--------------------------------------------------------
--  DDL for Package Body OE_AR_ACCEPTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_AR_ACCEPTANCE_GRP" AS
-- $Header: OEXGAARB.pls 120.3.12010000.2 2009/06/24 11:07:54 aambasth ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXGAARB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Package Spec of OE_AR_Acceptance_GRP                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Process_Acceptance_in_OM                                          |
--|                                                                       |
--| HISTORY                                                               |
--|     MAY-05-2005 Initial creation                                      |
--+=======================================================================+

PROCEDURE Process_Acceptance_in_OM(
  p_Action_Request_tbl            IN OUT NOCOPY OE_Order_PUB.Request_Tbl_Type,
  x_return_status                 OUT NOCOPY VARCHAR2,
  x_msg_count                     OUT NOCOPY NUMBER,
  x_msg_data                      OUT NOCOPY VARCHAR2) IS

  x_header_rec                    OE_Order_PUB.Header_Rec_Type;
  x_Header_Adj_tbl                OE_Order_PUB.Header_Adj_Tbl_Type;
  x_Header_price_Att_tbl          OE_Order_PUB.Header_Price_Att_Tbl_Type;
  x_Header_Adj_Att_tbl            OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  x_Header_Adj_Assoc_tbl          OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  x_Header_Scredit_tbl            OE_Order_PUB.Header_Scredit_Tbl_Type;
  x_Header_Payment_tbl            OE_Order_PUB.Header_Payment_Tbl_Type;
  x_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
  x_Line_Adj_tbl                  OE_Order_PUB.Line_Adj_Tbl_Type;
  x_Line_price_Att_tbl            OE_Order_PUB.Line_Price_Att_Tbl_Type;
  x_Line_Adj_Att_tbl              OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  x_Line_Adj_Assoc_tbl            OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  x_Line_Scredit_tbl              OE_Order_PUB.Line_Scredit_Tbl_Type;
  x_Line_Payment_tbl              OE_Order_PUB.Line_Payment_Tbl_Type;
  x_Lot_Serial_tbl                OE_Order_PUB.Lot_Serial_Tbl_Type;

BEGIN

  -- call to process order
     OE_Order_PVT.Process_Order(
         p_api_version_number           => 1.0
        ,p_init_msg_list               => FND_API.G_TRUE
        ,x_return_status                => x_return_status
        ,x_msg_count                    => x_msg_count
        ,x_msg_data                     => x_msg_data
        ,p_x_action_request_tbl           => p_action_request_tbl
        ,p_x_header_rec                   => x_header_rec
        ,p_x_Header_Adj_tbl               => x_Header_Adj_tbl
        ,p_x_Header_price_Att_tbl         => x_Header_price_Att_tbl
        ,p_x_Header_Adj_Att_tbl           => x_Header_Adj_Att_tbl
        ,p_x_Header_Adj_Assoc_tbl         => x_Header_Adj_Assoc_tbl
        ,p_x_Header_Scredit_tbl           => x_Header_Scredit_tbl
        ,p_x_Header_Payment_tbl           => x_Header_Payment_tbl
        ,p_x_line_tbl                     => x_line_tbl
        ,p_x_Line_Adj_tbl                 => x_Line_Adj_tbl
        ,p_x_Line_price_Att_tbl           => x_Line_price_Att_tbl
        ,p_x_Line_Adj_Att_tbl             => x_Line_Adj_Att_tbl
        ,p_x_Line_Adj_Assoc_tbl           => x_Line_Adj_Assoc_tbl
        ,p_x_Line_Scredit_tbl             => x_Line_Scredit_tbl
        ,p_x_Line_Payment_tbl             => x_Line_Payment_tbl
        ,p_x_Lot_Serial_tbl               => x_Lot_Serial_tbl
);

END Process_Acceptance_in_OM;

PROCEDURE Get_interface_attributes
(    p_line_id                       IN   NUMBER
,    x_line_flex_rec                 OUT NOCOPY ar_deferral_reasons_grp.line_flex_rec
,    x_return_status                 OUT NOCOPY VARCHAR2
,    x_msg_count                     OUT NOCOPY NUMBER
,    x_msg_data                      OUT NOCOPY VARCHAR2
)IS
l_delivery_line_id            NUMBER := NULL;
l_line_rec                    OE_Order_Pub.Line_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTER OE_AR_Acceptance_GRP.GET_INTERFACE_ATTRIBUTES PROCEDURE ' , 5 ) ;
   END IF;

   IF (p_line_id is NULL OR p_line_id = FND_API.G_MISS_NUM) THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Get_Interface_Attributes:Line id is null hence return' , 5 ) ;
     END IF;
     RETURN;
   ELSE
     BEGIN
	OE_Line_Util.Query_Row(p_line_id => p_line_id,x_line_rec => l_line_rec);

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'Get_Interface_Attributes: NO DATA FOUND FOR LINE ID:'||p_line_id , 5 ) ;
        END IF;
        x_line_flex_rec.INTERFACE_LINE_CONTEXT          := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE1       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE2       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE5       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE6       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE7       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE8       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE9       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE10      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE11      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE12      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE13      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE14      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE15      := NULL;
        x_line_flex_rec.acceptance_date                 := NULL; -- bug 8293484

        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END;
    END IF;

    IF nvl(l_line_rec.invoiced_quantity, 0) = 0 THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Get_Interface_Attributes:  This line is not invoice interfaced, hence return. LINE ID:'||p_line_id , 5 ) ;

        END IF;
        x_line_flex_rec.INTERFACE_LINE_CONTEXT          := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE1       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE2       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE5       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE6       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE7       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE8       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE9       := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE10      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE11      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE12      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE13      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE14      := NULL;
        x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE15      := NULL;
        x_line_flex_rec.acceptance_date                 := NULL; -- bug 8293484

        RETURN;

    END IF;

    x_line_flex_rec.INTERFACE_LINE_CONTEXT := 'ORDER ENTRY';

    SELECT order_number
    INTO x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE1
    FROM oe_order_headers_all
    WHERE header_id= l_line_rec.header_id;

    SELECT tt.name
    INTO   x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE2
    FROM   oe_transaction_types_tl tt,
            oe_order_headers oh
    WHERE  tt.language = ( select language_code
                         from   fnd_languages
                         where  installed_flag = 'B')
    AND    tt.transaction_type_id = oh.order_type_id
    AND    oh.header_id = l_line_rec.header_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Get_Interface_Attributes: HEADER_ID :'||l_line_rec.header_id , 5 ) ;
    END IF;

    -- Populate delivery number and Waybill number
    IF OE_Invoice_PUB.Shipping_info_Available(l_line_rec) THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Get_Interface_Attributes:Shipping_info_Available: TRUE', 5 ) ;
          END IF;
       IF l_line_rec.item_type_code NOT In ('MODEL','CLASS','KIT') THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Get_Interface_Attributes: ITEM NOT A MODEL/CLASS/KIT', 5 ) ;
          END IF;
          BEGIN
	       SELECT min(dl.delivery_id)
	       INTO   l_delivery_line_id
	       FROM   wsh_new_deliveries dl,
                      wsh_delivery_assignments da,
                      wsh_delivery_details dd
               WHERE  dd.delivery_detail_id  = da.delivery_detail_id
	       AND    da.delivery_id  = dl.delivery_id
               AND    dd.source_code = 'OE'
               AND    dd.source_line_id = l_line_rec.line_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
	          IF l_debug_level  > 0 THEN
	              oe_debug_pub.add(  'Get_Interface_Attributes: DELIVERY DETAILS NOT FOUND FOR THIS LINE' , 1 ) ;
	          END IF;
              x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3 := '0';
              x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4 := '0';
          END;
       ELSE
        -- IF l_line_rec.item_type_code In ('MODEL','CLASS','KIT') THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Get_Interface_Attributes:ITEM IS A MODEL/CLASS/KIT' , 5 ) ;
          END IF;
          BEGIN
	       SELECT min(dl.delivery_id)
               INTO   l_delivery_line_id
               FROM wsh_new_deliveries dl,
                    wsh_delivery_assignments da,
                    wsh_delivery_details dd
               WHERE   dd.delivery_detail_id  = da.delivery_detail_id
               AND     da.delivery_id  = dl.delivery_id
               AND     dd.source_code = 'OE'
               AND     dd.top_model_line_id = l_line_rec.line_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
	              IF l_debug_level  > 0 THEN
	                  oe_debug_pub.add(  'Get_Interface_Attributes:DELIVERY DETAILS NOT FOUND FOR THIS LINE' , 1 ) ;
	              END IF;
                  x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3 := '0';
                  x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4 := '0';
           END;
       END IF;
    END IF;

       IF l_delivery_line_id Is Not Null Then
           BEGIN
              SELECT  NVL(SUBSTR(dl.name, 1, 30), '0')
                      ,NVL(SUBSTR(dl.waybill, 1, 30), '0')
              INTO    x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3
                      ,x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4
              FROM   wsh_new_deliveries dl
              WHERE dl.delivery_id = l_delivery_line_id;

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('Get_Interface_Attributes:DELIVERY NUM:'||X_LINE_FLEX_REC.INTERFACE_LINE_ATTRIBUTE3,5);
                 oe_debug_pub.add('Get_Interface_Attributes:WAYBILL NUM:'||X_LINE_FLEX_REC.INTERFACE_LINE_ATTRIBUTE4 ,5);
              END IF;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'Get_Interface_Attributes:NO DETAILS FOUND FOR DELIVERY AND WAYBILL NUMBER' , 5 );
                  END IF;
                  x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3 := '0';
                  x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4 := '0';
         END;
      ELSE   -- for Returns and non shippable lines
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Get_Interface_Attributes:NON SHIPPABLE OR RETURN LINE ' , 5 ) ;
         END IF;
         x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3 := '0';
         x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4 := '0';
      END IF;


    -- Line would not interface more than once if it has contingency attached to it.
    x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE5 :='0';
    x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE6 := to_char(p_line_id);

    -- Bug 8293484 Start
    x_line_flex_rec.acceptance_date:=l_line_rec.REVREC_SIGNATURE_DATE;

    oe_debug_pub.add('l_line_rec.REVREC_SIGNATURE_DATE' || l_line_rec.REVREC_SIGNATURE_DATE , 5 );
    oe_debug_pub.add('x_line_flex_rec.acceptance_date' || x_line_flex_rec.acceptance_date , 5 );
    -- Bug 8293484 End

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE1:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE1);
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE2:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE2);
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE3:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE3);
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE4:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE4);
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE5:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE5);
          oe_debug_pub.add('INTERFACE_LINE_ATTRIBUTE6:'||x_line_flex_rec.INTERFACE_LINE_ATTRIBUTE6);
          oe_debug_pub.add(  'EXIT OE_AR_Acceptance_GRP.GET_INTERFACE_ATTRIBUTES PROCEDURE',5) ;
   END IF;

END Get_Interface_Attributes;

END OE_AR_Acceptance_GRP;

/
