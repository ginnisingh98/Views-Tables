--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_PRICE_LIST" AS
/* $Header: QPXFPLHB.pls 120.2 2005/06/20 23:01:00 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Price_List';

--  Global variables holding cached record.

g_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
g_db_PRICE_LIST_rec           QP_Price_List_PUB.Price_List_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_PRICE_LIST
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_PRICE_LIST
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_header_id                IN  NUMBER
)
RETURN QP_Price_List_PUB.Price_List_Rec_Type;

PROCEDURE Clear_PRICE_LIST;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Price_List_PUB.Price_List_Tbl_Type;

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
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_mobile_download               OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- mkarya for bug 1944882
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Multi-Currency SunilPandey
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER   -- Multi-Currency SunilPandey
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Attribute Manager Giri
,   x_pte                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Attribute Manager Giri
,   x_list_source_code		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Blanket Sales Order
,   x_orig_system_header_ref	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Blanket Sales Order
,   x_global_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Pricing Security gtippire
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_locked_from_list_header_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_val_rec          QP_Price_List_PUB.Price_List_Val_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
--fname varchar2(80);
BEGIN

        --oe_debug_pub.debug_on;
       -- fname := oe_debug_pub.set_debug_mode('FILE');

        oe_debug_pub.add('entering default attributes');

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

    l_PRICE_LIST_rec.attribute1                   := NULL;
    l_PRICE_LIST_rec.attribute10                  := NULL;
    l_PRICE_LIST_rec.attribute11                  := NULL;
    l_PRICE_LIST_rec.attribute12                  := NULL;
    l_PRICE_LIST_rec.attribute13                  := NULL;
    l_PRICE_LIST_rec.attribute14                  := NULL;
    l_PRICE_LIST_rec.attribute15                  := NULL;
    l_PRICE_LIST_rec.attribute2                   := NULL;
    l_PRICE_LIST_rec.attribute3                   := NULL;
    l_PRICE_LIST_rec.attribute4                   := NULL;
    l_PRICE_LIST_rec.attribute5                   := NULL;
    l_PRICE_LIST_rec.attribute6                   := NULL;
    l_PRICE_LIST_rec.attribute7                   := NULL;
    l_PRICE_LIST_rec.attribute8                   := NULL;
    l_PRICE_LIST_rec.attribute9                   := NULL;
    l_PRICE_LIST_rec.context                      := NULL;

    --  Set Operation to Create

    l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    oe_debug_pub.add('return status after proc_price_list ' || l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    oe_debug_Pub.add('msg count 1 : ' || x_msg_count);
    oe_debug_Pub.add('msg data 1 : ' || x_msg_data);


    --  Load OUT parameters.

    x_attribute1                   := l_x_PRICE_LIST_rec.attribute1;
    x_attribute10                  := l_x_PRICE_LIST_rec.attribute10;
    x_attribute11                  := l_x_PRICE_LIST_rec.attribute11;
    x_attribute12                  := l_x_PRICE_LIST_rec.attribute12;
    x_attribute13                  := l_x_PRICE_LIST_rec.attribute13;
    x_attribute14                  := l_x_PRICE_LIST_rec.attribute14;
    x_attribute15                  := l_x_PRICE_LIST_rec.attribute15;
    x_attribute2                   := l_x_PRICE_LIST_rec.attribute2;
    x_attribute3                   := l_x_PRICE_LIST_rec.attribute3;
    x_attribute4                   := l_x_PRICE_LIST_rec.attribute4;
    x_attribute5                   := l_x_PRICE_LIST_rec.attribute5;
    x_attribute6                   := l_x_PRICE_LIST_rec.attribute6;
    x_attribute7                   := l_x_PRICE_LIST_rec.attribute7;
    x_attribute8                   := l_x_PRICE_LIST_rec.attribute8;
    x_attribute9                   := l_x_PRICE_LIST_rec.attribute9;
    x_automatic_flag               := l_x_PRICE_LIST_rec.automatic_flag;
    x_comments                     := l_x_PRICE_LIST_rec.comments;
    x_context                      := l_x_PRICE_LIST_rec.context;
    x_currency_code                := l_x_PRICE_LIST_rec.currency_code;
    x_discount_lines_flag          := l_x_PRICE_LIST_rec.discount_lines_flag;
    x_end_date_active              := l_x_PRICE_LIST_rec.end_date_active;
    x_freight_terms_code           := l_x_PRICE_LIST_rec.freight_terms_code;
    x_gsa_indicator                := l_x_PRICE_LIST_rec.gsa_indicator;
    x_list_header_id               := l_x_PRICE_LIST_rec.list_header_id;
    x_list_type_code               := l_x_PRICE_LIST_rec.list_type_code;
    x_prorate_flag                 := l_x_PRICE_LIST_rec.prorate_flag;
    x_rounding_factor              := l_x_PRICE_LIST_rec.rounding_factor;
    x_ship_method_code             := l_x_PRICE_LIST_rec.ship_method_code;
    x_start_date_active            := l_x_PRICE_LIST_rec.start_date_active;
    x_terms_id                     := l_x_PRICE_LIST_rec.terms_id;
    x_name                         := l_x_PRICE_LIST_rec.name;
    x_description                  := l_x_PRICE_LIST_rec.description;
    x_version_no                   := l_x_PRICE_LIST_rec.version_no;
    x_active_flag                  := l_x_PRICE_LIST_rec.active_flag;
    x_mobile_download              := l_x_PRICE_LIST_rec.mobile_download; -- mkarya for bug 1944882
    x_currency_header_id           := l_x_PRICE_LIST_rec.currency_header_id;-- Multi-Currency SunilPandey
    x_pte_code                     := l_x_PRICE_LIST_rec.pte_code;-- Attribute Manager Giri
    x_list_source_code		   := l_x_PRICE_LIST_rec.list_source_code;-- Blanket Sales Order
    x_orig_system_header_ref	   := l_x_PRICE_LIST_rec.orig_system_header_ref;-- Blanket Sales Order
    x_global_flag           	   := l_x_PRICE_LIST_rec.global_flag;-- Pricing Security gtippire
    x_source_system_code           := l_x_PRICE_LIST_rec.source_system_code;
    x_shareable_flag               := l_x_PRICE_LIST_rec.shareable_flag;
    x_sold_to_org_id               := l_x_PRICE_LIST_rec.sold_to_org_id;
    x_locked_from_list_header_id   :=
			l_x_PRICE_LIST_rec.locked_from_list_header_id;
    --added for MOAC
    x_org_id                       := l_x_PRICE_LIST_rec.org_id;

    --  Load display out parameters if any
    oe_debug_Pub.add('msg count 2 : ' || x_msg_count);
    oe_debug_Pub.add('msg data 2 : ' || x_msg_data);

    l_PRICE_LIST_val_rec := QP_Price_List_Util.Get_Values
    (   p_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    );
    x_automatic                    := l_PRICE_LIST_val_rec.automatic;
    x_currency                     := l_PRICE_LIST_val_rec.currency;
    x_discount_lines               := l_PRICE_LIST_val_rec.discount_lines;
    x_freight_terms                := l_PRICE_LIST_val_rec.freight_terms;
    x_list_header                  := l_PRICE_LIST_val_rec.list_header;
    x_list_type                    := l_PRICE_LIST_val_rec.list_type;
    x_prorate                      := l_PRICE_LIST_val_rec.prorate;
    x_ship_method                  := l_PRICE_LIST_val_rec.ship_method;
    x_terms                        := l_PRICE_LIST_val_rec.terms;
    x_pte                          := l_PRICE_LIST_val_rec.pte;
    --x_active_flag                :=l_PRICE_LIST_val_rec.active_flag;
    x_list_source_code		   := l_PRICE_LIST_val_rec.list_source_code;
    x_orig_system_header_ref       := l_PRICE_LIST_val_rec.orig_system_header_ref;
    --  Write to cache.
    --  Set db_flag to False before writing to cache
    oe_debug_Pub.add('msg data 3 : ' || x_msg_data);

    l_x_PRICE_LIST_rec.db_flag := FND_API.G_FALSE;

    Write_PRICE_LIST
    (   p_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );
    oe_debug_Pub.add('msg data 4 : ' || x_msg_data);

    oe_debug_pub.add('exiting default attributes');


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

	    oe_debug_pub.add('msg data 5 : ' || x_msg_data);

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
,   x_automatic                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_lines                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_type                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prorate                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_version_no                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_active_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_mobile_download               OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- mkarya for bug 1944882
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Multi-Currency SunilPandey
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER   -- Multi-Currency SunilPandey
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Attribute Manager Giri
,   x_pte                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Attribute Manager Giri
,   x_list_source_code		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Blanket Sales Order
,   x_orig_system_header_ref        OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Blanket Sales Order
,   x_global_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2 -- Pricing Security gtippire
,   x_source_system_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shareable_flag           	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sold_to_org_id	            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_locked_from_list_header_id    OUT NOCOPY /* file.sql.39 change */ NUMBER
--added for MOAC
,   x_org_id                        OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_old_PRICE_LIST_rec          QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_val_rec          QP_Price_List_PUB.Price_List_Val_Rec_Type;
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

    --  Read PRICE_LIST from cache

    l_PRICE_LIST_rec := Get_PRICE_LIST
    (   p_db_record                   => FALSE
    ,   p_list_header_id              => p_list_header_id
    );

    l_old_PRICE_LIST_rec           := l_PRICE_LIST_rec;

    IF p_attr_id = QP_Price_List_Util.G_AUTOMATIC THEN
        l_PRICE_LIST_rec.automatic_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_COMMENTS THEN
        l_PRICE_LIST_rec.comments := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_CURRENCY THEN
        l_PRICE_LIST_rec.currency_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_DISCOUNT_LINES THEN
        l_PRICE_LIST_rec.discount_lines_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_END_DATE_ACTIVE THEN
        l_PRICE_LIST_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Price_List_Util.G_FREIGHT_TERMS THEN
        l_PRICE_LIST_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_GSA_INDICATOR THEN
        l_PRICE_LIST_rec.gsa_indicator := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_NAME THEN
        l_PRICE_LIST_rec.name := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_DESCRIPTION THEN
        l_PRICE_LIST_rec.description := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_LIST_HEADER THEN
        l_PRICE_LIST_rec.list_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Util.G_LIST_TYPE THEN
        l_PRICE_LIST_rec.list_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_VERSION_NO THEN
        l_PRICE_LIST_rec.version_no := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_PRORATE THEN
        l_PRICE_LIST_rec.prorate_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_ROUNDING_FACTOR THEN
        l_PRICE_LIST_rec.rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Price_List_Util.G_SHIP_METHOD THEN
        l_PRICE_LIST_rec.ship_method_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_START_DATE_ACTIVE THEN
        l_PRICE_LIST_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Price_List_Util.G_TERMS THEN
        l_PRICE_LIST_rec.terms_id := TO_NUMBER(p_attr_value);
	   --added active_flag
	   ELSIF p_attr_id = QP_Price_List_Util.G_ACTIVE_FLAG THEN
	   l_PRICE_LIST_rec.active_flag := p_attr_value;
	   --mkarya for bug 1944882 - added mobile download
           ELSIF p_attr_id = QP_Price_List_Util.G_MOBILE_DOWNLOAD THEN
	   l_PRICE_LIST_rec.mobile_download := p_attr_value;
	   --Multi-Currency SunilPandey
           ELSIF p_attr_id = QP_Price_List_Util.G_CURRENCY_HEADER THEN
	   l_PRICE_LIST_rec.CURRENCY_HEADER_ID := TO_NUMBER(p_attr_value);
	   --Attribute Manager Giri
           ELSIF p_attr_id = QP_Price_List_Util.G_PTE THEN
	   l_PRICE_LIST_rec.PTE_CODE := p_attr_value; --Blanket Agreement
    ELSIF p_attr_id = QP_Price_List_Util.G_LIST_SOURCE THEN
        l_PRICE_LIST_rec.list_source_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.ORIG_SYSTEM_HEADER_REF THEN
        l_PRICE_LIST_rec.orig_system_header_ref:= p_attr_value;
    -- added global_flag for Pricing Security
    ELSIF p_attr_id = QP_Price_List_Util.G_GLOBAL_FLAG THEN
        l_PRICE_LIST_rec.global_flag:= p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_SOURCE_SYSTEM_CODE THEN
        l_PRICE_LIST_rec.source_system_code := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_SHAREABLE_FLAG THEN
        l_PRICE_LIST_rec.shareable_flag := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_SOLD_TO_ORG_ID THEN
	l_PRICE_LIST_rec.sold_to_org_id := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_LOCKED_FROM_LIST_HEADER THEN
	l_PRICE_LIST_rec.locked_from_list_header_id := TO_NUMBER(p_attr_value);
    --added for MOAC
    ELSIF p_attr_id = QP_Price_List_Util.G_ORG_ID THEN
        l_PRICE_LIST_rec.org_id := p_attr_value;
    ELSIF p_attr_id = QP_Price_List_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Price_List_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Price_List_Util.G_CONTEXT
    THEN

        l_PRICE_LIST_rec.attribute1    := p_attribute1;
        l_PRICE_LIST_rec.attribute10   := p_attribute10;
        l_PRICE_LIST_rec.attribute11   := p_attribute11;
        l_PRICE_LIST_rec.attribute12   := p_attribute12;
        l_PRICE_LIST_rec.attribute13   := p_attribute13;
        l_PRICE_LIST_rec.attribute14   := p_attribute14;
        l_PRICE_LIST_rec.attribute15   := p_attribute15;
        l_PRICE_LIST_rec.attribute2    := p_attribute2;
        l_PRICE_LIST_rec.attribute3    := p_attribute3;
        l_PRICE_LIST_rec.attribute4    := p_attribute4;
        l_PRICE_LIST_rec.attribute5    := p_attribute5;
        l_PRICE_LIST_rec.attribute6    := p_attribute6;
        l_PRICE_LIST_rec.attribute7    := p_attribute7;
        l_PRICE_LIST_rec.attribute8    := p_attribute8;
        l_PRICE_LIST_rec.attribute9    := p_attribute9;
        l_PRICE_LIST_rec.context       := p_context;

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

    IF FND_API.To_Boolean(l_PRICE_LIST_rec.db_flag) THEN
        l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
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
    x_automatic                    := FND_API.G_MISS_CHAR;
    x_currency                     := FND_API.G_MISS_CHAR;
    x_discount_lines               := FND_API.G_MISS_CHAR;
    x_freight_terms                := FND_API.G_MISS_CHAR;
    x_list_header                  := FND_API.G_MISS_CHAR;
    x_list_type                    := FND_API.G_MISS_CHAR;
    x_prorate                      := FND_API.G_MISS_CHAR;
    x_ship_method                  := FND_API.G_MISS_CHAR;
    x_terms                        := FND_API.G_MISS_CHAR;
    x_name                         := FND_API.G_MISS_CHAR;
    x_description                  := FND_API.G_MISS_CHAR;
    x_version_no                   := FND_API.G_MISS_CHAR;
    x_active_flag                  :=FND_API.G_MISS_CHAR;
    x_mobile_download              :=FND_API.G_MISS_CHAR; -- mkarya for bug 1944882
    x_currency_header              :=FND_API.G_MISS_CHAR; -- Multi-Currency SunilPandey
    x_currency_header_id           :=FND_API.G_MISS_NUM; -- Multi-Currency SunilPandey
    x_pte_code                     :=FND_API.G_MISS_CHAR; -- Attribute Manager Giri
    x_pte                          :=FND_API.G_MISS_CHAR; -- Attribute Manager Giri
    x_list_source_code		   :=FND_API.G_MISS_CHAR; -- Blanket Sales Order
    x_orig_system_header_ref	   :=FND_API.G_MISS_CHAR; -- Blanket Sales Order
    x_global_flag           	   :=FND_API.G_MISS_CHAR; -- Pricing Security gtippire
    x_source_system_code           := FND_API.G_MISS_CHAR;
    x_shareable_flag	           := FND_API.G_MISS_CHAR;
    x_sold_to_org_id               := FND_API.G_MISS_NUM;
    x_locked_from_list_header_id   := FND_API.G_MISS_NUM;
    --added for MOAC
    x_org_id	                   := FND_API.G_MISS_NUM;

    --  Load display out parameters if any

    l_PRICE_LIST_val_rec := QP_Price_List_Util.Get_Values
    (   p_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   p_old_PRICE_LIST_rec          => l_PRICE_LIST_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute1,
                            l_PRICE_LIST_rec.attribute1)
    THEN
        x_attribute1 := l_x_PRICE_LIST_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute10,
                            l_PRICE_LIST_rec.attribute10)
    THEN
        x_attribute10 := l_x_PRICE_LIST_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute11,
                            l_PRICE_LIST_rec.attribute11)
    THEN
        x_attribute11 := l_x_PRICE_LIST_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute12,
                            l_PRICE_LIST_rec.attribute12)
    THEN
        x_attribute12 := l_x_PRICE_LIST_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute13,
                            l_PRICE_LIST_rec.attribute13)
    THEN
        x_attribute13 := l_x_PRICE_LIST_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute14,
                            l_PRICE_LIST_rec.attribute14)
    THEN
        x_attribute14 := l_x_PRICE_LIST_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute15,
                            l_PRICE_LIST_rec.attribute15)
    THEN
        x_attribute15 := l_x_PRICE_LIST_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute2,
                            l_PRICE_LIST_rec.attribute2)
    THEN
        x_attribute2 := l_x_PRICE_LIST_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute3,
                            l_PRICE_LIST_rec.attribute3)
    THEN
        x_attribute3 := l_x_PRICE_LIST_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute4,
                            l_PRICE_LIST_rec.attribute4)
    THEN
        x_attribute4 := l_x_PRICE_LIST_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute5,
                            l_PRICE_LIST_rec.attribute5)
    THEN
        x_attribute5 := l_x_PRICE_LIST_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute6,
                            l_PRICE_LIST_rec.attribute6)
    THEN
        x_attribute6 := l_x_PRICE_LIST_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute7,
                            l_PRICE_LIST_rec.attribute7)
    THEN
        x_attribute7 := l_x_PRICE_LIST_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute8,
                            l_PRICE_LIST_rec.attribute8)
    THEN
        x_attribute8 := l_x_PRICE_LIST_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.attribute9,
                            l_PRICE_LIST_rec.attribute9)
    THEN
        x_attribute9 := l_x_PRICE_LIST_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.automatic_flag,
                            l_PRICE_LIST_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_PRICE_LIST_rec.automatic_flag;
        x_automatic := l_PRICE_LIST_val_rec.automatic;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.comments,
                            l_PRICE_LIST_rec.comments)
    THEN
        x_comments := l_x_PRICE_LIST_rec.comments;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.context,
                            l_PRICE_LIST_rec.context)
    THEN
        x_context := l_x_PRICE_LIST_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.currency_code,
                            l_PRICE_LIST_rec.currency_code)
    THEN
        x_currency_code := l_x_PRICE_LIST_rec.currency_code;
        x_currency := l_PRICE_LIST_val_rec.currency;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.discount_lines_flag,
                            l_PRICE_LIST_rec.discount_lines_flag)
    THEN
        x_discount_lines_flag := l_x_PRICE_LIST_rec.discount_lines_flag;
        x_discount_lines := l_PRICE_LIST_val_rec.discount_lines;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.end_date_active,
                            l_PRICE_LIST_rec.end_date_active)
    THEN
        x_end_date_active := l_x_PRICE_LIST_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.freight_terms_code,
                            l_PRICE_LIST_rec.freight_terms_code)
    THEN
        x_freight_terms_code := l_x_PRICE_LIST_rec.freight_terms_code;
        x_freight_terms := l_PRICE_LIST_val_rec.freight_terms;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.gsa_indicator,
                            l_PRICE_LIST_rec.gsa_indicator)
    THEN
        x_gsa_indicator := l_x_PRICE_LIST_rec.gsa_indicator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.list_header_id,
                            l_PRICE_LIST_rec.list_header_id)
    THEN
        x_list_header_id := l_x_PRICE_LIST_rec.list_header_id;
        x_list_header := l_PRICE_LIST_val_rec.list_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.list_type_code,
                            l_PRICE_LIST_rec.list_type_code)
    THEN
        x_list_type_code := l_x_PRICE_LIST_rec.list_type_code;
        x_list_type := l_PRICE_LIST_val_rec.list_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.version_no,
                            l_PRICE_LIST_rec.version_no)
    THEN
        x_version_no := l_x_PRICE_LIST_rec.version_no;
    END IF;
-- added active_flag
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.active_flag,
					   l_PRICE_LIST_rec.active_flag)
    THEN
	   x_active_flag := l_x_PRICE_LIST_rec.active_flag;
    END IF;
-- mkarya for bug 1944882 - added mobile_download
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.mobile_download,
					   l_PRICE_LIST_rec.mobile_download)
    THEN
	   x_mobile_download := l_x_PRICE_LIST_rec.mobile_download;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.prorate_flag,
                            l_PRICE_LIST_rec.prorate_flag)
    THEN
        x_prorate_flag := l_x_PRICE_LIST_rec.prorate_flag;
        x_prorate := l_PRICE_LIST_val_rec.prorate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.rounding_factor,
                            l_PRICE_LIST_rec.rounding_factor)
    THEN
        x_rounding_factor := l_x_PRICE_LIST_rec.rounding_factor;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.ship_method_code,
                            l_PRICE_LIST_rec.ship_method_code)
    THEN
        x_ship_method_code := l_x_PRICE_LIST_rec.ship_method_code;
        x_ship_method := l_PRICE_LIST_val_rec.ship_method;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.start_date_active,
                            l_PRICE_LIST_rec.start_date_active)
    THEN
        x_start_date_active := l_x_PRICE_LIST_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.terms_id,
                            l_PRICE_LIST_rec.terms_id)
    THEN
        x_terms_id := l_x_PRICE_LIST_rec.terms_id;
        x_terms := l_PRICE_LIST_val_rec.terms;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.name,
                            l_PRICE_LIST_rec.name)
    THEN
        x_name := l_x_PRICE_LIST_rec.name;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.description,
                            l_PRICE_LIST_rec.description)
    THEN
        x_description := l_x_PRICE_LIST_rec.description;
    END IF;

    -- Multi-Currency SunilPandey
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.currency_header_id,
                            l_PRICE_LIST_rec.currency_header_id)
    THEN
        x_currency_header_id := l_x_PRICE_LIST_rec.currency_header_id;
        x_currency_header := l_PRICE_LIST_val_rec.currency_header;
    END IF;

    -- Attribute Manager Giri
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.pte_code,
                            l_PRICE_LIST_rec.pte_code)
    THEN
        x_pte_code := l_x_PRICE_LIST_rec.pte_code;
        x_pte := l_PRICE_LIST_val_rec.pte;
    END IF;

   -- Blanket Sales Order
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.list_source_code,
                            l_PRICE_LIST_rec.list_source_code)
    THEN
        x_list_source_code := l_x_PRICE_LIST_rec.list_source_code;
        x_orig_system_header_ref := l_PRICE_LIST_val_rec.orig_system_header_ref;
    END IF;

   -- Pricing Security gtippire
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.global_flag,
                            l_PRICE_LIST_rec.global_flag)
    THEN
        x_global_flag := l_x_PRICE_LIST_rec.global_flag;
    END IF;

   -- Blanket Pricing
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.source_system_code,
                            l_PRICE_LIST_rec.source_system_code)
    THEN
        x_source_system_code := l_x_PRICE_LIST_rec.source_system_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.shareable_flag,
                            l_PRICE_LIST_rec.shareable_flag)
    THEN
        x_shareable_flag := l_x_PRICE_LIST_rec.shareable_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.sold_to_org_id,
                            l_PRICE_LIST_rec.sold_to_org_id)
    THEN
        x_sold_to_org_id := l_x_PRICE_LIST_rec.sold_to_org_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.locked_from_list_header_id,
                            l_PRICE_LIST_rec.locked_from_list_header_id)
    THEN
        x_locked_from_list_header_id :=
                     l_x_PRICE_LIST_rec.locked_from_list_header_id;
    END IF;

    --added for MOAC
    IF NOT QP_GLOBALS.Equal(l_x_PRICE_LIST_rec.org_id,
                            l_PRICE_LIST_rec.org_id)
    THEN
        x_org_id := l_x_PRICE_LIST_rec.org_id;
    END IF;

    --  Write to cache.

    Write_PRICE_LIST
    (   p_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    );

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
,   p_list_header_id                IN  NUMBER
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
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_old_PRICE_LIST_rec          QP_Price_List_PUB.Price_List_Rec_Type;
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

    --  Read PRICE_LIST from cache

    l_old_PRICE_LIST_rec := Get_PRICE_LIST
    (   p_db_record                   => TRUE
    ,   p_list_header_id              => p_list_header_id
    );

    l_PRICE_LIST_rec := Get_PRICE_LIST
    (   p_db_record                   => FALSE
    ,   p_list_header_id              => p_list_header_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICE_LIST_rec.db_flag) THEN
        l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   p_old_PRICE_LIST_rec          => l_old_PRICE_LIST_rec
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


    x_creation_date                := l_x_PRICE_LIST_rec.creation_date;
    x_created_by                   := l_x_PRICE_LIST_rec.created_by;
    x_last_update_date             := l_x_PRICE_LIST_rec.last_update_date;
    x_last_updated_by              := l_x_PRICE_LIST_rec.last_updated_by;
    x_last_update_login            := l_x_PRICE_LIST_rec.last_update_login;
    x_program_application_id       := l_x_PRICE_LIST_rec.program_application_id;
    x_program_id                   := l_x_PRICE_LIST_rec.program_id;
    x_program_update_date          := l_x_PRICE_LIST_rec.program_update_date;
    x_request_id                   := l_x_PRICE_LIST_rec.request_id;

    --  Clear PRICE_LIST record cache

    Clear_PRICE_LIST;

    --  Keep track of performed operations.

    l_old_PRICE_LIST_rec.operation := l_PRICE_LIST_rec.operation;


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
,   p_list_header_id                IN  NUMBER
)
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
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

    l_PRICE_LIST_rec := Get_PRICE_LIST
    (   p_db_record                   => TRUE
    ,   p_list_header_id              => p_list_header_id
    );

    --  Set Operation.

    l_PRICE_LIST_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
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


    --  Clear PRICE_LIST record cache

    Clear_PRICE_LIST;

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
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_PRICE_LIST;

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
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

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
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

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
,   p_name                          IN  VARCHAR2
,   p_description                   IN  VARCHAR2
,   p_version_no                    IN  VARCHAR2
,   p_active_flag                   IN VARCHAR2
,   p_mobile_download               IN VARCHAR2 -- mkarya for bug 1944882
,   p_currency_header_id            IN NUMBER   -- Multi-Currency SunilPandey
,   p_pte_code                      IN VARCHAR2  := NULL -- Attribute Manager Giri
,   p_list_source_code		    IN VARCHAR2 := NULL--FND_API.G_MISS_CHAR--NULL  -- Blanket Sales Order
,   p_orig_system_header_ref        IN VARCHAR2 := NULL--FND_API.G_MISS_CHAR--NULL  -- Blanket Sales Order
,   p_global_flag                   IN VARCHAR2  -- Pricing Security gtippire
,   p_source_system_code            IN VARCHAR2
,   p_shareable_flag                IN VARCHAR2 :=  NULL
,   p_sold_to_org_id                IN NUMBER   :=  NULL
,   p_locked_from_list_header_id    IN NUMBER   :=  NULL
--added for MOAC
,   p_org_id                        IN NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    --  Load PRICE_LIST record
    oe_debug_pub.add('Lock_Row in QPXFPLHB, next call to QPXVPRLB::Lock_PRICE_LIST');

 if(p_list_source_code IS NULL) then
oe_debug_pub.add('list_source_code is ' || p_list_source_code);
    oe_debug_pub.add('orig_system_header_Ref is ' || p_orig_system_header_ref);
end if;
    l_PRICE_LIST_rec.attribute1    := p_attribute1;
    l_PRICE_LIST_rec.attribute10   := p_attribute10;
    l_PRICE_LIST_rec.attribute11   := p_attribute11;
    l_PRICE_LIST_rec.attribute12   := p_attribute12;
    l_PRICE_LIST_rec.attribute13   := p_attribute13;
    l_PRICE_LIST_rec.attribute14   := p_attribute14;
    l_PRICE_LIST_rec.attribute15   := p_attribute15;
    l_PRICE_LIST_rec.attribute2    := p_attribute2;
    l_PRICE_LIST_rec.attribute3    := p_attribute3;
    l_PRICE_LIST_rec.attribute4    := p_attribute4;
    l_PRICE_LIST_rec.attribute5    := p_attribute5;
    l_PRICE_LIST_rec.attribute6    := p_attribute6;
    l_PRICE_LIST_rec.attribute7    := p_attribute7;
    l_PRICE_LIST_rec.attribute8    := p_attribute8;
    l_PRICE_LIST_rec.attribute9    := p_attribute9;
    l_PRICE_LIST_rec.automatic_flag := p_automatic_flag;
    l_PRICE_LIST_rec.comments      := p_comments;
    l_PRICE_LIST_rec.context       := p_context;
    l_PRICE_LIST_rec.created_by    := p_created_by;
    l_PRICE_LIST_rec.creation_date := p_creation_date;
    l_PRICE_LIST_rec.currency_code := p_currency_code;
    l_PRICE_LIST_rec.discount_lines_flag := p_discount_lines_flag;
    l_PRICE_LIST_rec.end_date_active := p_end_date_active;
    l_PRICE_LIST_rec.freight_terms_code := p_freight_terms_code;
    l_PRICE_LIST_rec.gsa_indicator := p_gsa_indicator;
    l_PRICE_LIST_rec.last_updated_by := p_last_updated_by;
    l_PRICE_LIST_rec.last_update_date := p_last_update_date;
    l_PRICE_LIST_rec.last_update_login := p_last_update_login;
    l_PRICE_LIST_rec.list_header_id := p_list_header_id;
    l_PRICE_LIST_rec.list_type_code := p_list_type_code;
    l_PRICE_LIST_rec.program_application_id := p_program_application_id;
    l_PRICE_LIST_rec.program_id    := p_program_id;
    l_PRICE_LIST_rec.program_update_date := p_program_update_date;
    l_PRICE_LIST_rec.prorate_flag  := p_prorate_flag;
    l_PRICE_LIST_rec.request_id    := p_request_id;
    l_PRICE_LIST_rec.rounding_factor := p_rounding_factor;
    l_PRICE_LIST_rec.ship_method_code := p_ship_method_code;
    l_PRICE_LIST_rec.start_date_active := p_start_date_active;
    l_PRICE_LIST_rec.terms_id      := p_terms_id;
    l_PRICE_LIST_rec.name          := p_name;
    l_PRICE_LIST_rec.description      := p_description;
    l_PRICE_LIST_rec.version_no      := p_version_no;
    l_PRICE_LIST_rec.active_flag     := p_active_flag;
    l_PRICE_LIST_rec.mobile_download     := p_mobile_download; -- mkarya for bug 1944882
    l_PRICE_LIST_rec.currency_header_id  := p_currency_header_id; -- Multi-Currency SunilPandey
    l_PRICE_LIST_rec.pte_code      := p_pte_code; -- Attribute Manager Giri
    l_PRICE_LIST_rec.operation        := QP_GLOBALS.G_OPR_LOCK;
    l_PRICE_LIST_rec.list_source_code := p_list_source_code ; --Blanket Sales Order
    l_PRICE_LIST_rec.orig_system_header_ref := p_orig_system_header_ref ; --Blanket Sales Order
    l_PRICE_LIST_rec.global_flag := p_global_flag ; --Pricing Security gtippire
    l_PRICE_LIST_rec.source_system_code := p_source_system_code;
    l_PRICE_LIST_rec.shareable_flag := p_shareable_flag;
    l_PRICE_LIST_rec.sold_to_org_id := p_sold_to_org_id;
    l_PRICE_LIST_rec.locked_from_list_header_id := p_locked_from_list_header_id;
    --added for MOAC
    l_PRICE_LIST_rec.org_id := p_org_id;


    --  Call QP_LIST_HEADERS_PVT.Lock_PRICE_LIST

    QP_LIST_HEADERS_PVT.Lock_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_PRICE_LIST_rec.db_flag := FND_API.G_TRUE;

        Write_PRICE_LIST
        (   p_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
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

--  Procedures maintaining PRICE_LIST record cache.

PROCEDURE Write_PRICE_LIST
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_PRICE_LIST_rec := p_PRICE_LIST_rec;

    IF p_db_record THEN

        g_db_PRICE_LIST_rec := p_PRICE_LIST_rec;

    END IF;

END Write_Price_List;

FUNCTION Get_PRICE_LIST
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_list_header_id                IN  NUMBER
)
RETURN QP_Price_List_PUB.Price_List_Rec_Type
IS
BEGIN

    IF  p_list_header_id <> g_PRICE_LIST_rec.list_header_id
    THEN

        --  Query row from DB

        g_PRICE_LIST_rec := QP_Price_List_Util.Query_Row
        (   p_list_header_id              => p_list_header_id
        );

        g_PRICE_LIST_rec.db_flag       := FND_API.G_TRUE;

        --  Load DB record

        g_db_PRICE_LIST_rec            := g_PRICE_LIST_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_PRICE_LIST_rec;

    ELSE

        RETURN g_PRICE_LIST_rec;

    END IF;

END Get_Price_List;

PROCEDURE Clear_Price_List
IS
BEGIN

    g_PRICE_LIST_rec               := QP_Price_List_PUB.G_MISS_PRICE_LIST_REC;
    g_db_PRICE_LIST_rec            := QP_Price_List_PUB.G_MISS_PRICE_LIST_REC;

END Clear_Price_List;

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                  IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_PRICE_LIST
					,p_entity_id    => p_list_header_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Price_List;

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


END QP_QP_Form_Price_List;

/
