--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_BES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_BES_UTIL" AS
/* $Header: ENGUBESB.pls 120.4 2006/03/19 20:52:17 mkimizuk noship $ */

  -- ---------------------------------------------------------------------------
  -- Global variables and constants
  -- ---------------------------------------------------------------------------
  G_PKG_NAME                VARCHAR2(30) := 'ENG_CHANGE_BES_UTIL';



  /********************************************************************
  * API Type      : Private Local APIs
  * Purpose       : Those APIs are private
  *********************************************************************/
  FUNCTION GetChangeMgmtTypeCode
  ( p_change_id         IN     NUMBER)
  RETURN VARCHAR2
  IS
    l_cm_code VARCHAR2(30) ;

    CURSOR  c_cm_code(c_change_id NUMBER)
    IS
        -- Select cm category code
        SELECT ec.change_mgmt_type_code
        FROM eng_engineering_changes ec
        WHERE ec.change_id = p_change_id ;

  BEGIN
    FOR l_rec IN c_cm_code  (c_change_id => p_change_id)
    LOOP
        l_cm_code :=  l_rec.CHANGE_MGMT_TYPE_CODE  ;
    END LOOP ;

    RETURN l_cm_code ;

  END  GetChangeMgmtTypeCode ;


  FUNCTION GetBaseChangeMgmtTypeCode
  ( p_change_id         IN     NUMBER)
    RETURN VARCHAR2
  IS
       -- return SUMMARY or DETAIL
      l_base_cm_code VARCHAR2(30) ;

      CURSOR  c_base_cm_code(p_change_id NUMBER)
      IS
          SELECT ChangeCategory.BASE_CHANGE_MGMT_TYPE_CODE
          FROM ENG_ENGINEERING_CHANGES EngineeringChangeEO,
               ENG_CHANGE_ORDER_TYPES ChangeCategory
          WHERE  ChangeCategory.type_classification = 'CATEGORY'
          AND ChangeCategory.change_mgmt_type_code = EngineeringChangeEO.change_mgmt_type_code
          AND EngineeringChangeEO.change_id = p_change_id  ;

  BEGIN
      FOR l_rec IN c_base_cm_code  (p_change_id => p_change_id)
      LOOP
        l_base_cm_code :=  l_rec.BASE_CHANGE_MGMT_TYPE_CODE  ;
      END LOOP ;

      RETURN l_base_cm_code ;

  END  GetBaseChangeMgmtTypeCode ;




  /********************************************************************
  * API Type      : Local APIs
  * Purpose       : Those APIs are private
  *********************************************************************/
  PROCEDURE Raise_Status_Change_Event
  ( p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
   )
  IS

    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_base_cm_code              VARCHAR2(30) ;

  BEGIN


    l_base_cm_code := GetBaseChangeMgmtTypeCode (p_change_id) ;

    IF ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_LIFECYCLE = l_base_cm_code
    THEN
        RETURN ;
    END IF ;

    -- Adding event parameters to the list
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => l_base_cm_code
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_STATUS_CODE
     ,p_value         => to_char(p_status_code)
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACT_TYPE_CODE
     ,p_value         => p_action_type
     ,p_parameterList => l_param_list
     );


    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACTION_ID
     ,p_value         => to_char(p_action_id)
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_CHG_STATUS
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );
    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Raise_Status_Change_Event;


  PROCEDURE Raise_Appr_Status_Change_Event
  ( p_change_id                 IN   NUMBER
   ,p_appr_status               IN   NUMBER
   ,p_wf_route_status           IN   VARCHAR2
   )
  IS

    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_base_cm_code              VARCHAR2(30) ;

  BEGIN

    l_base_cm_code := GetBaseChangeMgmtTypeCode (p_change_id) ;

    IF ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_LIFECYCLE = l_base_cm_code
    THEN
        RETURN ;
    END IF ;


    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => l_base_cm_code
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_NEW_APPR_STS_CODE
     ,p_value         => p_appr_status
     ,p_parameterList => l_param_list
     );
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_WF_STATUS_CODE
     ,p_value         => p_wf_route_status
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_CHG_APPR_STATUS
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );
    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Raise_Appr_Status_Change_Event;



  PROCEDURE Raise_Post_Comment_Event
  ( p_change_id                 IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
  )
  IS
    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_base_cm_code              VARCHAR2(30) ;

  BEGIN

    l_base_cm_code := GetBaseChangeMgmtTypeCode (p_change_id) ;

    IF ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_LIFECYCLE = l_base_cm_code
    THEN
        RETURN ;
    END IF ;


    -- Adding event parameters to the list
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => l_base_cm_code
     ,p_parameterList => l_param_list
     );


    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACT_TYPE_CODE
     ,p_value         => p_action_type
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_ACTION_ID
     ,p_value         => to_char(p_action_id)
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_POST_COMMENT
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );

    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END Raise_Post_Comment_Event ;


  PROCEDURE Raise_Create_Change_Event
  ( p_change_id                 IN   NUMBER
  )
  IS

    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_base_cm_code              VARCHAR2(30) ;

  BEGIN

    l_base_cm_code := GetBaseChangeMgmtTypeCode (p_change_id) ;

    IF ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_LIFECYCLE = l_base_cm_code
    THEN
        RETURN ;
    END IF ;


    -- Adding event parameters to the list
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => l_base_cm_code
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_CREATE
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );

    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END Raise_Create_Change_Event ;


  PROCEDURE Raise_Update_Change_Event
  ( p_change_id                 IN   NUMBER
  )
  IS

    l_param_list                WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_base_cm_code              VARCHAR2(30) ;

  BEGIN

    l_base_cm_code := GetBaseChangeMgmtTypeCode (p_change_id) ;

    IF ENG_DOCUMENT_UTIL.G_DOM_DOCUMENT_LIFECYCLE = l_base_cm_code
    THEN
        RETURN ;
    END IF ;

    -- Adding event parameters to the list
    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_CHANGE_ID
     ,p_value         => to_char(p_change_id)
     ,p_parameterList => l_param_list
     );

    WF_EVENT.AddParameterToList
    ( p_name          => ENG_CHANGE_BES_UTIL.G_BES_PARAM_BASE_CM_TYPE_CODE
     ,p_value         => l_base_cm_code
     ,p_parameterList => l_param_list
     );

    -- Raise event
    WF_EVENT.RAISE
    ( p_event_name    => ENG_CHANGE_BES_UTIL.G_CMBE_HEADER_UPDATE
     ,p_event_key     => p_change_id
     ,p_parameters    => l_param_list
     );

    l_param_list.DELETE;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;

  END Raise_Update_Change_Event ;


END ENG_CHANGE_BES_UTIL;


/
