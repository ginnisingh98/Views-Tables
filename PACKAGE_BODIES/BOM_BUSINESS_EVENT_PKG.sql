--------------------------------------------------------
--  DDL for Package Body BOM_BUSINESS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BUSINESS_EVENT_PKG" as
/* $Header: BOMSBESB.pls 120.9.12010000.4 2009/12/24 08:25:18 gliang ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMSBESS.pls                                               |
| DESCRIPTION  : Package for raising various BOM Business Events            |
|                User of this API would use one of the defined constants    |
|                and call the raise event with the necessary parameters     |
|                Any Event that requires parameters must first call the     |
|          first call the Add_Parameter_To_List and then call the     |
|          raise_Event method. wf_parameter_list_t can be initialized |
|    as <variable> := wf_parameter_list_t()         |
| History:                    |
|--------                                                                   |
| 02-Sept-2003  Rahul Chitko  Initial Creation          |
+==========================================================================*/


  /*
  ** Procedure: Raise_Event
  ** Purpose  : Enables a Business Event to be raised. Any action within the realm of product structure
  **        can use this api to raise a pre-defined event, with the necessary parameters.
  ** Parameter: Event_Name - should ideally be one of the pre-defined constants. please refer to the spec.
  **        Event_Key  - a unique identifier for this event, something like sysdate.
  **        Parameter List - this is a name/value pair of parameters that will be passed to the event.
  */
  PROCEDURE Raise_Event( p_Event_Name IN  VARCHAR2
           , p_Event_Key  IN  VARCHAR2
           , p_Parameter_List IN OUT NOCOPY  wf_parameter_list_t
           )
  IS
  BEGIN
    wf_event.raise( p_Event_Name  => p_Event_Name
            , p_Event_Key => p_Event_Key
            , p_parameters  => p_Parameter_List
             );

    p_Parameter_List.DELETE;
 EXCEPTION
             --Added for bug 8462879
       WHEN OTHERS THEN
          ERROR_HANDLER.Add_Error_Message(
             p_message_name              => 'EGO_EVENT_SUBSCR'
            ,p_application_id            => 'EGO'
            ,p_message_type              => FND_API.G_RET_STS_ERROR
            ,p_addto_fnd_stack           => 'Y');
          raise Bom_Business_Event_PKG.G_SUBSCRIPTION_EXC;

 END Raise_Event;

  /*
  ** Procedure: Add_Parameter_To_List
  ** Purpose  : This is a wrappper procedure on top of what workflow provides. This indirection
  **        is created only to serve as a better extensibility.
  ** Parameter: p_Parameter_Name - name of the parameter
  **        p_value - value of the parameter
  **        parameter_list - returns the new parameter list
  */
  PROCEDURE Add_Parameter_To_List( p_Parameter_Name IN  VARCHAR2
               , p_Value    IN  VARCHAR2
               , p_parameter_List IN OUT NOCOPY wf_parameter_list_t
               )
  IS
  BEGIN

    wf_event.AddParameterToList( p_name   => p_Parameter_Name
             , p_value    => p_Value
             , p_ParameterList  => p_parameter_List
              );

  END Add_Parameter_To_List;


  /* Utility procedures */

        PROCEDURE Raise_Item_Event
        ( p_organization_id     IN  NUMBER
         ,p_inventory_item_id   IN  NUMBER
         ,p_item_name           IN  VARCHAR2
         ,p_item_description    IN  VARCHAR2
         ,p_Event_Name          IN  VARCHAR2)
  IS
    l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
  BEGIN
    Bom_Business_Event_PKG.Add_Parameter_To_List
    ( p_parameter_name => 'INVENTORY_ITEM_ID'
     ,p_value    => p_inventory_item_id
     ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
    (p_parameter_name => 'ORGANIZATION_ID'
    ,p_value    => p_organization_id
    ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
    (p_parameter_name => 'ITEM_NAME'
    ,p_value    => p_item_name
    ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
    (p_parameter_name => 'ITEM_DESCRIPTION'
    ,p_value    => p_item_description
    ,p_parameter_list => l_parameter_list);

    --bug:5245403 Create a file with time precision of fraction of seconds to avoid
    --overwrite in case of multiple events firing within a second.
    Bom_Business_Event_PKG.Raise_event
    ( p_Event_Name     => p_Event_Name
     ,p_Event_Key    => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
     ,p_parameter_list => l_parameter_list);

  END Raise_Item_Event;

         PROCEDURE Raise_Bill_Event
         ( p_pk1_value  IN  VARCHAR2
          ,p_pk2_value  IN  VARCHAR2
          ,p_obj_name   IN VARCHAR2
          ,p_structure_name IN VARCHAR2
          ,p_organization_id IN NUMBER
          ,p_structure_comment IN VARCHAR2
          ,p_Event_Name IN  VARCHAR2
	  ,p_revised_item_sequence_id IN NUMBER DEFAULT NULL --Added for BUG#8266922
	  )
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();

         BEGIN

                Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'OBJ_NAME'
                 ,p_value          =>  p_obj_name
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK1_VALUE'
                ,p_value          =>   p_pk1_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK2_VALUE'
                ,p_value          =>  p_pk2_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'STRUCTURE_NAME'
                ,p_value          => nvl(p_structure_name,'PRIMARY')
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'ORGANIZATION_ID'
                ,p_value    => p_organization_id
                ,p_parameter_list => l_parameter_list);


                Bom_Business_Event_PKG.Add_Parameter_To_List        -- Added for bug#8266922
                (p_parameter_name => 'REVISED_ITEM_SEQUENCE_ID'
                ,p_value    => p_revised_item_sequence_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END;

         PROCEDURE Raise_Component_Event
         ( p_bill_sequence_Id IN  NUMBER
           ,p_pk1_value IN VARCHAR2
           ,p_pk2_value IN VARCHAR2
           ,p_obj_name IN VARCHAR2
           ,p_organization_id IN NUMBER
           ,p_comp_item_name  IN VARCHAR2
           ,p_comp_description IN VARCHAR2
          ,p_Event_Name IN  VARCHAR2)
          IS

         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();

         BEGIN

                Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'OBJ_NAME'
                 ,p_value          =>  p_obj_name
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK1_VALUE'
                ,p_value          =>  p_pk1_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK2_VALUE'
                ,p_value          =>  p_pk2_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BILL_SEQUENCE_ID'
                ,p_value          =>  p_bill_sequence_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'ORGANIZATION_ID'
                ,p_value          =>  p_organization_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'COMPONENT_ITEM_NAME'
                ,p_value          =>  p_comp_item_name
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'COMPONENT_ITEM_DESCRIPTION'
                ,p_value          =>  p_comp_description
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END;



         -- Modified to add WHO columns
         PROCEDURE Raise_Bill_Event       --4306013
         (p_Event_Load_Type IN VARCHAR2
         ,p_Request_Identifier IN  NUMBER
         ,p_Batch_Identifier IN NUMBER
         ,p_Event_Entity_Name IN  VARCHAR2
         ,p_Event_Entity_Parent_Id IN  NUMBER
         ,p_Event_Name IN  VARCHAR2
         ,p_last_update_date IN DATE DEFAULT SYSDATE
         ,p_last_updated_by IN NUMBER DEFAULT NULL
         ,p_creation_date IN DATE DEFAULT SYSDATE
         ,p_created_by  IN NUMBER DEFAULT NULL
         ,p_last_update_login IN NUMBER DEFAULT NULL
         )
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         l_common_bill_sequence_id NUMBER;
         BEGIN
 SELECT common_bill_sequence_id INTO l_common_bill_sequence_id
    FROM bom_structures_b
    WHERE bill_sequence_id =  p_Event_Entity_Parent_Id;

Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'COMMON_BILL_SEQUENCE_ID'
                 ,p_value          =>  l_common_bill_sequence_id
                 ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'REQUEST_IDENTIFIER'
                ,p_value          =>   p_Request_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BATCH_IDENTIFIER'
                ,p_value          =>  p_Batch_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_PARENT_ID'
                ,p_value    => p_Event_Entity_Parent_Id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATE_DATE'
                ,p_value    => to_char(p_last_update_date,'dd-mon-yyyy hh24:mi:ss')
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATED_BY'
                ,p_value    => p_last_updated_by
                ,p_parameter_list => l_parameter_list);

                 IF (p_creation_date IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATION_DATE'
                 ,p_value    => to_char(p_creation_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATED_BY'
                  ,p_value    => p_created_by
                  ,p_parameter_list => l_parameter_list);
                 END IF;

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END Raise_Bill_Event;

          -- Modified to add WHO columns
         PROCEDURE Raise_Bill_Event       --4306013
         ( p_Event_Load_Type IN VARCHAR2
          ,p_Request_Identifier IN  NUMBER
          ,p_Batch_Identifier IN NUMBER
          ,p_Event_Entity_Name IN  VARCHAR2
          ,p_Event_Name IN  VARCHAR2
          ,p_last_update_date IN DATE DEFAULT SYSDATE
          ,p_last_updated_by IN NUMBER DEFAULT NULL
          ,p_creation_date IN DATE DEFAULT SYSDATE
          ,p_created_by  IN NUMBER DEFAULT NULL
          ,p_last_update_login IN NUMBER DEFAULT NULL
          )
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         BEGIN
    Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'REQUEST_IDENTIFIER'
                ,p_value          =>   p_Request_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BATCH_IDENTIFIER'
                ,p_value          =>  p_Batch_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATE_DATE'
                ,p_value          =>  to_char(p_last_update_date,'dd-mon-yyyy hh24:mi:ss')
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATED_BY'
                ,p_value          =>  p_last_updated_by
                ,p_parameter_list => l_parameter_list);

                 IF (p_creation_date IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATION_DATE'
                 ,p_value    => to_char(p_creation_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATED_BY'
                  ,p_value    => p_created_by
                  ,p_parameter_list => l_parameter_list);
                 END IF;


                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END Raise_Bill_Event;


 -- Modified to add WHO columns
 PROCEDURE Raise_Bill_Event
         (  p_pk1_value IN VARCHAR2,
            p_pk2_value IN VARCHAR2,
            p_obj_name  IN VARCHAR2,
            p_structure_name IN VARCHAR2,
            p_organization_id IN NUMBER,
            p_structure_comment  IN VARCHAR2,
            p_Event_Load_Type IN VARCHAR2,
            p_Event_Entity_Name IN  VARCHAR2,
            p_Event_Entity_Parent_Id IN  NUMBER,
            p_Event_Name IN  VARCHAR2,
            p_last_update_date IN DATE DEFAULT SYSDATE,
            p_last_updated_by IN NUMBER DEFAULT NULL,
            p_creation_date IN DATE DEFAULT SYSDATE,
            p_created_by  IN NUMBER DEFAULT NULL,
            p_last_update_login IN NUMBER DEFAULT NULL,
            p_component_seq_id IN NUMBER DEFAULT NULL
            )

   IS
    l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
          l_common_bill_sequence_id NUMBER;
 BEGIN

 SELECT common_bill_sequence_id INTO l_common_bill_sequence_id
    FROM bom_structures_b
    WHERE bill_sequence_id =  p_Event_Entity_Parent_Id;

Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'COMMON_BILL_SEQUENCE_ID'
                 ,p_value          =>  l_common_bill_sequence_id
                 ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'OBJ_NAME'
                 ,p_value          =>  p_obj_name
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK1_VALUE'
                ,p_value          =>   p_pk1_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK2_VALUE'
                ,p_value          =>  p_pk2_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'STRUCTURE_NAME'
                ,p_value          =>  nvl(p_structure_name,'PRIMARY')
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'ORGANIZATION_ID'
                ,p_value    => p_organization_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'EVENT_ENTITY_PARENT_ID'
                  ,p_value    => p_Event_Entity_Parent_Id
                  ,p_parameter_list => l_parameter_list);

                 IF(p_component_seq_id IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'COMPONENT_SEQUENCE_ID'
                 ,p_value    => p_component_seq_id
                 ,p_parameter_list => l_parameter_list);
                 END IF;

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'LAST_UPDATE_DATE'
                 ,p_value    => to_char(p_last_update_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                  Bom_Business_Event_PKG.Add_Parameter_To_List
                  (p_parameter_name => 'LAST_UPDATED_BY'
                   ,p_value    => p_last_updated_by
                   ,p_parameter_list => l_parameter_list);

                 IF (p_creation_date IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATION_DATE'
                 ,p_value    => to_char(p_creation_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATED_BY'
                  ,p_value    => p_created_by
                  ,p_parameter_list => l_parameter_list);
                 END IF;

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END;

  /*  **************************************************************************************  */
   -- Added for bug 8462879
    PROCEDURE Raise_Bill_Event
            (  p_pk1_value IN VARCHAR2,
               p_pk2_value IN VARCHAR2,
               p_obj_name  IN VARCHAR2,
               p_structure_name IN VARCHAR2,
               p_organization_id IN NUMBER,
               p_structure_comment  IN VARCHAR2,
               p_Event_Load_Type IN VARCHAR2,
               p_Event_Entity_Name IN  VARCHAR2,
               p_Event_Entity_Parent_Id IN  NUMBER,
               p_Event_Name IN  VARCHAR2,
               p_last_update_date IN DATE DEFAULT SYSDATE,
               p_last_updated_by IN NUMBER DEFAULT NULL,
               p_creation_date IN DATE DEFAULT SYSDATE,
               p_created_by  IN NUMBER DEFAULT NULL,
               p_last_update_login IN NUMBER DEFAULT NULL,
               p_component_seq_id IN NUMBER DEFAULT NULL,
               p_return_status  OUT NOCOPY VARCHAR2, --Added for bug 8437166
               p_msg_data  OUT NOCOPY VARCHAR2  --Added for bug 8437166
               )

      IS
            l_message_list          ERROR_HANDLER.Error_Tbl_Type;
            BEGIN
            Raise_Bill_Event(p_pk1_value            =>        p_pk1_value
                            ,p_pk2_value            =>        p_pk2_value
                            ,p_obj_name             =>       p_obj_name
                            ,p_structure_name       =>  p_structure_name
                            ,p_organization_id      =>  p_organization_id
                            ,p_structure_comment    =>  p_structure_comment
                            ,p_Event_Load_Type      =>  p_Event_Load_Type
                            ,p_Event_Entity_Name    =>  p_Event_Entity_Name
                          ,p_Event_Entity_Parent_Id => p_Event_Entity_Parent_Id
                            ,p_Event_Name           =>  p_Event_Name
                            ,p_last_update_date     =>  p_last_update_date
                            ,p_last_updated_by      =>  p_last_updated_by
                            ,p_creation_date        =>  p_creation_date
                            ,p_created_by           =>  p_created_by
                            ,p_last_update_login    =>  p_last_update_login
                            ,p_component_seq_id     =>  p_component_seq_id
                            );

                   p_msg_data := NULL;
                   p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
         WHEN Bom_Business_Event_PKG.G_SUBSCRIPTION_EXC THEN
              p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ERROR_HANDLER.Get_Message_List(l_message_list);
              FOR i IN l_message_list.FIRST..l_message_list.LAST
              LOOP
              p_msg_data := p_msg_data || l_message_list(i).message_text;
              END LOOP;
  END;
   /*  **************************************************************************************  */


  PROCEDURE Raise_Component_Event     --4306013
         (p_Event_Load_Type IN VARCHAR2
    ,p_Request_Identifier IN  NUMBER
    ,p_Batch_Identifier IN NUMBER
    ,p_Event_Entity_Name IN  VARCHAR2
      ,p_Event_Entity_Parent_Id IN  NUMBER
          ,p_Event_Name IN  VARCHAR2)
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         BEGIN

    Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'REQUEST_IDENTIFIER'
                ,p_value          =>   p_Request_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BATCH_IDENTIFIER'
                ,p_value          =>  p_Batch_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

    Bom_Business_Event_PKG.Add_Parameter_To_List
    (p_parameter_name => 'EVENT_ENTITY_PARENT_ID'
    ,p_value    => p_Event_Entity_Parent_Id
    ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END Raise_Component_Event;


 -- Modified to add WHO columns
  PROCEDURE Raise_Component_Event     --4306013
         ( p_Event_Load_Type IN VARCHAR2
          ,p_Request_Identifier IN  NUMBER
          ,p_Batch_Identifier IN NUMBER
          ,p_Event_Entity_Name IN  VARCHAR2
          ,p_Event_Name IN  VARCHAR2
          ,p_last_update_date IN DATE DEFAULT SYSDATE
          ,p_last_updated_by IN NUMBER DEFAULT NULL
          ,p_creation_date IN DATE DEFAULT SYSDATE
          ,p_created_by  IN NUMBER DEFAULT NULL
          ,p_last_update_login IN NUMBER DEFAULT NULL
         )
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         BEGIN

                Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'REQUEST_IDENTIFIER'
                ,p_value          =>   p_Request_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BATCH_IDENTIFIER'
                ,p_value          =>  p_Batch_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATE_DATE'
                ,p_value          =>  to_char(p_last_update_date,'dd-mon-yyyy hh24:mi:ss')
                ,p_parameter_list => l_parameter_list);


                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'LAST_UPDATED_BY'
                ,p_value          =>  p_last_updated_by
                ,p_parameter_list => l_parameter_list);

                 IF (p_creation_date IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATION_DATE'
                 ,p_value    => to_char(p_creation_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATED_BY'
                  ,p_value    => p_created_by
                  ,p_parameter_list => l_parameter_list);
                 END IF;


                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END Raise_Component_Event;


/*  **************************************************************************************  */

         -- Modified to add WHO columns
         PROCEDURE Raise_Component_Event
         ( p_bill_sequence_Id IN  NUMBER,
           p_pk1_value IN VARCHAR2,
           p_pk2_value IN VARCHAR2,
           p_obj_name  IN VARCHAR2,
           p_organization_id IN NUMBER,
           p_comp_item_name IN VARCHAR2,
           p_comp_description in VARCHAR2,
           p_Event_Load_Type IN VARCHAR2,
           p_Event_Entity_Name IN  VARCHAR2,
           p_Event_Entity_Parent_Id IN  NUMBER,
           p_Event_Name IN  VARCHAR2,
           p_last_update_date IN DATE DEFAULT SYSDATE,
           p_last_updated_by IN NUMBER  DEFAULT NULL,
           p_creation_date IN DATE DEFAULT SYSDATE,
           p_created_by  IN NUMBER DEFAULT NULL,
           p_last_update_login IN NUMBER DEFAULT NULL
           )

    IS
           l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         BEGIN

                Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'OBJ_NAME'
                 ,p_value          =>  p_obj_name
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK1_VALUE'
                ,p_value          =>  p_pk1_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'PK2_VALUE'
                ,p_value          =>  p_pk2_value
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'BILL_SEQUENCE_ID'
                ,p_value          =>  p_bill_sequence_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'ORGANIZATION_ID'
                ,p_value          =>  p_organization_id
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'COMPONENT_ITEM_NAME'
                ,p_value          =>  p_comp_item_name
                ,p_parameter_list => l_parameter_list);

           /*  bug 5324805
	       Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'COMPONENT_ITEM_DESCRIPTION'
                ,p_value          =>  p_comp_description
                ,p_parameter_list => l_parameter_list);   */

               Bom_Business_Event_PKG.Add_Parameter_To_List
                ( p_parameter_name => 'EVENT_TYPE'
                 ,p_value          =>  p_Event_Load_Type
                 ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_NAME'
                ,p_value          =>  p_Event_Entity_Name
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'EVENT_ENTITY_PARENT_ID'
                ,p_value    => p_Event_Entity_Parent_Id
                ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'LAST_UPDATE_DATE'
                 ,p_value   => to_char(p_last_update_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'LAST_UPDATED_BY'
                  ,p_value    => p_last_updated_by
                  ,p_parameter_list => l_parameter_list);

                 IF (p_creation_date IS NOT NULL)
                 THEN
                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATION_DATE'
                 ,p_value    => to_char(p_creation_date,'dd-mon-yyyy hh24:mi:ss')
                 ,p_parameter_list => l_parameter_list);

                 Bom_Business_Event_PKG.Add_Parameter_To_List
                 (p_parameter_name => 'CREATED_BY'
                  ,p_value    => p_created_by
                  ,p_parameter_list => l_parameter_list);
                 END IF;


                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END;

/*  **************************************************************************************  */
 --Add for bug 9108842, out param for error msg handling
 PROCEDURE Raise_Component_Event
         ( p_bill_sequence_Id IN  NUMBER,
           p_pk1_value IN VARCHAR2,
           p_pk2_value IN VARCHAR2,
           p_obj_name  IN VARCHAR2,
           p_organization_id IN NUMBER,
           p_comp_item_name IN VARCHAR2,
           p_comp_description in VARCHAR2,
           p_Event_Load_Type IN VARCHAR2,
           p_Event_Entity_Name IN  VARCHAR2,
           p_Event_Entity_Parent_Id IN  NUMBER,
           p_Event_Name IN  VARCHAR2,
           p_last_update_date IN DATE DEFAULT SYSDATE,
           p_last_updated_by IN NUMBER  DEFAULT NULL,
           p_creation_date IN DATE DEFAULT SYSDATE,
           p_created_by  IN NUMBER DEFAULT NULL,
           p_last_update_login IN NUMBER DEFAULT NULL,
           p_return_status  OUT NOCOPY VARCHAR2, --Added for bug 9108842
           p_msg_data  OUT NOCOPY VARCHAR2  --Added for bug 9108842
          )
        IS
     		 l_message_list  	ERROR_HANDLER.Error_Tbl_Type;
         BEGIN
           Error_Handler.Initialize; --  Added for bug 9057182 to clear error msg cache before raising BE
	         Raise_Component_Event
		         ( p_bill_sequence_Id      			  				=>     p_bill_sequence_Id         ,
							p_pk1_value             								=>     p_pk1_value                ,
							p_pk2_value             								=>     p_pk2_value                ,
							p_obj_name              								=>     p_obj_name                 ,
							p_organization_id       								=>     p_organization_id          ,
							p_comp_item_name        								=>     p_comp_item_name           ,
							p_comp_description      								=>     p_comp_description         ,
							p_Event_Load_Type       								=>     p_Event_Load_Type          ,
							p_Event_Entity_Name     								=>     p_Event_Entity_Name        ,
							p_Event_Entity_Parent_Id								=>     p_Event_Entity_Parent_Id   ,
							p_Event_Name            								=>     p_Event_Name               ,
							p_last_update_date      								=>     p_last_update_date         ,
							p_last_updated_by       								=>     p_last_updated_by          ,
							p_creation_date         								=>     p_creation_date            ,
							p_created_by            								=>     p_created_by               ,
							p_last_update_login     								=>     p_last_update_login
		          );
						p_msg_data := NULL;
						p_return_status := 	FND_API.G_RET_STS_SUCCESS;

	       EXCEPTION
  			  WHEN Bom_Business_Event_PKG.G_SUBSCRIPTION_EXC THEN
  					p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				  	ERROR_HANDLER.Get_Message_List(l_message_list);
				    FOR i IN l_message_list.FIRST..l_message_list.LAST
				     LOOP
				      p_msg_data := p_msg_data || l_message_list(i).message_text;
				    END LOOP;
         END;
/*  **************************************************************************************  */

    PROCEDURE Raise_Bill_Event        --4306013
         (p_Request_Identifier IN  NUMBER
    ,p_Event_Name IN  VARCHAR2)
         IS
         l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
         BEGIN

                Bom_Business_Event_PKG.Add_Parameter_To_List
                (p_parameter_name => 'REQUEST_IDENTIFIER'
                ,p_value          =>   p_Request_Identifier
                ,p_parameter_list => l_parameter_list);

                Bom_Business_Event_PKG.Raise_event
                ( p_Event_Name     => p_Event_Name
                 ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
                 ,p_parameter_list => l_parameter_list);
         END Raise_Bill_Event;

     -- Bug 5244896
    PROCEDURE raise_str_cpy_complete_event
  ( p_copy_request_id IN NUMBER )
  IS
  l_parameter_list   wf_parameter_list_t := wf_parameter_list_t();
    BEGIN
      bom_business_event_pkg.add_parameter_to_list
      (p_parameter_name => 'COPY_REQUEST_ID'
      ,p_value          => p_copy_request_id
      ,p_parameter_list => l_parameter_list
    );
      bom_business_event_pkg.raise_event
      ( p_Event_Name     => G_STRUCTURE_CPY_COMPLETE_EVENT
       ,p_Event_Key      => to_char(systimestamp, 'dd-mon-yyyy hh24:mi:ss:ff')
       ,p_parameter_list => l_parameter_list
    );
  END raise_str_cpy_complete_event;

END Bom_Business_Event_PKG;

/
