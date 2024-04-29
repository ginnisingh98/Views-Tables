--------------------------------------------------------
--  DDL for Package Body OE_FULFILL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FULFILL_WF" as
/* $Header: OEXWFULB.pls 120.2 2006/01/03 11:59:35 ssurapan noship $ */

/*-------------------------------------------------------------
PROCEDURE Check_Wait_To_Fulfill_Line
--------------------------------------------------------------*/

PROCEDURE Check_Wait_To_Fulfill_Line
(itemtype          IN         VARCHAR2
,itemkey           IN         VARCHAR2
,actid             IN         NUMBER
,funcmode          IN         VARCHAR2
,resultout         IN OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

  l_item_type              VARCHAR2(80);
  l_shippable_flag         VARCHAR2(1);
  l_service_ship_flag      VARCHAR2(1);
  l_header_id              NUMBER;
  l_service_ref_line_id    NUMBER;
  l_service_header_id      NUMBER;
  l_top_model_line_id      NUMBER;
  -- Bug 4875015
  l_service_reference_type_code  VARCHAR2(30);

  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --

BEGIN

   --
   -- RUN mode - normal process execution
   --

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering Check Wait to Fulfill Line'||itemkey,1 ) ;
   END IF;

   IF (funcmode = 'RUN') THEN

       OE_STANDARD_WF.Set_Msg_Context(actid);

       IF itemtype = OE_GLOBALS.G_WFI_LIN THEN
          -- Bug 4875015
          SELECT item_type_code,shippable_flag,top_model_line_id, service_reference_type_code
          INTO   l_item_type,l_shippable_flag,l_top_model_line_id, l_service_reference_type_code
          FROM   oe_order_lines_all
          WHERE  line_id = to_number(itemkey);

          IF l_top_model_line_id IS NOT NULL AND
                        nvl(l_shippable_flag,'N') = 'N' THEN

             -- Do not Hold Service and Non Shippable lines
             -- part of configurations.

             resultout := 'COMPLETE:N';

             IF l_debug_level >  0 THEN
                OE_DEBUG_PUB.Add('Result set to No, Line part of configuration!!');
             END IF;

        ELSIF l_item_type = 'SERVICE' AND
                        nvl(l_shippable_flag,'N') = 'N' THEN
           -- Bug 4875015
           IF l_service_reference_type_code = 'ORDER' THEN

              SELECT header_id,service_reference_line_id
              INTO   l_header_id,l_service_ref_line_id
              FROM   oe_order_lines_all
              WHERE  line_id = to_number(itemkey)
              AND    service_reference_type_code = 'ORDER';


              SELECT header_id,shippable_flag
              INTO   l_service_header_id,l_service_ship_flag
              FROM   oe_order_lines_all
              WHERE  line_id = l_service_ref_line_id;


              IF l_header_id = l_service_header_id AND
                        nvl(l_service_ship_flag,'N') = 'Y' THEN

                 IF l_debug_level >  0 THEN
                    OE_DEBUG_PUB.Add('Result set to No!! Service in same order');
                 END IF;

                 -- Do not hold services lines attached
                 -- to lines with in the same order.

                 resultout := 'COMPLETE:N';
              ELSE

                 IF l_debug_level >  0 THEN
                    OE_DEBUG_PUB.Add('Result set to Yes!! Service not in same order');
                     OE_DEBUG_PUB.Add('or Line is Service attached to Non Shippable Line');
                 END IF;

                 -- Hold services lines attached
                 -- to lines not in the same order.

                 resultout := 'COMPLETE:Y';
              END IF;

           ELSE -- Bug 4875015
               resultout := 'COMPLETE:N';
               IF l_debug_level >  0 THEN
                   OE_DEBUG_PUB.Add('Result set to N. service reference type is not ORDER', 1);
               END IF;
           END IF;  -- Bug 4875015 End

        ELSIF   nvl(l_shippable_flag,'N') = 'N'   THEN

                -- Hold Non Shippable Lines.

                resultout := 'COMPLETE:Y';

                IF l_debug_level >  0 THEN
                   OE_DEBUG_PUB.Add('Result set to YES!! Non Shippable Line');
                END IF;

        ELSE

                resultout := 'COMPLETE:N';

                IF l_debug_level >  0 THEN
                   OE_DEBUG_PUB.Add('Result set to No!!Shippable Line');
                END IF;
        END IF;

     ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          -- item type is not a line
     END IF;

   END IF; -- End for 'RUN' mode

   --
   -- CANCEL mode - activity 'compensation'
   --
   -- This is an event point is called with the effect of the activity must
   -- be undone, for example when a process is reset to an earlier point
   -- due to a loop back.
   --
   IF (funcmode = 'CANCEL') THEN
       -- your cancel code goes here
       null;

       -- no result needed
       resultout := 'COMPLETE';
       return;
   END IF;


   --
   -- Other execution modes may be created in the future.  Your
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --
   -- resultout := '';
   -- return;

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_FULFILL_WF', 'Check_Wait_To_Fulfill_Line',
                       itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    -- end data fix project
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    IF l_debug_level >  0 THEN
       OE_DEBUG_PUB.Add('When Other in Check Wait Fulfill'||sqlerrm);
    END IF;
    raise;
END Check_Wait_To_Fulfill_Line;

/*-------------------------------------------------------------
PROCEDURE Complete_Fulfill_Eligible_Line
Description: This Procedure will complete the Fulfill Line
             Eligible Activity for a line. This Procedure first
             Checks whether the line is Notified for the activity
             If Yes complete the activity else return.
             Lock the Row before you complete the activity.
--------------------------------------------------------------*/

PROCEDURE Complete_Fulfill_Eligible_Line
(p_line_id         IN         NUMBER
,x_return_status   OUT NOCOPY  VARCHAR2)
IS

 l_activity_status      VARCHAR2(30);
 l_line_rec             OE_Order_PUB.Line_Rec_Type;
 l_return_status        VARCHAR2(1);

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check whether the line is eligible to Fulfill

   IF l_debug_level >  0 THEN
      OE_DEBUG_PUB.Add('Entering Complete Fulfill Eligible Line ');
   END IF;

   BEGIN
       SELECT WIAS.Activity_Status
       INTO   l_activity_status
       FROM   wf_item_activity_statuses WIAS,
              wf_process_activities WPA
       WHERE  WIAS.Process_Activity = WPA.instance_id
       AND    WPA.activity_name     = 'FULFILL_LINE_ELIGIBLE'
       AND    WIAS.item_type        = 'OEOL'
       AND    WIAS.item_key         = to_char(p_line_id)
       AND    WIAS.activity_status  = 'NOTIFIED' ;
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            x_return_status :=  FND_API.G_RET_STS_ERROR;

            IF l_debug_level >  0 THEN
               OE_DEBUG_PUB.Add('Line Not Eligible for Fulfillment');
            END IF;
            RETURN;
   END;

   -- Lock the Row

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Before Calling Lock Row'||p_line_id);
   END IF;

   OE_Line_Util.lock_Row
               ( p_line_id       => p_line_id
                ,p_x_line_rec    => l_line_rec
                ,x_return_status => l_return_status
               );

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('After Calling Lock Row'||l_return_status);
   END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Complete the work flow Fulfill Line Eligible Activity

   WF_ENGINE.CompleteActivityInternalName (
              Itemtype  => 'OEOL',
              Itemkey   => to_char (p_line_id),
              Activity  => 'FULFILL_LINE_ELIGIBLE',
              Result    => OE_GLOBALS.G_WFR_COMPLETE);

   IF l_debug_level >  0 THEN
      OE_DEBUG_PUB.Add('Exiting Complete Fulfill Eligible Line ');
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

         IF l_debug_level >  0 THEN
            OE_DEBUG_PUB.Add('Expected Error in Fulfill Eligible'||sqlerrm);
         END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level >  0 THEN
            OE_DEBUG_PUB.Add('Un Expected Error in Fulfill Eligible');
         END IF;
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level >  0 THEN
            OE_DEBUG_PUB.Add('Un Expected Error in Fulfill Eligible'||sqlerrm);
         END IF;

END Complete_Fulfill_Eligible_Line;



/*-------------------------------------------------------------
PROCEDURE Start_Fulfillment
--------------------------------------------------------------*/

PROCEDURE Start_Fulfillment(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_line_id  		NUMBER;
l_return_status	VARCHAR2(30);
l_result_out		VARCHAR2(240);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_header_id                  NUMBER;
l_order_source_id            NUMBER;
l_orig_sys_document_ref      VARCHAR2(50);
l_orig_sys_line_ref          VARCHAR2(50);
l_orig_sys_shipment_ref      VARCHAR2(50);
l_change_sequence            VARCHAR2(50);
l_source_document_type_id    NUMBER;
l_source_document_id         NUMBER;
l_source_document_line_id    NUMBER;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('*** enter Start_Fulfillment() in OEXWFULB.pls for item type/item key'||ITEMTYPE||'/'||ITEMKEY , 1 ) ;
  END IF;
  OE_STANDARD_WF.Set_Msg_Context(actid);

  if (funcmode = 'RUN') then


	l_line_id  	:= to_number(itemkey);

        SELECT header_id
              ,order_source_id
              ,orig_sys_document_ref
              ,orig_sys_line_ref
              ,orig_sys_shipment_ref
              ,change_sequence
              ,source_document_type_id
              ,source_document_id
              ,source_document_line_id
         INTO l_header_id
              ,l_order_source_id
              ,l_orig_sys_document_ref
              ,l_orig_sys_line_ref
              ,l_orig_sys_shipment_ref
              ,l_change_sequence
              ,l_source_document_type_id
              ,l_source_document_id
              ,l_source_document_line_id
        FROM  oe_order_lines_all
       WHERE  line_id = l_line_id;

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

        OE_Line_Fullfill.G_DEBUG_MSG  := NULL;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add( 'call OE_LINE_FULLFILL.Process_Fulfillment() for line'||TO_CHAR ( L_LINE_ID ) , 2 ) ;
	END IF;
	OE_Line_Fullfill.Process_Fulfillment
			( p_api_version_number	=> 1.0
			, p_line_id      	=> l_line_id
			, p_activity_id		=> actid
			, x_result_out	        => l_result_out
			, x_return_status       => l_return_status
			, x_msg_count	        => l_msg_count
			, x_msg_data	        => l_msg_data
			);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('Returned from oe_line_fullfill.process_fulfillment '||l_return_status , 2 ) ;
	END IF;


    IF l_return_status = 'DEFERRED' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add( 'WF activity deferred') ;
       END IF;
       --resultout := 'DEFERRED:'||to_char(sysdate+0.02, wf_engine.date_format); --bug 4189737
       resultout := 'DEFERRED';
       OE_STANDARD_WF.Clear_Msg_Context;
       return;
    ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	app_exception.raise_exception;
    END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '*** completed fulfillment *** for line '||l_line_id,1);
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


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception

  when others then
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Others exception in OEXWFULB.pls' ) ; -- bug 4189737
      oe_debug_pub.add('Exception is '||sqlerrm,0.5); -- bug 4189737
    END IF;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Fulfill_WF', 'Fulfillment',
                    itemtype, itemkey, to_char(actid), funcmode,
                                           OE_Line_Fullfill.G_DEBUG_MSG);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    -- end data fix project
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    raise;
END Start_Fulfillment;

END OE_Fulfill_WF;

/
