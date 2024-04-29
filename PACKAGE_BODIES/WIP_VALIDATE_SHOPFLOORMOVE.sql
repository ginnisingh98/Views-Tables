--------------------------------------------------------
--  DDL for Package Body WIP_VALIDATE_SHOPFLOORMOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_VALIDATE_SHOPFLOORMOVE" AS
/* $Header: WIPLSFMB.pls 115.10 2002/11/28 11:48:15 rmahidha ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Validate_Shopfloormove';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) = WIP_Transaction_PVT.NONE then
	x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
    END IF;

    --  Check required attributes.

    IF  p_ShopFloorMove_rec.acct_period_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','acct_period_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.created_by_name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','created_by_name');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.entity_type IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','entity_type');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.fm_department_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_department_code');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.fm_department_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_department_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.fm_intraop_step_type IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_intraop_step_type');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.fm_operation_seq_num IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fm_operation_seq_num');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.organization_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_code');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.last_updated_by_name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','last_updated_by_name');
            FND_MSG_PUB.Add;

        END IF;

    END IF;
    IF  p_ShopFloorMove_rec.organization_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.primary_item_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_item_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.primary_quantity IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_quantity');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.primary_uom IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.process_phase IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process_phase');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.process_status IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','process_status');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.to_department_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_department_code');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.to_department_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_department_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.to_intraop_step_type IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_intraop_step_type');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.to_operation_seq_num IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','to_operation_seq_num');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.transaction_date IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_date');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.transaction_quantity IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_quantity');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.transaction_type IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_type');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.transaction_uom IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','transaction_uom');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.wip_entity_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity_id');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    IF  p_ShopFloorMove_rec.wip_entity_name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity_name');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

    --  Return Error if a required attribute is missing.


    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) <= WIP_Transaction_PVT.REQUIRED THEN
        x_return_status := l_return_status;
        return;
    END IF;

    --
    --  Check conditionally required attributes here.
    --
    IF  p_ShopFloorMove_rec.repetitive_schedule_id IS NOT NULL
      AND p_ShopFloorMove_rec.line_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'line_id');
    END IF;


    IF  p_ShopFloorMove_rec.repetitive_schedule_id IS NOT NULL
      AND p_ShopFloorMove_rec.line_code IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'line_code');
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;



    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level              IN  NUMBER DEFAULT NULL
,   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) = WIP_Transaction_PVT.NONE then
        return;
    END IF;

    --  Validate ShopFloorMove attributes

    IF  p_ShopFloorMove_rec.acct_period_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.acct_period_id <>
            p_old_ShopFloorMove_rec.acct_period_id OR
            p_old_ShopFloorMove_rec.acct_period_id IS NULL )
    THEN
       IF NOT WIP_Validate.Acct_Period(p_ShopFloorMove_rec.acct_period_id,
				       p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.created_by_name IS NOT NULL AND
        (   p_ShopFloorMove_rec.created_by_name <>
            p_old_ShopFloorMove_rec.created_by_name OR
            p_old_ShopFloorMove_rec.created_by_name IS NULL )
    THEN
        IF NOT WIP_Validate.Created_By_Name(p_ShopFloorMove_rec.created_by_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.entity_type IS NOT NULL AND
        (   p_ShopFloorMove_rec.entity_type <>
            p_old_ShopFloorMove_rec.entity_type OR
            p_old_ShopFloorMove_rec.entity_type IS NULL )
    THEN
        IF NOT WIP_Validate.Entity_Type(p_ShopFloorMove_rec.entity_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.fm_department_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.fm_department_code <>
            p_old_ShopFloorMove_rec.fm_department_code OR
            p_old_ShopFloorMove_rec.fm_department_code IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Code(p_ShopFloorMove_rec.fm_department_code,
					    p_ShopFloorMove_rec.organization_id,
					    'fm_department_code') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.fm_department_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.fm_department_id <>
            p_old_ShopFloorMove_rec.fm_department_id OR
            p_old_ShopFloorMove_rec.fm_department_id IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Id(p_ShopFloorMove_rec.fm_department_id,
					  'fm_department_id') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.fm_intraop_step_type IS NOT NULL AND
        (   p_ShopFloorMove_rec.fm_intraop_step_type <>
            p_old_ShopFloorMove_rec.fm_intraop_step_type OR
            p_old_ShopFloorMove_rec.fm_intraop_step_type IS NULL )
    THEN
        IF NOT WIP_Validate.Intraop_Step_Type(p_ShopFloorMove_rec.fm_intraop_step_type,
					      'fm_intraop_step_type') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.fm_operation_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.fm_operation_code <>
            p_old_ShopFloorMove_rec.fm_operation_code OR
            p_old_ShopFloorMove_rec.fm_operation_code IS NULL )
    THEN
        IF NOT WIP_Validate.Operation_Code(p_ShopFloorMove_rec.fm_operation_code,
				      'fm_operation_code') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.fm_operation_seq_num IS NOT NULL AND
        (   p_ShopFloorMove_rec.fm_operation_seq_num <>
            p_old_ShopFloorMove_rec.fm_operation_seq_num OR
            p_old_ShopFloorMove_rec.fm_operation_seq_num IS NULL )
    THEN
        IF NOT WIP_Validate.Operation_Seq_Num(p_ShopFloorMove_rec.fm_operation_seq_num,
					      'fm_operation_seq_num') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.kanban_card_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.kanban_card_id <>
            p_old_ShopFloorMove_rec.kanban_card_id OR
            p_old_ShopFloorMove_rec.kanban_card_id IS NULL )
    THEN
       IF NOT WIP_Validate.Kanban_Card(p_ShopFloorMove_rec.kanban_card_id,
				       p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.last_updated_by_name IS NOT NULL AND
        (   p_ShopFloorMove_rec.last_updated_by_name <>
            p_old_ShopFloorMove_rec.last_updated_by_name OR
            p_old_ShopFloorMove_rec.last_updated_by_name IS NULL )
    THEN
        IF NOT WIP_Validate.Last_Updated_By_Name(p_ShopFloorMove_rec.last_updated_by_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.line_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.line_code <>
            p_old_ShopFloorMove_rec.line_code OR
            p_old_ShopFloorMove_rec.line_code IS NULL )
    THEN
        IF NOT WIP_Validate.Line(p_ShopFloorMove_rec.line_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.line_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.line_id <>
            p_old_ShopFloorMove_rec.line_id OR
            p_old_ShopFloorMove_rec.line_id IS NULL )
    THEN
        IF NOT WIP_Validate.Line(p_ShopFloorMove_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.organization_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.organization_code <>
            p_old_ShopFloorMove_rec.organization_code OR
            p_old_ShopFloorMove_rec.organization_code IS NULL )
    THEN
        IF NOT WIP_Validate.Organization(p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.organization_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.organization_id <>
            p_old_ShopFloorMove_rec.organization_id OR
            p_old_ShopFloorMove_rec.organization_id IS NULL )
    THEN
        IF NOT WIP_Validate.Organization(p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.primary_item_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.primary_item_id <>
            p_old_ShopFloorMove_rec.primary_item_id OR
            p_old_ShopFloorMove_rec.primary_item_id IS NULL )
    THEN
       IF NOT WIP_Validate.Primary_Item(p_ShopFloorMove_rec.primary_item_id,
					p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.primary_uom IS NOT NULL AND
        (   p_ShopFloorMove_rec.primary_uom <>
            p_old_ShopFloorMove_rec.primary_uom OR
            p_old_ShopFloorMove_rec.primary_uom IS NULL )
    THEN
        IF NOT WIP_Validate.Primary_Uom(p_ShopFloorMove_rec.primary_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.process_phase IS NOT NULL AND
        (   p_ShopFloorMove_rec.process_phase <>
            p_old_ShopFloorMove_rec.process_phase OR
            p_old_ShopFloorMove_rec.process_phase IS NULL )
    THEN
        IF NOT WIP_Validate.Process_Phase(p_ShopFloorMove_rec.process_phase,
					  'WIP_MOVE_PROCESS_PHASE') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.process_status IS NOT NULL AND
        (   p_ShopFloorMove_rec.process_status <>
            p_old_ShopFloorMove_rec.process_status OR
            p_old_ShopFloorMove_rec.process_status IS NULL )
    THEN
        IF NOT WIP_Validate.Process_Status(p_ShopFloorMove_rec.process_status) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.reason_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.reason_id <>
            p_old_ShopFloorMove_rec.reason_id OR
            p_old_ShopFloorMove_rec.reason_id IS NULL )
    THEN
        IF NOT WIP_Validate.Reason(p_ShopFloorMove_rec.reason_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.reason_name IS NOT NULL AND
        (   p_ShopFloorMove_rec.reason_name <>
            p_old_ShopFloorMove_rec.reason_name OR
            p_old_ShopFloorMove_rec.reason_name IS NULL )
    THEN
        IF NOT WIP_Validate.Reason_Name(p_ShopFloorMove_rec.reason_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.repetitive_schedule_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.repetitive_schedule_id <>
            p_old_ShopFloorMove_rec.repetitive_schedule_id OR
            p_old_ShopFloorMove_rec.repetitive_schedule_id IS NULL )
    THEN
        IF NOT WIP_Validate.Repetitive_Schedule(p_ShopFloorMove_rec.repetitive_schedule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.scrap_account_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.scrap_account_id <>
            p_old_ShopFloorMove_rec.scrap_account_id OR
            p_old_ShopFloorMove_rec.scrap_account_id IS NULL )
    THEN
        IF NOT WIP_Validate.Scrap_Account(p_ShopFloorMove_rec.scrap_account_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.to_department_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.to_department_code <>
            p_old_ShopFloorMove_rec.to_department_code OR
            p_old_ShopFloorMove_rec.to_department_code IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Code(p_ShopFloorMove_rec.to_department_code,
					    p_ShopFloorMove_rec.organization_id,
					    'to_department_code') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.to_department_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.to_department_id <>
            p_old_ShopFloorMove_rec.to_department_id OR
            p_old_ShopFloorMove_rec.to_department_id IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Id(p_ShopFloorMove_rec.to_department_id,
					  'to_department_id') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.to_intraop_step_type IS NOT NULL AND
        (   p_ShopFloorMove_rec.to_intraop_step_type <>
            p_old_ShopFloorMove_rec.to_intraop_step_type OR
            p_old_ShopFloorMove_rec.to_intraop_step_type IS NULL )
    THEN
        IF NOT WIP_Validate.Intraop_Step_Type(p_ShopFloorMove_rec.to_intraop_step_type,
					      'to_intraop_step_type') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.to_operation_code IS NOT NULL AND
        (   p_ShopFloorMove_rec.to_operation_code <>
            p_old_ShopFloorMove_rec.to_operation_code OR
            p_old_ShopFloorMove_rec.to_operation_code IS NULL )
    THEN
        IF NOT WIP_Validate.Operation_Code(p_ShopFloorMove_rec.to_operation_code,
					   'to_operation_code') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.to_operation_seq_num IS NOT NULL AND
        (   p_ShopFloorMove_rec.to_operation_seq_num <>
            p_old_ShopFloorMove_rec.to_operation_seq_num OR
            p_old_ShopFloorMove_rec.to_operation_seq_num IS NULL )
    THEN
        IF NOT WIP_Validate.Operation_Seq_Num(p_ShopFloorMove_rec.to_operation_seq_num,
						 'to_operation_seq_num') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.transaction_type IS NOT NULL AND
        (   p_ShopFloorMove_rec.transaction_type <>
            p_old_ShopFloorMove_rec.transaction_type OR
            p_old_ShopFloorMove_rec.transaction_type IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Type(p_ShopFloorMove_rec.transaction_type, 'WIP_MOVE_TRANSACTION_TYPE') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.transaction_uom IS NOT NULL AND
        (   p_ShopFloorMove_rec.transaction_uom <>
            p_old_ShopFloorMove_rec.transaction_uom OR
            p_old_ShopFloorMove_rec.transaction_uom IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Uom(p_ShopFloorMove_rec.transaction_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.wip_entity_id IS NOT NULL AND
        (   p_ShopFloorMove_rec.wip_entity_id <>
            p_old_ShopFloorMove_rec.wip_entity_id OR
            p_old_ShopFloorMove_rec.wip_entity_id IS NULL )
    THEN
        IF NOT WIP_Validate.Wip_Entity(p_ShopFloorMove_rec.wip_entity_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_ShopFloorMove_rec.wip_entity_name IS NOT NULL AND
        (   p_ShopFloorMove_rec.wip_entity_name <>
            p_old_ShopFloorMove_rec.wip_entity_name OR
            p_old_ShopFloorMove_rec.wip_entity_name IS NULL )
    THEN
       IF NOT WIP_Validate.Wip_Entity_Name(p_ShopFloorMove_rec.wip_entity_name,
					   p_ShopFloorMove_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;


END WIP_Validate_Shopfloormove;

/
