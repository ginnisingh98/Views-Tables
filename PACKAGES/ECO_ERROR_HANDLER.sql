--------------------------------------------------------
--  DDL for Package ECO_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECO_ERROR_HANDLER" AUTHID CURRENT_USER AS
/* $Header: ENGBOEHS.pls 120.1 2005/07/04 00:42:06 lkasturi noship $ */
        G_PKG_NAME              CONSTANT VARCHAR2(30)   := 'Error_Handler';
        G_BO_LEVEL              CONSTANT NUMBER         := 0;
        G_ECO_LEVEL             CONSTANT NUMBER         := 1;
        G_REV_LEVEL             CONSTANT NUMBER         := 2;
        G_RI_LEVEL              CONSTANT NUMBER         := 3;
        G_RC_LEVEL              CONSTANT NUMBER         := 4;
        G_RD_LEVEL              CONSTANT NUMBER         := 5;
        G_SC_LEVEL              CONSTANT NUMBER         := 6;


        /*******************************************************
        -- Followings are for Routing BO
        ********************************************************/
        -- G_RTG_LEVEL     CONSTANT NUMBER         := 8;
        G_OP_LEVEL      CONSTANT NUMBER         := 9;
        G_RES_LEVEL     CONSTANT NUMBER         := 10;
        G_SR_LEVEL      CONSTANT NUMBER         := 11;
        -- G_NWK_LEVEL     CONSTANT NUMBER         := 12;
        -- Added by MK on 08/23/2000

        G_CL_LEVEL              CONSTANT NUMBER         := 21;
        -- Added by MK on 08/13/2002

        G_ATCH_LEVEL              CONSTANT NUMBER         := 22;

        G_STATUS_WARNING        CONSTANT VARCHAR2(1)    := 'W';
        G_STATUS_UNEXPECTED     CONSTANT VARCHAR2(1)    := 'U';
        G_STATUS_ERROR          CONSTANT VARCHAR2(1)    := 'E';
        G_STATUS_FATAL          CONSTANT VARCHAR2(1)    := 'F';
        G_STATUS_NOT_PICKED     CONSTANT VARCHAR2(1)    := 'N';

        G_SCOPE_ALL             CONSTANT VARCHAR2(1)    := 'A';
        G_SCOPE_RECORD          CONSTANT VARCHAR2(1)    := 'R';
        G_SCOPE_SIBLINGS        CONSTANT VARCHAR2(1)    := 'S';
        G_SCOPE_CHILDREN        CONSTANT VARCHAR2(1)    := 'C';


/* Comment out by MK on 08/23/2000 ********************************************

        PROCEDURE Log_Error
        (  p_eco_rec            IN  ENG_Eco_Pub.Eco_Rec_Type :=
                                               Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl   IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                    := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_revised_item_tbl   IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                    := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL
         , p_rev_component_tbl  IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl  IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
                                    := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status       IN  VARCHAR2
         , p_error_scope        IN  VARCHAR2 := NULL
         , p_other_message      IN  VARCHAR2 := NULL
         , p_other_status       IN  VARCHAR2 := NULL
         , p_other_token_tbl    IN  Error_Handler.Token_Tbl_Type
                                          := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level        IN  NUMBER
         , p_entity_index       IN  NUMBER := NULL
         , x_eco_rec            OUT NOCOPY ENG_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl   OUT NOCOPY Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_revised_item_tbl   OUT NOCOPY Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl  OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl  OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
         );
*******************************************************************************/



        /*******************************************************
        -- Log_Error prodedure used for ECO Routing enhancement
        --
        -- Added rev op, rev op res and rev sub res error handling
        -- to existed Log_Error procedure
        --
        -- Modified by MK on 08/23/2000
        ********************************************************/
        PROCEDURE Log_Error
        (  p_eco_rec            IN  ENG_Eco_Pub.Eco_Rec_Type :=
                                               Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl   IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                    := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_revised_item_tbl   IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                    := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL

         -- Followings are for Routing BO
         , p_rev_operation_tbl    IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
         , p_rev_op_resource_tbl  IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL
         , p_rev_sub_resource_tbl IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL
         -- Added by MK on 08/23/2000

         , p_rev_component_tbl  IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl  IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
                                    := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status       IN  VARCHAR2
         , p_error_scope        IN  VARCHAR2 := NULL
         , p_other_message      IN  VARCHAR2 := NULL
         , p_other_status       IN  VARCHAR2 := NULL
         , p_other_token_tbl    IN  Error_Handler.Token_Tbl_Type
                                          := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level        IN  NUMBER
         , p_entity_index       IN  NUMBER := 1 -- := NULL
         , x_eco_rec            IN OUT NOCOPY ENG_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl   IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_revised_item_tbl   IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl  IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl  IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type

         -- Followings are for Routing BO
         , x_rev_operation_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
         , x_rev_op_resource_tbl  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
         , x_rev_sub_resource_tbl IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
         -- Added by MK on 08/23/2000

         );

        /*******************************************************
        -- Log_Error prodedure used for Eng Change Managmet
        -- enhancement
        --
        -- Added people and change Line error handling
        -- to existed Log_Error procedure
        --
        -- Added by MK on 08/13/2002
        ********************************************************/
        PROCEDURE Log_Error
        (  p_eco_rec              IN  Eng_Eco_Pub.Eco_Rec_Type
                                      := Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl     IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                      := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_change_line_tbl      IN  Eng_Eco_Pub.Change_Line_Tbl_Type -- Eng Change
                                      := Eng_Eco_Pub.G_MISS_CHANGE_LINE_TBL
         , p_revised_item_tbl     IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL
         , p_rev_operation_tbl    IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
         , p_rev_op_resource_tbl  IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL
         , p_rev_sub_resource_tbl IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL
         , p_rev_component_tbl    IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl   IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl    IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl       IN  Error_Handler.Mesg_Token_Tbl_Type
                                      := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status         IN  VARCHAR2
         , p_error_scope          IN  VARCHAR2 := NULL
         , p_other_message        IN  VARCHAR2 := NULL
         , p_other_status         IN  VARCHAR2 := NULL
         , p_other_token_tbl      IN  Error_Handler.Token_Tbl_Type
                                      := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level          IN  NUMBER
         , p_entity_index         IN  NUMBER := 1 -- := NULL
         , x_eco_rec              IN OUT NOCOPY Eng_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl     IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_change_line_tbl      IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Tbl_Type      -- Eng Change
         , x_revised_item_tbl     IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl    IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl   IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl    IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
         , x_rev_operation_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
         , x_rev_op_resource_tbl  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
         , x_rev_sub_resource_tbl IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
         );



END Eco_Error_Handler;

 

/
