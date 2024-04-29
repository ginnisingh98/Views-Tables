--------------------------------------------------------
--  DDL for Package Body QP_MODIFIERS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MODIFIERS_UTIL" AS
/* $Header: QPXUMLLB.pls 120.5.12010000.7 2009/08/19 07:22:53 smbalara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Modifiers_Util';

--  Procedure Clear_Dependent_Attr

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   x_MODIFIERS_rec                 OUT NOCOPY QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
l_index                       NUMBER := 0;
l_src_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl                QP_GLOBALS.NUMBER_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Clear_dependent_Attr in QPXUMLLB');

    --  Load out record

    x_MODIFIERS_rec := p_MODIFIERS_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.

    IF p_attr_id = FND_API.G_MISS_NUM THEN

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.arithmetic_operator,p_old_MODIFIERS_rec.arithmetic_operator)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ARITHMETIC_OPERATOR;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute1,p_old_MODIFIERS_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute10,p_old_MODIFIERS_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute11,p_old_MODIFIERS_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute12,p_old_MODIFIERS_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute13,p_old_MODIFIERS_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute14,p_old_MODIFIERS_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute15,p_old_MODIFIERS_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute2,p_old_MODIFIERS_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute3,p_old_MODIFIERS_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute4,p_old_MODIFIERS_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute5,p_old_MODIFIERS_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute6,p_old_MODIFIERS_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute7,p_old_MODIFIERS_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute8,p_old_MODIFIERS_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute9,p_old_MODIFIERS_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.automatic_flag,p_old_MODIFIERS_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_AUTOMATIC;
        END IF;

/*        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.base_qty,p_old_MODIFIERS_rec.base_qty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BASE_QTY;
        END IF;
*/
        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_phase_id,p_old_MODIFIERS_rec.pricing_phase_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICING_PHASE;
        END IF;

/*        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.base_uom_code,p_old_MODIFIERS_rec.base_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BASE_UOM;
        END IF;
*/
        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.comments,p_old_MODIFIERS_rec.comments)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_COMMENTS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.context,p_old_MODIFIERS_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.created_by,p_old_MODIFIERS_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CREATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.creation_date,p_old_MODIFIERS_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.effective_period_uom,p_old_MODIFIERS_rec.effective_period_uom)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EFFECTIVE_PERIOD_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.end_date_active,p_old_MODIFIERS_rec.end_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_END_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.estim_accrual_rate,p_old_MODIFIERS_rec.estim_accrual_rate)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ESTIM_ACCRUAL_RATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.generate_using_formula_id,p_old_MODIFIERS_rec.generate_using_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_GENERATE_USING_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.inventory_item_id,p_old_MODIFIERS_rec.inventory_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INVENTORY_ITEM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_updated_by,p_old_MODIFIERS_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_date,p_old_MODIFIERS_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_login,p_old_MODIFIERS_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_header_id,p_old_MODIFIERS_rec.list_header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_HEADER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_id,p_old_MODIFIERS_rec.list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_type_code,p_old_MODIFIERS_rec.list_line_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_price,p_old_MODIFIERS_rec.list_price)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_PRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.modifier_level_code,p_old_MODIFIERS_rec.modifier_level_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_MODIFIER_LEVEL;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.number_effective_periods,p_old_MODIFIERS_rec.number_effective_periods)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NUMBER_EFFECTIVE_PERIODS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.operand,p_old_MODIFIERS_rec.operand)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_OPERAND;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.organization_id,p_old_MODIFIERS_rec.organization_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ORGANIZATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.override_flag,p_old_MODIFIERS_rec.override_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_OVERRIDE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.percent_price,p_old_MODIFIERS_rec.percent_price)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PERCENT_PRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_break_type_code,p_old_MODIFIERS_rec.price_break_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICE_BREAK_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_by_formula_id,p_old_MODIFIERS_rec.price_by_formula_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICE_BY_FORMULA;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.primary_uom_flag,p_old_MODIFIERS_rec.primary_uom_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRIMARY_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.print_on_invoice_flag,p_old_MODIFIERS_rec.print_on_invoice_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRINT_ON_INVOICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_application_id,p_old_MODIFIERS_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_id,p_old_MODIFIERS_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_update_date,p_old_MODIFIERS_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rebate_trxn_type_code,p_old_MODIFIERS_rec.rebate_trxn_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REBATE_TRANSACTION_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.related_item_id,p_old_MODIFIERS_rec.related_item_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RELATED_ITEM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.relationship_type_id,p_old_MODIFIERS_rec.relationship_type_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RELATIONSHIP_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.reprice_flag,p_old_MODIFIERS_rec.reprice_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REPRICE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.request_id,p_old_MODIFIERS_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REQUEST;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision,p_old_MODIFIERS_rec.revision)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_date,p_old_MODIFIERS_rec.revision_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_reason_code,p_old_MODIFIERS_rec.revision_reason_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION_REASON;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.start_date_active,p_old_MODIFIERS_rec.start_date_active)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_START_DATE_ACTIVE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_attribute,p_old_MODIFIERS_rec.substitution_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_context,p_old_MODIFIERS_rec.substitution_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_CONTEXT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_value,p_old_MODIFIERS_rec.substitution_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accrual_flag,p_old_MODIFIERS_rec.accrual_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ACCRUAL_FLAG;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_group_sequence,p_old_MODIFIERS_rec.pricing_group_sequence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICING_GROUP_SEQUENCE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.incompatibility_grp_code,p_old_MODIFIERS_rec.incompatibility_grp_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INCOMPATIBILITY_GRP_CODE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_no,p_old_MODIFIERS_rec.list_line_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.product_precedence,p_old_MODIFIERS_rec.product_precedence)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRODUCT_PRECEDENCE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_start_date,p_old_MODIFIERS_rec.expiration_period_start_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_PERIOD_START_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.number_expiration_periods,p_old_MODIFIERS_rec.number_expiration_periods)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NUMBER_EXPIRATION_PERIODS;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_uom,p_old_MODIFIERS_rec.expiration_period_uom)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_PERIOD_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_date,p_old_MODIFIERS_rec.expiration_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_DATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.estim_gl_value,p_old_MODIFIERS_rec.estim_gl_value)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ESTIM_GL_VALUE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_price_list_line_id,p_old_MODIFIERS_rec.benefit_price_list_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_PRICE_LIST_LINE;
        END IF;

/*        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.recurring_flag,p_old_MODIFIERS_rec.recurring_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RECURRING_FLAG;
        END IF;
*/
        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_limit,p_old_MODIFIERS_rec.benefit_limit)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_LIMIT;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_type_code,p_old_MODIFIERS_rec.charge_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CHARGE_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_subtype_code,p_old_MODIFIERS_rec.charge_subtype_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CHARGE_SUBTYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_qty,p_old_MODIFIERS_rec.benefit_qty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_QTY;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_uom_code,p_old_MODIFIERS_rec.benefit_uom_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_UOM;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accrual_conversion_rate,p_old_MODIFIERS_rec.accrual_conversion_rate)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ACCRUAL_CONVERSION_RATE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.proration_type_code,p_old_MODIFIERS_rec.proration_type_code)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRORATION_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.include_on_returns_flag,p_old_MODIFIERS_rec.include_on_returns_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INCLUDE_ON_RETURNS_FLAG;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.from_rltd_modifier_id,p_old_MODIFIERS_rec.from_rltd_modifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_FROM_RLTD_MODIFIER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.to_rltd_modifier_id,p_old_MODIFIERS_rec.to_rltd_modifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_TO_RLTD_MODIFIER;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_grp_no,p_old_MODIFIERS_rec.rltd_modifier_grp_no)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_GRP_NO;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_grp_type,p_old_MODIFIERS_rec.rltd_modifier_grp_type)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_GRP_TYPE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_id,p_old_MODIFIERS_rec.rltd_modifier_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_ID;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.qualification_ind,p_old_MODIFIERS_rec.qualification_ind)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_QUALIFICATION_IND;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.net_amount_flag,p_old_MODIFIERS_rec.net_amount_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NET_AMOUNT;
        END IF;
        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accum_attribute,p_old_MODIFIERS_rec.accum_attribute)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ACCUM_ATTRIBUTE;
        END IF;

        IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.continuous_price_break_flag,p_old_MODIFIERS_rec.continuous_price_break_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CONTINUOUS_PRICE_BREAK_FLAG;
        END IF;

    ELSIF p_attr_id = G_ARITHMETIC_OPERATOR THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ARITHMETIC_OPERATOR;
    ELSIF p_attr_id = G_ATTRIBUTE1 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE1;
    ELSIF p_attr_id = G_ATTRIBUTE10 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE10;
    ELSIF p_attr_id = G_ATTRIBUTE11 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE11;
    ELSIF p_attr_id = G_ATTRIBUTE12 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE12;
    ELSIF p_attr_id = G_ATTRIBUTE13 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE13;
    ELSIF p_attr_id = G_ATTRIBUTE14 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE14;
    ELSIF p_attr_id = G_ATTRIBUTE15 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE15;
    ELSIF p_attr_id = G_ATTRIBUTE2 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE2;
    ELSIF p_attr_id = G_ATTRIBUTE3 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE3;
    ELSIF p_attr_id = G_ATTRIBUTE4 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE4;
    ELSIF p_attr_id = G_ATTRIBUTE5 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE5;
    ELSIF p_attr_id = G_ATTRIBUTE6 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE6;
    ELSIF p_attr_id = G_ATTRIBUTE7 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE7;
    ELSIF p_attr_id = G_ATTRIBUTE8 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE8;
    ELSIF p_attr_id = G_ATTRIBUTE9 THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ATTRIBUTE9;
    ELSIF p_attr_id = G_AUTOMATIC THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_AUTOMATIC;
/*    ELSIF p_attr_id = G_BASE_QTY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BASE_QTY;  */
    ELSIF p_attr_id = G_PRICING_PHASE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICING_PHASE;
/*    ELSIF p_attr_id = G_BASE_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BASE_UOM;  */
    ELSIF p_attr_id = G_COMMENTS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_COMMENTS;
    ELSIF p_attr_id = G_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CONTEXT;
    ELSIF p_attr_id = G_CREATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CREATED_BY;
    ELSIF p_attr_id = G_CREATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CREATION_DATE;
    ELSIF p_attr_id = G_EFFECTIVE_PERIOD_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EFFECTIVE_PERIOD_UOM;
    ELSIF p_attr_id = G_END_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_END_DATE_ACTIVE;
    ELSIF p_attr_id = G_ESTIM_ACCRUAL_RATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ESTIM_ACCRUAL_RATE;
    ELSIF p_attr_id = G_GENERATE_USING_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_GENERATE_USING_FORMULA;
--    ELSIF p_attr_id = G_GL_CLASS THEN
--        l_index := l_index + 1;
--        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_GL_CLASS;
    ELSIF p_attr_id = G_INVENTORY_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INVENTORY_ITEM;
    ELSIF p_attr_id = G_LAST_UPDATED_BY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATED_BY;
    ELSIF p_attr_id = G_LAST_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATE_DATE;
    ELSIF p_attr_id = G_LAST_UPDATE_LOGIN THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LAST_UPDATE_LOGIN;
    ELSIF p_attr_id = G_LIST_HEADER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_HEADER;
    ELSIF p_attr_id = G_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE;
    ELSIF p_attr_id = G_LIST_LINE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE_TYPE;
    ELSIF p_attr_id = G_LIST_PRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_PRICE;
--    ELSIF p_attr_id = G_LIST_PRICE_UOM THEN
--        l_index := l_index + 1;
--        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_PRICE_UOM;
    ELSIF p_attr_id = G_MODIFIER_LEVEL THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_MODIFIER_LEVEL;
    ELSIF p_attr_id = G_NUMBER_EFFECTIVE_PERIODS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NUMBER_EFFECTIVE_PERIODS;
    ELSIF p_attr_id = G_OPERAND THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_OPERAND;
    ELSIF p_attr_id = G_ORGANIZATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ORGANIZATION;
    ELSIF p_attr_id = G_OVERRIDE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_OVERRIDE;
    ELSIF p_attr_id = G_PERCENT_PRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PERCENT_PRICE;
    ELSIF p_attr_id = G_PRICE_BREAK_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICE_BREAK_TYPE;
    ELSIF p_attr_id = G_PRICE_BY_FORMULA THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICE_BY_FORMULA;
    ELSIF p_attr_id = G_PRIMARY_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRIMARY_UOM;
    ELSIF p_attr_id = G_PRINT_ON_INVOICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRINT_ON_INVOICE;
    ELSIF p_attr_id = G_PROGRAM_APPLICATION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM_APPLICATION;
    ELSIF p_attr_id = G_PROGRAM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM;
    ELSIF p_attr_id = G_PROGRAM_UPDATE_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PROGRAM_UPDATE_DATE;
--    ELSIF p_attr_id = G_REBATE_SUBTYPE THEN
--        l_index := l_index + 1;
--        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REBATE_SUBTYPE;
    ELSIF p_attr_id = G_REBATE_TRANSACTION_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REBATE_TRANSACTION_TYPE;
    ELSIF p_attr_id = G_RELATED_ITEM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RELATED_ITEM;
    ELSIF p_attr_id = G_RELATIONSHIP_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RELATIONSHIP_TYPE;
    ELSIF p_attr_id = G_REPRICE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REPRICE;
    ELSIF p_attr_id = G_REQUEST THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REQUEST;
    ELSIF p_attr_id = G_REVISION THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION;
    ELSIF p_attr_id = G_REVISION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION_DATE;
    ELSIF p_attr_id = G_REVISION_REASON THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_REVISION_REASON;
    ELSIF p_attr_id = G_START_DATE_ACTIVE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_START_DATE_ACTIVE;
    ELSIF p_attr_id = G_SUBSTITUTION_ATTRIBUTE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_ATTRIBUTE;
    ELSIF p_attr_id = G_SUBSTITUTION_CONTEXT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_CONTEXT;
    ELSIF p_attr_id = G_SUBSTITUTION_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_SUBSTITUTION_VALUE;
    ELSIF p_attr_id = G_ACCRUAL_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ACCRUAL_FLAG;
    ELSIF p_attr_id = G_PRICING_GROUP_SEQUENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRICING_GROUP_SEQUENCE;
    ELSIF p_attr_id = G_INCOMPATIBILITY_GRP_CODE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INCOMPATIBILITY_GRP_CODE;
    ELSIF p_attr_id = G_LIST_LINE_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_LIST_LINE_NO;
    ELSIF p_attr_id = G_PRODUCT_PRECEDENCE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRODUCT_PRECEDENCE;
    ELSIF p_attr_id = G_EXPIRATION_PERIOD_START_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_PERIOD_START_DATE;
    ELSIF p_attr_id = G_NUMBER_EXPIRATION_PERIODS THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NUMBER_EXPIRATION_PERIODS;
    ELSIF p_attr_id = G_EXPIRATION_PERIOD_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_PERIOD_UOM;
    ELSIF p_attr_id = G_EXPIRATION_DATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_EXPIRATION_DATE;
    ELSIF p_attr_id = G_ESTIM_GL_VALUE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ESTIM_GL_VALUE;
    ELSIF p_attr_id = G_BENEFIT_PRICE_LIST_LINE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_PRICE_LIST_LINE;
/*    ELSIF p_attr_id = G_RECURRING_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RECURRING_FLAG;  */
    ELSIF p_attr_id = G_BENEFIT_LIMIT THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_LIMIT;
    ELSIF p_attr_id = G_CHARGE_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CHARGE_TYPE;
    ELSIF p_attr_id = G_CHARGE_SUBTYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_CHARGE_SUBTYPE;
    ELSIF p_attr_id = G_BENEFIT_QTY THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_QTY;
    ELSIF p_attr_id = G_BENEFIT_UOM THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_BENEFIT_UOM;
    ELSIF p_attr_id = G_ACCRUAL_CONVERSION_RATE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_ACCRUAL_CONVERSION_RATE;
    ELSIF p_attr_id = G_PRORATION_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_PRORATION_TYPE;
    ELSIF p_attr_id = G_INCLUDE_ON_RETURNS_FLAG THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_INCLUDE_ON_RETURNS_FLAG;
    ELSIF p_attr_id = G_FROM_RLTD_MODIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_FROM_RLTD_MODIFIER;
    ELSIF p_attr_id = G_TO_RLTD_MODIFIER THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_TO_RLTD_MODIFIER;
    ELSIF p_attr_id = G_RLTD_MODIFIER_GRP_NO THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_GRP_NO;
    ELSIF p_attr_id = G_RLTD_MODIFIER_GRP_TYPE THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_GRP_TYPE;
    ELSIF p_attr_id = G_RLTD_MODIFIER_ID THEN
        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_RLTD_MODIFIER_ID;
    ELSIF p_attr_id = G_NET_AMOUNT THEN
       l_index :=l_index + 1;
       l_src_attr_tbl(l_index) := QP_MODIFIERS_UTIL.G_NET_AMOUNT;
    END IF;

oe_debug_pub.add('END Clear_dependent_Attr in QPXUMLLB');

END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
,   x_MODIFIERS_rec                 OUT NOCOPY QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS

 --added by svdeshmu

l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


 -- end of additions by  svdeshmu

BEGIN

oe_debug_pub.add('BEGIN Apply_Attribute_Changes in QPXUMLLB');

    --  Load out record

    x_MODIFIERS_rec := p_MODIFIERS_rec;

-- mkarya for bug 1874586, log the qualification indicator request before any other delayed requests
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_id,p_old_MODIFIERS_rec.list_line_id)
    THEN
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
             p_entity_id  => p_MODIFIERS_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.arithmetic_operator,p_old_MODIFIERS_rec.arithmetic_operator)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute1,p_old_MODIFIERS_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute10,p_old_MODIFIERS_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute11,p_old_MODIFIERS_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute12,p_old_MODIFIERS_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute13,p_old_MODIFIERS_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute14,p_old_MODIFIERS_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute15,p_old_MODIFIERS_rec.attribute15)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute2,p_old_MODIFIERS_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute3,p_old_MODIFIERS_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute4,p_old_MODIFIERS_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute5,p_old_MODIFIERS_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute6,p_old_MODIFIERS_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute7,p_old_MODIFIERS_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute8,p_old_MODIFIERS_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute9,p_old_MODIFIERS_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.automatic_flag,p_old_MODIFIERS_rec.automatic_flag)
    THEN
        NULL;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.base_qty,p_old_MODIFIERS_rec.base_qty)
    THEN
        NULL;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_phase_id,p_old_MODIFIERS_rec.pricing_phase_id)
    THEN
       -- NULL;
       	-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_UPDATE and p_MODIFIERS_rec.qualification_ind in (8,10) ) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_MODIFIERS_rec.list_line_id,
		p_request_unique_key2 => 'UD',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
        END IF;
       END IF;
      END IF;
    qp_delayed_requests_PVT.log_request(
         p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
            p_entity_id  => p_MODIFIERS_rec.list_line_id,
         p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
        p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
        p_request_type =>QP_GLOBALS.G_UPDATE_PRICING_ATTR_PHASE,
        x_return_status => l_return_status);

                 qp_delayed_requests_PVT.log_request(
                   p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                  p_entity_id  => p_modifiers_rec.list_line_id,
                   p_param1 => p_modifiers_rec.list_header_id,
                   p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                   p_requesting_entity_id => p_modifiers_rec.list_line_id,
                   p_request_type =>QP_GLOBALS.G_MAINTAIN_LIST_HEADER_PHASES,
                   x_return_status => l_return_status);

    --hw
    -- log the changed lines API delayed request for phase change;
    if QP_PERF_PVT.enabled = 'Y' then
    qp_delayed_requests_pvt.log_request(
            p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
            p_entity_id => p_MODIFIERS_rec.list_line_id,
            p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
            p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
            p_request_type => QP_GLOBALS.G_UPDATE_CHANGED_LINES_PH,
            p_param1 => p_MODIFIERS_rec.pricing_phase_id,
            p_param2 => p_old_MODIFIERS_rec.pricing_phase_id,
            x_return_status => l_return_status);
    end if;

    END IF;

/*    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.base_uom_code,p_old_MODIFIERS_rec.base_uom_code)
    THEN
        NULL;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.comments,p_old_MODIFIERS_rec.comments)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.context,p_old_MODIFIERS_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.created_by,p_old_MODIFIERS_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.creation_date,p_old_MODIFIERS_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.effective_period_uom,p_old_MODIFIERS_rec.effective_period_uom)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.end_date_active,p_old_MODIFIERS_rec.end_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.estim_accrual_rate,p_old_MODIFIERS_rec.estim_accrual_rate)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.generate_using_formula_id,p_old_MODIFIERS_rec.generate_using_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.inventory_item_id,p_old_MODIFIERS_rec.inventory_item_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_updated_by,p_old_MODIFIERS_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_date,p_old_MODIFIERS_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_login,p_old_MODIFIERS_rec.last_update_login)
    THEN
        NULL;
    END IF;

--made changes by spgopal per rchellam's request
--qualification_ind has to be updated in delayed request only once, this is duplication to avoid performance problem
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_header_id,p_old_MODIFIERS_rec.list_header_id)
    THEN
   /*
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
             p_entity_id  => p_MODIFIERS_rec.list_header_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LIST_QUAL_IND,
                 x_return_status => l_return_status);
        */
     NULL;
    END IF;

/* mkarya for bug 1874586. Commenting out here and restoring the code at the begining of the procedure Apply_Attribute_Changes so that qualification_ind delayed requests are logged as first request
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_id,p_old_MODIFIERS_rec.list_line_id)
    THEN
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
             p_entity_id  => p_MODIFIERS_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);
    END IF;
*/

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_type_code,p_old_MODIFIERS_rec.list_line_type_code)
    THEN
          --added by svdeshmu


       --hvop

            oe_debug_pub.add('calling log request from QPXUMLLB.pls');
         qp_delayed_requests_PVT.log_request
            (  p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS
             , p_entity_id  => p_MODIFIERS_rec.list_line_id
          --, p_param1    => p_MODIFIERS_rec.list_line_type_code
          , p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS
          , p_requesting_entity_id => p_MODIFIERS_rec.list_line_id
          , p_request_type =>QP_GLOBALS.G_UPDATE_HVOP
             , x_return_status => l_return_status
            );
       --hvop
       if p_MODIFIERS_rec.list_line_type_code in ('PBH' ,'OID' ,'PRG') then

      oe_debug_pub.add('calling log request from QPXUMLLB.pls');
         qp_delayed_requests_PVT.log_request
      (  p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS
       , p_entity_id  => p_MODIFIERS_rec.list_line_id
          , p_param1    => p_MODIFIERS_rec.list_line_type_code
          , p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS
          , p_requesting_entity_id => p_MODIFIERS_rec.list_line_id
          , p_request_type =>QP_GLOBALS.G_VALIDATE_LINES_FOR_CHILD
           , x_return_status => l_return_status
      );

          else
          -- Fix For Bug No - 5251238  This is a latent issue
          begin
            IF  qp_delayed_requests_PVT.Check_for_Request( p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS
                            , p_entity_id    => p_MODIFIERS_rec.list_line_id
                            , p_request_type => QP_GLOBALS.G_VALIDATE_LINES_FOR_CHILD
                            ) THEN
               QP_delayed_requests_pvt.Delete_Request
                   ( p_entity_code   => QP_GLOBALS.G_ENTITY_MODIFIERS
                   , p_entity_id     => p_MODIFIERS_rec.list_line_id
                   , p_request_Type  => QP_GLOBALS.G_VALIDATE_LINES_FOR_CHILD
                   , x_return_status => l_return_status
                   );
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                 END IF;
            END IF;
          end;

       end if;


      if p_MODIFIERS_rec.list_line_type_code = 'PBH'  then

        oe_debug_pub.add('calling log request for overlapping breaks QPXUMLL');
        qp_delayed_requests_PVT.log_request
      ( p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS
      , p_entity_id  => p_MODIFIERS_rec.list_line_id
         , p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_MODIFIERS
         , p_requesting_entity_id => p_MODIFIERS_rec.list_line_id
         , p_request_type =>QP_GLOBALS.G_OVERLAPPING_PRICE_BREAKS
         , x_return_status => l_return_status
       );

   End If;


      --- end of additions by svdeshmu


      NULL;
    END IF;


    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_price,p_old_MODIFIERS_rec.list_price)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.modifier_level_code,p_old_MODIFIERS_rec.modifier_level_code)
    THEN
        NULL;
        -- mkarya for attribute manager
        -- Log a delayed request to validate that if header level qualifier exist then at least
        -- one qualifier should exist for any existence of modifier line of modifier level
        -- 'LINE'/'LINEGROUP' or 'ORDER'
        oe_debug_pub.add('Logging a request G_CHECK_LINE_FOR_HEADER_QUAL for modifier level change');
       -- Bug 2419504, log this request only if attribute manager is installed
       IF qp_util.attrmgr_installed = 'Y' then
        qp_delayed_requests_PVT.log_request(
           p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
       p_entity_id  => p_MODIFIERS_rec.list_header_id,
           p_request_unique_key1 => -1,
           p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_ALL,
           p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
           p_request_type =>QP_GLOBALS.G_CHECK_LINE_FOR_HEADER_QUAL,
           x_return_status => l_return_status);
       END IF;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.number_effective_periods,p_old_MODIFIERS_rec.number_effective_periods)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.operand,p_old_MODIFIERS_rec.operand)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.organization_id,p_old_MODIFIERS_rec.organization_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.override_flag,p_old_MODIFIERS_rec.override_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.percent_price,p_old_MODIFIERS_rec.percent_price)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_break_type_code,p_old_MODIFIERS_rec.price_break_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_by_formula_id,p_old_MODIFIERS_rec.price_by_formula_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.primary_uom_flag,p_old_MODIFIERS_rec.primary_uom_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.print_on_invoice_flag,p_old_MODIFIERS_rec.print_on_invoice_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_application_id,p_old_MODIFIERS_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_id,p_old_MODIFIERS_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.program_update_date,p_old_MODIFIERS_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rebate_trxn_type_code,p_old_MODIFIERS_rec.rebate_trxn_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.related_item_id,p_old_MODIFIERS_rec.related_item_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.relationship_type_id,p_old_MODIFIERS_rec.relationship_type_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.reprice_flag,p_old_MODIFIERS_rec.reprice_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.request_id,p_old_MODIFIERS_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision,p_old_MODIFIERS_rec.revision)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_date,p_old_MODIFIERS_rec.revision_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_reason_code,p_old_MODIFIERS_rec.revision_reason_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.start_date_active,p_old_MODIFIERS_rec.start_date_active)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_attribute,p_old_MODIFIERS_rec.substitution_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_context,p_old_MODIFIERS_rec.substitution_context)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_value,p_old_MODIFIERS_rec.substitution_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accrual_flag,p_old_MODIFIERS_rec.accrual_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_group_sequence,p_old_MODIFIERS_rec.pricing_group_sequence)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.incompatibility_grp_code,p_old_MODIFIERS_rec.incompatibility_grp_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_no,p_old_MODIFIERS_rec.list_line_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.product_precedence,p_old_MODIFIERS_rec.product_precedence)
    THEN
      -- bug 3703391 - update effective_precedence in qp_attribute_groups when no product is given but line qualifier given
      IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' THEN
        IF (p_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_UPDATE and p_MODIFIERS_rec.qualification_ind in (8,10) ) THEN
      qp_delayed_requests_pvt.log_request(
    p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
    p_entity_id => p_MODIFIERS_rec.list_header_id,
    p_request_unique_key1 => p_MODIFIERS_rec.list_line_id,
    p_request_unique_key2 => 'U',
    p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
    p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
    p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
    x_return_status => l_return_status);
        END IF;
      END IF;
      --pattern
-- jagan's PL/SQL pattern
       IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
         IF (p_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_UPDATE and p_MODIFIERS_rec.qualification_ind in (8,10) ) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_MODIFIERS_rec.list_line_id,
		p_request_unique_key2 => 'U',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);
        END IF;
       END IF;
      END IF;
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_start_date,p_old_MODIFIERS_rec.expiration_period_start_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.number_expiration_periods,p_old_MODIFIERS_rec.number_expiration_periods)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_uom,p_old_MODIFIERS_rec.expiration_period_uom)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_date,p_old_MODIFIERS_rec.expiration_date)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.estim_gl_value,p_old_MODIFIERS_rec.estim_gl_value)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_price_list_line_id,p_old_MODIFIERS_rec.benefit_price_list_line_id)
    THEN
        NULL;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.recurring_flag,p_old_MODIFIERS_rec.recurring_flag)
    THEN
        NULL;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_limit,p_old_MODIFIERS_rec.benefit_limit)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_type_code,p_old_MODIFIERS_rec.charge_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_subtype_code,p_old_MODIFIERS_rec.charge_subtype_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_qty,p_old_MODIFIERS_rec.benefit_qty)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_uom_code,p_old_MODIFIERS_rec.benefit_uom_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accrual_conversion_rate,p_old_MODIFIERS_rec.accrual_conversion_rate)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.proration_type_code,p_old_MODIFIERS_rec.proration_type_code)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.include_on_returns_flag,p_old_MODIFIERS_rec.include_on_returns_flag)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.from_rltd_modifier_id,p_old_MODIFIERS_rec.from_rltd_modifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.to_rltd_modifier_id,p_old_MODIFIERS_rec.to_rltd_modifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_grp_no,p_old_MODIFIERS_rec.rltd_modifier_grp_no)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_grp_type,p_old_MODIFIERS_rec.rltd_modifier_grp_type)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rltd_modifier_id,p_old_MODIFIERS_rec.rltd_modifier_id)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.accum_attribute,p_old_MODIFIERS_rec.accum_attribute)
    THEN
        NULL;
    END IF;

    IF NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.continuous_price_break_flag,p_old_MODIFIERS_rec.continuous_price_break_flag)
    THEN
        NULL;
    END IF;

oe_debug_pub.add('END Apply_Attribute_Changes in QPXUMLLB');

END Apply_Attribute_Changes;

--  Function Complete_Record

FUNCTION Complete_Record
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type := p_MODIFIERS_rec;
BEGIN

oe_debug_pub.add('BEGIN Complete_Record in QPXUMLLB');

    IF l_MODIFIERS_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.arithmetic_operator := p_old_MODIFIERS_rec.arithmetic_operator;
    END IF;

    IF l_MODIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute1 := p_old_MODIFIERS_rec.attribute1;
    END IF;

    IF l_MODIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute10 := p_old_MODIFIERS_rec.attribute10;
    END IF;

    IF l_MODIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute11 := p_old_MODIFIERS_rec.attribute11;
    END IF;

    IF l_MODIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute12 := p_old_MODIFIERS_rec.attribute12;
    END IF;

    IF l_MODIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute13 := p_old_MODIFIERS_rec.attribute13;
    END IF;

    IF l_MODIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute14 := p_old_MODIFIERS_rec.attribute14;
    END IF;

    IF l_MODIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute15 := p_old_MODIFIERS_rec.attribute15;
    END IF;

    IF l_MODIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute2 := p_old_MODIFIERS_rec.attribute2;
    END IF;

    IF l_MODIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute3 := p_old_MODIFIERS_rec.attribute3;
    END IF;

    IF l_MODIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute4 := p_old_MODIFIERS_rec.attribute4;
    END IF;

    IF l_MODIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute5 := p_old_MODIFIERS_rec.attribute5;
    END IF;

    IF l_MODIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute6 := p_old_MODIFIERS_rec.attribute6;
    END IF;

    IF l_MODIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute7 := p_old_MODIFIERS_rec.attribute7;
    END IF;

    IF l_MODIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute8 := p_old_MODIFIERS_rec.attribute8;
    END IF;

    IF l_MODIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute9 := p_old_MODIFIERS_rec.attribute9;
    END IF;

    IF l_MODIFIERS_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.automatic_flag := p_old_MODIFIERS_rec.automatic_flag;
    END IF;

/*    IF l_MODIFIERS_rec.base_qty = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.base_qty := p_old_MODIFIERS_rec.base_qty;
    END IF;
*/
    IF l_MODIFIERS_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.pricing_phase_id := p_old_MODIFIERS_rec.pricing_phase_id;
    END IF;

/*    IF l_MODIFIERS_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.base_uom_code := p_old_MODIFIERS_rec.base_uom_code;
    END IF;
*/
    IF l_MODIFIERS_rec.comments = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.comments := p_old_MODIFIERS_rec.comments;
    END IF;

    IF l_MODIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.context := p_old_MODIFIERS_rec.context;
    END IF;

    IF l_MODIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.created_by := p_old_MODIFIERS_rec.created_by;
    END IF;

    IF l_MODIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.creation_date := p_old_MODIFIERS_rec.creation_date;
    END IF;

    IF l_MODIFIERS_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.effective_period_uom := p_old_MODIFIERS_rec.effective_period_uom;
    END IF;

    IF l_MODIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.end_date_active := p_old_MODIFIERS_rec.end_date_active;
    END IF;

    IF l_MODIFIERS_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.estim_accrual_rate := p_old_MODIFIERS_rec.estim_accrual_rate;
    END IF;

    IF l_MODIFIERS_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.generate_using_formula_id := p_old_MODIFIERS_rec.generate_using_formula_id;
    END IF;

    IF l_MODIFIERS_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.inventory_item_id := p_old_MODIFIERS_rec.inventory_item_id;
    END IF;

    IF l_MODIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.last_updated_by := p_old_MODIFIERS_rec.last_updated_by;
    END IF;

    IF l_MODIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.last_update_date := p_old_MODIFIERS_rec.last_update_date;
    END IF;

    IF l_MODIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.last_update_login := p_old_MODIFIERS_rec.last_update_login;
    END IF;

    IF l_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_header_id := p_old_MODIFIERS_rec.list_header_id;
    END IF;

    IF l_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_line_id := p_old_MODIFIERS_rec.list_line_id;
    END IF;

    IF l_MODIFIERS_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.list_line_type_code := p_old_MODIFIERS_rec.list_line_type_code;
    END IF;

    IF l_MODIFIERS_rec.list_price = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_price := p_old_MODIFIERS_rec.list_price;
    END IF;

    IF l_MODIFIERS_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.modifier_level_code := p_old_MODIFIERS_rec.modifier_level_code;
    END IF;

    IF l_MODIFIERS_rec.number_effective_periods = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.number_effective_periods := p_old_MODIFIERS_rec.number_effective_periods;
    END IF;

    IF l_MODIFIERS_rec.operand = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.operand := p_old_MODIFIERS_rec.operand;
    END IF;

    IF l_MODIFIERS_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.organization_id := p_old_MODIFIERS_rec.organization_id;
    END IF;

    IF l_MODIFIERS_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.override_flag := p_old_MODIFIERS_rec.override_flag;
    END IF;

    IF l_MODIFIERS_rec.percent_price = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.percent_price := p_old_MODIFIERS_rec.percent_price;
    END IF;

    IF l_MODIFIERS_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.price_break_type_code := p_old_MODIFIERS_rec.price_break_type_code;
    END IF;

    IF l_MODIFIERS_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.price_by_formula_id := p_old_MODIFIERS_rec.price_by_formula_id;
    END IF;

    IF l_MODIFIERS_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.primary_uom_flag := p_old_MODIFIERS_rec.primary_uom_flag;
    END IF;

    IF l_MODIFIERS_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.print_on_invoice_flag := p_old_MODIFIERS_rec.print_on_invoice_flag;
    END IF;

    IF l_MODIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.program_application_id := p_old_MODIFIERS_rec.program_application_id;
    END IF;

    IF l_MODIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.program_id := p_old_MODIFIERS_rec.program_id;
    END IF;

    IF l_MODIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.program_update_date := p_old_MODIFIERS_rec.program_update_date;
    END IF;

    IF l_MODIFIERS_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.rebate_trxn_type_code := p_old_MODIFIERS_rec.rebate_trxn_type_code;
    END IF;

    IF l_MODIFIERS_rec.related_item_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.related_item_id := p_old_MODIFIERS_rec.related_item_id;
    END IF;

    IF l_MODIFIERS_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.relationship_type_id := p_old_MODIFIERS_rec.relationship_type_id;
    END IF;

    IF l_MODIFIERS_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.reprice_flag := p_old_MODIFIERS_rec.reprice_flag;
    END IF;

    IF l_MODIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.request_id := p_old_MODIFIERS_rec.request_id;
    END IF;

    IF l_MODIFIERS_rec.revision = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.revision := p_old_MODIFIERS_rec.revision;
    END IF;

    IF l_MODIFIERS_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.revision_date := p_old_MODIFIERS_rec.revision_date;
    END IF;

    IF l_MODIFIERS_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.revision_reason_code := p_old_MODIFIERS_rec.revision_reason_code;
    END IF;

    IF l_MODIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.start_date_active := p_old_MODIFIERS_rec.start_date_active;
    END IF;

    IF l_MODIFIERS_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_attribute := p_old_MODIFIERS_rec.substitution_attribute;
    END IF;

    IF l_MODIFIERS_rec.substitution_context = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_context := p_old_MODIFIERS_rec.substitution_context;
    END IF;

    IF l_MODIFIERS_rec.substitution_value = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_value := p_old_MODIFIERS_rec.substitution_value;
    END IF;

    IF l_MODIFIERS_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.accrual_flag := p_old_MODIFIERS_rec.accrual_flag;
    END IF;

    IF l_MODIFIERS_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.pricing_group_sequence := p_old_MODIFIERS_rec.pricing_group_sequence;
    END IF;

    IF l_MODIFIERS_rec.incompatibility_grp_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.incompatibility_grp_code := p_old_MODIFIERS_rec.incompatibility_grp_code;
    END IF;

    IF l_MODIFIERS_rec.list_line_no = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.list_line_no := p_old_MODIFIERS_rec.list_line_no;
    END IF;

    IF l_MODIFIERS_rec.product_precedence = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.product_precedence := p_old_MODIFIERS_rec.product_precedence;
    END IF;

    IF l_MODIFIERS_rec.expiration_period_start_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.expiration_period_start_date := p_old_MODIFIERS_rec.expiration_period_start_date;
    END IF;

    IF l_MODIFIERS_rec.number_expiration_periods = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.number_expiration_periods := p_old_MODIFIERS_rec.number_expiration_periods;
    END IF;

    IF l_MODIFIERS_rec.expiration_period_uom = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.expiration_period_uom := p_old_MODIFIERS_rec.expiration_period_uom;
    END IF;

    IF l_MODIFIERS_rec.expiration_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.expiration_date := p_old_MODIFIERS_rec.expiration_date;
    END IF;

    IF l_MODIFIERS_rec.estim_gl_value = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.estim_gl_value := p_old_MODIFIERS_rec.estim_gl_value;
    END IF;

    IF l_MODIFIERS_rec.benefit_price_list_line_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_price_list_line_id := p_old_MODIFIERS_rec.benefit_price_list_line_id;
    END IF;

/*    IF l_MODIFIERS_rec.recurring_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.recurring_flag := p_old_MODIFIERS_rec.recurring_flag;
    END IF;
*/
    IF l_MODIFIERS_rec.benefit_limit = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_limit := p_old_MODIFIERS_rec.benefit_limit;
    END IF;

    IF l_MODIFIERS_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.charge_type_code := p_old_MODIFIERS_rec.charge_type_code;
    END IF;

    IF l_MODIFIERS_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.charge_subtype_code := p_old_MODIFIERS_rec.charge_subtype_code;
    END IF;

    IF l_MODIFIERS_rec.benefit_qty = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_qty := p_old_MODIFIERS_rec.benefit_qty;
    END IF;

    IF l_MODIFIERS_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.benefit_uom_code := p_old_MODIFIERS_rec.benefit_uom_code;
    END IF;

    IF l_MODIFIERS_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.accrual_conversion_rate := p_old_MODIFIERS_rec.accrual_conversion_rate;
    END IF;

    IF l_MODIFIERS_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.proration_type_code := p_old_MODIFIERS_rec.proration_type_code;
    END IF;

    IF l_MODIFIERS_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.include_on_returns_flag := p_old_MODIFIERS_rec.include_on_returns_flag;
    END IF;

    IF l_MODIFIERS_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.from_rltd_modifier_id := p_old_MODIFIERS_rec.from_rltd_modifier_id;
    END IF;

    IF l_MODIFIERS_rec.to_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.to_rltd_modifier_id := p_old_MODIFIERS_rec.to_rltd_modifier_id;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_grp_no = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.rltd_modifier_grp_no := p_old_MODIFIERS_rec.rltd_modifier_grp_no;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_grp_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.rltd_modifier_grp_type := p_old_MODIFIERS_rec.rltd_modifier_grp_type;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.rltd_modifier_id := p_old_MODIFIERS_rec.rltd_modifier_id;
    END IF;

    IF l_MODIFIERS_rec.qualification_ind = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.qualification_ind := p_old_MODIFIERS_rec.qualification_ind;
    END IF;

    IF l_MODIFIERS_rec.accum_attribute = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.accum_attribute := p_old_MODIFIERS_rec.accum_attribute;
    END IF;

    IF l_MODIFIERS_rec.net_amount_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.net_amount_flag := p_old_MODIFIERS_rec.net_amount_flag;
    END IF;

    IF l_MODIFIERS_rec.continuous_price_break_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.continuous_price_break_flag := p_old_MODIFIERS_rec.continuous_price_break_flag;
    END IF;

oe_debug_pub.add('END Complete_Record in QPXUMLLB');

    RETURN l_MODIFIERS_rec;

END Complete_Record;

--  Function Convert_Miss_To_Null

FUNCTION Convert_Miss_To_Null
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type := p_MODIFIERS_rec;
BEGIN

oe_debug_pub.add('BEGIN Convert_Miss_To_Null in QPXUMLLB');

    IF l_MODIFIERS_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.arithmetic_operator := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute1 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute10 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute11 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute12 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute13 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute14 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute15 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute2 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute3 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute4 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute5 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute6 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute7 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute8 := NULL;
    END IF;

    IF l_MODIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.attribute9 := NULL;
    END IF;

    IF l_MODIFIERS_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.automatic_flag := NULL;
    END IF;

/*    IF l_MODIFIERS_rec.base_qty = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.base_qty := NULL;
    END IF;
*/
    IF l_MODIFIERS_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.pricing_phase_id := NULL;
    END IF;

/*    IF l_MODIFIERS_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.base_uom_code := NULL;
    END IF;
*/
    IF l_MODIFIERS_rec.comments = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.comments := NULL;
    END IF;

    IF l_MODIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.context := NULL;
    END IF;

    IF l_MODIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.created_by := NULL;
    END IF;

    IF l_MODIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.creation_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.effective_period_uom = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.effective_period_uom := NULL;
    END IF;

    IF l_MODIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.end_date_active := NULL;
    END IF;

    IF l_MODIFIERS_rec.estim_accrual_rate = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.estim_accrual_rate := NULL;
    END IF;

    IF l_MODIFIERS_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.generate_using_formula_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.inventory_item_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.last_updated_by := NULL;
    END IF;

    IF l_MODIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.last_update_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.last_update_login := NULL;
    END IF;

    IF l_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_header_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_line_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.list_line_type_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.list_price = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.list_price := NULL;
    END IF;

    IF l_MODIFIERS_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.modifier_level_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.number_effective_periods = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.number_effective_periods := NULL;
    END IF;

    IF l_MODIFIERS_rec.operand = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.operand := NULL;
    END IF;

    IF l_MODIFIERS_rec.organization_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.organization_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.override_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.override_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.percent_price = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.percent_price := NULL;
    END IF;

    IF l_MODIFIERS_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.price_break_type_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.price_by_formula_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.primary_uom_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.print_on_invoice_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.program_application_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.program_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.program_update_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.rebate_trxn_type_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.related_item_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.related_item_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.relationship_type_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.reprice_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.request_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.revision = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.revision := NULL;
    END IF;

    IF l_MODIFIERS_rec.revision_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.revision_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.revision_reason_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.start_date_active := NULL;
    END IF;

    IF l_MODIFIERS_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_attribute := NULL;
    END IF;

    IF l_MODIFIERS_rec.substitution_context = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_context := NULL;
    END IF;

    IF l_MODIFIERS_rec.substitution_value = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.substitution_value := NULL;
    END IF;

    IF l_MODIFIERS_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.accrual_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.pricing_group_sequence := NULL;
    END IF;

    IF l_MODIFIERS_rec.incompatibility_grp_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.incompatibility_grp_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.list_line_no = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.list_line_no := NULL;
    END IF;

    IF l_MODIFIERS_rec.product_precedence = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.product_precedence := NULL;
    END IF;

    IF l_MODIFIERS_rec.expiration_period_start_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.expiration_period_start_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.number_expiration_periods = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.number_expiration_periods := NULL;
    END IF;

    IF l_MODIFIERS_rec.expiration_period_uom = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.expiration_period_uom := NULL;
    END IF;

    IF l_MODIFIERS_rec.expiration_date = FND_API.G_MISS_DATE THEN
        l_MODIFIERS_rec.expiration_date := NULL;
    END IF;

    IF l_MODIFIERS_rec.estim_gl_value = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.estim_gl_value := NULL;
    END IF;

    IF l_MODIFIERS_rec.benefit_price_list_line_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_price_list_line_id := NULL;
    END IF;

/*    IF l_MODIFIERS_rec.recurring_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.recurring_flag := NULL;
    END IF;
*/
    IF l_MODIFIERS_rec.benefit_limit = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_limit := NULL;
    END IF;

    IF l_MODIFIERS_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.charge_type_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.charge_subtype_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.benefit_qty = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.benefit_qty := NULL;
    END IF;

    IF l_MODIFIERS_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.benefit_uom_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.accrual_conversion_rate := NULL;
    END IF;

    IF l_MODIFIERS_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.proration_type_code := NULL;
    END IF;

    IF l_MODIFIERS_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.include_on_returns_flag := NULL;
    END IF;

    IF l_MODIFIERS_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.from_rltd_modifier_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.to_rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.to_rltd_modifier_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_grp_no = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.rltd_modifier_grp_no := NULL;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_grp_type = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.rltd_modifier_grp_type := NULL;
    END IF;

    IF l_MODIFIERS_rec.rltd_modifier_id = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.rltd_modifier_id := NULL;
    END IF;

    IF l_MODIFIERS_rec.qualification_ind = FND_API.G_MISS_NUM THEN
        l_MODIFIERS_rec.qualification_ind := NULL;
    END IF;

    IF l_MODIFIERS_rec.accum_attribute = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.accum_attribute := NULL;
    END IF;

    IF l_MODIFIERS_rec.continuous_price_break_flag = FND_API.G_MISS_CHAR THEN
        l_MODIFIERS_rec.continuous_price_break_flag := NULL;
    END IF;

oe_debug_pub.add('END Complete_Record in QPXUMLLB');
oe_debug_pub.add('END Convert_Miss_To_Null in QPXUMLLB');

    RETURN l_MODIFIERS_rec;

END Convert_Miss_To_Null;

---------------------------------------------------------------------------

--PRIVATE PROCEDURE TO UPDATE CHILD LINES OF OID, PRG AND PBH

---------------------------------------------------------------------------

PROCEDURE UPDATE_CHILD_LINES(p_MODIFIERS_rec IN
        QP_MODIFIERS_PUB.Modifiers_rec_type) IS

l_status  NUMBER;
l_modifier_grp_type varchar2(30) := 'NOVAL';
l_list_line_id NUMBER;
l_list_line_type_code VARCHAR2(30);
l_MODIFIERS_rec QP_LIST_LINES%rowtype;

Cursor C_child_records(l_list_line_id  number) IS
         SELECT *
         FROM   QP_LIST_LINES qll
         WHERE qll.list_line_id IN
         (select to_rltd_modifier_id from
          qp_rltd_modifiers qrm where
          from_rltd_modifier_id = l_list_line_id);

BEGIN

oe_debug_pub.add('begin update child lines');

  l_list_line_id := p_Modifiers_rec.list_line_id;

  IF p_MODIFIERS_rec.list_line_type_code = 'PBH' THEN

    l_modifier_grp_type := 'PRICE BREAK';

  --updating all child break lines

      open C_child_records(l_list_line_id); LOOP
      fetch C_child_records into l_MODIFIERS_rec;

      EXIT WHEN C_child_records%NOTFOUND;


  oe_debug_pub.add('update child lines'||to_char(p_MODIFIERS_rec.list_line_id));

--fix for bug 1407684 unique index on list_line_no
      update qp_list_lines set
    -- list_line_no     = p_MODIFIERS_rec.list_line_no
        modifier_level_code   = p_MODIFIERS_rec.modifier_level_code
        ,automatic_flag   = p_MODIFIERS_rec.automatic_flag
        ,override_flag    = p_MODIFIERS_rec.override_flag
        ,Print_on_invoice_flag  = p_MODIFIERS_rec.Print_on_invoice_flag
        ,price_break_type_code  = p_MODIFIERS_rec.price_break_type_code
        ,Proration_type_code  = p_MODIFIERS_rec.Proration_type_code
        ,Incompatibility_Grp_code= p_MODIFIERS_rec.Incompatibility_Grp_code
        ,Pricing_phase_id   = p_MODIFIERS_rec.Pricing_phase_id
        ,Pricing_group_sequence = p_MODIFIERS_rec.Pricing_group_sequence
        ,accrual_flag     = p_MODIFIERS_rec.accrual_flag
        ,estim_accrual_rate   = p_MODIFIERS_rec.estim_accrual_rate
        ,rebate_transaction_type_code = p_MODIFIERS_rec.rebate_trxn_type_code
        ,expiration_date  = p_MODIFIERS_rec.expiration_date
        ,expiration_period_start_date = p_MODIFIERS_rec.expiration_period_start_date
        ,expiration_period_uom  = p_MODIFIERS_rec.expiration_period_uom
        ,number_expiration_periods  = p_MODIFIERS_rec.number_expiration_periods

        where list_line_id  = l_MODIFIERS_rec.list_line_id;

        END LOOP;

      close C_child_records;

  ELSIF p_MODIFIERS_rec.list_line_type_code  IN ( 'OID','PRG') THEN

--    l_modifier_grp_type := '('BENEFIT', 'QUALIFIER')';

  oe_debug_pub.add('update child lines'||to_char(p_MODIFIERS_rec.list_line_id));


  --update OID child records

      open C_child_records(l_list_line_id); LOOP
      fetch C_child_records into l_MODIFIERS_rec;

      EXIT WHEN C_child_records%NOTFOUND;

      --get or related records


--fix for bug 1407684 unique index on list_line_no
      update qp_list_lines set
    --  list_line_no  = p_MODIFIERS_rec.list_line_no
          modifier_level_code   = p_MODIFIERS_rec.modifier_level_code
          ,automatic_flag     = p_MODIFIERS_rec.automatic_flag
          ,override_flag    = p_MODIFIERS_rec.override_flag
          ,Print_on_invoice_flag  = p_MODIFIERS_rec.Print_on_invoice_flag
      --    ,price_break_type_code  = p_MODIFIERS_rec.price_break_type_code --2749159
          ,Proration_type_code  = p_MODIFIERS_rec.Proration_type_code
          ,Incompatibility_Grp_code= p_MODIFIERS_rec.Incompatibility_Grp_code
          ,Pricing_phase_id     = p_MODIFIERS_rec.Pricing_phase_id
          ,Pricing_group_sequence   = p_MODIFIERS_rec.Pricing_group_sequence
          ,accrual_flag       = p_MODIFIERS_rec.accrual_flag
          ,estim_accrual_rate   = p_MODIFIERS_rec.estim_accrual_rate
          ,rebate_transaction_type_code = p_MODIFIERS_rec.rebate_trxn_type_code
          ,expiration_date      = p_MODIFIERS_rec.expiration_date
          ,expiration_period_start_date = p_MODIFIERS_rec.expiration_period_start_date
          ,expiration_period_uom    = p_MODIFIERS_rec.expiration_period_uom
          ,number_expiration_periods  = p_MODIFIERS_rec.number_expiration_periods

          where list_line_id = l_MODIFIERS_rec.list_line_id;





        END LOOP;

      close C_child_records;


  ELSE

  null;

  END IF;

oe_debug_pub.add('end update child lines');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Child_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
oe_debug_pub.add('exp update child lines');

END UPDATE_CHILD_LINES;





---------------------------------------------------------------------------

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
v_accum_context VARCHAR2(30) := NULL;
v_accum_flag VARCHAR2(1) := NULL;
l_pte_code   VARCHAR2(30);
l_sourcing_method VARCHAR2(30);
l_check_active_flag     VARCHAR2(1); /* Accumulation */
l_active_flag           VARCHAR2(1); /* Accumulation */
BEGIN

oe_debug_pub.add('BEGIN Update_Row in QPXUMLLB');
   IF (p_MODIFIERS_rec.accum_attribute IS NOT NULL  AND
  p_MODIFIERS_rec.accum_attribute <> FND_API.G_MISS_CHAR) THEN
     v_accum_context := 'VOLUME';

     BEGIN
  l_pte_code:=nvl(fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY'), 'ORDFUL');

    SELECT  nvl(seeded_sourcing_method, user_sourcing_method)
      INTO l_sourcing_method
      FROM qp_pte_segments ps, qp_segments_b s, qp_prc_contexts_b c
     WHERE        c.prc_context_code = 'VOLUME'
       AND        c.prc_context_type = 'PRICING_ATTRIBUTE'
       AND        c.prc_context_id = s.prc_context_id
       AND        s.segment_mapping_column = p_MODIFIERS_rec.accum_attribute
       AND        s.segment_id = ps.segment_id
       AND        ps.pte_code = l_pte_code;
     EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
     END;

     IF l_sourcing_method = 'RUNTIME SOURCED' THEN
  v_accum_flag := 'Y';
     ELSE
  v_accum_flag := 'N';
     END IF;
  END IF;

   /* Accumulation Start */
   BEGIN
       SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B a,QP_LIST_LINES b
       WHERE  b.list_line_id=p_MODIFIERS_rec.list_line_id
       AND    b.LIST_HEADER_ID = a.list_header_id;
     EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
     END;
   /* Accumulation End */


    UPDATE  QP_LIST_LINES
    SET     ARITHMETIC_OPERATOR            = p_MODIFIERS_rec.arithmetic_operator
    ,       ATTRIBUTE1                     = p_MODIFIERS_rec.attribute1
    ,       ATTRIBUTE10                    = p_MODIFIERS_rec.attribute10
    ,       ATTRIBUTE11                    = p_MODIFIERS_rec.attribute11
    ,       ATTRIBUTE12                    = p_MODIFIERS_rec.attribute12
    ,       ATTRIBUTE13                    = p_MODIFIERS_rec.attribute13
    ,       ATTRIBUTE14                    = p_MODIFIERS_rec.attribute14
    ,       ATTRIBUTE15                    = p_MODIFIERS_rec.attribute15
    ,       ATTRIBUTE2                     = p_MODIFIERS_rec.attribute2
    ,       ATTRIBUTE3                     = p_MODIFIERS_rec.attribute3
    ,       ATTRIBUTE4                     = p_MODIFIERS_rec.attribute4
    ,       ATTRIBUTE5                     = p_MODIFIERS_rec.attribute5
    ,       ATTRIBUTE6                     = p_MODIFIERS_rec.attribute6
    ,       ATTRIBUTE7                     = p_MODIFIERS_rec.attribute7
    ,       ATTRIBUTE8                     = p_MODIFIERS_rec.attribute8
    ,       ATTRIBUTE9                     = p_MODIFIERS_rec.attribute9
    ,       AUTOMATIC_FLAG                 = p_MODIFIERS_rec.automatic_flag
--    ,       BASE_QTY                       = p_MODIFIERS_rec.base_qty
    ,       PRICING_PHASE_ID               = p_MODIFIERS_rec.pricing_phase_id
--    ,       BASE_UOM_CODE                  = p_MODIFIERS_rec.base_uom_code
    ,       COMMENTS                       = p_MODIFIERS_rec.comments
    ,       CONTEXT                        = p_MODIFIERS_rec.context
    ,       CREATED_BY                     = p_MODIFIERS_rec.created_by
    ,       CREATION_DATE                  = p_MODIFIERS_rec.creation_date
    ,       EFFECTIVE_PERIOD_UOM           = p_MODIFIERS_rec.effective_period_uom
    ,       END_DATE_ACTIVE                = p_MODIFIERS_rec.end_date_active
    ,       ESTIM_ACCRUAL_RATE             = p_MODIFIERS_rec.estim_accrual_rate
    ,       GENERATE_USING_FORMULA_ID      = p_MODIFIERS_rec.generate_using_formula_id
    ,       INVENTORY_ITEM_ID              = p_MODIFIERS_rec.inventory_item_id
    ,       LAST_UPDATED_BY                = p_MODIFIERS_rec.last_updated_by
    ,       LAST_UPDATE_DATE               = p_MODIFIERS_rec.last_update_date
    ,       LAST_UPDATE_LOGIN              = p_MODIFIERS_rec.last_update_login
    ,       LIST_HEADER_ID                 = p_MODIFIERS_rec.list_header_id
    ,       LIST_LINE_ID                   = p_MODIFIERS_rec.list_line_id
    ,       LIST_LINE_TYPE_CODE            = p_MODIFIERS_rec.list_line_type_code
    ,       LIST_PRICE                     = p_MODIFIERS_rec.list_price
    ,       MODIFIER_LEVEL_CODE            = p_MODIFIERS_rec.modifier_level_code
    ,       NUMBER_EFFECTIVE_PERIODS       = p_MODIFIERS_rec.number_effective_periods
    ,       OPERAND                        = p_MODIFIERS_rec.operand
    ,       ORGANIZATION_ID                = p_MODIFIERS_rec.organization_id
    ,       OVERRIDE_FLAG                  = p_MODIFIERS_rec.override_flag
    ,       PERCENT_PRICE                  = p_MODIFIERS_rec.percent_price
    ,       PRICE_BREAK_TYPE_CODE          = p_MODIFIERS_rec.price_break_type_code
    ,       PRICE_BY_FORMULA_ID            = p_MODIFIERS_rec.price_by_formula_id
    ,       PRIMARY_UOM_FLAG               = p_MODIFIERS_rec.primary_uom_flag
    ,       PRINT_ON_INVOICE_FLAG          = p_MODIFIERS_rec.print_on_invoice_flag
    ,       PROGRAM_APPLICATION_ID         = p_MODIFIERS_rec.program_application_id
    ,       PROGRAM_ID                     = p_MODIFIERS_rec.program_id
    ,       PROGRAM_UPDATE_DATE            = p_MODIFIERS_rec.program_update_date
    ,       REBATE_TRANSACTION_TYPE_CODE   = p_MODIFIERS_rec.rebate_trxn_type_code
    ,       RELATED_ITEM_ID                = p_MODIFIERS_rec.related_item_id
    ,       RELATIONSHIP_TYPE_ID           = p_MODIFIERS_rec.relationship_type_id
    ,       REPRICE_FLAG                   = p_MODIFIERS_rec.reprice_flag
    ,       REQUEST_ID                     = p_MODIFIERS_rec.request_id
    ,       REVISION                       = p_MODIFIERS_rec.revision
    ,       REVISION_DATE                  = p_MODIFIERS_rec.revision_date
    ,       REVISION_REASON_CODE           = p_MODIFIERS_rec.revision_reason_code
    ,       START_DATE_ACTIVE              = p_MODIFIERS_rec.start_date_active
    ,       SUBSTITUTION_ATTRIBUTE         = p_MODIFIERS_rec.substitution_attribute
    ,       SUBSTITUTION_CONTEXT           = p_MODIFIERS_rec.substitution_context
    ,       SUBSTITUTION_VALUE             = p_MODIFIERS_rec.substitution_value
    ,       ACCRUAL_FLAG                   = p_MODIFIERS_rec.accrual_flag
    ,       PRICING_GROUP_SEQUENCE         = p_MODIFIERS_rec.pricing_group_sequence
    ,       INCOMPATIBILITY_GRP_CODE       = p_MODIFIERS_rec.incompatibility_grp_code
    ,       LIST_LINE_NO                   = p_MODIFIERS_rec.list_line_no
    ,       PRODUCT_PRECEDENCE             = p_MODIFIERS_rec.product_precedence
    ,       EXPIRATION_PERIOD_START_DATE   = p_MODIFIERS_rec.expiration_period_start_date
    ,       NUMBER_EXPIRATION_PERIODS      = p_MODIFIERS_rec.number_expiration_periods
    ,       EXPIRATION_PERIOD_UOM          = p_MODIFIERS_rec.expiration_period_uom
    ,       EXPIRATION_DATE                = p_MODIFIERS_rec.expiration_date
    ,       ESTIM_GL_VALUE                 = p_MODIFIERS_rec.estim_gl_value
    ,       BENEFIT_PRICE_LIST_LINE_ID     = p_MODIFIERS_rec.benefit_price_list_line_id
--    ,       RECURRING_FLAG                 = p_MODIFIERS_rec.recurring_flag
    ,       BENEFIT_LIMIT                  = p_MODIFIERS_rec.benefit_limit
    ,       CHARGE_TYPE_CODE               = p_MODIFIERS_rec.charge_type_code
    ,       CHARGE_SUBTYPE_CODE            = p_MODIFIERS_rec.charge_subtype_code
    ,       BENEFIT_QTY                    = p_MODIFIERS_rec.benefit_qty
    ,       BENEFIT_UOM_CODE               = p_MODIFIERS_rec.benefit_uom_code
    ,       ACCRUAL_CONVERSION_RATE        = p_MODIFIERS_rec.accrual_conversion_rate
    ,       PRORATION_TYPE_CODE            = p_MODIFIERS_rec.proration_type_code
    ,       INCLUDE_ON_RETURNS_FLAG        = p_MODIFIERS_rec.include_on_returns_flag
    ,       QUALIFICATION_IND              = p_MODIFIERS_rec.qualification_ind
    ,       NET_AMOUNT_FLAG                = p_MODIFIERS_rec.net_amount_flag
    ,       ACCUM_ATTRIBUTE                = p_MODIFIERS_rec.accum_attribute
    ,       ACCUM_CONTEXT                  = v_accum_context
    ,       ACCUM_ATTR_RUN_SRC_FLAG        = v_accum_flag
    ,       CONTINUOUS_PRICE_BREAK_FLAG        = p_MODIFIERS_rec.continuous_price_break_flag
    WHERE   LIST_LINE_ID = p_MODIFIERS_rec.list_line_id
    ;


    if p_Modifiers_rec.list_line_type_code in ('PBH', 'OID', 'PRG') then
    --update child lines
  oe_debug_pub.add('start update child'||p_modifiers_rec.list_line_type_code);
  update_child_lines(p_Modifiers_rec);
  oe_debug_pub.add('end update child'||p_modifiers_rec.list_line_type_code);

    else

  null;
    end if;

   /* Accumulation Start */
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(v_accum_context IS NOT NULL) AND
   (p_MODIFIERS_rec.accum_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_MODIFIERS_rec.accum_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
       AND    b.prc_context_code=v_accum_context);

 END IF;
END IF;
   /* Accumulation End */

oe_debug_pub.add('END Update_Row in QPXUMLLB');

EXCEPTION

  WHEN DUP_VAL_ON_INDEX THEN

  FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MODIFIER_NUMBER');
  OE_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
l_return_status   VARCHAR2(30);
l_gsa_indicator   VARCHAR2(1);
v_accum_context VARCHAR2(30) := NULL;
v_accum_flag VARCHAR2(1) := NULL;
l_pte_code   VARCHAR2(30);
l_sourcing_method VARCHAR2(30);
l_check_active_flag     VARCHAR2(1); /* Accumulation */
l_active_flag           VARCHAR2(1); /* Accumulation */
BEGIN

oe_debug_pub.add('BEGIN Insert_Row in QPXUMLLB'||p_MODIFIERS_rec.list_line_type_code);

   IF (p_MODIFIERS_rec.accum_attribute IS NOT NULL AND
  p_MODIFIERS_rec.accum_attribute <> FND_API.G_MISS_CHAR) THEN
     v_accum_context := 'VOLUME';

     BEGIN
  l_pte_code:=nvl(fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY'), 'ORDFUL');

    SELECT  nvl(seeded_sourcing_method, user_sourcing_method)
      INTO l_sourcing_method
      FROM qp_pte_segments ps, qp_segments_b s, qp_prc_contexts_b c
     WHERE        c.prc_context_code = 'VOLUME'
       AND        c.prc_context_type = 'PRICING_ATTRIBUTE'
       AND        c.prc_context_id = s.prc_context_id
       AND        s.segment_mapping_column = p_MODIFIERS_rec.accum_attribute
       AND        s.segment_id = ps.segment_id
       AND        ps.pte_code = l_pte_code;
     EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
     END;

     IF l_sourcing_method = 'RUNTIME SOURCED' THEN
  v_accum_flag := 'Y';
     ELSE
  v_accum_flag := 'N';
     END IF;
  END IF;

   /* Accumulation Start */
     BEGIN
       SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_MODIFIERS_rec.list_header_id;
     EXCEPTION
  WHEN NO_DATA_FOUND THEN
     NULL;
     END;
   /* Accumulation End */

    INSERT  INTO QP_LIST_LINES
    (       ARITHMETIC_OPERATOR
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
--    ,       BASE_QTY
    ,       PRICING_PHASE_ID
--    ,       BASE_UOM_CODE
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
    ,       ACCRUAL_FLAG
    ,       PRICING_GROUP_SEQUENCE
    ,       INCOMPATIBILITY_GRP_CODE
    ,       LIST_LINE_NO
    ,       PRODUCT_PRECEDENCE
    ,       EXPIRATION_PERIOD_START_DATE
    ,       NUMBER_EXPIRATION_PERIODS
    ,       EXPIRATION_PERIOD_UOM
    ,       EXPIRATION_DATE
    ,       ESTIM_GL_VALUE
    ,       BENEFIT_PRICE_LIST_LINE_ID
--    ,       RECURRING_FLAG
    ,       BENEFIT_LIMIT
    ,       CHARGE_TYPE_CODE
    ,       CHARGE_SUBTYPE_CODE
    ,       BENEFIT_QTY
    ,       BENEFIT_UOM_CODE
    ,       ACCRUAL_CONVERSION_RATE
    ,       PRORATION_TYPE_CODE
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       QUALIFICATION_IND
    ,       NET_AMOUNT_FLAG
    ,       ACCUM_ATTRIBUTE
    ,       ACCUM_CONTEXT
    ,       ACCUM_ATTR_RUN_SRC_FLAG
    ,       CONTINUOUS_PRICE_BREAK_FLAG
    )
    VALUES
    (       p_MODIFIERS_rec.arithmetic_operator
    ,       p_MODIFIERS_rec.attribute1
    ,       p_MODIFIERS_rec.attribute10
    ,       p_MODIFIERS_rec.attribute11
    ,       p_MODIFIERS_rec.attribute12
    ,       p_MODIFIERS_rec.attribute13
    ,       p_MODIFIERS_rec.attribute14
    ,       p_MODIFIERS_rec.attribute15
    ,       p_MODIFIERS_rec.attribute2
    ,       p_MODIFIERS_rec.attribute3
    ,       p_MODIFIERS_rec.attribute4
    ,       p_MODIFIERS_rec.attribute5
    ,       p_MODIFIERS_rec.attribute6
    ,       p_MODIFIERS_rec.attribute7
    ,       p_MODIFIERS_rec.attribute8
    ,       p_MODIFIERS_rec.attribute9
    ,       p_MODIFIERS_rec.automatic_flag
--    ,       p_MODIFIERS_rec.base_qty
    ,       p_MODIFIERS_rec.pricing_phase_id
--    ,       p_MODIFIERS_rec.base_uom_code
    ,       p_MODIFIERS_rec.comments
    ,       p_MODIFIERS_rec.context
    ,       p_MODIFIERS_rec.created_by
    ,       p_MODIFIERS_rec.creation_date
    ,       p_MODIFIERS_rec.effective_period_uom
    ,       p_MODIFIERS_rec.end_date_active
    ,       p_MODIFIERS_rec.estim_accrual_rate
    ,       p_MODIFIERS_rec.generate_using_formula_id
    ,       p_MODIFIERS_rec.inventory_item_id
    ,       p_MODIFIERS_rec.last_updated_by
    ,       p_MODIFIERS_rec.last_update_date
    ,       p_MODIFIERS_rec.last_update_login
    ,       p_MODIFIERS_rec.list_header_id
    ,       p_MODIFIERS_rec.list_line_id
    ,       p_MODIFIERS_rec.list_line_type_code
    ,       p_MODIFIERS_rec.list_price
    ,       p_MODIFIERS_rec.modifier_level_code
    ,       p_MODIFIERS_rec.number_effective_periods
    ,       p_MODIFIERS_rec.operand
    ,       p_MODIFIERS_rec.organization_id
    ,       p_MODIFIERS_rec.override_flag
    ,       p_MODIFIERS_rec.percent_price
    ,       p_MODIFIERS_rec.price_break_type_code
    ,       p_MODIFIERS_rec.price_by_formula_id
    ,       p_MODIFIERS_rec.primary_uom_flag
    ,       p_MODIFIERS_rec.print_on_invoice_flag
    ,       p_MODIFIERS_rec.program_application_id
    ,       p_MODIFIERS_rec.program_id
    ,       p_MODIFIERS_rec.program_update_date
    ,       p_MODIFIERS_rec.rebate_trxn_type_code
    ,       p_MODIFIERS_rec.related_item_id
    ,       p_MODIFIERS_rec.relationship_type_id
    ,       p_MODIFIERS_rec.reprice_flag
    ,       p_MODIFIERS_rec.request_id
    ,       p_MODIFIERS_rec.revision
    ,       p_MODIFIERS_rec.revision_date
    ,       p_MODIFIERS_rec.revision_reason_code
    ,       p_MODIFIERS_rec.start_date_active
    ,       p_MODIFIERS_rec.substitution_attribute
    ,       p_MODIFIERS_rec.substitution_context
    ,       p_MODIFIERS_rec.substitution_value
    ,       p_MODIFIERS_rec.accrual_flag
    ,       p_MODIFIERS_rec.pricing_group_sequence
    ,       p_MODIFIERS_rec.incompatibility_grp_code
    ,       p_MODIFIERS_rec.list_line_no
    ,       p_MODIFIERS_rec.product_precedence
    ,       p_MODIFIERS_rec.expiration_period_start_date
    ,       p_MODIFIERS_rec.number_expiration_periods
    ,       p_MODIFIERS_rec.expiration_period_uom
    ,       p_MODIFIERS_rec.expiration_date
    ,       p_MODIFIERS_rec.estim_gl_value
    ,       p_MODIFIERS_rec.benefit_price_list_line_id
--    ,       p_MODIFIERS_rec.recurring_flag
    ,       p_MODIFIERS_rec.benefit_limit
    ,       p_MODIFIERS_rec.charge_type_code
    ,       p_MODIFIERS_rec.charge_subtype_code
    ,       p_MODIFIERS_rec.benefit_qty
    ,       p_MODIFIERS_rec.benefit_uom_code
    ,       p_MODIFIERS_rec.accrual_conversion_rate
    ,       p_MODIFIERS_rec.proration_type_code
    ,       p_MODIFIERS_rec.include_on_returns_flag
    ,       p_MODIFIERS_rec.qualification_ind
    ,       p_MODIFIERS_rec.net_amount_flag
    ,       p_MODIFIERS_rec.accum_attribute
    ,       v_accum_context
    ,       v_accum_flag
    ,       p_MODIFIERS_rec.continuous_price_break_flag
    );
/*
select gsa_indicator
into   l_gsa_indicator
from   qp_list_headers_b
where  list_header_id = p_MODIFIERS_rec.LIST_HEADER_ID;

IF l_gsa_indicator = 'Y'
THEN

  QP_QP_Form_Modifier_List.Create_GSA_Qual(p_MODIFIERS_rec.LIST_HEADER_ID ,
                                           p_MODIFIERS_rec.LIST_LINE_ID ,
                                  l_return_status );
END IF;

*/


IF p_Modifiers_rec.list_line_type_code = 'CIE' then

--create default coupon qualifier
oe_debug_pub.add('IN Def Qualifier in QPXUMLLB');

  QP_QP_Form_Modifier_List.Create_GSA_Qual(p_MODIFIERS_rec.LIST_HEADER_ID ,
                                           p_MODIFIERS_rec.TO_RLTD_MODIFIER_ID ,
                   'COUPON',
                                  l_return_status );
END IF;

oe_debug_pub.add('UMLLB l_ret_sts create_gsa_qual '||l_return_status);
/*added this code to raise exception if qualifier does not get created-spgopal*/
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
    OE_MSG_PUB.Add;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    RAISE NO_DATA_FOUND;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
    OE_MSG_PUB.Add;
    --RAISE FND_API.G_EXC_ERROR;
    RAISE NO_DATA_FOUND;
  END IF;

   /* Accumulation Start */
l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
 IF(v_accum_context IS NOT NULL) AND
   (p_MODIFIERS_rec.accum_attribute IS NOT NULL) THEN

     UPDATE qp_pte_segments set used_in_setup='Y'
     WHERE  nvl(used_in_setup,'N')='N'
     AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a,qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_MODIFIERS_rec.accum_attribute
       AND    a.prc_context_id=b.prc_context_id
       AND b.prc_context_type = 'PRICING_ATTRIBUTE'
       AND    b.prc_context_code=v_accum_context);

 END IF;
END IF;
   /* Accumulation End */

oe_debug_pub.add('END Insert_Row in QPXUMLLB');

EXCEPTION

  WHEN DUP_VAL_ON_INDEX THEN

  FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MODIFIER_NUMBER');
  OE_MSG_PUB.Add;
  RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_list_line_id                  IN  NUMBER
)
IS
BEGIN

oe_debug_pub.add('BEGIN Delete_Row in QPXUMLLB');
oe_debug_pub.add('list line id = '||to_char(p_list_line_id));

    DELETE FROM QP_PRICING_ATTRIBUTES
    WHERE LIST_LINE_ID = p_list_line_id;

    DELETE FROM QP_QUALIFIERS
    WHERE LIST_LINE_ID = p_list_line_id;

    DELETE FROM QP_RLTD_MODIFIERS
    WHERE TO_RLTD_MODIFIER_ID = p_list_line_id;

    DELETE  FROM QP_LIST_LINES
    WHERE   LIST_LINE_ID = p_list_line_id ;

oe_debug_pub.add('END Delete_Row in QPXUMLLB');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Row;

--  Function Query_Row

FUNCTION Query_Row
(   p_list_line_id                  IN  NUMBER
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type
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
) RETURN QP_Modifiers_PUB.Modifiers_Tbl_Type
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;

CURSOR l_MODIFIERS_csr IS
    SELECT  ARITHMETIC_OPERATOR
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
--    ,       BASE_QTY
    ,       PRICING_PHASE_ID
--    ,       BASE_UOM_CODE
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
    ,       ACCRUAL_FLAG
    ,       PRICING_GROUP_SEQUENCE
    ,       INCOMPATIBILITY_GRP_CODE
    ,       LIST_LINE_NO
    ,       PRODUCT_PRECEDENCE
    ,       EXPIRATION_PERIOD_START_DATE
    ,       NUMBER_EXPIRATION_PERIODS
    ,       EXPIRATION_PERIOD_UOM
    ,       EXPIRATION_DATE
    ,       ESTIM_GL_VALUE
    ,       BENEFIT_PRICE_LIST_LINE_ID
--    ,       RECURRING_FLAG
    ,       BENEFIT_LIMIT
    ,       CHARGE_TYPE_CODE
    ,       CHARGE_SUBTYPE_CODE
    ,       BENEFIT_QTY
    ,       BENEFIT_UOM_CODE
    ,       ACCRUAL_CONVERSION_RATE
    ,       PRORATION_TYPE_CODE
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       QUALIFICATION_IND
    ,       NET_AMOUNT_FLAG
    ,       ACCUM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG
    FROM    QP_LIST_LINES
    WHERE ( LIST_LINE_ID = p_list_line_id)
UNION                                     -- Changed for the bug#2715150
    SELECT  ARITHMETIC_OPERATOR
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
--    ,       BASE_QTY
    ,       PRICING_PHASE_ID
--    ,       BASE_UOM_CODE
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
    ,       ACCRUAL_FLAG
    ,       PRICING_GROUP_SEQUENCE
    ,       INCOMPATIBILITY_GRP_CODE
    ,       LIST_LINE_NO
    ,       PRODUCT_PRECEDENCE
    ,       EXPIRATION_PERIOD_START_DATE
    ,       NUMBER_EXPIRATION_PERIODS
    ,       EXPIRATION_PERIOD_UOM
    ,       EXPIRATION_DATE
    ,       ESTIM_GL_VALUE
    ,       BENEFIT_PRICE_LIST_LINE_ID
--    ,       RECURRING_FLAG
    ,       BENEFIT_LIMIT
    ,       CHARGE_TYPE_CODE
    ,       CHARGE_SUBTYPE_CODE
    ,       BENEFIT_QTY
    ,       BENEFIT_UOM_CODE
    ,       ACCRUAL_CONVERSION_RATE
    ,       PRORATION_TYPE_CODE
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       QUALIFICATION_IND
    ,       NET_AMOUNT_FLAG
    ,       ACCUM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG
    FROM    QP_LIST_LINES
    WHERE ( LIST_HEADER_ID = p_list_header_id );


BEGIN

oe_debug_pub.add('BEGIN Query_Rows in QPXUMLLB');
oe_debug_pub.add('list line = '||to_char(p_list_line_id));
oe_debug_pub.add('list hdr = '||to_char(p_list_header_id));

    IF
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (p_list_header_id IS NOT NULL
     AND
     p_list_header_id <> FND_API.G_MISS_NUM)
    THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: list_line_id = '|| p_list_line_id || ', list_header_id = '|| p_list_header_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;


oe_debug_pub.add('before FOR loooop');
    --  Loop over fetched records

    FOR l_implicit_rec IN l_MODIFIERS_csr LOOP

oe_debug_pub.add('loooop - 00');
        l_MODIFIERS_rec.arithmetic_operator := l_implicit_rec.ARITHMETIC_OPERATOR;
        l_MODIFIERS_rec.attribute1     := l_implicit_rec.ATTRIBUTE1;
        l_MODIFIERS_rec.attribute10    := l_implicit_rec.ATTRIBUTE10;
        l_MODIFIERS_rec.attribute11    := l_implicit_rec.ATTRIBUTE11;
        l_MODIFIERS_rec.attribute12    := l_implicit_rec.ATTRIBUTE12;
        l_MODIFIERS_rec.attribute13    := l_implicit_rec.ATTRIBUTE13;
        l_MODIFIERS_rec.attribute14    := l_implicit_rec.ATTRIBUTE14;
        l_MODIFIERS_rec.attribute15    := l_implicit_rec.ATTRIBUTE15;
        l_MODIFIERS_rec.attribute2     := l_implicit_rec.ATTRIBUTE2;
        l_MODIFIERS_rec.attribute3     := l_implicit_rec.ATTRIBUTE3;
        l_MODIFIERS_rec.attribute4     := l_implicit_rec.ATTRIBUTE4;
        l_MODIFIERS_rec.attribute5     := l_implicit_rec.ATTRIBUTE5;
        l_MODIFIERS_rec.attribute6     := l_implicit_rec.ATTRIBUTE6;
        l_MODIFIERS_rec.attribute7     := l_implicit_rec.ATTRIBUTE7;
        l_MODIFIERS_rec.attribute8     := l_implicit_rec.ATTRIBUTE8;
        l_MODIFIERS_rec.attribute9     := l_implicit_rec.ATTRIBUTE9;
        l_MODIFIERS_rec.automatic_flag := l_implicit_rec.AUTOMATIC_FLAG;
--        l_MODIFIERS_rec.base_qty       := l_implicit_rec.BASE_QTY;
        l_MODIFIERS_rec.pricing_phase_id := l_implicit_rec.PRICING_PHASE_ID;
--        l_MODIFIERS_rec.base_uom_code  := l_implicit_rec.BASE_UOM_CODE;
        l_MODIFIERS_rec.comments       := l_implicit_rec.COMMENTS;
        l_MODIFIERS_rec.context        := l_implicit_rec.CONTEXT;
        l_MODIFIERS_rec.created_by     := l_implicit_rec.CREATED_BY;
        l_MODIFIERS_rec.creation_date  := l_implicit_rec.CREATION_DATE;
        l_MODIFIERS_rec.effective_period_uom := l_implicit_rec.EFFECTIVE_PERIOD_UOM;
        l_MODIFIERS_rec.end_date_active := l_implicit_rec.END_DATE_ACTIVE;
        l_MODIFIERS_rec.estim_accrual_rate := l_implicit_rec.ESTIM_ACCRUAL_RATE;
        l_MODIFIERS_rec.generate_using_formula_id := l_implicit_rec.GENERATE_USING_FORMULA_ID;
        l_MODIFIERS_rec.inventory_item_id := l_implicit_rec.INVENTORY_ITEM_ID;
        l_MODIFIERS_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_MODIFIERS_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_MODIFIERS_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_MODIFIERS_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_MODIFIERS_rec.list_line_id   := l_implicit_rec.LIST_LINE_ID;
        l_MODIFIERS_rec.list_line_type_code := l_implicit_rec.LIST_LINE_TYPE_CODE;
        l_MODIFIERS_rec.list_price     := l_implicit_rec.LIST_PRICE;
        l_MODIFIERS_rec.modifier_level_code := l_implicit_rec.MODIFIER_LEVEL_CODE;
        l_MODIFIERS_rec.number_effective_periods := l_implicit_rec.NUMBER_EFFECTIVE_PERIODS;
        l_MODIFIERS_rec.operand        := l_implicit_rec.OPERAND;
        l_MODIFIERS_rec.organization_id := l_implicit_rec.ORGANIZATION_ID;
        l_MODIFIERS_rec.override_flag  := l_implicit_rec.OVERRIDE_FLAG;
        l_MODIFIERS_rec.percent_price  := l_implicit_rec.PERCENT_PRICE;
        l_MODIFIERS_rec.price_break_type_code := l_implicit_rec.PRICE_BREAK_TYPE_CODE;
        l_MODIFIERS_rec.price_by_formula_id := l_implicit_rec.PRICE_BY_FORMULA_ID;
        l_MODIFIERS_rec.primary_uom_flag := l_implicit_rec.PRIMARY_UOM_FLAG;
        l_MODIFIERS_rec.print_on_invoice_flag := l_implicit_rec.PRINT_ON_INVOICE_FLAG;
        l_MODIFIERS_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_MODIFIERS_rec.program_id     := l_implicit_rec.PROGRAM_ID;
        l_MODIFIERS_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_MODIFIERS_rec.rebate_trxn_type_code := l_implicit_rec.REBATE_TRANSACTION_TYPE_CODE;
        l_MODIFIERS_rec.related_item_id := l_implicit_rec.RELATED_ITEM_ID;
        l_MODIFIERS_rec.relationship_type_id := l_implicit_rec.RELATIONSHIP_TYPE_ID;
        l_MODIFIERS_rec.reprice_flag   := l_implicit_rec.REPRICE_FLAG;
        l_MODIFIERS_rec.request_id     := l_implicit_rec.REQUEST_ID;
        l_MODIFIERS_rec.revision       := l_implicit_rec.REVISION;
        l_MODIFIERS_rec.revision_date  := l_implicit_rec.REVISION_DATE;
        l_MODIFIERS_rec.revision_reason_code := l_implicit_rec.REVISION_REASON_CODE;
        l_MODIFIERS_rec.start_date_active := l_implicit_rec.START_DATE_ACTIVE;
        l_MODIFIERS_rec.substitution_attribute := l_implicit_rec.SUBSTITUTION_ATTRIBUTE;
        l_MODIFIERS_rec.substitution_context := l_implicit_rec.SUBSTITUTION_CONTEXT;
        l_MODIFIERS_rec.substitution_value := l_implicit_rec.SUBSTITUTION_VALUE;
        l_MODIFIERS_rec.accrual_flag := l_implicit_rec.ACCRUAL_FLAG;
        l_MODIFIERS_rec.pricing_group_sequence := l_implicit_rec.PRICING_GROUP_SEQUENCE;
        l_MODIFIERS_rec.incompatibility_grp_code := l_implicit_rec.INCOMPATIBILITY_GRP_CODE;
        l_MODIFIERS_rec.list_line_no := l_implicit_rec.LIST_LINE_NO;
        l_MODIFIERS_rec.product_precedence := l_implicit_rec.PRODUCT_PRECEDENCE;
        l_MODIFIERS_rec.expiration_period_start_date := l_implicit_rec.EXPIRATION_PERIOD_START_DATE;
        l_MODIFIERS_rec.number_expiration_periods := l_implicit_rec.NUMBER_EXPIRATION_PERIODS;
        l_MODIFIERS_rec.expiration_period_uom := l_implicit_rec.EXPIRATION_PERIOD_UOM;
        l_MODIFIERS_rec.expiration_date := l_implicit_rec.EXPIRATION_DATE;
        l_MODIFIERS_rec.estim_gl_value := l_implicit_rec.ESTIM_GL_VALUE;
        l_MODIFIERS_rec.benefit_price_list_line_id := l_implicit_rec.BENEFIT_PRICE_LIST_LINE_ID;
--        l_MODIFIERS_rec.recurring_flag := l_implicit_rec.RECURRING_FLAG;
        l_MODIFIERS_rec.benefit_limit := l_implicit_rec.BENEFIT_LIMIT;
        l_MODIFIERS_rec.charge_type_code := l_implicit_rec.CHARGE_TYPE_CODE;
        l_MODIFIERS_rec.charge_subtype_code := l_implicit_rec.CHARGE_SUBTYPE_CODE;
        l_MODIFIERS_rec.benefit_qty := l_implicit_rec.BENEFIT_QTY;
        l_MODIFIERS_rec.benefit_uom_code := l_implicit_rec.BENEFIT_UOM_CODE;
        l_MODIFIERS_rec.accrual_conversion_rate := l_implicit_rec.ACCRUAL_CONVERSION_RATE;
        l_MODIFIERS_rec.proration_type_code := l_implicit_rec.PRORATION_TYPE_CODE;
        l_MODIFIERS_rec.include_on_returns_flag := l_implicit_rec.INCLUDE_ON_RETURNS_FLAG;
        l_MODIFIERS_rec.qualification_ind := l_implicit_rec.qualification_ind;
        l_MODIFIERS_rec.net_amount_flag := l_implicit_rec.net_amount_flag;
        l_MODIFIERS_rec.accum_attribute := l_implicit_rec.accum_attribute;
        l_MODIFIERS_rec.continuous_price_break_flag := l_implicit_rec.continuous_price_break_flag;

    Begin

oe_debug_pub.add('before RLTD loooop');

    SELECT  RLTD_MODIFIER_GRP_NO
    ,       RLTD_MODIFIER_GRP_TYPE
    ,       FROM_RLTD_MODIFIER_ID
    ,       TO_RLTD_MODIFIER_ID
    ,       RLTD_MODIFIER_ID
    INTO    l_MODIFIERS_rec.rltd_modifier_grp_no
    ,       l_MODIFIERS_rec.rltd_modifier_grp_type
    ,       l_MODIFIERS_rec.from_rltd_modifier_id
    ,       l_MODIFIERS_rec.to_rltd_modifier_id
    ,       l_MODIFIERS_rec.rltd_modifier_id
    FROM    QP_RLTD_MODIFIERS
    WHERE   ( TO_RLTD_MODIFIER_ID = l_implicit_rec.LIST_LINE_ID )
    AND EXISTS
      ( SELECT TO_RLTD_MODIFIER_ID
        FROM   QP_RLTD_MODIFIERS
     WHERE  TO_RLTD_MODIFIER_ID = l_implicit_rec.LIST_LINE_ID );

    Exception
      when no_data_found then
oe_debug_pub.add('no dataaaaa');
   null;
    end;

        l_MODIFIERS_tbl(l_MODIFIERS_tbl.COUNT + 1) := l_MODIFIERS_rec;

    END LOOP;


    --  PK sent and no rows found

    IF
    (p_list_line_id IS NOT NULL
     AND
     p_list_line_id <> FND_API.G_MISS_NUM)
    AND
    (l_MODIFIERS_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


oe_debug_pub.add('END Query_Rows in QPXUMLLB');

    --  Return fetched table

    RETURN l_MODIFIERS_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
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
,   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   x_MODIFIERS_rec                 OUT NOCOPY QP_Modifiers_PUB.Modifiers_Rec_Type
)
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Lock_Row in QPXUMLLB');

    SELECT  ARITHMETIC_OPERATOR
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
--    ,       BASE_QTY
    ,       PRICING_PHASE_ID
--    ,       BASE_UOM_CODE
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
    ,       ACCRUAL_FLAG
    ,       PRICING_GROUP_SEQUENCE
    ,       INCOMPATIBILITY_GRP_CODE
    ,       LIST_LINE_NO
    ,       PRODUCT_PRECEDENCE
    ,       EXPIRATION_PERIOD_START_DATE
    ,       NUMBER_EXPIRATION_PERIODS
    ,       EXPIRATION_PERIOD_UOM
    ,       EXPIRATION_DATE
    ,       ESTIM_GL_VALUE
    ,       BENEFIT_PRICE_LIST_LINE_ID
--    ,       RECURRING_FLAG
    ,       BENEFIT_LIMIT
    ,       CHARGE_TYPE_CODE
    ,       CHARGE_SUBTYPE_CODE
    ,       BENEFIT_QTY
    ,       BENEFIT_UOM_CODE
    ,       ACCRUAL_CONVERSION_RATE
    ,       PRORATION_TYPE_CODE
    ,       INCLUDE_ON_RETURNS_FLAG
    ,       ACCUM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG
    INTO    l_MODIFIERS_rec.arithmetic_operator
    ,       l_MODIFIERS_rec.attribute1
    ,       l_MODIFIERS_rec.attribute10
    ,       l_MODIFIERS_rec.attribute11
    ,       l_MODIFIERS_rec.attribute12
    ,       l_MODIFIERS_rec.attribute13
    ,       l_MODIFIERS_rec.attribute14
    ,       l_MODIFIERS_rec.attribute15
    ,       l_MODIFIERS_rec.attribute2
    ,       l_MODIFIERS_rec.attribute3
    ,       l_MODIFIERS_rec.attribute4
    ,       l_MODIFIERS_rec.attribute5
    ,       l_MODIFIERS_rec.attribute6
    ,       l_MODIFIERS_rec.attribute7
    ,       l_MODIFIERS_rec.attribute8
    ,       l_MODIFIERS_rec.attribute9
    ,       l_MODIFIERS_rec.automatic_flag
--    ,       l_MODIFIERS_rec.base_qty
    ,       l_MODIFIERS_rec.pricing_phase_id
--    ,       l_MODIFIERS_rec.base_uom_code
    ,       l_MODIFIERS_rec.comments
    ,       l_MODIFIERS_rec.context
    ,       l_MODIFIERS_rec.created_by
    ,       l_MODIFIERS_rec.creation_date
    ,       l_MODIFIERS_rec.effective_period_uom
    ,       l_MODIFIERS_rec.end_date_active
    ,       l_MODIFIERS_rec.estim_accrual_rate
    ,       l_MODIFIERS_rec.generate_using_formula_id
    ,       l_MODIFIERS_rec.inventory_item_id
    ,       l_MODIFIERS_rec.last_updated_by
    ,       l_MODIFIERS_rec.last_update_date
    ,       l_MODIFIERS_rec.last_update_login
    ,       l_MODIFIERS_rec.list_header_id
    ,       l_MODIFIERS_rec.list_line_id
    ,       l_MODIFIERS_rec.list_line_type_code
    ,       l_MODIFIERS_rec.list_price
    ,       l_MODIFIERS_rec.modifier_level_code
    ,       l_MODIFIERS_rec.number_effective_periods
    ,       l_MODIFIERS_rec.operand
    ,       l_MODIFIERS_rec.organization_id
    ,       l_MODIFIERS_rec.override_flag
    ,       l_MODIFIERS_rec.percent_price
    ,       l_MODIFIERS_rec.price_break_type_code
    ,       l_MODIFIERS_rec.price_by_formula_id
    ,       l_MODIFIERS_rec.primary_uom_flag
    ,       l_MODIFIERS_rec.print_on_invoice_flag
    ,       l_MODIFIERS_rec.program_application_id
    ,       l_MODIFIERS_rec.program_id
    ,       l_MODIFIERS_rec.program_update_date
    ,       l_MODIFIERS_rec.rebate_trxn_type_code
    ,       l_MODIFIERS_rec.related_item_id
    ,       l_MODIFIERS_rec.relationship_type_id
    ,       l_MODIFIERS_rec.reprice_flag
    ,       l_MODIFIERS_rec.request_id
    ,       l_MODIFIERS_rec.revision
    ,       l_MODIFIERS_rec.revision_date
    ,       l_MODIFIERS_rec.revision_reason_code
    ,       l_MODIFIERS_rec.start_date_active
    ,       l_MODIFIERS_rec.substitution_attribute
    ,       l_MODIFIERS_rec.substitution_context
    ,       l_MODIFIERS_rec.substitution_value
    ,       l_MODIFIERS_rec.accrual_flag
    ,       l_MODIFIERS_rec.pricing_group_sequence
    ,       l_MODIFIERS_rec.incompatibility_grp_code
    ,       l_MODIFIERS_rec.list_line_no
    ,       l_MODIFIERS_rec.product_precedence
    ,       l_MODIFIERS_rec.expiration_period_start_date
    ,       l_MODIFIERS_rec.number_expiration_periods
    ,       l_MODIFIERS_rec.expiration_period_uom
    ,       l_MODIFIERS_rec.expiration_date
    ,       l_MODIFIERS_rec.estim_gl_value
    ,       l_MODIFIERS_rec.benefit_price_list_line_id
--    ,       l_MODIFIERS_rec.recurring_flag
    ,       l_MODIFIERS_rec.benefit_limit
    ,       l_MODIFIERS_rec.charge_type_code
    ,       l_MODIFIERS_rec.charge_subtype_code
    ,       l_MODIFIERS_rec.benefit_qty
    ,       l_MODIFIERS_rec.benefit_uom_code
    ,       l_MODIFIERS_rec.accrual_conversion_rate
    ,       l_MODIFIERS_rec.proration_type_code
    ,       l_MODIFIERS_rec.include_on_returns_flag
    ,       l_MODIFIERS_rec.accum_attribute
    ,       l_MODIFIERS_rec.continuous_price_break_flag
    FROM    QP_LIST_LINES
    WHERE   LIST_LINE_ID = p_MODIFIERS_rec.list_line_id
        FOR UPDATE NOWAIT;

	/* display debug messages only when OE_LOCK_ROW issue occurs
	-- smbalara Fix for Bug 6340093 - messages added for debugging oe_lock_row issue in the modifier lines block
	--added missing columns for oe_lock_row issue :bug 8594682
	oe_debug_pub.add('p_MODIFIERS_rec.arithmetic_operator		:'||p_MODIFIERS_rec.arithmetic_operator||':'||'l_MODIFIERS_rec.arithmetic_operator:'||l_MODIFIERS_rec.arithmetic_operator||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute1			:'||p_MODIFIERS_rec.attribute1||':'||'l_MODIFIERS_rec.attribute1:'||l_MODIFIERS_rec.attribute1||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute10			:'||p_MODIFIERS_rec.attribute10||':'||'l_MODIFIERS_rec.attribute10:'||l_MODIFIERS_rec.attribute10||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute11			:'||p_MODIFIERS_rec.attribute11||':'||'l_MODIFIERS_rec.attribute11:'||l_MODIFIERS_rec.attribute11||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute12			:'||p_MODIFIERS_rec.attribute12||':'||'l_MODIFIERS_rec.attribute12:'||l_MODIFIERS_rec.attribute12||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute13			:'||p_MODIFIERS_rec.attribute13||':'||'l_MODIFIERS_rec.attribute13:'||l_MODIFIERS_rec.attribute13||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute14			:'||p_MODIFIERS_rec.attribute14||':'||'l_MODIFIERS_rec.attribute14:'||l_MODIFIERS_rec.attribute14||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute15			:'||p_MODIFIERS_rec.attribute15||':'||'l_MODIFIERS_rec.attribute15:'||l_MODIFIERS_rec.attribute15||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute2			:'||p_MODIFIERS_rec.attribute2||':'||'l_MODIFIERS_rec.attribute2:'||l_MODIFIERS_rec.attribute2||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute3			:'||p_MODIFIERS_rec.attribute3||':'||'l_MODIFIERS_rec.attribute3:'||l_MODIFIERS_rec.attribute3||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute4			:'||p_MODIFIERS_rec.attribute4||':'||'l_MODIFIERS_rec.attribute4:'||l_MODIFIERS_rec.attribute4||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute5			:'||p_MODIFIERS_rec.attribute5||':'||'l_MODIFIERS_rec.attribute5:'||l_MODIFIERS_rec.attribute5||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute6			:'||p_MODIFIERS_rec.attribute6||':'||'l_MODIFIERS_rec.attribute6:'||l_MODIFIERS_rec.attribute6||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute7			:'||p_MODIFIERS_rec.attribute7||':'||'l_MODIFIERS_rec.attribute7:'||l_MODIFIERS_rec.attribute7||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute8			:'||p_MODIFIERS_rec.attribute8||':'||'l_MODIFIERS_rec.attribute8:'||l_MODIFIERS_rec.attribute8||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute9			:'||p_MODIFIERS_rec.attribute9||':'||'l_MODIFIERS_rec.attribute9:'||l_MODIFIERS_rec.attribute9||':');
	oe_debug_pub.add('p_MODIFIERS_rec.automatic_flag		:'||p_MODIFIERS_rec.automatic_flag||':'||'l_MODIFIERS_rec.automatic_flag:'||l_MODIFIERS_rec.automatic_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.pricing_phase_id		:'||p_MODIFIERS_rec.pricing_phase_id||':'||'l_MODIFIERS_rec.pricing_phase_id:'||l_MODIFIERS_rec.pricing_phase_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.comments			:'||p_MODIFIERS_rec.comments||':'||'l_MODIFIERS_rec.comments:'||l_MODIFIERS_rec.comments||':');
	oe_debug_pub.add('p_MODIFIERS_rec.context			:'||p_MODIFIERS_rec.context||':'||'l_MODIFIERS_rec.context:'||l_MODIFIERS_rec.context||':');
	oe_debug_pub.add('p_MODIFIERS_rec.effective_period_uom		:'||p_MODIFIERS_rec.effective_period_uom||':'||'l_MODIFIERS_rec.effective_period_uom:'||l_MODIFIERS_rec.effective_period_uom||':');
	oe_debug_pub.add('p_MODIFIERS_rec.end_date_active		:'||p_MODIFIERS_rec.end_date_active||':'||'l_MODIFIERS_rec.end_date_active:'||l_MODIFIERS_rec.end_date_active||':');
	oe_debug_pub.add('p_MODIFIERS_rec.estim_accrual_rate		:'||p_MODIFIERS_rec.estim_accrual_rate||':'||'l_MODIFIERS_rec.estim_accrual_rate:'||l_MODIFIERS_rec.estim_accrual_rate||':');
	oe_debug_pub.add('p_MODIFIERS_rec.generate_using_formula_id	:'||p_MODIFIERS_rec.generate_using_formula_id||':'||'l_MODIFIERS_rec.generate_using_formula_id:'||l_MODIFIERS_rec.generate_using_formula_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.inventory_item_id		:'||p_MODIFIERS_rec.inventory_item_id||':'||'l_MODIFIERS_rec.inventory_item_id:'||l_MODIFIERS_rec.inventory_item_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_header_id		:'||p_MODIFIERS_rec.list_header_id||':'||'l_MODIFIERS_rec.list_header_id:'||l_MODIFIERS_rec.list_header_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_id			:'||p_MODIFIERS_rec.list_line_id||':'||'l_MODIFIERS_rec.list_line_id:'||l_MODIFIERS_rec.list_line_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_type_code		:'||p_MODIFIERS_rec.list_line_type_code||':'||'l_MODIFIERS_rec.list_line_type_code:'||l_MODIFIERS_rec.list_line_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.modifier_level_code		:'||p_MODIFIERS_rec.modifier_level_code||':'||'l_MODIFIERS_rec.modifier_level_code:'||l_MODIFIERS_rec.modifier_level_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.number_effective_periods	:'||p_MODIFIERS_rec.number_effective_periods||':'||'l_MODIFIERS_rec.number_effective_periods:'||l_MODIFIERS_rec.number_effective_periods||':');
	oe_debug_pub.add('p_MODIFIERS_rec.operand			:'||p_MODIFIERS_rec.operand||':'||'l_MODIFIERS_rec.operand:'||l_MODIFIERS_rec.operand||':');
	oe_debug_pub.add('p_MODIFIERS_rec.organization_id		:'||p_MODIFIERS_rec.organization_id||':'||'l_MODIFIERS_rec.organization_id:'||l_MODIFIERS_rec.organization_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.override_flag			:'||p_MODIFIERS_rec.override_flag||':'||'l_MODIFIERS_rec.override_flag:'||l_MODIFIERS_rec.override_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.percent_price			:'||p_MODIFIERS_rec.percent_price||':'||'l_MODIFIERS_rec.percent_price:'||l_MODIFIERS_rec.percent_price||':');
	oe_debug_pub.add('p_MODIFIERS_rec.price_break_type_code		:'||p_MODIFIERS_rec.price_break_type_code||':'||'l_MODIFIERS_rec.price_break_type_code:'||l_MODIFIERS_rec.price_break_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.price_by_formula_id		:'||p_MODIFIERS_rec.price_by_formula_id||':'||'l_MODIFIERS_rec.price_by_formula_id:'||l_MODIFIERS_rec.price_by_formula_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.primary_uom_flag		:'||p_MODIFIERS_rec.primary_uom_flag||':'||'l_MODIFIERS_rec.primary_uom_flag:'||l_MODIFIERS_rec.primary_uom_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.print_on_invoice_flag		:'||p_MODIFIERS_rec.print_on_invoice_flag||':'||'l_MODIFIERS_rec.print_on_invoice_flag:'||l_MODIFIERS_rec.print_on_invoice_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.rebate_trxn_type_code		:'||p_MODIFIERS_rec.rebate_trxn_type_code||':'||'l_MODIFIERS_rec.rebate_trxn_type_code:'||l_MODIFIERS_rec.rebate_trxn_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.related_item_id		:'||p_MODIFIERS_rec.related_item_id||':'||'l_MODIFIERS_rec.related_item_id:'||l_MODIFIERS_rec.related_item_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.relationship_type_id		:'||p_MODIFIERS_rec.relationship_type_id||':'||'l_MODIFIERS_rec.relationship_type_id:'||l_MODIFIERS_rec.relationship_type_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.reprice_flag			:'||p_MODIFIERS_rec.reprice_flag||':'||'l_MODIFIERS_rec.reprice_flag:'||l_MODIFIERS_rec.reprice_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision			:'||p_MODIFIERS_rec.revision||':'||'l_MODIFIERS_rec.revision:'||l_MODIFIERS_rec.revision||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision_date			:'||p_MODIFIERS_rec.revision_date||':'||'l_MODIFIERS_rec.revision_date:'||l_MODIFIERS_rec.revision_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision_reason_code		:'||p_MODIFIERS_rec.revision_reason_code||':'||'l_MODIFIERS_rec.revision_reason_code:'||l_MODIFIERS_rec.revision_reason_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_attribute	:'||p_MODIFIERS_rec.substitution_attribute||':'||'l_MODIFIERS_rec.substitution_attribute:'||l_MODIFIERS_rec.substitution_attribute||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_context		:'||p_MODIFIERS_rec.substitution_context||':'||'l_MODIFIERS_rec.substitution_context:'||l_MODIFIERS_rec.substitution_context||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_value		:'||p_MODIFIERS_rec.substitution_value||':'||'l_MODIFIERS_rec.substitution_value:'||l_MODIFIERS_rec.substitution_value||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accrual_flag			:'||p_MODIFIERS_rec.accrual_flag||':'||'l_MODIFIERS_rec.accrual_flag:'||l_MODIFIERS_rec.accrual_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.pricing_group_sequence	:'||p_MODIFIERS_rec.pricing_group_sequence||':'||'l_MODIFIERS_rec.pricing_group_sequence:'||l_MODIFIERS_rec.pricing_group_sequence||':');
	oe_debug_pub.add('p_MODIFIERS_rec.incompatibility_grp_code	:'||p_MODIFIERS_rec.incompatibility_grp_code||':'||'l_MODIFIERS_rec.incompatibility_grp_code:'||l_MODIFIERS_rec.incompatibility_grp_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_no			:'||p_MODIFIERS_rec.list_line_no||':'||'l_MODIFIERS_rec.list_line_no:'||l_MODIFIERS_rec.list_line_no||':');
	oe_debug_pub.add('p_MODIFIERS_rec.product_precedence		:'||p_MODIFIERS_rec.product_precedence||':'||'l_MODIFIERS_rec.product_precedence:'||l_MODIFIERS_rec.product_precedence||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_period_start_date	:'||p_MODIFIERS_rec.expiration_period_start_date||':'||'l_MODIFIERS_rec.expiration_period_start_date:'||l_MODIFIERS_rec.expiration_period_start_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.number_expiration_periods	:'||p_MODIFIERS_rec.number_expiration_periods||':'||'l_MODIFIERS_rec.number_expiration_periods:'||l_MODIFIERS_rec.number_expiration_periods||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_period_uom		:'||p_MODIFIERS_rec.expiration_period_uom||':'||'l_MODIFIERS_rec.expiration_period_uom:'||l_MODIFIERS_rec.expiration_period_uom||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_date		:'||p_MODIFIERS_rec.expiration_date||':'||'l_MODIFIERS_rec.expiration_date:'||l_MODIFIERS_rec.expiration_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.estim_gl_value		:'||p_MODIFIERS_rec.estim_gl_value||':'||'l_MODIFIERS_rec.estim_gl_value:'||l_MODIFIERS_rec.estim_gl_value||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_price_list_line_id	:'||p_MODIFIERS_rec.benefit_price_list_line_id||':'||'l_MODIFIERS_rec.benefit_price_list_line_id:'||l_MODIFIERS_rec.benefit_price_list_line_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_limit			:'||p_MODIFIERS_rec.benefit_limit||':'||'l_MODIFIERS_rec.benefit_limit:'||l_MODIFIERS_rec.benefit_limit||':');
	oe_debug_pub.add('p_MODIFIERS_rec.charge_type_code		:'||p_MODIFIERS_rec.charge_type_code||':'||'l_MODIFIERS_rec.charge_type_code:'||l_MODIFIERS_rec.charge_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.charge_subtype_code		:'||p_MODIFIERS_rec.charge_subtype_code||':'||'l_MODIFIERS_rec.charge_subtype_code:'||l_MODIFIERS_rec.charge_subtype_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_qty			:'||p_MODIFIERS_rec.benefit_qty||':'||'l_MODIFIERS_rec.benefit_qty:'||l_MODIFIERS_rec.benefit_qty||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_uom_code		:'||p_MODIFIERS_rec.benefit_uom_code||':'||'l_MODIFIERS_rec.benefit_uom_code:'||l_MODIFIERS_rec.benefit_uom_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accrual_conversion_rate	:'||p_MODIFIERS_rec.accrual_conversion_rate||':'||'l_MODIFIERS_rec.accrual_conversion_rate:'||l_MODIFIERS_rec.accrual_conversion_rate||':');
	oe_debug_pub.add('p_MODIFIERS_rec.proration_type_code		:'||p_MODIFIERS_rec.proration_type_code||':'||'l_MODIFIERS_rec.proration_type_code:'||l_MODIFIERS_rec.proration_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.include_on_returns_flag	:'||p_MODIFIERS_rec.include_on_returns_flag||':'||'l_MODIFIERS_rec.include_on_returns_flag:'||l_MODIFIERS_rec.include_on_returns_flag||':');

	oe_debug_pub.add('p_MODIFIERS_rec.created_by			:'||p_MODIFIERS_rec.created_by||':'||'l_MODIFIERS_rec.created_by:'||l_MODIFIERS_rec.created_by||':');
	oe_debug_pub.add('p_MODIFIERS_rec.creation_date			:'||p_MODIFIERS_rec.creation_date||':'||'l_MODIFIERS_rec.creation_date:'||l_MODIFIERS_rec.creation_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_updated_by		:'||p_MODIFIERS_rec.last_updated_by||':'||'l_MODIFIERS_rec.last_updated_by:'||l_MODIFIERS_rec.last_updated_by||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_update_date		:'||p_MODIFIERS_rec.last_update_date||':'||'l_MODIFIERS_rec.last_update_date:'||l_MODIFIERS_rec.last_update_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_update_login		:'||p_MODIFIERS_rec.last_update_login||':'||'l_MODIFIERS_rec.last_update_login:'||l_MODIFIERS_rec.last_update_login||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_price			:'||p_MODIFIERS_rec.list_price||':'||'l_MODIFIERS_rec.list_price:'||l_MODIFIERS_rec.list_price||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_application_id	:'||p_MODIFIERS_rec.program_application_id||':'||'l_MODIFIERS_rec.program_application_id:'||l_MODIFIERS_rec.program_application_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_id			:'||p_MODIFIERS_rec.program_id||':'||'l_MODIFIERS_rec.program_id:'||l_MODIFIERS_rec.program_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_update_date		:'||p_MODIFIERS_rec.program_update_date||':'||'l_MODIFIERS_rec.program_update_date:'||l_MODIFIERS_rec.program_update_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.request_id			:'||p_MODIFIERS_rec.request_id||':'||'l_MODIFIERS_rec.request_id:'||l_MODIFIERS_rec.request_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.start_date_active		:'||p_MODIFIERS_rec.start_date_active||':'||'l_MODIFIERS_rec.start_date_active:'||l_MODIFIERS_rec.start_date_active||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accum_attribute		:'||p_MODIFIERS_rec.accum_attribute||':'||'l_MODIFIERS_rec.accum_attribute:'||l_MODIFIERS_rec.accum_attribute||':');
*/
    --  Row locked. Compare IN attributes to DB attributes.

    IF
    QP_GLOBALS.Equal(p_MODIFIERS_rec.arithmetic_operator,
                         l_MODIFIERS_rec.arithmetic_operator)

    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute1,
                         l_MODIFIERS_rec.attribute1)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute10,
                         l_MODIFIERS_rec.attribute10)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute11,
                         l_MODIFIERS_rec.attribute11)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute12,
                         l_MODIFIERS_rec.attribute12)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute13,
                         l_MODIFIERS_rec.attribute13)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute14,
                         l_MODIFIERS_rec.attribute14)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute15,
                         l_MODIFIERS_rec.attribute15)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute2,
                         l_MODIFIERS_rec.attribute2)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute3,
                         l_MODIFIERS_rec.attribute3)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute4,
                         l_MODIFIERS_rec.attribute4)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute5,
                         l_MODIFIERS_rec.attribute5)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute6,
                         l_MODIFIERS_rec.attribute6)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute7,
                         l_MODIFIERS_rec.attribute7)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute8,
                         l_MODIFIERS_rec.attribute8)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.attribute9,
                         l_MODIFIERS_rec.attribute9)

    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.automatic_flag,
                         l_MODIFIERS_rec.automatic_flag)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.base_qty,
--                         l_MODIFIERS_rec.base_qty)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_phase_id,
                         l_MODIFIERS_rec.pricing_phase_id)

--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.base_uom_code,
--                         l_MODIFIERS_rec.base_uom_code)
    AND QP_GLOBALS.Equal(NVL(p_MODIFIERS_rec.comments,l_MODIFIERS_rec.comments),
                         l_MODIFIERS_rec.comments) --bug 7321894
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.context,
                         l_MODIFIERS_rec.context)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.created_by,
--                         l_MODIFIERS_rec.created_by)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.creation_date,
--                         l_MODIFIERS_rec.creation_date)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.effective_period_uom,
                         l_MODIFIERS_rec.effective_period_uom)
    AND QP_GLOBALS.Equal(to_date(to_char(p_MODIFIERS_rec.end_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'),
                         to_date(to_char(l_MODIFIERS_rec.end_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'))
    AND QP_GLOBALS.Equal(nvl(p_MODIFIERS_rec.estim_accrual_rate, l_MODIFIERS_rec.estim_accrual_rate),
                         l_MODIFIERS_rec.estim_accrual_rate)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.generate_using_formula_id,
                         l_MODIFIERS_rec.generate_using_formula_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.inventory_item_id,
                         l_MODIFIERS_rec.inventory_item_id)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.last_updated_by,
--                         l_MODIFIERS_rec.last_updated_by)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_date,
--                         l_MODIFIERS_rec.last_update_date)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.last_update_login,
--                         l_MODIFIERS_rec.last_update_login)

    AND QP_GLOBALS.Equal(nvl(p_MODIFIERS_rec.list_header_id, l_MODIFIERS_rec.list_header_id),
                         l_MODIFIERS_rec.list_header_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_id,
                         l_MODIFIERS_rec.list_line_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_type_code,
                         l_MODIFIERS_rec.list_line_type_code)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.list_price,
--                         l_MODIFIERS_rec.list_price)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.modifier_level_code,
                         l_MODIFIERS_rec.modifier_level_code)

    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.number_effective_periods,
                         l_MODIFIERS_rec.number_effective_periods)

    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.operand,
                         l_MODIFIERS_rec.operand)

    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.organization_id,
                         l_MODIFIERS_rec.organization_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.override_flag,
                         l_MODIFIERS_rec.override_flag)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.percent_price,
                         l_MODIFIERS_rec.percent_price)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.price_break_type_code,
                         l_MODIFIERS_rec.price_break_type_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.price_by_formula_id,
                         l_MODIFIERS_rec.price_by_formula_id)
    AND QP_GLOBALS.Equal(NVL(p_MODIFIERS_rec.primary_uom_flag,l_MODIFIERS_rec.primary_uom_flag),
                         l_MODIFIERS_rec.primary_uom_flag) --bug 7321894
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.print_on_invoice_flag,
                         l_MODIFIERS_rec.print_on_invoice_flag)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.program_application_id,
--                         l_MODIFIERS_rec.program_application_id)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.program_id,
--                         l_MODIFIERS_rec.program_id)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.program_update_date,
--                         l_MODIFIERS_rec.program_update_date)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.rebate_trxn_type_code,
                         l_MODIFIERS_rec.rebate_trxn_type_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.related_item_id,
                         l_MODIFIERS_rec.related_item_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.relationship_type_id,
                         l_MODIFIERS_rec.relationship_type_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.reprice_flag,
                         l_MODIFIERS_rec.reprice_flag)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.request_id,
--                         l_MODIFIERS_rec.request_id)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.revision,
                         l_MODIFIERS_rec.revision)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_date,
                         l_MODIFIERS_rec.revision_date)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_reason_code,
                         l_MODIFIERS_rec.revision_reason_code)
--AND QP_GLOBALS.Equal(to_date(to_char(p_MODIFIERS_rec.start_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'),
--                         to_date(to_char(l_MODIFIERS_rec.start_date_active,'DD/MM/YYYY'),'DD/MM/YYYY'))
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_attribute,
                         l_MODIFIERS_rec.substitution_attribute)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_context,
                         l_MODIFIERS_rec.substitution_context)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.substitution_value,
                         l_MODIFIERS_rec.substitution_value)

    AND QP_GLOBALS.Equal(nvl(p_MODIFIERS_rec.accrual_flag, l_MODIFIERS_rec.accrual_flag),
                         l_MODIFIERS_rec.accrual_flag)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.pricing_group_sequence,
                         l_MODIFIERS_rec.pricing_group_sequence)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.incompatibility_grp_code,
                         l_MODIFIERS_rec.incompatibility_grp_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_no,
                         l_MODIFIERS_rec.list_line_no)
    AND QP_GLOBALS.Equal(nvl(p_MODIFIERS_rec.product_precedence, l_MODIFIERS_rec.product_precedence),
                         l_MODIFIERS_rec.product_precedence)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_start_date,
                         l_MODIFIERS_rec.expiration_period_start_date)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.number_expiration_periods,
                         l_MODIFIERS_rec.number_expiration_periods)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_period_uom,
                         l_MODIFIERS_rec.expiration_period_uom)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.expiration_date,
                         l_MODIFIERS_rec.expiration_date)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.estim_gl_value,
                         l_MODIFIERS_rec.estim_gl_value)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_price_list_line_id,
                         l_MODIFIERS_rec.benefit_price_list_line_id)
--    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.recurring_flag,
--                         l_MODIFIERS_rec.recurring_flag)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_limit,
                         l_MODIFIERS_rec.benefit_limit)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_type_code,
                         l_MODIFIERS_rec.charge_type_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.charge_subtype_code,
                         l_MODIFIERS_rec.charge_subtype_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_qty,
                         l_MODIFIERS_rec.benefit_qty)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.benefit_uom_code,
                         l_MODIFIERS_rec.benefit_uom_code)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.accrual_conversion_rate,
                         l_MODIFIERS_rec.accrual_conversion_rate)
    AND QP_GLOBALS.Equal(p_MODIFIERS_rec.proration_type_code,
                         l_MODIFIERS_rec.proration_type_code)
    AND QP_GLOBALS.Equal(nvl(p_MODIFIERS_rec.include_on_returns_flag, l_MODIFIERS_rec.include_on_returns_flag),
                         l_MODIFIERS_rec.include_on_returns_flag)

    THEN

        --  Row has not changed. Set out parameter.

        x_MODIFIERS_rec                := l_MODIFIERS_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

    ELSE

	  -- smbalara Fix for Bug 6340093 - messages added for debugging oe_lock_row issue in the modifier lines block
	--added missing columns for oe_lock_row issue :bug 8594682
	oe_debug_pub.add('p_MODIFIERS_rec.arithmetic_operator		:'||p_MODIFIERS_rec.arithmetic_operator||':'||'l_MODIFIERS_rec.arithmetic_operator:'||l_MODIFIERS_rec.arithmetic_operator||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute1			:'||p_MODIFIERS_rec.attribute1||':'||'l_MODIFIERS_rec.attribute1:'||l_MODIFIERS_rec.attribute1||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute10			:'||p_MODIFIERS_rec.attribute10||':'||'l_MODIFIERS_rec.attribute10:'||l_MODIFIERS_rec.attribute10||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute11			:'||p_MODIFIERS_rec.attribute11||':'||'l_MODIFIERS_rec.attribute11:'||l_MODIFIERS_rec.attribute11||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute12			:'||p_MODIFIERS_rec.attribute12||':'||'l_MODIFIERS_rec.attribute12:'||l_MODIFIERS_rec.attribute12||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute13			:'||p_MODIFIERS_rec.attribute13||':'||'l_MODIFIERS_rec.attribute13:'||l_MODIFIERS_rec.attribute13||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute14			:'||p_MODIFIERS_rec.attribute14||':'||'l_MODIFIERS_rec.attribute14:'||l_MODIFIERS_rec.attribute14||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute15			:'||p_MODIFIERS_rec.attribute15||':'||'l_MODIFIERS_rec.attribute15:'||l_MODIFIERS_rec.attribute15||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute2			:'||p_MODIFIERS_rec.attribute2||':'||'l_MODIFIERS_rec.attribute2:'||l_MODIFIERS_rec.attribute2||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute3			:'||p_MODIFIERS_rec.attribute3||':'||'l_MODIFIERS_rec.attribute3:'||l_MODIFIERS_rec.attribute3||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute4			:'||p_MODIFIERS_rec.attribute4||':'||'l_MODIFIERS_rec.attribute4:'||l_MODIFIERS_rec.attribute4||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute5			:'||p_MODIFIERS_rec.attribute5||':'||'l_MODIFIERS_rec.attribute5:'||l_MODIFIERS_rec.attribute5||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute6			:'||p_MODIFIERS_rec.attribute6||':'||'l_MODIFIERS_rec.attribute6:'||l_MODIFIERS_rec.attribute6||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute7			:'||p_MODIFIERS_rec.attribute7||':'||'l_MODIFIERS_rec.attribute7:'||l_MODIFIERS_rec.attribute7||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute8			:'||p_MODIFIERS_rec.attribute8||':'||'l_MODIFIERS_rec.attribute8:'||l_MODIFIERS_rec.attribute8||':');
	oe_debug_pub.add('p_MODIFIERS_rec.attribute9			:'||p_MODIFIERS_rec.attribute9||':'||'l_MODIFIERS_rec.attribute9:'||l_MODIFIERS_rec.attribute9||':');
	oe_debug_pub.add('p_MODIFIERS_rec.automatic_flag		:'||p_MODIFIERS_rec.automatic_flag||':'||'l_MODIFIERS_rec.automatic_flag:'||l_MODIFIERS_rec.automatic_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.pricing_phase_id		:'||p_MODIFIERS_rec.pricing_phase_id||':'||'l_MODIFIERS_rec.pricing_phase_id:'||l_MODIFIERS_rec.pricing_phase_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.comments			:'||p_MODIFIERS_rec.comments||':'||'l_MODIFIERS_rec.comments:'||l_MODIFIERS_rec.comments||':');
	oe_debug_pub.add('p_MODIFIERS_rec.context			:'||p_MODIFIERS_rec.context||':'||'l_MODIFIERS_rec.context:'||l_MODIFIERS_rec.context||':');
	oe_debug_pub.add('p_MODIFIERS_rec.effective_period_uom		:'||p_MODIFIERS_rec.effective_period_uom||':'||'l_MODIFIERS_rec.effective_period_uom:'||l_MODIFIERS_rec.effective_period_uom||':');
	oe_debug_pub.add('p_MODIFIERS_rec.end_date_active		:'||p_MODIFIERS_rec.end_date_active||':'||'l_MODIFIERS_rec.end_date_active:'||l_MODIFIERS_rec.end_date_active||':');
	oe_debug_pub.add('p_MODIFIERS_rec.estim_accrual_rate		:'||p_MODIFIERS_rec.estim_accrual_rate||':'||'l_MODIFIERS_rec.estim_accrual_rate:'||l_MODIFIERS_rec.estim_accrual_rate||':');
	oe_debug_pub.add('p_MODIFIERS_rec.generate_using_formula_id	:'||p_MODIFIERS_rec.generate_using_formula_id||':'||'l_MODIFIERS_rec.generate_using_formula_id:'||l_MODIFIERS_rec.generate_using_formula_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.inventory_item_id		:'||p_MODIFIERS_rec.inventory_item_id||':'||'l_MODIFIERS_rec.inventory_item_id:'||l_MODIFIERS_rec.inventory_item_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_header_id		:'||p_MODIFIERS_rec.list_header_id||':'||'l_MODIFIERS_rec.list_header_id:'||l_MODIFIERS_rec.list_header_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_id			:'||p_MODIFIERS_rec.list_line_id||':'||'l_MODIFIERS_rec.list_line_id:'||l_MODIFIERS_rec.list_line_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_type_code		:'||p_MODIFIERS_rec.list_line_type_code||':'||'l_MODIFIERS_rec.list_line_type_code:'||l_MODIFIERS_rec.list_line_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.modifier_level_code		:'||p_MODIFIERS_rec.modifier_level_code||':'||'l_MODIFIERS_rec.modifier_level_code:'||l_MODIFIERS_rec.modifier_level_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.number_effective_periods	:'||p_MODIFIERS_rec.number_effective_periods||':'||'l_MODIFIERS_rec.number_effective_periods:'||l_MODIFIERS_rec.number_effective_periods||':');
	oe_debug_pub.add('p_MODIFIERS_rec.operand			:'||p_MODIFIERS_rec.operand||':'||'l_MODIFIERS_rec.operand:'||l_MODIFIERS_rec.operand||':');
	oe_debug_pub.add('p_MODIFIERS_rec.organization_id		:'||p_MODIFIERS_rec.organization_id||':'||'l_MODIFIERS_rec.organization_id:'||l_MODIFIERS_rec.organization_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.override_flag			:'||p_MODIFIERS_rec.override_flag||':'||'l_MODIFIERS_rec.override_flag:'||l_MODIFIERS_rec.override_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.percent_price			:'||p_MODIFIERS_rec.percent_price||':'||'l_MODIFIERS_rec.percent_price:'||l_MODIFIERS_rec.percent_price||':');
	oe_debug_pub.add('p_MODIFIERS_rec.price_break_type_code		:'||p_MODIFIERS_rec.price_break_type_code||':'||'l_MODIFIERS_rec.price_break_type_code:'||l_MODIFIERS_rec.price_break_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.price_by_formula_id		:'||p_MODIFIERS_rec.price_by_formula_id||':'||'l_MODIFIERS_rec.price_by_formula_id:'||l_MODIFIERS_rec.price_by_formula_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.primary_uom_flag		:'||p_MODIFIERS_rec.primary_uom_flag||':'||'l_MODIFIERS_rec.primary_uom_flag:'||l_MODIFIERS_rec.primary_uom_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.print_on_invoice_flag		:'||p_MODIFIERS_rec.print_on_invoice_flag||':'||'l_MODIFIERS_rec.print_on_invoice_flag:'||l_MODIFIERS_rec.print_on_invoice_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.rebate_trxn_type_code		:'||p_MODIFIERS_rec.rebate_trxn_type_code||':'||'l_MODIFIERS_rec.rebate_trxn_type_code:'||l_MODIFIERS_rec.rebate_trxn_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.related_item_id		:'||p_MODIFIERS_rec.related_item_id||':'||'l_MODIFIERS_rec.related_item_id:'||l_MODIFIERS_rec.related_item_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.relationship_type_id		:'||p_MODIFIERS_rec.relationship_type_id||':'||'l_MODIFIERS_rec.relationship_type_id:'||l_MODIFIERS_rec.relationship_type_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.reprice_flag			:'||p_MODIFIERS_rec.reprice_flag||':'||'l_MODIFIERS_rec.reprice_flag:'||l_MODIFIERS_rec.reprice_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision			:'||p_MODIFIERS_rec.revision||':'||'l_MODIFIERS_rec.revision:'||l_MODIFIERS_rec.revision||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision_date			:'||p_MODIFIERS_rec.revision_date||':'||'l_MODIFIERS_rec.revision_date:'||l_MODIFIERS_rec.revision_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.revision_reason_code		:'||p_MODIFIERS_rec.revision_reason_code||':'||'l_MODIFIERS_rec.revision_reason_code:'||l_MODIFIERS_rec.revision_reason_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_attribute	:'||p_MODIFIERS_rec.substitution_attribute||':'||'l_MODIFIERS_rec.substitution_attribute:'||l_MODIFIERS_rec.substitution_attribute||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_context		:'||p_MODIFIERS_rec.substitution_context||':'||'l_MODIFIERS_rec.substitution_context:'||l_MODIFIERS_rec.substitution_context||':');
	oe_debug_pub.add('p_MODIFIERS_rec.substitution_value		:'||p_MODIFIERS_rec.substitution_value||':'||'l_MODIFIERS_rec.substitution_value:'||l_MODIFIERS_rec.substitution_value||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accrual_flag			:'||p_MODIFIERS_rec.accrual_flag||':'||'l_MODIFIERS_rec.accrual_flag:'||l_MODIFIERS_rec.accrual_flag||':');
	oe_debug_pub.add('p_MODIFIERS_rec.pricing_group_sequence	:'||p_MODIFIERS_rec.pricing_group_sequence||':'||'l_MODIFIERS_rec.pricing_group_sequence:'||l_MODIFIERS_rec.pricing_group_sequence||':');
	oe_debug_pub.add('p_MODIFIERS_rec.incompatibility_grp_code	:'||p_MODIFIERS_rec.incompatibility_grp_code||':'||'l_MODIFIERS_rec.incompatibility_grp_code:'||l_MODIFIERS_rec.incompatibility_grp_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_line_no			:'||p_MODIFIERS_rec.list_line_no||':'||'l_MODIFIERS_rec.list_line_no:'||l_MODIFIERS_rec.list_line_no||':');
	oe_debug_pub.add('p_MODIFIERS_rec.product_precedence		:'||p_MODIFIERS_rec.product_precedence||':'||'l_MODIFIERS_rec.product_precedence:'||l_MODIFIERS_rec.product_precedence||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_period_start_date	:'||p_MODIFIERS_rec.expiration_period_start_date||':'||'l_MODIFIERS_rec.expiration_period_start_date:'||l_MODIFIERS_rec.expiration_period_start_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.number_expiration_periods	:'||p_MODIFIERS_rec.number_expiration_periods||':'||'l_MODIFIERS_rec.number_expiration_periods:'||l_MODIFIERS_rec.number_expiration_periods||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_period_uom		:'||p_MODIFIERS_rec.expiration_period_uom||':'||'l_MODIFIERS_rec.expiration_period_uom:'||l_MODIFIERS_rec.expiration_period_uom||':');
	oe_debug_pub.add('p_MODIFIERS_rec.expiration_date		:'||p_MODIFIERS_rec.expiration_date||':'||'l_MODIFIERS_rec.expiration_date:'||l_MODIFIERS_rec.expiration_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.estim_gl_value		:'||p_MODIFIERS_rec.estim_gl_value||':'||'l_MODIFIERS_rec.estim_gl_value:'||l_MODIFIERS_rec.estim_gl_value||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_price_list_line_id	:'||p_MODIFIERS_rec.benefit_price_list_line_id||':'||'l_MODIFIERS_rec.benefit_price_list_line_id:'||l_MODIFIERS_rec.benefit_price_list_line_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_limit			:'||p_MODIFIERS_rec.benefit_limit||':'||'l_MODIFIERS_rec.benefit_limit:'||l_MODIFIERS_rec.benefit_limit||':');
	oe_debug_pub.add('p_MODIFIERS_rec.charge_type_code		:'||p_MODIFIERS_rec.charge_type_code||':'||'l_MODIFIERS_rec.charge_type_code:'||l_MODIFIERS_rec.charge_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.charge_subtype_code		:'||p_MODIFIERS_rec.charge_subtype_code||':'||'l_MODIFIERS_rec.charge_subtype_code:'||l_MODIFIERS_rec.charge_subtype_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_qty			:'||p_MODIFIERS_rec.benefit_qty||':'||'l_MODIFIERS_rec.benefit_qty:'||l_MODIFIERS_rec.benefit_qty||':');
	oe_debug_pub.add('p_MODIFIERS_rec.benefit_uom_code		:'||p_MODIFIERS_rec.benefit_uom_code||':'||'l_MODIFIERS_rec.benefit_uom_code:'||l_MODIFIERS_rec.benefit_uom_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accrual_conversion_rate	:'||p_MODIFIERS_rec.accrual_conversion_rate||':'||'l_MODIFIERS_rec.accrual_conversion_rate:'||l_MODIFIERS_rec.accrual_conversion_rate||':');
	oe_debug_pub.add('p_MODIFIERS_rec.proration_type_code		:'||p_MODIFIERS_rec.proration_type_code||':'||'l_MODIFIERS_rec.proration_type_code:'||l_MODIFIERS_rec.proration_type_code||':');
	oe_debug_pub.add('p_MODIFIERS_rec.include_on_returns_flag	:'||p_MODIFIERS_rec.include_on_returns_flag||':'||'l_MODIFIERS_rec.include_on_returns_flag:'||l_MODIFIERS_rec.include_on_returns_flag||':');

	oe_debug_pub.add('p_MODIFIERS_rec.created_by			:'||p_MODIFIERS_rec.created_by||':'||'l_MODIFIERS_rec.created_by:'||l_MODIFIERS_rec.created_by||':');
	oe_debug_pub.add('p_MODIFIERS_rec.creation_date			:'||p_MODIFIERS_rec.creation_date||':'||'l_MODIFIERS_rec.creation_date:'||l_MODIFIERS_rec.creation_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_updated_by		:'||p_MODIFIERS_rec.last_updated_by||':'||'l_MODIFIERS_rec.last_updated_by:'||l_MODIFIERS_rec.last_updated_by||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_update_date		:'||p_MODIFIERS_rec.last_update_date||':'||'l_MODIFIERS_rec.last_update_date:'||l_MODIFIERS_rec.last_update_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.last_update_login		:'||p_MODIFIERS_rec.last_update_login||':'||'l_MODIFIERS_rec.last_update_login:'||l_MODIFIERS_rec.last_update_login||':');
	oe_debug_pub.add('p_MODIFIERS_rec.list_price			:'||p_MODIFIERS_rec.list_price||':'||'l_MODIFIERS_rec.list_price:'||l_MODIFIERS_rec.list_price||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_application_id	:'||p_MODIFIERS_rec.program_application_id||':'||'l_MODIFIERS_rec.program_application_id:'||l_MODIFIERS_rec.program_application_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_id			:'||p_MODIFIERS_rec.program_id||':'||'l_MODIFIERS_rec.program_id:'||l_MODIFIERS_rec.program_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.program_update_date		:'||p_MODIFIERS_rec.program_update_date||':'||'l_MODIFIERS_rec.program_update_date:'||l_MODIFIERS_rec.program_update_date||':');
	oe_debug_pub.add('p_MODIFIERS_rec.request_id			:'||p_MODIFIERS_rec.request_id||':'||'l_MODIFIERS_rec.request_id:'||l_MODIFIERS_rec.request_id||':');
	oe_debug_pub.add('p_MODIFIERS_rec.start_date_active		:'||p_MODIFIERS_rec.start_date_active||':'||'l_MODIFIERS_rec.start_date_active:'||l_MODIFIERS_rec.start_date_active||':');
	oe_debug_pub.add('p_MODIFIERS_rec.accum_attribute		:'||p_MODIFIERS_rec.accum_attribute||':'||'l_MODIFIERS_rec.accum_attribute:'||l_MODIFIERS_rec.accum_attribute||':');

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

oe_debug_pub.add('END Lock_Row in QPXUMLLB');

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_DELETED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_LOCK_ROW_ALREADY_LOCKED');
            OE_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_MODIFIERS_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Function Get_Values

FUNCTION Get_Values
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_old_MODIFIERS_rec             IN  QP_Modifiers_PUB.Modifiers_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIERS_REC
) RETURN QP_Modifiers_PUB.Modifiers_Val_Rec_Type
IS
l_MODIFIERS_val_rec           QP_Modifiers_PUB.Modifiers_Val_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Get_Values in QPXUMLLB');

    IF p_MODIFIERS_rec.automatic_flag IS NOT NULL AND
        p_MODIFIERS_rec.automatic_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.automatic_flag,
        p_old_MODIFIERS_rec.automatic_flag)
    THEN
        l_MODIFIERS_val_rec.automatic := QP_Id_To_Value.Automatic
        (   p_automatic_flag              => p_MODIFIERS_rec.automatic_flag
        );
    END IF;

/*    IF p_MODIFIERS_rec.base_uom_code IS NOT NULL AND
        p_MODIFIERS_rec.base_uom_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.base_uom_code,
        p_old_MODIFIERS_rec.base_uom_code)
    THEN
        l_MODIFIERS_val_rec.base_uom := QP_Id_To_Value.Base_Uom
        (   p_base_uom_code               => p_MODIFIERS_rec.base_uom_code
        );
    END IF;
*/
    IF p_MODIFIERS_rec.generate_using_formula_id IS NOT NULL AND
        p_MODIFIERS_rec.generate_using_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.generate_using_formula_id,
        p_old_MODIFIERS_rec.generate_using_formula_id)
    THEN
        l_MODIFIERS_val_rec.generate_using_formula := QP_Id_To_Value.Generate_Using_Formula
        (   p_generate_using_formula_id   => p_MODIFIERS_rec.generate_using_formula_id
        );
    END IF;

    IF p_MODIFIERS_rec.inventory_item_id IS NOT NULL AND
        p_MODIFIERS_rec.inventory_item_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.inventory_item_id,
        p_old_MODIFIERS_rec.inventory_item_id)
    THEN
        l_MODIFIERS_val_rec.inventory_item := QP_Id_To_Value.Inventory_Item
        (   p_inventory_item_id           => p_MODIFIERS_rec.inventory_item_id
        );
    END IF;

    IF p_MODIFIERS_rec.list_header_id IS NOT NULL AND
        p_MODIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_header_id,
        p_old_MODIFIERS_rec.list_header_id)
    THEN
        l_MODIFIERS_val_rec.list_header := QP_Id_To_Value.List_Header
        (   p_list_header_id              => p_MODIFIERS_rec.list_header_id
        );
    END IF;

    IF p_MODIFIERS_rec.list_line_id IS NOT NULL AND
        p_MODIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_id,
        p_old_MODIFIERS_rec.list_line_id)
    THEN
        l_MODIFIERS_val_rec.list_line := QP_Id_To_Value.List_Line
        (   p_list_line_id                => p_MODIFIERS_rec.list_line_id
        );
    END IF;

    IF p_MODIFIERS_rec.list_line_type_code IS NOT NULL AND
        p_MODIFIERS_rec.list_line_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.list_line_type_code,
        p_old_MODIFIERS_rec.list_line_type_code)
    THEN
        l_MODIFIERS_val_rec.list_line_type := QP_Id_To_Value.List_Line_Type
        (   p_list_line_type_code         => p_MODIFIERS_rec.list_line_type_code
        );
    END IF;

    IF p_MODIFIERS_rec.modifier_level_code IS NOT NULL AND
        p_MODIFIERS_rec.modifier_level_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.modifier_level_code,
        p_old_MODIFIERS_rec.modifier_level_code)
    THEN
        l_MODIFIERS_val_rec.modifier_level := QP_Id_To_Value.Modifier_Level
        (   p_modifier_level_code         => p_MODIFIERS_rec.modifier_level_code
        );
    END IF;

    IF p_MODIFIERS_rec.organization_id IS NOT NULL AND
        p_MODIFIERS_rec.organization_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.organization_id,
        p_old_MODIFIERS_rec.organization_id)
    THEN
        l_MODIFIERS_val_rec.organization := QP_Id_To_Value.Organization
        (   p_organization_id             => p_MODIFIERS_rec.organization_id
        );
    END IF;

    IF p_MODIFIERS_rec.override_flag IS NOT NULL AND
        p_MODIFIERS_rec.override_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.override_flag,
        p_old_MODIFIERS_rec.override_flag)
    THEN
        l_MODIFIERS_val_rec.override := QP_Id_To_Value.Override
        (   p_override_flag               => p_MODIFIERS_rec.override_flag
        );
    END IF;

    IF p_MODIFIERS_rec.price_break_type_code IS NOT NULL AND
        p_MODIFIERS_rec.price_break_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_break_type_code,
        p_old_MODIFIERS_rec.price_break_type_code)
    THEN
        l_MODIFIERS_val_rec.price_break_type := QP_Id_To_Value.Price_Break_Type
        (   p_price_break_type_code       => p_MODIFIERS_rec.price_break_type_code
        );
    END IF;

    IF p_MODIFIERS_rec.price_by_formula_id IS NOT NULL AND
        p_MODIFIERS_rec.price_by_formula_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.price_by_formula_id,
        p_old_MODIFIERS_rec.price_by_formula_id)
    THEN
        l_MODIFIERS_val_rec.price_by_formula := QP_Id_To_Value.Price_By_Formula
        (   p_price_by_formula_id         => p_MODIFIERS_rec.price_by_formula_id
        );
    END IF;

    IF p_MODIFIERS_rec.primary_uom_flag IS NOT NULL AND
        p_MODIFIERS_rec.primary_uom_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.primary_uom_flag,
        p_old_MODIFIERS_rec.primary_uom_flag)
    THEN
        l_MODIFIERS_val_rec.primary_uom := QP_Id_To_Value.Primary_Uom
        (   p_primary_uom_flag            => p_MODIFIERS_rec.primary_uom_flag
        );
    END IF;

    IF p_MODIFIERS_rec.print_on_invoice_flag IS NOT NULL AND
        p_MODIFIERS_rec.print_on_invoice_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.print_on_invoice_flag,
        p_old_MODIFIERS_rec.print_on_invoice_flag)
    THEN
        l_MODIFIERS_val_rec.print_on_invoice := QP_Id_To_Value.Print_On_Invoice
        (   p_print_on_invoice_flag       => p_MODIFIERS_rec.print_on_invoice_flag
        );
    END IF;

    IF p_MODIFIERS_rec.rebate_trxn_type_code IS NOT NULL AND
        p_MODIFIERS_rec.rebate_trxn_type_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.rebate_trxn_type_code,
        p_old_MODIFIERS_rec.rebate_trxn_type_code)
    THEN
        l_MODIFIERS_val_rec.rebate_transaction_type := QP_Id_To_Value.Rebate_Transaction_Type
        (   p_rebate_trxn_type_code       => p_MODIFIERS_rec.rebate_trxn_type_code
        );
    END IF;

    IF p_MODIFIERS_rec.related_item_id IS NOT NULL AND
        p_MODIFIERS_rec.related_item_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.related_item_id,
        p_old_MODIFIERS_rec.related_item_id)
    THEN
        l_MODIFIERS_val_rec.related_item := QP_Id_To_Value.Related_Item
        (   p_related_item_id             => p_MODIFIERS_rec.related_item_id
        );
    END IF;

    IF p_MODIFIERS_rec.relationship_type_id IS NOT NULL AND
        p_MODIFIERS_rec.relationship_type_id <> FND_API.G_MISS_NUM AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.relationship_type_id,
        p_old_MODIFIERS_rec.relationship_type_id)
    THEN
        l_MODIFIERS_val_rec.relationship_type := QP_Id_To_Value.Relationship_Type
        (   p_relationship_type_id        => p_MODIFIERS_rec.relationship_type_id
        );
    END IF;

    IF p_MODIFIERS_rec.reprice_flag IS NOT NULL AND
        p_MODIFIERS_rec.reprice_flag <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.reprice_flag,
        p_old_MODIFIERS_rec.reprice_flag)
    THEN
        l_MODIFIERS_val_rec.reprice := QP_Id_To_Value.Reprice
        (   p_reprice_flag                => p_MODIFIERS_rec.reprice_flag
        );
    END IF;

    IF p_MODIFIERS_rec.revision_reason_code IS NOT NULL AND
        p_MODIFIERS_rec.revision_reason_code <> FND_API.G_MISS_CHAR AND
        NOT QP_GLOBALS.Equal(p_MODIFIERS_rec.revision_reason_code,
        p_old_MODIFIERS_rec.revision_reason_code)
    THEN
        l_MODIFIERS_val_rec.revision_reason := QP_Id_To_Value.Revision_Reason
        (   p_revision_reason_code        => p_MODIFIERS_rec.revision_reason_code
        );
    END IF;

oe_debug_pub.add('END Get_Values in QPXUMLLB');

    RETURN l_MODIFIERS_val_rec;

END Get_Values;

--  Function Get_Ids

FUNCTION Get_Ids
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_MODIFIERS_val_rec             IN  QP_Modifiers_PUB.Modifiers_Val_Rec_Type
) RETURN QP_Modifiers_PUB.Modifiers_Rec_Type
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
BEGIN

oe_debug_pub.add('BEGIN Get_Ids in QPXUMLLB');

    --  initialize  return_status.

    l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_MODIFIERS_rec.

    l_MODIFIERS_rec := p_MODIFIERS_rec;

    IF  p_MODIFIERS_val_rec.automatic <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.automatic_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.automatic_flag := p_MODIFIERS_rec.automatic_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.automatic_flag := QP_Value_To_Id.automatic
            (   p_automatic                   => p_MODIFIERS_val_rec.automatic
            );

            IF l_MODIFIERS_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

/*    IF  p_MODIFIERS_val_rec.base_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.base_uom_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.base_uom_code := p_MODIFIERS_rec.base_uom_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','base_uom');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.base_uom_code := QP_Value_To_Id.base_uom
            (   p_base_uom                    => p_MODIFIERS_val_rec.base_uom
            );

            IF l_MODIFIERS_rec.base_uom_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;
*/
    IF  p_MODIFIERS_val_rec.generate_using_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.generate_using_formula_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.generate_using_formula_id := p_MODIFIERS_rec.generate_using_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','generate_using_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.generate_using_formula_id := QP_Value_To_Id.generate_using_formula
            (   p_generate_using_formula      => p_MODIFIERS_val_rec.generate_using_formula
            );

            IF l_MODIFIERS_rec.generate_using_formula_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.inventory_item_id := p_MODIFIERS_rec.inventory_item_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.inventory_item_id := QP_Value_To_Id.inventory_item
            (   p_inventory_item              => p_MODIFIERS_val_rec.inventory_item
            );

            IF l_MODIFIERS_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.list_header <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.list_header_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.list_header_id := p_MODIFIERS_rec.list_header_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.list_header_id := QP_Value_To_Id.list_header
            (   p_list_header                 => p_MODIFIERS_val_rec.list_header
            );

            IF l_MODIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.list_line <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.list_line_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.list_line_id := p_MODIFIERS_rec.list_line_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.list_line_id := QP_Value_To_Id.list_line
            (   p_list_line                   => p_MODIFIERS_val_rec.list_line
            );

            IF l_MODIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.list_line_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.list_line_type_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.list_line_type_code := p_MODIFIERS_rec.list_line_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.list_line_type_code := QP_Value_To_Id.list_line_type
            (   p_list_line_type              => p_MODIFIERS_val_rec.list_line_type
            );

            IF l_MODIFIERS_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.modifier_level <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.modifier_level_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.modifier_level_code := p_MODIFIERS_rec.modifier_level_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','modifier_level');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.modifier_level_code := QP_Value_To_Id.modifier_level
            (   p_modifier_level              => p_MODIFIERS_val_rec.modifier_level
            );

            IF l_MODIFIERS_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.organization <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.organization_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.organization_id := p_MODIFIERS_rec.organization_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','organization');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.organization_id := QP_Value_To_Id.organization
            (   p_organization                => p_MODIFIERS_val_rec.organization
            );

            IF l_MODIFIERS_rec.organization_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.override <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.override_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.override_flag := p_MODIFIERS_rec.override_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','override');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.override_flag := QP_Value_To_Id.override
            (   p_override                    => p_MODIFIERS_val_rec.override
            );

            IF l_MODIFIERS_rec.override_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.price_break_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.price_break_type_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.price_break_type_code := p_MODIFIERS_rec.price_break_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_break_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.price_break_type_code := QP_Value_To_Id.price_break_type
            (   p_price_break_type            => p_MODIFIERS_val_rec.price_break_type
            );

            IF l_MODIFIERS_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.price_by_formula <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.price_by_formula_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.price_by_formula_id := p_MODIFIERS_rec.price_by_formula_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_by_formula');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.price_by_formula_id := QP_Value_To_Id.price_by_formula
            (   p_price_by_formula            => p_MODIFIERS_val_rec.price_by_formula
            );

            IF l_MODIFIERS_rec.price_by_formula_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.primary_uom <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.primary_uom_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.primary_uom_flag := p_MODIFIERS_rec.primary_uom_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','primary_uom');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.primary_uom_flag := QP_Value_To_Id.primary_uom
            (   p_primary_uom                 => p_MODIFIERS_val_rec.primary_uom
            );

            IF l_MODIFIERS_rec.primary_uom_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.print_on_invoice <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.print_on_invoice_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.print_on_invoice_flag := p_MODIFIERS_rec.print_on_invoice_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','print_on_invoice');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.print_on_invoice_flag := QP_Value_To_Id.print_on_invoice
            (   p_print_on_invoice            => p_MODIFIERS_val_rec.print_on_invoice
            );

            IF l_MODIFIERS_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.rebate_transaction_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.rebate_trxn_type_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.rebate_trxn_type_code := p_MODIFIERS_rec.rebate_trxn_type_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rebate_transaction_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.rebate_trxn_type_code := QP_Value_To_Id.rebate_transaction_type
            (   p_rebate_transaction_type     => p_MODIFIERS_val_rec.rebate_transaction_type
            );

            IF l_MODIFIERS_rec.rebate_trxn_type_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.related_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.related_item_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.related_item_id := p_MODIFIERS_rec.related_item_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','related_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.related_item_id := QP_Value_To_Id.related_item
            (   p_related_item                => p_MODIFIERS_val_rec.related_item
            );

            IF l_MODIFIERS_rec.related_item_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.relationship_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.relationship_type_id <> FND_API.G_MISS_NUM THEN

            l_MODIFIERS_rec.relationship_type_id := p_MODIFIERS_rec.relationship_type_id;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','relationship_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.relationship_type_id := QP_Value_To_Id.relationship_type
            (   p_relationship_type           => p_MODIFIERS_val_rec.relationship_type
            );

            IF l_MODIFIERS_rec.relationship_type_id = FND_API.G_MISS_NUM THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.reprice <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.reprice_flag <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.reprice_flag := p_MODIFIERS_rec.reprice_flag;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','reprice');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.reprice_flag := QP_Value_To_Id.reprice
            (   p_reprice                     => p_MODIFIERS_val_rec.reprice
            );

            IF l_MODIFIERS_rec.reprice_flag = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_MODIFIERS_val_rec.revision_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_MODIFIERS_rec.revision_reason_code <> FND_API.G_MISS_CHAR THEN

            l_MODIFIERS_rec.revision_reason_code := p_MODIFIERS_rec.revision_reason_code;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','revision_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            l_MODIFIERS_rec.revision_reason_code := QP_Value_To_Id.revision_reason
            (   p_revision_reason             => p_MODIFIERS_val_rec.revision_reason
            );

            IF l_MODIFIERS_rec.revision_reason_code = FND_API.G_MISS_CHAR THEN
                l_MODIFIERS_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


oe_debug_pub.add('END Get_Ids in QPXUMLLB');

    RETURN l_MODIFIERS_rec;

END Get_Ids;


Procedure Pre_Write_Process
(   p_MODIFIERS_rec                      IN  QP_Modifiers_PUB.MODIFIERS_rec_Type
,   p_old_MODIFIERS_rec                  IN  QP_Modifiers_PUB.MODIFIERS_rec_Type
          := QP_Modifiers_PUB.G_MISS_MODIFIERS_rec
,   x_MODIFIERS_rec                      OUT NOCOPY QP_Modifiers_PUB.MODIFIERS_rec_Type
) IS
l_Modifiers_rec              QP_MODIFIERS_PUB.MODIFIERS_rec_Type := p_MODIFIERS_rec;
l_return_status         varchar2(30);
l_parent_line_type      QP_LIST_LINES.LIST_LINE_TYPE_CODE%TYPE := 'NONE';
l_count NUMBER ;
l_active_flag VARCHAR2(1) ;
l_call_from NUMBER;

/*
l_product_attribute     varchar2(30) := null;
l_product_attr_value    varchar2(240) := null;
l_pricing_phase_id      number;
*/
BEGIN

  oe_debug_pub.Add('Entering QP_MODIFIERS_Util.pre_write_process', 1);

  x_MODIFIERS_rec := l_MODIFIERS_rec;

  -- jagan's PL/SQL pattern
  IF QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'N' THEN
    IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
      IF (p_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
	    qp_delayed_requests_pvt.log_request(
		p_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_unique_key1 => p_MODIFIERS_rec.list_line_id,
		p_request_unique_key2 => 'I',
		p_requesting_entity_code => QP_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id => p_MODIFIERS_rec.list_header_id,
		p_request_type => QP_GLOBALS.G_MAINTAIN_PRODUCT_PATTERN,
		x_return_status => l_return_status);

     END IF;
   END IF; --PL/SQL pattern search
 END IF; --- Java Engine Installed

  IF   ( p_MODIFIERS_rec.operation IN
    (OE_GLOBALS.G_OPR_CREATE, OE_GLOBALS.G_OPR_UPDATE)) THEN

    oe_debug_pub.add('request to update QP_PRICING_PHASES  '||l_parent_line_type, 1);

  IF p_MODIFIERS_rec.list_line_type_code IN ('RLTD','OID','CIE','TSN','IUE','PRG','FREIGHT_CHARGE')
    OR p_MODIFIERS_rec.modifier_level_code = 'LINEGROUP' THEN

    oe_debug_pub.add('Logging a request to update QP_PRICING_PHASES  ', 1);
--------------------------------- fix for bug 3756625
    l_call_from :=1;
  if((p_MODIFIERS_rec.operation) IN(OE_GLOBALS.G_OPR_CREATE)) or
     ((p_MODIFIERS_rec.operation) IN(OE_GLOBALS.G_OPR_UPDATE) and
      (p_old_MODIFIERS_rec.pricing_phase_id <> p_MODIFIERS_rec.pricing_phase_id))
        then
          qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_MODIFIERS_rec.pricing_phase_id,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);

    if ((p_MODIFIERS_rec.operation) NOT IN(OE_GLOBALS.G_OPR_CREATE)) then
    qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_old_MODIFIERS_rec.pricing_phase_id,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);
  end if;
 end if;

 END IF;
if (p_MODIFIERS_rec.operation) IN(OE_GLOBALS.G_OPR_UPDATE)
 then
    l_call_from :=2;
   if (p_old_MODIFIERS_rec.pricing_phase_id <> p_MODIFIERS_rec.pricing_phase_id)
  then
         Log_Update_Phases_DL(p_MODIFIERS_rec => p_MODIFIERS_rec,
                              x_return_status => l_return_status);
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_old_MODIFIERS_rec.pricing_phase_id,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);
    end if;
   if  p_MODIFIERS_rec.automatic_flag <> p_old_MODIFIERS_rec.automatic_flag then
    select active_flag into l_active_flag from qp_list_headers_b
    where list_header_id =p_MODIFIERS_rec.list_header_id;
    if l_active_flag ='Y' then
     begin
       select count(*) into l_count from qp_list_lines qll
       where automatic_flag = p_old_MODIFIERS_rec.automatic_flag and
       pricing_phase_id = p_MODIFIERS_rec.pricing_phase_id;
     exception
       when no_data_found then
        l_count :=0;
      end;
  if l_count >0 then
       qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_MODIFIERS_rec.pricing_phase_id,
                  p_param2  => p_MODIFIERS_rec.automatic_flag,
                  p_param3  => l_count,
      p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);
end if;
end if;
end if;
end if;
  END IF;

 -- Essilor Fix bug 2789138
  IF    p_MODIFIERS_rec.list_line_type_code <> 'PMR' AND
p_MODIFIERS_rec.operation = OE_GLOBALS.G_OPR_CREATE then

    oe_debug_pub.add('request to update G_UPDATE_MANUAL_MODIFIER_FLAG  '||l_parent_line_type, 1);
    oe_debug_pub.add('Logging a request to update G_UPDATE_MANUAL_MODIFIER_FLAG ', 1);

         qp_delayed_requests_PVT.log_request(
                 p_entity_code            => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_entity_id              => p_MODIFIERS_rec.list_line_id,
                 p_param1                 => p_MODIFIERS_rec.pricing_phase_id,
                 p_param2                 => p_MODIFIERS_rec.automatic_flag,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id   => p_MODIFIERS_rec.list_line_id,
                 p_request_type           => QP_GLOBALS.G_UPDATE_MANUAL_MODIFIER_FLAG,
                 x_return_status          => l_return_status);
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        RAISE;
    WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Pre_Write_Process'
            );
       END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Pre_Write_Process;

------------------------------fix for bug 3756625
Procedure Log_Update_Phases_DL(p_MODIFIERS_rec IN QP_Modifiers_PUB.MODIFIERS_rec_Type,
                               x_return_status OUT NOCOPY VARCHAR2)
IS
l_active_flag varchar2(1);
l_manual_modifier_flag varchar2(1);
l_return_status varchar2(30);
l_call_from NUMBER :=2;
BEGIN

select active_flag into l_active_flag from qp_list_headers
where list_header_id = p_MODIFIERS_rec.list_header_id;
 if (l_active_flag = 'Y') then
  select manual_modifier_flag into l_manual_modifier_flag
   from qp_pricing_phases
    where pricing_phase_id = p_MODIFIERS_rec.pricing_phase_id;

 if l_manual_modifier_flag is null then
  qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_MODIFIERS_rec.pricing_phase_id,
                  p_param2 => p_MODIFIERS_rec.automatic_flag,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);

 elsif l_manual_modifier_flag = 'A' then
    if( p_MODIFIERS_rec.automatic_flag = 'Y') then
       null;
    else
       qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_MODIFIERS_rec.pricing_phase_id,
                  p_param2 => p_MODIFIERS_rec.automatic_flag,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);
    end if;
 elsif l_manual_modifier_flag ='M' then
   if (p_MODIFIERS_rec.automatic_flag = 'N') then
      null;
   else
     qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_MODIFIER_LIST,
                  p_entity_id  => p_MODIFIERS_rec.list_header_id,
                  p_param1  => p_MODIFIERS_rec.pricing_phase_id,
                  p_param2 => p_MODIFIERS_rec.automatic_flag,
                  p_param4 => l_call_from,
                 p_requesting_entity_code => QP_GLOBALS.G_ENTITY_MODIFIERS,
                 p_requesting_entity_id => p_MODIFIERS_rec.list_line_id,
                 p_request_type => QP_GLOBALS.G_UPDATE_PRICING_PHASE,
                 x_return_status => l_return_status);
    end if;
else
null;
end if;
end if;
END Log_Update_Phases_DL;
END QP_Modifiers_Util;

/
