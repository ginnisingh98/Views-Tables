--------------------------------------------------------
--  DDL for Package Body SBC_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SBC_CONTROLLER" AS
/* $Header: ENGCSBCB.pls 115.7 2003/07/08 12:40:30 akumar ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_SBC_rec        IN  Controller_SBC_Rec_Type
,   x_SBC_tbl                   OUT NOCOPY BOM_BO_PUB.Sub_Component_Tbl_Type
,   x_unexp_SBC_rec             OUT NOCOPY BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_SBC_tbl(1).eco_name           := p_controller_SBC_rec.change_notice;
        x_SBC_tbl(1).organization_code  := p_controller_SBC_rec.organization_code;
        x_SBC_tbl(1).revised_item_name  := p_controller_SBC_rec.revised_item_name;
        x_SBC_tbl(1).new_revised_item_revision  := p_controller_SBC_rec.new_revised_item_revision;
        x_SBC_tbl(1).start_effective_date       := p_controller_SBC_rec.start_effective_date;
        x_SBC_tbl(1).operation_sequence_number  := p_controller_SBC_rec.operation_sequence_number;
        x_SBC_tbl(1).Component_Item_Name        := p_controller_SBC_rec.component_item_name;
        x_SBC_tbl(1).Alternate_BOM_Code         := p_controller_SBC_rec.alternate_bom_code;
        x_SBC_tbl(1).acd_type                   := p_controller_SBC_rec.acd_type;
        x_SBC_tbl(1).substitute_component_name  := p_controller_SBC_rec.substitute_component_name;
        x_SBC_tbl(1).substitute_item_quantity   := p_controller_SBC_rec.substitute_item_quantity;
        x_SBC_tbl(1).attribute_category         := p_controller_SBC_rec.attribute_category;
        x_SBC_tbl(1).attribute1                 := p_controller_SBC_rec.attribute1;
        x_SBC_tbl(1).attribute2                 := p_controller_SBC_rec.attribute2;
        x_SBC_tbl(1).attribute3                 := p_controller_SBC_rec.attribute3;
        x_SBC_tbl(1).attribute4                 := p_controller_SBC_rec.attribute4;
        x_SBC_tbl(1).attribute5                 := p_controller_SBC_rec.attribute5;
        x_SBC_tbl(1).attribute6                 := p_controller_SBC_rec.attribute6;
        x_SBC_tbl(1).attribute7                 := p_controller_SBC_rec.attribute7;
        x_SBC_tbl(1).attribute8                 := p_controller_SBC_rec.attribute8;
        x_SBC_tbl(1).attribute9                 := p_controller_SBC_rec.attribute9;
        x_SBC_tbl(1).attribute10                := p_controller_SBC_rec.attribute10;
        x_SBC_tbl(1).attribute11                := p_controller_SBC_rec.attribute11;
        x_SBC_tbl(1).attribute12                := p_controller_SBC_rec.attribute12;
        x_SBC_tbl(1).attribute13                := p_controller_SBC_rec.attribute13;
        x_SBC_tbl(1).attribute14                := p_controller_SBC_rec.attribute14;
        x_SBC_tbl(1).attribute15                := p_controller_SBC_rec.attribute15;

        -- Create unexposed record

        x_unexp_SBC_rec.organization_id := p_controller_SBC_rec.organization_id;
        x_unexp_SBC_rec.component_item_id := p_controller_SBC_rec.component_item_id;
        x_unexp_SBC_rec.component_sequence_id := p_controller_SBC_rec.component_sequence_id;
        x_unexp_SBC_rec.bill_sequence_id := p_controller_SBC_rec.bill_sequence_id;
        x_unexp_SBC_rec.revised_item_id := p_controller_SBC_rec.revised_item_id;
        x_unexp_SBC_rec.revised_item_sequence_id := p_controller_SBC_rec.revised_item_sequence_id;
        x_unexp_SBC_rec.substitute_component_id := p_controller_SBC_rec.substitute_component_id;
END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_SBC_tbl                   IN  BOM_BO_PUB.Sub_Component_Tbl_Type
,   p_unexp_SBC_rec             IN  BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type
,   x_controller_SBC_rec        OUT NOCOPY Controller_SBC_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_SBC_rec.change_notice := p_SBC_tbl(1).eco_name;
        x_controller_SBC_rec.organization_code := p_SBC_tbl(1).organization_code;
        x_controller_SBC_rec.revised_item_name := p_SBC_tbl(1).revised_item_name;
        x_controller_SBC_rec.new_revised_item_revision := p_SBC_tbl(1).new_revised_item_revision;
        x_controller_SBC_rec.start_effective_date := p_SBC_tbl(1).start_effective_date;
        x_controller_SBC_rec.operation_sequence_number := p_SBC_tbl(1).operation_sequence_number;
        x_controller_SBC_rec.Component_Item_Name := p_SBC_tbl(1).component_item_name;
        x_controller_SBC_rec.Alternate_BOM_Code := p_SBC_tbl(1).alternate_bom_code;
        x_controller_SBC_rec.acd_type := p_SBC_tbl(1).acd_type;
        x_controller_SBC_rec.substitute_component_name := p_SBC_tbl(1).substitute_component_name;
        x_controller_SBC_rec.substitute_item_quantity := p_SBC_tbl(1).substitute_item_quantity;
        x_controller_SBC_rec.attribute_category         := p_SBC_tbl(1).attribute_category;
        x_controller_SBC_rec.attribute1                 := p_SBC_tbl(1).attribute1;
        x_controller_SBC_rec.attribute2                 := p_SBC_tbl(1).attribute2;
        x_controller_SBC_rec.attribute3                 := p_SBC_tbl(1).attribute3;
        x_controller_SBC_rec.attribute4                 := p_SBC_tbl(1).attribute4;
        x_controller_SBC_rec.attribute5                 := p_SBC_tbl(1).attribute5;
        x_controller_SBC_rec.attribute6                 := p_SBC_tbl(1).attribute6;
        x_controller_SBC_rec.attribute7                 := p_SBC_tbl(1).attribute7;
        x_controller_SBC_rec.attribute8                 := p_SBC_tbl(1).attribute8;
        x_controller_SBC_rec.attribute9                 := p_SBC_tbl(1).attribute9;
        x_controller_SBC_rec.attribute10                := p_SBC_tbl(1).attribute10;
        x_controller_SBC_rec.attribute11                := p_SBC_tbl(1).attribute11;
        x_controller_SBC_rec.attribute12                := p_SBC_tbl(1).attribute12;
        x_controller_SBC_rec.attribute13                := p_SBC_tbl(1).attribute13;
        x_controller_SBC_rec.attribute14                := p_SBC_tbl(1).attribute14;
        x_controller_SBC_rec.attribute15                := p_SBC_tbl(1).attribute15;
        x_controller_SBC_rec.organization_id := p_unexp_SBC_rec.organization_id;
        x_controller_SBC_rec.component_item_id := p_unexp_SBC_rec.component_item_id;
        x_controller_SBC_rec.component_sequence_id := p_unexp_SBC_rec.component_sequence_id;
        x_controller_SBC_rec.bill_sequence_id := p_unexp_SBC_rec.bill_sequence_id;
        x_controller_SBC_rec.substitute_component_id := p_unexp_SBC_rec.substitute_component_id;
        x_controller_SBC_rec.revised_item_id := p_unexp_SBC_rec.revised_item_id;
        x_controller_SBC_rec.revised_item_sequence_id := p_unexp_SBC_rec.revised_item_sequence_id;
END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_SBC_controller_rec        IN OUT NOCOPY Controller_SBC_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SBC_controller_rec    Controller_SBC_Rec_Type := p_SBC_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;         --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;       --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;      --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SBC_rec  => l_SBC_controller_rec
        , x_SBC_tbl             => l_sub_component_tbl
        , x_unexp_SBC_rec       => l_unexp_SBC_rec
        );

        l_rev_component_tbl(1).transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_sub_component_tbl   => l_sub_component_tbl
        , p_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec  => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl     --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SBC_tbl             => l_sub_component_tbl
        , p_unexp_SBC_rec       => l_unexp_SBC_rec
        , x_controller_SBC_rec  => l_SBC_controller_rec
        );

        x_SBC_controller_rec := l_SBC_controller_rec;
        x_return_status := l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SBC_controller_rec        IN OUT NOCOPY Controller_SBC_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SBC_controller_rec    Controller_SBC_Rec_Type := p_SBC_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;         --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;       --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;      --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SBC_rec  => l_SBC_controller_rec
        , x_SBC_tbl             => l_sub_component_tbl
        , x_unexp_SBC_rec       => l_unexp_SBC_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_sub_component_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_sub_component_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_sub_component_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_sub_component_tbl   => l_sub_component_tbl
        , p_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec  => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl     --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SBC_tbl             => l_sub_component_tbl
        , p_unexp_SBC_rec       => l_unexp_SBC_rec
        , x_controller_SBC_rec  => l_SBC_controller_rec
        );

        x_SBC_controller_rec := l_SBC_controller_rec;
        x_return_status := l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SBC_controller_rec    Controller_SBC_Rec_Type := p_SBC_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;         --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;       --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;      --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SBC_rec  => l_SBC_controller_rec
        , x_SBC_tbl             => l_sub_component_tbl
        , x_unexp_SBC_rec       => l_unexp_SBC_rec
        );

        l_sub_component_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_sub_component_tbl   => l_sub_component_tbl
        , p_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec  => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl     --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SBC_tbl             => l_sub_component_tbl
        , p_unexp_SBC_rec       => l_unexp_SBC_rec
        , x_controller_SBC_rec  => l_SBC_controller_rec
        );

        x_return_status := l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_SBC_controller_rec        IN  Controller_SBC_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SBC_controller_rec        IN OUT NOCOPY Controller_SBC_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SBC_controller_rec    Controller_SBC_Rec_Type := p_SBC_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec         BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec         BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;      --add
l_unexp_RES_rec         BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;  --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type; --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;         --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;       --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;      --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SBC_rec  => l_SBC_controller_rec
        , x_SBC_tbl             => l_sub_component_tbl
        , x_unexp_SBC_rec       => l_unexp_SBC_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_sub_component_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_sub_component_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_sub_component_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_sub_component_tbl   => l_sub_component_tbl
        , p_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec  => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec  => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec         --add
        , x_unexp_rev_op_res_rec   => l_unexp_RES_rec         --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl     --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SBC_tbl             => l_sub_component_tbl
        , p_unexp_SBC_rec       => l_unexp_SBC_rec
        , x_controller_SBC_rec  => l_SBC_controller_rec
        );

        x_SBC_controller_rec := l_SBC_controller_rec;
        x_return_status := l_return_status;
END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_SBC_tbl(1)                       IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_SBC_tbl(1)                       OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END SBC_Controller;

/
