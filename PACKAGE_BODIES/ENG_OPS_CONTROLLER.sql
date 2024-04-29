--------------------------------------------------------
--  DDL for Package Body ENG_OPS_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_OPS_CONTROLLER" AS
/* $Header: ENGCOPSB.pls 120.0.12010000.3 2015/06/09 10:46:51 nlingamp ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_OPS_rec        IN  Controller_OPS_Rec_Type
,   x_OPS_tbl                   OUT NOCOPY BOM_RTG_PUB.Rev_operation_Tbl_Type
,   x_unexp_OPS_rec             OUT NOCOPY BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_OPS_tbl(1).eco_name           	:= p_controller_OPS_rec.eco_name;
        x_OPS_tbl(1).organization_code  	:= p_controller_OPS_rec.organization_code;
        x_OPS_tbl(1).revised_item_name  	:= p_controller_OPS_rec.revised_item_name;
        x_OPS_tbl(1).new_revised_item_revision  := p_controller_OPS_rec.new_revised_item_revision;
        x_OPS_tbl(1).ACD_Type       := p_controller_OPS_rec.ACD_Type;
        x_OPS_tbl(1).Alternate_Routing_Code     := p_controller_OPS_rec.Alternate_Routing_Code;
        x_OPS_tbl(1).operation_sequence_number  := p_controller_OPS_rec.operation_sequence_number;
        x_OPS_tbl(1).Operation_Type := p_controller_OPS_rec.Operation_Type;
        x_OPS_tbl(1).Start_Effective_Date       := p_controller_OPS_rec.Start_Effective_Date;
        x_OPS_tbl(1).new_operation_sequence_number := p_controller_OPS_rec.new_operation_sequence_number;
        x_OPS_tbl(1).Old_Operation_Sequence_Number := p_controller_OPS_rec.Old_Operation_Sequence_Number;
        x_OPS_tbl(1).Old_Start_Effective_Date   := p_controller_OPS_rec.Old_Start_Effective_Date;
        x_OPS_tbl(1).Standard_Operation_Code    := p_controller_OPS_rec.Standard_Operation_Code;
        x_OPS_tbl(1).Department_Code            := p_controller_OPS_rec.Department_Code;
        x_OPS_tbl(1).Op_Lead_Time_Percent       := p_controller_OPS_rec.Op_Lead_Time_Percent;
        x_OPS_tbl(1).Minimum_Transfer_Quantity  := p_controller_OPS_rec.Minimum_Transfer_Quantity;
        x_OPS_tbl(1).Count_Point_Type           := p_controller_OPS_rec.Count_Point_Type;
        x_OPS_tbl(1).Operation_Description      := p_controller_OPS_rec.Operation_Description;
        x_OPS_tbl(1).Disable_Date               := p_controller_OPS_rec.Disable_Date ;
        x_OPS_tbl(1).Backflush_Flag             := p_controller_OPS_rec.Backflush_Flag;
	/* commented for bug 21155295 since check_skill will be used as un-exposed column */
	-- x_OPS_tbl(1).Check_Skill                := p_controller_OPS_rec.Check_Skill;  --added for bug 13979762
        x_OPS_tbl(1).Option_Dependent_Flag      := p_controller_OPS_rec.Option_Dependent_Flag;
        x_OPS_tbl(1).Reference_Flag             := p_controller_OPS_rec.Reference_Flag;
        x_OPS_tbl(1).Yield                      := p_controller_OPS_rec.Yield  ;
        x_OPS_tbl(1).Cumulative_Yield           := p_controller_OPS_rec.Cumulative_Yield;
        x_OPS_tbl(1).Cancel_Comments            := p_controller_OPS_rec.Cancel_Comments ;
        x_OPS_tbl(1).Attribute_category         := p_controller_OPS_rec.Attribute_category;
        x_OPS_tbl(1).Attribute1                 := p_controller_OPS_rec.Attribute1;
        x_OPS_tbl(1).Attribute2                 := p_controller_OPS_rec.Attribute2;
        x_OPS_tbl(1).Attribute3                 := p_controller_OPS_rec.Attribute3;
        x_OPS_tbl(1).Attribute4                 := p_controller_OPS_rec.Attribute4;
        x_OPS_tbl(1).Attribute5                 := p_controller_OPS_rec.Attribute5;
        x_OPS_tbl(1).Attribute6                 := p_controller_OPS_rec.Attribute6;
        x_OPS_tbl(1).Attribute7                 := p_controller_OPS_rec.Attribute7;
        x_OPS_tbl(1).Attribute8                 := p_controller_OPS_rec.Attribute8;
        x_OPS_tbl(1).Attribute9                 := p_controller_OPS_rec.Attribute9;
        x_OPS_tbl(1).Attribute10                := p_controller_OPS_rec.Attribute10;
        x_OPS_tbl(1).Attribute11                := p_controller_OPS_rec.Attribute11;
        x_OPS_tbl(1).Attribute12                := p_controller_OPS_rec.Attribute12;
        x_OPS_tbl(1).Attribute13                := p_controller_OPS_rec.Attribute13;
        x_OPS_tbl(1).Attribute14                := p_controller_OPS_rec.Attribute14;
        x_OPS_tbl(1).Attribute15                := p_controller_OPS_rec.Attribute15;
        x_OPS_tbl(1).Original_System_Reference  := p_controller_OPS_rec.Original_System_Reference;
        x_OPS_tbl(1).Transaction_Type           := p_controller_OPS_rec.Transaction_Type;
        x_OPS_tbl(1).Return_Status              := p_controller_OPS_rec.Return_Status;

        -- Create unexposed record

        x_unexp_OPS_rec.Revised_Item_Sequence_Id  := p_controller_OPS_rec.Revised_Item_Sequence_Id;
        x_unexp_OPS_rec.Operation_Sequence_Id     := p_controller_OPS_rec.Operation_Sequence_Id;
        x_unexp_OPS_rec.Old_Operation_Sequence_Id := p_controller_OPS_rec.Old_Operation_Sequence_Id;
        x_unexp_OPS_rec.Routing_Sequence_Id       := p_controller_OPS_rec.Routing_Sequence_Id;
        x_unexp_OPS_rec.Revised_Item_Id           := p_controller_OPS_rec.Revised_Item_Id;
        x_unexp_OPS_rec.Organization_Id           := p_controller_OPS_rec.Organization_Id;
        x_unexp_OPS_rec.Standard_Operation_Id     := p_controller_OPS_rec.Standard_Operation_Id;
        x_unexp_OPS_rec.Department_Id             := p_controller_OPS_rec.Department_Id;
	/* Added for bug 21155295 since check_skill will be used as un-exposed column */
	x_unexp_OPS_rec.Check_Skill               := p_controller_OPS_rec.Check_Skill;

END Create_Exp_Unexp_Rec;



PROCEDURE Create_Controller_Rec
(   p_OPS_tbl                   IN  BOM_RTG_PUB.Rev_operation_Tbl_Type
,   p_unexp_OPS_rec             IN  BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type
,   x_controller_OPS_rec        OUT NOCOPY Controller_OPS_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_OPS_rec.eco_name                   := p_OPS_tbl(1).eco_name;
        x_controller_OPS_rec.organization_code          := p_OPS_tbl(1).organization_code;
        x_controller_OPS_rec.revised_item_name          := p_OPS_tbl(1).revised_item_name;
        x_controller_OPS_rec.new_revised_item_revision  := p_OPS_tbl(1).new_revised_item_revision;
        x_controller_OPS_rec.ACD_Type                   := p_OPS_tbl(1).ACD_Type;
        x_controller_OPS_rec.Alternate_Routing_Code     := p_OPS_tbl(1).Alternate_Routing_Code;
        x_controller_OPS_rec.operation_sequence_number  := p_OPS_tbl(1).operation_sequence_number;
        x_controller_OPS_rec.Operation_Type             := p_OPS_tbl(1).Operation_Type;
        x_controller_OPS_rec.Start_Effective_Date       := p_OPS_tbl(1).Start_Effective_Date;
        x_controller_OPS_rec.new_operation_sequence_number := p_OPS_tbl(1).new_operation_sequence_number;
        x_controller_OPS_rec.Old_Operation_Sequence_Number := p_OPS_tbl(1).Old_Operation_Sequence_Number;
        x_controller_OPS_rec.Old_Start_Effective_Date   := p_OPS_tbl(1).Old_Start_Effective_Date;
        x_controller_OPS_rec.Standard_Operation_Code    := p_OPS_tbl(1).Standard_Operation_Code;
        x_controller_OPS_rec.Department_Code            := p_OPS_tbl(1).Department_Code;
        x_controller_OPS_rec.Op_Lead_Time_Percent       := p_OPS_tbl(1).Op_Lead_Time_Percent;
        x_controller_OPS_rec.Minimum_Transfer_Quantity  := p_OPS_tbl(1).Minimum_Transfer_Quantity;
        x_controller_OPS_rec.Count_Point_Type           := p_OPS_tbl(1).Count_Point_Type;
        x_controller_OPS_rec.Operation_Description      := p_OPS_tbl(1).Operation_Description;
        x_controller_OPS_rec.Disable_Date               := p_OPS_tbl(1).Disable_Date;
        x_controller_OPS_rec.Backflush_Flag             := p_OPS_tbl(1).Backflush_Flag;
	/* commented for bug 21155295 since check_skill will be used as un-exposed column */
	--x_controller_OPS_rec.Check_Skill                := p_OPS_tbl(1).Check_Skill;  --added for bug 13979762
        x_controller_OPS_rec.Option_Dependent_Flag      := p_OPS_tbl(1).Option_Dependent_Flag;
        x_controller_OPS_rec.Reference_Flag             := p_OPS_tbl(1).Reference_Flag ;
        x_controller_OPS_rec.Yield                      := p_OPS_tbl(1).Yield ;
        x_controller_OPS_rec.Cumulative_Yield           := p_OPS_tbl(1).Cumulative_Yield ;
        x_controller_OPS_rec.Cancel_Comments            := p_OPS_tbl(1).Cancel_Comments ;
        x_controller_OPS_rec.Attribute_category         := p_OPS_tbl(1).Attribute_category ;
        x_controller_OPS_rec.Attribute1                 := p_OPS_tbl(1).Attribute1;
        x_controller_OPS_rec.Attribute2                 := p_OPS_tbl(1).Attribute2;
        x_controller_OPS_rec.Attribute3                 := p_OPS_tbl(1).Attribute3;
        x_controller_OPS_rec.Attribute4                 := p_OPS_tbl(1).Attribute4;
        x_controller_OPS_rec.Attribute5                 := p_OPS_tbl(1).Attribute5;
        x_controller_OPS_rec.Attribute6                 := p_OPS_tbl(1).Attribute6;
        x_controller_OPS_rec.Attribute7                 := p_OPS_tbl(1).Attribute7;
        x_controller_OPS_rec.Attribute8                 := p_OPS_tbl(1).Attribute8;
        x_controller_OPS_rec.Attribute9                 := p_OPS_tbl(1).Attribute9;
        x_controller_OPS_rec.Attribute10                := p_OPS_tbl(1).Attribute10;
        x_controller_OPS_rec.Attribute11                := p_OPS_tbl(1).Attribute11;
        x_controller_OPS_rec.Attribute12                := p_OPS_tbl(1).Attribute12;
        x_controller_OPS_rec.Attribute13                := p_OPS_tbl(1).Attribute13;
        x_controller_OPS_rec.Attribute14                := p_OPS_tbl(1).Attribute14;
        x_controller_OPS_rec.Attribute15                := p_OPS_tbl(1).Attribute15;
        x_controller_OPS_rec.Original_System_Reference  := p_OPS_tbl(1).Original_System_Reference;
        x_controller_OPS_rec.Transaction_Type           := p_OPS_tbl(1).Transaction_Type;
        x_controller_OPS_rec.Return_Status              := p_OPS_tbl(1).Return_Status;
        x_controller_OPS_rec.Revised_Item_Sequence_Id   := p_unexp_OPS_rec.Revised_Item_Sequence_Id;
        x_controller_OPS_rec.Operation_Sequence_Id      := p_unexp_OPS_rec.Operation_Sequence_Id;
        x_controller_OPS_rec.Old_Operation_Sequence_Id  := p_unexp_OPS_rec.Old_Operation_Sequence_Id;
        x_controller_OPS_rec.Routing_Sequence_Id        := p_unexp_OPS_rec.Routing_Sequence_Id;
        x_controller_OPS_rec.Revised_Item_Id            := p_unexp_OPS_rec.Revised_Item_Id;
        x_controller_OPS_rec.Organization_Id            := p_unexp_OPS_rec.Organization_Id;
        x_controller_OPS_rec.Standard_Operation_Id      := p_unexp_OPS_rec.Standard_Operation_Id;
        x_controller_OPS_rec.Department_Id              := p_unexp_OPS_rec.Department_Id;
	/* Added for bug 21155295 since check_skill will be used as un-exposed column */
	x_controller_OPS_rec.Check_Skill                := p_unexp_OPS_rec.Check_Skill;
END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type            := p_control_rec;
l_OPS_controller_rec    ENG_OPS_Controller.Controller_Ops_Rec_Type := p_ops_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
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
        ( p_controller_OPS_rec  => l_OPS_controller_rec
        , x_OPS_tbl             => l_rev_operation_tbl
        , x_unexp_OPS_rec       => l_unexp_OPS_rec
        );

        l_rev_operation_tbl(1).transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_rev_operation_tbl      => l_rev_operation_tbl
        , p_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_OPS_tbl             => l_rev_operation_tbl
        , p_unexp_OPS_rec       => l_unexp_OPS_rec
        , x_controller_OPS_rec  => l_OPS_controller_rec
        );

        x_OPS_controller_rec := l_OPS_controller_rec;
        x_return_status      := l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type            := p_control_rec;
l_OPS_controller_rec    ENG_OPS_Controller.Controller_Ops_Rec_Type := p_ops_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
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


IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('At the beginning of Validate_And_Write,the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

        Create_Exp_Unexp_Rec
        ( p_controller_OPS_rec  => l_OPS_controller_rec
        , x_OPS_tbl             => l_rev_operation_tbl
        , x_unexp_OPS_rec       => l_unexp_OPS_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_rev_operation_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_rev_operation_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_rev_operation_tbl(1).transaction_type := 'DELETE';
        END IF;
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('After  Create_Exp_Unexp_Rec, the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_rev_operation_tbl      => l_rev_operation_tbl
        , p_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );
IF BOM_Globals.get_debug = 'Y'
THEN
     error_handler.write_debug('After  process_ECO, the return status is');
     error_handler.write_debug( l_Return_Status);
END IF;
        Create_Controller_Rec
        ( p_OPS_tbl             => l_rev_operation_tbl
        , p_unexp_OPS_rec       => l_unexp_OPS_rec
        , x_controller_OPS_rec  => l_OPS_controller_rec
        );

        x_OPS_controller_rec := l_OPS_controller_rec;
        x_return_status := l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type            := p_control_rec;
l_OPS_controller_rec    ENG_OPS_Controller.Controller_Ops_Rec_Type := p_ops_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
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
        ( p_controller_OPS_rec  => l_OPS_controller_rec
        , x_OPS_tbl             => l_rev_operation_tbl
        , x_unexp_OPS_rec       => l_unexp_OPS_rec
        );

        l_rev_operation_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_rev_operation_tbl      => l_rev_operation_tbl
        , p_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_OPS_tbl             => l_rev_operation_tbl
        , p_unexp_OPS_rec       => l_unexp_OPS_rec
        , x_controller_OPS_rec  => l_OPS_controller_rec
        );

        x_return_status := l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_OPS_controller_rec        IN  Controller_OPS_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_OPS_controller_rec        IN OUT NOCOPY Controller_OPS_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type            := p_control_rec;
l_OPS_controller_rec    ENG_OPS_Controller.Controller_Ops_Rec_Type := p_ops_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_OPS_rec	        BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;
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
        ( p_controller_OPS_rec  => l_OPS_controller_rec
        , x_OPS_tbl             => l_rev_operation_tbl
        , x_unexp_OPS_rec       => l_unexp_OPS_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_rev_operation_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_rev_operation_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_rev_operation_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_rev_operation_tbl      => l_rev_operation_tbl
        , p_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_OPS_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,x_disable_revision  =>l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_OPS_tbl             => l_rev_operation_tbl
        , p_unexp_OPS_rec       => l_unexp_OPS_rec
        , x_controller_OPS_rec  => l_OPS_controller_rec
        );

        x_OPS_controller_rec := l_OPS_controller_rec;
        x_return_status := l_return_status;
END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_OPS_tbl(1)                    IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_OPS_tbl(1)                    OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END ENG_OPS_Controller;

/
