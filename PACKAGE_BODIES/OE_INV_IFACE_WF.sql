--------------------------------------------------------
--  DDL for Package Body OE_INV_IFACE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INV_IFACE_WF" AS
/* $Header: OEXWIIFB.pls 120.0 2005/06/01 23:12:20 appldev noship $ */
PROCEDURE Inventory_Interface
(   itemtype     IN     VARCHAR2
,   itemkey      IN     VARCHAR2
,   actid        IN     NUMBER
,   funcmode     IN     VARCHAR2
,   resultout    IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS
l_result_out    VARCHAR2(30);
l_return_status VARCHAR2(30);
l_line_id       NUMBER;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  IF (funcmode = 'RUN') THEN

     OE_STANDARD_WF.Set_Msg_Context(actid);

     IF itemtype = OE_GLOBALS.G_WFI_LIN THEN
        l_line_id := to_number(itemkey);
     ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     OE_Inv_Iface_PVT.Inventory_Interface(p_line_id => l_line_id,
                                          x_return_status => l_return_status,
                                          x_result_out => l_result_out);


     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF l_result_out = OE_GLOBALS.G_WFR_COMPLETE THEN
           resultout := OE_GLOBALS.G_WFR_COMPLETE|| ':' ||OE_GLOBALS.G_WFR_COMPLETE;
           OE_STANDARD_WF.Clear_Msg_Context;
           RETURN;
       ELSIF l_result_out = OE_GLOBALS.G_WFR_NOT_ELIGIBLE THEN
           resultout := OE_GLOBALS.G_WFR_COMPLETE ||':' || OE_GLOBALS.G_WFR_NOT_ELIGIBLE ;
           OE_STANDARD_WF.Clear_Msg_Context;
           RETURN;
       END IF;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       IF l_result_out = OE_GLOBALS.G_WFR_INCOMPLETE THEN
          resultout := OE_GLOBALS.G_WFR_COMPLETE || ':' || OE_GLOBALS.G_WFR_INCOMPLETE;
          OE_STANDARD_WF.Save_Messages(p_instance_id => actid);
          OE_STANDARD_WF.Clear_Msg_Context;
          RETURN;
       ELSIF l_result_out = OE_GLOBALS.G_WFR_ON_HOLD THEN
          resultout := OE_GLOBALS.G_WFR_COMPLETE || ':' || OE_GLOBALS.G_WFR_ON_HOLD;
          OE_STANDARD_WF.Save_Messages(p_instance_id => actid);
          OE_STANDARD_WF.Clear_Msg_Context;
          RETURN;
       ELSE -- STS_ERROR but not INCOMPLETE or ON_HOLD
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back. OM does not use CANCEL MODE
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

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_Inv_Iface_WF', 'Inventory_Interface',
		    itemtype, itemkey, to_char(actid), funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages(p_instance_id => actid);
    OE_STANDARD_WF.Clear_Msg_Context;
    RAISE;

END Inventory_Interface;

END  OE_Inv_Iface_WF;

/
