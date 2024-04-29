--------------------------------------------------------
--  DDL for Package BOM_RTG_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_VAL_TO_ID" AUTHID CURRENT_USER AS
/* $Header: BOMRVIDS.pls 115.3 2002/11/21 06:02:48 djebar ship $*/
/****************************************************************************
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  FILENAME BOMRVIDS.pls
--
--
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_Val_To_Id
--
--  NOTES
--
--  HISTORY
--
--  07-AUG-00   Biao Zhang          Initial Creation
--  07-SEP-00   Masanori Kimizuka   Modified to support ECO for Routing
--
****************************************************************************/


FUNCTION Organization
        (  p_organization IN VARCHAR2
         , x_err_text     IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;

FUNCTION Assembly_Item
        (  p_assembly_item_name IN VARCHAR2
         , p_organization_id    IN NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;


FUNCTION Common_Assembly_Item_Id
         ( p_organization_id           IN NUMBER
         , p_common_assembly_item_name IN VARCHAR2
         , x_err_text                  IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;

FUNCTION Routing_Sequence_id
        (  p_assembly_item_id             IN  NUMBER
         , p_organization_id              IN  NUMBER
         , p_alternate_routing_designator IN  VARCHAR2
         , x_err_text                     IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;

FUNCTION Common_Routing_Sequence_id
        (  p_common_assembly_item_id      IN NUMBER
         , p_organization_id              IN NUMBER
         , p_alternate_routing_designator IN VARCHAR2
         , x_err_text                     IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;

FUNCTION Completion_locator_id
        (  p_completion_location_name     IN VARCHAR2
         , p_organization_id              IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2)
        RETURN NUMBER;

FUNCTION Line_Id
        (  p_line_code                    IN VARCHAR2
         , p_organization_id              IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Standard_Operation_Id
        (  p_operation_type               IN NUMBER
         , p_standard_operation_code      IN VARCHAR2
         , p_organization_id              IN NUMBER
         , p_routing_sequence_id          IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Department_Id
        (  p_department_code              IN VARCHAR2
         , p_organization_id              IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Process_Op_Seq_Id
        (  p_process_code       IN  VARCHAR2
         , p_organization_id    IN  NUMBER
         , p_process_seq_number IN  NUMBER
         , p_routing_sequence_id IN  NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Line_Op_Seq_Id
         (  p_line_code       IN  VARCHAR2
         , p_organization_id    IN  NUMBER
         , p_line_seq_number IN  NUMBER
         , p_routing_sequence_id IN  NUMBER
         , x_err_text           IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Activity_Id
        (  p_activity                     IN VARCHAR2
         , p_organization_id              IN NUMBER
         , x_err_text                     IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

--confirm
FUNCTION Resource_Id
        (  p_resource_code   IN VARCHAR2
         , p_organization_id IN NUMBER
         , x_err_text        IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;

FUNCTION Operation_Sequence_Id
        (  p_routing_sequence_id   IN NUMBER
         , p_operation_type   IN NUMBER
         , p_operation_seq_num IN NUMBER
         , p_effectivity_date  IN date
         , x_err_text        IN OUT NOCOPY VARCHAR2
        ) RETURN NUMBER;



/***************************************************************************
*
* ROUTING HEADER ENTITY
*
*****************************************************************************/

-- Convert Routing header User Unique Index to Unique Index
PROCEDURE Rtg_Header_UUI_To_UI
        (  p_rtg_header_rec       IN   Bom_Rtg_Pub.Rtg_header_rec_type
         , p_rtg_header_unexp_rec IN   Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_unexp_rec IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
-- Convert header value to ID
PROCEDURE Rtg_Header_VID
        (  p_rtg_header_Rec      IN  Bom_Rtg_Pub.Rtg_Header_Rec_Type
         , p_rtg_header_unexp_rec  IN  Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_rtg_header_unexp_rec  IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Header_Unexposed_Rec_Type
         , x_Return_Status       IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


/***************************************************************************
*
* ROUTING REVISIONS ENTITY
*
*****************************************************************************/

-- Convert Routing revision User Unique Index to Unique Index
PROCEDURE Rtg_revision_UUI_To_UI
        (  p_rtg_revision_rec     IN   Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_rtg_rev_unexp_rec    IN   Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_rev_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_return_status        IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
/*
-- Convert routing revision record value to ID
PROCEDURE Rtg_revision_VID
        (  p_operation_rec        IN  Bom_Rtg_Pub.Rtg_Revision_Rec_Type
         , p_operation_unexp_rec  IN  Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_rtg_head_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Rtg_Rev_Unexposed_Rec_Type
         , x_Return_Status        IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl       IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
*/



/***************************************************************************
*
* OPERATION SEQUENCES ENTITY
*
*****************************************************************************/


-- Convert operation User Unique Index to Unique Index
-- Called by the Routing Business Object
PROCEDURE Operation_UUI_To_UI
        (  p_operation_rec       IN   Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec        IN   Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );


-- Convert revised operation User Unique Index to Unique Index
-- Called by the ECO Business Object
PROCEDURE Rev_Operation_UUI_To_UI
        (  p_rev_operation_rec       IN   Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec        IN   Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_rev_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );


-- Convert common operation User Unique Index to Unique Index
-- Internally called by the ECO and Routing Business Object
PROCEDURE Com_Operation_UUI_To_UI
        (  p_com_operation_rec       IN   Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec        IN   Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );


-- Convert operation value to ID
-- Called by the Routing Business Object
PROCEDURE Operation_VID
        (  p_operation_rec       IN  Bom_Rtg_Pub.Operation_Rec_Type
         , p_op_unexp_rec        IN  Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Op_Unexposed_Rec_Type
         , x_Return_Status       IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );

-- Convert revised operation value to ID
-- Called by the ECO Business Object
PROCEDURE Rev_Operation_VID
        (  p_rev_operation_rec       IN  Bom_Rtg_Pub.Rev_Operation_Rec_Type
         , p_rev_op_unexp_rec        IN  Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_rev_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Unexposed_Rec_Type
         , x_Return_Status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


-- Convert common operation value to ID
-- Internally called by the ECO and Routing Business Object
PROCEDURE Com_Operation_VID
        (  p_com_operation_rec       IN  Bom_Rtg_Pub.Com_Operation_Rec_Type
         , p_com_op_unexp_rec        IN  Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_com_op_unexp_rec        IN OUT NOCOPY Bom_Rtg_Pub.Com_Op_Unexposed_Rec_Type
         , x_Return_Status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


/***************************************************************************
*
* OPERATION RESOURCES ENTITY
*
*****************************************************************************/


-- Convert operation resource User Unique Index to Unique Index
-- Called by the Routing Business Object
PROCEDURE Op_resource_UUI_To_UI
        (  p_op_resource_rec     IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec    IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );

/*
-- Convert operation User Unique Index to Unique Index in resource record
PROCEDURE Op_resource_UUI_To_UI2
        (  p_op_resource_rec     IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec    IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_op_res_unexp_rec    IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_return_status       IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
*/

-- Convert operation  resource value to ID
-- Called by the Routing Business Object
PROCEDURE Op_resource_VID
        (  p_op_resource_rec     IN  Bom_Rtg_Pub.Op_Resource_Rec_Type
         , p_op_res_unexp_rec    IN  Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Op_Res_Unexposed_Rec_Type
         , x_Return_Status       IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl      IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );



-- Convert revised operation resource User Unique Index to Unique Index
-- Called by the ECO Business Object
PROCEDURE Rev_Op_resource_UUI_To_UI
        (  p_rev_op_resource_rec     IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_rev_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_return_status           IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );


-- Convert revised operation  resource value to ID
-- Called by the ECO Business Object
PROCEDURE Rev_Op_resource_VID
        (  p_rev_op_resource_rec     IN  Bom_Rtg_Pub.Rev_Op_Resource_Rec_Type
         , p_rev_op_res_unexp_rec    IN  Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_rev_op_res_unexp_rec    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Res_Unexposed_Rec_Type
         , x_Return_Status           IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl          IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


/***************************************************************************
*
* SUBSTITUTE OPERATION RESOURCES ENTITY
*
*****************************************************************************/

-- Convert operation sub resource User Unique Index to Unique Index
-- Called by the Routing Business Object
PROCEDURE Sub_Resource_UUI_To_UI
        (  p_sub_resource_rec       IN   Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec      IN   Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_return_status          IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         );

-- Convert operation sub resource value to ID
-- Called by the Routing Business Object
PROCEDURE Sub_Resource_VID
        (  p_sub_resource_rec       IN  Bom_Rtg_Pub.Sub_Resource_Rec_Type
         , p_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Sub_Res_Unexposed_Rec_Type
         , x_Return_Status          IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


-- Convert revised operation sub resource User Unique Index to Unique Index
-- Called by the ECO Business Object
PROCEDURE Rev_Sub_Resource_UUI_To_UI
        (  p_rev_sub_resource_rec       IN   Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec      IN   Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_rev_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_return_status              IN OUT NOCOPY VARCHAR2
         , x_mesg_token_tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );

-- Convert revised operation sub resource value to ID
-- Called by the ECO Business Object
PROCEDURE Rev_Sub_Resource_VID
        (  p_rev_sub_resource_rec       IN  Bom_Rtg_Pub.Rev_Sub_Resource_Rec_Type
         , p_rev_sub_res_unexp_rec      IN  Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_rev_sub_res_unexp_rec      IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Res_Unexposed_Rec_Type
         , x_Return_Status              IN OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );


/***************************************************************************
*
* OPERATION NETWORK ENTITY
*
*****************************************************************************/

-- Convert operation network User Unique Index to Unique Index
PROCEDURE OP_network_UUI_To_UI
        ( p_op_Network_Rec         IN   Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_op_Network_unexp_rec   IN   Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_op_Network_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_return_status          IN OUT NOCOPY VARCHAR2
        , x_mesg_token_tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
/*
-- Convert operation network value to ID
PROCEDURE OP_network_VID
        ( p_op_Network_Rec         IN   Bom_Rtg_Pub.Op_Network_Rec_Type
        , p_op_Network_unexp_rec   IN   Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_op_Network_unexp_rec   IN OUT NOCOPY Bom_Rtg_Pub.Op_Network_Unexposed_Rec_Type
        , x_Return_Status          IN OUT NOCOPY VARCHAR2
        , x_Mesg_Token_Tbl         IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        );
*/

END BOM_Rtg_Val_To_Id;

 

/
