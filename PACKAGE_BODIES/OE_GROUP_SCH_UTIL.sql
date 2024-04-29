--------------------------------------------------------
--  DDL for Package Body OE_GROUP_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GROUP_SCH_UTIL" AS
/* $Header: OEXUGRPB.pls 120.26.12010000.4 2010/03/15 09:28:12 spothula ship $ */

G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_GROUP_SCH_UTIL';
G_TOP_MODEL_LINE_ID         NUMBER;
G_PART_OF_SET               BOOLEAN;
G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; -- Added for bug 8636027

/*---------------------------------------------------------------------
Procedure Name : Validate_Item_Warehouse
Description    : This API will be called to check valid Item and warehouse
                 combinition
--------------------------------------------------------------------- */
Procedure Validate_Item_Warehouse
(p_inventory_item_id      IN NUMBER,
 p_ship_from_org_id       IN NUMBER,
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_validate_combinition NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_GROUP_SCH_UTIL.VALIDATE_ITEM_WAREHOUSE' , 2 ) ;
   END IF;
   -- bug 3594016
   IF (p_inventory_item_id is NOT NULL
      AND p_ship_from_org_id is NOT NULL)
   THEN
      SELECT 1
      INTO   l_validate_combinition
      FROM   mtl_system_items_b msi,
            org_organization_definitions org
      WHERE  msi.inventory_item_id= p_inventory_item_id
      AND    org.organization_id=msi.organization_id
      AND    sysdate<=nvl(org.disable_date,sysdate)
      AND    org.organization_id=p_ship_from_org_id
      AND    rownum=1 ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 THEN
          oe_debug_pub.add('INVALID ITEM WAREHOUSE COMBINATION',3);
       END IF;
       FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ITEM_WHSE');
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
END Validate_Item_Warehouse;

/*---------------------------------------------------------------------
Procedure Name : Validate_group_Line
Description    : Validates a line before scheduling.
                 This API will be called only when line is getting
                 scheduled or reserved.
                 IF the profile OM:Schedule Line on Hold is set to 'Y'
                 we will perform scheduling on lines on hold. If it is
                 set to 'N', we will not perform scheduling.
--------------------------------------------------------------------- */
Procedure Validate_Group_Line
(p_line_rec      IN OE_ORDER_PUB.Line_Rec_Type,
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_result                 VARCHAR2(30);
  l_scheduling_level_code  VARCHAR2(30) := NULL;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

   x_return_status   := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '..ENTERING OE_SCHEDULE_UTIL.VALIDATE_GROUP_LINE' , 6 ) ;
   END IF;

   -- If the line is shipped, scheduling is not allowed.

   IF p_line_rec.shipped_quantity is not null AND
      p_line_rec.shipped_quantity <> FND_API.G_MISS_NUM THEN

      -- The line is cancelled. Cannot perform scheduling
      -- on it.

       FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_SHIPPED');
       OE_MSG_PUB.Add;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' SHIPPED LINE.' , 4 ) ;
       END IF;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;

   END IF;

   IF p_line_rec.schedule_status_code is NULL THEN

     -- If the request_date on the line is missing or null and
     -- if the user is trying to performing scheduling,
     -- it is an error

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING THE REQUEST DATE....' , 1 ) ;
     END IF;
     IF (p_line_rec.request_date is null OR
         p_line_rec.request_date = FND_API.G_MISS_DATE) THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_MISSING_REQUEST_DATE');
         OE_MSG_PUB.Add;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'REQUEST DATE IS MISSING' , 4 ) ;
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CHECKING FOR HOLDS....' , 1 ) ;
     END IF;
     -- Call will be made to validate_group_line only when
     -- line is getting scheduled due to action OESCH_ACT_SCHEDULE
     -- or OESCH_ACT_RESERVE.

--     IF   FND_PROFILE.VALUE('ONT_SCHEDULE_LINE_ON_HOLD') = 'N'
     IF oe_sys_parameters.value ('ONT_SCHEDULE_LINE_ON_HOLD') = 'N' --moac
     THEN
      -- Since the profile is set to NO, we should not schedule
      -- the line if the line is on hold.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING CHECK HOLDS' , 1 ) ;
        END IF;

        OE_Holds_PUB.Check_Holds
         (   p_api_version       => 1.0
         ,   p_init_msg_list     => FND_API.G_FALSE
         ,   p_commit            => FND_API.G_FALSE
         ,   p_validation_level  => FND_API.G_VALID_LEVEL_FULL
         ,   x_return_status     => x_return_status
         ,   x_msg_count         => l_msg_count
         ,   x_msg_data          => l_msg_data
         ,   p_line_id           => p_line_rec.line_id
         ,   p_hold_id           => NULL
         ,   p_entity_code       => NULL
         ,   p_entity_id         => NULL
         ,   x_result_out        => l_result);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING CHECK HOLDS: ' || X_RETURN_STATUS , 1 ) ;
        END IF;


        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF (l_result = FND_API.G_TRUE) THEN
            FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_ON_HOLD');
            OE_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LINE IS ON HOLD' , 4 ) ;
            END IF;
            RETURN;
        END IF;

     END IF;
   END IF;
   -- Check to see what scheduling level is allowed to be performed
   -- on this line. If the action requested is not allowed for the
   -- scheduling action, error out.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING SCHEDULING LEVEL...' , 1 ) ;
   END IF;
   l_scheduling_level_code :=
    OE_SCHEDULE_UTIL.Get_Scheduling_Level(p_line_rec.header_id,
                                          p_line_rec.line_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SCHEDULING_LEVEL_CODE : ' || L_SCHEDULING_LEVEL_CODE , 1 ) ;
   END IF;

   IF l_scheduling_level_code is not null THEN
     IF l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_ONE THEN

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('ACTION', p_line_rec.schedule_action_code);
        FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                 nvl(OE_SCHEDULE_UTIL.sch_cached_line_type,
                     OE_SCHEDULE_UTIL.sch_cached_order_type));
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE TYPE IS ATP ONLY' , 4 ) ;
        END IF;

     ELSIF l_scheduling_level_code = OE_SCHEDULE_UTIL.SCH_LEVEL_TWO
     AND   p_line_rec.schedule_action_code =
                                  OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
     THEN

        FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('ACTION',
                  nvl(p_line_rec.schedule_action_code,
                      OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE));
        FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                 nvl(OE_SCHEDULE_UTIL.sch_cached_line_type,
                     OE_SCHEDULE_UTIL.sch_cached_order_type));
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE TYPE IS NOT ELIGIBLE FOR RESERVATION ' , 4 ) ;
        END IF;

     END IF;
   END IF;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  '..EXITING OE_SCHEDULE_UTIL.VALIDATE_GROUP_LINE WITH ' || X_RETURN_STATUS , 1 ) ;
                        END IF;


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Group_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Group_Line;

/*---------------------------------------------------------------------
Procedure Name : Validate_Group
Description    : Validate Group calls Validate Line and if the call is success
then and pass the record back to the caller. If it is a expected error, then ignore the record and if it is a unexpected error raise the error and stop the process.
--------------------------------------------------------------------- */
Procedure Validate_Group
(p_x_line_tbl    IN  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
 p_sch_action    IN  VARCHAR2,
 p_validate_action IN VARCHAR2 DEFAULT 'PARTIAL',     --for bug 3590437
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_return_status VARCHAR2(30);
J               NUMBER := 0;
l_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- 3870895 : Revorted back the code modified for bug 3349770
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING VALIDATE GROUP' || P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR I IN 1..p_x_line_tbl.count LOOP

   OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => p_x_line_tbl(I).line_id
         ,p_header_id                   => p_x_line_tbl(I).header_id
         ,p_line_id                     => p_x_line_tbl(I).line_id
         ,p_orig_sys_document_ref       =>
                                p_x_line_tbl(I).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                p_x_line_tbl(I).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                p_x_line_tbl(I).orig_sys_shipment_ref
         ,p_change_sequence             =>  p_x_line_tbl(I).change_sequence
         ,p_source_document_id          =>
                                p_x_line_tbl(I).source_document_id
         ,p_source_document_line_id     =>
                                p_x_line_tbl(I).source_document_line_id
         ,p_order_source_id             =>
                                p_x_line_tbl(I).order_source_id
         ,p_source_document_type_id     =>
                                p_x_line_tbl(I).source_document_type_id);
   --3564310
   -- Checking for Warehouse Validation
   Validate_Item_Warehouse
               (p_inventory_item_id  => p_x_line_tbl(I).inventory_item_id,
                p_ship_from_org_id   => p_x_line_tbl(I).ship_from_org_id,
                x_return_status => l_return_status);
   IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
      OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => p_x_line_tbl(I),
                                  p_old_line_rec  => p_x_line_tbl(I),
                                  p_sch_action    => p_sch_action ,
                                  x_return_status => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

         J := J + 1;
         l_line_tbl(J) := p_x_line_tbl(I);

      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR   THEN -- 3870895

         x_return_status := FND_API.G_RET_STS_ERROR;
         --5166476
         IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
            IF p_x_line_tbl(I).ship_model_complete_flag = 'N' AND
              p_x_line_tbl(I).top_model_line_id IS NOT NULL AND
              (p_x_line_tbl(I).ato_line_id IS NULL OR
              p_x_line_tbl(I).ato_line_id <> p_x_line_tbl(I).top_model_line_id) AND
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN
               IF NOT OE_SCH_CONC_REQUESTS.included_processed(p_x_line_tbl(I).line_id) THEN
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INCLUDED PROCESSED : ' || p_x_line_tbl(I).line_id, 3 ) ;
                 END IF;
                 -- 5166476
                 OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_x_line_tbl(I).line_id) := 'N';
               END IF;
            ELSE
               --5166476
               OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_x_line_tbl(I).line_id) := 'N';
            END IF;
         END IF;
      END IF;
   ELSE -- 3564310
      IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
         --5166476
         OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(p_x_line_tbl(I).line_id) := 'N';
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

  END LOOP;
  IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN  -- 3870895
     p_x_line_tbl := l_line_tbl;
   --5166476
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR
     AND l_line_tbl.count > 0 THEN
     IF OE_SCH_CONC_REQUESTS.g_conc_program = 'Y' THEN
        FOR I IN 1..l_line_tbl.count LOOP
           OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_tbl(I).line_id) := 'N';
        END LOOP;
     END IF;

  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING VALIDATE GROUP' || P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Validate_Group');
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Group;

Function Not_Part_of_set(p_top_model_line_id IN NUMBER)
RETURN BOOLEAN
IS
l_set_id NUMBER := Null;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Entering  Not_Part_of_set ' || p_top_model_line_id , 1 ) ;
      oe_debug_pub.add(  'Value of the cached model ' || g_top_model_line_id,2);
  END IF;
   IF p_top_model_line_id = g_top_model_line_id
   THEN
      RETURN g_part_of_set;
   Else

     BEGIN

      Select nvl(arrival_set_id,ship_set_id)
      Into   l_set_id
      From   oe_order_lines_all
      Where  line_id = p_top_model_line_id;

      IF l_set_id is null THEN
         g_part_of_set := TRUE;
      ELSE
         g_part_of_set := FALSE;
      END IF;
      g_top_model_line_id := p_top_model_line_id;
      Return g_part_of_set;
     EXCEPTION

      WHEN OTHERS THEN
         g_part_of_set := TRUE;
         Return g_part_of_set;
     END;

   END IF;
END Not_Part_of_set;
/* ----------------------------------------------------------------
Procedure Check_Merge_Line:
This procedure checks if the Line Id that is going to be Merged
into the l_line_tbl is already existing in that plsql table.
If the Line_Id is not existing in the table it merges the Line_id
with the existing l_line_tbl plsql Table
Bug Number:2319608

Procedure Check_Merge_Line(
               p_x_line_tbl  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
               p_line_tbl    IN OE_ORDER_PUB.Line_Tbl_Type
                                := OE_Order_PUB.G_MISS_LINE_TBL,
               p_line_rec    IN OE_ORDER_PUB.Line_rec_Type
                                := OE_Order_PUB.G_MISS_LINE_REC)
IS
J               NUMBER;
l_option_exists VARCHAR2(1) := 'N';

BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Entering Check_Merge_Line: ' || p_x_line_tbl.count,1);
     oe_debug_pub.add('Size of the in table : ' || p_line_tbl.count,1);
  END IF;
  J := p_x_line_tbl.count;
  IF p_line_rec.line_id is NOT NULL
  AND p_line_rec.line_id <> FND_API.G_MISS_NUM THEN -- Main IF Start

     FOR l_option_search in 1..J LOOP
       IF p_line_rec.line_id = p_x_line_tbl(l_option_search).line_id THEN
          IF l_debug_level  > 0 THEN
             OE_DEBUG_PUB.Add('Option already exists in the line table',1);
          END IF;
         l_option_exists := 'Y';
         EXIT; -- Exit the Loop if a match is found
       END IF;
     END LOOP;

     --If no matches are found then Merge the record.
     IF l_option_exists = 'N' THEN
       p_x_line_tbl(J+1) := p_line_rec;
     END IF;

  ELSE

    FOR I in 1..p_line_tbl.count LOOP
      l_option_exists := 'N';
      FOR l_option_search in 1..p_x_line_tbl.count LOOP
        IF p_line_tbl(I).line_id = p_x_line_tbl(l_option_search).line_id THEN
           IF l_debug_level  > 0 THEN
              OE_DEBUG_PUB.Add('Option already exists in the line table',1);
           END IF;
          l_option_exists := 'Y';
          EXIT; -- Exit the Inner Loop if a match is found
        END IF;
      END LOOP;

      --If no matches are found then Merge the record.
      IF l_option_exists = 'N' THEN
        J := J + 1;
        p_x_line_tbl(J) := p_line_tbl(I);
      END IF;
    END LOOP;

  END IF; -- Main IF End
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('Exiting Check_Merge_Line: ' || p_x_line_tbl.count,1);
  END IF;

End Check_Merge_Line;
*/

/*----------------------------------------------------------------
FUNCTION    :  Find_Line
Description :  This Function returns TRUE if the line already
               exist in the line table else FALSE
               Added for Bug-2454163
------------------------------------------------------------------*/

FUNCTION Find_line( p_x_line_tbl  IN OE_ORDER_PUB.Line_Tbl_Type,
                    p_line_id     IN  NUMBER)
Return BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING FIND_LINE: ' || P_LINE_ID , 1 ) ;
  END IF;

  FOR J IN 1..p_x_line_tbl.count LOOP

     IF p_line_id = p_x_line_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE EXISTS IN THE TABLE' , 1 ) ;
         END IF;

         RETURN TRUE;
     END IF;
  END LOOP;

 RETURN FALSE;

END Find_line;


/*----------------------------------------------------------------
PROCEDURE Query_Lines
Description:

  This is a internal procedure. This procedure will be called when user
  performs any scheduling action from header lever. Schedule Order API will
  will call this procedure to query all valid lines for requested scheduling
  operation.
  This procedure will return all valid records to caller when action is
  schedule/unschedule/atp check/unreserve. If the action is reserve and line is
  scheduled, the line will not be passed to caller and it performs the reservati  on action.

---------------------------------------------------------------------*/
PROCEDURE Query_Lines
( p_header_id   IN NUMBER,
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
I                 NUMBER;
l_inc_tbl         OE_Order_PUB.Line_Tbl_Type;
l_sales_order_id  NUMBER := Null;
l_line_rec        OE_Order_PUB.Line_Rec_type;
l_return_status   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_set_rec         OE_ORDER_CACHE.set_rec_type;
l_quantity_to_reserve    NUMBER;
l_quantity2_to_reserve    NUMBER; -- INVCONV
l_rsv_update            BOOLEAN := FALSE;

CURSOR Process_inc is
   SELECT line_id
   FROM   oe_order_lines_all
   WHERE  header_id = p_header_id
   AND    open_flag = 'Y'
   AND    ato_line_id is NULL
   AND    item_type_code IN ('MODEL', 'CLASS', 'KIT')
   AND    schedule_status_code is NULL;


CURSOR l_line_csr IS
    SELECT line_id,schedule_status_code,
           shippable_flag
    FROM   oe_order_lines_all
    WHERE  header_id = p_header_id
    AND    open_flag = 'Y'
    AND    line_category_code <> 'RETURN'
    AND    item_type_code <> 'SERVICE'
    AND    source_type_code <> OE_GLOBALS.G_SOURCE_EXTERNAL
    ORDER BY arrival_set_id,ship_set_id,line_number,shipment_number,nvl(option_number,-1);

CURSOR l_line_inc_csr IS
    SELECT line_id,ship_set_id,arrival_set_id, shippable_flag,
           shipping_interfaced_flag,orig_sys_document_ref, orig_sys_line_ref,
           orig_sys_shipment_ref, change_sequence, source_document_type_id,
           source_document_id, source_document_line_id, order_source_id
    FROM   oe_order_lines_all
    WHERE  header_id = p_header_id
    AND    open_flag = 'Y'
    AND    line_category_code <> 'RETURN'
    AND    schedule_status_code IS NOT NULL
    ORDER BY arrival_set_id,ship_set_id,line_number,shipment_number,nvl(option_number,-1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING QUERY LINES' , 1 ) ;
    END IF;

    -- Process Included Items if the action is schedule, atp_check
    -- and reserve.

    IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE OR
       p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE  OR
       p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK THEN

       OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
       OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

       FOR I IN process_inc LOOP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'BEFORE CALLING INC'|| I.LINE_ID , 3 ) ;
        END IF;
        l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                           (p_line_id   => I.line_id,
                            p_freeze    => FALSE);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AFTER CALLING INC'|| L_RETURN_STATUS , 3 ) ;
        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
        END IF;

       END LOOP;

       OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
       OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    END IF;



    IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
    THEN

     -- If the action is schedule,
     -- then only query the lines that are not scheduled.
     -- Re-scheduling should be allowed on the scheduled lines.
     -- Prepare out table with the lines which are not scheduled.

     I := 0;
     FOR c1 IN l_line_csr LOOP


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'PROCESSING LINE ' || C1.LINE_ID , 1 ) ;
       END IF;

       IF c1.schedule_status_code is null THEN

         --4382036
         /* OE_Line_Util.Query_Row( p_line_id  => c1.line_id
                                    ,x_line_rec => l_line_rec);
         */

         OE_Line_Util.Lock_Row(p_line_id => c1.line_id,
		       p_x_line_rec    => l_line_rec,
		       x_return_status => l_return_status);


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
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);

         l_line_rec.schedule_action_code := p_sch_action;
         -- 2766876
         l_line_rec.reserved_quantity := 0;

         l_return_status := FND_API.G_RET_STS_SUCCESS;
         OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                        p_old_line_rec  => l_line_rec,
                                        p_sch_action    => p_sch_action,
                                        x_return_status => l_return_status);


         IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN

           I := I + 1;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE SELECTED FOR SCHEDULING **** : ' || L_LINE_REC.LINE_ID , 1 ) ;
            END IF;
            x_line_tbl(I) := l_line_rec;
            x_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

            IF (x_line_tbl(I).arrival_set_id is not null) THEN

                l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( x_line_tbl(I).arrival_set_id);
                x_line_tbl(I).arrival_set   := l_set_rec.set_name;

            ELSIF (x_line_tbl(I).ship_set_id is not null) THEN

                l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( x_line_tbl(I).Ship_set_id);
                x_line_tbl(I).ship_set      := l_set_rec.set_name;

            ELSIF (x_line_tbl(I).ship_model_complete_flag ='Y') THEN
                x_line_tbl(I).ship_set      := x_line_tbl(I).top_model_line_id;
            ELSIF (x_line_tbl(I).ato_line_id is not null)
             AND NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10) THEN
                x_line_tbl(I).ship_set      := x_line_tbl(I).ato_line_id;
            END IF;


         END IF;
       END IF; -- schedule status code

     END LOOP;

    ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
    THEN


     --If the line is not scheduled,system should schedule and reserve the line.

     I := 0;
     FOR c1 IN l_line_csr LOOP

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE_ID :' || C1.LINE_ID , 1 ) ;
       END IF;

       -- 4382036
       /* OE_Line_Util.Query_Row( p_line_id  => c1.line_id
                              ,x_line_rec => l_line_rec);
       */

       OE_Line_Util.Lock_Row(p_line_id => c1.line_id,
		       p_x_line_rec    => l_line_rec,
		       x_return_status => l_return_status);


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
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);

       l_line_rec.schedule_action_code := p_sch_action;

       IF l_line_rec.schedule_status_code is not null THEN

         IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

           IF l_sales_order_id is null THEN
             l_sales_order_id :=
                  OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(p_header_id);
           END IF;

            -- INVCONV - MERGED CALLS    FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                  OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );


           /*l_line_rec.reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                   (p_header_id   => l_sales_order_id,
                    p_line_id     => l_line_rec.line_id,
                    p_org_id      => l_line_rec.ship_from_org_id); */

                                         IF  l_line_rec.reserved_quantity IS NULL
           OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
               l_line_rec.reserved_quantity := 0;
           END IF;

                                         /*l_line_rec.reserved_quantity2 :=      -- INVCONV
              OE_LINE_UTIL.Get_Reserved_Quantity2
                   (p_header_id   => l_sales_order_id,
                    p_line_id     => l_line_rec.line_id,
                    p_org_id      => l_line_rec.ship_from_org_id);*/

           /*IF  l_line_rec.reserved_quantity2 IS NULL
           OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
               l_line_rec.reserved_quantity2 := 0;
           END IF;   */ -- INVCONV PAL


           -- Pack J
           IF l_line_rec.reserved_quantity = 0
            OR ( OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
               --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG')= 'Y'
               AND l_line_rec.ordered_quantity >
                                 l_line_rec.reserved_quantity) THEN


              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'NEED TO RESERVE THE LINE' , 2 ) ;
              END IF;

             -- Check if the line is eligible for reservation.
             l_return_status := FND_API.G_RET_STS_SUCCESS;
             OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                            p_old_line_rec  => l_line_rec,
                                            p_sch_action    => p_sch_action,
                                            x_return_status => l_return_status);

             IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                --Pack J
                -- To calculate the remaining quantity to be reserved
                IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG')= 'Y'
                 AND l_line_rec.ordered_quantity >
                                 l_line_rec.reserved_quantity THEN
                   l_quantity_to_reserve := l_line_rec.ordered_quantity - l_line_rec.reserved_quantity;
                ELSE
                   l_quantity_to_reserve := l_line_rec.ordered_quantity;
                END IF;

                                                                IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'  -- INVCONV
                 AND l_line_rec.ordered_quantity2 >
                                 l_line_rec.reserved_quantity2 THEN
                   l_quantity2_to_reserve := nvl(l_line_rec.ordered_quantity2, 0) - nvl(l_line_rec.reserved_quantity2,0);
                ELSE
                   l_quantity2_to_reserve := l_line_rec.ordered_quantity2;
                END IF;

                IF l_quantity2_to_reserve = 0 -- INVCONV
                  THEN
                  l_quantity2_to_reserve := NULL;
                END IF;

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'QUANTITY TO RESERVE '||l_quantity_to_reserve , 2 ) ;
                                                                        oe_debug_pub.add(  'QUANTITY2 TO RESERVE '||l_quantity2_to_reserve , 2 ) ;
                  oe_debug_pub.add(  'LINE SELECTED FOR RESERVE **** : '|| L_LINE_REC.LINE_ID , 1 ) ;
                END IF;
                --partial reservation exists
                IF nvl(l_line_rec.reserved_quantity,0) > 0 THEN
                   l_rsv_update := TRUE;
                END IF;
                OE_SCHEDULE_UTIL.Reserve_Line
                (p_line_rec              => l_line_rec
                ,p_quantity_to_reserve   => l_quantity_to_reserve --l_line_rec.ordered_quantity
                ,p_quantity2_to_reserve  => l_quantity2_to_reserve --l_line_rec.ordered_quantity2
                ,p_rsv_update            => l_rsv_update
                ,x_return_status         => l_return_status);

                 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RAISING UNEXPECTED ERROR' , 1 ) ;
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'WILL IGNORE THE LINE AND PROCEED' , 1 ) ;
                    END IF;
                    l_return_status := FND_API.G_RET_STS_SUCCESS;
                 END IF;

             END IF;
           ELSE  -- reservation exists

              FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
              OE_MSG_PUB.Add;
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'LINE IS ALREADY RESERVED , DO NOT NEED RESERVATION :' || L_LINE_REC.RESERVED_QUANTITY ) ;
              END IF;

           END IF; -- Reserve.
         ELSE

           l_line_rec.reserved_quantity := 0;
           l_line_rec.reserved_quantity2 := 0; -- INVCONV
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS NON SHIPPABLE ' , 2 ) ;
           END IF;
           -- code fix for 3300528
           --FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
           IF  l_line_rec.ato_line_id IS NOT NULL AND
             NOT ( l_line_rec.ato_line_id = l_line_rec.line_id AND
             l_line_rec.item_type_code IN ( OE_GLOBALS.G_ITEM_OPTION,
             OE_GLOBALS.G_ITEM_STANDARD))
           THEN
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_NO_CONFIG');
           ELSE
             FND_MESSAGE.SET_NAME('ONT','ONT_SCH_NOT_RESERVABLE');
           END IF;
           -- code fix for 3300528
           OE_MSG_PUB.Add;

         END IF;
       ELSE --  Line is not scheduled yet.

         l_line_rec.reserved_quantity := 0;
                                 l_line_rec.reserved_quantity2 := 0; -- INCONV
         l_return_status := FND_API.G_RET_STS_SUCCESS;
         OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                        p_old_line_rec  => l_line_rec,
                                        p_sch_action    => p_sch_action,
                                        x_return_status => l_return_status);

         IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                                                  IF l_debug_level  > 0 THEN
                                                      oe_debug_pub.add(  'LINE SELECTED FOR RESERVE **** : '|| L_LINE_REC.LINE_ID , 1 ) ;
                                                  END IF;
           I := I + 1;
           x_line_tbl(I) := l_line_rec;
           x_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

           IF (x_line_tbl(I).arrival_set_id is not null) THEN
                l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( x_line_tbl(I).arrival_set_id);
                x_line_tbl(I).arrival_set   := l_set_rec.set_name;
           ELSIF (x_line_tbl(I).ship_set_id is not null) THEN
                l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( x_line_tbl(I).ship_set_id);
                x_line_tbl(I).ship_set      := l_set_rec.set_name;
           ELSIF (x_line_tbl(I).ship_model_complete_flag ='Y') THEN
               x_line_tbl(I).ship_set      := x_line_tbl(I).top_model_line_id;
           ELSIF (x_line_tbl(I).ato_line_id is not null)
             AND NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10) THEN
               x_line_tbl(I).ship_set      := x_line_tbl(I).ato_line_id;
           END IF;

           x_line_tbl(I).reserved_quantity := 0;
           x_line_tbl(I).reserved_quantity2 := 0; -- INVCONV

         END IF; -- return status.
       END IF; -- scheduled line.
     END LOOP;

    ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK
    THEN

     -- Load line table with scheduled and unscheduled lines.

     I := 0;
     FOR c1 IN l_line_csr LOOP
/*
       I := I + 1;

       IF I = 1 THEN */ -- 2327783
       IF l_sales_order_id IS NULL THEN
        l_sales_order_id :=OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(p_header_id);
       END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE SELECTED FOR ATP **** : ' || C1.LINE_ID , 1 ) ;
       END IF;
       OE_Line_Util.Query_Row( p_line_id  => c1.line_id
                              ,x_line_rec => l_line_rec);


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
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);
       l_line_rec.schedule_action_code := p_sch_action;


       l_return_status := FND_API.G_RET_STS_SUCCESS;
       OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                      p_old_line_rec  => l_line_rec,
                                      p_sch_action    => p_sch_action,
                                      x_return_status => l_return_status);


       IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           I := I +1; -- 2327783
           x_line_tbl(I) := l_line_rec;
          -- x_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

           IF (x_line_tbl(I).arrival_set_id is not null) THEN
               l_set_rec := OE_ORDER_CACHE.Load_Set
                            ( x_line_tbl(I).arrival_set_id);
               x_line_tbl(I).arrival_set   := l_set_rec.set_name;
           ELSIF (x_line_tbl(I).ship_set_id is not null) THEN
               l_set_rec := OE_ORDER_CACHE.Load_Set
                            ( x_line_tbl(I).ship_set_id);
               x_line_tbl(I).ship_set      := l_set_rec.set_name;
           ELSIF (x_line_tbl(I).ship_model_complete_flag ='Y') THEN
               x_line_tbl(I).ship_set      := x_line_tbl(I).top_model_line_id;
           ELSIF (x_line_tbl(I).ato_line_id is not null)
             AND NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                 AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10) THEN
               x_line_tbl(I).ship_set      := x_line_tbl(I).ato_line_id;
           END IF;

           IF  x_line_tbl(I).schedule_status_code is not null
           AND nvl(x_line_tbl(I).shippable_flag,'N') = 'Y' THEN

              -- INVCONV - MERGED CALLS  FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                        OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => x_line_tbl(I).line_id
                                              ,p_org_id    => x_line_tbl(I).ship_from_org_id
                                              ,x_reserved_quantity =>  x_line_tbl(I).reserved_quantity
                                              ,x_reserved_quantity2 => x_line_tbl(I).reserved_quantity2
                                                                                                                                                                                        );


               /*x_line_tbl(I).reserved_quantity :=
                  OE_LINE_UTIL.Get_Reserved_Quantity
                       (p_header_id   => l_sales_order_id,
                        p_line_id     => x_line_tbl(I).line_id,
                        p_org_id      => x_line_tbl(I).ship_from_org_id);
               x_line_tbl(I).reserved_quantity2 :=    -- INVCONV
                  OE_LINE_UTIL.Get_Reserved_Quantity2
                       (p_header_id   => l_sales_order_id,
                        p_line_id     => x_line_tbl(I).line_id,
                        p_org_id      => x_line_tbl(I).ship_from_org_id); */

           END IF;

           IF  x_line_tbl(I).reserved_quantity IS NULL
           OR  x_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM THEN
               x_line_tbl(I).reserved_quantity := 0;
           END IF;

                                         /* IF  x_line_tbl(I).reserved_quantity2 IS NULL -- INVCONV
           OR  x_line_tbl(I).reserved_quantity2 = FND_API.G_MISS_NUM THEN
               x_line_tbl(I).reserved_quantity2 := 0;
           END IF;      */

       END IF; -- Validation success
     END LOOP;


    ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE THEN

     -- Lines are already scheduled. We no need to explode the included items.

     I := 0;

     FOR c2 IN l_line_inc_csr LOOP


       OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => C2.line_id
         ,p_header_id                   => p_header_id
         ,p_line_id                     => C2.line_id
         ,p_orig_sys_document_ref       => C2.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => C2.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => C2.orig_sys_shipment_ref
         ,p_change_sequence             => C2.change_sequence
         ,p_source_document_id          => C2.source_document_id
         ,p_source_document_line_id     => C2.source_document_line_id
         ,p_order_source_id             => C2.order_source_id
         ,p_source_document_type_id     => C2.source_document_type_id);

       -- If the line belong to set, and action is unschedule,
       -- ignore the line.
       IF nvl(c2.shippable_flag,'N') = 'Y' THEN

        IF (nvl(c2.shipping_interfaced_flag,'N') = 'Y'
          AND oe_schedule_util.Get_Pick_Status(c2.line_id)) THEN  -- 2595661


          FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
          OE_MSG_PUB.Add;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE IS SHIPPING INTERFACED ' || C2.LINE_ID , 1 ) ;
          END IF;

        ELSE

          -- 4382036
          /* OE_Line_Util.Query_Row( p_line_id  => c2.line_id
                                 ,x_line_rec => l_line_rec);
          */

	  OE_Line_Util.Lock_Row(p_line_id => c2.line_id,
	       p_x_line_rec    => l_line_rec,
	       x_return_status => l_return_status);

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
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);

          IF l_sales_order_id is null THEN
             l_sales_order_id :=
                  OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(p_header_id);
          END IF;


          -- INVCONV - MERGED CALLS      FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                        OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );


          /*l_line_rec.reserved_quantity :=
                 OE_LINE_UTIL.Get_Reserved_Quantity
                       (p_header_id   => l_sales_order_id,
                        p_line_id     => l_line_rec.line_id,
                        p_org_id      => l_line_rec.ship_from_org_id); */

          IF  l_line_rec.reserved_quantity IS NULL
          OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
              l_line_rec.reserved_quantity := 0;
          END IF;


                                        /*l_line_rec.reserved_quantity2 :=   -- INVCONV
                  OE_LINE_UTIL.Get_Reserved_Quantity2
                       (p_header_id   => l_sales_order_id,
                        p_line_id     => l_line_rec.line_id,
                        p_org_id      => l_line_rec.ship_from_org_id); */

          /*IF  l_line_rec.reserved_quantity2 IS NULL     -- INVCONV - why was this commented out
          OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
              l_line_rec.reserved_quantity2 := 0;
          END IF; */



          IF l_line_rec.reserved_quantity > 0 THEN

           --   I := I + 1; 2327783
             IF l_sales_order_id is null THEN

              l_sales_order_id :=OE_SCHEDULE_UTIL.
                                Get_mtl_sales_order_id(p_header_id);

             END IF;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'LINE SELECTED FOR UNRES **** : ' || L_LINE_REC.LINE_ID , 1 ) ;
             END IF;


             l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
             l_line_rec.schedule_action_code := p_sch_action;
             l_return_status := FND_API.G_RET_STS_SUCCESS;

             OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                            p_old_line_rec  => l_line_rec,
                                            p_sch_action    => p_sch_action,
                                            x_return_status => l_return_status);


             IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 I := I + 1; --2327783
                 x_line_tbl(I) := l_line_rec;
             END IF;
          END IF; -- reservation qty.
        END IF; -- Shipping interfaced flag.

       ELSE -- not shippable
            l_line_rec.reserved_quantity := 0;
       END IF; --  Line is not shippable line.

     END LOOP;
    ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE
    THEN

     -- Lines are already scheduled. We no need to explode the included items.

     I := 0;

     FOR c2 IN l_line_inc_csr LOOP
       -- If the line belong to set, and action is unschedule,
       -- ignore the line.

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => C2.line_id
         ,p_header_id                   => p_header_id
         ,p_line_id                     => C2.line_id
         ,p_orig_sys_document_ref       => C2.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => C2.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => C2.orig_sys_shipment_ref
         ,p_change_sequence             => C2.change_sequence
         ,p_source_document_id          => C2.source_document_id
         ,p_source_document_line_id     => C2.source_document_line_id
         ,p_order_source_id             => C2.order_source_id
         ,p_source_document_type_id     => C2.source_document_type_id);

       IF   c2.ship_set_id is  null
       AND  c2.arrival_set_id is null
       THEN
/*
          I := I + 1;
          IF I = 1 THEN */ -- 2327783

          IF l_sales_order_id IS NULL THEN
           l_sales_order_id :=OE_SCHEDULE_UTIL.
                               Get_mtl_sales_order_id(p_header_id);
          END IF;


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE SELECTED FOR UNSCH **** : ' || C2.LINE_ID , 1 ) ;
          END IF;

	  -- 4382036
          /* OE_Line_Util.Query_Row( p_line_id  => c2.line_id
                                 ,x_line_rec => l_line_rec);
          */

          OE_Line_Util.Lock_Row(p_line_id => c2.line_id,
		          p_x_line_rec    => l_line_rec,
		          x_return_status => l_return_status);

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
         ,p_change_sequence             => l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);


          l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
          l_line_rec.schedule_action_code := p_sch_action;

          l_return_status := FND_API.G_RET_STS_SUCCESS;
          OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_rec,
                                         p_old_line_rec  => l_line_rec,
                                         p_sch_action    => p_sch_action,
                                         x_return_status => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            I := I + 1; --2327783
            x_line_tbl(I) := l_line_rec;

            IF (x_line_tbl(I).ship_model_complete_flag ='Y') THEN
                x_line_tbl(I).ship_set      := x_line_tbl(I).top_model_line_id;
            ELSIF (x_line_tbl(I).ato_line_id is not null)
              AND NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                  AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10) THEN
                x_line_tbl(I).ship_set      := x_line_tbl(I).ato_line_id;
            END IF;

            IF nvl(x_line_tbl(I).shippable_flag,'N') = 'Y' THEN
               -- INVCONV - MERGED CALLS         FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                         OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => x_line_tbl(I).line_id
                                              ,p_org_id    => x_line_tbl(I).ship_from_org_id
                                              ,x_reserved_quantity =>  x_line_tbl(I).reserved_quantity
                                              ,x_reserved_quantity2 => x_line_tbl(I).reserved_quantity2
                                                                                                                                                                                        );

               /*x_line_tbl(I).reserved_quantity :=
                   OE_LINE_UTIL.Get_Reserved_Quantity
                         (p_header_id   => l_sales_order_id,
                          p_line_id     => x_line_tbl(I).line_id,
                          p_org_id      => x_line_tbl(I).ship_from_org_id);
               x_line_tbl(I).reserved_quantity2 :=   -- INVCONV
                   OE_LINE_UTIL.Get_Reserved_Quantity2
                         (p_header_id   => l_sales_order_id,
                          p_line_id     => x_line_tbl(I).line_id,
                          p_org_id      => x_line_tbl(I).ship_from_org_id);*/

            END IF;

            IF  x_line_tbl(I).reserved_quantity IS NULL
            OR  x_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM THEN
                x_line_tbl(I).reserved_quantity := 0;
            END IF;
            IF  x_line_tbl(I).reserved_quantity2 IS NULL  -- INVCONV
            OR  x_line_tbl(I).reserved_quantity2 = FND_API.G_MISS_NUM THEN
                x_line_tbl(I).reserved_quantity2 := 0;
            END IF;

          END IF; -- Success.
       ELSE -- part of set
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_CANNOT_UNSCH_SET');
         OE_MSG_PUB.Add;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE IS PART OF SET ' , 1 ) ;
         END IF;

       END IF; -- do not unschedule if line is part of set.

     END LOOP;

    END IF; -- Main.


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_GROUP_SCH_UTIL.QUERY_LINES ' || X_LINE_TBL.COUNT , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY LINES ' , 1 ) ;
        END IF;
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN QUERY LINES ' , 1 ) ;
        END IF;
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS ERROR IN QUERY LINES ' , 1 ) ;
        END IF;
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Lines;
/*----------------------------------------------------------------
PROCEDURE Query_Schedule_Lines
Description : This api will be called from schedule_multi_line API when
action requested by user is schedule.
System has to perform little validations before passing record back to the user.
Initially system selects few scheduling related attributes to see whether the
line has to be selected for scheduling or not. If it has to be selected then
checks if it is part of non smc and model is also selected by user. If Model is selected by user we will ignore the line or else we will select the line for
processing. If the line selected is Included item and No SMC, make sure not only
it's modle is selected, also check for its immediate parent. If its immediate
parent is selected then ignore the included item, since included item will be
selected by it's parent.

If a line is part of SMC or ATO or if it is a TOP MODEL, selected whole model for processing. If it is a non smc class or kit, select its included items if any.
----------------------------------------------------------------- */
PROCEDURE Query_Schedule_Lines
( p_selected_tbl IN OE_GLOBALS.Selected_record_Tbl, --R12.MOAC
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_tbl             OE_Order_PUB.Line_Tbl_Type;
l_line_rec             OE_Order_PUB.Line_rec_Type;
l_line_id              NUMBER;
l_arrival_set_id       NUMBER;
l_ship_set_id          NUMBER;
l_top_model_line_id    NUMBER;
l_ato_line_id          NUMBER;
l_smc_flag             VARCHAR2(1);
l_item_type_code       VARCHAR2(30);
l_schedule_status_code VARCHAR2(30);
l_line_category_code   VARCHAR2(30);
l_source_type_code     VARCHAR2(30);
l_link_to_line_id      NUMBER;
l_query                VARCHAR2(1);
l_found                VARCHAR2(1);
J                      NUMBER;
l_header_id            NUMBER;
l_open_flag            VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_change_sequence            VARCHAR2(50);
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_set_line_rec OE_Order_PUB.Line_rec_Type; --4241385
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INTO QUERY SCHEDULE LINES ' , 1 ) ;
  END IF;
  FOR L IN 1..p_selected_tbl.count LOOP --R12.MOAC

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE_ID' || P_SELECTED_TBL(L).ID1 , 2 ) ;
    END IF;

    l_line_id := p_selected_tbl(L).id1;
    -- Query required attributes and check does any action is required
    -- on the line.
    BEGIN

    Select Arrival_set_id, Ship_set_id,top_model_line_id,
           Ship_model_complete_flag, ato_line_id,item_type_code,
           Schedule_status_code,line_category_code,header_id,open_flag,
           source_type_code,link_to_line_id,
           orig_sys_document_ref, orig_sys_line_ref, orig_sys_shipment_ref,
           source_document_type_id, change_sequence, source_document_id,
           source_document_line_id, order_source_id
    Into   l_arrival_set_id, l_ship_set_id, l_top_model_line_id,
           l_smc_flag, l_ato_line_id, l_item_type_code,
           l_schedule_status_code,l_line_category_code,l_header_id,l_open_flag,
           l_source_type_code,l_link_to_line_id,
           l_orig_sys_document_ref, l_orig_sys_line_ref, l_orig_sys_shipment_ref,
           l_source_document_type_id, l_change_sequence, l_source_document_id,
           l_source_document_line_id, l_order_source_id
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    EXCEPTION
     WHEN OTHERS THEN
        Null;
    END;

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
         ,p_order_source_id             => l_order_source_id
         ,p_source_document_type_id     => l_source_document_type_id);

     -- If the line is part of set then avoid selecting them ,
     -- since scheduling is prerequisite for sets.
     -- Also avoid selecting any line if they are part of ato model
     -- or smc and they are scheduled.

       IF ((l_arrival_set_id is not null
           OR l_ship_set_id  is not null
           OR l_ato_line_id  is not null
           OR l_smc_flag = 'Y') AND
           l_schedule_status_code is NOT NULL)
       OR  l_line_category_code = 'RETURN'
       OR  l_item_type_code = 'SERVICE'
       OR  l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
       OR  nvl(l_open_flag,'Y') = 'N'
       THEN
           -- Schedule action is not required for the line.
           -- Populate the message on the stack.

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
           OE_MSG_PUB.Add;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A SCHEDULED LINE' || L_LINE_ID , 2 ) ;
           END IF;

       --4241385
       /* Added the below elsif condition, so that all the lines in a set
       should be scheduled together, if we multi select lines from sales
       order form and do tools->scheduling->schedule*/

       ELSIF  (l_arrival_set_id is not null
           OR l_ship_set_id  is not null)
	   AND l_schedule_status_code IS NULL THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'log schedule set delayed request');
           END IF;


                OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_set_line_rec);

			oe_schedule_util.Log_Set_Request
				( l_set_line_rec,
				 l_set_line_rec,
				 'SCHEDULE',
				 'SCH_INTERNAL',
				 l_return_status );

       --4241385

       ELSE -- line not scheduled, please select the line to schedule.

        l_query := 'Y';

        -- If user slectes the non smc model and option,
        -- then avoid selecting the
        -- option, since model will select the option.

        IF  l_top_model_line_id IS NOT NULL
        AND l_smc_flag = 'N'
        AND l_top_model_line_id <> l_line_id
        THEN

          -- Check if model is selected by user.
          -- If model is selected then ignore the line for query, since
          -- model will query the line.

            FOR K IN 1..p_selected_tbl.count LOOP -- R12.MOAC
                IF l_top_model_line_id = p_selected_tbl(K).id1
                OR (l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
                    l_link_to_line_id = p_selected_tbl(K).id1) THEN
                   IF l_debug_level  > 0 THEN
                      oe_debug_pub.add(  'PARENT LINE IS PART OF TABLE' || P_SELECTED_TBL(K).ID1 , 2 ) ;
                   END IF;
                   l_query := 'N';
                   exit;
                END IF;
            END LOOP;



        ELSIF x_line_tbl.count > 0 THEN
           -- If the line is not a non smc option or class, then
           -- check if the line is present in the table.
           -- Check if the line is already present. If line exists then
           -- ignore the line.

           FOR I IN 1..x_line_tbl.count LOOP
               IF l_line_id = x_line_tbl(I).line_id
                THEN
                   l_query := 'N';
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  '2 LINE IS PART OF TABLE' , 2 ) ;
                   END IF;
                   Exit;
                END IF;
           END LOOP;

        END IF;

        IF l_query = 'Y' THEN

           -- Decided to query the line. See what to pass to query sets.
           IF l_smc_flag = 'Y'
           THEN

                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => l_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

               IF x_line_tbl.count = 0 THEN

                  x_line_tbl := l_line_tbl;

               ELSE
                /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                 ,p_line_tbl     => l_line_tbl); */  -- Bug-2454163

                 J := x_line_tbl.count;
                 FOR I IN 1..l_line_tbl.count LOOP
                   IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                      x_line_tbl(J + I) := l_line_tbl(I);
                    END IF;
                 END LOOP;
               END IF;

           ELSIF (l_ato_line_id is not null AND
               NOT (l_line_id = l_ato_line_id AND
                    l_item_type_code IN(OE_GLOBALS.G_ITEM_STANDARD,
                                      OE_GLOBALS.G_ITEM_OPTION)))
           THEN


                  -- Query ato model.
              OE_Config_Util.Query_ATO_Options
              (p_ato_line_id       => l_ato_line_id,
               x_line_tbl          => l_line_tbl);


               IF x_line_tbl.count = 0 THEN

                 x_line_tbl := l_line_tbl;

               ELSE
                 /*Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                 ,p_line_tbl     => l_line_tbl); */  -- Bug-2454163

                 J := x_line_tbl.count;
                 FOR I IN 1..l_line_tbl.count LOOP
                   IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                      x_line_tbl(J + I) := l_line_tbl(I);
                   END IF;
                 END LOOP;
               END IF;

           ELSIF  l_line_id = l_top_model_line_id THEN

                 -- This is a non smc top model. User might have selected model
                 -- and its options If the model is selected query whole
                 -- model and try to place them in the
                 -- out table if they are not present already.

                 Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => l_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                 IF x_line_tbl.count = 0 THEN
                 -- Added for Bug 2454163
                 J := x_line_tbl.count;
                 FOR I IN 1..l_line_tbl.count LOOP
                    IF l_line_tbl(I).schedule_status_code is NULL THEN
                       J := J + 1;
                       x_line_tbl(J) := l_line_tbl(I);
                    END IF;
                 END LOOP;

                 ELSE
                /*  Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                   ,p_line_tbl   => l_line_tbl);    */ --Bug-2454163
                   J :=  x_line_tbl.count;
                   FOR I IN 1..l_line_tbl.count LOOP
                     IF l_line_tbl(I).schedule_status_code is NULL AND
                        NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                        J := J + 1;
                        x_line_tbl(J) := l_line_tbl(I);
                     END IF;
                   END LOOP;
                 END IF;
           ELSE

              IF l_schedule_status_code IS NULL THEN
                /*
                OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_line_rec);
                */
                --4382036
                OE_LINE_UTIL.Lock_Row(p_line_id       => l_line_id,
                               p_x_line_rec    => l_line_rec,
                               x_return_status => l_return_status);

                l_line_rec.reserved_quantity := 0;
                /*Check_Merge_Line(p_line_rec     => l_line_rec
                                ,p_x_line_tbl   => x_line_tbl); */  --Bug-2454163
                --8731703
                IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                   IF NOT Find_Line(x_line_tbl,l_line_rec.line_id) THEN
                      x_line_tbl(x_line_tbl.count + 1) := l_line_rec;
                   END IF;

                   IF l_item_type_code = 'CLASS'
                   OR l_item_type_code = 'KIT'
                   THEN

                     Oe_Config_Schedule_Pvt.Query_Set_Lines
                     (p_header_id        => l_header_id,
                      p_link_to_line_id  => l_line_id,
                      p_sch_action       => p_sch_action,
                      x_line_tbl         => l_line_tbl,
                      x_return_status    => l_return_status);

                     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        x_line_tbl.delete(x_line_tbl.count);
                     END IF;

                     J :=  x_line_tbl.count;
                     FOR I IN 1..l_line_tbl.count LOOP
                        IF l_line_tbl(I).schedule_status_code is NULL
                         AND NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                           J := J + 1;
                           x_line_tbl(J) := l_line_tbl(I);
                        END IF;
                     END LOOP;
                  END IF; -- Class or Kit.
               END IF; -- 8731703
             END IF; -- Schedule status code.

          END IF; -- group query or single query.

        END IF; -- l_query.

     END IF; -- Ignore and do not ignore.

  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING QUERY_SCHEDULE_LINES' || X_LINE_TBL.COUNT , 1 ) ;
  END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_SCHEDULE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN QUERY_SCHEDULE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    -- Start 2742982 --
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    -- End 2742982 --

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Schedule_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Schedule_Lines;

/*----------------------------------------------------------------
PROCEDURE Query_Unschedule_Lines
Description : This api will be called from schedule_multi_line API when
action requested by user is Unschedule.
System has to perform little validations before passing record back to the user.
Initially system selects few scheduling related attributes to see whether the
line has to be selected for scheduling or not. If it has to be selected then
check if it is part of non smc and model is also selected by user. If Model is selected by user we will ignore the line or else we will select the line for
processing. If the line selected is Included item and No SMC, make sure not only
it's modle is selected, also check for its immediate parent. If its immediate
parent is selected then ignore the included item, since included item will be
selected by it's parent.

If a line is part of SMC or ATO or if it is a TOP MODEL, selected whole model
for processing. If it is a non smc class or kit, select its included items if any.
----------------------------------------------------------------- */
PROCEDURE Query_Unschedule_Lines
( p_selected_tbl IN OE_GLOBALS.Selected_record_Tbl, --R12.MOAC
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_tbl             OE_Order_PUB.Line_Tbl_Type;
l_line_rec             OE_Order_PUB.Line_rec_Type;
l_line_id              NUMBER;
l_arrival_set_id       NUMBER;
l_ship_set_id          NUMBER;
l_top_model_line_id    NUMBER;
l_ato_line_id          NUMBER;
l_smc_flag             VARCHAR2(1);
l_item_type_code       VARCHAR2(30);
l_schedule_status_code VARCHAR2(30);
l_line_category_code   VARCHAR2(30);
l_source_type_code     VARCHAR2(30);
l_link_to_line_id      NUMBER;
l_query                VARCHAR2(1);
l_found                VARCHAR2(1);
J                      NUMBER;
l_header_id            NUMBER;
l_sales_order_id       NUMBER;
l_open_flag            VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_change_sequence            VARCHAR2(50);
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING INTO QUERY UNSCHEDULE LINES ' , 1 ) ;
  END IF;
  FOR L IN 1..p_selected_tbl.count LOOP --R12.MOAC

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE_ID' || p_selected_tbl(L).id1 , 2 ) ;
    END IF;

    --l_line_id := p_line_id_tbl(L);
    l_line_id := p_selected_tbl(L).id1;
    -- Query required attributes and check does any action is required
    -- on the line.
    Select Arrival_set_id, Ship_set_id,top_model_line_id,
           Ship_model_complete_flag, ato_line_id,item_type_code,
           Schedule_status_code,line_category_code,header_id,open_flag,
           source_type_code,link_to_line_id,
           orig_sys_document_ref, orig_sys_line_ref, orig_sys_shipment_ref,
           source_document_type_id, change_sequence, source_document_id,
           source_document_line_id, order_source_id
    Into   l_arrival_set_id, l_ship_set_id, l_top_model_line_id,
           l_smc_flag, l_ato_line_id, l_item_type_code,
           l_schedule_status_code,l_line_category_code,l_header_id,l_open_flag,
           l_source_type_code,l_link_to_line_id,
           l_orig_sys_document_ref, l_orig_sys_line_ref, l_orig_sys_shipment_ref,
           l_source_document_type_id, l_change_sequence, l_source_document_id,
           l_source_document_line_id, l_order_source_id
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
         ,p_order_source_id             => l_order_source_id
         ,p_source_document_type_id     => l_source_document_type_id);


       -- If the line selected is not scheduled. Ignore the line, since
       -- no action is required here.

     IF l_arrival_set_id is not null
     OR l_ship_set_id is not null THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE CANNOT BE UNSCHEDULED IF IT IS PART OF SET' , 1 ) ;
        END IF;
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_CANNOT_UNSCH_SET');
        OE_MSG_PUB.Add;
     ELSIF (l_schedule_status_code IS NULL AND
         (l_smc_flag = 'Y' OR
         l_ato_line_id is not null OR
         l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED OR
         l_item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
         l_item_type_code = OE_GLOBALS.G_ITEM_STANDARD))
     OR  l_line_category_code = 'RETURN'
     OR  l_item_type_code = OE_GLOBALS.G_ITEM_SERVICE
     OR  nvl(l_open_flag,'Y') = 'N'
     THEN
         -- line is part of ATO/SMC Model or an ato item which is
         -- not scheduled. Bipass these lines.
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
         OE_MSG_PUB.Add;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NOT A VALID LINE' || L_LINE_ID , 2 ) ;
         END IF;
     ELSE -- line not scheduled, please select the line to schedule.

        l_query := 'Y';

        -- If user slectes the non smc model and option, then avoid
        -- selecting the option, since model will select the option.

        IF  l_top_model_line_id IS NOT NULL
        AND l_smc_flag = 'N'
        AND l_top_model_line_id <> l_line_id THEN

             -- Check if model is selected by user.
             -- If model is selected then ignore the line for query, since
             -- model will query the line.

            --R12.MOAC
            FOR K IN 1..p_selected_tbl.count LOOP
                IF l_top_model_line_id =p_selected_tbl(K).id1
                OR (l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
                    l_link_to_line_id = p_selected_tbl(K).id1) THEN
                   l_query := 'N';
                   exit;
                END IF;
            END LOOP;

        ELSIF x_line_tbl.count > 0 THEN
           -- if the line is not a non smc option or class, then check if the
           -- line is present in the table.
           -- Check if the line is already present. If line exists then
           -- ignore the line.

           FOR I IN 1..x_line_tbl.count LOOP
               IF l_line_id = x_line_tbl(I).line_id
                THEN
                   l_query := 'N';
                   Exit;
                END IF;
           END LOOP;
        END IF;

        IF l_query = 'Y' THEN

           -- Decided to query the line. See what to pass to query sets.
           IF l_smc_flag = 'Y'
           OR (l_ato_line_id is not null AND
               NOT (l_line_id = l_ato_line_id AND
                    l_item_type_code IN(OE_GLOBALS.G_ITEM_STANDARD,
                                      OE_GLOBALS.G_ITEM_OPTION)))
           THEN

               --  query using top_model_line_id / ato line id


               IF l_smc_flag = 'Y' THEN
                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => l_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               ELSE

                  -- Query ato model.
                  OE_Config_Util.Query_ATO_Options
                    ( p_ato_line_id       => l_ato_line_id,
                      x_line_tbl          => l_line_tbl);

               END IF;

               IF x_line_tbl.count = 0 THEN

                  x_line_tbl := l_line_tbl;

               ELSE
                 /* Check_Merge_Line(p_x_line_tbl => x_line_tbl
                                 ,p_line_tbl   => l_line_tbl); */ --Bug-2454163

                 J := x_line_tbl.count;
                 FOR I IN 1..l_line_tbl.count LOOP
                    IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                        J := J +1;
                        x_line_tbl(J) := l_line_tbl(I);
                    END IF;
                 END LOOP;
               END IF;

           ELSIF  l_line_id = l_top_model_line_id THEN

                 -- This is a non smc top model. User might have selected model
                 -- and its options If the model is selected query
                 -- whole model and try to place them in the
                 -- out table if they are not present already.

                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => l_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                 IF x_line_tbl.count = 0 THEN
                  J := x_line_tbl.count;
                  FOR I IN 1..l_line_tbl.count LOOP
                    IF l_line_tbl(I).schedule_status_code is NOT NULL THEN
                        J := J + 1;
                        x_line_tbl(J) := l_line_tbl(I);
                    END IF;
                  END LOOP;

                 ELSE

                  /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                 ,p_line_tbl   => l_line_tbl);  */


                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                       IF  l_line_tbl(I).schedule_status_code is NOT NULL
                       AND NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                          J := J + 1;
                          x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;

                 END IF;
           ELSE
                -- 4382036
                OE_Line_Util.Lock_Row(p_line_id => l_line_id,
                               p_x_line_rec    => l_line_rec,
                               x_return_status => l_return_status);

                /* OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_line_rec);
                */

                IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

                    IF l_sales_order_id is null THEN
                       l_sales_order_id :=
                          OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                     (l_line_rec.header_id);
                    END IF;


                     -- INVCONV - MERGED CALLS   FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                                                OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );


                    /*l_line_rec.reserved_quantity :=
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id  => l_sales_order_id,
                               p_line_id    => l_line_rec.line_id,
                               p_org_id     => l_line_rec.ship_from_org_id);
                                                                                l_line_rec.reserved_quantity2 :=   -- INVCONV
                              OE_LINE_UTIL.Get_Reserved_Quantity2
                              (p_header_id  => l_sales_order_id,
                               p_line_id    => l_line_rec.line_id,
                               p_org_id     => l_line_rec.ship_from_org_id); */


                END IF;
                IF  l_line_rec.reserved_quantity IS NULL
                OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity := 0;
                END IF;
                                                                IF  l_line_rec.reserved_quantity2 IS NULL  -- INVCONV
                OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity2 := 0;
                END IF;



                /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                ,p_line_rec     => l_line_rec); */  -- Bug-2454163

                  IF NOT Find_Line(x_line_tbl,l_line_rec.line_id) THEN
                     x_line_tbl(x_line_tbl.count + 1) := l_line_rec;
                  END IF;

                IF l_item_type_code = 'CLASS'
                OR l_item_type_code = 'KIT'
                THEN

                    Oe_Config_Schedule_Pvt.Query_Set_Lines
                    (p_header_id        => l_header_id,
                     p_link_to_line_id  => l_line_id,
                     p_sch_action       => p_sch_action,
                     x_line_tbl         => l_line_tbl,
                     x_return_status    => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     x_line_tbl.delete(x_line_tbl.count);
                  END IF;


                    /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                     ,p_line_tbl   => l_line_tbl); */   --Bug-2454163

                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                      IF  l_line_tbl(I).schedule_status_code is NOT NULL
                      AND NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                         J := J + 1;
                         x_line_tbl(J) := l_line_tbl(I);
                      END IF;
                    END LOOP;

                END IF; -- Class or Kit.
           END IF; -- group query or single query.

         END IF; -- l_query.

       END IF; -- Ignore and do not ignore.


  END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_UNSCHEDULE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN QUERY_UNSCHEDULE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    -- Start 2742982 --
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    -- End 2742982 --

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' WHEN OTHERS ERROR IN QUERY_UNSCHEDULE_LINES ' , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Unschedule_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Unschedule_Lines;

/*----------------------------------------------------------------
PROCEDURE Query_Unreserve_Lines
Description : This api will be called from schedule_multi_line API when
action requested by user is Unreserve.
System has to perform little validations before passing record back to the user.
Initially system selects few scheduling related attributes to see whether the
line has to be selected for Unreserve or not. If it has to be selected then
check if it is part of model and parent is also selected by user. If Model is selected by user we will ignore the line or else we will select the line for
processing. If the line selected is Included item,  make sure not only it's modle is selected, also check for its immediate parent. If its immediate parent is selected then ignore the included item, since included item will be selected by it's parent.

If line is a top model selected all its children that are scheduled and it is a class or kit select its included items as well or else select by itself.

----------------------------------------------------------------- */
PROCEDURE Query_Unreserve_Lines
( p_selected_tbl IN OE_GLOBALS.Selected_record_Tbl, --R12.MOAC
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_tbl                        OE_Order_PUB.Line_Tbl_Type;
l_line_rec                        OE_Order_PUB.Line_rec_Type;
l_line_id                         NUMBER;
l_arrival_set_id                  NUMBER;
l_ship_set_id                     NUMBER;
l_top_model_line_id               NUMBER;
l_ato_line_id                     NUMBER;
l_smc_flag                        VARCHAR2(1);
l_shipping_interfaced_flag        VARCHAR2(1);
l_item_type_code                  VARCHAR2(30);
l_schedule_status_code            VARCHAR2(30);
l_line_category_code              VARCHAR2(30);
l_source_type_code                VARCHAR2(30);
l_link_to_line_id                 NUMBER;
l_query                           VARCHAR2(1);
l_found                           VARCHAR2(1);
J                                 NUMBER;
l_header_id                       NUMBER;
l_sales_order_id                  NUMBER;
l_open_flag                       VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_change_sequence            VARCHAR2(50);
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    FOR L IN 1..p_selected_tbl.count LOOP --R12.MOAC


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE_ID' || P_SELECTED_TBL(L).ID1 , 2 ) ;
    END IF;

    l_line_id := p_selected_tbl(L).id1;
    -- Query required attributes and check does any action is required
    -- on the line.
    Select Arrival_set_id, Ship_set_id,top_model_line_id,
           Ship_model_complete_flag, ato_line_id,item_type_code,
           Schedule_status_code,line_category_code,header_id,open_flag,
           nvl(shipping_interfaced_flag,'N'),source_type_code,link_to_line_id,
           orig_sys_document_ref, orig_sys_line_ref, orig_sys_shipment_ref,
           source_document_type_id, change_sequence, source_document_id,
           source_document_line_id, order_source_id
    Into   l_arrival_set_id, l_ship_set_id, l_top_model_line_id,
           l_smc_flag, l_ato_line_id, l_item_type_code,
           l_schedule_status_code,l_line_category_code,l_header_id,l_open_flag,
           l_shipping_interfaced_flag,l_source_type_code,l_link_to_line_id,
           l_orig_sys_document_ref, l_orig_sys_line_ref, l_orig_sys_shipment_ref,
           l_source_document_type_id, l_change_sequence, l_source_document_id,
           l_source_document_line_id, l_order_source_id
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
         ,p_order_source_id             => l_order_source_id
         ,p_source_document_type_id     => l_source_document_type_id);

       -- If the line selected is not scheduled. Ignore the line, since
       -- no action is required here.

     IF l_schedule_status_code IS NULL
     OR nvl(l_open_flag,'Y') = 'N'
     OR (l_shipping_interfaced_flag = 'Y'
     AND oe_schedule_util.Get_Pick_Status(l_line_id))
     THEN  -- 2595661
          -- Go inside only if they are scheduled.
          -- and not part of set.
         IF l_shipping_interfaced_flag = 'Y' THEN

           FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
           OE_MSG_PUB.Add;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS SHIPPING INTERFACED' || L_LINE_ID , 1 ) ;
           END IF;

         END IF;
     ELSE -- line not scheduled, please select the line to schedule.

        l_query := 'Y';

        -- If user slectes the model and option, then avoid selecting the
        -- option, since model will select the option.

        IF  l_top_model_line_id IS NOT NULL
        AND l_top_model_line_id <> l_line_id THEN

             -- Check if model is selected by user.
             -- If model is selected then ignore the line for query, since
             -- model will query the line.

            --R12.MOAC
            FOR K IN 1..p_selected_tbl.count LOOP
                IF l_top_model_line_id = p_selected_tbl(K).id1
                OR (l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
                    l_link_to_line_id = p_selected_tbl(K).id1) THEN
                   l_query := 'N';
                   exit;
                END IF;
            END LOOP;
        END IF;

        IF l_query = 'Y' THEN

           -- Decided to query the line. See what to pass to query sets.
           IF  l_line_id = l_top_model_line_id THEN

                 -- This is a non smc top model. User might have selected model
                 -- and its options. If the model is selected query
                 -- whole model and try to place them in the
                 -- out table if they are not present already.

                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => l_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;


                 IF x_line_tbl.count = 0 THEN
                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                       IF l_line_tbl(I).schedule_status_code is NOT NULL THEN
                          J := J + 1;
                          x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;
                 ELSE
                   /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                   ,p_line_tbl   => l_line_tbl);   */ --Bug-2454163

                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                       IF l_line_tbl(I).schedule_status_code is NOT NULL
                       AND NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                          J := J + 1;
                          x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;

                 END IF;
           ELSE

                -- 4382036
                OE_Line_Util.Lock_Row(p_line_id => l_line_id,
                               p_x_line_rec    => l_line_rec,
                               x_return_status => l_return_status);

                /* OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_line_rec);
                 */

                IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

                    IF l_sales_order_id is null THEN
                       l_sales_order_id :=
                                OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                                (l_line_rec.header_id);
                    END IF;

                      -- INVCONV - MERGED CALLS  FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                                                OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );

                    /*l_line_rec.reserved_quantity :=
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);
                    l_line_rec.reserved_quantity2 :=  -- INVCONV
                              OE_LINE_UTIL.Get_Reserved_Quantity2
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);       */
                END IF;

                IF  l_line_rec.reserved_quantity IS NULL
                OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity := 0;
                END IF;
                                                                /*IF  l_line_rec.reserved_quantity2 IS NULL   -- INVCONV
                OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity2 := 0;
                END IF; */


                /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                  ,p_line_rec   => l_line_rec);  */ --Bug-2454163

                IF NOT Find_Line(x_line_tbl,l_line_rec.line_id) THEN
                   x_line_tbl(x_line_tbl.count + 1) := l_line_rec;
                END IF;

                IF l_item_type_code = 'CLASS'
                OR l_item_type_code = 'KIT'
                THEN

                    Oe_Config_Schedule_Pvt.Query_Set_Lines
                    (p_header_id        => l_header_id,
                     p_link_to_line_id  => l_line_id,
                     p_sch_action       => p_sch_action,
                     x_line_tbl         => l_line_tbl,
                     x_return_status    => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     x_line_tbl.delete(x_line_tbl.count);
                  END IF;

                    /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                      ,p_line_tbl   => l_line_tbl);  */  --Bug-2454163


                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                       IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id)
                       AND l_line_tbl(I).schedule_status_code IS NOT NULL THEN
                          J := J + 1;
                          x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;
                END IF; -- Class or Kit.
           END IF; -- group query or single query.

         END IF; -- l_query.

       END IF; -- Ignore and do not ignore.


  END LOOP;



EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_UNRESERVE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_UNRESERVE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    -- Start 2742982 --
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    -- End 2742982 --

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' WHEN OTHERS ERROR IN QUERY_UNRESERVE_LINES ' , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Unreserve_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Unreserve_Lines;

/*----------------------------------------------------------------
PROCEDURE Query_Reserve_Lines
Description : This api will be called from schedule_multi_line API when
action requested by user is reserve.
System has to perform little validations before passing record back to the user.
Initially system selects few scheduling related attributes to see whether the
line has to be selected for reserve or not. If it has to be selected then
check if it is part of model and parent is also selected by user. If Model is selected by user we will ignore the line or else we will select the line for
processing. If the line selected is Included item,  make sure not only it's
modle is selected, also check for its immediate parent. If its immediate parent
is selected then ignore the included item, since included item will be selected
by it's parent.

If top model is selected for processing then query whole model. If a line
selected is part of smc or ATO model and if it is not scheduled, then select
whole model or else select only the line for reservation. If class or kit is
selected then select its included items as well.

------------------------------------------------------------------*/
PROCEDURE Query_Reserve_Lines
( p_selected_tbl IN OE_GLOBALS.Selected_record_Tbl, --R12.MOAC
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_tbl             OE_Order_PUB.Line_Tbl_Type;
l_line_rec             OE_Order_PUB.Line_rec_Type;
l_line_id              NUMBER;
l_arrival_set_id       NUMBER;
l_ship_set_id          NUMBER;
l_top_model_line_id    NUMBER;
l_ato_line_id          NUMBER;
l_smc_flag             VARCHAR2(1);
l_item_type_code       VARCHAR2(30);
l_schedule_status_code VARCHAR2(30);
l_line_category_code   VARCHAR2(30);
l_link_to_line_id      NUMBER;
l_source_type_code     VARCHAR2(30);
l_query                VARCHAR2(1);
l_found                VARCHAR2(1);
J                      NUMBER;
l_header_id            NUMBER;
l_config_id            NUMBER;
l_sales_order_id       NUMBER := Null;
l_return_status        VARCHAR2(30) :=  FND_API.G_RET_STS_SUCCESS;
l_open_flag            VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_change_sequence            VARCHAR2(50);
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
l_quantity_to_reserve        NUMBER;
l_quantity2_to_reserve        NUMBER; -- INVCONV
l_rsv_update                 BOOLEAN :=FALSE;
l_set_line_rec OE_Order_PUB.Line_rec_Type; --4241385
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING QUERY RESERVE LINES' , 1 ) ;
  END IF;
  FOR L IN 1..p_selected_tbl.count LOOP --R12.MOAC

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE_ID' || P_SELECTED_TBL(L).ID1 , 2 ) ;
    END IF;

    l_line_id := p_selected_tbl(L).id1;
    -- Query required attributes and check does any action is required
    -- on the line.
    Select Arrival_set_id, Ship_set_id,top_model_line_id,
           Ship_model_complete_flag, ato_line_id,item_type_code,
           Schedule_status_code,line_category_code,header_id,open_flag,
           source_type_code,link_to_line_id,
           orig_sys_document_ref, orig_sys_line_ref, orig_sys_shipment_ref,
           source_document_type_id, change_sequence, source_document_id,
           source_document_line_id, order_source_id
    Into   l_arrival_set_id, l_ship_set_id, l_top_model_line_id,
           l_smc_flag, l_ato_line_id, l_item_type_code,
           l_schedule_status_code,l_line_category_code,l_header_id,l_open_flag,
           l_source_type_code,l_link_to_line_id,
           l_orig_sys_document_ref, l_orig_sys_line_ref, l_orig_sys_shipment_ref,
           l_source_document_type_id, l_change_sequence, l_source_document_id,
           l_source_document_line_id, l_order_source_id
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
         ,p_order_source_id             => l_order_source_id
         ,p_source_document_type_id     => l_source_document_type_id);


    IF l_line_category_code = 'RETURN'
    OR l_item_type_code = 'SERVICE'
    OR l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
    OR nvl(l_open_flag,'Y') = 'N' THEN

       -- populate the error message and skip the line.
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NOT A VALIDE LINE' || L_LINE_ID , 2 ) ;
       END IF;

     --4241385
     /* Added the below elsif condition, so that all the lines in a set
     should be scheduled/reserved together, if we multi select lines from
     sales order form and do tools->scheduling->reserve*/

    ELSIF  (l_arrival_set_id is not null
           OR l_ship_set_id  is not null)
	   AND l_schedule_status_code IS NULL THEN
	  -- AND l_auto_schedule_sets='N') THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'log schedule set delayed request');
           END IF;


                OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_set_line_rec);

			oe_schedule_util.Log_Set_Request
				( l_set_line_rec,
				 l_set_line_rec,
				 'SCHEDULE',
				 'SCH_INTERNAL',
				 l_return_status );
    --4241385
    ELSE
        l_query := 'Y';

        --If user slectes the non smc model and option, then avoid selecting the
        --option, since model will select the option.

        IF  l_top_model_line_id IS NOT NULL
        AND l_smc_flag = 'N'
        AND l_top_model_line_id <> l_line_id THEN

             -- Check if model is selected by user.
             -- If model is selected then ignore the line for query, since
             -- model will query the line.
           --R12.MOAC
            FOR K IN 1..p_selected_tbl.count LOOP
                IF l_top_model_line_id = p_selected_tbl(K).id1
                OR (l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
                    l_link_to_line_id = p_selected_tbl(K).id1) THEN
                   l_query := 'N';
                   exit;
                END IF;
            END LOOP;

        ELSIF l_line_tbl.count > 0 THEN
           -- if the line is not a non smc option or class, then check if the
           -- line is present in the table.
           -- Check if the line is already present. If line exists then
           -- ignore the line.

           FOR I IN 1..l_line_tbl.count LOOP
               IF l_line_id = l_line_tbl(I).line_id
                THEN
                   l_query := 'N';
                   Exit;
                END IF;
           END LOOP;
        END IF;

        IF l_query = 'Y' THEN

           -- Decided to query the line. See what to pass to query sets.
           -- If line is part of smc or ATO if it is not scheduled , then select
           -- whole model or else select only that line to reserve.

           IF (l_smc_flag = 'Y'
              AND l_schedule_status_code is null)
           OR (l_line_id = l_top_model_line_id
               AND l_ato_line_id is null) THEN

                 -- This is a non smc top model. User might have selected model
                 -- and its options.If the model is selected query whole
                 -- model and try to place them in the
                 -- out table if they are not present already.

                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id     => l_header_id,
                   p_model_line_id => l_top_model_line_id,
                   p_sch_action    => p_sch_action,
                   x_line_tbl      => x_line_tbl,
                   x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                   /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                      ,p_line_tbl   => l_line_tbl);  */  -- Bug-2454163

                 IF l_line_tbl.count = 0 THEN
                     l_line_tbl := x_line_tbl;
                 ELSE

                    J :=  l_line_tbl.count;
                    FOR I IN 1..x_line_tbl.count LOOP
                        IF NOT Find_Line(l_line_tbl,x_line_tbl(I).line_id) THEN
                           J := J + 1;
                           l_line_tbl(J) := x_line_tbl(I);
                        END IF;
                    END LOOP;

                 END IF;


           ELSIF (l_ato_line_id is not null AND
               NOT (l_line_id = l_ato_line_id AND
                    l_item_type_code IN(OE_GLOBALS.G_ITEM_STANDARD,
                                      OE_GLOBALS.G_ITEM_OPTION)))
           AND l_schedule_status_code is null
           THEN

                  -- Query ato model.
                  OE_Config_Util.Query_ATO_Options
                  (p_ato_line_id       => l_ato_line_id,
                   x_line_tbl          => x_line_tbl);

                 IF l_line_tbl.count = 0 THEN
                     l_line_tbl := x_line_tbl;
                 ELSE

                     /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                        ,p_line_tbl   => l_line_tbl); */


                    J :=  l_line_tbl.count;
                    FOR I IN 1..x_line_tbl.count LOOP
                        IF NOT Find_Line(l_line_tbl,x_line_tbl(I).line_id) THEN
                           J := J + 1;
                           l_line_tbl(J) := x_line_tbl(I);
                        END IF;
                    END LOOP;


                 END IF;

           -- 2746802
           ELSIF l_ato_line_id = l_line_id
           AND   l_item_type_code = OE_GLOBALS.G_ITEM_MODEL
           AND   l_schedule_status_code is not null THEN

                 l_config_id := Null;

                 BEGIN

                  SELECT line_id
                  INTO   l_config_id
                  FROM   oe_order_lines_all
                  WHERE  header_id = l_header_id
                  AND    ato_line_id = l_ato_line_id
                  AND    item_type_code = 'CONFIG';

                 EXCEPTION
                    When Others Then

                      l_config_id := Null;
                 END;

                 IF l_config_id IS NOT NULL THEN

                    IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'NEED TO RESERVE THE LINE' , 2 ) ;
                    END IF;

                   OE_Line_Util.Query_Row
                   (p_line_id    => l_config_id,
                    x_line_rec   => l_line_rec);

                   IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

                       IF l_sales_order_id is null THEN
                          l_sales_order_id :=
                              OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                               (l_line_rec.header_id);
                       END IF;

                         -- INVCONV - MERGED CALLS       FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                                                                OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );

                       /*l_line_rec.reserved_quantity :=
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);
                                                                                         l_line_rec.reserved_quantity2 :=   -- INVCONV
                              OE_LINE_UTIL.Get_Reserved_Quantity2
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id); */


                   END IF;
                   IF  l_line_rec.reserved_quantity IS NULL
                   OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
                   THEN
                       l_line_rec.reserved_quantity := 0;
                   END IF;
                   /*IF  l_line_rec.reserved_quantity2 IS NULL  -- INVCONV
                   OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM
                   THEN
                       l_line_rec.reserved_quantity2 := 0;
                   END IF; */



                   IF NOT Find_Line(l_line_tbl,l_line_rec.line_id) THEN
                        l_line_tbl(l_line_tbl.count + 1) := l_line_rec;
                   END IF;

                 END IF;
           ELSE

                -- 4382036
                OE_Line_Util.Lock_Row(p_line_id => l_line_id,
                               p_x_line_rec    => l_line_rec,
                               x_return_status => l_return_status);

                /* OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_line_rec);
                 */

                IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

                    IF l_sales_order_id is null THEN
                       l_sales_order_id :=
                           OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                            (l_line_rec.header_id);
                    END IF;

                      -- INVCONV - MERGED CALLS  FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                                                OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );

                   /* l_line_rec.reserved_quantity :=
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);
                                                                                l_line_rec.reserved_quantity2 :=
                              OE_LINE_UTIL.Get_Reserved_Quantity2
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id); */

                END IF;
                IF  l_line_rec.reserved_quantity IS NULL
                OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity := 0;
                END IF;
                 /* IF  l_line_rec.reserved_quantity2 IS NULL -- INVCONV
                OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity2 := 0;
                END IF; */


                /* Check_Merge_Line(p_x_line_tbl  => x_line_tbl
                               , p_line_rec  => l_line_rec );  */  -- Bug-2454163

                IF NOT Find_Line(l_line_tbl,l_line_rec.line_id) THEN
                     l_line_tbl(l_line_tbl.count + 1) := l_line_rec;
                END IF;

                IF l_item_type_code = 'CLASS'
                OR l_item_type_code = 'KIT'
                THEN

                    Oe_Config_Schedule_Pvt.Query_Set_Lines
                    (p_header_id        => l_header_id,
                     p_link_to_line_id  => l_line_id,
                     p_sch_action       => p_sch_action,
                     x_line_tbl         => x_line_tbl,
                     x_return_status    => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     l_line_tbl.delete(l_line_tbl.count);
                  END IF;


                     /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                     ,p_line_tbl   => l_line_tbl); */  --Bug-2454163

                    J :=  l_line_tbl.count;
                    FOR I IN 1..x_line_tbl.count LOOP
                        IF NOT Find_Line(l_line_tbl,x_line_tbl(I).line_id) THEN
                           J := J + 1;
                           l_line_tbl(J) := x_line_tbl(I);
                        END IF;
                    END LOOP;


                END IF; -- Class or Kit.

           END IF; -- group query or single query.

         END IF; -- l_query.


    END IF; -- do or do not.

  END LOOP;

  /* Bug 2319608
  FOR k IN 1..x_line_tbl.COUNT LOOP
    l_line_tbl(k) := x_line_tbl(k);
  END LOOP;
*/
  x_line_tbl.delete;
  J := 0;
  FOR I IN 1..l_line_tbl.count LOOP

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_tbl(I).line_id
         ,p_header_id                   => l_line_tbl(I).header_id
         ,p_line_id                     => l_line_tbl(I).line_id
         ,p_orig_sys_document_ref       => l_line_tbl(I).orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_line_tbl(I).orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_line_tbl(I).orig_sys_shipment_ref
         ,p_change_sequence             => l_line_tbl(I).change_sequence
         ,p_source_document_id          => l_line_tbl(I).source_document_id
         ,p_source_document_line_id     => l_line_tbl(I).source_document_line_id
         ,p_order_source_id             => l_line_tbl(I).order_source_id
         ,p_source_document_type_id     => l_line_tbl(I).source_document_type_id);


   IF l_line_tbl(I).schedule_status_code is not null THEN

     -- Pack J
     -- Check for Partial reservation flag when the line is partially reserved
     IF  nvl(l_line_tbl(I).shippable_flag,'N') = 'Y'
     AND ((l_line_tbl(I).reserved_quantity = 0)
      OR ( OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
         --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG')= 'Y'
        AND l_line_tbl(I).ordered_quantity >
                                 l_line_tbl(I).reserved_quantity)) THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NEED TO RESERVE THE LINE' , 2 ) ;
       END IF;

        -- Check if the line is eligible for reservation.
        l_return_status := FND_API.G_RET_STS_SUCCESS;
        OE_SCHEDULE_UTIL.Validate_Line(p_line_rec      => l_line_tbl(I),
                                       p_old_line_rec  => l_line_tbl(I),
                                       p_sch_action    => p_sch_action,
                                       x_return_status => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           --Pack J
           -- To calculate the remaining quantity to be reserved
           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
             --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG')= 'Y'
             AND l_line_tbl(I).ordered_quantity >
                                 l_line_tbl(I).reserved_quantity THEN
             l_quantity_to_reserve := l_line_tbl(I).ordered_quantity - l_line_tbl(I).reserved_quantity;
           ELSE
             l_quantity_to_reserve := l_line_tbl(I).ordered_quantity;
           END IF;

           IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'  -- INVCONV
             --AND OE_SYS_PARAMETERS.value('PARTIAL_RESERVATION_FLAG')= 'Y'
             AND l_line_tbl(I).ordered_quantity2 >
                                 l_line_tbl(I).reserved_quantity2 THEN
             l_quantity2_to_reserve := l_line_tbl(I).ordered_quantity2 - l_line_tbl(I).reserved_quantity2;
           ELSE
             l_quantity2_to_reserve := l_line_tbl(I).ordered_quantity2;
           END IF;

           IF l_quantity2_to_reserve = 0 -- INVCONV
            THEN
              l_quantity2_to_reserve := NULL;
           END IF;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'QUANTITY TO RESERVE '||l_quantity_to_reserve , 2 ) ;
                                                        oe_debug_pub.add(  'QUANTITY2 TO RESERVE '||l_quantity2_to_reserve , 2 ) ;
           END IF;
           IF nvl(l_line_tbl(I).reserved_quantity,0) > 0 THEN
             l_rsv_update := TRUE;
           END IF;

           OE_SCHEDULE_UTIL.Reserve_Line
           (p_line_rec              => l_line_tbl(I)
           ,p_quantity_to_reserve   => l_quantity_to_reserve --l_line_tbl(I).ordered_quantity
           ,p_quantity2_to_reserve   => l_quantity2_to_reserve --l_line_tbl(I).ordered_quantity2 -- INVCONV
           ,p_rsv_update            => l_rsv_update
           ,x_return_status         => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'RAISING UNEXPECTED ERROR' , 1 ) ;
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'WILL IGNORE THE LINE AND PROCEED' , 1 ) ;
              END IF;
              l_return_status := FND_API.G_RET_STS_SUCCESS;
           END IF;

      END IF; -- Return status
     ELSE
       -- code fix for 3300528
       IF  nvl(l_line_tbl(I).shippable_flag,'N') = 'N'
       THEN
         IF  l_line_tbl(I).ato_line_id IS NOT NULL AND
           NOT ( l_line_tbl(I).ato_line_id = l_line_tbl(I).line_id AND
           l_line_tbl(I).item_type_code IN ( OE_GLOBALS.G_ITEM_OPTION,
           OE_GLOBALS.G_ITEM_STANDARD))
         THEN -- check for ato
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_NO_CONFIG');
           IF  l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NON SHIPPABLE  ATO LINE' , 2 ) ;
           END IF;
         ELSE
           FND_MESSAGE.SET_NAME('ONT','ONT_SCH_NOT_RESERVABLE');
         END IF;-- end check for ato
       ELSE
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
         IF  l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ALREADY RESERVED' , 2 ) ;
         END IF;
       END IF; -- shippable flag
       OE_MSG_PUB.Add;
       -- code fix for 3300528
     END IF; -- shippable flag and reserved quantity
   ELSE

     J := J +1;
     x_line_tbl(J) := l_line_tbl(I);

   END IF;
  END LOOP;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING QUERY RESERVE LINES' , 1 ) ;
  END IF;


EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_RESERVE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN QUERY_RESERVE_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    -- Start 2742982 --
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    -- End 2742982 --

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS ERROR IN QUERY_RESERVE_LINES ' , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Group_Line'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Reserve_Lines;

/*----------------------------------------------------------------
PROCEDURE Query_ATP_CHECK_Lines
Description : This api will be called from schedule_multi_line API when
action requested by user is reserve.
System has to perform little validations before passing record back to the user.
Initially system selects few scheduling related attributes to see whether the
line has to be selected for atp_check or not. If it has to be selected then
check if it is part of model and parent is also selected by user. If Model is selected by user we will ignore the line or else we will select the line for
processing. If the line selected is Included item,  make sure not only it's modle is selected, also check for its immediate parent. If its immediate parent is selected then ignore the included item, since included item will be selected by it's parent.

If top model is selected for processing or line part of smc or ato then query whole model. If class or kit is selected then select its included items as well.If line is selected which is part of set then select whole set for processing

------------------------------------------------------------------*/
PROCEDURE Query_ATP_CHECK_Lines
( p_selected_tbl IN OE_GLOBALS.Selected_record_Tbl, --R12.MOAC
  p_sch_action  IN VARCHAR2,
  x_line_tbl    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_tbl             OE_Order_PUB.Line_Tbl_Type;
l_line_rec             OE_Order_PUB.Line_rec_Type;
l_line_id              NUMBER;
l_arrival_set_id       NUMBER;
l_ship_set_id          NUMBER;
l_top_model_line_id    NUMBER;
l_ato_line_id          NUMBER;
l_smc_flag             VARCHAR2(1);
l_item_type_code       VARCHAR2(30);
l_schedule_status_code VARCHAR2(30);
l_line_category_code   VARCHAR2(30);
l_source_type_code     VARCHAR2(30);
l_link_to_line_id      NUMBER;
l_query                VARCHAR2(1);
l_found                VARCHAR2(1);
J                      NUMBER;
l_header_id            NUMBER;
l_sales_order_id       NUMBER := Null;
l_open_flag            VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_change_sequence            VARCHAR2(50);
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
l_return_status              VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN


  FOR L IN 1..p_selected_tbl.count LOOP --R12.MOAC
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESSING LINE_ID ' || P_SELECTED_TBL(L).ID1 , 2 ) ;
    END IF;

    l_line_id := p_selected_tbl(L).id1;
    -- Query required attributes and check does any action is required
    -- on the line.
    Select Arrival_set_id, Ship_set_id,top_model_line_id,
           Ship_model_complete_flag, ato_line_id,item_type_code,
           Schedule_status_code,line_category_code,header_id,open_flag,
           source_type_code,link_to_line_id,
           orig_sys_document_ref, orig_sys_line_ref, orig_sys_shipment_ref,
           source_document_type_id, change_sequence, source_document_id,
           source_document_line_id, order_source_id
    Into   l_arrival_set_id, l_ship_set_id, l_top_model_line_id,
           l_smc_flag, l_ato_line_id, l_item_type_code,
           l_schedule_status_code,l_line_category_code,l_header_id,l_open_flag,
           l_source_type_code,l_link_to_line_id,
           l_orig_sys_document_ref, l_orig_sys_line_ref, l_orig_sys_shipment_ref,
           l_source_document_type_id, l_change_sequence, l_source_document_id,
           l_source_document_line_id, l_order_source_id
    From   oe_order_lines_all
    Where  line_id = l_line_id;

    OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_id
         ,p_header_id                   => l_header_id
         ,p_line_id                     => l_line_id
         ,p_orig_sys_document_ref       => l_orig_sys_document_ref
         ,p_orig_sys_document_line_ref  => l_orig_sys_line_ref
         ,p_orig_sys_shipment_ref       => l_orig_sys_shipment_ref
         ,p_change_sequence             => l_change_sequence
         ,p_source_document_id          => l_source_document_id
         ,p_source_document_line_id     => l_source_document_line_id
         ,p_order_source_id             => l_order_source_id
         ,p_source_document_type_id     => l_source_document_type_id);

    IF l_line_category_code = 'RETURN'
    OR l_item_type_code = 'SERVICE'
    OR l_source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL
    OR nvl(l_open_flag,'Y') = 'N' THEN

       -- populate the error message and skip the line.
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
    ELSE


       -- If the line is part of set then avoid selecting them ,
       -- since scheduling is prerequisite for sets.
       -- Also avoid selecting any line if they are part of ato model or
       -- smc and they are scheduled.


        l_query := 'Y';

        -- If user slectes the non smc model and option,
        -- then avoid selecting the
        -- option, since model will select the option.

        IF  l_top_model_line_id IS NOT NULL
        AND l_smc_flag = 'N'
        AND l_top_model_line_id <> l_line_id THEN

             -- Check if model is selected by user.
             -- If model is selected then ignore the line for query, since
             -- model will query the line.
            --R12.MOAC
            FOR K IN 1..p_selected_tbl.count LOOP
                IF l_top_model_line_id = p_selected_tbl(K).id1
                OR (l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND
                    l_link_to_line_id = p_selected_tbl(K).id1) THEN
                   l_query := 'N';
                   exit;
                END IF;
            END LOOP;

        ELSIF x_line_tbl.count > 0 THEN
           -- If the line is not a non smc option or class, then check if the
           -- line is present in the table.
           -- Check if the line is already present. If line exists then
           -- ignore the line.

           FOR I IN 1..x_line_tbl.count LOOP
               IF l_line_id = x_line_tbl(I).line_id
                THEN
                   l_query := 'N';
                   Exit;
                END IF;
           END LOOP;
        END IF;

        IF l_query = 'Y' THEN

           -- Decided to query the line. See what to pass to query sets.
           IF l_arrival_set_id is  not null
           OR l_ship_set_id is  not null
           OR l_smc_flag = 'Y'
           OR (l_ato_line_id is not null AND
               NOT (l_line_id = l_ato_line_id AND
                    l_item_type_code IN(OE_GLOBALS.G_ITEM_STANDARD,
                                      OE_GLOBALS.G_ITEM_OPTION)))
           THEN

               IF l_arrival_set_id is not null
               OR l_ship_set_id is not null
               OR l_smc_flag = 'Y'
               THEN

                  Oe_Config_Schedule_Pvt.Query_Set_Lines
                  (p_header_id      => l_header_id,
                   p_arrival_set_id => l_arrival_set_id,
                   p_ship_set_id    => l_ship_set_id,
                   p_model_line_id  => l_top_model_line_id,
                   p_sch_action     => p_sch_action,
                   x_line_tbl       => l_line_tbl,
                   x_return_status  => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

               ELSE

                  -- Query ato model.
                  OE_Config_Util.Query_ATO_Options
                    ( p_ato_line_id       => l_ato_line_id,
                      x_line_tbl          => l_line_tbl);

               END IF;

               --  query using top_model_line_id / ato line id


               IF x_line_tbl.count = 0 THEN

                 x_line_tbl := l_line_tbl;

               ELSE
                /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                 ,p_line_tbl   => l_line_tbl);  */   --Bug-2454163

                 J := x_line_tbl.count;
                 FOR I IN 1..l_line_tbl.count LOOP
                    IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                        x_line_tbl(J + I) := l_line_tbl(I);
                    END IF;
                 END LOOP;

               END IF;

           ELSIF  l_line_id = l_top_model_line_id THEN

                 -- This is a non smc top model. User might have selected model
                 -- and its options. If the model is selected query whole model
                 -- and try to place them in the
                 -- out table if they are not present already.

                 Oe_Config_Schedule_Pvt.Query_Set_Lines
                 (p_header_id      => l_header_id,
                  p_model_line_id  => l_top_model_line_id,
                  p_sch_action     => p_sch_action,
                  x_line_tbl       => l_line_tbl,
                  x_return_status  => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                 IF x_line_tbl.count = 0 THEN
                     x_line_tbl := l_line_tbl;
                 ELSE

                    /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                    ,p_line_tbl   => l_line_tbl);  */

                    J   :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP

                       IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                          J := J + 1;
                          x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;

                 END IF;
           ELSE


                OE_Line_Util.Query_Row
                (p_line_id    => l_line_id,
                 x_line_rec   => l_line_rec);

                IF  nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

                    IF l_sales_order_id is null THEN
                       l_sales_order_id :=
                         OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                              (l_line_rec.header_id);
                    END IF;

                    l_line_rec.reserved_quantity :=
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);
                                                                                l_line_rec.reserved_quantity2 :=   -- INVCONV
                              OE_LINE_UTIL.Get_Reserved_Quantity
                              (p_header_id => l_sales_order_id,
                               p_line_id   => l_line_rec.line_id,
                               p_org_id    => l_line_rec.ship_from_org_id);
                END IF;
                IF  l_line_rec.reserved_quantity IS NULL
                OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity := 0;
                END IF;

                                                                /*IF  l_line_rec.reserved_quantity2 IS NULL  -- INVCONV
                OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM
                THEN
                    l_line_rec.reserved_quantity2 := 0;
                END IF; */
                /* Check_Merge_Line(p_line_rec   => l_line_rec
                                ,p_x_line_tbl   => x_line_tbl);  */  --Bug-2454163

                IF NOT Find_Line(x_line_tbl,l_line_rec.line_id) THEN
                   x_line_tbl(x_line_tbl.count + 1) := l_line_rec;
                END IF;

                IF l_item_type_code = 'CLASS'
                OR l_item_type_code = 'KIT'
                THEN

                    Oe_Config_Schedule_Pvt.Query_Set_Lines
                    (p_header_id        => l_header_id,
                     p_link_to_line_id  => l_line_id,
                     p_sch_action       => p_sch_action,
                     x_line_tbl         => l_line_tbl,
                     x_return_status    => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     x_line_tbl.delete(x_line_tbl.count);

                  END IF;

                    /* Check_Merge_Line(p_x_line_tbl   => x_line_tbl
                                     ,p_line_tbl   => l_line_tbl); */  -- Bug-2454163

                    J :=  x_line_tbl.count;
                    FOR I IN 1..l_line_tbl.count LOOP
                       IF NOT Find_Line(x_line_tbl,l_line_tbl(I).line_id) THEN
                           J := J + 1;
                           x_line_tbl(J) := l_line_tbl(I);
                       END IF;
                    END LOOP;

                END IF; -- Class or Kit.
           END IF; -- group query or single query.

         END IF; -- l_query.

    END IF; -- do or do not.
  END LOOP;


EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXPECTED ERROR IN QUERY_ATP_CHECK_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNEXPECTED ERROR IN QUERY_ATP_CHECK_LINES ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    -- Start 2742982 --
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
    -- End 2742982 --

    WHEN OTHERS THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'WHEN OTHERS ERROR IN QUERY_ATP_CHECK_LINES ' , 1 ) ;
        END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_ATP_CHECK_Lines'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_ATP_CHECK_Lines;


/* ---------------------------------------------------------------
Procedure Schedule_Order
This procedure will be called from pld when user performs any scheduling
activity from header level.
An order can consists of many lines and each line can be within a group.
Call MRP for all lines at once. After calling the MRP for scheduling action
loop through the table and ignore all lines that failed the scheduling and
call process order for the lines that successfuly passed scheduling.
 ---------------------------------------------------------------*/
Procedure Schedule_Order(p_header_id       IN  NUMBER,
                         p_sch_action      IN  VARCHAR2,
                         x_atp_tbl         OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type,
                         x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                         x_msg_count       OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_msg_data        OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_line_tbl                OE_ORDER_PUB.Line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.Line_tbl_type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);

-- Need to remove this.
l_atp_tbl  OE_ATP.atp_tbl_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_GROUP_SCH_UTIL.SCHEDULE_ORDER' , 1 ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_HEADER_ID : ' || P_HEADER_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_SCH_ACTION: ' || P_SCH_ACTION , 1 ) ;
  END IF;

  -- Start 2434807 -
  -- Added to clear existing records from g_atp_tbl
  -- before starting scheduling event
  IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK THEN
    Oe_Schedule_Util.g_atp_tbl.delete;
  END IF;
  -- End 2434807 -


  Query_Lines(p_header_id  =>  p_header_id,
              p_sch_action =>  p_sch_action,
              x_line_tbl   =>  l_line_tbl);

  l_old_line_tbl := l_line_tbl;

    IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING MULTI_ATP_CHECK ' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT ' || L_LINE_TBL.COUNT ) ;
    END IF;

    IF l_line_tbl.count > 0 THEN

        OE_SCHEDULE_UTIL.Multi_ATP_CHECK
        (p_old_line_tbl   => l_old_line_tbl,
         p_x_line_tbl     => l_line_tbl,
         x_atp_tbl        => x_atp_tbl,
         x_return_status  => x_return_status);

    ELSE

      FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
      OE_MSG_PUB.Add;
    END IF;

  ELSE

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING PROCESS SCHEDULING GROUP ' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COUNT ' || L_LINE_TBL.COUNT ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'FIRST ' || L_LINE_TBL.FIRST ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LAST ' || L_LINE_TBL.LAST ) ;
    END IF;

    IF l_line_tbl.count > 0 THEN

     Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'UI_ACTION'
       ,p_sch_action     => p_sch_action
       ,p_partial        => TRUE
       ,x_return_status  => x_return_status);
    ELSE

      IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE THEN
        FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
        OE_MSG_PUB.Add;
      END IF;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  oe_msg_pub.count_and_get
     (p_count                       => x_msg_count
      ,p_data                        => x_msg_data);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS ' || X_MSG_COUNT , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_GROUP_SCH_UTIL.SCHEDULE_ORDER' , 1 ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Order'
            );
        END IF;

        oe_msg_pub.count_and_get
           (  p_count                       => x_msg_count
             ,p_data                        => x_msg_data
           );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Schedule_Order;
/*---------------------------------------------------------------
Procedure :Schedule_Multi_lines
           This procedure is called when lines are multi-selected and
           scheduling action is performed.
           Based on the requested action this API will call appropriate
           query api's which will get all approprite a lines. Based on the
           action call process group or multi atp check.
---------------------------------------------------------------*/
Procedure Schedule_Multi_lines
(p_selected_line_tbl  IN  OE_GLOBALS.Selected_Record_Tbl, --R12.MOAC
 p_line_count     IN  NUMBER,
 p_sch_action     IN  VARCHAR2,
 x_atp_tbl        OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type,
 x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count      OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
j                      Integer;
initial                Integer;
nextpos                Integer;
--3751812
--l_record_ids           VARCHAR2(2000) := p_line_list || ',';
--l_record_ids           VARCHAR2(32000) := p_line_list || ',';

l_line_id              NUMBER;

l_line_tbl             OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_line_id_tbl          number_arr;
l_set_rec              OE_ORDER_CACHE.set_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SCHEDULE_MULTI_LINES' , 1 ) ;
      oe_debug_pub.add(  'LINE COUNT IS: ' || P_LINE_COUNT , 1 ) ;
      oe_debug_pub.add(  'ACTION IS: ' || P_SCH_ACTION , 1 ) ;
   END IF;

   -- Start 2434807 -
   -- Added to clear existing records from g_atp_tbl
   -- before starting scheduling event
   IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK THEN
      Oe_Schedule_Util.g_atp_tbl.delete;
   END IF;
   -- End 2434807 -

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --R12.MOAC
   /*
   j := 1;
   initial := 1;
   nextpos := INSTR(l_record_ids,',',1,j) ;

   FOR I IN 1..p_line_count LOOP

     l_line_id := to_number(substr(l_record_ids,initial, nextpos-initial));
     l_line_id_tbl(j) := l_line_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE_ID : ' || L_LINE_ID , 1 ) ;
     END IF;

     initial := nextpos + 1.0;
     j := j + 1.0;
     nextpos := INSTR(l_record_ids,',',1,j) ;

   END LOOP;
   */
   IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE THEN

      Query_Schedule_lines(p_sch_action   => p_sch_action,
                           p_selected_tbl => p_selected_line_tbl,  --R12.MOAC
                           x_line_tbl     => l_line_tbl);

   ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNSCHEDULE THEN

      Query_Unschedule_lines(p_sch_action   => p_sch_action,
                             p_selected_tbl => p_selected_line_tbl,  --R12.MOAC
                             x_line_tbl     => l_line_tbl);

   ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_UNRESERVE THEN

      Query_Unreserve_lines(p_sch_action   => p_sch_action,
                            p_selected_tbl => p_selected_line_tbl,  --R12.MOAC
                            x_line_tbl     => l_line_tbl);

   ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE THEN

      Query_Reserve_lines(p_sch_action   => p_sch_action,
                          p_selected_tbl => p_selected_line_tbl,  --R12.MOAC
                          x_line_tbl     => l_line_tbl);

   ELSIF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK THEN
      --Bug 5881611
      --Creating a savepoint, so that  it can be be rolled for ATP Checks.
      --This is to rollback updates to database made by Availability window, which
      --calls process_included_items to explode included items and oe_order_pvt.lines
      --which updates the database tables.
      oe_debug_pub.add('Creating a savepoint for ATP Check activity.');
      SAVEPOINT SP_ONLY_ATP_CHECK;
      Query_ATP_CHECK_lines(p_sch_action   => p_sch_action,
                            p_selected_tbl => p_selected_line_tbl,  --R12.MOAC
                            x_line_tbl     => l_line_tbl);
   END IF;

   IF l_line_tbl.count > 0 THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('No lines to process : '||l_line_tbl.count,1);
      END IF;

      Validate_Group
         (p_x_line_tbl      => l_line_tbl,
          p_sch_action      => p_sch_action,
          p_validate_action => 'COMPLETE',         --added for bug 3590437
          x_return_status   => x_return_status);

     --3990887
     --END IF;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' AFTER VALIDATE_GROUP : '||x_return_status,1);
     END IF;

     -- 3990887
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       ----------- set up the tables -------------------------
       l_old_line_tbl := l_line_tbl;

       FOR I IN 1..l_line_tbl.count LOOP

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE ID : ' || L_LINE_TBL ( I ) .LINE_ID , 4 ) ;
          END IF;
          l_line_tbl(I).operation :=  OE_GLOBALS.G_OPR_UPDATE;
          l_line_tbl(I).schedule_action_code := p_sch_action;

          IF (l_line_tbl(I).arrival_set_id is not null) THEN
             l_set_rec := OE_ORDER_CACHE.Load_Set
                             (l_line_tbl(I).arrival_set_id);
             l_line_tbl(I).arrival_set      := l_set_rec.set_name;
          ELSIF (l_line_tbl(I).ship_set_id is not null) THEN
             l_set_rec := OE_ORDER_CACHE.Load_Set
                             (l_line_tbl(I).ship_set_id);
             l_line_tbl(I).ship_set      := l_set_rec.set_name;
          ELSIF (l_line_tbl(I).ship_model_complete_flag ='Y') THEN
             l_line_tbl(I).ship_set      := l_line_tbl(I).top_model_line_id;
          ELSIF (l_line_tbl(I).ato_line_id is not null)
                AND NOT(OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
                        AND MSC_ATP_GLOBAL.GET_APS_VERSION = 10)
          THEN
             l_line_tbl(I).ship_set      := l_line_tbl(I).ato_line_id;
          END IF;

       END LOOP;

        ------- Action Specific processing -----------------------
       -- 3990887
       IF p_sch_action = OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK
       THEN
          --Bug 5881611
          --Rolling back
          oe_debug_pub.add('Rollback for only atp check');
          oe_delayed_requests_pvt.Clear_Request(
 		 x_return_status => x_return_status);
          ROLLBACK TO SAVEPOINT SP_ONLY_ATP_CHECK;

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE CALLING MULTI_ATP_CHECK ' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LINE COUNT ' || L_LINE_TBL.COUNT , 1 ) ;
          END IF;

             OE_SCHEDULE_UTIL.Multi_ATP_CHECK
                (p_old_line_tbl   => l_old_line_tbl,
                 p_x_line_tbl     => l_line_tbl,
                 x_atp_tbl        => x_atp_tbl,
                 x_return_status  => x_return_status);

       ELSE

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE CALLING PROCESS SCHEDULING GROUP ' ) ;
             oe_debug_pub.add(  'LINE COUNT ' || L_LINE_TBL.COUNT , 1 ) ;
          END IF;

          -- 3870895 : call process_group only when coun > 0 and return status is success
          IF l_line_tbl.count > 0
             AND x_return_status = FND_API.G_RET_STS_SUCCESS
          THEN

             Oe_Config_Schedule_Pvt.Process_Group
                (p_x_line_tbl      => l_line_tbl
                 ,p_old_line_tbl   => l_old_line_tbl
                 ,p_caller         => 'UI_ACTION'
                 ,p_sch_action     => p_sch_action
                 ,p_partial        => TRUE
                 ,x_return_status  => x_return_status);

             IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                --      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                --        RAISE FND_API.G_EXC_ERROR;
             END IF;

          ELSE
             IF p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_RESERVE
              AND p_sch_action <> OE_SCHEDULE_UTIL.OESCH_ACT_ATP_CHECK
             THEN
                FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
                OE_MSG_PUB.Add;
             END IF;
          END IF;

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER PROCESS GROUP' || X_RETURN_STATUS , 1 ) ;
          END IF;
         END IF;
       --  Set return status.

       END IF;
    END IF; -- 3990887

   oe_msg_pub.count_and_get
      (   p_count                       => x_msg_count
          ,   p_data                        => x_msg_data);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' MESSAGE COUNT: ' || X_MSG_COUNT , 1 ) ;
   END IF;
   --  Set return status.

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;

   END IF;


   -- Returning success, even if there were errors (unexpected errors will
   -- be raised and taken care of). This is because we do not want to rollback
   -- since the successful lines should get committed.

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /* --  Get message count and data

    oe_msg_pub.count_and_get
      (   p_count                       => x_msg_count
      ,   p_data                        => x_msg_data
      );

   */
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SCHEDULE_MULTI_LINES WITH: ' || X_RETURN_STATUS , 1 ) ;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      --  Get message count and data

      oe_msg_pub.count_and_get
         (   p_count                       => x_msg_count
         ,   p_data                        => x_msg_data
         );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      --  Get message count and data

      oe_msg_pub.count_and_get
         (   p_count                       => x_msg_count
         ,   p_data                        => x_msg_data
         );

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
      THEN
         oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME,
                'Schedule_Multi_lines'
            );
      END IF;

      --  Get message count and data

      oe_msg_pub.count_and_get
         (   p_count                       => x_msg_count
         ,   p_data                        => x_msg_data
         );

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Schedule_Multi_lines;
/* ------------------------------------------------------------
Procedure schedule_set_lines
(p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
      p_entity_id              => p_line_rec.line_id,
      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
      p_requesting_entity_id   => p_line_rec.line_id,
      p_request_type           => OE_GLOBALS.G_SCHEDULE_LINE,
      p_param1                 => l_param1,
      p_param2                 => p_line_rec.header_id,
      p_param3                 => l_action,
      p_param4                 => p_old_line_rec.ship_from_org_id,
      p_param5                 => p_old_line_rec.ship_to_org_id,
      p_param6                 => p_old_line_rec.ship_set_id,
      p_param7                 => p_old_line_rec.arrival_set_id,
      p_param8                 => l_entity_type,
      p_param9                 => l_ship_to_org_id -- ship to from sets table.
      p_param10                => l_ship_to_org_id -- ship to from sets table.
      p_param11                => l_shipping_method_code
      p_date_param1            => p_old_line_rec.schedule_ship_date,
      p_date_param2            => p_old_line_rec.schedule_arrival_date,
      p_date_param3            => p_old_line_rec.request_date,
      p_date_param4            => l_schedule_ship_date,
      p_date_param5            => l_schedule_arrival_date,
      x_return_status          => x_return_status);

Description: This procedure will be called when the delayed request
             SCHEDULE_LINE is logged. This delayed request is logged
             when new lines are inserted to a SCHEDULE SET. A set being
             a user defined ship or arrival set.When multiple lines are
             iserted to the same set, this procedure is called once for
             all the lines of the set.
             If the included item is part of request table, check for the
             parent. If parent exists in the table, assume that parent will
             fetch the included items and remove included items from the list.

             Changes have been made to copy override_atp flag from model/class/
             kit to it's included items when the flag is set.
-------------------------------------------------------------------*/
Procedure Schedule_set_lines
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_rec           OE_ORDER_PUB.line_rec_type;
l_line_tbl           OE_ORDER_PUB.line_Tbl_type;
l_old_line_tbl       OE_ORDER_PUB.line_Tbl_type;
l_request_rec        OE_ORDER_PUB.request_rec_type;
l_old_set_tbl        set_tbl_type;
l_sales_order_id     NUMBER;
l_line_exists        VARCHAR2(1) := 'N';
l_iline_tbl          OE_ORDER_PUB.line_Tbl_type;
l_item_type_code     VARCHAR2(30);
l_link_to_line_id    NUMBER;
l_top_model_line_id  NUMBER;
l_ato_line_id        NUMBER;
l_header_id          NUMBER;
K                    NUMBER;
l_param12            VARCHAR2(1) := 'N'; --3384975
l_type_code          VARCHAR2(30);-- 3564302(issue#1)
--3564310
l_ship_set_id        NUMBER;
l_arrival_set_id     NUMBER;
l_set_rec            OE_ORDER_CACHE.set_rec_type;
l_log_error          BOOLEAN := FALSE;
l_part_of_set        VARCHAR2(1) :='Y'; --4405004

-- 3870895
CURSOR C5 IS
Select line_id, shipping_interfaced_flag
from oe_order_lines_all
where top_model_line_id = l_top_model_line_id
and open_flag = 'Y'
and shipping_interfaced_flag = 'Y';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_GROUP_SCH_UTIL.SCHEDULE_SET_LINES' , 1 ) ;
  END IF;

  K := 0;
  FOR I in 1..p_sch_set_tbl.count LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PROCESSING LINE' || P_SCH_SET_TBL ( I ) .ENTITY_ID , 1 ) ;
      END IF;

      -- For the included item, check if the parent is present the in table.
      -- That means parent will explode the line or else add the line to
      -- line tbl.

      -- 3384975
      IF p_sch_set_tbl(I).param12 = 'Y' THEN
         l_param12 := p_sch_set_tbl(I).param12;
      END IF;

      l_line_exists := 'N';
      -- 3564310 set ids selected
      BEGIN
        Select item_type_code,
               link_to_line_id,
               top_model_line_id,
               ato_line_id,
               header_id,
               ship_set_id,
               arrival_set_id
        Into   l_item_type_code,
               l_link_to_line_id,
               l_top_model_line_id,
               l_ato_line_id,
               l_header_id,
               l_ship_set_id,
               l_arrival_set_id
        From   oe_order_lines_all
        Where  line_id = p_sch_set_tbl(I).entity_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'ERROR WHILE SELECTING DATA' , 5 ) ;
          END IF;
          l_line_exists := 'Y';
      END;

     --{bug3885953: If the ship/arrival set has changed, do not use old delayed
     --request, but just go to the end of processing
     IF (p_sch_set_tbl(I).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET AND
         l_ship_set_id <> p_sch_set_tbl(I).param1) OR
        (p_sch_set_tbl(I).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET AND
         l_arrival_set_id <> p_sch_set_tbl(I).param1) THEN
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.Add('Sets differs, goto END OF PROCESS',2);
           END IF;
           GOTO END_OF_PROCESS;
     END IF;
     -- end of bug3885953 }



      IF l_ship_set_id is null
      AND l_arrival_set_id is null THEN
      -- 3870895
        IF l_top_model_line_id is not null
         AND l_top_model_line_id = p_sch_set_tbl(I).entity_id THEN

          Update oe_order_lines_all l
          Set arrival_set_id = Null,
              ship_set_id = Null
          Where top_model_line_id =  l_top_model_line_id
          And  open_flag = 'Y';

        END IF;

        FOR optionrec in C5
        LOOP

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE SHIPPING : CHILDREN OF MODEL ' || TO_CHAR ( OPTIONREC.LINE_ID ) , 1 ) ;
           END IF;

            OE_Delayed_Requests_Pvt.Log_Request(
            p_entity_code            =>   OE_GLOBALS.G_ENTITY_LINE,
            p_entity_id              =>   optionrec.line_id,
            p_requesting_entity_code =>   OE_GLOBALS.G_ENTITY_LINE,
            p_requesting_entity_id   =>   optionrec.line_id,
            p_request_type           =>   OE_GLOBALS.G_UPDATE_SHIPPING,
            p_request_unique_key1    =>   OE_GLOBALS.G_OPR_UPDATE,
            p_param1                 =>   FND_API.G_TRUE,
            x_return_status          =>   x_return_status);

        End loop;

        oe_debug_pub.add('Set does not exist on line ' || p_sch_set_tbl(I).entity_id,2);

        goto END_OF_PROCESS;

      END IF;
      IF  (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
      AND  MSC_ATP_GLOBAL.GET_APS_VERSION = 10)  THEN

      IF l_top_model_line_id <> p_sch_set_tbl(I).entity_id
      AND l_top_model_line_id is not null
      THEN
         FOR J IN 1..p_sch_set_tbl.count LOOP
          IF (l_link_to_line_id = p_sch_set_tbl(J).entity_id
          AND l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED)
          OR l_top_model_line_id =  p_sch_set_tbl(J).entity_id
          THEN
             --Parent exists.
              IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'PARENT EXISTS: ' || P_SCH_SET_TBL ( J).ENTITY_ID , 1 ) ;
              END IF;
              l_line_exists := 'Y';
             EXIT;
          END IF;
         END LOOP;
      END IF; -- Not top

      ELSE -- GOP Code
      -- If the line is present in the table ignore the line.
      IF l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
      THEN
           FOR J IN 1..p_sch_set_tbl.count LOOP
            IF l_link_to_line_id = p_sch_set_tbl(J).entity_id THEN
               --Parent exists.
                 IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'PARENT EXISTS: ' || P_SCH_SET_TBL ( J ) .ENTITY_ID , 1 ) ;
                 END IF;
               l_line_exists := 'Y';
              EXIT;
            END IF;
           END LOOP;
      END IF; -- Included

      END IF; -- GOP code

      -- Do not go in to this code, if the line is a top model or
      -- an ato model

      oe_debug_pub.add(' l_line_exists :' || l_line_exists,1);
      oe_debug_pub.add(' l_ato_line_id :' || l_ato_line_id,1);
      oe_debug_pub.add(' l_item_type_code :'||  l_item_type_code,1);
      IF l_line_exists = 'N'
      AND nvl(l_top_model_line_id,0) <> p_sch_set_tbl(I).entity_id
      AND NOT (l_item_type_code = OE_GLOBALS.G_ITEM_CLASS
          AND  nvl(l_ato_line_id,-99) = p_sch_set_tbl(I).entity_id) THEN


         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE IS SELECTED FOR PROCESSING ' || P_SCH_SET_TBL ( I ) .ENTITY_ID , 1 ) ;
         END IF;
         l_line_rec   := OE_ORDER_PUB.G_MISS_LINE_REC;
         OE_LINE_UTIL.Lock_Row(p_line_id       => p_sch_set_tbl(I).entity_id,
                               p_x_line_rec    => l_line_rec,
                               x_return_status => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         END IF;


         IF  nvl(l_line_rec.shippable_flag,'N') = 'Y'
         AND l_line_rec.schedule_status_code is not null THEN

             IF l_sales_order_id is null THEN
               l_sales_order_id :=
                 OE_SCHEDULE_UTIL.Get_mtl_sales_order_id(l_line_rec.header_id);
             END IF;

               -- INVCONV - MERGED CALLS         FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

                                                                OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_line_rec.reserved_quantity2
                                                                                                                                                                                        );

             /*l_line_rec.reserved_quantity :=
                OE_LINE_UTIL.Get_Reserved_Quantity
                  (p_header_id   => l_sales_order_id,
                   p_line_id     => l_line_rec.line_id,
                   p_org_id      => l_line_rec.ship_from_org_id);

                                                        l_line_rec.reserved_quantity2 :=  -- INVCONV
                OE_LINE_UTIL.Get_Reserved_Quantity2
                  (p_header_id   => l_sales_order_id,
                   p_line_id     => l_line_rec.line_id,
                   p_org_id      => l_line_rec.ship_from_org_id); */
         END IF;

         IF  l_line_rec.reserved_quantity IS NULL
         OR  l_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
              l_line_rec.reserved_quantity := 0;
         END IF;
        /* IF  l_line_rec.reserved_quantity2 IS NULL  -- INVCONV  -- why was this commented out
         OR  l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
              l_line_rec.reserved_quantity2 := 0;
         END IF; */


         -- Check if the line is part of Model and it is already scheduled.
         -- by its parent ??????????????????????????/

         K := K + 1;

         l_old_line_tbl(K)                      := l_line_rec;
         l_line_tbl(K)                          := l_line_rec;

         l_old_line_tbl(K).schedule_ship_date   :=  null;
         l_old_line_tbl(K).schedule_arrival_date:=  null;
         l_old_line_tbl(K).schedule_ship_date   := p_sch_set_tbl(I).date_param1;
         l_old_line_tbl(K).schedule_arrival_date:= p_sch_set_tbl(I).date_param2;
         l_old_line_tbl(K).request_date         := p_sch_set_tbl(I).date_param3;
         -- bug 3850293; FP -  added the IF condition
         IF p_sch_set_tbl(I).param4 IS NOT NULL THEN
            l_old_line_tbl(K).ship_from_org_id     := p_sch_set_tbl(I).param4;
         END IF;
         l_old_line_tbl(K).ship_to_org_id       := p_sch_set_tbl(I).param5;

       --  l_old_line_tbl(K).ship_set_id        := p_sch_set_tbl(I).param6;
       --  l_old_line_tbl(K).arrival_set_id     := p_sch_set_tbl(I).param7;

        l_old_set_tbl(k).ship_set_id        := p_sch_set_tbl(I).param6;
        l_old_set_tbl(k).arrival_set_id     := p_sch_set_tbl(I).param7;

         /* Start Audit Trail */
         l_line_tbl(K).change_reason := 'SYSTEM';
       l_line_tbl(K).change_comments := 'Delayed Request , Scheduling';
         /* End Audit Trail */

         l_line_tbl(K).operation             :=  OE_GLOBALS.G_OPR_UPDATE;

          /* Commented the above line to fix the bug 2916814 */
         --3564302 (#1)
         -- Get the order date type code
         l_type_code    := oe_schedule_util.Get_Date_Type(l_line_tbl(K).header_id);

         IF  p_sch_set_tbl(I).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
         THEN
           -- Ship set date.
           l_line_tbl(K).Schedule_ship_date  :=  p_sch_set_tbl(I).date_param4;
           -- 3564302
           IF l_type_code = 'ARRIVAL' THEN
              l_line_tbl(K).Schedule_arrival_date :=  p_sch_set_tbl(I).date_param5;
           END IF;
           IF  p_sch_set_tbl(I).param10 is not null THEN
            l_line_tbl(K).ship_from_org_id := p_sch_set_tbl(I).param10;
            l_line_tbl(k).re_source_flag := 'N';
           END IF;
           IF fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET') = 'Y' THEN
              oe_debug_pub.add('ONT_SHIP_METHOD_FOR_SHIP_SET' || p_sch_set_tbl(I).param11,2);
              l_line_tbl(K).shipping_method_code  :=  p_sch_set_tbl(I).param11;
           END IF;
         END IF;

         IF  p_sch_set_tbl(I).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
         THEN
           l_line_tbl(K).Schedule_arrival_date :=  p_sch_set_tbl(I).date_param5;
           -- 3564302(issue 1)
           IF l_type_code = 'SHIP' THEN
              l_line_tbl(K).Schedule_ship_date :=  p_sch_set_tbl(I).date_param4;
           END IF;
         END IF;

         -- Assign the value from the sets table. That way we are
         -- enforcing all the lines to have a same ship to.

         IF  p_sch_set_tbl(I).param9 is not null THEN
             l_line_tbl(K).ship_to_org_id := p_sch_set_tbl(I).param9;
         END IF;

         l_line_tbl(K).schedule_action_code  :=
                               OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;


         IF l_line_tbl(K).arrival_set_id is not null THEN
            l_line_tbl(K).arrival_set := l_line_tbl(K).arrival_set_id;
         ELSE
            l_line_tbl(K).ship_set := l_line_tbl(K).ship_set_id;
         END IF;
      END IF; -- Line Exists.


      IF l_item_type_code = 'CLASS'
      OR l_item_type_code = 'KIT'
      OR l_item_type_code = 'MODEL'
      THEN

        oe_debug_pub.add('line_id ' ||  p_sch_set_tbl(I).entity_id,3);
        oe_debug_pub.add(' top line ' || l_top_model_line_id,3);
        oe_debug_pub.add(' ato line ' || l_ato_line_id,3);
        oe_debug_pub.add(' item type  ' || l_item_type_code,3);
        oe_debug_pub.add(' header_id  ' || l_header_id,3);

        IF p_sch_set_tbl(I).entity_id = nvl(l_top_model_line_id,0) THEN
        Oe_Config_Schedule_Pvt.Query_Set_Lines
         (p_header_id        => l_header_id,
          p_model_line_id    => l_top_model_line_id,
          p_sch_action       => 'SCHEDULE',
          x_line_tbl         => l_iline_tbl,
          x_return_status    => x_return_status);

        ELSIF (l_ato_line_id is not null AND
          NOT (l_ato_line_id = p_sch_set_tbl(I).entity_id AND
              l_item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                   OE_GLOBALS.G_ITEM_OPTION)))
        THEN

        OE_Config_Util.Query_ATO_Options
        ( p_ato_line_id       => l_ato_line_id
         ,p_send_cancel_lines => 'Y'
         ,p_source_type       => OE_Globals.G_SOURCE_INTERNAL
         ,x_line_tbl          => l_iline_tbl);


        ELSE

        Oe_Config_Schedule_Pvt.Query_Set_Lines
         (p_header_id        => l_header_id,
          p_link_to_line_id  => p_sch_set_tbl(I).entity_id,
          p_sch_action       => 'SCHEDULE',
          x_line_tbl         => l_iline_tbl,
          x_return_status    => x_return_status);

        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- 3564310
        -- Line is no longer with the set
        --  rollback the changes.
        IF l_ship_set_id is  null
          AND l_arrival_set_id IS  null THEN
           FOR I IN 1..l_iline_tbl.count LOOP
              IF l_iline_tbl(I).schedule_status_code IS NULL THEN

                 UPDATE OE_ORDER_LINES_ALL
                 SET SCHEDULE_SHIP_DATE  = Null,
                 SCHEDULE_ARRIVAL_DATE = Null,
                 SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
                 SHIP_SET_ID           = Null,
                 ARRIVAL_SET_ID        = Null,
                 override_atp_date_code = Null
                 WHERE line_id = l_iline_tbl(I).line_id;

              ELSE
                 UPDATE OE_ORDER_LINES_ALL
                 SET
                 SCHEDULE_SHIP_DATE    = p_sch_set_tbl(I).date_param1,
                 SCHEDULE_ARRIVAL_DATE = p_sch_set_tbl(I).date_param2,
                 SHIP_FROM_ORG_ID      = p_sch_set_tbl(I).param4,
                 SHIP_SET_ID           = p_sch_set_tbl(I).param6,
                 ARRIVAL_SET_ID        = p_sch_set_tbl(I).param7
                 WHERE line_id = l_iline_tbl(I).line_id;
              END IF;
              -- 4026758
              IF l_iline_tbl(I).ship_set_id IS NOT NULL
                 OR l_iline_tbl(I).arrival_set_id IS NOT NULL THEN
                 oe_schedule_util.Log_Delete_Set_Request
                    (p_header_id   => l_iline_tbl(I).header_id,
                     p_line_id     => l_iline_tbl(I).line_id,
                     p_set_id      => nvl(l_iline_tbl(I).ship_set_id,
                                          l_iline_tbl(I).arrival_set_id),
                     x_return_status => x_return_status);
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST '
                                       || X_RETURN_STATUS , 1 ) ;
                 END IF;
              END IF;

              IF l_iline_tbl(I).shipping_interfaced_flag = 'Y' THEN

                 oe_debug_pub.add('Line is interfaced ',2);

                 OE_Delayed_Requests_Pvt.Log_Request(
                 p_entity_code               =>  OE_GLOBALS.G_ENTITY_LINE,
                 p_entity_id                 =>  l_iline_tbl(I).line_id,
                 p_requesting_entity_code    =>  OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id      =>  l_iline_tbl(I).line_id,
                 p_request_type              =>  OE_GLOBALS.G_UPDATE_SHIPPING,
                 p_request_unique_key1       =>  OE_GLOBALS.G_OPR_UPDATE,
                 p_param1                    =>  FND_API.G_TRUE,
                 x_return_status             =>  x_return_status);

             END IF;
           END LOOP;
           EXIT;
         END IF;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'INCLUDED ITEM COUNT ' || L_ILINE_TBL.COUNT,2);
        END IF;

          -- Start 2716220 --
   -- To check schedule dates with override flag

        l_type_code    := oe_schedule_util.Get_Date_Type(l_header_id);

       IF l_arrival_set_id is not null THEN

          l_set_rec := OE_ORDER_CACHE.Load_Set
                             (l_arrival_set_id);

       ELSIF l_ship_set_id is not null THEN

          l_set_rec := OE_ORDER_CACHE.Load_Set
                             (l_Ship_set_id);
       END IF;

       l_log_error := FALSE;

       FOR O IN 1..l_iline_tbl.count LOOP
       IF NVL(l_iline_tbl(O).override_atp_date_code,'N') = 'Y'
       THEN

         IF l_type_code = 'ARRIVAL' THEN
            IF l_iline_tbl(O).schedule_arrival_date IS NOT NULL
            AND l_set_rec.schedule_arrival_date IS NOT NULL
            AND  l_iline_tbl(O).schedule_arrival_date <> l_set_rec.schedule_arrival_date
            THEN
              oe_debug_pub.add('Arr date does not match with set date' || l_iline_tbl(O).line_id,2);
              l_log_error := TRUE;
            END IF;

         ELSE

            IF l_iline_tbl(O).schedule_ship_date IS NOT NULL
            AND l_set_rec.schedule_ship_date IS NOT NULL
            AND  l_iline_tbl(O).schedule_ship_date <> l_set_rec.schedule_ship_date
            THEN
              oe_debug_pub.add('Sch date does not match with set date' || l_iline_tbl(O).line_id,2);
              l_log_error := TRUE;
            END IF;
         END IF;
       END IF;
       END LOOP;

       IF l_log_error THEN
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_OVER_ATP_SET_NO_MATCH');
         OE_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

        FOR M IN 1..l_iline_tbl.count LOOP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add('LINE_ID: ' || l_iline_tbl(M).LINE_ID, 1);
          END IF;

          K := K + 1;

          -- BUG 1282873
          IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
            IF l_line_rec.override_atp_date_code = 'Y' THEN
             l_iline_tbl(M).override_atp_date_code := l_line_rec.override_atp_date_code;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OVERRIDE_ATP :' || L_ILINE_TBL(M).OVERRIDE_ATP_DATE_CODE , 3 ) ;
             END IF;
            END IF;
          END IF;
          -- END 1282873

          l_line_tbl(K) := l_iline_tbl(M);
          l_old_line_tbl(K) := l_iline_tbl(M);
          l_old_line_tbl(K).schedule_ship_date    :=  null;
          l_old_line_tbl(K).schedule_arrival_date :=  null;
          l_old_line_tbl(K).schedule_ship_date  := p_sch_set_tbl(I).date_param1;
          l_old_line_tbl(K).schedule_arrival_date:= p_sch_set_tbl(I).date_param2;
          l_old_line_tbl(K).request_date       := p_sch_set_tbl(I).date_param3;
          --bug 3850293; FP - added IF condition
          IF p_sch_set_tbl(I).param4 IS NOT NULL THEN
             l_old_line_tbl(K).ship_from_org_id   := p_sch_set_tbl(I).param4;
          END IF;
          l_old_line_tbl(K).ship_to_org_id     := p_sch_set_tbl(I).param5;

         --  l_old_line_tbl(K).ship_set_id     := p_sch_set_tbl(I).param6;
         --  l_old_line_tbl(K).arrival_set_id  := p_sch_set_tbl(I).param7;


         l_old_set_tbl(k).ship_set_id        := p_sch_set_tbl(I).param6;
         l_old_set_tbl(k).arrival_set_id     := p_sch_set_tbl(I).param7;

           /* Start Audit Trail */
           l_line_tbl(K).change_reason := 'SYSTEM';
         l_line_tbl(K).change_comments := 'Delayed Request , Scheduling';
           /* End Audit Trail */

           l_line_tbl(K).operation    :=  OE_GLOBALS.G_OPR_UPDATE;

           IF  p_sch_set_tbl(I).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
           THEN
             -- Ship set date.
             l_line_tbl(K).Schedule_ship_date  :=  p_sch_set_tbl(I).date_param4;
             -- 3564302
             IF l_type_code = 'ARRIVAL' THEN
               l_line_tbl(K).Schedule_arrival_date :=  p_sch_set_tbl(I).date_param5;
             END IF;
             IF  p_sch_set_tbl(I).param10 is not null THEN
              l_line_tbl(K).ship_from_org_id := p_sch_set_tbl(I).param10;
              l_line_tbl(k).re_source_flag := 'N';
             END IF;
              IF fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET') = 'Y' THEN
                oe_debug_pub.add('ONT_SHIP_METHOD_FOR_SHIP_SET Model:' || p_sch_set_tbl(I).param11,1);
                l_line_tbl(K).shipping_method_code  :=  p_sch_set_tbl(I).param11;
              END IF;
           END IF;

           IF  p_sch_set_tbl(I).param8
                         = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
           THEN
             l_line_tbl(K).Schedule_arrival_date
                                :=  p_sch_set_tbl(I).date_param5;
             -- 3564302
             IF l_type_code = 'SHIP' THEN
                l_line_tbl(K).Schedule_ship_date :=  p_sch_set_tbl(I).date_param4;
             END IF;
           END IF;

           -- Assign the value from the sets table. That way we are
           -- enforcing all the lines to have a same ship to.

           IF  p_sch_set_tbl(I).param9 is not null THEN
               l_line_tbl(K).ship_to_org_id := p_sch_set_tbl(I).param9;
           END IF;

           l_line_tbl(K).schedule_action_code  :=
                                 OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;

           IF l_line_tbl(K).arrival_set_id is not null THEN
              l_line_tbl(K).arrival_set := l_line_tbl(K).arrival_set_id;
           ELSE
              l_line_tbl(K).ship_set := l_line_tbl(K).ship_set_id;
           END IF;
          END LOOP; -- End of included item
      END IF; -- Class or KIT

    <<END_OF_PROCESS>>
    Null;
  END LOOP; -- Main loop.

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Line Count :' || l_line_tbl.count,1);
  END IF;
  --3564310
  -- Validate the lines befor calling process_group
  IF l_line_tbl.count > 0 THEN


      Validate_Group
         (p_x_line_tbl    => l_line_tbl,
          p_sch_action    => 'SCHEDULE',
          x_return_status => x_return_status);

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING Validate Group ' || X_RETURN_STATUS
            || l_line_tbl.count , 1 ) ;
  END IF;
  -- 3564310
  IF l_line_tbl.count > 0
    AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'SET'
       ,p_sch_action     => OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE
       ,p_partial_set    => TRUE
       ,p_part_of_set    => l_part_of_set --4405004
       ,x_return_status  => x_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('After call to Process Group :' || x_return_status ,1);
  END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END IF;

  -- Additional process we are doing to fix bug 2232950.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Compare output with requested values',1);
     END IF;

   FOR I IN 1..l_line_tbl.count LOOP

      IF  p_sch_set_tbl(1).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
      AND trunc(l_line_tbl(I).Schedule_ship_date) <> trunc(p_sch_set_tbl(1).date_param4)
      THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Not received correct values for ship set',1);
         END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           EXIT;
      ELSIF  p_sch_set_tbl(1).param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
      AND    trunc(l_line_tbl(I).Schedule_arrival_date) <> trunc(p_sch_set_tbl(1).date_param5)
      THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Not received correct values for arrival set',1);
         END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
           EXIT;
      END IF;

   END LOOP;
  END IF; -- Success.

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Line Id error out : ' || l_line_rec.line_id,2);
     END IF;

     -- Could not schedule the line on the set date. Let's schedule
     -- the whole set to see if we get another date got the whole
     -- set.

     IF fnd_profile.value('ONT_AUTO_PUSH_GRP_DATE') = 'Y' THEN

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Auto Push Group Date is Yes',2);
        END IF;

         -- Added this stmt to fix big 1899651.
         l_request_rec := p_sch_set_tbl(1);
         l_request_rec.param3 := OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
         -- 3384975
         l_request_rec.param12 := l_param12;

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Stng G_CASCADING_REQUEST_LOGGED to TRUE',2);
         END IF;
         OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

          Schedule_Set(p_request_rec    => l_request_rec,
                       x_return_status  => x_return_status);

     ELSE

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Before setting message for group failure',2);
        END IF;

       FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
       OE_MSG_PUB.Add;

     END IF; -- If Auto Push Group Date is Yes

     -- Scheduling Failed. If the line belongs to a Ship Set or Arrival
     -- Set, then just clear out the scheduling attributes and return a
     -- message that the line schedule failed. We will return a success
     -- since we do not want to fail the line insert due to this.

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Calling Update Set');
     END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Unable to schedule the line for set date');
       END IF;

      FOR I IN 1..l_line_tbl.count LOOP
       IF  l_line_tbl(I).top_model_line_id IS NOT NULL
       AND l_line_tbl(I).top_model_line_id <> l_line_tbl(I).line_id THEN

            -- Scheduling Failed. If the line belongs to a ATO Model or SMC
            -- PTO, then return an error, since the option cannot be inserted
            -- to a scheduled ATO or SMC PTO if it cannot be scheduled on
            -- the same date as that of the model.

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Line belong to model');
            END IF;
            fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
            OE_MSG_PUB.Add;
            RAISE  FND_API.G_EXC_ERROR;

       ELSE
        -- If the line is being added to set is a standard line
        -- save the line without scheduling attributes.
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Standard line is failed');
         END IF;
        fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
        OE_MSG_PUB.Add;

        IF l_line_tbl(I).schedule_status_code IS NULL
        THEN

           UPDATE OE_ORDER_LINES_ALL
           SET SCHEDULE_SHIP_DATE  = Null,
             SCHEDULE_ARRIVAL_DATE = Null,
             SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
             SHIP_SET_ID           = Null,
             ARRIVAL_SET_ID        = Null,
             override_atp_date_code = Null
           WHERE line_id = l_line_tbl(I).line_id;

        ELSE
        -- fix for 3557779
        -- update schedule_status_code and visible_demand_flag fields in
        -- addition to previously updated fields
           UPDATE OE_ORDER_LINES_ALL
           SET
             SCHEDULE_STATUS_CODE  = l_old_line_tbl(I).schedule_status_code,
             VISIBLE_DEMAND_FLAG   = l_old_line_tbl(I).visible_demand_flag,
             SCHEDULE_SHIP_DATE    = l_old_line_tbl(I).schedule_ship_date,
             SCHEDULE_ARRIVAL_DATE = l_old_line_tbl(I).schedule_arrival_date,
             SHIP_FROM_ORG_ID      = l_old_line_tbl(I).ship_from_org_id,
             SHIP_SET_ID           = l_old_set_tbl(I).ship_set_id,
             ARRIVAL_SET_ID        = l_old_set_tbl(I).arrival_set_id
           WHERE line_id = l_line_tbl(I).line_id;
        END IF;
        -- 4026758
        IF l_line_tbl(I).ship_set_id IS NOT NULL
           OR l_line_tbl(I).arrival_set_id IS NOT NULL THEN
           oe_schedule_util.Log_Delete_Set_Request
              (p_header_id   => l_line_tbl(I).header_id,
               p_line_id     => l_line_tbl(I).line_id,
               p_set_id      => nvl(l_line_tbl(I).ship_set_id,l_line_tbl(I).arrival_set_id),
               x_return_status => x_return_status);
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST '
                                 || X_RETURN_STATUS , 1 ) ;
           END IF;
        END IF;

        IF l_line_tbl(I).shipping_interfaced_flag = 'Y'
        AND l_line_tbl(I).Ordered_quantity > 0 THEN
         OE_Delayed_Requests_Pvt.Log_Request(
                 p_entity_code               =>  OE_GLOBALS.G_ENTITY_LINE,
                 p_entity_id                 =>  l_line_tbl(I).line_id,
                 p_requesting_entity_code    =>  OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id      =>  l_line_tbl(I).line_id,
                 p_request_type              =>  OE_GLOBALS.G_UPDATE_SHIPPING,
                 p_request_unique_key1       =>  OE_GLOBALS.G_OPR_UPDATE,
                 p_param1                    =>  FND_API.G_TRUE,
                 x_return_status             =>  x_return_status);
        END IF;
       END IF; -- Part of Model.
      END LOOP;
      -- 3384975
      IF l_param12 = 'N' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

     END IF; -- x_return_status = succ/error

  END IF;  -- If g_ret_status is error

  l_old_set_tbl.delete;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Exiting OE_Delayed_Requests_UTIL.Schedule_set_lines');
  END IF;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_old_set_tbl.delete;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from expected error',1);
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_set_lines'
            );
        END IF;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from unexpected error',1);
        END IF;

         l_old_set_tbl.delete;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_set_lines'
            );
        END IF;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from unexpected error',1);
        END IF;
        l_old_set_tbl.delete;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Schedule_set_lines;

/* ---------------------------------------------------------------
Procedure : Schedule_Set
Description:
p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
p_entity_id              => p_line_rec.line_id,
p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
p_requesting_entity_id   => p_line_rec.line_id,
p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
p_param1                 => l_param1,ship_set_id/arrival_set_id
p_param2                 => p_line_rec.header_id,
p_param3                 => l_action,
p_param4                 => p_old_line_rec.ship_from_org_id,
p_param5                 => p_old_line_rec.ship_to_org_id,
p_date_param1            => p_old_line_rec.schedule_ship_date,
p_date_param2            => p_old_line_rec.schedule_arrival_date,
p_date_param3            => p_old_line_rec.request_date,
p_param6                 => p_old_line_rec.ship_set_id,
p_param7                 => p_old_line_rec.arrival_set_id,
p_param8                 => l_entity_type,
p_param11                => l_shipping_method_code

Changes have been made to copy override_atp flag from model/class/
kit to it's included items when the flag is set. Code has been added to
cascade the override_atp flag to all the line in an ato model.
 ---------------------------------------------------------------*/
Procedure Schedule_Set(p_request_rec   IN  OE_ORDER_PUB.request_rec_type,
                       x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_tbl                    OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_line_rec                    OE_ORDER_PUB.line_rec_type;
l_old_line_rec                OE_ORDER_PUB.line_rec_type;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(2000);
l_set_rec                     OE_ORDER_CACHE.set_rec_type;
l_set_name                    VARCHAR2(30);
l_set_id                      NUMBER := null;
l_ship_set_id                 NUMBER := null;
l_arrival_set_id              NUMBER := null;

l_entity_type                 VARCHAR2(30);
l_action                      VARCHAR2(30);
l_line_id                     NUMBER;
l_header_id                   NUMBER;
l_old_schedule_ship_date      DATE   := Null;
l_old_schedule_arrival_date   DATE   := Null;
l_old_request_date            DATE   := Null;
l_old_ship_from_org_id        NUMBER := Null;
l_old_ship_set_id             NUMBER := Null;
l_old_arrival_set_id          NUMBER := Null;

l_set_Schedule_ship_date      DATE   := Null;
l_set_Schedule_arrival_date   DATE   := Null;
l_set_ship_to_org_id          NUMBER := Null;
l_set_ship_from_org_id        NUMBER := Null;

l_ship_to_org_id              NUMBER := NULL;
l_schedule_ship_date          DATE   := NULL;
l_schedule_arrival_date       DATE   := NULL;
l_ship_from_org_id            NUMBER := NULL;
l_request_date                DATE   := NULL;
l_shipping_method_code        VARCHAR2(30);
l_Freight_Carrier_Code        VARCHAR2(30);
l_shipment_priority_code      VARCHAR2(30);
l_can_bypass                  BOOLEAN := FALSE;
l_set_overridden              BOOLEAN := FALSE;
-- Start 2716220 --
l_override_ship_date          DATE   := NULL;
l_override_arrival_date       DATE   := NULL;
l_log_error                   BOOLEAN := FALSE;
l_operation                   VARCHAR2(30) := 'UPDATE';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
/* Added the following 2 line to fix the bug 2740480 */
l_push_logic                  VARCHAR2(1) := 'N';
l_date_changed                VARCHAR2(1) := 'N';

l_index                       NUMBER;
l_count			      NUMBER := 0;	     -- 5043206
l_org_id                      NUMBER ; --4241385
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SCHEDULE_SET' , 1 ) ;
  END IF;

  l_entity_type               := p_request_rec.param8;
  l_action                    := p_request_rec.param3;
  l_line_id                   := p_request_rec.entity_id;
  l_header_id                 := p_request_rec.param2;
  l_old_schedule_ship_date    := p_request_rec.date_param1;
  l_old_schedule_arrival_date := p_request_rec.date_param2;
  l_old_request_date          := p_request_rec.date_param3;
  l_old_ship_from_org_id      := p_request_rec.param4;
  l_old_ship_set_id           := p_request_rec.param6;
  l_old_arrival_set_id        := p_request_rec.param7;
  l_set_ship_to_org_id        := p_request_rec.param9;
  l_set_ship_from_org_id      := p_request_rec.param10;
/* Added the following 1 line to fix the bug 2740480 */
  l_push_logic                := nvl(p_request_rec.param13,'N');
  l_operation                 := p_request_rec.param14;
  l_set_schedule_ship_date    := p_request_rec.date_param4;
  l_set_schedule_arrival_date := p_request_rec.date_param5;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'L_OLD_SCHEDULE_SHIP_DATE :'
                          || L_OLD_SCHEDULE_SHIP_DATE , 1 ) ;
     oe_debug_pub.add(  'L_OLD_REQUEST_DATE :' || L_OLD_REQUEST_DATE , 1 ) ;
     oe_debug_pub.add(  'L_LINE_ID :' || L_LINE_ID , 1 ) ;
     oe_debug_pub.add(  'L_OLD_SHIP_SET_ID :' || L_OLD_SHIP_SET_ID , 1 ) ;
  END IF;

  Select Schedule_ship_date, Schedule_arrival_date,
         ship_to_org_id, ship_from_org_id, request_date,
         Ship_set_id,arrival_Set_id, org_id --4241385
  Into   l_Schedule_ship_date, l_Schedule_arrival_date,
         l_ship_to_org_id, l_ship_from_org_id, l_request_date,
         l_ship_set_id,l_arrival_set_id,l_org_id
  From   OE_ORDER_LINES_ALL
  Where  line_id = l_line_id;

  -- Schedule set lines is called it will have param4 as
  -- set date, use the same to schedule the line.

  IF  l_ship_set_id is null
  AND l_arrival_set_id is null
  THEN

     -- 5043206
     BEGIN

       IF p_request_rec.param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET  THEN

	  Select 1 into l_count from OE_ORDER_LINES_ALL
	    WHERE header_id = l_header_id and arrival_Set_id = p_request_rec.param1
		AND rownum = 1;

       ELSIF p_request_rec.param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET  THEN

	  Select 1 into l_count from OE_ORDER_LINES_ALL
	    WHERE header_id = l_header_id and ship_set_id = p_request_rec.param1
    		AND rownum = 1;

       END IF;

     EXCEPTION
        WHEN OTHERS THEN

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'No Records found after checking For Lines in set' , 1 ) ;
          END IF;

     END ;

	IF l_count = 0 THEN

	   -- Delalyed request is logged for set id and the same
	   -- is not available any more in the db. Do not process
	   -- the request.
	     goto END_OF_PROCESS;

     	END IF ;

  END IF;
/*
  IF  p_request_rec.date_param4 IS NOT NULL
  AND p_request_rec.date_param4 <> FND_API.G_MISS_DATE THEN
    l_Schedule_ship_date := p_request_rec.date_param4;
  END IF;
*/
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'L_SCHEDULE_SHIP_DATE :' || L_SCHEDULE_SHIP_DATE , 1 ) ;
    oe_debug_pub.add(  'L_REQUEST_DATE :' || L_REQUEST_DATE , 1 ) ;
    oe_debug_pub.add(  'L_LINE_ID :' || L_LINE_ID , 1 ) ;
    oe_debug_pub.add(  'L_SET_ID :' || L_SET_ID , 1 ) ;
  END IF;

  l_set_id           := p_request_rec.param1;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING QUERY_SET_LINES' , 1 ) ;
  END IF;
  BEGIN

   IF p_request_rec.param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET  THEN

     Oe_Config_Schedule_Pvt.Query_Set_Lines
      (p_header_id      => l_header_id,
       p_arrival_set_id => l_set_id,
       p_sch_action     => l_action,
       x_line_tbl       => l_line_tbl,
       x_return_status  => x_return_status);

   ELSIF p_request_rec.param8 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET  THEN

      Oe_Config_Schedule_Pvt.Query_Set_Lines
        (p_header_id     => l_header_id,
         p_ship_set_id   => l_set_id,
         p_sch_action    => l_action,
         x_line_tbl      => l_line_tbl,
         x_return_status  => x_return_status);

   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR AFTER CALLING QUERY_SET_LINES' , 1 ) ;
     END IF;
     goto END_OF_PROCESS;
  END;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING QUERY_SET_LINES' , 1 ) ;
      oe_debug_pub.add(  'COUNT IS ' || L_LINE_TBL.COUNT , 1 ) ;
  END IF;

  -- Start 2716220 --
   -- To check schedule dates with override flag
  IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509' THEN
   FOR I IN 1..l_line_tbl.count LOOP
     IF NVL(l_line_tbl(I).override_atp_date_code,'N') = 'Y'
        AND l_line_tbl(I).schedule_status_code is NULL
     THEN
        IF l_override_ship_date IS NULL THEN
           l_override_ship_date := l_line_tbl(I).schedule_ship_date;
        ELSIF l_line_tbl(I).schedule_ship_date <> l_override_ship_date THEN
           --  Dates are different,log the error
           l_log_error := TRUE;
           EXIT;
        END IF;
        IF l_override_arrival_date IS NULL THEN
           l_override_arrival_date := l_line_tbl(I).schedule_arrival_date;
        ELSIF l_line_tbl(I).schedule_arrival_date <> l_override_arrival_date THEN
           -- log the error
           l_log_error := TRUE;
           EXIT;
        END IF;
     END IF;
     IF NVL(l_line_tbl(I).override_atp_date_code,'N') = 'Y'
     AND NOT l_set_overridden THEN
         l_set_overridden := TRUE;
     END IF;
   END LOOP;

   IF l_log_error THEN
      FND_MESSAGE.SET_NAME('ONT','OE_SCH_OVER_ATP_SET_NO_MATCH');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      goto END_OF_PROCESS;
   END IF;
  END IF; -- code level.

   -- End 2716220 -

  -- Bypass if required.

  IF nvl(p_request_rec.param12,'N') = 'N' THEN
    l_set_rec := OE_ORDER_CACHE.Load_Set(l_set_id); --3878494

    FOR I IN 1..l_line_tbl.count LOOP

      IF l_line_tbl(I).schedule_status_code IS NULL OR
        (l_line_tbl(I).item_type_code <> OE_GLOBALS.G_ITEM_STANDARD AND
         nvl(l_line_tbl(I).model_remnant_flag,'N') = 'N') THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UNABLE TO BYPASS' , 2 ) ;
          END IF;
          l_can_bypass := FALSE;
          EXIT;

      END IF;
      -- following code commented for bug 3878494
      /*
      IF OE_SCHEDULE_UTIL.Set_Attr_Matched
          (p_set_ship_from_org_id    => l_line_tbl(1).ship_from_org_id ,
           p_line_ship_from_org_id   => l_line_tbl(I).ship_from_org_id,
           p_set_ship_to_org_id      => l_line_tbl(1).ship_to_org_id ,
           p_line_ship_to_org_id     => l_line_tbl(I).ship_to_org_id ,
           p_set_schedule_ship_date  => l_line_tbl(1).schedule_ship_date ,
           p_line_schedule_ship_date => l_line_tbl(I).schedule_ship_date,
           p_set_arrival_date        => l_line_tbl(1).schedule_arrival_date,
           p_line_arrival_date       => l_line_tbl(I).schedule_arrival_date,
           p_set_shipping_method_code    => l_line_tbl(1).shipping_method_code,
           p_line_shipping_method_code   => l_line_tbl(I).shipping_method_code,
           p_set_type                => p_request_rec.param8) THEN
      */

     -- Bug 6363297 starts
     -- Modified below logic for
     -- 1) If l_set_rec is blank it means all the lines are being added to a new Set.
     --    If all the Lines are already Scheduled and have the same attributes then no need to call MRP again.
     --    We can directly put the lines into the same Set.
     -- 2) If l_set_rec has values, it means lines are being added to an existing set or scheduling attributes
     --    of the lines that are part of the set are being changed.
     --    In that case compare the line attributes with that of Set attributes. If any change is found call MRP.
     IF l_set_rec.schedule_ship_date IS NULL THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('New Set is being created, comparing scheduling attributes with first line', 5);
        END IF;

        IF OE_SCHEDULE_UTIL.Set_Attr_Matched
          (p_set_ship_from_org_id      => l_line_tbl(1).ship_from_org_id ,
           p_line_ship_from_org_id     => l_line_tbl(I).ship_from_org_id,
           p_set_ship_to_org_id        => l_line_tbl(1).ship_to_org_id ,
           p_line_ship_to_org_id       => l_line_tbl(I).ship_to_org_id ,
           p_set_schedule_ship_date    => l_line_tbl(1).schedule_ship_date ,
           p_line_schedule_ship_date   => l_line_tbl(I).schedule_ship_date,
           p_set_arrival_date          => l_line_tbl(1).schedule_arrival_date,
           p_line_arrival_date         => l_line_tbl(I).schedule_arrival_date,
           p_set_shipping_method_code  => l_line_tbl(1).shipping_method_code,
           p_line_shipping_method_code => l_line_tbl(I).shipping_method_code,
           p_set_type                  => p_request_rec.param8)
        THEN
           l_can_bypass := TRUE;
        ELSE
           l_can_bypass := FALSE;
           EXIT;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Set already exists, comparing scheduling attributes with set', 5);
        END IF;

       -- following code added for bug 3878494
       IF OE_SCHEDULE_UTIL.Set_Attr_Matched
           (p_set_ship_from_org_id      => l_set_rec.ship_from_org_id ,
            p_line_ship_from_org_id     => l_line_tbl(I).ship_from_org_id,
            p_set_ship_to_org_id        => l_set_rec.ship_to_org_id ,
            p_line_ship_to_org_id       => l_line_tbl(I).ship_to_org_id ,
            p_set_schedule_ship_date    => l_set_rec.schedule_ship_date ,
            p_line_schedule_ship_date   => l_line_tbl(I).schedule_ship_date,
            p_set_arrival_date          => l_set_rec.schedule_arrival_date,
            p_line_arrival_date         => l_line_tbl(I).schedule_arrival_date,
            p_set_shipping_method_code  => l_set_rec.shipping_method_code,
            p_line_shipping_method_code => l_line_tbl(I).shipping_method_code,
            p_set_type                  => p_request_rec.param8) THEN
           l_can_bypass := TRUE;

       ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINES DID NOT MATCH' , 2 ) ;
           END IF;
           l_can_bypass := FALSE;
           EXIT;
       END IF;
     END IF;
     --Bug 6363297 ends
    END LOOP;


    IF l_can_bypass THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ALL LINES MATCH WITH SET DATES , BYPASS MRP CALL' , 2 ) ;
       END IF;
       GOTO BYPASS_PROCESS;

    END IF;

  END IF; -- param12.

  -- End of bypass

  l_old_line_tbl := l_line_tbl;

  FOR  I IN 1..l_old_line_tbl.count LOOP

       IF l_old_line_tbl(1).schedule_status_code is null THEN

         l_old_line_tbl(I).schedule_ship_date := null;
         l_old_line_tbl(I).schedule_arrival_date := null;
   --      l_old_line_tbl(I).ship_set_id := null;
   --      l_old_line_tbl(I).arrival_set_id := null;

       ELSE
         IF l_old_line_tbl(I).line_id = l_line_id THEN
        /* l_old_line_tbl(I).ship_set_id :=
                              l_old_ship_set_id;
         l_old_line_tbl(I).arrival_set_id :=
                              l_old_arrival_set_id;
       */
         IF l_old_schedule_ship_date is not null THEN
            l_old_line_tbl(I).schedule_ship_date :=
                              l_old_schedule_ship_date;
         END IF;
         IF l_old_schedule_arrival_date is not null THEN
            l_old_line_tbl(I).schedule_arrival_date :=
                              l_old_schedule_arrival_date;
         END IF;

         IF l_old_ship_from_org_id is not null THEN

            l_old_line_tbl(I).ship_from_org_id :=
                               l_old_ship_from_org_id;
         END IF;
         END IF;
       END IF;


    -- BUG 1282873 (Override Atp)
       IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110509'
       AND nvl(l_line_tbl(I).override_atp_date_code,'N') = 'N'   THEN

         IF  (l_line_tbl(I).ato_line_id is not null AND
         NOT (l_line_tbl(I).ato_line_id = l_line_tbl(I).line_id AND
              l_line_tbl(I).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                               OE_GLOBALS.G_ITEM_OPTION)))
         THEN

            BEGIN

              Select override_atp_date_code
              Into   l_line_tbl(I).override_atp_date_code
              From   oe_order_lines_all
              Where  header_id = l_line_tbl(I).header_id
              And    ato_line_id = l_line_tbl(I).ato_line_id
              And    override_atp_date_code = 'Y'
              And    rownum < 2;

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ato override flag :' || l_line_tbl ( I ) .override_atp_date_code , 3 ) ;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                   Null;

            END;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'override_atp for ato :' || L_LINE_TBL ( I ) .OVERRIDE_ATP_DATE_CODE || L_LINE_TBL ( I ) .LINE_ID , 3 ) ;
            END IF;
         ELSIF l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN


            BEGIN


                Select override_atp_date_code
                Into   l_line_tbl(I).override_atp_date_code
                From   oe_order_lines_all
                Where  header_id = l_line_tbl(I).header_id
                And    line_id = l_line_tbl(I).link_to_line_id;

                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'INC OVERRIDE FLAG :' || L_LINE_TBL ( I ) .OVERRIDE_ATP_DATE_CODE , 3 ) ;
                END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  Null;

            END;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'override_atp for inc :' || L_LINE_TBL ( I ) .OVERRIDE_ATP_DATE_CODE || L_LINE_TBL ( I ) .LINE_ID , 3 ) ;
            END IF;
         END IF; -- Ato/included.
       END IF; -- Check for pack I
    -- END 1282873
  END LOOP;
  IF l_entity_type = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET THEN

      l_set_rec := OE_ORDER_CACHE.Load_Set(l_set_id);
      l_set_name := l_set_rec.set_name;

       FOR I IN 1..l_line_tbl.count LOOP

           l_line_tbl(I).ship_set :=  l_set_name;
           l_line_tbl(I).schedule_action_code := l_action;

           /* Added for Bug 6250075 */
           l_line_tbl(I).change_reason := 'SYSTEM';
           l_line_tbl(I).change_comments := 'Delayed Request , Scheduling';
           /* End of Bug 6250075 */

           IF fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET') = 'Y' THEN
              oe_debug_pub.add('ONT_SHIP_METHOD_FOR_SHIP_SET: ' || p_request_rec.param11,2);
              l_line_tbl(I).shipping_method_code  := p_request_rec.param11;
           END IF;
           -- l_line_tbl(I).shipping_method_code := p_request_rec.param11;
/* Commented the above line to fix the bug 2916814 */
       /*    -- 2716220
           IF l_line_tbl(I).override_atp_date_code = 'Y' AND
              l_line_tbl(I).schedule_status_code is NULL THEN
              -- Donot cascade the scheduling attributes since it is overridden line .
              null;
           ELSE
*/
           IF l_set_ship_to_org_id is not null THEN
               l_line_tbl(I).ship_to_org_id := l_set_ship_to_org_id;
           ELSIF (l_ship_to_org_id is not null) THEN
                 l_line_tbl(I).ship_to_org_id := l_ship_to_org_id;
           END IF;

           IF l_set_ship_from_org_id is not null THEN
                 l_line_tbl(I).ship_from_org_id :=
                                    l_set_ship_from_org_id;
           ELSIF (l_ship_from_org_id is not null) THEN
                 l_line_tbl(I).ship_from_org_id :=
                                    l_ship_from_org_id;
           END IF;

           IF l_line_tbl(I).ship_from_org_id IS NOT NULL THEN

              l_line_tbl(I).re_source_flag := 'N';
           END IF;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'REQUEST DATE :' || L_REQUEST_DATE , 1 ) ;
           END IF;

           -- Start 2787962
           IF  l_line_tbl(I).top_model_line_id is not null
           AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT) )
           AND oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
           THEN
               l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).date_attribute1;
           ELSIF l_line_tbl(I).ato_line_id is not null
           AND   NOT(l_line_tbl(I).ato_line_id = l_line_tbl(I).line_id
           AND   l_line_tbl(I).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD, OE_GLOBALS.G_ITEM_OPTION))
           AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT) )
           AND  oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
           THEN
                 l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).date_attribute1;
           ELSIF  l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
           AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT) )
           AND oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
           THEN
                l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT)).date_attribute1;

           END IF;
           -- End 2787962

           IF (l_request_date is not null
               AND NOT OE_GLOBALS.Equal( l_request_date,
                                         l_old_request_date)) THEN

               IF NOT l_set_overridden THEN
                 --4483035
                 --l_line_tbl(I).schedule_ship_date := l_request_date;
                 --4929511
                   IF l_line_tbl(I).schedule_status_code is NULL
                      AND l_line_tbl(I).schedule_ship_date IS NULL THEN
                       l_line_tbl(I).schedule_ship_date := l_line_tbl(I).request_date;
                   END IF;
               END IF;

           --    l_line_tbl(I).request_date := l_request_date; 2787962

           END IF;

           IF l_set_schedule_ship_date is not null THEN
                 l_line_tbl(I).schedule_ship_date :=
                                    l_set_schedule_ship_date;
           -- 4929511 :Commented
           /*
           ELSIF (l_schedule_ship_date is not null
           AND NOT OE_GLOBALS.Equal( l_schedule_ship_date,
                                     l_old_schedule_ship_date)) THEN
                 l_line_tbl(I).schedule_ship_date :=
                                    l_schedule_ship_date;
           */
           END IF;

           IF l_line_tbl(I).schedule_ship_date is null THEN
                 l_line_tbl(I).schedule_ship_date := l_line_tbl(I).request_date;
           END IF;

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'request ship date :' || L_LINE_TBL ( I ) .SCHEDULE_SHIP_DATE , 1 ) ;
           END IF;


           IF l_set_schedule_arrival_date is not null  THEN
                 l_line_tbl(I).schedule_arrival_date :=
                                    l_set_schedule_arrival_date;
           -- 4929511 :Commented
           /*
           ELSIF (l_schedule_arrival_date is not null
           AND NOT OE_GLOBALS.Equal( l_schedule_arrival_date,
                                     l_old_schedule_arrival_date)) THEN
                 l_line_tbl(I).schedule_arrival_date :=
                                    l_schedule_arrival_date;
           */
           END IF;
 --          END IF; -- 2716220

           l_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('request date :' || l_line_tbl(i).request_date , 1 ) ;
             oe_debug_pub.add('schedule_ship_date :' || l_line_tbl(I).schedule_ship_date , 1 ) ;
             oe_debug_pub.add('schedule_arrival_date :' || l_line_tbl(I).schedule_arrival_date , 1 ) ;
             oe_debug_pub.add('ship_from_org_id :' || l_line_tbl(I).ship_from_org_id , 1 ) ;
           END IF;
       END LOOP;
  END IF; -- Ship Set

  IF l_entity_type =
               OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET THEN

       l_set_rec := OE_ORDER_CACHE.Load_Set(l_set_id);
       l_set_name := l_set_rec.set_name;

           /* Added for Bug 6250075 */
           /*
           Bug 6309823
           Moved this piece of code added through bug 6250075 into the below FOR loop
           l_line_tbl(I).change_reason := 'SYSTEM';
           l_line_tbl(I).change_comments := 'Delayed Request , Scheduling';
           */
           /* End of Bug 6250075 */

       FOR I IN 1..l_line_tbl.count LOOP

             l_line_tbl(I).arrival_set :=  l_set_name;
             l_line_tbl(I).schedule_action_code := l_action;

             --Bug 6309823
             l_line_tbl(I).change_reason := 'SYSTEM';
             l_line_tbl(I).change_comments := 'Delayed Request , Scheduling';

             -- 2716220
   /*          IF l_line_tbl(I).override_atp_date_code = 'Y' AND
                l_line_tbl(I).schedule_status_code is NULL THEN
                -- Donot cascade the scheduling attributes since it is overridden line .
                null;
             ELSE
*/

             IF l_set_ship_to_org_id is not null THEN
                 l_line_tbl(I).ship_to_org_id := l_set_ship_to_org_id;
             ELSIF l_ship_to_org_id is not null THEN
                 l_line_tbl(I).ship_to_org_id := l_ship_to_org_id;
             END IF;

              -- Start 2787962
             IF  l_line_tbl(I).top_model_line_id is not null
            AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT) )
            AND oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
            THEN
                  l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).date_attribute1;
            ELSIF l_line_tbl(I).ato_line_id is not null
            AND   NOT(l_line_tbl(I).ato_line_id = l_line_tbl(I).line_id
            AND   l_line_tbl(I).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD, OE_GLOBALS.G_ITEM_OPTION))
            AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT) )
            AND  oe_schedule_util.OE_sch_Attrb_Tbl (mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
            THEN
                  l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).date_attribute1;
            ELSIF  l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED
            AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT) )
            AND oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT)).date_attribute1 is not null
            THEN
                  l_line_tbl(I).request_date := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).link_to_line_id, G_BINARY_LIMIT)).date_attribute1;

            END IF;
            -- End 2787962

            -- Start 2391781
           IF  NVL(l_line_tbl(I).Ship_model_complete_flag,'N') = 'Y'
            AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT) )
            AND oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).attribute1 is not null
            THEN
                  l_line_tbl(I).Ship_from_org_id := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).top_model_line_id, G_BINARY_LIMIT)).attribute1;
            ELSIF l_line_tbl(I).ato_line_id is not null
            AND   NOT(l_line_tbl(I).ato_line_id = l_line_tbl(I).line_id
            AND   l_line_tbl(I).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                                   OE_GLOBALS.G_ITEM_OPTION))
            AND oe_schedule_util.OE_sch_Attrb_Tbl.EXISTS(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT) )
            AND  oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).attribute1 is not null
            THEN
                  l_line_tbl(I).Ship_from_org_id := oe_schedule_util.OE_sch_Attrb_Tbl(mod(l_line_tbl(I).ato_line_id, G_BINARY_LIMIT)).attribute1;
            END IF;

            -- 2391781

             IF (l_request_date is not null
             AND NOT OE_GLOBALS.Equal( l_request_date,
                                       l_old_request_date)) THEN
                 IF NOT l_set_overridden THEN
                   --4483035
                   --l_line_tbl(I).schedule_arrival_date := l_request_date;
                    --4929511
                    IF l_line_tbl(I).schedule_status_code is NULL
                      AND l_line_tbl(I).schedule_arrival_date IS NULL THEN
                      l_line_tbl(I).schedule_arrival_date := l_line_tbl(I).request_date;
                    END IF;
                 END IF;
                -- l_line_tbl(I).request_date := l_request_date; 2787962
             END IF;

             IF l_set_schedule_arrival_date is not null THEN
                 l_line_tbl(I).schedule_arrival_date :=
                                             l_set_schedule_arrival_date;
             --4929511 : Commented
             /*
             ELSIF (l_schedule_arrival_date is not null
             AND NOT OE_GLOBALS.Equal( l_schedule_arrival_date,
                                       l_old_schedule_arrival_date)) THEN
                 l_line_tbl(I).schedule_arrival_date := l_schedule_arrival_date;
             */
             END IF;

             IF l_line_tbl(I).schedule_arrival_date is null THEN
                 l_line_tbl(I).schedule_arrival_date :=
                                      l_line_tbl(I).request_date;
             END IF;
             IF l_set_schedule_ship_date is not null  THEN  -- 3281742
                 l_line_tbl(I).schedule_ship_date :=
                                    l_set_schedule_ship_date;
             --4929511 : Commented
             /*
             ELSIF (l_schedule_ship_date is not null
              AND NOT OE_GLOBALS.Equal( l_schedule_ship_date,
                                     l_old_schedule_ship_date)) THEN
                 l_line_tbl(I).schedule_ship_date :=
                                    l_schedule_ship_date;
             */
             END IF;
 --            END IF; -- 2716220

             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'REQUEST ARRIVAL DATE :' || L_LINE_TBL ( I ) .SCHEDULE_ARRIVAL_DATE , 1 ) ;
             END IF;


             l_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

       END LOOP;
  END IF;

 -- Start 2391781
 --- Deleteing delayed request of type cascade_warehous
  l_index   := oe_schedule_util.OE_sch_Attrb_Tbl.FIRST;
  WHILE l_index is not null
  LOOP
      IF oe_schedule_util.OE_sch_Attrb_Tbl(l_index).set_id =l_set_id
      THEN
         oe_schedule_util.OE_sch_Attrb_Tbl.delete(l_index);
      END IF;
      l_index := oe_schedule_util.OE_sch_Attrb_Tbl.NEXT(l_index);
  END LOOP;

  -- End 2391781

  IF OE_SCHEDULE_UTIL.OE_Override_Tbl.count > 0 THEN
     FOR I IN 1..l_line_tbl.count LOOP

      IF OE_SCHEDULE_UTIL.OE_Override_Tbl.EXISTS
                         (l_line_tbl(I).line_id) THEN

         OE_SCHEDULE_UTIL.OE_Override_Tbl.delete
                         (l_line_tbl(I).line_id);

      END IF;

     END LOOP;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING PROCESS_GROUP' , 1 ) ;
  END IF;

  IF l_line_tbl.count > 0 THEN


     Validate_Group
     (p_x_line_tbl    => l_line_tbl,
      p_sch_action    => l_action,
      x_return_status => x_return_status);

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING Validate Group ' || X_RETURN_STATUS
            || l_line_tbl.count || ':' || l_old_line_tbl.count , 1 ) ;
  END IF;

  IF l_line_tbl.count <> l_old_line_tbl.count THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
  END IF;

/*
  Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'SET'
       ,p_sch_action     => l_action
       ,x_return_status  => x_return_status);
*/
/* Commented the above code and added the following code to fix the bug 2740480 */
  IF l_push_logic = 'Y' THEN

  oe_debug_pub.add('2740480: Push logic is set to Y ',2);
  Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'SET'
       ,p_sch_action     => l_action
       ,p_partial_set    => TRUE
       ,x_return_status  => x_return_status);

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add('2740480: After call to Process Group :' || x_return_status ,1);
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('2740480: Compare output with requested values',1);
     END IF;

    FOR I IN 1..l_line_tbl.count LOOP
      oe_debug_pub.add('2740480: Entity type : '|| l_entity_type);
      oe_debug_pub.add('2740480: line schedule ship date : '|| l_line_tbl(I).Schedule_ship_date);
      oe_debug_pub.add('2740480: set schedule ship date :  '|| l_set_rec.Schedule_ship_date );
      IF  l_entity_type = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
      AND trunc(l_line_tbl(I).Schedule_ship_date) <> trunc(l_set_rec.Schedule_ship_date)
      THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('2740480: Not received correct values for ship set',1);
         END IF;
           l_date_changed := 'Y' ;
           EXIT;
      ELSIF  l_entity_type = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
      AND    trunc(l_line_tbl(I).Schedule_arrival_date) <> trunc(l_set_rec.Schedule_arrival_date)
      THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('2740480: Not received correct values for arrival set',1);
         END IF;
           l_date_changed  := 'Y' ;
           EXIT;
      END IF;

    END LOOP;
    IF l_date_changed = 'N' THEN
      GOTO BYPASS_PROCESS;
    END IF;

   END IF; -- Success.

   IF fnd_profile.value('ONT_AUTO_PUSH_GRP_DATE') = 'Y' THEN

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('2740480: Auto Push Group Date is Yes',2);
      END IF;
      goto Push;
   ELSE

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Before setting message for group failure',2);
        END IF;

       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_GROUP_MEMBER_FAILED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

   END IF;

  END IF; -- Push logic ends here.

  <<PUSH>>

  oe_debug_pub.add('2740480: Push logic is set to N ',2);
  Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'SET'
       ,p_sch_action     => l_action
       ,x_return_status  => x_return_status);

/* End of code for the bug fix 2740480 */


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING PROCESS_GROUP' || X_RETURN_STATUS , 1 ) ;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
--          RAISE FND_API.G_EXC_ERROR;

     -- Code added for bug 2812346

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('l_operation :' || l_operation,2);
        oe_debug_pub.add('l_set_rec.set_status :' || l_set_rec.set_status,2);
     END IF;
     IF l_operation = OE_GLOBALS.G_OPR_CREATE
     AND l_set_rec.set_status = 'T' THEN
     -- Could not schedule the line on the set date. Let's schedule
     -- the whole set to see if we get another date got the whole
     -- set.
    --4241385
    /* checking the if condition, so that lines will not be removed from the set,
    if scheduling fails, in case auto scheduling is turned on.*/
    IF NVL(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',l_org_id),'Y')='Y' THEN
      FOR I IN 1..l_line_tbl.count LOOP

        -- IF l_line_tbl(I).schedule_status_code IS NULL --commented for bug3986288
        -- THEN
        -- uncommented for bug 4188166
        IF l_line_tbl(I).schedule_status_code IS NULL OR
           l_old_line_tbl(I).schedule_status_code IS NULL
        THEN

         IF l_line_tbl(I).top_model_line_id is null
         OR l_line_tbl(I).top_model_line_id =
                 l_line_tbl(I).line_id
         OR (l_line_tbl(I).top_model_line_id is not null
         AND l_line_tbl(I).top_model_line_id <> l_line_tbl(I).line_id
         AND Not_part_of_set(l_line_tbl(I).top_model_line_id))
         THEN

           UPDATE OE_ORDER_LINES_ALL
           SET SCHEDULE_SHIP_DATE  = Null,
             SCHEDULE_ARRIVAL_DATE = Null,
             SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
             SHIP_SET_ID           = Null,
             ARRIVAL_SET_ID        = Null,
             override_atp_date_code = Null
           WHERE line_id = l_line_tbl(I).line_id;

           -- 4026758
           IF l_line_tbl(I).ship_set_id IS NOT NULL
              OR l_line_tbl(I).arrival_set_id IS NOT NULL THEN
              oe_schedule_util.Log_Delete_Set_Request
                 (p_header_id   => l_line_tbl(I).header_id,
                  p_line_id     => l_line_tbl(I).line_id,
                  p_set_id      => nvl(l_line_tbl(I).ship_set_id,l_line_tbl(I).arrival_set_id),
                  x_return_status => x_return_status);
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST ' || X_RETURN_STATUS , 1 ) ;
              END IF;
           END IF;

         ELSE

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Model is part of a set cannot save  ' ,2);
          END IF;

          RAISE  FND_API.G_EXC_ERROR;
         END IF;
         END IF; -- bug 4188166
--        END IF;  --commented for bug3986288
      END LOOP;
      ELSE
        l_set_rec.set_status := 'A'; --4241385
      END IF ; --4241385

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('It is a create operation  ' ,2);
        END IF;
        fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
        oe_debug_pub.add('x_return_status ' || x_return_status,2);
        END IF;
        GOTO END_OF_PROCESS;
     ELSE  -- Create
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('It is not a create operation  ' ,2);
        END IF;

        RAISE  FND_API.G_EXC_ERROR;
     END IF; -- Create.
  END IF;

  -- If scheduling set suceeded, then the result of scheduling
  -- have been updated to the database. Will query one of the lines
  -- of the set to see the change is set attributes so that we can
  -- update the set itself.
/*
  l_old_line_rec := l_old_line_tbl(1);
  OE_Line_Util.Query_Row( p_line_id   =>  l_old_line_rec.line_id,
                          x_line_rec  =>  l_line_rec);

   -- Update the set attributes.

  l_ship_from_org_id      := l_line_rec.ship_from_org_id;
  l_ship_to_org_id        := l_line_rec.ship_to_org_id;
  l_schedule_ship_date    := l_line_rec.schedule_ship_date;
  l_schedule_arrival_date := l_line_rec.schedule_arrival_date;
  l_shipping_method_code  := l_line_rec.shipping_method_code;
*/

  <<BYPASS_PROCESS>>
  BEGIN
/* Removed the shipping_method_code from the following select to fix the bug 2916814 */
   Select ship_from_org_id, ship_to_org_id, schedule_ship_date,
          schedule_arrival_date,Shipping_Method_Code,
          Freight_Carrier_Code,shipment_priority_code
   INTO   l_ship_from_org_id,l_ship_to_org_id,l_schedule_ship_date,
          l_schedule_arrival_date,l_Shipping_Method_Code,
          l_Freight_Carrier_Code,l_shipment_priority_code
   From   oe_order_lines_all
   Where  line_id  = l_line_tbl(1).line_id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING UPDATE SET' ) ;
    END IF;

    OE_Set_Util.Update_Set
        (p_Set_Id                   => l_set_id,
         p_Ship_From_Org_Id         => l_Ship_From_Org_Id,
         p_Ship_To_Org_Id           => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date       => l_Schedule_Ship_Date,
         p_Schedule_Arrival_Date    => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code     => l_Freight_Carrier_Code,
         p_Shipping_Method_Code     => l_Shipping_Method_Code,
         p_shipment_priority_code   => l_shipment_priority_code,
         X_Return_Status            => x_return_status,
         x_msg_count                => l_msg_count,
         x_msg_data                 => l_msg_data
        );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING UPDATE SET' ) ;
    END IF;

  EXCEPTION
   WHEN OTHERS THEN
     Null;
  END;
  <<END_OF_PROCESS>>
    G_TOP_MODEL_LINE_ID := Null;
    G_PART_OF_SET       := Null;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Exiting Schedule_Set',1);
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     --3543774 If new set show the error message
     IF p_request_rec.request_type = OE_GLOBALS.G_GROUP_SCHEDULE
      AND ((l_entity_type =
               OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
       AND NOT OE_GLOBALS.equal(l_ship_set_id,l_old_ship_set_id))
      OR (l_entity_type =
               OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
        AND NOT OE_GLOBALS.equal(l_arrival_set_id,l_old_arrival_set_id)))
     THEN
      fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
      OE_MSG_PUB.Add;
     END IF;
      G_TOP_MODEL_LINE_ID := Null;
      G_PART_OF_SET       := Null;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        G_TOP_MODEL_LINE_ID := Null;
        G_PART_OF_SET       := Null;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        G_TOP_MODEL_LINE_ID := Null;
        G_PART_OF_SET       := Null;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_Set'
            );
        END IF;
END Schedule_Set;
/***************************************************
Procedure Group_Schedule_sets has been written to take care
of set_for_each_line project.

p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
p_entity_id              => nvl(p_line_rec.ship_set_id,p_line_rec.arrival_set_
id),
p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
p_requesting_entity_id   => p_line_rec.line_id,
p_request_type           => OE_GLOBALS.G_GROUP_SET,
p_param1                 => l_set_type,
p_param2                 => p_line_rec.header_id,
p_param3                 => p_line_rec.line_id,
p_param4                 => p_line_rec.top_model_line_id,
p_param5                 => p_line_rec.ship_to_org_id,    -- added for bug 4188166
p_param6                 => p_line_rec.ship_from_org_id,  -- added for bug 4188166
x_return_status          => x_return_status);


****************************************************/

Procedure Group_Schedule_sets
( p_sch_set_tbl     IN  OE_ORDER_PUB.request_tbl_type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_tbl           OE_ORDER_PUB.line_Tbl_type;
l_old_line_tbl       OE_ORDER_PUB.line_Tbl_type;
l_sch_line_tbl       OE_ORDER_PUB.line_Tbl_type;
l_count              NUMBER := 0;
l_set_rec            OE_ORDER_CACHE.set_rec_type;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_set_exists         VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING Group_Schedule_sets' , 1 ) ;
  END IF;

  FOR I in 1..p_sch_set_tbl.count LOOP
    l_set_exists := 'Y';

    IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'Processing Line' || P_SCH_SET_TBL(I).ENTITY_ID, 1);
    END IF;

     l_return_status    := FND_API.G_RET_STS_SUCCESS;

      BEGIN

       Select 'Y'
       Into  l_set_exists
         From   oe_order_lines_all
         Where  header_id = p_sch_set_tbl(I).param2
         And    (ship_set_id = p_sch_set_tbl(I).entity_id
         Or     arrival_set_id = p_sch_set_tbl(I).entity_id)
         And    open_flag = 'Y'
         And    rownum = 1;

         IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Lines exists in the set', 2);
         END IF;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN

          l_set_exists := 'N';
        WHEN OTHERS THEN
          l_set_exists := 'Y';
      END;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Before quering the date ' || l_set_exists, 2);
       END IF;
     IF l_set_exists = 'N' THEN
        GOTO END_PROCESS;
     END IF;
     IF p_sch_set_tbl(I).param1 = OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET
     THEN
        Oe_Config_Schedule_Pvt.Query_Set_Lines
        (p_header_id      => p_sch_set_tbl(I).param2,
         p_arrival_set_id => p_sch_set_tbl(I).entity_id,
         p_sch_action     => 'SCHEDULE',
         x_line_tbl       => l_line_tbl,
         x_return_status  => l_return_status);


     ELSIF p_sch_set_tbl(I).param1 = OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET
     THEN

      Oe_Config_Schedule_Pvt.Query_Set_Lines
        (p_header_id     => p_sch_set_tbl(I).param2,
         p_ship_set_id   => p_sch_set_tbl(I).entity_id,
         p_sch_action    => 'SCHEDULE',
         x_line_tbl      => l_line_tbl,
         x_return_status  => l_return_status);

     END IF;

     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' L_return_status :' || l_return_status,1);
     END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(' Goto End due to error',1);
       END IF;
       GOTO END_PROCESS;
     END IF;

     FOR J IN 1..l_line_tbl.count LOOP

      OE_SCHEDULE_UTIL.Validate_Line(p_line_rec   => l_line_tbl(J),
                                  p_old_line_rec  => l_line_tbl(J),
                                  p_sch_action    => 'SCHEDULE' ,
                                  x_return_status => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(' Error in validation ',1);
         END IF;
         GOTO END_PROCESS;
      END IF;

     END LOOP;

     l_count := l_sch_line_tbl.count;
     FOR J IN 1..l_line_tbl.count LOOP

        l_count := l_count + 1;

        l_sch_line_tbl(l_count) := l_line_tbl(J);
        l_old_line_tbl(l_count) := l_line_tbl(J);

        l_sch_line_tbl(l_count).schedule_action_code := 'SCHEDULE';
        l_sch_line_tbl(l_count).operation := 'UPDATE';

        /* Added for Bug 6250075 */
        l_sch_line_tbl(l_count).change_reason := 'SYSTEM';
        l_sch_line_tbl(l_count).change_comments := 'Delayed Request , Scheduling';
        /* End of Bug 6250075 */

        IF nvl(l_line_tbl(J).override_atp_date_code,'N') = 'N'
        AND (l_line_tbl(J).ato_line_id is not null AND
        NOT (l_line_tbl(J).ato_line_id = l_line_tbl(J).line_id AND
             l_line_tbl(J).item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                               OE_GLOBALS.G_ITEM_OPTION)))
        THEN

            BEGIN

              Select override_atp_date_code,
                     schedule_ship_date,
                     schedule_arrival_date
              Into   l_sch_line_tbl(l_count).override_atp_date_code,
                     l_sch_line_tbl(l_count).schedule_ship_date,
                     l_sch_line_tbl(l_count).schedule_arrival_date
              From   oe_order_lines_all
              Where  header_id = l_line_tbl(J).header_id
              And    ato_line_id = l_line_tbl(J).ato_line_id
              And    override_atp_date_code = 'Y'
              And    rownum < 2;

            EXCEPTION
              WHEN OTHERS THEN
                   Null;

            END;
        END IF;


        IF (l_line_tbl(J).arrival_set_id is not null) THEN

           l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( l_line_tbl(J).arrival_set_id);
           l_sch_line_tbl(l_count).arrival_set   := l_set_rec.set_name;
           -- 4188166
           IF p_sch_set_tbl(I).param5 IS NOT NULL THEN --5151954
              l_sch_line_tbl(l_count).ship_to_org_id := p_sch_set_tbl(I).param5;
           END IF;

        ELSIF (l_line_tbl(J).ship_set_id is not null) THEN

           l_set_rec := OE_ORDER_CACHE.Load_Set
                             ( l_line_tbl(J).Ship_set_id);
           l_sch_line_tbl(l_count).ship_set      := l_set_rec.set_name;
           -- 4188166
           IF p_sch_set_tbl(I).param5 IS NOT NULL THEN --5151954
              l_sch_line_tbl(l_count).ship_to_org_id := p_sch_set_tbl(I).param5;
           END IF;

           IF p_sch_set_tbl(I).param6 IS NOT NULL THEN --5151954
              l_sch_line_tbl(l_count).ship_from_org_id := p_sch_set_tbl(I).param6;
           END IF;
        END IF;


     END LOOP; -- lsch_tbl

   <<END_PROCESS>>

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(' Error in ' || p_sch_set_tbl(I).param1,2);
      END IF;

      IF p_sch_set_tbl(I).param4  is null
      THEN
         UPDATE OE_ORDER_LINES_ALL
         SET SCHEDULE_SHIP_DATE  = Null,
         SCHEDULE_ARRIVAL_DATE = Null,
         SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
         SHIP_SET_ID           = Null,
         ARRIVAL_SET_ID        = Null,
         OVERRIDE_ATP_DATE_CODE = Null
         WHERE line_id = p_sch_set_tbl(I).param3;
       ELSE

        UPDATE OE_ORDER_LINES_ALL
         SET SCHEDULE_SHIP_DATE  = Null,
         SCHEDULE_ARRIVAL_DATE = Null,
         SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
         SHIP_SET_ID           = Null,
         ARRIVAL_SET_ID        = Null,
         OVERRIDE_ATP_DATE_CODE = Null
         WHERE top_model_line_id  = p_sch_set_tbl(I).param4;
      END IF;
      -- 4026758
      IF l_sch_line_tbl(I).ship_set_id IS NOT NULL
     OR l_sch_line_tbl(I).arrival_set_id IS NOT NULL THEN
     oe_schedule_util.Log_Delete_Set_Request
        (p_header_id   => l_sch_line_tbl(I).header_id,
         p_line_id     => l_sch_line_tbl(I).line_id,
         p_set_id      => nvl(l_sch_line_tbl(I).ship_set_id,l_sch_line_tbl(I).arrival_set_id),
         x_return_status => x_return_status);
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER LOGGING DELETE SETS DELAYED REQUEST '
                   || X_RETURN_STATUS , 1 ) ;
     END IF;
      END IF;
    END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Process next set :' || l_sch_line_tbl.count,1);
    END IF;

  END LOOP; -- Main loop.

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Line Count :' || l_sch_line_tbl.count,1);
  END IF;

  IF l_sch_line_tbl.count > 0 THEN

     Oe_Config_Schedule_Pvt.Process_Group
       (p_x_line_tbl     => l_sch_line_tbl
       ,p_old_line_tbl   => l_old_line_tbl
       ,p_caller         => 'SET'
       ,p_sch_action     => OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE
       ,p_partial        => TRUE
       ,x_return_status  => x_return_status);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('After call to Process Group :' || x_return_status ,1);
  END IF;
       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END IF;


  FOR I IN 1..l_sch_line_tbl.count LOOP

    oe_debug_pub.add('line id  :' || l_sch_line_tbl(I).line_id ,1);
    oe_debug_pub.add('Schedule status code  :' || l_sch_line_tbl(I).schedule_status_code ,1);

    -- 4188166
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       l_sch_line_tbl(I).schedule_status_code IS NOT NULL
    THEN

        /*
        IF l_sch_line_tbl(I).schedule_status_code IS NULL
        THEN

          IF l_sch_line_tbl(I).top_model_line_id is NULL THEN
           UPDATE OE_ORDER_LINES_ALL
           SET SCHEDULE_SHIP_DATE  = Null,
           SCHEDULE_ARRIVAL_DATE = Null,
           SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
           SHIP_SET_ID           = Null,
           ARRIVAL_SET_ID        = Null,
           OVERRIDE_ATP_DATE_CODE = Null
           WHERE line_id = l_sch_line_tbl(I).line_id;
          ELSE
           UPDATE OE_ORDER_LINES_ALL
           SET SCHEDULE_SHIP_DATE  = Null,
           SCHEDULE_ARRIVAL_DATE = Null,
           SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
           SHIP_SET_ID           = Null,
           ARRIVAL_SET_ID        = Null,
           OVERRIDE_ATP_DATE_CODE = Null
           WHERE top_model_line_id = l_sch_line_tbl(I).top_model_line_id;
          END IF;

        ELSIF l_sch_line_tbl(I).line_id = l_sch_line_tbl(I).top_model_line_id
        OR    l_sch_line_tbl(I).top_model_line_id is NULL THEN
        */

        IF l_sch_line_tbl(I).line_id = l_sch_line_tbl(I).top_model_line_id
        OR    l_sch_line_tbl(I).top_model_line_id is NULL THEN

        OE_Set_Util.Update_Set
        (p_Set_Id                   => Nvl(l_sch_line_tbl(I).arrival_Set_id,
                               l_sch_line_tbl(I).ship_Set_id),
        p_Ship_From_Org_Id         => l_sch_line_tbl(I).Ship_From_Org_Id,
        p_Ship_To_Org_Id           => l_sch_line_tbl(I).Ship_To_Org_Id,
        p_Schedule_Ship_Date       => l_sch_line_tbl(I).Schedule_Ship_Date,
        p_Schedule_Arrival_Date    => l_sch_line_tbl(I).Schedule_Arrival_Date,
        p_Freight_Carrier_Code     => l_sch_line_tbl(I).Freight_Carrier_Code,
        p_Shipping_Method_Code     => l_sch_line_tbl(I).Shipping_Method_Code,
        p_shipment_priority_code   => l_sch_line_tbl(I).shipment_priority_code,
        X_Return_Status            => x_return_status,
        x_msg_count                => l_msg_count,
        x_msg_data                 => l_msg_data
        );

        END IF;
    ELSE -- Return status has error (4188166)

        IF l_sch_line_tbl(I).top_model_line_id is null
        OR l_sch_line_tbl(I).top_model_line_id = l_sch_line_tbl(I).line_id
        OR (l_sch_line_tbl(I).top_model_line_id is not null
            AND l_sch_line_tbl(I).top_model_line_id <> l_sch_line_tbl(I).line_id
            AND Not_part_of_set(l_sch_line_tbl(I).top_model_line_id))
        THEN

            UPDATE OE_ORDER_LINES_ALL
            SET SCHEDULE_SHIP_DATE  = Null,
            SCHEDULE_ARRIVAL_DATE = Null,
            SHIP_FROM_ORG_ID      = decode(re_source_flag,'N',ship_from_org_id,null),
            SHIP_SET_ID           = Null,
            ARRIVAL_SET_ID        = Null,
            override_atp_date_code = Null
            --Bug 5654321
            --Modified the record from l_line_tbl to l_sch_line_tbl
            --WHERE line_id = l_line_tbl(I).line_id;
            WHERE line_id = l_sch_line_tbl(I).line_id;
        END IF;

        -- Begin 4026758
        IF l_sch_line_tbl(I).ship_set_id IS NOT NULL
        OR l_sch_line_tbl(I).arrival_set_id IS NOT NULL THEN

            oe_schedule_util.Log_Delete_Set_Request
            (p_header_id   => l_sch_line_tbl(I).header_id,
            p_line_id     => l_sch_line_tbl(I).line_id,
            p_set_id      => nvl(l_sch_line_tbl(I).ship_set_id,l_sch_line_tbl(I).arrival_set_id),
            x_return_status => l_return_status);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('AFTER LOGGING DELETE SETS DELAYED REQUEST ' || L_RETURN_STATUS,1) ;
            END IF;

        END IF;
        -- End 4026758

    END IF;
  END LOOP;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        fnd_message.set_name('ONT','OE_SCH_SET_INS_FAILED');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('x_return_status ' || x_return_status,2);
        END IF;
    END IF;
    -- End 4188166

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Exiting Group_Schedule_sets' || x_return_status,1);
    END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from expected error',1);
        END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Group_Schedule_sets'
            );
        END IF;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from unexpected error',1);
        END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Group_Schedule_sets'
            );
        END IF;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('No data from unexpected error',1);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Group_Schedule_sets;
END OE_GROUP_SCH_UTIL;


/
