--------------------------------------------------------
--  DDL for Package Body OE_SHIP_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIP_CONFIRMATION_PUB" AS
/* $Header: OEXPSHCB.pls 120.21.12010000.20 2010/11/26 10:30:50 sahvivek ship $ */


--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Ship_Confirmation_Pub';
G_SKIP_SHIP     VARCHAR2(30) := OE_GLOBALS.G_COMPLETE_ACTIVITY; -- Bug 10032407

Type ship_confirm_models is table of NUMBER
index by binary_integer;

Type ship_confirm_sets is table of NUMBER
index by binary_integer;

g_non_shippable_rec   Ship_Line_Rec_Type;

-- bug 4170119
PROCEDURE Handle_Bulk_Mode_Per_Order
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_line_adj_rec       IN            Ship_Adj_Rec_Type
 ,p_start_index        IN            NUMBER
 ,p_end_index          IN            NUMBER
 ,x_return_status      OUT NOCOPY    VARCHAR2);

PROCEDURE Ship_Confirm_Split_Lines
( p_ship_line_rec    IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_index            IN NUMBER);

PROCEDURE Process_Requests;

--  Start of Comments
--  API name    Ship_Confirm
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

PROCEDURE Ship_Confirm
(
    p_api_version_number         IN   NUMBER
,   p_line_tbl                   IN   OE_Order_PUB.Line_Tbl_Type
,   p_line_adj_tbl               IN   OE_ORDER_PUB.Line_adj_Tbl_Type
,   p_req_qty_tbl                IN   Req_Quantity_Tbl_Type
,   x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER
,   x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
    l_api_version_number	CONSTANT	NUMBER := 1.0;
    l_line_rec  		OE_Order_PUB.Line_Rec_Type;
    l_line_adj_rec 		OE_ORDER_PUB.Line_adj_rec_type;

    l_old_line_tbl		OE_ORDER_PUB.Line_Tbl_Type;
    l_line_tbl			OE_ORDER_PUB.Line_Tbl_Type;
    l_temp_line_tbl		OE_ORDER_PUB.Line_Tbl_Type;
    l_notify			BOOLEAN := FALSE;

    l_result_out		VARCHAR2(30);

    l_actual_shipment_date      DATE;
    l_shipped_quantity  	NUMBER;

    l_shipping_quantity  	NUMBER;
    l_shipping_quantity_uom     VARCHAR2(3);
    l_ordered_quantity  	NUMBER;
    l_order_quantity_uom  	VARCHAR2(3);

    l_inventory_item_id  	NUMBER;
    l_ship_from_org_id  	NUMBER;
    l_item_type_code  		VARCHAR2(30);
    l_ship_set_id       	NUMBER;
    l_ship_set_id_mod           NUMBER; -- Bug 8795918
    l_top_model_line_id 	NUMBER;
    l_ato_line_id 		NUMBER;
    l_model_remnant_flag  	VARCHAR2(1);
    l_make_remnant              VARCHAR2(1) := 'N'; --bug 4701487
    l_header_id			NUMBER;
    l_ship_tolerance_below      NUMBER;
    l_over_ship_reason_code     VARCHAR2(30);

    l_ship_tolerance_below_upd   NUMBER;
    l_over_ship_reason_code_upd VARCHAR2(30);

 /*   l_OPM_shipped_quantity      NUMBER(19,9); -- INVCONV
    l_OPM_shipping_quantity_uom VARCHAR2(4);
    l_OPM_order_quantity_uom    VARCHAR2(4); */
    l_item_rec         	 	OE_ORDER_CACHE.item_rec_type;
    l_status      		VARCHAR2(1);

    l_count         		NUMBER;
    l_msg_data   		VARCHAR2(500);

    l_temp_shipped_quantity     NUMBER;
    l_validated_quantity        NUMBER;
    l_primary_quantity          NUMBER;
    l_qty_return_status         VARCHAR2(1);
    l_return_status      	VARCHAR2(1);
    l_smc_flag                  VARCHAR2(1);
    l_price_adjustment_id 	NUMBER;

    TYPE Ship_Confirm_Rec	IS RECORD
    (
        type_id			NUMBER
,	ship_confirm_type	VARCHAR2(30)
);

     TYPE Ship_Confirm_Table IS TABLE OF Ship_Confirm_rec
     INDEX BY BINARY_INTEGER;

     l_ship_confirm_tbl		ship_confirm_table;
     l_ship_confirm_index	NUMBER;

     l_temp_requested_quantity  NUMBER;
     l_temp_requested_quantity2  NUMBER; -- INVCONV

-- HW addeded variables for DUAL (OPM)
--     l_OPM_requested_quantity   NUMBER;      INVCONV
     l_ordered_quantity2  	NUMBER;
     l_split_line_tbl		OE_ORDER_PUB.Line_Tbl_Type;
     l_line_set_id          NUMBER;
     l_control_rec          OE_GLOBALS.Control_Rec_Type;
     l_set_recursion        VARCHAR2(1) := 'N';

     l_calculate_price_flag VARCHAR2(1);
-- Variables for update global picture jolin
     l_notify_index	NUMBER;
     l_loop_index	NUMBER;


/* -- HW OPM BUG#: 2415731 local variables to be used for lot specific conversion
     l_lot_number       VARCHAR2(3);
     l_sublot_number    VARCHAR2(32);
     l_lot_id           NUMBER; */
     l_lot_number       VARCHAR2(80);

     CURSOR LOT_INFO (p_line_id NUMBER ) IS
     SELECT WDD.LOT_NUMBER,
       --     WDD.SUBLOT_NUMBER,	 INVCONV
            WDD.SHIPPED_QUANTITY

     FROM   WSH_DELIVERY_DETAILS WDD

     WHERE  WDD.SOURCE_LINE_ID = p_line_Id
     AND    WDD.RELEASED_STATUS ='C'
     AND    WDD.SOURCE_CODE='OE'
     AND    NVL ( WDD.OE_INTERFACED_FLAG , 'N' )  <> 'Y';

     LOT    LOT_INFO%ROWTYPE;

   l_temp_dual_shipped_qty NUMBER;  -- INVCONV

-- HW OPM end of changes for 2415731
     --bug3480047 start
     l_shippable_lines NUMBER;
     --bug3480047 contd

     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     l_line_id_mod          NUMBER; -- Bug 8795918
     l_top_model_line_id_mod NUMBER; -- Bug 8795918

BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_SHIP_CONFIRM.SHIP_CONFIRM' , 1 ) ;
    END IF;

    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    IF OE_GLOBALS.G_EC_INSTALLED IS NULL THEN
        OE_GLOBALS.G_EC_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(175);
    END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NUMBER OF RECORDS LINE/ADJ/REQ :
            '||P_LINE_TBL.COUNT||'/'||P_LINE_ADJ_TBL.COUNT||'/'||P_REQ_QTY_TBL.COUNT , 3 ) ;
	END IF;

    IF  p_req_qty_tbl.count > 0 THEN

        FOR J IN 1..p_req_qty_tbl.count

        LOOP
-- HW Retrieve ship_from_org_id,inventory_item_id and ordered_quantity2
-- to determine if the line is dual
            SELECT  ordered_quantity,
                    order_quantity_uom,
                    inventory_item_id,
                    top_model_line_id,
                    ato_line_id,
                    item_type_code,
                    line_set_id,
                    ship_from_org_id,
                    ordered_quantity2
            INTO    l_ordered_quantity,
                    l_order_quantity_uom,
                    l_inventory_item_id,
                    l_top_model_line_id,
                    l_ato_line_id,
                    l_item_type_code,
                    l_line_set_id,
                    l_ship_from_org_id,
                    l_ordered_quantity2
            FROM    OE_ORDER_LINES
            WHERE   line_id = p_req_qty_tbl(J).line_id;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'REQUESTED/ORDER QUANTITY : '||P_REQ_QTY_TBL ( J ) .REQUESTED_QUANTITY||'/'||L_ORDERED_QUANTITY , 3
                ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORD UOM/SHIPPING UOM : '||L_ORDER_QUANTITY_UOM||'/'||P_REQ_QTY_TBL ( J ) .SHIPPING_QUANTITY_UOM , 3
                ) ;
            END IF;
            IF l_debug_level  > 0 THEN -- INVCONV
                oe_debug_pub.add(  'SHIPPING UOM2 : '||P_REQ_QTY_TBL ( J ) .SHIPPING_QUANTITY_UOM2 , 3 ) ;
            END IF;

-- HW print OPM qty2 INVCONV DELETE
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'REQUESTED/ORDER QUANTITY2 : '||P_REQ_QTY_TBL ( J ) .REQUESTED_QUANTITY2||'/'||L_ORDERED_QUANTITY2 ,
                3 ) ;
            END IF;

            IF  nvl(l_top_model_line_id,-1) <> nvl(l_ato_line_id,-1) AND
                l_top_model_line_id IS NOT NULL THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'PTO MODEL LINE WITH REQUESTED QUANTITY NO SPLIT' , 3 ) ;
                END IF;
                GOTO END_REQ_QTY;

            END IF;

            IF  l_order_quantity_uom <> p_req_qty_tbl(J).shipping_quantity_uom THEN
/* -- HW Need to branch   -- INVCONV   NOT NEEDED NOW

              IF oe_line_util.Process_Characteristics
                   (l_inventory_item_id
                   ,l_ship_from_org_id
                   ,l_item_rec) THEN
		-- Get the OPM equivalent code for order_quantity_uom
		=====================================================
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'OPM PROCESS SHIPPING UPDATE ' , 1 ) ;
                      END IF;
                      l_temp_shipped_quantity := GMI_Reservation_Util.get_opm_converted_qty(
                          p_apps_item_id    => l_inventory_item_id,
                          p_organization_id => l_ship_from_org_id,
                          p_apps_from_uom   => p_req_qty_tbl(J).shipping_quantity_uom,
                          p_apps_to_uom     => l_order_quantity_uom,
                          p_original_qty    => p_req_qty_tbl(J).requested_quantity);
                  -- LG 4-17-03, bug 2900072
		  l_temp_requested_quantity := l_temp_shipped_quantity ;
-- HW This line is discrete
	      ELSE   */


		  l_temp_requested_quantity := OE_Order_Misc_Util.Convert_Uom
                       (
                       l_inventory_item_id,
                       p_req_qty_tbl(J).shipping_quantity_uom,
                       l_order_quantity_uom,
                       p_req_qty_tbl(J).requested_quantity
                       );
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CONVERTED REQUESTED QUANTITY : '|| TO_CHAR ( L_TEMP_REQUESTED_QUANTITY ) , 1 ) ;
                END IF;

 --             END IF; -- HW end of branching INVCONV

            ELSE

                l_temp_requested_quantity := p_req_qty_tbl(J).requested_quantity;
                l_temp_requested_quantity2 := p_req_qty_tbl(J).requested_quantity2; -- INVCONV
            END IF;

            IF l_temp_requested_quantity <> trunc(l_temp_requested_quantity) THEN

               Inv_Decimals_PUB.Validate_Quantity
               (
               p_item_id	         => l_inventory_item_id,
               p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
               p_input_quantity   => l_temp_requested_quantity,
               p_uom_code         => l_order_quantity_uom,
               x_output_quantity  => l_validated_quantity,
               x_primary_quantity => l_primary_quantity,
               x_return_status    => l_qty_return_status
               );

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURN STATUS FROM INV API : '||L_QTY_RETURN_STATUS , 1 ) ;
               END IF;
               IF l_qty_return_status = 'W' THEN

                  l_temp_requested_quantity := l_validated_quantity;

               END IF;

            END IF;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'FINAL REQUESTED QUANTITY : '|| TO_CHAR ( L_TEMP_REQUESTED_QUANTITY ) , 1 ) ;
                   oe_debug_pub.add(  'FINAL REQUESTED QUANTITY2 : '|| TO_CHAR ( L_TEMP_REQUESTED_QUANTITY2 ) , 1 ) ;
               END IF;

            IF  l_ordered_quantity <= l_temp_requested_quantity THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ERROR !!! CAN NOT SPLIT THE LINE ORDERED QUANTTITY <= REQUESTED QTY ' , 3 ) ;
                END IF;
                GOTO END_REQ_QTY;

            END IF;

            -- Assign the first record of the table for process order for update
            -- of the ordered quantity.

            l_split_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;

            IF l_ato_line_id IS NOT NULL and l_item_type_code <> 'STANDARD' THEN
               l_split_line_tbl(1).line_id := l_top_model_line_id;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SPLIT THE TOP MODEL : '||L_SPLIT_LINE_TBL ( 1 ) .LINE_ID , 3 ) ;
               END IF;
            ELSE
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'SPLIT THE LINE : '||L_SPLIT_LINE_TBL ( 1 ) .LINE_ID , 3 ) ;
                 END IF;
                 l_split_line_tbl(1).line_id := p_req_qty_tbl(J).line_id;
            END IF;

            l_split_line_tbl(1).line_set_id := l_line_set_id;
            l_split_line_tbl(1).ordered_quantity := l_temp_requested_quantity;
-- HW added qty2 for OPM
            -- l_split_line_tbl(1).ordered_quantity2 := nvl(p_req_qty_tbl(J).requested_quantity2,0); -- INVCONV
            l_split_line_tbl(1).ordered_quantity2 := nvl(l_temp_requested_quantity2, 0); -- INVCONV
            l_split_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
            l_split_line_tbl(1).split_action_code := 'SPLIT';
            l_split_line_tbl(1).split_by := 'SYSTEM';
            l_split_line_tbl(1).change_reason := 'SYSTEM';
            l_split_line_tbl(1).ship_from_org_id := l_ship_from_org_id; --9733938

            -- Assign the second record of the table for process order for
            -- create of new line.

            l_split_line_tbl(2) := OE_ORDER_PUB.G_MISS_LINE_REC;

            IF l_ato_line_id IS NOT NULL and l_item_type_code <> 'STANDARD' THEN
               l_split_line_tbl(2).split_from_line_id := l_top_model_line_id;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SPLIT FROM THE TOP MODEL : '||L_SPLIT_LINE_TBL ( 1 ) .LINE_ID , 3 ) ;
               END IF;
            ELSE
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'SPLIT FROM THE LINE : '||L_SPLIT_LINE_TBL ( 1 ) .LINE_ID , 3 ) ;
                 END IF;
                 l_split_line_tbl(2).split_from_line_id := p_req_qty_tbl(J).line_id;
            END IF;
            l_split_line_tbl(2).line_set_id := l_line_set_id;
            l_split_line_tbl(2).ordered_quantity := l_ordered_quantity - l_temp_requested_quantity;
-- HW Added qty2 for OPM
            l_split_line_tbl(2).ordered_quantity2 := nvl(l_ordered_quantity2,0)
                                                     -- nvl(p_req_qty_tbl(J).requested_quantity2,0);  INVCONV
                                                     - nvl(l_temp_requested_quantity2, 0);

            l_split_line_tbl(2).operation := OE_GLOBALS.G_OPR_CREATE;
            l_split_line_tbl(2).split_by := 'SYSTEM';
            l_split_line_tbl(2).change_reason := 'SYSTEM';

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SPLIT FROM LINE ID : '||TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .SPLIT_FROM_LINE_ID ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORIGINAL ORDERED QUANTITY : '||TO_CHAR ( L_LINE_REC.ORDERED_QUANTITY ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDERED QUANTITY OLD LINE : '||TO_CHAR ( L_SPLIT_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDERED QUANTITY NEW LINE : '||TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .ORDERED_QUANTITY ) , 3 ) ;
            END IF;

-- HW print qty2 for OPM   -- INVCONV DELETE this comment
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORIGINAL ORDERED QUANTITY2 : '||TO_CHAR ( L_LINE_REC.ORDERED_QUANTITY2 ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDERED QUANTITY2 OLD LINE : '||TO_CHAR ( L_SPLIT_LINE_TBL ( 1 ) .ORDERED_QUANTITY2 ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ORDERED QUANTITY2 NEW LINE : '||TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .ORDERED_QUANTITY2 ) , 3 ) ;
            END IF;

            -- 4. Call to process order will result in call to
            --	  update_shipping_attributes for update of ordered quantity
            --	  and creation of new line.

            l_control_rec.validate_entity		:= FALSE;
            l_control_rec.check_security		:= FALSE;

            IF  OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN

                l_set_recursion := 'N';

            ELSE

                l_set_recursion := 'Y';

            END IF;

            OE_Shipping_Integration_Pvt.Call_Process_Order
            (
            p_line_tbl		=> l_split_line_tbl,
            p_control_rec		=> l_control_rec,
            x_return_status	=> l_return_status
            );

            IF  l_set_recursion = 'Y' THEN

                l_set_recursion := 'N';
            END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RETURN STATUS FROM PROCESS ORDER : '||L_RETURN_STATUS , 3 ) ;
            END IF;

            IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        << END_REQ_QTY >>
        NULL;

        END LOOP;

    END IF; /* Req quantity table */

    IF  p_line_adj_tbl.COUNT > 0 THEN
    -- Create Freight Cost Records Here
        NULL;
        FOR J IN 1..p_line_adj_tbl.COUNT
        LOOP
            SELECT OE_PRICE_ADJUSTMENTS_S.nextval
            INTO l_price_adjustment_id
            FROM DUAL;

            l_line_adj_rec := p_line_adj_tbl(J);
            l_Line_adj_rec.price_adjustment_id := l_price_adjustment_id;
            l_Line_adj_rec.last_update_date := SYSDATE;
            l_Line_adj_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Line_adj_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
            l_Line_adj_rec.creation_date := SYSDATE;
            l_Line_adj_rec.created_by := FND_GLOBAL.USER_ID;
            -- #3015849
            IF l_debug_level > 0 THEN
               OE_DEBUG_PUB.add('Calling convert_miss_to_null for this adj record',5);
            END IF;
            OE_LINE_ADJ_UTIL.CONVERT_MISS_TO_NULL( l_line_adj_rec );
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INSERTING THE ADJ RECORD '||TO_CHAR ( L_LINE_ADJ_REC.PRICE_ADJUSTMENT_ID ) , 2 ) ;
            END IF;
            OE_LINE_ADJ_UTIL.INSERT_ROW(p_Line_Adj_rec => l_line_adj_rec);
        END LOOP;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NUMBER OF LINES SHIPPED : '||P_LINE_TBL.COUNT , 3 ) ;
    END IF;

    IF  p_line_tbl.COUNT > 0 THEN
	-- Update Line records for required attributes..

        FOR J IN 1..p_line_tbl.COUNT
        LOOP

            SELECT top_model_line_id
            INTO   l_top_model_line_id
            FROM   oe_order_lines
            WHERE  line_id = p_line_tbl(J).line_id;


            l_line_id_mod := mod(p_line_tbl(J).line_id,OE_GLOBALS.G_BINARY_LIMIT); -- Bug 8795918
	    --bug3549422
            --added the NOWAIT to the select statements and
            BEGIN

            -- Lock the Model line if the line is part of configuration.
            IF  nvl(l_top_model_line_id,0) <> 0 THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'LOCKING MODEL '||L_TOP_MODEL_LINE_ID||'/'||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 )
                    ;
                END IF;

                SELECT top_model_line_id
                INTO   l_top_model_line_id
                FROM   oe_order_lines
                WHERE  line_id = l_top_model_line_id
                FOR UPDATE NOWAIT;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'MODEL LOCKED '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
                END IF;

            END IF;

            SELECT  shipping_quantity,
                    shipping_quantity_uom,
                    order_quantity_uom,
                    actual_shipment_date,
                    inventory_item_id,
                    ship_from_org_id,
                    ship_set_id,
                    top_model_line_id,
                    ato_line_id,
                    model_remnant_flag,
                    ordered_quantity,
                    ship_tolerance_below,
                    over_ship_reason_code,
                    item_type_code,
                    header_id,
                    calculate_price_flag,
                    ship_model_complete_flag
            INTO    l_shipping_quantity,
                    l_shipping_quantity_uom,
                    l_order_quantity_uom,
                    l_actual_shipment_date,
                    l_inventory_item_id,
                    l_ship_from_org_id,
                    l_ship_set_id,
                    l_top_model_line_id,
                    l_ato_line_id,
                    l_model_remnant_flag,
                    l_ordered_quantity,
                    l_ship_tolerance_below,
                    l_over_ship_reason_code,
                    l_item_type_code,
                    l_header_id,
                    l_calculate_price_flag,
                    l_smc_flag
            FROM OE_ORDER_LINES
            WHERE line_id = p_line_tbl(J).line_id
            FOR UPDATE NOWAIT;

	    l_ship_set_id_mod := mod(l_ship_set_id,OE_GLOBALS.G_BINARY_LIMIT); -- Bug 8795918

            EXCEPTION

              WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.Add('Unable to lock the line/parent',3);
                END IF;
                RAISE FND_API.G_EXC_ERROR;


             WHEN OTHERS THEN
               IF l_debug_level > 0 THEN
                  OE_DEBUG_PUB.Add('Unable to process ship confirm line:'||
                                    sqlerrm,3);
               END IF;
               RAISE FND_API.G_EXC_ERROR;

            END;
            --bug3549422 ends

            IF  p_line_tbl(J).ship_tolerance_below = FND_API.G_MISS_NUM THEN

                l_ship_tolerance_below_upd := l_ship_tolerance_below;

            ELSE

                l_ship_tolerance_below_upd := p_line_tbl(J).ship_tolerance_below;

            END IF;

            IF  p_line_tbl(J).over_ship_reason_code = FND_API.G_MISS_CHAR THEN

                l_over_ship_reason_code_upd := l_over_ship_reason_code;

            ELSE

                l_over_ship_reason_code_upd := p_line_tbl(J).over_ship_reason_code;

            END IF;

            IF NOT OE_GLOBALS.Equal(p_line_tbl(J).shipping_quantity,l_shipping_quantity) THEN
                -- Convert the shipping quantity from shipping quantity UOM to
                -- Ordered quantity UOM and update the field shipped quantity
                -- Call API to convert the shipping quantity to shipped quantity
                -- from shipping quantity UOM to ordered quantity UOM and assign
                -- the returned quantity to shipped quantity.

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ORDER QUANTITY UOM : '|| L_ORDER_QUANTITY_UOM , 2 ) ;
                END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SHIPPING QUANTITY UOM : '||P_LINE_TBL ( J ) .SHIPPING_QUANTITY_UOM , 2 ) ;
                END IF;

                IF p_line_tbl(J).shipping_quantity_uom <> l_order_quantity_uom THEN

		/* --OPM 06/SEP/00 invoke process Uom Conversion for process line
		--============================================================  */
--  Invoke lot Uom Conversion possibly if for DUAL line INVCONV

                   IF oe_line_util.dual_uom_control
                   (l_inventory_item_id
                   ,l_ship_from_org_id
                   ,l_item_rec) THEN

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'DUAL ITEM  - SHIPPING UPDATE ' , 1 ) ;
                      END IF;

-- HW OPM BUG#:2415731 Since OM does not save lot and sublot information and shipping does,
-- we need to retrieve the information from wsh_delivery_details

                      l_temp_dual_shipped_qty := 0;

-- Fetch lot information from shipping table

                      OPEN LOT_INFO(p_line_tbl(J).line_id);
                      FETCH LOT_INFO INTO LOT;
	              while LOT_INFO%FOUND LOOP
/*  -- INVCONV
-- HW OPM BUG#:2415731
-- Sublot could be NULL, so we need to have different select statements
-- Unique Key in ic_loct_mst:lot_no,sublot_no and item_id.
-- Primary key is: item_id,lot_id.

-- Case 1: Both lot_no and sublot_no are not NULL
-- Uday Phadtare Bug 2886396 added exception and commented lot_id condition.
                      IF ( LOT.lot_number is NOT NULL AND LOT.sublot_number IS NOT NULL) THEN
                         BEGIN
                            SELECT ic.lot_id
                            INTO   l_lot_id
                            FROM   ic_lots_mst ic
                            WHERE  ic.lot_no = LOT.lot_number
                            AND    ic.item_id = l_item_rec.opm_item_id
                            AND    ic.sublot_no = LOT.sublot_number;
                            -- AND    ic.lot_id <> 0 ;
                         EXCEPTION
                             WHEN OTHERS THEN
                                  l_lot_id := 0;
                         END;
-- HW BUG#:2415731
-- Case 2: Sublot_no is NULL and lot_no is not
-- Uday Phadtare Bug 2886396 added exception and commented lot_id condition.
                      ELSIF (LOT.lot_number is NOT NULL AND LOT.sublot_number is NULL) THEN
                         BEGIN
                            SELECT ic.lot_id
                            INTO   l_lot_id
                            FROM   ic_lots_mst ic
                            WHERE  ic.lot_no = LOT.lot_number
                            AND    ic.item_id = l_item_rec.opm_item_id
                            AND    ic.sublot_no IS NULL;
                            -- AND    ic.lot_id <> 0 ;
                         EXCEPTION
                             WHEN OTHERS THEN
                                  l_lot_id := 0;
                         END;
-- HW BUG#:2415731
-- Case 3: Both lot_no and sublot_no are NULL
                      ELSE
                         l_lot_id := 0;
                      END IF;

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'OPM , VALUE OF LOT_ID IS : '||L_LOT_ID , 1 ) ;
                      END IF;

*/
-- INVCONV





-- BUG#: 2415731 pass l_lot_number to perform any lot specific  conversion -- INVCONV
-- and pass LOT.shipped_quantity to calculate shipped_qty for each line

                      /*l_temp_shipped_quantity := GMI_Reservation_Util.get_opm_converted_qty(
                          p_apps_item_id    => l_inventory_item_id,
                          p_organization_id => l_ship_from_org_id,
                          p_apps_from_uom   => p_line_tbl(J).shipping_quantity_uom,
                          p_apps_to_uom     => l_order_quantity_uom,
                          p_original_qty    => LOT.shipped_quantity,
                          p_lot_id          => l_lot_id); */

l_temp_shipped_quantity :=
 INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id 													, l_lot_number -- INVCONV
	                    , l_ship_from_org_id -- INVCONV
			    ,9 -- Precision (Default precision is 6 decimals) ?
                            ,LOT.shipped_quantity
                            ,p_line_tbl(J).shipping_quantity_uom
                            ,l_order_quantity_uom
                            ,NULL -- From uom name
                            ,NULL -- To uom name
                            );

-- BUG 2415731, sum the shipped_qty  -- INVCONV
                      l_temp_dual_shipped_qty := l_temp_dual_shipped_qty + l_temp_shipped_quantity; -- INVCONV

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'OPM , VALUE OF TEMP_DUAL_SHIPPED_QTY IS '||L_TEMP_DUAL_SHIPPED_QTY , 1 ) ; -- INVCONV
                     END IF;

-- HW BUG#:2415731 Fetch the next record and close the cursor
                      FETCH LOT_INFO into LOT;
                      END LOOP;
                      << loop_end>>
                      CLOSE LOT_INFO;

                      l_temp_shipped_quantity := l_temp_dual_shipped_qty; --INVCONV
-- HW end of changes for bug 2415731

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'DUAL PROCESS SHIPPING UPDATE CONVERSION' || ' GIVES SHIPPED QUANTITY OF ' ||
                          L_TEMP_SHIPPED_QUANTITY , 1 ) ;
                      END IF;

                   ELSE


                       l_temp_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
                       (
                       l_inventory_item_id,
                       p_line_tbl(J).shipping_quantity_uom,
                       l_order_quantity_uom,
                       p_line_tbl(J).shipping_quantity
                       );
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'CONVERTED SHIPPED QUANTITY : '|| TO_CHAR ( L_TEMP_SHIPPED_QUANTITY ) , 1 ) ;
                       END IF;
                   END IF;  --IF oe_line_util.dual_uom_control -- INVCONV

                   --OPM 06/SEP/00 END



                   oe_debug_pub.ADD('Converted Shipped Quantity : '||to_char(l_temp_shipped_quantity),1);

                   IF l_temp_shipped_quantity <> trunc(l_temp_shipped_quantity) THEN

                      Inv_Decimals_PUB.Validate_Quantity
                      (
                      p_item_id	         => l_inventory_item_id,
                      p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
                      p_input_quantity   => l_temp_shipped_quantity,
                      p_uom_code         => l_order_quantity_uom,
                      x_output_quantity  => l_validated_quantity,
                      x_primary_quantity => l_primary_quantity,
                      x_return_status    => l_qty_return_status
                      );

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'RETURN STATUS FROM INV API : '||L_QTY_RETURN_STATUS , 1 ) ;
                      END IF;
                      IF l_qty_return_status = 'W' THEN

                         l_shipped_quantity := l_validated_quantity;
                      ELSE

                         l_shipped_quantity := l_temp_shipped_quantity;

                      END IF;

                   ELSE
                       l_shipped_quantity := l_temp_shipped_quantity;

                   END IF; -- IF l_temp_shipped_quantity <> trunc

                ELSE
                    l_shipped_quantity := p_line_tbl(J).shipping_quantity;

                END IF; --IF p_line_tbl(J).shipping_quantity_uom <> l_order_quantity_uom

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'SHIPPED QUANTITY : '|| TO_CHAR ( L_SHIPPED_QUANTITY ) , 1 ) ;
                END IF;


                -- updating remnant flag for various conditions.

                IF l_top_model_line_id is not NULL AND
                   nvl(l_smc_flag, 'N') = 'N' AND
                   nvl(l_model_remnant_flag, 'N') = 'N' AND
                   OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508'
                THEN

                  SELECT ato_line_id
                  INTO   l_count
                  FROM   oe_order_lines
                  WHERE  line_id = l_top_model_line_id;

                  IF l_count is NULL THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'LINE PART OF NON SMC PTO' , 4 ) ;
                    END IF;

                    -- if ato+pto with external lines, make it remnant.

                  --bug3480047 contd
                  SELECT COUNT(*)
                  INTO   l_shippable_lines
                  FROM   OE_ORDER_LINES
                  WHERE  top_model_line_id = l_top_model_line_id
                  AND    NVL(CANCELLED_FLAG,'N')='N'
                  AND    NVL(SHIPPABLE_FLAG,'N')='Y';

                  IF l_shippable_lines > 1 THEN

                    SELECT count(*)
                    INTO   l_count
                    FROM   oe_order_lines
                    WHERE  top_model_line_id = l_top_model_line_id
                    AND    cancelled_flag = 'N'
                    AND    source_type_code = 'EXTERNAL';

                    IF l_count > 0 THEN
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'EXTERNAL LINES EXIST' , 2 ) ;
                      END IF;
                      l_make_remnant := 'Y'; --bug 4701487
                    END IF;
                  END IF; --bug3480047 ends

                    -- if non smc model with ato and config line not created
                    -- make it remanant.
                   IF l_make_remnant  <> 'Y'  THEN -- bug 4701487
                    l_count := 0;

                    /* MOAC_SQL_CHANGE */
                    SELECT count(*)
                    INTO   l_count
                    FROM   oe_order_lines oe1
                    WHERE  top_model_line_id = l_top_model_line_id
                    AND    ato_line_id = line_id
                    AND    item_type_code = 'CLASS'
                    AND    cancelled_flag = 'N'
                    AND    not exists
                           (SELECT NULL
                            FROM   oe_order_lines_all
                            WHERE  top_model_line_id = l_top_model_line_id
                            AND    ato_line_id = oe1.line_id
                            AND    cancelled_flag = 'N'
                            AND    item_type_code = 'CONFIG');

                    IF l_count > 0 THEN
                      IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ATO model line does not have CONFIG created' , 2 ) ;
                      END IF;
                      l_make_remnant := 'Y'; --bug 4701487
                    END IF;
                  END IF;

                  IF l_make_remnant  <> 'Y'  THEN -- bug 4701487
                    l_count := 0;
                    BEGIN
                    SELECT 1 INTO   l_count
                    FROM DUAL
                    WHERE EXISTS (
                                 SELECT NULL
                                 FROM   oe_order_lines
                                 WHERE  top_model_line_id = l_top_model_line_id
                                 AND    cancelled_flag = 'N'
                                 AND    schedule_ship_date  is NULL);
                    EXCEPTION
                       WHEN OTHERS THEN
                          NULL;
                    END;

                    IF l_count > 0 THEN
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add('Atleast one un-scheduled line exists in the Model...' , 2 ) ;
                      END IF;
                      l_make_remnant := 'Y'; -- bug 4701487
                    END IF;
                  END IF;

                  IF l_make_remnant  = 'Y'  THEN -- bug 4701487
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'Making the model REMNANT:'|| L_TOP_MODEL_LINE_ID , 3 ) ;
                      END IF;
                      UPDATE oe_order_lines
                      SET    model_remnant_flag = 'Y'
                      WHERE  top_model_line_id = l_top_model_line_id;

                      l_model_remnant_flag := 'Y';
                  END IF;

                  END IF; -- if top model is not ATO.

                END IF; -- if part of model.



		-- Add to the ship confirm table

                IF  (l_ship_set_id IS NOT NULL AND
                    l_ship_set_id <> FND_API.G_MISS_NUM) THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'SHIP SET SHIPPED : '||L_SHIP_SET_ID , 3 ) ;
                    END IF;

                    -- IF  l_ship_confirm_tbl.EXISTS(l_ship_set_id) THEN -- Bug 8795918
                    IF  l_ship_confirm_tbl.EXISTS(l_ship_set_id_mod) THEN

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'SHIP SET ALREADY EXISTS : '||L_SHIP_SET_ID , 3 ) ;
                        END IF;
                    ELSE
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'ADD SHIP SET : '||L_SHIP_SET_ID , 3 ) ;
                        END IF;
                        --l_ship_confirm_tbl(l_ship_set_id).type_id := l_ship_set_id; -- Bug 8795918
                        --l_ship_confirm_tbl(l_ship_set_id).ship_confirm_type := 'SHIP_SET'; -- Bug 8795918
                        l_ship_confirm_tbl(l_ship_set_id_mod).type_id := l_ship_set_id;
                        l_ship_confirm_tbl(l_ship_set_id_mod).ship_confirm_type := 'SHIP_SET';

                    END IF;

                ELSIF (l_ato_line_id IS NOT NULL AND
                       l_ato_line_id <> FND_API.G_MISS_NUM) AND
                       l_item_type_code = Oe_Globals.G_ITEM_CONFIG AND
                       l_ato_line_id = l_top_model_line_id THEN

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'ATO SHIPPED : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                       END IF;

                       IF  l_ship_confirm_tbl.EXISTS(p_line_tbl(J).line_id) THEN

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'ATO ALREADY EXISTS : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                           END IF;

                       ELSE
                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'ADD ATO : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                           END IF;
                           -- l_ship_confirm_tbl(p_line_tbl(J).line_id).type_id := p_line_tbl(J).line_id; -- Bug 8795918
                           -- l_ship_confirm_tbl(p_line_tbl(J).line_id).ship_confirm_type := 'ATO'; -- Bug 8795918
			   l_ship_confirm_tbl(l_line_id_mod).type_id := p_line_tbl(J).line_id;
			   l_ship_confirm_tbl(l_line_id_mod).ship_confirm_type := 'ATO';

                       END IF;

                ELSIF  (l_top_model_line_id IS NOT NULL AND
                       l_top_model_line_id <> FND_API.G_MISS_NUM) AND
                       nvl(l_model_remnant_flag,'N') = 'N' THEN

		        l_top_model_line_id_mod := mod(l_top_model_line_id,OE_GLOBALS.G_BINARY_LIMIT);-- Bug 8795918

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'PTO/KIT SHIPPED : '||L_TOP_MODEL_LINE_ID , 3 ) ;
                       END IF;

                       -- IF  l_ship_confirm_tbl.EXISTS(l_top_model_line_id) THEN Bug 8795918
                       IF  l_ship_confirm_tbl.EXISTS(l_top_model_line_id_mod) THEN

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'PTO/KIT ALREADY EXISTS : '||L_TOP_MODEL_LINE_ID , 3 ) ;
                           END IF;

                       ELSE
                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'ADD PTO/KIT : '||L_TOP_MODEL_LINE_ID , 3 ) ;
                           END IF;
                           -- l_ship_confirm_tbl(l_top_model_line_id).type_id := l_top_model_line_id; -- Bug 8795918
                           -- l_ship_confirm_tbl(l_top_model_line_id).ship_confirm_type := 'PTO_KIT'; -- Bug 8795918
                           l_ship_confirm_tbl(l_top_model_line_id_mod).type_id := l_top_model_line_id;
                           l_ship_confirm_tbl(l_top_model_line_id_mod).ship_confirm_type := 'PTO_KIT';

                       END IF;

                ELSE
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'NORMAL SHIPPED : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                       END IF;

                       -- IF  l_ship_confirm_tbl.EXISTS(p_line_tbl(J).line_id) THEN -- Bug 8795918
		       IF  l_ship_confirm_tbl.EXISTS(l_line_id_mod) THEN

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'ALREADY EXISTS : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                           END IF;

                       ELSE
                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'ADD : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                           END IF;
                           -- l_ship_confirm_tbl(p_line_tbl(J).line_id).type_id := p_line_tbl(J).line_id; -- Bug 8795918
                           -- l_ship_confirm_tbl(p_line_tbl(J).line_id).ship_confirm_type := l_item_type_code; -- Bug 8795918
                           l_ship_confirm_tbl(l_line_id_mod).type_id := p_line_tbl(J).line_id;
			   l_ship_confirm_tbl(l_line_id_mod).ship_confirm_type := l_item_type_code;

                       END IF;

                   END IF;

                END IF; -- IF NOT OE_GLOBALS.Equal


		/* jolin start */
		/* Moved call to query record out NOCOPY of IF ordered=shipped below so that
		   it always happens to populate the current and old line table for notification */

                   OE_Line_Util.Query_Rows(p_line_id  => p_line_tbl(J).line_id,
                                         x_line_tbl   => l_temp_line_tbl);

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'RETURNED FROM QUERY ROW ' , 1 ) ;
                   END IF;
                   l_old_line_tbl(J) := l_temp_line_tbl(1);
                   l_line_tbl(J) := l_old_line_tbl(J);

		/* jolin end */

       		-- If no partial shipment then
                IF l_ordered_quantity = l_shipped_quantity THEN

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'UPDATING LINE : '||P_LINE_TBL ( J ) .LINE_ID , 3 ) ;
                   END IF;

                  IF ((OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
                      (OE_GLOBALS.G_EC_INSTALLED = 'Y')  OR
	   	      (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y') )
		  THEN
		   /* l_line_tbl(J) already holds the old info, so just overwrite what changed */
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'NEED TO CALL PROCESS REQUEST ' , 3 ) ;
                   END IF;
                   l_line_tbl(J).shipping_quantity := p_line_tbl(J).shipping_quantity;
                   l_line_tbl(J).shipping_quantity2 := p_line_tbl(J).shipping_quantity2;
                   l_line_tbl(J).shipped_quantity2 := p_line_tbl(J).shipping_quantity2;
                   l_line_tbl(J).shipping_quantity_uom := p_line_tbl(J).shipping_quantity_uom;
               		 l_line_tbl(J).shipping_quantity_uom2 := p_line_tbl(J).shipping_quantity_uom2; -- INVCONV
                   l_line_tbl(J).shipped_quantity := l_shipped_quantity; -- PLA ?

                   l_line_tbl(J).actual_shipment_date := p_line_tbl(J).actual_shipment_date;
                   l_line_tbl(J).over_ship_reason_code := l_over_ship_reason_code_upd;
                   l_line_tbl(J).ship_tolerance_below := l_ship_tolerance_below_upd;
                   l_notify := TRUE;
                  END IF; /* need to update global picture */

                UPDATE OE_ORDER_LINES
                SET shipping_quantity = p_line_tbl(J).shipping_quantity,
                shipping_quantity2 = p_line_tbl(J).shipping_quantity2,
                shipped_quantity2 = p_line_tbl(J).shipping_quantity2,
                shipping_quantity_uom = p_line_tbl(J).shipping_quantity_uom,
                shipping_quantity_uom2 = p_line_tbl(J).shipping_quantity_uom2, -- INVCONV
                actual_shipment_date = p_line_tbl(J).actual_shipment_date,
                ship_tolerance_below = l_ship_tolerance_below_upd,
                over_ship_reason_code = l_over_ship_reason_code_upd,
                shipped_quantity = l_shipped_quantity
                WHERE line_id = p_line_tbl(J).line_id;

 	   ELSE  /* ordered does not equal shipped qty */

                  IF ((OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
                      (OE_GLOBALS.G_EC_INSTALLED = 'Y')  OR
	   	      (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y'))
		  THEN
		   /* l_line_tbl(J) already holds the old info, so just overwrite what changed */
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'NEED TO CALL PROCESS REQUEST ' , 3 ) ;
			END IF;
			l_line_tbl(J).shipping_quantity := p_line_tbl(J).shipping_quantity;
			l_line_tbl(J).shipping_quantity2 := p_line_tbl(J).shipping_quantity2;
			l_line_tbl(J).shipped_quantity2 := p_line_tbl(J).shipping_quantity2;
			l_line_tbl(J).shipping_quantity_uom := p_line_tbl(J).shipping_quantity_uom;
			l_line_tbl(J).shipping_quantity_uom2 := p_line_tbl(J).shipping_quantity_uom2; -- INVCONV

			l_line_tbl(J).shipped_quantity := l_shipped_quantity; -- INVCONV
			l_line_tbl(J).actual_shipment_date := p_line_tbl(J).actual_shipment_date;
			l_line_tbl(J).over_ship_reason_code := l_over_ship_reason_code_upd;
			l_line_tbl(J).ship_tolerance_below := l_ship_tolerance_below_upd;
			l_notify := TRUE;
		END IF; /* need to update global picture */

		OE_Shipping_Integration_PVT.Check_Shipment_Line(
				   p_line_rec                => l_temp_line_tbl(1)
				,  p_shipped_quantity        => l_Shipped_Quantity
				,  x_result_out              => l_result_out
				);

		IF l_result_out = OE_GLOBALS.G_PARTIALLY_SHIPPED THEN
		-- This line will split, set the calculate_price_flag  to 'P' if 'Y'
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CALCULATE PRICE FLAG : '||L_CALCULATE_PRICE_FLAG , 3 ) ;
                END IF;
				IF l_calculate_price_flag = 'Y' THEN
					l_calculate_price_flag := 'P';
				END IF;
		END IF;  /* partially shipped */

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'CALCULATE PRICE FLAG : '||L_CALCULATE_PRICE_FLAG , 3 ) ;
                END IF;
				UPDATE OE_ORDER_LINES
				SET shipping_quantity = p_line_tbl(J).shipping_quantity,
				shipping_quantity2 = p_line_tbl(J).shipping_quantity2,
				shipped_quantity2 = p_line_tbl(J).shipping_quantity2,
				shipping_quantity_uom = p_line_tbl(J).shipping_quantity_uom,
		 	  shipping_quantity_uom2 = p_line_tbl(J).shipping_quantity_uom2, -- INVCONV
				actual_shipment_date = p_line_tbl(J).actual_shipment_date,
				ship_tolerance_below = l_ship_tolerance_below_upd,
				over_ship_reason_code = l_over_ship_reason_code_upd,
				shipped_quantity = l_shipped_quantity,
				calculate_price_flag = l_calculate_price_flag
				WHERE line_id = p_line_tbl(J).line_id;

	END IF;  /* ordered = shipped */

			/* Log the pricing delayed request */

                    IF l_calculate_price_flag IN ('Y','P')
                        OR (p_line_tbl(J).shipping_quantity2 IS NOT NULL
                            AND p_line_tbl(J).shipping_quantity2 <> 0 ) -- bug 3598987,3659454
                    THEN
                        oe_debug_pub.add( 'Before logging Delayed request for pricing',3);
			OE_delayed_requests_Pvt.log_request(
			p_entity_code       		=> OE_GLOBALS.G_ENTITY_ALL,
			p_entity_id             	=> p_line_tbl(J).line_id,
			p_requesting_entity_code 	=> OE_GLOBALS.G_ENTITY_ALL,
			p_requesting_entity_id   	=> p_line_tbl(J).line_id,
			p_request_unique_key1   	=> 'SHIP',
			p_param1                 	=> l_header_id,
			p_param2                 	=> 'SHIP',
			p_request_type           	=> OE_GLOBALS.G_PRICE_LINE,
			x_return_status          	=> l_return_status);

                    END IF;


	END LOOP; /* over J */

	-- Now process ship confirms.

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NUMBER OF SHIP CONFIRMS : '||L_SHIP_CONFIRM_TBL.COUNT , 3 ) ;
	END IF;

	l_ship_confirm_index := l_ship_confirm_tbl.FIRST;

	WHILE l_ship_confirm_index IS NOT NULL
	LOOP

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'TYPE/ID : '||L_SHIP_CONFIRM_TBL ( L_SHIP_CONFIRM_INDEX )
                    .SHIP_CONFIRM_TYPE||'/'||L_SHIP_CONFIRM_TBL ( L_SHIP_CONFIRM_INDEX ) .TYPE_ID , 3 ) ;
		END IF;

		OE_Shipping_Integration_PVT.Process_Ship_Confirm

		(p_process_id	=>	l_ship_confirm_tbl(l_ship_confirm_index).type_id,
		 p_process_type	=>	l_ship_confirm_tbl(l_ship_confirm_index).ship_confirm_type,
		 x_return_status => l_return_status

		);

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETRUN STATUS FROM PROCESS_SHIP_CONFIRM : '||L_RETURN_STATUS , 3 ) ;
		END IF;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;

		l_ship_confirm_index := l_ship_confirm_tbl.NEXT(l_ship_confirm_index);

	END LOOP;  /* over ship confirm index */

-- jolin start
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

-- Here we call update_global_picture to get the index of each line being updated in the
-- update statement above, and we set the global variables for each.

--  loop over l_line_tbl using loop_index

     l_loop_index := l_line_tbl.FIRST;

     WHILE l_loop_index IS NOT NULL LOOP

    -- call notification framework to get this line's index position
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
        , p_header_id           => l_line_tbl(l_loop_index).header_id
	, p_line_rec		=> l_line_tbl(l_loop_index)
	, p_old_line_rec	=> l_old_line_tbl(l_loop_index)
        , p_line_id 		=> l_line_tbl(l_loop_index).line_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATE_GLOBAL RET_STATUS FOR LINE_ID '||L_LINE_TBL ( L_LOOP_INDEX ) .LINE_ID ||' IS: ' || L_RETURN_STATUS , 1
        ) ;
        oe_debug_pub.add('UPDATE_GLOBAL INDEX FOR LINE_ID '||L_LINE_TBL ( L_LOOP_INDEX ) .LINE_ID ||' IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   IF l_notify_index is not null then
     -- modify Global Picture
-- uncommented for bug 2934535
     OE_ORDER_UTIL.g_old_line_tbl(l_notify_index) := l_old_line_tbl(l_loop_index);

-- Commented for bug 2818553 hashraf
--    OE_ORDER_UTIL.g_line_tbl(l_notify_index) := OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
     OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id := l_line_tbl(l_loop_index).line_id;
     OE_ORDER_UTIL.g_line_tbl(l_notify_index).header_id := l_line_tbl(l_loop_index).header_id;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_date := l_line_tbl(l_loop_index).last_update_date;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipping_quantity:=  l_line_tbl(l_loop_index).shipping_quantity;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipping_quantity2:= l_line_tbl(l_loop_index).shipping_quantity2;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipped_quantity:=   l_line_tbl(l_loop_index).shipped_quantity;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipped_quantity2:=  l_line_tbl(l_loop_index).shipped_quantity2;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipping_quantity_uom:= l_line_tbl(l_loop_index).shipping_quantity_uom;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).shipping_quantity_uom2:= l_line_tbl(l_loop_index).shipping_quantity_uom2; -- INVCONV
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).actual_shipment_date:=  l_line_tbl(l_loop_index).actual_shipment_date;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).ship_tolerance_below:=	l_line_tbl(l_loop_index).ship_tolerance_below;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).over_ship_reason_code:=	l_line_tbl(l_loop_index).over_ship_reason_code;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).calculate_price_flag:=	l_line_tbl(l_loop_index).calculate_price_flag;
    -- bug 3272489
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_category_code :=      l_line_tbl(l_loop_index).line_category_code;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPING_QUANTITY: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPING_QUANTITY , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPING_QUANTITY2: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPING_QUANTITY2 , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPED_QUANTITY: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPED_QUANTITY , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPED_QUANTITY2: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPED_QUANTITY2 , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPING_QUANTITY_UOM: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPING_QUANTITY_UOM , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIPPING_QUANTITY_UOM2: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPING_QUANTITY_UOM2 , 1 ) ; -- INVCONV
		    oe_debug_pub.add(  'GLOBAL LINE ACTUAL_SHIPMENT_DATE: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .ACTUAL_SHIPMENT_DATE , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE SHIP_TOLERANCE_BELOW: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIP_TOLERANCE_BELOW , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE OVER_SHIP_REASON_CODE: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .OVER_SHIP_REASON_CODE , 1 ) ;
		    oe_debug_pub.add(  'GLOBAL LINE CALCULATE_PRICE_FLAG: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX )
                    .CALCULATE_PRICE_FLAG , 1 ) ;
                    oe_debug_pub.add(  'OLD GLOBAL LINE SHIPPED QTY IS: ' || OE_ORDER_UTIL.G_OLD_LINE_TBL ( L_NOTIFY_INDEX )
                    .SHIPPED_QUANTITY ) ;
                    oe_debug_pub.add(  'GLOBAL LINE FLOW STATUS IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .FLOW_STATUS_CODE
                    ) ;
                    oe_debug_pub.add(  'OLD GLOBAL LINE FLOW STATUS IS: ' || OE_ORDER_UTIL.G_OLD_LINE_TBL ( L_NOTIFY_INDEX )
                    .FLOW_STATUS_CODE ) ;
                    oe_debug_pub.add(  'OLD GLOBAL LINE Category Code is ' || OE_ORDER_UTIL.G_OLD_LINE_TBL ( L_NOTIFY_INDEX )
                    .LINE_CATEGORY_CODE ) ;
		END IF;

   END IF ; /* global entity index null check */

     l_loop_index := l_line_tbl.NEXT(l_loop_index);

  END LOOP; -- over each line to update global picture

	OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests          => TRUE
		, p_notify                    => FALSE  -- was l_notify
		, x_return_status             => l_return_status
		, p_line_tbl                  => l_line_tbl
		, p_old_line_tbl              => l_old_line_tbl
		);

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURNED FROM PROCESS REQUEST AND NOTIFY : '||L_RETURN_STATUS , 3 ) ;
		END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

ELSE /* pre-code H */

       OE_Set_Util.Process_Sets
        (p_x_line_tbl => l_line_tbl);

	OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests          => TRUE
		, p_notify                    => l_notify
		, x_return_status             => l_return_status
		, p_line_tbl                  => l_line_tbl
		, p_old_line_tbl              => l_old_line_tbl
		);

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURNED FROM PROCESS REQUEST AND NOTIFY : '||L_RETURN_STATUS , 3 ) ;
		END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END IF; /* code set is pack H or higher */
/* jolin end*/

	END IF; --IF p_line_tbl.COUNT > 0

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNED FROM OE_SHIP_CONFIRM.SHIP_CONFIRM '||X_RETURN_STATUS , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'EXC ERROR : '||SQLERRM , 1 ) ;
	   END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
	   END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IN OTHERS '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
		END IF;

        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
           	 FND_MSG_PUB.Add_Exc_Msg
           	 (   G_PKG_NAME
           	 ,   'Process_Line'
           	 );
        	END IF;

        	--  Get message count and data

        	OE_MSG_PUB.Count_And_Get
        	(   p_count                       => x_msg_count
        	,   p_data                        => x_msg_data
        	);
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Ship_Confirm;

PROCEDURE Process_Requests
IS
l_return_status  VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF (OE_GLOBALS.G_RECURSION_MODE = 'N'
        AND OE_DELAYED_REQUESTS_PVT.Requests_Count > 0 )
    THEN

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_HEADER_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Header_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Scredit
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Price_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Att
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
          (p_entity_code   => OE_GLOBALS.G_ENTITY_Line_Adj_Assoc
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Execute all remaining delayed requests. This would execute
	  -- requests logged against entity G_ENTITY_HEADER and G_ENTITY_ALL

       OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
          x_return_status => l_return_status
          );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF; --End of requests processing


END Process_Requests;


/*----------------------------------------------------------------
PROCEDURE Validate_Quantity

what about requested quantity 2 check??
code to handle p_handle_req_qty -- decode -- INVCONV ADDED FOR OPM INVENTORY CONVERGENCE
-----------------------------------------------------------------*/
PROCEDURE Validate_Quantity
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_handle_req_qty     IN VARCHAR2 := 'N'
 ,p_index              IN NUMBER )
  --,x_dual_item           OUT NOCOPY VARCHAR2) INVCONV
IS
  l_item_rec           OE_ORDER_CACHE.item_rec_type;
  l_return_status      VARCHAR2(1);
  l_primary_quantity   NUMBER;
  l_validated_quantity NUMBER;
  l_debug_level        CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Validate_Quantity '|| p_index, 5);
    oe_debug_pub.add
    ('order uom ' ||p_ship_line_rec.order_quantity_uom(p_index), 5);
    oe_debug_pub.add
    ('shipping uom ' || p_ship_line_rec.shipping_quantity_uom(p_index), 5);
  END IF;

  IF p_ship_line_rec.order_quantity_uom(p_index) <>
     p_ship_line_rec.shipping_quantity_uom(p_index) THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('uom diff ', 5);
    END IF;

    IF p_handle_req_qty = 'Y' THEN
      l_primary_quantity := p_ship_line_rec.requested_quantity(p_index);
    ELSE
      l_primary_quantity := p_ship_line_rec.shipping_quantity(p_index);
    END IF;

    /* IF OE_Line_Util.dual_uom_control -- INVCONV RENAME PROCess_Characteristics INVCONV NO LONGER NEEDED
       (p_inventory_item_id   => p_ship_line_rec.inventory_item_id(p_index)
       ,p_ship_from_org_id    => p_ship_line_rec.ship_from_org_id(p_index)
       ,x_item_rec            => l_item_rec) THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DUAL PROCESS SHIPPING UPDATE ', 5); -- INVCONV
      END IF;

      x_dual_item := 'Y'; -- INVCONV

      p_ship_line_rec.shipped_quantity(p_index) :=
          GMI_Reservation_Util.get_opm_converted_qty
          (p_apps_item_id    => p_ship_line_rec.inventory_item_id(p_index),
           p_organization_id => p_ship_line_rec.ship_from_org_id(p_index),
           p_apps_from_uom   => p_ship_line_rec.shipping_quantity_uom(p_index),
           p_apps_to_uom     => p_ship_line_rec.order_quantity_uom(p_index),
           p_original_qty    => l_primary_quantity);

    ELSE */

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('call OE_Order_Misc_Util.Convert_Uom', 5);
      END IF;

      p_ship_line_rec.shipped_quantity(p_index) :=
          OE_Order_Misc_Util.Convert_Uom
          (p_item_id           => p_ship_line_rec.inventory_item_id(p_index),
           p_from_uom_code     => p_ship_line_rec.shipping_quantity_uom(p_index),
           p_to_uom_code       => p_ship_line_rec.order_quantity_uom(p_index),
           p_from_qty          => l_primary_quantity);

        --   END IF; -- if opm
	 --Bug#9437761
         IF p_ship_line_rec.order_quantity_uom2(p_index) IS NOT NULL AND
            p_ship_line_rec.order_quantity_uom2(p_index) = p_ship_line_rec.order_quantity_uom(p_index) THEN
            p_ship_line_rec.shipped_quantity(p_index) := p_ship_line_rec.shipping_quantity2(p_index);

         END IF ;


  ELSE

    IF p_handle_req_qty = 'Y' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('shipped qty ' ||p_ship_line_rec.shipped_quantity(p_index), 5);
        oe_debug_pub.add
        ('requested qty  '||p_ship_line_rec.requested_quantity(p_index), 5);
      END IF;

      p_ship_line_rec.shipped_quantity(p_index) :=
            p_ship_line_rec.requested_quantity(p_index);

      p_ship_line_rec.shipped_quantity2(p_index) :=  -- INVCONV
            p_ship_line_rec.requested_quantity2(p_index);

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('shping  qty '||p_ship_line_rec.shipping_quantity(p_index), 5);
      END IF;

      p_ship_line_rec.shipped_quantity(p_index) :=
            p_ship_line_rec.shipping_quantity(p_index);
      p_ship_line_rec.shipped_quantity2(p_index) :=  -- INVCONV
            p_ship_line_rec.shipping_quantity2(p_index);

    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('uom is same,shpd qty '||p_ship_line_rec.shipped_quantity(p_index), 5);
      oe_debug_pub.add
      ('uom2 is same,shpd qty2 '||p_ship_line_rec.shipped_quantity2(p_index), 5); -- INVCONV
    END IF;


  END IF;

  IF p_ship_line_rec.shipped_quantity(p_index) <>
     TRUNC(p_ship_line_rec.shipped_quantity(p_index)) THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('shipped qty deciaml', 5);
    END IF;

    Inv_Decimals_PUB.Validate_Quantity
    (p_item_id          => p_ship_line_rec.inventory_item_id(p_index),
     p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
     p_input_quantity   => p_ship_line_rec.shipped_quantity(p_index),
     p_uom_code         => p_ship_line_rec.order_quantity_uom(p_index),
     x_output_quantity  => l_validated_quantity,
     x_primary_quantity => l_primary_quantity,
     x_return_status    => l_return_status );

    IF l_return_status = 'W' THEN
      p_ship_line_rec.shipped_quantity(p_index) := l_validated_quantity;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('RET STS FROM INV API : '
                       ||L_RETURN_STATUS || l_validated_quantity,1);
    END IF;

  END IF; -- if decimal

END Validate_Quantity;


/*----------------------------------------------------------------
PROCEDURE Handle_Requested_Qty
set recurstion flag ??

Record History
3329866 - Split From Line id is populated for second line
3317898 - split from line id populated incorrectly for models
-----------------------------------------------------------------*/
PROCEDURE Handle_Requested_Qty
( p_requested_line_rec IN OUT NOCOPY  Ship_Line_Rec_Type)
IS
  --J                      NUMBER := 0; bug 4422886
  l_split_line_rec       OE_Order_Pub.Line_Rec_Type;
  l_control_rec          OE_GLOBALS.Control_Rec_Type;
  l_return_status        VARCHAR2(1);
  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_split_line_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_wdd_count            NUMBER;
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering handle_requested_Quantity ', 5);
  END IF;

  FOR I in p_requested_line_rec.line_id.FIRST..
           p_requested_line_rec.line_id.LAST
  LOOP

   IF l_debug_level > 0 THEN
       oe_debug_pub.add('Before checking deleievry detail split ', 1);
        oe_debug_pub.add('Item type code :'||p_requested_line_rec.item_type_code(I), 1);
   END IF;

   -- Bug 7648161
   p_requested_line_rec.shipped_quantity.extend;
   p_requested_line_rec.shipped_quantity2.extend;

   p_requested_line_rec.shipped_quantity(I) := null;
   p_requested_line_rec.shipped_quantity2(I) := null;
   -- Bug 7648161

     IF p_requested_line_rec.item_type_code(I) = 'STANDARD' THEN

         SELECT count(*)
          INTO l_wdd_count
          FROM wsh_delivery_details
         WHERE source_line_id = p_requested_line_rec.line_id(I)
          AND  released_status <> 'D'
          AND  source_code = 'OE'
          AND  oe_interfaced_flag = 'N';

      END IF;

   IF nvl(l_wdd_count,1) > 0 THEN

    IF l_debug_level  > 0 THEN
       OE_DEBUG_PUB.Add('SR5331603 Delivery Detail Has Split..'||l_wdd_count,1);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('looping over requested qty '
                        || p_requested_line_rec.requested_quantity(I), 1);
      oe_debug_pub.add('looping over ordered qty '
                        || p_requested_line_rec.ordered_quantity(I), 1);
    END IF;

    Validate_Quantity
    ( p_ship_line_rec       => p_requested_line_rec
     ,p_handle_req_qty      => 'Y'
     ,p_index               => I );
     -- ,x_dual_item            => l_return_status); -- INVCONV

    l_split_line_Rec := OE_ORDER_PUB.G_MISS_LINE_REC;

    --J := J + 1; bug 4422886

    IF p_requested_line_rec.ordered_quantity(I) >
       p_requested_line_rec.shipped_quantity(I) THEN

      IF p_requested_line_rec.ato_line_id(I) IS NOT NULL AND
         p_requested_line_rec.item_type_code(I) <> 'STANDARD' THEN

        l_split_line_rec.line_id := p_requested_line_rec.top_model_line_id(I);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SPLIT MODEL : '||l_SPLIT_LINE_rec.LINE_ID,3);
        END IF;

      ELSE

        l_split_line_rec.line_id := p_requested_line_rec.line_id(I);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SPLIT LINE : '||L_SPLIT_line_rec.LINE_ID,3);
        END IF;

      END IF;

      l_split_line_rec.line_set_id    := p_requested_line_rec.line_set_id(I);
      l_split_line_rec.ordered_quantity := p_requested_line_rec.shipped_quantity(I);
      l_split_line_rec.ordered_quantity2
      -- := nvl(p_requested_line_rec.requested_quantity2(I),0); --?? INVCONV
      := p_requested_line_rec.shipped_quantity2(I); -- INVCONV
      l_split_line_rec.ship_from_org_id    := p_requested_line_rec.ship_from_org_id(I); --9733938


      l_split_line_rec.operation         := OE_GLOBALS.G_OPR_UPDATE;
      l_split_line_rec.split_action_code := 'SPLIT';
      l_split_line_rec.split_by          := 'SYSTEM';
      l_split_line_rec.change_reason     := 'SYSTEM';

      l_split_line_tbl(1) := l_split_line_rec; --bug 4422886
      IF l_debug_level  > 0 THEN
           oe_debug_pub.add(1 ||' opr update qty '
                        || l_split_line_tbl(1).ordered_quantity, 1);
	   oe_debug_pub.add(1 ||' opr update qty2 '
                           || l_split_line_tbl(1).ordered_quantity2, 1);

      END IF;

      --Bug 7534520. Ord qty2 was incorrect because two minus signs
         --were used. Removed one of them.

      l_split_line_Rec := OE_ORDER_PUB.G_MISS_LINE_REC;

      l_split_line_rec.line_set_id    := p_requested_line_rec.line_set_id(I);
      l_split_line_rec.ordered_quantity
      := p_requested_line_rec.ordered_quantity(I)
         - p_requested_line_rec.shipped_quantity(I);
      l_split_line_rec.ordered_quantity2
      := nvl(p_requested_line_rec.ordered_quantity2(I),0) - p_requested_line_rec.shipped_quantity2(I); -- INVCONV
      l_split_line_rec.split_from_line_id := l_split_line_tbl(1).line_id;

      l_split_line_rec.split_by          := 'SYSTEM';
      l_split_line_rec.change_reason     := 'SYSTEM';
      l_split_line_rec.operation         := OE_GLOBALS.G_OPR_CREATE;

      -- J := J+1; bug 4422886

      l_split_line_tbl(2) := l_split_line_rec;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(2 ||' opr create qty '|| l_split_line_tbl(2).ordered_quantity
			   || 'split from  ' || l_split_line_tbl(2).split_from_line_id, 1);
	  oe_debug_pub.add(2 ||' opr create qty2 '|| l_split_line_tbl(2).ordered_quantity2
       	|| 'split from  ' || l_split_line_tbl(2).split_from_line_id, 1);
      END IF;
      l_control_rec.validate_entity   := FALSE;
      l_control_rec.check_security    := FALSE;


      OE_Shipping_Integration_Pvt.Call_Process_Order
      ( p_line_tbl         => l_split_line_tbl,
        p_process_requests => TRUE,
        p_control_rec      => l_control_rec,
        x_return_status    => l_return_status );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RET STS FROM PROCESS ORDER : '||L_RETURN_STATUS,3);
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('can not SPLIT LINE, ord qty < ship qty',3);
      END IF;
    END IF;
   END IF; --l_wdd_count condition
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Handle_Requested_Qty',3);
  END IF;

EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Handle_Requested_Qty: '||sqlerrm,3);
    END IF;
    RAISE;
END Handle_Requested_Qty;


/*------------------------------------------------------------
PROCEDURE Split_Line

 -- In OPM, User can order in a 3rd UOM that is not primary  -- INVCONV
 nor secondary but a convertable UOM.
 3rd conversion case, we need to perform
 an item specific conversion

 select order_quantity_uom2??
-------------------------------------------------------------*/
PROCEDURE Split_Line
( p_ship_line_rec          IN OUT NOCOPY Ship_Line_Rec_Type
-- ,p_opm_check              IN VARCHAR2 := 'Y' -- INVCONV - NOT NEEDed NOW
 ,p_index                  IN NUMBER
 ,p_split_model            IN VARCHAR2 := 'N')
IS
  l_line_tbl             OE_Order_Pub.Line_Tbl_Type;
  l_control_rec          OE_GLOBALS.Control_Rec_Type;
  l_return_status        VARCHAR2(1);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_return               NUMBER; --Bug 7528326
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering local split line', 3);
  END IF;

  l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
  l_line_tbl(2) := l_line_tbl(1);
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('local split line 1 ', 3);
  END IF;

  l_line_tbl(1).operation            := OE_GLOBALS.G_OPR_UPDATE;
  l_line_tbl(1).split_by             := 'SYSTEM';
  l_line_tbl(1).change_reason        := 'SYSTEM';
  l_line_tbl(1).split_action_code    := 'SPLIT';
  l_line_tbl(1).ordered_quantity     :=
              p_ship_line_rec.shipped_quantity(p_index);
  l_line_tbl(1).ship_from_org_id     :=
              p_ship_line_rec.ship_from_org_id(p_index); --9733938

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('local split line 2 ', 3);
  END IF;
  l_line_tbl(2).operation            := OE_GLOBALS.G_OPR_CREATE;
  l_line_tbl(2).split_by             := 'SYSTEM';
  l_line_tbl(2).change_reason        := 'SYSTEM';
  l_line_tbl(2).ordered_quantity     :=
              p_ship_line_rec.ordered_quantity(p_index) -
              p_ship_line_rec.shipped_quantity(p_index);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('local split line 3 ', 3);
  END IF;
  IF p_split_model = 'N' THEN

    l_line_tbl(1).line_id              := p_ship_line_rec.line_id(p_index);
    l_line_tbl(2).split_from_line_id   := l_line_tbl(1).line_id;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('local split line 4 ', 3);
  END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('split single line '|| p_ship_line_rec.line_id(p_index), 3);
      oe_debug_pub.add
      ('shp qty ' || p_ship_line_rec.shipped_quantity(p_index), 3);
      oe_debug_pub.add
      ('ord qty ' || p_ship_line_rec.ordered_quantity(p_index), 3);
    END IF;

  ELSE -- model split

    IF p_ship_line_rec.ato_line_id(p_index)
       = p_ship_line_rec.top_model_line_id(p_index) THEN

      l_line_tbl(1).line_id  := p_ship_line_rec.ato_line_id(p_index);
      l_line_tbl(2).split_from_line_id := l_line_tbl(1).line_id;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('split ato '|| p_ship_line_rec.ato_line_id(p_index), 3);
      END IF;

    ELSE

      l_line_tbl(1).line_id  := p_ship_line_rec.top_model_line_id(p_index);
      l_line_tbl(2).split_from_line_id := l_line_tbl(1).line_id;



      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('split pto '|| p_ship_line_rec.top_model_line_id(p_index), 3);
      END IF;
    END IF;

  END IF;
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('here 1 index is  '|| p_index, 3);
    END IF;

-- HW

 --  IF p_opm_check = 'Y' AND  -- INVCONV -- pete

    IF (   p_ship_line_rec.order_quantity_uom2(p_index) is NOT NULL
    and  p_ship_line_rec.order_quantity_uom2(p_index) <> FND_API.G_MISS_CHAR )
    THEN

    IF p_ship_line_rec.order_quantity_uom(p_index)
       <> p_ship_line_rec.order_quantity_uom2(p_index) THEN

    /*  l_line_tbl(1).ordered_quantity2

        := GMI_Reservation_Util.get_opm_converted_qty
           (p_apps_item_id    => p_ship_line_rec.inventory_item_id(p_index),
            p_organization_id => p_ship_line_rec.ship_from_org_id(p_index),
            p_apps_from_uom   => p_ship_line_rec.order_quantity_uom(p_index),
            p_apps_to_uom     => p_ship_line_rec.order_quantity_uom2(p_index),
            p_original_qty    => l_line_tbl(1).ordered_quantity);

      l_line_tbl(2).ordered_quantity2

        := GMI_Reservation_Util.get_opm_converted_qty
           (p_apps_item_id    => p_ship_line_rec.inventory_item_id(p_index),
            p_organization_id => p_ship_line_rec.ship_from_org_id(p_index),
            p_apps_from_uom   => p_ship_line_rec.order_quantity_uom(p_index),
            p_apps_to_uom     => p_ship_line_rec.order_quantity_uom2(p_index),
            p_original_qty    => l_line_tbl(2).ordered_quantity);   */

      --Begin Bug 7528326. Assign shipped_qty2 to ordered_qty2 instead of calculating from ordered_qty.

        /*
            l_line_tbl(1).ordered_quantity2  := INV_CONVERT.INV_UM_CONVERT(p_ship_line_rec.inventory_item_id(p_index)-- INVCONV
                                                      , NULL
						      ,p_ship_line_rec.ship_from_org_id(p_index)
	                                              ,5 --NULL
                                                      ,l_line_tbl(1).ordered_quantity
                                                      ,p_ship_line_rec.order_quantity_uom(p_index)
                                                      ,p_ship_line_rec.order_quantity_uom2(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );

           l_line_tbl(2).ordered_quantity2  := INV_CONVERT.INV_UM_CONVERT(p_ship_line_rec.inventory_item_id(p_index)-- INVCONV
						      , NULL
  						      ,p_ship_line_rec.ship_from_org_id(p_index)
                                                      ,5 --NULL
                                                      ,l_line_tbl(2).ordered_quantity
                                                      ,p_ship_line_rec.order_quantity_uom(p_index)
                                                      ,p_ship_line_rec.order_quantity_uom2(p_index)
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );
        */

       --Assign ship qty2 to order qty2 for original line
       IF p_ship_line_rec.shipping_quantity2(p_index) IS NOT NULL THEN
          l_line_tbl(1).ordered_quantity2 := p_ship_line_rec.shipping_quantity2(p_index);
       ELSE --use conversion
          l_line_tbl(1).ordered_quantity2 :=
             INV_CONVERT.INV_UM_CONVERT( p_ship_line_rec.inventory_item_id(p_index)-- INVCONV
                                        ,NULL
 					,p_ship_line_rec.ship_from_org_id(p_index)
				        ,5 --NULL
                                        ,l_line_tbl(1).ordered_quantity
                                        ,p_ship_line_rec.order_quantity_uom(p_index)
                                        ,p_ship_line_rec.order_quantity_uom2(p_index)
                                        ,NULL -- From uom name
                                        ,NULL -- To uom name
                                       );
       END IF;

       --Assign difference between original line order qty2 and original line ship qty2 to
       --split line order qty2, only if the difference is grater than or equal to zero.
       IF (p_ship_line_rec.shipping_quantity2(p_index) IS NOT NULL AND
           p_ship_line_rec.ordered_quantity2(p_index) - p_ship_line_rec.shipping_quantity2(p_index) >= 0) THEN
           l_line_tbl(2).ordered_quantity2 := p_ship_line_rec.ordered_quantity2(p_index) -
                                              p_ship_line_rec.shipping_quantity2(p_index);
           --Check if order qty1 and order qty2 of split line are within deviation, only for positive qty.
           IF l_line_tbl(2).ordered_quantity2 > 0 THEN
              l_return := INV_CONVERT.Within_Deviation  -- INVCONV
                          ( p_organization_id   => p_ship_line_rec.ship_from_org_id(p_index)
                          , p_inventory_item_id => p_ship_line_rec.inventory_item_id(p_index)
                          , p_lot_number        => NULL --  p_lot_number -- INVCONV
                          , p_precision         => 5
                          , p_quantity          => l_line_tbl(2).ordered_quantity
                          , p_uom_code1         => p_ship_line_rec.order_quantity_uom(p_index)
                          , p_quantity2         => l_line_tbl(2).ordered_quantity2
                          , p_uom_code2         => p_ship_line_rec.order_quantity_uom2(p_index)
                          );

                IF l_return = 0 THEN --Not within deviation, hence use conversion
                   l_line_tbl(2).ordered_quantity2 :=
                   INV_CONVERT.INV_UM_CONVERT( p_ship_line_rec.inventory_item_id(p_index)-- INVCONV
                                              ,NULL
					      ,p_ship_line_rec.ship_from_org_id(p_index)
                                              ,5 --NULL
                                              ,l_line_tbl(2).ordered_quantity
                                              ,p_ship_line_rec.order_quantity_uom(p_index)
                                              ,p_ship_line_rec.order_quantity_uom2(p_index)
                                              ,NULL -- From uom name
                                              ,NULL -- To uom name
                                             );
                END IF;
           END IF;
       ELSE  --use conversion
          l_line_tbl(2).ordered_quantity2 :=
             INV_CONVERT.INV_UM_CONVERT( p_ship_line_rec.inventory_item_id(p_index)-- INVCONV
                                        ,NULL
					,p_ship_line_rec.ship_from_org_id(p_index)
                                        ,5 --NULL
                                        ,l_line_tbl(2).ordered_quantity
                                        ,p_ship_line_rec.order_quantity_uom(p_index)
                                        ,p_ship_line_rec.order_quantity_uom2(p_index)
                                        ,NULL -- From uom name
                                        ,NULL -- To uom name
                                       );
       END IF;
      --End Bug 7528326.


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('DUAL 3RD CONVERSION  1 '||l_line_tbl(1).ORDERED_QUANTITY2,1);
      END IF;

    ELSE -- order uom = order uom 2

      -- fix for 8479324  start below
      -- re write fix below for BUG 9395809  - INTERFACE TRIP STOP COMPLETES WITH ERROR MSG: A QUANTITY IS REQUIRED ON THE LINE
      -- to use shipping_quantity2 as in this flow p_ship_line_rec.shipped_quantity2(p_index) will always come as NULL, as Shipping never passes
      -- p_ship_line_rec.shipped_quantity2.

     /*-- fix for 8681362 fp of 8479324  start below
      l_line_tbl(1).ordered_quantity2   := p_ship_line_rec.shipped_quantity2(p_index);
      l_line_tbl(1).ordered_quantity    := l_line_tbl(1).ordered_quantity2;
      l_line_tbl(2).ordered_quantity2 :=  p_ship_line_rec.ordered_quantity2(p_index) -
      p_ship_line_rec.shipped_quantity2(p_index);
      l_line_tbl(2).ordered_quantity := l_line_tbl(2).ordered_quantity2;
      -- fix for 8681362   fp of  8479324  end   */

		 l_line_tbl(1).ordered_quantity2 := p_ship_line_rec.shipping_quantity2(p_index);
		 l_line_tbl(1).ordered_quantity := l_line_tbl(1).ordered_quantity2;

		 l_line_tbl(2).ordered_quantity2 := p_ship_line_rec.ordered_quantity2(p_index) -
		 p_ship_line_rec.shipping_quantity2(p_index);

		 l_line_tbl(2).ordered_quantity := l_line_tbl(2).ordered_quantity2;

    -- end BUG 9395809










    END IF;

  ELSE

    l_line_tbl(1).ordered_quantity2    := NULL;
    l_line_tbl(2).ordered_quantity2    := NULL;
  END IF;



  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('SPLIT FROM : '||L_LINE_TBL(2).SPLIT_FROM_LINE_ID,3);
    oe_debug_pub.add('ORD qty old  : '||L_LINE_TBL(1).ORDERED_QUANTITY,3);
    oe_debug_pub.add('ORD QTY2 old : '||L_LINE_TBL(1).ORDERED_QUANTITY2,3);
    oe_debug_pub.add('ORD QTY NEW  : '||L_LINE_TBL(2).ORDERED_QUANTITY,3);
    oe_debug_pub.add('ORD QTY2 NEW : '||L_LINE_TBL(2).ORDERED_QUANTITY2,3);
  END IF;


  l_control_rec.validate_entity    := FALSE;
  l_control_rec.check_security     := FALSE;

  OE_Shipping_Integration_Pvt.Call_Process_Order
  ( p_line_tbl         => l_line_tbl,
    p_control_rec      => l_control_rec,
    p_process_requests => TRUE,
    x_return_status    => l_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('local split line RET STS : '||L_RETURN_STATUS,3);
  END IF;

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('here 12 index is  '|| p_index, 3);
      oe_debug_pub.add('error in split_line '||sqlerrm,3);
    END IF;
    RAISE;
END Split_Line;


/*------------------------------------------------------------
PROCEDURE Fulfill_Remnant_PTO
-------------------------------------------------------------*/
PROCEDURE Fulfill_Remnant_PTO
(p_top_model_line_id    IN   NUMBER)
IS
  l_line_tbl                OE_ORDER_PUB.Line_Tbl_Type;
  l_x_result_out            VARCHAR2(30);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_result_code             VARCHAR2(30);
  l_activity_status         VARCHAR2(8);
  l_activity_result         VARCHAR2(30);
  l_activity_id             NUMBER;
  l_fulfillment_activity    VARCHAR2(30);
  l_fulfill_tbl             OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_index           NUMBER := 0 ;
  l_fulfillment_set_flag    VARCHAR2(1); -- for bug 4176692

  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR fulfill_remnant_lines IS
    SELECT line_id, ordered_quantity
	  ,header_id, actual_shipment_date, order_firmed_date
          ,blanket_number,blanket_line_number,blanket_version_number
    FROM   oe_order_lines
    WHERE  top_model_line_id = p_top_model_line_id
    AND    nvl(ato_line_id,-99) = -99 /*added for bug 6640292*/
    AND    shippable_flag = 'N'
    AND    model_remnant_flag = 'Y';
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering fulfill_remnant_pto'||p_top_model_line_id, 3);
  END IF;
  -- for bug 4176692
  l_fulfillment_set_flag :=
       OE_Line_Fullfill.Is_Part_Of_Fulfillment_Set(p_top_model_line_id);

  FOR line_rec in fulfill_remnant_lines
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING GET ACTIVITY RESULT FOR : '|| line_rec.line_id, 3);
    END IF;

    OE_LINE_FULLFILL.Get_Activity_Result
    (p_item_type             => OE_GLOBALS.G_WFI_LIN
    ,p_item_key              => to_char(line_rec.line_id)
    ,p_activity_name         => 'FULFILL_LINE'
    ,x_return_status         => l_return_status
    ,x_activity_result       => l_activity_result
    ,x_activity_status_code  => l_activity_status
    ,x_activity_id           => l_activity_id );

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('RET STS FROM GET ACT RESULT: '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LINE IS NOT AT FULFILLMENT ACTIVITY ',3);
      END IF;
    ELSE
      IF l_activity_status = 'NOTIFIED' THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE IS AT FULFILLMENT ACTIVITY ',3);
        END IF;

        OE_LINE_FULLFILL.Get_Fulfillment_Activity
        (p_item_key             => line_rec.line_id,
         p_activity_id          => l_activity_id,
         x_fulfillment_activity => l_fulfillment_activity,
         x_return_status        => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'FULFILLMENT ACT : '||L_FULFILLMENT_ACTIVITY , 3 ) ;
        END IF;

        IF (l_fulfillment_activity = 'NO_ACTIVITY' OR
           l_fulfillment_activity = 'SHIP_LINE') AND
           l_fulfillment_set_flag = FND_API.G_FALSE THEN -- bug 4176692

          l_fulfill_index                := l_fulfill_index + 1;
          l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
          l_fulfill_tbl(l_fulfill_index).line_id := line_rec.line_id;
          l_fulfill_tbl(l_fulfill_index).fulfilled_flag   := 'Y';
          l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
          l_fulfill_tbl(l_fulfill_index).fulfilled_quantity
                      := line_rec.ordered_quantity;
          l_fulfill_tbl(l_fulfill_index).header_id := line_rec.header_id;
          l_fulfill_tbl(l_fulfill_index).actual_shipment_date
                      := line_rec.actual_shipment_date;
          l_fulfill_tbl(l_fulfill_index).order_firmed_date
                      := line_rec.order_firmed_date;
          --BSA changes.
          l_fulfill_tbl(l_fulfill_index).blanket_number
                      := line_rec.blanket_number;
          l_fulfill_tbl(l_fulfill_index).blanket_line_number
                      := line_rec.blanket_line_number;
          l_fulfill_tbl(l_fulfill_index).blanket_version_number
                      := line_rec.blanket_version_number;
          --BSA changes

          l_fulfill_tbl(l_fulfill_index).operation := OE_GLOBALS.G_OPR_UPDATE;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('FULFILLED QUANTITY : '
            || L_FULFILL_TBL(L_FULFILL_INDEX).FULFILLED_QUANTITY,3);
          END IF;

        END IF; -- no activity
      END IF; -- line at fulfillment
    END IF; -- return status is error
  END LOOP; -- split line tbl has rows


  IF l_fulfill_index <> 0 THEN
    OE_Line_Fullfill.Fulfill_Line
    (p_line_tbl             =>  l_fulfill_tbl,
     p_mode                 =>  'TABLE',
     p_fulfillment_type     =>  'No Activity',
     p_fulfillment_activity => 'NO_ACTIVITY',
     x_return_status        =>  l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR  l_fulfill_index IN 1 .. l_fulfill_tbl.count
    LOOP
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
      END IF;

      OE_Order_WF_Util.Update_Flow_Status_Code
      (p_header_id        =>  l_fulfill_tbl(l_fulfill_index).header_id,
       p_line_id          =>  l_fulfill_tbl(l_fulfill_index).line_id,
       p_flow_status_code =>  'FULFILLED',
       x_return_status    =>  l_return_status);

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('RET STS FROM FLOW STATUS API '||L_RETURN_STATUS,3);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      OE_Delayed_Requests_Pvt.Log_Request
      ( p_entity_code   => OE_GLOBALS.G_ENTITY_ALL,
        p_entity_id     => l_fulfill_tbl(l_fulfill_index).line_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => l_fulfill_tbl(l_fulfill_index).line_id,
        p_request_type  => OE_GLOBALS.G_COMPLETE_ACTIVITY,
        p_param1        => OE_GLOBALS.G_WFI_LIN,
        p_param2        => to_char(l_fulfill_tbl(l_fulfill_index).line_id),--??
        p_param3        => 'FULFILL_LINE',
        p_param4        => OE_GLOBALS.G_WFR_COMPLETE,
        x_return_status => l_return_status);

      OE_LINE_FULLFILL.Fulfill_Service_Lines
      (p_line_id       => l_fulfill_tbl(l_fulfill_index).line_id,
       p_header_id     => l_fulfill_tbl(l_fulfill_index).header_id,
       x_return_status => l_return_status);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RET STS FULFILL SERVICE '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP; -- fulfill table has rows.

  END IF; -- fullfill index <> 0

  IF l_debug_level  > 0 THEN
    OE_DEBUG_PUB.Add('Exiting fulfill_remnant_pto', 3);
  END IF;
EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Fulfill_Remnant_PTO '||sqlerrm,3);
    END IF;
    RAISE;
END Fulfill_Remnant_PTO;

/*------------------------------------------------------------
PROCEDURE Ship_Confirm_Line

-- price line for atos??
--shipping_quantity_uom2?? in update

Change Record

-------------------------------------------------------------*/
PROCEDURE Ship_Confirm_Line
( p_ship_line_rec   IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_check_line_set  IN VARCHAR2 := 'Y'
 ,p_index           IN NUMBER
 ,p_model_call      IN VARCHAR2 := 'N'
 ,p_ato_only        IN VARCHAR2 := 'N')
IS
  l_return_status     VARCHAR2(1);
  l_wdd_count            NUMBER;
  l_debug_level       CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  -- bug4460242
  l_activity_status  VARCHAR2(8);
  l_activity_result  VARCHAR2(30);
  l_activity_id      NUMBER;

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Ship_Confirm_Line '||p_ato_only
                     ||'line_id: ' || p_ship_line_rec.line_id(p_index),3);
    oe_debug_pub.add('ord qty '||p_ship_line_rec.ordered_quantity(p_index),3);
    oe_debug_pub.add('shp qty '||p_ship_line_rec.shipped_quantity(p_index),3);
  END IF;

  IF p_ato_only = 'Y' THEN

    UPDATE oe_order_lines
    SET    shipped_quantity = (ordered_quantity *
                               p_ship_line_rec.shipped_quantity(p_index)/
                               p_ship_line_rec.ordered_quantity(p_index))
           ,actual_shipment_date
            = p_ship_line_rec.actual_shipment_date(p_index)
           ,lock_control     = lock_control + 1
           --last_updated_by**
    WHERE  ato_line_id = p_ship_line_rec.ato_line_id(p_index)
    AND    header_id   = p_ship_line_rec.header_id(p_index)
    AND    shippable_flag = 'N';

  END IF;


  IF p_ship_line_rec.ato_line_id(p_index) IS NOT NULL AND
     p_ship_line_rec.item_type_code(p_index) = 'CONFIG' THEN

    -- bug fix 4460242
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET ACTIVITY RESULT : '|| p_ship_line_rec.ato_line_id(p_index) , 3 ) ;
    END IF;
    OE_LINE_FULLFILL.Get_Activity_Result
    (  p_item_type            => OE_GLOBALS.G_WFI_LIN
    ,  p_item_key             => p_ship_line_rec.ato_line_id(p_index)
    ,  p_activity_name        => 'WAIT_FOR_CTO'
    ,  x_return_status        => l_return_status
    ,  x_activity_result      => l_activity_result
    ,  x_activity_status_code => l_activity_status
    ,  x_activity_id          => l_activity_id );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'STATUS GET ACTIVITY RESULT : '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE IS NOT AT WAIT_FOR_CTO ACTIVITY' , 1 ) ;
      END IF;
    ELSE
      IF l_activity_status = 'NOTIFIED' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS AT WAIT_FOR_CTO ACTIVITY' , 1 ) ;
            oe_debug_pub.add(  'COMPLETE ACTIVITY , FOR '|| p_ship_line_rec.ato_line_id(p_index) , 3 ) ;
        END IF;

        OE_DEBUG_PUB.Add('Log delayed request for Complete CTO-Bug-3471040');

        OE_Delayed_Requests_Pvt.Log_Request
        ( p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
          p_entity_id              => p_ship_line_rec.ato_line_id(p_index),
          p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
          p_requesting_entity_id   => p_ship_line_rec.ato_line_id(p_index),
          p_request_type           => OE_GLOBALS.G_COMPLETE_ACTIVITY,
          p_param1                 => OE_GLOBALS.G_WFI_LIN,
          p_param2                 => p_ship_line_rec.ato_line_id(p_index),
          p_param3                 => 'WAIT_FOR_CTO',
          p_param4                 => OE_GLOBALS.G_WFR_COMPLETE,
          x_return_status          => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('ato parent workflow progressed '
                       || p_ship_line_rec.ato_line_id(p_index), 5);
         END IF;
      END IF;-- end of IF l_activity_status = 'NOTIFIED'
    END IF; -- end of IF l_return_status =SUCCESS OR NOT
  END IF;
  -- end of bug 4460242


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('fulfilled? ' ||p_ship_line_rec.fulfilled_flag(p_index)
                     || ' model? '||p_model_call, 1);
  END IF;

  IF p_model_call = 'N' THEN

    IF p_ship_line_rec.fulfilled_flag(p_index) = 'Y' THEN

      IF p_check_line_set = 'Y' AND
         p_ship_line_rec.item_type_code(p_index) = 'STANDARD' THEN

         Ship_Confirm_Split_Lines
             (p_ship_line_rec    => p_ship_line_rec
             ,p_index            => p_index);

      END IF;

    ELSE

      IF p_ship_line_rec.shipped_quantity(p_index)
         < p_ship_line_rec.ordered_quantity(p_index) THEN

         IF nvl(p_ship_line_rec.ship_tolerance_above(p_index),0) = 0 AND
            nvl(p_ship_line_rec.ship_tolerance_below(p_index),0) = 0 AND
            p_ship_line_rec.item_type_code(p_index) = 'STANDARD' AND
            (floor(p_ship_line_rec.ordered_quantity(p_index))
                 <> p_ship_line_rec.ordered_quantity(p_index) OR
             floor(p_ship_line_rec.shipped_quantity(p_index))
                 <> p_ship_line_rec.shipped_quantity(p_index)) THEN
           IF NVL(p_ship_line_rec.source_type_code(p_index),'INTERNAL') = 'INTERNAL' THEN -- Added for bug 6877315
            -- 3590689
            BEGIN
               -- getting delivery details
               SELECT count(*)
               INTO   l_wdd_count
               FROM   wsh_delivery_details
               WHERE  source_line_id = p_ship_line_rec.line_id(p_index)
               AND    released_status <> 'D'
               AND    source_code = 'OE'
               AND    oe_interfaced_flag = 'N';
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('WSH Count : ' || l_wdd_count, 1);
            END IF;
           END IF; -- For bug 7243039 (Added for bug 6877315)
         ELSE
           l_wdd_count := 1;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('setting the count 1, split' , 1);
           END IF;
         END IF;

          -- END IF; -- Added for bug 6877315 : Commented for bug 7243039

         IF l_wdd_count > 0
         OR NVL(p_ship_line_rec.source_type_code(p_index),'INTERNAL') = 'EXTERNAL' THEN -- Modified for bug 6877315
           Split_Line
           ( p_ship_line_rec   => p_ship_line_rec
            ,p_index           => p_index
            ,p_split_model     => p_ato_only);

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('after split line for standard item', 5);
           END IF;
         END IF; -- Item_type_code

      END IF;

    END IF;
  END IF;

  BEGIN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('loggin request to wf complete', 5);
      oe_debug_pub.add('Activity to be performed' || G_SKIP_SHIP, 5); -- Bug 10032407
    END IF;

    OE_Delayed_Requests_Pvt.Log_Request
    ( p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
      p_entity_id              => p_ship_line_rec.line_id(p_index),
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_ship_line_rec.line_id(p_index),
      p_request_type           => G_SKIP_SHIP, -- Bug 10032407
      p_param1                 => OE_GLOBALS.G_WFI_LIN,
      p_param2                 => p_ship_line_rec.line_id(p_index),
      p_param3                 => 'SHIP_LINE',
      p_param4                 => 'SHIP_CONFIRM',
      x_return_status          => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('after wf completion delayed request', 3);
    END IF;

  EXCEPTION
    WHEN others THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.ADD('wf CompleteActivity error ' || sqlerrm,3);
      END IF;
      RAISE;
  END;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('calling Update_Flow_Status_Code', 3);
  END IF;

  OE_Order_WF_Util.Update_Flow_Status_Code
  (p_header_id          =>  p_ship_line_rec.header_id(p_index),
   p_line_id            =>  p_ship_line_rec.line_id(p_index),
   p_flow_status_code   =>  'SHIPPED',
   x_return_status      =>  l_return_status );


  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Ship_Confirm_Line', 3);
  END IF;
EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Ship_Confirm_Line ' || sqlerrm, 3);
    END IF;

    RAISE;
END Ship_Confirm_Line;


/*------------------------------------------------------------
PROCEDURE Ship_Confirm_PTO
Bug 3359702 : Check for line in p_ship_line_rec if it is not there
              append it.
-------------------------------------------------------------*/
PROCEDURE Ship_Confirm_PTO
( p_top_model_line_id  IN NUMBER
 ,p_index              IN NUMBER
 ,p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type)
IS
  l_count                NUMBER;
  l_count1               NUMBER;
  l_proportional_ship    VARCHAR2(1) := 'Y';
  l_split_line_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_return_status        VARCHAR2(1) := 'Y';
  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_index                NUMBER;
  l_model_remnant_flag   VARCHAR2(1) := 'N';
  l_make_remnant         VARCHAR2(1) := 'N'; -- bug 4701487
  l_line_found           NUMBER := 0;
-- bug4466040
  l_shipped_ratio         NUMBER;
  l_model_ordered_qty     NUMBER;
  l_new_model_shipped_qty NUMBER;
  l_line_model_shipped_qty NUMBER;   --added for bug 8774783
  l_line_model_ordered_qty NUMBER;   --added for bug 8774783

  CURSOR shipped_lines IS
    SELECT line_id, ordered_quantity, shipped_quantity
    FROM   oe_order_lines
    WHERE  shippable_flag = 'Y'
    AND    shipped_quantity is NOT NULL
    AND    top_model_line_id = p_top_model_line_id;
BEGIN

  SELECT count(*)
  INTO   l_count1
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id
  AND    cancelled_flag = 'N'
  AND    shippable_flag = 'Y';

  -- updating remnant flag for various conditions.
  --Commented IF condition to handle SMC Case  Bug Fix 5008069
 -- IF nvl(p_ship_line_rec.smc_flag(p_index), 'N') = 'N' THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LINE PART OF NON SMC PTO '|| l_count1, 4);
    END IF;

    -- if ato+pto with external lines, make it remnant.
    IF l_count1 > 1 THEN
      SELECT count(*)
      INTO   l_count
      FROM   oe_order_lines
      WHERE  top_model_line_id = p_top_model_line_id
      AND    cancelled_flag = 'N'
      AND    source_type_code = 'EXTERNAL';

      IF l_count > 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXTERNAL LINES EXIST' , 2 ) ;
        END IF;
        l_make_remnant := 'Y'; -- bug 4701487
      END IF;
    END IF; -- if more than 1 shippable lines.

    -- if non smc model with ato and config line not created
    -- make it remanant.
    IF l_make_remnant <> 'Y' THEN

      l_count := 0;

      /* MOAC_SQL_CHANGE */
      SELECT count(*)
      INTO   l_count
      FROM   oe_order_lines oe1
      WHERE  top_model_line_id = p_top_model_line_id
      AND    ato_line_id = line_id
      AND    item_type_code = 'CLASS'
      AND    cancelled_flag = 'N'
      AND    not exists
             (SELECT NULL
              FROM   oe_order_lines_all
              WHERE  top_model_line_id = p_top_model_line_id
              AND    ato_line_id = oe1.line_id
              AND    cancelled_flag = 'N'
             AND    item_type_code = 'CONFIG');

      IF l_count > 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ATO model line does not have CONFIG created', 2 ) ;
        END IF;
        l_make_remnant := 'Y';  -- bug 4701487
      END IF;
    END IF;

    IF l_make_remnant <> 'Y'  THEN -- bug 4701487
      l_count := 0;
      BEGIN
      SELECT 1 INTO   l_count
      FROM DUAL
      WHERE EXISTS (
                   SELECT NULL
                   FROM   oe_order_lines
                   WHERE  top_model_line_id = p_top_model_line_id
                   AND    cancelled_flag = 'N'
                   AND    schedule_ship_date  is NULL);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF l_count > 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Atleast one un-scheduled line exists in the Model...' , 2 ) ;
        END IF;
        l_make_remnant := 'Y';
      END IF;
    END IF;  -- bug 4701487

    IF l_make_remnant = 'Y' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Making the model REMNANT:'|| p_TOP_MODEL_LINE_ID , 2) ;
      END IF;

      UPDATE oe_order_lines
      SET    model_remnant_flag = 'Y'
            ,lock_control       = lock_control + 1
      WHERE  top_model_line_id = p_top_model_line_id
      AND    cancelled_flag = 'N';

      l_model_remnant_flag := 'Y';
    END IF;

 -- END IF; -- if part of a non smc model.

  -------------------- remnant upadate done ---------------------

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Ship_Confirm_PTO, model line_id: '
                      || p_top_model_line_id, 3);
  END IF;

  IF l_model_remnant_flag = 'N' THEN

    SELECT count(*)
    INTO   l_count
    FROM   oe_order_lines
    WHERE  top_model_line_id = p_top_model_line_id
    AND    shippable_flag = 'Y'
    AND    NVL(CANCELLED_FLAG,'N')='N' --9822866
    AND    shipped_quantity is NULL;

    IF l_count > 0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1 select '|| l_count , 3);
      END IF;
      l_proportional_ship := 'N';
    ELSE
      BEGIN

        /* MOAC_SQL_CHANGE */
        SELECT count(*)
        INTO   l_count
        FROM   oe_order_lines oe1
        WHERE  top_model_line_id = p_top_model_line_id
        AND    shippable_flag = 'Y'
        AND    NVL(OE1.CANCELLED_FLAG,'N')='N' --9822866
        AND    ordered_quantity/shipped_quantity = ALL
                    (SELECT ordered_quantity/shipped_quantity
                     FROM   oe_order_lines_all oe2
                     WHERE  oe2.top_model_line_id = oe1.top_model_line_id
                     AND    oe2.line_id <> oe1.line_id
                     AND    oe2.shippable_flag = 'Y'
                     AND    NVL(OE2.CANCELLED_FLAG,'N')='N' --9822866
                    );

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('2 select '|| l_count || l_count1 , 3);
        END IF;

        IF l_count1 = l_count THEN
           /* bug fix 4466040 */
          -- getting shipped ratio for shippable lines

          --begin changes for bug 8774783
    /*  -- commented for bug 8774783

          SELECT shipped_quantity/ordered_quantity
          INTO l_shipped_ratio
          FROM oe_order_lines_all
          WHERE  top_model_line_id = p_top_model_line_id
          AND  shippable_flag = 'Y'
          AND ROWNUM =1;

          SELECT ordered_quantity
          into l_model_ordered_qty
          FROM  oe_order_lines_all
          WHERE  line_id = p_top_model_line_id;

          l_new_model_shipped_qty :=(l_model_ordered_qty *l_shipped_ratio);
    */ --end comment for bug 8774783
          SELECT shipped_quantity,ordered_quantity
          INTO l_line_model_shipped_qty,l_line_model_ordered_qty
          FROM oe_order_lines_all
          WHERE  top_model_line_id = p_top_model_line_id
          AND  shippable_flag = 'Y'
          AND ROWNUM =1;

          SELECT ordered_quantity
          into l_model_ordered_qty
          FROM  oe_order_lines_all
          WHERE  line_id = p_top_model_line_id;

          l_new_model_shipped_qty :=(l_model_ordered_qty *l_line_model_shipped_qty/l_line_model_ordered_qty);

          --end changes for bug 8774783

          IF ((l_new_model_shipped_qty -TRUNC(l_new_model_shipped_qty,0))=0) THEN
            l_proportional_ship := 'Y';
          ELSE
            -- top_model_line can't be decimal qty
            l_proportional_ship := 'N';
          END IF;
          -- end of bug 4466040
        ELSE
          l_proportional_ship := 'N';
        END IF;
      EXCEPTION
        WHEN others THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('others '|| sqlerrm, 3);
          END IF;
          RAISE;
      END;
    END IF;

  ELSE
    l_proportional_ship := 'N';
  END IF; -- if proportional shipment


  l_count  := 0;
  l_count1 := 0;

  --------------- handle proportional shipment --------------------

  IF l_proportional_ship = 'Y' THEN

    UPDATE oe_order_lines
    SET    shipped_quantity = (ordered_quantity *
                               p_ship_line_rec.shipped_quantity(p_index)/
                               p_ship_line_rec.ordered_quantity(p_index))
           ,actual_shipment_date =
            p_ship_line_rec.actual_shipment_date(p_index)
           ,lock_control         = lock_control + 1
           --last_updated_by**
    WHERE  top_model_line_id = p_top_model_line_id
    AND    open_flag = 'Y'
    AND    nvl(cancelled_flag, 'N') = 'N'
    AND    source_type_code = 'INTERNAL'
    AND    shippable_flag = 'N';

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('nonshippable lines updated '|| sql%rowcount, 3);
      END IF;

    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('append model line ' || p_ship_line_rec.line_id.LAST, 3);
    END IF;

    l_index := p_ship_line_rec.line_id.LAST + 1;
    p_ship_line_rec.line_id.extend;
    p_ship_line_rec.shipped_quantity.extend;
    p_ship_line_rec.ordered_quantity.extend;
    p_ship_line_rec.order_quantity_uom2.extend; -- INVCONV 4199186
    p_ship_line_rec.ato_line_id.extend;
    p_ship_line_rec.top_model_line_id.extend;
    p_ship_line_rec.item_type_code.extend;
    p_ship_line_rec.ship_from_org_id.extend; -- Bug 10338240

    SELECT line_id, shipped_quantity, ordered_quantity, ordered_quantity_uom2, -- INVCONV 4199186
           ato_line_id,top_model_line_id, item_type_code, ship_from_org_id -- Bug 10338240
    INTO   p_ship_line_rec.line_id(l_index),
           p_ship_line_rec.shipped_quantity(l_index),
           p_ship_line_rec.ordered_quantity(l_index),
           p_ship_line_rec.order_quantity_uom2(l_index),  -- INVCONV 4199186
           p_ship_line_rec.ato_line_id(l_index),
           p_ship_line_rec.top_model_line_id(l_index),
           p_ship_line_rec.item_type_code(l_index),
	   p_ship_line_rec.ship_from_org_id(l_index) -- Bug 10338240
    FROM   oe_order_lines
    WHERE  line_id = p_top_model_line_id;


    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('p_index of this line '|| p_index, 3);
      oe_debug_pub.add
      ('shp qty: '|| p_ship_line_rec.shipped_quantity(p_index)
        || 'ord qty :'||p_ship_line_rec.ordered_quantity(p_index), 3);
      oe_debug_pub.add('model line added to l_index '|| l_index, 3);
      oe_debug_pub.add('model shp and ord qtys: '
       || p_ship_line_rec.shipped_quantity(l_index) || ' '
       || p_ship_line_rec.ordered_quantity(l_index), 3);
    END IF;

    IF p_ship_line_rec.shipped_quantity(l_index)
       < p_ship_line_rec.ordered_quantity(l_index) THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('calling split line from ship_confirm_pto', 3);
      END IF;

      Split_Line
      ( p_ship_line_rec   => p_ship_line_rec
     --   ,p_opm_check       => 'N' -- INVCONV no longer needed
       ,p_index           => l_index
       ,p_split_model     => 'Y');
    END IF;

    -- delete the appended model line

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('removing model line', 3);
    END IF;

    p_ship_line_rec.line_id.trim;
    p_ship_line_rec.shipped_quantity.trim;
    p_ship_line_rec.ordered_quantity.trim;
    p_ship_line_rec.ato_line_id.trim;
    p_ship_line_rec.top_model_line_id.trim;
    p_ship_line_rec.item_type_code.trim;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('done removing model line ' || p_ship_line_rec.line_id.first || '-'||p_ship_line_rec.line_id.last, 3);
    END IF;

    FOR I in p_ship_line_rec.line_id.first..p_ship_line_rec.line_id.last
    LOOP

      IF p_ship_line_rec.top_model_line_id(I) = p_top_model_line_id AND
	 p_ship_line_rec.shippable_flag(i) = 'Y'
      -- 4396294
      THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(I || ' calling Ship_Confirm_line for line_id '
                           ||p_ship_line_rec.line_id(I) , 3);
        END IF;

        Ship_Confirm_Line
        (p_ship_line_rec    => p_ship_line_rec
        ,p_check_line_set   => 'N'
        ,p_model_call       => 'Y'
        ,p_index            => I);

      END IF;

    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('1 leaving Ship_Confirm_PTO ', 3);
    END IF;

    RETURN;
  END IF;

  ----------------------- handle non proportional -------------

  IF l_model_remnant_flag = 'N' THEN
    -- send only shippable lines, else all

    l_count := 0;

    FOR I in p_ship_line_rec.line_id.first..p_ship_line_rec.line_id.last
    LOOP

      IF p_ship_line_rec.top_model_line_id(I) = p_top_model_line_id THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('line_id '|| p_ship_line_rec.line_id(I), 1);
        END IF;

        l_count := l_count + 1;

        l_split_line_tbl(l_count).line_id := p_ship_line_rec.line_id(I);
        IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('quring row ', 1);
        END IF;

        OE_Line_Util.Query_Row
        ( p_line_id  => p_ship_line_rec.line_id(I)
         ,x_line_rec => l_split_line_tbl(l_count));
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('zz2', 1);
        END IF;

        l_split_line_tbl(l_count).operation := OE_GLOBALS.G_OPR_UPDATE;

        l_split_line_tbl(l_count).split_by  := 'SYSTEM';
        l_split_line_tbl(l_count).change_reason := 'SYSTEM';
        l_split_line_tbl(l_count).split_action_code := 'SPLIT';
        l_split_line_tbl(l_count).shipped_quantity
                 := p_ship_line_rec.shipped_quantity(I);
        l_split_line_tbl(l_count).ordered_quantity
                 := p_ship_line_rec.ordered_quantity(I) -
                    p_ship_line_rec.shipped_quantity(I);
        l_split_line_tbl(l_count).item_type_code
                 := p_ship_line_rec.item_type_code(I);
        l_split_line_tbl(l_count).top_model_line_id
                 := p_ship_line_rec.top_model_line_id(I);
      END IF;

    END LOOP;

    IF l_count > 0 THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('calling Cascade_Non_Proportional_Split', 3);
      END IF;

      OE_Split_Util.Cascade_Non_Proportional_Split
      (p_x_line_tbl    => l_split_line_tbl,
       x_return_status => l_return_status);
    END IF;

    l_index  := p_ship_line_rec.line_id.LAST;
    l_count1 := 0;

    FOR I in l_split_line_tbl.FIRST..l_split_line_tbl.LAST
    LOOP
      IF l_split_line_tbl(I).shippable_flag = 'Y' AND
         l_split_line_tbl(I).shipped_quantity > 0 AND
         l_split_line_tbl(I).split_from_line_id is NOT NULL
      THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('append line ' || l_split_line_tbl(I).line_id, 3);
        END IF;
        l_line_found := 0;

        FOR J in p_ship_line_rec.line_id.FIRST..p_ship_line_rec.line_id.LAST
        LOOP
            IF p_ship_line_rec.line_id(J) =  l_split_line_tbl(I).line_id THEN
               IF l_debug_level  > 0 THEN
                 OE_DEBUG_PUB.Add('Line Exists already in Ship Rec'||
                                                  l_split_line_tbl(I).line_id,3);
               END IF;
               l_line_found := 1;
               EXIT;
            END IF;
        END LOOP;

        -- Append the line only if the line is not found in the
        -- Ship line Record.

        IF l_line_found = 0 THEN

          l_index  := l_index + 1;
          l_count1 := l_count1 + 1;

          p_ship_line_rec.line_id.extend;
          p_ship_line_rec.shipped_quantity.extend;
          p_ship_line_rec.ordered_quantity.extend;
          p_ship_line_rec.top_model_line_id.extend;
          p_ship_line_rec.fulfilled_flag.extend;
          p_ship_line_rec.header_id.extend;
          p_ship_line_rec.ato_line_id.extend;
          p_ship_line_rec.item_type_code.extend;

          SELECT line_id, shipped_quantity, ordered_quantity,
                 header_id,ato_line_id,item_type_code
          INTO   p_ship_line_rec.line_id(l_index),
                 p_ship_line_rec.shipped_quantity(l_index),
                 p_ship_line_rec.ordered_quantity(l_index),
                 p_ship_line_rec.header_id(l_index),
                 p_ship_line_rec.ato_line_id(l_index),
                 p_ship_line_rec.item_type_code(l_index)
          FROM   oe_order_lines
          WHERE  line_id = l_split_line_tbl(I).line_id;

          p_ship_line_rec.top_model_line_id(l_index) := p_top_model_line_id;
          -- the top model line id is actually diff, this is to make
          -- sure that ship_confirm_line gets called.

          p_ship_line_rec.fulfilled_flag(p_index) := 'Y';

       END IF;
      END IF;
    END LOOP;

  END IF; -- we did not make it remnant

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('last: '|| p_ship_line_rec.line_id.last, 5);
  END IF;

  FOR I in p_ship_line_rec.line_id.first..p_ship_line_rec.line_id.last
  LOOP
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('top model: '|| p_ship_line_rec.top_model_line_id(I), 5);
    END IF;
    IF p_ship_line_rec.top_model_line_id(I) = p_top_model_line_id THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('3 calling Ship_Confirm_line '
                         ||p_ship_line_rec.line_id(I) , 3);
      END IF;

      IF l_model_remnant_flag = 'Y' THEN
        l_proportional_ship := 'N'; -- yes split because did not call splits

        IF p_ship_line_rec.shipped_quantity(I) <
           p_ship_line_rec.ordered_quantity(I)THEN
          p_ship_line_rec.fulfilled_flag(I) := 'N';
        ELSE
          p_ship_line_rec.fulfilled_flag(I) := 'Y';
        END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(' ful: ' ||p_ship_line_rec.fulfilled_flag(I), 3);
        END IF;
      ELSE
        l_proportional_ship := 'Y'; -- reusing the variable
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('calling Ship_Confirm_Line '
                          || l_model_remnant_flag, 3);
      END IF;

      Ship_Confirm_Line
      (p_ship_line_rec    => p_ship_line_rec
      ,p_check_line_set   => 'N'
      ,p_model_call       => l_proportional_ship
      ,p_index            => I);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('done calling Ship_Confirm_Line '
                        || p_ship_line_rec.line_id(I), 3);
    END IF;
  END LOOP;

  IF l_count1 > 0 THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('triming appended tables : ' ||l_count1 , 3);
    END IF;

    p_ship_line_rec.line_id.trim(l_count1);
    p_ship_line_rec.shipped_quantity.trim(l_count1);
    p_ship_line_rec.ordered_quantity.trim(l_count1);
    p_ship_line_rec.top_model_line_id.trim(l_count1);
    p_ship_line_rec.fulfilled_flag.trim(l_count1);
    p_ship_line_rec.header_id.trim(l_count1);

  END IF;


  -- Check for remnant model lines and fulfill them.
  IF l_split_line_tbl.COUNT > 0 THEN

    FOR I in l_split_line_tbl.FIRST..l_split_line_tbl.LAST
    LOOP
      IF (l_split_line_tbl(I).top_model_line_id =
                     l_split_line_tbl(I).line_id) AND
           l_split_line_tbl(I).model_remnant_flag ='Y' THEN

         IF l_debug_level  > 0 THEN
          oe_debug_pub.add('calling Fulfill_Remnant_PTO ', 3);
         END IF;

         -- handle all remnant non-shippable lines
         Fulfill_Remnant_PTO
         (p_top_model_line_id    => l_split_line_tbl(I).top_model_line_id);
      END IF;
    END LOOP;

  ELSE -- could be remnant case that we make.
    IF l_model_remnant_flag = 'Y' THEN

         IF l_debug_level  > 0 THEN
          oe_debug_pub.add('remnant made by us, calling Fulfill_Remnant_PTO '
                            || p_top_model_line_id, 3);
         END IF;

       Fulfill_Remnant_PTO
       (p_top_model_line_id    => p_top_model_line_id);
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('2 leaving Ship_Confirm_PTO ', 3);
  END IF;
EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Ship_Confirm_PTO '||sqlerrm,3);
    END IF;
    RAISE;
END Ship_Confirm_PTO;

/*-------------------------------------------------------------
PROCEDURE Ship_Confirm_Split_Lines
This procedure is used to ship confirm split lines when ship
confirmation of other lines in the line set results in fulfilling
the ordered quantity within or beyond tolerance.

It will be used for standard lines and Config items.
p_line_rec provide details about the line getting ship confirmed
we need to cehck if due shipment of this line if we need to
close other lines.

alcoa bug 2605086 - closing lines in line set

Change Record
Bug 3613716 - extend ato_line_id and item_type_code
--------------------------------------------------------------*/
PROCEDURE Ship_Confirm_Split_Lines
( p_ship_line_rec    IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_index            IN NUMBER)
IS
  l_line_set_rec     OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type;
  l_return_status    VARCHAR2(1);
  l_count            NUMBER;

  /* MOAC_SQL_CHANGE */
  CURSOR split_lines IS
  SELECT line_id, line_set_id, ordered_quantity, ordered_quantity2,
         order_quantity_uom, ordered_quantity_uom2, inventory_item_id,
         header_id
  FROM   oe_order_lines oe
  WHERE  line_id in
              (SELECT line_id
               FROM   oe_order_lines_all
               WHERE  line_set_id = p_ship_line_rec.line_set_id(p_index)
               AND    line_id <> p_ship_line_rec.line_id(p_index))
  AND    open_flag = 'Y'
  AND    shipped_quantity is NULL
  AND    line_id in
              (SELECT source_line_id
               FROM   wsh_delivery_details
               WHERE  source_header_id = oe.header_id);

  I             NUMBER := 0;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Ship_Confirm_Split_Lines '
                     ||p_ship_line_rec.line_id(p_index) ,3);
  END IF;

  FOR line_rec in split_lines
  LOOP

    SELECT count(*)
    INTO   l_count
    FROM   wsh_delivery_details
    WHERE  source_line_id = line_rec.line_id
    AND    released_status <> 'D';

    IF l_count > 0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ignoring this line, can not close '
                          || line_rec.line_id , 3 ) ;
      END IF;
    ELSE

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('now processing '|| line_rec.line_id, 3);
      END IF;

      I := I + 1;

      l_line_set_rec.shipping_quantity2.extend;
      l_line_set_rec.shipped_quantity2.extend;

      IF p_ship_line_rec.shipped_quantity2(p_index) is not NULL THEN
        l_line_set_rec.shipping_quantity2(I) := 0;
        l_line_set_rec.shipped_quantity2(I)  := 0;
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Start extending', 3);
      END IF;

      l_line_set_rec.line_id.extend;
      l_line_set_rec.header_id.extend;

      l_line_set_rec.shipping_quantity.extend;
      l_line_set_rec.shipped_quantity.extend;
      l_line_set_rec.shipping_quantity_uom.extend;
      l_line_set_rec.shipping_quantity_uom2.extend; -- INVCONV
      l_line_set_rec.actual_shipment_date.extend;
      l_line_set_rec.fulfilled_flag.extend;
      l_line_set_rec.ordered_quantity.extend;
      l_line_set_rec.ordered_quantity2.extend; -- INVCONV   4199186
      l_line_set_rec.ato_line_id.extend;
      l_line_set_rec.item_type_code.extend;

      l_line_set_rec.line_id(I)             := line_rec.line_id;
      l_line_set_rec.header_id(I)           := line_rec.header_id;

      l_line_set_rec.shipping_quantity(I)   := 0;
      l_line_set_rec.shipped_quantity(I)    := 0;
      l_line_set_rec.shipping_quantity_uom(I)
                      := p_ship_line_rec.shipping_quantity_uom(p_index);

      l_line_set_rec.shipping_quantity2(I)   := 0; -- INVCONV
      l_line_set_rec.shipped_quantity2(I)    := 0; -- INVCONV
      l_line_set_rec.shipping_quantity_uom2(I)      -- INVCONV
                      := p_ship_line_rec.shipping_quantity_uom2(p_index);

      l_line_set_rec.actual_shipment_date(I)
                      := p_ship_line_rec.actual_shipment_date(p_index);
      l_line_set_rec.ordered_quantity(I)
                      := p_ship_line_rec.ordered_quantity(p_index);
          l_line_set_rec.ordered_quantity2(I)
                      := nvl(p_ship_line_rec.ordered_quantity2(p_index), 0) ; -- INVCONV
      l_line_set_rec.fulfilled_flag(I)      := 'Y';

      Call_Notification_Framework
      ( p_ship_line_rec  => p_ship_line_rec
       ,p_caller         => 'SHIP_CONFIRM_SPLIT_LINES');

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Before quantities db update', 3);
      END IF;

      UPDATE OE_ORDER_LINES
      SET shipping_quantity     = l_line_set_rec.shipping_quantity(I),
          shipped_quantity      = l_line_set_rec.shipped_quantity(I),
          shipping_quantity2    = l_line_set_rec.shipping_quantity2(I),
          shipped_quantity2     = l_line_set_rec.shipped_quantity2(I),
          shipping_quantity_uom = l_line_set_rec.shipping_quantity_uom(I),
          shipping_quantity_uom2 = l_line_set_rec.shipping_quantity_uom2(I),  -- INVCONV
          actual_shipment_date  = l_line_set_rec.actual_shipment_date(I),
          lock_control          = lock_control + 1
          WHERE line_id         = l_line_set_rec.line_id(I);

      G_SKIP_SHIP := OE_GLOBALS.G_SKIP_ACTIVITY; -- Bug 10032407

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('line set id '|| line_rec.line_set_id , 3 ) ;
      END IF;

      Ship_Confirm_Line
      (p_ship_line_rec    => l_line_set_rec
      ,p_check_line_set   => 'N'
      ,p_index            => I);

      G_SKIP_SHIP:= OE_GLOBALS.G_COMPLETE_ACTIVITY; -- Bug 10032407

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ret sts for me '||l_return_status , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF; -- if wdd has lines staged/shipped or not deleted

  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Ship_Confirm_Split_Lines',3);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    G_SKIP_SHIP:= OE_GLOBALS.G_COMPLETE_ACTIVITY; -- Bug 10032407
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Ship_Confirm_Split_Lines '|| sqlerrm,3);
    END IF;
    RAISE;
END Ship_Confirm_Split_Lines;

/*-------------------------------------------------------------
PROCEDURE Call_Ship_Confirm_Old
--------------------------------------------------------------*/
PROCEDURE Call_Ship_Confirm_Old
( p_ship_line_rec    IN  OUT NOCOPY OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type
 ,p_index            IN  NUMBER
 ,x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_line_tbl         OE_ORDER_PUB.Line_Tbl_Type;
  l_line_adj_tbl     OE_ORDER_PUB.Line_adj_Tbl_Type;
  l_req_qty_tbl      Req_Quantity_Tbl_Type;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  I                  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Call_Ship_Confirm_Old', 3);
  END IF;

  I := p_ship_line_rec.line_id.FIRST;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Initial I is: '|| I, 3);
  END IF;

  WHILE I is NOT NULL
  LOOP
    l_line_tbl(I).actual_shipment_date     :=
               p_ship_line_rec.actual_shipment_date(I);
    l_line_tbl(I).shipping_quantity        :=
               p_ship_line_rec.shipping_quantity(I);
    l_line_tbl(I).shipping_quantity2       :=
               p_ship_line_rec.shipping_quantity2(I);
    l_line_tbl(I).shipping_quantity_uom    :=
               p_ship_line_rec.shipping_quantity_uom(I);
    l_line_tbl(I).shipping_quantity_uom2   :=
               p_ship_line_rec.shipping_quantity_uom2(I);
    l_line_tbl(I).line_id                  :=
               p_ship_line_rec.line_id(I);
    l_line_tbl(I).header_id                :=
               p_ship_line_rec.header_id(I);
    I := p_ship_line_rec.line_id.NEXT(I);
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('New I is: '|| I, 3);
    END IF;
  END LOOP;

  Ship_Confirm
  (p_api_version_number     => 1.0
  ,p_line_tbl               => l_line_tbl
  ,p_line_adj_tbl           => l_line_adj_tbl
  ,p_req_qty_tbl            => l_req_qty_tbl
  ,x_return_status          => x_return_status
  ,x_msg_count              => l_msg_count
  ,x_msg_data               => l_msg_data);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Call_Ship_Confirm_Old '|| x_return_status, 3);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Call_Ship_Confirm_Old '|| sqlerrm,3);
    END IF;
    RAISE;
END Call_Ship_Confirm_Old;


/*-----------------------------------------------------------
PROCEDURE Remove_Lines_From_Shipset
??check if you can avoid process order call.

3670530 - Lock the order lines belonging to the ship set before
          removing the lines from the ship set. Handle lock
          exception in the exception handler
------------------------------------------------------------*/
PROCEDURE Remove_Lines_From_Shipset
( p_set_tbl        IN  ship_confirm_sets)
IS
  CURSOR remove_lines(p_ship_set_id  NUMBER) IS
    SELECT line_id, item_type_code,
           top_model_line_id,
           nvl(model_remnant_flag, 'N') model_remnant_flag,
           fulfilled_quantity,
           open_flag,
           invoiced_quantity
    FROM   oe_order_lines
    WHERE  ship_set_id = p_ship_set_id
    AND    shipped_quantity is NULL;

  I               NUMBER;
  J               NUMBER;
  l_set_tbl       OE_Order_Pub.Line_Tbl_Type;
  l_control_rec   OE_GLOBALS.Control_Rec_Type;
  l_return_status VARCHAR2(1);
  l_line_id       NUMBER ;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Remove_Lines_From_Shipset',3);
  END IF;

  I := p_set_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP
    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('check if set id needs to be updated '|| I, 3);
    END IF;

    J := 0;

    -- FOR line_rec in remove_lines(I) -- Bug 8795918
    FOR line_rec in remove_lines(p_set_tbl(I))
    LOOP
      --- 4052633
      IF NVL(line_rec.fulfilled_quantity,0) > 0 OR
         NVL(line_rec.invoiced_quantity,0) > 0 OR
         line_rec.open_flag = 'N' THEN

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('DIRECT UPDATE LINE ID: '||line_rec.line_id,3);
         END IF;

         -- do direct update
         UPDATE oe_order_lines
         SET    ship_set_id = NULL
         WHERE  line_id=line_rec.line_id;

      ELSE
         -- lock the lines belonging to the particular set
         SELECT line_id
         INTO   l_line_id
         FROM   oe_order_lines
         WHERE  line_id = line_rec.line_id
         FOR UPDATE NOWAIT;

         J := J + 1;

         l_set_tbl(J) := OE_Order_Pub.G_MISS_LINE_REC;

         IF line_rec.model_remnant_flag = 'N' AND
            line_rec.top_model_line_id is NOT NULL THEN
            l_set_tbl(J).line_id := line_rec.top_model_line_id;
         ELSE
            l_set_tbl(J).line_id := line_rec.line_id;
         END IF;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('unshipped LINE ID : '||L_SET_TBL(J).LINE_ID,3);
         END IF;

         l_set_tbl(J).ship_set_id := NULL;
         l_set_tbl(J).operation := OE_GLOBALS.G_OPR_UPDATE;
      END IF;
    END LOOP; -- all unshipped lines are in l_set_tbl

    IF J > 0 THEN
      l_control_rec                  := OE_GLOBALS.G_MISS_CONTROL_REC;
      l_control_rec.validate_entity  := FALSE;
      l_control_rec.check_security   := FALSE;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATE SHIP SET ID '|| J,3);
      END IF;

       OE_Shipping_Integration_Pvt.Call_Process_Order
      ( p_line_tbl      => l_set_tbl,
        p_control_rec   => l_control_rec,
        x_return_status => l_return_status );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RET STS FROM PROCESS ORDER : '||L_RETURN_STATUS,3);
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    I := p_set_tbl.NEXT(I);
  END LOOP; -- loop over the set tbl

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Remove_Lines_From_Shipset',3);
  END IF;

EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Unable to lock the line',3);
    END IF;
    OE_Msg_Pub.Add_Text('Could not obtain Lock on Order Line/s');
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Remove_Lines_From_Shipset '|| sqlerrm,3);
    END IF;
    RAISE;
END Remove_Lines_From_Shipset;

/*-----------------------------------------------------------
PROCEDURE Handle_NonBulk_Mode
??making remnant -- do it in ship_confirm_pto

3358774 -- Update Ordered Quantity if there is a call to
           Handle_Requested_Quantity
3613716 -- extend fields ordered_quantuty,ship_tolerance_below
           and ship_tolerance_above
3670530 -- If the order line belongs to a set, lock the
           corresponding set from oe_sets table. handle lock
           exception in the exception handler. also, move the
           code to lock order lines to a separate block
------------------------------------------------------------*/
PROCEDURE Handle_NonBulk_Mode
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_requested_line_rec IN OUT NOCOPY Ship_Line_Rec_Type
 ,x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_split_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
  J                      NUMBER;
  l_price_control_rec    QP_PREQ_GRP.control_record_type;
  l_request_rec          OE_Order_PUB.request_rec_type;
  l_rem_top_model_line_id    NUMBER := -1;
  l_varchar1             VARCHAR2(1);
  l_model_tbl            ship_confirm_models;
  l_set_tbl              ship_confirm_sets;
  I                      NUMBER;
  l_line_tbl             OE_Order_Pub.Line_Tbl_Type;
  l_old_line_tbl         OE_Order_Pub.Line_Tbl_Type;
  l_return_status        VARCHAR2(1);
  l_ship_set_id          NUMBER := -1;
  l_arrival_set_id       NUMBER := -1;
  --bug 3654553
  K                      NUMBER;
  l_change_line_tbl      Oe_Line_Adj_Util.G_CHANGED_LINE_TBL1;
  l_order_has_lines      Oe_Order_Adj_Pvt.Index_Tbl_Type;
  l_ind                  Number;
  l_ind_hdr              Number;
  l_top_model_line_id_mod    Number; -- Bug 8795918
  l_ship_set_id_mod     NUMBER;  -- Bug 8795918

BEGIN

  IF l_debug_level  > 0 THEN
    Oe_Debug_pub.Add('----------entering handle_nonbulk_mode', 3);
  END IF;
 --9354229
  oe_globals.g_call_process_req := FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.ADD('request_line_rec line_id count: ' ||  p_requested_line_rec.line_id.COUNT, 3);
  END IF;

  -- Setting the message context, bug 4516453
  OE_MSG_PUB.set_msg_context(
     p_entity_code                => 'HEADER'
    ,p_entity_id                  => p_ship_line_rec.header_id(p_ship_line_rec.header_id.FIRST)
    ,p_header_id                  => p_ship_line_rec.header_id(p_ship_line_rec.header_id.FIRST)
    ,p_line_id                    => null
    ,p_order_source_id            => null
    ,p_orig_sys_document_ref      => null
    ,p_orig_sys_document_line_ref => null
    ,p_change_sequence            => null
    ,p_source_document_type_id    => null
    ,p_source_document_id         => null
    ,p_source_document_line_id    => null );

  IF p_requested_line_rec.line_id.COUNT > 0 THEN
    Handle_Requested_Qty
    (p_requested_line_rec   => p_requested_line_rec);

     FOR I in p_ship_line_rec.line_id.FIRST..p_ship_line_rec.line_id.LAST
     LOOP
       -- 3590689
       -- Added ship_tolerance_below, ship_tolerance_above
       -- 3613716 - extending the fields
       -- 4396294 - removed size to extend, no need
       p_ship_line_rec.ordered_quantity.extend;
       p_ship_line_rec.ship_tolerance_below.extend;
       p_ship_line_rec.ship_tolerance_above.extend;

       SELECT ordered_quantity,
              ship_tolerance_below,
              ship_tolerance_above
         INTO p_ship_line_rec.ordered_quantity(I),
              p_ship_line_rec.ship_tolerance_below(I),
              p_ship_line_rec.ship_tolerance_above(I)
         FROM oe_order_lines_all
        WHERE line_id =  p_ship_line_rec.line_id(I);
     END LOOP;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('last- ' || p_ship_line_rec.line_id.LAST || ' first- '||
                     p_ship_line_rec.line_id.FIRST, 5);
  END IF;

  J := p_ship_line_rec.line_id.LAST-p_ship_line_rec.line_id.FIRST + 1;


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('extending the tables '|| J, 1);
  END IF;

  --3590689
  p_ship_line_rec.ship_tolerance_below.extend(J);
  p_ship_line_rec.ship_tolerance_above.extend(J);
  /* We are extending tolerance_xxx for use in
    ship_confirm_line. These 2 vars are only populated
    when requested_line_rec count is non-zero. See comment
    in ship_confrim_line for details */

  p_ship_line_rec.shipped_quantity.extend(J);
  p_ship_line_rec.shipped_quantity2.extend(J);
  p_ship_line_rec.shippable_flag.extend(J); -- 4396294
  p_ship_line_rec.source_type_code.extend(J); -- Bug 7218408

  J := -1;

   --	SAVEPOINT opm_check; -- INVCONV

  FOR I in p_ship_line_rec.line_id.FIRST..p_ship_line_rec.line_id.LAST
  LOOP

    p_ship_line_rec.shipped_quantity(I)  := null;
    p_ship_line_rec.shipped_quantity2(I) := null;
    p_ship_line_rec.model_remnant_flag(I):=
             nvl(p_ship_line_rec.model_remnant_flag(I), 'N');

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(I || 'looping over ship line rec, line_id: '
                       || p_ship_line_rec.line_id(I), 5);
    END IF;

    BEGIN
      --Bug #5058663 start
      IF l_debug_level > 0 THEN
          oe_debug_pub.ADD('Ship_line_rec.line_id '|| i || ':' || p_ship_line_rec.line_id(I), 5);
     END IF;
      --
      SELECT top_model_line_id, shippable_flag
       INTO p_ship_line_rec.top_model_line_id(I), p_ship_line_rec.shippable_flag(I)
       FROM OE_ORDER_LINES
       WHERE line_id = p_ship_line_rec.line_id(I)
       FOR UPDATE NOWAIT;
      --

      IF l_debug_level > 0 THEN
         oe_debug_pub.add('aa2 locked line' , 1);
         oe_debug_pub.ADD('shippable_flag '|| i || ':' || p_ship_line_rec.shippable_flag(i), 5);
         oe_debug_pub.ADD('top_model_line_id '|| i || ':' || p_ship_line_rec.top_model_line_id(I), 5);

     END IF;

      IF p_ship_line_rec.top_model_line_id(I) is NOT NULL AND
         p_ship_line_rec.top_model_line_id(I) <> l_rem_top_model_line_id THEN

        SELECT top_model_line_id
        INTO   l_rem_top_model_line_id
        FROM   oe_order_lines
        WHERE  line_id = p_ship_line_rec.top_model_line_id(I)
        FOR UPDATE NOWAIT;
      --Bug #5058663 End of changes.
      IF l_debug_level  > 0 THEN
           oe_debug_pub.add('aa3 model locked '|| l_rem_top_model_line_id, 1);
        END IF;
      END IF;

       -- 4396294

    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Unable to lock the line',3);
        END IF;
        OE_Msg_Pub.Add_Text('Could not obtain Lock on Order Line/s');
        RAISE FND_API.G_EXC_ERROR;
      WHEN others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('error in handle_nonbulk_mode '|| sqlerrm, 3);
        END IF;
        RAISE;
    END ;

    -- locking OE_SETS table also
    BEGIN
      IF p_ship_line_rec.ship_set_id(I) IS NOT NULL AND
         p_ship_line_rec.ship_set_id(I) <> l_ship_set_id THEN
        SELECT Set_id
        INTO   l_ship_set_id
        FROM   OE_SETS
        WHERE  set_id = p_ship_line_rec.ship_set_id(I)
        FOR UPDATE NOWAIT ;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('locked ship set id : '|| l_ship_set_id);
        END IF;
       END IF ;

    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Unable to lock the ship set :' || l_ship_set_id ,3);
        END IF;
        OE_Msg_Pub.Add_Text('Could not obtain Lock on Ship Set');
        RAISE FND_API.G_EXC_ERROR;
      WHEN others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('error in handle_nonbulk_mode '|| sqlerrm, 3);
        END IF;
        RAISE;

    END ;

    BEGIN
      IF p_ship_line_rec.arrival_set_id(I) IS NOT NULL AND
         p_ship_line_rec.arrival_set_id(I) <> l_arrival_set_id THEN

        SELECT Set_id
        INTO   l_arrival_set_id
        FROM   OE_SETS
        WHERE  set_id = p_ship_line_rec.arrival_set_id(I)
        FOR UPDATE NOWAIT ;
        IF l_debug_level > 0 THEN
          oe_debug_pub.add('locked arrival set id : ' || l_arrival_set_id);
        END IF;
      END IF ;

    EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Unable to lock the arrival set :' || l_arrival_set_id ,3);
        END IF;
        OE_Msg_Pub.Add_Text('Could not obtain Lock on Arrival Set');
        RAISE FND_API.G_EXC_ERROR;
      WHEN others THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('error in handle_nonbulk_mode '|| sqlerrm, 3);
        END IF;
        RAISE;

    END ;


    ------------------------- locking done -------------

    Validate_Quantity
    ( p_ship_line_rec       => p_ship_line_rec
     ,p_index               => I );
     -- ,x_dual_item            => l_varchar1); -- INVCONV

    /* IF l_debug_level  > 0 THEN INVCONV     WHOLE IF l_varchar1 = 'Y' THEN NOT USED.
      Oe_Debug_pub.Add('after Validate_Quantity '|| l_varchar1, 3);
    END IF;

    IF l_varchar1 = 'Y' THEN

      ROLLBACK to opm_check;

      IF l_debug_level  > 0 THEN
        Oe_Debug_pub.Add('opm item found'|| p_ship_line_rec.line_id(I), 5);
      END IF;

      OE_Delayed_Requests_PVT.Clear_Request
      ( x_return_status => x_return_status);

      Call_Ship_Confirm_Old
      ( p_ship_line_rec    => p_ship_line_rec
       ,p_index            => I
       ,x_return_status    => x_return_status);

      IF l_debug_level  > 0 THEN
        Oe_Debug_pub.Add('returning ...'|| x_return_status, 5);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      RETURN;

    END IF;   */  -- INVCONV

    IF p_ship_line_rec.fulfilled_flag(I) = 'N' AND
       p_ship_line_rec.shipped_quantity(I) < p_ship_line_rec.ordered_quantity(I)
    THEN
      -- line will split
      IF p_ship_line_rec.calculate_price_flag(I) = 'Y' THEN
        p_ship_line_rec.calculate_price_flag(I) := 'P';
      END IF;
    END IF;

    Call_Notification_Framework
    ( p_ship_line_rec  => p_ship_line_rec
     ,p_caller         => 'HANDLE_NON_BULK');

    UPDATE OE_ORDER_LINES
    SET shipping_quantity     = p_ship_line_rec.shipping_quantity(I),
        shipping_quantity2    = p_ship_line_rec.shipping_quantity2(I),
        shipped_quantity2     = p_ship_line_rec.shipping_quantity2(I),
        shipped_quantity      = p_ship_line_rec.shipped_quantity(I),
        shipping_quantity_uom = p_ship_line_rec.shipping_quantity_uom(I),
        shipping_quantity_uom2 = p_ship_line_rec.shipping_quantity_uom2(I), -- INVCONV
        actual_shipment_date  = p_ship_line_rec.actual_shipment_date(I),
        over_ship_reason_code = p_ship_line_rec.over_ship_reason_code(I),
        calculate_price_flag  = p_ship_line_rec.calculate_price_flag(I),
        lock_control          = lock_control + 1
    WHERE line_id = p_ship_line_rec.line_id(I);

    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('shipped qty updated to: '
      || p_ship_line_rec.shipped_quantity(I) || ' shp qty 2 is :'
      || p_ship_line_rec.shipping_quantity2(I), 3);
    END IF;

    IF p_ship_line_rec.arrival_set_id(I) IS NOT NULL AND
       p_ship_line_rec.arrival_set_id(I) <> J
    THEN
      UPDATE  OE_SETS
      SET     SET_STATUS = 'C'
      WHERE   SET_ID = p_ship_line_rec.arrival_set_id(I)
      AND     SET_STATUS <> 'C';

      IF SQL%FOUND AND
         l_debug_level  > 0 THEN
        oe_debug_pub.add('arrival SET CLOSED: '
                          || p_ship_line_rec.arrival_set_id(I), 3 ) ;
      END IF;

      J := p_ship_line_rec.arrival_set_id(I);
    END IF;

    ------------- validate, update and close arrival set --------

     IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('Before Logging Pricing Delayed Request');
     END IF;


     IF p_ship_line_rec.calculate_price_flag(I) IN ('Y','P') OR
        (p_ship_line_rec.shipping_quantity2(I) IS NOT NULL
         AND p_ship_line_rec.shipping_quantity2(I) <> 0 )  -- bug 3598987,3659454
     THEN
      --bug 3654553, 8795918

      IF p_ship_line_rec.line_id(I) > OE_GLOBALS.G_BINARY_LIMIT THEN
        l_ind := mod(p_ship_line_rec.line_id(I),OE_GLOBALS.G_BINARY_LIMIT);
      ELSE
        l_ind := p_ship_line_rec.line_id(I);
      END IF;
      IF p_ship_line_rec.header_id(I) > OE_GLOBALS.G_BINARY_LIMIT THEN
        l_ind_hdr := mod(p_ship_line_rec.header_id(I),OE_GLOBALS.G_BINARY_LIMIT);
      ELSE
        l_ind_hdr := p_ship_line_rec.header_id(I);
      END IF;
      /* Caching lines which needs to be priced */
      IF NOT l_change_line_tbl.EXISTS(l_ind) THEN
        l_change_line_tbl(l_ind).line_id := p_ship_line_rec.line_id(I);
        l_change_line_tbl(l_ind).header_id := p_ship_line_rec.header_id(I);
      END IF;
      /* Caching the order which has at least a line that is being shipped */
      IF NOT l_order_has_lines.EXISTS(l_ind_hdr) THEN
        l_order_has_lines(l_ind_hdr) := p_ship_line_rec.header_id(I);
      END IF;

    END IF;


    IF p_ship_line_rec.ship_set_id(I) is NOT NULL THEN
      l_ship_set_id_mod := mod(p_ship_line_rec.ship_set_id(I),OE_GLOBALS.G_BINARY_LIMIT); --Bug 8795918
      -- IF l_set_tbl.EXISTS(p_ship_line_rec.ship_set_id(I)) -- Bug 8795918
      IF l_set_tbl.EXISTS(l_ship_set_id_mod)
      THEN

        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('set id exists ', 5);
        END IF;

        --l_set_tbl(p_ship_line_rec.ship_set_id(I))
        --:= l_set_tbl(p_ship_line_rec.ship_set_id(I)) +1;
      ELSE
        -- l_set_tbl(p_ship_line_rec.ship_set_id(I)) := 1;-- Bug 8795918
	l_set_tbl(l_ship_set_id_mod) := 1;

        UPDATE OE_SETS
        SET    SET_STATUS = 'C'
        WHERE  SET_ID = p_ship_line_rec.ship_set_id(I)
        AND    SET_STATUS <> 'C';

        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('set closed '|| p_ship_line_rec.ship_set_id(I), 3);
        END IF;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('decide - ship confirm now', 3);
    END IF;
    IF p_ship_line_rec.top_model_line_id(I) is not null AND
       p_ship_line_rec.top_model_line_id(I) <>
       nvl(p_ship_line_rec.ato_line_id(I), -1) AND
       p_ship_line_rec.model_remnant_flag(I) = 'N' THEN
       l_top_model_line_id_mod := mod(p_ship_line_rec.top_model_line_id(I),OE_GLOBALS.G_BINARY_LIMIT);-- Bug 8795918
       IF l_debug_level  > 0 THEN
         Oe_Debug_pub.Add('this line is part of a pto model', 3);
       END IF;
      -- IF l_model_tbl.EXISTS(p_ship_line_rec.top_model_line_id(I)) -- Bug 8795918
      IF l_model_tbl.EXISTS(l_top_model_line_id_mod)
      THEN
	IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('here 1-2-3 '
			   || p_ship_line_rec.top_model_line_id(I), 3);
	END IF;
      ELSE
      --  l_model_tbl(p_ship_line_rec.top_model_line_id(I)) := I; -- Bug 8795918
      l_model_tbl(l_top_model_line_id_mod) := I;

        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add(p_ship_line_rec.top_model_line_id(I)
          || ' added model ' || l_model_tbl(l_top_model_line_id_mod), 3);
        --  || l_model_tbl(p_ship_line_rec.top_model_line_id(I)), 3); -- Bug 8795918
        END IF;
      END IF; -- added the model to table

    ELSE -- standard or remnant
      IF l_debug_level  > 0 THEN
        Oe_Debug_pub.Add
         ('line is standalone '|| p_ship_line_rec.ato_line_id(I), 3);
      END IF;
      IF p_ship_line_rec.top_model_line_id(I) = p_ship_line_rec.ato_line_id(I)
         AND p_ship_line_rec.item_type_code(I) = 'CONFIG' THEN
        l_varchar1 := 'Y';
      ELSE
        l_varchar1 := 'N';
      END IF;

      IF l_debug_level  > 0 THEN
        Oe_Debug_pub.Add('------ calling Ship_Confirm_Line '|| l_varchar1, 3);
      END IF;

      Ship_Confirm_Line
      (p_ship_line_rec   => p_ship_line_rec
      ,p_index           => I
      ,p_ato_only        => l_varchar1);
    END IF; -- if model

    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add
      (I ||' -------- done with this line: '||p_ship_line_rec.line_id(I), 5);
    END IF;
  END LOOP;  -- end of big  loop

  /* bug 3654553 calling to register changed lines */
  K := l_change_line_tbl.FIRST;
  WHILE K IS NOT NULL
  LOOP
    Oe_Line_Adj_Util.Register_Changed_Lines
    ( p_line_id       => l_change_line_tbl(K).line_id
     ,p_header_id     => l_change_line_tbl(K).header_id
     ,p_operation     => OE_GLOBALS.G_OPR_UPDATE);
    K := l_change_line_tbl.NEXT(K);
  END LOOP;
  l_change_line_tbl.delete;

  /* bug 3654553 logging price_order request to price the whole order at one go
     intead of pricing line by line to improve performance
  */
  K := l_order_has_lines.FIRST;
  WHILE K is NOT NULL
  LOOP
    OE_delayed_requests_Pvt.log_request
    ( p_entity_code                   => OE_GLOBALS.G_ENTITY_ALL
     ,p_entity_id                     => l_order_has_lines(K)
     ,p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_ALL
     ,p_requesting_entity_id          => l_order_has_lines(K)
     ,p_request_unique_key1           => 'SHIP'
     ,p_param1                        => l_order_has_lines(K)
     ,p_param2                        => 'SHIP'
     ,p_request_type                  => OE_GLOBALS.G_PRICE_ORDER
     ,x_return_status                 => l_return_status);

    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('Ret sts After Delayed Req'||l_return_status, 4);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    K := l_order_has_lines.NEXT(K);
  END LOOP;
  l_order_has_lines.delete;
  --bug 3654553


  I := l_model_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP
    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('----------- calling Ship_Confirm_PTO '|| I, 3);
    END IF;

    Ship_Confirm_PTO
    ( p_top_model_line_id  => p_ship_line_rec.top_model_line_id(l_model_tbl(I))
    -- ( p_top_model_line_id  => I -- Bug 8795918
     ,p_index              => l_model_tbl(I)
     ,p_ship_line_rec      => p_ship_line_rec);

    I := l_model_tbl.NEXT(I);
  END LOOP;

  IF l_set_tbl.COUNT > 0 THEN
    Remove_Lines_From_Shipset
    (p_set_tbl     => l_set_tbl);
  END IF;

  --9354229
  oe_globals.g_call_process_req := TRUE;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('calling Process_Requests_And_Notify......', 1);
  END IF;

  OE_Order_PVT.Process_Requests_And_Notify
  ( p_process_requests   => TRUE
   ,p_notify             => TRUE
   ,x_return_status      => x_return_status
   ,p_line_tbl           => l_line_tbl
   ,p_old_line_tbl       => l_old_line_tbl );

  OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER'); -- bug 4516453

  IF l_debug_level  > 0 THEN
    Oe_Debug_pub.Add('leaving handle_nonbulk_mode '||x_return_status, 3);
  END IF;

EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Unable to lock the line',3);
    END IF;
    --9354229
    oe_globals.g_call_process_req := TRUE;
    OE_Msg_Pub.Add_Text('Could not obtain Lock on Order Line/s');
    OE_MSG_PUB.Save_API_Messages();                --bug 4516453
    OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER'); -- bug 4516453
    RAISE FND_API.G_EXC_ERROR;

  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('error in handle_nonbulk_mode '|| sqlerrm, 3);
    END IF;
    --9354229
    oe_globals.g_call_process_req := TRUE;
    OE_MSG_PUB.Save_API_Messages();                --bug 4516453
    OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER'); -- bug 4516453
    RAISE;
END Handle_NonBulk_Mode;


/*-----------------------------------------------------------
PROCEDURE Handle_Bulk_Mode

The code from this API has been moved to Handle_Bulk_Mode_per_order
api, written for bug 4170119
------------------------------------------------------------*/
PROCEDURE Handle_Bulk_Mode
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_line_adj_rec       IN            Ship_Adj_Rec_Type
 ,p_start_index        IN            NUMBER
 ,p_end_index          IN            NUMBER
 ,x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_order_start_index    NUMBER;
  l_order_end_index      NUMBER;
  l_index                NUMBER;
  l_temp_index           NUMBER;
  l_temp_header_id       NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_temp_header_id    := p_ship_line_rec.header_id(p_start_index);
  l_order_start_index := p_start_index;

  IF l_temp_header_id = p_ship_line_rec.header_id(p_end_index) THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD('only one order in the trip', 1);
    END IF;

    Handle_Bulk_Mode_Per_Order
    ( p_ship_line_rec   => p_ship_line_rec
     ,p_line_adj_rec    => p_line_adj_rec
     ,p_start_index     => p_start_index
     ,p_end_index       => p_end_index
     ,x_return_status   => x_return_status );

    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD('1 leaving Handle_Bulk_Mode '|| x_return_status, 1);
    END IF;

    RETURN;
  END IF;

  FOR I IN p_start_index..p_end_index
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD(I ||' ---------- shipping_quantity '
      || p_ship_line_rec.shipping_quantity(I),5);
      oe_debug_pub.ADD('shipping_quantity2 '
      || p_ship_line_rec.shipping_quantity2(I),5);
      oe_debug_pub.ADD('shipping_quantity_uom '
      || p_ship_line_rec.shipping_quantity_uom(I),5);
      oe_debug_pub.ADD('shipping_quantity_uom2 '
      || p_ship_line_rec.shipping_quantity_uom2(I),5);
      oe_debug_pub.ADD('actual_shipment_date '
      || p_ship_line_rec.actual_shipment_date(I),5);
      oe_debug_pub.ADD('line_id '
      || p_ship_line_rec.line_id(I),5);
    END IF;

    -- header change logic here
    IF p_ship_line_rec.header_id(I) <> l_temp_header_id THEN
      l_order_end_index := I - 1;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.ADD('order start index '|| l_order_start_index
                          || '--order end index '|| l_order_end_index , 1);
      END IF;

      Handle_Bulk_Mode_Per_Order
      ( p_ship_line_rec   => p_ship_line_rec
       ,p_line_adj_rec    => p_line_adj_rec
       ,p_start_index     => l_order_start_index
       ,p_end_index       => l_order_end_index
       ,x_return_status   => x_return_status );

      l_order_start_index := I;
      l_temp_header_id    := p_ship_line_rec.header_id(I);

    END IF;

    IF I = p_end_index THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.ADD('order start index '|| l_order_start_index
                          || '--order end index '|| p_end_index , 1);
      END IF;

      Handle_Bulk_Mode_Per_Order
      ( p_ship_line_rec   => p_ship_line_rec
       ,p_line_adj_rec    => p_line_adj_rec
       ,p_start_index     => l_order_start_index
       ,p_end_index       => p_end_index
       ,x_return_status   => x_return_status );

    END IF;
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.ADD('2 leaving Handle_Bulk_Mode '|| x_return_status, 1);
  END IF;

EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Handle_Bulk_Mode ' || sqlerrm, 1);
    END IF;

    RAISE;
END Handle_Bulk_Mode;

/*-----------------------------------------------------------
 * PROCEDURE Handle_Bulk_Mode_Per_Order
 * The code from the Handle_bulk_mode API has been put in this new api for
 * bug4170119
 *
 * locking -- update table will lock rows, not doing for now
 * before notification framework.
 *
 * change record:
 * bug bugs 3544045, 3544209: a mix of internal and external
 * lines with complete shipped quantity should make the
 * model remnant even in case of BULK model call from WSH.
 *
 * Bug 3679500: Changed the return_status variable to be l_return_status
 * in the call to Price_Line and Process_Requests_And_Notify. Previously,
 * x_return_status was being used.
 * ------------------------------------------------------------*/
PROCEDURE Handle_Bulk_Mode_Per_Order
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_line_adj_rec       IN            Ship_Adj_Rec_Type
 ,p_start_index        IN            NUMBER
 ,p_end_index          IN            NUMBER
 ,x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_price_control_rec    QP_PREQ_GRP.control_record_type;
  l_request_rec          OE_Order_PUB.request_rec_type;
  l_line_tbl             OE_ORDER_PUB.line_Tbl_type;
  l_old_line_tbl         OE_ORDER_PUB.line_Tbl_type;
  l_return_status        VARCHAR2(1);
  l_last_top_model       NUMBER := -1;
  --bug 3654553
  J                      NUMBER;
  K                      NUMBER;
  l_change_line_tbl      Oe_Line_Adj_Util.G_CHANGED_LINE_TBL1;
  l_order_has_lines      Oe_Order_Adj_Pvt.Index_Tbl_Type;
  l_ind                  Number;
  l_ind_hdr              Number;
  -- tso
  l_top_container_model  Varchar2(1);
  l_part_of_container    Varchar2(1);
  l_last_calc_price      NUMBER; -- Bug 7149219

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.ADD('entering Handle_Bulk_Mode_Per_Order '
                      || p_ship_line_rec.header_id(p_start_index),5);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Setting the message context, bug 4516453
  OE_MSG_PUB.set_msg_context(
   p_entity_code                => 'HEADER'
  ,p_entity_id                  => p_ship_line_rec.header_id(p_start_index)
  ,p_header_id                  => p_ship_line_rec.header_id(p_start_index)
  ,p_line_id                    => null
  ,p_order_source_id            => null
  ,p_orig_sys_document_ref      => null
  ,p_orig_sys_document_line_ref => null
  ,p_change_sequence            => null
  ,p_source_document_type_id    => null
  ,p_source_document_id         => null
  ,p_source_document_line_id    => null );

  Call_Notification_Framework
  ( p_ship_line_rec  => p_ship_line_rec
   ,p_start_index    => p_start_index
   ,p_end_index      => p_end_index
   ,p_caller         => 'HANDLE_BULK');

  FORALL I in p_start_index..p_end_index

    UPDATE OE_ORDER_LINES_ALL
    SET shipping_quantity      = p_ship_line_rec.shipping_quantity(I),
        shipping_quantity2     = p_ship_line_rec.shipping_quantity2(I),
        shipped_quantity2      = p_ship_line_rec.shipping_quantity2(I),
        shipped_quantity       = p_ship_line_rec.ordered_quantity(I),
       -- shipped_quantity2       = p_ship_line_rec.ordered_quantity2(I), -- INVCONV
        shipping_quantity_uom  = p_ship_line_rec.shipping_quantity_uom(I),
        shipping_quantity_uom2 = p_ship_line_rec.shipping_quantity_uom2(I),
        actual_shipment_date   = p_ship_line_rec.actual_shipment_date(I),
        flow_status_code       = 'SHIPPED',
	last_update_date      = sysdate,--6901322
        lock_control           = lock_control + 1
    WHERE line_id = p_ship_line_rec.line_id(I);

  IF SQL%FOUND THEN
    oe_debug_pub.ADD('updated lines with shipped qty '|| sql%rowcount,1);
  END IF;


  FORALL I in p_start_index..p_end_index
    UPDATE OE_ORDER_LINES_ALL oe1
    SET    model_remnant_flag = 'Y'
    WHERE  top_model_line_id is not NULL
    AND    top_model_line_id = p_ship_line_rec.top_model_line_id(I)
    AND    model_remnant_flag is NULL
    AND    (EXISTS (SELECT NULL
                   FROM   oe_order_lines_all oe2
                   WHERE  oe2.top_model_line_id = oe1.top_model_line_id
                   AND    source_type_code =  'EXTERNAL')
            OR -- added for bug 4701487
            EXISTS (SELECT NULL
                    FROM   oe_order_lines_all oe3
                    WHERE  oe3.top_model_line_id = oe1.top_model_line_id
                    AND    cancelled_flag = 'N'
                    AND    schedule_ship_date  is NULL));

  IF SQL%FOUND THEN
    oe_debug_pub.ADD('updated lines model_remnant_flag '|| sql%rowcount,1);
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.ADD(' Start Index : '||p_start_index);
    oe_debug_pub.ADD(' End Index : '||p_end_index);
  END IF;

  p_ship_line_rec.error_flag.extend(p_end_index - p_start_index + 1);

  -- Added for bug 7149219
  l_last_calc_price := nvl(p_ship_line_rec.calculate_price_flag.LAST,p_end_index);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.ADD(' Last Calc Price is : '||l_last_calc_price);
  END IF;

  -- Commented for 7450821 start
  -- Added for bug 7149219
  /*IF p_end_index >= p_start_index and p_end_index >  l_last_calc_price THEN
    p_ship_line_rec.calculate_price_flag.EXTEND(p_end_index - l_last_calc_price);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD(' calculate_price_flag is extended');
    END IF;
  END IF;*/
  -- Commented for 7450821 end

  FOR i in p_start_index..p_end_index
  LOOP
    p_ship_line_rec.error_flag(i) := 'N';

    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD('CompleteActivity '|| p_ship_line_rec.line_id(i), 1);
    END IF;

    BEGIN


      -- Modified for 7450821 start
      -- Commented for bug 7149219
      -- p_ship_line_rec.calculate_price_flag.extend(I);
      p_ship_line_rec.calculate_price_flag.extend(1);
      -- Modified for 7450821 end

      SELECT calculate_price_flag
      INTO   p_ship_line_rec.calculate_price_flag(i)
      FROM   oe_order_lines_all
      WHERE  line_id = p_ship_line_rec.line_id(i);

      IF p_ship_line_rec.calculate_price_flag(i) IN ('Y','P') OR
         (p_ship_line_rec.shipping_quantity2(I) IS NOT NULL
          AND p_ship_line_rec.shipping_quantity2(I) <> 0 ) -- bug 3598987,3659454
      THEN

        --bug 3654553
        IF p_ship_line_rec.line_id(I) > 2147483647 THEN
          l_ind := mod(p_ship_line_rec.line_id(I),2147483647);
        ELSE
          l_ind := p_ship_line_rec.line_id(I);
        END IF;
        IF p_ship_line_rec.header_id(I) > 2147483647 THEN
          l_ind_hdr := mod(p_ship_line_rec.header_id(I),2147483647);
        ELSE
          l_ind_hdr := p_ship_line_rec.header_id(I);
        END IF;
        /* Caching lines that need to be priced */
        IF NOT l_change_line_tbl.EXISTS(l_ind) THEN
          l_change_line_tbl(l_ind).line_id := p_ship_line_rec.line_id(I);
          l_change_line_tbl(l_ind).header_id := p_ship_line_rec.header_id(I);
        END IF;
        IF NOT l_order_has_lines.EXISTS(l_ind_hdr) THEN
          l_order_has_lines(l_ind_hdr) := p_ship_line_rec.header_id(I);
        END IF;
        --bug 3654553
      END IF;
      -- workflow completion code moved for bug 4070931

    EXCEPTION
      WHEN others THEN
        NULL;

    END;

  END LOOP;

  --bug 3654553
  /* Call to price one order at a time */
  J := l_order_has_lines.first;
  WHILE J is NOT NULL
  LOOP
    K := l_change_line_tbl.FIRST;
    WHILE K is NOT NULL
    LOOP
      IF l_change_line_tbl(K).header_id = l_order_has_lines(J) THEN
        Oe_Line_Adj_Util.Register_Changed_Lines
        ( p_line_id       => l_change_line_tbl(K).line_id
         ,p_header_id     => l_change_line_tbl(K).header_id
         ,p_operation     => OE_GLOBALS.G_OPR_UPDATE);
        l_change_line_tbl.delete(K);
      END IF;
      K := l_change_line_tbl.NEXT(K);
    END LOOP;

    l_Price_Control_Rec.pricing_event   := 'SHIP';
    l_Price_Control_Rec.calculate_flag  := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
    l_Price_Control_Rec.Simulation_Flag := 'N';

    OE_Order_Adj_Pvt.Price_Line
    ( x_return_status       => l_return_status
     ,p_Header_id           => l_order_has_lines(J)
     ,p_Request_Type_code   => 'ONT'
     ,p_Control_rec         => l_Price_Control_Rec
     ,p_write_to_db         => TRUE
     ,p_request_rec         => l_request_rec
     ,x_line_Tbl            => l_Line_Tbl);

    l_line_tbl := l_old_line_tbl; -- bug 3303011

    IF l_debug_level  > 0 THEN
      Oe_Debug_pub.Add('After price line for '||l_return_status, 1);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    J := l_order_has_lines.NEXT(J);
  END LOOP;
  l_order_has_lines.delete;
  l_change_line_tbl.delete;
  -- bug 4070931 starts
  FOR i in p_start_index..p_end_index
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD('CompleteActivity '|| p_ship_line_rec.line_id(i), 1);
    END IF;

    BEGIN
      WF_Engine.CompleteActivityInternalName
      ( itemtype      => OE_GLOBALS.G_WFI_LIN
       ,itemkey       => to_char(p_ship_line_rec.line_id(i))
       ,activity      => 'SHIP_LINE'
       ,result        => 'SHIP_CONFIRM');

      IF l_debug_level  > 0 THEN
        oe_debug_pub.ADD('Returned from wf CompleteActivity',1);
      END IF;

    EXCEPTION
      WHEN others THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.ADD('wf CompleteActivity error ' || sqlerrm,1);
        END IF;

        p_ship_line_rec.error_flag(i) := 'Y';
        x_return_status               := 'W';

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add ('X_Return_status is now WARNING',1);
        END IF;

        Call_Notification_Framework
       ( p_ship_line_rec  => p_ship_line_rec
        ,p_index          => i
        ,p_caller         => 'HANDLE_BULK_FAILURE');

    END;

  END LOOP; -- bug 4070931 ends

  --bug 3654553
  IF l_debug_level  > 0 THEN
    oe_debug_pub.ADD('gg1 '|| p_start_index ||'-' ||p_end_index,1);
  END IF;
  FORALL i in p_start_index..p_end_index
    UPDATE oe_order_lines_all
    SET    shipped_quantity = ordered_quantity, -- INVCONV
    			 shipped_quantity2 = ordered_quantity2  -- INVCONV
          ,actual_shipment_date = p_ship_line_rec.actual_shipment_date(i)
          ,lock_control     = lock_control + 1
    WHERE  line_id in
             (SELECT line_id
              FROM oe_order_lines_all
              WHERE top_model_line_id =
                    p_ship_line_rec.top_model_line_id(i))
    AND    shippable_flag = 'N'
    AND    p_ship_line_rec.error_flag(i) = 'N'
    AND    shipped_quantity is NULL
    AND    open_flag = 'Y'
    AND    nvl(cancelled_flag, 'N') = 'N'
    AND    source_type_code = 'INTERNAL'
           RETURNING line_id,
                     ato_line_id,
                     item_type_code,
                     shipped_quantity,
                     shipped_quantity2, -- INVCONV
                     actual_shipment_date,
                     model_remnant_flag,
                     top_model_line_id
           BULK COLLECT
           INTO  g_non_shippable_rec.line_id,
                 g_non_shippable_rec.ato_line_id,
                 g_non_shippable_rec.item_type_code,
                 g_non_shippable_rec.shipped_quantity,
                 g_non_shippable_rec.shipped_quantity2, -- INVCONV
                 g_non_shippable_rec.actual_shipment_date,
                 g_non_shippable_rec.model_remnant_flag,
                 g_non_shippable_rec.top_model_line_id;


    IF SQL%FOUND THEN
      IF l_debug_level > 0 THEN
        oe_debug_pub.ADD('nonshippable lines updated '|| sql%rowcount,1);
      END IF;

      FOR I in g_non_shippable_rec.line_id.FIRST..
               g_non_shippable_rec.line_id.LAST
      LOOP
        -- TSO with Equipment
        OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
       (p_line_id              =>  g_non_shippable_rec.line_id(I),
        x_top_container_model  =>  l_top_container_model,
        x_part_of_container    =>  l_part_of_container);

        IF l_part_of_container = 'Y' THEN
          UPDATE oe_order_lines_all
          SET    shipped_quantity = NULL
                ,actual_shipment_date = NULL
                ,lock_control     = lock_control + 1
          WHERE  line_id = g_non_shippable_rec.line_id(I);
        END IF;
        -- TSO with equipment ends

        IF g_non_shippable_rec.line_id(I) =
           g_non_shippable_rec.ato_line_id(I) AND
           (g_non_shippable_rec.item_type_code(I) = 'MODEL' OR
            g_non_shippable_rec.item_type_code(I) = 'CLASS')
        THEN -- what about ato item??

          IF l_debug_level > 0 THEN
            oe_debug_pub.ADD(I || ' complete wait for cto '
                             || g_non_shippable_rec.ato_line_id(I), 1);
          END IF;

          WF_Engine.CompleteActivityInternalName
          (itemtype =>  OE_GLOBALS.G_WFI_LIN,
           itemkey  =>  to_char(g_non_shippable_rec.ato_line_id(I)),
           activity =>  'WAIT_FOR_CTO',
           result   =>  OE_GLOBALS.G_WFR_COMPLETE);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;

        IF g_non_shippable_rec.model_remnant_flag(I) = 'Y' THEN

          UPDATE oe_order_lines_all
          SET    shipped_quantity = null
                ,lock_control     = lock_control + 1
          WHERE  line_id = g_non_shippable_rec.line_id(I);


          IF l_last_top_model <> g_non_shippable_rec.top_model_line_id(I) THEN

            IF l_debug_level > 0 THEN
              oe_debug_pub.ADD(I || ' calling fulfill remnant lines '
                               || g_non_shippable_rec.top_model_line_id(I), 1);
            END IF;

            fulfill_remnant_pto
            (p_top_model_line_id => g_non_shippable_rec.top_model_line_id(I));
          END IF;

          l_last_top_model := g_non_shippable_rec.top_model_line_id(I);
        END IF;
      END LOOP;

      g_non_shippable_rec.line_id.delete;
      g_non_shippable_rec.ato_line_id.delete;
      g_non_shippable_rec.item_type_code.delete;
      g_non_shippable_rec.shipped_quantity.delete;
      g_non_shippable_rec.shipped_quantity2.delete; -- INVCONV
      g_non_shippable_rec.actual_shipment_date.delete;

    END IF; -- if non shippable lines
  -- 4052633
  FORALL I in p_start_index..p_end_index
    UPDATE OE_ORDER_LINES_ALL oe1
    SET    ship_set_id = NULL
    WHERE  ship_set_id is not NULL
    AND    shipped_quantity is NULL
    AND    ship_set_id = p_ship_line_rec.ship_set_id(I);

  IF SQL%FOUND THEN
    oe_debug_pub.ADD('removed lines from shipset '|| sql%rowcount,1);
  END IF;

  FORALL i in p_start_index..p_end_index

    UPDATE oe_sets
    SET    set_status = 'C'
    WHERE  set_id = p_ship_line_rec.ship_set_id(i)
    AND    SET_STATUS <> 'C'
    AND    p_ship_line_rec.error_flag(i) = 'N';

    IF SQL%FOUND THEN
      oe_debug_pub.ADD('gg4 sets closed '|| sql%rowcount,1);
    END IF;

  -- { bug3309470: close arrival sets also
  FORALL i IN p_start_index..p_end_index
     UPDATE oe_sets
     SET    set_status = 'C'
     WHERE  set_id = p_ship_line_rec.arrival_set_id(i)
     AND    SET_STATUS <> 'C'
     AND    p_ship_line_rec.error_flag(i) = 'N';

     IF SQL%FOUND THEN
        OE_DEBUG_PUB.Add('Arrival Sets Closed:'||sql%rowcount,1);
     END IF;
  -- bug3309470 ends }

  IF x_return_status = 'W' THEN
    FORALL i in p_start_index..p_end_index
      UPDATE OE_ORDER_LINES_ALL
      SET shipping_quantity      = null,
          shipping_quantity2     = null,
          shipped_quantity2      = null,
          shipped_quantity       = null,
          shipping_quantity_uom  = null,
          shipping_quantity_uom2 = null,
          actual_shipment_date   = null,
          flow_status_code       = p_ship_line_rec.flow_status_code(i),
          lock_control           = lock_control - 1
      WHERE line_id = p_ship_line_rec.line_id(i)
      AND   p_ship_line_rec.error_flag(i) = 'Y';

      IF SQL%FOUND THEN
        oe_debug_pub.ADD('errored lines '|| sql%rowcount,1);
      END IF;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('calling Process_Requests_And_Notify......', 1);
  END IF;

  OE_Order_PVT.Process_Requests_And_Notify
  ( p_process_requests   => FALSE
   ,p_notify             => TRUE
   ,x_return_status      => l_return_status
   ,p_line_tbl           => l_line_tbl
   ,p_old_line_tbl       => l_old_line_tbl );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := l_return_status;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add ('Failure in Process_Requests_ANd_Notify',1);
     END IF;
  END IF;

  -- Reseting the msg context, bug 4516453
  OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Handle_Bulk_Mode_Per_Order '|| x_return_status, 1);
  END IF;

EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Unable to lock the line',3);
    END IF;
    OE_Msg_Pub.Add_Text('Could not obtain Lock on Order Line/s');
    OE_MSG_PUB.Save_API_Messages(); --bug 4516453
    OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER');
    RAISE FND_API.G_EXC_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Handle_Bulk_Mode_Per_Order ' || sqlerrm, 1);
    END IF;
    OE_MSG_PUB.Save_API_Messages(); --bug 4516453
    OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'HEADER');
    RAISE;
END Handle_Bulk_Mode_Per_Order;

/*------------------------------------------------------------
PROCEDURE Ship_Confirm_New

p_start_index and p_end_index are applicable only in bulk mode
and only to p_ship_line_rec. The p_line_adj_rec will only
contain records corresponding to that batch of tables between
p_start_index and p_end_index in ship_line_rec.

handle_bulk and handle non bulk really do not need
x_return_status, may be remove.
-------------------------------------------------------------*/
PROCEDURE Ship_Confirm_New
( p_ship_line_rec      IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_requested_line_rec IN OUT NOCOPY Ship_Line_Rec_Type
 ,p_line_adj_rec       IN OUT NOCOPY Ship_Adj_Rec_Type
 ,p_bulk_mode          IN            VARCHAR2
 ,p_start_index        IN            NUMBER
 ,p_end_index          IN            NUMBER
 ,x_msg_count          OUT NOCOPY /* file.sql.39 change */           NUMBER
 ,x_msg_data           OUT NOCOPY    VARCHAR2
 ,x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_org_id      NUMBER;
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('entering Ship_Confirm_New '
                      || p_line_adj_rec.line_id.COUNT
                      || p_ship_line_rec.line_id.COUNT , 1);
  END IF;

  -- MOAC check for Org_id
  l_org_id := MO_GLOBAL.get_current_org_id;
  IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
     OE_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  SAVEPOINT om_ship_confirm;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ---------- Create Freight Cost Records first --------
  IF p_line_adj_rec.line_id.COUNT > 0 THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('inserting adjustments '
                        || p_line_adj_rec.line_id.COUNT, 5);
    END IF;

    --bug 4558089
    FORALL i IN p_line_adj_rec.line_id.FIRST..p_line_adj_rec.line_id.LAST
      DELETE FROM OE_PRICE_ADJUSTMENTS
      WHERE LINE_ID = p_line_adj_rec.line_id(i)
        AND CHARGE_TYPE_CODE IN ('FTEPRICE','FTECHARGE')
        AND p_line_adj_rec.charge_type_code(i) IN ('FTEPRICE','FTECHARGE')
        AND list_line_type_code = 'COST'
        AND p_line_adj_rec.list_line_type_code(i) = 'COST'
        AND ESTIMATED_FLAG = 'Y';
    --bug 4558089

    FORALL i IN p_line_adj_rec.line_id.FIRST..p_line_adj_rec.line_id.LAST
      INSERT INTO OE_PRICE_ADJUSTMENTS
      ( price_adjustment_id
       ,cost_id
       ,automatic_flag
       ,list_line_type_code
       ,charge_type_code
       ,header_id
       ,line_id
       ,adjusted_amount
       ,arithmetic_operator
       ,last_update_date
       ,last_updated_by
       ,last_update_login
       ,creation_date
       ,created_by)
       VALUES
       ( OE_PRICE_ADJUSTMENTS_S.nextval
        ,p_line_adj_rec.cost_id(i)
        ,p_line_adj_rec.automatic_flag(i)
        ,p_line_adj_rec.list_line_type_code(i)
        ,p_line_adj_rec.charge_type_code(i)
        ,p_line_adj_rec.header_id(i)
        ,p_line_adj_rec.line_id(i)
        ,p_line_adj_rec.adjusted_amount(i)
        ,p_line_adj_rec.arithmetic_operator(i)
        ,SYSDATE
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
        ,SYSDATE
        ,FND_GLOBAL.USER_ID)
       RETURNING price_adjustment_id
       BULK COLLECT
       INTO  p_line_adj_rec.price_adjustment_id;
  END IF;


  --------- seperate bulk and non bulk mode -----------

  IF p_bulk_mode = 'Y' THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('calling handle_bulk_mode '
                       || p_start_index ||'-'|| p_end_index, 1);
    END IF;

    Handle_Bulk_Mode
    (p_ship_line_rec    => p_ship_line_rec
    ,p_line_adj_rec     => p_line_adj_rec
    ,p_start_index      => p_start_index
    ,p_end_index        => p_end_index
    ,x_return_status    => x_return_status );

  ELSE

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('calling handle_NONbulk_mode '
                       || p_start_index ||'-'|| p_end_index, 5);
    END IF;

    Handle_NonBulk_Mode
    (p_ship_line_rec      => p_ship_line_rec
    ,p_requested_line_rec => p_requested_line_rec
    ,x_return_status      => x_return_status );

  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
     x_return_status is NULL THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('leaving Ship_Confirm_New', 2);
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ship_confirm_new EXC ERROR: '||SQLERRM,1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

    OE_MSG_PUB.Count_And_Get
    (p_count       => x_msg_count
    ,p_data        => x_msg_data);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('rollback to om_ship_confirm',1);
    END IF;
    ROLLBACK to om_ship_confirm;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ship_confirm_new UNEXPECTED ERROR : '||SQLERRM, 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    OE_MSG_PUB.Count_And_Get
    (p_count       => x_msg_count
    ,p_data        => x_msg_data);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('rollback to om_ship_confirm : ',1);
    END IF;
    ROLLBACK to om_ship_confirm;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('IN ship_confirm_new OTHERS ' || sqlerrm, 1);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
        ,'ship_confirm_new');
    END IF;

    OE_MSG_PUB.Count_And_Get
    (p_count       => x_msg_count
    ,p_data        => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('rollback to om_ship_confirm : ',1);
    END IF;
    ROLLBACK to om_ship_confirm;
END Ship_Confirm_New;

/*-------------------------------------------------------------
PROCEDURE Call_Notification_Framework

Call this procedure to handle the Notification_Framework call
instead of scattering the code all over acorss different
procedures.

not using p_line_rec and p_old_line_rec, will support if
needed - it will take more local variable declarations and copy of
tables.

if p_index is sent in, work on only one record.
p_start_index and p_end_index are passed in case iof handle_bulk.
if they are not passes, loop over the entire ship_line_rec.

Change Record:
Bug 3730537 - ***
--------------------------------------------------------------*/
PROCEDURE Call_Notification_Framework
( p_ship_line_rec  IN  Ship_Line_Rec_Type
 ,p_index          IN  NUMBER := NULL
 ,p_start_index    IN  NUMBER := NULL
 ,p_end_index      IN  NUMBER := NULL
 ,p_caller         IN  VARCHAR2)
IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_line_rec         OE_Order_Pub.Line_Rec_Type;
  l_old_line_rec     OE_Order_Pub.Line_Rec_Type;
  l_start_time       NUMBER;
  l_end_time         NUMBER;
  I                  NUMBER;
  J                  NUMBER;
  l_end_index        NUMBER;
  l_return_status    VARCHAR2(1);
BEGIN

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('entering Call_Notification_Framework ' || p_caller, 3);
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Commented for bug 8799963
  /*IF NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'N' THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('returning from Call_Notification_Framework ', 3);
    END IF;

    RETURN;
  END IF;*/

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_start_time from v$timer;
   end if;

  IF p_index is NULL THEN
    IF p_start_index is NULL THEN -- non bulk
      I           := p_ship_line_rec.line_id.FIRST;
      l_end_index := p_ship_line_rec.line_id.LAST + 1;
    ELSE
      I           := p_start_index;
      l_end_index := p_end_index + 1;
    END If;
  ELSE -- one record only
    I             := p_index;
    l_end_index   := p_index + 1;
  END IF;


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('p_start_index is ' || p_start_index
                      ||' p_end_index is ' || p_end_index
                      ||' l_end_index is ' || l_end_index, 3);
  END IF;

  WHILE I <> l_end_index
  LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(I || 'line_id : ' || l_line_rec.line_id, 3);
      oe_debug_pub.add('ord qty : ' || p_ship_line_rec.ordered_quantity(I), 3);
      oe_debug_pub.add('ship qty: ' || l_line_rec.shipped_quantity, 3);
    END IF;

    l_line_rec.line_id    :=  p_ship_line_rec.line_id(I);
    l_line_rec.header_id  :=  p_ship_line_rec.header_id(I);

    l_line_rec.shipping_quantity  := p_ship_line_rec.shipping_quantity(I);
    l_line_rec.shipping_quantity2 := p_ship_line_rec.shipping_quantity2(I);
    -- l_line_rec.shipped_quantity2  := p_ship_line_rec.ordered_quantity2(I); -- INVCONV

    l_line_rec.shipping_quantity_uom
                 := p_ship_line_rec.shipping_quantity_uom(I);
    l_line_rec.shipping_quantity_uom2
                 := p_ship_line_rec.shipping_quantity_uom2(I);
    l_line_rec.actual_shipment_date
                 := p_ship_line_rec.actual_shipment_date(I);

    IF p_caller = 'HANDLE_BULK' THEN
      l_line_rec.flow_status_code := 'SHIPPED';
      l_line_rec.shipped_quantity := p_ship_line_rec.ordered_quantity(I);
      l_line_rec.shipped_quantity2 := p_ship_line_rec.ordered_quantity2(I); -- INVCONV
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('bulk:inside setting shipped qty '
                          || l_line_rec.shipped_quantity, 3);

        oe_debug_pub.add('bulk:inside setting shipped qty2 '   -- INVCONV
                          || l_line_rec.shipped_quantity2, 3);
      END IF;

    ELSIF p_caller = 'HANDLE_BULK_FAILURE' THEN
      l_line_rec.shipping_quantity      := null;
      l_line_rec.shipping_quantity2     := null;
      l_line_rec.shipped_quantity2      := null;
      l_line_rec.shipped_quantity       := null;
      l_line_rec.shipping_quantity_uom  := null;
      l_line_rec.shipping_quantity_uom2 := null;
      l_line_rec.actual_shipment_date   := null;
      l_line_rec.flow_status_code       := p_ship_line_rec.flow_status_code(i);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('bulk failure:inside setting shipped qty '
                          || l_line_rec.shipped_quantity, 3);
      END IF;
    ELSIF p_caller = 'HANDLE_NON_BULK' OR
          p_caller = 'SHIP_CONFIRM_SPLIT_LINES' THEN
      l_line_rec.shipped_quantity   := p_ship_line_rec.shipped_quantity(I);
      l_line_rec.shipped_quantity2   := p_ship_line_rec.shipped_quantity2(I); -- INVCONV
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('non bulk:inside setting shipped qty '
                          || l_line_rec.shipped_quantity, 3);
        oe_debug_pub.add('non bulk:inside setting shipped qty2 ' -- INVCONV
                          || l_line_rec.shipped_quantity2, 3);

      END IF;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('update GLOBAL FLOW_STATUS is: '||l_line_rec.flow_status_code,3);
    END IF;

    OE_ORDER_UTIL.Update_Global_Picture
    (p_Upd_New_Rec_If_Exists => False,
     --p_header_id             => l_line_rec.header_id,
     p_old_line_rec          => l_old_line_rec,
     p_line_rec              => l_line_rec,
     p_line_id               => l_line_rec.line_id,
     x_index                 => J,
     x_return_status         => l_return_status);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(J || ' UPDATE_GLOBAL ret sts: ' || l_retuRN_STATUS);
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR
       l_return_status is NULL THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF J IS NOT NULL THEN

      OE_ORDER_UTIL.g_line_tbl(J)
                := OE_ORDER_UTIL.g_old_line_tbl(J);

      OE_ORDER_UTIL.g_line_tbl(J).line_id  := l_line_rec.line_id;
      OE_ORDER_UTIL.g_line_tbl(J).header_id:= l_line_rec.header_id;
      OE_ORDER_UTIL.g_line_tbl(J).last_update_date := SYSDATE;
      OE_ORDER_UTIL.g_line_tbl(J).last_updated_by  := FND_GLOBAL.USER_ID;
      OE_ORDER_UTIL.g_line_tbl(J).last_update_login:= FND_GLOBAL.LOGIN_ID;


      OE_ORDER_UTIL.g_line_tbl(J).shipping_quantity
                  := l_line_rec.shipping_quantity;
      OE_ORDER_UTIL.g_line_tbl(J).shipping_quantity2
                  := l_line_rec.shipping_quantity2;
      OE_ORDER_UTIL.g_line_tbl(J).shipped_quantity2
                  := l_line_rec.shipped_quantity2;
      OE_ORDER_UTIL.g_line_tbl(J).shipped_quantity
                  := l_line_rec.shipped_quantity;
      OE_ORDER_UTIL.g_line_tbl(J).shipping_quantity_uom
                  := l_line_rec.shipping_quantity_uom;
      OE_ORDER_UTIL.g_line_tbl(J).shipping_quantity_uom2
                  := l_line_rec.shipping_quantity_uom2;
      OE_ORDER_UTIL.g_line_tbl(J).actual_shipment_date
                  := l_line_rec.actual_shipment_date;
      OE_ORDER_UTIL.g_line_tbl(J).flow_status_code
                  := l_line_rec.flow_status_code;
      OE_ORDER_UTIL.g_line_tbl(J).operation
                  := OE_GLOBALS.G_OPR_UPDATE;  -- Bug 8442372

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('AFTER UPDATE GLOBAL FLOW_STATUS_CODE IS: '
         || OE_ORDER_UTIL.G_LINE_TBL( J ).FLOW_STATUS_CODE ,1);
      END IF;

    END IF; -- if index is not null

    I := I + 1; -- should not be an gaps in the ship_line_rec

  END LOOP; -- loop over ship line rec

   -- Bug 5640601 =>
   -- Selecting hsecs from v$times is changed to execute only when debug
   -- is enabled, as hsec is used for logging only when debug is enabled.
   IF l_debug_level > 0 Then
     SELECT hsecs INTO l_end_time from v$timer;
   end if;

  FND_FILE.PUT_LINE
  (FND_FILE.LOG,'Time spent in notification framework is (sec) '
   ||((l_end_time-l_start_time)/100));

EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Call_Notification_Framework' || sqlerrm, 1);
    END IF;
    RAISE;
END Call_Notification_Framework;

--ER number 7360612
/*#
* This API ship confirms a line with zero shipped quantity and completes the
* SHIP_LINE (Ship) workflow activity, provided that tolerances across the line
* set for the input line are met. Parameter x_return_status reports API success
* or failure, and x_result_out narrows down the cause of failure.
* @param p_line_id      Input value of line id to be shipped with zero quantity
* @param x_result_out   Returns reason for failure (W = Workflow not at Ship:Notified,T = Tolerances not met, D = Delivery details
already shipped)
* @param x_return_status   Return status (S = Success, E = Error, U = Unexpected Error)
* @param x_msg_count  Returns number of mesages generated while executing the API
* @param x_msg_data  Returns text of messages generated
* @rep:scope               public
* @rep:lifecycle           active
* @rep:displayname         Ship Confirm with Zero Quantity
*/
PROCEDURE Ship_Zero
( p_line_id  	   IN		NUMBER,
  x_result_out	   OUT		NOCOPY VARCHAR2,
  x_return_status  IN OUT	NOCOPY VARCHAR2,
  x_msg_count      OUT             NOCOPY   NUMBER,
  x_msg_data       OUT             NOCOPY   VARCHAR2
)
IS

  l_update_lines_tbl  OE_ORDER_PUB.Request_Tbl_Type;
  l_line_rec          OE_ORDER_PUB.line_rec_type;
  l_tolerance_check   VARCHAR2(256);
  l_count             NUMBER DEFAULT 0;
  l_return_status     VARCHAR2(256);

BEGIN
   x_result_out := 'S';
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --query row
  OE_Line_Util.Query_Row
  (
    p_line_id   => p_line_id,
    x_line_rec  => l_line_rec
  );
  --check line status
  --IF (l_line_rec.flow_status_code <> 'AWAITING_SHIPPING')
  --THEN
  --  x_result_out := 'F';
  --  RAISE FND_API.G_EXC_ERROR;
  --END IF;
  l_count := 0;
  select  Count (1)
  INTO    l_count
  from    wf_item_activity_statuses wias, wf_process_activities wpa
  where   wias.process_activity = wpa.instance_id
  and     to_number(wias.item_key) = p_line_id
  and     wias.item_type = 'OEOL'
  AND     wpa.activity_item_type = wias.item_type
  and     wias.activity_status = 'NOTIFIED'
  and     wpa.activity_name = 'SHIP_LINE';

  IF (l_count < 1)
  THEN
    x_result_out := 'W';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_Shipping_Integration_PVT.Check_Shipment_Line
  (
    p_line_rec          =>   l_line_rec,
    x_result_out        =>   l_tolerance_check
  );

  IF (  l_tolerance_check NOT IN (  OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW,
                                    OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE,
                                    OE_GLOBALS.G_FULLY_SHIPPED,
                                    OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE)
     )
  THEN
    x_result_out := 'T';
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_count := 0;
  SELECT  Count(1)
  INTO    l_count
  FROM    wsh_delivery_details
  WHERE   source_line_id  = p_line_id
  AND     released_status = 'C';

  IF (l_count > 0 )
  THEN
    x_result_out := 'D';
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --prepare call to shipping API
  l_update_lines_tbl(1).entity_id := p_line_id;
  l_update_lines_tbl(1).param1  := FND_API.G_FALSE;
  l_update_lines_tbl(1).param2  := FND_API.G_FALSE;
  l_update_lines_tbl(1).param5  := FND_API.G_TRUE;
  l_update_lines_tbl(1).request_type := OE_GLOBALS.G_OPR_UPDATE;

  --Step 4 : Call shipping integration
  OE_Shipping_Integration_PVT.Update_Shipping_From_OE
  (
    p_update_lines_tbl  =>  l_update_lines_tbl,
    x_return_status     =>  l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
  (
      p_request_type   =>OE_GLOBALS.G_COMPLETE_ACTIVITY
    ,p_delete        => FND_API.G_TRUE
    ,x_return_status => l_return_status
 );
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_result_out := 'U';
    OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END ship_zero;

END OE_Ship_Confirmation_Pub;

/
