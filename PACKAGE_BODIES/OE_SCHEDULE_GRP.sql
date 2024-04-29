--------------------------------------------------------
--  DDL for Package Body OE_SCHEDULE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SCHEDULE_GRP" AS
/* $Header: OEXGSCHB.pls 120.7.12010000.7 2009/12/17 06:42:09 rmoharan ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_SCHEDULE_GRP';
G_SCH_TBL          sch_tbl_type;
G_LINE_TBL         OE_Order_PUB.Line_Tbl_Type;
G_OLD_LINE_TBL     OE_Order_PUB.Line_Tbl_Type;
G_BINARY_LIMIT     CONSTANT      NUMBER  := OE_GLOBALS.G_BINARY_LIMIT; -- 9187335

/** Fwd declaration ********/
PROCEDURE Process_order(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2);
PROCEDURE Validate_sch_data(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2);
PROCEDURE Validate_Lines(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2);
PROCEDURE Validate_set(p_ship_set_id       IN NUMBER DEFAULT NULL,
                       p_arrival_set_id    IN NUMBER DEFAULT NULL,
                       p_top_model_line_id IN NUMBER DEFAULT NULL);

FUNCTION  Find_line(p_line_id  IN NUMBER)
RETURN BOOLEAN;
FUNCTION  Find_index(p_line_id  IN NUMBER)
RETURN NUMBER;
Procedure Update_reservation(p_index IN NUMBER,
                             x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
Procedure Update_Scheduling_Results
(p_x_sch_tbl     IN OUT NOCOPY sch_tbl_type,
 p_request_id    IN  Number,
 x_return_status OUT NOCOPY Varchar2)
IS
 l_old_org_id    Number := -99;
 l_old_header_id Number;
 l_count         Number;
 l_return_status Varchar2(1);
 l_msg_count     NUMBER;
 l_msg_data      VARCHAR2(2000);
 l_orig_user_id  NUMBER;
 l_orig_resp_id  NUMBER;
 l_orig_resp_appl_id NUMBER;
 J NUMBER;
 --9187335 Start
 TYPE set_line_rec_type IS RECORD
      (line_id  NUMBER
      ,set_id   NUMBER);

 TYPE OE_set_line_tbl_type IS TABLE OF
     set_line_rec_type INDEX by BINARY_INTEGER;
 l_set_line_tbl OE_set_line_tbl_type;

 TYPE set_rec_type IS RECORD
    (set_id   NUMBER);

 TYPE OE_sets_tbl_type IS TABLE OF
     set_rec_type INDEX by BINARY_INTEGER;
 l_sets_tbl OE_sets_tbl_type;

 l_ship_set_id NUMBER;
 l_arrival_set_id NUMBER;
 l_non_plan_line_rec sch_rec_type ;
 l_add_count NUMBER :=1;

 CURSOR ship_set(p_ship_set number) IS
 SELECT ol.line_id,
        ol.inventory_item_id,
        ol.ordered_quantity
 FROM oe_order_lines_all ol
 WHERE ship_set_id=p_ship_set;


 CURSOR arrival_set(p_arrival_set number) IS
 SELECT ol.line_id ,
        ol.inventory_item_id,
        ol.ordered_quantity
 FROM oe_order_lines_all  ol
 WHERE arrival_set_id=p_arrival_set;
 --9187335 End
BEGIN

  oe_debug_pub.add('Entering oe_schedule_grp.update_scheduling_results' || p_x_sch_tbl.count ,1);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL > '110509' THEN
  l_count := p_x_sch_tbl.count;
  --9187335 Start
  -- Populate l_set_line_tbl
  FOR I IN 1..p_x_sch_tbl.count LOOP
      l_set_line_tbl(MOD(p_x_sch_tbl(I).line_id,G_BINARY_LIMIT)).line_id := p_x_sch_tbl(I).line_id;
  END LOOP;
  --9187335 End
  FOR I IN 1..p_x_sch_tbl.count LOOP

    IF l_old_org_id <> p_x_sch_tbl(I).org_id THEN
       l_old_org_id := p_x_sch_tbl(I).org_id;

       oe_debug_pub.add('Set the Org ',1);
--       dbms_application_info.set_client_info(p_x_sch_tbl(I).org_id);

        OE_Order_Context_Grp.Set_Created_By_Context
        (p_header_id           => p_x_sch_tbl(I).header_id
        ,p_line_id             => p_x_sch_tbl(I).line_id
        ,x_orig_user_id        => l_orig_user_id
        ,x_orig_resp_id        => l_orig_resp_id
        ,x_orig_resp_appl_id   => l_orig_resp_appl_id
        ,x_return_status       => l_return_status
        ,x_msg_count           => l_msg_count
        ,x_msg_data            => l_msg_data);

    END IF;
    --9187335 Start
    --g_sch_tbl(I) := p_x_sch_tbl(I);
    l_add_count:=g_sch_tbl.count+1;
    g_sch_tbl(l_add_count) :=p_x_sch_tbl(I);
    --g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_sch_tbl(l_add_count).x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
       SELECT ship_set_id, arrival_set_id
       INTO l_ship_set_id, l_arrival_set_id
       FROM oe_order_lines_all
       WHERE line_id=p_x_sch_tbl(I).line_id;

       oe_debug_pub.add('Ship Set '||l_ship_set_id||' Arrival Set '||l_arrival_set_id,1);
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          null;
          oe_debug_pub.add('NO_DATA_FOUND',1);
       WHEN OTHERS THEN
          null;
          oe_debug_pub.add('Error'||sqlerrm,1);
    END ;

    IF l_ship_set_id IS NOT NULL THEN
      -- Add the set to the table
      IF l_sets_tbl.EXISTS (MOD(l_ship_set_id,G_BINARY_LIMIT)) THEN
         NULL;
      ELSE
         l_sets_tbl(MOD(l_ship_set_id,G_BINARY_LIMIT)).set_id := l_ship_set_id;
         FOR k IN ship_set(l_ship_set_id) LOOP
            IF l_set_line_tbl.EXISTS (MOD(k.line_id,G_BINARY_LIMIT)) THEN
               null;
               oe_debug_pub.ADD('Line is already present in the table');
            ELSE
               l_non_plan_line_rec:=p_x_sch_tbl(I);
               l_non_plan_line_rec.line_id:=k.line_id;
               l_non_plan_line_rec.inventory_item_id:=k.inventory_item_id;
               l_non_plan_line_rec.Orig_Inventory_item_id:=k.inventory_item_id;
               l_non_plan_line_rec.Orig_ordered_quantity:=k.ordered_quantity;
               l_non_plan_line_rec.x_return_status := FND_API.G_RET_STS_SUCCESS;

               IF g_sch_tbl.count>0 THEN
                  l_add_count:=g_sch_tbl.count+1;
               END IF ;
               oe_debug_pub.ADD('adding the line:'||l_non_plan_line_rec.line_id||' count '||l_add_count);
               g_sch_tbl(l_add_count):=l_non_plan_line_rec;
               l_set_line_tbl(MOD(l_non_plan_line_rec.line_id,G_BINARY_LIMIT)).line_id := l_non_plan_line_rec.line_id;
            END IF ;  --line is not in the table passed by planning
         END LOOP ;
      END IF;
   ELSIF l_arrival_set_id IS NOT NULL THEN
      IF l_sets_tbl.EXISTS (MOD(l_arrival_set_id,G_BINARY_LIMIT)) THEN
         NULL;
      ELSE
         l_sets_tbl(MOD(l_arrival_set_id,G_BINARY_LIMIT)).set_id := l_arrival_set_id;
         FOR k IN arrival_set(l_arrival_set_id) LOOP
            IF l_set_line_tbl.EXISTS (MOD(k.line_id,G_BINARY_LIMIT)) THEN
               null;
               oe_debug_pub.ADD('Line is already present in the table');
            ELSE
               l_non_plan_line_rec:=p_x_sch_tbl(I);
               l_non_plan_line_rec.line_id:=k.line_id;
               l_non_plan_line_rec.inventory_item_id:=k.inventory_item_id;
               l_non_plan_line_rec.Orig_Inventory_item_id:=k.inventory_item_id;
               l_non_plan_line_rec.Orig_ordered_quantity:=k.ordered_quantity;
               l_non_plan_line_rec.x_return_status := FND_API.G_RET_STS_SUCCESS;

               IF g_sch_tbl.count>0 THEN
                  l_add_count:=g_sch_tbl.count+1;
               END IF ;
               oe_debug_pub.ADD('adding the line:'||l_non_plan_line_rec.line_id);
               g_sch_tbl(l_add_count):=l_non_plan_line_rec;
               l_set_line_tbl(MOD(l_non_plan_line_rec.line_id,G_BINARY_LIMIT)).line_id := l_non_plan_line_rec.line_id;
            END IF ;  --line is not in the table passed by planning
         END LOOP ;
      END IF;
   END IF ;
   --9187335 End

    IF I = l_count
    OR p_x_sch_tbl(I).header_id <> p_x_sch_tbl(I + 1).header_id THEN

       SAVEPOINT Group_Schedule;
       Process_order(x_return_status => l_return_status);
/*
       -- Handling error as per bug 7679398
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
*/
       -- Commented the above for bug 7679398/7675256, and added the SAVEPOINT -
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         ROLLBACK TO Group_Schedule;
       END IF;


       J := g_sch_tbl.FIRST;
       WHILE J IS NOT NULL
       LOOP

         oe_debug_pub.add('J : ' || J);
         oe_debug_pub.add('J Return Status :' || g_sch_tbl(J).x_return_status,1);
         p_x_sch_tbl(J).x_return_status
                           := g_sch_tbl(J).x_return_status;
         IF g_sch_tbl(J).x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            oe_debug_pub.add('Setting the status to W to indicate partial processing',1);
            x_return_status := 'W';

         END IF;

         p_x_sch_tbl(J).x_override_atp_date_code :=
                           g_sch_tbl(I).x_override_atp_date_code;
         oe_debug_pub.add('J+ Return Status :' || p_x_sch_tbl(J).x_return_status,1);
         oe_debug_pub.add('J+ line_id :' || p_x_sch_tbl(J).line_id,1);
        J := g_sch_tbl.next(J);
       END LOOP;

       g_sch_tbl.delete;

    END IF;

  END LOOP;

  END IF; -- Code release.

  oe_msg_pub.save_messages(p_request_id => p_request_id);

  oe_debug_pub.add('Exiting oe_schedule_grp.update_scheduling_results' ||
                                             x_return_status,1);

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
      ,   'update_scheduling_results'
       );
    END IF;
END Update_Scheduling_Results;

PROCEDURE Process_order(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
l_line_rec        OE_Order_PUB.Line_Rec_type;
l_local_line_tbl  OE_ORDER_PUB.line_tbl_type;
l_control_rec     OE_GLOBALS.control_rec_type;
l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_count           Number;
l_ship_from_is_changed BOOLEAN := FALSE;
l_ship_method_is_changed BOOLEAN := FALSE;

-- The l_ord_qty_is_changed is added for IR ISO CMS project.
-- Refer bug #7576948
l_ord_qty_is_changed BOOLEAN := FALSE;

l_item_substituted BOOLEAN := FALSE; -- Added or ER 6110708
l_shippable_flag  VARCHAR2(1); -- Added for ER 6110708
l_opm_enabled     BOOLEAN; -- Added for ER 6110708
l_sales_order_id  Number;
I                 Number;
l_index           Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  oe_debug_pub.add('Entering oe_schedule_grp.Process_order',1);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- This variable is to track that the Item is being Substituted by Planning Loop Back and not being changed manully by user.
  -- Initializing to 'N' for current set of Lines. Will set it to Y if any item substitutions are happening.
  OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'N';  -- Added for ER 6110708

-- Bug #7667702: Tracking bug for IR ISO CMS Project
-- Since, in this code, caller can only be Planning (Planning Workbench
-- or DRP), setting the global with default value FALSE
    OE_Schedule_GRP.G_ISO_Planning_Update := FALSE;


  Validate_sch_data(x_return_status => l_return_status);
  l_count := 1;

  I := g_sch_tbl.FIRST;
  WHILE I IS NOT NULL
  LOOP
--  FOR I IN 1..g_sch_tbl.count LOOP

   IF g_sch_tbl(I).x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
     OE_Line_Util.Query_Row( p_line_id  => g_sch_tbl(I).line_id
                            ,x_line_rec => l_line_rec);

    EXCEPTION
     WHEN NO_DATA_FOUND THEN

       OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => g_sch_tbl(I).line_id
         ,p_header_id                   => g_sch_tbl(I).header_id
         ,p_line_id                     => g_sch_tbl(I).line_id);

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_LOOP_LINE');
        FND_MESSAGE.SET_TOKEN('LINE_ID',g_sch_tbl(I).line_id);
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
        goto end_main_loop;
    END;
     -- Special Validation is needed before taking the data

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       =>
                                l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             =>  l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);


    IF  g_sch_tbl(I).Orig_Schedule_Ship_Date IS NOT NULL
    AND trunc(l_line_rec.Schedule_Ship_Date) <>
               trunc(g_sch_tbl(I).Orig_Schedule_Ship_Date)  THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('Schedule_Ship_Date'));
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF  g_sch_tbl(I).Orig_Schedule_arrival_date IS NOT NULL
    AND trunc(l_line_rec.Schedule_Arrival_date) <>
               trunc(g_sch_tbl(I).Orig_Schedule_arrival_date)
    THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('Schedule_Arrival_date'));
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF  g_sch_tbl(I).Orig_ship_from_org_id IS NOT NULL
    AND l_line_rec.ship_from_org_id <>
               g_sch_tbl(I).Orig_ship_from_org_id
    THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('ship_from_org_id'));
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF g_sch_tbl(I).Orig_Shipping_Method_Code IS NOT NULL
    AND l_line_rec.Shipping_Method_Code <>
               g_sch_tbl(I).Orig_Shipping_Method_Code
    THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('Shipping_Method_Code'));
       OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF g_sch_tbl(I).Orig_ordered_quantity IS NOT NULL
    AND l_line_rec.ordered_quantity <>
               g_sch_tbl(I).Orig_ordered_quantity
    THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('ordered_quantity'));
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF g_sch_tbl(I).Orig_Earliest_Ship_date IS NOT NULL
    AND trunc(Nvl(l_line_rec.Earliest_Ship_date,
               g_sch_tbl(I).Orig_Earliest_Ship_date)) <>
               trunc(g_sch_tbl(I).Orig_Earliest_Ship_date)

    THEN

        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('Earliest_Ship_date'));
        OE_MSG_PUB.ADD;
        g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    IF  l_line_rec.ato_line_id is not null
    AND l_line_rec.ato_line_id <> l_line_rec.line_id
    AND NOT l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

          oe_debug_pub.add('E4',2);
          g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
          OE_MSG_PUB.ADD;
    END IF;

        /* Added for ER 6110708 to support Item Substitutions from Planning Loop Back */
	IF g_sch_tbl(I).inventory_item_id IS NOT NULL
	AND g_sch_tbl(I).inventory_item_id <> g_sch_tbl(I).orig_inventory_item_id THEN

          oe_debug_pub.add('Doing validations for Item Substitutions for Line Id : ' || g_sch_tbl(I).line_id, 5);
          oe_debug_pub.add('   Original Item on Line : ' || g_sch_tbl(I).orig_inventory_item_id, 5);
          oe_debug_pub.add('   Substitute Item       : ' || g_sch_tbl(I).inventory_item_id, 5);
          oe_debug_pub.add('   Current Item on Line  : ' || l_line_rec.inventory_item_id, 5);

	  -- If Item on the Sales Order Line has changed after running the plan and
	  -- before Planning releases the recommendations, then we should not accept the Item
	  -- Substitution. This means that planning has recommended item substitution based on old data.
	  IF l_line_rec.inventory_item_id <> g_sch_tbl(I).orig_inventory_item_id THEN
	      FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
	      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
	      OE_Order_Util.Get_Attribute_Name('inventory_item_id'));
	      OE_MSG_PUB.ADD;
	      g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;

          l_opm_enabled := INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_line_rec.ship_from_org_id);

          l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_rec.HEADER_ID);
          l_line_rec.reserved_quantity := OE_LINE_UTIL.Get_Reserved_Quantity
                                          ( p_header_id   => l_sales_order_id,
                                            p_line_id     => l_line_rec.line_id,
                                            p_org_id      => l_line_rec.ship_from_org_id
                                          );


	  -- Do not allow Item Substitutions in below cases.
          oe_debug_pub.add('   Item Type : ' || l_line_rec.item_type_code, 5);
          oe_debug_pub.add('   Line Set Id : ' || l_line_rec.line_set_id, 5);
          oe_debug_pub.add('   Split From Line Id : ' || l_line_rec.split_from_line_id, 5);
          oe_debug_pub.add('   Source Document Type Id : ' || nvl(l_line_rec.source_document_type_id, -99), 5);
          oe_debug_pub.add('   Source Type : ' || l_line_rec.source_type_code, 5);
          oe_debug_pub.add('   Booked Flag : ' || nvl(l_line_rec.booked_flag, 'N'), 5);
          IF l_opm_enabled THEN
            oe_debug_pub.add('   OPM Enabled Org : Yes', 5);
          ELSE
            oe_debug_pub.add('   OPM Enabled Org : No', 5);
          END IF;
          oe_debug_pub.add('   Reserved Qty : ' || nvl(l_line_rec.reserved_quantity, 0), 5);

	  IF ( l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD OR  -- Not a Standard Item
	       l_line_rec.line_set_id IS NOT NULL OR                   -- Line is Split
	       l_line_rec.split_from_line_id IS NOT NULL OR            -- Split Line
	       nvl(l_line_rec.source_document_type_id, -99) = 10 OR    -- Internal Sales Order Line
	       l_line_rec.source_type_code = 'EXTERNAL' OR             -- Externally Sourced Line
               ( nvl(l_line_rec.booked_flag, 'N') = 'Y' and INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_line_rec.ship_from_org_id) ) OR
                                                                       -- Booked Line and OPM Item
               ( nvl(l_line_rec.booked_flag, 'N') = 'Y' and nvl(l_line_rec.reserved_quantity, 0) <> 0 ) -- Booked Line with Reservations
	      )
	  THEN
		g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
		OE_MSG_PUB.ADD;
	  END IF;

	  -- Do not allow substitution of Shippable Item with non-Shippable and vise versa once the Line is Booked.
          IF nvl(l_line_rec.booked_flag, 'N') = 'Y' THEN
	    BEGIN
	      SELECT shippable_item_flag
	      INTO   l_shippable_flag
	      FROM   MTL_SYSTEM_ITEMS
	      WHERE  INVENTORY_ITEM_ID = g_sch_tbl(I).inventory_item_id
	      AND    ORGANIZATION_ID = nvl(g_sch_tbl(I).ship_from_org_id, l_line_rec.ship_from_org_id);

	      IF l_shippable_flag <> l_line_rec.shippable_flag THEN
		  g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_SHP_NONSHP');
	  	  OE_MSG_PUB.ADD;
	      END IF;
       	    END;
          END IF;

          oe_debug_pub.add('Finished with validations for Item Substitutions', 5);

	END IF;
	/* End of ER 6110708 */

     -- Special Validation.

    oe_debug_pub.add('After Special Validation ',2);
    IF g_sch_tbl(I).x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     IF nvl(l_line_rec.override_atp_date_code,'N') = 'Y' THEN
        g_sch_tbl(I).x_override_atp_date_code := 'Y';
     END IF;

     IF (l_line_rec.ato_line_id = l_line_rec.line_id
     AND l_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_MODEL,
                                        OE_GLOBALS.G_ITEM_CLASS))
     OR   l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG

     THEN
        oe_debug_pub.add('ATO Model',2);

         OE_Config_Util.Query_ATO_Options
            (p_ato_line_id => l_line_rec.ato_line_id,
             x_line_tbl    => l_local_line_tbl);

         FOR J IN 1..l_local_line_tbl.COUNT LOOP

           IF l_local_line_tbl(J).shippable_flag = 'Y' THEN

            l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                              (l_local_line_tbl(J).HEADER_ID);
            l_local_line_tbl(J).reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_local_line_tbl(J).line_id,
                  p_org_id      => l_local_line_tbl(J).ship_from_org_id);

           END IF;

           g_old_line_tbl(l_count) := l_local_line_tbl(J);

           IF g_sch_tbl(I).schedule_ship_date is NOT NULL THEN
/*
             IF trunc(g_sch_tbl(I).schedule_ship_date) < trunc(l_local_line_tbl(J).request_date)  THEN

                oe_debug_pub.add('Schedule Ship Date connot be less than request_date');
                g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
                l_local_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;
                l_local_line_tbl(J).return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_INVALID_DATE');
                OE_MSG_PUB.ADD;
                goto end_loop;
             END IF;
*/
             l_local_line_tbl(J).schedule_ship_date := g_sch_tbl(I).schedule_ship_date;

           END IF;

           IF g_sch_tbl(I).schedule_arrival_date IS NOT NULL THEN

/*             IF trunc(g_sch_tbl(I).schedule_arrival_date) < trunc(l_local_line_tbl(J).request_date)  THEN

                oe_debug_pub.add('Schedule Ship Date connot be less than request_date');
                g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
                l_local_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;
                l_local_line_tbl(J).return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_INVALID_DATE');
                oe_msg_pub.add;
                goto end_loop;
             END IF;
*/
             l_local_line_tbl(J).schedule_arrival_date := g_sch_tbl(I).schedule_arrival_date;
           END IF;

           IF  g_sch_tbl(I).ship_from_org_id is not null
           AND g_sch_tbl(I).ship_from_org_id <> l_local_line_tbl(J).ship_from_org_id THEN
              l_ship_from_is_changed := TRUE;
              l_local_line_tbl(J).ship_from_org_id := g_sch_tbl(I).ship_from_org_id;
           END IF;

           IF g_sch_tbl(I).Delivery_lead_time is not null THEN
              l_local_line_tbl(J).Delivery_lead_time  := g_sch_tbl(I).Delivery_lead_time ;
           END IF;

           IF g_sch_tbl(I).Shipping_Method_Code is not null
           AND nvl(l_local_line_tbl(J).Shipping_Method_Code,'-X') <> g_sch_tbl(I).Shipping_Method_Code THEN
              l_ship_method_is_changed := TRUE;
              l_local_line_tbl(J).Shipping_Method_Code := g_sch_tbl(I).Shipping_Method_Code;
           END IF;
           oe_debug_pub.add('Local shipping Method ' || l_local_line_tbl(J).Shipping_Method_Code,2);

           IF nvl(g_sch_tbl(I).Firm_Demand_Flag,'N') = 'Y'
           AND nvl(l_local_line_tbl(J).Firm_demand_Flag,'N') = 'N' THEN
              l_local_line_tbl(J).Firm_Demand_Flag := 'Y';
           END IF;

           IF g_sch_tbl(I).Earliest_ship_date is not null THEN
              l_local_line_tbl(J).Earliest_ship_date := g_sch_tbl(I).Earliest_ship_date;
           END IF;

-- The Ordered Quantity check is added for IR ISO CMS project.
-- Refer bug #7576948
           IF g_sch_tbl(I).Ordered_Quantity is not null
           AND g_sch_tbl(I).Ordered_Quantity <> nvl(l_local_line_tbl(J).Ordered_Quantity,0) THEN
             l_ord_qty_is_changed := TRUE;
             l_local_line_tbl(J).Ordered_Quantity := g_sch_tbl(I).Ordered_Quantity;
           END IF;

           oe_debug_pub.add('Before assigning' || l_local_line_tbl(J).line_id,2);
           g_line_tbl(l_count) := l_local_line_tbl(J);
           g_line_tbl(l_count).operation := OE_GLOBALS.G_OPR_UPDATE;
           g_line_tbl(l_count).return_status := Null;
           l_count := l_count + 1;
          <<end_loop>>
            g_sch_tbl(I).x_line_number :=
                OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(g_sch_tbl(I).line_id);
         END LOOP;

     ELSE

       IF nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

         l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                              (l_line_rec.HEADER_ID);
         l_line_rec.reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id);

       END IF;

       g_old_line_tbl(l_count) := l_line_rec;

       /* Added for ER 6110708 */
       IF g_sch_tbl(I).inventory_item_id IS NOT NULL
       AND g_sch_tbl(I).inventory_item_id <> g_sch_tbl(I).orig_inventory_item_id THEN

            -- When doing item substitutions, store the original item details.
            IF  l_line_rec.Original_Inventory_Item_Id is null THEN
               l_line_rec.Original_Inventory_Item_Id := l_line_rec.Inventory_Item_id;
               l_line_rec.Original_item_identifier_Type := l_line_rec.item_identifier_type;
               l_line_rec.Original_ordered_item_id := l_line_rec.ordered_item_id;
               l_line_rec.Original_ordered_item := l_line_rec.ordered_item;
            END IF;

            l_line_rec.inventory_item_id := g_sch_tbl(I).inventory_item_id;
            l_line_rec.item_identifier_type := 'INT';
            l_item_substituted := TRUE;

            -- This variable is to track that the Item is being Substituted by Planning Loop Back and not being changed manully by user.
            OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'Y';

       END IF;
       /* End of ER 6110708 */

       IF g_sch_tbl(I).schedule_ship_date is NOT NULL THEN
/*          IF trunc(g_sch_tbl(I).schedule_ship_date) < trunc(l_line_rec.request_date)  THEN

             oe_debug_pub.add('Schedule Ship Date connot be less than request_date');
             g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
             l_line_rec.operation := OE_GLOBALS.G_OPR_NONE;
             l_line_rec.return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_INVALID_DATE');
             OE_MSG_PUB.ADD;
             goto end_loop1;
           END IF;
 */         l_line_rec.schedule_ship_date := g_sch_tbl(I).schedule_ship_date;
       END IF;
       IF g_sch_tbl(I).schedule_arrival_date is NOT NULL THEN
/*         IF trunc(g_sch_tbl(I).schedule_arrival_date) < trunc(l_line_rec.request_date)  THEN

             oe_debug_pub.add('Schedule Ship Date connot be less than request_date');
             g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
             l_line_rec.operation := OE_GLOBALS.G_OPR_NONE;
             l_line_rec.return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_INVALID_DATE');
             oe_msg_pub.add;
             goto end_loop1;
          END IF;
*/          l_line_rec.schedule_arrival_date := g_sch_tbl(I).schedule_arrival_date;
       END IF;

       IF g_sch_tbl(I).ship_from_org_id is not null
       AND g_sch_tbl(I).ship_from_org_id <> l_line_rec.ship_from_org_id THEN
          l_ship_from_is_changed := TRUE;
          l_line_rec.ship_from_org_id := g_sch_tbl(I).ship_from_org_id;
       END IF;

       IF g_sch_tbl(I).Delivery_lead_time is not null THEN
          l_line_rec.Delivery_lead_time  := g_sch_tbl(I).Delivery_lead_time;
       END IF;

       IF g_sch_tbl(I).Shipping_Method_Code is not null
       AND g_sch_tbl(I).Shipping_Method_Code <> nvl(l_line_rec.Shipping_Method_Code,'-X') THEN
          l_ship_method_is_changed := TRUE;
          l_line_rec.Shipping_Method_Code := g_sch_tbl(I).Shipping_Method_Code;
       END IF;
       oe_debug_pub.add('Shipping Method on line rec ' || l_line_rec.Shipping_Method_Code,2);

       IF nvl(g_sch_tbl(I).Firm_Demand_Flag,'N') = 'Y'
       AND nvl(l_line_rec.Firm_demand_Flag,'N') = 'N' THEN
           l_line_rec.Firm_Demand_Flag := 'Y';
       END IF;

       IF g_sch_tbl(I).Earliest_ship_date is not null THEN
          l_line_rec.Earliest_ship_date := g_sch_tbl(I).Earliest_ship_date;
       END IF;

-- The Ordered Quantity check is added for IR ISO CMS project.
-- Refer bug #7576948
       IF g_sch_tbl(I).Ordered_Quantity is not null
       AND g_sch_tbl(I).Ordered_Quantity <> nvl(l_line_rec.Ordered_Quantity,0) THEN
         l_ord_qty_is_changed := TRUE;
         l_line_rec.Ordered_Quantity := g_sch_tbl(I).Ordered_Quantity;
       END IF;

       l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
       g_line_tbl(l_count) := l_line_rec;
       g_line_tbl(l_count).return_status := Null;
       l_count := l_count + 1;
       <<end_loop1>>
        g_sch_tbl(I).x_line_number :=
             OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(g_sch_tbl(I).line_id);

     END IF;
    END IF; -- Second Return
   END IF; -- return status

  <<end_main_loop>>
  I := g_sch_tbl.NEXT(I);
  END LOOP;

 -- assign the error status to g_sch_tbl
  Validate_lines(x_return_status => l_return_status);


  FOR J IN 1..g_line_tbl.count LOOP

    oe_debug_pub.add('Operation ' || g_line_tbl(J).operation ,2);

    IF g_line_tbl(J).return_status <> FND_API.G_RET_STS_SUCCESS  THEN

       oe_debug_pub.add('None ' || g_line_tbl(J).return_status,2);
       g_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;

    ELSE


         IF g_line_tbl(J).schedule_status_code is not null THEN

         OE_SCHEDULE_UTIL.Promise_Date_for_Sch_Action
                ( p_x_line_rec => g_line_tbl(J)
                 ,p_sch_action => OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE
                 ,p_header_id  => g_line_tbl(J).header_id);


         ELSE

           g_line_tbl(J).schedule_status_code := OE_SCHEDULE_UTIL.OESCH_STATUS_SCHEDULED;
           g_line_tbl(J).visible_demand_flag  := 'Y';

           OE_SCHEDULE_UTIL.Promise_Date_for_Sch_Action
                ( p_x_line_rec => g_line_tbl(J)
                 ,p_sch_action => OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
                 ,p_header_id  => g_line_tbl(J).header_id);

           -- Firm Demand Flag.
           IF  nvl(g_line_tbl(J).firm_demand_flag,'N') = 'N'
           AND Oe_Sys_Parameters.Value('FIRM_DEMAND_EVENTS') = 'SCHEDULE' THEN
               g_line_tbl(J).firm_demand_flag := 'Y';

           END IF;

         END IF;

    -- 4558027
    /* Start Audit Trail */
    g_line_tbl(J).change_reason := 'SYSTEM';
    g_line_tbl(J).change_comments := 'ASCP UPDATE';
    /* End Audit Trail */

    END IF;

    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Operation1            ' || g_line_tbl(J).operation ,2);
    oe_debug_pub.add('Line_id               ' || g_line_tbl(J).line_id,2);
    oe_debug_pub.add('Schedule_ship_date    ' || g_line_tbl(J).Schedule_ship_date,2);
    oe_debug_pub.add('Schedule_arrival_date ' || g_line_tbl(J).Schedule_arrival_date,2);
    oe_debug_pub.add('Schedule_status_code  ' || g_line_tbl(J).Schedule_status_code,2);
    oe_debug_pub.add('Ship_from_org         ' || g_line_tbl(J).Ship_from_org_id,2);
    Oe_debug_pub.add('Shipping Method       ' || g_line_tbl(J).shipping_method_code,2);
    oe_debug_pub.add('Ordered Quantity      ' || g_line_tbl(J).Ordered_Quantity,2);
    END IF;

   END LOOP;

-- Bug #7576948: FOr IR ISO CMS Project
--
-- Since, in this code, caller can only be Planning (Planning Workbench
-- or DRP), setting the global to TRUE, which can be read while processing
-- Scheduling for an internal sales order line with quantity as 0, i.e.
-- line is cancelled by Planner/DRP user
-- This global will even be used to supress the notification to be send
-- to Purchasing user for teh corresponding internal requisition, when the
-- changes are from Planning user
--
    OE_Schedule_GRP.G_ISO_Planning_Update := TRUE;
    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' Setting global OE_Schedule_GRP.G_ISO_Planning_Update to TRUE',5);
    END IF;
--

  IF l_ship_from_is_changed
  OR l_ship_method_is_changed
  OR l_item_substituted -- Added for ER 6110708, Process Order should be called in case of Item Substitutions also.
  OR l_ord_qty_is_changed -- Added as part of IR ISO CMS Project. Refer bug #7576948
  THEN

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.check_security       := TRUE; -- For ER 6110708 made it to TRUE, previously it was FALSE;

    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

  FOR J IN 1..g_line_tbl.count LOOP

    oe_debug_pub.add('OP ' || g_line_tbl(J).operation ,2);
    oe_debug_pub.add('OP ' || g_line_tbl(J).line_id ,2);
    oe_debug_pub.add('Ol OP ' || g_old_line_tbl(J).operation ,2);
    oe_debug_pub.add('Ol OP ' || g_old_line_tbl(J).line_id ,2);

  END LOOP;

    OE_Schedule_Util.Call_Process_Order
    ( p_x_old_line_tbl  => g_old_line_tbl
     ,p_x_line_tbl      => g_line_tbl
     ,p_control_rec     => l_control_rec
     ,p_caller          => OE_SCHEDULE_UTIL.SCH_EXTERNAL
     ,x_return_status   => x_return_status);
    /* Commented for 4606248
    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => TRUE
     ,p_notify                  => TRUE
     ,p_line_tbl                => g_line_tbl
     ,p_old_line_tbl            => g_old_line_tbl
     ,x_return_status           => x_return_status);
    */

  ELSE

   BEGIN
    OE_Config_Schedule_Pvt.Save_Sch_Attributes
    ( p_x_line_tbl     => g_line_tbl
     ,p_old_line_tbl   => g_old_line_tbl
     ,p_sch_action     => OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
     ,p_caller         => OE_SCHEDULE_UTIL.SCH_EXTERNAL
     ,x_return_status  => x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   END;

  END IF;
  -- 4606248
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

  OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => TRUE
     ,p_notify                  => TRUE
     ,p_line_tbl                => g_line_tbl
     ,p_old_line_tbl            => g_old_line_tbl
     ,x_return_status           => x_return_status);

     -- Resetting the variable after the Process Order API Call.
     OE_SCHEDULE_UTIL.OESCH_ITEM_IS_SUBSTITUTED := 'N';  -- Added for ER 6110708

--   ELSE  -- Updated for bug 7679398/7675256
  END IF;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN



     FOR I IN 1..g_line_tbl.COUNT LOOP

          l_index := find_index(g_line_tbl(I).line_id);
          g_sch_tbl(l_index).x_return_status := x_return_status;
     END LOOP;

     oe_debug_pub.add('Before clearing all requests',2);

     oe_delayed_requests_pvt.Clear_Request(x_return_status=> l_return_status);
     OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
     IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN
        OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
     END IF;


  END IF;

-- Bug #7576948: For IR ISO CMS Project
-- Ressting the global to FALSE
--
    OE_Schedule_GRP.G_ISO_Planning_Update := FALSE;
    IF l_debug_level > 0 THEN
      oe_debug_pub.add(' Setting global OE_Schedule_GRP.G_ISO_Planning_Update to FALSE',5);
    END IF;
--


  FOR I IN 1..g_line_tbl.COUNT LOOP

    IF ( g_line_tbl(I).reserved_quantity > 0
         OR g_line_tbl(I).inventory_item_id <> g_old_line_tbl(I).inventory_item_id  -- Added for ER 6110708
       )
    AND (g_line_tbl(I).return_status is null OR
        g_line_tbl(I).return_status = FND_API.G_RET_STS_SUCCESS) THEN

       Update_reservation(p_index => I,
                          x_return_status => l_return_status);

    END IF;
  END LOOP;
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  g_line_tbl.delete;
  g_old_line_tbl.delete;

  oe_debug_pub.add('Exiting oe_schedule_grp.Process_order '||x_return_status,1);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    OE_Schedule_GRP.G_ISO_Planning_Update := FALSE;
    -- Added for IR ISO Tracking bug 7667702

    x_return_status := FND_API.G_RET_STS_ERROR;
    g_line_tbl.delete;
    g_old_line_tbl.delete;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    OE_Schedule_GRP.G_ISO_Planning_Update := FALSE;
    -- Added for IR ISO Tracking bug 7667702

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_line_tbl.delete;
    g_old_line_tbl.delete;

  WHEN OTHERS THEN

    OE_Schedule_GRP.G_ISO_Planning_Update := FALSE;
    -- Added for IR ISO Tracking bug 7667702

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    g_line_tbl.delete;
    g_old_line_tbl.delete;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'process_order'
       );
    END IF;
END process_order;

PROCEDURE Validate_sch_data(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
I NUMBER;
BEGIN

    I := g_sch_tbl.FIRST;
    WHILE I IS NOT NULL
    LOOP
--    FOR I IN 1..g_sch_tbl.count LOOP

     IF g_sch_tbl(I).schedule_ship_date is null
     OR g_sch_tbl(I).schedule_arrival_date is NULL
     THEN

       OE_MSG_PUB.set_msg_context
        ( p_entity_code   => 'LINE'
         ,p_entity_id     => g_sch_tbl(I).line_id
         ,p_header_id     => g_sch_tbl(I).header_id
         ,p_line_id       => g_sch_tbl(I).line_id);

       oe_debug_pub.add('ONT_SCH_LOOP_DATE_NULL',1);
       g_sch_tbl(I).x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_DATE_NULL');
       OE_MSG_PUB.ADD;

     END IF;

    I := g_sch_tbl.NEXT(I);
    END LOOP;
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
      ,   'Validate_sch_data'
       );
    END IF;
END Validate_sch_data;

PROCEDURE Validate_Lines(x_return_status OUT NOCOPY /* file.sql.39 change */ Varchar2)
IS
l_scheduling_level_code  VARCHAR2(30);
l_out_return_status      VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_result                 Varchar2(30);
l_index                  NUMBER;

BEGIN

   oe_debug_pub.add('Entering Validate_Lines',1);

   FOR I IN 1..G_LINE_TBL.COUNT LOOP

   oe_debug_pub.add('Validate_Lines' || g_line_tbl(I).line_id,1);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => g_line_tbl(I).line_id
         ,p_header_id                   => g_line_tbl(I).header_id
         ,p_line_id                     => g_line_tbl(I).line_id
         ,p_orig_sys_document_ref       =>
                                g_line_tbl(I).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                g_line_tbl(I).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                g_line_tbl(I).orig_sys_shipment_ref
         ,p_change_sequence             =>  g_line_tbl(I).change_sequence
         ,p_source_document_id          =>
                                g_line_tbl(I).source_document_id
         ,p_source_document_line_id     =>
                                g_line_tbl(I).source_document_line_id
         ,p_order_source_id             =>
                                g_line_tbl(I).order_source_id
         ,p_source_document_type_id     =>
                                g_line_tbl(I).source_document_type_id);

       /*
       IF g_line_tbl(I).schedule_status_code is null THEN

          oe_debug_pub.add('E1',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_CANT_UPDATE');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
      */
       IF g_line_tbl(I).cancelled_flag = 'Y' THEN

          oe_debug_pub.add('E1-1',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LINE_FULLY_CANCELLED');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF g_line_tbl(I).shipped_quantity is not null THEN

          oe_debug_pub.add('E1-2',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LINE_SHIPPED');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       oe_debug_pub.add('Firm_demand_flag :' || g_line_tbl(I).firm_demand_flag,1);

       -- Commenting this code as ASCP is doing this already.
     /*  IF NVL(g_old_line_tbl(I).firm_demand_flag,'N') = 'Y'
       AND not oe_globals.equal(g_line_tbl(I).ship_from_org_id,
                            g_old_line_tbl(I).ship_from_org_id) THEN

          oe_debug_pub.add('E2',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_FRMD');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF; */

       IF g_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_SERVICE THEN

          oe_debug_pub.add('E3',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_SRV');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF g_line_tbl(I).ato_line_id IS NOT NULL THEN
/*        IF  NOT (g_line_tbl(I).ato_line_id    = g_line_tbl(I).line_id OR
              g_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CONFIG) THEN

          oe_debug_pub.add('E4',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
*/
        IF nvl(g_line_tbl(I).model_remnant_flag,'N') = 'Y' THEN
          oe_debug_pub.add('E5',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
       END IF;

       IF g_line_tbl(I).line_category_code =  'RETURN' THEN

          oe_debug_pub.add('E6',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_RET');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF OE_OTA_UTIL.Is_OTA_Line(g_line_tbl(I).order_quantity_uom) THEN

          oe_debug_pub.add('E7',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF g_line_tbl(I).source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL THEN

          oe_debug_pub.add('E8',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_EXT');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       l_scheduling_level_code := OE_SCHEDULE_UTIL.Get_Scheduling_Level
                                                   (g_line_tbl(I).header_id,
                                                    g_line_tbl(I).line_type_id);

       IF l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FOUR OR
          l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_FIVE OR
          l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_ONE THEN

          oe_debug_pub.add('E9',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_SCH_LOOP_LVL');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;


       END IF;

       IF g_line_tbl(I).arrival_set_id is not null OR
          g_line_tbl(I).ship_set_id is not null OR
          g_line_tbl(I).ship_model_complete_flag = 'Y' THEN


         -- Check all the lines in the set are passed or not.

         Validate_set(p_ship_set_id       => g_line_tbl(I).ship_set_id,
                      p_arrival_set_id    => g_line_tbl(I).arrival_set_id,
                      p_top_model_line_id => g_line_tbl(I).top_model_line_id);


       END IF;
/*
       IF NVL(g_line_tbl(I).re_source_flag,'Y') = 'N' AND
          g_line_tbl(I).ship_from_org_id <>
          NVL(g_sch_tbl(I).ship_from_org_id,g_line_tbl(I).ship_from_org_id)
       THEN
          oe_debug_pub.add('E10',2);
          g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
          FND_MESSAGE.SET_NAMe('ONT', 'OE_SCH_LOOP_WSH_UPD');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

       END IF;
*/
       IF  Oe_Sys_Parameters.Value('ONT_SCHEDULE_LINE_ON_HOLD') = 'N' THEN

            OE_Holds_PUB.Check_Holds
                 (   p_api_version       => 1.0
                 ,   p_init_msg_list     => FND_API.G_FALSE
                 ,   p_commit            => FND_API.G_FALSE
                 ,   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
                 ,   x_return_status     => l_out_return_status
                 ,   x_msg_count         => l_msg_count
                 ,   x_msg_data          => l_msg_data
                 ,   p_line_id           => g_line_tbl(I).line_id
                 ,   p_hold_id           => NULL
                 ,   p_entity_code       => NULL
                 ,   p_entity_id         => NULL
                 ,   x_result_out        => l_result
                 );

            IF (l_out_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              IF l_out_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

            IF (l_result = FND_API.G_TRUE) THEN
              oe_debug_pub.add('E11',2);
              g_line_tbl(I).operation := OE_GLOBALS.G_OPR_NONE;
              FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
              OE_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;


       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          l_index := find_index(g_line_tbl(I).line_id);
          g_sch_tbl(l_index).x_return_status := x_return_status;
       END IF;
   END LOOP;

   oe_debug_pub.add('Existing Validate_Lines',1);

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
      ,   'Validate_Lines'
       );
    END IF;
END Validate_Lines;

PROCEDURE Validate_set(p_ship_set_id       IN NUMBER DEFAULT NULL,
                       p_arrival_set_id    IN NUMBER DEFAULT NULL,
                       p_top_model_line_id IN NUMBER DEFAULT NULL)
IS

 Cursor line_ship_set IS
 Select line_id,ato_line_id,item_type_code
 From   oe_order_lines_all
 Where  ship_set_id = p_ship_set_id;

 Cursor line_arrival_set IS
 Select line_id,ato_line_id,item_type_code
 From   oe_order_lines_all
 Where  arrival_set_id = p_arrival_set_id;

 Cursor line_smc IS
 Select line_id,ato_line_id,item_type_code
 From   oe_order_lines_all
 Where  top_model_line_id = p_top_model_line_id;

 l_result  Boolean := TRUE;
 l_index   Number;

BEGIN

   Oe_debug_pub.add('Entering Procedure Validate_set'|| p_ship_set_id,1);
  IF p_Ship_set_id is not null THEN

   FOR C1 IN line_ship_set LOOP
      IF NOT Find_line(C1.line_id) THEN

        l_result := FALSE;
        EXIT;

      END IF;


   END LOOP;

  ELSIF   p_arrival_set_id is not null THEN

   FOR C1 IN line_arrival_set LOOP
      IF NOT Find_line(C1.line_id) THEN

        l_result := FALSE;
        EXIT;

      END IF;


   END LOOP;

  ELSE

     FOR C1 IN line_smc LOOP

        IF NOT Find_line(C1.line_id) THEN

            l_result := FALSE;
            EXIT;

        END IF;


     END LOOP;
  END IF;

   IF NOT l_result THEN

     oe_debug_pub.add('E10',2);
     FND_MESSAGE.SET_NAME('ONT', 'OE_SCH_LOOP_NOT_SUP');
     OE_MSG_PUB.ADD;
     IF p_ship_set_id IS NOT NULL THEN

         FOR J IN 1..g_line_tbl.count LOOP

            IF g_line_tbl(J).ship_set_id = p_ship_set_id THEN

               g_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;
               g_line_tbl(J).return_status := FND_API.G_RET_STS_ERROR;

               l_index := find_index(g_line_tbl(J).line_id);
               g_sch_tbl(l_index).x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

         END LOOP;

     ELSIF p_arrival_set_id IS NOT NULL THEN

         FOR J IN 1..g_line_tbl.count LOOP

            IF g_line_tbl(J).arrival_set_id = p_arrival_set_id THEN

               g_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;
               g_line_tbl(J).return_status := FND_API.G_RET_STS_ERROR;
               l_index := find_index(g_line_tbl(J).line_id);
               g_sch_tbl(l_index).x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

         END LOOP;

     ELSIF p_top_model_line_id IS NOT NULL THEN

         FOR J IN 1..g_line_tbl.count LOOP

            IF g_line_tbl(J).top_model_line_id = p_top_model_line_id THEN

               g_line_tbl(J).operation := OE_GLOBALS.G_OPR_NONE;
               l_index := find_index(g_line_tbl(J).line_id);
               g_sch_tbl(l_index).x_return_status := FND_API.G_RET_STS_ERROR;

            END IF;

         END LOOP;

     END IF;

   END IF;
EXCEPTION

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Validate_set'
       );
    END IF;
END Validate_set;

FUNCTION Find_line(p_line_id IN NUMBER)
Return BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING FIND_LINE: ' || P_LINE_ID , 1 ) ;
  END IF;

  FOR J IN 1..g_line_tbl.count LOOP

     IF p_line_id = g_line_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE EXISTS IN THE TABLE' , 1 ) ;
         END IF;
         RETURN TRUE;
     END IF;
  END LOOP;



 RETURN FALSE;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Find_line'
       );
    END IF;
    RETURN FALSE;
END Find_line;


FUNCTION Find_index(p_line_id IN NUMBER)
Return NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
J NUMBER;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING FIND_Index: ' || P_LINE_ID , 1 ) ;
  END IF;

  J := g_sch_tbl.FIRST;
  WHILE J IS NOT NULL
  LOOP

     IF p_line_id = g_sch_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' J : ' || J, 1 ) ;
         END IF;
         RETURN J;
     END IF;
  J := g_sch_tbl.NEXT(J);
  END LOOP;



 RETURN null;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN Null;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN Null;

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Find_index'
       );
    END IF;
    RETURN Null;
END Find_index;
Procedure Update_reservation(p_index IN NUMBER,
                             x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
BEGIN

  IF (NOT OE_GLOBALS.Equal(g_line_tbl(p_index).ship_from_org_id,
                          g_old_line_tbl(p_index).ship_from_org_id))
  OR  ( NOT OE_GLOBALS.Equal(g_line_tbl(p_index).inventory_item_id, g_old_line_tbl(p_index).inventory_item_id)
        AND nvl(g_line_tbl(p_index).booked_flag, 'N') = 'N'
      ) -- OR clause added for ER 6110708
  THEN

     OE_SCHEDULE_UTIL.Unreserve_Line
       (p_line_rec              => g_old_line_tbl(p_index),
        p_quantity_to_unreserve => g_old_line_tbl(p_index).reserved_quantity,
        x_return_status         => x_return_status);

     OE_SCHEDULE_UTIL.Reserve_Line
       (p_line_rec             => g_line_tbl(p_index)
       ,p_quantity_to_reserve  => g_line_tbl(p_index).reserved_quantity
       ,x_return_Status        => x_return_status);

   ELSIF NOT OE_GLOBALS.Equal(g_line_tbl(p_index).schedule_ship_date,
                              g_old_line_tbl(p_index).schedule_ship_date)
   THEN

     OE_CONFIG_SCHEDULE_PVT.Update_Reservation
     ( p_line_rec      => g_line_tbl(p_index)
      ,p_old_line_rec  => g_old_line_tbl(p_index)
      ,x_return_status => x_return_status);

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
      ,   'Validate_set'
       );
    END IF;
END Update_Reservation;

END OE_SCHEDULE_GRP;

/
