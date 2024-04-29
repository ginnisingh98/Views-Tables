--------------------------------------------------------
--  DDL for Package Body OE_HOLDS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HOLDS_WF" as
/* $Header: OEXWHLDB.pls 120.0 2005/05/31 23:08:06 appldev noship $ */

procedure APPLY_HOLDS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
is
l_line_id		NUMBER;
l_header_id		NUMBER;
l_hold_id		NUMBER;
l_reason_code		VARCHAR2(30);
l_entity_code		NUMBER;
l_entity_id		NUMBER;
l_comment		VARCHAR2(30);
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

   null;

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
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Holds_WF', 'APPLY_HOLDS',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
end APPLY_HOLDS;

procedure CHECK_HOLDS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
is
l_line_id	NUMBER := NULL;
l_header_id	NUMBER := NULL;
l_msg_count	NUMBER := 0;
l_msg_data	VARCHAR2(2000);
l_result_out	VARCHAR2(30);
l_return_status	VARCHAR2(30);
l_wf_item	VARCHAR2(8);
l_wf_activity	VARCHAR2(30);
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

-- Retrieving the order header_id/line_id based on the current
-- workflow(itemtype)
   IF itemtype = 'OEOH' THEN

      l_header_id := to_number(itemkey);

   ELSIF itemtype = 'OEOL' THEN

     	l_line_id := to_number(itemkey);
 	SELECT header_id
	INTO l_header_id
      	FROM oe_order_lines
       	WHERE line_id = to_number(itemkey);

   -- Not needed anymore.
   --ELSIF itemtype='OECHGORD' THEN
   --
   -- 	SELECT header_id, line_id
   -- 	INTO l_header_id, l_line_id
   -- 	FROM oe_line_pending_actions
   -- 	WHERE wf_key_id = to_number(itemkey);
  --
  --      IF l_header_id IS NULL then
  --          SELECT header_id
  --     	    INTO l_header_id
  --          FROM oe_order_lines
  --          WHERE line_id = l_line_id;
  --      END IF;

   END IF; -- end for the itemtype check


  -- Retrieving internal name and itemtype of the parent process.

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


     OE_Holds_PUB.Check_Holds
        (   p_api_version	=> 1.0
        ,   p_init_msg_list	=> FND_API.G_FALSE
        ,   p_commit		=> FND_API.G_FALSE
        ,   p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
        ,   x_return_status	=> l_return_status
        ,   x_msg_count		=> l_msg_count
        ,   x_msg_data		=> l_msg_data
        ,   p_header_id		=> l_header_id
        ,   p_line_id		=> l_line_id
        ,   p_wf_item		=> l_wf_item
	,   p_wf_activity	=> l_wf_activity
        ,   x_result_out 	=> l_result_out
        );


    if l_return_status = FND_API.G_RET_STS_SUCCESS then

      if l_result_out = FND_API.G_TRUE then
         resultout := 'NOTIFIED:HOLDS EXIST';
      elsif l_result_out = FND_API.G_FALSE then
         resultout := 'COMPLETE:NO_HOLDS';
      end if;

    else
      raise program_error;

    end if;

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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Holds_WF', 'CHECK_HOLDS',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
end CHECK_HOLDS;


procedure RELEASE_HOLDS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
is
l_line_id		NUMBER;
l_header_id		NUMBER;
l_hold_id		NUMBER;
l_hold_source_id	NUMBER;
l_reason_code	VARCHAR2(30);
l_entity_code	NUMBER;
l_entity_id		NUMBER;
l_comment		VARCHAR2(30);
l_return_status	VARCHAR2(240);
begin
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

   null;

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
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Holds_WF', 'RELEASE_HOLDS',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
end RELEASE_HOLDS;

END OE_Holds_WF;

/
