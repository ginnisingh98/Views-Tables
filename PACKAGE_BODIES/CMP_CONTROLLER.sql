--------------------------------------------------------
--  DDL for Package Body CMP_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CMP_CONTROLLER" AS
/* $Header: ENGCCMPB.pls 120.0 2005/05/26 18:36:15 appldev noship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_CMP_rec        IN  Controller_CMP_Rec_Type
,   x_CMP_tbl                   OUT NOCOPY BOM_BO_PUB.Rev_Component_Tbl_Type
,   x_unexp_CMP_rec             OUT NOCOPY BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
)
IS
BEGIN
	-- Create exposed record

	x_CMP_tbl(1).eco_name 		:= p_controller_CMP_rec.change_notice;
	x_CMP_tbl(1).organization_code 	:= p_controller_CMP_rec.organization_code;
	x_CMP_tbl(1).revised_item_name 	:= p_controller_CMP_rec.revised_item_name;
	x_CMP_tbl(1).new_revised_item_revision	:= p_controller_CMP_rec.new_item_revision;
	x_CMP_tbl(1).start_effective_date	:= p_controller_CMP_rec.scheduled_date;
	x_CMP_tbl(1).disable_date		:= p_controller_CMP_rec.disable_date;
	x_CMP_tbl(1).operation_sequence_number  := p_controller_CMP_rec.operation_sequence_number;
	x_CMP_tbl(1).old_operation_sequence_number := p_controller_CMP_rec.old_operation_sequence_number;
	x_CMP_tbl(1).old_effectivity_date       := p_controller_CMP_rec.old_effectivity_date;
	x_CMP_tbl(1).old_from_end_item_unit_number       := p_controller_CMP_rec.old_from_end_item_unit_number;
	x_CMP_tbl(1).new_operation_sequence_number := p_controller_CMP_rec.new_operation_sequence_number;
	x_CMP_tbl(1).Component_Item_Name	:= p_controller_CMP_rec.component_item_name;
	x_CMP_tbl(1).Alternate_BOM_Code		:= p_controller_CMP_rec.alternate_bom_code;
	x_CMP_tbl(1).acd_type			:= p_controller_CMP_rec.acd_type;
	x_CMP_tbl(1).item_sequence_number	:= p_controller_CMP_rec.item_sequence_number;
	x_CMP_tbl(1).Quantity_Per_Assembly	:= p_controller_CMP_rec.component_quantity;
	x_CMP_tbl(1).Planning_Percent		:= p_controller_CMP_rec.planning_factor;
	x_CMP_tbl(1).Projected_Yield		:= p_controller_CMP_rec.component_yield_factor;
	x_CMP_tbl(1).Include_In_Cost_Rollup	:= p_controller_CMP_rec.Include_In_Cost_Rollup;
	x_CMP_tbl(1).Wip_Supply_Type		:= p_controller_CMP_rec.wip_supply;
	x_CMP_tbl(1).So_Basis			:= p_controller_CMP_rec.so_basis;
	x_CMP_tbl(1).Basis_Type			:= p_controller_CMP_rec.Basis_Type;
	x_CMP_tbl(1).Optional			:= p_controller_CMP_rec.Optional;
	x_CMP_tbl(1).Mutually_Exclusive		:= p_controller_CMP_rec.Mutually_Exclusive;
	x_CMP_tbl(1).Check_Atp			:= p_controller_CMP_rec.Check_Atp;
	x_CMP_tbl(1).Shipping_Allowed		:= p_controller_CMP_rec.Shipping_Allowed;
	x_CMP_tbl(1).Required_To_Ship		:= p_controller_CMP_rec.Required_To_Ship;
	x_CMP_tbl(1).Required_For_Revenue	:= p_controller_CMP_rec.Required_For_Revenue;
	x_CMP_tbl(1).Include_On_Ship_Docs	:= p_controller_CMP_rec.Include_On_Ship_Docs;
	x_CMP_tbl(1).Quantity_Related		:= p_controller_CMP_rec.Quantity_Related;
	x_CMP_tbl(1).Supply_Subinventory	:= p_controller_CMP_rec.Supply_Subinventory;
	x_CMP_tbl(1).Location_Name		:= p_controller_CMP_rec.supply_locator;
	x_CMP_tbl(1).Minimum_Allowed_Quantity	:= p_controller_CMP_rec.low_quantity;
	x_CMP_tbl(1).Maximum_Allowed_Quantity	:= p_controller_CMP_rec.high_quantity;
	x_CMP_tbl(1).comments			:= p_controller_CMP_rec.component_remarks;
	x_CMP_tbl(1).cancel_comments		:= p_controller_CMP_rec.cancel_comments;
	x_CMP_tbl(1).attribute_category 	:= p_controller_CMP_rec.attribute_category;
	x_CMP_tbl(1).attribute1 		:= p_controller_CMP_rec.attribute1;
	x_CMP_tbl(1).attribute2 		:= p_controller_CMP_rec.attribute2;
        x_CMP_tbl(1).attribute3 		:= p_controller_CMP_rec.attribute3;
        x_CMP_tbl(1).attribute4 		:= p_controller_CMP_rec.attribute4;
        x_CMP_tbl(1).attribute5 		:= p_controller_CMP_rec.attribute5;
        x_CMP_tbl(1).attribute6 		:= p_controller_CMP_rec.attribute6;
        x_CMP_tbl(1).attribute7 		:= p_controller_CMP_rec.attribute7;
        x_CMP_tbl(1).attribute8 		:= p_controller_CMP_rec.attribute8;
        x_CMP_tbl(1).attribute9 		:= p_controller_CMP_rec.attribute9;
        x_CMP_tbl(1).attribute10 		:= p_controller_CMP_rec.attribute10;
        x_CMP_tbl(1).attribute11 		:= p_controller_CMP_rec.attribute11;
        x_CMP_tbl(1).attribute12 		:= p_controller_CMP_rec.attribute12;
        x_CMP_tbl(1).attribute13 		:= p_controller_CMP_rec.attribute13;
        x_CMP_tbl(1).attribute14 		:= p_controller_CMP_rec.attribute14;
	x_CMP_tbl(1).attribute15 		:= p_controller_CMP_rec.attribute15;
	x_CMP_tbl(1).from_end_item_unit_number := p_controller_CMP_rec.from_end_item_unit_number;
	x_CMP_tbl(1).to_end_item_unit_number	:= p_controller_CMP_rec.to_end_item_unit_number;
	x_CMP_tbl(1).enforce_int_requirements	:= p_controller_CMP_rec.enforce_int_requirements;

	-- Create unexposed record

	x_unexp_CMP_rec.organization_id	:= p_controller_CMP_rec.organization_id;
	x_unexp_CMP_rec.component_item_id := p_controller_CMP_rec.component_item_id;
	x_unexp_CMP_rec.old_component_sequence_id := p_controller_CMP_rec.old_component_sequence_id;
	x_unexp_CMP_rec.component_sequence_id := p_controller_CMP_rec.component_sequence_id;
	x_unexp_CMP_rec.pick_components	:= p_controller_CMP_rec.pick_components;
	x_unexp_CMP_rec.bill_sequence_id := p_controller_CMP_rec.bill_sequence_id;
	x_unexp_CMP_rec.supply_locator_id := p_controller_CMP_rec.supply_locator_id;
	x_unexp_CMP_rec.bom_item_type := p_controller_CMP_rec.bom_item_type;
	x_unexp_CMP_rec.revised_item_id := p_controller_CMP_rec.revised_item_id;
	x_unexp_CMP_rec.revised_item_sequence_id := p_controller_CMP_rec.revised_item_sequence_id;
	x_unexp_CMP_rec.include_on_bill_docs := p_controller_CMP_rec.include_on_bill_docs;
	x_unexp_CMP_rec.enforce_int_requirements_code := p_controller_CMP_rec.enforce_int_requirements_code;

END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_CMP_tbl                   IN  BOM_BO_PUB.Rev_Component_Tbl_Type
,   p_unexp_CMP_rec             IN  BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type
,   x_controller_CMP_rec        OUT NOCOPY Controller_CMP_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_CMP_rec.change_notice := p_CMP_tbl(1).eco_name;
        x_controller_CMP_rec.organization_code := p_CMP_tbl(1).organization_code;
        x_controller_CMP_rec.revised_item_name := p_CMP_tbl(1).revised_item_name;
        x_controller_CMP_rec.new_item_revision := p_CMP_tbl(1).new_revised_item_revision;
        x_controller_CMP_rec.scheduled_date := p_CMP_tbl(1).start_effective_date;
        x_controller_CMP_rec.disable_date := p_CMP_tbl(1).disable_date;
        x_controller_CMP_rec.operation_sequence_number := p_CMP_tbl(1).operation_sequence_number;
	x_controller_CMP_rec.old_operation_sequence_number :=
				p_CMP_tbl(1).old_operation_sequence_number;
	x_controller_CMP_rec.old_effectivity_date := p_CMP_tbl(1).old_effectivity_date;
	x_controller_CMP_rec.old_from_end_item_unit_number := p_CMP_tbl(1).old_from_end_item_unit_number;
        x_controller_CMP_rec.new_operation_sequence_number := p_CMP_tbl(1).new_operation_sequence_number;
        x_controller_CMP_rec.Component_Item_Name := p_CMP_tbl(1).component_item_name;
        x_controller_CMP_rec.Alternate_BOM_Code := p_CMP_tbl(1).alternate_bom_code;
        x_controller_CMP_rec.acd_type := p_CMP_tbl(1).acd_type;
        x_controller_CMP_rec.item_sequence_number := p_CMP_tbl(1).item_sequence_number;
        x_controller_CMP_rec.component_quantity	:= p_CMP_tbl(1).quantity_per_assembly;
        x_controller_CMP_rec.Planning_factor := p_CMP_tbl(1).planning_percent;
        x_controller_CMP_rec.component_yield_factor := p_CMP_tbl(1).projected_yield;
        x_controller_CMP_rec.Include_In_Cost_Rollup := p_CMP_tbl(1).Include_In_Cost_Rollup;
        x_controller_CMP_rec.Wip_Supply := p_CMP_tbl(1).wip_supply_type;
        x_controller_CMP_rec.So_Basis                   := p_CMP_tbl(1).so_basis;
        x_controller_CMP_rec.Optional                   := p_CMP_tbl(1).Optional;
        x_controller_CMP_rec.Mutually_Exclusive         := p_CMP_tbl(1).Mutually_Exclusive;
        x_controller_CMP_rec.Check_Atp                  := p_CMP_tbl(1).Check_Atp;
        x_controller_CMP_rec.Shipping_Allowed           := p_CMP_tbl(1).Shipping_Allowed;
        x_controller_CMP_rec.Required_To_Ship           := p_CMP_tbl(1).Required_To_Ship;
        x_controller_CMP_rec.Required_For_Revenue       := p_CMP_tbl(1).Required_For_Revenue;
        x_controller_CMP_rec.Include_On_Ship_Docs       := p_CMP_tbl(1).Include_On_Ship_Docs;
        x_controller_CMP_rec.Quantity_Related           := p_CMP_tbl(1).Quantity_Related;
        x_controller_CMP_rec.Supply_Subinventory        := p_CMP_tbl(1).Supply_Subinventory;
        x_controller_CMP_rec.supply_locator		:= p_CMP_tbl(1).location_name;
        x_controller_CMP_rec.low_quantity	:= p_CMP_tbl(1).Minimum_Allowed_Quantity;
        x_controller_CMP_rec.high_quantity	:= p_CMP_tbl(1).maximum_allowed_quantity;
        x_controller_CMP_rec.component_remarks	:= p_CMP_tbl(1).comments;
        x_controller_CMP_rec.cancel_comments            := p_CMP_tbl(1).cancel_comments;
        x_controller_CMP_rec.attribute_category         := p_CMP_tbl(1).attribute_category;
        x_controller_CMP_rec.attribute1                 := p_CMP_tbl(1).attribute1;
        x_controller_CMP_rec.attribute2                 := p_CMP_tbl(1).attribute2;
        x_controller_CMP_rec.attribute3                 := p_CMP_tbl(1).attribute3;
        x_controller_CMP_rec.attribute4                 := p_CMP_tbl(1).attribute4;
        x_controller_CMP_rec.attribute5                 := p_CMP_tbl(1).attribute5;
        x_controller_CMP_rec.attribute6                 := p_CMP_tbl(1).attribute6;
        x_controller_CMP_rec.attribute7                 := p_CMP_tbl(1).attribute7;
        x_controller_CMP_rec.attribute8                 := p_CMP_tbl(1).attribute8;
        x_controller_CMP_rec.attribute9                 := p_CMP_tbl(1).attribute9;
        x_controller_CMP_rec.attribute10                := p_CMP_tbl(1).attribute10;
        x_controller_CMP_rec.attribute11                := p_CMP_tbl(1).attribute11;
        x_controller_CMP_rec.attribute12                := p_CMP_tbl(1).attribute12;
        x_controller_CMP_rec.attribute13                := p_CMP_tbl(1).attribute13;
        x_controller_CMP_rec.attribute14                := p_CMP_tbl(1).attribute14;
        x_controller_CMP_rec.attribute15                := p_CMP_tbl(1).attribute15;
         x_controller_CMP_rec.basis_type                := p_CMP_tbl(1).basis_type;
        x_controller_CMP_rec.from_end_item_unit_number := p_CMP_tbl(1).from_end_item_unit_number;
        x_controller_CMP_rec.to_end_item_unit_number    := p_CMP_tbl(1).to_end_item_unit_number;
        x_controller_CMP_rec.enforce_int_requirements := p_CMP_tbl(1).enforce_int_requirements;

        x_controller_CMP_rec.organization_id := p_unexp_CMP_rec.organization_id;
        x_controller_CMP_rec.component_item_id := p_unexp_CMP_rec.component_item_id;
        x_controller_CMP_rec.old_component_sequence_id := p_unexp_CMP_rec.old_component_sequence_id;
        x_controller_CMP_rec.component_sequence_id := p_unexp_CMP_rec.component_sequence_id;
        x_controller_CMP_rec.pick_components := p_unexp_CMP_rec.pick_components;
        x_controller_CMP_rec.bill_sequence_id := p_unexp_CMP_rec.bill_sequence_id;
        x_controller_CMP_rec.supply_locator_id := p_unexp_CMP_rec.supply_locator_id;
        x_controller_CMP_rec.bom_item_type := p_unexp_CMP_rec.bom_item_type;
        x_controller_CMP_rec.revised_item_sequence_id := p_unexp_CMP_rec.revised_item_sequence_id;
        x_controller_CMP_rec.include_on_bill_docs := p_unexp_CMP_rec.include_on_bill_docs;
        x_controller_CMP_rec.enforce_int_requirements_code := p_unexp_CMP_rec.enforce_int_requirements_code;
END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_CMP_controller_rec        IN OUT NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_CMP_controller_rec	Controller_CMP_Rec_Type := p_CMP_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec	ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision      NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_CMP_rec  => l_CMP_controller_rec
	, x_CMP_tbl 		=> l_rev_component_tbl
	, x_unexp_CMP_rec	=> l_unexp_CMP_rec
	);

	l_rev_component_tbl(1).transaction_type := 'CREATE';

	ENG_FORM_ECO_PVT.Process_ECO
	( x_return_status	=> l_return_status
	, x_msg_count		=> l_msg_count
	, p_control_rec		=> l_control_rec
	, p_rev_component_tbl	=> l_rev_component_tbl
	, p_unexp_rev_comp_rec	=> l_unexp_CMP_rec
	, x_eco_rec             => l_eco_rec
	, x_unexp_eco_rec	=> l_unexp_eco_rec
	, x_unexp_eco_rev_rec	=> l_unexp_eco_rev_rec
	, x_unexp_revised_item_rec  => l_unexp_rev_item_rec
	, x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
	, x_eco_revision_tbl    => l_eco_revision_tbl
	, x_revised_item_tbl    => l_revised_item_tbl
	, x_rev_Component_tbl	=> l_rev_Component_tbl
	, x_ref_designator_tbl	=> l_ref_designator_tbl
	, x_sub_component_tbl	=> l_sub_component_tbl
        , x_rev_operation_tbl      => l_rev_operation_tbl     --add
        , x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
        , x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
	);

	Create_Controller_Rec
	( p_CMP_tbl		=> l_rev_component_tbl
	, p_unexp_CMP_rec	=> l_unexp_CMP_rec
	, x_controller_CMP_rec  => l_CMP_controller_rec
	);

	x_CMP_controller_rec := l_CMP_controller_rec;
	x_return_status	:= l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_CMP_controller_rec        IN  OUT NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_CMP_controller_rec	Controller_CMP_Rec_Type := p_CMP_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_CMP_rec  => l_CMP_controller_rec
	, x_CMP_tbl 		=> l_rev_component_tbl
	, x_unexp_CMP_rec	=> l_unexp_CMP_rec
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
        , p_unexp_rev_comp_rec  => l_unexp_CMP_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
	, x_unexp_eco_rev_rec	=> l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
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
	( p_CMP_tbl		=> l_rev_component_tbl
	, p_unexp_CMP_rec	=> l_unexp_CMP_rec
	, x_controller_CMP_rec  => l_CMP_controller_rec
	);

	x_CMP_controller_rec := l_CMP_controller_rec;
	x_return_status	:= l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_CMP_controller_rec	Controller_CMP_Rec_Type := p_CMP_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add



l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_CMP_rec  => l_CMP_controller_rec
	, x_CMP_tbl 		=> l_rev_component_tbl
	, x_unexp_CMP_rec	=> l_unexp_CMP_rec
	);

        l_rev_component_tbl(1).transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_rev_component_tbl   => l_rev_component_tbl
        , p_unexp_rev_comp_rec  => l_unexp_CMP_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
	, x_unexp_eco_rev_rec	=> l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
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
	( p_CMP_tbl		=> l_rev_component_tbl
	, p_unexp_CMP_rec	=> l_unexp_CMP_rec
	, x_controller_CMP_rec  => l_CMP_controller_rec
	);

	x_return_status	:= l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_CMP_controller_rec        IN  Controller_CMP_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_CMP_controller_rec        IN OUT NOCOPY Controller_CMP_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec 		BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_CMP_controller_rec	Controller_CMP_Rec_Type := p_CMP_controller_rec;
l_ECO_rec		ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec		ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_CMP_rec		BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec		BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec		BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec      BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec  BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add


l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status		VARCHAR2(1);
l_msg_count		NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
	Create_Exp_Unexp_Rec
	( p_controller_CMP_rec  => l_CMP_controller_rec
	, x_CMP_tbl 		=> l_rev_component_tbl
	, x_unexp_CMP_rec	=> l_unexp_CMP_rec
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
        , p_unexp_rev_comp_rec  => l_unexp_CMP_rec
        , x_eco_rec             => l_eco_rec
        , x_unexp_eco_rec       => l_unexp_eco_rec
	, x_unexp_eco_rev_rec	=> l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec  => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec => l_unexp_CMP_rec
        , x_unexp_sub_comp_rec => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec	=> l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
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
	( p_CMP_tbl		=> l_rev_component_tbl
	, p_unexp_CMP_rec	=> l_unexp_CMP_rec
	, x_controller_CMP_rec  => l_CMP_controller_rec
	);

	x_CMP_controller_rec := l_CMP_controller_rec;
	x_return_status	:= l_return_status;
END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text			    OUT NOCOPY VARCHAR2
,   p_CMP_tbl(1)                       IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_CMP_tbl(1)                       OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END CMP_Controller;

/
