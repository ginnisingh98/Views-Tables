--------------------------------------------------------
--  DDL for Package Body OE_BULK_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_WF_UTIL" AS
/* $Header: OEBUOWFB.pls 120.2.12010000.4 2010/02/16 08:58:52 vbkapoor ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_BULK_WF_UTIL';

-------------------------------------------------------------------
-- LOCAL PROCEDURES/FUNCTIONS
-------------------------------------------------------------------
FUNCTION Get_Wf_Item_type
(  p_line_index                 In  NUMBER,
   p_Line_rec                   IN  OE_WSH_BULK_GRP.LINE_REC_TYPE
)  RETURN VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ITEM_TYPE_CODE IS ' || P_LINE_REC.ITEM_TYPE_CODE(p_line_index) ) ;
    oe_debug_pub.add(  ' Order Quantity UOM :'|| p_line_rec.order_quantity_uom(p_line_index));
   oe_debug_pub.add(  '  ato line id :'|| p_line_rec.ato_line_id(p_line_index));
   oe_debug_pub.add(  '  line id :'|| p_line_rec.line_id(p_line_index));
    oe_debug_pub.add(  ' Top Model Line Id ;'|| p_line_rec.top_model_line_id(p_line_index));
END IF;

-- Code for Returns
IF p_line_rec.line_category_code(p_line_index) = 'RETURN' THEN
    RETURN 'STANDARD';
 END IF;

oe_debug_pub.add(  ' 1:');

IF ( p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_STANDARD OR
        p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_OPTION)
AND     p_line_rec.ato_line_id(p_line_index) = p_line_rec.line_id(p_line_index)
THEN
oe_debug_pub.add(  ' 3:');
                RETURN 'ATO_ITEM';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_MODEL AND
          p_line_rec.line_id(p_line_index) =
p_line_rec.ato_line_id(p_line_index)) THEN
oe_debug_pub.add(  ' 4:');
                RETURN 'ATO_MODEL';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_CONFIG) THEN
oe_debug_pub.add(  ' 5:');
                RETURN 'CONFIGURATION';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_INCLUDED)
THEN
oe_debug_pub.add(  ' 6:');
                RETURN 'II';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_KIT) THEN
oe_debug_pub.add(  ' 7:');
                RETURN 'KIT';
ELSIF (p_line_rec.item_type_code(p_line_index) =  OE_GLOBALS.G_ITEM_MODEL AND
       p_line_rec.line_id(p_line_index) =
p_line_rec.top_model_line_id(p_line_index) AND
        p_line_rec.ato_line_id(p_line_index) IS NULL) THEN
oe_debug_pub.add(  ' 8:');
                RETURN 'PTO_MODEL';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_CLASS AND
        p_line_rec.ato_line_id(p_line_index) IS NULL) THEN
oe_debug_pub.add(  ' 9:');
                RETURN 'PTO_CLASS';
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_OPTION AND
        p_line_rec.ato_line_id(p_line_index) IS NULL) THEN
oe_debug_pub.add(  ' 10:');
                RETURN 'PTO_OPTION';
-- for ato under pto, we want to start ato model flow
-- even if the item_type_code is class. For ato under ato
-- start standard flow.
oe_debug_pub.add(  ' 11:');
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_CLASS AND
        p_line_rec.ato_line_id(p_line_index) IS NOT NULL) THEN

      IF p_line_rec.ato_line_id(p_line_index) = p_line_rec.line_id(p_line_index)
      THEN
oe_debug_pub.add(  ' 11:');
          RETURN 'ATO_MODEL';
      ELSE
oe_debug_pub.add(  ' 12:');
          RETURN 'ATO_CLASS';  -- changed from STANDARD for 4572204
      END IF;
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_OPTION AND
        p_line_rec.ato_line_id(p_line_index) IS NOT NULL) THEN
oe_debug_pub.add(  ' 13:');
                RETURN 'ATO_OPTION';  -- changed from STANDARD for 4572204
ELSIF (p_line_rec.item_type_code(p_line_index) = OE_GLOBALS.G_ITEM_STANDARD)
THEN
oe_debug_pub.add(  ' 14:');
                RETURN 'STANDARD';
/* ELSIF OE_OTA_UTIL.Is_OTA_Line(p_line_rec.order_quantity_uom(p_line_index)) THEN
oe_debug_pub.add(  ' 15:');
               RETURN 'EDUCATION_ITEM';
syed */
 ELSE

         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_WF_ITEM_TYPE');
         OE_BULK_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
END IF;


EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , GET_WF_ITEM_TYPE' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Get_WF_Item_Type'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_WF_Item_Type;

PROCEDURE Create_HdrWorkItem
(  p_index                       IN  NUMBER
,  p_header_rec                  IN  OE_BULK_ORDER_PVT.HEADER_REC_TYPE
)
IS
  l_aname  wf_engine.nametabtyp;
  l_aname2  wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;
  sales_order VARCHAR2(240);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATE_HDRWORKITEM' ) ;
  END IF;

  -- Set Header User Key
  if p_header_rec.order_category_code(p_index) = 'RETURN' then
    fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
  else
    fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
  end if;

  fnd_message.set_token('ORDER_NUMBER'
                , to_char(p_header_rec.order_number(p_index)));
  sales_order := substrb(fnd_message.get, 1, 240);

  -- Create Header Work item
  WF_ENGINE.CreateProcess(OE_Globals.G_WFI_HDR
                   ,to_char(p_header_rec.header_id(p_index))
                   ,p_header_rec.wf_process_name(p_index)
                   ,sales_order);


  -- Set various Header Attributes
  l_aname(1) := 'USER_ID';
  l_avalue(1) := FND_GLOBAL.USER_ID;
  l_aname(2) := 'APPLICATION_ID';
  l_avalue(2) := FND_GLOBAL.RESP_APPL_ID;
  l_aname(3) := 'RESPONSIBILITY_ID';
  l_avalue(3) := FND_GLOBAL.RESP_ID;
  l_aname(4) := 'ORG_ID';
  l_avalue(4) := to_number(OE_GLOBALS.G_ORG_ID);
  l_aname(5) := 'ORDER_NUMBER'; -- Added for bug 6066313
  l_avalue(5) := p_header_rec.order_number(p_index); -- Added for bug 6066313
  wf_engine.SetItemAttrNumberArray( OE_GLOBALS.G_WFI_HDR
                              , p_header_rec.header_id(p_index)
                              , l_aname
                              , l_avalue
                              );
  l_aname2(1) := 'ORDER_CATEGORY';
  l_avaluetext(1) := p_header_rec.order_category_code(p_index);
  l_aname2(2) := 'NOTIFICATION_APPROVER';
  l_avaluetext(2) := OE_BULK_ORDER_PVT.G_NOTIFICATION_APPROVER;

  wf_engine.SetItemAttrTextArray( OE_GLOBALS.G_WFI_HDR
                             , p_header_rec.header_id(p_index)
                             , l_aname2
                             , l_avaluetext
                             );

EXCEPTION
WHEN OTHERS THEN
        OE_BULK_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_HdrWorkItem'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_HdrWorkItem;

PROCEDURE Create_LineWorkItem
(  p_line_index                     IN  NUMBER
,  p_header_index                   IN  NUMBER
,  p_line_rec                       IN OE_WSH_BULK_GRP.LINE_REC_TYPE
,  p_header_rec                     IN OE_BULK_ORDER_PVT.HEADER_REC_TYPE
)
IS
  l_process_name    VARCHAR2(30);
  l_wf_item_type    VARCHAR2(30);
  l_wf_assigned     BOOLEAN;
  l_order_number NUMBER;
  l_aname  wf_engine.nametabtyp;
  l_aname2 wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;
  line VARCHAR2(240);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  -- Set Line User Key
  if p_line_rec.line_category_code(p_line_index) = 'RETURN' THEN
    fnd_message.set_name('ONT', 'OE_WF_RETURN_LINE');
  else
    fnd_message.set_name('ONT', 'OE_WF_LINE');
  end if;

  fnd_message.set_token('ORDER_NUMBER',
                            to_char(p_header_rec.order_number(p_header_index)));
  fnd_message.set_token('LINE_NUMBER',
                            to_char(p_line_rec.line_number(p_line_index)));
  fnd_message.set_token('SHIPMENT_NUMBER',
                            to_char(p_line_rec.shipment_number(p_line_index)));
  fnd_message.set_token('OPTION_NUMBER',
                            to_char(p_line_rec.option_number(p_line_index)));
  fnd_message.set_token('SERVICE_NUMBER',
                            to_char(p_line_rec.service_number(p_line_index)));

  line := substrb(fnd_message.get, 1, 240);

  -- Create Line Work item
  WF_ENGINE.CreateProcess(OE_Globals.G_WFI_LIN
                         ,to_char(p_line_rec.line_id(p_line_index))
                         ,p_line_rec.wf_process_name(p_line_index)
                         ,line);


  -- Set various Line Attributes
  l_aname(1) := 'USER_ID';
  l_avalue(1) := FND_GLOBAL.USER_ID;
  l_aname(2) := 'APPLICATION_ID';
  l_avalue(2) := FND_GLOBAL.RESP_APPL_ID;
  l_aname(3) := 'RESPONSIBILITY_ID';
  l_avalue(3) := FND_GLOBAL.RESP_ID;
  l_aname(4) := 'ORG_ID';
  l_avalue(4) := to_number(OE_GLOBALS.G_ORG_ID);

  wf_engine.SetItemAttrNumberArray( OE_GLOBALS.G_WFI_LIN
                              , p_line_rec.line_id(p_line_index)
                              , l_aname
                              , l_avalue
                              );

  l_aname2(1) := 'LINE_CATEGORY';
  l_avaluetext(1) := p_line_rec.line_category_code(p_line_index);
  l_aname2(2) := 'NOTIFICATION_APPROVER';
  l_avaluetext(2) := OE_BULK_ORDER_PVT.G_NOTIFICATION_APPROVER;

  wf_engine.SetItemAttrTextArray( OE_GLOBALS.G_WFI_LIN
                             , p_line_rec.line_id(p_line_index)
                             , l_aname2
                             , l_avaluetext
                             );

  WF_ITEM.Set_Item_Parent(OE_Globals.G_WFI_LIN,
                          to_char(p_line_rec.line_id(p_line_index)),
                          OE_GLOBALS.G_WFI_HDR,
                          to_char(p_line_rec.header_id(p_line_index)), '');


EXCEPTION
WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CREATE_LINEWORKITEM OTHER ERROR' ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
        END IF;
        OE_BULK_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_LineWorkItem'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_LineWorkItem;


-------------------------------------------------------------------
-- PUBLIC PROCEDURES/FUNCTIONS
-------------------------------------------------------------------

FUNCTION Validate_OT_WF_Assignment
(p_order_type_id IN NUMBER
,x_process_name OUT NOCOPY VARCHAR2)

RETURN BOOLEAN
IS
l_process_name VARCHAR2(30);
CURSOR c_header_process (p_type_id NUMBER) IS
SELECT process_name
  FROM OE_WORKFLOW_ASSIGNMENTS
 WHERE order_type_id = p_type_id
   AND line_type_id IS NULL
   -- 11i10 - only fulfillment orders supported in HVOP so
   -- select fulfillment flow
   AND nvl(wf_item_type,'OEOH') = 'OEOH'
   AND sysdate >= start_date_active
   AND sysdate <= nvl(end_date_active, sysdate);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

 -- Check if Order Type exists in Global and has valid assignment.
 IF G_ORDER_TYPE_WF_ASSIGN_TBL.EXISTS(p_order_type_id) THEN

    x_process_name := G_ORDER_TYPE_WF_ASSIGN_TBL(p_order_type_id).process_name;
    IF x_process_name IS NOT NULL THEN
        RETURN TRUE;
    ELSE -- No assignment exists
        RETURN FALSE;
    END IF;

 ELSE -- no entry in cache

   OPEN c_header_process(p_order_type_id);
   FETCH c_header_process INTO x_process_name;
   IF c_header_process%NOTFOUND THEN
       x_process_name := NULL;
   END IF;
   CLOSE c_header_process;

   -- Update cache for null and not null values.
   G_ORDER_TYPE_WF_ASSIGN_TBL(p_order_type_id).process_name := x_process_name;

   IF x_process_name IS NOT NULL THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

 END IF;  -- Order Type is in cache

EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , VALIDATE_OT_WF_ASSIGNMENT' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Validate_OT_WF_Assignment'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_OT_WF_Assignment;

-- This Function Validates that a valid WF assignment exists for the Line Type
FUNCTION Validate_LT_WF_Assignment
  ( p_order_type_id       IN NUMBER
  , p_line_index          IN NUMBER
  , p_line_rec            IN  OE_WSH_BULK_GRP.LINE_REC_TYPE
  , x_process_name OUT NOCOPY VARCHAR2
  )
RETURN BOOLEAN
IS
  ctr                  NUMBER := 1;
  l_cache_exists       BOOLEAN := FALSE;
  l_wf_item_type       VARCHAR2(30);
  CURSOR c_line_process IS
    SELECT process_name
          ,item_type_code
    FROM OE_WORKFLOW_ASSIGNMENTS
    WHERE order_type_id = p_order_type_id
      AND line_type_id = p_line_rec.line_type_id(p_line_index)
      AND nvl(item_type_code,l_wf_item_type) = l_wf_item_type
      AND sysdate >= start_date_active
      AND sysdate <= nvl(end_date_active, sysdate);
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Entering Validate_LT_WF_Assignment',1 ) ;
    END IF;

  -- Bug 2900592, get_wf_item_type returns error if item type is not
  -- one of the bulk supported item types ('STANDARD','KIT' or 'INCLUDED')
  -- So handle it as an invalid WF assignment
  BEGIN

   oe_debug_pub.add(  'ITEM_TYPE_CODE IS ' || P_LINE_REC.ITEM_TYPE_CODE(p_line_index) ) ;
    oe_debug_pub.add(  ' Order Quantity UOM :'|| p_line_rec.order_quantity_uom(p_line_index));
   oe_debug_pub.add(  '  ato line id :'|| p_line_rec.ato_line_id(p_line_index));
   oe_debug_pub.add(  '  line id :'|| p_line_rec.line_id(p_line_index));
    oe_debug_pub.add(  ' Top Model Line Id ;'|| p_line_rec.top_model_line_id(p_line_index));

  -- Check if combination exists in Global and has valid assignment.
   l_wf_item_type := Get_WF_Item_Type(p_line_index,p_line_rec);
   if l_debug_level > 0 then
 	oe_debug_pub.add('work flow item type'||l_wf_item_type);
   end if;
  EXCEPTION
  WHEN OTHERS THEN
	oe_debug_pub.add('Into the exception');
     RETURN FALSE;
  END;

  WHILE (ctr <= G_LINE_TYPE_WF_ASSIGN_TBL.COUNT) LOOP

    IF (G_LINE_TYPE_WF_ASSIGN_TBL(ctr).order_type_id = p_order_TYPE_ID)
       AND (G_LINE_TYPE_WF_ASSIGN_TBL(ctr).line_type_id = p_line_rec.line_type_id(p_line_index))
       AND (nvl(G_LINE_TYPE_WF_ASSIGN_TBL(ctr).wf_item_type,l_wf_item_type)
            = l_wf_item_type)
    THEN

       x_process_name := G_LINE_TYPE_WF_ASSIGN_TBL(ctr).process_name;
       l_cache_exists := TRUE;
       EXIT;

    END IF;

   ctr := ctr + 1;
  END LOOP;

  IF (l_cache_exists) THEN

    IF x_process_name IS NOT NULL THEN
	oe_debug_pub.add('returning true');
        RETURN TRUE;
    ELSE -- no assignment for this combination.
	oe_debug_pub.add('returning false');
        RETURN FALSE;
    END IF;

  ELSE -- no entry in cache

    OPEN c_line_process;
    FETCH c_line_process INTO x_process_name, l_wf_item_type;
    IF c_line_process%NOTFOUND THEN
       x_process_name := NULL;
    END IF;
    CLOSE c_line_process;

    -- Update cache
 oe_debug_pub.add('updating the cache');
    ctr := G_LINE_TYPE_WF_ASSIGN_TBL.COUNT + 1;
    G_LINE_TYPE_WF_ASSIGN_TBL(ctr).order_type_id := p_order_type_id;
    G_LINE_TYPE_WF_ASSIGN_TBL(ctr).line_type_id := p_line_rec.line_type_id(p_line_index);
    G_LINE_TYPE_WF_ASSIGN_TBL(ctr).process_name := x_process_name;
    G_LINE_TYPE_WF_ASSIGN_TBL(ctr).wf_item_type := l_wf_item_type;

    IF x_process_name IS NOT NULL THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

  END IF;  -- Combination is in cache

   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'Exiting Validate_LT_WF_Assignment',1 ) ;
    END IF;


EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , VALIDATE_LT_WF_ASSIGNMENT' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Validate_LT_WF_Assignment'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_LT_WF_Assignment;


-----------------------------------------------------------------------
-- PROCEDURE Start_Flows
--
-- This API is called from BULK process order to start workflows for
-- all orders or lines processed in a batch.
-----------------------------------------------------------------------

PROCEDURE Start_Flows
        (p_header_rec          IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE
        ,p_line_rec            IN OUT NOCOPY OE_WSH_BULK_GRP.LINE_REC_TYPE
,x_return_status OUT NOCOPY VARCHAR2)

IS
l_msg_text                VARCHAR2(2000);
l_msg_count               NUMBER;
l_header_id               NUMBER;
l_wf_item_type            VARCHAR2(30);
i                         NUMBER;
j                         NUMBER := 1;
l_header_count            NUMBER := p_header_rec.HEADER_ID.COUNT;
l_ii_index                NUMBER;
--
/* Start of WF Bulk API ER #8601238 */
type process_name_bulk is table of varchar2(120) index by varchar2(120);
type item_keys_bulk is table of varchar2(240) index by varchar2(80);
type user_keys_bulk is table of varchar2(240) index by varchar2(80);

l_process_name_tbl   process_name_bulk;
l_item_keys          item_keys_bulk;
l_user_keys          user_keys_bulk;

l_owner_role         VARCHAR2(320);
l_line_to_key        VARCHAR2(40);

l_my_index_ind       VARCHAR2(120);
l_process_name_ind   VARCHAR2(120);
l_wf_bulk_api_index  NUMBER := 0;
l_index_Attr_Txt     NUMBER := 0;
l_index_Attr_Num     NUMBER := 0;

l_aname              wf_engine.nametabtyp;
l_aname2             wf_engine.nametabtyp;
l_avalue             wf_engine.numtabtyp;
l_avaluetext         wf_engine.texttabtyp;
l_itemkeys_4NAttr    wf_engine_bulk.itemkeytabtype;
l_itemkeys_4TAttr    wf_engine_bulk.itemkeytabtype;

WF_Api_l_item_keys   wf_engine_bulk.itemkeytabtype;
WF_Api_l_user_keys   wf_engine_bulk.userkeytabtype;
WF_Api_l_owner_roles wf_engine_bulk.ownerroletabtype;
/* End of WF Bulk API ER #8601238 */
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- bug 3549993, turning off saving of messages through WF
   OE_STANDARD_WF.G_SAVE_MESSAGES := FALSE;

/* Start of WF Bulk API ER #8601238 */
   SELECT user_name
   INTO   l_owner_role
   FROM   FND_USER
   WHERE  USER_ID = FND_GLOBAL.USER_ID;
/* End of WF Bulk API ER #8601238 */

   FOR I IN 1..l_header_count LOOP

     l_header_id := p_header_rec.header_id(i);

     IF nvl(p_header_rec.lock_control(i),0) NOT IN ( -99, -98, -97) THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'START WF , HEADER ID:'||L_HEADER_ID ) ;
        END IF;

        G_HEADER_INDEX := i;

        -- Bug 3482897
        -- Set line index to null when header WF item is created.
        -- WFs for free good lines are started in the pricing call prior
        -- to this WF start. This is allowed by WF even though parent WF for
        -- header does not exist.
        -- If line index is not nulled out, line WFs for these promotional items
        -- that are progressed in complete book call later think they are
        -- running in bulk mode and use an incorrect line index set by
        -- last line in previous order.
        -- This causes issues like free good lines not being scheduled for
        -- subsequent orders.
        G_LINE_INDEX := null;

        OE_BULK_WF_UTIL.Create_HdrWorkItem
                 (p_index      => i
                 ,p_header_rec => p_header_rec
                 );
	/*Before we move to start Header flow, create line flow also -- bug 5261216*/
	WHILE p_line_rec.HEADER_ID.EXISTS(j)
              AND p_line_rec.header_id(j) <= l_header_id
              AND NOT (p_line_rec.item_type_code(j) = 'INCLUDED') /* Uncommented for #9302459 */
        LOOP
           IF p_line_rec.header_id(j) = l_header_id THEN

           G_LINE_INDEX := j;

/* Start of WF Bulk API ER #8601238 */
/*         OE_BULK_WF_UTIL.Create_LineWorkItem
                  (p_line_index    => j
                  ,p_header_index  => i
                  ,p_line_rec      => p_line_rec
                  ,p_header_rec    => p_header_rec
                  ); */ -- Commented for WF Bulk API ER #8601238

           l_line_to_key := to_char(p_line_rec.line_id(j));

           IF NOT (l_process_name_tbl.EXISTS(p_line_rec.wf_process_name(j))) THEN
             l_process_name_tbl(p_line_rec.wf_process_name(j)) := p_line_rec.wf_process_name(j);
           END IF;
           l_item_keys(p_line_rec.wf_process_name(j)||':'||l_line_to_key) := l_line_to_key;

           -- Setting Line User Key
           if p_line_rec.line_category_code(j) = 'RETURN' THEN
             fnd_message.set_name('ONT', 'OE_WF_RETURN_LINE');
           else
             fnd_message.set_name('ONT', 'OE_WF_LINE');
           end if;
           fnd_message.set_token('ORDER_NUMBER', to_char(p_header_rec.order_number(i)));
           fnd_message.set_token('LINE_NUMBER', to_char(p_line_rec.line_number(j)));
           fnd_message.set_token('SHIPMENT_NUMBER', to_char(p_line_rec.shipment_number(j)));
           fnd_message.set_token('OPTION_NUMBER', to_char(p_line_rec.option_number(j)));
           fnd_message.set_token('SERVICE_NUMBER', to_char(p_line_rec.service_number(j)));
           l_user_keys(p_line_rec.wf_process_name(j)||':'||l_line_to_key)  := substrb(fnd_message.get, 1, 240);

           l_index_Attr_Num := l_index_Attr_Num + 1;
           l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(j));
           l_aname(l_index_Attr_Num) := 'USER_ID';
           l_avalue(l_index_Attr_Num) := FND_GLOBAL.USER_ID;

           l_index_Attr_Num := l_index_Attr_Num + 1;
           l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(j));
           l_aname(l_index_Attr_Num) := 'APPLICATION_ID';
           l_avalue(l_index_Attr_Num) := FND_GLOBAL.RESP_APPL_ID;

           l_index_Attr_Num := l_index_Attr_Num + 1;
           l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(j));
           l_aname(l_index_Attr_Num) := 'RESPONSIBILITY_ID';
           l_avalue(l_index_Attr_Num) := FND_GLOBAL.RESP_ID;

           l_index_Attr_Num := l_index_Attr_Num + 1;
           l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(j));
           l_aname(l_index_Attr_Num) := 'ORG_ID';
           l_avalue(l_index_Attr_Num) := to_number(OE_GLOBALS.G_ORG_ID);

           -- Set various Line Attributes of Text datatype
           l_index_Attr_Txt := l_index_Attr_Txt + 1;
           l_itemkeys_4TAttr(l_index_Attr_Txt) := to_char(p_line_rec.line_id(j));
           l_aname2(l_index_Attr_Txt) := 'LINE_CATEGORY';
           l_avaluetext(l_index_Attr_Txt) := p_line_rec.line_category_code(j);

           l_index_Attr_Txt := l_index_Attr_Txt + 1;
           l_itemkeys_4TAttr(l_index_Attr_Txt) := to_char(p_line_rec.line_id(j));
           l_aname2(l_index_Attr_Txt) := 'NOTIFICATION_APPROVER';
           l_avaluetext(l_index_Attr_Txt) := OE_BULK_ORDER_PVT.G_NOTIFICATION_APPROVER;

           -- Uncommented for #9302459
	   -- Start Workflows for included items if this is a kit line
           IF p_line_rec.item_type_code(j) IN ('KIT', 'MODEL', 'CLASS')
              AND p_line_rec.ii_start_index(j) IS NOT NULL THEN

              l_ii_index := p_line_rec.ii_start_index(j);

              FOR k IN 1..p_line_rec.ii_count(j) LOOP
                G_LINE_INDEX := l_ii_index;

                /* OE_BULK_WF_UTIL.Create_LineWorkItem
                  (p_line_index    => l_ii_index
                  ,p_header_index  => i
                  ,p_line_rec      => p_line_rec
                  ,p_header_rec    => p_header_rec
                  );
		*/ -- Commented for #9302459

                l_line_to_key := to_char(p_line_rec.line_id(l_ii_index));

                IF NOT (l_process_name_tbl.EXISTS(p_line_rec.wf_process_name(l_ii_index))) THEN
                  l_process_name_tbl(p_line_rec.wf_process_name(l_ii_index)) := p_line_rec.wf_process_name(l_ii_index);
                END IF;
                l_item_keys(p_line_rec.wf_process_name(l_ii_index)||':'||l_line_to_key) := l_line_to_key;

                -- Setting Line User Key
                if p_line_rec.line_category_code(j) = 'RETURN' THEN
                  fnd_message.set_name('ONT', 'OE_WF_RETURN_LINE');
                else
                  fnd_message.set_name('ONT', 'OE_WF_LINE');
                end if;
                fnd_message.set_token('ORDER_NUMBER', to_char(p_header_rec.order_number(i)));
                fnd_message.set_token('LINE_NUMBER', to_char(p_line_rec.line_number(l_ii_index)));
                fnd_message.set_token('SHIPMENT_NUMBER', to_char(p_line_rec.shipment_number(l_ii_index)));
                fnd_message.set_token('OPTION_NUMBER', to_char(p_line_rec.option_number(l_ii_index)));
                fnd_message.set_token('SERVICE_NUMBER', to_char(p_line_rec.service_number(l_ii_index)));
                l_user_keys(p_line_rec.wf_process_name(l_ii_index)||':'||l_line_to_key)  := substrb(fnd_message.get, 1, 240);

                l_index_Attr_Num := l_index_Attr_Num + 1;
                l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname(l_index_Attr_Num) := 'USER_ID';
                l_avalue(l_index_Attr_Num) := FND_GLOBAL.USER_ID;

                l_index_Attr_Num := l_index_Attr_Num + 1;
                l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname(l_index_Attr_Num) := 'APPLICATION_ID';
                l_avalue(l_index_Attr_Num) := FND_GLOBAL.RESP_APPL_ID;

                l_index_Attr_Num := l_index_Attr_Num + 1;
                l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname(l_index_Attr_Num) := 'RESPONSIBILITY_ID';
                l_avalue(l_index_Attr_Num) := FND_GLOBAL.RESP_ID;

                l_index_Attr_Num := l_index_Attr_Num + 1;
                l_itemkeys_4NAttr(l_index_Attr_Num) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname(l_index_Attr_Num) := 'ORG_ID';
                l_avalue(l_index_Attr_Num) := to_number(OE_GLOBALS.G_ORG_ID);

                -- Set various Line Attributes of Text datatype
                l_index_Attr_Txt := l_index_Attr_Txt + 1;
                l_itemkeys_4TAttr(l_index_Attr_Txt) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname2(l_index_Attr_Txt) := 'LINE_CATEGORY';
                l_avaluetext(l_index_Attr_Txt) := p_line_rec.line_category_code(l_ii_index);

                l_index_Attr_Txt := l_index_Attr_Txt + 1;
                l_itemkeys_4TAttr(l_index_Attr_Txt) := to_char(p_line_rec.line_id(l_ii_index));
                l_aname2(l_index_Attr_Txt) := 'NOTIFICATION_APPROVER';
                l_avaluetext(l_index_Attr_Txt) := OE_BULK_ORDER_PVT.G_NOTIFICATION_APPROVER;

                l_ii_index := l_ii_index + 1;

              END LOOP;

           END IF; -- Commented for WF Bulk API ER #8601238

/* End of WF Bulk API ER #8601238 */

           END IF; -- End if line header id = l_header_id

           j := j + 1;

        END LOOP; /*Bug 5261216*/

/* Start of WF Bulk API ER #8601238 */

	IF l_process_name_tbl.COUNT > 0 THEN
          l_process_name_ind := l_process_name_tbl.FIRST;
          FOR x in 1 .. l_process_name_tbl.COUNT LOOP
            l_wf_bulk_api_index := 0;
            l_my_index_ind := l_item_keys.FIRST;
            FOR xx in 1 .. l_item_keys.COUNT LOOP
              IF substr(l_my_index_ind,1,(INSTR(l_my_index_ind,':')-1)) = l_process_name_ind THEN
                l_wf_bulk_api_index := l_wf_bulk_api_index + 1;
                WF_Api_l_item_keys(l_wf_bulk_api_index) := l_item_keys(l_my_index_ind);
                WF_Api_l_user_keys(l_wf_bulk_api_index) := l_user_keys(l_my_index_ind);
                WF_Api_l_owner_roles(l_wf_bulk_api_index) := l_owner_role;
              END IF;
              l_my_index_ind := l_item_keys.NEXT(l_my_index_ind);
            END LOOP;

	    -- Calling WF Bulk APIs for Creating the Workflow Process Definition
            WF_ENGINE_BULK.CreateProcess
            ( itemtype        => OE_GLOBALS.G_WFI_LIN
            , itemkeys        => WF_Api_l_item_keys
            , process         => l_process_name_tbl(l_process_name_ind)
            , user_keys       => WF_Api_l_user_keys
            , owner_roles     => WF_Api_l_owner_roles
            , parent_itemtype => OE_GLOBALS.G_WFI_HDR
            , parent_itemkey  => l_header_id
            , masterdetail    => TRUE
            );

            WF_Api_l_item_keys.DELETE;
            WF_Api_l_user_keys.DELETE;
            WF_Api_l_owner_roles.DELETE;
            l_wf_bulk_api_index := 0;
            l_process_name_ind := l_process_name_tbl.NEXT(l_process_name_ind);
          END LOOP;
        END IF;

        -- Calling WF Bulk APIs for setting Item attributes of Number and Text type
        WF_ENGINE_BULK.SetItemAttrText
        ( itemtype => OE_GLOBALS.G_WFI_LIN
        , itemkeys => l_itemkeys_4TAttr
        , anames   => l_aname2
        , avalues  => l_avaluetext
        );

        WF_ENGINE_BULK.SetItemAttrNumber
        ( itemtype => OE_GLOBALS.G_WFI_LIN
        , itemkeys => l_itemkeys_4NAttr
        , anames   => l_aname
        , avalues  => l_avalue
        );

        l_process_name_tbl.DELETE;
        l_item_keys.DELETE;
        l_user_keys.DELETE;
        l_itemkeys_4TAttr.DELETE;
        l_aname2.DELETE;
        l_avaluetext.DELETE;
        l_itemkeys_4NAttr.DELETE;
        l_aname.DELETE;
        l_avalue.DELETE;
        -- Added above X.DELETE for bug 9302459

/* End of WF Bulk API ER #8601238 */

	/*Progress Both Header and Line Flows*/
        WF_ENGINE.StartProcess(OE_GLOBALS.G_WFI_HDR
                 ,to_char(l_header_id));

        IF p_header_rec.booked_flag(i) = 'Y' THEN
           -- Call WF_ENGINE to complete the BOOK_ELIGIBLE activity and proceed
           -- to the next activity in the order workflow
           WF_ENGINE.CompleteActivityInternalName
                ( itemtype              => 'OEOH'
                , itemkey               => to_char(l_header_id)
                , activity              => 'BOOK_ELIGIBLE'
                , result                => NULL
                );
           OE_BULK_ORDER_IMPORT_PVT.G_BOOKED_ORDERS :=
              OE_BULK_ORDER_IMPORT_PVT.G_BOOKED_ORDERS + 1;
        ELSE
           OE_BULK_ORDER_IMPORT_PVT.G_ENTERED_ORDERS :=
              OE_BULK_ORDER_IMPORT_PVT.G_ENTERED_ORDERS + 1;
        END IF;
	j:=1; /*Resetting j Bug 5261216*/
        WHILE p_line_rec.HEADER_ID.EXISTS(j)
              -- Bug 2802876
              -- Changed condition from = to <=
              -- As there could be lines for erroneous orders in
              -- the line table which should be skipped until you
              -- find lines for current order.
              AND p_line_rec.header_id(j) <= l_header_id
              AND NOT (p_line_rec.item_type_code(j) = 'INCLUDED')
        LOOP

           IF l_debug_level > 0 THEN
              oe_debug_pub.add('Line Index : '||j);
              oe_debug_pub.add('Line Header ID : '||p_line_rec.header_id(j));
           END IF;

           -- Start flows only if line header_id matches current
           -- header_id
           IF p_line_rec.header_id(j) = l_header_id THEN

           G_LINE_INDEX := j;

           /*OE_BULK_WF_UTIL.Create_LineWorkItem
                  (p_line_index    => j
                  ,p_header_index  => i
                  ,p_line_rec      => p_line_rec
                  ,p_header_rec    => p_header_rec
                  );*/ --Line work flow already created Bug 5261216

           -- Start Workflow for this line
           WF_ENGINE.StartProcess(OE_GLOBALS.G_WFI_LIN
                     ,to_char(p_line_rec.line_id(j)));

           -- Pricing Post-Processing
           -- Not needed for included items.
           -- This check is done here and not in OEBVPRCB-Price_Orders procedure
           -- as pricing API does not loop over lines while wf start does!

           OE_Bulk_Process_Line.Post_Process
                  (p_line_index    => j
                  ,p_header_index  => i
                  ,p_line_rec      => p_line_rec
                  ,p_header_rec    => p_header_rec
                  );

           -- Start Workflows for included items if this is a kit line
           IF p_line_rec.item_type_code(j) IN ('KIT', 'MODEL', 'CLASS')
              AND p_line_rec.ii_start_index(j) IS NOT NULL THEN

              l_ii_index := p_line_rec.ii_start_index(j);

              FOR k IN 1..p_line_rec.ii_count(j) LOOP

                -- Bug 2670420, line index was not set for included items.
                -- Scheduling WF API was checking parent index and mistakenly
                -- concluding that all included items were scheduled if the
                -- kit is schedule. This is not true for non-SMC kits.
                G_LINE_INDEX := l_ii_index;

                /* OE_BULK_WF_UTIL.Create_LineWorkItem
                  (p_line_index    => l_ii_index
                  ,p_header_index  => i
                  ,p_line_rec      => p_line_rec
                  ,p_header_rec    => p_header_rec
                  );*/ --Line work flow already created Bug 5261216

                WF_ENGINE.StartProcess(OE_GLOBALS.G_WFI_LIN
                     ,to_char(p_line_rec.line_id(l_ii_index)));
                l_ii_index := l_ii_index + 1;

              END LOOP;

           END IF;

           END IF; -- End if line header id = l_header_id

           j := j + 1;

        END LOOP; -- End loop for lines

     ELSE

        OE_BULK_ORDER_IMPORT_PVT.G_ERROR_ORDERS :=
            OE_BULK_ORDER_IMPORT_PVT.G_ERROR_ORDERS + 1;

     END IF; -- If order does not have errors

   END LOOP; -- End loop for headers

   G_HEADER_INDEX := NULL;
   G_LINE_INDEX := NULL;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    G_HEADER_INDEX := NULL;
    G_LINE_INDEX := NULL;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UNEXP ERROR , START_FLOWS' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    G_HEADER_INDEX := NULL;
    G_LINE_INDEX := NULL;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR , START_FLOWS' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 240 ) ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Start_Flows'
        );
END Start_Flows;

END OE_BULK_WF_UTIL;

/
