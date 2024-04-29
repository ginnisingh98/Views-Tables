--------------------------------------------------------
--  DDL for Package Body WIP_RES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_UTIL" AS
/* $Header: WIPURESB.pls 120.1.12010000.2 2010/03/10 09:49:31 hliew ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Res_Util';

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
) RETURN WIP_Transaction_PUB.Res_Rec_Type
IS
l_Res_rec                     WIP_Transaction_PUB.Res_Rec_Type := p_Res_rec;
BEGIN

    IF l_Res_rec.acct_period_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.acct_period_id := NULL;
    END IF;

    IF l_Res_rec.activity_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.activity_id := NULL;
    END IF;

    IF l_Res_rec.activity_name = FND_API.G_MISS_CHAR THEN
        l_Res_rec.activity_name := NULL;
    END IF;

    IF l_Res_rec.actual_resource_rate = FND_API.G_MISS_NUM THEN
        l_Res_rec.actual_resource_rate := NULL;
    END IF;

    IF l_Res_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute1 := NULL;
    END IF;

    IF l_Res_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute10 := NULL;
    END IF;

    IF l_Res_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute11 := NULL;
    END IF;

    IF l_Res_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute12 := NULL;
    END IF;

    IF l_Res_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute13 := NULL;
    END IF;

    IF l_Res_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute14 := NULL;
    END IF;

    IF l_Res_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute15 := NULL;
    END IF;

    IF l_Res_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute2 := NULL;
    END IF;

    IF l_Res_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute3 := NULL;
    END IF;

    IF l_Res_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute4 := NULL;
    END IF;

    IF l_Res_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute5 := NULL;
    END IF;

    IF l_Res_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute6 := NULL;
    END IF;

    IF l_Res_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute7 := NULL;
    END IF;

    IF l_Res_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute8 := NULL;
    END IF;

    IF l_Res_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute9 := NULL;
    END IF;

    IF l_Res_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_Res_rec.attribute_category := NULL;
    END IF;

    IF l_Res_rec.autocharge_type = FND_API.G_MISS_NUM THEN
        l_Res_rec.autocharge_type := NULL;
    END IF;

    IF l_Res_rec.basis_type = FND_API.G_MISS_NUM THEN
        l_Res_rec.basis_type := NULL;
    END IF;

    IF l_Res_rec.completion_transaction_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.completion_transaction_id := NULL;
    END IF;

    IF l_Res_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Res_rec.created_by := NULL;
    END IF;

    IF l_Res_rec.created_by_name = FND_API.G_MISS_CHAR THEN
        l_Res_rec.created_by_name := NULL;
    END IF;

    IF l_Res_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Res_rec.creation_date := NULL;
    END IF;

    IF l_Res_rec.currency_actual_rsc_rate = FND_API.G_MISS_NUM THEN
        l_Res_rec.currency_actual_rsc_rate := NULL;
    END IF;

    IF l_Res_rec.currency_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.currency_code := NULL;
    END IF;

    IF l_Res_rec.currency_conversion_date = FND_API.G_MISS_DATE THEN
        l_Res_rec.currency_conversion_date := NULL;
    END IF;

    IF l_Res_rec.currency_conversion_rate = FND_API.G_MISS_NUM THEN
        l_Res_rec.currency_conversion_rate := NULL;
    END IF;

    IF l_Res_rec.currency_conversion_type = FND_API.G_MISS_CHAR THEN
        l_Res_rec.currency_conversion_type := NULL;
    END IF;

    IF l_Res_rec.department_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.department_code := NULL;
    END IF;

    IF l_Res_rec.department_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.department_id := NULL;
    END IF;

    IF l_Res_rec.employee_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.employee_id := NULL;
    END IF;

    IF l_Res_rec.employee_num = FND_API.G_MISS_CHAR THEN
        l_Res_rec.employee_num := NULL;
    END IF;

    IF l_Res_rec.entity_type = FND_API.G_MISS_NUM THEN
        l_Res_rec.entity_type := NULL;
    END IF;

    IF l_Res_rec.group_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.group_id := NULL;
    END IF;

    IF l_Res_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Res_rec.last_updated_by := NULL;
    END IF;

    IF l_Res_rec.last_updated_by_name = FND_API.G_MISS_CHAR THEN
        l_Res_rec.last_updated_by_name := NULL;
    END IF;

    IF l_Res_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Res_rec.last_update_date := NULL;
    END IF;

    IF l_Res_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Res_rec.last_update_login := NULL;
    END IF;

    IF l_Res_rec.line_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.line_code := NULL;
    END IF;

    IF l_Res_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.line_id := NULL;
    END IF;

    IF l_Res_rec.move_transaction_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.move_transaction_id := NULL;
    END IF;

    IF l_Res_rec.operation_seq_num = FND_API.G_MISS_NUM THEN
        l_Res_rec.operation_seq_num := NULL;
    END IF;

    IF l_Res_rec.organization_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.organization_code := NULL;
    END IF;

    IF l_Res_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.organization_id := NULL;
    END IF;

    IF l_Res_rec.po_header_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.po_header_id := NULL;
    END IF;

    IF l_Res_rec.po_line_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.po_line_id := NULL;
    END IF;

    IF l_Res_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.primary_item_id := NULL;
    END IF;

    IF l_Res_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        l_Res_rec.primary_quantity := NULL;
    END IF;

    IF l_Res_rec.primary_uom = FND_API.G_MISS_CHAR THEN
        l_Res_rec.primary_uom := NULL;
    END IF;

    IF l_Res_rec.primary_uom_class = FND_API.G_MISS_CHAR THEN
        l_Res_rec.primary_uom_class := NULL;
    END IF;

    IF l_Res_rec.process_phase = FND_API.G_MISS_NUM THEN
        l_Res_rec.process_phase := NULL;
    END IF;

    IF l_Res_rec.process_status = FND_API.G_MISS_NUM THEN
        l_Res_rec.process_status := NULL;
    END IF;

    IF l_Res_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.program_application_id := NULL;
    END IF;

    IF l_Res_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.program_id := NULL;
    END IF;

    IF l_Res_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Res_rec.program_update_date := NULL;
    END IF;

    IF l_Res_rec.project_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.project_id := NULL;
    END IF;

    IF l_Res_rec.rcv_transaction_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.rcv_transaction_id := NULL;
    END IF;

    IF l_Res_rec.reason_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.reason_id := NULL;
    END IF;

    IF l_Res_rec.reason_name = FND_API.G_MISS_CHAR THEN
        l_Res_rec.reason_name := NULL;
    END IF;

    IF l_Res_rec.receiving_account_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.receiving_account_id := NULL;
    END IF;

    IF l_Res_rec.reference = FND_API.G_MISS_CHAR THEN
        l_Res_rec.reference := NULL;
    END IF;

    IF l_Res_rec.repetitive_schedule_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.repetitive_schedule_id := NULL;
    END IF;

    IF l_Res_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.request_id := NULL;
    END IF;

    IF l_Res_rec.resource_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.resource_code := NULL;
    END IF;

    IF l_Res_rec.resource_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.resource_id := NULL;
    END IF;

    IF l_Res_rec.resource_seq_num = FND_API.G_MISS_NUM THEN
        l_Res_rec.resource_seq_num := NULL;
    END IF;

    IF l_Res_rec.resource_type = FND_API.G_MISS_NUM THEN
        l_Res_rec.resource_type := NULL;
    END IF;

    IF l_Res_rec.source_code = FND_API.G_MISS_CHAR THEN
        l_Res_rec.source_code := NULL;
    END IF;

    IF l_Res_rec.source_line_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.source_line_id := NULL;
    END IF;

    IF l_Res_rec.standard_rate_flag = FND_API.G_MISS_NUM THEN
        l_Res_rec.standard_rate_flag := NULL;
    END IF;

    IF l_Res_rec.task_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.task_id := NULL;
    END IF;

    IF l_Res_rec.transaction_date = FND_API.G_MISS_DATE THEN
        l_Res_rec.transaction_date := NULL;
    END IF;

    IF l_Res_rec.transaction_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.transaction_id := NULL;
    END IF;

    IF l_Res_rec.transaction_quantity = FND_API.G_MISS_NUM THEN
        l_Res_rec.transaction_quantity := NULL;
    END IF;

    IF l_Res_rec.transaction_type = FND_API.G_MISS_NUM THEN
        l_Res_rec.transaction_type := NULL;
    END IF;

    IF l_Res_rec.transaction_uom = FND_API.G_MISS_CHAR THEN
        l_Res_rec.transaction_uom := NULL;
    END IF;

    IF l_Res_rec.usage_rate_or_amount = FND_API.G_MISS_NUM THEN
        l_Res_rec.usage_rate_or_amount := NULL;
    END IF;

    IF l_Res_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.wip_entity_id := NULL;
    END IF;

    IF l_Res_rec.wip_entity_name = FND_API.G_MISS_CHAR THEN
        l_Res_rec.wip_entity_name := NULL;
    END IF;

    /*Fix bug 9356683*/
    IF l_Res_rec.encumbrance_type_id = FND_API.G_MISS_NUM THEN
        l_Res_rec.encumbrance_type_id := NULL;
    END IF;

    IF l_Res_rec.encumbrance_amount = FND_API.G_MISS_NUM THEN
        l_Res_rec.encumbrance_amount := NULL;
    END IF;

    IF l_Res_rec.encumbrance_quantity = FND_API.G_MISS_NUM THEN
        l_Res_rec.encumbrance_quantity := NULL;
    END IF;

    IF l_Res_rec.encumbrance_ccid = FND_API.G_MISS_NUM THEN
        l_Res_rec.encumbrance_ccid := NULL;
    END IF;
    /*End of Fix Bug 9356683*/

    RETURN l_Res_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
)
IS
BEGIN

    UPDATE  WIP_COST_TXN_INTERFACE
    SET     ACCT_PERIOD_ID                 = p_Res_rec.acct_period_id
    ,       ACTIVITY_ID                    = p_Res_rec.activity_id
    ,       ACTIVITY_NAME                  = p_Res_rec.activity_name
    ,       ACTUAL_RESOURCE_RATE           = p_Res_rec.actual_resource_rate
    ,       ATTRIBUTE1                     = p_Res_rec.attribute1
    ,       ATTRIBUTE10                    = p_Res_rec.attribute10
    ,       ATTRIBUTE11                    = p_Res_rec.attribute11
    ,       ATTRIBUTE12                    = p_Res_rec.attribute12
    ,       ATTRIBUTE13                    = p_Res_rec.attribute13
    ,       ATTRIBUTE14                    = p_Res_rec.attribute14
    ,       ATTRIBUTE15                    = p_Res_rec.attribute15
    ,       ATTRIBUTE2                     = p_Res_rec.attribute2
    ,       ATTRIBUTE3                     = p_Res_rec.attribute3
    ,       ATTRIBUTE4                     = p_Res_rec.attribute4
    ,       ATTRIBUTE5                     = p_Res_rec.attribute5
    ,       ATTRIBUTE6                     = p_Res_rec.attribute6
    ,       ATTRIBUTE7                     = p_Res_rec.attribute7
    ,       ATTRIBUTE8                     = p_Res_rec.attribute8
    ,       ATTRIBUTE9                     = p_Res_rec.attribute9
    ,       ATTRIBUTE_CATEGORY             = p_Res_rec.attribute_category
    ,       AUTOCHARGE_TYPE                = p_Res_rec.autocharge_type
    ,       BASIS_TYPE                     = p_Res_rec.basis_type
    ,       COMPLETION_TRANSACTION_ID      = p_Res_rec.completion_transaction_id
    ,       CREATED_BY                     = p_Res_rec.created_by
    ,       CREATED_BY_NAME                = p_Res_rec.created_by_name
    ,       CREATION_DATE                  = p_Res_rec.creation_date
    ,       CURRENCY_ACTUAL_RESOURCE_RATE  = p_Res_rec.currency_actual_rsc_rate
    ,       CURRENCY_CODE                  = p_Res_rec.currency_code
    ,       CURRENCY_CONVERSION_DATE       = p_Res_rec.currency_conversion_date
    ,       CURRENCY_CONVERSION_RATE       = p_Res_rec.currency_conversion_rate
    ,       CURRENCY_CONVERSION_TYPE       = p_Res_rec.currency_conversion_type
    ,       DEPARTMENT_CODE                = p_Res_rec.department_code
    ,       DEPARTMENT_ID                  = p_Res_rec.department_id
    ,       EMPLOYEE_ID                    = p_Res_rec.employee_id
    ,       EMPLOYEE_NUM                   = p_Res_rec.employee_num
    ,       ENTITY_TYPE                    = p_Res_rec.entity_type
    ,       GROUP_ID                       = p_Res_rec.group_id
    ,       LAST_UPDATED_BY                = p_Res_rec.last_updated_by
    ,       LAST_UPDATED_BY_NAME           = p_Res_rec.last_updated_by_name
    ,       LAST_UPDATE_DATE               = p_Res_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_Res_rec.last_update_login
    ,       LINE_CODE                      = p_Res_rec.line_code
    ,       LINE_ID                        = p_Res_rec.line_id
    ,       MOVE_TRANSACTION_ID            = p_Res_rec.move_transaction_id
    ,       OPERATION_SEQ_NUM              = p_Res_rec.operation_seq_num
    ,       ORGANIZATION_CODE              = p_Res_rec.organization_code
    ,       ORGANIZATION_ID                = p_Res_rec.organization_id
    ,       PO_HEADER_ID                   = p_Res_rec.po_header_id
    ,       PO_LINE_ID                     = p_Res_rec.po_line_id
    ,       PRIMARY_ITEM_ID                = p_Res_rec.primary_item_id
    ,       PRIMARY_QUANTITY               = p_Res_rec.primary_quantity
    ,       PRIMARY_UOM                    = p_Res_rec.primary_uom
    ,       PRIMARY_UOM_CLASS              = p_Res_rec.primary_uom_class
    ,       PROCESS_PHASE                  = p_Res_rec.process_phase
    ,       PROCESS_STATUS                 = p_Res_rec.process_status
    ,       PROGRAM_APPLICATION_ID         = p_Res_rec.program_application_id
    ,       PROGRAM_ID                     = p_Res_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_Res_rec.program_update_date
    ,       PROJECT_ID                     = p_Res_rec.project_id
    ,       RCV_TRANSACTION_ID             = p_Res_rec.rcv_transaction_id
    ,       REASON_ID                      = p_Res_rec.reason_id
    ,       REASON_NAME                    = p_Res_rec.reason_name
    ,       RECEIVING_ACCOUNT_ID           = p_Res_rec.receiving_account_id
    ,       REFERENCE                      = p_Res_rec.reference
    ,       REPETITIVE_SCHEDULE_ID         = p_Res_rec.repetitive_schedule_id
    ,       REQUEST_ID                     = p_Res_rec.request_id
    ,       RESOURCE_CODE                  = p_Res_rec.resource_code
    ,       RESOURCE_ID                    = p_Res_rec.resource_id
    ,       RESOURCE_SEQ_NUM               = p_Res_rec.resource_seq_num
    ,       RESOURCE_TYPE                  = p_Res_rec.resource_type
    ,       SOURCE_CODE                    = p_Res_rec.source_code
    ,       SOURCE_LINE_ID                 = p_Res_rec.source_line_id
    ,       STANDARD_RATE_FLAG             = p_Res_rec.standard_rate_flag
    ,       TASK_ID                        = p_Res_rec.task_id
    ,       TRANSACTION_DATE               = p_Res_rec.transaction_date
    ,       TRANSACTION_ID                 = p_Res_rec.transaction_id
    ,       TRANSACTION_QUANTITY           = p_Res_rec.transaction_quantity
    ,       TRANSACTION_TYPE               = p_Res_rec.transaction_type
    ,       TRANSACTION_UOM                = p_Res_rec.transaction_uom
    ,       USAGE_RATE_OR_AMOUNT           = p_Res_rec.usage_rate_or_amount
    ,       WIP_ENTITY_ID                  = p_Res_rec.wip_entity_id
/* Fix for bug 3427769. Removed WIP_ENTITY_NAME from update statement.
    ,       WIP_ENTITY_NAME                = p_Res_rec.wip_entity_name
*/
    WHERE   PO_HEADER_ID = p_Res_rec.po_header_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
)
IS
BEGIN

    INSERT  INTO WIP_COST_TXN_INTERFACE
    (       ACCT_PERIOD_ID
    ,       ACTIVITY_ID
    ,       ACTIVITY_NAME
    ,       ACTUAL_RESOURCE_RATE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       AUTOCHARGE_TYPE
    ,       BASIS_TYPE
    ,       COMPLETION_TRANSACTION_ID
    ,       CREATED_BY
    ,       CREATED_BY_NAME
    ,       CREATION_DATE
    ,       CURRENCY_ACTUAL_RESOURCE_RATE
    ,       CURRENCY_CODE
    ,       CURRENCY_CONVERSION_DATE
    ,       CURRENCY_CONVERSION_RATE
    ,       CURRENCY_CONVERSION_TYPE
    ,       DEPARTMENT_CODE
    ,       DEPARTMENT_ID
    ,       EMPLOYEE_ID
    ,       EMPLOYEE_NUM
    ,       ENTITY_TYPE
    ,       GROUP_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATED_BY_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_CODE
    ,       LINE_ID
    ,       MOVE_TRANSACTION_ID
    ,       OPERATION_SEQ_NUM
    ,       ORGANIZATION_CODE
    ,       ORGANIZATION_ID
    ,       PO_HEADER_ID
    ,       PO_LINE_ID
    ,       PRIMARY_ITEM_ID
    ,       PRIMARY_QUANTITY
    ,       PRIMARY_UOM
    ,       PRIMARY_UOM_CLASS
    ,       PROCESS_PHASE
    ,       PROCESS_STATUS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       RCV_TRANSACTION_ID
    ,       REASON_ID
    ,       REASON_NAME
    ,       RECEIVING_ACCOUNT_ID
    ,       REFERENCE
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_CODE
    ,       RESOURCE_ID
    ,       RESOURCE_SEQ_NUM
    ,       RESOURCE_TYPE
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       STANDARD_RATE_FLAG
    ,       TASK_ID
    ,       TRANSACTION_DATE
    ,       TRANSACTION_ID
    ,       TRANSACTION_QUANTITY
    ,       TRANSACTION_TYPE
    ,       TRANSACTION_UOM
    ,       USAGE_RATE_OR_AMOUNT
    ,       WIP_ENTITY_ID
/* Fix for bug 3427769. Removed WIP_ENTITY_NAME from insert statement.
    ,       WIP_ENTITY_NAME
*/
    /* Fix bug 9356683, for costing encumbrance project*/
    ,       ENCUMBRANCE_TYPE_ID
    ,       ENCUMBRANCE_AMOUNT
    ,       ENCUMBRANCE_QUANTITY
    ,       ENCUMBRANCE_CCID
    )
    VALUES
    (       p_Res_rec.acct_period_id
    ,       p_Res_rec.activity_id
    ,       p_Res_rec.activity_name
    ,       p_Res_rec.actual_resource_rate
    ,       p_Res_rec.attribute1
    ,       p_Res_rec.attribute10
    ,       p_Res_rec.attribute11
    ,       p_Res_rec.attribute12
    ,       p_Res_rec.attribute13
    ,       p_Res_rec.attribute14
    ,       p_Res_rec.attribute15
    ,       p_Res_rec.attribute2
    ,       p_Res_rec.attribute3
    ,       p_Res_rec.attribute4
    ,       p_Res_rec.attribute5
    ,       p_Res_rec.attribute6
    ,       p_Res_rec.attribute7
    ,       p_Res_rec.attribute8
    ,       p_Res_rec.attribute9
    ,       p_Res_rec.attribute_category
    ,       p_Res_rec.autocharge_type
    ,       p_Res_rec.basis_type
    ,       p_Res_rec.completion_transaction_id
    ,       p_Res_rec.created_by
    ,       p_Res_rec.created_by_name
    ,       p_Res_rec.creation_date
    ,       p_Res_rec.currency_actual_rsc_rate
    ,       p_Res_rec.currency_code
    ,       p_Res_rec.currency_conversion_date
    ,       p_Res_rec.currency_conversion_rate
    ,       p_Res_rec.currency_conversion_type
    ,       p_Res_rec.department_code
    ,       p_Res_rec.department_id
    ,       p_Res_rec.employee_id
    ,       p_Res_rec.employee_num
    ,       p_Res_rec.entity_type
    ,       p_Res_rec.group_id
    ,       p_Res_rec.last_updated_by
    ,       p_Res_rec.last_updated_by_name
    ,       p_Res_rec.last_update_date
    ,       p_Res_rec.last_update_login
    ,       p_Res_rec.line_code
    ,       p_Res_rec.line_id
    ,       p_Res_rec.move_transaction_id
    ,       p_Res_rec.operation_seq_num
    ,       p_Res_rec.organization_code
    ,       p_Res_rec.organization_id
    ,       p_Res_rec.po_header_id
    ,       p_Res_rec.po_line_id
    ,       p_Res_rec.primary_item_id
    ,       p_Res_rec.primary_quantity
    ,       p_Res_rec.primary_uom
    ,       p_Res_rec.primary_uom_class
    ,       p_Res_rec.process_phase
    ,       p_Res_rec.process_status
    ,       p_Res_rec.program_application_id
    ,       p_Res_rec.program_id
    ,       p_Res_rec.program_update_date
    ,       p_Res_rec.project_id
    ,       p_Res_rec.rcv_transaction_id
    ,       p_Res_rec.reason_id
    ,       p_Res_rec.reason_name
    ,       p_Res_rec.receiving_account_id
    ,       p_Res_rec.reference
    ,       p_Res_rec.repetitive_schedule_id
    ,       p_Res_rec.request_id
    ,       p_Res_rec.resource_code
    ,       p_Res_rec.resource_id
    ,       p_Res_rec.resource_seq_num
    ,       p_Res_rec.resource_type
    ,       p_Res_rec.source_code
    ,       p_Res_rec.source_line_id
    ,       p_Res_rec.standard_rate_flag
    ,       p_Res_rec.task_id
    ,       p_Res_rec.transaction_date
    ,       p_Res_rec.transaction_id
    ,       p_Res_rec.transaction_quantity
    ,       p_Res_rec.transaction_type
    ,       p_Res_rec.transaction_uom
    ,       p_Res_rec.usage_rate_or_amount
    ,       p_Res_rec.wip_entity_id
/* Fix for bug 3427769. Removed WIP_ENTITY_NAME from insert statement.
    ,       p_Res_rec.wip_entity_name
*/
    /* Fix bug 9356683, for costing encumbrance project*/
    ,       p_Res_rec.encumbrance_type_id
    ,       p_Res_rec.encumbrance_amount
    ,       p_Res_rec.encumbrance_quantity
    ,       p_Res_rec.encumbrance_ccid
    );

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_po_header_id                  IN  NUMBER
)
IS
BEGIN

    DELETE  FROM WIP_COST_TXN_INTERFACE
    WHERE   PO_HEADER_ID = p_po_header_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_po_header_id                  IN  NUMBER
) RETURN WIP_Transaction_PUB.Res_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_po_header_id                => p_po_header_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_po_header_id                  IN  NUMBER :=
                                        NULL
,   p_dummy                         IN  VARCHAR2 :=
                                        NULL
) RETURN WIP_Transaction_PUB.Res_Tbl_Type
IS
l_Res_rec                     WIP_Transaction_PUB.Res_Rec_Type;
l_Res_tbl                     WIP_Transaction_PUB.Res_Tbl_Type;

CURSOR l_Res_csr IS
    SELECT  ACCT_PERIOD_ID
    ,       ACTIVITY_ID
    ,       ACTIVITY_NAME
    ,       ACTUAL_RESOURCE_RATE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       AUTOCHARGE_TYPE
    ,       BASIS_TYPE
    ,       COMPLETION_TRANSACTION_ID
    ,       CREATED_BY
    ,       CREATED_BY_NAME
    ,       CREATION_DATE
    ,       CURRENCY_ACTUAL_RESOURCE_RATE
    ,       CURRENCY_CODE
    ,       CURRENCY_CONVERSION_DATE
    ,       CURRENCY_CONVERSION_RATE
    ,       CURRENCY_CONVERSION_TYPE
    ,       DEPARTMENT_CODE
    ,       DEPARTMENT_ID
    ,       EMPLOYEE_ID
    ,       EMPLOYEE_NUM
    ,       ENTITY_TYPE
    ,       GROUP_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATED_BY_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_CODE
    ,       LINE_ID
    ,       MOVE_TRANSACTION_ID
    ,       OPERATION_SEQ_NUM
    ,       ORGANIZATION_CODE
    ,       ORGANIZATION_ID
    ,       PO_HEADER_ID
    ,       PO_LINE_ID
    ,       PRIMARY_ITEM_ID
    ,       PRIMARY_QUANTITY
    ,       PRIMARY_UOM
    ,       PRIMARY_UOM_CLASS
    ,       PROCESS_PHASE
    ,       PROCESS_STATUS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       RCV_TRANSACTION_ID
    ,       REASON_ID
    ,       REASON_NAME
    ,       RECEIVING_ACCOUNT_ID
    ,       REFERENCE
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_CODE
    ,       RESOURCE_ID
    ,       RESOURCE_SEQ_NUM
    ,       RESOURCE_TYPE
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       STANDARD_RATE_FLAG
    ,       TASK_ID
    ,       TRANSACTION_DATE
    ,       TRANSACTION_ID
    ,       TRANSACTION_QUANTITY
    ,       TRANSACTION_TYPE
    ,       TRANSACTION_UOM
    ,       USAGE_RATE_OR_AMOUNT
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    FROM    WIP_COST_TXN_INTERFACE
    WHERE ( PO_HEADER_ID = nvl(p_po_header_id,FND_API.G_MISS_NUM)
    );

BEGIN


    --  Loop over fetched records

    FOR l_implicit_rec IN l_Res_csr LOOP

        l_Res_rec.acct_period_id       := l_implicit_rec.ACCT_PERIOD_ID;
        l_Res_rec.activity_id          := l_implicit_rec.ACTIVITY_ID;
        l_Res_rec.activity_name        := l_implicit_rec.ACTIVITY_NAME;
        l_Res_rec.actual_resource_rate := l_implicit_rec.ACTUAL_RESOURCE_RATE;
        l_Res_rec.attribute1           := l_implicit_rec.ATTRIBUTE1;
        l_Res_rec.attribute10          := l_implicit_rec.ATTRIBUTE10;
        l_Res_rec.attribute11          := l_implicit_rec.ATTRIBUTE11;
        l_Res_rec.attribute12          := l_implicit_rec.ATTRIBUTE12;
        l_Res_rec.attribute13          := l_implicit_rec.ATTRIBUTE13;
        l_Res_rec.attribute14          := l_implicit_rec.ATTRIBUTE14;
        l_Res_rec.attribute15          := l_implicit_rec.ATTRIBUTE15;
        l_Res_rec.attribute2           := l_implicit_rec.ATTRIBUTE2;
        l_Res_rec.attribute3           := l_implicit_rec.ATTRIBUTE3;
        l_Res_rec.attribute4           := l_implicit_rec.ATTRIBUTE4;
        l_Res_rec.attribute5           := l_implicit_rec.ATTRIBUTE5;
        l_Res_rec.attribute6           := l_implicit_rec.ATTRIBUTE6;
        l_Res_rec.attribute7           := l_implicit_rec.ATTRIBUTE7;
        l_Res_rec.attribute8           := l_implicit_rec.ATTRIBUTE8;
        l_Res_rec.attribute9           := l_implicit_rec.ATTRIBUTE9;
        l_Res_rec.attribute_category   := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_Res_rec.autocharge_type      := l_implicit_rec.AUTOCHARGE_TYPE;
        l_Res_rec.basis_type           := l_implicit_rec.BASIS_TYPE;
        l_Res_rec.completion_transaction_id := l_implicit_rec.COMPLETION_TRANSACTION_ID;
        l_Res_rec.created_by           := l_implicit_rec.CREATED_BY;
        l_Res_rec.created_by_name      := l_implicit_rec.CREATED_BY_NAME;
        l_Res_rec.creation_date        := l_implicit_rec.CREATION_DATE;
        l_Res_rec.currency_actual_rsc_rate := l_implicit_rec.CURRENCY_ACTUAL_RESOURCE_RATE;
        l_Res_rec.currency_code        := l_implicit_rec.CURRENCY_CODE;
        l_Res_rec.currency_conversion_date := l_implicit_rec.CURRENCY_CONVERSION_DATE;
        l_Res_rec.currency_conversion_rate := l_implicit_rec.CURRENCY_CONVERSION_RATE;
        l_Res_rec.currency_conversion_type := l_implicit_rec.CURRENCY_CONVERSION_TYPE;
        l_Res_rec.department_code      := l_implicit_rec.DEPARTMENT_CODE;
        l_Res_rec.department_id        := l_implicit_rec.DEPARTMENT_ID;
        l_Res_rec.employee_id          := l_implicit_rec.EMPLOYEE_ID;
        l_Res_rec.employee_num         := l_implicit_rec.EMPLOYEE_NUM;
        l_Res_rec.entity_type          := l_implicit_rec.ENTITY_TYPE;
        l_Res_rec.group_id             := l_implicit_rec.GROUP_ID;
        l_Res_rec.last_updated_by      := l_implicit_rec.LAST_UPDATED_BY;
        l_Res_rec.last_updated_by_name := l_implicit_rec.LAST_UPDATED_BY_NAME;
        l_Res_rec.last_update_date     := l_implicit_rec.LAST_UPDATE_DATE;
        l_Res_rec.last_update_login    := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_Res_rec.line_code            := l_implicit_rec.LINE_CODE;
        l_Res_rec.line_id              := l_implicit_rec.LINE_ID;
        l_Res_rec.move_transaction_id  := l_implicit_rec.MOVE_TRANSACTION_ID;
        l_Res_rec.operation_seq_num    := l_implicit_rec.OPERATION_SEQ_NUM;
        l_Res_rec.organization_code    := l_implicit_rec.ORGANIZATION_CODE;
        l_Res_rec.organization_id      := l_implicit_rec.ORGANIZATION_ID;
        l_Res_rec.po_header_id         := l_implicit_rec.PO_HEADER_ID;
        l_Res_rec.po_line_id           := l_implicit_rec.PO_LINE_ID;
        l_Res_rec.primary_item_id      := l_implicit_rec.PRIMARY_ITEM_ID;
        l_Res_rec.primary_quantity     := l_implicit_rec.PRIMARY_QUANTITY;
        l_Res_rec.primary_uom          := l_implicit_rec.PRIMARY_UOM;
        l_Res_rec.primary_uom_class    := l_implicit_rec.PRIMARY_UOM_CLASS;
        l_Res_rec.process_phase        := l_implicit_rec.PROCESS_PHASE;
        l_Res_rec.process_status       := l_implicit_rec.PROCESS_STATUS;
        l_Res_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_Res_rec.program_id           := l_implicit_rec.PROGRAM_ID;
        l_Res_rec.program_update_date  := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_Res_rec.project_id           := l_implicit_rec.PROJECT_ID;
        l_Res_rec.rcv_transaction_id   := l_implicit_rec.RCV_TRANSACTION_ID;
        l_Res_rec.reason_id            := l_implicit_rec.REASON_ID;
        l_Res_rec.reason_name          := l_implicit_rec.REASON_NAME;
        l_Res_rec.receiving_account_id := l_implicit_rec.RECEIVING_ACCOUNT_ID;
        l_Res_rec.reference            := l_implicit_rec.REFERENCE;
        l_Res_rec.repetitive_schedule_id := l_implicit_rec.REPETITIVE_SCHEDULE_ID;
        l_Res_rec.request_id           := l_implicit_rec.REQUEST_ID;
        l_Res_rec.resource_code        := l_implicit_rec.RESOURCE_CODE;
        l_Res_rec.resource_id          := l_implicit_rec.RESOURCE_ID;
        l_Res_rec.resource_seq_num     := l_implicit_rec.RESOURCE_SEQ_NUM;
        l_Res_rec.resource_type        := l_implicit_rec.RESOURCE_TYPE;
        l_Res_rec.source_code          := l_implicit_rec.SOURCE_CODE;
        l_Res_rec.source_line_id       := l_implicit_rec.SOURCE_LINE_ID;
        l_Res_rec.standard_rate_flag   := l_implicit_rec.STANDARD_RATE_FLAG;
        l_Res_rec.task_id              := l_implicit_rec.TASK_ID;
        l_Res_rec.transaction_date     := l_implicit_rec.TRANSACTION_DATE;
        l_Res_rec.transaction_id       := l_implicit_rec.TRANSACTION_ID;
        l_Res_rec.transaction_quantity := l_implicit_rec.TRANSACTION_QUANTITY;
        l_Res_rec.transaction_type     := l_implicit_rec.TRANSACTION_TYPE;
        l_Res_rec.transaction_uom      := l_implicit_rec.TRANSACTION_UOM;
        l_Res_rec.usage_rate_or_amount := l_implicit_rec.USAGE_RATE_OR_AMOUNT;
        l_Res_rec.wip_entity_id        := l_implicit_rec.WIP_ENTITY_ID;
        l_Res_rec.wip_entity_name      := l_implicit_rec.WIP_ENTITY_NAME;

        l_Res_tbl(l_Res_tbl.COUNT + 1) := l_Res_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_po_header_id IS NOT NULL
     AND
     p_po_header_id <> FND_API.G_MISS_NUM)
    AND
    (l_Res_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table
    RETURN l_Res_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Res_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   x_Res_rec                       OUT NOCOPY WIP_Transaction_PUB.Res_Rec_Type
)
IS
l_Res_rec                     WIP_Transaction_PUB.Res_Rec_Type;
BEGIN

    SELECT  ACCT_PERIOD_ID
    ,       ACTIVITY_ID
    ,       ACTIVITY_NAME
    ,       ACTUAL_RESOURCE_RATE
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE_CATEGORY
    ,       AUTOCHARGE_TYPE
    ,       BASIS_TYPE
    ,       COMPLETION_TRANSACTION_ID
    ,       CREATED_BY
    ,       CREATED_BY_NAME
    ,       CREATION_DATE
    ,       CURRENCY_ACTUAL_RESOURCE_RATE
    ,       CURRENCY_CODE
    ,       CURRENCY_CONVERSION_DATE
    ,       CURRENCY_CONVERSION_RATE
    ,       CURRENCY_CONVERSION_TYPE
    ,       DEPARTMENT_CODE
    ,       DEPARTMENT_ID
    ,       EMPLOYEE_ID
    ,       EMPLOYEE_NUM
    ,       ENTITY_TYPE
    ,       GROUP_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATED_BY_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_CODE
    ,       LINE_ID
    ,       MOVE_TRANSACTION_ID
    ,       OPERATION_SEQ_NUM
    ,       ORGANIZATION_CODE
    ,       ORGANIZATION_ID
    ,       PO_HEADER_ID
    ,       PO_LINE_ID
    ,       PRIMARY_ITEM_ID
    ,       PRIMARY_QUANTITY
    ,       PRIMARY_UOM
    ,       PRIMARY_UOM_CLASS
    ,       PROCESS_PHASE
    ,       PROCESS_STATUS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       RCV_TRANSACTION_ID
    ,       REASON_ID
    ,       REASON_NAME
    ,       RECEIVING_ACCOUNT_ID
    ,       REFERENCE
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       RESOURCE_CODE
    ,       RESOURCE_ID
    ,       RESOURCE_SEQ_NUM
    ,       RESOURCE_TYPE
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       STANDARD_RATE_FLAG
    ,       TASK_ID
    ,       TRANSACTION_DATE
    ,       TRANSACTION_ID
    ,       TRANSACTION_QUANTITY
    ,       TRANSACTION_TYPE
    ,       TRANSACTION_UOM
    ,       USAGE_RATE_OR_AMOUNT
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    INTO    l_Res_rec.acct_period_id
    ,       l_Res_rec.activity_id
    ,       l_Res_rec.activity_name
    ,       l_Res_rec.actual_resource_rate
    ,       l_Res_rec.attribute1
    ,       l_Res_rec.attribute10
    ,       l_Res_rec.attribute11
    ,       l_Res_rec.attribute12
    ,       l_Res_rec.attribute13
    ,       l_Res_rec.attribute14
    ,       l_Res_rec.attribute15
    ,       l_Res_rec.attribute2
    ,       l_Res_rec.attribute3
    ,       l_Res_rec.attribute4
    ,       l_Res_rec.attribute5
    ,       l_Res_rec.attribute6
    ,       l_Res_rec.attribute7
    ,       l_Res_rec.attribute8
    ,       l_Res_rec.attribute9
    ,       l_Res_rec.attribute_category
    ,       l_Res_rec.autocharge_type
    ,       l_Res_rec.basis_type
    ,       l_Res_rec.completion_transaction_id
    ,       l_Res_rec.created_by
    ,       l_Res_rec.created_by_name
    ,       l_Res_rec.creation_date
    ,       l_Res_rec.currency_actual_rsc_rate
    ,       l_Res_rec.currency_code
    ,       l_Res_rec.currency_conversion_date
    ,       l_Res_rec.currency_conversion_rate
    ,       l_Res_rec.currency_conversion_type
    ,       l_Res_rec.department_code
    ,       l_Res_rec.department_id
    ,       l_Res_rec.employee_id
    ,       l_Res_rec.employee_num
    ,       l_Res_rec.entity_type
    ,       l_Res_rec.group_id
    ,       l_Res_rec.last_updated_by
    ,       l_Res_rec.last_updated_by_name
    ,       l_Res_rec.last_update_date
    ,       l_Res_rec.last_update_login
    ,       l_Res_rec.line_code
    ,       l_Res_rec.line_id
    ,       l_Res_rec.move_transaction_id
    ,       l_Res_rec.operation_seq_num
    ,       l_Res_rec.organization_code
    ,       l_Res_rec.organization_id
    ,       l_Res_rec.po_header_id
    ,       l_Res_rec.po_line_id
    ,       l_Res_rec.primary_item_id
    ,       l_Res_rec.primary_quantity
    ,       l_Res_rec.primary_uom
    ,       l_Res_rec.primary_uom_class
    ,       l_Res_rec.process_phase
    ,       l_Res_rec.process_status
    ,       l_Res_rec.program_application_id
    ,       l_Res_rec.program_id
    ,       l_Res_rec.program_update_date
    ,       l_Res_rec.project_id
    ,       l_Res_rec.rcv_transaction_id
    ,       l_Res_rec.reason_id
    ,       l_Res_rec.reason_name
    ,       l_Res_rec.receiving_account_id
    ,       l_Res_rec.reference
    ,       l_Res_rec.repetitive_schedule_id
    ,       l_Res_rec.request_id
    ,       l_Res_rec.resource_code
    ,       l_Res_rec.resource_id
    ,       l_Res_rec.resource_seq_num
    ,       l_Res_rec.resource_type
    ,       l_Res_rec.source_code
    ,       l_Res_rec.source_line_id
    ,       l_Res_rec.standard_rate_flag
    ,       l_Res_rec.task_id
    ,       l_Res_rec.transaction_date
    ,       l_Res_rec.transaction_id
    ,       l_Res_rec.transaction_quantity
    ,       l_Res_rec.transaction_type
    ,       l_Res_rec.transaction_uom
    ,       l_Res_rec.usage_rate_or_amount
    ,       l_Res_rec.wip_entity_id
    ,       l_Res_rec.wip_entity_name
    FROM    WIP_COST_TXN_INTERFACE
    WHERE   PO_HEADER_ID = p_Res_rec.po_header_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  WIP_GLOBALS.Equal(p_Res_rec.acct_period_id,
                         l_Res_rec.acct_period_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.activity_id,
                         l_Res_rec.activity_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.activity_name,
                         l_Res_rec.activity_name)
    AND WIP_GLOBALS.Equal(p_Res_rec.actual_resource_rate,
                         l_Res_rec.actual_resource_rate)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute1,
                         l_Res_rec.attribute1)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute10,
                         l_Res_rec.attribute10)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute11,
                         l_Res_rec.attribute11)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute12,
                         l_Res_rec.attribute12)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute13,
                         l_Res_rec.attribute13)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute14,
                         l_Res_rec.attribute14)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute15,
                         l_Res_rec.attribute15)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute2,
                         l_Res_rec.attribute2)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute3,
                         l_Res_rec.attribute3)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute4,
                         l_Res_rec.attribute4)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute5,
                         l_Res_rec.attribute5)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute6,
                         l_Res_rec.attribute6)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute7,
                         l_Res_rec.attribute7)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute8,
                         l_Res_rec.attribute8)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute9,
                         l_Res_rec.attribute9)
    AND WIP_GLOBALS.Equal(p_Res_rec.attribute_category,
                         l_Res_rec.attribute_category)
    AND WIP_GLOBALS.Equal(p_Res_rec.autocharge_type,
                         l_Res_rec.autocharge_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.basis_type,
                         l_Res_rec.basis_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.completion_transaction_id,
                         l_Res_rec.completion_transaction_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.created_by,
                         l_Res_rec.created_by)
    AND WIP_GLOBALS.Equal(p_Res_rec.created_by_name,
                         l_Res_rec.created_by_name)
    AND WIP_GLOBALS.Equal(p_Res_rec.creation_date,
                         l_Res_rec.creation_date)
    AND WIP_GLOBALS.Equal(p_Res_rec.currency_actual_rsc_rate,
                         l_Res_rec.currency_actual_rsc_rate)
    AND WIP_GLOBALS.Equal(p_Res_rec.currency_code,
                         l_Res_rec.currency_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.currency_conversion_date,
                         l_Res_rec.currency_conversion_date)
    AND WIP_GLOBALS.Equal(p_Res_rec.currency_conversion_rate,
                         l_Res_rec.currency_conversion_rate)
    AND WIP_GLOBALS.Equal(p_Res_rec.currency_conversion_type,
                         l_Res_rec.currency_conversion_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.department_code,
                         l_Res_rec.department_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.department_id,
                         l_Res_rec.department_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.employee_id,
                         l_Res_rec.employee_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.employee_num,
                         l_Res_rec.employee_num)
    AND WIP_GLOBALS.Equal(p_Res_rec.entity_type,
                         l_Res_rec.entity_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.group_id,
                         l_Res_rec.group_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.last_updated_by,
                         l_Res_rec.last_updated_by)
    AND WIP_GLOBALS.Equal(p_Res_rec.last_updated_by_name,
                         l_Res_rec.last_updated_by_name)
    AND WIP_GLOBALS.Equal(p_Res_rec.last_update_date,
                         l_Res_rec.last_update_date)
    AND WIP_GLOBALS.Equal(p_Res_rec.last_update_login,
                         l_Res_rec.last_update_login)
    AND WIP_GLOBALS.Equal(p_Res_rec.line_code,
                         l_Res_rec.line_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.line_id,
                         l_Res_rec.line_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.move_transaction_id,
                         l_Res_rec.move_transaction_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.operation_seq_num,
                         l_Res_rec.operation_seq_num)
    AND WIP_GLOBALS.Equal(p_Res_rec.organization_code,
                         l_Res_rec.organization_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.organization_id,
                         l_Res_rec.organization_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.po_header_id,
                         l_Res_rec.po_header_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.po_line_id,
                         l_Res_rec.po_line_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.primary_item_id,
                         l_Res_rec.primary_item_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.primary_quantity,
                         l_Res_rec.primary_quantity)
    AND WIP_GLOBALS.Equal(p_Res_rec.primary_uom,
                         l_Res_rec.primary_uom)
    AND WIP_GLOBALS.Equal(p_Res_rec.primary_uom_class,
                         l_Res_rec.primary_uom_class)
    AND WIP_GLOBALS.Equal(p_Res_rec.process_phase,
                         l_Res_rec.process_phase)
    AND WIP_GLOBALS.Equal(p_Res_rec.process_status,
                         l_Res_rec.process_status)
    AND WIP_GLOBALS.Equal(p_Res_rec.program_application_id,
                         l_Res_rec.program_application_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.program_id,
                         l_Res_rec.program_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.program_update_date,
                         l_Res_rec.program_update_date)
    AND WIP_GLOBALS.Equal(p_Res_rec.project_id,
                         l_Res_rec.project_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.rcv_transaction_id,
                         l_Res_rec.rcv_transaction_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.reason_id,
                         l_Res_rec.reason_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.reason_name,
                         l_Res_rec.reason_name)
    AND WIP_GLOBALS.Equal(p_Res_rec.receiving_account_id,
                         l_Res_rec.receiving_account_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.reference,
                         l_Res_rec.reference)
    AND WIP_GLOBALS.Equal(p_Res_rec.repetitive_schedule_id,
                         l_Res_rec.repetitive_schedule_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.request_id,
                         l_Res_rec.request_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.resource_code,
                         l_Res_rec.resource_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.resource_id,
                         l_Res_rec.resource_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.resource_seq_num,
                         l_Res_rec.resource_seq_num)
    AND WIP_GLOBALS.Equal(p_Res_rec.resource_type,
                         l_Res_rec.resource_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.source_code,
                         l_Res_rec.source_code)
    AND WIP_GLOBALS.Equal(p_Res_rec.source_line_id,
                         l_Res_rec.source_line_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.standard_rate_flag,
                         l_Res_rec.standard_rate_flag)
    AND WIP_GLOBALS.Equal(p_Res_rec.task_id,
                         l_Res_rec.task_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.transaction_date,
                         l_Res_rec.transaction_date)
    AND WIP_GLOBALS.Equal(p_Res_rec.transaction_id,
                         l_Res_rec.transaction_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.transaction_quantity,
                         l_Res_rec.transaction_quantity)
    AND WIP_GLOBALS.Equal(p_Res_rec.transaction_type,
                         l_Res_rec.transaction_type)
    AND WIP_GLOBALS.Equal(p_Res_rec.transaction_uom,
                         l_Res_rec.transaction_uom)
    AND WIP_GLOBALS.Equal(p_Res_rec.usage_rate_or_amount,
                         l_Res_rec.usage_rate_or_amount)
    AND WIP_GLOBALS.Equal(p_Res_rec.wip_entity_id,
                         l_Res_rec.wip_entity_id)
    AND WIP_GLOBALS.Equal(p_Res_rec.wip_entity_name,
                         l_Res_rec.wip_entity_name)
    THEN

        --  Row has not changed. Set out parameter.

        x_Res_rec                      := l_Res_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_Res_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Res_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Res_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_Res_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('WIP','WIP_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Res_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;


procedure print_record(p_Res_rec  IN WIP_Transaction_PUB.Res_Rec_Type)
  is
  begin

    null;
--  dbms_output.put_line('  ');
--  dbms_output.put_line('Resource Record*******************************');
--    dbms_output.put_line('acct_period_id '||to_char(p_Res_rec.acct_period_id));
--    dbms_output.put_line('activity_id '||to_char(p_Res_rec.activity_id));
--    dbms_output.put_line('activity_name '||p_Res_rec.activity_name );
--    dbms_output.put_line('actual_resource_rate '||to_char(p_Res_rec.actual_resource_rate ));
--    dbms_output.put_line('autocharge_type '||to_char(p_Res_rec.autocharge_type ));
--    dbms_output.put_line('basis_type '||to_char(p_Res_rec.basis_type ));
--    dbms_output.put_line('completion_transaction_id  '||to_char(p_Res_rec.completion_transaction_id  ));
--    dbms_output.put_line('created_by '||to_char(p_Res_rec.created_by ));
--    dbms_output.put_line('created_by_name '||p_Res_rec.created_by_name );
--    dbms_output.put_line('creation_date '||p_Res_rec.creation_date );
--    dbms_output.put_line('currency_actual_rsc_rate '||to_char(p_Res_rec.currency_actual_rsc_rate  ));
--    dbms_output.put_line('currency_code '||p_Res_rec.currency_code );
--    dbms_output.put_line('currency_conversion_date '||to_char(p_Res_rec.currency_conversion_date,'DD-MON-YY'));
--    dbms_output.put_line('currency_conversion_rate '||to_char(p_Res_rec.currency_conversion_rate ));
--    dbms_output.put_line('currency_conversion_type '||p_Res_rec.currency_conversion_type );
--    dbms_output.put_line('department_code '||p_Res_rec.department_code );
--    dbms_output.put_line('department_id '||to_char(p_Res_rec.department_id));
--    dbms_output.put_line('employee_id '||to_char(p_Res_rec.employee_id ));
--    dbms_output.put_line('employee_num '||p_Res_rec.employee_num );
--    dbms_output.put_line('entity_type  '||to_char(p_Res_rec.entity_type));
--    dbms_output.put_line('group_id '||to_char(p_Res_rec.group_id ));
--    dbms_output.put_line('last_updated_by  '||to_char(p_Res_rec.last_updated_by));
--    dbms_output.put_line('last_updated_by_name '||p_Res_rec.last_updated_by_name );
--    dbms_output.put_line('last_update_date '||to_char(p_Res_rec.last_update_date ,'DD-MON-YY'));
--    dbms_output.put_line('last_update_login  '||to_char(p_Res_rec.last_update_login ));
--    dbms_output.put_line('line_code '||p_Res_rec.line_code );
--    dbms_output.put_line('line_id '||to_char(nvl(p_Res_rec.line_id,-1)));
--    dbms_output.put_line('move_transaction_id '||to_char(p_Res_rec.move_transaction_id ));
--    dbms_output.put_line('operation_seq_num '||to_char(p_Res_rec.operation_seq_num  ));
--    dbms_output.put_line('organization_code '||p_Res_rec.organization_code);
--    dbms_output.put_line('organization_id  '||to_char(p_Res_rec.organization_id));
--    dbms_output.put_line('po_header_id  '||to_char(p_Res_rec.po_header_id));
--    dbms_output.put_line('po_line_id  '||to_char(p_Res_rec.po_line_id));
--    dbms_output.put_line('primary_item_id  '||to_char(p_Res_rec.primary_item_id));
--    dbms_output.put_line('primary_quantity  '||to_char(p_Res_rec.primary_quantity  ));
--    dbms_output.put_line('primary_uom' ||p_Res_rec.primary_uom);
--    dbms_output.put_line('primary_uom_class' || p_Res_rec.primary_uom_class);
--    dbms_output.put_line('process_phase  '||to_char(p_Res_rec.process_phase));
--    dbms_output.put_line('process_status  '||to_char(p_Res_rec.process_status));
--    dbms_output.put_line('program_application_id  '||to_char(p_Res_rec.program_application_id));
--    dbms_output.put_line('program_id  '||to_char(p_Res_rec.program_id));
--    dbms_output.put_line('program_update_date '||to_char(p_Res_rec.program_update_date,'DD-MON-YY'));
--    dbms_output.put_line('project_id  '||to_char(p_Res_rec.project_id  ));
--    dbms_output.put_line('rcv_transaction_id  '||to_char(nvl(p_Res_rec.rcv_transaction_id,-1)));
--    dbms_output.put_line('reason_id  '||to_char(p_Res_rec.reason_id  ));
--    dbms_output.put_line('reason_name '|| p_Res_rec.reason_name );
--    dbms_output.put_line('receiving_account_id  '||to_char(p_Res_rec.receiving_account_id));
--    dbms_output.put_line('reference '|| p_Res_rec.reference );
--    dbms_output.put_line('repetitive_schedule_id  '||to_char(p_Res_rec.repetitive_schedule_id));
--    dbms_output.put_line('request_id  '||to_char(p_Res_rec.request_id  ));
--    dbms_output.put_line('resource_code'|| p_Res_rec.resource_code );
--    dbms_output.put_line('resource_id  '||to_char(p_Res_rec.resource_id));
--    dbms_output.put_line('resource_seq_num  '||to_char(p_Res_rec.resource_seq_num));
--    dbms_output.put_line('resource_type  '||to_char(p_Res_rec.resource_type));
--    dbms_output.put_line('source_code '||p_Res_rec.source_code );
--    dbms_output.put_line('source_line_id  '||to_char(p_Res_rec.source_line_id));
--    dbms_output.put_line('standard_rate_flag  '||to_char(p_Res_rec.standard_rate_flag));
--    dbms_output.put_line('task_id  '||to_char(p_Res_rec.task_id  ));
--    dbms_output.put_line('transaction_date '||to_char(p_Res_rec.transaction_date ,'DD-MON-YY'));
--    dbms_output.put_line('transaction_id  '||to_char(p_Res_rec.transaction_id  ));
--    dbms_output.put_line('transaction_quantity  '||to_char(p_Res_rec.transaction_quantity  ));
--    dbms_output.put_line('transaction_type  '||to_char(p_Res_rec.transaction_type  ));
--    dbms_output.put_line('transaction_uom '||p_Res_rec.transaction_uom );
--    dbms_output.put_line('usage_rate_or_amount  '||to_char(p_Res_rec.usage_rate_or_amount));
--    dbms_output.put_line('wip_entity_id '||to_char(p_Res_rec.wip_entity_id));
--  dbms_output.put_line('wip_entity_name '||p_Res_rec.wip_entity_name );

  exception
  when others then
  null;
  end print_record;


END WIP_Res_Util;

/
