--------------------------------------------------------
--  DDL for Package Body OE_LINE_FULLFILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_FULLFILL" AS
/* $Header: OEXVFULB.pls 120.15.12010000.5 2010/01/13 11:47:27 ramising ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Line_Fullfill';
G_FULFILL_WITH_ACTIVITY CONSTANT  VARCHAR2(30) := 'With Activity';
G_FULFILL_NO_ACTIVITY CONSTANT  VARCHAR2(30) := 'No Activity';
G_BINARY_LIMIT          CONSTANT NUMBER :=OE_GLOBALS.G_BINARY_LIMIT; --7827727
g_set_tbl  processed_set;

-------------------------------------------------------------------
-- Added 09-DEC-2002
-- LOCAL PROCEDURE Update_Blanket_Qty
-- Updates fulfilled quantity on the blanket line as release
-- lines referencing this blanket line are fulfilled. For RMAs, it
-- updates returned quantity as return lines are received.
-------------------------------------------------------------------
-- 5126873   - Blankets not supported for fulfilled quantity2 as per initial INV design from PM so no need to calculate fulfilled quantity2
PROCEDURE Update_Blanket_Qty
     (p_line_rec              IN OE_Order_PUB.Line_Rec_Type
     ,p_fulfilled_quantity    IN NUMBER DEFAULT NULL
      )
IS

  l_fulfilled_quantity           NUMBER := p_fulfilled_quantity;
  l_blanket_uom                  VARCHAR2(30);
  l_amount                       NUMBER := 0;
  l_order_currency               VARCHAR2(30);
  l_blanket_currency             VARCHAR2(30);
  l_conversion_type              VARCHAR2(30);

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_fulfilled_quantity IS NULL THEN

     l_fulfilled_quantity := p_line_rec.fulfilled_quantity;

  END IF;



  if l_debug_level > 0 then
     oe_debug_pub.add('blanket number : '||p_line_rec.blanket_number);
     oe_debug_pub.add('blanket line number : '||p_line_rec.blanket_line_number);
     oe_debug_pub.add('UOM : '||p_line_rec.order_quantity_uom);
     oe_debug_pub.add('Item Type : '||p_line_rec.item_type_code);
     oe_debug_pub.add('Line Category : '||p_line_rec.line_category_code);
  end if;


     -- 1. COMPUTE AMOUNT INTO Blanket Currency

     OE_Order_Cache.Load_Order_Header(p_line_rec.header_id);
     l_order_currency := OE_Order_Cache.g_header_rec.transactional_curr_code;

     l_amount := nvl(l_fulfilled_quantity,0) *
                    nvl(p_line_rec.unit_selling_price,0);

     SELECT transactional_curr_code, conversion_type_code
       INTO l_blanket_currency, l_conversion_type
       FROM OE_BLANKET_HEADERS
      WHERE ORDER_NUMBER = p_line_rec.blanket_number
       AND SALES_DOCUMENT_TYPE_CODE = 'B';

     IF l_order_currency <> l_blanket_currency THEN
        l_amount := OE_Blkt_Release_Util.Convert_Amount
               (p_from_currency     => l_order_currency
               ,p_to_currency       => l_blanket_currency
               ,p_conversion_date   => sysdate
               ,p_conversion_type   => l_conversion_type
               ,p_amount            => l_amount
               );
     END IF;

     if l_debug_level > 0 then
        oe_debug_pub.add('Order Currency : '||l_order_currency);
        oe_debug_pub.add('Blanket Currency : '||l_blanket_currency);
        oe_debug_pub.add('Fulfilled Amount : '||l_amount);
     end if;


     -- 2. CONVERT fulfilled quantity into blanket UOM

     -- New Data Model Changes for Blanket Orders

     SELECT L.Order_Quantity_UOM
       INTO l_blanket_uom
       FROM OE_BLANKET_LINES L,OE_BLANKET_LINES_EXT BL
      WHERE BL.ORDER_NUMBER  = p_line_rec.blanket_number
        AND BL.LINE_NUMBER   = p_line_rec.blanket_line_number
        AND L.LINE_ID        = BL.LINE_ID
        AND L.SALES_DOCUMENT_TYPE_CODE = 'B';

     -- Blanket uom is null, quantities are not recorded on blanket
     IF l_blanket_uom IS NULL THEN

        l_fulfilled_quantity := null;

     -- Uoms are different, convert to blanket uom
     ELSIF p_line_rec.order_quantity_uom <>  l_blanket_uom THEN

        l_fulfilled_quantity := OE_Order_Misc_Util.Convert_UOM
             (p_item_id          => p_line_rec.inventory_item_id
             ,p_from_uom_code    => p_line_rec.order_quantity_uom
             ,p_to_uom_code      => l_blanket_uom
             ,p_from_qty         => l_fulfilled_quantity
             );

     END IF;

     if l_debug_level > 0 then
        oe_debug_pub.add('blkt uom :'||l_blanket_uom);
        oe_debug_pub.add('fulfilled qty :'||l_fulfilled_quantity);
     end if;


     -- 3. UPDATE quantity/amount on blanket line and header

     IF p_line_rec.line_category_code = 'ORDER' THEN

        UPDATE oe_blanket_lines l
           SET l.lock_control = l.lock_control + 1
         WHERE L.Line_Id IN (SELECT Line_Id FROM oe_blanket_lines_ext bl
                      WHERE bl.order_number = p_line_rec.blanket_number
                        AND bl.line_number   = p_line_rec.blanket_line_number)
          AND l.sales_document_type_code = 'B';

        -- Bug 2734877
        -- Update fulfilled qty only if uom is not null
        -- If blanket uom is null, fulfilled qty should also be null
        IF l_blanket_uom IS NULL THEN
           UPDATE oe_blanket_lines_ext ble
              SET ble.fulfilled_amount = nvl(ble.fulfilled_amount,0) +
                                          l_amount
            WHERE ble.order_number = p_line_rec.blanket_number
              AND ble.line_number  = p_line_rec.blanket_line_number;

        ELSE
           UPDATE oe_blanket_lines_ext ble
              SET ble.fulfilled_quantity = nvl(ble.fulfilled_quantity,0) +
                                               l_fulfilled_quantity
                  ,ble.fulfilled_amount = nvl(ble.fulfilled_amount,0) +
                                          l_amount
            WHERE ble.order_number = p_line_rec.blanket_number
              AND ble.line_number  = p_line_rec.blanket_line_number;
        END IF;

        UPDATE oe_blanket_headers_ext bhe
           SET bhe.fulfilled_amount = nvl(bhe.fulfilled_amount,0) +
                                          l_amount
         WHERE bhe.order_number = p_line_rec.blanket_number;

        UPDATE oe_blanket_headers bh
           SET bh.lock_control = bh.lock_control + 1
         WHERE bh.order_number = p_line_rec.blanket_number
           AND bh.sales_document_type_code = 'B';

     ELSIF p_line_rec.line_category_code = 'RETURN' THEN

        -- Bug 2734877
        -- Update returned qty only if uom is not null
        -- If blanket uom is null, returned qty should also be null
        IF l_blanket_uom IS NULL THEN
           UPDATE oe_blanket_lines_ext ble
              SET ble.returned_amount = nvl(ble.returned_amount,0) +
                                          l_amount
            WHERE ble.order_number = p_line_rec.blanket_number
              AND ble.line_number  = p_line_rec.blanket_line_number;

        ELSE
           UPDATE oe_blanket_lines_ext ble
              SET ble.returned_quantity = nvl(ble.returned_quantity,0) +
                                          l_fulfilled_quantity
                  ,ble.returned_amount = nvl(ble.returned_amount,0) +
                                          l_amount
            WHERE ble.order_number = p_line_rec.blanket_number
              AND ble.line_number  = p_line_rec.blanket_line_number;
        END IF;

        UPDATE oe_blanket_lines bl
           SET bl.lock_control = bl.lock_control + 1
         WHERE bl.line_Id IN (SELECT Line_Id FROM oe_blanket_lines_ext bl
                      WHERE bl.order_number = p_line_rec.blanket_number
                        AND bl.line_number   = p_line_rec.blanket_line_number)
           AND bl.sales_document_type_code = 'B';

        UPDATE oe_blanket_headers_ext bhe
           SET bhe.returned_amount = nvl(bhe.returned_amount,0) +
                                          l_amount
         WHERE bhe.order_number = p_line_rec.blanket_number;

        UPDATE oe_blanket_headers bh
           SET bh.lock_control = bh.lock_control + 1
         WHERE bh.order_number = p_line_rec.blanket_number
           AND bh.sales_document_type_code = 'B';

     END IF;

EXCEPTION
  WHEN OTHERS THEN
     if l_debug_level > 0 then
        oe_debug_pub.add('Update_Blanket_Qty: Others Error', 1);
        oe_debug_pub.ADD('Error: '||substr(sqlerrm,1,200),1);
     end if;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
          (   G_PKG_NAME
           ,   'Update_Blanket_Qty'
          );
     END IF;
     G_DEBUG_MSG := G_DEBUG_MSG || 'E1,';
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Blanket_Qty;


/*
  This function will check if a passed line is part of any fulfillment set.
  And will return True/False accordingly.
*/

FUNCTION Is_Part_Of_Fulfillment_Set
(
  p_line_id         IN  NUMBER
) return VARCHAR2
IS
  l_set_id  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.IS_PART_OF_FULFILLMENT_SET '|| TO_CHAR ( P_LINE_ID ) , 5 ) ;
  END IF;

  Select  set_id
  Into  l_set_id
  From  oe_line_sets
  Where line_id = p_line_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( 'Yes, part of fulfillment set ' , 5 ) ;
  END IF;

  Return  FND_API.G_TRUE;

EXCEPTION

  WHEN  NO_DATA_FOUND THEN
      Return  FND_API.G_FALSE;
  WHEN  TOO_MANY_ROWS THEN
      Return  FND_API.G_TRUE;
  WHEN  OTHERS THEN
      Return  FND_API.G_FALSE;

END Is_Part_Of_Fulfillment_Set;

PROCEDURE Get_service_lines
(
  p_line_id IN  NUMBER,
  p_header_id IN  NUMBER DEFAULT NULL,   -- 1717444
x_return_status OUT NOCOPY VARCHAR2,

x_line_tbl OUT NOCOPY OE_Order_Pub.Line_Tbl_Type

)
IS

  l_header_id         NUMBER;  -- 1717444
  l_service_index     NUMBER := 0;
  l_activity_status VARCHAR2(8);
  l_activity_result VARCHAR2(30);
  l_activity_id   NUMBER;
  l_item_key      VARCHAR2(240);
  l_fulfill_activity  VARCHAR2(30)  := 'FULFILL_LINE';
  l_return_status     VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR C_Service_Lines IS
  SELECT LINE_ID,
       HEADER_ID,
       ORDERED_QUANTITY,
       SHIPPED_QUANTITY,
       FULFILLED_FLAG,
       BLANKET_NUMBER,
       BLANKET_LINE_NUMBER,
       ORDER_QUANTITY_UOM,
       ITEM_TYPE_CODE,
       LINE_CATEGORY_CODE,
       UNIT_SELLING_PRICE,
       INVENTORY_ITEM_ID,
       ORDER_FIRMED_DATE,
       ACTUAL_SHIPMENT_DATE
  FROM   OE_ORDER_LINES_ALL
  WHERE  SERVICE_REFERENCE_LINE_ID = p_line_id
        AND    SERVICE_REFERENCE_TYPE_CODE = 'ORDER' -- added in 115.46
        AND    HEADER_ID = l_header_id   --  1717444
        AND    TOP_MODEL_LINE_ID IS NULL;   --3449588
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.GET_SERVICE_LINES '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;


        IF p_header_id IS NULL OR   --  This IF introduced for 1717444
           p_header_id = FND_API.G_MISS_NUM THEN
          SELECT header_id
          INTO   l_header_id
          FROM   oe_order_lines
          WHERE  line_id = p_line_id;
        ELSE
          l_header_id := p_header_id;
        END IF;

    FOR  l_service_lines IN c_service_lines
  LOOP

    IF  l_service_lines.fulfilled_flag = 'Y' THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SERVICE LINE IS ALREADY FULFILLED ' , 3 ) ;
            END IF;

    ELSE

    l_item_key := to_char(l_service_lines.line_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR ITEM : '||L_ITEM_KEY||'/'||L_FULFILL_ACTIVITY , 3 ) ;
    END IF;

    Get_Activity_Result
    (
      p_item_type       => OE_GLOBALS.G_WFI_LIN
    , p_item_key        => l_item_key
    , p_activity_name     => l_fulfill_activity
    , x_return_status     => l_return_status
    , x_activity_result   => l_activity_result
    , x_activity_status_code  => l_activity_status
    , x_activity_id     => l_activity_id
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS||'/'||L_ACTIVITY_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR OR
        l_activity_status <> 'NOTIFIED' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SERVICE LINE IS NOT AT FULFILL LINE : '||TO_CHAR ( L_SERVICE_LINES.LINE_ID ) , 3 ) ;
        END IF;
        GOTO END_SERVICE_LOOP;
    END IF;

        l_service_index := l_service_index + 1;
    x_line_tbl(l_service_index).line_id := l_service_lines.line_id;
    x_line_tbl(l_service_index).header_id := l_service_lines.header_id;
    x_line_tbl(l_service_index).ordered_quantity := l_service_lines.ordered_quantity;
    x_line_tbl(l_service_index).shipped_quantity := l_service_lines.shipped_quantity;
    x_line_tbl(l_service_index).blanket_number := l_service_lines.blanket_number;
    x_line_tbl(l_service_index).blanket_line_number := l_service_lines.blanket_line_number;
    x_line_tbl(l_service_index).order_quantity_uom := l_service_lines.order_quantity_uom;
    x_line_tbl(l_service_index).item_type_code := l_service_lines.item_type_code;
    x_line_tbl(l_service_index).line_category_code := l_service_lines.line_category_code;
    x_line_tbl(l_service_index).unit_selling_price := l_service_lines.unit_selling_price;
    x_line_tbl(l_service_index).inventory_item_id := l_service_lines.inventory_item_id;
    x_line_tbl(l_service_index).order_firmed_date := l_service_lines.order_firmed_date;
    x_line_tbl(l_service_index).actual_shipment_date := l_service_lines.actual_shipment_date;

    END IF;

        << END_SERVICE_LOOP >>
    NULL;

  END LOOP;


    IF  l_service_index = 0 THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.GET_SERVICE_LINES WITH STATUS: '|| X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION

  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.GET_SERVICE_LINES WITH STATUS: '|| X_RETURN_STATUS , 1 ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Service_Lines'
        );
      END IF;
      G_DEBUG_MSG := G_DEBUG_MSG || '5,';

  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.GET_SERVICE_LINES WITH STATUS: '|| X_RETURN_STATUS , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Service_Lines'
        );
      END IF;
      G_DEBUG_MSG := G_DEBUG_MSG || '6,';

END Get_service_lines;

PROCEDURE Fulfill_Service_Lines
(
  p_line_id IN  NUMBER,
  p_header_id IN  NUMBER DEFAULT NULL,     --  1717444
x_return_status OUT NOCOPY VARCHAR2

)

IS
  l_fulfill_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_index       NUMBER := 0 ;
  l_service_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_service_index       NUMBER := 0 ;
  l_line_id         NUMBER;
  l_return_status       VARCHAR2(1);
  l_parent_line_fulfilled_qty  NUMBER := null; --5699215

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.FULFILL_SERVICE_LINES '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;

  /* Get the service lines if there are any associated with the
     line       */


    Get_Service_Lines
  (
    p_line_id   => p_line_id,
    p_header_id   => p_header_id, -- 1717444
    x_return_status => l_return_status,
    x_line_tbl    => l_service_tbl
     );


  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
      GOTO END_SERVICE_LOOP;
    END IF;

  --5699215
  SELECT  fulfilled_quantity
  INTO    l_parent_line_fulfilled_qty
  FROM    oe_order_lines
  WHERE   line_id = p_line_id;
  --5699215

  /* Add service lines to l_fulfill_tbl for fulfillment */

  FOR l_service_index IN 1 .. l_service_tbl.count
  LOOP
    l_fulfill_index := l_fulfill_index + 1;
    l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
    l_fulfill_tbl(l_fulfill_index).line_id := l_service_tbl(l_service_index).line_id;
    l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
    l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
    --5699215
    l_fulfill_tbl(l_fulfill_index).fulfilled_quantity :=  nvl(l_parent_line_fulfilled_qty,(Nvl(l_service_tbl(l_service_index).shipped_quantity,l_service_tbl(l_service_index).ordered_quantity)));
    --nvl(l_service_tbl(l_service_index).shipped_quantity,l_service_tbl(l_service_index).ordered_quantity);
    l_fulfill_tbl(l_fulfill_index).fulfilled_quantity2 := nvl(l_service_tbl(l_service_index).shipped_quantity2,l_service_tbl(l_service_index).ordered_quantity2); --bug 5126873
    IF l_fulfill_tbl(l_fulfill_index).fulfilled_quantity2 = 0 then -- bug 5126873
      l_fulfill_tbl(l_fulfill_index).fulfilled_quantity2 := NULL;
    END IF;
    l_fulfill_tbl(l_fulfill_index).blanket_number := l_service_tbl(l_service_index).blanket_number;
    l_fulfill_tbl(l_fulfill_index).blanket_line_number := l_service_tbl(l_service_index).blanket_line_number;
    l_fulfill_tbl(l_fulfill_index).order_quantity_uom := l_service_tbl(l_service_index).order_quantity_uom;
    l_fulfill_tbl(l_fulfill_index).item_type_code := l_service_tbl(l_service_index).item_type_code;
    l_fulfill_tbl(l_fulfill_index).line_category_code := l_service_tbl(l_service_index).line_category_code;
    l_fulfill_tbl(l_fulfill_index).unit_selling_price := l_service_tbl(l_service_index).unit_selling_price;
    l_fulfill_tbl(l_fulfill_index).header_id := l_service_tbl(l_service_index).header_id;
    l_fulfill_tbl(l_fulfill_index).inventory_item_id := l_service_tbl(l_service_index).inventory_item_id;
    l_fulfill_tbl(l_fulfill_index).order_firmed_date := l_service_tbl(l_service_index).order_firmed_date;
    l_fulfill_tbl(l_fulfill_index).actual_shipment_date := l_service_tbl(l_service_index).actual_shipment_date;
    l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FULFILL INDEX : '||TO_CHAR ( L_FULFILL_INDEX ) , 3 ) ;
        oe_debug_pub.add(  'FULFILLED FLAG : '||L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_FLAG , 3 ) ;
        oe_debug_pub.add(  'FULFILLED QUANTITY : '||TO_CHAR ( L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_QUANTITY ) , 3 ) ;
    END IF;

  END LOOP;

    /* Update the fulfilled flag and quantity for the service lines */

  IF  l_fulfill_index <> 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FULFILL LINE TABLE : ' , 3 ) ;
    END IF;

    Fulfill_Line
    (
      p_line_tbl      =>  l_fulfill_tbl,
      p_mode        =>  'TABLE',
      p_fulfillment_type  =>  G_FULFILL_WITH_ACTIVITY,
      x_return_status   =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('raising unexpected error '||sqlerrm,1);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('raising exc error '||sqlerrm,1);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  /* Complete the work flow activity for the service lines */

  FOR l_service_index IN 1 .. l_service_tbl.count
  LOOP

    l_line_id := l_service_tbl(l_service_index).line_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FLOW STATUS API FOR LINE '||L_SERVICE_TBL ( L_SERVICE_INDEX ) .LINE_ID , 3 ) ;
    END IF;

    OE_Order_WF_Util.Update_Flow_Status_Code
    (p_line_id            =>  l_service_tbl(l_service_index).line_id,
    p_flow_status_code    =>  'FULFILLED',
    x_return_status       =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('after update of flow status code - error '||sqlerrm,1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('after update of flow status code - exc error '||sqlerrm,1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_ID ) , 3 ) ;
    END IF;
      wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_id), 'FULFILL_LINE', '#NULL');
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_ID ) , 3 ) ;
    END IF;

  END LOOP;


  << END_SERVICE_LOOP >>

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.FULFILL_SERVICE_LINES '|| X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION

  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.FULFILL_SERVICE_LINES WITH STATUS: '|| X_RETURN_STATUS , 1 ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Fulfill_Service_Lines'
        );
      END IF;
                 G_DEBUG_MSG := G_DEBUG_MSG || 'E4,';

  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.FULFILL_SERVICE_LINES WITH STATUS: '|| X_RETURN_STATUS , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Fulfill_Service_Lines'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E5';

END Fulfill_Service_Lines;


PROCEDURE Update_Service_Dates  /* 2048753 */
(
  p_line_rec             IN OUT NOCOPY     OE_Order_Pub.Line_Rec_Type
)
IS
l_return_status VARCHAR2(1);
l_line_rec OE_Order_Pub.Line_Rec_Type;  -- added for 2897505

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'ENTERING UPDATE_SERVICE_DATES: ' || TO_CHAR ( P_LINE_REC.LINE_ID ) || ' '|| TO_CHAR ( P_LINE_REC.SERVICE_START_DATE , 'YYYY/MM/DD' ) ||' , '|| TO_CHAR ( P_LINE_REC.SERVICE_END_DATE , 'YYYY/MM/DD' ) , 5 ) ;
                   END IF;


  IF p_line_rec.service_start_date IS NULL OR
     p_line_rec.service_start_date = FND_API.G_MISS_DATE
  THEN
    l_line_rec := p_line_rec;  -- 2897505 start
    l_line_rec.service_start_date := NULL;
    l_line_rec.service_reference_type_code := 'GET_SVC_START';


    OE_SERVICE_UTIL.Get_Service_Duration(
                   p_x_line_rec => l_line_rec,
                   x_return_status => l_return_status
    );



    p_line_rec.service_start_date := l_line_rec.service_start_date;

    /*  commented out for 4110237
    IF p_line_rec.service_start_date IS NULL THEN
      p_line_rec.service_start_date := p_line_rec.fulfillment_date;
    END IF; -- 2897505 end
    */

     -- IF condition added for 4110237
    IF p_line_rec.service_start_date IS NOT NULL THEN
       p_line_rec.service_end_date := NULL;
       OE_SERVICE_UTIL.Get_Service_Duration(
                   p_x_line_rec => p_line_rec,
                   x_return_status => l_return_status
        );
    END IF;

  ELSIF p_line_rec.service_end_date IS NULL OR
        p_line_rec.service_end_date = FND_API.G_MISS_DATE
  THEN

    OE_SERVICE_UTIL.Get_Service_Duration(
                   p_x_line_rec => p_line_rec,
                   x_return_status => l_return_status
    );

  END IF;

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'EXITING UPDATE_SERVICE_DATES:' || TO_CHAR ( P_LINE_REC.SERVICE_START_DATE , 'YYYY/MM/DD' ) ||' , '|| TO_CHAR ( P_LINE_REC.SERVICE_END_DATE , 'YYYY/MM/DD' ) , 5 ) ;
                   END IF;

END Update_Service_Dates;

/*
   This procedure is to update the fulfilled flag, fulfilled quantity and
   fulfillment date for a line or a table of line records by calling
   Process_Order API
*/

PROCEDURE Fulfill_Line
(
 p_line_rec             IN OE_Order_Pub.Line_Rec_Type DEFAULT OE_Order_Pub.G_MISS_LINE_REC
,p_line_tbl   IN OE_Order_Pub.Line_Tbl_Type DEFAULT OE_Order_Pub.G_MISS_LINE_TBL
,p_mode     IN VARCHAR2
,p_fulfillment_type IN VARCHAR2
,p_fulfillment_activity IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,x_return_status        OUT NOCOPY VARCHAR2
)
IS
l_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
l_aso_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
l_return_status      VARCHAR2(1);
l_index        NUMBER;
l_fulfilled_quantity NUMBER;
l_fulfilled_quantity2 NUMBER; -- 5126873
l_line_rec       OE_Order_Pub.Line_Rec_Type;  /* 2048753 */
l_notify_index       NUMBER;
l_user               NUMBER := NVL(OE_STANDARD_WF.G_USER_ID, FND_GLOBAL.USER_ID); --3169637
-- Changes for AFD
l_ordered_date date;
l_actual_fulfillment_date date;
l number;
-- end Changes for AFD

Cursor srv_lines is  -- 2292133
   select service_start_date,
          service_end_date,
          service_period,
          service_duration,
          service_coterminate_flag,
          item_type_code  -- this one added for 2417601
   from   oe_order_lines
   where  line_id = l_line_rec.line_id;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
/* Start Improved OM,IB,OKS changes */
l_msg_data              VARCHAR2(2000) := NULL;
l_validation_level      NUMBER;
l_Service_Order_Lines   OKS_OMINT_PUB.Service_Order_Lines_TblType;
l_order_number NUMBER;
/* end Improved OM,IB,OKS changes */
l_message_id       NUMBER;
l_error_code       NUMBER;
l_error_message    VARCHAR2(4000);
l_accounting_rule_type  VARCHAR2(60); -- webroot bug 6826344 added

  CAN_NOT_LOCK_MODEL          EXCEPTION;

BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering oe_line_fullfill.fulfill_line()  '||to_char(p_line_rec.line_id),1) ;
END IF;


l_line_rec.service_start_date := NULL;  -- initialization for 2292133
l_line_rec.service_end_date := NULL;

IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
   OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
END IF;

/*  Commented for performance changes.
  l_control_rec := OE_GLOBALS.G_MISS_CONTROL_REC;
  l_control_rec.validate_entity   := FALSE;
  l_control_rec.check_security    := FALSE;
*/
IF p_mode = 'RECORD' THEN


 -- CHANGES for AFD
    select ordered_date into l_ordered_date
    from oe_order_headers_all
    where header_id = p_line_rec.header_id;

    l_actual_fulfillment_date := nvl(p_line_rec.actual_shipment_date,nvl(p_line_rec.order_firmed_date,l_ordered_date));
    -- end  CHANGES for AFD


/*  Commented for performance changes
    l_update_line_tbl(1) := OE_Order_PUB.G_MISS_LINE_REC;
    l_update_line_tbl(1).line_id := p_line_rec.line_id;
    l_update_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
*/
    /* Start Audit Trail */
    -- l_update_line_tbl(1).change_reason := 'SYSTEM';
    -- l_update_line_tbl(1).change_comments := 'Process fulfillment set';
    /* End Audit Trail */
/*
    l_update_line_tbl(1).fulfilled_flag := 'Y';
    l_update_line_tbl(1).fulfillment_date := SYSDATE;

*/
IF  p_fulfillment_type = G_FULFILL_WITH_ACTIVITY THEN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Updating with shipped quantity',3) ;
    END IF;
  --l_update_line_tbl(1).fulfilled_quantity := p_line_rec.shipped_quantity;
    l_fulfilled_quantity := p_line_rec.shipped_quantity;
    l_fulfilled_quantity2 := p_line_rec.shipped_quantity2; -- 5126873
    IF l_fulfilled_quantity2 = 0 then -- bug 5126873
      l_fulfilled_quantity2 := NULL;
    END IF;


    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Updating with ordered quantity',3) ;
        END IF;
        --l_update_line_tbl(1).fulfilled_quantity := p_line_rec.ordered_quantity;
        l_fulfilled_quantity := p_line_rec.ordered_quantity;
        l_fulfilled_quantity2 := p_line_rec.ordered_quantity2;    -- 5126873
        IF l_fulfilled_quantity2 = 0 then -- bug 5126873
      		l_fulfilled_quantity2 := NULL;
    		END IF;

    END IF;
    --webroot bug 6826344 start
    IF p_line_rec.accounting_rule_id IS  NOT NULL THEN

        SELECT type INTO l_accounting_rule_type
        FROM ra_rules
        WHERE rule_id = p_line_rec.accounting_rule_id;

    END IF;
    --webroot bug 6826344 end

    IF  p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE /* 2048753 */
       OR (l_accounting_rule_type = 'PP_DR_PP'  OR l_accounting_rule_type = 'PP_DR_ALL') THEN -- added for webroot bug 6826344
        l_line_rec := p_line_rec;
        l_line_rec.fulfillment_date := SYSDATE;

        Update_Service_Dates(l_line_rec);

    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('After calling update_service_lines() ',5) ;
    END IF;
    IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  ) THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('mode is record',3) ;
       END IF;
       OE_Line_Util.Lock_Rows
      (p_line_id    => p_line_rec.line_id
      ,x_line_tbl   => l_old_line_tbl
      ,x_return_status  => l_return_status
      );
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Returned from lock row : '||l_return_status,3) ;
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('STS error while locking row '||sqlerrm,1);
         END IF;
         RAISE CAN_NOT_LOCK_MODEL;
         --RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('EXC error while locking row '||sqlerrm,1);
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       l_line_tbl := l_old_line_tbl;
       l_aso_line_tbl := l_old_line_tbl;
       l_line_tbl(1).fulfilled_flag := 'Y';
       l_line_tbl(1).fulfilled_quantity := l_fulfilled_quantity;
       l_line_tbl(1).fulfilled_quantity2 := l_fulfilled_quantity2;     -- 5126873
       IF  l_line_tbl(1).fulfilled_quantity2 = 0 then -- bug 5126873
      			l_line_tbl(1).fulfilled_quantity2 := NULL;
    	 END IF;


       l_line_tbl(1).fulfillment_date := SYSDATE;
       l_line_tbl(1).last_update_date := SYSDATE;
       l_line_tbl(1).last_updated_by := l_user; -- 3169637
       l_line_tbl(1).last_update_login := FND_GLOBAL.LOGIN_ID;
       l_line_tbl(1).lock_control := l_line_tbl(1).lock_control + 1;
       /* next two lines: 2048753 */
       l_line_tbl(1).service_start_date := l_line_rec.service_start_date;
       l_line_tbl(1).service_end_date := l_line_rec.service_end_date;

      -- changes for AFD
       l_line_tbl(1).actual_fulfillment_date := l_actual_fulfillment_date;

       -- added for notification framework
       --check code release level first. Notification framework is at Pack H level
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
            -- calling notification framework to get index position
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Line_id is:' || p_line_rec.line_id ) ;
          END IF;
          OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_header_id=>p_line_rec.header_id,
                    p_line_rec =>l_line_tbl(1),
                    p_line_id => p_line_rec.line_id,
                    x_index => l_notify_index,
                    x_return_status => l_return_status);


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Update_global return status from oe_line_fullfill.fullfill_line is: '|| l_return_status ) ;
               oe_debug_pub.add('Global picture index is: '||l_notify_index,1) ;
           END IF;
           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        IF l_notify_index IS NOT NULL THEN
          --update Global Picture directly
           OE_ORDER_UTIL.g_old_line_tbl(l_notify_index):= l_old_line_tbl(1);
           OE_ORDER_UTIL.g_line_tbl(l_notify_index):= OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);

           oe_debug_pub.add('line_rec line id is :'|| l_line_rec.line_id);
           oe_debug_pub.add('line_rec header id is :'|| l_line_rec.header_id);

           /* commented as unnecessary for 3803251
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id := l_line_rec.line_id;
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).header_id := l_line_rec.header_id;
           */
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_flag := 'Y';
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity := l_fulfilled_quantity;
           IF l_fulfilled_quantity2 <> 0 then
           		OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity2 := l_fulfilled_quantity2; -- 5126873
            ELSE
              OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity2 := NULL;
           END IF;

           OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfillment_date := SYSDATE;
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_date := SYSDATE;
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_updated_by  := l_user; -- 3169637
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_login :=FND_GLOBAL.LOGIN_ID;
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).service_start_date :=l_line_rec.service_start_date;
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).service_end_date := l_line_rec.service_end_date;
     /* changes for AFD */
           OE_ORDER_UTIL.g_line_tbl(l_notify_index).actual_fulfillment_date := l_actual_fulfillment_date;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('global line fulfilled_flag is: '||OE_ORDER_UTIL.G_LINE_TBL(L_NOTIFY_INDEX).FULFILLED_FLAG,1) ;
           END IF;
        END IF;
     END IF; /*code_release_level*/
   -- notification framework end
   END IF; /* aso installed*/


   UPDATE OE_ORDER_LINES_ALL
   SET    FULFILLED_FLAG = 'Y',
          FULFILLED_QUANTITY = l_fulfilled_quantity,
          FULFILLED_QUANTITY2 = l_fulfilled_quantity2, -- 5126873
          FULFILLMENT_DATE = SYSDATE,
          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY  = l_user,  -- 3169637
          LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
          /* next two lines: 2048753 */
          SERVICE_START_DATE = l_line_rec.service_start_date,
          SERVICE_END_DATE = l_line_rec.service_end_date,
          ACTUAL_FULFILLMENT_DATE = l_actual_fulfillment_date,
          LOCK_CONTROL = LOCK_CONTROL+1
   WHERE  LINE_ID = p_line_rec.line_id;

   IF  p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN
        /* Start Improved OM,IB,OKS changes */
        select order_number
          into l_order_number
          from oe_order_headers_all
         where header_id = p_line_rec.header_id;

        l_Service_Order_Lines(1).Order_Header_ID   :=  p_line_rec.header_id;
        l_Service_Order_Lines(1).Order_Line_ID     :=  p_line_rec.line_id;
        l_Service_Order_Lines(1).Order_Number      :=  l_order_number;
        l_Service_Order_Lines(1).Ref_Order_Line_ID :=  p_line_rec.service_reference_line_id;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calling OKS_OMINT_PUB.Interface_Service_Order_Lines:p_line_rec.line_id:'
                             || p_line_rec.line_id,3) ;
        END IF;

        OKS_OMINT_PUB.Interface_Service_Order_Lines(
                             p_Service_Order_Lines => l_Service_Order_Lines,
                             x_Return_Status       => l_return_status,
                             x_Error_Message       => l_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           oe_debug_pub.add('FND_API.G_RET_STS_ERROR after call to OKS_OMINT_PUB.Interface_Service');
           oe_debug_pub.add('l_msg_data' || l_msg_data);
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           oe_debug_pub.add('FND_API.G_RET_STS_UNEXP_ERROR after call to OKS_OMINT_PUB.Interface_Service');
           oe_debug_pub.add('l_msg_data' || l_msg_data);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        /* End Improved OM,IB,OKS changes */
   END IF;

   -- Added 09-Dec-2002
   -- BLANKETS: Update returned/fulfilled qty
   IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN
      if l_debug_level > 0 then
         oe_debug_pub.add('OEXVFULB 1, blanket number :'||
                                       p_line_rec.blanket_number);
      end if;
      IF p_line_rec.blanket_number IS NOT NULL THEN
         Update_Blanket_Qty(p_line_rec,l_fulfilled_quantity);
      END IF;
   END IF;

    oe_debug_pub.add('  FND_PROFILE.VALUE(ONT_AUTO_INTERFACE_LINES_TO_IB) =  ' || FND_PROFILE.VALUE('ONT_AUTO_INTERFACE_LINES_TO_IB'), 5);

    IF  p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_SERVICE
         AND ( NVL(FND_PROFILE.VALUE('ONT_AUTO_INTERFACE_LINES_TO_IB'),'Y') = 'Y')  -- bug 9245134
    THEN
        oe_debug_pub.add('Before Call to csi_ont_txn_pub.posttransaction',1);
      csi_ont_txn_pub.posttransaction
        (
        p_order_line_id    =>  p_line_rec.line_id,
        x_return_status    => l_return_status,
        x_message_id       => l_message_id,
        x_error_code       => l_error_code,
        x_error_message    => l_error_message);
        oe_debug_pub.add('After Call to csi_ont_txn_pub.posttransaction',1);

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('raising unexpected error in csi_ont_txn_pub.posttransaction'||sqlerrm,1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('raising exc error in csi_ont_txn_pub.posttransaction'||sqlerrm,1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;

ELSE
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Number of lines to update: '||p_line_tbl.count,3) ;
   END IF;

   IF p_line_tbl.count = 0 THEN  -- this IF added for 2231594
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting fulfill_line() - no lines to update',3) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN;
   END IF;

   -- CHANGES for AFD
    l := p_line_tbl.FIRST;

    select ordered_date into l_ordered_date
    from oe_order_headers_all
    where header_id = p_line_tbl(l).header_id;
    -- end CHANGES for AFD



   FOR l_index IN p_line_tbl.FIRST .. p_line_tbl.LAST LOOP

         -- Changes for AFD
         l_actual_fulfillment_date := nvl(p_line_tbl(l_index).actual_shipment_date,nvl(p_line_tbl(l_index).order_firmed_date,l_ordered_date));
         -- END CHANGES for AFD

       IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
            (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  )THEN

          OE_Line_Util.Lock_Rows
        (p_line_id    => p_line_tbl(l_index).line_id
        ,x_line_tbl   => l_old_line_tbl
        ,x_return_status  => l_return_status
        );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Returned from lock row : '||l_return_status,3) ;
    END IF;

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('STS error while locking row '||sqlerrm,1);
            END IF;
            RAISE CAN_NOT_LOCK_MODEL;
            --RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('EXC error while locking row '||sqlerrm,1);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

    l_line_tbl(l_index) := l_old_line_tbl(1);
    l_aso_line_tbl(l_index) := l_old_line_tbl(1);
    l_line_tbl(l_index).fulfilled_flag := p_line_tbl(l_index).fulfilled_flag;
    l_line_tbl(l_index).fulfilled_quantity := p_line_tbl(l_index).fulfilled_quantity;
    l_line_tbl(l_index).fulfilled_quantity2 := p_line_tbl(l_index).fulfilled_quantity2; -- 5126873
    IF l_line_tbl(l_index).fulfilled_quantity2 = 0 then -- 5126873
    	 l_line_tbl(l_index).fulfilled_quantity2 := NULL;
    END IF;
    l_line_tbl(l_index).fulfillment_date := p_line_tbl(l_index).fulfillment_date;
    l_line_tbl(l_index).last_update_date := SYSDATE;
    l_line_tbl(l_index).last_updated_by := l_user;  -- 3169637
    l_line_tbl(l_index).last_update_login := FND_GLOBAL.LOGIN_ID;
    l_line_tbl(l_index).lock_control := l_line_tbl(l_index).lock_control + 1;

         -- Changes for AFD
          l_line_tbl(l_index).actual_fulfillment_date := l_actual_fulfillment_date;
         -- END CHANGES for AFD

          IF  l_line_tbl(l_index).item_type_code = OE_GLOBALS.G_ITEM_SERVICE /* 2048753 */ THEN
              l_line_rec := l_line_tbl(l_index);
              Update_Service_Dates(l_line_rec);
              l_line_tbl(l_index).service_start_date := l_line_rec.service_start_date;
              l_line_tbl(l_index).service_end_date := l_line_rec.service_end_date;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'AFTER CALLING UPDATE_SERVICE_DATES - ASO INSTALLED' , 5 ) ;
              END IF;
    END IF;

          -- added for notification framework
          --check code release level first. Notification framework is at Pack H level
          IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
             -- calling notification framework to get index position
             OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_header_id=>l_line_tbl(l_index).header_id,
                    p_line_rec=>l_line_tbl(l_index),
                    p_line_id => p_line_tbl(l_index).line_id,
                    x_index => l_notify_index,
                    x_return_status => l_return_status);
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Update_global return status from fulfill_line with line table is: '||l_return_status);
             END IF;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'GLOBAL PICTURE INDEX IS: ' || L_NOTIFY_INDEX , 1 ) ;
             END IF;
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             IF l_notify_index IS NOT NULL THEN
                --update Global Picture directly
                -- Fix for the bug2635911
                -- OE_ORDER_UTIL.g_old_line_tbl(l_notify_index) := l_old_line_tbl(l_index);
                OE_ORDER_UTIL.g_old_line_tbl(l_notify_index) := l_old_line_tbl(1);
                OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id := p_line_tbl(l_index).line_id;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).header_id := p_line_tbl(l_index).header_id;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_flag := p_line_tbl(l_index).fulfilled_flag;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity := p_line_tbl(l_index).fulfilled_quantity;
                IF  p_line_tbl(l_index).fulfilled_quantity2 = 0 then -- 5126873
                	OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity2 := NULL;
                ELSE
                 	OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfilled_quantity2 := p_line_tbl(l_index).fulfilled_quantity2; -- 5126873
                END IF;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).fulfillment_date := p_line_tbl(l_index).fulfillment_date;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_date := SYSDATE;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_updated_by := l_user;  --  3169637
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_login :=FND_GLOBAL.LOGIN_ID;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).service_start_date :=l_line_rec.service_start_date;
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).service_end_date := l_line_rec.service_end_date;
                -- Changes for AFD
                OE_ORDER_UTIL.g_line_tbl(l_notify_index).actual_fulfillment_date := l_actual_fulfillment_date;
                -- end Changes for AFD
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('Line fulfilled_flag is: '||OE_ORDER_UTIL.G_LINE_TBL(L_NOTIFY_INDEX).FULFILLED_FLAG,1);
                END IF;
            END IF;
         END IF; --code_release_level
         -- notification framework end
      ELSIF p_line_tbl(l_index).item_type_code = OE_GLOBALS.G_ITEM_SERVICE  /* 2292133 */
         OR  p_line_tbl(l_index).item_type_code IS NULL -- 2417601
         OR  p_line_tbl(l_index).item_type_code = FND_API.G_MISS_CHAR  THEN -- 2417601
          l_line_rec := p_line_tbl(l_index);
          open srv_lines;
          fetch srv_lines into
            l_line_rec.service_start_date,
            l_line_rec.service_end_date,
            l_line_rec.service_period,
            l_line_rec.service_duration,
            l_line_rec.service_coterminate_flag,
            l_line_rec.item_type_code;
          close srv_lines;
          IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN  -- 2417601
            Update_Service_Dates(l_line_rec);
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('After calling update_service_dates - aso not installed',5) ;
            END IF;
          END IF;
      END IF;  /* IF OE_GLOBALS.G_ASO_INSTALLED */

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Updating line : '||p_line_tbl(l_index).line_id,3) ;
      END IF;

--      IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN --3471423
        IF p_line_tbl(l_index).item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN --3471423
          /* 2417601 uses a different update statements for service line */


          UPDATE  OE_ORDER_LINES_ALL
          SET     FULFILLED_FLAG     = p_line_tbl(l_index).fulfilled_flag,
                  FULFILLED_QUANTITY = p_line_tbl(l_index).fulfilled_quantity,
                  FULFILLED_QUANTITY2 = p_line_tbl(l_index).fulfilled_quantity2, -- 5126873
                  FULFILLMENT_DATE   = p_line_tbl(l_index).fulfillment_date,
                  LAST_UPDATE_DATE   = SYSDATE,
                  LAST_UPDATED_BY    = l_user, -- 3169637
                  LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID,
                  SERVICE_START_DATE = l_line_rec.service_start_date,
                  SERVICE_END_DATE   = l_line_rec.service_end_date,
                  ACTUAL_FULFILLMENT_DATE   = l_actual_fulfillment_date,
                  LOCK_CONTROL = LOCK_CONTROL+1
          WHERE   LINE_ID = p_line_tbl(l_index).line_id;

          /* Start Improved OM,IB,OKS changes */
          select order_number
            into l_order_number
            from oe_order_headers_all
           where header_id = p_line_tbl(l_index).header_id;

          l_Service_Order_Lines(1).Order_Header_ID   :=  p_line_tbl(l_index).header_id;
          l_Service_Order_Lines(1).Order_Line_ID     :=  p_line_tbl(l_index).line_id;
          l_Service_Order_Lines(1).Order_Number      :=  l_order_number;
          l_Service_Order_Lines(1).Ref_Order_Line_ID :=  p_line_tbl(l_index).service_reference_line_id;
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Calling OKS_OMINT_PUB.Interface_Service_Order_Lines:LineID:'
                               || p_line_tbl(l_index).line_id,3) ;
          END IF;

          OKS_OMINT_PUB.Interface_Service_Order_Lines(
                               p_Service_Order_Lines => l_Service_Order_Lines,
                               x_Return_Status       => l_return_status,
                               x_Error_Message       => l_msg_data);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             oe_debug_pub.add('FND_API.G_RET_STS_ERROR after call to OKS_OMINT_PUB.Interface_Service');
             oe_debug_pub.add('l_msg_data' || l_msg_data);
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             oe_debug_pub.add('FND_API.G_RET_STS_UNEXP_ERROR after call to OKS_OMINT_PUB.Interface_Service');
             oe_debug_pub.add('l_msg_data' || l_msg_data);
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          /* End Improved OM,IB,OKS changes */


       ELSE -- 2417601

          UPDATE  OE_ORDER_LINES_ALL
          SET     FULFILLED_FLAG     = p_line_tbl(l_index).fulfilled_flag,
                  FULFILLED_QUANTITY = p_line_tbl(l_index).fulfilled_quantity,
                  FULFILLED_QUANTITY2 = p_line_tbl(l_index).fulfilled_quantity2, -- 5126873
                  FULFILLMENT_DATE   = p_line_tbl(l_index).fulfillment_date,
                  LAST_UPDATE_DATE   = SYSDATE,
                  LAST_UPDATED_BY    = l_user, -- 3169637
                  LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID,
                  ACTUAL_FULFILLMENT_DATE   = l_actual_fulfillment_date,
                  LOCK_CONTROL = LOCK_CONTROL+1
          WHERE   LINE_ID = p_line_tbl(l_index).line_id;


       END IF;  -- 2417601

       -- Added 09-Dec-2002
       -- BLANKETS: Update returned/fulfilled qty
       IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN
        -- Bug 3061559
        -- Use p_line_tbl, not l_line_tbl.
          if l_debug_level > 0 then
             oe_debug_pub.add('OEXVFULB 2, blanket number :'|| p_line_tbl(l_index).blanket_number);
             oe_debug_pub.add('Line ID : '|| p_line_tbl(l_index).line_id);
             oe_debug_pub.add('Fulfilled Qty : '|| p_line_tbl(l_index).fulfilled_quantity);
             oe_debug_pub.add('Fulfilled Qty2 : '|| p_line_tbl(l_index).fulfilled_quantity2); -- 5126873
             oe_debug_pub.add('Item Type : '|| p_line_tbl(l_index).item_type_code);
          end if;
          IF p_line_tbl(l_index).blanket_number IS NOT NULL THEN
             Update_Blanket_Qty(p_line_tbl(l_index)
                      ,p_line_tbl(l_index).fulfilled_quantity);
          END IF;
       END IF;

       oe_debug_pub.add('  FND_PROFILE.VALUE(ONT_AUTO_INTERFACE_LINES_TO_IB) =>>  ' || FND_PROFILE.VALUE('ONT_AUTO_INTERFACE_LINES_TO_IB'), 5);

       IF p_line_tbl(l_index).item_type_code <> OE_GLOBALS.G_ITEM_SERVICE
         AND ( NVL(FND_PROFILE.VALUE('ONT_AUTO_INTERFACE_LINES_TO_IB'),'Y') = 'Y')  -- bug 9245134
       THEN
            oe_debug_pub.add('Before Call to csi_ont_txn_pub.posttransaction',1);
            csi_ont_txn_pub.posttransaction(
            p_order_line_id    =>   p_line_tbl(l_index).line_id,
            x_return_status    => x_return_status,
            x_message_id       => l_message_id,
            x_error_code       => l_error_code,
            x_error_message    => l_error_message);
            oe_debug_pub.add('After Call to csi_ont_txn_pub.posttransaction',1);

            IF  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF l_debug_level  > 0 THEN
               oe_debug_pub.add('raising unexpected error in csi_ont_txn_pub.posttransaction '||sqlerrm,1);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF   x_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add('raising exc error in csi_ont_txn_pub.posttransaction '||sqlerrm,1);
             END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
           END IF;

   END LOOP;

END IF;

/*  Commented for performance changes.
  oe_debug_pub.ADD('Calling OE_Order_PVT.Process_Order to update the fulfilled quantity and fulfilled flag',2);

  OE_GLOBALS.G_RECURSION_MODE := 'Y';
  OE_Shipping_Integration_PVT.Call_Process_Order
  (
    p_line_tbl    => l_update_line_tbl,
    p_control_rec => l_control_rec,
    x_return_status => l_return_status
  );

  OE_GLOBALS.G_RECURSION_MODE := 'N';

  oe_debug_pub.add('Return Status from Process Order : '||l_return_status,2);

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  END IF;
*/
IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN
    IF (OE_GLOBALS.G_ASO_INSTALLED = 'Y') THEN

        -- #2769599
        IF (nvl(oe_order_cache.g_header_rec.header_id,-999)<>p_line_rec.header_id) THEN
            IF l_debug_level > 0 THEN
               OE_DEBUG_PUB.add('Loading header rec from cache : ',5);
            END IF;
            OE_Order_Cache.Load_Order_Header(p_line_rec.header_id);
        END IF;
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.add('Cached header id: '||to_char(oe_order_cache.g_header_rec.header_id), 5);
        END IF;
        OE_Order_PVT.Process_Requests_And_Notify
        ( p_process_requests          => FALSE
        , p_notify                    => TRUE
        , x_return_status             => l_return_status
        , p_line_tbl                  => l_line_tbl
        , p_old_line_tbl              => l_aso_line_tbl
        );


        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURNED FROM PROCESS REQUEST AND NOTIFY : '||L_RETURN_STATUS , 3 ) ;
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF; /* ASO installed */


ELSE
    /* Pack H or higher */
   IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
      ( NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  ) THEN


       OE_ORDER_PVT.Process_Requests_and_Notify
      (p_process_requests          => FALSE
      ,p_notify                    => FALSE
      ,x_return_status             => l_return_status
      ,p_line_tbl                  => l_line_tbl
      ,p_old_line_tbl              => l_aso_line_tbl
      );

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('returned from process request and notify : '||l_return_status,3) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


   END IF;  /* ASO and DBI check for Pack H and higher */

END IF; --code_release_level
IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exiting oe_line_fullfill.fulfill_line()',1) ;
END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN CAN_NOT_LOCK_MODEL THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXVFULB.pls:Fulfill_line API- MODEL LOCKING EXCEPTION' , 1 ) ;
        END IF;
        x_return_status := 'D';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Unexp Error'||sqlerrm,1);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Fulfill_Line');
         END IF;
         G_DEBUG_MSG := G_DEBUG_MSG || 'E6,';
    WHEN FND_API.G_EXC_ERROR THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('EXC Error '||sqlerrm,1);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Error '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Fulfill_Line');
         END IF;
         G_DEBUG_MSG := G_DEBUG_MSG || 'E7,';
END Fulfill_Line;

/*
  This procedure is to get the work flow activity attribute for a given
  item type, item key, activity id and attribute name using work flow
  engine API GetActivityAttrText.
*/

PROCEDURE Get_Activity_Attribute
(
  p_item_type       IN  VARCHAR2
, p_item_key        IN  VARCHAR2
, p_activity_id     IN  VARCHAR2
, p_fulfill_attr_name   IN  VARCHAR2
, x_attribute_value OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

)
IS
  l_errname         VARCHAR2(30);
  l_errmsg          VARCHAR2(2000);
  l_errstack          VARCHAR2(2000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
    x_attribute_value := wf_engine.GetActivityAttrText(p_item_type,p_item_key,p_activity_id,p_fulfill_attr_name);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WORK FLOW ERROR HAS OCCURED ' , 1 ) ;
    END IF;
    WF_CORE.Get_Error(l_errname, l_errmsg, l_errstack);
    IF  l_errname = 'WFENG_ACTIVITY_ATTR' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE '||L_ERRMSG , 1 ) ;
      END IF;
      x_attribute_value := 'NONE';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    END IF;

END Get_Activity_Attribute;

/*
  This API is to get the Activity result code and activity status from work
  flow tables for given item type, item key and activity name
*/

PROCEDURE Get_Activity_Result
(
  p_item_type       IN  VARCHAR2
, p_item_key        IN  VARCHAR2
, p_activity_name     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

, x_activity_result OUT NOCOPY VARCHAR2

, x_activity_status_code OUT NOCOPY VARCHAR2

, x_activity_id OUT NOCOPY NUMBER

)
IS
l_upgraded_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.GET_ACTIVITY_RESULT '|| P_ITEM_TYPE||'/'||P_ITEM_KEY||'/'||P_ACTIVITY_NAME , 1 ) ;
  END IF;

  SELECT  wias.ACTIVITY_STATUS, wias.ACTIVITY_RESULT_CODE, wias.PROCESS_ACTIVITY
  INTO       x_activity_status_code, x_activity_result, x_activity_id
  FROM       WF_ITEM_ACTIVITY_STATUSES wias, WF_PROCESS_ACTIVITIES wpa
  WHERE wias.ITEM_KEY = p_item_key
  AND   wias.ITEM_TYPE  = p_item_type
  AND   wpa.ACTIVITY_NAME = p_activity_name
  AND       wias.PROCESS_ACTIVITY = wpa.INSTANCE_ID;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.GET_ACTIVITY_RESULT '||X_ACTIVITY_RESULT||'/'||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN  NO_DATA_FOUND THEN
  --- commmented for 3589692
  /*
                -- Bug-2791964
                SELECT nvl(upgraded_flag,'N')
                INTO   l_upgraded_flag
                FROM   oe_order_lines
                WHERE  line_id = to_number(p_item_key);

                IF l_upgraded_flag =  'N' THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
                ELSE
             x_return_status := FND_API.G_RET_STS_SUCCESS;
                END IF;
  */
    x_return_status := FND_API.G_RET_STS_ERROR;
          G_DEBUG_MSG := G_DEBUG_MSG || '34,';
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Activity_Result'
        );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;
                  G_DEBUG_MSG := G_DEBUG_MSG || '35,';

END Get_Activity_Result;

/*
  This procedure gets all the lines and sets for a given line_id from
  oe_sets and oe_line_sets tables
*/

PROCEDURE Get_Fulfillment_Set
(
  p_line_id     IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

, x_set_tbl OUT NOCOPY Line_Set_Tbl_Type

)
IS

  CURSOR  c_set IS
  SELECT  OLS.LINE_ID, OLS.SET_ID
  FROM    OE_LINE_SETS OLS, OE_SETS OST
  WHERE OLS.LINE_ID = p_line_id
  AND   OLS.SET_ID  = OST.SET_ID
  AND   OST.SET_TYPE = 'FULFILLMENT_SET';

  l_set_id    NUMBER;

  CURSOR  c_line_set IS
  SELECT  LINE_ID, SET_ID
  FROM    OE_LINE_SETS
  WHERE SET_ID = l_set_id;

  l_set_index   NUMBER := 0;
  l_set_tbl   Line_Set_Tbl_Type;
  l_temp_tbl    Line_Set_Tbl_Type;
  l_return_status VARCHAR2(1);
  l_loop_index  NUMBER := 0;
  l_temp_index  NUMBER := 0;

    l_line_set_exists VARCHAR2(1) := FND_API.G_FALSE;
--Start 7827727
l_line_id_mod    NUMBER;
l_set_id_mod     NUMBER;
--End 7827727

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.GET_FULFILLMENT_SET '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;



  FOR l_set in c_set
  LOOP

    l_set_id  := l_set.set_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SET ID : '||TO_CHAR ( L_SET_ID ) , 3 ) ;
    END IF;

    l_set_id_mod := MOD(l_set_id,G_BINARY_LIMIT); --7827727
    IF g_set_tbl.EXISTS(l_set_id_mod) THEN  --7827727
   -- IF g_set_tbl.EXISTS(l_set_id) THEN
      GOTO END_SET_LOOP;
    END IF;
    --g_set_tbl(l_set_id) := l_set_id;
    g_set_tbl(l_set_id_mod) := l_set_id; --7827727
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SET ID ADDED : '||TO_CHAR ( L_SET_ID ) , 3 ) ;
    END IF;

    FOR l_line_set in c_line_set
    LOOP
      l_line_set_exists := FND_API.G_FALSE;
      FOR l_temp_index IN 1..l_temp_tbl.count
      LOOP

        IF  l_temp_tbl(l_temp_index).line_id = l_line_set.line_id AND
          l_temp_tbl(l_temp_index).set_id = l_set_id THEN
                  IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'LINE EXISTS FOR COMBINATION' , 3 ) ;
                  END IF;
          l_line_set_exists := FND_API.G_TRUE;
          GOTO END_LINE_SET;

        END IF;

                << END_LINE_SET >>
        NULL;
      END LOOP;


      IF  l_line_set_exists = FND_API.G_FALSE THEN
        l_temp_index := l_temp_tbl.count + 1;
        l_temp_tbl(l_temp_index).line_id := l_line_set.line_id;
        l_temp_tbl(l_temp_index).set_id := l_line_set.set_id;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('adding line to set table '||l_temp_tbl(l_temp_index).line_id||'/'||l_temp_tbl(l_temp_index).set_id,5);
        END IF;
      END IF;

      IF  l_line_set.line_id <> p_line_id THEN

        Get_Fulfillment_Set
        (
          p_line_id     => l_line_set.line_id
        , x_return_status   => l_return_status
        , x_set_tbl     => l_set_tbl
        );


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NUMBER OF ROWS RETURNED : '||L_SET_TBL.COUNT , 3 ) ;
        END IF;

        IF  l_set_tbl.COUNT > 0 THEN
          l_loop_index := 0;
          FOR l_loop_index IN l_set_tbl.FIRST .. l_set_tbl.LAST
          LOOP

              l_line_set_exists := FND_API.G_FALSE;
              FOR l_temp_index IN 1..l_temp_tbl.count
              LOOP

                IF  l_temp_tbl(l_temp_index).line_id = l_set_tbl(l_loop_index).line_id AND
                  l_temp_tbl(l_temp_index).set_id = l_set_tbl(l_loop_index).set_id THEN
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'LINE EXISTS FOR COMBINATION' , 3 ) ;
                          END IF;
                  l_line_set_exists := FND_API.G_TRUE;
                  GOTO END_LINE_SET1;

                END IF;

                        << END_LINE_SET1 >>
                NULL;
              END LOOP;

              IF  l_line_set_exists = FND_API.G_FALSE THEN
                l_temp_index := l_temp_tbl.count + 1;
                l_temp_tbl(l_temp_index).line_id := l_set_tbl(l_loop_index).line_id;
                l_temp_tbl(l_temp_index).set_id := l_set_tbl(l_loop_index).set_id;
                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('line does not exist, adding now '||l_temp_tbl(l_temp_index).line_id||'/'||l_temp_tbl(l_temp_index).set_id,3);
                END IF;
              END IF;
          END LOOP;
        END IF;
      END IF;
    END LOOP;

    << END_SET_LOOP >>
    NULL;

  END LOOP;

  l_set_index := l_temp_tbl.FIRST;
  l_loop_index := 0;
  IF l_debug_level>0 THEN
    oe_debug_pub.add('SET table picture',5);
  END IF;

  WHILE l_set_index IS NOT NULL
  LOOP

    l_loop_index := l_loop_index + 1;
    x_set_tbl(l_loop_index).line_id := l_temp_tbl(l_set_index).line_id;
    x_set_tbl(l_loop_index).set_id := l_temp_tbl(l_set_index).set_id;
    l_set_index := l_temp_tbl.NEXT(l_set_index);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE/SET : '||TO_CHAR ( X_SET_TBL ( L_LOOP_INDEX ) .LINE_ID ) ||'/'||TO_CHAR ( X_SET_TBL ( L_LOOP_INDEX ) .SET_ID ) , 3 ) ;
    END IF;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.GET_FULFILLMENT_SET ' , 3 ) ;
  END IF;

EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Unexp Error '||sqlerrm,1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Fulfillment_Set'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E10,';

  WHEN  FND_API.G_EXC_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exc Error '||sqlerrm,1);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('error '||SUBSTR(SQLERRM,1,2000),1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Fulfillment_Set'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E11,';

END Get_Fulfillment_Set;

/*
  This procedure derives the fulfillment activity(method) for a given item
  key and activity id. The fulfillment activity is derived using activity
  attributes FULFILLMENT_ACTIVITY and COMPLETION_RESULT for item 'OEOL' and
  activity FULFILL_LINE. If no FULFILLMENT_ACTIVITY is defined fulfillment
  activity will be returned as 'NO_ACTIVITY'
*/

PROCEDURE Get_Fulfillment_Activity
(
  p_item_key        IN  VARCHAR2
, p_activity_id     IN  NUMBER
, x_fulfillment_activity OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

)
IS
  l_fulfill_attr_name   VARCHAR2(30) := 'FULFILLMENT_ACTIVITY';
  l_in_fulfill_attr_name  VARCHAR2(30) := 'INBOUND_FULFILLMENT_ACTIVITY';
  l_fulfill_activity_name VARCHAR2(30);
  l_item_type       VARCHAR2(8) := OE_GLOBALS.G_WFI_LIN;
  l_result_attr_name    VARCHAR2(30) := 'COMPLETION_RESULT';
  l_in_result_attr_name   VARCHAR2(30) := 'INBOUND_COMPLETION_RESULT';
  l_completion_result   VARCHAR2(30);
  l_activity_result   VARCHAR2(30) := 'NO_RESULT';
  l_activity_status   VARCHAR2(8);
  l_activity_id     NUMBER;
  l_return_status     VARCHAR2(1);
  l_line_category_code  VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_upgraded_flag VARCHAR2(1); -- bug 3589692
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.GET_FULFILLMENT_ACTIVITY '|| P_ITEM_KEY , 1 ) ;
  END IF;


     select line_category_code into l_line_category_code
  from oe_order_lines_all
  where line_id = to_number(p_item_key);

  IF l_line_category_code = 'RETURN' THEN
        l_fulfill_attr_name := l_in_fulfill_attr_name;
        l_result_attr_name := l_in_result_attr_name;
     END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING GET ATTRIBUTE - ACTIVITY ' , 3 ) ;
  END IF;
  Get_Activity_Attribute
  (
    p_item_type       => l_item_type,
    p_item_key        => p_item_key,
    p_activity_id     => p_activity_id,
    p_fulfill_attr_name   => l_fulfill_attr_name,
    x_attribute_value   => l_fulfill_activity_name,
    x_return_status     => l_return_status
  );


  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  l_fulfill_activity_name = 'NONE' OR
    l_fulfill_activity_name IS NULL THEN
    l_fulfill_activity_name := 'NO_ACTIVITY';
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'FULFILLMENT ACTIVITY NAME : '|| L_FULFILL_ACTIVITY_NAME , 3 ) ;
  END IF;
  IF  l_fulfill_activity_name <> 'NO_ACTIVITY' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING GET ATTRIBUTE - RESULT ' , 3 ) ;
    END IF;


    Get_Activity_Attribute
    (
      p_item_type       => l_item_type,
      p_item_key        => p_item_key,
      p_activity_id     => p_activity_id,
      p_fulfill_attr_name   => l_result_attr_name,
      x_attribute_value   => l_completion_result,
      x_return_status     => l_return_status
    );

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF  l_completion_result = 'NONE'OR
      l_completion_result IS NULL THEN
      l_completion_result := 'NO_RESULT';
    ELSE


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'REQUIRED COMPLETION RESULT : '|| L_COMPLETION_RESULT , 3 ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING GET_ACTIVITY_STATUS ' , 3 ) ;
    END IF;

    Get_Activity_Result
    (
      p_item_type     => l_item_type
    , p_item_key      => p_item_key
    , p_activity_name   => l_fulfill_activity_name
    , x_return_status   => l_return_status
    , x_activity_result => l_activity_result
    , x_activity_status_code  => l_activity_status
    , x_activity_id     => l_activity_id
    );

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
      SELECT nvl(upgraded_flag,'N')       -- Bug 3589692
                           INTO   l_upgraded_flag
                           FROM   oe_order_lines
                           WHERE  line_id = to_number(p_item_key);
                        IF l_upgraded_flag =  'N' THEN
                           RAISE FND_API.G_EXC_ERROR;
                        ELSE
                           l_activity_status := OE_GLOBALS.G_WFR_COMPLETE;
                        END IF; -- bug 3589692 ends
    END IF;

    IF  l_activity_status <> OE_GLOBALS.G_WFR_COMPLETE THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    END IF;

    IF  l_completion_result <> 'NO_RESULT' THEN
      IF  l_activity_result <> l_completion_result AND -- added for 1570684
                                nvl(l_activity_result, 'NONE') <> 'OVER_SHIPPED' THEN
        l_fulfill_activity_name := 'NO_ACTIVITY';
      END IF;
    END IF;


  END IF;

  x_fulfillment_activity := l_fulfill_activity_name;
  x_return_status      := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Fulfillment_Activity'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E12,';

    WHEN  FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Get_Fulfillment_Activity'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E13,';


END Get_Fulfillment_Activity;

PROCEDURE Check_PTO_KIT_Fulfillment
(
p_top_model_line_id   IN  NUMBER,
x_fulfill_status OUT NOCOPY VARCHAR2,

x_return_status OUT NOCOPY VARCHAR2

)
IS

  l_top_model_line_id NUMBER;

    CURSOR C_lines IS
  SELECT LINE_ID,
       FULFILLED_FLAG
    FROM   OE_ORDER_LINES
  WHERE  TOP_MODEL_LINE_ID = l_top_model_line_id
  AND    OPEN_FLAG = 'Y';

  l_activity_status VARCHAR2(8);
  l_activity_result VARCHAR2(30);
  l_activity_id   NUMBER;
  l_item_key      VARCHAR2(240);
  l_fulfill_activity  VARCHAR2(30)  := 'FULFILL_LINE';
  l_return_status   VARCHAR2(1);
  l_fulfill_status  VARCHAR2(1) := FND_API.G_TRUE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.CHECK_PTO_KIT_FULFILLMENT '|| TO_CHAR ( P_TOP_MODEL_LINE_ID ) , 1 ) ;
  END IF;


  l_top_model_line_id := p_top_model_line_id;

    FOR  l_top_lines IN c_lines
  LOOP

    l_item_key := to_char(l_top_lines.line_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR ITEM : '||L_ITEM_KEY||'/'||L_FULFILL_ACTIVITY , 3 ) ;
    END IF;

    Get_Activity_Result
    (
      p_item_type       => OE_GLOBALS.G_WFI_LIN
    , p_item_key        => l_item_key
    , p_activity_name     => l_fulfill_activity
    , x_return_status     => l_return_status
    , x_activity_result   => l_activity_result
    , x_activity_status_code  => l_activity_status
    , x_activity_id     => l_activity_id
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS||'/'||L_ACTIVITY_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR OR
        l_activity_status <> 'NOTIFIED' THEN
        l_fulfill_status := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS NOT FULFILLED : '||TO_CHAR ( L_TOP_LINES.LINE_ID ) , 3 ) ;
        END IF;
        GOTO END_CHECK_LOOP;
    END IF;

    END LOOP;


    << END_CHECK_LOOP >>

  x_fulfill_status := l_fulfill_status;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.CHECK_PTO_KIT_FULFILLMENT '||L_FULFILL_STATUS||'/'||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION

  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Check_PTO_KIT_Fulfillment'
        );
      END IF;
      G_DEBUG_MSG := G_DEBUG_MSG || 'E14-1,';

    WHEN  FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          G_DEBUG_MSG := G_DEBUG_MSG || 'E14-2,';
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Check_PTO_KIT_Fulfillment'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E14-3,';

END Check_PTO_KIT_Fulfillment;

PROCEDURE Fulfill_PTO_KIT
(
p_top_model_line_id   IN NUMBER,
x_return_status OUT NOCOPY VARCHAR2
)
IS
l_top_model_line_id NUMBER;
l_return_status   VARCHAR2(1);
l_line_tbl    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl    OE_Order_PUB.Line_Tbl_Type;
l_index                 NUMBER;
--Changes for AFD
l_ordered_date          DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
CAN_NOT_LOCK_MODEL          EXCEPTION;

CURSOR C_fulfill_lines IS
       SELECT LINE_ID,
              HEADER_ID,
        FULFILLED_FLAG
       FROM   OE_ORDER_LINES
       WHERE  TOP_MODEL_LINE_ID = l_top_model_line_id
       AND    OPEN_FLAG = 'Y';
BEGIN

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Entering oe_line_fullfill.fulfill_pto_kit() '||to_char(p_top_model_line_id),1) ;
END IF;

l_top_model_line_id := p_top_model_line_id;
FOR  l_top_lines IN c_fulfill_lines LOOP
     IF nvl(l_top_lines.fulfilled_flag,'N') = 'N' THEN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('line is not fulfilled '||l_top_lines.line_id,3) ;
  END IF;
        OE_Line_Util.Lock_Rows
      (p_line_id    => l_top_lines.line_id
      ,x_line_tbl   => l_old_line_tbl
      ,x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE CAN_NOT_LOCK_MODEL;
     -- RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  l_line_tbl := l_old_line_tbl;
  l_line_tbl(1).fulfilled_flag := 'Y';
  l_line_tbl(1).fulfilled_quantity := nvl(l_line_tbl(1).shipped_quantity,l_line_tbl(1).ordered_quantity);
  l_line_tbl(1).fulfillment_date := SYSDATE;

        -- CHANGES for AFD
        IF l_ordered_date is null THEN
            select ordered_date into l_ordered_date
            from oe_order_headers_all
            where header_id = l_line_tbl(1).header_id;
        END IF;

        l_line_tbl(1).actual_fulfillment_date := nvl(l_line_tbl(1).actual_shipment_date,nvl(l_line_tbl(1).order_firmed_date,l_ordered_date));
        -- end CHANGES for AFD

        update oe_order_lines
        set    fulfilled_flag = l_line_tbl(1).fulfilled_flag,
         fulfilled_quantity = l_line_tbl(1).fulfilled_quantity,
         fulfillment_date = l_line_tbl(1).fulfillment_date,
               actual_fulfillment_date = l_line_tbl(1).actual_fulfillment_date,
               lock_control = lock_control+1
  where  line_id = l_line_tbl(1).line_id;

        -- added for notification framework
        -- check code release level first.
        -- Notification framework is at Pack H level
        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
           -- calling notification framework to get index position
           OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_header_id=>l_line_tbl(1).header_id,
                    p_old_line_rec => l_old_line_tbl(1),
                    p_line_rec =>l_line_tbl(1),
                    p_line_id =>l_line_tbl(1).line_id ,
                    x_index => l_index,
                    x_return_status => l_return_status);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('update_global return status for line ID '||L_LINE_TBL(1).LINE_ID||'IS:'||l_return_status,1) ;
              oe_debug_pub.add('update_global index in fulfill_pto_kit for line_id '||l_line_tbl(1).LINE_ID ||' is: '||l_index,1);
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
           IF l_index IS NOT NULL THEN
               --update Global Picture directly
              OE_ORDER_UTIL.g_old_line_tbl(l_index) := l_old_line_tbl(1);
              OE_ORDER_UTIL.g_line_tbl(l_index) := OE_ORDER_UTIL.g_old_line_tbl(l_index);
              OE_ORDER_UTIL.g_line_tbl(l_index).header_id:= l_line_tbl(1).header_id;
              OE_ORDER_UTIL.g_line_tbl(l_index).line_id:= l_line_tbl(1).line_id;
              OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date:= l_line_tbl(1).last_update_date;
              OE_ORDER_UTIL.g_line_tbl(l_index).fulfilled_flag := l_line_tbl(1).fulfilled_flag;
              OE_ORDER_UTIL.g_line_tbl(l_index).fulfilled_quantity := l_line_tbl(1).fulfilled_quantity;
              OE_ORDER_UTIL.g_line_tbl(l_index).fulfillment_date := l_line_tbl(1).fulfillment_date;
              -- Changes for AFD
              OE_ORDER_UTIL.g_line_tbl(l_index).actual_fulfillment_date := l_line_tbl(1).actual_fulfillment_date;
              -- end Changes for AFD
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('global line fulfilled_flag is: '||OE_ORDER_UTIL.G_LINE_TBL(l_index).fulfilled_flag,1) ;
              END IF;
           END IF;



           /* Call Process Requests and Notify also since this does not call PO */
           /* p_notify will be seto False in this case as the Event Notification */
           /* framework does not look at this flag */
           OE_Order_PVT.Process_Requests_And_Notify
                       (p_process_requests          => FALSE
                       ,p_notify                    => FALSE
                       ,x_return_status             => l_return_status
                       ,p_line_tbl                  => l_line_tbl
                       ,p_old_line_tbl              => l_old_line_tbl
                       );
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        ELSE /*pre-pack H*/

           -- #2769599
           IF (nvl(oe_order_cache.g_header_rec.header_id,-999)<>l_top_lines.header_id) THEN
                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.add('Loading header rec from cache : ',5);
                END IF;
                OE_Order_Cache.Load_Order_Header(l_top_lines.header_id);
           END IF;
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.add('Cached header id: '||to_char(oe_order_cache.g_header_rec.header_id), 5);
           END IF;
           OE_Order_PVT.Process_Requests_And_Notify
           ( p_process_requests          => FALSE
           , p_notify                    => TRUE
           , x_return_status             => l_return_status
           , p_line_tbl                  => l_line_tbl
           , p_old_line_tbl              => l_old_line_tbl
           );


         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

        END IF; -- code_release_level
    END IF;

    OE_Order_WF_Util.Update_Flow_Status_Code
    (p_line_id            =>  l_top_lines.line_id,
     p_flow_status_code     =>  'FULFILLED',
     x_return_status      =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Return status from flow status '||l_return_status,3) ;
    END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
  oe_debug_pub.add('Fulfill associated service lines' , 3 ) ;
    END IF;

    Fulfill_Service_Lines
    (
  p_line_id   =>  l_top_lines.line_id,
  p_header_id   =>  l_top_lines.header_id,   --  1717444
  x_return_status =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Return status from fulfill service lines '||l_return_status , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
  RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Calling wf_engine.completeactivityinternalname '||to_char(l_top_lines.line_id),3) ;
    END IF;
    wf_engine.CompleteActivityInternalName('OEOL', to_char(l_top_lines.line_id), 'FULFILL_LINE', '#NULL');
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('returned from wf_engine.completeactivityinternalname '||to_char ( l_top_lines.line_id ) , 3 ) ;
    END IF;

END LOOP;

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Exiting oe_line_fullfill.fulfill_pto_kit '||x_return_status,3) ;
END IF;

EXCEPTION

WHEN CAN_NOT_LOCK_MODEL THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXVSHPB.pls:Fulfill_PTO_KIT-MODEL LOCKING EXCEPTION', 1 ) ;
     END IF;
     x_return_status := 'D' ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
  OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Fulfill_PTO_KIT');
     END IF;
     G_DEBUG_MSG := G_DEBUG_MSG || 'E15,';
WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     G_DEBUG_MSG := G_DEBUG_MSG || 'E16,';
WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF l_debug_level  > 0 THEN
  oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
     END IF;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
  OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Fulfill_PTO_KIT');
     END IF;
     G_DEBUG_MSG := G_DEBUG_MSG || 'E17,';
END Fulfill_PTO_KIT;

/*
  This procedure is to do the processing of fulfillment for a line which is
  part of a PTO/KIT. This procedure checks if all the lines which have a
  fulfillment activity have been fulfilled or not. If all such lines are
  fulfilled then all the lines which don't have any fulfillment activity
  gets fulfilled, else the lines will wait at FULFILL_LINE workflow activity
  untill all the lines of MODEL are fulfilled. This procedure returns
  fulfillment status True if all the lines are fulfilled, else will return
  FALSE.
*/
-- 5126873   - PTO KIT not supported for dual controlled items so no need to calculate fulfilled quantity2
PROCEDURE Process_PTO_KIT
(
  p_line_id       IN  NUMBER
, p_top_model_line_id   IN  NUMBER
, p_fulfillment_activity  IN  VARCHAR2
, p_process_all     IN  VARCHAR2
,   p_part_of_fullfillment_set  IN  BOOLEAN := FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_fulfillment_status OUT NOCOPY VARCHAr2

)
IS
  l_line_tbl      OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_tbl   OE_Order_Pub.Line_Tbl_Type;
  l_service_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_service_index     NUMBER;
  l_line_index    NUMBER;
  l_fulfill_index   NUMBER := 0 ;
  l_fulfilled_flag  VARCHAR2(1) := FND_API.G_TRUE;
  l_return_status   VARCHAR2(1);
  l_line_id     NUMBER;
  l_activity_status VARCHAR2(8);
  l_activity_result VARCHAR2(30);
  l_activity_id   NUMBER;
  l_item_key      VARCHAR2(240);
  l_fulfill_activity  VARCHAR2(30)  := 'FULFILL_LINE';
  l_count                 NUMBER;
  l_item_type_code        VARCHAR2(30);
  l_ato_line_id           NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  -- 4640517
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(2000);
  l_hold_result_out           VARCHAR2(30):= 'TRUE';

  TYPE Fulfill_Service_Rec  IS RECORD
  (
    line_id       NUMBER := FND_API.G_MISS_NUM
  , header_id     NUMBER := FND_API.G_MISS_NUM
  );

  TYPE Fulfill_Service_Tbl IS TABLE OF Fulfill_Service_Rec
    INDEX BY BINARY_INTEGER;

  l_fulfill_service_tbl       Fulfill_Service_Tbl;
  l_fulfill_service_index     NUMBER :=0;

    CURSOR pto_kit_lines IS
    SELECT line_id, item_type_code, shippable_flag, fulfilled_flag
    FROM OE_ORDER_LINES
    WHERE top_model_line_id = p_top_model_line_id
    AND open_flag = 'Y';
--
BEGIN

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('enter Process_Pto_Kit() for line '||to_char(p_line_id),1);
   oe_debug_pub.add('fulfillment activity - '||p_fulfillment_activity,1);
   oe_debug_pub.add('process all - '||p_process_all,1);
END IF;

  IF p_line_id = p_top_model_line_id THEN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('model line is at fulfillment, top model is '||p_top_model_line_id,1);
   END IF;

    -- bug 3974488 changes starts
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Profile value OM: Allow Model Fulfillment  = '||NVL(FND_PROFILE.VALUE('ONT_ALLOW_MODEL_FULFILL_WITHOUT_CONFIG'),'N'),1);
    END IF;

    IF NVL(FND_PROFILE.VALUE('ONT_ALLOW_MODEL_FULFILL_WITHOUT_CONFIG'),'N') = 'N' THEN

      SELECT count(*)
      INTO   l_count
      FROM   oe_order_lines
      WHERE  top_model_line_id = p_line_id;


      IF l_count = 1 THEN

         SELECT item_type_code,ato_line_id
         INTO   l_item_type_code,l_ato_line_id
         FROM   oe_order_lines
         WHERE  line_id = p_line_id;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('No child lines yet for the model' , 1 ) ;
         END IF;


           IF p_fulfillment_activity = 'NO_ACTIVITY' THEN

              IF l_item_type_code = 'MODEL' THEN

                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CAN NOT FULFILL MODEL YET!!' , 1 ) ;
                 END IF;

                 l_fulfilled_flag := FND_API.G_FALSE;
                 GOTO END_PTO_KIT_LOOP;

              END IF;
           END IF;
      END IF;
    END IF; -- Allow model filfillment profile
  END IF;


/* Following loop is being changed to loop thru the cursor instead of
   the line table because of performance changes
*/


  FOR l_pto_kit_lines IN pto_kit_lines
  LOOP

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('line ID - '||to_char(l_pto_kit_lines.line_id),5);
       oe_debug_pub.add('item type/shippable - '||l_pto_kit_lines.item_type_code||'/'||l_pto_kit_lines.shippable_flag,5);
    END IF;


    IF  l_pto_kit_lines.line_id <> p_line_id OR
      p_process_all = FND_API.G_TRUE THEN
      IF  l_pto_kit_lines.fulfilled_flag = 'Y' THEN
        l_fulfilled_flag := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('line '||l_pto_kit_lines.line_id||' is already fulfilled ',5);
        END IF;
      ELSE

        l_item_key := to_char(l_pto_kit_lines.line_id);

        IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('call Get_Activity_Result() for item - '||l_item_key||'/'||l_fulfill_activity,5);
        END IF;

        Get_Activity_Result
        (
          p_item_type       => OE_GLOBALS.G_WFI_LIN
        , p_item_key        => l_item_key
        , p_activity_name     => l_fulfill_activity
        , x_return_status     => l_return_status
        , x_activity_result   => l_activity_result
        , x_activity_status_code  => l_activity_status
        , x_activity_id     => l_activity_id
        );

        IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('return status - '||l_return_status||'/'||l_activity_status,5);
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF   l_return_status = FND_API.G_RET_STS_ERROR OR
            l_activity_status <> 'NOTIFIED' THEN
            l_fulfilled_flag := FND_API.G_FALSE;
            x_fulfillment_status := FND_API.G_FALSE;
            IF l_debug_level  > 0 THEN
		    oe_debug_pub.add('line '||l_pto_kit_lines.line_id||' is not fulfilled ',5);
            END IF;
            GOTO END_PTO_KIT_LOOP;
        END IF;
           -- 4640517, models with autoselected components are entered after the line is booked
           -- The model goes to Config Hold but the autoselected components progress to Fulfill/Closed
           -- Through this fix, if the model is at Config Hold, stop the components at Awaiting Fulfillment

           IF p_top_model_line_id is not NULL then

              SELECT item_type_code,ato_line_id
              INTO   l_item_type_code,l_ato_line_id
              FROM   oe_order_lines
              WHERE  line_id = p_line_id;

              IF l_Debug_level > 0 THEN
                 oe_Debug_pub.add('item type '||l_item_type_code||','||l_ato_line_id||','||l_fulfilled_flag||','||p_line_id||','||p_top_model_line_id,1);
              END IF;
              IF  l_pto_kit_lines.line_id = l_ato_line_id THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Check if Model in configuration validation hold (hold ID 3) ' , 1 ) ;
                  END IF;

                  OE_HOLDS_PUB.CHECK_HOLDS
                  ( p_api_version       => 1.0,
                    p_line_id           => p_line_id,
                    p_hold_id           => 3,
                    x_result_out        => l_hold_result_out,
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data);

                  oe_debug_pub.add('after model check '||l_hold_result_out,1);

                  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                     IF l_hold_result_out = FND_API.G_TRUE THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('Model on Hold - CAN NOT FULFILL MODEL YET!!' , 1 ) ;
                        END IF;
                        l_fulfilled_flag := FND_API.G_FALSE;
                        GOTO END_PTO_KIT_LOOP;
                     END IF;
                  END IF;
              END IF;
           END IF;

        /* If the line is at fulfill line work flow activity and the
        fulfilled flag is not set it will be a line without fulfillment
        activity. So for the purpose of Configuration fulfillment it
        will can be considered as fulfilled */

        l_fulfilled_flag := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS FULFILLED : '||TO_CHAR ( L_PTO_KIT_LINES.LINE_ID ) , 3 ) ;
        END IF;
      END IF;
    END IF;

  END LOOP;
  << END_PTO_KIT_LOOP >>

    IF  l_fulfilled_flag = FND_API.G_TRUE AND  p_part_of_fullfillment_set THEN

        x_fulfillment_status := l_fulfilled_flag;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('line is part of fulfillment set',1);
        END IF;
        RETURN;
    END IF;

  IF  l_fulfilled_flag = FND_API.G_TRUE THEN

    -- Prepare the table to update the fulfilled quantity and fulfilled
    -- flag for derived lines.

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('now all the related lines are fulfilled',1);
      oe_debug_pub.add('call Query_Options() '||to_char(sysdate,'DD-MM-YYYY HH24:MI:SS'),5);
    END IF;

    OE_Config_Util.Query_Options(p_top_model_line_id  =>  p_top_model_line_id,
                   x_line_tbl       =>  l_line_tbl);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('after Query_Options() '||to_char(sysdate,'DD-MM-YYYY HH24:MI:SS'),5);
    END IF;


    FOR l_line_index IN 1 .. l_line_tbl.count
    LOOP

      IF l_debug_level  > 0 THEN
	  oe_debug_pub.add('index/line_id/fulfilled :'||l_line_index||'/'||l_line_tbl(l_line_index).line_id||'/'||l_line_tbl(l_line_index).fulfilled_flag,5);
      END IF;
      IF      (l_line_tbl(l_line_index).line_id <> p_line_id  OR
         p_process_all = FND_API.G_TRUE) AND
        nvl(l_line_tbl(l_line_index).fulfilled_flag,'N') <> 'Y' THEN

        l_fulfill_index := l_fulfill_index + 1;
        l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
        l_fulfill_tbl(l_fulfill_index).line_id := l_line_tbl(l_line_index).line_id;
        l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
        l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
        l_fulfill_tbl(l_fulfill_index).fulfilled_quantity := nvl(l_line_tbl(l_line_index).shipped_quantity,l_line_tbl(l_line_index).ordered_quantity);
                                -- Bug 3061559
                                -- Copy fields used in blankets processing
                    l_fulfill_tbl(l_fulfill_index).blanket_number := l_line_tbl(l_line_index).blanket_number;
                    l_fulfill_tbl(l_fulfill_index).blanket_line_number := l_line_tbl(l_line_index).blanket_line_number;
                    l_fulfill_tbl(l_fulfill_index).order_quantity_uom := l_line_tbl(l_line_index).order_quantity_uom;
                    l_fulfill_tbl(l_fulfill_index).item_type_code := l_line_tbl(l_line_index).item_type_code;
                    l_fulfill_tbl(l_fulfill_index).line_category_code := l_line_tbl(l_line_index).line_category_code;
                    l_fulfill_tbl(l_fulfill_index).unit_selling_price := l_line_tbl(l_line_index).unit_selling_price;
                    l_fulfill_tbl(l_fulfill_index).header_id := l_line_tbl(l_line_index).header_id;
                    l_fulfill_tbl(l_fulfill_index).inventory_item_id := l_line_tbl(l_line_index).inventory_item_id;
                                -- End bug 3061559
                                -- changes for AFD
                                l_fulfill_tbl(l_fulfill_index).actual_shipment_date := l_line_tbl(l_line_index).actual_shipment_date;
                                l_fulfill_tbl(l_fulfill_index).order_firmed_date := l_line_tbl(l_line_index).order_firmed_date;
                                -- end of changes for AFD


        l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;
        IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('index - '||l_fulfill_index,5);
	      oe_debug_pub.add('fulfilled flag - '||l_fulfill_tbl(l_fulfill_index).fulfilled_flag,5);
	      oe_debug_pub.add('quantity - '||l_fulfill_tbl(l_fulfill_index).fulfilled_quantity,5);
        END IF;
      END IF;

      /* Get the service lines if there are any associated with the
         lines of the Model              */

            Get_Service_Lines
      (
        p_line_id   => l_line_tbl(l_line_index).line_id,
        p_header_id   => l_line_tbl(l_line_index).header_id, -- 1717444
        x_return_status => l_return_status,
        x_line_tbl    => l_service_tbl
            );

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          GOTO END_FULFILL_LOOP;
            END IF;

      /* Add service lines to l_fulfill_tbl for fulfillment */

      FOR l_service_index IN 1 .. l_service_tbl.count
      LOOP
        l_fulfill_index := l_fulfill_index + 1;
        l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
        l_fulfill_tbl(l_fulfill_index).line_id := l_service_tbl(l_service_index).line_id;
        l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
        l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
        l_fulfill_tbl(l_fulfill_index).fulfilled_quantity := nvl(l_service_tbl(l_service_index).shipped_quantity,l_service_tbl(l_service_index).ordered_quantity);
                                -- Bug 3061559
                                -- Copy fields used in blankets processing
                    l_fulfill_tbl(l_fulfill_index).blanket_number := l_service_tbl(l_service_index).blanket_number;
                    l_fulfill_tbl(l_fulfill_index).blanket_line_number := l_service_tbl(l_service_index).blanket_line_number;
                    l_fulfill_tbl(l_fulfill_index).order_quantity_uom := l_service_tbl(l_service_index).order_quantity_uom;
                    l_fulfill_tbl(l_fulfill_index).item_type_code := l_service_tbl(l_service_index).item_type_code;
                    l_fulfill_tbl(l_fulfill_index).line_category_code := l_service_tbl(l_service_index).line_category_code;
                    l_fulfill_tbl(l_fulfill_index).unit_selling_price := l_service_tbl(l_service_index).unit_selling_price;
                    l_fulfill_tbl(l_fulfill_index).header_id := l_service_tbl(l_service_index).header_id;
                    l_fulfill_tbl(l_fulfill_index).inventory_item_id := l_service_tbl(l_service_index).inventory_item_id;
                                -- End bug 3061559
                                -- changes for AFD
                                l_fulfill_tbl(l_fulfill_index).actual_shipment_date := l_service_tbl(l_service_index).actual_shipment_date;
                                l_fulfill_tbl(l_fulfill_index).order_firmed_date := l_service_tbl(l_service_index).order_firmed_date;
                                -- end changes for AFD

        l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;
	   IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('index - '||l_fulfill_index,5);
	      oe_debug_pub.add('fulfilled flag - '||l_fulfill_tbl(l_fulfill_index).fulfilled_flag,5);
	      oe_debug_pub.add('fulfilled quantity - '||l_fulfill_tbl(l_fulfill_index).fulfilled_quantity,5);
	   END IF;


        /* Add to the fulfill service table for completing
           the FULFILL_LINE workflow activity */

                l_fulfill_service_index := l_fulfill_service_index + 1;
        l_fulfill_service_tbl(l_fulfill_service_index).line_id := l_service_tbl(l_service_index).line_id;
        l_fulfill_service_tbl(l_fulfill_service_index).header_id := l_service_tbl(l_service_index).header_id;

           IF l_debug_level  > 0 THEN
	      oe_debug_pub.add('service fulfill index - '||l_fulfill_service_index,5);
	      oe_debug_pub.add('line id - '||l_fulfill_service_tbl(l_fulfill_service_index).line_id,5);
	   END IF;

      END LOOP;


            << END_FULFILL_LOOP >>
      NULL;

    END LOOP;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('call Fulfill_Line() with full picture ',5);
   END IF;

    Fulfill_Line
    (
      p_line_tbl      =>  l_fulfill_tbl,
      p_mode        =>  'TABLE',
      p_fulfillment_type  =>  G_FULFILL_WITH_ACTIVITY,
      p_fulfillment_activity => p_fulfillment_activity,
      x_return_status   =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Complete the FULFILL_LINE activity for the fulfilled lines.

    FOR l_line_index IN 1 .. l_line_tbl.count
    LOOP
      IF  l_line_tbl(l_line_index).line_id <> p_line_id OR
        p_process_all = FND_API.G_TRUE THEN
        l_line_id := l_line_tbl(l_line_index).line_id;

	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('update the flow status code on the lines ',5);
	  END IF;

        OE_Order_WF_Util.Update_Flow_Status_Code
            (p_line_id            =>  l_line_tbl(l_line_index).line_id,
            p_flow_status_code    =>  'FULFILLED',
            x_return_status       =>  l_return_status
            );

	  IF l_debug_level  > 0 THEN
             oe_debug_pub.add('after update of flow status '||l_return_status,5);
          END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

	  IF l_debug_level  > 0 THEN
             oe_debug_pub.add('** complete the WF activity on this '||l_line_id,1);
	  END IF;
            wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_id), 'FULFILL_LINE', '#NULL');
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('after wf complete ',5);
	  END IF;

      END IF;
    END LOOP;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('*** process the service lines now ***',1);
   END IF;

     IF  l_fulfill_service_index <> 0 THEN


      FOR l_fulfill_service_index IN 1 .. l_fulfill_service_tbl.count
      LOOP
        l_line_id := l_fulfill_service_tbl(l_fulfill_service_index).line_id;

	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('update flow status for - '||l_line_id,5);
	  END IF;

        OE_Order_WF_Util.Update_Flow_Status_Code
            (p_line_id            =>  l_fulfill_service_tbl(l_fulfill_service_index).line_id,
            p_flow_status_code    =>  'FULFILLED',
            x_return_status       =>  l_return_status
            );

	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
	  END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

          IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('call complete WF for this service line - '||l_line_id,5);
	  END IF;
            wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_id), 'FULFILL_LINE', '#NULL');
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('after WF complete ',5);
	  END IF;

      END LOOP;

    END IF;

  END IF;

  x_fulfillment_status := l_fulfilled_flag;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level  > 0 THEN
   oe_debug_pub.add('** complete OE_Line_Fullfill.Process_PTO_Kit() ',1);
END IF;

EXCEPTION
    WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('*** 1. Error -  '||SUBSTR(SQLERRM,1,200),1);
	  END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Process_PTO_KIT');
	  END IF;

    WHEN  FND_API.G_EXC_ERROR THEN
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('*** 2. Error -  '||SUBSTR(SQLERRM,1,200),1);
	  END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN  OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add('*** 3. Error -  '||SUBSTR(SQLERRM,1,200),1);
	  END IF;

	  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Process_PTO_KIT');
	  END IF;

END Process_PTO_KIT;

/*
  This procedure is for processing of fulfillment prcessing of a line which
  is part of fulfillment set(s). This procedure returns TRUE if all the
  lines of all the fulfillment set(s) to which this line is linked to are
  fulfilled, else will return FALSE. If a line's fulfilled flag is not set
  to 'Y' and the line is waiting at FULFILL_LINE work flow activity the line
  will be considered to be fulfilled if all the other lines of the
  fulfillment set are fulfilled.
*/
PROCEDURE Process_Fulfillment_Set
(
  p_line_id       IN  NUMBER
, p_fulfillment_activity  IN  VARCHAR2
, p_line_set_tbl      IN  Line_Set_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

, x_fulfillment_status OUT NOCOPY VARCHAR2

)
IS
  l_line_set_index    NUMBER := 0;
  l_prev_set_id     NUMBER := 0;
  l_line_rec        OE_ORDER_PUB.Line_Rec_Type;
  l_fulfilled_flag    VARCHAR2(1) := FND_API.G_TRUE;
  l_item_key        VARCHAR2(240);
  l_fulfill_activity    VARCHAR2(30) := 'FULFILL_LINE';
  l_activity_status   VARCHAR2(8);
  l_activity_result   VARCHAR2(30);
  l_activity_id     NUMBER;
  l_return_status     VARCHAR2(1);
  TYPE line_tbl IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
  l_line_tbl        line_tbl;
  l_line_tbl_index    NUMBER;
  TYPE set_tbl IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
  l_set_tbl       set_tbl;
  l_set_tbl_index   NUMBER := 0;
  l_fulfill_tbl     OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_index     NUMBER := 0 ;
  l_process_tbl     Line_Set_Tbl_Type;
  l_process_index     NUMBER := 0;
  l_fulfillment_status  VARCHAR2(1);
  l_process_all     VARCHAR2(1) := FND_API.G_TRUE;
  l_top_model_line_id   NUMBER;
  l_header_id       NUMBER;
  l_service_tbl           OE_Order_Pub.Line_Tbl_Type;
  l_service_index         NUMBER;
  --Start 7827727
  l_line_id_mod          NUMBER;
  l_set_id_mod           NUMBER;
  --End 7827727
        -- Bug 3061559
        -- Select fields used in blankets processing
        CURSOR c_line(l_cursor_line_id IN NUMBER) IS
            SELECT HEADER_ID,
                   BLANKET_NUMBER,
                   BLANKET_LINE_NUMBER,
                   ORDER_QUANTITY_UOM,
                   ITEM_TYPE_CODE,
                   LINE_CATEGORY_CODE,
                   UNIT_SELLING_PRICE,
                   INVENTORY_ITEM_ID,
                   -- changes for AFD
                   ACTUAL_SHIPMENT_DATE,
                   ORDER_FIRMED_DATE
            FROM OE_ORDER_LINES_ALL
            WHERE LINE_ID = l_cursor_line_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.PROCESS_FULFILLMENT_SET '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;

  /* Prepare a table of line and set id's to be processed. This new table
     will have indication whether it is a standard line or a configuration. */


  FOR l_line_set_index IN p_line_set_tbl.FIRST .. p_line_set_tbl.LAST
  LOOP

--    l_line_rec  :=  OE_Line_Util.Query_Row(p_line_set_tbl(l_line_set_index).line_id);
    OE_Line_Util.Query_Row(p_line_id => p_line_set_tbl(l_line_set_index).line_id,
                 x_line_rec => l_line_rec);
    l_set_id_mod :=
MOD(p_line_set_tbl(l_line_set_index).set_id,G_BINARY_LIMIT);--7827727

    --IF  NOT l_set_tbl.EXISTS(p_line_set_tbl(l_line_set_index).set_id) THEN
    IF  NOT l_set_tbl.EXISTS(l_set_id_mod) THEN --7827727
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SET ID ADDED : '||TO_CHAR ( P_LINE_SET_TBL ( L_LINE_SET_INDEX ) .SET_ID ) , 3 ) ;
      END IF;
      --l_set_tbl(p_line_set_tbl(l_line_set_index).set_id) := p_line_set_tbl(l_line_set_index).set_id;
     l_set_tbl(l_set_id_mod) := p_line_set_tbl(l_line_set_index).set_id; --7827727

    END IF;

    IF  l_line_rec.top_model_line_id IS NOT NULL AND
      l_line_rec.top_model_line_id <> FND_API.G_MISS_NUM THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE IS PART OF A CONFIGURATION : '||TO_CHAR ( L_LINE_REC.LINE_ID ) ||'/'||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
      END IF;

      l_process_index := l_process_index + 1;
      l_process_tbl(l_process_index) := p_line_set_tbl(l_line_set_index);
      l_process_tbl(l_process_index).fulfilled_flag := l_line_rec.fulfilled_flag;
      l_process_tbl(l_process_index).ordered_quantity := l_line_rec.ordered_quantity;

      IF  l_line_rec.top_model_line_id = l_line_rec.line_id THEN
        l_process_tbl(l_process_index).type := 'C';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE HAS BEEN ADDED AS CONFIGURATION LINE : '||TO_CHAR ( L_LINE_REC.LINE_ID ) ||'/'||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
        END IF;
            ELSE
        l_process_tbl(l_process_index).type := 'O';
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE HAS BEEN ADDED AS OPTION LINE : '||TO_CHAR ( L_LINE_REC.LINE_ID ) ||'/'||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
        END IF;

      END IF;
    ELSE
      l_process_index := l_process_index + 1;
      l_process_tbl(l_process_index) := p_line_set_tbl(l_line_set_index);
      l_process_tbl(l_process_index).type := 'S';
      l_process_tbl(l_process_index).fulfilled_flag := l_line_rec.fulfilled_flag;
      l_process_tbl(l_process_index).ordered_quantity := l_line_rec.ordered_quantity;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE HAS BEEN ADDED AS STANDARD LINE : '||TO_CHAR ( L_LINE_REC.LINE_ID ) ||'/'||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
      END IF;

    END IF;
  END LOOP;



  FOR l_line_set_index IN l_process_tbl.FIRST .. l_process_tbl.LAST
  LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE ID/SET ID : '|| TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) ||'/'||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .SET_ID ) , 3 ) ;
    END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE TYPE : '||L_PROCESS_TBL ( L_LINE_SET_INDEX ) .TYPE , 3 ) ;
        END IF;
    IF  l_process_tbl(l_line_set_index).type = 'C' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IT IS A CONFIGURATION TOP MODEL ' , 3 ) ;
      END IF;

--      l_line_rec  :=  OE_Line_Util.Query_Row(p_line_id);

      SELECT  TOP_MODEL_LINE_ID
      INTO  l_top_model_line_id
      FROM  OE_ORDER_LINES
      WHERE LINE_ID = p_line_id;


      IF  l_top_model_line_id = nvl(l_process_tbl(l_line_set_index).line_id,0) THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DO NOT PROCESS ALL THE LINES ' , 3 ) ;
        END IF;
        l_process_all := FND_API.G_FALSE;
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS ALL THE LINES ' , 3 ) ;
        END IF;
        l_process_all := FND_API.G_TRUE;
      END IF;


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING PROCESS PTO FULFILLMENT ' , 3 ) ;
      END IF;
      Process_PTO_KIT
      (
        p_line_id       => p_line_id,
        p_top_model_line_id   => l_process_tbl(l_line_set_index).line_id,
        p_fulfillment_activity  => p_fulfillment_activity,
        p_process_all     => l_process_all,
                p_part_of_fullfillment_set      => TRUE,
        x_return_status     => l_return_status,
        x_fulfillment_status  => l_fulfillment_status
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS/FULFILLMENT STATUS : '||L_RETURN_STATUS||'/'||L_FULFILLMENT_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF  l_fulfillment_status = FND_API.G_TRUE THEN
        l_fulfilled_flag := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CONFIGURATION IS FULFILLED : '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;
      ELSE
        l_fulfilled_flag := FND_API.G_FALSE;
        x_fulfillment_status := FND_API.G_FALSE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CONFIGURATION IS NOT FULFILLED : '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;
        GOTO END_CHECK_FULFILLMENT;
      END IF;
    END IF;

    IF  p_line_id <> l_process_tbl(l_line_set_index).line_id AND
      l_process_tbl(l_line_set_index).type = 'S' THEN

      IF  l_process_tbl(l_line_set_index).fulfilled_flag = 'Y' THEN
        l_fulfilled_flag := FND_API.G_TRUE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS FULFILLED : '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;
      ELSE

        l_item_key := to_char(l_process_tbl(l_line_set_index).line_id);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR ITEM : '||L_ITEM_KEY||'/'||L_FULFILL_ACTIVITY , 3 ) ;
        END IF;

        Get_Activity_Result
        (
          p_item_type       => OE_GLOBALS.G_WFI_LIN
        , p_item_key        => l_item_key
        , p_activity_name     => l_fulfill_activity
        , x_return_status     => l_return_status
        , x_activity_result   => l_activity_result
        , x_activity_status_code  => l_activity_status
        , x_activity_id     => l_activity_id
        );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS||L_ACTIVITY_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF   l_return_status = FND_API.G_RET_STS_ERROR OR
            l_activity_status <> 'NOTIFIED' THEN
            l_fulfilled_flag := FND_API.G_FALSE;
            x_fulfillment_status := FND_API.G_FALSE;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE IS NOT FULFILLED : '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
            END IF;
            GOTO END_CHECK_FULFILLMENT;
        END IF;

    /* If the line is at fulfill line work flow activity and the
    fulfilled flag is not set it will be a line without fulfillment
    activity. So for the purpose of fulfillment set fulfillment it will
    can be considered as fulfilled */

        l_fulfilled_flag := FND_API.G_TRUE;

      END IF;

    END IF;

  END LOOP;
  << END_CHECK_FULFILLMENT >>


  /* If the fulfilled flag after the above loop is TRUE, complete the
     fulfill line work flow for all the lines except the current line */

  IF  l_fulfilled_flag = FND_API.G_TRUE THEN

    /* Prepare a table of lines which have not been fulfilled to update
       the fulfillment related attributes  and comlpete the fulfill line */

    FOR l_line_set_index IN 1 .. l_process_tbl.count
    LOOP
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE ID/SET ID : '|| TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) ||'/'||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .SET_ID ) , 3 ) ;
      END IF;

            /* Get the associated service lines */

      --IF  NOT l_line_tbl.EXISTS(l_process_tbl(l_line_set_index).line_id) THEN
      IF  NOT
       l_line_tbl.EXISTS(MOD(l_process_tbl(l_line_set_index).line_id,G_BINARY_LIMIT))
      THEN --7827727

              Get_Service_Lines
        (
          p_line_id   => l_process_tbl(l_line_set_index).line_id,
          x_return_status => l_return_status,
          x_line_tbl    => l_service_tbl
              );

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            GOTO END_SERVICE_LINE;
              END IF;

      /* Add service lines to l_fulfill_tbl for fulfillment */

        FOR l_service_index IN 1 .. l_service_tbl.count
        LOOP
         l_line_id_mod:=MOD(l_service_tbl(l_service_index).line_id,G_BINARY_LIMIT);--7827727
          --IF  NOT l_line_tbl.EXISTS(l_service_tbl(l_service_index).line_id) THEN
          IF NOT l_line_tbl.EXISTS(l_line_id_mod) THEN --7827727
          l_fulfill_index := l_fulfill_index + 1;
          l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
          l_fulfill_tbl(l_fulfill_index).line_id := l_service_tbl(l_service_index).line_id;
          l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
          l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
          l_fulfill_tbl(l_fulfill_index).fulfilled_quantity := nvl(l_service_tbl(l_service_index).shipped_quantity,l_service_tbl(l_service_index).ordered_quantity);
                                        -- Bug 3061559
                                        -- Copy fields used in blankets processing
                            l_fulfill_tbl(l_fulfill_index).blanket_number := l_service_tbl(l_service_index).blanket_number;
                            l_fulfill_tbl(l_fulfill_index).blanket_line_number := l_service_tbl(l_service_index).blanket_line_number;
                            l_fulfill_tbl(l_fulfill_index).order_quantity_uom := l_service_tbl(l_service_index).order_quantity_uom;
                            l_fulfill_tbl(l_fulfill_index).item_type_code := l_service_tbl(l_service_index).item_type_code;
                            l_fulfill_tbl(l_fulfill_index).line_category_code := l_service_tbl(l_service_index).line_category_code;
                            l_fulfill_tbl(l_fulfill_index).unit_selling_price := l_service_tbl(l_service_index).unit_selling_price;
                            l_fulfill_tbl(l_fulfill_index).header_id := l_service_tbl(l_service_index).header_id;
                            l_fulfill_tbl(l_fulfill_index).inventory_item_id := l_service_tbl(l_service_index).inventory_item_id;
                                        -- End bug 3061559
                                        -- changes for AFD
                                        l_fulfill_tbl(l_fulfill_index).actual_shipment_date := l_service_tbl(l_service_index).actual_shipment_date;
                                        l_fulfill_tbl(l_fulfill_index).order_firmed_date := l_service_tbl(l_service_index).order_firmed_date;
                                        -- end changes for AFD

          l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'FULFILL INDEX : '||TO_CHAR ( L_FULFILL_INDEX ) , 3 ) ;
              oe_debug_pub.add(  'FULFILLED FLAG : '||L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_FLAG , 3 ) ;
              oe_debug_pub.add(  'FULFILLED QUANTITY : '||TO_CHAR ( L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_QUANTITY ) , 3 ) ;
          END IF;


          --l_line_tbl(l_service_tbl(l_service_index).line_id) := l_service_tbl(l_service_index).line_id;
          l_line_tbl(l_line_id_mod) :=l_service_tbl(l_service_index).line_id;--7827727
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SERVICE LINE IS ADDED TO TABLE '||TO_CHAR ( L_SERVICE_TBL ( L_SERVICE_INDEX ) .LINE_ID ) , 3 ) ;
          END IF;

          END IF;

        END LOOP;

      END IF;

            << END_SERVICE_LINE >>

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE ID/SET ID AFTER SERVICE : '|| TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) ||'/'||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .SET_ID ) , 3 ) ;
      END IF;
      l_line_id_mod:=MOD(l_process_tbl(l_line_set_index).line_id,G_BINARY_LIMIT);--7827727
      IF  p_line_id <> l_process_tbl(l_line_set_index).line_id AND
        NOT l_line_tbl.EXISTS(l_line_id_mod) THEN  --7827727
        --NOT l_line_tbl.EXISTS(l_process_tbl(l_line_set_index).line_id) THEN
        --l_line_tbl(l_process_tbl(l_line_set_index).line_id) := l_process_tbl(l_line_set_index).line_id;
        l_line_tbl(l_line_id_mod) :=l_process_tbl(l_line_set_index).line_id; --7827727
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS ADDED TO TABLE '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;

        /* If the line is not fulfilled earlier add this to fulfill
        table for updating the fulfillment related attributes on the
        line */

        IF  nvl(l_process_tbl(l_line_set_index).fulfilled_flag,'N') <> 'Y' THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'THE LINE IS NOT FULFILLED '||TO_CHAR ( L_PROCESS_TBL ( L_LINE_SET_INDEX ) .LINE_ID ) , 3 ) ;
          END IF;

          l_fulfill_index := l_fulfill_index + 1;
          l_fulfill_tbl(l_fulfill_index):= OE_Order_PUB.G_MISS_LINE_REC;
          l_fulfill_tbl(l_fulfill_index).line_id := l_process_tbl(l_line_set_index).line_id;
          l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
          l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
          l_fulfill_tbl(l_fulfill_index).fulfilled_quantity := nvl(l_process_tbl(l_line_set_index).ordered_quantity,l_process_tbl(l_line_set_index).ordered_quantity);
                                        -- Bug 3061559
                                        -- Copy fields used in blankets processing
                                        OPEN c_line(l_fulfill_tbl(l_fulfill_index).line_id);
                                        FETCH c_line INTO
                                              l_fulfill_tbl(l_fulfill_index).header_id,
                                              l_fulfill_tbl(l_fulfill_index).blanket_number,
                                              l_fulfill_tbl(l_fulfill_index).blanket_line_number,
                                              l_fulfill_tbl(l_fulfill_index).order_quantity_uom,
                                              l_fulfill_tbl(l_fulfill_index).item_type_code,
                                              l_fulfill_tbl(l_fulfill_index).line_category_code,
                                              l_fulfill_tbl(l_fulfill_index).unit_selling_price,
                                              l_fulfill_tbl(l_fulfill_index).inventory_item_id,
                  -- Changes for AFD
                                              l_fulfill_tbl(l_fulfill_index).actual_shipment_date,
                                              l_fulfill_tbl(l_fulfill_index).order_firmed_date;
                                        -- end Changes for AFD

                                        CLOSE c_line;
                                        -- End bug 3061559
          l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'FULFILL INDEX : '||TO_CHAR ( L_FULFILL_INDEX ) , 3 ) ;
              oe_debug_pub.add(  'FULFILLED FLAG : '||L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_FLAG , 3 ) ;
              oe_debug_pub.add(  'FULFILLED QUANTITY : '||TO_CHAR ( L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_QUANTITY ) , 3 ) ;
          END IF;
                ELSE

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS FULFILLED ' , 3 ) ;
          END IF;

        END IF;
      END IF;
    END LOOP;

    IF  l_fulfill_index <> 0 THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING FULFILL LINE TABLE : ' , 3 ) ;
      END IF;


      Fulfill_Line
      (
        p_line_tbl      =>  l_fulfill_tbl,
        p_mode        =>  'TABLE',
        p_fulfillment_type  =>  G_FULFILL_WITH_ACTIVITY,
        p_fulfillment_activity => p_fulfillment_activity,
        x_return_status   =>  l_return_status
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    l_line_tbl_index := l_line_tbl.FIRST;

    WHILE l_line_tbl_index IS NOT NULL
    LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
        END IF;

--        l_line_rec  :=  OE_Line_Util.Query_Row(l_line_tbl(l_line_tbl_index));

/*
        SELECT  HEADER_ID
        INTO  l_header_id
        FROM  OE_ORDER_LINES
        WHERE LINE_ID = l_line_tbl(l_line_tbl_index);
*/
        OE_Order_WF_Util.Update_Flow_Status_Code
            (p_line_id            =>  l_line_tbl(l_line_tbl_index),
            p_flow_status_code    =>  'FULFILLED',
            x_return_status       =>  l_return_status
            );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_TBL ( L_LINE_TBL_INDEX ) ) , 3 ) ;
        END IF;
              wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_tbl(l_line_tbl_index)), 'FULFILL_LINE', '#NULL');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_TBL ( L_LINE_TBL_INDEX ) ) , 3 ) ;
        END IF;

        l_line_tbl_index := l_line_tbl.NEXT(l_line_tbl_index);
    END LOOP;

    -- Update the set status in oe_sets to closed.
    l_set_tbl_index := l_set_tbl.FIRST;

    WHILE l_set_tbl_index IS NOT NULL
    LOOP
        -- 3772947
        UPDATE  OE_SETS
        SET SET_STATUS  = 'C',
            UPDATE_DATE = SYSDATE
        WHERE SET_ID = l_set_tbl(l_set_tbl_index);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SET IS CLOSED : '||TO_CHAR ( L_SET_TBL ( L_SET_TBL_INDEX ) ) , 3 ) ;
        END IF;
        l_set_tbl_index := l_set_tbl.NEXT(l_set_tbl_index);

	OE_Set_util.g_set_rec.set_status := 'C'; -- 4080531

    END LOOP;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_fulfillment_status := l_fulfilled_flag;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.PROCESS_FULFILLMENT_SET '||X_RETURN_STATUS||'/'||X_FULFILLMENT_STATUS , 1 ) ;
  END IF;


EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Process_Fulfillment_Set'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E20,';

    WHEN  FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E20-1,';
  WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Process_Fulfillment_Set'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E21,';

END Process_Fulfillment_Set;
/*
  This procedure is called when a line reaches FULFILL_LINE work flow
  activity. It gets the fulfillment activity for the line if the line
  has a fulfillment activity it updates the fulfilled quantity, flag and
  fulfillment date for the line. If the line is part of a MODEL the
  fulfillment processing for PTO/KIT will take place, if the line is part
  of fulfillment set(s) fulfillment processing for a fulfillment set will
  take place. If the line is part of a remnant MODEL the FULILL_LINE work
  flow activity will be completed for the line. If the line is not part of
  either MODEL or fulfillment set, the FULFILL_LINE work flow activity will
  be set to COMPLETE. If the line does not have a fulfillment activity and
  is not part of MODEL or fulfillment set, the fulfilled quantity will be
  updated from the ordered quantity of the line and FULFILL_LINE activity
  will be completed.
*/

PROCEDURE Process_Fulfillment
(
  p_api_version_number  IN  NUMBER
, p_line_id       IN  NUMBER
, p_activity_id     IN  NUMBER
, x_result_out OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY VARCHAR2

, x_msg_data OUT NOCOPY VARCHAR2

)
IS

  l_line_rec          OE_Order_Pub.Line_Rec_Type;
  l_return_status       VARCHAR2(1);
  l_item_key          VARCHAR2(240);
  l_fulfillment_activity    VARCHAR2(30);
  l_fulfillment_type      VARCHAR2(30);
  l_set_tbl         Line_Set_Tbl_Type;
  l_fulfillment_status    VARCHAR2(1);
  l_flow_status_code      VARCHAR2(30);
  l_activity_status     VARCHAR2(8);
  l_activity_result     VARCHAR2(30);
  l_activity_id       NUMBER;
  l_line_tbl          OE_Order_Pub.Line_Tbl_Type;
  l_line_index        NUMBER;
  l_config_index        NUMBER := 0;
  l_fulfill_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_index       NUMBER := 0 ;
  l_service_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_service_index       NUMBER := 0 ;
  l_line_id         NUMBER;
  l_fulfilled_flag      VARCHAR2(1);
  l_top_model_line_id     NUMBER;
  l_set_id          NUMBER;
  l_header_id       NUMBER;
  l_ref_header_id       NUMBER;  -- 1717444
  lock_set_id       NUMBER;
  CAN_NOT_LOCK_MODEL          EXCEPTION;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.PROCESS_FULFILLMENT '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;



--  l_line_rec  :=  OE_Line_Util.Query_Row(p_line_id);
  OE_Line_Util.Query_Row(p_line_id  =>  p_line_id,
             x_line_rec =>  l_line_rec);

   OE_MSG_PUB.set_msg_context(
      p_entity_code                => 'LINE'
     ,p_entity_id                  => l_line_rec.line_id
     ,p_header_id                  => l_line_rec.header_id
     ,p_line_id                    => l_line_rec.line_id
     ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
     ,p_change_sequence            => l_line_rec.change_sequence
     ,p_source_document_id         => l_line_rec.source_document_id
     ,p_source_document_line_id    => l_line_rec.source_document_line_id
     ,p_order_source_id            => l_line_rec.order_source_id
     ,p_source_document_type_id    => l_line_rec.source_document_type_id);

  x_result_out := 'COMPLETE:#NULL';

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('check if this line is part of fulfillment set ',5);
  END IF;

  g_set_tbl.delete;



  Get_Fulfillment_Set
  (
    p_line_id     => l_line_rec.line_id
  , x_return_status   => l_return_status
  , x_set_tbl     => l_set_tbl
  );


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURN STATUS FROM GET FULFILLMENT SET : '||L_RETURN_STATUS||'/'||TO_CHAR ( L_SET_TBL.COUNT ) , 3 ) ;
  END IF;

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('unexp error while getting fulfillment set info '||sqlerrm,1);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('exc error while getting fulfillment set info '||sqlerrm,1);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /* Lock the relevent lines */

  BEGIN
    IF l_set_tbl.count > 0 THEN
      IF g_set_tbl.count > 1 THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('LOCKING HEADER '||L_LINE_REC.HEADER_ID||'/'||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
        END IF;

        SELECT HEADER_ID
        INTO   l_header_id
        FROM   OE_ORDER_HEADERS
        WHERE  HEADER_ID = l_line_rec.header_id
        FOR UPDATE NOWAIT;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('header locked successfully ',1);
        END IF;

      ELSE
        lock_set_id := g_set_tbl.FIRST;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'locking set with ID '||LOCK_SET_ID||' at '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
        END IF;

        SELECT SET_ID
        INTO   l_set_id
        FROM   OE_SETS
        WHERE  SET_ID = lock_set_id
        FOR UPDATE NOWAIT;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'set locked successfully ',1);
        END IF;
      END IF;
   END IF;

    IF nvl(l_line_rec.top_model_line_id,0) <> 0 THEN  --bug 4189737, the ELSIF was changed to a IF condition
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('this line is part of configuration',5);
        oe_debug_pub.add('locking while configuration at '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),5);
      END IF;

      SELECT line_id, top_model_line_id
      INTO   l_line_id, l_top_model_line_id
      FROM   oe_order_lines
      WHERE  line_id = l_line_rec.top_model_line_id
      FOR UPDATE NOWAIT;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('configuration locked successfully',1);
      END IF;
       /* Fix for bug 2560644 */

    ELSIF l_line_rec.item_type_code = 'SERVICE' AND
          l_line_rec.service_reference_line_id IS NOT NULL AND
          l_line_rec.service_reference_type_code = 'ORDER' THEN
       IF l_debug_level  > 0 THEN
        oe_debug_pub.add('this is a service line now at fulfillment '|| L_LINE_REC.SERVICE_REFERENCE_TYPE_CODE,5);
      END IF;

      /* First lock the product */

      SELECT top_model_line_id
      INTO   l_top_model_line_id
      FROM   oe_order_lines
      WHERE  line_id = l_line_rec.service_reference_line_id
      FOR UPDATE NOWAIT;

      IF nvl(l_top_model_line_id,0) <> 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('locking the parent model line of this service line '||L_TOP_MODEL_LINE_ID,1);
        END IF;

        SELECT line_id
        INTO   l_line_id
        FROM   oe_order_lines
        WHERE  line_id = l_top_model_line_id
        FOR UPDATE NOWAIT;

      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('locking the parent reference line of this service line '||L_TOP_MODEL_LINE_ID,1);
        END IF;
        SELECT line_id
        INTO   l_line_id
        FROM   oe_order_lines
        WHERE  line_id = l_line_rec.service_reference_line_id
        FOR UPDATE NOWAIT;

      END IF;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('product lines locked successfully '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
      END IF;

      SELECT line_id
      INTO   l_line_id
      FROM   oe_order_lines
      WHERE  line_id = l_line_rec.line_id
      FOR UPDATE NOWAIT;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('locked the service line '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
      END IF;
    /* fix for bug 2517485 */
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('locking the current line '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
      END IF;

      SELECT line_id
      INTO   l_line_id
      FROM   oe_order_lines
      WHERE  line_id = l_line_rec.line_id
      FOR UPDATE NOWAIT;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE LOCKED '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
      END IF;

    END IF;

  EXCEPTION
         WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
         -- some one else is currently working on the line
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('unable to lock the lines or configuration',1);
           END IF;
           G_DEBUG_MSG := G_DEBUG_MSG || 'ELOCK1,';
           RAISE CAN_NOT_LOCK_MODEL;
    END;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ACTIVTITY ID : '||TO_CHAR ( P_ACTIVITY_ID ) , 3 ) ;
  END IF;
  l_item_key := to_char(p_line_id);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING GET FULFILLMENT ACTIVITY ' , 3 ) ;
  END IF;

  Get_Fulfillment_Activity
  (
    p_item_key        =>  l_item_key,
    p_activity_id     =>  p_activity_id,
    x_fulfillment_activity  =>  l_fulfillment_activity,
    x_return_status     =>  l_return_status
  );



  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'FULFILLMENT ACTIVITY : '|| L_FULFILLMENT_ACTIVITY , 3 ) ;
  END IF;



  IF  l_fulfillment_activity <> 'NO_ACTIVITY' THEN
    l_fulfillment_type := G_FULFILL_WITH_ACTIVITY;

    -- Fulfill Line.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FULFILL LINE WITH : '|| L_FULFILLMENT_TYPE||'/'||L_FULFILLMENT_ACTIVITY , 3 ) ;
    END IF;


    Fulfill_Line
    (
      p_line_rec      =>  l_line_rec,
      p_mode        =>  'RECORD',
      p_fulfillment_type  =>  l_fulfillment_type,
      p_fulfillment_activity => l_fulfillment_activity,
      x_return_status   =>  l_return_status
    );


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF l_return_status = 'D' THEN
       RAISE CAN_NOT_LOCK_MODEL;
    ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    l_fulfillment_type := G_FULFILL_NO_ACTIVITY;
    --l_fulfillment_activity := FND_API.G_MISS_CHAR;
  END IF;

  IF  l_set_tbl.count > 0 THEN
    -- Processing for Fulfillment set
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS LINE PART OF A FULFILLMENT SET' , 3 ) ;
    END IF;



      Process_Fulfillment_Set
      (
        p_line_id       => l_line_rec.line_id,
        p_fulfillment_activity  => l_fulfillment_activity,
        p_line_set_tbl      => l_set_tbl,
        x_return_status     => l_return_status,
        x_fulfillment_status  => l_fulfillment_status
      );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS/FULFILLMENT STATUS : '||L_RETURN_STATUS||'/'||L_FULFILLMENT_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF  l_fulfillment_status = FND_API.G_FALSE THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ALL THE LINES OF THE FULFILLMENT SET HAS NOT BEEN FULFILLED' , 3 ) ;
        END IF;
        x_result_out := 'NOTIFIED:#NULL';
               ELSIF l_fulfillment_type = G_FULFILL_NO_ACTIVITY THEN



        Fulfill_Line
        (
          p_line_rec      =>  l_line_rec,
          p_mode        =>  'RECORD',
          p_fulfillment_type  =>  l_fulfillment_type,
          p_fulfillment_activity => l_fulfillment_activity,
          x_return_status   =>  l_return_status
        );

        IF l_return_status = 'D' THEN
          RAISE CAN_NOT_LOCK_MODEL;
        ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;



  ELSIF l_line_rec.top_model_line_id IS NOT NULL AND
    l_line_rec.top_model_line_id <> FND_API.G_MISS_NUM THEN

    -- Processing for PTO/ATO/KIT
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS LINE PART OF A PTO' , 3 ) ;
    END IF;

    -- Processing for Remnant Model



    IF  l_line_rec.model_remnant_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE IS PART OF REMNANT MODEL '||TO_CHAR ( L_LINE_REC.LINE_ID ) , 3 ) ;
      END IF;



                        -- Bug-2376255
                        SELECT fulfilled_flag
                        INTO   l_fulfilled_flag
                        FROM   oe_order_lines
                        WHERE  Line_id = l_line_rec.line_id;



      IF nvl(l_fulfilled_flag,'N') = 'N'
           --bug 6394191 AND Condition Added
      AND nvl(l_line_rec.ato_line_id,0) = 0 THEN -- Bug-2376255
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING FULFILL LINE WITH : '|| G_FULFILL_NO_ACTIVITY , 3 ) ;
      END IF;

      Fulfill_Line
      (
        p_line_rec      =>  l_line_rec,
        p_mode        =>  'RECORD',
        p_fulfillment_type  =>  G_FULFILL_NO_ACTIVITY,
        p_fulfillment_activity => l_fulfillment_activity,
        x_return_status   =>  l_return_status
      );

      IF l_return_status = 'D' THEN
        RAISE CAN_NOT_LOCK_MODEL;
      ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      END IF; /* fulfilled _flag */
        --bug 6394191 ATO Remnant Model Processing Modified ****Start
          IF  l_line_rec.ato_line_id IS NOT NULL AND l_line_rec.ato_line_id <> FND_API.G_MISS_NUM then --AND
              --(l_line_rec.item_type_code = 'CONFIG' OR (l_line_rec.item_type_code = 'CLASS' AND
                --  l_line_rec.ato_line_id = l_line_rec.line_id)) THEN

                 IF  l_debug_level  > 0 THEN
                     oe_debug_pub.add('line is part of ATO sub configuration ',5);
                 END IF;

		 IF  l_line_rec.ato_line_id = l_line_rec.line_id THEN
                    IF  l_debug_level  > 0 THEN
		   oe_debug_pub.add('Model line of ATO sub configuration ',5);
		    END IF;
                 END IF;

                  IF l_line_rec.item_type_code = 'CONFIG'  THEN
		      IF  l_debug_level  > 0 THEN
                         oe_debug_pub.add('config line of ATO sub configuration ',5);
                     END IF;
                  END IF;

		 OE_Config_Util.Query_ATO_Options( p_ato_line_id  =>  l_line_rec.ato_line_id,
                                                   x_line_tbl     =>  l_line_tbl);

		  FOR l_line_index IN l_line_tbl.FIRST .. l_line_tbl.LAST LOOP


		    IF l_line_tbl(l_line_index).line_id <> p_line_id  THEN
                      IF  l_debug_level  > 0 THEN
                         oe_debug_pub.add('call Get_Activity_Result() - '||L_ITEM_KEY , 3 ) ;
                      END IF;
                      l_item_key := to_char(l_line_tbl(l_line_index).line_id);

                     Get_Activity_Result
                     (
                       p_item_type       => OE_GLOBALS.G_WFI_LIN
                     , p_item_key        => l_item_key
                     , p_activity_name     => 'FULFILL_LINE'
                     , x_return_status     => l_return_status
                     , x_activity_result   => l_activity_result
                     , x_activity_status_code  => l_activity_status
                     , x_activity_id     => l_activity_id
                     );

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add('return status - '||L_RETURN_STATUS , 3 ) ;
			 oe_debug_pub.add('activity status - '||l_activity_status , 3 ) ;
                     END IF;
                    /*Added for bug 8790623*/
		     IF l_activity_status = 'DEFERRED' THEN
		        wf_item_activity_status.create_status('OEOL',to_char(l_item_key),l_activity_id,'NOTIFIED',NULL,SYSDATE,null);
                        l_activity_status:= NULL ;
		     END IF ;
		     /*Added for bug 8790623*/

                     IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add('The ATO line is not at fulfillment '||TO_CHAR ( L_LINE_REC.ATO_LINE_ID ) , 3 ) ;
                         END IF;
                         x_result_out := 'NOTIFIED:#NULL';
                         GOTO END_ATO_REMNANT;
                     END IF;
                    END IF;
                   END LOOP;

                    FOR l_line_index IN l_line_tbl.FIRST .. l_line_tbl.LAST LOOP
                       Fulfill_Line
                       ( p_line_rec      =>  l_line_tbl(l_line_index),
	                 p_mode        =>  'RECORD',
                         p_fulfillment_type  =>  G_FULFILL_NO_ACTIVITY,
                         p_fulfillment_activity => l_fulfillment_activity,
                         x_return_status   =>  l_return_status
                       );

                         IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                         ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                         END IF;


                      IF l_line_tbl(l_line_index).line_id <> p_line_id THEN
		           IF l_debug_level  > 0 THEN
                            oe_debug_pub.add('update flow status code',5);
                         END IF;

                         OE_Order_WF_Util.Update_Flow_Status_Code
                           (p_line_id            =>  l_line_tbl(l_line_index).line_id,
                            p_flow_status_code    =>  'FULFILLED',
                            x_return_status       =>  l_return_status
                            );

                         IF l_debug_level  > 0 THEN
                            oe_debug_pub.add('return status - '||L_RETURN_STATUS,5);
                         END IF;

                         IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                         END IF;


                         IF l_debug_level  > 0 THEN
                            oe_debug_pub.add('complete the WF activity for line - '||L_LINE_TBL(L_LINE_INDEX).LINE_ID,5) ;
                         END IF;

                         wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_tbl(l_line_index).line_id), 'FULFILL_LINE', '#NULL');

                         IF l_debug_level  > 0 THEN
                            oe_debug_pub.add('after wf complete ',5);
                         END IF;
                       END IF;

                     IF  l_debug_level  > 0 THEN
                         oe_debug_pub.add('now fulfill the associated service lines of '||L_LINE_TBL(L_LINE_INDEX).LINE_ID,5);
                     END IF;

                     Fulfill_Service_Lines
                     (
                       p_line_id   =>  l_line_tbl(l_line_index).line_id,
                       p_header_id   =>  l_line_tbl(l_line_index).header_id,    -- 1717444
                       x_return_status =>  l_return_status
                     );

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add('return status - '||L_RETURN_STATUS , 3 ) ;
                     END IF;

                     IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
                     END IF;
		  END LOOP;
--bug6394191 Remnant ATO Model Processing Modified **End

--Old Processing Commented Below
    /*  IF  l_line_rec.ato_line_id IS NOT NULL AND
        l_line_rec.ato_line_id <> FND_API.G_MISS_NUM AND
                 fix for bug 2206098
                (l_line_rec.item_type_code = 'CONFIG' OR
                 (l_line_rec.item_type_code = 'CLASS' AND
                  l_line_rec.ato_line_id = l_line_rec.line_id)) THEN



        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS PART OF ATO SUB CONFIG ' , 3 ) ;
        END IF;

        IF  l_line_rec.ato_line_id = l_line_rec.line_id THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'MODEL LINE OF ATO SUB CONFIG ' , 3 ) ;
          END IF;

          l_line_tbl := OE_Config_Util.Query_Options(l_line_rec.top_model_line_id);
          OE_Config_Util.Query_Options(p_top_model_line_id  =>  l_line_rec.top_model_line_id,
                         x_line_tbl       =>  l_line_tbl);
          FOR l_line_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
          LOOP
            IF  l_line_tbl(l_line_index).ato_line_id = l_line_rec.ato_line_id AND
              l_line_tbl(l_line_index).item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
              l_config_index := l_line_index;
              GOTO CONFIG_FOUND;
            END IF;

          END LOOP;
          << CONFIG_FOUND >>

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CONFIG LINE OF ATO SUB CONFIG '||L_LINE_TBL ( L_CONFIG_INDEX ) .LINE_ID , 3 ) ;
          END IF;


          l_item_key := to_char(l_line_tbl(l_config_index).line_id);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR ITEM : '||L_ITEM_KEY , 3 ) ;
          END IF;

          Get_Activity_Result
          (
            p_item_type       => OE_GLOBALS.G_WFI_LIN
          , p_item_key        => l_item_key
          , p_activity_name     => 'FULFILL_LINE'
          , x_return_status     => l_return_status
          , x_activity_result   => l_activity_result
          , x_activity_status_code  => l_activity_status
          , x_activity_id     => l_activity_id
          );


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS , 3 ) ;
          END IF;

          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CONFIG LINE IS NOT AT FULFILLMENT : '||TO_CHAR ( L_LINE_REC.ATO_LINE_ID ) , 3 ) ;
              END IF;
              x_result_out := 'NOTIFIED:#NULL';
              GOTO END_ATO_REMNANT;
          END IF;

          /* bug 4460242 */
          --  Move update flow status code only when NOTIFIED status
          -- and before we do complete that activity


          /* Complete CONFIG if it is notified
          IF l_activity_status = 'NOTIFIED' THEN
              -- bug 4460242 start
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
              END IF;

              OE_Order_WF_Util.Update_Flow_Status_Code
                (p_line_id            =>  l_line_tbl(l_config_index).line_id,
                 p_flow_status_code    =>  'FULFILLED',
                 x_return_status       =>  l_return_status
                 );

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
              END IF;

              IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- end of bug 4460242

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME FOR CONFIG LINE OF ATO SUB CONFIG '|| TO_CHAR ( L_LINE_TBL ( L_CONFIG_INDEX ) .LINE_ID ) , 3 ) ;
              END IF;

              wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_tbl(l_config_index).line_id), 'FULFILL_LINE', '#NULL');
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_TBL ( L_CONFIG_INDEX ) .LINE_ID ) , 3 ) ;
              END IF;

          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '||L_LINE_TBL ( L_CONFIG_INDEX ) .LINE_ID , 3 ) ;
          END IF;

          Fulfill_Service_Lines
          (
            p_line_id   =>  l_line_tbl(l_config_index).line_id,
            p_header_id   =>  l_line_tbl(l_config_index).header_id,    -- 1717444
            x_return_status =>  l_return_status
          );


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
          END IF;

          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CONFIG LINE OF ATO SUB CONFIG '||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
          END IF;

          l_item_key := to_char(l_line_rec.ato_line_id);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR ITEM : '||L_ITEM_KEY , 3 ) ;
          END IF;

          Get_Activity_Result
          (
            p_item_type       => OE_GLOBALS.G_WFI_LIN
          , p_item_key        => l_item_key
          , p_activity_name     => 'FULFILL_LINE'
          , x_return_status     => l_return_status
          , x_activity_result   => l_activity_result
          , x_activity_status_code  => l_activity_status
          , x_activity_id     => l_activity_id
          );

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS||'/'||L_ACTIVITY_STATUS , 3 ) ;
          END IF;

          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'MODEL LINE IS NOT AT FULFILLMENT : '||TO_CHAR ( L_LINE_REC.ATO_LINE_ID ) , 3 ) ;
              END IF;
              x_result_out := 'NOTIFIED:#NULL';
              GOTO END_ATO_REMNANT;
          END IF;

          -- bug 4460242
          -- move update_flow_status inside IF NOTIFIED loop

          /* Complete ATO MODEL if it is notified
          IF l_activity_status = 'NOTIFIED' THEN
              -- bug 4460242 start
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
              END IF;

              OE_Order_WF_Util.Update_Flow_Status_Code
                (p_line_id            =>  l_line_rec.ato_line_id,
                 p_flow_status_code    =>  'FULFILLED',
                 x_return_status       =>  l_return_status
                 );

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
               END IF;

               IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
               -- bug 4460242 end

               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME FOR MODEL LINE OF ATO SUB CONFIG '|| TO_CHAR ( L_LINE_REC.ATO_LINE_ID ) , 3 ) ;
               END IF;

               wf_engine.CompleteActivityInternalName('OEOL', to_char(l_line_rec.ato_line_id), 'FULFILL_LINE', '#NULL');
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_LINE_REC.ATO_LINE_ID ) , 3 ) ;
               END IF;

          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '||L_LINE_REC.ATO_LINE_ID , 3 ) ;
          END IF;

          Fulfill_Service_Lines
          (
            p_line_id   =>  l_line_rec.ato_line_id,
            p_header_id   =>  l_line_rec.header_id, -- 1717444
            x_return_status =>  l_return_status
          );


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
          END IF;

          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;*/


        << END_ATO_REMNANT >>
        NULL;
               ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '||L_LINE_REC.LINE_ID , 3 ) ;
        END IF;

        Fulfill_Service_Lines
        (
          p_line_id   =>  l_line_rec.line_id,
          p_header_id   =>  l_line_rec.header_id,  -- 1717444
          x_return_status =>  l_return_status
        );


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    ELSE

      -- process PTO fulfillment activity.
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING PROCESS PTO FULFILLMENT ' , 3 ) ;
      END IF;
      Process_PTO_KIT
      (
        p_line_id       => l_line_rec.line_id,
        p_top_model_line_id   => l_line_rec.top_model_line_id,
        p_fulfillment_activity  => l_fulfillment_activity,
        p_process_all     => FND_API.G_FALSE,
        x_return_status     => l_return_status,
        x_fulfillment_status  => l_fulfillment_status
      );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS/FULFILLMENT STATUS : '||L_RETURN_STATUS||'/'||L_FULFILLMENT_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF  l_fulfillment_status = FND_API.G_FALSE THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ALL THE LINES OF THE FULFILLMENT SET HAS NOT BEEN FULFILLED' , 3 ) ;
        END IF;
        x_result_out := 'NOTIFIED:#NULL';
               ELSIF l_fulfillment_type = G_FULFILL_NO_ACTIVITY THEN


        Fulfill_Line
        (
          p_line_rec      =>  l_line_rec,
          p_mode        =>  'RECORD',
          p_fulfillment_type  =>  l_fulfillment_type,
          p_fulfillment_activity => l_fulfillment_activity,
          x_return_status   =>  l_return_status
        );

        IF l_return_status = 'D' THEN
          RAISE CAN_NOT_LOCK_MODEL;
        ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
--    END IF;

    END IF;


    ELSIF   l_line_rec.item_type_code = 'SERVICE' AND
      l_line_rec.service_reference_line_id IS NOT NULL AND
      l_line_rec.service_reference_type_code = 'ORDER' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SERVICE LINE AT FULFILLMENT : '||L_LINE_REC.SERVICE_REFERENCE_TYPE_CODE , 3 ) ;
      END IF;


                   SELECT fulfilled_flag,
                          header_id       -- 1717444
                   INTO   l_fulfilled_flag,
                          l_ref_header_id -- 1717444
                   FROM   oe_order_lines
                   WHERE  line_id = l_line_rec.service_reference_line_id;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'PRODUCT LINE FULFILLED : '||L_FULFILLED_FLAG , 3 ) ;
            END IF;

            IF  l_fulfilled_flag = 'Y' OR         -- OR condition added for 1717444
                l_ref_header_id <> l_line_rec.header_id THEN


           IF l_fulfillment_type = G_FULFILL_NO_ACTIVITY THEN


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CALLING FULFILL LINE WITH : '|| L_FULFILLMENT_TYPE||'/'||L_FULFILLMENT_ACTIVITY , 3 ) ;
       END IF;

       Fulfill_Line
        (
         p_line_rec     =>  l_line_rec,
         p_mode     =>  'RECORD',
         p_fulfillment_type   =>  l_fulfillment_type,
         p_fulfillment_activity => l_fulfillment_activity,
         x_return_status    =>  l_return_status
        );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
       END IF;

       IF l_return_status = 'D' THEN
         RAISE CAN_NOT_LOCK_MODEL;
       ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

           END IF;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SERVICE LINE IS FULFILLED' , 3 ) ;
           END IF;
       ELSE


           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SERVICE LINE AT FULFILLMENT' , 3 ) ;
           END IF;
           x_result_out := 'NOTIFIED:#NULL';

       END IF;

  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FULFILL_LINE ACTIVITY IS COMPLETE '||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
    END IF;


    IF  l_fulfillment_type = G_FULFILL_NO_ACTIVITY THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING FULFILL LINE WITH : '|| L_FULFILLMENT_TYPE||'/'||L_FULFILLMENT_ACTIVITY , 3 ) ;
      END IF;

      Fulfill_Line
      (
        p_line_rec      =>  l_line_rec,
        p_mode        =>  'RECORD',
        p_fulfillment_type  =>  l_fulfillment_type,
        p_fulfillment_activity => l_fulfillment_activity,
        x_return_status   =>  l_return_status
      );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FULFILL LINE : '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF l_return_status = 'D' THEN
        RAISE CAN_NOT_LOCK_MODEL;
      ELSIF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '||L_LINE_REC.LINE_ID , 3 ) ;
      END IF;

      Fulfill_Service_Lines
      (
        p_line_id   =>  l_line_rec.line_id,
        p_header_id   =>  l_line_rec.header_id,  -- 1717444
        x_return_status =>  l_return_status
      );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '||L_LINE_REC.LINE_ID , 3 ) ;
      END IF;


      Fulfill_Service_Lines
      (
        p_line_id   =>  l_line_rec.line_id,
        p_header_id   =>  l_line_rec.header_id,  -- 1717444
        x_return_status =>  l_return_status
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.PROCESS_FULFILLMENT '||X_RESULT_OUT , 3 ) ;
  END IF;

  IF  x_result_out = 'NOTIFIED:#NULL' THEN

    l_flow_status_code := 'AWAITING_FULFILLMENT';
  ELSE
    l_flow_status_code := 'FULFILLED';
  END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
    END IF;


    OE_Order_WF_Util.Update_Flow_Status_Code
        (p_line_id            =>  l_line_rec.line_id,
         p_flow_status_code   =>  l_flow_status_code,
         x_return_status      =>  l_return_status
         );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING FROM OE_LINE_FULFILL.PROCESS_FULFILLMENT : '||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION

  WHEN CAN_NOT_LOCK_MODEL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXVFULB.pls: Process_fulfillment- MODEL LOCKING EXCEPTION' , 1 ) ;
        END IF;
        x_return_status                := 'DEFERRED';
        G_DEBUG_MSG := G_DEBUG_MSG || 'ELOCK2,';
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PROCESS_FULFILLMENT : EXITING WITH UNEXPECTED ERROR'||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E22-1,';

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Process_Fulfillment'
        );
      END IF;
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E22-2,';

    WHEN  FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS_FULFILLMENT : EXITING WITH OTHERS ERROR' , 1 ) ;
        END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Fulfillment'
            );
        END IF;
        G_DEBUG_MSG := G_DEBUG_MSG || 'E23,';

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Fulfillment;


-- Bug2068310: Parameter p_fulfill_operation is added. Value passed will be
-- 'N' in case of deletion and cancellation of a line, and will be 'Y' when
-- removing the line from fulfillment set.

PROCEDURE Cancel_line
(
  p_line_id     IN  NUMBER
, x_return_status OUT NOCOPY VARCHAR2

,       p_fulfill_operation             IN  VARCHAR2 DEFAULT 'N'
,       p_set_id      IN  NUMBER DEFAULT NULL  --  2525203
)
IS
-- Added For bug#2965878 Begin
j                     Integer;
initial               Integer;
nextpos               Integer;
t_line_id             NUMBER;
set_flag              VARCHAR2(1) := 'N';
-- Added For bug#2965878 End

  l_set_tbl     Line_Set_Tbl_Type;
  l_set_index     NUMBER := 0;
  l_activity_status   VARCHAR2(8);
  l_activity_result   VARCHAR2(30);
  l_activity_id     NUMBER;
  l_return_status     VARCHAR2(1);
  l_line_rec      OE_Order_Pub.Line_Rec_Type;
  l_process_current_line    BOOLEAN := TRUE;
  l_complete_fulfillment          BOOLEAN := TRUE;

        /* 2525203 */
        l_set_f                         BOOLEAN := TRUE; /* fulfill set p_set_id? */
        l_oth_f                         BOOLEAN := TRUE; /* fulfill all other sets except p_set_id? */
        l_shared_lines                  BOOLEAN := FALSE;
        l_set_id                        NUMBER;
        l_howmany                       INTEGER := 0;
        l_common_sets                   INTEGER := 0;
        TYPE line_tbl IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
        l_fulfilled_lines               line_tbl;
        l_set_status                    VARCHAR2(1);
        /* end 2525203 */
  --Start Bug 7827727
  l_line_id_mod      NUMBER;
  l_set_id_mod       NUMBER;
 --end of Bug 7827727

  TYPE set_tbl IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;
  l_close_tbl     set_tbl;
  l_close_tbl_index   NUMBER := 0;
  l_header_id     NUMBER := 0;
  l_top_model_line_id   NUMBER :=0;
  l_model_remnant_flag    VARCHAR2(1);
  l_store_top     NUMBER :=0;
  l_store_rem     VARCHAR2(1);

  TYPE fulfill_set IS RECORD
  (
    line_id     NUMBER := FND_API.G_MISS_NUM
  , top_model_line_id NUMBER := FND_API.G_MISS_NUM
  ,     set_id                NUMBER := FND_API.G_MISS_NUM
  , model_remnant_flag  VARCHAR2(1) := FND_API.G_MISS_CHAR
  );

  TYPE fulfill_set_tbl IS TABLE OF fulfill_set
    INDEX BY BINARY_INTEGER;

  l_ful_set_tbl     fulfill_set_tbl;
  l_ful_set_index     NUMBER := 0;

  l_fulfill_status    VARCHAR2(1);

        -- Added for Bug-2560644
        l_fulfilled_flag                VARCHAR2(1);
  l_fulfillment_activity          VARCHAR2(30);
  l_fulfillment_type          VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_FULLFILL.CANCEL_LINE : '||TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;



  -- Check if being called for child line

    SELECT TOP_MODEL_LINE_ID,
         MODEL_REMNANT_FLAG
    INTO   l_store_top,
         l_store_rem
    FROM   OE_ORDER_LINES
    WHERE  LINE_ID = p_line_id;


  IF l_store_top IS NOT NULL AND
     l_store_top <> p_line_id AND
     nvl(l_store_rem,'N') = 'N' THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLED FOR CHILD ' , 3 ) ;
     END IF;
     GOTO LINE_NOT_IN_SET;

  END IF;

        /* 2525203 start */


        IF p_set_id IS NOT NULL THEN

          select count(*)
          into   l_howmany
          from   oe_line_sets l,
                 oe_sets s
          where l.line_id = p_line_id
          and   l.set_id = s.set_id
          and   s.set_id <> p_set_id
          and   s.set_type = 'FULFILLMENT_SET';
          IF l_howmany > 0 THEN
            l_set_id := p_set_id;
          ELSE
            l_set_id := NULL;  -- p_line_id is in only one fulfillment set, p_set_id
          END IF;

        ELSE
          l_set_id := NULL;
        END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_SET_ID :'||TO_CHAR ( L_SET_ID ) ||'.' , 5 ) ;
  END IF;

        IF l_set_id IS NOT NULL THEN

          /* check if there is a line other than p_line_id which is a member of both
             p_set_id and another fulfillment set */

          select count(*)  -- added for 2525203
          into l_howmany
          from oe_line_sets l1,
               oe_line_sets l2,
               oe_sets s1,
               oe_order_lines ol
          where l1.line_id <> p_line_id
          and   l1.set_id = s1.set_id
          and   s1.set_type = 'FULFILLMENT_SET'
          and   s1.set_id <> l_set_id
          and   l2.line_id = l1.line_id
          and   l1.line_id = ol.line_id
          and   (ol.top_model_line_id is null or
                ol.top_model_line_id = ol.line_id or
                nvl(ol.model_remnant_flag, 'N') = 'Y')
          and   l2.set_id = l_set_id;
          IF l_howmany > 0 THEN
            l_shared_lines := TRUE;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_SHARED_LINES IS TRUE' , 5 ) ;
      END IF;
          END IF;


          /* check if there is another line which is with p_line_id in l_set_id and at least one other
             fulfillment set */
          select count(*)
          into l_common_sets
          from oe_line_sets l1,
               oe_line_sets l2,
               oe_line_sets l3,
               oe_sets s1,
               oe_order_lines ol
          where l1.line_id = p_line_id
          and   l1.set_id = s1.set_id
          and   s1.set_type = 'FULFILLMENT_SET'
          and   s1.set_id <> l_set_id
          and   l2.set_id = s1.set_id
          and   l2.line_id = ol.line_id
          and   (ol.top_model_line_id is null or
                ol.top_model_line_id = ol.line_id or
                nvl(ol.model_remnant_flag, 'N') = 'Y')
          and   l2.line_id <> l1.line_id
          and   l2.line_id = l3.line_id
          and   l3.set_id = l_set_id;

        END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_COMMON_SETS :'||TO_CHAR ( L_COMMON_SETS ) ||'.' , 5 ) ;
  END IF;

        /* 2525203 end */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET THE FULFILLMENT SET CALLING GET FULFILLMENT SET : ' , 3 ) ;
  END IF;

  g_set_tbl.delete;

  Get_Fulfillment_Set
  (
    p_line_id     => p_line_id
  , x_return_status   => l_return_status
  , x_set_tbl     => l_set_tbl
  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURN STATUS FROM GET FULFILLMENT SET : '||L_RETURN_STATUS||'/'||TO_CHAR ( L_SET_TBL.COUNT ) , 3 ) ;
  END IF;

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF  l_set_tbl.count > 0 THEN
    NULL;
  ELSE
    GOTO LINE_NOT_IN_SET;
  END IF;



  --Prepare a table for MODEL/Standard to be processed.

  FOR l_set_index IN l_set_tbl.FIRST .. l_set_tbl.LAST
  LOOP

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LOOPING FOR LINE_ID :'||L_SET_TBL ( L_SET_INDEX ) .LINE_ID , 3 ) ;
    END IF;


    SELECT TOP_MODEL_LINE_ID,
         MODEL_REMNANT_FLAG
    INTO   l_top_model_line_id,
         l_model_remnant_flag
    FROM   OE_ORDER_LINES
    WHERE  LINE_ID = l_set_tbl(l_set_index).line_id;

    IF l_top_model_line_id IS NULL OR
       l_top_model_line_id = l_set_tbl(l_set_index).line_id OR
       nvl(l_model_remnant_flag,'N') = 'Y' THEN
                      -- Added For bug#2965878 Begin
                      /* Not needed with MOAC
                      j := 1.0;
                      initial := 1.0;
                      nextpos := INSTR(OE_OE_FORM_CANCEL_LINE.g_record_ids,',',1,j) ;
                      */
                      set_flag := 'N';


                         FOR i IN 1..OE_OE_FORM_CANCEL_LINE.g_num_of_records LOOP
                             IF l_debug_level  > 0 THEN
                                 OE_DEBUG_PUB.Add('Number Of records'||to_char(OE_OE_FORM_CANCEL_LINE.g_num_of_records),1);
                             END IF;
                             --MOAC
                             --t_line_id := to_number(substr(OE_OE_FORM_CANCEL_LINE.g_record_ids,initial, nextpos-initial));
                             t_line_id := OE_OE_FORM_CANCEL_LINE.g_record_ids(i).id1;

                             IF l_debug_level  > 0 THEN
                                 OE_DEBUG_PUB.Add('Line Id: '||to_char(t_line_id),1);
                             END IF;
                             /* Not needed with MOAC
                             initial := nextpos + 1.0;
                             j := j + 1.0;
                             nextpos := INSTR(OE_OE_FORM_CANCEL_LINE.g_record_ids,',',1,j) ;
                             */

                              IF t_line_id = l_set_tbl(l_set_index).line_id THEN
                                 set_flag := 'Y';
                                 exit;
                              END IF;
                         END LOOP;
                                 IF set_flag = 'Y' THEN
                                    IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'LINE IS GETTING CANCELLED,NOT ADDED TO TABLE : '||L_SET_TBL ( L_SET_INDEX ) .LINE_ID , 3 ) ;
                                    END IF;
                                    NULL;
                                 ELSE    -- Added For bug#2965878 End
                                    IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'ADD THE LINE TO TABLE/REM : '||L_SET_TBL ( L_SET_INDEX ) .LINE_ID||'/'||L_MODEL_REMNANT_FLAG , 3 ) ;
                        END IF;
                           l_ful_set_index := l_ful_set_index + 1;
                           l_ful_set_tbl(l_ful_set_index).line_id := l_set_tbl(l_set_index).line_id;
                           l_ful_set_tbl(l_ful_set_index).set_id := l_set_tbl(l_set_index).set_id;
                           l_ful_set_tbl(l_ful_set_index).top_model_line_id := l_top_model_line_id;
                               l_ful_set_tbl(l_ful_set_index).model_remnant_flag := l_model_remnant_flag;
                                    IF l_debug_level  > 0 THEN
                                        oe_debug_pub.add(  'INDEX : '||L_FUL_SET_INDEX , 3 ) ;
                                    END IF;
                                 END IF;
    ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE NOT ADDED TO TABLE : '||L_SET_TBL ( L_SET_INDEX ) .LINE_ID , 3 ) ;
       END IF;

    END IF;

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT '||L_FUL_SET_TBL.COUNT , 3 ) ;
  END IF;

   IF L_FUL_SET_TBL.COUNT >0 THEN    -- Added For bug#2965878
  FOR l_ful_set_index IN l_ful_set_tbl.FIRST .. l_ful_set_tbl.LAST
  LOOP

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE : '||TO_CHAR ( L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .LINE_ID ) , 3 ) ;
    END IF;

    -- Check for the passed line. If the line is at FULFILL_LINE work
    -- flow activity, then the fulfillment processing for this line
    -- should take place.


    l_set_id_mod:=MOD(l_ful_set_tbl(l_ful_set_index).set_id,G_BINARY_LIMIT);--7827727
    --IF NOT l_close_tbl.EXISTS(l_ful_set_tbl(l_ful_set_index).set_id) THEN
    IF NOT l_close_tbl.EXISTS(l_set_id_mod) THEN --7827727

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SET ID ADDED : '||TO_CHAR ( L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .SET_ID ) , 3 ) ;
      END IF;
      --l_close_tbl(l_ful_set_tbl(l_ful_set_index).set_id) := l_ful_set_tbl(l_ful_set_index).set_id;
      l_close_tbl(l_set_id_mod) :=l_ful_set_tbl(l_ful_set_index).set_id;--7827727

    END IF;

    IF l_ful_set_tbl(l_ful_set_index).top_model_line_id is NOT NULL AND
       nvl(l_ful_set_tbl(l_ful_set_index).model_remnant_flag,'N') = 'N' THEN

      Check_PTO_KIT_Fulfillment
      (
      p_top_model_line_id   => l_ful_set_tbl(l_ful_set_index).top_model_line_id,
      x_return_status     => l_return_status,
      x_fulfill_status    => l_fulfill_status
      );

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'RETURN FROM CHECK_PTO_KIT_FULFILLMENT '||L_RETURN_STATUS||'/'||L_FULFILL_STATUS , 3 ) ;
                        END IF;
      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      IF l_fulfill_status = FND_API.G_FALSE THEN
        IF l_ful_set_tbl(l_ful_set_index).line_id = p_line_id THEN
          l_process_current_line := FALSE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '1- DO NOT PROCESS CURRENT LINE '||L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .LINE_ID , 3 ) ;
          END IF;

                                        IF l_set_id IS NOT NULL THEN  -- 2525203
            l_complete_fulfillment := FALSE;
                                          l_oth_f := FALSE;
            IF l_common_sets > 0 THEN
                    l_set_f := FALSE;
                                          END IF;
                                        END IF; -- 2525203 end

          GOTO END_SET_LOOP;
        ELSE
          l_complete_fulfillment := FALSE;

                                        IF l_ful_set_tbl(l_ful_set_index).set_id = l_set_id THEN  -- 2525203
                                          l_set_f := FALSE;
                                        ELSIF l_set_id IS NOT NULL THEN
                                          l_oth_f := FALSE;
                                        END IF;  -- 2525203 end

                                        IF l_set_id IS NULL OR  -- GOTO made conditional for 2525203
                                           (NOT l_set_f AND NOT l_oth_f) THEN
            GOTO END_CANCEL_PROCESS;
                                        END IF;
        END IF;
      END IF;

    ELSE

      Get_Activity_Result
      (
        p_item_type     => OE_GLOBALS.G_WFI_LIN
      , p_item_key      => to_char(l_ful_set_tbl(l_ful_set_index).line_id)
      , p_activity_name     => 'FULFILL_LINE'
      , x_return_status     => l_return_status
      , x_activity_result   => l_activity_result
      , x_activity_status_code    => l_activity_status
      , x_activity_id     => l_activity_id
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  ( l_return_status = FND_API.G_RET_STS_ERROR
             OR
             NVL(l_activity_status, 'COMPLETE') <> 'NOTIFIED' )
         THEN
        IF l_ful_set_tbl(l_ful_set_index).line_id = p_line_id THEN
          l_process_current_line := FALSE;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '2- DO NOT PROCESS CURRENT LINE ' , 3 ) ;
          END IF;

                                        IF l_set_id IS NOT NULL THEN  -- 2525203
            l_complete_fulfillment := FALSE;
                                          l_oth_f := FALSE;
            IF l_common_sets > 0 THEN
                    l_set_f := FALSE;
                                          END IF;
                                        END IF; -- 2525203 end

          GOTO END_SET_LOOP;
        ELSE
          l_complete_fulfillment := FALSE;

                                        IF l_ful_set_tbl(l_ful_set_index).set_id = l_set_id THEN  -- 2525203
                                          l_set_f := FALSE;
                                        ELSIF l_set_id IS NOT NULL THEN
                                          l_oth_f := FALSE;
                                        END IF;  -- 2525203 end

                                        IF l_set_id IS NULL OR  -- GOTO made conditional for 2525203
                                           (NOT l_set_f AND NOT l_oth_f) THEN
            GOTO END_CANCEL_PROCESS;
                                        END IF;
        END IF;
      END IF;

    END IF;

  << END_SET_LOOP >>
  NULL;
        /* Debugging statements added for 2525203 */
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FLAGS:' , 5 ) ;
        END IF;
        IF l_complete_fulfillment THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_COMPLETE_FULFILLMENT IS TRUE' , 5 ) ;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_COMPLETE_FULFILLMENT IS FALSE' , 5 ) ;
          END IF;
        END IF;
        IF l_set_f THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_SET_F IS TRUE' , 5 ) ;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_SET_F IS FALSE' , 5 ) ;
          END IF;
        END IF;
        IF l_oth_f THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_OTH_F IS TRUE' , 5 ) ;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_OTH_F IS FALSE' , 5 ) ;
          END IF;
        END IF;
        IF l_process_current_line THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_PROCESS_CURRENT_LINE IS TRUE' , 5 ) ;
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_PROCESS_CURRENT_LINE IS FALSE' , 5 ) ;
          END IF;
        END IF;
        /* end 2525203 */

  END LOOP;
   END IF;  -- Count of l_ful_set_tbl is 0

  << END_CANCEL_PROCESS >>

        IF l_shared_lines AND -- added for 2525203
           (NOT l_set_f OR NOT l_oth_f) THEN
          l_set_f := FALSE;
          l_oth_f := FALSE;
        END IF;

  IF l_complete_fulfillment OR  -- OR added for 2525203
           (l_set_id IS NOT NULL AND (l_set_f OR l_oth_f)) THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FULFILL SOME LINES <> P_LINE_ID: ' , 3 ) ;
    END IF;

                l_fulfilled_lines.DELETE; -- 2525203
   IF L_FUL_SET_TBL.COUNT >0 THEN -- Added For bug#2965878
    FOR l_ful_set_index IN l_ful_set_tbl.FIRST .. l_ful_set_tbl.LAST
    LOOP
          IF  l_ful_set_tbl(l_ful_set_index).line_id <> p_line_id  AND -- AND  added for 2525203
                        (l_complete_fulfillment OR
                         l_set_f AND l_ful_set_tbl(l_ful_set_index).set_id = l_set_id OR
                         l_oth_f AND l_ful_set_tbl(l_ful_set_index).set_id <> l_set_id) AND
                         NOT l_fulfilled_lines.EXISTS(MOD(l_ful_set_tbl(l_ful_set_index).line_id,G_BINARY_LIMIT)) THEN --7827727
                        --NOT l_fulfilled_lines.EXISTS(l_ful_set_tbl(l_ful_set_index).line_id) THEN

                        --l_fulfilled_lines(l_ful_set_tbl(l_ful_set_index).line_id) := 'Y'; -- 2525203
                        l_fulfilled_lines(MOD(l_ful_set_tbl(l_ful_set_index).line_id,G_BINARY_LIMIT)) :='Y';--2525203 --7827727

      IF  l_ful_set_tbl(l_ful_set_index).line_id = l_ful_set_tbl(l_ful_set_index).top_model_line_id AND
                    nvl(l_ful_set_tbl(l_ful_set_index).model_remnant_flag,'N') = 'N' THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING FULFILL_PTO_KIT '||L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .TOP_MODEL_LINE_ID , 3 ) ;
        END IF;

        Fulfill_PTO_KIT
        (
        p_top_model_line_id   => l_ful_set_tbl(l_ful_set_index).top_model_line_id,
        x_return_status     => l_return_status
        );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FULFILL_PTO_KIT API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSE
                        /* Fix for 2560644 */

                       SELECT fulfilled_flag
                       INTO   l_fulfilled_flag
                       FROM   OE_ORDER_LINES
                       WHERE  LINE_ID = l_ful_set_tbl(l_ful_set_index).line_id;

                        /* If the line is not fulfilled set the fulfillment related
                           attributes for the line before it goes beyond FULFILL_LINE */

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'FULFILLED FLAG '||L_FULFILLED_FLAG , 5 ) ;
                       END IF;

                       IF nvl(l_fulfilled_flag,'N') <> 'Y' THEN

                          l_fulfillment_type := G_FULFILL_NO_ACTIVITY;
                          l_fulfillment_activity := 'NO_ACTIVITY';

                          OE_Line_Util.Query_Row(p_line_id  => l_ful_set_tbl(l_ful_set_index).line_id,
                   x_line_rec => l_line_rec);
                          Fulfill_Line
                          (
                          p_line_rec  => l_line_rec,
                          p_mode      => 'RECORD',
                          p_fulfillment_type => l_fulfillment_type,
                          p_fulfillment_activity => l_fulfillment_activity,
                          x_return_status => l_return_status
                          );

                          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                          END IF;

                       --END IF; /* Commented for bug 2965878 */

                       --bug3292817: shippable line in a fulfillment set
                       --must get closed
                       END IF; /*bug3292817*/

                       --bug3292817 start
                       l_activity_status := 'NOTIFIED';
                       IF OE_OE_FORM_CANCEL_LINE.g_num_of_records > 1 THEN
                          Get_Activity_Result
                          (   p_item_type => OE_GLOBALS.G_WFI_LIN
                             ,p_item_key =>
to_char(l_ful_set_tbl(l_ful_set_index).line_id)
                             ,p_activity_name => 'FULFILL_LINE'
                             ,x_return_status => l_return_status
                             ,x_activity_result => l_activity_result
                             ,x_activity_status_code => l_activity_status
                             ,x_activity_id => l_activity_id
                          );
                        END IF;
                        --bug3292817 end

                        IF NVL(l_activity_status,'NOTIFIED') <> 'COMPLETE' THEN
/* bug3292817 */
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
        END IF;

        OE_Order_WF_Util.Update_Flow_Status_Code
            (p_line_id            =>  l_ful_set_tbl(l_ful_set_index).line_Id,
            p_flow_status_code    =>  'FULFILLED',
            x_return_status       =>  l_return_status
            );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES ' , 3 ) ;
        END IF;

        Fulfill_Service_Lines
        (
          p_line_id       =>  l_ful_set_tbl(l_ful_set_index).line_id,
          x_return_status =>  l_return_status
        );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;
              wf_engine.CompleteActivityInternalName('OEOL', to_char(l_ful_set_tbl(l_ful_set_index).line_id), 'FULFILL_LINE', '#NULL');
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( L_FUL_SET_TBL ( L_FUL_SET_INDEX ) .LINE_ID ) , 3 ) ;
        END IF;

                       END IF; --Line fulfilled
      END IF;
        END IF; /*Top Model */
    END LOOP;

   END IF; --Count of l_ful_set_tbl is 0
    -- Update the set status in oe_sets to closed.
    l_close_tbl_index := l_close_tbl.FIRST;

    WHILE l_close_tbl_index IS NOT NULL
    LOOP
                  IF l_complete_fulfillment OR  -- This IF added for 2525203
                     l_set_f AND l_close_tbl(l_close_tbl_index) = l_set_id OR
                     l_oth_f AND l_close_tbl(l_close_tbl_index) <> l_set_id THEN
        -- 3772947
        UPDATE  OE_SETS
        SET SET_STATUS  = 'C',
            UPDATE_DATE = SYSDATE
        WHERE SET_ID = l_close_tbl(l_close_tbl_index);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SET IS CLOSED : '||TO_CHAR ( L_CLOSE_TBL ( L_CLOSE_TBL_INDEX ) ) , 3 ) ;
        END IF;
                  END IF; -- end 2525203
        l_close_tbl_index := l_close_tbl.NEXT(l_close_tbl_index);

	OE_Set_util.g_set_rec.set_status := 'C'; -- 4080531

    END LOOP;

  END IF;

        /* following IF for Bug2068310. */
        IF p_fulfill_operation = 'N' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'CURRENT LINE IS GETTING DELETED OR CANCELLED , DONOT PROCESS ' , 3 ) ;
       END IF;
       l_process_current_line := FALSE;
        END IF;

  IF l_process_current_line AND -- AND added for 2525203
           (l_set_id IS NULL OR l_oth_f)  THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING CURRENT LINE' , 3 ) ;
    END IF;

    IF l_store_top IS NOT NULL AND
       l_store_top = p_line_id AND
       nvl(l_store_rem,'N') = 'N' THEN

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'CALLING CHECK_PTO_KIT_FULFILLMENT ' , 3 ) ;
                        END IF;

      Check_PTO_KIT_Fulfillment
      (
      p_top_model_line_id   => p_line_id,

      x_return_status     => l_return_status,
      x_fulfill_status    => l_fulfill_status
      );

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'RETURN FROM CHECK_PTO_KIT_FULFILLMENT '||L_RETURN_STATUS||'/'||L_FULFILL_STATUS , 3 ) ;
                        END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      IF  l_fulfill_status = FND_API.G_FALSE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE CAN NOT BE FULFILLED ' , 3 ) ;
        END IF;
        GOTO LINE_NOT_IN_SET;

      ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING FULFILL_PTO_KIT '||P_LINE_ID , 3 ) ;
        END IF;

        Fulfill_PTO_KIT
        (
        p_top_model_line_id   => p_line_id,
        x_return_status     => l_return_status
        );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS FROM FULFILL_PTO_KIT API '||L_RETURN_STATUS , 3 ) ;
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    ELSE

      Get_Activity_Result
      (
        p_item_type       => OE_GLOBALS.G_WFI_LIN
      , p_item_key        => to_char(p_line_id)
      , p_activity_name     => 'FULFILL_LINE'
      , x_return_status     => l_return_status
      , x_activity_result   => l_activity_result
      , x_activity_status_code  => l_activity_status
      , x_activity_id     => l_activity_id
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DO NOT PROCESS CURRENT LINE ' , 3 ) ;
        END IF;
        GOTO LINE_NOT_IN_SET;
      END IF;

                       /* Fix for 2560644 */

                       SELECT fulfilled_flag
                       INTO   l_fulfilled_flag
                       FROM   OE_ORDER_LINES
                       WHERE  LINE_ID = p_line_id;

                       /* If the line is not fulfilled set the fulfillment related
                          attributes for the line before it goes beyond FULFILL_LINE */

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'FULFILLED FLAG '||L_FULFILLED_FLAG , 5 ) ;
                       END IF;
                       IF nvl(l_fulfilled_flag,'N') <> 'Y' THEN

                          l_fulfillment_type := G_FULFILL_NO_ACTIVITY;
                          l_fulfillment_activity := 'NO_ACTIVITY';

                          OE_Line_Util.Query_Row(p_line_id  =>  p_line_id,
                                                  x_line_rec  =>  l_line_rec);

                          Fulfill_Line
                                     (
                                      p_line_rec  => l_line_rec,
                                      p_mode      => 'RECORD',
                                      p_fulfillment_type => l_fulfillment_type,
                                      p_fulfillment_activity => l_fulfillment_activity,
                                      x_return_status => l_return_status
                                      );

                          IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;

                     END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
      END IF;

--      l_line_rec  :=  OE_Line_Util.Query_Row(p_line_id);
/*
      SELECT  HEADER_ID
      INTO  l_header_id
      FROM  OE_ORDER_LINES
      WHERE LINE_ID = p_line_id;
*/
      OE_Order_WF_Util.Update_Flow_Status_Code
        (p_line_id            =>  p_line_Id,
        p_flow_status_code    =>  'FULFILLED',
        x_return_status       =>  l_return_status
        );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES ' , 3 ) ;
      END IF;


      Fulfill_Service_Lines
      (
        p_line_id   =>  p_line_id,
        x_return_status =>  l_return_status
      );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STATUS FROM FULFILL SERVICE LINES API '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( P_LINE_ID ) , 3 ) ;
      END IF;
              wf_engine.CompleteActivityInternalName('OEOL', to_char(p_line_id), 'FULFILL_LINE', '#NULL');
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( P_LINE_ID ) , 3 ) ;
      END IF;

    END IF;

  END IF;


  << LINE_NOT_IN_SET >>

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_LINE_FULLFILL.CANCEL_LINE : '||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CANCEL_LINE : EXITING WITH UNEXPECTED ERROR'||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
         'Cancel_Line'
      );
    END IF;
                G_DEBUG_MSG := G_DEBUG_MSG || 'E24,';

        WHEN  FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CANCEL_LINE : EXITING WITH OTHERS ERROR' , 1 ) ;
                END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Cancel_Line'
                        );
                END IF;
                G_DEBUG_MSG := G_DEBUG_MSG || 'E25,';

END Cancel_Line;

END OE_LINE_FULLFILL;


/
