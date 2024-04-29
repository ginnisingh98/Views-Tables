--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_WF" as
/* $Header: OEXWCRCB.pls 120.1.12010000.2 2008/10/17 12:09:17 cpati ship $ */


/*--------------------------------------------------------------------------
Called by the workflow activity CREDIT_CHECK, this procedure:
1) Doesn't do a credit check if a previous hold was manually released and
   the order is not being updated.
2) Decides on the credit check rule to use.
3) Calls the mainline procedure in the credit check utility.
----------------------------------------------------------------------------*/

procedure OE_CHECK_AVAILABLE_CREDIT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
is
l_return_status 	VARCHAR2(30);	-- checks the return status of the called procedures
l_msg_count		NUMBER := 0;	-- checks the no. of msgs. from the called procedures
l_msg_data		VARCHAR2(240);	-- stores the msg. data from the called procedures
l_result_out		VARCHAR2(240);	-- PASS/FAIL: result from credit check API
l_header_id             NUMBER;		-- Header Id for the order being processed
l_calling_action	VARCHAR2(30);	-- is the credit check rule Booking/Shipping
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCRWFB: CHECK_AVAILABLE_CREDIT: ITEM TYPE='||ITEMTYPE ) ;
   END IF;

    l_header_id := GetHeaderID(itemtype, itemkey);

/*-------- Check for manual release of holds ------------------------------*/

--  No credit check if a previous credit hold was manually released and if
--  this credit check is NOT due to the order being updated

    IF itemtype in ('OEOH', 'OEOL') THEN
   	IF (CheckManualRelease(l_header_id) = 'Y') THEN
   	   resultout := 'COMPLETE:PASS';
   	   return;
   	END IF;
    END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCRWFB: AFTER CHECK FOR MANUAL RELEASE' ) ;
   END IF;

/*-------- Deciding which credit check rule to use -------------------------*/

	l_calling_action := 	WhichCreditRule(itemtype,
						itemkey,
						actid);

/*-------  Calling the credit check API -----------------------------------*/
    OE_Credit_PUB.Check_Available_Credit
				(  p_header_id => l_header_id
				, p_calling_action => l_calling_action
				, p_msg_count => l_msg_count
				, p_msg_data => l_msg_data
				, p_result_out => l_result_out
				, p_return_status => l_return_status
			      );

--  If the check available credit procedure returns with success we should
--  set the result out for workflow.

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        IF l_result_out = 'FAIL' then
    	  resultout := 'COMPLETE:FAIL';
        ELSE
	  resultout := 'COMPLETE:PASS';
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXCRWFB CHECK AVAILABLE CREDIT , RESULTOUT:' || RESULTOUT ) ;
        END IF;

      ELSE  RAISE PROGRAM_ERROR;

      END IF;

    return;

  end if;

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
  resultout := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_CREDIT_WF', 'OE_CHECK_AVAILABLE_CREDIT',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end OE_CHECK_AVAILABLE_CREDIT;

/*----------------------------------------------------------------------------------
   This Procedure is provided for the scenario of a credit hold already existing
   for a given order.  At deployment time the workflow can be set up to
   not reapply a credit hold if one has already been placed based on the outcome
   of this procedure.
-----------------------------------------------------------------------------------*/
procedure OE_CHECK_FOR_HOLDS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
is
l_hold_exists	VARCHAR2(1);  -- Y/N depending on whether the hold exists or not
l_hold_count	NUMBER;      -- Number of credit holds on this order...should be 1 at any time
l_released 	VARCHAR2(1);  -- Y/N depending on whether the hold exists or not
l_header_id     NUMBER;
l_return_status 	VARCHAR2(30);	    -- checks the return status of the called procedures
l_msg_count		NUMBER := 0;	    -- checks the no. of msgs. from the called procedures
l_msg_data		VARCHAR2(240);      -- stores the msg. data from the called procedures
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN CHECK FOR HOLDS , OEXCRWFB WITH ITEMTYPE:'||ITEMTYPE ) ;
    END IF;

    l_header_id := GetHeaderID(itemtype, itemkey);

       BEGIN

      --  Getting the number of credit failure holds on this order
   	     SELECT count(*)
             INTO l_hold_count
             FROM OE_ORDER_HOLDS H, OE_HOLD_SOURCES S
             WHERE H.HEADER_ID = l_header_id
           --  AND H.LINE_ID IS NULL
             AND H.HOLD_RELEASE_ID IS NULL
             AND H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
             AND S.HOLD_ID = 1
             AND S.HOLD_ENTITY_CODE = 'O'
             AND S.HOLD_ENTITY_ID = l_header_id
             AND S.RELEASED_FLAG = 'N';

    	 -- if number of rows retrieved > 0, then hold exists
	   if l_hold_count > 0 then
	      l_hold_exists := 'Y';
	   else
	      l_hold_exists := 'N';
	   end if;

      EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_hold_exists := 'N';
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'NO DATA FOUND IN CHECK FOR HOLDS' ) ;
               END IF;
      END;

	    -- Setting the result for the workflow
   	 IF l_hold_exists = 'Y' then
    		resultout := 'COMPLETE:Y';
  	  ELSE
		resultout := 'COMPLETE:N';
  	  END IF;


    return;

  end if;

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
  resultout := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_CREDIT_WF', 'OE_CHECK_FOR_HOLDS',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end OE_CHECK_FOR_HOLDS;

/*---------------------------------------------------------------------
  Based on the results of the OE_CHECK_AVAILABLE_CREDIT procedure the
  workflow may be set to apply a credit hold.
----------------------------------------------------------------------*/
procedure OE_APPLY_CREDIT_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
is
l_order_number	NUMBER;
l_return_status VARCHAR2(30);
l_msg_count	NUMBER := 0;
l_msg_data	VARCHAR2(240);
l_header_id     NUMBER;
l_hold_source_rec	OE_Hold_Sources_Pvt.Hold_Source_REC :=
			OE_Hold_Sources_Pvt.G_MISS_Hold_Source_REC;
			--
			l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
			--
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

-- Apply Credit hold using public hold API.


  if (funcmode = 'RUN') then

	l_header_id := 	GetHeaderID( itemtype, itemkey);

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'APPLYING CREDIT HOLD TO HEADER:' || L_HEADER_ID ) ;
         END IF;

/*--------------------------- Applying credit hold ----------------------------------*/
 l_hold_source_rec.hold_id := 1; 	-- Credit Failure Hold
 l_hold_source_rec.hold_entity_code := 'O'; -- Order Hold
 l_hold_source_rec.hold_entity_id := l_header_id; -- Order Header


 OE_Holds_PUB.Apply_Holds
                (   p_api_version       =>      1.0
                ,   p_header_id         =>      l_header_id
                ,   p_hold_source_rec   => 	l_hold_source_rec
                ,   x_return_status     =>      l_return_status
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                );

/*
	 OE_Holds_PUB.Apply_Holds
		(   p_header_id		=>	l_header_id
		,   p_hold_id		=>	1 		-- Credit Failure Hold
		,   p_entity_code	=>	'O'		-- Order Hold
		,   p_entity_id		=>	l_header_id  	-- Order Header id
		,   x_return_status	=>	l_return_status
		,   x_msg_count 	=> 	l_msg_count
		,   x_msg_data		=> 	l_msg_data
		,   p_api_version       =>      1.0
		);
*/

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'APPLIED CREDIT HOLD TO HEADER:' || L_HEADER_ID ) ;
        END IF;

        if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise PROGRAM_ERROR;
        end if;

-- Next set the Workflow Item Attributes to put meaningful information
-- in the message when notifying the credit manager.
    SELECT 	ORDER_NUMBER
    INTO	l_order_number
    FROM	OE_ORDER_HEADERS
    WHERE	header_id = l_header_id;

    wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ORDER_NUMBER', l_order_number);

 -- Set workflow activity completion result
       resultout := 'COMPLETE:Null';

    return;

  end if;


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
  resultout := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_CREDIT_WF', 'OE_APPLY_CREDIT_HOLD',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end OE_APPLY_CREDIT_HOLD;

/*-----------------------------------------------------
 This procedure is a workflow wrapper to the Public
 release hold API in OE_HOLDS_PUB.  It is provided
 here so that when the credit manager responds to
 his notification that a credit review is required
 for a customer whose order has gone on credit hold,
 we can automate the removal of the hold if the
 customer passes credit review.
-------------------------------------------------------*/
procedure OE_RELEASE_CREDIT_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
is
--ER#7479609 l_hold_entity_id	NUMBER;
l_hold_entity_id	oe_hold_sources_all.hold_entity_id%TYPE;  --ER#7479609
l_hold_count		NUMBER;
l_return_status		VARCHAR2(30);
l_msg_count		NUMBER := 0;
l_msg_data		VARCHAR2(240);
l_release_reason	VARCHAR2(30);
l_hold_release_rec	OE_Hold_Sources_Pvt.Hold_Release_REC :=
			OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;
Cursor blocked_process IS
        SELECT wfas.item_type, wfas.item_key, wpa.activity_name, wfas.activity_status
  	FROM wf_item_activity_statuses wfas, wf_process_activities wpa
  	WHERE wpa.activity_name IN ('OE_CREDIT_HOLD_NTF','OE_HOLD_BLOCK','WAIT_FOR_NTF_RESULT')
              AND wfas.process_activity = wpa.instance_id
  		AND wfas.activity_status = 'NOTIFIED'
 	         AND wfas.item_type = 'OEOH'
                 AND wpa.activity_item_type = 'OEOH'
                 and wfas.item_key = to_char(l_hold_entity_id)
         UNION
        SELECT wfas.item_type, wfas.item_key, wpa.activity_name, wfas.activity_status
  	FROM wf_item_activity_statuses wfas, wf_process_activities wpa
  	WHERE wpa.activity_name IN ('OE_CREDIT_HOLD_NTF','OE_HOLD_BLOCK','WAIT_FOR_NTF_RESULT')
              AND wfas.process_activity = wpa.instance_id
  		AND wfas.activity_status = 'NOTIFIED'
                 AND wpa.activity_item_type = 'OEOL'
 	         AND  wfas.item_type = 'OEOL' and wfas.item_key
                          in (select line_id
                              from oe_order_lines_all L
                              where L.header_id = l_hold_entity_id);
				   --
                       --OR (item_type = 'OECHGORD' and item_key
                       --   in (select to_char(P.wf_key_id)
                       --       from oe_line_pending_actions P
                       --       where P.header_id = l_hold_entity_id)));
                       --
                       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                       --
begin
   -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'IN RELEASE HOLDS , OEXCRWFB WITH ITEMTYPE:'||ITEMTYPE ) ;
   END IF;

	  l_hold_entity_id := 	GetHeaderID(itemtype, itemkey);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING HOLDS FOR HEADER ID:' || L_HOLD_ENTITY_ID ) ;
   END IF;

/*-------------------- Checking if the hold still exists -------------------*/

             SELECT count(*)
             INTO l_hold_count
             FROM OE_ORDER_HOLDS H, OE_HOLD_SOURCES S
             WHERE H.HEADER_ID = l_hold_entity_id
           --  AND H.LINE_ID IS NULL
             AND H.HOLD_RELEASE_ID IS NULL
             AND H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
             AND S.HOLD_ID = 1
             AND S.HOLD_ENTITY_CODE = 'O'
             AND S.HOLD_ENTITY_ID = l_hold_entity_id
             AND S.RELEASED_FLAG = 'N';


    IF l_hold_count > 0 THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RELEASING ORDER WITH HEADER ID:' || L_HOLD_ENTITY_ID ) ;
     END IF;

/*-------------------- Releasing credit hold -------------------------------*/
 l_hold_release_rec.release_reason_code := 'PASS_CREDIT';
 OE_Holds_PUB.Release_Holds
                (   p_api_version       =>      1.0
                ,   p_hold_id		=> 	1
                ,   p_entity_code	=>      'O'
                ,   p_entity_id		=> 	l_hold_entity_id
                ,   p_header_id		=>      l_hold_entity_id
                ,   p_hold_release_rec   => 	l_hold_release_rec
                ,   x_return_status     =>      l_return_status
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                );

/*
	  OE_Holds_PUB.RELEASE_HOLDS
				(   p_entity_id		=>	l_hold_entity_id
				,   p_hold_id		=>	1    	-- Credit hold ID
				,   p_reason_code	=>	'PASS_CREDIT'
				,   p_entity_code	=>	'O'  	-- Order Entity
				,   x_result_out	=>	resultout
				,   x_return_status	=>	l_return_status
				,   x_msg_count 	=> 	l_msg_count
				,   x_msg_data		=> 	l_msg_data
				,   p_api_version       =>      1.0
				);
*/

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           raise PROGRAM_ERROR;
        end if;

-- Check for all the workflows (header/line/change order) that may be held up due
-- to this hold and complete them to loop back to the check for holds function

      FOR curr_block_process IN blocked_process LOOP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'REL. HOLDS COMPLETE_ACT WITH ITEMTYPE:'||ITEMTYPE||' AND ITEMKEY:'||ITEMKEY ) ;
          END IF;

       -- Completing all blocked check for hold processes for this order

         IF curr_block_process.activity_name = 'OE_HOLD_BLOCK' THEN

           WF_ENGINE.CompleteActivity( curr_block_process.item_type
                                      , curr_block_process.item_key
                                      , curr_block_process.activity_name
                                      , NULL
                                      );

       -- Completing all waiting credit check processes

         ELSE

           WF_ENGINE.CompleteActivity( curr_block_process.item_type
                                      , curr_block_process.item_key
                                      , curr_block_process.activity_name
                                      , 'APPROVED'
                                      );

         END IF;

      END LOOP;

   END IF;  -- Do nothing if the hold has already been released.

      -- setting the resultout for workflow
       resultout := 'COMPLETE:Null';

    return;

  end if;


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
  resultout := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_CREDIT_WF', 'OE_RELEASE_CREDIT_HOLD',
		    itemtype, itemkey, to_char(actid), funcmode);
     -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end OE_RELEASE_CREDIT_HOLD;


/*-------------------------------------------------------------------
	When the order is being updated and the credit has to be
	re-evaluated, this process suspends the previous credit hold
	notifications (if any).
---------------------------------------------------------------------*/
procedure OE_WAIT_HOLD_NTF(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2)
is
l_header_id              NUMBER;
l_return_status          VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_order_number           NUMBER;
Cursor ntf_process_data IS
        SELECT wfas.item_type, wfas.item_key
  	FROM   wf_item_activity_statuses wfas, wf_process_activities wpa
  	WHERE  wfas.item_type='OEOH'
               AND wfas.process_activity = wpa.instance_id
               AND wpa.activity_item_type='OEOH'
               AND  wpa.activity_name = 'OE_CREDIT_HOLD_NTF'
  		AND wfas.activity_status = 'NOTIFIED'
 	        AND wfas.item_key = to_char(l_header_id)
        UNION
         SELECT wfas.item_type, wfas.item_key
  	FROM   wf_item_activity_statuses wfas
               , wf_process_activities wpa
               , oe_order_lines_all ol
  	WHERE  wfas.item_type='OEOL'
               AND wfas.process_activity = wpa.instance_id
               AND wpa.activity_item_type='OEOL'
               AND  wpa.activity_name = 'OE_CREDIT_HOLD_NTF'
  		AND wfas.activity_status = 'NOTIFIED'
 	        AND wfas.item_key  = ol.line_id
                AND ol.header_id = l_header_id;

                       -- Not need anymore
                       --OR (item_type = 'OECHGORD' and item_key
                       --     IN (select to_char(P.wf_key_id)
                       --         from oe_line_pending_actions P
                       --         where P.header_id = l_header_id)));
                       --
                       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                       --
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  if (funcmode = 'RUN') then

	l_header_id := GetHeaderId( itemtype, itemkey);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN THE WAIT_HOLD_NTF PROCEDURE' ) ;
       END IF;

       FOR current_ntf_data IN ntf_process_data LOOP

          WF_ENGINE.CompleteActivity(current_ntf_data.item_type
                                      , current_ntf_data.item_key
                                      , 'OE_CREDIT_HOLD_NTF'
                                      , 'WAIT'
                                      );

        END LOOP;

--  The workflow calling this procedure doesn't go through the apply
--  holds procedure as there is a credit hold already existing. However,
--  new notifications are sent and hence, the need to populate the
--  item attributes.

   	 SELECT ORDER_NUMBER
   	 INTO	l_order_number
   	 FROM	OE_ORDER_HEADERS
   	 WHERE	header_id = l_header_id;

         wf_engine.SetItemAttrNumber(itemtype, itemkey, 'ORDER_NUMBER', l_order_number);

    resultout := 'COMPLETE:Null';
    return;

  end if;

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
  resultout := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_CREDIT_WF', 'OE_WAIT_HOLD_NTF',
		    itemtype, itemkey, to_char(actid), funcmode);
     -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end OE_WAIT_HOLD_NTF;

/*--------------------------------------------------------------------
	New BLOCK activity defined so that this activity cannot be
	completed by the end-user through 'Progress Order'.
	To be re-visited.
----------------------------------------------------------------------*/
procedure CREDIT_BLOCK(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
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
    Wf_Core.Context('OE_CREDIT_WF', 'CREDIT_BLOCK', itemtype,
                    itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

end CREDIT_BLOCK;

/*-----------------------------------------------------------------------
	GetHeaderId retrieves the order header id based on the
	current workflow(itemtype)
------------------------------------------------------------------------*/
function GetHeaderID(itemtype   in varchar2,
               	     itemkey    in varchar2
               		)
return NUMBER
is
l_header_id	NUMBER;
-- Retrieves header id if it's a Line workflow
CURSOR line_header IS
       SELECT header_id
       FROM oe_order_lines
       WHERE line_id = to_number(itemkey);
-- Retrieves header id if it's a Change Order workflow
-- Not used anymore
--CURSOR pending_rec_header IS
--       SELECT header_id
--       FROM oe_line_pending_actions
--       WHERE wf_key_id = to_number(itemkey);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

-- Retrieving the order header id based on the current workflow(itemtype)
      IF itemtype = 'OEOH' THEN

           l_header_id := to_number(itemkey);

      ELSIF itemtype = 'OEOL' THEN

        OPEN line_header;
        FETCH line_header INTO l_header_id;
        CLOSE line_header;

      -- Not used anymore.
      --ELSIF itemtype='OECHGORD' THEN
      --
      --   OPEN pending_rec_header;
      --   FETCH pending_rec_header INTO l_header_id;
      --   CLOSE pending_rec_header;

      END IF;

      return(l_header_id);

end GetHeaderID;

/*-------------------------------------------------------------------
	Returns 'Y' if the last credit hold was manually released
	else returns 'N'.
---------------------------------------------------------------------*/
function CheckManualRelease(header_id in number)
return 	VARCHAR2
is
l_manual_release	NUMBER := 0;	-- no. of times credit hold was manually released
l_hold_release_id	NUMBER := 0;	-- release ID for the last credit hold
CURSOR released_hold IS
      SELECT NVL(MAX(H.HOLD_RELEASE_ID),0)
      FROM OE_ORDER_HOLDS H, OE_HOLD_SOURCES S
      WHERE H.HEADER_ID = header_id
      AND H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
      AND H.HOLD_RELEASE_ID IS NOT NULL
      AND S.HOLD_ID = 1
      AND S.HOLD_ENTITY_CODE = 'O'
      AND S.HOLD_ENTITY_ID = header_id
      AND S.RELEASED_FLAG ='Y';
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
begin


 -- Retrieve the hold release ID of the last released credit hold
 -- for this order
        OPEN released_hold;
        IF (released_hold%found) THEN
   	  FETCH released_hold INTO l_hold_release_id;
   	END IF;
   	CLOSE released_hold;

    IF l_hold_release_id > 0 THEN

           SELECT count(*)
           INTO l_manual_release
           FROM OE_HOLD_RELEASES
           WHERE HOLD_RELEASE_ID = l_hold_release_id
           AND RELEASE_REASON_CODE <> 'PASS_CREDIT'
           AND CREATED_BY <> 1;

	 IF l_manual_release > 0 THEN
           return('Y');
         ELSE
           return('N');
         END IF;

    ELSE

        return('N');

    END IF;

end CheckManualRelease;

/*-------------------------------------------------------------------
	Returns 'BOOKING' if the credit rule to be used is the
	booking rule and returns 'SHIPPING' for the shipping rule.
---------------------------------------------------------------------*/
function WhichCreditRule(itemtype in varchar2,
			 itemkey in varchar2,
			 actid in number)
return VARCHAR2
is
l_header_id		NUMBER;
l_calling_action	VARCHAR2(30);	-- is the credit check rule Booking/Shipping
l_pick_rel_count 	NUMBER;		-- has pick release been done for at least one order line?
l_next_pick_rel		NUMBER;		-- is the next activity = pick release?
l_fromact_id		NUMBER;		-- activity instance id of the parent process
-- Gets the number of order lines that have gone through pick release
CURSOR pick_rel IS
       SELECT count(*)
       FROM wf_item_activity_statuses wfas, wf_process_activities wpa
       WHERE  wfas.item_type = 'OEOL'
          AND wfas.process_activity = wpa.instance_id
          AND wpa.activity_item_type = 'OEOL'
          AND wfas.item_key IN ( SELECT line_id
      			FROM  oe_order_lines_all
      			WHERE header_id = l_header_id)
          AND wpa.activity_name = 'PICK_RELEASE';
-- Checks if the next activity is pick release
CURSOR next_pick_rel IS
	SELECT count(*)
	FROM   wf_activity_transitions atr
	WHERE  atr.from_process_activity = l_fromact_id
	AND    result_code = 'APPROVED'
	AND    to_process_activity IN
                (SELECT pa.instance_id
 		 FROM wf_process_activities pa
 		 WHERE pa.activity_name = 'PICK_RELEASE'
                   AND pa.activity_item_type = itemtype);
                   --
                   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                   --
begin

   l_header_id := GetHeaderID(itemtype, itemkey);

-- Setting the credit check rule to the 'booking rule' initially
   l_calling_action := 'BOOKING';

-- Checking if there exists a line WF corresponding to this header that has
-- gone till the activity of PICK RELEASE

   OPEN pick_rel;
   FETCH pick_rel INTO l_pick_rel_count;
   CLOSE pick_rel;

-- If any order line has gone till pick_release, use the 'shipping' rule
-- for credit check

   IF l_pick_rel_count > 0 then
      l_calling_action := 'SHIPPING';
   END IF;


   IF itemtype = 'OEOL' and l_calling_action = 'BOOKING' THEN

	--  Retrieving the instance id for the credit checking process (NOT activity)
	--  This assumes that this activity will always be called from within
	--  the credit check process.

   	  l_fromact_id := wf_engine_util.activity_parent_process(itemtype
							,itemkey
   							,actid);

	--  check if the next activity after credit check PROCESS is
	--  pick release

    	 OPEN next_pick_rel;
    	 FETCH next_pick_rel INTO l_next_pick_rel;
    	 CLOSE next_pick_rel;

	-- If the next activity is pick release, use the 'shipping' rule

    	 IF l_next_pick_rel > 0 then
       		l_calling_action := 'SHIPPING';
    	 END IF;

   END IF;

   return(l_calling_action);

end WhichCreditRule;

end OE_CREDIT_WF;

/
