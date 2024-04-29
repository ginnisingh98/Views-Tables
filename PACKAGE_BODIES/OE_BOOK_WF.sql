--------------------------------------------------------
--  DDL for Package Body OE_BOOK_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BOOK_WF" as
/* $Header: OEXWBOKB.pls 120.0 2005/06/01 00:48:35 appldev noship $ */

PROCEDURE Book_Order(
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
l_booked_flag           VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

        l_header_id	:= to_number(itemkey);

        -- BEGIN: During BULK order import, booking validations and
        -- business logic are executed as a part of the import so order
        -- could be booked prior to the workflow activity. Therefore,
        -- return if order is booked.
        IF OE_BULK_WF_UTIL.G_HEADER_INDEX IS NOT NULL THEN

          l_booked_flag := OE_BULK_ORDER_PVT.G_HEADER_REC.booked_flag
                            (OE_BULK_WF_UTIL.G_HEADER_INDEX);
          IF l_booked_flag = 'Y' THEN
            resultout := 'COMPLETE:COMPLETE';
            RETURN;
          END IF;

        END IF;
        -- END: code for BULK order import

	OE_STANDARD_WF.Set_Msg_Context(actid);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CALL CHECK_BOOKING_HOLDS' ) ;
	END IF;
	OE_ORDER_BOOK_UTIL.Check_Booking_Holds
			( p_header_id			=> l_header_id
			, x_return_status		=> l_return_status
			);

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS FROM CHECK_BOOKING_HOLDS: '||L_RETURN_STATUS ) ;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
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

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CALL BOOK_ORDER' ) ;
	END IF;
	OE_ORDER_BOOK_UTIL.Book_Order
			( p_api_version_number	=> 1.0
			, p_header_id			=> l_header_id
			, x_return_status		=> l_return_status
			, x_msg_count			=> l_msg_count
			, x_msg_data			=> l_msg_data
			);
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RETURN STATUS FROM BOOK_ORDER: '||L_RETURN_STATUS ) ;
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		resultout := 'COMPLETE:INCOMPLETE';
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
    wf_core.context('OE_Order_WF', 'Book_Order',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END Book_Order;

END OE_Book_WF;

/
