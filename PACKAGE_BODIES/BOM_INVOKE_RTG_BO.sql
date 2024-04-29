--------------------------------------------------------
--  DDL for Package Body BOM_INVOKE_RTG_BO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_INVOKE_RTG_BO" AS
/* $Header: BOMRIVKB.pls 120.1 2005/06/21 02:59:43 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRIVKB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Invoke_Rtg_Bo
--
--  NOTES
--
--  HISTORY
--
--  12-MAR-01	Masanori Kimizuka Initial Creation
--
***************************************************************************/

-- Invoker for Bom_Rtg_Pub.Process_Rtg
PROCEDURE Process_Rtg
   ( p_bo_identifier           IN  VARCHAR2 := 'RTG'
   , p_api_version_number      IN  NUMBER := 1.0
   , p_init_msg_list           IN  BOOLEAN := FALSE
   , p_rtg_header_rec          IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC
   , p_rtg_revision_tbl        IN  Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
                                        :=Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL
   , p_operation_tbl           IN  Bom_Rtg_Pub.Operation_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OPERATION_TBL
   , p_op_resource_tbl         IN  Bom_Rtg_Pub.Op_Resource_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL
   , p_sub_resource_tbl        IN  Bom_Rtg_Pub.Sub_Resource_Tbl_Type
                                       :=  Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL
   , p_op_network_tbl          IN  Bom_Rtg_Pub.Op_Network_Tbl_Type
                                        :=  Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL
   , x_rtg_header_rec          IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Rec_Type
   , x_rtg_revision_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Revision_Tbl_Type
   , x_operation_tbl           IN OUT NOCOPY Bom_Rtg_Pub.Operation_Tbl_Type
   , x_op_resource_tbl         IN OUT NOCOPY Bom_Rtg_Pub.Op_Resource_Tbl_Type
   , x_sub_resource_tbl        IN OUT NOCOPY Bom_Rtg_Pub.Sub_Resource_Tbl_Type
   , x_op_network_tbl          IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Tbl_Type
   , x_return_status           IN OUT NOCOPY VARCHAR2
   , x_msg_count               IN OUT NOCOPY NUMBER
   , p_debug                   IN  VARCHAR2 := 'N'
   , p_output_dir              IN  VARCHAR2 := NULL
   , p_debug_filename          IN  VARCHAR2 := 'RTG_BO_debug.log'
   )
IS

BEGIN


   Bom_Rtg_Pub.Process_Rtg
   ( p_bo_identifier           => p_bo_identifier
   , p_api_version_number      => p_api_version_number
   , p_init_msg_list           => p_init_msg_list
   , p_rtg_header_rec          => p_rtg_header_rec
   , p_rtg_revision_tbl        => p_rtg_revision_tbl
   , p_operation_tbl           => p_operation_tbl
   , p_op_resource_tbl         => p_op_resource_tbl
   , p_sub_resource_tbl        => p_sub_resource_tbl
   , p_op_network_tbl          => p_op_network_tbl
   , x_rtg_header_rec          => x_rtg_header_rec
   , x_rtg_revision_tbl        => x_rtg_revision_tbl
   , x_operation_tbl           => x_operation_tbl
   , x_op_resource_tbl         => x_op_resource_tbl
   , x_sub_resource_tbl        => x_sub_resource_tbl
   , x_op_network_tbl          => x_op_network_tbl
   , x_return_status           => x_return_status
   , x_msg_count               => x_msg_count
   , p_debug                   => p_debug
   , p_output_dir              => p_output_dir
   , p_debug_filename          => p_debug_filename
   ) ;


END Process_Rtg ;


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
   ( x_message_list    IN OUT NOCOPY Error_Handler.Error_Tbl_Type)
IS
BEGIN

   Error_Handler.Get_Message_List
   ( x_message_list    => x_message_list ) ;

END Get_Message_List ;

PROCEDURE Get_Entity_Message
   ( p_entity_id      IN  VARCHAR2
   , x_message_list   IN OUT NOCOPY Error_Handler.Error_Tbl_Type
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
   , x_message_text   IN OUT NOCOPY VARCHAR2
   )
IS
BEGIN

   Error_Handler.Get_Entity_Message
   ( p_entity_id      => p_entity_id
   , p_entity_index   => p_entity_index
   , x_message_text   => x_message_text
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
   ( x_message_text   IN OUT NOCOPY VARCHAR2
   , x_entity_index   IN OUT NOCOPY NUMBER
   , x_entity_id      IN OUT NOCOPY VARCHAR2
   , x_message_type   IN OUT NOCOPY VARCHAR2
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


END Bom_Invoke_Rtg_Bo;

/
