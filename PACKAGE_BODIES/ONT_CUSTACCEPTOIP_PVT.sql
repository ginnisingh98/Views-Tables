--------------------------------------------------------
--  DDL for Package Body ONT_CUSTACCEPTOIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_CUSTACCEPTOIP_PVT" AS
/* $Header: OEXVOIPB.pls 120.6 2006/08/23 10:20:21 myerrams noship $ */
PROCEDURE Call_OIP_Process_Order
(
  p_header_id                    IN          NUMBER
, p_line_id_tbl                  IN          ont_num_tbl_type
, p_reference_document           IN          VARCHAR2
, p_customer_signature           IN          VARCHAR2
, p_signature_date               IN          DATE
, p_customer_comments            IN          VARCHAR2
, p_action                       IN          VARCHAR2
, x_return_status                OUT NOCOPY  VARCHAR2
, x_msg_count                    OUT NOCOPY  NUMBER
, x_msg_data                     OUT NOCOPY  VARCHAR2
)
IS
        l_action_request_tbl        OE_ORDER_PUB.Request_Tbl_Type;

	l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
	l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
	l_header_price_att_out_tbl  OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
	l_header_adj_att_out_tbl    OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
	l_header_adj_assoc_out_tbl  OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
	l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
	l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
	l_line_adj_out_tbl          OE_ORDER_PUB.Line_Adj_Tbl_Type;
	l_line_price_att_out_tbl    OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
	l_line_adj_att_out_tbl	    OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
	l_line_adj_assoc_out_tbl    OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
	l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
	l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
	l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;

--myerrams, start
	l_header_val_out_rec	    OE_Order_PUB.Header_Val_Rec_Type;
	l_header_adj_val_out_tbl    OE_Order_PUB.Header_Adj_Val_Tbl_Type;
	l_header_scredit_val_out_tbl OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
	l_line_val_out_tbl	    OE_Order_PUB.Line_Val_Tbl_Type;
	l_line_adj_val_out_tbl	    OE_Order_PUB.Line_Adj_Val_Tbl_Type;
	l_line_scredit_val_out_tbl  OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
	l_lot_serial_val_out_tbl    OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
--myerrams, end

	l_action                    VARCHAR2(30);
	l_return_status		    VARCHAR2(1);
	l_msg_count		    NUMBER;
	l_msg_data		    VARCHAR2(4000);

        l_debug_level CONSTANT NUMBER	:= oe_debug_pub.g_debug_level;
	l_temp_var VARCHAR2(2000)	:= NULL;
	l_org_id			NUMBER;

BEGIN

--myerrams, Bug: 5285062
  IF To_number(Nvl(fnd_profile.value('ONT_DEBUG_LEVEL'), '0')) > 0 THEN
      oe_debug_pub.initialize;
      l_temp_var := oe_debug_pub.set_debug_mode('FILE');
      oe_debug_pub.debug_on;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Start of method ONT_CustAcceptOip_PVT.Call_OIP_Process_Order' ) ;
  END IF;

-- myerrams, to get the org_id of header passed.
  select org_id into l_org_id from oe_order_headers_all where header_id = p_header_id;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Org_Id of the header passed:' || l_org_id) ;
  END IF;

--myerrams, Bug:5155962; Modified the code to match the LookupCode instead of Meaning
--as Meaning can be different for different languages.
 IF p_action = 'A'
 THEN
    l_action := OE_GLOBALS.G_ACCEPT_FULFILLMENT;
 ELSIF p_action = 'R'
 THEN
    l_action := OE_GLOBALS.G_REJECT_FULFILLMENT;
 END IF;
--myerrams, end. Bug:5155962

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Parameters passed to Process Order') ;
  END IF;

 oe_msg_pub.initialize;
 FOR i IN 1..p_line_id_tbl.COUNT LOOP

   l_action_request_tbl(i).entity_code  := OE_GLOBALS.G_ENTITY_LINE;
   l_action_request_tbl(i).request_type := l_action;
   l_action_request_tbl(i).entity_id    := p_line_id_tbl(i);
   l_action_request_tbl(i).param1       := p_customer_comments;
   l_action_request_tbl(i).param2       := p_customer_signature;
   l_action_request_tbl(i).param3       := p_reference_document;
   l_action_request_tbl(i).param4       := 'N';
   l_action_request_tbl(i).param5       := p_header_id;
   l_action_request_tbl(i).date_param1  := p_signature_date;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Record Number:' || i || ' out of ' || p_line_id_tbl.COUNT || ' records') ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: entity_code'		|| l_action_request_tbl(i).entity_code) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: request_type'		|| l_action_request_tbl(i).request_type) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: entity_id'		|| l_action_request_tbl(i).entity_id) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: customer_comments'	|| l_action_request_tbl(i).param1) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: customer_signature'	|| l_action_request_tbl(i).param2) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: reference_document'	|| l_action_request_tbl(i).param3) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Explicit Revenue Recognition Acceptance') ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: header_id'		|| l_action_request_tbl(i).param5) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: signature_date'		|| l_action_request_tbl(i).date_param1) ;
  END IF;

 END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: Before Call to Process Order API.') ;
  END IF;

 OE_Order_PUB.Process_Order
         (  p_api_version_number		=> 1.0
	  , p_org_id				=> l_org_id
	  , x_return_status			=> l_return_status
	  , x_msg_count				=> l_msg_count
	  , x_msg_data				=> l_msg_data
          , x_header_rec			=> l_header_out_rec
	  , x_header_val_rec			=> l_header_val_out_rec
          , x_header_adj_tbl			=> l_header_adj_out_tbl
          , x_header_adj_val_tbl		=> l_header_adj_val_out_tbl
      	  , x_header_price_att_tbl	        => l_header_price_att_out_tbl
	  , x_header_adj_att_tbl		=> l_header_adj_att_out_tbl
	  , x_header_adj_assoc_tbl	        => l_header_adj_assoc_out_tbl
	  , x_header_scredit_tbl		=> l_header_scredit_out_tbl
	  , x_header_scredit_val_tbl		=> l_header_scredit_val_out_tbl
	  , x_line_tbl				=> l_line_out_tbl
	  , x_line_val_tbl			=> l_line_val_out_tbl
          , x_line_adj_tbl			=> l_line_adj_out_tbl
          , x_line_adj_val_tbl			=> l_line_adj_val_out_tbl
          , x_line_price_att_tbl		=> l_line_price_att_out_tbl
          , x_line_adj_att_tbl			=> l_line_adj_att_out_tbl
          , x_line_adj_assoc_tbl		=> l_line_adj_assoc_out_tbl
	  , x_line_scredit_tbl			=> l_line_scredit_out_tbl
	  , x_line_scredit_val_tbl		=> l_line_scredit_val_out_tbl
          , x_lot_serial_tbl			=> l_lot_serial_out_tbl
          , x_lot_serial_val_tbl		=> l_lot_serial_val_out_tbl
	  , p_action_request_tbl		=> l_action_request_tbl
	  , x_action_request_tbl		=> l_action_request_out_tbl
	);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: After Call to Process Order API.') ;
  END IF;

  x_return_status := l_return_status;
  x_msg_count  :=  l_msg_count;

--Decoding the Error message
if l_msg_count > 0 then
	for k in 1 .. l_msg_count loop
		l_msg_data := oe_msg_pub.get( p_msg_index => k,
					      p_encoded => 'F'
					    );
		x_msg_data := x_msg_data || k || '.' ||  l_msg_data || '  ' ;
	end loop;
end if;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: x_msg_count:' || x_msg_count) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: x_msg_data: ' || x_msg_data) ;
      oe_debug_pub.add(  'GBL:Customer Acceptance OIP: End of method ONT_CustAcceptOip_PVT.Call_OIP_Process_Order' ) ;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Call_OIP_Process_Order;

END ONT_CustAcceptOip_PVT;

/
