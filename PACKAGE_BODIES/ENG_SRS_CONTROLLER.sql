--------------------------------------------------------
--  DDL for Package Body ENG_SRS_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_SRS_CONTROLLER" AS
/* $Header: ENGCSRSB.pls 115.6 2003/07/08 12:43:45 akumar ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_SRS_rec        IN  Controller_SRS_Rec_Type
,   x_SRS_tbl                   OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type
,   x_unexp_SRS_rec             OUT NOCOPY BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_SRS_tbl(1).eco_name           	  := p_controller_SRS_rec.eco_name;
        x_SRS_tbl(1).organization_code  	  := p_controller_SRS_rec.organization_code;
        x_SRS_tbl(1).revised_item_name  	  := p_controller_SRS_rec.revised_item_name;
        x_SRS_tbl(1).new_revised_item_revision    := p_controller_SRS_rec.new_revised_item_revision;
        x_SRS_tbl(1).ACD_Type                     := p_controller_SRS_rec.ACD_Type;
        x_SRS_tbl(1).Alternate_Routing_Code       := p_controller_SRS_rec.Alternate_Routing_Code;
        x_SRS_tbl(1).operation_sequence_number    := p_controller_SRS_rec.operation_sequence_number;
        x_SRS_tbl(1).Operation_Type               := p_controller_SRS_rec.Operation_Type;
        x_SRS_tbl(1).Op_Start_Effective_Date      := p_controller_SRS_rec.Op_Start_Effective_Date;
        x_SRS_tbl(1).Sub_Resource_Code            := p_controller_SRS_rec.Sub_Resource_Code;
        x_SRS_tbl(1).New_Sub_Resource_Code        := p_controller_SRS_rec.New_Sub_Resource_Code;
        x_SRS_tbl(1).Schedule_Sequence_Number     := p_controller_SRS_rec.Schedule_Sequence_Number;
        x_SRS_tbl(1).Replacement_Group_Number     := p_controller_SRS_rec.Replacement_Group_Number;
        x_SRS_tbl(1).Activity                     := p_controller_SRS_rec.Activity ;
        x_SRS_tbl(1).Standard_Rate_Flag           := p_controller_SRS_rec.Standard_Rate_Flag;
        x_SRS_tbl(1).Assigned_Units               := p_controller_SRS_rec.Assigned_Units;
        x_SRS_tbl(1).Usage_Rate_Or_amount         := p_controller_SRS_rec.Usage_Rate_Or_amount;
        x_SRS_tbl(1).Usage_Rate_Or_Amount_Inverse := p_controller_SRS_rec.Usage_Rate_Or_Amount_Inverse;
        x_SRS_tbl(1).Basis_Type                   := p_controller_SRS_rec.Basis_Type;
        x_SRS_tbl(1).Schedule_Flag                := p_controller_SRS_rec.Schedule_Flag;
        x_SRS_tbl(1).Resource_Offset_Percent      := p_controller_SRS_rec.Resource_Offset_Percent;
        x_SRS_tbl(1).Autocharge_Type              := p_controller_SRS_rec.Autocharge_Type;
        x_SRS_tbl(1).Principle_Flag               := p_controller_SRS_rec.Principle_Flag;
        x_SRS_tbl(1).Attribute_category           := p_controller_SRS_rec.Attribute_category;
        x_SRS_tbl(1).Attribute1                   := p_controller_SRS_rec.Attribute1;
        x_SRS_tbl(1).Attribute2                   := p_controller_SRS_rec.Attribute2;
        x_SRS_tbl(1).Attribute3                   := p_controller_SRS_rec.Attribute3;
        x_SRS_tbl(1).Attribute4                   := p_controller_SRS_rec.Attribute4;
        x_SRS_tbl(1).Attribute5                   := p_controller_SRS_rec.Attribute5;
        x_SRS_tbl(1).Attribute6                   := p_controller_SRS_rec.Attribute6;
        x_SRS_tbl(1).Attribute7                   := p_controller_SRS_rec.Attribute7;
        x_SRS_tbl(1).Attribute8                   := p_controller_SRS_rec.Attribute8;
        x_SRS_tbl(1).Attribute9                   := p_controller_SRS_rec.Attribute9;
        x_SRS_tbl(1).Attribute10                  := p_controller_SRS_rec.Attribute10;
        x_SRS_tbl(1).Attribute11                  := p_controller_SRS_rec.Attribute11;
        x_SRS_tbl(1).Attribute12                  := p_controller_SRS_rec.Attribute12;
        x_SRS_tbl(1).Attribute13                  := p_controller_SRS_rec.Attribute13;
        x_SRS_tbl(1).Attribute14                  := p_controller_SRS_rec.Attribute14;
        x_SRS_tbl(1).Attribute15                  := p_controller_SRS_rec.Attribute15;
        x_SRS_tbl(1).Original_System_Reference    := p_controller_SRS_rec.Original_System_Reference;
        x_SRS_tbl(1).Transaction_Type             := p_controller_SRS_rec.Transaction_Type;
        x_SRS_tbl(1).Setup_Type                   := p_controller_SRS_rec.Setup_code;
        x_SRS_tbl(1).Return_Status                := p_controller_SRS_rec.Return_Status;

        -- Create unexposed record

        x_unexp_SRS_rec.Revised_Item_Sequence_Id  := p_controller_SRS_rec.Revised_Item_Sequence_Id;
        x_unexp_SRS_rec.Operation_Sequence_Id     := p_controller_SRS_rec.Operation_Sequence_Id;
        x_unexp_SRS_rec.Routing_Sequence_Id       := p_controller_SRS_rec.Routing_Sequence_Id;
        x_unexp_SRS_rec.Substitute_Group_Number   := p_controller_SRS_rec.Substitute_Group_Number;
        x_unexp_SRS_rec.Revised_Item_Id           := p_controller_SRS_rec.Revised_Item_Id;
        x_unexp_SRS_rec.Organization_Id           := p_controller_SRS_rec.Organization_Id;
        x_unexp_SRS_rec.Resource_Id               := p_controller_SRS_rec.Resource_Id;
        x_unexp_SRS_rec.New_Resource_Id           := p_controller_SRS_rec.New_Resource_Id;
        x_unexp_SRS_rec.Activity_Id               := p_controller_SRS_rec.Activity_Id;
        x_unexp_SRS_rec.Setup_Id                  := p_controller_SRS_rec.Setup_Id;

END Create_Exp_Unexp_Rec;



PROCEDURE Create_Controller_Rec
(   p_SRS_tbl                   IN  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type
,   p_unexp_SRS_rec             IN  BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type
,   x_controller_SRS_rec        OUT NOCOPY Controller_SRS_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_SRS_rec.eco_name                     := p_SRS_tbl(1).eco_name;
        x_controller_SRS_rec.organization_code            := p_SRS_tbl(1).organization_code;
        x_controller_SRS_rec.revised_item_name            := p_SRS_tbl(1).revised_item_name;
        x_controller_SRS_rec.new_revised_item_revision    := p_SRS_tbl(1).new_revised_item_revision;
        x_controller_SRS_rec.ACD_Type                     := p_SRS_tbl(1).ACD_Type;
        x_controller_SRS_rec.Alternate_Routing_Code       := p_SRS_tbl(1).Alternate_Routing_Code;
        x_controller_SRS_rec.operation_sequence_number    := p_SRS_tbl(1).operation_sequence_number;
        x_controller_SRS_rec.Operation_Type               := p_SRS_tbl(1).Operation_Type;
        x_controller_SRS_rec.Op_Start_Effective_Date      := p_SRS_tbl(1).Op_Start_Effective_Date;
        x_controller_SRS_rec.Sub_Resource_Code            := p_SRS_tbl(1).Sub_Resource_Code;
        x_controller_SRS_rec.New_Sub_Resource_Code        := p_SRS_tbl(1).New_Sub_Resource_Code;
        x_controller_SRS_rec.Schedule_Sequence_Number     := p_SRS_tbl(1).Schedule_Sequence_Number ;
        x_controller_SRS_rec.Replacement_Group_Number     := p_SRS_tbl(1).Replacement_Group_Number;
        x_controller_SRS_rec.Activity                     := p_SRS_tbl(1).Activity;
        x_controller_SRS_rec.Standard_Rate_Flag           := p_SRS_tbl(1).Standard_Rate_Flag;
        x_controller_SRS_rec.Assigned_Units               := p_SRS_tbl(1).Assigned_Units;
        x_controller_SRS_rec.Usage_Rate_Or_amount         := p_SRS_tbl(1).Usage_Rate_Or_amount;
        x_controller_SRS_rec.Usage_Rate_Or_Amount_Inverse := p_SRS_tbl(1).Usage_Rate_Or_Amount_Inverse;
        x_controller_SRS_rec.Basis_Type                   := p_SRS_tbl(1).Basis_Type;
        x_controller_SRS_rec.Schedule_Flag                := p_SRS_tbl(1).Schedule_Flag;
        x_controller_SRS_rec.Resource_Offset_Percent      := p_SRS_tbl(1).Resource_Offset_Percent;
        x_controller_SRS_rec.Autocharge_Type              := p_SRS_tbl(1).Autocharge_Type;
        x_controller_SRS_rec.Principle_Flag               := p_SRS_tbl(1).Principle_Flag;
        x_controller_SRS_rec.Attribute_category           := p_SRS_tbl(1).Attribute_category ;
        x_controller_SRS_rec.Attribute1                   := p_SRS_tbl(1).Attribute1;
        x_controller_SRS_rec.Attribute2                   := p_SRS_tbl(1).Attribute2;
        x_controller_SRS_rec.Attribute3                   := p_SRS_tbl(1).Attribute3;
        x_controller_SRS_rec.Attribute4                   := p_SRS_tbl(1).Attribute4;
        x_controller_SRS_rec.Attribute5                   := p_SRS_tbl(1).Attribute5;
        x_controller_SRS_rec.Attribute6                   := p_SRS_tbl(1).Attribute6;
        x_controller_SRS_rec.Attribute7                   := p_SRS_tbl(1).Attribute7;
        x_controller_SRS_rec.Attribute8                   := p_SRS_tbl(1).Attribute8;
        x_controller_SRS_rec.Attribute9                   := p_SRS_tbl(1).Attribute9;
        x_controller_SRS_rec.Attribute10                  := p_SRS_tbl(1).Attribute10;
        x_controller_SRS_rec.Attribute11                  := p_SRS_tbl(1).Attribute11;
        x_controller_SRS_rec.Attribute12                  := p_SRS_tbl(1).Attribute12;
        x_controller_SRS_rec.Attribute13                  := p_SRS_tbl(1).Attribute13;
        x_controller_SRS_rec.Attribute14                  := p_SRS_tbl(1).Attribute14;
        x_controller_SRS_rec.Attribute15                  := p_SRS_tbl(1).Attribute15;
        x_controller_SRS_rec.Original_System_Reference    := p_SRS_tbl(1).Original_System_Reference;
        x_controller_SRS_rec.Transaction_Type             := p_SRS_tbl(1).Transaction_Type;
        x_controller_SRS_rec.Setup_Code                   := p_SRS_tbl(1).Setup_Type;
        x_controller_SRS_rec.Return_Status                := p_SRS_tbl(1).Return_Status;
        x_controller_SRS_rec.Revised_Item_Sequence_Id     := p_unexp_SRS_rec.Revised_Item_Sequence_Id;
        x_controller_SRS_rec.Operation_Sequence_Id        := p_unexp_SRS_rec.Operation_Sequence_Id;
        x_controller_SRS_rec.Routing_Sequence_Id          := p_unexp_SRS_rec.Routing_Sequence_Id;
        x_controller_SRS_rec.Substitute_Group_Number      := p_unexp_SRS_rec.Substitute_Group_Number;
        x_controller_SRS_rec.Revised_Item_Id              := p_unexp_SRS_rec.Revised_Item_Id;
        x_controller_SRS_rec.Organization_Id              := p_unexp_SRS_rec.Organization_Id;
        x_controller_SRS_rec.Resource_Id                  := p_unexp_SRS_rec.Resource_Id;
        x_controller_SRS_rec.New_Resource_Id              := p_unexp_SRS_rec.New_Resource_Id;
        x_controller_SRS_rec.Activity_Id                  := p_unexp_SRS_rec.Activity_Id;
        x_controller_SRS_rec.Setup_Id                     := p_unexp_SRS_rec.Setup_Id;
END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_SRS_controller_rec        IN  Controller_SRS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_SRS_controller_rec        IN OUT NOCOPY Controller_SRS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SRS_controller_rec    ENG_SRS_Controller.Controller_Srs_Rec_Type := p_srs_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_SRS_rec         BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SRS_rec  => l_SRS_controller_rec
        , x_SRS_tbl             => l_rev_sub_resource_tbl
        , x_unexp_SRS_rec       => l_unexp_SRS_rec
        );

        l_rev_Sub_Resource_tbl(1).transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , p_control_rec                => l_control_rec
        , p_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
        , p_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_rec                    => l_eco_rec
        , x_unexp_eco_rec              => l_unexp_eco_rec
        , x_unexp_eco_rev_rec          => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec     => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec         => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec         => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec         => l_unexp_RFD_rec
        , x_unexp_rev_op_rec           => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec       => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_revision_tbl           => l_eco_revision_tbl
        , x_revised_item_tbl           => l_revised_item_tbl
        , x_rev_Component_tbl          => l_rev_Component_tbl
        , x_ref_designator_tbl         => l_ref_designator_tbl
        , x_sub_component_tbl          => l_sub_component_tbl
        , x_rev_operation_tbl          => l_rev_operation_tbl
        , x_rev_op_resource_tbl        => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SRS_tbl             => l_rev_Sub_Resource_tbl
        , p_unexp_SRS_rec       => l_unexp_SRS_rec
        , x_controller_SRS_rec  => l_SRS_controller_rec
        );

        x_SRS_controller_rec := l_SRS_controller_rec;
        x_return_status := l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_SRS_controller_rec        IN  Controller_SRS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SRS_controller_rec        IN OUT NOCOPY Controller_SRS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SRS_controller_rec    ENG_SRS_Controller.Controller_Srs_Rec_Type := p_srs_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_SRS_rec         BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SRS_rec  => l_SRS_controller_rec
        , x_SRS_tbl             => l_rev_Sub_Resource_tbl
        , x_unexp_SRS_rec       => l_unexp_SRS_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , p_control_rec                => l_control_rec
        , p_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
        , p_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_rec                    => l_eco_rec
        , x_unexp_eco_rec              => l_unexp_eco_rec
        , x_unexp_eco_rev_rec          => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec     => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec         => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec         => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec         => l_unexp_RFD_rec
        , x_unexp_rev_op_rec           => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec       => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_revision_tbl           => l_eco_revision_tbl
        , x_revised_item_tbl           => l_revised_item_tbl
        , x_rev_Component_tbl          => l_rev_Component_tbl
        , x_ref_designator_tbl         => l_ref_designator_tbl
        , x_sub_component_tbl          => l_sub_component_tbl
        , x_rev_operation_tbl          => l_rev_operation_tbl
        , x_rev_op_resource_tbl        => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );


        Create_Controller_Rec
        ( p_SRS_tbl             => l_rev_Sub_Resource_tbl
        , p_unexp_SRS_rec       => l_unexp_SRS_rec
        , x_controller_SRS_rec  => l_SRS_controller_rec
        );

        x_SRS_controller_rec := l_SRS_controller_rec;
        x_return_status := l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_SRS_controller_rec        IN  Controller_SRS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SRS_controller_rec    ENG_SRS_Controller.Controller_Srs_Rec_Type := p_srs_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_SRS_rec         BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SRS_rec  => l_SRS_controller_rec
        , x_SRS_tbl             => l_rev_Sub_Resource_tbl
        , x_unexp_SRS_rec       => l_unexp_SRS_rec
        );

        l_rev_Sub_Resource_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , p_control_rec                => l_control_rec
        , p_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
        , p_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_rec                    => l_eco_rec
        , x_unexp_eco_rec              => l_unexp_eco_rec
        , x_unexp_eco_rev_rec          => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec     => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec         => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec         => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec         => l_unexp_RFD_rec
        , x_unexp_rev_op_rec           => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec       => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_revision_tbl           => l_eco_revision_tbl
        , x_revised_item_tbl           => l_revised_item_tbl
        , x_rev_Component_tbl          => l_rev_Component_tbl
        , x_ref_designator_tbl         => l_ref_designator_tbl
        , x_sub_component_tbl          => l_sub_component_tbl
        , x_rev_operation_tbl          => l_rev_operation_tbl
        , x_rev_op_resource_tbl        => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );


        Create_Controller_Rec
        ( p_SRS_tbl             => l_rev_Sub_Resource_tbl
        , p_unexp_SRS_rec       => l_unexp_SRS_rec
        , x_controller_SRS_rec  => l_SRS_controller_rec
        );

        x_return_status := l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_SRS_controller_rec        IN  Controller_SRS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_SRS_controller_rec        IN OUT NOCOPY Controller_SRS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_SRS_controller_rec    ENG_SRS_Controller.Controller_Srs_Rec_Type := p_srs_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_SRS_rec         BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_SRS_rec  => l_SRS_controller_rec
        , x_SRS_tbl             => l_rev_Sub_Resource_tbl
        , x_unexp_SRS_rec       => l_unexp_SRS_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_rev_Sub_Resource_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , p_control_rec                => l_control_rec
        , p_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
        , p_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_rec                    => l_eco_rec
        , x_unexp_eco_rec              => l_unexp_eco_rec
        , x_unexp_eco_rev_rec          => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec     => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec         => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec         => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec         => l_unexp_RFD_rec
        , x_unexp_rev_op_rec           => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec       => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec      => l_unexp_SRS_rec
        , x_eco_revision_tbl           => l_eco_revision_tbl
        , x_revised_item_tbl           => l_revised_item_tbl
        , x_rev_Component_tbl          => l_rev_Component_tbl
        , x_ref_designator_tbl         => l_ref_designator_tbl
        , x_sub_component_tbl          => l_sub_component_tbl
        , x_rev_operation_tbl          => l_rev_operation_tbl
        , x_rev_op_resource_tbl        => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl       => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_SRS_tbl             => l_rev_Sub_Resource_tbl
        , p_unexp_SRS_rec       => l_unexp_SRS_rec
        , x_controller_SRS_rec  => l_SRS_controller_rec
        );

        x_SRS_controller_rec := l_SRS_controller_rec;
        x_return_status := l_return_status;
END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_SRS_tbl(1)                    IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_SRS_tbl(1)                    OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END ENG_SRS_Controller;

/
