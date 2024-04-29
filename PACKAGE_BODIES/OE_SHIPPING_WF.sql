--------------------------------------------------------
--  DDL for Package Body OE_SHIPPING_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SHIPPING_WF" as
/* $Header: OEXWSHPB.pls 120.4 2008/01/11 11:55:20 prpathak ship $ */


PROCEDURE Inc_Items_Freeze_Required(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_item_type      VARCHAR2(80);
l_ato_line_id    NUMBER;
l_explosion_date DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
    IF itemtype = OE_GLOBALS.G_WFI_LIN THEN

       IF l_debug_level >  0 THEN
          OE_DEBUG_PUB.Add('G_FREEZE_II:'||G_FREEZE_II);
       END IF;

       IF G_FREEZE_II = 'PICK RELEASE' THEN

          SELECT item_type_code,ato_line_id,explosion_date
          INTO  l_item_type,l_ato_line_id,l_explosion_date
          FROM  oe_order_lines_all
          WHERE line_id = to_number(itemkey);

          IF l_debug_level >  0 THEN
             OE_DEBUG_PUB.Add('Item Type:'||l_item_type);
             OE_DEBUG_PUB.Add('Exp Date:'||l_explosion_date);
          END IF;

          IF l_item_type in ('MODEL','CLASS','KIT') AND
                   l_ato_line_id is NULL AND
                   l_explosion_date is NULL  THEN

                     resultout := 'COMPLETE:Y';
                     IF l_debug_level >  0 THEN
                        OE_DEBUG_PUB.Add('Result set to YES!!');
                     END IF;
          ELSE
                     resultout := 'COMPLETE:N';
                     IF l_debug_level >  0 THEN
                        OE_DEBUG_PUB.Add('Result set to No!!');
                     END IF;
          END IF;

       ELSE
          resultout := 'COMPLETE:N';
       END IF;

    ELSE
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       -- item type is not a line
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    WF_CORE.Context('OE_WF_SHIPPING', 'Inc_items_freeze_required',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    RAISE;

End Inc_items_Freeze_Required;


PROCEDURE Start_Shipping(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
IS
l_line_id               NUMBER;
--bug 2979522
l_header_id             NUMBER;
l_user_id               NUMBER;
l_resp_id               NUMBER;
l_resp_appl_id          NUMBER;
l_resp_name             VARCHAR2(100);
l_appl_name             VARCHAR2(240);
l_descriptor            VARCHAR2(1000);
l_doc_type                VARCHAR2(100);
l_nid                   NUMBER;
l_from_role             VARCHAR2(320);
l_validate_user         NUMBER;
role_name               VARCHAR2(320);
l_eid                   NUMBER;

l_top_model_line_id     NUMBER;
l_return_status         VARCHAR2(30);
l_result_out            VARCHAR2(240);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_change_sequence            VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;
l_order_source_id            NUMBER;
--variable added for bug 3814076
l_itemkey                    NUMBER ;
--variable added for bug#6029753
l_if                         VARCHAR2(1);
l_oe_shipped_quantity        NUMBER;
BEGIN

  --
  -- RUN mode - normal process execution
  --
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENTERING OE_SHIPPING_WF.START_SHIPPING '||ITEMTYPE||'/'||ITEMKEY , 1 ) ;
        END IF;
        oe_msg_pub.set_process_activity(actid);
  if (funcmode = 'RUN') then


-- CODE CHANGES FOR BUG#6029753 STARTS HERE
        BEGIN

            SELECT  nvl(wdd.oe_interfaced_flag, 'N')
            INTO l_if
            FROM wsh_delivery_details wdd
            WHERE wdd.source_line_id = to_number(itemkey)
            AND wdd.source_code = 'OE'
            AND released_status = 'C'  --Added for bug#6727843
            GROUP BY oe_interfaced_flag;

            IF l_if = 'N' then
               resultout := 'NOTIFIED';
               RETURN;
            ELSIF l_if = 'Y' THEN
               BEGIN
                    SELECT NVL(shipped_quantity,0)
                    INTO l_oe_shipped_quantity
                    FROM oe_order_lines
                    WHERE line_id= to_number(itemkey);
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'ERROR: INVALID CONTEXT ATTRIBUTES' , 5 ) ;
                         END IF;
                         resultout := 'NOTIFIED';
                         RETURN;
               END;

               IF l_oe_shipped_quantity > 0 THEN
                  resultout := 'COMPLETE:SHIP_CONFIRM';
                  RETURN;
               END IF;
            END IF;

      EXCEPTION
          WHEN TOO_MANY_ROWS THEN
              resultout := 'NOTIFIED';
              RETURN;
          WHEN OTHERS THEN
              NULL;
      END;
      -- CODE CHANGES FOR BUG#6029753 ENDS HERE

  -- If it is BULK Mode then no need to query these values from Database

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NOT NULL THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('SHP BULK MODE' , 5 ) ;
    END IF;
    -- bug 4070931 starts
    IF OE_SHIPPING_INTEGRATION_PVT.G_BULK_WSH_INTERFACE_CALLED = TRUE THEN
      app_exception.raise_exception;
    END IF; -- bug 4070931 ends

    l_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);
    l_top_model_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.top_model_line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_header_id := OE_BULK_ORDER_PVT.G_LINE_REC.header_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_order_source_id := OE_BULK_ORDER_PVT.G_LINE_REC.order_source_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_orig_sys_document_ref := OE_BULK_ORDER_PVT.G_LINE_REC.orig_sys_document_ref(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_orig_sys_line_ref := OE_BULK_ORDER_PVT.G_LINE_REC.orig_sys_line_ref(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_orig_sys_shipment_ref := OE_BULK_ORDER_PVT.G_LINE_REC.orig_sys_shipment_ref(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_change_sequence := OE_BULK_ORDER_PVT.G_LINE_REC.change_sequence(OE_BULK_WF_UTIL.G_LINE_INDEX);

    /* Commenting for Bug 3319095
    l_source_document_type_id := OE_BULK_ORDER_PVT.G_LINE_REC.source_document_type_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_source_document_id := OE_BULK_ORDER_PVT.G_LINE_REC.source_document_id(OE_BULK_WF_UTIL.G_LINE_INDEX);

    l_source_document_line_id := OE_BULK_ORDER_PVT.G_LINE_REC.source_document_line_id(OE_BULK_WF_UTIL.G_LINE_INDEX);
    */

  ELSE
        -- # 2416391, locking issue
        SELECT line_id, top_model_line_id
               , header_id
               , order_source_id
               , orig_sys_document_ref
               , orig_sys_line_ref
               , orig_sys_shipment_ref
               , change_sequence
               , source_document_type_id
               , source_document_id
               , source_document_line_id
        INTO   l_line_id, l_top_model_line_id
               , l_header_id
               , l_order_source_id
               , l_orig_sys_document_ref
               , l_orig_sys_line_ref
               , l_orig_sys_shipment_ref
               , l_change_sequence
               , l_source_document_type_id
               , l_source_document_id
               , l_source_document_line_id
        FROM   oe_order_lines
        WHERE  line_id = to_number(itemkey);
  END IF; -- bulk mode or not

        OE_MSG_PUB.set_msg_context(
              p_entity_code                => 'LINE'
             ,p_entity_id                  => l_line_id
             ,p_header_id                  => l_header_id
             ,p_line_id                    => l_line_id
             ,p_order_source_id            => l_order_source_id
             ,p_orig_sys_document_ref      => l_orig_sys_document_ref
             ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
             ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
             ,p_change_sequence            => l_change_sequence
             ,p_source_document_type_id    => l_source_document_type_id
             ,p_source_document_id         => l_source_document_id
             ,p_source_document_line_id    => l_source_document_line_id
            );

        OE_SHIPPING_INTEGRATION_PVT.G_DEBUG_MSG  :=  NULL;
        OE_SHIPPING_INTEGRATION_PVT.G_DEBUG_CALL :=  1;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'TOP MODEL LINE ID : '||L_TOP_MODEL_LINE_ID , 3 ) ;
        END IF;

  IF OE_BULK_WF_UTIL.G_LINE_INDEX IS NULL THEN

        IF nvl(l_top_model_line_id,0) <> 0 THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE LOCKING THE TOP LINE '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
           END IF;
           SELECT line_id, top_model_line_id
           INTO   l_line_id, l_top_model_line_id
           FROM   oe_order_lines_all
           WHERE  line_id = l_top_model_line_id
           FOR UPDATE NOWAIT;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'TOP LINE LOCKED AT '||TO_CHAR ( SYSDATE , 'DD-MM-YYYY HH24:MI:SS' ) , 3 ) ;
           END IF;

        ELSE
       --bug 3814076
           l_itemkey := to_number(itemkey);
           SELECT line_id
           INTO   l_line_id
           FROM   oe_order_lines_all
           WHERE  line_id = l_itemkey
           FOR UPDATE NOWAIT;

        END IF;
  END IF; -- no bulk mode

        l_line_id       := to_number(itemkey);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING OE_SHIPPING_INTEGRATION_PVT.PROCESS_SHIPPING_ACTIVITY '||TO_CHAR ( L_LINE_ID ) , 2 ) ;
        END IF;
        OE_Shipping_Integration_PVT.Process_Shipping_Activity
                        ( p_api_version_number  => 1.0
                        , p_line_id                     => l_line_id
                        , x_result_out                  => l_result_out
                        , x_return_status               => l_return_status
                        , x_msg_count                   => l_msg_count
                        , x_msg_data                    => l_msg_data
                        );
        OE_SHIPPING_INTEGRATION_PVT.G_DEBUG_CALL :=  0;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RETURNED FROM OE_SHIPPING_INTEGRATION_PVT.PROCESS_SHIPPING_ACTIVITY '||L_RETURN_STATUS , 2 ) ;
        END IF;


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                app_exception.raise_exception;
        END IF;

        resultout := l_result_out;
        OE_STANDARD_WF.Clear_Msg_Context;
        return;

  end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;

  /* bug 2979522 */
  if (funcmode = 'SKIP') then
BEGIN
   -- WF require a COMPLETE result out
   IF G_DEV_SKIP = 'Y' THEN
     resultout := 'COMPLETE';
   ELSE

     insert into ont_wf_skip_log(creation_date, line_id, activity_id, user_id, responsibility_id, application_id) values (sysdate, to_number(itemkey), actid, FND_GLOBAL.user_id, FND_GLOBAL.RESP_ID, FND_GLOBAL.RESP_APPL_ID);

     resultout := 'COMPLETE';
     select header_id
     into l_header_id
     from oe_order_lines_all
     where line_id = to_number(itemkey);

     oe_msg_pub.initialize;
     oe_msg_pub.set_process_activity(actid);
     oe_msg_pub.set_msg_context(p_header_id=>l_header_id, p_line_id=>to_number(itemkey));
     fnd_message.set_name('ONT', 'ONT_WF_NO_SKIP_SHIP');
     oe_msg_pub.add;
     OE_STANDARD_WF.save_messages;
     --log a OM message in our message stack

     l_user_id := FND_GLOBAL.USER_ID;
     l_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
     l_resp_id := FND_GLOBAL.RESP_ID;


     select employee_id
     into   l_eid
     from fnd_user
     where user_id =l_user_id;

     IF l_eid is null THEN
       select name
       into role_name
       from wf_roles
       where orig_system='FND_USR'
       and orig_system_id = l_user_id;
     ELSE
       select name
       into role_name
       from wf_roles
       where orig_system='PER'
       and orig_system_id = l_eid;
     END IF;


     select RESPONSIBILITY_NAME
     into l_resp_name
     from FND_RESPONSIBILITY_VL
     where RESPONSIBILITY_ID=l_resp_id
     and APPLICATION_ID=l_resp_appl_id;

     select APPLICATION_NAME
     into l_appl_name
     from fnd_application_vl
     where APPLICATION_ID = l_resp_appl_id;

     l_from_role := 'SYSADMIN';

 BEGIN
   select 1
   into l_validate_user
   from wf_roles
   where name = l_from_role;

 EXCEPTION
    WHEN OTHERS THEN
      l_from_role := null; -- do not set FROM_ROLE then
 END;

     -- notification to the skipper
     wf_engine.SetItemAttrText(itemtype, itemkey, 'NOTIFICATION_FROM_ROLE', l_from_role);

     l_nid := WF_NOTIFICATION.Send(role_name, 'OEOL', 'WORKFLOW_SKIPPED_MSG');

     OE_ORDER_WF_UTIL.Set_Line_Descriptor(l_nid, null, l_descriptor, l_doc_type);
     WF_NOTIFICATION.SetAttrText(l_nid, 'LINE_DESCRIPTOR', l_descriptor);


     -- l_from_role = SYSADMIN
     -- notification to SYSADMIN
     l_nid := WF_NOTIFICATION.Send(l_from_role, 'OEOL', 'WORKFLOW_SKIPPED_ADMIN_MSG');

     OE_ORDER_WF_UTIL.Set_Line_Descriptor(l_nid, null, l_descriptor, l_doc_type);

     WF_NOTIFICATION.SetAttrText(l_nid, 'USER_NAME', role_name);
     WF_NOTIFICATION.SetAttrText(l_nid, 'RESP_NAME', l_resp_name);
     WF_NOTIFICATION.SetAttrText(l_nid, 'APPL_NAME', l_appl_name);
     WF_NOTIFICATION.SetAttrText(l_nid, 'LINE_DESCRIPTOR', l_descriptor);
   END IF; --G_DEV_SKIP == 'N'

EXCEPTION
   WHEN OTHERS THEN
     null;
END;

  end if;



  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
    -- some one else is currently working on the line
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXWSHPB.pls: unable to lock the lines',1);
    END IF;
    resultout := 'DEFERRED';

  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Shipping_WF', 'Shipping_Activity',
                    itemtype, itemkey, to_char(actid), funcmode,
                               OE_SHIPPING_INTEGRATION_PVT.G_DEBUG_MSG);
    OE_SHIPPING_INTEGRATION_PVT.G_DEBUG_CALL :=  0;
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    -- end data fix project
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    raise;
END START_SHIPPING;

END OE_Shipping_WF;

/
