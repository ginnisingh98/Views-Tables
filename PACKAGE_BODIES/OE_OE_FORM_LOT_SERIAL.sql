--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_LOT_SERIAL" AS
/* $Header: OEXFSRLB.pls 120.0 2005/05/31 22:34:38 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Lot_Serial';

--  Global variables holding cached record.

g_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
g_db_Lot_Serial_rec           OE_Order_PUB.Lot_Serial_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Lot_Serial
(   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE Get_Lot_Serial
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_lot_serial_id                 IN  NUMBER
,   x_lot_serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
);

PROCEDURE Clear_Lot_Serial;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Lot_Serial_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_line_id                       IN  NUMBER
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

, x_from_serial_number OUT NOCOPY VARCHAR2

, x_line_id OUT NOCOPY NUMBER

, x_lot_number OUT NOCOPY VARCHAR2

-- , x_sublot_number OUT NOCOPY VARCHAR2 --OPM 2380194 INVCONV

, x_lot_serial_id OUT NOCOPY NUMBER

, x_quantity OUT NOCOPY NUMBER

, x_quantity2 OUT NOCOPY NUMBER --OPM 2380194

, x_to_serial_number OUT NOCOPY VARCHAR2

, x_line OUT NOCOPY VARCHAR2

, x_lot_serial OUT NOCOPY VARCHAR2

)
IS
l_x_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_Lot_Serial_val_rec          OE_Order_PUB.Lot_Serial_Val_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_old_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Lot_Serial_val_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

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
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOT_SERIAL LINE_ID'||P_LINE_ID , 1 ) ;
    END IF;
    l_x_Lot_Serial_rec:=OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
    l_x_Old_Lot_Serial_Tbl(1):=OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
    l_x_Lot_Serial_rec.line_id := p_line_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_x_lot_serial_rec.attribute1                   := NULL;
    l_x_lot_serial_rec.attribute10                  := NULL;
    l_x_lot_serial_rec.attribute11                  := NULL;
    l_x_lot_serial_rec.attribute12                  := NULL;
    l_x_lot_serial_rec.attribute13                  := NULL;
    l_x_lot_serial_rec.attribute14                  := NULL;
    l_x_lot_serial_rec.attribute15                  := NULL;
    l_x_lot_serial_rec.attribute2                   := NULL;
    l_x_lot_serial_rec.attribute3                   := NULL;
    l_x_lot_serial_rec.attribute4                   := NULL;
    l_x_lot_serial_rec.attribute5                   := NULL;
    l_x_lot_serial_rec.attribute6                   := NULL;
    l_x_lot_serial_rec.attribute7                   := NULL;
    l_x_lot_serial_rec.attribute8                   := NULL;
    l_x_lot_serial_rec.attribute9                   := NULL;
    l_x_lot_serial_rec.context                      := NULL;

    --  Set Operation to Create

    l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Lot_Serial table

    l_x_Lot_Serial_tbl(1) := l_x_Lot_Serial_rec;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOT_SERIAL CONTROLLER - DEFAULT ATTRIBUTES - CALLING PROCESS' , 2 ) ;
    END IF;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lot_Serials
    (   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
     ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_old_Lot_Serial_tbl        => l_x_old_Lot_Serial_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_Lot_Serial_rec := l_x_Lot_Serial_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_Lot_Serial_rec.attribute1;
    x_attribute10                  := l_x_Lot_Serial_rec.attribute10;
    x_attribute11                  := l_x_Lot_Serial_rec.attribute11;
    x_attribute12                  := l_x_Lot_Serial_rec.attribute12;
    x_attribute13                  := l_x_Lot_Serial_rec.attribute13;
    x_attribute14                  := l_x_Lot_Serial_rec.attribute14;
    x_attribute15                  := l_x_Lot_Serial_rec.attribute15;
    x_attribute2                   := l_x_Lot_Serial_rec.attribute2;
    x_attribute3                   := l_x_Lot_Serial_rec.attribute3;
    x_attribute4                   := l_x_Lot_Serial_rec.attribute4;
    x_attribute5                   := l_x_Lot_Serial_rec.attribute5;
    x_attribute6                   := l_x_Lot_Serial_rec.attribute6;
    x_attribute7                   := l_x_Lot_Serial_rec.attribute7;
    x_attribute8                   := l_x_Lot_Serial_rec.attribute8;
    x_attribute9                   := l_x_Lot_Serial_rec.attribute9;
    x_context                      := l_x_Lot_Serial_rec.context;
    x_from_serial_number           := l_x_Lot_Serial_rec.from_serial_number;
    x_line_id                      := l_x_Lot_Serial_rec.line_id;
    x_lot_number                   := l_x_Lot_Serial_rec.lot_number;
--    x_sublot_number                := l_x_Lot_Serial_rec.sublot_number; --OPM 2380194  INVCONV
    x_lot_serial_id                := l_x_Lot_Serial_rec.lot_serial_id;
    x_quantity                     := l_x_Lot_Serial_rec.quantity;
    x_quantity2                    := l_x_Lot_Serial_rec.quantity2; -- OPM 2380194
    x_to_serial_number             := l_x_Lot_Serial_rec.to_serial_number;

    --  Load display out parameters if any

    l_Lot_Serial_val_rec := OE_Lot_Serial_Util.Get_Values
    (   p_Lot_Serial_rec              => l_x_Lot_Serial_rec
    );
    x_line                         := l_Lot_Serial_val_rec.line;
    x_lot_serial                   := l_Lot_Serial_val_rec.lot_serial;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Lot_Serial_rec.db_flag := FND_API.G_FALSE;

    Write_Lot_Serial
    (   p_Lot_Serial_rec              => l_x_Lot_Serial_rec
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LOT_SERIAL.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
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

, x_from_serial_number OUT NOCOPY VARCHAR2

, x_line_id OUT NOCOPY NUMBER

, x_lot_number OUT NOCOPY VARCHAR2

-- , x_sublot_number OUT NOCOPY VARCHAR2 --OPM 2380194  invconv

, x_lot_serial_id OUT NOCOPY NUMBER

, x_quantity OUT NOCOPY NUMBER

, x_quantity2 OUT NOCOPY NUMBER   --OPM 2380194

, x_to_serial_number OUT NOCOPY VARCHAR2

, x_line OUT NOCOPY VARCHAR2

, x_lot_serial OUT NOCOPY VARCHAR2

)
IS
l_old_Lot_Serial_rec          OE_Order_PUB.Lot_Serial_Rec_Type;
l_Lot_Serial_val_rec          OE_Order_PUB.Lot_Serial_Val_Rec_Type;
l_x_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LOT_SERIAL.CHANGE_ATTRIBUTES' , 1 ) ;
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
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LOT_SERIAL;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Lot_Serial from cache

     Get_Lot_Serial
    (   p_db_record                   => FALSE
    ,   p_lot_serial_id               => p_lot_serial_id
    ,   x_lot_serial_rec              => l_x_Lot_Serial_rec
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CHANGE_ATTRIBUTES ATTR VALUE'||P_ATTR_VALUE , 1 ) ;
    END IF;

    l_old_Lot_Serial_rec := l_x_Lot_Serial_rec;

    IF p_attr_id = OE_Lot_Serial_Util.G_FROM_SERIAL_NUMBER THEN
        l_x_lot_serial_rec.from_serial_number := p_attr_value;
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_LINE THEN
        l_x_lot_serial_rec.line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_LOT_NUMBER THEN
        l_x_lot_serial_rec.lot_number := p_attr_value;
    /*ELSIF p_attr_id = OE_Lot_Serial_Util.G_SUBLOT_NUMBER THEN --OPM 2380194 INVCONV
        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   	 THEN
            l_x_lot_serial_rec.sublot_number := p_attr_value;
         END IF;    */
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_LOT_SERIAL THEN
        l_x_lot_serial_rec.lot_serial_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_QUANTITY THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN QUANTITY CHANGE' , 1 ) ;
    END IF;
        l_x_lot_serial_rec.quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_QUANTITY2 THEN     --OPM 2380194
    	IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   	 THEN
    		l_x_lot_serial_rec.quantity2 := TO_NUMBER(p_attr_value);
    	END IF;
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_TO_SERIAL_NUMBER THEN
        l_x_lot_serial_rec.to_serial_number := p_attr_value;
    ELSIF p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Lot_Serial_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Lot_Serial_Util.G_CONTEXT
    THEN

        l_x_lot_serial_rec.attribute1    := p_attribute1;
        l_x_lot_serial_rec.attribute10   := p_attribute10;
        l_x_lot_serial_rec.attribute12   := p_attribute12;
        l_x_lot_serial_rec.attribute13   := p_attribute13;
        l_x_lot_serial_rec.attribute14   := p_attribute14;
        l_x_lot_serial_rec.attribute15   := p_attribute15;
        l_x_lot_serial_rec.attribute2    := p_attribute2;
        l_x_lot_serial_rec.attribute3    := p_attribute3;
        l_x_lot_serial_rec.attribute4    := p_attribute4;
        l_x_lot_serial_rec.attribute5    := p_attribute5;
        l_x_lot_serial_rec.attribute6    := p_attribute6;
        l_x_lot_serial_rec.attribute7    := p_attribute7;
        l_x_lot_serial_rec.attribute8    := p_attribute8;
        l_x_lot_serial_rec.attribute9    := p_attribute9;
        l_x_lot_serial_rec.context       := p_context;

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
    IF FND_API.To_Boolean(l_x_Lot_Serial_rec.db_flag) THEN
        l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Lot_Serial table
    l_x_Lot_Serial_tbl(1) := l_x_Lot_Serial_rec;
    l_x_old_Lot_Serial_tbl(1) := l_old_Lot_Serial_rec;

    --  Call OE_Order_PVT.Process_order

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING OE_ORDER_PVT.LOT_SERIALS'||TO_CHAR ( L_X_LOT_SERIAL_TBL ( 1 ) .QUANTITY ) , 1 ) ;
  END IF;
    OE_Order_PVT.Lot_Serials
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_old_Lot_Serial_tbl        => l_x_old_Lot_Serial_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING OE_ORDER_PVT.LOT_SERIALS'||TO_CHAR ( L_X_LOT_SERIAL_TBL ( 1 ) .QUANTITY ) , 1 ) ;
  END IF;

    --  Unload out tbl

    l_x_Lot_Serial_rec := l_x_Lot_Serial_tbl(1);

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
    x_context                      := FND_API.G_MISS_CHAR;
    x_from_serial_number           := FND_API.G_MISS_CHAR;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_lot_number                   := FND_API.G_MISS_CHAR;
--    x_sublot_number                := FND_API.G_MISS_CHAR; --OPM 2380194     INVCONV
    x_lot_serial_id                := FND_API.G_MISS_NUM;
    x_quantity                     := FND_API.G_MISS_NUM;
    x_quantity2                    := FND_API.G_MISS_NUM;  --OPM 2380194
    x_to_serial_number             := FND_API.G_MISS_CHAR;
    x_line                         := FND_API.G_MISS_CHAR;
    x_lot_serial                   := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_Lot_Serial_val_rec := OE_Lot_Serial_Util.Get_Values
    (   p_Lot_Serial_rec              => l_x_Lot_Serial_rec
    ,   p_old_Lot_Serial_rec          => l_old_Lot_Serial_rec
    );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING OE_LOT_SERIAL_UTIL.GET_VALUES' , 1 ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUANTITY '||TO_CHAR ( L_X_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD QUANTITY '||TO_CHAR ( L_OLD_LOT_SERIAL_REC.QUANTITY ) , 1 ) ;
  END IF;
    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute1,
                            l_old_lot_serial_rec.attribute1)
    THEN
        x_attribute1 := l_x_Lot_Serial_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute10,
                            l_old_lot_serial_rec.attribute10)
    THEN
        x_attribute10 := l_x_Lot_Serial_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute11,
                            l_old_lot_serial_rec.attribute11)
    THEN
        x_attribute11 := l_x_Lot_Serial_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute12,
                            l_old_lot_serial_rec.attribute12)
    THEN
        x_attribute12 := l_x_Lot_Serial_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute13,
                            l_old_lot_serial_rec.attribute13)
    THEN
        x_attribute13 := l_x_Lot_Serial_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute14,
                            l_old_lot_serial_rec.attribute14)
    THEN
        x_attribute14 := l_x_Lot_Serial_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute15,
                            l_old_lot_serial_rec.attribute15)
    THEN
        x_attribute15 := l_x_Lot_Serial_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute2,
                            l_old_lot_serial_rec.attribute2)
    THEN
        x_attribute2 := l_x_Lot_Serial_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute3,
                            l_old_lot_serial_rec.attribute3)
    THEN
        x_attribute3 := l_x_Lot_Serial_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute4,
                            l_old_lot_serial_rec.attribute4)
    THEN
        x_attribute4 := l_x_Lot_Serial_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute5,
                            l_old_lot_serial_rec.attribute5)
    THEN
        x_attribute5 := l_x_Lot_Serial_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute6,
                            l_old_lot_serial_rec.attribute6)
    THEN
        x_attribute6 := l_x_Lot_Serial_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute7,
                            l_old_lot_serial_rec.attribute7)
    THEN
        x_attribute7 := l_x_Lot_Serial_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute8,
                            l_old_lot_serial_rec.attribute8)
    THEN
        x_attribute8 := l_x_Lot_Serial_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.attribute9,
                            l_old_lot_serial_rec.attribute9)
    THEN
        x_attribute9 := l_x_Lot_Serial_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.context,
                            l_old_lot_serial_rec.context)
    THEN
        x_context := l_x_Lot_Serial_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.from_serial_number,
                            l_old_lot_serial_rec.from_serial_number)
    THEN
        x_from_serial_number := l_x_Lot_Serial_rec.from_serial_number;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.line_id,
                            l_old_lot_serial_rec.line_id)
    THEN
        x_line_id := l_x_Lot_Serial_rec.line_id;
        x_line := l_Lot_Serial_val_rec.line;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.lot_number,
                            l_old_lot_serial_rec.lot_number)
    THEN
        x_lot_number := l_x_Lot_Serial_rec.lot_number;
    END IF;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
   	 THEN

    		/*IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.sublot_number,  --OPM 2380194 INVCONV
                	            l_old_lot_serial_rec.sublot_number)
    		THEN
        		x_sublot_number := l_x_Lot_Serial_rec.sublot_number;
    		END IF; */

                IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.quantity2,   --OPM 2380194
                            l_old_lot_serial_rec.quantity2)
    			THEN
        			IF l_debug_level  > 0 THEN
	   				oe_debug_pub.add('The Quantity2 Has Changed', 1);
				END IF;
        		        x_quantity2 := l_x_Lot_Serial_rec.quantity2;
    		END IF;

    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.lot_serial_id,
                            l_old_lot_serial_rec.lot_serial_id)
    THEN
        x_lot_serial_id := l_x_Lot_Serial_rec.lot_serial_id;
        x_lot_serial := l_Lot_Serial_val_rec.lot_serial;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.quantity,
                            l_old_lot_serial_rec.quantity)
    THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'THE QUANTITY HAS CHANGED' , 1 ) ;
	   END IF;
        x_quantity := l_x_Lot_Serial_rec.quantity;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Lot_Serial_rec.to_serial_number,
                            l_old_lot_serial_rec.to_serial_number)
    THEN
        x_to_serial_number := l_x_Lot_Serial_rec.to_serial_number;
    END IF;


    --  Write to cache.

    Write_Lot_Serial
    (   p_Lot_Serial_rec              => l_x_Lot_Serial_rec
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LOT_SERIAL.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

)
IS
l_x_old_Lot_Serial_rec          OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LOT_SERIAL.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LOT_SERIAL;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Lot_Serial from cache

    Get_Lot_Serial
    (   p_db_record                   => TRUE
    ,   p_lot_serial_id               => p_lot_serial_id
    ,   x_lot_serial_rec              => l_x_old_Lot_Serial_rec
    );

    Get_Lot_Serial
    (   p_db_record                   => FALSE
    ,   p_lot_serial_id               => p_lot_serial_id
    ,   x_lot_serial_rec              => l_x_Lot_Serial_rec
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_Lot_Serial_rec.db_flag) THEN
        l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Lot_Serial table

    l_x_Lot_Serial_tbl(1) := l_x_Lot_Serial_rec;
    l_x_old_Lot_Serial_tbl(1) := l_x_old_Lot_Serial_rec;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lot_Serials
    (   p_validation_level              =>FND_API.G_VALID_LEVEL_FULL
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                   => l_control_rec
    ,   p_x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,   p_x_old_Lot_Serial_tbl          => l_x_old_Lot_Serial_tbl
    ,   x_return_status                 => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
/* The Process Requests and Notify call should be there for */
/* Pre-Pack code level */

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => FALSE
	,   p_init_msg_list               => FND_API.G_FALSE
     ,  p_notify                     => TRUE
     ,  x_return_status              => l_return_status
     ,  p_Lot_Serial_Tbl             => l_x_Lot_Serial_Tbl
     ,  p_Old_Lot_Serial_Tbl         => l_x_old_Lot_Serial_Tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   END IF;

    --  Load OUT parameters.

    l_x_Lot_Serial_rec := l_x_Lot_Serial_tbl(1);

    x_creation_date                := l_x_Lot_Serial_rec.creation_date;
    x_created_by                   := l_x_Lot_Serial_rec.created_by;
    x_last_update_date             := l_x_Lot_Serial_rec.last_update_date;
    x_last_updated_by              := l_x_Lot_Serial_rec.last_updated_by;
    x_last_update_login            := l_x_Lot_Serial_rec.last_update_login;
    x_lock_control                 :=  l_x_Lot_Serial_rec.lock_control;

    --  Clear Lot_Serial record cache

    Clear_Lot_Serial;

    --  Keep track of performed operations.

    l_x_old_Lot_Serial_rec.operation := l_x_Lot_Serial_rec.operation;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LOT_SERIAL.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR IN OE_OE_FORM_LOT_SERIAL.VALIDATE_AND_WRITE '|| TO_CHAR ( X_MSG_COUNT ) , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR IN OE_OE_FORM_LOT_SERIAL.VALIDATE_AND_WRITE '|| X_MSG_DATA , 1 ) ;
    END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
)
IS
l_x_Lot_Serial_rec              OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_old_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

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

    Get_Lot_Serial
    (   p_db_record                   => TRUE
    ,   p_lot_serial_id               => p_lot_serial_id
    ,   x_lot_serial_rec              => l_x_Lot_Serial_rec
    );

    --  Set Operation.

    l_x_Lot_Serial_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate Lot_Serial table

    l_x_Lot_Serial_tbl(1) := l_x_Lot_Serial_rec;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lot_Serials
    (   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_old_Lot_Serial_tbl        => l_x_old_Lot_Serial_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Lot_Serial record cache

    Clear_Lot_Serial;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

)
IS
l_return_status               VARCHAR2(1);
/*l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
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
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type; */
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.
/*
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LOT_SERIAL;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
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
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                    => l_x_line_tbl
    ,   p_x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl          => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl	      => l_action_request_tbl
    );
*/

     Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
	,   p_init_msg_list               => FND_API.G_TRUE
     ,  p_notify                     => TRUE
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

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_lot_serial_id                 IN  NUMBER
,   p_lock_control                  IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load Lot_Serial record

    l_x_Lot_Serial_rec.operation        := OE_GLOBALS.G_OPR_LOCK;
    l_x_Lot_Serial_rec.lot_serial_id    := p_lot_serial_id;
    l_x_Lot_Serial_rec.lock_control     := p_lock_control;

    --  Call OE_Lot_Serial_Util.lock_row instead of OE_Order_PVT.Lock_order

    OE_Lot_Serial_Util.Lock_Row
    (   x_return_status          => l_return_status
    ,   p_x_Lot_Serial_rec       =>  l_x_Lot_Serial_rec );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Lot_Serial_rec.db_flag := FND_API.G_TRUE;

        Write_Lot_Serial
        (   p_Lot_Serial_rec              => l_x_Lot_Serial_rec
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

--  Procedures maintaining Lot_Serial record cache.

PROCEDURE Write_Lot_Serial
(   p_Lot_Serial_rec                IN  OE_Order_PUB.Lot_Serial_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LOT_SERIAL.WRITE_LOT_SERIAL' , 1 ) ;
    END IF;

    g_Lot_Serial_rec := p_Lot_Serial_rec;

    IF p_db_record THEN

        g_db_Lot_Serial_rec := p_Lot_Serial_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LOT_SERIAL.WRITE_LOT_SERIAL' , 1 ) ;
    END IF;

END Write_Lot_Serial;

PROCEDURE Get_Lot_Serial
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_lot_serial_id                 IN  NUMBER
,   x_lot_serial_rec                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LOT_SERIAL.GET_LOT_SERIAL' , 1 ) ;
    END IF;

    IF  p_lot_serial_id <> g_Lot_Serial_rec.lot_serial_id
    THEN

        --  Query row from DB

        OE_Lot_Serial_Util.Query_Row
        (   p_lot_serial_id               => p_lot_serial_id
         ,  x_lot_serial_rec              => g_Lot_Serial_rec
        );

        g_Lot_Serial_rec.db_flag       := FND_API.G_TRUE;

        --  Load DB record

        g_db_Lot_Serial_rec            := g_Lot_Serial_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LOT_SERIAL.GET_LOT_SERIAL' , 1 ) ;
    END IF;
    IF p_db_record THEN

        x_lot_serial_rec:= g_db_Lot_Serial_rec;

    ELSE

        x_lot_serial_rec:= g_Lot_Serial_rec;

    END IF;

END Get_Lot_Serial;

PROCEDURE Clear_Lot_Serial
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    g_Lot_Serial_rec               := OE_Order_PUB.G_MISS_LOT_SERIAL_REC;
    g_db_Lot_Serial_rec            := OE_Order_PUB.G_MISS_LOT_SERIAL_REC;

END Clear_Lot_Serial;

END OE_OE_Form_Lot_Serial;

/
