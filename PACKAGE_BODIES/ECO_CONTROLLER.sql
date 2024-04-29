--------------------------------------------------------
--  DDL for Package Body ECO_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECO_CONTROLLER" AS
/* $Header: ENGCECOB.pls 115.11 2003/10/30 11:21:31 akumar ship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_ECO_rec        IN  Controller_Eco_Rec_Type
,   x_ECO_rec                   OUT NOCOPY ENG_ECO_PUB.Eco_Rec_Type
,   x_unexp_ECO_rec             OUT NOCOPY ENG_ECO_PUB.ECO_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_ECO_rec.eco_name              := p_controller_ECO_rec.change_notice;
        x_ECO_rec.organization_code     := p_controller_ECO_rec.organization_code;
        x_ECO_rec.change_type_code      := p_controller_ECO_rec.change_order_type;
        x_ECO_rec.description           := p_controller_ECO_rec.description;
        x_ECO_rec.cancellation_comments := p_controller_ECO_rec.cancellation_comments;
        x_ECO_rec.priority_code         := p_controller_ECO_rec.priority_code;
        x_ECO_rec.reason_code           := p_controller_ECO_rec.reason_code;
        x_ECO_rec.eng_implementation_cost := p_controller_ECO_rec.estimated_eng_cost;
        x_ECO_rec.mfg_implementation_cost := p_controller_ECO_rec.estimated_mfg_cost;
        x_ECO_rec.approval_list_name    := p_controller_ECO_rec.approval_list_name;
        x_ECO_rec.attribute_category    := p_controller_ECO_rec.attribute_category;
        x_ECO_rec.attribute1            := p_controller_ECO_rec.attribute1;
        x_ECO_rec.attribute2            := p_controller_ECO_rec.attribute2;
        x_ECO_rec.attribute3            := p_controller_ECO_rec.attribute3;
        x_ECO_rec.attribute4            := p_controller_ECO_rec.attribute4;
        x_ECO_rec.attribute5            := p_controller_ECO_rec.attribute5;
        x_ECO_rec.attribute6            := p_controller_ECO_rec.attribute6;
        x_ECO_rec.attribute7            := p_controller_ECO_rec.attribute7;
        x_ECO_rec.attribute8            := p_controller_ECO_rec.attribute8;
        x_ECO_rec.attribute9            := p_controller_ECO_rec.attribute9;
        x_ECO_rec.attribute10           := p_controller_ECO_rec.attribute10;
        x_ECO_rec.attribute11           := p_controller_ECO_rec.attribute11;
        x_ECO_rec.attribute12           := p_controller_ECO_rec.attribute12;
        x_ECO_rec.attribute13           := p_controller_ECO_rec.attribute13;
        x_ECO_rec.attribute14           := p_controller_ECO_rec.attribute14;
        x_ECO_rec.attribute15           := p_controller_ECO_rec.attribute15;
       -- x_ECO_rec.hierarchy_flag        := p_controller_ECO_rec.hierarchy_flag;
        x_ECO_rec.organization_hierarchy:= p_controller_ECO_rec.organization_hierarchy;
	--added
        x_ECO_rec.approval_request_date := p_controller_ECO_rec.approval_request_date;
        x_ECO_rec.approval_date   := p_controller_ECO_rec.approval_date;
        --11.5.10
	x_ECO_rec.plm_or_erp_change :=p_controller_ECO_rec.plm_or_erp_change;

        -- Create unexposed record

        x_unexp_ECO_rec.organization_id := p_controller_ECO_rec.organization_id;
        x_unexp_ECO_rec.initiation_date := p_controller_ECO_rec.initiation_date;
        x_unexp_ECO_rec.implementation_date := p_controller_ECO_rec.implementation_date;
        x_unexp_ECO_rec.cancellation_date := p_controller_ECO_rec.cancellation_date;
        x_unexp_ECO_rec.approval_list_id := p_controller_ECO_rec.approval_list_id;
        x_unexp_ECO_rec.change_order_type_id := p_controller_ECO_rec.change_order_type_id;
        x_unexp_ECO_rec.responsible_org_id :=p_controller_ECO_rec.responsible_organization_id;
        x_unexp_ECO_rec.requestor_id    := p_controller_ECO_rec.requestor_id;
--Uncommented for bug 307761
 x_unexp_ECO_rec.project_id      := p_controller_ECO_rec.project_id;
 x_unexp_ECO_rec.task_id         := p_controller_ECO_rec.task_id;

	x_unexp_ECO_rec.change_id             := p_controller_ECO_rec.change_id;
	x_unexp_ECO_rec.change_mgmt_type_code := p_controller_ECO_rec.change_mgmt_type_code;
        x_unexp_ECO_rec.hierarchy_id          := p_controller_ECO_rec.hierarchy_id;


	--added
        x_unexp_ECO_rec.status_type           := p_controller_ECO_rec.status_type;
	x_unexp_ECO_rec.approval_status_type  := p_controller_ECO_rec.approval_status_type;


END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_ECO_rec                   IN  ENG_ECO_PUB.Eco_Rec_Type
,   p_unexp_ECO_rec             IN  ENG_ECO_PUB.ECO_Unexposed_Rec_Type
,   x_controller_ECO_rec        OUT NOCOPY Controller_Eco_Rec_Type
)
IS
BEGIN

        -- Create exposed record

        x_controller_ECO_rec.change_notice         := p_ECO_rec.eco_name;
        x_controller_ECO_rec.organization_code     := p_ECO_rec.organization_code;
        x_controller_ECO_rec.change_order_type     := p_ECO_rec.change_type_code;
        x_controller_ECO_rec.description           := p_ECO_rec.description;
        x_controller_ECO_rec.cancellation_comments := p_ECO_rec.cancellation_comments;
        x_controller_ECO_rec.priority_code         := p_ECO_rec.priority_code;
        x_controller_ECO_rec.reason_code           := p_ECO_rec.reason_code;
        x_controller_ECO_rec.estimated_eng_cost := p_ECO_rec.eng_implementation_cost;
        x_controller_ECO_rec.estimated_mfg_cost := p_ECO_rec.mfg_implementation_cost;
        x_controller_ECO_rec.approval_list_name    := p_ECO_rec.approval_list_name;
        x_controller_ECO_rec.attribute_category    := p_ECO_rec.attribute_category;
        x_controller_ECO_rec.attribute1            := p_ECO_rec.attribute1;
        x_controller_ECO_rec.attribute2            := p_ECO_rec.attribute2;
        x_controller_ECO_rec.attribute3            := p_ECO_rec.attribute3;
        x_controller_ECO_rec.attribute4            := p_ECO_rec.attribute4;
        x_controller_ECO_rec.attribute5            := p_ECO_rec.attribute5;
        x_controller_ECO_rec.attribute6            := p_ECO_rec.attribute6;
        x_controller_ECO_rec.attribute7            := p_ECO_rec.attribute7;
        x_controller_ECO_rec.attribute8            := p_ECO_rec.attribute8;
        x_controller_ECO_rec.attribute9            := p_ECO_rec.attribute9;
        x_controller_ECO_rec.attribute10           := p_ECO_rec.attribute10;
        x_controller_ECO_rec.attribute11           := p_ECO_rec.attribute11;
        x_controller_ECO_rec.attribute12           := p_ECO_rec.attribute12;
        x_controller_ECO_rec.attribute13           := p_ECO_rec.attribute13;
        x_controller_ECO_rec.attribute14           := p_ECO_rec.attribute14;
        x_controller_ECO_rec.attribute15           := p_ECO_rec.attribute15;
     -- x_controller_ECO_rec.hierarchy_flag        := p_ECO_rec.hierarchy_flag;
        x_controller_ECO_rec.organization_hierarchy:= p_ECO_rec.organization_hierarchy;
        x_controller_ECO_rec.approval_date         := p_ECO_rec.approval_date;
        x_controller_ECO_rec.approval_request_date := p_ECO_rec.approval_request_date;

        --11.5.10
        x_controller_ECO_rec.plm_or_erp_change :=p_ECO_rec.plm_or_erp_change;

	x_controller_ECO_rec.status_type           := p_unexp_ECO_rec.status_type;
        x_controller_ECO_rec.approval_status_type  := p_unexp_ECO_rec.approval_status_type;
      	x_controller_ECO_rec.organization_id       := p_unexp_ECO_rec.organization_id;
        x_controller_ECO_rec.initiation_date       := p_unexp_ECO_rec.initiation_date;
        x_controller_ECO_rec.implementation_date   := p_unexp_ECO_rec.implementation_date;
        x_controller_ECO_rec.cancellation_date     := p_unexp_ECO_rec.cancellation_date;
        x_controller_ECO_rec.approval_list_id      := p_unexp_ECO_rec.approval_list_id;
        x_controller_ECO_rec.change_order_type_id  := p_unexp_ECO_rec.change_order_type_id;
        x_controller_ECO_rec.responsible_organization_id := p_unexp_ECO_rec.responsible_org_id;
        x_controller_ECO_rec.requestor_id          := p_unexp_ECO_Rec.requestor_id;
      --x_controller_ECO_rec.project_id            := p_unexp_ECO_rec.project_id;
      --x_controller_ECO_rec.task_id               := p_unexp_ECO_rec.task_id;
	--------------
        x_controller_ECO_rec.change_id             := p_unexp_ECO_rec.change_id;
 	x_controller_ECO_rec.change_mgmt_type_code := p_unexp_ECO_rec.change_mgmt_type_code;
       x_controller_ECO_rec.hierarchy_id          := p_unexp_ECO_rec.hierarchy_id;


END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_ECO_controller_rec    Controller_Eco_Rec_Type := p_ECO_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l1_ECO_rec              ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_ECO_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec	BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_ECO_rec  => l_ECO_controller_rec
        , x_ECO_rec             => l_ECO_rec
        , x_unexp_ECO_rec       => l_unexp_ECO_rec
        );

        l_ECO_rec.transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count               => l_msg_count
        , p_control_rec             => l_control_rec
        , p_ECO_rec                 => l_eco_rec
        , p_unexp_eco_rec           => l_unexp_ECO_rec
        , x_unexp_eco_rec           => l_unexp_ECO_rec
        , x_unexp_eco_rev_rec       => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_ECO_rec                => l1_eco_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl     --add
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_ECO_rec             => l1_eco_rec
        , p_unexp_eco_rec       => l_unexp_eco_rec
        , x_controller_ECO_rec  => l_eco_controller_rec
        );

        x_eco_controller_rec := l_eco_controller_rec;
        x_return_status := l_return_status;
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_ECO_controller_rec    Controller_Eco_Rec_Type := p_ECO_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_ECO_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec	BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN

         Create_Exp_Unexp_Rec
        ( p_controller_ECO_rec  => l_ECO_controller_rec
        , x_ECO_rec             => l_ECO_rec
        , x_unexp_ECO_rec       => l_unexp_ECO_rec
        );

           IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_ECO_rec.transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_ECO_rec.transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_ECO_rec.transaction_type := 'DELETE';
        END IF;


        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_ECO_rec                => l_ECO_rec
        , p_unexp_eco_rec          => l_unexp_ECO_rec
        , x_unexp_eco_rec          => l_unexp_ECO_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_ECO_rec                => l_ECO_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl     --add
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        Create_Controller_Rec
        ( p_ECO_rec             => l_eco_rec
        , p_unexp_eco_rec       => l_unexp_eco_rec
        , x_controller_ECO_rec  => l_eco_controller_rec
        );

        x_eco_controller_rec := l_eco_controller_rec;
        x_return_status := l_return_status;
END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_ECO_controller_rec    Controller_Eco_Rec_Type := p_ECO_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_ECO_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec	BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add

l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_ECO_rec  => l_ECO_controller_rec
        , x_ECO_rec             => l_ECO_rec
        , x_unexp_ECO_rec       => l_unexp_ECO_rec
        );

        l_control_rec.entity_validation := TRUE;
        l_control_rec.write_to_db := TRUE;
        l_control_rec.process_entity := ENG_Globals.G_ENTITY_ECO;

        l_ECO_rec.transaction_type := 'DELETE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_ECO_rec             => l_eco_rec
        , p_unexp_eco_rec       => l_unexp_ECO_rec
        , x_unexp_eco_rec       => l_unexp_ECO_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_ECO_rec                => l_eco_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl     --add
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
        );

        x_return_status := l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_ECO_controller_rec        IN  Controller_Eco_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_ECO_controller_rec        IN OUT NOCOPY Controller_Eco_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_ECO_controller_rec    Controller_Eco_Rec_Type := p_ECO_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_ECO_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_rev_item_rec    ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
l_unexp_rev_op_rec	BOM_RTG_PUB.Rev_Op_Unexposed_Rec_Type;       --add
l_unexp_rev_op_res_rec	BOM_RTG_PUB.Rev_Op_Res_Unexposed_Rec_Type;   --add
l_unexp_rev_sub_res_rec	BOM_RTG_PUB.Rev_Sub_Res_Unexposed_Rec_Type;  --add
l_eco_revision_tbl      ENG_Eco_PUB.Eco_Revision_Tbl_Type;
l_revised_item_tbl      ENG_Eco_PUB.Revised_Item_Tbl_Type;
l_rev_component_tbl     BOM_BO_PUB.Rev_Component_Tbl_Type;
l_ref_designator_tbl    BOM_BO_PUB.Ref_Designator_Tbl_Type;
l_sub_component_tbl     BOM_BO_PUB.Sub_Component_Tbl_Type;
l_rev_operation_tbl     BOM_RTG_PUB.Rev_Operation_Tbl_Type;     --add
l_rev_op_resource_tbl   BOM_RTG_PUB.Rev_Op_Resource_Tbl_Type;   --add
l_rev_sub_resource_tbl  BOM_RTG_PUB.Rev_Sub_Resource_Tbl_Type;  --add
l_mesg_token_tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_other_message         VARCHAR2(50);
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
l_disable_revision   NUMBER:=2; --BUG 3034642
BEGIN

        Create_Exp_Unexp_Rec
        ( p_controller_ECO_rec  => l_ECO_controller_rec
        , x_ECO_rec             => l_ECO_rec
        , x_unexp_ECO_rec       => l_unexp_ECO_rec
        );


        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_ECO_rec.transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_ECO_rec.transaction_type := 'UPDATE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , p_control_rec         => l_control_rec
        , p_ECO_rec             => l_eco_rec
        , p_unexp_eco_rec       => l_unexp_ECO_rec
        , x_unexp_eco_rec       => l_unexp_ECO_rec
        , x_unexp_eco_rev_rec   => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_rev_item_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec      --add
        , x_unexp_rev_op_res_rec   => l_unexp_rev_op_res_rec  --add
        , x_unexp_rev_sub_res_rec  => l_unexp_rev_sub_res_rec --add
        , x_ECO_rec                => l_eco_rec
        , x_eco_revision_tbl       => l_eco_revision_tbl
        , x_revised_item_tbl       => l_revised_item_tbl
        , x_rev_Component_tbl      => l_rev_Component_tbl
        , x_ref_designator_tbl     => l_ref_designator_tbl
        , x_sub_component_tbl      => l_sub_component_tbl
	, x_rev_operation_tbl      => l_rev_operation_tbl     --add
	, x_rev_op_resource_tbl    => l_rev_op_resource_tbl   --add
	, x_rev_sub_resource_tbl   => l_rev_sub_resource_tbl  --add
	,   x_disable_revision       => l_disable_revision  --BUG 3034642
      );
       Create_Controller_Rec
        ( p_ECO_rec             => l_eco_rec
        , p_unexp_eco_rec       => l_unexp_eco_rec
        , x_controller_ECO_rec  => l_eco_controller_rec
        );
        x_eco_controller_rec := l_eco_controller_rec;
        x_return_status := l_return_status;

/*
EXCEPTION
      WHEN OTHERS THEN
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


       x_return_status := 1;
*/


END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                       OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
);
*/

END ECO_Controller;

/
