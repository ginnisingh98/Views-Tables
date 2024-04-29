--------------------------------------------------------
--  DDL for Package Body OKE_PRINT_CONTRACT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PRINT_CONTRACT_WF" AS
/* $Header: OKEWCPPB.pls 120.1 2005/06/24 10:36:29 ausmani noship $ */

--
-- Global Variables
--
EventName    VARCHAR2(240)  := NULL;
l_Item_Key   VARCHAR2(1000) := 'DEFAULT';
--
-- Private Procedures and Functions
--
PROCEDURE GetEventName
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
) IS

BEGIN

  EventName := WF_ENGINE.GetItemAttrText
               ( ItemType => ItemType
               , ItemKey  => ItemKey
               , AName    => 'ECX_EVENT_NAME' );

END GetEventName;

PROCEDURE Raise_Business_Event
( P_Header_ID             IN            VARCHAR2
, P_Major_Version         IN            NUMBER
, X_Item_Key              OUT NOCOPY    VARCHAR2
) IS

  l_xmldocument        varchar2(30000);
  l_eventdata          clob;
  --l_message            varchar2(10);
  MapCode              VARCHAR2(30);
  TxnType              VARCHAR2(30) := 'ECX';
  EventName            VARCHAR2(80) := 'oracle.apps.oke.documents.contract.print';
  ParamList            wf_parameter_list_t := wf_parameter_list_t();

  l_latest_version     NUMBER; -- The latest version number of the contract
  l_org_id             NUMBER; -- for MOAC


  cursor c_version is
    select max(major_version)
    from oke_k_headers_hv
    where k_header_id =P_Header_id;

  cursor c_org is
    select authoring_org_id
    from oke_k_headers_v
    where k_header_id =P_Header_id;


BEGIN

  OPEN c_version;
  FETCH c_version INTO l_latest_version;
  CLOSE c_version;

  OPEN c_org;
  FETCH c_org INTO l_org_id;
  CLOSE c_org;

  IF P_Major_Version<=l_latest_version THEN
      MapCode     :='OKE_K_PRINT_H_OUT';
  ELSE
      MapCode     :='OKE_K_PRINT_OUT';
  END IF;


  --
  -- Building Parameter List
  --
  wf_event.AddParameterToList( p_name => 'ECX_MAP_CODE'
                             , p_value => MapCode
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_TRANSACTION_TYPE'
                             , p_value => TxnType
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_DOCUMENT_ID'
                             , p_value => P_Header_id
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER1'
                             , p_value => P_Header_ID
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER2'
                             , p_value => P_Major_Version
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ORG_ID'
                             , p_value => l_org_id
                             , p_parameterList => ParamList );


  IF ( OKE_UTILS.Debug_Mode = 'Y' ) THEN
    wf_event.AddParameterToList( p_name => 'ECX_DEBUG_LEVEL'
                               , p_value => '0'
                               , p_parameterList => ParamList );
  END IF;

  --
  -- Raise Event
  --

  wf_event.Raise( p_event_name => EventName
                    , p_event_key  => to_char(sysdate , 'YYYYMMDD HH24MISS')
                    , p_parameters => ParamList );

  ParamList.DELETE;

  X_Item_Key := l_Item_Key;


  commit;

  exception
  when others then
    null;

END;

--
-- Public Procedures
--
PROCEDURE Initialize
( ItemType            IN      VARCHAR2
, ItemKey             IN      VARCHAR2
, ActID               IN      NUMBER
, FuncMode            IN      VARCHAR2
, ResultOut           OUT NOCOPY     VARCHAR2
) IS


BEGIN

  IF ( FuncMode = 'RUN' ) THEN
    --
    -- Getting the event name from the Workflow attribute
    --
    GetEventName( ItemType , ItemKey );

    --
    -- The URL should be generic for all types of documents.
    -- Perform this action before form specific initializations
    -- so it is possible to override the result on a form-by-form
    -- basis.
    --
    WF_ENGINE.SetItemAttrText
    ( ItemType => ItemType
    , ItemKey  => ItemKey
    , AName    => 'DOCUMENT_URL'
    , AValue   => wfa_html.base_url ||
                  '/Wf_Event_Html.EventDataContents?' ||
                  'P_EventAttribute=ECX_EVENT_MESSAGE&' ||
                  'P_ItemType=' || ItemType || '&' ||
                  'P_ItemKey='  || replace(ItemKey , ' ' , '+')
    );


    l_Item_Key := 'P_ItemKey=' || replace(ItemKey , ' ' , '+');



    ResultOut := 'COMPLETE:';
    RETURN;

  END IF;

  IF ( FuncMode = 'CANCEL' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  IF ( FuncMode = 'TIMEOUT' ) THEN
    ResultOut := '';
    RETURN;
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    ResultOut := 'ERROR:';
    WF_Core.Context
            ( 'OKE_PRINT_CONTRACT_WF'
            , 'INITIALIZE'
            , ItemType
            , ItemKey
            , to_char(ActID)
            , FuncMode
            , ResultOut );
    RAISE;

END Initialize;

FUNCTION getEventData
( p_itemType                 IN            VARCHAR2
, p_itemKey                  IN            VARCHAR2
)RETURN CLOB IS

l_event_t            wf_event_t;
l_eventdata          clob;

BEGIN
	wf_event_t.Initialize(l_event_t);

	l_event_t :=wf_engine.GetItemAttrEvent(
                                              itemType          => p_itemType,
                                              itemKey           => p_itemKey,
                                              name              =>'ECX_EVENT_MESSAGE');
        l_eventData :=l_event_t.GetEventData();
        return l_eventData;

END getEventData;

END OKE_PRINT_CONTRACT_WF;

/
