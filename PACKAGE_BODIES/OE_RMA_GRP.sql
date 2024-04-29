--------------------------------------------------------
--  DDL for Package Body OE_RMA_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RMA_GRP" AS
/* $Header: OEXGRMAB.pls 120.1 2006/03/10 12:07:08 mchavan noship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_RMA_GRP';

/*
** Submit_Ordeer() will progress the return order header forward
** from Awaiting Submission once the user submits the order.
*/
PROCEDURE Submit_Order(
  p_api_version		IN		NUMBER
, p_header_id 		IN 		NUMBER
, x_return_status	OUT	NOCOPY	VARCHAR2
, x_msg_count		OUT	NOCOPY	NUMBER
, x_msg_data		OUT	NOCOPY	VARCHAR2
)
IS
l_api_version	CONSTANT NUMBER := 1.0;
l_api_name	CONSTANT VARCHAR2(30):= 'Submit_Order';

l_header_rec	OE_Order_PUB.Header_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: ENTERING SUBMIT_ORDER, HEADER ID: '||P_HEADER_ID) ;
  END IF;

  /* Standard call to check for call compatibility */

  IF NOT FND_API.Compatible_API_Call
           (   l_api_version
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME
           )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OE_Header_Util.Query_Row(p_header_id  => p_header_id,
                           x_header_rec => l_header_rec);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: AFTER CALLING QUERY ROW') ;
  END IF;

  /* Complete the Wait for Submission activity */

  WF_ENGINE.CompleteActivityInternalName( 'OEOH'
                                        , to_char(p_header_id)
                                        , 'RMA_WAIT_FOR_SUBMISSION'
                                        , 'COMPLETE'
                                        );

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: AFTER COMPLETING THE WAIT FOR SUBMISSION ACTIVITY') ;
  END IF;

  /* Update the ordered_date with the system date */

  l_header_rec.ordered_date      := SYSDATE;
  l_header_rec.last_updated_by   := FND_GLOBAL.USER_ID;
  l_header_rec.last_update_date  := SYSDATE;
  l_header_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

  UPDATE oe_order_headers
  SET	 ordered_date      = l_header_rec.ordered_date
  ,      last_updated_by   = l_header_rec.last_updated_by
  ,      last_update_date  = l_header_rec.last_update_date
  ,      last_update_login = l_header_rec.last_update_login
  WHERE	 header_id         = p_header_id;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: AFTER UPDATING ORDERED DATE ON HEADER');
  END IF;

  /* Update the Header Cache with the new information */

  OE_Order_Cache.Set_Order_Header(l_header_rec);

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: AFTER CALLING UPDATE FLOW STATUS CODE, RETURN STATUS: '||X_RETURN_STATUS);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: EXITING SUBMIT_ORDER');
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Submit_Order'
            );
      END IF;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );
END Submit_Order;

/*
** Is_Over_Return() will check if returned qty matches the original
** ordered qty. If returned qty exceeds the original ordered qty, the
** API will raise an error.
**
** NOTE that this api even looks at Unbooked Return Lines, which is
** different from the Is_Over_Return() procedure in OE_LINE_UTIL Package.
*/
PROCEDURE Is_Over_Return(
  p_api_version		IN		NUMBER
, p_line_tbl		IN 		OE_ORDER_PUB.LINE_TBL_TYPE
, x_error_tbl           OUT     NOCOPY  OE_RMA_GRP.OVER_RETURN_ERR_TBL_TYPE
, x_return_status	OUT	NOCOPY	VARCHAR2
, x_msg_count		OUT	NOCOPY	NUMBER
, x_msg_data		OUT	NOCOPY	VARCHAR2
)
IS
l_api_version	CONSTANT NUMBER := 1.0;
l_api_name	CONSTANT VARCHAR2(30):= 'Is_Over_Return';

l_index			NUMBER;
l_ctr                   NUMBER := 0;
l_already_returned	NUMBER;
l_original_ordered	NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: ENTERING IS_OVER_RETURN') ;
  END IF;

  /* Standard call to check for call compatibility */

  IF NOT FND_API.Compatible_API_Call
           (   l_api_version
           ,   p_api_version
           ,   l_api_name
           ,   G_PKG_NAME
           )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Validate returned qty for each line id in the Line Table */
  l_index := p_line_tbl.FIRST;

  WHILE l_index IS NOT NULL LOOP

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXGRMAB: VALIDATE LINE ID/ITEM ID: '||p_line_tbl(l_index).line_id||'/'
                                                             ||p_line_tbl(l_index).inventory_item_id) ;
    END IF;

    /* Get the total qty already returned for the referenced SO Line */

    SELECT nvl(sum(ordered_quantity), 0)
    INTO   l_already_returned
    FROM   oe_order_lines
    WHERE  reference_line_id   = p_line_tbl(l_index).reference_line_id
    AND    cancelled_flag      <> 'Y'
    AND    line_category_code  = 'RETURN'
    AND    line_id             <> p_line_tbl(l_index).line_id;

    /* Get the originally ordered qty on referenced SO line */

    SELECT nvl(ordered_quantity, 0)
    INTO   l_original_ordered
    FROM   oe_order_lines
    WHERE  line_id = p_line_tbl(l_index).reference_line_id;

    /* Check if the quantity is Over Returned */

    IF (l_already_returned + p_line_tbl(l_index).ordered_quantity) > l_original_ordered THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OEXGRMAB: LINE OVER RETURNED ERROR');
      END IF;

      FND_MESSAGE.Set_Name('ONT','OE_LINE_OVER_RETURNED');
      FND_MESSAGE.Set_Token('LINE', p_line_tbl(l_index).line_number);
      FND_MESSAGE.Set_Token('PREVIOUS', l_already_returned);
      FND_MESSAGE.Set_Token('CURRENT', p_line_tbl(l_index).ordered_quantity);
      FND_MESSAGE.Set_Token('ORIGINAL', l_original_ordered);
      OE_MSG_PUB.Add;
      /* No Need to Raise the Exception, Just Set the Return Status */
      --Raise FND_API.G_EXC_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;

      /*
      ** Populate the Return Error Table to let iStore know
      ** of the Return Lines which actually errored out.
      */
      l_ctr := l_ctr + 1;

      x_error_tbl(l_ctr).line_id := p_line_tbl(l_index).line_id;
      x_error_tbl(l_ctr).previous_quantity := l_already_returned;
      x_error_tbl(l_ctr).current_quantity  := p_line_tbl(l_index).ordered_quantity;
      x_error_tbl(l_ctr).original_quantity := l_original_ordered;
      x_error_tbl(l_ctr).return_status := FND_API.G_RET_STS_ERROR;

      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_error_tbl(l_ctr).msg_data
            , p_msg_index_out => x_error_tbl(l_ctr).msg_count
            );

    END IF;

    l_index := p_line_tbl.NEXT(l_index);

  END LOOP;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: EXITING IS_OVER_RETURN');
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Is_Over_Return'
            );
      END IF;
      OE_MSG_PUB.Get
            ( p_msg_index     => OE_MSG_PUB.G_LAST
            , p_encoded       => FND_API.G_FALSE
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_count
            );

END Is_Over_Return;

/*
** Post_Approval_Process() will be called from workflow activyt to do
** some post approval steps. For example it will call iStore API that
** sends the notification on approval of the return order to the end user.
*/
PROCEDURE Post_Approval_Process(
  itemtype 	IN 	VARCHAR2
, itemkey 	IN 	VARCHAR2
, actid 	IN 	NUMBER
, funcmode 	IN 	VARCHAR2
, resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
l_order_source_id       NUMBER;
l_notification_id	NUMBER;
l_ntf_exists	        VARCHAR2(1) := 'Y';
l_comments		VARCHAR2(4000);
l_block_str             VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

CURSOR ntf
IS
SELECT wv.NOTIFICATION_ID
FROM
 (
    select IAS.NOTIFICATION_ID NOTIFICATION_ID, IAS.END_DATE END_DATE
      from WF_PROCESS_ACTIVITIES PA,
           WF_ITEM_ACTIVITY_STATUSES IAS
     where IAS.ITEM_TYPE = itemtype
       and IAS.ITEM_KEY = itemkey
       and PA.ACTIVITY_NAME = 'RMA_ORDER_APPROVAL_NTF'
       and IAS.NOTIFICATION_ID is not null
       and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
 UNION ALL
    select IAS.NOTIFICATION_ID, IAS.END_DATE
      from WF_PROCESS_ACTIVITIES PA,
           WF_ITEM_ACTIVITY_STATUSES_H IAS
     where IAS.ITEM_TYPE = itemtype
       and IAS.ITEM_KEY = itemkey
       and PA.ACTIVITY_NAME = 'RMA_ORDER_APPROVAL_NTF'
       and IAS.NOTIFICATION_ID is not null
       and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
 ) wv
 ORDER BY wv.end_date DESC ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: ENTERING POST_APPROVAL_PROCESS, ITEM TYPE/KEY: '||itemtype||'/'||itemkey) ;
  END IF;

  IF (FUNCMODE = 'RUN') THEN

    IF itemtype = OE_GLOBALS.G_WFI_HDR THEN

      /* Get the Order Source ID of the Order */

      SELECT order_source_id
      INTO   l_order_source_id
      FROM   oe_order_headers
      WHERE  header_id = to_number(itemkey);

      IF l_order_source_id  = 13 THEN

        /* Get Notification ID for Return Order Approval NTF */

        OPEN ntf;

        FETCH ntf INTO l_notification_id;
        IF ntf%NOTFOUND THEN
          l_ntf_exists := 'N';
        END IF;

        CLOSE ntf;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXGRMAB: NOTIFICATION ID: '||l_notification_id) ;
        END IF;

        /* Get Approver Comments */

        IF l_ntf_exists = 'Y' THEN
          l_comments := WF_NOTIFICATION.GetAttrText(l_notification_id, 'WF_NOTE');
        END IF;

        /* Prepare dynamic SQL to call iStore API */

        l_block_str :=
        'DECLARE '||
        'BEGIN '||
        'IBE_OM_INTEGRATION_GRP.Notify_RMA_Request_Action(
           p_api_version_number => 1.0
         , p_order_header_id    => :header_id
         , p_notif_context      => IBE_OM_INTEGRATION_GRP.G_RETURN_APPROVAL
         , p_comments           => :comment
         , p_reject_reason_code => null
         , x_return_status      => :return_status
         , x_msg_count          => :msg_count
         , x_msg_data           => :msg_data
         );'||
        'END;';

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXGRMAB: BEFORE CALLING IBE_OM_INTEGRATION_GRP.NOTIFY_RMA_REQUEST_ACTION');
        END IF;

        BEGIN
          EXECUTE IMMEDIATE  l_block_str
                   USING IN  to_number(itemkey)
                       , IN  l_comments
                       , OUT l_return_status
                       , OUT l_msg_count
                       , OUT l_msg_data;
        EXCEPTION
          WHEN OTHERS THEN
            /*
            ** Ignore the following Exceptions
            ** 6550: PL/SQL Compilation Error - Raised when above package does not exist.
            ** 4067: Not executed, <Object> does not exist - Raised when just the spec exists.
            */
            IF SQLCODE in ('-6550', '-4067') THEN
              OE_DEBUG_PUB.ADD('OEXGRMAB: ISTORE PACKAGE DOES NOT EXIST '||SQLCODE);
              NULL;
            ELSE
              OE_DEBUG_PUB.ADD('OEXGRMAB: PACKAGE EXIST, SOME OTHER EXCEPTION '||SQLCODE);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXGRMAB: AFTER CALLING IBE_OM_INTEGRATION_GRP.NOTIFY_RMA_REQUEST_ACTION');
        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- If iStore Return

    ELSE -- Not Header Item Type
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    RESULTOUT := 'COMPLETE:COMPLETE';

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: EXITING POST_APPROVAL_PROCESS');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context(G_PKG_NAME, 'Post_Approval_Process', itemtype, itemkey, to_char(actid), funcmode);
    Raise;

END Post_Approval_Process;

/*
** Post_Rejection_Process() will set the reason for rejecting the RMA
** into OE_REASONS table. It will also call iStore API that sends the
** notification on rejection of the return order to the end user.
*/
PROCEDURE Post_Rejection_Process(
  itemtype 	IN 	VARCHAR2
, itemkey 	IN 	VARCHAR2
, actid 	IN 	NUMBER
, funcmode 	IN 	VARCHAR2
, resultout 	IN OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
l_order_source_id       NUMBER;
l_notification_id	NUMBER;
l_ntf_exists	        VARCHAR2(1) := 'Y';
l_reason_exists         VARCHAR2(1);
l_reason_code           VARCHAR2(30);
l_reason_id		NUMBER;
l_comments		VARCHAR2(4000);
l_block_str             VARCHAR2(2000);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);

CURSOR ntf
IS
SELECT wv.NOTIFICATION_ID
FROM
 (
    select IAS.NOTIFICATION_ID NOTIFICATION_ID, IAS.END_DATE END_DATE
      from WF_PROCESS_ACTIVITIES PA,
           WF_ITEM_ACTIVITY_STATUSES IAS
     where IAS.ITEM_TYPE = itemtype
       and IAS.ITEM_KEY = itemkey
       and PA.ACTIVITY_NAME = 'RMA_ORDER_APPROVAL_NTF'
       and IAS.NOTIFICATION_ID is not null
       and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
 UNION ALL
    select IAS.NOTIFICATION_ID, IAS.END_DATE
      from WF_PROCESS_ACTIVITIES PA,
           WF_ITEM_ACTIVITY_STATUSES_H IAS
     where IAS.ITEM_TYPE = itemtype
       and IAS.ITEM_KEY = itemkey
       and PA.ACTIVITY_NAME = 'RMA_ORDER_APPROVAL_NTF'
       and IAS.NOTIFICATION_ID is not null
       and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
 ) wv
 ORDER BY wv.end_date DESC ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: ENTERING POST_REJECTION_PROCESS, ITEM TYPE/KEY: '||itemtype||'/'||itemkey) ;
  END IF;

  IF (FUNCMODE = 'RUN') THEN

    IF itemtype = OE_GLOBALS.G_WFI_HDR THEN

      /* Get Notification ID for Return Order Approval NTF */

      OPEN ntf;

      FETCH ntf INTO l_notification_id;
      IF ntf%NOTFOUND THEN
        l_ntf_exists := 'N';
      END IF;

      CLOSE ntf;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OEXGRMAB: NOTIFICATION ID: '||l_notification_id) ;
      END IF;

      /* Get Rejection Reason and Comments */

      IF l_ntf_exists = 'Y' THEN
        l_reason_code := WF_NOTIFICATION.GetAttrText(l_notification_id, 'REJECTION_REASON');
        l_comments := WF_NOTIFICATION.GetAttrText(l_notification_id, 'WF_NOTE');
      END IF;

      /* Update the Rejection Reason */

      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

        /* Check if Rejection Reason has been setup in RMA_REJECTION_REASON lookup */
        BEGIN
          SELECT 'Y'
          INTO  l_reason_exists
          FROM  oe_lookups
          WHERE lookup_type = 'RMA_REJECTION_REASON'
          AND   lookup_code = l_reason_code;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_reason_exists := 'N';
        END;

        IF l_reason_exists = 'Y' THEN

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OEXGRMAB: BEFORE CALLING OE_REASONS_UTIL.APPLY_REASON');
          END IF;

          /* Set the Reason in the OE_REASONS Table */

          OE_REASONS_UTIL.Apply_Reason(
            p_entity_code    => 'HEADER'
          , p_entity_id	     => to_number(itemkey)
          , p_version_number => 1.0
          , p_reason_type    => 'RMA_REJECTION_REASON'
          , p_reason_code    => l_reason_code
          , p_reason_comments=> l_comments
          , x_reason_id      => l_reason_id
          , x_return_status  => l_return_status
          );

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add('OEXGRMAB: AFTER CALLING OE_REASONS_UTIL.APPLY_REASON');
          END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;
      END IF;

      /* Get the Order Source ID of the Order */

      SELECT order_source_id
      INTO   l_order_source_id
      FROM   oe_order_headers
      WHERE  header_id = to_number(itemkey);

      /* Check if this Return Order originated from iStore */

      IF l_order_source_id  = 13 THEN

        /* Prepare dynamic SQL to call iStore API */

        l_block_str :=
        'DECLARE '||
        'BEGIN '||
        'IBE_OM_INTEGRATION_GRP.Notify_RMA_Request_Action(
           p_api_version_number => 1.0
         , p_order_header_id    => :header_id
         , p_notif_context      => IBE_OM_INTEGRATION_GRP.G_RETURN_REJECT
         , p_comments           => :comment
         , p_reject_reason_code => :reason
         , x_return_status      => :return_status
         , x_msg_count          => :msg_count
         , x_msg_data           => :msg_data
         );'||
        'END;';

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXGRMAB: BEFORE CALLING IBE_OM_INTEGRATION_GRP.NOTIFY_RMA_REQUEST_ACTION');
        END IF;

        BEGIN
          EXECUTE IMMEDIATE  l_block_str
                   USING IN  to_number(itemkey)
                       , IN  l_comments
                       , IN  l_reason_code
                       , OUT l_return_status
                       , OUT l_msg_count
                       , OUT l_msg_data;
        EXCEPTION
          WHEN OTHERS THEN
            /*
            ** Ignore the following Exceptions
            ** 6550: PL/SQL Compilation Error - Raised when above package does not exist.
            ** 4067: Not executed, <Object> does not exist - Raised when just the spec exists.
            */
            IF SQLCODE in ('-6550', '-4067') THEN
              OE_DEBUG_PUB.ADD('OEXGRMAB: ISTORE PACKAGE DOES NOT EXIST '||SQLCODE);
              NULL;
            ELSE
              OE_DEBUG_PUB.ADD('OEXGRMAB: PACKAGE EXIST, SOME OTHER EXCEPTION '||SQLCODE);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END;

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OEXGRMAB: AFTER CALLING IBE_OM_INTEGRATION_GRP.NOTIFY_RMA_REQUEST_ACTION');
        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF; -- If iStore Return

    ELSE -- Not Header Item Type
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    RESULTOUT := 'COMPLETE:COMPLETE';

  END IF;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXGRMAB: EXITING POST_REJECTION_PROCESS');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context(G_PKG_NAME, 'Post_Rejection_Process', itemtype, itemkey, to_char(actid), funcmode);
    Raise;

END Post_Rejection_Process;

END OE_RMA_GRP;

/
