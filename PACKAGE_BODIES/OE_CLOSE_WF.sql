--------------------------------------------------------
--  DDL for Package Body OE_CLOSE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CLOSE_WF" as
/* $Header: OEXWCLOB.pls 120.1 2005/09/27 23:19:17 serla noship $ */

PROCEDURE Close_Order(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_header_id		NUMBER;
l_return_status	VARCHAR2(30);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

	OE_STANDARD_WF.Set_Msg_Context(actid);

	l_header_id	:= to_number(itemkey);

	OE_ORDER_CLOSE_UTIL.Close_Order
			( p_api_version_number	=> 1.0
			, p_header_id			=> l_header_id
			, x_return_status		=> l_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data
			);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		resultout := 'COMPLETE:INCOMPLETE';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		return;
	ELSIF l_return_status = 'H' THEN
		resultout := 'COMPLETE:ON_HOLD';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		return;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                -- start data fix project
		-- OE_STANDARD_WF.Save_Messages;
		-- OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		app_exception.raise_exception;
     END IF;

    	resultout := 'COMPLETE:COMPLETE';
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Close_WF', 'Close_Order',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Close_Order;

PROCEDURE Close_Line(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
l_line_id		NUMBER;
l_return_status	VARCHAR2(30);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

	OE_STANDARD_WF.Set_Msg_Context(actid);

	l_line_id	:= to_number(itemkey);

	OE_ORDER_CLOSE_UTIL.Close_Line
			( p_api_version_number	=> 1.0
			, p_line_id			=> l_line_id
			, x_return_status		=> l_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data
			);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		resultout := 'COMPLETE:INCOMPLETE';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		return;
	ELSIF l_return_status = 'H' THEN
		resultout := 'COMPLETE:ON_HOLD';
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		return;
	ELSIF l_return_status = 'C' THEN
                resultout := OE_GLOBALS.G_WFR_COMPLETE || ':' || OE_GLOBALS.G_WFR_PENDING_ACCEPTANCE;
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		return;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                -- start data fix project
		-- OE_STANDARD_WF.Save_Messages;
		-- OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		app_exception.raise_exception;
     END IF;

    	resultout := 'COMPLETE:COMPLETE';
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
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Close_WF', 'Close_Line',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Close_Line;

END OE_Close_WF;

/
