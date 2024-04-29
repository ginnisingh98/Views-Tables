--------------------------------------------------------
--  DDL for Package Body ENG_INVOKE_ECO_BO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_INVOKE_ECO_BO" AS
/* $Header: ENGBIVKB.pls 115.6 2003/04/08 21:15:02 mxgovind ship $ */



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
     ,   x_change_line_tbl          OUT NOCOPY ENG_Eco_PUB.Change_Line_Tbl_Type
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
   )

IS

BEGIN
       ENG_Eco_PUB.Process_ECO
       (   p_api_version_number        =>  p_api_version_number
       ,   p_init_msg_list             =>  p_init_msg_list
       ,   x_return_status             =>  x_return_status
       ,   x_msg_count                 =>  x_msg_count
       ,   p_bo_identifier             =>  p_bo_identifier
       ,   p_ECO_rec                   =>  p_ECO_rec
       ,   p_eco_revision_tbl          =>  p_eco_revision_tbl
       ,   p_change_line_tbl           =>  p_change_line_tbl
       ,   p_revised_item_tbl          =>  p_revised_item_tbl
       ,   p_rev_component_tbl         =>  p_rev_component_tbl
       ,   p_ref_designator_tbl        =>  p_ref_designator_tbl
       ,   p_sub_component_tbl         =>  p_sub_component_tbl
       ,   p_rev_operation_tbl         =>  p_rev_operation_tbl
       ,   p_rev_op_resource_tbl       =>  p_rev_op_resource_tbl
       ,   p_rev_sub_resource_tbl      =>  p_rev_sub_resource_tbl
       ,   x_ECO_rec                   =>  x_ECO_rec
       ,   x_eco_revision_tbl          =>  x_eco_revision_tbl
       ,   x_change_line_tbl          =>  x_change_line_tbl
       ,   x_revised_item_tbl          =>  x_revised_item_tbl
       ,   x_rev_component_tbl         =>  x_rev_component_tbl
       ,   x_ref_designator_tbl        =>  x_ref_designator_tbl
       ,   x_sub_component_tbl         =>  x_sub_component_tbl
       ,   x_rev_operation_tbl         =>  x_rev_operation_tbl
       ,   x_rev_op_resource_tbl       =>  x_rev_op_resource_tbl
       ,   x_rev_sub_resource_tbl      =>  x_rev_sub_resource_tbl
       ,   p_debug                     =>  p_debug
       ,   p_output_dir                =>  p_output_dir
       ,   p_debug_filename            =>  p_debug_filename
      );

END Process_Eco ;

 -- Invoker for Error_Handler procedures/functions
PROCEDURE Initialize
IS
BEGIN

   Error_Handler.Initialize ;

END Initialize ;

PROCEDURE Reset
IS
BEGIN
   Error_Handler.Reset ;

END Reset ;

PROCEDURE Get_Message_List
   ( x_message_list    OUT NOCOPY Error_Handler.Error_Tbl_Type)
IS
BEGIN

   Error_Handler.Get_Message_List
   ( x_message_list    => x_message_list ) ;

END Get_Message_List ;

PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , x_message_list   OUT NOCOPY Error_Handler.Error_Tbl_Type
   )
IS
BEGIN

   Error_Handler.Get_Entity_Message
   ( p_entity_id      => p_entity_id
   , x_message_list   => x_message_list
   ) ;

END Get_Entity_Message ;

PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , p_entity_index   IN  NUMBER
   , x_message_list   OUT NOCOPY Error_Handler.Error_Tbl_Type
   )
IS
BEGIN

   Error_Handler.Get_Entity_Message
   ( p_entity_id      => p_entity_id
   , p_entity_index   => p_entity_index
   , x_message_list   => x_message_list
   ) ;

END Get_Entity_Message ;


PROCEDURE Delete_Message
   ( p_entity_id          IN  VARCHAR2
   , p_entity_index       IN  NUMBER
   )
IS
BEGIN

   Error_Handler.Delete_Message
   ( p_entity_id      => p_entity_id
   , p_entity_index   => p_entity_index
   );

END Delete_Message ;
PROCEDURE Delete_Message
   (  p_entity_id          IN  VARCHAR2 )
IS
BEGIN

   Error_Handler.Delete_Message
   ( p_entity_id      => p_entity_id ) ;

END Delete_Message ;

PROCEDURE Get_Message
   ( x_message_text   OUT NOCOPY VARCHAR2
   , x_entity_index   OUT NOCOPY NUMBER
   , x_entity_id      OUT NOCOPY VARCHAR2
   , x_message_type   OUT NOCOPY VARCHAR2
   )
IS
BEGIN

   Error_Handler.Get_Message
   ( x_message_text   => x_message_text
   , x_entity_index   => x_entity_index
   , x_entity_id      => x_entity_id
   , x_message_type   => x_message_type
   ) ;


END Get_Message ;
FUNCTION Get_Message_Count RETURN NUMBER
IS
BEGIN

   RETURN Error_Handler.Get_Message_Count ;

END Get_Message_Count ;

PROCEDURE Dump_Message_List
IS
BEGIN

   Error_Handler.Dump_Message_List ;

END Dump_Message_List ;

-- Invoker for FND_GLOBAL.APPS_INITIALIZE
PROCEDURE Apps_Initialize
   ( user_id           IN NUMBER
    ,resp_id           IN NUMBER
    ,resp_appl_id      IN NUMBER
    ,security_group_id IN NUMBER  default 0
   )
IS
BEGIN

   FND_GLOBAL.Apps_Initialize
   ( user_id           => user_id
    ,resp_id           => resp_id
    ,resp_appl_id      => resp_appl_id
    ,security_group_id => security_group_id
   ) ;

END Apps_Initialize  ;

END  ENG_Invoke_ECO_Bo;

/
