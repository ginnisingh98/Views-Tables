--------------------------------------------------------
--  DDL for Package BOM_BUSINESS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BUSINESS_EVENT_PKG" AUTHID CURRENT_USER as
/* $Header: BOMSBESS.pls 120.4.12010000.5 2009/12/24 08:20:11 gliang ship $ */
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
| 01-Sept-2003  Rahul Chitko  Initial Creation          |
+==========================================================================*/

  /**
  ***  Item Events
  **/
  G_ITEM_DEL_SUCCESS_EVENT  CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.item.deleteSuccess';
  G_ITEM_DEL_ERROR_EVENT    CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.item.deleteError';
  G_ITEM_MARKED_DEL_EVENT   CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.item.itemMarkedForDelete';

  /**
        ***  Structure Events
        **/
  G_STRUCTURE_DEL_SUCCESS_EVENT CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.deleteSuccess';
  G_STRUCTURE_DEL_ERROR_EVENT CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.deleteError';
  G_STRUCTURE_MODIFIED_EVENT  CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.modified';
  G_STRUCTURE_CREATION_EVENT  CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.created';
  G_STRUCTURE_NEWREVISION_EVENT CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.revisionCreated';
        G_STRUCTURE_CPY_COMPLETE_EVENT  CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.structure.copy.complete';   -- 4306013

  /**
        ***  Components Events
        **/

  G_COMPONENT_DEL_SUCCESS_EVENT CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.component.deleteSuccess';
  G_COMPONENT_DEL_ERROR_EVENT CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.component.deleteError';
  G_COMPONENT_MODIFIED_EVENT  CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.component.modified';
  G_COMPONENT_ADDED_EVENT   CONSTANT    VARCHAR2(240) := 'oracle.apps.bom.component.created';
   /* Added for bug 8462879*/
  G_SUBSCRIPTION_EXC       EXCEPTION; --Subscription Exception defined
  PROCEDURE Raise_Event( p_Event_Name IN  VARCHAR2
           , p_Event_Key  IN  VARCHAR2
           , p_Parameter_List IN OUT NOCOPY  wf_parameter_list_t
           );

  PROCEDURE Add_Parameter_To_List( p_Parameter_Name IN  VARCHAR2
               , p_Value    IN  VARCHAR2
               , p_parameter_List IN OUT NOCOPY wf_parameter_list_t
               );

  /* Utility procedures */

  PROCEDURE Raise_Item_Event
  ( p_organization_id IN  NUMBER
   ,p_inventory_item_id IN  NUMBER
         ,p_item_name           IN  VARCHAR2
         ,p_item_description    IN VARCHAR2
   ,p_Event_Name    IN  VARCHAR2);


       PROCEDURE Raise_Bill_Event
       ( p_pk1_value IN VARCHAR2,
         p_pk2_value IN VARCHAR2,
         p_obj_name  IN VARCHAR2,
         p_structure_name IN VARCHAR2,
         p_organization_id IN NUMBER,
         p_structure_comment  IN VARCHAR2,
         p_Event_Name IN  VARCHAR2,
	 p_revised_item_sequence_id IN NUMBER DEFAULT NULL
	 --addeed for Bug8574333
	 );

       PROCEDURE Raise_Component_Event
       ( p_bill_sequence_Id IN  NUMBER,
         p_pk1_value IN VARCHAR2,
         p_pk2_value IN VARCHAR2,
         p_obj_name  IN VARCHAR2,
         p_organization_id IN NUMBER,
         p_comp_item_name IN VARCHAR2,
         p_comp_description in VARCHAR2,
         p_Event_Name IN  VARCHAR2
	);


   --4306013
   -- Modified for BE Changes
       PROCEDURE Raise_Bill_Event
       ( p_pk1_value IN VARCHAR2,
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
       );

       --Added for bug 8462879
         PROCEDURE Raise_Bill_Event
          ( p_pk1_value IN VARCHAR2,
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
            p_return_status  OUT NOCOPY VARCHAR2, --Added for bug 8462879
            p_msg_data  OUT NOCOPY VARCHAR2  --Added for bug 8462879
          );

-- Modified for BE Changes
   PROCEDURE Raise_Bill_Event     --4306013
         ( p_Event_Load_Type IN VARCHAR2
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
          );

-- Modified for BE Changes
   PROCEDURE Raise_Bill_Event     --4306013 for bulk operations -- component
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
          );

  PROCEDURE Raise_Component_Event     --4306013
         (p_Event_Load_Type IN VARCHAR2
         ,p_Request_Identifier IN  NUMBER
         ,p_Batch_Identifier IN NUMBER
         ,p_Event_Entity_Name IN  VARCHAR2
         ,p_Event_Entity_Parent_Id IN  NUMBER
         ,p_Event_Name IN  VARCHAR2);

-- Modified for BE Changes
  PROCEDURE Raise_Component_Event     --4306013  for bulk operations -- SC, RD, CO
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
          );

-- Modified for BE Changes
--4306013
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
         p_last_updated_by IN NUMBER DEFAULT NULL,
         p_creation_date IN DATE DEFAULT SYSDATE,
         p_created_by  IN NUMBER DEFAULT NULL,
         p_last_update_login IN NUMBER DEFAULT NULL
         );
   --Add for bug 9108842
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
         p_last_updated_by IN NUMBER DEFAULT NULL,
         p_creation_date IN DATE DEFAULT SYSDATE,
         p_created_by  IN NUMBER DEFAULT NULL,
         p_last_update_login IN NUMBER DEFAULT NULL,
         p_return_status  OUT NOCOPY VARCHAR2, --Added for bug 9108842
         p_msg_data  OUT NOCOPY VARCHAR2  --Added for bug 9108842
         );
    --4306013
      PROCEDURE Raise_Bill_Event
      (p_Request_Identifier IN  NUMBER
       ,p_Event_Name IN  VARCHAR2);

     -- Bug 5244896
     PROCEDURE raise_str_cpy_complete_event
   (p_copy_request_id IN NUMBER);

END Bom_Business_Event_PKG;

/
