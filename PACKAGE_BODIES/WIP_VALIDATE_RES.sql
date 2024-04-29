--------------------------------------------------------
--  DDL for Package Body WIP_VALIDATE_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_VALIDATE_RES" AS
/* $Header: WIPLRESB.pls 115.11 2002/11/28 11:43:17 rmahidha ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Validate_Res';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_old_Res_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
)
IS
   l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_dummy                       VARCHAR2(10) := NULL;
BEGIN

    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) = WIP_Transaction_PVT.NONE then
        x_return_status := l_return_status;
	return;
    END IF;

    --  Check required Resource/OSP attributes.

    IF  p_Res_rec.acct_period_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'acct_period_id');
    END IF;

    IF  p_Res_rec.autocharge_type IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'autocharge_type');
    END IF;

    IF  p_Res_rec.basis_type IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'basis_type');
    END IF;

    IF  p_Res_rec.department_code IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'department_code');
    END IF;

    IF  p_Res_rec.department_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'department_id');
    END IF;

    IF  p_Res_rec.entity_type IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'entity_type');
    END IF;

    IF  p_Res_rec.last_updated_by_name IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'last_updated_by_name');
    END IF;

    IF  p_Res_rec.operation_seq_num IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'operation_seq_num');
    END IF;

    IF  p_Res_rec.organization_code IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'organization_code');
    END IF;

    IF  p_Res_rec.organization_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'organization_id');
    END IF;

    IF  p_Res_rec.primary_item_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'primary_item_id');
    END IF;

    IF  p_Res_rec.primary_quantity IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'primary_quantity');
    END IF;

    IF  p_Res_rec.primary_uom IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'primary_uom');
    END IF;

    IF  p_Res_rec.process_phase IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'process_phase');
    END IF;

    IF  p_Res_rec.process_status IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'process_status');
    END IF;

    IF  p_Res_rec.resource_code IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'resource_code');
    END IF;

    IF  p_Res_rec.resource_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'resource_id');
    END IF;

    IF  p_Res_rec.resource_seq_num IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'resource_seq_num');
    END IF;

    IF  p_Res_rec.standard_rate_flag IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'standard_rate_flag');
    END IF;

    IF  p_Res_rec.transaction_date IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'transaction_date');
    END IF;

    IF  p_Res_rec.transaction_quantity IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'transaction_quantity');
    END IF;

    IF  p_Res_rec.transaction_type IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'transaction_type');
    END IF;

    IF  p_Res_rec.usage_rate_or_amount IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'usage_rate_or_amount');
    END IF;

    IF  p_Res_rec.wip_entity_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'wip_entity_id');
    END IF;

    IF  p_Res_rec.wip_entity_name IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'wip_entity_name');
    END IF;



    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) <= WIP_Transaction_PVT.REQUIRED THEN
        x_return_status := l_return_status;
	return;
    END IF;


    --
    --  Check conditionally required attributes here.
    --

    IF  p_Res_rec.repetitive_schedule_id IS NOT NULL
      AND p_Res_rec.line_id IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'line_id');
    END IF;


    IF  p_Res_rec.repetitive_schedule_id IS NOT NULL
      AND p_Res_rec.line_code IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'line_code');
    END IF;


    IF  p_Res_rec.project_id IS NOT NULL
      AND p_Res_rec.task_id IS NULL
    THEN
       BEGIN
	  SELECT  'VALID'
	    INTO     l_dummy
	    FROM     mtl_parameters mp
	    WHERE    mp.organization_id = p_Res_rec.organization_id
	    AND      mp.project_reference_enabled = 1
	    AND      mp.project_control_level = 2;
       EXCEPTION
	  WHEN OTHERS THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;

	     WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'project_id');
       END;
    END IF;

    IF  p_Res_rec.activity_id IS NOT NULL
      AND p_Res_rec.activity_name IS NULL
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

	WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'activity_name');
    END IF;


    -- check the following attributes if OSP transaction
    IF  p_Res_rec.transaction_type = WIP_CONSTANTS.OSP_TXN then

        IF  p_Res_rec.po_header_id IS NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

	    WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'po_header_id');
        END IF;


        IF  p_Res_rec.po_line_id IS NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

	    WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'po_line_id');
        END IF;


        IF  p_Res_rec.rcv_transaction_id IS NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

	    WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'rcv_transaction_id');
        END IF;

        IF  p_Res_rec.source_code IS NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

	    WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'source_code');
        END IF;

        IF  p_Res_rec.source_line_id IS NULL
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;

	    WIP_Globals.Add_Error_Message(
				      p_message_name   => 'WIP_ATTRIBUTE_REQUIRED',
				      p_token1_name    => 'ATTRIBUTE',
				      p_token1_value   => 'source_line_id');
        END IF;

    END IF;
    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Do any other specific entity validations here.

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
,   p_validation_level		    IN  NUMBER DEFAULT NULL
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_old_Res_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF nvl(p_validation_level,WIP_Transaction_PVT.COMPLETE) = WIP_Transaction_PVT.NONE then
	return;
    END IF;

    --  Validate Resource attributes

    IF  p_Res_rec.acct_period_id IS NOT NULL AND
        (   p_Res_rec.acct_period_id <>
            p_old_Res_rec.acct_period_id OR
            p_old_Res_rec.acct_period_id IS NULL )
    THEN
       IF NOT WIP_Validate.Acct_Period(p_Res_rec.acct_period_id,
				       p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.activity_id IS NOT NULL AND
        (   p_Res_rec.activity_id <>
            p_old_Res_rec.activity_id OR
            p_old_Res_rec.activity_id IS NULL )
    THEN
        IF NOT WIP_Validate.Activity(p_Res_rec.activity_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.activity_name IS NOT NULL AND
        (   p_Res_rec.activity_name <>
            p_old_Res_rec.activity_name OR
            p_old_Res_rec.activity_name IS NULL )
    THEN
        IF NOT WIP_Validate.Activity_Name(p_Res_rec.activity_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.actual_resource_rate IS NOT NULL AND
        (   p_Res_rec.actual_resource_rate <>
            p_old_Res_rec.actual_resource_rate OR
            p_old_Res_rec.actual_resource_rate IS NULL )
    THEN
        IF NOT WIP_Validate.Actual_Resource_Rate(p_Res_rec.actual_resource_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.autocharge_type IS NOT NULL AND
        (   p_Res_rec.autocharge_type <>
            p_old_Res_rec.autocharge_type OR
            p_old_Res_rec.autocharge_type IS NULL )
    THEN
        IF NOT WIP_Validate.Autocharge_Type(p_Res_rec.autocharge_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.basis_type IS NOT NULL AND
        (   p_Res_rec.basis_type <>
            p_old_Res_rec.basis_type OR
            p_old_Res_rec.basis_type IS NULL )
    THEN
        IF NOT WIP_Validate.Basis_Type(p_Res_rec.basis_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.completion_transaction_id IS NOT NULL AND
        (   p_Res_rec.completion_transaction_id <>
            p_old_Res_rec.completion_transaction_id OR
            p_old_Res_rec.completion_transaction_id IS NULL )
    THEN
        IF NOT WIP_Validate.Completion_Transaction(p_Res_rec.completion_transaction_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.created_by IS NOT NULL AND
        (   p_Res_rec.created_by <>
            p_old_Res_rec.created_by OR
            p_old_Res_rec.created_by IS NULL )
    THEN
        IF NOT WIP_Validate.Created_By(p_Res_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.created_by_name IS NOT NULL AND
        (   p_Res_rec.created_by_name <>
            p_old_Res_rec.created_by_name OR
            p_old_Res_rec.created_by_name IS NULL )
    THEN
        IF NOT WIP_Validate.Created_By_Name(p_Res_rec.created_by_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.creation_date IS NOT NULL AND
        (   p_Res_rec.creation_date <>
            p_old_Res_rec.creation_date OR
            p_old_Res_rec.creation_date IS NULL )
    THEN
        IF NOT WIP_Validate.Creation_Date(p_Res_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
      */

    IF  p_Res_rec.currency_actual_rsc_rate IS NOT NULL AND
        (   p_Res_rec.currency_actual_rsc_rate <>
            p_old_Res_rec.currency_actual_rsc_rate OR
            p_old_Res_rec.currency_actual_rsc_rate IS NULL )
    THEN
        IF NOT WIP_Validate.Currency_Actual_Rsc_Rate(p_Res_rec.currency_actual_rsc_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.currency_code IS NOT NULL AND
        (   p_Res_rec.currency_code <>
            p_old_Res_rec.currency_code OR
            p_old_Res_rec.currency_code IS NULL )
    THEN
        IF NOT WIP_Validate.Currency(p_Res_rec.currency_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.currency_conversion_date IS NOT NULL AND
        (   p_Res_rec.currency_conversion_date <>
            p_old_Res_rec.currency_conversion_date OR
            p_old_Res_rec.currency_conversion_date IS NULL )
    THEN
        IF NOT WIP_Validate.Currency_Conversion_Date(p_Res_rec.currency_conversion_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.currency_conversion_rate IS NOT NULL AND
        (   p_Res_rec.currency_conversion_rate <>
            p_old_Res_rec.currency_conversion_rate OR
            p_old_Res_rec.currency_conversion_rate IS NULL )
    THEN
        IF NOT WIP_Validate.Currency_Conversion_Rate(p_Res_rec.currency_conversion_rate) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.currency_conversion_type IS NOT NULL AND
        (   p_Res_rec.currency_conversion_type <>
            p_old_Res_rec.currency_conversion_type OR
            p_old_Res_rec.currency_conversion_type IS NULL )
    THEN
        IF NOT WIP_Validate.Currency_Conversion_Type(p_Res_rec.currency_conversion_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.department_code IS NOT NULL AND
        (   p_Res_rec.department_code <>
            p_old_Res_rec.department_code OR
            p_old_Res_rec.department_code IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Code(p_Res_rec.department_code, p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.department_id IS NOT NULL AND
        (   p_Res_rec.department_id <>
            p_old_Res_rec.department_id OR
            p_old_Res_rec.department_id IS NULL )
    THEN
        IF NOT WIP_Validate.Department_Id(p_Res_rec.department_id, p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.employee_id IS NOT NULL AND
        (   p_Res_rec.employee_id <>
            p_old_Res_rec.employee_id OR
            p_old_Res_rec.employee_id IS NULL )
    THEN
        IF NOT WIP_Validate.Employee(p_Res_rec.employee_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.employee_num IS NOT NULL AND
        (   p_Res_rec.employee_num <>
            p_old_Res_rec.employee_num OR
            p_old_Res_rec.employee_num IS NULL )
    THEN
        IF NOT WIP_Validate.Employee_Num(p_Res_rec.employee_num) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.entity_type IS NOT NULL AND
        (   p_Res_rec.entity_type <>
            p_old_Res_rec.entity_type OR
            p_old_Res_rec.entity_type IS NULL )
    THEN
        IF NOT WIP_Validate.Entity_Type(p_Res_rec.entity_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.group_id IS NOT NULL AND
        (   p_Res_rec.group_id <>
            p_old_Res_rec.group_id OR
            p_old_Res_rec.group_id IS NULL )
    THEN
        IF NOT WIP_Validate.Group_Id(p_Res_rec.group_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.last_updated_by IS NOT NULL AND
        (   p_Res_rec.last_updated_by <>
            p_old_Res_rec.last_updated_by OR
            p_old_Res_rec.last_updated_by IS NULL )
    THEN
        IF NOT WIP_Validate.Last_Updated_By(p_Res_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.last_updated_by_name IS NOT NULL AND
        (   p_Res_rec.last_updated_by_name <>
            p_old_Res_rec.last_updated_by_name OR
            p_old_Res_rec.last_updated_by_name IS NULL )
    THEN
        IF NOT WIP_Validate.Last_Updated_By_Name(p_Res_rec.last_updated_by_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.last_update_date IS NOT NULL AND
        (   p_Res_rec.last_update_date <>
            p_old_Res_rec.last_update_date OR
            p_old_Res_rec.last_update_date IS NULL )
    THEN
        IF NOT WIP_Validate.Last_Update_Date(p_Res_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.last_update_login IS NOT NULL AND
        (   p_Res_rec.last_update_login <>
            p_old_Res_rec.last_update_login OR
            p_old_Res_rec.last_update_login IS NULL )
    THEN
        IF NOT WIP_Validate.Last_Update_Login(p_Res_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.line_code IS NOT NULL AND
        (   p_Res_rec.line_code <>
            p_old_Res_rec.line_code OR
            p_old_Res_rec.line_code IS NULL )
    THEN
        IF NOT WIP_Validate.Line(p_Res_rec.line_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.line_id IS NOT NULL AND
        (   p_Res_rec.line_id <>
            p_old_Res_rec.line_id OR
            p_old_Res_rec.line_id IS NULL )
    THEN
        IF NOT WIP_Validate.Line(p_Res_rec.line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.move_transaction_id IS NOT NULL AND
        (   p_Res_rec.move_transaction_id <>
            p_old_Res_rec.move_transaction_id OR
            p_old_Res_rec.move_transaction_id IS NULL )
    THEN
        IF NOT WIP_Validate.Move_Transaction(p_Res_rec.move_transaction_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.operation_seq_num IS NOT NULL AND
        (   p_Res_rec.operation_seq_num <>
            p_old_Res_rec.operation_seq_num OR
            p_old_Res_rec.operation_seq_num IS NULL )
    THEN
        IF NOT WIP_Validate.Operation_Seq_Num(p_Res_rec.operation_seq_num) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.organization_code IS NOT NULL AND
        (   p_Res_rec.organization_code <>
            p_old_Res_rec.organization_code OR
            p_old_Res_rec.organization_code IS NULL )
    THEN
        IF NOT WIP_Validate.Organization(p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.organization_id IS NOT NULL AND
        (   p_Res_rec.organization_id <>
            p_old_Res_rec.organization_id OR
            p_old_Res_rec.organization_id IS NULL )
    THEN
        IF NOT WIP_Validate.Organization(p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.po_header_id IS NOT NULL AND
        (   p_Res_rec.po_header_id <>
            p_old_Res_rec.po_header_id OR
            p_old_Res_rec.po_header_id IS NULL )
    THEN
        IF NOT WIP_Validate.Po_Header(p_Res_rec.po_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.po_line_id IS NOT NULL AND
        (   p_Res_rec.po_line_id <>
            p_old_Res_rec.po_line_id OR
            p_old_Res_rec.po_line_id IS NULL )
    THEN
        IF NOT WIP_Validate.Po_Line(p_Res_rec.po_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.primary_item_id IS NOT NULL AND
        (   p_Res_rec.primary_item_id <>
            p_old_Res_rec.primary_item_id OR
            p_old_Res_rec.primary_item_id IS NULL )
    THEN
       IF NOT WIP_Validate.Primary_Item(p_Res_rec.primary_item_id,
					p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.primary_quantity IS NOT NULL AND
        (   p_Res_rec.primary_quantity <>
            p_old_Res_rec.primary_quantity OR
            p_old_Res_rec.primary_quantity IS NULL )
    THEN
        IF NOT WIP_Validate.Primary_Quantity(p_Res_rec.primary_quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.primary_uom IS NOT NULL AND
        (   p_Res_rec.primary_uom <>
            p_old_Res_rec.primary_uom OR
            p_old_Res_rec.primary_uom IS NULL )
    THEN
        IF NOT WIP_Validate.Primary_Uom(p_Res_rec.primary_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.primary_uom_class IS NOT NULL AND
        (   p_Res_rec.primary_uom_class <>
            p_old_Res_rec.primary_uom_class OR
            p_old_Res_rec.primary_uom_class IS NULL )
    THEN
        IF NOT WIP_Validate.Primary_Uom_Class(p_Res_rec.primary_uom_class) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.process_phase IS NOT NULL AND
        (   p_Res_rec.process_phase <>
            p_old_Res_rec.process_phase OR
            p_old_Res_rec.process_phase IS NULL )
    THEN
        IF NOT WIP_Validate.Process_Phase(p_Res_rec.process_phase, 'WIP_RESOURCE_PROCESS_PHASE') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.process_status IS NOT NULL AND
        (   p_Res_rec.process_status <>
            p_old_Res_rec.process_status OR
            p_old_Res_rec.process_status IS NULL )
    THEN
        IF NOT WIP_Validate.Process_Status(p_Res_rec.process_status) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.program_application_id IS NOT NULL AND
        (   p_Res_rec.program_application_id <>
            p_old_Res_rec.program_application_id OR
            p_old_Res_rec.program_application_id IS NULL )
    THEN
        IF NOT WIP_Validate.Program_Application(p_Res_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.program_id IS NOT NULL AND
        (   p_Res_rec.program_id <>
            p_old_Res_rec.program_id OR
            p_old_Res_rec.program_id IS NULL )
    THEN
        IF NOT WIP_Validate.Program(p_Res_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.program_update_date IS NOT NULL AND
        (   p_Res_rec.program_update_date <>
            p_old_Res_rec.program_update_date OR
            p_old_Res_rec.program_update_date IS NULL )
    THEN
        IF NOT WIP_Validate.Program_Update_Date(p_Res_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.project_id IS NOT NULL AND
        (   p_Res_rec.project_id <>
            p_old_Res_rec.project_id OR
            p_old_Res_rec.project_id IS NULL )
    THEN
       IF NOT WIP_Validate.Project(p_Res_rec.project_id,
				   p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.rcv_transaction_id IS NOT NULL AND
        (   p_Res_rec.rcv_transaction_id <>
            p_old_Res_rec.rcv_transaction_id OR
            p_old_Res_rec.rcv_transaction_id IS NULL )
    THEN
        --rcv_transaction_id is the transaction_id. we actually need to
        --validate against the rcv_transactions_interface table and thus
        --need to pass the interface_transaction_id...source line id should
        --always be populated if rcv_transaction_id is populated
        IF NOT WIP_Validate.Rcv_Transaction(p_Res_rec.source_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.reason_id IS NOT NULL AND
        (   p_Res_rec.reason_id <>
            p_old_Res_rec.reason_id OR
            p_old_Res_rec.reason_id IS NULL )
    THEN
        IF NOT WIP_Validate.Reason(p_Res_rec.reason_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.reason_name IS NOT NULL AND
        (   p_Res_rec.reason_name <>
            p_old_Res_rec.reason_name OR
            p_old_Res_rec.reason_name IS NULL )
    THEN
        IF NOT WIP_Validate.Reason_Name(p_Res_rec.reason_name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.receiving_account_id IS NOT NULL AND
        (   p_Res_rec.receiving_account_id <>
            p_old_Res_rec.receiving_account_id OR
            p_old_Res_rec.receiving_account_id IS NULL )
    THEN
        IF NOT WIP_Validate.Receiving_Account(p_Res_rec.receiving_account_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.reference IS NOT NULL AND
        (   p_Res_rec.reference <>
            p_old_Res_rec.reference OR
            p_old_Res_rec.reference IS NULL )
    THEN
        IF NOT WIP_Validate.Reference(p_Res_rec.reference) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.repetitive_schedule_id IS NOT NULL AND
        (   p_Res_rec.repetitive_schedule_id <>
            p_old_Res_rec.repetitive_schedule_id OR
            p_old_Res_rec.repetitive_schedule_id IS NULL )
    THEN
        IF NOT WIP_Validate.Repetitive_Schedule(p_Res_rec.repetitive_schedule_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.request_id IS NOT NULL AND
        (   p_Res_rec.request_id <>
            p_old_Res_rec.request_id OR
            p_old_Res_rec.request_id IS NULL )
    THEN
        IF NOT WIP_Validate.Request(p_Res_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.resource_code IS NOT NULL AND
        (   p_Res_rec.resource_code <>
            p_old_Res_rec.resource_code OR
            p_old_Res_rec.resource_code IS NULL )
    THEN
        IF NOT WIP_Validate.Resource_Code(p_Res_rec.resource_code, p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.resource_id IS NOT NULL AND
        (   p_Res_rec.resource_id <>
            p_old_Res_rec.resource_id OR
            p_old_Res_rec.resource_id IS NULL )
    THEN
        IF NOT WIP_Validate.Resource_Id(p_Res_rec.resource_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.resource_seq_num IS NOT NULL AND
        (   p_Res_rec.resource_seq_num <>
            p_old_Res_rec.resource_seq_num OR
            p_old_Res_rec.resource_seq_num IS NULL )
    THEN
        IF NOT WIP_Validate.Resource_Seq_Num(p_Res_rec.resource_seq_num) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.resource_type IS NOT NULL AND
        (   p_Res_rec.resource_type <>
            p_old_Res_rec.resource_type OR
            p_old_Res_rec.resource_type IS NULL )
    THEN
        IF NOT WIP_Validate.Resource_Type(p_Res_rec.resource_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.source_code IS NOT NULL AND
        (   p_Res_rec.source_code <>
            p_old_Res_rec.source_code OR
            p_old_Res_rec.source_code IS NULL )
    THEN
        IF NOT WIP_Validate.Source(p_Res_rec.source_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.source_line_id IS NOT NULL AND
        (   p_Res_rec.source_line_id <>
            p_old_Res_rec.source_line_id OR
            p_old_Res_rec.source_line_id IS NULL )
    THEN
        IF NOT WIP_Validate.Source_Line(p_Res_rec.source_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */
    IF  p_Res_rec.standard_rate_flag IS NOT NULL AND
        (   p_Res_rec.standard_rate_flag <>
            p_old_Res_rec.standard_rate_flag OR
            p_old_Res_rec.standard_rate_flag IS NULL )
    THEN
        IF NOT WIP_Validate.Standard_Rate(p_Res_rec.standard_rate_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.task_id IS NOT NULL AND
        (   p_Res_rec.task_id <>
            p_old_Res_rec.task_id OR
            p_old_Res_rec.task_id IS NULL )
    THEN
       IF NOT WIP_Validate.Task(p_Res_rec.task_id,
				p_Res_rec.project_id,
				p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.transaction_date IS NOT NULL AND
        (   p_Res_rec.transaction_date <>
            p_old_Res_rec.transaction_date OR
            p_old_Res_rec.transaction_date IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Date(p_Res_rec.transaction_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.transaction_id IS NOT NULL AND
        (   p_Res_rec.transaction_id <>
            p_old_Res_rec.transaction_id OR
            p_old_Res_rec.transaction_id IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction(p_Res_rec.transaction_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    /*
    IF  p_Res_rec.transaction_quantity IS NOT NULL AND
        (   p_Res_rec.transaction_quantity <>
            p_old_Res_rec.transaction_quantity OR
            p_old_Res_rec.transaction_quantity IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Quantity(p_Res_rec.transaction_quantity) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;
      */

    IF  p_Res_rec.transaction_type IS NOT NULL AND
        (   p_Res_rec.transaction_type <>
            p_old_Res_rec.transaction_type OR
            p_old_Res_rec.transaction_type IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Type(p_Res_rec.transaction_type, 'WIP_TRANSACTION_TYPE' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.transaction_uom IS NOT NULL AND
        (   p_Res_rec.transaction_uom <>
            p_old_Res_rec.transaction_uom OR
            p_old_Res_rec.transaction_uom IS NULL )
    THEN
        IF NOT WIP_Validate.Transaction_Uom(p_Res_rec.transaction_uom) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.usage_rate_or_amount IS NOT NULL AND
        (   p_Res_rec.usage_rate_or_amount <>
            p_old_Res_rec.usage_rate_or_amount OR
            p_old_Res_rec.usage_rate_or_amount IS NULL )
    THEN
        IF NOT WIP_Validate.Usage_Rate_Or_Amount(p_Res_rec.usage_rate_or_amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.wip_entity_id IS NOT NULL AND
        (   p_Res_rec.wip_entity_id <>
            p_old_Res_rec.wip_entity_id OR
            p_old_Res_rec.wip_entity_id IS NULL )
    THEN
        IF NOT WIP_Validate.Wip_Entity(p_Res_rec.wip_entity_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_Res_rec.wip_entity_name IS NOT NULL AND
        (   p_Res_rec.wip_entity_name <>
            p_old_Res_rec.wip_entity_name OR
            p_old_Res_rec.wip_entity_name IS NULL )
    THEN
       IF NOT WIP_Validate.Wip_Entity_Name(p_Res_rec.wip_entity_name,
					   p_Res_rec.organization_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  (p_Res_rec.attribute1 IS NOT NULL AND
        (   p_Res_rec.attribute1 <>
            p_old_Res_rec.attribute1 OR
            p_old_Res_rec.attribute1 IS NULL ))
    OR  (p_Res_rec.attribute10 IS NOT NULL AND
        (   p_Res_rec.attribute10 <>
            p_old_Res_rec.attribute10 OR
            p_old_Res_rec.attribute10 IS NULL ))
    OR  (p_Res_rec.attribute11 IS NOT NULL AND
        (   p_Res_rec.attribute11 <>
            p_old_Res_rec.attribute11 OR
            p_old_Res_rec.attribute11 IS NULL ))
    OR  (p_Res_rec.attribute12 IS NOT NULL AND
        (   p_Res_rec.attribute12 <>
            p_old_Res_rec.attribute12 OR
            p_old_Res_rec.attribute12 IS NULL ))
    OR  (p_Res_rec.attribute13 IS NOT NULL AND
        (   p_Res_rec.attribute13 <>
            p_old_Res_rec.attribute13 OR
            p_old_Res_rec.attribute13 IS NULL ))
    OR  (p_Res_rec.attribute14 IS NOT NULL AND
        (   p_Res_rec.attribute14 <>
            p_old_Res_rec.attribute14 OR
            p_old_Res_rec.attribute14 IS NULL ))
    OR  (p_Res_rec.attribute15 IS NOT NULL AND
        (   p_Res_rec.attribute15 <>
            p_old_Res_rec.attribute15 OR
            p_old_Res_rec.attribute15 IS NULL ))
    OR  (p_Res_rec.attribute2 IS NOT NULL AND
        (   p_Res_rec.attribute2 <>
            p_old_Res_rec.attribute2 OR
            p_old_Res_rec.attribute2 IS NULL ))
    OR  (p_Res_rec.attribute3 IS NOT NULL AND
        (   p_Res_rec.attribute3 <>
            p_old_Res_rec.attribute3 OR
            p_old_Res_rec.attribute3 IS NULL ))
    OR  (p_Res_rec.attribute4 IS NOT NULL AND
        (   p_Res_rec.attribute4 <>
            p_old_Res_rec.attribute4 OR
            p_old_Res_rec.attribute4 IS NULL ))
    OR  (p_Res_rec.attribute5 IS NOT NULL AND
        (   p_Res_rec.attribute5 <>
            p_old_Res_rec.attribute5 OR
            p_old_Res_rec.attribute5 IS NULL ))
    OR  (p_Res_rec.attribute6 IS NOT NULL AND
        (   p_Res_rec.attribute6 <>
            p_old_Res_rec.attribute6 OR
            p_old_Res_rec.attribute6 IS NULL ))
    OR  (p_Res_rec.attribute7 IS NOT NULL AND
        (   p_Res_rec.attribute7 <>
            p_old_Res_rec.attribute7 OR
            p_old_Res_rec.attribute7 IS NULL ))
    OR  (p_Res_rec.attribute8 IS NOT NULL AND
        (   p_Res_rec.attribute8 <>
            p_old_Res_rec.attribute8 OR
            p_old_Res_rec.attribute8 IS NULL ))
    OR  (p_Res_rec.attribute9 IS NOT NULL AND
        (   p_Res_rec.attribute9 <>
            p_old_Res_rec.attribute9 OR
            p_old_Res_rec.attribute9 IS NULL ))
    OR  (p_Res_rec.attribute_category IS NOT NULL AND
        (   p_Res_rec.attribute_category <>
            p_old_Res_rec.attribute_category OR
            p_old_Res_rec.attribute_category IS NULL ))
    THEN

    --  These calls are temporarily commented out
	NULL;
/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_Res_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_Res_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_Res_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_Res_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_Res_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_Res_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_Res_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_Res_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_Res_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_Res_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_Res_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_Res_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_Res_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_Res_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_Res_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE_CATEGORY'
        ,   column_value                  => p_Res_rec.attribute_category
        );

        --  Validate descriptive flexfield.

        IF NOT WIP_Validate.Desc_Flex( 'OSP' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

*/
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

END WIP_Validate_Res;

/
