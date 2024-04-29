--------------------------------------------------------
--  DDL for Package Body REV_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."REV_CONTROLLER" AS
/* $Header: ENGCREVB.pls 115.8 2003/07/08 12:25:37 akumar ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_REV_rec        IN  REV_Controller.Controller_REV_Rec_Type
,   x_REV_tbl                   OUT NOCOPY ENG_ECO_PUB.Eco_Revision_Tbl_Type
,   x_unexp_REV_rec             OUT NOCOPY ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type
)
IS
BEGIN
	-- Create exposed record

	x_REV_tbl(1).eco_name 		:= p_controller_REV_rec.change_notice;
	x_REV_tbl(1).organization_code 	:= p_controller_REV_rec.organization_code;
	x_REV_tbl(1).revision 		:= p_controller_REV_rec.revision;
	x_REV_tbl(1).new_revision	:= p_controller_REV_rec.new_revision;
	x_REV_tbl(1).comments		:= p_controller_REV_rec.comments;
	x_REV_tbl(1).attribute_category := p_controller_REV_rec.attribute_category;
	x_REV_tbl(1).attribute1 	:= p_controller_REV_rec.attribute1;
	x_REV_tbl(1).attribute2 	:= p_controller_REV_rec.attribute2;
        x_REV_tbl(1).attribute3 	:= p_controller_REV_rec.attribute3;
        x_REV_tbl(1).attribute4 	:= p_controller_REV_rec.attribute4;
        x_REV_tbl(1).attribute5 	:= p_controller_REV_rec.attribute5;
        x_REV_tbl(1).attribute6 	:= p_controller_REV_rec.attribute6;
        x_REV_tbl(1).attribute7 	:= p_controller_REV_rec.attribute7;
        x_REV_tbl(1).attribute8 	:= p_controller_REV_rec.attribute8;
        x_REV_tbl(1).attribute9 	:= p_controller_REV_rec.attribute9;
        x_REV_tbl(1).attribute10 	:= p_controller_REV_rec.attribute10;
        x_REV_tbl(1).attribute11 	:= p_controller_REV_rec.attribute11;
        x_REV_tbl(1).attribute12 	:= p_controller_REV_rec.attribute12;
        x_REV_tbl(1).attribute13 	:= p_controller_REV_rec.attribute13;
        x_REV_tbl(1).attribute14 	:= p_controller_REV_rec.attribute14;
	x_REV_tbl(1).attribute15 	:= p_controller_REV_rec.attribute15;

	-- Create unexposed record

	x_unexp_REV_rec.organization_id	:= p_controller_REV_rec.organization_id;
	x_unexp_REV_rec.revision_id     := p_controller_REV_rec.revision_id;
	x_unexp_REV_rec.change_id       := p_controller_REV_rec.change_id; --added on 6.1.2003

END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_REV_tbl                   IN  ENG_ECO_PUB.Eco_Revision_Tbl_Type
,   p_unexp_REV_rec             IN  ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type
,   x_controller_REV_rec        OUT NOCOPY REV_Controller.Controller_REV_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_REV_rec.change_notice 	:= p_REV_tbl(1).eco_name;
        x_controller_REV_rec.organization_code 	:= p_REV_tbl(1).organization_code;
        x_controller_REV_rec.revision 		:= p_REV_tbl(1).revision;
        x_controller_REV_rec.new_revision    	:= p_REV_tbl(1).new_revision;
        x_controller_REV_rec.comments 		:= p_REV_tbl(1).comments;
        x_controller_REV_rec.attribute_category := p_REV_tbl(1).attribute_category;
        x_controller_REV_rec.attribute1         := p_REV_tbl(1).attribute1;
        x_controller_REV_rec.attribute2         := p_REV_tbl(1).attribute2;
        x_controller_REV_rec.attribute3         := p_REV_tbl(1).attribute3;
        x_controller_REV_rec.attribute4         := p_REV_tbl(1).attribute4;
        x_controller_REV_rec.attribute5         := p_REV_tbl(1).attribute5;
        x_controller_REV_rec.attribute6         := p_REV_tbl(1).attribute6;
        x_controller_REV_rec.attribute7         := p_REV_tbl(1).attribute7;
        x_controller_REV_rec.attribute8         := p_REV_tbl(1).attribute8;
        x_controller_REV_rec.attribute9         := p_REV_tbl(1).attribute9;
        x_controller_REV_rec.attribute10        := p_REV_tbl(1).attribute10;
        x_controller_REV_rec.attribute11        := p_REV_tbl(1).attribute11;
        x_controller_REV_rec.attribute12        := p_REV_tbl(1).attribute12;
        x_controller_REV_rec.attribute13        := p_REV_tbl(1).attribute13;
        x_controller_REV_rec.attribute14        := p_REV_tbl(1).attribute14;
        x_controller_REV_rec.attribute15        := p_REV_tbl(1).attribute15;
        x_controller_REV_rec.organization_id 	:= p_unexp_REV_rec.organization_id;
        x_controller_REV_rec.revision_id 	:= p_unexp_REV_rec.revision_id;
END Create_Controller_Rec;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_REV_controller_rec        IN  REV_Controller.Controller_REV_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_REV_controller_rec        IN  OUT NOCOPY REV_Controller.Controller_REV_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_REV_controller_rec	REV_Controller.Controller_REV_Rec_Type := p_REV_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_REV_rec		ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;

l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;

l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;

l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;


l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_REV_rec  => l_REV_controller_rec
	, x_REV_tbl 		=> l_eco_revision_tbl
	, x_unexp_REV_rec	=> l_unexp_REV_rec
	);

        IF p_record_status IN ('NEW', 'INSERT')
	THEN
		l_eco_revision_tbl(1).transaction_type := 'CREATE';
	ELSIF p_record_status IN ('QUERY', 'CHANGED')
	THEN
		l_eco_revision_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_eco_revision_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_eco_revision_tbl	=> l_eco_revision_tbl
        , p_unexp_eco_rev_rec	=> l_unexp_REV_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec 	=> l_unexp_REV_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec  => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec 	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec

        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl

        , x_rev_operation_tbl      => l_rev_operation_tbl
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,   x_disable_revision       => l_disable_revision  --BUG 3034642

        );

	Create_Controller_Rec
	( p_REV_tbl		=> l_eco_revision_tbl
	, p_unexp_REV_rec	=> l_unexp_REV_rec
	, x_controller_REV_rec  => l_REV_controller_rec
	);

	x_REV_controller_rec := l_REV_controller_rec;
	x_return_status	:= l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_REV_controller_rec        IN  REV_Controller.Controller_REV_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_REV_controller_rec	REV_Controller.Controller_REV_Rec_Type := p_REV_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_REV_rec		ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;

l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;

l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;

l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;


l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_REV_rec  => l_REV_controller_rec
	, x_REV_tbl 		=> l_eco_revision_tbl
	, x_unexp_REV_rec	=> l_unexp_REV_rec
	);

        l_rev_component_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_eco_revision_tbl	=> l_eco_revision_tbl
        , p_unexp_eco_rev_rec	=> l_unexp_REV_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_eco_rev_rec 	=> l_unexp_REV_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec  => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

	Create_Controller_Rec
	( p_REV_tbl		=> l_eco_revision_tbl
	, p_unexp_REV_rec	=> l_unexp_REV_rec
	, x_controller_REV_rec  => l_REV_controller_rec
	);

	x_return_status	:= l_return_status;
END Delete_Row;

/*
--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_REV_controller_rec        IN  ENG_ECO_PUB.Controller_REV_Rec_Type
,   p_control_rec               IN  ENG_ECO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_REV_controller_rec        IN  OUT NOCOPY ENG_ECO_PUB.Controller_REV_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		ENG_ECO_PUB.Control_Rec_Type := p_control_rec;
l_REV_controller_rec	ENG_ECO_PUB.Controller_REV_Rec_Type := p_REV_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_REV_rec		ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;

l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     ENG_ECO_PUB.Eco_Revision_Tbl_Type;
l_ref_designator_tbl    ENG_ECO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     ENG_ECO_PUB.Sub_Component_Tbl_Type;

l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;


l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_REV_rec  => l_REV_controller_rec
	, x_REV_tbl 		=> l_rev_component_tbl
	, x_unexp_REV_rec	=> l_unexp_REV_rec
	);

        IF p_record_status IN ('NEW', 'INSERT')
	THEN
		l_rev_component_tbl(1).transaction_type := 'CREATE';
	ELSIF p_record_status IN ('QUERY', 'CHANGED')
	THEN
		l_rev_component_tbl(1).transaction_type := 'UPDATE';
	ELSIF p_record_status = 'DELETE'
	THEN
		l_rev_component_tbl(1).transaction_type := 'DELETE';
	END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_rev_component_tbl   => l_rev_component_tbl
        , p_unexp_rev_comp_rec  => l_unexp_REV_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_REV_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec
        , x_eco_revision_tbl    => l_eco_revision_tbl
        , x_revised_item_tbl    => l_revised_item_tbl
        , x_rev_Component_tbl   => l_rev_Component_tbl
        , x_ref_designator_tbl  => l_ref_designator_tbl
        , x_sub_component_tbl   => l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

	Create_Controller_Rec
	( p_REV_tbl		=> l_rev_component_tbl
	, p_unexp_REV_rec	=> l_unexp_REV_rec
	, x_controller_REV_rec  => l_REV_controller_rec
	);

	x_REV_controller_rec := l_REV_controller_rec;
	x_return_status	:= l_return_status;
END Change_Attribute;

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY VARCHAR2
,   p_REV_tbl(1)                       IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_REV_tbl(1)                       OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END REV_Controller;

/
