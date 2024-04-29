--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_UTIL" AS
/* $Header: OEXUCFGB.pls 120.33.12010000.7 2011/02/25 08:50:12 snimmaga ship $ */

--  Global constant holding the package name
G_PKG_NAME      CONSTANT    VARCHAR2(30):='Oe_Config_Util';

/*-----------------------------------------------------------------
forward declarations
------------------------------------------------------------------*/
PROCEDURE Query_Config
( p_link_to_line_id     IN  NUMBER := FND_API.G_MISS_NUM
  , p_top_model_line_id   IN  NUMBER := FND_API.G_MISS_NUM
  , p_ato_line_id         IN  NUMBER := FND_API.G_MISS_NUM
  , x_line_tbl            OUT NOCOPY OE_ORDER_PUB.line_tbl_type);

Procedure get_transaction_id(p_caller   IN  VARCHAR2);

PROCEDURE Print_Time(p_msg   IN  VARCHAR2);

PROCEDURE Log_Included_Item_Requests
( p_line_tbl    IN  OE_Order_Pub.Line_Tbl_Type
 ,p_booked_flag IN  VARCHAR2);

PROCEDURE  Unlock_Config
(p_line_rec  IN OE_ORDER_PUB.line_rec_type,
 x_return_status OUT NOCOPY VARCHAR2);

/*-------------------------------------------------------------------------
Procedure Name : Config_Exists
Description    :
--------------------------------------------------------------------------*/

FUNCTION Config_Exists(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   RETURN TRUE;
END Config_Exists;

/*------------------------------------------------------------------------
Procedure Name : Complete_Config
Description    : This procedure will cascade the quantity change from the
                 parent to all it's children. Currently, implementing it
                 as a single update statement.
------------------------------------------------------------------------ */
Procedure Complete_Config
( p_top_model_line_id IN  NUMBER
, x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- Complete Config Config Using the BOM_EXPLOSIONS
  -- Populate link_to_line_id
  -- Populate ato_line_id
  NULL;
END;


/*------------------------------------------------------------------------
Procedure Name : Cascade_Changes
Description    : This procedure will cascade the attribute changes from the
                 top most parent to all it's children, including the
                 included items, even if they are under a class of the
                 top parent. If a parameter is passed with
                 value other than null(te default of the params is null),
                 it indicate that the colums has changed on top parent
                 and needs to be cascaded.

Change Record:
2031256: To populated shipped_quantity and actual_shipment_date
on ato child lines.

Dropship fro config : cascade source type for ato: param15
------------------------------------------------------------------------ */


Procedure Cascade_Changes
( p_parent_line_id     IN  NUMBER,
  p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
    -- params sent in request rec.
    l_item_type_code       VARCHAR2(30)  := p_request_rec.param7;
    l_child_item_type      VARCHAR2(30);
    l_old_quantity         NUMBER        := to_number(p_request_rec.param1);
    l_new_quantity         NUMBER        := to_number(p_request_rec.param2);
    l_change_reason        VARCHAR2(100) := p_request_rec.param3;
    l_change_comments      VARCHAR2(2000) := p_request_rec.param4;   -- 4495205
    l_project_id           NUMBER        := to_number(p_request_rec.param5);
    l_task_id              NUMBER        := to_number(p_request_rec.param6);
    l_ship_tolerance_above NUMBER        := to_number(p_request_rec.param11);
    l_ship_tolerance_below NUMBER        := to_number(p_request_rec.param12);
    l_ship_quantity        NUMBER        := to_number(p_request_rec.param9);
    l_set_zero             VARCHAR2(1)   := 'N';
    l_ship_to_org_id       NUMBER        := to_number(p_request_rec.param14);
    l_request_date         DATE          := p_request_rec.date_param1;
    l_promise_date         DATE          := p_request_rec.date_param2;
/* Added the following parameter to fix the bug 2217336 */
    l_freight_terms_code   VARCHAR2(100) := p_request_rec.param16;
    l_ratio                NUMBER;
    child_line_id          NUMBER;
    l_inv_item_id          NUMBER;
    l_ordered_qty          NUMBER;
    l_shipped_qty          NUMBER;
    l_model_line_id        NUMBER;
    l_model_qty            NUMBER;
    l_model_actual_ship_date   DATE;
    l_parent_line_rec           OE_ORDER_PUB.Line_Rec_Type;
    l_header_id            NUMBER := 0;


    -- process_order in variables
    l_control_rec              OE_GLOBALS.Control_Rec_Type;
    l_header_rec               OE_Order_PUB.Header_Rec_Type;
    l_line_rec                 OE_ORDER_PUB.Line_Rec_Type
                               := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_old_line_tbl             OE_Order_PUB.Line_Tbl_Type;
    l_line_tbl                 OE_Order_PUB.Line_Tbl_Type;
    l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_line_count               NUMBER;
    l_queried_quantity         NUMBER;

    CURSOR children is
    SELECT line_id, inventory_item_id, ordered_quantity, item_type_code,
           shipped_quantity
    FROM   oe_order_lines
    WHERE header_id = l_header_id
    AND   open_flag = 'Y'
    AND  ((top_model_line_id = p_parent_line_id
           and line_id <> p_parent_line_id)
          OR
          (l_item_type_code  = OE_GLOBALS.G_ITEM_CLASS
           and ato_line_id = p_parent_line_id
           and line_id <> p_parent_line_id ));

-- parent_line_id is either top_model_line_id for models and kits
-- or it can be class only for ato sub configs
-- in 2nd case we will get children using ato_line_id as a link.

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.CASCADE_CHANGES' , 1);
    oe_debug_pub.add('MODEL OLD QTY: ' ||L_OLD_QUANTITY , 2 );
    oe_debug_pub.add('MODEL NEW QTY: ' ||L_NEW_QUANTITY , 2 );
  END IF;

  IF l_old_quantity = 0 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CASCADE_CHANGES RETURNING , SINCE OLD QTY = 0' , 1);
    END IF;
    x_return_status := l_return_status;
    RETURN;
  END IF;

  -- insted of modifying cursor, querying the line,
  -- so that code remains clean.

  OE_Line_Util.Lock_Row( p_line_id       => p_parent_line_id
                        ,p_x_line_rec    => l_parent_line_rec
                        ,x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_item_type_code  = OE_GLOBALS.G_ITEM_MODEL THEN
     l_model_actual_ship_date := l_parent_line_rec.actual_shipment_date;
     l_model_qty              := l_parent_line_rec.ordered_quantity;
  END IF;

  -- 3603308
  -- Query to get header_id and order_qty is removed
  l_header_id := l_parent_line_rec.header_id;
  l_queried_quantity := l_parent_line_rec.ordered_quantity;

  IF l_new_quantity <> FND_API.G_MISS_NUM  THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('New Quantity is not missing');
     END IF;
     l_new_quantity := l_queried_quantity;
  END IF;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Before opening cursor...',3);
     oe_debug_pub.add('Hdr ID:'||l_header_id,3);
     oe_debug_pub.add('Proj:'||l_project_id||' Task Id:'||l_task_id,3);
     oe_debug_pub.add('New Qty:'||l_new_quantity,3);
     oe_debug_pub.add('Parent Line:'||p_parent_line_id,3);
  END IF;

  -- actual processing starts.

  l_line_count := 0;
  OPEN children ;
  LOOP
    FETCH children into child_line_id, l_inv_item_id,
          l_ordered_qty, l_child_item_type, l_shipped_qty;
    EXIT when children%NOTFOUND;

        l_line_count                 := l_line_count + 1;
        l_line_rec                   := OE_ORDER_PUB.G_MISS_LINE_REC;
        l_line_rec.line_id           := child_line_id;
        l_line_rec.inventory_item_id := l_inv_item_id;
        l_line_rec.ordered_quantity  := l_ordered_qty;
        l_line_rec.shipped_quantity  := l_shipped_qty;
        l_line_rec.item_type_code    := l_child_item_type;
        l_line_tbl(l_line_count)     := l_line_rec;
  END LOOP;

  IF l_line_count = 0 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONFIG_UTIL.CASCADE_CHANGES' , 1);
      oe_debug_pub.add('NO ROWS TO CASCADE' , 2 );
    END IF;
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NO OF LINES TO CASCADE: '
                      || L_LINE_TBL.COUNT || P_REQUEST_REC.PARAM13 , 2 );
    oe_debug_pub.add(L_NEW_QUANTITY || ' ' || L_ITEM_TYPE_CODE , 1);
  END IF;

  IF l_new_quantity = 0 AND
     (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
      l_item_type_code = OE_GLOBALS.G_ITEM_KIT)
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('DO NOT SUPRESS SCHEDULING' , 3 );
    END IF;
    l_set_zero := 'Y';
  END IF;

  FOR I IN 1..l_line_tbl.count LOOP

    -- 1. ordered quantity

    IF l_new_quantity = 0    AND
       p_request_rec.param13 = 'N' AND
       (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
        l_item_type_code = OE_GLOBALS.G_ITEM_KIT)
    THEN
      IF l_line_tbl(I).item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NEW QTY 0 ,NOT CANCELLATION ,SO DELETE',1);
        END IF;
        l_line_tbl(I).operation  := OE_GLOBALS.G_OPR_DELETE;
      ELSE
        l_line_tbl(I).operation  := OE_GLOBALS.G_OPR_NONE;
      END IF;

    ELSE -- cancellation

      l_line_tbl(I).OPERATION := OE_GLOBALS.G_OPR_UPDATE;

      -- if qty becomes 0, the options will get cancelled eventually.
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('REGULAR CODE , BIG ELSE' , 1);
      END IF;

      IF (l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CONFIG AND
          l_new_quantity = 0)
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('DO NOT CASCADE' , 3 );
        END IF;
        l_line_tbl(I).operation  := OE_GLOBALS.G_OPR_NONE;
      ELSE

        IF  l_old_quantity <> l_new_quantity AND
            (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
             l_item_type_code = OE_GLOBALS.G_ITEM_KIT)
        THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('CASCADE_CHANGES , OLD_ORD_QTY: '
                             ||L_LINE_TBL (I).ORDERED_QUANTITY , 2 );
          END IF;

          l_line_tbl(I).ordered_quantity  :=
             (l_line_tbl(I).ordered_quantity/l_old_quantity) * l_new_quantity;

          /* Start Audit Trail */
          l_line_tbl(I).change_reason    := 'SYSTEM';
          /* End Audit Trail */

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_LINE_TBL (I).LINE_ID||':'
                             ||L_LINE_TBL (I).INVENTORY_ITEM_ID , 2 );
            oe_debug_pub.add('NEW_ORD_QTY: '
                             ||L_LINE_TBL (I).ORDERED_QUANTITY , 2 );
          END IF;
        END IF;

      END IF; -- qry cancellation cascade


      -- 2. project and task.

      IF nvl(l_project_id, -1) <> FND_API.G_MISS_NUM THEN
         l_line_tbl(I).project_id        := l_project_id;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('PROJECT_ID CASCADED, L_LINE_TBL (I).LINE_ID: '
                             || L_PROJECT_ID , 2 );
         END IF;
      END IF;

      IF nvl(l_task_id, -1) <> FND_API.G_MISS_NUM THEN
         l_line_tbl(I).task_id := l_task_id;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('TASK_ID CASCADED FOR,L_LINE_TBL (I).LINE_ID: '
                             || L_TASK_ID , 2 );
         END IF;
      END IF;


      -- 3. ship_tolerance_above and below

      IF nvl(l_ship_tolerance_above, -1) <> FND_API.G_MISS_NUM THEN
         l_line_tbl(I).ship_tolerance_above  := l_ship_tolerance_above;
      END IF;

      IF nvl(l_ship_tolerance_below, -1) <> FND_API.G_MISS_NUM THEN
         l_line_tbl(I).ship_tolerance_below  := l_ship_tolerance_below;
      END IF;


      -- 4. shipped_quantity and actual_shipment_date

      IF nvl(l_ship_quantity, -1) <> FND_API.G_MISS_NUM THEN
         IF l_line_tbl(I).shipped_quantity is null THEN
           l_line_tbl(I).shipped_quantity  :=
           (l_line_tbl(I).ordered_quantity / l_model_qty) * l_ship_quantity;
            l_line_tbl(I).actual_shipment_date :=  l_model_actual_ship_date;

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('CASCADED SHIPPED QTY , L_LINE_TBL (I).LINE_ID: '
                              || L_LINE_TBL (I).SHIPPED_QUANTITY , 2 );
             oe_debug_pub.add('CASCADED ACT_SHIP_DATE '
                              || L_LINE_TBL (I).ACTUAL_SHIPMENT_DATE , 2 );
          END IF;
        END IF;
      END IF;


      -- 5. ship_to_org_id and request_date

      IF nvl(l_ship_to_org_id, -1)<> FND_API.G_MISS_NUM THEN
         l_line_tbl(I).ship_to_org_id        := l_ship_to_org_id;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SHIP TO CASCADED , LINE_ID: '
                             || L_SHIP_TO_ORG_ID , 2 );
         END IF;
      END IF;

      IF nvl(l_request_date, sysdate) <> FND_API.G_MISS_DATE THEN
         l_line_tbl(I).request_date        := l_request_date;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('REQUEST_DATE CASCADED , REQUEST_DATE: '
                             || L_REQUEST_DATE , 2 );
         END IF;
      END IF;

      -- 6. source_type_code for ato configurations.

      IF nvl(p_request_rec.param15, 'X')<> FND_API.G_MISS_CHAR THEN
         l_line_tbl(I).source_type_code     := p_request_rec.param15;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SOURCE_TYPE CASCADED: '
                            || P_REQUEST_REC.PARAM15 , 2 );
         END IF;
      END IF;


/* Added the following logic to fix the bug 2217336 */
      -- 7. freight_terms_code for ato configurations.

      IF nvl(l_freight_terms_code, 'X')<> FND_API.G_MISS_CHAR THEN
         l_line_tbl(I).freight_terms_code     :=  l_freight_terms_code ;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('FREIGHT_TERMS_CODE CASCADED: '
                             || L_FREIGHT_TERMS_CODE , 2 );
         END IF;
      END IF;

      --  8. Promise date

           IF nvl(l_promise_date, sysdate) <> FND_API.G_MISS_DATE THEN
             l_line_tbl(I).promise_date        := l_promise_date;
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('PROMISE DATE OCASCADED , PROMISE_DATE: '
                                 || L_PROMISE_DATE , 2 );
              END IF;
          END IF;

    END IF; -- if cancellation.

  END LOOP;


  -- Call Process Order to update the record.

  --  Set control flags.

  l_control_rec.controlled_operation := TRUE;
  l_control_rec.change_attributes    := TRUE;
  l_control_rec.default_attributes   := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.check_security       := TRUE;
  l_control_rec.write_to_DB          := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.process              := FALSE;
  l_control_rec.clear_dependents     := TRUE;

  --  Instruct API to retain its caches

  l_control_rec.clear_api_cache      := FALSE;
  l_control_rec.clear_api_requests   := FALSE;

  l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;

  -- Set the Recursive Call Constant to 'Y' to avoid the recursive
  -- call to cascading while making this call to process order

  OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'Y';

  -- Set the Validate_config Call Constant to 'N' to avoid the validation

  OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'N';

  -- Set the scheduling flag to 'N', do not schedule in a recursive call.

  -- bug fix 1607036
  IF l_set_zero = 'N' AND
     nvl(l_parent_line_rec.ship_model_complete_flag, 'Y') <> 'N'
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('SCHEDULE FLAG SET TO N' , 5 );
    END IF;
    -- 4504362
    OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CALLING PROCESS ORDER' , 2 );
  END IF;

  --  Call OE_Order_PVT.Process_order

   OE_ORDER_PVT.Lines
   (p_validation_level         => FND_API.G_VALID_LEVEL_NONE
   ,p_control_rec              => l_control_rec
   ,p_x_line_tbl               => l_line_tbl
   ,p_x_old_line_tbl           => l_old_line_tbl
   ,x_return_status            => l_return_status);


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('IN CASCADE CHANGES AFTER CALLING PROCESS ORDER' , 2 );
    oe_debug_pub.add('L_RETURN_STATUS IS ' || L_RETURN_STATUS , 1);
  END IF;

  -- Resetting the Recursive Call Constant to 'N'
  OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'N';

  -- Resetting the Validation Constant to 'Y'
  OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG := 'Y';

  -- Set it back to 'Y'
  -- 4504362
  OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
  OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- process_order call successful, and this was decrement to 0.
  IF l_set_zero = 'Y'  THEN

    -- Instance Unlocking.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Before calling Unlock_Config for parent line.' , 3 );
    END IF;
    IF l_parent_line_rec.item_type_code = 'MODEL'
    AND l_parent_line_rec.Booked_flag = 'Y' THEN

       Unlock_Config(p_line_rec      => l_parent_line_rec,
                     x_return_status => l_return_status);

        oe_debug_pub.add('After calling Unlock_Config for parent line ' || l_return_status , 3 );
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    -- Instance Unlocking

    UPDATE oe_order_lines
    SET    config_header_id = null,
           config_rev_nbr   = null,
           configuration_id = null,
           lock_control     = lock_control + 1
    WHERE  top_model_line_id = p_parent_line_id;

    IF SQL%FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIG IDS SET TO NULL' , 3 );
      END IF;
    END IF;

    -- delete the SPC configuration data.
    OE_Config_Pvt.Delete_Config
    ( p_config_hdr_id   =>  l_parent_line_rec.config_header_id
     ,p_config_rev_nbr  =>  l_parent_line_rec.config_rev_nbr
     ,x_return_status   =>  l_return_status);

  END IF;

  OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

  /* added for 2653505 */
  IF OE_CODE_CONTROL.get_code_release_level < '110508' THEN
    OE_ORDER_PVT.Process_Requests_And_notify
    ( p_process_requests       => FALSE
     ,p_notify                 => TRUE
     ,x_return_status          => l_return_status
     ,p_line_tbl               => l_line_tbl
     ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.CASCADE_CHANGES' , 1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CASCADE_CHANGES ERROR '|| SQLERRM , 1);
    END IF;
    RAISE;
END;


/*----------------------------------------------------------------------
Procedure Name : Query_Config_Line
Description    :
-----------------------------------------------------------------------*/

PROCEDURE Query_Config_Line
(p_parent_line_id IN NUMBER
,x_line_rec       OUT NOCOPY OE_ORDER_PUB.line_rec_type)
IS
 l_line_rec   OE_ORDER_PUB.line_rec_type;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
 x_line_rec := l_line_rec;
END;

/*------------------------------------------------------------------------
Procedure Name : Change_Configuration
Description    : This procedure will change certain attributes across
                 the whole configuration, when the attribute is changed
                 even on one line of the configuration.
                 E.g.: If the warehouse changes on a ATO option, all the
                       lines of the ATO model should reflect the same
                       warehouse. Same is true if the change took place
                       on an option of a Ship model complete PTO.
                       The attributes which we currently maintain same
                       across an ATO or a SMC PTO are:
                       1. Ship From Org
                       2. Ship To Org
                       3. Request Date
                       4. Schedule Ship Date
                This procedure will be called only if the line is not
                scheduled. If the line is scheduled and any of the above
                attributes change, then scheduling code will take
                care of change across the configuration.
------------------------------------------------------------------------ */

Procedure Change_Configuration
( p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)

IS
-- params sent in request rec.
l_changed_line_rec              OE_ORDER_PUB.Line_Rec_Type;
l_top_model_line_id             NUMBER;
l_ato_line_id                   NUMBER;
l_line_id                       NUMBER;
l_count                         NUMBER:=0;
l_header_id                     NUMBER := 0;

-- Process Order Variables
l_control_rec                   OE_GLOBALS.Control_Rec_Type;
l_header_rec                    OE_Order_PUB.Header_Rec_Type;
l_line_rec                      OE_ORDER_PUB.Line_Rec_Type
                                := OE_ORDER_PUB.G_MISS_LINE_REC;
l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;

l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    CURSOR configuration_line(p_header_id         IN NUMBER,
                              p_top_model_line_id IN NUMBER,
                              p_ato_line_id       IN NUMBER,
                              p_line_id           IN NUMBER)
    IS
    SELECT line_id
    FROM   oe_order_lines
    WHERE((top_model_line_id = p_top_model_line_id
           and line_id <> p_line_id)
    OR    (ato_line_id  = p_ato_line_id and
           line_id <> p_line_id ))
    AND    open_flag = 'Y';

-- parent_line_id is either top_model_line_id for models and kits
-- or it can be class only for ato sub configs
-- in 2nd case we will get children using ato_line_id as a link.

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONGIG_UTIL.CHANGE_CONFIGURATION' , 1);
   END IF;

   -- insted of modifying cursor, querying the line,
   -- so that code remains clean.

   OE_LINE_UTIL.Lock_Row(p_line_id       => p_request_rec.param1,
                         p_x_line_rec    => l_changed_line_rec,
                         x_return_status => l_return_status);

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_line_id   := l_changed_line_rec.line_id;
   l_header_id := l_changed_line_rec.header_id;

   IF nvl(l_changed_line_rec.ship_model_complete_flag,'N') = 'N' THEN
      l_ato_line_id       := l_changed_line_rec.ato_line_id;
      l_top_model_line_id := null;
   ELSE
      l_top_model_line_id := l_changed_line_rec.top_model_line_id;
      l_ato_line_id       := null;
   END IF;

   OPEN configuration_line(l_header_id,
                           l_top_model_line_id,
                           l_ato_line_id,
                           l_line_id);
   LOOP
      FETCH configuration_line into l_line_id;
      EXIT when configuration_line%NOTFOUND;
      l_line_rec                  := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_rec.line_id          := l_line_id;
      l_line_rec.ship_from_org_id := l_changed_line_rec.ship_from_org_id;
      l_line_rec.ship_to_org_id   := l_changed_line_rec.ship_to_org_id;
      l_line_rec.request_date     := l_changed_line_rec.request_date;
      l_line_rec.shipping_method_code
         := l_changed_line_rec.shipping_method_code;
      l_line_rec.freight_carrier_code
         := l_changed_line_rec.freight_carrier_code;
      l_line_rec.shipment_priority_code
         := l_changed_line_rec.shipment_priority_code;
      l_line_rec.demand_class_code := l_changed_line_rec.demand_class_code;

      -- Start Audit Trail
      l_line_rec.change_reason    := 'SYSTEM';
      -- End Audit Trail

      l_line_rec.OPERATION        := OE_GLOBALS.G_OPR_UPDATE;
      l_count                     := l_count + 1;
      l_line_tbl(l_count)         := l_line_rec;
   END LOOP;

   IF l_count = 0 THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('EXITING OE_CONGIG_UTIL.CHANGE_CONFIGURATION' , 1);
         oe_debug_pub.add('NO ROWS TO PASS TO PROCESS_ORDER' , 2 );
      END IF;
      RETURN;
   END IF;

   -- Call Process Order to update the record.

   --  Set control flags.

   l_control_rec.controlled_operation := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.check_security       := TRUE; --FALSE;
   l_control_rec.write_to_DB          := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.process              := FALSE;
   l_control_rec.clear_dependents     := TRUE;

   --  Instruct API to retain its caches

   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;

   l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;

   -- Set the Change Configuration flag 'N' to avoid the recursive
   -- call to changin configuration while making this call to process order
   OE_GLOBALS.G_CHANGE_CFG_FLAG := 'N';

   -- Set recursion mode.
   -- OE_GLOBALS.G_RECURSION_MODE := 'Y';

   -- Set the scheduling flag to 'N', do not schedule in a recursive call.
   -- 4504362
   OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
   OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING PROCESS ORDER WITH LINES: '
                       || L_LINE_TBL.COUNT , 2 );
   END IF;

   OE_ORDER_PVT.Lines
      (p_validation_level         => FND_API.G_VALID_LEVEL_NONE
       ,p_control_rec              => l_control_rec
       ,p_x_line_tbl               => l_line_tbl
       ,p_x_old_line_tbl           => l_old_line_tbl
       ,x_return_status            => l_return_status);


   -- Set it back to 'Y'
   -- 4504362
   OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
   OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

   -- Resetting the Change Configuration flag 'Y'
   OE_GLOBALS.G_CHANGE_CFG_FLAG := 'Y';

   -- Resetting the Recursive Call Constant to 'N'
   OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG := 'N';

   -- ReSet recursion mode.
   --OE_GLOBALS.G_RECURSION_MODE := 'N';

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- added for 2653505
   IF OE_CODE_CONTROL.get_code_release_level < '110508' THEN
      OE_ORDER_PVT.Process_Requests_And_notify
         ( p_process_requests       => FALSE
           ,p_notify                 => TRUE
           ,x_return_status          => l_return_status
           ,p_line_tbl               => l_line_tbl
           ,p_old_line_tbl           => l_old_line_tbl);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- Setting G_CASCADING_REQUEST_LOGGED to requery the lines in the form
   -- not reqd, done in vreqb.
   OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

   x_return_status := l_return_status;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONGIG_UTIL.CHANGE_CONFIGURATION' , 1);
   END IF;

END Change_Configuration;

/*----------------------------------------------------------------------
Procedure Name : Delink_Config
Description    :
-----------------------------------------------------------------------*/
Procedure Delink_Config
( p_line_id         IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

-- process_order in variables
l_control_rec                   OE_GLOBALS.Control_Rec_Type;
l_header_rec                    OE_Order_PUB.Header_Rec_Type;
l_line_rec                      OE_ORDER_PUB.Line_Rec_Type
                                := OE_ORDER_PUB.G_MISS_LINE_REC;
l_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;

l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);

l_line_num        VARCHAR2(20);
l_po_header_id    NUMBER;
--bug 4411054
--l_po_status             VARCHAR2(4100);
l_po_status_rec         PO_STATUS_REC_TYPE;
l_autorization_status   VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     OE_LINE_UTIL.Lock_Row(p_line_id       => p_line_id
                          ,p_x_line_rec    => l_line_rec
                          ,x_return_status => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONGIG_UTIL.DELINK_CONFIG' , 1);
    END IF;

    -- Changes for Enhanced DropShipments. Prevent Delink
    -- if the PO associated with config item is Approved.

    -- #5252929, the following PO-APPROVED check is now disabled.  Now the
    -- check is done only when user chooses Action->Delink from the SO pad
    -- and that check is done in OEXOECFG.pld.
    -- Here we donot want to check becuase the constraint check is already
    -- done at the Model level.   If the user disables that constarint then
    -- the delink should take place.  Please see bug for further details.

   /*  IF PO_CODE_RELEASE_GRP.Current_Release >=
       PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
            OE_CODE_CONTROL.Get_Code_Release_Level  >= '110510' AND
                              l_line_rec.source_type_code = 'EXTERNAL' THEN

         BEGIN
              SELECT po_header_id
              INTO   l_po_header_id
              FROM   oe_drop_ship_sources
              WHERE  line_id    = l_line_rec.line_id
              AND    header_id  = l_line_rec.header_id;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   IF l_debug_level  > 0 THEN
                      OE_DEBUG_PUB.Add('PO Not Created for Config.:'||
                                                  l_line_rec.line_id , 2 );
                   END IF;
         END;

         IF l_po_header_id is not null THEN

               PO_DOCUMENT_CHECKS_GRP.po_status_check
                                (p_api_version => 1.0
                                , p_header_id => l_po_header_id
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);

               IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                    l_autorization_status := l_po_status_rec.authorization_status(1);

                    IF l_debug_level > 0 THEN
                        OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
               	 	OE_DEBUG_PUB.Add('Check PO Status : '|| l_autorization_status, 2);
             	     END IF;
       		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
       		END IF;

         END IF;

         --IF (INSTR(nvl(l_po_status,'z'), 'APPROVED') <> 0 ) THEN
         IF (nvl(l_autorization_status,'z')= 'APPROVED') THEN
              l_line_num :=  RTRIM(l_line_rec.line_number||'.'||
                             l_line_rec.shipment_number||'.'||
                             l_line_rec.option_number||'.'||
                             l_line_rec.component_number||'.'||
                             l_line_rec.service_number,'.');
              FND_MESSAGE.Set_Name('ONT', 'ONT_DELINK_NOT_ALLOWED');
              FND_MESSAGE.Set_Token('LINE_NUM', l_line_num);
              FND_MESSAGE.Set_Token('MODEL', l_line_rec.ordered_item);
              OE_MSG_PUB.Add;
              RETURN;
         END IF;

     END IF; */

     l_line_rec           := OE_ORDER_PUB.G_MISS_LINE_REC;
     l_line_rec.line_id   := p_line_id;
     l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_line_tbl(1)        := l_line_rec;

    -- check_security is made false so that
    -- we can delete the config line overriding the constraint.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.check_security       := FALSE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.clear_dependents     := TRUE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' ' , 3 );
      oe_debug_pub.add('IN DELINK_CONFIG CALLING PROCESS ORDER' , 3 );
      oe_debug_pub.add('IN DELINK_CONFIG AFTER CALL TO PROCESS ORDER' , 3 );
      oe_debug_pub.add('L_RETURN_STATUS IS: ' || L_RETURN_STATUS , 2 );
    END IF;

   OE_ORDER_PVT.Lines
   (p_validation_level         => FND_API.G_VALID_LEVEL_NONE
   ,p_control_rec              => l_control_rec
   ,p_x_line_tbl               => l_line_tbl
   ,p_x_old_line_tbl           => l_old_line_tbl
   ,x_return_status            => l_return_status);


    -- count and get
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('STATUS:' || L_RETURN_STATUS , 3 );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('STATUS:' || L_RETURN_STATUS , 3 );
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Call Notify OC, required ****************************

   OE_ORDER_PVT.Process_Requests_And_notify
    (p_process_requests       => TRUE
    ,p_notify                 => TRUE
    ,x_return_status          => l_return_status
    ,p_line_tbl               => l_line_tbl
    ,p_old_line_tbl           => l_old_line_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  oe_msg_pub.count_and_get
  ( p_count      => l_msg_count
   ,p_data       => l_msg_data  );

    -- if everything is OK.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('IN OE_CONFIG_UTI.DELINK , X_RETURN_STATUS'
                      ||X_RETURN_STATUS , 2 );
    oe_debug_pub.add('EXITING OE_CONGIG_UTIL.DELINK_CONFIG' , 1);
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        oe_msg_pub.count_and_get
        ( p_count   => l_msg_count
        ,   p_data    => l_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
        oe_msg_pub.count_and_get
        ( p_count   => l_msg_count
        ,   p_data    => l_msg_data
        );

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('ERROR: ' || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
        END IF;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            ( G_PKG_NAME
            ,   'Oe_Config_Util'
            );
        END IF;

        --  Get message count and data
        oe_msg_pub.count_and_get
        ( p_count    => l_msg_count
        ,   p_data     => l_msg_data
        );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delink_Config;



/*----------------------------------------------------------------------
Procedure Name : Validate_Cfgs_In_Order
Description    : checks if the models in the order
                 are complete and valid
-----------------------------------------------------------------------*/
FUNCTION Validate_Cfgs_In_Order(p_header_id IN NUMBER)
RETURN VARCHAR2
IS
  l_line_id             number := null;
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_valid_config        VARCHAR2(10);
  l_complete_config     VARCHAR2(10);

  -- Instance locking changes

  l_booked_flag         VARCHAR2(1);
  l_config_header_id    NUMBER;
  l_config_rev_nbr      NUMBER;
  l_configuration_id    NUMBER;
  l_top_container       VARCHAR2(1);
  l_part_of_container   VARCHAR2(1);
  l_locking_key         NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_order_number        NUMBER;

  -- Instance locking changes.

  CURSOR models is
  SELECT line_id,config_header_id,config_rev_nbr,
         configuration_id,booked_flag
  FROM   oe_order_lines
  WHERE  item_type_code = OE_GLOBALS.G_ITEM_MODEL
  AND    header_id = p_header_id
  AND    open_flag = 'Y';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONGIG_UTIL.VALIDATE_CFGS_IN_ORDER' , 1);
  END IF;
  --get_transaction_id(p_caller   => 'before validate_cfgs');

  OPEN models;

  LOOP
    FETCH models
    into l_line_id,l_config_header_id,l_config_rev_nbr,
         l_configuration_id,l_booked_flag;

    EXIT WHEN MODELS%NOTFOUND;

    Oe_Config_Util.validate_configuration
                ( p_model_line_id      => l_line_id,
                  p_validate_flag      => 'Y',
                  p_complete_flag      => 'Y',
                  p_caller             => 'BOOKING',
                  x_valid_config       => l_valid_config,
                  x_complete_config    => l_complete_config,
                  x_return_status      => l_return_status);

    -- if the valid or complete flag is false, we error out.

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --get_transaction_id(p_caller   => 'after call to validate_cfgs');
      RETURN l_return_status ;
    ELSE
       IF LOWER(l_valid_config) = 'false' OR
          LOWER(l_complete_config) = 'false' THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('RETURN_STATUS SUCCESS,BUT INVALID/INCOMPLETE',2);
          END IF;
          RETURN FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    -- Instance locking
    IF l_booked_flag = 'Y' THEN

      IF l_debug_level  > 0 THEN

         oe_debug_pub.add(' Before calling Is part of container model ' || l_line_id,  2);

      END IF;

      OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
       (  p_line_id             => l_line_id
         ,p_top_model_line_id   => l_line_id
         ,x_top_container_model => l_top_container
         ,x_part_of_container   => l_part_of_container  );

       IF l_top_container = 'Y' THEN

           -- BV code must have changed the rev number. Therefore we have to
           -- re-fetch the value to pass it to lock api.
           BEGIN
            Select config_rev_nbr
            Into   l_config_rev_nbr
            From   oe_order_lines_all
            Where  line_id = l_line_id;
           END;

           l_order_number := OE_SCHEDULE_UTIL.Get_Order_Number(p_header_id);

           IF l_debug_level  > 0 THEN

            oe_debug_pub.add(' Calling lock_Config' || l_config_header_id,  2);
            oe_debug_pub.add(' Config rev nbr' || l_config_rev_nbr,  2);
            oe_debug_pub.add(' Configuration_id ' || l_configuration_id,  2);
            oe_debug_pub.add(' Order Number  ' || l_order_number,  2);

          END IF;

          CZ_IB_LOCKING.Lock_Config
          ( p_api_version            => 1.0,
            p_config_session_hdr_id  => l_config_header_id,
            p_config_session_rev_nbr => l_config_rev_nbr,
            p_config_session_item_id => Null,
            p_source_application_id  => fnd_profile.value('RESP_APPL_ID'),
            p_source_header_ref      => l_order_number,
            p_source_line_ref1       => Null,
            p_source_line_ref2       => Null,
            p_source_line_ref3       => Null,
            p_commit                 => 'N',
            p_init_msg_list          => FND_API.G_TRUE,
            p_validation_level       => Null,
            x_locking_key            => l_locking_key,
            x_return_status          => l_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(' After calling CZ lock API ' || l_return_status || l_msg_data,2);
            END IF;
            IF l_msg_count > 0 THEN
                  OE_MSG_PUB.Transfer_Msg_stack;

            END IF;
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RETURN l_return_status;
            END IF;

       END IF; -- Container
     END IF; -- Booked Flag
      -- Instance locking.
  END LOOP;

  CLOSE models;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING VALIDATE_CFGS_IN_ORDER:' || L_RETURN_STATUS ,2);
    oe_debug_pub.add('EXITING OE_CONGIG_UTIL.VALIDATE_CFGS_IN_ORDER' , 1);
  END IF;
  --get_transaction_id(p_caller   => 'leaving validate_cfgs');

  RETURN l_return_status;
END Validate_Cfgs_In_Order;

/*----------------------------------------------------------------------
Procedure Name : Freeze_Inc_Items_For_Order
Description    :

Change Record:
  Calling process_included_items directly w/o call to
freeze_included_items.
-----------------------------------------------------------------------*/
FUNCTION Freeze_Inc_Items_for_Order(p_header_id IN NUMBER)
RETURN VARCHAR2
IS
  l_line_id                   NUMBER;
  l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  CURSOR order_lines is
  SELECT line_id
  FROM   oe_order_lines
  WHERE  item_type_code in (OE_GLOBALS.G_ITEM_MODEL,
                            OE_GLOBALS.G_ITEM_CLASS,
                            OE_GLOBALS.G_ITEM_KIT)
  AND    open_flag = 'Y'
  AND    header_id = p_header_id;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.FREEZE_INC_ITEMS_FOR_ORDER' , 1);
  END IF;

  OPEN order_lines;

  LOOP
    FETCH order_lines
    into l_line_id;
    EXIT WHEN ORDER_LINES%NOTFOUND;

    l_return_status := Oe_Config_Util.Process_included_items
                       ( p_line_id  => l_line_id
                        ,p_freeze   => TRUE);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN l_return_status ;
    END IF;
  END LOOP;

  CLOSE order_lines;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING FREEZE_INC_ITEMS_FOR_ORDER:'
                     || L_RETURN_STATUS , 2 );
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.FREEZE_INC_ITEMS_FOR_ORDER' , 1);
  END IF;
  RETURN l_return_status;
END Freeze_Inc_Items_for_Order;

/*----------------------------------------------------------------------
Procedure Name : Validate_Configuration_upg

----------------------------------------------------------------------*/

PROCEDURE Validate_Configuration_upg
(p_model_line_id       IN     NUMBER,
 x_return_status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS
  l_valid_config             VARCHAR2(10);
  l_complete_config          VARCHAR2(10);
  l_return_status            VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  Oe_Config_Util.Validate_Configuration
  (p_model_line_id       => p_model_line_id,
   x_valid_config        => l_valid_config,
   x_complete_config     => l_complete_config,
   x_return_status       => l_return_status);

   x_return_status := l_return_status;
END;


/*----------------------------------------------------------------------
forward declarations
----------------------------------------------------------------------*/

PROCEDURE Complete_Configuration
(p_top_model_line_id     IN  NUMBER,
 x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE Cascade_Qty
( p_x_options_tbl  IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_component_code  IN VARCHAR2
 ,p_ratio           IN NUMBER
  -- 4211654
 ,p_new_qty         in number
 ,p_old_qty         in number
 ,p_change_reason   IN VARCHAR2
 ,p_change_comments IN VARCHAR2);


PROCEDURE Delete_Children
(p_x_options_tbl  IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code IN VARCHAR2
,p_parent_item    IN VARCHAR2);


PROCEDURE Delete_Parent
(p_x_options_tbl      IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag             IN   VARCHAR2 := 'N');


FUNCTION No_More_Children_Left
(p_x_options_tbl      IN Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag            IN VARCHAR2 := 'N')
RETURN BOOLEAN;


PROCEDURE Propogate_Change_To_Parent
(p_x_options_tbl      IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag            IN VARCHAR2 := 'N');


PROCEDURE Message_From_Cz
(p_line_id            IN NUMBER
,p_valid_config       IN VARCHAR2
,p_complete_config    IN VARCHAR2
,p_config_header_id   IN NUMBER
,p_config_rev_nbr     IN NUMBER);

/*----------------------------------------------------------------------
PROCEDURE: Configurator_Validation
Description    : checks if the configuration is complete/valid
                 returns success/error as status. It calls
                 send_input_xml : to send the configuration coptions to SPC
                 parse_output_xml : parse output of SPC to see if
                                    configuration is valid/complete
                 process_config : to save options in oe_order_lines

                 now that we have decided that we will treat invalid
                 configuration in the same way as incomplete configuration,
                 the arguments p_validate_flag and p_complete_flag do not
                 have a lot of meaning. We might remove them for the procedure.
                 We will save invali as well as incomplete configurations
                 in oe_order_lines before booking.
                 After booking we will put model on hold if configuraion
                 becomes invalid/incomplete.
-----------------------------------------------------------------------*/
PROCEDURE Configurator_Validation
(p_model_line_id       IN     NUMBER,
 p_deleted_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_updated_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_caller              IN     VARCHAR2 := '',
 x_valid_config        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_complete_config     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_return_status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
      l_header_id              NUMBER := NULL;
      l_model_line_id          NUMBER := p_model_line_id;
      l_model_line_rec         OE_ORDER_PUB.line_rec_type;

      l_updated_options_tbl    OE_Order_PUB.request_tbl_type
                               := p_updated_options_tbl;
      l_deleted_options_tbl    OE_Order_PUB.request_tbl_type
                               :=p_deleted_options_tbl;

      l_config_header_id       NUMBER;
      l_config_rev_nbr         NUMBER;
      l_valid_config           VARCHAR2(10):= 'true';
      l_complete_config        VARCHAR2(10):= 'true';
      l_change_flag            VARCHAR2(1) := 'N';
      l_booked_flag            VARCHAR2(1) := 'N';
      l_model_qty              NUMBER;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_result_out             VARCHAR2(30);
      l_options_tbl
                       Oe_Process_Options_Pvt.Selected_Options_Tbl_Type;
      -- input xml message
      l_xml_message            LONG   := NULL;
      l_xml_hdr                VARCHAR2(2000);

      -- upgrade stuff
      l_upgraded_flag          VARCHAR2(1);
      l_source_document_type_id  NUMBER;
      l_order_source_id          NUMBER;

      -- cz's delete return value
      l_return_status_del      VARCHAR2(1);

      -- cz_verify output
      l_any_insert             NUMBER := 0;
      l_exists_flag            VARCHAR2(1) := FND_API.G_TRUE;
      l_complete_flag          VARCHAR2(1) := FND_API.G_TRUE;
      l_valid_flag             VARCHAR2(1) := FND_API.G_TRUE;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING CONFIGURATOR_VALIDATION' , 1);
      oe_debug_pub.add('QUERYING MODEL LINE' , 3 );
    END IF;

    BEGIN
      SELECT header_id, ordered_quantity, booked_flag,
             upgraded_flag,  config_header_id, config_rev_nbr,
             source_document_type_id,order_source_id
      INTO   l_header_id, l_model_qty, l_booked_flag,
             l_upgraded_flag ,l_config_header_id, l_config_rev_nbr,
             l_source_document_type_id, l_order_source_id
      FROM   OE_ORDER_LINES
      WHERE  line_id = p_model_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    l_booked_flag := nvl(l_booked_flag, 'N');
    l_upgraded_flag := nvl(l_upgraded_flag, 'N');

    ------------- upgrade stuff ---------------

    BEGIN
       IF ( l_upgraded_flag = 'Y'     OR
            l_upgraded_flag = 'P' )   AND
          (l_config_header_id is null AND
           l_config_rev_nbr is null)  AND
           Oe_Config_Util.G_Upgraded_Flag = 'N'
       THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('UPGRADE THE CONFIGURAION' , 2 );
         END IF;

         Oe_Config_Util.G_Upgraded_Flag := 'Y';

         Configurator_Validation
         (p_model_line_id       => p_model_line_id,
          x_valid_config        => l_valid_config,
          x_complete_config     => l_complete_config,
          x_return_status       => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_UPGARDE_ERROR');
           OE_Msg_Pub.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_UPGARDE_ERROR');
           OE_Msg_Pub.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('CONFIGURAION GOT UPGRADED' , 2 );
         END IF;
       END IF;
    END;


    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('REV NBR ' ||L_CONFIG_REV_NBR );
       oe_debug_pub.add('CONF HDR ID' ||L_CONFIG_HEADER_ID );
       oe_debug_pub.add('BOOKED FLAG ' || L_BOOKED_FLAG );
    END IF;

    --  Check if there is any INSERT option operation being
    --  performed on an existing Model

    IF l_booked_flag  = 'N' THEN

      SELECT count (*)
      INTO  l_any_insert
      FROM  OE_ORDER_LINES
      WHERE top_model_line_id = p_model_line_id
      AND   line_id <> p_model_line_id
      AND   config_header_id IS NULL
      AND   config_rev_nbr  IS NULL;

      IF l_debug_level  > 0 THEN
        OE_Debug_Pub.Add('lines w/o cfg hdr '|| l_any_insert, 3);
        OE_Debug_Pub.Add('Order Level Copy '||OE_ORDER_COPY_UTIL.G_ORDER_LEVEL_COPY, 3);
      END IF;

      IF l_any_insert = 0 THEN

        BEGIN
          SELECT 1
          INTO   l_any_insert
          FROM   cz_config_details_v cz, oe_order_lines oe
          WHERE  oe.line_id = p_model_line_id
          AND    oe.ordered_quantity <> cz.quantity
          AND    oe.config_header_id = cz.config_hdr_id
          AND    oe.config_rev_nbr   = cz.config_rev_nbr
          AND    oe.component_code   = cz.component_code;

          IF l_debug_level  > 0 THEN
            OE_Debug_Pub.Add('yes, need to call batch val for model qty',3);
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
              OE_Debug_Pub.Add('no need to call batch val for model qty',3);
            END IF;
          WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'QTY SELECT: '|| SQLERRM , 1 ) ;
            END IF;
            RAISE;
        END;
      END IF; -- model qty check

    END IF; -- booked flag and new inserts check.

    IF l_booked_flag  = 'N' AND
       l_updated_options_tbl.COUNT =  0 AND
       l_deleted_options_tbl.COUNT =  0 AND
       l_any_insert = 0   AND
       OE_ORDER_COPY_UTIL.G_ORDER_LEVEL_COPY <> 1 AND
       l_config_rev_nbr is not null AND
       l_config_header_id is not null
    THEN
       IF l_debug_level  > 0 THEN
         OE_Debug_Pub.Add('Skip Batch Validation ');
       END IF;

       CZ_CONFIG_API_PUB.verify_configuration
       ( p_api_version        => 1.0,
         p_config_hdr_id      => l_config_header_id,
         p_config_rev_nbr     => l_config_rev_nbr,
         x_exists_flag        => l_exists_flag,
         x_valid_flag         => l_valid_flag,
         x_complete_flag      => l_complete_flag,
         x_return_status      => l_return_status,
         x_msg_count          => l_msg_count,
         x_msg_data           => l_msg_data );

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add (' Exists Flag :' ||l_exists_flag,2);
         oe_debug_pub.add (' Valid Flag :'|| l_valid_flag,2);
         oe_debug_pub.add (' Complete Flag :'|| l_complete_flag,2);
         oe_debug_pub.add (' Return Status :'|| l_return_status,2);
         oe_debug_pub.add (' Message Count :'|| l_msg_count,2);
         oe_debug_pub.add (' Message Data  :'|| l_msg_data,2);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN

         IF l_exists_flag = FND_API.G_FALSE THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Configuration Does not Exist '|| l_msg_data,2);
           END IF;
           RAISE FND_API.G_EXC_ERROR;

         ELSE
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add  (' Configuration Exists ',2);
           END IF;

           IF l_valid_flag  = FND_API.G_FALSE THEN
              l_valid_config := 'FALSE';
           ELSE
              l_valid_config := 'TRUE';
           END IF;

           IF l_complete_flag = FND_API.G_FALSE THEN
              l_complete_config := 'FALSE';
           ELSE
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Configuration Exists, valid and Complete ',2);
             END IF;
             l_complete_config := 'TRUE';
           END IF;
         END IF; -- if exist flag = false
       END IF; -- if success

       Message_From_Cz
       ( p_line_id           => l_model_line_id,
         p_valid_config      => l_valid_config,
         p_complete_config   => l_complete_config,
         p_config_header_id  => l_config_header_id,
         p_config_rev_nbr    => l_config_rev_nbr);

    ELSE -- call batch val

      -- create xml initialization message,
      -- then we send it along with options to SPC
      -- then we parse the o/p xml from  SPC to get
      -- batch validation results
      -- Check if the user has already performed configurator validation
      -- If the call is from Order Import and not BOOKING then skip the
      -- Configurator BATCH Validation (bug 2560933)

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CALLING CREATE_HDR_XML' , 2 );
        oe_debug_pub.add('--------INITIALIZATION MESSAGE------------' , 2 );
      END IF;

      Create_hdr_xml
      ( p_model_line_id        => p_model_line_id ,
        x_xml_hdr              => l_xml_hdr);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('------AFTER CREATE INITIALIZATION MESSAGE----' , 2 );
        oe_debug_pub.add('CALLING SEND_INPUT_XML' , 2 );
      END IF;

      Send_Input_xml
      ( p_model_line_id        => l_model_line_id,
        p_deleted_options_tbl  => l_deleted_options_tbl,
        p_updated_options_tbl  => l_updated_options_tbl,
        p_model_qty            => l_model_qty,
        p_xml_hdr              => l_xml_hdr,
        x_out_xml_msg          => l_xml_message,
        x_return_status        => l_return_status );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('AFTER CALLING SEND_INPUT_XML: '||L_RETURN_STATUS , 2 );
      END IF;
      --get_transaction_id(p_caller   => 'after send_xml');

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;

      END IF;


      l_xml_message := UPPER(l_xml_message);

      -- extract data from xml message.

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('CALLING PARSE_OUTPUT_XML' , 2 );
       END IF;

      Parse_Output_xml
      ( p_xml               => l_xml_message,
        p_line_id           => l_model_line_id,
        x_valid_config      => l_valid_config,
        x_complete_config   => l_complete_config,
        x_config_header_id  => l_config_header_id,
        x_config_rev_nbr    => l_config_rev_nbr,
        x_return_status     => l_return_status );

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('AFTER CALLING PARSE_XML: '||L_RETURN_STATUS , 2 );
        END IF;

        x_valid_config    := l_valid_config;
        x_complete_config := l_complete_config;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;  -- if skip batch val

    x_valid_config    := l_valid_config;
    x_complete_config := l_complete_config;

    IF p_caller = 'BOOKING' AND
       (l_valid_config = 'FALSE' OR
        l_complete_config = 'FALSE') THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLER IS BOOKING AND ERRORED OUT' , 2 );
        END IF;

        x_return_status   := l_return_status;
        RETURN;
    END IF;


    -- if the order id booked, we want to put hold on the model line
    -- if the configuration is invalid or incomplete. Also we want
    -- to release the hold, if the configuration becomes valid and complete
    -- after this particular change.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('IS THIS IS A BOOKED ORDER , IF SO PUT HOLD: '
                         ||L_BOOKED_FLAG , 2 );
    END IF;

    IF l_booked_flag = 'Y' THEN

        OE_Config_Pvt.put_hold_and_release_hold
        (p_header_id       => l_header_id,
         p_line_id         => l_model_line_id,
         p_valid_config    => l_valid_config,
         p_complete_config => l_complete_config,
         x_msg_count       => l_msg_count,
         x_msg_data        => l_msg_data,
         x_return_status   => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    -- call to process_config to insert new valid and complete confiuration

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('------- CALLING PROCESS_CONFIG -----------' , 2 );
    END IF;

    OE_Config_Pvt.Process_Config
    ( p_header_id          => l_header_id
     ,p_config_hdr_id      => l_config_header_id
     ,p_config_rev_nbr     => l_config_rev_nbr
     ,p_top_model_line_id  => l_model_line_id
     ,p_ui_flag            => 'N'
     ,x_change_flag        => l_change_flag
     ,x_msg_count          => l_msg_count
     ,x_msg_data           => l_msg_data
     ,x_return_status      => l_return_status );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('AFTER CALL TO PROCESS_CONFIG: '
                         ||L_RETURN_STATUS , 2 );
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('PROCESS CONFIG UNEXPECTED ERROR' , 2 );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('PROCESS CONFIG EXEC ERROR' , 2 );
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    -- If you are here, things went off OK ! So return success
    x_return_status   := l_return_status;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING CONFIGURATOR_VALIDATION' , 1);
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN CONFIGURATOR_VALIDATION'|| SQLERRM , 1);
    END IF;
    RAISE;
END Configurator_Validation;

/*----------------------------------------------------------------------
PROCEDURE: Bom_Config_Validation
If Use_Configurator function returns false.

Change Record:
ER 2625376 : date effectivity - call to prepare_cascade_tables.

MACD: No MACD functionality should be available in the options window
-----------------------------------------------------------------------*/
PROCEDURE Bom_Config_Validation
(p_model_line_id       IN     NUMBER,
 p_header_id           IN     NUMBER,
 p_model_qty           IN     NUMBER,
 p_deleted_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_updated_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_caller              IN     VARCHAR2 := '',
 x_valid_config        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_complete_config     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_return_status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
  l_options_tbl     Oe_Process_Options_Pvt.Selected_Options_Tbl_Type;
  l_updated_options_tbl OE_Order_PUB.request_tbl_type;
  l_deleted_options_tbl OE_Order_PUB.request_tbl_type;
  I                 NUMBER;
  l_change_flag     VARCHAR2(1);
  l_item_type_code  VARCHAR2(30);
  l_model_component VARCHAR2(1000);
  l_req_rec         OE_Order_Pub.Request_Rec_Type;
  l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);

  --
  l_debug_level     CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING BOM_CONFIG_VALIDATION' , 1);
    oe_debug_pub.add('GETTING PREVIOUSLY SAVED OPTIONS FROM DB' , 2 );
  END IF;

  IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN

    OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
    ( p_line_id              => p_model_line_id
     ,x_top_container_model  => l_change_flag
     ,x_part_of_container    => l_return_status );

    IF l_change_flag = 'Y' THEN
      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Line is top container, hence not allowed',3);
      END IF;

      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','ONT_TSO_NOT_IN_OPTIONS_WINDOW');
      OE_MSG_PUB.Add;
      RETURN;
    END IF;

  END IF;


  l_return_status := FND_API.G_RET_STS_SUCCESS;

  OE_Process_Options_Pvt.Get_Options_From_DB
  ( p_top_model_line_id  => p_model_line_id
   ,p_get_model_line     => TRUE
   ,p_caller             => 'OPTIONS WINDOW BATCH'
   ,p_query_criteria     => 4
   ,x_disabled_options   => l_msg_data
   ,x_options_tbl        => l_options_tbl);

  IF p_deleted_options_tbl.COUNT > 0 OR
     p_updated_options_tbl.COUNT > 0 OR
     l_msg_data = 'Y' THEN

    SELECT component_code
    INTO   l_model_component
    FROM   oe_order_lines
    WHERE  line_id = p_model_line_id;

    l_updated_options_tbl := p_updated_options_tbl;
    l_deleted_options_tbl := p_deleted_options_tbl;

    IF l_msg_data = 'Y' THEN

      OE_Process_Options_Pvt.Prepare_Cascade_Tables
      ( p_options_tbl           => l_options_tbl
       ,p_top_model_line_id     => p_model_line_id
       ,p_x_updated_options_tbl => l_updated_options_tbl
       ,p_x_deleted_options_tbl => l_deleted_options_tbl);

    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING CASCADE_UPDATES_DELETES '||
                        l_deleted_options_tbl.COUNT || '-' ||
                        l_updated_options_tbl.COUNT, 3);
    END IF;

    Cascade_Updates_Deletes
    ( p_model_line_id       => p_model_line_id
     ,p_model_component     => l_model_component
     ,p_x_options_tbl       => l_options_tbl
     ,p_deleted_options_tbl => l_deleted_options_tbl
     ,p_updated_options_tbl => l_updated_options_tbl
     ,x_return_status       => l_return_status);

  END IF; -- if we need to cascade

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CALLING PROCESS_CONFIG_OPTIONS' , 1);
  END IF;

  OE_Process_Options_Pvt.Process_Config_Options
  (p_options_tbl       => l_options_tbl,
   p_header_id         => p_header_id,
   p_top_model_line_id => p_model_line_id,
   p_ui_flag           => 'N',
   p_caller            => p_caller, -- bug 4636208
   x_valid_config      => x_valid_config,
   x_complete_config   => x_complete_config,
   x_change_flag       => l_change_flag,
   x_msg_count         => l_msg_count,
   x_msg_data          => l_msg_data,
   x_return_status     => x_return_status);

  OE_Process_Options_Pvt.Handle_Ret_Status
  (p_return_Status   => x_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING BOM_CONFIG_VALIDATION' , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN BOM_CONFIG_VALIDATION'|| SQLERRM , 1);
    END IF;
    RAISE;
END Bom_Config_Validation;


/*----------------------------------------------------------------------
Procedure Name :  Cascade_Updates_Deletes
Description    :  This API will be used when there are updates and deletes
to option/class of a configuration and we want to cascade the operation to
either upwards or downwards.
  -- handle updates
  -- if any class is updated, modify the l_options-tbl so that, options
  -- qty cascades, set operation of update on the updated once, and none
  -- on the others

  -- handle deletes
  -- if any class deleted, delete all options underit.
  -- if a option is deleted, i.e. the only option in a class
  -- delete the class from l_options_tbl

  Note:
  If a kit under a model is updated/deleted, since its included items
  are not present in l_options_tbl, so we can not use cascade_qty
  or delete_options for it.
  We handle this seperately, before call to process_order in
  handle_dml in OEXVOPTB.pls. We also handle the case of included
  items under a PTO class in handle_dml.

 As part of pack J ato options decimal quantity project
 decimal_ratio_check is moved to OE_VALIDATE_LINE
 for Decimal quantities for ATO Options Project
 the decimal ratio check will be part of line entity
 validation
-----------------------------------------------------------------------*/

PROCEDURE Cascade_Updates_Deletes
( p_model_line_id        IN   NUMBER
 ,p_model_component      IN   VARCHAR2
 ,p_x_options_tbl        IN   OUT NOCOPY
                              Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_deleted_options_tbl  IN   OE_Order_PUB.request_tbl_type
                              := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_updated_options_tbl  IN   OE_Order_PUB.request_tbl_type
                              := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_ui_flag              IN   VARCHAR2 := 'N'
 ,x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
  I                          NUMBER;
  l_index                    NUMBER;
  l_ratio                    NUMBER;
  l_req_rec                  OE_Order_Pub.Request_Rec_Type;
  l_deleted_options_tbl      OE_Order_PUB.request_tbl_type
                             := p_deleted_options_tbl;
  l_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_qty                      NUMBER := 1;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING CASCADE_UPDATES_DELETES' , 1);
    oe_debug_pub.add('FIRST UPDATES' , 2 );
  END IF;

  IF p_updated_options_tbl.COUNT > 0 THEN
    SELECT ordered_quantity
    INTO   l_qty
    FROM   oe_order_lines
    WHERE  line_id = p_model_line_id;
  END IF;

  I :=p_updated_options_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    l_req_rec  := p_updated_options_tbl(I);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OPTIONS UPDATED ' , 4 );
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('QTY '|| L_REQ_REC.PARAM5||'CANCEL: '
                       ||L_REQ_REC.PARAM8 , 2 );
    END IF;

    IF l_req_rec.param5 = 0 AND l_req_rec.param8 = 'N' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('QTY = 0 AND NO CANCELLATION , SO DELETE' , 1);
      END IF;

      BEGIN
        -- set operation to delete
        l_index := OE_Process_Options_Pvt.Find_Matching_comp_index
        ( p_options_tbl  => p_x_options_tbl
         ,p_comp_code    => l_req_rec.param2);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('INDEX: '|| L_INDEX , 2 );
        END IF;
        p_x_options_tbl(l_index).operation := OE_GLOBALS.G_OPR_DELETE;

      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('COMPONENT NOT PRESENT' , 1);
          END IF;
          RAISE;
      END;

      l_deleted_options_tbl(nvl(l_deleted_options_tbl.LAST, 0) + 1) :=
                                  l_req_rec; -- ok, since params match

    ELSE -- regular code
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('REGULAR CODE OF UPDATES'|| L_REQ_REC.PARAM3 , 1);
      END IF;

      IF l_req_rec.param3 = OE_GLOBALS.G_ITEM_CLASS THEN

        IF l_req_rec.param5 = 0 THEN
          l_ratio := 0;
        ELSE
          l_ratio := l_req_rec.param5/l_req_rec.param4;
        END IF;

        IF l_debug_level  > 0 THEN
          -- 4211654
          oe_debug_pub.add(L_REQ_REC.PARAM2||'   OLD QTY (l_req_rec.param4) = '
                           ||L_REQ_REC.PARAM4||'  New Qty (l_req_rec.param5) = '
                           ||l_req_rec.param5 , 1);
        END IF;

        Cascade_Qty( p_x_options_tbl   => p_x_options_tbl
                    ,p_component_code  => l_req_rec.param2
                    ,p_ratio           => l_ratio
                    -- 4211654
                    ,p_new_qty        => l_req_rec.param5
                    ,p_old_qty        => l_req_rec.param4
                    ,p_change_reason   => l_req_rec.param6
                    ,p_change_comments => l_req_rec.param7);
      END IF;

      IF l_req_rec.param8 = 'Y' AND
         l_req_rec.param5 = 0
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CALLING PROPOGATE CHANGE , CANCEL FLAG Y' , 1);
        END IF;

        Propogate_change_To_parent
        (p_x_options_tbl     => p_x_options_tbl
        ,p_component_code    => l_req_rec.param2
        ,p_top_model_line_id => p_model_line_id
        ,p_model_component   => p_model_component
        ,p_ui_flag      => p_ui_flag);
      END IF;

    END IF; -- qty 0 and cancel = 'N'

    I :=  p_updated_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NOW DELETES' , 1);
  END IF;

  I :=l_deleted_options_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('THERE ARE ITEMS DELETED'|| L_REQ_REC.PARAM2 , 1);
    END IF;

    l_req_rec  := l_deleted_options_tbl(I);

    IF l_req_rec.param3 = OE_GLOBALS.G_ITEM_CLASS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CLASS IS DELETED'|| L_REQ_REC.PARAM2 , 1);
      END IF;

      Delete_Children( p_x_options_tbl  => p_x_options_tbl
                      ,p_component_code => l_req_rec.param2
                      ,p_parent_item    => l_req_rec.param10 ); -- 3563690
    END IF;

    -- why a KIT and a Class are considered here.
    -- if user saves a configuration with a class or kit w/o any
    -- options/inc items and then deletes this class/kit, we
    -- should see if the parent needs to be deleted, rare case.

    IF p_model_component is NULL THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('MODEL COMPONENT IS NULL' , 1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OPTION/CLASS/KIT IS DELETED' , 1);
    END IF;

    Delete_Parent(p_x_options_tbl     => p_x_options_tbl
                 ,p_component_code    => l_req_rec.param2
                 ,p_top_model_line_id => p_model_line_id
                 ,p_model_component   => p_model_component
                 ,p_ui_flag           => p_ui_flag);

    I :=  l_deleted_options_tbl.NEXT(I);
  END LOOP;

  x_return_status := l_return_status;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING CASCADE_UPDATES_DELETES' , 1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN CASCADE_UPDATES_DELETES'|| SQLERRM , 1);
    END IF;
    RAISE;
END Cascade_Updates_Deletes;

/*---------------------------------------------------------------------
PROCEDURE: Cascade_Qty
bug fixed: Make sure to pass req. reason and comment, while cascading.
bug fixed: only one level cascade will happen.
----------------------------------------------------------------------*/

PROCEDURE Cascade_Qty
( p_x_options_tbl   IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_component_code  IN VARCHAR2
 ,p_ratio           IN NUMBER
  -- 4211654
 ,p_new_qty         IN number
 ,p_old_qty         IN number
 ,p_change_reason   IN VARCHAR2
 ,p_change_comments IN VARCHAR2)
IS
  I            NUMBER;
  l_length     NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING CASCADE_QTY '|| P_RATIO , 1);
  END IF;

  l_length := LENGTH(p_component_code);

  I := p_x_options_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    IF SUBSTR(p_x_options_tbl(I).component_code, 1, l_length )
              = p_component_code
       AND p_x_options_tbl(I).component_code <> p_component_code
       AND p_x_options_tbl(I).operation <> OE_GLOBALS.G_OPR_DELETE
    THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OPTION TO BE UPDATED '
                          || P_X_OPTIONS_TBL (I).COMPONENT_CODE , 3 );
         oe_debug_pub.add('CHANGE REASON '|| P_CHANGE_REASON , 3 );
       END IF;
       /* 4211654 - instead of using p_ratio, used p_old_qty and p_new_qty to
        *           calculate p_x_options_tbl(I).ordered_quantity
        */
       p_x_options_tbl(I).ordered_quantity :=
          (p_x_options_tbl(I).ordered_quantity / p_old_qty) * p_new_qty;
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('NEW QTY '||P_X_OPTIONS_TBL (I).ORDERED_QUANTITY ,1);
       END IF;
       p_x_options_tbl(I).change_reason   := p_change_reason;
       p_x_options_tbl(I).change_comments := p_change_comments;

       --added IF condition for bug# 4116813
       IF p_x_options_tbl(I).operation <>  OE_GLOBALS.G_OPR_INSERT THEN
         p_x_options_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;
       END IF;


    END IF;
    I := p_x_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING CASCADE_QTY' , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN CASCADE_QTY'|| SQLERRM , 1);
    END IF;
    RAISE;
END Cascade_Qty;


/*----------------------------------------------------------------------
PROCEDURE: Delete_Children
3563690 => If operation is insert for a child line, do not set the
           operation to delete. Instead, raise an exception
           Changed the signature of the procedure to accept the  name
           of the class.
----------------------------------------------------------------------*/
PROCEDURE Delete_Children
( p_x_options_tbl  IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
 ,p_component_code IN VARCHAR2
 ,p_parent_item    IN VARCHAR2)
IS
  I            NUMBER;
  l_length     NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING DELETE_CHILDREN' , 1);
  END IF;

  l_length := LENGTH(p_component_code);

  I := p_x_options_tbl.FIRST;
  WHILE I is not NULL
  LOOP
    IF SUBSTR(p_x_options_tbl(I).component_code, 1, l_length )
              = p_component_code
       AND p_x_options_tbl(I).component_code <> p_component_code
    THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OPTION TO BE DELETED '
                          || P_X_OPTIONS_TBL (I).COMPONENT_CODE , 3 );
       END IF;
       IF p_x_options_tbl(I).operation <> OE_GLOBALS.G_OPR_INSERT
       THEN
         p_x_options_tbl(I).operation := OE_GLOBALS.G_OPR_DELETE;
       ELSE
         FND_MESSAGE.SET_NAME('ONT','ONT_CONFIG_INSERT_DELETE');
         FND_MESSAGE.Set_Token('CLASS',p_parent_item);
         FND_MESSAGE.Set_Token('ITEM',p_x_options_tbl(I).ordered_item);
         Oe_Msg_Pub.Add;
         IF l_debug_level > 0 THEN
           oe_debug_pub.add('OPERATION IS INSERT IN PROCEDURE DELETE_CHILDREN');
           oe_debug_pub.add('parent class : ' || p_parent_item);
           oe_debug_pub.add('child item   : ' || p_x_options_tbl(I).ordered_item);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    I := p_x_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING DELETE_CHILDREN' , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN DELETE_CHILDREN'|| SQLERRM , 1);
    END IF;
    RAISE;
END Delete_Children;


/*----------------------------------------------------------------------
PROCEDURE Delete_Parent
delete the parent only if the only option under it is getting deleted.
Never delete the model line.
----------------------------------------------------------------------*/
PROCEDURE Delete_Parent
(p_x_options_tbl      IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag            IN VARCHAR2 := 'N')
IS
  I                  NUMBER;
  l_count            NUMBER;
  l_link_to_line_id  NUMBER;
  l_parent           VARCHAR2(1000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING DELETE_PARENT' , 1);
  END IF;

  IF p_model_component is NULL THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF p_component_code = p_model_component THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('MODEL REACHED' , 1);
    END IF;
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('COMP SENT IN: '|| P_COMPONENT_CODE , 2 );
  END IF;


  IF no_more_children_left
     (p_x_options_tbl     => p_x_options_tbl
     ,p_component_code    => p_component_code
     ,p_top_model_line_id => p_top_model_line_id
     ,p_model_component   => p_model_component
     ,p_ui_flag           => p_ui_flag)
  THEN

    -- make a recursive call, because parent can be the
    -- only child to its parent.

    I := p_x_options_tbl.FIRST;
    WHILE I is not NULL

    LOOP
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(I || ': '|| P_X_OPTIONS_TBL (I).COMPONENT_CODE , 2 );
      END IF;
      l_parent :=
      SUBSTR(p_component_code, 1, INSTR(p_component_code, '-', -1) - 1);

      IF l_parent = p_x_options_tbl(I).component_code AND
         p_x_options_tbl(I).component_code <> p_model_component
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT TO BE DELETED '
                           || P_X_OPTIONS_TBL (I).COMPONENT_CODE , 3 );
        END IF;

        p_x_options_tbl(I).operation := OE_GLOBALS.G_OPR_DELETE;

        -- recursive call.

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RECURSIVE CALL'|| P_MODEL_COMPONENT , 1);
        END IF;
        Delete_Parent(p_x_options_tbl     => p_x_options_tbl
                     ,p_component_code    => l_parent
                     ,p_top_model_line_id => p_top_model_line_id
                     ,p_model_component   => p_model_component
                     ,p_ui_flag           => p_ui_flag);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('MY CALL WORK DONE' , 1);
        END IF;
        RETURN;
      END IF;
      I := p_x_options_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('PARENT NOT FOUND??' , 1);
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING DELETE_PARENT'|| P_COMPONENT_CODE , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN DELETE_PARENT'|| SQLERRM , 1);
    END IF;
    RAISE;
END Delete_Parent;


/*----------------------------------------------------------------------
PROCEDURE Propogate_Change_To_Parent
propogate change to the parent only if the only option under
it is changed.
----------------------------------------------------------------------*/
PROCEDURE Propogate_Change_To_Parent
(p_x_options_tbl      IN OUT NOCOPY Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag            IN VARCHAR2 := 'N')
IS
  I                  NUMBER;
  l_count            NUMBER;
  l_link_to_line_id  NUMBER;
  l_parent           VARCHAR2(1000);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING PROPOGATE_CHANGE_TO_PARENT' , 1);
  END IF;

  IF p_model_component is NULL THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  IF p_component_code = p_model_component THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('MODEL REACHED' , 1);
    END IF;
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('COMP SENT IN: '|| P_COMPONENT_CODE , 2 );
  END IF;


  IF no_more_children_left
     (p_x_options_tbl     => p_x_options_tbl
     ,p_component_code    => p_component_code
     ,p_top_model_line_id => p_top_model_line_id
     ,p_model_component   => p_model_component
     ,p_ui_flag           => p_ui_flag)
  THEN

    -- make a recursive call, because parent can be the
    -- only child to its parent.

    I := p_x_options_tbl.FIRST;
    WHILE I is not NULL

    LOOP
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(I || ': '|| P_X_OPTIONS_TBL (I).COMPONENT_CODE , 2 );
      END IF;

      l_parent :=
      SUBSTR(p_component_code, 1, INSTR(p_component_code, '-', -1) - 1);

      IF l_parent = p_x_options_tbl(I).component_code AND
         p_x_options_tbl(I).component_code <> p_model_component
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('PARENT TO BE MODIFIED '
                           || P_X_OPTIONS_TBL (I).COMPONENT_CODE , 3 );
        END IF;


        p_x_options_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;
        p_x_options_tbl(I).ordered_quantity := 0;
        p_x_options_tbl(I).change_reason := 'SYSTEM';

        -- recursive call.

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RECURSIVE CALL'|| P_MODEL_COMPONENT , 1);
        END IF;

        Propogate_Change_To_Parent
                     (p_x_options_tbl     => p_x_options_tbl
                     ,p_component_code    => l_parent
                     ,p_top_model_line_id => p_top_model_line_id
                     ,p_model_component   => p_model_component
                     ,p_ui_flag           => p_ui_flag);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('MY CALL WORK DONE' , 1);
        END IF;
        RETURN;
      END IF;
      I := p_x_options_tbl.NEXT(I);
    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('PARENT NOT FOUND??' , 1);
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING PROPOGATE_CHANGE_TO_PARENT'
                     || P_COMPONENT_CODE , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN PROPOGATE_CHANGE_TO_PARENT'
                       || SQLERRM , 1);
    END IF;
    RAISE;
END Propogate_Change_To_Parent;


/*----------------------------------------------------------------------
PROCEDURE No_More_Children_Left
delete the parent only if the only option under it is getting deleted.
Never delete the model line.
p_component_code is the component_code of the child, for which
we are trying tofind out if this is the only child to its parent.
----------------------------------------------------------------------*/
FUNCTION No_More_Children_Left
(p_x_options_tbl      IN Oe_Process_Options_Pvt.Selected_Options_Tbl_Type
,p_component_code     IN VARCHAR2
,p_top_model_line_id  IN NUMBER
,p_model_component    IN VARCHAR2
,p_ui_flag            IN VARCHAR2 := 'N')
RETURN BOOLEAN
IS
  l_parent    VARCHAR2(1000);
  l_count     NUMBER;
  I           NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING NO_MORE_CHILDREN_LEFT'|| P_UI_FLAG , 1);
  END IF;

  l_parent :=
    SUBSTR(p_component_code, 1, INSTR(p_component_code, '-', -1) - 1);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('PARENT: '|| L_PARENT , 3 );
  END IF;

  IF l_parent = p_model_component THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('PARENT IS A MODEL' , 1);
    END IF;
    RETURN FALSE;
  END IF;

  I := p_x_options_tbl.FIRST;

  WHILE I is not NULL
  LOOP
    IF SUBSTR(p_x_options_tbl(I).component_code, 1,
              INSTR(p_component_code, '-', -1) - 1)
              =  SUBSTR(p_component_code, 1,
              INSTR(p_component_code, '-', -1) - 1)  -- same parent
       AND p_x_options_tbl(I).component_code <> l_parent
       AND p_x_options_tbl(I).component_code <> p_component_code
       AND p_x_options_tbl(I).operation <> OE_GLOBALS.G_OPR_DELETE
       AND NOT(p_x_options_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE AND
               p_x_options_tbl(I).ordered_quantity = 0) -- cancel

    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OPTION UNDER SAME PARENT EXISTS' , 3 );
      END IF;
      RETURN FALSE;
    END IF;

    I :=  p_x_options_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CAME OUT OF LOOP' , 3 );
  END IF;

  -- use sql, may be included item exist.
  l_count := 0;

  SELECT /* MOAC_SQL_CHANGE */ count(*)
  INTO   l_count
  FROM   oe_order_lines_all
  WHERE  top_model_line_id = p_top_model_line_id
  AND    item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
  AND    open_flag      = 'Y'
  AND    link_to_line_id =
      (SELECT line_id
       FROM   oe_order_lines_all
       WHERE  top_model_line_id = p_top_model_line_id
       AND    component_code = l_parent
       AND    open_flag      = 'Y' );

  IF l_count > 0 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('SOME MORE OPTIONS EXIST' , 1);
    END IF;
    RETURN FALSE;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING NO_MORE_CHILDREN_LEFT' , 1);
  END IF;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ECXEPTION IN NO_MORE_CHILDREN_LEFT'|| SQLERRM , 1);
    END IF;
    RAISE;
END No_More_Children_Left;


/*----------------------------------------------------------------------
Procedure Name : Validate_Configuration
wrapper  API to decide which validation API should be used.

Change Record:

We do not need to call the apt complete_configuration anymore,
because all the code is put in OEXVORDB.pls in the lines loop.
-----------------------------------------------------------------------*/
PROCEDURE Validate_Configuration
(p_model_line_id       IN     NUMBER,
 p_deleted_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_updated_options_tbl IN     OE_Order_PUB.request_tbl_type
                                := OE_Order_Pub.G_MISS_REQUEST_TBL,
 p_validate_flag       IN     VARCHAR2 := 'Y',
 p_complete_flag       IN     VARCHAR2 := 'Y',
 p_caller              IN     VARCHAR2 := '',
 x_valid_config        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_complete_config     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_return_status       OUT NOCOPY /* file.sql.39 change */    VARCHAR2)

IS
  l_header_id                 NUMBER;
  l_config_hdr_id             NUMBER;
  l_config_rev_nbr            NUMBER;
  l_configuration_id          NUMBER;
  l_model_qty                 NUMBER;
  l_use_configurator          BOOLEAN;
  l_configurator_was_used     NUMBER;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_return_status             VARCHAR2(1):=  FND_API.G_RET_STS_SUCCESS;
  l_order_source_id           NUMBER;
  l_orig_sys_document_ref     VARCHAR2(50);
  l_orig_sys_line_ref         VARCHAR2(50);
  l_orig_sys_shipment_ref     VARCHAR2(50);
  l_change_sequence           VARCHAR2(50);
  l_source_document_type_id   NUMBER;
  l_source_document_id        NUMBER;
  l_source_document_line_id   NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.VALIDATE_CONFIGURATION' , 1);
   END IF;


-- No Copy Changes. Initialized return status to success
	x_return_status    := FND_API.G_RET_STS_SUCCESS;


--get_transaction_id(p_caller   => 'inside validate_config');

   BEGIN
     SELECT header_id, config_header_id, config_rev_nbr, ordered_quantity,
            configuration_id, order_source_id, orig_sys_document_ref,
            orig_sys_line_ref, orig_sys_shipment_ref, change_sequence,
            source_document_type_id, source_document_id, source_document_line_id
     INTO   l_header_id, l_config_hdr_id, l_config_rev_nbr, l_model_qty,
            l_configuration_id, l_order_source_id, l_orig_sys_document_ref,
            l_orig_sys_line_ref, l_orig_sys_shipment_ref, l_change_sequence,
            l_source_document_type_id, l_source_document_id, l_source_document_line_id
     FROM   OE_ORDER_LINES_ALL
     WHERE  line_id = p_model_line_id;
   EXCEPTION
     WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   OE_Msg_Pub.Set_Msg_Context
   (p_entity_code   => OE_GLOBALS.G_ENTITY_LINE
   ,p_entity_id     => p_model_line_id
   ,p_header_id     => l_header_id
   ,p_line_id       => p_model_line_id
   ,p_order_source_id            => l_order_source_id
   ,p_orig_sys_document_ref      => l_orig_sys_document_ref
   ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
   ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
   ,p_change_sequence            => l_change_sequence
   ,p_source_document_type_id    => l_source_document_type_id
   ,p_source_document_id         => l_source_document_id
   ,p_source_document_line_id    => l_source_document_line_id);

   l_use_configurator := OE_Process_Options_Pvt.Use_Configurator;

   IF l_use_configurator THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('USE CONFIGURATOR IS TRUE' , 1);
     END IF;
   END IF;

   IF l_config_hdr_id is NOT NULL AND
      l_config_rev_nbr   is NOT NULL THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIGURATOR WAS USED' , 1);
      END IF;
      l_configurator_was_used := 0;
   ELSIF
      l_configuration_id is NOT NULL THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OPTIONS WINDOW WAS USED' , 1);
      END IF;
      l_configurator_was_used := 1;
   ELSE
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('NEW CONFIGURATION BEING CREATED' , 1);
      END IF;
      l_configurator_was_used := 2;
   END IF;

   IF l_use_configurator AND
      (l_configurator_was_used = 0 OR
       l_configurator_was_used = 2)
   THEN
       Configurator_Validation
       (p_model_line_id        => p_model_line_id,
        p_deleted_options_tbl  => p_deleted_options_tbl,
        p_updated_options_tbl  => p_updated_options_tbl,
        p_caller               => p_caller,
        x_valid_config         => x_valid_config,
        x_complete_config      => x_complete_config,
        x_return_status        => x_return_status);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RETURNING AFTER CONFIGURATOR_VALIDATION'
                           || X_RETURN_STATUS , 2 );
        END IF;
        RETURN;
   END IF;


   IF NOT(l_use_configurator) AND
      (l_configurator_was_used = 1 OR
       l_configurator_was_used = 2)
   THEN

       Bom_Config_Validation
       (p_model_line_id        => p_model_line_id,
        p_header_id            => l_header_id,
        p_model_qty            => l_model_qty,
        p_deleted_options_tbl  => p_deleted_options_tbl,
        p_updated_options_tbl  => p_updated_options_tbl,
        p_caller               => p_caller,
        x_valid_config         => x_valid_config,
        x_complete_config      => x_complete_config,
        x_return_status        => x_return_status);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('RETURNING AFTER BOM_CONFIG_VALIDATION'
                           || X_RETURN_STATUS , 2 );
        END IF;
        RETURN;
   END IF;

   IF l_configurator_was_used <> 0 AND l_use_configurator THEN
     FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_USE_OPTIONS_WINDOW');
     OE_Msg_Pub.Add;
     x_return_status:= FND_API.G_RET_STS_ERROR;
   END IF;

   IF l_configurator_was_used <> 1 AND NOT (l_use_configurator) THEN
     FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_USE_CONFIGURATOR');
     OE_Msg_Pub.Add;
     x_return_status:= FND_API.G_RET_STS_ERROR;
   END IF;

   --get_transaction_id(p_caller   => ' leaving validate_config');

   oe_msg_pub.count_and_get
   ( p_count                       => l_msg_count
   ,   p_data                        => l_msg_data );


   OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('EXITING OE_CONFIG_UTIL.VALIDATE_CONFIGURATION' , 1);
   END IF;
EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status  := FND_API.G_RET_STS_ERROR;
         --get_transaction_id(p_caller   => 'exc error in validate_config');


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
         --get_transaction_id(p_caller   => 'unxp error in validate_config');


      WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('ERROR IN VALIDATE_CONFIGURATION : '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;
         x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Configuration;


  -- create xml message, send it to ui manager
  -- get back pieces of xml message
  -- process them and generate a long output xml message
  -- hardcoded :url,user, passwd, gwyuid,fndnam,two_task

/*-------------------------------------------------------------------
Procedure Name : Send_input_xml
Description    : sends the xml batch validation message to SPC that has
                 options that are newly inserted/updated/deleted
                 from the model.

                 SPC validation_status :
                 CONFIG_PROCESSED              constant NUMBER :=0;
                 CONFIG_PROCESSED_NO_TERMINATE constant NUMBER :=1;
                 INIT_TOO_LONG                 constant NUMBER :=2;
                 INVALID_OPTION_REQUEST        constant NUMBER :=3;
                 CONFIG_EXCEPTION              constant NUMBER :=4;
                 DATABASE_ERROR                constant NUMBER :=5;
                 UTL_HTTP_INIT_FAILED          constant NUMBER :=6;
                 UTL_HTTP_REQUEST_FAILED       constant NUMBER :=7;

Change Record:

Decimal ratio check is is moved to OE_VALIDATE_LINE
for Decimal quantities for ATO Options Project
the decimal ratio check will be part of line entity
validation

---------------------------------------------------------------------*/

PROCEDURE Send_input_xml
            ( p_model_line_id       IN NUMBER ,
              p_deleted_options_tbl IN   OE_Order_PUB.request_tbl_type
                                    := OE_Order_Pub.G_MISS_REQUEST_TBL,
              p_updated_options_tbl IN   OE_Order_PUB.request_tbl_type
                                    := OE_Order_Pub.G_MISS_REQUEST_TBL,
              p_model_qty           IN NUMBER,
              p_xml_hdr             IN VARCHAR2,
              x_out_xml_msg         OUT NOCOPY /* file.sql.39 change */ LONG ,
              x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
  l_html_pieces              CZ_BATCH_VALIDATE.CFG_OUTPUT_PIECES;
  l_option                   CZ_BATCH_VALIDATE.INPUT_SELECTION;
  l_batch_val_tbl            CZ_BATCH_VALIDATE.CFG_INPUT_LIST;
  l_db_options_tbl       OE_Process_Options_Pvt.SELECTED_OPTIONS_TBL_TYPE;
  -- update / delete options
  l_req_rec                       OE_Order_Pub.Request_Rec_Type;
  l_flag                          VARCHAR2(30) := '0';

  --variable to fetch from cursor Get_Options
  l_component_code                VARCHAR2(1000);
  l_configuration_id              NUMBER;
  l_send_model_flag               VARCHAR2(1);
  -- message related
  l_validation_status             NUMBER;
  l_sequence                      NUMBER := 0;
  l_url                           VARCHAR2(500):=
                                  FND_PROFILE.Value('CZ_UIMGR_URL');
  l_rec_index BINARY_INTEGER;
  l_xml_hdr                       VARCHAR2(2000);
  l_long_xml                      LONG := NULL;
  l_return_status                 VARCHAR2(1) :=
                                  FND_API.G_RET_STS_SUCCESS;
  I                               NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
 BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.SEND_INPUT_XML' , 1);
        oe_debug_pub.add('UIMANAGER URL: ' || L_URL , 2 );
      END IF;


      l_xml_hdr := p_xml_hdr;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LENGTH OF INI MSG: ' || LENGTH ( L_XML_HDR ) , 2 );
      END IF;


      -- if there is change in model qty and we have cascaded it
      -- to all options, w/o communicating this to SPC
      -- send the new model qty in batch validation.

      l_send_model_flag := 'Y';

      BEGIN
        SELECT ol.component_code, ol.configuration_id
        INTO   l_component_code, l_configuration_id
        FROM   oe_order_lines ol, cz_config_details_v cz
        WHERE  ol.line_id        = p_model_line_id
        AND    cz.component_code = ol.component_code
        AND    cz.config_hdr_id  = ol.config_header_id
        AND    cz.config_rev_nbr = ol.config_rev_nbr
        AND    cz.quantity      <> ol.ordered_quantity;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_send_model_flag := 'N';

        WHEN OTHERS THEN
          RAISE FND_API.G_EXC_ERROR;
      END;


     IF l_send_model_flag = 'Y' THEN
          l_sequence := l_sequence + 1;
          l_option.component_code     := l_component_code;
          l_option.quantity           := p_model_qty;
          l_option.input_seq          := l_sequence;

          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('SEND XML UCFGB MI , PACK H NEW LOGIC' , 3 );
            END IF;
            l_option.config_item_id   := l_configuration_id;
          END IF;

          l_batch_val_tbl(l_sequence) := l_option;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('NEW MODEL QTY: '|| P_MODEL_QTY , 2 );
          END IF;

     END IF;

     -- get the options from the from databse.
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('GETTING PREVIOUSLY SAVED OPTIONS FROM DB' , 2 );
     END IF;

     OE_Process_Options_Pvt.Get_Options_From_DB
     ( p_top_model_line_id  => p_model_line_id
      ,x_disabled_options   => l_flag
      ,x_options_tbl        => l_db_options_tbl);

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('cursor GET NEWLY INSERTED OPTIONS '|| l_flag , 2 );
     END IF;

     I := l_db_options_tbl.FIRST;
     WHILE I is not NULL
     LOOP
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('GET_OPTION : '
                            || L_DB_OPTIONS_TBL (I).COMPONENT_CODE , 2 );
          END IF;

          l_sequence := l_sequence + 1;

          l_option.component_code := l_db_options_tbl(I).component_code;
          l_option.input_seq      := l_sequence;

          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('SEND XML UCFGB MI , PACK H NEW LOGIC' , 3 );
            END IF;
            l_option.config_item_id
                                := l_db_options_tbl(I).configuration_id;
          END IF;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('QTY RATIO : '
            || L_DB_OPTIONS_TBL (I).ORDERED_QUANTITY/P_MODEL_QTY , 2 );
            oe_debug_pub.add('OE QTY: '
            || L_DB_OPTIONS_TBL (I).ORDERED_QUANTITY , 2 );
          END IF;

          l_option.quantity   := l_db_options_tbl(I).ordered_quantity;

          l_batch_val_tbl(l_sequence) := l_option;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_SEQUENCE||' '
                             ||L_DB_OPTIONS_TBL (I).CONFIGURATION_ID , 2 );
          END IF;

          I := l_db_options_tbl.NEXT(I);
      END LOOP;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OUT OF NEWLY INSERTED OPTIONS LOOP' , 2 );
      END IF;


     --------------- send updated options/classes----------------


     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NO. OF UPDATED OPTIONS: '
                        ||P_UPDATED_OPTIONS_TBL.COUNT , 2 );
       oe_debug_pub.add('ENTERING LOOP TO PASS UPDATED OPTIONS' , 2 );
     END IF;


     l_rec_index := 1;

     FOR I IN 1..p_updated_options_tbl.COUNT
     LOOP
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('WITHIN THE LOOP OF P_UPDATED_OPTIONS_TBL' , 2 );
           oe_debug_pub.add('L_REC_INDEX: ' || L_REC_INDEX , 2 );
         END IF;

         l_req_rec  := p_updated_options_tbl(l_rec_index);

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('UPDATE LINE_ID: ' || L_REQ_REC.ENTITY_ID , 2 );
           oe_debug_pub.add('COMPONENT_CODE: ' || L_REQ_REC.PARAM2 , 2 );
         END IF;

         l_sequence := l_sequence + 1;

         l_option.component_code := l_req_rec.param2;
         l_option.input_seq      := l_sequence;

         IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('UPD , SEND XML MI , PACK H NEW LOGIC' , 3 );
           END IF;
           l_option.config_item_id := l_req_rec.param9;
         END IF;

          -- check if integer

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_REQ_REC.PARAM2
            || ' OPTION UPDATED TO A QTY OF: ' || L_REQ_REC.PARAM5 , 3 );
          END IF;

          l_option.quantity       := l_req_rec.param5;

          l_batch_val_tbl(l_sequence) := l_option;
          l_rec_index := l_rec_index + 1;

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_SEQUENCE||' SEQ '||L_REQ_REC.PARAM9 , 2 );
          END IF;

     END LOOP;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('LEAVING LOOP TO PASS UPDATED OPTIONS' , 2 );
     END IF;



     ------------ send deleted options/classes-------------------

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('NO. OF DELETED OPTIONS: '
                        ||P_DELETED_OPTIONS_TBL.COUNT , 2 );
       oe_debug_pub.add('ENTERING LOOP TO PASS DELETED OPTIONS' , 2 );
     END IF;

     l_rec_index := 1;
     FOR I IN 1..p_deleted_options_tbl.COUNT
     LOOP

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('WITHIN THE LOOP OF P_DELETED_OPTIONS_TBL' , 2 );
           oe_debug_pub.add('L_REC_INDEX: ' || L_REC_INDEX , 2 );
         END IF;


         l_req_rec := p_deleted_options_tbl(l_rec_index);
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('ENTITY ID: ' || L_REQ_REC.ENTITY_ID , 2 );
           oe_debug_pub.add('COMPONENT_CODE: ' || L_REQ_REC.PARAM2 , 2 );
         END IF;

         l_sequence := l_sequence + 1;

         l_option.component_code := l_req_rec.param2;
         l_option.input_seq      := l_sequence;
         l_option.quantity       := 0;


         IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('DEL , SEND XML MI , PACK H NEW LOGIC' , 3 );
           END IF;
           l_option.config_item_id
                              := l_req_rec.param9;
         END IF;

         l_batch_val_tbl(l_sequence) := l_option;
         l_rec_index := l_rec_index + 1;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(L_SEQUENCE||' SEQ '||L_REQ_REC.PARAM9 , 2 );
         END IF;
     END LOOP;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('OUT OF INSERT/UPDATE/DELETE OPTIONS LOOPS ' , 1);
     END IF;


     -- delete previous data.
     IF (l_html_pieces.COUNT <> 0) THEN
         l_html_pieces.DELETE;
     END IF;


      --get_transaction_id
      --(p_caller   => 'inside send_xml, before call to SPC validate');

      CZ_BATCH_VALIDATE.Validate
      ( config_input_list => l_batch_val_tbl ,
        init_message      => l_xml_hdr ,
        config_messages   => l_html_pieces ,
        validation_status => l_validation_status ,
        URL               => l_url );


      --get_transaction_id
      --(p_caller   => 'inside send_xml, after call to SPC validate');

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('AFTER CALL TO SPC , STATUS : '
                          ||L_VALIDATION_STATUS , 1);
      END IF;

      IF l_validation_status <> 0 THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('DO NOT PROCESS RESULTS , ERROR ',1);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_html_pieces.COUNT <= 0) THEN
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('HTML_PIECES COUNT IS <= 0' , 2 );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      l_rec_index := l_html_pieces.FIRST;
      LOOP
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(L_REC_INDEX ||': PART OF OUTPUT_MESSAGE: '
            || SUBSTR ( L_HTML_PIECES ( L_REC_INDEX ) , 1 , 100 ) , 2 );
          END IF;

          l_long_xml := l_long_xml || l_html_pieces(l_rec_index);

          EXIT WHEN l_rec_index = l_html_pieces.LAST;
          l_rec_index := l_html_pieces.NEXT(l_rec_index);

      END LOOP;

      -- if everything ok, set out NOCOPY  values
      x_out_xml_msg := l_long_xml;
      x_return_status := l_return_status;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXITING OE_CONFIG_UTIL.SEND_INPUT_XML' , 1);
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         --get_transaction_id
         --(p_caller   => 'send_xml exc error, before call to SPC validate');

         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_VALIDATION_FAILURE');
         OE_Msg_Pub.Add;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         --get_transaction_id
         --(p_caller   => 'send_xml unxp, before call to SPC validate');
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('AN UNEXP ERROR RAISED' , 1);
         END IF;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SEND_INPUT_XML ERROR: '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;


      WHEN OTHERS THEN
         --get_transaction_id
         --(p_caller=> 'send_xml others error, before call to SPC validate');

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add
           ('SEND_INPUT_XML ERROR: ' || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

END Send_input_xml;


/*-------------------------------------------------------------------------
Procedure Name : Create_hdr_xml
Description    : creates a batch validation header message.
--------------------------------------------------------------------------*/

PROCEDURE Create_hdr_xml
( p_model_line_id       IN NUMBER
, p_ui_flag             IN VARCHAR2 := 'N'
, x_xml_hdr             OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS

      TYPE param_name_type IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

      TYPE param_value_type IS TABLE OF VARCHAR2(200)
      INDEX BY BINARY_INTEGER;

      param_name  param_name_type;
      param_value param_value_type;

      l_rec_index BINARY_INTEGER;

      l_model_line_rec                  OE_Order_Pub.Line_Rec_Type;

      -- SPC specific params
      l_database_id                     VARCHAR2(100);
      l_save_config_behavior            VARCHAR2(30):= 'new_revision';
      l_ui_type                         VARCHAR2(30):= null;
      l_msg_behavior                    VARCHAR2(30):= 'brief';

      --ont parameters
      l_context_org_id                  VARCHAR2(80);
      l_inventory_item_id               VARCHAR2(80);
      l_config_header_id                VARCHAR2(80);
      l_config_rev_nbr                  VARCHAR2(80);
      l_model_quantity                  VARCHAR2(80);
      l_pricing_package_name            VARCHAR2(100)
                                        := 'OE_Config_Price_Util';
      l_price_items_proc                VARCHAR2(100)
                                        := 'OE_Config_Price_Items';
      l_configurator_session_key        VARCHAR2(100):= NULL;
      l_session_id                      VARCHAR2(80)
                                        := FND_PROFILE.Value('DB_SESSION_ID');
      l_count                           NUMBER;
      -- message related
      l_xml_hdr                         VARCHAR2(2000):=
                                        '<initialize>';
      l_dummy                           VARCHAR2(500) := NULL;
      l_return_status                   VARCHAR2(1)
                                        := FND_API.G_RET_STS_SUCCESS;

      l_config_effective_date           DATE;
      l_old_behavior                    VARCHAR2(1);
      l_frozen_model_bill               VARCHAR2(1);
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
  BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.CREATE_HDR_XML' , 1);
      END IF;

      OE_LINE_UTIL.Query_Row(p_line_id  => p_model_line_id
                            ,x_line_rec => l_model_line_rec);

      -- now set the values from model_rec and org_id
      l_context_org_id        :=
                 OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
      l_inventory_item_id     := to_char(l_model_line_rec.inventory_item_id);
      l_config_header_id      := to_char(l_model_line_rec.config_header_id);
      l_config_rev_nbr        := to_char(l_model_line_rec.config_rev_nbr);


      l_model_quantity        := to_char(l_model_line_rec.ordered_quantity);


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('QUERIED FROM OE_LINES: ' || ' QTY: '
                          || L_MODEL_QUANTITY || ' CONFIG-HDR: '
                          || L_CONFIG_HEADER_ID || ' CONFIG-REV: '
                          || L_CONFIG_REV_NBR || ' ORG-ID: '
                          || L_CONTEXT_ORG_ID || ' ITEM-ID: '
                          || L_INVENTORY_ITEM_ID , 2 );
      END IF;

     -- profiles and env. variables.
      l_database_id            := fnd_web_config.database_id;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('DATABASE_ID: '|| L_DATABASE_ID , 2 );
      END IF;

      -- set param_names

      param_name(1)  := 'database_id';
      param_name(2)  := 'context_org_id';
      param_name(3)  := 'config_creation_date';
      param_name(4)  := 'calling_application_id';
      param_name(5)  := 'responsibility_id';
      param_name(6)  := 'model_id';
      param_name(7)  := 'config_header_id';
      param_name(8)  := 'config_rev_nbr';
      param_name(9)  := 'read_only';
      param_name(10) := 'save_config_behavior';
      param_name(11) := 'ui_type';
      param_name(12) := 'validation_org_id';
      param_name(13) := 'terminate_msg_behavior';
      param_name(14) := 'model_quantity';
      param_name(15) := 'icx_session_ticket';
      param_name(16) := 'client_header';
      param_name(17) := 'client_line';
      param_name(18) := 'sbm_flag';
      param_name(19)  := 'config_effective_date';
      param_name(20)  := 'config_model_lookup_date';
      l_count := 20;

      IF p_ui_flag = 'Y' THEN
        param_name(21) := 'pricing_package_name';
        param_name(22) := 'price_mult_items_proc';
        param_name(23) := 'configurator_session_key';
        l_count := 23;
      END IF;
        -- set param values

      param_value(1)  := l_database_id;
      param_value(2)  := l_context_org_id;
      param_value(3)  := to_char(l_model_line_rec.creation_date,
                                         'MM-DD-YYYY-HH24-MI-SS');
      --5249719: hardcoding application id
      param_value(4)  := 660; --fnd_profile.value('RESP_APPL_ID');
      param_value(5)  := fnd_profile.value('RESP_ID');
      param_value(6)  := l_inventory_item_id;
      param_value(7)  := l_config_header_id;
      param_value(8)  := l_config_rev_nbr;
      param_value(9)  := null;
      param_value(10) := l_save_config_behavior;
      param_value(11) := l_ui_type;
      param_value(12) := null;
      param_value(13) := l_msg_behavior;
      param_value(14) := l_model_quantity;
      param_value(15) := cz_cf_api.icx_session_ticket;
      param_value(16) := to_char(l_model_line_rec.header_id);
      param_value(17) := to_char(l_model_line_rec.line_id);

      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110508' THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('UCFGB MI , PACK H NEW LOGIC' , 1);
        END IF;
        param_value(18) := 'TRUE';
      ELSE
        param_value(18) := 'FALSE';
      END IF;

      OE_Config_Util.Get_Config_Effective_Date
      ( p_model_line_rec        => l_model_line_rec
       ,x_old_behavior          => l_old_behavior
       ,x_config_effective_date => l_config_effective_date
       ,x_frozen_model_bill     => l_frozen_model_bill);

      IF l_old_behavior = 'N' THEN
        param_value(19) := to_char(l_config_effective_date,
                           'MM-DD-YYYY-HH24-MI-SS');
        param_value(20) := param_value(19);
      ELSE
        param_value(19) := null;
        param_value(20) := null;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('old behavior no dates', 2 );
        END IF;
      END IF;


      IF p_ui_flag = 'Y' THEN
        param_value(21) := l_pricing_package_name;
        param_value(22) := l_price_items_proc;

        l_configurator_session_key
              := ( p_model_line_id || '#' || l_session_id);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CONFIG SESSION KEY : '
                            || L_CONFIGURATOR_SESSION_KEY , 2 );
        END IF;

        param_value(23) := l_configurator_session_key;
      END IF;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('INSIDE CREATE_HDR_XML , PARAMETERS ARE SET' , 2 );
      END IF;


      l_rec_index := 1;

      LOOP
         -- ex : <param name="config_header_id">1890</param>

         IF (param_value(l_rec_index) IS NOT NULL) THEN

             l_dummy :=  '<param name=' ||
                         '"' || param_name(l_rec_index) || '"'
                         ||'>'|| param_value(l_rec_index) ||
                         '</param>';

             l_xml_hdr := l_xml_hdr || l_dummy;

          END IF;

          l_dummy := NULL;

          l_rec_index := l_rec_index + 1;
          EXIT WHEN l_rec_index > l_count;

      END LOOP;


      -- add termination tags

      l_xml_hdr := l_xml_hdr || '</initialize>';
      l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('1ST PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 1 , 200 ) , 3 );
        oe_debug_pub.add('2ND PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 201 , 200 ) , 3 );
        oe_debug_pub.add('3RD PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 401 , 200 ) , 3 );
        oe_debug_pub.add('4TH PART OF CREATE_HDR_XML IS : '
                         ||SUBSTR ( L_XML_HDR , 601 , 200 ) , 3 );
      END IF;

      x_xml_hdr := l_xml_hdr;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LENGTH OF INI MSG:' || LENGTH ( L_XML_HDR ) , 3 );
        oe_debug_pub.add('LEAVING CREATE_HDR_XML' , 3 );
      END IF;
EXCEPTION
   when others then
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXCEPTION IN CREATE_HDR_XML '|| SQLERRM , 3 );
      END IF;
      RAISE;
END Create_hdr_xml;



/*-------------------------------------------------------------------------
Procedure Name : Parse_output_xml
Description    : Parses the output of SPC to get the valid and complete flag
                 populates messages from SPC in oe's message stack.

Change Record  :
Bug 2292308    : Display different messages for Incomplete and
                 Invalid Configurations.
--------------------------------------------------------------------------*/

PROCEDURE  Parse_output_xml
               (p_xml                IN LONG,
                  p_line_id            IN NUMBER,
                  x_valid_config       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_complete_config    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                  x_config_header_id   OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_config_rev_nbr     OUT NOCOPY /* file.sql.39 change */ NUMBER,
                  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS

      l_exit_start_tag                VARCHAR2(20) := '<EXIT>';
      l_exit_end_tag                  VARCHAR2(20) := '</EXIT>';
      l_exit_start_pos                NUMBER;
      l_exit_end_pos                  NUMBER;

      l_valid_config_start_tag          VARCHAR2(30) := '<VALID_CONFIGURATION>';
      l_valid_config_end_tag            VARCHAR2(30) := '</VALID_CONFIGURATION>';
      l_valid_config_start_pos          NUMBER;
      l_valid_config_end_pos            NUMBER;

      l_complete_config_start_tag       VARCHAR2(30) := '<COMPLETE_CONFIGURATION>';
      l_complete_config_end_tag         VARCHAR2(30) := '</COMPLETE_CONFIGURATION>';
      l_complete_config_start_pos       NUMBER;
      l_complete_config_end_pos         NUMBER;

      l_config_header_id_start_tag      VARCHAR2(20) := '<CONFIG_HEADER_ID>';
      l_config_header_id_end_tag        VARCHAR2(20) := '</CONFIG_HEADER_ID>';
      l_config_header_id_start_pos      NUMBER;
      l_config_header_id_end_pos        NUMBER;

      l_config_rev_nbr_start_tag        VARCHAR2(20) := '<CONFIG_REV_NBR>';
      l_config_rev_nbr_end_tag          VARCHAR2(20) := '</CONFIG_REV_NBR>';
      l_config_rev_nbr_start_pos        NUMBER;
      l_config_rev_nbr_end_pos          NUMBER;

      l_message_text_start_tag          VARCHAR2(20) := '<MESSAGE_TEXT>';
      l_message_text_end_tag            VARCHAR2(20) := '</MESSAGE_TEXT>';
      l_message_text_start_pos          NUMBER;
      l_message_text_end_pos            NUMBER;

      l_message_type_start_tag          VARCHAR2(20) := '<MESSAGE_TYPE>';
      l_message_type_end_tag            VARCHAR2(20) := '</MESSAGE_TYPE>';
      l_message_type_start_pos          NUMBER;
      l_message_type_end_pos            NUMBER;

      l_exit                            VARCHAR(20);
      l_config_header_id                NUMBER;
      l_config_rev_nbr                  NUMBER;
      l_message_text                    VARCHAR2(2000);
      l_message_type                    VARCHAR2(200);
      l_list_price                      NUMBER;
      l_selection_line_id               NUMBER;
      l_valid_config                    VARCHAR2(10);
      l_complete_config                 VARCHAR2(10);
      l_header_id                       NUMBER;
      l_return_status                   VARCHAR2(1) :=
                                        FND_API.G_RET_STS_SUCCESS;
      l_return_status_del               VARCHAR2(1);
      l_msg                             VARCHAR2(2000);
      l_constraint                      VARCHAR2(16);
      l_flag                            VARCHAR2(1) := 'N';

      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING OE_CONGIG_UTIL.PARSE_OUTPUT_XML' , 1);
      END IF;


      l_exit_start_pos :=
                    INSTR(p_xml, l_exit_start_tag,1, 1) +
                                length(l_exit_start_tag);

      l_exit_end_pos   :=
                          INSTR(p_xml, l_exit_end_tag,1, 1) - 1;

      l_exit           := SUBSTR (p_xml, l_exit_start_pos,
                                  l_exit_end_pos - l_exit_start_pos + 1);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('L_EXIT: ' || L_EXIT , 3 );
      END IF;

      -- if error go to msg etc.
      IF nvl(l_exit,'ERROR') <> 'ERROR'  THEN

        l_valid_config_start_pos :=
                INSTR(p_xml, l_valid_config_start_tag,1, 1) +
          length(l_valid_config_start_tag);

        l_valid_config_end_pos :=
                INSTR(p_xml, l_valid_config_end_tag,1, 1) - 1;

        l_valid_config := SUBSTR( p_xml, l_valid_config_start_pos,
                                  l_valid_config_end_pos -
                                  l_valid_config_start_pos + 1);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('GG1: '|| L_VALID_CONFIG , 3 );
        END IF;

        /* ex :- <VALID_CONFIGURATION>abc</VALID_CONFIGURATION>
           1st instr : posin of a(22), 2nd instr gives posn of c(24)
           substr gives string starting from
           posn a to posn c - posn a + 1(3)*/

        l_complete_config_start_pos :=
                   INSTR(p_xml, l_complete_config_start_tag,1, 1) +
        length(l_complete_config_start_tag);
        l_complete_config_end_pos :=
                   INSTR(p_xml, l_complete_config_end_tag,1, 1) - 1;

        l_complete_config := SUBSTR( p_xml, l_complete_config_start_pos,
                                     l_complete_config_end_pos -
                                     l_complete_config_start_pos + 1);

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('GG2: '|| L_COMPLETE_CONFIG , 3 );
        END IF;


          IF (nvl(l_valid_config, 'N')  <> 'TRUE') THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('SPC RETURNED VALID_FLAG AS NULL/FALSE' , 2 );
              END IF;
              l_flag := 'Y';
          END IF ;


          IF (nvl(l_complete_config, 'N') <> 'TRUE' ) THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('COMPLETE_FLAG AS NULL/FALSE' , 2 );
              END IF;
              l_flag := 'Y';
          END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SPC VALID_CONFIG FLAG: ' || L_VALID_CONFIG , 2 );
          oe_debug_pub.add('COMPLETE_CONFIG FLAG: ' || L_COMPLETE_CONFIG , 2 );
        END IF;

      END IF; /* if not error */


      -- parsing message_text and type is not req. I use it for debugging.

      l_message_text_start_pos :=
                 INSTR(p_xml, l_message_text_start_tag,1, 1) +
                       length(l_message_text_start_tag);
      l_message_text_end_pos :=
                 INSTR(p_xml, l_message_text_end_tag,1, 1) - 1;

      l_message_text := SUBSTR( p_xml, l_message_text_start_pos,
                                l_message_text_end_pos -
                                l_message_text_start_pos + 1);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('GG3: '|| L_MESSAGE_TEXT , 3 );
      END IF;

      l_message_type_start_pos :=
                 INSTR(p_xml, l_message_type_start_tag,1, 1) +
                 length(l_message_type_start_tag);
      l_message_type_end_pos :=
                 INSTR(p_xml, l_message_type_end_tag,1, 1) - 1;

      l_message_type := SUBSTR( p_xml, l_message_type_start_pos,
                                l_message_type_end_pos -
                                l_message_type_start_pos + 1);


      -- get the latest config_header_id, and rev_nbr to get
      -- messages if any.

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('SPC RETURNED MESSAGE_TEXT: '|| L_MESSAGE_TEXT , 2 );
        oe_debug_pub.add('SPC RETURNED MESSAGE_TYPE: '|| L_MESSAGE_TYPE , 2 );
      END IF;


      l_config_header_id_start_pos :=
                       INSTR(p_xml, l_config_header_id_start_tag, 1, 1)+
                       length(l_config_header_id_start_tag);

      l_config_header_id_end_pos :=
                       INSTR(p_xml, l_config_header_id_end_tag, 1, 1) - 1;

      l_config_header_id :=
                       to_number(SUBSTR( p_xml,l_config_header_id_start_pos,
                                         l_config_header_id_end_pos -
                                         l_config_header_id_start_pos + 1));


      l_config_rev_nbr_start_pos :=
                       INSTR(p_xml, l_config_rev_nbr_start_tag, 1, 1)+
                             length(l_config_rev_nbr_start_tag);

      l_config_rev_nbr_end_pos :=
                       INSTR(p_xml, l_config_rev_nbr_end_tag, 1, 1) - 1;

      l_config_rev_nbr :=
                       to_number(SUBSTR( p_xml,l_config_rev_nbr_start_pos,
                                         l_config_rev_nbr_end_pos -
                                         l_config_rev_nbr_start_pos + 1));

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CONFIG_HEADER_ID AS:' || L_CONFIG_HEADER_ID  , 2 );
        oe_debug_pub.add('CONFIG_REV_NBR AS:' || L_CONFIG_REV_NBR , 2 );
      END IF;


      IF (l_flag = 'Y' ) OR
          l_exit is NULL OR
          l_exit = 'ERROR'  THEN

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('GETTING MESSAGES FROM CZ_CONFIG_MESSAGES' , 2 );
          END IF;

          Message_From_Cz
          ( p_line_id           => p_line_id,
            p_valid_config      => l_valid_config,
            p_complete_config   => l_complete_config,
            p_config_header_id  => l_config_header_id,
            p_config_rev_nbr    => l_config_rev_nbr);

      END IF;

      IF L_MESSAGE_TEXT IS NOT NULL THEN
         oe_msg_pub.add_text(L_MESSAGE_TEXT);
      END IF;

      IF l_exit is NULL OR
         l_exit = 'ERROR'  THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SPC RETURNED ERROR , FAIL TRANSACTION' , 2 );
         END IF;

         -- delete the SPC configuration in error
         OE_Config_Pvt.Delete_Config
                        ( p_config_hdr_id   =>  l_config_header_id
                         ,p_config_rev_nbr  =>  l_config_rev_nbr
                         ,x_return_status   =>  l_return_status_del);

         RAISE FND_API.G_EXC_ERROR;
      END IF;


          -- if everything ok, set return values
      x_return_status    := l_return_status;
      x_config_header_id := l_config_header_id;
      x_config_rev_nbr   := l_config_rev_nbr;
      x_complete_config  := nvl(l_complete_config, 'FALSE');
      x_valid_config     := nvl(l_valid_config, 'FALSE');


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXITING OE_CONFIG_UTIL.PARSE_OUTPUT_XML' , 1);
      END IF;

EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('SPC EXIT TAG IS ERROR' , 1);
         END IF;

      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('PARSE_OUTPUT_XML ERROR: '
                            || SUBSTR ( SQLERRM , 1 , 100 ) , 1);
         END IF;

END Parse_output_xml;


/*----------------------------------------------------------------------
Procedure Name : Query_Options
Description    :
-----------------------------------------------------------------------*/
PROCEDURE Query_Options
(p_top_model_line_id IN NUMBER
,p_send_cancel_lines IN VARCHAR2 := 'N'
,p_source_type       IN VARCHAR2 := ''
,x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type)
IS
    l_header_id           NUMBER := 0;
    l_line_rec            OE_Order_PUB.Line_Rec_Type
                          := OE_Order_PUB.G_MISS_LINE_REC;

/* adding component number in this cursor to fix bug 2733667 */

    CURSOR c1 IS
    SELECT  line_id
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = l_header_id AND
            TOP_MODEL_LINE_ID   = p_top_model_line_id
    ORDER BY line_number,shipment_number,nvl(option_number,-1),nvl(component_number,-1);

    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.QUERY_OPTIONS' , 1);
      oe_debug_pub.add('SEND_CANCEL_LINES: '|| P_SEND_CANCEL_LINES , 3 );
    END IF;

    BEGIN
        SELECT header_id
        INTO   l_header_id
        FROM   oe_order_lines_all
        WHERE  line_id = p_top_model_line_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_header_id := 0;
    END;

    --  Loop over fetched records
    FOR op in C1 LOOP

      OE_Line_Util.Query_Row( p_line_id  => op.line_id
                             ,x_line_rec => l_line_rec );

      IF (l_line_rec.open_flag = 'Y' OR
          p_send_cancel_lines = 'Y') AND
          l_line_rec.source_type_code =
            nvl(p_source_type, l_line_rec.source_type_code) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(L_LINE_REC.SOURCE_TYPE_CODE||' ADDING '
                           ||L_LINE_REC.OPEN_FLAG , 3 );
        END IF;

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;
      END IF;
    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONFIG_UTIL.QUERY_OPTIONS' , 1);
    END IF;

END;


/*----------------------------------------------------------------------
Procedure Name : Query_ATO_Options
Description    :
-----------------------------------------------------------------------*/
PROCEDURE Query_ATO_Options
( p_ato_line_id       IN NUMBER
 ,p_send_cancel_lines IN VARCHAR2 := 'N'
 ,p_source_type       IN VARCHAR2 := ''
 ,x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type)
IS
    l_top_model_line_id   NUMBER := 0;
    l_header_id           NUMBER := 0;
    l_line_rec            OE_Order_PUB.Line_Rec_Type
                          := OE_Order_PUB.G_MISS_LINE_REC;


    CURSOR c1 IS
    SELECT  line_id
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = l_header_id AND
            TOP_MODEL_LINE_ID   = l_top_model_line_id AND
            ATO_LINE_ID   = p_ato_line_id
    ORDER BY line_number,shipment_number,nvl(option_number,-1);
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.QUERY_ATO_OPTIONS' , 1);
      oe_debug_pub.add('SEND_CANCEL_LINES: '|| P_SEND_CANCEL_LINES , 3 );
    END IF;

     BEGIN
        SELECT top_model_line_id ,header_id
        INTO   l_top_model_line_id,l_header_id
        FROM   oe_order_lines_all
        WHERE  line_id = p_ato_line_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_top_model_line_id := 0;
             l_header_id := 0;
     END;

    --  Loop over fetched records
    FOR ato_option in C1 LOOP

      OE_Line_Util.Query_Row( p_line_id  => ato_option.line_id
                             ,x_line_rec => l_line_rec );

      IF (l_line_rec.open_flag = 'Y' OR
          p_send_cancel_lines = 'Y') AND
          l_line_rec.source_type_code =
            nvl(p_source_type, l_line_rec.source_type_code) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(L_LINE_REC.SOURCE_TYPE_CODE||' ADDING '
                           ||L_LINE_REC.OPEN_FLAG , 3 );
        END IF;
        l_line_rec.reserved_quantity := Null;
        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;
      END IF;

    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONFIG_UTIL.QUERY_ATO_OPTIONS' , 1);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


/*----------------------------------------------------------------------
Procedure Name : Explode
Description    :
-----------------------------------------------------------------------*/
Procedure Explode
( p_validation_org IN  NUMBER
, p_group_id       IN  NUMBER := NULL
, p_session_id     IN  NUMBER := NULL
, p_levels         IN  NUMBER := 60
, p_stdcompflag    IN  VARCHAR2
, p_exp_quantity   IN  NUMBER := NULL
, p_top_item_id    IN  NUMBER
, p_revdate        IN  DATE
, p_component_code IN  VARCHAR2 := NULL
, x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_error_code     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_group_id   NUMBER; -- bom out NOCOPY param
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.EXPLODE' , 1);
      oe_debug_pub.add(' EXPLOSION TYPE ' || P_STDCOMPFLAG , 2 );
    END IF;

    BOMPNORD.Bmxporder_Explode_For_Order(
          org_id             => p_validation_org,
          copy_flag          => 2,
          expl_type          => p_stdcompflag,
          order_by           => 2,
          grp_id             => l_group_id,
          session_id         => p_session_id,
          levels_to_explode  => 60,
          item_id            => p_top_item_id,
          rev_date           => to_char(p_revdate,'YYYY/MM/DD HH24:MI'),
          user_id            => 0,
          commit_flag        => 'N',
          err_msg            => x_msg_data,
          error_code         => x_error_code);

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AFTER CALLING BOM EXPLODE API' , 2 );
    END IF;

    IF x_error_code <> 0 THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ERROR IN BOM EXPLOSION' , 2 );
        oe_debug_pub.add('ERROR CODE IS ' || X_ERROR_CODE , 2 );
      END IF;

      IF x_msg_data is not null THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('BOM MSG NAME: '
                           || SUBSTR ( X_MSG_DATA , 1 , 250 ) , 2 );
        END IF;

        -- girish from bom team told err_msg is msg name, track bug 1623728
--        FND_MESSAGE.Set_Name('BOM', x_msg_data);
--        oe_msg_pub.add;
        -- After BOM ER 2700606, BOM is sending a complete message
          oe_msg_pub.add_text(p_message_text => x_msg_data);

      END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONFIG_UTIL.EXPLODE' , 1);
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
END Explode;

/*----------------------------------------------------------------------
Procedure Name : Query_Included_Item
Description    : CURRENTLY NOT USED.
-----------------------------------------------------------------------*/
PROCEDURE Query_Included_Item
( p_top_model_line_id     IN  NUMBER
, p_component_seqeunce_id IN  NUMBER
, p_component_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_line_rec              OUT NOCOPY  OE_ORDER_PUB.line_rec_type)
IS
l_line_rec OE_ORDER_PUB.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_line_rec := l_line_rec;
END Query_Included_Item;

/*----------------------------------------------------------------------
Procedure Name : Query_Included_Items
Description    : Queries all the included items for a particular
                 parent line.
-----------------------------------------------------------------------*/
PROCEDURE Query_Included_Items
( p_line_id           IN  NUMBER
, p_header_id         IN  NUMBER   := FND_API.G_MISS_NUM
, p_top_model_line_id IN  NUMBER   := FND_API.G_MISS_NUM
, p_send_cancel_lines IN  VARCHAR2 := 'N'
, p_source_type       IN  VARCHAR2 := ''
, x_line_tbl          OUT NOCOPY OE_ORDER_PUB.line_tbl_type)
IS
    l_top_model_line_id   NUMBER := 0;
    l_header_id           NUMBER := 0;
    l_line_rec            OE_Order_PUB.Line_Rec_Type
                          := OE_Order_PUB.G_MISS_LINE_REC;


    CURSOR c1 IS
    SELECT  line_id
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = l_header_id AND
            TOP_MODEL_LINE_ID   = l_top_model_line_id AND
            LINK_TO_LINE_ID   = p_line_id AND
            ITEM_TYPE_CODE    = OE_GLOBALS.G_ITEM_INCLUDED
    ORDER BY line_number,shipment_number,nvl(option_number,-1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('SEND_CANCEL_LINES: '|| P_SEND_CANCEL_LINES , 3 );
     END IF;

     IF p_header_id = FND_API.G_MISS_NUM AND
        p_top_model_line_id = FND_API.G_MISS_NUM THEN

        BEGIN
           SELECT top_model_line_id ,header_id
           INTO   l_top_model_line_id,l_header_id
           FROM   oe_order_lines_all
           WHERE  line_id = p_line_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_top_model_line_id := 0;
                l_header_id := 0;
        END;

      ELSE

        l_top_model_line_id := p_top_model_line_id;
        l_header_id := p_header_id;

      END IF;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('HEADER ID , TOP MODEL LINE ID '
                            ||L_HEADER_ID||'/'||L_TOP_MODEL_LINE_ID , 3 );
         END IF;

    --  Loop over fetched records
    FOR inc_item in C1 LOOP

      OE_Line_Util.Query_Row( p_line_id  => inc_item.line_id
                             ,x_line_rec => l_line_rec );

      IF (l_line_rec.open_flag = 'Y' OR
          p_send_cancel_lines = 'Y') AND
          l_line_rec.source_type_code =
            nvl(p_source_type, l_line_rec.source_type_code) THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(L_LINE_REC.SOURCE_TYPE_CODE||' ADDING '
                           ||L_LINE_REC.OPEN_FLAG , 3 );
        END IF;

        x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;
      END IF;

    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXITING OE_CONFIG_UTIL.QUERY_INCLUDED_ITEMS' , 1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Included_Items;

-- forward declaration

PROCEDURE update_component_number
(p_line_id           IN  NUMBER ,
 p_top_model_line_id IN  NUMBER ,
 x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

/*----------------------------------------------------------------------
Procedure Name : Process_Included_Items
Description    :
This procedure is used to explode the included items for a
PTO model/class or a kit. This procedure is called from
oe_line_util if,
 the included items freeze method profile options is ENTRY or NULL.
 a new line is created in a booked order.
 a line with included items is schduled.

Lastly if the profile is set to PICK RELEASE OR BOOKING, the
wrapper procedures finally call this method.

Check whether the included items need to be processed
If the line's explosion date is not NULL;
or the line is ATO; or the item type is not a model, kit
or class, then do not process included items

included items  will have same
line + ship + option number combination as the parent line.
However we will populate component_number for them.

To improve performance, we will explicitly log delayed
requests using procedure log_included_items_requests.
We will set the control_rec.change_attributes to FALSE.
However execution of the delayed requests logged in that
procedure is up to the caller of this API.

Change Record:
2002550
  the pricing attributes need to be set to 0, since we are not
  calling apply_attribute_changes as per perf changes.

  Assign pricing_quantity = ordered_quantity and
  pricing_quantity_uom = order_quantity_uom.

2115192
  setting the ordered item field on included items.
  Also, insert_into_set call removed, moved to generic
  model_option_defaulting API.
2508632
  Copy Calculate Price Flag of included items from Parent Line.

Bug 2869052 :
  Default_Child_Line procedure would be called only if there are
  any new included items to be created. If the call returns an
  error an exception would be raised. New variable l_default_child_line
  has been created.
-----------------------------------------------------------------------*/
FUNCTION Process_Included_Items
(p_line_rec         IN OE_ORDER_PUB.line_rec_type
                    := OE_ORDER_PUB.G_MISS_LINE_REC,
 p_line_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_freeze           IN  BOOLEAN,
 p_process_requests IN BOOLEAN DEFAULT FALSE)
RETURN VARCHAR2
IS

  -- process_order in variables
  l_control_rec               OE_GLOBALS.Control_Rec_Type;
  l_header_rec                OE_Order_PUB.Header_Rec_Type;
  l_line_rec                  OE_ORDER_PUB.Line_Rec_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;

  l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  -- procedure variables
  l_parent_line_rec           OE_Order_PUB.Line_Rec_Type;
  l_line_count                NUMBER := 0;
  l_line_id                   NUMBER;
  l_component_number          NUMBER;
  l_adjust_comp_no_flag       VARCHAR2(1) := 'N';
  l_parent_component_sequence_id NUMBER := 0;
  l_option_number             NUMBER;
  l_top_model_quantity        NUMBER := 0;
  l_freeze_method             VARCHAR2(30);
  l_explosion_date            DATE;
  l_validation_org            NUMBER;
  l_error_code                NUMBER;
  l_default_child_line        BOOLEAN  := TRUE;
  l_freeze_macd_kit           BOOLEAN  := FALSE;

  --bug3269648
  l_return_code               NUMBER;
  l_error_buffer              VARCHAR2(240);
  --bug3269648
  -- tso with equipment
  l_top_container_model       VARCHAR2(1);
  l_part_of_container         VARCHAR2(1);
  l_config_mode               NUMBER;
  l_cz_config_mode               NUMBER;
  l_x_return_status           VARCHAR2(1);

   CURSOR new_included_items(p_top_bill_sequence_id IN NUMBER,
                             p_top_model_line_id    IN NUMBER,
                             p_std_comp_freeze_date IN DATE)
   IS
    SELECT
      component_item_id,
      component_sequence_id,
      extended_quantity,
      component_code,
      PRIMARY_UOM_CODE,
      sort_order
    FROM bom_explosions  be
    WHERE
      be.explosion_type = 'INCLUDED'
      AND be.plan_level >= 0
      AND be.extended_quantity > 0
      AND be.TOP_BILL_SEQUENCE_ID = p_top_bill_sequence_id
      AND be.EFFECTIVITY_DATE <= p_std_comp_freeze_date
      AND be.DISABLE_DATE > p_std_comp_freeze_date
      AND be.COMPONENT_ITEM_ID <> be.TOP_ITEM_ID
      AND NOT EXISTS
          (   SELECT 'X'
                FROM  oe_order_lines l
                WHERE l.top_model_line_id = p_top_model_line_id
                AND   l.link_to_line_id   = l_parent_line_rec.line_id
                AND   l.component_code = be.component_code
                AND   l.open_flag = 'Y')
    ORDER BY sort_order;
    --ORDER BY COMPONENT_ITEM_ID, COMPONENT_CODE ;


  CURSOR update_included_items(p_top_bill_sequence_id IN NUMBER,
                               p_top_model_line_id    IN NUMBER,
                               p_top_model_quantity   IN NUMBER,
                               p_std_comp_freeze_date IN DATE)
  IS
    SELECT
         oel.line_id, be.extended_quantity * p_top_model_quantity
    FROM oe_order_lines oel, bom_explosions be
    WHERE oel.top_model_line_id = p_top_model_line_id
    AND oel.link_to_line_id     = l_parent_line_rec.line_id
    AND oel.item_type_code = 'INCLUDED'
    AND be.explosion_type = 'INCLUDED'
    AND be.plan_level >= 0
    AND be.TOP_BILL_SEQUENCE_ID = p_top_bill_sequence_id
    AND be.EFFECTIVITY_DATE <= p_std_comp_freeze_date
    AND be.DISABLE_DATE > p_std_comp_freeze_date
    AND be.COMPONENT_ITEM_ID <> be.TOP_ITEM_ID
    AND be.component_code = oel.component_code
    AND oel.ordered_quantity/p_top_model_quantity <> be.extended_quantity
    AND oel.open_flag = 'Y';


  CURSOR outdated_included_items(p_top_bill_sequence_id IN NUMBER,
                                 p_top_model_line_id    IN NUMBER,
                                 p_std_comp_freeze_date IN DATE)
  IS
    SELECT
         l.line_id
    FROM  oe_order_lines l
    WHERE l.link_to_line_id = l_parent_line_rec.line_id
    AND   l.top_model_line_id = p_top_model_line_id
    AND   l.item_type_code = 'INCLUDED'
    AND   l.open_flag = 'Y'
    AND NOT EXISTS
          (   SELECT 'X'
           FROM  bom_explosions be
           WHERE be.component_code = l.component_code
           AND be.explosion_type   = 'INCLUDED'
           AND be.plan_level >= 0
           AND be.TOP_BILL_SEQUENCE_ID =  p_top_bill_sequence_id
           AND be.EFFECTIVITY_DATE <= p_std_comp_freeze_date
           AND be.DISABLE_DATE > p_std_comp_freeze_date);

    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

  Print_Time('Entering oe_config_util.process_included_items');

  l_parent_line_rec := p_line_rec;

  IF p_line_rec.line_id <> FND_API.G_MISS_NUM AND
     p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('DO NOT LOCK' , 3 );
     END IF;
  ELSE
    IF p_line_id = FND_API.G_MISS_NUM THEN
      OE_LINE_UTIL.Lock_Row
      (p_line_id       => p_line_rec.line_id
      ,p_x_line_rec    => l_parent_line_rec
      ,x_return_status => l_return_status);
       -- Parent Line has been passed
       l_parent_line_rec := p_line_rec;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('P_LINE_ID IS MISS_NUM' , 3 );
       END IF;
    ELSE
       -- Query the Parent Line
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('PARENT LINE_ID: '|| P_LINE_ID , 2 );
      END IF;

      OE_LINE_UTIL.Lock_Row
      (p_line_id       => p_line_id
      ,p_x_line_rec    => l_parent_line_rec
      ,x_return_status => l_return_status);
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ROW LOCKED' , 3 );
    END IF;
  END IF;


  IF l_parent_line_rec.explosion_date is not null OR
     l_parent_line_rec.ato_line_id is not null OR
     l_parent_line_rec.item_type_code not in
     ('MODEL', 'KIT', 'CLASS') OR
     l_parent_line_rec.ordered_quantity = 0
  THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('RETURNING FROM PROC_INC_ITEMS' , 3 );
    END IF;
    RETURN l_return_status;
  END IF;

  -- TSO with Equipment starts
  IF l_parent_line_rec.line_id <> l_parent_line_rec.top_model_line_id AND
     l_parent_line_rec.item_type_code = 'KIT' THEN

    OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
    (p_line_id              =>  l_parent_line_rec.line_id ,
     x_top_container_model  =>  l_top_container_model,
     x_part_of_container    =>  l_part_of_container);

    -- The line is part of container
    IF l_part_of_container = 'Y' THEN

      OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode
      (  p_line_id           => l_parent_line_rec.line_id
        ,x_config_mode       => l_config_mode
        ,x_return_status     => l_x_return_status );

      IF l_config_mode <> 1 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Returning from Process_included_items for Kit in TSO configuration' , 3 );
        END IF;

        l_cz_config_mode :=
          CZ_NETWORK_API_PUB.is_item_added (p_config_hdr_id  => l_parent_line_rec.config_header_id
                                           ,p_config_rev_nbr => l_parent_line_rec.config_rev_nbr
                                           ,p_config_item_id => l_parent_line_rec.configuration_id);
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('After calling CZ_NETWORK_API_PUB.is_item_added: ' || l_cz_config_mode );
        END IF;
        IF l_cz_config_mode = 0 THEN
           --RETURN l_return_status;
           l_freeze_macd_kit := TRUE;
        END IF;
      END IF; -- Mode
    END IF;  -- Container
  END IF; -- KIT
  -- TSO with Equipment ends

  l_freeze_method := G_FREEZE_METHOD; /* Bug # 5036404 */

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('METHOD: '|| L_FREEZE_METHOD , 4 );
  END IF;
  -- 4359339
  l_freeze_method := nvl(l_freeze_method, OE_GLOBALS.G_IIFM_ENTRY);

  IF l_parent_line_rec.creation_date is null OR
     l_freeze_method <> OE_GLOBALS.G_IIFM_ENTRY
  THEN
     l_explosion_date := sysdate;
  ELSE
     l_explosion_date := l_parent_line_rec.creation_date;
  END IF;

  IF l_freeze_macd_kit THEN

     l_explosion_date := sysdate;
     l_return_status := FND_API.G_RET_STS_SUCCESS;
     GOTO UPDATE_EXP_DATE;

  END IF;
  l_validation_org    := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXPLOSION_DATE: ' || L_EXPLOSION_DATE , 2 );
    oe_debug_pub.add('P_TOP_ITEM_ID: '
                     || L_PARENT_LINE_REC.INVENTORY_ITEM_ID , 2 );
    oe_debug_pub.add('EXPLODING WITH ORG : ' || L_VALIDATION_ORG , 2 );
  END IF;

  Explode(p_validation_org => l_validation_org,
          p_levels         => 6, --??
          p_stdcompflag    => OE_BMX_STD_COMPS_ONLY,
          p_top_item_id    => l_parent_line_rec.inventory_item_id,
          p_revdate        => l_explosion_date,
          x_msg_data       => l_msg_data,
          x_error_code     => l_error_code,
          x_return_status  => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;


  BEGIN
    SELECT bill_sequence_id
    INTO   l_parent_component_sequence_id
    FROM   bom_bill_of_materials
    WHERE  ASSEMBLY_ITEM_ID = l_parent_line_rec.inventory_item_id
    AND    ORGANIZATION_ID = l_validation_org
    AND    ALTERNATE_BOM_DESIGNATOR IS NULL;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('BILL SEQ ID '||L_PARENT_COMPONENT_SEQUENCE_ID , 1);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('BILL DOES NOT EXIST FOR THIS ITEM' , 3 );
      END IF;
      l_parent_component_sequence_id := 0;
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('UNEXPECTED ERROR WHILE GETTING BILL SEQUENCE ID' , 3 );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  BEGIN
    SELECT max(component_number)
    INTO   l_component_number
    FROM   oe_order_lines
    WHERE  link_to_line_id = p_line_id
    AND    top_model_line_id = l_parent_line_rec.top_model_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  l_line_rec := OE_Order_PUB.G_MISS_LINE_REC;

  OPEN new_included_items
     (p_top_bill_sequence_id =>  l_parent_component_sequence_id,
      p_top_model_line_id    =>  l_parent_line_rec.top_model_line_id,
      p_std_comp_freeze_date =>  l_explosion_date);

  LOOP
    FETCH new_included_items
    INTO  l_line_rec.inventory_item_id, l_line_rec.component_sequence_id,
          l_line_rec.ordered_quantity, l_line_rec.component_code,
          l_line_rec.order_quantity_uom, l_line_rec.sort_order;
    EXIT WHEN new_included_items%NOTFOUND;

    IF l_default_child_line THEN

       ------ 1. Insert new included items
       l_component_number     := nvl(l_component_number, 0);
       l_line_rec.operation   := OE_GLOBALS.G_OPR_CREATE;
       l_line_rec.item_identifier_type := 'INT';
       l_line_rec.option_number     := l_parent_line_rec.option_number;
       l_line_rec.item_type_code    := OE_GLOBALS.G_ITEM_INCLUDED;
       l_line_rec.top_model_line_id := l_parent_line_rec.top_model_line_id;
       l_line_rec.link_to_line_id   := l_parent_line_rec.line_id;
       l_line_rec.model_remnant_flag:= l_parent_line_rec.model_remnant_flag;
       l_line_rec.header_id         := l_parent_line_rec.header_id;
       l_line_rec.unit_list_price   := 0;
       l_line_rec.unit_selling_price          :=0;
       l_line_rec.unit_list_price_per_pqty    :=0;
       l_line_rec.unit_selling_price_per_pqty :=0;
       l_line_rec.calculate_price_flag :=
                           l_parent_line_rec.calculate_price_flag;


       IF l_parent_line_rec.booked_flag = 'Y' THEN
         l_line_rec.flow_status_code := 'BOOKED';
       ELSE
         l_line_rec.flow_status_code := 'ENTERED';
       END IF;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('CALLING DEFAULT CHILD' , 2 );
       END IF;

       default_child_line
       (p_parent_line_rec  => l_parent_line_rec,
        p_x_child_line_rec => l_line_rec,
        x_return_status    => l_return_status);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_default_child_line := FALSE;

    END IF;

    -- Get the concatanted segment value to be stored in
    -- order lines at ordered_item

    BEGIN
      SELECT concatenated_segments
      INTO   l_line_rec.ordered_item
      FROM   MTL_SYSTEM_ITEMS_KFV
      WHERE  inventory_item_id = l_line_rec.inventory_item_id
      AND    organization_id   = l_validation_org;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('CANCAT SEG FETCH ERROR' , 3 );
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ORD ITEM IS: ' || L_LINE_REC.ORDERED_ITEM , 5 );
      oe_debug_pub.add('INSERTING....'|| L_LINE_REC.COMPONENT_CODE , 2 );
    END IF;

    -- Adding this flag for fulfillment purpose.

    SELECT OE_ORDER_LINES_S.NEXTVAL
    INTO   l_line_rec.line_id
    FROM   dual;

    l_component_number          := l_component_number + 1;
    l_line_rec.component_number := l_component_number;
    l_line_rec.ordered_quantity := l_parent_line_rec.ordered_quantity
                                   * l_line_rec.ordered_quantity;
    l_line_rec.pricing_quantity := l_line_rec.ordered_quantity;
    l_line_rec.pricing_quantity_uom := l_line_rec.order_quantity_uom;
    l_line_rec.line_type_id         := l_parent_line_rec.line_type_id;
    l_line_rec.org_id               := l_parent_line_rec.org_id;   -- Bug 6058501
    --Bug 4153518: Intialized Global DFF values to NULL
    l_line_rec.global_attribute1 := NULL;
    l_line_rec.global_attribute2 := NULL;
    l_line_rec.global_attribute3 := NULL;
    l_line_rec.global_attribute4 := NULL;
    l_line_rec.global_attribute5 := NULL;
    l_line_rec.global_attribute6 := NULL;
    l_line_rec.global_attribute7 := NULL;
    l_line_rec.global_attribute8 := NULL;
    l_line_rec.global_attribute9 := NULL;
    l_line_rec.global_attribute10 := NULL;
    l_line_rec.global_attribute11 := NULL;
    l_line_rec.global_attribute12 := NULL;
    l_line_rec.global_attribute13 := NULL;
    l_line_rec.global_attribute14 := NULL;
    l_line_rec.global_attribute15 := NULL;
    l_line_rec.global_attribute16 := NULL;
    l_line_rec.global_attribute17 := NULL;
    l_line_rec.global_attribute18 := NULL;
    l_line_rec.global_attribute19 := NULL;
    l_line_rec.global_attribute20 := NULL;
    l_line_rec.global_attribute_category := NULL;

    --bug3269648 start
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Before calling JG ',2);
    END IF;

    JG_ZZ_OM_COMMON_PKG.default_gdf
    (  x_line_rec     => l_line_rec
      ,x_return_code  => l_return_code
      ,x_error_buffer => l_error_buffer );

    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('After JG Call:'|| l_return_code || l_error_buffer,2);
    END IF;
    --bug3269648 ends

    l_line_count                := l_line_count + 1;
    l_line_tbl(l_line_count)    := l_line_rec;

  END LOOP;
  CLOSE new_included_items;


  -- open cursors only if some records exist to upd/del
  SELECT count(*)
  INTO   l_top_model_quantity
  FROM   oe_order_lines
  WHERE  item_type_code = 'INCLUDED'
  AND    top_model_line_id = l_parent_line_rec.top_model_line_id
  AND    link_to_line_id   = l_parent_line_rec.line_id;

  IF l_top_model_quantity > 0 THEN

    ----- 2. Update existing included items which needs to be updated

    IF l_parent_line_rec.ordered_quantity is null THEN
      l_top_model_quantity := 1;
    ELSE
      l_top_model_quantity := l_parent_line_rec.ordered_quantity;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('MODEL ORDERED QUANTITY IS'
                       || L_TOP_MODEL_QUANTITY , 2 );
    END IF;

    l_line_rec             := OE_Order_PUB.G_MISS_LINE_REC;
    l_line_rec.operation   := OE_GLOBALS.G_OPR_UPDATE;
    l_line_rec.header_id   := l_parent_line_rec.header_id;

    OPEN update_included_items
       (p_top_bill_sequence_id =>  l_parent_component_sequence_id,
        p_top_model_line_id    =>  l_parent_line_rec.top_model_line_id,
        p_top_model_quantity   =>  l_top_model_quantity,
        p_std_comp_freeze_date =>  l_explosion_date);
    LOOP

      FETCH update_included_items
      INTO  l_line_rec.line_id, l_line_rec.ordered_quantity;
      EXIT WHEN update_included_items%NOTFOUND;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('UPDATING....'|| L_LINE_REC.COMPONENT_CODE , 2 );
      END IF;

      -- Audit Trail
      l_line_rec.change_reason   := 'SYSTEM';
      l_line_count               := l_line_count + 1;
      l_line_tbl(l_line_count)   := l_line_rec;

    END LOOP;
    CLOSE update_included_items;


    ----- 3. Delete and included items that are not valid anymore

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('TOP MODEL LINE:' || L_PARENT_LINE_REC.LINE_ID , 2 );
    END IF;

    l_line_rec                := OE_Order_PUB.G_MISS_LINE_REC;
    l_line_rec.operation      := OE_GLOBALS.G_OPR_DELETE;
    l_line_rec.header_id      := l_parent_line_rec.header_id;

    OPEN outdated_included_items
    (p_top_bill_sequence_id =>  l_parent_component_sequence_id,
     p_top_model_line_id    =>  l_parent_line_rec.top_model_line_id,
     p_std_comp_freeze_date =>  l_explosion_date);
    LOOP
      FETCH outdated_included_items
      INTO  l_line_rec.line_id;
      EXIT WHEN outdated_included_items%NOTFOUND;

      l_adjust_comp_no_flag := 'Y';

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('DELETING....'|| L_LINE_REC.LINE_ID , 2 );
      END IF;

      l_line_count             := l_line_count + 1;
      l_line_tbl(l_line_count) := l_line_rec;

    END LOOP;
    CLOSE outdated_included_items;

  END IF; -- no need to open cursors

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NO. OF LINES ' || TO_CHAR ( L_LINE_COUNT ) , 2 );
  END IF;

  IF l_line_count > 0 THEN
    l_header_rec.operation := OE_GLOBALS.G_OPR_NONE;
    l_header_rec.header_id := l_parent_line_rec.header_id;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('CALLING PROCESS_ORDER' , 2 );
    END IF;

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := FALSE;
    l_control_rec.change_attributes    := FALSE;

    OE_ORDER_PVT.Lines
    (p_validation_level         => FND_API.G_VALID_LEVEL_NONE
    ,p_control_rec              => l_control_rec
    ,p_x_line_tbl               => l_line_tbl
    ,p_x_old_line_tbl           => l_old_line_tbl
    ,x_return_status            => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    Log_Included_Item_Requests
    ( p_line_tbl     => l_line_tbl
     ,p_booked_flag  => l_parent_line_rec.booked_flag);


    OE_ORDER_PVT.Process_Requests_And_notify
    (p_process_requests       => p_process_requests
    ,p_notify                 => TRUE
    ,x_return_status          => l_return_status
    ,p_line_tbl               => l_line_tbl
    ,p_old_line_tbl           => l_old_line_tbl);


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF l_adjust_comp_no_flag = 'Y' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('INCLUDED ITEMS GOT DELETED' , 1);
      END IF;

     update_component_number
      (p_line_id           => p_line_id,
       p_top_model_line_id => l_parent_line_rec.top_model_line_id,
       x_return_status     => l_return_status);
    END IF;

    oe_msg_pub.count_and_get
    ( p_count      => l_msg_count
     ,p_data       => l_msg_data  );

  END IF; -- count > 0

  -- now populate the explosion date on parent line, if p_freeze id TRUE.
  <<UPDATE_EXP_DATE>>
  IF nvl(p_freeze, FALSE) = TRUE OR
     l_freeze_macd_kit THEN
    -- Update the explosion date on the model line.
    BEGIN
      UPDATE OE_ORDER_LINES_ALL
      set explosion_date = l_explosion_date,
          lock_control   = lock_control + 1
      WHERE line_id      = l_parent_line_rec.line_id;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;


  Print_Time('Exiting process_included_items: ' || l_return_status);

  RETURN l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        -- bug 4683857
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Process_Included_Items');
        END IF;
        RETURN FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Process_Included_Items');
        END IF;
        RETURN FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,'Process_Included_Items');
        END IF;
        RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END Process_Included_Items;


/*----------------------------------------------------------------------
Procedure Name : update_component_number
Description    : This procedure is written to update the
                 component_number on the included items,
                 if any of them is deleted.

-----------------------------------------------------------------------*/

PROCEDURE update_component_number(p_line_id           IN  NUMBER ,
                                  p_top_model_line_id IN  NUMBER ,
                                  x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

  CURSOR comp_number IS
  SELECT line_id
  FROM   oe_order_lines
  WHERE  link_to_line_id    = p_line_id
  AND    top_model_line_id  = p_top_model_line_id;

  l_component_number NUMBER := 0;
  l_line_id          NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_COMPONENT_NUMBER' , 1);
  END IF;

  OPEN  comp_number;
  LOOP
    FETCH comp_number INTO l_line_id;
    EXIT WHEN comp_number%NOTFOUND;

    l_component_number := l_component_number + 1;

    UPDATE oe_order_lines
    SET    component_number = l_component_number,
           lock_control     = lock_control + 1
    WHERE  line_id = l_line_id;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_COMPONENT_NUMBER' , 1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END update_component_number;

/*----------------------------------------------------------------------
Procedure Name : Supply_Reserved
Description    : This procedure is written for the validation
        template Supply Reserved. It will return 1 if the
                 line is line has supply reserved and 0 otherwise.

-----------------------------------------------------------------------*/
PROCEDURE  Supply_Reserved (
p_application_id               in number,
p_entity_short_name            in varchar2,
p_validation_entity_short_name in varchar2,
p_validation_tmplt_short_name  in varchar2,
p_record_set_short_name        in varchar2,
p_scope                        in varchar2,
x_result                       out NOCOPY /* file.sql.39 change */  number)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   x_result := 0;
END;

/*----------------------------------------------------------------------
Procedure Name : Freeze_Included_Items
Description    :
-----------------------------------------------------------------------*/
FUNCTION Freeze_Included_Items(p_line_id       IN  NUMBER)
RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    RETURN Process_Included_Items(p_line_id => p_line_id,
                                  p_freeze  => TRUE);
END Freeze_Included_Items;



/*----------------------------------------------------------------------
Procedure Name : Is_ATO_Model
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_ATO_Model
(p_line_id    IN  NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec   IN OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_ATO_MODEL FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id  => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
    l_line_rec.ato_line_id = l_line_rec.line_id AND
    l_line_rec.top_model_line_id = l_line_rec.line_id -- redundent
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_MODEL FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_MODEL FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_ATO_MODEL FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXCEPTION IN IS_ATO_MODEL FUNCTION ' , 1);
  END IF;
  RETURN FALSE;
END Is_ATO_Model;



/*----------------------------------------------------------------------
Procedure Name : Is_PTO_Model
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_PTO_Model
(p_line_id   IN   NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec  IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_PTO_MODEL FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
    l_line_rec.ato_line_id IS NULL AND
    l_line_rec.top_model_line_id = l_line_rec.line_id -- redundent
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_MODEL FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_MODEL FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_PTO_MODEL FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXCEPTION IN IS_PTO_MODEL FUNCTION ' , 1);
  END IF;
  RETURN FALSE;
END Is_PTO_Model;

/*----------------------------------------------------------------------
Procedure Name : Is_Included_Option
Description    :
-----------------------------------------------------------------------*/

FUNCTION Is_Included_Option
(p_line_id   IN   NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec  IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_INCLUDED_OPTION FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id  => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_INCLUDED_OPTION FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_INCLUDED_OPTION FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_INCLUDED_OPTION FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXCEPTION IN IS_INCLUDED_OPTION FUNCTION ' , 1);
  END IF;
  RETURN FALSE;
END Is_Included_Option;


/*----------------------------------------------------------------------
Procedure Name : Is_Config_Item
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_Config_Item
(p_line_id  IN    NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN    OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_CONFIG_ITEM FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
      OE_Line_Util.Query_Row(p_line_id => p_line_id
                            ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;


 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_CONFIG_ITEM FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_CONFIG_ITEM FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_CONFIG_ITEM FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXCEPTION IN IS_CONFIG_ITEM FUNCTION ' , 1);
  END IF;
  RETURN FALSE;
END Is_Config_item;

/*----------------------------------------------------------------------
Procedure Name : Is_ATO_Option
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_ATO_Option
(p_line_id  IN NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_ATO_OPTION FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id  => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;


 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
    l_line_rec.ato_line_id is not null AND
    l_line_rec.top_model_line_id = l_line_rec.ato_line_id
    -- not an ato under pto
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_OPTION FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_OPTION FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_ATO_OPTION FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXCEPTION IN IS_ATO_OPTION FUNCTION ' , 1);
  END IF;
  RETURN FALSE;
END Is_ATO_Option;


/*----------------------------------------------------------------------
Procedure Name : Is_PTO_Option
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_PTO_Option
(p_line_id   IN  NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec  IN  OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_PTO_OPTION FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id  => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
    l_line_rec.ato_line_id is null
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_OPTION FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_OPTION FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_PTO_OPTION FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_PTO_OPTION FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_PTO_Option;

/*----------------------------------------------------------------------
Procedure Name : Is_ATO_Class
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_ATO_Class
(p_line_id  IN    NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_ATO_CLASS FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
      OE_Line_Util.Query_Row(p_line_id  => p_line_id
                            ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
    l_line_rec.ato_line_id is not null AND
    l_line_rec.top_model_line_id = l_line_rec.ato_line_id
    -- not an ato under pto
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_ATO_CLASS FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_ATO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_ATO_Class;


/*----------------------------------------------------------------------
Procedure Name : Is_PTO_Class
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_PTO_Class
(p_line_id  IN   NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_PTO_CLASS FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
      OE_Line_Util.Query_Row(p_line_id  => p_line_id
                            ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
    l_line_rec.ato_line_id is not null
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_PTO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_PTO_CLASS FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_PTO_CLASS FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_PTO_Class;


/*----------------------------------------------------------------------
Procedure Name : Is_ATO_Subconfig
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_ATO_Subconfig
(p_line_id  IN    NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_ATO_SUBCONFIG FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
      OE_Line_Util.Query_Row(p_line_id  => p_line_id
                            ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 -- what about subconfig options
 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
    l_line_rec.ato_line_id is not null AND
    l_line_rec.top_model_line_id <> l_line_rec.ato_line_id
    -- ato under pto
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_SUBCONFIG FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_SUBCONFIG FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_ATO_SUBCONFIG FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_ATO_SUBCONFIG FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_ATO_Subconfig;

/*----------------------------------------------------------------------
Procedure Name : Is_Kit
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_Kit
(p_line_id  IN   NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_KIT FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
      OE_Line_Util.Query_Row(p_line_id  => p_line_id
                            ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_KIT FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_KIT FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_KIT FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_KIT FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_Kit;

/*----------------------------------------------------------------------
Procedure Name : Is_Ato_Item
Description    :
-----------------------------------------------------------------------*/
FUNCTION Is_Ato_Item
(p_line_id  IN    NUMBER
               := FND_API.G_MISS_NUM ,
 p_line_rec IN   OE_Order_PUB.LINE_REC_TYPE
               :=  OE_ORDER_PUB.G_MISS_LINE_REC)
RETURN BOOLEAN
IS
l_line_rec     OE_Order_PUB.LINE_REC_TYPE;

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('ENTERING IS_ATO_ITEM FUNCTION ' , 1);
 END IF;

 -- if p_line_rec.line_id is missing, query row
 -- if p_line_id and and p_line_rec both missing, RAISE FND_API.G_EXC_ERROR
 -- if p_line_rec is not missing, use it as line_rec insted of querying.

 IF p_line_rec.line_id = FND_API.G_MISS_NUM THEN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
       OE_Line_Util.Query_Row(p_line_id  => p_line_id
                             ,x_line_rec => l_line_rec);
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
 ELSE
    l_line_rec := p_line_rec;
 END IF;

 IF (l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
     l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
     l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED ) AND -- 9775352
     l_line_rec.ato_line_id = l_line_rec.line_id
 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_ITEM FUNCTION ' , 1);
    END IF;
    RETURN TRUE;
 ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING IS_ATO_ITEM FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
 END IF;

 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING IS_ATO_ITEM FUNCTION ' , 1);
 END IF;

EXCEPTION
  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN IS_ATO_ITEM FUNCTION ' , 1);
    END IF;
    RETURN FALSE;
END Is_Ato_Item;


/*-------------------------------------------------------------------
PROCEDURE  Query_Config:
  This function is called by query_options and query_included_items
  and query_ato_options. For query_ato and query_included, we make
  l_top_model_line_id as null, so that we do not return all the lines
  in that configuration bu only ato options/included items of that line
---------------------------------------------------------------------*/

PROCEDURE  Query_Config
( p_link_to_line_id     IN  NUMBER := FND_API.G_MISS_NUM
  , p_top_model_line_id   IN  NUMBER := FND_API.G_MISS_NUM
  , p_ato_line_id         IN  NUMBER := FND_API.G_MISS_NUM
  , x_line_tbl            OUT NOCOPY OE_ORDER_PUB.line_tbl_type)
IS
l_line_rec           OE_Order_PUB.Line_Rec_Type
                     := OE_Order_PUB.G_MISS_LINE_REC;
l_top_model_line_id  NUMBER;
l_line_id                     NUMBER := 0;
ll_line_id                    NUMBER := 0;
l_header_id                   NUMBER := 0;

    CURSOR l_line_csr(l_top_model_line_id  NUMBER) IS
    SELECT  line_id
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = l_header_id
    AND     (TOP_MODEL_LINE_ID   = l_top_model_line_id OR
            ( LINK_TO_LINE_ID   = p_link_to_line_id AND
              ITEM_TYPE_CODE    = OE_GLOBALS.G_ITEM_INCLUDED AND
              TOP_MODEL_LINE_ID = p_top_model_line_id) OR
            ( ATO_LINE_ID       = p_ato_line_id AND
              TOP_MODEL_LINE_ID = p_top_model_line_id))
    ORDER BY line_number,shipment_number,nvl(option_number,-1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.QUERY_CONFIG' , 1);
    END IF;

    l_top_model_line_id := p_top_model_line_id;

    BEGIN
      IF (p_link_to_line_id is not null and
         p_link_to_line_id <> FND_API.G_MISS_NUM) THEN
         ll_line_id := p_link_to_line_id;
      ELSIF (p_top_model_line_id is not null and
         p_top_model_line_id <> FND_API.G_MISS_NUM) THEN
         ll_line_id := p_top_model_line_id;
      ELSIF (p_ato_line_id is not null and
         p_ato_line_id <> FND_API.G_MISS_NUM) THEN
         ll_line_id := p_ato_line_id;
      ELSE
         ll_line_id := 0;
      END IF;

      SELECT header_id
      INTO l_header_id
      FROM oe_order_lines_all
      WHERE line_id=ll_line_id;

    EXCEPTION
      WHEN OTHERS THEN
        l_header_id:=0;
    END;

    IF p_ato_line_id <> FND_API.G_MISS_NUM OR
       p_link_to_line_id <>  FND_API.G_MISS_NUM THEN
       l_top_model_line_id := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('HEADER_ID: ' || L_HEADER_ID , 3 );
    END IF;

    --  Loop over fetched records
    OPEN l_line_csr(l_top_model_line_id);

    LOOP
      FETCH l_line_csr into l_line_id;
      EXIT WHEN  l_line_csr%NOTFOUND;

      OE_Line_Util.Query_Row( p_line_id  => l_line_id
                             ,x_line_rec => l_line_rec );

      x_line_tbl(x_line_tbl.COUNT + 1) := l_line_rec;

    END LOOP;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LEAVING QUERY CONFIG' , 1);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('NO_DATA_FOUND IN QUERY_CONFIG' , 1);
      END IF;
      RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXC_UNXP IN QUERY_CONFIG' , 1);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OTHERS IN QUERY_CONFIG' , 1);
        END IF;
        OE_MSG_PUB.Add_Exc_Msg
        ( G_PKG_NAME
          , 'Query_Config'
         );
      END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Config;


/*------------------------------------------------------------
helper to see who commits
-------------------------------------------------------------*/

Procedure get_transaction_id(p_caller   IN  VARCHAR2)
IS
l_tran_id       VARCHAR2(1000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--insert into  values(1);
--uncomment when you want to see tran id
--should not go in tst115
l_tran_id := dbms_transaction.local_transaction_id();
IF l_debug_level  > 0 THEN
  oe_debug_pub.add(P_CALLER ||' , TRANSACTION_ID: '|| L_TRAN_ID , 1);
END IF;
END get_transaction_id;




/*-----------------------------------------------------------
PROCEDURE: Complete_Configuration

Description:  if there is any ambiguity, exception here
              will indicate it. component_code should be
              passed in case of ambiguities. sort_order
              and comp_seq_id, I will get it through upd_cur
              in process_config. Component_code can also be
              derived there but we do  not want any ambiuities
              to be passedd to SPC. This procedure will also
              populate the component_sequence_id, sort_order
              and uom on the records if they are null.
------------------------------------------------------------*/

PROCEDURE Complete_Configuration
(p_top_model_line_id     IN  NUMBER,
 x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_sort_order                VARCHAR2(2000);  -- 4336446
l_uom_code                  VARCHAR2(3);
l_model_seq_id              NUMBER;
l_model_comp_seq_id         NUMBER;
l_component_code            VARCHAR2(1000);
l_component_item_id         NUMBER;
l_component_seq_id          NUMBER;
l_rev_date                  DATE;
l_validation_org            NUMBER := OE_SYS_PARAMETERS.VALUE
                                      ('MASTER_ORGANIZATION_ID');
l_group_id                  NUMBER := null;
l_session_id                NUMBER := 0;
l_levels                    NUMBER := 60;
l_stdcompflag               VARCHAR2(10) := Oe_Config_Util.OE_BMX_ALL_COMPS;
l_exp_quantity              NUMBER;
l_top_item_id               NUMBER;
l_num_lines                 NUMBER := 0;
l_model_ordered_item        VARCHAR2(2000);
l_msg_data                  VARCHAR2(2000);
l_error_code                NUMBER;

CURSOR comp_code_upd IS
SELECT line_id, inventory_item_id, ordered_item, component_code
FROM   oe_order_lines
WHERE  top_model_line_id = p_top_model_line_id
AND    item_type_code <> OE_GLOBALS.G_ITEM_CONFIG
AND    open_flag = 'Y'
AND    (component_code is null OR
        component_sequence_id is null OR
        sort_order is null OR
        order_quantity_uom is null
       );

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.COMPLETE_CONFIGURATION' , 1);
  END IF;

  BEGIN

    SELECT creation_date, component_code, component_sequence_id,
           inventory_item_id, ordered_quantity, ordered_item
    INTO   l_rev_date, l_component_code, l_model_seq_id,
           l_top_item_id, l_exp_quantity, l_model_ordered_item
    FROM   oe_order_lines
    WHERE  line_id = p_top_model_line_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('EXCEPTION IN SELECT' , 1);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  END;


   -- Explode the options in Bom_Explosions
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('CALL TO EXPLOSION' , 2 );
    oe_debug_pub.add('ORG ID: '|| L_VALIDATION_ORG , 2 );
  END IF;


  OE_CONFIG_UTIL.Explode
  ( p_validation_org   => l_validation_org
  , p_group_id         => l_group_id
  , p_session_id       => l_session_id
  , p_levels           => l_levels
  , p_stdcompflag      => l_stdcompflag
  , p_exp_quantity     => l_exp_quantity
  , p_top_item_id      => l_top_item_id
  , p_revdate          => l_rev_date
  , p_component_code   => l_component_code
  , x_msg_data         => l_msg_data
  , x_error_code       => l_error_code
  , x_return_status    => l_return_status  );


  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('AFTER CALL TO EXPLODE: '|| L_RETURN_STATUS , 2 );
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_model_seq_id is null THEN

     BEGIN
       SELECT bill_sequence_id
       into l_model_seq_id
       FROM bom_explosions
       WHERE COMPONENT_ITEM_ID = l_top_item_id
       AND ORGANIZATION_ID = l_validation_org
       AND PLAN_LEVEL = 0
       AND effectivity_date <= l_rev_date
       AND disable_date > l_rev_date
       AND explosion_type   =  l_stdcompflag ;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('COMPONENT_SEQUENCE_ID QUERY FAILED' , 1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
     END;

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('COMP_SEQ_ID OF MODEL: ' || L_MODEL_SEQ_ID , 2 );
  END IF;

  FOR line_rec in comp_code_upd
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COMPLETE ITEM: '|| LINE_REC.INVENTORY_ITEM_ID , 1);
    END IF;

    -- 1st obtain component_code using bom_explosions, if the select
    -- statement fetches more than one row, there is ambiguity in the bill
    -- we can not set the component_code for that item.
    BEGIN

      IF line_rec.component_code is not NULL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('COMPONENT CODE PASSED , SOMETHING ELSE NULL' , 3 );
        END IF;

        SELECT component_code, component_sequence_id, sort_order,
               primary_uom_code
        INTO   l_component_code, l_component_seq_id, l_sort_order,
               l_uom_code
        FROM   bom_explosions
        WHERE  component_item_id    = line_rec.inventory_item_id
        AND    explosion_type       = Oe_Config_Util.OE_BMX_ALL_COMPS
        AND    top_bill_sequence_id = l_model_seq_id
        AND    effectivity_date     <= l_rev_date
        AND    disable_date         > l_rev_date
        AND    organization_id      =  l_validation_org
        AND    component_code       = line_rec.component_code;

      ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('COMPONENT CODE NOT PASSED' , 3 );
        END IF;

        SELECT component_code, component_sequence_id, sort_order,
               primary_uom_code
        INTO   l_component_code, l_component_seq_id, l_sort_order,
               l_uom_code
        FROM   bom_explosions
        WHERE  component_item_id    = line_rec.inventory_item_id
        AND    explosion_type       = Oe_Config_Util.OE_BMX_ALL_COMPS
        AND    top_bill_sequence_id = l_model_seq_id
        AND    effectivity_date     <= l_rev_date
        AND    disable_date         > l_rev_date
        AND    organization_id      =  l_validation_org;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SELECT COMP_CODE FAILED , NO DATA FOUND ' , 1);
          oe_debug_pub.add('ITEM: '|| LINE_REC.INVENTORY_ITEM_ID , 1);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_ITEM_NOT_IN_BILL');
        FND_MESSAGE.Set_Token('COMPONENT', nvl(line_rec.ordered_item,line_rec.inventory_item_id));
        FND_MESSAGE.Set_Token('MODEL', nvl(l_model_ordered_item,l_top_item_id));
        oe_msg_pub.add;
        RETURN;

      WHEN TOO_MANY_ROWS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('SELECT COMP_CODE FAILED , TOO_MANY ROWS ' , 1);
          oe_debug_pub.add('ITEM: '|| LINE_REC.INVENTORY_ITEM_ID , 1);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_AMBIGUITY');
        FND_MESSAGE.Set_Token('COMPONENT', nvl(line_rec.ordered_item,line_rec.inventory_item_id));
        FND_MESSAGE.Set_Token('MODEL', nvl(l_model_ordered_item,l_top_item_id));
        oe_msg_pub.add;
       RETURN;

     WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('SELECT COMP_CODE FAILED , OTHERS ' , 1);
         oe_debug_pub.add('ITEM: '|| LINE_REC.INVENTORY_ITEM_ID , 1);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- now update the oe table
    UPDATE oe_order_lines
    SET    component_code        = l_component_code,
           component_sequence_id = l_component_seq_id,
           sort_order            = l_sort_order,
           order_quantity_uom    = l_uom_code,
           lock_control          = lock_control + 1
    WHERE line_id = line_rec.line_id;

  END LOOP;

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF l_debug_level  > 0 THEN
   oe_debug_pub.add('LEAVING COMPLETE CONFIGURATION' , 1);
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('AMBIGUITY IN BILL'|| SUBSTR ( SQLERRM , 1 , 150 ) , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
END Complete_Configuration;


/*----------------------------------------------------------------------
Procedure Name : Match_and_Reserve
Description    :
     -- The Match and Reserve first matches the ordered configuration
     -- against existing configurations.  If a match is found,
     -- it will determine the available quantity to reserve.
     -- If the quantity available to reserve is less than the ordered
     -- quantity, the matching configuration item and available quantity are
     -- displayed for informational purposes.  Reservation should not be an
     -- option to the user.

     -- If sufficient quantity is available (greater than or equal to the
     -- quantity ordered), than this information is also displayed to the
     -- user who should then have the option to reserve.  No partial
     -- reservations are allowed at this time.

     -- no match : message.
     -- match with no qty, no message.
     -- match with qty : disply resv. question.
     -- comment completing w/f , when user said no.
-----------------------------------------------------------------------*/

PROCEDURE Match_and_Reserve
( p_line_id           IN     NUMBER
 ,x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2)
IS
l_line_rec              OE_Order_Pub.line_rec_type;
l_top_model_line_id     NUMBER;
l_ordered_quantity      NUMBER;
l_order_quantity_uom    VARCHAR2(3);
l_config_id             NUMBER;
l_available_qty         NUMBER;
l_quantity_to_reserve   NUMBER;
l_quantity_reserved     NUMBER;
l_message_name          VARCHAR2(30);
l_error_message         VARCHAR2(2000);
l_result                BOOLEAN;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.MATCH_AND_RESERVE' , 1);
     END IF;
     BEGIN
       SELECT top_model_line_id, ordered_quantity, order_quantity_uom
       INTO   l_top_model_line_id, l_ordered_quantity, l_order_quantity_uom
       FROM   oe_order_lines
       WHERE  line_id = p_line_id;
     EXCEPTION
       WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('OTHERS IN MATCH AND RESERVE' , 1);
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;


     IF CTO_MATCH_AND_RESERVE.match_inquiry
        (p_model_line_id         => l_top_model_line_id,
         p_automatic_reservation => FALSE,
         p_quantity_to_reserve   => l_ordered_quantity,
         p_reservation_uom_code  => l_order_quantity_uom,
         x_config_id             => l_config_id,
         x_available_qty         => l_available_qty,
         x_quantity_reserved     => l_quantity_reserved,
         x_error_message         => l_error_message,
         x_message_name          => l_message_name)
     THEN
        IF l_config_id is NOT NULL THEN

          IF  l_available_qty > 0 THEN

            IF l_available_qty < l_ordered_quantity THEN
               l_quantity_to_reserve := l_available_qty;
            ELSE
               l_quantity_to_reserve := l_ordered_quantity;
            END IF;

            l_result := CTO_MATCH_AND_RESERVE.create_config_reservation
                         (p_model_line_id        => l_top_model_line_id,
                          p_config_item_id       => l_config_id,
                          p_quantity_to_reserve  => l_quantity_to_reserve,
                          p_reservation_uom_code => l_order_quantity_uom,
                          x_quantity_reserved    => l_quantity_reserved,
                          x_error_msg            => l_error_message,
                          x_error_msg_name       => l_message_name);

            IF l_message_name IS NOT NULL THEN
              FND_MESSAGE.Set_Name('BOM', l_message_name);
              OE_Msg_Pub.Add;
            END IF;
          END IF;
        ELSE  -- if config_id null
            FND_MESSAGE.Set_Name('BOM', l_message_name);
            OE_Msg_Pub.Add; -- config_id is null
        END IF;

     ELSE -- if cto return true for match
          FND_MESSAGE.Set_Name('BOM', l_message_name);
          OE_Msg_Pub.Add;
     END IF; -- if match found

     x_return_status := l_return_status;
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('EXITING OE_CONFIG_UTIL.MATCH_AND_RESERVE' , 1);
     END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('NO DATA FOUND IN MATCH AND RESERVE' , 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('EXCEPTION IN MATCH AND RESERVE' , 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Match_and_Reserve;


/*----------------------------------------------------------------------
Procedure Name : Delink_Config_batch
Description    : Action supported for Order Import.
Input Parameter: p_line_id : ATO Model Line Id(i.e. immediate parent of CONFIG line)
-----------------------------------------------------------------------*/

PROCEDURE Delink_Config_batch
( p_line_id         IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
   l_config_id      NUMBER ;
   l_item_type_code VARCHAR2(30);
   l_ato_line_id    NUMBER;
   l_inv_item_id    NUMBER;
   l_message_name   VARCHAR2(30);
   l_error_message  VARCHAR2(2000);
   l_table_name     VARCHAR2(30);
   l_cto_result     NUMBER;
   l_result         BOOLEAN;
   l_ordered_item   VARCHAR2(2000);
   l_return_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

   l_config_header_id NUMBER;
   l_config_line_id  NUMBER;
   l_source_type     VARCHAR2(10);
   l_line_num        VARCHAR2(20);
   l_po_header_id    NUMBER;
   --bug 4411054
   --l_po_status       VARCHAR2(4100);
   l_po_status_rec         PO_STATUS_REC_TYPE;
   l_autorization_status   VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTERING DELINK_CONFIG  with :'||p_line_id);
   END IF;

   BEGIN
     SELECT item_type_code, ato_line_id, ordered_item,inventory_item_id
     INTO   l_item_type_code, l_ato_line_id, l_ordered_item,l_inv_item_id
     FROM   oe_order_lines
     WHERE  line_id = p_line_id;
   EXCEPTION
     WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('DELINK BATCH ERROR' , 1);
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
       l_item_type_code = OE_GLOBALS.G_ITEM_CLASS ) AND
       l_ato_line_id = p_line_id THEN

        SELECT inventory_item_id,line_id,header_id,
               RTRIM(line_number||'.'||shipment_number||'.'||
               option_number||'.'||component_number||'.'||
               service_number,'.'),source_type_code
        INTO   l_config_id,l_config_line_id,l_config_header_id,
               l_line_num,l_source_type
        FROM   oe_order_lines
        -- Bug#5026787: Start:- ato_line_id should be used instead of top_model_line_id.
        -- WHERE top_model_line_id = p_line_id
        WHERE ato_line_id = p_line_id
        -- Bug#5026787: End
        AND    item_type_code = 'CONFIG';

        -- Changes for Enhanced DropShipments. Prevent Delink
        -- if the PO associated with config item is Approved.

        IF PO_CODE_RELEASE_GRP.Current_Release >=
            PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
                     OE_CODE_CONTROL.Get_Code_Release_Level  >= '110510' AND
                                               l_source_type = 'EXTERNAL' THEN

           BEGIN
              SELECT po_header_id
              INTO   l_po_header_id
              FROM   oe_drop_ship_sources
              WHERE  line_id    = l_config_line_id
              AND    header_id  = l_config_header_id;
           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   IF l_debug_level  > 0 THEN
                      OE_DEBUG_PUB.Add('PO Not Created for Config.' , 2 );
                   END IF;
           END;

           IF l_po_header_id is not null THEN

              -- comment out for bug 4411054
              /*l_po_status := UPPER(PO_HEADERS_SV3.Get_PO_Status
                                        (x_po_header_id => l_po_header_id
                                        ));
               */
               PO_DOCUMENT_CHECKS_GRP.po_status_check
                                (p_api_version => 1.0
                                , p_header_id => l_po_header_id
                                , p_mode => 'GET_STATUS'
                                , x_po_status_rec => l_po_status_rec
                                , x_return_status => l_return_status);

	        IF(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        	      l_autorization_status := l_po_status_rec.authorization_status(1);

             	      IF l_debug_level > 0 THEN
                	OE_DEBUG_PUB.Add('Sucess call from PO_DOCUMENT_CHECKS_GRP.po_status_check',2);
                	OE_DEBUG_PUB.Add('Check PO Status : '|| l_autorization_status, 2);
             	      END IF;
       		ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             	      RAISE FND_API.G_EXC_ERROR;
       		END IF;

           END IF;

           --IF (INSTR(nvl(l_po_status,'z'), 'APPROVED') <> 0 ) THEN
           IF(nvl(l_autorization_status,'z')= 'APPROVED')  THEN
              FND_MESSAGE.Set_Name('ONT', 'ONT_DELINK_NOT_ALLOWED');
              FND_MESSAGE.Set_Token('LINE_NUM', l_line_num);
              FND_MESSAGE.Set_Token('MODEL', l_ordered_item);
              OE_MSG_PUB.Add;
              RETURN;
           END IF;

        END IF;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('AFTER SELECT STMT.' , 2 );
        END IF;

        l_cto_result := CTO_CONFIG_ITEM_PK.Delink_Item
                        ( pModelLineId      => p_line_id,
                          pConfigId         => l_config_id,
                          xErrorMessage     => l_error_message,
                          xMessageName      => l_message_name,
                          xTableName        => l_table_name);

        --returns 1 in case of successful completion, 0 in case of error

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('AFTER CALL TO CTO_CONFIG_ITEM_PK.DELINK_ITEM ',2);
          oe_debug_pub.add('L_CTO_RESULT:'|| L_CTO_RESULT , 2 );
        END IF;

        IF (l_cto_result = 1) THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('DELINKED CONFIG ITEM' , 2 );
            END IF;
        ELSE
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('CTO RESULT NOT 1' , 2 );
            END IF;
            IF l_message_name IS NOT NULL THEN
                 FND_MESSAGE.Set_Name('BOM', l_message_name);
                 oe_msg_pub.add;
            ELSE
                 IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('CTO MESSAGE NAME NULL' , 2 );
                 END IF;
            END IF;
        END IF;
   ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('DELINK_CONFIG_ITEM ALLOWED ONLY FROM ATO MODEL',1);
        END IF;
        FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_INVALID_ACTION');
        FND_MESSAGE.Set_Token('ACTION', 'Delink Config');
        oe_msg_pub.add;
   END IF;

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('EXITING OE_CONFIG_UTIL.DELINK_CONFIG' , 1);
   END IF;

   x_return_status := l_return_status;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_NO_ITEM_TO_DELINK');
    FND_MESSAGE.Set_Token('MODEL', nvl(l_ordered_item,l_inv_item_id));
    oe_msg_pub.add;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN DELINK_CONFIG' , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Delink_Config_batch;


/*----------------------------------------------------------------------
Procedure Name : Part_of_Configuration
Description    : API used for constraint evaluation.
                 Result of 1 means operation is constrained.
-----------------------------------------------------------------------*/

PROCEDURE Part_of_Configuration
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER )
IS
  l_item_type_code      VARCHAR2(30);
  l_header_id           NUMBER;
  l_top_model_line_id   NUMBER;
  l_line_id             NUMBER;
  l_count               NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.PART_OF_CONFIGURATION' , 1);
  END IF;

  SELECT item_type_code,header_id, top_model_line_id, line_id
  INTO   l_item_type_code,l_header_id, l_top_model_line_id, l_line_id
  FROM   oe_order_lines
  WHERE  line_id = oe_line_security.g_record.line_id;

  IF l_item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
     l_item_type_code = OE_GLOBALS.G_ITEM_SERVICE  OR
     l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
  THEN
    x_result := 0;
    RETURN;
  END IF;

  IF  l_item_type_code = OE_GLOBALS.G_ITEM_CLASS  OR
      l_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
      l_item_type_code = OE_GLOBALS.G_ITEM_CONFIG OR
      ( l_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
        l_top_model_line_id <> l_line_id)
  THEN
    x_result := 1;
    RETURN;
  END IF;

  l_count := 0;

  IF  l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
     ( l_item_type_code = OE_GLOBALS.G_ITEM_KIT AND
       l_top_model_line_id = l_line_id)
  THEN
    SELECT count(*)
    INTO   l_count
    FROM   OE_ORDER_LINES
    WHERE  top_model_line_id = oe_line_security.g_record.line_id
    AND    line_id          <> oe_line_security.g_record.line_id
    AND    header_id         = l_header_id;

    IF l_count > 0 THEN
      x_result := 1;
      RETURN;
    ELSE
      x_result := 0;
      RETURN;
    END IF;
  END IF;

  x_result := 0;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING PART_OF_CONFIGURATION, UNKNOWN ITEM_TYPE', 1);
  END IF;

END Part_of_Configuration;

/*----------------------------------------------------------------------
Procedure Name :  Link_Config
Description    : Action supported for Order Import.

-----------------------------------------------------------------------*/

PROCEDURE  Link_Config
( p_line_id         IN  NUMBER
, p_config_item_id  IN  NUMBER
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
   l_item_type_code      VARCHAR2(30);
   l_ato_line_id         NUMBER;
   l_message_name        VARCHAR2(30);
   l_error_message       VARCHAR2(2000);
   l_table_name          VARCHAR2(30);
   l_result              BOOLEAN;
   l_cto_result          NUMBER(38) := 0;
   l_ordered_item        VARCHAR2(2000);
   l_valid               NUMBER;
   l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.LINK_CONFIG' , 1);
   END IF;

   BEGIN
     SELECT item_type_code, ato_line_id, ordered_item
     INTO   l_item_type_code, l_ato_line_id, l_ordered_item
     FROM   oe_order_lines
     WHERE  line_id = p_line_id;
   EXCEPTION
     WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('LINK CONFIG ERROR' , 2 );
       END IF;
       l_valid := 1;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   IF (l_item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
       l_item_type_code = OE_GLOBALS.G_ITEM_CLASS ) AND
       l_ato_line_id = p_line_id THEN

        l_valid := 0;

        SELECT distinct 1
        INTO l_valid
        FROM oe_order_lines_all oel,
             mtl_system_items msi
        WHERE oel.line_id = p_line_id
        AND oel.inventory_item_id = msi.base_item_id
        AND msi.inventory_item_id = p_config_item_id;

        l_result :=   CTO_MANUAL_LINK_CONFIG.link_config
                      ( p_model_line_id  => p_line_id,
                        p_config_item_id => p_config_item_id,
                        x_error_message  => l_error_message,
                        x_message_name   => l_message_name );

       IF NOT (l_result) THEN
         FND_MESSAGE.Set_Name('BOM', l_message_name);
         oe_msg_pub.add();
       END IF;

   ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('LINK_CONFIG_ITEM ALLOWED ONLY FROM ATO MODEL', 2 );
        END IF;
        FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_INVALID_ACTION');
        FND_MESSAGE.Set_Token('ACTION', 'Link Config');
        oe_msg_pub.add;
   END IF;

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.LINK_CONFIG' , 1);
   END IF;

   x_return_status := l_return_status;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION IN LINK_CONFIG' , 1);
    END IF;

       IF l_valid = 0 THEN
          FND_MESSAGE.Set_Name('BOM', 'CTO_INVALID_LINK_ERROR');
          OE_Msg_Pub.add;
       END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Link_Config;


/*----------------------------------------------------------------------
Procedure Name :  Update_Comp_Seq_Id
Description    :  API for CTO to do a direct update on
                  oe_order_lines w/o calling process_order.
-----------------------------------------------------------------------*/

PROCEDURE Update_Comp_Seq_Id
( p_line_id        IN  NUMBER
 ,p_comp_seq_id    IN  NUMBER
 ,x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_COMP_SEQ_ID' , 1);
  END IF;

  UPDATE oe_order_lines
  SET    component_sequence_id = p_comp_seq_id
        ,last_update_date      = sysdate
        ,last_updated_by       = FND_Global.User_Id
        ,last_update_login     = FND_Global.Login_Id
        ,lock_control          = lock_control + 1
  where  line_id = p_line_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_COMP_SEQ_ID' , 1);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO_DATA_FOUND IN UPDATE_COMP_SEQ_ID' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION IN UPDATE_COMP_SEQ_ID' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Comp_Seq_Id;


/*----------------------------------------------------------------------
Procedure Name :  Update_Visible_Demand_Flag
Description    :  API for CTO to do a direct update on
                  oe_order_lines w/o calling process_order.
-----------------------------------------------------------------------*/

PROCEDURE  Update_Visible_Demand_Flag
( p_ato_line_id            IN  NUMBER
 ,p_visible_demand_flag    IN  VARCHAR2 := 'N'
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_VISIBLE_DEMAND_FLAG' , 1);
  END IF;

  UPDATE oe_order_lines
  SET    visible_demand_flag = p_visible_demand_flag
        ,last_update_date      = sysdate
        ,last_updated_by       = FND_Global.User_Id
        ,last_update_login     = FND_Global.Login_Id
        ,lock_control          = lock_control + 1
  where  ato_line_id = p_ato_line_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_VISIBLE_DEMAND_FLAG' , 1);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO_DATA_FOUND IN UPDATE_VISIBLE_DEMAND_FLAG' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION IN UPDATE_VISIBLE_DEMAND_FLAG' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END  Update_Visible_Demand_Flag;


/*----------------------------------------------------------------------
Procedure Name :  Update_Mfg_Comp_Seq_Id
Description    :  API for CTO to do a direct update on
                  oe_order_lines w/o calling process_order.
-----------------------------------------------------------------------*/

PROCEDURE  Update_Mfg_Comp_Seq_Id
( p_ato_line_id            IN  NUMBER
 ,p_mfg_comp_seq_id        IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_MFG_COMP_SEQ_ID' , 1);
  END IF;

  UPDATE oe_order_lines_all
  SET    mfg_component_sequence_id = p_mfg_comp_seq_id
        ,last_update_date      = sysdate
        ,last_updated_by       = FND_Global.User_Id
        ,last_update_login     = FND_Global.Login_Id
        ,lock_control          = lock_control + 1
  where  ato_line_id = p_ato_line_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_MFG_COMP_SEQ_ID' , 1);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO_DATA_FOUND IN UPDATE_MFG_COMP_SEQ_ID' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION IN UPDATE_MFG_COMP_SEQ_ID' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END  Update_Mfg_Comp_Seq_Id;


/*----------------------------------------------------------------------
Procedure Name :  Update_Model_Group_Number
Description    :  API for CTO to do a direct update on
                  oe_order_lines w/o calling process_order.
-----------------------------------------------------------------------*/

PROCEDURE  Update_Model_Group_Number
( p_ato_line_id            IN  NUMBER
 ,p_model_group_number     IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_MODEL_GROUP_NUMBER' , 1);
  END IF;

  UPDATE oe_order_lines
  SET    model_group_number = p_model_group_number
        ,last_update_date      = sysdate
        ,last_updated_by       = FND_Global.User_Id
        ,last_update_login     = FND_Global.Login_Id
        ,lock_control          = lock_control + 1
  where  ato_line_id = p_ato_line_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_MODEL_GROUP_NUMBER' , 1);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO_DATA_FOUND IN UPDATE_MODEL_GROUP_NUMBER' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION IN UPDATE_MODEL_GROUP_NUMBER' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END  Update_Model_Group_Number;


/*----------------------------------------------------------------------
Procedure Name :  Update_Cto_Columns
Description    :  API for CTO to do a direct update on
                  oe_order_lines w/o calling process_order.
-----------------------------------------------------------------------*/

PROCEDURE  Update_Cto_Columns
( p_ato_line_id            IN  NUMBER
 ,p_request_id             IN  NUMBER
 ,p_program_id             IN  NUMBER
 ,p_prog_update_date       IN  DATE
 ,p_prog_appl_id           IN  NUMBER
 ,x_return_status          OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.UPDATE_CTO_COLUMNS' , 1);
  END IF;

  UPDATE oe_order_lines
  SET    request_id             = p_request_id
        ,program_id             = p_program_id
        ,program_update_date    = p_prog_update_date
        ,program_application_id = p_prog_appl_id
        ,last_update_date       = sysdate
        ,last_updated_by        = FND_Global.User_Id
        ,last_update_login      = FND_Global.Login_Id
        ,lock_control           = lock_control + 1
  where  ato_line_id            = p_ato_line_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('EXITING OE_CONFIG_UTIL.UPDATE_CTO_COLUMNS' , 1);
  END IF;

EXCEPTION
  WHEN no_data_found THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO_DATA_FOUND IN UPDATE_CTO_COLUMNS' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;

  WHEN others THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OTHERS EXCEPTION IN UPDATE_CTO_COLUMNS' , 1);
    END IF;
    x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END  Update_Cto_Columns;


/*------------------------------------------------------------------
PROCEDURE  Notify_CTO
for cto change order notification.
The IN parameters p_request_rec and p_request_tbl are mutually
exclusive.
-------------------------------------------------------------------*/

PROCEDURE  Notify_CTO
( p_ato_line_id         IN  NUMBER
 ,p_request_rec         IN  OE_Order_Pub.Request_Rec_Type
                            := OE_Order_Pub.G_MISS_REQUEST_REC
 ,p_request_tbl         IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_split_tbl           IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,p_decimal_tbl         IN  OE_Order_PUB.request_tbl_type
                            := OE_Order_Pub.G_MISS_REQUEST_TBL
 ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_cto_change_tbl        CTO_CHANGE_ORDER_PK.CHANGE_TABLE_TYPE;
  l_ato_line_id           NUMBER := p_ato_line_id;
  I                       NUMBER;
  l_split_tbl             CTO_CHANGE_ORDER_PK.SPLIT_CHG_TABLE_TYPE;
  l_decimal_tbl           CTO_CHANGE_ORDER_PK.OPTION_CHG_TABLE_TYPE;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING NOTIFY_CTO' , 1);
  END IF;

  I := 0;

  IF p_request_rec.param1 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.QTY_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param1;
    l_cto_change_tbl(I).new_value   := p_request_rec.param2;
  END IF;

  IF p_request_rec.param3 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.RD_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param3;
    l_cto_change_tbl(I).new_value   := p_request_rec.param4;
  END IF;

  IF p_request_rec.param5 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.SSD_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param5;
    l_cto_change_tbl(I).new_value   := p_request_rec.param6;
  END IF;

  IF p_request_rec.param7 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.SAD_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param7;
    l_cto_change_tbl(I).new_value   := p_request_rec.param8;
  END IF;

  IF p_request_rec.param9 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.CONFIG_CHANGE;
  END IF;

  IF p_request_rec.param10 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.WAREHOUSE_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param10;
    l_cto_change_tbl(I).new_value   := p_request_rec.param11;
  END IF;
 -- INVCONV  start

  IF p_request_rec.param12 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.QTY2_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param12;
    l_cto_change_tbl(I).new_value   := p_request_rec.param13;
  END IF;
    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NOTIFY_CTO 3 ' , 1);
  END IF;
  IF p_request_rec.param14 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.QTY2_UOM_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param14;
    l_cto_change_tbl(I).new_value   := p_request_rec.param15;
  END IF;
    IF l_debug_level  > 0 THEN
    oe_debug_pub.add('NOTIFY_CTO 4 ' , 1);
  END IF;
  IF p_request_rec.param16 is not NULL THEN
    I := I + 1;
    l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.QTY_UOM_CHANGE;
    l_cto_change_tbl(I).old_value   := p_request_rec.param16;
    l_cto_change_tbl(I).new_value   := p_request_rec.param17;
  END IF;

  -- INVCONV  end

  I := p_request_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('PTO ATO CREATE'|| P_REQUEST_TBL (I).PARAM1 , 3 );
    END IF;

    SELECT ato_line_id
    INTO   l_ato_line_id
    FROM   oe_order_lines
    WHERE  line_id = p_request_tbl(I).param1;

    IF l_ato_line_id = p_request_tbl(I).param2 THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('part of PTO, but correct ato_line_id ', 3 );
      END IF;

      l_cto_change_tbl(I).change_type := CTO_CHANGE_ORDER_PK.CONFIG_CHANGE;
      l_cto_change_tbl(I).old_value   := p_request_tbl(I).param1;
      l_cto_change_tbl(I).new_value   := 'PTO_ATO_CREATE';
      l_ato_line_id                   := null;
    END IF;

    I := p_request_tbl.NEXT(I);
  END LOOP;

  I := p_decimal_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('new qty '|| P_decimal_TBL (I).PARAM4 , 3 );
      oe_debug_pub.add('old qty '|| P_decimal_TBL (I).PARAM5 , 3 );
    END IF;

    l_decimal_tbl(I).line_id := p_decimal_tbl(I).entity_id;
    l_decimal_tbl(I).old_Qty := p_decimal_tbl(I).param5;
    l_decimal_tbl(I).new_Qty := p_decimal_tbl(I).param4;
    l_decimal_tbl(I).action  := p_decimal_tbl(I).param1;
    l_decimal_tbl(I).inventory_item_id := p_decimal_tbl(I).param6;

    I := p_decimal_tbl.NEXT(I);
  END LOOP;

  I := p_split_tbl.FIRST;
  WHILE I is NOT NULL
  LOOP
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('split from '|| p_split_tbl (I).PARAM3 , 3 );
      oe_debug_pub.add('split to '|| p_split_tbl (I).PARAM4 , 3 );
    END IF;

    l_split_tbl(I).line_id := p_split_tbl(I).PARAM4;

    I := p_split_tbl.NEXT(I);
  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OLD QTY' || P_REQUEST_REC.PARAM1 , 3 );
    oe_debug_pub.add('NEW QTY' || P_REQUEST_REC.PARAM2 , 3 );
    oe_debug_pub.add('OLD RD'  || P_REQUEST_REC.PARAM3 , 3 );
    oe_debug_pub.add('NEW RD'  || P_REQUEST_REC.PARAM4 , 3 );
    oe_debug_pub.add('OLD SSD' || P_REQUEST_REC.PARAM5 , 3 );
    oe_debug_pub.add('NEW SSD' || P_REQUEST_REC.PARAM6 , 3 );
    oe_debug_pub.add('OLD SAD' || P_REQUEST_REC.PARAM7 , 3 );
    oe_debug_pub.add('NEW SAD' || P_REQUEST_REC.PARAM8 , 3 );
    oe_debug_pub.add('CONFIG ' || P_REQUEST_REC.PARAM9 , 3 );
    oe_debug_pub.add('OLD QTY2' || P_REQUEST_REC.PARAM12 , 3 );
    oe_debug_pub.add('NEW QTY2' || P_REQUEST_REC.PARAM3 , 3 );
    oe_debug_pub.add('PTOATO ' || P_REQUEST_TBL.COUNT , 3 );
    oe_debug_pub.add('PLINEID '|| L_ATO_LINE_ID , 3 );
    oe_debug_pub.add('CALLING CTO PACKAGE '|| I , 3 );
  END IF;

  IF l_cto_change_tbl.COUNT > 0 THEN

    CTO_CHANGE_ORDER_PK.CHANGE_NOTIFY
    ( plineid           => l_ato_line_id
     ,pchgtype          => l_cto_change_tbl
     ,poptionchgdtls    => l_decimal_tbl
     ,psplitdtls        => l_split_tbl
     ,x_return_status   => l_return_status
     ,x_msg_count       => l_msg_count
     ,x_msg_data        => l_msg_data );

  END IF;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING NOTIFY_CTO'|| X_RETURN_STATUS , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('EXCEPTION NOTIFY_CTO'|| SQLERRM , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


/*------------------------------------------------------------------
PROCEDURE  Decimal_Ratio_Check
helper to populate a decimal ratio message.
no return status since caller does not need to check.
====================================================================
This procedure is moved to OE_VALIDATE_LINE
for Decimal quantities for ATO Options Project
the decimal ratio check will be part of line entity
validation
-------------------------------------------------------------------*/

PROCEDURE Decimal_Ratio_Check
( p_top_model_line_id  IN NUMBER
 ,p_component_code     IN VARCHAR2
 ,p_ratio              IN NUMBER)
IS
  l_ordered_item     VARCHAR2(2000);
  l_item_type_code   VARCHAR2(30);
  l_inv_item_id      NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING DECIMAL_RATIO_CHECK '|| P_COMPONENT_CODE , 1);
  END IF;

  FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_DECIMAL_RATIO');

  SELECT ordered_item, item_type_code,inventory_item_id
  INTO   l_ordered_item, l_item_type_code,l_inv_item_id
  FROM   oe_order_lines
  WHERE  top_model_line_id = p_top_model_line_id
  AND    component_code = p_component_code
  AND    rownum = 1;

  FND_MESSAGE.Set_TOKEN('ITEM', nvl(l_ordered_item,l_inv_item_id));
  FND_MESSAGE.Set_TOKEN('TYPECODE', l_item_type_code);
  FND_MESSAGE.Set_TOKEN('VALUE',to_char(p_ratio));

  SELECT ordered_item, item_type_code,inventory_item_id
  INTO   l_ordered_item, l_item_type_code,l_inv_item_id
  FROM   oe_order_lines
  WHERE  line_id = p_top_model_line_id;

  FND_MESSAGE.Set_TOKEN('MODEL', nvl(l_ordered_item,l_inv_item_id));
  FND_MESSAGE.Set_TOKEN('PTYPECODE', l_item_type_code);

  OE_Msg_Pub.Add;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING DECIMAL_RATIO_CHECK' , 3 );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('DECIMAL_RATIO_CHECK '|| SQLERRM , 1);
    END IF;

END Decimal_Ratio_Check;

/*------------------------------------------------------------------
PROCEDURE  Default_Child_Line
This procedure will default certain attributes from model to
children instead of getting values from header.

This procedure will be called from,
OEXDLINB.pls: Model_Option_Defaulting
OEXUCFGB.pls: Process_Included_Items
Since we are calling from process_included_items for the reason
if class has an included item we cannot default in OEXDLINB.pls
In DLINB.pls, code assumes that parent is created in db.

Also, top_model_line_id, item_type_code, ato_line_id and
ship_model_complete_flag should be set before calling this api
from defauling.

Donot add any inventory item dependent(OEXUDEPB.pls) attributes
in this procedure.

We have to default some columns for options under PTO and under
top level ATO Model. For options under ATO subassembly, we will
get the attributes from the ATO subassembly in Process_Config.
Until the call to Process_Config, options and classes under ATO
subassembly will get their attributes from the PTO parent.

Change Record:

bug 1950510: The inventory_item dependent fields should
not be defaulted from the parent line to child lines,
commenting out NOCOPY those fields from this procedure.

bug 1963589: added p_direct_save parameter to default some
additional columns from parent in case of direct insert of
class line.

bug 2015511:
added cancelled_flag := 'N' in direct_save defaulting.

2150536 : moved the ato/smc/set specific defaulting to
here in default_child_line.

bug 2208039: copy dff from parent to child.

Dropship for config: populate the source_type from parent if
ato_line_id not null.

bug 2311690: get all reqd. attributes for ato under pto
from the parent ato.

Bug 2454658: Raise Error if Top Model line id or
header id are NULL.

Bug 1282873: Assign override_atp_date_code from the parent to child
for ato model.

Bug 2511313: For flexfield defaulting.
The call to OE_Validate_Line.Validate_Flex is not for validation
but to default the flex field segments, this call should be made
after the ont_copy_model_dff logic.

Bug 2703023: Setting calculate price flag to Y when direct save
related profile is set to Yes

Bug 2869052: copy dff from model to child has been extended to all
callers and the validate_flex is called with validation level FULL
and we raise an exception if it returns an error.

Bug 3060043: Enabling the code to default blanket number,blanket
version number and blanket line number for Config Items.
Blanket Line number and Version Number for the Child lines will be
defaulted only when blanket number is defined on the parent line.
Otherwise it should not.
This code was added by Srini to support CONFIG ITEMS for PACK-J.

bug fix 3056512: ship to, bill to and request date not cascaded for
non SMC models if caller provides a value.

MACD: Different components of a container model should be allowed to
have different line types when order is received from upstream
sales application
-------------------------------------------------------------------*/
PROCEDURE Default_Child_Line
( p_parent_line_rec    IN   OE_Order_Pub.Line_Rec_Type
 ,p_x_child_line_rec   IN   OUT NOCOPY OE_Order_Pub.Line_Rec_Type
 ,p_direct_save        IN   BOOLEAN := FALSE
 ,x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
--
l_debug_level CONSTANT   NUMBER := oe_debug_pub.g_debug_level;
l_blanket_line_number    NUMBER;
l_blanket_version_number NUMBER;
l_blanket_number         NUMBER;
l_blanket_req_date       date;
l_top_container_model    VARCHAR2(1);
l_part_of_container      VARCHAR2(1);
l_return_status          VARCHAR2(1);

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING DEFAULT_CHILD_LINE' , 1);
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_parent_line_rec.header_id is NULL OR
     p_parent_line_rec.top_model_line_id is NULL THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('CORRUPT DATA' , 3 );
      END IF;
      FND_Message.Set_Name('ONT', 'OE_CONFIG_WRONG_MODEL_LINK');
      FND_MESSAGE.Set_TOKEN('ITEM', nvl(p_x_child_line_rec.ordered_item
                                    ,p_x_child_line_rec.inventory_item_id));
      OE_Msg_Pub.add();
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  p_x_child_line_rec.shipment_number    := p_parent_line_rec.shipment_number;
  p_x_child_line_rec.line_number        := p_parent_line_rec.line_number;
  p_x_child_line_rec.project_id         := p_parent_line_rec.project_id;
  p_x_child_line_rec.task_id            := p_parent_line_rec.task_id;
  p_x_child_line_rec.ship_tolerance_above
                             := p_parent_line_rec.ship_tolerance_above;
  p_x_child_line_rec.ship_tolerance_below
                             := p_parent_line_rec.ship_tolerance_below;
  p_x_child_line_rec.ship_from_org_id   := p_parent_line_rec.ship_from_org_id;

  IF p_x_child_line_rec.ship_from_org_id IS NOT NULL THEN
     p_x_child_line_rec.re_source_flag := 'N';
  END IF;

  p_x_child_line_rec.shipping_method_code
                             := p_parent_line_rec.shipping_method_code;
  p_x_child_line_rec.ship_model_complete_flag
                             := p_parent_line_rec.ship_model_complete_flag;
  p_x_child_line_rec.freight_terms_code
  := p_parent_line_rec.freight_terms_code;
  p_x_child_line_rec.cust_po_number := p_parent_line_rec.cust_po_number;
  --{ Start fix for bug 2652187
---commenting out for fix# 10364601  p_x_child_line_rec.customer_line_number := p_parent_line_rec.customer_line_number;
  -- End fix for bug 2652187 }
  ---START bug 10364601
  IF  p_x_child_line_rec.customer_line_number <>   FND_API.G_MISS_CHAR THEN
        p_x_child_line_rec.customer_line_number := Nvl(p_x_child_line_rec.customer_line_number,p_parent_line_rec.customer_line_number);
  ELSE
   --{ Start fix for bug 2652187
      p_x_child_line_rec.customer_line_number :=p_parent_line_rec.customer_line_number;
    -- End fix for bug 2652187 }
   END IF ;
  ----END BUG 10364601

    IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add(' parent customer line number'||p_parent_line_rec.customer_line_number,3);
        OE_DEBUG_PUB.Add(' child customer line number '|| p_x_child_line_rec.customer_line_number ,3);
     END IF;


  p_x_child_line_rec.salesrep_id        := p_parent_line_rec.salesrep_id;
  p_x_child_line_rec.pricing_date       := p_parent_line_rec.pricing_date;
  p_x_child_line_rec.agreement_id       := p_parent_line_rec.agreement_id;
  p_x_child_line_rec.tax_date           := p_parent_line_rec.tax_date;
  p_x_child_line_rec.tax_exempt_number  := p_parent_line_rec.tax_exempt_number;
  p_x_child_line_rec.tax_exempt_reason_code
                             := p_parent_line_rec.tax_exempt_reason_code;
  p_x_child_line_rec.tax_exempt_flag     := p_parent_line_rec.tax_exempt_flag;
  p_x_child_line_rec.planning_priority  := p_parent_line_rec.planning_priority;
  p_x_child_line_rec.ship_set_id        := p_parent_line_rec.ship_set_id;
  p_x_child_line_rec.arrival_set_id     := p_parent_line_rec.arrival_set_id;
  p_x_child_line_rec.shipment_priority_code
                             := p_parent_line_rec.shipment_priority_code;
  p_x_child_line_rec.fob_point_code     := p_parent_line_rec.fob_point_code;
  p_x_child_line_rec.subinventory       := p_parent_line_rec.subinventory;
  p_x_child_line_rec.demand_class_code  := p_parent_line_rec.demand_class_code;
  p_x_child_line_rec.deliver_to_org_id  := p_parent_line_rec.deliver_to_org_id;
  p_x_child_line_rec.earliest_acceptable_date
                             := p_parent_line_rec.earliest_acceptable_date;
  p_x_child_line_rec.latest_acceptable_date
                             := p_parent_line_rec.latest_acceptable_date;
  p_x_child_line_rec.first_ack_date     := p_parent_line_rec.first_ack_date;
  p_x_child_line_rec.last_ack_date      := p_parent_line_rec.last_ack_date;
  p_x_child_line_rec.first_ack_code     := p_parent_line_rec.first_ack_code;
  p_x_child_line_rec.last_ack_code      := p_parent_line_rec.last_ack_code;

  p_x_child_line_rec.promise_date       := p_parent_line_rec.promise_date;
  p_x_child_line_rec.shipping_instructions
                             := p_parent_line_rec.shipping_instructions;
  p_x_child_line_rec.packing_instructions
                             := p_parent_line_rec.packing_instructions;
  p_x_child_line_rec.model_remnant_flag := p_parent_line_rec.model_remnant_flag;

  -- MACD ---------------------------------------------------------------
  IF p_x_child_line_rec.line_type_id IS NOT NULL OR
     p_x_child_line_rec.line_type_id <> FND_API.G_MISS_NUM THEN

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('LineTypeID:'||p_x_child_line_rec.line_type_id,3);
        OE_DEBUG_PUB.Add('Inventory Item ID (from Parent Line):'
                         ||p_parent_line_rec.inventory_item_id,3);
     END IF;

     OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
     (  p_inventory_item_id    => p_parent_line_rec.inventory_item_id
       ,x_top_container_model  => l_top_container_model
       ,x_part_of_container    => l_part_of_container );

     IF l_part_of_container = 'N' THEN
        p_x_child_line_rec.line_type_id := p_parent_line_rec.line_type_id;

        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add
           ('Line_type from parent: '||p_x_child_line_rec.line_type_id,3);
        END IF;
     ELSE
        IF l_debug_level > 0 THEN
           OE_DEBUG_PUB.Add
           ('Keeping Line_type: '||p_x_child_line_rec.line_type_id,3);
        END IF;
     END IF;
  ELSE
    p_x_child_line_rec.line_type_id := p_parent_line_rec.line_type_id;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COPY it: '|| P_X_CHILD_LINE_REC.line_type_id, 4 );
    END IF;
  END IF;


  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN

     IF p_parent_line_rec.blanket_number IS NOT NULL and
                  p_parent_line_rec.item_type_code  <> 'INCLUDED' THEN

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Blanket No:'
                           ||p_parent_line_rec.blanket_number);
          oe_debug_pub.add('Top Model Inventory Item ID:'
                           ||p_parent_line_rec.inventory_item_id );
          oe_debug_pub.add('Child Inventory Item ID:'
                           ||p_x_child_line_rec.inventory_item_id );
          oe_debug_pub.add('Child Item Type Code:'
                           ||p_x_child_line_rec.item_type_code );
       END IF;

       -- For the bug fix #3579240
       IF p_x_child_line_rec.item_type_code <> 'INCLUDED'
       THEN


         -- Call Blanket Procedure for the Child Items

            oe_default_line.default_Blanket_Values (  p_blanket_number         => p_parent_line_rec.blanket_number,
                                                      p_cust_po_number         => p_parent_line_rec.cust_po_number,
						      p_ordered_item_id        => p_x_child_line_rec.ordered_item_id, --bug6826787
                                                      p_ordered_item           => p_x_child_line_rec.ordered_item,
                                                      p_inventory_item_id      => p_x_child_line_rec.inventory_item_id,
                                                      p_item_identifier_type   => p_x_child_line_rec.item_type_code,
                                                      p_request_date           => p_x_child_line_rec.request_date,
                                                      p_sold_to_org_id         => p_x_child_line_rec.sold_to_org_id,
                                                      x_blanket_number         => p_x_child_line_rec.blanket_number,
                                                      x_blanket_line_number    => p_x_child_line_rec.blanket_line_number,
                                                      x_blanket_version_number => p_x_child_line_rec.blanket_version_number,
                                                      x_blanket_request_date   => l_blanket_req_date
                                                   );

       END IF;

     END IF;

  END IF;


  ---------------- dff -------------------------------------------

  IF G_COPY_MODEL_DFF = 'Y' /* Bug # 5036404 */
     -- OE_CONFIG_UTIL.G_CONFIG_UI_USED = 'Y'
    THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('COPYING DFF TO CHILD' , 1);
    END IF;

    IF p_x_child_line_rec.attribute1 is null OR
       p_x_child_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute1 := p_parent_line_rec.attribute1;
    END IF;

    IF p_x_child_line_rec.attribute2 is null OR
       p_x_child_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute2 := p_parent_line_rec.attribute2;
    END IF;

    IF p_x_child_line_rec.attribute3 is null OR
       p_x_child_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute3 := p_parent_line_rec.attribute3;
    END IF;

    IF p_x_child_line_rec.attribute4 is null OR
       p_x_child_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute4 := p_parent_line_rec.attribute4;
    END IF;

    IF p_x_child_line_rec.attribute5 is null OR
       p_x_child_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute5 := p_parent_line_rec.attribute5;
    END IF;

    IF p_x_child_line_rec.attribute6 is null OR
       p_x_child_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute6 := p_parent_line_rec.attribute6;
    END IF;

    IF p_x_child_line_rec.attribute7 is null OR
       p_x_child_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute7 := p_parent_line_rec.attribute7;
    END IF;

    IF p_x_child_line_rec.attribute8 is null OR
       p_x_child_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute8 := p_parent_line_rec.attribute8;
    END IF;

    IF p_x_child_line_rec.attribute9 is null OR
       p_x_child_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute9 := p_parent_line_rec.attribute9;
    END IF;

    IF p_x_child_line_rec.attribute10 is null OR
       p_x_child_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute10 := p_parent_line_rec.attribute10;
    END IF;

    IF p_x_child_line_rec.attribute11 is null OR
       p_x_child_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute11 := p_parent_line_rec.attribute11;
    END IF;

    IF p_x_child_line_rec.attribute12 is null OR
       p_x_child_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute12 := p_parent_line_rec.attribute12;
    END IF;

    IF p_x_child_line_rec.attribute13 is null OR
       p_x_child_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute13 := p_parent_line_rec.attribute13;
    END IF;

    IF p_x_child_line_rec.attribute14 is null OR
       p_x_child_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute14 := p_parent_line_rec.attribute14;
    END IF;

    IF p_x_child_line_rec.attribute15 is null OR
       p_x_child_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute15 := p_parent_line_rec.attribute15;
    END IF;

    IF p_x_child_line_rec.attribute16 is null OR  -- for bug 2184255
       p_x_child_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute16 := p_parent_line_rec.attribute16;
    END IF;

    IF p_x_child_line_rec.attribute17 is null OR
       p_x_child_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute17 := p_parent_line_rec.attribute17;
    END IF;

    IF p_x_child_line_rec.attribute18 is null OR
       p_x_child_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute18 := p_parent_line_rec.attribute18;
    END IF;

    IF p_x_child_line_rec.attribute19 is null OR
       p_x_child_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute19 := p_parent_line_rec.attribute19;
    END IF;

    IF p_x_child_line_rec.attribute20 is null OR  -- for bug 2184255
       p_x_child_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.attribute20 := p_parent_line_rec.attribute20;
    END IF;

    IF p_x_child_line_rec.context is null OR
       p_x_child_line_rec.context = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.context := p_parent_line_rec.context;
    END IF;

IF p_x_child_line_rec.industry_attribute1 is null OR
       p_x_child_line_rec.industry_attribute1 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute1 := p_parent_line_rec.industry_attribute1;
    END IF;

    IF p_x_child_line_rec.industry_attribute2 is null OR
       p_x_child_line_rec.industry_attribute2 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute2 := p_parent_line_rec.industry_attribute2;
    END IF;

    IF p_x_child_line_rec.industry_attribute3 is null OR
       p_x_child_line_rec.industry_attribute3 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute3 := p_parent_line_rec.industry_attribute3;
    END IF;

    IF p_x_child_line_rec.industry_attribute4 is null OR
       p_x_child_line_rec.industry_attribute4 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute4 := p_parent_line_rec.industry_attribute4;
    END IF;

    IF p_x_child_line_rec.industry_attribute5 is null OR
       p_x_child_line_rec.industry_attribute5 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute5 := p_parent_line_rec.industry_attribute5;
    END IF;

    IF p_x_child_line_rec.industry_attribute6 is null OR
       p_x_child_line_rec.industry_attribute6 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute6 := p_parent_line_rec.industry_attribute6;
    END IF;

    IF p_x_child_line_rec.industry_attribute7 is null OR
       p_x_child_line_rec.industry_attribute7 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute7 := p_parent_line_rec.industry_attribute7;
    END IF;

    IF p_x_child_line_rec.industry_attribute8 is null OR
       p_x_child_line_rec.industry_attribute8 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute8 := p_parent_line_rec.industry_attribute8;
    END IF;

   IF p_x_child_line_rec.industry_attribute9 is null OR
       p_x_child_line_rec.industry_attribute9 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute9 := p_parent_line_rec.industry_attribute9;
    END IF;

    IF p_x_child_line_rec.industry_attribute10 is null OR
       p_x_child_line_rec.industry_attribute10 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute10 := p_parent_line_rec.industry_attribute10;
    END IF;

    IF p_x_child_line_rec.industry_attribute11 is null OR
       p_x_child_line_rec.industry_attribute11 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute11 := p_parent_line_rec.industry_attribute11;
    END IF;

    IF p_x_child_line_rec.industry_attribute12 is null OR
       p_x_child_line_rec.industry_attribute12 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute12 := p_parent_line_rec.industry_attribute12;
    END IF;

    IF p_x_child_line_rec.industry_attribute13 is null OR
       p_x_child_line_rec.industry_attribute13 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute13 := p_parent_line_rec.industry_attribute13;
    END IF;

    IF p_x_child_line_rec.industry_attribute14 is null OR
       p_x_child_line_rec.industry_attribute14 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute14 := p_parent_line_rec.industry_attribute14;
    END IF;

    IF p_x_child_line_rec.industry_attribute15 is null OR
       p_x_child_line_rec.industry_attribute15 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute15 := p_parent_line_rec.industry_attribute15;
    END IF;

    IF p_x_child_line_rec.industry_attribute16 is null OR
       p_x_child_line_rec.industry_attribute16 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute16 := p_parent_line_rec.industry_attribute16;
    END IF;
IF p_x_child_line_rec.industry_attribute17 is null OR
       p_x_child_line_rec.industry_attribute17 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute17 := p_parent_line_rec.industry_attribute17;
    END IF;

    IF p_x_child_line_rec.industry_attribute18 is null OR
       p_x_child_line_rec.industry_attribute18 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute18 := p_parent_line_rec.industry_attribute18;
    END IF;

    IF p_x_child_line_rec.industry_attribute19 is null OR
       p_x_child_line_rec.industry_attribute19 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute19 := p_parent_line_rec.industry_attribute19;
    END IF;

    IF p_x_child_line_rec.industry_attribute20 is null OR
       p_x_child_line_rec.industry_attribute20 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute20 := p_parent_line_rec.industry_attribute20;
    END IF;

    IF p_x_child_line_rec.industry_attribute21 is null OR
       p_x_child_line_rec.industry_attribute21 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute21 := p_parent_line_rec.industry_attribute21;
    END IF;

    IF p_x_child_line_rec.industry_attribute22 is null OR
       p_x_child_line_rec.industry_attribute22 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute22 := p_parent_line_rec.industry_attribute22;
    END IF;

    IF p_x_child_line_rec.industry_attribute23 is null OR
       p_x_child_line_rec.industry_attribute23 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute23 := p_parent_line_rec.industry_attribute23;
    END IF;

    IF p_x_child_line_rec.industry_attribute24 is null OR
       p_x_child_line_rec.industry_attribute24 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute24 := p_parent_line_rec.industry_attribute24;
    END IF;

    IF p_x_child_line_rec.industry_attribute25 is null OR
       p_x_child_line_rec.industry_attribute25 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute25 := p_parent_line_rec.industry_attribute25;
    END IF;

    IF p_x_child_line_rec.industry_attribute26 is null OR
       p_x_child_line_rec.industry_attribute26 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute26 := p_parent_line_rec.industry_attribute26;
    END IF;
IF p_x_child_line_rec.industry_attribute27 is null OR
       p_x_child_line_rec.industry_attribute27 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute27 := p_parent_line_rec.industry_attribute27;
    END IF;

    IF p_x_child_line_rec.industry_attribute28 is null OR
       p_x_child_line_rec.industry_attribute28 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute28 := p_parent_line_rec.industry_attribute28;
    END IF;

    IF p_x_child_line_rec.industry_attribute29 is null OR
       p_x_child_line_rec.industry_attribute29 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute29 := p_parent_line_rec.industry_attribute29;
    END IF;

    IF p_x_child_line_rec.industry_attribute30 is null OR
       p_x_child_line_rec.industry_attribute30 = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_attribute30 := p_parent_line_rec.industry_attribute30;
    END IF;

    IF p_x_child_line_rec.industry_context is null OR
       p_x_child_line_rec.industry_context = FND_API.G_MISS_CHAR THEN
      p_x_child_line_rec.industry_context := p_parent_line_rec.industry_context;
    END IF;


  END IF;


  OE_Validate_Line.Validate_Flex
  ( p_x_line_rec        => p_x_child_line_rec
   ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
   ,x_return_status     => x_return_status);

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN   -- For bug 2869052
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  ---------------- for direct save only ------------------------

  IF p_direct_save THEN

    p_x_child_line_rec.operation          := OE_GLOBALS.G_OPR_CREATE;
    p_x_child_line_rec.header_id          := p_parent_line_rec.header_id;
    p_x_child_line_rec.top_model_line_id  := p_parent_line_rec.line_id;
    p_x_child_line_rec.item_identifier_type := 'INT';
    p_x_child_line_rec.item_type_code     := OE_GLOBALS.G_ITEM_CLASS;
    p_x_child_line_rec.line_category_code
                                 := p_parent_line_rec.line_category_code;
    p_x_child_line_rec.creation_date      := sysdate;
    p_x_child_line_rec.created_by         := p_parent_line_rec.created_by;
    p_x_child_line_rec.last_update_date   := p_parent_line_rec.last_update_date;
    p_x_child_line_rec.last_updated_by    := p_parent_line_rec.last_updated_by;
    p_x_child_line_rec.unit_list_price    := 0;
    p_x_child_line_rec.unit_selling_price := 0;
    p_x_child_line_rec.price_list_id      := p_parent_line_rec.price_list_id;
    p_x_child_line_rec.sold_to_org_id     := p_parent_line_rec.sold_to_org_id;
    p_x_child_line_rec.tax_code           := p_parent_line_rec.tax_code;
    p_x_child_line_rec.shippable_flag     := 'N';
    p_x_child_line_rec.shipping_interfaced_flag := 'N';
    p_x_child_line_rec.booked_flag        := 'N';
    p_x_child_line_rec.open_flag          := 'Y';
    p_x_child_line_rec.cancelled_flag     := 'N';
    p_x_child_line_rec.cancelled_quantity := 0;
    p_x_child_line_rec.source_type_code   := p_parent_line_rec.source_type_code;
    p_x_child_line_rec.org_id             := p_parent_line_rec.org_id;
    -- Bug 5912216: start
    -- p_x_child_line_rec.flow_status_code   := 'ENTERED'; (Commented out)
    p_x_child_line_rec.flow_status_code   := p_parent_line_rec.flow_status_code;
    p_x_child_line_rec.transaction_phase_code := p_parent_line_rec.transaction_phase_code;
    -- Bug 5912216: end
    p_x_child_line_rec.payment_term_id    := p_parent_line_rec.payment_term_id;
    p_x_child_line_rec.calculate_price_flag  := 'Y';

    -- this is for pure ato, pto+ato will get in change_columns.
    p_x_child_line_rec.ato_line_id        := p_parent_line_rec.ato_line_id;

  END IF;


  ---------- conditional defaulting here onwards----------


  ---------- SMC/ATO/SHIP and Arrival Set-----------------

  IF p_parent_line_rec.ship_model_complete_flag = 'Y' OR
     p_parent_line_rec.ato_line_id = p_parent_line_rec.top_model_line_id OR
     (p_parent_line_rec.ship_set_id is NOT NULL AND
      p_parent_line_rec.ship_set_id <> FND_API.G_MISS_NUM) OR
     (p_parent_line_rec.arrival_set_id is NOT NULL AND
      p_parent_line_rec.arrival_set_id <> FND_API.G_MISS_NUM)
  THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('**PARENT IS ATO OR SMC PTO OR IN SET' , 1);
      END IF;

      p_x_child_line_rec.schedule_ship_date    :=
                         p_parent_line_rec.schedule_ship_date;
      p_x_child_line_rec.schedule_arrival_date :=
                         p_parent_line_rec.schedule_arrival_date;
      p_x_child_line_rec.freight_carrier_code  :=
                         p_parent_line_rec.freight_carrier_code;


      /* Added the following 3 lines to fix the bug 3056512 */

      p_x_child_line_rec.ship_to_org_id     := p_parent_line_rec.ship_to_org_id;
      p_x_child_line_rec.request_date       := p_parent_line_rec.request_date;
      p_x_child_line_rec.invoice_to_org_id  := p_parent_line_rec.invoice_to_org_id;

      /*Begin bug 7041018,7175458*/
       p_x_child_line_rec.intermed_ship_to_org_id := p_parent_line_rec.intermed_ship_to_org_id;
       p_x_child_line_rec.ship_to_contact_id := p_parent_line_rec.ship_to_contact_id;
     /*end bug 7041018, 7175458*/
      ------------- IF SMC ----------------------------------

      IF p_parent_line_rec.ship_model_complete_flag = 'Y' THEN

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
          p_x_child_line_rec.firm_demand_flag :=
                          p_parent_line_rec.firm_demand_flag;
        END IF;
      END IF;

      ------------- IF ATO ----------------------------------
      IF p_parent_line_rec.ato_line_id is not NULL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('1 **SOURCE TYPE ATO '
                           || P_PARENT_LINE_REC.SOURCE_TYPE_CODE , 4 );
        END IF;

        p_x_child_line_rec.source_type_code    :=
                         p_parent_line_rec.source_type_code;

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
          p_x_child_line_rec.override_atp_date_code :=
                       p_parent_line_rec.override_atp_date_code;
        END IF;

        IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
          p_x_child_line_rec.firm_demand_flag :=
                       p_parent_line_rec.firm_demand_flag;
        END IF;
      END IF;

  ------------- IF NON SMC, use this branch -----------------
  ELSE -- Added the else to fix the bug 3056512

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('**PARENT IS NON SMC PTO ' , 1);
      END IF;

      IF p_x_child_line_rec.ship_to_org_id = FND_API.G_MISS_NUM OR
         p_x_child_line_rec.ship_to_org_id IS NULL THEN
        p_x_child_line_rec.ship_to_org_id
                 := p_parent_line_rec.ship_to_org_id;
      END IF;

      IF p_x_child_line_rec.request_date = FND_API.G_MISS_DATE OR
         p_x_child_line_rec.request_date IS NULL THEN
         p_x_child_line_rec.request_date
                 := p_parent_line_rec.request_date;
      END IF;

      IF p_x_child_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM OR
         p_x_child_line_rec.invoice_to_org_id IS NULL THEN
         p_x_child_line_rec.invoice_to_org_id
                 := p_parent_line_rec.invoice_to_org_id;
      END IF;

      /*Start bug7041018,7175458*/
      IF p_x_child_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM OR
         p_x_child_line_rec.intermed_ship_to_org_id IS NULL THEN
         p_x_child_line_rec.intermed_ship_to_org_id
                 := p_parent_line_rec.intermed_ship_to_org_id;
      END IF;

      IF p_x_child_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM OR
         p_x_child_line_rec.ship_to_contact_id IS NULL THEN
         p_x_child_line_rec.ship_to_contact_id
                 := p_parent_line_rec.ship_to_contact_id;
      END IF;

      /*ENd bug 7041018,71754588*/

  END IF;  ------ if part of ato/smc/ship or arr set.



  --Begin- code to get user_item_description from the parent for the child

  IF p_x_child_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG AND
     p_x_child_line_rec.ato_line_id is not NULL AND
     p_x_child_line_rec.line_id <> p_x_child_line_rec.ato_line_id THEN

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('DEFAULTING USER_ITEM_DESCRIPTION
                          FROM ATO FOR CONFIG ITEMS ', 1);
     END IF;

     SELECT user_item_description
     INTO   p_x_child_line_rec.user_item_description
     FROM   oe_order_lines
     WHERE  line_id = p_x_child_line_rec.ato_line_id;

     --no need to handle exception here as exception is handled outside

     IF l_debug_level > 0 THEN
        oe_debug_pub.add('USER_ITEM_DESCRIPTION on child line is: '
                          || p_x_child_line_rec.user_item_description, 1);
     END IF;

     -- Populate delivery lead time from the parent.
     p_x_child_line_rec.delivery_lead_time := p_parent_line_rec.delivery_lead_time;
  END IF;


  ------------------ ATO within PTO -------------------------------
  IF p_x_child_line_rec.ato_line_id is not NULL AND
     p_x_child_line_rec.line_id <> p_x_child_line_rec.ato_line_id AND
     p_x_child_line_rec.top_model_line_id <> p_x_child_line_rec.ato_line_id
  THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ATO IN PTO '||P_X_CHILD_LINE_REC.ATO_LINE_ID , 2 );
     END IF;

     SELECT source_type_code, project_id, task_id,
            ship_from_org_id, ship_to_org_id,
            schedule_ship_date, schedule_arrival_date,
            request_date, shipping_method_code,
            freight_carrier_code, invoice_to_org_id,
            firm_demand_flag, override_atp_date_code,
            ship_to_contact_id,intmed_ship_to_org_id  --bug 7041018,7175458
     INTO   p_x_child_line_rec.source_type_code,
            p_x_child_line_rec.project_id,
            p_x_child_line_rec.task_id,
            p_x_child_line_rec.ship_from_org_id,
            p_x_child_line_rec.ship_to_org_id,
            p_x_child_line_rec.schedule_ship_date,
            p_x_child_line_rec.schedule_arrival_date,
            p_x_child_line_rec.request_date,
            p_x_child_line_rec.shipping_method_code,
            p_x_child_line_rec.freight_carrier_code,
            p_x_child_line_rec.invoice_to_org_id,
            p_x_child_line_rec.firm_demand_flag,
            p_x_child_line_rec.override_atp_date_code,
            p_x_child_line_rec.ship_to_contact_id,   --bug7041018,7175458
            p_x_child_line_rec.intermed_ship_to_org_id   --bug 7041018,7175458
     FROM   oe_order_lines
     WHERE  line_id = p_x_child_line_rec.ato_line_id;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('2 **SOURCE TYPE ATO '
                        || P_X_CHILD_LINE_REC.SOURCE_TYPE_CODE , 4 );
     END IF;

  END IF;


  -------------------- any other conditions -------------------
  --IF
  --  put logic here
  --END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING DEFAULT_CHILD_LINE' , 1);
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('DEFAULT_CHILD_LINE, exc error '|| SQLERRM , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('others in DEFAULT_CHILD_LINE '|| SQLERRM , 1);
    END IF;

END Default_Child_Line;


/*---------------------------------------------------------------------
PROCEDURE: Is_Included_Item_Constrained

This API will check if the delete and update quantity operation
performed on a Included item should be allowed or not.
We will not allow any user delete/update quantity.
We will allow system changes ex: cascading.

We have to write a pl/sql api because we want the system to be able to
do the operations.

result of 1 means constrained.

Process_Included_Items procedure will set the security_check to
false, before calling process_order.

--##1922440 bug fix.
----------------------------------------------------------------------*/
PROCEDURE Is_Included_Item_Constrained
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER )
IS
  l_item_type_code         VARCHAR2(30);
  l_model_remnant_flag     VARCHAR2(1);
  l_pre_exploded_flag      VARCHAR2(1); -- DOO Preexploded Kit ER 9339742
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING IS_INCLUDED_ITEM_CONSTRAINED' , 1);
    oe_debug_pub.add('OPERATION '|| OE_LINE_SECURITY.G_RECORD.OPERATION , 4 );
    oe_debug_pub.add('ITEM TYPE '||OE_LINE_SECURITY.G_RECORD.ITEM_TYPE_CODE,4);
  END IF;

  SELECT item_type_code, model_remnant_flag, pre_exploded_flag
  INTO   l_item_type_code, l_model_remnant_flag, l_pre_exploded_flag  -- DOO Preexploded Kit ER 9339742
  FROM   oe_order_lines
  WHERE  line_id = oe_line_security.g_record.line_id;

  IF l_debug_level  > 0 THEN -- DOO Preexploded Kit ER 9339742
    oe_debug_pub.add('Pre Exploded Flag is : '||l_pre_exploded_flag);
  END IF;

  IF nvl(l_item_type_code, 'A') <> 'INCLUDED' THEN
    x_result := 0;
    RETURN;
  END IF;

  IF  OE_CONFIG_UTIL.CASCADE_CHANGES_FLAG = 'Y' OR
      OE_CONFIG_PVT.OECFG_VALIDATE_CONFIG = 'N' OR
      l_model_remnant_flag = 'Y'                OR
      -- DOO Preexploded Kit ER 9339742
      l_pre_exploded_flag  = 'Y'                OR
      Oe_Genesis_Util.G_INCOMING_FROM_DOO OR
      Oe_Genesis_Util.G_INCOMING_FROM_SIEBEL
  THEN
    x_result := 0;
  ELSE
    x_result := 1;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING IS_INCLUDED_ITEM_CONSTRAINED '|| X_RESULT , 1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('IS_INCLUDED_ITEM_CONSTRAINED ERROR '|| SQLERRM , 1);
    END IF;
    RAISE;
END Is_Included_Item_Constrained;


/*--------------------------------------------------------
PROCEDURE: Log_Included_Item_Requests

This procedure will be used to log delayed requests
for included items. To improce performance of
saving included items, we will set the
control_rec.change_attributes parameter to FALSE.
Hence all the delayed requests logged in
oe_line_util.apply_attribute_changes procedure for
included_items will be logged here.
--------------------------------------------------------*/
PROCEDURE Log_Included_Item_Requests
( p_line_tbl    IN  OE_Order_Pub.Line_Tbl_Type
 ,p_booked_flag IN  VARCHAR2)
IS
  I                NUMBER;
  l_return_status  VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_serviceable_item   VARCHAR2(1); -- Added for bug 5925600
  l_serviced_model     VARCHAR2(1); -- Added for bug 5925600

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTERING LOG_INCLUDED_ITEM_REQUESTS'
                     || P_LINE_TBL.COUNT , 1);
  END IF;

  I := p_line_tbl.FIRST;
  FOR I in p_line_tbl.FIRST..p_line_tbl.LAST
  LOOP

    IF nvl(FND_PROFILE.VALUE('ONT_CHARGES_FOR_INCLUDED_ITEM'),'N') = 'Y'
    THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RENGA-LOGGING REQ TO CHARGES FOR INCLUDED ' , 3 );
        oe_debug_pub.add('RENGA-LINE OPERATION IS : '
                          || P_LINE_TBL (I).OPERATION , 3 );
      END IF;

      OE_LINE_ADJ_UTIL.Register_Changed_Lines
      (p_line_id         => p_line_tbl(I).line_id,
       p_header_id       => p_line_tbl(I).header_id,
       p_operation       => p_line_tbl(I).operation );

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('RENGA-AFTER REGISTER_CHANGED_LINES Booked Flag=' || p_booked_flag , 3 );
      END IF;

    --Added the if clause for bug 6892989/6903859
      IF ( nvl(p_booked_flag,'N') = 'Y' ) THEN
      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
       p_entity_id              => p_line_tbl(I).header_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
       p_requesting_entity_id   => p_line_tbl(I).header_id,
       p_request_unique_key1    => 'BATCH,BOOK',
       p_param1                 => p_line_tbl(I).header_id,
       p_param2                 => 'BATCH,BOOK',
       p_request_type           => OE_GLOBALS.G_FREIGHT_FOR_INCLUDED,
       x_return_status          => l_return_status);
     ELSE
      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
       p_entity_id              => p_line_tbl(I).header_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
       p_requesting_entity_id   => p_line_tbl(I).header_id,
       p_request_unique_key1    => 'BATCH',
       p_param1                 => p_line_tbl(I).header_id,
       p_param2                 => 'BATCH',
       p_request_type           => OE_GLOBALS.G_FREIGHT_FOR_INCLUDED,
       x_return_status          => l_return_status);
     END IF;


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add
        ('RENGA-AFTER LOGGING DELAYED REQ FREIGHT_FOR_INCLUDED-2' , 3 );
      END IF;

    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LOGGING REQ TO TAX_LINE ' , 3 );
      oe_debug_pub.add('REN: ITEM TYPE CODE IS: '
                       || P_LINE_TBL (I).ITEM_TYPE_CODE , 1);
    END IF;

   IF p_line_tbl(I).item_type_code not in ('INCLUDED', 'CONFIG') THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('REN: ITEM TYPE CODE IS NOT INCLUDED OR CONFIG' , 1);
     END IF;

    OE_delayed_requests_Pvt.log_request
    (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
     p_entity_id              => p_line_tbl(I).line_id,
     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
     p_requesting_entity_id   => p_line_tbl(I).line_id,
     p_request_type           => OE_GLOBALS.g_tax_line,
     x_return_status          => l_return_status);

   END IF;

    IF OE_Commitment_Pvt.Do_Commitment_Sequencing AND
       p_line_tbl(I).commitment_id is not null
    THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LOGGING REQ TO CALC COMMITMENT' , 3 );
      END IF;

      OE_Delayed_Requests_Pvt.Log_Request
      (p_entity_code             => OE_GLOBALS.G_ENTITY_LINE,
       p_entity_id               => p_line_tbl(I).line_id,
       p_requesting_entity_code  => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id    => p_line_tbl(I).line_id,
       p_request_type            => OE_GLOBALS.G_CALCULATE_COMMITMENT,
       x_return_status           => l_return_status);
    END IF;

    IF p_booked_flag = 'Y' AND
       p_line_tbl(I).operation = 'UPDATE' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('LOGGING REQ TO VERIFY_PAYMENT' , 3 );
      END IF;
      OE_delayed_requests_Pvt.log_request
      (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
       p_entity_id              => p_line_tbl(I).header_id,
       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
       p_requesting_entity_id   => p_line_tbl(I).line_id,
       p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
       x_return_status          => l_return_status);

    END IF;

    -- Log delayed request for Freight Rating.
    IF OE_Freight_Rating_Util.IS_FREIGHT_RATING_AVAILABLE
       AND OE_Freight_Rating_Util.Get_List_Line_Type_Code
                                  (p_line_tbl(I).header_id)
            = 'OM_CALLED_FREIGHT_RATES' THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add
         ('LOGGING DELAYED REQUEST FOR FREIGHT RATE FOR INCLUDED ITEM: '
          ||P_LINE_TBL (I).HEADER_ID , 2 );
       END IF;

       OE_delayed_requests_Pvt.log_request
       (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
        p_entity_id              => p_line_tbl(I).header_id,
        p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
        p_requesting_entity_id   => p_line_tbl(I).line_id,
        p_request_type           => OE_GLOBALS.G_FREIGHT_RATING,
        p_param1                 => 'Y',
        x_return_status          => l_return_status);
    END IF;

    /* Below code has been added for bug 5925600 */
    IF p_line_tbl(I).operation = OE_GLOBALS.G_OPR_CREATE THEN

      if l_debug_level > 0 then
        oe_debug_pub.add('Before checking if we need to log delayed request for G_CASCADE_OPTIONS_SERVICE', 5);
	oe_debug_pub.ADD('operation : '|| p_line_tbl(I).operation);
	oe_debug_pub.ADD('inventory_item_id : '|| p_line_tbl(I).inventory_item_id);
      end if;

      BEGIN
	select 'Y'
	into   l_serviceable_item
	from   mtl_system_items mtl
	where  mtl.inventory_item_id = p_line_tbl(I).inventory_item_id
	and    mtl.organization_id = OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID')
	and    mtl.serviceable_product_flag='Y'
	and    rownum = 1;

      EXCEPTION
	  WHEN OTHERS THEN
	    l_serviceable_item := 'N';
      END;

      if l_debug_level > 0 then
         oe_debug_pub.ADD('serviceable option :  '|| l_serviceable_item);
	 oe_debug_pub.ADD('service_reference_line_id:  '|| p_line_tbl(I).top_model_line_id);
      end if;

      IF l_serviceable_item = 'Y' THEN

         BEGIN
	   select 'Y'
           into   l_serviced_model
	   from   oe_order_lines
	   where  item_type_code = 'SERVICE'
	   and    service_reference_line_id = p_line_tbl(I).top_model_line_id
	   and    service_reference_type_code = 'ORDER'
	   and    rownum = 1;

	 EXCEPTION
	    WHEN OTHERS THEN
	      l_serviced_model := 'N';
	 END;

	 if l_debug_level > 0 then
	    oe_debug_pub.ADD('serviced model :  '|| l_serviced_model);
	 end if;

	 IF l_serviced_model = 'Y' THEN

	    if l_debug_level > 0 then
	       oe_debug_pub.add('Before log delayed request -- G_CASCADE_OPTIONS_SERVICE',1);
	    end if;

	    OE_Delayed_Requests_Pvt.log_request
		 (
		   p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
		   p_entity_id              => p_line_tbl(I).line_id,
		   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		   p_requesting_entity_id   => p_line_tbl(I).line_id,
		   p_request_type           => OE_GLOBALS.G_CASCADE_OPTIONS_SERVICE,
		   x_return_status          => l_return_status
		 );

	  END IF; /* l_serviced_model = 'Y' */
       END IF; /* l_serviceable_item = 'Y' */
    END IF; /* operation = CREATE */
    /* End of changes done for bug 5925600 */

  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('LEAVING LOG_INCLUDED_ITEM_REQUESTS' , 1);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('LOG_INCLUDED_ITEM_REQUESTS '|| SQLERRM , 1);
    END IF;
    RAISE;
END;


/*--------------------------------------------------------
PROCEDURE ATO_Remnant_Check
Constraint API to not let some changes to remnant
ATOs.
--------------------------------------------------------*/

PROCEDURE ATO_Remnant_Check
( p_application_id                IN   NUMBER,
  p_entity_short_name             IN   VARCHAR2,
  p_validation_entity_short_name  IN   VARCHAR2,
  p_validation_tmplt_short_name   IN   VARCHAR2,
  p_record_set_short_name         IN   VARCHAR2,
  p_scope                         IN   VARCHAR2,
  x_result                        OUT NOCOPY /* file.sql.39 change */  NUMBER )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_result := 0;

  IF nvl(oe_line_security.g_record.model_remnant_flag, 'N') = 'N' THEN
    RETURN;
  END IF;

  IF oe_line_security.g_record.ato_line_id is NULL THEN
    RETURN;
  END IF;

  --IF oe_line_security.g_record.item_type_code = 'STANDARD' OR
    -- (oe_line_security.g_record.item_type_code = 'OPTION' AND
  --Begin Bug fix for bug#6153528
     IF oe_line_security.g_record.item_type_code IN ( 'STANDARD', 'OPTION', 'CONFIG', 'CLASS' )  OR
     (oe_line_security.g_record.item_type_code in ( 'OPTION', 'CLASS' ) AND
  --End Bug fix for bug#6153528
      oe_line_security.g_record.line_id =
      oe_line_security.g_record.ato_line_id) THEN
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('REMNANT ATO CHECK CONSTRAINED' , 3 );
  END IF;

  x_result := 1;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ATO_REMNANT_CHECK ERROR '|| SQLERRM , 1);
    END IF;
    RAISE;
END ATO_Remnant_Check;

/*--------------------------------------------------------
PROCEDURE Launch_Supply_Workbench

This procedure is used to perform some checks on line/
header before launching the supply to order wb.
It also derives a wb item type and sends it as out NOCOPY param.
This functionality is only available from pack I onwards.

p_header_id is populated when the action is performed
from header block and not when call is made from line block.
rest of the params are populated when it is performed from
line block.

This action is only UI action not for batch call.

This API will be called only if the order is booked.
--------------------------------------------------------*/
PROCEDURE Launch_Supply_Workbench
( p_header_id          IN  NUMBER
 ,p_top_model_line_id  IN  NUMBER
 ,p_ato_line_id        IN  NUMBER
 ,p_line_id            IN  NUMBER
 ,p_item_type_code     IN  VARCHAR2
 ,x_wb_item_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 ,x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_count   NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  Print_Time('entering Launch_Supply_Workbench');

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('-'|| P_HEADER_ID || '-' || P_TOP_MODEL_LINE_ID
                     || '-' || P_ATO_LINE_ID || '-' || P_LINE_ID
                     || '-' || P_ITEM_TYPE_CODE , 3 );
  END IF;

  IF p_header_id is not NULL AND
     p_line_id is not NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('WRONG PARAMTERS' , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_wb_item_type  := null;

  SELECT count(*)
  INTO   l_count
  FROM   oe_order_lines
  WHERE  line_category_code  <> 'RETURN'
	-- the condition below is commented for bug 3441504
 -- AND  booked_flag = 'Y'
  AND    (header_id          = p_header_id OR
          (top_model_line_id = p_top_model_line_id AND
           p_line_id         = p_top_model_line_id) OR
          (ato_line_id       = p_ato_line_id AND
           top_model_line_id = p_top_model_line_id AND
           p_line_id         = p_ato_line_id AND
           p_item_type_code in ('MODEL', 'CLASS')) OR
          line_id           = p_line_id)
  AND    ((source_type_code = 'EXTERNAL' AND
           shippable_flag = 'Y') OR
          (ato_line_id = line_id AND
           item_type_code in ('STANDARD', 'OPTION', 'INCLUDED')) OR --9775352
           item_type_code = 'CONFIG')
  AND     OPEN_FLAG = 'Y';


  IF l_count > 0 THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ELIGIBLE LINES EXIST '|| L_COUNT , 1);
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('NO ELIGIBLE LINES ' , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF p_header_id is not null AND
     p_line_id is null THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('WB ITEM TYPE IS HEADER '|| P_HEADER_ID , 3 );
     END IF;
     x_wb_item_type := 'HEAD';

  ElSIF p_top_model_line_id is not null AND
        p_ato_line_id is null AND
        p_item_type_code = 'MODEL' THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('WB ITEM TYPE IS PTO MODEL '
                       || P_TOP_MODEL_LINE_ID , 3 );
    END IF;
    x_wb_item_type := 'PTO';

  ElSIF p_ato_line_id = p_line_id AND
        (p_item_type_code = 'MODEL' OR
         p_item_type_code = 'CLASS') THEN

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('WB ITEM TYPE IS ATO MODEL ' || P_ATO_LINE_ID , 3 );
    END IF;
    x_wb_item_type := 'MDL';

   ELSE

     IF p_ato_line_id = p_line_id AND
        (p_item_type_code = 'STANDARD' OR
         p_item_type_code = 'OPTION' OR
	 p_item_type_code = 'INCLUDED') THEN --9775352

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('WB ITEM TYPE IS ATO ITEM ' || P_LINE_ID , 3 );
       END IF;
       x_wb_item_type := 'ATO';

     ELSIF p_item_type_code = 'CONFIG' THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('WB ITEM TYPE IS CONFIG ITEM ' || P_LINE_ID , 3 );
       END IF;
       x_wb_item_type := 'CFG';

     ELSE
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('WB ITEM TYPE IS STD DROPSHIP ITEM '
                          || P_LINE_ID , 3 );
       END IF;
       x_wb_item_type := 'STD';
     END IF;

  END IF; -- if l_count > 0

  Print_Time('leaving Launch_Supply_Workbench '|| x_wb_item_type);

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN LAUNCH_SUPPLY_WORKBENCH'|| SQLERRM , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Launch_Supply_Workbench;

/* -----------------------------------------------------------
PROCEDURE Message_From_Cz
Called to copy the messages from the CZ schema to
the OM tables
--------------------------------------------------------------*/

PROCEDURE Message_From_Cz
( p_line_id            IN NUMBER,
  p_valid_config       IN VARCHAR2,
  p_complete_config    IN VARCHAR2,
  p_config_header_id   IN NUMBER,
  p_config_rev_nbr     IN NUMBER )
IS

    l_config_header_id                NUMBER := p_config_header_id;
    l_config_rev_nbr                  NUMBER := p_config_rev_nbr;
    l_message_text                    VARCHAR2(2000);
    l_msg                             VARCHAR2(2000);
    l_constraint                      VARCHAR2(16);

    CURSOR messages(p_config_hdr_id NUMBER, p_config_rev_nbr NUMBER) is
    SELECT constraint_type , message
    FROM   cz_config_messages
    WHERE  config_hdr_id =  p_config_hdr_id
    AND    config_rev_nbr = p_config_rev_nbr;


BEGIN
    oe_debug_pub.add(' Entering Message_From_Cz');

    OPEN messages(l_config_header_id, l_config_rev_nbr);

    LOOP
      FETCH messages into l_constraint,l_msg;
      EXIT when messages%notfound;

      OE_Msg_Pub.Add_Text(l_msg);
      oe_debug_pub.add('msg from spc: '||messages%rowcount , 2);
      oe_debug_pub.add('msg from spc: '|| substr(l_msg, 1, 250) , 3);

    END LOOP;

    IF nvl(p_valid_config, 'FALSE') = 'FALSE' THEN

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_VALIDATION_FAILURE');
      OE_Msg_Pub.Add;
    END IF;

    IF nvl(p_complete_config, 'FALSE') = 'FALSE'  THEN

      BEGIN

        SELECT nvl(ordered_item,inventory_item_id )
        INTO   l_message_text
        FROM   oe_order_lines
        WHERE  line_id = p_line_id;

      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;

      FND_MESSAGE.Set_Name('ONT', 'OE_CONFIG_INCOMPLETE_MODEL');
      FND_MESSAGE.SET_TOKEN('MODEL',l_message_text);
      OE_Msg_Pub.Add;

    END IF;

EXCEPTION
    WHEN OTHERS THEN
      OE_Debug_Pub.Add('Error in Message_From_Cz '|| sqlerrm, 2);
END Message_From_Cz;

/*--------------------------------------------------------
PROCEDURE Get_Config_Effective_Date

one of the i/p params p_model_line_rec  or p_model_line_id
should have a valid value - from caller.

callers:
cz ui call and batch val.
process order
options window ui and batch val.

profile value,
1 - old behavior
2 - creation date of model
3 - sysdate till booking.
4 - sysdate till pick release   -- #6187663
--------------------------------------------------------*/
PROCEDURE Get_Config_Effective_Date
( p_model_line_rec        IN  OE_Order_Pub.Line_Rec_Type := null
 ,p_model_line_id         IN  NUMBER    := null
 ,x_old_behavior          OUT NOCOPY    VARCHAR2
 ,x_config_effective_date OUT NOCOPY    DATE
 ,x_frozen_model_bill     OUT NOCOPY    VARCHAR2)
IS

  l_header_id           NUMBER;
  l_creation_date       DATE;
  l_profile             VARCHAR2(1);
  l_line_set_id         NUMBER;
  l_split_from_line_id  NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level > 0 THEN
    OE_Debug_Pub.Add
    ('entering Get_Config_Effective_Date '|| p_model_line_id, 3);
  END IF;

  IF p_model_line_rec.header_id is not NULL THEN

    l_header_id          := p_model_line_rec.header_id;

    OE_Debug_Pub.Add('model header id '|| p_model_line_rec.header_id, 3);
    OE_Debug_Pub.Add('split id '|| p_model_line_rec.split_from_line_id, 3);
    OE_Debug_Pub.Add('line id '|| p_model_line_rec.line_id, 3);

    IF p_model_line_rec.split_from_line_id is NOT NULL THEN

      SELECT creation_date
      INTO   l_creation_date
      FROM   oe_order_lines
      WHERE  header_id = l_header_id
      AND    line_set_id = p_model_line_rec.line_set_id
      AND    split_from_line_id is NULL;

      IF l_debug_level > 0 THEN
        OE_Debug_Pub.Add
        ('split '||p_model_line_rec.split_from_line_id||l_creation_date,3);
      END IF;

    ELSE

      IF p_model_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        l_creation_date := sysdate;
        IF l_debug_level > 0 THEN
          OE_Debug_Pub.Add('model is getting created today', 3);
        END IF;

      ELSE
        l_creation_date := p_model_line_rec.creation_date;
      END IF;

    END IF; -- split model or not

  ELSIF p_model_line_id is not NULL THEN

    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('using model line id '|| p_model_line_id, 3);
    END IF;

    SELECT header_id, creation_date,
           line_set_id, split_from_line_id
    INTO   l_header_id, l_creation_date,
           l_line_set_id, l_split_from_line_id
    FROM   oe_order_lines
    WHERE  line_id = p_model_line_id;

    IF l_split_from_line_id is NOT NULL THEN

      SELECT creation_date
      INTO   l_creation_date
      FROM   oe_order_lines
      WHERE  header_id = l_header_id
      AND    line_set_id = l_line_set_id
      AND    split_from_line_id is NULL;

      IF l_debug_level > 0 THEN
        OE_Debug_Pub.Add
        ('split case '|| l_split_from_line_id || l_creation_date, 3);
      END IF;
    END IF;

  ELSE

    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('something wrong in i/p'|| p_model_line_id, 3);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF; -- if model rec was sent in


  IF OE_CODE_CONTROL.get_code_release_level >= '110510' THEN

    l_profile := nvl(OE_Sys_Parameters.VALUE('ONT_CONFIG_EFFECTIVITY_DATE'),
                     '1');

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('pack J code '||l_profile, 1);
    END IF;

  ELSE

    l_profile := nvl(FND_PROFILE.Value('ONT_CONFIG_EFFECTIVITY_DATE'), '1');

    IF l_profile > 1 THEN

      IF OE_Process_Options_Pvt.Use_Configurator THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('USE CONFIGURATOR, ct fix' , 1);
        END IF;
      ELSE
        l_profile := 1;

      END IF;

    END IF;
  END IF; -- decide l_profile value


  IF  l_profile = '1' THEN
    x_old_behavior          := 'Y';
    x_config_effective_date := l_creation_date;
    x_frozen_model_bill     := 'Y';

  ELSIF  l_profile = '2' THEN
    x_old_behavior          := 'N';
    x_config_effective_date := l_creation_date;
    x_frozen_model_bill     := 'Y';

    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('creation date is effective date', 3);
    END IF;

  ELSIF l_profile = '3' THEN

    x_old_behavior          := 'N';

    SELECT nvl(booked_flag, 'N'), booked_date
    INTO   x_frozen_model_bill, x_config_effective_date
    FROM   oe_order_headers
    WHERE  header_id = l_header_id;

    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('booked, frozen: ' || x_frozen_model_bill, 3);
    END IF;

    IF x_frozen_model_bill = 'Y' THEN
      IF l_creation_date > x_config_effective_date THEN   --bug5969409
        x_config_effective_date := l_creation_date;
      ELSE
        l_header_id := sysdate - x_config_effective_date;

       IF l_header_id < 0.007 THEN -- some 10 min right now***
         IF l_debug_level > 0 THEN
          OE_Debug_Pub.Add('not frozen, as booked now? '||l_header_id , 3);
         END IF;
         x_frozen_model_bill := 'N';
       END IF;
      END IF;
    ELSE

      IF l_debug_level > 0 THEN
        OE_Debug_Pub.Add('not frozen, not booked', 3);
      END IF;
      x_config_effective_date := sysdate;
    END IF;
    -- Added for ER#6187663 Start
  ELSIF l_profile = '4' THEN  --ER#6187663: for OM:Configuration Effective Date='System Date till Pick Release'
    x_old_behavior          := 'N';
    x_config_effective_date := sysdate;
    /* x_frozen_model_bill='Y' if SO Booked  eles N*/
    SELECT nvl(booked_flag, 'N')    INTO   x_frozen_model_bill
    FROM   oe_order_headers
    WHERE  header_id = l_header_id;

    -- Added for ER#6187663 Start

  ELSE
    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('something wrong???', 3);
    END IF;
  END IF;

  IF l_debug_level > 0 THEN
    OE_Debug_Pub.Add
    ('leaving Get_Config_Effective_Date '||
      to_char(x_config_effective_date, 'DD-MON-YY HH24:MI:SS'), 3);
    OE_Debug_Pub.Add('sysdate '||to_char(sysdate, 'DD-MON-YY HH24:MI:SS'),3);
    OE_Debug_Pub.Add(x_frozen_model_bill  || '-'|| x_old_behavior, 3);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
      OE_Debug_Pub.Add('Get_Config_Effective_Date '|| sqlerrm, 1);
    END IF;

    x_config_effective_date := null;
    x_frozen_model_bill     := null;
    x_old_behavior          := null;

    RAISE;

END Get_Config_Effective_Date;


/*--------------------------------------------------------
PROCEDURE Print_Time

--------------------------------------------------------*/

PROCEDURE Print_Time(p_msg   IN  VARCHAR2)
IS
  l_time    VARCHAR2(100);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  l_time := to_char (new_time (sysdate, 'PST', 'EST'),
                                 'DD-MON-YY HH24:MI:SS');
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(P_MSG || ': '|| L_TIME , 1);
  END IF;
END Print_Time;

/*--------------------------------------------------------
PROCEDURE Unlock_Config

This API will be called before deleting or cacelling booked macd model.
--------------------------------------------------------*/

PROCEDURE  Unlock_Config(p_line_rec  IN OE_ORDER_PUB.line_rec_type,
                         x_return_status OUT NOCOPY VARCHAR2 )
IS

  l_top_container       VARCHAR2(1);
  l_part_of_container   VARCHAR2(1);
  l_locking_key         NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_return_status       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_order_number        NUMBER;

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('ENTERING OE_CONFIG_UTIL.Unlock_Config' , 1);
       END IF;


       OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
       (  p_line_id             => p_line_rec.line_id
         ,p_top_model_line_id   => p_line_rec.line_id
         ,x_top_container_model => l_top_container
         ,x_part_of_container   => l_part_of_container  );
       IF l_top_container = 'Y' THEN

          l_order_number := OE_SCHEDULE_UTIL.get_order_number(p_line_rec.header_id);

          IF l_debug_level  > 0 THEN

            oe_debug_pub.add(' Calling Unlock_Config' || p_line_rec.config_header_id,  2);
            oe_debug_pub.add(' Config rev nbr' || p_line_rec.config_rev_nbr,  2);
            oe_debug_pub.add(' Configuration_id ' || p_line_rec.configuration_id,  2);
            oe_debug_pub.add(' order_number  ' || l_order_number,  2);

          END IF;

          CZ_IB_LOCKING.Unlock_Config
          ( p_api_version            => 1.0,
            p_config_session_hdr_id  => p_line_rec.config_header_id,
            p_config_session_rev_nbr => p_line_rec.config_rev_nbr,
            p_config_session_item_id => null,
            p_source_application_id  => fnd_profile.value('RESP_APPL_ID'),
            p_source_header_ref      => l_order_number,
            p_source_line_ref1       => Null,
            p_source_line_ref2       => Null,
            p_source_line_ref3       => Null,
            p_commit                 => 'N',
            p_init_msg_list          => FND_API.G_TRUE,
            p_validation_level       => Null,
            p_locking_key            => Null,
            x_return_status          => x_return_status,
            x_msg_count              => l_msg_count,
            x_msg_data               => l_msg_data);

            IF l_debug_level  > 0 THEN

              oe_debug_pub.add(' After calling CZ Unlock_Config ' || x_return_status,2);
            END IF;

            IF l_msg_count > 0 THEN

               OE_MSG_PUB.Transfer_Msg_Stack;

            END IF;


       END IF;

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting  OE_CONFIG_UTIL.Unlock_Config'  || x_return_status, 1);
       END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('ERROR IN OE_CONFIG_UTIL.Unlock_Config'|| SQLERRM , 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Unlock_Config;

-- Added for DOO Pre Exploded Kit ER 9339742
PROCEDURE Process_Pre_Exploded_Kits
( p_top_model_line_id IN  NUMBER
, p_explosion_date    IN  DATE
-- p_top_model_line_id : has the Line_id of the top most parent in the Kit or PTO
-- p_explosion_date : has little significance in the processing because we just
--                  get this field from DOO so as to set the pre_exploded_flag value.
, x_return_status     OUT NOCOPY VARCHAR2
) IS
--
  l_return_status             VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
  l_cursor_query              VARCHAR2(4000);
  l_parent_line_rec           OE_Order_PUB.Line_Rec_Type;
  l_included_item_tbl         OE_Order_PUB.Line_Tbl_Type;
  l_included_item_rec         OE_Order_PUB.Line_Rec_Type;
  l_explosion_date            DATE;
  l_validation_org            NUMBER;
  l_item_check                BOOLEAN := FALSE;
  l_validation_status         BOOLEAN := FALSE;
  l_component_number          NUMBER := 0;
  l_parent_component_sequence_id NUMBER;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(4000);
  l_error_code                NUMBER;
  l_temp_line_id              NUMBER;
  l_line_id                   NUMBER;
  l_comp_line_id              NUMBER;
  l_inventory_item_id         NUMBER;
  l_included_item_line_id     NUMBER;
  x                           NUMBER := 0;
  y                           NUMBER := 0;
--
  -- Bom_Explosion_Rec record structure is created to store the values of each
  -- parent/sub-parent model information from EBS BOM based on parent
  -- Bill_Seq_id. It has two more fields: the OM's corresponding line_id of
  -- that immediate parent and its inventory item id, which is used later,
  -- after validating the DOO BOM with EBS BOM, to populate the reference
  -- information on OM tables i.e. Link_To_Line_id and Component_Code validation
  -- for each INCLUDED items in the BOM definition
  --
  TYPE Bom_Explosion_Rec IS RECORD
  ( component_item_id     bom_explosions.component_item_id%TYPE
  , component_sequence_id bom_explosions.component_sequence_id%TYPE
  , extended_quantity     bom_explosions.extended_quantity%TYPE
  , component_code        bom_explosions.component_code%TYPE
  , PRIMARY_UOM_CODE      bom_explosions.PRIMARY_UOM_CODE%TYPE
  , sort_order            bom_explosions.sort_order%TYPE
  , OM_Parent_Line_id     oe_order_lines_all.line_id%TYPE
  , OM_Parent_Inventory_Item_id    oe_order_lines_all.Inventory_Item_id%TYPE
  );


  CURSOR C_PreExploded_Kit (c_top_model_line_id IN NUMBER) IS
   SELECT line_id FROM oe_order_lines_all
   WHERE item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
   AND top_model_line_id = c_top_model_line_id
   AND top_model_line_id <> line_id;

  CURSOR C_Bom_Explosion_Info (p_top_bill_sequence_id IN NUMBER,
                               p_std_comp_freeze_date IN DATE)
  IS
   SELECT
      component_item_id,
      component_sequence_id,
      extended_quantity,
      component_code,
      PRIMARY_UOM_CODE,
      sort_order,
      null OM_Parent_Line_id,
      null OM_Parent_Inventory_Item_id
      -- To OM fields, setting the NULL values so as to complete the record structure
   FROM bom_explosions  be
   WHERE
      be.explosion_type = OE_GLOBALS.G_ITEM_INCLUDED --'INCLUDED'
      AND be.plan_level >= 0
      AND be.extended_quantity > 0
      AND be.TOP_BILL_SEQUENCE_ID = p_top_bill_sequence_id
      AND be.EFFECTIVITY_DATE <= p_std_comp_freeze_date
      AND be.DISABLE_DATE > p_std_comp_freeze_date
      AND be.COMPONENT_ITEM_ID <> be.TOP_ITEM_ID
   ORDER BY sort_order; -- Here the sort_order is performing a very important
   -- task. It is helping to get the right order of the components in a given model
   -- which is used to refer the same on OM base tables based on data from DOO BOM and
   -- hence processing it in the same sequence.

  l_Bom_Explosion_Rec Bom_Explosion_Rec;
  TYPE Bom_Explosion_Tbl IS TABLE OF Bom_Explosion_Rec INDEX BY BINARY_INTEGER;
  l_Bom_Explosion_Tbl Bom_Explosion_Tbl;

  -- C_Bill_Seq_id gives the Bill_Seq_id for each parent/sub-parent along with
  -- its corresponding Line_id and Inventory_Item_id from OM tables, which later
  -- get sets to Bom_Explosion_Rec
  CURSOR C_Bill_Seq_id ( p_top_model_line_id IN NUMBER, p_header_id IN NUMBER
                       , p_validation_org IN NUMBER) IS
    SELECT bom.bill_sequence_id, oel.line_id, oel.inventory_item_id
    FROM   bom_bill_of_materials bom, oe_order_lines_all oel
    WHERE  bom.ASSEMBLY_ITEM_ID = oel.inventory_item_id
    AND    oel.top_model_line_id = p_top_model_line_id
    AND    oel.header_id = p_header_id
    AND    oel.item_type_code in (OE_GLOBALS.G_ITEM_CLASS,OE_GLOBALS.G_ITEM_KIT,OE_GLOBALS.G_ITEM_MODEL)
    AND    bom.ORGANIZATION_ID = p_validation_org
    AND    bom.ALTERNATE_BOM_DESIGNATOR IS NULL;

  -- comp_number is used to set the Component_Number column on OE_Order_Lines_All
  -- table for all the INCLUDED item components inside its given immediate parent
  CURSOR comp_number (c_parent_line_id IN NUMBER, c_top_model_line_id IN NUMBER, c_header_id IN NUMBER) IS
   SELECT line_id
   FROM   oe_order_lines_all
   WHERE  link_to_line_id    = c_parent_line_id
   AND    top_model_line_id  = c_top_model_line_id
   AND    header_id          = c_header_id
   AND    item_type_code     = OE_GLOBALS.G_ITEM_INCLUDED;
--
  l_debug_level   CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add(' Entering OE_Config_Util.Process_Pre_Exploded_Kits',1);
  end if;

  x_return_status := l_return_status;

  -- Getting the complete record structure for the top model parent line
  -- and Locking it at the same time
  OE_LINE_UTIL.Lock_Row
     (p_line_id       => p_top_model_line_id
     ,p_x_line_rec    => l_parent_line_rec
     ,x_return_status => l_return_status);

  if l_debug_level > 0 then
    oe_debug_pub.add(' Parent Line is Locked and Queried',5);
  end if;

  -- A top model parent line can either be a MODEL in a case of PTO or KIT
  -- in case of Kits. It cannot have any other values. If it is then no
  -- processing is required. RETURN from the code.
  IF l_parent_line_rec.item_type_code Not IN (OE_GLOBALS.G_ITEM_MODEL,OE_GLOBALS.G_ITEM_KIT)
     OR l_parent_line_rec.ordered_quantity = 0
  -- OR l_parent_line_rec.explosion_date is null
  THEN
    if l_debug_level  > 0 then
      oe_debug_pub.add(' The parent line is not a Kit, Kit in a Class, or Qty is 0. RETURN...',1);
    end if;
    RETURN;
  END IF;

  OPEN C_PreExploded_Kit (l_parent_line_rec.top_model_line_id);
  IF C_PreExploded_Kit%ISOPEN THEN
    LOOP
      FETCH C_PreExploded_Kit INTO l_included_item_line_id;
      EXIT WHEN C_PreExploded_Kit%NOTFOUND;
        y := y + 1;
        OE_LINE_UTIL.Query_Row
        ( p_line_id       => l_included_item_line_id
        , x_line_rec      => l_included_item_rec);
        l_included_item_tbl(y) := l_included_item_rec;
    END LOOP;
  END IF;
  CLOSE C_PreExploded_Kit;

  if l_debug_level > 0 then
    oe_debug_pub.add(' Count of Included Items under Kit : '||l_included_item_tbl.COUNT,5);
  end if;

  l_explosion_date := SYSDATE;
  l_validation_org := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

  Explode( p_validation_org => l_validation_org,
           p_levels         => 6, --??
           p_stdcompflag    => OE_BMX_STD_COMPS_ONLY,
           p_top_item_id    => l_parent_line_rec.inventory_item_id,
           p_revdate        => l_explosion_date,
           x_msg_data       => l_msg_data,
           x_error_code     => l_error_code,
           x_return_status  => l_return_status);

  if l_debug_level > 0 then
    oe_debug_pub.add(' Return Status from BOM Explosion API is : '||l_return_status,1);
  end if;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN C_Bill_Seq_id ( l_parent_line_rec.top_model_line_id,
                       l_parent_line_rec.header_id,
                       l_validation_org);
  IF C_Bill_Seq_id%ISOPEN THEN
    LOOP
      FETCH C_Bill_Seq_id INTO l_parent_component_sequence_id, l_line_id, l_inventory_item_id;
      EXIT WHEN C_Bill_Seq_id%NOTFOUND;

      if l_debug_level > 0 then
        oe_debug_pub.add(' Get BOM for parent Seq id = '||l_parent_component_sequence_id,5);
      end if;
      OPEN C_Bom_Explosion_Info (l_parent_component_sequence_id, l_explosion_date);
        IF C_Bom_Explosion_Info%ISOPEN THEN
          LOOP
            FETCH C_Bom_Explosion_Info INTO l_Bom_Explosion_Rec;
            EXIT WHEN C_Bom_Explosion_Info%NOTFOUND;
            x := x + 1;
            l_Bom_Explosion_Tbl(x) := l_Bom_Explosion_Rec;
            l_Bom_Explosion_Tbl(x).OM_Parent_Line_id := l_line_id;
            l_Bom_Explosion_Tbl(x).OM_Parent_Inventory_Item_id := l_inventory_item_id;
          END LOOP;
        END IF;
      CLOSE C_Bom_Explosion_Info;
    END LOOP;
  END IF;
  CLOSE C_Bill_Seq_id;

  if l_debug_level > 0 then
    oe_debug_pub.add(' Validating BOM definition between DOO and EBS',5);
    oe_debug_pub.add(' ---------------------------------------------',5);
    oe_debug_pub.add(' EBS OM Information from DOO -',5);
    oe_debug_pub.add(' Count of Included Items : '||l_included_item_tbl.count,5);
    for i in l_included_item_tbl.first .. l_included_item_tbl.last loop
      oe_debug_pub.add(' Line_id : '||l_included_item_tbl(i).line_id,5);
      oe_debug_pub.add(' Inventory Item id : '||l_included_item_tbl(i).inventory_item_id,5);
      oe_debug_pub.add(' Ordered Quantity UOM : '||l_included_item_tbl(i).order_quantity_uom,5);
      oe_debug_pub.add(' Ord Qty Ratio : '||l_included_item_tbl(i).ordered_quantity/l_parent_line_rec.ordered_quantity,5);
    end loop;

    oe_debug_pub.add(' EBS BOM Information -',5);
    oe_debug_pub.add(' Count of Included Items : '||l_Bom_Explosion_Tbl.count,5);
    for i in l_Bom_Explosion_Tbl.first .. l_Bom_Explosion_Tbl.last loop
      oe_debug_pub.add(' Inventory Item id : '||l_Bom_Explosion_Tbl(i).component_item_id,5);
      oe_debug_pub.add(' BOM Quantity UOM : '||l_Bom_Explosion_Tbl(i).primary_uom_code,5);
      oe_debug_pub.add(' Quantity Ratio : '||l_Bom_Explosion_Tbl(i).extended_quantity,5);
    end loop;
  end if;

  -- The DOO BOM and EBS BOM Validation Start
  -------------------------------------------
  --
  -- Note: It may be possible that DOO BOM pass invalid association
  -- between the Model, Class, Option Items, or Included Items via
  -- wrong Link_To_Line_Index. However, since the assumtion is: DOO
  -- BOM and EBS BOM will be always in sync, we are safe to assume
  -- it to be always same. Considering this factor, the below code
  -- is designed in such a manner that even with wrong Link_To_Line_index
  -- values, system will create a successful BOM in EBS with all the
  -- links correctly established. We are not validating this because
  -- if we happen to do it then we are contracting the assumption we
  -- have taken above, without which, there may be tens of many more
  -- required validation to be considered but we are safely ignoring
  -- them.
  --
  -- Validating if the EBS BOM definition in BOM_Explosions table
  -- and BOM information passed by DOO in OE_order_Lines_All table is same
  IF l_included_item_tbl.COUNT <> l_Bom_Explosion_Tbl.COUNT THEN
    if l_debug_level > 0 then
      oe_debug_pub.add(' The count of Included Items are not same',5);
    end if;
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_BOM');
    oe_msg_pub.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_Bom_Explosion_Tbl.COUNT > 0 THEN
    FOR j IN l_Bom_Explosion_Tbl.FIRST .. l_Bom_Explosion_Tbl.LAST LOOP
      IF l_included_item_tbl.COUNT > 0 THEN
        FOR i IN l_included_item_tbl.FIRST .. l_included_item_tbl.LAST LOOP

          l_validation_status := FALSE;

          -- Inventory Item Check
          -- There is an assumption from DOO that a BOM definition
          -- will have every Inventory Item unique
          l_item_check := FALSE;
          IF l_included_item_tbl(i).inventory_item_id = l_Bom_Explosion_Tbl(j).component_item_id THEN

            l_item_check := TRUE;
            l_validation_status := TRUE;

            if l_debug_level > 0 then
              oe_debug_pub.add(' Inventory Item id is matching'||l_included_item_tbl(i).inventory_item_id,5);
            end if;

            -- Ordered Quantity Ratio Check
            IF l_included_item_tbl(i).ordered_quantity/l_parent_line_rec.ordered_quantity =
                      l_Bom_Explosion_Tbl(j).extended_quantity THEN
              if l_debug_level > 0 then
                oe_debug_pub.add(' Quantity is in ratio : '||l_Bom_Explosion_Tbl(j).extended_quantity,5);
              end if;
            ELSE
              if l_debug_level > 0 then
                oe_debug_pub.add(' Quantity is NOT in ratio',1);
              end if;
              l_validation_status := FALSE;
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_QTY_RATIO');
              oe_msg_pub.add;
            END IF;

            -- Ordered Quantity UOM Check
            -- There is an assumption from DOO that DOO UOM, EBS OM UOM
            -- and EBS BOM UOM will be same
            IF l_included_item_tbl(i).order_quantity_uom = l_Bom_Explosion_Tbl(j).primary_uom_code THEN
              if l_debug_level > 0 then
                oe_debug_pub.add(' Quantity UOM is matching : '||l_Bom_Explosion_Tbl(j).primary_uom_code,5);
              end if;
            ELSE
              if l_debug_level > 0 then
                oe_debug_pub.add(' Quantity UOM is NOT matching : '||l_Bom_Explosion_Tbl(j).primary_uom_code,5);
              end if;
              l_validation_status := FALSE;
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_UOM');
              oe_msg_pub.add;
            END IF;

            IF l_validation_status THEN
              if l_debug_level > 0 then
                oe_debug_pub.add(' Setting the BOM data in OM for Line : '||l_included_item_tbl(i).line_id,5);
              end if;

              UPDATE OE_order_Lines_All
              SET    Component_Sequence_id = l_Bom_Explosion_Tbl(j).component_sequence_id
                   , Sort_Order = l_Bom_Explosion_Tbl(j).sort_order
                   , Component_Code = l_Bom_Explosion_Tbl(j).component_code
                   , Explosion_Date = l_explosion_date
                   , Link_To_Line_id = l_Bom_Explosion_Tbl(j).OM_Parent_Line_id
                   , lock_control = lock_control + 1
              WHERE  Line_id = l_included_item_tbl(i).line_id;

              l_included_item_tbl(i).Component_Sequence_id := l_Bom_Explosion_Tbl(j).component_sequence_id;
              l_included_item_tbl(i).Sort_Order            := l_Bom_Explosion_Tbl(j).sort_order;
              l_included_item_tbl(i).Component_Code        := l_Bom_Explosion_Tbl(j).component_code;
              l_included_item_tbl(i).Explosion_Date        := l_explosion_date;
              l_included_item_tbl(i).Link_To_Line_id       := l_Bom_Explosion_Tbl(j).OM_Parent_Line_id;

              IF l_included_item_tbl(i).component_code <> (l_Bom_Explosion_Tbl(j).OM_Parent_Inventory_Item_id||'-'||l_included_item_tbl(i).inventory_item_id) THEN
                if l_debug_level > 0 then
                  oe_debug_pub.add(' Invalid Association between the Included Item and its immediate parent',1);
                end if;
                l_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_BOM');
                oe_msg_pub.add;
                RAISE FND_API.G_EXC_ERROR;
              END IF;

              -- Since there is a valid match found and updated
              -- on the OM order line, Exit the child Loop
              EXIT;

            END IF;

          END IF; -- l_included_item_tbl(i).inventory_item_id
        END LOOP;

        IF NOT(l_item_check) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add(' Inventory Item Mismatch : '||l_Bom_Explosion_Tbl(j).component_item_id,1);
          end if;
          l_validation_status := FALSE;
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_ITEM');
          oe_msg_pub.add;
        END IF;

        IF NOT(l_validation_status) THEN
          if l_debug_level > 0 then
            oe_debug_pub.add(' BOM Validation Failure',1);
          end if;
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('ONT', 'OE_DOO_INVALID_BOM');
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      ELSE
        if l_debug_level > 0 then
          oe_debug_pub.add(' There are no Included Items from BOM Explosion',5);
        end if;
      END IF; -- l_included_item_tbl
    END LOOP;
  END IF; -- l_Bom_Explosion_Tbl

  IF l_Bom_Explosion_Tbl.COUNT > 0 THEN
    FOR j IN l_Bom_Explosion_Tbl.FIRST .. l_Bom_Explosion_Tbl.LAST LOOP
      OPEN  comp_number ( l_Bom_Explosion_Tbl(j).OM_Parent_Line_id
                        , l_parent_line_rec.top_model_line_id
                        , l_parent_line_rec.header_id);
      LOOP
        FETCH comp_number INTO l_comp_line_id;
        EXIT WHEN comp_number%NOTFOUND;

        l_component_number := l_component_number + 1;

        UPDATE oe_order_lines
        SET    component_number = l_component_number,
               lock_control     = lock_control + 1
        WHERE  line_id = l_comp_line_id;

      END LOOP;
      CLOSE comp_number;
      l_component_number := 0;
    END LOOP;
  END IF;

  UPDATE OE_order_Lines_All
  SET    Explosion_Date = l_explosion_date
       , lock_control = lock_control + 1
  WHERE  Line_id = l_parent_line_rec.line_id;

  x_return_status := l_return_status;

  if l_debug_level > 0 then
    oe_debug_pub.add(' Exiting OE_Config_Util.Process_Pre_Exploded_Kits',1);
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Process_Pre_Exploded_Kits'
      );
    END IF;
END Process_Pre_Exploded_Kits;

END OE_CONFIG_UTIL;

/
