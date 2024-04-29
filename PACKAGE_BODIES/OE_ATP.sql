--------------------------------------------------------
--  DDL for Package Body OE_ATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ATP" AS
/* $Header: OEXVATPB.pls 120.1 2005/12/15 02:27:37 pkannan noship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_ATP';


/*-----------------------------------------------------------------------------
Procedure Name : ATP_Check
Description    :
----------------------------------------------------------------------------- */

Procedure ATP_Check( p_line_atp_rec	   IN line_atp_rec_type
                    ,p_old_line_atp_rec    IN line_atp_rec_type
                    ,x_atp_rec             OUT NOCOPY /* file.sql.39 change */ atp_rec_type
                    ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                    )
IS
l_line_rec            OE_ORDER_PUB.line_rec_type;
l_old_line_rec        OE_ORDER_PUB.line_rec_type;
l_atp_tbl             OE_ATP.atp_tbl_type;
--- 2697690 --
l_scheduling_level_code   VARCHAR2(30) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_validity_flag        NUMBER :=  0;        -- for bug 2549166

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING ATP_CHECK' , 1 ) ;
      oe_debug_pub.add(  'BEFORE FIRST ASSIGN ATPREC' , 3 ) ;
      oe_debug_pub.add(  'NEW LINE TYPE : '||TO_CHAR ( P_LINE_ATP_REC.LINE_TYPE_ID ) , 3 ) ;
      oe_debug_pub.add(  'OLD LINE TYPE : '||TO_CHAR ( P_OLD_LINE_ATP_REC.LINE_TYPE_ID ) , 3 ) ;
  END IF;

  -- Check Min Attributes Required to do ATP

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R1' , 3 ) ;
  END IF;
  IF (p_line_atp_rec.inventory_item_id IS null) OR
     (p_line_atp_rec.inventory_item_id = FND_API.G_MISS_NUM)
  THEN
      null;
      goto end_atp_check;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R2' , 3 ) ;
  END IF;
  IF (p_line_atp_rec.ordered_quantity IS null) OR
     (p_line_atp_rec.ordered_quantity = FND_API.G_MISS_NUM) OR
     (p_line_atp_rec.ordered_quantity <= 0) OR
     (p_line_atp_rec.line_category_code =  'RETURN')
  THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDERED_QUANTITY IS NULL' , 3 ) ;
      END IF;
      goto end_atp_check;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R3' , 3 ) ;
  END IF;
  IF (p_line_atp_rec.order_quantity_uom IS null) OR
     (p_line_atp_rec.order_quantity_uom = FND_API.G_MISS_CHAR)
  THEN
      null;
      goto end_atp_check;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R4' , 3 ) ;
  END IF;
  IF (p_line_atp_rec.request_date IS null) OR
     (p_line_atp_rec.request_date = FND_API.G_MISS_DATE)
  THEN
      null;
      goto end_atp_check;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R5 ', 3 ) ;
  END IF;

  -- 3670442 : added check for External source and close order
  IF p_line_atp_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
  THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INVALID SOURCE TYPE '||p_line_atp_rec.source_type_code , 3 ) ;
     END IF;
     goto end_atp_check;
  END IF;

  IF (p_line_atp_rec.shipped_quantity is not null) AND
      (p_line_atp_rec.shipped_quantity <> FND_API.G_MISS_NUM) THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE IS SHIPPED' , 3 ) ;
    END IF;
    goto end_atp_check;
  END IF;

  IF NVL(p_line_atp_rec.open_flag,'Y') = 'N'
  THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IT IS A CLOSED LINE' , 3 ) ;
     END IF;
     goto end_atp_check;
  END IF;

  IF (p_line_atp_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD)
  THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NOT A STANDARD LINE' , 3 ) ;
     END IF;
     goto end_atp_check;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'R6' , 3 ) ;
  END IF;

--Added for Bug 2549166

  IF (p_line_atp_rec.ship_from_org_id IS null) OR
     (p_line_atp_rec.ship_from_org_id = FND_API.G_MISS_NUM)
  THEN
     null;
     goto end_atp_check;
  ELSE
    BEGIN
       SELECT 1
       INTO   l_validity_flag
       FROM   mtl_system_items_b msi,
              org_organization_definitions org
       WHERE  msi.inventory_item_id= p_line_atp_rec.inventory_item_id
       AND    org.organization_id=msi.organization_id
       AND    sysdate<=nvl(org.disable_date,sysdate)
       AND    org.organization_id=p_line_atp_rec.ship_from_org_id
       AND    rownum=1;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF l_debug_level > 0 THEN
           oe_debug_pub.add('INVALID ITEM WAREHOUSE COMBINATION',3);
         END IF;
         goto end_atp_check;
    END;
  END IF;
  IF l_debug_level > 0 THEN
      oe_debug_pub.add('R7',3);
  END IF;

--End of Modification for Bug 2549166

  --- Start 2697690 --
  l_scheduling_level_code :=
      NVL(Oe_Schedule_Util.Get_Scheduling_Level(p_line_atp_rec.header_id,
                                                p_line_atp_rec.line_type_id),OE_SCHEDULE_UTIL.SCH_LEVEL_THREE);
  --3763015
  IF l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FOUR OR
     l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FIVE OR
     NVL(fnd_profile.value('ONT_BYPASS_ATP'),'N') = 'Y' THEN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FOUR AND FIVE CANNOT HAVE ATP PERFORMED' , 3 ) ;
     END IF;

-- start 3431595
   IF p_line_atp_rec.p_pa_call then
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
       FND_MESSAGE.SET_TOKEN('ACTION',OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK);

       IF p_line_atp_rec.line_type_id is not null THEN
         FND_MESSAGE.SET_TOKEN('ORDER_TYPE',OE_SCHEDULE_UTIL.sch_cached_line_type);
       ELSE
         FND_MESSAGE.SET_TOKEN('ORDER_TYPE',OE_SCHEDULE_UTIL.sch_cached_order_type);
       END IF;

       OE_MSG_PUB.Add;
   END IF;

--end 3431595

     goto end_atp_check;

  END IF;
  --- End 2697690 --


  Assign_Atprec(p_line_atp_rec => p_old_line_atp_rec
               ,x_line_rec     => l_old_line_rec);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER FIRST ASSIGN ATPREC' , 3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE TYPE ON LINE : '||TO_CHAR ( L_OLD_LINE_REC.LINE_TYPE_ID ) , 3 ) ;
  END IF;

  Assign_Atprec(p_line_atp_rec => p_line_atp_rec
                ,x_line_rec    => l_line_rec);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE TYPE ON LINE NEW : '||TO_CHAR ( L_LINE_REC.LINE_TYPE_ID ) , 3 ) ;
  END IF;

  l_line_rec.item_type_code       :=    OE_GLOBALS.G_ITEM_STANDARD;
  l_line_rec.schedule_action_code := OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK;

  -- Bug4504362

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH:CALLING OE_SCHEDULE_UTIL.ATP_CHECK' , 2 ) ;
    END IF;

    OE_SCHEDULE_UTIL.atp_check(
                     p_old_line_rec  => l_old_line_rec,
                     p_validate      => FND_API.G_FALSE,
                     p_x_line_rec    => l_line_rec,
                     x_atp_tbl       => l_atp_tbl,
                     x_return_status => x_return_status);


  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PRINTING THE ATP RECORD' , 3 ) ;
  END IF;

  x_atp_rec := l_atp_tbl(1);

  <<end_atp_check>>
  null;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ATP_CHECK' || X_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'ATP_Check'
            );
        END IF;

END ATP_Check;

Procedure Assign_Atprec(p_line_atp_rec IN line_atp_rec_type
                        ,x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  x_line_rec.arrival_set_id         := p_line_atp_rec.arrival_set_id;
  x_line_rec.ato_line_id            := p_line_atp_rec.ato_line_id;
  x_line_rec.demand_class_code      := p_line_atp_rec.demand_class_code;
  x_line_rec.delivery_lead_time     := p_line_atp_rec.delivery_lead_time;
  x_line_rec.freight_carrier_code   := p_line_atp_rec.freight_carrier_code;
  x_line_rec.header_id              := p_line_atp_rec.header_id;
  x_line_rec.ordered_item           := p_line_atp_rec.item_input;
  x_line_rec.inventory_item_id      := p_line_atp_rec.inventory_item_id;
  x_line_rec.item_type_code         := p_line_atp_rec.item_type_code;
  x_line_rec.line_id                := p_line_atp_rec.line_id;
  x_line_rec.ordered_quantity       := p_line_atp_rec.ordered_quantity;
  x_line_rec.order_quantity_uom     := p_line_atp_rec.order_quantity_uom;
  x_line_rec.request_date           := p_line_atp_rec.request_date;
  x_line_rec.schedule_ship_date     := p_line_atp_rec.schedule_ship_date;
  x_line_rec.schedule_arrival_date  := p_line_atp_rec.schedule_arrival_date;
  x_line_rec.latest_acceptable_date := p_line_atp_rec.latest_acceptable_date;
  x_line_rec.ship_from_org_id       := p_line_atp_rec.ship_from_org_id;
  x_line_rec.ship_model_complete_flag := p_line_atp_rec.ship_model_complete_flag;
  x_line_rec.ship_set_id            := p_line_atp_rec.ship_set_id;
  x_line_rec.ship_to_org_id         := p_line_atp_rec.ship_to_org_id;
  x_line_rec.source_type_code       := p_line_atp_rec.source_type_code;
  x_line_rec.shipping_method_code   := p_line_atp_rec.shipping_method_code;
  x_line_rec.sold_to_org_id         := p_line_atp_rec.sold_to_org_id;
  x_line_rec.top_model_line_id      := p_line_atp_rec.top_model_line_id;
  x_line_rec.line_type_id           := p_line_atp_rec.line_type_id;

END Assign_Atprec;

/*-------------------------------------------------------------------
Procedure Name : ATP_Inquiry
Description    : This will be called when Manual ATP Inquiry on a
                 line(which has been saved).

------------------------------------------------------------------- */

Procedure ATP_Inquiry( p_entity_type   IN VARCHAR2
                     , p_entity_id     IN NUMBER
                     , x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                     , x_atp_tbl       OUT NOCOPY /* file.sql.39 change */ ATP_TBL_TYPE)
IS
l_line_atp_rec      OE_ORDER_PUB.line_rec_type;
l_out_atp_rec       OE_ATP.atp_rec_type;
l_out_atp_tbl       OE_ATP.atp_tbl_type;

l_return_status     VARCHAR2(1);
l_entity_type       VARCHAR2(30);
l_entity_id         NUMBER;
l_group_req_rec     OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING ATP_INQUIRY' , 1 ) ;
   END IF;
   l_entity_type := p_entity_type;
   l_entity_id   := p_entity_id;


   IF (p_entity_type <> OE_ORDER_SCH_UTIL.OESCH_ENTITY_O_LINE) THEN
      OE_GRP_SCH_UTIL.Group_Schedule
        (p_group_req_rec     => l_group_req_rec,
         x_atp_tbl           => l_out_atp_tbl,
         x_return_status     => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Perform ATP Inquiry for Standard Lines

--   l_line_atp_rec := OE_LINE_UTIL.Query_Row(l_entity_id);
   OE_Line_Util.Query_Row(p_line_id	=> l_entity_id,
					 x_line_rec	=> l_line_atp_rec);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALLING ATP_CHECK' , 2 ) ;
   END IF;

/*   ATP_Check(p_line_atp_rec	       => l_line_atp_rec
             ,p_old_line_atp_rec   => l_line_atp_rec
             ,x_atp_rec        => l_out_atp_rec
             ,x_return_status  => l_return_status
             );
*/

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_atp_tbl(1) := l_out_atp_rec;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ATP_INQUIRY' , 1 ) ;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_line'
            );
        END IF;

END ATP_Inquiry;

END OE_ATP;

/
