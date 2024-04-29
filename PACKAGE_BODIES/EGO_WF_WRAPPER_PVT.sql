--------------------------------------------------------
--  DDL for Package Body EGO_WF_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_WF_WRAPPER_PVT" AS
/* $Header: EGOVWFWB.pls 120.12.12010000.4 2010/06/02 14:06:24 shsahu ship $ */



                   ------------------------------
                   -- Private Global Variables --
                   ------------------------------

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'EGO_WF_WRAPPER_PVT';--R12C Batch Level Business Event switches
--R12C Entity level Business events switch
G_ITEM_BULKLOAD_BUS_EVENT           VARCHAR2(1)     :=   FND_API.G_TRUE;
G_REV_CHANGE_BUS_EVENT              VARCHAR2(1)     :=   FND_API.G_TRUE;
G_CAT_ASSIGN_BUS_EVENT              VARCHAR2(1)     :=   FND_API.G_TRUE;
G_POST_ATTR_BUS_EVENT               VARCHAR2(1)     :=   FND_API.G_TRUE;
G_POST_AML_BUS_EVENT                VARCHAR2(1)     :=   FND_API.G_TRUE;
G_ITEM_PEOPLE_BUS_EVENT             VARCHAR2(1)     :=   FND_API.G_TRUE;

----------------------------------------------------------------------


                      -----------------------
                      -- Public Procedures --
                      -----------------------


----------------------------------------------------------------------



PROCEDURE Raise_WF_Business_Event (
        p_event_name                    IN   VARCHAR2
       ,p_event_key                     IN   VARCHAR2
       ,p_pre_event_flag                IN   VARCHAR2         DEFAULT NULL --Not null when used to raise pre event
       ,p_request_id                    IN   VARCHAR2         DEFAULT NULL
       ,p_dml_type                      IN   VARCHAR2         DEFAULT NULL
       ,p_attr_group_name               IN   VARCHAR2         DEFAULT NULL
       ,p_extension_id                  IN   NUMBER           DEFAULT NULL
       ,p_primary_key_1_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_1_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_2_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_2_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_3_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_3_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_4_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_4_value           IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_5_col_name        IN   VARCHAR2         DEFAULT NULL
       ,p_primary_key_5_value           IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_id                 IN   NUMBER           DEFAULT NULL
       ,p_data_level_1_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_1_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_2_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_2_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_3_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_3_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_4_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_4_value            IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_5_col_name         IN   VARCHAR2         DEFAULT NULL
       ,p_data_level_5_value            IN   VARCHAR2         DEFAULT NULL
       ,p_user_row_identifier           IN   VARCHAR2         DEFAULT NULL
       ,p_attr_name_val_tbl             IN   EGO_ATTR_TABLE   DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2         DEFAULT NULL
       ,p_entity_index                  IN   NUMBER           DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2         DEFAULT NULL
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2         DEFAULT NULL
) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Raise_WF_Business_Event';

    l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
    l_index                  NUMBER;

  BEGIN
    IF p_request_id IS NOT NULL THEN --Not null in case of PostAttributeChange event from Bulk Load
      l_parameter_t.SetName('REQUEST_ID');
      l_parameter_t.SetValue(p_request_id);
      l_parameter_list.EXTEND();
      l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;
    ELSE
      ------------------------------------------------------------
      -- We start our parameter list with the basic information --
      ------------------------------------------------------------
      l_parameter_t.SetName('DML_TYPE');
      l_parameter_t.SetValue(p_dml_type);
      l_parameter_list.EXTEND();
      l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;
      l_parameter_t.SetName('ATTR_GROUP_NAME');
      l_parameter_t.SetValue(p_attr_group_name);
      l_parameter_list.EXTEND();
      l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

      l_parameter_t.SetName('DATA_LEVEL_ID');
      l_parameter_t.SetValue(p_data_level_id);
      l_parameter_list.EXTEND();
      l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

      l_parameter_t.SetName('EXTENSION_ID');
      IF p_pre_event_flag IS NOT NULL AND  p_dml_type='CREATE' THEN  --while raising preAttrbuteChange for CREATE
        l_parameter_t.SetValue(null);
      ELSE
        l_parameter_t.SetValue(p_extension_id);
      END IF;

      l_parameter_list.EXTEND();
      l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

      ---------------------------------------------------------------
      -- We add as many Primary Key names/values as were passed... --
      ---------------------------------------------------------------
      IF (p_primary_key_1_col_name IS NOT NULL) THEN

        l_parameter_t.SetName(p_primary_key_1_col_name);
        l_parameter_t.SetValue(p_primary_key_1_value);
        l_parameter_list.EXTEND();
        l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

        IF (p_primary_key_2_col_name IS NOT NULL) THEN

          l_parameter_t.SetName(p_primary_key_2_col_name);
          l_parameter_t.SetValue(p_primary_key_2_value);
          l_parameter_list.EXTEND();
          l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

          IF (p_primary_key_3_col_name IS NOT NULL) THEN

            l_parameter_t.SetName(p_primary_key_3_col_name);
            l_parameter_t.SetValue(p_primary_key_3_value);
            l_parameter_list.EXTEND();
            l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

            IF (p_primary_key_4_col_name IS NOT NULL) THEN

              l_parameter_t.SetName(p_primary_key_4_col_name);
              l_parameter_t.SetValue(p_primary_key_4_value);
              l_parameter_list.EXTEND();
              l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

              IF (p_primary_key_5_col_name IS NOT NULL) THEN

                l_parameter_t.SetName(p_primary_key_5_col_name);
                l_parameter_t.SetValue(p_primary_key_5_value);
                l_parameter_list.EXTEND();
                l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

              END IF;
            END IF;
          END IF;
        END IF;
      END IF;

      --------------------------------------------------------
      -- ... and we do the same for Data Level names/values --
      --------------------------------------------------------
      IF (p_data_level_1_col_name IS NOT NULL) THEN

        l_parameter_t.SetName(p_data_level_1_col_name);
        l_parameter_t.SetValue(p_data_level_1_value);
        l_parameter_list.EXTEND();
        l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

        IF (p_data_level_2_col_name IS NOT NULL) THEN

          l_parameter_t.SetName(p_data_level_2_col_name);
          l_parameter_t.SetValue(p_data_level_2_value);
          l_parameter_list.EXTEND();
          l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

          IF (p_data_level_3_col_name IS NOT NULL) THEN

            l_parameter_t.SetName(p_data_level_3_col_name);
            l_parameter_t.SetValue(p_data_level_3_value);
            l_parameter_list.EXTEND();
            l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

            IF (p_data_level_4_col_name IS NOT NULL) THEN

              l_parameter_t.SetName(p_data_level_4_col_name);
              l_parameter_t.SetValue(p_data_level_4_value);
              l_parameter_list.EXTEND();
              l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

              IF (p_data_level_5_col_name IS NOT NULL) THEN

                l_parameter_t.SetName(p_data_level_5_col_name);
                l_parameter_t.SetValue(p_data_level_5_value);
                l_parameter_list.EXTEND();
                l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;

	      END IF;
	    END IF;
          END IF;
        END IF;
      END IF;

      IF p_pre_event_flag IS NOT NULL AND  --in case of pre event
         p_attr_name_val_tbl.COUNT > 0 THEN
        l_index := p_attr_name_val_tbl.FIRST;
        WHILE l_index <= p_attr_name_val_tbl.LAST LOOP
          l_parameter_t.SetName(p_attr_name_val_tbl(l_index).attr_name);
          l_parameter_t.SetValue(p_attr_name_val_tbl(l_index).attr_value);
          l_parameter_list.EXTEND();
          l_parameter_list(l_parameter_list.LAST()) := l_parameter_t;
          l_index := p_attr_name_val_tbl.NEXT(l_index);
        END LOOP;
      END IF;

    END IF; --Request_ID
    BEGIN

      WF_EVENT.Raise(p_event_name => p_event_name
                    ,p_event_key  => p_event_key
                    ,p_parameters => l_parameter_list);
    EXCEPTION
      WHEN OTHERS THEN
        --if pre event only then raise the user defined exception, put SQLERRM in to the stack
        -- Bug 6376745 	#commenting out the below check
        -- IF p_pre_event_flag IS NOT NULL THEN
        --for pre event only we expect the user to have a Synchronous subscriptions (phase 0-99)
          DECLARE
            l_token_table            ERROR_HANDLER.Token_Tbl_Type;
          BEGIN
           -- Uncommenting the below block as part of fix
            l_token_table(1).TOKEN_NAME := 'PKG_NAME';
            l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
            l_token_table(2).TOKEN_NAME := 'API_NAME';
            l_token_table(2).TOKEN_VALUE := l_api_name;
            l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
            l_token_table(3).TOKEN_VALUE := SQLERRM;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name              => 'EGO_EVENT_SUBSCR'
             ,p_application_id            => 'EGO'
             --,p_token_tbl                 => l_token_table  ---parameters Commented for bug 6518941
             ,p_message_type              => FND_API.G_RET_STS_ERROR
             --,p_row_identifier            => p_user_row_identifier
             --,p_entity_id                 => p_entity_id
             --,p_entity_index              => p_entity_index
             --,p_entity_code               => p_entity_code
             ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
            );
            raise EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC;
          END;
        --ELSE --for post event do the default handling
        --    raise;
        --END IF;
    END;

  EXCEPTION
    -----------------------------------------------------------
    ---Exception raised by Subscription
    -----------------------------------------------------------
    WHEN EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC THEN
      raise EGO_USER_ATTRS_COMMON_PVT.G_SUBSCRIPTION_EXC;

    -----------------------------------------------------------
    ---for unexpected exceptions-
    -----------------------------------------------------------
    WHEN OTHERS THEN
      DECLARE
        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
      BEGIN
        l_token_table(1).TOKEN_NAME := 'PKG_NAME';
        l_token_table(1).TOKEN_VALUE := G_PKG_NAME;
        l_token_table(2).TOKEN_NAME := 'API_NAME';
        l_token_table(2).TOKEN_VALUE := l_api_name;
        l_token_table(3).TOKEN_NAME := 'SQL_ERR_MSG';
        l_token_table(3).TOKEN_VALUE := SQLERRM;

        ERROR_HANDLER.Add_Error_Message(
          p_message_name              => 'EGO_PLSQL_ERR'
         ,p_application_id            => 'EGO'
         ,p_token_tbl                 => l_token_table
         ,p_message_type              => FND_API.G_RET_STS_ERROR
         ,p_row_identifier            => p_user_row_identifier
         ,p_entity_id                 => p_entity_id
         ,p_entity_index              => p_entity_index
         ,p_entity_code               => p_entity_code
         ,p_addto_fnd_stack           => p_add_errors_to_fnd_stack
        );
      END;

END Raise_WF_Business_Event;


/*-------------------------------------------------------
Requirement : To riase business event postAMLChange
-------------------------------------------------------*/
PROCEDURE Raise_AML_Event (
                           p_event_name          IN   VARCHAR2
                          ,p_dml_type            IN   VARCHAR2
                          ,p_Inventory_Item_Id   IN   NUMBER
                          ,p_Organization_Id     IN   NUMBER
                          ,p_Manufacturer_Id     IN   NUMBER
                          ,p_Mfg_Part_Num        IN   VARCHAR2
                          ,x_msg_data            OUT  NOCOPY VARCHAR2
                          ,x_return_status       OUT  NOCOPY VARCHAR2
                          )
IS
  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
  l_event_name		   VARCHAR2(240);
  l_event_key              VARCHAR2(240);
  l_event_num              NUMBER;

BEGIN

  l_event_name := p_event_name ;
  --l_event_key  := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

    SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;  --Bug: 5606011
    l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;


  --Adding the parameters
  wf_event.AddParameterToList(p_name          => 'INVENTORY_ITEM_ID'
                             ,p_value         => p_Inventory_Item_Id
                             ,p_ParameterList => l_parameter_List);
  wf_event.AddParameterToList(p_name          => 'ORGANIZATION_ID'
                             ,p_value         => p_Organization_Id
                             ,p_ParameterList => l_parameter_List);
  wf_event.AddParameterToList(p_name          => 'DML_TYPE'
                             ,p_value         => p_dml_type
                             ,p_ParameterList => l_parameter_List);
  wf_event.AddParameterToList(p_name          => 'MANUFACTURER_ID'
                             ,p_value         => p_Manufacturer_Id
                             ,p_ParameterList => l_parameter_List);
  wf_event.AddParameterToList(p_name          => 'MFG_PART_NUM'
                             ,p_value         => p_Mfg_Part_Num
                             ,p_ParameterList => l_parameter_List);

/*R12: Business Events*/
  WF_EVENT.Raise(p_event_name => l_event_name
                ,p_event_key  => l_event_key
                ,p_parameters => l_parameter_list);

  l_parameter_list.DELETE;
  x_return_status :=FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  -----------------------------------------------------------
  -- There are no expected errors in this procedure, so... --
  -----------------------------------------------------------
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := p_event_name ||' '|| SQLERRM;
END Raise_AML_Event;


------------------------------------------------------------------
-- Start : 4105841 : Business Event Enhancement
--Procedure to raise the event for Item Create and update  --
--------------------------------------------------------------------
/*Added the new parameter p_is_master_attr_modified */
PROCEDURE Raise_Item_Create_Update_Event (
                           p_event_name          IN   VARCHAR2
                          ,p_request_id          IN   NUMBER    DEFAULT NULL
                          ,p_Organization_Id     IN   NUMBER    DEFAULT NULL
                          ,p_organization_code   IN   VARCHAR2  DEFAULT NULL
                          ,p_Inventory_Item_Id   IN   NUMBER    DEFAULT NULL
                          ,p_item_number         IN   VARCHAR2  DEFAULT NULL
                          ,p_item_description    IN   VARCHAR2  DEFAULT NULL
			  ,p_is_master_attr_modified IN   VARCHAR2  DEFAULT 'N'
                          ,x_msg_data            OUT  NOCOPY VARCHAR2
                          ,x_return_status       OUT  NOCOPY VARCHAR2
                          )
IS
  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_parameter_t            WF_PARAMETER_T:= WF_PARAMETER_T(null, null);
  l_event_name             VARCHAR2(240);
  l_event_key              VARCHAR2(240);
  l_event_num              NUMBER;
  l_org_id                 NUMBER;

  Cursor c_get_org_id(p_organization_code VARCHAR2) is
  Select organization_id
  from org_organization_definitions
  where organization_code = p_organization_code;
BEGIN

  l_event_name := p_event_name ;
  --l_event_key  := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

    SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;  --Bug: 5606011
    l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;


  --Adding the parameters
  IF p_request_id IS NOT NULL THEN --in case of Bulk Load
    wf_event.AddParameterToList( p_name            => 'REQUEST_ID'
                                ,p_value           => p_request_id
                                ,p_ParameterList   => l_parameter_List);
  ELSE
    -- Fix for bug#8474046
    IF (p_organization_id = FND_API.G_MISS_NUM and p_organization_code is not null) THEN
      -- Derive the Organization_id from Organization Code
      OPEN  c_get_org_id(p_organization_code);
      FETCH c_get_org_id INTO l_org_id;
      CLOSE c_get_org_id;
    ELSE
      l_org_id := p_organization_id;
    END IF;

    wf_event.AddParameterToList( p_name            => 'INVENTORY_ITEM_ID'
                                ,p_value           => p_Inventory_Item_Id
                                ,p_ParameterList   => l_parameter_List);
    wf_event.AddParameterToList( p_name            => 'ORGANIZATION_ID'
                                ,p_value           => l_org_id -- fix for bug#8474046 p_Organization_Id
                                ,p_ParameterList   => l_parameter_List);
    wf_event.AddParameterToList( p_name            => 'ORGANIZATION_CODE'
                                ,p_value           =>  p_organization_code
                                ,p_ParameterList   => l_parameter_List);
    wf_event.AddParameterToList( p_name            => 'ITEM_NUMBER'
                                ,p_value           => p_item_number
                                ,p_ParameterList   => l_parameter_List);
    wf_event.AddParameterToList( p_name            => 'ITEM_DESCRIPTION'
                                ,p_value           => p_item_description
                                ,p_ParameterList   => l_parameter_List);
    wf_event.AddParameterToList( p_name            => 'IS_MASTER_ATTR_MODIFIED'
                                 ,p_value          => p_is_master_attr_modified
                                 ,p_ParameterList  => l_parameter_List);

  END IF;

/*R12: Business Events*/
  WF_EVENT.Raise(p_event_name => l_event_name
                ,p_event_key  => l_event_key
                ,p_parameters => l_parameter_list);


  l_parameter_list.DELETE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN Others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      := SQLERRM ;
END Raise_Item_Create_Update_Event;


/* -------------------------------------------------------------------
   Procedure  : Raise_Item_Event
   Purpose    : Raise Work flow event
 ------------------------------------------------------------------*/
  PROCEDURE  Raise_Item_Event(
	  p_event_name          IN   VARCHAR2
         ,p_dml_type            IN   VARCHAR2    DEFAULT NULL
         ,p_request_id          IN   VARCHAR2    DEFAULT NULL
         ,p_Inventory_Item_Id    IN   NUMBER      DEFAULT NULL
         ,p_Organization_Id      IN   NUMBER      DEFAULT NULL
         ,p_Revision_id          IN   NUMBER      DEFAULT NULL
         ,p_category_id          IN   VARCHAR2    DEFAULT NULL
         ,p_catalog_id           IN   VARCHAR2    DEFAULT NULL
         ,p_old_category_id      IN   NUMBER      DEFAULT NULL --add 8310065 with base bug 8351807
         ,p_cross_reference_type IN   VARCHAR2    DEFAULT NULL --r12
         ,p_cross_reference      IN   VARCHAR2    DEFAULT NULL --r12
         ,p_customer_item_id     IN   NUMBER      DEFAULT NULL --r12
         ,p_related_item_id      IN   NUMBER      DEFAULT NULL --r12
         ,p_relationship_type_id IN   NUMBER      DEFAULT NULL --r12
         ,p_role_id              IN   NUMBER      DEFAULT NULL --r12
         ,p_party_type           IN   VARCHAR2    DEFAULT NULL --r12
         ,p_party_id             IN   NUMBER      DEFAULT NULL --r12
         ,p_start_date           IN   DATE        DEFAULT NULL --r12
         ,x_msg_data            OUT   NOCOPY VARCHAR2
         ,x_return_status       OUT   NOCOPY VARCHAR2)
  IS
    l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    l_parameter_t            WF_PARAMETER_T      := WF_PARAMETER_T(null, null);
    l_event_name             VARCHAR2(240);
    l_event_key              VARCHAR2(240);
    l_event_num              NUMBER;
    l_raise_item_cat_assign   VARCHAR2(2);
    l_raise_alt_cat_hier_chg  VARCHAR2(2);
    l_raise_catalog_cat_chg   VARCHAR2(2);
  BEGIN
    l_event_name := p_event_name ;
    --l_event_key  := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

    SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;  --Bug: 5606011
    l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;

    IF p_request_id IS NOT NULL THEN --in case of Bulk Load
      wf_event.AddParameterToList( p_name            => 'REQUEST_ID'
                                  ,p_value           => p_request_id
                                  ,p_ParameterList   => l_parameter_List);
    ELSE
      wf_event.AddParameterToList( p_name           => 'INVENTORY_ITEM_ID'
                                 , p_value           => p_Inventory_Item_Id
                                 , p_ParameterList   => l_parameter_List);
      wf_event.AddParameterToList( p_name           => 'ORGANIZATION_ID'
                                 , p_value           => p_Organization_Id
                                 , p_ParameterList   => l_parameter_List);

      IF p_dml_type IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name           => 'DML_TYPE'
                                   , p_value           => p_dml_type
                                   , p_ParameterList   => l_parameter_List);
      END IF;

      IF p_Revision_id IS NOT NULL THEN
         wf_event.AddParameterToList( p_name            => 'REVISION_ID'
                                   , p_value           => p_Revision_id
                                   , p_ParameterList   => l_parameter_List);
      END IF;

      IF p_catalog_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CATALOG_ID'
                                    ,p_value            => p_catalog_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;
      IF p_category_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CATEGORY_ID'
                                    ,p_value            => p_category_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;
      --add 8310065 with base bug 8351807
 	    IF p_old_category_id IS NOT NULL  THEN
 	      wf_event.AddParameterToList( p_name             => 'OLD_CATEGORY_ID'
 	                                       ,p_value            => p_old_category_id
 	                                       ,p_ParameterList    => l_parameter_List);
 	    END IF;

      IF p_cross_reference_type IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CROSS_REFERENCE_TYPE'
                                    ,p_value            => p_cross_reference_type
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_cross_reference IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CROSS_REFERENCE'
                                    ,p_value            => p_cross_reference
                                    ,p_ParameterList    => l_parameter_List);
      END IF;
/***
  These parameters are commented as the associated events are not routed
  through this package currently.
      IF p_role_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'ROLE_ID'
                                    ,p_value            => p_role_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_party_type IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'PARTY_TYPE'
                                    ,p_value            => p_party_type
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_party_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'PARTY_ID'
                                    ,p_value            => p_party_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_start_date IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'START_DATE'
                                    ,p_value            => p_start_date
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_customer_item_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CUSTOMER_ITEM_ID'
                                    ,p_value            => p_customer_item_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_related_item_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'RELATED_ITEM_ID'
                                    ,p_value            => p_related_item_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;

      IF p_relationship_type_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'RELATIONSHIP_TYPE_ID'
                                    ,p_value            => p_relationship_type_id
                                    ,p_ParameterList    => l_parameter_List);
      END IF;
***/
    END IF;

 /*R12: Business Events*/
    IF p_catalog_id IS NOT NULL  THEN
        BEGIN
            SELECT raise_item_cat_assign_event, raise_alt_cat_hier_chg_event, raise_catalog_cat_chg_event
            INTO l_raise_item_cat_assign, l_raise_alt_cat_hier_chg, l_raise_catalog_cat_chg
            FROM mtl_category_sets_b
            WHERE category_set_id = p_catalog_id;

            IF l_event_name = 'oracle.apps.ego.item.postCatalogAssignmentChange' AND l_raise_item_cat_assign = 'Y'  THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
            IF l_event_name = 'oracle.apps.ego.item.postCatalogCategoryChange' AND l_raise_catalog_cat_chg = 'Y' THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
            IF l_event_name = 'oracle.apps.ego.item.postValidCategoryChange' AND l_raise_alt_cat_hier_chg = 'Y' THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
        END;
    ELSE

        WF_EVENT.Raise( p_event_name => l_event_name
                       ,p_event_key  => l_event_key
                       ,p_parameters => l_parameter_list);
    END IF;

    l_parameter_list.DELETE;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   EXCEPTION
     WHEN Others THEN
      x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := SQLERRM;
  END Raise_Item_Event;
  --End : 4105841 : Business Event Enhancement

  --R12 Business Event Enhancement
  PROCEDURE Raise_Categories_Event(
          p_event_name           IN   VARCHAR2
         ,p_dml_type             IN   VARCHAR2 DEFAULT NULL
         ,p_category_set_id      IN   NUMBER   DEFAULT NULL
         ,p_category_id          IN   NUMBER   DEFAULT NULL
         ,p_category_name        IN   VARCHAR2 DEFAULT NULL
         ,x_msg_data            OUT   NOCOPY   VARCHAR2
         ,x_return_status       OUT   NOCOPY   VARCHAR2) IS

  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_parameter_t            WF_PARAMETER_T      := WF_PARAMETER_T(null, null);
  l_event_name             VARCHAR2(240);
  l_event_key              VARCHAR2(240);
  l_event_num              NUMBER;
  l_raise_item_cat_assign   VARCHAR2(2);
  l_raise_alt_cat_hier_chg  VARCHAR2(2);
  l_raise_catalog_cat_chg   VARCHAR2(2);
  BEGIN
    l_event_name := p_event_name ;
    --l_event_key  := SUBSTRB(l_event_name, 1, 225) || '-' || TO_CHAR(SYSDATE, 'J.SSSSS');

    SELECT MTL_BUSINESS_EVENTS_S.NEXTVAL into l_event_num FROM dual;  --Bug: 5606011
    l_event_key := SUBSTRB(l_event_name, 1, 255) || '-' || l_event_num;

    IF p_dml_type IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name           => 'DML_TYPE'
                                   , p_value           => p_dml_type
                                   , p_ParameterList   => l_parameter_List);
    END IF;

    IF p_category_set_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CATEGORY_SET_ID'
                                    ,p_value            => p_category_set_id
                                    ,p_ParameterList    => l_parameter_List);
    END IF;


    IF p_category_id IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CATEGORY_ID'
                                    ,p_value            => p_category_id
                                    ,p_ParameterList    => l_parameter_List);
    END IF;

    IF p_category_name IS NOT NULL  THEN
        wf_event.AddParameterToList( p_name             => 'CATEGORY_NAME'
                                    ,p_value            => p_category_name
                                    ,p_ParameterList    => l_parameter_List);
    END IF;

    IF p_category_set_id IS NOT NULL  THEN
        BEGIN
            SELECT raise_item_cat_assign_event, raise_alt_cat_hier_chg_event, raise_catalog_cat_chg_event
            INTO l_raise_item_cat_assign, l_raise_alt_cat_hier_chg, l_raise_catalog_cat_chg
            FROM mtl_category_sets_b
            WHERE category_set_id = p_category_set_id;

            IF l_event_name = 'oracle.apps.ego.item.postCatalogAssignmentChange' AND l_raise_item_cat_assign = 'Y'  THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
            IF l_event_name = 'oracle.apps.ego.item.postCatalogCategoryChange' AND l_raise_catalog_cat_chg = 'Y' THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
            IF l_event_name = 'oracle.apps.ego.item.postValidCategoryChange' AND l_raise_alt_cat_hier_chg = 'Y' THEN
                WF_EVENT.Raise( p_event_name => l_event_name
                               ,p_event_key  => l_event_key
                               ,p_parameters => l_parameter_list);
            END IF;
        END;
    ELSE
        WF_EVENT.Raise( p_event_name => l_event_name
                       ,p_event_key  => l_event_key
                       ,p_parameters => l_parameter_list);
    END IF;

    l_parameter_list.DELETE;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    EXCEPTION
      WHEN Others THEN
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := SQLERRM;
END Raise_Categories_Event;

--R12C Raise Post Process Message Event for Orchestration
PROCEDURE Raise_Post_Process_Msg_Event(
          p_event_name            IN   VARCHAR2
         ,p_entity_name           IN   VARCHAR2
         ,p_pk1_value             IN   VARCHAR2
         ,p_pk2_value             IN   VARCHAR2
         ,p_pk3_value             IN   VARCHAR2
         ,p_pk4_value             IN   VARCHAR2
         ,p_pk5_value             IN   VARCHAR2
         ,p_processing_type       IN   VARCHAR2
         ,p_language_code         IN   VARCHAR2
         ,p_last_update_date      IN   VARCHAR2
         ,x_msg_data              OUT  NOCOPY VARCHAR2
         ,x_return_status         OUT  NOCOPY VARCHAR2
         )
IS

  l_parameter_list         WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
  l_event_name             VARCHAR2(240);
  l_event_key              VARCHAR2(240);

BEGIN

  l_event_name := p_event_name ;

  SELECT  TO_CHAR( SYSTIMESTAMP, 'dd-mon-yyyy hh24:mi:ss:ffff' )
  INTO    l_event_key
  FROM    DUAL;

  WF_EVENT.AddParameterToList( p_name             => 'ENTITY_NAME'
                              ,p_value            => p_entity_name
                              ,p_ParameterList    => l_parameter_List);


  WF_EVENT.AddParameterToList( p_name             => 'PK1_VALUE'
                              ,p_value            => p_pk1_value
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'PK2_VALUE'
                              ,p_value            => p_pk2_value
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'PK3_VALUE'
                              ,p_value            => p_pk3_value
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'PK4_VALUE'
                              ,p_value            => p_pk4_value
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'PK5_VALUE'
                              ,p_value            => p_pk5_value
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'PROCESSING_TYPE'
                              ,p_value            => p_processing_type
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'LANGUAGE_CODE'
                              ,p_value            => p_language_code
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.AddParameterToList( p_name             => 'LAST_UPDATE_DATE'
                              ,p_value            => p_last_update_date
                              ,p_ParameterList    => l_parameter_List);

  WF_EVENT.Raise( p_event_name => l_event_name
                 ,p_event_key  => l_event_key
                 ,p_parameters => l_parameter_list);

  l_parameter_list.DELETE;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  x_msg_data := NULL;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;

END Raise_Post_Process_Msg_Event;

--R12C Setters for Entity Level Business events
PROCEDURE Set_Item_Bulkload_Bus_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_ITEM_BULKLOAD_BUS_EVENT := l_true_false;
END Set_Item_Bulkload_Bus_Event;

PROCEDURE Set_Rev_Change_Bus_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_REV_CHANGE_BUS_EVENT := l_true_false;
END Set_Rev_Change_Bus_Event;

PROCEDURE Set_Category_Assign_Bus_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) OR p_true_false IS NULL THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_CAT_ASSIGN_BUS_EVENT := l_true_false;
END Set_Category_Assign_Bus_Event;

PROCEDURE Set_PostAttr_Change_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_POST_ATTR_BUS_EVENT := l_true_false;
END Set_PostAttr_Change_Event;

PROCEDURE Set_PostAml_Change_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_POST_AML_BUS_EVENT := l_true_false;
END Set_PostAml_Change_Event;

PROCEDURE Set_Item_People_Event(p_true_false IN VARCHAR2)
IS
  l_true_false VARCHAR2(1);
BEGIN
  l_true_false := p_true_false;
  IF p_true_false NOT IN (FND_API.g_true, FND_API.g_false) THEN
     l_true_false := FND_API.g_true;
  END IF;
  G_ITEM_PEOPLE_BUS_EVENT := l_true_false;
END Set_Item_People_Event;

--R12C Getters for Entity Level Business events
FUNCTION Get_Item_Bulkload_Bus_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_ITEM_BULKLOAD_BUS_EVENT );
END Get_Item_Bulkload_Bus_Event;

FUNCTION Get_Rev_Change_Bus_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_REV_CHANGE_BUS_EVENT );
END Get_Rev_Change_Bus_Event;

FUNCTION Get_Category_Assign_Bus_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_CAT_ASSIGN_BUS_EVENT );
END Get_Category_Assign_Bus_Event;

FUNCTION Get_PostAttr_Change_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_POST_ATTR_BUS_EVENT );
END Get_PostAttr_Change_Event;

FUNCTION Get_PostAml_Change_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_POST_AML_BUS_EVENT );
END Get_PostAml_Change_Event;

FUNCTION Get_Item_People_Event RETURN VARCHAR2
IS
BEGIN
   RETURN(G_ITEM_PEOPLE_BUS_EVENT );
END Get_Item_People_Event;

END EGO_WF_WRAPPER_PVT;

/
