--------------------------------------------------------
--  DDL for Package Body OE_SHIPPING_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIPPING_INTEGRATION_PUB" AS
/* $Header: OEXPSHPB.pls 120.0.12010000.2 2009/08/14 08:34:44 sahvivek ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Shipping_Integration_PUB';

--  Start of Comments
--  API name    OE_Shipping_Integration_PUB
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

/*
	This function returns FND_API.G_TRUE, if the line's next eligible WF
	activity is "SHIP_LINE", otherwise returns FND_API.G_FALSE
*/

FUNCTION Is_Activity_Shipping
(
	p_api_version_number		IN	NUMBER
,	p_line_id					IN	NUMBER
) return VARCHAR2
IS
	l_count							NUMBER := 0;
	l_api_version_number	CONSTANT NUMBER := 1.0;
	l_api_name				CONSTANT VARCHAR2(30) := 'Is_Activity_Shipping';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


        select count(*)
          into l_count
          from wf_item_activity_statuses wias,
               wf_process_activities wpa
         where wias.item_type = 'OEOL'
           and wias.item_key = to_char(p_line_id)
           and wias.ACTIVITY_STATUS = 'NOTIFIED'
           and wias.process_activity = wpa.instance_id
           and wpa.activity_name = 'SHIP_LINE';

	IF l_count > 0 THEN
		return FND_API.G_TRUE;
	ELSE
		return FND_API.G_FALSE;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        return FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

END Is_Activity_Shipping;

/*
	This procedure releases the BLOCK on "SHIP_LINE" activity. This Procedure
	will be called whenever "SHIPPED_QUANTITY" column in OE_ORDER_LINES is
	updated or a non-shippable line reaches the SHIP_LINE activity.
*/

PROCEDURE Complete_Ship_Line_Activity
(   p_api_version_number		IN      NUMBER
,   p_line_id                   IN      NUMBER
,   p_result_code				IN		VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
) IS
	l_api_version_number	CONSTANT	NUMBER := 1.0;
	l_api_name				CONSTANT	VARCHAR2(30) := 'Complete_Ship_Line_Activity';
	l_errname					VARCHAR2(30);
	l_errmsg					VARCHAR2(2000);
	l_errstack					VARCHAR2(2000);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    --  Standard call to check for call compatibility
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.COMPLETE_SHIP_LINE_ACTIVITY '|| TO_CHAR ( P_LINE_ID ) ||' '||P_RESULT_CODE , 1 ) ;
	END IF;

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF OE_Validate.Line(p_line_id)
    THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CALLING WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( P_LINE_ID ) , 2 ) ;
		END IF;
        wf_engine.CompleteActivityInternalName('OEOL', to_char(p_line_id), 'SHIP_LINE', p_result_code);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURNED FROM WF_ENGINE.COMPLETEACTIVITYINTERNALNAME '|| TO_CHAR ( P_LINE_ID ) , 2 ) ;
		END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PUB.COMPLETE_SHIP_LINE_ACTIVITY '|| TO_CHAR ( P_LINE_ID ) , 1 ) ;
	END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

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
		    oe_debug_pub.add(  'WORK FLOW ERROR HAS OCCURED '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
		END IF;

		WF_CORE.Get_Error(l_errname, l_errmsg, l_errstack);
		IF	l_errname IS NOT NULL THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ERROR MESSAGE '||L_ERRMSG , 1 ) ;
			END IF;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		ELSE
        	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
           	 FND_MSG_PUB.Add_Exc_Msg
           	 (   G_PKG_NAME
           	 ,   'Complete_Ship_Line_Activity'
           	 );
        	END IF;

        	--  Get message count and data

        	FND_MSG_PUB.Count_And_Get
        	(   p_count                       => x_msg_count
        	,   p_data                        => x_msg_data
        	);
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		END IF;

END Complete_Ship_Line_Activity;


/* Returns FND_API_G_TRUE if credit check passes,
		   FND_API.G_FALSE if credit check fails */
/** This function is not used ******/
FUNCTION Credit_Check
(
	p_api_version_number			IN	NUMBER
,	p_header_id						IN	NUMBER
,	p_line_id						IN	NUMBER	DEFAULT NULL
) return VARCHAR2
IS
	l_x_result_out						VARCHAR2(80);
	l_x_return_status					VARCHAR2(1);
	l_x_msg_count						NUMBER;
	l_x_msg_data						VARCHAR2(2000);
	l_api_version_number	CONSTANT	NUMBER := 1.0;
	l_api_name				CONSTANT	VARCHAR2(30) := 'Credit_Check';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
/*
	OE_Credit_PUB.Check_Available_Credit
	(
	 p_header_id       	=> p_header_id,
	 p_msg_count        => l_x_msg_count,
	 p_msg_data         => l_x_msg_data,
	 p_result_out		=> l_x_result_out,
	 p_return_status	=> l_x_return_status
	);
	IF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
*/
	IF UPPER(l_x_result_out) = 'PASS' THEN
		return FND_API.G_TRUE;
	ELSE
		return FND_API.G_FALSE;
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        return FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

END Credit_Check;

/*
	If this funtion returns FND_API.G_TRUE, a hold exists on this line.
	If this funtion returns FND_API.G_FALSE, a hold does not exists
	on this line.
*/

FUNCTION Check_Holds_For_SC
(
	p_api_version_number		IN	NUMBER
,	p_header_id					IN	NUMBER	DEFAULT NULL
,	p_line_id					IN	NUMBER
) return VARCHAR2
IS
	l_x_result_out					VARCHAR2(1);
	l_x_return_status				VARCHAR2(1);
	l_x_msg_count					NUMBER;
	l_x_msg_data					VARCHAR2(2000);
	l_credit_check_pass				VARCHAR2(1);
	l_api_version_number	CONSTANT NUMBER := 1.0;
	l_api_name				CONSTANT VARCHAR2(30) := 'Check_Holds_For_SC';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	OE_Holds_PUB.Check_Holds
	(
	 p_api_version          => 1.0,
	 p_line_id              => p_line_id,
	 x_result_out           => l_x_result_out,
	 x_return_status        => l_x_return_status,
	 x_msg_count            => l_x_msg_count,
	 x_msg_data             => l_x_msg_data
	);
	IF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	return l_x_result_out;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        return FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        return FND_API.G_RET_STS_UNEXP_ERROR ;

END Check_Holds_For_SC;


/*
	This procedure will return the ship_tolerance_above and ship_tolerance_below
    for a passed line id
*/

PROCEDURE Get_Tolerance
(
	 p_api_version_number		IN	NUMBER
,    p_cal_tolerance_tbl		IN	Cal_Tolerance_Tbl_Type
,	 x_update_tolerance_flag	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_ship_tolerance			OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_ship_beyond_tolerance	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,	 x_shipped_within_tolerance	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_config_broken			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
	l_api_version_number		CONSTANT NUMBER := 1.0;
	l_api_name					CONSTANT VARCHAR2(30) := 'Get_Tolerance';
	l_line_rec					OE_Order_Pub.Line_Rec_Type;
	l_line_tbl					OE_Order_Pub.Line_Tbl_Type;
	l_temp_line_tbl				OE_Order_Pub.Line_Tbl_Type;
	l_tbl_index					NUMBER;
	l_line_index				NUMBER;
	l_cal_tolerance_tbl			Cal_Tolerance_Tbl_Type;
	l_model_kit_line			VARCHAR2(1) := FND_API.G_FALSE;
	l_x_result_out				VARCHAR2(30);
	l_shipped_quantity			NUMBER := 0;
	l_ordered_quantity			NUMBER := 0;
	l_x_shipped_quantity		NUMBER := 0;
	l_x_shipping_quantity		NUMBER := 0;
	l_x_ordered_quantity		NUMBER := 0;
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);
	l_ship_tolerance			NUMBER := 0;
	l_x_return_status			VARCHAR2(1);
	l_top_model_line_id			NUMBER;
--	l_x_line_tbl				OE_Order_Pub.Line_Tbl_Type;
	l_ratio_status				VARCHAR2(1);
	l_planned_quantity_passed		VARCHAR2(1) := FND_API.G_FALSE;
	l_top_model_index			NUMBER := 0;

        l_count_unshipped                       NUMBER := 0;
        l_del_shipping_quantity                 NUMBER := 0;
	l_line_id_mod                           NUMBER; -- Bug 8795918

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.GET_TOLERANCE ' , 1 ) ;
	END IF;
    --  Standard call to check for call compatibility
	x_update_tolerance_flag := FND_API.G_FALSE;
	x_ship_beyond_tolerance := FND_API.G_FALSE;
	x_shipped_within_tolerance := FND_API.G_FALSE;
	x_config_broken			   := FND_API.G_FALSE;

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Convert the passed table

	FOR	l_tbl_index IN p_cal_tolerance_tbl.FIRST .. p_cal_tolerance_tbl.LAST
	LOOP
	        l_line_id_mod := mod(p_cal_tolerance_tbl(l_tbl_index).line_id,OE_GLOBALS.G_BINARY_LIMIT); -- Bug 8795918
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTERING THE CONVERT LOOP : ' || TO_CHAR ( L_TBL_INDEX ) , 3 ) ;
		END IF;
		/* Modified for bug 7833591
		l_cal_tolerance_tbl(p_cal_tolerance_tbl(l_tbl_index).line_id).line_id := p_cal_tolerance_tbl(l_tbl_index).line_id;
		l_cal_tolerance_tbl(p_cal_tolerance_tbl(l_tbl_index).line_id).quantity_to_be_shipped := p_cal_tolerance_tbl(l_tbl_index).quantity_to_be_shipped;*/
		l_cal_tolerance_tbl(l_line_id_mod).line_id := p_cal_tolerance_tbl(l_tbl_index).line_id;
		l_cal_tolerance_tbl(l_line_id_mod).quantity_to_be_shipped := p_cal_tolerance_tbl(l_tbl_index).quantity_to_be_shipped;

        /* to fix the bug 2127323 */
        IF p_cal_tolerance_tbl(l_tbl_index).planned_quantity = FND_API.G_MISS_NUM THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'PLANNED QUANTITY IS MISSING SETTING IT TO ZERO ' , 3 ) ;
           END IF;

           -- l_cal_tolerance_tbl(p_cal_tolerance_tbl(l_tbl_index).line_id).planned_quantity := 0; -- Bug 8795918
	   l_cal_tolerance_tbl(l_line_id_mod).planned_quantity := 0;

        END IF;

		-- l_cal_tolerance_tbl(p_cal_tolerance_tbl(l_tbl_index).line_id).shipping_uom := p_cal_tolerance_tbl(l_tbl_index).shipping_uom; -- Bug 8795918
		l_cal_tolerance_tbl(l_line_id_mod).shipping_uom := p_cal_tolerance_tbl(l_tbl_index).shipping_uom;
		IF	nvl(p_cal_tolerance_tbl(l_tbl_index).planned_quantity,0) <> 0 AND
                        p_cal_tolerance_tbl(l_tbl_index).planned_quantity <> FND_API.G_MISS_NUM THEN
			l_planned_quantity_passed := FND_API.G_TRUE;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIPPING UOM : '||P_CAL_TOLERANCE_TBL ( L_TBL_INDEX ) .SHIPPING_UOM , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'QUANTITY TO BE SHIPPED : '||TO_CHAR ( P_CAL_TOLERANCE_TBL ( L_TBL_INDEX ) .QUANTITY_TO_BE_SHIPPED ) , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'PLANNED QUANTITY : '||TO_CHAR ( P_CAL_TOLERANCE_TBL ( L_TBL_INDEX ) .PLANNED_QUANTITY ) , 3 ) ;
		END IF;

	END LOOP;

	FOR	l_tbl_index IN p_cal_tolerance_tbl.FIRST .. p_cal_tolerance_tbl.LAST
	LOOP

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTERING THE LOOP : ' || TO_CHAR ( L_TBL_INDEX ) , 2 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE ID : ' || TO_CHAR ( P_CAL_TOLERANCE_TBL ( L_TBL_INDEX ) .LINE_ID ) , 2 ) ;
		END IF;
--		l_line_rec := OE_Line_Util.Query_Row(p_cal_tolerance_tbl(l_tbl_index).line_id);
		OE_Line_Util.Query_Row(p_line_id	=> p_cal_tolerance_tbl(l_tbl_index).line_id,
						   x_line_rec	=> l_line_rec);
		IF	l_line_rec.top_model_line_id IS NOT NULL AND
			l_line_rec.top_model_line_id <> FND_API.G_MISS_NUM THEN

			l_model_kit_line := FND_API.G_TRUE;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'IT IS A MODEL/KIT LINE ' , 3 ) ;
			END IF;
			l_top_model_line_id := l_line_rec.top_model_line_id;

		END IF;
	NULL;
	END LOOP;

	IF	l_model_kit_line = FND_API.G_TRUE THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IT IS A MODEL/KIT LINE ' , 3 ) ;
		END IF;
--		l_line_tbl := OE_Config_Util.Query_Options(l_line_rec.top_model_line_id);
		OE_Config_Util.Query_Options(p_top_model_line_id	=>	l_line_rec.top_model_line_id,
								 	 x_line_tbl				=>	l_line_tbl);
		-- Get the top model line id index.

		FOR  l_line_index IN 1 .. l_line_tbl.count
		LOOP

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'INDEX/LINE_ID/TOP_MODEL_LINE_ID :'||TO_CHAR ( L_LINE_INDEX ) ||TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) ||TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .TOP_MODEL_LINE_ID ) , 3 ) ;
			END IF;
			IF	l_line_tbl(l_line_index).line_id = l_line_tbl(l_line_index).top_model_line_id THEN
				l_top_model_index := l_line_index;
				GOTO END_GET_TOP_MODEL;
			END IF;

		END LOOP;
		<< END_GET_TOP_MODEL >>

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'TOP MODEL INDEX : '||L_TOP_MODEL_INDEX , 3 ) ;
		END IF;

		l_temp_line_tbl := l_line_tbl;

		-- Assign the quantity to be shipped for shippable lines.
		FOR	l_line_index IN	l_line_tbl.FIRST .. l_line_tbl.LAST
		LOOP

		l_line_id_mod := mod(l_line_tbl(l_line_index).line_id,OE_GLOBALS.G_BINARY_LIMIT); -- Bug 8795918

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INSIDE THE MODEL LOOP '||TO_CHAR ( L_LINE_INDEX ) , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ITEM TYPE '||L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
		END IF;

		-- IF 	l_cal_tolerance_tbl.EXISTS(l_line_tbl(l_line_index).line_id) THEN -- Bug 8795918
		IF      l_cal_tolerance_tbl.EXISTS((l_line_id_mod)) THEN

			-- l_temp_line_tbl(l_line_index).shipping_quantity := nvl(l_line_tbl(l_line_index).shipping_quantity,0) + l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).quantity_to_be_shipped; -- Bug 8795918
			l_temp_line_tbl(l_line_index).shipping_quantity := nvl(l_line_tbl(l_line_index).shipping_quantity,0) + l_cal_tolerance_tbl(l_line_id_mod).quantity_to_be_shipped;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPING QUANTITY '|| TO_CHAR ( L_TEMP_LINE_TBL ( L_LINE_INDEX ) .SHIPPING_QUANTITY ) , 3 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ORDERED UOM '||L_LINE_TBL ( L_LINE_INDEX ) .ORDER_QUANTITY_UOM , 3 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPING UOM '||L_CAL_TOLERANCE_TBL ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) .SHIPPING_UOM , 3 ) ;
			END IF;
			-- IF	l_line_tbl(l_line_index).order_quantity_uom <> l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).shipping_uom THEN -- Bug 8795918
			IF      l_line_tbl(l_line_index).order_quantity_uom <> l_cal_tolerance_tbl(l_line_id_mod).shipping_uom THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'UOMS ARE DIFFRENT ' , 3 ) ;
				END IF;
				l_temp_line_tbl(l_line_index).shipped_quantity := OE_Order_Misc_Util.Convert_Uom
	  			(
		  		l_line_rec.inventory_item_id,
				l_cal_tolerance_tbl(l_line_id_mod).shipping_uom,
		  		-- l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).shipping_uom,-- Bug 8795918
		  		l_line_tbl(l_line_index).order_quantity_uom,
		  		l_temp_line_tbl(l_line_index).shipped_quantity
	  			);

			ELSE
				l_temp_line_tbl(l_line_index).shipped_quantity := l_temp_line_tbl(l_line_index).shipping_quantity;

			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY '|| TO_CHAR ( L_TEMP_LINE_TBL ( L_LINE_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
		END IF;

		END LOOP;

		-- Calculate the shipped quantity of top model line.
		OE_Shipping_Integration_PVT.Get_PTO_Shipped_Quantity
		(
			p_x_line_tbl			=> l_temp_line_tbl
		,	x_ratio_status			=> l_ratio_status
		,	x_return_status			=> l_x_return_status
		);

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RATIO STATUS/RETURN STATUS : '||L_RATIO_STATUS||L_X_RETURN_STATUS , 3 ) ;
		END IF;

		IF	l_ratio_status = FND_API.G_TRUE THEN

			l_shipped_quantity	:= l_temp_line_tbl(l_top_model_index).shipped_quantity;
			l_line_rec			:= l_temp_line_tbl(l_top_model_index);

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
			OE_Shipping_Integration_PVT.Check_Shipment_Line
			(
			p_line_rec			=> l_line_rec,
			p_shipped_quantity	=> l_shipped_quantity,
			x_result_out		=> l_x_result_out
			);

			IF	l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW AND
				l_planned_quantity_passed = FND_API.G_TRUE THEN

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SHIPPED WITHIN TOLERANCE BELOW' , 2 ) ;
				END IF;

				-- Tolerance needs to be updated so that ship confirm can result
				-- in split.

				l_temp_line_tbl := l_line_tbl;

				-- Assign the quantity to be shipped for shippable lines.
				FOR	l_line_index IN	l_line_tbl.FIRST .. l_line_tbl.LAST
				LOOP

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INSIDE THE MODEL LOOP '||TO_CHAR ( L_LINE_INDEX ) , 3 ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'ITEM TYPE '||L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
				END IF;

				-- IF 	l_cal_tolerance_tbl.EXISTS(l_line_tbl(l_line_index).line_id) THEN -- Bug 8795918
				IF      l_cal_tolerance_tbl.EXISTS(l_line_id_mod) THEN

					l_temp_line_tbl(l_line_index).shipping_quantity := nvl(l_line_tbl(l_line_index).shipping_quantity,0) +
					  l_cal_tolerance_tbl(l_line_id_mod).quantity_to_be_shipped + nvl(l_cal_tolerance_tbl(l_line_id_mod).planned_quantity,0);
					-- l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).quantity_to_be_shipped + Bug 8795918
					-- nvl(l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).planned_quantity,0);

					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'SHIPPING QUANTITY '|| TO_CHAR ( L_TEMP_LINE_TBL ( L_LINE_INDEX ) .SHIPPING_QUANTITY ) , 3 ) ;
					END IF;
					-- IF	l_line_tbl(l_line_index).order_quantity_uom <> l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).shipping_uom THEN -- Bug 8795918
					IF l_line_tbl(l_line_index).order_quantity_uom <> l_cal_tolerance_tbl(l_line_id_mod).shipping_uom THEN
						l_temp_line_tbl(l_line_index).shipped_quantity := OE_Order_Misc_Util.Convert_Uom
	  					(
		  				l_line_rec.inventory_item_id,
						l_cal_tolerance_tbl(l_line_id_mod).shipping_uom,
		  				-- l_cal_tolerance_tbl(l_line_tbl(l_line_index).line_id).shipping_uom,-- Bug 8795918
		  				l_line_tbl(l_line_index).order_quantity_uom,
		  				l_temp_line_tbl(l_line_index).shipped_quantity
	  					);

					ELSE
						l_temp_line_tbl(l_line_index).shipped_quantity := l_temp_line_tbl(l_line_index).shipping_quantity;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'SHIPPED QUANTITY '|| TO_CHAR ( L_TEMP_LINE_TBL ( L_LINE_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
					END IF;
				END IF;

				END LOOP;
				-- Calculate the shipped quantity of top model line.
				OE_Shipping_Integration_PVT.Get_PTO_Shipped_Quantity
				(
					p_x_line_tbl			=> l_temp_line_tbl
				,	x_ratio_status			=> l_ratio_status
				,	x_return_status			=> l_x_return_status
				);
				IF	l_ratio_status = FND_API.G_TRUE THEN

					l_shipped_quantity 	:= l_temp_line_tbl(l_top_model_index).shipped_quantity;
					l_ordered_quantity 	:= l_temp_line_tbl(l_top_model_index).ordered_quantity;
					l_line_rec			:= l_temp_line_tbl(l_top_model_index);

					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'TOTAL QUANTITY TO BE SHIPPED : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_ORDERED_QUANTITY ) , 3 ) ;
					END IF;

					-- Get the total ordered and shipped quantities if it is a part of
					-- a line set.

					IF	l_line_rec.line_set_id IS NOT NULL AND
						l_line_rec.line_set_id <> FND_API.G_MISS_NUM THEN

						OE_Shipping_Integration_PUB.Get_Quantity
						(
	 					p_api_version_number		=> 1.0,
						p_line_id					=> l_line_rec.line_id,
     					p_line_set_id				=> l_line_rec.line_set_id,
	 					x_ordered_quantity    		=> l_x_ordered_quantity,
	 					x_shipped_quantity    		=> l_x_shipped_quantity,
	 					x_shipping_quantity    		=> l_x_shipping_quantity,
     					x_return_status				=> l_x_return_status,
	 					x_msg_count					=> l_msg_count,
	 					x_msg_data					=> l_msg_data
	 					);

						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_X_ORDERED_QUANTITY ) , 3 ) ;
						END IF;
						IF l_debug_level  > 0 THEN
						    oe_debug_pub.add(  'TOTAL SHIPPED QUANTITY : '||TO_CHAR ( L_X_SHIPPED_QUANTITY ) , 3 ) ;
						END IF;
						l_shipped_quantity := l_shipped_quantity + l_x_shipped_quantity;
						l_ordered_quantity := l_x_ordered_quantity;

					END IF;

					-- Calculate the new tolerance value
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_ORDERED_QUANTITY ) , 3 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'TOTAL SHIPPED QUANTITY : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
					END IF;

					l_ship_tolerance := ((l_ordered_quantity - l_shipped_quantity)/l_ordered_quantity) * 100;
					IF	l_ship_tolerance < 0 THEN
						l_ship_tolerance := 0;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'NEW TOLERANCE VALUE : '|| TO_CHAR ( L_SHIP_TOLERANCE ) , 3 ) ;
					END IF;
					x_update_tolerance_flag := FND_API.G_TRUE;
					x_ship_tolerance := l_ship_tolerance;
				ELSE
					x_config_broken := FND_API.G_TRUE;
				END IF;

			ELSIF	l_x_result_out = OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE THEN
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'SHIPPED BEYOND TOLERANCE ' , 3 ) ;
					END IF;
					x_ship_beyond_tolerance := FND_API.G_TRUE;
			ELSIF	l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW OR
					l_x_result_out	= OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE THEN
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'SHIPPED WITHIN TOLERANCE ' , 3 ) ;
					END IF;
					x_shipped_within_tolerance := FND_API.G_TRUE;
			END IF;

		ELSE
			x_config_broken := FND_API.G_TRUE;
		END IF;

	ELSE
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IT IS A STANDARD LINE ' , 3 ) ;
		END IF;

                IF  l_line_rec.line_set_id IS NOT NULL THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'LINE SET ID NOT NULL '||L_LINE_REC.LINE_SET_ID , 3 ) ;
                END IF;
                SELECT  count(*)
                INTO    l_count_unshipped
                FROM    oe_order_lines
                WHERE   line_set_id = l_line_rec.line_set_id
                AND     shipped_quantity IS NULL
                AND     line_id <> l_line_rec.line_id ;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'COUNT '||L_COUNT_UNSHIPPED , 3 ) ;
                END IF;

                IF  nvl(l_count_unshipped,0) > 0 THEN

                    BEGIN

                    SELECT nvl(sum(shipped_quantity),0)
                    INTO   l_del_shipping_quantity
                    FROM   wsh_delivery_details
                    where  source_line_id in (SELECT line_id
                                              FROM   oe_order_lines
                                              WHERE  line_set_id = l_line_rec.line_set_id
                                              AND     shipped_quantity IS NULL
                                              AND     line_id <> l_line_rec.line_id)
                    and   source_code = 'OE'
                    and   released_status = 'C'
                    group by requested_quantity_uom;

                    EXCEPTION

                        WHEN NO_DATA_FOUND THEN
                             NULL;

                    END;

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'DELIVERY SHIPPING QUANTITY '||L_DEL_SHIPPING_QUANTITY , 3 ) ;
                    END IF;

                END IF; /* unshipped count more than 0 */

                END IF; /* Line set id not null */

		l_line_rec.shipping_quantity := nvl(l_line_rec.shipping_quantity,0) + p_cal_tolerance_tbl(1).quantity_to_be_shipped + l_del_shipping_quantity;

		IF	l_line_rec.order_quantity_uom <> p_cal_tolerance_tbl(1).shipping_uom THEN
			l_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
	  		(
		  	l_line_rec.inventory_item_id,
		  	p_cal_tolerance_tbl(1).shipping_uom,
		  	l_line_rec.order_quantity_uom,
		  	l_line_rec.shipping_quantity
	  		);
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOTAL QUANTITY TO BE SHIPPED AFTER UOM CONV : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
		ELSE
			l_shipped_quantity := l_line_rec.shipping_quantity;
		END IF;

		-- Check if the current quantity shipping will fulfill the line within
		-- tolerance.

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIPPED QUANTITY '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
		END IF;
		OE_Shipping_Integration_PVT.Check_Shipment_Line
		(
		p_line_rec			=> l_line_rec,
		p_shipped_quantity	=> l_shipped_quantity,
		x_result_out		=> l_x_result_out
		);

		IF	l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW AND
			l_planned_quantity_passed = FND_API.G_TRUE THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED WITHIN TOLERANCE BELOW' , 3 ) ;
			END IF;

			-- Tolerance needs to be updated so that ship confirm can result
			-- in split.

			l_shipped_quantity := 0;
			l_line_rec.shipping_quantity := p_cal_tolerance_tbl(1).quantity_to_be_shipped + p_cal_tolerance_tbl(1).planned_quantity;
			l_ordered_quantity := l_line_rec.ordered_quantity;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOTAL QUANTITY TO BE SHIPPED : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_ORDERED_QUANTITY ) , 3 ) ;
			END IF;
			IF	l_line_rec.order_quantity_uom <> p_cal_tolerance_tbl(1).shipping_uom THEN
				l_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
	  			(
		  		l_line_rec.inventory_item_id,
		  		p_cal_tolerance_tbl(1).shipping_uom,
		  		l_line_rec.order_quantity_uom,
		  		l_line_rec.shipping_quantity
	  			);
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'TOTAL QUANTITY TO BE SHIPPED AFTER UOM CONV : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
				END IF;
			ELSE
				l_shipped_quantity := l_line_rec.shipping_quantity;
			END IF;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
			END IF;

			-- Get the total ordered and shipped quantities if it is a part of
			-- a line set.

			IF	l_line_rec.line_set_id IS NOT NULL AND
				l_line_rec.line_set_id <> FND_API.G_MISS_NUM THEN

				OE_Shipping_Integration_PUB.Get_Quantity
				(
	 			p_api_version_number		=> 1.0,
				p_line_id					=> l_line_rec.line_id,
     			p_line_set_id				=> l_line_rec.line_set_id,
	 			x_ordered_quantity    		=> l_x_ordered_quantity,
	 			x_shipped_quantity    		=> l_x_shipped_quantity,
	 			x_shipping_quantity    		=> l_x_shipping_quantity,
     			x_return_status				=> l_x_return_status,
	 			x_msg_count					=> l_msg_count,
	 			x_msg_data					=> l_msg_data
	 			);

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_X_ORDERED_QUANTITY ) , 3 ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'TOTAL SHIPPED QUANTITY : '||TO_CHAR ( L_X_SHIPPED_QUANTITY ) , 3 ) ;
				END IF;
				l_shipped_quantity := l_shipped_quantity + l_x_shipped_quantity;
				l_ordered_quantity := l_x_ordered_quantity;

			END IF;

			-- Calculate the new tolerance value
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOTAL ORDERED QUANTITY : '||TO_CHAR ( L_ORDERED_QUANTITY ) , 3 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'TOTAL SHIPPED QUANTITY : '||TO_CHAR ( L_SHIPPED_QUANTITY ) , 3 ) ;
			END IF;

			l_ship_tolerance := ((l_ordered_quantity - l_shipped_quantity)/l_ordered_quantity) * 100;
			IF	l_ship_tolerance < 0 THEN
				l_ship_tolerance := 0;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'NEW TOLERANCE VALUE : '|| TO_CHAR ( L_SHIP_TOLERANCE ) , 3 ) ;
			END IF;
			x_update_tolerance_flag := FND_API.G_TRUE;
			x_ship_tolerance := l_ship_tolerance;

		ELSIF	l_x_result_out = OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE THEN
				x_ship_beyond_tolerance := FND_API.G_TRUE;
		ELSIF	l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW OR
				l_x_result_out	= OE_GLOBALS.G_FULLY_SHIPPED OR
				l_x_result_out	= OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SHIPPED WITHIN TOLERANCE ' , 3 ) ;
				END IF;
				x_shipped_within_tolerance := FND_API.G_TRUE;
		END IF;

	END IF;


	x_return_status			:= FND_API.G_RET_STS_SUCCESS;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING FROM OE_SHIPPING_INTEGRATION_PUB.GET_TOLERANCE ' , 1 ) ;
	END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN


	x_return_status		:= FND_API.G_RET_STS_ERROR;

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
            ,   'Get_Tolerance'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Tolerance;

/*
	This procedure will return the total ordered quantity and the total shipped
	quantity. It adds up the ordered and shipped quantities for all the lines
    which may have been created because of split.
*/

PROCEDURE Get_Quantity
(
	 p_api_version_number		IN	NUMBER
,	 p_line_id				IN	NUMBER
,	 p_line_set_id				IN	NUMBER
,	 x_ordered_quantity    		OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_shipped_quantity    		OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_shipping_quantity		OUT NOCOPY /* file.sql.39 change */	NUMBER
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

	l_api_version_number	CONSTANT NUMBER := 1.0;
	l_api_name				CONSTANT VARCHAR2(30) := 'Get_Quantity';
	l_x_ordered_quantity	NUMBER;
	l_x_shipped_quantity	NUMBER;
	l_x_shipping_quantity	NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Standard call to check for call compatibility
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.GET_QUANTITY '||TO_CHAR ( P_LINE_ID ) ||'/'||TO_CHAR ( P_LINE_SET_ID ) , 1 ) ;
	END IF;

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	SELECT	SUM(ordered_quantity)
		,	SUM(shipped_quantity)
		,	SUM(shipping_quantity)
	INTO	l_x_ordered_quantity
		,	l_x_shipped_quantity
		,	l_x_shipping_quantity
	FROM	oe_order_lines
	WHERE 	line_set_id	= p_line_set_id;

	x_ordered_quantity 	:= l_x_ordered_quantity;
	x_shipped_quantity 	:= l_x_shipped_quantity;
	x_shipping_quantity 	:= l_x_shipping_quantity;
	x_return_status		:= FND_API.G_RET_STS_SUCCESS;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PUB.GET_QUANTITY ' , 1 ) ;
	END IF;
EXCEPTION

	WHEN NO_DATA_FOUND THEN

	x_ordered_quantity := 0;
	x_shipped_quantity := 0;
	x_shipping_quantity := 0;

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
            ,   'Get_Quantity'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Quantity;

PROCEDURE Update_Shipping_Interface
(
	 p_api_version_number		IN	NUMBER
,    p_line_id					IN	NUMBER
,	 p_shipping_interfaced_flag	IN 	VARCHAR2
,    x_return_status			OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,	 x_msg_count				OUT NOCOPY /* file.sql.39 change */ NUMBER
,	 x_msg_data					OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl		OE_Order_PUB.Line_Tbl_Type;
l_index             Number;
l_firm_flag         Varchar2(1) := Null;
l_ato_line_id       Number;
l_top_model_line_id Number;
l_item_type_code    Varchar2(30);
l_smc_flag          Varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_is_op_create VARCHAR2(1) := 'N';
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.UPDATE_SHIPPING_INTERFACE' , 1 ) ;
	END IF;

    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

	IF	p_line_id IS NULL OR
		p_line_id = FND_API.G_MISS_NUM THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE ID IS NULL ' , 1 ) ;
		END IF;

		FND_MESSAGE.SET_NAME('ONT','OE_SHP_LINE_ID_MISSING');
		OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;

	END IF;

	IF	p_shipping_interfaced_flag IS NOT NULL AND
		p_shipping_interfaced_flag NOT IN ('Y','N') THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INVALID VALUE FOR SHIPPING INTERFACED FLAG' , 1 ) ;
		END IF;

		FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
		OE_Order_Util.Get_Attribute_Name('shipping_interfaced_flag'));
		OE_MSG_PUB.Add;

		RAISE FND_API.G_EXC_ERROR;

	END IF;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    AND Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SHIPPING_INTERFACED'
    THEN
       l_firm_flag := 'Y';
    END IF;

	SAVEPOINT Update_Shipping_Interface;

	update 	oe_order_lines
	set		shipping_interfaced_flag = p_shipping_interfaced_flag,
            firm_demand_flag = NVL(l_firm_flag,firm_demand_flag),
			last_update_date = SYSDATE,
			last_updated_by = FND_GLOBAL.USER_ID,
			last_update_login = FND_GLOBAL.LOGIN_ID,
			lock_control = lock_control + 1
	where 	line_id	= p_line_id;


-- Note that even though a direct update is happening here in the preceeding statement,
-- we are not calling the notification framework

    -- Check if ISO is installed, then only lock the rows and call Process_Requests_And_Notify

    IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y' ) OR
          (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  ) THEN

        OE_Line_Util.Lock_Rows
		(p_line_id		=> p_line_id
		,x_line_tbl		=> l_old_line_tbl
		,x_return_status	=> x_return_status
		);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_line_tbl := l_old_line_tbl;
	    l_line_tbl(1).shipping_interfaced_flag := p_shipping_interfaced_flag;
        l_line_tbl(1).firm_demand_flag := NVL(l_firm_flag,
                                              l_line_tbl(1).firm_demand_flag);
	    l_line_tbl(1).last_update_date := SYSDATE;
	    l_line_tbl(1).last_updated_by := FND_GLOBAL.USER_ID;
	    l_line_tbl(1).last_update_login := FND_GLOBAL.LOGIN_ID;
	    l_line_tbl(1).lock_control := l_line_tbl(1).lock_control + 1;

               /* comenting following lines because of bug 1880716
		IF (l_line_tbl(1).item_type_code = 'CONFIG') OR
		   (l_line_tbl(1).item_type_code IN ('STANDARD','OPTION') AND -- 1820608
			l_line_tbl(1).ato_line_id IS NOT NULL) THEN
			oe_debug_pub.add('Do not update flow status ');
		ELSE
			oe_debug_pub.add('Update flow status ');
			l_line_tbl(1).flow_status_code := 'AWAITING_SHIPPING';
		END IF;
              */

        IF l_firm_flag = 'Y' THEN
          IF l_line_tbl(1).ship_model_complete_flag = 'Y' THEN

             Update oe_order_lines_all
             Set    firm_demand_flag = 'Y'
             Where  top_model_line_id = l_line_tbl(1).top_model_line_id;

          ELSIF (l_line_tbl(1).ato_line_id is not null
          AND  NOT  (l_line_tbl(1).ato_line_id = p_line_id AND
                     l_line_tbl(1).item_type_code IN
                                       (OE_GLOBALS.G_ITEM_STANDARD,
                                        OE_GLOBALS.G_ITEM_OPTION)))
          THEN

             Update oe_order_lines_all
             Set    firm_demand_flag = 'Y'
             Where  ato_line_id = l_line_tbl(1).ato_line_id;

          END IF;


        END IF;    -- Firm flag

   -- added for notification framework
   -- If using notification framework, no call to process_requests_and_notify is needed
   -- check code release level first. Notification framework is at Pack H level

       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

          -- calling notification framework to get index position
          OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                                 p_header_id =>l_line_tbl(1).header_id,
                                 p_old_line_rec => l_old_line_tbl(1),
                                 p_line_rec =>l_line_tbl(1),
                                 p_line_id => p_line_id,
                                 x_index => l_index,
                                 x_return_status => x_return_status);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_SHIPPING_INTEGRATION_PUB IS:' || X_RETURN_STATUS ) ;
         END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'GLOBAL PICTURE INDEX IS: ' || L_INDEX , 1 ) ;
         END IF;

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

           IF l_index IS NOT NULL THEN
           -- update the global picture directly

-- bug 3454703

	     IF OE_ORDER_UTIL.g_old_line_tbl.EXISTS(l_index) THEN
       	       IF OE_ORDER_UTIL.g_old_line_tbl(l_index).OPERATION = oe_globals.g_opr_create THEN
	         l_is_op_create := 'Y';
               END IF;
             END IF;
-- end bug 3454703

             OE_ORDER_UTIL.g_old_line_tbl(l_index) := l_old_line_tbl(1);
             OE_ORDER_UTIL.g_line_tbl(l_index) := OE_ORDER_UTIL.g_old_line_tbl(l_index);
-- bug 3454703
	     IF l_is_op_create = 'Y' THEN
               OE_ORDER_UTIL.g_old_line_tbl(l_index).OPERATION := oe_globals.g_opr_create;
	     END IF;
-- end bug 3454703
             OE_ORDER_UTIL.g_line_tbl(l_index).line_id := l_line_tbl(1).line_id;
             OE_ORDER_UTIL.g_line_tbl(l_index).header_id := l_line_tbl(1).header_id;

             OE_ORDER_UTIL.g_line_tbl(l_index).shipping_interfaced_flag := p_shipping_interfaced_flag;
             OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date := SYSDATE;
             OE_ORDER_UTIL.g_line_tbl(l_index).last_updated_by := FND_GLOBAL.USER_ID;
             OE_ORDER_UTIL.g_line_tbl(l_index).last_update_login := FND_GLOBAL.LOGIN_ID;
             OE_ORDER_UTIL.g_line_tbl(l_index).last_update_login := FND_GLOBAL.LOGIN_ID;
          END IF;

       ELSE /*pre-pack H*/

        OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => x_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl              => l_old_line_tbl
          );

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

	END IF; /* pack H */

    ELSE

     IF l_firm_flag = 'Y' THEN

        BEGIN

          Select ato_line_id ,
                 item_type_code,
                 ship_model_complete_flag,
                 top_model_line_id
          Into   l_ato_line_id,
                 l_item_type_code,
                 l_smc_flag,
                 l_top_model_line_id
          From   oe_order_lines_all
          Where  line_id = p_line_id;

          IF l_smc_flag = 'Y' THEN

             Update oe_order_lines_all
             Set    firm_demand_flag = 'Y'
             Where  top_model_line_id = l_top_model_line_id;
          ELSIF (l_ato_line_id is not null
          AND  NOT  (l_ato_line_id = p_line_id AND
                     l_item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                          OE_GLOBALS.G_ITEM_OPTION)))
          THEN

             Update oe_order_lines_all
             Set    firm_demand_flag = 'Y'
             Where  ato_line_id = l_ato_line_id;

          END IF;

        END; -- For begin


     END IF;    -- Firm flag
    END IF; -- IF OE_GLOBALS.G_ASO_INSTALLED = 'Y' or DBI installed.

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PUB.UPDATE_SHIPPING_INTERFACE' , 1 ) ;
	END IF;

	x_return_status		:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO Update_Shipping_Interface;

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

		x_return_status :=  FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO Update_Shipping_Interface;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
		END IF;
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        ROLLBACK TO Update_Shipping_Interface;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Shipping_Interface'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'UNEXPECTED ERROR : '||SQLERRM , 1 ) ;
		END IF;
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Shipping_Interface;

-- HW added qty2 for OPM in the procedure parameters

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

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PUB.GET_MIN_MAX_TOLERANCE_QUANTITY' , 1 ) ;
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


    OE_Shipping_Tolerances_PUB.Get_Min_Max_Tolerance_Quantity
(
     p_api_version_number	   => p_api_version_number,
     p_line_id			       => p_line_id,
     x_min_remaining_quantity  => x_min_remaining_quantity,
     x_max_remaining_quantity  => x_max_remaining_quantity,
     x_min_remaining_quantity2 => x_min_remaining_quantity2,
     x_max_remaining_quantity2 => x_max_remaining_quantity2,
     x_return_status		   => x_return_status,
     x_msg_count               => x_msg_count,
     x_msg_data	               => x_msg_data
);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHP RETURN MIN REMAINING QUANTITY : '||X_MIN_REMAINING_QUANTITY , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHP RETURN MAX REMAINING QUANTITY : '||X_MAX_REMAINING_QUANTITY , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHP RETURN MIN REMAINING QUANTITY2 : '||X_MIN_REMAINING_QUANTITY2 , 3 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHP RETURN MAX REMAINING QUANTITY2 : '||X_MAX_REMAINING_QUANTITY2 , 3 ) ;
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PUB.GET_MIN_MAX_TOLERANCE_QUANTITY '||X_RETURN_STATUS , 1 ) ;
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


FUNCTION  Check_Import_Pending_Lines
(p_header_id              IN    NUMBER
,p_ship_set_id            IN    NUMBER
,p_top_model_line_id      IN    NUMBER
,p_transactable_flag      IN    VARCHAR2
,x_return_status          OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_line_id              NUMBER;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT  oel.line_id
    INTO  l_line_id
    FROM  oe_order_lines_all oel,
          mtl_system_items msi
  WHERE  oel.header_id = p_header_id
  AND    (oel.ship_set_id = p_ship_set_id OR
          (oel.top_model_line_id = p_top_model_line_id AND
           oel.ship_model_complete_flag = 'Y'))
  AND    oel.inventory_item_id = msi.inventory_item_id
  and    oel.ship_from_org_id = msi.organization_id
  AND    oel.ordered_quantity > 0
  and    ((p_transactable_flag = 'N') OR
          (p_transactable_flag = 'Y' AND
           msi.mtl_transactions_enabled_flag = 'Y'))
  AND    oel.shipping_interfaced_flag = 'N'
  AND    (oel.shippable_flag = 'Y' OR
          (EXISTS (SELECT 'Y'
                   FROM   oe_order_lines_all oel1
                   WHERE  oel1.header_id = p_header_id
                   AND    (oel1.ship_set_id = p_ship_set_id OR
                                 (oel1.top_model_line_id = p_top_model_line_id AND
                                  oel1.ship_model_complete_flag = 'Y'))
                   AND    oel1.ato_line_id = oel1.line_id
                   AND    oel1.item_type_code in ('MODEL','CLASS')
		   AND    oel1.ordered_quantity > 0
                   AND    NOT EXISTS (SELECT 'Y'
                                      FROM  oe_order_lines_all oel2
                                      WHERE oel2.top_model_line_id
                                            = oel1.top_model_line_id
                                      AND   oel2.ato_line_id
                                            = oel1.ato_line_id
                                      AND   oel2.item_type_code = 'CONFIG'))))
  AND ROWNUM = 1;

Return True;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('No Pending_Lines', 1);
              End if;
              Return False;

        WHEN OTHERS THEN
              if l_debug_level > 0 then
                  OE_DEBUG_PUB.Add('When Others in Check_Pick_pending_Lines'||SqlErrm, 1);
               End if;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End Check_Import_Pending_Lines;

PROCEDURE ATO_Config_Line_Ship_Notified( p_application_id               IN NUMBER,
                                 p_entity_short_name            in VARCHAR2,
                                 p_validation_entity_short_name in VARCHAR2,
                                 p_validation_tmplt_short_name  in VARCHAR2,
                                 p_record_set_tmplt_short_name  in VARCHAR2,
                                 p_scope                        in VARCHAR2,
                                 p_result                       OUT NOCOPY NUMBER ) IS


l_config_line_id NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

config_line_ship_notified NUMBER := 0;
BEGIN



  IF  (OE_LINE_SECURITY.g_record.ato_line_id IS NULL) OR
      (OE_LINE_SECURITY.g_record.ato_line_id = FND_API.G_MISS_NUM) OR
      (OE_LINE_SECURITY.g_record.item_type_code not in ('MODEL', 'CLASS')) OR
      (OE_LINE_SECURITY.g_record.line_id IS NULL) OR
      (OE_LINE_SECURITY.g_record.line_id = FND_API.G_MISS_NUM) OR
      (OE_LINE_SECURITY.g_record.ato_line_id <> OE_LINE_SECURITY.g_record.line_id)
  THEN
      OE_MSG_PUB.Update_Msg_Context(p_attribute_code => null);
      p_result := 0;

  ELSE

    BEGIN

	SELECT line_id
	INTO l_config_line_id
	FROM oe_order_lines
        WHERE header_id = OE_LINE_SECURITY.g_record.header_id
        AND ato_line_id = OE_LINE_SECURITY.g_record.line_id
        AND item_type_code = 'CONFIG';

                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('Config line line_id' || l_config_line_id);
                 END IF;


	SELECT 1
        INTO config_line_ship_notified
	FROM wf_item_activity_statuses wias, wf_process_activities wpa
	WHERE wias.item_type='OEOL'
	AND wias.item_key=l_config_line_id
	AND wpa.activity_name='SHIP_LINE'
	AND wias.activity_status='NOTIFIED'
	AND wias.PROCESS_ACTIVITY = wpa.INSTANCE_ID;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             config_line_ship_notified := 0;
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('In NO DATA FOUND - No config lines for this model have been ship notified');
                 END IF;
    END;

    IF config_line_ship_notified = 1 THEN
        p_result := 1;
    ELSE
        p_result := 0;
    END IF;

  END IF;

END ATO_Config_Line_Ship_Notified;

/*-----------------------------------------------------------------
-- PROCEDURE Get_SetSMC_Interface_Status
-- Description : This API was added for bug 3623149 ,
                 to be used by shipping.
                 Setsmc_Output_Rec_Type.x_interface_status can
                 have Y if all lines available in
                 shipping, N if all lines are not available in shipping.
                 Shipping will use the x_interface_status value
                 only if the x_return_status is Success.

Change Record - This API is not only for SMC models but also
used for non_SMC models and the name may be confusing...
-----------------------------------------------------------------*/
PROCEDURE Get_SetSMC_Interface_Status
(p_setsmc_input_rec    IN Setsmc_Input_Rec_Type
,p_setsmc_output_rec  OUT NOCOPY /* file.sql.39 change */ Setsmc_Output_Rec_Type
,x_return_status      OUT NOCOPY VARCHAR2)
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_line_id              NUMBER;
  l_header_id            NUMBER := p_setsmc_input_rec.header_id;
  l_top_model_line_id    NUMBER := p_setsmc_input_rec.top_model_line_id;
  l_ship_set_id          NUMBER := p_setsmc_input_rec.ship_set_id;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Entering Get_SetSMC_Interface_Status ', 1);
   oe_debug_pub.add('headerID = '||l_header_id, 3);
   oe_debug_pub.add('top_model_line_id = '||l_top_model_line_id, 3);
   oe_debug_pub.add('ship_set_id = '||l_ship_set_id, 3);
 END IF;
 BEGIN
   SELECT oel.line_id
   INTO   l_line_id
   FROM   oe_order_lines_all oel
   WHERE  oel.header_id = l_header_id
   AND    (oel.ship_set_id = l_ship_set_id OR
           oel.top_model_line_id = l_top_model_line_id)
   AND    oel.shipping_interfaced_flag = 'N'
   AND    (oel.shippable_flag = 'Y' OR
          (EXISTS (SELECT 'Y'
                   FROM   oe_order_lines_all oel1
                   WHERE  oel1.header_id = l_header_id
                   AND    (oel1.ship_set_id = l_ship_set_id OR
                           oel1.top_model_line_id = l_top_model_line_id)
                   AND    oel1.ato_line_id = oel1.line_id
                   AND    oel1.item_type_code in ('MODEL','CLASS')
                   AND    NOT EXISTS (SELECT 'Y'
                                      FROM  oe_order_lines_all oel2
                                      WHERE oel2.top_model_line_id
                                            = oel1.top_model_line_id
                                      AND   oel2.ato_line_id
                                            = oel1.ato_line_id
                                      AND   oel2.item_type_code = 'CONFIG'))))
   AND    ROWNUM = 1;

 -- If some shippable lines are found not interfaced to wsh
 p_setsmc_output_rec.x_interface_status := 'N';

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('leaving Get_SetSMC_Interface_Status '
                     || p_setsmc_output_rec.x_interface_status
                     || '-' || x_return_status, 1);
 END IF;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('all shippable lines are interfaced to wsh', 1);
    END IF;
   p_setsmc_output_rec.x_interface_status := 'Y';
 END;

EXCEPTION
  WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('OTHERS EXCEPTION ' || sqlerrm, 1);
   END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_setsmc_output_rec.x_interface_status := 'N';

END Get_SetSMC_Interface_Status;
-- 3623149 changes ends
END OE_Shipping_Integration_PUB;


/
