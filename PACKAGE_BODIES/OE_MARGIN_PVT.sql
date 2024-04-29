--------------------------------------------------------
--  DDL for Package Body OE_MARGIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MARGIN_PVT" AS
/* $Header: OEXVMRGB.pls 120.8.12010000.3 2008/11/03 22:56:07 rbadadar ship $ */

G_CUSTOM_COST        VARCHAR2(3);
G_SHIP_FROM_ORG_ID   NUMBER:=-1;
G_PROJECT_ID         NUMBER:=-1;
G_HEADER_ID          NUMBER:=-1;
G_MIN_MARGIN_PERCENT NUMBER:=-1;
G_COMPUTE_METHOD     VARCHAR2(5):=NULL;
G_SOB_CURRENCY       VARCHAR2(15):=NULL;
G_DEBUG              VARCHAR2(1):=NULL;

procedure debug
             (p_text  In Varchar2
             ,p_level In Number Default 5
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF G_DEBUG IS NULL THEN
     IF OE_DEBUG_PUB.G_DEBUG = FND_API.G_TRUE THEN
        G_DEBUG := 'Y';
     ELSE
        G_DEBUG := 'N';
     END IF;
  END IF;

  IF G_DEBUG =  'Y'  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  P_TEXT , NVL ( P_LEVEL , 5 ) ) ;
    END IF;
  END IF;
End;

procedure cost_action
                (
                 p_selected_records            Oe_Globals.Selected_Record_Tbl
                ,P_cost_level                  varchar2
)

is

l_request_rec      Oe_Order_Pub.Request_Rec_Type DEFAULT Oe_Order_Pub.G_MISS_REQUEST_REC;
l_line_id                       number;
l_header_id                     number;
l_unit_cost                     number;
j                               number;
l_Line_Tbl                      oe_order_pub.line_tbl_type;
l_header_flag                   boolean;
i                               number;
l_org_id                        Number;
l_prev_org_id                   Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   debug('Inside oe_margin_pvt_1.cost_action',1);
        If P_cost_level ='LINE' then
           debug('Inside cost level- line',1);

                --MOAC PI
                i := p_selected_records.first;
                while i is not null loop
                   l_line_id := p_selected_records(i).id1;
                   l_org_id := p_selected_records(i).org_id;
                   If l_prev_org_id is null or l_prev_org_id <> l_org_id Then
                      MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id  =>  l_Org_Id);
                      l_prev_org_id := l_org_id;
                   End If;
                   l_request_rec.entity_id := l_line_id ;
                   l_unit_cost := Oe_Margin_Pvt.Get_Cost(p_request_rec => l_request_rec);
                   i := p_selected_records.next(i);
                End loop;
                --MOAC PI

        Else
            debug('cost level header',1);
               --MOAC PI
               i := p_selected_records.first;
               while i is not null loop
                  l_Header_id := p_selected_records(i).id1;
                  l_org_id := p_selected_records(i).org_id;
                  If l_prev_org_id is null or l_prev_org_id <> l_org_id Then
                     MO_GLOBAL.set_policy_context(p_access_mode => 'S',  p_org_id  =>  l_Org_Id);
                     l_prev_org_id := l_org_id;
                  End If;
                  oe_Line_util.query_rows(p_header_id => l_Header_id, x_line_tbl => l_Line_Tbl);
		  j := l_Line_Tbl.First;
                  While j Is not null loop
                      l_request_rec.entity_id := l_Line_Tbl(j).line_id;
                      debug('l_request_rec.entity_id = '||l_request_rec.entity_id,1);
                      l_header_flag := TRUE;
                      l_unit_cost := Oe_Margin_Pvt.Get_Cost(p_request_rec => l_request_rec,p_line_rec => l_Line_Tbl(j), p_header_flag => l_header_flag);
                      j := l_Line_Tbl.Next(j);
                  End loop;
                  i := p_selected_records.next(i);
               End Loop;
               --MOAC PI
        End if;
End;

------------------------------------------------------------------
--Check_manual_released_holds
--This function is to check is a hold was being manually released.
------------------------------------------------------------------
Function CHECK_MANUAL_RELEASED_HOLDS (
 p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
 p_header_id         IN   NUMBER,
 p_line_id	     IN   NUMBER DEFAULT  NULL
                                  )
RETURN Varchar2
IS
 l_hold_release_id           number;
 l_dummy                     VARCHAR2(1);
 l_manual_hold_exists        varchar2(1) := 'N';
 l_released_rec_exists       varchar2(1) := 'Y';
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
 debug('Entering OE_MARGIN_PUB.Check_Manual_Released_Holds');
 Debug(' Checking for Manually Released Holds on header_id'||
                     to_char(p_header_id) );

    IF p_line_id IS NULL THEN
      BEGIN
        SELECT NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES s
       WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID IS NULL
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Debug('No Released record for Margin Holds');
          l_released_rec_exists := 'N';
        WHEN OTHERS THEN
          null;
      END;

    ELSE
      BEGIN
        SELECT NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES s
       WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID = p_line_id
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          Debug('No Released record for margin Holds');
          l_released_rec_exists := 'N';
        WHEN OTHERS THEN
          null;
      END;

    END IF;   -- end if p_line_id is null

    IF l_released_rec_exists = 'Y' THEN
       BEGIN
         select 'Y'
           into l_manual_hold_exists
           FROM OE_HOLD_RELEASES
          WHERE HOLD_RELEASE_ID = l_hold_release_id
            AND RELEASE_REASON_CODE <> 'PASS_MIN_MARGIN'
            AND CREATED_BY <> 1;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           Debug('No Manually Released Margin Holds');
           l_manual_hold_exists := 'N';
         WHEN OTHERS THEN
          null;
       END;
    END IF;

 Debug(' Manual Holds Exists:' || l_manual_hold_exists );
 debug('Leaving OE_MARGIN_PUB.Check_Manual_Released_Holds');
 return l_manual_hold_exists;

End CHECK_MANUAL_RELEASED_HOLDS;


----------------------------------------------------------------
FUNCTION Get_Cost (p_line_rec       IN  OE_ORDER_PUB.LINE_REC_TYPE   DEFAULT OE_Order_Pub.G_MISS_LINE_REC
                  ,p_request_rec    IN Oe_Order_Pub.Request_Rec_Type DEFAULT Oe_Order_Pub.G_MISS_REQUEST_REC
                  ,p_order_currency IN VARCHAR2 Default NULL
                  ,p_sob_currency   IN VARCHAR2 Default NULL
                  ,p_inventory_item_id    IN NUMBER Default NULL
                  ,p_ship_from_org_id     IN NUMBER Default NULL
                  ,p_conversion_Type_code IN VARCHAR2 Default NULL
                  ,p_conversion_rate      IN NUMBER   Default NULL
                  ,p_item_type_code       IN VARCHAR2 Default 'STANDARD'
                  ,p_header_flag          IN Boolean Default FALSE)
----------------------------------------------------------------
RETURN NUMBER IS
l_line_rec        OE_ORDER_PUB.LINE_REC_TYPE;
l_unit_cost       NUMBER;
l_cost_group_id   NUMBER;
l_item_rec        OE_ORDER_CACHE.item_rec_type;
l_set_of_books    Oe_Order_Cache.Set_Of_Books_Rec_Type;
l_order_currency  VARCHAR2(30);
l_set_of_books_id VARCHAR2(30);
l_sob_currency    VARCHAR2(30);
l_old_unit_cost   NUMBER;
l_control_rec     OE_GLOBALS.Control_Rec_Type;
l_line_tbl        Oe_Order_Pub.Line_Tbl_Type;
l_old_line_tbl    Oe_Order_Pub.Line_Tbl_Type;
l_return_status   VARCHAR2(30);
l_denominator     NUMBER;
l_numerator       NUMBER;
l_rate            NUMBER;
l_conversion_type_code VARCHAR2(30);
l_conversion_rate NUMBER;
l_PA_CALL Boolean := FALSE;
l_result_code   VARCHAR2(30);
l_no_of_rows    NUMBER;
l_cost_mthd     VARCHAR2(15);
l_cmpnTcls      NUMBER;
l_analysis_code VARCHAR2(15);
l_whse_code     VARCHAR2(15);
l_orgn_code     VARCHAR2(15);
l_inventory_org_id number;
l_uom_rate      NUMBER;
-- INVCONV
l_status                      VARCHAR2(1);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_ind    NUMBER;
l_result varchar2(30);

--INVCONV
/*Cursor OPM_CODE(p_organization_id Number) Is -- INVCONV
SELECT w.whse_code
     , s.orgn_code
FROM   mtl_parameters p
     , ic_whse_mst w
     , sy_orgn_mst s
     , gl_plcy_mst plcy
WHERE plcy.co_code            = s.co_code
AND   w.mtl_organization_id   = p.organization_id
AND   s.orgn_code             = w.orgn_code
AND   s.orgn_code             = p.process_orgn_code
AND   p.process_enabled_flag  ='Y'
AND   s.delete_mark           = 0
AND   w.delete_mark           = 0
AND   p.ORGANIZATION_ID       = p_organization_id
AND   rownum < 2; */

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
CURSOR drop_ship_line_cost IS
   SELECT POL.UNIT_PRICE
   FROM PO_LINES_ALL POL,
     OE_DROP_SHIP_SOURCES OEDSS
   WHERE OEDSS.LINE_ID = l_line_rec.line_id
   AND OEDSS.PO_RELEASE_ID IS NULL
   AND POL.PO_LINE_ID = OEDSS.PO_LINE_ID
   UNION
   SELECT PRL.UNIT_PRICE
   FROM PO_REQUISITION_LINES_ALL PRL,
     OE_DROP_SHIP_SOURCES OEDSS
   WHERE OEDSS.LINE_ID = l_line_rec.line_id
   AND OEDSS.PO_LINE_ID IS NULL
   AND PRL.REQUISITION_LINE_ID = OEDSS.REQUISITION_LINE_ID
   UNION
   SELECT POLL.PRICE_OVERRIDE UNIT_PRICE
   FROM PO_LINE_LOCATIONS_ALL POLL,
   OE_DROP_SHIP_SOURCES OEDSS
   WHERE OEDSS.LINE_ID = l_line_rec.line_id
   AND OEDSS.PO_LINE_ID IS NOT NULL
   AND POLL.LINE_LOCATION_ID = OEDSS.LINE_LOCATION_ID
   AND OEDSS.PO_RELEASE_ID IS NOT NULL;


BEGIN
 debug('Entering Oe_Margin_Pvt.get_cost');

 --Not yet decided. We might allow user to write their
 --own api to get a custom code...
 IF G_CUSTOM_COST IS NOT NULL THEN
   G_CUSTOM_COST:=Fnd_Profile.value('ONT_GET_CUSTOM_COST');
 END IF;

 IF G_COMPUTE_METHOD IS NULL THEN
  G_COMPUTE_METHOD:=Oe_Sys_Parameters.Value('COMPUTE_MARGIN');
 END IF;

 IF G_COMPUTE_METHOD = 'N' THEN
  debug(' Not computing cost, compute method is N');
  RETURN NULL;
 END IF;


 BEGIN
   IF p_request_rec.entity_id IS NOT NULL OR
      p_request_rec.entity_id <> FND_API.G_MISS_NUM
      AND p_header_flag = FALSE
   THEN
       debug('query line');
     -- bug 4642569 begin replace expensive query_row with direct select
     OE_ORDER_UTIL.Return_Glb_Ent_Index(OE_GLOBALS.G_ENTITY_LINE,
                                       p_request_rec.entity_id,
                                       l_ind,
                                       l_result,
                                       l_return_status);
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INDEX=' || L_IND , 1 ) ;
       oe_debug_pub.add(  'L_RETURN_STATUS =' || L_RETURN_STATUS , 1 ) ;
       oe_debug_pub.add(  'L_RESULT =' || L_RESULT , 1 ) ;
     END IF;

     IF l_result = FND_API.G_TRUE   then
       l_line_rec := OE_ORDER_UTIL.G_Line_Tbl(l_ind);
     ELSE
       l_line_rec := oe_line_util.query_row(p_request_rec.entity_id);
     END IF;
    -- bug 4642569 end
   ELSE
       debug('dont query');
       debug('passed in line_id:'||p_line_rec.line_id);
       l_line_rec := p_line_rec;
   END IF;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        debug('p_request_rec.entity_id =' || p_request_rec.entity_id);
        l_return_status := FND_API.G_RET_STS_ERROR;
 END;

 --RT{
 IF l_line_rec.retrobill_request_id IS NOT NULL
    and l_line_rec.retrobill_request_id <> FND_API.G_MISS_NUM THEN
   debug(' Not computing cost, retrobill line');
   RETURN NULL;
 END IF;
 --RT}

 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
   RETURN NULL;
 END IF;

 IF l_line_rec.line_id   IS NULL
    AND p_sob_currency      IS NOT NULL
    AND p_inventory_item_id IS NOT NULL
    AND p_order_currency    IS NOT NULL
    AND p_ship_from_org_id  IS NOT NULL
 THEN
   --PRICING and AVAILBLITY CALL, they do not have line record
   --Therefore they do not pass in p_line_record
   l_PA_CALL := TRUE;
   G_SHIP_FROM_ORG_ID := p_ship_from_org_id;

   --Bug 7347299 starts
   --G_SOB_CURRENCY := p_sob_currency;
   --getting set of book ID for this ship_from_org
   BEGIN
      SELECT SET_OF_BOOKS_ID
        INTO l_set_of_books_id
        FROM ORG_ORGANIZATION_DEFINITIONS
       WHERE ORGANIZATION_ID =  G_SHIP_FROM_ORG_ID;
   EXCEPTION
   WHEN OTHERS THEN
      debug(' Error:'||SQLERRM);
   END;

   --getting currency based on the set of book id
   BEGIN
      SELECT Currency_Code
        INTO G_SOB_CURRENCY
        FROM OE_GL_SETS_OF_BOOKS_V
       WHERE SET_OF_BOOKS_ID = l_set_of_books_id;
   EXCEPTION
   WHEN OTHERS THEN
      debug(' Error:'||SQLERRM);
   END;
   --Bug 7347299 ends

   debug(' PA call set to true');
 ELSIF l_line_rec.line_id IS NULL THEN
   debug(' Invalid get_cost call...Returning');
   RETURN NULL;
 END IF;


  l_old_unit_cost := l_line_rec.unit_cost;


 IF nvl(l_line_rec.inventory_item_id,p_inventory_item_id) IS NULL THEN
  debug(' Return null because inventory_item_id passed in is null');
  RETURN NULL;
 END IF;

 IF nvl(l_line_rec.item_type_code,p_item_type_code) IN ('KIT','MODEL','INCLUDED','CLASS','CONFIG','OPTION') THEN
  debug(' This item type is not supported:'||nvl(l_line_rec.item_type_code,p_item_type_code));
  RETURN NULL;
 END IF;

 IF NOT l_PA_CALL THEN
   IF l_line_rec.open_flag = 'N' OR l_line_rec.shipped_quantity = l_line_rec.ordered_quantity THEN
     debug(' Line is either closed or shipped, no new cost will be fetched');
     RETURN l_line_rec.unit_cost;
   END IF;
 END IF;

 --A drop shipment line, getting cost from
 --Try to get cost from drop ship views (PO).
 --If record no available that means PO has not been created, then we need to get cost from
 --mtl_system_items_kfv
 IF l_line_rec.source_type_code = 'EXTERNAL' THEN
  debug(' This is a drop ship line');

  /* begin bug 3181730: the following SQL consumes over 1MB memory
     replace with direct table join

  BEGIN
   SELECT unit_price
   INTO   l_unit_cost
   FROM   oe_drop_ship_links_v
   WHERE  line_id = l_line_rec.line_id;


  EXCEPTION

   WHEN NO_DATA_FOUND THEN
   end comment out for 3181730*/

   l_unit_cost := NULL;
   OPEN drop_ship_line_cost;
   FETCH drop_ship_line_cost INTO l_unit_cost;
   CLOSE drop_ship_line_cost;

   if l_unit_cost IS NULL then
     --PO has not been created yet. Getting the cost from mtl_systems_item_kfv
     debug('  PO has not been created yet. Getting the cost from mtl_system_item:item:'||l_line_rec.inventory_item_id||' Ship from org id:'||l_line_rec.ship_from_org_id);

   /* end bug 3181730 */
   BEGIN
     select inventory_organization_id into l_inventory_org_id from financials_system_parameters;  --bug 2733946

     SELECT list_price_per_unit
     INTO   l_unit_cost
     FROM   mtl_system_items_kfv
     WHERE  inventory_item_id = nvl(l_line_rec.inventory_item_id,p_inventory_item_id)
     AND    organization_id   = l_inventory_org_id; --nvl(l_line_rec.ship_from_org_id,p_ship_from_org_id);

   EXCEPTION
   WHEN OTHERS THEN
    debug(' Error in retrieving cost for drop ship lines:'||SQLERRM);
  END;
  END IF;
 END IF;

 debug(' Drop ship cost:'|| l_unit_cost);
 IF l_line_rec.source_type_code = 'INTERNAL'
    AND NOT l_PA_CALL
 THEN

IF nvl(G_SHIP_FROM_ORG_ID,-1) <> nvl(l_line_rec.ship_from_org_id,-1) OR
  -- IF G_SHIP_FROM_ORG_ID <> l_line_rec.ship_from_org_id OR bug 6709490/6518329
     NVL(G_PROJECT_ID,-1) <> NVL(l_line_rec.project_id,-1) THEN

    --cache the value, if it is the same we don't want to hit the db again
    G_SHIP_FROM_ORG_ID := l_line_rec.ship_from_org_id;
    G_SOB_CURRENCY := NULL; -- bug 6709490/6518329
    debug(' Line org is different');

    IF l_line_rec.project_id IS NULL THEN

      G_PROJECT_ID := NULL;
      SELECT NVL(default_cost_group_id,-1)
      INTO   l_cost_group_id
      FROM   mtl_parameters
      WHERE  organization_id = G_SHIP_FROM_ORG_ID;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' COST GROUP ID FOR NONE PROJECT ITEM:'||L_COST_GROUP_ID ) ;
      END IF;

    ELSE

      G_PROJECT_ID := l_line_rec.project_id;
      SELECT NVL(costing_group_id,-1)
      INTO   l_cost_group_id
      FROM   pjm_project_parameters ppp
      WHERE  ppp.project_id = l_line_rec.project_id
      AND    ppp.organization_id = G_SHIP_FROM_ORG_ID;

    END IF;

  END IF;

-- INVCONV
  If l_item_rec.primary_uom_code is null or l_item_rec.primary_uom_code = fnd_api.g_miss_char then
       l_item_rec := OE_Order_Cache.Load_Item(l_line_rec.inventory_item_id,
                                              G_SHIP_FROM_ORG_ID);
  End if;

-- IF Process org call OPM API to get cost
  IF l_item_rec.process_warehouse_flag = 'Y' then

    l_result_code:=GMF_CMCOMMON.Get_Process_Item_Cost
		 		 (p_api_version        =>1
				, p_init_msg_list      => FND_API.G_FALSE
				, x_return_status      => l_return_status
				, x_msg_count          =>  l_msg_count
				, x_msg_data           =>  l_msg_count
				, p_inventory_item_id  =>l_line_rec.inventory_item_id
				, p_organization_id    =>G_SHIP_FROM_ORG_ID  /*Inventory Organization Id */
				, p_transaction_date   =>nvl(l_line_rec.actual_shipment_date,nvl(l_line_rec.fulfillment_date,sysdate)) /* Cost as on date */
				, p_detail_flag        =>1 /* same as retrieve indicator: */
                                      /*  1 = total cost, 2 = details; */
                                      /* 3 = cost for a specific component
																			class/analysis code, etc. */
				, p_cost_method        =>l_cost_mthd    /* OPM Cost Method */
				, p_cost_component_class_id =>l_cmpntcls
				, p_cost_analysis_code => l_analysis_code
				, x_total_cost         =>l_unit_cost  /* total cost */
				, x_no_of_rows         => l_no_of_rows    /* number of detail rows retrieved */
         );

-- INVCONV

   debug(' Result code from process  get_cost api:'||l_result_code);
   debug(' Unit cost for Process org item before convert:'||l_unit_cost);
   debug('primary_uom_code : '||l_item_rec.primary_uom_code);
   debug('Order_quantity_uom : '||l_Line_rec.Order_quantity_uom);
   debug('Inventory_item_id : '||l_Line_rec.Inventory_item_id);
   If l_item_rec.primary_uom_code <> l_Line_rec.Order_quantity_uom
      and l_unit_cost is not null and l_unit_cost <> fnd_api.g_miss_num Then
      INV_CONVERT.INV_UM_CONVERSION(From_Unit => l_Line_rec.Order_quantity_uom
                                       ,To_Unit   => l_item_rec.primary_uom_code
                                       ,Item_ID   => l_Line_rec.Inventory_item_id
                                       ,Uom_Rate  => l_Uom_rate);
      debug('l_Uom_rate : '||l_Uom_rate);
      l_unit_cost := l_unit_cost * l_Uom_rate;
      debug(' Unit cost for Process org item after convert:'||l_unit_cost);
   End If;

  ELSE -- Regular item call costing api to get cost
    l_unit_cost:=cst_cost_api.get_item_cost
                 (p_api_version=>1
                 ,p_inventory_item_id=>l_line_rec.inventory_item_id
                 ,p_organization_id=>G_SHIP_FROM_ORG_ID
                 ,p_cost_group_id=>l_cost_group_id
                 ,p_cost_type_id=>null);

    debug(' unit cost before convert:'||l_unit_cost);
    debug('primary_uom_code : '||l_item_rec.primary_uom_code);
    If l_item_rec.primary_uom_code is null or l_item_rec.primary_uom_code = fnd_api.g_miss_char then
       l_item_rec := OE_Order_Cache.Load_Item(l_line_rec.inventory_item_id,
                                              G_SHIP_FROM_ORG_ID);
    End If;
    debug('Order_quantity_uom : '||l_Line_rec.Order_quantity_uom);
    debug('Inventory_item_id : '||l_Line_rec.Inventory_item_id);
    If l_item_rec.primary_uom_code <> l_Line_rec.Order_quantity_uom
       and l_unit_cost is not null and l_unit_cost <> fnd_api.g_miss_num Then
       INV_CONVERT.INV_UM_CONVERSION(From_Unit => l_Line_rec.Order_quantity_uom
                                        ,To_Unit   => l_item_rec.primary_uom_code
                                        ,Item_ID   => l_Line_rec.Inventory_item_id
                                        ,Uom_Rate  => l_Uom_rate);
       debug('l_Uom_rate : '||l_Uom_rate);
       l_unit_cost := l_unit_cost * l_Uom_rate;
       debug(' Unit cost for OPM item after convert:'||l_unit_cost);
    End If;
  END IF;  -- IF l_item_rec.process_warehouse_flag = 'Y' then

 END IF;


 debug(' Line ship_from_org_id:'||l_line_rec.ship_from_org_id);
 debug(' Order ship_from_org_id:'||OE_ORDER_CACHE.g_header_rec.ship_from_org_id);

 --Pricing and Availbility call
 IF l_PA_CALL THEN
  SELECT NVL(default_cost_group_id,-1)
  INTO   l_cost_group_id
  FROM   mtl_parameters
  WHERE  organization_id = G_SHIP_FROM_ORG_ID;

  debug(' cost group id for none project item:'||l_cost_group_id);

  l_unit_cost:=cst_cost_api.get_item_cost
                 (p_api_version=>1
                 ,p_inventory_item_id=>p_inventory_item_id
                 ,p_organization_id=>G_SHIP_FROM_ORG_ID
                 ,p_cost_group_id=>l_cost_group_id
                 ,p_cost_type_id=>null);
 END IF;

IF G_SOB_CURRENCY IS NULL THEN
 --Global sob currency is not set, execute following to set it

  debug(' getting set of book ID for this ship_from_org');
  --getting set of book ID for this ship_from_org
  BEGIN
   SELECT SET_OF_BOOKS_ID
   INTO   l_set_of_books_id
   FROM   ORG_ORGANIZATION_DEFINITIONS
   -- WHERE  ORGANIZATION_ID =  nvl(OE_ORDER_CACHE.g_header_rec.ship_from_org_id,G_SHIP_FROM_ORG_ID);
      -- bug 6518329/6709490
   WHERE  ORGANIZATION_ID =  nvl(G_SHIP_FROM_ORG_ID,OE_ORDER_CACHE.g_header_rec.ship_from_org_id);

  EXCEPTION
  WHEN OTHERS THEN
   --need to handle... to be added....
   debug(' Error:'||SQLERRM);
  END;

 debug(' getting currency based on the set of book id for the line');
 --getting currency based on the set of book id for the line
  BEGIN
   SELECT Currency_Code
   INTO   G_SOB_CURRENCY
   FROM   OE_GL_SETS_OF_BOOKS_V
   WHERE  SET_OF_BOOKS_ID = l_set_of_books_id;
  EXCEPTION
  WHEN OTHERS THEN
   --need to handle... to be added....
   debug(' Error:'||SQLERRM);
  END;
END IF;

  IF l_PA_CALL THEN
    l_order_currency := p_order_currency;
  ELSE
    IF OE_ORDER_CACHE.g_header_rec.header_id IS NULL OR
       OE_ORDER_CACHE.g_header_rec.header_id <> l_line_rec.header_id
    THEN
       OE_Header_Util.query_row(p_header_id => l_line_rec.header_id
                               , x_header_rec => OE_ORDER_CACHE.g_header_rec);
    END IF;
    l_order_currency := OE_ORDER_CACHE.g_header_rec.transactional_curr_code;
  END IF;

  DEBUG(' Order currency:'||l_order_currency);
  DEBUG(' Cost''s sob currency:'||g_sob_currency);

  --Currency different, that is cost from costing api is using different currency
  --than our order currency, cost will need to be converted to order currency
  IF l_order_currency <> G_SOB_CURRENCY THEN
    BEGIN

     IF NOT l_PA_CALL THEN
       IF OE_ORDER_CACHE.g_header_rec.conversion_type_code = 'User'
        AND OE_ORDER_CACHE.g_header_rec.conversion_rate IS NULL
       THEN
         DEBUG(' USER conversion type without rate, unable to perform cost conversion');
         RETURN NULL;
       END IF;

       IF OE_ORDER_CACHE.g_header_rec.conversion_type_code IS NULL THEN
         DEBUG(' Conversion type not entered in sales order header,unable to perfor cost conversion');
         RETURN NULL;
       END IF;

     ELSE
       IF p_conversion_type_code = 'User' AND p_conversion_rate IS NULL THEN
         DEBUG(' USER conversion type without rate, unable to perform cost conversion');
         RETURN NULL;
       END IF;

       IF p_conversion_type_code IS NULL THEN
         DEBUG(' Conversion type not entered, unable to perform cost conversion');
         RETURN NULL;
       END IF;

     END IF;

     IF NOT l_PA_CALL THEN
       l_conversion_type_code :=  OE_ORDER_CACHE.g_header_rec.conversion_type_code;
       l_conversion_rate      :=  OE_ORDER_CACHE.g_header_rec.conversion_rate;
     ELSE
       l_conversion_type_code :=  p_conversion_type_code;
       l_conversion_rate      :=  p_conversion_rate;
     END IF;

     --bug 4695325
     -- the conversion rate would always be stored in the system in Foreign to Base format irrespective of the profile option DISPLAY_INVERSE_RATE
     IF l_conversion_rate IS NOT NULL THEN
        l_conversion_rate := 1/l_conversion_rate;
     END IF;

      gl_currency_api.convert_closest_amount
      (  x_from_currency    =>  g_sob_currency
      ,  x_to_currency      =>  l_order_currency
      ,  x_conversion_date  =>  sysdate
      ,  x_conversion_type  =>  l_conversion_type_code
      ,  x_amount           =>  l_unit_cost
      ,  x_user_rate        =>  l_conversion_rate
      ,  x_max_roll_days    =>  -1
      ,  x_converted_amount =>  l_unit_cost
      ,  x_denominator      =>  l_denominator
      ,  x_numerator        =>  l_numerator
      ,  x_rate             =>  l_rate
      );

     DEBUG(' Converted unit cost:'||l_unit_cost||' rate:'||l_rate);
    EXCEPTION
     --will need to handle this later...
      WHEN OTHERS THEN
       debug('Gl_Currency_Api.Convert_Amount returns errors:'||SQLERRM);
       RETURN NULL;
    END;
  END IF;



 IF p_request_rec.entity_id IS NOT NULL
 OR p_request_rec.entity_id <> FND_API.G_MISS_NUM THEN
      debug('l_old_unit_cost = '||l_old_unit_cost);
     IF nvl(l_old_unit_cost,-999.3134) <> l_unit_cost THEN
         l_control_rec.controlled_operation := FALSE;
         l_control_rec.write_to_db := TRUE;
         l_control_rec.change_attributes := TRUE;
         l_control_rec.default_attributes := FALSE;
         l_control_rec.validate_entity := FALSE;
         l_control_rec.clear_dependents := FALSE;

         l_old_line_tbl(1) := l_line_rec;
         l_line_tbl(1) := l_line_rec;
         l_line_tbl(1).unit_cost := l_unit_cost;
         l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

          debug('before calling OE_ORDER_PVT.Lines jitesh');
         OE_ORDER_PVT.Lines(p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                            p_control_rec => l_control_rec,
                            p_x_line_tbl => l_line_tbl,
                            p_x_old_line_tbl => l_old_line_tbl,
                             x_return_status => l_return_status);
     END IF;
 END IF;
        debug('after calling OE_ORDER_PVT.Lines jitesh');

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
    debug('just before return oe_margin_pvt.get_cost');
    debug('l_unit_cost ='||l_unit_cost);

 RETURN l_unit_cost;

 debug('Leaving Oe_Margin_Pvt.get_cost');

EXCEPTION
WHEN OTHERS THEN
  DEBUG(' OE_MARGIN_PVT:Unable to get cost:'||SQLERRM);
  Return null;
END GET_COST;

--------------------------------------------------
Function Min_Margin_Percent
--Return Minimum Margin Percent from setup
--------------------------------------------------
(p_header_id IN NUMBER) RETURN NUMBER IS
l_transaction_type_id NUMBER;
l_min_margin_percent  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 debug('Entering function min_margin_percent');
 debug(' p_header_id:'||p_header_id);
 debug(' global header_id:'||G_HEADER_ID);

 IF OE_GLOBALS.Equal(p_header_id,G_HEADER_ID) THEN
   debug('Leaving function min_margin_percent');
   RETURN G_MIN_MARGIN_PERCENT;
 ELSE
   SELECT a.min_margin_percent
   INTO   l_min_margin_percent
   FROM   OE_TRANSACTION_TYPES_ALL a,
          OE_ORDER_HEADERS_ALL     b
   WHERE  a.transaction_type_id = b.order_type_id
   AND    b.header_id = p_header_id;
   G_HEADER_ID := p_header_id;
   G_MIN_MARGIN_PERCENT := l_min_margin_percent;
 END IF;

 debug('Leaving function min_margin_percent');
Return l_min_margin_percent;

EXCEPTION
WHEN OTHERS THEN
 debug('Error in function get_min_margin_percent:'||SQLERRM);
 Return -1;
END;

--------------------------------------------------
PROCEDURE Get_Order_Margin
-------------------------------------------------
(p_header_id              IN  NUMBER,
p_org_id IN NUMBER default NULL,
x_order_margin_percent OUT NOCOPY NUMBER ,

x_order_margin_amount OUT NOCOPY NUMBER) IS

 l_compute_method VARCHAR2(1);
 l_margin_ratio         NUMBER;
 l_margin_amount        NUMBER;

 -- {bug 5654745
 l_total_selling_price  Number :=0;
 l_total_cost		Number :=0;
 l_unit_SP		Number;
 l_unit_cost		Number;
 l_ordered_qty		Number;

CURSOR MARGIN is
SELECT ordered_quantity, unit_selling_price, unit_cost
  FROM  OE_ORDER_LINES_ALL
  WHERE header_id = p_header_id
  AND   unit_cost IS NOT NULL
  AND   line_category_code = 'ORDER';
--bug 5654745}
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
 debug('Entering Oe_Margin_Pvt.Get_Order_Margin');
 --retrive margin calculation method perference
 l_compute_method:=Oe_Sys_Parameters.Value('COMPUTE_MARGIN', p_org_id);

 debug(' Margin_Compute_Method:'||l_compute_method);

 IF l_compute_method = 'N'  THEN
   x_order_margin_percent := NULL;
   x_order_margin_amount  := NULL;
   debug(' Margin not computed system parameter says N');
   RETURN;
 End IF;

 --check order type minimum_margin is null... pending

 --check if this is a booked order....pending, maybe need to move somewhere
 -- {bug 5654745
open margin;
loop
	fetch margin into l_ordered_qty,l_unit_SP,l_unit_cost;
	exit when margin%NOTFOUND;
	l_total_selling_price := l_total_selling_price + (l_ordered_qty * l_unit_SP);
	l_total_cost := l_total_cost + (l_ordered_qty * l_unit_cost);
end loop;
close margin;
l_margin_amount := l_total_selling_price-l_total_cost;
-- bug 5654745}

 IF l_compute_method = 'P' THEN
  debug(' Margin based on price');
  --Margin percent based on price

  -- 3756821 commented the usp > 0
 /* SELECT SUM(ordered_quantity*(unit_selling_price - unit_cost))/sum(ordered_quantity*unit_selling_price),
         SUM(ordered_quantity*(unit_selling_price - unit_cost))
  INTO  l_margin_ratio,
        l_margin_amount
  FROM  OE_ORDER_LINES_ALL
  WHERE header_id = p_header_id
  AND   unit_cost IS NOT NULL
  -- AND   unit_selling_price > 0
  AND   line_category_code = 'ORDER';  */
    l_margin_ratio := l_margin_amount/l_total_selling_price;		--bug 5654745

  x_order_margin_amount :=l_margin_amount;
  -- 3756821
  IF l_margin_amount < 0 THEN
    --order level margin amount less than 0, making a lost, percent should be negative also
    x_order_margin_percent := -1 * ABS(l_margin_ratio * 100);
  ELSE
    x_order_margin_percent := l_margin_ratio * 100;
  END IF;
  -- 3756821
  debug('Leaving Oe_Margin_Pvt.Get_Order_Margin');
  RETURN;

 END IF;

 IF l_compute_method = 'C' THEN
  debug(' Margin based on cost');
  --Margin percent based on cost

 /* SELECT SUM(ordered_quantity*(unit_selling_price - unit_cost))/sum(ordered_quantity*unit_cost),
         SUM(ordered_quantity*(unit_selling_price- unit_cost))
  INTO  l_margin_ratio,
        l_margin_amount
  FROM  OE_ORDER_LINES_ALL
  WHERE header_id = p_header_id
  AND   unit_cost IS NOT NULL
  AND   line_category_code = 'ORDER';  */
   l_margin_ratio := l_margin_amount/l_total_cost;	--bug 5654745

  x_order_margin_amount := l_margin_amount;
  -- 3756821
  IF l_margin_amount < 0 THEN
    --order level margin amount less than 0, making a lost, percent should be negative also
    x_order_margin_percent := -1 * ABS(l_margin_ratio * 100);
  ELSE
    x_order_margin_percent := l_margin_ratio * 100;
  END IF;
  -- 3756821
 END IF;

 debug('Leaving Oe_Margin_Pvt.Get_Order_Margin');

EXCEPTION
WHEN ZERO_DIVIDE THEN
 IF l_compute_method = 'P' THEN
  debug(' Oe_Margin_Pvt.Get_Order_Margin ZERO price');

  --Good problem to have, user has infinite margin, for sure it should
  --pass order margin hold check.
  --When null, caller will not continue margin hold/check process

  x_order_margin_amount := null;
  x_order_margin_percent:= null;

 ElSIF l_compute_method = 'C' THEN

  debug(' Oe_Margin_Pvt.Get_Order_Margin ZERO cost:');
  --Good problem to have, user has infinite margin, for sure should
  --pass order margin hold check
  --When null, caller will not continue margin hold/check process

  x_order_margin_amount := null;
  x_order_margin_percent:= null;

 ELSE

  debug(' Oe_Margin_Pvt.Get_Order_Margin:'||SQLERRM);

 END IF;

WHEN OTHERS THEN
 debug(' Oe_Margin_Pvt.Get_Order_Margin unable get margin:'||SQLERRM);
End;

----------------------------------------------
PROCEDURE Margin_Hold
--evaluate margin, hold the order if necessary
----------------------------------------------
(p_header_id IN NUMBER) IS
l_order_margin_percent NUMBER;
l_min_margin_percent   NUMBER;
l_hold_source_rec  OE_Holds_Pvt.hold_source_rec_type;
l_hold_release_rec OE_Holds_Pvt.Hold_Release_REC_Type;
l_return_status			varchar2(30);
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
l_x_result_out                  Varchar2(30);
l_line_id NUMBER;
l_order_margin_amount           number;
l_manual_released Varchar2(1):= 'N';
l_booked_flag Varchar2(1):='N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 debug('Entering Oe_Margin_Pvt.Margin_Hold');

 Get_Order_Margin(p_header_id=>p_header_id,
                  x_order_margin_percent=>l_order_margin_percent,
                  x_order_margin_amount =>l_order_margin_amount);

 IF l_order_margin_percent IS NULL THEN
  --Margin not computed, user has set 'N' on compute_method or divide by zero margin
  debug(' Order margin percent is Null or compute method is N');
  RETURN;
 END IF;

 l_min_margin_percent:=Min_Margin_Percent(p_header_id);

 IF l_min_margin_percent IS NULL THEN
  --Margin percent is not set or other errors occurs
  debug(' Margin percent is not set or other errors occurs');
  RETURN;
 END IF;

 l_hold_source_rec.hold_id := G_SEEDED_MARGIN_HOLD_ID;
 l_hold_source_rec.hold_entity_id := p_header_id;
 l_hold_source_rec.header_id := p_header_id;
 l_hold_source_rec.Hold_Entity_code := 'O';

  -- check if order already on margin hold, place hold if not
     OE_Holds_Pub.Check_Holds(
	p_api_version		=> 1.0
       ,p_header_id             => p_header_id
       ,p_line_id		=> null
       ,p_hold_id		=> l_hold_source_rec.Hold_id
       ,x_return_status	        => l_return_status
       ,x_msg_count		=> l_x_msg_count
       ,x_msg_data		=> l_x_msg_data
       ,x_result_out		=> l_x_result_out
	);


 IF (l_return_status <> FND_API.g_ret_sts_success) THEN
    Debug(' OE_HOLD_PUB.Check_Holds returns unexpected error!');
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 debug(' order_margin_%:'||l_order_margin_percent);
 debug(' min_margin_% in setup:'||l_min_margin_percent);

 IF l_order_margin_percent < l_min_margin_percent THEN
    IF l_x_result_out = FND_API.G_FALSE THEN

       --check if this hold had been manually released
       --if manually release, do not apply hold again
        l_manual_released:=CHECK_MANUAL_RELEASED_HOLDS
                                   (p_hold_id=>G_SEEDED_MARGIN_HOLD_ID,
                                    p_header_id=>p_header_id);

        IF l_manual_released = 'N' THEN
          OE_HOLDS_PUB.Apply_Holds(
	  p_api_version		=> 1.0
	  ,p_hold_source_rec	=> l_hold_source_rec
	  ,x_return_status	=> l_return_status
	  ,x_msg_count		=> l_x_msg_count
	  ,x_msg_data		=> l_x_msg_data
	  );

	  IF l_return_status = FND_API.g_ret_sts_success then
                FND_MESSAGE.SET_NAME('ONT', 'ONT_MARGIN_HOLD_APPLIED');
		OE_MSG_PUB.Add;
	  ELSE
                debug('error applying hold',3);
		RAISE FND_API.G_EXC_ERROR;
	  END IF;
        END IF;

    END IF; --Hold applied check
 ELSE
    --need to release hold if hold applied
    IF l_x_result_out = FND_API.G_TRUE THEN
     l_hold_release_rec.release_reason_code :='PASS_MIN_MARGIN';
     OE_Holds_Pub.Release_Holds(
	p_api_version	   => 1.0
       ,p_hold_source_rec  => l_hold_source_rec
       ,p_hold_release_rec => l_hold_release_rec
       ,x_return_status	   => l_return_status
       ,x_msg_count	   => l_x_msg_count
       ,x_msg_data	   => l_x_msg_data
	);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            debug('Unexpected Error while releasing Margin Hold:'||SQLERRM);
             --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             debug('Error while releasing Margin Hold');
             --RAISE FND_API.G_EXC_ERROR;
     END IF;

    END IF;
 END IF;


 debug('Leaving Oe_Margin_Pvt.Margin_Hold');
END;

--------------------------------------------------------------------
--Margin should only avail for pack I
--This is wrapper to a call to OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL
--------------------------------------------------------------------
Function Is_Margin_Avail return Boolean Is
l_release_level Varchar2(15);
l_correct_release Boolean;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 l_release_level:=Oe_Code_Control.Get_Code_Release_Level;

 If l_release_level = 110509 THEN
  l_correct_release:=True;
 ELSE
  l_correct_release:=False;
 END IF;

 --Always return true first for initial testing purpose. Will turn on
 --above logic when checking in the code!
 Return True;
END;

Procedure Get_Line_Margin(p_line_rec In OE_ORDER_PUB.LINE_REC_TYPE,
                          x_unit_cost Out NOCOPY Number,
                          x_unit_margin_amount Out NOCOPY Number,
                          x_margin_percent Out NOCOPY Number) As
l_cost Number;
l_margin_amt Number;
l_margin_percent Number;
Begin
 l_cost:=Get_Cost(p_line_rec=>p_line_rec);
 x_unit_cost:=l_cost;
 If p_line_rec.unit_selling_price is Null Then
   oe_debug_pub.add('Warning:- unit selling price is null,margin not relevant');
   oe_debug_pub.add('Exiting oe_margin_pvt.get_line_margin');
   Return;
 End If;
 l_margin_amt := nvl(p_line_rec.unit_selling_price,0) - nvl(l_cost,0); --bug 5155086
 x_unit_margin_amount:=l_margin_amt;

 IF G_COMPUTE_METHOD = 'P' THEN
   If p_line_rec.unit_selling_price = 0 Then
     oe_debug_pub.add('Warning: Price based margin calculation is invalid,because 0 selling price, divided by zero error would occur. Returning');
     x_margin_percent:=NULL;
     Return;
   End If;

   l_margin_percent := l_margin_amt/p_line_rec.unit_selling_price*100;
   x_margin_percent := l_margin_percent;
 Elsif G_COMPUTE_METHOD = 'C' THEN
--   If p_line_rec.unit_selling_price = 0 Then bug5939162
     If nvl(l_cost,0) = 0 Then
     oe_debug_pub.add('Warning: Cost based margin calculation is invalid,because 0 cost, divided by zero error would occur. Returning');
     x_margin_percent:=NULL;
     Return;
   End If;

   x_margin_percent :=  l_margin_amt/l_cost*100; --added * 100 for bug5155086;
 End If;
End;

End OE_MARGIN_PVT;

/
