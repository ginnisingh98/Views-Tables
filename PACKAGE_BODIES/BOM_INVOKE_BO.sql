--------------------------------------------------------
--  DDL for Package Body BOM_INVOKE_BO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_INVOKE_BO" AS
/* $Header: BOMBIVKB.pls 115.6 2003/03/14 07:23:18 vhymavat ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBIVKB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Invoke_BO
--
--  NOTES
--
--  HISTORY
--
--  09-MAR-01	Refai Farook	   Initial Creation
--  16-MAR-01   Masanori Kimizuka  Added wrapper procedures for Error_Handlers
--                                 and FND_GLOBALS.Apps_Initialize
***************************************************************************/

PROCEDURE Process_Bom
        (  p_bo_identifier           IN  VARCHAR2 := 'BOM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
         , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
         , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
         , p_bom_ref_designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_type :=
                                         Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
         , p_bom_sub_component_tbl   IN Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
         , x_bom_header_rec          OUT NOCOPY Bom_Bo_Pub.bom_Head_Rec_Type
         , x_bom_revision_tbl        OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , x_bom_component_tbl       OUT NOCOPY Bom_Bo_pub.Bom_Comps_Tbl_Type
         , x_bom_ref_designator_tbl  OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , x_bom_sub_component_tbl   OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         , p_debug                   IN  VARCHAR2 := 'N'
         , p_output_dir              IN  VARCHAR2 := NULL
         , p_debug_filename          IN  VARCHAR2 := 'BOM_BO_debug.log'
         ) IS
BEGIN
    Bom_Bo_Pub.Process_Bom
        (  p_bo_identifier           => p_bo_identifier
         , p_api_version_number      => p_api_version_number
         , p_init_msg_list           => p_init_msg_list
         , p_bom_header_rec          => p_bom_header_rec
         , p_bom_revision_tbl        => p_bom_revision_tbl
         , p_bom_component_tbl       => p_bom_component_tbl
         , p_bom_ref_designator_tbl  => p_bom_ref_designator_tbl
         , p_bom_sub_component_tbl   => p_bom_sub_component_tbl
         , x_bom_header_rec          => x_bom_header_rec
         , x_bom_revision_tbl        => x_bom_revision_tbl
         , x_bom_component_tbl       => x_bom_component_tbl
         , x_bom_ref_designator_tbl  => x_bom_ref_designator_tbl
         , x_bom_sub_component_tbl   => x_bom_sub_component_tbl
         , x_return_status           => x_return_status
         , x_msg_count               => x_msg_count
         , p_debug                   => p_debug
         , p_output_dir              => p_output_dir
         , p_debug_filename          => p_debug_filename
         );
END Process_Bom ;

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
   , x_message_text   OUT NOCOPY VARCHAR2
   )
IS
BEGIN

   x_message_text   := 'This method is no longer supported. Messages returned from this call could be more than one. Please use the other method which returns a list of messages';

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
PROCEDURE Export_BOM(P_org_hierarchy_name        IN   VARCHAR2 DEFAULT NULL,
                     P_assembly_item_name        IN   VARCHAR2,
                     P_organization_code         IN   VARCHAR2,
                     P_alternate_bm_designator   IN   VARCHAR2 DEFAULT NULL,
                     P_Costs                     IN   NUMBER DEFAULT 2,
                     P_Cost_type_id            IN   NUMBER DEFAULT 0,
                     X_bom_header_tbl          OUT  NOCOPY BOM_BO_PUB.BOM_HEADER_TBL_TYPE,
                     X_bom_revisions_tbl       OUT  NOCOPY BOM_BO_PUB.BOM_REVISION_TBL_TYPE,
                     X_bom_components_tbl      OUT  NOCOPY BOM_BO_PUB.BOM_COMPS_TBL_TYPE,
                     X_bom_ref_designators_tbl OUT  NOCOPY BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE,
                     X_bom_sub_components_tbl  OUT  NOCOPY BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE,
                     X_bom_comp_ops_tbl        OUT  NOCOPY BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE,
                     X_Err_Msg                 OUT  NOCOPY VARCHAR2,
                     X_Error_Code              OUT  NOCOPY NUMBER)
IS
Begin
 BOMPXINQ.Export_BOM(P_org_hierarchy_name        =>  P_org_hierarchy_name ,
                     P_assembly_item_name        => P_assembly_item_name ,
                     P_organization_code         =>  P_organization_code,
                     P_alternate_bm_designator   =>   P_alternate_bm_designator ,
                     P_Costs                     =>  P_Costs     ,
                     P_Cost_type_id            => P_Cost_type_id    ,
                     X_bom_header_tbl          =>  X_bom_header_tbl   ,
                     X_bom_revisions_tbl       => X_bom_revisions_tbl  ,
                     X_bom_components_tbl      =>  X_bom_components_tbl    ,
                     X_bom_ref_designators_tbl => X_bom_ref_designators_tbl ,
                     X_bom_sub_components_tbl  => X_bom_sub_components_tbl ,
                     X_bom_comp_ops_tbl        => X_bom_comp_ops_tbl  ,
                     X_Err_Msg                 =>  X_Err_Msg ,
                     X_Error_Code              =>  X_Error_Code  );

End Export_Bom;
END Bom_Invoke_Bo;

/
