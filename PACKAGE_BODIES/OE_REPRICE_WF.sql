--------------------------------------------------------
--  DDL for Package Body OE_REPRICE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_REPRICE_WF" as
/* $Header: OEXWREPB.pls 120.0 2005/06/01 23:19:58 appldev noship $ */

PROCEDURE Start_Repricing(
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
BEGIN

  --
  -- RUN mode - normal process execution
  --
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_REPRICE_WF.START_REPRICING '||ITEMTYPE||'/'||ITEMKEY , 1 ) ;
	END IF;
  if (funcmode = 'RUN') then

	OE_STANDARD_WF.Set_Msg_Context(actid);

	l_line_id  	:= to_number(itemkey);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CALLING OE_LINE_REPRICE.PROCESS_REPRICING '||TO_CHAR ( L_LINE_ID ) , 2 ) ;
	END IF;
	OE_Line_Reprice.Process_Repricing
			( p_api_version_number	=> 1.0
			, p_line_id  			=> l_line_id
			, p_activity_id		=> actid
			, x_result_out			=> l_result_out
			, x_return_status		=> l_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data
			);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURNED FROM OE_LINE_REPRICE.PROCESS_REPRICING '||L_RETURN_STATUS , 2 ) ;
	END IF;
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		OE_STANDARD_WF.Save_Messages;
		OE_STANDARD_WF.Clear_Msg_Context;
		-- app_exception.raise_exception;
     END IF;

    	resultout := l_result_out;
--        resultout := 'COMPLETE';
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
    wf_core.context('OE_Reprice_WF', 'Repricing',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Start_Repricing;

PROCEDURE Start_Repricing_Holds(
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
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_REPRICE_WF.START_REPRICING_HOLDS '||ITEMTYPE||'/'||ITEMKEY , 1 ) ;
  END IF;
  if (funcmode = 'RUN') then

        OE_STANDARD_WF.Set_Msg_Context(actid);

    -- check activity specific hold only
    OE_HOLDS_PUB.CHECK_HOLDS(p_api_version => 1.0,
                     p_line_id => to_number(itemkey),
                     p_wf_item => OE_GLOBALS.G_WFI_LIN,
                     p_wf_activity => 'REPRICE_LINE',
                     p_chk_act_hold_only => 'Y',
                     x_result_out => l_result_out,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data);

        IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               OE_STANDARD_WF.Save_Messages;
               OE_STANDARD_WF.Clear_Msg_Context;
               resultout := 'INCOMPLETE';
               RETURN;
        ELSIF (l_result_out = FND_API.G_TRUE ) THEN
           resultout := 'ON_HOLD';
           oe_line_reprice.set_reprice_status('REPRICE_HOLD', to_number(itemkey));
           OE_STANDARD_WF.Clear_Msg_Context;
           RETURN;
         END IF;

    -- call start_repricing to minimize dual maitainance of code
    Start_Repricing(itemtype,
    itemkey,
    actid,
    funcmode,
    resultout);

    IF resultout ='COMPLETE' then
       oe_line_reprice.set_reprice_status('REPRICE_COMPLETE', to_number(itemkey));
    END IF;

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
    wf_core.context('OE_Reprice_WF', 'Start_Repricing_Holds',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Start_Repricing_Holds;

END OE_Reprice_WF;

/
