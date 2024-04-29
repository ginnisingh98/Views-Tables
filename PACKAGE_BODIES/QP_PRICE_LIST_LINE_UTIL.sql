--------------------------------------------------------
--  DDL for Package Body QP_PRICE_LIST_LINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_LIST_LINE_UTIL" AS
/* $Header: QPXUPLLB.pls 120.10.12010000.6 2009/12/15 05:35:59 hmohamme ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Price_List_Line_Util';
--introduced the constant for performance problem
G_ORGANIZATION_ID             CONSTANT VARCHAR2(30) := TO_CHAR(QP_UTIL.Get_Item_Validation_Org);

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

    --  Load out record

    x_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_qty,p_old_PRICE_LIST_LINE_rec.accrual_qty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ACCRUAL_QTY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_uom_code,p_old_PRICE_LIST_LINE_rec.accrual_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ACCRUAL_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.arithmetic_operator,p_old_PRICE_LIST_LINE_rec.arithmetic_operator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ARITHMETIC_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute1,p_old_PRICE_LIST_LINE_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute10,p_old_PRICE_LIST_LINE_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute11,p_old_PRICE_LIST_LINE_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute12,p_old_PRICE_LIST_LINE_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute13,p_old_PRICE_LIST_LINE_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute14,p_old_PRICE_LIST_LINE_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute15,p_old_PRICE_LIST_LINE_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute2,p_old_PRICE_LIST_LINE_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute3,p_old_PRICE_LIST_LINE_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute4,p_old_PRICE_LIST_LINE_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute5,p_old_PRICE_LIST_LINE_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute6,p_old_PRICE_LIST_LINE_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute7,p_old_PRICE_LIST_LINE_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute8,p_old_PRICE_LIST_LINE_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute9,p_old_PRICE_LIST_LINE_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.automatic_flag,p_old_PRICE_LIST_LINE_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_AUTOMATIC;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_qty,p_old_PRICE_LIST_LINE_rec.base_qty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BASE_QTY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_uom_code,p_old_PRICE_LIST_LINE_rec.base_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BASE_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.comments,p_old_PRICE_LIST_LINE_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_COMMENTS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.context,p_old_PRICE_LIST_LINE_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.created_by,p_old_PRICE_LIST_LINE_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.creation_date,p_old_PRICE_LIST_LINE_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.effective_period_uom,p_old_PRICE_LIST_LINE_rec.effective_period_uom)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_EFFECTIVE_PERIOD_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.end_date_active,p_old_PRICE_LIST_LINE_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.estim_accrual_rate,p_old_PRICE_LIST_LINE_rec.estim_accrual_rate)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ESTIM_ACCRUAL_RATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.generate_using_formula_id,p_old_PRICE_LIST_LINE_rec.generate_using_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_GENERATE_USING_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,p_old_PRICE_LIST_LINE_rec.inventory_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_INVENTORY_ITEM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_updated_by,p_old_PRICE_LIST_LINE_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_date,p_old_PRICE_LIST_LINE_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_login,p_old_PRICE_LIST_LINE_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_header_id,p_old_PRICE_LIST_LINE_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_id,p_old_PRICE_LIST_LINE_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_type_code,p_old_PRICE_LIST_LINE_rec.list_line_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_LINE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_price,p_old_PRICE_LIST_LINE_rec.list_price)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_PRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.from_rltd_modifier_id,p_old_PRICE_LIST_LINE_rec.from_rltd_modifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_FROM_RLTD_MODIFIER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rltd_modifier_group_no,p_old_PRICE_LIST_LINE_rec.rltd_modifier_group_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RLTD_MODIFIER_GROUP_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.product_precedence,p_old_PRICE_LIST_LINE_rec.product_precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRODUCT_PRECEDENCE;
        END IF;


        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.modifier_level_code,p_old_PRICE_LIST_LINE_rec.modifier_level_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_MODIFIER_LEVEL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.number_effective_periods,p_old_PRICE_LIST_LINE_rec.number_effective_periods)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_NUMBER_EFFECTIVE_PERIODS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.operand,p_old_PRICE_LIST_LINE_rec.operand)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_OPERAND;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.organization_id,p_old_PRICE_LIST_LINE_rec.organization_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ORGANIZATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.override_flag,p_old_PRICE_LIST_LINE_rec.override_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_OVERRIDE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.percent_price,p_old_PRICE_LIST_LINE_rec.percent_price)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PERCENT_PRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_break_type_code,p_old_PRICE_LIST_LINE_rec.price_break_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRICE_BREAK_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_by_formula_id,p_old_PRICE_LIST_LINE_rec.price_by_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRICE_BY_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.primary_uom_flag,p_old_PRICE_LIST_LINE_rec.primary_uom_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRIMARY_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.print_on_invoice_flag,p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRINT_ON_INVOICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_application_id,p_old_PRICE_LIST_LINE_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_id,p_old_PRICE_LIST_LINE_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_update_date,p_old_PRICE_LIST_LINE_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rebate_trxn_type_code,p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REBATE_TRANSACTION_TYPE;
        END IF;

        -- block pricing
        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.recurring_value, p_old_PRICE_LIST_LINE_rec.recurring_value)
        THEN
          l_index := l_index+1;
          l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RECURRING_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.related_item_id,p_old_PRICE_LIST_LINE_rec.related_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RELATED_ITEM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.relationship_type_id,p_old_PRICE_LIST_LINE_rec.relationship_type_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RELATIONSHIP_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,p_old_PRICE_LIST_LINE_rec.reprice_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REPRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.request_id,p_old_PRICE_LIST_LINE_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision,p_old_PRICE_LIST_LINE_rec.revision)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_date,p_old_PRICE_LIST_LINE_rec.revision_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,p_old_PRICE_LIST_LINE_rec.revision_reason_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION_REASON;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.start_date_active,p_old_PRICE_LIST_LINE_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_attribute,p_old_PRICE_LIST_LINE_rec.substitution_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_context,p_old_PRICE_LIST_LINE_rec.substitution_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_value,p_old_PRICE_LIST_LINE_rec.substitution_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_VALUE;
        END IF;

	IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id, p_old_PRICE_LIST_LINE_rec.customer_item_id)
	THEN
	    l_index := l_index + 1;
	    l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CUSTOMER_ITEM_ID;
	END IF;

    ELSIF p_attr_id = G_ACCRUAL_QTY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ACCRUAL_QTY;
    ELSIF p_attr_id = G_ACCRUAL_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ACCRUAL_UOM;
    ELSIF p_attr_id = G_ARITHMETIC_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ARITHMETIC_OPERATOR;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AUTOMATIC THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_AUTOMATIC;
    ELSIF p_attr_id = G_BASE_QTY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BASE_QTY;
    ELSIF p_attr_id = G_BASE_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BASE_UOM;
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_EFFECTIVE_PERIOD_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_EFFECTIVE_PERIOD_UOM;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_ESTIM_ACCRUAL_RATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ESTIM_ACCRUAL_RATE;
    ELSIF p_attr_id = G_GENERATE_USING_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_GENERATE_USING_FORMULA;
    ELSIF p_attr_id = G_INVENTORY_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_INVENTORY_ITEM;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_LIST_LINE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_LINE_TYPE;
    ELSIF p_attr_id = G_LIST_PRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_LIST_PRICE;
    ELSIF p_attr_id = G_FROM_RLTD_MODIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_FROM_RLTD_MODIFIER;
    ELSIF p_attr_id = G_RLTD_MODIFIER_GROUP_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RLTD_MODIFIER_GROUP_NO;
    ELSIF p_attr_id = G_PRODUCT_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRODUCT_PRECEDENCE;
    ELSIF p_attr_id = G_MODIFIER_LEVEL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_MODIFIER_LEVEL;
    ELSIF p_attr_id = G_NUMBER_EFFECTIVE_PERIODS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_NUMBER_EFFECTIVE_PERIODS;
    ELSIF p_attr_id = G_OPERAND THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_OPERAND;
    ELSIF p_attr_id = G_ORGANIZATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_ORGANIZATION;
    ELSIF p_attr_id = G_OVERRIDE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_OVERRIDE;
    ELSIF p_attr_id = G_PERCENT_PRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PERCENT_PRICE;
    ELSIF p_attr_id = G_PRICE_BREAK_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRICE_BREAK_TYPE;
    ELSIF p_attr_id = G_PRICE_BY_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRICE_BY_FORMULA;
    ELSIF p_attr_id = G_PRIMARY_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRIMARY_UOM;
    ELSIF p_attr_id = G_PRINT_ON_INVOICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PRINT_ON_INVOICE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_PROGRAM_UPDATE_DATE;
    ELSIF p_attr_id = G_REBATE_TRANSACTION_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REBATE_TRANSACTION_TYPE;
    -- block pricing
    ELSIF p_attr_id = G_RECURRING_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RECURRING_VALUE;
    ELSIF p_attr_id = G_RELATED_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RELATED_ITEM;
    ELSIF p_attr_id = G_RELATIONSHIP_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_RELATIONSHIP_TYPE;
    ELSIF p_attr_id = G_REPRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REPRICE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_REVISION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION;
    ELSIF p_attr_id = G_REVISION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION_DATE;
    ELSIF p_attr_id = G_REVISION_REASON THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_REVISION_REASON;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_SUBSTITUTION_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_ATTRIBUTE;
    ELSIF p_attr_id = G_SUBSTITUTION_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_CONTEXT;
    ELSIF p_attr_id = G_SUBSTITUTION_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_SUBSTITUTION_VALUE;
    ELSIF p_attr_id = G_CUSTOMER_ITEM_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CUSTOMER_ITEM_ID;
    ELSIF p_attr_id = G_BREAK_UOM_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BREAK_UOM_CODE;
    ELSIF p_attr_id = G_BREAK_UOM_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BREAK_UOM_CONTEXT;
    ELSIF p_attr_id = G_BREAK_UOM_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_BREAK_UOM_ATTRIBUTE;
    ELSIF p_attr_id = G_CONTINUOUS_PRICE_BREAK_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_PRICE_LIST_LINE_UTIL.G_CONTINUOUS_PRICE_BREAK_FLAG;
    END IF;

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_return_status 	varchar2(30);
BEGIN

    --  Load out record

    x_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    -- Set reprice_flag to 'Y' every time a price list line is added/modified
    x_PRICE_LIST_LINE_rec.reprice_flag  := 'Y';

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_qty,p_old_PRICE_LIST_LINE_rec.accrual_qty)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_uom_code,p_old_PRICE_LIST_LINE_rec.accrual_uom_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.arithmetic_operator,p_old_PRICE_LIST_LINE_rec.arithmetic_operator)
    THEN
        NULL;
    END IF;


    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute1,p_old_PRICE_LIST_LINE_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute10,p_old_PRICE_LIST_LINE_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute11,p_old_PRICE_LIST_LINE_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute12,p_old_PRICE_LIST_LINE_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute13,p_old_PRICE_LIST_LINE_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute14,p_old_PRICE_LIST_LINE_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute15,p_old_PRICE_LIST_LINE_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute2,p_old_PRICE_LIST_LINE_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute3,p_old_PRICE_LIST_LINE_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute4,p_old_PRICE_LIST_LINE_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute5,p_old_PRICE_LIST_LINE_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute6,p_old_PRICE_LIST_LINE_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute7,p_old_PRICE_LIST_LINE_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute8,p_old_PRICE_LIST_LINE_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute9,p_old_PRICE_LIST_LINE_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.automatic_flag,p_old_PRICE_LIST_LINE_rec.automatic_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_qty,p_old_PRICE_LIST_LINE_rec.base_qty)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_uom_code,p_old_PRICE_LIST_LINE_rec.base_uom_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.comments,p_old_PRICE_LIST_LINE_rec.comments)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.context,p_old_PRICE_LIST_LINE_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.created_by,p_old_PRICE_LIST_LINE_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.creation_date,p_old_PRICE_LIST_LINE_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.effective_period_uom,p_old_PRICE_LIST_LINE_rec.effective_period_uom)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.end_date_active,p_old_PRICE_LIST_LINE_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.estim_accrual_rate,p_old_PRICE_LIST_LINE_rec.estim_accrual_rate)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.generate_using_formula_id,p_old_PRICE_LIST_LINE_rec.generate_using_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,p_old_PRICE_LIST_LINE_rec.inventory_item_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_updated_by,p_old_PRICE_LIST_LINE_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_date,p_old_PRICE_LIST_LINE_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_login,p_old_PRICE_LIST_LINE_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_header_id,p_old_PRICE_LIST_LINE_rec.list_header_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_id,p_old_PRICE_LIST_LINE_rec.list_line_id)
    THEN

      /* Commented out delayed request by dhgupta for bug 2018275. This delayed request is now being called from
         procedure insert_row  */
null;
/*
	 qp_delayed_requests_PVT.log_request(
		 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
   		 p_entity_id  => p_PRICE_LIST_LINE_rec.list_line_id,
		 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
		 p_requesting_entity_id => p_PRICE_LIST_LINE_rec.list_line_id,
		 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
		 x_return_status => l_return_status);
*/
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_type_code,p_old_PRICE_LIST_LINE_rec.list_line_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_price,p_old_PRICE_LIST_LINE_rec.list_price)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.from_rltd_modifier_id,p_old_PRICE_LIST_LINE_rec.from_rltd_modifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rltd_modifier_group_no,p_old_PRICE_LIST_LINE_rec.rltd_modifier_group_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.product_precedence,p_old_PRICE_LIST_LINE_rec.product_precedence)
    THEN
        NULL;
    END IF;


    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.modifier_level_code,p_old_PRICE_LIST_LINE_rec.modifier_level_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.number_effective_periods,p_old_PRICE_LIST_LINE_rec.number_effective_periods)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.operand,p_old_PRICE_LIST_LINE_rec.operand)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.organization_id,p_old_PRICE_LIST_LINE_rec.organization_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.override_flag,p_old_PRICE_LIST_LINE_rec.override_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.percent_price,p_old_PRICE_LIST_LINE_rec.percent_price)
    THEN
        NULL;
    END IF;

--IF not p_PRICE_LIST_LINE_rec.list_line_type_code = 'PHB'
--then null;
--else

--fnd_message.debug('gm before new code');
oe_debug_pub.add('gm before new code');

    IF NOT (QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_break_type_code,p_old_PRICE_LIST_LINE_rec.price_break_type_code)
	and QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.arithmetic_operator,p_old_PRICE_LIST_LINE_rec.arithmetic_operator))
    and (p_PRICE_LIST_LINE_rec.list_line_type_code = 'PBH')
    THEN
	   qp_delayed_requests_PVT.log_request(
		 p_entity_code => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE,
   		 p_entity_id  => p_PRICE_LIST_LINE_rec.list_line_id,
		 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Price_List_Line,
		 p_requesting_entity_id => p_PRICE_LIST_LINE_rec.list_line_id,
		 p_request_type =>QP_GLOBALS.G_UPDATE_CHILD_BREAKS,
		 x_return_status => l_return_status);
    END IF;
 --   END IF;
oe_debug_pub.add('gm after new code');


--fnd_message.debug('gm after new code');


    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_by_formula_id,p_old_PRICE_LIST_LINE_rec.price_by_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.primary_uom_flag,p_old_PRICE_LIST_LINE_rec.primary_uom_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.print_on_invoice_flag,p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_application_id,p_old_PRICE_LIST_LINE_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_id,p_old_PRICE_LIST_LINE_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_update_date,p_old_PRICE_LIST_LINE_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rebate_trxn_type_code,p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
    THEN
        NULL;
    END IF;

    -- block pricing
    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.recurring_value, p_old_PRICE_LIST_LINE_rec.recurring_value)
    THEN
      NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.related_item_id,p_old_PRICE_LIST_LINE_rec.related_item_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.relationship_type_id,p_old_PRICE_LIST_LINE_rec.relationship_type_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,p_old_PRICE_LIST_LINE_rec.reprice_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.request_id,p_old_PRICE_LIST_LINE_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision,p_old_PRICE_LIST_LINE_rec.revision)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_date,p_old_PRICE_LIST_LINE_rec.revision_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,p_old_PRICE_LIST_LINE_rec.revision_reason_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.start_date_active,p_old_PRICE_LIST_LINE_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_attribute,p_old_PRICE_LIST_LINE_rec.substitution_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_context,p_old_PRICE_LIST_LINE_rec.substitution_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_value,p_old_PRICE_LIST_LINE_rec.substitution_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id, p_old_PRICE_LIST_LINE_rec.customer_item_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.break_uom_code,p_old_PRICE_LIST_LINE_rec.break_uom_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.break_uom_context,p_old_PRICE_LIST_LINE_rec.break_uom_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.break_uom_attribute,p_old_PRICE_LIST_LINE_rec.break_uom_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.continuous_price_break_flag,p_old_PRICE_LIST_LINE_rec.continuous_price_break_flag)
    THEN
        NULL;
    END IF;

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type := p_PRICE_LIST_LINE_rec;
BEGIN

    IF l_PRICE_LIST_LINE_rec.accrual_qty = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.accrual_qty := p_old_PRICE_LIST_LINE_rec.accrual_qty;
    END IF;


    IF l_PRICE_LIST_LINE_rec.accrual_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.accrual_uom_code := p_old_PRICE_LIST_LINE_rec.accrual_uom_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.arithmetic_operator := p_old_PRICE_LIST_LINE_rec.arithmetic_operator;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute1 := p_old_PRICE_LIST_LINE_rec.attribute1;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute10 := p_old_PRICE_LIST_LINE_rec.attribute10;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute11 := p_old_PRICE_LIST_LINE_rec.attribute11;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute12 := p_old_PRICE_LIST_LINE_rec.attribute12;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute13 := p_old_PRICE_LIST_LINE_rec.attribute13;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute14 := p_old_PRICE_LIST_LINE_rec.attribute14;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute15 := p_old_PRICE_LIST_LINE_rec.attribute15;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute2 := p_old_PRICE_LIST_LINE_rec.attribute2;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute3 := p_old_PRICE_LIST_LINE_rec.attribute3;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute4 := p_old_PRICE_LIST_LINE_rec.attribute4;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute5 := p_old_PRICE_LIST_LINE_rec.attribute5;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute6 := p_old_PRICE_LIST_LINE_rec.attribute6;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute7 := p_old_PRICE_LIST_LINE_rec.attribute7;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute8 := p_old_PRICE_LIST_LINE_rec.attribute8;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute9 := p_old_PRICE_LIST_LINE_rec.attribute9;
    END IF;

    IF l_PRICE_LIST_LINE_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.automatic_flag := p_old_PRICE_LIST_LINE_rec.automatic_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.base_qty = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.base_qty := p_old_PRICE_LIST_LINE_rec.base_qty;
    END IF;

    IF l_PRICE_LIST_LINE_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.base_uom_code := p_old_PRICE_LIST_LINE_rec.base_uom_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.comments := p_old_PRICE_LIST_LINE_rec.comments;
    END IF;

    IF l_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.context := p_old_PRICE_LIST_LINE_rec.context;
    END IF;

    IF l_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.created_by := p_old_PRICE_LIST_LINE_rec.created_by;
    END IF;

    IF l_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.creation_date := p_old_PRICE_LIST_LINE_rec.creation_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.effective_period_uom := p_old_PRICE_LIST_LINE_rec.effective_period_uom;
    END IF;

    IF l_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.end_date_active := p_old_PRICE_LIST_LINE_rec.end_date_active;
    END IF;

    IF l_PRICE_LIST_LINE_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.estim_accrual_rate := p_old_PRICE_LIST_LINE_rec.estim_accrual_rate;
    END IF;

    IF l_PRICE_LIST_LINE_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.generate_using_formula_id := p_old_PRICE_LIST_LINE_rec.generate_using_formula_id;
    END IF;


    IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.inventory_item_id := p_old_PRICE_LIST_LINE_rec.inventory_item_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_updated_by := p_old_PRICE_LIST_LINE_rec.last_updated_by;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.last_update_date := p_old_PRICE_LIST_LINE_rec.last_update_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_update_login := p_old_PRICE_LIST_LINE_rec.last_update_login;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_header_id := p_old_PRICE_LIST_LINE_rec.list_header_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_line_id := p_old_PRICE_LIST_LINE_rec.list_line_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_no = FND_API.G_MISS_CHAR THEN -- bug 4751658, 4199398
        l_PRICE_LIST_LINE_rec.list_line_no := p_old_PRICE_LIST_LINE_rec.list_line_no;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.list_line_type_code := p_old_PRICE_LIST_LINE_rec.list_line_type_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_price := p_old_PRICE_LIST_LINE_rec.list_price;
    END IF;

    IF l_PRICE_LIST_LINE_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := p_old_PRICE_LIST_LINE_rec.from_rltd_modifier_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.rltd_modifier_group_no = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := p_old_PRICE_LIST_LINE_rec.rltd_modifier_group_no;
    END IF;

    IF l_PRICE_LIST_LINE_rec.product_precedence = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.product_precedence := p_old_PRICE_LIST_LINE_rec.product_precedence;
    END IF;

    IF l_PRICE_LIST_LINE_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.modifier_level_code := p_old_PRICE_LIST_LINE_rec.modifier_level_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.number_effective_periods = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.number_effective_periods := p_old_PRICE_LIST_LINE_rec.number_effective_periods;
    END IF;

    IF l_PRICE_LIST_LINE_rec.operand = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.operand := p_old_PRICE_LIST_LINE_rec.operand;
    END IF;

    IF l_PRICE_LIST_LINE_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.organization_id := p_old_PRICE_LIST_LINE_rec.organization_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.override_flag := p_old_PRICE_LIST_LINE_rec.override_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.percent_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.percent_price := p_old_PRICE_LIST_LINE_rec.percent_price;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.price_break_type_code := p_old_PRICE_LIST_LINE_rec.price_break_type_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_by_formula_id := p_old_PRICE_LIST_LINE_rec.price_by_formula_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.primary_uom_flag := p_old_PRICE_LIST_LINE_rec.primary_uom_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.print_on_invoice_flag := p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_application_id := p_old_PRICE_LIST_LINE_rec.program_application_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_id := p_old_PRICE_LIST_LINE_rec.program_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.program_update_date := p_old_PRICE_LIST_LINE_rec.program_update_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code;
    END IF;

    -- block pricing
    IF l_PRICE_LIST_LINE_rec.recurring_value = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.recurring_value := p_old_PRICE_LIST_LINE_rec.recurring_value;
    END IF;

    IF l_PRICE_LIST_LINE_rec.related_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.related_item_id := p_old_PRICE_LIST_LINE_rec.related_item_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.relationship_type_id := p_old_PRICE_LIST_LINE_rec.relationship_type_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.reprice_flag := p_old_PRICE_LIST_LINE_rec.reprice_flag;
    END IF;

    IF l_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.request_id := p_old_PRICE_LIST_LINE_rec.request_id;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision := p_old_PRICE_LIST_LINE_rec.revision;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.revision_date := p_old_PRICE_LIST_LINE_rec.revision_date;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision_reason_code := p_old_PRICE_LIST_LINE_rec.revision_reason_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.start_date_active := p_old_PRICE_LIST_LINE_rec.start_date_active;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_attribute := p_old_PRICE_LIST_LINE_rec.substitution_attribute;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_context := p_old_PRICE_LIST_LINE_rec.substitution_context;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_value = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_value := p_old_PRICE_LIST_LINE_rec.substitution_value;
    END IF;

    IF l_PRICE_LIST_LINE_rec.qualification_ind = FND_API.G_MISS_NUM THEN
       l_PRICE_LIST_LINE_rec.qualification_ind := p_old_PRICE_LIST_LINE_rec.qualification_ind;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_code = FND_API.G_MISS_CHAR THEN
       l_PRICE_LIST_LINE_rec.break_uom_code := p_old_PRICE_LIST_LINE_rec.break_uom_code;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_context = FND_API.G_MISS_CHAR THEN
       l_PRICE_LIST_LINE_rec.break_uom_context := p_old_PRICE_LIST_LINE_rec.break_uom_context;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_attribute = FND_API.G_MISS_CHAR THEN
       l_PRICE_LIST_LINE_rec.break_uom_attribute := p_old_PRICE_LIST_LINE_rec.break_uom_attribute;
    END IF;

    IF l_PRICE_LIST_LINE_rec.continuous_price_break_flag = FND_API.G_MISS_CHAR THEN
       l_PRICE_LIST_LINE_rec.continuous_price_break_flag := p_old_PRICE_LIST_LINE_rec.continuous_price_break_flag;
    END IF;

    --bug 9114132
    IF l_PRICE_LIST_LINE_rec.customer_item_id = FND_API.G_MISS_NUM THEN
       l_PRICE_LIST_LINE_rec.customer_item_id := p_old_PRICE_LIST_LINE_rec.customer_item_id;
    END IF;

    RETURN l_PRICE_LIST_LINE_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type := p_PRICE_LIST_LINE_rec;
BEGIN

    IF l_PRICE_LIST_LINE_rec.accrual_qty = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.accrual_qty := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.accrual_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.accrual_uom_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.arithmetic_operator := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute1 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute10 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute11 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute12 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute13 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute14 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute15 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute2 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute3 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute4 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute5 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute6 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute7 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute8 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.attribute9 := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.automatic_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.base_qty = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.base_qty := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.base_uom_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.comments = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.comments := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.context := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.created_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.created_by := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.creation_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.effective_period_uom := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.end_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.estim_accrual_rate := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.generate_using_formula_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.inventory_item_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_updated_by := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.last_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.last_update_login := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_header_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_line_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_no = FND_API.G_MISS_CHAR THEN -- bug 4751658, 4199398
        l_PRICE_LIST_LINE_rec.list_line_no := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.list_line_type_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.list_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.list_price := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.rltd_modifier_group_no = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.product_precedence = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.product_precedence := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.modifier_level_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.number_effective_periods = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.number_effective_periods := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.operand = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.operand := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.organization_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.override_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.percent_price = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.percent_price := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.price_break_type_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.price_by_formula_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.primary_uom_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.print_on_invoice_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_application_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.program_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.program_update_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := NULL;
    END IF;

    -- block pricing
    IF l_PRICE_LIST_LINE_rec.recurring_value = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.recurring_value := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.related_item_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.related_item_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.relationship_type_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.reprice_flag := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.request_id = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.request_id := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.revision_date := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.revision_reason_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_PRICE_LIST_LINE_rec.start_date_active := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_attribute := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_context := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.substitution_value = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.substitution_value := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.qualification_ind = FND_API.G_MISS_NUM THEN
        l_PRICE_LIST_LINE_rec.qualification_ind := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_code = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.break_uom_code := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_context = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.break_uom_context := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.break_uom_attribute = FND_API.G_MISS_CHAR THEN
        l_PRICE_LIST_LINE_rec.break_uom_attribute := NULL;
    END IF;

    IF l_PRICE_LIST_LINE_rec.continuous_price_break_flag = FND_API.G_MISS_CHAR THEN
       l_PRICE_LIST_LINE_rec.continuous_price_break_flag := NULL;
    END IF;

    RETURN l_PRICE_LIST_LINE_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

-- Added for Enhancement 1732601

FUNCTION Round_List_Price(p_price_list_header_id IN NUMBER)
RETURN NUMBER
IS
l_rounding_factor       NUMBER;

BEGIN
    BEGIN
      select rounding_factor
      into   l_rounding_factor
      from   qp_list_headers_b
      where  list_header_id =p_price_list_header_id;
    EXCEPTION
         WHEN OTHERS THEN
           l_rounding_factor := -2;
    END;
    Return l_rounding_factor;
END Round_List_Price;

PROCEDURE Update_Row
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_operand               NUMBER;
l_check_active_flag     VARCHAR2(1); /* Proration */
l_active_flag           VARCHAR2(1); /* Proration */
BEGIN
    /* Added for Enhancement 1732601 */
   IF fnd_profile.value('QP_PRICE_ROUNDING') IS NOT NULL THEN
   	 l_operand := round(p_PRICE_LIST_LINE_rec.operand,-1*Round_List_Price(p_PRICE_LIST_LINE_rec.list_header_id));
   ELSE
  	 l_operand := p_PRICE_LIST_LINE_rec.operand;
   END IF;

   /* Proration Start */
   BEGIN
       SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_PRICE_LIST_LINE_rec.list_header_id;
   EXCEPTION
   	WHEN OTHERS THEN
	NULL;
   END;
   /* Proration End */

    UPDATE  QP_LIST_LINES
    SET     ACCRUAL_QTY                    = p_PRICE_LIST_LINE_rec.accrual_qty
    ,       ACCRUAL_UOM_CODE               = p_PRICE_LIST_LINE_rec.accrual_uom_code
    ,       ARITHMETIC_OPERATOR            = p_PRICE_LIST_LINE_rec.arithmetic_operator
    ,       ATTRIBUTE1                     = p_PRICE_LIST_LINE_rec.attribute1
    ,       ATTRIBUTE10                    = p_PRICE_LIST_LINE_rec.attribute10
    ,       ATTRIBUTE11                    = p_PRICE_LIST_LINE_rec.attribute11
    ,       ATTRIBUTE12                    = p_PRICE_LIST_LINE_rec.attribute12
    ,       ATTRIBUTE13                    = p_PRICE_LIST_LINE_rec.attribute13
    ,       ATTRIBUTE14                    = p_PRICE_LIST_LINE_rec.attribute14
    ,       ATTRIBUTE15                    = p_PRICE_LIST_LINE_rec.attribute15
    ,       ATTRIBUTE2                     = p_PRICE_LIST_LINE_rec.attribute2
    ,       ATTRIBUTE3                     = p_PRICE_LIST_LINE_rec.attribute3
    ,       ATTRIBUTE4                     = p_PRICE_LIST_LINE_rec.attribute4
    ,       ATTRIBUTE5                     = p_PRICE_LIST_LINE_rec.attribute5
    ,       ATTRIBUTE6                     = p_PRICE_LIST_LINE_rec.attribute6
    ,       ATTRIBUTE7                     = p_PRICE_LIST_LINE_rec.attribute7
    ,       ATTRIBUTE8                     = p_PRICE_LIST_LINE_rec.attribute8
    ,       ATTRIBUTE9                     = p_PRICE_LIST_LINE_rec.attribute9
    ,       AUTOMATIC_FLAG                 = p_PRICE_LIST_LINE_rec.automatic_flag
    ,       BASE_QTY                       = p_PRICE_LIST_LINE_rec.base_qty
    ,       BASE_UOM_CODE                  = p_PRICE_LIST_LINE_rec.base_uom_code
    ,       COMMENTS                       = p_PRICE_LIST_LINE_rec.comments
    ,       CONTEXT                        = p_PRICE_LIST_LINE_rec.context
    ,       CREATED_BY                     = p_PRICE_LIST_LINE_rec.created_by
    ,       CREATION_DATE                  = p_PRICE_LIST_LINE_rec.creation_date
    ,       EFFECTIVE_PERIOD_UOM           = p_PRICE_LIST_LINE_rec.effective_period_uom
    ,       END_DATE_ACTIVE                = trunc(p_PRICE_LIST_LINE_rec.end_date_active)
    ,       ESTIM_ACCRUAL_RATE             = p_PRICE_LIST_LINE_rec.estim_accrual_rate
    ,       GENERATE_USING_FORMULA_ID      = p_PRICE_LIST_LINE_rec.generate_using_formula_id
    ,       INVENTORY_ITEM_ID              = p_PRICE_LIST_LINE_rec.inventory_item_id
    ,       LAST_UPDATED_BY                = p_PRICE_LIST_LINE_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_PRICE_LIST_LINE_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_PRICE_LIST_LINE_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_PRICE_LIST_LINE_rec.list_header_id
    ,       LIST_LINE_ID                   = p_PRICE_LIST_LINE_rec.list_line_id
    ,       LIST_LINE_NO                   = p_PRICE_LIST_LINE_rec.list_line_no
    ,       LIST_LINE_TYPE_CODE            = p_PRICE_LIST_LINE_rec.list_line_type_code
    ,       LIST_PRICE                     = p_PRICE_LIST_LINE_rec.list_price
    ,       PRODUCT_PRECEDENCE             = p_PRICE_LIST_LINE_rec.product_precedence
    ,       MODIFIER_LEVEL_CODE            = p_PRICE_LIST_LINE_rec.modifier_level_code
    ,       NUMBER_EFFECTIVE_PERIODS       = p_PRICE_LIST_LINE_rec.number_effective_periods
    --,       OPERAND                        = p_PRICE_LIST_LINE_rec.operand
    ,       OPERAND                        = l_operand  					--Modified for Enhancement 1732601
    ,       ORGANIZATION_ID                = p_PRICE_LIST_LINE_rec.organization_id
    ,       OVERRIDE_FLAG                  = p_PRICE_LIST_LINE_rec.override_flag
    ,       PERCENT_PRICE                  = p_PRICE_LIST_LINE_rec.percent_price
    ,       PRICE_BREAK_TYPE_CODE          = p_PRICE_LIST_LINE_rec.price_break_type_code
    ,       PRICE_BY_FORMULA_ID            = p_PRICE_LIST_LINE_rec.price_by_formula_id
    ,       PRIMARY_UOM_FLAG               = p_PRICE_LIST_LINE_rec.primary_uom_flag
    ,       PRINT_ON_INVOICE_FLAG          = p_PRICE_LIST_LINE_rec.print_on_invoice_flag
    ,       PROGRAM_APPLICATION_ID         = p_PRICE_LIST_LINE_rec.program_application_id
    ,       PROGRAM_ID                     = p_PRICE_LIST_LINE_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_PRICE_LIST_LINE_rec.program_update_date
    ,       REBATE_TRANSACTION_TYPE_CODE   = p_PRICE_LIST_LINE_rec.rebate_trxn_type_code
    ,       RELATED_ITEM_ID                = p_PRICE_LIST_LINE_rec.related_item_id
    ,       RELATIONSHIP_TYPE_ID           = p_PRICE_LIST_LINE_rec.relationship_type_id
    ,       REPRICE_FLAG                   = p_PRICE_LIST_LINE_rec.reprice_flag
    ,       REQUEST_ID                     = p_PRICE_LIST_LINE_rec.request_id
    ,       REVISION                       = p_PRICE_LIST_LINE_rec.revision
    ,       REVISION_DATE                  = trunc(p_PRICE_LIST_LINE_rec.revision_date)
    ,       REVISION_REASON_CODE           = p_PRICE_LIST_LINE_rec.revision_reason_code
    ,       START_DATE_ACTIVE              = trunc(p_PRICE_LIST_LINE_rec.start_date_active)
    ,       SUBSTITUTION_ATTRIBUTE         = p_PRICE_LIST_LINE_rec.substitution_attribute
    ,       SUBSTITUTION_CONTEXT           = p_PRICE_LIST_LINE_rec.substitution_context
    ,       SUBSTITUTION_VALUE             = p_PRICE_LIST_LINE_rec.substitution_value
    ,       PRICING_GROUP_SEQUENCE         = 0
    ,       PRICING_PHASE_ID               = 1
    ,       INCOMPATIBILITY_GRP_CODE       = 'EXCL'
    ,       QUALIFICATION_IND              = p_PRICE_LIST_LINE_rec.qualification_ind
    ,       RECURRING_VALUE                = p_PRICE_LIST_LINE_rec.recurring_value -- block pricing
    ,       CUSTOMER_ITEM_ID               = p_PRICE_LIST_LINE_rec.customer_item_id
    ,       BREAK_UOM_CODE                 = p_PRICE_LIST_LINE_rec.break_uom_code -- OKS proration
    ,       BREAK_UOM_CONTEXT              = p_PRICE_LIST_LINE_rec.break_uom_context -- OKS
    ,       BREAK_UOM_ATTRIBUTE            = p_PRICE_LIST_LINE_rec.break_uom_attribute -- OKS proration
    ,       CONTINUOUS_PRICE_BREAK_FLAG        = p_PRICE_LIST_LINE_rec.continuous_price_break_flag
    										-- Continuous price breaks
    WHERE   LIST_LINE_ID = p_PRICE_LIST_LINE_rec.list_line_id
    ;

   /* Proration Start */
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(p_PRICE_LIST_LINE_rec.break_uom_context IS NOT NULL) AND
   (p_PRICE_LIST_LINE_rec.break_uom_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICE_LIST_LINE_rec.break_uom_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
       AND    b.prc_context_code=p_PRICE_LIST_LINE_rec.break_uom_context);

 END IF;
END IF;
   /* Proration End */

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_return_status         varchar2(30);
l_operand		NUMBER;
l_check_active_flag     VARCHAR2(1); /* Proration */
l_active_flag           VARCHAR2(1); /* Proration */

BEGIN

    /* Added for Enhancement 1732601 */
   IF fnd_profile.value('QP_PRICE_ROUNDING') IS NOT NULL THEN
         l_operand := round(p_PRICE_LIST_LINE_rec.operand,-1*Round_List_Price(p_PRICE_LIST_LINE_rec.list_header_id));
   ELSE
         l_operand := p_PRICE_LIST_LINE_rec.operand;
   END IF;

   /* pricing group sequence = 0, pricing_phase_id = 1 - list line price */

   /* Proration Start */
   begin
       SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_PRICE_LIST_LINE_rec.list_header_id;
   exception
   when others then
   	null;
   end;

   /* Proration End */

    INSERT  INTO QP_LIST_LINES
    (       ACCRUAL_QTY
    ,       ACCRUAL_UOM_CODE
    ,       ARITHMETIC_OPERATOR
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
    ,       AUTOMATIC_FLAG
    ,       BASE_QTY
    ,       BASE_UOM_CODE
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EFFECTIVE_PERIOD_UOM
    ,       END_DATE_ACTIVE
    ,       ESTIM_ACCRUAL_RATE
    ,       GENERATE_USING_FORMULA_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_NO
    ,       LIST_LINE_TYPE_CODE
    ,       LIST_PRICE
    ,       PRODUCT_PRECEDENCE
    ,       MODIFIER_LEVEL_CODE
    ,       NUMBER_EFFECTIVE_PERIODS
    ,       OPERAND
    ,       ORGANIZATION_ID
    ,       OVERRIDE_FLAG
    ,       PERCENT_PRICE
    ,       PRICE_BREAK_TYPE_CODE
    ,       PRICE_BY_FORMULA_ID
    ,       PRIMARY_UOM_FLAG
    ,       PRINT_ON_INVOICE_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REBATE_TRANSACTION_TYPE_CODE
    ,       RELATED_ITEM_ID
    ,       RELATIONSHIP_TYPE_ID
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       SUBSTITUTION_ATTRIBUTE
    ,       SUBSTITUTION_CONTEXT
    ,       SUBSTITUTION_VALUE
    ,       PRICING_GROUP_SEQUENCE
    ,       PRICING_PHASE_ID
    ,       INCOMPATIBILITY_GRP_CODE
    ,       QUALIFICATION_IND
    ,       RECURRING_VALUE -- block pricing
    ,       CUSTOMER_ITEM_ID
    ,       BREAK_UOM_CODE  -- OKS proration
    ,       BREAK_UOM_CONTEXT -- OKS proration
    ,       BREAK_UOM_ATTRIBUTE -- OKS proration
    ,       CONTINUOUS_PRICE_BREAK_FLAG -- Continuous price breaks
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,orig_sys_line_ref
  ,ORIG_SYS_HEADER_REF
    )
    VALUES
    (       p_PRICE_LIST_LINE_rec.accrual_qty
    ,       p_PRICE_LIST_LINE_rec.accrual_uom_code
    ,       p_PRICE_LIST_LINE_rec.arithmetic_operator
    ,       p_PRICE_LIST_LINE_rec.attribute1
    ,       p_PRICE_LIST_LINE_rec.attribute10
    ,       p_PRICE_LIST_LINE_rec.attribute11
    ,       p_PRICE_LIST_LINE_rec.attribute12
    ,       p_PRICE_LIST_LINE_rec.attribute13
    ,       p_PRICE_LIST_LINE_rec.attribute14
    ,       p_PRICE_LIST_LINE_rec.attribute15
    ,       p_PRICE_LIST_LINE_rec.attribute2
    ,       p_PRICE_LIST_LINE_rec.attribute3
    ,       p_PRICE_LIST_LINE_rec.attribute4
    ,       p_PRICE_LIST_LINE_rec.attribute5
    ,       p_PRICE_LIST_LINE_rec.attribute6
    ,       p_PRICE_LIST_LINE_rec.attribute7
    ,       p_PRICE_LIST_LINE_rec.attribute8
    ,       p_PRICE_LIST_LINE_rec.attribute9
    ,       p_PRICE_LIST_LINE_rec.automatic_flag
    ,       p_PRICE_LIST_LINE_rec.base_qty
    ,       p_PRICE_LIST_LINE_rec.base_uom_code
    ,       p_PRICE_LIST_LINE_rec.comments
    ,       p_PRICE_LIST_LINE_rec.context
    ,       p_PRICE_LIST_LINE_rec.created_by
    ,       p_PRICE_LIST_LINE_rec.creation_date
    ,       p_PRICE_LIST_LINE_rec.effective_period_uom
    ,       trunc(p_PRICE_LIST_LINE_rec.end_date_active)
    ,       p_PRICE_LIST_LINE_rec.estim_accrual_rate
    ,       p_PRICE_LIST_LINE_rec.generate_using_formula_id
    ,       p_PRICE_LIST_LINE_rec.inventory_item_id
    ,       p_PRICE_LIST_LINE_rec.last_updated_by
    ,       p_PRICE_LIST_LINE_rec.last_update_date
    ,       p_PRICE_LIST_LINE_rec.last_update_login
    ,       p_PRICE_LIST_LINE_rec.list_header_id
    ,       p_PRICE_LIST_LINE_rec.list_line_id
    ,       p_PRICE_LIST_LINE_rec.list_line_no
    ,       p_PRICE_LIST_LINE_rec.list_line_type_code
    ,       p_PRICE_LIST_LINE_rec.list_price
    ,       p_PRICE_LIST_LINE_rec.product_precedence
    ,       p_PRICE_LIST_LINE_rec.modifier_level_code
    ,       p_PRICE_LIST_LINE_rec.number_effective_periods
 --   ,       p_PRICE_LIST_LINE_rec.operand
    ,       l_operand                                             --Modified for 1732601
    ,       p_PRICE_LIST_LINE_rec.organization_id
    ,       p_PRICE_LIST_LINE_rec.override_flag
    ,       p_PRICE_LIST_LINE_rec.percent_price
    ,       p_PRICE_LIST_LINE_rec.price_break_type_code
    ,       p_PRICE_LIST_LINE_rec.price_by_formula_id
    ,       p_PRICE_LIST_LINE_rec.primary_uom_flag
    ,       p_PRICE_LIST_LINE_rec.print_on_invoice_flag
    ,       p_PRICE_LIST_LINE_rec.program_application_id
    ,       p_PRICE_LIST_LINE_rec.program_id
    ,       p_PRICE_LIST_LINE_rec.program_update_date
    ,       p_PRICE_LIST_LINE_rec.rebate_trxn_type_code
    ,       p_PRICE_LIST_LINE_rec.related_item_id
    ,       p_PRICE_LIST_LINE_rec.relationship_type_id
    ,       p_PRICE_LIST_LINE_rec.reprice_flag
    ,       p_PRICE_LIST_LINE_rec.request_id
    ,       p_PRICE_LIST_LINE_rec.revision
    ,       trunc(p_PRICE_LIST_LINE_rec.revision_date)
    ,       p_PRICE_LIST_LINE_rec.revision_reason_code
    ,       trunc(p_PRICE_LIST_LINE_rec.start_date_active)
    ,       p_PRICE_LIST_LINE_rec.substitution_attribute
    ,       p_PRICE_LIST_LINE_rec.substitution_context
    ,       p_PRICE_LIST_LINE_rec.substitution_value
    ,       0
    ,       1
    ,       'EXCL'
    ,       p_PRICE_LIST_LINE_rec.qualification_ind --Euro Bug 2138996
    ,       p_PRICE_LIST_LINE_rec.recurring_value -- block pricing
    ,       p_PRICE_LIST_LINE_rec.customer_item_id
    ,       p_PRICE_LIST_LINE_rec.break_uom_code -- OKS proration
    ,       p_PRICE_LIST_LINE_rec.break_uom_context -- OKS
    ,       p_PRICE_LIST_LINE_rec.break_uom_attribute -- OKS proration
    ,       p_PRICE_LIST_LINE_rec.continuous_price_break_flag -- Continuous price breaks
  --ENH Upgrade BOAPI for orig_sys...ref RAVI
  ,to_char(p_PRICE_LIST_LINE_rec.list_line_id)
  ,(select h.ORIG_SYSTEM_HEADER_REF from qp_list_headers_b h where h.list_header_id=p_PRICE_LIST_LINE_rec.list_header_id)
    );
      /* Added delayed request by dhgupta for bug 2018275 */

         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
                 p_entity_id  => p_PRICE_LIST_LINE_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
                 p_requesting_entity_id => p_PRICE_LIST_LINE_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

   /* Proration Start */
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(p_PRICE_LIST_LINE_rec.break_uom_context IS NOT NULL) AND
   (p_PRICE_LIST_LINE_rec.break_uom_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_PRICE_LIST_LINE_rec.break_uom_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
       AND    b.prc_context_code=p_PRICE_LIST_LINE_rec.break_uom_context);

 END IF;
END IF;
   /* Proration End */

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure delete_Row

PROCEDURE Delete_Row
(   p_list_line_id                  IN  NUMBER
)
IS
L_LINE_TYPE_CODE VARCHAR2(30) := NULL;

cursor get_rltd_mods(line_id in number) is
select from_rltd_modifier_id, to_rltd_modifier_id
from qp_rltd_modifiers
where from_rltd_modifier_id = line_id;


BEGIN

   SELECT LIST_LINE_TYPE_CODE
   INTO L_LINE_TYPE_CODE
   FROM QP_LIST_LINES
   WHERE LIST_LINE_ID = p_list_line_id;

   /* delete all the related modifier lines if the line is a PBH,
     else delete all references of this line in qp_rltd_modifiers */

   IF L_LINE_TYPE_CODE = 'PBH' THEN

     for get_rltd_mods_rec in get_rltd_mods(p_list_line_id) loop

        QP_PRICE_LIST_LINE_UTIL.DELETE_ROW(get_rltd_mods_rec.to_rltd_modifier_id);

     end loop;

     DELETE FROM QP_RLTD_MODIFIERS
     WHERE FROM_RLTD_MODIFIER_ID = p_list_line_id;

  ELSE

      DELETE FROM QP_RLTD_MODIFIERS
      WHERE TO_RLTD_MODIFIER_ID = p_list_line_id;

  END IF;  /* done with related modifier lines */


 /* delete all the pricing attributes */

    DELETE FROM QP_PRICING_ATTRIBUTES
    WHERE LIST_LINE_ID = p_list_line_id;   /* done with pricing attributes */


    DELETE  FROM QP_LIST_LINES
    WHERE   LIST_LINE_ID = p_list_line_id
    ;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_list_line_id                  IN  NUMBER
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type
IS
BEGIN

    RETURN Query_Rows
        (   p_list_line_id                => p_list_line_id
        )(1);

END Query_Row;

--  Function Query_Rows

--

FUNCTION Query_Rows
(   p_list_line_id                  IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN QP_Price_List_PUB.Price_List_Line_Tbl_Type
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;

CURSOR l_PRICE_LIST_LINE_csr IS
    SELECT  ACCRUAL_QTY
    ,       ACCRUAL_UOM_CODE
    ,       ARITHMETIC_OPERATOR
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
    ,       AUTOMATIC_FLAG
    ,       BASE_QTY
    ,       BASE_UOM_CODE
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EFFECTIVE_PERIOD_UOM
    ,       END_DATE_ACTIVE
    ,       ESTIM_ACCRUAL_RATE
    ,       GENERATE_USING_FORMULA_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_NO
    ,       LIST_LINE_TYPE_CODE
    ,       LIST_PRICE
    ,       PRODUCT_PRECEDENCE
    ,       MODIFIER_LEVEL_CODE
    ,       NUMBER_EFFECTIVE_PERIODS
    ,       OPERAND
    ,       ORGANIZATION_ID
    ,       OVERRIDE_FLAG
    ,       PERCENT_PRICE
    ,       PRICE_BREAK_TYPE_CODE
    ,       PRICE_BY_FORMULA_ID
    ,       PRIMARY_UOM_FLAG
    ,       PRINT_ON_INVOICE_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REBATE_TRANSACTION_TYPE_CODE
    ,       RELATED_ITEM_ID
    ,       RELATIONSHIP_TYPE_ID
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       SUBSTITUTION_ATTRIBUTE
    ,       SUBSTITUTION_CONTEXT
    ,       SUBSTITUTION_VALUE
    ,       QUALIFICATION_IND
    ,       RECURRING_VALUE -- block pricing
    ,       CUSTOMER_ITEM_ID
    ,       BREAK_UOM_CODE
    ,       BREAK_UOM_CONTEXT
    ,       BREAK_UOM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG -- Continuous price breaks
    FROM    QP_LIST_LINES
    WHERE  LIST_LINE_ID = p_list_line_id;

/* Peformance changes for 2422019 */
/*
    )
    OR (    LIST_HEADER_ID = p_list_header_id
    );
*/

CURSOR l_PRICE_LIST_LINE_hdr_csr IS
    SELECT  ACCRUAL_QTY
    ,       ACCRUAL_UOM_CODE
    ,       ARITHMETIC_OPERATOR
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
    ,       AUTOMATIC_FLAG
    ,       BASE_QTY
    ,       BASE_UOM_CODE
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EFFECTIVE_PERIOD_UOM
    ,       END_DATE_ACTIVE
    ,       ESTIM_ACCRUAL_RATE
    ,       GENERATE_USING_FORMULA_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_NO
    ,       LIST_LINE_TYPE_CODE
    ,       LIST_PRICE
    ,       PRODUCT_PRECEDENCE
    ,       MODIFIER_LEVEL_CODE
    ,       NUMBER_EFFECTIVE_PERIODS
    ,       OPERAND
    ,       ORGANIZATION_ID
    ,       OVERRIDE_FLAG
    ,       PERCENT_PRICE
    ,       PRICE_BREAK_TYPE_CODE
    ,       PRICE_BY_FORMULA_ID
    ,       PRIMARY_UOM_FLAG
    ,       PRINT_ON_INVOICE_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REBATE_TRANSACTION_TYPE_CODE
    ,       RELATED_ITEM_ID
    ,       RELATIONSHIP_TYPE_ID
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       SUBSTITUTION_ATTRIBUTE
    ,       SUBSTITUTION_CONTEXT
    ,       SUBSTITUTION_VALUE
    ,       QUALIFICATION_IND
    ,       RECURRING_VALUE -- block pricing
    ,       CUSTOMER_ITEM_ID
    ,       BREAK_UOM_CODE
    ,       BREAK_UOM_CONTEXT
    ,       BREAK_UOM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG -- Continuous price breaks
    FROM    QP_LIST_LINES
    WHERE   LIST_HEADER_ID = p_list_header_id;

BEGIN

    IF
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_list_header_id IS NOT NULL
     AND
     p_list_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                oe_msg_pub.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: list_line_id = '|| p_list_line_id || ', list_header_id = '|| p_list_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


    --  Loop over fetched records
IF (p_list_line_id IS NOT NULL) AND (p_list_line_id <> FND_API.G_MISS_NUM) THEN  --Added for performance bug2422019
    FOR l_implicit_rec IN l_PRICE_LIST_LINE_csr LOOP

        l_PRICE_LIST_LINE_rec.accrual_qty := l_implicit_rec.ACCRUAL_QTY;
        l_PRICE_LIST_LINE_rec.accrual_uom_code := l_implicit_rec.ACCRUAL_UOM_CODE;
        l_PRICE_LIST_LINE_rec.arithmetic_operator := l_implicit_rec.ARITHMETIC_OPERATOR;
        l_PRICE_LIST_LINE_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_PRICE_LIST_LINE_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_PRICE_LIST_LINE_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_PRICE_LIST_LINE_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_PRICE_LIST_LINE_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_PRICE_LIST_LINE_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_PRICE_LIST_LINE_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_PRICE_LIST_LINE_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_PRICE_LIST_LINE_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_PRICE_LIST_LINE_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_PRICE_LIST_LINE_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_PRICE_LIST_LINE_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_PRICE_LIST_LINE_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_PRICE_LIST_LINE_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_PRICE_LIST_LINE_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_PRICE_LIST_LINE_rec.automatic_flag := l_implicit_rec.AUTOMATIC_FLAG;
        l_PRICE_LIST_LINE_rec.base_qty := l_implicit_rec.BASE_QTY;
        l_PRICE_LIST_LINE_rec.base_uom_code := l_implicit_rec.BASE_UOM_CODE;
        l_PRICE_LIST_LINE_rec.comments := l_implicit_rec.COMMENTS;
        l_PRICE_LIST_LINE_rec.context  := l_implicit_rec.CONTEXT;
        l_PRICE_LIST_LINE_rec.created_by := l_implicit_rec.CREATED_BY;
        l_PRICE_LIST_LINE_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_PRICE_LIST_LINE_rec.effective_period_uom := l_implicit_rec.EFFECTIVE_PERIOD_UOM;
        l_PRICE_LIST_LINE_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.estim_accrual_rate := l_implicit_rec.ESTIM_ACCRUAL_RATE;
        l_PRICE_LIST_LINE_rec.generate_using_formula_id := l_implicit_rec.GENERATE_USING_FORMULA_ID;
        l_PRICE_LIST_LINE_rec.inventory_item_id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_PRICE_LIST_LINE_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICE_LIST_LINE_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICE_LIST_LINE_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_PRICE_LIST_LINE_rec.list_line_id := l_implicit_rec.LIST_LINE_ID;
        l_PRICE_LIST_LINE_rec.list_line_no := l_implicit_rec.LIST_LINE_NO;
        l_PRICE_LIST_LINE_rec.list_line_type_code := l_implicit_rec.LIST_LINE_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.list_price := l_implicit_rec.LIST_PRICE;
        l_PRICE_LIST_LINE_rec.product_precedence := l_implicit_rec.PRODUCT_PRECEDENCE;
        l_PRICE_LIST_LINE_rec.modifier_level_code := l_implicit_rec.MODIFIER_LEVEL_CODE;
        l_PRICE_LIST_LINE_rec.number_effective_periods := l_implicit_rec.NUMBER_EFFECTIVE_PERIODS;
        l_PRICE_LIST_LINE_rec.operand  := l_implicit_rec.OPERAND;
        l_PRICE_LIST_LINE_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_PRICE_LIST_LINE_rec.override_flag := l_implicit_rec.OVERRIDE_FLAG;
        l_PRICE_LIST_LINE_rec.percent_price := l_implicit_rec.PERCENT_PRICE;
        l_PRICE_LIST_LINE_rec.price_break_type_code := l_implicit_rec.PRICE_BREAK_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.price_by_formula_id := l_implicit_rec.PRICE_BY_FORMULA_ID;
        l_PRICE_LIST_LINE_rec.primary_uom_flag := l_implicit_rec.PRIMARY_UOM_FLAG;
        l_PRICE_LIST_LINE_rec.print_on_invoice_flag := l_implicit_rec.PRINT_ON_INVOICE_FLAG;
        l_PRICE_LIST_LINE_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICE_LIST_LINE_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_PRICE_LIST_LINE_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := l_implicit_rec.REBATE_TRANSACTION_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.related_item_id := l_implicit_rec.RELATED_ITEM_ID;
        l_PRICE_LIST_LINE_rec.relationship_type_id := l_implicit_rec.RELATIONSHIP_TYPE_ID;
        l_PRICE_LIST_LINE_rec.reprice_flag := l_implicit_rec.REPRICE_FLAG;
        l_PRICE_LIST_LINE_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_PRICE_LIST_LINE_rec.revision := l_implicit_rec.REVISION;
        l_PRICE_LIST_LINE_rec.revision_date := l_implicit_rec.REVISION_DATE;
        l_PRICE_LIST_LINE_rec.revision_reason_code := l_implicit_rec.REVISION_REASON_CODE;
        l_PRICE_LIST_LINE_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.substitution_attribute := l_implicit_rec.SUBSTITUTION_ATTRIBUTE;
        l_PRICE_LIST_LINE_rec.substitution_context := l_implicit_rec.SUBSTITUTION_CONTEXT;
        l_PRICE_LIST_LINE_rec.substitution_value := l_implicit_rec.SUBSTITUTION_VALUE;
        l_PRICE_LIST_LINE_rec.qualification_ind := l_implicit_rec.QUALIFICATION_IND;
        l_PRICE_LIST_LINE_rec.recurring_value := l_implicit_rec.RECURRING_VALUE; -- block pricing
	l_PRICE_LIST_LINE_rec.customer_item_id := l_implicit_rec.CUSTOMER_ITEM_ID;
        l_PRICE_LIST_LINE_rec.break_uom_code := l_implicit_rec.BREAK_UOM_CODE;
	l_PRICE_LIST_LINE_rec.break_uom_context := l_implicit_rec.BREAK_UOM_CONTEXT;
        l_PRICE_LIST_LINE_rec.break_uom_attribute := l_implicit_rec.BREAK_UOM_ATTRIBUTE; --OKS proration
        l_PRICE_LIST_LINE_rec.continuous_price_break_flag := l_implicit_rec.CONTINUOUS_PRICE_BREAK_FLAG;
										-- Continuous price breaks
  BEGIN
    SELECT  RLTD_MODIFIER_GRP_NO
    ,       RLTD_MODIFIER_GRP_TYPE
    ,       FROM_RLTD_MODIFIER_ID
    ,       TO_RLTD_MODIFIER_ID
    ,       RLTD_MODIFIER_ID
    INTO    l_PRICE_LIST_LINE_rec.rltd_modifier_group_no
    ,       l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type
    ,       l_PRICE_LIST_LINE_rec.from_rltd_modifier_id
    ,       l_PRICE_LIST_LINE_rec.to_rltd_modifier_id
    ,       l_PRICE_LIST_LINE_rec.rltd_modifier_id
    FROM    QP_RLTD_MODIFIERS
    WHERE   ( TO_RLTD_MODIFIER_ID = l_implicit_rec.LIST_LINE_ID );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := null;
      l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type := null;
      l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := null;
      l_PRICE_LIST_LINE_rec.to_rltd_modifier_id := null;
      l_PRICE_LIST_LINE_rec.rltd_modifier_id := null;
  END;

        l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_tbl.COUNT + 1) := l_PRICE_LIST_LINE_rec;

    END LOOP;

/* Added for performance bug2422019 */

ELSIF (p_list_header_id IS NOT NULL) AND (p_list_header_id <> FND_API.G_MISS_NUM) THEN
    FOR l_implicit_rec IN l_PRICE_LIST_LINE_hdr_csr LOOP

        l_PRICE_LIST_LINE_rec.accrual_qty := l_implicit_rec.ACCRUAL_QTY;
        l_PRICE_LIST_LINE_rec.accrual_uom_code := l_implicit_rec.ACCRUAL_UOM_CODE;
        l_PRICE_LIST_LINE_rec.arithmetic_operator := l_implicit_rec.ARITHMETIC_OPERATOR;
        l_PRICE_LIST_LINE_rec.attribute1 := l_implicit_rec.ATTRIBUTE1;
        l_PRICE_LIST_LINE_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_PRICE_LIST_LINE_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_PRICE_LIST_LINE_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_PRICE_LIST_LINE_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_PRICE_LIST_LINE_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_PRICE_LIST_LINE_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_PRICE_LIST_LINE_rec.attribute2 := l_implicit_rec.ATTRIBUTE2;
        l_PRICE_LIST_LINE_rec.attribute3 := l_implicit_rec.ATTRIBUTE3;
        l_PRICE_LIST_LINE_rec.attribute4 := l_implicit_rec.ATTRIBUTE4;
        l_PRICE_LIST_LINE_rec.attribute5 := l_implicit_rec.ATTRIBUTE5;
        l_PRICE_LIST_LINE_rec.attribute6 := l_implicit_rec.ATTRIBUTE6;
        l_PRICE_LIST_LINE_rec.attribute7 := l_implicit_rec.ATTRIBUTE7;
        l_PRICE_LIST_LINE_rec.attribute8 := l_implicit_rec.ATTRIBUTE8;
        l_PRICE_LIST_LINE_rec.attribute9 := l_implicit_rec.ATTRIBUTE9;
        l_PRICE_LIST_LINE_rec.automatic_flag := l_implicit_rec.AUTOMATIC_FLAG;
        l_PRICE_LIST_LINE_rec.base_qty := l_implicit_rec.BASE_QTY;
        l_PRICE_LIST_LINE_rec.base_uom_code := l_implicit_rec.BASE_UOM_CODE;
        l_PRICE_LIST_LINE_rec.comments := l_implicit_rec.COMMENTS;
        l_PRICE_LIST_LINE_rec.context  := l_implicit_rec.CONTEXT;
        l_PRICE_LIST_LINE_rec.created_by := l_implicit_rec.CREATED_BY;
        l_PRICE_LIST_LINE_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_PRICE_LIST_LINE_rec.effective_period_uom := l_implicit_rec.EFFECTIVE_PERIOD_UOM;
        l_PRICE_LIST_LINE_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.estim_accrual_rate := l_implicit_rec.ESTIM_ACCRUAL_RATE;
        l_PRICE_LIST_LINE_rec.generate_using_formula_id := l_implicit_rec.GENERATE_USING_FORMULA_ID;
        l_PRICE_LIST_LINE_rec.inventory_item_id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_PRICE_LIST_LINE_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICE_LIST_LINE_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICE_LIST_LINE_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_PRICE_LIST_LINE_rec.list_line_id := l_implicit_rec.LIST_LINE_ID;
        l_PRICE_LIST_LINE_rec.list_line_no := l_implicit_rec.LIST_LINE_NO;
        l_PRICE_LIST_LINE_rec.list_line_type_code := l_implicit_rec.LIST_LINE_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.list_price := l_implicit_rec.LIST_PRICE;
        l_PRICE_LIST_LINE_rec.product_precedence := l_implicit_rec.PRODUCT_PRECEDENCE;
        l_PRICE_LIST_LINE_rec.modifier_level_code := l_implicit_rec.MODIFIER_LEVEL_CODE;
        l_PRICE_LIST_LINE_rec.number_effective_periods := l_implicit_rec.NUMBER_EFFECTIVE_PERIODS;
        l_PRICE_LIST_LINE_rec.operand  := l_implicit_rec.OPERAND;
        l_PRICE_LIST_LINE_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_PRICE_LIST_LINE_rec.override_flag := l_implicit_rec.OVERRIDE_FLAG;
        l_PRICE_LIST_LINE_rec.percent_price := l_implicit_rec.PERCENT_PRICE;
        l_PRICE_LIST_LINE_rec.price_break_type_code := l_implicit_rec.PRICE_BREAK_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.price_by_formula_id := l_implicit_rec.PRICE_BY_FORMULA_ID;
        l_PRICE_LIST_LINE_rec.primary_uom_flag := l_implicit_rec.PRIMARY_UOM_FLAG;
        l_PRICE_LIST_LINE_rec.print_on_invoice_flag := l_implicit_rec.PRINT_ON_INVOICE_FLAG;
        l_PRICE_LIST_LINE_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICE_LIST_LINE_rec.program_id := l_implicit_rec.PROGRAM_ID;
        l_PRICE_LIST_LINE_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := l_implicit_rec.REBATE_TRANSACTION_TYPE_CODE;
        l_PRICE_LIST_LINE_rec.related_item_id := l_implicit_rec.RELATED_ITEM_ID;
        l_PRICE_LIST_LINE_rec.relationship_type_id := l_implicit_rec.RELATIONSHIP_TYPE_ID;
        l_PRICE_LIST_LINE_rec.reprice_flag := l_implicit_rec.REPRICE_FLAG;
        l_PRICE_LIST_LINE_rec.request_id := l_implicit_rec.REQUEST_ID;
        l_PRICE_LIST_LINE_rec.revision := l_implicit_rec.REVISION;
        l_PRICE_LIST_LINE_rec.revision_date := l_implicit_rec.REVISION_DATE;
        l_PRICE_LIST_LINE_rec.revision_reason_code := l_implicit_rec.REVISION_REASON_CODE;
        l_PRICE_LIST_LINE_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_PRICE_LIST_LINE_rec.substitution_attribute := l_implicit_rec.SUBSTITUTION_ATTRIBUTE;
        l_PRICE_LIST_LINE_rec.substitution_context := l_implicit_rec.SUBSTITUTION_CONTEXT;
        l_PRICE_LIST_LINE_rec.substitution_value := l_implicit_rec.SUBSTITUTION_VALUE;
        l_PRICE_LIST_LINE_rec.qualification_ind := l_implicit_rec.QUALIFICATION_IND;
        l_PRICE_LIST_LINE_rec.recurring_value := l_implicit_rec.RECURRING_VALUE; -- block pricing
	l_PRICE_LIST_LINE_rec.customer_item_id := l_implicit_rec.CUSTOMER_ITEM_ID;
        l_PRICE_LIST_LINE_rec.break_uom_code := l_implicit_rec.BREAK_UOM_CODE;
	l_PRICE_LIST_LINE_rec.break_uom_context := l_implicit_rec.BREAK_UOM_CONTEXT;
        l_PRICE_LIST_LINE_rec.break_uom_attribute := l_implicit_rec.BREAK_UOM_ATTRIBUTE; --OKS proration
        l_PRICE_LIST_LINE_rec.continuous_price_break_flag := l_implicit_rec.CONTINUOUS_PRICE_BREAK_FLAG;
										-- Continuous price breaks
  BEGIN
    SELECT  RLTD_MODIFIER_GRP_NO
    ,       RLTD_MODIFIER_GRP_TYPE
    ,       FROM_RLTD_MODIFIER_ID
    ,       TO_RLTD_MODIFIER_ID
    ,       RLTD_MODIFIER_ID
    INTO    l_PRICE_LIST_LINE_rec.rltd_modifier_group_no
    ,       l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type
    ,       l_PRICE_LIST_LINE_rec.from_rltd_modifier_id
    ,       l_PRICE_LIST_LINE_rec.to_rltd_modifier_id
    ,       l_PRICE_LIST_LINE_rec.rltd_modifier_id
    FROM    QP_RLTD_MODIFIERS
    WHERE   ( TO_RLTD_MODIFIER_ID = l_implicit_rec.LIST_LINE_ID );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := null;
      l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type := null;
      l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := null;
      l_PRICE_LIST_LINE_rec.to_rltd_modifier_id := null;
      l_PRICE_LIST_LINE_rec.rltd_modifier_id := null;
  END;

        l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_tbl.COUNT + 1) := l_PRICE_LIST_LINE_rec;

    END LOOP;

END IF;

    --  PK sent and no rows found

    IF
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (l_PRICE_LIST_LINE_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

    RETURN l_PRICE_LIST_LINE_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   x_PRICE_LIST_LINE_rec           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Rec_Type
)
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN


    QP_Price_List_Line_Util.Print_Price_List_line(p_PRICE_LIST_LINE_rec,
                                                   1);


    SELECT  ACCRUAL_QTY
    ,       ACCRUAL_UOM_CODE
    ,       ARITHMETIC_OPERATOR
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
    ,       AUTOMATIC_FLAG
    ,       BASE_QTY
    ,       BASE_UOM_CODE
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EFFECTIVE_PERIOD_UOM
    ,       END_DATE_ACTIVE
    ,       ESTIM_ACCRUAL_RATE
    ,       GENERATE_USING_FORMULA_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_TYPE_CODE
    ,       LIST_PRICE
    ,       PRODUCT_PRECEDENCE
    ,       MODIFIER_LEVEL_CODE
    ,       NUMBER_EFFECTIVE_PERIODS
    ,       OPERAND
    ,       ORGANIZATION_ID
    ,       OVERRIDE_FLAG
    ,       PERCENT_PRICE
    ,       PRICE_BREAK_TYPE_CODE
    ,       PRICE_BY_FORMULA_ID
    ,       PRIMARY_UOM_FLAG
    ,       PRINT_ON_INVOICE_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REBATE_TRANSACTION_TYPE_CODE
    ,       RECURRING_VALUE -- block pricing
    ,       RELATED_ITEM_ID
    ,       RELATIONSHIP_TYPE_ID
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       SUBSTITUTION_ATTRIBUTE
    ,       SUBSTITUTION_CONTEXT
    ,       SUBSTITUTION_VALUE
    ,       CUSTOMER_ITEM_ID
    ,       BREAK_UOM_CODE
    ,	    BREAK_UOM_CONTEXT
    ,       BREAK_UOM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG -- Continuous price breaks
    INTO    l_PRICE_LIST_LINE_rec.accrual_qty
    ,       l_PRICE_LIST_LINE_rec.accrual_uom_code
    ,       l_PRICE_LIST_LINE_rec.arithmetic_operator
    ,       l_PRICE_LIST_LINE_rec.attribute1
    ,       l_PRICE_LIST_LINE_rec.attribute10
    ,       l_PRICE_LIST_LINE_rec.attribute11
    ,       l_PRICE_LIST_LINE_rec.attribute12
    ,       l_PRICE_LIST_LINE_rec.attribute13
    ,       l_PRICE_LIST_LINE_rec.attribute14
    ,       l_PRICE_LIST_LINE_rec.attribute15
    ,       l_PRICE_LIST_LINE_rec.attribute2
    ,       l_PRICE_LIST_LINE_rec.attribute3
    ,       l_PRICE_LIST_LINE_rec.attribute4
    ,       l_PRICE_LIST_LINE_rec.attribute5
    ,       l_PRICE_LIST_LINE_rec.attribute6
    ,       l_PRICE_LIST_LINE_rec.attribute7
    ,       l_PRICE_LIST_LINE_rec.attribute8
    ,       l_PRICE_LIST_LINE_rec.attribute9
    ,       l_PRICE_LIST_LINE_rec.automatic_flag
    ,       l_PRICE_LIST_LINE_rec.base_qty
    ,       l_PRICE_LIST_LINE_rec.base_uom_code
    ,       l_PRICE_LIST_LINE_rec.comments
    ,       l_PRICE_LIST_LINE_rec.context
    ,       l_PRICE_LIST_LINE_rec.created_by
    ,       l_PRICE_LIST_LINE_rec.creation_date
    ,       l_PRICE_LIST_LINE_rec.effective_period_uom
    ,       l_PRICE_LIST_LINE_rec.end_date_active
    ,       l_PRICE_LIST_LINE_rec.estim_accrual_rate
    ,       l_PRICE_LIST_LINE_rec.generate_using_formula_id
    ,       l_PRICE_LIST_LINE_rec.inventory_item_id
    ,       l_PRICE_LIST_LINE_rec.last_updated_by
    ,       l_PRICE_LIST_LINE_rec.last_update_date
    ,       l_PRICE_LIST_LINE_rec.last_update_login
    ,       l_PRICE_LIST_LINE_rec.list_header_id
    ,       l_PRICE_LIST_LINE_rec.list_line_id
    ,       l_PRICE_LIST_LINE_rec.list_line_type_code
    ,       l_PRICE_LIST_LINE_rec.list_price
    ,       l_PRICE_LIST_LINE_rec.product_precedence
    ,       l_PRICE_LIST_LINE_rec.modifier_level_code
    ,       l_PRICE_LIST_LINE_rec.number_effective_periods
    ,       l_PRICE_LIST_LINE_rec.operand
    ,       l_PRICE_LIST_LINE_rec.organization_id
    ,       l_PRICE_LIST_LINE_rec.override_flag
    ,       l_PRICE_LIST_LINE_rec.percent_price
    ,       l_PRICE_LIST_LINE_rec.price_break_type_code
    ,       l_PRICE_LIST_LINE_rec.price_by_formula_id
    ,       l_PRICE_LIST_LINE_rec.primary_uom_flag
    ,       l_PRICE_LIST_LINE_rec.print_on_invoice_flag
    ,       l_PRICE_LIST_LINE_rec.program_application_id
    ,       l_PRICE_LIST_LINE_rec.program_id
    ,       l_PRICE_LIST_LINE_rec.program_update_date
    ,       l_PRICE_LIST_LINE_rec.rebate_trxn_type_code
    ,       l_PRICE_LIST_LINE_rec.recurring_value -- block pricing
    ,       l_PRICE_LIST_LINE_rec.related_item_id
    ,       l_PRICE_LIST_LINE_rec.relationship_type_id
    ,       l_PRICE_LIST_LINE_rec.reprice_flag
    ,       l_PRICE_LIST_LINE_rec.request_id
    ,       l_PRICE_LIST_LINE_rec.revision
    ,       l_PRICE_LIST_LINE_rec.revision_date
    ,       l_PRICE_LIST_LINE_rec.revision_reason_code
    ,       l_PRICE_LIST_LINE_rec.start_date_active
    ,       l_PRICE_LIST_LINE_rec.substitution_attribute
    ,       l_PRICE_LIST_LINE_rec.substitution_context
    ,       l_PRICE_LIST_LINE_rec.substitution_value
    ,       l_PRICE_LIST_LINE_rec.customer_item_id
    ,       l_PRICE_LIST_LINE_rec.break_uom_code
    ,	    l_PRICE_LIST_LINE_rec.break_uom_context
    ,       l_PRICE_LIST_LINE_rec.break_uom_attribute
    ,       l_PRICE_LIST_LINE_rec.continuous_price_break_flag -- Continuous price breaks
    FROM    QP_LIST_LINES
    WHERE   LIST_LINE_ID = p_PRICE_LIST_LINE_rec.list_line_id
        FOR UPDATE NOWAIT;


oe_debug_pub.add(' accrual qty:'||l_PRICE_LIST_LINE_rec.accrual_qty||':'||p_PRICE_LIST_LINE_rec.accrual_qty||':');
oe_debug_pub.add(' accrual uom code:'||l_PRICE_LIST_LINE_rec.accrual_uom_code||':'|| p_PRICE_LIST_LINE_rec.accrual_uom_code||':');
oe_debug_pub.add(' arithmetic_operator:'||l_PRICE_LIST_LINE_rec.arithmetic_operator||':'||   p_PRICE_LIST_LINE_rec.arithmetic_operator||':');
oe_debug_pub.add(' attribute1:'||l_PRICE_LIST_LINE_rec.attribute1||':'||  p_PRICE_LIST_LINE_rec.attribute1||':');
oe_debug_pub.add(' attribute10:'||l_PRICE_LIST_LINE_rec.attribute10||':'||p_PRICE_LIST_LINE_rec.attribute10||':');
oe_debug_pub.add(' attribute11:'||l_PRICE_LIST_LINE_rec.attribute11||':'||p_PRICE_LIST_LINE_rec.attribute11||':');
oe_debug_pub.add(' attribute12:'||l_PRICE_LIST_LINE_rec.attribute12||':'||p_PRICE_LIST_LINE_rec.attribute12||':');
oe_debug_pub.add(' attribute13:'||l_PRICE_LIST_LINE_rec.attribute13||':'||p_PRICE_LIST_LINE_rec.attribute13||':');
oe_debug_pub.add(' attribute14:'||l_PRICE_LIST_LINE_rec.attribute14||':'||p_PRICE_LIST_LINE_rec.attribute14||':');
oe_debug_pub.add(' attribute15:'||l_PRICE_LIST_LINE_rec.attribute15||':'||p_PRICE_LIST_LINE_rec.attribute15||':');
oe_debug_pub.add(' attribute2:'||l_PRICE_LIST_LINE_rec.attribute2||':'||p_PRICE_LIST_LINE_rec.attribute2||':');
oe_debug_pub.add(' attribute3:'||l_PRICE_LIST_LINE_rec.attribute3||':'||p_PRICE_LIST_LINE_rec.attribute3||':');
oe_debug_pub.add(' attribute4:'||l_PRICE_LIST_LINE_rec.attribute4||':'||p_PRICE_LIST_LINE_rec.attribute4||':');
oe_debug_pub.add(' attribute5:'||l_PRICE_LIST_LINE_rec.attribute5||':'||p_PRICE_LIST_LINE_rec.attribute5||':');
oe_debug_pub.add(' attribute6:'||l_PRICE_LIST_LINE_rec.attribute6||':'||p_PRICE_LIST_LINE_rec.attribute6||':');
oe_debug_pub.add(' attribute7:'||l_PRICE_LIST_LINE_rec.attribute7||':'||p_PRICE_LIST_LINE_rec.attribute7||':');
oe_debug_pub.add(' attribute8:'||l_PRICE_LIST_LINE_rec.attribute8||':'||p_PRICE_LIST_LINE_rec.attribute8||':');
oe_debug_pub.add(' attribute9:'||l_PRICE_LIST_LINE_rec.attribute9||':'||p_PRICE_LIST_LINE_rec.attribute9||':');
oe_debug_pub.add(' automatic_flag:'||l_PRICE_LIST_LINE_rec.automatic_flag||':'||p_PRICE_LIST_LINE_rec.automatic_flag||':');
oe_debug_pub.add(' base qty:'||l_PRICE_LIST_LINE_rec.base_qty||':'||p_PRICE_LIST_LINE_rec.base_qty||':');
oe_debug_pub.add(' base uom code:'||l_PRICE_LIST_LINE_rec.base_uom_code||':'||p_PRICE_LIST_LINE_rec.base_uom_code||':');
oe_debug_pub.add(' comments:'||l_PRICE_LIST_LINE_rec.comments||':'||p_PRICE_LIST_LINE_rec.comments||':');
oe_debug_pub.add(' context:'||l_PRICE_LIST_LINE_rec.context||':'||p_PRICE_LIST_LINE_rec.context||':');
oe_debug_pub.add(' created_by:'||l_PRICE_LIST_LINE_rec.created_by||':'||p_PRICE_LIST_LINE_rec.created_by||':');
oe_debug_pub.add(' creation_date:'||l_PRICE_LIST_LINE_rec.creation_date||':'||p_PRICE_LIST_LINE_rec.creation_date||':');
oe_debug_pub.add(' effective_period_uom:'||l_PRICE_LIST_LINE_rec.effective_period_uom||':'||p_PRICE_LIST_LINE_rec.effective_period_uom||':');
oe_debug_pub.add(' end_date_active:'||l_PRICE_LIST_LINE_rec.end_date_active||':'||p_PRICE_LIST_LINE_rec.end_date_active||':');
oe_debug_pub.add(' estim_accrual_rate:'||l_PRICE_LIST_LINE_rec.estim_accrual_rate||':'||p_PRICE_LIST_LINE_rec.estim_accrual_rate||':');
oe_debug_pub.add(' generate_using_formula_id:'||l_PRICE_LIST_LINE_rec.generate_using_formula_id||':'||p_PRICE_LIST_LINE_rec.generate_using_formula_id||':');
oe_debug_pub.add(' inventory_item_id:'||l_PRICE_LIST_LINE_rec.inventory_item_id||':'||p_PRICE_LIST_LINE_rec.inventory_item_id||':');
oe_debug_pub.add(' last_updated_by:'||l_PRICE_LIST_LINE_rec.last_updated_by||':'||p_PRICE_LIST_LINE_rec.last_updated_by||':');
oe_debug_pub.add(' last_update_date:'||l_PRICE_LIST_LINE_rec.last_update_date||':'||p_PRICE_LIST_LINE_rec.last_update_date||':');
oe_debug_pub.add(' accrual qty:'||l_PRICE_LIST_LINE_rec.last_update_login||':'||p_PRICE_LIST_LINE_rec.last_update_login||':');
oe_debug_pub.add(' list_header_id:'||l_PRICE_LIST_LINE_rec.list_header_id||':'||p_PRICE_LIST_LINE_rec.list_header_id||':');
oe_debug_pub.add(' list_line_id:'||l_PRICE_LIST_LINE_rec.list_line_id||':'||p_PRICE_LIST_LINE_rec.list_line_id||':');
oe_debug_pub.add(' list_line_type_code:'||l_PRICE_LIST_LINE_rec.list_line_type_code||':'||p_PRICE_LIST_LINE_rec.list_line_type_code||':');
oe_debug_pub.add(' list_price:'||l_PRICE_LIST_LINE_rec.list_price||':'||p_PRICE_LIST_LINE_rec.list_price||':');
oe_debug_pub.add(' product_precedence:'||l_PRICE_LIST_LINE_rec.product_precedence||':'||p_PRICE_LIST_LINE_rec.product_precedence||':');
oe_debug_pub.add(' modifier_level_code:'||l_PRICE_LIST_LINE_rec.modifier_level_code||':'||p_PRICE_LIST_LINE_rec.modifier_level_code||':');
oe_debug_pub.add(' number_effective_periods:'||l_PRICE_LIST_LINE_rec.number_effective_periods||':'||p_PRICE_LIST_LINE_rec.number_effective_periods||':');
oe_debug_pub.add(' operand:'||l_PRICE_LIST_LINE_rec.operand||':'||p_PRICE_LIST_LINE_rec.operand||':');
oe_debug_pub.add(' organization_id:'||l_PRICE_LIST_LINE_rec.organization_id||':'||p_PRICE_LIST_LINE_rec.organization_id||':');
oe_debug_pub.add(' override_flag:'||l_PRICE_LIST_LINE_rec.override_flag||':'||p_PRICE_LIST_LINE_rec.override_flag||':');
oe_debug_pub.add(' percent_price:'||l_PRICE_LIST_LINE_rec.percent_price||':'||p_PRICE_LIST_LINE_rec.percent_price||':');
oe_debug_pub.add(' accrual qty:'||l_PRICE_LIST_LINE_rec.price_break_type_code||':'||p_PRICE_LIST_LINE_rec.price_break_type_code||':');
oe_debug_pub.add(' price_by_formula_id:'||l_PRICE_LIST_LINE_rec.price_by_formula_id||':'||p_PRICE_LIST_LINE_rec.price_by_formula_id||':');
oe_debug_pub.add(' primary_uom_flag:'||l_PRICE_LIST_LINE_rec.primary_uom_flag||':'||p_PRICE_LIST_LINE_rec.primary_uom_flag||':');
oe_debug_pub.add(' print_on_invoice_flag:'||l_PRICE_LIST_LINE_rec.print_on_invoice_flag||':'||p_PRICE_LIST_LINE_rec.print_on_invoice_flag||':');
oe_debug_pub.add(' program_application_id:'||l_PRICE_LIST_LINE_rec.program_application_id||':'||p_PRICE_LIST_LINE_rec.program_application_id||':');
oe_debug_pub.add(' program_id:'||l_PRICE_LIST_LINE_rec.program_id||':'||p_PRICE_LIST_LINE_rec.program_id||':');
oe_debug_pub.add(' program_update_date:'||l_PRICE_LIST_LINE_rec.program_update_date||':'||p_PRICE_LIST_LINE_rec.program_update_date||':');
oe_debug_pub.add(' rebate_trxn_type_code:'||l_PRICE_LIST_LINE_rec.rebate_trxn_type_code||':'||p_PRICE_LIST_LINE_rec.rebate_trxn_type_code||':');
oe_debug_pub.add(' recurring_value:'||l_PRICE_LIST_LINE_rec.recurring_value||':'||p_PRICE_LIST_LINE_rec.recurring_value||':');
oe_debug_pub.add(' related_item_id:'||l_PRICE_LIST_LINE_rec.related_item_id||':'||p_PRICE_LIST_LINE_rec.related_item_id||':');
oe_debug_pub.add(' relationship_type_id:'||l_PRICE_LIST_LINE_rec.relationship_type_id||':'||p_PRICE_LIST_LINE_rec.relationship_type_id||':');
oe_debug_pub.add(' reprice_flag:'||l_PRICE_LIST_LINE_rec.reprice_flag||':'||p_PRICE_LIST_LINE_rec.reprice_flag||':');
oe_debug_pub.add(' request_id:'||l_PRICE_LIST_LINE_rec.request_id||':'||p_PRICE_LIST_LINE_rec.request_id||':');
oe_debug_pub.add(' revision:'||l_PRICE_LIST_LINE_rec.revision||':'||p_PRICE_LIST_LINE_rec.revision||':');
oe_debug_pub.add(' revision_date:'||l_PRICE_LIST_LINE_rec.revision_date||':'||p_PRICE_LIST_LINE_rec.revision_date||':');
oe_debug_pub.add(' revision_reason_code:'||l_PRICE_LIST_LINE_rec.revision_reason_code||':'||p_PRICE_LIST_LINE_rec.revision_reason_code||':');
oe_debug_pub.add(' start_date_active:'||l_PRICE_LIST_LINE_rec.start_date_active||':'||p_PRICE_LIST_LINE_rec.start_date_active||':');
oe_debug_pub.add(' substitution_attr:'||l_PRICE_LIST_LINE_rec.substitution_attribute||':'||p_PRICE_LIST_LINE_rec.substitution_attribute||':');
oe_debug_pub.add(' substitution_context:'||l_PRICE_LIST_LINE_rec.substitution_context||':'||p_PRICE_LIST_LINE_rec.substitution_context||':');
oe_debug_pub.add(' substitution_value:'||l_PRICE_LIST_LINE_rec.substitution_value||':'||p_PRICE_LIST_LINE_rec.substitution_value||':');
oe_debug_pub.add(' customer_item_id:'||l_PRICE_LIST_LINE_rec.customer_item_id||':'||p_PRICE_LIST_LINE_rec.customer_item_id||':');



    --  Row locked. Compare IN attributes to DB attributes.

    IF  QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_qty,
                         l_PRICE_LIST_LINE_rec.accrual_qty)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_uom_code,
                         l_PRICE_LIST_LINE_rec.accrual_uom_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.arithmetic_operator,
                         l_PRICE_LIST_LINE_rec.arithmetic_operator)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute1,
                         l_PRICE_LIST_LINE_rec.attribute1)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute10,
                         l_PRICE_LIST_LINE_rec.attribute10)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute11,
                         l_PRICE_LIST_LINE_rec.attribute11)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute12,
                         l_PRICE_LIST_LINE_rec.attribute12)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute13,
                         l_PRICE_LIST_LINE_rec.attribute13)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute14,
                         l_PRICE_LIST_LINE_rec.attribute14)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute15,
                         l_PRICE_LIST_LINE_rec.attribute15)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute2,
                         l_PRICE_LIST_LINE_rec.attribute2)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute3,
                         l_PRICE_LIST_LINE_rec.attribute3)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute4,
                         l_PRICE_LIST_LINE_rec.attribute4)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute5,
                         l_PRICE_LIST_LINE_rec.attribute5)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute6,
                         l_PRICE_LIST_LINE_rec.attribute6)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute7,
                         l_PRICE_LIST_LINE_rec.attribute7)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute8,
                         l_PRICE_LIST_LINE_rec.attribute8)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.attribute9,
                         l_PRICE_LIST_LINE_rec.attribute9)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.automatic_flag,
                         l_PRICE_LIST_LINE_rec.automatic_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_qty,
                         l_PRICE_LIST_LINE_rec.base_qty)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_uom_code,
                         l_PRICE_LIST_LINE_rec.base_uom_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.comments,
                         l_PRICE_LIST_LINE_rec.comments)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.context,
                         l_PRICE_LIST_LINE_rec.context)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.created_by,
                         l_PRICE_LIST_LINE_rec.created_by)
    AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.creation_date),
                         trunc(l_PRICE_LIST_LINE_rec.creation_date))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.effective_period_uom,
                         l_PRICE_LIST_LINE_rec.effective_period_uom)
    AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.end_date_active),
                         trunc(l_PRICE_LIST_LINE_rec.end_date_active))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.estim_accrual_rate,
                         l_PRICE_LIST_LINE_rec.estim_accrual_rate)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.generate_using_formula_id,
                         l_PRICE_LIST_LINE_rec.generate_using_formula_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,
                         l_PRICE_LIST_LINE_rec.inventory_item_id)
 --   AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_updated_by,
 --                        l_PRICE_LIST_LINE_rec.last_updated_by)
 --   AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.last_update_date),
 --                        trunc(l_PRICE_LIST_LINE_rec.last_update_date))
 --   AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.last_update_login,
 --                        l_PRICE_LIST_LINE_rec.last_update_login)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_header_id,
                         l_PRICE_LIST_LINE_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_id,
                         l_PRICE_LIST_LINE_rec.list_line_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_type_code,
                         l_PRICE_LIST_LINE_rec.list_line_type_code)
--5409776 and 8540557
  --  AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_price,
    --                     l_PRICE_LIST_LINE_rec.list_price)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.product_precedence,
                         l_PRICE_LIST_LINE_rec.product_precedence)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.modifier_level_code,
                         l_PRICE_LIST_LINE_rec.modifier_level_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.number_effective_periods,
                         l_PRICE_LIST_LINE_rec.number_effective_periods)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.operand,
                         l_PRICE_LIST_LINE_rec.operand)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.organization_id,
                         l_PRICE_LIST_LINE_rec.organization_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.override_flag,
                         l_PRICE_LIST_LINE_rec.override_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.percent_price,
                         l_PRICE_LIST_LINE_rec.percent_price)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_break_type_code,
                         l_PRICE_LIST_LINE_rec.price_break_type_code)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_by_formula_id,
                         l_PRICE_LIST_LINE_rec.price_by_formula_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.primary_uom_flag,
                         l_PRICE_LIST_LINE_rec.primary_uom_flag)
    --AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.print_on_invoice_flag, bug8206467
    --                     l_PRICE_LIST_LINE_rec.print_on_invoice_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_application_id,
                         l_PRICE_LIST_LINE_rec.program_application_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.program_id,
                         l_PRICE_LIST_LINE_rec.program_id)
    AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.program_update_date),
                         trunc(l_PRICE_LIST_LINE_rec.program_update_date))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rebate_trxn_type_code,
                         l_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
    -- block pricing
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.recurring_value,
                         l_PRICE_LIST_LINE_rec.recurring_value)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.related_item_id,
                         l_PRICE_LIST_LINE_rec.related_item_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.relationship_type_id,
                         l_PRICE_LIST_LINE_rec.relationship_type_id)
--    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,
--                         l_PRICE_LIST_LINE_rec.reprice_flag)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.request_id,
                         l_PRICE_LIST_LINE_rec.request_id)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision,
                         l_PRICE_LIST_LINE_rec.revision)
    AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.revision_date),
                         trunc(l_PRICE_LIST_LINE_rec.revision_date))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,
                         l_PRICE_LIST_LINE_rec.revision_reason_code)
    AND QP_GLOBALS.Equal(trunc(p_PRICE_LIST_LINE_rec.start_date_active),
                         trunc(l_PRICE_LIST_LINE_rec.start_date_active))
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_attribute,
                         l_PRICE_LIST_LINE_rec.substitution_attribute)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_context,
                         l_PRICE_LIST_LINE_rec.substitution_context)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.substitution_value,
                         l_PRICE_LIST_LINE_rec.substitution_value)
    AND QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.customer_item_id,
                         l_PRICE_LIST_LINE_rec.customer_item_id)
    THEN

        --  Row has not changed. Set out parameter.

        x_PRICE_LIST_LINE_rec          := l_PRICE_LIST_LINE_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    ELSE
	--8594682 - Add debug messages for OE_LOCK error
	oe_debug_pub.ADD('-------------------Data compare in Price list line (database vs record)------------------');
	oe_debug_pub.add('list_line_id		:'||l_PRICE_LIST_LINE_rec.list_line_id||':'||p_PRICE_LIST_LINE_rec.list_line_id||':');
	oe_debug_pub.ADD('attribute1		:'||l_PRICE_LIST_LINE_rec.attribute1||':'||p_PRICE_LIST_LINE_rec.attribute1||':');
	oe_debug_pub.ADD('attribute2		:'||l_PRICE_LIST_LINE_rec.attribute2||':'||p_PRICE_LIST_LINE_rec.attribute2||':');
	oe_debug_pub.ADD('attribute3		:'||l_PRICE_LIST_LINE_rec.attribute3||':'||p_PRICE_LIST_LINE_rec.attribute3||':');
	oe_debug_pub.ADD('attribute4		:'||l_PRICE_LIST_LINE_rec.attribute4||':'||p_PRICE_LIST_LINE_rec.attribute4||':');
	oe_debug_pub.ADD('attribute5		:'||l_PRICE_LIST_LINE_rec.attribute5||':'||p_PRICE_LIST_LINE_rec.attribute5||':');
	oe_debug_pub.ADD('attribute6		:'||l_PRICE_LIST_LINE_rec.attribute6||':'||p_PRICE_LIST_LINE_rec.attribute6||':');
	oe_debug_pub.ADD('attribute7		:'||l_PRICE_LIST_LINE_rec.attribute7||':'||p_PRICE_LIST_LINE_rec.attribute7||':');
	oe_debug_pub.ADD('attribute8		:'||l_PRICE_LIST_LINE_rec.attribute8||':'||p_PRICE_LIST_LINE_rec.attribute8||':');
	oe_debug_pub.ADD('attribute9		:'||l_PRICE_LIST_LINE_rec.attribute9||':'||p_PRICE_LIST_LINE_rec.attribute9||':');
	oe_debug_pub.ADD('attribute10		:'||l_PRICE_LIST_LINE_rec.attribute10||':'||p_PRICE_LIST_LINE_rec.attribute10||':');
	oe_debug_pub.ADD('attribute11		:'||l_PRICE_LIST_LINE_rec.attribute11||':'||p_PRICE_LIST_LINE_rec.attribute11||':');
	oe_debug_pub.ADD('attribute12		:'||l_PRICE_LIST_LINE_rec.attribute12||':'||p_PRICE_LIST_LINE_rec.attribute12||':');
	oe_debug_pub.ADD('attribute13		:'||l_PRICE_LIST_LINE_rec.attribute13||':'||p_PRICE_LIST_LINE_rec.attribute13||':');
	oe_debug_pub.ADD('attribute14		:'||l_PRICE_LIST_LINE_rec.attribute14||':'||p_PRICE_LIST_LINE_rec.attribute14||':');
	oe_debug_pub.ADD('attribute15		:'||l_PRICE_LIST_LINE_rec.attribute15||':'||p_PRICE_LIST_LINE_rec.attribute15||':');
	oe_debug_pub.ADD('ACCRUAL_QTY		:'||l_PRICE_LIST_LINE_rec.ACCRUAL_QTY||':'||p_PRICE_LIST_LINE_rec.ACCRUAL_QTY||':');
	oe_debug_pub.ADD('ACCRUAL_UOM_CODE	:'||l_PRICE_LIST_LINE_rec.ACCRUAL_UOM_CODE||':'||p_PRICE_LIST_LINE_rec.ACCRUAL_UOM_CODE||':');
	oe_debug_pub.ADD('ARITHMETIC_OPERATOR	:'||l_PRICE_LIST_LINE_rec.ARITHMETIC_OPERATOR||':'||p_PRICE_LIST_LINE_rec.ARITHMETIC_OPERATOR||':');
	oe_debug_pub.ADD('AUTOMATIC_FLAG	:'||l_PRICE_LIST_LINE_rec.AUTOMATIC_FLAG||':'||p_PRICE_LIST_LINE_rec.AUTOMATIC_FLAG||':');
	oe_debug_pub.ADD('BASE_QTY		:'||l_PRICE_LIST_LINE_rec.BASE_QTY||':'||p_PRICE_LIST_LINE_rec.BASE_QTY||':');
	oe_debug_pub.ADD('BASE_UOM_CODE		:'||l_PRICE_LIST_LINE_rec.BASE_UOM_CODE||':'||p_PRICE_LIST_LINE_rec.BASE_UOM_CODE||':');
	oe_debug_pub.ADD('COMMENTS		:'||l_PRICE_LIST_LINE_rec.COMMENTS||':'||p_PRICE_LIST_LINE_rec.COMMENTS||':');
	oe_debug_pub.ADD('CONTEXT		:'||l_PRICE_LIST_LINE_rec.CONTEXT||':'||p_PRICE_LIST_LINE_rec.CONTEXT||':');
	oe_debug_pub.ADD('CREATED_BY		:'||l_PRICE_LIST_LINE_rec.CREATED_BY||':'||p_PRICE_LIST_LINE_rec.CREATED_BY||':');
	oe_debug_pub.ADD('CREATION_DATE		:'||l_PRICE_LIST_LINE_rec.CREATION_DATE||':'||p_PRICE_LIST_LINE_rec.CREATION_DATE||':');
	oe_debug_pub.ADD('EFFECTIVE_PERIOD_UOM	:'||l_PRICE_LIST_LINE_rec.EFFECTIVE_PERIOD_UOM||':'||p_PRICE_LIST_LINE_rec.EFFECTIVE_PERIOD_UOM||':');
	oe_debug_pub.ADD('END_DATE_ACTIVE	:'||l_PRICE_LIST_LINE_rec.END_DATE_ACTIVE||':'||p_PRICE_LIST_LINE_rec.END_DATE_ACTIVE||':');
	oe_debug_pub.ADD('ESTIM_ACCRUAL_RATE	:'||l_PRICE_LIST_LINE_rec.ESTIM_ACCRUAL_RATE||':'||p_PRICE_LIST_LINE_rec.ESTIM_ACCRUAL_RATE||':');
	oe_debug_pub.ADD('GENERATE_USING_FORMULA_ID:'||l_PRICE_LIST_LINE_rec.GENERATE_USING_FORMULA_ID||':'||p_PRICE_LIST_LINE_rec.GENERATE_USING_FORMULA_ID||':');
	oe_debug_pub.ADD('INVENTORY_ITEM_ID	:'||l_PRICE_LIST_LINE_rec.INVENTORY_ITEM_ID||':'||p_PRICE_LIST_LINE_rec.INVENTORY_ITEM_ID||':');
	oe_debug_pub.ADD('LAST_UPDATED_BY	:'||l_PRICE_LIST_LINE_rec.LAST_UPDATED_BY||':'||p_PRICE_LIST_LINE_rec.LAST_UPDATED_BY||':');
	oe_debug_pub.ADD('LAST_UPDATE_DATE	:'||l_PRICE_LIST_LINE_rec.LAST_UPDATE_DATE||':'||p_PRICE_LIST_LINE_rec.LAST_UPDATE_DATE||':');
	oe_debug_pub.ADD('LAST_UPDATE_LOGIN	:'||l_PRICE_LIST_LINE_rec.LAST_UPDATE_LOGIN||':'||p_PRICE_LIST_LINE_rec.LAST_UPDATE_LOGIN||':');
	oe_debug_pub.ADD('LIST_HEADER_ID	:'||l_PRICE_LIST_LINE_rec.LIST_HEADER_ID||':'||p_PRICE_LIST_LINE_rec.LIST_HEADER_ID||':');
	oe_debug_pub.ADD('LIST_LINE_TYPE_CODE	:'||l_PRICE_LIST_LINE_rec.LIST_LINE_TYPE_CODE||':'||p_PRICE_LIST_LINE_rec.LIST_LINE_TYPE_CODE||':');
	oe_debug_pub.ADD('LIST_PRICE		:'||l_PRICE_LIST_LINE_rec.LIST_PRICE||':'||p_PRICE_LIST_LINE_rec.LIST_PRICE||':');
	oe_debug_pub.ADD('PRODUCT_PRECEDENCE	:'||l_PRICE_LIST_LINE_rec.PRODUCT_PRECEDENCE||':'||p_PRICE_LIST_LINE_rec.PRODUCT_PRECEDENCE||':');
	oe_debug_pub.ADD('MODIFIER_LEVEL_CODE	:'||l_PRICE_LIST_LINE_rec.MODIFIER_LEVEL_CODE||':'||p_PRICE_LIST_LINE_rec.MODIFIER_LEVEL_CODE||':');
	oe_debug_pub.ADD('NUMBER_EFFECTIVE_PERIODS:'||l_PRICE_LIST_LINE_rec.NUMBER_EFFECTIVE_PERIODS||':'||p_PRICE_LIST_LINE_rec.NUMBER_EFFECTIVE_PERIODS||':');
	oe_debug_pub.ADD('OPERAND		:'||l_PRICE_LIST_LINE_rec.OPERAND||':'||p_PRICE_LIST_LINE_rec.OPERAND||':');
	oe_debug_pub.ADD('ORGANIZATION_ID	:'||l_PRICE_LIST_LINE_rec.ORGANIZATION_ID||':'||p_PRICE_LIST_LINE_rec.ORGANIZATION_ID||':');
	oe_debug_pub.ADD('OVERRIDE_FLAG		:'||l_PRICE_LIST_LINE_rec.OVERRIDE_FLAG||':'||p_PRICE_LIST_LINE_rec.OVERRIDE_FLAG||':');
	oe_debug_pub.ADD('PERCENT_PRICE		:'||l_PRICE_LIST_LINE_rec.PERCENT_PRICE||':'||p_PRICE_LIST_LINE_rec.PERCENT_PRICE||':');
	oe_debug_pub.ADD('PRICE_BREAK_TYPE_CODE	:'||l_PRICE_LIST_LINE_rec.PRICE_BREAK_TYPE_CODE||':'||p_PRICE_LIST_LINE_rec.PRICE_BREAK_TYPE_CODE||':');
	oe_debug_pub.ADD('PRICE_BY_FORMULA_ID	:'||l_PRICE_LIST_LINE_rec.PRICE_BY_FORMULA_ID||':'||p_PRICE_LIST_LINE_rec.PRICE_BY_FORMULA_ID||':');
	oe_debug_pub.ADD('PRIMARY_UOM_FLAG	:'||l_PRICE_LIST_LINE_rec.PRIMARY_UOM_FLAG||':'||p_PRICE_LIST_LINE_rec.PRIMARY_UOM_FLAG||':');
	oe_debug_pub.ADD('PRINT_ON_INVOICE_FLAG	:'||l_PRICE_LIST_LINE_rec.PRINT_ON_INVOICE_FLAG||':'||p_PRICE_LIST_LINE_rec.PRINT_ON_INVOICE_FLAG||':');
	oe_debug_pub.ADD('PROGRAM_APPLICATION_ID:'||l_PRICE_LIST_LINE_rec.PROGRAM_APPLICATION_ID||':'||p_PRICE_LIST_LINE_rec.PROGRAM_APPLICATION_ID||':');
	oe_debug_pub.ADD('PROGRAM_ID		:'||l_PRICE_LIST_LINE_rec.PROGRAM_ID||':'||p_PRICE_LIST_LINE_rec.PROGRAM_ID||':');
	oe_debug_pub.ADD('PROGRAM_UPDATE_DATE	:'||l_PRICE_LIST_LINE_rec.PROGRAM_UPDATE_DATE||':'||p_PRICE_LIST_LINE_rec.PROGRAM_UPDATE_DATE||':');
	oe_debug_pub.ADD('REBATE_TRANSACTION_TYPE_CODE:'||l_PRICE_LIST_LINE_rec.rebate_trxn_type_code||':'||p_PRICE_LIST_LINE_rec.rebate_trxn_type_code||':');
	oe_debug_pub.ADD('RECURRING_VALUE	:'||l_PRICE_LIST_LINE_rec.RECURRING_VALUE||':'||p_PRICE_LIST_LINE_rec.RECURRING_VALUE||':');
	oe_debug_pub.ADD('RELATED_ITEM_ID	:'||l_PRICE_LIST_LINE_rec.RELATED_ITEM_ID||':'||p_PRICE_LIST_LINE_rec.RELATED_ITEM_ID||':');
	oe_debug_pub.ADD('RELATIONSHIP_TYPE_ID	:'||l_PRICE_LIST_LINE_rec.RELATIONSHIP_TYPE_ID||':'||p_PRICE_LIST_LINE_rec.RELATIONSHIP_TYPE_ID||':');
	oe_debug_pub.ADD('REPRICE_FLAG		:'||l_PRICE_LIST_LINE_rec.REPRICE_FLAG||':'||p_PRICE_LIST_LINE_rec.REPRICE_FLAG||':');
	oe_debug_pub.ADD('REQUEST_ID		:'||l_PRICE_LIST_LINE_rec.REQUEST_ID||':'||p_PRICE_LIST_LINE_rec.REQUEST_ID||':');
	oe_debug_pub.ADD('REVISION		:'||l_PRICE_LIST_LINE_rec.REVISION||':'||p_PRICE_LIST_LINE_rec.REVISION||':');
	oe_debug_pub.ADD('REVISION_DATE		:'||l_PRICE_LIST_LINE_rec.REVISION_DATE||':'||p_PRICE_LIST_LINE_rec.REVISION_DATE||':');
	oe_debug_pub.ADD('REVISION_REASON_CODE	:'||l_PRICE_LIST_LINE_rec.REVISION_REASON_CODE||':'||p_PRICE_LIST_LINE_rec.REVISION_REASON_CODE||':');
	oe_debug_pub.ADD('START_DATE_ACTIVE	:'||l_PRICE_LIST_LINE_rec.START_DATE_ACTIVE||':'||p_PRICE_LIST_LINE_rec.START_DATE_ACTIVE||':');
	oe_debug_pub.ADD('SUBSTITUTION_ATTRIBUTE:'||l_PRICE_LIST_LINE_rec.SUBSTITUTION_ATTRIBUTE||':'||p_PRICE_LIST_LINE_rec.SUBSTITUTION_ATTRIBUTE||':');
	oe_debug_pub.ADD('SUBSTITUTION_CONTEXT	:'||l_PRICE_LIST_LINE_rec.SUBSTITUTION_CONTEXT||':'||p_PRICE_LIST_LINE_rec.SUBSTITUTION_CONTEXT||':');
	oe_debug_pub.ADD('SUBSTITUTION_VALUE	:'||l_PRICE_LIST_LINE_rec.SUBSTITUTION_VALUE||':'||p_PRICE_LIST_LINE_rec.SUBSTITUTION_VALUE||':');
	oe_debug_pub.ADD('CUSTOMER_ITEM_ID	:'||l_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID||':'||p_PRICE_LIST_LINE_rec.CUSTOMER_ITEM_ID||':');
	oe_debug_pub.ADD('BREAK_UOM_CODE	:'||l_PRICE_LIST_LINE_rec.BREAK_UOM_CODE||':'||p_PRICE_LIST_LINE_rec.BREAK_UOM_CODE||':');
	oe_debug_pub.ADD('BREAK_UOM_CONTEXT	:'||l_PRICE_LIST_LINE_rec.BREAK_UOM_CONTEXT||':'||p_PRICE_LIST_LINE_rec.BREAK_UOM_CONTEXT||':');
	oe_debug_pub.ADD('BREAK_UOM_ATTRIBUTE	:'||l_PRICE_LIST_LINE_rec.BREAK_UOM_ATTRIBUTE||':'||p_PRICE_LIST_LINE_rec.BREAK_UOM_ATTRIBUTE||':');
	oe_debug_pub.ADD('-------------------Data compare in price list line end------------------');
	--  Row has changed by another user.


        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            oe_msg_pub.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            oe_msg_pub.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            oe_msg_pub.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_old_PRICE_LIST_LINE_rec       IN  QP_Price_List_PUB.Price_List_Line_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC
) RETURN QP_Price_List_PUB.Price_List_Line_Val_Rec_Type
IS
l_PRICE_LIST_LINE_val_rec     QP_Price_List_PUB.Price_List_Line_Val_Rec_Type;
BEGIN

  /*
    IF p_PRICE_LIST_LINE_rec.accrual_uom_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.accrual_uom_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.accrual_uom_code,
        p_old_PRICE_LIST_LINE_rec.accrual_uom_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.accrual_uom := QP_Id_To_Value.Accrual_Uom
        (   p_accrual_uom_code            => p_PRICE_LIST_LINE_rec.accrual_uom_code
        );
    END IF;

   */

    IF p_PRICE_LIST_LINE_rec.automatic_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.automatic_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.automatic_flag,
        p_old_PRICE_LIST_LINE_rec.automatic_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.automatic := QP_Id_To_Value.Automatic
        (   p_automatic_flag              => p_PRICE_LIST_LINE_rec.automatic_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.base_uom_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.base_uom_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.base_uom_code,
        p_old_PRICE_LIST_LINE_rec.base_uom_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.base_uom := QP_Id_To_Value.Base_Uom
        (   p_base_uom_code               => p_PRICE_LIST_LINE_rec.base_uom_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.generate_using_formula_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.generate_using_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.generate_using_formula_id,
        p_old_PRICE_LIST_LINE_rec.generate_using_formula_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.generate_using_formula := QP_Id_To_Value.Generate_Using_Formula
        (   p_generate_using_formula_id   => p_PRICE_LIST_LINE_rec.generate_using_formula_id
        );
    END IF;


    IF p_PRICE_LIST_LINE_rec.inventory_item_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.inventory_item_id,
        p_old_PRICE_LIST_LINE_rec.inventory_item_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.inventory_item := QP_Id_To_Value.Inventory_Item
        (   p_inventory_item_id           => p_PRICE_LIST_LINE_rec.inventory_item_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.list_header_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_header_id,
        p_old_PRICE_LIST_LINE_rec.list_header_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_PRICE_LIST_LINE_rec.list_header_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.list_line_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_id,
        p_old_PRICE_LIST_LINE_rec.list_line_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_PRICE_LIST_LINE_rec.list_line_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.list_line_type_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.list_line_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.list_line_type_code,
        p_old_PRICE_LIST_LINE_rec.list_line_type_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.list_line_type := QP_Id_To_Value.List_Line_Type
        (   p_list_line_type_code         => p_PRICE_LIST_LINE_rec.list_line_type_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.modifier_level_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.modifier_level_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.modifier_level_code,
        p_old_PRICE_LIST_LINE_rec.modifier_level_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.modifier_level := QP_Id_To_Value.Modifier_Level
        (   p_modifier_level_code         => p_PRICE_LIST_LINE_rec.modifier_level_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.organization_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.organization_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.organization_id,
        p_old_PRICE_LIST_LINE_rec.organization_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.organization := QP_Id_To_Value.Organization
        (   p_organization_id             => p_PRICE_LIST_LINE_rec.organization_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.override_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.override_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.override_flag,
        p_old_PRICE_LIST_LINE_rec.override_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.override := QP_Id_To_Value.Override
        (   p_override_flag               => p_PRICE_LIST_LINE_rec.override_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.price_break_type_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.price_break_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_break_type_code,
        p_old_PRICE_LIST_LINE_rec.price_break_type_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.price_break_type := QP_Id_To_Value.Price_Break_Type
        (   p_price_break_type_code       => p_PRICE_LIST_LINE_rec.price_break_type_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.price_by_formula_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.price_by_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.price_by_formula_id,
        p_old_PRICE_LIST_LINE_rec.price_by_formula_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.price_by_formula := QP_Id_To_Value.Price_By_Formula
        (   p_price_by_formula_id         => p_PRICE_LIST_LINE_rec.price_by_formula_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.primary_uom_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.primary_uom_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.primary_uom_flag,
        p_old_PRICE_LIST_LINE_rec.primary_uom_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.primary_uom := QP_Id_To_Value.Primary_Uom
        (   p_primary_uom_flag            => p_PRICE_LIST_LINE_rec.primary_uom_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.print_on_invoice_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.print_on_invoice_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.print_on_invoice_flag,
        p_old_PRICE_LIST_LINE_rec.print_on_invoice_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.print_on_invoice := QP_Id_To_Value.Print_On_Invoice
        (   p_print_on_invoice_flag       => p_PRICE_LIST_LINE_rec.print_on_invoice_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.rebate_trxn_type_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.rebate_trxn_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.rebate_trxn_type_code,
        p_old_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.rebate_transaction_type := QP_Id_To_Value.Rebate_Transaction_Type
        (   p_rebate_trxn_type_code       => p_PRICE_LIST_LINE_rec.rebate_trxn_type_code
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.related_item_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.related_item_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.related_item_id,
        p_old_PRICE_LIST_LINE_rec.related_item_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.related_item := QP_Id_To_Value.Related_Item
        (   p_related_item_id             => p_PRICE_LIST_LINE_rec.related_item_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.relationship_type_id IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.relationship_type_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.relationship_type_id,
        p_old_PRICE_LIST_LINE_rec.relationship_type_id)
    THEN
        l_PRICE_LIST_LINE_val_rec.relationship_type := QP_Id_To_Value.Relationship_Type
        (   p_relationship_type_id        => p_PRICE_LIST_LINE_rec.relationship_type_id
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.reprice_flag IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.reprice_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.reprice_flag,
        p_old_PRICE_LIST_LINE_rec.reprice_flag)
    THEN
        l_PRICE_LIST_LINE_val_rec.reprice := QP_Id_To_Value.Reprice
        (   p_reprice_flag                => p_PRICE_LIST_LINE_rec.reprice_flag
        );
    END IF;

    IF p_PRICE_LIST_LINE_rec.revision_reason_code IS NOT NULL AND
        p_PRICE_LIST_LINE_rec.revision_reason_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_PRICE_LIST_LINE_rec.revision_reason_code,
        p_old_PRICE_LIST_LINE_rec.revision_reason_code)
    THEN
        l_PRICE_LIST_LINE_val_rec.revision_reason := QP_Id_To_Value.Revision_Reason
        (   p_revision_reason_code        => p_PRICE_LIST_LINE_rec.revision_reason_code
        );
    END IF;

    RETURN l_PRICE_LIST_LINE_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_PRICE_LIST_LINE_val_rec       IN  QP_Price_List_PUB.Price_List_Line_Val_Rec_Type
) RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_PRICE_LIST_LINE_rec.

    l_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    IF  p_PRICE_LIST_LINE_val_rec.accrual_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.accrual_uom_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.accrual_uom_code := p_PRICE_LIST_LINE_rec.accrual_uom_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accrual_uom');
                oe_msg_pub.Add;

            END IF;

        ELSE

		 /*

		  l_PRICE_LIST_LINE_rec.accrual_uom_code := QP_Value_To_Id.accrual_uom
            (   p_accrual_uom                 => p_PRICE_LIST_LINE_val_rec.accrual_uom
            );

           */

            IF l_PRICE_LIST_LINE_rec.accrual_uom_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.automatic <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.automatic_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.automatic_flag := p_PRICE_LIST_LINE_rec.automatic_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.automatic_flag := QP_Value_To_Id.automatic
            (   p_automatic                   => p_PRICE_LIST_LINE_val_rec.automatic
            );

            IF l_PRICE_LIST_LINE_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.base_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.base_uom_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.base_uom_code := p_PRICE_LIST_LINE_rec.base_uom_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_uom');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.base_uom_code := QP_Value_To_Id.base_uom
            (   p_base_uom                    => p_PRICE_LIST_LINE_val_rec.base_uom
            );

            IF l_PRICE_LIST_LINE_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.generate_using_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.generate_using_formula_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.generate_using_formula_id := p_PRICE_LIST_LINE_rec.generate_using_formula_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','generate_using_formula');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.generate_using_formula_id := QP_Value_To_Id.generate_using_formula
            (   p_generate_using_formula      => p_PRICE_LIST_LINE_val_rec.generate_using_formula
            );

            IF l_PRICE_LIST_LINE_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.inventory_item_id := p_PRICE_LIST_LINE_rec.inventory_item_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.inventory_item_id := QP_Value_To_Id.inventory_item
            (   p_inventory_item              => p_PRICE_LIST_LINE_val_rec.inventory_item
            );

            IF l_PRICE_LIST_LINE_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.list_header_id := p_PRICE_LIST_LINE_rec.list_header_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_PRICE_LIST_LINE_val_rec.list_header
            );

            IF l_PRICE_LIST_LINE_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.list_line_id := p_PRICE_LIST_LINE_rec.list_line_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_PRICE_LIST_LINE_val_rec.list_line
            );

            IF l_PRICE_LIST_LINE_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.list_line_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.list_line_type_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.list_line_type_code := p_PRICE_LIST_LINE_rec.list_line_type_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.list_line_type_code := QP_Value_To_Id.list_line_type
            (   p_list_line_type              => p_PRICE_LIST_LINE_val_rec.list_line_type
            );

            IF l_PRICE_LIST_LINE_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.modifier_level <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.modifier_level_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.modifier_level_code := p_PRICE_LIST_LINE_rec.modifier_level_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','modifier_level');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.modifier_level_code := QP_Value_To_Id.modifier_level
            (   p_modifier_level              => p_PRICE_LIST_LINE_val_rec.modifier_level
            );

            IF l_PRICE_LIST_LINE_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.organization_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.organization_id := p_PRICE_LIST_LINE_rec.organization_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.organization_id := QP_Value_To_Id.organization
            (   p_organization                => p_PRICE_LIST_LINE_val_rec.organization
            );

            IF l_PRICE_LIST_LINE_rec.organization_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.override <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.override_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.override_flag := p_PRICE_LIST_LINE_rec.override_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.override_flag := QP_Value_To_Id.override
            (   p_override                    => p_PRICE_LIST_LINE_val_rec.override
            );

            IF l_PRICE_LIST_LINE_rec.override_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.price_break_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.price_break_type_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.price_break_type_code := p_PRICE_LIST_LINE_rec.price_break_type_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_break_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.price_break_type_code := QP_Value_To_Id.price_break_type
            (   p_price_break_type            => p_PRICE_LIST_LINE_val_rec.price_break_type
            );

            IF l_PRICE_LIST_LINE_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.price_by_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.price_by_formula_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.price_by_formula_id := p_PRICE_LIST_LINE_rec.price_by_formula_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_by_formula');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.price_by_formula_id := QP_Value_To_Id.price_by_formula
            (   p_price_by_formula            => p_PRICE_LIST_LINE_val_rec.price_by_formula
            );

            IF l_PRICE_LIST_LINE_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.primary_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.primary_uom_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.primary_uom_flag := p_PRICE_LIST_LINE_rec.primary_uom_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.primary_uom_flag := QP_Value_To_Id.primary_uom
            (   p_primary_uom                 => p_PRICE_LIST_LINE_val_rec.primary_uom
            );

            IF l_PRICE_LIST_LINE_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.print_on_invoice <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.print_on_invoice_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.print_on_invoice_flag := p_PRICE_LIST_LINE_rec.print_on_invoice_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','print_on_invoice');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.print_on_invoice_flag := QP_Value_To_Id.print_on_invoice
            (   p_print_on_invoice            => p_PRICE_LIST_LINE_val_rec.print_on_invoice
            );

            IF l_PRICE_LIST_LINE_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.rebate_transaction_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.rebate_trxn_type_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := p_PRICE_LIST_LINE_rec.rebate_trxn_type_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_transaction_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := QP_Value_To_Id.rebate_transaction_type
            (   p_rebate_transaction_type     => p_PRICE_LIST_LINE_val_rec.rebate_transaction_type
            );

            IF l_PRICE_LIST_LINE_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.related_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.related_item_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.related_item_id := p_PRICE_LIST_LINE_rec.related_item_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','related_item');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.related_item_id := QP_Value_To_Id.related_item
            (   p_related_item                => p_PRICE_LIST_LINE_val_rec.related_item
            );

            IF l_PRICE_LIST_LINE_rec.related_item_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.relationship_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.relationship_type_id <> FND_API.G_MISS_NUM THEN

            l_PRICE_LIST_LINE_rec.relationship_type_id := p_PRICE_LIST_LINE_rec.relationship_type_id;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','relationship_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.relationship_type_id := QP_Value_To_Id.relationship_type
            (   p_relationship_type           => p_PRICE_LIST_LINE_val_rec.relationship_type
            );

            IF l_PRICE_LIST_LINE_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.reprice <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.reprice_flag <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.reprice_flag := p_PRICE_LIST_LINE_rec.reprice_flag;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.reprice_flag := QP_Value_To_Id.reprice
            (   p_reprice                     => p_PRICE_LIST_LINE_val_rec.reprice
            );

            IF l_PRICE_LIST_LINE_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_PRICE_LIST_LINE_val_rec.revision_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_PRICE_LIST_LINE_rec.revision_reason_code <> FND_API.G_MISS_CHAR THEN

            l_PRICE_LIST_LINE_rec.revision_reason_code := p_PRICE_LIST_LINE_rec.revision_reason_code;

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
                oe_msg_pub.Add;

            END IF;

        ELSE

            l_PRICE_LIST_LINE_rec.revision_reason_code := QP_Value_To_Id.revision_reason
            (   p_revision_reason             => p_PRICE_LIST_LINE_val_rec.revision_reason
            );

            IF l_PRICE_LIST_LINE_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
                l_PRICE_LIST_LINE_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    RETURN l_PRICE_LIST_LINE_rec;

END Get_Ids;


Procedure Print_Price_List_Line
        (p_PRICE_LIST_LINE_rec IN QP_PRICE_LIST_PUB.PRICE_LIST_LINE_REC_TYPE,
         p_counter IN NUMBER)
IS
BEGIN
oe_debug_pub.add('additional message 1- 8206467');
  oe_debug_pub.add('accrual qty ' || p_counter || ': ' || p_PRICE_LIST_LINE_rec.accrual_qty);

   oe_debug_pub.add('accrual uom code ' || p_counter || ': ' ||  p_PRICE_LIST_LINE_rec.accrual_uom_code);
   oe_debug_pub.add('arithmetic_operator ' || p_counter || ': ' ||    p_PRICE_LIST_LINE_rec.arithmetic_operator);
   oe_debug_pub.add('attribute1 ' || p_counter || ': ' ||   p_PRICE_LIST_LINE_rec.attribute1);
   oe_debug_pub.add('attribute10 ' || p_counter || ': ' ||      p_PRICE_LIST_LINE_rec.attribute10);
   oe_debug_pub.add('attribute11 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute11);
   oe_debug_pub.add('attribute12 ' || p_counter || ': ' || p_PRICE_LIST_LINE_rec.attribute12);
   oe_debug_pub.add('attribute13 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute13);
   oe_debug_pub.add('attribute14 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute14);
   oe_debug_pub.add('attribute15 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute15);
   oe_debug_pub.add('attribute2 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute2);
   oe_debug_pub.add('attribute3 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute3);
   oe_debug_pub.add('attribute4 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute4);
   oe_debug_pub.add('attribute5 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute5);
   oe_debug_pub.add('attribute6 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute6);
   oe_debug_pub.add('attribute7 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute7);
   oe_debug_pub.add('attribute8 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute8);
   oe_debug_pub.add('attribute9 ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.attribute9);
   oe_debug_pub.add('automatic_flag ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.automatic_flag);
   oe_debug_pub.add('base qty ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.base_qty);
   oe_debug_pub.add('base uom code ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.base_uom_code);
   oe_debug_pub.add('comments ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.comments);
   oe_debug_pub.add('context ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.context);
   oe_debug_pub.add('created_by ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.created_by);
   oe_debug_pub.add('creation_date ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.creation_date);
   oe_debug_pub.add('effective_period_uom ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.effective_period_uom);
   oe_debug_pub.add('end_date_active ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.end_date_active);
   oe_debug_pub.add('estim_accrual_rate ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.estim_accrual_rate);
   oe_debug_pub.add('generate_using_formula_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.generate_using_formula_id);
   oe_debug_pub.add('inventory_item_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.inventory_item_id);
   oe_debug_pub.add('last_updated_by ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.last_updated_by);
   oe_debug_pub.add('last_update_date ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.last_update_date);
   oe_debug_pub.add('accrual qty ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.last_update_login);
   oe_debug_pub.add('list_header_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.list_header_id);
   oe_debug_pub.add('list_line_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.list_line_id);
   oe_debug_pub.add('list_line_type_code ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.list_line_type_code);
   oe_debug_pub.add('list_price ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.list_price);
   oe_debug_pub.add('product_precedence ' || p_counter || ': ' || p_PRICE_LIST_LINE_rec.product_precedence);
   oe_debug_pub.add('modifier_level_code ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.modifier_level_code);
   oe_debug_pub.add('number_effective_periods ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.number_effective_periods);
   oe_debug_pub.add('operand ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.operand);
   oe_debug_pub.add('organization_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.organization_id);
   oe_debug_pub.add('override_flag ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.override_flag);
   oe_debug_pub.add('percent_price ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.percent_price);
   oe_debug_pub.add('accrual qty ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.price_break_type_code);
   oe_debug_pub.add('price_by_formula_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.price_by_formula_id);
   oe_debug_pub.add('primary_uom_flag ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.primary_uom_flag);
   oe_debug_pub.add('print_on_invoice_flag ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.print_on_invoice_flag);
   oe_debug_pub.add('program_application_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.program_application_id);
   oe_debug_pub.add('program_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.program_id);
   oe_debug_pub.add('program_update_date ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.program_update_date);
   oe_debug_pub.add('rebate_trxn_type_code ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.rebate_trxn_type_code);
-- block pricing
   oe_debug_pub.add('recurring_value' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.recurring_value);
   oe_debug_pub.add('related_item_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.related_item_id);
   oe_debug_pub.add('relationship_type_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.relationship_type_id);
   oe_debug_pub.add('reprice_flag ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.reprice_flag);
   oe_debug_pub.add('request_id ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.request_id);
   oe_debug_pub.add('revision ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.revision);
   oe_debug_pub.add('revision_date ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.revision_date);
   oe_debug_pub.add('revision_reason_code ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.revision_reason_code);
   oe_debug_pub.add('start_date_active ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.start_date_active);
   oe_debug_pub.add('substitution_attr ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.substitution_attribute);
   oe_debug_pub.add('substitution_context ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.substitution_context);
   oe_debug_pub.add('substitution_value ' || p_counter || ': ' ||p_PRICE_LIST_LINE_rec.substitution_value);

END Print_Price_List_Line;

FUNCTION get_qualifier_attr_value(p_qual_attr_value in varchar2)
return varchar2
is
l_qual_attr_value number;
BEGIN

   IF p_qual_attr_value is not null THEN

	  select to_number(p_qual_attr_value)
	  into l_qual_attr_value
	  from dual;

       return to_char(l_qual_attr_value);
   ELSE
       return null;
   END IF;

EXCEPTION

   WHEN INVALID_NUMBER THEN

       return NULL;

END get_qualifier_attr_value;


/******************************************************************************
* Important: The following function Get_Context is currently not being
*            called anywhere. So this function has not been altered for used
*            with Attributes Manager installed. So, please do not use this
*            utility function from anywhere in the code even in the future
*            unless you modify it suitably for use with Attributes Manager.
******************************************************************************/
FUNCTION Get_Context(p_FlexField_Name  IN VARCHAR2
				  ,p_context    IN VARCHAR2)RETURN VARCHAR2 IS

  Flexfield FND_DFLEX.dflex_r;
  Flexinfo  FND_DFLEX.dflex_dr;
  Contexts  FND_DFLEX.contexts_dr;


  x_context_code        VARCHAR2(240);

  BEGIN

  -- Call Flexapi to get contexts

  FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);
  FND_DFLEX.get_contexts(Flexfield,Contexts);


  For i in 1..Contexts.ncontexts LOOP

    If(Contexts.is_enabled(i) AND (NOT (Contexts.is_global(i)))) Then

       If p_context = Contexts.context_code(i) Then
          x_context_code :=Contexts.context_name(i);
		EXIT;
       End If;

    End if;
  End Loop;

  RETURN x_context_code;

END Get_Context;

/******************************************************************************
* Important: The following function Get_Attribute_Code is currently not being
*            called anywhere. So this function has not been altered for used
*            with Attributes Manager installed. So, please do not use this
*            utility function from anywhere in the code even in the future
*            unless you modify it suitably for use with Attributes Manager.
******************************************************************************/
FUNCTION Get_Attribute_Code(p_FlexField_Name IN VARCHAR2
                            ,p_Context_Name   IN VARCHAR2
				        ,p_attribute      IN VARCHAR2
			   ) RETURN VARCHAR2 IS

  Flexfield FND_DFLEX.dflex_r;
  Flexinfo  FND_DFLEX.dflex_dr;
  Contexts  FND_DFLEX.contexts_dr;
  segments  FND_DFLEX.segments_dr;
  i BINARY_INTEGER;
  x_attribute_code VARCHAR2(240) := NULL;

BEGIN

  --fnd_message.debug('passsed values are ' ||p_FlexField_Name);
  --fnd_message.debug('passsed values are ' ||p_Context_Name);
  --fnd_message.debug('passsed values are ' ||p_attribute);


  FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);
  FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Name),
                      segments,TRUE);

  For i in 1..segments.nsegments LOOP

    IF segments.is_enabled(i)  THEN

         --fnd_message.debug('col name is  ' ||segments.application_column_name(i));
         --fnd_message.debug(' seg name is  ' ||segments.segment_name(i));
	    IF segments.application_column_name(i) = p_attribute Then
		  x_attribute_code := segments.row_prompt(i);
		  RETURN x_attribute_code;
         End if;
    END IF;
  END LOOP;

  RETURN x_attribute_code;

 END Get_Attribute_Code;

FUNCTION Get_Product_Value(p_FlexField_Name       IN VARCHAR2
                            ,p_Context_Name         IN VARCHAR2
				        ,p_attribute_name         IN VARCHAR2
					   ,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2 IS
l_item_name varchar2(240) := NULL;
l_category_name varchar2(240) := NULL;
l_segment_name varchar2(240) := NULL;
l_organization_id VARCHAR2(30) := TO_CHAR(QP_UTIL.Get_Item_Validation_Org);


BEGIN

  IF (    (p_FlexField_Name = 'QP_ATTR_DEFNS_PRICING')
      and ( p_Context_Name = 'ITEM' ) ) THEN

	 IF (p_attribute_name = 'PRICING_ATTRIBUTE1') then

--changed the code to use G_ORGANIZATION_ID for performance problem on modifiers
		select concatenated_segments
		into l_item_name
		from mtl_system_items_vl
		where inventory_item_id = to_number(p_attr_value)
		and organization_id = l_organization_id and rownum=1;

		RETURN l_item_name;

	 ELSIF (p_attribute_name = 'PRICING_ATTRIBUTE2') then
       /* product catalog
              select concatenated_segments
		into l_category_name
		from mtl_categories_kfv
		where category_id = to_number(p_attr_value) and rownum=1;
       */
              select category_name
		into l_category_name
		from qp_item_categories_v
		where category_id = to_number(p_attr_value) and rownum=1;

		RETURN l_category_name;
       /*

        ELSIF (p_attribute_name = 'PRICING_ATTRIBUTE3') then

             RETURN( Get_Attribute_Value(
                             p_FlexField_Name => 'QP_ATTR_DEFNS_PRICING'
                            ,p_Context_Name => 'ITEM'
		            ,p_segment_name => 'ALL_ITEMS'
                            ,p_attr_value => p_attr_value) );

       */

       ELSE

            l_segment_name := Get_Segment_Name(p_FlexField_Name,
                             p_Context_Name,
                             p_attribute_name);

             RETURN( Get_Attribute_Value(
                             p_FlexField_Name
                            ,p_Context_Name
		            ,l_segment_name
                            ,p_attr_value) );



     END IF;

   ELSE

	 RETURN NULL;

   END IF;

 EXCEPTION

         WHEN OTHERS THEN RETURN NULL;

END Get_Product_Value;

FUNCTION Get_Attribute_Value(p_FlexField_Name       IN VARCHAR2
                            ,p_Context_Name         IN VARCHAR2
				        ,p_segment_name         IN VARCHAR2
					   ,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2 IS

  Vset  FND_VSET.valueset_r;
  Fmt   FND_VSET.valueset_dr;

  Found BOOLEAN;
  Row   NUMBER;
  Value FND_VSET.value_dr;



  x_Format_Type Varchar2(1);
  x_Validation_Type Varchar2(1);
  x_Vsid  NUMBER;


  x_attr_value_code     VARCHAR2(240);
  l_id VARCHAR2(150);
  l_value VARCHAR2(150);


  BEGIN

  QP_UTIL.get_valueset_id(p_FlexField_Name,p_Context_Name,p_Segment_Name,x_Vsid,x_Format_Type,
                   x_Validation_Type);
  --fnd_message.debug(x_Vsid);
  --fnd_message.debug(x_Validation_Type);
  --fnd_message.show;

  IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN
   IF x_Validation_Type = 'I' THEN     --Added for 2332139
     FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
     FND_VSET.get_value_init(Vset,TRUE);
     FND_VSET.get_value(Vset,Row,Found,Value);

   IF Fmt.Has_Id Then    --id is defined.Hence compare for id

     While(Found) Loop

       --fnd_message.debug(Value.value);
       --fnd_message.debug(Value.meaning);
       --fnd_message.debug(Value.id);

       If  p_attr_value  = Value.id  Then

	      x_attr_value_code  := Value.Value;
           RETURN x_attr_value_code;
       End If;
       FND_VSET.get_value(Vset,Row,Found,Value);

     End Loop;

  Else

     While(Found) Loop

                      --fnd_message.debug(Value.value);
                      --fnd_message.debug(Value.meaning);
                      --fnd_message.debug(Value.id);

                        If  p_attr_value  = Value.value  Then

	                       x_attr_value_code  := p_attr_value;
                               RETURN x_attr_value_code;
                        End If;
                        FND_VSET.get_value(Vset,Row,Found,Value);

                     End Loop;

     End If;   -- end of Fmt.Has_Id

     FND_VSET.get_value_end(Vset);

/* Added for 2332139 */

   ELSIF x_Validation_Type='F' THEN
                                       FND_VSET.get_valueset(x_Vsid,Vset,Fmt);

                                        IF (QP_UTIL.value_exists_in_table(Vset.table_info,
                                                        p_attr_value,l_id,l_value)) THEN

                                                        IF Fmt.Has_Id Then
                                                        --id is defined. Hence compare id

                                                                IF p_attr_value = l_id Then

                                                                        x_attr_value_code := l_value;
                                                                END IF;
                                                        ELSE
                                                                IF p_attr_value = l_value THEN
                                                                        x_attr_value_code := p_attr_value;
                                                                END IF;
                                                        END IF;         --End of Fmt.Has_ID
                                        END IF;

   END IF;

 ELSE

    x_attr_value_code := p_attr_value;
 END IF;

 RETURN x_attr_value_code;


END Get_Attribute_Value;

FUNCTION Get_Item_Validate_Org_Value(p_pricing_attribute  IN VARCHAR2,p_attr_value IN VARCHAR2
					   ) RETURN VARCHAR2 IS

l_name varchar2(240) := 'Y';

BEGIN
	 IF (p_pricing_attribute = 'PRICING_ATTRIBUTE1') then

		select to_char(organization_id)
		into l_name
		from mtl_system_items_b
		where inventory_item_id = to_number(p_attr_value)
		and organization_id = G_ORGANIZATION_ID;

		RETURN l_name;
   ELSE

	 RETURN l_name;

   END IF;

 EXCEPTION

         WHEN OTHERS THEN RETURN 'N';

END Get_Item_Validate_Org_Value;

FUNCTION Get_Segment_Name(p_FlexField_Name IN VARCHAR2
                         ,p_Context_Name   IN VARCHAR2
			 ,p_attribute      IN VARCHAR2
			 ) RETURN VARCHAR2 IS

Flexfield FND_DFLEX.dflex_r;
Flexinfo  FND_DFLEX.dflex_dr;
Contexts  FND_DFLEX.contexts_dr;
segments  FND_DFLEX.segments_dr;
i BINARY_INTEGER;
x_segment_name VARCHAR2(240) := NULL;

l_pte_code            VARCHAR2(30);
l_context_type        VARCHAR2(30);
l_error_code          NUMBER;

CURSOR attribute_cur(a_context_type VARCHAR2, a_context_code VARCHAR2,
                     a_pte_code VARCHAR2, a_attribute VARCHAR2)
IS
  SELECT b.segment_code
  FROM   qp_segments_tl a, qp_segments_b b,
         qp_prc_contexts_b c, qp_pte_segments d
  WHERE  c.prc_context_type = a_context_type
  AND    c.prc_context_code = a_context_code
  AND    c.prc_context_id = b.prc_context_id
  AND    b.segment_mapping_column = a_attribute
  AND    b.segment_id = a.segment_id
  AND    a.language = userenv('LANG')
  AND    b.segment_id = d.segment_id
  AND    d.pte_code = a_pte_code;


BEGIN


  IF QP_UTIL.Attrmgr_Installed = 'Y' THEN

    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

    IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
    END IF;

    QP_UTIL.Get_Context_Type(p_flexfield_name, p_context_name,
                             l_context_type, l_error_code);

    IF l_error_code = 0 THEN

      OPEN  attribute_cur(l_context_type, p_context_name,
                          l_pte_code, p_attribute);

      FETCH attribute_cur INTO x_segment_name;
      CLOSE attribute_cur;

    END IF; --If l_error_code = 0

  ELSE

  /* Added for 2332139 */

   BEGIN
    select end_user_column_name
    INTO x_segment_name
    from FND_DESCR_FLEX_COL_USAGE_VL
    where APPLICATION_ID = 661 and
    DESCRIPTIVE_FLEXFIELD_NAME = p_FlexField_Name and
    DESCRIPTIVE_FLEX_CONTEXT_CODE = p_Context_Name and
    application_column_name = p_attribute and
    enabled_flag='Y';

   EXCEPTION
    WHEN OTHERS THEN
    x_segment_name := NULL;
   END;

/* Commented out for 2332139 */
/*

    FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);
    FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Name),
                           segments,TRUE);

    FOR i IN 1..segments.nsegments LOOP

      IF segments.is_enabled(i)  THEN

	IF segments.application_column_name(i) = p_attribute Then
	  x_segment_name := segments.segment_name(i);
	  EXIT;
        END IF;

      END IF;

    END LOOP;
*/
  END IF; --If qp_util.attrmgr_installed = 'Y'

  RETURN x_segment_name;

END Get_Segment_Name;


FUNCTION Get_Product_Id(p_FlexField_Name IN VARCHAR2
                           ,p_Context_Name   IN VARCHAR2
                           ,p_attribute      IN VARCHAR2
                           ,p_attr_value IN VARCHAR2) RETURN NUMBER IS

l_product_id number := NULL;

BEGIN

   IF p_flexfield_name = 'QP_ATTR_DEFNS_PRICING' THEN

     IF ( p_Context_Name = 'ITEM' and
           (p_attribute in ('PRICING_ATTRIBUTE1', 'PRICING_ATTRIBUTE2') )
        ) then

      l_product_id := TO_NUMBER(p_attr_value);

     END IF;

   END IF;

   RETURN l_product_id;

END Get_Product_Id;



END QP_Price_List_Line_Util;

/
