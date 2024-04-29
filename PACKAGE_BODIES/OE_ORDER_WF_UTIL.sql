--------------------------------------------------------
--  DDL for Package Body OE_ORDER_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_WF_UTIL" AS
/* $Header: OEXUOWFB.pls 120.17.12010000.20 2010/10/06 13:16:13 srsunkar ship $ */

-- record for dynamic notification body for quote/blanket
TYPE line_record IS RECORD (
  line_num             VARCHAR2(100),
  item                 mtl_system_items_kfv.concatenated_segments%TYPE,
  uom                  VARCHAR2(3),
  quantity             NUMBER,
  unit_selling_price   NUMBER,
  line_amount          NUMBER,
  line_id              NUMBER,
  inventory_item_id    NUMBER,    --- the following column needed for line_margin API
  item_type_code       VARCHAR2(30),
  open_flag            VARCHAR2(1),
  SHIPPED_QUANTITY     NUMBER,
  ORDERED_QUANTITY     NUMBER,
  SOURCE_TYPE_CODE     VARCHAR2(30),
  SHIP_FROM_ORG_ID     NUMBER,
  PROJECT_ID           NUMBER,
  ACTUAL_SHIPMENT_DATE DATE,
  FULFILLMENT_DATE     DATE
);

-- This procedure retrieves the name of the flow that needs to
-- be created.
FUNCTION Get_ProcessName
(   p_itemtype IN VARCHAR2
,   p_itemkey  IN VARCHAR2
,   p_wfasgn_item_type IN VARCHAR2 := FND_API.G_MISS_CHAR
,   p_SalesDocumentTypeCode IN VARCHAR2 Default null
,   p_line_rec IN OE_Order_PUB.Line_Rec_Type  := OE_Order_Pub.G_MISS_LINE_REC
) RETURN VARCHAR2
IS
 l_process_name varchar2(30);

 /* In the five cursors below, trunc(sysdate) was put in instead of sysdate in expr.
    trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate) to fix bug 3108864 */

 CURSOR find_HdrProcessname(itemkey varchar2) is
        select wf_assign.process_name
        from oe_workflow_assignments wf_assign,
             oe_order_headers_all header
        where header.header_id = to_number(itemkey)
              and header.order_type_id = wf_assign.order_type_id
              and sysdate >= wf_assign.start_date_active
              and trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate)
              and wf_assign.line_type_id IS NULL
              and nvl(wf_assign.wf_item_type, OE_GLOBALS.G_WFI_HDR) = OE_GLOBALS.G_WFI_HDR;
         /* NEED UPGRADE ON NEW COLUMN? */

 CURSOR find_LineProcessname is
        SELECT wf_assign.process_name
          FROM oe_workflow_assignments wf_assign,
               oe_order_headers_all header
         WHERE  nvl(p_wfasgn_item_type,'-99') =
                 nvl(wf_assign.item_type_code,nvl(p_wfasgn_item_type,'-99'))
                AND header.header_id = p_line_rec.header_id AND
                header.order_type_id = wf_assign.order_type_id
                 AND p_line_rec.line_type_id = wf_assign.line_type_id
                 AND wf_assign.line_type_id IS NOT NULL
                 AND sysdate >= wf_assign.start_date_active
                 AND trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate)
                 Order by wf_assign.item_type_code;

 CURSOR find_NegotiateHdrProcessname(itemkey varchar2) is
        SELECT wf_assign.process_name
          FROM oe_workflow_assignments wf_assign,
               oe_order_headers_all header
         WHERE header.header_id = to_number(itemkey)
              and header.order_type_id = wf_assign.order_type_id
              and sysdate >= wf_assign.start_date_active
              and trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate)
              and wf_assign.wf_item_type = OE_GLOBALS.G_WFI_NGO
              and wf_assign.line_type_id IS NULL;

 CURSOR find_BktNgoHdrProcessname(itemkey varchar2) is
        SELECT wf_assign.process_name
          FROM oe_workflow_assignments wf_assign,
               oe_blanket_headers_all header
         WHERE header.header_id = to_number(itemkey)
              and header.order_type_id = wf_assign.order_type_id
              and sysdate >= wf_assign.start_date_active
              and trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate)
              and wf_assign.wf_item_type = OE_GLOBALS.G_WFI_NGO
              and wf_assign.line_type_id IS NULL;

 CURSOR find_BlanketHdrProcessname(itemkey varchar2) is
        SELECT wf_assign.process_name
          FROM oe_workflow_assignments wf_assign,
               oe_blanket_headers_all blanket
         WHERE blanket.header_id = to_number(itemkey)
              and blanket.order_type_id = wf_assign.order_type_id
              and sysdate >= wf_assign.start_date_active
              and trunc(sysdate) <= nvl(wf_assign.end_date_active, sysdate)
              and wf_assign.wf_item_type = OE_GLOBALS.G_WFI_BKT
              and wf_assign.line_type_id IS NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN GET_PROCESSNAME: '  || p_itemtype || '/' || p_itemkey || '/' || p_wfasgn_item_type) ;
   END IF;

   IF (p_itemtype = OE_GLOBALS.G_WFI_HDR) THEN

        OPEN find_HdrProcessname(p_itemkey);
        FETCH find_HdrProcessname
        INTO l_process_name;

        CLOSE find_HdrProcessname;
  ELSIF (p_itemtype = OE_GLOBALS.G_WFI_LIN) THEN
	IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'header_id: ' || p_line_rec.header_id || ' line_id: ' || p_line_rec.line_id || ' line_type_id: ' || p_line_rec.line_type_id);
        END IF;
        OPEN  find_LineProcessname;
        FETCH find_LineProcessname
        INTO l_process_name;

        CLOSE find_LineProcessname;
  ELSIF (p_itemtype = OE_GLOBALS.G_WFI_NGO) THEN
        IF nvl(p_SalesDocumentTypeCode, 'O') = 'O' THEN
          OPEN find_NegotiateHdrProcessname(p_itemkey);
          FETCH find_NegotiateHdrProcessname
          INTO l_process_name;

          CLOSE find_NegotiateHdrProcessname;
        ELSIF nvl(p_SalesDocumentTypeCode, 'O') = 'B' THEN
          OPEN find_BktNgoHdrProcessname(p_itemkey);
          FETCH find_BktNgoHdrProcessname
          INTO l_process_name;

          CLOSE find_BktNgoHdrProcessname;
        ELSE
          -- error
          RAISE FND_API.G_EXC_ERROR;
        END IF;

  ELSIF (p_itemtype = OE_GLOBALS.G_WFI_BKT) THEN
        OPEN find_BlanketHdrProcessname(p_itemkey);
        FETCH find_BlanketHdrProcessname
        INTO l_process_name;

        CLOSE find_BlanketHdrProcessname;
  END IF;


   IF l_process_name IS NULL THEN
      RAISE NO_DATA_FOUND;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PROCESS NAME IS '||L_PROCESS_NAME ) ;
   END IF;

   RETURN l_process_name;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING GET_PROCESSNAME' ) ;
   END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('ONT','OE_MISS_FLOW');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;

  WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_ProcessName'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
END Get_ProcessName;


PROCEDURE Set_Header_Descriptor(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY /* file.sql.39 change */ varchar2,
                            document_type in out NOCOPY /* file.sql.39 change */ varchar2)
IS

l_header_id NUMBER;
l_order_number NUMBER;
l_order_type_id NUMBER;
l_order_type_name VARCHAR2(80);
l_order_category_code VARCHAR2(30);
l_order_type_txt VARCHAR2(2000);
l_header_txt VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   document_type := display_type;
  BEGIN
   -- if viewing method is through URL
   -- fix bug 1332384
   SELECT item_key
   INTO l_header_id
   FROM wf_item_activity_statuses
   where notification_id = to_number(document_id);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
-- Begin Changes for bug 8570400
       BEGIN
          SELECT item_key
          INTO l_header_id
          FROM wf_item_activity_statuses_h
          where notification_id = to_number(document_id);
       EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
    -- if viewing method is email
          l_header_id := to_number(wf_engine.setctx_itemkey);
       END;    -- End Changes for bug 8570400
  END;

   SELECT order_number, order_type_id, order_category_code
   into l_order_number, l_order_type_id, l_order_category_code
   from oe_order_headers_all
   where header_id = l_header_id;

   SELECT T.NAME
   INTO   l_order_type_name
   FROM OE_TRANSACTION_TYPES_TL T
   WHERE T.LANGUAGE = userenv('LANG')
   AND T.TRANSACTION_TYPE_ID = l_order_type_id;

   fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
   fnd_message.set_token('ORDER_TYPE', l_order_type_name);
   l_order_type_txt := fnd_message.get;

   IF l_order_category_code = 'RETURN' THEN
     fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
     fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
     l_header_txt := fnd_message.get;
   ELSE
     fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
     fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
     l_header_txt := fnd_message.get;
   END IF;
   document := substrb(l_order_type_txt || ', ' || l_header_txt, 1, 240);


EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Set_Header_Descriptor'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END Set_Header_Descriptor;


PROCEDURE Set_Line_Descriptor(document_id in varchar2,
                            display_type in varchar2,
                            document in out NOCOPY /* file.sql.39 change */ varchar2,
                            document_type in out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_header_id NUMBER;
l_line_id NUMBER;
l_order_number NUMBER;
l_order_type_id NUMBER;
l_order_type_name VARCHAR2(80);
l_order_category_code VARCHAR2(30);
l_order_type_txt VARCHAR2(2000);
l_line_txt VARCHAR2(2000);
l_line_number NUMBER;
l_shipment_number NUMBER;
l_option_number NUMBER;
l_service_number NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   document_type := display_type;
  BEGIN
   -- if viewing method is through URL
   -- fix bug 1332384
   SELECT item_key
   INTO l_line_id
   FROM wf_item_activity_statuses
   where notification_id = to_number(document_id);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
-- Begin Changes for bug 8570400
       BEGIN
          SELECT item_key
          INTO l_line_id
          FROM wf_item_activity_statuses_h
          WHERE notification_id = to_number(document_id);
       EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          NULL;
        WHEN NO_DATA_FOUND THEN
    -- if viewing method is email
     l_line_id := to_number(wf_engine.setctx_itemkey);
       END;    -- End Changes for bug 8570400
  END;
   SELECT header_id, line_number, shipment_number, option_number, service_number
   into l_header_id, l_line_number, l_shipment_number, l_option_number, l_service_number
   FROM oe_order_lines_all
   WHERE line_id = l_line_id;

   SELECT order_number, order_type_id, order_category_code
   into l_order_number, l_order_type_id, l_order_category_code
   from oe_order_headers_all
   where header_id = l_header_id;

   SELECT T.NAME
   INTO   l_order_type_name
   FROM OE_TRANSACTION_TYPES_TL T
   WHERE T.LANGUAGE = userenv('LANG')
   AND T.TRANSACTION_TYPE_ID = l_order_type_id;

   fnd_message.set_name('ONT', 'OE_WF_ORDER_TYPE');
   fnd_message.set_token('ORDER_TYPE', l_order_type_name);
   l_order_type_txt := fnd_message.get;

   IF l_order_category_code = 'RETURN' THEN
     fnd_message.set_name('ONT', 'OE_WF_RETURN_LINE');
     fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
     fnd_message.set_token('LINE_NUMBER', to_char(l_line_number));
     fnd_message.set_token('SHIPMENT_NUMBER', to_char(l_shipment_number));
     fnd_message.set_token('OPTION_NUMBER', to_char(l_option_number));
     fnd_message.set_token('SERVICE_NUMBER', to_char(l_service_number));
     l_line_txt := fnd_message.get;
   ELSE
     fnd_message.set_name('ONT', 'OE_WF_LINE');
     fnd_message.set_token('ORDER_NUMBER', to_char(l_order_number));
     fnd_message.set_token('LINE_NUMBER', to_char(l_line_number));
     fnd_message.set_token('SHIPMENT_NUMBER', to_char(l_shipment_number));
     fnd_message.set_token('OPTION_NUMBER', to_char(l_option_number));
     fnd_message.set_token('SERVICE_NUMBER', to_char(l_service_number));
     l_line_txt := fnd_message.get;
   END IF;

   document := substrb(l_order_type_txt || ', ' || l_line_txt, 1, 240);

EXCEPTION
     WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        OE_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME
        , 'Set_Line_Descriptor'
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END Set_Line_Descriptor;


PROCEDURE Set_Header_User_Key(p_header_rec IN OE_Order_PUB.Header_Rec_Type)
IS
sales_order VARCHAR2(240);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
if p_header_rec.order_category_code = 'RETURN' then
  fnd_message.set_name('ONT', 'OE_WF_RETURN_ORDER');
else
  fnd_message.set_name('ONT', 'OE_WF_SALES_ORDER');
end if;

fnd_message.set_token('ORDER_NUMBER', to_char(p_header_rec.order_number));

EXCEPTION
WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Set_Header_User_Key'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
END Set_Header_User_Key;

PROCEDURE Set_Line_User_Key(p_line_rec IN OE_Order_PUB.Line_Rec_Type)
IS
l_header_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  l_header_id := p_line_rec.header_id;

  -- Performance Bug 1929163:
  -- Use cached header rec to get header values instead
  -- of a query to select the values.

  OE_Order_Cache.Load_Order_Header(l_header_id);

  if OE_Order_Cache.g_header_rec.order_category_code = 'RETURN' THEN
    fnd_message.set_name('ONT', 'OE_WF_RETURN_LINE');
  else
    fnd_message.set_name('ONT', 'OE_WF_LINE');
  end if;

  fnd_message.set_token('ORDER_NUMBER',
                            to_char(OE_Order_Cache.g_header_rec.order_number));
  fnd_message.set_token('LINE_NUMBER', to_char(p_line_rec.line_number));
  fnd_message.set_token('SHIPMENT_NUMBER', to_char(p_line_rec.shipment_number));
  fnd_message.set_token('OPTION_NUMBER', to_char(p_line_rec.option_number));
  fnd_message.set_token('SERVICE_NUMBER', to_char(p_line_rec.service_number));


EXCEPTION
WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Set_Line_User_Key'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
END Set_Line_User_Key;



-- This procedure starts the flow, by calling WF_ENGINE utilities.
--
PROCEDURE Start_Flow
(  p_itemtype in varchar2
,  p_itemkey  in varchar2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN START_FLOW' ) ;
   END IF;

   WF_ENGINE.StartProcess(p_itemtype, p_itemkey);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING START_FLOW' ) ;
   END IF;
EXCEPTION
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Flow'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Start_flow;

PROCEDURE Start_LineFork
(p_itemkey IN Varchar2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN START_LINEFORK' ) ;
    END IF;

    WF_ENGINE.StartForkProcess('OEOL', p_itemkey);

    -- Refresh old notifications here if needed.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING START_LINEFORK' ) ;
    END IF;


EXCEPTION


  WHEN OTHERS THEN
                IF wf_core.error_name = 'WFENG_NOFORK_ONERROR' THEN
                          FND_MESSAGE.SET_NAME('ONT','OE_WF_SPLIT_FORK_ERR');
          OE_MSG_PUB.ADD;
             END IF;
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                 ,   'Start_LineFork'
          );
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

END Start_LineFork;

-- This process is called from OE_ORDER_PVT.HEader to create the
-- Header workitem and start the flow.

PROCEDURE CreateStart_HdrProcess
( p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
)
IS
--
l_count NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATESTART_HDRPROCESS' ) ;
  END IF;

  Create_HdrWorkItem(p_header_rec);

  -- We do not start the flow when the record is written, rather
  -- when the transaction is committed. Here we will set the
  -- Global.
  OE_GLOBALS.G_START_HEADER_FLOW := p_header_rec.header_id;

  -- For OENH
  -- Check if a OENH flow exists, if so set the parent
  SELECT count(1)
  INTO l_count
  FROM wf_items
  WHERE item_type=OE_GLOBALS.G_WFI_NGO
  AND   item_key =to_char(p_header_rec.header_id);

  IF l_count > 0 THEN
     WF_ITEM.Set_Item_Parent(OE_GLOBALS.G_WFI_HDR,
                             to_char(p_header_rec.header_id),
                             OE_GLOBALS.G_WFI_NGO,
                             to_char(p_header_rec.header_id), '');
  END IF;



  /* Start_Flow(OE_GLOBALS.G_WFI_HDR, p_header_rec.header_id); */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATESTART_HDRPROCESS' ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN -- 2590433
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_HdrProcess'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END CreateStart_HdrProcess;

-- This procedure creates the Header WorkItem
--
PROCEDURE Create_HdrWorkItem
(  p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
)
IS
  l_hdr_process_name VARCHAR2(30);
  l_aname  wf_engine.nametabtyp;
  l_aname2  wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;

  sales_order VARCHAR2(240);
  l_user_name VARCHAR2(100);
  l_validate_user NUMBER;
  l_owner_role VARCHAR2(100);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATE_HDRWORKITEM' ) ;
  END IF;


  -- Get name of Header Process
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET HEADER PROCESS NAME' ) ;
  END IF;
  l_hdr_process_name := Get_ProcessName(p_itemtype => OE_GLOBALS.G_WFI_HDR, p_itemkey => p_header_rec.header_id);

  Set_Header_User_Key(p_header_rec);
  sales_order := substrb(fnd_message.get, 1, 240);

  SELECT user_name
  INTO l_owner_role
  FROM FND_USER
  WHERE USER_ID = FND_GLOBAL.USER_ID;
  -- Create Header Work item
  WF_ENGINE.CreateProcess(OE_Globals.G_WFI_HDR,to_char(p_header_rec.header_id),
                                                   l_hdr_process_name,
                                                   sales_order,
                                                   l_owner_role);

  WF_ENGINE.additemattr(OE_Globals.G_WFI_HDR,to_char(p_header_rec.header_id),
                                                      '#WAITFORDETAIL',null,0);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER WF_ENGINE.CREATEPROCESS' ) ;
  END IF;

  -- Set various Header Attributes
  l_aname(1) := 'USER_ID';
  l_avalue(1) := FND_GLOBAL.USER_ID;
  l_aname(2) := 'APPLICATION_ID';
  l_avalue(2) := FND_GLOBAL.RESP_APPL_ID;
  l_aname(3) := 'RESPONSIBILITY_ID';
  l_avalue(3) := FND_GLOBAL.RESP_ID;
  l_aname(4) := 'ORG_ID';
  l_avalue(4) := to_number(OE_GLOBALS.G_ORG_ID);
  l_aname(5) := 'ORDER_NUMBER';
  l_avalue(5) := p_header_rec.order_number;

  wf_engine.SetItemAttrNumberArray( OE_GLOBALS.G_WFI_HDR
                              , p_header_rec.header_id
                              , l_aname
                              , l_avalue
                              );

/* new logic to get FROM_ROLE */
  BEGIN
  select user_name
  into l_user_name
  from fnd_user
  where user_id = FND_GLOBAL.USER_ID;

  EXCEPTION
    WHEN OTHERS THEN
      l_user_name := null; -- do not set FROM_ROLE then
  END;


  l_aname2(1) := 'ORDER_CATEGORY';
  l_avaluetext(1) := p_header_rec.order_category_code;
  l_aname2(2) := 'NOTIFICATION_APPROVER';
  l_avaluetext(2) := FND_PROFILE.VALUE('OE_NOTIFICATION_APPROVER');
  l_aname2(3) := 'NOTIFICATION_FROM_ROLE';
  l_avaluetext(3) := l_user_name;
  l_aname2(4) := 'ORDER_DETAILS_URL';
  l_avaluetext(4) := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/')||
                     '/OA_HTML/OA.jsp?akRegionCode=ORDER_DETAILS_PAGE' || '&' ||
                     'akRegionApplicationId=660' || '&' || 'HeaderId=' || to_char(p_header_rec.header_id);


  wf_engine.SetItemAttrTextArray( OE_GLOBALS.G_WFI_HDR
                             , p_header_rec.header_id
                             , l_aname2
                             , l_avaluetext
                             );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATE_HDRWORKITEM' ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN -- 2590433
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_HdrWorkItem'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Create_HdrWorkItem;

-- THis is called from OE_ORDER_PVT.LINES to create the Line
-- workitem and start the line flow.

PROCEDURE CreateStart_LineProcess
( p_Line_rec                    IN  OE_Order_PUB.Line_Rec_Type
)
IS
l_item_type varchar2(30);
l_index number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- If this is a Split Insert then we need to fork the flow
  IF p_line_rec.split_from_line_id IS NOT NULL THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SPLIT FROM LINE ID IS NOT NULL' ) ;
     END IF;
     CreateStart_LineFork(p_Line_rec);
  ELSE -- Regular Flow creation
     -- Get Wf itme type
     l_item_type := OE_Order_Wf_Util.get_wf_item_type(p_line_rec);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN CREATESTART_LINEPROCESS' ) ;
     END IF;
     Create_LineWorkItem(p_Line_rec, l_item_type);

     -- We do not start the flow when the record is written, rather
     -- when the transaction is committed.
     -- Start_Flow(OE_GLOBALS.G_WFI_LIN, p_Line_rec.Line_id);
     -- Add line Id to global table for later processing.

     -- Bug 3000619, references to G_START_LINE_FLOWS_TBL are changed.
     IF (OE_GLOBALS.G_START_LINE_FLOWS_TBL.COUNT = 0) THEN
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'G_START_LINE_FLOWS_TBL.COUNT = 0'|| p_Line_rec.ato_Line_id || '-'|| p_Line_rec.Line_id , 2) ;
           END IF;
           OE_GLOBALS.G_START_LINE_FLOWS_TBL(1).line_id := p_Line_rec.Line_id;
           OE_GLOBALS.G_START_LINE_FLOWS_TBL(1).post_write_ato_line_id := p_Line_rec.ato_Line_id;
     ELSE -- the table has entries
           l_index := OE_GLOBALS.G_START_LINE_FLOWS_TBL.LAST;
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'G_START_LINE_FLOWS_TBL.COUNT = ' || to_char(l_index) || p_Line_rec.ato_Line_id || '-'|| p_Line_rec.Line_id, 3 ) ;
           END IF;
           OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_index + 1).line_id := p_Line_rec.Line_id;
           OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_index + 1).post_write_ato_line_id := p_Line_rec.ato_Line_id;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CREATESTART_LINEPROCESS' ) ;
     END IF;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN -- 2590433
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CreateStart_LineProcess'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END CreateStart_LineProcess;

PROCEDURE CreateStart_LineFork
( p_Line_rec                    IN  OE_Order_PUB.Line_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN CREATESTART_LINEFORK' ) ;
    END IF;

    Create_LineFork(p_Line_rec);

    Start_LineFork(p_line_rec.line_id);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING CREATESTART_LINEFORK' ) ;
    END IF;


EXCEPTION
  WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
           OE_MSG_PUB.Add_Exc_Msg
           (   G_PKG_NAME
            ,   'CreateStart_LineFork'
           );
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END CreateStart_LineFork;




-- This procedure creates the Line WorkItem.
--
PROCEDURE Create_LineWorkItem
(  p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type,
   p_item_type  IN VARCHAR2
)
IS
  l_line_process_name VARCHAR2(30);
  l_item_type varchar2(30);
  l_order_number NUMBER;
  l_aname  wf_engine.nametabtyp;
  l_aname2 wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;

  line VARCHAR2(240);
  l_owner_role VARCHAR2(100);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATE_LINEWORKITEM' ) ;
  END IF;
  l_item_type := p_item_type;

  -- Get name of Line Process
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'GET LINE PROCESSNAME' ) ;
  END IF;
   l_line_process_name := Get_ProcessName(p_itemtype => OE_GLOBALS.G_WFI_LIN, p_itemkey => p_Line_rec.line_id, p_wfasgn_item_type => l_item_type, p_line_rec => p_line_rec);

   Set_Line_User_Key(p_line_rec);
  line := substrb(fnd_message.get, 1, 240);

  SELECT user_name
  INTO l_owner_role
  FROM FND_USER
  WHERE USER_ID = FND_GLOBAL.USER_ID;

  -- Create Line Work item
  WF_ENGINE.CreateProcess(OE_Globals.G_WFI_LIN,to_char(p_Line_rec.line_id),
                                                   l_line_process_name,
                                                   line,
                                                   l_owner_role);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER WF_ENGINE.CREATEPROCESS' ) ;
  END IF;


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
                              , p_line_rec.line_id
                              , l_aname
                              , l_avalue
                              );

  l_aname2(1) := 'LINE_CATEGORY';
  l_avaluetext(1) := p_line_rec.line_category_code;
  l_aname2(2) := 'NOTIFICATION_APPROVER';
  l_avaluetext(2) := FND_PROFILE.VALUE('OE_NOTIFICATION_APPROVER');

  wf_engine.SetItemAttrTextArray( OE_GLOBALS.G_WFI_LIN
                             , p_line_rec.line_id
                             , l_aname2
                             , l_avaluetext
                             );

  WF_ITEM.Set_Item_Parent(OE_Globals.G_WFI_LIN,
                          to_char(p_Line_rec.line_id),
                          OE_GLOBALS.G_WFI_HDR,
                          to_char(p_Line_rec.header_id), '',
                          true);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATE_LINEWORKITEM' ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN -- 2590433
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_LineWorkItem'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Create_LineWorkItem;

PROCEDURE Create_LineFork
(p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type
)

IS
l_order_number NUMBER;
l_header_id NUMBER;
line VARCHAR2(240);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN CREATE_LINEFORK' ) ;
     END IF;

        Set_Line_User_Key(p_line_rec);
        line := substrb(fnd_message.get, 1, 240);

        WF_ENGINE.CreateForkProcess('OEOL', p_line_rec.split_from_line_id,
                                            p_line_rec.line_id,
                                            true,
                                            true );

        wf_engine.SetItemUserKey( OE_GLOBALS.G_WFI_LIN
                                , p_line_rec.line_id
                                , line);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING CREATE_LINEFORK' ) ;
     END IF;

EXCEPTION
  WHEN OTHERS THEN
                IF wf_core.error_name = 'WFENG_NOFORK_ONERROR' THEN
                          FND_MESSAGE.SET_NAME('ONT','OE_WF_SPLIT_FORK_ERR');
          OE_MSG_PUB.ADD;
             END IF;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                OE_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME
              ,   'Create_LineFork'
                );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

END Create_LineFork;

FUNCTION Get_Wf_Item_type
(  p_Line_rec                   IN  OE_Order_PUB.Line_Rec_Type
) RETURN VARCHAR2
IS
l_item_rec         OE_ORDER_CACHE.item_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
l_item_rec :=
          OE_Order_Cache.Load_Item (p_line_rec.inventory_item_id
                                      ,p_line_rec.ship_from_org_id);

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ITEM_TYPE_CODE IS ' || P_LINE_REC.ITEM_TYPE_CODE ) ;
END IF;

-- Code for Returns
IF p_line_rec.line_category_code = 'RETURN' THEN
   RETURN 'STANDARD';
END IF;

IF OE_OTA_UTIL.Is_OTA_Line(p_line_rec.order_quantity_uom) THEN

                RETURN 'EDUCATION_ITEM';

--ELSIF ( p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD AND
--   l_item_rec.replenish_to_order_flag = 'Y') OR

-- ## 1820608 ato item under a top pto model should start ato_item flow.

ELSIF ( p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
        p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
	p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED) --9775352
AND     p_line_rec.ato_line_id = p_line_rec.line_id THEN
                RETURN 'ATO_ITEM';

ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL AND
          p_line_rec.line_id = p_line_rec.ato_line_id) THEN

                RETURN 'ATO_MODEL';
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG) THEN

                RETURN 'CONFIGURATION';

ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_INCLUDED) THEN

                RETURN 'II';
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT) THEN

                RETURN 'KIT';
ELSIF (p_line_rec.item_type_code =  OE_GLOBALS.G_ITEM_MODEL AND
       p_line_rec.line_id = p_line_rec.top_model_line_id AND
        p_line_rec.ato_line_id IS NULL) THEN

                RETURN 'PTO_MODEL';
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
        p_line_rec.ato_line_id IS NULL) THEN

                RETURN 'PTO_CLASS';
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
        p_line_rec.ato_line_id IS NULL) THEN

                RETURN 'PTO_OPTION';


-- for ato under pto, we want to start ato model flow
-- even if the item_type_code is class. For ato under ato
-- start standard flow.

ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS AND
        p_line_rec.ato_line_id IS NOT NULL) THEN

      IF p_line_rec.ato_line_id = p_line_rec.line_id
      THEN
          RETURN 'ATO_MODEL';
      ELSE
                RETURN 'ATO_CLASS'; --FP bug no 4572207
      END IF;

ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION AND
        p_line_rec.ato_line_id IS NOT NULL) THEN

                RETURN 'ATO_OPTION'; --FB bug no 4572207
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD) THEN

                RETURN 'STANDARD';
ELSIF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE) THEN

                RETURN 'SERVICE';

ELSE

         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_WF_ITEM_TYPE');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
END IF;

EXCEPTION

WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Get_Wf_Item_Type'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Wf_Item_type;


-- This procedure starts flows for all the Header and Line records created in a Process Order
-- Transaction.  The WF item has been created when the record is written to the db - post_write
-- processing.
PROCEDURE Start_All_Flows
IS

ctr NUMBER;
l_type_id NUMBER;
l_item_type_code VARCHAR2(30);
l_ato_line_id NUMBER;
l_line_id NUMBER;
l_item_type varchar2(30);
l_line_rec oe_order_pub.line_rec_type;
l_header_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ENTERING START_ALL_FLOWS' ) ;
         END IF;

         -- This code should be invoked again, once it starts executing
         -- Starting flows can cause the creation of new lines, but we do not
         -- want the creation call to get in here again.
         IF  (NOT OE_GLOBALS.G_FLOW_PROCESSING_STARTED) THEN
                OE_GLOBALS.G_FLOW_PROCESSING_STARTED := TRUE;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'FLOW PROCESSING STARTED' ) ;
                END IF;

          -- Issue Savepoint
                SAVEPOINT Start_All_Flows;

          -- Check if Header flow needs to be started
          IF (OE_GLOBALS.G_START_HEADER_FLOW IS NOT NULL) THEN

                   BEGIN
                        -- Sanity Check to verify that header exists
                        -- The create of the header could have been rolled back
                        -- but the PL/SQL global is not in synch.
                          Select order_type_id
                          into l_type_id
                          from oe_order_headers_all
                          where header_id = OE_GLOBALS.G_START_HEADER_FLOW;

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'STARTING HEADER FLOW' ) ;
                          END IF;

                         -- Start flow and clear global
                         Start_Flow(OE_GLOBALS.G_WFI_HDR, OE_GLOBALS.G_START_HEADER_FLOW);
                         OE_GLOBALS.G_START_HEADER_FLOW := NULL;

                         EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'HEADER '||OE_GLOBALS.G_START_HEADER_FLOW||' IS MISSING , BUT ID EXISTS IN GLOBAL TABLE' ) ;
                                END IF;
                                OE_GLOBALS.G_START_HEADER_FLOW := NULL;
                   END;


          END IF;

          -- Check if Line Flows need to be started
          IF (OE_GLOBALS.G_START_LINE_FLOWS_TBL.COUNT > 0) THEN

          -- This global table can grow while it is being processed, hence we can cannot
                -- loop thru using first ... count.  Starting a line flow can create included item
                -- lines (booking, scheduling activity).

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'START LINE FLOWS' ) ;
                END IF;

                ctr := OE_GLOBALS.G_START_LINE_FLOWS_TBL.FIRST;

                WHILE (ctr is NOT NULL) LOOP

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'INSIDE LOOP '||'LINE ID IS '||OE_GLOBALS.G_START_LINE_FLOWS_TBL ( CTR ).line_id ) ;
                   END IF;

                   BEGIN

                        -- Sanity Check to verify that line exists
                        -- The create of the line could have been rolled back
                        -- but the PL/SQL table is not in synch.

                        -- Bug 3000619

                        Select line_type_id, item_type_code,
                               ato_line_id, line_id
                          into l_type_id, l_item_type_code,
                               l_ato_line_id, l_line_id
                          from oe_order_lines_all
                          where line_id = OE_GLOBALS.G_START_LINE_FLOWS_TBL(ctr).line_id;

                                     IF l_debug_level  > 0 THEN
                                         oe_debug_pub.add(  'STARTING LINE FLOW '||'LINE ID = ' ||OE_GLOBALS.G_START_LINE_FLOWS_TBL ( CTR ).line_id ) ;
                                     END IF;

                          IF l_item_type_code = 'CLASS' AND
                             l_ato_line_id is not null AND
                             l_ato_line_id <> l_line_id THEN
                            IF l_debug_level  > 0 THEN
                              oe_debug_pub.add('need to check wf assignment for ato under ato under pto, 3');
                            END IF;

                            IF OE_GLOBALS.G_START_LINE_FLOWS_TBL(CTR).post_write_ato_line_id
                               <> l_ato_line_id THEN

                              WF_ENGINE.AbortProcess
                              (itemtype => OE_GLOBALS.G_WFI_LIN,
                               itemkey  => OE_GLOBALS.G_START_LINE_FLOWS_TBL(CTR).line_id);

                              WF_PURGE.Items
                              (itemtype => OE_GLOBALS.G_WFI_LIN,
                               itemkey  => OE_GLOBALS.G_START_LINE_FLOWS_TBL(CTR).line_id,
                               force    => TRUE,
                               docommit => false);

                              OE_Line_Util.Query_Row
                              ( p_line_id   => OE_GLOBALS.G_START_LINE_FLOWS_TBL(CTR).line_id
                               ,x_line_rec  => l_line_rec);

                              l_item_type := OE_Order_Wf_Util.get_wf_item_type(l_line_rec);

                              Create_LineWorkItem(l_line_rec, l_item_type);

                            END IF; -- if post_write_ato_line_id <> l_ato_line_id
                          END IF; -- item_type = CLASS

                          Start_Flow(OE_GLOBALS.G_WFI_LIN, OE_GLOBALS.G_START_LINE_FLOWS_TBL(ctr).line_id); -- End bug 3000619

                   EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                                    IF l_debug_level  > 0 THEN
                                                        oe_debug_pub.add(  'LINE '||OE_GLOBALS.G_START_LINE_FLOWS_TBL ( CTR ).line_id ||' IS MISSING , BUT ID EXISTS IN GLOBAL TABLE' ) ;
                                                    END IF;
                   END;


                   ctr := OE_GLOBALS.G_START_LINE_FLOWS_TBL.NEXT(ctr);

                END LOOP;

                  -- Clear the Global table.
                  OE_GLOBALS.G_START_LINE_FLOWS_TBL.DELETE;

          END IF;

          -- Start OENH/OEBH handling
          IF (OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW IS NOT NULL) THEN
                   BEGIN
                        -- Sanity Check to verify that negotiate header exists
                        -- The create of the header could have been rolled back
                        -- but the PL/SQL global is not in synch.
                          IF OE_GLOBALS.G_SALES_DOCUMENT_TYPE_CODE = 'O' THEN
                            Select header_id
                            into l_header_id
                            from oe_order_headers_all
                            where header_id = OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW;
                          ELSIF OE_GLOBALS.G_SALES_DOCUMENT_TYPE_CODE = 'B' THEN
                             Select header_id
                             into l_header_id
                             from oe_blanket_headers_all
                             where header_id = OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW;
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'STARTING NEGOTIATE HEADER FLOW' ) ;
                          END IF;

                         -- Start flow and clear global
                         Start_Flow(OE_GLOBALS.G_WFI_NGO, OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW);
                         OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW := NULL;

                         EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'Negotiate Header (OENH): '||OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW||' IS MISSING , BUT ID EXISTS IN GLOBAL' ) ;
                                END IF;
                                OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW:= NULL;
                   END;
          END IF;

          IF (OE_GLOBALS.G_START_BLANKET_HEADER_FLOW IS NOT NULL) THEN
                   BEGIN
                        -- Sanity Check to verify that negotiate header exists
                        -- The create of the header could have been rolled back
                        -- but the PL/SQL global is not in synch.
                          Select header_id
                          into l_header_id
                          from oe_blanket_headers_all
                          where header_id = OE_GLOBALS.G_START_BLANKET_HEADER_FLOW;

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'STARTING BLANKET HEADER FLOW' ) ;
                          END IF;

                         -- Start flow and clear global
                         Start_Flow(OE_GLOBALS.G_WFI_BKT, OE_GLOBALS.G_START_BLANKET_HEADER_FLOW);
                         OE_GLOBALS.G_START_BLANKET_HEADER_FLOW := NULL;

                         EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'Blanket Header (OEBH): '||OE_GLOBALS.G_START_BLANKET_HEADER_FLOW||' IS MISSING , BUT ID EXISTS IN GLOBAL' ) ;
                                END IF;
                                OE_GLOBALS.G_START_BLANKET_HEADER_FLOW := NULL;
                   END;
          END IF;

          -- End of OENH/OEBH handling


          -- Reset global value
          OE_GLOBALS.G_FLOW_PROCESSING_STARTED := FALSE;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING START_ALL_FLOWS' ) ;
      END IF;

EXCEPTION
WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Start_All_Flows');

           -- Rollback to savepoint
           ROLLBACK TO Start_All_Flows;
           -- Clear Globals
           Clear_FlowStart_Globals;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

END start_all_flows;

Procedure Clear_FlowStart_Globals
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CLEAR_FLOWSTART_GLOBALS' ) ;
  END IF;

  OE_GLOBALS.G_START_HEADER_FLOW := NULL;
  OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW:= NULL;
  OE_GLOBALS.G_START_BLANKET_HEADER_FLOW := NULL;
  OE_GLOBALS.G_START_LINE_FLOWS_TBL.DELETE;
  OE_GLOBALS.G_FLOW_PROCESSING_STARTED := FALSE;

END Clear_FlowStart_Globals;


PROCEDURE Delete_Row
( p_type  IN VARCHAR2,
  p_id    IN NUMBER

) IS

l_status VARCHAR2(30);
l_result VARCHAR2(240);
l_count  NUMBER;
l_transaction_phase_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OE_ORDER_WF_UTIL.DELETE_ROW' ) ;
       END IF;

       IF p_type = 'HEADER' THEN
                          WF_ENGINE.ItemStatus(itemtype => OE_GLOBALS.G_WFI_HDR,
                                                itemkey => p_id,
                                                status => l_status,
                                                result => l_result);
                          IF l_status <> 'COMPLETE' THEN
                                WF_ENGINE.AbortProcess(itemtype => OE_GLOBALS.G_WFI_HDR,
                                                       itemkey => p_id);
                          END IF;
                          WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_HDR,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);

                          select count(1)
                          into l_count
                          from   wf_items
                          where  item_type=OE_GLOBALS.G_WFI_NGO
                          and    item_key=to_char(p_id);

                          IF l_count > 0 THEN
                             WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_NGO,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);
                          END IF;

	ELSIF p_type = 'LINE' THEN
	    SELECT transaction_phase_code
	    INTO l_transaction_phase_code
	    FROM oe_order_lines_all
	    WHERE line_id = p_id;

	    IF nvl(l_transaction_phase_code, 'F') <> 'N' THEN

                          WF_ENGINE.ItemStatus(itemtype => OE_GLOBALS.G_WFI_LIN,
                                                itemkey => p_id,
                                                status => l_status,
                                                result => l_result);
           --Added the nvl condition to fix bug 2333095
                          IF nvl(l_status,'ACTIVE') <> 'COMPLETE' THEN
                                WF_ENGINE.AbortProcess(itemtype => OE_GLOBALS.G_WFI_LIN,
                                                       itemkey => p_id);
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'PURGING WF ITEM' ) ;
                          END IF;
                          WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_LIN,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);
	    END IF;

       ELSIF p_type = 'NEGOTIATE' THEN
                          WF_ENGINE.ItemStatus(itemtype => OE_GLOBALS.G_WFI_NGO,
                                                itemkey => p_id,
                                                status => l_status,
                                                result => l_result);
                          IF nvl(l_status,'ACTIVE') <> 'COMPLETE' THEN
                                WF_ENGINE.AbortProcess(itemtype => OE_GLOBALS.G_WFI_NGO,
                                                       itemkey => p_id);
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'PURGING WF ITEM - Negotiate') ;
                          END IF;
                          WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_NGO,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);
       ELSIF p_type = 'BLANKET' THEN

-- Bug 8537639
                    select count(1)
                          into   l_count
                          from   wf_items
                          where  item_type=OE_GLOBALS.G_WFI_NGO
                          and    item_key=to_char(p_id);

                          IF l_count > 0 THEN
-- Bug 8537639


                          WF_ENGINE.ItemStatus(itemtype => OE_GLOBALS.G_WFI_BKT,
                                                itemkey => p_id,
                                                status => l_status,
                                                result => l_result);
                          IF nvl(l_status,'ACTIVE') <> 'COMPLETE' THEN
                                WF_ENGINE.AbortProcess(itemtype => OE_GLOBALS.G_WFI_BKT,
                                                       itemkey => p_id);
                          END IF;
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'PURGING WF ITEM - BLANKET') ;
                          END IF;
                          WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_BKT,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);

                     /* Bug 8537639     select count(1)
                          into   l_count
                          from   wf_items
                          where  item_type=OE_GLOBALS.G_WFI_NGO
                          and    item_key=to_char(p_id);

                          IF l_count > 0 THEN     */
                             WF_PURGE.Items(itemtype => OE_GLOBALS.G_WFI_NGO,
                                         itemkey  => p_id,
                                         force    => TRUE,
                                         docommit => false);
                          END IF;

       ELSE
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OE_ORDER_WF_UTIL: DELETE TYPE NOT IN HEADER,LINE,NEGOTIATE,BLANKET' ) ;
                        END IF;
                        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                                THEN
                                        OE_MSG_PUB.Add_Exc_Msg
                                        (   G_PKG_NAME
                                        ,   'Delete_Row'
                                        );
                                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                                        END IF;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_ORDER_WF_UTIL.DELETE_ROW' ) ;
        END IF;

END Delete_Row;

PROCEDURE Update_Flow_Status_Code
                 (
                   p_header_id                 IN         NUMBER DEFAULT NULL,
                   p_line_id                   IN         NUMBER DEFAULT NULL,
                   p_flow_status_code          IN         VARCHAR2,
                   p_item_type                 IN         VARCHAR2 DEFAULT NULL,
                   p_sales_document_type_code  IN         VARCHAR2 DEFAULT NULL,
                   x_return_status             OUT NOCOPY VARCHAR2
                 )
IS
l_flow_status_code              VARCHAR2(30);
l_header_rec                    OE_Order_PUB.Header_Rec_Type;
l_old_header_rec                OE_Order_PUB.Header_Rec_Type;
l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
l_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_return_status                 VARCHAR2(30);
l_source_document_id            NUMBER;
l_source_document_line_id       NUMBER;
l_header_id                     NUMBER;
l_orig_sys_document_ref         VARCHAR2(50);
l_orig_sys_line_ref             VARCHAR2(50);
l_order_source_id               NUMBER;
l_orig_sys_shipment_ref         VARCHAR2(50);
l_change_sequence               VARCHAR2(50);
l_source_document_type_id       NUMBER;
l_index                         NUMBER;
l_blanket_lock_control          NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_itemkey_sso                   number; -- GENESIS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_line_rec                      Oe_Order_Pub.Line_Rec_Type; --OIP ER
Cursor lines IS
   SELECT line_id, lock_control
   FROM OE_ORDER_LINES_ALL
   WHERE HEADER_ID = p_header_id
   FOR UPDATE NOWAIT;

l_line_id                       NUMBER;
l_lock_control                  NUMBER;


BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING UPDATE_FLOW_STATUS_CODE' , 5 ) ;
        oe_debug_pub.add('UFSC: GLOBAL RECURSION WITHOUT EXCEPTION: ' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION) ;
        oe_debug_pub.add('UFSC: GLOBAL CACHE BOOKED FLAG' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add('UFSC: GLOBAL PICTURE HEADER BOOKED FLAG' || OE_ORDER_UTIL.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE TABLE= '|| OE_ORDER_UTIL.G_LINE_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_HEADER_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_LINE_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_LOT_SERIAL_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_OLD_LOT_SERIAL_TBL.COUNT ) ;
    END IF;

    SAVEPOINT UPDATE_FLOW_STATUS_CODE;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if the ASO is installed to call the NOTIFY_OC.
    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    -- *** Negotiation Changes Start ***
    IF p_item_type in (OE_GLOBALS.G_WFI_NGO, OE_GLOBALS.G_WFI_BKT) THEN
      IF p_header_id IS NOT NULL THEN
         -- validate p_flow_status
         SELECT lookup_code
         INTO   l_flow_status_code
         FROM   oe_lookups
         WHERE  lookup_type= 'FLOW_STATUS'
         AND    lookup_code = p_flow_status_code
         AND    enabled_flag = 'Y'
         AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE);

         IF p_item_type = OE_GLOBALS.G_WFI_NGO THEN

            IF p_sales_document_type_code is null THEN
               -- for Negotiation, you must pass the document type code
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF p_sales_document_type_code = 'O' THEN
             IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Update_Flow_Status_Code for Quote:'  || p_flow_status_code, 5 ) ;
             END IF;
               OE_Header_Util.Lock_Row(p_header_id=>p_header_id
                                         , p_x_header_rec=>l_header_rec
                                         , x_return_status => l_return_status);
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

                   -- is entity HEADER correct?
               OE_MSG_PUB.set_msg_context
                   ( p_entity_code             => 'HEADER'
                    ,p_entity_id               => l_header_rec.header_id
                    ,p_header_id               => l_header_rec.header_id
                    ,p_line_id                 => null
                    ,p_order_source_id         => l_header_rec.order_source_id
                    ,p_orig_sys_document_ref   => l_header_rec.orig_sys_document_ref
                    ,p_orig_sys_document_line_ref  => null
                    ,p_change_sequence         => l_header_rec.change_sequence
                    ,p_source_document_type_id     => l_header_rec.source_document_type_id
                    ,p_source_document_id      => l_header_rec.source_document_id
                    ,p_source_document_line_id => null );

                    l_old_header_rec := l_header_rec;

               UPDATE OE_ORDER_HEADERS_ALL
               SET FLOW_STATUS_CODE = p_flow_status_code
                   --Bug 8435596
                   , last_update_date  = SYSDATE
                   , last_updated_by   = FND_GLOBAL.USER_ID
                   , last_update_login = FND_GLOBAL.LOGIN_ID
               ,   LOCK_CONTROL = LOCK_CONTROL + 1
               WHERE HEADER_ID = p_header_id;

               -- Also update all lines to have the same flow_status_code for quotes
               Open Lines;
               Loop
                 FETCH lines into l_line_id, l_lock_control;
                 EXIT WHEN Lines%NOTFOUND;
               End Loop;
               Close Lines;

               UPDATE OE_ORDER_LINES_ALL
               SET FLOW_STATUS_CODE = p_flow_status_code
                   --Bug 8435596
                   , last_update_date  = SYSDATE
                   , last_updated_by   = FND_GLOBAL.USER_ID
                   , last_update_login = FND_GLOBAL.LOGIN_ID
                   , LOCK_CONTROL = LOCK_CONTROL + 1
               WHERE HEADER_ID = p_header_id;


               l_header_rec.flow_status_code := p_flow_status_code;
               l_header_rec.lock_control := l_header_rec.lock_control + 1;

                    -- aksingh performance
                    -- As the update is on headers table, it is time to update
                    -- cache also!
               OE_Order_Cache.Set_Order_Header(l_header_rec);

                    -- Bug 1755817: clear the cached constraint results for header entity
                    -- when order header is updated.
               OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
                          (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

                    -- added for notification framework
                    -- calling notification framework to get index position
               OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                p_old_header_rec => l_old_header_rec,
                p_Header_rec     => l_header_rec,
                p_header_id      => p_header_id,
                x_index          => l_index,
                x_return_status  => l_return_status);

               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('UPDATE_GLOBAL RETURN STATUS FROM OE_WF_ORDER_UTIL.UPDATE HEADER FLOW STATUS CODE IS: ' || L_RETURN_STATUS ) ;
                 oe_debug_pub.add(  'INDEX IS: ' || L_INDEX , 1 ) ;
                 oe_debug_pub.add(  'HEADER FLOW STATUS IS: ' || P_FLOW_STATUS_CODE , 1 ) ;
               END IF;

               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               IF l_index is not NULL THEN
               -- update global picture directly
                 OE_ORDER_UTIL.g_header_rec := OE_ORDER_UTIL.g_old_header_rec;
                 OE_ORDER_UTIL.g_header_rec.flow_status_code:=p_flow_status_code;
                 OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
                 OE_ORDER_UTIL.g_header_rec.operation:=OE_GLOBALS.G_OPR_UPDATE;
                 IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'GLOBAL HEADER FLOW STATUS IS: ' || OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE,1);
                   oe_debug_pub.add(  'GLOBAL HEADER OPERATION IS: ' || OE_ORDER_UTIL.G_HEADER_REC.OPERATION,1);
                 END IF;
               END IF;
               -- bug 4732614
               IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('OEXUOWFB.pls: Calling Process_Requests_And_Notify......', 1);
               END IF;

               OE_Order_PVT.Process_Requests_And_Notify
               ( p_header_rec     => l_header_rec
                ,p_old_header_rec => l_old_header_rec
                ,x_return_status  => l_return_status);

               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 IF l_debug_level  > 0 THEN
                   Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_ERROR exception',2);
                 END IF;
                 RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 IF l_debug_level  > 0 THEN
                   Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_UNEXPECTED_ERROR exception',2);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF; -- bug 4732614 ends
            ELSIF p_sales_document_type_code = 'B' THEN -- Blanket Negotitation
             IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Update_Flow_Status_Code for Blanket Negotiation:'  || p_flow_status_code, 5 ) ;
             END IF;

                   SELECT lock_control
                   INTO l_blanket_lock_control
                   FROM oe_blanket_headers_all
                   WHERE header_id = p_header_id
                   FOR UPDATE NOWAIT;

/* avoid dependency on blanket code, do a direct lock row

                   OE_Blanket_Util.Lock_Row(p_blanket_id=>p_header_id
                                         , p_blanket_line_id => null
                                         , p_x_lock_control=>l_blanket_lock_control
                                         , x_return_status => l_return_status
                                         , x_msg_count => l_msg_count
                                         , x_msg_data => l_msg_data);
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                   OE_MSG_PUB.set_msg_context
                   ( p_entity_code             => 'BLANKET'
                    ,p_entity_id               => p_header_id
                    ,p_header_id               => p_header_id);


*/
                    UPDATE OE_BLANKET_HEADERS_ALL
                    SET FLOW_STATUS_CODE = p_flow_status_code
                       --Bug 8435596
                       , last_update_date  = SYSDATE
                       , last_updated_by   = FND_GLOBAL.USER_ID
                       , LOCK_CONTROL = LOCK_CONTROL + 1
                    WHERE HEADER_ID = p_header_id;

            END IF; --check sales_document_type_code

         ELSIF p_item_type = OE_GLOBALS.G_WFI_BKT THEN
            IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Update_Flow_Status_Code for Blanket Fulfillment:'  || p_flow_status_code, 5 ) ;
            END IF;

            -- lock row or select for update here
                   SELECT lock_control
                   INTO l_blanket_lock_control
                   FROM oe_blanket_headers_all
                   WHERE header_id = p_header_id
                   FOR UPDATE NOWAIT;

/* avoid dependency on blanket API
            OE_Blanket_Util.Lock_Row(p_blanket_id=>p_header_id
                                  , p_blanket_line_id => null
                                  , p_x_lock_control=>l_blanket_lock_control
                                  , x_return_status => l_return_status
                                  , x_msg_count => l_msg_count
                                  , x_msg_data => l_msg_data);
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
*/
  -- set msg context follows

            UPDATE OE_BLANKET_HEADERS_ALL
            SET FLOW_STATUS_CODE = p_flow_status_code
                --Bug 8435596
                , last_update_date  = SYSDATE
                , last_updated_by   = FND_GLOBAL.USER_ID
                , last_update_login = FND_GLOBAL.LOGIN_ID
            ,   LOCK_CONTROL = LOCK_CONTROL + 1
            WHERE HEADER_ID = p_header_id;


         END IF;

       END IF; -- p_header_id is not null


    ELSE
    -- *** END negotiation/blanket changes ***


-- regular processing for OEOH/OEOL starts below


-- we will process the line_id if both header id and line id are passed

     IF p_line_id IS NOT NULL THEN
     -- validate p_flow_status

           SELECT lookup_code
           INTO l_flow_status_code
           FROM oe_lookups
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = p_flow_status_code
           AND    enabled_flag = 'Y'
           AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE);

       IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  ) THEN

           OE_Line_Util.Lock_Rows
                        (p_line_id=>p_line_id
                        , x_line_tbl=>l_old_line_tbl
                        , x_return_status => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                           RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

           OE_MSG_PUB.set_msg_context
             ( p_entity_code             => 'LINE'
             ,p_entity_id               => l_old_line_tbl(1).line_id
             ,p_header_id               => l_old_line_tbl(1).header_id
             ,p_line_id                 => l_old_line_tbl(1).line_id
             ,p_order_source_id         => l_old_line_tbl(1).order_source_id
             ,p_orig_sys_document_ref   => l_old_line_tbl(1).orig_sys_document_ref
             ,p_orig_sys_document_line_ref  => l_old_line_tbl(1).orig_sys_line_ref
             ,p_orig_sys_shipment_ref   => l_old_line_tbl(1).orig_sys_shipment_ref
             ,p_change_sequence         => l_old_line_tbl(1).change_sequence
             ,p_source_document_type_id => l_old_line_tbl(1).source_document_type_id
             ,p_source_document_id      => l_old_line_tbl(1).source_document_id
             ,p_source_document_line_id => l_old_line_tbl(1).source_document_line_id );

           l_line_tbl := l_old_line_tbl;

         ELSE
             SELECT source_document_id,
                    source_document_line_id,
                    header_id,
                    orig_sys_document_ref,
                    orig_sys_line_ref,
                    order_source_id,
                    orig_sys_shipment_ref,
                    change_sequence,
                    source_document_type_id
             INTO   l_source_document_id,
                    l_source_document_line_id,
                    l_header_id,
                    l_orig_sys_document_ref,
                    l_orig_sys_line_ref,
                    l_order_source_id,
                    l_orig_sys_shipment_ref,
                    l_change_sequence,
                    l_source_document_type_id
             FROM   OE_ORDER_LINES_ALL
             WHERE line_id = p_line_id
             FOR UPDATE NOWAIT;

             OE_MSG_PUB.set_msg_context
             ( p_entity_code               => 'LINE'
             ,p_entity_id                  => p_line_id
             ,p_header_id                  => l_header_id
             ,p_line_id                    => p_line_id
             ,p_order_source_id            => l_order_source_id
             ,p_orig_sys_document_ref      => l_orig_sys_document_ref
             ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
             ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
             ,p_change_sequence            => l_change_sequence
             ,p_source_document_type_id    => l_source_document_type_id
             ,p_source_document_id         => l_source_document_id
             ,p_source_document_line_id    => l_source_document_line_id );

             --7138604 : l_line_tbl(1) is used below, so it has to be
             -- initialized in order to prevent NO_DATA_FOUND exception
             l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;

         END IF;
     ELSIF p_header_id IS NOT NULL THEN
     -- validate p_flow_status

             SELECT lookup_code
             INTO l_flow_status_code
             FROM oe_lookups
             WHERE lookup_type = 'FLOW_STATUS'
             AND lookup_code = p_flow_status_code
             AND    enabled_flag = 'Y'
             AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE);


         OE_Header_Util.Lock_Row
                        (p_header_id=>p_header_id
                        , p_x_header_rec=>l_header_rec
                        , x_return_status => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                             RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

         OE_MSG_PUB.set_msg_context
             ( p_entity_code             => 'HEADER'
             ,p_entity_id               => l_header_rec.header_id
             ,p_header_id               => l_header_rec.header_id
             ,p_line_id                 => null
             ,p_order_source_id         => l_header_rec.order_source_id
             ,p_orig_sys_document_ref   => l_header_rec.orig_sys_document_ref
             ,p_orig_sys_document_line_ref  => null
             ,p_change_sequence         => l_header_rec.change_sequence
             ,p_source_document_type_id     => l_header_rec.source_document_type_id
             ,p_source_document_id      => l_header_rec.source_document_id
             ,p_source_document_line_id => null );

         l_old_header_rec := l_header_rec;
     END IF;

     IF p_line_id is NOT NULL THEN

         UPDATE OE_ORDER_LINES_ALL
         SET FLOW_STATUS_CODE = p_flow_status_code,
                   last_update_date = SYSDATE,
                   last_updated_by = FND_GLOBAL.USER_ID,
                   last_update_login = FND_GLOBAL.LOGIN_ID,
                  LOCK_CONTROL = LOCK_CONTROL + 1
         WHERE LINE_ID = p_line_id;

         --OIP SUN ER Changes
	          if p_flow_status_code ='SHIPPED' THEN
	             Oe_Line_Util.Query_Row(p_line_id, l_line_rec);
	             OE_ORDER_UTIL.RAISE_BUSINESS_EVENT(l_line_rec.header_id,
	 	    	                               l_line_rec.line_id,
	 	    	                               p_flow_status_code);
         end if;

     IF ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
         (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  ) THEN


            l_line_tbl(1).flow_status_code := p_flow_status_code;
            l_line_tbl(1).lock_control := l_line_tbl(1).lock_control + 1;

       -- added for notification framework
             -- calling notification framework to get index position
           OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_header_id => l_line_tbl(1).header_id,
                    p_old_line_rec => l_old_line_tbl(1),
                    p_line_rec =>l_line_tbl(1),
                    p_line_id => p_line_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_WF_ORDER_UTIL.UPDATE LINE FLOW STATUS CODE IS: ' || L_RETURN_STATUS ) ;
                oe_debug_pub.add(  'INDEX IS: ' || L_INDEX , 1 ) ;
            END IF;
          --OE_DEBUG_PUB.ADD('Line Flow Status is: ' || p_flow_status_code ,1);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

           IF l_index is not NULL THEN

           -- update global picture directly
           -- First copy the old picture to the new and then update the
           -- changed columns for the new global table.
           OE_ORDER_UTIL.g_old_line_tbl(l_index) := l_old_line_tbl(1); --Added for bug 5842114
           OE_ORDER_UTIL.g_line_tbl(l_index) := OE_ORDER_UTIL.g_old_line_tbl(l_index);
           OE_ORDER_UTIL.g_line_tbl(l_index).flow_status_code:=p_flow_status_code;
           OE_ORDER_UTIL.g_line_tbl(l_index).lock_control:=l_line_tbl(1).lock_control;
           OE_ORDER_UTIL.g_line_tbl(l_index).line_id:=l_line_tbl(1).line_id;
           OE_ORDER_UTIL.g_line_tbl(l_index).header_id:=l_line_tbl(1).header_id;
           OE_ORDER_UTIL.g_line_tbl(l_index).last_update_date:=l_line_tbl(1).last_update_date;
           OE_ORDER_UTIL.g_line_tbl(l_index).operation:=OE_GLOBALS.G_OPR_UPDATE;
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'GLOBAL LINE FLOW STATUS IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_INDEX ) .FLOW_STATUS_CODE , 1 ) ;
               oe_debug_pub.add(  'GLOBAL LINE OPERATION IS: ' || OE_ORDER_UTIL.G_LINE_TBL ( L_INDEX ) .OPERATION , 1 ) ;
             END IF;
           END IF;
           -- bug 4732614
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('OEXUOWFB.pls: Calling Process_Requests_And_Notify......', 1);
           END IF;

           OE_Order_PVT.Process_Requests_And_Notify
           ( p_line_tbl       => l_line_tbl
            ,p_old_line_tbl   => l_old_line_tbl
            ,x_return_status  => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
               Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_ERROR exception',2);
             END IF;
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             IF l_debug_level  > 0 THEN
               Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_UNEXPECTED_ERROR exception',2);
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF; -- bug 4732614 ends
        END IF; /*ASO installed */

         OE_MSG_PUB.Reset_Msg_Context('LINE');
     /********************GENESIS********************************
     *  Some statuses are not going through process order and   *
     *  the update_flow_status is getting called directly. So   *
     *  we need to call synch_header_line for AIA enabled order *
     *  sources.                                                *
     ***********************************************************/
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - p_header_id: ' || p_header_id);
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - p_line_id: ' || p_line_id);
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - l_header_rec.order_source_id: ' || l_header_rec.order_source_id);
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - l_order_source_id: ' || l_order_source_id);
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - l_line_tbl(1).order_source_id: ' || l_line_tbl(1).order_source_id);
            oe_debug_pub.add(' GENESIS : UPDATE FLOW STATUS - l_line_tbl(1).header_id: '||l_line_tbl(1).header_id);
            oe_debug_pub.ADD(' GENESIS : UPDATE FLOW STATUS - g_aso_installed: ' || oe_globals.g_aso_installed);
            oe_debug_pub.ADD(' GENESIS : UPDATE FLOW STATUS - DBI Installed: ' ||
                        Nvl(fnd_profile.Value('ONT_DBI_INSTALLED'), 'No.'));
            oe_debug_pub.ADD(' GENESIS : UPDATE FLOW STATUS - p_flow_status_code: ' ||
                        p_flow_status_code);
         END IF;

     IF NOT ( (OE_GLOBALS.G_ASO_INSTALLED = 'Y') OR
                (NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') = 'Y')  )
        AND
        (
          (Oe_Genesis_Util.source_aia_enabled(l_order_source_id)) OR
          (Oe_Genesis_Util.source_aia_enabled(l_line_tbl(1).order_source_id))
        )
        AND
           Oe_Genesis_Util.Status_Needs_Sync(p_flow_status_code)
     THEN
            oe_line_util.query_row(
                                   p_line_id  => p_line_id
                                  ,x_line_rec => l_line_tbl(1)
                                  );

           l_line_tbl(1).flow_status_code := p_flow_status_code;
           l_line_tbl(1).lock_control     := l_line_tbl(1).lock_control + 1;

            OE_Header_UTIL.Query_Row
                 (p_header_id            => l_line_tbl(1).header_id
                 ,x_header_rec           => l_header_rec
                 );

            select OE_XML_MESSAGE_SEQ_S.nextval
            into l_itemkey_sso
            from dual;

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  ' GENESIS : UPDATE FLOW STATUS - l_itemkey_sso'||l_itemkey_sso);
            END IF;

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  ' GENESIS : UPDATE FLOW STATUS');
            END IF;

            OE_SYNC_ORDER_PVT.INSERT_SYNC_lINE(P_LINE_rec       => l_line_tbl(1),
  	                                           p_change_type   => 'LINE_STATUS',
	                                             p_req_id        => l_itemkey_sso,
  	                                           X_RETURN_STATUS => L_RETURN_STATUS);

            OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE( p_header_rec          => l_header_rec
                                               ,p_line_rec            => null
                                               ,p_hdr_req_id          => l_itemkey_sso
                                               ,p_lin_req_id          => l_itemkey_sso
                                               ,p_change_type         => 'LINE_STATUS');
        END IF;
    -- GENESIS --

     ELSIF p_header_id IS NOT NULL THEN

           UPDATE OE_ORDER_HEADERS_ALL
           SET FLOW_STATUS_CODE = p_flow_status_code
               --Bug 8435596
               , last_update_date  = SYSDATE
               , last_updated_by   = FND_GLOBAL.USER_ID
               , last_update_login = FND_GLOBAL.LOGIN_ID
               , LOCK_CONTROL = LOCK_CONTROL + 1
           WHERE HEADER_ID = p_header_id;

           l_header_rec.flow_status_code := p_flow_status_code;
                 l_header_rec.lock_control := l_header_rec.lock_control + 1;

           -- aksingh performance
           -- As the update is on headers table, it is time to update
           -- cache also!
           OE_Order_Cache.Set_Order_Header(l_header_rec);

           -- Bug 1755817: clear the cached constraint results for header entity
           -- when order header is updated.
           OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
                 (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

           -- added for notification framework
             -- calling notification framework to get index position
           OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                    p_old_header_rec => l_old_header_rec,
                    p_Header_rec =>l_header_rec,
                    p_header_id => p_header_id,
                    x_index => l_index,
                    x_return_status => l_return_status);

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_WF_ORDER_UTIL.UPDATE HEADER FLOW STATUS CODE IS: ' || L_RETURN_STATUS ) ;
              oe_debug_pub.add(  'INDEX IS: ' || L_INDEX , 1 ) ;
              oe_debug_pub.add(  'HEADER FLOW STATUS IS: ' || P_FLOW_STATUS_CODE , 1 ) ;
          END IF;
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

         IF l_index is not NULL THEN
          -- update global picture directly
          OE_ORDER_UTIL.g_header_rec := OE_ORDER_UTIL.g_old_header_rec;
          OE_ORDER_UTIL.g_header_rec.flow_status_code:=p_flow_status_code;
          OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
          OE_ORDER_UTIL.g_header_rec.operation:=OE_GLOBALS.G_OPR_UPDATE;
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'GLOBAL HEADER FLOW STATUS IS: ' || OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE , 1 ) ;
              oe_debug_pub.add(  'GLOBAL HEADER OPERATION IS: ' || OE_ORDER_UTIL.G_HEADER_REC.OPERATION , 1 ) ;
            END IF;
          END IF;
         -- bug 4732614
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('OEXUOWFB.pls: Calling Process_Requests_And_Notify......', 1);
         END IF;

         OE_Order_PVT.Process_Requests_And_Notify
         ( p_header_rec     => l_header_rec
          ,p_old_header_rec => l_old_header_rec
          ,x_return_status  => l_return_status);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
             Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_ERROR exception',2);
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
             Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_UNEXPECTED_ERROR exception',2);
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF; -- bug 4732614 ends
     ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATE_FLOW_STATUS_CODE: HEADER_ID AND LINE_ID ARE NULL' ) ;
           END IF;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END IF;

    END IF; -- End of OENH/OEBH vs OEOH/OEOL processing

    --Bug 3356542
    OE_PC_Constraints_Admin_PVT.Clear_Cached_Results;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ENTERING UPDATE_FLOW_STATUS_CODE' , 5 ) ;
        oe_debug_pub.add('UFSC: GLOBAL RECURSION WITHOUT EXCEPTION: ' || OE_ORDER_UTIL.G_RECURSION_WITHOUT_EXCEPTION) ;
        oe_debug_pub.add('UFSC: GLOBAL CACHE BOOKED FLAG' || OE_ORDER_CACHE.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add('UFSC: GLOBAL PICTURE HEADER BOOKED FLAG' || OE_ORDER_UTIL.G_HEADER_REC.BOOKED_FLAG ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE TABLE= '|| OE_ORDER_UTIL.G_LINE_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD HDR ADJ TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_ADJ_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_HEADER_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD HDR SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_HEADER_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_LINE_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LINE SCREDIT TABLE= '|| OE_ORDER_UTIL.G_OLD_LINE_SCREDIT_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF NEW LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_LOT_SERIAL_TBL.COUNT ) ;
        oe_debug_pub.add('UFSC: COUNT OF OLD LOT SERIAL TABLE= '|| OE_ORDER_UTIL.G_OLD_LOT_SERIAL_TBL.COUNT ) ;
        oe_debug_pub.add('EXITING UPDATE_FLOW_STATUS_CODE' , 5 ) ;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UPDATE_FLOW_STATUS_CODE;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_FLOW_STATUS_CODE: NO_DATA_FOUND' ) ;
        END IF;
        IF p_line_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('LINE');
        ELSIF p_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_FLOW_STATUS_CODE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_FLOW_STATUS_CODE: ERROR' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF p_line_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('LINE');
        ELSIF p_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        ROLLBACK TO UPDATE_FLOW_STATUS_CODE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_FLOW_STATUS_CODE: LOCK EXC' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
          OE_MSG_PUB.Add;
        END IF;
        IF p_line_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('LINE');
        ELSIF p_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_FLOW_STATUS_CODE;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_FLOW_STATUS_CODE: UNEXP ERROR' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Flow_Status_Code'
                        );
        END IF;
        IF p_line_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('LINE');
        ELSIF p_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
END Update_Flow_Status_Code;


PROCEDURE Set_Notification_Approver(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
v_id                VARCHAR2(240);
v_value             VARCHAR2(240);
l_type              VARCHAR2(30);
v_header_id         NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN
       l_type := wf_engine.GetActivityAttrText(itemtype, itemkey, actid, 'SOURCE');
       IF l_type = 'PROFILE_APPROVER' THEN
 -- changed call from fnd_profile.value to oe_profile.value to retrieve profile in created_by context
           IF itemtype = 'OEOH' THEN
	     v_value := oe_profile.value(p_header_id => to_number(itemkey),
                                                  p_line_id => null,
                                                  p_profile_option_name => 'OE_NOTIFICATION_APPROVER');
           ELSIF itemtype = 'OEOL' THEN
             v_value := oe_profile.value(p_header_id => null,
                                                  p_line_id => to_number(itemkey),
                                                  p_profile_option_name => 'OE_NOTIFICATION_APPROVER');
           END IF;
       ELSIF l_type = 'ORDER_CREATED_BY' THEN
            IF itemtype = 'OEOH' THEN
                   SELECT  CREATED_BY
                   INTO    v_id
                   FROM    OE_ORDER_HEADERS_ALL
                   WHERE   HEADER_ID = TO_NUMBER(ITEMKEY);
         ELSIF itemtype = 'OEOL' THEN
                            SELECT HEADER_ID
                            INTO   v_header_id
                            FROM   OE_ORDER_LINES_ALL
                            WHERE  LINE_ID = TO_NUMBER(ITEMKEY);

                            SELECT CREATED_BY
                   INTO    v_id
                   FROM    OE_ORDER_HEADERS_ALL
                   WHERE   HEADER_ID = v_header_id;
          END IF;
          SELECT USER_NAME
          INTO   v_value
          FROM   FND_USER
          WHERE  USER_ID = v_id
          AND    (EMPLOYEE_ID is null
                           OR
                           EMPLOYEE_ID in (SELECT PERSON_ID
                                                    FROM PER_PEOPLE_F));
/*
sales rep is not available in
WF view yet

       ELSIF l_type = 'ORDER_SALESPERSON' THEN
                   SELECT SALESREP_ID
                   INTO   v_id
                   FROM   OE_ORDER_HEADERS_ALL
                   WHERE  HEADER_ID = TO_NUMBER(ITEMKEY);
*/
       ELSIF l_type = 'CREATED_BY' THEN
                IF itemtype='OEOH' THEN
                          SELECT CREATED_BY
                          INTO   v_id
                          FROM   OE_ORDER_HEADERS_ALL
                          WHERE  HEADER_ID = TO_NUMBER(ITEMKEY);
           ELSIF itemtype='OEOL' THEN
                    SELECT CREATED_BY
                    INTO   v_id
                    FROM   OE_ORDER_LINES_ALL
                    WHERE  LINE_ID = TO_NUMBER(ITEMKEY);
           END IF;

           SELECT  USER_NAME
           INTO    v_value
           FROM    FND_USER
           WHERE   USER_ID = v_id
           AND     (EMPLOYEE_ID is null
                                OR
                                EMPLOYEE_ID in (SELECT PERSON_ID
                                                         FROM PER_PEOPLE_F));
/*
sales rep is not available in
WF view yet
       ELSIF l_type = 'SALESPERSON' THEN
                IF itemtype='OEOH' THEN
                   SELECT SALESREP_ID
                   INTO   v_id
                   FROM   OE_ORDER_HEADERS_ALL
                   WHERE  HEADER_ID = TO_NUMBER(ITEMKEY);
                ELSIF itemtype='OEOL' THEN
                   SELECT SALESREP_ID
                   INTO   v_id
                   FROM   OE_ORDER_LINES_ALL
                   WHERE  LINE_ID = TO_NUMBER(ITEMKEY);
                END IF;
*/
       END IF;
       wf_engine.SetItemAttrText( itemtype, itemkey,
             -- Bug 9386150: provide a default value for 'v_value'
            'NOTIFICATION_APPROVER', Nvl(v_value, 'SYSADMIN') );
       resultout := 'COMPLETE:COMPLETE';
  END IF;
Exception
       When Others Then
          wf_core.context('', 'Set_Notification_Approver', itemtype, itemkey,
                          to_char(actid), funcmode);
          raise;
End Set_Notification_Approver;

PROCEDURE Update_Quote_Blanket(p_item_type IN VARCHAR2,
                             p_item_key  IN VARCHAR2,
                             p_flow_status_code IN VARCHAR2 DEFAULT NULL,
                             p_open_flag IN VARCHAR2 DEFAULT NULL,
                             p_draft_submitted_flag IN VARCHAR2 DEFAULT NULL,
                             x_return_status OUT NOCOPY VARCHAR2)
IS
l_header_id                     NUMBER;
l_flow_status_code              VARCHAR2(30);
l_header_rec                    OE_Order_PUB.Header_Rec_Type;
l_old_header_rec                OE_Order_PUB.Header_Rec_Type;
l_return_status                 VARCHAR2(30);
l_index                         NUMBER;
l_blanket_lock_control          NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_updated_flag                  VARCHAR2(1) := 'N';
l_sales_document_type_code      VARCHAR2(30);
l_line_id                       NUMBER;
l_lock_control                  NUMBER;

Cursor lines IS
   SELECT line_id, lock_control
   FROM OE_ORDER_LINES_ALL
   WHERE HEADER_ID = l_header_id
   FOR UPDATE NOWAIT;

Cursor blanket_lines IS
   SELECT line_id, lock_control
   FROM OE_BLANKET_LINES_ALL
   WHERE HEADER_ID = l_header_id
   FOR UPDATE NOWAIT;

BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING UPDATE_QUOTE_BLANKET' , 5 ) ;
    END IF;

    SAVEPOINT UPDATE_QUOTE_BLANKET;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if the ASO is installed to call the NOTIFY_OC.
    IF OE_GLOBALS.G_ASO_INSTALLED IS NULL THEN
        OE_GLOBALS.G_ASO_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(697);
    END IF;

    l_header_id := to_number(p_item_key);
    IF p_flow_status_code is not null THEN
         -- if flow_status_code is passed in, validate it
         SELECT lookup_code
         INTO   l_flow_status_code
         FROM   oe_lookups
         WHERE  lookup_type= 'FLOW_STATUS'
         AND    lookup_code = p_flow_status_code
         AND    enabled_flag = 'Y'
         AND    SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND NVL(END_DATE_ACTIVE, SYSDATE);

    END IF;

    IF p_item_type = OE_GLOBALS.G_WFI_BKT THEN
       l_sales_document_type_code := 'B';
    ELSE -- itemtype = OENH
       l_sales_document_type_code := WF_ENGINE.GetItemAttrText(p_item_type, p_item_key, 'SALES_DOCUMENT_TYPE_CODE');
    END IF;


     IF l_sales_document_type_code = 'O' THEN
        OE_Header_Util.Lock_Row(p_header_id=>l_header_id
                                         , p_x_header_rec=>l_header_rec
                                         , x_return_status => l_return_status);
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

                   -- is entity HEADER correct?
        OE_MSG_PUB.set_msg_context
                   ( p_entity_code             => 'HEADER'
                    ,p_entity_id               => l_header_rec.header_id
                    ,p_header_id               => l_header_rec.header_id
                    ,p_line_id                 => null
                    ,p_order_source_id         => l_header_rec.order_source_id
                    ,p_orig_sys_document_ref   => l_header_rec.orig_sys_document_ref
                    ,p_orig_sys_document_line_ref  => null
                    ,p_change_sequence         => l_header_rec.change_sequence
                    ,p_source_document_type_id     => l_header_rec.source_document_type_id
                    ,p_source_document_id      => l_header_rec.source_document_id
                    ,p_source_document_line_id => null );

        l_old_header_rec := l_header_rec;

      IF p_flow_status_code is not null THEN
        UPDATE OE_ORDER_HEADERS_ALL
        SET FLOW_STATUS_CODE = p_flow_status_code
            --Bug 8435596
            , last_update_date  = SYSDATE
            , last_updated_by   = FND_GLOBAL.USER_ID
            , last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE HEADER_ID = l_header_id;

                       -- Also update all lines to have the same flow_status_code
        Open Lines;
        Loop
          FETCH lines into l_line_id, l_lock_control;
          EXIT WHEN Lines%NOTFOUND;
        End Loop;
        Close Lines;

        UPDATE OE_ORDER_LINES_ALL
        SET FLOW_STATUS_CODE = p_flow_status_code
            --Bug 8435596
            , last_update_date  = SYSDATE
            , last_updated_by   = FND_GLOBAL.USER_ID
            , last_update_login = FND_GLOBAL.LOGIN_ID
            , LOCK_CONTROL = LOCk_CONTROL + 1
        WHERE HEADER_ID = l_header_id;

        l_updated_flag := 'Y';
        l_header_rec.flow_status_code := p_flow_status_code;
      END IF;

      IF p_open_flag is not null THEN
        UPDATE OE_ORDER_HEADERS_ALL
        SET OPEN_FLAG = p_open_flag
        WHERE HEADER_ID = l_header_id;

        l_updated_flag := 'Y';
        l_header_rec.open_flag := p_open_flag;

	-- XDING bug FP5172433
        UPDATE OE_ORDER_LINES_ALL
        SET OPEN_FLAG = p_open_flag
        WHERE HEADER_ID = l_header_id;
	-- XDING bug FP5172433

      END IF;

      IF p_draft_submitted_flag is not null THEN
        UPDATE OE_ORDER_HEADERS_ALL
        SET DRAFT_SUBMITTED_FLAG = p_draft_submitted_flag
        WHERE HEADER_ID = l_header_id;

        l_updated_flag := 'Y';
        l_header_rec.draft_submitted_flag := p_draft_submitted_flag;
      END IF;

      IF l_updated_flag = 'Y' THEN
        UPDATE OE_ORDER_HEADERS_ALL
        SET LOCK_CONTROL = LOCK_CONTROL + 1
        WHERE HEADER_ID = l_header_id;

        l_header_rec.lock_control := l_header_rec.lock_control + 1;
      END IF;


                    -- aksingh performance
                    -- As the update is on headers table, it is time to update
                    -- cache also!
      OE_Order_Cache.Set_Order_Header(l_header_rec);

                    -- Bug 1755817: clear the cached constraint results for header entity
                    -- when order header is updated.
      OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
                          (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

                    -- added for notification framework
                    -- calling notification framework to get index position
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists =>False,
                       p_old_header_rec => l_old_header_rec,
                       p_Header_rec =>l_header_rec,
                       p_header_id => l_header_id,
                       x_index => l_index,
                       x_return_status => l_return_status);

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_WF_ORDER_UTIL.UPDATE HEADER FLOW STATUS CODE IS: ' || L_RETURN_STATUS ) ;
        oe_debug_pub.add(  'INDEX IS: ' || L_INDEX , 1 ) ;
        oe_debug_pub.add(  'HEADER FLOW STATUS IS: ' || P_FLOW_STATUS_CODE , 1 ) ;
      END IF;

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_index is not NULL THEN
        -- update global picture directly
        OE_ORDER_UTIL.g_header_rec := OE_ORDER_UTIL.g_old_header_rec;
        IF p_flow_status_code is not null THEN
          OE_ORDER_UTIL.g_header_rec.flow_status_code:=p_flow_status_code;
        END IF;
        IF p_open_flag is not null THEN
          OE_ORDER_UTIL.g_header_rec.open_flag:=p_open_flag;
        END IF;
        IF p_draft_submitted_flag is not null THEN
          OE_ORDER_UTIL.g_header_rec.draft_submitted_flag:=p_draft_submitted_flag;
        END IF;
        OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
        OE_ORDER_UTIL.g_header_rec.operation:=OE_GLOBALS.G_OPR_UPDATE;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'GLOBAL HEADER FLOW STATUS IS: ' || OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE , 1 );
          oe_debug_pub.add(  'GLOBAL HEADER OPEN_FLAG IS: ' || OE_ORDER_UTIL.G_HEADER_REC.OPEN_FLAG , 1 );
          oe_debug_pub.add(  'GLOBAL HEADER DRAFT_SUBMITTED_FLAG IS: ' || OE_ORDER_UTIL.G_HEADER_REC.DRAFT_SUBMITTED_FLAG , 1 );
          oe_debug_pub.add(  'GLOBAL HEADER OPERATION IS: ' || OE_ORDER_UTIL.G_HEADER_REC.OPERATION , 1 ) ;
        END IF;
      END IF;
      -- bug 4732614
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OEXUOWFB.pls: Calling Process_Requests_And_Notify......', 1);
      END IF;

      OE_Order_PVT.Process_Requests_And_Notify
      ( p_header_rec     => l_header_rec
       ,p_old_header_rec => l_old_header_rec
       ,x_return_status  => l_return_status);

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_ERROR exception',2);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
          Oe_Debug_pub.Add('Process_Requests_And_Notify,return_status='||l_return_status||',Raising FND_API.G_EXC_UNEXPECTED_ERROR exception',2);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; -- bug 4732614 ends
    ELSIF l_sales_document_type_code = 'B' THEN -- Blanket Negotitation/Fulfillment
      SELECT lock_control
      INTO l_blanket_lock_control
      FROM oe_blanket_headers_all
      WHERE header_id = l_header_id
      FOR UPDATE NOWAIT;

/* avoid dependency on blanket API
                   OE_Blanket_Util.Lock_Row(p_blanket_id=>l_header_id
                                         , p_blanket_line_id => null
                                         , p_x_lock_control=>l_blanket_lock_control
                                         , x_return_status => l_return_status
                                         , x_msg_count => l_msg_count
                                         , x_msg_data => l_msg_data);
                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                   OE_MSG_PUB.set_msg_context
                   ( p_entity_code             => 'BLANKET'
                    ,p_entity_id               => p_header_id
                    ,p_header_id               => p_header_id);


*/

      IF p_flow_status_code is not null THEN
        UPDATE OE_BLANKET_HEADERS_ALL
        SET FLOW_STATUS_CODE = p_flow_status_code
            --Bug 8435596
            , last_update_date  = SYSDATE
            , last_updated_by   = FND_GLOBAL.USER_ID
            , last_update_login = FND_GLOBAL.LOGIN_ID
        WHERE HEADER_ID = l_header_id;

        l_updated_flag := 'Y';
      END IF;

      IF p_open_flag is not null THEN
        UPDATE OE_BLANKET_HEADERS_ALL
        SET OPEN_FLAG = p_open_flag
        WHERE HEADER_ID = l_header_id;

                       -- ZB put the code here
        oe_debug_pub.add('Acquiring locks on blanket lines');
        open blanket_lines;
        loop
          fetch blanket_lines into l_line_id, l_lock_control;
          EXIT WHEN blanket_lines%NOTFOUND;
        end loop;
        close blanket_lines;

        oe_debug_pub.add('Updating blanket lines 4 open flag');
        update OE_BLANKET_LINES_ALL
        SET OPEN_FLAG = p_open_flag
        WHERE HEADER_ID = l_header_id;
        -- End code

        l_updated_flag := 'Y';
      END IF;

      IF p_draft_submitted_flag is not null THEN
        UPDATE OE_BLANKET_HEADERS_ALL
        SET DRAFT_SUBMITTED_FLAG = p_draft_submitted_flag
        WHERE HEADER_ID = l_header_id;

        l_updated_flag := 'Y';
      END IF;

      IF l_updated_flag = 'Y' THEN
        UPDATE OE_BLANKET_HEADERS_ALL
        SET LOCK_CONTROL = LOCK_CONTROL + 1
        WHERE HEADER_ID = l_header_id;
      END IF;
    END IF; --check sales_document_type_code
   -- Bug 3356542
    OE_PC_Constraints_Admin_PVT.Clear_Cached_Results;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING UPDATE_QUOTE_BLANKET' , 5 ) ;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UPDATE_QUOTE_BLANKET;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_QUOTE_BLANKET: NO_DATA_FOUND' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_QUOTE_BLANKET;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_QUOTE_BLANKET: ERROR' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
        ROLLBACK TO UPDATE_QUOTE_BLANKET;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_QUOTE_BLANKET: LOCK EXC' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          fnd_message.set_name('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
          OE_MSG_PUB.Add;
        END IF;
        IF l_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_QUOTE_BLANKET;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_QUOTE_BLANKET: UNEXP ERROR' , 5 ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Quote_Blanket'
                        );
        END IF;
        IF l_header_id IS NOT NULL THEN
           OE_MSG_PUB.Reset_Msg_Context('HEADER');
        END IF;

END Update_Quote_Blanket;


/* -------------------------------------------------
   PROCEDURE: Create_WorkItem_Upgrade
   USAGE: This is used for blanket upgrade only
          at this time. It will create the WF process,
          but will not start the flow. Caller can use
          handleerror API call to jump to the right
          activity
----------------------------------------------------- */
PROCEDURE Create_WorkItem_Upgrade
(p_item_type      IN VARCHAR2,
 p_item_key       IN VARCHAR2,
 p_process_name   IN VARCHAR2,
 p_transaction_number       IN NUMBER,
 p_sales_document_type_code IN VARCHAR2,
 p_user_id       IN NUMBER,
 p_resp_id       IN NUMBER,
 p_appl_id       IN NUMBER,
 p_org_id        IN NUMBER
)
IS
  user_key_string VARCHAR2(240);
  l_valid_process VARCHAR2(30);
  l_aname  wf_engine.nametabtyp;
  l_aname2  wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;
  l_user_name VARCHAR2(100);
  l_validate_user NUMBER;
  l_owner_role VARCHAR2(100);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Entering Create_WorkItem_Upgrade.  item_type/item_key=' || p_item_type || '/' || p_item_key, 1) ;
  END IF;

  -- validate the p_process_name is ok
  select name
  into l_valid_process
  from wf_activities
  where item_type=p_item_type
  and name=p_process_name
  and runnable_flag = 'Y'
  and end_date is null;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'process_name: ' || l_valid_process, 4);
  END IF;

  IF p_sales_document_type_code = 'O' THEN
    fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
  ELSIF p_sales_document_type_code = 'B' THEN
    fnd_message.set_name('ONT', 'OE_NTF_BSA');
  END IF;

  user_key_string := substrb(fnd_message.get, 1, 240) || ' ' || to_char(p_transaction_number);

  SELECT user_name
  INTO l_owner_role
  FROM FND_USER
  WHERE USER_ID = p_user_id;

  -- Create process
  WF_ENGINE.CreateProcess(p_item_type,
                          p_item_key,
                          p_process_name,
                          user_key_string,
                          l_owner_role);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'After WF_ENGINE.CreateProcess', 4 ) ;
  END IF;

  -- Set various Header Attributes
  l_aname(1) := 'USER_ID';
  l_avalue(1) := p_user_id;
  l_aname(2) := 'APPLICATION_ID';
  l_avalue(2) := p_appl_id;
  l_aname(3) := 'RESPONSIBILITY_ID';
  l_avalue(3) := p_resp_id;
  l_aname(4) := 'ORG_ID';
  l_avalue(4) := p_org_id;
  l_aname(5) := 'TRANSACTION_NUMBER';
  l_avalue(5) := p_transaction_number;

  wf_engine.SetItemAttrNumberArray(p_item_type
                              , p_item_key
                              , l_aname
                              , l_avalue
                              );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATE_WORKITEM_UPGRADE' , 4) ;
  END IF;

EXCEPTION
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_WorkItem_Upgrade'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Create_WorkItem_Upgrade;

PROCEDURE CreateStart_HdrInternal
( p_item_type IN VARCHAR2,
  p_header_id IN NUMBER,
  p_transaction_number IN NUMBER,
  p_sales_document_type_code IN VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_count NUMBER;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATESTART_HDRINTERNAL' ) ;
  END IF;

  Create_HdrWorkItemInternal(p_item_type, p_header_id, p_transaction_number, p_sales_document_type_code);

  IF p_item_type = OE_GLOBALS.G_WFI_NGO THEN
        OE_GLOBALS.G_START_NEGOTIATE_HEADER_FLOW := p_header_id;
  ELSIF p_item_type = OE_GLOBALS.G_WFI_BKT THEN
        OE_GLOBALS.G_START_BLANKET_HEADER_FLOW := p_header_id;
        -- For OEBH
        -- Check if a OENH flow exists, if so set the parent
        SELECT count(1)
        INTO l_count
        FROM wf_items
        WHERE item_type=OE_GLOBALS.G_WFI_NGO
        AND   item_key =to_char(p_header_id);

        IF l_count > 0 THEN
             WF_ITEM.Set_Item_Parent(OE_GLOBALS.G_WFI_BKT,
                             to_char(p_header_id),
                             OE_GLOBALS.G_WFI_NGO,
                             to_char(p_header_id), '');
        END IF;

  END IF;

  OE_GLOBALS.G_SALES_DOCUMENT_TYPE_CODE := p_sales_document_type_code;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATESTART_HDRPROCESSINTERNAL' ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CreateStart_HdrInternal'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END CreateStart_HdrInternal;




/* ----------------------------------------------------------
   PROCEDURE: Create_HdrWorkItemInternal
   USAGE: The main create WF work item routine for item type
          OENH and OEBH
------------------------------------------------------------- */

PROCEDURE Create_HdrWorkItemInternal
(p_item_type IN VARCHAR2,
 p_header_id IN NUMBER,
 p_transaction_number IN NUMBER,
 p_sales_document_type_code IN VARCHAR2
)
IS
  l_hdr_process_name VARCHAR2(30);
  l_aname  wf_engine.nametabtyp;
  l_aname2  wf_engine.nametabtyp;
  l_avalue wf_engine.numtabtyp;
  l_avaluetext wf_engine.texttabtyp;

  user_key_string VARCHAR2(240);
  l_user_name VARCHAR2(100);
  l_validate_user NUMBER;
  l_sales_document_type VARCHAR2(240);
  l_owner_role VARCHAR2(100);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN CREATE_HDRWORKITEMINTERNAL, ITEM_TYPE/ITEM_KEY=' || p_item_type || '/' || to_char(p_header_id)) ;
  END IF;

  l_hdr_process_name := Get_ProcessName(p_itemtype=> p_item_type, p_itemkey=>p_header_id, p_SalesDocumentTypeCode=> p_sales_document_type_code);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Get ProcessName: ' || l_hdr_process_name);
  END IF;

  -- set user key
  IF p_sales_document_type_code = 'O' THEN
    fnd_message.set_name('ONT', 'OE_NTF_QUOTE');
  ELSIF p_sales_document_type_code = 'B' THEN
    fnd_message.set_name('ONT', 'OE_NTF_BSA');
  END IF;

  l_sales_document_type := substrb(fnd_message.get, 1, 240);
  user_key_string := l_sales_document_type || ' ' ||  to_char(p_transaction_number);

  SELECT user_name
  INTO l_owner_role
  FROM FND_USER
  WHERE USER_ID = FND_GLOBAL.USER_ID;

  -- Create Header Work item
  WF_ENGINE.CreateProcess(p_item_type,
                          to_char(p_header_id),
                          l_hdr_process_name,
                          user_key_string,
                          l_owner_role);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER WF_ENGINE.CREATEPROCESS' ) ;
  END IF;

  -- Set various Header Attributes
  l_aname(1) := 'USER_ID';
  l_avalue(1) := FND_GLOBAL.USER_ID;
  l_aname(2) := 'APPLICATION_ID';
  l_avalue(2) := FND_GLOBAL.RESP_APPL_ID;
  l_aname(3) := 'RESPONSIBILITY_ID';
  l_avalue(3) := FND_GLOBAL.RESP_ID;
  l_aname(4) := 'ORG_ID';
  l_avalue(4) := to_number(OE_GLOBALS.G_ORG_ID);
  l_aname(5) := 'TRANSACTION_NUMBER';
  l_avalue(5) := p_transaction_number;

  IF p_item_type = OE_GLOBALS.G_WFI_NGO THEN
    l_aname(6)  := 'HEADER_ID';
    l_avalue(6) := p_header_id;
  END IF;

  wf_engine.SetItemAttrNumberArray(p_item_type
                              , to_char(p_header_id)
                              , l_aname
                              , l_avalue
                              );

  /* get FROM_ROLE */
    BEGIN
      select user_name
      into l_user_name
      from fnd_user
      where user_id = FND_GLOBAL.USER_ID;

    EXCEPTION
      WHEN OTHERS THEN
        l_user_name := null; -- do not set FROM_ROLE then
    END;

  wf_engine.SetItemAttrText(p_item_type,
                            to_char(p_header_id),
                            'NOTIFICATION_FROM_ROLE',
                            l_user_name);

  IF p_item_type = OE_GLOBALS.G_WFI_NGO THEN
  -- if this is a negotiation flow, set some item attributes that
  -- only apply to negotiations

    l_aname2(1) := 'SALES_DOCUMENT_TYPE_CODE';
    l_avaluetext(1) := p_sales_document_type_code;
    l_aname2(2) := 'SALES_DOCUMENT_TYPE';
    l_avaluetext(2) := l_sales_document_type;

    -- CONTRACT_ATTACHMENT will not be set here, it may be too early, we need
    -- to call contract to determine the attachment, at a later time, it's done
    -- at Initiate_Approval

    wf_engine.SetItemAttrTextArray(p_item_type
                             , to_char(p_header_id)
                             , l_aname2
                             , l_avaluetext
                             );
  END IF; -- only need to set text item attr if it is OENH

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CREATE_HDRWORKITEMINTERNAL' ) ;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  RAISE;
WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_HdrWorkItemInternal'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

END Create_HdrWorkItemInternal;

PROCEDURE Set_Negotiate_Hdr_User_Key(p_header_id IN NUMBER,
                                     p_sales_document_type_code IN VARCHAR2,
                                     p_transaction_number IN NUMBER)
IS
l_user_key VARCHAR2(240);

BEGIN

   IF p_sales_document_type_code = 'O' THEN
       fnd_message.set_name('ONT', 'OE_WF_QUOTE_ORDER');
       fnd_message.set_token('QUOTE_NUMBER', to_char(p_transaction_number));
   ELSIF p_sales_document_type_code = 'B' THEN
       fnd_message.set_name('ONT', 'OE_WF_BLANKET_ORDER');
       fnd_message.set_token('BLANKET_NUMBER', to_char(p_transaction_number));
   END IF;

   l_user_key := substrb(fnd_message.get, 1, 240);
   wf_engine.SetItemUserKey( OE_GLOBALS.G_WFI_NGO
                                , p_header_id
                                , l_user_key);
EXCEPTION
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                OE_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME
              ,   'Set_Negotiate_Hdr_User_Key'
                );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
END Set_Negotiate_Hdr_User_Key;


PROCEDURE Set_Blanket_Hdr_User_Key(p_header_id IN NUMBER,
                                   p_transaction_number IN NUMBER)
IS
l_user_key VARCHAR2(240);

BEGIN

       fnd_message.set_name('ONT', 'OE_WF_BLANKET_ORDER');
       fnd_message.set_token('BLANKET_NUMBER', to_char(p_transaction_number));

   l_user_key := substrb(fnd_message.get, 1, 240);
   wf_engine.SetItemUserKey( OE_GLOBALS.G_WFI_BKT
                                , p_header_id
                                , l_user_key);
EXCEPTION
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                OE_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME
              ,   'Set_Blanket_Hdr_User_Key'
                );
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
END Set_Blanket_Hdr_User_Key;


/******************************
*** Set_transaction_Details  **
******************************/
/*
*/
Procedure Set_transaction_Details (document_id     in      varchar2,
                                   display_type   in      varchar2,
                                   document       in out  NOCOPY varchar2,
                                   document_type  in out  NOCOPY varchar2)
IS

   l_sales_document_type_code VARCHAR2(1);
   l_item_key                 VARCHAR2(240);
   l_item_type     VARCHAR2(8);
   l_blanket_flag             VARCHAR2(1);


   -- HTML variables
   l_document                 VARCHAR2(32000) := '';

BEGIN

--  select ITEM_KEY, ITEM_TYPE
--    into l_item_key, l_item_type
--    from wf_item_activity_statuses_v
--   where NOTIFICATION_ID = to_number(document_id);

  -- replaced with this. see bug#4930449
  begin
  select ITEM_KEY, ITEM_TYPE
    into l_item_key, l_item_type
    from WF_ITEM_ACTIVITY_STATUSES
   where NOTIFICATION_ID = to_number(document_id);
  exception
    when no_data_found then
      select ITEM_KEY, ITEM_TYPE
      into l_item_key, l_item_type
      from WF_ITEM_ACTIVITY_STATUSES_H
      where NOTIFICATION_ID = to_number(document_id);
  end;
  /* 9047023: End */

  -- Get the Sales Document Type
  if l_item_type = 'OEBH' THEN
    l_blanket_flag := 'Y';
  else
    l_sales_document_type_code := wf_engine.GetItemAttrText(
                                 OE_GLOBALS.G_WFI_NGO,
                                  l_item_key,
                                  'SALES_DOCUMENT_TYPE_CODE');
    if l_sales_document_type_code = 'B' then
     l_blanket_flag := 'Y';
    end if;

  end if;


  IF l_blanket_flag = 'Y' THEN

     OE_Order_WF_Util.build_blanket_doc (p_item_type                 => l_item_type,
                                         p_item_key                  => l_item_key,
                                         p_display_type              => display_type,
                                         p_x_document                => l_document);


  -----------------------------
  -- Sales Document is Quote --
  -----------------------------
  ELSE -- l_blanket_flag = 'N'

     OE_Order_WF_Util.build_quote_doc (p_item_type                 => l_item_type,
                                       p_item_key                  => l_item_key,
                                       p_display_type              => display_type,
                                       p_x_document                => l_document);


  END IF; -- l_sales_document_type_code = 'B'

 document := l_document;

END Set_transaction_Details;



/*************************
**  BUILD_BLANKET_DOC   **
*************************/
procedure build_blanket_doc (p_item_type      in varchar2,
                             p_item_key       in varchar2,
                             p_display_type   in varchar2,
                             p_x_document     in out  NOCOPY varchar2
                             )
IS
   l_wf_header_attr           VARCHAR2(30);
   l_salesrep       VARCHAR2(240);
   l_sold_to        VARCHAR2(240);
   l_expiration_date DATE;

   l_transaction_id           NUMBER;
   --l_header_id                NUMBER;
   l_blanket_flag             VARCHAR2(1);

   l_item_type     VARCHAR2(8);
   l_aname         wf_engine.nametabtyp;
   l_avaluetext    wf_engine.texttabtyp;


   l_transaction_number       NUMBER;


   -- Blanket Header Attributes
   l_order_number             NUMBER;
   l_blanket_min_amount       NUMBER;
   l_blanket_max_amount       NUMBER;
   l_start_date_active        DATE;
   l_end_date_active          DATE;
   l_credit_hold              VARCHAR2(3);
   l_creation_date            DATE;
   l_ship_to_address          VARCHAR2(40);
   l_invoice_to_address       VARCHAR2(40);
   l_payment_term             VARCHAR2(15);


   -- HTML variables
   l_document                 VARCHAR2(32000) := '';
   l_line_msg                 VARCHAR2(1000);
   NL                         VARCHAR2(1) := '';
   i                          number := 0;

   -- New Line char.
   NLCHAR                     VARCHAR2(2) := FND_GLOBAL.Newline;

   -- fnd messages
   l_msg_BSA                  VARCHAR2(240);
   l_msg_creation_date        VARCHAR2(240);
   l_msg_activation_date      VARCHAR2(240);
   l_msg_expiration_date      VARCHAR2(240);
   l_msg_ship_to              VARCHAR2(240);
   l_msg_invoice_to           VARCHAR2(240);
   l_msg_credit_holds         VARCHAR2(240);
   l_msg_payment_term         VARCHAR2(240);
   l_msg_min_amt_agreed       VARCHAR2(240);
   l_msg_max_amt_agreed       VARCHAR2(240);
   l_msg_salesperson          VARCHAR2(240);
   l_msg_customer             VARCHAR2(240);
   l_msg_blanket_number       VARCHAR2(240);

BEGIN

     l_transaction_id := to_number(p_item_key);

     -- set fnd message titles for tables
     l_msg_BSA := FND_MESSAGE.Get_String('ONT', 'OE_NTF_BSA');
     l_msg_creation_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CREATION_DATE');
     l_msg_activation_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_ACTIVATION_DATE');
     l_msg_expiration_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_EXPIRATION_DATE');
     l_msg_ship_to := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SHIP_TO');
     l_msg_invoice_to := FND_MESSAGE.Get_String('ONT', 'OE_NTF_INVOICE_TO');
     l_msg_credit_holds := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CREDIT_HOLDS');
     l_msg_payment_term := FND_MESSAGE.Get_String('ONT', 'OE_NTF_PAYMENT_TERM');
     l_msg_min_amt_agreed := FND_MESSAGE.Get_String('ONT', 'OE_NTF_MIN_AMT_AGREED');
     l_msg_max_amt_agreed := FND_MESSAGE.Get_String('ONT', 'OE_NTF_MAX_AMT_AGREED');


     -- set values
       select /* MOAC_SQL_CHANGE */ headers.order_number, headers.CREATION_DATE,
              shipto.location name,
              invoiceto.LOCATION name,
              terms.NAME,
              blnk_ext.BLANKET_MIN_AMOUNT, blnk_ext.BLANKET_MAX_AMOUNT,
              blnk_ext.START_DATE_ACTIVE, blnk_ext.END_DATE_ACTIVE
         INTO l_order_number, l_creation_date, l_ship_to_address, l_invoice_to_address,
              l_payment_term,
              l_blanket_min_amount, l_blanket_max_amount,
              l_start_date_active, l_end_date_active
         FROM oe_blanket_headers_all headers,
              oe_blanket_headers_ext blnk_ext,
               hz_cust_site_uses_all  shipto,
              hz_cust_site_uses_all  invoiceto,
              ra_terms_tl               terms
        where headers.header_id = l_transaction_id
          and headers.order_number = blnk_ext.order_number(+)
          and headers.ship_to_org_id = shipto.site_use_id(+)
          and shipto.site_use_code(+) = 'SHIP_TO'
          and shipto.org_id(+) = headers.org_id
          and headers.invoice_to_org_id = invoiceto.site_use_id(+)
          and invoiceto.site_use_code(+) = 'BILL_TO'
          and invoiceto.org_id(+) = headers.org_id
          and headers.payment_term_id = terms.term_id(+)
	  and terms.language(+) = userenv('LANG');


       --- ??? Check with the PM
       l_credit_hold := OE_Order_Wf_Util.check_credit_hold (p_hold_entity_code => 'O',
                                           p_hold_entity_id   => l_transaction_id);




     --------------
     --   HTML   --
     If p_display_type IS NULL OR p_display_type='text/html' Then


       --------------------------------------
       -- **HEADINGS FOR THE HEADER TABLE**--
       --------------------------------------
       l_document := l_document || NL || NL || '<!-- OE_BLANKET_HEADERS -->'|| NL || NL || '<P>';
       l_document := l_document || '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
       l_document := l_document || '<table width=100% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
       l_document := l_document || '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';


       --------------------------------------------------
       -- IF the WF Header Attributes are not enables ---
       --------------------------------------------------
       l_wf_header_attr := wf_core.translate('WF_HEADER_ATTR');

       IF l_wf_header_attr <> 'Y' THEN

         -- set fnd msg title
         l_msg_blanket_number := FND_MESSAGE.Get_String('ONT', 'OE_NTF_BLANKET_NUMBER');
         l_msg_salesperson := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SALESPERSON');
         l_msg_customer := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CUSTOMER');

         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_blanket_number  || '</font></th>';
         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_customer  || '</font></th>';
         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_salesperson || '</font></th>';

       END IF;
       -- WF Header Attributes   ---

       -----------------------------

       -- **HEADINGS FOR THE BLNAKET HEADER TABLE**--

       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_creation_date || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_activation_date || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_expiration_date || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_ship_to || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_invoice_to || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_credit_holds || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_payment_term || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_min_amt_agreed || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_max_amt_agreed || '</font></th></tr>';






       --------------------------------------------------
       -- IF the WF Header Attributes are not enables ---
       --------------------------------------------------
       IF l_wf_header_attr <> 'Y' THEN
           l_transaction_number := wf_engine.GetItemAttrNumber(
                                 p_item_type,
                                 p_item_key,
                                 'TRANSACTION_NUMBER');

           l_salesrep := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SALESPERSON');
           l_sold_to  := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SOLD_TO');



           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_transaction_number) || '</font></td>';
           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_sold_to || '</font></td>';
           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_salesrep || '</font></td>';

       END IF;  --- l_wf_header_attr <> 'Y' ---



       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_creation_date, 'DD-MON-YYYY') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_start_date_active, 'DD-MON-YYYY') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_end_date_active, 'DD-MON-YYYY') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_ship_to_address || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_invoice_to_address || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_credit_hold || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_payment_term || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(l_blanket_min_amount) || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(l_blanket_max_amount) || '</font></td></tr>';

       l_document := l_document || '</TABLE></TD></TR></TABLE></P>' || NL;


     ----------------
     ---  TEXT    ---
     elsif p_display_type = 'text/plain' then

           l_transaction_number := wf_engine.GetItemAttrNumber(
                                 p_item_type,
                                 p_item_key,
                                 'TRANSACTION_NUMBER');

           l_salesrep := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SALESPERSON');
           l_sold_to  := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SOLD_TO');

           -- set fnd msg title
           l_msg_blanket_number := FND_MESSAGE.Get_String('ONT', 'OE_NTF_BLANKET_NUMBER');
           l_msg_salesperson := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SALESPERSON');
           l_msg_customer := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CUSTOMER');


        l_document := l_document || l_msg_blanket_number || ': ' || TO_CHAR(l_transaction_number) || NLCHAR;
        l_document := l_document || l_msg_salesperson || ': ' || l_salesrep || NLCHAR;
        l_document := l_document || l_msg_customer || ': ' || l_sold_to || NLCHAR;
        l_document := l_document || l_msg_creation_date || ': ' || TO_CHAR(l_creation_date, 'DD-MON-YYYY') || NLCHAR;
        l_document := l_document || l_msg_activation_date || ': ' || TO_CHAR(l_start_date_active, 'DD-MON-YYYY') || NLCHAR;
        l_document := l_document || l_msg_expiration_date || ': ' || TO_CHAR(l_end_date_active, 'DD-MON-YYYY') || NLCHAR;
        l_document := l_document || l_msg_ship_to  || ': ' || l_ship_to_address || NLCHAR;
        l_document := l_document || l_msg_invoice_to  || ': ' || l_invoice_to_address || NLCHAR;
        l_document := l_document || l_msg_credit_holds  || ': ' || l_credit_hold || NLCHAR;
        l_document := l_document || l_msg_payment_term || ': ' || l_payment_term || NLCHAR;
        l_document := l_document || l_msg_min_amt_agreed || ': ' || TO_CHAR(l_blanket_min_amount) || NLCHAR;
        l_document := l_document || l_msg_max_amt_agreed || ': ' || TO_CHAR(l_blanket_max_amount) || NLCHAR;

     end if;

     p_x_document := l_document;
END build_blanket_doc;



/************************
**  BUILD_QUOTE_DOC     *
************************/
/*
*/
procedure build_quote_doc ( p_item_type      in varchar2,
                            p_item_key       in varchar2,
                            p_display_type   in varchar2,
                            p_x_document     in out  NOCOPY varchar2
                             )
IS
   l_wf_header_attr           VARCHAR2(30);
   l_salesrep       VARCHAR2(240);
   l_sold_to        VARCHAR2(240);
   l_expiration_date DATE;

   l_transaction_id           NUMBER;
   l_blanket_flag             VARCHAR2(1);

   l_item_type     VARCHAR2(8);
   l_aname         wf_engine.nametabtyp;
   l_avaluetext    wf_engine.texttabtyp;


   l_transaction_number       NUMBER;

   -- Quote Header table attributes
   l_creation_date            DATE;
   l_ship_to_address          VARCHAR2(40);
   l_invoice_to_address       VARCHAR2(40);
   l_transactional_curr_code  VARCHAR2(3);
   l_payment_term             VARCHAR2(15);
   l_order_total              NUMBER;
   l_credit_hold              VARCHAR2(3);
   l_order_margin_percent     NUMBER;
   l_order_margin_amount      NUMBER;


   -- Quote Line Attributes
   l_line_margin_percent      NUMBER;
   l_line_rec                 OE_ORDER_PUB.LINE_REC_TYPE;
   l_unit_cost                NUMBER;
   l_unit_margin_amount       NUMBER;
   l_margin_percent           NUMBER;
   l_line                     line_record; -- ?? Is it still being used somewhere


   -- HTML variables
   l_document                 VARCHAR2(32000) := '';
   l_line_msg                 VARCHAR2(1000);
   NL                         VARCHAR2(1) := '';
   i                          number := 0;
   l_url                      VARCHAR2(1000);

   -- New Line char.
   NLCHAR                     VARCHAR2(2) := FND_GLOBAL.Newline;

   -- FND msg titles
   l_msg_creation_date        VARCHAR2(240);
   l_msg_salesperson          VARCHAR2(240);
   l_msg_customer             VARCHAR2(240);
   l_msg_quote                VARCHAR2(240);
   l_msg_total                VARCHAR2(240);
   l_msg_UOM                  VARCHAR2(240);
   l_msg_item                 VARCHAR2(240);
   l_msg_quantity             VARCHAR2(240);
   l_msg_currency             VARCHAR2(240);
   l_msg_unit_selling_price   VARCHAR2(240);
   l_msg_margin_percent       VARCHAR2(240);
   l_msg_line_details         VARCHAR2(240);
   l_msg_expiration_date      VARCHAR2(240);
   l_msg_ship_to              VARCHAR2(240);
   l_msg_invoice_to           VARCHAR2(240);
   l_msg_credit_holds         VARCHAR2(240);
   l_msg_payment_term         VARCHAR2(240);
   l_msg_quote_number         VARCHAR2(240);
   l_msg_line_number          VARCHAR2(240);
   l_msg_quote_details        VARCHAR2(240);
   l_msg_first_five_lines     VARCHAR2(240);

  -- Cursor to build line table
  CURSOR line_cursor(v_header_id NUMBER) IS
  SELECT ol.line_number || '.' ||ol.shipment_number ||'.' ||
         ol.option_number ||'.'|| ol.component_number,
         msi.concatenated_segments,
         ol.order_quantity_uom,
         ol.ordered_quantity,
         ol.unit_selling_price,
         ol.ordered_quantity * ol.unit_selling_price,
         ol.line_id,              --- the following column needed for line_margin API
         ol.inventory_item_id,
         ol.item_type_code,
         ol.open_flag,
         ol.SHIPPED_QUANTITY,
         ol.ORDERED_QUANTITY,
         ol.SOURCE_TYPE_CODE,
         ol.SHIP_FROM_ORG_ID,
         ol.PROJECT_ID,
         ol.ACTUAL_SHIPMENT_DATE,
         ol.FULFILLMENT_DATE
    FROM oe_order_lines_all ol,
         mtl_system_items_kfv   msi
   WHERE ol.header_id = v_header_id
     AND ol.inventory_item_id = msi.inventory_item_id
     AND msi.organization_id = nvl(ol.ship_from_org_id,
		oe_sys_parameters.Value('MASTER_ORGANIZATION_ID'))  -- Bug 6215694
   ORDER BY line_number, shipment_number, option_number, component_number;

   l_prec_inited BOOLEAN := FALSE;	-- Bug 6275663
   l_org_id NUMBER;

BEGIN

     l_transaction_id := to_number(p_item_key);
     select org_id into l_org_id from oe_order_headers_all where header_id = l_transaction_id;
     MO_GLOBAL.set_policy_context('S', l_org_id);

  -- Bug 6275663
     IF ( nvl(Oe_Order_Util.G_Precision,0) = 0 ) THEN
       l_prec_inited := Oe_Order_Util.Get_Precision (p_header_id => l_transaction_id);
     END IF;

     -- set fnd message titles for tables
     l_msg_quote := FND_MESSAGE.Get_String('ONT', 'OE_NTF_QUOTE');
     l_msg_creation_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CREATION_DATE');
     l_msg_margin_percent := FND_MESSAGE.Get_String('ONT', 'OE_NTF_MARGIN_PERCENT');
     l_msg_ship_to := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SHIP_TO');
     l_msg_invoice_to := FND_MESSAGE.Get_String('ONT', 'OE_NTF_INVOICE_TO');
     l_msg_credit_holds := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CREDIT_HOLDS');
     l_msg_payment_term := FND_MESSAGE.Get_String('ONT', 'OE_NTF_PAYMENT_TERM');
     l_msg_total := FND_MESSAGE.Get_String('ONT', 'OE_NTF_TOTAL');
     l_msg_line_details := FND_MESSAGE.Get_String('ONT', 'OE_NTF_LINE_DETAILS');
     l_msg_item := FND_MESSAGE.Get_String('ONT', 'OE_NTF_ITEM');
     l_msg_uom := FND_MESSAGE.Get_String('ONT', 'OE_NTF_UOM');
     l_msg_quantity := FND_MESSAGE.Get_String('ONT', 'OE_NTF_QUANTITY');
     l_msg_currency := FND_MESSAGE.Get_STring('ONT', 'OE_NTF_CURRENCY');
     l_msg_unit_selling_price := FND_MESSAGE.Get_String('ONT', 'OE_NTF_UNIT_SELLING_PRICE');
     l_msg_line_number := FND_MESSAGE.Get_String('ONT', 'OE_NTF_LINE_NUMBER');
     l_msg_quote_details := FND_MESSAGE.Get_String('ONT', 'OE_NTF_ADL_QUOTE_DETAILS');
     l_msg_first_five_lines := FND_MESSAGE.Get_String('ONT', 'OE_NTF_FIRST_FIVE_LINES');
     -------------------------

     -- set value
     -- Build the header attribute values
       l_order_total := OE_OE_TOTALS_SUMMARY.PRT_ORDER_TOTAL(l_transaction_id);

       --- ???? Check with PM
       l_credit_hold := OE_Order_Wf_Util.check_credit_hold (p_hold_entity_code => 'O',
                                           p_hold_entity_id   => l_transaction_id);
       OE_MARGIN_PVT.Get_Order_Margin ( p_header_id            => l_transaction_id,
                                        x_order_margin_percent => l_order_margin_percent,
                                        x_order_margin_amount  => l_order_margin_amount);

       l_order_margin_percent  :=  Round(l_order_margin_percent, Oe_Order_Util.G_Precision); -- Bug 6275663



       select /* MOAC_SQL_CHANGE */ headers.CREATION_DATE,shipto.name,
              invoiceto.LOCATION name,
              headers.TRANSACTIONAL_CURR_CODE, terms.NAME
         INTO l_creation_date, l_ship_to_address, l_invoice_to_address,
              l_transactional_curr_code, l_payment_term
         FROM oe_order_headers_all headers,
              oe_ship_to_orgs_v    shipto,
              HZ_CUST_SITE_USES_ALL invoiceto,
              ra_terms             terms
        where headers.header_id = l_transaction_id
          and headers.SHIP_TO_ORG_ID = shipto.organization_id(+)
          and headers.INVOICE_TO_ORG_ID = invoiceto.SITE_USE_ID(+)
          and invoiceto.SITE_USE_CODE(+) = 'BILL_TO'
          and invoiceto.ORG_ID(+) = headers.org_id
          and headers.payment_term_id = terms.term_id(+);



     -- DISPLAY_TYPE = HTML --
     IF p_display_type IS NULL OR p_display_type='text/html' THEN

       --------------------------------------
       -- **HEADINGS FOR THE HEADER TABLE**--
       --------------------------------------
       l_document := l_document || NL || NL || '<!-- OE_HEADERS_DETAILS -->'|| NL || NL || '<P>';
       l_document := l_document || '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' ||  l_msg_quote || '</font><br>';
       l_document := l_document || '<table width=100% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
       l_document := l_document || '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';


       --------------------------------------------------
       -- IF the WF Header Attributes are not enables ---
       --------------------------------------------------
       l_wf_header_attr := wf_core.translate('WF_HEADER_ATTR');

       IF l_wf_header_attr <> 'Y' THEN

         -- set FND msg title
         l_msg_quote_number := FND_MESSAGE.Get_String('ONT', 'OE_NTF_QUOTE_NUMBER');
         l_msg_salesperson := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SALESPERSON');
         l_msg_customer := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CUSTOMER');
         l_msg_expiration_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_EXPIRATION_DATE');

         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_quote_number || '</font></th>';
         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_customer || '</font></th>';
         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_expiration_date || '</font></th>';
         l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_salesperson || '</font></th>';

       END IF;
       -- WF Header Attributes   ---
       -----------------------------



       -- **HEADINGS FOR THE HEADER TABLE**--

       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_creation_date || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_ship_to || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_invoice_to || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_credit_holds || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_currency || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_total || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_margin_percent || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_payment_term || '</font></th></tr>';


       --------------------------------------------------
       -- IF the WF Header Attributes are not enables ---
       --------------------------------------------------
       IF l_wf_header_attr <> 'Y' THEN
           l_transaction_number := wf_engine.GetItemAttrNumber(
                                 p_item_type,
                                 p_item_key,
                                 'TRANSACTION_NUMBER');
           l_salesrep := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SALESPERSON');
           l_sold_to  := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SOLD_TO');
           l_expiration_date := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'EXPIRATION_DATE');

           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_transaction_number) || '</font></td>';
           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_sold_to || '</font></td>';
           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_expiration_date, 'DD-MON-YYYY') || '</font></td>';
           l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_salesrep || '</font></td>';



       END IF; -- l_wf_header_attr <> 'Y' --


       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_creation_date, 'DD-MON-YYYY') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_ship_to_address || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_invoice_to_address || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_credit_hold || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_transactional_curr_code || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_order_total || '</font></td>';

       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(l_order_margin_percent) || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_payment_term || '</font></td></tr>';


       l_document := l_document || '</TABLE></TD></TR></TABLE></P>' || NL;


       -----------------------------------
       -- Build the Lines Detail Table  --
       -----------------------------------
       l_document := l_document || NL || NL || '<!-- OE_LINE_DETAILS -->'|| NL || NL || '<P>';
       l_document := l_document || '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' ||  l_msg_line_details ||'</font><br>';

       l_document := l_document || l_msg_first_five_lines;
       l_document := l_document || '<br><table width=100% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
       l_document := l_document || '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';

       -- **HEADINGS FOR THE LINE TABLE**--
       l_document := l_document || '<th scope=col width=10% align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_line_number || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_item || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_uom || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_quantity || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_unit_selling_price || '</font></th>';
       l_document := l_document || '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_msg_margin_percent || '</font></th></tr>';

       --** BUILD THE LINE TABLE** --
       -- Line detail columns -> Items, UOM, Selling Price



    OPEN line_cursor(l_transaction_id);
    LOOP
       FETCH line_cursor into l_line;
       EXIT WHEN line_cursor%NOTFOUND;
       i := i + 1;
       l_line_rec.header_id            := l_transaction_id; --bug 5210735
       l_line_rec.line_id              := l_line.line_id;
       l_line_rec.inventory_item_id    := l_line.inventory_item_id;
       l_line_rec.item_type_code       := l_line.item_type_code;
       l_line_rec.open_flag            := l_line.open_flag;
       l_line_rec.SHIPPED_QUANTITY     := l_line.SHIPPED_QUANTITY;
       l_line_rec.ORDERED_QUANTITY     := l_line.ORDERED_QUANTITY;
       l_line_rec.SOURCE_TYPE_CODE     := l_line.SOURCE_TYPE_CODE;
       l_line_rec.SOURCE_TYPE_CODE     := l_line.SOURCE_TYPE_CODE;
       l_line_rec.SHIP_FROM_ORG_ID     := l_line.SHIP_FROM_ORG_ID;
       l_line_rec.PROJECT_ID           := l_line.PROJECT_ID;
       l_line_rec.ACTUAL_SHIPMENT_DATE := l_line.ACTUAL_SHIPMENT_DATE;
       l_line_rec.FULFILLMENT_DATE     := l_line.FULFILLMENT_DATE;
       l_line_rec.unit_selling_price   := l_line.unit_selling_price; --bug 5155086

       OE_MARGIN_PVT.Get_Line_Margin ( p_line_rec            => l_line_rec,
                                       x_unit_cost           => l_unit_cost,
                                       x_unit_margin_amount  => l_unit_margin_amount,
                                       x_margin_percent      => l_line_margin_percent);

      l_line_margin_percent  :=  Round(l_line_margin_percent, Oe_Order_Util.G_Precision); -- Bug 6275663


       l_document := l_document || '<tr><td align=CENTER valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || nvl(l_line.line_num, '&' || 'nbsp') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || nvl(l_line.item, '&' || 'nbsp') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || nvl(l_line.uom, '&'||'nbsp') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || nvl(to_char(l_line.quantity), '&' ||'nbsp') || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_line.unit_selling_price) || '</font></td>';
       l_document := l_document || '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || TO_CHAR(l_line_margin_percent) || '</font></td>';

      exit when i = 5;
    end loop;

    close line_cursor;

    l_document := l_document || '</TABLE></TD></TR></TABLE></P>' || NL;

    -- show the URL link to OIP
    l_url := rtrim(fnd_profile.Value('APPS_FRAMEWORK_AGENT'), '/')||'/OA_HTML/OA.jsp?akRegionCode=ORDER_DETAILS_PAGE' || '&' || 'akRegionApplicationId=660' || '&' || 'HeaderId=' || p_item_key;

    l_document := l_document ||'<TABLE width="100%" SUMMARY=""><TR> <TD align=right><A HREF="' ||
                  l_url || '" TARGET="_top">' || l_msg_quote_details || '</A></TD></TR></TABLE>'
                  || NL;

     -------------------------
     -- DISPLAY_TYPE = TEXT --
     ELSIF p_display_type = 'text/plain' THEN

         -- set FND msg title
         l_msg_quote_number := FND_MESSAGE.Get_String('ONT', 'OE_NTF_QUOTE_NUMBER');
         l_msg_salesperson := FND_MESSAGE.Get_String('ONT', 'OE_NTF_SALESPERSON');
         l_msg_customer := FND_MESSAGE.Get_String('ONT', 'OE_NTF_CUSTOMER');
         l_msg_expiration_date := FND_MESSAGE.Get_String('ONT', 'OE_NTF_EXPIRATION_DATE');

           l_transaction_number := wf_engine.GetItemAttrNumber(
                                 p_item_type,
                                 p_item_key,
                                 'TRANSACTION_NUMBER');

           l_salesrep := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SALESPERSON');
           l_sold_to  := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'SOLD_TO');
           l_expiration_date := wf_engine.GetItemAttrText(
                                 p_item_type,
                                 p_item_key,
                                 'EXPIRATION_DATE');


        l_document := l_document || l_msg_quote_number || l_transaction_number || NLCHAR;
        l_document := l_document || l_msg_customer || l_sold_to || NLCHAR;
        l_document := l_document || l_msg_expiration_date|| TO_CHAR(l_expiration_date, 'DD-MON-YYYY') || NLCHAR;
        l_document := l_document || l_msg_salesperson || l_salesrep || NLCHAR;
        l_document := l_document || l_msg_creation_date || TO_CHAR(l_creation_date, 'DD-MON-YYYY') || NLCHAR;
        l_document := l_document || l_msg_ship_to || l_ship_to_address || NLCHAR;
        l_document := l_document || l_msg_invoice_to || l_invoice_to_address || NLCHAR;
        l_document := l_document || l_msg_credit_holds || l_credit_hold || NLCHAR;
        l_document := l_document || l_msg_currency || l_transactional_curr_code || NLCHAR;
        l_document := l_document || l_msg_total || l_order_total || NLCHAR;
        l_document := l_document || l_msg_total || to_char(l_order_margin_percent) || NLCHAR;
        l_document := l_document || l_msg_payment_term || l_payment_term || NLCHAR;

-- ?? fix the nbsp
/*
        l_document := l_document || NLCHAR || NLCHAR || '<!-- OE_LINES_DETAILS -->' || NLCHAR || NLCHAR;
        l_document := l_document || 'Line Number:' || nvl(l_line.line_num, '&' || 'nbsp') || NLCHAR;
        l_document := l_document || 'Item:' || nvl(l_line.item, '&' || 'nbsp') || NLCHAR;
        l_document := l_document || 'UOM:' || nvl(l_line.uom, '&'||'nbsp') || NLCHAR;
        l_document := l_document || 'Quantity:' || nvl(to_char(l_line.quantity), '&' ||'nbsp') || NLCHAR;
        l_document := l_document || 'Unit Price:' || TO_CHAR(l_line.unit_selling_price) || NLCHAR;
        l_document := l_document || 'Margin:' || TO_CHAR(l_line_margin_percent) || NLCHAR;
*/

     END IF;



     p_x_document := l_document;
END build_quote_doc;




/* todo:Move it to the Holds package later */

/*************************
**  CHECK_CREDIT_HOLD    *
*************************/


function check_credit_hold (p_hold_entity_code     IN      varchar2,
                            p_hold_entity_id       IN      number
                            )
                            RETURN VARCHAR2
IS
 l_result_out              VARCHAR2(30);

BEGIN

  -- Initialize result to TRUE i.e. holds are found
  l_result_out := 'Y';


 BEGIN
  select 'Y'
     into l_result_out
    from oe_hold_sources HS,
         oe_hold_definitions h
      where HS.hold_entity_code = p_hold_entity_code
        and to_char(HS.hold_entity_id) = to_char(p_hold_entity_id) --9371206
        and HS.hold_id = 1
        and HS.released_flag = 'N'
        AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=  ROUND( SYSDATE )
        AND hs.hold_id = h.hold_id
        AND SYSDATE BETWEEN NVL( H.START_DATE_ACTIVE, SYSDATE )
                  AND NVL( H.END_DATE_ACTIVE, SYSDATE );

 EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_result_out := 'N';
        --IF l_debug_level  > 0 THEN
        --  oe_debug_pub.add(  'NO HOLDS FOUND FOR HEADER ID: ' || P_HDR_ID ) ;
        --END IF;
      WHEN TOO_MANY_ROWS THEN
        null;
 END;

 RETURN l_result_out;

END check_credit_hold;

PROCEDURE Complete_eligible_and_Book
                ( p_api_version_number          IN   NUMBER
                , p_init_msg_list               IN   VARCHAR2 := FND_API.G_FALSE
                , p_header_id                   IN   NUMBER
                , x_return_status               OUT  NOCOPY VARCHAR2
                , x_msg_count                   OUT  NOCOPY NUMBER
                , x_msg_data                    OUT  NOCOPY VARCHAR2
                )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Complete_eligible_and_Book';
  -- Use local variables instead of literals.
  l_wfeng_status   varchar2(24)  := 'WFENG_STATUS';
  l_root           varchar2(24)  := 'ROOT';
  l_negotiation    varchar2(1)   := 'N';
  l_oenh           varchar2(8)   := 'OENH';
  l_oebh           varchar2(8)   := 'OEBH';
  l_oeol           varchar2(8)   := 'OEOL';
  l_oeoh           varchar2(8)   := 'OEOH';
  l_standard_block varchar2(128) := 'OE_STANDARD_WF.STANDARD_BLOCK';
  l_eng_notified   varchar2(8) := 'NOTIFIED';
  l_eng_deferred   varchar2(8) := 'DEFERRED';
  l_retval              VARCHAR2(30);
  l_activity            VARCHAR2(30);
  l_book_eligible         VARCHAR2(1);
  l_book_deferred         VARCHAR2(1);
  l_booked_flag                   VARCHAR2(1);
  l_flow_status_code     VARCHAR2(30);
  l_flow_status          VARCHAR2(256);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  CURSOR c_eligible_activity IS
   select pa.activity_name
     from wf_item_activity_statuses s,
          wf_process_activities pa, wf_lookups l,
          wf_activities_vl act
     where s.activity_status = l.lookup_code
       and l.lookup_type = l_wfeng_status
       and s.process_activity = pa.instance_id
       and pa.activity_item_type = act.item_type
       and pa.activity_name = act.name
         and pa.process_name <> l_root
       and act.version = (select max(version)
                            from wf_activities_vl act2
                           where act.item_type = act2.item_type
                             and act.name = act2.name)
       and upper(s.activity_status) = l_eng_notified
       and s.item_type =  l_oenh
       and s.item_key = p_header_id
       and act.function = l_standard_block;

CURSOR book_eligible IS
        SELECT 'Y'
        FROM WF_ITEM_ACTIVITY_STATUSES WIAS
                , WF_PROCESS_ACTIVITIES WPA
        WHERE WIAS.item_type = 'OEOH'
          AND WIAS.item_key = p_header_id
          AND WIAS.activity_status = 'NOTIFIED'
          AND WPA.activity_name = 'BOOK_ELIGIBLE'
          AND WPA.instance_id = WIAS.process_activity;

CURSOR book_deferred IS
        SELECT 'Y'
        FROM WF_ITEM_ACTIVITY_STATUSES WIAS
                , WF_PROCESS_ACTIVITIES WPA
        WHERE WIAS.item_type = 'OEOH'
          AND WIAS.item_key = p_header_id
          AND WIAS.activity_status = 'DEFERRED'
          AND WPA.activity_name = 'BOOK_DEFER'
          AND WPA.instance_id = WIAS.process_activity;

BEGIN
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('In Complete_eligible_and_Book, header_id' || p_header_id);
   END IF;


   open c_eligible_activity;
   FETCH c_eligible_activity into l_activity;
   IF c_eligible_activity%NOTFOUND THEN
      oe_debug_pub.add('c_eligible_activity NOT FOUND');
      fnd_message.set_name('ONT','OE_NO_ELIGIBLE_ACTIVITIES');
      OE_MSG_PUB.ADD;
   ELSE
     close c_eligible_activity;
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('ELIGIBLE Activity: ' || l_activity);
     END IF;

     WF_ENGINE.CompleteActivityInternalName(OE_GLOBALS.G_WFI_NGO,
                       to_char(p_header_id), l_activity, l_retval);
     -- The order could have been booked already becuase the booking was synchronous.
     select booked_flag, flow_status_code
       into l_booked_flag, l_flow_status_code
       from oe_order_headers
      where header_id = p_header_id;
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('l_booked_flag: ' || l_booked_flag);
     END IF;

     IF l_booked_flag = 'N' THEN
       -- If the order is book eligigble then try to book it also.
       OPEN book_eligible;
       FETCH book_eligible INTO l_book_eligible;
          IF (book_eligible%NOTFOUND) THEN
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BOOKING NOT ELIGIBLE' ) ;
            END IF;
            -- Booking can be a high cost activity and may be deferred
            OPEN book_deferred;
            FETCH book_deferred INTO l_book_deferred;
            IF (book_deferred%FOUND) THEN
              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('BOOKING IS DEFERRED' );
              END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_ORDER_BOOK_DEFERRED');
              OE_MSG_PUB.ADD;
              CLOSE book_deferred;
            ELSE
              select MEANING
                into l_flow_status
                from oe_lookups
               WHERE  lookup_type= 'FLOW_STATUS'
                 AND  lookup_code = l_flow_status_code
                 AND  enabled_flag = 'Y'
                 AND  SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                        AND NVL(END_DATE_ACTIVE, SYSDATE);

              FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_NOT_BOOKED');
              FND_MESSAGE.SET_TOKEN('FLOW_STATUS', l_flow_status);
              OE_MSG_PUB.ADD;
            END IF; -- book_deferred%FOUND
          ELSE -- book_eligible%NOTFOUND
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Calling OE_Order_Book_Util.Complete_Book_Eligible' ) ;
            END IF;

            OE_Order_Book_Util.Complete_Book_Eligible
                    ( p_api_version_number  => 1.0
                    , p_header_id                   => p_header_id
                    , x_return_status               => x_return_status
                    , x_msg_count                   => x_msg_count
                    , x_msg_data                    => x_msg_data);

          END IF; -- book_eligible%NOTFOUND
     END IF; -- l_booked_flag = 'N'
   END IF; -- l_activity_Cur%NOTFOUND


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF (book_eligible%ISOPEN) THEN
                CLOSE book_eligible;
        END IF;
        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
        OE_MSG_PUB.Reset_Msg_Context(p_entity_code      => 'HEADER');
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (book_eligible%ISOPEN) THEN
                CLOSE book_eligible;
        END IF;
        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
        OE_MSG_PUB.Reset_Msg_Context(p_entity_code      => 'HEADER');
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (book_eligible%ISOPEN) THEN
                CLOSE book_eligible;
        END IF;
        IF      OE_MSG_PUB.Check_Msg_Level
                   (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                   OE_MSG_PUB.Add_Exc_Msg
                                ( G_PKG_NAME
                                , l_api_name
                                );
        END IF;
        OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );
        OE_MSG_PUB.Reset_Msg_Context(p_entity_code      => 'HEADER');

end Complete_eligible_and_Book;



END OE_Order_Wf_Util;

/
