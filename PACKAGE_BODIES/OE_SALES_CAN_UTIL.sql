--------------------------------------------------------
--  DDL for Package Body OE_SALES_CAN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SALES_CAN_UTIL" AS
/* $Header: OEXUCANB.pls 120.11.12010000.7 2010/04/14 10:06:35 spothula ship $ */

--  Start of Comments
--  API name    OE_SALES_CAN_UTIL
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

--g_ord_lvl_can boolean := FALSE; Commented for bug# 2922468
g_par_ord_lvl_can boolean := FALSE; -- Introduced this variable to fix bug 2230777
g_ser_cascade boolean := FALSE;

Procedure PerformLineCancellation(P_line_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
				  p_line_old_tbl IN OE_ORDER_PUB.LINE_TBL_TYPE,
x_return_status OUT NOCOPY VARCHAR2);


Procedure UpdateLine
          (p_line_id           In  Number
          ,p_ordered_quantity  In  Number
          ,p_change_reason     In Varchar2
          ,p_change_comments   In Varchar2
,x_return_status out nocopy Varchar2

,x_msg_count out nocopy Number

,x_msg_data out nocopy Varchar2)

Is
l_api_name                    VARCHAR2(30) := 'UPDATELINE';
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_line_rec                    OE_Order_PUB.Line_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SALES_CAN_UTIL.UPDATE_LINE' ) ;
  END IF;

  --  Set control flags.

  l_control_rec.controlled_operation := TRUE;
  l_control_rec.change_attributes    := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.write_to_DB          := TRUE;
  l_control_rec.default_attributes   := FALSE;
  l_control_rec.process              := TRUE;

  --  Instruct API to retain its caches

  l_control_rec.clear_api_cache      := FALSE;
  l_control_rec.clear_api_requests   := FALSE;

  --  Read line from cache

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING LOCK ROW' ) ;
  END IF;

  /* Fix for Bug 1763178. Passing line record instead of table. */

  OE_Line_Util.lock_Row
      ( p_line_id      => p_line_id,
       p_x_line_rec    => l_line_rec
      ,x_return_status => l_return_status
      );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING LOCK ROW' ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_line_tbl(1) := l_line_rec;
  l_line_tbl(1).db_flag := FND_API.G_TRUE;

  l_old_line_tbl(1) := l_line_tbl(1);

  l_line_tbl(1).ordered_quantity := p_ordered_quantity;

  /*lchen fix bug 1879607. Passing input parameters instead of line record*/

  l_line_tbl(1).change_reason := p_change_reason;
  l_line_tbl(1).change_comments := p_change_comments;

  --  Set Operation.
  l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

  --  Populate line table

  --  Call OE_Order_PVT.Process_order
  g_ser_cascade := TRUE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER' ) ;
  END IF;

  oe_order_pvt.Lines
  (   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
  ,   p_control_rec       => l_control_rec
  ,   p_x_line_tbl         =>  l_line_tbl
  ,   p_x_old_line_tbl    =>  l_old_line_tbl
  ,   x_return_status     => l_return_status
  );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER' ) ;
  END IF;

/* jolin start comment out nocopy for notification project

    -- API to call notify_oc and ack and to process delayed requests
OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        oe_debug_pub.ADD('Update Line Process Order return UNEXP_ERROR');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        oe_debug_pub.ADD('Update Line Process Order return RET_STS_ERROR');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
jolin end */

  g_ser_cascade := FALSE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.UPDATE_LINE' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         g_ser_cascade := FALSE;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            oe_msg_pub.Add_Exc_Msg
            (G_PKG_NAME
             ,l_api_name);
         END IF;
         g_ser_cascade := FALSE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
         g_ser_cascade := FALSE;
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || L_API_NAME ) ;
                       END IF;
        IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           oe_msg_pub.Add_Exc_Msg
           (G_PKG_NAME
            ,l_api_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END UpdateLine;

PROCEDURE perform_line_change
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_api_name            VARCHAR2(30):= 'Perform_line_change';
l_line_id             NUMBER;
l_line_ind            NUMBER;
l_return_status       VARCHAR2(30);
l_result              VARCHAR2(30);
--l_pending_rec       OE_CHG_ORDER_PVT.G_Pending_Request_REC_Type;
l_msg_count           NUMBER;
l_msg_data 	      VARCHAR2(240);
l_entity_id           NUMBER;
l_entity_code 	      VARCHAR2(1) := 'O';
l_line_process_name   VARCHAR2(30);
l_hold_release_rec    OE_HOLD_SOURCES_PVT.HOLD_RELEASE_REC;
l_cancelled_qty       NUMBER;
lhisttypecode         VARCHAR2(240);
l_fulfill             VARCHAR2(30);
l_order_tbl           OE_HOLDS_PVT.order_tbl_type;
l_hold_id             OE_HOLD_DEFINITIONS.HOLD_ID%TYPE;
l_release_reason_code OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE;
l_release_comment     OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE;

-- INVCONV
l_cancelled_qty2       NUMBER; -- INVCONV

-- This is moved to pre write to cover all quantity changes
po_result             BOOLEAN;
po_supply_id          NUMBER;
po_header_id	      NUMBER;  --Bug 5335066

l_is_ota_line         BOOLEAN;
l_order_quantity_uom  VARCHAR2(3);
l_mtl_supply_quantity NUMBER;                 -- 6710187

-- We do not need this cursor since we started storing REQUISITION_LINE_ID in
-- source_document_line_id.
/*cursor poreq is
             SELECT  PRL.REQUISITION_LINE_ID
             FROM    PO_REQUISITION_LINES PRL,
                     PO_REQUISITION_HEADERS PRH
             WHERE   PRH.SEGMENT1 = p_line_rec.source_document_id
             AND     PRL.LINE_NUM =  p_line_rec.source_document_line_id
             AND     PRL.REQUISITION_HEADER_ID =PRH.REQUISITION_HEADER_ID;*/

l_require_reason      BOOLEAN;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- bug2743789 if cancellation is defined at entered level and audit parameter
-- defined at booked orders only, then cancel history record would be inserted
-- without reason code.

IF l_debug_level > 0 THEN
   OE_DEBUG_PUB.add('Entering perform_line_change() with reason required flag : '||OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG,1);
END IF;

l_order_quantity_uom := p_line_rec.order_quantity_uom;		--bug 5702849
oe_debug_pub.add('5702849:	Value of l_order_quantity_uom :'||l_order_quantity_uom);

IF  (p_line_rec.operation <> oe_globals.g_opr_create AND
--     p_line_rec.split_action_code <> 'SPLIT') THEN  -- Bug 8841055
     Nvl(p_line_rec.split_action_code,Fnd_Api.G_Miss_Char) <> 'SPLIT') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Entering oe_sales_can_util.perform_line_change' ) ;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (nvl(p_line_rec.ordered_quantity, 0) < nvl(p_old_line_rec.ordered_quantity, 0)) THEN
        l_cancelled_qty := nvl(p_old_line_rec.ordered_quantity, 0) - nvl(p_line_rec.ordered_quantity, 0);
        IF (oe_sales_can_util.G_REQUIRE_REASON) THEN
            lhisttypecode := OE_GLOBALS.G_CAN_HIST_TYPE_CODE;
        ELSE
            lhisttypecode := 'QUANTITY UPDATE';
        END IF;
    ELSIF (nvl(p_line_rec.ordered_quantity, 0) > nvl(p_old_line_rec.ordered_quantity, 0)) THEN
        lhisttypecode := 'QUANTITY UPDATE';
    END IF;

-- INVCONV
		IF (nvl(p_line_rec.ordered_quantity2, 0) < nvl(p_old_line_rec.ordered_quantity2, 0)) THEN
        l_cancelled_qty2 := nvl(p_old_line_rec.ordered_quantity2, 0) - nvl(p_line_rec.ordered_quantity2, 0);
        IF (oe_sales_can_util.G_REQUIRE_REASON) THEN
            lhisttypecode := OE_GLOBALS.G_CAN_HIST_TYPE_CODE;
        ELSE
            lhisttypecode := 'QUANTITY UPDATE';
        END IF;
    ELSIF (nvl(p_line_rec.ordered_quantity2, 0) > nvl(p_old_line_rec.ordered_quantity2, 0)) THEN
        lhisttypecode := 'QUANTITY UPDATE';
    END IF;


    -- Update Service Lines
    /*
    ** Fix bug # 2126033
    ** update service not called when order is being cancelled.
    if NOT(g_ord_lvl_can) then
    */

    /*
    ** Fix Bug # 2157850
    ** Store the g_require_reason global before calling update
    ** service and restore after that.
    */
    l_require_reason := oe_sales_can_util.g_require_reason;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Before calling update_service()',1) ;
    END IF;

    update_service(p_line_rec, p_old_line_rec, x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('After calling update_service , return status : '||x_return_status,1) ;
    END IF;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
       if x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
       else
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    oe_sales_can_util.g_require_reason := l_require_reason ;

    -- end if; -- Not Order Level Cancellation.
    -- This code is moved to pre write to cover all quantity changes
    -- call PO if its Internal requistion


/* 7576948: IR ISO Change Management project Start */
/* -- This code is commented for IR ISO project, as from this project onwards
   -- there will not be any descrepancy between the OM and Purchasing for
   -- partial internal sales order line cancellation, createed as part of
   -- system split after partial shipping against the original internal sales
   -- order line. From this project, onwards, if an internal sales order line
   -- is cancelled, it will log a OE_GLOBALS.G_UPDATE_REQUISITION delayed
   -- request, whose execution will call the Puchasing API
   -- PO_RCO_Validation_GRP.Update_ReqCancel_from_SO(). It will be this
   --  purchasing API responsibility to update the MTL_Supply table for
   -- quantity change in internal sales order line.

   -- For details on IR ISO CMS project, please refer to FOL >
   -- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc



    IF p_line_rec.source_document_type_id = 10 THEN
       IF (nvl(p_line_rec.ordered_quantity,0) < nvl(p_old_line_rec.ordered_quantity,0)) THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Qty reduced on internal order',1);
          END IF;

          po_supply_id := p_line_rec.source_document_line_id;
	  po_header_id := p_line_rec.source_document_id; --Bug 5335066
	  --l_order_quantity_uom := p_line_rec.order_quantity_uom; --Bug 5335066 [Moved the initialization outside the condition.]

          IF po_supply_id IS NOT NULL THEN

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SUPPLY ID EXISTS , BEFORE CALLING PO_SUPPLY.PO_REQ_SUPPLY ( ) ' ) ;
             END IF;
-- INVCONV no requirement to change this

	     IF  p_line_rec.split_from_line_id IS NOT NULL THEN        -- 6710187 start

	       	BEGIN
	       	   SELECT quantity
	             INTO l_mtl_supply_quantity
	             FROM mtl_supply
	            WHERE req_line_id = p_line_rec.source_document_line_id
	              AND supply_type_code = 'REQ';

	        EXCEPTION
	           WHEN NO_DATA_FOUND THEN
	              NULL;
	           WHEN TOO_MANY_ROWS THEN
	              fnd_message.set_name('ONT','OE_CAN_UPDATE_SUPPLY');
	              oe_msg_pub.add;
	              raise FND_API.G_EXC_ERROR;
	        END;

	        IF p_old_line_rec.ordered_quantity <> l_mtl_supply_quantity THEN

	           fnd_message.set_name('ONT','OE_CAN_UPDATE_SUPPLY');
	           oe_msg_pub.add;
	           raise FND_API.G_EXC_ERROR;
	        END IF;

             END IF;                                                -- 6710187 end

             po_result := po_supply.po_req_supply(  --Bug 5335066
                         p_docid         => po_header_id,
                         p_lineid        => po_supply_id,
                         p_shipid        => NULL,
                         p_action        => 'Update_Req_Line_Qty',
                         p_recreate_flag => FALSE,
                         p_qty           => p_line_rec.ordered_quantity,
                         p_receipt_date  => null,
			 p_reservation_action=>'UPDATE_SO_QUANTITY',
			 p_ordered_uom	 => l_order_quantity_uom);
             --p_reservation_action added for bug4277603

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('After calling po_supply.po_req_supply()',1);
             END IF;

        END IF;

        IF  po_supply_id IS NULL THEN
          fnd_message.set_name('ONT','OE_CAN_NO_SUPPLY_ID');
          oe_msg_pub.add;
             --  raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF; -- For cancellation

*/
/* IR ISO Change Management project End */


    IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.add('Audit Trail Reason Required Flag : '||OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG,1);
        oe_debug_pub.add('Line change reason : '||p_line_rec.change_reason,1);
    END IF;

    -- #2743789 changes
    IF oe_sales_can_util.G_REQUIRE_REASON THEN

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Change reason required',1);
       END IF;

      --Commented out hre following block of code for bug #3665150
      /* IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN -- reinstated for 2653505

          IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'N' THEN
             IF p_line_rec.change_reason IS NULL OR
                p_line_rec.change_reason = FND_API.G_MISS_CHAR THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Cancellation Reason is Not Provided',1);
                END IF;
                fnd_message.set_name('ONT','OE_CAN_REASON_NOT');
                oe_msg_pub.add;
                raise FND_API.G_EXC_ERROR;
             END IF;
          END IF;

       ELSE.*/
          IF p_line_rec.change_reason IS NULL OR
             p_line_rec.change_reason = FND_API.G_MISS_CHAR THEN
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Cancellation Reason is Not Provided',1);
             END IF;
             fnd_message.set_name('ONT','OE_CAN_REASON_NOT');
             oe_msg_pub.add;
             raise FND_API.G_EXC_ERROR;
          END IF;
      -- END IF;
    END IF;

    IF p_line_rec.change_reason IS NOT NULL AND p_line_rec.change_reason <> FND_API.G_MISS_CHAR THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Before calling record line history',5);
      END IF;

       --11.5.10 Versioning/Audit Trail updates
       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                           p_entity_id => p_line_rec.line_id,
                                           p_hist_type_code => lhisttypecode);
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_line_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                                   p_requesting_entity_id => p_line_rec.line_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
      ELSE
           OE_CHG_ORDER_PVT.RecordLineHist
                        ( p_line_id          => p_line_rec.line_id
                        , p_line_rec         => p_line_rec
                        , p_hist_type_code   => lhisttypecode
                        , p_reason_code      => p_line_rec.change_reason
                        , p_comments         => p_line_rec.change_comments
                        , p_wf_activity_code => 'OEOL_CANCEL'
                        , p_wf_result_code   => 'COMPLETE'
                        , x_return_status    => l_return_status);

      END IF;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('After calling record line history',5);
      END IF;

    END IF;

    -- Call OTA API for training lines that are cancelled.

    --l_order_quantity_uom := p_line_rec.order_quantity_uom;  Moved up before the call to po_supply.po_req_supply
    l_is_ota_line := OE_OTA_UTIL.Is_OTA_Line(l_order_quantity_uom);

    If (l_is_ota_line) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'JPN: IT IS A OTA LINE' , 1 ) ;
      END IF;

      IF p_line_rec.ordered_quantity = 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JPN: BEFORE CALLING NOTIFY_OTA' , 1 ) ;
        END IF;

        oe_ota_util.Notify_OTA(
                               p_line_id => p_line_rec.line_id,
                               p_org_id  => p_line_rec.org_id,
                               p_order_quantity_uom => l_order_quantity_uom,
                               p_daemon_type => 'C',
                               x_return_status => l_return_status);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JPN: AFTER CALLING NOTIFY_OTA' , 1 ) ;
        END IF;

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          if l_return_status = FND_API.G_RET_STS_ERROR then
            RAISE FND_API.G_EXC_ERROR;
          else
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          end if;
        end if;
      end if;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'JPN: NOT A OTA LINE' , 1 ) ;
      END IF;
    end if;

    -- Call to Remove from fullfillment sets
    IF (oe_sales_can_util.G_REQUIRE_REASON) THEN
      If p_line_rec.ordered_quantity = 0 then

        -- Remove from fulfillment sets

        --oe_set_util.Remove_from_fulfillment(p_line_id => p_line_rec.line_id);
        -- added the following IF condition to fix bug 2230777
        -- using OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can for bug# 2922468
        if NOT(OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can) and NOT(g_par_ord_lvl_can)then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BEFORE CALLING OE_LINE_FULLFILL.CANCEL_LINE ( ) ' ) ;
          END IF;

          oe_line_fullfill.cancel_line(p_line_id => p_line_rec.line_id,
                                       x_return_status => l_return_status);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
            if l_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
            else
	      raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
          end if;
        end if;

        oe_set_util.Remove_from_fulfillment(p_line_id => p_line_rec.line_id);

      End if;

      /*
      ** Recommented for clarity. WF activity is progressed in OEXULINB.pls

      Abort Wf activities
      OE_STANDARD_WF.Get_LineProcessName(OE_GLOBALS.G_WFI_LIN, p_line_rec.line_id,
      l_line_process_name);

      If p_line_rec.ordered_quantity = 0 then
        wf_engine.abortprocess(OE_Globals.G_WFI_LIN
 				,to_char(p_line_rec.line_id)
 				,l_line_process_name);
        OE_DEBUG_PUB.ADD('Calling Wf Handle Error ');
        Using Retry option to run close activity
        OE_GLOBALS.G_RECURSION_MODE := 'Y';
        wf_engine.handleerror(OE_Globals.G_WFI_LIN
 				,to_char(p_line_rec.line_id)
 		        	,'CLOSE_LINE',
 				'RETRY','CANCEL');
        OE_DEBUG_PUB.ADD('After Calling Wf Handle Error ');
        NULL;
        OE_GLOBALS.G_RECURSION_MODE := 'N';
      end if;
      */

      --  Release Holds

      IF p_line_rec.ordered_quantity = 0 THEN

        l_order_tbl(1).line_id := p_line_rec.line_id;
        l_release_reason_code  := 'OM_CANCEL';

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING RELEASE HOLDS' ) ;
        END IF;

        OE_Holds_pub.release_holds(
          p_order_tbl            =>  l_order_tbl,
          p_release_reason_code  =>  l_release_reason_code,
          p_release_comment      =>  l_release_comment,
          p_hold_id              =>  Null,
          x_return_status        =>  l_return_status,
          x_msg_count            =>  l_msg_count,
          x_msg_data             =>  l_msg_data);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING RELEASE HOLDS :' || L_RETURN_STATUS ) ;
        END IF;

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          if l_return_status = FND_API.G_RET_STS_ERROR then
            raise FND_API.G_EXC_ERROR;
          else
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          end if;
        end if;
      End if; -- Rlease holds

    end if;
  END IF;

  --oe_sales_can_util.g_require_reason := FALSE;

   -- If the ordered quantity  is Zero then a delayed request is logged

  IF p_line_rec.ordered_quantity = 0 THEN

      oe_delayed_requests_pvt.log_request(
                p_entity_code                => OE_GLOBALS.G_ENTITY_ALL,
                p_entity_id                  => p_line_rec.header_id,
                p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_ALL,
                p_requesting_entity_id       => p_line_rec.header_id,
                p_request_type               => OE_GLOBALS.G_DELETE_CHARGES,
                x_return_status              => l_return_status);

  End if;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.PERFORM_LINE_CHANGE' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            oe_msg_pub.Add_Exc_Msg
            (G_PKG_NAME
             ,l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || 'PERFORM_LINE_CHANGE' ) ;
                       END IF;
        IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           oe_msg_pub.Add_Exc_Msg
           (G_PKG_NAME
            ,l_api_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Perform_Line_change;

-- Comment Label for procedure added as part of Inline Documentation Drive.
---------------------------------------------------------------------------------
-- Procedure Name : Check_Constraints
-- Input Params   : p_x_line_rec        : Current Line Record.
--                  p_old_line_rec      : Old Line Record.
-- Output Params  : x_return_status     : Return Status from the procedure.
--                : p_x_line_rec        : Current Line Record.
-- Description    : This procedure does various checks during Line Cancellation
--                  flow or during reducing the ordered_quantity on sales order
--                  line. Checks are like, Updating quantity on Service Lines
--                  not allowed, or setting qty to zero on Booked order not
--                  allowed, and processing of Cancelled Quantities and Flags
--                  if the flow is a cancellation flow.
--                  This procedure is called from OE_HEADER_UTIL(OEXUHDRB.pls)
--                  and OE_LINE_UTIL(OEXULINB.pls), for checking constraints
--                  on cancellation and calculating Cancelled Quantities
--                  for Cancellation flows, or for other flows where secondary
--                  Cancelled quantities need to be populated.
---------------------------------------------------------------------------------

PROCEDURE check_constraints
( p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY varchar2

)
IS
l_return_status       VARCHAR2(30) :=FND_API.G_RET_STS_SUCCESS;
--l_line_Rec          oe_order_pub.line_rec_type := p_line_Rec;
x_result              NUMBER := 0 ;
x_msg_count           NUMBER;
x_msg_data            VARCHAR2(255);
l_api_name            VARCHAR2(30):= 'Check_Constraints';

l_item_rec  OE_ORDER_CACHE.item_rec_type; -- INVCONV
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  --	x_line_Rec := p_line_Rec;
  IF (p_x_line_rec.operation <> oe_globals.g_opr_create AND
      nvl(p_x_line_rec.split_action_code,'X') <> 'SPLIT') THEN
  --	OE_SALES_CAN_UTIL.G_REQUIRE_REASON := FALSE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SALES_CAN_UTIL.CHECK_CONSTRAINTS' ) ;
  END IF;
  --	initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CHECKING CONSTRAINTS FOR LINE ID '|| TO_CHAR ( P_X_LINE_REC.LINE_ID ) ) ;
  END IF;

  if ( p_old_line_rec.cancelled_flag = 'Y') then
    fnd_message.set_name('ONT', 'OE_CANCEL_NOTHING');
    oe_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR ;
  end if;

  -- Check if line is booked and and is not a cancellations and orderquantity is
  -- zero
  -- This is to fix the order level status problem. If the call is made
  -- from order level it will treated as cancellation always
  -- using OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can for bug# 2922468
  IF OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can THEN
      OE_SALES_CAN_UTIL.G_REQUIRE_REASON := TRUE;
  END IF;

  IF NOT OE_SALES_CAN_UTIL.G_REQUIRE_REASON THEN

    IF (nvl(p_x_line_rec.booked_flag,'N') = 'Y' AND
        nvl(p_x_line_rec.ordered_quantity,0) = 0 ) THEN

      fnd_message.set_name('ONT', 'OE_QTY_ZERO_NOT_ALLOWED');
      oe_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
  END IF;

  -- Check Service here. We allow only full cancellation of service
  -- if service alone is updated.

  if (p_x_line_rec.ITEM_TYPE_CODE = 'SERVICE') AND
      NOT (g_ser_cascade) AND
      (p_x_line_rec.Ordered_Quantity <> 0)   then

    if (p_x_line_rec.Ordered_Quantity <>
        p_old_line_rec.Ordered_Quantity) THEN
      fnd_message.set_name('ONT', 'OE_CAN_SERV_AMT_NOT_ALLOWED');
      oe_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- Set Ordered level cancellation to true or false
  -- using OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can for bug# 2922468
  IF OE_SALES_CAN_UTIL.G_REQUIRE_REASON AND OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can   THEN

    oe_sales_can_util.g_order_cancel := TRUE;
  ELSE
    IF oe_sales_can_util.g_order_cancel THEN
         oe_sales_can_util.g_order_cancel := FALSE;
    END IF;
  END IF;

  -- Compute Cancelled Quantity
  -- Compute Cancelled Quantity2
  -- invconv

  -- Bug 7679175 Start
  -- Moved this condition here, since Cancelled_Quantity2 should
  -- only be calculated when Cancelled_Quantity is calculated.

  IF OE_SALES_CAN_UTIL.G_REQUIRE_REASON THEN


    IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IN CHANGE REASON REQUIRED' ) ;
    END IF;

    IF p_x_line_rec.change_reason IS  NULL THEN
        /*fnd_message.set_name('ONT','OE_CAN_REASON_NOT');
        oe_msg_pub.add;*/
        NULL;
    END IF;

  -- Bug 7679175 End

    IF oe_line_util.dual_uom_control   -- INVCONV  Process_Characteristics
  		(p_x_line_rec.inventory_item_id,p_X_line_rec.ship_from_org_id,l_item_rec) THEN
  				IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV
       			if l_debug_level > 0 then
							oe_debug_pub.add(' Get dual uom - tracking in P and S ');
       			end if;


						IF l_debug_level  > 0 THEN
      			  oe_debug_pub.add(  'BEFORE CALLING CAL_CANCELLED_QTY2' ) ;
    				END IF;

    				p_x_line_rec.cancelled_quantity2 :=oe_sales_can_util.Cal_cancelled_qty2(
                        p_x_line_rec,
                        p_old_line_rec);

    				IF l_debug_level  > 0 THEN
        				oe_debug_pub.add(  'CANCELLED QUANTITY2 IS '||P_X_LINE_REC.CANCELLED_QUANTITY2 ) ;
    				END IF;

    			END IF; -- IF l_item_rec.tracking_quantity_ind = 'PS'

    END IF; --  IF oe_line_util.dual_uom_control

    -- Bug 7679175 Start
    -- Moving this condition to before calculating Cancelled_Quantity2, since it should
    -- only be calculated when Cancelled_Quantity is calculated.
    /*
       IF OE_SALES_CAN_UTIL.G_REQUIRE_REASON THEN


    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'IN CHANGE REASON REQUIRED' ) ;
    	END IF;

    	IF p_x_line_rec.change_reason IS  NULL THEN
    	  fnd_message.set_name('ONT','OE_CAN_REASON_NOT');
    	  oe_msg_pub.add;
    	  NULL;
    	END IF;
    */
    -- Bug 7679175 End


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING CAL_CANCELLED_QTY' ) ;
    END IF;

    p_x_line_rec.cancelled_quantity :=oe_sales_can_util.Cal_cancelled_qty(
                        p_x_line_rec,
                        p_old_line_rec);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CANCELLED QUANTITY IS '||P_X_LINE_REC.CANCELLED_QUANTITY ) ;
    END IF;




    --Set cancelled flag and open flag if complete cancellation
    IF p_x_line_rec.ordered_quantity = 0 THEN
      /* NC - Added for OPM 04/23/01 Bug#1749562  */

      IF(p_x_line_rec.ordered_quantity2 IS NOT NULL AND
         p_x_line_rec.ordered_quantity2 <> 0 ) THEN

         p_x_line_rec.ordered_quantity2 := 0;

      END IF;
      /* End of OPM changes. */

-- Reverted the changes to take care of P1 issues

      p_x_line_rec.cancelled_flag := 'Y';

      /*
      ** Fix Bug # 2238002:
      ** Following columns are updated when WF Handle error is called.
      p_x_line_rec.open_flag := 'N';
      p_x_line_rec.flow_status_code := 'CANCELLED';
      */

    END IF;





  ELSIF p_x_line_rec.ordered_quantity > p_old_line_rec.ordered_quantity THEN

    -- bug 3542477, must calculate cancelled quantity in case user
    -- reverts their selection
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING ORIGINAL CANCELLED_QUANTITY' ) ;
     END IF;

    p_x_line_rec.cancelled_quantity :=oe_sales_can_util.Cal_cancelled_qty(
                        p_x_line_rec,
                        p_old_line_rec);
-- INVCONV


		IF oe_line_util.dual_uom_control   -- INVCONV  Process_Characteristics
  		(p_x_line_rec.inventory_item_id,p_X_line_rec.ship_from_org_id,l_item_rec) THEN
  				IF l_item_rec.tracking_quantity_ind = 'PS' THEN -- INVCONV
       			if l_debug_level > 0 then
							oe_debug_pub.add(' Get dual uom - tracking in P and S ');
       			end if;


						IF l_debug_level  > 0 THEN
      			  oe_debug_pub.add(  'BEFORE CALLING CAL_CANCELLED_QTY2' ) ;
    				END IF;

    				p_x_line_rec.cancelled_quantity2 :=oe_sales_can_util.Cal_cancelled_qty2(
                        p_x_line_rec,
                        p_old_line_rec);

    				IF l_debug_level  > 0 THEN
        				oe_debug_pub.add(  'CANCELLED QUANTITY2 IS '||P_X_LINE_REC.CANCELLED_QUANTITY2 ) ;
    				END IF;

    			END IF; -- IF l_item_rec.tracking_quantity_ind = 'PS'

    END IF; --  IF oe_line_util.dual_uom_control





  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.CHECK_CONSTRAINTS' ) ;
  END IF;

END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            oe_msg_pub.Add_Exc_Msg
            (G_PKG_NAME
             ,l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || L_API_NAME ) ;
                       END IF;
        IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           oe_msg_pub.Add_Exc_Msg
           (G_PKG_NAME
            ,l_api_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_constraints;

PROCEDURE update_service
( p_line_rec      IN  OE_Order_PUB.Line_Rec_Type
, p_old_line_rec  IN  OE_Order_PUB.Line_Rec_Type := OE_Order_PUB.G_MISS_LINE_REC
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_api_name          VARCHAR2(30):= 'Update_Service';
l_line_id           NUMBER;
l_ordered_quantity  NUMBER;
l_service_quantity  NUMBER;
l_return_status     VARCHAR2(30);
x_msg_count         NUMBER;
x_msg_data          VARCHAR2(250);

/* lchen add l_change_reason, l_change_comments to fix bug 1879607 */
l_change_reason     VARCHAR2(30);
l_change_comments   VARCHAR2(2000);

CURSOR get_service IS
SELECT  LINE_ID, ORDERED_QUANTITY
FROM    oe_order_lines
WHERE  service_reference_line_id = p_line_rec.line_id
AND    service_reference_type_code = 'ORDER' -- these two conditions added for bug 2946327
AND    nvl(cancelled_flag, 'N') <> 'Y';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SALES_CAN_UTIL.UPDATE_SERVICE' ) ;
  END IF;

  for Serrec in get_service loop
    l_line_id := serrec.line_id;
    l_service_quantity := serrec.ordered_quantity;
    l_ordered_quantity := p_line_rec.ordered_quantity;

    /* lchen add l_change_reason, l_change_comments to fix bug 1879607 */
    l_change_reason := p_line_rec.change_reason;
    l_change_comments := p_line_rec.change_comments;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING UPDATELINE FOR LINE ID: '|| L_LINE_ID ) ;
    END IF;

    /* Call the UpdateLine only if ordered_quantity is greater than zero */
    IF( l_service_quantity <> 0 )then
		Updateline(l_line_id,
			   l_ordered_quantity,
                           l_change_reason,
                           l_change_comments,
                           l_return_status,
			   x_msg_count,
			   x_msg_data);
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING UPDATELINE , RETURN STATUS: '|| L_RETURN_STATUS ) ;
    END IF;

  end loop;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    if l_return_status = FND_API.G_RET_STS_ERROR then
      raise FND_API.G_EXC_ERROR;
    else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  end if;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.UPDATE_SERVICE' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            oe_msg_pub.Add_Exc_Msg
            (G_PKG_NAME
             ,l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || L_API_NAME ) ;
                       END IF;
        IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           oe_msg_pub.Add_Exc_Msg
           (G_PKG_NAME
            ,l_api_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end update_service;

FUNCTION Cal_Cancelled_Qty
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)Return Number
IS
l_ordered_quantity number;
l_old_ord_quantity number;
l_old_can_quantity number;
l_new_can_quantity number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)
        THEN
--IF (nvl(p_line_rec.line_category_code,' ') <> 'RETURN')  THEN

  /* Fix bug # 2136529: Get the old quantities from the database */
  select nvl(ordered_quantity, 0)
  ,      nvl(cancelled_quantity, 0)
  into   l_old_ord_quantity
  ,      l_old_can_quantity
  from   oe_order_lines
  where  line_id = p_line_rec.line_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW ORDERED QUANTITY IS: '||P_LINE_REC.ORDERED_QUANTITY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD ORDERED QUANTITY IS: '||L_OLD_ORD_QUANTITY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD CANCELLED QUANTITY IS: '||L_OLD_CAN_QUANTITY ) ;
  END IF;

  IF (l_old_ord_quantity > p_line_rec.ordered_quantity)
       and nvl(oe_globals.g_pricing_recursion, 'N') = 'N' THEN
    l_new_can_quantity := l_old_ord_quantity - p_line_rec.ordered_quantity
                                               + l_old_can_quantity;
  ELSE
    l_new_can_quantity := l_old_can_quantity;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW CANCELLED QUANTITY IS: '||L_NEW_CAN_QUANTITY ) ;
  END IF;

  RETURN l_new_can_quantity;

END IF;
/*
** Fix # 3147694 Start
** Following will be true only if the user is cancelling the
** order right after quantity on the lines was updated to 0.
** Need to send the Cancelled Qty as Zero in such instances.
*/
IF p_line_rec.ordered_quantity = 0 AND
   p_old_line_rec.ordered_quantity = 0 AND
   OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can THEN

  RETURN 0;

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Line Ord Qty already 0, Returning 0 as Cancelled Qty');
  END IF;
END IF;

/* Following commented code has been replaced as fix for bug # 2136529

IF (p_old_line_rec.ordered_quantity > p_line_rec.ordered_quantity) THEN
l_ordered_quantity :=
 (p_old_line_rec.ordered_quantity - p_line_rec.ordered_quantity);

	IF p_old_line_rec.cancelled_quantity = FND_API.G_MISS_NUM OR
		 p_old_line_rec.cancelled_quantity is NULL THEN
        oe_debug_pub.ADD('rajeevcancell');
			RETURN l_ordered_quantity;
		ELSE
        oe_debug_pub.ADD('rajeevcancel2');
			RETURN (l_ordered_quantity +
				p_old_line_rec.cancelled_quantity) ;
	END IF;
ELSE
        oe_debug_pub.ADD('rajeevcancel3');
		RETURN p_line_rec.cancelled_quantity;
END IF;
END IF;
ELSE
IF (p_old_line_rec.ordered_quantity < p_line_rec.ordered_quantity) THEN
l_ordered_quantity :=
 (p_old_line_rec.ordered_quantity - p_line_rec.ordered_quantity);

	IF p_old_line_rec.cancelled_quantity = FND_API.G_MISS_NUM OR
		 p_old_line_rec.cancelled_quantity is NULL THEN
			RETURN l_ordered_quantity;
		ELSE
			RETURN (l_ordered_quantity +
				p_old_line_rec.cancelled_quantity) ;
	END IF;
ELSE
		RETURN p_line_rec.cancelled_quantity;
END IF;
        oe_debug_pub.ADD('rajeevcancelsecond');

END IF;
END IF;
		RETURN p_line_rec.cancelled_quantity;
*/

--Bug# 4009268
IF OE_GLOBALS.Equal(p_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)  THEN
   oe_debug_pub.add('New ordered_quantity and Old ordered_quantity are equal ');
   RETURN nvl(p_line_rec.cancelled_quantity,0);
END IF;

IF l_debug_level > 0 THEN
    oe_debug_pub.add('Cal_Cancelled_qty  - Returning 0 as Cancelled Qty at end ');
  END IF;

return 0; -- INVCONV

end Cal_Cancelled_qty;

PROCEDURE check_constraints
(   p_header_rec                      IN  OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                  IN  OE_Order_PUB.header_Rec_Type:=
                                        OE_Order_PUB.G_MISS_header_REC
, x_return_status OUT NOCOPY VARCHAR2

) IS
l_api_name         CONSTANT VARCHAR2(30) := 'Check_Constraints';
l_return_status       varchar2(30) :=FND_API.G_RET_STS_SUCCESS;
x_result 	NUMBER := 0 ;
l_constrain_all_flag varchar2(255);
l_constraint_id NUMBER;
l_resolving_wf_activity_name varchar2(255);
l_resolving_wf_item_type varchar2(255);
l_exclude_flag varchar2(255);
l_resolving_responsibility_id number;
x_msg_count number;
x_msg_data  varchar2(255);
l_on_operation_action varchar2(255);
l_resp_id number := nvl(fnd_global.resp_id,-1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN CHECK CONSTRAINS FOR CANCELLATION' ) ;
	END IF;
--	initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
     -- Prepare security record

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            oe_msg_pub.Add_Exc_Msg
            (G_PKG_NAME
             ,l_api_name);
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UNEXPECTED ERROR IN ' || G_PKG_NAME || ':' || L_API_NAME ) ;
                       END IF;
        IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           oe_msg_pub.Add_Exc_Msg
           (G_PKG_NAME
            ,l_api_name);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
end check_constraints;

PROCEDURE perform_cancel_order
( p_header_rec     IN  OE_Order_PUB.header_Rec_Type
, p_old_header_rec IN  OE_Order_PUB.header_Rec_Type := OE_Order_PUB.G_MISS_header_REC
, x_return_status OUT NOCOPY VARCHAR2

)IS
l_line_tbl              OE_Order_PUB.line_tbl_type;
l_line_old_tbl          OE_Order_PUB.line_tbl_type;
l_line_rec              OE_Order_PUB.line_rec_type;
l_msg_count             NUMBER;
l_msg_data 	        VARCHAR2(240);
l_entity_id             NUMBER;
l_result                VARCHAR2(30);
l_entity_code           VARCHAR2(1) := 'O';
l_line_process_name     VARCHAR2(30);
l_hold_release_rec      oe_hold_sources_pvt.hold_release_rec;
l_return_status         VARCHAR2(30);
l_result_out            VARCHAR2(30);
l_order_tbl             OE_HOLDS_PVT.order_tbl_type;
l_hold_id               OE_HOLD_DEFINITIONS.HOLD_ID%TYPE;
l_release_reason_code   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE;
l_release_comment       OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE;

l_service_parent_exists VARCHAR2(1) := 'N';
l_x_line_old_tbl        OE_Order_PUB.line_tbl_type;
i                       NUMBER := 0;
l_prg_line_count        NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.ADD('Entering oe_sales_can_util.perform_cancel_order',5);
      OE_DEBUG_PUB.ADD('perform cancel order header id : '||p_header_rec.header_id,5);
      OE_DEBUG_PUB.add('Reason Required Flag : '||OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG,1);
      OE_DEBUG_PUB.add('Reason provided is : '||p_header_rec.change_reason,1);
  END IF;

  --g_ord_lvl_can := TRUE; Commented for bug# 2922468

  IF (oe_sales_can_util.G_REQUIRE_REASON AND OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG <> 'N') THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CHANGE REASON IS REQUIRED' ) ;
    END IF;
    IF p_header_rec.change_reason IS NULL THEN
      fnd_message.set_name('ONT','OE_CAN_REASON_NOT');
      oe_msg_pub.add;
      raise FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  oe_line_util.Query_Rows( p_header_id  => p_header_rec.header_id
                         , x_line_tbl   => l_line_old_tbl
                         );

  --l_line_tbl := l_line_old_tbl;

   -- If the header is cancelled then the header level charges are deleted
   IF nvl(p_header_rec.cancelled_flag,'N') = 'Y' THEN
     OE_Header_Adj_Util.Delete_Header_Charges( p_header_id  => p_header_rec.header_id );
   END IF;

  For j in 1 .. l_line_old_tbl.count Loop

    /* Fix for bug # 2104209 */
    IF nvl(l_line_old_tbl(j).cancelled_flag, 'N') <> 'Y' THEN

      IF nvl(l_line_old_tbl(j).top_model_line_id, l_line_old_tbl(j).line_id) = l_line_old_tbl(j).line_id OR
         nvl(l_line_old_tbl(j).model_remnant_flag, 'N') = 'Y' THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE SELECTED FOR CANCELLATION , ID: '|| L_LINE_OLD_TBL ( J ) .LINE_ID , 1 ) ;
        END IF;

        /* Fix for bug # 2126033 */
        IF l_line_old_tbl(j).item_type_code = OE_Globals.G_ITEM_SERVICE AND
           l_line_old_tbl(j).service_reference_type_code = 'ORDER' THEN

          begin
            select 'Y'
            into   l_service_parent_exists
            from   oe_order_lines
            where  header_id = l_line_old_tbl(j).header_id
            and    line_id   = l_line_old_tbl(j).service_reference_line_id;
            exception
              when no_data_found then
                l_service_parent_exists := 'N';
              when others then
                null;
          end;

          IF l_service_parent_exists = 'Y' THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SKIP , PARENT OF THIS SERVICE LINE EXISTS IN THE SAME ORDER' ) ;
            END IF;
            goto  end_loop;
          END IF;
        END IF;

        /* Fix for bug # 2387919 */
        begin
          select count(*)
          into   l_prg_line_count
          from   oe_price_adjustments opa1,
                 oe_price_adjustments opa2,
                 oe_price_adj_assocs opaa
          where  opa1.list_line_type_code = 'PRG'
          and    opa1.price_adjustment_id = opaa.price_adjustment_id
          and    opa2.price_adjustment_id = opaa.rltd_price_adj_id
          and    opa2.line_id             = l_line_old_tbl(j).line_id;
        end;

        IF l_prg_line_count > 0 THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SKIP , THIS IS A PROMOTIONAL LINE' ) ;
          END IF;
          goto  end_loop;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ADDING FOR CANCELLATION , LINE ID: '||L_LINE_OLD_TBL ( J ) .LINE_ID ) ;
        END IF;

        i := i + 1;

        l_line_tbl(i) := l_line_old_tbl(j);
        l_x_line_old_tbl(i) := l_line_old_tbl(j);
        l_line_tbl(i).db_flag := FND_API.G_TRUE;
        --l_line_tbl(i).cancelled_quantity := l_line_tbl(i).ordered_quantity;
        l_line_tbl(i).ordered_quantity :=0;
        l_line_tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(i).change_reason :=p_header_rec.change_reason;
        l_line_tbl(i).change_comments :=p_header_Rec.change_comments;
        /*l_line_tbl(i).cancelled_flag := 'Y';
        l_line_tbl(i).flow_status_code := 'CANCELLED';
        l_line_tbl(i).open_flag := 'N'; */
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SKIPPING LINE ID: '||L_LINE_OLD_TBL ( J ) .LINE_ID||'-'|| L_LINE_OLD_TBL ( J ) .ITEM_TYPE_CODE ) ;
        END IF;
      END IF;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SKIPPING CANCELLED LINE ID: '||L_LINE_OLD_TBL ( J ) .LINE_ID||'-'|| L_LINE_OLD_TBL ( J ) .ITEM_TYPE_CODE ) ;
      END IF;
    END IF; -- line not cancelled?
    <<end_loop>>
    null;
  End Loop;

  IF l_line_tbl.count = 0 THEN
    oe_sales_can_util.g_order_cancel := TRUE;
  END IF;

  -- Call PeformLinecancellation to cancel each line
  IF l_line_tbl.count > 0 THEN
    PerformLinecancellation(l_line_tbl,
                            l_x_line_old_tbl,
                            l_return_status);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE LINE PROCESS ORDER RETURN UNEXP_ERROR' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE LINE PROCESS ORDER RETURN RET_STS_ERROR' ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Need to process payment refund if there is any prepayment.
  IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.ADD('Calling Payment Refund for multiple payments.');
    END IF;

    OE_Prepayment_PVT.Process_Payment_Refund
                           ( p_header_rec     => p_header_rec
                           , x_msg_count      => l_msg_count
                           , x_msg_data       => l_msg_data
                           , x_return_status  => x_return_status
                           );
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('return status after calling process_payment_refund is: '||x_return_status, 3);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF NVL(p_header_rec.payment_type_code,'NULL') = 'CREDIT_CARD'
    AND OE_PrePayment_UTIL.is_prepaid_order(p_header_rec) = 'Y'
    THEN
     oe_debug_pub.ADD('Calling Payment Refund.');
     OE_PrePayment_PVT.Process_PrePayment_Order
               ( p_header_rec           => p_header_rec
                , p_calling_action      => NULL
                , p_delayed_request     => FND_API.G_FALSE
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , x_return_status       => x_return_status
                );
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('return status after calling process_prepayment_order is: '||x_return_status, 3);
     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  -- Release Holds

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING RELEASE HOLD API RELEASE HOLD' ) ;
  END IF;

  l_order_tbl(1).header_id  := p_header_rec.header_id;
  l_release_reason_code := 'OM_CANCEL';

  OE_Holds_pub.release_holds(
          p_order_tbl            =>  l_order_tbl,
          p_release_reason_code  =>  l_release_reason_code,
          p_release_comment      =>  l_release_comment,
          p_hold_id              => Null,
          x_return_status        =>  l_return_status,
          x_msg_count            =>  l_msg_count,
          x_msg_data             =>  l_msg_data
          );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'THE HOLD RELEASED WITH STATUS :'|| L_RETURN_STATUS ) ;
  END IF;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    if l_return_status = FND_API.G_RET_STS_ERROR then
      raise FND_API.G_EXC_ERROR;
    else
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  end if;

  /*
  ** Fix for 1967295:
  ** As VOID has been de-supported by iPayment, commenting
  ** following code which was used to VOID existing Trxns.
  **
  -- If Order has Credit Card approval, then Void the Authorization
  IF p_header_rec.credit_card_approval_code is NOT NULL THEN

    -- Call Payment Request to Void any existing Authorizations
      oe_debug_pub.ADD('Before calling Payment Request');

    OE_Verify_Payment_PUB.Payment_Request
                           ( p_header_rec     => p_header_rec
                           , p_trxn_type      => 'VOIDAUTHONLY'
                           , p_msg_count      => l_msg_count
                           , p_msg_data       => l_msg_data
                           , p_result_out     => l_result_out
                           , p_return_status  => l_return_status
                           );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF; -- IF Credit Card Approval Code is NOT NULL
  */



  -- Abort the Wf and close the Header
  --OE_STANDARD_WF.Get_HdrProcessName(OE_GLOBALS.G_WFI_HDR, p_header_rec.header_id,
  --l_line_process_name);

  -- Moved this post line process
		/*IF oe_sales_can_util.g_order_cancel  THEN
		wf_engine.handleerror(OE_Globals.G_WFI_HDR
				,to_char(p_header_rec.header_id)
		        	,'CLOSE_HEADER',
				'SKIP','CANCEL');
	     END IF; */

  --g_ord_lvl_can := FALSE; Commented for bug# 2922468

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.PERFORM_CANCEL_ORDER' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --g_ord_lvl_can := FALSE; Commented for bug# 2922468
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --g_ord_lvl_can := FALSE; Commented for bug# 2922468
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      --g_ord_lvl_can := FALSE; Commented for bug# 2922468
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        oe_msg_pub.Add_Exc_Msg
          (G_PKG_NAME
           ,'Peform_Cancel_order');
      END IF;

End Perform_Cancel_order;

Procedure PerformLineCancellation(
  p_line_tbl      IN  OE_ORDER_PUB.LINE_TBL_TYPE
, p_line_old_tbl  IN  OE_ORDER_PUB.LINE_TBL_TYPE
, x_return_status OUT NOCOPY VARCHAR2)

IS
l_control_rec      OE_GLOBALS.Control_Rec_Type;
l_line_tbl         OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl     OE_ORDER_PUB.Line_Tbl_Type;
l_api_name         CONSTANT VARCHAR2(30) := 'PerformLineCancellation';
x_msg_count        NUMBER;
x_msg_data         VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SALES_CAN_UTIL.PERFORMLINECANCELLATION' ) ;
  END IF;

  l_control_rec.controlled_operation := TRUE;
  l_control_rec.change_attributes    := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.write_to_DB          := TRUE;

  l_control_rec.default_attributes   := FALSE;
  l_control_rec.process              := TRUE;
  l_control_rec.process_partial      := TRUE;

  --  Instruct API to retain its caches

  l_control_rec.clear_api_cache      := FALSE;
  l_control_rec.clear_api_requests   := FALSE;

  l_line_tbl := p_line_tbl;
  l_old_line_tbl := p_line_old_tbl;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER' ) ;
  END IF;

  oe_order_pvt.Lines
  (   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
  ,   p_control_rec       => l_control_rec
  ,   p_x_line_tbl        => l_line_tbl
  ,   p_x_old_line_tbl    => l_old_line_tbl
  ,   x_return_status     => x_return_status
  );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER' ) ;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Api to call OC and ACK and process delayed requests
  IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN -- reinstated for 2653505
    OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => x_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );

         FOR I IN 1..l_line_tbl.COUNT LOOP
          if l_line_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
      	     x_return_status := FND_API.G_RET_STS_ERROR;
      elsif l_line_tbl(I).return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          end if;
        end loop;
  END IF; -- 2653505

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.PERFORMLINECANCELLATION' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       IF oe_msg_pub.Check_MSg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          oe_msg_pub.Add_Exc_Msg
          (G_PKG_NAME
           ,'PeformLineCancellation');
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;

END PerformLineCancellation;

FUNCTION Query_Rows
(   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
) RETURN OE_Order_PUB.Line_Tbl_Type
IS
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_UTIL.QUERY_ROWS' , 1 ) ;
    END IF;


    --  Return fetched table
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_UTIL.QUERY_ROWS' , 1 ) ;
    END IF;

    RETURN l_line_tbl;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Rows;

-- bug 4887806
-- The Logic of creating this api was to see that while the
-- remaining lines of an order are being cancelled, if there
-- are any fulfillment sets which should not be awaiting for
-- any other lines to reach fulfillment due to result of cancellation
-- then those sets should be processed for fulfillment logic.

PROCEDURE Call_Process_Fulfillment(p_header_id IN NUMBER)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_result_out      VARCHAR2(240);
l_return_status   VARCHAR2(30);
l_activity_result VARCHAR2(30) := 'NO_RESULT';
l_activity_status VARCHAR2(8);
l_msg_data        VARCHAR2(2000);
l_item_key        VARCHAR2(240);
l_msg_count       NUMBER;
l_line_id         NUMBER;
l_activity_id     NUMBER;
l_lines_in_set    NUMBER;
l_lines_awaiting  NUMBER;

  -- Find all the non-closed fulfillment sets
  Cursor C_FulfillmentSets IS
  SELECT DISTINCT OS.SET_ID
  FROM oe_order_lines ol, oe_sets OS, oe_line_sets ols
  WHERE ol.header_id  = p_header_id
    and OS.HEADER_ID  = ol.header_id
    and ol.line_id    = ols.line_id
    and ols.set_id    = OS.set_id
    and OS.SET_TYPE   = 'FULFILLMENT_SET'
    and OS.SET_STATUS in ('A','T')
    and ol.cancelled_flag <> 'Y'
    and ol.open_flag  = 'Y';

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering Oe_sales_can_util.Call_Process_Fulfillment API',2);
  END IF;

  SAVEPOINT Process_Set;

  FOR C_Set in C_FulfillmentSets
  LOOP

    -- Count the lines in this set
    SELECT count(1) INTO l_lines_in_set
    FROM oe_order_lines ol, oe_line_sets ols
    WHERE ol.header_id  = p_header_id
      AND ols.set_id    = C_Set.set_id
      AND ol.line_id    = ols.line_id
      AND ol.cancelled_flag <> 'Y'
      AND ol.open_flag  = 'Y';

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Fulfillment Set_id='||C_Set.set_id||',No. of lines='||l_lines_in_set,2);
    END IF;

    -- Count the lines that are awaiting fulfillment for this set
    IF l_lines_in_set > 0 THEN
      SELECT count(1) INTO l_lines_awaiting
      FROM oe_order_lines ol, oe_line_sets ols,
           wf_item_activity_statuses WIAS,
           wf_process_activities WPA
      WHERE ol.header_id = p_header_id
        AND ols.set_id = C_Set.set_id
        AND ols.line_id = ol.line_id
        AND WPA.activity_name     = 'FULFILL_LINE'
        AND WIAS.item_type        = 'OEOL'
        AND WIAS.item_key         = to_char(ol.line_id)
        AND WIAS.activity_status  = 'NOTIFIED'
        AND WIAS.Process_Activity = WPA.instance_id;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('No. of lines in Fulfill:NOTIFIED ='||l_lines_awaiting,2);
      END IF;

      IF l_lines_awaiting = l_lines_in_set THEN
        -- This is to pick up 1 line in the set in Fulfill:Notified
        SELECT WIAS.Process_Activity, ol.line_id
        INTO l_activity_id, l_line_id
        FROM oe_order_lines ol, oe_line_sets ols,
             wf_item_activity_statuses WIAS,
             wf_process_activities WPA
        WHERE ol.header_id = p_header_id
          AND ols.set_id = C_Set.set_id
          AND ols.line_id = ol.line_id
          AND WPA.activity_name     = 'FULFILL_LINE'
          AND WIAS.item_type        = 'OEOL'
          AND WIAS.item_key         = to_char(ol.line_id)
          AND WIAS.activity_status  = 'NOTIFIED'
          AND WIAS.Process_Activity = WPA.instance_id
          AND ROWNUM = 1;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('All lines in fulfill:notified, hence calling OE_Line_Fullfill.Process_Fulfillment for line_id='||l_line_id||' , p_activity_id='||l_activity_id,2);
        END IF;

        OE_Line_Fullfill.Process_Fulfillment
                  ( p_api_version_number  => 1.0
                  , p_line_id             => l_line_id
                  , p_activity_id         => l_activity_id
                  , x_result_out          => l_result_out
                  , x_return_status       => l_return_status
                  , x_msg_count           => l_msg_count
                  , x_msg_data            => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Exception from Process_Fulfillment:'||l_result_out,2);
          END IF;
          OE_MSG_PUB.Add_Text(p_message_text => l_msg_data);
          OE_MSG_PUB.Save_API_Messages;

          ROLLBACK TO Process_Set;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSE -- fulfillment of all related lines was successful
          l_item_key := to_char(l_line_id);
          Oe_line_fullfill.Get_Activity_Result(
	          p_item_type            => OE_GLOBALS.G_WFI_LIN
                 ,p_item_key             => l_item_key
                 ,p_activity_name        => 'FULFILL_LINE'
                 ,x_return_status        => l_return_status
                 ,x_activity_result      => l_activity_result
                 ,x_activity_status_code => l_activity_status
                 ,x_activity_id          => l_activity_id );

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('After Get_Activity_Result, ret status:'||l_return_status||' ,Fulfill:'||l_activity_status,3);
          END IF;

          IF l_return_status = FND_API.G_RET_STS_SUCCESS AND
	     l_activity_status = 'NOTIFIED' THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Calling wf_engine.CompleteActivityInternalName for lineID='||l_item_key,2);
            END IF;

            Wf_Engine.CompleteActivityInternalName('OEOL', l_item_key, 'FULFILL_LINE', '#NULL');

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('After calling wf_engine.CompleteActivityInternalName for lineID='||l_item_key,2);
            END IF;
          END IF;
        END IF;
      END IF; -- l_lines_awaiting = l_lines_in_set check
    END IF; -- l_lines_in_set > 0 check
    -- re-initializing the variables to NULL
    l_lines_awaiting := NULL;
    l_lines_in_set   := NULL;
  END LOOP; -- Non closed fulfillment sets

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exiting from Oe_sales_can_util.Call_Process_Fulfillment API',2);
  END IF;
EXCEPTION
  WHEN Others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION in Oe_sales_can_util.Call_Process_Fulfillment API',2);
    END IF;
END Call_Process_Fulfillment;

PROCEDURE Cancel_Remaining_Order
( p_header_Rec    IN  OE_Order_PUB.Header_Rec_Type := OE_ORDER_PUB.G_MISS_HEADER_REC,
  p_header_id     IN  NUMBER := FND_API.G_MISS_NUM
, x_return_status OUT NOCOPY VARCHAR2

)
IS
l_line_tbl          OE_Order_PUB.line_tbl_type;
l_line_old_tbl      OE_Order_PUB.line_tbl_type;
l_x_line_old_tbl    OE_Order_PUB.line_tbl_type;
l_line_rec          OE_Order_PUB.line_rec_type;
l_header_rec        OE_Order_PUB.header_rec_type;
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(240);
l_entity_id         NUMBER;
l_result            VARCHAR2(30);
l_entity_code       VARCHAR2(1) := 'O';
l_line_process_name VARCHAR2(30);
l_hold_release_rec  oe_hold_sources_pvt.hold_release_rec;
l_return_status     VARCHAR2(30);
l_header_id         NUMBER;
J                   NUMBER := 0;
lfullfillqty        NUMBER;

l_service_parent_exists   VARCHAR2(1) := 'N';
l_prg_line_count          NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_SALES_CAN_UTIL.CANCEL_REMAINING_ORDER' ) ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  g_par_ord_lvl_can := TRUE; --Fix for bug 2230777

  l_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;

  IF (p_header_rec.header_id = FND_API.G_MISS_NUM OR
      p_header_rec.header_id = NULL) THEN
    l_header_id := p_header_id;
  ELSE
    l_header_id := p_header_rec.header_id;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CANCEL REMAINING ORDER HEADER ID: '||L_HEADER_ID ) ;
  END IF;

  oe_line_util.Query_Rows( p_header_id => l_header_id
                         , x_line_tbl  => l_line_old_tbl
                         );

  oe_header_util.Query_Row( p_header_id  => l_header_id
                          , x_header_rec => l_header_rec
                          );

  --l_line_tbl := l_line_old_tbl;

  For I in 1 .. l_line_old_tbl.count Loop

    /*IF l_line_old_tbl(i).line_category_code = 'RETURN' THEN
        lfullfillqty := NULL;
      ELSE
        lfullfillqty := l_line_old_tbl(i).shipped_quantity;
      END IF;*/

    IF  Nvl(l_line_old_tbl(i).shipped_quantity,0) = 0    AND
        Nvl(l_line_old_tbl(i).cancelled_flag,'N') <> 'Y' AND
        Nvl(l_line_old_tbl(i).ordered_quantity,0) <> 0   AND
        Nvl(l_line_old_tbl(i).open_flag,'N')      <> 'N' THEN

      /* Following IF condition added to fix 2112435 */
      IF nvl(l_line_old_tbl(i).top_model_line_id, l_line_old_tbl(i).line_id) = l_line_old_tbl(i).line_id OR
         nvl(l_line_old_tbl(i).model_remnant_flag, 'N') = 'Y' THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE SELECTED FOR CANCELLATION , ID: '|| L_LINE_OLD_TBL ( I ) .LINE_ID , 1 ) ;
        END IF;

        /* Fix for bug # 2126033 */
        IF l_line_old_tbl(i).item_type_code = OE_Globals.G_ITEM_SERVICE AND
           l_line_old_tbl(i).service_reference_type_code = 'ORDER' THEN

          begin
            select 'Y'
            into   l_service_parent_exists
            from   oe_order_lines
            where  header_id = l_line_old_tbl(i).header_id
            and    line_id   = l_line_old_tbl(i).service_reference_line_id;
            exception
              when no_data_found then
                l_service_parent_exists := 'N';
              when others then
                null;
          end;

          IF l_service_parent_exists = 'Y' THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SKIP , PARENT OF THIS SERVICE LINE EXISTS IN THE SAME ORDER' ) ;
            END IF;
            goto  end_loop;
          END IF;
        END IF;

        /* Fix for bug # 2387919 */
        begin
          select count(*)
          into   l_prg_line_count
          from   oe_price_adjustments opa1,
                 oe_price_adjustments opa2,
                 oe_price_adj_assocs opaa,
                 oe_order_lines_all ol --bug 4156493
          where  opa1.list_line_type_code = 'PRG'
          and    opa1.price_adjustment_id = opaa.price_adjustment_id
          and    opa2.price_adjustment_id = opaa.rltd_price_adj_id
          and    opa2.line_id             = l_line_old_tbl(i).line_id
          --bug 4156493
          and    opa1.line_id            = ol.line_id
          and    ol.shipped_quantity is null;
        end;

        IF l_prg_line_count > 0 THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SKIP , THIS IS A PROMOTIONAL GOODS LINE' ) ;
          END IF;
          goto  end_loop;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ADDING FOR CANCELLATION , LINE ID: '|| L_LINE_OLD_TBL ( I ) .LINE_ID ) ;
        END IF;

        J := J + 1;

        l_line_tbl(J) := l_line_old_tbl(I);
        l_x_line_old_tbl(J) := l_line_old_tbl(I);
        l_line_tbl(J).db_flag := FND_API.G_TRUE;
        --l_line_tbl(J).cancelled_quantity := l_line_tbl(J).ordered_quantity;
        l_line_tbl(j).ordered_quantity :=0;
        l_line_tbl(j).operation := OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(j).change_reason :=p_header_rec.change_reason;
        l_line_tbl(j).change_comments :=p_header_Rec.change_comments;
        /*
        ** Fix bug # 2660104:
        ** Following column will be updated in Check_Constraints()
        ** procedure if line reaches the cancellation point.
        l_line_tbl(j).cancelled_flag := 'Y';
        */
        /*
        ** Fix Bug # 2238002:
        ** Following columns are updated when WF Handle error is called.
        */
        --l_line_tbl(j).flow_status_code := 'CANCELLED';
        --l_line_tbl(j).open_flag := 'N';
      ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SKIPPING LINE ID: '||L_LINE_OLD_TBL ( I ) .LINE_ID||'-'|| L_LINE_OLD_TBL ( I ) .ITEM_TYPE_CODE ) ;
        END IF;
      END IF;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SKIPPING ALREADY SHIPPED OR CLOSED/CANCELLED LINE ID: '||L_LINE_OLD_TBL ( I ) .LINE_ID ) ;
      END IF;
    END If;
    <<end_loop>>
    null;
  End Loop;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CANCEL REMAINING ORDER - LINE COUNT '|| L_LINE_TBL.COUNT ) ;
  END IF;

  IF l_line_tbl.count = 0 THEN
    FND_MESSAGE.SET_NAME('ONT','OE_NO_ELIGIBLE_LINES');
    FND_MESSAGE.SET_TOKEN('ORDER', L_header_rec.Order_Number);
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE CALLING PERFORM LINE CANCELLATION' ) ;
  END IF;

  -- Call PeformLinecancellation to cancel each line
  PerformLinecancellation(l_line_tbl,
                          l_x_line_old_tbl,
			  x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PERFORM LINE CANCELLATION UNEXP_ERROR' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PERFORM LINE CANCELLATION RET_STS_ERROR' ) ;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  g_par_ord_lvl_can := FALSE;

  --added for bug 4567339
      OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => TRUE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_x_line_old_tbl
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  'Process_requests_and_notify UNEXP_ERROR' ) ;
           END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  'Process_requests_and_notify RET_STS_ERROR' ) ;
	   END IF;
		RAISE FND_API.G_EXC_ERROR;
        END IF;
  --end bug 4567339

  -- bug 4887806
  OE_SALES_CAN_UTIL.Call_Process_Fulfillment(p_header_id => p_header_id);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_SALES_CAN_UTIL.CANCEL_REMAINING_ORDER' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      g_par_ord_lvl_can := FALSE;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      g_par_ord_lvl_can := FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Cancel Remaining Order'
               );
      END IF;
End Cancel_Remaining_Order;

PROCEDURE Cancel_Wf
(
x_return_status OUT NOCOPY varchar2
, x_request_rec      IN OUT NOCOPY OE_Order_PUB.Request_Rec_Type
)
IS
l_Ordered_Quantity number ;
Cursor C1 IS
select ordered_quantity from
oe_order_lines_all
where line_id = x_request_rec.entity_id;

Cursor C2 IS
select ordered_quantity from
oe_order_lines_all
where header_id = x_request_rec.entity_id
and ordered_quantity <> 0;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('Enter Cancel Workflow API - OEXUCANB ');
         OE_DEBUG_PUB.ADD('Entity:' || x_request_rec.param1 );
         OE_DEBUG_PUB.ADD('Entity id:' || x_request_rec.entity_id );
	end if;

	IF x_request_rec.param1 = OE_GLOBALS.G_ENTITY_HEADER
	THEN

	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('Before select ');
	end if;
		OPEN C2;
		FETCH C2 INTO l_ordered_quantity;
		CLOSE C2;
		IF l_ordered_quantity IS NULL THEN
	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('Before cancelling header flow ');
	end if;

          wf_engine.handleerror(OE_Globals.G_WFI_HDR
                    ,to_char(x_request_rec.entity_id)
                    ,'CLOSE_HEADER',
                    'RETRY','CANCEL');

		END IF; -- Ordered quantity

	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('after cancelling header flow ');
	end if;

       ELSIF x_request_rec.param1 = OE_GLOBALS.G_ENTITY_LINE
       THEN

	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('before select Cursoer C1 ');
	end if;
		OPEN C1;
		FETCH C1 INTO l_ordered_quantity;
		CLOSE C1;
		IF l_ordered_quantity = 0  THEN
	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('Before cancelling line  flow ');
	end if;
		Update oe_order_lines_all
		set cancelled_flag = 'Y' where
		line_id = x_request_rec.entity_id;

          wf_engine.handleerror(OE_Globals.G_WFI_LIN
                    ,to_char(x_request_rec.entity_id)
                    ,'CLOSE_LINE',
                    'RETRY','CANCEL');
	      End if; -- Ordered quantity

	 if l_debug_level > 0 then
         OE_DEBUG_PUB.ADD('after cancelling line flow ');
	end if;

	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CANCEL_WF' );
	END IF;

END CANCEL_WF ;


--  INVCONV  OPM Inventory convergence
FUNCTION Cal_Cancelled_Qty2
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_old_line_rec                  IN  OE_Order_PUB.Line_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_REC
)Return Number
IS
l_ordered_quantity2 number;
l_old_ord_quantity2 number;
l_old_can_quantity2 number;
l_new_can_quantity2 number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

 IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'entering Cal_Cancelled_Qty2') ;
  END IF;
IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2)
        THEN
        IF l_debug_level  > 0 THEN
    			  oe_debug_pub.add(  'in Cal_Cancelled_Qty2 1 ') ;
  			END IF;

--IF (nvl(p_line_rec.line_category_code,' ') <> 'RETURN')  THEN

  /* Fix bug # 2136529: Get the old quantities from the database */
  select nvl(ordered_quantity2, 0)
  ,      nvl(cancelled_quantity2, 0)
  into   l_old_ord_quantity2
  ,      l_old_can_quantity2
  from   oe_order_lines
  where  line_id = p_line_rec.line_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW ORDERED QUANTITY2 IS: '||P_LINE_REC.ORDERED_QUANTITY2 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD ORDERED QUANTITY2 IS: '||L_OLD_ORD_QUANTITY2 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OLD CANCELLED QUANTITY2 IS: '||L_OLD_CAN_QUANTITY2 ) ;
  END IF;

  IF (l_old_ord_quantity2 > p_line_rec.ordered_quantity2)
       and nvl(oe_globals.g_pricing_recursion, 'N') = 'N' THEN
    l_new_can_quantity2 := l_old_ord_quantity2 - p_line_rec.ordered_quantity2
                                               + l_old_can_quantity2;
  ELSE
    l_new_can_quantity2 := l_old_can_quantity2;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'NEW CANCELLED QUANTITY2 IS: '||L_NEW_CAN_QUANTITY2 ) ;
  END IF;

  RETURN l_new_can_quantity2;

END IF;
/*
** Fix # 3147694 Start
** Following will be true only if the user is cancelling the
** order right after quantity on the lines was updated to 0.
** Need to send the Cancelled Qty as Zero in such instances.
*/
IF l_debug_level  > 0 THEN
    			  oe_debug_pub.add(  'in Cal_Cancelled_Qty2 2 ') ;
  			END IF;

IF p_line_rec.ordered_quantity2 = 0 AND
   p_old_line_rec.ordered_quantity2 = 0 AND
   OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can THEN

  RETURN 0;

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Line Ord Qty2 already 0, Returning 0 as Cancelled Qty2');
  END IF;
END IF;

IF l_debug_level  > 0 THEN
    			  oe_debug_pub.add(  'in Cal_Cancelled_Qty2 3 ') ;
  			END IF;

/* Following commented code has been replaced as fix for bug # 2136529

IF (p_old_line_rec.ordered_quantity > p_line_rec.ordered_quantity) THEN
l_ordered_quantity :=
 (p_old_line_rec.ordered_quantity - p_line_rec.ordered_quantity);

	IF p_old_line_rec.cancelled_quantity = FND_API.G_MISS_NUM OR
		 p_old_line_rec.cancelled_quantity is NULL THEN
        oe_debug_pub.ADD('rajeevcancell');
			RETURN l_ordered_quantity;
		ELSE
        oe_debug_pub.ADD('rajeevcancel2');
			RETURN (l_ordered_quantity +
				p_old_line_rec.cancelled_quantity) ;
	END IF;
ELSE
        oe_debug_pub.ADD('rajeevcancel3');
		RETURN p_line_rec.cancelled_quantity;
END IF;
END IF;
ELSE
IF (p_old_line_rec.ordered_quantity < p_line_rec.ordered_quantity) THEN
l_ordered_quantity :=
 (p_old_line_rec.ordered_quantity - p_line_rec.ordered_quantity);

	IF p_old_line_rec.cancelled_quantity = FND_API.G_MISS_NUM OR
		 p_old_line_rec.cancelled_quantity is NULL THEN
			RETURN l_ordered_quantity;
		ELSE
			RETURN (l_ordered_quantity +
				p_old_line_rec.cancelled_quantity) ;
	END IF;
ELSE
		RETURN p_line_rec.cancelled_quantity;
END IF;
        oe_debug_pub.ADD('rajeevcancelsecond');

END IF;
END IF;
		RETURN p_line_rec.cancelled_quantity;
*/

--Bug# 4009268
IF OE_GLOBALS.Equal(p_line_rec.ordered_quantity2,p_old_line_rec.ordered_quantity2)  THEN
   oe_debug_pub.add('New ordered_quantity2 and Old ordered_quantity2 are equal ');
   RETURN p_line_rec.cancelled_quantity2;
END IF;

		IF l_debug_level  > 0 THEN
    			  oe_debug_pub.add(  'in Cal_Cancelled_Qty2 4 ') ;
  			END IF;
  			 RETURN 0;

end Cal_Cancelled_qty2;


END OE_SALES_CAN_UTIL;

/
