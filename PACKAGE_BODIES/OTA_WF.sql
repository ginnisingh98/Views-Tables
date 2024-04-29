--------------------------------------------------------
--  DDL for Package Body OTA_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_WF" as
/* $Header: ottomiwf.pkb 120.1.12000000.2 2007/10/17 08:34:45 smahanka noship $ */
g_package  varchar2(33)	:= '  ota_wf.';  -- Global package name

-- ----------------------------------------------------------------------------
-- |---------------------------------< CANCEL_ORDER >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CANCEL_ORDER (
itemtype 	IN	VARCHAR2
,itemkey 	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2

)
IS
l_proc 	varchar2(72) := g_package||'cancel_order';

l_Line_id  oe_order_lines.Line_Id%type;
l_header_id oe_order_lines.header_id%type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type:=
					OE_GLOBALS.G_MISS_CONTROL_REC;

--Declare all local variable.
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
x_header_rec            OE_Order_PUB.Header_Rec_Type; --added for bug 6347596
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl                      OE_Order_PUB.Line_Tbl_Type; --added for bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);

l_org_id 				oe_order_lines.org_id%type;
BEGIN

hr_utility.set_location('Entering:'||l_proc, 5);

IF (funcmode = 'RUN') THEN

	l_header_id := WF_ENGINE.getitemattrnumber(
		itemtype  =>  itemtype,
		itemkey =>  itemkey,
		aname => 'HEADER_ID');
	l_org_id := WF_ENGINE.getitemattrnumber(
		itemtype  =>  itemtype,
		itemkey =>  itemkey,
		aname => 'ORG_ID');
    MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support
--fnd_client_info.set_org_context(context => to_char(l_org_id)); -- No needed

	l_header_rec.header_id :=  l_header_id;
	l_line_rec. operation := 'UPDATE';
	l_line_rec.ordered_quantity := 0;
	l_line_rec.line_id := to_number(itemkey);
	l_line_tbl(1) := l_line_rec;

 	OE_Order_GRP.Process_Order
	(   p_api_version_number      => 1.0
	,   p_init_msg_list           => FND_API.G_FALSE
	,   p_return_values      	=> l_return_values
	,   p_commit                  => FND_API.G_FALSE
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_return_status      	=> l_return_status
	,   x_msg_count          	=> l_msg_count
	,   x_msg_data           	=>  l_msg_data
	,   p_header_rec         	=> l_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   p_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   p_Header_Scredit_tbl      => l_header_scredit_tbl
	,   p_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_Lot_Serial_tbl          => l_lot_serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_Action_Request_tbl      => l_request_tbl
	,   x_header_rec              => x_header_rec    --modified for bug 6347596
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl     --modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       	=> l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   	=> l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl 	=> l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     	=> l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl 	=> l_action_request_tbl
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	   ota_om_upd_api.retrieve_oe_messages(l_message_data);
          RAISE FND_API.G_EXC_ERROR;

 	END IF;
    resultout := 'COMPLETE';
    return;

END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'cancel_order',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;

-- ----------------------------------------------------------------------------
-- |---------------------------------< CREATE_RMA >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  CREATE_RMA (
itemtype 	IN	VARCHAR2
,itemkey 	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2

)IS
l_proc 	varchar2(72) := g_package||'create_rma';

l_Line_id  oe_order_lines.Line_Id%type;
l_header_id oe_order_lines.header_id%type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type ;

--Declare all local variable.
 l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
x_header_rec            OE_Order_PUB.Header_Rec_Type;  --added for bug 6347596
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl                      OE_Order_PUB.Line_Tbl_Type;  --added for bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);
l_org_id 				oe_order_lines.org_id%type;


BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

 IF (funcmode = 'RUN') THEN

	l_header_id := WF_ENGINE.getitemattrnumber(
	itemtype  =>  itemtype,
	itemkey   =>  itemkey,
	aname => 'HEADER_ID');


	l_org_id := WF_ENGINE.getitemattrnumber(
		itemtype  =>  itemtype,
		itemkey =>  itemkey,
		aname => 'ORG_ID');

MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support

	l_header_rec.header_id :=  l_header_id;
	l_line_rec. operation := 'INSERT';
	l_line_rec.reference_Line_id := to_number(itemkey);
	l_line_rec.reference_header_id := l_header_id;
	l_line_rec.line_category_code  := 'RETURN';
	l_line_rec.ordered_quantity := -1;
	l_line_tbl(1) := l_line_rec;

--fnd_client_info.set_org_context(context => to_char(l_org_id));

 	OE_Order_GRP.Process_Order
	(   p_api_version_number      =>  l_api_version_number
	,   p_init_msg_list           => FND_API.G_FALSE
	,   p_return_values      	=> l_return_values
	,   p_commit                  => FND_API.G_FALSE
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_return_status      	=> l_return_status
	,   x_msg_count          	=> l_msg_count
	,   x_msg_data           	=> l_msg_data
	,   p_header_rec         	=> l_header_rec
	,   p_old_header_rec          => l_old_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_old_header_val_rec      => l_old_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_old_Header_Adj_tbl	=> l_old_Header_Adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_old_Header_Adj_val_tbl  => l_old_Header_Adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl
	,   p_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   p_old_Header_Adj_Att_tbl  => l_old_Header_Adj_Att_tbl
	,   p_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl
	,   p_Header_Scredit_tbl      => l_header_scredit_tbl
	,   p_old_Header_Scredit_tbl  => l_old_Header_Scredit_tbl
	,   p_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   p_old_Header_Scredit_val_tbl => l_old_Header_Scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_old_line_tbl 		=> l_old_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_old_line_val_tbl 		=> l_old_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_old_Line_Adj_tbl    	=> l_old_Line_Adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_old_Line_Adj_val_tbl	=> l_old_Line_Adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_old_Line_Price_Att_tbl  => l_old_Line_Price_Att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_old_Line_Adj_Att_tbl	=> l_old_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_old_Line_Adj_Assoc_tbl  => l_old_Line_Adj_Assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_old_Line_Scredit_tbl	=> l_old_Line_Scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_old_Line_Scredit_val_tbl  => l_old_Line_Scredit_val_tbl
	,   p_Lot_Serial_tbl          => l_lot_serial_tbl
	,   p_old_Lot_Serial_tbl	=> l_old_Lot_Serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_old_Lot_Serial_val_tbl  => l_old_Lot_Serial_val_tbl
	,   p_Action_Request_tbl      => l_request_tbl
	,   x_header_rec              => x_header_rec    --modified for bug 6347596
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl      --modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       	=> l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   	=> l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl 	=> l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     	=> l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl 	=> l_action_request_tbl
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
 	   ota_om_upd_api.retrieve_oe_messages(l_message_data);
        RAISE FND_API.G_EXC_ERROR;

 	END IF;
    resultout := 'COMPLETE';

    return;

END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'create_rma',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;


-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_FULFILL_DATE >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE  UPDATE_FULFILL_DATE (
itemtype	IN	VARCHAR2
,itemkey	IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout   OUT NOCOPY VARCHAR2

) Is
l_proc 	varchar2(72) := g_package||'update_fulfill_date';
l_header_id oe_order_lines.header_id%type;

l_Line_id 		OE_ORDER_LINES.line_id%type := to_number(itemkey) ;
l_control_rec                 OE_GLOBALS.Control_Rec_Type:=
					OE_GLOBALS.G_MISS_CONTROL_REC;


l_api_version_number          CONSTANT NUMBER := 1.0;
 l_return_values               varchar2(50);
l_return_status		VARCHAR2(1) ;
l_msg_count			NUMBER;
l_msg_data			VARCHAR2(2000);
l_header_rec		OE_Order_PUB.Header_Rec_Type;
l_header_val_rec		OE_Order_PUB.Header_Val_Rec_Type;
l_header_adj_tbl		OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_adj_val_tbl	OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_header_price_att_tbl	OE_Order_PUB.header_Price_Att_Tbl_Type;
l_header_adj_att_tbl	OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_header_adj_assoc_tbl	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_header_scredit_tbl	OE_Order_PUB.Header_Scredit_Tbl_Type;
l_header_scredit_val_tbl	OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_line_tbl			OE_Order_PUB.Line_Tbl_Type;
x_line_tbl			OE_Order_PUB.Line_Tbl_Type;    --added for bug 6347596
l_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_adj_val_tbl	OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_price_att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl	OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_line_adj_assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_line_scredit_tbl	OE_Order_PUB.Line_Scredit_Tbl_Type;
l_line_scredit_val_tbl	OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_tbl		OE_Order_PUB.Lot_Serial_Tbl_Type;
l_lot_serial_val_tbl	OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_action_request_tbl	OE_Order_PUB.Request_Tbl_Type ;

l_line_rec			OE_ORDER_PUB.LINE_REC_TYPE;
l_request_tbl           OE_Order_PUB.Request_Tbl_Type :=
					OE_Order_PUB.G_MISS_REQUEST_TBL;

l_old_header_rec			OE_Order_PUB.Header_Rec_Type ;
l_old_header_val_rec     	OE_Order_PUB.Header_Val_Rec_Type ;
l_old_Header_Adj_tbl     	OE_Order_PUB.Header_Adj_Tbl_Type ;
l_old_Header_Adj_val_tbl 	OE_Order_PUB.Header_Adj_Val_Tbl_Type ;
l_old_Header_Price_Att_tbl  	OE_Order_PUB.Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl    	OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl  	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl    	OE_Order_PUB.Header_Scredit_Tbl_Type ;
l_old_Header_Scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type ;
l_old_line_tbl			OE_Order_PUB.Line_Tbl_Type ;
l_old_line_val_tbl		OE_Order_PUB.Line_Val_Tbl_Type ;
l_old_Line_Adj_tbl		OE_Order_PUB.Line_Adj_Tbl_Type ;
l_old_Line_Adj_val_tbl		OE_Order_PUB.Line_Adj_Val_Tbl_Type ;
l_old_Line_Price_Att_tbl	OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl 		OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl		OE_Order_PUB.Line_Scredit_Tbl_Type ;
l_old_Line_Scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type ;
l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type ;
l_old_Lot_Serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type ;

l_message_data 	varchar2(2000);
l_org_id 				oe_order_lines.org_id%type;


CURSOR C_EVENT
IS
SELECT Course_End_date
FROM  OTA_EVENTS
WHERE LINE_ID = l_line_id;
Line_id 		OE_ORDER_LINES.line_id%type;
l_course_end_date	OTA_EVENTS.course_end_date%type;

CURSOR C_ORDER IS
SELECT HEADER_ID,ORG_ID
FROM OE_ORDER_LINES_ALL
WHERE LINE_ID = l_line_id;

BEGIN
hr_utility.set_location('Entering:'||l_proc, 5);

IF (funcmode = 'RUN') THEN
   OPEN C_ORDER;
   FETCH C_ORDER INTO l_header_id,l_org_id;
   CLOSE C_ORDER;

   OPEN C_EVENT;
   FETCH C_EVENT INTO l_course_end_date;
   IF C_EVENT%found THEN

      /*l_header_id := WF_ENGINE.getitemattrnumber(
	    itemtype  =>  itemtype,
	    itemkey   =>  itemkey,
	     aname => 'HEADER_ID'); */


	/*l_org_id := WF_ENGINE.getitemattrnumber(
		itemtype  =>  itemtype,
		itemkey =>  itemkey,
		aname => 'ORG_ID'); */
      MO_GLOBAL.SET_POLICY_CONTEXT ('S', l_org_id);  -- For MOAC support
    --l_header_rec.header_id :=  l_header_id;
      l_line_rec. operation := 'UPDATE';
      l_line_rec.fulfillment_date  := l_course_end_date ;
      l_line_rec.line_id := l_line_id;
      l_line_tbl(1) := l_line_rec;

--fnd_client_info.set_org_context(context => to_char(l_org_id));

      OE_Order_GRP.Process_Order
     	(   p_api_version_number        => 1.0
     	,   p_init_msg_list             => FND_API.G_FALSE
	,   p_return_values      => l_return_values
	,   p_commit                   => FND_API.G_FALSE
	,   x_return_status      => l_return_status
	,   p_validation_level        => FND_API.G_VALID_LEVEL_FULL
	,   p_control_rec             => l_control_rec
	,   p_api_service_level       =>  OE_GLOBALS.G_ALL_SERVICE
	,   x_msg_count          => l_msg_count
	,   x_msg_data           =>  l_msg_data
	,   p_header_rec         => l_header_rec
	,   p_header_val_rec          => l_header_val_rec
	,   p_Header_Adj_tbl          => l_header_adj_tbl
	,   p_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   p_Header_price_Att_tbl    => l_header_price_att_tbl
	,   p_Header_Adj_Att_tbl           => l_header_adj_att_tbl
	,   p_Header_Adj_Assoc_tbl         => l_header_adj_assoc_tbl
	,   p_Header_Scredit_tbl        => l_header_scredit_tbl
	,   p_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
	,   p_line_tbl                => l_line_tbl
	,   p_line_val_tbl            => l_line_val_tbl
	,   p_Line_Adj_tbl            => l_line_adj_tbl
	,   p_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   p_Line_price_Att_tbl      => l_line_price_att_tbl
	,   p_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
	,   p_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl
	,   p_Line_Scredit_tbl        => l_line_scredit_tbl
	,   p_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   p_Lot_Serial_tbl            => l_lot_serial_tbl
	,   p_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   p_Action_Request_tbl        => l_request_tbl
	,   x_header_rec              => l_header_rec
	,   x_header_val_rec          => l_header_val_rec
	,   x_Header_Adj_tbl          => l_header_adj_tbl
	,   x_Header_Adj_val_tbl      => l_header_adj_val_tbl
	,   x_Header_price_Att_tbl    => l_header_price_att_tbl
	,   x_Header_Adj_Att_tbl      => l_header_adj_att_tbl
	,   x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl
	,   x_Header_Scredit_tbl      => l_header_scredit_tbl
	,   x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl
	,   x_line_tbl                => x_line_tbl       --modified for bug 6347596
	,   x_line_val_tbl            => l_line_val_tbl
	,   x_Line_Adj_tbl       => l_line_adj_tbl
	,   x_Line_Adj_val_tbl        => l_line_adj_val_tbl
	,   x_Line_price_Att_tbl      => l_line_price_att_tbl
	,   x_Line_Adj_Att_tbl   => l_line_adj_att_tbl
	,   x_Line_Adj_Assoc_tbl => l_line_adj_assoc_tbl
	,   x_Line_Scredit_tbl        => l_line_scredit_tbl
	,   x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl
	,   x_Lot_Serial_tbl     => l_lot_serial_tbl
	,   x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl
	,   x_action_request_tbl => l_action_request_tbl
	);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		ota_om_upd_api.retrieve_oe_messages(l_message_data);
      	RAISE FND_API.G_EXC_ERROR;

	END IF;
      resultout := 'COMPLETE';
	return;
   END IF;
   CLOSE C_EVENT;
END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'update_fulfill_date',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;

-- ----------------------------------------------------------------------------
-- |---------------------------< CHK_INVOICE_EXISTS >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a used to check the invoice of Order Line.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE  CHK_INVOICE_EXISTS (
itemtype 	IN 	VARCHAR2,
itemkey	IN	VARCHAR2,
actid       IN    NUMBER,
funcmode    IN    VARCHAR2,
resultout   OUT NOCOPY VARCHAR2
)
IS

l_line_id  oe_order_lines.line_id%type := to_number(itemkey);
l_proc 	varchar2(72) := g_package||'chk_invoice_exists';
l_invoice_quantity 	oe_order_lines.invoiced_quantity%type;


CURSOR c_invoice IS
SELECT
   decode(invoiced_quantity,null,0,invoiced_quantity)
FROM
   oe_order_lines
WHERE
   line_id = l_line_id;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

  IF (funcmode = 'RUN') THEN
  	OPEN c_invoice;
  	FETCH c_invoice into l_invoice_quantity;
  	IF c_invoice%found THEN
     	   IF l_invoice_quantity = 1 then
	  	resultout := wf_engine.eng_completed || ':' || 'Y';
     	   ELSE
	      resultout := wf_engine.eng_completed || ':' || 'N';
         END IF;
      END IF;
  	CLOSE c_invoice;
  END IF;

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

EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'Chk_invoice_exists',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;
  	hr_utility.set_location(' Leaving:'||l_proc, 10);
END;

-- ----------------------------------------------------------------------------
-- |------------------------------------< CHECK_UOM>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the uom of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE  CHECK_UOM(
Itemtype		IN 	VARCHAR2,
Itemkey		IN	VARCHAR2,
actid       	IN    NUMBER,
funcmode    	IN    VARCHAR2,
resultout	 OUT NOCOPY VARCHAR2
)
IS

l_uom		  oe_order_lines.order_quantity_uom%type;
l_proc 	varchar2(72) := g_package||'check_uom';
l_line_id  oe_order_lines.line_id%type := to_number(itemkey);
l_order_number  oe_order_headers.order_number%type;
l_line_number   oe_order_lines.line_number%type;
l_email_address  per_people_f.email_address%type;
l_description   varchar2(200);


CURSOR c_uom IS
SELECT
   ol.order_quantity_uom ,
   oh.order_number,
   ol.line_number
FROM
   oe_order_lines_all ol,
   oe_order_headers_all oh
WHERE
   oh.header_id = ol.header_id and
   ol.line_id = l_line_id;

/*CURSOR c_event IS
SELECT email_address
FROM per_people_f
WHERE person_id IN(
select owner_id from
ota_events where
line_id = l_line_id);*/


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN

  OPEN c_uom;
  FETCH c_uom into l_uom,
                   l_order_number,
                   l_line_number;
  IF c_uom%found THEN

     IF l_uom = 'ENR' then
	  resultout := 'COMPLETE:ENR';
     ELSIF l_uom= 'EVT' THEN

      --  OPEN c_event;
	--  FETCH c_event into l_email_address;
	--    WF_ENGINE.SetItemattrnumber(itemtype,itemkey,'NOTIFICATION_APPROVER',l_email_address);
     --   WF_ENGINE.SetItemattrnumber(p_itemtype,l_itemkey,'LIN_SHORT_DESCRIPTOR',l_order_number);

	  resultout := 'COMPLETE:EVT';
     END IF;
  END IF;
  CLOSE c_uom;
 END IF;
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
  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'Check_UOM',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
END;



-- ----------------------------------------------------------------------------
-- |------------------------------------< CHECK_CREATION>----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be a concurrent process which run in the background.
--
--   This procedure will only be used for OTA and OM integration. Basically this
--   procedure will select all delegate booking data that has daemon_flag='Y' and
--   Daemon_type  is not nul. If the enrollment got canceled and there is a
--   waitlisted student then the automatic waitlist processing will be called.
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHECK_CREATION(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       IN    NUMBER
,funcmode    IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2
)

IS

l_uom		  oe_order_lines.order_quantity_uom%type;
l_proc 	varchar2(72) := g_package||'ota_creation_ck';
l_line_id  oe_order_lines.line_id%type := to_number(itemkey);
l_exist	varchar2(1);


CURSOR c_uom IS
SELECT
   order_quantity_uom
FROM
   oe_order_lines
WHERE
   line_id = l_line_id;

CURSOR c_evt
IS
SELECT
	null
FROM
	OTA_EVENTS
WHERE
	line_id = l_line_id;

CURSOR c_enr
IS
SELECT
	null
FROM
	ota_delegate_bookings
WHERE
	line_id = l_line_id;


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN

  OPEN c_uom;
  FETCH c_uom into l_uom;
  IF c_uom%found THEN

     IF l_uom = 'ENR' then
	  OPEN C_ENR;
	  FETCH c_enr INTO l_exist;
	  IF c_enr%found then
    	     resultout := wf_engine.eng_completed || ':' || 'Y';
	  ELSE
	     resultout := wf_engine.eng_completed || ':' || 'N';
	  END IF;
	  CLOSE c_enr;
     ELSIF l_uom= 'EVT' THEN
	  OPEN C_EVT;
	  FETCH c_evt INTO l_exist;
	  IF c_evt%found then
    	     resultout := wf_engine.eng_completed || ':' || 'Y';
	  ELSE
	     resultout := wf_engine.eng_completed || ':' || 'N';
	  END IF;
	  CLOSE c_evt;
     END IF;
  END IF;
  CLOSE c_uom;
 END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'Check_Creation',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
END;

-- ----------------------------------------------------------------------------
-- |------------------------< CHK_ENROLL_STATUS_ADV >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the uom of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CHK_ENROLL_STATUS_ADV (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)

IS

CURSOR c_Enroll_type
IS
SELECT
	bst.type
FROM
	ota_delegate_bookings tdb,	ota_booking_status_types bst
WHERE
	line_id = to_number(itemkey)AND
	bst.booking_status_type_id = tdb.booking_status_type_id;

  l_proc 	varchar2(72) := g_package||'chk_enroll_status_adv';
  l_type	ota_booking_status_types.type%type;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN
   OPEN c_enroll_type;
  FETCH c_enroll_type INTO l_type;
  IF c_enroll_type%found THEN
     IF l_type = 'P' THEN
	  resultout := 'COMPLETE:PLACED';
     ELSIF l_type = 'W' THEN
 	  resultout := 'COMPLETE:WAITLISTED';

     END IF;
  END IF;
  CLOSE c_enroll_type;
 END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'chk_enroll_status_adv',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;
--
-- ----------------------------------------------------------------------------
-- |------------------------< CHK_ENROLL_STATUS_ARR >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the uom of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHK_ENROLL_STATUS_ARR (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)

IS

CURSOR c_Enroll_type
IS
SELECT
	bst.type
FROM
	ota_delegate_bookings tdb,
	ota_booking_status_types bst
WHERE
	line_id = to_number(itemkey)AND
	bst.booking_status_type_id = tdb.booking_status_type_id;

  l_proc 	varchar2(72) := g_package||'chk_enroll_status_arr';
  l_type	ota_booking_status_types.type%type;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN
  OPEN c_enroll_type;
  FETCH c_enroll_type INTO l_type;
  IF c_enroll_type%found THEN
     IF l_type = 'P' THEN
	  resultout := 'COMPLETE:PLACED';
     ELSIF l_type = 'W' THEN
 	  resultout := 'COMPLETE:WAITLISTED';
     ELSIF l_type = 'A' THEN
	resultout := 'COMPLETE:ATTENDED';
     ELSIF l_type = 'R' THEN
	resultout := 'COMPLETE:REQUESTED';

     END IF;
  END IF;
  CLOSE c_enroll_type;
 END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'chk_enroll_status_arr',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< CHECK_INVOICE_RULE >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the invoicing rule of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CHECK_INVOICE_RULE (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)

IS
CURSOR c_invoice_rule
IS
SELECT
	invoicing_rule_id
FROM
	oe_order_lines_all
WHERE
    line_id = to_number(itemkey);

  l_proc 	varchar2(72) := g_package||'check_invoice_rule';
  l_rule_id  oe_order_lines_all.invoicing_rule_id%type;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
IF (funcmode = 'RUN') THEN
  OPEN c_invoice_rule;
  FETCH c_invoice_rule INTO l_rule_id;
  IF c_invoice_rule%found THEN
	IF l_rule_id = -2 THEN
         resultout := 'COMPLETE:ADVANCED';
      ELSIF l_rule_id = -3 THEN
         resultout := 'COMPLETE:ARREAR';
	END IF;
  END IF;
  CLOSE c_invoice_rule;
END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'check_invoice_rule',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;


  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;
--

-- ----------------------------------------------------------------------------
-- |----------------------------< CANCEL_ENROLLMENT>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to cancel an enrollment.
--
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   itemtype,
--   itemkey
--   actid
--   funcmode
--
-- Out Arguments:
--   resultout
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE CANCEL_ENROLLMENT(
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)IS

l_org_id   oe_order_lines.org_id%type;
 l_proc 	varchar2(72) := g_package||'cancel_enrollment';
l_return_status  varchar2(1);

l_booking_status_type_id ota_booking_status_types.booking_status_type_id%type;
l_booking_status_type   varchar2(3);

 CURSOR C_ENROLLMENT IS
 SELECT
    Booking_status_type_id
 FROM
    OTA_DELEGATE_BOOKINGS
 WHERE
    Line_id = to_number(itemkey);

--

CURSOR C_BOOKING_STATUS IS
 SELECT
   Type
 FROM
   OTA_BOOKING_STATUS_TYPES
 WHERE
   booking_status_type_id = l_booking_status_type_id;


BEGIN
IF (funcmode = 'RUN') THEN
  hr_utility.set_location(' entering:'||l_proc, 5);
  OPEN C_ENROLLMENT;
    FETCH c_enrollment into
	         l_Booking_status_type_id;
    IF c_enrollment%found THEN
       OPEN C_BOOKING_STATUS;
       FETCH  c_booking_status into
              	l_booking_status_type;

       IF c_booking_status%found then
       	IF l_booking_status_type <>'C' then
           	   l_org_id := WF_ENGINE.getitemattrnumber(
		               itemtype  =>  itemtype,
		               itemkey =>  itemkey,
		               aname => 'ORG_ID');

     		   ota_cancel_api.delete_cancel_line
 					(
  					p_line_id  	=>to_number(itemkey),
  					p_org_id 	=> l_org_id,
  					p_UOM  	=> 'ENR',
  					P_daemon_type  => 'C',
  					x_return_status =>  l_return_status);
	    				resultout := 'COMPLETE';
    					return;
		ELSE
				resultout := 'COMPLETE';
    					return;
		END IF;
	 END IF;
	 CLOSE C_BOOKING_STATUS;
	END IF;
	CLOSE C_ENROLLMENT;

END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'cancel_enrollment',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);


END;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_OWNER_EMAIL >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the invoicing rule of the order line.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------

PROCEDURE UPDATE_OWNER_EMAIL (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)

IS

l_proc 	varchar2(72) := g_package||'update_owner_email';
l_line_id  oe_order_lines.line_id%type := to_number(itemkey);
l_user_name  fnd_user.user_name%type;


CURSOR c_uom IS
SELECT
   ol.order_quantity_uom ,
   oh.order_number,
   ol.line_number
FROM
   oe_order_lines_all ol,
   oe_order_headers_all oh
WHERE
   oh.header_id = ol.header_id and
   ol.line_id = l_line_id;

CURSOR c_event IS
SELECT user_name
FROM FND_USER
WHERE employee_id IN(
select owner_id from
ota_events where
line_id = l_line_id);


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN

        OPEN c_event;
	  FETCH c_event into l_user_name;
	  WF_ENGINE.SetItemattrtext(itemtype,itemkey,'NOTIFICATION_APPROVER',l_user_name);
        resultout := 'COMPLETE';
        CLOSE c_event;
 END IF;
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
  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'UPDATE_OWNER_EMAIL',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
END;

-- ----------------------------------------------------------------------------
-- |------------------------< CHK_EVENT_ENROLL_STATUS >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure  will be used to check the completion of the order line for
--   Private Event whis is come from OM.
--   It will be called by the workflow activity.
--
--
-- Pre Conditions:
--   None.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an err--
--
--
-- Post Success:
--   Processing continues.
--
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
----------------------------------------------------------------------------
PROCEDURE CHK_EVENT_ENROLL_STATUS (
Itemtype		IN 	VARCHAR2
,Itemkey		IN	VARCHAR2
,actid       	IN    NUMBER
,funcmode    	IN    VARCHAR2
,resultout	 OUT NOCOPY VARCHAR2)

IS

l_event_id   ota_events.event_id%type;


CURSOR C_EVENT
IS
SELECT
  EVENT_ID
FROM
  OTA_EVENTS
WHERE
  line_id = to_number(itemkey);

CURSOR c_Enroll_type
IS
SELECT
	bst.type
FROM
	ota_delegate_bookings tdb,
	ota_booking_status_types bst
WHERE
	event_id = l_event_id AND
	bst.booking_status_type_id = tdb.booking_status_type_id;

  l_proc 	varchar2(72) := g_package||'chk_event_enroll_status';
  l_type	ota_booking_status_types.type%type;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
 IF (funcmode = 'RUN') THEN
  OPEN C_EVENT;
  FETCH C_EVENT INTO l_event_id;
  IF c_event%found then
    OPEN c_enroll_type;
    FETCH c_enroll_type INTO l_type;
    IF c_enroll_type%found THEN
       IF l_type = 'P' THEN
	    resultout := 'COMPLETE:PLACED';
       ELSIF l_type = 'W' THEN
 	    resultout := 'COMPLETE:WAITLISTED';
       ELSIF l_type = 'A' THEN
	   resultout := 'COMPLETE:ATTENDED';
       ELSIF l_type = 'R' THEN
	   resultout := 'COMPLETE:REQUESTED';

       END IF;
    END IF;
    CLOSE c_enroll_type;
   END IF;
    CLOSE C_EVENT;
 END IF;
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

  EXCEPTION
  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OTA_WF', 'chk_enroll_status_arr',
		    itemtype, itemkey, to_char(actid), funcmode);
    RAISE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

END;


end  ota_wf;

/
