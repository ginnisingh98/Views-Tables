--------------------------------------------------------
--  DDL for Package Body IBE_CANCEL_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CANCEL_ORDER_PVT" AS
/* $Header: IBECORDB.pls 120.3 2005/08/10 04:46:55 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_CANCEL_ORDER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBECORDB.pls';
l_true VARCHAR2(1) := FND_API.G_TRUE;

PROCEDURE CANCEL_ORDER (
    p_api_version       IN  NUMBER   := 1                  ,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_TRUE     ,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE    ,
    p_order_header_id   IN  NUMBER ,
    p_comments          IN  VARCHAR2,
    p_reason_code       IN  VARCHAR2,
    P_Last_Updated_By   IN  NUMBER,
    P_Last_Update_Date  IN  DATE,
    P_Last_Update_Login	IN  NUMBER,
    X_Return_Status     OUT NOCOPY VARCHAR2,
    X_Msg_Count         OUT NOCOPY NUMBER,
    X_Msg_Data          OUT NOCOPY VARCHAR2
    )
   IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'CANCEL_ORDER';

  l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=
                                OE_Order_PUB.G_MISS_REQUEST_TBL;
  l_control_rec                 OE_GLOBALS.Control_Rec_Type;
  l_return_status               VARCHAR2(1);
  l_header_rec                  OE_Order_PUB.Header_Rec_Type
                                := OE_ORDER_PUB.G_MISS_HEADER_REC;
  x_header_rec                  OE_Order_PUB.Header_Rec_Type
                                := OE_ORDER_PUB.G_MISS_HEADER_REC;
  l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
  l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
  l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
  l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_old_header_rec              OE_Order_PUB.Header_Rec_Type;
  l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
  l_old_Header_price_Att_tbl    OE_Order_PUB.Header_Price_Att_Tbl_Type ;
  l_old_Header_Adj_Att_tbl      OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
  l_old_Header_Adj_Assoc_tbl    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
  l_old_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_old_line_tbl                OE_Order_PUB.Line_Tbl_Type;
  l_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
  l_old_Line_price_Att_tbl      OE_Order_PUB.Line_Price_Att_Tbl_Type ;
  l_old_Line_Adj_Att_tbl        OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
  l_old_Line_Adj_Assoc_tbl      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
  l_old_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_old_Lot_Serial_tbl          OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;
  l_return_values               varchar2(50);
  l_header_val_rec              OE_Order_PUB.Header_Val_Rec_Type;
  l_old_header_val_rec          OE_Order_PUB.Header_Val_Rec_Type;
  l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
  l_old_header_adj_val_tbl      OE_Order_PUB.Header_Adj_Val_Tbl_Type;
  l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
  l_old_header_scredit_val_tbl  OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
  l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
  l_old_line_val_tbl            OE_Order_PUB.Line_Val_Tbl_Type;
  l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
  l_old_line_adj_val_tbl        OE_Order_PUB.Line_Adj_Val_Tbl_Type;
  l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
  l_old_line_scredit_val_tbl    OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
  l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
  l_old_lot_serial_val_tbl      OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
  l_commit                      VARCHAR2(10)     := FND_API.G_FALSE;
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_userid                      VARCHAR2(30);
  l_rownums                     NUMBER;
  l_colname                     VARCHAR2(240);


  -- Variable needed for Cancelling Orders across difft orgs.
  l_user_orgid         NUMBER;
  l_order_orgid        NUMBER;

  x_ont_return_status  VARCHAR2(30);
  x_ont_msg_count      NUMBER;
  x_ont_msg_data       VARCHAR2(2000);

  CURSOR c_ord(l_header_id NUMBER) IS
  SELECT org_id FROM oe_order_headers_all
  WHERE header_id = l_header_id;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_CANCEL_ORDER_PVT.CANCEL_ORDER()');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT CANCEL_Order_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.

 IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_CANCEL_ORDER_PVT.CANCEL_ORDER:START');
  END IF;



  -- ******************************************************************
  -- cancel order across multi-org
  -- If the User-Context-OrgId is different from the Order's OrgId,
  -- Then
  --    Switch the Context to the Order-Creator's Context
  --    and then call the process-order api
  -- Else
  --    Call the process-order api directly
  -- ******************************************************************


  -- Get the User's Session ORG_ID
  l_user_orgid := mo_global.GET_CURRENT_ORG_ID();

  -- Get the Order's ORG_ID
  OPEN  c_ord(p_order_header_id);
  FETCH c_ord into l_order_orgid;
  CLOSE c_ord;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('User Context - ORG_ID : '||TO_CHAR(l_user_orgid));
     IBE_UTIL.DEBUG('OrderContext - ORG_ID : '||TO_CHAR(l_order_orgid));
  END IF;

  IF l_order_orgid <> l_user_orgid THEN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Before ORG_ID Switch to Orders ORG_ID');
      END IF;

      -- Set the Session's ORGID to the Order's ORG_ID, before calling the Process_Order() API
	 -- i.e Set the Global Security Context to that of the original Order Creator's ORG_ID
      mo_global.set_policy_context('S', l_order_orgid);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('After ORG_ID Switch to Orders ORG_ID : '|| mo_global.GET_CURRENT_ORG_ID());
      END IF;

  END IF;    -- End of (l_order_orgid <> l_user_orgid) condition



  -- ******************************************************************
  -- Initialize the local variable
  -- ******************************************************************
  l_msg_data      := x_msg_data;
  l_msg_count     := x_msg_count;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --******************************************************************
  -- Initialize the Order Header information
  -- ******************************************************************
  l_header_rec.header_id       := p_order_header_id;
  l_header_rec.cancelled_flag  := 'Y';
  l_header_rec.change_reason   := p_reason_code;
  l_header_rec.change_comments := p_comments;
  l_header_rec.operation       := OE_Globals.G_OPR_UPDATE;
  --
  -- API body
  --
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('OE_Order_GRP.Process_Order:START');
  END IF;
   OE_Order_GRP.Process_Order
    (p_api_version_number      => 1.0,
     p_init_msg_list           => FND_API.G_TRUE,
     p_return_values           => l_return_values,
     p_commit                  => FND_API.G_FALSE,
     x_return_status           => x_return_status,
     x_msg_count               => x_msg_count,
     x_msg_data                => x_msg_data,
     p_header_rec              => l_header_rec,
     x_header_rec              => x_header_rec,
     x_header_val_rec          => l_header_val_rec,
     x_Header_Adj_tbl          => l_header_adj_tbl,
     x_Header_Adj_val_tbl      => l_header_adj_val_tbl,
     x_Header_price_Att_tbl    => l_header_price_att_tbl,
     x_Header_Adj_Att_tbl      => l_header_adj_att_tbl,
     x_Header_Adj_Assoc_tbl    => l_header_adj_assoc_tbl,
     x_Header_Scredit_tbl      => l_header_scredit_tbl,
     x_Header_Scredit_val_tbl  => l_header_scredit_val_tbl,
     x_line_tbl                => l_line_tbl,
     x_line_val_tbl            => l_line_val_tbl,
     x_Line_Adj_tbl            => l_line_adj_tbl,
     x_Line_Adj_val_tbl        => l_line_adj_val_tbl,
     x_Line_price_Att_tbl      => l_line_price_att_tbl,
     x_Line_Adj_Att_tbl        => l_line_adj_att_tbl,
     x_Line_Adj_Assoc_tbl      => l_line_adj_assoc_tbl,
     x_Line_Scredit_tbl        => l_line_scredit_tbl,
     x_Line_Scredit_val_tbl    => l_line_scredit_val_tbl,
     x_Lot_Serial_tbl          => l_lot_serial_tbl,
     x_Lot_Serial_val_tbl      => l_lot_serial_val_tbl,
     x_action_request_tbl      => l_action_request_tbl
                                                        );
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('OE_Order_GRP.Process_Order:Finishes');
     END IF;

  -- Check return status from the above procedure call

  IF x_return_status = FND_API.G_RET_STS_ERROR then
    raise FND_API.G_EXC_ERROR;
  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  if x_return_status = FND_API.G_RET_STS_SUCCESS then
  --     call Notification api.
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Ready to call Notification API:IBE_WORKFLOW_PVT.Notify_cancel_order');
       IBE_UTIL.DEBUG('Input order id to notification API is: '||p_order_header_id);
    END IF;
    IBE_WORKFLOW_PVT.Notify_cancel_order(
      p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_order_id        => p_order_header_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data
                                       );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Done Notification API:IBE_WORKFLOW_PVT.Notify_cancel_order');
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  end if;


  -- Restore the Logged-In User's Security Context, if switched
  IF l_order_orgid <> l_user_orgid THEN

      mo_global.set_policy_context('S', l_user_orgid);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Restored the ORG_ID to the Users ORG_ID: '||  mo_global.GET_CURRENT_ORG_ID());
      END IF;

  END IF;


  --
  -- End of API body.
  --
  -- Standard check for l_commit
  IF FND_API.to_Boolean( l_commit ) THEN
    COMMIT WORK;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('IBE_CANCEL_ORDER_PVT.CANCEL_ORDER:DONE');
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                              p_data  =>   x_msg_data);


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CANCEL_Order_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

      -- Restore the Logged-In User's Security Context, if switched
      IF l_order_orgid <> l_user_orgid THEN

          mo_global.set_policy_context('S', l_user_orgid);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Restored the ORG_ID to the Users ORG_ID: '||  mo_global.GET_CURRENT_ORG_ID());
          END IF;

      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_CANCEL_ORDER_PVT.CANCEL_ORDER()');
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO CANCEL_Order_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      -- Restore the Logged-In User's Security Context, if switched
      IF l_order_orgid <> l_user_orgid THEN

          mo_global.set_policy_context('S', l_user_orgid);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Restored the ORG_ID to the Users ORG_ID: '||  mo_global.GET_CURRENT_ORG_ID());
          END IF;

      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_CANCEL_ORDER_PVT.CANCEL_ORDER()');
      END IF;

   WHEN OTHERS THEN
     -- changes for retrieving OM messages
      ibe_order_save_pvt.retrieve_oe_messages;
      ROLLBACK TO CANCEL_Order_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_ont_msg_count    ,
                                p_data    => x_ont_msg_data);

      -- Restore the Logged-In User's Security Context, if switched
      IF l_order_orgid <> l_user_orgid THEN

          mo_global.set_policy_context('S', l_user_orgid);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Restored the ORG_ID to the Users ORG_ID: '||  mo_global.GET_CURRENT_ORG_ID());
          END IF;

      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_CANCEL_ORDER_PVT.CANCEL_ORDER()');
      END IF;


END CANCEL_ORDER;

END IBE_CANCEL_ORDER_PVT;

/
