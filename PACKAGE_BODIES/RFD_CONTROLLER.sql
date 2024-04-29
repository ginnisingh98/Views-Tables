--------------------------------------------------------
--  DDL for Package Body RFD_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RFD_CONTROLLER" AS
/* $Header: ENGCRFDB.pls 115.7 2003/07/08 12:28:13 akumar ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_RFD_rec        IN  Controller_RFD_Rec_Type
,   x_RFD_tbl                   OUT NOCOPY BOM_BO_PUB.Ref_Designator_Tbl_Type
,   x_unexp_RFD_rec             OUT NOCOPY BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_RFD_tbl(1).eco_name           := p_controller_RFD_rec.change_notice;
        x_RFD_tbl(1).organization_code  := p_controller_RFD_rec.organization_code;
        x_RFD_tbl(1).revised_item_name  := p_controller_RFD_rec.revised_item_name;
        x_RFD_tbl(1).new_revised_item_revision  := p_controller_RFD_rec.new_revised_item_revision;
        x_RFD_tbl(1).start_effective_date       := p_controller_RFD_rec.start_effective_date;
        x_RFD_tbl(1).operation_sequence_number  := p_controller_RFD_rec.operation_sequence_number;
        x_RFD_tbl(1).Component_Item_Name        := p_controller_RFD_rec.component_item_name;
        x_RFD_tbl(1).Alternate_BOM_Code         := p_controller_RFD_rec.alternate_bom_code;
        x_RFD_tbl(1).acd_type                   := p_controller_RFD_rec.acd_type;
        x_RFD_tbl(1).reference_designator_name  := p_controller_RFD_rec.reference_designator_name;
        x_RFD_tbl(1).ref_designator_comment     := p_controller_RFD_rec.ref_designator_comment;
        x_RFD_tbl(1).attribute_category         := p_controller_RFD_rec.attribute_category;
        x_RFD_tbl(1).attribute1                 := p_controller_RFD_rec.attribute1;
        x_RFD_tbl(1).attribute2                 := p_controller_RFD_rec.attribute2;
        x_RFD_tbl(1).attribute3                 := p_controller_RFD_rec.attribute3;
        x_RFD_tbl(1).attribute4                 := p_controller_RFD_rec.attribute4;
        x_RFD_tbl(1).attribute5                 := p_controller_RFD_rec.attribute5;
        x_RFD_tbl(1).attribute6                 := p_controller_RFD_rec.attribute6;
        x_RFD_tbl(1).attribute7                 := p_controller_RFD_rec.attribute7;
        x_RFD_tbl(1).attribute8                 := p_controller_RFD_rec.attribute8;
        x_RFD_tbl(1).attribute9                 := p_controller_RFD_rec.attribute9;
        x_RFD_tbl(1).attribute10                := p_controller_RFD_rec.attribute10;
        x_RFD_tbl(1).attribute11                := p_controller_RFD_rec.attribute11;
        x_RFD_tbl(1).attribute12                := p_controller_RFD_rec.attribute12;
        x_RFD_tbl(1).attribute13                := p_controller_RFD_rec.attribute13;
        x_RFD_tbl(1).attribute14                := p_controller_RFD_rec.attribute14;
        x_RFD_tbl(1).attribute15                := p_controller_RFD_rec.attribute15;

        -- Create unexposed record

        x_unexp_RFD_rec.organization_id := p_controller_RFD_rec.organization_id;
        x_unexp_RFD_rec.component_item_id := p_controller_RFD_rec.component_item_id;
        x_unexp_RFD_rec.component_sequence_id := p_controller_RFD_rec.component_sequence_id;
        x_unexp_RFD_rec.bill_sequence_id := p_controller_RFD_rec.bill_sequence_id;
        x_unexp_RFD_rec.revised_item_id := p_controller_RFD_rec.revised_item_id;
        x_unexp_RFD_rec.revised_item_sequence_id := p_controller_RFD_rec.revised_item_sequence_id;
END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_RFD_tbl                   IN  BOM_BO_PUB.Ref_Designator_Tbl_Type
,   p_unexp_RFD_rec             IN  BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type
,   x_controller_RFD_rec        OUT NOCOPY Controller_RFD_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_RFD_rec.change_notice := p_RFD_tbl(1).eco_name;
        x_controller_RFD_rec.organization_code := p_RFD_tbl(1).organization_code;
        x_controller_RFD_rec.revised_item_name := p_RFD_tbl(1).revised_item_name;
        x_controller_RFD_rec.new_revised_item_revision := p_RFD_tbl(1).new_revised_item_revision;
        x_controller_RFD_rec.start_effective_date := p_RFD_tbl(1).start_effective_date;
        x_controller_RFD_rec.operation_sequence_number := p_RFD_tbl(1).operation_sequence_number;
        x_controller_RFD_rec.Component_Item_Name := p_RFD_tbl(1).component_item_name;
        x_controller_RFD_rec.Alternate_BOM_Code := p_RFD_tbl(1).alternate_bom_code;
        x_controller_RFD_rec.acd_type := p_RFD_tbl(1).acd_type;
        x_controller_RFD_rec.reference_designator_name := p_RFD_tbl(1).reference_designator_name;
        x_controller_RFD_rec.ref_designator_comment     := p_RFD_tbl(1).ref_designator_comment;
        x_controller_RFD_rec.attribute_category         := p_RFD_tbl(1).attribute_category;
        x_controller_RFD_rec.attribute1                 := p_RFD_tbl(1).attribute1;
        x_controller_RFD_rec.attribute2                 := p_RFD_tbl(1).attribute2;
        x_controller_RFD_rec.attribute3                 := p_RFD_tbl(1).attribute3;
        x_controller_RFD_rec.attribute4                 := p_RFD_tbl(1).attribute4;
        x_controller_RFD_rec.attribute5                 := p_RFD_tbl(1).attribute5;
        x_controller_RFD_rec.attribute6                 := p_RFD_tbl(1).attribute6;
        x_controller_RFD_rec.attribute7                 := p_RFD_tbl(1).attribute7;
        x_controller_RFD_rec.attribute8                 := p_RFD_tbl(1).attribute8;
        x_controller_RFD_rec.attribute9                 := p_RFD_tbl(1).attribute9;
        x_controller_RFD_rec.attribute10                := p_RFD_tbl(1).attribute10;
        x_controller_RFD_rec.attribute11                := p_RFD_tbl(1).attribute11;
        x_controller_RFD_rec.attribute12                := p_RFD_tbl(1).attribute12;
        x_controller_RFD_rec.attribute13                := p_RFD_tbl(1).attribute13;
        x_controller_RFD_rec.attribute14                := p_RFD_tbl(1).attribute14;
        x_controller_RFD_rec.attribute15                := p_RFD_tbl(1).attribute15;
        x_controller_RFD_rec.organization_id := p_unexp_RFD_rec.organization_id;
        x_controller_RFD_rec.component_item_id := p_unexp_RFD_rec.component_item_id;
        x_controller_RFD_rec.component_sequence_id := p_unexp_RFD_rec.component_sequence_id;
        x_controller_RFD_rec.bill_sequence_id := p_unexp_RFD_rec.bill_sequence_id;
        x_controller_RFD_rec.revised_item_id := p_unexp_RFD_rec.revised_item_id;
        x_controller_RFD_rec.revised_item_sequence_id := p_unexp_RFD_rec.revised_item_sequence_id;
END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_RFD_controller_rec        IN  Controller_RFD_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_RFD_controller_rec        IN OUT NOCOPY Controller_RFD_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RFD_controller_rec    Controller_RFD_Rec_Type := p_RFD_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      -- add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  -- add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; -- add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;    --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;  --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type; --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RFD_rec  => l_RFD_controller_rec
        , x_RFD_tbl             => l_ref_designator_tbl
        , x_unexp_RFD_rec       => l_unexp_RFD_rec
        );

        l_rev_component_tbl(1).transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_ref_designator_tbl     => l_ref_designator_tbl
        , p_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl    --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl  --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_RFD_tbl             => l_ref_designator_tbl
        , p_unexp_RFD_rec       => l_unexp_RFD_rec
        , x_controller_RFD_rec  => l_RFD_controller_rec
        );

        x_RFD_controller_rec := l_RFD_controller_rec;
        x_return_status := l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_RFD_controller_rec        IN  Controller_RFD_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RFD_controller_rec        IN OUT NOCOPY Controller_RFD_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RFD_controller_rec    Controller_RFD_Rec_Type := p_RFD_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;        --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;      --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;     --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RFD_rec  => l_RFD_controller_rec
        , x_RFD_tbl             => l_ref_designator_tbl
        , x_unexp_RFD_rec       => l_unexp_RFD_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_ref_designator_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_ref_designator_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_ref_designator_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_ref_designator_tbl     => l_ref_designator_tbl
        , p_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl    --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl  --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_RFD_tbl             => l_ref_designator_tbl
        , p_unexp_RFD_rec       => l_unexp_RFD_rec
        , x_controller_RFD_rec  => l_RFD_controller_rec
        );

        x_RFD_controller_rec := l_RFD_controller_rec;
        x_return_status := l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_RFD_controller_rec        IN  Controller_RFD_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RFD_controller_rec    Controller_RFD_Rec_Type := p_RFD_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;        --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;      --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;     --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RFD_rec  => l_RFD_controller_rec
        , x_RFD_tbl             => l_ref_designator_tbl
        , x_unexp_RFD_rec       => l_unexp_RFD_rec
        );

        l_sub_component_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_ref_designator_tbl     => l_ref_designator_tbl
        , p_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl    --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl  --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_RFD_tbl             => l_ref_designator_tbl
        , p_unexp_RFD_rec       => l_unexp_RFD_rec
        , x_controller_RFD_rec  => l_RFD_controller_rec
        );

        x_return_status := l_return_status;
END Delete_Row;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_RFD_tbl(1)                       IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_RFD_tbl(1)                       OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END RFD_Controller;

/
