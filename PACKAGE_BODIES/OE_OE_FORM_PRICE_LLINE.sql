--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_PRICE_LLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_PRICE_LLINE" AS
/* $Header: OEXFPLLB.pls 120.1 2005/06/09 00:25:16 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Price_Lline';

--  Global variables holding cached record.

g_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
g_db_Price_LLine_rec          OE_Price_List_PUB.Price_List_Line_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Price_LLine
(   p_Price_LLine_rec               IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_Price_LLine
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_line_id            IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

PROCEDURE Clear_Price_LLine;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Price_List_PUB.Price_List_Line_Tbl_Type;

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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_method_code                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute10           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute11           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute12           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute13           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute14           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute15           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute5            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute6            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute7            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute8            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute9            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_context               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_creation_date		    OUT NOCOPY /* file.sql.39 change */ DATE  /* Parameter added Geresh */
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_val_rec         OE_Price_List_PUB.Price_List_Line_Val_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Price_Lline.Default_Attributes');

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

    l_Price_LLine_rec.attribute1                  := 'NULL';
    l_Price_LLine_rec.attribute10                 := 'NULL';
    l_Price_LLine_rec.attribute11                 := 'NULL';
    l_Price_LLine_rec.attribute12                 := 'NULL';
    l_Price_LLine_rec.attribute13                 := 'NULL';
    l_Price_LLine_rec.attribute14                 := 'NULL';
    l_Price_LLine_rec.attribute15                 := 'NULL';
    l_Price_LLine_rec.attribute2                  := 'NULL';
    l_Price_LLine_rec.attribute3                  := 'NULL';
    l_Price_LLine_rec.attribute4                  := 'NULL';
    l_Price_LLine_rec.attribute5                  := 'NULL';
    l_Price_LLine_rec.attribute6                  := 'NULL';
    l_Price_LLine_rec.attribute7                  := 'NULL';
    l_Price_LLine_rec.attribute8                  := 'NULL';
    l_Price_LLine_rec.attribute9                  := 'NULL';
    l_Price_LLine_rec.context                     := 'NULL';

    --  Set Operation to Create

    l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Price_LLine table

    l_Price_LLine_tbl(1) := l_Price_LLine_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    oe_debug_pub.add('before process_pricing_cont in list lines ');

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   oe_debug_pub.add('after calling process_pricing_cont for lines ');


    --  Unload out tbl

    l_x_Price_LLine_rec := l_x_Price_LLine_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_Price_LLine_rec.attribute1;
    x_attribute10                  := l_x_Price_LLine_rec.attribute10;
    x_attribute11                  := l_x_Price_LLine_rec.attribute11;
    x_attribute12                  := l_x_Price_LLine_rec.attribute12;
    x_attribute13                  := l_x_Price_LLine_rec.attribute13;
    x_attribute14                  := l_x_Price_LLine_rec.attribute14;
    x_attribute15                  := l_x_Price_LLine_rec.attribute15;
    x_attribute2                   := l_x_Price_LLine_rec.attribute2;
    x_attribute3                   := l_x_Price_LLine_rec.attribute3;
    x_attribute4                   := l_x_Price_LLine_rec.attribute4;
    x_attribute5                   := l_x_Price_LLine_rec.attribute5;
    x_attribute6                   := l_x_Price_LLine_rec.attribute6;
    x_attribute7                   := l_x_Price_LLine_rec.attribute7;
    x_attribute8                   := l_x_Price_LLine_rec.attribute8;
    x_attribute9                   := l_x_Price_LLine_rec.attribute9;
    x_comments                     := l_x_Price_LLine_rec.comments;
    x_context                      := l_x_Price_LLine_rec.context;
    x_customer_item_id             := l_x_Price_LLine_rec.customer_item_id;
    x_end_date_active              := l_x_Price_LLine_rec.end_date_active;
    x_inventory_item_id            := l_x_Price_LLine_rec.inventory_item_id;
    x_list_price                   := l_x_Price_LLine_rec.list_price;
    x_method_code                  := l_x_Price_LLine_rec.method_code;
    x_price_list_id                := l_x_Price_LLine_rec.price_list_id;
    x_price_list_line_id           := l_x_Price_LLine_rec.price_list_line_id;
    x_pricing_attribute1           := l_x_Price_LLine_rec.pricing_attribute1;
    x_pricing_attribute10          := l_x_Price_LLine_rec.pricing_attribute10;
    x_pricing_attribute11          := l_x_Price_LLine_rec.pricing_attribute11;
    x_pricing_attribute12          := l_x_Price_LLine_rec.pricing_attribute12;
    x_pricing_attribute13          := l_x_Price_LLine_rec.pricing_attribute13;
    x_pricing_attribute14          := l_x_Price_LLine_rec.pricing_attribute14;
    x_pricing_attribute15          := l_x_Price_LLine_rec.pricing_attribute15;
    x_pricing_attribute2           := l_x_Price_LLine_rec.pricing_attribute2;
    x_pricing_attribute3           := l_x_Price_LLine_rec.pricing_attribute3;
    x_pricing_attribute4           := l_x_Price_LLine_rec.pricing_attribute4;
    x_pricing_attribute5           := l_x_Price_LLine_rec.pricing_attribute5;
    x_pricing_attribute6           := l_x_Price_LLine_rec.pricing_attribute6;
    x_pricing_attribute7           := l_x_Price_LLine_rec.pricing_attribute7;
    x_pricing_attribute8           := l_x_Price_LLine_rec.pricing_attribute8;
    x_pricing_attribute9           := l_x_Price_LLine_rec.pricing_attribute9;
    x_pricing_context              := l_x_Price_LLine_rec.pricing_context;
    x_pricing_rule_id              := l_x_Price_LLine_rec.pricing_rule_id;
    x_reprice_flag                 := l_x_Price_LLine_rec.reprice_flag;
    x_revision                     := l_x_Price_LLine_rec.revision;
    x_revision_date                := l_x_Price_LLine_rec.revision_date;
    x_revision_reason_code         := l_x_Price_LLine_rec.revision_reason_code;
    x_start_date_active            := l_x_Price_LLine_rec.start_date_active;
    x_unit_code                    := l_x_Price_LLine_rec.unit_code;
    x_primary                      := l_x_Price_LLine_rec.primary;
    x_list_line_type_code          := l_x_Price_LLine_rec.list_line_type_code;

-- Added By Geresh
   x_creation_date                := l_x_Price_LLine_rec.creation_date;

   oe_debug_pub.add('get display values');

    --  Load display out parameters if any

    l_Price_LLine_val_rec := OE_Price_List_Line_Util.Get_Values
    (   p_Price_List_Line_rec             => l_x_Price_LLine_rec
    );
    x_customer_item                := l_Price_LLine_val_rec.customer_item;
    x_inventory_item               := l_Price_LLine_val_rec.inventory_item;
    x_method                       := l_Price_LLine_val_rec.method;
    x_price_list                   := l_Price_LLine_val_rec.price_list;
    x_price_list_line              := l_Price_LLine_val_rec.price_list_line;
    x_pricing_rule                 := l_Price_LLine_val_rec.pricing_rule;
    x_reprice                      := l_Price_LLine_val_rec.reprice;
    x_revision_reason              := l_Price_LLine_val_rec.revision_reason;
    x_unit                         := l_Price_LLine_val_rec.unit;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Price_LLine_rec.db_flag := FND_API.G_FALSE;

    oe_debug_pub.add('after display values');

    Write_Price_LLine
    (   p_Price_LLine_rec             => l_x_Price_LLine_rec
    );

    oe_debug_pub.add('after writing to cache ');

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Price_Lline.Default_Attributes');

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
,   p_price_list_line_id            IN  NUMBER
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_inventory_item_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_price                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_method_code                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute10           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute11           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute12           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute13           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute14           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute15           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute5            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute6            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute7            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute8            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute9            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_context               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule_id               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_reprice_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_revision_reason_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_customer_item                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_rule                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reprice                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_revision_reason               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_primary                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_list_line_type_code           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_Price_LLine_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_val_rec         OE_Price_List_PUB.Price_List_Line_Val_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_Price_LLine_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Price_Lline.Change_Attribute');

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

    --  Read Price_LLine from cache

    oe_debug_pub.add('price list line id to query is : ' || to_char(p_price_list_line_id));


    l_Price_LLine_rec := Get_Price_LLine
    (   p_db_record                   => FALSE
    ,   p_price_list_line_id          => p_price_list_line_id
    );

       oe_debug_pub.add('price list line id after query 1 is : ' || to_char(p_price_list_line_id));




    l_old_Price_LLine_rec          := l_Price_LLine_rec;

       oe_debug_pub.add('price list line id before **** is : ');
    IF p_attr_id = OE_Price_List_Line_Util.G_COMMENTS THEN
       oe_debug_pub.add('price list line id 1111 is : ');
	l_Price_LLine_rec.comments := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_CUSTOMER_ITEM THEN
       oe_debug_pub.add('price list line id 2222 is : ');
        l_Price_LLine_rec.customer_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_END_DATE_ACTIVE THEN
       oe_debug_pub.add('price list line id 3333 is : ');
        l_Price_LLine_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_INVENTORY_ITEM THEN
       oe_debug_pub.add('price list line id 4444 is : ');
        l_Price_LLine_rec.inventory_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_LIST_PRICE THEN
       oe_debug_pub.add('price list line id 5555 is : ');
        l_Price_LLine_rec.list_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_METHOD THEN
       oe_debug_pub.add('price list line id 6666 is : ');
        l_Price_LLine_rec.method_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICE_LIST THEN
       oe_debug_pub.add('price list line id 7777 is : ');
        l_Price_LLine_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICE_LIST_LINE THEN
       oe_debug_pub.add('price list line id 8888 is : ');
        l_Price_LLine_rec.price_list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE1 THEN
       oe_debug_pub.add('price list line id 9999 is : ');
        l_Price_LLine_rec.pricing_attribute1 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE10 THEN
       oe_debug_pub.add('price list line id 1010 is : ');
        l_Price_LLine_rec.pricing_attribute10 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE11 THEN
       oe_debug_pub.add('price list line id 1212 is : ');
        l_Price_LLine_rec.pricing_attribute11 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE12 THEN
       oe_debug_pub.add('price list line id 1313 is : ');
        l_Price_LLine_rec.pricing_attribute12 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE13 THEN
       oe_debug_pub.add('price list line id 1414 is : ');
        l_Price_LLine_rec.pricing_attribute13 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE14 THEN
       oe_debug_pub.add('price list line id 1515 is : ');
        l_Price_LLine_rec.pricing_attribute14 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE15 THEN
       oe_debug_pub.add('price list line id 1616 is : ');
        l_Price_LLine_rec.pricing_attribute15 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE2 THEN
       oe_debug_pub.add('price list line id 1818 is : ');
        l_Price_LLine_rec.pricing_attribute2 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE3 THEN
       oe_debug_pub.add('price list line id 1919 is : ');
        l_Price_LLine_rec.pricing_attribute3 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE4 THEN
       oe_debug_pub.add('price list line id 2020 is : ');
        l_Price_LLine_rec.pricing_attribute4 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE5 THEN
       oe_debug_pub.add('price list line id 2121 is : ');
        l_Price_LLine_rec.pricing_attribute5 := p_attr_value;

    ELSIF p_attr_id = OE_Price_List_line_Util.G_CREATION_DATE THEN
       oe_debug_pub.add('price list line id 2323 is : ');
        l_Price_LLine_rec.creation_date := TO_DATE(p_attr_value,'DD/MM/YYYY');

    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE6 THEN
       oe_debug_pub.add('price list line id 2424 is : ');
        l_Price_LLine_rec.pricing_attribute6 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE7 THEN
       oe_debug_pub.add('price list line id 2525 is : ');
        l_Price_LLine_rec.pricing_attribute7 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE8 THEN
       oe_debug_pub.add('price list line id 2626 is : ');
        l_Price_LLine_rec.pricing_attribute8 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_ATTRIBUTE9 THEN
       oe_debug_pub.add('price list line id 2727 is : ');
        l_Price_LLine_rec.pricing_attribute9 := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_CONTEXT THEN
       oe_debug_pub.add('price list line id 2828 is : ');
        l_Price_LLine_rec.pricing_context := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRICING_RULE THEN
       oe_debug_pub.add('price list line id 2929 is : ');
        l_Price_LLine_rec.pricing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_REPRICE THEN
       oe_debug_pub.add('price list line id 3030 is : ');
        l_Price_LLine_rec.reprice_flag := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_REVISION THEN
       oe_debug_pub.add('price list line id 3131 is : ');
        l_Price_LLine_rec.revision := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_REVISION_DATE THEN
       oe_debug_pub.add('price list line id 3232 is : ');
        l_Price_LLine_rec.revision_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_REVISION_REASON THEN
       oe_debug_pub.add('price list line id 3434 is : ');
        l_Price_LLine_rec.revision_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_START_DATE_ACTIVE THEN
       oe_debug_pub.add('price list line id 3535 is : ');
        l_Price_LLine_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_UNIT THEN
       oe_debug_pub.add('price list line id 3636 is : ');
        l_Price_LLine_rec.unit_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_PRIMARY THEN
       oe_debug_pub.add('price list line id 3737 is : ');
        l_Price_Lline_rec.primary := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Line_Util.G_LIST_LINE_TYPE_CODE THEN
       oe_debug_pub.add('price list line id 3737 is : ');
        l_Price_Lline_rec.list_line_type_code := p_attr_value;

    ELSIF p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Price_List_Line_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Price_List_Line_Util.G_CONTEXT
    THEN

        l_Price_LLine_rec.attribute1   := p_attribute1;
        l_Price_LLine_rec.attribute10  := p_attribute10;
        l_Price_LLine_rec.attribute11  := p_attribute11;
        l_Price_LLine_rec.attribute12  := p_attribute12;
        l_Price_LLine_rec.attribute13  := p_attribute13;
        l_Price_LLine_rec.attribute14  := p_attribute14;
        l_Price_LLine_rec.attribute15  := p_attribute15;
        l_Price_LLine_rec.attribute2   := p_attribute2;
        l_Price_LLine_rec.attribute3   := p_attribute3;
        l_Price_LLine_rec.attribute4   := p_attribute4;
        l_Price_LLine_rec.attribute5   := p_attribute5;
        l_Price_LLine_rec.attribute6   := p_attribute6;
        l_Price_LLine_rec.attribute7   := p_attribute7;
        l_Price_LLine_rec.attribute8   := p_attribute8;
        l_Price_LLine_rec.attribute9   := p_attribute9;
        l_Price_LLine_rec.context      := p_context;
       oe_debug_pub.add('price list line id 4444 is : ');

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


    IF (l_Price_LLine_rec.db_flag = FND_API.G_MISS_CHAR ) THEN

        l_Price_LLine_rec.db_flag := NULL;

    END IF;
       oe_debug_pub.add('price list line id 5555 is : ');

    IF FND_API.To_Boolean(l_Price_LLine_rec.db_flag) THEN
        l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Price_LLine table

       oe_debug_pub.add('price list line id 6666 is : ');
    l_Price_LLine_tbl(1) := l_Price_LLine_rec;
    l_old_Price_LLine_tbl(1) := l_old_Price_LLine_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

       oe_debug_pub.add('price list line id 7777 is : ');
    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   p_old_Price_LLine_tbl         => l_old_Price_LLine_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_Price_LLine_rec := l_x_Price_LLine_tbl(1);


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
    x_comments                     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_customer_item_id             := FND_API.G_MISS_NUM;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_inventory_item_id            := FND_API.G_MISS_NUM;
    x_list_price                   := FND_API.G_MISS_NUM;
    x_method_code                  := FND_API.G_MISS_CHAR;
    x_price_list_id                := FND_API.G_MISS_NUM;
    x_price_list_line_id           := FND_API.G_MISS_NUM;
    x_pricing_attribute1           := FND_API.G_MISS_CHAR;
    x_pricing_attribute10          := FND_API.G_MISS_CHAR;
    x_pricing_attribute11          := FND_API.G_MISS_CHAR;
    x_pricing_attribute12          := FND_API.G_MISS_CHAR;
    x_pricing_attribute13          := FND_API.G_MISS_CHAR;
    x_pricing_attribute14          := FND_API.G_MISS_CHAR;
    x_pricing_attribute15          := FND_API.G_MISS_CHAR;
    x_pricing_attribute2           := FND_API.G_MISS_CHAR;
    x_pricing_attribute3           := FND_API.G_MISS_CHAR;
    x_pricing_attribute4           := FND_API.G_MISS_CHAR;
    x_pricing_attribute5           := FND_API.G_MISS_CHAR;
    x_pricing_attribute6           := FND_API.G_MISS_CHAR;
    x_pricing_attribute7           := FND_API.G_MISS_CHAR;
    x_pricing_attribute8           := FND_API.G_MISS_CHAR;
    x_pricing_attribute9           := FND_API.G_MISS_CHAR;
    x_pricing_context              := FND_API.G_MISS_CHAR;
    x_pricing_rule_id              := FND_API.G_MISS_NUM;
    x_reprice_flag                 := FND_API.G_MISS_CHAR;
    x_revision                     := FND_API.G_MISS_CHAR;
    x_revision_date                := FND_API.G_MISS_DATE;
    x_revision_reason_code         := FND_API.G_MISS_CHAR;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_unit_code                    := FND_API.G_MISS_CHAR;
    x_customer_item                := FND_API.G_MISS_CHAR;
    x_inventory_item               := FND_API.G_MISS_CHAR;
    x_method                       := FND_API.G_MISS_CHAR;
    x_price_list                   := FND_API.G_MISS_CHAR;
    x_price_list_line              := FND_API.G_MISS_CHAR;
    x_pricing_rule                 := FND_API.G_MISS_CHAR;
    x_reprice                      := FND_API.G_MISS_CHAR;
    x_revision_reason              := FND_API.G_MISS_CHAR;
    x_unit                         := FND_API.G_MISS_CHAR;
    x_primary                      := FND_API.G_MISS_CHAR;
    x_creation_date            	   := FND_API.G_MISS_DATE;
    x_list_line_type_code          := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_Price_LLine_val_rec := OE_Price_List_Line_Util.Get_Values
    (   p_Price_List_Line_rec             => l_x_Price_LLine_rec
    ,   p_old_Price_List_Line_rec         => l_Price_LLine_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute1,
                            l_Price_LLine_rec.attribute1)
    THEN
        x_attribute1 := l_x_Price_LLine_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute10,
                            l_Price_LLine_rec.attribute10)
    THEN
        x_attribute10 := l_x_Price_LLine_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute11,
                            l_Price_LLine_rec.attribute11)
    THEN
        x_attribute11 := l_x_Price_LLine_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute12,
                            l_Price_LLine_rec.attribute12)
    THEN
        x_attribute12 := l_x_Price_LLine_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute13,
                            l_Price_LLine_rec.attribute13)
    THEN
        x_attribute13 := l_x_Price_LLine_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute14,
                            l_Price_LLine_rec.attribute14)
    THEN
        x_attribute14 := l_x_Price_LLine_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute15,
                            l_Price_LLine_rec.attribute15)
    THEN
        x_attribute15 := l_x_Price_LLine_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute2,
                            l_Price_LLine_rec.attribute2)
    THEN
        x_attribute2 := l_x_Price_LLine_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute3,
                            l_Price_LLine_rec.attribute3)
    THEN
        x_attribute3 := l_x_Price_LLine_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute4,
                            l_Price_LLine_rec.attribute4)
    THEN
        x_attribute4 := l_x_Price_LLine_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute5,
                            l_Price_LLine_rec.attribute5)
    THEN
        x_attribute5 := l_x_Price_LLine_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute6,
                            l_Price_LLine_rec.attribute6)
    THEN
        x_attribute6 := l_x_Price_LLine_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute7,
                            l_Price_LLine_rec.attribute7)
    THEN
        x_attribute7 := l_x_Price_LLine_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute8,
                            l_Price_LLine_rec.attribute8)
    THEN
        x_attribute8 := l_x_Price_LLine_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.attribute9,
                            l_Price_LLine_rec.attribute9)
    THEN
        x_attribute9 := l_x_Price_LLine_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.comments,
                            l_Price_LLine_rec.comments)
    THEN
        x_comments := l_x_Price_LLine_rec.comments;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.context,
                            l_Price_LLine_rec.context)
    THEN
        x_context := l_x_Price_LLine_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.customer_item_id,
                            l_Price_LLine_rec.customer_item_id)
    THEN
        x_customer_item_id := l_x_Price_LLine_rec.customer_item_id;
        x_customer_item := l_Price_LLine_val_rec.customer_item;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.end_date_active,
                            l_Price_LLine_rec.end_date_active)
    THEN
        x_end_date_active := l_x_Price_LLine_rec.end_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.inventory_item_id,
                            l_Price_LLine_rec.inventory_item_id)
    THEN
        x_inventory_item_id := l_x_Price_LLine_rec.inventory_item_id;
        x_inventory_item := l_Price_LLine_val_rec.inventory_item;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.list_price,
                            l_Price_LLine_rec.list_price)
    THEN
        x_list_price := l_x_Price_LLine_rec.list_price;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.method_code,
                            l_Price_LLine_rec.method_code)
    THEN
        x_method_code := l_x_Price_LLine_rec.method_code;
        x_method := l_Price_LLine_val_rec.method;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.price_list_id,
                            l_Price_LLine_rec.price_list_id)
    THEN
        x_price_list_id := l_x_Price_LLine_rec.price_list_id;
        x_price_list := l_Price_LLine_val_rec.price_list;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.price_list_line_id,
                            l_Price_LLine_rec.price_list_line_id)
    THEN
        x_price_list_line_id := l_x_Price_LLine_rec.price_list_line_id;
        x_price_list_line := l_Price_LLine_val_rec.price_list_line;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute1,
                            l_Price_LLine_rec.pricing_attribute1)
    THEN
        x_pricing_attribute1 := l_x_Price_LLine_rec.pricing_attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute10,
                            l_Price_LLine_rec.pricing_attribute10)
    THEN
        x_pricing_attribute10 := l_x_Price_LLine_rec.pricing_attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute11,
                            l_Price_LLine_rec.pricing_attribute11)
    THEN
        x_pricing_attribute11 := l_x_Price_LLine_rec.pricing_attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute12,
                            l_Price_LLine_rec.pricing_attribute12)
    THEN
        x_pricing_attribute12 := l_x_Price_LLine_rec.pricing_attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute13,
                            l_Price_LLine_rec.pricing_attribute13)
    THEN
        x_pricing_attribute13 := l_x_Price_LLine_rec.pricing_attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute14,
                            l_Price_LLine_rec.pricing_attribute14)
    THEN
        x_pricing_attribute14 := l_x_Price_LLine_rec.pricing_attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute15,
                            l_Price_LLine_rec.pricing_attribute15)
    THEN
        x_pricing_attribute15 := l_x_Price_LLine_rec.pricing_attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute2,
                            l_Price_LLine_rec.pricing_attribute2)
    THEN
        x_pricing_attribute2 := l_x_Price_LLine_rec.pricing_attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute3,
                            l_Price_LLine_rec.pricing_attribute3)
    THEN
        x_pricing_attribute3 := l_x_Price_LLine_rec.pricing_attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute4,
                            l_Price_LLine_rec.pricing_attribute4)
    THEN
        x_pricing_attribute4 := l_x_Price_LLine_rec.pricing_attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute5,
                            l_Price_LLine_rec.pricing_attribute5)
    THEN
        x_pricing_attribute5 := l_x_Price_LLine_rec.pricing_attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute6,
                            l_Price_LLine_rec.pricing_attribute6)
    THEN
        x_pricing_attribute6 := l_x_Price_LLine_rec.pricing_attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute7,
                            l_Price_LLine_rec.pricing_attribute7)
    THEN
        x_pricing_attribute7 := l_x_Price_LLine_rec.pricing_attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute8,
                            l_Price_LLine_rec.pricing_attribute8)
    THEN
        x_pricing_attribute8 := l_x_Price_LLine_rec.pricing_attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_attribute9,
                            l_Price_LLine_rec.pricing_attribute9)
    THEN
        x_pricing_attribute9 := l_x_Price_LLine_rec.pricing_attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_context,
                            l_Price_LLine_rec.pricing_context)
    THEN
        x_pricing_context := l_x_Price_LLine_rec.pricing_context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.pricing_rule_id,
                            l_Price_LLine_rec.pricing_rule_id)
    THEN
        x_pricing_rule_id := l_x_Price_LLine_rec.pricing_rule_id;
        x_pricing_rule := l_Price_LLine_val_rec.pricing_rule;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.reprice_flag,
                            l_Price_LLine_rec.reprice_flag)
    THEN
        x_reprice_flag := l_x_Price_LLine_rec.reprice_flag;
        x_reprice := l_Price_LLine_val_rec.reprice;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.revision,
                            l_Price_LLine_rec.revision)
    THEN
        x_revision := l_x_Price_LLine_rec.revision;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.revision_date,
                            l_Price_LLine_rec.revision_date)
    THEN
        x_revision_date := l_x_Price_LLine_rec.revision_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.revision_reason_code,
                            l_Price_LLine_rec.revision_reason_code)
    THEN
        x_revision_reason_code := l_x_Price_LLine_rec.revision_reason_code;
        x_revision_reason := l_Price_LLine_val_rec.revision_reason;
    END IF;

-- New Add

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.creation_date,
                            l_Price_LLine_rec.creation_date)
    THEN
        x_creation_date := l_x_Price_LLine_rec.creation_date;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.start_date_active,
                            l_Price_LLine_rec.start_date_active)
    THEN
        x_start_date_active := l_x_Price_LLine_rec.start_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.unit_code,
                            l_Price_LLine_rec.unit_code)
    THEN
        x_unit_code := l_x_Price_LLine_rec.unit_code;
        x_unit := l_Price_LLine_val_rec.unit;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.primary,
                            l_Price_LLine_rec.primary)
    THEN
        x_primary := l_x_Price_LLine_rec.primary;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LLine_rec.list_line_type_code,
                            l_Price_LLine_rec.list_line_type_code)
    THEN
        x_list_line_type_code := l_x_Price_LLine_rec.list_line_type_code;
    END IF;






    --  Write to cache.

    Write_Price_LLine
    (   p_Price_LLine_rec             => l_x_Price_LLine_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Price_List_Id: ' || g_Price_LLine_rec.price_list_id ||
		'Price_List_Line_Id: ' || g_Price_LLine_rec.price_list_line_id);
    oe_debug_pub.add('Exiting OE_OE_Form_Price_Lline.Change_Attribute');

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
,   p_price_list_line_id            IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_Price_LLine_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_Price_LLine_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Price_Lline.Validate_And_Write');

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

    --  Read Price_LLine from cache

    l_old_Price_LLine_rec := Get_Price_LLine
    (   p_db_record                   => TRUE
    ,   p_price_list_line_id          => p_price_list_line_id
    );

    l_Price_LLine_rec := Get_Price_LLine
    (   p_db_record                   => FALSE
    ,   p_price_list_line_id          => p_price_list_line_id
    );

    oe_debug_pub.add('Price_List_Id: ' || g_Price_LLine_rec.price_list_id ||
		'Price_List_Line_Id: ' || g_Price_LLine_rec.price_list_line_id);
    oe_debug_pub.add('Price_List_Id: ' || l_Price_LLine_rec.price_list_id ||
		'Price_List_Line_Id: ' || l_Price_LLine_rec.price_list_line_id);
    --  Set Operation.

    IF FND_API.To_Boolean(l_Price_LLine_rec.db_flag) THEN
        l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
            oe_debug_pub.add('create price list line');
        l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --Revision Control S
    IF ( ( l_old_Price_LLine_rec.revision <> FND_API.G_MISS_CHAR )
        AND (l_old_Price_LLine_rec.revision <>  l_Price_LLine_rec.revision) )
    THEN
        oe_debug_pub.add('incrementing price list line id');
        oe_debug_pub.add('old rev is: ' || l_old_Price_LLine_rec.revision);
        oe_debug_pub.add('new rev is: ' || l_Price_LLine_rec.revision);

      IF (l_old_Price_LLine_rec.revision is NULL) THEN
        oe_debug_pub.add('old revision is null');
      END IF;

      IF (l_Price_LLine_rec.revision is NULL) THEN
        oe_debug_pub.add('new revision is also null');
      END IF;

        select qp_list_lines_s.nextval into l_Price_LLine_rec.price_list_line_id from dual;
        l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_CREATE;
        l_Price_LLine_rec.db_flag := FND_API.G_FALSE;
    END IF;
    --Revision Control E

    --  Populate Price_LLine table

    l_Price_LLine_tbl(1) := l_Price_LLine_rec;
    l_old_Price_LLine_tbl(1) := l_old_Price_LLine_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   p_old_Price_LLine_tbl         => l_old_Price_LLine_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_Price_LLine_rec := l_x_Price_LLine_tbl(1);

    x_creation_date                := l_x_Price_LLine_rec.creation_date;
    x_created_by                   := l_x_Price_LLine_rec.created_by;
    x_last_update_date             := l_x_Price_LLine_rec.last_update_date;
    x_last_updated_by              := l_x_Price_LLine_rec.last_updated_by;
    x_last_update_login            := l_x_Price_LLine_rec.last_update_login;

    --  Clear Price_LLine record cache

    Clear_Price_LLine;

    --  Keep track of performed operations.

    l_old_Price_LLine_rec.operation := l_Price_LLine_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Price_Lline.Validate_And_Write');

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
,   p_price_list_line_id            IN  NUMBER
)
IS
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
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

    l_Price_LLine_rec := Get_Price_LLine
    (   p_db_record                   => TRUE
    ,   p_price_list_line_id          => p_price_list_line_id
    );

    --  Set Operation.

    l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate Price_LLine table

    l_Price_LLine_tbl(1) := l_Price_LLine_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Price_LLine record cache

    Clear_Price_LLine;

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

END Delete_Row;

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_Form_Price_Lline.Process_Entity');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_PRICE_LLINE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
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

    oe_debug_pub.add('Exiting OE_OE_Form_Price_Lline.Process_Entity');

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
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_customer_item_id              IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_inventory_item_id             IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_price                    IN  NUMBER
,   p_method_code                   IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_price_list_line_id            IN  NUMBER
,   p_pricing_attribute1            IN  VARCHAR2
,   p_pricing_attribute10           IN  VARCHAR2
,   p_pricing_attribute11           IN  VARCHAR2
,   p_pricing_attribute12           IN  VARCHAR2
,   p_pricing_attribute13           IN  VARCHAR2
,   p_pricing_attribute14           IN  VARCHAR2
,   p_pricing_attribute15           IN  VARCHAR2
,   p_pricing_attribute2            IN  VARCHAR2
,   p_pricing_attribute3            IN  VARCHAR2
,   p_pricing_attribute4            IN  VARCHAR2
,   p_pricing_attribute5            IN  VARCHAR2
,   p_pricing_attribute6            IN  VARCHAR2
,   p_pricing_attribute7            IN  VARCHAR2
,   p_pricing_attribute8            IN  VARCHAR2
,   p_pricing_attribute9            IN  VARCHAR2
,   p_pricing_context               IN  VARCHAR2
,   p_pricing_rule_id               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_reprice_flag                  IN  VARCHAR2
,   p_request_id                    IN  NUMBER
,   p_revision                      IN  VARCHAR2
,   p_revision_date                 IN  DATE
,   p_revision_reason_code          IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_unit_code                     IN  VARCHAR2
,   p_primary                       IN  VARCHAR2
,   p_list_line_type_code           IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Load Price_LLine record

     oe_debug_pub.add('price list id 1 is : ' || to_char(p_price_list_id));


    l_Price_LLine_rec.attribute1   := p_attribute1;
    l_Price_LLine_rec.attribute10  := p_attribute10;
    l_Price_LLine_rec.attribute11  := p_attribute11;
    l_Price_LLine_rec.attribute12  := p_attribute12;
    l_Price_LLine_rec.attribute13  := p_attribute13;
    l_Price_LLine_rec.attribute14  := p_attribute14;
    l_Price_LLine_rec.attribute15  := p_attribute15;
    l_Price_LLine_rec.attribute2   := p_attribute2;
    l_Price_LLine_rec.attribute3   := p_attribute3;
    l_Price_LLine_rec.attribute4   := p_attribute4;
    l_Price_LLine_rec.attribute5   := p_attribute5;
    l_Price_LLine_rec.attribute6   := p_attribute6;
    l_Price_LLine_rec.attribute7   := p_attribute7;
    l_Price_LLine_rec.attribute8   := p_attribute8;
    l_Price_LLine_rec.attribute9   := p_attribute9;
    l_Price_LLine_rec.comments     := p_comments;
    l_Price_LLine_rec.context      := p_context;
    l_Price_LLine_rec.created_by   := p_created_by;
    l_Price_LLine_rec.creation_date := p_creation_date;
    l_Price_LLine_rec.customer_item_id := p_customer_item_id;
    l_Price_LLine_rec.end_date_active := p_end_date_active;
    l_Price_LLine_rec.inventory_item_id := p_inventory_item_id;
    l_Price_LLine_rec.last_updated_by := p_last_updated_by;
    l_Price_LLine_rec.last_update_date := p_last_update_date;
    l_Price_LLine_rec.last_update_login := p_last_update_login;
    l_Price_LLine_rec.list_price   := p_list_price;
    l_Price_LLine_rec.method_code  := p_method_code;
    l_Price_LLine_rec.price_list_id := p_price_list_id;
    l_Price_LLine_rec.price_list_line_id := p_price_list_line_id;
    l_Price_LLine_rec.pricing_attribute1 := p_pricing_attribute1;
    l_Price_LLine_rec.pricing_attribute10 := p_pricing_attribute10;
    l_Price_LLine_rec.pricing_attribute11 := p_pricing_attribute11;
    l_Price_LLine_rec.pricing_attribute12 := p_pricing_attribute12;
    l_Price_LLine_rec.pricing_attribute13 := p_pricing_attribute13;
    l_Price_LLine_rec.pricing_attribute14 := p_pricing_attribute14;
    l_Price_LLine_rec.pricing_attribute15 := p_pricing_attribute15;
    l_Price_LLine_rec.pricing_attribute2 := p_pricing_attribute2;
    l_Price_LLine_rec.pricing_attribute3 := p_pricing_attribute3;
    l_Price_LLine_rec.pricing_attribute4 := p_pricing_attribute4;
    l_Price_LLine_rec.pricing_attribute5 := p_pricing_attribute5;
    l_Price_LLine_rec.pricing_attribute6 := p_pricing_attribute6;
    l_Price_LLine_rec.pricing_attribute7 := p_pricing_attribute7;
    l_Price_LLine_rec.pricing_attribute8 := p_pricing_attribute8;
    l_Price_LLine_rec.pricing_attribute9 := p_pricing_attribute9;
    l_Price_LLine_rec.pricing_context := p_pricing_context;
    l_Price_LLine_rec.pricing_rule_id := p_pricing_rule_id;
    l_Price_LLine_rec.program_application_id := p_program_application_id;
    l_Price_LLine_rec.program_id   := p_program_id;
    l_Price_LLine_rec.program_update_date := p_program_update_date;
    l_Price_LLine_rec.reprice_flag := p_reprice_flag;
    l_Price_LLine_rec.request_id   := p_request_id;
    l_Price_LLine_rec.revision     := p_revision;
    l_Price_LLine_rec.revision_date := p_revision_date;
    l_Price_LLine_rec.revision_reason_code := p_revision_reason_code;
    l_Price_LLine_rec.start_date_active := p_start_date_active;
    l_Price_LLine_rec.unit_code    := p_unit_code;
    l_Price_LLine_rec.primary      := p_primary;
    l_Price_LLine_rec.list_line_type_code      := p_list_line_type_code;


    --  Populate Price_LLine table

    l_Price_LLine_tbl(1) := l_Price_LLine_rec;

     oe_debug_pub.add('price list id 2 is : ' || to_char(l_Price_LLine_tbl(1).price_list_id));

    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    oe_debug_pub.add('price list id 3 is : ' || to_char(p_price_list_id));

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Price_LLine_rec.db_flag := FND_API.G_TRUE;

        Write_Price_LLine
        (   p_Price_LLine_rec             => l_x_Price_LLine_rec
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



END Lock_Row;

--  Procedures maintaining Price_LLine record cache.

PROCEDURE Write_Price_LLine
(   p_Price_LLine_rec               IN  OE_Price_List_PUB.Price_List_Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_Price_LLine_rec := p_Price_LLine_rec;

    IF p_db_record THEN

        g_db_Price_LLine_rec := p_Price_LLine_rec;

    END IF;

END Write_Price_Lline;

FUNCTION Get_Price_LLine
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_line_id            IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
BEGIN

    oe_debug_pub.add('global pline id is : ' || to_char(g_Price_LLine_rec.price_list_id));

    oe_debug_pub.add('plineid 2 is : ' || to_char(p_price_list_line_id));

    IF  p_price_list_line_id <> g_Price_LLine_rec.price_list_line_id
    THEN

        --  Query row from DB

        g_Price_LLine_rec := OE_Price_List_Line_Util.Query_Row
        (   p_price_list_line_id          => p_price_list_line_id
        ,   p_price_list_id          => g_Price_LLine_rec.price_list_id
        );

        g_Price_LLine_rec.db_flag      := FND_API.G_TRUE;

        --  Load DB record

        g_db_Price_LLine_rec           := g_Price_LLine_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_Price_LLine_rec;

    ELSE

        RETURN g_Price_LLine_rec;

    END IF;

END Get_Price_Lline;

PROCEDURE Clear_Price_Lline
IS
BEGIN

    g_Price_LLine_rec              := OE_Price_List_PUB.G_MISS_PRICE_List_Line_REC;
    g_db_Price_LLine_rec           := OE_Price_List_PUB.G_MISS_PRICE_List_Line_REC;

END Clear_Price_Lline;

END OE_OE_Form_Price_Lline;

/
