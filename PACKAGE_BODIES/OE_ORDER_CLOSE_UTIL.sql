--------------------------------------------------------
--  DDL for Package Body OE_ORDER_CLOSE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_CLOSE_UTIL" AS
/* $Header: OEXUCLOB.pls 120.11.12010000.4 2009/07/13 05:48:09 snimmaga ship $ */

--  Global constant holding the package name
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'OE_ORDER_CLOSE_UTIL';

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 DELETE_ADJUSTMENTS purges the the unapplied adjustments from oe table

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

PROCEDURE DELETE_ADJUSTMENTS (
        p_header_id                    IN NUMBER DEFAULT NULL
        ,p_line_id                     IN NUMBER DEFAULT NULL
        )
IS
l_adjustment_id        NUMBER;

--bug4099565
-- Adding the condition retrobill_request_id IS NULL in both the cursors to prevent the deletion of manual modifier record corresponding to the latest price in the set up in the case of retrobill lines.

CURSOR c_adjustment_header IS
         SELECT price_adjustment_id
         FROM oe_price_adjustments
         WHERE header_id = p_header_id
         AND list_line_type_code<>'TAX'
         AND automatic_flag = 'N'
         AND applied_flag = 'N'
         AND retrobill_request_id IS NULL; --bug4099565

/* Added a condition to avoid deleting unapplied Price Break Child line adjustments
   from oe_price_adjustments for bug 2516895 */
CURSOR c_adjustment_line IS
         SELECT price_adjustment_id
         FROM oe_price_adjustments adj
         WHERE line_id = p_line_id
         AND list_line_type_code<>'TAX'
         AND automatic_flag = 'N'
         AND applied_flag = 'N'
         AND retrobill_request_id IS NULL --bug4099565
         AND not exists( select 1 from oe_price_adj_assocs
                         where rltd_price_adj_id = adj.price_adjustment_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('ENTERING DELETE_ADJUSTMENTS');
  END IF;

  IF p_header_id IS NOT NULL THEN
   OPEN c_adjustment_header;
   LOOP
    BEGIN
      FETCH c_adjustment_header INTO l_adjustment_id;
      EXIT WHEN c_adjustment_header%NOTFOUND;
      --
      DELETE FROM oe_price_adj_assocs
      WHERE price_adjustment_id = l_adjustment_id;
      --
      DELETE FROM oe_price_adj_attribs
      WHERE price_adjustment_id = l_adjustment_id;
      --
     DELETE FROM oe_price_adjustments
     WHERE price_adjustment_id = l_adjustment_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
   END LOOP;
    --
   CLOSE c_adjustment_header;
  ELSE
   IF p_line_id IS NOT NULL THEN
    OPEN c_adjustment_line;
    LOOP
     BEGIN
       FETCH c_adjustment_line INTO l_adjustment_id;
       EXIT WHEN c_adjustment_line%NOTFOUND;
       --
       DELETE FROM oe_price_adj_assocs
       WHERE price_adjustment_id = l_adjustment_id;
       --
       DELETE FROM oe_price_adj_attribs
       WHERE price_adjustment_id = l_adjustment_id;
       --
       DELETE FROM oe_price_adjustments
       WHERE price_adjustment_id = l_adjustment_id;
     EXCEPTION
        WHEN OTHERS THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;
      --
    END LOOP;
    CLOSE c_adjustment_line;
     --
   ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ERROR: BOTH PARAMETERS ARE NULL IN DELETE_ADJUSTMENTS ' , 1 ) ;
         END IF;
      RETURN;
   END IF;
  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('EXITING DELETE_ADJUSTMENTS');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
     END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DELETE_ADJUSTMENTS;

PROCEDURE CLOSE_ORDER
        (p_api_version_number           IN NUMBER
        ,p_init_msg_list                IN VARCHAR2 := FND_API.G_FALSE
        ,p_header_id                    IN NUMBER
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

        )
IS
l_header_rec            OE_ORDER_PUB.Header_Rec_Type;
l_old_header_rec	OE_ORDER_PUB.Header_Rec_Type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_check_hold_result	VARCHAR2(30);
on_hold_error           EXCEPTION;
l_notify_index		NUMBER;  -- jolin
l_itemkey_sso            NUMBER; -- GENESIS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

	SAVEPOINT CLOSE_ORDER;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'HEADER'
        ,p_entity_id                    => p_header_id
        ,p_header_id                    => p_header_id);

        -- Lock and query the old header record

        OE_Header_Util.Lock_Row
		(p_header_id		=> p_header_id
		,p_x_header_rec     => l_old_header_rec
		,x_return_status 	=> x_return_status
		);
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        OE_MSG_PUB.update_msg_context(
         p_entity_code                  => 'HEADER'
        ,p_entity_id                    => l_old_header_rec.header_id
        ,p_header_id                    => l_old_header_rec.header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => l_old_header_rec.orig_sys_document_ref
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => l_old_header_rec.change_sequence
        ,p_source_document_id           => l_old_header_rec.source_document_id
        ,p_source_document_line_id      => null
        ,p_order_source_id            => l_old_header_rec.order_source_id
        ,p_source_document_type_id    => l_old_header_rec.source_document_type_id);


	-- check for generic or holds specific to CLOSE_HEADER activity
	IF nvl(l_old_header_rec.cancelled_flag,'N') = 'N' THEN

	OE_Holds_PUB.Check_Holds
		(p_api_version			=> 1.0
		,p_header_id			=> p_header_id
		,p_wf_item			=> 'OEOH'
		,p_wf_activity			=> 'CLOSE_ORDER'
		,p_chk_act_hold_only     => 'Y'
		,x_result_out			=> l_check_hold_result
		,x_return_status		=> x_return_status
		,x_msg_count			=> l_msg_count
		,x_msg_data			=> l_msg_data
		);

	END IF;

	IF ( x_return_status = FND_API.G_RET_STS_SUCCESS AND
		l_check_hold_result = FND_API.G_TRUE )
	THEN
		FND_MESSAGE.SET_NAME('ONT','OE_CLOSE_ORDER_HOLD_EXISTS');
		OE_MSG_PUB.ADD;
		RAISE ON_HOLD_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


        -- Set the open flag and flow status on the header

	l_header_rec					:= l_old_header_rec;
	l_header_rec.open_flag   		:= 'N';
	IF l_header_rec.cancelled_flag = 'Y' THEN
		l_header_rec.flow_status_code		:= 'CANCELLED';
	ELSE
		l_header_rec.flow_status_code 	:= 'CLOSED';
	END IF;
	l_header_rec.last_updated_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID); -- 3169637;
	l_header_rec.last_update_login	:= FND_GLOBAL.LOGIN_ID;
	l_header_rec.last_update_date		:= SYSDATE;
	l_header_rec.lock_control		:= l_header_rec.lock_control + 1;

	UPDATE oe_order_headers
	SET open_flag 			= l_header_rec.open_flag
	  , flow_status_code 	= l_header_rec.flow_status_code
	  , last_updated_by		= l_header_rec.last_updated_by
	  , last_update_login	= l_header_rec.last_update_login
	  , last_update_date	= l_header_rec.last_update_date
	  , lock_control         = l_header_rec.lock_control
	WHERE header_id 		= p_header_id;

-- Added for bug 5988559
        IF SQL%NOTFOUND THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORG CONTEXT is not properly set for'||p_header_id , 1) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        END IF;

        DELETE_ADJUSTMENTS(p_header_id => p_header_id);

    -- jolin start
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    -- call notification framework to get header index position
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_header_rec		=> l_header_rec
	, p_old_header_rec	=> l_old_header_rec
        , p_header_id 		=> l_header_rec.header_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FOR HDR IS: ' || X_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HDR INDEX IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

   IF l_notify_index is not null then
     -- modify Global Picture

    OE_ORDER_UTIL.g_header_rec.open_flag:= l_header_rec.open_flag;
    OE_ORDER_UTIL.g_header_rec.flow_status_code:= l_header_rec.flow_status_code;
    OE_ORDER_UTIL.g_header_rec.last_updated_by:=l_header_rec.last_updated_by;
    OE_ORDER_UTIL.g_header_rec.last_update_login:=l_header_rec.last_update_login;
    OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
    OE_ORDER_UTIL.g_header_rec.lock_control:=	l_header_rec.lock_control;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL HDR OPEN_FLAG IS: ' || OE_ORDER_UTIL.G_HEADER_REC.OPEN_FLAG , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL HDR FLOW_STATUS_CODE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE , 1 ) ;
			END IF;

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

-- Process requests is TRUE so still need to call it, but don't need to notify
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXUCLOB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
	OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests	=> TRUE
		, p_notify		=> FALSE
        	, p_process_ack         => FALSE
		, x_return_status	=> x_return_status
		, p_header_rec		=> l_header_rec
		, p_old_header_rec	=> l_old_header_rec
		);
	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
      END IF ; /* global entity index null check */

    ELSE  /* in pre-pack H code */

	-- Need to both notify and process requests in old framework
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXUCLOB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
      END IF;
	    OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests	=> TRUE
		, p_notify		=> TRUE
        	, p_process_ack         => FALSE
		, x_return_status	=> x_return_status
		, p_header_rec		=> l_header_rec
		, p_old_header_rec	=> l_old_header_rec
		);
	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
    END IF; /* code set is pack H or higher */
    -- jolin end

     /********************GENESIS********************************
     *  Some statuses are not going through process order and   *
     *  the update_flow_status is getting called directly. So   *
     *  we need to call synch_header_line for 28                *
     ***********************************************************/
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' GENESIS : -CLOSE ORDER- header rec order source'||l_header_rec.order_source_id);
     END IF;
     IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
       -- 8516700: Start (O2C25)
       IF Oe_Genesis_Util.Status_Needs_Sync(l_header_rec.flow_status_code) THEN
       -- 8516700: End (O2C25)

         select OE_XML_MESSAGE_SEQ_S.nextval
         into l_itemkey_sso
         from dual;
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' GENESIS CLOSE : CLOSE ORDER - l_itemkey_sso'||l_itemkey_sso);
         END IF;
         OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE( p_header_rec          => l_header_rec
                                            ,p_line_rec            => null
                                            ,p_hdr_req_id          => l_itemkey_sso
                                            ,p_lin_req_id          => null
                                            ,p_change_type         => 'LINE_STATUS');
       END IF; -- status_needs_sync
      END IF; -- source_aia_enabled
      -- GENESIS --

        -- aksingh performance
        -- As the update is on headers table, it is time to update
        -- cache also!
        OE_Order_Cache.Set_Order_Header(l_header_rec);

        -- Bug 1755817: clear the cached constraint results for header entity
        -- when order header is updated.
        OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
                (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

        OE_MSG_PUB.reset_msg_context('HEADER');

EXCEPTION
    WHEN ON_HOLD_ERROR THEN
	   x_return_status := 'H';
           OE_MSG_PUB.reset_msg_context('HEADER');
	   ROLLBACK TO CLOSE_ORDER;
    WHEN FND_API.G_EXC_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           OE_MSG_PUB.reset_msg_context('HEADER');
	   ROLLBACK TO CLOSE_ORDER;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.reset_msg_context('HEADER');
	   ROLLBACK TO CLOSE_ORDER;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Close_Order'
                        );
        END IF;
           OE_MSG_PUB.reset_msg_context('HEADER');
	   ROLLBACK TO CLOSE_ORDER;
END CLOSE_ORDER;

PROCEDURE CLOSE_LINE
        (p_api_version_number  IN NUMBER
        ,p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE
        ,p_line_id             IN NUMBER
        ,x_return_status       OUT NOCOPY VARCHAR2
        ,x_msg_count           OUT NOCOPY NUMBER
        ,x_msg_data            OUT NOCOPY VARCHAR2
        )
IS
l_line_tbl              OE_ORDER_PUB.Line_TBL_Type;
l_old_line_tbl		OE_ORDER_PUB.Line_TBL_Type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_check_hold_result	VARCHAR2(30);
on_hold_error           EXCEPTION;
l_notify_index		NUMBER;  -- jolin
-- GENESIS --
l_itemkey_sso           NUMBER;
l_header_rec            OE_Order_PUB.Header_Rec_Type;
l_return_status_gen     VARCHAR2(30);
-- GENESIS --
l_return_status         VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
l_inventory_item_id     oe_order_lines_all.inventory_item_id%TYPE;
l_org_id                oe_order_lines_all.org_id%TYPE;
/* Customer Acceptance */
l_pending_acceptance VARCHAR2(1) := 'N';
l_line_rec               OE_ORDER_PUB.Line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER OE_ORDER_CLOSE_UTIL.CLOSE_LINE' , 1 ) ;
     END IF;

	SAVEPOINT CLOSE_LINE;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

        OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'LINE'
        ,p_entity_id                    => p_line_id
        ,p_line_id                      => p_line_id);


    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    IF OE_GLOBALS.G_EC_INSTALLED IS NULL THEN
        OE_GLOBALS.G_EC_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(175);
    END IF;


    -- Check whether EC/ASO products are installed. Call lock_row only if we
    -- need to call Process_Requests_And_Notify to notify OC or to process
    -- acknowledgements.

    IF ( (OE_GLOBALS.G_EC_INSTALLED <> 'Y') AND
         (OE_GLOBALS.G_ASO_INSTALLED <> 'Y') AND
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'N')  )
    THEN
           SELECT cancelled_flag,
                  lock_control,
                  line_id,
                  header_id,
                  order_source_id,
                  orig_sys_document_ref,
                  orig_sys_line_ref,
                  orig_sys_shipment_ref,
                  change_sequence,
                  source_document_type_id,
                  source_document_id,
                  source_document_line_id
           INTO   l_old_line_tbl(1).cancelled_flag,
                  l_old_line_tbl(1).lock_control,
                  l_old_line_tbl(1).line_id,
                  l_old_line_tbl(1).header_id,
                  l_old_line_tbl(1).order_source_id,
                  l_old_line_tbl(1).orig_sys_document_ref,
                  l_old_line_tbl(1).orig_sys_line_ref,
                  l_old_line_tbl(1).orig_sys_shipment_ref,
                  l_old_line_tbl(1).change_sequence,
                  l_old_line_tbl(1).source_document_type_id,
                  l_old_line_tbl(1).source_document_id,
                  l_old_line_tbl(1).source_document_line_id
           FROM   oe_order_lines_all
           WHERE  line_id = p_line_id
           FOR UPDATE NOWAIT;

        OE_MSG_PUB.update_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_old_line_tbl(1).line_id
         ,p_header_id                   => l_old_line_tbl(1).header_id
         ,p_line_id                     => l_old_line_tbl(1).line_id
         ,p_orig_sys_document_ref       => l_old_line_tbl(1).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_old_line_tbl(1).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_old_line_tbl(1).orig_sys_shipment_ref
         ,p_change_sequence             => l_old_line_tbl(1).change_sequence
         ,p_source_document_id          => l_old_line_tbl(1).source_document_id
         ,p_source_document_line_id     => l_old_line_tbl(1).source_document_line_id
         ,p_order_source_id             => l_old_line_tbl(1).order_source_id
         ,p_source_document_type_id     => l_old_line_tbl(1).source_document_type_id);

    ELSE
     	-- Lock and query the old line record

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

        OE_MSG_PUB.update_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_old_line_tbl(1).line_id
         ,p_header_id                   => l_old_line_tbl(1).header_id
         ,p_line_id                     => l_old_line_tbl(1).line_id
         ,p_orig_sys_document_ref       => l_old_line_tbl(1).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_old_line_tbl(1).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_old_line_tbl(1).orig_sys_shipment_ref
         ,p_change_sequence             => l_old_line_tbl(1).change_sequence
         ,p_source_document_id          => l_old_line_tbl(1).source_document_id
         ,p_source_document_line_id     => l_old_line_tbl(1).source_document_line_id
         ,p_order_source_id             => l_old_line_tbl(1).order_source_id
         ,p_source_document_type_id     => l_old_line_tbl(1).source_document_type_id);

    END IF;



     --- Deep

    -- check for generic or holds specific to CLOSE_LINE activity

	IF nvl(l_old_line_tbl(1).cancelled_flag,'N') = 'N' THEN
	    OE_Holds_PUB.Check_Holds
		(p_api_version	    => 1.0
		,p_line_id			=> p_line_id
		,p_wf_item			=> 'OEOL'
		,p_wf_activity	    => 'CLOSE_LINE'
		,p_chk_act_hold_only    => 'Y'
		,x_result_out			=> l_check_hold_result
		,x_return_status		=> x_return_status
		,x_msg_count			=> l_msg_count
		,x_msg_data			=> l_msg_data
		);
         IF ( x_return_status = FND_API.G_RET_STS_SUCCESS AND
			l_check_hold_result = FND_API.G_TRUE )
		THEN
			FND_MESSAGE.SET_NAME('ONT','OE_CLOSE_LINE_HOLD_EXISTS');
			OE_MSG_PUB.ADD;
			RAISE ON_HOLD_ERROR;
		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

    --Customer Acceptance
    IF nvl(OE_SYS_PARAMETERS.VALUE('ENABLE_FULFILLMENT_ACCEPTANCE'), 'N') = 'Y' THEN

       OE_Line_Util.Query_Row(p_line_id => p_line_id,x_line_rec => l_line_rec);

           -- need to check if the line is accepted when re-tried from progress order action
         IF ((l_line_rec.flow_status_code='POST-BILLING_ACCEPTANCE' OR OE_ACCEPTANCE_UTIL.Post_billing_acceptance_on (l_line_rec))
                   AND OE_ACCEPTANCE_UTIL.Acceptance_Status(l_line_rec) = 'NOT_ACCEPTED')
              AND nvl(l_line_rec.cancelled_flag,'N') = 'N'  THEN

           -- added following for bug# 5232503
           -- If it is a child line then check if the parent is accepted.
           -- Do not wait for acceptance if parent is already accepted.                    -- This check is added to make sure that child line won't get stuck
           -- if the system parameter is changed from yes to no to yes again.
           IF ((l_line_rec.top_model_line_id is not null
              AND l_line_rec.line_id <>  l_line_rec.top_model_line_id
              AND OE_ACCEPTANCE_UTIL.Acceptance_Status(l_line_rec.top_model_line_id) = 'ACCEPTED')
              OR
              (l_line_rec.item_type_code = 'SERVICE'
              AND l_line_rec.service_reference_type_code='ORDER'
              AND l_line_rec.service_reference_line_id IS NOT NULL
              AND OE_ACCEPTANCE_UTIL.Acceptance_Status(l_line_rec.service_reference_line_id) = 'ACCEPTED')) THEN
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('acceptance not required. item_type:'||l_line_rec.item_type_code);
              END IF;
           ELSE
                 l_pending_acceptance:= 'Y';
           END IF;
         END IF;
    END IF;

    --Customer Acceptance

    --
    -- Bug # 4454055
    -- Close_Line is changed to call the costing API to move COGS account from
    -- deferred to actual account for the order lines that need to notify costing
    --

   IF oe_cogs_grp.is_revenue_event_line(p_line_id) = 'Y' AND l_pending_acceptance = 'N' THEN

            SELECT inventory_item_id, org_id
             INTO l_inventory_item_id, l_org_id
              FROM oe_order_lines_all
                WHERE line_id = p_line_id;


      cst_revenuecogsmatch_grp.receive_closelineevent (
		p_api_version            =>  1.0,
		p_init_msg_list          =>  FND_API.G_FALSE,
		p_commit                 =>  FND_API.G_FALSE,
		p_validation_level	 =>  FND_API.G_VALID_LEVEL_FULL,
		x_return_status          =>  l_return_status,
		x_msg_count		 =>  x_msg_count,
		x_msg_data		 =>  x_msg_data,
		p_revenue_event_line_id	 =>  p_line_id,
		p_event_date             =>  SYSDATE,
		p_ou_id			 =>  l_org_id,
		p_inventory_item_id	 =>  l_inventory_item_id);

        END IF;

	-- Check Return status and error handling
	-- Costing will raise an error if required parameters are not passed
	-- Also if there is any unexpected error, close line workflow activity would be in
	-- Incomplete status and will rerun automatically, we will mark the flow_status_code
	-- as 'NOTIFY_COSTING_ERROR';

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

	        UPDATE oe_order_lines_all
		   SET flow_status_code='NOTIFY_COSTING_ERROR'
		   WHERE line_id = p_line_id;
 	           x_return_status := l_return_status;
                   --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               return;
        END IF;


    -- Check whether we need to call Process_Requests_And_Notify.

    IF ( (OE_GLOBALS.G_RECURSION_MODE = 'Y') AND
         (OE_GLOBALS.G_EC_INSTALLED <> 'Y') AND
         (OE_GLOBALS.G_ASO_INSTALLED <> 'Y') AND
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'N')  )
    THEN
       --Customer Acceptance
       IF l_pending_acceptance = 'Y' THEN

	    UPDATE oe_order_lines
	       SET  flow_status_code    = 'POST-BILLING_ACCEPTANCE'
		    , last_updated_by     = NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID)
		    , last_update_login   = FND_GLOBAL.LOGIN_ID
		    , last_update_date    = SYSDATE
	     , lock_control        = l_old_line_tbl(1).lock_control + 1
	     WHERE line_id       = p_line_id;

-- Added for bug 5988559
        IF SQL%NOTFOUND THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORG CONTEXT is not properly set for'||p_line_id , 1) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        END IF;
       ELSE
       --Customer Acceptance
        UPDATE oe_order_lines
        SET open_flag           = 'N'
          , calculate_price_flag = 'N'
          , flow_status_code    = DECODE(l_old_line_tbl(1).cancelled_flag,'Y',
                                  'CANCELLED','CLOSED')
          , last_updated_by     = NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID) -- 3169637
          , last_update_login   = FND_GLOBAL.LOGIN_ID
          , last_update_date    = SYSDATE
          , lock_control        = l_old_line_tbl(1).lock_control + 1
         WHERE line_id       = p_line_id;

-- Added for bug 5988559
        IF SQL%NOTFOUND THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORG CONTEXT is not properly set for'||p_line_id , 1) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        END IF;


      END IF;

    ELSE
      --Customer Acceptance Start
       IF l_pending_acceptance= 'Y' THEN

            l_line_tbl(1)                       := l_old_line_tbl(1);
            l_line_tbl(1).flow_status_code      := 'POST-BILLING_ACCEPTANCE';
            l_line_tbl(1).last_updated_by       := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID);
            l_line_tbl(1).last_update_login     := FND_GLOBAL.LOGIN_ID;
            l_line_tbl(1).last_update_date      := SYSDATE;
            l_line_tbl(1).lock_control          := l_line_tbl(1).lock_control + 1;
       ELSE
     --Customer Acceptance End
	    l_line_tbl(1)					:= l_old_line_tbl(1);
	    l_line_tbl(1).open_flag   		:= 'N';
            l_line_tbl(1).calculate_price_flag      := 'N';
	    IF l_line_tbl(1).cancelled_flag = 'Y' THEN
		    l_line_tbl(1).flow_status_code	:= 'CANCELLED';
	    ELSE
		    l_line_tbl(1).flow_status_code 	:= 'CLOSED';
	    END IF;
	    l_line_tbl(1).last_updated_by := NVL(OE_STANDARD_WF.g_user_id, FND_GLOBAL.USER_ID);
	    l_line_tbl(1).last_update_login	:= FND_GLOBAL.LOGIN_ID;
	    l_line_tbl(1).last_update_date	:= SYSDATE;
	    l_line_tbl(1).lock_control         := l_line_tbl(1).lock_control + 1;
         END IF;

        UPDATE oe_order_lines
	    SET open_flag 			= l_line_tbl(1).open_flag
          , calculate_price_flag = l_line_tbl(1).calculate_price_flag
	      , flow_status_code 	= l_line_tbl(1).flow_status_code
	      , last_updated_by		= l_line_tbl(1).last_updated_by
	      , last_update_login	= l_line_tbl(1).last_update_login
	      , last_update_date	= l_line_tbl(1).last_update_date
	      , lock_control         = l_line_tbl(1).lock_control
	    WHERE line_id 		= p_line_id;

-- Added for bug 5988559
        IF SQL%NOTFOUND THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ORG CONTEXT is not properly set for'||p_line_id , 1) ;
          END IF;
          RAISE FND_API.G_EXC_ERROR;

        END IF;


	-- jolin start
	IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

	-- call notification framework to get this line's index position
	OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_line_rec		=> l_line_tbl(1)
	, p_old_line_rec	=> l_old_line_tbl(1)
        , p_line_id 		=> l_line_tbl(1).line_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RET_STATUS FOR LINE_ID '||L_LINE_TBL ( 1 ) .LINE_ID ||' IS: ' || X_RETURN_STATUS , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL INDEX FOR LINE_ID '||L_LINE_TBL ( 1 ) .LINE_ID ||' IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   IF l_notify_index is not null then
     -- modify Global Picture
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).open_flag:=	l_line_tbl(1).open_flag;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).calculate_price_flag:= l_line_tbl(1).calculate_price_flag;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).flow_status_code:=l_line_tbl(1).flow_status_code;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_updated_by:=	l_line_tbl(1).last_updated_by;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_login:=l_line_tbl(1).last_update_login;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).last_update_date:=l_line_tbl(1).last_update_date;
    OE_ORDER_UTIL.g_line_tbl(l_notify_index).lock_control:=	l_line_tbl(1).lock_control;

			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL LINE OPEN_FLAG IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .OPEN_FLAG , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL LINE CALCULATE_PRICE_FLAG IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .CALCULATE_PRICE_FLAG , 1 ) ;
			END IF;
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'GLOBAL LINE FLOW_STATUS_CODE IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_NOTIFY_INDEX ) .FLOW_STATUS_CODE , 1 ) ;
			END IF;


	-- Process requests is TRUE, but don't need to notify
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
	    OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests	=> TRUE
		, p_notify		=> FALSE
		, p_process_ack		=> FALSE
		, x_return_status	=> x_return_status
		, p_line_tbl		=> l_line_tbl
		, p_old_line_tbl	=> l_old_line_tbl
		);
	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
          END IF ; /* global entity index null check */

	ELSE /* in pre-pack H code */

	-- Need to both notify and process requests in old framework
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
      END IF;
	    OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests	=> TRUE
		, p_notify		=> TRUE
		, p_process_ack		=> FALSE
		, x_return_status	=> x_return_status
		, p_line_tbl		=> l_line_tbl
		, p_old_line_tbl	=> l_old_line_tbl
		);
	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		    RAISE FND_API.G_EXC_ERROR;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
	END IF; /* code set is pack H or higher */
	-- jolin end

    END IF; -- we should notify after we update

    IF l_pending_acceptance = 'Y' THEN
       x_return_status := 'C';
    END IF;

    --Customer Acceptance
    IF l_pending_acceptance = 'N' THEN
       DELETE_ADJUSTMENTS(p_line_id => p_line_id);
       OE_MSG_PUB.Reset_Msg_Context('LINE');
    END IF;

    /********************GENESIS********************************
    *  Some statuses are not going through process order and   *
    *  the update_flow_status is getting called directly. So   *
    *  we need to call synch_header_line for 28                *
    ***********************************************************/
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE  - header rec order source'||p_line_id);
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE - line rec order source'||l_line_tbl(1).order_source_id);
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE - old line rec order source'||l_old_line_tbl(1).order_source_id);
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE - old line rec order source'||l_line_tbl(1).order_source_id);
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE - new line rec flow status'||l_line_tbl(1).flow_status_code);
       oe_debug_pub.add(  ' GENESIS : CLOSE LINE - old line rec flow status'||l_old_line_tbl(1).flow_status_code);
    END IF;
    IF (OE_GENESIS_UTIL.source_aia_enabled(l_old_line_tbl(1).order_source_id)) THEN
      -- 8516700 (O2C2.5): Start
      IF Oe_Genesis_Util.Status_Needs_Sync(l_line_tbl(1).flow_status_code) THEN
      -- 8516700 (O2C2.5): End
        OE_Header_UTIL.Query_Row
            (p_header_id            => l_old_line_tbl(1).header_id
            ,x_header_rec           => l_header_rec
            );

        select OE_XML_MESSAGE_SEQ_S.nextval
	      into l_itemkey_sso
	      from dual;
	      IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  ' GENESIS  : CLOSE LINE - l_itemkey_sso'||l_itemkey_sso);
	      END IF;

	      OE_SYNC_ORDER_PVT.INSERT_SYNC_lINE(P_LINE_rec       => l_line_tbl(1),
	                                         p_change_type   => 'LINE_STATUS',
	  	                                     p_req_id        => l_itemkey_sso,
		                                       X_RETURN_STATUS => L_RETURN_STATUS_GEN);

          IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' GENESIS :CLOSE LINE:  RETURN STATUS'||l_return_status_gen);
	      END IF;

	      IF l_return_status_gen = FND_API.G_RET_STS_SUCCESS THEN
	         OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE( p_header_rec          => l_header_rec
	                                            ,p_line_rec            => l_line_tbl(1) -- Bug 8442372
	                                            ,p_hdr_req_id          => l_itemkey_sso
	                                            ,p_lin_req_id          => l_itemkey_sso
	                                            ,p_change_type         => 'LINE_STATUS');
	      END IF;

        END IF; -- status_needs_sync
	  END IF; -- source_aia_enabled
	-- GENESIS

EXCEPTION
    WHEN ON_HOLD_ERROR THEN
	   x_return_status := 'H';
           OE_MSG_PUB.Reset_Msg_Context('LINE');
	   ROLLBACK TO CLOSE_LINE;
    WHEN FND_API.G_EXC_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           OE_MSG_PUB.Reset_Msg_Context('LINE');
	   ROLLBACK TO CLOSE_LINE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           OE_MSG_PUB.Reset_Msg_Context('LINE');
	   ROLLBACK TO CLOSE_LINE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Close_Line'
                        );
        END IF;
           OE_MSG_PUB.Reset_Msg_Context('LINE');
	   ROLLBACK TO CLOSE_LINE;
END CLOSE_LINE;

END OE_ORDER_CLOSE_UTIL;

/
