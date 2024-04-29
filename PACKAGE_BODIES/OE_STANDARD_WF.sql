--------------------------------------------------------
--  DDL for Package Body OE_STANDARD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_STANDARD_WF" AS
/* $Header: OEXWSTDB.pls 120.3.12010000.2 2008/08/04 15:09:44 amallik ship $ */

-- This procedure sets the global g_upgrade_mode to TRUE
Procedure UPGRADE_MODE_ON
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  OE_STANDARD_WF.G_UPGRADE_MODE := TRUE;
End UPGRADE_MODE_ON;

-- This procedure sets the global g_save_messages to TRUE
Procedure SAVE_MESSAGES_ON
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  OE_STANDARD_WF.G_SAVE_MESSAGES := TRUE;
End SAVE_MESSAGES_ON;

-- This procedure sets the global g_save_messages to FALSE
Procedure SAVE_MESSAGES_OFF
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  OE_STANDARD_WF.G_SAVE_MESSAGES := FALSE;
End SAVE_MESSAGES_OFF;

-- This procedure sets the global G_RESET_APPS_CONTEXT to TRUE
Procedure RESET_APPS_CONTEXT_ON
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  OE_STANDARD_WF.G_RESET_APPS_CONTEXT := TRUE;
End RESET_APPS_CONTEXT_ON;

-- This procedure sets the global G_RESET_APPS_CONTEXT to FALSE
Procedure RESET_APPS_CONTEXT_OFF
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  OE_STANDARD_WF.G_RESET_APPS_CONTEXT := FALSE;
End RESET_APPS_CONTEXT_OFF;

-- Callers should pass in the instance_id. This is used to set Workflow
-- context for messages.
PROCEDURE SET_MSG_CONTEXT(P_PROCESS_ACTIVITY IN NUMBER DEFAULT NULL)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    OE_MSG_PUB.Set_Process_Activity(p_process_activity);
END;

-- This procedures clears the workflow context from the context area.
PROCEDURE CLEAR_MSG_CONTEXT
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    OE_MSG_PUB.Set_Process_Activity(NULL);
END;

PROCEDURE SAVE_MESSAGES(
   p_instance_id IN NUMBER DEFAULT NULL
)
is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('In WF save messages', 5);
   END IF;

-- we will save the message regardless of the global
-- since the save_api_messages will have the intelligence
-- not to save duplicate messages

   -- not passing the p_instance_id as it is not used for WF
   OE_MSG_PUB.Save_API_Messages(p_request_id => NULL, p_message_source_code => 'W');


exception
  when others then
    Wf_Core.Context('OE_STANDARD_WF', 'SAVE_MESSAGES');
    raise;
end SAVE_MESSAGES;



/*--------------------------------------------------------------------
	New BLOCK activity defined so that the activity cannot be
	completed by the end-user through 'Progress Order'. This
        block function should be used instead of the wf_engine standard
        block function if the activity should be blocked for completion
        from the Progress Order form
----------------------------------------------------------------------*/
procedure STANDARD_BLOCK(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2 /* file.sql.39 change */
)
is
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project

  -- Do nothing in cancel or timeout mode
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  resultout := wf_engine.eng_notified||':'||wf_engine.eng_null||
                 ':'||wf_engine.eng_null;
exception
  when others then
    Wf_Core.Context('OE_STANDARD_WF', 'STANDARD_BLOCK', itemtype,
                    itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
end STANDARD_BLOCK;

/* --------------------------------------------------------
   This procedure is used to set the database session context
   correctly before executing a function activity. The selector
   function will be run by the workflow engine in the SET_CTX
   mode before executing the activity.
----------------------------------------------------------- */

PROCEDURE OEOH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_header_id           NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- p_result := FND_API.G_MISS_CHAR;

-- Workflow engine calls the SET_CTX to set the context for the
-- activity before the execution.
--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804


  l_header_id := to_number(p_itemkey);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'HEADER ID IS ' || L_HEADER_ID ) ;
  END IF;

-- Currently this mode is not being used
-- we are using the OE_ORDER_WF_UTIL pkg functions
-- to find out the flow that a header needs to follow
-- and passing that in the createprocess call within
-- Process Order.

   IF (p_funcmode = 'RUN') THEN
    p_result := 'COMPLETE';

  -- Engine calls SET_CTX just before activity execution

  ELSIF(p_funcmode = 'SET_CTX') THEN


   -- Any caller that calls the WF_ENGINE can set this to FALSE in which case
   -- we will not reset apps context to that of the user who created the line
   -- wf item.

   IF G_RESET_APPS_CONTEXT THEN

      SELECT org_id
	INTO l_org_id
        FROM oe_order_headers_all
       WHERE header_id = to_number (p_itemkey);
      IF l_debug_level  > 0 THEN
           oe_debug_pub.add('ORG ID IS ' || l_org_id ) ;
      END IF;

      MO_GLOBAL.set_policy_context ('S', l_org_id);

   END IF;

    p_result := 'COMPLETE';

 -- Notification Viewer form calls the TEST_CTX just before launching the form
 -- WF Engine calls TEST_CTX, if this returns FALSE then flow is deferred.
    ELSIF (p_funcmode = 'TEST_CTX') THEN

        --initialize global so each tested flow must set explicitly
        OE_GLOBALS.G_FLOW_RESTARTED := FALSE;

        IF G_UPGRADE_MODE THEN -- During Upgrade Mode we always return TRUE;

           p_result := 'TRUE';

        ELSE -- Normal Mode

           IF G_RESET_APPS_CONTEXT THEN

	       -- Setting a global varaible to indicate that the process is being run
               -- as a result of the flow being restarted
	       OE_GLOBALS.G_FLOW_RESTARTED := TRUE;

               SELECT org_id
     	         INTO l_org_id
               	 FROM oe_order_headers_all
            	WHERE header_id = to_number (p_itemkey);

                IF NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id
                THEN
                    p_result := 'FALSE';
                ELSE
                    p_result := 'TRUE';
                END IF;

           ELSE -- G_RESET_APPS_CONTEXT is FALSE
                   p_result := 'TRUE';
           END IF;

        END IF;  -- End If Upgrade Mode

    END IF; -- End if TEST_CTX

--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Exiting OEOH_SELECTOR , RESULT = '||P_RESULT
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804
EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_STANDARD_WF', 'OEOH_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END OEOH_SELECTOR;

/* --------------------------------------------------------
   This procedure is used to set the database session context
   correctly before executing a function activity. The selector
   function will be run by the workflow engine in the SET_CTX
   mode before executing the activity.
----------------------------------------------------------- */
PROCEDURE OEOL_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Currently this mode is not being used
-- we are using the OE_ORDER_WF_UTIL pkg functions
-- to find out the flow that a line needs to follow
-- and passing that in the createprocess call within
-- Process Order.
--Bug 6884804
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN OEOL_SELECTOR , FUNCMODE:' || P_FUNCMODE || ' ' || P_ITEMTYPE || ' ' || P_ITEMKEY , 1 ) ;
   END IF;
--End Bug 6884804
   IF G_RESET_APPS_CONTEXT THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'G_RESET_APPS_CONTEXT IS TRUE' ) ;
       END IF;
   ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'G_RESET_APPS_CONTEXT IS FALSE' ) ;
       END IF;
   END IF;

   IF G_UPGRADE_MODE THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'G_UPGRADE_MODE IS TRUE' ) ;
       END IF;
   ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'G_UPGRADE_MODE IS FALSE' ) ;
       END IF;
   END IF;

   if (p_funcmode = 'RUN') THEN
     p_result := 'COMPLETE';

   -- Engine calls SET_CTX just before activity execution
   -- The workflow engine calls the selector function
   -- in the SET_CTX mode to set the database context
   -- correctly for executing a function activity.
   ELSIF(p_funcmode = 'SET_CTX') THEN
     -- Any caller that calls the WF_ENGINE can set this to FALSE in which case
     -- we will not reset apps context to that of the user who created the line
     -- wf item.
     IF G_RESET_APPS_CONTEXT THEN
         SELECT org_id
           INTO l_org_id
           FROM oe_order_lines_all
          WHERE line_id = to_number (p_itemkey);

         MO_GLOBAL.set_policy_context ('S', l_org_id);

     END IF;
     p_result := 'COMPLETE';

    -- Notification Viewer form calls the TEST_CTX just before launching the form
    -- If test_ctx returns false, then flow is automatically deferred.
    ELSIF (p_funcmode = 'TEST_CTX') THEN

       --initialize global so each tested flow must set explicitly
       OE_GLOBALS.G_FLOW_RESTARTED := FALSE;

       IF G_UPGRADE_MODE THEN -- During Upgrade Mode we always return TRUE;
           p_result := 'TRUE';
       ELSE -- Normal Mode
         IF G_RESET_APPS_CONTEXT THEN

	   -- Setting a global varaible to indicate that the process is
           -- being run as a result of the flow being restarted
           OE_GLOBALS.G_FLOW_RESTARTED := TRUE;

           SELECT org_id
             INTO l_org_id
             FROM oe_order_lines_all
            WHERE line_id = to_number (p_itemkey);
           IF l_debug_level  > 0 THEN
             oe_debug_pub.add('ORG ID IS ' || l_org_id ) ;
           END IF;

          IF NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id
          THEN
           p_result := 'FALSE';
          ELSE
           p_result := 'TRUE';
          END IF;

         ELSE -- G_RESET_APPS_CONTEXT is FALSE
           p_result := 'TRUE';
         END IF;

       END IF; -- End Upgrade Mode.

     END IF; -- End mode

--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Exiting OEOL_SELELECTOR , RESULT = '||P_RESULT
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'P_RESULT:' || P_RESULT ) ;
     END IF;

EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_STANDARD_WF', 'OEOL_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END OEOL_SELECTOR;


/* --------------------------------------------------------
   This procedure is used to set the database session context
   correctly before executing a function activity. The selector
   function will be run by the workflow engine in the SET_CTX
   mode before executing the activity.
----------------------------------------------------------- */

PROCEDURE OENH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_header_id           NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;
  l_sales_document_type_code VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Workflow engine calls the SET_CTX to set the context for the
-- activity before the execution.
--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE
      ||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804

  l_header_id := to_number(p_itemkey);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OENH HEADER ID IS ' || L_HEADER_ID ) ;
  END IF;

  IF (p_funcmode = 'RUN') THEN
    p_result := 'COMPLETE';

  ELSIF(p_funcmode = 'SET_CTX') THEN

   -- Any caller that calls the WF_ENGINE can set this to FALSE in which case
   -- we will not reset apps context to that of the user who created the line
   -- wf item.

   IF G_RESET_APPS_CONTEXT THEN

       l_sales_document_type_code := WF_ENGINE.GetItemAttrText(p_itemtype,
                                       p_itemkey, 'SALES_DOCUMENT_TYPE_CODE');

       IF l_sales_document_type_code = 'O' THEN
          SELECT org_id
            INTO l_org_id
            FROM oe_order_headers_all
           WHERE header_id = to_number (p_itemkey);
       ELSIF l_sales_document_type_code = 'B' THEN
          SELECT org_id
            INTO l_org_id
            FROM oe_blanket_headers_all
           WHERE header_id = to_number (p_itemkey);
       ELSE
          -- Should never get here. In negotiation phase it should be O or B
          oe_debug_pub.add('l_sales_document_type_code is NULL for:' || p_itemkey);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       MO_GLOBAL.set_policy_context ('S', l_org_id);

   END IF;

    p_result := 'COMPLETE';

    -- Notification Viewer form calls the TEST_CTX just before launching the form
    -- WF Engine calls TEST_CTX, if this returns FALSE then flow is deferred.
    ELSIF (p_funcmode = 'TEST_CTX') THEN

        --initialize global so each tested flow must set explicitly
        OE_GLOBALS.G_FLOW_RESTARTED := FALSE;

        IF G_UPGRADE_MODE THEN -- During Upgrade Mode we always return TRUE;

		p_result := 'TRUE';

        ELSE -- Normal Mode

             IF G_RESET_APPS_CONTEXT THEN

	        -- Setting a global varaible to indicate that the process
                -- is being run as a result of the flow being restarted
	        OE_GLOBALS.G_FLOW_RESTARTED := TRUE;

              l_sales_document_type_code := WF_ENGINE.GetItemAttrText(p_itemtype,
                                                    p_itemkey, 'SALES_DOCUMENT_TYPE_CODE');

              IF l_sales_document_type_code = 'O' THEN
                SELECT org_id
                  INTO l_org_id
                  FROM oe_order_headers_all
                 WHERE header_id = to_number (p_itemkey);
              ELSIF l_sales_document_type_code = 'B' THEN
                SELECT org_id
                  INTO l_org_id
                  FROM oe_blanket_headers_all
                 WHERE header_id = to_number (p_itemkey);
              ELSE
                -- Should never get here. In negotiation phase it should be O or B
                oe_debug_pub.add('l_sales_document_type_code is NULL for:' || p_itemkey);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

                IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('ORG ID IS ' || l_org_id ) ;
                END IF;

                IF NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id
                THEN
                   p_result := 'FALSE';
                ELSE
                   p_result := 'TRUE';
                END IF;

            ELSE -- G_RESET_APPS_CONTEXT is FALSE
                   p_result := 'TRUE';
            END IF;

       END IF;  -- End If Upgrade Mode

    END IF; -- End if TEST_CTX

--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Exiting OENH_SELECTOR , RESULT = '||P_RESULT
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804
EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_STANDARD_WF', 'OENH_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END OENH_SELECTOR;



/* --------------------------------------------------------
   This procedure is used to set the database session context
   correctly before executing a function activity. The selector
   function will be run by the workflow engine in the SET_CTX
   mode before executing the activity.
----------------------------------------------------------- */

PROCEDURE OEBH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_header_id           NUMBER;
  l_org_id              NUMBER;
  l_current_org_id      NUMBER;
  l_client_org_id       NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Workflow engine calls the SET_CTX to set the context for the
-- activity before the execution.
--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'THE WORKFLOW FUNCTION MODE IS: FUNCMODE='||P_FUNCMODE
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804

  l_header_id := to_number(p_itemkey);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEBH HEADER ID IS ' || L_HEADER_ID ) ;
  END IF;

  IF (p_funcmode = 'RUN') THEN
    p_result := 'COMPLETE';

  ELSIF(p_funcmode = 'SET_CTX') THEN

   -- Any caller that calls the WF_ENGINE can set this to FALSE in which case
   -- we will not reset apps context to that of the user who created the line
   -- wf item.

   IF G_RESET_APPS_CONTEXT THEN
     SELECT org_id
       INTO l_org_id
       FROM oe_blanket_headers_all
      WHERE header_id = to_number (p_itemkey);

     MO_GLOBAL.set_policy_context ('S', l_org_id);

   END IF;

    p_result := 'COMPLETE';

 -- Notification Viewer form calls the TEST_CTX just before launching the form
 -- WF Engine calls TEST_CTX, if this returns FALSE then flow is deferred.
    ELSIF (p_funcmode = 'TEST_CTX') THEN

       --initialize global so each tested flow must set explicitly
        OE_GLOBALS.G_FLOW_RESTARTED := FALSE;


       IF G_UPGRADE_MODE THEN -- During Upgrade Mode we always return TRUE;

		p_result := 'TRUE';

       ELSE -- Normal Mode

         IF G_RESET_APPS_CONTEXT THEN

            -- Setting a global varaible to indicate that the process is
            -- being run as a result of the flow being restarted
            OE_GLOBALS.G_FLOW_RESTARTED := TRUE;

            SELECT org_id
              INTO l_org_id
               	   FROM oe_blanket_headers_all
            	WHERE header_id = to_number (p_itemkey);
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('ORG ID IS ' || l_org_id ) ;
            END IF;

            IF NVL(MO_GLOBAL.get_current_org_id, -99) <> l_org_id
            THEN
               p_result := 'FALSE';
            ELSE
               p_result := 'TRUE';
            END IF;

         ELSE -- G_RESET_APPS_CONTEXT is FALSE
                   p_result := 'TRUE';
         END IF;

       END IF;  -- End If Upgrade Mode

    END IF; -- End if TEST_CTX

--Bug 6884804
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( ' Exiting OEBH_SELECTOR , RESULT = '||P_RESULT
||' ITEMTYPE = '||P_ITEMTYPE||' ITEMKEY = '||P_ITEMKEY,1);
  END IF;
--End Bug 6884804
EXCEPTION
   WHEN OTHERS THEN NULL;
   WF_CORE.Context('OE_STANDARD_WF', 'OEBH_SELECTOR',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
   RAISE;


END OEBH_SELECTOR;


/* --------------------------------------------------------
   This procedure is used to Get the source_type of the line.
----------------------------------------------------------- */
PROCEDURE Get_Supply_Source_Type
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_source_type VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  -- end data fix project

   if (p_funcmode = 'RUN') THEN
	SELECT source_type_code
     INTO l_source_type
     FROM oe_order_lines_all
     WHERE line_id = to_number(p_itemkey);

     IF l_source_type = OE_GLOBALS.G_SOURCE_EXTERNAL THEN
        p_result := 'COMPLETE:EXTERNAL';
     ELSE
        p_result := 'COMPLETE:INTERNAL';
     END IF;
   end if;


EXCEPTION
   WHEN OTHERS THEN NULL;
   oe_msg_pub.set_msg_context ( p_entity_code         => 'LINE'
                               ,p_line_id             => p_itemkey);
   WF_CORE.Context('OE_STANDARD_WF', 'Get_Supply_Source_Type',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
   RAISE;


END Get_Supply_Source_Type;


/* --------------------------------------------------------
   This procedure is used to Get the Line Category.
----------------------------------------------------------- */
PROCEDURE Get_Line_Category
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_category_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  -- end data fix project
   IF (p_funcmode = 'RUN') THEN
    IF p_itemtype = OE_GLOBALS.G_WFI_LIN THEN
       l_category_code := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'LINE_CATEGORY');
       p_result := 'COMPLETE:'||l_category_code;
    ELSE
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- item type is not a line
    END IF;

   ELSE

	  p_result := 'COMPLETE:';

   END IF;

EXCEPTION
   WHEN OTHERS THEN NULL;
   oe_msg_pub.set_msg_context ( p_entity_code         => 'LINE'
                               ,p_line_id             => p_itemkey);
   WF_CORE.Context('OE_STANDARD_WF', 'Get_Line_Category',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
   RAISE;


END Get_Line_Category;



PROCEDURE Set_Exception_Message
IS
l_data VARCHAR2(500);
l_msg_index_out NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   OE_MSG_PUB.GET( p_msg_index => OE_MSG_PUB.G_LAST
    ,p_encoded   => FND_API.G_FALSE
    ,p_data      =>  l_data
    ,p_msg_index_out => l_msg_index_out);
   FND_MESSAGE.SET_NAME('ONT', 'OE_WF_EXCEPTION');
   FND_MESSAGE.SET_TOKEN('EXCEPTION', l_data);

END Set_Exception_Message;

/* --------------------------------------------------------
   This procedure is used to log a message with the
   indicating the workflow activity that failed.
   A different error message is used when the
   message stack is empty as opposed to when
   there are messages.
----------------------------------------------------------- */

PROCEDURE Add_Error_Activity_Msg (p_actid IN NUMBER, p_itemkey IN VARCHAR2, p_itemtype IN VARCHAR2)
IS
l_msg_count NUMBER := 0;
l_activity_name VARCHAR2(80);
BEGIN
   l_msg_count := OE_MSG_PUB.Count_Msg;

   SELECT wfa.display_name
     INTO l_activity_name
     FROM wf_activities_vl wfa, wf_process_activities wpa
    WHERE wpa.instance_id = p_actid
      AND wpa.activity_item_type = p_itemtype
      AND wfa.item_type = p_itemtype
      AND wfa.name = wpa.activity_name
      AND (wfa.end_date is null OR wfa.end_date >= sysdate)
      AND rownum = 1;

   IF l_msg_count > 0 THEN
      FND_MESSAGE.SET_NAME ('ONT', 'OE_WF_ACTIVITY_ERROR');
      FND_MESSAGE.SET_TOKEN ('ACTIVITY_NAME', l_activity_name);
      OE_Msg_Pub.Add;
   ELSE
      FND_MESSAGE.SET_NAME ('ONT', 'OE_WF_ACTIVITY_UNEXP_ERROR');
      FND_MESSAGE.SET_TOKEN ('ACTIVITY_NAME', l_activity_name);
      OE_Msg_Pub.Add;
   END IF;
EXCEPTION
  WHEN OTHERS THEN NULL;
END Add_Error_Activity_Msg;

end OE_STANDARD_WF;

/
