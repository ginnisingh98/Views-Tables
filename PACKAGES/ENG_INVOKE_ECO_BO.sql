--------------------------------------------------------
--  DDL for Package ENG_INVOKE_ECO_BO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_INVOKE_ECO_BO" AUTHID DEFINER AS
/* $Header: ENGBIVKS.pls 115.5 2003/04/08 21:14:05 mxgovind ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      ENGBIVKS.pls
--
--  DESCRIPTION
--
--      Spec of package ENG_Invoke_ECO_Bo
--
--  NOTES
--
--  HISTORY
--
--  09-MAR-01	Biao Zhang Initial Creation
--
***************************************************************************/
    PROCEDURE Process_Eco
        (   p_api_version_number        IN  NUMBER  := 1.0
     ,   p_init_msg_list             IN  BOOLEAN := FALSE
     ,   x_return_status             OUT NOCOPY VARCHAR2
     ,   x_msg_count                 OUT NOCOPY NUMBER
     ,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
     ,   p_ECO_rec                   IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                            ENG_Eco_PUB.G_MISS_ECO_REC
     ,   p_eco_revision_tbl          IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
     ,   p_change_line_tbl          IN  ENG_Eco_PUB.Change_Line_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_CHANGE_LINE_TBL
     ,   p_revised_item_tbl          IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
     ,   p_rev_component_tbl         IN  Bom_Bo_Pub.Rev_Component_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_REV_COMPONENT_TBL
     ,   p_ref_designator_tbl        IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_REF_DESIGNATOR_TBL
     ,   p_sub_component_tbl         IN  Bom_Bo_Pub.Sub_Component_Tbl_Type :=
                                            ENG_Eco_PUB.G_MISS_SUB_COMPONENT_TBL
     ,   p_rev_operation_tbl         IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type:=
                                            Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
     ,   p_rev_op_resource_tbl       IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type:=
                                            Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL
     ,   p_rev_sub_resource_tbl      IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type:=
                                            Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL
     ,   x_ECO_rec                   OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
     ,   x_eco_revision_tbl          OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
     ,   x_change_line_tbl           OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type
     ,   x_revised_item_tbl          OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
     ,   x_rev_component_tbl         OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
     ,   x_ref_designator_tbl        OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
     ,   x_sub_component_tbl         OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
     ,   x_rev_operation_tbl         OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
     ,   x_rev_op_resource_tbl       OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
     ,   x_rev_sub_resource_tbl      OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
     ,   p_debug                     IN  VARCHAR2 := 'N'
     ,   p_output_dir                IN  VARCHAR2 := NULL
     ,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
         );
  -- Invoker for Error_Handler procedures/functions
   PROCEDURE Initialize;

   PROCEDURE Reset;

   PROCEDURE Get_Message_List
   ( x_message_list    OUT NOCOPY Error_Handler.Error_Tbl_Type);

   PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , x_message_list   OUT NOCOPY Error_Handler.Error_Tbl_Type
   );

   PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , p_entity_index   IN  NUMBER
   , x_message_list   OUT NOCOPY Error_Handler.Error_Tbl_Type
   );

   PROCEDURE Delete_Message
   ( p_entity_id          IN  VARCHAR2
   , p_entity_index       IN  NUMBER
   );

   PROCEDURE Delete_Message
   (  p_entity_id          IN  VARCHAR2 );

    PROCEDURE Get_Message
   ( x_message_text   OUT NOCOPY VARCHAR2
   , x_entity_index   OUT NOCOPY NUMBER
   , x_entity_id      OUT NOCOPY VARCHAR2
   , x_message_type   OUT NOCOPY VARCHAR2
   );

   FUNCTION Get_Message_Count RETURN NUMBER;

   PROCEDURE Dump_Message_List;


   -- Invoker for FND_GLOBAL.APPS_INITIALIZE
   PROCEDURE Apps_Initialize
   ( user_id           IN NUMBER
    ,resp_id           IN NUMBER
    ,resp_appl_id      IN NUMBER
    ,security_group_id IN NUMBER  default 0
   ) ;

END ENG_Invoke_ECO_Bo;


 

/
