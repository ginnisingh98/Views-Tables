--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_LINE_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_LINE_EXT" AS
/* $Header: ONTHLIEB.pls 120.0 2005/05/31 22:32:01 appldev noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Html_Line_Ext';
G_line_dff_tbl                Oe_Oe_Html_Line_Ext.Line_Dff_Tbl_Type;
G_LINE_NUMBER                 NUMBER;
G_SHIPMENT_NUMBER             NUMBER;

PROCEDURE GET_LINE_SHIPMENT_NUMBER(
  x_return_status OUT NOCOPY VARCHAR2
, p_header_id                     IN  Number
, x_line_number OUT NOCOPY Number
, x_shipment_number OUT NOCOPY Number
 );

PROCEDURE Save_Lines
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_cascade_flag                  OUT NOCOPY BOOLEAN
, p_line_tbl                      IN  OE_ORDER_PUB.Line_Tbl_Type
, p_old_line_tbl                  IN  OE_ORDER_PUB.Line_Tbl_Type
) IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_return_status               VARCHAR2(1);
I                             Number;
J                             Number;
l_num_lines                   NUMBER;
l_num_dff_lines               NUMBER;
l_fname varchar2(1000);
l_old_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
l_line_tbl     OE_ORDER_PUB.Line_Tbl_Type;
L_CASCADE_FLAG                BOOLEAN;
BEGIN

-- Consider changing the line_tbl to OUT type so that the old record
-- can be cached after save.

    oe_debug_pub.g_debug_level := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
    l_fname := oe_Debug_pub.set_debug_mode('FILE');
    oe_debug_pub.debug_on;
    OE_GLOBALS.G_UI_FLAG := TRUE;
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;
    l_old_line_tbl:=p_old_line_tbl;
    l_line_tbl:=p_line_tbl;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read line from cache

    -- Operation Should be Populated in the EO as multiple lines
    -- will be passed to the API. It is easier to set the flag
    -- through the EO instead of looping.

    --  Populate line table



    --  Call Oe_Order_Pvt.Process_order

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN BEGINING HTML LINE- SAVE' ) ;
    END IF;
        oe_debug_pub.add(  'AT Beg HTML LINE- SAVE FIRST CALL-Line Type'
       || l_line_tbl(1).line_type_id ) ;
        oe_debug_pub.add(  'AT Beg HTML LINE- SAVE FIRST CALL-Line Type'
       || l_old_line_tbl(1).line_type_id ) ;

    Oe_Order_Pvt.Lines
    (   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list                 => FND_API.G_FALSE
    ,   p_control_rec                   =>   l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl
    ,   p_x_old_line_tbl                => l_old_line_tbl
    ,   x_return_Status                 => l_return_status
    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AT END HTML LINE- SAVE FIRST CALL' ) ;
        oe_debug_pub.add(  'AT END HTML LINE- SAVE FIRST CALL-Line Type'
       || l_line_tbl(1).line_type_id ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AT BEGINING HTML LINE- SAVE SECOND CALL' ) ;
    END IF;

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.process              := FALSE;


    I := l_line_tbl.FIRST;
    l_num_lines := l_line_tbl.COUNT;
    WHILE I IS NOT NULL AND l_num_lines > 0
    LOOP
     IF FND_API.To_Boolean(l_line_tbl(i).db_flag) OR
      l_line_tbl(i).operation = OE_GLOBALS.G_OPR_UPDATE  THEN
        oe_debug_pub.add('Operation -Update');
--    The operation is set to handle if it doesn't get set in middle tier.
      l_line_tbl(i).operation:=OE_GLOBALS.G_OPR_UPDATE;

--  PO would have already queried the record if the old record is missing.
--  So this is a redundant call. Commenting for performance reasons.
       OE_Line_Util.Query_Row
          (   p_line_id                     => l_line_tbl(i).line_id
          ,   x_line_rec                    => l_old_line_tbl(i) );
     ELSE
     -- This needs to be changed once deletes are handled.
        oe_debug_pub.add('Operation -CREATE');
--    The operation is set to handle if it doesn't get set in middle tier.
      l_line_tbl(i).operation:=OE_GLOBALS.G_OPR_CREATE;
       GET_LINE_SHIPMENT_NUMBER(
            x_return_Status => l_return_status
        ,   p_header_id     => l_line_tbl(i).header_id
        ,   x_line_number   => l_line_tbl(i).line_number
        ,   x_shipment_number   => l_line_tbl(i).shipment_number
        );
        oe_debug_pub.add(  'IN GET_LINE_SHIPMENT_NUMBER'||l_line_tbl(i).line_number);
        oe_debug_pub.add(  'IN GET_LINE_SHIPMENT_NUMBER'||l_line_tbl(i).shipment_number);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;

     J := G_line_dff_tbl.FIRST;
     l_num_dff_lines := l_line_tbl.COUNT;
     WHILE J IS NOT NULL AND l_num_dff_lines > 0
     LOOP
      IF NVL(G_line_dff_tbl(j).line_id,-1)=NVL(l_line_tbl(i).line_id,-2) THEN
        l_line_tbl(i).attribute1:=G_line_dff_tbl(j).attribute1;
        l_line_tbl(i).attribute2:=G_line_dff_tbl(j).attribute2;
        l_line_tbl(i).attribute3:=G_line_dff_tbl(j).attribute3;
        l_line_tbl(i).attribute4:=G_line_dff_tbl(j).attribute4;
        l_line_tbl(i).attribute5:=G_line_dff_tbl(j).attribute5;
        l_line_tbl(i).attribute6:=G_line_dff_tbl(j).attribute6;
        l_line_tbl(i).attribute7:=G_line_dff_tbl(j).attribute7;
        l_line_tbl(i).attribute8:=G_line_dff_tbl(j).attribute8;
        l_line_tbl(i).attribute9:=G_line_dff_tbl(j).attribute9;
        l_line_tbl(i).attribute10:=G_line_dff_tbl(j).attribute10;
        l_line_tbl(i).attribute11:=G_line_dff_tbl(j).attribute11;
        l_line_tbl(i).attribute12:=G_line_dff_tbl(j).attribute12;
        l_line_tbl(i).attribute13:=G_line_dff_tbl(j).attribute13;
        l_line_tbl(i).attribute14:=G_line_dff_tbl(j).attribute14;
        l_line_tbl(i).attribute15:=G_line_dff_tbl(j).attribute15;
        Exit;
      END IF;
      j := G_line_dff_tbl.NEXT(I);
     END LOOP;
     I := l_line_tbl.NEXT(I);
    END LOOP;



    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    Oe_Order_Pvt.Lines
    (   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list                 => FND_API.G_TRUE
    ,   p_control_rec                   =>   l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl
    ,   p_x_old_line_tbl                => l_old_line_tbl
    ,   x_return_Status                 => l_return_status
    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AT END HTML LINE- SAVE SECOND CALL' ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  /*   Oe_Oe_Html_Header.Process_Object
     ( x_return_status =>l_return_status
     , x_msg_count     => x_msg_count
     , x_msg_data      => x_msg_data
     , x_cascade_flag  => l_cascade_flag
     ); */
     oe_debug_pub.add(  'AT END HTML LINE- PROCESS OBJECT CALL' ) ;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    G_LINE_NUMBER:=Null;
    G_SHIPMENT_NUMBER:=Null;
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        oe_debug_pub.add(  'IN END HTML LINE- SAVE' ) ;
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
            ,   'Save_Lines'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Save_Lines;


PROCEDURE Prepare_Lines_Dff_For_Save
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_line_dff_tbl                  IN   Oe_Oe_Html_Line_Ext.Line_Dff_Tbl_Type
)
IS
BEGIN


G_line_dff_tbl                :=x_line_dff_tbl;

END Prepare_Lines_Dff_For_Save;

PROCEDURE GET_LINE_SHIPMENT_NUMBER(
  x_return_status OUT NOCOPY VARCHAR2
, p_header_id                     IN  Number
, x_line_number OUT NOCOPY Number
, x_shipment_number OUT NOCOPY Number
                                   )  IS
l_line_number Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- Also this will need to be enhanced to support manual line numbers.
-- For Manual Line Numbers, we will also have to check that the line
-- number generated doesn't conflict with the manual number that is
-- entered by the user.

 IF G_LINE_NUMBER IS NULL THEN
    SELECT  NVL(MAX(LINE_NUMBER)+1,1)
    INTO    x_line_number
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = p_header_id;
    l_line_number:=x_line_number;
    G_LINE_NUMBER:=x_line_number;
  IF x_line_number IS NOT NULL THEN
    SELECT  NVL(MAX(SHIPMENT_NUMBER)+1,1)
    INTO    x_shipment_number
    FROM    OE_ORDER_LINES
    WHERE   HEADER_ID = p_header_id
    AND     LINE_NUMBER = l_line_number;
    G_SHIPMENT_NUMBER:=x_shipment_number;
  END IF;
 ELSE
  G_LINE_NUMBER:=G_LINE_NUMBER+1;
--  G_SHIPMENT_NUMBER:=G_SHIPMENT_NUMBER+1;
  x_line_number:=G_LINE_NUMBER;
  x_shipment_number:=G_SHIPMENT_NUMBER;
 END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Line_Shipment_Number'
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_LINE_SHIPMENT_NUMBER;


Procedure Populate_Transient_Attributes
(
  P_line_rec               IN Oe_Order_Pub.line_rec_type
, x_line_val_rec           OUT NOCOPY /* file.sql.39 change */  line_Ext_Val_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
) IS

CURSOR c_line_info IS

   select decode(line.line_Number,null,null,line.line_number)||
   decode(line.shipment_Number,null,null,'.'||line.shipment_number)||
   decode(line.option_number,null,null,'.'||line.option_number) line_num,
   line.unit_selling_price*decode(line.line_category_code,'RETURN',-1,1) unit_selling_price,
   (nvl(line.ordered_quantity,line.ordered_quantity)*line.unit_selling_price)*decode(line.line_category_code,'RETURN',-1,1) extended_price,
    DECODE(line.ITEM_IDENTIFIER_TYPE, 'CUST', NVL(C.CUSTOMER_ITEM_DESC,ITEMSTL.DESCRIPTION), 'INT', ITEMSTL.DESCRIPTION, null, ITEMSTL.DESCRIPTION, NVL(REF.DESCRIPTION,ITEMSTL.DESCRIPTION)) ITEM_DESCRIPTION
   from oe_order_lines_all line,
        mtl_system_items_tl itemstl,
        mtl_customer_items c,
        mtl_cross_references ref,
        mtl_system_items_b_kfv items
   Where  line.inventory_item_id =items.inventory_item_id(+)
and line.line_id= p_line_rec.line_id
and oe_sys_parameters.value('MASTER_ORGANIZATION_ID') = items.organization_id
and items.organization_id = itemstl.organization_id
and items.inventory_item_id =itemstl.inventory_item_id
and itemstl.language = userenv('LANG')
and line.item_identifier_type = ref.cross_reference_type(+)
and line.ordered_item = ref.cross_reference(+)
and line.inventory_item_id = ref.inventory_item_id(+)
and line.ordered_item_id = c.customer_item_id(+);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN  c_line_info;
   FETCH c_line_info
    INTO x_line_val_rec.line_number,
         x_line_val_rec.unit_selling_price,
         x_line_val_rec.extended_price,
         x_line_val_rec.item_description;
   CLOSE c_line_info;

EXCEPTION

  WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS OF CALL_MRP_ATP' ) ;
            oe_debug_pub.add(  'CODE='||SQLCODE||' MSG='||SQLERRM ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END populate_transient_attributes;



END Oe_Oe_Html_Line_Ext;

/
