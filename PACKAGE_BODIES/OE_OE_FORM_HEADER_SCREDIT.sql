--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_HEADER_SCREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_HEADER_SCREDIT" AS
/* $Header: OEXFHSCB.pls 120.0 2005/06/01 01:36:19 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Header_Scredit';

--  Global variables holding cached record.

g_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
g_db_Header_Scredit_rec       OE_Order_PUB.Header_Scredit_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Header_Scredit
(   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE Get_Header_Scredit
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_sales_credit_id               IN  NUMBER
,   x_header_scredit_rec            OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
);

PROCEDURE Clear_Header_Scredit;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Header_Scredit_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_dw_update_advice_flag OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_percent OUT NOCOPY NUMBER

, x_salesrep_id OUT NOCOPY NUMBER

, x_sales_credit_type_id OUT NOCOPY NUMBER

, x_sales_credit_id OUT NOCOPY NUMBER

, x_wh_update_date OUT NOCOPY DATE

, x_salesrep OUT NOCOPY VARCHAR2

, x_sales_credit_type OUT NOCOPY VARCHAR2
--SG {
,   x_sales_group_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_sales_group_updated_flag      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--SG}

)
IS
l_Header_Scredit_val_rec      OE_Order_PUB.Header_Scredit_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_Old_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist
    l_x_Header_Scredit_tbl(1):=OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_REC;
    l_x_old_Header_Scredit_Tbl(1):=OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_REC;

    l_x_Header_Scredit_tbl(1).header_id                := p_header_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_x_header_scredit_tbl(1).attribute1               := NULL;
    l_x_header_scredit_tbl(1).attribute10              := NULL;
    l_x_header_scredit_tbl(1).attribute11              := NULL;
    l_x_header_scredit_tbl(1).attribute12              := NULL;
    l_x_header_scredit_tbl(1).attribute13              := NULL;
    l_x_header_scredit_tbl(1).attribute14              := NULL;
    l_x_header_scredit_tbl(1).attribute15              := NULL;
    l_x_header_scredit_tbl(1).attribute2               := NULL;
    l_x_header_scredit_tbl(1).attribute3               := NULL;
    l_x_header_scredit_tbl(1).attribute4               := NULL;
    l_x_header_scredit_tbl(1).attribute5               := NULL;
    l_x_header_scredit_tbl(1).attribute6               := NULL;
    l_x_header_scredit_tbl(1).attribute7               := NULL;
    l_x_header_scredit_tbl(1).attribute8               := NULL;
    l_x_header_scredit_tbl(1).attribute9               := NULL;
    l_x_header_scredit_tbl(1).context                  := NULL;

    --  Set Operation to Create

    l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Header_Scredit table


    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Header_Scredits
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_old_Header_Scredit_tbl    => l_x_old_Header_Scredit_tbl
    ,   x_return_Status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;




    --  Load OUT NOCOPY parameters.

    x_attribute1                   := l_x_header_scredit_tbl(1).attribute1;
    x_attribute10                  := l_x_header_scredit_tbl(1).attribute10;
    x_attribute11                  := l_x_header_scredit_tbl(1).attribute11;
    x_attribute12                  := l_x_header_scredit_tbl(1).attribute12;
    x_attribute13                  := l_x_header_scredit_tbl(1).attribute13;
    x_attribute14                  := l_x_header_scredit_tbl(1).attribute14;
    x_attribute15                  := l_x_header_scredit_tbl(1).attribute15;
    x_attribute2                   := l_x_header_scredit_tbl(1).attribute2;
    x_attribute3                   := l_x_header_scredit_tbl(1).attribute3;
    x_attribute4                   := l_x_header_scredit_tbl(1).attribute4;
    x_attribute5                   := l_x_header_scredit_tbl(1).attribute5;
    x_attribute6                   := l_x_header_scredit_tbl(1).attribute6;
    x_attribute7                   := l_x_header_scredit_tbl(1).attribute7;
    x_attribute8                   := l_x_header_scredit_tbl(1).attribute8;
    x_attribute9                   := l_x_header_scredit_tbl(1).attribute9;
    x_context                      := l_x_header_scredit_tbl(1).context;
    x_dw_update_advice_flag        := l_x_header_scredit_tbl(1).dw_update_advice_flag;
    x_header_id                    := l_x_header_scredit_tbl(1).header_id;
    x_line_id                      := l_x_header_scredit_tbl(1).line_id;
    x_percent                      := l_x_header_scredit_tbl(1).percent;
    x_salesrep_id                  := l_x_header_scredit_tbl(1).salesrep_id;
    x_sales_credit_type_id         := l_x_header_scredit_tbl(1).sales_credit_type_id;
    x_sales_credit_id              := l_x_header_scredit_tbl(1).sales_credit_id;
    x_wh_update_date               := l_x_header_scredit_tbl(1).wh_update_date;

    --  Load display out NOCOPY parameters if any

    l_Header_Scredit_val_rec := OE_Header_Scredit_Util.Get_Values
    (   p_Header_Scredit_rec          => l_x_Header_Scredit_tbl(1)
    );
    x_salesrep                     := l_Header_Scredit_val_rec.salesrep;
    x_sales_credit_type           := l_Header_Scredit_val_rec.sales_credit_type;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Header_Scredit_tbl(1).db_flag := FND_API.G_FALSE;

    Write_Header_Scredit
    (   p_Header_Scredit_rec          => l_x_Header_Scredit_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
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
--SG{
,   p_sales_group_id                IN  NUMBER
,   p_sales_group_updated_flag           IN  VARCHAR2
--SG}
, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_context OUT NOCOPY VARCHAR2

, x_dw_update_advice_flag OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_percent OUT NOCOPY NUMBER

, x_salesrep_id OUT NOCOPY NUMBER

, x_sales_credit_type_id OUT NOCOPY NUMBER

, x_sales_credit_id OUT NOCOPY NUMBER

, x_wh_update_date OUT NOCOPY DATE

, x_salesrep OUT NOCOPY VARCHAR2

, x_sales_credit_type OUT NOCOPY VARCHAR2
--SG{
,   x_sales_group         OUT NOCOPY  VARCHAR2
,   x_sales_group_id      OUT NOCOPY  NUMBER
,   x_sales_group_updated_flag OUT NOCOPY  VARCHAR2
--SG}

)
IS
l_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;
l_Header_Scredit_val_rec      OE_Order_PUB.Header_Scredit_Val_Rec_Type;
l_x_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.CHANGE_ATTRIBUTE' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Header_Scredit from cache
    Get_Header_Scredit
    (   p_db_record                   => FALSE
    ,   p_sales_credit_id             => p_sales_credit_id
    ,   x_header_scredit_rec          => l_x_Header_Scredit_tbl(1)
    );

    l_x_old_Header_Scredit_tbl(1)       := l_x_Header_Scredit_tbl(1);

    IF p_attr_id = OE_Header_Scredit_Util.G_DW_UPDATE_ADVICE THEN
        l_x_header_scredit_tbl(1).dw_update_advice_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_HEADER THEN
        l_x_header_scredit_tbl(1).header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_LINE THEN
        l_x_header_scredit_tbl(1).line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_PERCENT THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER PERCENT ' || P_ATTR_VALUE ) ;
		END IF;
        l_x_header_scredit_tbl(1).percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_SALESREP THEN
        l_x_header_scredit_tbl(1).salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_SALES_CREDIT_TYPE THEN
        l_x_header_scredit_tbl(1).sales_credit_type_id := TO_NUMBER(p_attr_value);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER CREDIT TYPE ' || P_ATTR_VALUE ) ;
		END IF;
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_SALES_CREDIT THEN
        l_x_header_scredit_tbl(1).sales_credit_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_WH_UPDATE_DATE THEN
         l_x_header_scredit_tbl(1).wh_update_date := TO_DATE(p_attr_value,'YYYY/MM/DD');
    --SG {
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_SALES_GROUP_ID THEN
         l_x_header_scredit_tbl(1).sales_group_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =  OE_Header_Scredit_Util.G_SALES_GROUP_UPDATED_FLAG THEN
         l_x_header_scredit_tbl(1).sales_group_updated_flag := p_attr_value;
    --SG }
    ELSIF p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Scredit_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Scredit_Util.G_CONTEXT
    THEN

        l_x_header_scredit_tbl(1).attribute1 := p_attribute1;
        l_x_header_scredit_tbl(1).attribute10 := p_attribute10;
        l_x_header_scredit_tbl(1).attribute11 := p_attribute11;
        l_x_header_scredit_tbl(1).attribute12 := p_attribute12;
        l_x_header_scredit_tbl(1).attribute13 := p_attribute13;
        l_x_header_scredit_tbl(1).attribute14 := p_attribute14;
        l_x_header_scredit_tbl(1).attribute15 := p_attribute15;
        l_x_header_scredit_tbl(1).attribute2 := p_attribute2;
        l_x_header_scredit_tbl(1).attribute3 := p_attribute3;
        l_x_header_scredit_tbl(1).attribute4 := p_attribute4;
        l_x_header_scredit_tbl(1).attribute5 := p_attribute5;
        l_x_header_scredit_tbl(1).attribute6 := p_attribute6;
        l_x_header_scredit_tbl(1).attribute7 := p_attribute7;
        l_x_header_scredit_tbl(1).attribute8 := p_attribute8;
        l_x_header_scredit_tbl(1).attribute9 := p_attribute9;
        l_x_header_scredit_tbl(1).context   := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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

    IF FND_API.To_Boolean(l_x_Header_Scredit_tbl(1).db_flag) THEN
        l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Header_Scredit table
    l_header_scredit_rec:=l_x_Header_Scredit_Tbl(1);
    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Header_Scredits
    (
        p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                   => l_control_rec
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   p_x_old_Header_Scredit_tbl      => l_x_old_Header_Scredit_tbl
    ,   x_return_status                 => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT NOCOPY parameters to missing.

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
    x_dw_update_advice_flag        := FND_API.G_MISS_CHAR;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_percent                      := FND_API.G_MISS_NUM;
    x_salesrep_id                  := FND_API.G_MISS_NUM;
    x_sales_credit_type_id         := FND_API.G_MISS_NUM;
    x_sales_credit_id              := FND_API.G_MISS_NUM;
    x_wh_update_date               := FND_API.G_MISS_DATE;
    x_salesrep                     := FND_API.G_MISS_CHAR;
    x_sales_credit_type            := FND_API.G_MISS_CHAR;
    --SG{
    x_sales_group                  := FND_API.G_MISS_CHAR;
    x_sales_group_id               := FND_API.G_MISS_NUM;
    x_sales_group_updated_flag          := FND_API.G_MISS_CHAR;
    --SG}

    --  Load display out NOCOPY parameters if any

    l_Header_Scredit_val_rec := OE_Header_Scredit_Util.Get_Values
    (   p_Header_Scredit_rec          => l_x_Header_Scredit_tbl(1)
    ,   p_old_Header_Scredit_rec      => l_Header_Scredit_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute1,
                            l_Header_Scredit_rec.attribute1)
    THEN
        x_attribute1 := l_x_header_scredit_tbl(1).attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute10,
                            l_Header_Scredit_rec.attribute10)
    THEN
        x_attribute10 := l_x_header_scredit_tbl(1).attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute11,
                            l_Header_Scredit_rec.attribute11)
    THEN
        x_attribute11 := l_x_header_scredit_tbl(1).attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute12,
                            l_Header_Scredit_rec.attribute12)
    THEN
        x_attribute12 := l_x_header_scredit_tbl(1).attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute13,
                            l_Header_Scredit_rec.attribute13)
    THEN
        x_attribute13 := l_x_header_scredit_tbl(1).attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute14,
                            l_Header_Scredit_rec.attribute14)
    THEN
        x_attribute14 := l_x_header_scredit_tbl(1).attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_header_scredit_tbl(1).attribute15,
                            l_Header_Scredit_rec.attribute15)
    THEN
        x_attribute15 := l_x_header_scredit_tbl(1).attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute2,
                            l_Header_Scredit_rec.attribute2)
    THEN
        x_attribute2 := l_x_Header_Scredit_Tbl(1).attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute3,
                            l_Header_Scredit_rec.attribute3)
    THEN
        x_attribute3 := l_x_Header_Scredit_Tbl(1).attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute4,
                            l_Header_Scredit_rec.attribute4)
    THEN
        x_attribute4 := l_x_Header_Scredit_Tbl(1).attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute5,
                            l_Header_Scredit_rec.attribute5)
    THEN
        x_attribute5 := l_x_Header_Scredit_Tbl(1).attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute6,
                            l_Header_Scredit_rec.attribute6)
    THEN
        x_attribute6 := l_x_Header_Scredit_Tbl(1).attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute7,
                            l_Header_Scredit_rec.attribute7)
    THEN
        x_attribute7 := l_x_Header_Scredit_Tbl(1).attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute8,
                            l_Header_Scredit_rec.attribute8)
    THEN
        x_attribute8 := l_x_Header_Scredit_Tbl(1).attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).attribute9,
                            l_Header_Scredit_rec.attribute9)
    THEN
        x_attribute9 := l_x_Header_Scredit_Tbl(1).attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).context,
                            l_Header_Scredit_rec.context)
    THEN
        x_context := l_x_Header_Scredit_Tbl(1).context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).dw_update_advice_flag,
                            l_Header_Scredit_rec.dw_update_advice_flag)
    THEN
        x_dw_update_advice_flag := l_x_Header_Scredit_Tbl(1).dw_update_advice_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).header_id,
                            l_Header_Scredit_rec.header_id)
    THEN
        x_header_id := l_x_Header_Scredit_Tbl(1).header_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).line_id,
                            l_Header_Scredit_rec.line_id)
    THEN
        x_line_id := l_x_Header_Scredit_Tbl(1).line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).percent,
                            l_Header_Scredit_rec.percent)
    THEN
        x_percent := l_x_Header_Scredit_Tbl(1).percent;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).salesrep_id,
                            l_Header_Scredit_rec.salesrep_id)
    THEN
        x_salesrep_id := l_x_Header_Scredit_Tbl(1).salesrep_id;
        x_salesrep := l_Header_Scredit_val_rec.salesrep;
    END IF;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).sales_credit_type_id,
                            l_Header_Scredit_rec.sales_credit_type_id)
    THEN
        x_sales_credit_type_id := l_x_Header_Scredit_Tbl(1).sales_credit_type_id;
        x_sales_credit_type := l_Header_Scredit_val_rec.sales_credit_type;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).sales_credit_id,
                            l_Header_Scredit_rec.sales_credit_id)
    THEN
        x_sales_credit_id := l_x_Header_Scredit_Tbl(1).sales_credit_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).wh_update_date,
                            l_Header_Scredit_rec.wh_update_date)
    THEN
        x_wh_update_date := l_x_Header_Scredit_Tbl(1).wh_update_date;
    END IF;

    --SG{

    IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).sales_group_id,
                            l_Header_Scredit_rec.sales_group_id)
    THEN
        x_sales_group_id := l_x_Header_Scredit_Tbl(1).sales_group_id;
        x_sales_group    := l_Header_Scredit_val_rec.sales_group;
        oe_debug_pub.add('OEXFHSCB2--x_sales_group:'||x_sales_group);
    END IF;

     IF NOT OE_GLOBALS.Equal(l_x_Header_Scredit_Tbl(1).sales_group_updated_flag,
                            l_Header_Scredit_rec.sales_group_updated_flag)
    THEN
        x_sales_group_updated_flag    := l_Header_Scredit_rec.sales_group_updated_flag;
    END IF;
    --SG}

    --  Write to cache.

    Write_Header_Scredit
    (   p_Header_Scredit_rec          => l_x_Header_Scredit_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.CHANGE_ATTRIBUTE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
,   p_change_reason_code            IN  VARCHAR2
,   p_change_comments               IN  VARCHAR2
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

)
IS
l_x_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Header_Scredit from cache
    Get_Header_Scredit
    (   p_db_record                   => TRUE
    ,   p_sales_credit_id             => p_sales_credit_id
    ,   x_header_scredit_rec          => l_x_old_Header_Scredit_tbl(1)
    );


    Get_Header_Scredit
    (   p_db_record                   => FALSE
    ,   p_sales_credit_id             => p_sales_credit_id
    ,   x_header_scredit_rec          => l_x_Header_Scredit_tbl(1)
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_Header_Scredit_tbl(1).db_flag) THEN
        l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    /* Start Audit Trail -- Pass change reason, comments */
    l_x_Header_Scredit_tbl(1).change_reason := p_change_reason_code;
    l_x_Header_Scredit_tbl(1).change_comments := p_change_comments;
    /* End Audit Trail */

    --  Populate Header_Scredit table

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Header_Scredits
    (   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                   => l_control_rec
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   p_x_old_Header_Scredit_tbl      => l_x_old_Header_Scredit_tbl
    ,   x_return_status                 => l_return_status
    );

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT NOCOPY parameters.
  /* Enable the call for Pre-Pack H Code level */

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => FALSE
    ,   p_init_msg_list               => FND_API.G_FALSE
    ,   p_notify                     => TRUE
    ,   x_return_status              => l_return_status
    ,   p_header_scredit_tbl         => l_x_Header_Scredit_tbl
    ,   p_old_header_scredit_tbl   => l_x_old_Header_Scredit_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    END IF;

    x_creation_date                := l_x_Header_Scredit_tbl(1).creation_date;
    x_created_by                   := l_x_Header_Scredit_tbl(1).created_by;
    x_last_update_date             := l_x_Header_Scredit_tbl(1).last_update_date;
    x_last_updated_by              := l_x_Header_Scredit_tbl(1).last_updated_by;
    x_last_update_login            := l_x_Header_Scredit_tbl(1).last_update_login;
    x_lock_control                 := l_x_Header_Scredit_tbl(1).lock_control;

    --  Clear Header_Scredit record cache

    Clear_Header_Scredit;

    --  Keep track of performed operations.

--    l_old_Header_Scredit_rec.operation := l_Header_Scredit_rec.operation;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_Old_Header_Scredit_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.DELETE_ROW' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    Get_Header_Scredit
    (   p_db_record                   => TRUE
    ,   p_sales_credit_id             => p_sales_credit_id
    ,   x_header_scredit_rec          => l_x_Header_Scredit_tbl(1)
    );

    --  Set Operation.

    l_x_Header_Scredit_tbl(1).operation := OE_GLOBALS.G_OPR_DELETE;
    l_x_Header_Scredit_tbl(1).change_reason := p_change_reason_code;
    l_x_Header_Scredit_tbl(1).change_comments := p_change_comments;

    --  Populate Header_Scredit table


    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Header_Scredits
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_old_Header_Scredit_tbl    => l_x_old_Header_Scredit_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Header_Scredit record cache

    Clear_Header_Scredit;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
/*l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type; */

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.PROCESS_ENTITY' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

/*  l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_HEADER_SCREDIT;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents   := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl        => l_x_action_request_tbl
    ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl

    );
*/
    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_TRUE
     ,  p_notify                     => FALSE   --jolin
     ,  x_return_status              => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.PROCESS_ENTITY' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sales_credit_id               IN  NUMBER
,   p_lock_control                  IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_x_Header_Scredit_rec          OE_Order_PUB.Header_Scredit_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load Header_Scredit record

    l_x_Header_Scredit_rec.operation    :=  OE_GLOBALS.G_OPR_LOCK;
    l_x_Header_Scredit_rec.sales_credit_id :=   p_sales_credit_id      ;
    l_x_Header_Scredit_rec.lock_control :=  p_lock_control;

    --  Call oe_headers_scredits_util.lock_row instead of OE_Order_PVT.Lock_order

    OE_Header_Scredit_Util.Lock_Row
    (   x_return_status           => l_return_status
    ,   p_x_header_Scredit_rec    => l_x_header_Scredit_rec );
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Header_Scredit_rec.db_flag := FND_API.G_TRUE;

        Write_Header_Scredit
        (   p_Header_Scredit_rec          => l_x_Header_Scredit_rec
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
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

--  Procedures maintaining Header_Scredit record cache.

PROCEDURE Write_Header_Scredit
(   p_Header_Scredit_rec            IN  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.WRITE_HEADER_SCREDIT' , 1 ) ;
    END IF;

    g_Header_Scredit_rec := p_Header_Scredit_rec;

    IF p_db_record THEN

        g_db_Header_Scredit_rec := p_Header_Scredit_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.WRITE_HEADER_SCREDIT' , 1 ) ;
    END IF;

END Write_Header_Scredit;

PROCEDURE Get_Header_Scredit
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_sales_credit_id               IN  NUMBER
,   x_header_scredit_rec            OUT NOCOPY OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.GET_HEADER_SCREDIT' , 1 ) ;
    END IF;

    IF  p_sales_credit_id <> NVL(g_Header_Scredit_rec.sales_credit_id,-1)
    THEN

        --  Query row from DB

        OE_Header_Scredit_Util.Query_Row
        (   p_sales_credit_id             => p_sales_credit_id
	    ,  x_header_scredit_rec          => g_Header_Scredit_rec
        );

        g_Header_Scredit_rec.db_flag   := FND_API.G_TRUE;

        --  Load DB record

        g_db_Header_Scredit_rec        := g_Header_Scredit_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.GET_HEADER_SCREDIT' , 1 ) ;
    END IF;

    IF p_db_record THEN

        x_header_scredit_rec:= g_db_Header_Scredit_rec;

    ELSE

        x_header_scredit_rec:= g_Header_Scredit_rec;

    END IF;

END Get_Header_Scredit;

PROCEDURE Clear_Header_Scredit
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_SCREDIT.CLEAR_HEADER_SCREDIT' , 1 ) ;
    END IF;

    g_Header_Scredit_rec           := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;
    g_db_Header_Scredit_rec        := OE_Order_PUB.G_MISS_HEADER_SCREDIT_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_SCREDIT.CLEAR_HEADER_SCREDIT' , 1 ) ;
    END IF;

END Clear_Header_Scredit;

--SG{
Procedure Get_Values(p_header_scredit_rec      IN OE_Order_PUB.Header_Scredit_Rec_Type
                     ,x_header_scredit_val_rec OUT NOCOPY OE_Order_PUB.Header_Scredit_Val_Rec_Type) AS
BEGIN
  x_header_scredit_val_rec:=OE_Header_Scredit_Util.Get_Values(p_header_scredit_rec);
END;
--SG}

END OE_OE_Form_Header_Scredit;

/
