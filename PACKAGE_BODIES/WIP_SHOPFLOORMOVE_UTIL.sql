--------------------------------------------------------
--  DDL for Package Body WIP_SHOPFLOORMOVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SHOPFLOORMOVE_UTIL" AS
/* $Header: WIPUSFMB.pls 115.13 2003/10/06 20:40:29 kboonyap ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Shopfloormove_Util';


--  Function Complete_Record

FUNCTION Complete_Record
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
,   p_old_ShopFloorMove_rec         IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type
IS
l_ShopFloorMove_rec           WIP_Transaction_PUB.Shopfloormove_Rec_Type := p_ShopFloorMove_rec;
BEGIN

    IF l_ShopFloorMove_rec.acct_period_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.acct_period_id := p_old_ShopFloorMove_rec.acct_period_id;
    END IF;

    IF l_ShopFloorMove_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute1 := p_old_ShopFloorMove_rec.attribute1;
    END IF;

    IF l_ShopFloorMove_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute10 := p_old_ShopFloorMove_rec.attribute10;
    END IF;

    IF l_ShopFloorMove_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute11 := p_old_ShopFloorMove_rec.attribute11;
    END IF;

    IF l_ShopFloorMove_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute12 := p_old_ShopFloorMove_rec.attribute12;
    END IF;

    IF l_ShopFloorMove_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute13 := p_old_ShopFloorMove_rec.attribute13;
    END IF;

    IF l_ShopFloorMove_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute14 := p_old_ShopFloorMove_rec.attribute14;
    END IF;

    IF l_ShopFloorMove_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute15 := p_old_ShopFloorMove_rec.attribute15;
    END IF;

    IF l_ShopFloorMove_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute2 := p_old_ShopFloorMove_rec.attribute2;
    END IF;

    IF l_ShopFloorMove_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute3 := p_old_ShopFloorMove_rec.attribute3;
    END IF;

    IF l_ShopFloorMove_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute4 := p_old_ShopFloorMove_rec.attribute4;
    END IF;

    IF l_ShopFloorMove_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute5 := p_old_ShopFloorMove_rec.attribute5;
    END IF;

    IF l_ShopFloorMove_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute6 := p_old_ShopFloorMove_rec.attribute6;
    END IF;

    IF l_ShopFloorMove_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute7 := p_old_ShopFloorMove_rec.attribute7;
    END IF;

    IF l_ShopFloorMove_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute8 := p_old_ShopFloorMove_rec.attribute8;
    END IF;

    IF l_ShopFloorMove_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute9 := p_old_ShopFloorMove_rec.attribute9;
    END IF;

    IF l_ShopFloorMove_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute_category := p_old_ShopFloorMove_rec.attribute_category;
    END IF;

    IF l_ShopFloorMove_rec.created_by = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.created_by := p_old_ShopFloorMove_rec.created_by;
    END IF;

    IF l_ShopFloorMove_rec.created_by_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.created_by_name := p_old_ShopFloorMove_rec.created_by_name;
    END IF;

    IF l_ShopFloorMove_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.creation_date := p_old_ShopFloorMove_rec.creation_date;
    END IF;

    IF l_ShopFloorMove_rec.entity_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.entity_type := p_old_ShopFloorMove_rec.entity_type;
    END IF;

    IF l_ShopFloorMove_rec.fm_department_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.fm_department_code := p_old_ShopFloorMove_rec.fm_department_code;
    END IF;

    IF l_ShopFloorMove_rec.fm_department_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_department_id := p_old_ShopFloorMove_rec.fm_department_id;
    END IF;

    IF l_ShopFloorMove_rec.fm_intraop_step_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_intraop_step_type := p_old_ShopFloorMove_rec.fm_intraop_step_type;
    END IF;

    IF l_ShopFloorMove_rec.fm_operation_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.fm_operation_code := p_old_ShopFloorMove_rec.fm_operation_code;
    END IF;

    IF l_ShopFloorMove_rec.fm_operation_seq_num = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_operation_seq_num := p_old_ShopFloorMove_rec.fm_operation_seq_num;
    END IF;

    IF l_ShopFloorMove_rec.group_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.group_id := p_old_ShopFloorMove_rec.group_id;
    END IF;

    IF l_ShopFloorMove_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.kanban_card_id := p_old_ShopFloorMove_rec.kanban_card_id;
    END IF;

    IF l_ShopFloorMove_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.last_updated_by := p_old_ShopFloorMove_rec.last_updated_by;
    END IF;

    IF l_ShopFloorMove_rec.last_updated_by_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.last_updated_by_name := p_old_ShopFloorMove_rec.last_updated_by_name;
    END IF;

    IF l_ShopFloorMove_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.last_update_date := p_old_ShopFloorMove_rec.last_update_date;
    END IF;

    IF l_ShopFloorMove_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.last_update_login := p_old_ShopFloorMove_rec.last_update_login;
    END IF;

    IF l_ShopFloorMove_rec.line_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.line_code := p_old_ShopFloorMove_rec.line_code;
    END IF;

    IF l_ShopFloorMove_rec.line_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.line_id := p_old_ShopFloorMove_rec.line_id;
    END IF;

    IF l_ShopFloorMove_rec.organization_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.organization_code := p_old_ShopFloorMove_rec.organization_code;
    END IF;

    IF l_ShopFloorMove_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.organization_id := p_old_ShopFloorMove_rec.organization_id;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_primary_qty = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_primary_qty := p_old_ShopFloorMove_rec.overcpl_primary_qty;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_transaction_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_transaction_id := p_old_ShopFloorMove_rec.overcpl_transaction_id;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_transaction_qty = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_transaction_qty := p_old_ShopFloorMove_rec.overcpl_transaction_qty;
    END IF;

    IF l_ShopFloorMove_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.primary_item_id := p_old_ShopFloorMove_rec.primary_item_id;
    END IF;

    IF l_ShopFloorMove_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.primary_quantity := p_old_ShopFloorMove_rec.primary_quantity;
    END IF;

    IF l_ShopFloorMove_rec.primary_uom = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.primary_uom := p_old_ShopFloorMove_rec.primary_uom;
    END IF;

    IF l_ShopFloorMove_rec.process_phase = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.process_phase := p_old_ShopFloorMove_rec.process_phase;
    END IF;

    IF l_ShopFloorMove_rec.process_status = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.process_status := p_old_ShopFloorMove_rec.process_status;
    END IF;

    IF l_ShopFloorMove_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.program_application_id := p_old_ShopFloorMove_rec.program_application_id;
    END IF;

    IF l_ShopFloorMove_rec.program_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.program_id := p_old_ShopFloorMove_rec.program_id;
    END IF;

    IF l_ShopFloorMove_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.program_update_date := p_old_ShopFloorMove_rec.program_update_date;
    END IF;

    IF l_ShopFloorMove_rec.qa_collection_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.qa_collection_id := p_old_ShopFloorMove_rec.qa_collection_id;
    END IF;

    IF l_ShopFloorMove_rec.reason_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.reason_id := p_old_ShopFloorMove_rec.reason_id;
    END IF;

    IF l_ShopFloorMove_rec.reason_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.reason_name := p_old_ShopFloorMove_rec.reason_name;
    END IF;

    IF l_ShopFloorMove_rec.reference = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.reference := p_old_ShopFloorMove_rec.reference;
    END IF;

    IF l_ShopFloorMove_rec.repetitive_schedule_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.repetitive_schedule_id := p_old_ShopFloorMove_rec.repetitive_schedule_id;
    END IF;

    IF l_ShopFloorMove_rec.request_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.request_id := p_old_ShopFloorMove_rec.request_id;
    END IF;

    IF l_ShopFloorMove_rec.scrap_account_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.scrap_account_id := p_old_ShopFloorMove_rec.scrap_account_id;
    END IF;

    IF l_ShopFloorMove_rec.source_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.source_code := p_old_ShopFloorMove_rec.source_code;
    END IF;

    IF l_ShopFloorMove_rec.source_line_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.source_line_id := p_old_ShopFloorMove_rec.source_line_id;
    END IF;

    IF l_ShopFloorMove_rec.to_department_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.to_department_code := p_old_ShopFloorMove_rec.to_department_code;
    END IF;

    IF l_ShopFloorMove_rec.to_department_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_department_id := p_old_ShopFloorMove_rec.to_department_id;
    END IF;

    IF l_ShopFloorMove_rec.to_intraop_step_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_intraop_step_type := p_old_ShopFloorMove_rec.to_intraop_step_type;
    END IF;

    IF l_ShopFloorMove_rec.to_operation_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.to_operation_code := p_old_ShopFloorMove_rec.to_operation_code;
    END IF;

    IF l_ShopFloorMove_rec.to_operation_seq_num = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_operation_seq_num := p_old_ShopFloorMove_rec.to_operation_seq_num;
    END IF;

    IF l_ShopFloorMove_rec.transaction_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.transaction_date := p_old_ShopFloorMove_rec.transaction_date;
    END IF;

    IF l_ShopFloorMove_rec.transaction_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_id := p_old_ShopFloorMove_rec.transaction_id;
    END IF;

    IF l_ShopFloorMove_rec.transaction_quantity = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_quantity := p_old_ShopFloorMove_rec.transaction_quantity;
    END IF;

    IF l_ShopFloorMove_rec.transaction_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_type := p_old_ShopFloorMove_rec.transaction_type;
    END IF;

    IF l_ShopFloorMove_rec.transaction_uom = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.transaction_uom := p_old_ShopFloorMove_rec.transaction_uom;
    END IF;

    IF l_ShopFloorMove_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.wip_entity_id := p_old_ShopFloorMove_rec.wip_entity_id;
    END IF;

    IF l_ShopFloorMove_rec.wip_entity_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.wip_entity_name := p_old_ShopFloorMove_rec.wip_entity_name;
    END IF;

    RETURN l_ShopFloorMove_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type
IS
l_ShopFloorMove_rec           WIP_Transaction_PUB.Shopfloormove_Rec_Type := p_ShopFloorMove_rec;
BEGIN

    IF l_ShopFloorMove_rec.acct_period_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.acct_period_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute1 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute10 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute11 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute12 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute13 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute14 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute15 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute2 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute3 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute4 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute5 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute6 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute7 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute8 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute9 := NULL;
    END IF;

    IF l_ShopFloorMove_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.attribute_category := NULL;
    END IF;

    IF l_ShopFloorMove_rec.created_by = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.created_by := NULL;
    END IF;

    IF l_ShopFloorMove_rec.created_by_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.created_by_name := NULL;
    END IF;

    IF l_ShopFloorMove_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.creation_date := NULL;
    END IF;

    IF l_ShopFloorMove_rec.entity_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.entity_type := NULL;
    END IF;

    IF l_ShopFloorMove_rec.fm_department_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.fm_department_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.fm_department_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_department_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.fm_intraop_step_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_intraop_step_type := NULL;
    END IF;

    IF l_ShopFloorMove_rec.fm_operation_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.fm_operation_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.fm_operation_seq_num = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.fm_operation_seq_num := NULL;
    END IF;

    IF l_ShopFloorMove_rec.group_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.group_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.kanban_card_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.kanban_card_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.last_updated_by := NULL;
    END IF;

    IF l_ShopFloorMove_rec.last_updated_by_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.last_updated_by_name := NULL;
    END IF;

    IF l_ShopFloorMove_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.last_update_date := NULL;
    END IF;

    IF l_ShopFloorMove_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.last_update_login := NULL;
    END IF;

    IF l_ShopFloorMove_rec.line_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.line_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.line_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.line_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.organization_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.organization_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.organization_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_primary_qty = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_primary_qty := NULL;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_transaction_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_transaction_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.overcpl_transaction_qty = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.overcpl_transaction_qty := NULL;
    END IF;

    IF l_ShopFloorMove_rec.primary_item_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.primary_item_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.primary_quantity = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.primary_quantity := NULL;
    END IF;

    IF l_ShopFloorMove_rec.primary_uom = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.primary_uom := NULL;
    END IF;

    IF l_ShopFloorMove_rec.process_phase = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.process_phase := NULL;
    END IF;

    IF l_ShopFloorMove_rec.process_status = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.process_status := NULL;
    END IF;

    IF l_ShopFloorMove_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.program_application_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.program_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.program_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.program_update_date := NULL;
    END IF;

    IF l_ShopFloorMove_rec.qa_collection_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.qa_collection_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.reason_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.reason_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.reason_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.reason_name := NULL;
    END IF;

    IF l_ShopFloorMove_rec.reference = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.reference := NULL;
    END IF;

    IF l_ShopFloorMove_rec.repetitive_schedule_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.repetitive_schedule_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.request_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.request_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.scrap_account_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.scrap_account_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.source_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.source_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.source_line_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.source_line_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.to_department_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.to_department_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.to_department_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_department_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.to_intraop_step_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_intraop_step_type := NULL;
    END IF;

    IF l_ShopFloorMove_rec.to_operation_code = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.to_operation_code := NULL;
    END IF;

    IF l_ShopFloorMove_rec.to_operation_seq_num = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.to_operation_seq_num := NULL;
    END IF;

    IF l_ShopFloorMove_rec.transaction_date = FND_API.G_MISS_DATE THEN
        l_ShopFloorMove_rec.transaction_date := NULL;
    END IF;

    IF l_ShopFloorMove_rec.transaction_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.transaction_quantity = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_quantity := NULL;
    END IF;

    IF l_ShopFloorMove_rec.transaction_type = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.transaction_type := NULL;
    END IF;

    IF l_ShopFloorMove_rec.transaction_uom = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.transaction_uom := NULL;
    END IF;

    IF l_ShopFloorMove_rec.wip_entity_id = FND_API.G_MISS_NUM THEN
        l_ShopFloorMove_rec.wip_entity_id := NULL;
    END IF;

    IF l_ShopFloorMove_rec.wip_entity_name = FND_API.G_MISS_CHAR THEN
        l_ShopFloorMove_rec.wip_entity_name := NULL;
    END IF;

    RETURN l_ShopFloorMove_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row


--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_ShopFloorMove_rec             IN  WIP_Transaction_PUB.Shopfloormove_Rec_Type
)
IS
BEGIN

    INSERT  INTO WIP_MOVE_TXN_INTERFACE
    (       ACCT_PERIOD_ID
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
    ,       CREATED_BY
    ,       CREATED_BY_NAME
    ,       CREATION_DATE
    ,       ENTITY_TYPE
    ,       FM_DEPARTMENT_CODE
    ,       FM_DEPARTMENT_ID
    ,       FM_INTRAOPERATION_STEP_TYPE
    ,       FM_OPERATION_CODE
    ,       FM_OPERATION_SEQ_NUM
    ,       GROUP_ID
    ,       KANBAN_CARD_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATED_BY_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_CODE
    ,       LINE_ID
    ,       ORGANIZATION_CODE
    ,       ORGANIZATION_ID
    ,       OVERCOMPLETION_PRIMARY_QTY
    ,       OVERCOMPLETION_TRANSACTION_ID
    ,       OVERCOMPLETION_TRANSACTION_QTY
    ,       PRIMARY_ITEM_ID
    ,       PRIMARY_QUANTITY
    ,       PRIMARY_UOM
    ,       PROCESS_PHASE
    ,       PROCESS_STATUS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QA_COLLECTION_ID
    ,       REASON_ID
    ,       REASON_NAME
    ,       REFERENCE
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       SCRAP_ACCOUNT_ID
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       TO_DEPARTMENT_CODE
    ,       TO_DEPARTMENT_ID
    ,       TO_INTRAOPERATION_STEP_TYPE
    ,       TO_OPERATION_CODE
    ,       TO_OPERATION_SEQ_NUM
    ,       TRANSACTION_DATE
    ,       TRANSACTION_ID
    ,       TRANSACTION_QUANTITY
    ,       TRANSACTION_TYPE
    ,       TRANSACTION_UOM
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    )
    VALUES
    (       p_ShopFloorMove_rec.acct_period_id
    ,       p_ShopFloorMove_rec.attribute1
    ,       p_ShopFloorMove_rec.attribute10
    ,       p_ShopFloorMove_rec.attribute11
    ,       p_ShopFloorMove_rec.attribute12
    ,       p_ShopFloorMove_rec.attribute13
    ,       p_ShopFloorMove_rec.attribute14
    ,       p_ShopFloorMove_rec.attribute15
    ,       p_ShopFloorMove_rec.attribute2
    ,       p_ShopFloorMove_rec.attribute3
    ,       p_ShopFloorMove_rec.attribute4
    ,       p_ShopFloorMove_rec.attribute5
    ,       p_ShopFloorMove_rec.attribute6
    ,       p_ShopFloorMove_rec.attribute7
    ,       p_ShopFloorMove_rec.attribute8
    ,       p_ShopFloorMove_rec.attribute9
    ,       p_ShopFloorMove_rec.attribute_category
    ,       p_ShopFloorMove_rec.created_by
    ,       p_ShopFloorMove_rec.created_by_name
    ,       p_ShopFloorMove_rec.creation_date
    ,       p_ShopFloorMove_rec.entity_type
    ,       p_ShopFloorMove_rec.fm_department_code
    ,       p_ShopFloorMove_rec.fm_department_id
    ,       p_ShopFloorMove_rec.fm_intraop_step_type
    ,       p_ShopFloorMove_rec.fm_operation_code
    ,       p_ShopFloorMove_rec.fm_operation_seq_num
    ,       p_ShopFloorMove_rec.group_id
    ,       p_ShopFloorMove_rec.kanban_card_id
    ,       p_ShopFloorMove_rec.last_updated_by
    ,       p_ShopFloorMove_rec.last_updated_by_name
    ,       p_ShopFloorMove_rec.last_update_date
    ,       p_ShopFloorMove_rec.last_update_login
    ,       p_ShopFloorMove_rec.line_code
    ,       p_ShopFloorMove_rec.line_id
    ,       p_ShopFloorMove_rec.organization_code
    ,       p_ShopFloorMove_rec.organization_id
    ,       p_ShopFloorMove_rec.overcpl_primary_qty
    ,       p_ShopFloorMove_rec.overcpl_transaction_id
    ,       p_ShopFloorMove_rec.overcpl_transaction_qty
    ,       p_ShopFloorMove_rec.primary_item_id
    ,       p_ShopFloorMove_rec.primary_quantity
    ,       p_ShopFloorMove_rec.primary_uom
    ,       p_ShopFloorMove_rec.process_phase
    ,       p_ShopFloorMove_rec.process_status
    ,       p_ShopFloorMove_rec.program_application_id
    ,       p_ShopFloorMove_rec.program_id
    ,       p_ShopFloorMove_rec.program_update_date
    ,       p_ShopFloorMove_rec.qa_collection_id
    ,       p_ShopFloorMove_rec.reason_id
    ,       p_ShopFloorMove_rec.reason_name
    ,       p_ShopFloorMove_rec.reference
    ,       p_ShopFloorMove_rec.repetitive_schedule_id
    ,       p_ShopFloorMove_rec.request_id
    ,       p_ShopFloorMove_rec.scrap_account_id
    ,       p_ShopFloorMove_rec.source_code
    ,       p_ShopFloorMove_rec.source_line_id
    ,       p_ShopFloorMove_rec.to_department_code
    ,       p_ShopFloorMove_rec.to_department_id
    ,       p_ShopFloorMove_rec.to_intraop_step_type
    ,       p_ShopFloorMove_rec.to_operation_code
    ,       p_ShopFloorMove_rec.to_operation_seq_num
    ,       p_ShopFloorMove_rec.transaction_date
    ,       p_ShopFloorMove_rec.transaction_id
    ,       p_ShopFloorMove_rec.transaction_quantity
    ,       p_ShopFloorMove_rec.transaction_type
    ,       p_ShopFloorMove_rec.transaction_uom
    ,       p_ShopFloorMove_rec.wip_entity_id
    ,       p_ShopFloorMove_rec.wip_entity_name
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
(   p_transaction_id                IN  NUMBER
)
IS
BEGIN

    DELETE  FROM WIP_MOVE_TXN_INTERFACE
    WHERE   TRANSACTION_ID = p_transaction_id
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

FUNCTION Query_Row
(   p_transaction_id                IN  NUMBER
) RETURN WIP_Transaction_PUB.Shopfloormove_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_transaction_id              => p_transaction_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_transaction_id                IN  NUMBER :=
                                        NULL
,   p_dummy                         IN  VARCHAR2 :=
                                        NULL
) RETURN WIP_Transaction_PUB.Shopfloormove_Tbl_Type
IS
l_ShopFloorMove_rec           WIP_Transaction_PUB.Shopfloormove_Rec_Type;
l_ShopFloorMove_tbl           WIP_Transaction_PUB.Shopfloormove_Tbl_Type;

CURSOR l_ShopFloorMove_csr IS
    SELECT  ACCT_PERIOD_ID
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
    ,       CREATED_BY
    ,       CREATED_BY_NAME
    ,       CREATION_DATE
    ,       ENTITY_TYPE
    ,       FM_DEPARTMENT_CODE
    ,       FM_DEPARTMENT_ID
    ,       FM_INTRAOPERATION_STEP_TYPE
    ,       FM_OPERATION_CODE
    ,       FM_OPERATION_SEQ_NUM
    ,       GROUP_ID
    ,       KANBAN_CARD_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATED_BY_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LINE_CODE
    ,       LINE_ID
    ,       ORGANIZATION_CODE
    ,       ORGANIZATION_ID
    ,       OVERCOMPLETION_PRIMARY_QTY
    ,       OVERCOMPLETION_TRANSACTION_ID
    ,       OVERCOMPLETION_TRANSACTION_QTY
    ,       PRIMARY_ITEM_ID
    ,       PRIMARY_QUANTITY
    ,       PRIMARY_UOM
    ,       PROCESS_PHASE
    ,       PROCESS_STATUS
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       QA_COLLECTION_ID
    ,       REASON_ID
    ,       REASON_NAME
    ,       REFERENCE
    ,       REPETITIVE_SCHEDULE_ID
    ,       REQUEST_ID
    ,       SCRAP_ACCOUNT_ID
    ,       SOURCE_CODE
    ,       SOURCE_LINE_ID
    ,       TO_DEPARTMENT_CODE
    ,       TO_DEPARTMENT_ID
    ,       TO_INTRAOPERATION_STEP_TYPE
    ,       TO_OPERATION_CODE
    ,       TO_OPERATION_SEQ_NUM
    ,       TRANSACTION_DATE
    ,       TRANSACTION_ID
    ,       TRANSACTION_QUANTITY
    ,       TRANSACTION_TYPE
    ,       TRANSACTION_UOM
    ,       WIP_ENTITY_ID
    ,       WIP_ENTITY_NAME
    FROM    WIP_MOVE_TXN_INTERFACE
    WHERE ( TRANSACTION_ID = nvl(p_transaction_id,FND_API.G_MISS_NUM)
    );

BEGIN


    --  Loop over fetched records

    FOR l_implicit_rec IN l_ShopFloorMove_csr LOOP

        l_ShopFloorMove_rec.acct_period_id := l_implicit_rec.ACCT_PERIOD_ID;
        l_ShopFloorMove_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_ShopFloorMove_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_ShopFloorMove_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_ShopFloorMove_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_ShopFloorMove_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_ShopFloorMove_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_ShopFloorMove_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_ShopFloorMove_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_ShopFloorMove_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_ShopFloorMove_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_ShopFloorMove_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_ShopFloorMove_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_ShopFloorMove_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_ShopFloorMove_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_ShopFloorMove_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_ShopFloorMove_rec.attribute_category := l_implicit_rec.ATTRIBUTE_CATEGORY;
        l_ShopFloorMove_rec.created_by := l_implicit_rec.CREATED_BY;
        l_ShopFloorMove_rec.created_by_name := l_implicit_rec.CREATED_BY_NAME;
        l_ShopFloorMove_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_ShopFloorMove_rec.entity_type := l_implicit_rec.ENTITY_TYPE;
        l_ShopFloorMove_rec.fm_department_code := l_implicit_rec.FM_DEPARTMENT_CODE;
        l_ShopFloorMove_rec.fm_department_id := l_implicit_rec.FM_DEPARTMENT_ID;
        l_ShopFloorMove_rec.fm_intraop_step_type := l_implicit_rec.FM_INTRAOPERATION_STEP_TYPE;
        l_ShopFloorMove_rec.fm_operation_code := l_implicit_rec.FM_OPERATION_CODE;
        l_ShopFloorMove_rec.fm_operation_seq_num := l_implicit_rec.FM_OPERATION_SEQ_NUM;
        l_ShopFloorMove_rec.group_id   := l_implicit_rec.GROUP_ID;
        l_ShopFloorMove_rec.kanban_card_id := l_implicit_rec.KANBAN_CARD_ID;
        l_ShopFloorMove_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_ShopFloorMove_rec.last_updated_by_name := l_implicit_rec.LAST_UPDATED_BY_NAME;
        l_ShopFloorMove_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_ShopFloorMove_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_ShopFloorMove_rec.line_code  := l_implicit_rec.LINE_CODE;
        l_ShopFloorMove_rec.line_id    := l_implicit_rec.LINE_ID;
        l_ShopFloorMove_rec.organization_code := l_implicit_rec.ORGANIZATION_CODE;
        l_ShopFloorMove_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_ShopFloorMove_rec.overcpl_primary_qty := l_implicit_rec.OVERCOMPLETION_PRIMARY_QTY;
        l_ShopFloorMove_rec.overcpl_transaction_id := l_implicit_rec.OVERCOMPLETION_TRANSACTION_ID;
        l_ShopFloorMove_rec.overcpl_transaction_qty := l_implicit_rec.OVERCOMPLETION_TRANSACTION_QTY;
        l_ShopFloorMove_rec.primary_item_id := l_implicit_rec.PRIMARY_ITEM_ID;
        l_ShopFloorMove_rec.primary_quantity := l_implicit_rec.PRIMARY_QUANTITY;
        l_ShopFloorMove_rec.primary_uom := l_implicit_rec.PRIMARY_UOM;
        l_ShopFloorMove_rec.process_phase := l_implicit_rec.PROCESS_PHASE;
        l_ShopFloorMove_rec.process_status := l_implicit_rec.PROCESS_STATUS;
        l_ShopFloorMove_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_ShopFloorMove_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_ShopFloorMove_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_ShopFloorMove_rec.qa_collection_id := l_implicit_rec.QA_COLLECTION_ID;
        l_ShopFloorMove_rec.reason_id  := l_implicit_rec.REASON_ID;
        l_ShopFloorMove_rec.reason_name := l_implicit_rec.REASON_NAME;
        l_ShopFloorMove_rec.reference  := l_implicit_rec.REFERENCE;
        l_ShopFloorMove_rec.repetitive_schedule_id := l_implicit_rec.REPETITIVE_SCHEDULE_ID;
        l_ShopFloorMove_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_ShopFloorMove_rec.scrap_account_id := l_implicit_rec.SCRAP_ACCOUNT_ID;
        l_ShopFloorMove_rec.source_code := l_implicit_rec.SOURCE_CODE;
        l_ShopFloorMove_rec.source_line_id := l_implicit_rec.SOURCE_LINE_ID;
        l_ShopFloorMove_rec.to_department_code := l_implicit_rec.TO_DEPARTMENT_CODE;
        l_ShopFloorMove_rec.to_department_id := l_implicit_rec.TO_DEPARTMENT_ID;
        l_ShopFloorMove_rec.to_intraop_step_type := l_implicit_rec.TO_INTRAOPERATION_STEP_TYPE;
        l_ShopFloorMove_rec.to_operation_code := l_implicit_rec.TO_OPERATION_CODE;
        l_ShopFloorMove_rec.to_operation_seq_num := l_implicit_rec.TO_OPERATION_SEQ_NUM;
        l_ShopFloorMove_rec.transaction_date := l_implicit_rec.TRANSACTION_DATE;
        l_ShopFloorMove_rec.transaction_id := l_implicit_rec.TRANSACTION_ID;
        l_ShopFloorMove_rec.transaction_quantity := l_implicit_rec.TRANSACTION_QUANTITY;
        l_ShopFloorMove_rec.transaction_type := l_implicit_rec.TRANSACTION_TYPE;
        l_ShopFloorMove_rec.transaction_uom := l_implicit_rec.TRANSACTION_UOM;
        l_ShopFloorMove_rec.wip_entity_id := l_implicit_rec.WIP_ENTITY_ID;
        l_ShopFloorMove_rec.wip_entity_name := l_implicit_rec.WIP_ENTITY_NAME;

        l_ShopFloorMove_tbl(l_ShopFloorMove_tbl.COUNT + 1) := l_ShopFloorMove_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_transaction_id IS NOT NULL
     AND
     p_transaction_id <> FND_API.G_MISS_NUM)
    AND
    (l_ShopFloorMove_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_ShopFloorMove_tbl;

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


PROCEDURE print_record(p_ShopFloorMove_rec IN WIP_Transaction_PUB.ShopFloorMove_Rec_Type)
  IS
BEGIN

     null;
--   dbms_output.put_line('  ');
--   dbms_output.put_line('ShopFloorMove Record*********************************');

--    dbms_output.put_line('acct_period_id ' ||  p_ShopFloorMove_rec.Acct_Period_id);
--    dbms_output.put_line('created_by_name ' ||  p_ShopFloorMove_rec.Created_By_Name);
--    dbms_output.put_line('entity_type ' ||  p_ShopFloorMove_rec.Entity_Type);
--    dbms_output.put_line('fm_department_code ' ||  p_ShopFloorMove_rec.Fm_Department_Code);
--    dbms_output.put_line('fm_department_id ' ||  p_ShopFloorMove_rec.Fm_Department_Id);
--    dbms_output.put_line('fm_intraop_step_type ' ||  p_ShopFloorMove_rec.Fm_Intraop_Step_Type);
--    dbms_output.put_line('fm_operation_code ' ||  p_ShopFloorMove_rec.Fm_Operation_code);
--    dbms_output.put_line('fm_operation_seq_num ' ||  p_ShopFloorMove_rec.Fm_Operation_Seq_Num);
--    dbms_output.put_line('group_id ' ||  p_ShopFloorMove_rec.Group_id);
--    dbms_output.put_line('last_updated_by_name ' ||  p_ShopFloorMove_rec.Last_Updated_By_Name);
--    dbms_output.put_line('line_code ' ||  p_ShopFloorMove_rec.Line_Code);
--    dbms_output.put_line('line_id ' ||  p_ShopFloorMove_rec.Line_Id);
--    dbms_output.put_line('organization_code ' ||  p_ShopFloorMove_rec.Organization_Code);
--    dbms_output.put_line('organization_id ' ||  p_ShopFloorMove_rec.Organization_Id);
--    dbms_output.put_line('overcpl_primary_qty ' ||  p_ShopFloorMove_rec.Overcpl_Primary_Qty);
--    dbms_output.put_line('overcpl_transaction_id ' ||  p_ShopFloorMove_rec.Overcpl_Transaction_id);
--    dbms_output.put_line('overcpl_transaction_qty ' ||  p_ShopFloorMove_rec.Overcpl_Transaction_Qty);
--    dbms_output.put_line('primary_item_id ' ||  p_ShopFloorMove_rec.Primary_Item_id);
--    dbms_output.put_line('primary_quantity ' ||  p_ShopFloorMove_rec.Primary_Quantity);
--    dbms_output.put_line('primary_uom ' ||  p_ShopFloorMove_rec.Primary_Uom);
--    dbms_output.put_line('process_phase ' ||  p_ShopFloorMove_rec.Process_Phase);
--    dbms_output.put_line('process_status ' ||  p_ShopFloorMove_rec.Process_Status);
--    dbms_output.put_line('program_application_id ' ||  p_ShopFloorMove_rec.program_application_id);
--    dbms_output.put_line('program_id ' ||  p_ShopFloorMove_rec.program_id);
--    dbms_output.put_line('program_update_date ' ||  p_ShopFloorMove_rec.program_update_date);
--    dbms_output.put_line('qa_collection_id ' ||  p_ShopFloorMove_rec.Qa_Collection_id);
--    dbms_output.put_line('reason_id ' ||  p_ShopFloorMove_rec.Reason_id);
--    dbms_output.put_line('reason_name ' ||  p_ShopFloorMove_rec.Reason_Name);
--    dbms_output.put_line('reference ' ||  p_ShopFloorMove_rec.Reference);
--    dbms_output.put_line('repetitive_schedule_id ' ||  p_ShopFloorMove_rec.Repetitive_Schedule_id);
--    dbms_output.put_line('request_id ' ||  p_ShopFloorMove_rec.request_id);
--    dbms_output.put_line('scrap_account_id ' ||  p_ShopFloorMove_rec.Scrap_Account_id);
--    dbms_output.put_line('source_code ' ||  p_ShopFloorMove_rec.Source_code);
--    dbms_output.put_line('source_line_id ' ||  p_ShopFloorMove_rec.Source_Line_id);
--    dbms_output.put_line('to_department_code ' ||  p_ShopFloorMove_rec.To_Department_Code);
--    dbms_output.put_line('to_department_id ' ||  p_ShopFloorMove_rec.To_Department_Id);
--    dbms_output.put_line('to_intraop_step_type ' ||  p_ShopFloorMove_rec.To_Intraop_Step_Type);
--    dbms_output.put_line('to_operation_code ' ||  p_ShopFloorMove_rec.To_Operation_code);
--    dbms_output.put_line('to_operation_seq_num ' ||  p_ShopFloorMove_rec.To_Operation_Seq_Num);
--    dbms_output.put_line('transaction_date ' ||  p_ShopFloorMove_rec.Transaction_Date);
--    dbms_output.put_line('transaction_id ' ||  p_ShopFloorMove_rec.Transaction_id);
--    dbms_output.put_line('transaction_quantity ' ||  p_ShopFloorMove_rec.Transaction_Quantity);
--    dbms_output.put_line('transaction_type ' ||  p_ShopFloorMove_rec.Transaction_Type);
--    dbms_output.put_line('transaction_uom ' ||  p_ShopFloorMove_rec.Transaction_Uom);
--    dbms_output.put_line('wip_entity_id ' ||  p_ShopFloorMove_rec.Wip_Entity_id);
--    dbms_output.put_line('wip_entity_name ' ||  p_ShopFloorMove_rec.Wip_Entity_Name);


END print_record;

END WIP_Shopfloormove_Util;

/
