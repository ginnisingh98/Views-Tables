--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_MODIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_MODIFIERS" AS
/* $Header: QPXFMLLB.pls 120.5 2006/03/06 00:02:41 nirmkuma noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Modifiers';

--  Global variables holding cached record.

g_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
g_db_MODIFIERS_rec            QP_Modifiers_PUB.Modifiers_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_MODIFIERS
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_MODIFIERS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_line_id                  IN  NUMBER
)
RETURN QP_Modifiers_PUB.Modifiers_Rec_Type;

PROCEDURE Clear_MODIFIERS;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Modifiers_PUB.Modifiers_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_list_header_id                IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_arithmetic_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_gl_class_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_list_price_uom_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_new_price                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_trxn_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_relationship_type_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_substitution_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_context          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_gl_class                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_list_price_uom                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_group_sequence        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_incompatibility_grp_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_start_date  OUT NOCOPY /* file.sql.39 change */ DATE
,   x_number_expiration_periods     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_uom         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_gl_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_price_list_line_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_recurring_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_limit                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_conversion_rate       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_proration_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_to_rltd_modifier_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_no          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_net_amount_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accum_attribute               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_continuous_price_break_flag       OUT NOCOPY VARCHAR2  --Continuous Price Breaks
)
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_val_rec           QP_Modifiers_PUB.Modifiers_Val_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Default_Attributes in QPXFMLLB');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist

    l_MODIFIERS_rec.list_header_id                := p_list_header_id;


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_MODIFIERS_rec.attribute1                    := NULL;
    l_MODIFIERS_rec.attribute10                   := NULL;
    l_MODIFIERS_rec.attribute11                   := NULL;
    l_MODIFIERS_rec.attribute12                   := NULL;
    l_MODIFIERS_rec.attribute13                   := NULL;
    l_MODIFIERS_rec.attribute14                   := NULL;
    l_MODIFIERS_rec.attribute15                   := NULL;
    l_MODIFIERS_rec.attribute2                    := NULL;
    l_MODIFIERS_rec.attribute3                    := NULL;
    l_MODIFIERS_rec.attribute4                    := NULL;
    l_MODIFIERS_rec.attribute5                    := NULL;
    l_MODIFIERS_rec.attribute6                    := NULL;
    l_MODIFIERS_rec.attribute7                    := NULL;
    l_MODIFIERS_rec.attribute8                    := NULL;
    l_MODIFIERS_rec.attribute9                    := NULL;
    l_MODIFIERS_rec.context                       := NULL;

    --  Set Operation to Create

    l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate MODIFIERS table

    l_MODIFIERS_tbl(1) := l_MODIFIERS_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_MODIFIERS_rec := l_x_MODIFIERS_tbl(1);

    --  Load OUT parameters.

    x_arithmetic_operator          := l_x_MODIFIERS_rec.arithmetic_operator;
    x_attribute1                   := l_x_MODIFIERS_rec.attribute1;
    x_attribute10                  := l_x_MODIFIERS_rec.attribute10;
    x_attribute11                  := l_x_MODIFIERS_rec.attribute11;
    x_attribute12                  := l_x_MODIFIERS_rec.attribute12;
    x_attribute13                  := l_x_MODIFIERS_rec.attribute13;
    x_attribute14                  := l_x_MODIFIERS_rec.attribute14;
    x_attribute15                  := l_x_MODIFIERS_rec.attribute15;
    x_attribute2                   := l_x_MODIFIERS_rec.attribute2;
    x_attribute3                   := l_x_MODIFIERS_rec.attribute3;
    x_attribute4                   := l_x_MODIFIERS_rec.attribute4;
    x_attribute5                   := l_x_MODIFIERS_rec.attribute5;
    x_attribute6                   := l_x_MODIFIERS_rec.attribute6;
    x_attribute7                   := l_x_MODIFIERS_rec.attribute7;
    x_attribute8                   := l_x_MODIFIERS_rec.attribute8;
    x_attribute9                   := l_x_MODIFIERS_rec.attribute9;
    x_automatic_flag               := l_x_MODIFIERS_rec.automatic_flag;
--    x_base_qty                     := l_x_MODIFIERS_rec.base_qty;
    x_pricing_phase_id             := l_x_MODIFIERS_rec.pricing_phase_id;
--    x_base_uom_code                := l_x_MODIFIERS_rec.base_uom_code;
    x_comments                     := l_x_MODIFIERS_rec.comments;
    x_context                      := l_x_MODIFIERS_rec.context;
    x_effective_period_uom         := l_x_MODIFIERS_rec.effective_period_uom;
    x_end_date_active              := l_x_MODIFIERS_rec.end_date_active;
    x_estim_accrual_rate           := l_x_MODIFIERS_rec.estim_accrual_rate;
    x_generate_using_formula_id    := l_x_MODIFIERS_rec.generate_using_formula_id;
--    x_gl_class_id                  := l_x_MODIFIERS_rec.gl_class_id;
    x_inventory_item_id            := l_x_MODIFIERS_rec.inventory_item_id;
    x_list_header_id               := l_x_MODIFIERS_rec.list_header_id;
    x_list_line_id                 := l_x_MODIFIERS_rec.list_line_id;
    x_list_line_type_code          := l_x_MODIFIERS_rec.list_line_type_code;
    x_list_price                   := l_x_MODIFIERS_rec.list_price;
--    x_list_price_uom_code          := l_x_MODIFIERS_rec.list_price_uom_code;
    x_modifier_level_code          := l_x_MODIFIERS_rec.modifier_level_code;
--    x_new_price                    := l_x_MODIFIERS_rec.new_price;
    x_number_effective_periods     := l_x_MODIFIERS_rec.number_effective_periods;
    x_operand                      := l_x_MODIFIERS_rec.operand;
    x_organization_id              := l_x_MODIFIERS_rec.organization_id;
    x_override_flag                := l_x_MODIFIERS_rec.override_flag;
    x_percent_price                := l_x_MODIFIERS_rec.percent_price;
    x_price_break_type_code        := l_x_MODIFIERS_rec.price_break_type_code;
    x_price_by_formula_id          := l_x_MODIFIERS_rec.price_by_formula_id;
    x_primary_uom_flag             := l_x_MODIFIERS_rec.primary_uom_flag;
    x_print_on_invoice_flag        := l_x_MODIFIERS_rec.print_on_invoice_flag;
--    x_rebate_subtype_code          := l_x_MODIFIERS_rec.rebate_subtype_code;
    x_rebate_trxn_type_code        := l_x_MODIFIERS_rec.rebate_trxn_type_code;
    x_related_item_id              := l_x_MODIFIERS_rec.related_item_id;
    x_relationship_type_id         := l_x_MODIFIERS_rec.relationship_type_id;
    x_reprice_flag                 := l_x_MODIFIERS_rec.reprice_flag;
    x_revision                     := l_x_MODIFIERS_rec.revision;
    x_revision_date                := l_x_MODIFIERS_rec.revision_date;
    x_revision_reason_code         := l_x_MODIFIERS_rec.revision_reason_code;
    x_start_date_active            := l_x_MODIFIERS_rec.start_date_active;
    x_substitution_attribute       := l_x_MODIFIERS_rec.substitution_attribute;
    x_substitution_context         := l_x_MODIFIERS_rec.substitution_context;
    x_substitution_value           := l_x_MODIFIERS_rec.substitution_value;
    x_accrual_flag                 := l_x_MODIFIERS_rec.accrual_flag;
    x_pricing_group_sequence       := l_x_MODIFIERS_rec.pricing_group_sequence;
    x_incompatibility_grp_code     := l_x_MODIFIERS_rec.incompatibility_grp_code;
    x_list_line_no                 := l_x_MODIFIERS_rec.list_line_no;
    x_product_precedence           := l_x_MODIFIERS_rec.product_precedence;
    x_expiration_period_start_date := l_x_MODIFIERS_rec.expiration_period_start_date;
    x_number_expiration_periods    := l_x_MODIFIERS_rec.number_expiration_periods;
    x_expiration_period_uom        := l_x_MODIFIERS_rec.expiration_period_uom;
    x_expiration_date              := l_x_MODIFIERS_rec.expiration_date;
    x_estim_gl_value               := l_x_MODIFIERS_rec.estim_gl_value;
    x_benefit_price_list_line_id   := l_x_MODIFIERS_rec.benefit_price_list_line_id;
--    x_recurring_flag               := l_x_MODIFIERS_rec.recurring_flag;
    x_benefit_limit                := l_x_MODIFIERS_rec.benefit_limit;
    x_charge_type_code             := l_x_MODIFIERS_rec.charge_type_code;
    x_charge_subtype_code          := l_x_MODIFIERS_rec.charge_subtype_code;
    x_benefit_qty                  := l_x_MODIFIERS_rec.benefit_qty;
    x_benefit_uom_code             := l_x_MODIFIERS_rec.benefit_uom_code;
    x_accrual_conversion_rate      := l_x_MODIFIERS_rec.accrual_conversion_rate;
    x_proration_type_code          := l_x_MODIFIERS_rec.proration_type_code;
    x_include_on_returns_flag      := l_x_MODIFIERS_rec.include_on_returns_flag;
    x_from_rltd_modifier_id        := l_x_MODIFIERS_rec.from_rltd_modifier_id;
    x_to_rltd_modifier_id          := l_x_MODIFIERS_rec.to_rltd_modifier_id;
    x_rltd_modifier_grp_no         := l_x_MODIFIERS_rec.rltd_modifier_grp_no;
    x_rltd_modifier_grp_type       := l_x_MODIFIERS_rec.rltd_modifier_grp_type;
    x_net_amount_flag              := l_x_MODIFIERS_rec.net_amount_flag;
    x_accum_attribute              := l_x_MODIFIERS_rec.accum_attribute;
    x_continuous_price_break_flag      := l_x_MODIFIERS_rec.continuous_price_break_flag;
    						--Continuous Price Breaks
    --  Load display out parameters if any

    l_MODIFIERS_val_rec := QP_Modifiers_Util.Get_Values
    (   p_MODIFIERS_rec               => l_x_MODIFIERS_rec
    );
    x_automatic                    := l_MODIFIERS_val_rec.automatic;
--    x_base_uom                     := l_MODIFIERS_val_rec.base_uom;
    x_generate_using_formula       := l_MODIFIERS_val_rec.generate_using_formula;
--    x_gl_class                     := l_MODIFIERS_val_rec.gl_class;
    x_inventory_item               := l_MODIFIERS_val_rec.inventory_item;
    x_list_header                  := l_MODIFIERS_val_rec.list_header;
    x_list_line                    := l_MODIFIERS_val_rec.list_line;
    x_list_line_type               := l_MODIFIERS_val_rec.list_line_type;
--    x_list_price_uom               := l_MODIFIERS_val_rec.list_price_uom;
    x_modifier_level               := l_MODIFIERS_val_rec.modifier_level;
    x_organization                 := l_MODIFIERS_val_rec.organization;
    x_override                     := l_MODIFIERS_val_rec.override;
    x_price_break_type             := l_MODIFIERS_val_rec.price_break_type;
    x_price_by_formula             := l_MODIFIERS_val_rec.price_by_formula;
    x_primary_uom                  := l_MODIFIERS_val_rec.primary_uom;
    x_print_on_invoice             := l_MODIFIERS_val_rec.print_on_invoice;
--    x_rebate_subtype               := l_MODIFIERS_val_rec.rebate_subtype;
    x_rebate_transaction_type      := l_MODIFIERS_val_rec.rebate_transaction_type;
    x_related_item                 := l_MODIFIERS_val_rec.related_item;
    x_relationship_type            := l_MODIFIERS_val_rec.relationship_type;
    x_reprice                      := l_MODIFIERS_val_rec.reprice;
    x_revision_reason              := l_MODIFIERS_val_rec.revision_reason;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_MODIFIERS_rec.db_flag := FND_API.G_FALSE;

    Write_MODIFIERS
    (   p_MODIFIERS_rec               => l_x_MODIFIERS_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Default_Attributes in QPXFMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_arithmetic_operator           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_phase_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_gl_class_id                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_list_price_uom_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_new_price                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_trxn_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_relationship_type_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_substitution_attribute        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_context          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_substitution_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_gl_class                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_list_price_uom                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_rebate_subtype                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_group_sequence        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_incompatibility_grp_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_no                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_start_date  OUT NOCOPY /* file.sql.39 change */ DATE
,   x_number_expiration_periods     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_expiration_period_uom         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_expiration_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_gl_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_price_list_line_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--,   x_recurring_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_limit                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charge_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_charge_subtype_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_benefit_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_benefit_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accrual_conversion_rate       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_proration_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_include_on_returns_flag       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_to_rltd_modifier_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_no          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_grp_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_net_amount_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accum_attribute               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_continuous_price_break_flag       OUT NOCOPY VARCHAR2  --Continuous Price Breaks
)
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_old_MODIFIERS_rec           QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_val_rec           QP_Modifiers_PUB.Modifiers_Val_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_old_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Change_attribute in QPXFMLLB');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read MODIFIERS from cache

    l_MODIFIERS_rec := Get_MODIFIERS
    (   p_db_record                   => FALSE
    ,   p_list_line_id                => p_list_line_id
    );

    l_old_MODIFIERS_rec            := l_MODIFIERS_rec;



    IF p_attr_id = QP_Modifiers_Util.G_ARITHMETIC_OPERATOR THEN
        l_MODIFIERS_rec.arithmetic_operator := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_AUTOMATIC THEN
        l_MODIFIERS_rec.automatic_flag := p_attr_value;
--    ELSIF p_attr_id = QP_Modifiers_Util.G_BASE_QTY THEN
--        l_MODIFIERS_rec.base_qty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRICING_PHASE THEN
        l_MODIFIERS_rec.pricing_phase_id := TO_NUMBER(p_attr_value);
--    ELSIF p_attr_id = QP_Modifiers_Util.G_BASE_UOM THEN
--        l_MODIFIERS_rec.base_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_COMMENTS THEN
        l_MODIFIERS_rec.comments := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_EFFECTIVE_PERIOD_UOM THEN
        l_MODIFIERS_rec.effective_period_uom := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_END_DATE_ACTIVE THEN
        l_MODIFIERS_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifiers_Util.G_ESTIM_ACCRUAL_RATE THEN
        l_MODIFIERS_rec.estim_accrual_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_GENERATE_USING_FORMULA THEN
        l_MODIFIERS_rec.generate_using_formula_id := TO_NUMBER(p_attr_value);
--    ELSIF p_attr_id = QP_Modifiers_Util.G_GL_CLASS THEN
--        l_MODIFIERS_rec.gl_class_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_INVENTORY_ITEM THEN
        l_MODIFIERS_rec.inventory_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_HEADER THEN
        l_MODIFIERS_rec.list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_LINE THEN
        l_MODIFIERS_rec.list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_LINE_TYPE THEN
        l_MODIFIERS_rec.list_line_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_PRICE THEN
        l_MODIFIERS_rec.list_price := TO_NUMBER(p_attr_value);
--    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_PRICE_UOM THEN
--        l_MODIFIERS_rec.list_price_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_MODIFIER_LEVEL THEN
        l_MODIFIERS_rec.modifier_level_code := p_attr_value;
--    ELSIF p_attr_id = QP_Modifiers_Util.G_NEW_PRICE THEN
--        l_MODIFIERS_rec.new_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_NUMBER_EFFECTIVE_PERIODS THEN
        l_MODIFIERS_rec.number_effective_periods := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_OPERAND THEN
        l_MODIFIERS_rec.operand := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_ORGANIZATION THEN
        l_MODIFIERS_rec.organization_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_OVERRIDE THEN
        l_MODIFIERS_rec.override_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_PERCENT_PRICE THEN
        l_MODIFIERS_rec.percent_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRICE_BREAK_TYPE THEN
        l_MODIFIERS_rec.price_break_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRICE_BY_FORMULA THEN
        l_MODIFIERS_rec.price_by_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRIMARY_UOM THEN
        l_MODIFIERS_rec.primary_uom_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRINT_ON_INVOICE THEN
OE_Debug_Pub.add(to_char(QP_Modifiers_Util.G_PRINT_ON_INVOICE)||to_char(p_attr_id));
        l_MODIFIERS_rec.print_on_invoice_flag := p_attr_value;
--    ELSIF p_attr_id = QP_Modifiers_Util.G_REBATE_SUBTYPE THEN
--        l_MODIFIERS_rec.rebate_subtype_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_REBATE_TRANSACTION_TYPE THEN
        l_MODIFIERS_rec.rebate_trxn_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_RELATED_ITEM THEN
        l_MODIFIERS_rec.related_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_RELATIONSHIP_TYPE THEN
        l_MODIFIERS_rec.relationship_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_REPRICE THEN
        l_MODIFIERS_rec.reprice_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_REVISION THEN
        l_MODIFIERS_rec.revision := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_REVISION_DATE THEN
        l_MODIFIERS_rec.revision_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifiers_Util.G_REVISION_REASON THEN
        l_MODIFIERS_rec.revision_reason_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_START_DATE_ACTIVE THEN
        l_MODIFIERS_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifiers_Util.G_SUBSTITUTION_ATTRIBUTE THEN
        l_MODIFIERS_rec.substitution_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_SUBSTITUTION_CONTEXT THEN
        l_MODIFIERS_rec.substitution_context := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_SUBSTITUTION_VALUE THEN
        l_MODIFIERS_rec.substitution_value := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_ACCRUAL_FLAG THEN
        l_MODIFIERS_rec.accrual_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRICING_GROUP_SEQUENCE THEN
        l_MODIFIERS_rec.pricing_group_sequence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_INCOMPATIBILITY_GRP_CODE THEN
        l_MODIFIERS_rec.incompatibility_grp_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_LIST_LINE_NO THEN
        l_MODIFIERS_rec.list_line_no := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRODUCT_PRECEDENCE THEN
        l_MODIFIERS_rec.product_precedence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_EXPIRATION_PERIOD_START_DATE THEN
        l_MODIFIERS_rec.expiration_period_start_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifiers_Util.G_NUMBER_EXPIRATION_PERIODS THEN
        l_MODIFIERS_rec.number_expiration_periods := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_EXPIRATION_PERIOD_UOM THEN
        l_MODIFIERS_rec.expiration_period_uom := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_EXPIRATION_DATE THEN
        l_MODIFIERS_rec.expiration_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifiers_Util.G_ESTIM_GL_VALUE THEN
        l_MODIFIERS_rec.estim_gl_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_BENEFIT_PRICE_LIST_LINE THEN
        l_MODIFIERS_rec.benefit_price_list_line_id := TO_NUMBER(p_attr_value);
--    ELSIF p_attr_id = QP_Modifiers_Util.G_RECURRING_FLAG THEN
--        l_MODIFIERS_rec.recurring_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_BENEFIT_LIMIT THEN
        l_MODIFIERS_rec.benefit_limit := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_CHARGE_TYPE THEN
        l_MODIFIERS_rec.charge_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_CHARGE_SUBTYPE THEN
        l_MODIFIERS_rec.charge_subtype_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_BENEFIT_QTY THEN
        l_MODIFIERS_rec.benefit_qty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_BENEFIT_UOM THEN
        l_MODIFIERS_rec.benefit_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_ACCRUAL_CONVERSION_RATE THEN
        l_MODIFIERS_rec.accrual_conversion_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_PRORATION_TYPE THEN
        l_MODIFIERS_rec.proration_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_INCLUDE_ON_RETURNS_FLAG THEN
        l_MODIFIERS_rec.include_on_returns_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_FROM_RLTD_MODIFIER THEN
        l_MODIFIERS_rec.from_rltd_modifier_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_TO_RLTD_MODIFIER THEN
        l_MODIFIERS_rec.to_rltd_modifier_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_RLTD_MODIFIER_GRP_NO THEN
        l_MODIFIERS_rec.rltd_modifier_grp_no := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifiers_Util.G_RLTD_MODIFIER_GRP_TYPE THEN
        l_MODIFIERS_rec.rltd_modifier_grp_type := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_NET_AMOUNT THEN
        l_MODIFIERS_rec.net_amount_flag  := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_ACCUM_ATTRIBUTE THEN
        l_MODIFIERS_rec.accum_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Modifiers_Util.G_continuous_price_break_flag THEN
        l_MODIFIERS_rec.continuous_price_break_flag := p_attr_value; --Continuous
								 --Price Breaks
    ELSIF p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Modifiers_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Modifiers_Util.G_CONTEXT
    THEN

        l_MODIFIERS_rec.attribute1     := p_attribute1;
        l_MODIFIERS_rec.attribute10    := p_attribute10;
        l_MODIFIERS_rec.attribute11    := p_attribute11;
        l_MODIFIERS_rec.attribute12    := p_attribute12;
        l_MODIFIERS_rec.attribute13    := p_attribute13;
        l_MODIFIERS_rec.attribute14    := p_attribute14;
        l_MODIFIERS_rec.attribute15    := p_attribute15;
        l_MODIFIERS_rec.attribute2     := p_attribute2;
        l_MODIFIERS_rec.attribute3     := p_attribute3;
        l_MODIFIERS_rec.attribute4     := p_attribute4;
        l_MODIFIERS_rec.attribute5     := p_attribute5;
        l_MODIFIERS_rec.attribute6     := p_attribute6;
        l_MODIFIERS_rec.attribute7     := p_attribute7;
        l_MODIFIERS_rec.attribute8     := p_attribute8;
        l_MODIFIERS_rec.attribute9     := p_attribute9;
        l_MODIFIERS_rec.context        := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_MODIFIERS_rec.db_flag) THEN
        l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate MODIFIERS table

    l_MODIFIERS_tbl(1) := l_MODIFIERS_rec;
    l_old_MODIFIERS_tbl(1) := l_old_MODIFIERS_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   p_old_MODIFIERS_tbl           => l_old_MODIFIERS_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_MODIFIERS_rec := l_x_MODIFIERS_tbl(1);

    --  Init OUT parameters to missing.

    x_arithmetic_operator          := FND_API.G_MISS_CHAR;
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_automatic_flag               := FND_API.G_MISS_CHAR;
--    x_base_qty                     := FND_API.G_MISS_NUM;
    x_pricing_phase_id             := FND_API.G_MISS_NUM;
--    x_base_uom_code                := FND_API.G_MISS_CHAR;
    x_comments                     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_effective_period_uom         := FND_API.G_MISS_CHAR;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_estim_accrual_rate           := FND_API.G_MISS_NUM;
    x_generate_using_formula_id    := FND_API.G_MISS_NUM;
--    x_gl_class_id                  := FND_API.G_MISS_NUM;
    x_inventory_item_id            := FND_API.G_MISS_NUM;
    x_list_header_id               := FND_API.G_MISS_NUM;
    x_list_line_id                 := FND_API.G_MISS_NUM;
    x_list_line_type_code          := FND_API.G_MISS_CHAR;
    x_list_price                   := FND_API.G_MISS_NUM;
--    x_list_price_uom_code          := FND_API.G_MISS_CHAR;
    x_modifier_level_code          := FND_API.G_MISS_CHAR;
--    x_new_price                    := FND_API.G_MISS_NUM;
    x_number_effective_periods     := FND_API.G_MISS_NUM;
    x_operand                      := FND_API.G_MISS_NUM;
    x_organization_id              := FND_API.G_MISS_NUM;
    x_override_flag                := FND_API.G_MISS_CHAR;
    x_percent_price                := FND_API.G_MISS_NUM;
    x_price_break_type_code        := FND_API.G_MISS_CHAR;
    x_price_by_formula_id          := FND_API.G_MISS_NUM;
    x_primary_uom_flag             := FND_API.G_MISS_CHAR;
    x_print_on_invoice_flag        := FND_API.G_MISS_CHAR;
--    x_rebate_subtype_code          := FND_API.G_MISS_CHAR;
    x_rebate_trxn_type_code        := FND_API.G_MISS_CHAR;
    x_related_item_id              := FND_API.G_MISS_NUM;
    x_relationship_type_id         := FND_API.G_MISS_NUM;
    x_reprice_flag                 := FND_API.G_MISS_CHAR;
    x_revision                     := FND_API.G_MISS_CHAR;
    x_revision_date                := FND_API.G_MISS_DATE;
    x_revision_reason_code         := FND_API.G_MISS_CHAR;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_substitution_attribute       := FND_API.G_MISS_CHAR;
    x_substitution_context         := FND_API.G_MISS_CHAR;
    x_substitution_value           := FND_API.G_MISS_CHAR;
    x_automatic                    := FND_API.G_MISS_CHAR;
--    x_base_uom                     := FND_API.G_MISS_CHAR;
    x_generate_using_formula       := FND_API.G_MISS_CHAR;
--    x_gl_class                     := FND_API.G_MISS_CHAR;
    x_inventory_item               := FND_API.G_MISS_CHAR;
    x_list_header                  := FND_API.G_MISS_CHAR;
    x_list_line                    := FND_API.G_MISS_CHAR;
    x_list_line_type               := FND_API.G_MISS_CHAR;
--    x_list_price_uom               := FND_API.G_MISS_CHAR;
    x_modifier_level               := FND_API.G_MISS_CHAR;
    x_organization                 := FND_API.G_MISS_CHAR;
    x_override                     := FND_API.G_MISS_CHAR;
    x_price_break_type             := FND_API.G_MISS_CHAR;
    x_price_by_formula             := FND_API.G_MISS_CHAR;
    x_primary_uom                  := FND_API.G_MISS_CHAR;
    x_print_on_invoice             := FND_API.G_MISS_CHAR;
--    x_rebate_subtype               := FND_API.G_MISS_CHAR;
    x_rebate_transaction_type      := FND_API.G_MISS_CHAR;
    x_related_item                 := FND_API.G_MISS_CHAR;
    x_relationship_type            := FND_API.G_MISS_CHAR;
    x_reprice                      := FND_API.G_MISS_CHAR;
    x_revision_reason              := FND_API.G_MISS_CHAR;
    x_accrual_flag                 := FND_API.G_MISS_CHAR;
    x_pricing_group_sequence       := FND_API.G_MISS_NUM;
    x_incompatibility_grp_code     := FND_API.G_MISS_CHAR;
    x_list_line_no                 := FND_API.G_MISS_CHAR;
    x_product_precedence           := FND_API.G_MISS_NUM;
    x_expiration_period_start_date := FND_API.G_MISS_DATE;
    x_number_expiration_periods    := FND_API.G_MISS_NUM;
    x_expiration_period_uom        := FND_API.G_MISS_CHAR;
    x_expiration_date              := FND_API.G_MISS_DATE;
    x_estim_gl_value               := FND_API.G_MISS_NUM;
    x_benefit_price_list_line_id   := FND_API.G_MISS_NUM;
--    x_recurring_flag               := FND_API.G_MISS_CHAR;
    x_benefit_limit                := FND_API.G_MISS_NUM;
    x_charge_type_code             := FND_API.G_MISS_CHAR;
    x_charge_subtype_code          := FND_API.G_MISS_CHAR;
    x_benefit_qty                  := FND_API.G_MISS_NUM;
    x_benefit_uom_code             := FND_API.G_MISS_CHAR;
    x_accrual_conversion_rate      := FND_API.G_MISS_NUM;
    x_proration_type_code          := FND_API.G_MISS_CHAR;
    x_include_on_returns_flag      := FND_API.G_MISS_CHAR;
    x_from_rltd_modifier_id        := FND_API.G_MISS_NUM;
    x_to_rltd_modifier_id          := FND_API.G_MISS_NUM;
    x_rltd_modifier_grp_no         := FND_API.G_MISS_NUM;
    x_rltd_modifier_grp_type       := FND_API.G_MISS_CHAR;
    x_net_amount_flag              := FND_API.G_MISS_CHAR;
    x_accum_attribute              := FND_API.G_MISS_CHAR;
    x_continuous_price_break_flag      := FND_API.G_MISS_CHAR; --Continuous Price Breaks

    --  Load display out parameters if any

    l_MODIFIERS_val_rec := QP_Modifiers_Util.Get_Values
    (   p_MODIFIERS_rec               => l_x_MODIFIERS_rec
    ,   p_old_MODIFIERS_rec           => l_MODIFIERS_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.arithmetic_operator,
                            l_MODIFIERS_rec.arithmetic_operator)
    THEN
        x_arithmetic_operator := l_x_MODIFIERS_rec.arithmetic_operator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute1,
                            l_MODIFIERS_rec.attribute1)
    THEN
        x_attribute1 := l_x_MODIFIERS_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute10,
                            l_MODIFIERS_rec.attribute10)
    THEN
        x_attribute10 := l_x_MODIFIERS_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute11,
                            l_MODIFIERS_rec.attribute11)
    THEN
        x_attribute11 := l_x_MODIFIERS_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute12,
                            l_MODIFIERS_rec.attribute12)
    THEN
        x_attribute12 := l_x_MODIFIERS_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute13,
                            l_MODIFIERS_rec.attribute13)
    THEN
        x_attribute13 := l_x_MODIFIERS_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute14,
                            l_MODIFIERS_rec.attribute14)
    THEN
        x_attribute14 := l_x_MODIFIERS_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute15,
                            l_MODIFIERS_rec.attribute15)
    THEN
        x_attribute15 := l_x_MODIFIERS_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute2,
                            l_MODIFIERS_rec.attribute2)
    THEN
        x_attribute2 := l_x_MODIFIERS_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute3,
                            l_MODIFIERS_rec.attribute3)
    THEN
        x_attribute3 := l_x_MODIFIERS_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute4,
                            l_MODIFIERS_rec.attribute4)
    THEN
        x_attribute4 := l_x_MODIFIERS_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute5,
                            l_MODIFIERS_rec.attribute5)
    THEN
        x_attribute5 := l_x_MODIFIERS_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute6,
                            l_MODIFIERS_rec.attribute6)
    THEN
        x_attribute6 := l_x_MODIFIERS_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute7,
                            l_MODIFIERS_rec.attribute7)
    THEN
        x_attribute7 := l_x_MODIFIERS_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute8,
                            l_MODIFIERS_rec.attribute8)
    THEN
        x_attribute8 := l_x_MODIFIERS_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.attribute9,
                            l_MODIFIERS_rec.attribute9)
    THEN
        x_attribute9 := l_x_MODIFIERS_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.automatic_flag,
                            l_MODIFIERS_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_MODIFIERS_rec.automatic_flag;
        x_automatic := l_MODIFIERS_val_rec.automatic;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.base_qty,
                            l_MODIFIERS_rec.base_qty)
    THEN
        x_base_qty := l_x_MODIFIERS_rec.base_qty;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.pricing_phase_id,
                            l_MODIFIERS_rec.pricing_phase_id)
    THEN
        x_pricing_phase_id := l_x_MODIFIERS_rec.pricing_phase_id;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.base_uom_code,
                            l_MODIFIERS_rec.base_uom_code)
    THEN
        x_base_uom_code := l_x_MODIFIERS_rec.base_uom_code;
        x_base_uom := l_MODIFIERS_val_rec.base_uom;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.comments,
                            l_MODIFIERS_rec.comments)
    THEN
        x_comments := l_x_MODIFIERS_rec.comments;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.context,
                            l_MODIFIERS_rec.context)
    THEN
        x_context := l_x_MODIFIERS_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.effective_period_uom,
                            l_MODIFIERS_rec.effective_period_uom)
    THEN
        x_effective_period_uom := l_x_MODIFIERS_rec.effective_period_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.end_date_active,
                            l_MODIFIERS_rec.end_date_active)
    THEN
        x_end_date_active := l_x_MODIFIERS_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.estim_accrual_rate,
                            l_MODIFIERS_rec.estim_accrual_rate)
    THEN
        x_estim_accrual_rate := l_x_MODIFIERS_rec.estim_accrual_rate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.generate_using_formula_id,
                            l_MODIFIERS_rec.generate_using_formula_id)
    THEN
        x_generate_using_formula_id := l_x_MODIFIERS_rec.generate_using_formula_id;
        x_generate_using_formula := l_MODIFIERS_val_rec.generate_using_formula;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.gl_class_id,
                            l_MODIFIERS_rec.gl_class_id)
    THEN
        x_gl_class_id := l_x_MODIFIERS_rec.gl_class_id;
        x_gl_class := l_MODIFIERS_val_rec.gl_class;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.inventory_item_id,
                            l_MODIFIERS_rec.inventory_item_id)
    THEN
        x_inventory_item_id := l_x_MODIFIERS_rec.inventory_item_id;
        x_inventory_item := l_MODIFIERS_val_rec.inventory_item;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_header_id,
                            l_MODIFIERS_rec.list_header_id)
    THEN
        x_list_header_id := l_x_MODIFIERS_rec.list_header_id;
        x_list_header := l_MODIFIERS_val_rec.list_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_line_id,
                            l_MODIFIERS_rec.list_line_id)
    THEN
        x_list_line_id := l_x_MODIFIERS_rec.list_line_id;
        x_list_line := l_MODIFIERS_val_rec.list_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_line_type_code,
                            l_MODIFIERS_rec.list_line_type_code)
    THEN
        x_list_line_type_code := l_x_MODIFIERS_rec.list_line_type_code;
        x_list_line_type := l_MODIFIERS_val_rec.list_line_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_price,
                            l_MODIFIERS_rec.list_price)
    THEN
        x_list_price := l_x_MODIFIERS_rec.list_price;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_price_uom_code,
                            l_MODIFIERS_rec.list_price_uom_code)
    THEN
        x_list_price_uom_code := l_x_MODIFIERS_rec.list_price_uom_code;
        x_list_price_uom := l_MODIFIERS_val_rec.list_price_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.modifier_level_code,
                            l_MODIFIERS_rec.modifier_level_code)
    THEN
        x_modifier_level_code := l_x_MODIFIERS_rec.modifier_level_code;
        x_modifier_level := l_MODIFIERS_val_rec.modifier_level;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.new_price,
                            l_MODIFIERS_rec.new_price)
    THEN
        x_new_price := l_x_MODIFIERS_rec.new_price;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.number_effective_periods,
                            l_MODIFIERS_rec.number_effective_periods)
    THEN
        x_number_effective_periods := l_x_MODIFIERS_rec.number_effective_periods;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.operand,
                            l_MODIFIERS_rec.operand)
    THEN
        x_operand := l_x_MODIFIERS_rec.operand;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.organization_id,
                            l_MODIFIERS_rec.organization_id)
    THEN
        x_organization_id := l_x_MODIFIERS_rec.organization_id;
        x_organization := l_MODIFIERS_val_rec.organization;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.override_flag,
                            l_MODIFIERS_rec.override_flag)
    THEN
        x_override_flag := l_x_MODIFIERS_rec.override_flag;
        x_override := l_MODIFIERS_val_rec.override;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.percent_price,
                            l_MODIFIERS_rec.percent_price)
    THEN
        x_percent_price := l_x_MODIFIERS_rec.percent_price;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.price_break_type_code,
                            l_MODIFIERS_rec.price_break_type_code)
    THEN
        x_price_break_type_code := l_x_MODIFIERS_rec.price_break_type_code;
        x_price_break_type := l_MODIFIERS_val_rec.price_break_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.price_by_formula_id,
                            l_MODIFIERS_rec.price_by_formula_id)
    THEN
        x_price_by_formula_id := l_x_MODIFIERS_rec.price_by_formula_id;
        x_price_by_formula := l_MODIFIERS_val_rec.price_by_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.primary_uom_flag,
                            l_MODIFIERS_rec.primary_uom_flag)
    THEN
        x_primary_uom_flag := l_x_MODIFIERS_rec.primary_uom_flag;
        x_primary_uom := l_MODIFIERS_val_rec.primary_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.print_on_invoice_flag,
                            l_MODIFIERS_rec.print_on_invoice_flag)
    THEN
        x_print_on_invoice_flag := l_x_MODIFIERS_rec.print_on_invoice_flag;
        x_print_on_invoice := l_MODIFIERS_val_rec.print_on_invoice;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.rebate_subtype_code,
                            l_MODIFIERS_rec.rebate_subtype_code)
    THEN
        x_rebate_subtype_code := l_x_MODIFIERS_rec.rebate_subtype_code;
        x_rebate_subtype := l_MODIFIERS_val_rec.rebate_subtype;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.rebate_trxn_type_code,
                            l_MODIFIERS_rec.rebate_trxn_type_code)
    THEN
        x_rebate_trxn_type_code := l_x_MODIFIERS_rec.rebate_trxn_type_code;
        x_rebate_transaction_type := l_MODIFIERS_val_rec.rebate_transaction_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.related_item_id,
                            l_MODIFIERS_rec.related_item_id)
    THEN
        x_related_item_id := l_x_MODIFIERS_rec.related_item_id;
        x_related_item := l_MODIFIERS_val_rec.related_item;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.relationship_type_id,
                            l_MODIFIERS_rec.relationship_type_id)
    THEN
        x_relationship_type_id := l_x_MODIFIERS_rec.relationship_type_id;
        x_relationship_type := l_MODIFIERS_val_rec.relationship_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.reprice_flag,
                            l_MODIFIERS_rec.reprice_flag)
    THEN
        x_reprice_flag := l_x_MODIFIERS_rec.reprice_flag;
        x_reprice := l_MODIFIERS_val_rec.reprice;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.revision,
                            l_MODIFIERS_rec.revision)
    THEN
        x_revision := l_x_MODIFIERS_rec.revision;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.revision_date,
                            l_MODIFIERS_rec.revision_date)
    THEN
        x_revision_date := l_x_MODIFIERS_rec.revision_date;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.revision_reason_code,
                            l_MODIFIERS_rec.revision_reason_code)
    THEN
        x_revision_reason_code := l_x_MODIFIERS_rec.revision_reason_code;
        x_revision_reason := l_MODIFIERS_val_rec.revision_reason;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.start_date_active,
                            l_MODIFIERS_rec.start_date_active)
    THEN
        x_start_date_active := l_x_MODIFIERS_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.substitution_attribute,
                            l_MODIFIERS_rec.substitution_attribute)
    THEN
        x_substitution_attribute := l_x_MODIFIERS_rec.substitution_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.substitution_context,
                            l_MODIFIERS_rec.substitution_context)
    THEN
        x_substitution_context := l_x_MODIFIERS_rec.substitution_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.substitution_value,
                            l_MODIFIERS_rec.substitution_value)
    THEN
        x_substitution_value := l_x_MODIFIERS_rec.substitution_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.accrual_flag,
                            l_MODIFIERS_rec.accrual_flag)
    THEN
        x_accrual_flag := l_x_MODIFIERS_rec.accrual_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.pricing_group_sequence,
                            l_MODIFIERS_rec.pricing_group_sequence)
    THEN
        x_pricing_group_sequence := l_x_MODIFIERS_rec.pricing_group_sequence;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.incompatibility_grp_code,
                            l_MODIFIERS_rec.incompatibility_grp_code)
    THEN
        x_incompatibility_grp_code := l_x_MODIFIERS_rec.incompatibility_grp_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.pricing_phase_id,
                            l_MODIFIERS_rec.pricing_phase_id)
    THEN
        x_pricing_phase_id := l_x_MODIFIERS_rec.pricing_phase_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.list_line_no,
                            l_MODIFIERS_rec.list_line_no)
    THEN
        x_list_line_no := l_x_MODIFIERS_rec.list_line_no;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.product_precedence,
                            l_MODIFIERS_rec.product_precedence)
    THEN
        x_product_precedence := l_x_MODIFIERS_rec.product_precedence;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.expiration_period_start_date,
                            l_MODIFIERS_rec.expiration_period_start_date)
    THEN
        x_expiration_period_start_date := l_x_MODIFIERS_rec.expiration_period_start_date;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.number_expiration_periods,
                            l_MODIFIERS_rec.number_expiration_periods)
    THEN
        x_number_expiration_periods := l_x_MODIFIERS_rec.number_expiration_periods;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.expiration_period_uom,
                            l_MODIFIERS_rec.expiration_period_uom)
    THEN
        x_expiration_period_uom := l_x_MODIFIERS_rec.expiration_period_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.expiration_date,
                            l_MODIFIERS_rec.expiration_date)
    THEN
        x_expiration_date := l_x_MODIFIERS_rec.expiration_date;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.estim_gl_value,
                            l_MODIFIERS_rec.estim_gl_value)
    THEN
        x_estim_gl_value := l_x_MODIFIERS_rec.estim_gl_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.benefit_price_list_line_id,
                            l_MODIFIERS_rec.benefit_price_list_line_id)
    THEN
        x_benefit_price_list_line_id := l_x_MODIFIERS_rec.benefit_price_list_line_id;
    END IF;

/*    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.recurring_flag,
                            l_MODIFIERS_rec.recurring_flag)
    THEN
        x_recurring_flag := l_x_MODIFIERS_rec.recurring_flag;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.benefit_limit,
                            l_MODIFIERS_rec.benefit_limit)
    THEN
        x_benefit_limit := l_x_MODIFIERS_rec.benefit_limit;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.charge_type_code,
                            l_MODIFIERS_rec.charge_type_code)
    THEN
        x_charge_type_code := l_x_MODIFIERS_rec.charge_type_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.charge_subtype_code,
                            l_MODIFIERS_rec.charge_subtype_code)
    THEN
        x_charge_subtype_code := l_x_MODIFIERS_rec.charge_subtype_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.benefit_qty,
                            l_MODIFIERS_rec.benefit_qty)
    THEN
        x_benefit_qty := l_x_MODIFIERS_rec.benefit_qty;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.benefit_uom_code,
                            l_MODIFIERS_rec.benefit_uom_code)
    THEN
        x_benefit_uom_code := l_x_MODIFIERS_rec.benefit_uom_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.accrual_conversion_rate,
                            l_MODIFIERS_rec.accrual_conversion_rate)
    THEN
        x_accrual_conversion_rate := l_x_MODIFIERS_rec.accrual_conversion_rate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.proration_type_code,
                            l_MODIFIERS_rec.proration_type_code)
    THEN
        x_proration_type_code := l_x_MODIFIERS_rec.proration_type_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.include_on_returns_flag,
                            l_MODIFIERS_rec.include_on_returns_flag)
    THEN
        x_include_on_returns_flag := l_x_MODIFIERS_rec.include_on_returns_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.from_rltd_modifier_id,
                            l_MODIFIERS_rec.from_rltd_modifier_id)
    THEN
        x_from_rltd_modifier_id := l_x_MODIFIERS_rec.from_rltd_modifier_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.to_rltd_modifier_id,
                            l_MODIFIERS_rec.to_rltd_modifier_id)
    THEN
        x_to_rltd_modifier_id := l_x_MODIFIERS_rec.to_rltd_modifier_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.rltd_modifier_grp_no,
                            l_MODIFIERS_rec.rltd_modifier_grp_no)
    THEN
        x_rltd_modifier_grp_no := l_x_MODIFIERS_rec.rltd_modifier_grp_no;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.rltd_modifier_grp_type,
                            l_MODIFIERS_rec.rltd_modifier_grp_type)
    THEN
        x_rltd_modifier_grp_type := l_x_MODIFIERS_rec.rltd_modifier_grp_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.net_amount_flag,
                            l_MODIFIERS_rec.net_amount_flag)
    THEN
        x_net_amount_flag := l_x_MODIFIERS_rec.net_amount_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.accum_attribute,
                            l_MODIFIERS_rec.accum_attribute)
    THEN
        x_accum_attribute := l_x_MODIFIERS_rec.accum_attribute;
    END IF;

    --Continuous Price Breaks
    IF NOT QP_GLOBALS.Equal(l_x_MODIFIERS_rec.continuous_price_break_flag,
                            l_MODIFIERS_rec.continuous_price_break_flag)
    THEN
        x_continuous_price_break_flag := l_x_MODIFIERS_rec.continuous_price_break_flag;
    END IF;


    --  Write to cache.

    Write_MODIFIERS
    (   p_MODIFIERS_rec               => l_x_MODIFIERS_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Change_attribute in QPXFMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_old_MODIFIERS_rec           QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_old_MODIFIERS_tbl           QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Validate_And_Write in QPXFMLLB');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read MODIFIERS from cache

    l_old_MODIFIERS_rec := Get_MODIFIERS
    (   p_db_record                   => TRUE
    ,   p_list_line_id                => p_list_line_id
    );

    l_MODIFIERS_rec := Get_MODIFIERS
    (   p_db_record                   => FALSE
    ,   p_list_line_id                => p_list_line_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_MODIFIERS_rec.db_flag) THEN
        l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate MODIFIERS table

    l_MODIFIERS_tbl(1) := l_MODIFIERS_rec;
    l_old_MODIFIERS_tbl(1) := l_old_MODIFIERS_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   p_old_MODIFIERS_tbl           => l_old_MODIFIERS_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_MODIFIERS_rec := l_x_MODIFIERS_tbl(1);

    x_creation_date                := l_x_MODIFIERS_rec.creation_date;
    x_created_by                   := l_x_MODIFIERS_rec.created_by;
    x_last_update_date             := l_x_MODIFIERS_rec.last_update_date;
    x_last_updated_by              := l_x_MODIFIERS_rec.last_updated_by;
    x_last_update_login            := l_x_MODIFIERS_rec.last_update_login;

    --  Clear MODIFIERS record cache

    Clear_MODIFIERS;

    --  Keep track of performed operations.

    l_old_MODIFIERS_rec.operation := l_MODIFIERS_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Validate_And_Write in QPXFMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
)
IS
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Delete_Row in QPXFMLLB');

    --  Set control flags.


    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_MODIFIERS_rec := Get_MODIFIERS
    (   p_db_record                   => TRUE
    ,   p_list_line_id                => p_list_line_id
    );

    --  Set Operation.

    l_MODIFIERS_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate MODIFIERS table

    l_MODIFIERS_tbl(1) := l_MODIFIERS_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear MODIFIERS record cache

    Clear_MODIFIERS;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Delete_Row in QPXFMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Process_Entity in QPXFMLLB');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_MODIFIERS;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Process_Entity in QPXFMLLB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_arithmetic_operator           IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_automatic_flag                IN  VARCHAR2
--,   p_base_qty                      IN  NUMBER
,   p_pricing_phase_id              IN  NUMBER
--,   p_base_uom_code                 IN  VARCHAR2
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_effective_period_uom          IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_estim_accrual_rate            IN  NUMBER
,   p_generate_using_formula_id     IN  NUMBER
--,   p_gl_class_id                   IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_list_line_type_code           IN  VARCHAR2
,   p_list_price                    IN  NUMBER
--,   p_list_price_uom_code           IN  VARCHAR2
,   p_modifier_level_code           IN  VARCHAR2
--,   p_new_price                     IN  NUMBER
,   p_number_effective_periods      IN  NUMBER
,   p_operand                       IN  NUMBER
,   p_organization_id               IN  NUMBER
,   p_override_flag                 IN  VARCHAR2
,   p_percent_price                 IN  NUMBER
,   p_price_break_type_code         IN  VARCHAR2
,   p_price_by_formula_id           IN  NUMBER
,   p_primary_uom_flag              IN  VARCHAR2
,   p_print_on_invoice_flag         IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
--,   p_rebate_subtype_code           IN  VARCHAR2
,   p_rebate_trxn_type_code         IN  VARCHAR2
,   p_related_item_id               IN  NUMBER
,   p_relationship_type_id          IN  NUMBER
,   p_reprice_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_substitution_attribute        IN  VARCHAR2
,   p_substitution_context          IN  VARCHAR2
,   p_substitution_value            IN  VARCHAR2
,   p_accrual_flag                  IN  VARCHAR2
,   p_pricing_group_sequence        IN  NUMBER
,   p_incompatibility_grp_code      IN  VARCHAR2
,   p_list_line_no                  IN  VARCHAR2
,   p_product_precedence            IN  NUMBER
,   p_expiration_period_start_date  IN  DATE
,   p_number_expiration_periods     IN  NUMBER
,   p_expiration_period_uom         IN  VARCHAR2
,   p_expiration_date               IN  DATE
,   p_estim_gl_value                IN  NUMBER
,   p_benefit_price_list_line_id    IN  NUMBER
--,   p_recurring_flag                IN  VARCHAR2
,   p_benefit_limit                 IN  NUMBER
,   p_charge_type_code              IN  VARCHAR2
,   p_charge_subtype_code           IN  VARCHAR2
,   p_benefit_qty                   IN  NUMBER
,   p_benefit_uom_code              IN  VARCHAR2
,   p_accrual_conversion_rate       IN  NUMBER
,   p_proration_type_code           IN  VARCHAR2
,   p_include_on_returns_flag       IN  VARCHAR2
,   p_from_rltd_modifier_id         IN  NUMBER
,   p_to_rltd_modifier_id           IN  NUMBER
,   p_rltd_modifier_grp_no          IN  NUMBER
,   p_rltd_modifier_grp_type        IN  VARCHAR2
,   p_net_amount_flag               IN  VARCHAR2
,   p_accum_attribute               IN  VARCHAR2
,   p_continuous_price_break_flag       IN  VARCHAR2  --Continuous Price Breaks
)
IS
l_return_status               VARCHAR2(1);
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN Lock_Row in QPXFMLLB');

    --  Load MODIFIERS record

    l_MODIFIERS_rec.arithmetic_operator := p_arithmetic_operator;
    l_MODIFIERS_rec.attribute1     := p_attribute1;
    l_MODIFIERS_rec.attribute10    := p_attribute10;
    l_MODIFIERS_rec.attribute11    := p_attribute11;
    l_MODIFIERS_rec.attribute12    := p_attribute12;
    l_MODIFIERS_rec.attribute13    := p_attribute13;
    l_MODIFIERS_rec.attribute14    := p_attribute14;
    l_MODIFIERS_rec.attribute15    := p_attribute15;
    l_MODIFIERS_rec.attribute2     := p_attribute2;
    l_MODIFIERS_rec.attribute3     := p_attribute3;
    l_MODIFIERS_rec.attribute4     := p_attribute4;
    l_MODIFIERS_rec.attribute5     := p_attribute5;
    l_MODIFIERS_rec.attribute6     := p_attribute6;
    l_MODIFIERS_rec.attribute7     := p_attribute7;
    l_MODIFIERS_rec.attribute8     := p_attribute8;
    l_MODIFIERS_rec.attribute9     := p_attribute9;
    l_MODIFIERS_rec.automatic_flag := p_automatic_flag;
--    l_MODIFIERS_rec.base_qty       := p_base_qty;
    l_MODIFIERS_rec.pricing_phase_id  := p_pricing_phase_id;
--    l_MODIFIERS_rec.base_uom_code  := p_base_uom_code;
    l_MODIFIERS_rec.comments       := p_comments;
    l_MODIFIERS_rec.context        := p_context;
    l_MODIFIERS_rec.created_by     := p_created_by;
    l_MODIFIERS_rec.creation_date  := p_creation_date;
    l_MODIFIERS_rec.effective_period_uom := p_effective_period_uom;
    l_MODIFIERS_rec.end_date_active := p_end_date_active;
    l_MODIFIERS_rec.estim_accrual_rate := p_estim_accrual_rate;
    l_MODIFIERS_rec.generate_using_formula_id := p_generate_using_formula_id;
--    l_MODIFIERS_rec.gl_class_id    := p_gl_class_id;
    l_MODIFIERS_rec.inventory_item_id := p_inventory_item_id;
    l_MODIFIERS_rec.last_updated_by := p_last_updated_by;
    l_MODIFIERS_rec.last_update_date := p_last_update_date;
    l_MODIFIERS_rec.last_update_login := p_last_update_login;
    l_MODIFIERS_rec.list_header_id := p_list_header_id;
    l_MODIFIERS_rec.list_line_id   := p_list_line_id;
    l_MODIFIERS_rec.list_line_type_code := p_list_line_type_code;
    l_MODIFIERS_rec.list_price     := p_list_price;
--    l_MODIFIERS_rec.list_price_uom_code := p_list_price_uom_code;
    l_MODIFIERS_rec.modifier_level_code := p_modifier_level_code;
--    l_MODIFIERS_rec.new_price      := p_new_price;
    l_MODIFIERS_rec.number_effective_periods := p_number_effective_periods;
    l_MODIFIERS_rec.operand        := p_operand;
    l_MODIFIERS_rec.organization_id := p_organization_id;
    l_MODIFIERS_rec.override_flag  := p_override_flag;
    l_MODIFIERS_rec.percent_price  := p_percent_price;
    l_MODIFIERS_rec.price_break_type_code := p_price_break_type_code;
    l_MODIFIERS_rec.price_by_formula_id := p_price_by_formula_id;
    l_MODIFIERS_rec.primary_uom_flag := p_primary_uom_flag;
    l_MODIFIERS_rec.print_on_invoice_flag := p_print_on_invoice_flag;
    l_MODIFIERS_rec.program_application_id := p_program_application_id;
    l_MODIFIERS_rec.program_id     := p_program_id;
    l_MODIFIERS_rec.program_update_date := p_program_update_date;
--    l_MODIFIERS_rec.rebate_subtype_code := p_rebate_subtype_code;
    l_MODIFIERS_rec.rebate_trxn_type_code := p_rebate_trxn_type_code;
    l_MODIFIERS_rec.related_item_id := p_related_item_id;
    l_MODIFIERS_rec.relationship_type_id := p_relationship_type_id;
    l_MODIFIERS_rec.reprice_flag   := p_reprice_flag;
    l_MODIFIERS_rec.request_id     := p_request_id;
    l_MODIFIERS_rec.revision       := p_revision;
    l_MODIFIERS_rec.revision_date  := p_revision_date;
    l_MODIFIERS_rec.revision_reason_code := p_revision_reason_code;
    l_MODIFIERS_rec.start_date_active := p_start_date_active;
    l_MODIFIERS_rec.substitution_attribute := p_substitution_attribute;
    l_MODIFIERS_rec.substitution_context := p_substitution_context;
    l_MODIFIERS_rec.substitution_value := p_substitution_value;
    l_MODIFIERS_rec.accrual_flag := p_accrual_flag;
    l_MODIFIERS_rec.pricing_group_sequence := p_pricing_group_sequence;
    l_MODIFIERS_rec.incompatibility_grp_code := p_incompatibility_grp_code;
    l_MODIFIERS_rec.list_line_no := p_list_line_no;
    l_MODIFIERS_rec.product_precedence := p_product_precedence;
    l_MODIFIERS_rec.expiration_period_start_date := p_expiration_period_start_date;
    l_MODIFIERS_rec.number_expiration_periods := p_number_expiration_periods;
    l_MODIFIERS_rec.expiration_period_uom := p_expiration_period_uom;
    l_MODIFIERS_rec.expiration_date := p_expiration_date;
    l_MODIFIERS_rec.estim_gl_value := p_estim_gl_value;
    l_MODIFIERS_rec.benefit_price_list_line_id := p_benefit_price_list_line_id;
--    l_MODIFIERS_rec.recurring_flag := p_recurring_flag;
    l_MODIFIERS_rec.benefit_limit := p_benefit_limit;
    l_MODIFIERS_rec.charge_type_code := p_charge_type_code;
    l_MODIFIERS_rec.charge_subtype_code := p_charge_subtype_code;
    l_MODIFIERS_rec.benefit_qty := p_benefit_qty;
    l_MODIFIERS_rec.benefit_uom_code := p_benefit_uom_code;
    l_MODIFIERS_rec.accrual_conversion_rate := p_accrual_conversion_rate;
    l_MODIFIERS_rec.proration_type_code := p_proration_type_code;
    l_MODIFIERS_rec.include_on_returns_flag := p_include_on_returns_flag;
--    l_MODIFIERS_rec.from_rltd_modifier_id := p_from_rltd_modifier_id;
--    l_MODIFIERS_rec.to_rltd_modifier_id := p_to_rltd_modifier_id;
--    l_MODIFIERS_rec.rltd_modifier_grp_no := p_rltd_modifier_grp_no;
--    l_MODIFIERS_rec.rltd_modifier_grp_type := p_rltd_modifier_grp_type;
    l_MODIFIERS_rec.operation   := QP_GLOBALS.G_OPR_LOCK;
    l_MODIFIERS_rec.net_amount_flag := p_net_amount_flag;
    l_MODIFIERS_rec.accum_attribute := p_accum_attribute;
    l_MODIFIERS_rec.continuous_price_break_flag := p_continuous_price_break_flag;
    						--Continuous Price Breaks


    --  Populate MODIFIERS table

    l_MODIFIERS_tbl(1) := l_MODIFIERS_rec;

    --  Call QP_Modifiers_PVT.Lock_MODIFIERS

    QP_Modifiers_PVT.Lock_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_MODIFIERS_rec.db_flag := FND_API.G_TRUE;

        Write_MODIFIERS
        (   p_MODIFIERS_rec               => l_x_MODIFIERS_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('END Lock_Row in QPXFMLLB');

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Lock_Row;

--  Procedures maintaining MODIFIERS record cache.

PROCEDURE Write_MODIFIERS
(   p_MODIFIERS_rec                 IN  QP_Modifiers_PUB.Modifiers_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    oe_debug_pub.add('BEGIN Write_Modifiers in QPXFMLLB');

    g_MODIFIERS_rec := p_MODIFIERS_rec;

    IF p_db_record THEN

        g_db_MODIFIERS_rec := p_MODIFIERS_rec;

    END IF;

    oe_debug_pub.add('END Write_Modifiers in QPXFMLLB');

END Write_Modifiers;

FUNCTION Get_MODIFIERS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_line_id                  IN  NUMBER
)
RETURN QP_Modifiers_PUB.Modifiers_Rec_Type
IS
BEGIN

    oe_debug_pub.add('BEGIN Get_Modifiers in QPXFMLLB');

    IF  p_list_line_id <> g_MODIFIERS_rec.list_line_id
    THEN

        --  Query row from DB

        g_MODIFIERS_rec := QP_Modifiers_Util.Query_Row
        (   p_list_line_id                => p_list_line_id
        );

        g_MODIFIERS_rec.db_flag        := FND_API.G_TRUE;

        --  Load DB record

        g_db_MODIFIERS_rec             := g_MODIFIERS_rec;

    END IF;

    IF p_db_record THEN

    oe_debug_pub.add('END Get_Modifiers in QPXFMLLB');
        RETURN g_db_MODIFIERS_rec;

    ELSE

    oe_debug_pub.add('else END Get_Modifiers in QPXFMLLB');
        RETURN g_MODIFIERS_rec;

    END IF;



END Get_Modifiers;

PROCEDURE Clear_Modifiers
IS
BEGIN

    oe_debug_pub.add('BEGIN Clear_Modifiers in QPXFMLLB');

    g_MODIFIERS_rec                := QP_Modifiers_PUB.G_MISS_MODIFIERS_REC;
    g_db_MODIFIERS_rec             := QP_Modifiers_PUB.G_MISS_MODIFIERS_REC;

    oe_debug_pub.add('END Clear_Modifiers in QPXFMLLB');
END Clear_Modifiers;


--added by svdeshmu
-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
     QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_MODIFIERS
					,p_entity_id    => p_list_line_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Modifiers;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Clear_Record'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Clear_Record;


--added by svdeshmu

-- Following procedure is added for the ER 2423045

Procedure Dup_record
(  p_old_list_line_id                     IN NUMBER,
   p_new_list_line_id                     IN NUMBER,
   p_list_header_id                       IN NUMBER,
   p_list_line_type_code                  IN VARCHAR2,
   x_msg_count                            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data                             OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
   x_return_status                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_new_pricing_attribute_id    Number;
l_new_list_line_id            Number;
l_new_qualifier_id            Number;
l_number_of_lines             Number := 1;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_MODIFIERS_rec               QP_Modifiers_PUB.Modifiers_Rec_Type;
l_MODIFIERS_tbl               QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_QUALIFIERS_rec              Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_continuous_price_break_flag varchar2(1);

CURSOR l_LIST_LINE_csr(p_list_line_id Number) IS
 SELECT
           L.ACCRUAL_CONVERSION_RATE
 ,         L.ACCRUAL_FLAG
 ,         L.ACCRUAL_QTY
 ,         L.ACCRUAL_UOM_CODE
 ,         L.ARITHMETIC_OPERATOR
 ,         L.ATTRIBUTE1
 ,         L.ATTRIBUTE2
 ,         L.ATTRIBUTE3
 ,         L.ATTRIBUTE4
 ,         L.ATTRIBUTE5
 ,         L.ATTRIBUTE6
 ,         L.ATTRIBUTE7
 ,         L.ATTRIBUTE8
 ,         L.ATTRIBUTE9
 ,         L.ATTRIBUTE10
 ,         L.ATTRIBUTE11
 ,         L.ATTRIBUTE12
 ,         L.ATTRIBUTE13
 ,         L.ATTRIBUTE14
 ,         L.ATTRIBUTE15
 ,         L.AUTOMATIC_FLAG
 ,         L.BASE_QTY
 ,         L.BASE_UOM_CODE
 ,         L.BENEFIT_LIMIT
 ,         L.BENEFIT_PRICE_LIST_LINE_ID
 ,         L.BENEFIT_QTY
 ,         L.BENEFIT_UOM_CODE
 ,         L.CHARGE_SUBTYPE_CODE
 ,         L.CHARGE_TYPE_CODE
 ,         L.COMMENTS
 ,         L.CONTEXT
 ,         L.CREATED_BY
 ,         L.CREATION_DATE
 ,         L.EFFECTIVE_PERIOD_UOM
 ,         L.END_DATE_ACTIVE
 ,         L.ESTIM_ACCRUAL_RATE
 ,         L.ESTIM_GL_VALUE
 ,         L.EXPIRATION_DATE
 ,         L.EXPIRATION_PERIOD_START_DATE
 ,         L.EXPIRATION_PERIOD_UOM
 ,         L.GENERATE_USING_FORMULA_ID
 ,         L.GROUP_COUNT
 ,         L.INCLUDE_ON_RETURNS_FLAG
 ,         L.INCOMPATIBILITY_GRP_CODE
 ,         L.INVENTORY_ITEM_ID
 ,         L.LAST_UPDATE_DATE
 ,         L.LAST_UPDATE_LOGIN
 ,         L.LAST_UPDATED_BY
 ,         L.LIMIT_EXISTS_FLAG
 ,         L.LIST_HEADER_ID
 ,         L.LIST_LINE_ID
 ,         L.LIST_LINE_NO
 ,         L.LIST_LINE_TYPE_CODE
 ,         L.LIST_PRICE
 ,         L.LIST_PRICE_UOM_CODE
 ,         L.MODIFIER_LEVEL_CODE
 ,         L.NUMBER_EFFECTIVE_PERIODS
 ,         L.NUMBER_EXPIRATION_PERIODS
 ,         L.OPERAND
 ,         L.ORGANIZATION_ID
 ,         L.OVERRIDE_FLAG
 ,         L.PERCENT_PRICE
 ,         L.PRICE_BREAK_TYPE_CODE
 ,         L.PRICE_BY_FORMULA_ID
 ,         L.PRICING_GROUP_SEQUENCE
 ,         L.PRICING_PHASE_ID
 ,         L.PRIMARY_UOM_FLAG
 ,         L.PRINT_ON_INVOICE_FLAG
 ,         L.PRODUCT_PRECEDENCE
 ,         L.PROGRAM_APPLICATION_ID
 ,         L.PROGRAM_ID
 ,         L.PROGRAM_UPDATE_DATE
 ,         L.PRORATION_TYPE_CODE
 ,         L.QUALIFICATION_IND
 ,         L.REBATE_TRANSACTION_TYPE_CODE
 ,         L.RECURRING_FLAG
 ,         L.RELATED_ITEM_ID
 ,         L.RELATIONSHIP_TYPE_ID
 ,         L.REPRICE_FLAG
 ,         L.REQUEST_ID
 ,         L.REVISION
 ,         L.REVISION_DATE
 ,         L.REVISION_REASON_CODE
 ,         L.START_DATE_ACTIVE
 ,         L.SUBSTITUTION_ATTRIBUTE
 ,         L.SUBSTITUTION_CONTEXT
 ,         L.SUBSTITUTION_VALUE
 ,         RM.RLTD_MODIFIER_GRP_NO
 ,         RM.RLTD_MODIFIER_GRP_TYPE
 ,         L.CONTINUOUS_PRICE_BREAK_FLAG
 FROM    QP_LIST_LINES L, QP_RLTD_MODIFIERS RM
 WHERE   L.LIST_LINE_ID  = RM.TO_RLTD_MODIFIER_ID
 AND     RM.FROM_RLTD_MODIFIER_ID = p_list_line_id
 AND     L.LIST_HEADER_ID = p_list_header_id;

CURSOR l_PRICING_ATTR_csr(p_list_line_id Number) IS
    SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE   LIST_LINE_ID = p_list_line_id
    AND     ((  PRICING_ATTRIBUTE_CONTEXT IS NOT NULL
            AND PRICING_ATTRIBUTE_CONTEXT <> 'VOLUME')
            OR  EXCLUDER_FLAG = 'Y')
    AND     LIST_HEADER_ID = p_list_header_id;

CURSOR l_PRICING_ATTR_RLTD_csr(p_list_line_id Number) IS
    SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE   LIST_LINE_ID = p_list_line_id
    AND     LIST_HEADER_ID = p_list_header_id;

CURSOR l_QUALIFIER_csr(p_list_line_id Number) IS
SELECT
          ACTIVE_FLAG
 ,        ATTRIBUTE1
 ,        ATTRIBUTE10
 ,        ATTRIBUTE11
 ,        ATTRIBUTE12
 ,        ATTRIBUTE13
 ,        ATTRIBUTE14
 ,        ATTRIBUTE15
 ,        ATTRIBUTE2
 ,        ATTRIBUTE3
 ,        ATTRIBUTE4
 ,        ATTRIBUTE5
 ,        ATTRIBUTE6
 ,        ATTRIBUTE7
 ,        ATTRIBUTE8
 ,        ATTRIBUTE9
 ,        COMPARISON_OPERATOR_CODE
 ,        CONTEXT
 ,        CREATED_BY
 ,        CREATED_FROM_RULE_ID
 ,        CREATION_DATE
 ,        DISTINCT_ROW_COUNT
 ,        END_DATE_ACTIVE
 ,        EXCLUDER_FLAG
 ,        HEADER_QUALS_EXIST_FLAG
 ,        LAST_UPDATE_DATE
 ,        LAST_UPDATE_LOGIN
 ,        LAST_UPDATED_BY
 ,        LIST_HEADER_ID
 ,        LIST_LINE_ID
 ,        LIST_TYPE_CODE
 ,        PROGRAM_APPLICATION_ID
 ,        PROGRAM_ID
 ,        PROGRAM_UPDATE_DATE
 ,        QUAL_ATTR_VALUE_FROM_NUMBER
 ,        QUAL_ATTR_VALUE_TO_NUMBER
 ,        QUALIFIER_ATTR_VALUE
 ,        QUALIFIER_ATTR_VALUE_TO
 ,        QUALIFIER_ATTRIBUTE
 ,        QUALIFIER_CONTEXT
 ,        QUALIFIER_DATATYPE
 ,        QUALIFIER_GROUP_CNT
 ,        QUALIFIER_GROUPING_NO
 ,        QUALIFIER_ID
 ,        QUALIFIER_PRECEDENCE
 ,        QUALIFIER_RULE_ID
 ,        REQUEST_ID
 ,        SEARCH_IND
 ,        START_DATE_ACTIVE
 FROM     QP_QUALIFIERS
 WHERE    LIST_LINE_ID = p_list_line_id
 AND      LIST_HEADER_ID = p_list_header_id;

BEGIN


    oe_debug_pub.add('Inside Duplicate Record');
    oe_debug_pub.add('List Line Type' || p_list_line_type_code,3);
    /******************************************************************************************/
    /*       	        Duplicate line Pricing Attributes 				      */
    /******************************************************************************************/
    FOR l_implicit_rec IN l_PRICING_ATTR_csr(p_old_list_line_id) LOOP

        oe_debug_pub.add('Inside pricing attribute cursor of line : '||p_new_list_line_id, 3);

        SELECT qp_pricing_attributes_s.nextval INTO l_new_pricing_attribute_id
        FROM dual;

        l_PRICING_ATTR_rec.accumulate_flag              := l_implicit_rec.ACCUMULATE_FLAG;
        l_PRICING_ATTR_rec.attribute1                   := l_implicit_rec.ATTRIBUTE1;
        l_PRICING_ATTR_rec.attribute10                  := l_implicit_rec.ATTRIBUTE10;
        l_PRICING_ATTR_rec.attribute11                  := l_implicit_rec.ATTRIBUTE11;
        l_PRICING_ATTR_rec.attribute12                  := l_implicit_rec.ATTRIBUTE12;
        l_PRICING_ATTR_rec.attribute13                  := l_implicit_rec.ATTRIBUTE13;
        l_PRICING_ATTR_rec.attribute14                  := l_implicit_rec.ATTRIBUTE14;
        l_PRICING_ATTR_rec.attribute15                  := l_implicit_rec.ATTRIBUTE15;
        l_PRICING_ATTR_rec.attribute2                   := l_implicit_rec.ATTRIBUTE2;
        l_PRICING_ATTR_rec.attribute3                   := l_implicit_rec.ATTRIBUTE3;
        l_PRICING_ATTR_rec.attribute4                   := l_implicit_rec.ATTRIBUTE4;
        l_PRICING_ATTR_rec.attribute5                   := l_implicit_rec.ATTRIBUTE5;
        l_PRICING_ATTR_rec.attribute6                   := l_implicit_rec.ATTRIBUTE6;
        l_PRICING_ATTR_rec.attribute7                   := l_implicit_rec.ATTRIBUTE7;
        l_PRICING_ATTR_rec.attribute8                   := l_implicit_rec.ATTRIBUTE8;
        l_PRICING_ATTR_rec.attribute9                   := l_implicit_rec.ATTRIBUTE9;
        l_PRICING_ATTR_rec.attribute_grouping_no        := l_implicit_rec.ATTRIBUTE_GROUPING_NO;
        l_PRICING_ATTR_rec.context                      := l_implicit_rec.CONTEXT;
        l_PRICING_ATTR_rec.created_by                   := l_implicit_rec.CREATED_BY;
        l_PRICING_ATTR_rec.creation_date                := l_implicit_rec.CREATION_DATE;
        l_PRICING_ATTR_rec.excluder_flag                := l_implicit_rec.EXCLUDER_FLAG;
        l_PRICING_ATTR_rec.last_updated_by              := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICING_ATTR_rec.last_update_date             := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICING_ATTR_rec.last_update_login            := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICING_ATTR_rec.list_line_id                 := p_new_list_line_id;
        l_PRICING_ATTR_rec.list_header_id               := l_implicit_rec.LIST_HEADER_ID;
        l_PRICING_ATTR_rec.pricing_phase_id             := l_implicit_rec.PRICING_PHASE_ID;
        l_PRICING_ATTR_rec.pricing_attribute            := l_implicit_rec.PRICING_ATTRIBUTE;
        l_PRICING_ATTR_rec.pricing_attribute_context    := l_implicit_rec.PRICING_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.pricing_attribute_id         := l_new_pricing_attribute_id;
        l_PRICING_ATTR_rec.pricing_attr_value_from      := l_implicit_rec.PRICING_ATTR_VALUE_FROM;
        l_PRICING_ATTR_rec.pricing_attr_value_to        := l_implicit_rec.PRICING_ATTR_VALUE_TO;
        l_PRICING_ATTR_rec.product_attribute            := l_implicit_rec.PRODUCT_ATTRIBUTE;
        l_PRICING_ATTR_rec.product_attribute_context    := l_implicit_rec.PRODUCT_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.product_attr_value           := l_implicit_rec.PRODUCT_ATTR_VALUE;
        l_PRICING_ATTR_rec.product_uom_code             := l_implicit_rec.PRODUCT_UOM_CODE;
        l_PRICING_ATTR_rec.program_application_id       := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICING_ATTR_rec.program_id                   := l_implicit_rec.PROGRAM_ID;
        l_PRICING_ATTR_rec.program_update_date          := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICING_ATTR_rec.request_id                   := l_implicit_rec.REQUEST_ID;
        l_PRICING_ATTR_rec.comparison_operator_code     := l_implicit_rec.comparison_operator_code;
        l_PRICING_ATTR_rec.pricing_attribute_datatype   := l_implicit_rec.pricing_attribute_datatype;
        l_PRICING_ATTR_rec.product_attribute_datatype   := l_implicit_rec.product_attribute_datatype;
        l_PRICING_ATTR_rec.pricing_attr_value_from_number := l_implicit_rec.PRICING_ATTR_VALUE_FROM_NUMBER;
        l_PRICING_ATTR_rec.pricing_attr_value_to_number := l_implicit_rec.PRICING_ATTR_VALUE_TO_NUMBER;
        l_PRICING_ATTR_rec.qualification_ind            := l_implicit_rec.QUALIFICATION_IND;
        l_PRICING_ATTR_rec.MODIFIERS_INDEX              := 1;

        l_PRICING_ATTR_rec.operation 			:= QP_GLOBALS.G_OPR_CREATE;

        l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

    END LOOP;

    /******************************************************************************************/
    /*          			Related Lines Duplication			      */
    /******************************************************************************************/
    If p_list_line_type_code IN ('PBH', 'PRG','OID') Then

--Storing continuous_price_break_flag value for later use,to convert non continuous price break lines into continuous line.

        SELECT continuous_price_break_flag INTO l_continuous_price_break_flag
        FROM QP_LIST_LINES
	WHERE list_line_id=p_old_list_line_id;

      FOR l_implicit_rec IN l_LIST_LINE_csr(p_old_list_line_id) LOOP

        oe_debug_pub.add('Inside related modifier cursor for line : '||p_new_list_line_id, 3);

        SELECT qp_List_lines_s.nextval INTO l_new_list_line_id
        FROM dual;

        oe_debug_pub.add('From Modifier : '||p_new_list_line_id, 3);
        oe_debug_pub.add('To Modifier : '||l_new_list_line_id, 3);

        l_MODIFIERS_rec.ACCRUAL_CONVERSION_RATE        := l_implicit_rec.ACCRUAL_CONVERSION_RATE;
        l_MODIFIERS_rec.ACCRUAL_FLAG                   := l_implicit_rec.ACCRUAL_FLAG;
        l_MODIFIERS_rec.ARITHMETIC_OPERATOR            := l_implicit_rec.ARITHMETIC_OPERATOR;
        l_MODIFIERS_rec.ATTRIBUTE1                     := l_implicit_rec.ATTRIBUTE1;
        l_MODIFIERS_rec.ATTRIBUTE2                     := l_implicit_rec.ATTRIBUTE2;
        l_MODIFIERS_rec.ATTRIBUTE3                     := l_implicit_rec.ATTRIBUTE3;
        l_MODIFIERS_rec.ATTRIBUTE4                     := l_implicit_rec.ATTRIBUTE4;
        l_MODIFIERS_rec.ATTRIBUTE5                     := l_implicit_rec.ATTRIBUTE5;
        l_MODIFIERS_rec.ATTRIBUTE6                     := l_implicit_rec.ATTRIBUTE6;
        l_MODIFIERS_rec.ATTRIBUTE7                     := l_implicit_rec.ATTRIBUTE7;
        l_MODIFIERS_rec.ATTRIBUTE8                     := l_implicit_rec.ATTRIBUTE8;
        l_MODIFIERS_rec.ATTRIBUTE9                     := l_implicit_rec.ATTRIBUTE9;
        l_MODIFIERS_rec.ATTRIBUTE10                    := l_implicit_rec.ATTRIBUTE10;
        l_MODIFIERS_rec.ATTRIBUTE11                    := l_implicit_rec.ATTRIBUTE11;
        l_MODIFIERS_rec.ATTRIBUTE12                    := l_implicit_rec.ATTRIBUTE12;
        l_MODIFIERS_rec.ATTRIBUTE13                    := l_implicit_rec.ATTRIBUTE13;
        l_MODIFIERS_rec.ATTRIBUTE14                    := l_implicit_rec.ATTRIBUTE14;
        l_MODIFIERS_rec.ATTRIBUTE15                    := l_implicit_rec.ATTRIBUTE15;
        l_MODIFIERS_rec.AUTOMATIC_FLAG                 := l_implicit_rec.AUTOMATIC_FLAG;
        l_MODIFIERS_rec.BENEFIT_LIMIT                  := l_implicit_rec.BENEFIT_LIMIT;
        l_MODIFIERS_rec.BENEFIT_PRICE_LIST_LINE_ID     := l_implicit_rec.BENEFIT_PRICE_LIST_LINE_ID;
        l_MODIFIERS_rec.BENEFIT_QTY                    := l_implicit_rec.BENEFIT_QTY;
        l_MODIFIERS_rec.BENEFIT_UOM_CODE               := l_implicit_rec.BENEFIT_UOM_CODE;
        l_MODIFIERS_rec.CHARGE_SUBTYPE_CODE            := l_implicit_rec.CHARGE_SUBTYPE_CODE;
        l_MODIFIERS_rec.CHARGE_TYPE_CODE               := l_implicit_rec.CHARGE_TYPE_CODE;
        l_MODIFIERS_rec.COMMENTS                       := l_implicit_rec.COMMENTS;
        l_MODIFIERS_rec.CONTEXT                        := l_implicit_rec.CONTEXT;
        l_MODIFIERS_rec.CREATED_BY                     := l_implicit_rec.CREATED_BY;
        l_MODIFIERS_rec.CREATION_DATE                  := l_implicit_rec.CREATION_DATE;
        l_MODIFIERS_rec.EFFECTIVE_PERIOD_UOM           := l_implicit_rec.EFFECTIVE_PERIOD_UOM;
        l_MODIFIERS_rec.END_DATE_ACTIVE                := l_implicit_rec.END_DATE_ACTIVE;
        l_MODIFIERS_rec.ESTIM_ACCRUAL_RATE             := l_implicit_rec.ESTIM_ACCRUAL_RATE;
        l_MODIFIERS_rec.ESTIM_GL_VALUE                 := l_implicit_rec.ESTIM_GL_VALUE;
        l_MODIFIERS_rec.EXPIRATION_DATE                := l_implicit_rec.EXPIRATION_DATE;
        l_MODIFIERS_rec.EXPIRATION_PERIOD_START_DATE   := l_implicit_rec.EXPIRATION_PERIOD_START_DATE;
        l_MODIFIERS_rec.EXPIRATION_PERIOD_UOM          := l_implicit_rec.EXPIRATION_PERIOD_UOM;
        l_MODIFIERS_rec.GENERATE_USING_FORMULA_ID      := l_implicit_rec.GENERATE_USING_FORMULA_ID;
        l_MODIFIERS_rec.INCOMPATIBILITY_GRP_CODE       := l_implicit_rec.INCOMPATIBILITY_GRP_CODE;
        l_MODIFIERS_rec.INVENTORY_ITEM_ID              := l_implicit_rec.INVENTORY_ITEM_ID;
        l_MODIFIERS_rec.LAST_UPDATE_DATE               := l_implicit_rec.LAST_UPDATE_DATE;
        l_MODIFIERS_rec.LAST_UPDATE_LOGIN              := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_MODIFIERS_rec.LAST_UPDATED_BY                := l_implicit_rec.LAST_UPDATED_BY;
        l_MODIFIERS_rec.LIST_HEADER_ID                 := l_implicit_rec.LIST_HEADER_ID;
        l_MODIFIERS_rec.LIST_LINE_ID                   := l_new_list_line_id;
        l_MODIFIERS_rec.LIST_LINE_NO                   := l_new_list_line_id;
        l_MODIFIERS_rec.LIST_LINE_TYPE_CODE            := l_implicit_rec.LIST_LINE_TYPE_CODE;
        l_MODIFIERS_rec.LIST_PRICE                     := l_implicit_rec.LIST_PRICE;
        l_MODIFIERS_rec.MODIFIER_LEVEL_CODE            := l_implicit_rec.MODIFIER_LEVEL_CODE;
        l_MODIFIERS_rec.NUMBER_EFFECTIVE_PERIODS       := l_implicit_rec.NUMBER_EFFECTIVE_PERIODS;
        l_MODIFIERS_rec.NUMBER_EXPIRATION_PERIODS      := l_implicit_rec.NUMBER_EXPIRATION_PERIODS;
        l_MODIFIERS_rec.OPERAND                        := l_implicit_rec.OPERAND;
        l_MODIFIERS_rec.ORGANIZATION_ID                := l_implicit_rec.ORGANIZATION_ID;
        l_MODIFIERS_rec.OVERRIDE_FLAG                  := l_implicit_rec.OVERRIDE_FLAG;
        l_MODIFIERS_rec.PERCENT_PRICE                  := l_implicit_rec.PERCENT_PRICE;
        l_MODIFIERS_rec.PRICE_BREAK_TYPE_CODE          := l_implicit_rec.PRICE_BREAK_TYPE_CODE;
        l_MODIFIERS_rec.PRICE_BY_FORMULA_ID            := l_implicit_rec.PRICE_BY_FORMULA_ID;
        l_MODIFIERS_rec.PRICING_GROUP_SEQUENCE         := l_implicit_rec.PRICING_GROUP_SEQUENCE;
        l_MODIFIERS_rec.PRICING_PHASE_ID               := l_implicit_rec.PRICING_PHASE_ID;
        l_MODIFIERS_rec.PRIMARY_UOM_FLAG               := l_implicit_rec.PRIMARY_UOM_FLAG;
        l_MODIFIERS_rec.PRINT_ON_INVOICE_FLAG          := l_implicit_rec.PRINT_ON_INVOICE_FLAG;
        l_MODIFIERS_rec.PRODUCT_PRECEDENCE             := l_implicit_rec.PRODUCT_PRECEDENCE;
        l_MODIFIERS_rec.PROGRAM_APPLICATION_ID         := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_MODIFIERS_rec.PROGRAM_ID                     := l_implicit_rec.PROGRAM_ID;
        l_MODIFIERS_rec.PROGRAM_UPDATE_DATE            := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_MODIFIERS_rec.PRORATION_TYPE_CODE            := l_implicit_rec.PRORATION_TYPE_CODE;
        l_MODIFIERS_rec.REBATE_TRXN_TYPE_CODE          := l_implicit_rec.REBATE_TRANSACTION_TYPE_CODE;
        l_MODIFIERS_rec.RELATED_ITEM_ID                := l_implicit_rec.RELATED_ITEM_ID;
        l_MODIFIERS_rec.RELATIONSHIP_TYPE_ID           := l_implicit_rec.RELATIONSHIP_TYPE_ID;
        l_MODIFIERS_rec.REPRICE_FLAG                   := l_implicit_rec.REPRICE_FLAG;
        l_MODIFIERS_rec.REQUEST_ID                     := l_implicit_rec.REQUEST_ID;
        l_MODIFIERS_rec.REVISION                       := l_implicit_rec.REVISION;
        l_MODIFIERS_rec.REVISION_DATE                  := l_implicit_rec.REVISION_DATE;
        l_MODIFIERS_rec.REVISION_REASON_CODE           := l_implicit_rec.REVISION_REASON_CODE;
        l_MODIFIERS_rec.START_DATE_ACTIVE              := l_implicit_rec.START_DATE_ACTIVE;
        l_MODIFIERS_rec.SUBSTITUTION_ATTRIBUTE         := l_implicit_rec.SUBSTITUTION_ATTRIBUTE;
        l_MODIFIERS_rec.SUBSTITUTION_CONTEXT           := l_implicit_rec.SUBSTITUTION_CONTEXT;
        l_MODIFIERS_rec.SUBSTITUTION_VALUE             := l_implicit_rec.SUBSTITUTION_VALUE;

        /* Related modifier details */
        l_MODIFIERS_rec.FROM_RLTD_MODIFIER_ID          := p_new_list_line_id;
        l_MODIFIERS_rec.TO_RLTD_MODIFIER_ID            := l_new_list_line_id;
        l_MODIFIERS_rec.RLTD_MODIFIER_GRP_NO           := l_implicit_rec.RLTD_MODIFIER_GRP_NO;
        l_MODIFIERS_rec.RLTD_MODIFIER_GRP_TYPE         := l_implicit_rec.RLTD_MODIFIER_GRP_TYPE;

        l_MODIFIERS_rec.db_flag 		       := FND_API.G_TRUE;
        l_MODIFIERS_rec.operation 	               := QP_GLOBALS.G_OPR_CREATE;

        l_MODIFIERS_tbl(l_MODIFIERS_tbl.COUNT + 1) := l_MODIFIERS_rec;
        l_number_of_lines := l_number_of_lines + 1;

        /*************************************************************************************/
	/*          	Related Lines Pricing Attributes Duplication			     */
	/*************************************************************************************/

        FOR l_implicit_attr_rec IN l_PRICING_ATTR_rltd_csr(l_implicit_rec.list_line_id) LOOP

        oe_debug_pub.add('Inside pricing attribute cursor of related modifier line : '||l_new_list_line_id, 3);

    	    SELECT qp_pricing_attributes_s.nextval INTO l_new_pricing_attribute_id
	    FROM dual;

	        l_PRICING_ATTR_rec.accumulate_flag 		:= l_implicit_attr_rec.ACCUMULATE_FLAG;
        	l_PRICING_ATTR_rec.attribute1      		:= l_implicit_attr_rec.ATTRIBUTE1;
	        l_PRICING_ATTR_rec.attribute10 			:= l_implicit_attr_rec.ATTRIBUTE10;
	        l_PRICING_ATTR_rec.attribute11 			:= l_implicit_attr_rec.ATTRIBUTE11;
        	l_PRICING_ATTR_rec.attribute12 			:= l_implicit_attr_rec.ATTRIBUTE12;
	        l_PRICING_ATTR_rec.attribute13 			:= l_implicit_attr_rec.ATTRIBUTE13;
        	l_PRICING_ATTR_rec.attribute14 			:= l_implicit_attr_rec.ATTRIBUTE14;
        	l_PRICING_ATTR_rec.attribute15 			:= l_implicit_attr_rec.ATTRIBUTE15;
	        l_PRICING_ATTR_rec.attribute2  			:= l_implicit_attr_rec.ATTRIBUTE2;
	        l_PRICING_ATTR_rec.attribute3  			:= l_implicit_attr_rec.ATTRIBUTE3;
        	l_PRICING_ATTR_rec.attribute4  			:= l_implicit_attr_rec.ATTRIBUTE4;
	        l_PRICING_ATTR_rec.attribute5  			:= l_implicit_attr_rec.ATTRIBUTE5;
	        l_PRICING_ATTR_rec.attribute6  			:= l_implicit_attr_rec.ATTRIBUTE6;
	        l_PRICING_ATTR_rec.attribute7  			:= l_implicit_attr_rec.ATTRIBUTE7;
	        l_PRICING_ATTR_rec.attribute8  			:= l_implicit_attr_rec.ATTRIBUTE8;
        	l_PRICING_ATTR_rec.attribute9  			:= l_implicit_attr_rec.ATTRIBUTE9;
        	l_PRICING_ATTR_rec.attribute_grouping_no 	:= l_implicit_attr_rec.ATTRIBUTE_GROUPING_NO;
	        l_PRICING_ATTR_rec.context     			:= l_implicit_attr_rec.CONTEXT;
        	l_PRICING_ATTR_rec.created_by  			:= l_implicit_attr_rec.CREATED_BY;
	        l_PRICING_ATTR_rec.creation_date 		:= l_implicit_attr_rec.CREATION_DATE;
        	l_PRICING_ATTR_rec.excluder_flag 		:= l_implicit_attr_rec.EXCLUDER_FLAG;
	        l_PRICING_ATTR_rec.last_updated_by 		:= l_implicit_attr_rec.LAST_UPDATED_BY;
	        l_PRICING_ATTR_rec.last_update_date 		:= l_implicit_attr_rec.LAST_UPDATE_DATE;
	        l_PRICING_ATTR_rec.last_update_login 		:= l_implicit_attr_rec.LAST_UPDATE_LOGIN;
	        l_PRICING_ATTR_rec.list_line_id 		:= l_new_list_line_id;
	        l_PRICING_ATTR_rec.list_header_id 		:= l_implicit_attr_rec.LIST_HEADER_ID;
        	l_PRICING_ATTR_rec.pricing_phase_id 		:= l_implicit_attr_rec.PRICING_PHASE_ID;
	        l_PRICING_ATTR_rec.pricing_attribute 		:= l_implicit_attr_rec.PRICING_ATTRIBUTE;
        	l_PRICING_ATTR_rec.pricing_attribute_context 	:= l_implicit_attr_rec.PRICING_ATTRIBUTE_CONTEXT;
	        l_PRICING_ATTR_rec.pricing_attribute_id 	:= l_new_pricing_attribute_id;
        	l_PRICING_ATTR_rec.pricing_attr_value_from 	:= l_implicit_attr_rec.PRICING_ATTR_VALUE_FROM;
	        l_PRICING_ATTR_rec.pricing_attr_value_to 	:= l_implicit_attr_rec.PRICING_ATTR_VALUE_TO;
	        l_PRICING_ATTR_rec.product_attribute 		:= l_implicit_attr_rec.PRODUCT_ATTRIBUTE;
	        l_PRICING_ATTR_rec.product_attribute_context 	:= l_implicit_attr_rec.PRODUCT_ATTRIBUTE_CONTEXT;
	        l_PRICING_ATTR_rec.product_attr_value 		:= l_implicit_attr_rec.PRODUCT_ATTR_VALUE;
	        l_PRICING_ATTR_rec.product_uom_code 		:= l_implicit_attr_rec.PRODUCT_UOM_CODE;
        	l_PRICING_ATTR_rec.program_application_id 	:= l_implicit_attr_rec.PROGRAM_APPLICATION_ID;
	        l_PRICING_ATTR_rec.program_id  			:= l_implicit_attr_rec.PROGRAM_ID;
	        l_PRICING_ATTR_rec.program_update_date 		:= l_implicit_attr_rec.PROGRAM_UPDATE_DATE;
	        l_PRICING_ATTR_rec.request_id  			:= l_implicit_attr_rec.REQUEST_ID;
	        l_PRICING_ATTR_rec.comparison_operator_code 	:= l_implicit_attr_rec.comparison_operator_code;
        	l_PRICING_ATTR_rec.pricing_attribute_datatype 	:= l_implicit_attr_rec.pricing_attribute_datatype;
	        l_PRICING_ATTR_rec.product_attribute_datatype 	:= l_implicit_attr_rec.product_attribute_datatype;
        	l_PRICING_ATTR_rec.pricing_attr_value_from_number := l_implicit_attr_rec.PRICING_ATTR_VALUE_FROM_NUMBER;
	        l_PRICING_ATTR_rec.pricing_attr_value_to_number := l_implicit_attr_rec.PRICING_ATTR_VALUE_TO_NUMBER;
	        l_PRICING_ATTR_rec.qualification_ind 		:= l_implicit_attr_rec.QUALIFICATION_IND;
           	l_PRICING_ATTR_rec.MODIFIERS_INDEX              := l_number_of_lines;
        	l_PRICING_ATTR_rec.operation 			:= QP_GLOBALS.G_OPR_CREATE;

        	l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

         END LOOP;
      END LOOP;
    END IF;
    /******************************************************************************************/
    /*          			Qualifiers Duplication				      */
    /******************************************************************************************/
    FOR l_implicit_rec IN l_QUALIFIER_csr(p_old_list_line_id) LOOP

        oe_debug_pub.add('Inside qualifier cursor of line : '||p_new_list_line_id, 3);

        SELECT qp_qualifiers_s.nextval INTO l_new_qualifier_id
        FROM dual;

 	l_QUALIFIERS_rec.ACTIVE_FLAG                          := l_implicit_rec.ACTIVE_FLAG;
 	l_QUALIFIERS_rec.ATTRIBUTE1                           := l_implicit_rec.ATTRIBUTE1;
 	l_QUALIFIERS_rec.ATTRIBUTE2                           := l_implicit_rec.ATTRIBUTE2;
 	l_QUALIFIERS_rec.ATTRIBUTE3                           := l_implicit_rec.ATTRIBUTE3;
 	l_QUALIFIERS_rec.ATTRIBUTE4                           := l_implicit_rec.ATTRIBUTE4;
 	l_QUALIFIERS_rec.ATTRIBUTE5                           := l_implicit_rec.ATTRIBUTE5;
 	l_QUALIFIERS_rec.ATTRIBUTE6                           := l_implicit_rec.ATTRIBUTE6;
 	l_QUALIFIERS_rec.ATTRIBUTE7                           := l_implicit_rec.ATTRIBUTE7;
 	l_QUALIFIERS_rec.ATTRIBUTE8                           := l_implicit_rec.ATTRIBUTE8;
 	l_QUALIFIERS_rec.ATTRIBUTE9                           := l_implicit_rec.ATTRIBUTE9;
 	l_QUALIFIERS_rec.ATTRIBUTE10                          := l_implicit_rec.ATTRIBUTE10;
 	l_QUALIFIERS_rec.ATTRIBUTE11                          := l_implicit_rec.ATTRIBUTE11;
 	l_QUALIFIERS_rec.ATTRIBUTE12                          := l_implicit_rec.ATTRIBUTE12;
 	l_QUALIFIERS_rec.ATTRIBUTE13                          := l_implicit_rec.ATTRIBUTE13;
 	l_QUALIFIERS_rec.ATTRIBUTE14                          := l_implicit_rec.ATTRIBUTE14;
 	l_QUALIFIERS_rec.ATTRIBUTE15                          := l_implicit_rec.ATTRIBUTE15;
 	l_QUALIFIERS_rec.COMPARISON_OPERATOR_CODE             := l_implicit_rec.COMPARISON_OPERATOR_CODE;
 	l_QUALIFIERS_rec.CONTEXT                              := l_implicit_rec.CONTEXT;
 	l_QUALIFIERS_rec.CREATED_BY                           := l_implicit_rec.CREATED_BY;
 	l_QUALIFIERS_rec.CREATED_FROM_RULE_ID                 := l_implicit_rec.CREATED_FROM_RULE_ID;
 	l_QUALIFIERS_rec.CREATION_DATE                        := l_implicit_rec.CREATION_DATE;
 	l_QUALIFIERS_rec.DISTINCT_ROW_COUNT                   := l_implicit_rec.DISTINCT_ROW_COUNT;
 	l_QUALIFIERS_rec.END_DATE_ACTIVE                      := l_implicit_rec.END_DATE_ACTIVE;
 	l_QUALIFIERS_rec.EXCLUDER_FLAG                        := l_implicit_rec.EXCLUDER_FLAG;
 	l_QUALIFIERS_rec.HEADER_QUALS_EXIST_FLAG              := l_implicit_rec.HEADER_QUALS_EXIST_FLAG;
 	l_QUALIFIERS_rec.LAST_UPDATE_DATE                     := l_implicit_rec.LAST_UPDATE_DATE;
 	l_QUALIFIERS_rec.LAST_UPDATE_LOGIN                    := l_implicit_rec.LAST_UPDATE_LOGIN;
 	l_QUALIFIERS_rec.LAST_UPDATED_BY                      := l_implicit_rec.LAST_UPDATED_BY;
 	l_QUALIFIERS_rec.LIST_HEADER_ID                       := l_implicit_rec.LIST_HEADER_ID;
 	l_QUALIFIERS_rec.LIST_LINE_ID                         := p_new_list_line_id;
 	l_QUALIFIERS_rec.LIST_TYPE_CODE                       := l_implicit_rec.LIST_TYPE_CODE;
 	l_QUALIFIERS_rec.PROGRAM_APPLICATION_ID               := l_implicit_rec.PROGRAM_APPLICATION_ID;
 	l_QUALIFIERS_rec.PROGRAM_ID                           := l_implicit_rec.PROGRAM_ID;
 	l_QUALIFIERS_rec.PROGRAM_UPDATE_DATE                  := l_implicit_rec.PROGRAM_UPDATE_DATE;
 	l_QUALIFIERS_rec.QUAL_ATTR_VALUE_FROM_NUMBER          := l_implicit_rec.QUAL_ATTR_VALUE_FROM_NUMBER;
 	l_QUALIFIERS_rec.QUAL_ATTR_VALUE_TO_NUMBER            := l_implicit_rec.QUAL_ATTR_VALUE_TO_NUMBER;
 	l_QUALIFIERS_rec.QUALIFIER_ATTR_VALUE                 := l_implicit_rec.QUALIFIER_ATTR_VALUE;
	l_QUALIFIERS_rec.QUALIFIER_ATTR_VALUE_TO              := l_implicit_rec.QUALIFIER_ATTR_VALUE_TO;
 	l_QUALIFIERS_rec.QUALIFIER_ATTRIBUTE                  := l_implicit_rec.QUALIFIER_ATTRIBUTE;
 	l_QUALIFIERS_rec.QUALIFIER_CONTEXT                    := l_implicit_rec.QUALIFIER_CONTEXT;
 	l_QUALIFIERS_rec.QUALIFIER_DATATYPE                   := l_implicit_rec.QUALIFIER_DATATYPE;
 	l_QUALIFIERS_rec.QUALIFIER_GROUP_CNT                  := l_implicit_rec.QUALIFIER_GROUP_CNT;
 	l_QUALIFIERS_rec.QUALIFIER_GROUPING_NO                := l_implicit_rec.QUALIFIER_GROUPING_NO;
 	l_QUALIFIERS_rec.QUALIFIER_ID                         := l_new_qualifier_id;
 	l_QUALIFIERS_rec.QUALIFIER_PRECEDENCE                 := l_implicit_rec.QUALIFIER_PRECEDENCE;
 	l_QUALIFIERS_rec.QUALIFIER_RULE_ID                    := l_implicit_rec.QUALIFIER_RULE_ID;
 	l_QUALIFIERS_rec.REQUEST_ID                           := l_implicit_rec.REQUEST_ID;
 	l_QUALIFIERS_rec.SEARCH_IND                           := l_implicit_rec.SEARCH_IND;
 	l_QUALIFIERS_rec.START_DATE_ACTIVE                    := l_implicit_rec.START_DATE_ACTIVE;

        l_QUALIFIERS_rec.operation 			      := QP_GLOBALS.G_OPR_CREATE;

        l_QUALIFIERS_tbl(l_QUALIFIERS_tbl.COUNT + 1) := l_QUALIFIERS_rec;

    END LOOP;

    /***************************************************************************************/
    /*           			Set the control record			           */
    /***************************************************************************************/

    IF ((l_MODIFIERS_tbl.COUNT    <> 0) OR
        (l_PRICING_ATTR_tbl.COUNT <> 0) OR
        (l_QUALIFIERS_tbl.COUNT   <> 0))
    THEN
      l_control_rec.controlled_operation := TRUE;
      l_control_rec.write_to_DB          := TRUE;

      l_control_rec.validate_entity      := FALSE;
      l_control_rec.default_attributes   := FALSE;
      l_control_rec.change_attributes    := FALSE;
      l_control_rec.process              := FALSE;

      --  Instruct API to retain its caches

      l_control_rec.clear_api_cache      := FALSE;
      l_control_rec.clear_api_requests   := FALSE;

      /*************************************************************************************/
      /*          		Process the Dulplicated Modifier		           */
      /*************************************************************************************/

      oe_debug_pub.add('Before calling Process Modifier');

      QP_Modifiers_PVT.Process_MODIFIERS
      (   p_api_version_number          => 1.0
      ,   p_init_msg_list               => FND_API.G_TRUE
      ,   x_return_status               => l_return_status
      ,   x_msg_count                   => x_msg_count
      ,   x_msg_data                    => x_msg_data
      ,   p_control_rec                 => l_control_rec
      ,   p_MODIFIERS_tbl               => l_MODIFIERS_tbl
      ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
      ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
      ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
      ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
      ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
      ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
      );

-- Upgrade Non Continuous Price Break Lines into Continuous Price Break Lines.
IF (l_continuous_price_break_flag<>'Y' OR  l_continuous_price_break_flag IS NULL )and p_list_line_type_code='PBH' THEN

      qp_delayed_requests_PVT.log_request
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_entity_id              =>p_new_list_line_id
       , p_requesting_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_requesting_entity_id   => p_new_list_line_id
       , p_request_type           => QP_Globals.G_UPGRADE_PRICE_BREAKS
       , p_param1                 => null
       , p_param2                 => null
       , p_param3                 => null
       , x_return_status          => l_return_status);


     QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , x_return_status          => l_return_status);

     fnd_message.set_name('QP','QP_CONT_DUPLICATE_LINE');
     OE_MSG_PUB.Add;

     oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END IF;

      oe_debug_pub.add('After calling Process Modifier');
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
      END IF;
      oe_debug_pub.add('Outside Duplicate Record');
    END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

           x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Write to DB'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Dup_record;





END QP_QP_Form_Modifiers;

/
