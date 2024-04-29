--------------------------------------------------------
--  DDL for Package Body OE_RLM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RLM_WF" as
/* $Header: OEXWRLMB.pls 120.0 2005/06/01 02:21:33 appldev noship $ */


procedure CHECK_AUTHORIZE_TO_SHIP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out nocopy varchar2 /* file.sql.39 change */
)
is
l_line_id	NUMBER := NULL;
l_header_id	NUMBER := NULL;
l_msg_count	NUMBER := 0;
l_msg_data	VARCHAR2(2000);
l_result_out	VARCHAR2(30);
l_return_status	VARCHAR2(30);
l_wf_item	VARCHAR2(8);
l_wf_activity	VARCHAR2(30);
l_authorized_to_ship_flag    VARCHAR2(1);
l_line_rec                 oe_order_pub.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

   OE_STANDARD_WF.Set_Msg_Context(actid);

   -- Retrieving the order header_id/line_id based on the current
   -- workflow(itemtype)
   IF itemtype = 'OEOL' THEN

    	l_line_id := to_number(itemkey);
        oe_line_util.query_row
           (p_line_id   => l_line_id
           ,x_line_rec  => l_line_rec );

        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_rec.line_id
          ,p_header_id                  => l_line_rec.header_id
          ,p_line_id                    => l_line_rec.line_id
          ,p_order_source_id            => l_line_rec.order_source_id
          ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
          ,p_change_sequence            => l_line_rec.change_sequence
          ,p_source_document_type_id    => l_line_rec.source_document_type_id
          ,p_source_document_id         => l_line_rec.source_document_id
          ,p_source_document_line_id    => l_line_rec.source_document_line_id );

   /* 	SELECT header_id
	INTO l_header_id
      	FROM oe_order_lines
       	WHERE line_id = l_line_id; */

     l_header_id := l_line_rec.header_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADERID:' || TO_CHAR ( L_HEADER_ID ) ) ;
     END IF;

  -- Retrieving internal name and itemtype of the parent process.
  -- XX Do we need this
  /*
	   SELECT PARENT.ACTIVITY_ITEM_TYPE, PARENT.ACTIVITY_NAME
	   INTO l_wf_item, l_wf_activity
	   FROM WF_ITEM_ACTIVITY_STATUSES IAS,
	        WF_PROCESS_ACTIVITIES CHILD,
	        WF_PROCESS_ACTIVITIES PARENT
	   WHERE CHILD.INSTANCE_ID = actid
	   AND CHILD.PROCESS_ITEM_TYPE = PARENT.ACTIVITY_ITEM_TYPE
	   AND CHILD.PROCESS_NAME = PARENT.ACTIVITY_NAME
	   AND PARENT.INSTANCE_ID = IAS.PROCESS_ACTIVITY
	   AND IAS.ITEM_TYPE = itemtype
	   AND IAS.ITEM_KEY = itemkey;
*/
       BEGIN
	   SELECT nvl(AUTHORIZED_TO_SHIP_FLAG, 'Y')
		into l_authorized_to_ship_flag
		FROM oe_order_lines
	    WHERE line_id = l_line_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AUTHORIZED_TO_SHIP_FLAG:'||L_AUTHORIZED_TO_SHIP_FLAG ) ;
       END IF;
	    if l_authorized_to_ship_flag = 'Y' then
            resultout := 'COMPLETE:Y';
	    else
            resultout := 'COMPLETE:N';
         end if;

       EXCEPTION
		WHEN NO_DATA_FOUND THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'NO DATA FOUND FOR AUTHORIZED_TO_SHIP_FLAG' ) ;
		  END IF;
            resultout := 'INCOMPLETE:N';
		  raise program_error;
          WHEN OTHERS THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'ERROR FOR AUTHORIZED_TO_SHIP_FLAG' ) ;
		  END IF;
            resultout := 'INCOMPLETE:N';
		  raise program_error;
       END;


    return;

   END IF; -- end for the itemtype check
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_RLM_WF', 'CHECK_AUTHORIZE_TO_SHIP',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
end CHECK_AUTHORIZE_TO_SHIP;



END OE_RLM_WF;

/
