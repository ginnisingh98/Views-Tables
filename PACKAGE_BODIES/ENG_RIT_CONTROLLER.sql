--------------------------------------------------------
--  DDL for Package Body ENG_RIT_CONTROLLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_RIT_CONTROLLER" AS
/* $Header: ENGCRICB.pls 120.0 2006/02/12 23:39:49 asjohal noship $ */

-- Procedure Create_Exp_Unexp_Rec

PROCEDURE Create_Exp_Unexp_Rec
(   p_controller_RIT_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_RIT_tbl                   OUT NOCOPY ENG_ECO_PUB.Revised_Item_Tbl_Type
,   x_unexp_RIT_rec             OUT NOCOPY ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_RIT_tbl(1).eco_name                      := p_controller_RIT_rec.eco_name;
        x_RIT_tbl(1).organization_code             := p_controller_RIT_rec.organization_code;
        x_RIT_tbl(1).revised_item_name             := p_controller_RIT_rec.revised_item_name;
        x_RIT_tbl(1).new_revised_item_revision     := p_controller_RIT_rec.new_revised_item_revision;

        /* Item revision description enhancement Bug: 1667419*/
        x_RIT_tbl(1).new_revised_item_rev_desc     := p_controller_RIT_rec.new_revised_item_rev_desc;

        x_RIT_tbl(1).updated_revised_item_revision := p_controller_RIT_rec.updated_revised_item_revision;
        x_RIT_tbl(1).start_effective_date          := p_controller_RIT_rec.start_effective_date;
        x_RIT_tbl(1).new_effective_date            := p_controller_RIT_rec.new_effective_date;
        x_RIT_tbl(1).from_end_item_unit_number     := p_controller_RIT_rec.start_from_unit_number;
        x_RIT_tbl(1).new_from_end_item_unit_number := p_controller_RIT_rec.new_from_end_item_unit_number;
        x_RIT_tbl(1).alternate_bom_code            := p_controller_RIT_rec.alternate_bom_code;
        x_RIT_tbl(1).status_type                   := p_controller_RIT_rec.status_type;
        x_RIT_tbl(1).mrp_active                    := p_controller_RIT_rec.mrp_active;
        x_RIT_tbl(1).earliest_effective_date       := p_controller_RIT_rec.earliest_effective_date;
        x_RIT_tbl(1).use_up_item_name              := p_controller_RIT_rec.use_up_item_name;
        x_RIT_tbl(1).use_up_plan_name              := p_controller_RIT_rec.use_up_plan_name;
        x_RIT_tbl(1).Requestor                     := p_controller_RIT_rec.Requestor;
        x_RIT_tbl(1).disposition_type              := p_controller_RIT_rec.disposition_type;
        x_RIT_tbl(1).update_wip                    := p_controller_RIT_rec.update_wip;
        x_RIT_tbl(1).cancel_comments               := p_controller_RIT_rec.cancel_comments;
        x_RIT_tbl(1).change_description            := p_controller_RIT_rec.change_description;
        x_RIT_tbl(1).attribute_category            := p_controller_RIT_rec.attribute_category;
        x_RIT_tbl(1).attribute1                    := p_controller_RIT_rec.attribute1;
        x_RIT_tbl(1).attribute2                    := p_controller_RIT_rec.attribute2;
        x_RIT_tbl(1).attribute3                    := p_controller_RIT_rec.attribute3;
        x_RIT_tbl(1).attribute4                    := p_controller_RIT_rec.attribute4;
        x_RIT_tbl(1).attribute5                    := p_controller_RIT_rec.attribute5;
        x_RIT_tbl(1).attribute6                    := p_controller_RIT_rec.attribute6;
        x_RIT_tbl(1).attribute7                    := p_controller_RIT_rec.attribute7;
        x_RIT_tbl(1).attribute8                    := p_controller_RIT_rec.attribute8;
        x_RIT_tbl(1).attribute9                    := p_controller_RIT_rec.attribute9;
        x_RIT_tbl(1).attribute10                   := p_controller_RIT_rec.attribute10;
        x_RIT_tbl(1).attribute11                   := p_controller_RIT_rec.attribute11;
        x_RIT_tbl(1).attribute12                   := p_controller_RIT_rec.attribute12;
        x_RIT_tbl(1).attribute13                   := p_controller_RIT_rec.attribute13;
        x_RIT_tbl(1).attribute14                   := p_controller_RIT_rec.attribute14;
        x_RIT_tbl(1).attribute15                   := p_controller_RIT_rec.attribute15;
        x_RIT_tbl(1).original_system_reference     := p_controller_RIT_rec.original_system_reference;
        x_RIT_tbl(1).Return_Status                 := p_controller_RIT_rec.Return_Status;
        x_RIT_tbl(1).Transaction_Type              := p_controller_RIT_rec.Transaction_Type;
        x_RIT_tbl(1).From_Work_Order               := p_controller_RIT_rec.From_Work_Order;
        x_RIT_tbl(1).To_Work_Order                 := p_controller_RIT_rec.To_Work_Order;
        x_RIT_tbl(1).From_Cumulative_Quantity      := p_controller_RIT_rec.From_Cumulative_Quantity;
        x_RIT_tbl(1).Lot_Number                    := p_controller_RIT_rec.Lot_Number;
        x_RIT_tbl(1).Completion_Subinventory       := p_controller_RIT_rec.Completion_Subinventory;
        x_RIT_tbl(1).Completion_Location_Name      := p_controller_RIT_rec.Completion_Location_Name;
        x_RIT_tbl(1).Priority                      := p_controller_RIT_rec.Priority;
        x_RIT_tbl(1).Ctp_Flag                      := p_controller_RIT_rec.CTP_Flag;
        x_RIT_tbl(1).New_Routing_Revision          := p_controller_RIT_rec.New_Routing_Revision;
        x_RIT_tbl(1).Updated_Routing_Revision      := p_controller_RIT_rec.Updated_Routing_Revision;
        x_RIT_tbl(1).Routing_Comment               := p_controller_RIT_rec.Routing_Comment;
        x_RIT_tbl(1).Eco_For_Production            := p_controller_RIT_rec.Eco_For_Production;
        x_RIT_tbl(1).Reschedule_Comments           := p_controller_RIT_rec.Reschedule_Comments; -- Bug 3589974
        -- Create unexposed record

        x_unexp_RIT_rec.organization_id          := p_controller_RIT_rec.organization_id;
        x_unexp_RIT_rec.revised_item_id          := p_controller_RIT_rec.revised_item_id;
        x_unexp_RIT_rec.implementation_date      := p_controller_RIT_rec.implementation_date;
        x_unexp_RIT_rec.auto_implement_date      := p_controller_RIT_rec.auto_implement_date;
        x_unexp_RIT_rec.cancellation_date        := p_controller_RIT_rec.cancellation_date;
        x_unexp_RIT_rec.bill_sequence_id         := p_controller_RIT_rec.bill_sequence_id;
        x_unexp_RIT_rec.use_up_item_id           := p_controller_RIT_rec.use_up_item_id;
        x_unexp_RIT_rec.use_up                   := p_controller_RIT_rec.use_up;
        x_unexp_RIT_rec.Requestor_id             := p_controller_RIT_rec.Requestor_id;
        x_unexp_RIT_rec.revised_item_sequence_id := p_controller_RIT_rec.revised_item_sequence_id;
        x_unexp_RIT_rec.routing_sequence_id      := p_controller_RIT_rec.routing_sequence_id;
        x_unexp_RIT_rec.from_wip_entity_id       := p_controller_RIT_rec.from_wip_entity_id;
        x_unexp_RIT_rec.to_wip_entity_id         := p_controller_RIT_rec.to_wip_entity_id;
        x_unexp_RIT_rec.cfm_routing_flag         := p_controller_RIT_rec.cfm_routing_flag;
        x_unexp_RIT_rec.completion_locator_id    := p_controller_RIT_rec.completion_locator_id;

	-------
        x_unexp_RIT_rec.change_id                := p_controller_RIT_rec.change_id;



END Create_Exp_Unexp_Rec;

PROCEDURE Create_Controller_Rec
(   p_RIT_tbl                   IN  ENG_ECO_PUB.Revised_Item_Tbl_Type
,   p_unexp_RIT_rec             IN  ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type
,   x_controller_RIT_rec        OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
)
IS
BEGIN
        -- Create exposed record

        x_controller_RIT_rec.eco_name                      := p_RIT_tbl(1).eco_name;
        x_controller_RIT_rec.organization_code             := p_RIT_tbl(1).organization_code;
        x_controller_RIT_rec.revised_item_name             := p_RIT_tbl(1).revised_item_name;
        x_controller_RIT_rec.new_revised_item_revision     := NVL(p_RIT_tbl(1).updated_revised_item_revision,
                                                                  p_RIT_tbl(1).new_revised_item_revision);
        x_controller_RIT_rec.new_revised_item_rev_desc := p_RIT_tbl(1).new_revised_item_rev_desc ;
        x_controller_RIT_rec.updated_revised_item_revision := p_RIT_tbl(1).updated_revised_item_revision ;
        x_controller_RIT_rec.start_effective_date          := NVL(p_RIT_tbl(1).new_effective_date,
                                                                  p_RIT_tbl(1).start_effective_date);
        x_controller_RIT_rec.new_effective_date            := p_RIT_tbl(1).new_effective_date ;
        x_controller_RIT_rec.start_from_unit_number     := NVL(p_RIT_tbl(1).new_from_end_item_unit_number,
                                                                  p_RIT_tbl(1).from_end_item_unit_number);
        x_controller_RIT_rec.new_from_end_item_unit_number            := p_RIT_tbl(1).new_from_end_item_unit_number ;
        x_controller_RIT_rec.Original_System_Reference     := p_RIT_tbl(1).Original_System_Reference;
        x_controller_RIT_rec.alternate_bom_code            := p_RIT_tbl(1).alternate_bom_code;
        x_controller_RIT_rec.status_type                   := p_RIT_tbl(1).status_type;
        x_controller_RIT_rec.mrp_active                    := p_RIT_tbl(1).mrp_active;
        x_controller_RIT_rec.earliest_effective_date       := p_RIT_tbl(1).earliest_effective_date;
        x_controller_RIT_rec.use_up_item_name              := p_RIT_tbl(1).use_up_item_name;
        x_controller_RIT_rec.use_up_plan_name              := p_RIT_tbl(1).use_up_plan_name;
        x_controller_RIT_rec.requestor                     := p_RIT_tbl(1).requestor;
        x_controller_RIT_rec.disposition_type              := p_RIT_tbl(1).disposition_type;
        x_controller_RIT_rec.update_wip                    := p_RIT_tbl(1).update_wip;
        x_controller_RIT_rec.cancel_comments               := p_RIT_tbl(1).cancel_comments;
        x_controller_RIT_rec.change_description            := p_RIT_tbl(1).change_description;
        x_controller_RIT_rec.attribute_category            := p_RIT_tbl(1).attribute_category;
        x_controller_RIT_rec.attribute1                    := p_RIT_tbl(1).attribute1;
        x_controller_RIT_rec.attribute2                    := p_RIT_tbl(1).attribute2;
        x_controller_RIT_rec.attribute3                    := p_RIT_tbl(1).attribute3;
        x_controller_RIT_rec.attribute4                    := p_RIT_tbl(1).attribute4;
        x_controller_RIT_rec.attribute5                    := p_RIT_tbl(1).attribute5;
        x_controller_RIT_rec.attribute6                    := p_RIT_tbl(1).attribute6;
        x_controller_RIT_rec.attribute7                    := p_RIT_tbl(1).attribute7;
        x_controller_RIT_rec.attribute8                    := p_RIT_tbl(1).attribute8;
        x_controller_RIT_rec.attribute9                    := p_RIT_tbl(1).attribute9;
        x_controller_RIT_rec.attribute10                   := p_RIT_tbl(1).attribute10;
        x_controller_RIT_rec.attribute11                   := p_RIT_tbl(1).attribute11;
        x_controller_RIT_rec.attribute12                   := p_RIT_tbl(1).attribute12;
        x_controller_RIT_rec.attribute13                   := p_RIT_tbl(1).attribute13;
        x_controller_RIT_rec.attribute14                   := p_RIT_tbl(1).attribute14;
        x_controller_RIT_rec.attribute15                   := p_RIT_tbl(1).attribute15;
        x_controller_RIT_rec.Return_Status                 := p_RIT_tbl(1).Return_Status;
        x_controller_RIT_rec.Transaction_Type              := p_RIT_tbl(1).Transaction_Type;
        x_controller_RIT_rec.from_work_order               := p_RIT_tbl(1).from_work_order;
        x_controller_RIT_rec.to_work_order                 := p_RIT_tbl(1).to_work_order;
        x_controller_RIT_rec.from_cumulative_quantity      := p_RIT_tbl(1).from_cumulative_quantity;
        x_controller_RIT_rec.lot_number                    := p_RIT_tbl(1).lot_number;
        x_controller_RIT_rec.completion_subinventory       := p_RIT_tbl(1).completion_subinventory;
        x_controller_RIT_rec.completion_location_name      := p_RIT_tbl(1).completion_location_name;
        x_controller_RIT_rec.priority                      := p_RIT_tbl(1).priority;
        x_controller_RIT_rec.ctp_flag                      := p_RIT_tbl(1).ctp_flag;
        x_controller_RIT_rec.New_Routing_Revision          := NVL(p_RIT_tbl(1).updated_routing_revision,
                                                                  p_RIT_tbl(1).new_routing_revision);
        x_controller_RIT_rec.updated_routing_revision      := p_RIT_tbl(1).updated_routing_revision ;
        x_controller_RIT_rec.routing_comment               := p_RIT_tbl(1).routing_comment;
        x_controller_RIT_rec.eco_for_production            := p_RIT_tbl(1).eco_for_production;
        x_controller_RIT_rec.organization_id               := p_unexp_RIT_rec.organization_id;
        x_controller_RIT_rec.revised_item_id               := p_unexp_RIT_rec.revised_item_id;
        x_controller_RIT_rec.implementation_date           := p_unexp_RIT_rec.implementation_date;
        x_controller_RIT_rec.auto_implement_date           := p_unexp_RIT_rec.auto_implement_date;
        x_controller_RIT_rec.cancellation_date             := p_unexp_RIT_rec.cancellation_date;
        x_controller_RIT_rec.bill_sequence_id              := p_unexp_RIT_rec.bill_sequence_id;
        x_controller_RIT_rec.use_up_item_id                := p_unexp_RIT_rec.use_up_item_id;
        x_controller_RIT_rec.use_up                        := p_unexp_RIT_rec.use_up;
        x_controller_RIT_rec.requestor_id                  := p_unexp_RIT_rec.requestor_id;
        x_controller_RIT_rec.revised_item_sequence_id      := p_unexp_RIT_rec.revised_item_sequence_id;
        x_controller_RIT_rec.routing_sequence_id           := p_unexp_RIT_Rec.routing_sequence_id;
        x_controller_RIT_rec.from_wip_entity_id            := p_unexp_RIT_Rec.from_wip_entity_id;
        x_controller_RIT_rec.to_wip_entity_id              := p_unexp_RIT_Rec.to_wip_entity_id;
        x_controller_RIT_rec.cfm_routing_flag              := p_unexp_RIT_Rec.cfm_routing_flag;
        x_controller_RIT_rec.completion_locator_id         := p_unexp_RIT_Rec.completion_locator_id;
	------
        x_controller_RIT_rec.change_id         := p_unexp_RIT_Rec.change_id;

END Create_Controller_Rec;

-- Procedure Initialize_Record

PROCEDURE Initialize_Record
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_RIT_controller_rec        IN OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RIT_controller_rec    ENG_RIT_Controller.Controller_Rit_Rec_Type := p_rit_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_RIT_rec         ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
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
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision      NUMBER; --Bug 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RIT_rec  => l_RIT_controller_rec
        , x_RIT_tbl             => l_revised_item_tbl
        , x_unexp_RIT_rec       => l_unexp_RIT_rec
        );

        l_revised_item_tbl(1).transaction_type := 'CREATE';

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_revised_item_tbl       => l_revised_item_tbl
        , p_unexp_rev_item_rec     => l_unexp_RIT_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_RIT_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
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
	,   x_disable_revision     =>  l_disable_revision --Bug no:3034642
        );

        Create_Controller_Rec
        ( p_RIT_tbl             => l_revised_item_tbl
        , p_unexp_RIT_rec       => l_unexp_RIT_rec
        , x_controller_RIT_rec  => l_RIT_controller_rec
        );

        x_RIT_controller_rec := l_RIT_controller_rec;
        x_return_status := l_return_status;
        --dbms_output.put_line('Status: ' ||
        --                        to_char(l_revised_item_tbl(1).status_type));
        --dbms_output.put_line('Early effective date: ' ||
        --                        to_char(l_revised_item_tbl(1).earliest_effective_date));
        --dbms_output.put_line('Update_WIP: ' ||
        --                        to_char(l_revised_item_tbl(1).update_wip));
        --dbms_output.put_line('MRP_Active: ' ||
        --                        to_char(l_revised_item_tbl(1).mrp_active));
        --dbms_output.put_line('Requestor Id: ' ||
        --                        to_char(l_unexp_rit_rec.requestor_id));
        --dbms_output.put_line('Implementation date: ' ||
        --                        to_char(l_unexp_rit_rec.implementation_date));
        --dbms_output.put_line('Cancellation date: ' ||
        --                        to_char(l_unexp_rit_rec.cancellation_date));
        --dbms_output.put_line('disposition_type:' ||
        --                        to_char(l_revised_item_tbl(1).disposition_type));
END Initialize_Record;

-- Procedure Validate_And_Write

PROCEDURE Validate_And_Write
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RIT_controller_rec        IN OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RIT_controller_rec    ENG_RIT_Controller.Controller_Rit_Rec_Type := p_rit_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_RIT_rec         ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
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
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision      NUMBER; --Bug 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RIT_rec  => l_RIT_controller_rec
        , x_RIT_tbl             => l_revised_item_tbl
        , x_unexp_RIT_rec       => l_unexp_RIT_rec
        );

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_revised_item_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_revised_item_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_revised_item_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_revised_item_tbl       => l_revised_item_tbl
        , p_unexp_rev_item_rec     => l_unexp_RIT_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_RIT_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
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
	,   x_disable_revision     =>  l_disable_revision --Bug no:3034642
        );

        Create_Controller_Rec
        ( p_RIT_tbl             => l_revised_item_tbl
        , p_unexp_RIT_rec       => l_unexp_RIT_rec
        , x_controller_RIT_rec  => l_RIT_controller_rec
        );

        x_RIT_controller_rec := l_RIT_controller_rec;
        x_return_status := l_return_status;

END Validate_And_Write;

-- Procedure Delete_Row

PROCEDURE Delete_Row
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RIT_controller_rec    ENG_RIT_Controller.Controller_Rit_Rec_Type := p_rit_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_RIT_rec         ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
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
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_disable_revision      NUMBER; --Bug 3034642
BEGIN
        Create_Exp_Unexp_Rec
        ( p_controller_RIT_rec  => l_RIT_controller_rec
        , x_RIT_tbl             => l_revised_item_tbl
        , x_unexp_RIT_rec       => l_unexp_RIT_rec
        );

        l_control_rec.process_entity := ENG_Globals.G_ENTITY_ECO;

        l_revised_item_tbl(1).transaction_type := 'DELETE';


        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_revised_item_tbl       => l_revised_item_tbl
        , p_unexp_rev_item_rec     => l_unexp_RIT_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_RIT_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
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
	,   x_disable_revision     =>  l_disable_revision --Bug no:3034642
        );

        Create_Controller_Rec
        ( p_RIT_tbl             => l_revised_item_tbl
        , p_unexp_RIT_rec       => l_unexp_RIT_rec
        , x_controller_RIT_rec  => l_RIT_controller_rec
        );

        x_return_status := l_return_status;
END Delete_Row;

--Procedure Change_Attibute

PROCEDURE Change_Attribute
(   p_RIT_controller_rec        IN  ENG_RIT_Controller.Controller_Rit_Rec_Type
,   p_control_rec               IN  BOM_BO_PUB.Control_Rec_Type
,   p_record_status             IN  VARCHAR2
,   x_RIT_controller_rec        IN OUT NOCOPY ENG_RIT_Controller.Controller_Rit_Rec_Type
,   x_Mesg_Token_Tbl            OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status             OUT NOCOPY VARCHAR2
,   x_disable_revision          OUT NOCOPY NUMBER --Bug no:3034642
)
IS
l_control_rec           BOM_BO_PUB.Control_Rec_Type := p_control_rec;
l_RIT_controller_rec    ENG_RIT_Controller.Controller_Rit_Rec_Type := p_rit_controller_rec;
l_ECO_rec               ENG_ECO_PUB.ECO_Rec_Type;
l_unexp_eco_rec         ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_unexp_eco_rev_rec     ENG_ECO_PUB.Eco_Rev_Unexposed_Rec_Type;
l_unexp_RIT_rec         ENG_ECO_PUB.Rev_Item_Unexposed_Rec_Type;
l_unexp_rev_comp_rec    BOM_BO_PUB.Rev_Comp_Unexposed_Rec_Type;
l_unexp_SBC_rec         BOM_BO_PUB.Sub_Comp_Unexposed_Rec_Type;
l_unexp_RFD_rec         BOM_BO_PUB.Ref_Desg_Unexposed_Rec_Type;
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
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_other_message         VARCHAR2(50);
l_other_token_tbl       Error_Handler.Token_Tbl_Type;
BEGIN

IF BOM_Globals.get_debug = 'Y' THEN
     error_handler.write_debug('at the beginnig of change attribute');
END IF;
        Create_Exp_Unexp_Rec
        ( p_controller_RIT_rec  => l_RIT_controller_rec
        , x_RIT_tbl             => l_revised_item_tbl
        , x_unexp_RIT_rec       => l_unexp_RIT_rec
        );

        --dbms_output.put_line('Revised item id: ' ||
        --                        to_char(l_unexp_rit_rec.revised_item_id));
        --dbms_output.put_line('Organization id: ' ||
        --                        to_char(l_unexp_rit_rec.organization_id));
        -- dbms_output.put_line('Start Effective Date: ' ||
        --                        to_char(l_revised_item_tbl(1).start_effective_date));
        --dbms_output.put_line('New item revision: ' ||
        --                        l_revised_item_tbl(1).new_revised_item_revision);
        --dbms_output.put_line('ECO name: ' ||
         --                       l_revised_item_tbl(1).eco_name);

        IF p_record_status IN ('NEW', 'INSERT')
        THEN
                l_revised_item_tbl(1).transaction_type := 'CREATE';
        ELSIF p_record_status IN ('QUERY', 'CHANGED')
        THEN
                l_revised_item_tbl(1).transaction_type := 'UPDATE';
        ELSIF p_record_status = 'DELETE'
        THEN
                l_revised_item_tbl(1).transaction_type := 'DELETE';
        END IF;

        ENG_FORM_ECO_PVT.Process_ECO
        ( x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , p_control_rec            => l_control_rec
        , p_revised_item_tbl       => l_revised_item_tbl
        , p_unexp_rev_item_rec     => l_unexp_RIT_rec
        , x_eco_rec                => l_eco_rec
        , x_unexp_eco_rec          => l_unexp_eco_rec
        , x_unexp_eco_rev_rec      => l_unexp_eco_rev_rec
        , x_unexp_revised_item_rec => l_unexp_RIT_rec
        , x_unexp_rev_comp_rec     => l_unexp_rev_comp_rec
        , x_unexp_sub_comp_rec     => l_unexp_SBC_rec
        , x_unexp_ref_desg_rec     => l_unexp_RFD_rec
        , x_unexp_rev_op_rec       => l_unexp_rev_op_rec
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
	,   x_disable_revision     =>  x_disable_revision --Bug no:3034642
        );

        Create_Controller_Rec
        ( p_RIT_tbl             => l_revised_item_tbl
        , p_unexp_RIT_rec       => l_unexp_RIT_rec
        , x_controller_RIT_rec  => l_RIT_controller_rec
        );

        x_RIT_controller_rec := l_RIT_controller_rec;
        x_return_status := l_return_status;
   EXCEPTION
      WHEN OTHERS THEN
        Eco_Error_Handler.Log_Error
                (  p_ECO_rec              => l_ECO_rec
                ,  p_eco_revision_tbl     => l_eco_revision_tbl
                ,  p_revised_item_tbl     => l_revised_item_tbl
                ,  p_rev_component_tbl    => l_rev_component_tbl
                ,  p_ref_designator_tbl   => l_ref_designator_tbl
                ,  p_sub_component_tbl    => l_sub_component_tbl
                ,  p_rev_operation_tbl    => l_rev_operation_tbl       --add
                ,  p_rev_op_resource_tbl  => l_rev_op_resource_tbl     --add
                ,  p_rev_sub_resource_tbl => l_rev_sub_resource_tbl    --add
                ,  p_mesg_token_tbl       => l_mesg_token_tbl
                ,  p_error_status         => FND_API.G_RET_STS_UNEXP_ERROR
                ,  p_other_status         => Error_Handler.G_STATUS_NOT_PICKED
                ,  p_other_message        => l_other_message
                ,  p_other_token_tbl      => l_other_token_tbl
                ,  p_error_level          => 1
                ,  x_ECO_rec              => l_ECO_rec
                ,  x_eco_revision_tbl     => l_eco_revision_tbl
                ,  x_revised_item_tbl     => l_revised_item_tbl
                ,  x_rev_component_tbl    => l_rev_component_tbl
                ,  x_ref_designator_tbl   => l_ref_designator_tbl
                ,  x_sub_component_tbl    => l_sub_component_tbl
                ,  x_rev_operation_tbl    => l_rev_operation_tbl       --add
                ,  x_rev_op_resource_tbl  => l_rev_op_resource_tbl     --add
                ,  x_rev_sub_resource_tbl => l_rev_sub_resource_tbl    --add
                );

       x_return_status := 1;
END Change_Attribute;

/*PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_RIT_tbl(1)                    IN  ENG_Eco_PUB.Rit_Rec_Type
,   x_RIT_tbl(1)                    OUT NOCOPY ENG_Eco_PUB.Rit_Rec_Type
);
*/

END ENG_RIT_Controller;

/
