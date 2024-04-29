--------------------------------------------------------
--  DDL for Package Body OE_ORDER_BOOK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_BOOK_UTIL" AS
/* $Header: OEXUBOKB.pls 120.9.12010000.3 2010/10/06 11:10:22 srsunkar ship $ */

--  Global constant holding the package name
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'OE_ORDER_BOOK_UTIL';


/* LOCAL PROCEDURES */

-- LOCAL function: BookingIsDeferred
-- Called from Complete_Book_Eligible
-- Returns TRUE if booking has been deferred for this itemkey
-- and also populates a message to inform the user that booking
-- has been deferred.
---------------------------------------------------------------
FUNCTION BookingIsDeferred
		(p_itemkey		IN VARCHAR2
		)
RETURN BOOLEAN
IS
l_book_deferred		VARCHAR2(1);
CURSOR book_deferred IS
	SELECT 'Y'
	FROM WF_ITEM_ACTIVITY_STATUSES WIAS
		, WF_PROCESS_ACTIVITIES WPA
	WHERE WIAS.item_type = 'OEOH'
	  AND WIAS.item_key = p_itemkey
	  AND WIAS.activity_status = 'DEFERRED'
	  AND WPA.activity_name = 'BOOK_DEFER'
	  AND WPA.instance_id = WIAS.process_activity;
	  --
	  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	  --
BEGIN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CHECK IF BOOKING IS DEFERRED' ) ;
			END IF;

		OPEN book_deferred;
		FETCH book_deferred INTO l_book_deferred;

		IF (book_deferred%FOUND) THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'BOOKING IS DEFERRED' ) ;
			END IF;
		  FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOK_DEFERRED');
		  OE_MSG_PUB.ADD;
	       CLOSE book_deferred;
		  RETURN TRUE;
	     END IF;

	     CLOSE book_deferred;
		RETURN FALSE;

EXCEPTION
	WHEN OTHERS THEN
		if (book_deferred%isopen) then
			close book_deferred;
		end if;
		RAISE;

END BookingIsDeferred;

---------------------------------------------------------------
PROCEDURE Pricing_Book_Event
          (p_x_line_tbl       IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
          ,p_header_id        IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

          )
IS
l_price_control_rec      QP_PREQ_GRP.control_record_type;
l_request_rec            oe_order_pub.request_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
          -- Oe_Debug_pub.Add('Before Book_Pricing_Event');
          l_Price_Control_Rec.pricing_event := 'BOOK';
          l_Price_Control_Rec.calculate_flag :=  QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
          l_Price_Control_Rec.Simulation_Flag := 'N';

          oe_order_adj_pvt.Price_line(
                         X_Return_Status     => x_Return_Status
                         ,p_Header_id        => p_header_id
                         ,p_Request_Type_code=> 'ONT'
                         ,p_Control_rec      => l_Price_Control_Rec
                         ,p_write_to_db      => TRUE
                         ,p_request_rec      => l_request_rec
                         ,x_line_Tbl         => p_x_Line_Tbl
                         );
          -- Oe_Debug_pub.Add('After Book_Pricing_Event');

END Pricing_Book_Event;


---------------------------------------------------------------
PROCEDURE Update_Booked_Flag
		(p_header_id	 	IN NUMBER
,x_validate_cfg OUT NOCOPY BOOLEAN

,x_freeze_inc_items OUT NOCOPY BOOLEAN

,x_return_status OUT NOCOPY VARCHAR2

		)
IS
l_index				NUMBER := 1;
l_new_index			NUMBER := 1;
l_loop_index			NUMBER := 1;  -- jolin
l_notify_index			NUMBER;  -- jolin
l_line_id			NUMBER;
l_header_rec			OE_ORDER_PUB.Header_Rec_Type;
l_old_header_rec		OE_ORDER_PUB.Header_Rec_Type;
l_line_tbl			OE_ORDER_PUB.Line_TBL_Type;
l_old_line_tbl			OE_ORDER_PUB.Line_TBL_Type;
l_msg_count				NUMBER;
l_active_phase_count	NUMBER;
l_msg_data				VARCHAR2(2000);
l_return_status			VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_tax_calculation_event_code varchar2(30) := NULL;
l_notify BOOLEAN := FALSE;
l_in_loop_index			NUMBER := 1;
l_line_adj_tbl	        OE_ORDER_PUB.LINE_ADJ_TBL_Type;
l_populate_adj BOOLEAN := FALSE;
l_global_index NUMBER;
l_line_adj_index NUMBER;

CURSOR Query_Lines IS
         SELECT line_id
            , booked_flag
            , sold_to_org_id
            , invoice_to_org_id
            , ship_to_org_id
            , tax_exempt_flag
            , inventory_item_id
            , order_quantity_uom
            , ordered_quantity
            , line_category_code
            , item_type_code
            , price_list_id
            , unit_list_price
            , unit_selling_price
            , payment_term_id
            , ship_from_org_id
            , request_date
            , line_type_id
            , tax_date
            , tax_code
            , service_duration
            , reference_line_id
            , cancelled_flag
            , orig_sys_document_ref
            , orig_sys_line_ref
            , source_document_id
            , source_document_line_id
            , service_coterminate_flag
            , service_reference_type_code
            , service_start_date
            , service_end_date
            , service_period
            , header_id /* renga */
            , org_id
            , return_context
            , reference_customer_trx_line_id /* end renga */
            , order_firmed_date   /* Key Transaction Dates */
      FROM OE_ORDER_LINES
      WHERE HEADER_ID = p_header_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
        x_validate_cfg := FALSE;
        x_freeze_inc_items := FALSE;

	-- NOTE: Process order is called twice, once to update the booked flag
	-- on the order header and the second time to update the booked flag
	-- on all lines on the order. This cannot be done in one call as the
	-- process order does not process lines(or any line level validation)
	-- if the header validation fails. In order to give user complete
	-- feedback i.e. validation errors for lines also if any, process order
	-- is called for lines separately even if header update returns with
	-- a status of ERROR.


	-- Set up the header record

     OE_Header_Util.Query_Row
			(p_header_id	=> p_header_id
			,x_header_rec	=> l_old_header_rec
			);
	l_header_rec				:= l_old_header_rec;
	l_header_rec.booked_flag   		:= 'Y';
	l_header_rec.booked_date   		:= sysdate;
	l_header_rec.flow_status_code 		:= 'BOOKED';
	l_header_rec.last_updated_by		:= FND_GLOBAL.USER_ID;
	l_header_rec.last_update_login		:= FND_GLOBAL.LOGIN_ID;
	l_header_rec.last_update_date		:= SYSDATE;
	l_header_rec.lock_control		:= l_header_rec.lock_control + 1;

        -- bug 1406890
        -- renga: change for tax calculation event enhancement
        BEGIN

          IF l_header_rec.order_type_id is not null THEN
            SELECT  TAX_CALCULATION_EVENT_CODE
            into l_tax_calculation_event_code
            from oe_transaction_types_all
            where transaction_type_id = l_header_rec.order_type_id;
          END IF;

        EXCEPTION
           when no_data_found then
                 l_tax_calculation_event_code := NULL;
           when others then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'REN: FAILED WHILE TRYING TO QUERY UP TAX_CALCUALTION_EVENT FOR ORDER_TYPE_ID IN UPDATE_BOOKED_FLAG' ) ;
             END IF;
             RAISE;
        END;
        -- renga: end of change for tax calculation event enhancement


     -- Header booking validation

     OE_MSG_PUB.set_msg_context(
      p_entity_code           => 'HEADER'
     ,p_entity_id                  => l_header_rec.header_id
     ,p_header_id                  => l_header_rec.header_id
     ,p_line_id                    => null
     ,p_order_source_id            => l_header_rec.order_source_id
     ,p_orig_sys_document_ref => l_header_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => null
     ,p_change_sequence            => l_header_rec.change_sequence
     ,p_source_document_type_id    => l_header_rec.source_document_type_id
     ,p_source_document_id         => l_header_rec.source_document_id
     ,p_source_document_line_id    => null );

     OE_Validate_Header.Check_Book_Reqd_Attributes
          (p_header_rec            => l_header_rec
          ,x_return_status         => l_return_status
          );

     OE_MSG_PUB.reset_msg_context('HEADER');

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	-- if unexpected error, then do NOT validate lines.
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RETURN;
	END IF;

    -- Check whether we need to call the Pricing at BOOKING
    SELECT count(*)
    INTO l_active_phase_count
    FROM QP_EVENT_PHASES
    WHERE pricing_event_code = 'BOOK'
    AND trunc(sysdate) between trunc(nvl(start_date_active, sysdate)) and
                  trunc(nvl(end_date_active, sysdate));

    -- Check if the ASO and EC are installed products
    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    IF OE_GLOBALS.G_EC_INSTALLED IS NULL THEN
        OE_GLOBALS.G_EC_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(175);
    END IF;

    -- We need to call the Query_Rows only if Pricing is called and ASO/EC are
    -- Installed products.

    IF ( (NVL(l_active_phase_count,0) > 0) OR
         (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
         (OE_GLOBALS.G_EC_INSTALLED = 'Y' ) OR
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  )
    THEN
     -- Set up the lines table of records

        OE_Line_Util.Query_Rows
        (p_header_id		=> p_header_id
		  ,x_line_tbl	 	=> l_old_line_tbl
         );
    ELSE
        l_index := 1;

        OPEN Query_Lines;
        LOOP

            FETCH Query_Lines INTO
              l_old_line_tbl(l_index).line_id
            , l_old_line_tbl(l_index).booked_flag
            , l_old_line_tbl(l_index).sold_to_org_id
            , l_old_line_tbl(l_index).invoice_to_org_id
            , l_old_line_tbl(l_index).ship_to_org_id
            , l_old_line_tbl(l_index).tax_exempt_flag
            , l_old_line_tbl(l_index).inventory_item_id
            , l_old_line_tbl(l_index).order_quantity_uom
            , l_old_line_tbl(l_index).ordered_quantity
            , l_old_line_tbl(l_index).line_category_code
            , l_old_line_tbl(l_index).item_type_code
            , l_old_line_tbl(l_index).price_list_id
            , l_old_line_tbl(l_index).unit_list_price
            , l_old_line_tbl(l_index).unit_selling_price
            , l_old_line_tbl(l_index).payment_term_id
            , l_old_line_tbl(l_index).ship_from_org_id
            , l_old_line_tbl(l_index).request_date
            , l_old_line_tbl(l_index).line_type_id
            , l_old_line_tbl(l_index).tax_date
            , l_old_line_tbl(l_index).tax_code
            , l_old_line_tbl(l_index).service_duration
            , l_old_line_tbl(l_index).reference_line_id
            , l_old_line_tbl(l_index).cancelled_flag
            , l_old_line_tbl(l_index).orig_sys_document_ref
            , l_old_line_tbl(l_index).orig_sys_line_ref
            , l_old_line_tbl(l_index).source_document_id
            , l_old_line_tbl(l_index).source_document_line_id
            , l_old_line_tbl(l_index).service_coterminate_flag
            , l_old_line_tbl(l_index).service_reference_type_code
            , l_old_line_tbl(l_index).service_start_date
            , l_old_line_tbl(l_index).service_end_date
            , l_old_line_tbl(l_index).service_period
            , l_old_line_tbl(l_index).header_id /* renga */
            , l_old_line_tbl(l_index).org_id
            , l_old_line_tbl(l_index).return_context
            , l_old_line_tbl(l_index).reference_customer_trx_line_id
                                           /* end renga */
	    , l_old_line_tbl(l_index).order_firmed_date;   /*key transaction dates */

            EXIT WHEN (Query_Lines%NOTFOUND);

            l_index := l_index + 1;

        END LOOP;

        CLOSE Query_Lines;

     END IF;


     -- (1) Lines Booking Validation
     l_line_tbl := l_old_line_tbl;
     l_index := l_line_tbl.FIRST;

     WHILE l_index IS NOT NULL LOOP

	  -- for non-cancelled lines, do the booking validation and set
	  -- the booked_flag and flow_status on the new line records
	  IF nvl(l_line_tbl(l_index).cancelled_flag,'N') = 'N' THEN

                IF l_line_tbl(l_index).item_type_code = 'STANDARD' THEN
                   NULL;
                ELSIF l_line_tbl(l_index).item_type_code = 'MODEL' THEN
                   x_validate_cfg := TRUE;
                   x_freeze_inc_items := TRUE;
                ELSIF l_line_tbl(l_index).item_type_code in ('CLASS','KIT') THEN
                   x_freeze_inc_items := TRUE;
                END IF;

                l_return_status 			:= FND_API.G_RET_STS_SUCCESS;
                l_line_tbl(l_index).operation   := OE_GLOBALS.G_OPR_UPDATE;
		l_line_tbl(l_index).booked_flag	:= 'Y';
		l_line_tbl(l_index).flow_status_code	:= 'BOOKED';
		l_line_tbl(l_index).last_updated_by	:= FND_GLOBAL.USER_ID;
		l_line_tbl(l_index).last_update_login	:= FND_GLOBAL.LOGIN_ID;
		l_line_tbl(l_index).last_update_date	:= SYSDATE;
		l_line_tbl(l_index).lock_control	     := l_line_tbl(l_index).lock_control + 1;

          OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_tbl(l_index).line_id
          ,p_header_id                  => p_header_id
          ,p_line_id                    => l_line_tbl(l_index).line_id
          ,p_order_source_id            => l_line_tbl(l_index).order_source_id
          ,p_orig_sys_document_ref 	=> l_line_tbl(l_index).orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_tbl(l_index).orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_tbl(l_index).orig_sys_shipment_ref
          ,p_change_sequence            => l_line_tbl(l_index).change_sequence
          ,p_source_document_type_id    => l_line_tbl(l_index).source_document_type_id
          ,p_source_document_id         => l_line_tbl(l_index).source_document_id
          ,p_source_document_line_id    => l_line_tbl(l_index).source_document_line_id );

          OE_Validate_Line.Check_Book_Reqd_Attributes
               (p_line_rec    => l_line_tbl(l_index)
               ,p_old_line_rec => l_old_line_tbl(l_index)
               ,x_return_status => l_return_status
               );

          OE_MSG_PUB.reset_msg_context('LINE');

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               RETURN;
          END IF;

          -- bug 1406890
          -- Renga - log a delayed request for calculating tax for
          -- each of the order lines

          IF l_tax_calculation_event_code = 'BOOKING' THEN

           IF l_line_tbl(l_index).item_type_code not in ('INCLUDED', 'CONFIG') THEN

            OE_delayed_requests_Pvt.log_request(
		p_entity_code 		 => OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id   		 => l_line_tbl(l_index).line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		p_requesting_entity_id   => l_line_tbl(l_index).line_id,
                p_request_type           => OE_GLOBALS.g_tax_line,
                x_return_status     	 => l_return_status);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  RETURN;
            END IF;

           END IF; -- if item_type_code not in INCLUDED or CONFIG

          END IF; -- if tax_calculation_event is booking


          -- end of bug 1406890


	  -- delete the cancelled lines from the lines table, these do
	  -- not need to be sent to notify_oc
	  ELSE
		l_old_line_tbl.DELETE(l_index);
		l_line_tbl.DELETE(l_index);
	  END IF;

	  l_index := l_line_tbl.NEXT(l_index);

     END LOOP;

     -- Return error if there were validation errors for the header/line
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


     --  Update the booked_flag and flow_status on the tables
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

          UPDATE oe_order_headers_all
          SET booked_flag = 'Y'
			, booked_date = sysdate
               , flow_status_code = 'BOOKED'
			, last_updated_by = FND_GLOBAL.USER_ID
			, last_update_login = FND_GLOBAL.LOGIN_ID
			, last_update_date = SYSDATE
 			, lock_control = lock_control + 1
          WHERE header_id = p_header_id;

          -- aksingh performance
          -- As the update is on headers table, it is time to update
          -- cache also!
          OE_Order_Cache.Set_Order_Header(l_header_rec);

          -- Clear cached results for constraints as order being booked
          -- may change results of some validation packages
          OE_PC_Constraints_Admin_PVT.Clear_Cached_Results;

          UPDATE oe_order_lines_all
          SET booked_flag = 'Y'
               , flow_status_code = 'BOOKED'
			, last_updated_by = FND_GLOBAL.USER_ID
			, last_update_login = FND_GLOBAL.LOGIN_ID
			, last_update_date = SYSDATE
 			, lock_control = lock_control + 1
          WHERE header_id = p_header_id
            AND nvl(cancelled_flag,'N') <> 'Y'; -- nvl added for bug 4486781

     END IF;

     --OIP SUN ER changes
         IF (NVL(FND_PROFILE.VALUE('ONT_RAISE_STATUS_CHANGE_BUSINESS_EVENT'),'N') ='Y') THEN
	            OE_delayed_requests_Pvt.log_request
	 				(p_entity_code			=> OE_GLOBALS.G_ENTITY_HEADER,
	 				p_entity_id			=> l_header_rec.header_id,
	 				p_requesting_entity_code	=> OE_GLOBALS.G_ENTITY_HEADER,
	 				p_requesting_entity_id		=> l_header_rec.header_id,
	 				p_request_type      		=> 'OE_ORDER_BOOKED', --OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP,
	 				x_return_status			=> l_return_status);

	            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	                   x_return_status := FND_API.G_RET_STS_ERROR;
	             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	                   RETURN;
	             END IF;
      END IF;
     --OIP SUN ER changes End

     --  Evaluate the BOOK event for pricing
     -- Call Pricing only if there are active phases in BOOK event.
/*
     IF l_active_phase_count > 0 THEN
	    Pricing_Book_Event(p_x_line_tbl => l_line_tbl
                    , p_header_id       => p_header_id
                    , x_return_status   => l_return_status
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;
*/

     -- (4) API to call notify_oc and ack with l_header_rec and l_old_header_rec
     -- and l_line_tbl and l_old_line_tbl
    -- bug 1406890
    -- renga - change for tax calculation event enhancement

    l_notify := FALSE;

    IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
         (OE_GLOBALS.G_EC_INSTALLED = 'Y' ) OR
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  )
    THEN
      l_notify := TRUE;

    /* jolin start */
    -- AND we need to update the global picture before calling process_requests_and_notify
    -- if we are using the new notification method

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    -- Need to call Update_Global_Picture to update globals on direct changes
    -- made in the two update stmts to the headers and lines tables.
    -- First make call for the header, then loop through all the lines

-- bug 2821129
    oe_debug_pub.add('in OEXUBOKB header will do query');
     oe_debug_pub.add('p_header_id is '|| p_header_id);
    oe_debug_pub.add('l_header_rec.header_id is '|| l_header_rec.header_id);
    OE_HEADER_ADJ_UTIL.Query_Rows
        (p_header_id		=> p_header_id
	 ,x_Header_adj_Tbl	=> OE_ORDER_UTIL.g_header_adj_tbl);


-- loop to populate the operation in the global table
    l_in_loop_index := OE_ORDER_UTIL.g_header_adj_tbl.FIRST;

    while l_in_loop_index is not null loop
      OE_ORDER_UTIL.g_header_adj_tbl(l_in_loop_index).operation := OE_GLOBALS.G_OPR_CREATE;
    l_in_loop_index := OE_ORDER_UTIL.g_header_adj_tbl.NEXT(l_in_loop_index);
    END LOOP;

    oe_debug_pub.add('in OEXUBOKB header adj tbl count is '|| OE_ORDER_UTIL.g_header_adj_tbl.count);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE ENTERING UPDATE_GLOBAL_PICTURE IN BOOKING' ) ;
   END IF;
    -- call notification framework to get header index position
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE UPDATE , HEADER VALUE' || OE_ORDER_UTIL.G_HEADER_REC.HEADER_ID ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE UPDATE , OLD HEADER VALUE' || OE_ORDER_UTIL.G_OLD_HEADER_REC.HEADER_ID ) ;
   END IF;
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_header_rec		=> l_header_rec
	, p_old_header_rec	=> l_old_header_rec
        , p_header_id 		=> l_header_rec.header_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FOR HDR IS: ' || L_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HDR INDEX IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   IF l_notify_index is not null then
     -- modify Global Picture
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'JPN: OLD GLOBAL HDR REC BOOKED_FLAG IS:' || OE_ORDER_UTIL.G_OLD_HEADER_REC.BOOKED_FLAG , 1 ) ;
                         END IF;
     OE_ORDER_UTIL.g_old_header_rec := l_old_header_rec;
     OE_ORDER_UTIL.g_header_rec := OE_ORDER_UTIL.g_old_header_rec;
     OE_ORDER_UTIL.g_old_header_rec.booked_flag := 'N';
     OE_ORDER_UTIL.g_old_header_rec.booked_date := NULL;
     OE_ORDER_UTIL.g_header_rec.booked_flag := l_header_rec.booked_flag;
    OE_ORDER_UTIL.g_header_rec.booked_date:=	l_header_rec.booked_date;
    OE_ORDER_UTIL.g_header_rec.flow_status_code:=l_header_rec.flow_status_code;
    OE_ORDER_UTIL.g_header_rec.last_updated_by:=l_header_rec.last_updated_by;
    OE_ORDER_UTIL.g_header_rec.last_update_login:=l_header_rec.last_update_login;
    OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
    OE_ORDER_UTIL.g_header_rec.lock_control:=	l_header_rec.lock_control;
    OE_ORDER_UTIL.g_header_rec.operation:=	l_header_rec.operation;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'JYOTHI:GLOBAL HDR REC BOOKED_FLAG IS: ' || OE_ORDER_UTIL.G_HEADER_REC.BOOKED_FLAG , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL HDR BOOKED_DATE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.BOOKED_DATE , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL HDR FLOW_STATUS_CODE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE , 1 ) ;
			END IF;

   END IF ; /* global entity index null check */

   -- update lines global picture
   --  loop over l_line_tbl using loop_index

     l_loop_index := l_line_tbl.FIRST;

     <<outer>>

    WHILE l_loop_index IS NOT NULL LOOP
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'JFC: IN BOOKING LINES , L_LOOP_INDEX= '||L_LOOP_INDEX , 1 ) ;
    END IF;
      -- call notification framework to get this line's index position
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_line_rec		=> l_line_tbl(l_loop_index)
	, p_line_id 		=> l_line_tbl(l_loop_index).line_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS IN OE_ORDER_BOOK_UTIL FOR LINE_ID '||L_LINE_TBL ( L_LOOP_INDEX ) .LINE_ID ||' IS: ' || L_RETURN_STATUS , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL INDEX IN OE_ORDER_BOOK_UTIL FOR LINE_ID '||L_LINE_TBL ( L_LOOP_INDEX ) .LINE_ID ||' IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   IF l_notify_index is not null then
     -- modify Global Picture
    OE_ORDER_UTIL.g_old_line_tbl(l_notify_index):= l_old_line_tbl(l_loop_index);
    OE_ORDER_UTIL.g_line_tbl(l_notify_index):= OE_ORDER_UTIL.g_old_line_tbl(l_notify_index);
    OE_ORDER_UTIL.g_old_line_tbl(l_notify_index).booked_flag:='N';

    OE_ORDER_UTIL.g_line_tbl(l_notify_index).line_id:=	l_line_tbl(l_loop_index).line_id;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).booked_flag:=	l_line_tbl(l_loop_index).booked_flag;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).flow_status_code:=l_line_tbl(l_loop_index).flow_status_code;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_updated_by:=	l_line_tbl(l_loop_index).last_updated_by;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_login:=l_line_tbl(l_loop_index).last_update_login;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_date:=l_line_tbl(l_loop_index).last_update_date;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).lock_control:=	l_line_tbl(l_loop_index).lock_control;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).operation:=l_line_tbl(l_loop_index).operation;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN BOOKING , AFTER UPDATE LINE GLOBAL PICTURE' ) ;
    END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL LINE BOOKED_FLAG IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .BOOKED_FLAG , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL LINE FLOW_STATUS_CODE IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .FLOW_STATUS_CODE , 1 ) ;
			END IF;
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'GLOBAL OLD LINE BOOKED_FLAG IS: ' || OE_ORDER_UTIL.G_OLD_LINE_TBL ( L_NOTIFY_INDEX ) .BOOKED_FLAG , 1 ) ;
                       END IF;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'GLOBAL LINE OPERATION IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .OPERATION , 1 ) ;
                    END IF;
   END IF ; /* global entity index null check */

-- bug 2821129

       oe_debug_pub.add('p_header_id is '|| p_header_id);
       oe_debug_pub.add('line_id is '|| l_line_tbl(l_loop_index).line_id);

      oe_debug_pub.add('in OEXUBOKB start g line adj tbl count is '|| OE_ORDER_UTIL.g_line_adj_tbl.count);

       OE_LINE_ADJ_UTIL.Query_Rows
         (
	  p_line_id 		=> l_line_tbl(l_loop_index).line_id
	 ,p_header_id		=> p_header_id
	 ,x_Line_Adj_Tbl	=> l_line_adj_tbl);


      oe_debug_pub.add('in OEXUBOKB line adj tbl count from query row is '|| l_line_adj_tbl.count);


         l_in_loop_index := l_line_adj_tbl.FIRST;

         While l_in_loop_index is not NULL LOOP

           OE_ORDER_UTIL.Update_Global_Picture
	   (p_Upd_New_Rec_If_Exists =>FALSE
	   , p_line_adj_id 		=> l_line_adj_tbl(l_in_loop_index).price_adjustment_id
           , x_index 		=> l_notify_index
           , x_return_status 	=> l_return_status);

           OE_ORDER_UTIL.g_line_adj_tbl(l_notify_index) := l_line_adj_tbl(l_in_loop_index);
      OE_ORDER_UTIL.g_line_adj_tbl(l_notify_index).operation := OE_GLOBALS.G_OPR_CREATE;
     oe_debug_pub.add('in OEXUBOKB after insert into global table, line_id is ' || OE_ORDER_UTIL.g_line_adj_tbl(l_notify_index).line_id);
     oe_debug_pub.add('in OEXUBOKB after insert into global table, operation is ' || OE_ORDER_UTIL.g_line_adj_tbl(l_notify_index).operation);

           l_in_loop_index :=  l_line_adj_tbl.NEXT(l_in_loop_index);

         END LOOP;

     oe_debug_pub.add('in OEXUBOKB at end g line adj tbl count is '|| OE_ORDER_UTIL.g_line_adj_tbl.count);

     l_loop_index := l_line_tbl.NEXT(l_loop_index);

  END LOOP outer; -- over each line to update global picture

   -- notification framework end
   -- no need to call process_requests_and_notify in new framework

  ELSE -- ASO or EC are installed and we are using the old framework

    -- Process request is set to FALSE here but this api will
    -- be again called with process_requests = TRUE at the end
    -- of the main Book_Order procedure. This will take care of
    -- executing the tax requests that may have been logged in
    -- this procedure.
    OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests	=> FALSE
		, p_notify	    	=> l_notify
		, x_return_status	=> l_return_status
		, p_header_rec		=> l_header_rec
		, p_old_header_rec	=> l_old_header_rec
		, p_line_tbl		=> l_line_tbl
		, p_old_line_tbl	=> l_old_line_tbl
		);

     -- renga -end change for tax calculation event enhancement

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

  END IF; /* code set is pack H or higher */
  /* jolin end*/

 END IF; -- ASO or EC are installed

/* Call the pricing event in the end after all the processing */

  --  Evaluate the BOOK event for pricing
     -- Call Pricing only if there are active phases in BOOK event.

     IF l_active_phase_count > 0 THEN
            Pricing_Book_Event(p_x_line_tbl => l_line_tbl
                    , p_header_id       => p_header_id
                    , x_return_status   => l_return_status
                    );
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

   IF OE_FEATURES_PVT.Is_Margin_Avail THEN
     --Evaluate margin hold;
     Oe_Margin_Pvt.Margin_Hold(p_header_id);
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Booked_Flag'
                        );
        END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Booked_Flag;

PROCEDURE Verify_Payment_AT_Booking
	( p_header_id			IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

	)
IS
l_msg_count				NUMBER;
l_msg_data				VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	-- If Payment Verification Fails then the Order is
	-- Automatically Put on a Credit Checking Hold  or
	-- a Credit Card Processing Hold.
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING VERIFY PAYMENT' ) ;
	END IF;
	--
	OE_Verify_Payment_PUB.Verify_Payment
		( p_header_id		=> p_header_id
		, p_calling_action	=> 'BOOKING'
		, p_msg_count		=> l_msg_count
		, p_msg_data		=> l_msg_data
		, p_return_status	=> x_return_status
		);

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Verify_Payment_AT_Booking'
                        );
        END IF;
END Verify_Payment_AT_Booking;

PROCEDURE Validate_Sales_Credits
	( p_header_id		IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2

	 )
IS
l_return_status					VARCHAR2(30);
h_return_status                                 VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--FP bug 3872166
CURSOR line_ids(p_header_id IN NUMBER)  IS
SELECT line_id
FROM oe_order_lines_all
WHERE header_id = p_header_id;
BEGIN
   IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('Entering Oe_Order_Book_Util.Validate_sales_Credits' ) ;
   END IF;

        h_return_status := FND_API.G_RET_STS_SUCCESS;
	-- Validate Header Sales Credits
	OE_Validate_Header_Scredit.Validate_HSC_TOTAL_FOR_BK
		( p_header_id		=> p_header_id
		, x_return_status	=> x_return_status );

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS AFTER HSC:'||X_RETURN_STATUS ) ;
	END IF;

        -- FP bug 4697708
        -- h_return_status := x_return_status;
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          h_return_status := x_return_status;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RETURN;
        END IF;


        l_return_status := FND_API.G_RET_STS_SUCCESS;

        -- commented out for FP 4697708
        /*
	-- IF added for nocopy analysis
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RETURN ;
	ELSE
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;
        */

	--FP bug 3872166 start
	FOR l_line_id IN line_ids(p_header_id) LOOP
   	  OE_Validate_Line_Scredit.Validate_LSC_QUOTA_TOTAL
		( x_return_status	=> x_return_status
		 ,p_line_id		=> l_line_id.line_id);

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS AFTER LSC FOR LINE '||l_line_id.line_id|| 'IS '||X_RETURN_STATUS ) ;
          END IF;

          -- FP bug 4697708
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            l_return_status := x_return_status;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RETURN;
          END IF;
	END LOOP;
	--FP bug 3872166 end

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURN STATUS AFTER LSC:'||L_RETURN_STATUS ) ;
        END IF;

        -- FP bug 4697708
        /*
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		l_return_status := x_return_status;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		-- x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RETURN;
	ELSE  -- nocopy analysis
		l_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;
        */

        IF h_return_status = FND_API.G_RET_STS_ERROR OR l_return_status = FND_API.G_RET_STS_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
        ELSIF h_return_status = FND_API.G_RET_STS_UNEXP_ERROR OR l_return_status
= FND_API.G_RET_STS_UNEXP_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ELSE
                 x_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

     IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('Exiting Oe_Order_Book_Util.Validate_sales_Credits: '||x_return_status ) ;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Validate_Sales_Credits'
                        );
        END IF;
END Validate_Sales_Credits;


/* PUBLIC PROCEDURES */

---------------------------------------------------------------
PROCEDURE Check_Booking_Holds
		(p_header_id	 	IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

		)
IS
l_check_holds_result			VARCHAR2(30);
l_msg_count				NUMBER;
l_msg_data				VARCHAR2(2000);
l_dummy                                 VARCHAR2(30);
p_hold_rec                              OE_HOLDS_PUB.any_line_hold_rec;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_ORDER_BOOK_UTIL.CHECK_BOOKING_HOLDS' , 1 ) ;
	END IF;

	-- Check if there are any generic or Booking holds

     -- Fix bug
	-- Removed p_entity_id parameter
	OE_HOLDS_PUB.Check_Holds
		(p_api_version		=> 1.0
		,p_header_id		=> p_header_id
		,p_wf_item		=> 'OEOH'
		,p_wf_activity		=> 'BOOK_ORDER'
		,x_result_out		=> l_check_holds_result
		,x_return_status	=> x_return_status
		,x_msg_count		=> l_msg_count
		,x_msg_data		=> l_msg_data
		);


	IF ( x_return_status = FND_API.G_RET_STS_SUCCESS AND
	     l_check_holds_result = FND_API.G_TRUE )
 	THEN
		FND_MESSAGE.SET_NAME('ONT','OE_BOOKING_HOLD_EXISTS');
		OE_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
        /* Changes for bug#2673236:Begin */
        ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS AND
                l_check_holds_result = FND_API.G_FALSE )
        THEN
              IF nvl(fnd_profile.value('ONT_PREVENT_BOOKING'),'N')='Y' THEN
                IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'Profile ont_prevent_booking is set' , 1 ) ;
                END IF;

                BEGIN
                    SELECT
                      'EXISTS' INTO l_dummy
                    FROM oe_order_lines_all
                    WHERE header_id = p_header_id and
                    ROWNUM = 1;

                    IF sql%found THEN
                        p_hold_rec.header_id := p_header_id;
                        p_hold_rec.wf_item_type := 'OEOH';
                        p_hold_rec.wf_activity_name := 'BOOK_ORDER';

                       IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'Before calling Check_Any_Line_Hold' , 1 ) ;
                       END IF;

                       OE_HOLDS_PUB.Check_Any_Line_Hold
                       (x_hold_rec             => p_hold_rec
                       ,x_return_status        => x_return_status
                       ,x_msg_count            => l_msg_count
                       ,x_msg_data             => l_msg_data
                       );


                       IF ( x_return_status = FND_API.G_RET_STS_SUCCESS AND
                             p_hold_rec.x_result_out = FND_API.G_TRUE )
                       THEN
                           FND_MESSAGE.SET_NAME('ONT','OE_BOOKING_HOLD_EXISTS');
                                OE_MSG_PUB.ADD;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                       END IF;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      null;
                END;
              END IF;
        END IF;
        /* Changes for bug#2673236:End */
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_ORDER_BOOK_UTIL.CHECK_BOOKING_HOLDS' , 1 ) ;
	END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Check_Booking_Holds'
                        );
        END IF;
END Check_Booking_Holds;

---------------------------------------------------------------
PROCEDURE BOOK_ORDER
	(p_api_version_number		IN NUMBER
	,p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE
	,p_header_id				IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

	)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'BOOK_ORDER';
l_api_version_number    CONSTANT NUMBER := 1.0;
l_return_status		VARCHAR2(1);
l_validate_cfg          BOOLEAN;
l_freeze_inc_items      BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_count	                 NUMBER;

l_qa_return_status       VARCHAR2(1);


BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_ORDER_BOOK.BOOK_ORDER' ) ;
	END IF;

    SAVEPOINT BOOK_ORDER;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

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

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;


	-- Validate if revenue sales credits on the header and on each line
	-- add upto 100%. There is no check for error after this as all the
	-- order validation feedback should be given together. The check
	-- for error is therefore, after the next call which would validate
	-- the header and the lines

 	Validate_Sales_Credits
		( p_header_id		=> p_header_id
		, x_return_status	=> l_return_status
		);

       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
         OE_Header_Scredit_Util.Redefault_Sales_Group(p_header_id=>p_header_id,
                               p_date=> nvl(OE_ORDER_UTIL.g_header_rec.booked_date,SYSDATE));
       END IF;

	-- if unexpected error, then go to exception handler. If there
	-- were validation failures, then it is expected error therefore
	-- go to order and line validation and then raise error.
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS AFTER SALES CREDITS:'||L_RETURN_STATUS ) ;
	END IF;

	-- Call process order to update the booked_flag on header and
	-- on all the order lines. This will also check for all the fields
	-- that are required on the order and the lines at booking

	Update_Booked_Flag(p_header_id	=> p_header_id
                         , x_validate_cfg => l_validate_cfg
                         , x_freeze_inc_items => l_freeze_inc_items
			 , x_return_status => x_return_status
			  );

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS AFTER UPDATE BOOKED:'||X_RETURN_STATUS ) ;
	END IF;

	-- if failure during validate sales credits OR during order and
	-- line validation, raise error
	IF (x_return_status = FND_API.G_RET_STS_ERROR OR
		l_return_status = FND_API.G_RET_STS_ERROR ) THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	-- Validate configurations, if any, in this order
        IF (l_validate_cfg) THEN

	  l_return_status := OE_Config_Util.Validate_Cfgs_In_Order
						(p_header_id	=> p_header_id);
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'RETURN STATUS AFTER VALIDATE CFGS:'||L_RETURN_STATUS ) ;
	  END IF;

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

        END IF;


	-- Freeze included items, if any, for this order
        IF (l_freeze_inc_items
            AND FND_PROFILE.VALUE('ONT_INCLUDED_ITEM_FREEZE_METHOD') =
					OE_GLOBALS.G_IIFM_BOOKING )
        THEN

          l_return_status := OE_Config_Util.Freeze_Inc_Items_For_Order
						(p_header_id	=> p_header_id);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RETURN STATUS AFTER FREEZE INC:'||L_RETURN_STATUS ) ;
          END IF;

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        END IF;


        -- Execute any delayed requests and flow starts
        -- Will also take care of executing other delayed requests like
        -- tax which may have been logged in update_booked_flag and
        -- other procedures called by book_order.
        -- NOTE: This should be executed before verify payment call
        -- as credit check needs to look at the updated tax amounts.

	OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests		=> TRUE
		, p_notify			=> FALSE
		, x_return_status		=> l_return_status
		);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- ABH
        -- run QA for current order
       IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN


        /****************************************************
        l_header_id_char := TO_CHAR(p_header_id);
        --This procedure would return status of FND_API.G_RET_STS_SUCCESS only if the order passed QA check
        QA_Order(
                 p_api_version_number => 1.0,
                 p_init_msg_list      => 'T',
                 p_header_id_list     => l_header_id_char,
                 p_header_count       => l_count,
                 x_error_count        => l_error_count,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data
        );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        ****************************************************/

        --Check for licensing
        IF OE_Contracts_util.check_license() <> 'Y' THEN
            IF l_debug_level > 0 THEN
               oe_debug_pub.add('Contractual option not licensed, hence not performing article QA ', 3);
            END IF;
        ELSE


            OE_CONTRACTS_UTIL.qa_articles (
                   p_api_version       => 1.0,
                   p_doc_type          => OE_CONTRACTS_UTIL.G_SO_DOC_TYPE,
                   p_doc_id            => p_header_id,
                   x_qa_return_status  => l_qa_return_status,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data);


            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

               IF l_qa_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF l_qa_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


        END IF;


       END IF;
        -- ABH

        -- From Order Import we will make a call to Verfify Payment, only after committing the data.
	-- The call to Verify Payment from Booking code is suppressed for Order Import flow.
	-- This change is only for Verify Payment call that is triggered as part of Booking.
       IF NOT OE_GLOBALS.G_ORDER_IMPORT_CALL THEN -- Bug 7367433

	-- Payment Verification is done at the end of booking
	-- because it is an expensive operation.

        --R12 CVV2
        IF nvl(OE_GLOBALS.G_PAYMENT_PROCESSED, 'N') <> 'Y' THEN
	   Verify_Payment_AT_Booking
			(p_header_id	=> p_header_id
			 , x_return_status => l_return_status
			);
	   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
        END IF;
       ELSE
         IF nvl(OE_GLOBALS.G_PAYMENT_PROCESSED, 'N') <> 'Y' THEN
            OE_GLOBALS.G_PAYMENT_PROCESSED := 'O';
         END IF;
       END IF; -- Bug 7367433

        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_ORDER_BOOK.BOOK_ORDER' , 1 ) ;
	END IF;

EXCEPTION
-- Bug 2285308: Clear Delayed Requests when there is an error.
-- Pricing/Inc Item Explosion API calls can log delayed requests but
-- execution of requests is only towards the end, just before Verify_Payments.
-- If there is an error in between logging and execution of requests,
-- requests were not cleared from the cache earlier resulting
-- in bugs like 2285308.
    WHEN FND_API.G_EXC_ERROR THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXP. ERROR IN OE_ORDER_BOOK.BOOK_ORDER' , 1 ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
	ROLLBACK TO BOOK_ORDER;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UNEXP. ERROR IN OE_ORDER_BOOK.BOOK_ORDER' , 1 ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
	ROLLBACK TO BOOK_ORDER;
    WHEN OTHERS THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OTHERS ERROR IN OE_ORDER_BOOK.BOOK_ORDER' , 1 ) ;
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   l_api_name
                        );
        END IF;
        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);
	ROLLBACK TO BOOK_ORDER;
END BOOK_ORDER;


-- Complete_Book_Eligible
-- Checks if the order is eligible for booking and if not, populates
-- an error message and returns an expected error status.
-- If it is eligible, it progresses the order workflow to complete
-- the booking process.
-- If booking has been deferred, then it informs the caller by
-- adding a message to the stack.
---------------------------------------------------------------------
PROCEDURE Complete_Book_Eligible
		(p_api_version_number	IN	NUMBER
		, p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE
		, p_header_id			IN 	NUMBER
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

		)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'COMPLETE_BOOK_ELIGIBLE';
l_api_version_number    CONSTANT NUMBER := 1.0;
l_itemkey				VARCHAR2(30);
l_booked_flag			VARCHAR2(1);
l_book_eligible		VARCHAR2(1);
l_booking_errored_flag  VARCHAR2(1);
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_type_id   NUMBER;
l_source_document_id        NUMBER;
CURSOR book_eligible IS
	SELECT 'Y'
	FROM WF_ITEM_ACTIVITY_STATUSES WIAS
		, WF_PROCESS_ACTIVITIES WPA
	WHERE WIAS.item_type = 'OEOH'
	  AND WIAS.item_key = l_itemkey
	  AND WIAS.activity_status = 'NOTIFIED'
	  AND WPA.activity_name = 'BOOK_ELIGIBLE'
	  AND WPA.instance_id = WIAS.process_activity;
--For bug 3493374
CURSOR booking_errored IS
       SELECT 'Y'
       FROM WF_ITEM_ACTIVITY_STATUSES WIAS
		, WF_PROCESS_ACTIVITIES WPA
       WHERE WIAS.item_type = 'OEOH'
       AND WIAS.item_key = l_itemkey
       AND WIAS.activity_status = 'ERROR'
       AND WPA.activity_name = 'BOOK_ORDER'
       AND WPA.instance_id = WIAS.process_activity;
	  --
	  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	  --
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_ORDER_BOOK.COMPLETE_BOOK_ELIGIBLE' , 1 ) ;
	END IF;

    	-- Initialize API return status to success
   	 x_return_status := FND_API.G_RET_STS_SUCCESS;

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

    	--  Initialize message list.

   	 IF FND_API.to_Boolean(p_init_msg_list) THEN
        		OE_MSG_PUB.initialize;
   	 END IF;

         SELECT order_source_id, orig_sys_document_ref, change_sequence, source_document_type_id, source_document_id
	 INTO l_order_source_id, l_orig_sys_document_ref, l_change_sequence, l_source_document_type_id, l_source_document_id
	 FROM OE_ORDER_HEADERS_ALL
 	 WHERE HEADER_ID = p_header_id;

    OE_MSG_PUB.set_msg_context(
      p_entity_code           => 'HEADER'
     ,p_entity_id                  => p_header_id
     ,p_header_id                  => p_header_id
     ,p_line_id                    => null
     ,p_order_source_id            => l_order_source_id
     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
     ,p_orig_sys_document_line_ref => null
     ,p_change_sequence            => l_change_sequence
     ,p_source_document_type_id    => l_source_document_type_id
     ,p_source_document_id         => l_source_document_id
     ,p_source_document_line_id    => null );

	l_itemkey := to_char(p_header_id);

	-- Check if for this header, the BOOK_ELIGIBLE activity is in a
	-- notified state

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'OPEN BOOK_ELIGIBLE' ) ;
		END IF;
	OPEN book_eligible;
	FETCH book_eligible INTO l_book_eligible;

	IF (book_eligible%NOTFOUND) THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'BOOKING NOT ELIGIBLE' ) ;
		END IF;

     	-- Booking could be a high cost activity and could have been deferred
		-- due to a prior request. If the activity is in a deferred status,
		-- then inform the user.

 	      IF BookingIsDeferred(l_itemkey)
              THEN

			 OE_MSG_PUB.Count_And_Get
                	 (   p_count     =>      x_msg_count
			 ,   p_data      =>      x_msg_data
                	 );
		  	 CLOSE book_eligible;
	       		 RETURN;
             --For bug 3493374.Booking errored out
             ELSE
		OPEN booking_errored;
		FETCH booking_errored INTO l_booking_errored_flag;
                IF (booking_errored%FOUND)
                THEN
	          FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOK_ERRORED');
		  OE_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
                -- Else the order is NOT eligible for booking: raise an error.
	     	ELSE
		   FND_MESSAGE.SET_NAME('ONT','OE_ORDER_NOT_BOOK_ELIGIBLE');
		   OE_MSG_PUB.ADD;
		   RAISE FND_API.G_EXC_ERROR;
	        END IF;
        	CLOSE booking_errored;
             END IF;
	END IF;

	CLOSE book_eligible;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CLOSE BOOK_ELIGIBLE' ) ;
		END IF;


	-- Lock the order: header, lines , sales credits and price adjustments
	-- This will prevent another user from working on the same order
	-- and needs to be done before calling the wf_engine as the workflow
	-- engine will hang if another user is trying to book the same order

	OE_ORDER_UTIL.Lock_Order_Object
			(p_header_id	=> p_header_id
			,x_return_status	=> x_return_status
			);
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Call WF_ENGINE to complete the BOOK_ELIGIBLE activity and proceed
	-- to the next activity in the order workflow

	WF_ENGINE.CompleteActivityInternalName
		( itemtype		=> 'OEOH'
		, itemkey			=> l_itemkey
		, activity		=> 'BOOK_ELIGIBLE'
		, result		=> NULL
		);


	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AFTER CALLING WF_ENGINE' ) ;
	END IF;

	-- if order was booked, the flag on the order header would have
	-- been updated.

	SELECT booked_flag
	INTO	l_booked_flag
	FROM OE_ORDER_HEADERS_ALL
	WHERE HEADER_ID = p_header_id;

    OE_MSG_PUB.set_msg_context(
      p_entity_code           => 'HEADER'
     ,p_entity_id                  => p_header_id
     ,p_header_id                  => p_header_id
     ,p_line_id                    => null
     ,p_order_source_id            => l_order_source_id
     ,p_orig_sys_document_ref 	=> l_orig_sys_document_ref
     ,p_orig_sys_document_line_ref => null
     ,p_change_sequence            => l_change_sequence
     ,p_source_document_type_id    => l_source_document_type_id
     ,p_source_document_id         => l_source_document_id
     ,p_source_document_line_id    => null );

    	 -- if order has been booked, inform the user

	IF l_booked_flag = 'Y' THEN

		FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOKED');
		OE_MSG_PUB.ADD;

	-- if order has NOT been booked, then check if booking has been deferred

	ELSE

          -- if order is neither booked nor booking has been deferred,
          -- then raise an expected error: booking might have failed.
          -- Error messages would have been populated in the
          -- BOOK_ORDER activity
          IF NOT BookingIsDeferred(l_itemkey)
          THEN

            -- Bug 2437258 - raise error only if order is back at
            -- book eligible status. As booking workflows should be
            -- defined to transition to book eligible for errors.
            -- If it is NOT at book eligible, there was probably a
            -- customization between book eligible and book order
            -- (e.g. WF approval notification) due to which order
            -- did not even reach book order activity.
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AGAIN OPEN BOOK_ELIGIBLE' ) ;
            END IF;
	    OPEN book_eligible;
	    FETCH book_eligible INTO l_book_eligible;
	    IF (book_eligible%FOUND) THEN
		RAISE FND_API.G_EXC_ERROR;
            END IF;
            CLOSE book_eligible;

          END IF;

	END IF;

        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );

	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_ORDER_BOOK.COMPLETE_BOOK_ELIGIBLE' , 1 ) ;
	END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	IF (book_eligible%ISOPEN) THEN
		CLOSE book_eligible;
   	END IF;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);
	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF (book_eligible%ISOPEN) THEN
		CLOSE book_eligible;
   	END IF;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');
WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF (book_eligible%ISOPEN) THEN
		CLOSE book_eligible;
   	END IF;
	IF      OE_MSG_PUB.Check_Msg_Level
		   (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		   OE_MSG_PUB.Add_Exc_Msg
				( G_PKG_NAME
				, l_api_name
				);
     	END IF;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);
	OE_MSG_PUB.Reset_Msg_Context(p_entity_code	=> 'HEADER');

END Complete_Book_Eligible;


-- PROCEDURE Book_Multiple_Orders
-- This procedure accepts a list of header IDs in a string separated
-- by commas (e.g. 1234,3567.8945) and the number of orders
-- (p_header_count) to be booked.
-- And it progresses each order through the booking activity in its
-- workflow by calling complete_book_eligible.
-- The return status is SUCCESS only if all orders are processed
-- successfully.
-- The number of orders that are processed with errors can be retrieved
-- from the OUT variable, x_error_count.
-- Called from the form package OE_ORDER_CONTROL.Book_Order_Button
-- for booking multi_selected orders.
---------------------------------------------------------------------
PROCEDURE Book_Multiple_Orders
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id_list               IN OE_GLOBALS.Selected_Record_Tbl
        ,p_header_count                 IN NUMBER
,x_error_count OUT NOCOPY NUMBER

,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        )
IS
l_api_name              CONSTANT VARCHAR2(30) := 'BOOK_MULTIPLE_ORDERS';
l_api_version_number    CONSTANT NUMBER := 1.0;
l_header_id			NUMBER;
l_Transaction_Phase_Code	 VARCHAR2(30);
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
I					NUMBER;
initial				NUMBER;
nextpos				NUMBER;
l_return_status		VARCHAR2(30);
l_orgid number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTER OE_ORDER_BOOK.BOOK_MULTIPLE_ORDERS' , 1 ) ;
	END IF;

    	-- Initialize API return status to success
   	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 x_error_count := 0;

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

    	--  Initialize message list.

   	 IF FND_API.to_Boolean(p_init_msg_list) THEN
        		OE_MSG_PUB.initialize;
   	 END IF;
  initial := 1;
  FOR I IN 1..p_header_count LOOP

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add( 'Enter Loop headercount'|| p_header_count , 1 ) ;
	END IF;
/* changes for MOAC, not required since the input is the table
	IF I = p_header_count THEN
	 nextpos := length(p_header_id_list)+1.0;
	ELSE
	 nextpos := INSTR(p_header_id_list,',',initial,1);
	END IF;
*/

      l_header_id := p_header_id_list(i).id1;
        IF l_orgid is null OR p_header_id_list(i).org_id <> l_orgid THEN
                l_orgid := p_header_id_list(i).Org_Id;

 Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                               p_org_id      => p_header_id_list(i).Org_Id);

        END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'HEADER ID: '||L_HEADER_ID , 1 ) ;
      END IF;
      --For CC Project
SELECT  h.Transaction_Phase_Code
INTO l_Transaction_Phase_Code
FROM oe_order_headers_all h
WHERE  l_header_id=h.header_id;
IF (l_Transaction_Phase_Code='N' ) THEN
OE_Order_Wf_Util.Complete_eligible_and_Book(
      p_api_version_number => 1.0
     , p_init_msg_list                =>  FND_API.G_FALSE
     , p_header_id			   =>  l_header_id
     , x_return_status                =>  l_return_status
     , x_msg_count                    =>  l_msg_count
     , x_msg_data                      => l_msg_data );
ELSE
	 OE_Order_Book_Util.Complete_Book_Eligible (
		p_api_version_number   => 1.0
               , p_init_msg_list        => FND_API.G_FALSE
               , p_header_id            => l_header_id
               , x_return_status        => l_return_status
               , x_msg_count            => l_msg_count
               , x_msg_data             => l_msg_data);
END IF ;

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		x_error_count := x_error_count + 1.0;
		x_return_status := FND_API.G_RET_STS_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		x_error_count := x_error_count + 1.0;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 END IF;

      initial := nextpos + 1.0;
  END LOOP;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXIT OE_ORDER_BOOK.BOOK_MULTIPLE_ORDERS' , 1 ) ;
	END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF OE_MSG_PUB.Check_Msg_Level
		   (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		   OE_MSG_PUB.Add_Exc_Msg
				( G_PKG_NAME
				, l_api_name
				);
     END IF;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);

END Book_Multiple_Orders;



/******************************************************************************
--ABH
-- This procedure accepts a list of header IDs in a string separated
-- by commas (e.g. 1234,3567,8945) and the number of orders
-- (p_header_count) to be QA'd.
-- In case of a single order, we have just one header id in the string.
-- The return status is SUCCESS only if all orders are processed
-- successfully.
-- The number of orders that are processed with errors (i.e. QA returned error) can be retrieved
-- from the OUT variable, x_error_count.
-- Called from the form package OE_ORDER_CONTROL.Book_Order_Button
-- for QA'ing multi_selected orders or just a single order.
PROCEDURE QA_Order
        (p_api_version_number           IN  NUMBER
        ,p_init_msg_list                IN  VARCHAR2              := FND_API.G_FALSE
        ,p_header_id_list               IN  OUT NOCOPY VARCHAR2
        ,p_header_count                 IN  NUMBER
        ,x_error_count                  OUT NOCOPY NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2
        ) IS

       l_api_name                       CONSTANT VARCHAR2(30) := 'QA_ORDER';
       l_api_version_number             CONSTANT NUMBER := 1.0;
       l_header_id                      NUMBER;
       l_msg_count                      NUMBER;
       l_msg_data                       VARCHAR2(2000);
       I                                NUMBER;
       initial                          NUMBER;
       nextpos                          NUMBER;
       l_return_status                  VARCHAR2(30);

       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

       TYPE header_id_tbl_type          IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
       l_header_id_tbl                  header_id_tbl_type;
       TYPE delete_header_id_tbl_type   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
       l_delete_header_id_tbl           delete_header_id_tbl_type;
       J                                NUMBER;
       l_qa_return_status               VARCHAR2(1);
       l_record_ids                     VARCHAR2(32000);

BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTER OE_ORDER_BOOK.QA_ORDER' , 1 ) ;
      oe_debug_pub.add('p_header_count: ' || p_header_count, 1);
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_error_count := 0;

  --Check for licensing
  IF OE_Contracts_util.check_license() <> 'Y' THEN
      IF l_debug_level > 0 THEN
         oe_debug_pub.add('Contractual option not licensed, hence not performing article QA ', 3);
      END IF;
      RETURN;
  END IF;



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

  --  Initialize message list.

  IF FND_API.to_Boolean(p_init_msg_list) THEN
            OE_MSG_PUB.initialize;
  END IF;

  --initialize PL/SQL tables
  l_header_id_tbl.DELETE;
  l_delete_header_id_tbl.DELETE;



  --convert the header id's separated by commas in p_header_id_list into a PL/SQL table l_header_id_tbl
  initial := 1;
  FOR I IN 1..p_header_count LOOP

      IF I = p_header_count THEN
         nextpos := length(p_header_id_list)+1.0;
      ELSE
         nextpos := INSTR(p_header_id_list,',',initial,1);
      END IF;

      l_header_id := to_number(substr(p_header_id_list,initial, nextpos-initial));
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'adding to PL/SQL table HEADER ID: '||L_HEADER_ID , 1 ) ;
      END IF;

      --transfer into PL/SQL table
      l_header_id_tbl(I) := l_header_id;

      initial := nextpos + 1.0;
  END LOOP;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('l_header_id_tbl.COUNT: ' || l_header_id_tbl.COUNT);
  END IF;


  --now run QA on header id's contained in PL/SQL table l_header_id_tbl
  J := 1;
  FOR I IN 1..p_header_count LOOP
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Calling OE_CONTRACTS_UTIL.qa_articles for l_header_id_tbl('||I||'): '||l_header_id_tbl(I));
      END IF;

      OE_CONTRACTS_UTIL.qa_articles (
                   p_api_version       => 1.0,
                   p_doc_type          => OE_CONTRACTS_UTIL.G_SO_DOC_TYPE,
                   p_doc_id            => TO_NUMBER(l_header_id_tbl(I)),
                   x_qa_return_status  => l_qa_return_status,
                   x_return_status     => l_return_status,
                   x_msg_count         => l_msg_count,
                   x_msg_data          => l_msg_data);




      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('l_return_status for l_header_id_tbl('||I||'): '||l_header_id_tbl(I)||' is '|| l_return_status);
          oe_debug_pub.add('l_qa_return_status for l_header_id_tbl('||I||'): '||l_header_id_tbl(I)||' is '|| l_qa_return_status);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF l_qa_return_status = FND_API.G_RET_STS_ERROR THEN
             l_delete_header_id_tbl(J) := I;  --keep track of which header id to delete later
             J := J + 1;
             x_error_count := x_error_count + 1.0;
             x_return_status := FND_API.G_RET_STS_ERROR;

         ELSIF l_qa_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             l_delete_header_id_tbl(J) := I;  --keep track of which header id to delete later
             J := J + 1;
             x_error_count := x_error_count + 1.0;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         END IF;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


  END LOOP;


  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('l_delete_header_id_tbl.COUNT: ' || l_delete_header_id_tbl.COUNT);
     oe_debug_pub.add('l_header_id_tbl.COUNT before deleting: ' || l_header_id_tbl.COUNT);
  END IF;

  --delete the header id's that failed QA from the PL/SQL table l_header_id_tbl
  FOR J IN 1..l_delete_header_id_tbl.COUNT LOOP
      l_header_id_tbl.DELETE(l_delete_header_id_tbl(J));

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Deleted element with index ' || J || ' from l_header_id_tbl');
      END IF;
  END LOOP;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('l_header_id_tbl.COUNT after deleting: ' || l_header_id_tbl.COUNT);
  END IF;



  -- finally transfer the remaining QA passed header ids in PL/SQL table l_header_id_tbl back to comma separated
  --    form in p_header_id_list
  l_record_ids := NULL;  --initialize
  I := l_header_id_tbl.FIRST;
  WHILE I IS NOT NULL LOOP

      IF (I = l_header_id_tbl.LAST OR l_header_id_tbl.COUNT = 1) THEN
         l_record_ids := l_record_ids || l_header_id_tbl(I);
      ELSE
         l_record_ids := l_record_ids || l_header_id_tbl(I) || ',';
      END IF;

      I := l_header_id_tbl.NEXT(I);

  END LOOP;

  p_header_id_list := l_record_ids;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Length of string l_record_ids: ' || LENGTH(l_record_ids));
     oe_debug_pub.add('Length of string p_header_id_list: ' || LENGTH(p_header_id_list));
  END IF;



  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXIT OE_ORDER_BOOK.QA_ORDER' , 1 ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF OE_MSG_PUB.Check_Msg_Level
		   (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		   OE_MSG_PUB.Add_Exc_Msg
				( G_PKG_NAME
				, l_api_name
				);
     END IF;
	OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
		);


END QA_Order;
--ABH
******************************************************************************/


END OE_ORDER_BOOK_UTIL;

/
