--------------------------------------------------------
--  DDL for Package Body OE_SHIPPING_TOLERANCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIPPING_TOLERANCES_PUB" AS
/* $Header: OEXPTOLB.pls 120.0 2005/06/01 01:45:33 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Shipping_Tolerances_PUB';

--  Start of Comments
--  API name    OE_Shipping_Tolerances_PUB
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

-- HW added qty2 for OPM in the procedure parameters
-- INVCONV - NOT SURE IF NEED TO CHANGE THESE

PROCEDURE Get_Min_Max_Tolerance_Quantity
(
     p_api_version_number	IN  NUMBER
,    p_line_id			IN  NUMBER
,    x_min_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_min_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_msg_data			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS

	l_api_version_number	CONSTANT NUMBER := 1.0;
	l_api_name		CONSTANT VARCHAR2(30) := 'Get_Min_Max_Tolerance_Quantity';
	l_line_set_id		        NUMBER;
	l_ship_tolerance_above	        NUMBER;
	l_ship_tolerance_below	        NUMBER;
	l_tolerance_quantity_below	NUMBER;
	l_tolerance_quantity_above	NUMBER;

	l_ordered_quantity		NUMBER;
	l_shipped_quantity		NUMBER;
	l_shipping_quantity		NUMBER;
	l_min_quantity_remaining	NUMBER;
	l_max_quantity_remaining	NUMBER;
-- HW OPM added qty2 for OPM
	l_ordered_quantity2		NUMBER;
	l_shipped_quantity2		NUMBER;
	l_shipping_quantity2		NUMBER;
	l_min_quantity_remaining2	NUMBER;
	l_max_quantity_remaining2	NUMBER;

        l_top_model_line_id             NUMBER;
        l_ato_line_id                   NUMBER;
        l_order_quantity_uom            VARCHAR2(3);
        l_shipping_quantity_uom         VARCHAR2(3);
        l_del_shipping_quantity         NUMBER;
        l_del_shipped_quantity          NUMBER;
--       l_del_shipping_quantity2        NUMBER;  -- INVCONV not used
--        l_del_shipped_quantity2         NUMBER; -- INVCONV not used

        l_count_unshipped               NUMBER;
        l_item_rec                      OE_ORDER_CACHE.item_rec_type;
        l_OPM_shipped_quantity          NUMBER(19,9);
        l_OPM_shipping_quantity_uom     VARCHAR2(4);
        l_OPM_order_quantity_uom        VARCHAR2(4);
        l_inventory_item_id             NUMBER;
        l_ship_from_org_id              NUMBER;

        l_status                        VARCHAR2(1);

        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(2000);

        l_validated_quantity            NUMBER;
        l_primary_quantity              NUMBER;
        l_qty_return_status             VARCHAR2(1);

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_TOLERANCES_PUB.GET_MIN_MAX_TOLERANCE_QUANTITY' , 1 ) ;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
    	IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    	THEN
       	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
*/
-- HW OPM retrieve qty2 for OPM
	SELECT	ship_tolerance_below,
		ship_tolerance_above,
		line_set_id,
		ordered_quantity,
		shipped_quantity,
		ordered_quantity2,
		shipped_quantity2,
                top_model_line_id,
                ato_line_id,
                order_quantity_uom,
                ship_from_org_id,
                inventory_item_id
	INTO	l_ship_tolerance_below,
		l_ship_tolerance_above,
		l_line_set_id,
		l_ordered_quantity,
		l_shipped_quantity,
		l_ordered_quantity2,
		l_shipped_quantity2,
                l_top_model_line_id,
                l_ato_line_id,
                l_order_quantity_uom,
                l_ship_from_org_id,
                l_inventory_item_id
	FROM	OE_ORDER_LINES_ALL
	WHERE	line_id = p_line_id;
/* Comented for bug 2193139
        IF  nvl(l_top_model_line_id,-1) = nvl(l_ato_line_id,-1) AND
            l_top_model_line_id IS NOT NULL THEN

            oe_debug_pub.add('It is a ATO MODEL ',3);

            SELECT  line_set_id
            INTO    l_line_set_id
            FROM    OE_ORDER_LINES_ALL
            WHERE   line_id = l_top_model_line_id;

            oe_debug_pub.add('Line set id : '||l_line_set_id,3);

        END IF;
*/
	IF  l_line_set_id IS NOT NULL THEN
-- HW Sum qty2 for OPM
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE SET ID : '||L_LINE_SET_ID , 3 ) ;
		END IF;
		SELECT	SUM(ordered_quantity)
		,	SUM(nvl(shipped_quantity,0))
		,	SUM(nvl(shipping_quantity,0))
		,       SUM(nvl(ordered_quantity2,0))
		,	SUM(nvl(shipped_quantity2,0))
		,	SUM(nvl(shipping_quantity2,0))
		INTO    l_ordered_quantity
		,	l_shipped_quantity
		,	l_shipping_quantity
		,       l_ordered_quantity2
		,	l_shipped_quantity2
		,	l_shipping_quantity2
		FROM	oe_order_lines_all
		WHERE 	line_set_id	= l_line_set_id;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'ORDER LINE SHIPPED QUANTITY '||L_SHIPPED_QUANTITY , 3 ) ;
                    oe_debug_pub.add(  'ORDER LINE SHIPPED QUANTITY2 '||L_SHIPPED_QUANTITY2 , 3 ) ; -- INVCONV
                END IF;
                SELECT  count(*)
                INTO    l_count_unshipped
                FROM    oe_order_lines_all
                WHERE   line_set_id = l_line_set_id
                AND     shipped_quantity IS NULL
                AND     line_id <> p_line_id ;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'COUNT '||L_COUNT_UNSHIPPED , 3 ) ;
                END IF;

                IF  nvl(l_count_unshipped,0) > 0 THEN

                    BEGIN

                    SELECT nvl(sum(shipped_quantity),0),requested_quantity_uom
                    INTO   l_del_shipping_quantity,l_shipping_quantity_uom
                    FROM   wsh_delivery_details
                    where  source_line_id in (SELECT line_id
                                              FROM   oe_order_lines_all
                                              WHERE  line_set_id = l_line_set_id
                                              AND     shipped_quantity IS NULL
                                              AND     line_id <> p_line_id)
                    and   source_code = 'OE'
                    group by requested_quantity_uom;

                    EXCEPTION

                        WHEN NO_DATA_FOUND THEN
                             l_del_shipping_quantity := 0;
                             l_shipping_quantity_uom := l_order_quantity_uom;

                    END;

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'DELIVERY SHIPPING QUANTITY/UOM '||L_DEL_SHIPPING_QUANTITY||'/'||L_SHIPPING_QUANTITY_UOM , 3 ) ;
                    END IF;


                    IF  l_order_quantity_uom <> l_shipping_quantity_uom AND
                        nvl(l_del_shipping_quantity,0) <> 0 THEN

/*                         IF oe_line_util.Process_Characteristics -- INVCONV NOT NEEDED NOW FOR OPM CONVERGENCE
                           (l_inventory_item_id
                           ,l_ship_from_org_id
                           ,l_item_rec) THEN

-- PAL Feb 2003 2683316 - changed the call to GMI uom_conversion and Get_OPMUOM_from_AppsUOM above to
-- get_opm_converted_qty to resolve rounding issues


 			   l_OPM_shipped_quantity := GMI_Reservation_Util.get_opm_converted_qty(
              			p_apps_item_id    => l_inventory_item_id,
              			p_organization_id => l_ship_from_org_id,
              			p_apps_from_uom   => l_shipping_quantity_uom,
              			p_apps_to_uom     => l_order_quantity_uom,
              			p_original_qty    => l_del_shipping_quantity);

      oe_debug_pub.add('OPM shipped quantity in proc Get_Min_Max_Tolerance_Quantity after new get_opm_converted_qty is  '||l_OPM_shipped_quantity, 5);

                           l_del_shipped_quantity := l_OPM_shipped_quantity ;

-- HW This line is discrete
	                ELSE     */
		            l_del_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
                            (
                             l_inventory_item_id,
                             l_shipping_quantity_uom,
                             l_order_quantity_uom,
                             l_del_shipping_quantity
                             );
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'CONVERTED SHIPPED QUANTITY : '|| L_DEL_SHIPPED_QUANTITY , 3 ) ;
                            END IF;

                   --     END IF; -- HW end of branching INVCONV

                        IF l_del_shipped_quantity <> trunc(l_del_shipped_quantity) THEN

                           Inv_Decimals_PUB.Validate_Quantity
                           (
                           p_item_id	         => l_inventory_item_id,
                           p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
                           p_input_quantity   => l_del_shipped_quantity,
                           p_uom_code         => l_order_quantity_uom,
                           x_output_quantity  => l_validated_quantity,
                           x_primary_quantity => l_primary_quantity,
                           x_return_status    => l_qty_return_status
                           );

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'RETURN STATUS FROM INV API : '||L_QTY_RETURN_STATUS , 1 ) ;
                           END IF;
                           IF l_qty_return_status = 'W' THEN

                              l_del_shipped_quantity := l_validated_quantity;

                           END IF;
                        END IF;

                    ELSE

                        l_del_shipped_quantity := l_del_shipping_quantity;

                    END IF; /* not same UOM */

                    l_shipped_quantity := l_shipped_quantity + l_del_shipped_quantity;

                END IF;/* Unshipped lines */

	END IF;/*line set */

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_ORDERED_QUANTITY ) , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'TOTAL SHIPPED QUANTITY : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
	END IF;

	l_tolerance_quantity_below	:=	nvl(l_ordered_quantity,0)*nvl(l_ship_tolerance_below,0)/100;
	l_tolerance_quantity_above	:=	nvl(l_ordered_quantity,0)*nvl(l_ship_tolerance_above,0)/100;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'TOLERANCE QUANTITY BELOW : '||L_TOLERANCE_QUANTITY_BELOW , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'TOLERANCE QUANTITY ABOVE : '||L_TOLERANCE_QUANTITY_ABOVE , 3 ) ;
	END IF;

	l_min_quantity_remaining := l_ordered_quantity - nvl(l_shipped_quantity,0) - l_tolerance_quantity_below;
	l_max_quantity_remaining := l_ordered_quantity - nvl(l_shipped_quantity,0) + l_tolerance_quantity_above;

-- HW Get min and max qty2 for OPM
	l_min_quantity_remaining2 := nvl(l_ordered_quantity2,0) - nvl(l_shipped_quantity2,0) - l_tolerance_quantity_below;
	l_max_quantity_remaining2 := nvl(l_ordered_quantity2,0) - nvl(l_shipped_quantity2,0) + l_tolerance_quantity_above;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'MIN REMAINING QUANTITY : '||L_MIN_QUANTITY_REMAINING , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'MAX REMAINING QUANTITY : '||L_MAX_QUANTITY_REMAINING , 3 ) ;
	END IF;

-- HW Print Qty2 for OPM
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'MIN REMAINING QUANTITY2 : '||L_MIN_QUANTITY_REMAINING2 , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'MAX REMAINING QUANTITY2 : '||L_MAX_QUANTITY_REMAINING2 , 3 ) ;
	END IF;

	IF	l_min_quantity_remaining < 0 THEN

		l_min_quantity_remaining := 0;

	END IF;

	IF	l_min_quantity_remaining2 < 0 THEN
-- HW reset qty2 for OPM
                l_min_quantity_remaining2 := 0;

	END IF;

	IF	l_max_quantity_remaining < 0 THEN

		l_max_quantity_remaining := 0;
	END IF;

	IF	l_max_quantity_remaining2 < 0 THEN
-- HW reset qty2 for OPM
		l_max_quantity_remaining2 := 0;

	END IF;

	x_min_remaining_quantity := l_min_quantity_remaining;
	x_max_remaining_quantity := l_max_quantity_remaining;

-- HW added qty2 for OPM
	x_min_remaining_quantity2 := nvl(l_min_quantity_remaining2,0);
	x_max_remaining_quantity2 := nvl(l_max_quantity_remaining2,0);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MIN REMAINING QUANTITY : '||X_MIN_REMAINING_QUANTITY , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MAX REMAINING QUANTITY : '||X_MAX_REMAINING_QUANTITY , 3 ) ;
	END IF;

-- HW print qty2 for OPM
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MIN REMAINING QUANTITY2 : '||X_MIN_REMAINING_QUANTITY2 , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MAX REMAINING QUANTITY2 : '||X_MAX_REMAINING_QUANTITY2 , 3 ) ;
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_TOLERANCES_PUB.GET_MIN_MAX_TOLERANCE_QUANTITY '||X_RETURN_STATUS , 1 ) ;
	END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN

	x_min_remaining_quantity := 0;
	x_max_remaining_quantity := 0;

-- HW reset values for qty2 for OPM
        x_min_remaining_quantity2 := 0;
	x_max_remaining_quantity2 := 0;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	WHEN OTHERS THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
		END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Min_Max_Tolerance_Quantity'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Min_Max_Tolerance_Quantity;

PROCEDURE Get_Min_Max_quantity_Uom
(
     p_api_version_number	IN  NUMBER
,    p_line_id			IN  NUMBER
,    x_min_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_quantity_uom             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_min_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_max_remaining_quantity2	OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_quantity_uom2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER
,    x_msg_data			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.GET_MIN_MAX_QUANTITY_UOM' , 1 ) ;
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        OE_Shipping_Tolerances_PUB.Get_Min_Max_Tolerance_Quantity
        (
        p_api_version_number      => p_api_version_number,
        p_line_id                 => p_line_id,
        x_min_remaining_quantity  => x_min_remaining_quantity,
        x_max_remaining_quantity  => x_max_remaining_quantity,
        x_min_remaining_quantity2 => x_min_remaining_quantity2,
        x_max_remaining_quantity2 => x_max_remaining_quantity2,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
        );

        SELECT order_quantity_uom,
               ordered_quantity_uom2
        INTO   x_quantity_uom,
               x_quantity_uom2
        FROM   oe_order_lines_all
        WHERE  line_id = p_line_id;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MIN REMAINING QUANTITY : '||X_MIN_REMAINING_QUANTITY , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MAX REMAINING QUANTITY : '||X_MAX_REMAINING_QUANTITY , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MIN REMAINING QUANTITY2 : '||X_MIN_REMAINING_QUANTITY2 , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN MAX REMAINING QUANTITY2 : '||X_MAX_REMAINING_QUANTITY2 , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN QUANTITY UOM : '||X_QUANTITY_UOM , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN QUANTITY UOM2 : '||X_QUANTITY_UOM2 , 3 ) ;
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PUB.GET_MIN_MAX_QUANTITY_UOM '||X_RETURN_STATUS , 1 ) ;
	END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN

	x_min_remaining_quantity := 0;
	x_max_remaining_quantity := 0;

        x_min_remaining_quantity2 := 0;
	x_max_remaining_quantity2 := 0;

        x_quantity_uom := '';
        x_quantity_uom2 := '';

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	WHEN OTHERS THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
		END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Min_Max_Quantity_Uom'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Get_Min_Max_Quantity_Uom;

END OE_Shipping_Tolerances_PUB;


/
