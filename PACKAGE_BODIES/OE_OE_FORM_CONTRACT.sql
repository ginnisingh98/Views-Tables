--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_CONTRACT" AS
/* $Header: OEXFPCTB.pls 115.0 99/07/15 19:22:32 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Contract';

--  Global variables holding cached record.

g_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
g_db_Contract_rec             OE_Pricing_Cont_PUB.Contract_Rec_Type;

-- Revision Control S
g_Revision_Change             VARCHAR2(1) :=  FND_API.G_FALSE;
g_Agreement_Id		      NUMBER := FND_API.G_MISS_NUM;
-- Revision Control E

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Contract
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_Contract
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_contract_id           IN  NUMBER
)
RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type;

PROCEDURE Clear_Contract;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Pricing_Cont_PUB.Contract_Tbl_Type;

PROCEDURE Get_Startup_Values
(Item_Id_Flex_Code         IN VARCHAR2,
 Item_Id_Flex_Num          OUT NUMBER) IS

    CURSOR C_Item_Flex(X_Id_Flex_Code VARCHAR2) is
      SELECT id_flex_num
      FROM   fnd_id_flex_structures
      WHERE  id_flex_code = X_Id_Flex_Code;
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_CONTRACT.GET_FORM_STARTUP_VALUES');

    OPEN C_Item_Flex(Item_Id_Flex_Code);
    FETCH C_Item_Flex INTO Item_Id_Flex_Num;
    CLOSE C_Item_Flex;

    oe_debug_pub.add('Exiting OE_OE_FORM_CONTRACT.GET_FORM_STARTUP_VALUES');

  EXCEPTION
    WHEN OTHERS THEN
      OE_MSG.Internal_Exception('OE_OE_Form_Contract.Get_Form_Startup_Values',
                                'Get Form Startup Values', 'AGREEMENT');

END Get_Startup_Values;



--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   x_agreement_id                  OUT NUMBER
,   x_attribute1                    OUT VARCHAR2
,   x_attribute10                   OUT VARCHAR2
,   x_attribute11                   OUT VARCHAR2
,   x_attribute12                   OUT VARCHAR2
,   x_attribute13                   OUT VARCHAR2
,   x_attribute14                   OUT VARCHAR2
,   x_attribute15                   OUT VARCHAR2
,   x_attribute2                    OUT VARCHAR2
,   x_attribute3                    OUT VARCHAR2
,   x_attribute4                    OUT VARCHAR2
,   x_attribute5                    OUT VARCHAR2
,   x_attribute6                    OUT VARCHAR2
,   x_attribute7                    OUT VARCHAR2
,   x_attribute8                    OUT VARCHAR2
,   x_attribute9                    OUT VARCHAR2
,   x_context                       OUT VARCHAR2
,   x_discount_id                   OUT NUMBER
,   x_last_updated_by               OUT NUMBER
,   x_price_list_id                 OUT NUMBER
,   x_pricing_contract_id           OUT NUMBER
,   x_agreement                     OUT VARCHAR2
,   x_discount                      OUT VARCHAR2
,   x_price_list                    OUT VARCHAR2
)
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_Contract_val_rec            OE_Pricing_Cont_PUB.Contract_Val_Rec_Type;
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

    oe_debug_pub.add('Entering OE_OE_Form_Contract.Default_Attributes');

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

    l_Contract_rec.attribute1                     := 'NULL';
    l_Contract_rec.attribute10                    := 'NULL';
    l_Contract_rec.attribute11                    := 'NULL';
    l_Contract_rec.attribute12                    := 'NULL';
    l_Contract_rec.attribute13                    := 'NULL';
    l_Contract_rec.attribute14                    := 'NULL';
    l_Contract_rec.attribute15                    := 'NULL';
    l_Contract_rec.attribute2                     := 'NULL';
    l_Contract_rec.attribute3                     := 'NULL';
    l_Contract_rec.attribute4                     := 'NULL';
    l_Contract_rec.attribute5                     := 'NULL';
    l_Contract_rec.attribute6                     := 'NULL';
    l_Contract_rec.attribute7                     := 'NULL';
    l_Contract_rec.attribute8                     := 'NULL';
    l_Contract_rec.attribute9                     := 'NULL';
    l_Contract_rec.context                        := 'NULL';

    --  Set Operation to Create

    l_Contract_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Contract_rec                => l_Contract_rec
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

    x_agreement_id                 := l_x_Contract_rec.agreement_id;
    x_attribute1                   := l_x_Contract_rec.attribute1;
    x_attribute10                  := l_x_Contract_rec.attribute10;
    x_attribute11                  := l_x_Contract_rec.attribute11;
    x_attribute12                  := l_x_Contract_rec.attribute12;
    x_attribute13                  := l_x_Contract_rec.attribute13;
    x_attribute14                  := l_x_Contract_rec.attribute14;
    x_attribute15                  := l_x_Contract_rec.attribute15;
    x_attribute2                   := l_x_Contract_rec.attribute2;
    x_attribute3                   := l_x_Contract_rec.attribute3;
    x_attribute4                   := l_x_Contract_rec.attribute4;
    x_attribute5                   := l_x_Contract_rec.attribute5;
    x_attribute6                   := l_x_Contract_rec.attribute6;
    x_attribute7                   := l_x_Contract_rec.attribute7;
    x_attribute8                   := l_x_Contract_rec.attribute8;
    x_attribute9                   := l_x_Contract_rec.attribute9;
    x_context                      := l_x_Contract_rec.context;
    x_discount_id                  := l_x_Contract_rec.discount_id;
    x_last_updated_by              := l_x_Contract_rec.last_updated_by;
    x_price_list_id                := l_x_Contract_rec.price_list_id;
    x_pricing_contract_id          := l_x_Contract_rec.pricing_contract_id;

    --  Load display out parameters if any

    l_Contract_val_rec := OE_Contract_Util.Get_Values
    (   p_Contract_rec                => l_x_Contract_rec
    );
    x_agreement                    := l_Contract_val_rec.agreement;
    x_discount                     := l_Contract_val_rec.discount;
    x_price_list                   := l_Contract_val_rec.price_list;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Contract_rec.db_flag := FND_API.G_FALSE;

    Write_Contract
    (   p_Contract_rec                => l_x_Contract_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Contract.Default_Attributes');

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
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
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
,   x_agreement_id                  OUT NUMBER
,   x_attribute1                    OUT VARCHAR2
,   x_attribute10                   OUT VARCHAR2
,   x_attribute11                   OUT VARCHAR2
,   x_attribute12                   OUT VARCHAR2
,   x_attribute13                   OUT VARCHAR2
,   x_attribute14                   OUT VARCHAR2
,   x_attribute15                   OUT VARCHAR2
,   x_attribute2                    OUT VARCHAR2
,   x_attribute3                    OUT VARCHAR2
,   x_attribute4                    OUT VARCHAR2
,   x_attribute5                    OUT VARCHAR2
,   x_attribute6                    OUT VARCHAR2
,   x_attribute7                    OUT VARCHAR2
,   x_attribute8                    OUT VARCHAR2
,   x_attribute9                    OUT VARCHAR2
,   x_context                       OUT VARCHAR2
,   x_discount_id                   OUT NUMBER
,   x_last_updated_by               OUT NUMBER
,   x_price_list_id                 OUT NUMBER
,   x_pricing_contract_id           OUT NUMBER
,   x_agreement                     OUT VARCHAR2
,   x_discount                      OUT VARCHAR2
,   x_price_list                    OUT VARCHAR2
)
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_old_Contract_rec            OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_Contract_val_rec            OE_Pricing_Cont_PUB.Contract_Val_Rec_Type;
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

    oe_debug_pub.add('Entering OE_OE_Form_Contract.Change_Attribute');

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

    --  Read Contract from cache

    l_Contract_rec := Get_Contract
    (   p_db_record                   => FALSE
    ,   p_pricing_contract_id         => p_pricing_contract_id
    );

    l_old_Contract_rec             := l_Contract_rec;

    IF p_attr_id = OE_Contract_Util.G_AGREEMENT THEN
        l_Contract_rec.agreement_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Contract_Util.G_DISCOUNT THEN
        l_Contract_rec.discount_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Contract_Util.G_LAST_UPDATED_BY THEN
        l_Contract_rec.last_updated_by := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Contract_Util.G_PRICE_LIST THEN
        l_Contract_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Contract_Util.G_PRICING_CONTRACT THEN
        l_Contract_rec.pricing_contract_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Contract_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Contract_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Contract_Util.G_CONTEXT
    THEN

        l_Contract_rec.attribute1      := p_attribute1;
        l_Contract_rec.attribute10     := p_attribute10;
        l_Contract_rec.attribute11     := p_attribute11;
        l_Contract_rec.attribute12     := p_attribute12;
        l_Contract_rec.attribute13     := p_attribute13;
        l_Contract_rec.attribute14     := p_attribute14;
        l_Contract_rec.attribute15     := p_attribute15;
        l_Contract_rec.attribute2      := p_attribute2;
        l_Contract_rec.attribute3      := p_attribute3;
        l_Contract_rec.attribute4      := p_attribute4;
        l_Contract_rec.attribute5      := p_attribute5;
        l_Contract_rec.attribute6      := p_attribute6;
        l_Contract_rec.attribute7      := p_attribute7;
        l_Contract_rec.attribute8      := p_attribute8;
        l_Contract_rec.attribute9      := p_attribute9;
        l_Contract_rec.context         := p_context;

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

    IF FND_API.To_Boolean(l_Contract_rec.db_flag) THEN
        l_Contract_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Contract_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Contract_rec                => l_Contract_rec
    ,   p_old_Contract_rec            => l_old_Contract_rec
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


    --  Init OUT parameters to missing.

    x_agreement_id                 := FND_API.G_MISS_NUM;
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
    x_context                      := FND_API.G_MISS_CHAR;
    x_discount_id                  := FND_API.G_MISS_NUM;
    x_last_updated_by              := FND_API.G_MISS_NUM;
    x_price_list_id                := FND_API.G_MISS_NUM;
    x_pricing_contract_id          := FND_API.G_MISS_NUM;
    x_agreement                    := FND_API.G_MISS_CHAR;
    x_discount                     := FND_API.G_MISS_CHAR;
    x_price_list                   := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_Contract_val_rec := OE_Contract_Util.Get_Values
    (   p_Contract_rec                => l_x_Contract_rec
    ,   p_old_Contract_rec            => l_Contract_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.agreement_id,
                            l_Contract_rec.agreement_id)
    THEN
        x_agreement_id := l_x_Contract_rec.agreement_id;
        x_agreement := l_Contract_val_rec.agreement;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute1,
                            l_Contract_rec.attribute1)
    THEN
        x_attribute1 := l_x_Contract_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute10,
                            l_Contract_rec.attribute10)
    THEN
        x_attribute10 := l_x_Contract_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute11,
                            l_Contract_rec.attribute11)
    THEN
        x_attribute11 := l_x_Contract_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute12,
                            l_Contract_rec.attribute12)
    THEN
        x_attribute12 := l_x_Contract_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute13,
                            l_Contract_rec.attribute13)
    THEN
        x_attribute13 := l_x_Contract_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute14,
                            l_Contract_rec.attribute14)
    THEN
        x_attribute14 := l_x_Contract_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute15,
                            l_Contract_rec.attribute15)
    THEN
        x_attribute15 := l_x_Contract_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute2,
                            l_Contract_rec.attribute2)
    THEN
        x_attribute2 := l_x_Contract_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute3,
                            l_Contract_rec.attribute3)
    THEN
        x_attribute3 := l_x_Contract_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute4,
                            l_Contract_rec.attribute4)
    THEN
        x_attribute4 := l_x_Contract_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute5,
                            l_Contract_rec.attribute5)
    THEN
        x_attribute5 := l_x_Contract_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute6,
                            l_Contract_rec.attribute6)
    THEN
        x_attribute6 := l_x_Contract_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute7,
                            l_Contract_rec.attribute7)
    THEN
        x_attribute7 := l_x_Contract_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute8,
                            l_Contract_rec.attribute8)
    THEN
        x_attribute8 := l_x_Contract_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.attribute9,
                            l_Contract_rec.attribute9)
    THEN
        x_attribute9 := l_x_Contract_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.context,
                            l_Contract_rec.context)
    THEN
        x_context := l_x_Contract_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.discount_id,
                            l_Contract_rec.discount_id)
    THEN
        x_discount_id := l_x_Contract_rec.discount_id;
        x_discount := l_Contract_val_rec.discount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.last_updated_by,
                            l_Contract_rec.last_updated_by)
    THEN
        x_last_updated_by := l_x_Contract_rec.last_updated_by;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.price_list_id,
                            l_Contract_rec.price_list_id)
    THEN
        x_price_list_id := l_x_Contract_rec.price_list_id;
        x_price_list := l_Contract_val_rec.price_list;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Contract_rec.pricing_contract_id,
                            l_Contract_rec.pricing_contract_id)
    THEN
        x_pricing_contract_id := l_x_Contract_rec.pricing_contract_id;
    END IF;


    --  Write to cache.

    Write_Contract
    (   p_Contract_rec                => l_x_Contract_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Contract.Change_Attribute');

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
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
,   x_creation_date                 OUT DATE
,   x_created_by                    OUT NUMBER
,   x_last_update_date              OUT DATE
,   x_last_updated_by               OUT NUMBER
,   x_last_update_login             OUT NUMBER
)
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_old_Contract_rec            OE_Pricing_Cont_PUB.Contract_Rec_Type;
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

    oe_debug_pub.add('Entering OE_OE_Form_Contract.Validate_And_Write');

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

    --  Read Contract from cache

    l_old_Contract_rec := Get_Contract
    (   p_db_record                   => TRUE
    ,   p_pricing_contract_id         => p_pricing_contract_id
    );

    l_Contract_rec := Get_Contract
    (   p_db_record                   => FALSE
    ,   p_pricing_contract_id         => p_pricing_contract_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_Contract_rec.db_flag) THEN
        l_Contract_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Contract_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --Revision Control S
    IF FND_API.To_Boolean(g_Revision_Change) THEN
        select oe_pricing_contracts_s.nextval into l_Contract_rec.pricing_contract_id  from dual;
	l_contract_rec.agreement_id := g_Agreement_Id;
        l_Contract_rec.operation := OE_GLOBALS.G_OPR_CREATE;
        l_Contract_rec.db_flag := FND_API.G_FALSE;
	g_Revision_Change := FND_API.G_FALSE;
    END IF;
    --Revision Control E

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Contract_rec                => l_Contract_rec
    ,   p_old_Contract_rec            => l_old_Contract_rec
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


    x_creation_date                := l_x_Contract_rec.creation_date;
    x_created_by                   := l_x_Contract_rec.created_by;
    x_last_update_date             := l_x_Contract_rec.last_update_date;
    x_last_updated_by              := l_x_Contract_rec.last_updated_by;
    x_last_update_login            := l_x_Contract_rec.last_update_login;

    --  Clear Contract record cache

    Clear_Contract;

    --  Keep track of performed operations.

    l_old_Contract_rec.operation := l_Contract_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_Form_Contract.Validate_And_Write');

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
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
)
IS
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
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

    l_Contract_rec := Get_Contract
    (   p_db_record                   => TRUE
    ,   p_pricing_contract_id         => p_pricing_contract_id
    );

    --  Set Operation.

    l_Contract_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Contract_rec                => l_Contract_rec
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


    --  Clear Contract record cache

    Clear_Contract;

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
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
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

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_CONTRACT;

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

--  Procedure       Process_Object
--

PROCEDURE Process_Object
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
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

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

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

END Process_Object;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_agreement_id                  IN  NUMBER
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
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_discount_id                   IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_price_list_id                 IN  NUMBER
,   p_pricing_contract_id           IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
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

    --  Load Contract record

    l_Contract_rec.agreement_id    := p_agreement_id;
    l_Contract_rec.attribute1      := p_attribute1;
    l_Contract_rec.attribute10     := p_attribute10;
    l_Contract_rec.attribute11     := p_attribute11;
    l_Contract_rec.attribute12     := p_attribute12;
    l_Contract_rec.attribute13     := p_attribute13;
    l_Contract_rec.attribute14     := p_attribute14;
    l_Contract_rec.attribute15     := p_attribute15;
    l_Contract_rec.attribute2      := p_attribute2;
    l_Contract_rec.attribute3      := p_attribute3;
    l_Contract_rec.attribute4      := p_attribute4;
    l_Contract_rec.attribute5      := p_attribute5;
    l_Contract_rec.attribute6      := p_attribute6;
    l_Contract_rec.attribute7      := p_attribute7;
    l_Contract_rec.attribute8      := p_attribute8;
    l_Contract_rec.attribute9      := p_attribute9;
    l_Contract_rec.context         := p_context;
    l_Contract_rec.created_by      := p_created_by;
    l_Contract_rec.creation_date   := p_creation_date;
    l_Contract_rec.discount_id     := p_discount_id;
    l_Contract_rec.last_updated_by := p_last_updated_by;
    l_Contract_rec.last_update_date := p_last_update_date;
    l_Contract_rec.last_update_login := p_last_update_login;
    l_Contract_rec.price_list_id   := p_price_list_id;
    l_Contract_rec.pricing_contract_id := p_pricing_contract_id;

    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Contract_rec                => l_Contract_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Contract_rec.db_flag := FND_API.G_TRUE;

        Write_Contract
        (   p_Contract_rec                => l_x_Contract_rec
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

--  Procedures maintaining Contract record cache.

PROCEDURE Write_Contract
(   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_Contract_rec := p_Contract_rec;

    IF p_db_record THEN

        g_db_Contract_rec := p_Contract_rec;

    END IF;

END Write_Contract;

FUNCTION Get_Contract
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_contract_id           IN  NUMBER
)
RETURN OE_Pricing_Cont_PUB.Contract_Rec_Type
IS
BEGIN

    IF  p_pricing_contract_id <> g_Contract_rec.pricing_contract_id
    THEN

        --  Query row from DB

        g_Contract_rec := OE_Contract_Util.Query_Row
        (   p_pricing_contract_id         => p_pricing_contract_id
        );

        g_Contract_rec.db_flag         := FND_API.G_TRUE;

        --  Load DB record

        g_db_Contract_rec              := g_Contract_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_Contract_rec;

    ELSE

        RETURN g_Contract_rec;

    END IF;

END Get_Contract;

PROCEDURE Clear_Contract
IS
BEGIN

    g_Contract_rec                 := OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC;
    g_db_Contract_rec              := OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC;

END Clear_Contract;

-- Revision Control S
PROCEDURE Create_Revision (l_Agreement_Id IN NUMBER)
IS
BEGIN
    g_Revision_Change := FND_API.G_TRUE;
    g_Agreement_Id := l_Agreement_Id;
    --Validate_And_Write;
    --g_Revision_Change := FND_API.G_FALSE;
END;
-- Revision Control E

END OE_OE_Form_Contract;

/
