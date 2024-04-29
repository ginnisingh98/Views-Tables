--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_MODIFIER_LIST" AS
/* $Header: QPXFMLHB.pls 120.4 2005/10/26 18:00:44 jhkuo ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Modifier_List';

--  Global variables holding cached record.

g_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
g_db_MODIFIER_LIST_rec        QP_Modifiers_PUB.Modifier_List_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_MODIFIER_LIST
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_MODIFIER_LIST
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_header_id                IN  NUMBER
)
RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type;

PROCEDURE Clear_MODIFIER_LIST;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Modifiers_PUB.Modifier_List_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_gsa_indicator                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_type_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_parent_list_header_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active_first       OUT NOCOPY /* file.sql.39 change */ DATE
,   x_end_date_active_first         OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_first_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active_second      OUT NOCOPY /* file.sql.39 change */ DATE
,   x_global_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active_second        OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_second_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ask_for_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_source_code		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_orig_system_header_ref        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIER_LIST_val_rec       QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
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

    oe_debug_pub.add('BEGIN default_attibutes in QPXFMLHB');
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


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_MODIFIER_LIST_rec.attribute1                := NULL;
    l_MODIFIER_LIST_rec.attribute10               := NULL;
    l_MODIFIER_LIST_rec.attribute11               := NULL;
    l_MODIFIER_LIST_rec.attribute12               := NULL;
    l_MODIFIER_LIST_rec.attribute13               := NULL;
    l_MODIFIER_LIST_rec.attribute14               := NULL;
    l_MODIFIER_LIST_rec.attribute15               := NULL;
    l_MODIFIER_LIST_rec.attribute2                := NULL;
    l_MODIFIER_LIST_rec.attribute3                := NULL;
    l_MODIFIER_LIST_rec.attribute4                := NULL;
    l_MODIFIER_LIST_rec.attribute5                := NULL;
    l_MODIFIER_LIST_rec.attribute6                := NULL;
    l_MODIFIER_LIST_rec.attribute7                := NULL;
    l_MODIFIER_LIST_rec.attribute8                := NULL;
    l_MODIFIER_LIST_rec.attribute9                := NULL;
    l_MODIFIER_LIST_rec.context                   := NULL;

    --  Set Operation to Create

    l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
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

    x_attribute1                   := l_x_MODIFIER_LIST_rec.attribute1;
    x_attribute10                  := l_x_MODIFIER_LIST_rec.attribute10;
    x_attribute11                  := l_x_MODIFIER_LIST_rec.attribute11;
    x_attribute12                  := l_x_MODIFIER_LIST_rec.attribute12;
    x_attribute13                  := l_x_MODIFIER_LIST_rec.attribute13;
    x_attribute14                  := l_x_MODIFIER_LIST_rec.attribute14;
    x_attribute15                  := l_x_MODIFIER_LIST_rec.attribute15;
    x_attribute2                   := l_x_MODIFIER_LIST_rec.attribute2;
    x_attribute3                   := l_x_MODIFIER_LIST_rec.attribute3;
    x_attribute4                   := l_x_MODIFIER_LIST_rec.attribute4;
    x_attribute5                   := l_x_MODIFIER_LIST_rec.attribute5;
    x_attribute6                   := l_x_MODIFIER_LIST_rec.attribute6;
    x_attribute7                   := l_x_MODIFIER_LIST_rec.attribute7;
    x_attribute8                   := l_x_MODIFIER_LIST_rec.attribute8;
    x_attribute9                   := l_x_MODIFIER_LIST_rec.attribute9;
    x_automatic_flag               := l_x_MODIFIER_LIST_rec.automatic_flag;
    x_comments                     := l_x_MODIFIER_LIST_rec.comments;
    x_context                      := l_x_MODIFIER_LIST_rec.context;
    x_currency_code                := l_x_MODIFIER_LIST_rec.currency_code;
    x_discount_lines_flag          := l_x_MODIFIER_LIST_rec.discount_lines_flag;
    x_end_date_active              := l_x_MODIFIER_LIST_rec.end_date_active;
    x_freight_terms_code           := l_x_MODIFIER_LIST_rec.freight_terms_code;
    x_gsa_indicator                := l_x_MODIFIER_LIST_rec.gsa_indicator;
    x_list_header_id               := l_x_MODIFIER_LIST_rec.list_header_id;
    x_list_type_code               := l_x_MODIFIER_LIST_rec.list_type_code;
    x_prorate_flag                 := l_x_MODIFIER_LIST_rec.prorate_flag;
    x_rounding_factor              := l_x_MODIFIER_LIST_rec.rounding_factor;
    x_ship_method_code             := l_x_MODIFIER_LIST_rec.ship_method_code;
    x_start_date_active            := l_x_MODIFIER_LIST_rec.start_date_active;
    x_terms_id                     := l_x_MODIFIER_LIST_rec.terms_id;
    x_source_system_code           := l_x_MODIFIER_LIST_rec.source_system_code;
    x_pte_code                     := l_x_MODIFIER_LIST_rec.pte_code;
    x_active_flag                  := l_x_MODIFIER_LIST_rec.active_flag;
    x_parent_list_header_id        := l_x_MODIFIER_LIST_rec.parent_list_header_id;
    x_start_date_active_first      := l_x_MODIFIER_LIST_rec.start_date_active_first;
    x_end_date_active_first        := l_x_MODIFIER_LIST_rec.end_date_active_first;
    x_active_date_first_type       := l_x_MODIFIER_LIST_rec.active_date_first_type;
    x_start_date_active_second     := l_x_MODIFIER_LIST_rec.start_date_active_second;
    x_global_flag                  := l_x_MODIFIER_LIST_rec.global_flag;
    x_end_date_active_second       := l_x_MODIFIER_LIST_rec.end_date_active_second;
    x_active_date_second_type      := l_x_MODIFIER_LIST_rec.active_date_second_type;
    x_ask_for_flag                 := l_x_MODIFIER_LIST_rec.ask_for_flag;
    x_name                         := l_x_MODIFIER_LIST_rec.name;
    x_description                  := l_x_MODIFIER_LIST_rec.description;
    x_version_no                   := l_x_MODIFIER_LIST_rec.version_no;
    x_list_source_code	           := l_x_MODIFIER_LIST_rec.list_source_code;
    x_orig_system_header_ref       := l_x_MODIFIER_LIST_rec.orig_system_header_ref;
    x_shareable_flag               := l_x_MODIFIER_LIST_rec.shareable_flag;
    --added for MOAC
    x_org_id                       := l_x_MODIFIER_LIST_rec.org_id;


    --  Load display out parameters if any

    l_MODIFIER_LIST_val_rec := QP_Modifier_List_Util.Get_Values
    (   p_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    );
    x_automatic                    := l_MODIFIER_LIST_val_rec.automatic;
    x_currency                     := l_MODIFIER_LIST_val_rec.currency;
    x_discount_lines               := l_MODIFIER_LIST_val_rec.discount_lines;
    x_freight_terms                := l_MODIFIER_LIST_val_rec.freight_terms;
    x_list_header                  := l_MODIFIER_LIST_val_rec.list_header;
    x_list_type                    := l_MODIFIER_LIST_val_rec.list_type;
    x_prorate                      := l_MODIFIER_LIST_val_rec.prorate;
    x_ship_method                  := l_MODIFIER_LIST_val_rec.ship_method;
    x_terms                        := l_MODIFIER_LIST_val_rec.terms;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_MODIFIER_LIST_rec.db_flag := FND_API.G_FALSE;

    Write_MODIFIER_LIST
    (   p_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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

    oe_debug_pub.add('END default_attibutes in QPXFMLHB');
END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines_flag           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_gsa_indicator                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_type_code                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_parent_list_header_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active_first       OUT NOCOPY /* file.sql.39 change */ DATE
,   x_end_date_active_first         OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_first_type        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active_second      OUT NOCOPY /* file.sql.39 change */ DATE
,   x_global_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active_second        OUT NOCOPY /* file.sql.39 change */ DATE
,   x_active_date_second_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ask_for_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_source_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_orig_system_header_ref        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_old_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIER_LIST_val_rec       QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
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

    oe_debug_pub.add('BEGIN change_attibutes in QPXFMLHB');
    OE_Debug_Pub.add(to_char(p_attr_id)||'attr_id');
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

    --  Read MODIFIER_LIST from cache

    l_MODIFIER_LIST_rec := Get_MODIFIER_LIST
    (   p_db_record                   => FALSE
    ,   p_list_header_id              => p_list_header_id
    );
OE_debug_Pub.add('returned');
    l_old_MODIFIER_LIST_rec        := l_MODIFIER_LIST_rec;

    IF p_attr_id = QP_Modifier_List_Util.G_AUTOMATIC THEN
        l_MODIFIER_LIST_rec.automatic_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_COMMENTS THEN
        l_MODIFIER_LIST_rec.comments := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_CURRENCY THEN
        l_MODIFIER_LIST_rec.currency_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_DISCOUNT_LINES THEN
        l_MODIFIER_LIST_rec.discount_lines_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_END_DATE_ACTIVE THEN
        l_MODIFIER_LIST_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_FREIGHT_TERMS THEN
        l_MODIFIER_LIST_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_GSA_INDICATOR THEN
        l_MODIFIER_LIST_rec.gsa_indicator := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_LIST_HEADER THEN
        l_MODIFIER_LIST_rec.list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifier_List_Util.G_LIST_TYPE THEN
        l_MODIFIER_LIST_rec.list_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_PRORATE THEN
        l_MODIFIER_LIST_rec.prorate_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ROUNDING_FACTOR THEN
        l_MODIFIER_LIST_rec.rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifier_List_Util.G_SHIP_METHOD THEN
        l_MODIFIER_LIST_rec.ship_method_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_START_DATE_ACTIVE THEN
        l_MODIFIER_LIST_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_TERMS THEN
        l_MODIFIER_LIST_rec.terms_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifier_List_Util.G_NAME THEN
        l_MODIFIER_LIST_rec.name := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_DESCRIPTION THEN
        l_MODIFIER_LIST_rec.Description := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_VERSION_NO THEN
        l_MODIFIER_LIST_rec.Version_no := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_PARENT_LIST_HEADER_ID THEN
        l_MODIFIER_LIST_rec.Parent_list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ACTIVE_FLAG THEN
        l_MODIFIER_LIST_rec.active_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_START_DATE_ACTIVE_FIRST THEN
        l_MODIFIER_LIST_rec.start_date_active_first := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_END_DATE_ACTIVE_FIRST THEN
        l_MODIFIER_LIST_rec.end_date_active_first := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_START_DATE_ACTIVE_SECOND THEN
        l_MODIFIER_LIST_rec.start_date_active_second := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_GLOBAL_FLAG THEN
        l_MODIFIER_LIST_rec.global_flag := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_END_DATE_ACTIVE_SECOND THEN
        l_MODIFIER_LIST_rec.end_date_active_second := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ACTIVE_DATE_FIRST_TYPE THEN
        l_MODIFIER_LIST_rec.active_date_first_type := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ACTIVE_DATE_SECOND_TYPE THEN
        l_MODIFIER_LIST_rec.active_date_second_type := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ASK_FOR THEN
        l_MODIFIER_LIST_rec.ask_for_flag := p_attr_value;
-- Blanket Agreement
    ELSIF p_attr_id = QP_Modifier_List_Util.G_SOURCE_SYSTEM_CODE THEN
        l_MODIFIER_LIST_rec.source_system_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_PTE_CODE THEN
        l_MODIFIER_LIST_rec.pte_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_LIST_SOURCE_CODE THEN
        l_MODIFIER_LIST_rec.list_source_code := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ORIG_SYSTEM_HEADER_REF THEN
        l_MODIFIER_LIST_rec.orig_system_header_ref := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_SHAREABLE_FLAG THEN
        l_MODIFIER_LIST_rec.shareable_flag := p_attr_value;
    --added for MOAC
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ORG_ID THEN
        l_MODIFIER_LIST_rec.org_id := p_attr_value;
    ELSIF p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Modifier_List_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Modifier_List_Util.G_CONTEXT
    THEN

        l_MODIFIER_LIST_rec.attribute1 := p_attribute1;
        l_MODIFIER_LIST_rec.attribute10 := p_attribute10;
        l_MODIFIER_LIST_rec.attribute11 := p_attribute11;
        l_MODIFIER_LIST_rec.attribute12 := p_attribute12;
        l_MODIFIER_LIST_rec.attribute13 := p_attribute13;
        l_MODIFIER_LIST_rec.attribute14 := p_attribute14;
        l_MODIFIER_LIST_rec.attribute15 := p_attribute15;
        l_MODIFIER_LIST_rec.attribute2 := p_attribute2;
        l_MODIFIER_LIST_rec.attribute3 := p_attribute3;
        l_MODIFIER_LIST_rec.attribute4 := p_attribute4;
        l_MODIFIER_LIST_rec.attribute5 := p_attribute5;
        l_MODIFIER_LIST_rec.attribute6 := p_attribute6;
        l_MODIFIER_LIST_rec.attribute7 := p_attribute7;
        l_MODIFIER_LIST_rec.attribute8 := p_attribute8;
        l_MODIFIER_LIST_rec.attribute9 := p_attribute9;
        l_MODIFIER_LIST_rec.context    := p_context;

    ELSE

OE_debug_Pub.add('else returned');
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

    IF FND_API.To_Boolean(l_MODIFIER_LIST_rec.db_flag) THEN
        l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

 oe_debug_pub.add('name in QPXF = ' || l_MODIFIER_LIST_rec.name);
 oe_debug_pub.add('curr in QPXF = ' || l_MODIFIER_LIST_rec.currency_code);

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

 oe_debug_pub.add('name after QPXF = ' || l_x_MODIFIER_LIST_rec.name);
 oe_debug_pub.add('curr after QPXF = ' || l_x_MODIFIER_LIST_rec.currency_code);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT parameters to missing.

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
    x_comments                     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_currency_code                := FND_API.G_MISS_CHAR;
    x_discount_lines_flag          := FND_API.G_MISS_CHAR;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_freight_terms_code           := FND_API.G_MISS_CHAR;
    x_gsa_indicator                := FND_API.G_MISS_CHAR;
    x_list_header_id               := FND_API.G_MISS_NUM;
    x_list_type_code               := FND_API.G_MISS_CHAR;
    x_prorate_flag                 := FND_API.G_MISS_CHAR;
    x_rounding_factor              := FND_API.G_MISS_NUM;
    x_ship_method_code             := FND_API.G_MISS_CHAR;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_terms_id                     := FND_API.G_MISS_NUM;
    x_source_system_code           := FND_API.G_MISS_CHAR;
    x_pte_code                     := FND_API.G_MISS_CHAR;
    x_active_flag                  := FND_API.G_MISS_CHAR;
    x_parent_list_header_id        := FND_API.G_MISS_NUM;
    x_start_date_active_first      := FND_API.G_MISS_DATE;
    x_end_date_active_first        := FND_API.G_MISS_DATE;
    x_active_date_first_type       := FND_API.G_MISS_CHAR;
    x_start_date_active_second     := FND_API.G_MISS_DATE;
    x_global_flag                  := FND_API.G_MISS_CHAR;
    x_end_date_active_second       := FND_API.G_MISS_DATE;
    x_active_date_second_type      := FND_API.G_MISS_CHAR;
    x_automatic                    := FND_API.G_MISS_CHAR;
    x_currency                     := FND_API.G_MISS_CHAR;
    x_discount_lines               := FND_API.G_MISS_CHAR;
    x_freight_terms                := FND_API.G_MISS_CHAR;
    x_list_header                  := FND_API.G_MISS_CHAR;
    x_list_type                    := FND_API.G_MISS_CHAR;
    x_prorate                      := FND_API.G_MISS_CHAR;
    x_ship_method                  := FND_API.G_MISS_CHAR;
    x_terms                        := FND_API.G_MISS_CHAR;
    x_ask_for_flag                 := FND_API.G_MISS_CHAR;
    x_name                         := FND_API.G_MISS_CHAR;
    x_description                  := FND_API.G_MISS_CHAR;
    x_version_no                   := FND_API.G_MISS_CHAR;
    x_list_source_code		   := FND_API.G_MISS_CHAR;
    x_orig_system_header_ref       := FND_API.G_MISS_CHAR;
    x_shareable_flag		   := FND_API.G_MISS_CHAR;
    --added for MOAC
    x_org_id		           := FND_API.G_MISS_NUM;

    --  Load display out parameters if any

    l_MODIFIER_LIST_val_rec := QP_Modifier_List_Util.Get_Values
    (   p_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   p_old_MODIFIER_LIST_rec       => l_MODIFIER_LIST_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute1,
                            l_MODIFIER_LIST_rec.attribute1)
    THEN
        x_attribute1 := l_x_MODIFIER_LIST_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute10,
                            l_MODIFIER_LIST_rec.attribute10)
    THEN
        x_attribute10 := l_x_MODIFIER_LIST_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute11,
                            l_MODIFIER_LIST_rec.attribute11)
    THEN
        x_attribute11 := l_x_MODIFIER_LIST_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute12,
                            l_MODIFIER_LIST_rec.attribute12)
    THEN
        x_attribute12 := l_x_MODIFIER_LIST_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute13,
                            l_MODIFIER_LIST_rec.attribute13)
    THEN
        x_attribute13 := l_x_MODIFIER_LIST_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute14,
                            l_MODIFIER_LIST_rec.attribute14)
    THEN
        x_attribute14 := l_x_MODIFIER_LIST_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute15,
                            l_MODIFIER_LIST_rec.attribute15)
    THEN
        x_attribute15 := l_x_MODIFIER_LIST_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute2,
                            l_MODIFIER_LIST_rec.attribute2)
    THEN
        x_attribute2 := l_x_MODIFIER_LIST_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute3,
                            l_MODIFIER_LIST_rec.attribute3)
    THEN
        x_attribute3 := l_x_MODIFIER_LIST_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute4,
                            l_MODIFIER_LIST_rec.attribute4)
    THEN
        x_attribute4 := l_x_MODIFIER_LIST_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute5,
                            l_MODIFIER_LIST_rec.attribute5)
    THEN
        x_attribute5 := l_x_MODIFIER_LIST_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute6,
                            l_MODIFIER_LIST_rec.attribute6)
    THEN
        x_attribute6 := l_x_MODIFIER_LIST_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute7,
                            l_MODIFIER_LIST_rec.attribute7)
    THEN
        x_attribute7 := l_x_MODIFIER_LIST_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute8,
                            l_MODIFIER_LIST_rec.attribute8)
    THEN
        x_attribute8 := l_x_MODIFIER_LIST_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.attribute9,
                            l_MODIFIER_LIST_rec.attribute9)
    THEN
        x_attribute9 := l_x_MODIFIER_LIST_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.automatic_flag,
                            l_MODIFIER_LIST_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_MODIFIER_LIST_rec.automatic_flag;
        x_automatic := l_MODIFIER_LIST_val_rec.automatic;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.comments,
                            l_MODIFIER_LIST_rec.comments)
    THEN
        x_comments := l_x_MODIFIER_LIST_rec.comments;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.context,
                            l_MODIFIER_LIST_rec.context)
    THEN
        x_context := l_x_MODIFIER_LIST_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.currency_code,
                            l_MODIFIER_LIST_rec.currency_code)
    THEN
        x_currency_code := l_x_MODIFIER_LIST_rec.currency_code;
        x_currency := l_MODIFIER_LIST_val_rec.currency;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.discount_lines_flag,
                            l_MODIFIER_LIST_rec.discount_lines_flag)
    THEN
        x_discount_lines_flag := l_x_MODIFIER_LIST_rec.discount_lines_flag;
        x_discount_lines := l_MODIFIER_LIST_val_rec.discount_lines;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.end_date_active,
                            l_MODIFIER_LIST_rec.end_date_active)
    THEN
        x_end_date_active := l_x_MODIFIER_LIST_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.freight_terms_code,
                            l_MODIFIER_LIST_rec.freight_terms_code)
    THEN
        x_freight_terms_code := l_x_MODIFIER_LIST_rec.freight_terms_code;
        x_freight_terms := l_MODIFIER_LIST_val_rec.freight_terms;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.gsa_indicator,
                            l_MODIFIER_LIST_rec.gsa_indicator)
    THEN
        x_gsa_indicator := l_x_MODIFIER_LIST_rec.gsa_indicator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.list_header_id,
                            l_MODIFIER_LIST_rec.list_header_id)
    THEN
        x_list_header_id := l_x_MODIFIER_LIST_rec.list_header_id;
        x_list_header := l_MODIFIER_LIST_val_rec.list_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.list_type_code,
                            l_MODIFIER_LIST_rec.list_type_code)
    THEN
        x_list_type_code := l_x_MODIFIER_LIST_rec.list_type_code;
        x_list_type := l_MODIFIER_LIST_val_rec.list_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.prorate_flag,
                            l_MODIFIER_LIST_rec.prorate_flag)
    THEN
        x_prorate_flag := l_x_MODIFIER_LIST_rec.prorate_flag;
        x_prorate := l_MODIFIER_LIST_val_rec.prorate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.rounding_factor,
                            l_MODIFIER_LIST_rec.rounding_factor)
    THEN
        x_rounding_factor := l_x_MODIFIER_LIST_rec.rounding_factor;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.ship_method_code,
                            l_MODIFIER_LIST_rec.ship_method_code)
    THEN
        x_ship_method_code := l_x_MODIFIER_LIST_rec.ship_method_code;
        x_ship_method := l_MODIFIER_LIST_val_rec.ship_method;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.start_date_active,
                            l_MODIFIER_LIST_rec.start_date_active)
    THEN
        x_start_date_active := l_x_MODIFIER_LIST_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.terms_id,
                            l_MODIFIER_LIST_rec.terms_id)
    THEN
        x_terms_id := l_x_MODIFIER_LIST_rec.terms_id;
        x_terms := l_MODIFIER_LIST_val_rec.terms;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.source_system_code,
                            l_MODIFIER_LIST_rec.source_system_code)
    THEN
        x_source_system_code := l_x_MODIFIER_LIST_rec.source_system_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.pte_code,
                            l_MODIFIER_LIST_rec.pte_code)
    THEN
        x_pte_code := l_x_MODIFIER_LIST_rec.pte_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.active_flag,
                            l_MODIFIER_LIST_rec.active_flag)
    THEN
        x_active_flag := l_x_MODIFIER_LIST_rec.active_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.parent_list_header_id,
                            l_MODIFIER_LIST_rec.parent_list_header_id)
    THEN
        x_parent_list_header_id := l_x_MODIFIER_LIST_rec.parent_list_header_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.start_date_active_first,
                            l_MODIFIER_LIST_rec.start_date_active_first)
    THEN
        x_start_date_active_first := l_x_MODIFIER_LIST_rec.start_date_active_first;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.end_date_active_first,
                            l_MODIFIER_LIST_rec.end_date_active_first)
    THEN
        x_end_date_active_first := l_x_MODIFIER_LIST_rec.end_date_active_first;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.active_date_first_type,
                            l_MODIFIER_LIST_rec.active_date_first_type)
    THEN
        x_active_date_first_type := l_x_MODIFIER_LIST_rec.active_date_first_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.start_date_active_second,
                            l_MODIFIER_LIST_rec.start_date_active_second)
    THEN
        x_start_date_active_second := l_x_MODIFIER_LIST_rec.start_date_active_second;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.global_flag,
                            l_MODIFIER_LIST_rec.global_flag)
    THEN
        x_global_flag := l_x_MODIFIER_LIST_rec.global_flag;
    END IF;


    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.end_date_active_second,
                            l_MODIFIER_LIST_rec.end_date_active_second)
    THEN
        x_end_date_active_second := l_x_MODIFIER_LIST_rec.end_date_active_second;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.active_date_second_type,
                            l_MODIFIER_LIST_rec.active_date_second_type)
    THEN
        x_active_date_second_type := l_x_MODIFIER_LIST_rec.active_date_second_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.ask_for_flag,
                            l_MODIFIER_LIST_rec.ask_for_flag)
    THEN
        x_ask_for_flag := l_x_MODIFIER_LIST_rec.ask_for_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.name,
                            l_MODIFIER_LIST_rec.name)
    THEN
        x_name := l_x_MODIFIER_LIST_rec.name;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.description,
                            l_MODIFIER_LIST_rec.description)
    THEN
        x_description := l_x_MODIFIER_LIST_rec.description;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_MODIFIER_LIST_rec.version_no,
                            l_MODIFIER_LIST_rec.version_no)
    THEN
        x_version_no := l_x_MODIFIER_LIST_rec.version_no;
    END IF;

    IF NOT QP_GLOBALS.Equal (l_x_MODIFIER_LIST_rec.list_source_code,
                             l_MODIFIER_LIST_rec.list_source_code)
    THEN
        x_list_source_code := l_x_MODIFIER_LIST_rec.list_source_code;
    END IF;

    IF NOT QP_GLOBALS.Equal (l_x_MODIFIER_LIST_rec.orig_system_header_ref,
                             l_MODIFIER_LIST_rec.orig_system_header_ref)
    THEN
        x_orig_system_header_ref := l_x_MODIFIER_LIST_rec.orig_system_header_ref;
    END IF;

    IF NOT QP_GLOBALS.Equal (l_x_MODIFIER_LIST_rec.shareable_flag,
                             l_MODIFIER_LIST_rec.shareable_flag)
    THEN
        x_shareable_flag := l_x_MODIFIER_LIST_rec.shareable_flag;
    END IF;

    --added for MOAC
    IF NOT QP_GLOBALS.Equal (l_x_MODIFIER_LIST_rec.org_id,
                             l_MODIFIER_LIST_rec.org_id)
    THEN
        x_org_id := l_x_MODIFIER_LIST_rec.org_id;
    END IF;

    --  Write to cache.

    Write_MODIFIER_LIST
    (   p_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('End change_attibutes in QPXFMLHB');

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

    oe_debug_pub.add('Exp change_attibutes in QPXFMLHB');
END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_old_MODIFIER_LIST_rec       QP_Modifiers_PUB.Modifier_List_Rec_Type;
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

    oe_debug_pub.add('BEGIN validate_and_write in QPXFMLHB');
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

    --  Read MODIFIER_LIST from cache

    l_old_MODIFIER_LIST_rec := Get_MODIFIER_LIST
    (   p_db_record                   => TRUE
    ,   p_list_header_id              => p_list_header_id
    );

    l_MODIFIER_LIST_rec := Get_MODIFIER_LIST
    (   p_db_record                   => FALSE
    ,   p_list_header_id              => p_list_header_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_MODIFIER_LIST_rec.db_flag) THEN
        l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   p_old_MODIFIER_LIST_rec       => l_old_MODIFIER_LIST_rec
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


    x_creation_date                := l_x_MODIFIER_LIST_rec.creation_date;
    x_created_by                   := l_x_MODIFIER_LIST_rec.created_by;
    x_last_update_date             := l_x_MODIFIER_LIST_rec.last_update_date;
    x_last_updated_by              := l_x_MODIFIER_LIST_rec.last_updated_by;
    x_last_update_login            := l_x_MODIFIER_LIST_rec.last_update_login;

    --  Clear MODIFIER_LIST record cache

    Clear_MODIFIER_LIST;

    --  Keep track of performed operations.

    l_old_MODIFIER_LIST_rec.operation := l_MODIFIER_LIST_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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
    oe_debug_pub.add('END validate_and_write in QPXFMLHB');

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
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

    oe_debug_pub.add('BEGIN delete_row in QPXFMLHB');
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

    l_MODIFIER_LIST_rec := Get_MODIFIER_LIST
    (   p_db_record                   => TRUE
    ,   p_list_header_id              => p_list_header_id
    );

    --  Set Operation.

    l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
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


    --  Clear MODIFIER_LIST record cache

    Clear_MODIFIER_LIST;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


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

    oe_debug_pub.add('END delete_row in QPXFMLHB');
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

    oe_debug_pub.add('BEGIN process_entity in QPXFMLHB');
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_MODIFIER_LIST;

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

    oe_debug_pub.add('END process_entity in QPXFMLHB');
END Process_Entity;

--  Procedure       Process_Object
--

PROCEDURE Process_Object
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

    oe_debug_pub.add('BEGIN process_object in QPXFMLHB');
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

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
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    oe_debug_pub.add('END process_object in QPXFMLHB');
END Process_Object;


PROCEDURE Create_GSA_Qualifier(p_list_header_id IN NUMBER,
	                          x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS
Begin
    x_return_status := null;

END Create_GSA_Qualifier;

PROCEDURE Create_GSA_Qual(p_list_header_id IN NUMBER,
					      p_list_line_id IN NUMBER,
                          	 p_qualifier_type IN VARCHAR2,
	                          x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
x_msg_count                   number;
x_msg_data                    Varchar2(2000);
x_msg_index                     number;

l_MODIFIER_LIST_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_MODIFIER_LIST_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_MODIFIERS_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_MODIFIERS_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_PRICING_ATTR_tbl              QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_PRICING_ATTR_val_tbl          QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

l_x_MODIFIER_LIST_rec             QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIER_LIST_val_rec         QP_Modifiers_PUB.Modifier_List_Val_Rec_Type;
l_x_MODIFIERS_tbl                 QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_MODIFIERS_val_tbl             QP_Modifiers_PUB.Modifiers_Val_Tbl_Type;
l_x_QUALIFIERS_tbl                QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_QUALIFIERS_val_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type
;
l_x_PRICING_ATTR_tbl              QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;


l_x_PRICING_ATTR_val_tbl          QP_Modifiers_PUB.Pricing_Attr_Val_Tbl_Type;

l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_qualifier_grouping_no       QP_QUALIFIERS.QUALIFIER_GROUPING_NO%TYPE;
l_error_code                  NUMBER := 0;

BEGIN

--behind the scene qualifier for gsa_pricing


    oe_debug_pub.add('BEGIN Create GSA_Qualifiers in QPXFMLHB');
/*
  IF p_list_line_id IS NULL
  THEN

   	l_MODIFIER_LIST_rec.list_header_id           := p_list_header_id;
	l_MODIFIER_LIST_rec.operation      		:= QP_GLOBALS.G_OPR_UPDATE;

  ELSE

   	l_MODIFIERS_rec.list_line_id           := p_list_line_id;
	l_MODIFIERS_rec.operation      		:= QP_GLOBALS.G_OPR_UPDATE;

  END IF;
  */

 	IF p_qualifier_type = 'GSA' THEN
    oe_debug_pub.add('IN IF Create GSA_Qualifiers in QPXFMLHB'||to_char(p_list_line_id));

	--create default qualifier for GSA Modifier List

	l_QUALIFIERS_tbl(1).qualifier_context		:= 'CUSTOMER';
	l_QUALIFIERS_tbl(1).qualifier_attribute		:= 'QUALIFIER_ATTRIBUTE15';
	l_QUALIFIERS_tbl(1).qualifier_attr_value	:= 'Y';
	l_QUALIFIERS_tbl(1).qualifier_attr_value_to	:= Null;
	l_QUALIFIERS_tbl(1).qualifier_grouping_no	:= -1;
--changed gsa precedence per nitin's decision to change precedence to 100
--gsa discounts were not getting selected with old precedence as
--item context's precedence< gsa qualifier precedence
--	l_QUALIFIERS_tbl(1).qualifier_precedence	:= 100;
--	l_QUALIFIERS_tbl(1).qualifier_precedence	:=
			QP_UTIL.Get_Qual_Flex_Properties(
					l_QUALIFIERS_tbl(1).Qualifier_Context,
					l_QUALIFIERS_tbl(1).Qualifier_Attribute,
					l_QUALIFIERS_tbl(1).Qualifier_Attr_Value,
					l_datatype,
					l_QUALIFIERS_tbl(1).Qualifier_precedence,
					l_error_code);
	l_QUALIFIERS_tbl(1).qualifier_datatype		:= 'C';
	l_QUALIFIERS_tbl(1).list_header_id			:= p_list_header_id;
	l_QUALIFIERS_tbl(1).list_line_id  			:= p_list_line_id;
	l_QUALIFIERS_tbl(1).operation                := QP_GLOBALS.G_OPR_CREATE;

	ELSIF p_qualifier_type = 'COUPON' THEN

    oe_debug_pub.add('IN IF Create COUP_Qualifiers in QPXFMLHB'||to_char(p_list_line_id));
	--create default qualifier for COUPON ISSUE Modifier's child line

	--for restricted qualifier will have grouping no as the max grouping no + 1
	--if the discount has null qual grp no the coupon line should have that
	--as an AND condition in its qualifiers

	select (nvl(max(qualifier_grouping_no),1)+1) into l_qualifier_grouping_no
			from qp_qualifiers where
			list_header_id = p_list_header_id and
			list_line_id = p_list_line_id;

	l_QUALIFIERS_tbl(1).qualifier_context		:= 'MODLIST';
	l_QUALIFIERS_tbl(1).qualifier_attribute		:= 'QUALIFIER_ATTRIBUTE10';
	l_QUALIFIERS_tbl(1).qualifier_attr_value	:= 'Y';
	l_QUALIFIERS_tbl(1).qualifier_attr_value_to	:= Null;
	l_QUALIFIERS_tbl(1).qualifier_grouping_no	:= l_qualifier_grouping_no;
--	l_QUALIFIERS_tbl(1).qualifier_precedence	:=
			QP_UTIL.Get_Qual_Flex_Properties(
					l_QUALIFIERS_tbl(1).Qualifier_Context,
					l_QUALIFIERS_tbl(1).Qualifier_Attribute,
					l_QUALIFIERS_tbl(1).Qualifier_Attr_Value,
					l_datatype,
					l_QUALIFIERS_tbl(1).Qualifier_precedence,
					l_error_code);
	l_QUALIFIERS_tbl(1).qualifier_datatype		:= 'C';
	l_QUALIFIERS_tbl(1).list_header_id			:= p_list_header_id;
	l_QUALIFIERS_tbl(1).list_line_id  			:= p_list_line_id;
	l_QUALIFIERS_tbl(1).operation                := QP_GLOBALS.G_OPR_CREATE;


	ELSE

		null;
	END IF;


    oe_debug_pub.add('BEFORE Process_Modifiers in QPXVMLSB');

/* dhgupta for bug 1975291.Private package needs to be called instead of Public package */

/*
     QP_Modifiers_PUB.Process_Modifiers
			( p_api_version_number   => 1.0
             	, p_init_msg_list        => FND_API.G_FALSE
	          , p_return_values        =>  FND_API.G_FALSE
             	, p_commit               => FND_API.G_FALSE
			, x_return_status        => x_return_status
			, x_msg_count            =>x_msg_count
			, x_msg_data             =>x_msg_data
--			,p_MODIFIER_LIST_rec     => l_MODIFIER_LIST_rec
--			,p_MODIFIERS_tbl         => l_MODIFIERS_tbl
--			,p_PRICING_ATTR_tbl      => l_PRICING_ATTR_tbl
			,p_QUALIFIERS_tbl      => l_QUALIFIERS_tbl
			,x_MODIFIER_LIST_rec     => l_MODIFIER_LIST_rec
			,x_MODIFIER_LIST_val_rec => l_MODIFIER_LIST_val_rec
			,x_MODIFIERS_tbl         => l_MODIFIERS_tbl
			,x_MODIFIERS_val_tbl     => l_MODIFIERS_val_tbl
			,x_QUALIFIERS_tbl        => l_QUALIFIERS_tbl
			,x_QUALIFIERS_val_tbl    => l_QUALIFIERS_val_tbl
			,x_PRICING_ATTR_tbl      => l_PRICING_ATTR_tbl
			,x_PRICING_ATTR_val_tbl  => l_PRICING_ATTR_val_tbl
			);

*/

     QP_Modifiers_PVT.Process_Modifiers
                        ( p_api_version_number   => 1.0
                        , p_init_msg_list        => FND_API.G_FALSE
                        , p_commit               => FND_API.G_FALSE
                        , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                        , p_control_rec          => l_control_rec
                        , x_return_status        => x_return_status
                        , x_msg_count            =>x_msg_count
                        , x_msg_data             =>x_msg_data
                        ,p_QUALIFIERS_tbl      => l_QUALIFIERS_tbl
                        ,x_MODIFIER_LIST_rec     => l_MODIFIER_LIST_rec
                        ,x_MODIFIERS_tbl         => l_MODIFIERS_tbl
                        ,x_QUALIFIERS_tbl        => l_x_QUALIFIERS_tbl
                        ,x_PRICING_ATTR_tbl      => l_PRICING_ATTR_tbl
                        );


    oe_debug_pub.add('END Create GSA_Qualifiers in QPXFMLHB');


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

		  x_return_status := FND_API.G_RET_STS_ERROR;

			FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
			OE_MSG_PUB.Add;

			--  Get message count and data

			OE_MSG_PUB.Count_And_Get
			(   		p_count  		=> x_msg_count
			,   p_data    	=> x_msg_data
			);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_QP_FORM_MODIFIER_LIST'
            );
        END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			FND_MESSAGE.SET_NAME('QP','QP_PE_QUALIFIERS');
			OE_MSG_PUB.Add;
			--  Get message count and data

			OE_MSG_PUB.Count_And_Get
			(   p_count                       => x_msg_count
			,   p_data                        => x_msg_data
			);

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_QP_FORM_MODIFIER_LIST'
            );
        END IF;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_QP_FORM_MODIFIER_LIST'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    oe_debug_pub.add('EXP Create GSA_Qualifiers in QPXFMLHB');


END Create_GSA_Qual;


--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_code                 IN  VARCHAR2
,   p_discount_lines_flag           IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_freight_terms_code            IN  VARCHAR2
,   p_gsa_indicator                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_header_id                IN  NUMBER
,   p_list_type_code                IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_prorate_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_rounding_factor               IN  NUMBER
,   p_ship_method_code              IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_terms_id                      IN  NUMBER
,   p_source_system_code            IN VARCHAR2
,   p_pte_code                      IN VARCHAR2
,   p_active_flag                   IN VARCHAR2
,   p_parent_list_header_id         IN NUMBER
,   p_start_date_active_first       IN  DATE
,   p_end_date_active_first         IN  DATE
,   p_active_date_first_type        IN VARCHAR2
,   p_start_date_active_second      IN  DATE
,   p_global_flag                   IN  VARCHAR2
,   p_end_date_active_second        IN  DATE
,   p_active_date_second_type       IN VARCHAR2
,   p_ask_for_flag                  IN VARCHAR2
,   p_list_source_code              IN VARCHAR2 := NULL
,   p_orig_system_header_ref        IN VARCHAR2 := NULL
,   p_shareable_flag                IN VARCHAR2 := NULL
--added for MOAC
,   p_org_id                        IN NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('BEGIN lock_row in QPXFMLHB');
    --  Load MODIFIER_LIST record

    l_MODIFIER_LIST_rec.attribute1 := p_attribute1;
    l_MODIFIER_LIST_rec.attribute10 := p_attribute10;
    l_MODIFIER_LIST_rec.attribute11 := p_attribute11;
    l_MODIFIER_LIST_rec.attribute12 := p_attribute12;
    l_MODIFIER_LIST_rec.attribute13 := p_attribute13;
    l_MODIFIER_LIST_rec.attribute14 := p_attribute14;
    l_MODIFIER_LIST_rec.attribute15 := p_attribute15;
    l_MODIFIER_LIST_rec.attribute2 := p_attribute2;
    l_MODIFIER_LIST_rec.attribute3 := p_attribute3;
    l_MODIFIER_LIST_rec.attribute4 := p_attribute4;
    l_MODIFIER_LIST_rec.attribute5 := p_attribute5;
    l_MODIFIER_LIST_rec.attribute6 := p_attribute6;
    l_MODIFIER_LIST_rec.attribute7 := p_attribute7;
    l_MODIFIER_LIST_rec.attribute8 := p_attribute8;
    l_MODIFIER_LIST_rec.attribute9 := p_attribute9;
    l_MODIFIER_LIST_rec.automatic_flag := p_automatic_flag;
    l_MODIFIER_LIST_rec.comments   := p_comments;
    l_MODIFIER_LIST_rec.context    := p_context;
    l_MODIFIER_LIST_rec.created_by := p_created_by;
    l_MODIFIER_LIST_rec.creation_date := p_creation_date;
    l_MODIFIER_LIST_rec.currency_code := p_currency_code;
    l_MODIFIER_LIST_rec.discount_lines_flag := p_discount_lines_flag;
    l_MODIFIER_LIST_rec.end_date_active := p_end_date_active;
    l_MODIFIER_LIST_rec.freight_terms_code := p_freight_terms_code;
    l_MODIFIER_LIST_rec.gsa_indicator := p_gsa_indicator;
    l_MODIFIER_LIST_rec.last_updated_by := p_last_updated_by;
    l_MODIFIER_LIST_rec.last_update_date := p_last_update_date;
    l_MODIFIER_LIST_rec.last_update_login := p_last_update_login;
    l_MODIFIER_LIST_rec.list_header_id := p_list_header_id;
    l_MODIFIER_LIST_rec.list_type_code := p_list_type_code;
    l_MODIFIER_LIST_rec.program_application_id := p_program_application_id;
    l_MODIFIER_LIST_rec.program_id := p_program_id;
    l_MODIFIER_LIST_rec.program_update_date := p_program_update_date;
    l_MODIFIER_LIST_rec.prorate_flag := p_prorate_flag;
    l_MODIFIER_LIST_rec.request_id := p_request_id;
    l_MODIFIER_LIST_rec.rounding_factor := p_rounding_factor;
    l_MODIFIER_LIST_rec.ship_method_code := p_ship_method_code;
    l_MODIFIER_LIST_rec.start_date_active := p_start_date_active;
    l_MODIFIER_LIST_rec.terms_id   := p_terms_id;
    l_MODIFIER_LIST_rec.source_system_code   := p_source_system_code;
    l_MODIFIER_LIST_rec.pte_code             := p_pte_code;
    l_MODIFIER_LIST_rec.active_flag   := p_active_flag;
    l_MODIFIER_LIST_rec.parent_list_header_id   := p_parent_list_header_id;
    l_MODIFIER_LIST_rec.start_date_active_first   := p_start_date_active_first;
    l_MODIFIER_LIST_rec.end_date_active_first   := p_end_date_active_first;
    l_MODIFIER_LIST_rec.active_date_first_type   := p_active_date_first_type;
    l_MODIFIER_LIST_rec.start_date_active_second   := p_start_date_active_second;
    l_MODIFIER_LIST_rec.global_flag   := p_global_flag;
    l_MODIFIER_LIST_rec.end_date_active_second   := p_end_date_active_second;
    l_MODIFIER_LIST_rec.active_date_second_type   := p_active_date_second_type;
    l_MODIFIER_LIST_rec.ask_for_flag   := p_ask_for_flag;
    l_MODIFIER_LIST_rec.list_source_code       := p_list_source_code ;
    l_MODIFIER_LIST_rec.orig_system_header_ref := p_orig_system_header_ref;
    l_MODIFIER_LIST_rec.shareable_flag         := p_shareable_flag ;
    --added for MOAC
    l_MODIFIER_LIST_rec.org_id         := p_org_id ;
    l_MODIFIER_LIST_rec.operation   := QP_GLOBALS.G_OPR_LOCK;

    --  Call QP_Modifiers_PVT.Lock_MODIFIERS

    QP_Modifiers_PVT.Lock_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_MODIFIER_LIST_rec.db_flag := FND_API.G_TRUE;

        Write_MODIFIER_LIST
        (   p_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
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


    oe_debug_pub.add('END lock_row in QPXFMLHB');

END Lock_Row;

--  Procedures maintaining MODIFIER_LIST record cache.

PROCEDURE Write_MODIFIER_LIST
(   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN
    oe_debug_pub.add('BEGIN write_modifier_list in QPXFMLHB');

    g_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    IF p_db_record THEN

        g_db_MODIFIER_LIST_rec := p_MODIFIER_LIST_rec;

    END IF;
    oe_debug_pub.add('END write_modifier_list in QPXFMLHB');

END Write_Modifier_List;

FUNCTION Get_MODIFIER_LIST
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_header_id                IN  NUMBER
)
RETURN QP_Modifiers_PUB.Modifier_List_Rec_Type
IS
BEGIN

    oe_debug_pub.add('BEGIN get_modifier_list in QPXFMLHB');
    IF  p_list_header_id <> g_MODIFIER_LIST_rec.list_header_id
    THEN

        --  Query row from DB

        g_MODIFIER_LIST_rec := QP_Modifier_List_Util.Query_Row
        (   p_list_header_id              => p_list_header_id
        );

        g_MODIFIER_LIST_rec.db_flag    := FND_API.G_TRUE;

        --  Load DB record

        g_db_MODIFIER_LIST_rec         := g_MODIFIER_LIST_rec;

    END IF;

    IF p_db_record THEN

    oe_debug_pub.add('if END get_modifier_list in QPXFMLHB');
        RETURN g_db_MODIFIER_LIST_rec;

    ELSE

    oe_debug_pub.add('else END get_modifier_list in QPXFMLHB');
        RETURN g_MODIFIER_LIST_rec;

    END IF;
    oe_debug_pub.add('END get_modifier_list in QPXFMLHB');

END Get_Modifier_List;

PROCEDURE Clear_Modifier_List
IS
BEGIN

    g_MODIFIER_LIST_rec            := QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC;
    g_db_MODIFIER_LIST_rec         := QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC;

END Clear_Modifier_List;


--added bu svdeshmu
-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_MODIFIER_LIST
					,p_entity_id    => p_list_header_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Modifier_List;

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


--end of additions by svdeshmu




END QP_QP_Form_Modifier_List;

/
