--------------------------------------------------------
--  DDL for Package Body OE_UPDATE_HEADER_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPDATE_HEADER_ACK_UTIL" AS
/* $Header: OEXUHAUB.pls 120.0 2005/06/01 01:59:49 appldev noship $ */

PROCEDURE Update_Header_Ack(
   p_request_id			IN  NUMBER
  ,p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_change_sequence            IN  VARCHAR2
,p_msg_count OUT NOCOPY NUMBER

,p_msg_data OUT NOCOPY VARCHAR2

,p_return_status OUT NOCOPY VARCHAR2

) is
  l_control_rec                 OE_Globals.Control_Rec_Type;

  l_header_rec                  OE_Order_Pub.Header_Rec_Type;
  l_header_rec_new              OE_Order_Pub.Header_Rec_Type;
  l_header_adj_rec  		OE_Order_Pub.Header_Adj_Rec_Type;
  l_header_adj_tbl  		OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_adj_tbl_new  	OE_Order_Pub.Header_Adj_Tbl_Type;
  l_header_price_att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_header_price_att_tbl_new    OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_header_adj_att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_header_adj_att_tbl_new      OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_header_adj_assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_header_adj_assoc_tbl_new    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_header_scredit_rec          OE_Order_Pub.Header_Scredit_Rec_Type;
  l_header_scredit_tbl      	OE_Order_Pub.Header_Scredit_Tbl_Type;
  l_header_scredit_tbl_new      OE_Order_Pub.Header_Scredit_Tbl_Type;

  l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;
  l_header_val_rec_new          OE_Order_Pub.Header_Val_Rec_Type;
  l_header_adj_val_rec  	OE_Order_Pub.Header_Adj_Val_Rec_Type;
  l_header_adj_val_tbl  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_adj_val_tbl_new  	OE_Order_Pub.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_rec      OE_Order_Pub.Header_Scredit_Val_Rec_Type;
  l_header_scredit_val_tbl      OE_Order_Pub.Header_Scredit_Val_Tbl_Type;
  l_header_scredit_val_tbl_new  OE_Order_Pub.Header_Scredit_Val_Tbl_Type;

  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_tbl_new                OE_Order_Pub.Line_Tbl_Type;
  l_line_adj_rec                OE_Order_Pub.Line_Adj_Rec_Type;
  l_line_adj_tbl                OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_adj_tbl_new            OE_Order_Pub.Line_Adj_Tbl_Type;
  l_line_price_att_tbl          OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_price_att_tbl_new      OE_Order_Pub.Line_Price_Att_Tbl_Type;
  l_line_adj_att_tbl            OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_att_tbl_new        OE_Order_Pub.Line_Adj_Att_Tbl_Type;
  l_line_adj_assoc_tbl          OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_adj_assoc_tbl_new      OE_Order_Pub.Line_Adj_Assoc_Tbl_Type;
  l_line_scredit_rec            OE_Order_Pub.Line_Scredit_Rec_Type;
  l_line_scredit_tbl            OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_line_scredit_tbl_new        OE_Order_Pub.Line_Scredit_Tbl_Type;
  l_lot_serial_rec         	OE_Order_Pub.Lot_Serial_Rec_Type;
  l_lot_serial_tbl         	OE_Order_Pub.Lot_Serial_Tbl_Type;
  l_lot_serial_tbl_new     	OE_Order_Pub.Lot_Serial_Tbl_Type;

  l_line_val_rec                OE_Order_Pub.Line_Val_Rec_Type;
  l_line_val_tbl                OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_val_tbl_new            OE_Order_Pub.Line_Val_Tbl_Type;
  l_line_adj_val_rec  		OE_Order_Pub.Line_Adj_Val_Rec_Type;
  l_line_adj_val_tbl  		OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_adj_val_tbl_new  	OE_Order_Pub.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_rec        OE_Order_Pub.Line_Scredit_Val_Rec_Type;
  l_line_scredit_val_tbl        OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_line_scredit_val_tbl_new    OE_Order_Pub.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_rec          OE_Order_Pub.Lot_Serial_Val_Rec_Type;
  l_lot_serial_val_tbl          OE_Order_Pub.Lot_Serial_Val_Tbl_Type;
  l_lot_serial_val_tbl_new      OE_Order_Pub.Lot_Serial_Val_Tbl_Type;

  l_action_request_rec          OE_Order_Pub.Request_Rec_Type;
  l_action_request_tbl	        OE_Order_Pub.Request_Tbl_Type;
  l_action_request_tbl_new      OE_Order_Pub.Request_Tbl_Type;

  l_header_count		NUMBER := 0;
  l_line_count		        NUMBER := 0;
  l_lot_serial_count		NUMBER := 0;

  l_order_source_id		NUMBER;
  l_orig_sys_document_ref	VARCHAR2(50);
  l_orig_sys_line_ref		VARCHAR2(50);
  l_orig_sys_shipment_ref	VARCHAR2(50);

  l_init_msg_list		VARCHAR2(1) := FND_API.G_TRUE;
  l_validation_level 		NUMBER := FND_API.G_VALID_LEVEL_FULL;

  l_msg_index              	NUMBER;

  l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Header_Ack';


    CURSOR l_header_cursor IS
    SELECT order_source_id
    	 , orig_sys_document_ref
	 , change_sequence
	 , nvl(org_id,				FND_API.G_MISS_NUM)
	 , nvl(header_id,			FND_API.G_MISS_NUM)
	 , nvl(order_number,			FND_API.G_MISS_NUM)
	 , nvl(ordered_date,			FND_API.G_MISS_DATE)
	 , nvl(order_type_id,			FND_API.G_MISS_NUM)
	 , nvl(first_ack_code,			FND_API.G_MISS_CHAR)
	 , nvl(first_ack_date,			FND_API.G_MISS_DATE)
	 , nvl(last_ack_code,			FND_API.G_MISS_CHAR)
	 , nvl(last_ack_date,			FND_API.G_MISS_DATE)
      FROM oe_order_headers
     WHERE order_source_id 			= l_order_source_id
       AND orig_sys_document_ref 		= l_orig_sys_document_ref
;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/* -----------------------------------------------------------
   Initialization
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE INITIALIZATION' ) ;
   END IF;

  l_header_rec 			:= OE_Order_Pub.G_MISS_HEADER_REC;
  l_header_rec_new 		:= OE_Order_Pub.G_MISS_HEADER_REC;
  l_header_adj_tbl 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_TBL;
  l_header_adj_tbl_new 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_TBL;
  l_header_price_att_tbl        := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_TBL;
  l_header_price_att_tbl_new    := OE_Order_Pub.G_MISS_HEADER_PRICE_ATT_TBL;
  l_header_adj_att_tbl          := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_TBL;
  l_header_adj_att_tbl_new      := OE_Order_Pub.G_MISS_HEADER_ADJ_ATT_TBL;
  l_header_adj_assoc_tbl        := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_TBL;
  l_header_adj_assoc_tbl_new    := OE_Order_Pub.G_MISS_HEADER_ADJ_ASSOC_TBL;
  l_header_scredit_tbl 		:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL;
  l_header_scredit_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL;

  l_header_val_rec 		:= OE_Order_Pub.G_MISS_HEADER_VAL_REC;
  l_header_val_rec_new 		:= OE_Order_Pub.G_MISS_HEADER_VAL_REC;
  l_header_adj_val_tbl 		:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL;
  l_header_adj_val_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL;
  l_header_scredit_val_tbl 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL;
  l_header_scredit_val_tbl_new 	:= OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL;

  l_line_rec 			:= OE_Order_Pub.G_MISS_LINE_REC;
  l_line_tbl 			:= OE_Order_Pub.G_MISS_LINE_TBL;
  l_line_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_TBL;
  l_line_adj_tbl 		:= OE_Order_Pub.G_MISS_LINE_ADJ_TBL;
  l_line_adj_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_ADJ_TBL;
  l_line_price_att_tbl          := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_TBL;
  l_line_price_att_tbl_new      := OE_Order_Pub.G_MISS_LINE_PRICE_ATT_TBL;
  l_line_adj_att_tbl            := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_TBL;
  l_line_adj_att_tbl_new        := OE_Order_Pub.G_MISS_LINE_ADJ_ATT_TBL;
  l_line_adj_assoc_tbl          := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_TBL;
  l_line_adj_assoc_tbl_new      := OE_Order_Pub.G_MISS_LINE_ADJ_ASSOC_TBL;
  l_line_scredit_tbl 		:= OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL;
  l_line_scredit_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL;

  l_line_val_rec 		:= OE_Order_Pub.G_MISS_LINE_VAL_REC;
  l_line_val_tbl 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
  l_line_val_tbl_new 		:= OE_Order_Pub.G_MISS_LINE_VAL_TBL;
  l_line_adj_val_tbl 		:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL;
  l_line_adj_val_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL;
  l_line_scredit_val_tbl 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL;
  l_line_scredit_val_tbl_new 	:= OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL;

  l_lot_serial_rec 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_REC;
  l_lot_serial_tbl 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;
  l_lot_serial_tbl_new 		:= OE_Order_Pub.G_MISS_LOT_SERIAL_TBL;

  l_action_request_tbl 		:= OE_Order_Pub.G_MISS_REQUEST_TBL;
  l_action_request_tbl_new 	:= OE_Order_Pub.G_MISS_REQUEST_TBL;

  l_header_rec.operation 	:= OE_GLOBALS.G_OPR_UPDATE;
  l_line_rec.operation 		:= OE_GLOBALS.G_OPR_UPDATE;


/* -----------------------------------------------------------
   Setting Debug On
   -----------------------------------------------------------
*/
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE SETTING DEBUG ON' ) ;
   END IF;

/*
   OE_DEBUG_PUB.debug_on;
   OE_DEBUG_PUB.SetDebugLevel(3);
*/


/* -----------------------------------------------------------
   Headers cursor
   -----------------------------------------------------------
*/
  OPEN l_header_cursor;
  LOOP
     FETCH l_header_cursor
      INTO l_header_rec.order_source_id
	 , l_header_rec.orig_sys_document_ref
	 , l_header_rec.change_sequence
	 , l_header_rec.org_id
	 , l_header_rec.header_id
	 , l_header_rec.order_number
	 , l_header_rec.ordered_date
	 , l_header_rec.order_type_id
	 , l_header_rec.first_ack_code
	 , l_header_rec.first_ack_date
	 , l_header_rec.last_ack_code
	 , l_header_rec.last_ack_date
;
      EXIT WHEN l_header_cursor%NOTFOUND;

  END LOOP;
  CLOSE l_header_cursor;

/* -----------------------------------------------------------
   Call Process_Order
   -----------------------------------------------------------
*/
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING PROCESS_ORDER' ) ;
     END IF;

     OE_Order_Grp.Process_Order(
	 p_api_version_number 		=> 1
	,p_init_msg_list 		=> l_init_msg_list
	,p_validation_level 		=> l_validation_level
	,p_control_rec 			=> l_control_rec
	,p_header_rec 			=> l_header_rec
--	,p_header_adj_tbl		=> l_header_adj_tbl
--	,p_header_Scredit_tbl		=> l_header_scredit_tbl
--	,p_line_tbl 			=> l_line_tbl
--	,p_line_adj_tbl			=> l_line_adj_tbl
--	,p_line_scredit_tbl		=> l_line_scredit_tbl
--	,p_lot_serial_tbl		=> l_lot_serial_tbl
--	,p_action_request_tbl 		=> l_action_request_tbl
	,x_header_rec 			=> l_header_rec_new
	,x_header_adj_tbl 		=> l_header_adj_tbl_new
	,x_header_price_att_tbl         => l_header_price_att_tbl_new
	,x_header_adj_att_tbl           => l_header_adj_att_tbl_new
	,x_header_adj_assoc_tbl         => l_header_adj_assoc_tbl_new
	,x_header_scredit_tbl 		=> l_header_scredit_tbl_new
	,x_header_val_rec               => l_header_val_rec_new
	,x_header_adj_val_tbl           => l_header_adj_val_tbl_new
	,x_header_scredit_val_tbl       => l_header_scredit_val_tbl_new
	,x_line_tbl 			=> l_line_tbl_new
	,x_line_adj_tbl         	=> l_line_adj_tbl_new
	,x_line_scredit_tbl		=> l_line_scredit_tbl_new
	,x_line_price_att_tbl           => l_line_price_att_tbl_new
	,x_line_adj_att_tbl             => l_line_adj_att_tbl_new
	,x_line_adj_assoc_tbl           => l_line_adj_assoc_tbl_new
	,x_lot_serial_tbl		=> l_lot_serial_tbl_new
	,x_line_val_tbl                 => l_line_val_tbl_new
	,x_line_adj_val_tbl             => l_line_adj_val_tbl_new
	,x_line_scredit_val_tbl         => l_line_scredit_val_tbl_new
	,x_lot_serial_val_tbl           => l_lot_serial_val_tbl_new
	,x_action_request_tbl   	=> l_action_request_tbl_new
	,x_msg_count 			=> p_msg_count
	,x_msg_data 			=> p_msg_data
	,x_return_status 		=> p_return_status
	);

/* -----------------------------------------------------------
   Check Process_Order Results
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER CALLING PROCESS_ORDER' ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'RETURN_STATUS: '||P_RETURN_STATUS ) ;
      END IF;

    IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF p_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'ACKNOWLEDGMENT CODE AND DATE UPDATED FOR REF: '|| L_HEADER_REC_NEW.ORIG_SYS_DOCUMENT_REF ) ;
			END IF;

/*
  OE_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
			    p_count   => p_msg_count,
        		    p_data    => p_msg_data);
*/

  IF p_msg_count > 0 THEN
     FOR k IN 1 .. p_msg_count
     LOOP
  	oe_msg_pub.get (p_msg_index     => -2,
		        p_encoded       => 'F',
		        p_data          => p_msg_data,
		        p_msg_index_out => l_msg_index);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'MESSAGE: '|| P_MSG_DATA ) ;
        END IF;
     END LOOP;
  END IF;

/* -----------------------------------------------------------
   End of Update Header Ack
   -----------------------------------------------------------
*/
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'END OF UPDATE HEADER ACK' ) ;
      END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       p_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
          			  p_data  => p_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
          			  p_data  => p_msg_data);

  WHEN OTHERS THEN
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       then
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       end if;

       FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
          			  p_data  => p_msg_data);

END Update_Header_Ack;

END OE_Update_Header_Ack_Util;

/
