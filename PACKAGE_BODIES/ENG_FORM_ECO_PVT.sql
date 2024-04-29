--------------------------------------------------------
--  DDL for Package Body ENG_FORM_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_FORM_ECO_PVT" AS
/* $Header: ENGFPVTB.pls 120.1.12010000.2 2009/11/12 23:14:42 umajumde ship $ */

--  Global constant holding the package name

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ENG_Eco_PVT';
G_EXC_QUIT_IMPORT       EXCEPTION;

G_MISS_ECO_REC          ENG_Eco_PUB.ECO_Rec_Type;
G_MISS_ECO_REV_REC      ENG_Eco_PUB.ECO_Revision_Rec_Type;
G_MISS_REV_ITEM_REC     ENG_Eco_PUB.Revised_Item_Rec_Type;
G_MISS_REV_COMP_REC     BOM_BO_PUB.Rev_Component_Rec_Type;
G_MISS_REF_DESG_REC     BOM_BO_PUB.Ref_Designator_Rec_Type;
G_MISS_SUB_COMP_REC     BOM_BO_PUB.Sub_Component_Rec_Type;
G_MISS_REV_OP_REC       BOM_RTG_PUB.Rev_Operation_Rec_Type;        --add
G_MISS_REV_OP_RES_REC   BOM_RTG_PUB.Rev_Op_Resource_Rec_Type;      --add
G_MISS_REV_SUB_RES_REC  BOM_RTG_PUB.Rev_Sub_Resource_Rec_Type;     --add

G_CONTROL_REC           BOM_BO_PUB.Control_Rec_Type;


-- Added for Bug#1587263
-- Set Revised Item's attributes to Global_System_Information
-- records, which are used from rev item chidlren entities.
-- This modification caused BOs modification for dependency issue.
-- In feature, following source I added will be eliminated
-- as well as BO's modification for dependency issue.
-- This procedure is called from each child entity of Rev Item.
-- p_bo_processed is 'RTG' or 'BOM'
--
--
PROCEDURE Set_RevItem_Attributes
(  p_revised_item_sequence_id    IN  NUMBER
 , p_bo_processed                IN  VARCHAR2 := 'RTG'
)

IS
        l_lot_number            VARCHAR2(30) ;
        l_routing_sequence_id   NUMBER ;
        l_from_wip_entity_id    NUMBER ;
        l_to_wip_entity_id      NUMBER ;
        l_from_cum_qty          NUMBER ;
        l_eco_for_production    NUMBER ;
        l_cfm_routing_flag      NUMBER ;

        l_err_text              VARCHAR2(2000);
        l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
        l_return_status         VARCHAR2(1);
BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        SELECT routing_sequence_id
             , lot_number
             , from_wip_entity_id
             , to_wip_entity_id
             , from_cum_qty
             , NVL(eco_for_production,2)
             , NVL(cfm_routing_flag,2)
         INTO  l_routing_sequence_id
             , l_lot_number
             , l_from_wip_entity_id
             , l_to_wip_entity_id
             , l_from_cum_qty
             , l_eco_for_production
             , l_cfm_routing_flag
         FROM eng_revised_items
         WHERE revised_item_sequence_id = p_revised_item_sequence_id ;

    EXCEPTION
        -- Added for Bug1606881
        WHEN NO_DATA_FOUND THEN
           NULL ;

    END  ;

    IF  p_bo_processed = 'RTG' THEN

         -- Set Revised Item Attributes to Global System Information.
         Bom_Rtg_Globals.Set_Lot_Number(l_lot_number) ;
         Bom_Rtg_Globals.Set_From_Wip_Entity_Id(l_from_wip_entity_id) ;
         Bom_Rtg_Globals.Set_To_Wip_Entity_Id(l_to_wip_entity_id) ;
         Bom_Rtg_Globals.Set_From_Cum_Qty(l_from_cum_qty) ;
         Bom_Rtg_Globals.Set_Eco_For_Production(l_eco_for_production) ;
         Bom_Rtg_Globals.Set_Routing_Sequence_Id(l_routing_sequence_id) ;

    ELSIF p_bo_processed = 'BOM' THEN

         -- Set Revised Item Attributes to Global System Information.
         Bom_Globals.Set_Lot_Number(l_lot_number) ;
         Bom_Globals.Set_From_Wip_Entity_Id(l_from_wip_entity_id) ;
         Bom_Globals.Set_To_Wip_Entity_Id(l_to_wip_entity_id) ;
         Bom_Globals.Set_From_Cum_Qty(l_from_cum_qty) ;
         Bom_Globals.Set_Eco_For_Production(l_eco_for_production) ;

    END IF ;

END Set_RevItem_Attributes ;


-- Added by Masahiko Mochizuki on 09/13/00
-- Rev_Sub_Res

PROCEDURE Rev_Sub_Res
(   p_unexp_rev_sub_res_rec         IN  BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_rev_sub_res_rec         IN OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rev_sub_resource_Rec    BOM_RTG_PUB.Rev_Sub_Resource_Rec_Type;
l_rev_sub_res_unexp_Rec   BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type := p_unexp_Rev_Sub_Res_rec;
l_old_rev_sub_resource_Rec   BOM_RTG_PUB.Rev_Sub_Resource_Rec_Type := NULL;
l_old_rev_sub_res_unexp_Rec  BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type := p_rev_op_resource_tbl;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_rev_sub_resource_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_rev_sub_resource_rec := l_rev_sub_resource_tbl(I);

        l_rev_sub_resource_rec.transaction_type :=
                UPPER(l_rev_sub_resource_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rev_sub_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Sub Operation Resource's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Sub_Op_Res.Check_Existence
                (  p_rev_sub_resource_rec          => l_rev_sub_resource_rec
                ,  p_rev_sub_res_unexp_rec         => l_rev_sub_res_unexp_rec
                ,  x_old_rev_sub_resource_rec      => l_old_rev_sub_resource_rec
                ,  x_old_rev_sub_res_unexp_rec     => l_old_rev_sub_res_unexp_rec
                ,  x_Mesg_Token_Tbl                => x_Mesg_Token_Tbl
                ,  x_return_status                 => x_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_rev_sub_res_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'RTG'
        ) ;



     -- Process Flow step 12 - Entity Level Validation

        IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_rev_sub_resource_rec.transaction_type = 'DELETE'
                THEN
                        NULL;
                        /*Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_rev_sub_resource_rec    => l_rev_sub_resource_rec
                        ,  p_rev_operation_unexp_rec => l_rev_operation_unexp_rec
                        ,  x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
                        ,  x_return_status           => l_Return_Status
                        );*/
                ELSE
                        Bom_Validate_Sub_Op_Res.Check_Entity
                        (  p_rev_sub_resource_rec      => l_rev_sub_resource_rec
                        ,  p_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                        ,  p_old_rev_sub_resource_rec  => l_old_rev_sub_resource_rec
                        ,  p_old_rev_sub_res_unexp_rec => l_old_rev_sub_res_unexp_rec
                        ,  p_control_rec               => Bom_Rtg_Pub.G_Default_Control_Rec
                        ,  x_rev_sub_resource_rec      => l_rev_sub_resource_rec
                        ,  x_rev_sub_res_unexp_rec     => l_rev_sub_res_unexp_rec
                        ,  x_return_status             => l_return_status
                        ,  x_mesg_token_tbl            => l_mesg_token_tbl
                        );

                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_SR_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes
--dbms_output.put_line('checking if to write to db');
        IF g_control_rec.write_to_db
        THEN
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_rtg_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);
                bom_rtg_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                Bom_Sub_Op_Res_Util.Perform_Writes
                (   p_rev_sub_resource_rec   => l_rev_sub_resource_rec
                ,   p_rev_sub_res_unexp_rec  => l_rev_sub_res_unexp_rec
                ,   p_control_rec            => Bom_Rtg_Pub.G_Default_Control_Rec
                ,   x_mesg_token_tbl         => x_mesg_token_tbl
                ,   x_return_status          => x_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_SR_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        l_rev_sub_resource_tbl(I) := l_rev_sub_resource_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_rev_sub_resource_tbl(I) := l_rev_sub_resource_rec;
        Eco_Error_Handler.Log_Error
                (  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => Error_Handler.G_SR_LEVEL
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;
        x_unexp_rev_sub_res_rec        := l_rev_sub_res_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_rev_op_resource_tbl         := l_rev_op_resource_tbl;

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_rev_sub_resource_tbl  => l_rev_sub_resource_tbl
                ,  p_mesg_token_tbl        => l_mesg_token_tbl
                ,  p_error_status          => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status          => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message         => l_other_message
                ,  p_other_token_tbl       => l_other_token_tbl
                ,  p_error_level           => Error_Handler.G_SR_LEVEL
                ,  p_entity_index          => I
                ,  x_ECO_rec               => l_ECO_rec
                ,  x_eco_revision_tbl      => l_eco_revision_tbl
                ,  x_revised_item_tbl      => l_revised_item_tbl
                ,  x_rev_component_tbl     => l_rev_component_tbl
                ,  x_ref_designator_tbl    => l_ref_designator_tbl
                ,  x_sub_component_tbl     => l_sub_component_tbl
                ,  x_rev_operation_tbl     => l_rev_operation_tbl
                ,  x_rev_op_resource_tbl   => l_rev_op_resource_tbl
                ,  x_rev_sub_resource_tbl  => l_rev_sub_resource_tbl
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;
        x_unexp_rev_sub_res_rec        := l_rev_sub_res_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;

        l_return_status := 'U';

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_rev_sub_res_rec    := l_rev_sub_res_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rev_Sub_Res;

-- Added by Masahiko Mochizuki on 09/12/00
--  Rev_Op_Res

PROCEDURE Rev_Op_Res
(   p_unexp_rev_op_res_rec          IN  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_rev_op_res_rec          IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rev_op_resource_Rec       BOM_RTG_PUB.Rev_Op_Resource_Rec_Type;
l_rev_op_res_unexp_Rec      BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type := p_unexp_rev_op_res_rec;
l_old_rev_op_resource_Rec   BOM_RTG_PUB.Rev_Op_Resource_Rec_Type := NULL;
l_old_rev_op_res_unexp_Rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type := p_rev_op_resource_tbl;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_rev_op_resource_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_rev_op_resource_rec := l_rev_op_resource_tbl(I);

        l_rev_op_resource_rec.transaction_type :=
                UPPER(l_rev_op_resource_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rev_op_resource_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Operation Resource's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Op_Res.Check_Existence
                (  p_rev_op_resource_rec        => l_rev_op_resource_rec
                ,  p_rev_op_res_unexp_rec       => l_rev_op_res_unexp_rec
                ,  x_old_rev_op_resource_rec    => l_old_rev_op_resource_rec
                ,  x_old_rev_op_res_unexp_rec   => l_old_rev_op_res_unexp_rec
                ,  x_Mesg_Token_Tbl             => x_Mesg_Token_Tbl
                ,  x_return_status              => x_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_rev_op_res_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'RTG'
        ) ;


     -- Process Flow step 12 - Entity Level Validation

        IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_rev_op_resource_rec.transaction_type = 'DELETE'
                THEN
                        NULL;
                        /*Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_rev_op_resource_rec     => l_rev_op_resource_rec
                        ,  p_rev_operation_unexp_rec => l_rev_operation_unexp_rec
                        ,  x_Mesg_Token_Tbl          => l_Mesg_Token_Tbl
                        ,  x_return_status           => l_Return_Status
                        );*/
                ELSE
                        Bom_Validate_Op_Res.Check_Entity
                        (  p_rev_op_resource_rec      => l_rev_op_resource_rec
                        ,  p_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                        ,  p_old_rev_op_resource_rec  => l_old_rev_op_resource_rec
                        ,  p_old_rev_op_res_unexp_rec => l_old_rev_op_res_unexp_rec
                        ,  p_control_rec              => Bom_Rtg_Pub.G_Default_Control_Rec
                        ,  x_rev_op_resource_rec      => l_rev_op_resource_rec
                        ,  x_rev_op_res_unexp_rec     => l_rev_op_res_unexp_rec
                        ,  x_return_status            => l_return_status
                        ,  x_mesg_token_tbl           => l_mesg_token_tbl
                        );
                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_RES_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes
--dbms_output.put_line('checking if to write to db');
        IF g_control_rec.write_to_db
        THEN
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_rtg_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);
                bom_rtg_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                Bom_Op_Res_Util.Perform_Writes
                (   p_rev_op_resource_rec       => l_rev_op_resource_rec
                ,   p_rev_op_res_unexp_rec      => l_rev_op_res_unexp_rec
                ,   p_control_rec               => Bom_Rtg_Pub.G_Default_Control_Rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_RES_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        l_rev_op_resource_tbl(I) := l_rev_op_resource_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_rev_op_resource_tbl(I) := l_rev_op_resource_rec;
        Eco_Error_Handler.Log_Error
                (  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => Error_Handler.G_RES_LEVEL
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;
        x_unexp_rev_op_res_rec         := l_rev_op_res_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_rev_sub_resource_tbl        := l_rev_sub_resource_tbl;

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message        => l_other_message
                ,  p_other_token_tbl      => l_other_token_tbl
                ,  p_error_level          => Error_Handler.G_RES_LEVEL
                ,  p_entity_index         => I
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;
        x_unexp_rev_op_res_rec         := l_rev_op_res_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;

        l_return_status := 'U';

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_rev_op_res_rec     := l_rev_op_res_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rev_Op_Res;

-- Added by Masahiko Mochizuki on 09/12/00
--  Rev_Ops

PROCEDURE Rev_Ops
(   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_operation_Tbl_Type
,   p_unexp_rev_op_rec              IN  BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_op_resource_Tbl_Type
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_sub_resource_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_rev_op_rec              IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rev_operation_Rec     BOM_RTG_PUB.Rev_Operation_Rec_Type;
l_rev_op_unexp_Rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type := p_unexp_rev_op_rec;
l_old_rev_operation_Rec BOM_RTG_PUB.Rev_Operation_Rec_Type := NULL;
l_old_rev_op_unexp_Rec  BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type := p_rev_operation_tbl;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type := p_rev_op_resource_tbl;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_query_op_seq_num      NUMBER := NULL;
-- Bug no:2770096
l_routing_sequence_id   NUMBER := NULL;
l_query_effective_date  DATE := NULL;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('At the beginning of Rev_Op, the rec count is');
     error_handler.write_debug( l_rev_operation_tbl.COUNT);
END IF;
 FOR I IN 1..l_rev_operation_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_rev_operation_rec := l_rev_operation_tbl(I);

        l_rev_operation_rec.transaction_type :=
                UPPER(l_rev_operation_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rev_operation_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Revised Operation's existence
        --
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('At the beginning of check existence');
END IF;
        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Op_Seq.Check_Existence
                (  p_rev_operation_rec     => l_rev_operation_rec
                ,  p_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,  x_old_rev_operation_rec => l_old_rev_operation_rec
                ,  x_old_rev_op_unexp_rec  => l_old_rev_op_unexp_rec
                ,  x_return_status         => l_return_status
                ,  x_mesg_token_tbl        => l_mesg_token_tbl
                );

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('After check existence, the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;


                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_rev_op_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'RTG'
        ) ;


        IF g_control_rec.attribute_defaulting AND
           l_rev_operation_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE
        THEN

                -- Process Flow step 9: Default missing values for Operation CREATE
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('before op_seq attribute , the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;
                Bom_Default_Op_Seq.Attribute_Defaulting
                (  p_rev_operation_rec     => l_rev_operation_rec
                ,  p_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,  p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
                ,  x_rev_operation_rec     => l_rev_operation_rec
                ,  x_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,  x_return_status         => l_return_status
                ,  x_mesg_token_tbl        => l_mesg_token_tbl
                );

                --dbms_output.put_line('pvt item num: ' || to_char(l_rev_operation_rec.item_sequence_number));

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND                     l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;


        IF ((g_control_rec.entity_defaulting AND
             NOT g_control_rec.attribute_defaulting)
            OR
            g_control_rec.entity_validation)
           AND
           (l_rev_operation_rec.transaction_type='UPDATE'
            OR
           (l_rev_operation_rec.transaction_type = 'CREATE'
            AND l_rev_operation_rec.acd_type = 2)
            )
        THEN
                IF l_rev_operation_rec.transaction_type='UPDATE'
                THEN

                     -- Bug #1614911
                     -- Form does not have new operatin seq num.
                     -- and Form always passes the new operation seq num value
                     -- to operation_sequence_number and new_operation_sequence_number
                     -- in l_rev_operation_rec.
                     --
                     -- Hence theis logic get the original op seq num and
                     -- effective date using operation_sequence_id
                     -- Bug no:2770096 ,selecting routing_sequence_id also
                     BEGIN

                         SELECT operation_seq_num ,
                                effectivity_date ,
				routing_sequence_id
                         INTO   l_query_op_seq_num ,
                                l_query_effective_date,
				l_routing_sequence_id
                         FROM   BOM_OPERATION_SEQUENCES
                         WHERE  operation_sequence_id
                                  =  l_rev_op_unexp_rec.operation_sequence_id  ;
                     EXCEPTION
                         WHEN OTHERS THEN
                              NULL ;
                     END  ;

                     /* Comment Out
                        l_query_op_seq_num := l_rev_operation_rec.new_operation_sequence_number;
                        l_query_effective_date := l_rev_operation_rec.start_effective_date;
                     */
                ELSE
                        l_query_op_seq_num := l_rev_operation_rec.old_operation_sequence_number;
                        l_query_effective_date := l_rev_operation_rec.old_start_effective_date;
                END IF;

                --dbms_output.put_line('querying row');

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('before query_row, the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

--Bug 2827097

if(l_rev_operation_rec.acd_type = 2 )then
   l_routing_sequence_id :=l_rev_op_unexp_rec.routing_sequence_id;
end if;

--end of Bug 2827097
                Bom_Op_Seq_Util.Query_Row
                   -- Modified conditions for Bug1609574
                   ( p_operation_sequence_number => l_query_op_seq_num
                                                    --  l_rev_operation_rec.old_operation_sequence_number
                   , p_effectivity_date          => l_query_effective_date
                                                    --  l_rev_operation_rec.old_start_effective_date
                   , p_routing_sequence_id       => l_routing_sequence_id --Bug no:2770096
		                                   --l_rev_op_unexp_rec.routing_sequence_id
                   , p_operation_type            => l_rev_operation_rec.operation_type
                   , p_mesg_token_tbl            => l_mesg_token_tbl
                   , x_rev_operation_rec         => l_old_rev_operation_rec
                   , x_rev_op_unexp_rec          => l_old_rev_op_unexp_rec
                   , x_mesg_token_tbl            => l_mesg_token_tbl
                   , x_return_status             => l_return_status
                   );

                --dbms_output.put_line('query return_status: ' || l_return_status);

                IF l_return_status = 'N'
                THEN
                        -- Added for Bug1609574
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl(1).token_name := 'OP_SEQ_NUMBER';
                        l_Token_Tbl(1).token_value :=
                                 l_rev_operation_rec.operation_sequence_number ;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'BOM_OP_CREATE_REC_NOT_FOUND'
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );

                END IF;

/*              IF l_return_status = 'F'
                THEN
                        dbms_output.put_line('queried old record');
                ELSIF l_return_status = 'N'
                THEN
                        dbms_output.put_line('old record not found');
                END IF;*/
        END IF;

     -- Process Flow step 11 - Entity Level Defaulting

        IF g_control_rec.entity_defaulting
        THEN
                --dbms_output.put_line('Entity Defaulting');
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('before entity_defaulting , the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

                Bom_Default_Op_Seq.Entity_Defaulting
                (   p_rev_operation_rec     => l_rev_operation_rec
                ,   p_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,   p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
                ,   x_rev_operation_rec     => l_rev_operation_rec
                ,   x_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,   x_return_status         => l_return_status
                ,   x_mesg_token_tbl        => l_mesg_token_tbl
                );

                --dbms_output.put_line('pvt item num: ' || to_char(l_rev_operation_rec.item_sequence_number));

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

     -- Process Flow step 12 - Entity Level Validation
        IF g_control_rec.entity_validation
        THEN

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('before entity validation , the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

                --dbms_output.put_line('Entity validation');
                IF l_rev_operation_rec.transaction_type = 'DELETE'
                THEN
                        NULL;
                        /*Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_rev_operation_rec    => l_rev_operation_rec
                        ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  x_return_status        => l_Return_Status
                        );*/
                ELSE
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('before calling Bom_Validate_Op_Seq.Check_Entity,the return status is');
     error_handler.write_debug( l_Return_Status);
     error_handler.write_debug( l_rev_operation_rec.operation_sequence_number);
      error_handler.write_debug( l_rev_operation_rec.count_point_type);
      error_handler.write_debug( l_rev_operation_rec.backflush_flag);

     error_handler.write_debug(  'then all others:'           );
      error_handler.write_debug(  l_rev_operation_rec.eco_name           );
      error_handler.write_debug(  l_rev_operation_rec.organization_code  );
      error_handler.write_debug(  l_rev_operation_rec.revised_item_name );
      error_handler.write_debug(  l_rev_operation_rec.new_revised_item_revision  );
      error_handler.write_debug(  l_rev_operation_rec.ACD_Type                );
      error_handler.write_debug(  l_rev_operation_rec.Alternate_Routing_Code   );
      error_handler.write_debug(  l_rev_operation_rec.Operation_Type        );
      error_handler.write_debug(  l_rev_operation_rec.Start_Effective_Date  );
      error_handler.write_debug(  l_rev_operation_rec.new_operation_sequence_number);
      error_handler.write_debug(  l_rev_operation_rec.Old_Operation_Sequence_Number );
      error_handler.write_debug(  l_rev_operation_rec.Old_Start_Effective_Date    );
      error_handler.write_debug(  l_rev_operation_rec.Standard_Operation_Code   );
      error_handler.write_debug(  l_rev_operation_rec.Department_Code           );
      error_handler.write_debug(  l_rev_operation_rec.Op_Lead_Time_Percent     );
      error_handler.write_debug(  l_rev_operation_rec.Minimum_Transfer_Quantity);
      error_handler.write_debug(  l_rev_operation_rec.Operation_Description    );
      error_handler.write_debug(  l_rev_operation_rec.Disable_Date            );
      error_handler.write_debug(  l_rev_operation_rec.Option_Dependent_Flag   );
      error_handler.write_debug(  l_rev_operation_rec.Reference_Flag         );
      error_handler.write_debug(  l_rev_operation_rec.Yield                  );
      error_handler.write_debug(  l_rev_operation_rec.Cumulative_Yield       );
      error_handler.write_debug(  l_rev_operation_rec.Cancel_Comments       );
      error_handler.write_debug(  l_rev_operation_rec.Attribute_category);
    error_handler.write_debug( 'After attribute_category');
      error_handler.write_debug(  l_rev_operation_rec.Original_System_Reference   );
      error_handler.write_debug(  l_rev_operation_rec.Transaction_Type        );
      error_handler.write_debug(  l_rev_operation_rec.Return_Status          );
END IF;




                        Bom_Validate_Op_Seq.Check_Entity
                        (  p_rev_operation_rec     => l_rev_operation_rec
                        ,  p_rev_op_unexp_rec      => l_rev_op_unexp_rec
                        ,  p_old_rev_operation_rec => l_old_rev_operation_rec
                        ,  p_old_rev_op_unexp_rec  => l_old_rev_op_unexp_rec
                        ,  p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
                        ,  x_rev_operation_rec     => l_rev_operation_rec
                        ,  x_rev_op_unexp_rec      => l_rev_op_unexp_rec
                        ,  x_return_status         => l_return_status
                        ,  x_mesg_token_tbl        => l_mesg_token_tbl
                        );

                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        --dbms_output.put_line('logging warnings');
                        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes


        IF g_control_rec.write_to_db
        THEN

IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('Before write_to_db, the return status is');
     error_handler.write_debug( l_Return_Status);
     error_handler.write_debug( l_rev_op_unexp_rec.operation_sequence_id);
END IF;
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_rtg_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);
                bom_rtg_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

           --Bug 9088260 changes begin
 	           IF(l_rev_operation_rec.alternate_routing_code is NULL)
 	           THEN
             ENG_Globals.Perform_Writes_For_Primary_Rtg
              (   p_rev_operation_rec       => l_rev_operation_rec
              ,   p_rev_op_unexp_rec        => l_rev_op_unexp_rec
              ,   x_mesg_token_tbl          => l_mesg_token_tbl
              ,   x_return_status           => l_return_status
              ) ;
             ELSE
 	              ENG_Globals.Perform_Writes_For_Alt_Rtg
 	               (   p_rev_operation_rec       => l_rev_operation_rec
 	               ,   p_rev_op_unexp_rec        => l_rev_op_unexp_rec
 	               ,   x_mesg_token_tbl          => l_mesg_token_tbl
 	               ,   x_return_status           => l_return_status
 	               ) ;
 	             END IF;
 	              --Bug  9088260  changes end
           IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           THEN
               l_other_message := 'BOM_OP_WRITES_UNEXP_SKIP';
               l_other_token_tbl(1).token_name := 'OP_SEQ_NUMBER';
               l_other_token_tbl(1).token_value :=
                          l_rev_operation_rec.operation_sequence_number ;
               RAISE EXC_UNEXP_SKIP_OBJECT ;
           ELSIF l_return_status ='S' AND
               l_mesg_token_tbl .COUNT <>0
           THEN
               ECO_Error_Handler.Log_Error
               (  p_rev_operation_tbl   => l_rev_operation_tbl
               ,  p_rev_op_resource_tbl => l_rev_op_resource_tbl
               ,  p_rev_sub_resource_tbl=> l_rev_sub_resource_tbl
               ,  p_mesg_token_tbl      => l_mesg_token_tbl
               ,  p_error_status        => 'W'
               ,  p_error_level         => Error_Handler.G_OP_LEVEL
               ,  p_entity_index        => I
               ,  x_ECO_rec             => l_ECO_rec
               ,  x_eco_revision_tbl    => l_eco_revision_tbl
               ,  x_revised_item_tbl    => l_revised_item_tbl
               ,  x_rev_component_tbl   => l_rev_component_tbl
               ,  x_ref_designator_tbl  => l_ref_designator_tbl
               ,  x_sub_component_tbl   => l_sub_component_tbl
               ,  x_rev_operation_tbl   => l_rev_operation_tbl
               ,  x_rev_op_resource_tbl => l_rev_op_resource_tbl
               ,  x_rev_sub_resource_tbl=> l_rev_sub_resource_tbl
               ) ;
           END IF;

                --dbms_output.put_line('Writing to the database');
                BOM_Op_Seq_Util.Perform_Writes
                (   p_rev_operation_rec     => l_rev_operation_rec
                ,   p_rev_op_unexp_rec      => l_rev_op_unexp_rec
                ,   p_control_rec           => Bom_Rtg_Pub.G_Default_Control_Rec
                ,   x_return_status         => l_return_status
                ,   x_mesg_token_tbl        => l_mesg_token_tbl
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );
                END IF;
        END IF;

        l_rev_operation_tbl(I) := l_rev_operation_rec;


IF BOM_Globals.get_debug = 'Y'
THEN
    error_handler.write_debug( 'after checck entity ');
   error_handler.write_debug( l_rev_operation_tbl(1).operation_sequence_number);
      error_handler.write_debug( l_rev_operation_tbl(1).count_point_type);
      error_handler.write_debug( l_rev_operation_tbl(1).backflush_flag);

     error_handler.write_debug(  'then all others:'           );
      error_handler.write_debug(  l_rev_operation_tbl(1).eco_name           );
      error_handler.write_debug(  l_rev_operation_tbl(1).organization_code  );
      error_handler.write_debug(  l_rev_operation_tbl(1).revised_item_name );
      error_handler.write_debug(  l_rev_operation_tbl(1).new_revised_item_revision  );
      error_handler.write_debug(  l_rev_operation_tbl(1).ACD_Type                );
      error_handler.write_debug(  l_rev_operation_tbl(1).Alternate_Routing_Code   );
      error_handler.write_debug(  l_rev_operation_tbl(1).Operation_Type        );
      error_handler.write_debug(  l_rev_operation_tbl(1).Start_Effective_Date  );
      error_handler.write_debug(  l_rev_operation_tbl(1).new_operation_sequence_number);
      error_handler.write_debug(  l_rev_operation_tbl(1).Old_Operation_Sequence_Number );
      error_handler.write_debug(  l_rev_operation_tbl(1).Old_Start_Effective_Date    );
      error_handler.write_debug(  l_rev_operation_tbl(1).Standard_Operation_Code   );
      error_handler.write_debug(  l_rev_operation_tbl(1).Department_Code           );
      error_handler.write_debug(  l_rev_operation_tbl(1).Op_Lead_Time_Percent     );
      error_handler.write_debug(  l_rev_operation_tbl(1).Minimum_Transfer_Quantity);
      error_handler.write_debug(  l_rev_operation_tbl(1).Operation_Description    );
      error_handler.write_debug(  l_rev_operation_tbl(1).Disable_Date            );
      error_handler.write_debug(  l_rev_operation_tbl(1).Option_Dependent_Flag   );
      error_handler.write_debug(  l_rev_operation_tbl(1).Reference_Flag         );
      error_handler.write_debug(  l_rev_operation_tbl(1).Yield                  );
      error_handler.write_debug(  l_rev_operation_tbl(1).Cumulative_Yield       );
      error_handler.write_debug(  l_rev_operation_tbl(1).Cancel_Comments       );
      error_handler.write_debug(  l_rev_operation_tbl(1).Attribute_category);
    error_handler.write_debug( 'After attribute_category');
      error_handler.write_debug(  l_rev_operation_tbl(1).Original_System_Reference   );
      error_handler.write_debug(  l_rev_operation_tbl(1).Transaction_Type        );
      error_handler.write_debug(  l_rev_operation_tbl(1).Return_Status          );
  --    error_handler.write_debug(     l_rev_operation_tbl(1).Revised_Item_Sequence_Id    );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Operation_Sequence_Id      );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Old_Operation_Sequence_Id  );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Routing_Sequence_Id      );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Revised_Item_Id          );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Organization_Id          );
   --   error_handler.write_debug(     l_rev_operation_tbl(1).Standard_Operation_Id    );
    --  error_handler.write_debug(     l_rev_operation_tbl(1).Department_Id            );

     error_handler.write_debug('End of Rev_Op, the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_rev_operation_tbl(I) := l_rev_operation_rec;
        Eco_Error_Handler.Log_Error
                        (  p_rev_operation_tbl    => l_rev_operation_tbl
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => FND_API.G_RET_STS_ERROR
                        ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                        ,  p_error_level          => Error_Handler.G_OP_LEVEL
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                        );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_unexp_rev_op_rec             := l_rev_op_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;
                --dbms_output.put_line('err pvt item num: ' || to_char(l_rev_operation_rec.item_sequence_number));

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_rev_operation_tbl    => l_rev_operation_tbl
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message        => l_other_message
                ,  p_other_token_tbl      => l_other_token_tbl
                ,  p_error_level          => Error_Handler.G_OP_LEVEL
                ,  p_entity_index         => I
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl
                );

        l_return_status := 'U';
--dbms_output.put_line('unexp message' || l_mesg_token_tbl(1).message_text);
        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;
        x_unexp_rev_op_rec             := l_rev_op_unexp_rec;
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_rev_op_rec         := l_rev_op_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;
                --dbms_output.put_line('end pvt item num: ' || to_char(l_rev_operation_rec.item_sequence_number));

END Rev_Ops;

--  Sub_Comps

PROCEDURE Sub_Comps
(   p_unexp_sub_comp_rec            IN  BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_sub_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_sub_component_Rec      BOM_BO_PUB.Sub_Component_Rec_Type;
l_sub_comp_unexp_Rec     BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type := p_unexp_sub_comp_rec;
l_old_sub_component_Rec  BOM_BO_PUB.Sub_Component_Rec_Type := NULL;
l_old_sub_comp_unexp_Rec BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_sub_component_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_sub_component_rec := l_sub_component_tbl(I);

        l_sub_component_rec.transaction_type :=
                UPPER(l_sub_component_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_sub_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Substitute Component's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Sub_Component.Check_Existence
                (  p_sub_component_rec          => l_sub_component_rec
                ,  p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                ,  x_old_sub_component_rec      => l_old_sub_component_rec
                ,  x_old_sub_comp_unexp_rec     => l_old_sub_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_sub_comp_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'BOM'
        ) ;


     -- Process Flow step 12 - Entity Level Validation

        IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_sub_component_rec.transaction_type = 'DELETE'
                THEN
                        NULL;
                        /*Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_rev_component_rec     => l_rev_component_rec
                        ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  x_return_status        => l_Return_Status
                        );*/
                ELSE
                        Bom_Validate_Sub_Component.Check_Entity
                        (  p_sub_component_rec          => l_sub_component_rec
                        ,  p_sub_comp_unexp_rec         => l_sub_comp_unexp_rec
                        ,  p_control_rec                => g_control_rec
                        ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                        ,  x_return_status              => l_Return_Status
                        );
                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ref_designator_tbl => l_ref_designator_tbl
                        ,  p_sub_component_tbl  => l_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 6
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_sub_component_tbl  => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes
--dbms_output.put_line('checking if to write to db');
        IF g_control_rec.write_to_db
        THEN
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                Bom_Sub_Component_Util.Perform_Writes
                (   p_sub_component_rec         => l_sub_component_rec
                ,   p_sub_comp_unexp_rec        => l_sub_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ref_designator_tbl => l_ref_designator_tbl
                        ,  p_sub_component_tbl  => l_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 6
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_sub_component_tbl  => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                        );
                END IF;
        END IF;

        l_sub_component_tbl(I) := l_sub_component_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_sub_component_tbl(I) := l_sub_component_rec;
        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_ERROR
                ,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_eco_rec            => l_eco_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_unexp_sub_comp_rec           := l_sub_comp_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --add

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 6
                ,  p_entity_index       => I
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl     => l_rev_operation_tbl     --add
                ,  x_rev_op_resource_tbl   => l_rev_op_resource_tbl   --add
                ,  x_rev_sub_resource_tbl  => l_rev_sub_resource_tbl  --add
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_unexp_sub_comp_rec           := l_sub_comp_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --add

        l_return_status := 'U';

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_sub_comp_rec       := l_sub_comp_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;     --add
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --add
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --add
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Sub_Comps;

--  Ref_Desgs

PROCEDURE Ref_Desgs
(   p_unexp_ref_desg_rec            IN  BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_ref_desg_rec            IN OUT NOCOPY BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type     --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type   --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type  --add
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_ref_designator_Rec    BOM_BO_PUB.Ref_Designator_Rec_Type;
l_ref_desg_unexp_Rec    BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type := p_unexp_ref_desg_rec;
l_old_ref_designator_Rec BOM_BO_PUB.Ref_Designator_Rec_Type := NULL;
l_old_ref_desg_unexp_Rec BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;      --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;    --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;   --add
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_ref_designator_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_ref_designator_rec := l_ref_designator_tbl(I);

        l_ref_designator_rec.transaction_type :=
                UPPER(l_ref_designator_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_ref_designator_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Reference Designator's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Ref_Designator.Check_Existence
                (  p_ref_designator_rec         => l_ref_designator_rec
                ,  p_ref_desg_unexp_rec         => l_ref_desg_unexp_rec
                ,  x_old_ref_designator_rec     => l_old_ref_designator_rec
                ,  x_old_ref_desg_unexp_rec     => l_old_ref_desg_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;


        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_ref_desg_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'BOM'
        ) ;


        -- Process Flow step 13 : Database Writes

        IF g_control_rec.write_to_db
        THEN
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                Bom_Ref_Designator_Util.Perform_Writes
                (   p_ref_designator_rec        => l_ref_designator_rec
                ,   p_ref_desg_unexp_rec        => l_ref_desg_unexp_rec
                ,   p_control_rec               => g_control_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ref_designator_tbl => l_ref_designator_tbl
                        ,  p_sub_component_tbl  => l_sub_component_tbl
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 5
                        ,  p_entity_index       => I
                        ,  x_eco_rec            => l_eco_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_sub_component_tbl  => l_sub_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                        );
                END IF;
        END IF;

        l_ref_designator_tbl(I) := l_ref_designator_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_ref_designator_tbl(I) := l_ref_designator_rec;
        Eco_Error_Handler.Log_Error
                (  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 5
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_unexp_ref_desg_rec           := l_ref_desg_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --add

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 5
                ,  p_entity_index       => I
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                );

        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_unexp_ref_desg_rec           := l_ref_desg_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;     --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;   --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;  --add


        l_return_status := 'U';
        IF g_control_rec.write_to_db
        THEN
                RAISE;
        END IF;

  END;
  END LOOP; -- END ref designator processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_ref_desg_rec       := l_ref_desg_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;     --add
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;   --add
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl;  --add
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Ref_Desgs;

--  Rev_Comps

PROCEDURE Rev_Comps
(   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_unexp_rev_comp_rec            IN  BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_rev_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type     --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type   --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type  --add
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_rev_component_Rec     BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_comp_unexp_Rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type := p_unexp_rev_comp_rec;
l_old_rev_component_Rec BOM_BO_PUB.Rev_Component_Rec_Type := NULL;
l_old_rev_comp_unexp_Rec     BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type := p_rev_component_tbl;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
l_query_op_seq_num      NUMBER := NULL;
l_query_effective_date  DATE := NULL;
l_query_from_unit_number  VARCHAR2(30) := NULL;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_rev_component_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_rev_component_rec := l_rev_component_tbl(I);

        l_rev_component_rec.transaction_type :=
                UPPER(l_rev_component_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_rev_component_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify Revised Component's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                Bom_Validate_Bom_Component.Check_Existence
                (  p_rev_component_rec          => l_rev_component_rec
                ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                ,  x_old_rev_component_rec      => l_old_rev_component_rec
                ,  x_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                ,  x_return_status              => l_Return_Status
                );


                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        -- Set parent revised item attributes
        Set_RevItem_Attributes
        (  p_revised_item_sequence_id    => l_rev_comp_unexp_rec.revised_item_sequence_id
         , p_bo_processed                => 'BOM'
        ) ;


        IF g_control_rec.attribute_defaulting AND
           l_rev_component_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE
        THEN

                -- Process Flow step 9: Default missing values for Operation CREATE

                --dbms_output.put_line('Attribute Defaulting');
                Bom_Default_Bom_Component.Attribute_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                ,   x_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('pvt item num: ' || to_char(l_rev_component_rec.item_sequence_number));

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 4
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl     --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl   --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl  --add
                        );
                END IF;
        END IF;

        IF ((g_control_rec.entity_defaulting AND
             NOT g_control_rec.attribute_defaulting)
            OR
            g_control_rec.entity_validation)
           AND
           (--l_rev_component_rec.transaction_type='UPDATE'
            --OR -- commented out validation on update as it not required --Bug 3864772
            (l_rev_component_rec.transaction_type = 'CREATE'
             AND l_rev_component_rec.acd_type = 2))
        THEN
                IF l_rev_component_rec.transaction_type='UPDATE'
                THEN
                        l_query_op_seq_num := l_rev_component_rec.new_operation_sequence_number;
                        l_query_effective_date := l_rev_component_rec.start_effective_date;
                        l_query_from_unit_number := l_rev_component_rec.from_end_item_unit_number;
                ELSE
                        l_query_op_seq_num := l_rev_component_rec.old_operation_sequence_number;
                        l_query_effective_date := l_rev_component_rec.old_effectivity_date;
                        l_query_from_unit_number := l_rev_component_rec.old_from_end_item_unit_number;
                END IF;

                --dbms_output.put_line('querying row');
                Bom_Bom_Component_Util.Query_Row
                   ( p_component_item_id         => l_rev_comp_unexp_rec.component_item_id
                   , p_operation_sequence_number => l_query_op_seq_num
                   , p_effectivity_date          => l_query_effective_date
                   , p_bill_sequence_id          => l_rev_comp_unexp_rec.bill_sequence_id
                   , p_from_end_item_number      => l_query_from_unit_number
                   , p_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                   , x_Rev_Component_Rec         => l_old_rev_component_rec
                   , x_Rev_Comp_Unexp_Rec        => l_old_rev_comp_unexp_rec
                   , x_return_status             => l_return_status
                   , x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                   );

                --dbms_output.put_line('query return_status: ' || l_return_status);

                IF l_return_status = 'N'
                THEN
                        -- Added for Bug1609574
                        l_return_status := Error_Handler.G_STATUS_ERROR ;
                        l_Token_Tbl(1).token_name := 'REVISED_COMPONENT_NAME';
                        l_Token_Tbl(1).token_value := l_rev_component_rec.component_item_name;

                        Error_Handler.Add_Error_Token
                        ( p_message_name       => 'BOM_CMP_CREATE_REC_NOT_FOUND'
                        , p_mesg_token_tbl     => l_Mesg_Token_Tbl
                        , p_token_tbl          => l_Token_Tbl
                        , x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                        );

                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 4
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;

/*              IF l_return_status = 'F'
                THEN
                        dbms_output.put_line('queried old record');
                ELSIF l_return_status = 'N'
                THEN
                        dbms_output.put_line('old record not found');
                END IF;*/
        END IF;

     -- Process Flow step 11 - Entity Level Defaulting

        IF g_control_rec.entity_defaulting
        THEN
                --dbms_output.put_line('Entity Defaulting');

                Bom_Default_Bom_Component.Entity_Defaulting
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_old_rev_component_rec     => l_old_rev_component_rec
                ,   x_rev_component_rec         => l_rev_component_rec
                );

                --dbms_output.put_line('pvt item num: ' || to_char(l_rev_component_rec.item_sequence_number));

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 4
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

     -- Process Flow step 12 - Entity Level Validation

        IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_rev_component_rec.transaction_type = 'DELETE'
                THEN
                        NULL;
                        /*Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_rev_component_rec     => l_rev_component_rec
                        ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  x_return_status        => l_Return_Status
                        );*/
                ELSE
                        Bom_Validate_Bom_Component.Check_Entity
                        (  p_rev_component_rec          => l_rev_component_rec
                        ,  p_rev_comp_unexp_rec         => l_rev_comp_unexp_rec
                        ,  p_old_rev_component_rec      => l_old_rev_component_rec
                        ,  p_old_rev_comp_unexp_rec     => l_old_rev_comp_unexp_rec
                        ,  p_control_rec                => g_control_rec
                        ,  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                        ,  x_return_status              => l_Return_Status
                        );
                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        --dbms_output.put_line('logging warnings');
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 4
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes

        IF g_control_rec.write_to_db
        THEN
                bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                BOM_BOM_Component_Util.Perform_Writes
                (   p_rev_component_rec         => l_rev_component_rec
                ,   p_rev_comp_unexp_rec        => l_rev_comp_unexp_rec
                ,   p_control_rec               => g_control_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 4 --reverted fix 2774876-- vani
                        ,  p_entity_index         => I
                        ,  x_eco_rec              => l_eco_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        l_rev_component_tbl(I) := l_rev_component_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        l_rev_component_tbl(I) := l_rev_component_rec;
        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 4
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_unexp_rev_comp_rec           := l_rev_comp_unexp_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add
                --dbms_output.put_line('err pvt item num: ' || to_char(l_rev_component_rec.item_sequence_number));

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message        => l_other_message
                ,  p_other_token_tbl      => l_other_token_tbl
                ,  p_error_level          => 4
                ,  p_entity_index         => I
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        l_return_status := 'U';
--dbms_output.put_line('unexp message' || l_mesg_token_tbl(1).message_text);
        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_unexp_rev_comp_rec           := l_rev_comp_unexp_rec;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_rev_comp_rec       := l_rev_comp_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;    --add
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;  --add
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl; --add
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;
                --dbms_output.put_line('end pvt item num: ' || to_char(l_rev_component_rec.item_sequence_number));

END Rev_Comps;

--  Rev_Items

PROCEDURE Rev_Items
(   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_unexp_rev_item_rec            IN  ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_Operation_Tbl_Type    --add
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type  --add
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type --add
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_rev_item_rec            IN OUT NOCOPY ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_revised_item_Rec      Eng_Eco_Pub.Revised_Item_Rec_Type;
l_rev_item_unexp_Rec    Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type := p_unexp_rev_item_rec;
l_old_rev_item_Rec      Eng_Eco_Pub.Revised_Item_Rec_Type := NULL;
l_old_rev_item_unexp_Rec     Eng_Eco_Pub.Rev_Item_Unexposed_Rec_Type := NULL;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type    := p_revised_item_tbl;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type    := p_rev_component_tbl;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type   := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type    := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type    := p_rev_operation_tbl;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type  := p_rev_op_resource_tbl;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;  --add
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN


    IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('at the beginning of rev_item procedure');
     error_handler.write_debug('revised item count is');
     error_handler.write_debug(l_revised_item_tbl.COUNT);

   END IF;

    -- Begin block that processes revised items. This block holds the exception handlers
    -- for header errors.
    FOR I IN 1..l_revised_item_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        l_revised_item_rec := l_revised_item_tbl(I);

        l_revised_item_rec.transaction_type :=
                UPPER(l_revised_item_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_revised_item_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify ECO's existence
        --

        IF g_control_rec.check_existence
        THEN
                --dbms_output.put_line('Checking Existence');
                ENG_Validate_Revised_Item.Check_Existence
                ( p_revised_item_rec    => l_revised_item_rec
                , p_rev_item_unexp_rec  => l_rev_item_unexp_rec
                , x_old_revised_item_rec=> l_old_rev_item_rec
                , x_old_rev_item_unexp_rec  => l_old_rev_item_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
		,   x_disable_revision    =>   x_disable_revision --Bug no:3034642
                );
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After check existence');
 error_handler.write_debug( l_Return_Status);
 END IF;
                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

        IF g_control_rec.attribute_defaulting AND
           l_revised_item_rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE
        THEN

                -- Process Flow step 9: Default missing values for Operation CREATE
                --dbms_output.put_line('Attribute Defaulting');
                Eng_Default_Revised_Item.Attribute_Defaulting
                (   p_revised_item_rec   => l_revised_item_rec
                ,   p_rev_item_unexp_rec => l_rev_item_unexp_rec
                ,   x_revised_item_rec   => l_revised_item_rec
                ,   x_rev_item_unexp_rec => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                ,   x_return_status      => l_Return_Status
                );
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After attribute defaulting, the return status is');
     error_handler.write_debug( l_Return_Status);
   END IF;
                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 3
                        ,  p_entity_index         => I
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        IF ((g_control_rec.entity_defaulting AND
             NOT g_control_rec.attribute_defaulting)
            OR
            g_control_rec.entity_validation)
           AND
           l_revised_item_rec.transaction_type='UPDATE'
        THEN
                --dbms_output.put_line('querying row');
                ENG_Revised_Item_Util.Query_Row
                ( p_revised_item_id     => l_rev_item_unexp_rec.revised_item_id
                , p_organization_id     => l_rev_item_unexp_rec.organization_id
                , p_change_notice       => l_revised_item_rec.eco_name
                , p_start_eff_date      => l_revised_item_rec.start_effective_date
                , p_new_item_revision   => l_revised_item_rec.new_revised_item_revision
                , p_new_routing_revision => l_revised_item_rec.new_routing_revision --add
                , p_from_end_item_number=> l_revised_item_rec.from_end_item_unit_number
                , p_alternate_designator => l_revised_item_rec.alternate_bom_code -- To Fix Bug 3760265
                , x_revised_item_rec    => l_old_rev_item_rec
                , x_rev_item_unexp_rec  => l_old_rev_item_unexp_rec
                , x_Return_status       => l_return_status
                );

IF BOM_Globals.get_debug = 'Y'
   Then
      error_handler.write_debug('After query row, the return status is');
     error_handler.write_debug( l_Return_Status);
   END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

/*              IF l_return_status = 'F'
                THEN
                        dbms_output.put_line('queried old record');
                ELSIF l_return_status = 'N'
                THEN
                        dbms_output.put_line('old record not found');
                END IF;*/
        END IF;

     -- Process Flow step 11 - Entity Level Defaulting

        IF g_control_rec.entity_defaulting
        THEN
                --dbms_output.put_line('Entity Defaulting');

                Eng_Default_Revised_Item.Entity_Defaulting
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_old_revised_item_rec      => l_old_rev_item_rec
                ,   p_old_rev_item_unexp_rec    => l_old_rev_item_unexp_rec
                ,   p_control_rec               => g_control_rec
                ,   x_revised_item_rec          => l_revised_item_rec
                ,   x_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

IF BOM_Globals.get_debug = 'Y'
   Then
      error_handler.write_debug('After eitity default, the return status is');
     error_handler.write_debug( l_Return_Status);
   END IF;
                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_entity_index         => I
                        ,  p_error_level          => 3
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

     -- Process Flow step 12 - Entity Level Validation

        IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_revised_item_rec.transaction_type = 'DELETE'
                THEN
                        Eng_Validate_Revised_Item.Check_Entity_Delete
                        (  p_revised_item_rec     => l_revised_item_rec
                        ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  x_return_status        => l_Return_Status
                        );
                ELSE
                        Eng_Validate_Revised_Item.Check_Entity
                        (  p_revised_item_rec     => l_revised_item_rec
                        ,  p_rev_item_unexp_rec   => l_rev_item_unexp_rec
                        ,  p_old_revised_item_rec => l_old_rev_item_rec
                        ,  p_old_rev_item_unexp_rec => l_old_rev_item_unexp_rec
                        ,  p_control_rec          => g_control_rec
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  x_return_status        => l_Return_Status
                        );
                END IF;

IF BOM_Globals.get_debug = 'Y'
   Then
      error_handler.write_debug('After entity validation.');
     error_handler.write_debug( l_Return_Status);
   END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 3
                        ,  p_entity_index         => I
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        -- Process Flow step 13 : Database Writes

        IF g_control_rec.write_to_db
        THEN
                eng_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                eng_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

                --dbms_output.put_line('Writing to the database');
                ENG_Revised_Item_Util.Perform_Writes
                (   p_revised_item_rec          => l_revised_item_rec
                ,   p_rev_item_unexp_rec        => l_rev_item_unexp_rec
                ,   p_control_rec               => g_control_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

IF BOM_Globals.get_debug = 'Y'
   Then
      error_handler.write_debug('After write to db, the return status is');
     error_handler.write_debug( l_Return_Status);
   END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 3
                        ,  p_entity_index         => I
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        l_revised_item_tbl(I) := l_revised_item_rec;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        --dbms_output.put_line('Expected error generated');
        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 3
                ,  p_entity_index         => I
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );
--dbms_output.put_line('logged error: ' || l_return_Status);
        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_unexp_rev_item_rec           := l_rev_item_unexp_Rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message        => l_other_message
                ,  p_other_token_tbl      => l_other_token_tbl
                ,  p_error_level          => 3
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_unexp_rev_item_rec           := l_rev_item_unexp_Rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add

        l_return_status := 'U';

  END;
  END LOOP; -- END revised items processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;


     --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_rev_item_rec       := l_rev_item_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;    --add
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;  --add
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl; --add
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Rev_Items;

--  Eco_Rev

PROCEDURE Eco_Rev
(   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   p_unexp_eco_rev_rec             IN  ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_eco_rev_rec             IN OUT NOCOPY ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_eco_rev_unexp_Rec     Eng_Eco_Pub.Eco_Rev_Unexposed_Rec_Type := p_unexp_eco_rev_rec;
l_eco_rec               ENG_ECO_PUB.ECO_Rec_Type := NULL;
l_eco_revision_rec      ENG_ECO_PUB.Eco_Revision_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type    := p_eco_revision_tbl;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type    := p_revised_item_tbl;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type    := p_rev_component_tbl;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type   := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type    := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type    := p_rev_operation_tbl;    --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type  := p_rev_op_resource_tbl;  --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl; --add
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes eco revisions. This block holds the exception handlers
    -- for header errors.

    FOR I IN 1..l_eco_revision_tbl.COUNT LOOP
    BEGIN
        --  Load local records.

        --  Load local records.

        l_eco_revision_rec := l_eco_revision_tbl(I);

        l_eco_revision_rec.transaction_type :=
                UPPER(l_eco_revision_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_eco_revision_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        IF g_control_rec.attribute_defaulting
        THEN

                --dbms_output.put_line('Attribute Defaulting');
                 Eng_Default_ECO_revision.Attribute_Defaulting
                        (   p_eco_revision_rec          => l_eco_revision_rec
                        ,   p_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                        ,   x_eco_revision_rec          => l_eco_revision_rec
                        ,   x_eco_rev_unexp_rec         => l_eco_rev_unexp_Rec
                        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                        ,   x_return_status             => l_Return_Status
                        );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec            => l_ECO_rec
                        ,  p_eco_revision_tbl   => l_eco_revision_tbl
                        ,  p_revised_item_tbl   => l_revised_item_tbl
                        ,  p_rev_component_tbl  => l_rev_component_tbl
                        ,  p_ref_designator_tbl => l_ref_designator_tbl
                        ,  p_sub_component_tbl  => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 3
                        ,  p_entity_index       => I
                        ,  x_ECO_rec            => l_ECO_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_sub_component_tbl  => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;

        END IF;

        -- Process Flow step 13 : Database Writes

        IF g_control_rec.write_to_db
        THEN
                eng_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                eng_globals.set_login_id(p_login_id => g_control_rec.last_update_login);
                --dbms_output.put_line('Writing to the database');
                ENG_Eco_Revision_Util.Perform_Writes
                (   p_eco_revision_rec          => l_eco_revision_rec
                ,   p_eco_rev_unexp_rec         => l_eco_rev_unexp_rec
                ,   p_control_rec               => g_control_rec
                ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
                ,   x_return_status             => l_return_status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 3
                        ,  p_entity_index         => I
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

        l_eco_revision_tbl(I)          := l_eco_revision_rec;

        --  For loop exception handler.


     EXCEPTION

       WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl     => l_eco_revision_tbl
                ,  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 2
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        IF l_bo_return_status = 'S'
        THEN
                l_bo_return_status     := l_return_status;
        END IF;
        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_unexp_eco_rev_rec            := l_eco_rev_unexp_rec;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN

        --dbms_output.put_line('Unexpected error generated');
        Eco_Error_Handler.Log_Error
                (  p_eco_revision_tbl     => l_eco_revision_tbl
                ,  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 2
                ,  p_entity_index         => I
                ,  x_eco_rec              => l_eco_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        x_return_status                := l_bo_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_unexp_eco_rev_rec            := l_eco_rev_unexp_rec;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;

        l_return_status := 'U';

        IF g_control_rec.write_to_db
        THEN
                RAISE;
        END IF;

  END;
  END LOOP; -- END eco revisions processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        x_return_status := l_return_status;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;


     --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_eco_rev_rec        := l_eco_rev_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Eco_Rev;

--  Eco_Header

PROCEDURE Eco_Header
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_unexp_ECO_rec                 IN  ENG_Eco_PUB.ECO_Unexposed_Rec_Type
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_unexp_ECO_rec                 IN OUT NOCOPY ENG_Eco_PUB.ECO_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_Mesg_Token_Tbl                IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type    --add
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_op_resource_Tbl_Type  --add
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_sub_resource_Tbl_Type --add
,   x_return_status                 IN OUT NOCOPY VARCHAR2
)
IS

l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_other_message         VARCHAR2(50);
l_err_text              VARCHAR2(2000);
l_valid                 BOOLEAN := TRUE;
l_Return_Status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_bo_return_status      VARCHAR2(1) := 'S';
l_ECO_Rec               Eng_Eco_Pub.ECO_Rec_Type;
l_eco_unexp_Rec         Eng_Eco_Pub.ECO_Unexposed_Rec_Type := p_unexp_eco_rec;
l_Old_ECO_Rec           Eng_Eco_Pub.ECO_Rec_Type := NULL;
l_Old_ECO_Unexp_Rec     Eng_Eco_Pub.ECO_Unexposed_Rec_Type   := NULL;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type    := p_eco_revision_tbl;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type    := p_revised_item_tbl;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type    := p_rev_component_tbl;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type   := p_ref_designator_tbl;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type    := p_sub_component_tbl;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type    := p_rev_operation_tbl;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type  := p_rev_op_resource_tbl;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type := p_rev_sub_resource_tbl;
l_return_value          NUMBER;
l_Token_Tbl             Error_Handler.Token_Tbl_Type;

--10dec
l_ECO_Rec_1               Eng_Eco_Pub.ECO_Rec_Type           := p_ECO_rec;
l_eco_unexp_Rec_1         Eng_Eco_Pub.ECO_Unexposed_Rec_Type := p_unexp_eco_rec;


EXC_SEV_QUIT_RECORD     EXCEPTION;
EXC_UNEXP_SKIP_OBJECT   EXCEPTION;

BEGIN

    -- Begin block that processes header. This block holds the exception handlers
    -- for header errors.

    BEGIN

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('start of eco_header.');
   END IF;



        l_ECO_rec := p_ECO_rec;
        l_ECO_rec.transaction_type := UPPER(l_eco_rec.transaction_type);

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        l_eco_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        -- Process Flow step 3: Verify ECO's existence
        --

        IF g_control_rec.check_existence
        THEN
/*
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('organization id is');
     error_handler.write_debug(' l_eco_unexp_rec.organization_idorganization id is');
   END IF;
*/

               --dbms_output.put_line('Checking Existence');
                ENG_Validate_Eco.Check_Existence
                ( p_change_notice       => l_eco_rec.ECO_Name
                , p_organization_id     => l_eco_unexp_rec.organization_id
                , p_organization_code   => l_eco_rec.organization_code
                , p_calling_entity      => 'ECO'
                , p_transaction_type    => l_eco_rec.transaction_type
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                , x_return_status       => l_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                END IF;
        END IF;

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('Attribute defaulting.');
   END IF;

        IF g_control_rec.attribute_defaulting AND
           l_ECO_Rec.Transaction_Type = ENG_GLOBALS.G_OPR_CREATE
        THEN

                -- Process Flow step 9: Default missing values for Operation CREATE

                --dbms_output.put_line('Attribute Defaulting');
                Eng_Default_ECO.Attribute_Defaulting
                (   p_ECO_rec           => l_ECO_Rec_1
                ,   p_Unexp_ECO_Rec     => l_ECO_Unexp_Rec_1
                ,   x_ECO_rec           => l_ECO_Rec
                ,   x_Unexp_ECO_Rec     => l_ECO_Unexp_Rec
                ,   x_Mesg_Token_Tbl    => l_Mesg_Token_Tbl
                ,   x_return_status     => l_Return_Status
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 1
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('end of Attribute defaulting..');
   END IF;


        IF g_control_rec.entity_defaulting OR
           g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('querying row');
                ENG_ECO_Util.Query_Row
                ( p_change_notice       => l_ECO_rec.eco_name
                , p_organization_id     => l_eco_unexp_rec.organization_id
                , x_eco_rec             => l_old_eco_rec
                , x_eco_unexp_rec       => l_old_eco_unexp_rec
                , x_return_status       => l_return_status
                , x_err_text            => l_err_text
                );
/*              IF l_return_status = 'F'
                THEN
                        dbms_output.put_line('queried old record');
                ELSIF l_return_status = 'N'
                THEN
                        dbms_output.put_line('old record not found');
                END IF;*/
        END IF;
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('end of query row..');
   END IF;


     -- Process Flow step 11 - Entity Level Defaulting

        IF g_control_rec.entity_defaulting
        THEN
                --dbms_output.put_line('Entity Defaulting');

                ENG_Default_ECO.Entity_Defaulting
                (   p_ECO_rec            => l_ECO_rec
                ,   p_Unexp_ECO_rec      => l_ECO_unexp_rec
                ,   p_Old_ECO_rec        => l_old_ECO_rec
                ,   p_Old_Unexp_ECO_rec  => l_old_ECO_unexp_rec
                ,   p_control_rec        => g_control_rec
                ,   x_ECO_rec            => l_ECO_rec
                ,   x_Unexp_ECO_rec      => l_ECO_unexp_rec
                ,   x_return_status      => l_return_status
                ,   x_Mesg_Token_Tbl     => l_Mesg_Token_Tbl
                );

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN                       RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 1
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

     -- Process Flow step 12 - Entity Level Validation
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After Entity default..');
   END IF;

      IF g_control_rec.entity_validation
        THEN
                --dbms_output.put_line('Entity validation');
                IF l_eco_rec.transaction_type = 'DELETE'
                THEN
                        ENG_Validate_ECO.Check_Delete
                        ( p_eco_rec             => l_eco_rec
                        , p_Unexp_ECO_rec       => l_ECO_Unexp_Rec
                        , x_return_status       => l_return_status
                        , x_Mesg_Token_Tbl      => l_Mesg_Token_Tbl
                        );

                ELSE
   IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('Before check entiry..');
   END IF;
                        Eng_Validate_ECO.Check_Entity
                        (  x_return_status        => l_Return_Status
                        ,  x_err_text             => l_err_text
                        ,  x_Mesg_Token_Tbl       => l_Mesg_Token_Tbl
                        ,  p_ECO_rec              => l_ECO_Rec
                        ,  p_Unexp_ECO_Rec        => l_ECO_Unexp_Rec
                        ,  p_old_ECO_rec          => l_old_ECO_rec
                        ,  p_old_unexp_ECO_rec    => l_old_ECO_unexp_rec
                        ,  p_control_rec          => g_control_rec
                        );
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After check entity..');


   END IF;
                END IF;

                --dbms_output.put_line('return_status: ' || l_return_status);

                IF l_return_status = Error_Handler.G_STATUS_ERROR
                THEN
                        RAISE EXC_SEV_QUIT_RECORD;
                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec              => l_ECO_rec
                        ,  p_eco_revision_tbl     => l_eco_revision_tbl
                        ,  p_revised_item_tbl     => l_revised_item_tbl
                        ,  p_rev_component_tbl    => l_rev_component_tbl
                        ,  p_ref_designator_tbl   => l_ref_designator_tbl
                        ,  p_sub_component_tbl    => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl       => l_mesg_token_tbl
                        ,  p_error_status         => 'W'
                        ,  p_error_level          => 1
                        ,  x_ECO_rec              => l_ECO_rec
                        ,  x_eco_revision_tbl     => l_eco_revision_tbl
                        ,  x_revised_item_tbl     => l_revised_item_tbl
                        ,  x_rev_component_tbl    => l_rev_component_tbl
                        ,  x_ref_designator_tbl   => l_ref_designator_tbl
                        ,  x_sub_component_tbl    => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After check entity..');
END IF;


        -- Process Flow step 13 : Database Writes
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('Before write to db..');
END IF;

        IF g_control_rec.write_to_db
        THEN
                eng_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
                eng_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('write_to db is true');
END IF;


                --dbms_output.put_line('Writing to the database');
                ENG_ECO_Util.Perform_Writes
                (   p_ECO_rec          => l_ECO_rec
                ,   p_Unexp_ECO_rec    => l_ECO_unexp_rec
                ,   p_old_ECO_rec      => l_old_ECO_rec
                ,   p_control_rec      => g_control_rec
                ,   x_Mesg_Token_Tbl   => l_Mesg_Token_Tbl
                ,   x_return_status    => l_return_status
                );
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('After write to db..');
END IF;


                IF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
                        RAISE EXC_UNEXP_SKIP_OBJECT;
                ELSIF l_return_status ='S' AND
                      l_Mesg_Token_Tbl.COUNT <>0
                THEN
                        Eco_Error_Handler.Log_Error
                        (  p_ECO_rec            => l_ECO_rec
                        ,  p_eco_revision_tbl   => l_eco_revision_tbl
                        ,  p_revised_item_tbl   => l_revised_item_tbl
                        ,  p_rev_component_tbl  => l_rev_component_tbl
                        ,  p_ref_designator_tbl => l_ref_designator_tbl
                        ,  p_sub_component_tbl  => l_sub_component_tbl
                        ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        ,  p_mesg_token_tbl     => l_mesg_token_tbl
                        ,  p_error_status       => 'W'
                        ,  p_error_level        => 1
                        ,  x_ECO_rec            => l_ECO_rec
                        ,  x_eco_revision_tbl   => l_eco_revision_tbl
                        ,  x_revised_item_tbl   => l_revised_item_tbl
                        ,  x_rev_component_tbl  => l_rev_component_tbl
                        ,  x_ref_designator_tbl => l_ref_designator_tbl
                        ,  x_sub_component_tbl  => l_sub_component_tbl
                        ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                        ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                        ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                        );
                END IF;
        END IF;

  EXCEPTION

    WHEN EXC_SEV_QUIT_RECORD THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec              => l_ECO_rec
                ,  p_eco_revision_tbl     => l_eco_revision_tbl
                ,  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_ERROR
                ,  p_error_scope          => Error_Handler.G_SCOPE_RECORD
                ,  p_error_level          => 1
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );
--dbms_output.put_line('logged error: ' || l_return_Status);
        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_unexp_ECO_rec                := l_eco_unexp_Rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add

        RETURN;

    WHEN EXC_UNEXP_SKIP_OBJECT THEN
       Eco_Error_Handler.Log_Error
                (  p_ECO_rec            => l_ECO_rec
                ,  p_eco_revision_tbl   => l_eco_revision_tbl
                ,  p_revised_item_tbl   => l_revised_item_tbl
                ,  p_rev_component_tbl  => l_rev_component_tbl
                ,  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 1
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl    --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl  --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl --add
                );

        x_return_status                := l_return_status;
        x_Mesg_Token_Tbl               := l_Mesg_Token_Tbl;
        x_ECO_rec                      := l_ECO_rec;
        x_unexp_ECO_rec                := l_eco_unexp_Rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;    --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;  --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl; --add

        l_return_status := 'U';

        IF g_control_rec.write_to_db
        THEN
                RAISE;
        END IF;

  END; -- END Header processing block

    IF l_return_status in ('Q', 'U')
    THEN
        x_return_status := l_return_status;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        RETURN;
    END IF;

    l_bo_return_status := l_return_status;


     --  Load OUT parameters

     x_return_status            := l_bo_return_status;
     x_ECO_rec                  := l_ECO_rec;
     x_unexp_ECO_rec            := l_eco_unexp_Rec;
     x_eco_revision_tbl         := l_eco_revision_tbl;
     x_revised_item_tbl         := l_revised_item_tbl;
     x_rev_component_tbl        := l_rev_component_tbl;
     x_ref_designator_tbl       := l_ref_designator_tbl;
     x_sub_component_tbl        := l_sub_component_tbl;
     x_rev_operation_tbl        := l_rev_operation_tbl;    --add
     x_rev_op_resource_tbl      := l_rev_op_resource_tbl;  --add
     x_rev_sub_resource_tbl     := l_rev_sub_resource_tbl; --add
     x_Mesg_Token_Tbl           := l_Mesg_Token_Tbl;

END Eco_Header;


--  Start of Comments
--  API name    Process_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--        11-SEP-2000 Modified by Masahiko Mochizuki
--  End of Comments

PROCEDURE Process_Eco
(   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_msg_count                     IN OUT NOCOPY NUMBER
,   p_control_rec                   IN  BOM_BO_PUB.Control_Rec_Type
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_unexp_eco_rec                 IN  ENG_Eco_PUB.ECO_Unexposed_Rec_Type := NULL
,   p_unexp_rev_item_rec            IN  ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type := NULL
,   p_unexp_rev_comp_rec            IN  BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type := NULL
,   p_unexp_eco_rev_rec             IN  ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type := NULL
,   p_unexp_sub_comp_rec            IN  BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type := NULL
,   p_unexp_ref_desg_rec            IN  BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type := NULL
,   p_unexp_rev_op_rec              IN  BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type := NULL
,   p_unexp_rev_op_res_rec          IN  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type := NULL
,   p_unexp_rev_sub_res_rec         IN  BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type := NULL
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                        BOM_BO_PUB.G_MISS_SUB_COMPONENT_TBL
,   p_rev_operation_tbl             IN  BOM_RTG_PUB.Rev_Operation_Tbl_Type:=
                                        BOM_RTG_PUB.G_MISS_REV_OPERATION_TBL
,   p_rev_op_resource_tbl           IN  BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type :=
                                        BOM_RTG_PUB.G_MISS_REV_OP_RESOURCE_TBL
,   p_rev_sub_resource_tbl          IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type:=
                                        BOM_RTG_PUB.G_MISS_REV_SUB_RESOURCE_TBL
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type --ECO 10dec
,   x_unexp_ECO_rec                 IN OUT NOCOPY ENG_Eco_PUB.ECO_Unexposed_Rec_Type
,   x_unexp_eco_rev_rec             IN OUT NOCOPY ENG_Eco_PUB.Eco_Rev_Unexposed_Rec_Type
,   x_unexp_revised_item_rec        IN OUT NOCOPY ENG_Eco_PUB.Rev_Item_Unexposed_Rec_Type
,   x_unexp_rev_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_unexp_sub_comp_rec            IN OUT NOCOPY BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
,   x_unexp_ref_desg_rec            IN OUT NOCOPY BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
,   x_unexp_rev_op_rec              IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type
,   x_unexp_rev_op_res_rec          IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type
,   x_unexp_rev_sub_res_rec         IN OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_rev_operation_tbl             IN OUT NOCOPY BOM_RTG_PUB.Rev_Operation_Tbl_Type
,   x_rev_op_resource_tbl           IN OUT NOCOPY BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type
,   x_rev_sub_resource_tbl          IN OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type
,   x_disable_revision              OUT NOCOPY NUMBER --Bug no:3034642
)
IS
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Eco';
l_err_text                    VARCHAR2(240);
l_return_status               VARCHAR2(1);
l_bo_return_status            VARCHAR2(1);

l_control_rec                 BOM_BO_PUB.Control_Rec_Type;

l_ECO_rec                     ENG_Eco_PUB.Eco_Rec_Type := p_ECO_rec;
l_unexp_eco_rec               ENG_Eco_PUB.ECO_Unexposed_Rec_Type := p_unexp_eco_rec;
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;
l_eco_revision_tbl            ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_rec            ENG_Eco_PUB.Revised_Item_Rec_Type;
l_revised_item_tbl            ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_rec           BOM_BO_PUB.Rev_Component_Rec_Type;
l_rev_component_tbl           BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_rec          BOM_BO_PUB.Ref_Designator_Rec_Type;
l_ref_designator_tbl          BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_rec           BOM_BO_PUB.Sub_Component_Rec_Type;
l_sub_component_tbl           BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl           BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl         BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl        BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add
l_rev_operation_rec           BOM_RTG_PUB.Rev_Operation_Rec_Type;     --add
l_rev_op_resource_rec         BOM_RTG_PUB.Rev_Op_Resource_Rec_Type;   --add
l_rev_sub_resource_rec        BOM_RTG_PUB.Rev_Sub_Resource_Rec_Type;  --add

l_mesg_token_tbl              Error_Handler.Mesg_Token_Tbl_Type;
l_other_message               VARCHAR2(2000);
l_other_token_tbl             Error_Handler.Token_Tbl_Type;

EXC_ERR_PVT_API_MAIN          EXCEPTION;

BEGIN

    --dbms_output.enable(1000000);

    --  Standard call to check for call compatibility

   IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('here, for test purpose, you can write message.');
   END IF;

    --dbms_output.put_line('The following objects will be processed as part of the same business object');
    --dbms_output.put_line('| ECO : ' || l_ECO_rec.eco_name);
    --dbms_output.put_line('| ECO REVISIONS : ' || to_char(p_eco_revision_tbl.COUNT));
    --dbms_output.put_line('| REVISED ITEMS : ' || to_char(p_revised_item_tbl.COUNT));
    --dbms_output.put_line('| REVISED COMPS : ' || to_char(p_rev_component_tbl.COUNT));
    --dbms_output.put_line('| SUBS. COMPS   : ' || to_Char(p_sub_component_tbl.COUNT));
    --dbms_output.put_line('| REFD. DESGS         : ' || to_char(p_ref_designator_tbl.COUNT));
    --dbms_output.put_line('|----------------------------------------------------');

    --dbms_output.put_line('Assigning control record to global variable');

  -- Init Global variables.
    g_control_rec := p_control_rec;

    bom_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
    bom_rtg_globals.set_user_id(p_user_id => g_control_rec.last_updated_by);
    bom_globals.set_login_id(p_login_id => g_control_rec.last_update_login);
    bom_rtg_globals.set_login_id(p_login_id => g_control_rec.last_update_login);

   -- bug 3583789 ,Bo_Identifier needs to be set for all the errors/warnings to be shown in the form --vani
    Eng_Globals.Set_Bo_Identifier(p_bo_identifier       => 'ECO');

    --  Init local variables

    l_ECO_rec                      := p_ECO_rec;

    --  Init local table variables.

    l_eco_revision_tbl             := p_eco_revision_tbl;
    l_revised_item_tbl             := p_revised_item_tbl;
    l_rev_component_tbl            := p_rev_component_tbl;
    l_ref_designator_tbl           := p_ref_designator_tbl;
    l_sub_component_tbl            := p_sub_component_tbl;
    l_rev_operation_tbl                 := p_rev_operation_tbl;         --add
    l_rev_op_resource_tbl              := p_rev_op_resource_tbl;        --add
    l_rev_sub_resource_tbl            := p_rev_sub_resource_tbl;        --add

    -- Initialize System_Information Unit_Effectivity flag

    IF PJM_UNIT_EFF.ENABLED = 'Y'
    THEN
        ENG_Globals.Set_Unit_Effectivity (TRUE);
    ELSE
        ENG_Globals.Set_Unit_Effectivity (FALSE);
    END IF;

--  Added by AS on 03/17/99 to fix bug 852322
    l_bo_return_status := 'S';

    --  Eco

/*   Bom_Globals.Set_Debug('Y');
    Error_Handler.Open_Debug_Session
	(p_debug_filename	=> 'form_debug.log'
         , p_output_dir		=> '/sqlcom/log/dom1151'
         , x_return_status	=> l_return_status
         , p_mesg_token_tbl	=> l_mesg_token_tbl
         , x_mesg_Token_tbl	=> l_mesg_token_tbl
	);
*/

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('here, for test purpose, you can write message.');
   END IF;

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_ECO
    THEN
        --dbms_output.put_line('PVT API: Calling ECO_Header');

        Eco_Header
        (   p_ECO_rec                   => l_ECO_rec
        ,   p_unexp_eco_rec             => l_unexp_eco_rec
        ,   p_eco_revision_tbl          => l_eco_revision_tbl
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl        --add
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl      --add
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl     --add
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_eco_rec             => x_unexp_eco_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status       );

        --dbms_output.put_line('eco hdr return status: ' || l_eco_rec.return_status);

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('end of ECO header in Process_ECO..');
     error_handler.write_debug('here, the process entity is:');
     error_handler.write_debug( g_control_rec.process_entity);
     error_handler.write_debug( ENG_GLOBALS.G_ENTITY_ECO);


END IF;

--error_Handler.Close_Debug_Session;


   --dbms_output.put_line('BO error status: ' || l_bo_return_status);

    --  Eco

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_ECO_REVISION
    THEN
        --dbms_output.put_line('PVT API: Calling ECO_Header');

        Eco_Rev
        (   p_eco_revision_tbl          => l_eco_revision_tbl
        ,   p_unexp_eco_rev_rec         => p_unexp_eco_rev_rec
        ,   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl        --add
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl      --add
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl     --add
        ,   x_eco_rec                   => l_eco_rec
        ,   x_unexp_eco_rev_rec         => x_unexp_eco_rev_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        );

        --dbms_output.put_line('eco revisions return status: ' || l_eco_revision_tbl(1).return_status);

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

    --  Revised Items

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REVISED_ITEM
    THEN
        --dbms_output.put_line('PVT API: Calling Rev_Items');

        Rev_Items
        (   p_revised_item_tbl          => l_revised_item_tbl
        ,   p_unexp_rev_item_rec        => p_unexp_rev_item_rec
        ,   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   p_rev_operation_tbl         => l_rev_operation_tbl        --add
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl      --add
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl     --add
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_rev_item_rec        => x_unexp_revised_item_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
	,   x_disable_revision          =>  x_disable_revision  --Bug no:3034642
        ) ;

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('after rev_items, the return status is');
     error_handler.write_debug(l_return_status);
   END IF;

        --dbms_output.put_line('rev items return status: ' || l_revised_item_tbl(1).return_status);

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);

    --  Revised Components

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REV_COMPONENT
    THEN
        --dbms_output.put_line('PVT API: Calling Rev_Comps');

        Rev_Comps
        (   p_rev_component_tbl         => l_rev_component_tbl
        ,   p_unexp_rev_comp_rec        => p_unexp_rev_comp_rec
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_rev_comp_rec        => x_unexp_rev_comp_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        --dbms_output.put_line('rev comps return status: ' || l_return_status);
--dbms_output.put_line('main item num: ' || to_char(l_rev_component_tbl(1).item_sequence_number));
        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);

    --  Reference Designators

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REF_DESIGNATOR
    THEN
        --dbms_output.put_line('PVT API: Calling Sub_Comps');

        Ref_Desgs
        (   p_unexp_ref_desg_rec        => p_unexp_ref_desg_rec
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_ref_desg_rec        => x_unexp_ref_desg_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        --dbms_output.put_line('ref desgs return status: ' || l_ref_designator_tbl(1).return_status);

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);

    --  Substitute Components

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_SUB_COMPONENT
    THEN
        --dbms_output.put_line('PVT API: Calling Sub_Comps');

        Sub_Comps
        (   p_unexp_sub_comp_rec        => p_unexp_sub_comp_rec
        ,   p_ref_designator_tbl        => l_ref_designator_tbl
        ,   p_sub_component_tbl         => l_sub_component_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_sub_comp_rec        => x_unexp_sub_comp_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl         --add
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl       --add
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl      --add
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        --dbms_output.put_line('sub comps return status: ' || l_sub_component_tbl(1).return_status);

        -- Added by AS on 03/22/99 to fix bug 853529

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        --  Added by AS on 03/17/99 to fix bug 852322
        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);

-- Added by Masahiko Mochizuki on 09/11/00

    --  Revised Operations

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REV_OPERATION
    THEN
        --dbms_output.put_line('PVT API: Calling Rev_Ops');


       Rev_Ops
        (   p_rev_operation_tbl         => l_rev_operation_tbl
        ,   p_unexp_rev_op_rec          => p_unexp_rev_op_rec
        ,   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_rev_op_rec          => x_unexp_rev_op_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);


-- Added by Masahiko Mochizuki on 09/11/00

    --  Revised Operation Resources

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REV_OP_RESOURCE
    THEN
        --dbms_output.put_line('PVT API: Calling Rev_Op_Res');


       Rev_Op_Res
        (   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_unexp_rev_op_res_rec      => p_unexp_rev_op_res_rec
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_rev_op_res_rec      => x_unexp_rev_op_res_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);


-- Added by Masahiko Mochizuki on 09/11/00

    --  Revised Sub Operation Resources

    IF  g_control_rec.process_entity = ENG_GLOBALS.G_ENTITY_REV_SUB_RESOURCE
    THEN
        --dbms_output.put_line('PVT API: Calling Rev_Sub_Res');


       Rev_Sub_Res
        (   p_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   p_unexp_rev_sub_res_rec     => p_unexp_rev_sub_res_rec
        ,   p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_ECO_rec                   => l_ECO_rec
        ,   x_unexp_rev_sub_res_rec     => x_unexp_rev_sub_res_rec
        ,   x_eco_revision_tbl          => l_eco_revision_tbl
        ,   x_revised_item_tbl          => l_revised_item_tbl
        ,   x_rev_component_tbl         => l_rev_component_tbl
        ,   x_ref_designator_tbl        => l_ref_designator_tbl
        ,   x_sub_component_tbl         => l_sub_component_tbl
        ,   x_rev_operation_tbl         => l_rev_operation_tbl
        ,   x_rev_op_resource_tbl       => l_rev_op_resource_tbl
        ,   x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl
        ,   x_Mesg_Token_Tbl            => l_Mesg_Token_Tbl
        ,   x_return_status             => l_return_status
        ) ;

        IF NVL(l_return_status, 'S') = 'Q'
        THEN
                l_return_status := 'F';
                RAISE G_EXC_QUIT_IMPORT;
        ELSIF NVL(l_return_status, 'S') = 'U'
        THEN
                RAISE G_EXC_QUIT_IMPORT;

        ELSIF NVL(l_return_status, 'S') <> 'S'
        THEN
                l_bo_return_status := l_return_status;
        END IF;

   END IF;

   --dbms_output.put_line('BO error status: ' || l_bo_return_status);


    --  Done processing, load OUT parameters.
   --  Added by AS on 03/17/99 to fix bug 852322
    x_return_status                := l_bo_return_status;

    x_ECO_rec                      := l_ECO_rec;
    x_eco_revision_tbl             := l_eco_revision_tbl;
    x_revised_item_tbl             := l_revised_item_tbl;
    x_rev_component_tbl            := l_rev_component_tbl;
    x_ref_designator_tbl           := l_ref_designator_tbl;
    x_sub_component_tbl            := l_sub_component_tbl;
    x_rev_operation_tbl            := l_rev_operation_tbl;         --add
    x_rev_op_resource_tbl          := l_rev_op_resource_tbl;       --add
    x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;      --add

    -- Reset system_information business object flags

IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('before set global variables.');
   END IF;

    ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
    ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
    ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
    ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
    ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
    ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
    ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
    ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);
IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('end of process_eco');
   END IF;

EXCEPTION

    WHEN EXC_ERR_PVT_API_MAIN THEN

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec            => l_ECO_rec
                ,  p_eco_revision_tbl   => l_eco_revision_tbl
                ,  p_revised_item_tbl   => l_revised_item_tbl
                ,  p_rev_component_tbl  => l_rev_component_tbl
                ,  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_rev_operation_tbl     => l_rev_operation_tbl       --add
                ,  p_rev_op_resource_tbl   => l_rev_op_resource_tbl     --add
                ,  p_rev_sub_resource_tbl  => l_rev_sub_resource_tbl    --add
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 0
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl     => l_rev_operation_tbl      --add
                ,  x_rev_op_resource_tbl   => l_rev_op_resource_tbl    --add
                ,  x_rev_sub_resource_tbl  => l_rev_sub_resource_tbl   --add
                );

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;         --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;       --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;      --add


        -- Reset system_information business object flags

        ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
        ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
        ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
        ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
        ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
        ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
        ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
        ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN G_EXC_QUIT_IMPORT THEN

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            :=  l_rev_operation_tbl;         --add
        x_rev_op_resource_tbl          :=  l_rev_op_resource_tbl;       --add
        x_rev_sub_resource_tbl         :=  l_rev_sub_resource_tbl;      --add

        -- Reset system_information business object flags

        ENG_GLOBALS.Set_ECO_Impl( p_eco_impl        => NULL);
        ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl      => NULL);
        ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process=> NULL);
        ENG_GLOBALS.Set_ECO_Access( p_eco_access    => NULL);
        ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
        ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
        ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
        ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

    WHEN OTHERS THEN


IF BOM_Globals.get_debug = 'Y'
   Then
     error_handler.write_debug('error in process_eco.');
   END IF;
   Error_Handler.Close_Debug_Session;

        IF g_control_rec.write_to_db
        THEN
                RAISE;
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                l_err_text := G_PKG_NAME || ' : Process ECO '
                        || substrb(SQLERRM,1,200);
                Error_Handler.Add_Error_Token
                        ( p_Message_Text => l_err_text
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        );
        END IF;

        Eco_Error_Handler.Log_Error
                (  p_ECO_rec            => l_ECO_rec
                ,  p_eco_revision_tbl   => l_eco_revision_tbl
                ,  p_revised_item_tbl   => l_revised_item_tbl
                ,  p_rev_component_tbl  => l_rev_component_tbl
                ,  p_ref_designator_tbl => l_ref_designator_tbl
                ,  p_sub_component_tbl  => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl       --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl     --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl    --add
                ,  p_mesg_token_tbl     => l_mesg_token_tbl
                ,  p_error_status       => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status       => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message      => l_other_message
                ,  p_other_token_tbl    => l_other_token_tbl
                ,  p_error_level        => 0
                ,  x_ECO_rec            => l_ECO_rec
                ,  x_eco_revision_tbl   => l_eco_revision_tbl
                ,  x_revised_item_tbl   => l_revised_item_tbl
                ,  x_rev_component_tbl  => l_rev_component_tbl
                ,  x_ref_designator_tbl => l_ref_designator_tbl
                ,  x_sub_component_tbl  => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl         --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl       --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl      --add
                );

        x_return_status                := l_return_status;
        x_ECO_rec                      := l_ECO_rec;
        x_eco_revision_tbl             := l_eco_revision_tbl;
        x_revised_item_tbl             := l_revised_item_tbl;
        x_rev_component_tbl            := l_rev_component_tbl;
        x_ref_designator_tbl           := l_ref_designator_tbl;
        x_sub_component_tbl            := l_sub_component_tbl;
        x_rev_operation_tbl            := l_rev_operation_tbl;         --add
        x_rev_op_resource_tbl          := l_rev_op_resource_tbl;       --add
        x_rev_sub_resource_tbl         := l_rev_sub_resource_tbl;      --add

        -- Reset system_information business object flags

        ENG_GLOBALS.Set_ECO_Impl( p_eco_impl         => NULL);
        ENG_GLOBALS.Set_ECO_Cancl( p_eco_cancl       => NULL);
        ENG_GLOBALS.Set_Wkfl_Process( p_wkfl_process => NULL);
        ENG_GLOBALS.Set_ECO_Access( p_eco_access     => NULL);
        ENG_GLOBALS.Set_STD_Item_Access( p_std_item_access => NULL);
        ENG_GLOBALS.Set_MDL_Item_Access( p_mdl_item_access => NULL);
        ENG_GLOBALS.Set_PLN_Item_Access( p_pln_item_access => NULL);
        ENG_GLOBALS.Set_OC_Item_Access( p_oc_item_access   => NULL);

END process_Eco;

--  Start of Comments
--  API name    Lock_Eco
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Eco
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 IN OUT NOCOPY VARCHAR2
,   x_msg_count                     IN OUT NOCOPY NUMBER
,   x_msg_data                      IN OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REC
,   p_eco_revision_tbl              IN  ENG_Eco_PUB.Eco_Revision_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_ECO_REVISION_TBL
,   p_revised_item_tbl              IN  ENG_Eco_PUB.Revised_Item_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REVISED_ITEM_TBL
,   p_rev_component_tbl             IN  BOM_BO_PUB.Rev_Component_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REV_COMPONENT_TBL
,   p_ref_designator_tbl            IN  BOM_BO_PUB.Ref_Designator_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_REF_DESIGNATOR_TBL
,   p_sub_component_tbl             IN  BOM_BO_PUB.Sub_Component_Tbl_Type :=
                                        ENG_Eco_PUB.G_MISS_SUB_COMPONENT_TBL
,   x_ECO_rec                       IN OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_eco_revision_tbl              IN OUT NOCOPY ENG_Eco_PUB.Eco_Revision_Tbl_Type
,   x_revised_item_tbl              IN OUT NOCOPY ENG_Eco_PUB.Revised_Item_Tbl_Type
,   x_rev_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_ref_designator_tbl            IN OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_sub_component_tbl             IN OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_err_text                      IN OUT NOCOPY VARCHAR2
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Eco';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_eco_revision_rec            ENG_Eco_PUB.Eco_Revision_Rec_Type;
l_revised_item_rec            ENG_Eco_PUB.Revised_Item_Rec_Type;
l_rev_component_rec           BOM_BO_PUB.Rev_Component_Rec_Type;
l_ref_designator_rec          BOM_BO_PUB.Ref_Designator_Rec_Type;
l_sub_component_rec           BOM_BO_PUB.Sub_Component_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

NULL;

/*********************** Temporarily commented *****************************

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Eco_PVT;

    --  Lock ECO

    IF p_ECO_rec.operation = ENG_GLOBALS.G_OPR_LOCK THEN

        ENG_Eco_Util.Lock_Row
        (   p_ECO_rec                     => p_ECO_rec
        ,   x_ECO_rec                     => x_ECO_rec
        ,   x_return_status               => l_return_status
        ,   x_err_text                    => x_err_text
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock eco_revision

    FOR I IN 1..p_eco_revision_tbl.COUNT LOOP

        IF p_eco_revision_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Eco_Revision_Util.Lock_Row
            (   p_eco_revision_rec            => p_eco_revision_tbl(I)
            ,   x_eco_revision_rec            => l_eco_revision_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                          => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_eco_revision_tbl(I)          := l_eco_revision_rec;

        END IF;

    END LOOP;

    --  Lock revised_item

    FOR I IN 1..p_revised_item_tbl.COUNT LOOP

        IF p_revised_item_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Revised_Item_Util.Lock_Row
            (   p_revised_item_rec            => p_revised_item_tbl(I)
            ,   x_revised_item_rec            => l_revised_item_rec
            ,   x_return_status               => l_return_status
            ,   x_err_text                    => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_revised_item_tbl(I)          := l_revised_item_rec;

        END IF;

    END LOOP;

    --  Lock rev_component

    FOR I IN 1..p_rev_component_tbl.COUNT LOOP

        IF p_rev_component_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Rev_Component_Util.Lock_Row
            (   p_rev_component_rec           => p_rev_component_tbl(I)
            ,   x_rev_component_rec           => l_rev_component_rec
            ,   x_return_status               => l_return_status
                ,   x_err_text                      => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_rev_component_tbl(I)         := l_rev_component_rec;

        END IF;

    END LOOP;

    --  Lock ref_designator

    FOR I IN 1..p_ref_designator_tbl.COUNT LOOP

        IF p_ref_designator_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Ref_Designator_Util.Lock_Row
            (   p_ref_designator_rec          => p_ref_designator_tbl(I)
            ,   x_ref_designator_rec          => l_ref_designator_rec
            ,   x_return_status               => l_return_status
              ,   x_err_text                        => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_ref_designator_tbl(I)        := l_ref_designator_rec;

        END IF;

    END LOOP;

    --  Lock sub_component

    FOR I IN 1..p_sub_component_tbl.COUNT LOOP

        IF p_sub_component_tbl(I).operation = ENG_GLOBALS.G_OPR_LOCK THEN

            ENG_Sub_Component_Util.Lock_Row
            (   p_sub_component_rec           => p_sub_component_tbl(I)
            ,   x_sub_component_rec           => l_sub_component_rec
            ,   x_return_status               => l_return_status
                ,   x_err_text                      => x_err_text
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_sub_component_tbl(I)         := l_sub_component_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
       --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Eco'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Eco_PVT;

****************************************************************************/

END Lock_Eco;

END ENG_Form_Eco_PVT;


/
