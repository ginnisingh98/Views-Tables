--------------------------------------------------------
--  DDL for Package Body OE_FREIGHT_CHOICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FREIGHT_CHOICES_PVT" AS
/* $Header: OEXVFCHB.pls 120.4.12010000.5 2008/11/14 23:11:03 rbadadar ship $ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'OE_FREIGHT_CHOICES_PVT';
G_config_count                 NUMBER;
--G_line_tbl		OE_Order_PUB.Line_Tbl_Type;

TYPE number_type is table of number index by binary_integer;

/*--------------------------------------------------------------+
 | Local Procedures and Function Declarations                   |
 +--------------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

PROCEDURE Prepare_Freight_Choices_Input
( p_header_id              IN      NUMBER
 ,p_x_fte_source_line_tab  IN OUT  NOCOPY
                                   FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab
 ,p_x_line_tbl             IN OUT  NOCOPY  OE_ORDER_PUB.Line_Tbl_Type
 ,p_action                 IN      VARCHAR2
 ,x_config_count           OUT NOCOPY /* file.sql.39 change */     NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2);


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
  Name        :   Prepare_Freight_Choices_Input
  Parameters  :   IN OUT NOCOPY p_x_line_tbl
                  IN OUT NOCOPY  p_x_fte_source_line_tab
                  IN  p_header_id
                  IN  p_line_id
                  IN  p_action
                  OUT NOCOPY  x_return_status
                  OUT NOCOPY  x_config_count

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

PROCEDURE Prepare_Freight_Choices_Input
( p_header_id              IN      NUMBER
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
           ,schedule_arrival_date
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
    FROM   oe_order_lines_all
    WHERE  header_id  =  p_header_id
    AND    p_action <> 'R'
    ORDER BY top_model_line_id, ato_line_id, sort_order;


   CURSOR   C_INC_ITEMS_PARENT IS
     SELECT line_id
     FROM    oe_order_lines_all
     WHERE   item_type_code IN ('MODEL', 'CLASS', 'KIT')
     AND     ato_line_id is NULL
     AND     explosion_date is NULL
     AND     NVL(fulfilled_flag,'N') <> 'Y'
     AND     open_flag     = 'Y'
     AND     shipped_quantity IS NULL
     AND     source_type_code     = 'INTERNAL'
     AND     header_id = p_header_id;

  l_open_flag                      VARCHAR2(1);
  l_order_category_code            VARCHAR2(30);
  l_line_count                     NUMBER          := 0;
  l_config_count                   NUMBER          := 0;
  l_count                          NUMBER          := 0;
  l_transactional_curr_code        VARCHAR2(15);
  l_conversion_type_code           VARCHAR2(30);
  l_line_rec                       OE_ORDER_PUB.line_rec_type   :=
                                                OE_Order_Pub.G_MISS_LINE_REC;
  l_debug_level                    CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  Print_Time('Entering OE_FREIGHT_CHOICES_PVT.Prepare_Freight_Choices_Input...');

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Order header Id:'||p_header_id,1);
  END IF;
  x_return_status   := FND_API.G_RET_STS_SUCCESS;

  -- Validating Order
  -- transactional curr code is also selected
  BEGIN
    SELECT open_flag,order_category_code,transactional_curr_code,conversion_type_code
    INTO   l_open_flag,l_order_category_code,l_transactional_curr_code,l_conversion_type_code
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
  FROM   oe_order_lines_all
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

      p_x_fte_source_line_tab(l_count).arrival_date       :=
            c_ship_method.schedule_arrival_date;

      p_x_fte_source_line_tab(l_count).currency           :=
                 l_transactional_curr_code;

      p_x_fte_source_line_tab(l_count).currency_conversion_type :=
                 l_conversion_type_code;

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
      p_x_fte_source_line_tab(l_count).override_ship_method := 'Y';

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

      oe_debug_pub.Add('Transactional Currency :'||
         p_x_fte_source_line_tab(l_count).currency,3);

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

      G_Ship_Date_tbl(c_ship_method.line_id).Schedule_Ship_Date := c_ship_method.Schedule_Ship_Date;
      G_Ship_Date_tbl(c_ship_method.line_id).Line_id            := c_ship_method.line_id;
   END LOOP;

   -- this check is added to show the message when no lines of the order are eligible for freight rating

   IF p_x_line_tbl.count = 0  THEN

    FND_MESSAGE.Set_Name('ONT','ONT_FTE_NO_LINES_ELIGIBLE');
    OE_MSG_PUB.Add;
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('No lines of the order are eligible for freight rating');
       END IF; -- bug 7433107
	 --l_return_status = FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
       -- END IF; -- bug 7433107
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.Add('FTE Input count:'||p_x_fte_source_line_tab.count,3);
      oe_debug_pub.Add('Total count:'|| p_x_line_tbl.count,3);
   END IF;

   for i in G_Ship_Date_tbl.first..G_Ship_Date_tbl.last loop
      if G_Ship_Date_tbl.exists(i) Then
         oe_debug_pub.Add('Shedule Ship Date Value .. '||G_Ship_Date_tbl(i).Schedule_Ship_Date);
      end if;
   end loop;

   Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Prepare_Freight_Choices_Input...');
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
        'Prepare_Freight_Choices_Input');
    END IF;

END Prepare_Freight_Choices_Input;

PROCEDURE Get_Shipment_Summary
(p_header_id		IN   NUMBER,
 x_shipment_count       OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2)

IS
l_line_tbl		OE_Order_PUB.Line_Tbl_Type;
l_fte_source_line_tab	FTE_PROCESS_REQUESTS.fte_source_line_tab;
l_fte_source_header_tab	FTE_PROCESS_REQUESTS.fte_source_header_tab;
l_fte_line_rates_tab    FTE_PROCESS_REQUESTS.fte_source_line_rates_tab;
l_fte_header_rates_tab  FTE_PROCESS_REQUESTS.fte_source_header_rates_tab;
--l_rating_parameters_tab FTE_PROCESS_REQUESTS.fte_rating_parameters_tab;
l_return_status		VARCHAR2(1);
l_msg_data		VARCHAR2(2000);
l_msg_count		NUMBER;
l_config_count		NUMBER;
i                       NUMBER;
l_debug_level           CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_msg_text              VARCHAR2(2000);

BEGIN

     oe_debug_pub.add(' Entering the procedure Get_shipment_Summary');

  x_shipment_count := 0;

	-- Prepare the input information for FTE.
	--OE_FTE_INTEGRATION_PVT.Create_FTE_Input
        Prepare_Freight_Choices_Input
  	( p_header_id              	=> p_header_id
	 --,p_line_id                     => NULL
 	 ,p_x_fte_source_line_tab  	=> l_fte_source_line_tab
  	 ,p_x_line_tbl             	=> l_line_tbl
         ,p_action                 	=> 'X'
  	 ,x_config_count           	=> l_config_count
 	 ,x_return_status         	=> l_return_status
        );

	x_return_status := l_return_status;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
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

   	--x_shipment_count := 15;


     -- Call FTE to get group info only if the number of lines is greater than zero
	IF l_fte_source_line_tab.Count > 0  THEN

	Print_Time('Calling FTE for Get_Group ... ');
  	FTE_PROCESS_REQUESTS.Process_Lines(
  		p_source_line_tab 	=> l_fte_source_line_tab,
  		p_source_header_tab 	=> l_fte_source_header_tab,
 		p_source_type 		=> 'ONT',
  		p_action 		=> 'GET_GROUP', --  to get group info
               --p_rating_parameters_tab => l_rating_parameters_tab,
                x_source_line_rates_tab  => l_fte_line_rates_tab,
  		x_source_header_rates_tab=> l_fte_header_rates_tab,
  		x_return_status 	=> l_return_status,
  		x_msg_count 		=> l_msg_count,
  		x_msg_data 		=> l_msg_data);

	x_return_status := l_return_status;
         Print_Time('After Calling FTE for Get_Group ... ');
	 IF l_debug_level > 0 THEN
		     oe_debug_pub.Add('After Calling FTE Process Lines:'||
									l_return_status,3);
		     --x_shipment_count := 15;
	 END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
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

     g_line_tbl               := l_line_tbl;
     g_fte_source_line_tab    := l_fte_source_line_tab;
     g_fte_source_header_tab  := l_fte_source_header_tab;

     oe_debug_pub.Add('header tab count is : ' || l_fte_source_header_tab.Count);
     oe_debug_pub.Add('line tab count is : ' || l_fte_source_line_tab.Count);


     g_config_count := l_config_count;

      -- populate the global table with FTE results.

    --Get the ship_from,ship_to,total_weight,total_volume,freight_terms,scheduled_ship_date for the line from l_fte_header_source_tab
      For i IN l_fte_source_header_tab.FIRST .. l_fte_source_header_tab.LAST LOOP
        g_shipment_summary_tbl(i).consolidation_id := l_fte_source_header_tab(i).consolidation_id;
	g_shipment_summary_tbl(i).ship_from := l_fte_source_header_tab(i).Ship_from_Org_Id;
	g_shipment_summary_tbl(i).ship_to   := l_fte_source_header_tab(i).Ship_to_site_Id;
	g_shipment_summary_tbl(i).total_weight := l_fte_source_header_tab(i).total_weight;
        g_shipment_summary_tbl(i).weight_uom := l_fte_source_header_tab(i).weight_uom_code;
	g_shipment_summary_tbl(i).total_volume := l_fte_source_header_tab(i).total_volume;
        g_shipment_summary_tbl(i).volume_uom :=  l_fte_source_header_tab(i).volume_uom_code;
	g_shipment_summary_tbl(i).freight_terms := l_fte_source_header_tab(i).freight_terms;

        For j in g_fte_source_line_tab.FIRST .. g_fte_source_line_tab.LAST LOOP
         IF g_fte_source_line_tab(j).consolidation_id = l_fte_source_header_tab(i).consolidation_id then
          If G_Ship_Date_tbl.exists(g_fte_source_line_tab(j).source_line_id) Then
	   g_shipment_summary_tbl(i).scheduled_ship_date := G_Ship_Date_tbl(g_fte_source_line_tab(j).source_line_id).Schedule_Ship_Date;
          End If;
         End If;
        End Loop;

      END LOOP;

    x_shipment_count := g_shipment_summary_tbl.count;

   End If;  -- l_fte_source_line_tab.Count > 0
  --oe_debug_pub.add('Before print time');
  Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Get_Shipment_Summary...');
  oe_debug_pub.add('Exiting OE_FREIGHT_CHOICES_PVT.Get_Shipment_Summary');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level > 0 THEN
    oe_debug_pub.Add('Expected Error in Get Shipment Summary',2);
    END IF;


END Get_Shipment_Summary;

PROCEDURE Get_Shipment_Summary_Tbl
(x_shipment_summary_tbl	IN OUT NOCOPY /* file.sql.39 change */ shipment_summary_tbl_type)
IS

BEGIN

    oe_debug_pub.add('Entering Get shipment summary tbl');
     oe_debug_pub.add('count:'||g_shipment_summary_tbl.count);

  IF g_shipment_summary_tbl.count >0 THEN
    For I IN g_shipment_summary_tbl.FIRST .. g_shipment_summary_tbl.LAST LOOP
	x_shipment_summary_tbl(i).consolidation_id := g_shipment_summary_tbl(i).consolidation_id;
	x_shipment_summary_tbl(i).ship_from := g_shipment_summary_tbl(i).ship_from;
	x_shipment_summary_tbl(i).ship_to := g_shipment_summary_tbl(i).ship_to;
	x_shipment_summary_tbl(i).total_weight := g_shipment_summary_tbl(i).total_weight;
        x_shipment_summary_tbl(i).weight_uom := g_shipment_summary_tbl(i).weight_uom;
        x_shipment_summary_tbl(i).total_volume := g_shipment_summary_tbl(i).total_volume;
        x_shipment_summary_tbl(i).volume_uom := g_shipment_summary_tbl(i).volume_uom;
        x_shipment_summary_tbl(i).freight_terms := g_shipment_summary_tbl(i).freight_terms;
	x_shipment_summary_tbl(i).scheduled_ship_date := g_shipment_summary_tbl(i).scheduled_ship_date;
    END LOOP;
 END IF;

  oe_debug_pub.add(' exiting the get_shipment_summary_tbl proc');

END Get_Shipment_Summary_Tbl;

PROCEDURE Prepare_Adj_Detail
( p_header_id       IN   NUMBER
 ,p_line_id         IN   NUMBER
 ,p_fte_rates_rec   IN   FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_rec
 ,x_line_adj_rec    OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
 ,x_return_status   OUT NOCOPY VARCHAR2

) IS

  l_price_adjustment_id     number := 0;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING PROCEDURE PREPARE_ADJ_DETAIL.' , 3 ) ;
    END IF;
    x_return_status   := FND_API.G_RET_STS_SUCCESS;

    select oe_price_adjustments_s.nextval into l_price_adjustment_id
    from dual;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRICE ADJUSTMENT ID IN PREPARE_ADJ_DETAIL IS: ' ||L_PRICE_ADJUSTMENT_ID , 1 ) ;
       oe_debug_pub.add(  'LINE_ID IN PREPARE_ADJ_DETAIL IS: ' ||P_LINE_ID , 1 ) ;
    END IF;

    x_line_adj_rec.header_id := p_header_id;
    x_line_adj_rec.line_id := p_line_id;
    x_line_adj_rec.price_adjustment_id := l_price_adjustment_id;
    x_line_adj_rec.creation_date := sysdate;
    x_line_adj_rec.last_update_date := sysdate;
    x_line_adj_rec.created_by := 1;
    x_line_adj_rec.last_updated_by := 1;
    x_line_adj_rec.last_update_login := 1;

    x_line_adj_rec.automatic_flag := 'Y';
    x_line_adj_rec.adjusted_amount := p_fte_rates_rec.adjusted_price;
    oe_debug_pub.add('value of cost ' ||p_fte_rates_rec.adjusted_price);
    x_line_adj_rec.charge_type_code := p_fte_rates_rec.cost_type;
    oe_debug_pub.add('value of cost_type '||p_fte_rates_rec.cost_type);
    x_line_adj_rec.list_line_type_code := 'COST';
    x_line_adj_rec.estimated_flag := 'Y';
    x_line_adj_rec.source_system_code := 'FTE';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING PROCEDURE PREPARE_ADJ_DETAIL.' , 3 ) ;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN PROCEDURE PREPARE_ADJ_DETAIL: '||SUBSTR ( SQLERRM , 1 , 240 ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN PREPRARE_ADJ_DETAIL :'||SQLERRM , 3 ) ;
      END IF;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Prepare_Adj_Detail');
      END IF;
END Prepare_Adj_Detail;


PROCEDURE Create_Dummy_Adjustment(p_header_id in number
				 ) IS
l_price_adjustment_id number := -1;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF p_header_id is not null THEN

    select oe_price_adjustments_s.nextval
    into   l_price_adjustment_id
    from   dual;

    INSERT INTO oe_price_adjustments
           (PRICE_ADJUSTMENT_ID
           ,HEADER_ID
           ,LINE_ID
           ,PRICING_PHASE_ID
           ,LIST_LINE_TYPE_CODE
           ,LIST_HEADER_ID
           ,LIST_LINE_ID
           ,ADJUSTED_AMOUNT
           ,AUTOMATIC_FLAG
           ,UPDATED_FLAG
           ,APPLIED_FLAG
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           )
    VALUES
          (l_price_adjustment_id
           ,p_header_id
           ,NULL
           ,-1
           ,'OM_CALLED_CHOOSE_SHIP_METHOD'
           ,-1*p_header_id
           ,NULL
           ,-1
           ,'N'
           ,'Y'
           ,NULL
           ,sysdate
           ,1
           ,sysdate
           ,1
          );

  END IF;
END Create_Dummy_Adjustment;

Function  Get_List_Line_Type_Code
(   p_key       IN NUMBER)
RETURN Number
IS
l_count Number := 0;
 Begin

     Select Count(*) into l_count from
       oe_price_adjustments
       where header_id = p_key
       and LIST_LINE_TYPE_CODE = 'OM_CALLED_CHOOSE_SHIP_METHOD';

     Return l_count;

End;

PROCEDURE Get_Freight_Choices
( p_consolidation_id              	IN    NUMBER,
  x_return_status                       OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
  x_msg_count                           OUT NOCOPY /* file.sql.39 change */   NUMBER,
  x_msg_data                            OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

 l_fte_source_line_tab		FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab;
 l_fte_source_header_tab	FTE_PROCESS_REQUESTS.Fte_Source_Header_Tab;
 l_fte_line_rate_tab		FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Tab;
 l_fte_header_rate_tab		FTE_PROCESS_REQUESTS.Fte_Source_header_Rates_Tab;
 l_price_control_rec 		OE_ORDER_PRICE_PVT.control_rec_type;
 l_line_adj_rec			OE_Order_PUB.Line_Adj_Rec_Type;
 l_line_tbl              	OE_Order_PUB.Line_Tbl_Type;
 query_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
 l_config_count           	NUMBER;
 l_no_opr_count           	NUMBER;
 l_msg_text               	VARCHAR2(2000);
 l_debug_level                  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 i                              NUMBER;
 j                              NUMBER;
 g_count                        Number := 0;
 l_index                        NUMBER;
 l_total_charges                NUMBER := 0;
 l_total_cost                   NUMBER := 0;
 l_return_status                VARCHAR2(10);
 l_Adjusted_amount              NUMBER := 0;
 q_Adjusted_amount              NUMBER := 0;
 l_meaning                      VARCHAR2(50);
 l_exists_flag                  BOOLEAN := FALSE;
 l_cost_amount                  number := 0;
 M                              NUMBER := 0;
 l_next_index                   NUMBER := 0;
 l_ship_method_code             VARCHAR2(30);
 l_source_line_id               NUMBER := 0;
 K                              NUMBER := 0;
 l_lane_id                      NUMBER := 0;

 deleted_costs number_type;

BEGIN

  /* initialize g_freight_choices_tbl for this call */

  oe_debug_pub.add(  'Entering Get Freight Choices procedure ');

  g_freight_choices_tbl.DELETE;

  For j in g_fte_source_header_tab.FIRST .. g_fte_source_header_tab.LAST LOOP
     oe_debug_pub.add( ' value of g_fte_source_header_tab ' || g_fte_source_header_tab(j).consolidation_id);
  End loop;

  For j in g_fte_source_line_tab.FIRST .. g_fte_source_line_tab.LAST LOOP
     oe_debug_pub.add( ' value of g_fte_source_line_tab ' || g_fte_source_line_tab(j).consolidation_id);
  End loop;

  IF g_fte_source_header_tab(p_consolidation_id).consolidation_id = p_consolidation_id then
	   l_fte_source_header_tab(1) := g_fte_source_header_tab(p_consolidation_id);

  END IF;

  oe_debug_pub.add(  ' Count 1');

      i := 1;
      For j in g_fte_source_line_tab.FIRST .. g_fte_source_line_tab.LAST LOOP
	IF g_fte_source_line_tab(j).consolidation_id = p_consolidation_id then
          l_fte_source_line_tab(i) := g_fte_source_line_tab(j);
	  i := i+1;
	End If;
     END LOOP;

      oe_debug_pub.add(  ' Count 2');
/*
This is used to populate the return table for the shipment details block
in Get_Shipment_Details Procedure.
*/
   g_line_shipment_details_tbl := l_fte_source_line_tab;

-- Call FTE to get freight choices only if the number of lines is
-- greater than zero.
   IF l_fte_source_line_tab.Count > 0  THEN

     oe_debug_pub.Add('before process lines ');
     oe_debug_pub.Add('source header id : ' || l_fte_source_line_tab(1).source_header_id);
     Print_Time('Calling FTE for GET_RATE_CHOICE ... ');

     		FTE_PROCESS_REQUESTS.Process_Lines (
  		p_source_line_tab 	=> l_fte_source_line_tab,
  		p_source_header_tab 	=> l_fte_source_header_tab,
 		p_source_type 		=> 'ONT',
  		p_action 		=> 'GET_RATE_CHOICE', -- to get freight rates
  		x_source_line_rates_tab  => l_fte_line_rate_tab,
  		x_source_header_rates_tab=> l_fte_header_rate_tab,
    		x_return_status 	=> l_return_status,
  		x_msg_count 		=> x_msg_count,
  		x_msg_data 		=> x_msg_data);

     Print_Time('After Calling FTE for GET_RATE_CHOICE ... ');
	IF l_debug_level > 0 THEN
	   oe_debug_pub.Add('After Calling FTE Process Lines:'||
			     l_return_status,3);
	END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
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

   g_line_shipment_details_tbl := l_fte_source_line_tab;

   -- g_fte_source_line_tab := l_fte_source_line_tab;
   --g_fte_source_header_tab := l_fte_source_header_tab;

-- Bug 6186084
    For I IN l_fte_source_header_tab.FIRST .. l_fte_source_header_tab.LAST LOOP
        g_shipment_summary_tbl(p_consolidation_id).total_weight := l_fte_source_header_tab(i).total_weight;
        g_shipment_summary_tbl(p_consolidation_id).total_volume := l_fte_source_header_tab(i).total_volume;
    END LOOP;

   For j in g_fte_source_line_tab.FIRST .. g_fte_source_line_tab.LAST LOOP
     oe_debug_pub.add( ' value of g_fte_source_line_tab ' || g_fte_source_line_tab(j).consolidation_id);
   End loop;

    g_fte_line_rate_tab := l_fte_line_rate_tab ;
    g_fte_header_rate_tab := l_fte_header_rate_tab;

   l_index := 1;

   I := l_fte_header_rate_tab.FIRST;
   j := 1;
   WHILE I IS NOT NULL LOOP

   l_ship_method_code := l_fte_header_rate_tab(I).ship_method_code;
   l_lane_id := l_fte_header_rate_tab(I).lane_id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '============ FTE RESULTS ============' , 3 ) ;
    END IF;

    M := l_fte_header_rate_tab(I).first_line_index;
    l_source_line_id := l_fte_line_rate_tab(M).source_line_id;
    K := 0;

   While M is not null loop

     oe_debug_pub.add('source line id : ' || l_fte_line_rate_tab(M).source_line_id);

     oe_debug_pub.add('ship method is: ' || l_fte_line_rate_tab(M).ship_method_code);

    IF l_fte_line_rate_tab(M).ship_method_code = l_ship_method_code
    and l_fte_line_rate_tab(M).lane_id = l_lane_id
    and l_fte_line_rate_tab(M).consolidation_id = p_consolidation_id
    THEN

      Prepare_Adj_Detail
       (p_header_id => l_fte_source_line_tab(1).source_header_id
       ,p_line_id   => l_fte_line_rate_tab(M).source_line_id
       ,p_fte_rates_rec => l_fte_line_rate_tab(M)
       ,x_line_adj_rec  => l_line_adj_rec
       ,x_return_status => l_return_status
       );

      oe_debug_pub.add('104');

      IF deleted_costs.EXISTS(l_fte_line_rate_tab(M).source_line_id) THEN
         NULL;
      ELSE
          DELETE FROM OE_PRICE_ADJUSTMENTS
          WHERE line_ID = l_fte_line_rate_tab(M).source_line_id
          AND   CHARGE_TYPE_CODE IN ('FTEPRICE','FTECHARGE')
          AND   list_line_type_code = 'COST'
          AND   ESTIMATED_FLAG = 'Y';

          deleted_costs(l_fte_line_rate_tab(M).source_line_id) := l_fte_line_rate_tab(M).source_line_id;

         oe_line_util.query_rows
   	   (p_line_id   => l_fte_line_rate_tab(M).source_line_id
   	   ,x_line_tbl  => query_line_tbl );

         K := K + 1;

         l_line_tbl(K) := query_line_tbl(1);

      END IF;  -- if deleted_costs...

      OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

    ELSE
        EXIT; -- We can exit the loop since l_fte_line_rate_tab is grouped
              -- according to lane_id, ship_method_code and consolidation_id

    END IF; --if l_fte_line_rate_tab(M).ship_method_code = l_ship_method_code

    M := l_fte_line_rate_tab.NEXT(M);

    oe_debug_pub.add('105');

   END LOOP;   --While M is not null loop

    deleted_costs.DELETE;

  -- Calling Pricing Engine to calculate freight charges
  -- if being called from Action button.

   oe_debug_pub.add('107');

  /*
  Call Pricing to do cost to charge conversion with simulation mode for this order line and
  for this ship method combination.
  populate the simulate_flag to 'Y' and populate the freight_charge_flag to 'Y' in control record,
  Also set the write_to_db to false.
  Freight_Choices_Tab should store all the applicable freight charges for this particular order line.
  */
   oe_debug_pub.add('108');

     l_price_control_rec.p_Request_Type_Code:='ONT';
     l_Price_control_rec.p_write_to_db:=FALSE;
     l_price_control_rec.p_honor_price_flag:='Y';
     l_price_control_rec.p_multiple_events:='N';
     l_price_control_rec.p_get_freight_flag:='Y';
     l_price_control_rec.p_simulation_flag := 'Y';

   oe_debug_pub.add('109');

   IF l_line_tbl.count > 0 THEN
   oe_order_price_pvt.price_line
                 (p_Header_id        => null
                 ,p_Line_id          => null
                 ,px_line_Tbl        => l_line_tbl
                 ,p_Control_Rec      => l_price_control_rec
                 ,p_action_code      => 'PRICE_LINE'
                 ,p_Pricing_Events   => 'BATCH'
                 ,x_Return_Status    => l_return_status
                 );

   oe_debug_pub.add('110');
    K := 1;
    K := l_line_tbl.FIRST;
    WHILE K IS NOT NULL LOOP

     Select sum(nvl(l.ADJUSTMENT_AMOUNT,0)) into q_Adjusted_amount from QP_ldets_v l,QP_preq_lines_tmp q
	        where l.line_index = q.line_index
		 and  q.line_id    = l_line_tbl(K).line_id
                 and  q.line_type_code = 'LINE'
                 AND  nvl(l.automatic_flag,'N') = 'Y'
                 AND l.list_line_type_code = 'FREIGHT_CHARGE';

     oe_debug_pub.add('value of ordered qty : '||nvl(l_line_tbl(K).ordered_quantity,0));

     -- Modified for bug # 7043225
          -- bug 6701769/6753485
          --l_Adjusted_amount := l_Adjusted_amount + nvl(l_line_tbl(K).ordered_quantity,0)*q_Adjusted_amount;
            l_Adjusted_amount := l_Adjusted_amount + (nvl(nvl(l_line_tbl(K).pricing_quantity,l_line_tbl(K).ordered_quantity),0)*nvl(q_Adjusted_amount,0));

     oe_debug_pub.add('6701769 value of l_Adjusted_amount : '||l_Adjusted_amount);

     K := l_line_tbl.NEXT(K);

    END LOOP;  -- while k is not null

    K := 0;

    oe_debug_pub.add('value of charges : '||l_Adjusted_amount);

    --oe_debug_pub.add('value of ordered qty : '||nvl(l_line_tbl(K).ordered_quantity,0));

    Select MEANING into l_meaning from oe_ship_methods_v
	       where LOOKUP_CODE= l_fte_header_rate_tab(I).ship_method_code
	       and LOOKUP_TYPE='SHIP_METHOD';


   /*
   We don't need to check if g_freight_choices_tbl already has
   as we are looping through fte_source_header_rates_tab and this contains
   one row for a unique combination of consolidation_id, ship_method_code and
   lane_id - Every Freight choice we show is for a unique combination of
   consolidation_id, ship_method_code and lane_id
   */

        g_freight_choices_tbl(j).consolidation_id := l_fte_header_rate_tab(i).consolidation_id ;
	g_freight_choices_tbl(j).shipping_method :=  l_meaning;
	g_freight_choices_tbl(j).shipping_method_code := l_fte_header_rate_tab(i).ship_method_code;
	g_freight_choices_tbl(j).Transit_Time := l_fte_header_rate_tab(i).transit_time;
        g_freight_choices_tbl(j).transit_time_uom := l_fte_header_rate_tab(i).transit_time_uom;
	g_freight_choices_tbl(j).charge_amount := l_Adjusted_amount;
	g_freight_choices_tbl(j).cost := l_fte_header_rate_tab(i).price;
        g_freight_choices_tbl(j).lane_id := l_fte_header_rate_tab(i).lane_id ; -- bug 4408958

        j := j + 1;
     END IF; -- If l_line_tbl.count > 0
         I := l_fte_header_rate_tab.NEXT(I);
         l_line_tbl.DELETE;
         l_Adjusted_amount := 0;
     END LOOP;  --while i is not null loop

   g_fte_source_line_rate_tab := l_fte_line_rate_tab;
   --This Global table is used in Procedure Process_Freight_Choices

   END IF; --if l_fte_source_line_tab.count > 0

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Get_Freight_Choices...');

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN PROCEDURE Get_Freight_Choices: '||SUBSTR ( SQLERRM , 1 , 240 ) , 3 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN Get_Freight_Choices :'||SQLERRM , 3 ) ;
      END IF;
    /*  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME,
              'Get_Freight_Choices');
      END IF; */

END Get_Freight_Choices;


PROCEDURE Get_Freight_Choices_Tbl
(x_freight_choices_tbl 	IN OUT NOCOPY /* file.sql.39 change */ freight_choices_tbl_type)
IS

BEGIN

   For I IN g_freight_choices_Tbl.FIRST .. g_freight_choices_tbl.LAST LOOP
     oe_debug_pub.add(' Value of Transit Time Uom .. '||g_freight_choices_tbl(i).transit_time_uom);
     x_freight_choices_tbl(i).consolidation_id := g_freight_choices_tbl(i).consolidation_id;
     x_freight_choices_tbl(i).shipping_method := g_freight_choices_tbl(i).shipping_method;
     x_freight_choices_tbl(i).shipping_method_code
				:= g_freight_choices_tbl(i).shipping_method_code;
     x_freight_choices_tbl(i).transit_time := g_freight_choices_tbl(i).transit_time;
     x_freight_choices_tbl(i).transit_time_uom := g_freight_choices_tbl(i).transit_time_uom;
     x_freight_choices_tbl(i).charge_amount := g_freight_choices_tbl(i).charge_amount;
     x_freight_choices_tbl(i).cost := g_freight_choices_tbl(i).cost;
     x_freight_choices_tbl(i).lane_id := g_freight_choices_tbl(i).lane_id; --bug 4408958

   END LOOP;

  Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Get_Freight_Choices_Tbl...');

END Get_Freight_Choices_Tbl;


PROCEDURE Get_Shipment_Details_Tbl
(x_Line_Shipment_Details_tbl 	IN OUT NOCOPY /* file.sql.39 change */ line_Shipment_Details_tbl_type)
IS

BEGIN


   For I IN g_line_shipment_details_tbl.FIRST .. g_line_shipment_details_tbl.LAST LOOP
     x_Line_Shipment_Details_tbl(i).source_line_id := g_line_shipment_details_tbl(i).source_line_id;
     x_Line_Shipment_Details_tbl(i).inventory_item_id := g_line_shipment_details_tbl(i).inventory_item_id;
     x_Line_Shipment_Details_tbl(i).source_quantity
				:= g_line_shipment_details_tbl(i).source_quantity;
     x_Line_Shipment_Details_tbl(i).source_quantity_uom := g_line_shipment_details_tbl(i).source_quantity_uom;
     x_Line_Shipment_Details_tbl(i).ship_date := g_line_shipment_details_tbl(i).ship_date;
     x_Line_Shipment_Details_tbl(i).arrival_date := g_line_shipment_details_tbl(i).arrival_date;

   END LOOP;

  Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Get_Shipment_Details_Tbl...');

END Get_Shipment_Details_Tbl;

--Bug 6186084
PROCEDURE Repopulate_Freight_Choices
(x_volume       OUT NOCOPY NUMBER,
 x_weight       OUT NOCOPY NUMBER,
 x_consolidation_id IN NUMBER)
 IS

 BEGIN
    oe_debug_pub.add('Entering Repopulate_Freight_Choices');

    IF g_shipment_summary_tbl.count >0 THEN
       x_weight := g_shipment_summary_tbl(x_consolidation_id).total_weight;
       x_volume := g_shipment_summary_tbl(x_consolidation_id).total_volume;
    END IF;

    oe_debug_pub.add('Exiting the Repopulate_Freight_Choices proc');

END Repopulate_Freight_Choices;

PROCEDURE Process_Freight_Choices
( p_header_id          	 IN    NUMBER
 ,p_consolidation_id     IN    NUMBER
 ,p_ship_method_code     IN    VARCHAR2 -- ..This New parameter is added
 ,p_lane_id              IN    NUMBER   --bug 4408958
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */   VARCHAR2
 ,x_msg_count           OUT NOCOPY /* file.sql.39 change */   NUMBER
 ,x_msg_data            OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

l_freight_choices_rec       OE_Freight_Choices_PVT.Freight_Choices_Rec_type;
l_fte_line_rate_tab         FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_Tab;
l_fte_rates_rec      	    FTE_PROCESS_REQUESTS.Fte_Source_Line_Rates_rec;
l_line_adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_fte_source_line_tab       FTE_PROCESS_REQUESTS.Fte_Source_Line_Tab;
l_line_tbl             	    OE_Order_PUB.Line_Tbl_Type;
query_line_tbl              OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_line_rec                  OE_ORDER_PUB.line_rec_type ;
l_bulk_adj_rec              OE_Freight_Rating_PVT.Bulk_Line_Adj_Rec_Type;
l_count                     Number;
l_fte_count                 Number := 1;
i                           Number := 1;
j                           Number;
l_debug_level               CONSTANT NUMBER := oe_debug_pub.g_debug_level;
M                           Number;
K                           Number;
l_order_source_id           NUMBER;
l_orig_sys_document_ref     VARCHAR2(50);
l_orig_sys_line_ref         VARCHAR2(50);
l_orig_sys_shipment_ref     VARCHAR2(50);
l_change_sequence           VARCHAR2(50);
l_source_document_id        NUMBER;
l_source_document_line_id   NUMBER;
l_source_document_type_id   NUMBER;
l_ship_method_code          VARCHAR2(30);
l_lane_id                   NUMBER := 0;
l_meaning                   VARCHAR2(50);
l_return_status             VARCHAR2(10);
l_pricing_event             VARCHAR2(30);
l_index                     NUMBER := 1;
l_adj_index                 NUMBER;
l_line_id                   NUMBER;
l_header_id                 NUMBER;
l_config_line_exists        NUMBER := 0;

deleted_costs number_type;

CURSOR   C_CONFIG_ITEM_PARENTS(p_ato_line_id IN NUMBER) IS
           SELECT  opa.price_adjustment_id,ool.line_id,
                   opa.adjusted_amount, opa.list_line_type_code,
                   opa.charge_type_code
           FROM    oe_order_lines_all ool
                  ,oe_price_adjustments opa
           WHERE   opa.charge_type_code IN ('FTEPRICE','FTECHARGE')
           AND	   list_line_type_code = 'COST' -- For bug 7043225
           AND     ool.line_id = opa.line_id
           AND     ool.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
           AND     ool.ato_line_id = p_ato_line_id;

/*CURSOR    C_CONFIG_LINE_EXISTS(p_line_id IN NUMBER) IS
            SELECT 1 from oe_order_lines_all
            WHERE ato_line_id = p_line_id
            AND   item_type_code = OE_GLOBALS.G_ITEM_CONFIG;
*/
BEGIN

   oe_debug_pub.add(' Entering the procedure process freight choices');

   Savepoint Cancel_All;
    oe_debug_pub.add('first Consolidation Id got '|| g_fte_header_rate_tab(i).Consolidation_id);

   I := g_fte_header_rate_tab.FIRST;
   WHILE I IS NOT NULL LOOP
     If g_fte_header_rate_tab(i).Consolidation_id = p_Consolidation_id and
        g_fte_header_rate_tab(i).Ship_method_code = p_ship_method_code and  --bug 4408958
	g_fte_header_rate_tab(i).lane_id = p_lane_id then
	oe_debug_pub.add('In the first I loop');
      Exit;
     End If;
   I := g_fte_header_rate_tab.NEXT(I);
   End Loop;


      oe_debug_pub.add('Consolidation Id got '|| g_fte_header_rate_tab(i).Consolidation_id);

      M := g_fte_header_rate_tab(I).first_line_index;

      K := 0;

    For j in g_fte_line_rate_tab.FIRST .. g_fte_line_rate_tab.LAST LOOP
     oe_debug_pub.add( ' Line Ids: value of g_fte_line_rate_tab' || g_fte_line_rate_tab(j).source_line_id);
     oe_debug_pub.add( ' Ship method ids : '||g_fte_line_rate_tab(j).ship_method_code);
    End loop;

    While M is not null loop

     IF g_fte_line_rate_tab(M).ship_method_code = p_ship_method_code and
         --and g_fte_line_rate_tab(M).lane_id = l_lane_id
        g_fte_line_rate_tab(M).consolidation_id = p_consolidation_id
     THEN

       	IF deleted_costs.EXISTS(g_fte_line_rate_tab(M).source_line_id) THEN
         NULL;
        ELSE
          DELETE FROM OE_PRICE_ADJUSTMENTS
          WHERE line_ID = g_fte_line_rate_tab(M).source_line_id
          AND   CHARGE_TYPE_CODE IN ('FTEPRICE','FTECHARGE')
          AND   list_line_type_code = 'COST'
          AND   ESTIMATED_FLAG = 'Y';

          deleted_costs(g_fte_line_rate_tab(M).source_line_id) := g_fte_line_rate_tab(M).source_line_id;

         oe_line_util.query_rows
   	   (p_line_id   => g_fte_line_rate_tab(M).source_line_id
   	   ,x_line_tbl  => query_line_tbl );

            K := K + 1;

	   oe_debug_pub.add('The line ids for the lines added '|| g_fte_line_rate_tab(M).source_line_id);
            l_old_line_tbl(k) := query_line_tbl(1);

       /* renga-review */
      	For j in g_fte_source_line_tab.first .. g_fte_source_line_tab.Last Loop
	   If g_fte_source_line_tab(j).source_line_id = g_fte_line_rate_tab(M).source_line_id Then
            l_count := j;
	     Exit;
	   End If;
        End Loop;


       IF (g_fte_line_rate_tab(M).ship_method_code) <>
          nvl(query_line_tbl(1).shipping_method_code,'-99')
       THEN
            IF l_debug_level > 0 THEN
         	    Null;
            END IF;
         oe_debug_pub.add('value of carrier freight code '||g_fte_line_rate_tab(M).carrier_freight_code);
	 query_line_tbl(1).shipping_method_code   :=
           g_fte_line_rate_tab(M).ship_method_code;

         query_line_tbl(1).freight_carrier_code :=
           g_fte_line_rate_tab(M).carrier_freight_code;

         query_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

        /* Start Audit Trail */

        query_line_tbl(1).change_reason := 'SYSTEM';
        query_line_tbl(1).change_comments := 'Choose Ship Method';

        /* End Audit Trail */


       ELSE -- no change, set the operation to none.
          IF l_debug_level > 0 THEN
            oe_debug_pub.add('No Changes to save', 4);
          END IF;
          /* renga-review */
          --l_line_rec.operation := OE_GLOBALS.G_OPR_NONE;

          query_line_tbl(1).operation := OE_GLOBALS.G_OPR_NONE;

          --x_no_opr_count   := x_no_opr_count + 1;

       End If;

    -- cascade to CONFIG line, we need to do this irrespective
    -- of the fte source line ret status because we need to
    -- push the offset anyway.

    IF g_config_count > 0 AND l_index <= g_config_count THEN

      IF query_line_tbl(1).ato_line_id =
         query_line_tbl(1).line_id  THEN

        -- This is an ATO Model
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('ato model '||query_line_tbl(1).line_id,3);
         END IF;

       -- added by Renga after review
       IF query_line_tbl(1).ato_line_id is not null then

         select count(*) into l_config_line_exists
         from oe_order_lines_all
         where ato_line_id = query_line_tbl(1).ato_line_id
         and item_type_code = 'CONFIG';

       END IF; --ato_line_id is not null


        IF g_line_tbl(l_index).ato_line_id =
               query_line_tbl(1).line_id
        THEN

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('cfg line '|| g_line_tbl(l_index).line_id, 3);
           END IF;

          IF query_line_tbl(1).operation = OE_GLOBALS.G_OPR_UPDATE
          THEN

            g_line_tbl(l_index).shipping_method_code   :=
               query_line_tbl(1).shipping_method_code;

            g_line_tbl(l_index).freight_carrier_code   :=
               query_line_tbl(1).freight_carrier_code;

             /* Start Audit Trail */

            g_line_tbl(l_index).change_reason := 'SYSTEM';
            g_line_tbl(l_index).change_comments := 'Get Ship Method Action';

            /* End Audit Trail */

            IF l_debug_level > 0 THEN
              oe_debug_pub.Add('Cascading Ship Method from:' ||
              query_line_tbl(1).line_id ||' to ' ||
              g_line_tbl(l_index).line_id,3);
            END IF;

         END IF;
            IF l_debug_level > 0 THEN
             oe_debug_pub.add
             ('cfg opr '||g_line_tbl(l_index).operation, 3);
           END IF;

          g_line_tbl(l_index).operation:=
                      query_line_tbl(1).operation;

          l_index :=  l_index  + 1;

        END IF;
      END IF;
   END IF;

  -- added here also

      -- Even though the ship method did not change, rates could have
      -- changed. Hence registering the line, inspite of no change.

      -- to register changed line so that repricing for this line
       -- would happen.
       oe_debug_pub.add('Register changed line: '||l_line_rec.line_id,1);
       OE_LINE_ADJ_UTIL.Register_Changed_Lines
         (p_line_id         => query_line_tbl(1).line_id,
          p_header_id       => query_line_tbl(1).header_id,
          p_operation       => OE_GLOBALS.G_OPR_UPDATE);


    END IF;  -- if deleted_costs...
/* Commented for bug 7043225. We now need to allow charges to get created on ATO Model,
   Even if config item is not yet created

    IF (query_line_tbl(1).ato_line_id =
         query_line_tbl(1).line_id ) THEN
       IF  l_config_line_exists = 1 THEN

         Prepare_Adj_Detail
            (p_header_id => query_line_tbl(1).header_id
            ,p_line_id   => g_fte_line_rate_tab(M).source_line_id
            ,p_fte_rates_rec => g_fte_line_rate_tab(M)
            ,x_line_adj_rec  => l_line_adj_rec
            ,x_return_status => l_return_status
            );

         OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

         l_config_line_exists := 0;

       END IF;

    ELSE
    */

        Prepare_Adj_Detail
            (p_header_id => query_line_tbl(1).header_id
            ,p_line_id   => g_fte_line_rate_tab(M).source_line_id
            ,p_fte_rates_rec => g_fte_line_rate_tab(M)
            ,x_line_adj_rec  => l_line_adj_rec
            ,x_return_status => l_return_status
            );

        OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

   -- END IF;--bug 7043225

          l_line_tbl(K) := query_line_tbl(1);
          /* renga-review: no need to do the following as we have done it
             for query_line_tbl in the if condition already */

          M := g_fte_line_rate_tab.NEXT(M);

    ELSE
       Exit;
    End If;

   End Loop;


  l_header_id := l_line_tbl(1).header_id;
  l_index     := 1;
  l_adj_index := 1;

  WHILE l_index <= g_config_count LOOP

    l_line_id := g_line_tbl(l_index).line_id;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CASCADING ADJUSTMENT LINES TO CONFIG LINES. ' , 3 );
    END IF;

    OPEN C_CONFIG_ITEM_PARENTS(g_line_tbl(l_index).ato_line_id);
    FETCH C_CONFIG_ITEM_PARENTS BULK COLLECT INTO
         l_bulk_adj_rec.price_adjustment_id
         ,l_bulk_adj_rec.line_id
         ,l_bulk_adj_rec.adjusted_amount
         ,l_bulk_adj_rec.list_line_type_code
         ,l_bulk_adj_rec.charge_type_code
         ;

    CLOSE C_CONFIG_ITEM_PARENTS;

      FOR i in 1..l_bulk_adj_rec.price_adjustment_id.COUNT LOOP

      l_fte_rates_rec.cost_type := l_bulk_adj_rec.charge_type_code(i);
      l_fte_rates_rec.adjusted_price := l_bulk_adj_rec.adjusted_amount(i);

       oe_debug_pub.add( ' in the config item loops .. line_id '||l_bulk_adj_rec.line_id(i));

      Prepare_Adj_Detail
         (p_header_id => l_header_id
         ,p_line_id   => l_line_id
         ,p_fte_rates_rec =>  l_fte_rates_rec
         ,x_line_adj_rec  => l_line_adj_rec
         ,x_return_status => l_return_status
          );

      --l_line_adj_tbl(l_adj_index) := l_line_adj_rec;

      -- inserting for the config line
      OE_LINE_ADJ_UTIL.INSERT_ROW(l_line_adj_rec);

       -- register changed line for config item line.
      OE_LINE_ADJ_UTIL.Register_Changed_Lines
      (p_line_id         => l_line_id,
       p_header_id       => l_header_id,
       p_operation       => OE_GLOBALS.G_OPR_UPDATE);

      -- deleting the parents of the config line.
      -- these deleted parent lines have been registered in
      -- previous loop looping through p_fte_rates_tab, so
      -- no need to register changed line again for these lines.

      DELETE FROM oe_price_adjustments
      WHERE price_adjustment_id = l_bulk_adj_rec.price_adjustment_id(i);

      l_adj_index :=  l_adj_index  + 1;

    END LOOP;

        oe_line_util.query_rows
        (p_line_id   => l_line_id
         ,x_line_tbl  => query_line_tbl );

        K := K + 1;

        oe_debug_pub.add('The config lines added '|| l_line_id);
        l_line_tbl(k) := query_line_tbl(1);

    l_index := l_index + 1;

   END LOOP;

 -- for ATO lines, only send config lines to Pricing.
 -- Commented for bug 7043225, as we want all the charges to get applied on ATO Model even before,
 -- config item is created. Hence we need to pass the CPF as 'Y' for all lines.
 -- Else the charges that got inserted on these items will never get displayed in the UI
 /* J := l_line_tbl.FIRST;
  WHILE J IS NOT NULL LOOP
    -- delete those non-shippable ATO parent lines
    IF l_line_tbl(J).ato_line_id IS NOT NULL
       AND l_line_tbl(J).item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
       l_line_tbl(J).calculate_price_flag := 'N';
       oe_debug_pub.add('ATO item price flag set to N :'||l_line_tbl(J).line_id);
    END IF;
    J := l_line_tbl.NEXT(J);
  END LOOP;*/

  For j in l_line_tbl.FIRST .. l_line_tbl.LAST LOOP
     oe_debug_pub.add( ' Lines passed to pricing Ids: value of l_line_tbl' || l_line_tbl(j).line_id);
  End loop;

    IF (Nvl(get_list_line_type_code(p_header_id),0) = 0 )  THEN

       Create_Dummy_Adjustment
	(p_header_id => p_header_id
	);

    END IF;

        l_control_rec.default_attributes   := TRUE;
        l_control_rec.controlled_operation := TRUE;
        l_control_rec.change_attributes    := TRUE;
        l_control_rec.validate_entity      := TRUE;
        l_control_rec.write_to_DB          := TRUE;
        l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;

	--l_line_tbl.operation := OE_GLOBALS.G_OPR_UPDATE;

   	OE_ORDER_PVT.Lines
	  ( p_validation_level    => FND_API.G_VALID_LEVEL_NONE
	   ,p_control_rec         => l_control_rec
	   ,p_x_line_tbl          => l_line_tbl
	   ,p_x_old_line_tbl      => l_old_line_tbl
	   ,x_return_status       => x_return_status);

	 IF l_debug_level > 0 THEN
          oe_debug_pub.Add('After Calling Process Order...'||x_return_status,3);
         END IF; -- bug7433107

	  -- Logging a delayed request for Price Line in BATCH mode.

	    l_pricing_event := 'BATCH';

              OE_delayed_requests_Pvt.log_request(
                   p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                   p_entity_id              => p_header_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                   p_requesting_entity_id   => p_header_id,
                   p_request_unique_key1    => l_pricing_event,
                   p_param1                 => p_header_id,
                   p_param2                 => l_pricing_event,
                   p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
                   x_return_status          => l_return_status);


         IF l_debug_level > 0 THEN -- bug7433107
         OE_DEBUG_PUB.Add('Before Calling Process Requests and Notify',3);
         END IF;

	  OE_ORDER_PVT.Process_Requests_And_notify
	  ( p_process_requests     => TRUE
	   ,p_notify               => TRUE
	   ,x_return_status        => x_return_status
	   ,p_line_tbl             => l_line_tbl
	   ,p_old_line_tbl         => l_old_line_tbl);

	  IF l_debug_level > 0 THEN
	     OE_DEBUG_PUB.Add('After Calling Process Requests and Notify...'|| x_return_status,3);
          END IF;

  Print_Time('Exiting OE_FREIGHT_CHOICES_PVT.Process_Freight_Choices...');

 EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     IF l_debug_level > 0 THEN
        oe_debug_pub.Add('Expected Error in Process Freight Choices', 1);
     END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF l_debug_level > 0 THEN
       oe_debug_pub.Add('Unexpected Error in Process Freight Choices'||
                    sqlerrm, 2);
     END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   /* IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Process_Freight_Choices');
    END IF; */

END Process_Freight_Choices;

PROCEDURE Cancel_all Is

NO_SAVEPOINT EXCEPTION;
PRAGMA EXCEPTION_INIT(NO_SAVEPOINT, -1086);

Begin
  oe_debug_pub.add('Entering Cancel all');
  Rollback to Savepoint Cancel_All;

  -- bug 5883660
  EXCEPTION WHEN NO_SAVEPOINT THEN
    Null;
End Cancel_all;

END OE_FREIGHT_CHOICES_PVT;

/
