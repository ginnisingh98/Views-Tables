--------------------------------------------------------
--  DDL for Package Body OE_SHIPPING_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIPPING_INTEGRATION_PVT" AS
/* $Header: OEXVSHPB.pls 120.19.12010000.4 2009/08/14 08:37:42 sahvivek ship $ */

--  Global constant holding the package name

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Shipping_Integration_PVT';

--  Start of Comments
--  API name    OE_Shipping_Integration_PVT
--  Type        Private
--  Version     Current version = 1.0
--              Initial version = 1.0

/*---------------------------------------------------------------
Forward Declarations
----------------------------------------------------------------*/

PROCEDURE Ship_Confirm_Split_Lines
( p_line_rec         IN  OE_Order_Pub.Line_Rec_Type
 ,p_shipment_status  IN  VARCHAR2);


PROCEDURE Call_Notification_Framework
( p_line_rec       IN  OE_Order_Pub.Line_Rec_Type
 ,p_caller         IN  VARCHAR2
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);


/*---------------------------------------------------------------
PROCEDURE Validate_Release_Status
----------------------------------------------------------------*/
PROCEDURE Validate_Release_Status
(
	p_application_id		IN	NUMBER
,	p_entity_short_name		IN	VARCHAR2
,	p_validation_entity_short_name	IN	VARCHAR2
,	p_validation_tmplt_short_name	IN	VARCHAR2
,	p_record_set_short_name		IN	VARCHAR2
,	p_scope				IN	VARCHAR2
, x_result_out OUT NOCOPY NUMBER

)
IS
l_Release_Status   VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
        IF g_debug_call > 0 THEN
           G_DEBUG_MSG := G_DEBUG_MSG || '1,';
        END IF;

	SELECT	PICK_STATUS
	INTO	l_release_status
	FROM	WSH_DELIVERY_LINE_STATUS_V
	WHERE 	SOURCE_CODE = 'OE'
	AND	SOURCE_LINE_ID = OE_LINE_SECURITY.g_record.line_id
	AND	PICK_STATUS = 'S';
	IF	l_release_status = 'S' THEN
		x_result_out := 1;
	ELSE
		x_result_out := 0;
	END IF;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '2';
         END IF;
EXCEPTION
	WHEN	NO_DATA_FOUND THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'NO DATA FOUND IN VALIDATE RELEASE STATUS' , 1 ) ;
                END IF;
                x_result_out := 0;
	WHEN	TOO_MANY_ROWS THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'TOO MANY ROWS IN VALIDATE RELEASE STATUS' , 1 ) ;
                END IF;
		x_result_out := 1;
	WHEN OTHERS THEN
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Validate_Release_Status'
                );
             END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ERROR MESSAGE IN VALIDATE RELEASE STATUS : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
	END IF;
END Validate_Release_Status;


/*---------------------------------------------------------------
PROCEDURE Validate_Pick
----------------------------------------------------------------*/
PROCEDURE Validate_Pick
(
	p_application_id		IN	NUMBER
,	p_entity_short_name		IN	VARCHAR2
,	p_validation_entity_short_name	IN	VARCHAR2
,	p_validation_tmplt_short_name	IN	VARCHAR2
,	p_record_set_short_name			IN	VARCHAR2
,	p_scope							IN	VARCHAR2
, x_result_out OUT NOCOPY NUMBER

)
IS
	l_pick_status		VARCHAR2(1);
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	SELECT	PICK_STATUS
	INTO	l_pick_status
	FROM	WSH_DELIVERY_LINE_STATUS_V
	WHERE 	SOURCE_CODE = 'OE'
	AND		SOURCE_LINE_ID = OE_LINE_SECURITY.g_record.line_id
	AND		PICK_STATUS = 'Y';

	IF	l_pick_status = 'Y' THEN
		x_result_out := 1;
	ELSE
		x_result_out := 0;
	END IF;


EXCEPTION
	WHEN	NO_DATA_FOUND THEN
			x_result_out := 0;
	WHEN	TOO_MANY_ROWS THEN
			x_result_out := 1;
	WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Pick'
            );
        END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
		END IF;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E1';
                END IF;
END Validate_Pick;


/*---------------------------------------------------------------
PROCEDURE Call_Process_Order
----------------------------------------------------------------*/
PROCEDURE Call_Process_Order
(p_line_tbl		IN	OE_Order_PUB.Line_Tbl_Type
,p_control_rec		IN	OE_GLOBALS.Control_Rec_Type DEFAULT OE_GLOBALS.G_MISS_CONTROL_REC
,p_process_requests     IN BOOLEAN := FALSE
,x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_line_tbl					OE_Order_PUB.Line_Tbl_Type;
	l_control_rec				OE_GLOBALS.Control_Rec_Type;
	l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
	l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
	l_line_adj_out_tbl          OE_ORDER_PUB.Line_Adj_Tbl_Type;
	l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
	l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
	l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
	l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;
	l_header_price_att_tbl		OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
	l_header_adj_assoc_tbl		OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
	l_header_adj_att_tbl		OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
	l_line_price_att_tbl		OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
	l_line_adj_assoc_tbl		OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
	l_line_adj_att_tbl			OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
	l_lot_serial_tbl        	OE_Order_PUB.Lot_Serial_Tbl_Type;
	l_return_status				VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);
--serla begin
l_header_payment_out_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_line_payment_out_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	l_line_tbl	:= p_line_tbl;
	l_control_rec := p_control_rec;
        IF g_debug_call > 0 THEN
           G_DEBUG_MSG := G_DEBUG_MSG || '3,';
        END IF;

	IF	l_control_rec.check_security = FALSE THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CHECK SECURITY = FALSE' , 1 ) ;
		END IF;
	ELSE
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CHECK SECURITY = TRUE' , 1 ) ;
		END IF;
	END IF;

	l_control_rec.process := p_process_requests;

	l_control_rec.controlled_operation := TRUE;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '4,';
         END IF;

		OE_Order_PVT.Process_Order
		(
			p_api_version_number		=> 1.0
		,	x_return_status				=> l_return_status
		,	x_msg_count					=> l_msg_count
		,	x_msg_data					=> l_msg_data
		,	p_x_line_tbl				=> l_line_tbl
		,	p_control_rec				=> l_control_rec
		,	p_x_header_rec				=> l_header_out_rec
		,	p_x_header_adj_tbl			=> l_header_adj_out_tbl
		,	p_x_header_scredit_tbl		=> l_header_scredit_out_tbl
--serla begin
		,	p_x_header_payment_tbl		=> l_header_payment_out_tbl
--serla end
		,	p_x_line_adj_tbl			=> l_line_adj_out_tbl
		,	p_x_line_scredit_tbl		=> l_line_scredit_out_tbl
--serla begin
		,	p_x_line_payment_tbl		=> l_line_payment_out_tbl
--serla end
		,	p_x_action_request_tbl		=> l_action_request_out_tbl
		,	p_x_lot_serial_tbl			=> l_lot_serial_tbl
		,	p_x_header_price_att_tbl	=> l_header_price_att_tbl
		,	p_x_header_adj_att_tbl		=> l_header_adj_att_tbl
		,	p_x_header_adj_assoc_tbl	=> l_header_adj_assoc_tbl
		,	p_x_line_price_att_tbl		=> l_line_price_att_tbl
		,	p_x_line_adj_att_tbl		=> l_line_adj_att_tbl
		,	p_x_line_adj_assoc_tbl		=> l_line_adj_assoc_tbl
		);

		x_return_status := l_return_status;
                IF g_debug_call > 0 THEN
                   G_DEBUG_MSG := G_DEBUG_MSG || '4';
                END IF;

EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Call_Process_Order'
				);
			END IF;
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || 'E4';
                 END IF;

    WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Call_Process_Order'
				);
			END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
		END IF;
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || 'E5';
                 END IF;
END Call_Process_Order;

/*----------------------------------------------------------------
PROCEDURE Update_Shipping_From_OE

parameters in request rec=>
request_unique_key1: line_rec.operation
param1: true/false, whether to update shipping from OE
param2: true/false, explosion_date_changed
param3:
param4:
param5: ordered_quantity_changed

meaning of action flag,
I : delete
S : create
U : update
-----------------------------------------------------------------*/

PROCEDURE Update_Shipping_From_OE
( p_update_lines_tbl    IN    OE_ORDER_PUB.Request_Tbl_Type
 ,x_return_status       OUT NOCOPY VARCHAR2)
IS
    l_shp_index             NUMBER :=0;
    l_line_index            NUMBER :=0;
    l_changed_attributes    WSH_INTERFACE.ChangedAttributeTabType;
    l_line_rec              OE_Order_Pub.line_rec_type;
    l_line_id               NUMBER;
    l_return_status         VARCHAR2(1);
    l_line_at_shipping      VARCHAR2(1) := FND_API.G_FALSE;
    l_result_out            VARCHAR2(30);
    l_source_code           VARCHAR2(2) := 'OE';
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_x_result_out          VARCHAR2(30);
    l_result_code           VARCHAR2(30);
    l_error_msg             VARCHAR2(240);
    l_msg_index             NUMBER;
    l_line_tbl              OE_Order_PUB.Line_Tbl_Type;
    l_old_line_tbl          OE_Order_PUB.Line_Tbl_Type;
    l_line_number           VARCHAR2(150);
    l_index                 NUMBER;
    l_shipping_interfaced_flag    VARCHAR2(1);
    -- odaboval : Begin of OPM Changes
    --l_ic_item_mst_rec       GMI_Reservation_Util.ic_item_mst_rec;  OPM INVCONV 4742691
   -- l_opm_lot_id            NUMBER; -- INVCONV
 --   l_opm_uom               VARCHAR2(4);-- INVCONV
--    l_opm_uom2              VARCHAR2(4);-- INVCONV
--    l_apps_uom              VARCHAR2(3);-- INVCONV
--    l_apps_uom2             VARCHAR2(3);-- INVCONV
			l_item_rec   OE_ORDER_CACHE.item_rec_type; -- INVCONV

    l_force_ui              VARCHAR2(1)   := 'N';
    l_header_id             NUMBER;
    l_item_type_code        VARCHAR2(240);
    -- odaboval : End of OPM Changes
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    -- 4437814 start changes
    l_activity_status         VARCHAR2(8);
    l_activity_result         VARCHAR2(30);
    l_activity_id             NUMBER;
    l_shipline_notified       VARCHAR2(1):='Y';
    -- 4437814 end changes
    --
    --l_assign_flag   boolean := FALSE;

    --code fix for 6391881 start changes
    l_wsh_no_data_found   BOOLEAN := FALSE;
    l_ok_to_cancel        BOOLEAN := TRUE;
    --code fix for 6391881 end changes

   -- code fix for 5590106
    i number;
    l_cxl_dd_count NUMBER ;  -- cancelled delivery detail count



BEGIN

    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING oexvshpb UPDATE_SHIPPING_FROM_OE',1);
        oe_debug_pub.add('Tbl Count:'||p_update_lines_tbl.COUNT,4);
    END IF;
     IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '6,';
     END IF;

    FOR l_line_index IN p_update_lines_tbl.First .. p_update_lines_tbl.Last
    LOOP

        l_line_id          := p_update_lines_tbl(l_line_index).entity_id;
        l_line_at_shipping := FND_API.G_FALSE;

       OE_Line_Util.Query_Row --bug 4516453, moved query_row here to set msg context
        ( p_line_id  => l_line_id,
          x_line_rec => l_line_rec);
       --- setting the msg context
       OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id
          );

        -------------- handle delete operation -----------------

        IF p_update_lines_tbl(l_line_index).request_unique_key1
                             = OE_GLOBALS.G_OPR_DELETE THEN
        -- fix for 3779333
        -- select item type code from oe_orderlines_table. For config lines
        -- pass action code as 'U' to shipping. for other item types, pass
        -- action code as 'D'

             SELECT item_type_code
             INTO   l_item_type_code
             FROM   oe_order_lines
             WHERE  line_id = l_line_id;

          --{ bug3831490 starts
          IF l_item_type_code <> 'CONFIG' THEN

             l_shp_index := l_shp_index + 1;
             l_changed_attributes(l_shp_index).action_flag := 'D';
             l_changed_attributes(l_shp_index).source_line_id
                          := p_update_lines_tbl(l_line_index).entity_id;
             l_changed_attributes(l_shp_index).ordered_quantity :=  0;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('line is deleted '
                 || L_CHANGED_ATTRIBUTES(L_SHP_INDEX).SOURCE_LINE_ID , 3 ) ;
                 oe_debug_pub.add('action flag = '
                 ||L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ACTION_FLAG , 3 ) ;
                 oe_debug_pub.add('item type code :' || l_item_type_code, 3);
                 oe_debug_pub.add('ordered quantity '
                 || L_CHANGED_ATTRIBUTES(L_SHP_INDEX).ORDERED_QUANTITY, 3 ) ;
             END IF;

             GOTO END_UPDATE_SHIPPING_LOOP;
          ELSE
             --this is if it is DELETE + ITEM_TYPE_CODE==CONFIG
             l_shp_index := l_shp_index + 1;
             l_changed_attributes(l_shp_index).source_line_id
                          := p_update_lines_tbl(l_line_index).entity_id;
	     IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add ('This is a config item cancel/delete case',1);
	     END IF;
          END IF;

        END IF; -- if operation is delete

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('processing line_ID ' ||L_LINE_ID, 3);
        END IF;

        ---------- Check If explosion date has changed and -----------
        -- the current activity is shipping for the line.
        -- this code is not required and explosion date never changes.


        IF p_update_lines_tbl(l_line_index).param2 = FND_API.G_TRUE THEN
             IF g_debug_call > 0 THEN
               G_DEBUG_MSG := G_DEBUG_MSG || '7,';
             END IF;

            IF OE_Shipping_Integration_PUB.Is_Activity_Shipping
              (1.0, l_line_id) = FND_API.G_TRUE THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add
                    ('explosion date changed, line is at ship '|| l_line_id,3);
                END IF;

                l_line_at_shipping := FND_API.G_TRUE;
            ELSE
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || '8,';
                 END IF;

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add
                    ('explosion date changed, but LINE not at shipping '
                      || TO_CHAR ( L_LINE_ID ) , 3 ) ;
                END IF;

                GOTO END_UPDATE_SHIPPING_LOOP;
            END IF;

        END IF; -- if exlosion date changes


        ----------- Assign the values to table for Shipping ---------

        l_shp_index := l_shp_index + 1;
        l_changed_attributes(l_shp_index).released_status
                    := FND_API.G_MISS_CHAR;

        -- Line is at SHIP_LINE call shipping with action code 'I'
        -- If the line is not yet interfaced

        IF  p_update_lines_tbl(l_line_index).param4 = FND_API.G_TRUE THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('line at shipping, update released flag '
                                  || TO_CHAR ( L_LINE_ID ) , 3 ) ;
            END IF;


                SELECT  shipping_interfaced_flag, header_id
                INTO    l_shipping_interfaced_flag, l_header_id
                FROM    oe_order_lines
                WHERE   line_id = l_line_id;
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || '10,';
                 END IF;

                IF  nvl(l_shipping_interfaced_flag,'N') = 'N' THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('NOT INTERFACED TO SHIPPING ' , 3 ) ;
                    END IF;

                    l_changed_attributes(l_shp_index).source_line_id
                                                               := l_line_id;
                    l_changed_attributes(l_shp_index).action_flag := 'I';
                    l_changed_attributes(l_shp_index).released_status := 'R';


                    GOTO END_UPDATE_SHIPPING_LOOP;
                ELSE
                    l_changed_attributes(l_shp_index).released_status := 'R';
                END IF; -- if shipping interfaed or not

            IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '11,';
            END IF;
        END IF; -- if param4 is true

        /* the code has been moved up for bug 4516453 to set msg context
        OE_Line_Util.Query_Row
        ( p_line_id  => l_line_id,
          x_line_rec => l_line_rec); */


        -- Check If only explosion date has changed and the current activity
        -- is shipping for the line.

        IF p_update_lines_tbl(l_line_index).param2 = FND_API.G_TRUE
        AND l_line_at_shipping = FND_API.G_TRUE THEN

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('explosion date changed, activity shipping '
                                 || TO_CHAR ( L_LINE_ID ) , 3 ) ;
            END IF;
             IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '12,';
             END IF;

            --  Check if the line is shippable.
            --  If the line is shippable update Shipping
            --  Else complete the shipment activity and go to next record.

            IF nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN
                l_changed_attributes(l_shp_index).released_status := 'R';
            ELSE

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add
                    ('explosion date has changed for a non shippable line'
                     || TO_CHAR ( L_LINE_ID ) , 3 ) ;
                END IF;

                l_result_code    := 'NON_SHIPPABLE';

                -- Log a delayed request for Complete Activity, 1739574

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'log delayed request complet activity for '
                                      || L_LINE_REC.LINE_ID , 3 ) ;
                END IF;

                OE_Delayed_Requests_Pvt.Log_Request
                ( p_entity_code           => OE_GLOBALS.G_ENTITY_ALL,
                 p_entity_id              => l_line_rec.line_id,
                 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id   => l_line_rec.line_id,
                 p_request_type           => OE_GLOBALS.G_COMPLETE_ACTIVITY,
                 p_param1                 => OE_GLOBALS.G_WFI_LIN,
                 p_param2                 => l_line_rec.line_id,
                 p_param3                 => 'SHIP_LINE',
                 p_param4                 => l_result_code,
                 x_return_status          => l_return_status);
                  IF g_debug_call > 0 THEN
                     G_DEBUG_MSG := G_DEBUG_MSG || '13,';
                  END IF;
                GOTO END_UPDATE_SHIPPING_LOOP;
            END IF; -- if shippable
        END IF; -- param2 and lien at shipping


        ------------- assign other parameters to changed record --------

        l_changed_attributes(l_shp_index).source_header_id
                                     := l_line_rec.header_id;
         IF g_debug_call > 0 THEN
             G_DEBUG_MSG := G_DEBUG_MSG || '14,';
         END IF;

        IF l_line_rec.split_from_line_id IS NULL THEN
            l_changed_attributes(l_shp_index).original_source_line_id
                                     := l_line_rec.line_id;
        ELSE
            l_changed_attributes(l_shp_index).original_source_line_id
                                     := l_line_rec.split_from_line_id;
        END IF;

        l_changed_attributes(l_shp_index).source_line_id
                                     := l_line_rec.line_id;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('source line id : '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .SOURCE_LINE_ID , 3 ) ;
        END IF;

        l_changed_attributes(l_shp_index).sold_to_org_id
                                      :=  l_line_rec.sold_to_org_id;
        l_changed_attributes(l_shp_index).ship_from_org_id
                                      :=  l_line_rec.ship_from_org_id;
        l_changed_attributes(l_shp_index).ship_to_org_id
                                      :=  l_line_rec.ship_to_org_id;
        l_changed_attributes(l_shp_index).ship_to_contact_id
                                      :=  l_line_rec.ship_to_contact_id;
        l_changed_attributes(l_shp_index).deliver_to_org_id
                                      :=  l_line_rec.deliver_to_org_id;
        l_changed_attributes(l_shp_index).deliver_to_contact_id
                                      :=  l_line_rec.deliver_to_contact_id;
        l_changed_attributes(l_shp_index).intmed_ship_to_org_id
                                      :=  l_line_rec.intermed_ship_to_org_id;
        l_changed_attributes(l_shp_index).intmed_ship_to_contact_id
                                 :=  l_line_rec.intermed_ship_to_contact_id;
        l_changed_attributes(l_shp_index).ship_tolerance_above
                                      :=  l_line_rec.ship_tolerance_above;
        l_changed_attributes(l_shp_index).ship_tolerance_below
                                      :=  l_line_rec.ship_tolerance_below;
         IF g_debug_call > 0 THEN
             G_DEBUG_MSG := G_DEBUG_MSG || '15,';
         END IF;

        -- Changes for Bug-2579571
        l_changed_attributes(l_shp_index).source_line_set_id
                                      :=  l_line_rec.line_set_id;

        -- CMS Date Changes

        l_changed_attributes(l_shp_index).schedule_arrival_date
                                     :=   l_line_rec.schedule_arrival_date;
        l_changed_attributes(l_shp_index).promise_date
                                     :=   l_line_rec.promise_date;
        l_changed_attributes(l_shp_index).earliest_acceptable_date
                                     :=   l_line_rec.earliest_acceptable_date;
        l_changed_attributes(l_shp_index).latest_acceptable_date
                                     :=   l_line_rec.latest_acceptable_date;
        l_changed_attributes(l_shp_index).earliest_ship_date
                                     :=   l_line_rec.earliest_ship_date;

         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '16,';
         END IF;
        IF p_update_lines_tbl(l_line_index).request_unique_key1
                                      = OE_GLOBALS.G_OPR_CREATE THEN
            l_changed_attributes(l_shp_index).action_flag := 'S';
        ELSE
            l_changed_attributes(l_shp_index).action_flag := 'U';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('action flag = '
            ||L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ACTION_FLAG , 3 ) ;
        END IF;

        IF l_line_rec.shipped_quantity IS NOT NULL AND
           l_line_rec.shipped_quantity <> FND_API.G_MISS_NUM THEN
            l_changed_attributes(l_shp_index).shipped_flag := 'Y';
        ELSE
            l_changed_attributes(l_shp_index).shipped_flag := 'N';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('shipped flag '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .SHIPPED_FLAG , 3 ) ;
        END IF;
         IF g_debug_call > 0 THEN
             G_DEBUG_MSG := G_DEBUG_MSG || '17,';
         END IF;


        -------------- line is shipped with qty = 0 ---------------------
        -- If a line is being deleted then the ordered quantity to be notified
        -- to shipping will be 0.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('under shipment tolerance : '
                              ||L_LINE_REC.SHIP_TOLERANCE_BELOW , 3 ) ;
            oe_debug_pub.add(p_update_lines_tbl(l_line_index).param5
                         || '-- param5---', 1);
	END IF;

        IF  p_update_lines_tbl(l_line_index).param5 = FND_API.G_TRUE AND
            nvl(l_line_rec.shipped_quantity,0) = 0  AND
            nvl(l_line_rec.ordered_quantity,0) <> 0 AND          -- bug 2129287
            nvl(l_line_rec.ship_tolerance_below,0) < 100 THEN --1829490
             IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '18,';
             END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('ordered quantity has been reduced' , 3 ) ;
            END IF;

            -- ordered quantity changed check for the shipment status.

            Check_Shipment_Line( p_line_rec    => l_line_rec,
                                 x_result_out    => l_x_result_out);
            IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '19,';
            END IF;
            -- 4437814 start changes
            IF (l_line_rec.item_type_code = 'CONFIG'
               OR
                (l_line_rec.ato_line_id = l_line_rec.line_id AND
                l_line_rec.item_type_code IN ('STANDARD','OPTION'))) THEN
               --Get the activity result
                OE_LINE_FULLFILL.Get_Activity_Result
                (p_item_type             => OE_GLOBALS.G_WFI_LIN
                ,p_item_key              => l_line_rec.line_id
                ,p_activity_name         => 'SHIP_LINE'
                ,x_return_status         => l_return_status
                ,x_activity_result       => l_activity_result
                ,x_activity_status_code  => l_activity_status
                ,x_activity_id           => l_activity_id );

              IF NVL(l_activity_status,'NON_NOTIFIED') <> 'NOTIFIED' THEN
                 l_shipline_notified := 'N';
              END IF;
             END IF;
           -- 4437814 end changes
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('shipline notified flag:' || l_shipline_notified) ;
            END IF;
            IF l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW OR
               l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE OR
               l_x_result_out = OE_GLOBALS.G_FULLY_SHIPPED OR
               l_x_result_out = OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE THEN
             IF l_shipline_notified = 'Y'THEN  --4437814
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add
                    ('line shipped within tolerance, complete ship_line',3);
                END IF;
                 IF g_debug_call > 0 THEN
                     G_DEBUG_MSG := G_DEBUG_MSG || '20,';
                 END IF;

                -- Start 1829490

                /* AG: Change to check if the ASO is installed and then only
                   call Process_Requests_And_Notify */

                UPDATE oe_order_lines
                SET    flow_status_code = 'SHIPPED',
                       shipped_quantity = 0,
                       last_update_date = SYSDATE,
                       last_updated_by = FND_GLOBAL.USER_ID,
                       last_update_login = FND_GLOBAL.LOGIN_ID
                WHERE  line_id    = l_line_rec.line_id;
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || '21,';
                 END IF;

                l_old_line_tbl(1)              := l_line_rec;
                l_line_tbl(1)                  :=  l_line_rec;
                l_line_tbl(1).flow_status_code := 'SHIPPED';
                l_line_tbl(1).shipped_quantity := 0;

                -- added for notification framework, pack H onwards

                IF ((OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508') OR
                   (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y'))
                THEN
                     IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || '22,';
                     END IF;
                    OE_ORDER_UTIL.Update_Global_Picture
                    (p_Upd_New_Rec_If_Exists =>False,
                     p_header_id             => l_line_rec.header_id,
                     p_old_line_rec          => l_old_line_tbl(1),
                     p_line_rec              => l_line_tbl(1),
                     p_line_id               => l_line_rec.line_id,
                     x_index                 => l_index,
                     x_return_status         => l_return_status);

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'after update global picture, status: '
                                            || L_RETURN_STATUS ) ;
                        oe_debug_pub.add(  'global picture index: '
                                            || L_INDEX , 1 ) ;
                    END IF;

                    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    IF l_index IS NOT NULL THEN

                        --update Global Picture directly


                        OE_ORDER_UTIL.g_old_line_tbl(l_index)
                                 := l_old_line_tbl(1);
                        OE_ORDER_UTIL.g_line_tbl(l_index)
                                 := OE_ORDER_UTIL.g_old_line_tbl(l_index);
                        OE_ORDER_UTIL.g_line_tbl(l_index).line_id
                                 := l_line_tbl(1).line_id;
                        OE_ORDER_UTIL.g_line_tbl(l_index).header_id
                                 := l_line_tbl(1).header_id;
                        OE_ORDER_UTIL.g_line_tbl(l_index).flow_status_code
                                 := l_line_tbl(1).flow_status_code;
                        OE_ORDER_UTIL.g_line_tbl(l_index).shipped_quantity
                                 := l_line_tbl(1).shipped_quantity;
                        OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date
                                 := SYSDATE;
                        OE_ORDER_UTIL.g_line_tbl(l_index).last_updated_by
                                 := FND_GLOBAL.USER_ID;
                        OE_ORDER_UTIL.g_line_tbl(l_index).last_update_login
                                 := FND_GLOBAL.LOGIN_ID;

                        IF l_debug_level  > 0 THEN
                          oe_debug_pub.add
                           ('global flow status code after update: '
                || OE_ORDER_UTIL.G_LINE_TBL( L_INDEX ).FLOW_STATUS_CODE ,1);
                        END IF;

                    END IF; -- if index is not null

                ELSE   --pre-pack H

                    IF OE_GLOBALS.G_ASO_INSTALLED = 'Y' THEN


                        OE_Order_PVT.Process_Requests_And_Notify
                       (  p_process_requests    => FALSE
                        , p_notify              => TRUE
                        , p_process_ack         => FALSE
                        , x_return_status       => l_return_status
                        , p_line_tbl            => l_line_tbl
                        , p_old_line_tbl        => l_old_line_tbl);

                        IF l_debug_level  > 0 THEN
                          oe_debug_pub.add
                          ('return status Process_Requests_And_Notify() '||L_RETURN_STATUS , 3 ) ;
                        END IF;

                        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                            RAISE FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                        THEN
                            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;  -- aso_installed
                END IF;   -- code_release_level

                l_line_rec.flow_status_code := 'SHIPPED';
                l_line_rec.shipped_quantity := 0;
                -- END 1829490

                ------------------------  continue -------------------------

                l_changed_attributes(l_shp_index).ordered_quantity :=  0;

                -- odaboval : Begin of OPM Changes
                l_changed_attributes(l_shp_index).ordered_quantity2 := NULL;

                /* IF (INV_GMI_RSV_BRANCH.Process_Branch -- INVCONV NOT NEEDED
                   ( p_organization_id => l_line_rec.ship_from_org_id) ) THEN
                    IF g_debug_call > 0 THEN
                       G_DEBUG_MSG := G_DEBUG_MSG || '28,';
                    END IF;
                   GMI_RESERVATION_UTIL.Get_OPM_Item_From_Apps
                   ( p_organization_id     => l_line_rec.ship_from_org_id,
                     p_inventory_item_id   => l_line_rec.inventory_item_id,
                     x_ic_item_mst_rec     => l_ic_item_mst_rec,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data);

                    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                      IF l_debug_level  > 0 THEN
                        oe_debug_pub.add
               (' ( MLP_DBG ) CALL TO GET_OPM_ITEM_FROM APPS FAILED' , 1 ) ;
                      END IF;
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;    */

							 IF oe_line_util.dual_uom_control   -- INVCONV  Process_Characteristics
  							(l_line_rec.inventory_item_id,l_line_rec.ship_from_org_id,l_item_rec) THEN
  								 IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV
                   -- IF (l_ic_item_mst_rec.dualum_ind > 0) THEN  -- ONVCONV
                      l_changed_attributes(l_shp_index).ordered_quantity2 := 0;
                   END IF;
               END IF;
               ---------------------- odaboval : End of OPM Changes

               IF l_line_rec.item_type_code = 'CONFIG' THEN

                   IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('config line, complete ato model '
                                      || l_line_rec.ato_line_id, 2);
                   END IF;

                   Handle_Config_Parent
                   ( p_ato_line_id    => l_line_rec.ato_line_id);
               END IF;

               l_result_code    := 'SHIP_CONFIRM';

               -- Log a delayed request for Complete Activity, 1739574
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add( 'LOGGING DELAYED REQUEST FOR '
                                     || L_LINE_REC.LINE_ID , 3 ) ;
               END IF;

               OE_Delayed_Requests_Pvt.Log_Request
               ( p_entity_code             => OE_GLOBALS.G_ENTITY_ALL,
                 p_entity_id               => l_line_rec.line_id,
                 p_requesting_entity_code  => OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id    => l_line_rec.line_id,
                 p_request_type            => OE_GLOBALS.G_COMPLETE_ACTIVITY,
                 p_param1                  => OE_GLOBALS.G_WFI_LIN,
                 p_param2                  => l_line_rec.line_id,
                 p_param3                  => 'SHIP_LINE',
                 p_param4                  => l_result_code,
                 x_return_status           => l_return_status);
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-4-31';
                 END IF;
                IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                IF  l_line_rec.arrival_set_id IS NOT NULL AND
                    l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
                    -- Update the set status to closed.
                   UPDATE  OE_SETS
                   SET     SET_STATUS = 'C'
                   WHERE   SET_ID = l_line_rec.arrival_set_id;

                   IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('SET IS CLOSED : '
                     ||TO_CHAR ( L_LINE_REC.ARRIVAL_SET_ID ) , 3 ) ;
                   END IF;
                END IF;
                END IF; --4437814
            ELSE -- regular qtu update

                l_changed_attributes(l_shp_index).ordered_quantity
                            :=  l_line_rec.ordered_quantity;

                -- odaboval : Begin of OPM Changes
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || '33,';
                 END IF;

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add( ' ( MLP_DBG ) ORDERED_QUANTITY IS '
              || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ORDERED_QUANTITY , 1 ) ;
                END IF;

                l_changed_attributes(l_shp_index).ordered_quantity2
                          := l_line_rec.ordered_quantity2;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  ' ( MLP_DBG ).ORDERED_QUANTITY2 IS '
             || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ORDERED_QUANTITY2 , 1 ) ;
               END IF;

               -- odaboval : End of OPM Changes
            END IF; --if shipped within tolerance below
             IF g_debug_call > 0 THEN
                 G_DEBUG_MSG := G_DEBUG_MSG || '34,';
             END IF;
        ELSE

            l_changed_attributes(l_shp_index).ordered_quantity
                            :=  l_line_rec.ordered_quantity;
            -- odaboval : Begin of OPM Changes
	    --{ bug3831490 contd
            IF l_line_rec.item_type_code = 'CONFIG' AND
	       p_update_lines_tbl(l_line_index).request_unique_key1 =
	            OE_GLOBALS.G_OPR_DELETE THEN

               l_changed_attributes(l_shp_index).ordered_quantity := 0;
	       IF l_debug_level > 0 THEN
	          OE_DEBUG_PUB.Add('This is Config cancel/delete case!',1);
		  OE_DEBUG_PUB.Add('Overrriden Ord qty to 0',1);
               END IF;

	    END IF;
	    --bug3831490 ends }


            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( ' ( MLP_DBG ).ORDERED_QUANTITY IS '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ORDERED_QUANTITY , 1 ) ;
            END IF;

            l_changed_attributes(l_shp_index).ordered_quantity2
                             := l_line_rec.ordered_quantity2;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(' ( MLP_DBG ).ORDERED_QUANTITY2 IS '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ORDERED_QUANTITY2 , 1 ) ;
            END IF;
            -- odaboval : End of OPM Changes
        END IF; -- p_update_lines_tbl(l_line_index).param5 etc


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ORDERED QUANTITY '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .ORDERED_QUANTITY, 3 ) ;
        END IF;

        l_changed_attributes(l_shp_index).order_quantity_uom
                              :=  l_line_rec.order_quantity_uom;

        -- odaboval : Begin of OPM Changes
        l_changed_attributes(l_shp_index).ordered_quantity_uom2
                              := l_line_rec.ordered_quantity_uom2;
        l_changed_attributes(l_shp_index).preferred_grade
                              := l_line_rec.preferred_grade;
        -- odaboval : End of OPM Changes

        -- #1818531
        -- l_changed_attributes(l_shp_index).revision
        -- :=  l_line_rec.item_revision;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '36,';
         END IF;

        l_changed_attributes(l_shp_index).date_requested
                              :=  l_line_rec.request_date;
        l_changed_attributes(l_shp_index).date_scheduled
                              :=  l_line_rec.schedule_ship_date;
        l_changed_attributes(l_shp_index).shipping_method_code
                              :=  l_line_rec.shipping_method_code;
        l_changed_attributes(l_shp_index).freight_carrier_code
                              :=  l_line_rec.freight_carrier_code;
        l_changed_attributes(l_shp_index).freight_terms_code
                              :=  l_line_rec.freight_terms_code;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FREIGHT TERMS CODE '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .FREIGHT_TERMS_CODE , 3 ) ;
        END IF;

        l_changed_attributes(l_shp_index).shipment_priority_code
                              :=  l_line_rec.shipment_priority_code;
        l_changed_attributes(l_shp_index).fob_code
                              :=  l_line_rec.fob_point_code;
        --l_changed_attributes(l_shp_index).customer_item_id
        -- :=  l_line_rec.customer_item_id;

   -- Above condition is uncommented for the bug 2939731

        IF (l_line_rec.item_identifier_type = 'CUST') THEN
         -- Added for the bug 3762407
          l_changed_attributes(l_shp_index).customer_item_id :=  l_line_rec.ordered_item_id;

        END IF;

        l_changed_attributes(l_shp_index).dep_plan_required_flag
                              :=  l_line_rec.dep_plan_required_flag;
        l_changed_attributes(l_shp_index).customer_dock_code
                              :=  l_line_rec.customer_dock_code;
        l_changed_attributes(l_shp_index).customer_prod_seq
                              :=  l_line_rec.cust_production_seq_num;

        -- Alcoa enhancement three fields added

        l_changed_attributes(l_shp_index).customer_job
                              :=  l_line_rec.customer_job;
        l_changed_attributes(l_shp_index).cust_model_serial_number
                              :=  l_line_rec.cust_model_serial_number;
        l_changed_attributes(l_shp_index).customer_production_line
                              :=  l_line_rec.customer_production_line;


        l_changed_attributes(l_shp_index).top_model_line_id
                              :=  l_line_rec.top_model_line_id;
        l_changed_attributes(l_shp_index).ship_set_id
                              :=  l_line_rec.ship_set_id;
        l_changed_attributes(l_shp_index).ato_line_id
                              :=  l_line_rec.ato_line_id;
        l_changed_attributes(l_shp_index).arrival_set_id
                              :=  l_line_rec.arrival_set_id;
        l_changed_attributes(l_shp_index).ship_model_complete_flag
                              :=  l_line_rec.ship_model_complete_flag;
        l_changed_attributes(l_shp_index).cust_po_number
                              :=  l_line_rec.cust_po_number;
        l_changed_attributes(l_shp_index).shipping_instructions
                              :=  l_line_rec.shipping_instructions;
        l_changed_attributes(l_shp_index).packing_instructions
                              :=  l_line_rec.packing_instructions;
        l_changed_attributes(l_shp_index).subinventory
                              :=  l_line_rec.subinventory;

        IF l_line_rec.top_model_line_id IS NOT NULL AND
           nvl(l_line_rec.model_remnant_flag, 'N') = 'N' THEN
           l_force_ui := 'Y';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SUB-INVENTORY '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .SUBINVENTORY , 3 ) ;
        END IF;



        l_changed_attributes(l_shp_index).project_id
                              :=  l_line_rec.project_id;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '39,';
         END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROJECT_ID:'
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .PROJECT_ID , 3 ) ;
        END IF;

	l_changed_attributes(l_shp_index).task_id
                              :=  l_line_rec.task_id;


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'TASK_ID:'
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .TASK_ID , 3 ) ;
        END IF;

         IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '40,';
         END IF;

        -- Changes for passing the line number. Enhancement 1495329

        IF l_line_rec.service_number is not null THEN
           IF l_line_rec.option_number is not null THEN
               IF l_line_rec.component_number is not null THEN

                   l_line_number
                     := l_line_rec.line_number||'.'
                        ||l_line_rec.shipment_number||'.'
                        ||l_line_rec.option_number||'.'||
                        l_line_rec.component_number||'.'||
                        l_line_rec.service_number;
               ELSE
                   l_line_number := l_line_rec.line_number||'.'
                                   ||l_line_rec.shipment_number||'.'||
                                   l_line_rec.option_number||'..'
                                   ||l_line_rec.service_number;
               END IF;
                IF g_debug_call > 0 THEN
                   G_DEBUG_MSG := G_DEBUG_MSG || '41,';
                END IF;

               --- if a option is not attached
           ELSE
              IF l_line_rec.component_number is not null THEN
                  l_line_number := l_line_rec.line_number||'.'
                                   ||l_line_rec.shipment_number||'..'||
               l_line_rec.component_number||'.'||l_line_rec.service_number;
            ELSE
               l_line_number := l_line_rec.line_number||'.'
                       ||l_line_rec.shipment_number||
               '...'||l_line_rec.service_number;
            END IF;

          END IF; /* if option number is not null */

         -- if the service number is null
        ELSE
          IF l_line_rec.option_number is not null THEN
            IF l_line_rec.component_number is not null THEN
               l_line_number := l_line_rec.line_number||'.'||l_line_rec.shipment_number||'.'||
               l_line_rec.option_number||'.'||l_line_rec.component_number;
            ELSE
               l_line_number := l_line_rec.line_number||'.'||l_line_rec.shipment_number||'.'||
               l_line_rec.option_number;
            END IF;

            --- if a option is not attached
          ELSE
            IF l_line_rec.component_number is not null THEN
               l_line_number := l_line_rec.line_number||'.'||l_line_rec.shipment_number||'..'||
               l_line_rec.component_number;
            ELSE
               l_line_number := l_line_rec.line_number||'.'||l_line_rec.shipment_number;
            END IF;

          END IF; /* if option number is not null */

        END IF; /* if service number is not null */



        l_changed_attributes(l_shp_index).line_number :=  l_line_number;

        /* Added below code for ER 6110708 */
        l_changed_attributes(l_shp_index).inventory_item_id := l_line_rec.inventory_item_id;
        -- Commented for bug 7665831
        -- This assignment is already done above as a part of bugfix 3762407

        -- l_changed_attributes(l_shp_index).customer_item_id := l_line_rec.ordered_item_id;
        /* End of changes for ER 6110708 */

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('LINE-NUMBER '
            || L_CHANGED_ATTRIBUTES ( L_SHP_INDEX ) .LINE_NUMBER , 3 ) ;
        END IF;

       <<END_UPDATE_SHIPPING_LOOP>>
        NULL;

    END LOOP; -- big loop

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'COMMING OUT LOOP , NUMBER OF RECORDS '
                           ||L_CHANGED_ATTRIBUTES.COUNT , 3 ) ;

    END IF;
    IF g_debug_call > 0 THEN
       G_DEBUG_MSG := G_DEBUG_MSG || '44,';
    END IF;


    ------------------ Call update_shipping_attribute.-------------

    IF  l_changed_attributes.count > 0 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('CALLING WSH UPDATE_SHIPPING_ATTRIBUTES' , 2 ) ;

        END IF;

        IF (NVL(FND_PROFILE.VALUE('WSH_ENABLE_DCP'), -1)  = 1 OR
            NVL(FND_PROFILE.VALUE('WSH_ENABLE_DCP'), -1)  = 2) AND
            WSH_DCP_PVT.G_CALL_DCP_CHECK = 'Y' THEN
          l_msg_data                   := 'CHECK_WSH_DCP';
          WSH_DCP_PVT.G_INIT_MSG_COUNT := fnd_msg_pub.count_msg;
        END IF;

        SAVEPOINT CATCH_DCP;
        <<BEFORE_CATCH_DCP>>

        WSH_INTERFACE.Update_Shipping_Attributes
        ( p_source_code              =>    l_source_code
         ,p_changed_attributes       =>    l_changed_attributes
         ,x_return_status            =>    l_return_status);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURNED FROM WSH UPDATE_SHIPPING_ATTRIBUTES '
                              || L_RETURN_STATUS , 2 ) ;
        END IF;

        IF g_debug_call > 0 THEN
          G_DEBUG_MSG := G_DEBUG_MSG || '46,';
        END IF;

        IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            --Changes for Bug - 2898616
            IF l_force_ui = 'Y' THEN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Setting the global to force UI Block',2);
               END IF;
               OE_GLOBALS.G_FORCE_CLEAR_UI_BLOCK := 'Y';
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	-- 3571148 changes
		IF l_debug_level  > 0 THEN
       		   oe_debug_pub.add(  ' INSIDE EXPECTED ERROR' , 1 ) ;
	        END IF;
      		OE_MSG_PUB.Transfer_Msg_Stack(p_type => 'ERROR' ); --bug4741573
      		l_msg_count   := OE_MSG_PUB.COUNT_MSG;

      		FOR I IN 1..l_msg_count LOOP
        		l_msg_data :=  OE_MSG_PUB.Get(I,'F');
        		IF l_debug_level  > 0 THEN
            			oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
        		END IF;
            --code fix bug 6391881 :START
             IF ( InStr(l_msg_data, 'WSH_NO_DATA_FOUND') > 0 ) THEN
              oe_debug_pub.ADD('Bug 6391881: Setting l_wsh_no_data_found to true...' , 1);
              l_wsh_no_data_found :=  TRUE;
            END IF;
            --code fix bug 6391881 :END
      		END LOOP; -- 3571148 ends
                IF l_force_ui = 'Y' THEN
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Setting the global to force UI Block',2);
                   END IF;
                   OE_GLOBALS.G_FORCE_CLEAR_UI_BLOCK := 'Y';
                END IF;
                -- Start: Changes for bug 6391881
              -- Check if we are coming from wsh_no_data_found error.
              IF ( l_wsh_no_data_found = TRUE) THEN
                oe_debug_pub.ADD('Bug 6391881::: Checking for cancellation...' , 1);
                FOR I in 1..l_changed_attributes.count LOOP
                  IF ( l_changed_attributes(I).action_flag = 'U' AND
                      l_changed_attributes(I).ordered_quantity = 0 ) THEN
                      oe_debug_pub.ADD('Bug 6391881::: Cancellation is YES.', 1);
                      -- Check for existence of non-cancelled delivery details.
                      -- If they exist, cancellation is not allowed.
                      DECLARE
                        l_non_cxl_dd_count  NUMBER  :=  -1;
                        l_exist_dd_count    NUMBER  :=  -1;
                      BEGIN
                        SELECT  Count(*)
                            INTO l_exist_dd_count
                        FROM    wsh_delivery_details
                        WHERE   source_line_id = l_changed_attributes(I).source_line_id
                        AND     source_code    = 'OE'
                        ;
                        IF ( l_exist_dd_count > 0 ) THEN
                          SELECT  Count(*)
                              INTO l_non_cxl_dd_count
                          FROM    wsh_delivery_details wdd, oe_order_lines line
                          WHERE   wdd.source_line_id = line.line_id
                          AND     wdd.source_code = 'OE'
                          AND     wdd.source_line_id = l_changed_attributes(I).source_line_id
                          AND     Nvl(wdd.released_status, 'N') <> 'D'
                          ;
                          oe_debug_pub.ADD('Bug 6391881::: l_non_cxl_dd_count: '
                                          || l_non_cxl_dd_count, 1);
                          IF ( l_non_cxl_dd_count > 0 ) THEN
                            oe_debug_pub.ADD('Bug 6391881::: Setting l_ok_to_cancel to false...', 1);
                            l_ok_to_cancel := FALSE;
                          ELSE
                            oe_debug_pub.ADD('Bug 6391881::: Setting l_return_status to SUCCESS...', 1);
                            l_msg_data      :=  NULL;
                            l_return_status := FND_API.G_RET_STS_SUCCESS;
                            oe_msg_pub.delete_msg;
                          END IF;
                        ELSE  -- we don't cancel a line when delivery details go missing.
                          l_ok_to_cancel := FALSE;
                        END IF; -- on l_exist_dd_count
                      EXCEPTION
                        WHEN OTHERS THEN
                          RAISE;
                      END;
                  END IF;
                END LOOP;
              END IF; -- on l_wsh_no_data_found

            IF l_wsh_no_data_found = TRUE THEN
              oe_debug_pub.ADD('Bug 6391881::: l_wsh_no_data_found is true.', 1);
            ELSE
              oe_debug_pub.ADD('Bug 6391881::: l_wsh_data_found is false.', 1);
            END IF;

            IF l_ok_to_cancel = TRUE THEN
              oe_debug_pub.ADD('Bug 6391881::: l_ok_to_cancel is true.', 1);
            ELSE
              oe_debug_pub.ADD('Bug 6391881::: l_ok_to_cancel is false.', 1);
            END IF;

            IF NOT ( l_wsh_no_data_found = TRUE AND l_ok_to_cancel = TRUE ) THEN
              RAISE fnd_api.g_exc_error;
            END IF;
            -- End:   Changes for bug 6391881

             IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '47,';
             END IF;

        ELSE ------- success, call catch DCP code ----------

          -- temp for testing only
          -- update oe_order_lines set ship_from_org_id = 99
          -- where line_id = l_changed_attributes(1).source_line_id;

          IF l_changed_attributes.COUNT = 1 AND
             l_changed_attributes(1).action_flag = 'D' THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('action delete, do not call dcp here',2);
            END IF;
            l_msg_data := null;
          END IF;

          IF l_msg_data = 'CHECK_WSH_DCP' THEN

            l_header_id := nvl(l_line_rec.header_id, l_header_id);
            IF l_header_id is NULL THEN
              SELECT header_id
              INTO   l_header_id
              FROM   oe_order_lines
              WHERE  line_id = l_changed_attributes(1).source_line_id;
            END IF;


            l_line_id := null;
            IF l_changed_attributes.COUNT = 1 THEN
              l_line_id := l_changed_attributes(1).source_line_id;
            END IF;

            BEGIN

              WSH_DCP_PVT.g_dc_table.DELETE;

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('CALLING WSH_DCP_PVT.Check_Scripts '
                                  ||'l_header-'|| l_header_id, 1);
              END IF;

              WSH_DCP_PVT.Check_Scripts
              ( p_source_header_id  => l_header_id
               ,p_source_line_id    => l_line_id
               ,x_data_inconsistent => l_msg_data);

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add
                ('CALLING WSH_DCP_PVT.Post_Process '|| l_msg_data, 1);
              END IF;

              WSH_DCP_PVT.Post_Process
              ( p_action_code     => 'OM'
               ,p_raise_exception => 'Y');

            EXCEPTION
              WHEN WSH_DCP_PVT.dcp_caught THEN
                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('OM call to WSH DCP Caught,
                                    rollback and call wsh again', 1);
                END IF;

                ROLLBACK to CATCH_DCP;
                GOTO BEFORE_CATCH_DCP;

              WHEN others THEN
                IF l_debug_level  > 0 THEN
                  oe_msg_pub.add_text
                  ('Update_Shipping_From_OE, DCP post process'|| sqlerrm);
                  oe_debug_pub.add('OM call to WSH DCP,others '|| sqlerrm, 1);
                END IF;
            END;
          END IF; -- profile is yes
        END IF; -- return status check

    ELSE

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('DO NOT CALL SHIPPING API,RETURN SUCCESS ',3);
        END IF;

    END IF;-- count is 0

    OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'LINE');
    x_return_status := l_return_status;


-- code changes for 5590106 starts here.

 FOR I in 1..l_changed_attributes.count LOOP

        IF l_changed_attributes(I).action_flag = 'U' AND
           l_changed_attributes(I).ordered_quantity = 0 THEN

                OE_DEBUG_PUB.add('order line id '||l_changed_attributes(I).source_line_id,5);
                OE_DEBUG_PUB.add('action flag '||l_changed_attributes(I).action_flag,5);
                OE_DEBUG_PUB.add('ordered quantity '||l_changed_attributes(I).ordered_quantity,5);

                   BEGIN

                         SELECT COUNT(*)
                         INTO   l_cxl_dd_count
                         FROM   WSH_DELIVERY_DETAILS
                         WHERE  SOURCE_LINE_ID = l_changed_attributes(I).source_line_id
                         AND    SOURCE_CODE = 'OE'
                         AND    RELEASED_STATUS <> 'D';

                         IF l_cxl_dd_count > 0 THEN
                            OE_DEBUG_PUB.add('DD is not cancelled',1);
                            fnd_message.set_name('ONT', 'OE_CANCEL_NOTHING');
                            oe_msg_pub.add;
                            RAISE FND_API.G_EXC_ERROR ;

                         END IF;

                   EXCEPTION WHEN OTHERS THEN
                         RAISE;
                   END;
          END IF;

    END LOOP;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'returning from UPDATE_SHIPPING_FROM_OE' , 1 ) ;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                   'Update_Shipping_From_OE'
                );
        END IF;
        OE_MSG_PUB.Save_API_Messages(); --bug 4516453
        OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'LINE');
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || 'E5';
         END IF;
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Save_API_Messages(); --bug 4516453
        OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'LINE');
          IF g_debug_call > 0 THEN
             G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-4';
          END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                   'Update_Shipping_From_OE'
                );
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR MESSAGE : '||SQLERRM , 1 ) ;
        END IF;
        OE_MSG_PUB.Save_API_Messages(); --bug 4516453
        OE_MSG_PUB.Reset_Msg_Context (p_entity_code => 'LINE');
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-5';
         END IF;
END Update_Shipping_From_OE;

/*----------------------------------------------------------------
PROCEDURE Update_Shipping_PVT
-----------------------------------------------------------------*/
PROCEDURE Update_Shipping_PVT
(
	p_line_id			IN	NUMBER
,	p_hold_type			IN	VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,	p_shipping_activity	IN	VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
, x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_update_lines_tbl	OE_ORDER_PUB.Request_Tbl_Type;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PVT.UPDATE_SHIPPING_PVT' , 1 ) ;
	END IF;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '51,';
         END IF;

	-- Prepare the table for calling Update_Shipping_From_OE

	l_update_lines_tbl(1).entity_id := p_line_id;
	l_update_lines_tbl(1).param1 	:= FND_API.G_FALSE;
	l_update_lines_tbl(1).param2 	:= FND_API.G_FALSE;

	IF 	p_hold_type IS NOT NULL AND
		p_hold_type <> FND_API.G_MISS_CHAR THEN

		l_update_lines_tbl(1).param3 := p_hold_type;

	END IF;

	IF 	p_shipping_activity IS NOT NULL AND
		p_shipping_activity <> FND_API.G_MISS_CHAR THEN

		l_update_lines_tbl(1).param4 := p_shipping_activity;

	END IF;

	Update_Shipping_From_OE
	(
		p_update_lines_tbl	=>	l_update_lines_tbl,
		x_return_status		=>	x_return_status
	);

	IF	x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF	x_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PVT.UPDATE_SHIPPING_PVT' , 1 ) ;
	END IF;
         IF g_debug_call > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '54,';
         END IF;
EXCEPTION

	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Update_Shipping_PVT'
				);
			END IF;
                         IF g_debug_call > 0 THEN
                             G_DEBUG_MSG := G_DEBUG_MSG || 'E6,';
                         END IF;
    WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
	WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Update_Shipping_PVT'
				);
			END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SQLERRM , 1 ) ;
		END IF;
                 IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || 'E7,';
                 END IF;
	NULL;
END Update_Shipping_PVT;

/*-------------------------------------------------------------------
PROCEDURE Check_Shipment_Line

Line_id should be passed to check the shipment across the split lines.
If line id is not passed the ordered and shipped quantity must be passed
in order to do the check for shipment.
--------------------------------------------------------------------*/
PROCEDURE Check_Shipment_Line --INVCONV PAL OPEN ISSUE
( p_line_rec          IN     OE_Order_Pub.Line_Rec_Type
 ,p_shipped_quantity  IN     NUMBER DEFAULT 0
 ,x_result_out        OUT NOCOPY VARCHAR2 )
IS
  l_line_id                   NUMBER;
  l_line_rec                  OE_Order_Pub.Line_Rec_Type;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_ordered_quantity          NUMBER := 0;
  l_shipped_quantity          NUMBER := 0;
  l_shipping_quantity         NUMBER := 0;
  l_temp_shipped_quantity     NUMBER := 0;
  l_tolerance_quantity_below  NUMBER := 0;
  l_tolerance_quantity_above  NUMBER := 0;
  l_ship_tolerance_below      NUMBER := 0;
  l_ship_tolerance_above      NUMBER := 0;
  l_validated_quantity        NUMBER := 0;
  l_primary_quantity          NUMBER := 0;
  l_qty_return_status         VARCHAR2(1);
  l_x_return_status           VARCHAR2(1);
  l_org_id                    NUMBER;
  l_wdd_count                 NUMBER :=0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add
   ('ENTERING OE_SHIPPING_INTEGRATION_PVT.CHECK_SHIPMENT_LINE : '
    ||TO_CHAR ( P_LINE_REC.LINE_ID ) ||'/'||TO_CHAR ( P_SHIPPED_QUANTITY )
    ||'/'||P_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
  END IF;
   IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '61';
   END IF;

  IF  p_line_rec.top_model_line_id IS NOT NULL AND
      p_line_rec.top_model_line_id <> FND_API.G_MISS_NUM AND
      NVL(p_line_rec.model_remnant_flag,'N') = 'N' THEN


    SELECT  line_id,
            line_set_id,
            ordered_quantity,
            shipped_quantity,
            shipping_quantity,
            ship_tolerance_below,
            ship_tolerance_above,
            item_type_code,
            inventory_item_id,
            order_quantity_uom,
            shipping_quantity_uom
    INTO    l_line_rec.line_id,
            l_line_rec.line_set_id,
            l_line_rec.ordered_quantity,
            l_line_rec.shipped_quantity,
            l_line_rec.shipping_quantity,
            l_line_rec.ship_tolerance_below,
            l_line_rec.ship_tolerance_above,
            l_line_rec.item_type_code,
            l_line_rec.inventory_item_id,
            l_line_rec.order_quantity_uom,
            l_line_rec.shipping_quantity_uom
    FROM    OE_ORDER_LINES
    WHERE   line_id = p_line_rec.top_model_line_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('SHIPPED QUANTITY : '
                    ||TO_CHAR ( L_LINE_REC.SHIPPED_QUANTITY ) , 3 ) ;
    END IF;
     IF g_debug_call > 0 THEN
       G_DEBUG_MSG := G_DEBUG_MSG || '62,';
     END IF;

  ELSE
    l_line_rec:= p_line_rec;
  END IF; -- if part of model


  IF l_line_rec.ship_tolerance_below IS NULL OR
     l_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
    l_ship_tolerance_below  := 0;
  ELSE
    l_ship_tolerance_below  := l_line_rec.ship_tolerance_below;
  END IF;


  IF l_line_rec.ship_tolerance_above IS NULL OR
    l_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN

    l_ship_tolerance_above  := 0;
  ELSE
    l_ship_tolerance_above  := l_line_rec.ship_tolerance_above;
  END IF;



  -- Call Get_Quantity to get the cumulative ordered and shipped quantity if
  -- this line is part of any line set - only for oe table

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LINE SET ID '||TO_CHAR(L_LINE_REC.LINE_SET_ID),3);
  END IF;

  IF l_line_rec.line_set_id IS NOT NULL AND
     l_line_rec.line_set_id <> FND_API.G_MISS_NUM THEN

     IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '64';
     END IF;

    OE_Shipping_Integration_PUB.Get_Quantity
    (p_api_version_number => 1.0,
     p_line_id            => l_line_rec.line_id,
     p_line_set_id        => l_line_rec.line_set_id,
     x_ordered_quantity   => l_ordered_quantity,
     x_shipped_quantity   => l_shipped_quantity,
     x_shipping_quantity  => l_shipping_quantity,
     x_return_status      => l_x_return_status,
     x_msg_count          => l_msg_count,
     x_msg_data           => l_msg_data);

    IF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF   l_x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE

    l_ordered_quantity      := l_line_rec.ordered_quantity;
    l_shipped_quantity      := nvl(l_line_rec.shipped_quantity,0);
    l_shipping_quantity     := nvl(l_line_rec.shipping_quantity,0);

  END IF;


  --********
  l_shipped_quantity := nvl(l_shipped_quantity,0) + nvl(p_shipped_quantity,0);
  --********

  -- Calculate the tolerance quantities

  l_tolerance_quantity_below:=l_ordered_quantity*l_ship_tolerance_below/100;
  l_tolerance_quantity_above:=l_ordered_quantity*l_ship_tolerance_above/100;

  IF l_tolerance_quantity_below <> trunc(l_tolerance_quantity_below) THEN

    IF l_line_rec.item_type_code IN
            ('MODEL', 'OPTION','KIT','CLASS','INCLUDED','CONFIG') THEN
      l_tolerance_quantity_below := FLOOR(l_tolerance_quantity_below);

    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING INVENTORY VALIDATE QUANTITY : '
                          ||L_QTY_RETURN_STATUS , 2 ) ;
      END IF;


      Inv_Decimals_PUB.Validate_Quantity
      ( p_item_id          => l_line_rec.inventory_item_id,
        p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
        p_input_quantity   => l_tolerance_quantity_below,
        p_uom_code         => l_line_rec.order_quantity_uom,
        x_output_quantity  => l_validated_quantity,
        x_primary_quantity => l_primary_quantity,
        x_return_status    => l_qty_return_status);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RET STS FROM INV API : '||L_QTY_RETURN_STATUS , 2 ) ;
      END IF;

       IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '6-6';
       END IF;

      IF l_qty_return_status IN ('W','S') THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('TOL BELOW/VALID QTY : '
          ||TO_CHAR ( L_TOLERANCE_QUANTITY_BELOW )
          ||'/'||TO_CHAR ( L_VALIDATED_QUANTITY ) , 3 ) ;
        END IF;

        l_tolerance_quantity_below := l_validated_quantity;
      ELSE
        l_tolerance_quantity_below := FLOOR(l_tolerance_quantity_below);
      END IF; -- if qty stst is W, S
    END IF; -- item type =model...
  END IF; -- if tol in decimal


  IF l_tolerance_quantity_above <> trunc(l_tolerance_quantity_above) THEN

    IF l_line_rec.item_type_code IN
       ('MODEL', 'OPTION','KIT','CLASS','INCLUDED','CONFIG') THEN
      l_tolerance_quantity_above := CEIL(l_tolerance_quantity_above);
    ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING INVENTORY VALIDATE QUANTITY : '
                          ||L_QTY_RETURN_STATUS , 2 ) ;
     END IF;

     Inv_Decimals_PUB.Validate_Quantity
     ( p_item_id           => l_line_rec.inventory_item_id,
       p_organization_id   => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
       p_input_quantity    => l_tolerance_quantity_above,
       p_uom_code          => l_line_rec.order_quantity_uom,
       x_output_quantity   => l_validated_quantity,
       x_primary_quantity  => l_primary_quantity,
       x_return_status     => l_qty_return_status);

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('RETURN STATUS FROM INV API : '
                         ||L_QTY_RETURN_STATUS , 2 ) ;
     END IF;

     IF l_qty_return_status IN ('W','S') THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'TOL ABOVE/VALID QTY : '
         ||TO_CHAR ( L_TOLERANCE_QUANTITY_ABOVE )
         ||'/'||TO_CHAR ( L_VALIDATED_QUANTITY ) , 3 ) ;
       END IF;

       l_tolerance_quantity_above := l_validated_quantity;
     ELSE
       l_tolerance_quantity_above := CEIL(l_tolerance_quantity_above);
     END IF;
    END IF;
  END IF;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '68,';
  END IF;

  ---------- done with getting tol above and below.


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ORDERED QUANTITY ' || TO_CHAR ( L_ORDERED_QUANTITY),3 );
    oe_debug_pub.add('SHIPPED QUANTITY ' || TO_CHAR ( L_SHIPPED_QUANTITY),3 );
    oe_debug_pub.add('SHIPPING QUANTITY ' || TO_CHAR( L_SHIPPING_QUANTITY),3 );
    oe_debug_pub.add('TOLERANCE BELOW ' || TO_CHAR (L_SHIP_TOLERANCE_BELOW),3 );
    oe_debug_pub.add('TOLERAQNCE ABOVE ' || TO_CHAR(L_SHIP_TOLERANCE_ABOVE),3 );
    oe_debug_pub.add('TOLE QTY BELOW '||TO_CHAR(L_TOLERANCE_QUANTITY_BELOW),3 );
    oe_debug_pub.add('TOLE QTY ABOVE '|| TO_CHAR(L_TOLERANCE_QUANTITY_ABOVE),3 );
  END IF;



  IF l_ordered_quantity= l_shipped_quantity THEN
    x_result_out    :=OE_GLOBALS.G_FULLY_SHIPPED;

  ELSIF  l_ordered_quantity <= l_shipped_quantity + l_tolerance_quantity_below AND
         l_shipped_quantity < l_ordered_quantity THEN
    x_result_out    :=OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW;

  ELSIF l_ordered_quantity > l_shipped_quantity + l_tolerance_quantity_below THEN

    IF l_line_rec.shipping_quantity_uom <> l_line_rec.order_quantity_uom THEN
      l_temp_shipped_quantity :=
            OE_Order_Misc_Util.Convert_Uom
           ( l_line_rec.inventory_item_id,
             l_line_rec.shipping_quantity_uom,
             l_line_rec.order_quantity_uom,
             l_shipping_quantity);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONVERTED SHIPPED QUANTITY : '
                          || TO_CHAR ( L_TEMP_SHIPPED_QUANTITY),3 );
      END IF;

     IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '69,';
     END IF;

      IF l_temp_shipped_quantity <> trunc(l_temp_shipped_quantity) THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLING INVENTORY VALIDATE QUANTITY : '
                           ||L_QTY_RETURN_STATUS , 2 );
        END IF;

        Inv_Decimals_PUB.Validate_Quantity
        (p_item_id          => l_line_rec.inventory_item_id,
         p_organization_id  => OE_Sys_Parameters.value('MASTER_ORGANIZATION_ID'),
         p_input_quantity   => l_temp_shipped_quantity,
         p_uom_code         => l_line_rec.order_quantity_uom,
         x_output_quantity  => l_validated_quantity,
         x_primary_quantity => l_primary_quantity,
         x_return_status    => l_qty_return_status);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RET STS FROM INV API : '||L_QTY_RETURN_STATUS , 2 );
        END IF;

        IF l_qty_return_status = 'W' THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('VALID QTY : '||TO_CHAR ( L_VALIDATED_QUANTITY),3 );
          END IF;
          l_temp_shipped_quantity := l_validated_quantity;
        END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'VALIDATED SHIPPED QUANTITY : '
                            || TO_CHAR ( L_TEMP_SHIPPED_QUANTITY),3 );
        END IF;

      END IF; -- done validate decimal

      IF l_ordered_quantity> l_temp_shipped_quantity + l_tolerance_quantity_below
      THEN
        x_result_out    :=OE_GLOBALS.G_PARTIALLY_SHIPPED;
      ELSE
        x_result_out    :=OE_GLOBALS.G_FULLY_SHIPPED;
      END IF;

       IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.Add('Check the Decimals for Standard Items..Different UOM');
         OE_DEBUG_PUB.Add('Changes for Bug-3468847');
      END IF;

      IF p_line_rec.item_type_code = 'STANDARD' THEN

         SELECT count(*)
          INTO l_wdd_count
          FROM wsh_delivery_details
         WHERE source_line_id = p_line_rec.line_id
          AND  released_status <> 'D'
          AND  source_code = 'OE'
          AND  oe_interfaced_flag = 'N';


         IF l_wdd_count = 0 THEN
            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.Add('Delivery Detail Did not Split..');
            END IF;
            x_result_out    := OE_GLOBALS.G_FULLY_SHIPPED;
         ELSE
            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.Add('Delivery Detail Has Split..');
            END IF;
         END IF;
      END IF;

    ELSE
      x_result_out    :=OE_GLOBALS.G_PARTIALLY_SHIPPED;
    END IF; -- different uom

    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '61,';
    END IF;

  -- Check for Shipment within ship tolerance above

  ELSIF l_shipped_quantity <= l_ordered_quantity + l_tolerance_quantity_above AND
        l_ordered_quantity < l_shipped_quantity THEN
    x_result_out    :=OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE;

  -- Check for Shipment above ship tolerance above

  ELSIF l_shipped_quantity > l_ordered_quantity + l_tolerance_quantity_above THEN
    x_result_out    :=OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE;
  END IF;

  -- Bug 5332001
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.add('Checking for complete dropship receipt',1);
  END IF;

  IF p_line_rec.source_type_code = 'EXTERNAL' THEN

     DECLARE

         poll_received_quantity NUMBER;
         actual_quantity     NUMBER;

         BEGIN

                SELECT QUANTITY, QUANTITY_RECEIVED
                INTO   actual_quantity,poll_received_quantity
                FROM   PO_LINE_LOCATIONS_ALL
                WHERE  LINE_LOCATION_ID = (SELECT LINE_LOCATION_ID
                                           FROM   OE_DROP_SHIP_SOURCES
                                           WHERE  LINE_ID = l_line_rec.line_id);

                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.add('actual quantity '||actual_quantity||' poll received '||poll_received_quantity,1);
                END IF;

                IF poll_received_quantity = actual_quantity THEN
                   x_result_out    := OE_GLOBALS.G_FULLY_SHIPPED;
                END IF;

         EXCEPTION WHEN OTHERS THEN
                IF l_debug_level > 0 THEN
                   OE_DEBUG_PUB.add('error when checking receipt info '||sqlerrm,1);
                END IF;
                NULL;
         END;

  END IF;
  -- Bug 5332001 end

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING FROM CHECK_SHIPMENT_LINE : '||X_RESULT_OUT , 1 );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME,
       'Check_Shipment_Line'
      );
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E8,';
    END IF;

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (G_PKG_NAME,
       'CHeck_Shipment_Line'
      );
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E9,';
    END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 );
    END IF;
END Check_Shipment_Line;

/*--------------------------------------------------------------------
PROCEDURE Get_PTO_Shipped_Quantity
---------------------------------------------------------------------*/
PROCEDURE Get_PTO_Shipped_Quantity
(
	p_top_model_line_id		IN	NUMBER DEFAULT FND_API.G_MISS_NUM
,	p_x_line_tbl			IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
, x_ratio_status OUT NOCOPY VARCHAR2

, x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_pto_shipment_tbl		Shipment_Tbl_Type;
	l_line_tbl				OE_Order_PUB.Line_Tbl_Type;
	l_line_index			NUMBER;
	l_pto_index				NUMBER :=0;
	l_top_index				NUMBER :=0;
	l_final_index			NUMBER :=0;
	l_parent_index			NUMBER :=0;
	l_return_index			NUMBER :=0;
	l_top_shipped_quantity	NUMBER :=0;
	l_parent_shipped_quantity	NUMBER :=0;
	l_ratio_status			VARCHAR2(1) := FND_API.G_TRUE;
	l_ship_date				DATE;

	/* Added for bug 1952023 */
	l_over_shipped			VARCHAR2(1) := FND_API.G_FALSE;
	l_under_shipped			VARCHAR2(1) := FND_API.G_FALSE;
	l_line_shipped			VARCHAR2(1) := FND_API.G_TRUE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PVT.GET_PTO_SHIPPED_QUANTITY '|| TO_CHAR ( P_TOP_MODEL_LINE_ID ) , 1 ) ;
	END IF;

	IF	p_top_model_line_id IS NOT NULL AND
		p_top_model_line_id <> FND_API.G_MISS_NUM THEN

		-- Call function to get all the lines in a PTO.

--		p_x_line_tbl := OE_Config_Util.Query_Options(p_top_model_line_id);
	OE_Config_Util.Query_Options(p_top_model_line_id	=>	p_top_model_line_id,
								 p_send_cancel_lines    =>  'Y',
								 x_line_tbl				=>	l_line_tbl);

	ELSE

		l_line_tbl := p_x_line_tbl;

	END IF;

        IF g_debug_call > 0 THEN
          G_DEBUG_MSG := G_DEBUG_MSG || '71';
        END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NUMBER OF LINES IN THE TABLE '|| TO_CHAR ( L_LINE_TBL.COUNT ) , 3 ) ;
	END IF;

		-- Populate the local shipment table.

	FOR l_line_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
	LOOP

          IF  l_line_tbl(l_line_index).ordered_quantity = 0 THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'LINE WITH ZERO QUANTITY : '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID||'/'||L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
              END IF;
			  GOTO END_PREPARE_LOOP;
		END IF;
		l_final_index := l_final_index + 1;
		p_x_line_tbl(l_final_index) := l_line_tbl(l_line_index);
		-- l_pto_index := l_line_tbl(l_line_index).line_id; -- Bug 8795918
		l_pto_index := mod(l_line_tbl(l_line_index).line_id,OE_GLOBALS.G_BINARY_LIMIT);

		l_pto_shipment_tbl(l_pto_index).line_id := l_line_tbl(l_line_index).line_id;
		l_pto_shipment_tbl(l_pto_index).top_model_line_id := l_line_tbl(l_line_index).top_model_line_id;
		l_pto_shipment_tbl(l_pto_index).ordered_quantity := l_line_tbl(l_line_index).ordered_quantity;
		l_pto_shipment_tbl(l_pto_index).shipped_quantity := l_line_tbl(l_line_index).shipped_quantity;
		l_pto_shipment_tbl(l_pto_index).link_to_line_id := l_line_tbl(l_line_index).link_to_line_id;

                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '73,';
                END IF;

		IF	nvl(l_line_tbl(l_line_index).shippable_flag,'N') = 'Y' THEN
			l_pto_shipment_tbl(l_pto_index).shippable_flag := FND_API.G_TRUE;
			l_ship_date := l_line_tbl(l_line_index).actual_shipment_date;

			IF	nvl(l_line_tbl(l_line_index).shipped_quantity,0) = 0 THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'LINE IS NOT SHIPPED : '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
				END IF;
				l_line_shipped := FND_API.G_FALSE;
			END IF;
		ELSE
			l_pto_shipment_tbl(l_pto_index).shippable_flag := FND_API.G_FALSE;
		END IF;

		/* Added for bug 1952023 */
		IF	nvl(l_line_tbl(l_line_index).shipped_quantity,0) > nvl(l_line_tbl(l_line_index).ordered_quantity,0) THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'LINE IS OVER SHIPPED '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
			END IF;
			l_over_shipped := FND_API.G_TRUE;

		END IF;

		IF	nvl(l_line_tbl(l_line_index).shipped_quantity,0) < nvl(l_line_tbl(l_line_index).ordered_quantity,0) AND
			nvl(l_line_tbl(l_line_index).shippable_flag,'N') = 'Y' THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'LINE IS UNDER SHIPPED '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
			END IF;
			l_under_shipped := FND_API.G_TRUE;

		END IF;

		<< END_PREPARE_LOOP >>
		NULL;

	END LOOP;
        IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '74';
        END IF;
	-- Calculate the ratios.

	l_pto_index := l_pto_shipment_tbl.FIRST;

	WHILE l_pto_index IS NOT NULL
	LOOP


		-- l_top_index := l_pto_shipment_tbl(l_pto_index).top_model_line_id; -- Bug 8795918
		l_top_index := mod(l_pto_shipment_tbl(l_pto_index).top_model_line_id,OE_GLOBALS.G_BINARY_LIMIT);

		-- l_parent_index := nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id); -- Bug 8795918
		l_parent_index := mod(nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id),OE_GLOBALS.G_BINARY_LIMIT);
		l_pto_shipment_tbl(l_pto_index).ratio_to_top_model := l_pto_shipment_tbl(l_pto_index).ordered_quantity/l_pto_shipment_tbl(l_top_index).ordered_quantity;

		IF 	l_parent_index <> 0 THEN

			l_pto_shipment_tbl(l_pto_index).ratio_to_parent := l_pto_shipment_tbl(l_pto_index).ordered_quantity/l_pto_shipment_tbl(l_parent_index).ordered_quantity;
		ELSE
			l_pto_shipment_tbl(l_pto_index).ratio_to_parent := 1;
		END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RATIO TO PARENT = '||TO_CHAR ( L_PTO_SHIPMENT_TBL ( L_PTO_INDEX ) .RATIO_TO_PARENT ) , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RATIO TO TOP = '||TO_CHAR ( L_PTO_SHIPMENT_TBL ( L_PTO_INDEX ) .RATIO_TO_TOP_MODEL ) , 3 ) ;
		END IF;

		l_pto_index := l_pto_shipment_tbl.NEXT(l_pto_index);

	END LOOP;

	-- Calculate the shipped quantity for non-shippable lines.

	l_pto_index := l_pto_shipment_tbl.FIRST;

	WHILE l_pto_index IS NOT NULL AND
		  l_ratio_status = FND_API.G_TRUE
	LOOP

		IF	l_pto_shipment_tbl(l_pto_index).shippable_flag = FND_API.G_FALSE THEN

			GOTO SKIP_THE_LINE;

		END IF;

		-- l_parent_index := nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id); --Bug 8795918
		-- l_top_index := l_pto_shipment_tbl(l_pto_index).top_model_line_id; -- Bug 8795918
		l_parent_index := mod(nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id),OE_GLOBALS.G_BINARY_LIMIT);
		l_top_index := mod(l_pto_shipment_tbl(l_pto_index).top_model_line_id,OE_GLOBALS.G_BINARY_LIMIT);

		l_parent_shipped_quantity := nvl(l_pto_shipment_tbl(l_pto_index).shipped_quantity,0)/l_pto_shipment_tbl(l_pto_index).ratio_to_parent;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIPPED QUANTITY FOR PARENT : '|| TO_CHAR ( L_PARENT_SHIPPED_QUANTITY ) , 3 ) ;
		END IF;

		IF	l_pto_shipment_tbl(l_parent_index).shipped_quantity IS NOT NULL AND
			l_pto_shipment_tbl(l_parent_index).shipped_quantity <> l_parent_shipped_quantity THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'PTO HAS NOT BEEN SHIPPED IN PROPORTION ' , 3 ) ;
			END IF;
			l_ratio_status := FND_API.G_FALSE;
			GOTO END_CALCULATE_SHIPPED_QUANTITY;
		ELSE
			l_pto_shipment_tbl(l_parent_index).shipped_quantity := l_parent_shipped_quantity;
		END IF;

		IF	l_pto_shipment_tbl(l_parent_index).shipped_quantity <> trunc(l_pto_shipment_tbl(l_parent_index).shipped_quantity) THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY IN DECIMAL '||TO_CHAR ( L_PTO_SHIPMENT_TBL ( L_PARENT_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
			l_ratio_status := FND_API.G_FALSE;
			GOTO END_CALCULATE_SHIPPED_QUANTITY;

		END IF;

		l_top_shipped_quantity := nvl(l_pto_shipment_tbl(l_pto_index).shipped_quantity,0)/l_pto_shipment_tbl(l_pto_index).ratio_to_top_model;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIPPED QUANTITY FOR TOP MODEL : '|| TO_CHAR ( L_TOP_SHIPPED_QUANTITY ) , 3 ) ;
		END IF;

		IF	l_pto_shipment_tbl(l_top_index).shipped_quantity IS NOT NULL AND
			l_pto_shipment_tbl(l_top_index).shipped_quantity <> l_top_shipped_quantity THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'PTO HAS NOT BEEN SHIPPED IN PROPORTION ' , 3 ) ;
			END IF;
			l_ratio_status := FND_API.G_FALSE;
			GOTO END_CALCULATE_SHIPPED_QUANTITY;
		ELSE
			l_pto_shipment_tbl(l_top_index).shipped_quantity := l_top_shipped_quantity;
		END IF;

		IF	l_pto_shipment_tbl(l_top_index).shipped_quantity <> trunc(l_pto_shipment_tbl(l_top_index).shipped_quantity) THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY IN DECIMAL '||TO_CHAR ( L_PTO_SHIPMENT_TBL ( L_TOP_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
			l_ratio_status := FND_API.G_FALSE;
			GOTO END_CALCULATE_SHIPPED_QUANTITY;

		END IF;

	<<SKIP_THE_LINE>>
		l_pto_index := l_pto_shipment_tbl.NEXT(l_pto_index);

	END LOOP;

	<<END_CALCULATE_SHIPPED_QUANTITY>>

	-- If the ratio is not broken populate the out line table.

	IF	l_ratio_status = FND_API.G_TRUE THEN

     -- Assign the shipped quantity if not assigned to any of the lines

	l_pto_index := l_pto_shipment_tbl.FIRST;

	WHILE l_pto_index IS NOT NULL
	LOOP

		-- l_parent_index := nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id); -- Bug 8795918
		-- l_top_index := l_pto_shipment_tbl(l_pto_index).top_model_line_id; -- Bug 8795918
		l_parent_index := mod(nvl(l_pto_shipment_tbl(l_pto_index).link_to_line_id,l_pto_shipment_tbl(l_pto_index).top_model_line_id),OE_GLOBALS.G_BINARY_LIMIT);
		l_top_index := mod(l_pto_shipment_tbl(l_pto_index).top_model_line_id,OE_GLOBALS.G_BINARY_LIMIT);

		IF  nvl(l_pto_shipment_tbl(l_pto_index).shipped_quantity,0) = 0 THEN

              l_pto_shipment_tbl(l_pto_index).shipped_quantity := nvl(l_pto_shipment_tbl(l_top_index).shipped_quantity,0) * l_pto_shipment_tbl(l_pto_index).ratio_to_top_model;

		END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIPPED QUANTITY : '||TO_CHAR ( L_PTO_SHIPMENT_TBL ( L_PTO_INDEX ) .SHIPPED_QUANTITY ) , 1 ) ;
		END IF;

		l_pto_index := l_pto_shipment_tbl.NEXT(l_pto_index);
	END LOOP;

     l_final_index := 0;

	FOR l_line_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
	LOOP

        IF  l_line_tbl(l_line_index).ordered_quantity = 0 THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'LINE WITH ZERO QUANTITY : '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID||'/'||L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
             END IF;
			 GOTO END_FINAL_LOOP;
		END IF;

		l_final_index := l_final_index + 1;
		p_x_line_tbl(l_final_index) := l_line_tbl(l_line_index);

		-- l_pto_index := l_line_tbl(l_line_index).line_id; -- Bug 8795918
		l_pto_index := mod(l_line_tbl(l_line_index).line_id,OE_GLOBALS.G_BINARY_LIMIT);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INDEX/LINE_ID/FINAL_INDEX '|| TO_CHAR ( L_LINE_INDEX ) ||'/'||P_X_LINE_TBL ( L_FINAL_INDEX ) .LINE_ID||'/'||TO_CHAR ( L_FINAL_INDEX ) , 3 ) ;
		END IF;

		IF	l_pto_shipment_tbl(l_pto_index).shippable_flag = FND_API.G_FALSE THEN
			p_x_line_tbl(l_final_index).shipped_quantity := l_pto_shipment_tbl(l_pto_index).shipped_quantity;
			p_x_line_tbl(l_final_index).actual_shipment_date := l_ship_date;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPPED QUANTITY ASSIGNED '||P_X_LINE_TBL ( L_FINAL_INDEX ) .ITEM_TYPE_CODE||TO_CHAR ( P_X_LINE_TBL ( L_FINAL_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIPMENT DATE ASSIGNED '||P_X_LINE_TBL ( L_FINAL_INDEX ) .ITEM_TYPE_CODE||TO_CHAR ( P_X_LINE_TBL ( L_FINAL_INDEX ) .ACTUAL_SHIPMENT_DATE , 'DD-MM-YY' ) , 3 ) ;
			END IF;
		END IF;

		<< END_FINAL_LOOP >>
		NULL;

       END LOOP;
	/* Added for bug 1952023 */
	ELSE

		IF	l_over_shipped = FND_API.G_TRUE AND
			l_under_shipped = FND_API.G_FALSE AND
			l_line_shipped = FND_API.G_TRUE THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ONE OF THE LINE HAS BEEN OVER SHIPPED , MAKE THE MODEL REMNANT '||P_X_LINE_TBL ( 1 ) .TOP_MODEL_LINE_ID , 3 ) ;
			END IF;


			update oe_order_lines
			set    model_remnant_flag = 'Y'
			where  top_model_line_id = p_x_line_tbl(1).top_model_line_id;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'NOW SET THE REMNANT FLAG FOR ALL THE LINES ' , 3 ) ;
			END IF;

			FOR l_line_index IN p_x_line_tbl.FIRST .. p_x_line_tbl.LAST
			LOOP

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'LINE/ITEM '||P_X_LINE_TBL ( L_LINE_INDEX ) .LINE_ID||'/'||P_X_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
				END IF;
				p_x_line_tbl(l_line_index).model_remnant_flag := 'Y';

			END LOOP;

		END IF;
	END IF;

	--x_line_tbl	:= l_line_tbl;
	x_ratio_status := l_ratio_status;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_SHIPPING_INTEGRATION_PVT.GET_PTO_SHIPPED_QUANTITY ' , 1 ) ;
	END IF;
EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Get_PTO_Shipped_Quantity'
				);
			END IF;
                        IF g_debug_call > 0 THEN
                           G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-10';
                        END IF;

   	WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-11';
                END IF;

	WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Get_PTO_Shipped_Quantity'
				);
			END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
		END IF;
                IF g_debug_call > 0 THEN
                    G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-12';
                END IF;
	NULL;
END Get_PTO_Shipped_Quantity;



/*--------------------------------------------------------------
PROCEDURE Ship_Confirm_PTO_KIT

This procedure is called for ship confirmation PTO models.
It checks if the model is shipped in proprtion or not.

If model is shipped in proportion.:
It sets the shipped quantity on nonshippable lines. It splits the shippble
lines if partailly shipped. Then it logs requests to
progress the wf for shippable lines.

If the model is not shipped in proportion:
it performs nonproportional split of the model if it is not a
remnant already. it then progress the wf for shippble lines.
finally it prrgressed th fulfillment of non-shippable lines
if not in fulfillment set and are at fulfillment activity.

Change record:
bug 2361720: added call to ship_confirm_standard_line if the
shipped not in proportion branch, whcih will complete the ATO
model's wait for cto inturn.
---------------------------------------------------------------*/
PROCEDURE Ship_Confirm_PTO_KIT
( p_top_model_line_id    IN   NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
  l_line_tbl                OE_ORDER_PUB.Line_Tbl_Type;
  l_split_line_tbl          OE_ORDER_PUB.Line_Tbl_Type;
  l_split_index             NUMBER :=0;
  l_pto_index               NUMBER;
  l_ratio_status            VARCHAR2(1) := FND_API.G_TRUE;
  l_ship_tolerance_below    NUMBER;
  l_ship_tolerance_above    NUMBER;
  l_update_tolerance_value  NUMBER := 0 ;
  l_x_result_out            VARCHAR2(30);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_result_code             VARCHAR2(30);
  l_unreserve_quantity      NUMBER;
  l_activity_status         VARCHAR2(8);
  l_activity_result         VARCHAR2(30);
  l_activity_id             NUMBER;
  l_fulfillment_activity    VARCHAR2(30);
  l_item_key                VARCHAR2(240);
  l_fulfill_tbl             OE_Order_Pub.Line_Tbl_Type;
  l_fulfill_index           NUMBER := 0 ;
  l_fulfillment_set_flag    VARCHAR2(1);

  -- Variables to call process order to update the shipped quantity for
  -- non shippable lines.
  l_upd_tbl_index           NUMBER := 0;
  l_update_line_tbl         OE_ORDER_PUB.Line_Tbl_Type;
  l_control_rec             OE_GLOBALS.Control_Rec_Type;
  l_top_model_index         NUMBER;
  l_ato_line_index          NUMBER := 0;
  l_set_recursion           VARCHAR2(1) := 'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SHIP_CONFIRM_PTO_KIT '|| P_TOP_MODEL_LINE_ID , 1 ) ;
  END IF;

  -- Call get PTO shipped quantity to get the shipment status and shipped
  -- quantities for MODEL and CLASS.


  Get_PTO_Shipped_Quantity
  (p_top_model_line_id    => p_top_model_line_id
  ,p_x_line_tbl           => l_line_tbl
  ,x_ratio_status         => l_ratio_status
  ,x_return_status        => l_return_status );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Get the top model line id index.

  FOR  l_pto_index IN 1 .. l_line_tbl.count
  LOOP

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'INDEX/LINE_ID/TOP_MODEL_LINE_ID :'|| TO_CHAR ( L_PTO_INDEX ) || TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) || TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .TOP_MODEL_LINE_ID ) , 3 ) ;
                      END IF;

    IF l_line_tbl(l_pto_index).line_id =
                  l_line_tbl(l_pto_index).top_model_line_id THEN
      l_top_model_index := l_pto_index;
    END IF;

    IF l_line_tbl(l_pto_index).line_id = l_line_tbl(l_pto_index).ato_line_id
    THEN
      l_ato_line_index := l_pto_index;
    END IF;



    IF nvl(l_line_tbl(l_pto_index).ship_tolerance_below,0) <> 0 AND
       l_line_tbl(l_pto_index).shippable_flag = 'Y' THEN
      l_update_tolerance_value := l_line_tbl(l_pto_index).ship_tolerance_below;
    ELSE
      l_update_tolerance_value := 0;
    END IF;

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TOP MODEL INDEX : '||L_TOP_MODEL_INDEX , 3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ATO LINE INDEX : '||L_ATO_LINE_INDEX , 3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW TOLERANCE VALUE : '||L_UPDATE_TOLERANCE_VALUE , 3 ) ;
  END IF;


  -- Check for shipment status when the ratio is not broken and the ship
  -- tolerances will be honoured.

  IF  l_ratio_status = FND_API.G_TRUE THEN

    -- Loop to Update the shipped quantity of non shippable lines by calling
    -- process_order.

    FOR l_pto_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
    LOOP
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INSIDE THE LOOP FOR NON SHIPPABLE LINE : '|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) ||'/'|| L_LINE_TBL ( L_PTO_INDEX ) .SHIPPED_QUANTITY , 3 ) ;
                        END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'SHIPPABLE FLAG/OPEN FLAG : '|| L_LINE_TBL ( L_PTO_INDEX ) .SHIPPABLE_FLAG||'/'|| L_LINE_TBL ( L_PTO_INDEX ) .OPEN_FLAG , 3 ) ;
                        END IF;

      IF nvl(l_line_tbl(l_pto_index).shippable_flag,'N') <> 'Y' THEN

        l_upd_tbl_index := l_upd_tbl_index + 1;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NONSHIPPABLE INDEX UPD TABLE '|| L_UPD_TBL_INDEX , 3 ) ;
        END IF;

        l_update_line_tbl(l_upd_tbl_index) := l_line_tbl(l_pto_index);
        l_update_line_tbl(l_upd_tbl_index).operation
                                           := OE_GLOBALS.G_OPR_UPDATE;

        IF l_line_tbl(l_top_model_index).ship_tolerance_below <>
           nvl(l_line_tbl(l_pto_index).ship_tolerance_below,0) AND
           l_line_tbl(l_top_model_index).line_id =
                          l_line_tbl(l_pto_index).line_id AND
           nvl(l_line_tbl(l_pto_index).ship_tolerance_below,0) <> 0
        THEN

          l_update_line_tbl(l_upd_tbl_index).ship_tolerance_below
                                        := l_update_tolerance_value;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NEW TOLERANCE = '|| L_UPDATE_LINE_TBL ( L_UPD_TBL_INDEX ) .SHIP_TOLERANCE_BELOW , 3 ) ;
          END IF;

        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIPPED QUANTITY = '|| TO_CHAR ( L_UPDATE_LINE_TBL ( L_UPD_TBL_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
        END IF;

      END IF;

    END LOOP;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PO TO UPDATE SHIPPED QTY FOR NON SHIPPABLE LINES' , 3 ) ;
    END IF;

    IF g_debug_call > 0 THEN
       G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-8-6';
    END IF;

    l_control_rec                    := OE_GLOBALS.G_MISS_CONTROL_REC;
    l_control_rec.validate_entity    := FALSE;
    l_control_rec.check_security     := FALSE;

    IF OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN
      l_set_recursion := 'N';
    ELSE
      l_set_recursion := 'Y';
      -- OE_GLOBALS.G_RECURSION_MODE := 'Y';
    END IF;

    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '87,';
    END IF;

    Call_Process_Order
    ( p_line_tbl       => l_update_line_tbl,
      p_control_rec    => l_control_rec,
      x_return_status  => l_return_status );

    IF l_set_recursion = 'Y' THEN
      l_set_recursion := 'N';
      -- OE_GLOBALS.G_RECURSION_MODE := 'N';
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '88,';
    END IF;

    IF l_line_tbl(l_top_model_index).ordered_quantity =
            l_line_tbl(l_top_model_index).shipped_quantity THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'FULLY SHIPPED , SHIPMENT RATIO IS NOT BROKEN' , 3 ) ;
      END IF;
      l_x_result_out := OE_GLOBALS.G_FULLY_SHIPPED;

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOT FULLY SHIPPED , SHIPMENT RATIO IS NOT BROKEN' , 3 ) ;
      END IF;
      -- Check the shipment status

      l_ship_tolerance_below
              := l_line_tbl(l_top_model_index).ship_tolerance_below;
      l_ship_tolerance_above
              := l_line_tbl(l_top_model_index).ship_tolerance_above;
      -- Check the shipment status

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'CHECKING THE SHIPMENT STATUS FOR LINE : '|| L_LINE_TBL ( L_TOP_MODEL_INDEX ) .LINE_ID || ' ' || L_LINE_TBL ( L_TOP_MODEL_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
                        END IF;

      Check_Shipment_Line
      (p_line_rec      => l_line_tbl(l_top_model_index),
       x_result_out    => l_x_result_out);

    END IF;


    -- Call the split API if it is a partial shipment.

    IF l_x_result_out = OE_GLOBALS.G_PARTIALLY_SHIPPED AND
       l_line_tbl(l_top_model_index).ordered_quantity >
       l_line_tbl(l_top_model_index).shipped_quantity THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING OE_ORDER_PVT.PROCESS_ORDER FOR MODEL LINE' , 3 ) ;
      END IF;

      -- Assign the first record of the table for process order for update
      -- of the ordered quantity.

      l_split_line_tbl(1) := l_line_tbl(l_top_model_index);
      l_split_line_tbl(1).ordered_quantity
                          := l_line_tbl(l_top_model_index).shipped_quantity;
      l_split_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_split_line_tbl(1).split_action_code := 'SPLIT';
      l_split_line_tbl(1).split_by := 'SYSTEM';

      IF g_debug_call  > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '80,';
      END IF;
      -- Assign the second record of the table for process order for
      -- create of new line.

      l_split_line_tbl(2) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_split_line_tbl(2).split_from_line_id
                          := l_line_tbl(l_top_model_index).line_id;
      l_split_line_tbl(2).ordered_quantity
                          := l_line_tbl(l_top_model_index).ordered_quantity -
                             l_line_tbl(l_top_model_index).shipped_quantity;
      l_split_line_tbl(2).operation := OE_GLOBALS.G_OPR_CREATE;
      l_split_line_tbl(2).split_by  := 'SYSTEM';

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SPLIT FROM LINE ID : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .SPLIT_FROM_LINE_ID ) , 3 ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORIGINAL ORDERED QUANTITY : '|| TO_CHAR ( L_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) , 3 ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDERED QUANTITY OLD LINE : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) , 3 ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDERED QUANTITY NEW LINE : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .ORDERED_QUANTITY ) , 3 ) ;
      END IF;


      l_control_rec := OE_GLOBALS.G_MISS_CONTROL_REC;
      l_control_rec.controlled_operation := TRUE;
      l_control_rec.check_security       := FALSE;
      l_control_rec.change_attributes    := TRUE;
      l_control_rec.default_attributes   := TRUE;
      l_control_rec.clear_dependents     := TRUE;

      IF OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN
        l_set_recursion := 'N';
      ELSE
        l_set_recursion := 'Y';
        -- OE_GLOBALS.G_RECURSION_MODE := 'Y';
      END IF;

      IF g_debug_call  > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '81,';
      END IF;

      Call_Process_Order
      ( p_line_tbl       => l_split_line_tbl,
        p_control_rec    => l_control_rec,
        x_return_status  => l_return_status);

      IF l_set_recursion = 'Y' THEN
        l_set_recursion := 'N';
        -- OE_GLOBALS.G_RECURSION_MODE := 'N';
      END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RET STS FROM PROCESS ORDER: '||L_RETURN_STATUS , 3 ) ;
      END IF;
    END IF;

    ---------------------- split done -------------------------


    -- Loop to ship confirm the shippable lines of a PTO/KIT.
    FOR l_pto_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
    LOOP

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'INSIDE THE CONFIRM SHIPMENT LOOP : LINE ID : '|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) , 3 ) ;
                       END IF;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INSIDE THE CONFIRM SHIPMENT LOOP : ITEM TYPE : '|| L_LINE_TBL ( L_PTO_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
                        END IF;

      IF nvl(l_line_tbl(l_pto_index).shippable_flag,'N') = 'Y' THEN

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'INSIDE THE IF FOR SHIPPABLE LINE : LINE ID : '|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) , 3 ) ;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'INSIDE THE IF FOR SHIPPABLE LINE : ITEM TYPE : '|| L_LINE_TBL ( L_PTO_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
                          END IF;

        Ship_Confirm_Standard_Line
        ( p_line_rec         => l_line_tbl(l_pto_index),
          p_shipment_status  => l_x_result_out,
          x_return_status    => x_return_status );


        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;

    END LOOP;

    ------------------ ratio_status = TRUE done ---------------

    -- It is over/under shipepd with shipment ratio broken. The lines
    -- will split if under ship. The shipment activity will be
    -- completed for lines which have been overshipped.

    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '84,';
    END IF;

  ELSIF l_ratio_status = FND_API.G_FALSE THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NOT SHIPPED , SHIPMENT RATIO IS BROKEN : ' , 3 ) ;
    END IF;

    -- Call process order to update the shipping tolerances to 0
    -- if there is some value in tolerance

    IF nvl(l_line_tbl(l_top_model_index).ship_tolerance_below,0) <> 0 OR
       nvl(l_line_tbl(l_top_model_index).ship_tolerance_above,0) <> 0 THEN


      UPDATE OE_ORDER_LINES_ALL
      SET    SHIP_TOLERANCE_BELOW = 0,
             SHIP_TOLERANCE_ABOVE = 0
      WHERE  TOP_MODEL_LINE_ID = l_line_tbl(l_top_model_index).line_id;

    END IF;

    FOR l_pto_index IN l_line_tbl.FIRST .. l_line_tbl.LAST
    LOOP

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INSIDE THE RATIO BROKEN LOOP : LINE ID : '|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) , 3 ) ;
                        END IF;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'INSIDE THE RATIO BROKEN LOOP : ITEM TYPE : '|| L_LINE_TBL ( L_PTO_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
                        END IF;

      /* Added for bug 1952023 */


      IF nvl(l_line_tbl(l_top_model_index).model_remnant_flag,'N') = 'N'
      THEN
        IF nvl(l_line_tbl(l_pto_index).shippable_flag,'N') = 'Y' THEN

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'INSIDE THE IF FOR SHIPPABLE LINE : LINE ID : '|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) , 3 ) ;
                            END IF;

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'INSIDE THE IF FOR SHIPPABLE LINE : ITEM TYPE : '|| L_LINE_TBL ( L_PTO_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
                            END IF;

          IF nvl(l_line_tbl(l_pto_index).shipped_quantity,0) <> 0 THEN
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'THE LINE IS UNDERSHIPPED : SPLIT LINE'|| TO_CHAR ( L_LINE_TBL ( L_PTO_INDEX ) .LINE_ID ) , 3 ) ;
                              END IF;

            l_split_index := l_split_index + 1;
            l_split_line_tbl(l_split_index) := l_line_tbl(l_pto_index);
            l_split_line_tbl(l_split_index).ordered_quantity
                 := l_line_tbl(l_pto_index).ordered_quantity -
                    l_line_tbl(l_pto_index).shipped_quantity;
            l_split_line_tbl(l_split_index).shipped_quantity
                 := l_line_tbl(l_pto_index).shipped_quantity;
            l_split_line_tbl(l_split_index).operation
                 := OE_GLOBALS.G_OPR_UPDATE;
            l_split_line_tbl(l_split_index).split_by  := 'SYSTEM';
            l_split_line_tbl(l_split_index).split_action_code := 'SPLIT';

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NEW ORDERED QUANTITY : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( L_SPLIT_INDEX ) .ORDERED_QUANTITY ) , 3 ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIPPED QUANTITY : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( L_SPLIT_INDEX ) .SHIPPED_QUANTITY ) , 3 ) ;
            END IF;
            -- Call the process order to split the line
          END IF;
        END IF; -- Shippable flag = Y

      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'REMNANT_MODEL ' , 3 ) ;
        END IF;
        l_split_index := l_split_index + 1;
        l_split_line_tbl(l_split_index) := l_line_tbl(l_pto_index);
      END IF; -- Model Remnant

    END LOOP;

    -- Call un-proportional split if any of the lines has under shipped

    IF l_split_line_tbl.count > 0 THEN

      IF nvl(l_line_tbl(l_top_model_index).model_remnant_flag,'N') = 'N'
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING NON PROPORTIONAL SPLIT' , 3 ) ;
        END IF;

        IF g_debug_call  > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '88,';
        END IF;

        oe_split_util.cascade_non_proportional_Split
        (p_x_line_tbl    => l_split_line_tbl,
         x_return_status => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RET STS FROM NON PRO SPLIT/'||L_RETURN_STATUS , 3 ) ;
        END IF;

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'NUMBER OF ROWS RETURNED : '|| TO_CHAR ( L_SPLIT_LINE_TBL.COUNT ) , 3 ) ;
                          END IF;
      END IF; -- Remnant flag
      IF g_debug_call  > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '89';
      END IF;

      -- Complete the SHIP_LINE work flow activity for shippable lines.
      -- Complete the FULFILL_LINE work flow activity for non shippable
      -- lines if the fulfillment activity is SHIP_LINE or no fulfillment
      -- activity.

      FOR l_split_index IN 1 .. l_split_line_tbl.count
      LOOP

        l_fulfillment_set_flag :=
              OE_Line_Fullfill.Is_Part_Of_Fulfillment_Set
             (l_split_line_tbl(l_split_index).line_id);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PART FULFILLMENT SET: '||L_FULFILLMENT_SET_FLAG , 3 ) ;
        END IF;


        IF nvl(l_split_line_tbl(l_split_index).shippable_flag,'N') = 'Y' AND
           nvl(l_split_line_tbl(l_split_index).shipped_quantity,0) <> 0
        THEN

          -- check if line is already ship confirmed.

          l_item_key := to_char(l_split_line_tbl(l_split_index).line_id);

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('CALLING GET ACTIVITY RESULT FOR : '
                              || L_ITEM_KEY||'/'||'SHIP_LINE' , 3 ) ;
                            END IF;

          OE_LINE_FULLFILL.Get_Activity_Result
          (p_item_type             => OE_GLOBALS.G_WFI_LIN
          ,p_item_key              => l_item_key
          ,p_activity_name         => 'SHIP_LINE'
          ,x_return_status         => l_return_status
          ,x_activity_result       => l_activity_result
          ,x_activity_status_code  => l_activity_status
          ,x_activity_id           => l_activity_id );

          IF l_activity_status = 'NOTIFIED' THEN

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING SHIP_CONFIRM_STANDARD_LINE '
                                || L_SPLIT_LINE_TBL ( L_SPLIT_INDEX ) .LINE_ID , 3 ) ;
            END IF;

            Ship_Confirm_Standard_Line
            ( p_line_rec         => l_split_line_tbl(l_split_index),
              p_shipment_status  => l_x_result_out,
              x_return_status    => x_return_status );

            IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
        ---- non shippable lines not in fulfillment set start ---------

        ELSIF nvl(l_split_line_tbl(l_split_index).shippable_flag,'N')= 'N' AND
              nvl(l_split_line_tbl(l_split_index).model_remnant_flag,'N') = 'Y'
              AND l_fulfillment_set_flag = FND_API.G_FALSE THEN

          l_item_key := to_char(l_split_line_tbl(l_split_index).line_id);

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'CALLING GET ACTIVITY RESULT FOR : '|| L_ITEM_KEY||'/'||'FULFILL_LINE' , 3 ) ;
                            END IF;

          OE_LINE_FULLFILL.Get_Activity_Result
          (p_item_type             => OE_GLOBALS.G_WFI_LIN
          ,p_item_key              => l_item_key
          ,p_activity_name         => 'FULFILL_LINE'
          ,x_return_status         => l_return_status
          ,x_activity_result       => l_activity_result
          ,x_activity_status_code  => l_activity_status
          ,x_activity_id           => l_activity_id );

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RET STS FROM GET ACT RESULT: '||L_RETURN_STATUS , 3 ) ;
          END IF;
          IF g_debug_call  > 0 THEN
             G_DEBUG_MSG := G_DEBUG_MSG || '89';
          END IF;
          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE IS NOT AT FULFILLMENT ACTIVITY : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( L_SPLIT_INDEX ) .LINE_ID ) , 3 ) ;
            END IF;
          ELSE
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE IS AT FULFILLMENT ACTIVITY : '|| TO_CHAR ( L_SPLIT_LINE_TBL ( L_SPLIT_INDEX ) .LINE_ID ) , 3 ) ;
            END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CALLING GET FULFILLMENT ACTIVITY ' , 3 ) ;
            END IF;

            IF g_debug_call  > 0 THEN
            G_DEBUG_MSG := G_DEBUG_MSG || '90';
            END IF;

            OE_LINE_FULLFILL.Get_Fulfillment_Activity
            (p_item_key             => l_item_key,
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

            IF  l_fulfillment_activity = 'NO_ACTIVITY' OR
                l_fulfillment_activity = 'SHIP_LINE' THEN

              l_fulfill_index := l_fulfill_index + 1;
              l_fulfill_tbl(l_fulfill_index) := OE_Order_PUB.G_MISS_LINE_REC;
              l_fulfill_tbl(l_fulfill_index).line_id
                     := l_split_line_tbl(l_split_index).line_id;
              l_fulfill_tbl(l_fulfill_index).fulfilled_flag := 'Y';
              l_fulfill_tbl(l_fulfill_index).fulfillment_date := SYSDATE;
              l_fulfill_tbl(l_fulfill_index).fulfilled_quantity
                     := l_split_line_tbl(l_split_index).ordered_quantity;
	      l_fulfill_tbl(l_fulfill_index).header_id
                     := l_split_line_tbl(l_split_index).header_id;
	      l_fulfill_tbl(l_fulfill_index).actual_shipment_date
                     :=l_split_line_tbl(l_split_index).actual_shipment_date;
	      l_fulfill_tbl(l_fulfill_index).order_firmed_date
                     :=l_split_line_tbl(l_split_index).order_firmed_date;
              --BSA changes for AFD
              l_fulfill_tbl(l_fulfill_index).blanket_number
                      :=l_split_line_tbl(l_split_index).blanket_number;
              l_fulfill_tbl(l_fulfill_index).blanket_line_number
                      :=l_split_line_tbl(l_split_index).blanket_line_number;
              l_fulfill_tbl(l_fulfill_index).blanket_version_number
                      :=l_split_line_tbl(l_split_index).blanket_version_number;
              --BSA changes for AFD

              l_fulfill_tbl(l_fulfill_index).operation
                     := OE_GLOBALS.G_OPR_UPDATE;

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'FULFILL INDEX : '||TO_CHAR ( L_FULFILL_INDEX ) , 3 ) ;
              END IF;
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'FULFILLED FLAG : '|| L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_FLAG , 3 ) ;
                              END IF;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'FULFILLED QUANTITY : '|| TO_CHAR ( L_FULFILL_TBL ( L_FULFILL_INDEX ) .FULFILLED_QUANTITY ) , 3 ) ;
              END IF;

            END IF; -- no activity

          END IF; -- line at fulfillment

        END IF; -- big if shippable etc.

      END LOOP; -- split line tbl has rows

      --------ship confirm done, call to fullfill strats -------

      IF l_fulfill_index <> 0 THEN

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'CALLING FULFILL LINE TABLE : '|| TO_CHAR ( L_FULFILL_INDEX ) , 3 ) ;
                          END IF;
        IF g_debug_call  > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '91';
        END IF;
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
              oe_debug_pub.add(  'RET STS FROM FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
          END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_item_key := to_char(l_fulfill_tbl(l_fulfill_index).line_id);

          -- 1739574 Log a delayed request for Complete Activity
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COMPLETE ACT :LOGGING REQUEST '|| L_ITEM_KEY , 3 ) ;
          END IF;

          OE_Delayed_Requests_Pvt.Log_Request
          ( p_entity_code   => OE_GLOBALS.G_ENTITY_ALL,
            p_entity_id     => l_fulfill_tbl(l_fulfill_index).line_id,
            p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id   => l_fulfill_tbl(l_fulfill_index).line_id,
            p_request_type  => OE_GLOBALS.G_COMPLETE_ACTIVITY,
            p_param1        => OE_GLOBALS.G_WFI_LIN,
            p_param2        => l_item_key,
            p_param3        => 'FULFILL_LINE',
            p_param4        => OE_GLOBALS.G_WFR_COMPLETE,
            x_return_status => l_return_status);

                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'FULFILL ASSOCIATED SERVICE LINES '|| L_FULFILL_TBL ( L_FULFILL_INDEX ) .LINE_ID , 3 ) ;
                            END IF;

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

    END IF; --split count more than 0

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SHIP_CONFIRM_PTO_KIT : '||X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
        , 'Ship_Confirm_PTO_KIT'
       );
    END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_CONFIRM_PTO_KIT : EXITING WITH OTHERS ERROR' , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SQLERRM , 1 ) ;
    END IF;
    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E9';
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
        , 'Ship_Confirm_PTO_KIT'
       );
    END IF;
    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E14';
    END IF;

    --  Get message count and data

END Ship_Confirm_PTO_KIT;


/*--------------------------------------------------------------*/
PROCEDURE Ship_Confirm_Standard_Line
(p_line_id         IN  NUMBER DEFAULT FND_API.G_MISS_NUM
,p_line_rec        IN  OE_ORDER_PUB.line_rec_type
                       DEFAULT OE_ORDER_PUB.G_MISS_LINE_REC
,p_shipment_status IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,p_check_line_set  IN  VARCHAR2 := 'Y'
,x_return_status   OUT NOCOPY VARCHAR2)

IS
  l_line_rec              OE_ORDER_PUB.line_rec_type;
  l_shipped_quantity      NUMBER;
  l_x_result_out          VARCHAR2(30);
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_unreserve_quantity   NUMBER;
  l_result_code           VARCHAR2(30);
  l_line_tbl              OE_ORDER_PUB.Line_Tbl_Type;
  l_control_rec           OE_GLOBALS.Control_Rec_Type;
  l_set_recursion         VARCHAR2(1) := 'N';

 -- HW 2415731 variables for OPM
  l_temp_shipped_qty      NUMBER;
  l_item_rec              OE_ORDER_CACHE.item_rec_type;
  l_uom_different         NUMBER;
  l_requested_qty_uom     VARCHAR2(3);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'enter ship_confirm_standard_line ' , 1 ) ;
  END IF;

  IF g_debug_call  > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '101,';
  END IF;

  IF p_line_id IS NULL OR
     p_line_id = FND_API.G_MISS_NUM THEN
     l_line_rec := p_line_rec;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'p_line_rec.line_id '||P_LINE_REC.LINE_ID , 3 ) ;
     END IF;
  ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'line_id '||P_LINE_ID , 3 ) ;
     END IF;

     OE_Line_Util.Query_Row(p_line_id   => p_line_id,
                            x_line_rec  => l_line_rec);
  END IF;


  -- Check for Shipment Status

  IF  p_shipment_status <> FND_API.G_MISS_CHAR AND
      p_shipment_status IS NOT NULL THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '1 shipment status '|| P_SHIPMENT_STATUS , 1 ) ;
    END IF;
    l_x_result_out := p_shipment_status;

    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '103,';
    END IF;
  ELSE

    BEGIN

      SELECT nvl(sum(shipped_quantity),0), requested_quantity_uom
      INTO   l_shipped_quantity, l_requested_qty_uom
      FROM   wsh_delivery_details
      WHERE  source_line_id in
           (SELECT line_id
            FROM   oe_order_lines
            WHERE  line_set_id = l_line_rec.line_set_id
            AND    shipped_quantity IS NULL
            AND    line_id <> l_line_rec.line_id)
      AND    source_code = 'OE'
      AND    released_status = 'C'
      GROUP BY requested_quantity_uom;


    EXCEPTION
      WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('wsh select error '|| sqlerrm, 1);
        END IF;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('additional shipped qty '|| l_shipped_quantity, 1);
    END IF;

    IF l_line_rec.order_quantity_uom <> l_requested_qty_uom THEN

      l_shipped_quantity := OE_Order_Misc_Util.Convert_Uom
                            ( l_line_rec.inventory_item_id,
                              l_requested_qty_uom,
                              l_line_rec.order_quantity_uom,
                              l_shipped_quantity );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('AFTER UOM CONV : '|| L_SHIPPED_QUANTITY,3);
      END IF;
      IF g_debug_call  > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '105,';
      END IF;

    END IF;

    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '106,';
    END IF;

    Check_Shipment_Line
     ( p_line_rec         => l_line_rec,
      p_shipped_quantity => l_shipped_quantity,
      x_result_out       => l_x_result_out);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AFTER check_shipement: '|| l_x_result_out,3);
    END IF;

  END IF; -- if shipment status was sent in




  IF l_x_result_out = OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW THEN

    -- Call API to releive allocation
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIPPED WITHIN TOLERANCE BELOW ' , 3 ) ;
    END IF;

    /* unreserve function need not to be performed as lines
       will be shipping interfaced, and delete reservation
       will be taken care by shipping */

    IF g_debug_call  > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '104';
    END IF;

  END IF; -- if below tolerance


  IF l_x_result_out = OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE THEN
    NULL;
    -- Send the notification ??
  END IF;


  IF l_x_result_out = OE_GLOBALS.G_PARTIALLY_SHIPPED AND
     l_line_rec.ordered_quantity > l_line_rec.shipped_quantity AND
    (l_line_rec.top_model_line_id is null OR
     l_line_rec.top_model_line_id = FND_API.G_MISS_NUM OR
     nvl(l_line_rec.model_remnant_flag,'N') = 'Y') THEN

      -- Split API is called only for Standard line. For PTO/ATO it
      -- will be called from respective procedures.
      -- Call Split API It should perform the followings :
      -- 1. Update the ordered quantity on the old line
      -- 2. Create a new line with Shipping_Interfaced_Flag = 'Y'
      -- 3. Call Process Order to perform 1 and 2.

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING OE_ORDER_PVT.PROCESS_ORDER ' , 3 ) ;
      END IF;
      -- Assign the first record of the table for process order for update
      -- of the ordered quantity.

      l_line_tbl(1) := l_line_rec;
      IF g_debug_call  > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '112';
      END IF;

-- HW BUG#:2415731 initialize variables -- INVCONV
      l_uom_different :=0;
      l_temp_shipped_qty :=0;

-- HW OPM BUG#:2415731. Is shipped_uom different from order_uom,
-- if so, we need to perform item specific conversion   Not sure if need this  RIGHT NOW cos converted above in misc convert

      IF ( l_line_tbl(1).shipping_quantity_uom <> l_line_tbl(1).order_quantity_uom )
          AND oe_line_util.dual_uom_control -- INVCONV
              (l_line_tbl(1).inventory_item_id
              ,l_line_tbl(1).ship_from_org_id
              ,l_item_rec) THEN

        /*l_temp_shipped_qty := GMI_Reservation_Util.get_opm_converted_qty(
                              p_apps_item_id    => l_line_tbl(1).inventory_item_id,
                              p_organization_id => l_line_tbl(1).ship_from_org_id,
                              p_apps_from_uom   => l_line_tbl(1).shipping_quantity_uom,
                              p_apps_to_uom     => l_line_tbl(1).order_quantity_uom,
                              p_original_qty    => l_line_tbl(1).shipping_quantity);     */

        l_temp_shipped_qty := INV_CONVERT.INV_UM_CONVERT(l_line_tbl(1).inventory_item_id -- INVCONV
                                                      ,5 --NULL
                                                      ,l_line_tbl(1).shipping_quantity
                                                      ,l_line_tbl(1).shipping_quantity_uom
                                                      ,l_line_tbl(1).order_quantity_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );

      	IF l_debug_level  > 0 THEN
      			oe_debug_pub.add('Ship_Confirm_Standard_Line  : l_temp_shipped_qty for dual control item  is '|| l_temp_shipped_qty);
      	END IF;


        IF g_debug_call  > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '107';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OPM , SHIPPED_UOM <> ORD_UOM AND CONVERSION VALUE IS: '||L_TEMP_SHIPPED_QTY , 1 ) ;
        END IF;

        l_line_tbl(1).ordered_quantity := l_temp_shipped_qty;
-- Check if item is dual UOM
        IF ( l_line_tbl(1).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR ) THEN

-- User can order in a 3rd UOM that is not primary nor secondary
-- but a convertable UOM.
-- 3rd conversion case, we need to perform an item specific conversion
--          IF ( l_line_tbl(1).order_quantity_uom <> l_line_tbl(1).ordered_quantity_uom2) THEN

--                 l_line_tbl(1).ordered_quantity2 := GMI_Reservation_Util.get_opm_converted_qty
--                                (p_apps_item_id    => l_line_tbl(1).inventory_item_id,
--                                 p_organization_id => l_line_tbl(1).ship_from_org_id,
--                                 p_apps_from_uom   => l_line_tbl(1).order_quantity_uom,
--                                 p_apps_to_uom     => l_line_tbl(1).ordered_quantity_uom2,
--                                 p_original_qty    => l_temp_shipped_qty);
--                IF l_debug_level  > 0 THEN
--                    oe_debug_pub.add(  'OPM 3RD CONVERSION AND CONV. VALUE IS '|| L_LINE_TBL ( 1 ) .ORDERED_QUANTITY2 , 1 ) ;
--                END IF;
                   IF g_debug_call  > 0 THEN
                      G_DEBUG_MSG := G_DEBUG_MSG || '109,';
                   END IF;
-- ordered item is in secondary UOM
--          ELSE
--              l_line_tbl(1).ordered_quantity2 := l_temp_shipped_qty;
--          END IF;
            l_line_tbl(1).ordered_quantity2 :=  l_line_rec.shipped_quantity2; --bug 2999767
-- item is a single UOM
        ELSE
          l_line_tbl(1).ordered_quantity2 :=NULL;
           IF g_debug_call  > 0 THEN
              G_DEBUG_MSG := G_DEBUG_MSG || '115,';
           END IF;
        END IF;

        l_uom_different :=1;

      ELSE  -- UOMS are same. This is good for discrete and OPM
        l_line_tbl(1).ordered_quantity := l_line_rec.shipped_quantity;
-- check if item is a dual UOM
        IF ( l_line_tbl(1).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR ) THEN
          l_line_tbl(1).ordered_quantity2 := l_line_rec.shipped_quantity2;
-- single UOM item
        ELSE
          l_line_tbl(1).ordered_quantity2 := NULL;
        END IF;

      END IF; -- end of uoms are different
                  --  IF ( l_line_tbl(1).shipping_quantity_uom <> l_line_tbl(1).order_quantity_uom )
                  --  AND oe_line_util.Process_Characteristics
-- HW end of changes for BUG#: 2415731

      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_line_tbl(1).split_action_code := 'SPLIT';
      l_line_tbl(1).split_by := 'SYSTEM';

-- Assign the second record of the table for process order for
-- create of new line.

      l_line_tbl(2) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_tbl(2).split_from_line_id := l_line_rec.line_id;

-- HW BUG#: 2415731.

      IF ( l_uom_different = 1 ) THEN  -- UOMS are different and it is dual item line -- INVCONV
	l_line_tbl(2).ordered_quantity := l_line_rec.ordered_quantity - l_temp_shipped_qty;
-- Check if item is a dual UOM
        IF ( l_line_tbl(1).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR ) THEN

-- In OPM, User can order in a 3rd UOM that is not primary nor secondary
-- but a convertable UOM.
-- 3rd conversion case, we need to perform an item specific conversion

--           IF ( l_line_tbl(1).order_quantity_uom <> l_line_tbl(1).ordered_quantity_uom2) THEN
--              l_line_tbl(2).ordered_quantity2 := GMI_Reservation_Util.get_opm_converted_qty
--			      ( p_apps_item_id    => l_line_tbl(1).inventory_item_id,
--                                p_organization_id => l_line_tbl(1).ship_from_org_id,
--                                p_apps_from_uom   => l_line_tbl(1).order_quantity_uom,
--                                p_apps_to_uom     => l_line_tbl(1).ordered_quantity_uom2,
--                                p_original_qty    => l_line_tbl(2).ordered_quantity);

-- ordered item is in secondary UOM
--           ELSE
--             l_line_tbl(2).ordered_quantity2 := l_line_rec.ordered_quantity2 -
--                                                l_temp_shipped_qty;
--           END IF;
-- Item is a single UOM

         -- bug2999767
         l_line_tbl(2).ordered_quantity2 :=  l_line_rec.ordered_quantity2 -
	                                     l_line_rec.shipped_quantity2;
        ELSE
          l_line_tbl(2).ordered_quantity2 := NULL;
        END IF;
	IF g_debug_call > 0 THEN
           G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-9-18';
        END IF;

      ELSE -- UOMS are same. This is good for discrete and OPM
	l_line_tbl(2).ordered_quantity := l_line_rec.ordered_quantity -
		                          l_line_rec.shipped_quantity;
-- Check if item is a dual UOM
        IF ( l_line_tbl(1).ordered_quantity_uom2 <> FND_API.G_MISS_CHAR ) THEN
          l_line_tbl(2).ordered_quantity2 :=  l_line_rec.ordered_quantity2 -
	                                      l_line_rec.shipped_quantity2;
-- Item is a single UOM
	ELSE
	  l_line_tbl(2).ordered_quantity2 := NULL;
	END IF;

      END IF;  --    IF ( l_line_tbl(1).shipping_quantity_uom <> l_line_tbl(1).order_quantity_uom )
               --     AND oe_line_util.Process_Characteristics end of branching
-- HW end of changes 2415731


      l_line_tbl(2).operation          := OE_GLOBALS.G_OPR_CREATE;
      l_line_tbl(2).split_by           := 'SYSTEM';

-- HW BUG#:2415731 added debugging messages for qty2 and others
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SPLIT FROM LINE: '||TO_CHAR ( L_LINE_TBL ( 2 ) .SPLIT_FROM_LINE_ID ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORIGINAL ORD QTY : '||TO_CHAR ( L_LINE_REC.ORDERED_QUANTITY ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORD QTY OLD LINE : '||TO_CHAR ( L_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORD QTY2 OLD LINE : '||TO_CHAR ( L_LINE_TBL ( 1 ) .ORDERED_QUANTITY2 ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORD QTY NEW LINE : '||TO_CHAR ( L_LINE_TBL ( 2 ) .ORDERED_QUANTITY ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORD QTY2 NEW LINE : '||TO_CHAR ( L_LINE_TBL ( 2 ) .ORDERED_QUANTITY2 ) , 3 ) ;
      END IF;
      IF g_debug_call > 0 THEN
         G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-9-19';
      END IF;

      -- 4. Call to process order will result in call to
      --    update_shipping_attributes for update of ordered quantity
      --    and creation of new line.

      l_control_rec.validate_entity    := FALSE;
      l_control_rec.check_security     := FALSE;

      IF  OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN
        l_set_recursion := 'N';
      ELSE
        l_set_recursion := 'Y';
      END IF;

      Call_Process_Order
      ( p_line_tbl       => l_line_tbl,
        p_control_rec    => l_control_rec,
        x_return_status  => l_return_status);

      IF  l_set_recursion = 'Y' THEN
        l_set_recursion := 'N';
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RET STS PROCESS ORDER : '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF; -- split

  IF g_debug_call > 0 THEN
     G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-9-21';
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ITEM TYPE CODE HERE '|| L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
  END IF;

  IF l_line_rec.item_type_code = 'CONFIG' THEN

    SELECT ato_line_id
    INTO   l_line_rec.ato_line_id
    FROM   oe_order_lines
    WHERE  line_id = l_line_rec.line_id;

    Handle_Config_Parent
    ( p_ato_line_id    => l_line_rec.ato_line_id);
  END IF;

  -- Check for Shipment within ship tolerance below, within ship tolerance
  -- above and beyond tolerance.

  IF l_x_result_out  =  OE_GLOBALS.G_SHIPPED_WITHIN_TOL_BELOW OR
     l_x_result_out  =  OE_GLOBALS.G_SHIPPED_WITHIN_TOL_ABOVE OR
     l_x_result_out  =  OE_GLOBALS.G_PARTIALLY_SHIPPED        OR
     l_x_result_out  =  OE_GLOBALS.G_FULLY_SHIPPED            OR
     l_x_result_out  =  OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE
  THEN

    IF p_check_line_set = 'Y' AND
       l_x_result_out <>  OE_GLOBALS.G_PARTIALLY_SHIPPED AND
       l_line_rec.item_type_code IN ('STANDARD') THEN

       -- not now 'CONFIG'
       -- l_line_rec.ordered_quantity <??? l_line_rec.shipped_quantity AND
       -- 2617708 OE_CODE_CONTROL.CODE_RELEASE_LEVEL <= '110508'  THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLING Ship_Confirm_Split_Lines '
                           ||l_line_rec.shipped_quantity ,3);
      END IF;
      IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '145';
      END IF;
      Ship_Confirm_Split_Lines
      ( p_line_rec         => l_line_rec
       ,p_shipment_status  => l_x_result_out);

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '9-24';
    END IF;

    OE_Order_WF_Util.Update_Flow_Status_Code
    (p_header_id          =>  l_line_rec.header_id,
     p_line_id            =>  l_line_rec.line_id,
     p_flow_status_code   =>  'SHIPPED',
     x_return_status      =>  l_return_status );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STS FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
    END IF;

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '9-25';
    END IF;
    -- Call WF function to complete the shipment activity

    IF l_x_result_out = OE_GLOBALS.G_SHIPPED_BEYOND_TOLERANCE THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE SHIPPED BEYOND OVERSHIPMENT TOLERANCE ' , 3 ) ;
      END IF;
      l_result_code  := 'OVER_SHIPPED';
    ELSE
      l_result_code  := 'SHIP_CONFIRM';
    END IF;

    -- 1739574  Log a delayed request for Complete Activity
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPLETEACTIVITY , LOG DELAYED REQ '||L_LINE_REC.LINE_ID , 3 ) ;
    END IF;

    OE_Delayed_Requests_Pvt.Log_Request
    (p_entity_code             =>      OE_GLOBALS.G_ENTITY_ALL,
     p_entity_id               =>      l_line_rec.line_id,
     p_requesting_entity_code  =>      OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id    =>      l_line_rec.line_id,
     p_request_type            =>      OE_GLOBALS.G_COMPLETE_ACTIVITY,
     p_param1                  =>      OE_GLOBALS.G_WFI_LIN,
     p_param2                  =>      l_line_rec.line_id,
     p_param3                  =>      'SHIP_LINE',
     p_param4                  =>      l_result_code,
     x_return_status           =>      l_return_status);
     IF g_debug_call > 0 THEN
     G_DEBUG_MSG := G_DEBUG_MSG || '9-27';
     END IF;
     IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_line_rec.arrival_set_id IS NOT NULL AND
        l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
       UPDATE  OE_SETS
       SET    SET_STATUS = 'C'
       WHERE  SET_ID = l_line_rec.arrival_set_id;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SET CLOSED: '|| L_LINE_REC.ARRIVAL_SET_ID , 3 ) ;
       END IF;
     END IF;

  END IF;
  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '9-28';
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SHIP_CONFIRM_STANDARD_LINE '|| X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Ship_Confirm_Standard_Line'
        );
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E20';
    END IF;

  WHEN   FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_CONFIRM_STANDARD_LINE EXC ERROR' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-21';
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME,
           'Ship_Confirm_Standard_Line'
        );
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E22';
    END IF;
END Ship_Confirm_Standard_Line;

/*--------------------------------------------------------------
PROCEDURE Handle_Config_Parent
To progress the ATO parent of config line.
---------------------------------------------------------------*/
PROCEDURE Handle_Config_Parent
( p_ato_line_id   IN  NUMBER)
IS
  l_return_status    VARCHAR2(1);
  l_activity_status  VARCHAR2(8);
  l_activity_result  VARCHAR2(30);
  l_activity_id      NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING HANDLE_CONFIG_PARENT ' , 1 ) ;
  END IF;

  -- Call work flow engine to complete the WAIT_FOR_CTO work flow
  -- activity for the MODEL line

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET ACTIVITY RESULT : '|| P_ATO_LINE_ID , 3 ) ;
  END IF;

    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '10-1';
    END IF;

    OE_LINE_FULLFILL.Get_Activity_Result
    (  p_item_type            => OE_GLOBALS.G_WFI_LIN
    ,  p_item_key             => p_ato_line_id
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
        END IF;

        -- 1739574 Log a delayed request for Complete Activity

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPLETE ACTIVITY , FOR '|| P_ATO_LINE_ID , 3 ) ;
        END IF;
        IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '10-3';
        END IF;

        OE_Delayed_Requests_Pvt.Log_Request
        ( p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
          p_entity_id              => p_ato_line_id,
          p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
          p_requesting_entity_id   => p_ato_line_id,
          p_request_type           => OE_GLOBALS.G_COMPLETE_ACTIVITY,
          p_param1                 => OE_GLOBALS.G_WFI_LIN,
          p_param2                 => p_ato_line_id,
          p_param3                 => 'WAIT_FOR_CTO',
          p_param4                 => OE_GLOBALS.G_WFR_COMPLETE,
          x_return_status          => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;
    END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING HANDLE_CONFIG_PARENT '|| L_RETURN_STATUS , 1 ) ;
  END IF;
  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '10-4';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HANDLE_CONFIG_PARENT ERROR '|| SQLERRM , 1 ) ;
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-23';
    END IF;
    RAISE;
END Handle_Config_Parent;


/*------------------------------------------------------------------
PROCEDURE Ship_Confirm_ATO

This procedure should be called for a CONFIG line with
model_remnant_clag = 'N' and only when the CONFIG line
is part of a top level ATO.
The PTO+ATO case is handled by Ship_Confirm_PTO_KIT procedure
-------------------------------------------------------------------*/
-- INVCONV - OPEN ISSUE FOR opm CONVREGENCE RIGHT NOW FOR ato SUPPORT

PROCEDURE Ship_Confirm_ATO
( p_line_id  IN   NUMBER
 ,x_return_status OUT NOCOPY VARCHAR2)
IS
  l_line_id              NUMBER;
  l_return_status        VARCHAR2(1);
  l_line_rec             OE_ORDER_PUB.Line_Rec_Type;
  l_update_line_tbl      OE_ORDER_PUB.Line_Tbl_Type;
  l_control_rec          OE_GLOBALS.Control_Rec_Type;
  l_set_recursion        VARCHAR2(1) := 'N';
  l_split_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
  l_result_out           VARCHAR2(30);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_SHIPPING_INTEGRATION_PVT.SHIP_CONFIRM_ATO '
                     || TO_CHAR ( P_LINE_ID ) , 1 ) ;
  END IF;

  l_line_id  := p_line_id;

  -- Call Process Order to Update the MODEL SHIPPED Quantity

  OE_Line_Util.Query_Row
  (p_line_id   => p_line_id,
   x_line_rec  => l_line_rec);

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '10-5';
  END IF;
  OE_Line_Util.Query_Rows
  (p_line_id   => l_line_rec.top_model_line_id,
   x_line_tbl  => l_update_line_tbl);

  l_control_rec                := OE_GLOBALS.G_MISS_CONTROL_REC;
  l_control_rec.validate_entity:= FALSE;
  l_control_rec.check_security := FALSE;

  l_update_line_tbl(1).operation            := OE_GLOBALS.G_OPR_UPDATE;
  l_update_line_tbl(1).shipped_quantity     := l_line_rec.shipped_quantity;
  l_update_line_tbl(1).actual_shipment_date := l_line_rec.actual_shipment_date;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ACTUAL SHIPMENT DATE :'
     ||TO_CHAR(L_UPDATE_LINE_TBL(1).ACTUAL_SHIPMENT_DATE,'DD-MM-YY'),3);
  END IF;

  IF  OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN
    l_set_recursion := 'N';
  ELSE
    l_set_recursion := 'Y';
  END IF;

  Call_Process_Order
  ( p_line_tbl       => l_update_line_tbl,
    p_control_rec    => l_control_rec,
    x_return_status  => l_return_status);

  IF  l_set_recursion = 'Y' THEN
    l_set_recursion := 'N';
  END IF;

  IF l_debug_level  > 0 THEN
  oe_debug_pub.add('RET STS FROM PROCESS ORDER : '||L_RETURN_STATUS , 3 ) ;
  END IF;

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '10-7';
  END IF;
  --------- split the entire ato MODEL if partailly shipped -------

  Check_Shipment_Line
  (p_line_rec         => l_line_rec,
--   p_shipped_quantity => l_shipped_quantity,
   x_result_out       => l_result_out);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SHIPMENT STATUS : '||L_RESULT_OUT , 3 ) ;
  END IF;


  IF l_result_out  =  OE_GLOBALS.G_PARTIALLY_SHIPPED AND

    l_line_rec.ordered_quantity > l_line_rec.shipped_quantity THEN

    l_split_line_tbl(1)                  := l_update_line_tbl(1);
    l_split_line_tbl(1).ordered_quantity := l_line_rec.shipped_quantity;
    l_split_line_tbl(1).operation        := OE_GLOBALS.G_OPR_UPDATE;
    l_split_line_tbl(1).split_action_code:= 'SPLIT';
    l_split_line_tbl(1).split_by         := 'SYSTEM';

    -- Assign the second record of the table for process order for
    -- create of new line.

    l_split_line_tbl(2)                    := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_split_line_tbl(2).split_from_line_id := l_update_line_tbl(1).line_id;
    l_split_line_tbl(2).ordered_quantity   :=
           l_line_rec.ordered_quantity - l_line_rec.shipped_quantity;
    l_split_line_tbl(2).operation          := OE_GLOBALS.G_OPR_CREATE;
    l_split_line_tbl(2).split_by           := 'SYSTEM';

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ITEM TYPE CODE : '||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '10-8';
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SPLIT FROM LINE ID : '
      ||TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .SPLIT_FROM_LINE_ID ) , 3 ) ;

      oe_debug_pub.add( 'ORIGINAL ORDERED QUANTITY : '
                        ||TO_CHAR ( L_LINE_REC.ORDERED_QUANTITY ) , 3 ) ;
      oe_debug_pub.add(  'ORDERED QUANTITY OLD LINE : '
      ||TO_CHAR ( L_SPLIT_LINE_TBL ( 1 ) .ORDERED_QUANTITY ) , 3 ) ;

      oe_debug_pub.add(  'ORDERED QUANTITY NEW LINE : '
      ||TO_CHAR ( L_SPLIT_LINE_TBL ( 2 ) .ORDERED_QUANTITY ) , 3 ) ;
    END IF;

    l_control_rec                      := OE_GLOBALS.G_MISS_CONTROL_REC;
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := FALSE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.clear_dependents     := TRUE;

    IF  OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN
      l_set_recursion := 'N';
    ELSE
      l_set_recursion := 'Y';
    END IF;

    Call_Process_Order
    (p_line_tbl       => l_split_line_tbl,
     p_control_rec    => l_control_rec,
     x_return_status  => l_return_status);

    IF  l_set_recursion = 'Y' THEN
      l_set_recursion := 'N';
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-10-9';
    END IF;
    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('RET STS FROM PROCESS ORDER:'||L_RETURN_STATUS , 3 ) ;
    END IF;

  END IF;


  -------  call ship confirm std line to complete wf, flow sts ---

  Ship_Confirm_Standard_Line
  (p_line_id          =>  l_line_id,
   x_return_status    =>  l_return_status);

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '1-10';
  END IF;

  IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
    OE_MSG_PUB.Add_Exc_Msg
    (G_PKG_NAME,
     'Ship_Confirm_ATO');
  END IF;
  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || 'E-24';
  END IF;

  WHEN   FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-25';
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME,
       'Ship_Confirm_ATO');
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-26';
    END IF;

END Ship_Confirm_ATO;


/*---------------------------------------------------------------------
PROCEDURE Ship_Confirm_Ship_Set
---------------------------------------------------------------------*/
PROCEDURE Ship_Confirm_Ship_Set
(
	p_ship_set_id		IN	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_line_tbl				OE_ORDER_PUB.Line_Tbl_Type;
	l_line_index			NUMBER;
	l_process_tbl			OE_Order_Pub.Line_Tbl_Type;
	l_process_index			NUMBER := 0;
	l_set_tbl				OE_ORDER_PUB.Line_Tbl_Type;
	l_set_index				NUMBER := 0;
	l_control_rec			OE_GLOBALS.Control_Rec_Type;
	l_line_shipped			VARCHAR2(1) := FND_API.G_FALSE;
	l_return_status			VARCHAR2(1);
	l_set_recursion				VARCHAR2(1) := 'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PVT.SHIP_CONFIRM_SHIP_SET '|| TO_CHAR ( P_SHIP_SET_ID ) , 1 ) ;
	END IF;

        IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '11-1';
        END IF;
	-- Call set function to get all the lines in a set.

--	l_line_tbl := OE_Set_Util.Query_Set_Rows(p_ship_set_id);

	OE_Set_Util.Query_Set_Rows(p_set_id	=> p_ship_set_id,
						  x_line_tbl	=> l_line_tbl);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NUMBER OF LINES IN THE SET '|| TO_CHAR ( L_LINE_TBL.COUNT ) , 3 ) ;
	END IF;
	-- Update the set status to closed.

	UPDATE	OE_SETS
	SET		SET_STATUS = 'C'
	WHERE	SET_ID = p_ship_set_id;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SET IS CLOSED : '||TO_CHAR ( P_SHIP_SET_ID ) , 3 ) ;
	END IF;

	-- Prepare a table with PTO_KIT/ATO/STANDARD lines.

	FOR l_line_index IN	l_line_tbl.FIRST .. l_line_tbl.LAST
	LOOP

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IN THE SET LOOP ' , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INDEX/ITEM TYPE : '||TO_CHAR ( L_LINE_INDEX ) ||'/'||L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE_ID/TOP_MODEL_LINE_ID : '||TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) ||'/'||TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .TOP_MODEL_LINE_ID ) , 3 ) ;
		END IF;

		IF	(l_line_tbl(l_line_index).link_to_line_id = l_line_tbl(l_line_index).top_model_line_id AND
			 l_line_tbl(l_line_index).item_type_code = OE_Globals.G_ITEM_CONFIG) THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'IT IS AN ATO ' , 3 ) ;
			END IF;
			l_process_index := l_process_index + 1;
			l_process_tbl(l_process_index) := l_line_tbl(l_line_index);


		ELSIF	(l_line_tbl(l_line_index).top_model_line_id	IS NOT NULL AND
				 l_line_tbl(l_line_index).top_model_line_id <> FND_API.G_MISS_NUM AND
				 l_line_tbl(l_line_index).line_id = l_line_tbl(l_line_index).top_model_line_id) AND
				 (l_line_tbl(l_line_index).ato_line_id IS NULL OR
				 l_line_tbl(l_line_index).ato_line_id = FND_API.G_MISS_NUM) THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'IT IS A PTO/KIT ' , 3 ) ;
				END IF;
				l_process_index := l_process_index + 1;
				l_process_tbl(l_process_index) := l_line_tbl(l_line_index);

		ELSIF	l_line_tbl(l_line_index).item_type_code = OE_GLOBALS.G_ITEM_STANDARD THEN

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'IT IS A STANDARD LINE' , 3 ) ;
				END IF;
				l_process_index := l_process_index + 1;
				l_process_tbl(l_process_index) := l_line_tbl(l_line_index);
		END IF;

	END LOOP;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'NUMBER OF LINES TO PROCESS : '||TO_CHAR ( L_PROCESS_INDEX ) , 3 ) ;
	END IF;
        IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-11-3';
        END IF;
	FOR l_process_index IN l_process_tbl.FIRST .. l_process_tbl.LAST
	LOOP

		IF	l_process_tbl(l_process_index).top_model_line_id IS NOT NULL AND
			l_process_tbl(l_process_index).top_model_line_id <> FND_API.G_MISS_NUM AND
			/* Commented for bug 1820608
			(l_process_tbl(l_process_index).ato_line_id IS NULL OR
			l_process_tbl(l_process_index).ato_line_id = FND_API.G_MISS_NUM) THEN */
            /* Added condition of KIT for bug 1926571 */
			l_process_tbl(l_process_index).item_type_code IN ('MODEL','KIT') THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'IT IS PTO/KIT '||TO_CHAR ( L_PROCESS_TBL ( L_PROCESS_INDEX ) .TOP_MODEL_LINE_ID ) , 3 ) ;
			END IF;

			-- Check if any of the option has been shipped for the model


			FOR l_line_index IN	l_line_tbl.FIRST .. l_line_tbl.LAST
			LOOP

				IF	l_line_tbl(l_line_index).top_model_line_id = l_process_tbl(l_process_index).top_model_line_id AND
					nvl(l_line_tbl(l_line_index).shippable_flag,'N') = 'Y' AND
					nvl(l_line_tbl(l_line_index).shipped_quantity,0) <> 0 AND
					l_line_tbl(l_line_index).shipped_quantity <> FND_API.G_MISS_NUM THEN
					l_line_shipped := FND_API.G_TRUE;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'LINE IS SHIPPED '||TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) , 3 ) ;
					END IF;

					Ship_Confirm_PTO_KIT
					(
						p_top_model_line_id	=>	l_process_tbl(l_process_index).top_model_line_id,
						x_return_status	=>	l_return_status
					);
					IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
							RAISE FND_API.G_EXC_ERROR;
					END IF;

					GOTO END_PTO_KIT_SET;

				END IF;

			END LOOP;
			<<END_PTO_KIT_SET>>
			NULL;

		ELSIF	nvl(l_process_tbl(l_process_index).shipped_quantity,0) <> 0 AND
			l_process_tbl(l_process_index).shipped_quantity <> FND_API.G_MISS_NUM THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'INSIDE THE LOOP : LINE ID : '|| TO_CHAR ( L_PROCESS_TBL ( L_PROCESS_INDEX ) .LINE_ID ) , 3 ) ;
			END IF;
			IF	l_process_tbl(l_process_index).item_type_code = OE_GLOBALS.G_ITEM_STANDARD THEN
				Ship_Confirm_Standard_Line
				(
					p_line_rec		=>	l_process_tbl(l_process_index),
					x_return_status	=>	l_return_status
				);

				IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;

			IF	l_process_tbl(l_process_index).item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
				Ship_Confirm_ATO
				(
					p_line_id		=>	l_process_tbl(l_process_index).line_id,
					x_return_status =>	l_return_status
				);

				IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
					RAISE FND_API.G_EXC_ERROR;
				END IF;
			END IF;

			l_line_shipped := FND_API.G_TRUE;
		END IF;

		IF	l_line_shipped = FND_API.G_FALSE THEN

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'SHIP SET IS PARTIALLY SHIPPED REMOVING THE SETID '||TO_CHAR ( L_PROCESS_TBL ( L_PROCESS_INDEX ) .LINE_ID ) , 3 ) ;
			END IF;
			l_set_index := l_set_index + 1;
			l_set_tbl(l_set_index) := OE_Order_Pub.G_MISS_LINE_REC;
			IF	l_process_tbl(l_process_index).item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
				l_set_tbl(l_set_index).line_id := l_process_tbl(l_process_index).top_model_line_id;
			ELSE
				l_set_tbl(l_set_index).line_id := l_process_tbl(l_process_index).line_id;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'LINE ID : '||TO_CHAR ( L_SET_TBL ( L_SET_INDEX ) .LINE_ID ) , 3 ) ;
			END IF;
			l_set_tbl(l_set_index).ship_set_id := NULL;
			l_set_tbl(l_set_index).operation := OE_GLOBALS.G_OPR_UPDATE;

		END IF;

		l_line_shipped := FND_API.G_FALSE;

	END LOOP;

	IF	l_set_index <> 0 THEN

		l_control_rec := OE_GLOBALS.G_MISS_CONTROL_REC;
		l_control_rec.validate_entity		:= FALSE;
		l_control_rec.check_security		:= FALSE;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CALLING PROCESS ORDER TO UPDATE SHIP SET ID' , 3 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'NUMBER OF LINES '||TO_CHAR ( L_SET_INDEX ) , 3 ) ;
		END IF;

        IF  OE_GLOBALS.G_RECURSION_MODE = 'Y' THEN

            l_set_recursion := 'N';

		ELSE

            l_set_recursion := 'Y';
			-- OE_GLOBALS.G_RECURSION_MODE := 'Y';

		END IF;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '11-8';
                END IF;

		Call_Process_Order
		(
			p_line_tbl		=> l_set_tbl,
			p_control_rec	=> l_control_rec,
			x_return_status	=> l_return_status
		);

		IF  l_set_recursion = 'Y' THEN

            l_set_recursion := 'N';
			-- OE_GLOBALS.G_RECURSION_MODE := 'N';
		END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RETURN STATUS FROM PROCESS ORDER : '||L_RETURN_STATUS , 3 ) ;
		END IF;
		IF	l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF	l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	x_return_status := l_return_status;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING FROM OE_SHIPPING_INTEGRATION_PVT.SHIP_CONFIRM_SHIP_SET : '||X_RETURN_STATUS , 1 ) ;
	END IF;
        IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || '11-9';
        END IF;

EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Ship_Confirm_Ship_Set'
				);
			END IF;
                 IF g_debug_call > 0 THEN
                 G_DEBUG_MSG := G_DEBUG_MSG || 'E-27';
                 END IF;

   	WHEN 	FND_API.G_EXC_ERROR THEN
        	x_return_status := FND_API.G_RET_STS_ERROR;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E-28';
                END IF;
	WHEN OTHERS THEN
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Ship_Confirm_Ship_Set'
				);
			END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
		END IF;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E-29';
                END IF;
	NULL;

END Ship_Confirm_Ship_Set;

PROCEDURE Process_Ship_Confirm
(
	p_process_id		IN	NUMBER
,	p_process_type		IN	VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2

)
IS
	l_line_rec					OE_ORDER_PUB.line_rec_type;
	l_line_id					NUMBER;
	l_ordered_quantity			NUMBER;
	l_shipped_quantity			NUMBER;
	l_x_return_status			VARCHAR2(1);
	l_msg_count					NUMBER;
	l_msg_data					VARCHAR2(2000);
	l_tolerance_quantity_below	NUMBER;
	l_tolerance_quantity_above	NUMBER;
	l_old_recursion_mode          VARCHAR2(1) := OE_GLOBALS.G_RECURSION_MODE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_SHIPPING_INTEGRATION_PVT.PROCESS_SHIP_CONFIRM '|| P_PROCESS_TYPE , 1 ) ;
	END IF;

--   Setting the Global variable OE_GLOBALS.G_RECURSION_MODE to Y so that the
--   Price request for "SHIP" event is not triggered before COST records are
--   inserted into OE_PRICE_ADJUSTMENTS.

     IF g_debug_call > 0 THEN
     G_DEBUG_MSG := G_DEBUG_MSG || '12-1';
     END IF;

     IF OE_GLOBALS.G_RECURSION_MODE <> 'Y' THEN
         -- OE_GLOBALS.G_RECURSION_MODE := 'Y';
         null;
     END IF;


		IF	p_process_type = 'ATO' AND
			(p_process_id IS NOT NULL AND
			 p_process_id <> FND_API.G_MISS_NUM) THEN

			-- Call procedure for Ship Confirmation of ATO
			Ship_Confirm_ATO
			(
				p_line_id		=>	p_process_id,
				x_return_status =>	l_x_return_status
			);
			IF	l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF	l_x_return_status = FND_API.G_RET_STS_ERROR THEN
					RAISE FND_API.G_EXC_ERROR;
			END IF;

		ELSIF	p_process_type = 'PTO_KIT' AND
				(p_process_id IS NOT NULL AND
				 p_process_id <> FND_API.G_MISS_NUM) THEN

				-- Call procedure for Ship Confirmation of PTO and KIT


				Ship_Confirm_PTO_KIT
				(
					p_top_model_line_id	=>	p_process_id,
					x_return_status	=>	l_x_return_status
				);
				IF	l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_x_return_status = FND_API.G_RET_STS_ERROR THEN
						RAISE FND_API.G_EXC_ERROR;
				END IF;


		ELSIF	p_process_type = 'SHIP_SET' AND
				(p_process_id IS NOT NULL AND
				 p_process_id <> FND_API.G_MISS_NUM) THEN

				-- Call procedure for Ship Confirmation of SHIP_SET

				Ship_Confirm_Ship_Set
				(
					p_ship_set_id		=>	p_process_id,
					x_return_status	=>	l_x_return_status
				);
				IF	l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF	l_x_return_status = FND_API.G_RET_STS_ERROR THEN
						RAISE FND_API.G_EXC_ERROR;
				END IF;
		ELSE

		-- Call procedure for Ship Confirmation of Standard Line
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || '12-5';
                END IF;

		Ship_Confirm_Standard_Line
		(
			p_line_id			=>	p_process_id,
			x_return_status	=>	l_x_return_status
		);

		IF	l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF	l_x_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
		END IF;


	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_old_recursion_mode <> OE_GLOBALS.G_RECURSION_MODE THEN
         -- OE_GLOBALS.G_RECURSION_MODE := l_old_recursion_mode;
         null;
     END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURNED FROM OE_SHIPPING_INTEGRATION_PVT.PROCESS_SHIP_CONFIRM '|| X_RETURN_STATUS , 1 ) ;
	END IF;

EXCEPTION
	WHEN	FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_old_recursion_mode <> OE_GLOBALS.G_RECURSION_MODE THEN
             -- OE_GLOBALS.G_RECURSION_MODE := l_old_recursion_mode;
             null;
         END IF;

        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Process_Ship_Confirm'
				);
			END IF;
                        IF g_debug_call > 0 THEN
                        G_DEBUG_MSG := G_DEBUG_MSG || 'E-30';
                        END IF;

   	WHEN 	FND_API.G_EXC_ERROR THEN
         IF l_old_recursion_mode <> OE_GLOBALS.G_RECURSION_MODE THEN
             -- OE_GLOBALS.G_RECURSION_MODE := l_old_recursion_mode;
             null;
         END IF;
        	x_return_status := FND_API.G_RET_STS_ERROR;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E31';
                END IF;
	WHEN OTHERS THEN
         IF l_old_recursion_mode <> OE_GLOBALS.G_RECURSION_MODE THEN
             -- OE_GLOBALS.G_RECURSION_MODE := l_old_recursion_mode;
             null;
         END IF;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E-32';
                END IF;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

			IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
			THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME,
				   'Process_Ship_Confirm'
				);
			END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
		END IF;
	NULL;

END Process_Ship_Confirm;


/*-------------------------------------------------------------
PROCEDURE Process_Shipping_Activity

This procedure is called from workflow.
It broadly has 3 sections,
  external/return lines
  SMC lines
  non SMC and standard lines

Change Record : bug fix 3539694 - included items if created
by scheduling wf activity, bypass hvop.
--------------------------------------------------------------*/
PROCEDURE Process_Shipping_Activity
( p_api_version_number    IN      NUMBER
 ,p_line_id               IN      NUMBER
,x_result_out OUT NOCOPY VARCHAR2

,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY VARCHAR2

,x_msg_data OUT NOCOPY VARCHAR2)

IS
  l_line_index                NUMBER;
  l_shipping_activity         VARCHAR2(1) := FND_API.G_TRUE;
  l_return_status             VARCHAR2(1);
  l_freeze_method             VARCHAR2(30);
  l_flow_status_code          VARCHAR2(30);
  l_line_category_code        VARCHAR2(30);
  l_source_type_code          VARCHAR2(30);
  l_ship_model_complete_flag  VARCHAR2(1);
  l_top_model_line_id         NUMBER;
  l_shippable_flag            VARCHAR2(1);
  l_explosion_date            DATE;
  l_ato_line_id               NUMBER;
  l_line_id                   NUMBER;
  l_item_type_code            VARCHAR2(30);
  l_header_id                 NUMBER;
  l_model_remnant_flag        VARCHAR2(1);
  l_link_to_line_id           NUMBER;
  l_parent_explosion_date     DATE;
  l_enforce_smc_flag          VARCHAR2(1) := 'N';
  l_ship_from_org_id          NUMBER;
  l_count                     NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

  CURSOR c_lines IS
  SELECT line_id
  FROM   oe_order_lines,wf_item_activity_statuses wias,
         wf_process_activities wpa
  WHERE  header_id           = l_header_id
  AND    top_model_line_id   = l_top_model_line_id
  AND    link_to_line_id     = p_line_id
  AND    item_type_code      = 'INCLUDED'
  AND    wias.item_type      = 'OEOL'
  AND    wias.item_key       = to_char(line_id)
  AND    wias.process_activity = wpa.instance_id
  AND    wpa.activity_name   = 'SHIP_LINE'
  AND    wias.activity_status = 'NOTIFIED'
  AND    shipping_interfaced_flag = 'N'
  ORDER BY line_number,shipment_number,nvl(option_number,-1),
                                    nvl(component_number,-1);

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'enter process_shipping_activity for line ID '|| P_LINE_ID , 1 ) ;
  END IF;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '201';
  END IF;

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('bulk call?? line id '|| OE_BULK_ORDER_PVT.G_LINE_REC.line_id
       (OE_BULK_WF_UTIL.G_LINE_INDEX), 2);
    END IF;
  END IF;

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL AND
     OE_BULK_ORDER_PVT.G_LINE_REC.line_id(OE_BULK_WF_UTIL.G_LINE_INDEX) =
     p_line_id THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add
      ('2 shipping bulk mode '|| OE_BULK_WF_UTIL.G_LINE_INDEX, 4);
    END IF;

    l_line_category_code := OE_BULK_ORDER_PVT.G_LINE_REC.line_category_code
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_source_type_code := OE_BULK_ORDER_PVT.G_LINE_REC.source_type_code
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    --oe_debug_pub.add('here 2: ', 2);

    l_ship_model_complete_flag
                   := OE_BULK_ORDER_PVT.G_LINE_REC.ship_model_complete_flag
                      (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_top_model_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.top_model_line_id
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);
    l_link_to_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.link_to_line_id
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_ato_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.ato_line_id
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);
    l_model_remnant_flag := OE_BULK_ORDER_PVT.G_LINE_REC.model_remnant_flag
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_shippable_flag := OE_BULK_ORDER_PVT.G_LINE_REC.shippable_flag
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_explosion_date := OE_BULK_ORDER_PVT.G_LINE_REC.explosion_date
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.line_id
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);
    l_item_type_code := OE_BULK_ORDER_PVT.G_LINE_REC.item_type_code
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);
    --oe_debug_pub.add('here 3: ', 2);
    l_header_id := OE_BULK_ORDER_PVT.G_LINE_REC.header_id
                 (OE_BULK_WF_UTIL.G_LINE_INDEX);

    --oe_debug_pub.add('here 4: ', 2);
  ELSE
    SELECT line_category_code,
          source_type_code,
          ship_model_complete_flag,
          top_model_line_id,
          link_to_line_id,
          shippable_flag,
          explosion_date,
          ato_line_id,
          line_id,
          item_type_code,
          header_id,
          model_remnant_flag,
          ship_from_org_id

    INTO  l_line_category_code,
          l_source_type_code,
          l_ship_model_complete_flag,
          l_top_model_line_id,
          l_link_to_line_id,
          l_shippable_flag,
          l_explosion_date,
          l_ato_line_id,
          l_line_id,
          l_item_type_code,
          l_header_id,
          l_model_remnant_flag,
          l_ship_from_org_id
    FROM    OE_ORDER_LINES_ALL
    WHERE   LINE_ID = p_line_id;

  END IF; -- bulk mode switch

  l_model_remnant_flag := nvl(l_model_remnant_flag, 'N');
  l_shippable_flag     := nvl(l_shippable_flag, 'N');
  l_ship_model_complete_flag := nvl(l_ship_model_complete_flag, 'N');

  x_result_out := 'NOTIFIED:#NULL';

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '204';
  END IF;
  IF  l_line_category_code = 'RETURN' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS A RETURN LINE NOT ELIGIBLE FOR SHIPPING' , 3 ) ;
    END IF;
    x_result_out := 'COMPLETE:NON_SHIPPABLE';
    GOTO END_SHIPPING_PROCESSING;

  END IF;

  IF l_source_type_code = 'EXTERNAL' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS A DROP SHIP LINE' , 3 ) ;
    END IF;

    IF nvl(l_shippable_flag, 'N') = 'N' THEN
      x_result_out := 'COMPLETE:NON_SHIPPABLE';
    END IF;

    GOTO END_SHIPPING_PROCESSING;
  END IF;

  ------------ external and return lines done ------------

  IF l_shippable_flag = 'N' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'NON SHIPPABLE LINE ' || L_ITEM_TYPE_CODE , 3 ) ;
    END IF;
    x_result_out := 'COMPLETE:NON_SHIPPABLE';
  END IF;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '205';
  END IF;

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL AND
     OE_Code_Control.Code_Release_Level >= '110510' AND
     OE_BULK_ORDER_PVT.G_LINE_REC.line_id(OE_BULK_WF_UTIL.G_LINE_INDEX) =
     p_line_id THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('3 shipping bulk mode',5);
    END IF;

    IF OE_BULK_ORDER_PVT.G_LINE_REC.shippable_flag
      (OE_BULK_WF_UTIL.G_LINE_INDEX) = 'Y' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        (OE_BULK_ORDER_PVT.G_LINE_REC.shipping_eligible_flag.COUNT,5);
      END IF;

      IF OE_BULK_ORDER_PVT.G_LINE_REC.shipping_eligible_flag.COUNT <
         OE_BULK_ORDER_PVT.G_LINE_REC.line_id.COUNT THEN

        --------------------------------------------------------
        -- 1st eligible line for wsh interface, so extend all.
        --------------------------------------------------------

        l_count := OE_BULK_ORDER_PVT.G_LINE_REC.line_id.COUNT -
                   OE_BULK_ORDER_PVT.G_LINE_REC.shipping_eligible_flag.COUNT;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('bulk wsh attribs extend begin '
          || OE_BULK_ORDER_PVT.G_LINE_REC.line_id.COUNT
          || ' ' || l_count, 2);
        END IF;


        IF l_count > 0 THEN
          OE_BULK_ORDER_PVT.G_LINE_REC.shipping_eligible_flag.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.sold_to_contact_id.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.source_header_number.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.order_date_type_code.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.source_header_type_id.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.source_header_type_name.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.source_line_number.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.currency_code.extend(l_count);

          OE_BULK_ORDER_PVT.G_LINE_REC.INTERMED_SHIP_TO_CONTACT_ID.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.INTERMED_SHIP_TO_ORG_ID.extend(l_count);

          OE_BULK_ORDER_PVT.G_LINE_REC.item_description.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.hazard_class_id.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.weight_uom_code.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.volume_uom_code.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.requested_quantity_uom.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.mtl_unit_weight.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.mtl_unit_volume.extend(l_count);
          OE_BULK_ORDER_PVT.G_LINE_REC.pickable_flag.extend(l_count);

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('bulk wsh attribs extended '|| l_count,2);
          END IF;
        END IF;
      END IF; -- if not yet extended

      --------------------------------------------------------
      -- Assign values to this line
      --------------------------------------------------------
      OE_BULK_ORDER_PVT.G_LINE_REC.shipping_eligible_flag
      (OE_BULK_WF_UTIL.G_LINE_INDEX) := 'Y';

      --oe_debug_pub.add('here 5: ', 2);

      l_count := OE_BULK_CACHE.Load_Item
                 ( p_key1
                   => OE_BULK_ORDER_PVT.G_LINE_REC.inventory_item_id
                     (OE_BULK_WF_UTIL.G_LINE_INDEX)
                  ,p_key2
                  => OE_BULK_ORDER_PVT.G_LINE_REC.ship_from_org_id
                     (OE_BULK_WF_UTIL.G_LINE_INDEX));

      --oe_debug_pub.add('here 5-1: '
      --|| OE_BULK_ORDER_PVT.G_LINE_REC.ordered_item_id
      --(OE_BULK_WF_UTIL.G_LINE_INDEX), 2);

      IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '208';
      END IF;

      OE_BULK_ORDER_PVT.G_LINE_REC.item_description
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).item_description;

      OE_BULK_ORDER_PVT.G_LINE_REC.hazard_class_id
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).hazard_class_id;

      OE_BULK_ORDER_PVT.G_LINE_REC.weight_uom_code
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).weight_uom_code;

      --oe_debug_pub.add('here 6: ', 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.volume_uom_code
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).volume_uom_code;

      --oe_debug_pub.add('here 6-1: ', 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.requested_quantity_uom
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).primary_uom_code;

      --oe_debug_pub.add('here 6-2: ', 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.mtl_unit_weight
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).unit_weight;

      --oe_debug_pub.add('here 6-3: ', 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.mtl_unit_volume
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).unit_volume;

      --oe_debug_pub.add('here 6-4: ', 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.pickable_flag
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       OE_BULK_CACHE.G_ITEM_TBL(l_count).pickable_flag;

      --oe_debug_pub.add('here 7: ', 2);
      --------------- from header/ xn types --------------------

      OE_BULK_ORDER_PVT.G_LINE_REC.sold_to_contact_id
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_Bulk_Order_PVT.g_header_rec.sold_to_contact_id
      (OE_BULK_WF_UTIL.G_HEADER_INDEX);

      OE_BULK_ORDER_PVT.G_LINE_REC.source_header_number
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_Bulk_Order_PVT.g_header_rec.order_number
      (OE_BULK_WF_UTIL.G_HEADER_INDEX);

      OE_BULK_ORDER_PVT.G_LINE_REC.order_date_type_code
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_Bulk_Order_PVT.g_header_rec.order_date_type_code
      (OE_BULK_WF_UTIL.G_HEADER_INDEX);

      --oe_debug_pub.add('here 8: ', 2);
      OE_BULK_ORDER_PVT.G_LINE_REC.source_header_type_id
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_Bulk_Order_PVT.g_header_rec.order_type_id
      (OE_BULK_WF_UTIL.G_HEADER_INDEX);

      OE_BULK_ORDER_PVT.G_LINE_REC.currency_code
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_Bulk_Order_PVT.g_header_rec.transactional_curr_code
      (OE_BULK_WF_UTIL.G_HEADER_INDEX);

      l_count := OE_BULK_CACHE.Load_Order_Type
                 ( p_key
                   => OE_BULK_ORDER_PVT.G_HEADER_REC.order_type_id
                      (OE_BULK_WF_UTIL.G_HEADER_INDEX));

      OE_BULK_ORDER_PVT.G_LINE_REC.source_header_type_name
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
      OE_BULK_CACHE.G_ORDER_TYPE_TBL(l_count).name;

      --oe_debug_pub.add('here 9: '|| OE_BULK_ORDER_PVT.G_LINE_REC.source_header_type_name(OE_BULK_WF_UTIL.G_LINE_INDEX), 2);

      OE_BULK_ORDER_PVT.G_LINE_REC.source_line_number
      (OE_BULK_WF_UTIL.G_LINE_INDEX) :=
       RTRIM(OE_BULK_ORDER_PVT.G_LINE_REC.line_number
             (OE_BULK_WF_UTIL.G_LINE_INDEX)  || '.' ||
             OE_BULK_ORDER_PVT.G_LINE_REC.shipment_number
             (OE_BULK_WF_UTIL.G_LINE_INDEX)  || '.' ||
             OE_BULK_ORDER_PVT.G_LINE_REC.option_number
             (OE_BULK_WF_UTIL.G_LINE_INDEX)  || '.' ||
             OE_BULK_ORDER_PVT.G_LINE_REC.component_number
             (OE_BULK_WF_UTIL.G_LINE_INDEX)  || '.' ||
             OE_BULK_ORDER_PVT.G_LINE_REC.service_number
             (OE_BULK_WF_UTIL.G_LINE_INDEX),'.');

      --oe_debug_pub.add('here 10: ', 2);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('eligible for shipping '||
        OE_BULK_ORDER_PVT.G_LINE_REC.line_id
        (OE_BULK_WF_UTIL.G_LINE_INDEX), 1 ) ;
      END IF;

    END IF; -- if shippable

    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '209';
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
  END IF; -- bulk mode
  --Start Bug 4094824
  BEGIN
     SELECT Enforce_Ship_Set_And_Smc
     INTO   l_enforce_smc_flag
     FROM   Wsh_Shipping_Parameters
     WHERE  Organization_Id = l_ship_from_org_Id;
     -- Added condition, in case of enforce smc flag is never changed from Checked to Unchecked or
     -- vice versa returns null value
     --
     IF l_enforce_smc_flag IS NULL THEN
        l_enforce_smc_flag := 'N';
     END IF;
     --
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.add('Enforce SMC - flag is '||l_enforce_smc_flag||' for org '||l_ship_from_org_id,1);
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
          IF l_debug_level > 0 THEN
             oe_debug_pub.add('did not find shipping parameter Enforce Ship Set',1);
          END IF;
          NULL;
  END;
  --End Bug 4094824
  IF l_item_type_code in ('MODEL', 'CLASS', 'KIT') AND
     l_explosion_date IS NULL THEN

    l_return_status := OE_Config_Util.Process_Included_Items(
                                      p_line_id          => p_line_id
                                     ,p_freeze           => TRUE
                                     ,p_process_requests => TRUE);

    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '211';
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('After calling explosion : '|| l_return_status , 3 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_ship_model_complete_flag = 'N'  OR l_enforce_smc_flag = 'Y' THEN

           -- Model or Kit is at Shippping we need to interface
           -- the included items to shipping. Interface included items part
           -- of Non Sip Model Complete. Process_SMC_Shipping will take care of
           -- interfacing SMC.

           OE_DEBUG_PUB.Add('Interface Included Items part of NON SMC to shipping', 1);

           FOR c_line IN C_LINES
           LOOP

              IF l_debug_level > 0 THEN
                  OE_DEBUG_PUB.Add('Interfacing Line :'||c_line.line_id);
              END IF;

              Update_Shipping_PVT(p_line_id           => c_line.line_id,
                                  p_shipping_activity => l_shipping_activity,
                                  x_return_status     => l_return_status);
           END LOOP;
       END IF;

  END IF;

  -- Hold all the included items if they are part of
  -- SMC or NON SMC.

  IF l_item_type_code = 'INCLUDED'  AND
     (l_ship_model_complete_flag = 'N' OR l_enforce_smc_flag = 'Y') THEN

       IF g_debug_call > 0 THEN
       G_DEBUG_MSG := G_DEBUG_MSG || '211';
       END IF;

       SELECT explosion_date
       INTO   l_parent_explosion_date
       FROM   oe_order_lines
       WHERE  top_model_line_id = l_top_model_line_id
        AND   header_id         = l_header_id
        AND   line_id           = l_link_to_line_id;

       IF l_parent_explosion_date IS NULL THEN

           IF l_debug_level  > 0 THEN
              OE_DEBUG_PUB.Add('Included Item at Shipping:'||l_line_id, 5 ) ;
           END IF;

           -- Update Flow Status Code as  Ship Line is Notified.
           -- Donot update shipping now!!

           GOTO END_SHIPPING_PROCESSING;
       END IF;

  END IF;


  IF l_ship_model_complete_flag = 'Y' AND
     l_enforce_smc_flag = 'N' AND
     l_top_model_line_id IS NOT NULL AND
     l_model_remnant_flag = 'N' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'processing line is part of SMC PTO at shipping activity' , 5 ) ;
    END IF;

    Process_SMC_Shipping
    (p_line_id               => p_line_id
    ,p_top_model_line_id     => l_top_model_line_id
    ,x_return_status         => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE -- standard, non-smc etc

    IF l_shippable_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'shippable line is at shipping activity, item type '||L_ITEM_TYPE_CODE , 5 ) ;
      END IF;
      IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '213';
      END IF;

      Update_Shipping_PVT(p_line_id           => l_line_id,
                          p_shipping_activity => l_shipping_activity,
                          x_return_status     => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF; -- big IF smc etc.


   G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-14';

  <<END_SHIPPING_PROCESSING>>

  IF x_result_out = 'NOTIFIED:#NULL' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING FLOW STATUS API ' , 3 ) ;
    END IF;

    IF  l_source_type_code = 'EXTERNAL' THEN
      l_flow_status_code := 'AWAITING_RECEIPT';
    ELSE
      l_flow_status_code := 'AWAITING_SHIPPING';
    END IF;

    IF ((l_item_type_code = 'CONFIG' OR
        (l_item_type_code IN ('STANDARD','OPTION') AND
         l_ato_line_id = l_line_id)) AND
         l_source_type_code = 'INTERNAL') OR
         nvl(l_shippable_flag,'N') = 'N' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DO NOT CALL FLOW STATUS API ' , 3 ) ;
      END IF;

      IF g_debug_call > 0 THEN
      G_DEBUG_MSG := G_DEBUG_MSG || '215';
      END IF;

    ELSE

      OE_Order_WF_Util.Update_Flow_Status_Code
      (p_header_id          =>  l_header_id,
       p_line_id            =>  l_line_id,
       p_flow_status_code   =>  l_flow_status_code,
       x_return_status      =>  l_return_status);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN STS FLOW STATUS API '||L_RETURN_STATUS , 3 ) ;
      END IF;

      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

  END IF; -- if result_out = notified

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '216';
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROCESS_SHIPPING_ACTIVITY SUCCESSFULLY ' , 1 ) ;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SHIPPING_ACTIVITY : UNEXPECTED ERROR' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               'Process_Shipping_Activity');
     END IF;
     IF g_debug_call > 0 THEN
     G_DEBUG_MSG := G_DEBUG_MSG || 'E-33';
     END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SHIPPING_ACTIVITY : EXE ERROR' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-34';
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SHIPPING_ACTIVITY : OTHERS ERROR' , 1 ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               'Process_Shipping_Activity');
    END IF;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    ( p_count         => x_msg_count
     ,p_data          => x_msg_data);
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-35';
    END IF;

END Process_Shipping_Activity;


/*-------------------------------------------------------------
PROCEDURE Process_SMC_Shipping

Do we need to complete the activity for MODEL/CLASS ??
Yes for now. It will be done in Update Shipping procedure
on the change of explosion date because of explosion.
--------------------------------------------------------------*/
PROCEDURE Process_SMC_Shipping
( p_line_id                IN  NUMBER
 ,p_top_model_line_id      IN  NUMBER
,x_return_status OUT NOCOPY VARCHAR2)

IS
  l_line_tbl              OE_Order_Pub.Line_Tbl_Type;
  l_update_lines_tbl      OE_ORDER_PUB.Request_Tbl_Type;
  l_update_lines_index    NUMBER := 0;
  l_lines_not_at_ship     VARCHAR2(1) := FND_API.G_FALSE;
  l_activity_status_code  VARCHAR2(8);
  l_dummy                 VARCHAR2(52);
  l_line_index            NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PROCESS_SMC_SHIPPING' , 3 ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OE_Config_Util.Query_Options
  (p_top_model_line_id  => p_top_model_line_id,
   x_line_tbl           => l_line_tbl);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINES IN THE SMC_PTO '|| L_LINE_TBL.COUNT , 3 ) ;
  END IF;

  l_line_index := l_line_tbl.FIRST;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '13-2';
  END IF;

  WHILE l_line_index is NOT NULL
  LOOP

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCESSING LINE : '|| L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID || ' '|| L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE ||'/' ||L_LINE_TBL ( L_LINE_INDEX ) .SHIPPABLE_FLAG , 3 ) ;
     END IF;

    l_dummy := null;

    IF nvl(l_line_tbl(l_line_index).shippable_flag,'N') = 'Y' THEN

      IF l_line_tbl(l_line_index).shipping_interfaced_flag = 'Y' THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'THE LINE IS SHIPPING INTERFACED ' , 5 ) ;
        END IF;

        BEGIN

          SELECT 'Line is Released , staged or confirmed..'
          INTO   l_dummy
          FROM   WSH_DELIVERY_DETAILS
          WHERE  SOURCE_LINE_ID = l_line_tbl(l_line_index).line_id
          AND    RELEASED_STATUS <> 'N';


        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIPPING NEEDS UPDATE'||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
            END IF;
            l_dummy := 'U';

          WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ONE/MORE LINES RELEASED IN THIS BATCH..' , 5 ) ;
            END IF;

        END;

      ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'THE LINE IS NOT YET INTERFACED TO SHIPPING ' , 5 ) ;
        END IF;
        l_dummy := 'U';
      END IF; -- if not interfaced

      IF l_dummy = 'U' THEN
        l_update_lines_index := l_update_lines_index + 1;
        l_update_lines_tbl(l_update_lines_index).entity_id
                             := l_line_tbl(l_line_index).line_id;
        l_update_lines_tbl(l_update_lines_index).param1
                             := FND_API.G_FALSE;
        l_update_lines_tbl(l_update_lines_index).param2
                             := FND_API.G_FALSE;
        l_update_lines_tbl(l_update_lines_index).param4
                             := FND_API.G_TRUE;
      END IF;
    END IF; -- if shippable


    IF p_line_id <> l_line_tbl(l_line_index).line_id
    THEN
      BEGIN

        IF l_line_tbl(l_line_index).line_id
                      = nvl(l_line_tbl(l_line_index).ato_line_id,0) AND
           l_line_tbl(l_line_index).item_type_code IN ('MODEL','CLASS')
        THEN -- Change for bug 1820608

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AN ATO MODEL LINE '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 1 ) ;
          END IF;


          BEGIN
            SELECT 'X'
            INTO   l_dummy
            FROM   oe_order_lines
            WHERE  top_model_line_id = p_top_model_line_id
            AND    ato_line_id    = l_line_tbl(l_line_index).ato_line_id
            AND    item_type_code = 'CONFIG';
          EXCEPTION
            WHEN no_data_found THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ATO MODEL NOT PROCESSED IN A SMC' , 1 ) ;
              END IF;
              l_lines_not_at_ship := FND_API.G_TRUE;

            WHEN others THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ATO MODEL SQL '|| SQLERRM , 1 ) ;
              END IF;
          END;
        ELSE

          select activity_status
          into l_activity_status_code
          from wf_item_activity_statuses wias,
               wf_process_activities wpa
          where wias.item_type = 'OEOL'
          and wias.item_key = to_char(l_line_tbl(l_line_index).line_id)
          and wias.process_activity = wpa.instance_id
          and wpa.activity_name = 'SHIP_LINE'
          and wias.activity_status in ('NOTIFIED','COMPLETE');

        END IF; -- if ato.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE IS AT SHIPPING : ' || L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID || ' ' || L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE || '--' || L_ACTIVITY_STATUS_CODE , 3 ) ;
        END IF;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NOT AT SHIPPING: '|| TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) || ' '|| L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
          END IF;

          l_lines_not_at_ship := FND_API.G_TRUE;

        WHEN TOO_MANY_ROWS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS AT SHIPPING TOO MANY ROWS : ' || TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) || ' ' || L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE , 3 ) ;
          END IF;

        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'PROCESS SHIPPING ACTIVITY :'||SUBSTR ( SQLERRM , 1 , 200 ) , 3 ) ;
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF l_lines_not_at_ship = FND_API.G_TRUE THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ALL LINES NOT AT SHIP , RETURNING...' , 1 ) ;
        END IF;
        RETURN;
      END IF;

    END IF; -- if line_id <> p_line_id

    l_line_index := l_line_tbl.NEXT(l_line_index);

  END LOOP;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || '13-7';
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ALL THE SMC LINES ARE AT SHIPPING : ' , 3 ) ;
  END IF;
  -- Inform shipping that lines are ready to pick release

  IF l_update_lines_tbl.count > 0 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE SHIPPING '||L_UPDATE_LINES_TBL.COUNT , 3 ) ;
    END IF;

    Update_Shipping_From_OE
    ( p_update_lines_tbl  =>  l_update_lines_tbl,
      x_return_status     =>  x_return_status);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_SHIPPING_FROM_OE : '|| X_RETURN_STATUS , 3 ) ;
    END IF;

    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '13-8';
    END IF;

  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DONT CALL UPDATE_SHIPPING_FROM_OE' , 3 ) ;
    END IF;
  END IF; -- count > 0


  -- all non-shippable lines would be waiting, complete them.

  l_line_index := l_line_tbl.FIRST;

  WHILE l_line_index is NOT NULL
  LOOP
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PROCESSING LINE : '|| TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) || ' '|| L_LINE_TBL ( L_LINE_INDEX ) .ITEM_TYPE_CODE ||'/' ||L_LINE_TBL ( L_LINE_INDEX ) .SHIPPABLE_FLAG , 3 ) ;
      END IF;

    IF nvl(l_line_tbl(l_line_index).shippable_flag,'N') = 'N' AND
       OE_Shipping_Integration_PUB.Is_Activity_Shipping
       (1.0, l_line_tbl(l_line_index).line_id) = FND_API.G_TRUE AND
           p_line_id <> l_line_tbl(l_line_index).line_id THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COMP SHIP_LINE , NONSHIP: '||L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
      END IF;

      /* 1739754 */
      -- Log a delayed request for Complete Activity

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'COMP ACT DELAYED REQ '|| L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID , 3 ) ;
      END IF;


      wf_engine.CompleteActivityInternalName
      ('OEOL', to_char(l_line_tbl(l_line_index).line_id),
       'SHIP_LINE', 'NON_SHIPPABLE');

                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'WF_ENGINE.COMPLETEACTIVITYINTERNALNAME ' || TO_CHAR ( L_LINE_TBL ( L_LINE_INDEX ) .LINE_ID ) , 3 ) ;
                       END IF;

    END IF; -- if non shippable in a SMC.

    l_line_index := l_line_tbl.NEXT(l_line_index);

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LEAVING PROCESS_SMC_SHIPPING' , 3 ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SMC_SHIPPING : UNEXPECTED ERROR' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               'Process_SMC_Shipping');
     END IF;
     IF g_debug_call > 0 THEN
        G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-E-36';
     END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SMC_SHIPPING : EXE ERROR' , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-37';
    END IF;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS_SMC_SHIPPING : OTHERS ERROR' , 1 ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               'Process_SMC_Shipping');
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-38';
    END IF;

END Process_SMC_Shipping;

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
--------------------------------------------------------------*/
PROCEDURE Ship_Confirm_Split_Lines
( p_line_rec         IN  OE_Order_Pub.Line_Rec_Type
 ,p_shipment_status  IN  VARCHAR2)
IS
  l_line_set_rec     OE_ORDER_PUB.line_rec_type;
  l_return_status    VARCHAR2(1);
  l_count            NUMBER;

  CURSOR split_lines IS
  SELECT /* MOAC_SQL_CHANGE */ line_id, line_set_id, ordered_quantity, ordered_quantity2,
         order_quantity_uom, ordered_quantity_uom2, inventory_item_id
  FROM   oe_order_lines_all oe
  WHERE  line_id in
              (SELECT line_id
               FROM   oe_order_lines_all
               WHERE  line_set_id = p_line_rec.line_set_id
               AND    line_id <> p_line_rec.line_id)
  AND    open_flag = 'Y'
  AND    shipped_quantity is NULL
--  AND    line_id not in
--              (SELECT source_line_id
--               FROM   wsh_delivery_details
--               WHERE  released_status in ('Y', 'C')
  AND    line_id in
              (SELECT source_line_id
               FROM   wsh_delivery_details
               WHERE  source_header_id = oe.header_id);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add
    ('entering Ship_Confirm_Split_Lines '||p_line_rec.line_id ,3);
  END IF;

  IF p_line_rec.shipped_quantity2 is not NULL THEN
    l_line_set_rec.shipping_quantity2 := 0;
    l_line_set_rec.shipped_quantity2  := 0;
  END IF;

  IF g_debug_call > 0 THEN
  G_DEBUG_MSG := G_DEBUG_MSG || 'Shp-14-1';
   END IF;

  FOR line_rec in split_lines -- what about notify oc?
  LOOP

    SELECT count(*)
    INTO   l_count
    FROM   wsh_delivery_details
    WHERE  source_line_id = line_rec.line_id
    AND    released_status <> 'D';


    IF l_count > 0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ignoring this line, can no close '|| line_rec.line_id , 3 ) ;
      END IF;
    ELSE

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('now processing '|| line_rec.line_id, 3 ) ;
      END IF;

      l_line_set_rec.line_id             := line_rec.line_id;
      l_line_set_rec.line_set_id         := line_rec.line_set_id;
      l_line_set_rec.ordered_quantity    := line_rec.ordered_quantity;
      l_line_set_rec.ordered_quantity2   := line_rec.ordered_quantity2;
      l_line_set_rec.order_quantity_uom  := line_rec.order_quantity_uom;
      l_line_set_rec.ordered_quantity_uom2 := line_rec.ordered_quantity_uom2;
      l_line_set_rec.inventory_item_id   := line_rec.inventory_item_id;


      l_line_set_rec.shipping_quantity     := 0;
      l_line_set_rec.shipped_quantity      := 0;
      l_line_set_rec.shipping_quantity_uom := p_line_rec.shipping_quantity_uom;
      l_line_set_rec.shipping_quantity_uom2 := p_line_rec.shipping_quantity_uom2; -- INVCONV
      l_line_set_rec.actual_shipment_date  := p_line_rec.actual_shipment_date;

      Call_Notification_Framework
      ( p_line_rec       => l_line_set_rec
       ,p_caller         => 'Ship_Confirm_Split_Lines'
       ,x_return_status  => l_return_status);


      IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;


      UPDATE OE_ORDER_LINES
      SET shipping_quantity     = l_line_set_rec.shipping_quantity,
          shipped_quantity      = l_line_set_rec.shipped_quantity,
          shipping_quantity2    = l_line_set_rec.shipping_quantity2,
          shipped_quantity2     = l_line_set_rec.shipped_quantity2,
          shipping_quantity_uom = l_line_set_rec.shipping_quantity_uom,
          shipping_quantity_uom2 = l_line_set_rec.shipping_quantity_uom2, -- INVCONV
          actual_shipment_date  = l_line_set_rec.actual_shipment_date
          WHERE line_id         = l_line_set_rec.line_id;


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('line set id '|| line_rec.line_set_id , 3 ) ;
      END IF;

      Ship_Confirm_Standard_Line
      ( p_line_rec         => l_line_set_rec,
        p_shipment_status  => p_shipment_status,
        p_check_line_set   => 'N',
        x_return_status    => l_return_status );

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
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Ship_Confirm_Split_Lines '|| sqlerrm,3);
    END IF;
    RAISE;
END Ship_Confirm_Split_Lines;


/*-------------------------------------------------------------
PROCEDURE Call_Notification_Framework

Call this procedure to handle the Notification_Framework call
instead of scattering the code all over acorss different
procedures.

not using p_line_rec and p_old_line_rec, will support if
needed - it will take more local variable declarations and copy of
tables.
--------------------------------------------------------------*/
PROCEDURE Call_Notification_Framework
( p_line_rec       IN  OE_Order_Pub.Line_Rec_Type
 ,p_caller         IN  VARCHAR2
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  I                  NUMBER := 1;
  J                  NUMBER;
  l_line_tbl         OE_Order_Pub.Line_Tbl_Type;
  l_old_line_tbl     OE_Order_Pub.Line_Tbl_Type;


BEGIN

  Print_Time
  ('entering Call_Notification_Framework ' || p_caller);

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF p_caller = 'Ship_Confirm_Split_Lines' THEN
    l_line_tbl(I)     := p_line_rec;
    l_old_line_tbl(I) := l_line_tbl(I);

    l_old_line_tbl(I).shipping_quantity     := null;
    l_old_line_tbl(I).shipped_quantity      := null;
    l_old_line_tbl(I).shipping_quantity2    := null;
    l_old_line_tbl(I).shipped_quantity2     := null;
    l_old_line_tbl(I).shipping_quantity_uom := null;
    l_old_line_tbl(I).shipping_quantity_uom2 := null; -- INVCONV
    l_old_line_tbl(I).actual_shipment_date  := null;
  ELSE
    RETURN;
  END IF;


  IF ((OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508') OR
     (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y'))
  THEN

    I := l_line_tbl.FIRST;

   IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || '14-6';
   END IF;
    WHILE I is not NULL
    LOOP

      OE_ORDER_UTIL.Update_Global_Picture
      (p_Upd_New_Rec_If_Exists => False,
       p_header_id             => l_line_tbl(I).header_id,
       p_old_line_rec          => l_old_line_tbl(I),
       p_line_rec              => l_line_tbl(I),
       p_line_id               => l_line_tbl(I).line_id,
       x_index                 => J,
       x_return_status         => x_return_status);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        (J || ' UPDATE_GLOBAL ret sts: ' || x_RETURN_STATUS);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN;
      END IF;


      IF J IS NOT NULL THEN

        --update Global Picture directly
        OE_ORDER_UTIL.g_old_line_tbl(J)      := l_old_line_tbl(I);
        OE_ORDER_UTIL.g_line_tbl(J).line_id  := l_line_tbl(I).line_id;
        OE_ORDER_UTIL.g_line_tbl(J).header_id:= l_line_tbl(I).header_id;

        OE_ORDER_UTIL.g_line_tbl(J).last_update_date := SYSDATE;
        OE_ORDER_UTIL.g_line_tbl(J).last_updated_by  := FND_GLOBAL.USER_ID;
        OE_ORDER_UTIL.g_line_tbl(J).last_update_login:= FND_GLOBAL.LOGIN_ID;

        OE_ORDER_UTIL.g_line_tbl(J)
                  := OE_ORDER_UTIL.g_old_line_tbl(J);
        OE_ORDER_UTIL.g_line_tbl(J).flow_status_code
                  := l_line_tbl(I).flow_status_code;
        OE_ORDER_UTIL.g_line_tbl(J).shipped_quantity
                  := l_line_tbl(I).shipped_quantity;
        OE_ORDER_UTIL.g_line_tbl(J).shipped_quantity2 -- INVCONV
                  := l_line_tbl(I).shipped_quantity2;


        IF l_debug_level  > 0 THEN
          oe_debug_pub.add
          ('AFTER UPDATE GLOBAL FLOW_STATUS_CODE IS: '
           || OE_ORDER_UTIL.G_LINE_TBL( J ).FLOW_STATUS_CODE ,1);
        END IF;

      END IF; -- if index is not null

      I := l_line_tbl.NEXT(I);
    END LOOP;

  ELSE   --pre-pack H

    IF OE_GLOBALS.G_ASO_INSTALLED = 'Y' THEN

      OE_Order_PVT.Process_Requests_And_Notify
      (  p_process_requests    => FALSE
       , p_notify              => TRUE
       , p_process_ack         => FALSE
       , x_return_status       => x_return_status
       , p_line_tbl            => l_line_tbl
       , p_old_line_tbl        => l_old_line_tbl);

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RETRURNED FROM PRN: '||x_RETURN_STATUS , 3 ) ;
       END IF;
       IF g_debug_call > 0 THEN
       G_DEBUG_MSG := G_DEBUG_MSG || '14-7';
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RETURN;
       END IF;

    END IF;  -- aso_installed
  END IF;   -- code_release_level

  Print_Time('leaving Call_Notification_Framework');

EXCEPTION
  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('error in Call_Notification_Framework' || sqlerrm, 1);
    END IF;
    RAISE;
END Call_Notification_Framework;


/*-----------------------------------------------------------------
PROCEDURE OM_To_WSH_Interface

OM-WSH_HVOP
------------------------------------------------------------------*/
PROCEDURE OM_To_WSH_Interface
( p_line_rec      IN  OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
 ,p_header_rec    IN  OE_BULK_ORDER_PVT.HEADER_REC_TYPE
 ,x_return_status OUT NOCOPY VARCHAR2)
IS
  l_action_rec             WSH_BULK_TYPES_GRP.action_parameters_rectype;
  l_out_rec                WSH_BULK_TYPES_GRP.Bulk_process_out_rec_type;
  l_msg_count              NUMBER;
  l_return_status          VARCHAR2(1);
  l_msg_data               VARCHAR2(2000);
  l_index                  NUMBER;
  l_error_msg             VARCHAR2(240);
  l_msg_index             NUMBER;
  l_firm_flag             VARCHAR2(1) := Null;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  l_action_rec.caller        := 'OM';
  l_action_rec.action_code   := 'CREATE';
  -- commented for MOAC  FND_PROFILE.Get('ORG_ID', l_action_rec.org_id);
  l_action_rec.org_id := MO_GLOBAL.get_current_org_id();

  WSH_bulk_process_grp.Create_update_delivery_details
  ( p_api_version_number  => 1.0
   ,p_init_msg_list       => FND_API.G_TRUE
   ,p_commit              => FND_API.G_FALSE
   ,p_action_prms         => l_action_rec
   ,p_line_rec            => p_line_rec
   ,x_out_rec             => l_out_rec
   ,x_return_status       => l_return_status
   ,x_msg_count           => l_msg_count
   ,x_msg_data            => l_msg_data);

  oe_debug_pub.add
  ('return status from WSH '|| l_return_status || '-' || l_msg_count, 5);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS OR
     l_return_status = 'W' THEN

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND
       OE_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SHIPPING_INTERFACED'
    THEN
       l_firm_flag := 'Y';
    END IF;

    FORALL I in p_line_rec.line_id.FIRST..p_line_rec.line_id.LAST
      UPDATE oe_order_lines
      SET    shipping_interfaced_flag = 'Y',
             flow_status_code = 'AWAITING_SHIPPING',
             firm_demand_flag = NVL(l_firm_flag,firm_demand_flag)
      WHERE  line_id = p_line_rec.line_id(I)
      AND    p_line_rec.shipping_interfaced_flag(I) = 'Y';

    oe_debug_pub.add('afer updating shipping interfaced flag', 5);
    G_BULK_WSH_INTERFACE_CALLED := TRUE; -- bug 4070931 starts

    FOR I in p_line_rec.line_id.FIRST..p_line_rec.line_id.LAST
    LOOP
      IF p_line_rec.shipping_interfaced_flag(I) is NULL AND
         p_line_rec.shippable_flag(I) = 'Y' THEN

        OE_BULK_WF_UTIL.G_LINE_INDEX := I;

        BEGIN
          WF_ENGINE.HandleError
          (itemtype => 'OEOL',
           itemkey  => to_char(p_line_rec.line_id(I)),
           activity => 'SHIP_LINE',
           command  => 'RETRY',
           result   => NULL);

        EXCEPTION
          WHEN OTHERS THEN
            oe_debug_pub.add('Exception caught after Wf_engine.Handle_Error',5);
        END; -- Erroring out the WF table

        OE_BULK_WF_UTIL.G_LINE_INDEX := NULL;
      END IF; -- lines not shipping_interfaced
      p_line_rec.shipping_eligible_flag(I) := null;
    END LOOP;

    G_BULK_WSH_INTERFACE_CALLED := FALSE; -- bug 4070931ends
  END IF;


  IF l_msg_count > 0 THEN

    l_index := P_LINE_REC.error_message_count.FIRST;

    WHILE l_index is not NULL
    LOOP
      l_msg_count := 1;

      WHILE P_LINE_REC.error_message_count(l_index) > 0
      LOOP
        IF l_msg_count = 1 THEN

          l_msg_count := null;

          -- Set the message context for errors.
          oe_bulk_msg_pub.set_msg_context
          ( p_entity_code               => 'LINE'
           ,p_entity_id                 => P_LINE_REC.line_id(l_index)
           ,p_header_id                 => P_LINE_REC.header_id(l_index)
           ,p_line_id                   => P_LINE_REC.line_id(l_index)
           ,p_orig_sys_document_ref
                     => P_LINE_REC.orig_sys_document_ref(l_index)
           ,p_orig_sys_document_line_ref
                     => P_LINE_REC.orig_sys_line_ref(l_index)
           ,p_source_document_id        => NULL
           ,p_source_document_line_id   => NULL
           ,p_order_source_id
                     => P_LINE_REC.order_source_id(l_index)
           ,p_source_document_type_id   => NULL);

        END IF;

        Fnd_Msg_Pub.GET
        (p_encoded       => FND_API.G_FALSE,
         p_data          => l_error_msg,
         p_msg_index_out => l_msg_index);

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ERROR : '||L_ERROR_MSG , 2 ) ;
         END IF;

         fnd_message.set_name('ONT','OE_SHP_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE',l_error_msg);
         --oe_msg_pub.add;

        OE_BULK_MSG_PUB.ADD;
        oe_debug_pub.add('here again 2 ', 5);

        P_LINE_REC.error_message_count(l_index)
                := p_line_rec.error_message_count(l_index) - 1;
      END LOOP; -- message count> 0

      l_index := p_line_rec.error_message_count.NEXT(l_index);
    END LOOP; -- loop over all lines

  END IF; -- if there were errors

  IF l_return_status = 'W' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := l_return_status;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('return status from vshpb'|| x_return_status, 5);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OM_TO_WSH_INTERFACE : UNEXPECTED ERROR',1);
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                              'OM_To_WSH_Interface');
    END IF;
    IF g_debug_call > 0 THEN
    G_DEBUG_MSG := G_DEBUG_MSG || 'E-39';
    END IF;

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OM_TO_WSH_INTERFACE : EXE ERROR',1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OM_TO_WSH_INTERFACE, OTHERS '|| sqlerrm ,1);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR MESSAGE : '||SUBSTR(SQLERRM ,1,100),1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                               'OM_To_WSH_Interface');
    END IF;

END OM_To_WSH_Interface;

/*------------------------------------------------------------------------
PROCEDURE Print_Time

-------------------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time        VARCHAR2(100);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  P_MSG || ': '|| L_TIME , 1 ) ;
  END IF;
END Print_Time;
/*--------------------------------------------------------------------------------
PROCEDURE Ship_Complete
Added for bug 6021460. This API will be used for Ship Complete Validation template.
----------------------------------------------------------------------------------*/
PROCEDURE ship_complete
(
  p_application_id    IN  NUMBER
, p_entity_short_name   IN  VARCHAR2
, p_validation_entity_short_name  IN  VARCHAR2
, p_validation_tmplt_short_name IN  VARCHAR2
, p_record_set_short_name     IN  VARCHAR2
, p_scope             IN  VARCHAR2
, x_result_out OUT NOCOPY NUMBER

)
IS
  l_ship_confirm_status   VARCHAR2(30);
  l_count_reserve         NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  select  activity_result_code
  into    l_ship_confirm_status
  from    wf_process_activities p, wf_item_activity_statuses s
  where   p.instance_id	        = s.process_activity
  and     item_type		= 'OEOL'
  and     item_key 		= to_char(OE_LINE_SECURITY.g_record.line_id)
  and     p.activity_name	= 'SHIP_LINE'
  and     s.activity_status     = 'COMPLETE';

  IF  l_ship_confirm_status = 'UNRESERVE' THEN
    x_result_out := 0;
  ELSE
    x_result_out := 1;
  END IF;


EXCEPTION
  WHEN  NO_DATA_FOUND THEN
      x_result_out := 0;
  WHEN  TOO_MANY_ROWS THEN

     select count(1)
     into  l_count_reserve
     from  wf_process_activities p, wf_item_activity_statuses s
     where p.instance_id	= s.process_activity
     and   item_type		= 'OEOL'
     and   item_key 		= to_char(OE_LINE_SECURITY.g_record.line_id)
     and   p.activity_name	= 'SHIP_LINE'
     and   s.activity_status    = 'COMPLETE'
     and   (activity_result_code IS NULL OR activity_result_code <> 'UNRESERVE');

     if l_count_reserve = 0 then

        x_result_out := 0;

     else

        x_result_out := 1;

     end if;

  WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ship_complete'
            );
        END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 100 ) , 1 ) ;
    END IF;
                IF g_debug_call > 0 THEN
                G_DEBUG_MSG := G_DEBUG_MSG || 'E1';
                END IF;
    RAISE;
END ship_complete;


END OE_Shipping_Integration_PVT;

/
