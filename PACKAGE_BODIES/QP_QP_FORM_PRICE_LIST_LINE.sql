--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_PRICE_LIST_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_PRICE_LIST_LINE" AS
/* $Header: QPXFPLLB.pls 120.2 2006/02/22 06:27:33 prarasto noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Price_List_Line';

--  Global variables holding cached record.

g_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
g_db_PRICE_LIST_LINE_rec      QP_Price_List_PUB.Price_List_Line_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_PRICE_LIST_LINE
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_PRICE_LIST_LINE
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_line_id                  IN  NUMBER
)
RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type;

PROCEDURE Clear_PRICE_LIST_LINE;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Price_List_PUB.Price_List_Line_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN NUMBER
,   x_accrual_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accrual_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_group_no        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_accrual_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_from_rltd_modifier_id           IN  NUMBER := NULL
,   x_recurring_value               OUT NOCOPY /* file.sql.39 change */ NUMBER -- block pricing
,   x_customer_item_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_break_uom_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_continuous_price_break_flag       OUT NOCOPY                          VARCHAR2 --Continuous Price Breaks
)
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_val_rec     QP_Price_List_PUB.Price_List_Line_Val_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

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

    l_PRICE_LIST_LINE_rec.list_header_id := p_list_header_id;
    l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := p_from_rltd_modifier_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_PRICE_LIST_LINE_rec.attribute1              := NULL;
    l_PRICE_LIST_LINE_rec.attribute10             := NULL;
    l_PRICE_LIST_LINE_rec.attribute11             := NULL;
    l_PRICE_LIST_LINE_rec.attribute12             := NULL;
    l_PRICE_LIST_LINE_rec.attribute13             := NULL;
    l_PRICE_LIST_LINE_rec.attribute14             := NULL;
    l_PRICE_LIST_LINE_rec.attribute15             := NULL;
    l_PRICE_LIST_LINE_rec.attribute2              := NULL;
    l_PRICE_LIST_LINE_rec.attribute3              := NULL;
    l_PRICE_LIST_LINE_rec.attribute4              := NULL;
    l_PRICE_LIST_LINE_rec.attribute5              := NULL;
    l_PRICE_LIST_LINE_rec.attribute6              := NULL;
    l_PRICE_LIST_LINE_rec.attribute7              := NULL;
    l_PRICE_LIST_LINE_rec.attribute8              := NULL;
    l_PRICE_LIST_LINE_rec.attribute9              := NULL;
    l_PRICE_LIST_LINE_rec.context                 := NULL;

    --  Set Operation to Create

    l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate PRICE_LIST_LINE table

    l_PRICE_LIST_LINE_tbl(1) := l_PRICE_LIST_LINE_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

   oe_debug_pub.add('after process price list 0');
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   oe_debug_pub.add('after process price list 1');
    --  Unload out tbl

    l_x_PRICE_LIST_LINE_rec := l_x_PRICE_LIST_LINE_tbl(1);

    --  Load OUT parameters.

    x_accrual_qty                  := l_x_PRICE_LIST_LINE_rec.accrual_qty;
    x_accrual_uom_code             := l_x_PRICE_LIST_LINE_rec.accrual_uom_code;
    x_arithmetic_operator          := l_x_PRICE_LIST_LINE_rec.arithmetic_operator;
    x_attribute1                   := l_x_PRICE_LIST_LINE_rec.attribute1;
    x_attribute10                  := l_x_PRICE_LIST_LINE_rec.attribute10;
    x_attribute11                  := l_x_PRICE_LIST_LINE_rec.attribute11;
    x_attribute12                  := l_x_PRICE_LIST_LINE_rec.attribute12;
    x_attribute13                  := l_x_PRICE_LIST_LINE_rec.attribute13;
    x_attribute14                  := l_x_PRICE_LIST_LINE_rec.attribute14;
    x_attribute15                  := l_x_PRICE_LIST_LINE_rec.attribute15;
    x_attribute2                   := l_x_PRICE_LIST_LINE_rec.attribute2;
    x_attribute3                   := l_x_PRICE_LIST_LINE_rec.attribute3;
    x_attribute4                   := l_x_PRICE_LIST_LINE_rec.attribute4;
    x_attribute5                   := l_x_PRICE_LIST_LINE_rec.attribute5;
    x_attribute6                   := l_x_PRICE_LIST_LINE_rec.attribute6;
    x_attribute7                   := l_x_PRICE_LIST_LINE_rec.attribute7;
    x_attribute8                   := l_x_PRICE_LIST_LINE_rec.attribute8;
    x_attribute9                   := l_x_PRICE_LIST_LINE_rec.attribute9;
    x_automatic_flag               := l_x_PRICE_LIST_LINE_rec.automatic_flag;
    x_base_qty                     := l_x_PRICE_LIST_LINE_rec.base_qty;
    x_base_uom_code                := l_x_PRICE_LIST_LINE_rec.base_uom_code;
    x_comments                     := l_x_PRICE_LIST_LINE_rec.comments;
    x_context                      := l_x_PRICE_LIST_LINE_rec.context;
    x_effective_period_uom         := l_x_PRICE_LIST_LINE_rec.effective_period_uom;
    x_end_date_active              := l_x_PRICE_LIST_LINE_rec.end_date_active;
    x_estim_accrual_rate           := l_x_PRICE_LIST_LINE_rec.estim_accrual_rate;
    x_generate_using_formula_id    := l_x_PRICE_LIST_LINE_rec.generate_using_formula_id;
    x_inventory_item_id            := l_x_PRICE_LIST_LINE_rec.inventory_item_id;
    x_list_header_id               := l_x_PRICE_LIST_LINE_rec.list_header_id;
    x_list_line_id                 := l_x_PRICE_LIST_LINE_rec.list_line_id;
    x_list_line_type_code          := l_x_PRICE_LIST_LINE_rec.list_line_type_code;
    x_list_price                   := l_x_PRICE_LIST_LINE_rec.list_price;
    x_from_rltd_modifier_id        := l_x_PRICE_LIST_LINE_rec.from_rltd_modifier_id;
    x_rltd_modifier_group_no       := l_x_PRICE_LIST_LINE_rec.rltd_modifier_group_no;
    x_product_precedence           := l_x_PRICE_LIST_LINE_rec.product_precedence;
    x_modifier_level_code          := l_x_PRICE_LIST_LINE_rec.modifier_level_code;
    x_number_effective_periods     := l_x_PRICE_LIST_LINE_rec.number_effective_periods;
    x_operand                      := l_x_PRICE_LIST_LINE_rec.operand;
    x_organization_id              := l_x_PRICE_LIST_LINE_rec.organization_id;
    x_override_flag                := l_x_PRICE_LIST_LINE_rec.override_flag;
    x_percent_price                := l_x_PRICE_LIST_LINE_rec.percent_price;
    x_price_break_type_code        := l_x_PRICE_LIST_LINE_rec.price_break_type_code;
    x_price_by_formula_id          := l_x_PRICE_LIST_LINE_rec.price_by_formula_id;
    x_primary_uom_flag             := l_x_PRICE_LIST_LINE_rec.primary_uom_flag;
    x_print_on_invoice_flag        := l_x_PRICE_LIST_LINE_rec.print_on_invoice_flag;
    x_rebate_trxn_type_code        := l_x_PRICE_LIST_LINE_rec.rebate_trxn_type_code;
    x_related_item_id              := l_x_PRICE_LIST_LINE_rec.related_item_id;
    x_relationship_type_id         := l_x_PRICE_LIST_LINE_rec.relationship_type_id;
    x_reprice_flag                 := l_x_PRICE_LIST_LINE_rec.reprice_flag;
    x_revision                     := l_x_PRICE_LIST_LINE_rec.revision;
    x_revision_date                := l_x_PRICE_LIST_LINE_rec.revision_date;
    x_revision_reason_code         := l_x_PRICE_LIST_LINE_rec.revision_reason_code;
    x_start_date_active            := l_x_PRICE_LIST_LINE_rec.start_date_active;
    x_substitution_attribute       := l_x_PRICE_LIST_LINE_rec.substitution_attribute;
    x_substitution_context         := l_x_PRICE_LIST_LINE_rec.substitution_context;
    x_substitution_value           := l_x_PRICE_LIST_LINE_rec.substitution_value;
    x_recurring_value              := l_x_PRICE_LIST_LINE_rec.recurring_value; -- block pricing
    x_customer_item_id             := l_x_PRICE_LIST_LINE_rec.customer_item_id;
    x_break_uom_code               := l_x_PRICE_LIST_LINE_rec.break_uom_code; --OKS proration
    x_break_uom_context            := l_x_PRICE_LIST_LINE_rec.break_uom_code; --OKS proration
    x_break_uom_attribute          := l_x_PRICE_LIST_LINE_rec.break_uom_attribute; --OKS proration
    x_continuous_price_break_flag      := l_x_PRICE_LIST_LINE_rec.continuous_price_break_flag;
								    --Continuous Price Breaks

    --  Load display out parameters if any

    oe_debug_pub.add('before get values');

    l_PRICE_LIST_LINE_val_rec := QP_Price_List_Line_Util.Get_Values
    (   p_PRICE_LIST_LINE_rec         => l_x_PRICE_LIST_LINE_rec
    );
    x_accrual_uom                  := l_PRICE_LIST_LINE_val_rec.accrual_uom;
    x_automatic                    := l_PRICE_LIST_LINE_val_rec.automatic;
    x_base_uom                     := l_PRICE_LIST_LINE_val_rec.base_uom;
    x_generate_using_formula       := l_PRICE_LIST_LINE_val_rec.generate_using_formula;
    x_inventory_item               := l_PRICE_LIST_LINE_val_rec.inventory_item;
    x_list_header                  := l_PRICE_LIST_LINE_val_rec.list_header;
    x_list_line                    := l_PRICE_LIST_LINE_val_rec.list_line;
    x_list_line_type               := l_PRICE_LIST_LINE_val_rec.list_line_type;
    x_modifier_level               := l_PRICE_LIST_LINE_val_rec.modifier_level;
    x_organization                 := l_PRICE_LIST_LINE_val_rec.organization;
    x_override                     := l_PRICE_LIST_LINE_val_rec.override;
    x_price_break_type             := l_PRICE_LIST_LINE_val_rec.price_break_type;
    x_price_by_formula             := l_PRICE_LIST_LINE_val_rec.price_by_formula;
    x_primary_uom                  := l_PRICE_LIST_LINE_val_rec.primary_uom;
    x_print_on_invoice             := l_PRICE_LIST_LINE_val_rec.print_on_invoice;
    x_rebate_transaction_type      := l_PRICE_LIST_LINE_val_rec.rebate_transaction_type;
    x_related_item                 := l_PRICE_LIST_LINE_val_rec.related_item;
    x_relationship_type            := l_PRICE_LIST_LINE_val_rec.relationship_type;
    x_reprice                      := l_PRICE_LIST_LINE_val_rec.reprice;
    x_revision_reason              := l_PRICE_LIST_LINE_val_rec.revision_reason;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    oe_debug_pub.add('after get values');

    l_x_PRICE_LIST_LINE_rec.db_flag := FND_API.G_FALSE;

    Write_PRICE_LIST_LINE
    (   p_PRICE_LIST_LINE_rec         => l_x_PRICE_LIST_LINE_rec
    );

    oe_debug_pub.add('after write price list line');

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('msg data is : ' || x_msg_data);

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
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_accrual_qty                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_accrual_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_base_qty                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_uom_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_effective_period_uom          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_estim_accrual_rate            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_generate_using_formula_id     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rltd_modifier_group_no        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_product_precedence            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_modifier_level_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_number_effective_periods      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_operand                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_organization_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_override_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent_price                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_type_code         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_primary_uom_flag              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice_flag         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_accrual_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_uom                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_generate_using_formula        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_modifier_level                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_organization                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_override                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_break_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_by_formula              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_print_on_invoice              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rebate_transaction_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_related_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_relationship_type             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_recurring_value               OUT NOCOPY /* file.sql.39 change */ NUMBER -- block pricing
,   x_customer_item_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_break_uom_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_context             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_break_uom_attribute           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- OKS proration
,   x_continuous_price_break_flag       OUT NOCOPY                          VARCHAR2 --Continuous Price Breaks
)
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_rec     QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_val_rec     QP_Price_List_PUB.Price_List_Line_Val_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_tbl     QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

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

    --  Read PRICE_LIST_LINE from cache

    oe_debug_pub.add('Ren: before get price list line - ca pll 1');

    l_PRICE_LIST_LINE_rec := Get_PRICE_LIST_LINE
    (   p_db_record                   => FALSE
    ,   p_list_line_id                => p_list_line_id
    );

    l_old_PRICE_LIST_LINE_rec      := l_PRICE_LIST_LINE_rec;

    oe_debug_pub.add('prog app id in ca pll 1 is: ' || l_PRICE_LIST_LINE_rec.program_application_id);
    oe_debug_pub.add('prog id in ca pll 1 is: ' || l_PRICE_LIST_LINE_rec.program_id);

    IF p_attr_id = QP_Price_List_Line_Util.G_ACCRUAL_QTY THEN
        l_PRICE_LIST_LINE_rec.accrual_qty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_ACCRUAL_UOM THEN
        l_PRICE_LIST_LINE_rec.accrual_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_ARITHMETIC_OPERATOR THEN
        l_PRICE_LIST_LINE_rec.arithmetic_operator := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_AUTOMATIC THEN
        l_PRICE_LIST_LINE_rec.automatic_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_BASE_QTY THEN
        l_PRICE_LIST_LINE_rec.base_qty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_BASE_UOM THEN
        l_PRICE_LIST_LINE_rec.base_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_COMMENTS THEN
        l_PRICE_LIST_LINE_rec.comments := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_EFFECTIVE_PERIOD_UOM THEN
        l_PRICE_LIST_LINE_rec.effective_period_uom := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_END_DATE_ACTIVE THEN
        l_PRICE_LIST_LINE_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_ESTIM_ACCRUAL_RATE THEN
        l_PRICE_LIST_LINE_rec.estim_accrual_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_GENERATE_USING_FORMULA THEN
        l_PRICE_LIST_LINE_rec.generate_using_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_INVENTORY_ITEM THEN
        l_PRICE_LIST_LINE_rec.inventory_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_LIST_HEADER THEN
        l_PRICE_LIST_LINE_rec.list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_LIST_LINE THEN
        l_PRICE_LIST_LINE_rec.list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_LIST_LINE_TYPE THEN
        l_PRICE_LIST_LINE_rec.list_line_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_LIST_PRICE THEN
        l_PRICE_LIST_LINE_rec.list_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_FROM_RLTD_MODIFIER THEN
        l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_RLTD_MODIFIER_GROUP_NO THEN
       l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PRODUCT_PRECEDENCE THEN
        l_PRICE_LIST_LINE_rec.product_precedence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_MODIFIER_LEVEL THEN
        l_PRICE_LIST_LINE_rec.modifier_level_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_NUMBER_EFFECTIVE_PERIODS THEN
        l_PRICE_LIST_LINE_rec.number_effective_periods := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_OPERAND THEN
        l_PRICE_LIST_LINE_rec.operand := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_ORGANIZATION THEN
        l_PRICE_LIST_LINE_rec.organization_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_OVERRIDE THEN
        l_PRICE_LIST_LINE_rec.override_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PERCENT_PRICE THEN
        l_PRICE_LIST_LINE_rec.percent_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PRICE_BREAK_TYPE THEN
        l_PRICE_LIST_LINE_rec.price_break_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PRICE_BY_FORMULA THEN
        l_PRICE_LIST_LINE_rec.price_by_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PRIMARY_UOM THEN
        l_PRICE_LIST_LINE_rec.primary_uom_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_PRINT_ON_INVOICE THEN
        l_PRICE_LIST_LINE_rec.print_on_invoice_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_REBATE_TRANSACTION_TYPE THEN
        l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_RECURRING_VALUE THEN
      l_PRICE_LIST_LINE_rec.recurring_value := TO_NUMBER(p_attr_value); -- block pricing
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_RELATED_ITEM THEN
        l_PRICE_LIST_LINE_rec.related_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_RELATIONSHIP_TYPE THEN
        l_PRICE_LIST_LINE_rec.relationship_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_REPRICE THEN
        l_PRICE_LIST_LINE_rec.reprice_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_REVISION THEN
        l_PRICE_LIST_LINE_rec.revision := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_REVISION_DATE THEN
        l_PRICE_LIST_LINE_rec.revision_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_REVISION_REASON THEN
        l_PRICE_LIST_LINE_rec.revision_reason_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_START_DATE_ACTIVE THEN
        l_PRICE_LIST_LINE_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_SUBSTITUTION_ATTRIBUTE THEN
        l_PRICE_LIST_LINE_rec.substitution_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_SUBSTITUTION_CONTEXT THEN
        l_PRICE_LIST_LINE_rec.substitution_context := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_SUBSTITUTION_VALUE THEN
        l_PRICE_LIST_LINE_rec.substitution_value := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_CUSTOMER_ITEM_ID THEN
        l_PRICE_LIST_LINE_rec.customer_item_id := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_line_Util.G_BREAK_UOM_CODE THEN
        l_PRICE_LIST_LINE_rec.break_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_line_Util.G_BREAK_UOM_CONTEXT THEN
        l_PRICE_LIST_LINE_rec.break_uom_context := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_BREAK_UOM_ATTRIBUTE THEN
        l_PRICE_LIST_LINE_rec.break_uom_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_continuous_price_break_flag THEN
        l_PRICE_LIST_LINE_rec.continuous_price_break_flag := p_attr_value;	--Continuous Price Breaks
    ELSIF p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Price_List_Line_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Price_List_Line_Util.G_CONTEXT
    THEN

        l_PRICE_LIST_LINE_rec.attribute1 := p_attribute1;
        l_PRICE_LIST_LINE_rec.attribute10 := p_attribute10;
        l_PRICE_LIST_LINE_rec.attribute11 := p_attribute11;
        l_PRICE_LIST_LINE_rec.attribute12 := p_attribute12;
        l_PRICE_LIST_LINE_rec.attribute13 := p_attribute13;
        l_PRICE_LIST_LINE_rec.attribute14 := p_attribute14;
        l_PRICE_LIST_LINE_rec.attribute15 := p_attribute15;
        l_PRICE_LIST_LINE_rec.attribute2 := p_attribute2;
        l_PRICE_LIST_LINE_rec.attribute3 := p_attribute3;
        l_PRICE_LIST_LINE_rec.attribute4 := p_attribute4;
        l_PRICE_LIST_LINE_rec.attribute5 := p_attribute5;
        l_PRICE_LIST_LINE_rec.attribute6 := p_attribute6;
        l_PRICE_LIST_LINE_rec.attribute7 := p_attribute7;
        l_PRICE_LIST_LINE_rec.attribute8 := p_attribute8;
        l_PRICE_LIST_LINE_rec.attribute9 := p_attribute9;
        l_PRICE_LIST_LINE_rec.context  := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICE_LIST_LINE_rec.db_flag) THEN
        l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PRICE_LIST_LINE table

    l_PRICE_LIST_LINE_tbl(1) := l_PRICE_LIST_LINE_rec;
    l_old_PRICE_LIST_LINE_tbl(1) := l_old_PRICE_LIST_LINE_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   p_old_PRICE_LIST_LINE_tbl     => l_old_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_PRICE_LIST_LINE_rec := l_x_PRICE_LIST_LINE_tbl(1);

    --  Init OUT parameters to missing.

    x_accrual_qty                  := FND_API.G_MISS_NUM;
    x_accrual_uom_code             := FND_API.G_MISS_CHAR;
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
    x_base_qty                     := FND_API.G_MISS_NUM;
    x_base_uom_code                := FND_API.G_MISS_CHAR;
    x_comments                     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_effective_period_uom         := FND_API.G_MISS_CHAR;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_estim_accrual_rate           := FND_API.G_MISS_NUM;
    x_generate_using_formula_id    := FND_API.G_MISS_NUM;
    x_inventory_item_id            := FND_API.G_MISS_NUM;
    x_list_header_id               := FND_API.G_MISS_NUM;
    x_list_line_id                 := FND_API.G_MISS_NUM;
    x_list_line_type_code          := FND_API.G_MISS_CHAR;
    x_list_price                   := FND_API.G_MISS_NUM;
    x_from_rltd_modifier_id        := FND_API.G_MISS_NUM;
    x_rltd_modifier_group_no       := FND_API.G_MISS_NUM;
    x_product_precedence           := FND_API.G_MISS_NUM;
    x_modifier_level_code          := FND_API.G_MISS_CHAR;
    x_number_effective_periods     := FND_API.G_MISS_NUM;
    x_operand                      := FND_API.G_MISS_NUM;
    x_organization_id              := FND_API.G_MISS_NUM;
    x_override_flag                := FND_API.G_MISS_CHAR;
    x_percent_price                := FND_API.G_MISS_NUM;
    x_price_break_type_code        := FND_API.G_MISS_CHAR;
    x_price_by_formula_id          := FND_API.G_MISS_NUM;
    x_primary_uom_flag             := FND_API.G_MISS_CHAR;
    x_print_on_invoice_flag        := FND_API.G_MISS_CHAR;
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
    x_accrual_uom                  := FND_API.G_MISS_CHAR;
    x_automatic                    := FND_API.G_MISS_CHAR;
    x_base_uom                     := FND_API.G_MISS_CHAR;
    x_generate_using_formula       := FND_API.G_MISS_CHAR;
    x_inventory_item               := FND_API.G_MISS_CHAR;
    x_list_header                  := FND_API.G_MISS_CHAR;
    x_list_line                    := FND_API.G_MISS_CHAR;
    x_list_line_type               := FND_API.G_MISS_CHAR;
    x_modifier_level               := FND_API.G_MISS_CHAR;
    x_organization                 := FND_API.G_MISS_CHAR;
    x_override                     := FND_API.G_MISS_CHAR;
    x_price_break_type             := FND_API.G_MISS_CHAR;
    x_price_by_formula             := FND_API.G_MISS_CHAR;
    x_primary_uom                  := FND_API.G_MISS_CHAR;
    x_print_on_invoice             := FND_API.G_MISS_CHAR;
    x_rebate_transaction_type      := FND_API.G_MISS_CHAR;
    x_related_item                 := FND_API.G_MISS_CHAR;
    x_relationship_type            := FND_API.G_MISS_CHAR;
    x_reprice                      := FND_API.G_MISS_CHAR;
    x_revision_reason              := FND_API.G_MISS_CHAR;
    x_recurring_value              := FND_API.G_MISS_NUM; -- block pricing
    x_customer_item_id		   := FND_API.G_MISS_NUM;
    x_break_uom_code               := FND_API.G_MISS_CHAR; -- OKS proration
    x_break_uom_context            := FND_API.G_MISS_CHAR; -- OKS proration
    x_break_uom_attribute          := FND_API.G_MISS_CHAR;  -- OKS proration
    x_continuous_price_break_flag      := FND_API.G_MISS_CHAR;  --Continuous Price Breaks

    --  Load display out parameters if any

    l_PRICE_LIST_LINE_val_rec := QP_Price_List_Line_Util.Get_Values
    (   p_PRICE_LIST_LINE_rec         => l_x_PRICE_LIST_LINE_rec
    ,   p_old_PRICE_LIST_LINE_rec     => l_PRICE_LIST_LINE_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.accrual_qty,
                            l_PRICE_LIST_LINE_rec.accrual_qty)
    THEN
        x_accrual_qty := l_x_PRICE_LIST_LINE_rec.accrual_qty;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.accrual_uom_code,
                            l_PRICE_LIST_LINE_rec.accrual_uom_code)
    THEN
        x_accrual_uom_code := l_x_PRICE_LIST_LINE_rec.accrual_uom_code;
        x_accrual_uom := l_PRICE_LIST_LINE_val_rec.accrual_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.arithmetic_operator,
                            l_PRICE_LIST_LINE_rec.arithmetic_operator)
    THEN
        x_arithmetic_operator := l_x_PRICE_LIST_LINE_rec.arithmetic_operator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute1,
                            l_PRICE_LIST_LINE_rec.attribute1)
    THEN
        x_attribute1 := l_x_PRICE_LIST_LINE_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute10,
                            l_PRICE_LIST_LINE_rec.attribute10)
    THEN
        x_attribute10 := l_x_PRICE_LIST_LINE_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute11,
                            l_PRICE_LIST_LINE_rec.attribute11)
    THEN
        x_attribute11 := l_x_PRICE_LIST_LINE_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute12,
                            l_PRICE_LIST_LINE_rec.attribute12)
    THEN
        x_attribute12 := l_x_PRICE_LIST_LINE_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute13,
                            l_PRICE_LIST_LINE_rec.attribute13)
    THEN
        x_attribute13 := l_x_PRICE_LIST_LINE_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute14,
                            l_PRICE_LIST_LINE_rec.attribute14)
    THEN
        x_attribute14 := l_x_PRICE_LIST_LINE_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute15,
                            l_PRICE_LIST_LINE_rec.attribute15)
    THEN
        x_attribute15 := l_x_PRICE_LIST_LINE_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute2,
                            l_PRICE_LIST_LINE_rec.attribute2)
    THEN
        x_attribute2 := l_x_PRICE_LIST_LINE_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute3,
                            l_PRICE_LIST_LINE_rec.attribute3)
    THEN
        x_attribute3 := l_x_PRICE_LIST_LINE_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute4,
                            l_PRICE_LIST_LINE_rec.attribute4)
    THEN
        x_attribute4 := l_x_PRICE_LIST_LINE_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute5,
                            l_PRICE_LIST_LINE_rec.attribute5)
    THEN
        x_attribute5 := l_x_PRICE_LIST_LINE_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute6,
                            l_PRICE_LIST_LINE_rec.attribute6)
    THEN
        x_attribute6 := l_x_PRICE_LIST_LINE_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute7,
                            l_PRICE_LIST_LINE_rec.attribute7)
    THEN
        x_attribute7 := l_x_PRICE_LIST_LINE_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute8,
                            l_PRICE_LIST_LINE_rec.attribute8)
    THEN
        x_attribute8 := l_x_PRICE_LIST_LINE_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.attribute9,
                            l_PRICE_LIST_LINE_rec.attribute9)
    THEN
        x_attribute9 := l_x_PRICE_LIST_LINE_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.automatic_flag,
                            l_PRICE_LIST_LINE_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_PRICE_LIST_LINE_rec.automatic_flag;
        x_automatic := l_PRICE_LIST_LINE_val_rec.automatic;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.base_qty,
                            l_PRICE_LIST_LINE_rec.base_qty)
    THEN
        x_base_qty := l_x_PRICE_LIST_LINE_rec.base_qty;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.base_uom_code,
                            l_PRICE_LIST_LINE_rec.base_uom_code)
    THEN
        x_base_uom_code := l_x_PRICE_LIST_LINE_rec.base_uom_code;
        x_base_uom := l_PRICE_LIST_LINE_val_rec.base_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.comments,
                            l_PRICE_LIST_LINE_rec.comments)
    THEN
        x_comments := l_x_PRICE_LIST_LINE_rec.comments;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.context,
                            l_PRICE_LIST_LINE_rec.context)
    THEN
        x_context := l_x_PRICE_LIST_LINE_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.effective_period_uom,
                            l_PRICE_LIST_LINE_rec.effective_period_uom)
    THEN
        x_effective_period_uom := l_x_PRICE_LIST_LINE_rec.effective_period_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.end_date_active,
                            l_PRICE_LIST_LINE_rec.end_date_active)
    THEN
        x_end_date_active := l_x_PRICE_LIST_LINE_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.estim_accrual_rate,
                            l_PRICE_LIST_LINE_rec.estim_accrual_rate)
    THEN
        x_estim_accrual_rate := l_x_PRICE_LIST_LINE_rec.estim_accrual_rate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.generate_using_formula_id,
                            l_PRICE_LIST_LINE_rec.generate_using_formula_id)
    THEN
        x_generate_using_formula_id := l_x_PRICE_LIST_LINE_rec.generate_using_formula_id;
        x_generate_using_formula := l_PRICE_LIST_LINE_val_rec.generate_using_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.inventory_item_id,
                            l_PRICE_LIST_LINE_rec.inventory_item_id)
    THEN
        x_inventory_item_id := l_x_PRICE_LIST_LINE_rec.inventory_item_id;
        x_inventory_item := l_PRICE_LIST_LINE_val_rec.inventory_item;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.list_header_id,
                            l_PRICE_LIST_LINE_rec.list_header_id)
    THEN
        x_list_header_id := l_x_PRICE_LIST_LINE_rec.list_header_id;
        x_list_header := l_PRICE_LIST_LINE_val_rec.list_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.list_line_id,
                            l_PRICE_LIST_LINE_rec.list_line_id)
    THEN
        x_list_line_id := l_x_PRICE_LIST_LINE_rec.list_line_id;
        x_list_line := l_PRICE_LIST_LINE_val_rec.list_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.list_line_type_code,
                            l_PRICE_LIST_LINE_rec.list_line_type_code)
    THEN
        x_list_line_type_code := l_x_PRICE_LIST_LINE_rec.list_line_type_code;
        x_list_line_type := l_PRICE_LIST_LINE_val_rec.list_line_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.list_price,
                            l_PRICE_LIST_LINE_rec.list_price)
    THEN
        x_list_price := l_x_PRICE_LIST_LINE_rec.list_price;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.from_rltd_modifier_id,
                            l_PRICE_LIST_LINE_rec.from_rltd_modifier_id)
    THEN
        x_from_rltd_modifier_id := l_x_PRICE_LIST_LINE_rec.from_rltd_modifier_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.rltd_modifier_group_no,
                            l_PRICE_LIST_LINE_rec.rltd_modifier_group_no)
    THEN
        x_rltd_modifier_group_no := l_x_PRICE_LIST_LINE_rec.rltd_modifier_group_no;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.product_precedence,
                            l_PRICE_LIST_LINE_rec.product_precedence)
    THEN
        x_product_precedence := l_x_PRICE_LIST_LINE_rec.product_precedence;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.modifier_level_code,
                            l_PRICE_LIST_LINE_rec.modifier_level_code)
    THEN
        x_modifier_level_code := l_x_PRICE_LIST_LINE_rec.modifier_level_code;
        x_modifier_level := l_PRICE_LIST_LINE_val_rec.modifier_level;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.number_effective_periods,
                            l_PRICE_LIST_LINE_rec.number_effective_periods)
    THEN
        x_number_effective_periods := l_x_PRICE_LIST_LINE_rec.number_effective_periods;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.operand,
                            l_PRICE_LIST_LINE_rec.operand)
    THEN
        x_operand := l_x_PRICE_LIST_LINE_rec.operand;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.organization_id,
                            l_PRICE_LIST_LINE_rec.organization_id)
    THEN
        x_organization_id := l_x_PRICE_LIST_LINE_rec.organization_id;
        x_organization := l_PRICE_LIST_LINE_val_rec.organization;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.override_flag,
                            l_PRICE_LIST_LINE_rec.override_flag)
    THEN
        x_override_flag := l_x_PRICE_LIST_LINE_rec.override_flag;
        x_override := l_PRICE_LIST_LINE_val_rec.override;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.percent_price,
                            l_PRICE_LIST_LINE_rec.percent_price)
    THEN
        x_percent_price := l_x_PRICE_LIST_LINE_rec.percent_price;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.price_break_type_code,
                            l_PRICE_LIST_LINE_rec.price_break_type_code)
    THEN
        x_price_break_type_code := l_x_PRICE_LIST_LINE_rec.price_break_type_code;
        x_price_break_type := l_PRICE_LIST_LINE_val_rec.price_break_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.price_by_formula_id,
                            l_PRICE_LIST_LINE_rec.price_by_formula_id)
    THEN
        x_price_by_formula_id := l_x_PRICE_LIST_LINE_rec.price_by_formula_id;
        x_price_by_formula := l_PRICE_LIST_LINE_val_rec.price_by_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.primary_uom_flag,
                            l_PRICE_LIST_LINE_rec.primary_uom_flag)
    THEN
        x_primary_uom_flag := l_x_PRICE_LIST_LINE_rec.primary_uom_flag;
        x_primary_uom := l_PRICE_LIST_LINE_val_rec.primary_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.print_on_invoice_flag,
                            l_PRICE_LIST_LINE_rec.print_on_invoice_flag)
    THEN
        x_print_on_invoice_flag := l_x_PRICE_LIST_LINE_rec.print_on_invoice_flag;
        x_print_on_invoice := l_PRICE_LIST_LINE_val_rec.print_on_invoice;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.rebate_trxn_type_code,
                            l_PRICE_LIST_LINE_rec.rebate_trxn_type_code)
    THEN
        x_rebate_trxn_type_code := l_x_PRICE_LIST_LINE_rec.rebate_trxn_type_code;
        x_rebate_transaction_type := l_PRICE_LIST_LINE_val_rec.rebate_transaction_type;
    END IF;


    -- block pricing
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.recurring_value,
                            l_PRICE_LIST_LINE_rec.recurring_value)
    THEN
      x_recurring_value := l_x_PRICE_LIST_LINE_rec.recurring_value;
    END IF;


    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.related_item_id,
                            l_PRICE_LIST_LINE_rec.related_item_id)
    THEN
        x_related_item_id := l_x_PRICE_LIST_LINE_rec.related_item_id;
        x_related_item := l_PRICE_LIST_LINE_val_rec.related_item;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.relationship_type_id,
                            l_PRICE_LIST_LINE_rec.relationship_type_id)
    THEN
        x_relationship_type_id := l_x_PRICE_LIST_LINE_rec.relationship_type_id;
        x_relationship_type := l_PRICE_LIST_LINE_val_rec.relationship_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.reprice_flag,
                            l_PRICE_LIST_LINE_rec.reprice_flag)
    THEN
        x_reprice_flag := l_x_PRICE_LIST_LINE_rec.reprice_flag;
        x_reprice := l_PRICE_LIST_LINE_val_rec.reprice;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.revision,
                            l_PRICE_LIST_LINE_rec.revision)
    THEN
        x_revision := l_x_PRICE_LIST_LINE_rec.revision;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.revision_date,
                            l_PRICE_LIST_LINE_rec.revision_date)
    THEN
        x_revision_date := l_x_PRICE_LIST_LINE_rec.revision_date;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.revision_reason_code,
                            l_PRICE_LIST_LINE_rec.revision_reason_code)
    THEN
        x_revision_reason_code := l_x_PRICE_LIST_LINE_rec.revision_reason_code;
        x_revision_reason := l_PRICE_LIST_LINE_val_rec.revision_reason;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.start_date_active,
                            l_PRICE_LIST_LINE_rec.start_date_active)
    THEN
        x_start_date_active := l_x_PRICE_LIST_LINE_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.substitution_attribute,
                            l_PRICE_LIST_LINE_rec.substitution_attribute)
    THEN
        x_substitution_attribute := l_x_PRICE_LIST_LINE_rec.substitution_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.substitution_context,
                            l_PRICE_LIST_LINE_rec.substitution_context)
    THEN
        x_substitution_context := l_x_PRICE_LIST_LINE_rec.substitution_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.substitution_value,
                            l_PRICE_LIST_LINE_rec.substitution_value)
    THEN
        x_substitution_value := l_x_PRICE_LIST_LINE_rec.substitution_value;
    END IF;

    IF NOT QP_GLOBALS.Equal (l_x_PRICE_LIST_LINE_rec.customer_item_id,
                             l_PRICE_LIST_LINE_rec.customer_item_id)
    THEN
        x_customer_item_id := l_x_PRICE_LIST_LINE_rec.customer_item_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.break_uom_code,
                            l_PRICE_LIST_LINE_rec.break_uom_code)
    THEN
        x_break_uom_code := l_x_PRICE_LIST_LINE_rec.break_uom_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.break_uom_context,
                            l_PRICE_LIST_LINE_rec.break_uom_context)
    THEN
        x_break_uom_context := l_x_PRICE_LIST_LINE_rec.break_uom_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.break_uom_attribute,
                            l_PRICE_LIST_LINE_rec.break_uom_attribute)
    THEN
        x_break_uom_attribute := l_x_PRICE_LIST_LINE_rec.break_uom_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_LINE_rec.continuous_price_break_flag,
                            l_PRICE_LIST_LINE_rec.continuous_price_break_flag)
    THEN
        x_continuous_price_break_flag := l_x_PRICE_LIST_LINE_rec.continuous_price_break_flag;
    END IF;

    --  Write to cache.

    Write_PRICE_LIST_LINE
    (   p_PRICE_LIST_LINE_rec         => l_x_PRICE_LIST_LINE_rec
    );

    oe_debug_pub.add('prog app id in ca pll 2 is: ' || l_x_PRICE_LIST_LINE_rec.program_application_id);
    oe_debug_pub.add('prog id in ca pll 2 is: ' || l_x_PRICE_LIST_LINE_rec.program_id);
    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_program_application_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_update_date           OUT NOCOPY /* file.sql.39 change */ DATE
,   x_request_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_PRICE_LIST_LINE_rec     QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_PRICE_LIST_LINE_tbl     QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

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

    --  Read PRICE_LIST_LINE from cache

    l_old_PRICE_LIST_LINE_rec := Get_PRICE_LIST_LINE
    (   p_db_record                   => TRUE
    ,   p_list_line_id                => p_list_line_id
    );

    l_PRICE_LIST_LINE_rec := Get_PRICE_LIST_LINE
    (   p_db_record                   => FALSE
    ,   p_list_line_id                => p_list_line_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICE_LIST_LINE_rec.db_flag) THEN
        l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PRICE_LIST_LINE table

    l_PRICE_LIST_LINE_tbl(1) := l_PRICE_LIST_LINE_rec;
    l_old_PRICE_LIST_LINE_tbl(1) := l_old_PRICE_LIST_LINE_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   p_old_PRICE_LIST_LINE_tbl     => l_old_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_PRICE_LIST_LINE_rec := l_x_PRICE_LIST_LINE_tbl(1);

    x_creation_date                := l_x_PRICE_LIST_LINE_rec.creation_date;
    x_created_by                   := l_x_PRICE_LIST_LINE_rec.created_by;
    x_last_update_date             := l_x_PRICE_LIST_LINE_rec.last_update_date;
    x_last_updated_by              := l_x_PRICE_LIST_LINE_rec.last_updated_by;
  x_last_update_login            := l_x_PRICE_LIST_LINE_rec.last_update_login;
 x_program_application_id     := l_x_PRICE_LIST_LINE_rec.program_application_id;
 x_program_id     := l_x_PRICE_LIST_LINE_rec.program_id;
 x_program_update_date     := l_x_PRICE_LIST_LINE_rec.program_update_date;
 x_request_id     := l_x_PRICE_LIST_LINE_rec.request_id;

    --  Clear PRICE_LIST_LINE record cache

    Clear_PRICE_LIST_LINE;

    --  Keep track of performed operations.

    l_old_PRICE_LIST_LINE_rec.operation := l_PRICE_LIST_LINE_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

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

    l_PRICE_LIST_LINE_rec := Get_PRICE_LIST_LINE
    (   p_db_record                   => TRUE
    ,   p_list_line_id                => p_list_line_id
    );

    --  Set Operation.

    l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate PRICE_LIST_LINE table

    l_PRICE_LIST_LINE_tbl(1) := l_PRICE_LIST_LINE_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear PRICE_LIST_LINE record cache

    Clear_PRICE_LIST_LINE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
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

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   p_accrual_qty                   IN  NUMBER
,   p_accrual_uom_code              IN  VARCHAR2
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
,   p_base_qty                      IN  NUMBER
,   p_base_uom_code                 IN  VARCHAR2
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_effective_period_uom          IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_estim_accrual_rate            IN  NUMBER
,   p_generate_using_formula_id     IN  NUMBER
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_list_line_type_code           IN  VARCHAR2
,   p_list_price                    IN  NUMBER
,   p_product_precedence            IN  NUMBER
,   p_modifier_level_code           IN  VARCHAR2
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
,   p_recurring_value               IN  NUMBER -- block pricing
,   p_customer_item_id              IN  NUMBER
,   p_break_uom_code                IN  VARCHAR2 -- OKS proration
,   p_break_uom_context             IN  VARCHAR2 -- OKS
,   p_break_uom_attribute           IN  VARCHAR2 -- OKS proration
,   p_continuous_price_break_flag       IN  VARCHAR2 --Continuous price breaks
)
IS
l_return_status               VARCHAR2(1);
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('inside lock price list - form 1');

    --  Load PRICE_LIST_LINE record

    l_PRICE_LIST_LINE_rec.accrual_qty := p_accrual_qty;
    l_PRICE_LIST_LINE_rec.accrual_uom_code := p_accrual_uom_code;
    l_PRICE_LIST_LINE_rec.arithmetic_operator := p_arithmetic_operator;
    l_PRICE_LIST_LINE_rec.attribute1 := p_attribute1;
    l_PRICE_LIST_LINE_rec.attribute10 := p_attribute10;
    l_PRICE_LIST_LINE_rec.attribute11 := p_attribute11;
    l_PRICE_LIST_LINE_rec.attribute12 := p_attribute12;
    l_PRICE_LIST_LINE_rec.attribute13 := p_attribute13;
    l_PRICE_LIST_LINE_rec.attribute14 := p_attribute14;
    l_PRICE_LIST_LINE_rec.attribute15 := p_attribute15;
    l_PRICE_LIST_LINE_rec.attribute2 := p_attribute2;
    l_PRICE_LIST_LINE_rec.attribute3 := p_attribute3;
    l_PRICE_LIST_LINE_rec.attribute4 := p_attribute4;
    l_PRICE_LIST_LINE_rec.attribute5 := p_attribute5;
    l_PRICE_LIST_LINE_rec.attribute6 := p_attribute6;
    l_PRICE_LIST_LINE_rec.attribute7 := p_attribute7;
    l_PRICE_LIST_LINE_rec.attribute8 := p_attribute8;
    l_PRICE_LIST_LINE_rec.attribute9 := p_attribute9;
    l_PRICE_LIST_LINE_rec.automatic_flag := p_automatic_flag;
    l_PRICE_LIST_LINE_rec.base_qty := p_base_qty;
    l_PRICE_LIST_LINE_rec.base_uom_code := p_base_uom_code;
    l_PRICE_LIST_LINE_rec.comments := p_comments;
    l_PRICE_LIST_LINE_rec.context  := p_context;
    l_PRICE_LIST_LINE_rec.created_by := p_created_by;
    l_PRICE_LIST_LINE_rec.creation_date := p_creation_date;
    l_PRICE_LIST_LINE_rec.effective_period_uom := p_effective_period_uom;
    l_PRICE_LIST_LINE_rec.end_date_active := p_end_date_active;
    l_PRICE_LIST_LINE_rec.estim_accrual_rate := p_estim_accrual_rate;
    l_PRICE_LIST_LINE_rec.generate_using_formula_id := p_generate_using_formula_id;
    l_PRICE_LIST_LINE_rec.inventory_item_id := p_inventory_item_id;
    l_PRICE_LIST_LINE_rec.last_updated_by := p_last_updated_by;
    l_PRICE_LIST_LINE_rec.last_update_date := p_last_update_date;
    l_PRICE_LIST_LINE_rec.last_update_login := p_last_update_login;
    l_PRICE_LIST_LINE_rec.list_header_id := p_list_header_id;
    l_PRICE_LIST_LINE_rec.list_line_id := p_list_line_id;
    l_PRICE_LIST_LINE_rec.list_line_type_code := p_list_line_type_code;
    l_PRICE_LIST_LINE_rec.list_price := p_list_price;
    l_PRICE_LIST_LINE_rec.product_precedence := p_product_precedence;
    l_PRICE_LIST_LINE_rec.modifier_level_code := p_modifier_level_code;
    l_PRICE_LIST_LINE_rec.number_effective_periods := p_number_effective_periods;
    l_PRICE_LIST_LINE_rec.operand  := p_operand;
    l_PRICE_LIST_LINE_rec.organization_id := p_organization_id;
    l_PRICE_LIST_LINE_rec.override_flag := p_override_flag;
    l_PRICE_LIST_LINE_rec.percent_price := p_percent_price;
    l_PRICE_LIST_LINE_rec.price_break_type_code := p_price_break_type_code;
    l_PRICE_LIST_LINE_rec.price_by_formula_id := p_price_by_formula_id;
    l_PRICE_LIST_LINE_rec.primary_uom_flag := p_primary_uom_flag;
    l_PRICE_LIST_LINE_rec.print_on_invoice_flag := p_print_on_invoice_flag;
    l_PRICE_LIST_LINE_rec.program_application_id := p_program_application_id;
    l_PRICE_LIST_LINE_rec.program_id := p_program_id;
    l_PRICE_LIST_LINE_rec.program_update_date := p_program_update_date;
    l_PRICE_LIST_LINE_rec.rebate_trxn_type_code := p_rebate_trxn_type_code;
    l_PRICE_LIST_LINE_rec.related_item_id := p_related_item_id;
    l_PRICE_LIST_LINE_rec.relationship_type_id := p_relationship_type_id;
    l_PRICE_LIST_LINE_rec.reprice_flag := p_reprice_flag;
    l_PRICE_LIST_LINE_rec.request_id := p_request_id;
    l_PRICE_LIST_LINE_rec.revision := p_revision;
    l_PRICE_LIST_LINE_rec.revision_date := p_revision_date;
    l_PRICE_LIST_LINE_rec.revision_reason_code := p_revision_reason_code;
    l_PRICE_LIST_LINE_rec.start_date_active := p_start_date_active;
    l_PRICE_LIST_LINE_rec.substitution_attribute := p_substitution_attribute;
    l_PRICE_LIST_LINE_rec.substitution_context := p_substitution_context;
    l_PRICE_LIST_LINE_rec.substitution_value := p_substitution_value;
    l_PRICE_LIST_LINE_rec.operation := QP_GLOBALS.G_OPR_LOCK;
    l_PRICE_LIST_LINE_rec.recurring_value := p_recurring_value; -- block pricing
    l_PRICE_LIST_LINE_rec.customer_item_id := p_customer_item_id;
    l_PRICE_LIST_LINE_rec.break_uom_code  := p_break_uom_code;
    l_PRICE_LIST_LINE_rec.break_uom_context  := p_break_uom_context;
    l_PRICE_LIST_LINE_rec.break_uom_attribute := p_break_uom_attribute;
    l_PRICE_LIST_LINE_rec.continuous_price_break_flag := p_continuous_price_break_flag;--Continuous price breaks

    if (p_recurring_value IS NOT NULL) THEN
      oe_msg_pub.Add_Exc_Msg(G_PKG_NAME, 'Lock_Row');
    end if;

    --  Populate PRICE_LIST_LINE table

    l_PRICE_LIST_LINE_tbl(1) := l_PRICE_LIST_LINE_rec;

    --  Call QP_LIST_HEADERS_PVT.Lock_PRICE_LIST

   oe_debug_pub.add('before calling lock price list');

    QP_LIST_HEADERS_PVT.Lock_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

     oe_debug_pub.add('after calling lock price list');

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_PRICE_LIST_LINE_rec.db_flag := FND_API.G_TRUE;

        Write_PRICE_LIST_LINE
        (   p_PRICE_LIST_LINE_rec         => l_x_PRICE_LIST_LINE_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('mesg data in lock row : ' || x_msg_data);


EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining PRICE_LIST_LINE record cache.

PROCEDURE Write_PRICE_LIST_LINE
(   p_PRICE_LIST_LINE_rec           IN  QP_Price_List_PUB.Price_List_Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    IF p_db_record THEN

        g_db_PRICE_LIST_LINE_rec := p_PRICE_LIST_LINE_rec;

    END IF;

END Write_Price_List_Line;

FUNCTION Get_PRICE_LIST_LINE
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_line_id                  IN  NUMBER
)
RETURN QP_Price_List_PUB.Price_List_Line_Rec_Type
IS
BEGIN
    IF  p_list_line_id <> g_PRICE_LIST_LINE_rec.list_line_id
    THEN

        --  Query row from DB

	   oe_debug_pub.add('gpll - query row from db ca 1');

        g_PRICE_LIST_LINE_rec := QP_Price_List_Line_Util.Query_Row
        (   p_list_line_id                => p_list_line_id
        );

        g_PRICE_LIST_LINE_rec.db_flag  := FND_API.G_TRUE;

        --  Load DB record

        g_db_PRICE_LIST_LINE_rec       := g_PRICE_LIST_LINE_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_PRICE_LIST_LINE_rec;

    ELSE

        RETURN g_PRICE_LIST_LINE_rec;

    END IF;

END Get_Price_List_Line;

PROCEDURE Clear_Price_List_Line
IS
BEGIN

    g_PRICE_LIST_LINE_rec          := QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC;
    g_db_PRICE_LIST_LINE_rec       := QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_REC;

END Clear_Price_List_Line;

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
					p_entity_code  => QP_GLOBALS.G_ENTITY_PRICE_LIST_LINE
					,p_entity_id    => p_list_line_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Price_List_Line;

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


-- This procedure will be called from the client when the user
-- clears a block or Form
Procedure Delete_All_Requests
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Clear_Request(
				     x_return_status => l_return_status);

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_All_Requests'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_All_Requests;


END QP_QP_Form_Price_List_Line;

/
