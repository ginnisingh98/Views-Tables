--------------------------------------------------------
--  DDL for Package Body OE_RMA_RECEIVING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RMA_RECEIVING" As
/* $Header: OEXRMARB.pls 120.6.12010000.3 2009/01/13 05:52:49 nshah ship $ */

-- Push_Receiving_Info is an OM procedure that is called by Oracle Purchasing
-- to push receiving information to Oracle Order Management.
--
-- Pseudo Code of the possible combination of the parent trx types and
-- trx types in PO when calling this API.
-- This API assumes that the workflow always have Inspection activity
-- after Receiving activity. This is the seeded sub process.
-- If this is not the case, the logic has to be rewritten.
-- Also, it is assumed that PO will be calling this API with the correct trx types and quantity.
--
/*
	IF (p_parent_transaction_type is NULL or p_parent_transaction_type = G_RMA_NO_PARENT) THEN
		IF (p_transaction_type = G_RMA_RECEIVE) THEN
			- shipped_quantity := p_quantity;
			- shipping_uom := ordered_uom;
			- IF p_quantity < ordered_quantity (partial receipt) THEN
				split order line
			- complete wf activity for Receiving.
		ELSE
			no processing.
			return succesfull.
		END IF;

	ELSIF (p_parent_transaction_type = G_RMA_RECEIVE) THEN
		IF  (p_transaction_type = G_RMA_DELIVER) THEN

			- fulfilled_quantity := nvl(fulfilled_quantity, 0) + p_quantity;
			- IF fulfilled_quantity = shipped_quantity THEN
				complete wf activity for Inspection.
			  END IF;

		ELSIF (p_transaction_type = G_RMA_RETURN_TO_CUSTOMER) THEN
			- shipped_quantity := shipped_quantity - p_quantity;

		ELSIF (p_transaction_type = G_RMA_CORRECT) THEN
			- shipped_quantity := shipped_quantity - p_quantity;
			- adjust remaining open quantity or split line.

		ELSE
			no processing.
			return successfull.
		END IF;
	ELSIF (p_parent_transaction_type in (G_RMA_ACCEPT,G_RMA_REJECT)) THEN
		IF ( p_transaction_type = G_RMA_DELIVER) THEN
			- fulfilled_quantity := nvl(fulfilled_quantity, 0) + p_quantity;
			- IF fulfilled_quantity = shipped_quantity THEN
				complete wf activity for Inspection.
			  END IF;
		ELSIF (p_transaction_type = G_RMA_RETURN_TO_CUSTOMER) THEN
			- shipped_quantity := shipped_quantity - p_quantity;
			- IF fulfilled_quantity = shipped_quantity THEN
				complete wf activity for Inspection.
			  END IF;
		ELSE
			no processing.
			return successfull.
		END IF;

	ELSIF (p_parent_transaction_type = G_RMA_DELIVER) THEN
		IF (p_transaction_type = G_RMA_RETURN_TO_CUSTOMER) THEN
			- shipped_quantity := shipped_quantity - p_quantity;
			- fulfilled_quantity := fulfilled_quantity - p_quantity;

		ELSIF (p_transaction_type = G_RMA_RETURN_TO_RECEIVING) THEN
			- fulfilled_quantity := fulfilled_quantity - p_quantity;

		ELSIF (p_transaction_type = G_RMA_CORRECT) THEN
			- fulfilled_quantity := fulfilled_quantity + p_quantity;

		ELSE
			no processing.
			return successfull.
		END IF;

	ELSIF (p_parent_transaction_type = G_RMA_RETURN_TO_CUSTOMER) THEN
		IF (p_transaction_type = G_RMA_CORRECT) THEN
			- shipped_quantity := shipped_quantity - p_quantity;
			- fulfilled_quantity := fulfilled_quantity - p_quantity;
				(check if fulfilled is not null)

		ELSE
			no processing.
			return successfull.
		END IF;

	ELSIF (p_parent_transaction_type = G_RMA_RETURN_TO_RECEIVING) THEN
		IF (p_transaction_type = G_RMA_CORRECT) THEN
			- fulfilled_quantity := fulfilled_quantity - p_quantity;

		ELSE
			no processing.
			return successfull.
		END IF;

	ELSIF (p_parent_transaction_type = G_RMA_UNMATCHED_ORDER) THEN
		IF (p_transaction_type = G_RMA_MATCH) THEN
			- shipped_quantity := p_quantity;
			- shipping_uom := ordered_uom;
			- if partial receipt, split line;
			- complete wf activity for receiving;

		ELSE
			no processing
			return successfull;

		END IF;

	ELSE (for other parent transaction type)
		no processing.
		return successfull.
	END IF;

*/

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OE_RMA_RECEIVING';

Procedure Push_Receiving_Info(
p_RMA_Line_ID               IN  NUMBER,
p_Quantity                  IN  NUMBER,
p_Parent_Transaction_Type   IN  VARCHAR2,
p_Transaction_Type          IN  VARCHAR2,
p_Mismatch_Flag             IN  VARCHAR2,
x_Return_Status             OUT NOCOPY VARCHAR2,
x_Msg_Count                 OUT NOCOPY NUMBER,
x_MSG_Data                  OUT NOCOPY VARCHAR2,
p_Quantity2                 IN  NUMBER DEFAULT NULL,
p_R2Cust_Parent_Trn_Type    IN  VARCHAR2 DEFAULT NULL
)
IS
l_old_line_tbl		      	OE_Order_PUB.Line_Tbl_Type;
l_line_tbl		      	OE_Order_PUB.Line_Tbl_Type;
l_item_key                    varchar2(30);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_tbl	      	OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
l_return_status               VARCHAR2(30);
l_tolerance_below  			NUMBER;
l_tolerance_above  			NUMBER;
l_open_line_id 			NUMBER;
l_open_line_rec               OE_Order_PUB.Line_Rec_Type;
l_temp_open_line_rec		OE_Order_PUB.Line_Rec_Type;
l_updated_quantity			NUMBER;
b_om_processing			boolean := FALSE;
						/* to indicate if om processing is needed*/
l_updated_quantity2			NUMBER; -- 04/20/2001 OPM
b_dual_qty			boolean := FALSE; -- 04/20/2001 OPM
b_adjust_open_quantity 		boolean := FALSE;
b_complete_receiving		boolean := FALSE;
b_complete_inspection		boolean := FALSE;
b_negative_correction		boolean := FALSE;
b_neg_corr_zero_qty         boolean := FALSE;
b_positive_correction		boolean := FALSE;
l_temp_var VARCHAR2(2000) := NULL;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_max_qty_to_adjust        NUMBER;
l_line_number              VARCHAR2(30);
l_credit_rejected_qty  VARCHAR2(1); -- Added for bug 6052676
BEGIN

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- OM: Debug Level.  Just remove the comments
  IF To_number(Nvl(fnd_profile.value('ONT_DEBUG_LEVEL'), '0')) > 0 THEN
      oe_debug_pub.initialize;
      l_temp_var := oe_debug_pub.set_debug_mode('FILE');
      oe_debug_pub.debug_on;
  END IF;

  -- Return success if there is no parent and unordered receipt
  IF (p_parent_transaction_type is NULL OR
      p_parent_transaction_type = OE_RMA_RECEIVING.G_RMA_NO_PARENT) AND
     (p_transaction_type = OE_RMA_RECEIVING.G_RMA_UNMATCHED_ORDER) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS NULL OR NO PARENT , TRX TYPE IS UNORDERED' ) ;
      END IF;
     return;
  END IF;

  -- This API is called directly from PO, need to set the oe global context
  OE_GLOBALS.set_context;

  -- This if statement is to allow debug generation by setting the profile option

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_RMA_RECEIVING.PUSH_RECEIVING_INFO' , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RMA_LINE_ID: ' || P_RMA_LINE_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'QUANTITY: ' || P_QUANTITY , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PARENT_TRANSACTION_TYPE: ' || P_PARENT_TRANSACTION_TYPE , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'TRANSACTION_TYPE: ' || P_TRANSACTION_TYPE , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'MISMATCH_FLAG: ' || P_MISMATCH_FLAG , 1 ) ;
  END IF;


  l_item_key := to_char(p_RMA_Line_id);

  --  Query line from p_RMA_Line_ID

  OE_Line_Util.Lock_Rows
  (  p_line_id                     => p_RMA_Line_id
  ,  x_line_tbl				=> l_old_line_tbl
  ,  x_return_status               => l_return_status
  );
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_old_line_tbl(1).db_flag := FND_API.G_TRUE;
  l_line_tbl(1) := l_old_line_tbl(1);

  --  Set control flags.

  l_control_rec.controlled_operation := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.write_to_DB          := TRUE;

  l_control_rec.default_attributes   := TRUE;
  l_control_rec.change_attributes    := TRUE;
  l_control_rec.clear_dependents     := TRUE;

  --  Instruct API to retain its caches

  l_control_rec.clear_api_cache      := FALSE;
  l_control_rec.clear_api_requests   := FALSE;
  -- Fix for bug #1168866. Our internal calls to process order
  -- should suppress security
  l_control_rec.check_security       := FALSE;

  -- setting ship tolerances

  IF (l_line_tbl(1).ship_tolerance_below = FND_API.G_MISS_NUM)
   OR (l_line_tbl(1).ship_tolerance_below is NULL) THEN
     l_tolerance_below := 0.0;
  ELSE
     l_tolerance_below := l_line_tbl(1).ship_tolerance_below * l_line_tbl(1).ordered_quantity/100;
  END IF;

  IF (l_line_tbl(1).ship_tolerance_above = FND_API.G_MISS_NUM)
   OR (l_line_tbl(1).ship_tolerance_above is NULL) THEN
     l_tolerance_above := 0.0;
  ELSE
     l_tolerance_above := l_line_tbl(1).ship_tolerance_above * l_line_tbl(1).ordered_quantity/100;
  END IF;


  -- set boolean for presence of quantity2 for OPM
  IF (p_quantity2 = FND_API.G_MISS_NUM)
   OR (p_quantity2 = 0 )
   OR (p_quantity2 is NULL) THEN
     b_dual_qty := FALSE;
  ELSE
     b_dual_qty := TRUE;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'The Tolerance above is '||l_tolerance_above ) ;
      oe_debug_pub.add(  'The Tolerance below is '||l_tolerance_below ) ;
  END IF;

  -- Fix for Bug #1140815. Receiving module passes us the string 'NO PARENT'
  -- when receiving goods for the first time
  IF (p_parent_transaction_type is NULL OR
      p_parent_transaction_type = OE_RMA_RECEIVING.G_RMA_NO_PARENT) THEN
    IF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_RECEIVE) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS NULL , TRX TYPE IS RECEIVE' ) ;
      END IF;

      -- update shipped_quantity
      b_om_processing := TRUE;
      b_complete_receiving := TRUE;

      -- should not be receiving more than the ordered quantity

      IF ((l_line_tbl(1).shipped_quantity = FND_API.G_MISS_NUM) OR
		 (l_line_tbl(1).shipped_quantity is NULL)) THEN
		l_updated_quantity := p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := p_quantity2; -- 04/20/2001 OPM
	 	END IF;
      ELSE
		l_updated_quantity := l_line_tbl(1).shipped_quantity + p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 + p_quantity2; -- 04/20/2001 OPM
		END IF;
      END IF;

      -- received quantity should be within tolerance
      IF (l_updated_quantity >
        l_line_tbl(1).ordered_quantity + l_tolerance_above) THEN
 		FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_RCVD_QTY');
          OE_MSG_PUB.Add;
	     x_return_status := FND_API.G_RET_STS_ERROR ;
		RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- under return, split the line
      IF (l_updated_quantity <
        l_line_tbl(1).ordered_quantity - l_tolerance_below) then

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNDER RETURN:'||TO_CHAR ( P_QUANTITY ) ||'<'||TO_CHAR ( L_LINE_TBL ( 1 ) .ORDERED_QUANTITY+L_TOLERANCE_BELOW ) , 1 ) ;
         END IF;

        l_open_line_rec.db_flag 			:= FND_API.G_FALSE;
        l_open_line_rec.ordered_quantity
                := l_old_line_tbl(1).ordered_quantity - p_quantity;
        IF b_dual_qty THEN
                l_open_line_rec.ordered_quantity2
                := l_old_line_tbl(1).ordered_quantity2 - p_quantity2; -- 04/20/2001 OPM
        END IF;
        l_open_line_rec.split_from_line_id 	:= p_RMA_Line_ID;
	    l_opeN_line_rec.split_by             := 'SYSTEM';
        l_open_line_rec.operation 			:= OE_GLOBALS.G_OPR_CREATE;
        l_line_tbl(1).ordered_quantity 		:= p_quantity;
        IF b_dual_qty THEN
          l_line_tbl(1).ordered_quantity2 := p_quantity2; -- 04/20/2001 OPM
        END IF;
        l_line_tbl(1).operation 			:= OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(1).shipped_quantity 		:= p_quantity;
        IF b_dual_qty THEN
           l_line_tbl(1).shipped_quantity2 		:= p_quantity2; -- 04/20/2001 OPM
           l_line_tbl(1).shipping_quantity_uom2	:= l_old_line_tbl(1).ordered_quantity_uom2;
        END IF;
	   l_line_tbl(1).shipping_quantity_uom	:= l_old_line_tbl(1).order_quantity_uom;
        l_line_tbl(1).split_action_code 	:= 'SPLIT';
	   l_line_tbl(1).split_by               := 'SYSTEM';
	   b_adjust_open_quantity := TRUE;

      ELSE -- full return

        l_line_tbl(1).shipped_quantity := p_quantity;
        If b_dual_qty THEN
           l_line_tbl(1).shipped_quantity2 		:= p_quantity2; -- 04/20/2001 OPM
           l_line_tbl(1).shipping_quantity_uom2	:= l_old_line_tbl(1).ordered_quantity_uom2;
        END IF;
	   l_line_tbl(1).shipping_quantity_uom := l_old_line_tbl(1).order_quantity_uom;
        l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

      END IF;
      --set the actual shipment date on the RMA line

      SELECT MAX(transaction_date)
      INTO l_line_tbl(1).actual_shipment_date
      FROM rcv_transactions
      WHERE  transaction_type = 'RECEIVE'
      AND    oe_order_line_id = l_line_tbl(1).line_id;

      IF l_line_tbl(1).actual_shipment_date IS NULL THEN
          l_line_tbl(1).actual_shipment_date := sysdate;
      END IF;

    END IF;

  ELSIF (p_parent_transaction_type = OE_RMA_RECEIVING.G_RMA_RECEIVE OR
         p_parent_transaction_type = OE_RMA_RECEIVING.G_RMA_MATCH) THEN
    IF  (p_transaction_type = G_RMA_DELIVER) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RECEIVE , TRX TYPE IS ACCEPT/REJECT/DELIVER' ) ;
      END IF;

      -- update fulfilled_quantity, and possibility to complete inspection.
      b_om_processing := TRUE;

      -- get the current fulfilled quantity
      IF ((l_line_tbl(1).fulfilled_quantity = FND_API.G_MISS_NUM) OR
		 (l_line_tbl(1).fulfilled_quantity is NULL)) THEN
		l_updated_quantity := p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := p_quantity2; -- 04/20/2001 OPM
	 	END IF;
      ELSE
		l_updated_quantity := l_line_tbl(1).fulfilled_quantity + p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := l_line_tbl(1).fulfilled_quantity2 + p_quantity2; -- 04/20/2001 OPM
	 	END IF;
      END IF;

      -- over quantity being passed
      IF (l_line_tbl(1).shipped_quantity < l_updated_quantity ) THEN
 		FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_DLVR_QTY');
          OE_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_line_tbl(1).fulfilled_quantity := l_updated_quantity;
      IF b_dual_qty THEN
		l_line_tbl(1).fulfilled_quantity2 := l_updated_quantity2; -- 04/20/2001 OPM
      END IF;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

      IF (l_line_tbl(1).shipped_quantity = l_updated_quantity) THEN
		b_complete_inspection := TRUE;
      END IF;

    ELSIF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_RETURN_TO_CUSTOMER) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RECEIVE , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      -- update shipped_quantity
      b_om_processing := TRUE;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RECEIVE , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      l_updated_quantity := l_line_tbl(1).shipped_quantity - p_quantity;
      IF b_dual_qty THEN
      		l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 - p_quantity2; -- 04/20/2001 OPM
      		l_line_tbl(1).shipped_quantity2 := l_updated_quantity2;
      END IF;
      l_line_tbl(1).shipped_quantity := l_updated_quantity;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security := FALSE;

      -- Bug 7692369 : WORKFLOW STUCK THOUGH THE LINE IS FULFILLED IN CASE FULL RETURN TO CUSTOMER
      -- This is because comparision of fulfilled quantity w/o NVL condition.
      -- Adding NVL to resolve this bug.
      IF (l_line_tbl(1).shipped_quantity = NVL(l_line_tbl(1).fulfilled_quantity,0))
      THEN
          b_complete_inspection := TRUE;
      END IF;


    ELSIF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_CORRECT) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RECEIVE , TRX TYPE IS CORRECT' ) ;
      END IF;

      -- update shipped_quantity and adjust remaining open quantity
      b_om_processing := TRUE;

      -- check whether it is an upgrade or downgrade
      -- if p_quantity is positive, we should check whether we can receive
      -- on the current line. Otherwise give error..
      -- if p_quantity is negative, we should adjust the ordered
      -- quantity and shipped quantity of the line, and adjust
      -- the remaining open line or split the current line.

      l_open_line_id := Get_Open_Line_Id(l_line_tbl(1));

      IF (l_open_line_id is NOT NULL) THEN
          IF l_debug_level  > 0 THEN
          oe_debug_pub.add('There is an Open Line Id' ) ;
          END IF;
        OE_Line_Util.Lock_Row
		(p_line_id 		=> l_open_line_id
		,p_x_line_rec		=> l_temp_open_line_rec
	     ,x_return_status    => l_return_status
		);
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      IF ( p_quantity > 0 ) THEN  -- received more
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'QUANTITY IS POSITIVE' ) ;
         END IF;

	     l_updated_quantity := l_line_tbl(1).shipped_quantity + p_quantity;
	     IF b_dual_qty THEN
              l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 +
                                     p_quantity2; -- 04/20/2001 OPM
	     END IF;
         -- Check if updated qty is within + tolerance
         IF l_updated_quantity <=
	   		(l_line_tbl(1).ordered_quantity + l_tolerance_above) THEN
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Change is within tolerance' ) ;
              END IF;
	          -- adjust the shipped_quantity and ordered_quantity
	          l_line_tbl(1).shipped_quantity := l_updated_quantity;
	          IF b_dual_qty THEN
	      		l_line_tbl(1).shipped_quantity2 := l_updated_quantity2; -- 04/20/2001 OPM
	      	  END IF;
	          l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
         ELSE
               l_max_qty_to_adjust := l_line_tbl(1).ordered_quantity +
                                      l_tolerance_above -
                                      l_line_tbl(1).shipped_quantity;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'Above Tolerance, raise ERROR' ) ;
               END IF;
               IF l_open_line_id is NOT NULL THEN
                  l_line_number := l_temp_open_line_rec.line_number||'.'||
                                   l_temp_open_line_rec.shipment_number;
 		          FND_MESSAGE.Set_Name('ONT', 'OE_RECEIVE_ON_OPEN_LINE');
                  FND_MESSAGE.Set_Token('LINENUMBER', l_line_number);
               ELSE
                  IF l_max_qty_to_adjust > 0 THEN
 		              FND_MESSAGE.Set_Name('ONT', 'OE_MAX_CORRECTION_QTY');
                      FND_MESSAGE.Set_Token('CORRECTIONQTY',
                             to_char(l_max_qty_to_adjust)||' '||
                             l_line_tbl(1).ORDER_QUANTITY_UOM);
                  ELSE
 		              FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_RCVD_QTY');
                  END IF;
               END IF;
               OE_MSG_PUB.Add;
	           x_return_status := FND_API.G_RET_STS_ERROR ;
	           RAISE FND_API.G_EXC_ERROR;
         END IF;
        -- Never receive on open line as this line will never have any receipt
        -- associated with it.

    ELSE -- received less. adjust the qty of the current line,
         -- and adjust the quantity of the open line.

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('For -ve correction ');
       END IF;
	    -- adjust the shipped_quantity and ordered_quantity
	    l_updated_quantity := l_line_tbl(1).shipped_quantity + p_quantity;
	    l_line_tbl(1).shipped_quantity := l_updated_quantity;
	    IF b_dual_qty THEN
	    	l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 + p_quantity2; -- 04/20/2001 OPM
	    	l_line_tbl(1).shipped_quantity := l_updated_quantity;
	    END IF;

	    l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
	    l_control_rec.check_security := FALSE;

	    IF (l_open_line_id is NULL) THEN -- no open line

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add('No Open Line: l_updated QTY is '
                                ||l_updated_quantity);
           END IF;
           IF ( l_updated_quantity not between
			(l_line_tbl(1).ordered_quantity - l_tolerance_below) and
	   		(l_line_tbl(1).ordered_quantity + l_tolerance_above)) OR
            ( l_updated_quantity = 0 ) THEN
	          -- split line if the l_updated_quantity is > 0.
              IF l_updated_quantity > 0 THEN
                  l_open_line_rec.db_flag := FND_API.G_FALSE;
                  l_open_line_rec.ordered_quantity := -p_quantity;
                  IF b_dual_qty THEN
                     l_open_line_rec.ordered_quantity2 := -p_quantity2;
                     -- 04/20/2001 OPM
	              END IF;
                  IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Split the current line ' );
                  END IF;
	              l_open_line_rec.split_from_line_id := p_RMA_Line_ID;
		          l_open_line_rec.split_by           := 'SYSTEM';
                  l_open_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
                  b_adjust_open_quantity := TRUE;

	              l_line_tbl(1).ordered_quantity := l_updated_quantity;
                  IF b_dual_qty THEN
                     l_line_tbl(1).ordered_quantity2 := l_updated_quantity2;
                     -- 04/20/2001 OPM
	      	      END IF;
                  l_line_tbl(1).split_action_code := 'SPLIT';
		          l_line_tbl(1).split_by          := 'SYSTEM';

                  b_negative_correction := TRUE;
              ELSIF l_updated_quantity = 0 THEN
                  -- Take the received line back to AWAITING_RETURN
                  IF l_debug_level  > 0 THEN
                       oe_debug_pub.add('Take the line back to AWAITING_RETURN' );
                  END IF;
                  b_neg_corr_zero_qty := TRUE;
	              l_line_tbl(1).shipped_quantity := NULL;
	              IF b_dual_qty THEN
	    	 	     l_line_tbl(1).shipped_quantity2 := NULL; -- 04/20/2001 OPM
	              END IF;
	              l_line_tbl(1).flow_status_code := 'AWAITING_RETURN';
              ELSE
                 FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_RCVD_QTY');
                 OE_MSG_PUB.Add;
	             x_return_status := FND_API.G_RET_STS_ERROR ;
	             RAISE FND_API.G_EXC_ERROR;
              END IF;

           END IF; -- IF l_updated_quantity not between

           -- Added fix for issue 5078844
           IF l_line_tbl(1).ordered_quantity = l_line_tbl(1).fulfilled_quantity
              and l_line_tbl(1).flow_status_code='AWAITING_RETURN_DISPOSITION'
           THEN
               b_complete_inspection := TRUE;
           END IF;


         ELSE -- IF (l_open_line_id is NOT NULL) THEN

            IF l_updated_quantity > 0 THEN
                -- Correct the quantity on original line
	            l_line_tbl(1).ordered_quantity := l_updated_quantity;
	            IF b_dual_qty THEN
                   l_line_tbl(1).ordered_quantity2 := l_updated_quantity2;
                   -- 04/20/2001 OPM
	            END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add('Adjusting ordered qty on open line' );
                END IF;

	             -- adjust the open ordered_quantity
                l_open_line_rec := l_temp_open_line_rec;
	            l_updated_quantity := l_open_line_rec.ordered_quantity -
                                      p_quantity;
	            l_open_line_rec.ordered_quantity := l_updated_quantity;
	            IF b_dual_qty THEN
	    	 	    l_updated_quantity2 := l_open_line_rec.ordered_quantity2 -
                                           p_quantity2; -- 04/20/2001 OPM
	        	    l_open_line_rec.ordered_quantity2 := l_updated_quantity2;
	      	    END IF;
	            l_open_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
                b_adjust_open_quantity := TRUE;
            ELSIF l_updated_quantity = 0 THEN
                -- Take the received line back to AWAITING_RETURN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Taking the line back to AWAITING_RETURN');
                END IF;
                b_neg_corr_zero_qty := TRUE;
	            l_line_tbl(1).shipped_quantity := NULL;
	            IF b_dual_qty THEN
	    	 	   l_line_tbl(1).shipped_quantity2 := NULL; -- 04/20/2001 OPM
	            END IF;
	            l_line_tbl(1).flow_status_code := 'AWAITING_RETURN';
            ELSE
                -- Give error that it is a wrong correction
                FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_RCVD_QTY');
                OE_MSG_PUB.Add;
	            x_return_status := FND_API.G_RET_STS_ERROR ;
	            RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- IF (l_open_line_id is NULL) THEN

      END IF;

    END IF;
  ELSIF (p_parent_transaction_type in (G_RMA_ACCEPT,G_RMA_REJECT)) THEN
    IF ( p_transaction_type = G_RMA_DELIVER) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS ACCEPT/REJECT , TRX TYPE IS DELIVER' ) ;
      END IF;

      -- update fulfilled_quantity, and possibility to complete inspection.
      b_om_processing := TRUE;

      -- get the current fulfilled quantity
      IF ((l_line_tbl(1).fulfilled_quantity = FND_API.G_MISS_NUM) OR
           (l_line_tbl(1).fulfilled_quantity is NULL)) THEN
          l_updated_quantity := p_quantity;
          IF b_dual_qty THEN
			l_updated_quantity2 := p_quantity2; -- 04/20/2001 OPM
	 	END IF;
      ELSE
          l_updated_quantity := l_line_tbl(1).fulfilled_quantity + p_quantity;
          IF b_dual_qty THEN
			l_updated_quantity2 := l_line_tbl(1).fulfilled_quantity2 + p_quantity2; -- 04/20/2001 OPM
	  END IF;
      END IF;

      -- over quantity being passed
      IF (l_line_tbl(1).shipped_quantity < l_updated_quantity ) THEN
 		FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_DLVR_QTY');
          OE_MSG_PUB.Add;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* Commented for Bug 5501949
      l_line_tbl(1).fulfilled_quantity := l_updated_quantity;
      IF b_dual_qty THEN
		l_line_tbl(1).fulfilled_quantity2 := l_updated_quantity2; -- 04/20/2001 OPM
      END IF;
      */


  l_credit_rejected_qty := nvl(FND_PROFILE.VALUE('ONT_GENERATE_CREDIT_REJECTED_RETURNS'), 'N'); -- Added for bug 6052676

      IF l_debug_level > 0 THEN
        oe_debug_pub.add(' Profile : ONT_GENERATE_CREDIT_REJECTED_RETURNS : ' || l_credit_rejected_qty, 5);
      END IF;


 /* Modified below IF and ELSIF conditions for bug 6052676 */

/* Start bug 5501949 */

/* Start bug 6052676 */

      IF p_parent_transaction_type = G_RMA_REJECT AND l_credit_rejected_qty ='N'
 THEN
         l_line_tbl(1).shipped_quantity := l_line_tbl(1).shipped_quantity - p_quantity;
         IF b_dual_qty THEN
           l_line_tbl(1).shipped_quantity2 := l_line_tbl(1).shipped_quantity2 - p_quantity2;
         END IF;
      ELSIF p_parent_transaction_type = G_RMA_ACCEPT OR ( p_parent_transaction_type = G_RMA_REJECT AND l_credit_rejected_qty ='Y' ) THEN
         l_line_tbl(1).fulfilled_quantity := l_updated_quantity;
         IF b_dual_qty THEN
                l_line_tbl(1).fulfilled_quantity2 := l_updated_quantity2;
         END IF;
      END IF;
      /* End Bug 5501949 */
 /* End Bug 6052676 */


      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

      -- Modified for Bug 5501949 IF (l_line_tbl(1).shipped_quantity = l_updated_quantity) THEN
      --Added NVL for bug 6110517
      IF nvl(l_line_tbl(1).shipped_quantity,0) = nvl(l_line_tbl(1).fulfilled_quantity,0) THEN
          b_complete_inspection := TRUE;
      END IF;

    ELSIF (p_transaction_type = G_RMA_RETURN_TO_CUSTOMER) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PARENT IS ACCEPT/REJECT , TRX TYPE IS RETURN TO CUSTOMER' ) ;
     END IF;

      -- update shipped_quantity
      b_om_processing := TRUE;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RECEIVE , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      l_updated_quantity := l_line_tbl(1).shipped_quantity - p_quantity;
      IF b_dual_qty THEN
      		l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 - p_quantity2; -- 04/20/2001 OPM
      		l_line_tbl(1).shipped_quantity2 := l_updated_quantity2;
      END IF;
      l_line_tbl(1).shipped_quantity := l_updated_quantity;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security := FALSE;

      -- For the bug fix 5099112
      -- FOR the bug fix 7571804
	  IF NVL(l_line_tbl(1).shipped_quantity,0) = NVL(l_line_tbl(1).fulfilled_quantity,0)
      AND l_line_tbl(1).flow_status_code='AWAITING_RETURN_DISPOSITION'
	  THEN
          b_complete_inspection := TRUE;
      END IF;
    END IF;
  ELSIF (p_parent_transaction_type = OE_RMA_RECEIVING.G_RMA_DELIVER) THEN

    IF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_RETURN_TO_CUSTOMER) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS DELIVER , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      -- update shipped_quantity and fulfilled_quantity
      b_om_processing := TRUE;

      l_line_tbl(1).shipped_quantity
			:= l_line_tbl(1).shipped_quantity - p_quantity;
      l_line_tbl(1).fulfilled_quantity
			:= l_line_tbl(1).fulfilled_quantity - p_quantity;
      IF b_dual_qty THEN
      	l_line_tbl(1).shipped_quantity2
			:= l_line_tbl(1).shipped_quantity2 - p_quantity2; -- 04/20/2001 OPM
      	l_line_tbl(1).fulfilled_quantity2
			:= l_line_tbl(1).fulfilled_quantity2 - p_quantity2;
      END IF;
      l_line_tbl(1).operation 		:= OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security 	:= FALSE;


    ELSIF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_RETURN_TO_RECEIVING) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS DELIVER , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      -- update fulfilled_quantity
      b_om_processing := TRUE;

      l_updated_quantity := l_line_tbl(1).fulfilled_quantity - p_quantity;
      l_line_tbl(1).fulfilled_quantity := l_updated_quantity;
      IF b_dual_qty THEN
      	l_updated_quantity2 := l_line_tbl(1).fulfilled_quantity2 - p_quantity2; -- 04/20/2001 OPM
        l_line_tbl(1).fulfilled_quantity2 := l_updated_quantity2;
      END IF;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security := FALSE;


    ELSIF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_CORRECT) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS DELIVER , TRX TYPE IS RETURN TO CUSTOMER' ) ;
      END IF;

      -- update fulfilled_quantity
      b_om_processing := TRUE;

      l_updated_quantity := l_line_tbl(1).fulfilled_quantity + p_quantity;
      l_line_tbl(1).fulfilled_quantity := l_updated_quantity;
      IF b_dual_qty THEN
      	l_updated_quantity2 := l_line_tbl(1).fulfilled_quantity2 + p_quantity2; -- 04/20/2001 OPM
      	l_line_tbl(1).fulfilled_quantity2 := l_updated_quantity2;
      END IF;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security := FALSE;

      -- do we want to check if the line gets fulfilled at this point?

    END IF;

   ELSIF (p_parent_transaction_type =
	  OE_RMA_RECEIVING.G_RMA_RETURN_TO_CUSTOMER) THEN

    IF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_CORRECT) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RETURN TO CUST , TRX TYPE IS CORRECT' ) ;
      END IF;

      -- update shipped_quantity and fulfilled_quantity
      b_om_processing := TRUE;

      l_line_tbl(1).shipped_quantity
			:= l_line_tbl(1).shipped_quantity - p_quantity;

      -- No need to update fulfilled_quantity as this Return To Customer has
      -- happen before delivery transaction. Fix for bug 2811397
      -- l_line_tbl(1).fulfilled_quantity
	  --		:= l_line_tbl(1).fulfilled_quantity - p_quantity;

      -- PO can specify the Trn that happened before return to customer we
      -- can now reduce the fulfilled qty if the item was delivered before
      -- return to customer.

      IF p_R2Cust_Parent_Trn_Type = G_RMA_DELIVER AND
         l_line_tbl(1).fulfilled_quantity > 0
      THEN
          l_line_tbl(1).fulfilled_quantity
            := l_line_tbl(1).fulfilled_quantity - p_quantity;

          IF b_dual_qty and l_line_tbl(1).fulfilled_quantity2 > 0 THEN
              l_line_tbl(1).fulfilled_quantity2
                  := l_line_tbl(1).fulfilled_quantity2 - p_quantity2;
          END IF;
      END IF;

      IF b_dual_qty THEN
      	l_line_tbl(1).shipped_quantity2
			:= l_line_tbl(1).shipped_quantity2 - p_quantity2; -- 04/20/2001 OPM
      END IF;

      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
      l_control_rec.check_security := FALSE;

      IF l_line_tbl(1).shipped_quantity = l_line_tbl(1).fulfilled_quantity
      AND l_line_tbl(1).flow_status_code='AWAITING_RETURN_DISPOSITION'
      THEN
          b_complete_inspection := TRUE;
      END IF;


    END IF;

   ELSIF (p_parent_transaction_type =
	  OE_RMA_RECEIVING.G_RMA_RETURN_TO_RECEIVING) THEN

    IF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_CORRECT) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS RETURN TO RECEIVING , TRX TYPE IS CORRECT' ) ;
      END IF;

      -- update fulfilled_quantity
      b_om_processing := TRUE;

      l_line_tbl(1).fulfilled_quantity
			:= l_line_tbl(1).fulfilled_quantity - p_quantity;
      IF b_dual_qty THEN
      	l_line_tbl(1).fulfilled_quantity2
			:= l_line_tbl(1).fulfilled_quantity2 - p_quantity2; -- 04/20/2001 OPM
      END IF;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

    END IF;

   ELSIF (p_parent_transaction_type =
	  OE_RMA_RECEIVING.G_RMA_UNMATCHED_ORDER) THEN

    IF (p_transaction_type = OE_RMA_RECEIVING.G_RMA_MATCH) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARENT IS UNMATCHED ORDER , TRX TYPE IS MATCH ' ) ;
      END IF;

      -- update shipped_quantity
      b_om_processing := TRUE;
      b_complete_receiving := TRUE;

      -- should not be receiving more than the ordered quantity

      IF ((l_line_tbl(1).shipped_quantity = FND_API.G_MISS_NUM) OR
		 (l_line_tbl(1).shipped_quantity is NULL)) THEN
		l_updated_quantity := p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := p_quantity2; -- 04/20/2001 OPM
 		END IF;
      ELSE
		l_updated_quantity := l_line_tbl(1).shipped_quantity + p_quantity;
		IF b_dual_qty THEN
			l_updated_quantity2 := l_line_tbl(1).shipped_quantity2 + p_quantity2; -- 04/20/2001 OPM
		END IF;
      END IF;

       -- received quantity should be within tolerance
      IF (l_updated_quantity >
        l_line_tbl(1).ordered_quantity + l_tolerance_above) THEN
 		FND_MESSAGE.Set_Name('ONT', 'OE_RETURN_INVALID_RCVD_QTY');
          OE_MSG_PUB.Add;
	     x_return_status := FND_API.G_RET_STS_ERROR ;
		RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- under return, split the line
      IF (l_updated_quantity <
        l_line_tbl(1).ordered_quantity - l_tolerance_below) then

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UNDER RETURN:'||TO_CHAR ( P_QUANTITY ) ||'<'||TO_CHAR ( L_LINE_TBL ( 1 ) .ORDERED_QUANTITY+L_TOLERANCE_BELOW ) , 1 ) ;
         END IF;

        l_open_line_rec.db_flag 		:= FND_API.G_FALSE;
        l_open_line_rec.ordered_quantity
                := l_old_line_tbl(1).ordered_quantity - p_quantity;
        l_open_line_rec.split_from_line_id 	:= p_RMA_Line_ID;
	   l_open_line_rec.split_by        := 'SYSTEM';
        l_open_line_rec.operation 		:= OE_GLOBALS.G_OPR_CREATE;
        l_line_tbl(1).ordered_quantity 		:= p_quantity;
        l_line_tbl(1).operation 			:= OE_GLOBALS.G_OPR_UPDATE;
        l_line_tbl(1).shipped_quantity 		:= p_quantity;

        IF b_dual_qty THEN
        	l_open_line_rec.ordered_quantity2
                := l_old_line_tbl(1).ordered_quantity2 - p_quantity2;
                l_line_tbl(1).ordered_quantity2 		:= p_quantity2; -- 04/20/2001 OPM
          	l_line_tbl(1).shipped_quantity2 		:= p_quantity2;
        END IF;
        l_line_tbl(1).split_action_code 	:= 'SPLIT';
	   l_line_tbl(1).split_by               := 'SYSTEM';
	   b_adjust_open_quantity := TRUE;

      ELSE -- full return

        l_line_tbl(1).shipped_quantity := p_quantity;
        IF b_dual_qty THEN
          	l_line_tbl(1).shipped_quantity2	:= p_quantity2; -- 04/20/2001 OPM
        END IF;


        l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

      END IF;

      -- Set the actual shipment date on the RMA line
      -- We will need to look at UNORDERED transaction to figure out
      -- the actual shipment date.
      SELECT MAX(transaction_date)
      INTO l_line_tbl(1).actual_shipment_date
      FROM rcv_transactions
      WHERE  transaction_type = 'UNORDERED'
      AND oe_order_line_id = l_line_tbl(1).line_id;

      IF l_line_tbl(1).actual_shipment_date IS NULL THEN
          l_line_tbl(1).actual_shipment_date := sysdate;
      END IF;

    END IF;

  END IF;  -- p_parent_transaction_type

  IF (b_om_processing) THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OM_PROCESSING , CALLING PROCESS ORDER' ) ;
    END IF;

     IF (b_adjust_open_quantity) THEN

       l_line_tbl(2) := l_open_line_rec;

     END IF;

     --  Call OE_Order_PVT.Process_order

     OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_old_line_tbl                => l_old_line_tbl
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
--serla end
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl          => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS ORDER Return Status IS '||x_return_status);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- complete workflow activity

    IF (b_complete_receiving) THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In b_complete_receiving ');
    END IF;

      WF_ENGINE.CompleteActivityInternalName('OEOL', l_item_key,
           'RMA_WAIT_FOR_RECEIVING', 'COMPLETE');

    ELSIF (b_complete_inspection) THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In b_complete_inspection ');
    END IF;
      WF_ENGINE.CompleteActivityInternalName('OEOL', l_item_key,
           'RMA_WAIT_FOR_INSPECTION', 'COMPLETE');

    END IF; -- complete wf activity


   IF (b_neg_corr_zero_qty) THEN
      l_item_key := to_char(l_line_tbl(1).line_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In b_neg_corr_zero_qty ');
    END IF;
      WF_ENGINE.CompleteActivityInternalName('OEOL', l_item_key,
           'RMA_WAIT_FOR_INSPECTION', 'CORRECT_RECEIVING');
   END IF;

   IF (b_negative_correction) THEN
      l_item_key := to_char(l_line_tbl(2).line_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In b_negative_correction ');
    END IF;
      WF_ENGINE.CompleteActivityInternalName('OEOL', l_item_key,
           'RMA_WAIT_FOR_INSPECTION', 'CORRECT_RECEIVING');
   ELSIF (b_positive_correction) THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'In b_positive_correction ');
    END IF;
      l_item_key := to_char(l_line_tbl(1).line_id);

      WF_ENGINE.CompleteActivityInternalName('OEOL', l_item_key,
           'RMA_WAIT_FOR_RECEIVING', 'COMPLETE');
   END IF;

   -- Set the line Flow status

   IF b_complete_receiving or b_positive_correction THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CALLING FLOW STATUS API 1 ' ||l_item_key ) ;
			END IF;

               OE_Order_WF_Util.Update_Flow_Status_Code
                    (p_line_id               =>  to_number(l_item_key),
                     p_flow_status_code      =>  'AWAITING_RETURN_DISPOSITION',
                     x_return_status         =>  l_return_status
                     );

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API 1 '|| L_RETURN_STATUS , 1 ) ;
                    END IF;

               IF   l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF     l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
               END IF;

   END IF;

   IF b_complete_inspection THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'CALLING FLOW STATUS API 2 ' ||l_item_key);
			END IF;

               OE_Order_WF_Util.Update_Flow_Status_Code
                    (p_line_id               =>  to_number(l_item_key),
                     p_flow_status_code      =>  'RETURNED',
                     x_return_status         =>  l_return_status
                     );

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RETURN STATUS FROM FLOW STATUS API 2'|| L_RETURN_STATUS , 1 ) ;
                    END IF;

               IF   l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF     l_return_status = FND_API.G_RET_STS_ERROR THEN
                         RAISE FND_API.G_EXC_ERROR;
               END IF;

   END IF;

  END IF; -- if b_om_processing.

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Returning From Push_Receiving_Info '|| x_return_status);
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    OE_MSG_PUB.Get
        (   p_msg_index				=> OE_MSG_PUB.G_LAST
	   ,   p_encoded  				=> FND_API.G_FALSE
        ,   p_data                      => x_msg_data
	   ,	  p_msg_index_out             => x_msg_count
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF OE_MSG_PUB.Check_MSg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (G_PKG_NAME
           ,'Push_Receiving_Info'
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    OE_MSG_PUB.Get
        (   p_msg_index				=> OE_MSG_PUB.G_LAST
	   ,   p_encoded  				=> FND_API.G_FALSE
        ,   p_data                      => x_msg_data
	   ,	  p_msg_index_out             => x_msg_count
        );

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
            OE_MSG_PUB.Add_Exc_Msg
	      (   G_PKG_NAME
		    ,   'Push_Receiving_Info'
		  );
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    OE_MSG_PUB.Get
        (   p_msg_index				=> OE_MSG_PUB.G_LAST
	   ,   p_encoded  				=> FND_API.G_FALSE
        ,   p_data                      => x_msg_data
	   ,	  p_msg_index_out             => x_msg_count
        );

END Push_Receiving_Info;


FUNCTION Get_Open_Line_Id (p_line_rec  IN OE_ORDER_PUB.line_rec_type)
RETURN NUMBER
IS

l_open_line_id	     NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SELECT 	l.line_id
  INTO		l_open_line_id
  FROM		oe_order_lines l,
                wf_item_activity_statuses wf,
                wf_process_activities wpa
  WHERE		l.open_flag = 'Y'
  and  		wpa.activity_item_type='OEOL'
  and 		wpa.activity_name='RMA_WAIT_FOR_RECEIVING'
  and 		wf.item_type='OEOL'
  and 		wf.process_activity=wpa.instance_id
  and 		wf.activity_status='NOTIFIED'
--  and 		l.line_id=to_number(wf.item_key)
  and 		to_char(l.line_id) = wf.item_key    --FP bug#5758850
  and 		l.line_set_id = p_line_rec.line_set_id
  and 		l.shipped_quantity is null
  and 		l.line_id<>p_line_rec.line_id
  and       rownum = 1;

  RETURN l_open_line_id;

EXCEPTION

WHEN NO_DATA_FOUND THEN
		RETURN NULL;

END Get_Open_Line_Id;

/* This procedure is for PO to find remaining open quantity from OE.
   After a line is under-received, OE split the line into two lines,
   one with the received qty, another with the remaining qty.  This API
   shields PO from the splitting */
Procedure Get_RMA_Available_Quantity(p_RMA_Line_ID   In Number,
x_Quantity out nocopy Number,

x_Return_Status out nocopy Varchar2,

x_Msg_Count out nocopy Number,

x_MSG_Data out nocopy Varchar2)

IS
l_quantity                    NUMBER;
l_open_flag                     VARCHAR2(1);
l_inv_interface_status_code     VARCHAR2(30);
l_ordered_quantity              NUMBER;
l_shipped_quantity              NUMBER;
l_line_set_id                   NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- OE_GLOBALS.set_context; -- removed for MOAC.
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'G_ORG_ID='||TO_CHAR ( OE_GLOBALS.G_ORG_ID ) , 1 ) ;
  END IF;
  SELECT open_flag,
         invoice_interface_status_code,
         ordered_quantity,
         shipped_quantity,
         line_set_id
  INTO   l_open_flag,
         l_inv_interface_status_code,
         l_ordered_quantity,
         l_shipped_quantity,
         l_line_set_id
  FROM OE_ORDER_LINES_ALL
  WHERE line_id = p_rma_line_id;

  IF (l_open_flag = 'N' OR
    l_inv_interface_status_code IS NOT NULL OR
    l_ordered_quantity = l_shipped_quantity) THEN
    /* this line is closed, or AR interfaced, or fully received */
          select l.ordered_quantity
           into x_quantity
           from oe_order_lines_all l,
                wf_item_activity_statuses wf,
                wf_process_activities wpa
           where l.open_flag = 'Y'
           and  wpa.activity_item_type='OEOL'
           and wpa.activity_name='RMA_WAIT_FOR_RECEIVING'
           and wf.item_type='OEOL'
           and wf.process_activity=wpa.instance_id
           and wf.activity_status='NOTIFIED'
--           and l.line_id=to_number(wf.item_key)
           and to_char(l.line_id) = wf.item_key     -- FP bug#5758850
           and l.line_set_id = l_line_set_id
           and l.shipped_quantity is null and l.line_id<>p_RMA_line_id;
  ELSE
    x_quantity := l_ordered_quantity - nvl(l_shipped_quantity,0);
  END IF;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
	x_quantity := 0;

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_RMA_Available_Quantity'
            );
        END IF;
END Get_RMA_Available_Quantity;

/* This procedure is used by PO to get over and under return tolerances
 for a RMA Line. */

Procedure Get_RMA_Tolerances(
          p_RMA_Line_ID            In Number,
x_Under_Return_Tolerance out nocopy Number,

x_Over_Return_Tolerance out nocopy Number,

x_Return_Status out nocopy Varchar2,

x_Msg_Count out nocopy Number,

x_MSG_Data out nocopy Varchar2

          )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


     Select SHIP_TOLERANCE_BELOW, SHIP_TOLERANCE_ABOVE
     into x_Under_Return_Tolerance,x_Over_Return_Tolerance
     from oe_order_lines_all
     Where line_id = p_RMA_Line_ID;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_RMA_Tolerances'
            );
        END IF;

          --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_RMA_Tolerances;

END OE_RMA_RECEIVING;

/
