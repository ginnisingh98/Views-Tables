--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_LINE" AS
/* $Header: OEHFLINB.pls 120.0 2005/05/31 23:36:46 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Html_Line';

--  Global variables holding cached record.

g_line_rec                    OE_Order_PUB.Line_Rec_Type;
g_db_line_rec                 OE_Order_PUB.Line_Rec_Type;


--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   x_line_Rec                      IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_line_val_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Rec_Type
,   p_header_Rec                    IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type

)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_error NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

x_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
x_old_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
 x_line_val_tbl                 OE_ORDER_PUB.Line_Val_Tbl_Type;
l_fname varchar2(1000);
BEGIN

    oe_debug_pub.g_debug_level := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
    l_fname := oe_Debug_pub.set_debug_mode('FILE');

    oe_debug_pub.debug_on;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING Oe_Oe_Html_Line.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

  l_error := 1;
    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;
    OE_GLOBALS.G_HTML_FLAG := TRUE;

    OE_PORTAL_UTIL.SET_HEADER_CACHE(p_header_Rec);
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := FALSE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := TRUE;
    l_control_rec.clear_api_requests   := TRUE;

    --  Load IN parameters if any exist
    x_old_line_tbl(1)     :=OE_ORDER_PUB.G_MISS_LINE_REC;
    x_line_tbl(1)         :=OE_ORDER_PUB.G_MISS_LINE_REC;
    x_line_tbl(1).header_id                := p_header_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    x_line_tbl(1).attribute1                         := NULL;
    x_line_tbl(1).attribute10                        := NULL;
    x_line_tbl(1).attribute11                        := NULL;
    x_line_tbl(1).attribute12                        := NULL;
    x_line_tbl(1).attribute13                        := NULL;
    x_line_tbl(1).attribute14                        := NULL;
    x_line_tbl(1).attribute15                        := NULL;
    x_line_tbl(1).attribute2                         := NULL;
    x_line_tbl(1).attribute3                         := NULL;
    x_line_tbl(1).attribute4                         := NULL;
    x_line_tbl(1).attribute5                         := NULL;
    x_line_tbl(1).attribute6                         := NULL;
    x_line_tbl(1).attribute7                         := NULL;
    x_line_tbl(1).attribute8                         := NULL;
    x_line_tbl(1).attribute9                         := NULL;
    x_line_tbl(1).context                            := NULL;
    x_line_tbl(1).global_attribute1                  := NULL;
    x_line_tbl(1).global_attribute10                 := NULL;
    x_line_tbl(1).global_attribute11                 := NULL;
    x_line_tbl(1).global_attribute12                 := NULL;
    x_line_tbl(1).global_attribute13                 := NULL;
    x_line_tbl(1).global_attribute14                 := NULL;
    x_line_tbl(1).global_attribute15                 := NULL;
    x_line_tbl(1).global_attribute16                 := NULL;
    x_line_tbl(1).global_attribute17                 := NULL;
    x_line_tbl(1).global_attribute18                 := NULL;
    x_line_tbl(1).global_attribute19                 := NULL;
    x_line_tbl(1).global_attribute2                  := NULL;
    x_line_tbl(1).global_attribute20                 := NULL;
    x_line_tbl(1).global_attribute3                  := NULL;
    x_line_tbl(1).global_attribute4                  := NULL;
    x_line_tbl(1).global_attribute5                  := NULL;
    x_line_tbl(1).global_attribute6                  := NULL;
    x_line_tbl(1).global_attribute7                  := NULL;
    x_line_tbl(1).global_attribute8                  := NULL;
    x_line_tbl(1).global_attribute9                  := NULL;
    x_line_tbl(1).global_attribute_category          := NULL;
    x_line_tbl(1).industry_attribute1                := NULL;
    x_line_tbl(1).industry_attribute10               := NULL;
    x_line_tbl(1).industry_attribute11               := NULL;
    x_line_tbl(1).industry_attribute12               := NULL;
    x_line_tbl(1).industry_attribute13               := NULL;
    x_line_tbl(1).industry_attribute14               := NULL;
    x_line_tbl(1).industry_attribute15               := NULL;
    x_line_tbl(1).industry_attribute16               := NULL;
    x_line_tbl(1).industry_attribute17               := NULL;
    x_line_tbl(1).industry_attribute18               := NULL;
    x_line_tbl(1).industry_attribute19               := NULL;
    x_line_tbl(1).industry_attribute2                := NULL;
    x_line_tbl(1).industry_attribute20               := NULL;
    x_line_tbl(1).industry_attribute21               := NULL;
    x_line_tbl(1).industry_attribute22               := NULL;
    x_line_tbl(1).industry_attribute23               := NULL;
    x_line_tbl(1).industry_attribute24               := NULL;
    x_line_tbl(1).industry_attribute25               := NULL;
    x_line_tbl(1).industry_attribute26               := NULL;
    x_line_tbl(1).industry_attribute27               := NULL;
    x_line_tbl(1).industry_attribute28               := NULL;
    x_line_tbl(1).industry_attribute29               := NULL;
    x_line_tbl(1).industry_attribute3                := NULL;
    x_line_tbl(1).industry_attribute30               := NULL;
    x_line_tbl(1).industry_attribute4                := NULL;
    x_line_tbl(1).industry_attribute5                := NULL;
    x_line_tbl(1).industry_attribute6                := NULL;
    x_line_tbl(1).industry_attribute7                := NULL;
    x_line_tbl(1).industry_attribute8                := NULL;
    x_line_tbl(1).industry_attribute9                := NULL;
    x_line_tbl(1).industry_context                   := NULL;
    x_line_tbl(1).pricing_attribute1                 := NULL;
    x_line_tbl(1).pricing_attribute10                := NULL;
    x_line_tbl(1).pricing_attribute2                 := NULL;
    x_line_tbl(1).pricing_attribute3                 := NULL;
    x_line_tbl(1).pricing_attribute4                 := NULL;
    x_line_tbl(1).pricing_attribute5                 := NULL;
    x_line_tbl(1).pricing_attribute6                 := NULL;
    x_line_tbl(1).pricing_attribute7                 := NULL;
    x_line_tbl(1).pricing_attribute8                 := NULL;
    x_line_tbl(1).pricing_attribute9                 := NULL;
    x_line_tbl(1).pricing_context                    := NULL;
    x_line_tbl(1).return_attribute1                  := NULL;
    x_line_tbl(1).return_attribute10                 := NULL;
    x_line_tbl(1).return_attribute11                 := NULL;
    x_line_tbl(1).return_attribute12                 := NULL;
    x_line_tbl(1).return_attribute13                 := NULL;
    x_line_tbl(1).return_attribute14                 := NULL;
    x_line_tbl(1).return_attribute15                 := NULL;
    x_line_tbl(1).return_attribute2                  := NULL;
    x_line_tbl(1).return_attribute3                  := NULL;
    x_line_tbl(1).return_attribute4                  := NULL;
    x_line_tbl(1).return_attribute5                  := NULL;
    x_line_tbl(1).return_attribute6                  := NULL;
    x_line_tbl(1).return_attribute7                  := NULL;
    x_line_tbl(1).return_attribute8                  := NULL;
    x_line_tbl(1).return_attribute9                  := NULL;
    x_line_tbl(1).return_context                     := NULL;
    x_line_tbl(1).tp_attribute1                         := NULL;
    x_line_tbl(1).tp_attribute10                        := NULL;
    x_line_tbl(1).tp_attribute11                        := NULL;
    x_line_tbl(1).tp_attribute12                        := NULL;
    x_line_tbl(1).tp_attribute13                        := NULL;
    x_line_tbl(1).tp_attribute14                        := NULL;
    x_line_tbl(1).tp_attribute15                        := NULL;
    x_line_tbl(1).tp_attribute2                         := NULL;
    x_line_tbl(1).tp_attribute3                         := NULL;
    x_line_tbl(1).tp_attribute4                         := NULL;
    x_line_tbl(1).tp_attribute5                         := NULL;
    x_line_tbl(1).tp_attribute6                         := NULL;
    x_line_tbl(1).tp_attribute7                         := NULL;
    x_line_tbl(1).tp_attribute8                         := NULL;
    x_line_tbl(1).tp_attribute9                         := NULL;
    x_line_tbl(1).tp_context                            := NULL;

    --  Set Operation to Create

  l_error := 2;
    x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate line table


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - CALLING PROCESS' , 2 ) ;
    END IF;

    --  Call Oe_Order_Pvt.Process_order

  l_error := 3;


    Oe_Order_Pvt.Lines
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_x_old_line_tbl              => x_old_line_tbl
    ,   x_return_status               => l_return_status
    );

  l_error := 3;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - AFTER PROCESS' , 2 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    x_line_rec := x_line_tbl(1);


    --  Load display out parameters if any
     x_line_val_rec:=OE_ORDER_PUB.G_MISS_LINE_VAL_REC;
     x_line_val_rec:=OE_Line_Util.Get_Values
    (   p_line_rec                    => x_line_tbl(1)
    );
    --  Set db_flag to False before writing to cache

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - CALLING WRITE LINE' , 2 ) ;
    END IF;

    x_line_tbl(1).db_flag := FND_API.G_FALSE;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING Oe_Oe_Html_Line.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes' || l_error
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
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
,   p_line_id                       IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   p_reason			    IN  VARCHAR2
,   p_comments			    IN  VARCHAR2
,   x_line_Rec                      IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_old_line_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Rec_Type
,   x_line_val_rec                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Rec_Type



)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_order_date_type_code        VARCHAR2(30) := null;
l_orig_ship_from_org_id       OE_Order_LINES.ship_from_org_id%TYPE;
l_x_item_rec_type             OE_ORDER_CACHE.item_rec_type;    -- OPM 2/JUN/00
file_name varchar2(100);
i						pls_Integer;
L_PRICE_CONTROL_REC			QP_PREQ_GRP.control_record_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

x_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
x_old_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
x_line_val_tbl                 OE_ORDER_PUB.Line_Val_Tbl_Type;
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING Oe_Oe_Html_Line.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;


    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read line from cache




    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SETTING OPERATION' , 2 ) ;
    END IF;

    x_line_tbl(1):=x_line_Rec;
    x_old_line_tbl(1):=x_old_line_Rec;

    IF FND_API.To_Boolean(x_line_tbl(1).db_flag) THEN
        x_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;
        x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate line table
    --  Validate Scheduling Dates Changes, if any.


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' , 2 ) ;
        oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER' , 1 ) ;
    END IF;

    --  Call Oe_Order_Pvt.Process_order
    Oe_Order_Pvt.Lines
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_x_old_line_tbl              => x_old_line_tbl
    ,   x_return_status               => l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS ORDER RETURN UNEXP_ERROR' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS ORDER RETURN RET_STS_ERROR' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl


    --  Init OUT parameters to missing.

    --  Load display out parameters if any

     x_line_val_tbl(1):=OE_Line_Util.Get_Values
    (   p_line_rec                    => x_line_tbl(1)
    ,   p_old_line_rec                => x_old_line_tbl(1)
    );


    --  Write to cache.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WRITING TO CACHE' , 2 ) ;
    END IF;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data
    x_line_rec:=x_line_tbl(1);
    x_old_line_rec:=x_old_line_tbl(1);
    x_line_val_rec:=x_line_val_tbl(1);

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING Oe_Oe_Html_Line.CHANGE_ATTRIBUTE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;


--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
)
IS
l_x_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_x_old_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SAVEPOINT LINE_DELETE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING Oe_Oe_Html_Line.DELETE_ROW' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security	    := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;



    --  Set Operation.

    l_x_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate line table

    l_x_line_tbl(1) := l_x_line_rec;
    l_x_line_tbl(1).change_reason := p_change_reason_code;
    l_x_line_tbl(1).change_comments := p_change_comments;

    --  Call Oe_Order_Pvt.Process_order

    Oe_Order_Pvt.Lines
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_old_line_tbl              => l_x_old_line_tbl
    ,   x_return_status               => l_return_status

    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Clear line record cache


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING Oe_Oe_Html_Line.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SAVEPOINT Line_Delete;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SAVEPOINT Line_Delete;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT Line_Delete;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;


--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_lock_control                  IN  NUMBER
)

IS
l_return_status               VARCHAR2(1);
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING Oe_Oe_Html_Line.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load line record

    l_x_line_rec.lock_control        := p_lock_control;
    l_x_line_rec.line_id             := p_line_id;
    l_x_line_rec.operation           := OE_GLOBALS.G_OPR_LOCK; -- not req.

    --Bug 3025978
      OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Call OE_Line_Util.Lock_Row instead of Oe_Order_Pvt.Lock_order
    OE_MSG_PUB.initialize;
    OE_Line_Util.Lock_Row
    ( x_return_status         => l_return_status
    , p_x_line_rec            => l_x_line_rec
    , p_line_id               => p_line_id);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_line_rec.db_flag := FND_API.G_TRUE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING Oe_Oe_Html_Line.LOCK_ROW'||L_X_LINE_REC.LINE_ID , 1 ) ;
    END IF;


    END IF;

    --  Set return status.

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING Oe_Oe_Html_Line.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

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

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;


-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                     IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 l_new_line_rec     OE_Order_PUB.Line_Rec_Type; --3445778
 l_old_line_rec     OE_Order_PUB.Line_Rec_Type; --3445778
 l_index            NUMBER;  --3445778
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
                         p_entity_code  => OE_GLOBALS.G_ENTITY_LINE
                         ,p_entity_id    => p_line_id
                         ,x_return_status => l_return_status);

    -- Added for bug 3445778
    oe_debug_pub.add('Executing code for updating global picture, line_id: ' || p_line_id, 1);

    -- Set the operation on the record so that globals are updated
     l_new_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_line_rec.line_id := p_line_id;
     l_old_line_rec.line_id := p_line_id;

      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_rec => l_new_line_rec,
                    p_line_id => p_line_id,
                    p_old_line_rec => l_old_line_rec,
                    x_index => l_index,
                    x_return_status => l_return_status);

    -- End of 3445778

    OE_MSG_PUB.Count_And_Get
	  (   p_count                       => x_msg_count
		,   p_data                        => x_msg_data
	   );

   -- Clear the controller cache, so that it will not be used for
   -- next operation on same record


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


END Oe_Oe_Html_Line;

/
