--------------------------------------------------------
--  DDL for Package Body OE_FTE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FTE_INTEGRATION_PVT" AS
/* $Header: OEXVFTEB.pls 120.0 2005/06/01 01:09:38 appldev noship $ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_FTE_INTEGRATION_PVT';


/*--------------------------------------------------------------+
 | Local Procedures and Function Declarations                   |
 +--------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

PROCEDURE Update_FTE_Results
( p_x_line_tbl           IN OUT  NOCOPY OE_Order_PUB.Line_Tbl_Type
 ,x_return_status        OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

PROCEDURE Create_FTE_Input
( p_header_id              IN      NUMBER
 ,p_line_id                IN      NUMBER
 ,p_x_fte_source_line_tab  IN OUT  NOCOPY
                                   FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT  NOCOPY  OE_ORDER_PUB.Line_Tbl_Type
 ,p_action                 IN      VARCHAR2
 ,x_config_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2);

PROCEDURE Process_FTE_Output
( p_x_fte_source_line_tab  IN OUT  NOCOPY
                           FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT  NOCOPY  OE_ORDER_PUB.line_tbl_type
 ,p_config_count           IN      NUMBER
 ,x_no_opr_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2 );


/*--------------------------------------------------------------+
 | Name        :   Print_Time                                   |
 | Parameters  :   IN  p_msg                                    |
 |                                                              |
 | Description :   This Procedure will print Current time along |
 |                 with the Debug Message Passed as input.      |
 |                 This Procedure will be called from Main      |
 |                 Procedures to print Entering and Leaving Msg |
 +--------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                               'DD-MON-YY HH24:MI:SS');
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add(p_msg || ': '|| l_time, 1);
  END IF;
END Print_Time;


/*--------------------------------------------------------------+
 | Name        :   Update_FTE_Results                           |
 | Parameters  :   IN OUT NOCOPY p_x_line_tbl                          |
 |                 OUT NOCOPY                                           |
 |                     x_return_status                          |
 |                                                              |
 | Description :   This Procedure updates the FTE Results in db |
 |                 This Calls Process Order to update the FTE   |
 |                 results. Then the Procedure Process delayed  |
 |                 requests and notify is called to execute all |
 |                 pending delayed requests. This is called from|
 |                 procedure Process FTE Requests.              |
 | Change Record :                                              |
 +--------------------------------------------------------------*/

PROCEDURE Update_FTE_Results
( p_x_line_tbl           IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
 ,x_return_status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  Print_Time('Entering OE_FTE_INTEGRATION_PVT.Update_FTE_Results..');

  x_return_status   := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Before Calling Process Order..',3);
  END IF;

  OE_ORDER_PVT.Lines
  ( p_validation_level    => FND_API.G_VALID_LEVEL_NONE
   ,p_control_rec         => l_control_rec
   ,p_x_line_tbl          => p_x_line_tbl
   ,p_x_old_line_tbl      => l_old_line_tbl
   ,x_return_status       => x_return_status);


  IF l_debug_level > 0 THEN
  oe_debug_pub.Add('After Calling Process Order...'||
                        x_return_status,3);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Before Calling Process Requests and Notify',3);
  END IF;

  OE_ORDER_PVT.Process_Requests_And_notify
  ( p_process_requests     => TRUE
   ,p_notify               => TRUE
   ,x_return_status        => x_return_status
   ,p_line_tbl             => p_x_line_tbl
   ,p_old_line_tbl         => l_old_line_tbl);

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('After Calling Process Requests' ||
               'and Notify...'|| x_return_status,3);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  Print_Time('Exiting OE_FTE_INTEGRATION_PVT.Update_FTE_Results..');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Expected Error in Update FTE Results', 2);
     END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Unexpected Error in Update FTE Results'||
                               sqlerrm, 1);
     END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Update_FTE_Results');
    END IF;

END Update_FTE_Results;


/*--------------------------------------------------------------+
  Name        :   Create_FTE_Input
  Parameters  :   IN OUT NOCOPY  p_x_line_tbl
                  IN OUT NOCOPY  p_x_fte_source_line_tab
                  IN  p_header_id
                  IN  p_line_id
                  IN  p_action
                  OUT NOCOPY x_return_status
                  OUT NOCOPY x_config_count

  Description :   This Procedure prepares FTE input table to be
                  passed to FTE. This has two cursors. The
                  first Cursor is used to select all the attrib
                  to be passed to FTE. The second cursor is
                  is used to select all the included item
                  parents to process the included items.

                  we process the included items if they are not
                  frozen already. We will exclude all the non
                  eligible lines and prepate the fte input tab
                  at the same time we will also insert the
                  elgible lines in the oe_order_pub line table
                  to be used later.
                  Now we have line table with all the lines
                  beginnning with config lines.

                  The Same Procedure will be used by freight
                  rating also to prepare the Fte input table.
                  All non shippable lines not part of ATO
                  configuration should be marked as not
                  eligible for freight rate calculations.

                 This procedure is called from Process_FTE_Actions
                 API and p_action paramter can not have a NULL value.

  Change Record :

 +--------------------------------------------------------------*/

PROCEDURE Create_FTE_Input
( p_header_id              IN      NUMBER
 ,p_line_id                IN      NUMBER
 ,p_x_fte_source_line_tab  IN OUT  NOCOPY
                                   FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT  NOCOPY  OE_ORDER_PUB.Line_Tbl_Type
 ,p_action                 IN      VARCHAR2
 ,x_config_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2)

IS
   CURSOR   C_SHIP_METHOD_LINES IS
     SELECT line_id
           ,ship_from_org_id
           ,ship_to_org_id
           ,sold_to_org_id
           ,inventory_item_id
           ,ordered_quantity
           ,order_quantity_uom
           ,request_date
           ,schedule_ship_date
           ,delivery_lead_time
           ,DECODE(schedule_status_code,NULL,'N',
                   'SCHEDULED','Y','N') scheduled_flag
           ,ship_set_id
           ,arrival_set_id
           ,ship_model_complete_flag
           ,ato_line_id
           ,top_model_line_id
           ,shipping_method_code
           ,freight_carrier_code
           ,freight_terms_code
           ,intmed_ship_to_org_id
           ,fob_point_code
           ,source_type_code
           ,line_category_code
           ,item_type_code
           ,shipped_quantity
           ,NVL(fulfilled_flag,'N') fulfilled_flag
           ,open_flag
           ,nvl(shippable_flag, 'N') shippable_flag
           ,order_source_id
           ,orig_sys_document_ref
           ,orig_sys_line_ref
           ,orig_sys_shipment_ref
           ,change_sequence
           ,source_document_type_id
           ,source_document_id
           ,source_document_line_id
    FROM   oe_order_lines
    WHERE  header_id  =  p_header_id
    AND    NOT (p_action = 'R' AND shipping_method_code is NULL)
    ORDER BY top_model_line_id, ato_line_id, sort_order;


   CURSOR   C_INC_ITEMS_PARENT IS
     SELECT line_id
     FROM    oe_order_lines
     WHERE   item_type_code IN ('MODEL', 'CLASS', 'KIT')
     AND     ato_line_id is NULL
     AND     explosion_date is NULL
     AND     NVL(fulfilled_flag,'N') <> 'Y'
     AND     open_flag     = 'Y'
     AND     shipped_quantity IS NULL
     AND     line_category_code    <> 'RETURN'
     AND     source_type_code     = 'INTERNAL'
     AND     header_id = p_header_id;

  l_open_flag            VARCHAR2(1);
  l_order_category_code  VARCHAR2(30);
  l_line_count           NUMBER          := 0;
  l_config_count         NUMBER          := 0;
  l_count                NUMBER          := 0;
  l_line_rec             OE_ORDER_PUB.line_rec_type   :=
                                      OE_Order_Pub.G_MISS_LINE_REC;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  Print_Time('Entering OE_FTE_INTEGRATION_PVT.Create_FTE_Input...');

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Order header Id:'||p_header_id,1);
  END IF;
  x_return_status   := FND_API.G_RET_STS_SUCCESS;


  -- Validating Order

  BEGIN
    SELECT open_flag,order_category_code
    INTO   l_open_flag,l_order_category_code
    FROM   oe_order_headers_all
    WHERE  header_id  =  p_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('No Data Found when Validating Order',3);
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('When Others when Validating Order',3);
      END IF;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF  l_open_flag  = 'N' OR l_order_category_code = 'RETURN' THEN
       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Order is Return/Closed',1);
       END IF;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  -- We need to create the included items  if not already frozen.
  -- Loop through the cursor Inc Item Parents to get the parent
  -- lines of included items.

  FOR c_inc_parent IN C_INC_ITEMS_PARENT
  LOOP
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Calling Process Included Items for Line:'||
                 c_inc_parent.line_id,3);
     END IF;

    x_return_status := OE_CONFIG_UTIL.Process_Included_Items
            (p_line_id   => c_inc_parent.line_id
            ,p_freeze  => FALSE);

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('After Calling Process Included Items: '||
                  x_return_status,3);
     END IF;

    IF  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;


  -- Query the Config lines and Put them in the line table
  -- We are putting config lines in the line table in the
  -- beginning. When traversing through the line table for
  -- config lines it would be easy to identify them as they will
  -- be in the beginning. We will insert all other lines in the
  -- table next to config lines.
  -- Now number of Config lines in the table

  SELECT count(*)
  INTO   l_config_count
  FROM   oe_order_lines
  WHERE  item_type_code = 'CONFIG'
  AND    ato_line_id IS NOT NULL
  AND    header_id = p_header_id;

   IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Config Line Count:'||l_config_count,3);
   END IF;

  x_config_count :=  l_config_count;
  l_line_count   :=  l_config_count;


  -- Reset the Config Count Variable
  l_config_count := 0;

  -- Loop through the cursor Ship Method Lines and exclude all
  -- Non eligible Lines.

  FOR c_ship_method IN C_SHIP_METHOD_LINES
  LOOP
    -- We need to set the Message Context for each line.

    OE_Msg_Pub.Set_Msg_Context
    ( p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
     ,p_entity_id   => c_ship_method.line_id
     ,p_header_id   => p_header_id
     ,p_line_id     => c_ship_method.line_id
     ,p_order_source_id            => c_ship_method.order_source_id
     ,p_orig_sys_document_ref      => c_ship_method.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => c_ship_method.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => c_ship_method.orig_sys_shipment_ref
     ,p_change_sequence            => c_ship_method.change_sequence
     ,p_source_document_type_id    => c_ship_method.source_document_type_id
     ,p_source_document_id         => c_ship_method.source_document_id
     ,p_source_document_line_id    => c_ship_method.source_document_line_id);

    -- If the line is sourced Externally the line is
    -- not eligible

    IF c_ship_method.source_type_code   = 'EXTERNAL' OR
       c_ship_method.item_type_code     = 'SERVICE'  OR
       c_ship_method.line_category_code = 'RETURN'   THEN

      FND_MESSAGE.Set_Name('ONT','ONT_FTE_EXTERNAL_RET_SERVICE');
      OE_MSG_PUB.Add;

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Line is External/Service/Return:'||
                   c_ship_method.line_id ,3);
       END IF;

    ELSIF c_ship_method.ship_from_org_id IS NULL THEN

      FND_MESSAGE.Set_Name('ONT','ONT_FTE_MISSING_SHIP_FROM');
      OE_MSG_PUB.Add;
       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Line is Missing Ship From Org Id:'||
                   c_ship_method.line_id ,3);
       END IF;

    ELSIF c_ship_method.ship_to_org_id IS NULL THEN

      FND_MESSAGE.Set_Name('ONT','ONT_FTE_MISSING_SHIP_TO');
      OE_MSG_PUB.Add;
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Line is Missing Ship To Org Id:'||
                   c_ship_method.line_id ,3);
       END IF;

    ELSIF c_ship_method.shipped_quantity IS NOT NULL OR
      c_ship_method.fulfilled_flag    =  'Y' OR
      c_ship_method.open_flag     <> 'Y' THEN

      FND_MESSAGE.Set_Name('ONT','ONT_FTE_SHIP_FULFILL_CLOSED');
      OE_MSG_PUB.Add;
       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('Line is Shipped/Fulfilled/Closed:'||
                  c_ship_method.line_id ,1);
       END IF;
    ELSIF c_ship_method.item_type_code   =  OE_GLOBALS.G_ITEM_CONFIG THEN

      -- We are not going to send Config lines to FTE
      -- We have to store the config lines in the line table.
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Config Line:'||c_ship_method.line_id,3);
       END IF;

      l_line_rec.line_id         := c_ship_method.line_id;
      l_line_rec.ato_line_id     := c_ship_method.ato_line_id;
      l_line_rec.item_type_code  := c_ship_method.item_type_code;
      l_line_rec.shipping_method_code  :=
                 c_ship_method.shipping_method_code;
      l_line_rec.freight_terms_code    :=
                 c_ship_method.freight_terms_code;

      l_config_count  :=  l_config_count + 1;

      p_x_line_tbl(l_config_count) := l_line_rec;
      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Excluding Config Line from FTE Input:'||
                    c_ship_method.line_id ,1);
      END IF;
    ELSE
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Sending Eligibile Line to FTE:'||
                  c_ship_method.line_id ,1);
       END IF;

      -- Increment the FTE line table count

      l_count  :=  l_count  + 1;

      p_x_fte_source_line_tab(l_count).source_type  :=  'ONT';

      p_x_fte_source_line_tab(l_count).source_header_id   :=
                     p_header_id;

      p_x_fte_source_line_tab(l_count).source_line_id     :=
                   c_ship_method.line_id;

      p_x_fte_source_line_tab(l_count).ship_from_org_id   :=
                c_ship_method.ship_from_org_id;

      p_x_fte_source_line_tab(l_count).ship_to_site_id    :=
                c_ship_method.ship_to_org_id;


      p_x_fte_source_line_tab(l_count).customer_id        :=
                  c_ship_method.sold_to_org_id;

      p_x_fte_source_line_tab(l_count).inventory_item_id  :=
                c_ship_method.inventory_item_id;

      p_x_fte_source_line_tab(l_count).source_quantity    :=
                c_ship_method.ordered_quantity;

      p_x_fte_source_line_tab(l_count).source_quantity_uom:=
                c_ship_method.order_quantity_uom;

      p_x_fte_source_line_tab(l_count).ship_date          :=
            NVL(c_ship_method.schedule_ship_date
               , NVL(c_ship_method.request_date,sysdate));

      IF   c_ship_method.scheduled_flag = 'N' THEN
         p_x_fte_source_line_tab(l_count).delivery_lead_time :=0;

      ELSE
         p_x_fte_source_line_tab(l_count).delivery_lead_time :=
                c_ship_method.delivery_lead_time;

      END IF;

      p_x_fte_source_line_tab(l_count).scheduled_flag   :=
                c_ship_method.scheduled_flag;


      IF  c_ship_method.arrival_set_id IS NOT NULL THEN

        p_x_fte_source_line_tab(l_count).order_set_type :=
                        'ARRIVAL';

        p_x_fte_source_line_tab(l_count).order_set_id   :=
                c_ship_method.arrival_set_id;

      ELSIF c_ship_method.ship_set_id IS NOT NULL THEN

        p_x_fte_source_line_tab(l_count).order_set_type :=
                        'SHIP';

        p_x_fte_source_line_tab(l_count).order_set_id   :=
                c_ship_method.ship_set_id;

      ELSIF c_ship_method.top_model_line_id IS NOT NULL   AND
        c_ship_method.ship_model_complete_flag = 'Y' THEN

        p_x_fte_source_line_tab(l_count).order_set_type := 'SMC';

        p_x_fte_source_line_tab(l_count).order_set_id   :=
                c_ship_method.top_model_line_id;

      ELSIF c_ship_method.ato_line_id IS NOT NULL THEN

        p_x_fte_source_line_tab(l_count).order_set_type := 'ATO';

        p_x_fte_source_line_tab(l_count).order_set_id   :=
                c_ship_method.ato_line_id;
      ELSE
        p_x_fte_source_line_tab(l_count).order_set_type := NULL;

        p_x_fte_source_line_tab(l_count).order_set_id   := NULL;

      END IF;

      p_x_fte_source_line_tab(l_count).carrier_id     := NULL;

      p_x_fte_source_line_tab(l_count).ship_method_code   :=
                 c_ship_method.shipping_method_code;

      p_x_fte_source_line_tab(l_count).freight_terms    :=
                c_ship_method.freight_terms_code;

      p_x_fte_source_line_tab(l_count).fob_code     :=
                c_ship_method.fob_point_code;


      p_x_fte_source_line_tab(l_count).intmed_ship_to_site_id :=
                c_ship_method.intmed_ship_to_org_id;

      p_x_fte_source_line_tab(l_count).ship_method_flag   := 'Y';
      p_x_fte_source_line_tab(l_count).freight_rating_flag:= 'Y';

      IF c_ship_method.shippable_flag = 'N' THEN

        IF c_ship_method.ato_line_id is not NULL AND
           NOT ((c_ship_method.item_type_code =  'OPTION' OR
                 c_ship_method.item_type_code =  'STANDARD') AND
                 c_ship_method.ato_line_id = c_ship_method.line_id)
        THEN
           IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('calculate rating part of ato', 4);
           END IF;
        ELSE
          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.Add('do not calculate freight_rating '||
                             c_ship_method.line_id, 1);
          END IF;
          p_x_fte_source_line_tab(l_count).freight_rating_flag:= 'N';
        END IF;

      END IF;

      IF l_debug_level > 0 THEN
      oe_debug_pub.Add('--------- Input to FTE --------',3);

      oe_debug_pub.Add('Source Line    :'||
         p_x_fte_source_line_tab(l_count).source_line_id,3);

      oe_debug_pub.Add('Ship From Org    :'||
         p_x_fte_source_line_tab(l_count).ship_from_org_id,3);

      oe_debug_pub.Add('Customer     :'||
         p_x_fte_source_line_tab(l_count).customer_id,3);

      oe_debug_pub.Add('Inventory Item   :'||
         p_x_fte_source_line_tab(l_count).inventory_item_id,3);

      oe_debug_pub.Add('Source Quantity  :'||
         p_x_fte_source_line_tab(l_count).source_quantity,3);

      oe_debug_pub.Add('Ship Date    :'||
         p_x_fte_source_line_tab(l_count).ship_date,3);

      oe_debug_pub.Add('Delivery Lead Time :'||
         p_x_fte_source_line_tab(l_count).delivery_lead_time,3);

      oe_debug_pub.Add('Scheduled    :'||
         p_x_fte_source_line_tab(l_count).scheduled_flag,3);

      oe_debug_pub.Add('Order Set Type   :'||
         p_x_fte_source_line_tab(l_count).order_set_type,3);

      oe_debug_pub.Add('Order Set    :'||
         p_x_fte_source_line_tab(l_count).order_set_id,3);

      oe_debug_pub.Add('Ship Method    :'||
         p_x_fte_source_line_tab(l_count).ship_method_code,3);

      oe_debug_pub.Add('Freight Terms    :'||
         p_x_fte_source_line_tab(l_count).freight_terms,3);

      oe_debug_pub.Add('Freight on Board   :'||
         p_x_fte_source_line_tab(l_count).fob_code,3);

      oe_debug_pub.Add('Intermediate Ship  :'||
         p_x_fte_source_line_tab(l_count).intmed_ship_to_site_id,3);

      oe_debug_pub.Add('-------------------------------',3);
      END IF;

      -- Store the old ship method code in the line table

      l_line_rec.line_id         := c_ship_method.line_id;
      l_line_rec.ato_line_id     := c_ship_method.ato_line_id;
      l_line_rec.item_type_code  := c_ship_method.item_type_code;
      l_line_rec.shipping_method_code :=
                       c_ship_method.shipping_method_code;
      l_line_rec.freight_terms_code   :=
                       c_ship_method.freight_terms_code;
      l_line_rec.freight_carrier_code :=
                       c_ship_method.freight_carrier_code;

      l_line_count               := l_line_count + 1;
      p_x_line_tbl(l_line_count) := l_line_rec;

    END IF;

   END LOOP;

   -- this check is added to show the message when no lines of the order are eligible for freight rating

   IF p_x_line_tbl.count = 0  THEN

    FND_MESSAGE.Set_Name('ONT','ONT_FTE_NO_LINES_ELIGIBLE');
    OE_MSG_PUB.Add;
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('No lines of the order are eligible for freight rating');
       END IF;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.Add('FTE Input count:'||p_x_fte_source_line_tab.count,3);
      oe_debug_pub.Add('Total count:'|| p_x_line_tbl.count,3);
   END IF;

   Print_Time('Exiting OE_FTE_INTEGRATION_PVT.Create_FTE_Input...');
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level > 0 THEN
    oe_debug_pub.Add('Expected Error in Create FTE Input',2);
    END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.Add('Unexpected Error in Create FTE Input:'||SqlErrm, 1);
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Create_FTE_Input');
    END IF;

END Create_FTE_Input;


/*--------------------------------------------------------------+
  Name        :   Process_FTE_Output
  Parameters  :   IN OUT NOCOPY p_x_line_tbl
                  IN OUT NOCOPY  p_x_fte_source_line_tab
                  IN     p_config_count
                  OUT NOCOPY
                       x_return_status
                       x_no_opr_count
  Description :   This Procedure processes the FTE output and
                  is called from procedure process_fte_actions.
                  In this Procedure FTE line table is traversed
                  if there is any change in the ship method
                  we will update the changes in the line and
                  and Call Process Order. Process Order should
                  not be called when there are no lines with
                  operation equal to UPDATE. Count number of
                  lines which have operation as none and do
                  not call update results if there is atleast
                  one line with operation update.

                  o/p parameters are cascaded on CONFIG line
                  from its ato parent line.
  Change Record :

 +--------------------------------------------------------------*/

PROCEDURE Process_FTE_Output
( p_x_fte_source_line_tab  IN OUT NOCOPY
                           FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
 ,p_config_count           IN     NUMBER
 ,x_no_opr_count           OUT NOCOPY /* file.sql.39 change */    NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */    VARCHAR2 )
IS
  l_fte_count      NUMBER   :=  1;
  l_line_offset    NUMBER   :=  0;
  l_index          NUMBER   :=  1;

 l_order_source_id            NUMBER;
 l_orig_sys_document_ref      VARCHAR2(50);
 l_orig_sys_line_ref          VARCHAR2(50);
 l_orig_sys_shipment_ref      VARCHAR2(50);
 l_change_sequence            VARCHAR2(50);
 l_source_document_id         NUMBER;
 l_source_document_line_id    NUMBER;
 l_source_document_type_id    NUMBER;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  Print_Time('Entering OE_FTE_INTEGRATION_PVT.Process_FTE_Output..');

  x_no_opr_count    :=  0;
  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  l_line_offset     :=  p_config_count + 1;

   IF l_debug_level > 0 THEN
      oe_debug_pub.Add('Total Number of Config lines:'||p_config_count,3);
      oe_debug_pub.Add('Line Offset is :'||l_line_offset,3);
   END IF;

  WHILE l_fte_count IS NOT NULL
  LOOP
    IF l_debug_level > 0 THEN
    oe_debug_pub.Add('--------- FTE Results ----------',3);

    oe_debug_pub.Add('Source Line     :'||
        p_x_fte_source_line_tab(l_fte_count).source_line_id,3);

    oe_debug_pub.Add('Ship Method     :'||
        p_x_fte_source_line_tab(l_fte_count).ship_method_code,3);

    oe_debug_pub.Add('Frieght Carrier     :'||
        p_x_fte_source_line_tab(l_fte_count).freight_carrier_code,3);

    oe_debug_pub.Add('Service Level     :' ||
        p_x_fte_source_line_tab(l_fte_count).service_level,3);

    oe_debug_pub.Add('Mode of Transport   :'||
        p_x_fte_source_line_tab(l_fte_count).mode_of_transport,3);

    oe_debug_pub.Add('Frieght Terms     :'||
        p_x_fte_source_line_tab(l_fte_count).freight_terms,3);

    oe_debug_pub.Add('Weight      :'||
        p_x_fte_source_line_tab(l_fte_count).weight,3);

    oe_debug_pub.Add('Weight UOM    :'||
        p_x_fte_source_line_tab(l_fte_count).weight_uom_code,3);

    oe_debug_pub.Add('Volume      :'||
        p_x_fte_source_line_tab(l_fte_count).volume,3);

    oe_debug_pub.Add('Volume UOM    :'||
        p_x_fte_source_line_tab(l_fte_count).volume_uom_code,3);

    oe_debug_pub.Add('Frieght Rate    :'||
        p_x_fte_source_line_tab(l_fte_count).freight_rate,3);

    oe_debug_pub.Add('Frieght Rate Currency :'||
        p_x_fte_source_line_tab(l_fte_count).freight_rate_currency,3);

    oe_debug_pub.Add('Status      :'||
        p_x_fte_source_line_tab(l_fte_count).status,3);

    END IF;

    IF  p_x_fte_source_line_tab(l_fte_count).status =
                                FND_API.G_RET_STS_ERROR THEN

      IF p_x_fte_source_line_tab(l_fte_count).source_line_id IS NOT NULL AND
         p_x_fte_source_line_tab(l_fte_count).source_line_id <> FND_API.G_MISS_NUM THEN
         BEGIN
            IF l_debug_level > 0 THEN
               oe_debug_pub.add('Getting reference data for line_id:'||
                           p_x_fte_source_line_tab(l_fte_count).source_line_id);
            END IF;
            SELECT order_source_id, orig_sys_document_ref, orig_sys_line_ref,
                   orig_sys_shipment_ref, change_sequence, source_document_id,
                   source_document_line_id, source_document_type_id
            INTO l_order_source_id, l_orig_sys_document_ref, l_orig_sys_line_ref,
                 l_orig_sys_shipment_ref, l_change_sequence, l_source_document_id,
                 l_source_document_line_id, l_source_document_type_id
            FROM oe_order_lines_all
            WHERE line_id = p_x_fte_source_line_tab(l_fte_count).source_line_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               IF l_debug_level > 0 THEN
                  oe_debug_pub.add('No_data_found while getting reference data '||
                     'for line_id:'||p_x_fte_source_line_tab(l_fte_count).source_line_id);
               END IF;
               l_order_source_id := NULL;
               l_orig_sys_document_ref := NULL;
               l_orig_sys_line_ref := NULL;
               l_orig_sys_shipment_ref := NULL;
               l_change_sequence := NULL;
               l_source_document_id := NULL;
               l_source_document_line_id := NULL;
               l_source_document_type_id := NULL;
          END;
      END IF;

      OE_Msg_Pub.Set_Msg_Context
      (p_entity_code => OE_GLOBALS.G_ENTITY_LINE
      ,p_entity_id   => p_x_fte_source_line_tab(l_fte_count).source_line_id
      ,p_header_id   => p_x_fte_source_line_tab(l_fte_count).source_header_id
      ,p_line_id     => p_x_fte_source_line_tab(l_fte_count).source_line_id
      ,p_order_source_id            => l_order_source_id
      ,p_orig_sys_document_ref      => l_orig_sys_document_ref
      ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
      ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
      ,p_change_sequence            => l_change_sequence
      ,p_source_document_id         => l_source_document_id
      ,p_source_document_line_id    => l_source_document_line_id
      ,p_source_document_type_id    => l_source_document_type_id);

      OE_MSG_PUB.Add_Text(p_x_fte_source_line_tab(l_fte_count).message_data);
      IF l_debug_level > 0 THEN
        oe_debug_pub.Add
         ('FTE Error :'|| p_x_fte_source_line_tab(l_fte_count).message_data,3);
      END IF;
      p_x_line_tbl(l_line_offset).operation := OE_GLOBALS.G_OPR_NONE;
      x_no_opr_count   := x_no_opr_count + 1;
      x_return_status  := FND_API.G_RET_STS_ERROR;

    ELSE -- warning or success

      IF  p_x_fte_source_line_tab(l_fte_count).status = 'W' THEN
        OE_MSG_PUB.Add_Text
        (p_x_fte_source_line_tab(l_fte_count).message_data);
      IF l_debug_level > 0 THEN
        oe_debug_pub.Add
         ('FTE Warning:'|| p_x_fte_source_line_tab(l_fte_count).message_data,3);
      END IF;
      END IF;


      IF (p_x_fte_source_line_tab(l_fte_count).ship_method_code) <>
          nvl(p_x_line_tbl(l_line_offset).shipping_method_code,'-99') OR
         (p_x_fte_source_line_tab(l_fte_count).freight_carrier_code)  =
          nvl(p_x_line_tbl(l_line_offset).freight_carrier_code,'-99') OR
         (p_x_fte_source_line_tab(l_fte_count).freight_terms)  =
          nvl(p_x_line_tbl(l_line_offset).freight_terms_code,'-99')
      THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.Add('Change :'|| p_x_line_tbl(l_line_offset).line_id,3);
         END IF;

        p_x_line_tbl(l_line_offset).shipping_method_code   :=
           p_x_fte_source_line_tab(l_fte_count).ship_method_code;

        p_x_line_tbl(l_line_offset).freight_carrier_code   :=
           p_x_fte_source_line_tab(l_fte_count).freight_carrier_code;

        p_x_line_tbl(l_line_offset).freight_terms_code      :=
           p_x_fte_source_line_tab(l_fte_count).freight_terms;

        p_x_line_tbl(l_line_offset).operation := OE_GLOBALS.G_OPR_UPDATE;

        /* Start Audit Trail */

        p_x_line_tbl(l_line_offset).change_reason := 'SYSTEM';
        p_x_line_tbl(l_line_offset).change_comments := 'Get Ship Method Action';

        /* End Audit Trail */

      ELSE -- no change, set the operation to none.
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('No Changes to save', 4);
         END IF;
        p_x_line_tbl(l_line_offset).operation := OE_GLOBALS.G_OPR_NONE;
      x_no_opr_count   := x_no_opr_count + 1;
      END IF;

    END IF; -- if error.


    -- cascade to CONFIG line, we need to do this irrespective
    -- of the fte source line ret status because we need to
    -- push the offset anyway.

    IF p_config_count > 0 AND l_index <= p_config_count THEN

      IF p_x_line_tbl(l_line_offset).ato_line_id =
         p_x_line_tbl(l_line_offset).line_id  THEN

        -- This is an ATO Model
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('ato model '||p_x_line_tbl(l_line_offset).line_id,3);
         END IF;

        IF p_x_line_tbl(l_index).ato_line_id =
               p_x_line_tbl(l_line_offset).line_id
        THEN

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('cfg line '|| p_x_line_tbl(l_index).line_id, 3);
           END IF;

          IF p_x_line_tbl(l_line_offset).operation = OE_GLOBALS.G_OPR_UPDATE
          THEN

            p_x_line_tbl(l_index).shipping_method_code   :=
               p_x_line_tbl(l_line_offset).shipping_method_code;

            p_x_line_tbl(l_index).freight_carrier_code   :=
               p_x_line_tbl(l_line_offset).freight_carrier_code;

            p_x_line_tbl(l_index).freight_terms_code   :=
               p_x_line_tbl(l_line_offset).freight_terms_code;

            /* Start Audit Trail */

            p_x_line_tbl(l_index).change_reason := 'SYSTEM';
            p_x_line_tbl(l_index).change_comments := 'Get Ship Method Action';

            /* End Audit Trail */

            IF l_debug_level > 0 THEN
              oe_debug_pub.Add('Cascading Ship Method from:' ||
              p_x_line_tbl(l_line_offset).line_id ||' to ' ||
              p_x_line_tbl(l_index).line_id,3);
            END IF;

          END IF;
           IF l_debug_level > 0 THEN
             oe_debug_pub.add
             ('cfg opr '||p_x_line_tbl(l_line_offset).operation, 3);
           END IF;

          p_x_line_tbl(l_index).operation :=
                      p_x_line_tbl(l_line_offset).operation;

          l_index :=  l_index  + 1;

        END IF;

      END IF;
    END IF; -- l_config_count

    l_fte_count   := p_x_fte_source_line_tab.NEXT(l_fte_count);
    l_line_offset :=  l_line_offset  + 1;

  END LOOP;

  Print_Time('Entering OE_FTE_INTEGRATION_PVT.Process_FTE_Output..');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.Add('Expected Error in Process FTE Output', 1);
     END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
       oe_debug_pub.Add('Unexpected Error in Process FTE Output'||
                    sqlerrm, 2);
     END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Process_FTE_Output');
    END IF;
END Process_FTE_Output;


/*--------------------------------------------------------------+
  Name        :   Process_FTE_Action
  Parameters  :   IN  p_header_id
                      p_line_id - should be null for now
                      p_ui_flag
                      p_action  - 'C','R'or 'B'
                      p_call_pricing_for_FR - for freight rates
                  OUT NOCOPY
                      x_msg_count
                      x_msg_data
                      x_return_status
  Description :   This Procedure is called from OEXOEFRM.pld
                  when Get Ship Method or Get Freight Rate or
                  Get Ship Method and Freight Rate action is
                  selected.
                  It is also called from process order delayed
                  requests and actions processing.
                  THe p_action 'C','R'or 'B' to indicate
                  whether the 3 actions that can be performed.

                  First FTE input record is prepared. The FTE procedure
                  Process lines is called to process FTE action.
                  Then based on the p_action we call apprpriate
                  o/p processing API i.e. to save ship menthods
                  and / or rates.

  Change Record :

 +--------------------------------------------------------------*/

PROCEDURE Process_FTE_Action
( p_header_id             IN    NUMBER
 ,p_line_id               IN    NUMBER
 ,p_ui_flag               IN    VARCHAR2
 ,p_action                IN    VARCHAR2
 ,p_call_pricing_for_FR   IN    VARCHAR2
 ,x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2
 ,x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER
 ,x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
  l_fte_source_line_tab    FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab;
  l_fte_source_header_tab  FTE_PROCESS_REQUESTS.Fte_Source_Header_Tab;
  l_fte_rates_tab          FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Tab;
  l_fte_header_rates_tab   FTE_PROCESS_REQUESTS.Fte_Source_Header_Rates_Tab;
  l_line_tbl               OE_Order_PUB.Line_Tbl_Type;
  l_config_count           NUMBER;
  l_no_opr_count           NUMBER;
  l_msg_text               VARCHAR2(2000);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  Print_Time('Entering Process_FTE_Action...'|| p_action);

  IF p_line_id is not NULL THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('line id not null, error for now', 1);
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status  :=   FND_API.G_RET_STS_SUCCESS;

  IF p_ui_flag  = 'Y' THEN
    OE_MSG_PUB.Initialize;
  END IF;

  -- Check whether FTE is Installed. If not Exit

  IF OE_GLOBALS.G_FTE_INSTALLED IS NULL THEN
     OE_GLOBALS.G_FTE_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(716);
  END IF;

  IF OE_GLOBALS.G_FTE_INSTALLED = 'N' THEN
     FND_MESSAGE.Set_Name('ONT','ONT_FTE_NOT_INSTALLED');
     OE_MSG_PUB.Add;
      IF l_debug_level > 0 THEN
        oe_debug_pub.ADD('FTE is NOT Installed!',3);
      END IF;
     x_return_status  :=   FND_API.G_RET_STS_ERROR;
     RETURN;
  END IF;

  Create_FTE_Input
  ( p_header_id              => p_header_id
   ,p_line_id                => p_line_id
   ,p_x_fte_source_line_tab  => l_fte_source_line_tab
   ,p_x_line_tbl             => l_line_tbl
   ,p_action                 => p_action
   ,x_config_count           => l_config_count
   ,x_return_status          => x_return_status);

   IF l_debug_level > 0 THEN
     oe_debug_pub.Add('After Calling Create FTE Input :'||
                x_return_status,3);
   END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level > 0 THEN
     oe_debug_pub.add(x_msg_data,1);
    END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
   IF l_debug_level > 0 THEN
    oe_debug_pub.Add('Before Calling FTE Process Lines...',3);
   END IF;

  -- Call FTE only if the number of lines is greater than zero.

  IF l_line_tbl.Count > 0  THEN

     FTE_PROCESS_REQUESTS.Process_Lines
     ( p_source_line_tab       => l_fte_source_line_tab
      ,p_source_header_tab     => l_fte_source_header_tab
      ,p_source_type           => 'ONT'
      ,p_action                => p_action
      ,x_source_line_rates_tab => l_fte_rates_tab
      ,x_source_header_rates_tab => l_fte_header_rates_tab
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data );

   IF l_debug_level > 0 THEN
     oe_debug_pub.Add('After Calling FTE Process Lines:'||
                x_return_status,3);
   END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       IF ( FND_MSG_PUB.Count_Msg > 0 ) THEN
         FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
           l_msg_text := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
            IF l_debug_level > 0 THEN
               oe_debug_pub.Add(l_msg_text, 3);
            END IF;
           oe_msg_pub.add_text(p_message_text => l_msg_text);
         END LOOP;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
     END IF;



     IF p_action = 'B' OR
        p_action = 'C' THEN
       IF l_debug_level > 0 THEN
       oe_debug_pub.add('processing o/p for carrier', 1);
       END IF;
       Process_FTE_Output
       ( p_x_fte_source_line_tab  =>   l_fte_source_line_tab
        ,p_x_line_tbl             =>   l_line_tbl
        ,p_config_count           =>   l_config_count
        ,x_no_opr_count           =>   l_no_opr_count
        ,x_return_status          =>   x_return_status);

     IF l_debug_level > 0 THEN
     oe_debug_pub.Add('After Calling Process FTE Output: '||
                   x_return_status);
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- set the recursion flag so that FTE won't be called
     -- again for Freight Rating if ship method is changed
     -- due to the call to FTE.
     oe_globals.g_freight_recursion := 'Y';

      IF l_debug_level > 0 THEN
         oe_debug_pub.Add('Before Calling Update FTE Results...',3);
      END IF;

     -- If there are no lines with operation UPDATE donot call
     -- Update Fte Results.

     IF l_no_opr_count   < l_line_tbl.count THEN
        Update_FTE_Results
        ( p_x_line_tbl      => l_line_tbl
         ,x_return_status   => x_return_status);

      IF l_debug_level > 0 THEN
       oe_debug_pub.Add('After Calling Update FTE Results...'||
                      x_return_status,3);
      END IF;

     ELSE
      IF l_debug_level > 0 THEN
       oe_debug_pub.Add('Donot Call Update Results!!:'||l_line_tbl.count,1);
       oe_debug_pub.Add('No of Lines with Opr None:'||l_no_opr_count,1);
      END IF;
     END IF;

     oe_globals.g_freight_recursion := 'N';

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
     END IF;


    END IF; -- action is carrier or both

    IF p_action = 'B' OR
       p_action = 'R' THEN
      IF l_debug_level > 0 THEN
      oe_debug_pub.add('processing o/p for rating', 1);
      END IF;

      OE_FREIGHT_RATING_PVT.Process_FTE_Output
      ( p_header_id             =>   p_header_id
       ,p_x_fte_source_line_tab =>   l_fte_source_line_tab
       ,p_x_line_tbl            =>   l_line_tbl
       ,p_fte_rates_tab         =>   l_fte_rates_tab
       ,p_config_count          =>   l_config_count
       ,p_ui_flag               =>   p_ui_flag
       ,p_call_pricing_for_FR   =>   p_call_pricing_for_FR
       ,x_return_status         =>   x_return_status);

      IF l_debug_level > 0 THEN
        oe_debug_pub.Add('After Calling FREIGHT Process_FTE_Output '||
           x_return_status,3);
      END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
     END IF;

    END IF;
  END IF; -- l_line_tbl.count > 0

  OE_MSG_PUB.Count_And_Get
  ( p_count   => x_msg_count
   ,p_data    => x_msg_data);

   IF l_debug_level > 0 THEN
     oe_debug_pub.Add('Message Count :'||x_msg_count,3);
   END IF;

  Print_Time('Exiting OE_FTE_INTEGRATION_PVT.Process_FTE_Action...');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
       oe_debug_pub.Add('Expected Error in Get Ship Method', 1);
     END IF;

    OE_MSG_PUB.Count_And_Get
         ( p_count   => x_msg_count
        ,p_data  => x_msg_data);

    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.Add('Unexpected Error in Get Ship Method'||sqlerrm, 2);
     END IF;

    OE_MSG_PUB.Count_And_Get
         ( p_count   => x_msg_count
        ,p_data  => x_msg_data);

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level > 0 THEN
        oe_debug_pub.Add('When Others in Get Ship Method'||sqlerrm,3);
     END IF;

    OE_MSG_PUB.Count_And_Get
         ( p_count   => x_msg_count
        ,p_data  => x_msg_data);

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Process_FTE_Action');
    END IF;

END Process_FTE_Action;

END OE_FTE_INTEGRATION_PVT;

/
