--------------------------------------------------------
--  DDL for Package Body OE_VERIFY_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VERIFY_PAYMENT_PUB" AS
/* $Header: OEXPVPMB.pls 120.39.12010000.10 2010/02/03 20:21:45 lagrawal ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_Verify_Payment_PUB';
G_credit_check_rule_id NUMBER;

PROCEDURE Check_ReAuth_for_MultiPmnts
(  p_credit_card_approval_code 	IN VARCHAR2
,  p_trxn_extension_id 		IN NUMBER
,  p_amount_to_authorize  	IN NUMBER
,  p_org_id			IN NUMBER
,  p_site_use_id                IN NUMBER
,  p_header_id                  IN NUMBER  --bug 5209584
,  p_line_id                    IN NUMBER
,  p_payment_number             IN NUMBER
,  p_reauthorize_out 		OUT NOCOPY  VARCHAR2
,  x_msg_count       		OUT NOCOPY  NUMBER
,  x_msg_data        		OUT NOCOPY  VARCHAR2
,  x_return_status   		OUT NOCOPY  VARCHAR2
);

--bug3225795 start
--this function is currently similar to Get_Line_Total. Needs to be changed later to consider partial invoicing.
FUNCTION Get_Inv_Line_Total
( p_line_id		  IN 	NUMBER
, p_header_id		  IN	NUMBER
, p_currency_code	  IN	VARCHAR2
, p_level		  IN	VARCHAR2
, p_to_exclude_commitment IN    VARCHAR2 DEFAULT 'Y' --bug3225795
) RETURN NUMBER;


PROCEDURE Update_AuthInfo_for_MultiPmnts
( p_header_id           IN   NUMBER
, p_auth_amount         IN   NUMBER
, p_auth_code           IN   VARCHAR2
, p_auth_date           IN   DATE
, p_tangible_id		IN   VARCHAR2
, p_line_id             IN   NUMBER
, p_payment_number	IN   NUMBER
, p_msg_count           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

-- bug 4339864, make this autonomous to be called for picking,shipping and packing event.
PROCEDURE Apply_Verify_Line_Hold_Commit
(  p_header_id       IN   NUMBER
,  p_line_id         IN   NUMBER
,  p_hold_id         IN   NUMBER
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

-- bug 4339864
PRAGMA AUTONOMOUS_TRANSACTION;

l_hold_id		NUMBER;
l_hold_source_rec   	OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  	OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_result   	VARCHAR2(30);
l_line_ind		VARCHAR2(240);
l_line_number		NUMBER;
l_shipment_number 	NUMBER;
l_option_number   	NUMBER;
l_component_number	NUMBER;
l_service_number	NUMBER;

l_msg_count         	NUMBER := 0;
l_msg_data          	VARCHAR2(2000);
l_return_status     	VARCHAR2(30);
l_debug_level CONSTANT 	NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN APPLY VERIFY LINE HOLDS' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: LINE ID : '||P_LINE_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HOLD ID : '||P_HOLD_ID ) ;
  END IF;

  -- Check if Hold already exists on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING IF REQUESTED VERIFY HOLD ALREADY APPLIED' ) ;
  END IF;
  --
    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_line_id        => p_line_id
                      , p_hold_id        => l_hold_id
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

  -- Return with Success if this Hold Already exists on the order
  IF l_hold_result = FND_API.G_TRUE THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: HOLD ALREADY APPLIED ON LINE ID : ' || P_LINE_ID ) ;
    END IF;
    RETURN ;
  END IF ;

  -- Apply Verify Hold on Order Line
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLYING VERIFY HOLD ON LINE ID : ' || P_LINE_ID ) ;
  END IF;

  l_hold_source_rec.hold_id         := p_hold_id ;
  l_hold_source_rec.hold_entity_code:= 'O';
  l_hold_source_rec.hold_entity_id  := p_header_id;
  l_hold_source_rec.line_id         := p_line_id;

  OE_Holds_PUB.Apply_Holds
                (   p_api_version       =>      1.0
                ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                ,   p_hold_source_rec   =>      l_hold_source_rec
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                ,   x_return_status     =>      l_return_status
                );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_hold_id = 16 THEN

      BEGIN
       SELECT line_number,
              shipment_number,
              option_number,
              component_number,
              service_number
       INTO   l_line_number,
              l_shipment_number,
              l_option_number,
              l_component_number,
              l_service_number
       from  oe_order_lines_all
       where line_id = p_line_id;


      end;
      l_line_ind := RTRIM(l_line_number      || '.' ||
                             l_shipment_number  || '.' ||
                             l_option_number    || '.' ||
                             l_component_number || '.' ||
                             l_service_number, '.');


      FND_MESSAGE.SET_NAME('ONT','ONT_PENDING_AUTH_HOLD_APPLIED');
      FND_MESSAGE.SET_TOKEN('LEVEL','LINE '||l_line_ind);
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVPPYB: Pending Payment Authorization hold  has been applied on order line.', 3);
      END IF;
    END IF;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- bug 4339864
  IF l_debug_level  > 0 THEN
    OE_DEBUG_PUB.ADD(' Holds success ' , 3);
    OE_DEBUG_PUB.ADD(' About to Issue COMMIT', 3);
  END IF;

  COMMIT;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLIED VERIFY HOLD ON LINE ID:' || P_LINE_ID ) ;
  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Verify_Line_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Apply_Verify_Line_Hold_Commit;

Function CHECK_MANUAL_RELEASED_HOLDS (
 p_calling_action    IN   VARCHAR2,
 p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
 p_header_id         IN   NUMBER,
 p_line_id	     IN   NUMBER DEFAULT  NULL
                                  )
RETURN varchar2
IS
 l_hold_release_id           number;
 l_dummy                     VARCHAR2(1);
 l_manual_hold_exists        varchar2(1) := 'N';
 l_released_rec_exists       varchar2(1) := 'Y';
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'CHECKING FOR MANUALLY RELEASED HOLDS ON HEADER_ID'|| TO_CHAR ( P_HEADER_ID ) ) ;
                     END IF;

 if p_calling_action = 'SHIPPING' then
    IF p_line_id IS NULL THEN
      BEGIN
        SELECT NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES s
       WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID IS NULL
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NO RELEASED RECORD FOR CREDIT CHECK HOLDS' ) ;
          END IF;
          l_released_rec_exists := 'N';
        WHEN OTHERS THEN
          null;
      END;

    ELSE
      -- p_line_id is not null, this is line level credit check.
      BEGIN
        SELECT NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES s
       WHERE H.HOLD_SOURCE_ID = S.HOLD_SOURCE_ID
         AND H.HEADER_ID = p_header_id
         AND H.LINE_ID = p_line_id
         AND H.HOLD_RELEASE_ID IS NOT NULL
         AND S.HOLD_ID = p_hold_id
         AND S.HOLD_ENTITY_CODE = 'O'
         AND S.HOLD_ENTITY_ID = p_header_id
         AND S.RELEASED_FLAG ='Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'NO RELEASED RECORD FOR CREDIT CHECK HOLDS' ) ;
          END IF;
          l_released_rec_exists := 'N';
        WHEN OTHERS THEN
          null;
      END;

    END IF;   -- end if p_line_id is null

    IF l_released_rec_exists = 'Y' THEN
       BEGIN
         select 'Y'
           into l_manual_hold_exists
           FROM OE_HOLD_RELEASES
          WHERE HOLD_RELEASE_ID = l_hold_release_id
            AND RELEASE_REASON_CODE <> 'PASS_CREDIT'
            AND CREATED_BY <> 1;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NO MANUALLY RELEASED CREDIT HOLDS' ) ;
           END IF;
           l_manual_hold_exists := 'N';
         WHEN OTHERS THEN
          null;
       END;
    END IF;
 end if;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'MANUAL HOLDS EXISTS:' || L_MANUAL_HOLD_EXISTS ) ;
 END IF;
 return l_manual_hold_exists;

End CHECK_MANUAL_RELEASED_HOLDS;

PROCEDURE Release_Credit_Check_Hold
(  p_header_id       IN   NUMBER
,  p_invoice_to_org_id  IN NUMBER DEFAULT NULL
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_hold_entity_id    NUMBER := p_header_id;
l_hold_id                 NUMBER;
l_hold_exists       VARCHAR2(1);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(30);
l_release_reason    VARCHAR2(30);
l_hold_source_rec   OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_result   VARCHAR2(30);

CURSOR c_billto_lines IS
  SELECT line_id
    FROM oe_order_lines
   WHERE header_id = p_header_id
    AND  invoice_to_org_id = nvl(p_invoice_to_org_id, invoice_to_org_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN RELEASE CREDIT CHECK HOLD' ) ;
  END IF;

 FOR C1 in c_billto_lines
 LOOP
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'OEXPVPMB:CHECKING CREDIT CHECK HOLD FOR HEADER/LINE ID : ' || TO_CHAR ( P_HEADER_ID ) || '/' || TO_CHAR ( C1.LINE_ID ) ) ;
                 END IF;

    l_hold_id := 1 ; -- Credit Checking Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;

  OE_HOLDS_PUB.Check_Holds
                ( p_api_version    => 1.0
                , p_header_id      => p_header_id
                , p_line_id        => C1.line_id
                , p_hold_id        => 1
                , p_entity_code    => 'O'
                , p_entity_id      => p_header_id
                , x_result_out     => l_hold_result
                , x_msg_count      => l_msg_count
                , x_msg_data       => l_msg_data
                , x_return_status  => l_return_status
                );

    IF l_hold_result = FND_API.G_TRUE THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CHECK HOLD ON HEADER ID:' || TO_CHAR ( P_HEADER_ID ) || '/' || TO_CHAR ( C1.LINE_ID ) , 1 ) ;
              END IF;

      l_hold_source_rec.hold_id          := 1;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;
      l_hold_source_rec.line_id := C1.line_id;


      l_hold_release_rec.release_reason_code := 'PASS_CREDIT';

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        fnd_message.set_name('ONT', 'OE_CC_HOLD_REMOVED');
        oe_msg_pub.add;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

  END LOOP;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Release_Credit_Check_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Release_Credit_Check_Hold;


/*----------------------------------------------------------------------
Applies a Credit Check Failure Hold
----------------------------------------------------------------------*/
PROCEDURE Apply_Credit_Check_Hold
(   p_header_id       IN   NUMBER
,   p_invoice_to_org_id         IN   NUMBER
,   p_hold_id         IN   NUMBER
,   p_calling_action  IN   VARCHAR2
,   p_delayed_request IN   VARCHAR2
,   p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_hold_exists     VARCHAR2(1) := NULL ;
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(30);
l_hold_result   VARCHAR2(30);
l_attribute         VARCHAR2(30);
l_line_number       NUMBER;
l_hold_source_rec   OE_Holds_PVT.Hold_Source_REC_type;

l_apply_hold      VARCHAR2(1) := 'N';

CURSOR c_billto_lines IS
  SELECT line_id, line_number
    FROM oe_order_lines
   WHERE header_id = p_header_id
    AND  invoice_to_org_id = p_invoice_to_org_id
    AND  open_flag = 'Y';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN APPLY CREDIT CHECK HOLDS' ) ;
  END IF;

 FOR C1 in c_billto_lines
 LOOP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: HEADER/LINE ID : '|| P_HEADER_ID || '/' || C1.LINE_ID ) ;
          END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HOLD ID : '||P_HOLD_ID ) ;
  END IF;

  -- If the call was made from a delayed request, always apply hold.
  IF NVL(p_delayed_request, FND_API.G_FALSE) = FND_API.G_TRUE THEN
    l_apply_hold := 'Y';
  ELSE
    IF CHECK_MANUAL_RELEASED_HOLDS (
               p_calling_action    => p_calling_action,
               p_hold_id           => 1,
               p_header_id         => p_header_id,
               p_line_id           => C1.line_id
                                 ) = 'N' then
      l_apply_hold := 'Y';
    END IF;
  END IF;

  -- Check if Hold already exists on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECK IF HOLD ALREADY APPLIED' ) ;
  END IF;
  --
    OE_HOLDS_PUB.Check_Holds
                ( p_api_version    => 1.0
                , p_header_id      => p_header_id
                , p_line_id        => C1.line_id
                , p_hold_id        => 1
                , p_entity_code    => 'O'
                , p_entity_id      => p_header_id
                , x_result_out     => l_hold_result
                , x_msg_count      => l_msg_count
                , x_msg_data       => l_msg_data
                , x_return_status  => l_return_status
                );

  -- Return with Success if this Hold Already exists on the order
  IF l_hold_result = FND_API.G_TRUE THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'OEXPVPMB: HOLD ALREADY APPLIED ON HEADER/LINE ID:' || P_HEADER_ID || '/' || C1.LINE_ID ) ;
           END IF;
    -- IF One line is on Hold, other lines will NOT go on hold
    -- because of this Return.
    --
    --RETURN ;
    l_apply_hold := 'N';
  END IF ;

  -- Apply hold only if the flag was set to "Yes" above.
  IF l_apply_hold = 'Y' THEN
    -- Apply Credit Check  Hold on Header
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'OEXPVPMB: APPLYING CREDIT CHECK HOLD ON HEADER/LINE ID:' || P_HEADER_ID || '/' || C1.LINE_ID ) ;
              END IF;

    l_hold_source_rec.hold_id         := p_hold_id ;  -- Requested Hold
    l_hold_source_rec.hold_entity_code:= 'O';         -- Order Hold
    l_hold_source_rec.hold_entity_id  := p_header_id; -- Order Header
    l_hold_source_rec.line_id         := C1.line_id;

    OE_Holds_PUB.Apply_Holds
                  (   p_api_version       =>      1.0
                  ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                  ,   p_hold_source_rec   =>      l_hold_source_rec
                  ,   x_msg_count         =>      l_msg_count
                  ,   x_msg_data          =>      l_msg_data
                  ,   x_return_status     =>      l_return_status
                  );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
       --fnd_message.set_name('ONT', 'OE_CC_HOLD_APPLIED');
         l_attribute := 'Credit Check';
         l_line_number := C1.line_number;
         fnd_message.set_name('ONT','OE_HLD_APPLIED_LINE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_attribute);
         FND_MESSAGE.SET_TOKEN('LINE_NUMBER',l_line_number);
         oe_msg_pub.add;

    END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPVPMB: APPLIED CREDIT CHECK HOLD ON HEADER/LINE ID:' || P_HEADER_ID || '/' || C1.LINE_ID ) ;
         END IF;
  END IF; -- IF apply hold "Yes"
END LOOP;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Credit_Check_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Apply_Credit_Check_Hold;

PROCEDURE  Credit_Check_line_level
                    ( p_header_id      	IN 	NUMBER
                    , p_calling_action  IN   	VARCHAR2
                    , p_delayed_request IN      VARCHAR2
                    , p_msg_count       OUT NOCOPY /* file.sql.39 change */	NUMBER
                    , p_msg_data        OUT NOCOPY /* file.sql.39 change */	VARCHAR2
                    , p_result_out      OUT NOCOPY /* file.sql.39 change */	VARCHAR2
                    , p_return_status 	OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
                    )
IS

l_calling_action    VARCHAR2(30) := p_calling_action;
l_epayment          VARCHAR2(1);
l_header_rec        OE_Order_PUB.Header_Rec_Type;
l_msg_count         NUMBER        := 0 ;
l_msg_data          VARCHAR2(2000):= NULL ;
l_result_out        VARCHAR2(30)   := NULL ;
l_return_status     VARCHAR2(30)   := NULL ;

CURSOR C_credit_check_lines IS
 SELECT invoice_to_org_id
   FROM oe_order_lines
  where header_id = l_header_rec.header_id
   group by invoice_to_org_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_VERIFY_PAYMENT_PUB.CREDIT_CHECK_LINE_LEVEL.' , 1 ) ;
    END IF;

    -- Query the Order Header
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE QUERYING HEADER ID : '||P_HEADER_ID ) ;
    END IF;
    --
    OE_Header_UTIL.Query_Row
	(p_header_id		=> p_header_id
	,x_header_rec		=> l_header_rec
	);

    FOR C1 in C_credit_check_lines LOOP
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'OEXPVPMB LINE LEVEL: HEADERID/INVOICETOORGID:' || L_HEADER_REC.HEADER_ID || '/' || C1.INVOICE_TO_ORG_ID , 1 ) ;
               END IF;

      OE_Credit_PUB.Check_Available_Credit_Line
                    ( p_header_id          => l_header_rec.header_id
                    , p_invoice_to_org_id  => C1.invoice_to_org_id
                    , p_calling_action     => l_calling_action
                    , p_msg_count          => l_msg_count
                    , p_msg_data           => l_msg_data
                    , p_result_out         => l_result_out
                    , p_return_status      => l_return_status
                    );

                           IF l_debug_level  > 0 THEN
                               oe_debug_pub.add(  'OEXPVPMB: AFTER CALLING CREDIT REQUEST API:' || L_RESULT_OUT ) ;
                           END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Release Any existing CC Holds
                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'OEXPVPMB LINE LEVEL: RELEASING CREDIT CARD ' || 'HOLDS-AFTER CREDITCHECKING' ) ;
                          END IF;
    --
    OE_Verify_Payment_PUB.Release_Verify_Hold
                  ( p_header_id     => l_header_rec.header_id
                  , p_epayment_hold => 'Y' -- We want to Release Credit Card Hol
                  , p_msg_count     => l_msg_count
                  , p_msg_data      => l_msg_data
                  , p_return_status => l_return_status
                  );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check the Out Result of Credit Checking
    IF l_result_out = 'PASS' THEN

         -- Release Any existing Credit Checking Holds
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB LINE LEVEL: RELEASING CREDIT CHECKING HOLDS' ) ;
      END IF;
         --
         OE_Verify_Payment_PUB.Release_Credit_Check_Hold
                                ( p_header_id     => l_header_rec.header_id
                                 , p_invoice_to_org_id  => C1.invoice_to_org_id
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   ELSE -- Failed

            -- Apply Credit Checking Failure Hold on the Order
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB LINE LEVEL: APPLYING CREDIT CHECKING FAILURE HOLD' ) ;
        END IF;
          --
        OE_Verify_Payment_PUB.Apply_Credit_Check_Hold
                      ( p_header_id     => l_header_rec.header_id
                      , p_invoice_to_org_id  => C1.invoice_to_org_id -- XX
                      , p_hold_id       => 1
                      , p_calling_action  => l_calling_action
                      , p_delayed_request => p_delayed_request
                      , p_msg_count     => l_msg_count
                      , p_msg_data      => l_msg_data
                      , p_return_status => l_return_status
                      );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

   END IF; -- IF Result Out of Credit Checking
  END LOOP;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_VERIFY_PAYMENT_PUB.CREDIT_CHECK_LINE_LEVEL.' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_Check_Line_Level'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Credit_Check_line_level;

/*--------------------------------------------------------------------------
Called By Booking, Pre Ship or Purchase Release Processing.
 Checks if Electronic Payment is associated to the Order.
 IF Yes THEN
   Calls OE_Verify_Payment_PUB.Payment_Request Authorization
 ELSE
   Calls OE_Credit_PUB.OE_Check_Available_Credit for Credit Limit Checking

  1961228 - Multi currency credit checking changes
            As part of the code swict design logic, the verify_payment
            will call the new Multi currency Credit checking Engine API's
            for credit checking.
            The switch will be governed by a hidded profile that will
            be seeded as MULTI with the patch
            The existing OM profile to check for line level
            ( calculating Exposure onlide from transaction tables )
             will still be
            checked to avoid any change of behavior for customers
            already using the feature
----------------------------------------------------------------------------*/
PROCEDURE Verify_Payment
(  p_header_id       IN   NUMBER
,  p_calling_action  IN   VARCHAR2
,  p_delayed_request IN   VARCHAR2
--R12 CVV2
--comm rej,  p_reject_on_auth_failure IN VARCHAR2 DEFAULT NULL
--comm rej,  p_reject_on_risk_failure IN VARCHAR2 DEFAULT NULL
,  p_risk_eval_flag  IN VARCHAR2 DEFAULT  NULL --'Y'
--R12 CVV2
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_calling_action    VARCHAR2(30) := p_calling_action;
l_rule_defined      VARCHAR2(1);
l_epayment          VARCHAR2(1);
l_header_rec        OE_Order_PUB.Header_Rec_Type;
l_msg_count         NUMBER        := 0 ;
l_msg_data          VARCHAR2(2000):= NULL ;
l_result_out        VARCHAR2(30)   := NULL ;
l_return_status     VARCHAR2(30)   := NULL ;
l_prepayment	    VARCHAR2(1);
l_payment_server_order_num	VARCHAR2(80);
l_approval_code			VARCHAR2(80);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN VERIFY PAYMENT MAIN' , 1 ) ;
  END IF;
  G_credit_check_rule_id := NULL ;

  OE_Verify_Payment_PUB.G_init_calling_action := p_calling_action;   --ER#7479609

  -- Query the Order Header
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE QUERYING HEADER ID : '||P_HEADER_ID , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: P_CALLING_ACTION => '|| P_CALLING_ACTION , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: L_CALLING_ACTION => '|| L_CALLING_ACTION , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: P_DELAYED_REQUEST => '|| P_DELAYED_REQUEST , 1 ) ;
  END IF;
  --
  OE_Header_UTIL.Query_Row
	(p_header_id		=> p_header_id
	,x_header_rec		=> l_header_rec
	);

  -- Verify Payment is N/A for RMAs, return if Order Category is 'RETURN'
  --
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER QUERY ORDER CATEGORY => '|| L_HEADER_REC.ORDER_CATEGORY_CODE ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'AFTER QUERY BOOKED FLAG => '|| L_HEADER_REC.BOOKED_FLAG ) ;
          END IF;

  IF l_header_rec.order_category_code = 'RETURN' THEN
    RETURN;
  END IF;

  -- Check if Verify Payment Call was made from Delayed Request
  -- Because if call was made from a delayed request, we need to
  -- VOID the Current Credit Card Authorization if any exists.
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING CALL FROM DELAYED REQUEST OR NOT' ) ;
  END IF;
  --
  IF NVL(p_delayed_request, FND_API.G_FALSE) = FND_API.G_TRUE THEN

    /*
    ** Fix for 1967295:
    ** As VOID has been de-supported by iPayment, commenting
    ** following code which was used to VOID existing Trxns.
    **
    -- VOID only if the Approval Date exist
    OE_DEBUG_PUB.ADD('OEXPVPMB: Before checking if APPROVAL DATE is NOT NULL');
    --
    **
    ** Commented as this will not be true if the approval code
    **  itself is being updated to NULL
    IF l_header_rec.credit_card_approval_code is NOT NULL THEN
    **

    -- Check approval date(instead of approval code) to find out
    -- if we should really proceed with VOID. This  is a must as
    -- without this IF condition every time a delayed request is
    -- logged application will  try to void  irrespective of the
    -- fact that it is really required.Approval date will be not
    -- null even if approval code has been updated to null.
    IF l_header_rec.credit_card_approval_date is NOT NULL THEN

      -- Call the Payment Request API
      OE_DEBUG_PUB.ADD('OEXPVPMB: Before Calling Payment Request API For VOIDAUTHONLY');
      --
      OE_Verify_Payment_PUB.Payment_Request
                                ( p_header_rec     => l_header_rec
                                , p_trxn_type      => 'VOIDAUTHONLY'
                                , p_msg_count      => l_msg_count
                                , p_msg_data       => l_msg_data
                                , p_result_out     => l_result_out
                                , p_return_status  => l_return_status
                                );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Requery Order Header just in case it was updated during VOID.
      OE_DEBUG_PUB.ADD('OEXPVPMB: Requerying Order Header After Void : ');
      --
      OE_Header_UTIL.Query_Row
	(p_header_id		=> p_header_id
	,x_header_rec		=> l_header_rec
	);

    END IF;
    */

    -- If the Order is UnBooked then return
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING IF THE ORDER IS UNBOOKED' ) ;
    END IF;
    --
    IF l_header_rec.booked_flag = 'N' THEN
      RETURN;

    ELSE
	 -- Call Which_Rule function to find out Which Rule to Apply
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING WHICH RULE ' ) ;
      END IF;
      --

       -- Commenting code as the credit check rule will be BOOKING
       -- for order updates as well 2412678
       -- New fix: code was uncommented as part of Bug # 3292283.

       l_calling_action := OE_Verify_Payment_PUB.Which_Rule(p_header_id => p_header_id);

    END IF;

  END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'L_CALLING_ACTION => '|| L_CALLING_ACTION ) ;
            END IF;


    -- Begin of the change for Prepayment.
    -- determine whether or not this is a prepaid order
    l_prepayment := OE_PrePayment_UTIL.is_prepaid_order(l_header_rec);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: THE PREPAYMENT_FLAG FOR THIS ORDER IS: '||L_PREPAYMENT , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: THE CALLING_ACTION FOR THIS ORDER IS: '||L_CALLING_ACTION , 3 ) ;
    END IF;

    IF l_prepayment = 'Y' AND l_header_rec.booked_flag = 'Y'
       AND NOT OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN

      -- do not need to process prepayment during or after shipping.
      IF l_calling_action IN ( 'SHIPPING', 'PACKING' , 'PICKING' )
      THEN
         RETURN;
      END IF;

       -- if this is a full prepaid order.
       OE_PrePayment_PVT.Process_PrePayment_Order
               ( p_header_rec           => l_header_rec
                , p_calling_action      => p_calling_action
                , p_delayed_request	=> p_delayed_request
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , x_return_status       => l_return_status
                );

        p_return_status := l_return_status;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: OUT OF OE_PREPAYMENT_PVT' , 1 ) ;
        END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'X_RETURN_STATUS = ' || L_RETURN_STATUS , 1 ) ;
        END IF;

        -- control returned from Verify_payment for Prepayment to
        -- avoid continuation of code through the existing code flow
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' RETURN FROM VERIFY_PAYMENT FOR PREPAYMENT' , 1 ) ;
        END IF;

        RETURN ;

     END IF;
     -- end of the change for Prepayment.


  -- Check if Calling action is being passed as Null.
  -- This will be the case only if Credit Card Auth
  -- has been Invoked On-Line. And if that's the case
  -- We don't need to check for any rules.
  IF l_calling_action IS NOT NULL
    AND l_header_rec.booked_flag = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RULE TO BE USED IS : '|| L_CALLING_ACTION ) ;
    END IF;

    -- Check the Rule to Apply
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'G_CREDIT_CHECK_RULE_ID => '|| G_CREDIT_CHECK_RULE_ID ) ;
    END IF;
    G_credit_check_rule_id := NULL ;

    -- check rule defined here is multiple payment is not enabled, if
    -- enabled, the check has been moved to OE_Prepayment_PVT.Process_Payments.
    IF NOT OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING IF THE RULE IS DEFINED OR NOT' ) ;
      END IF;
      l_rule_defined := OE_Verify_Payment_PUB.Check_Rule_Defined
				( p_header_rec     => l_header_rec
				, p_calling_action => l_calling_action
				) ;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OEXPVPMB: OUT OF RULE DEFINED : '|| L_RULE_DEFINED);
        oe_debug_pub.add('G_CREDIT_CHECK_RULE_ID => ' || G_CREDIT_CHECK_RULE_ID);
      END IF;

      -- If NO Rule defined for the calling action then return
      -- Modified the condition so that only return when multiple
      -- payments is not enabled. If multiple payments is enabled,
      -- we don't check the rule for prepayments. This logic has been
      -- moved to OE_Prepayment_PVT.
      IF l_rule_defined = 'N' THEN
         RETURN;
      END IF;
    END IF;

  ELSE

    -- Fix for 1967295:
    -- Control will come into this ELSE condition when call is being
    -- made from "Authorize Payment" action. Setting CC Approval Code
    -- to NULL so that the Order is always re-authorized.
    l_header_rec.credit_card_approval_code := NULL;

  END IF;


  -- Check for Electronic Payment
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING FOR ELECTRONIC PAYMENT' , 1 ) ;
  END IF;
  --
  l_epayment := OE_Verify_Payment_PUB.Is_Electronic_Payment( l_header_rec ) ;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IS IT AN ELECTRONIC PAYMENT : '|| L_EPAYMENT ) ;
  END IF;


IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED THEN
  -- new code for Pack J, if multiple payments is enabled
  -- Credit card authorization and prepayment collection
  -- are all coded in OE_PREPAYMENT_PVT.Process_Payments
  -- from Pack J if multiple payments is enabled.

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'start processing multiple payments.',3 ) ;
       END IF;

       OE_PREPAYMENT_PVT.Process_Payments(
             	       p_header_id 	=> l_header_rec.header_id,
                       p_calling_action => l_calling_action,
                       p_amount         => null,
                       p_delayed_request=> p_delayed_request,
                      --comm rej p_reject_on_auth_failure => p_reject_on_auth_failure,
                      --comm rej p_reject_on_risk_failure => p_reject_on_risk_failure,
                       p_risk_eval_flag => p_risk_eval_flag,
                       x_msg_data	=> l_msg_data,
                       x_msg_count	=> l_msg_count,
                       x_return_status	=> l_return_status);

       OE_MSG_PUB.Count_And_Get( p_count => p_msg_count
                                ,p_data  => p_msg_data
                               );

       IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPVPMB: after calling Process_Payments, returns tatus is: '||l_return_status, 3 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       RETURN;
       -- end of multiple payments processing.

       -- comment out the following code, as credit checking
       -- is now called from OE_Prepayment_PVT.process_payments
       -- if multiple payments is enabled.
       /*
       -- Check rule defined before going to credit checking engine.
       l_rule_defined := OE_Verify_Payment_PUB.Check_Rule_Defined
				( p_header_rec     => l_header_rec
				, p_calling_action => l_calling_action
				) ;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXVPPYB: RULE DEFINED FOR AUTHORIZATION: '|| L_RULE_DEFINED ) ;
      END IF;

      IF l_rule_defined = 'N' THEN
         return;
      END IF;


    ------------- Begin Multi currency credit checking changes ----
    ----------------------------------------------------------------
    -- The credit checking code
     -- ( NON- Electronic, NON iPayment )
    -- code is now maintained, developed, enhanced
    --  and Bug fixed in the new MUlti currency API's.
    -- including customers prior to OM patch set G will
    -- get the new  API's

    --  For clarifications, please contact
    --  Global Manufacturing
    ----------------------------------------------------------------

    -- BUG 2298782 .
    -- Remove check for OE_CREDIT_CHECK_API_FLOW

    BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: NON ELECTRONIC PAYMENT ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEGIN CHECK FOR MCC CODE SWITCH ' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO CHECK FOR OE_CREDIT_CHECK_API_FLOW ' , 1 ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_CALLING_ACTION = '|| P_CALLING_ACTION , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_CALLING_ACTION = '|| L_CALLING_ACTION , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_DELAYED_REQUEST = '|| P_DELAYED_REQUEST , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_HEADER_ID = '|| P_HEADER_ID , 1 ) ;
      END IF;


      -- lkxu 10/22/02: commented out the check for profile option,
      -- as this profile option is not being used any more.
      -- IF NVL(Fnd_Profile.Value('OE_CREDIT_CHECKING_LEVEL'),'ORDER')
      --    = 'ORDER' THEN
        BEGIN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB:INTO MULTI CREDIT CHECKING FLOW ' , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_CALLING_ACTION = '|| L_CALLING_ACTION , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'P_HEADER_ID => '|| P_HEADER_ID ) ;
          END IF;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'P_DELAYED_REQUEST => '|| P_DELAYED_REQUEST ) ;
                        END IF;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'G_CREDIT_CHECK_RULE_ID => ' || G_CREDIT_CHECK_RULE_ID ) ;
                    END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: CALL OE_CREDIT_ENGINE_GRP' , 1 ) ;
          END IF;

          OE_Credit_Engine_GRP.Credit_check_with_payment_typ
           (  p_header_id            => p_header_id
           ,  p_calling_action       => l_calling_action
           ,  p_delayed_request      => p_delayed_request
           ,  p_credit_check_rule_id => G_credit_check_rule_id
           ,  x_msg_count            => p_msg_count
           ,  x_msg_data             => p_msg_data
           ,  x_return_status        => p_return_status
           );

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: OUT OF OE_CREDIT_ENGINE_GRP' , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'X_RETURN_STATUS = ' || P_RETURN_STATUS , 1 ) ;
          END IF;

          -- Control returned out of Verify_payment to avoid
          -- continuation of code through the existing code flow
          G_credit_check_rule_id := NULL ;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: RETURN FROM VERIFY_PAYMENT ' , 1 ) ;
          END IF;
          RETURN ;
        END ;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: EXCEPTION - CONTROL NOT RETURNED OUT ' , 1 ) ;
        END IF;

    --  END IF; -- End MCC profile IF
    END ; -- End MCC Block
    */

    --------------------------------------------------------------------
    ----------------- End Multi currency credit checking code changes --
    ---------------------------------------------------------------------

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: IN SINGLE CREDIT CHECKING' , 1 ) ;
    END IF;
    -- The following Check_Available_Credit is replaced by MULTI
    -- must not be supported

    -- Call the Credit Checking API
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING CREDIT CHECKING API' ) ;
    END IF;
    --

    -- lkxu, call different code according to the profile option.
    -- No need to check this profile option as it is not being used any more.
    -- IF Nvl(Fnd_Profile.Value('OE_CREDIT_CHECKING_LEVEL'),'ORDER') = 'ORDER' THEN
    -- calling order level credit checking.

    OE_Credit_PUB.Check_Available_Credit
                    ( p_header_id      => l_header_rec.header_id
                    , p_calling_action => l_calling_action
                    , p_msg_count      => l_msg_count
                    , p_msg_data       => l_msg_data
                    , p_result_out     => l_result_out
                    , p_return_status  => l_return_status
                    );


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: AFTER CALLING CREDIT REQUEST API' ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Check the Out Result of Credit Checking
    IF l_result_out = 'PASS' THEN

	 -- Release Any existing Credit Checking Holds
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CHECKING HOLDS' ) ;
      END IF;
	 --
	 OE_Verify_Payment_PUB.Release_Verify_Hold
                                ( p_header_id     => l_header_rec.header_id
                                 , p_epayment_hold => 'N' -- We want to Release Credit Checking Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE -- Failed
      IF CHECK_MANUAL_RELEASED_HOLDS (
                   p_calling_action    => l_calling_action,
                   p_hold_id           => 1,
                   p_header_id         => l_header_rec.header_id
                                     ) = 'N' then
	    -- Apply Credit Checking Failure Hold on the Order
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPVPMB: APPLYING CREDIT CHECKING FAILURE HOLD' ) ;
         END IF;
          --
	    OE_Verify_Payment_PUB.Apply_Verify_Hold
                            ( p_header_id     => l_header_rec.header_id
                            , p_hold_id       => 1
                            , p_msg_count     => l_msg_count
                            , p_msg_data      => l_msg_data
                            , p_return_status => l_return_status
                             );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	        RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
              fnd_message.set_name('ONT', 'OE_CC_HOLD_APPLIED');
     	    oe_msg_pub.add;
         END IF;
      END IF; -- CHECK_MANUAL_RELEASED_HOLDS

    END IF; -- IF Result Out of Credit Checking

     --  ELSE
     -- lkxu, perform line leve credit checking according the profile option.
     -- 10/22/02: this part of code is not needed as MCC has this line level credit
     -- checking.
     /***
      Credit_Check_line_level
                    ( p_header_id      => l_header_rec.header_id
                    , p_calling_action => l_calling_action
                    , p_delayed_request=> p_delayed_request
                    , p_msg_count      => l_msg_count
                    , p_msg_data       => l_msg_data
                    , p_result_out     => l_result_out
                    , p_return_status  => l_return_status
                    );


    END IF;   -- IF level of credit checking is ORDER
    ***/
ELSE
  -- retain the original code before Pack J if multiple payments
  -- is not enabled.
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'start processing verify payment without multiple payments.',3 ) ;
  END IF;

  IF l_epayment = 'Y' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: IN ELECTRONIC PAYMENT' ) ;
    END IF;

    -- Call the Electronic Payment Request API
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PAYMENT REQUEST API FOR AUTHONLY' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Payment_Request
                                ( p_header_rec    => l_header_rec
                                , p_trxn_type     => 'AUTHONLY'
                                , p_msg_count     => l_msg_count
                                , p_msg_data      => l_msg_data
                                , p_result_out    => l_result_out
                                , p_return_status => l_return_status
                                );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: AFTER CALLING PAYMENT REQUEST API' ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If No Error Occurred in Payment Request, Release any existing
    -- Credit Checking Holds This will ensure that for Elctronic Payment
    -- only  Credit Card Holds, if any, remain applied.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CHECKING HOLD' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Release_Verify_Hold
                               ( p_header_id     => l_header_rec.header_id
                               , p_epayment_hold => 'N' -- We want to Release Credit Check Hold
                               , p_msg_count     => l_msg_count
                               , p_msg_data      => l_msg_data
                               , p_return_status => l_return_status
                               );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Check the Out Result of Payment Request
    IF l_result_out = 'PASS' THEN

	 -- Release Any existing CC Holds
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CARD HOLDS' ) ;
      END IF;
	 --
	 OE_Verify_Payment_PUB.Release_Verify_Hold
                                 ( p_header_id     => l_header_rec.header_id
                                 , p_epayment_hold => 'Y' -- We want to Release Credit Card Holds
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF l_result_out = 'RISK' THEN

	 -- Apply Risk Hold on the Order
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: APPLYING CC RISK HOLD' ) ;
      END IF;
	 --
	 OE_Verify_Payment_PUB.Apply_Verify_Hold
                                 ( p_header_id     => l_header_rec.header_id
                                 , p_hold_id       => 12 -- Seed Id for CC Risk Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE -- Failed

	 -- Apply CC Auth Failure Hold on the Order
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: APPLYING CC AUTH FAILURE HOLD' ) ;
      END IF;
	 --
	 OE_Verify_Payment_PUB.Apply_Verify_Hold
                                 ( p_header_id     => l_header_rec.header_id
                                 , p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; -- IF Result Out of Payment Request

  ELSE -- It's Not An Electronic Payment

    ------------- Begin Multi currency credit checking changes ----
    ----------------------------------------------------------------
    -- The credit checking code
     -- ( NON- Electronic, NON iPayment )
    -- code is now maintained, developed, enhanced
    --  and Bug fixed in the new MUlti currency API's.
    -- including customers prior to OM patch set G will
    -- get the new  API's

    --  For clarifications, please contact
    --  Global Manufacturing
    ----------------------------------------------------------------

    -- BUG 2298782 .
    -- Remove check for OE_CREDIT_CHECK_API_FLOW

    BEGIN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: NON ELECTRONIC PAYMENT ' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEGIN CHECK FOR MCC CODE SWITCH ' , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO CHECK FOR OE_CREDIT_CHECK_API_FLOW ' , 1 ) ;
      END IF;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_CALLING_ACTION = '|| P_CALLING_ACTION , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'L_CALLING_ACTION = '|| L_CALLING_ACTION , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_DELAYED_REQUEST = '|| P_DELAYED_REQUEST , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'P_HEADER_ID = '|| P_HEADER_ID , 1 ) ;
      END IF;


      -- lkxu 10/22/02: commented out the check for profile option,
      -- as this profile option is not being used any more.
      -- IF NVL(Fnd_Profile.Value('OE_CREDIT_CHECKING_LEVEL'),'ORDER')
      --    = 'ORDER' THEN
        BEGIN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB:INTO MULTI CREDIT CHECKING FLOW ' , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'L_CALLING_ACTION = '|| L_CALLING_ACTION , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'P_HEADER_ID => '|| P_HEADER_ID ) ;
          END IF;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'P_DELAYED_REQUEST => '|| P_DELAYED_REQUEST ) ;
                        END IF;
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'G_CREDIT_CHECK_RULE_ID => ' || G_CREDIT_CHECK_RULE_ID ) ;
                    END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: CALL OE_CREDIT_ENGINE_GRP' , 1 ) ;
          END IF;

          OE_Credit_Engine_GRP.Credit_check_with_payment_typ
           (  p_header_id            => p_header_id
           ,  p_calling_action       => l_calling_action
           ,  p_delayed_request      => p_delayed_request
           ,  p_credit_check_rule_id => G_credit_check_rule_id
           ,  x_msg_count            => p_msg_count
           ,  x_msg_data             => p_msg_data
           ,  x_return_status        => p_return_status
           );

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: OUT OF OE_CREDIT_ENGINE_GRP' , 1 ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'X_RETURN_STATUS = ' || P_RETURN_STATUS , 1 ) ;
          END IF;

          -- Control returned out of Verify_payment to avoid
          -- continuation of code through the existing code flow
          G_credit_check_rule_id := NULL ;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: RETURN FROM VERIFY_PAYMENT ' , 1 ) ;
          END IF;
          RETURN ;
        END ;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: EXCEPTION - CONTROL NOT RETURNED OUT ' , 1 ) ;
        END IF;

    --  END IF; -- End MCC profile IF
    END ; -- End MCC Block

    --------------------------------------------------------------------
    ----------------- End Multi currency credit checking code changes --
    ---------------------------------------------------------------------

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: IN SINGLE CREDIT CHECKING' , 1 ) ;
    END IF;
    -- The following Check_Available_Credit is replaced by MULTI
    -- must not be supported

    -- Call the Credit Checking API
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING CREDIT CHECKING API' ) ;
    END IF;
    --

    -- lkxu, call different code according to the profile option.
    -- No need to check this profile option as it is not being used any more.
    -- IF Nvl(Fnd_Profile.Value('OE_CREDIT_CHECKING_LEVEL'),'ORDER') = 'ORDER' THEN
    -- calling order level credit checking.

    OE_Credit_PUB.Check_Available_Credit
                    ( p_header_id      => l_header_rec.header_id
                    , p_calling_action => l_calling_action
                    , p_msg_count      => l_msg_count
                    , p_msg_data       => l_msg_data
                    , p_result_out     => l_result_out
                    , p_return_status  => l_return_status
                    );


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: AFTER CALLING CREDIT REQUEST API' ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Check the Out Result of Credit Checking
    IF l_result_out = 'PASS' THEN

	 -- Release Any existing Credit Checking Holds
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CHECKING HOLDS' ) ;
      END IF;
	 --
	 OE_Verify_Payment_PUB.Release_Verify_Hold
                                ( p_header_id     => l_header_rec.header_id
                                 , p_epayment_hold => 'N' -- We want to Release Credit Checking Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE -- Failed
      IF CHECK_MANUAL_RELEASED_HOLDS (
                   p_calling_action    => l_calling_action,
                   p_hold_id           => 1,
                   p_header_id         => l_header_rec.header_id
                                     ) = 'N' then
	    -- Apply Credit Checking Failure Hold on the Order
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPVPMB: APPLYING CREDIT CHECKING FAILURE HOLD' ) ;
         END IF;
          --
	    OE_Verify_Payment_PUB.Apply_Verify_Hold
                            ( p_header_id     => l_header_rec.header_id
                            , p_hold_id       => 1
                            , p_msg_count     => l_msg_count
                            , p_msg_data      => l_msg_data
                            , p_return_status => l_return_status
                             );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	        RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
              fnd_message.set_name('ONT', 'OE_CC_HOLD_APPLIED');
     	    oe_msg_pub.add;
         END IF;
      END IF; -- CHECK_MANUAL_RELEASED_HOLDS

    END IF; -- IF Result Out of Credit Checking

     --  ELSE
     -- lkxu, perform line leve credit checking according the profile option.
     -- 10/22/02: this part of code is not needed as MCC has this line level credit
     -- checking.
     /***
      Credit_Check_line_level
                    ( p_header_id      => l_header_rec.header_id
                    , p_calling_action => l_calling_action
                    , p_delayed_request=> p_delayed_request
                    , p_msg_count      => l_msg_count
                    , p_msg_data       => l_msg_data
                    , p_result_out     => l_result_out
                    , p_return_status  => l_return_status
                    );


    END IF;   -- IF level of credit checking is ORDER
    ***/

  END IF; -- IF Electronic Payment

END IF; -- if multiple payments is enabled.

  OE_MSG_PUB.Count_And_Get( p_count => p_msg_count
                          , p_data  => p_msg_data
                          );

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Verify_Payment'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Verify_Payment;

/*----------------------------------------------------------------------
Function to find out Rule to be applied for Verify Payment
----------------------------------------------------------------------*/
FUNCTION Which_Rule
(  p_header_id  IN  NUMBER )
RETURN VARCHAR2
IS
l_calling_action  VARCHAR2(30) := 'BOOKING';
l_ship_rule_count NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: INSIDE WHICH RULE' ) ;
  END IF;
  -- Count lines in the order with "SHIP_LINE" activity completed.
  /* For bug 1459546, performance issue, query has been tuned */

  /*
  ** Fix Bug 1723338 - Performance Issue
  **
  ** Commented following query because it accesses WF tables giving
  ** poor performance. Added new query to use shipped_quantity > 0
  ** on lines to find if at least one line in the order has shipped.

  SELECT COUNT(*)
  INTO   l_ship_rule_count
  FROM   WF_ITEM_ACTIVITY_STATUSES WIAS,
	    WF_PROCESS_ACTIVITIES WPA,
	    OE_ORDER_LINES OOL,
	    OE_ORDER_HEADERS OOH
  WHERE  WIAS.ITEM_TYPE            = 'OEOL'
  AND    WIAS.ACTIVITY_STATUS      = 'COMPLETE'
  AND    WIAS.PROCESS_ACTIVITY     = WPA.INSTANCE_ID
  AND    WPA.ACTIVITY_NAME         = 'SHIP_LINE'
  AND    WIAS.ITEM_KEY = TO_CHAR(OOL.LINE_ID)
  AND    OOL.HEADER_ID = OOH.HEADER_ID
  AND    OOH.HEADER_ID = p_header_id;
  */

  BEGIN
    SELECT 1 /* MOAC_SQL_CHANGE */
    INTO   l_ship_rule_count
    FROM   OE_ORDER_HEADERS_ALL OOH
    WHERE  OOH.HEADER_ID = p_header_id
    AND    EXISTS
          (SELECT 'Line Shipped'
           FROM   OE_ORDER_LINES OOL
           WHERE  OOL.HEADER_ID = OOH.HEADER_ID
           AND    NVL(OOL.SHIPPED_QUANTITY, 0) > 0
           AND LINE_CATEGORY_CODE <> 'RETURN' ); -- bug 7676011

    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   NULL;
  END;

  -- Count lines in  the order  for which "PURCHASE RELEASE ELIGIBLE"
  -- activity is completed and have a payment type code = CREDIT_CARD.
  /* For bug 1459546, performance issue, query has been tuned */

  /*
  ** Fix Bug 1723338 - Performance Issue
  **
  ** Commented following query because it accesses WF tables giving
  ** poor performance. Added new query to use drop ship sources table
  ** to find if at least one line in the order has purchase released.

  SELECT COUNT(*) + l_ship_rule_count
  INTO   l_ship_rule_count
  FROM   WF_ITEM_ACTIVITY_STATUSES WIAS,
	    WF_PROCESS_ACTIVITIES  WPA,
	    OE_ORDER_LINES OOL,
	    OE_ORDER_HEADERS OOH
  WHERE  WIAS.ITEM_TYPE           = 'OEOL'
  AND    WPA.ACTIVITY_NAME        = 'PURCHASE RELEASE ELIGIBLE'
  AND    WPA.INSTANCE_ID          = WIAS.PROCESS_ACTIVITY
  AND    WIAS.ACTIVITY_STATUS     = 'COMPLETE'
  AND    WIAS.ITEM_KEY            = TO_CHAR(OOL.LINE_ID)
  AND    OOH.PAYMENT_TYPE_CODE    = 'CREDIT_CARD'
  AND    OOL.HEADER_ID            = OOH.HEADER_ID
  AND    OOH.HEADER_ID            = p_header_id;
  */

  BEGIN
    SELECT 1 + l_ship_rule_count /* MOAC_SQL_CHANGE */
    INTO   l_ship_rule_count
    FROM   OE_ORDER_HEADERS_ALL OOH
    WHERE  OOH.PAYMENT_TYPE_CODE = 'CREDIT_CARD'
    AND    OOH.HEADER_ID         = p_header_id
    AND    EXISTS
          (SELECT 'Purchase Released'
           FROM   OE_ORDER_LINES  OOL, OE_DROP_SHIP_SOURCES ODSS
           WHERE  OOL.HEADER_ID  = OOH.HEADER_ID
           AND    ODSS.LINE_ID   = OOL.LINE_ID
           AND    ODSS.HEADER_id = OOL.HEADER_ID);
    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   NULL;
  END;

  IF l_ship_rule_count > 0 THEN
    l_calling_action := 'SHIPPING';
  ELSE
    l_calling_action := 'BOOKING';
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CALLING ACTION FROM WHICH_RULE ( AFTER 1723338 ) '||L_CALLING_ACTION , 1 ) ;
  END IF;
  RETURN (l_calling_action);

  EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Which_Rule;

/*-------------------------------------------------------------------
  Checks if the Rule defined by calling action has been setup at
  Order Type or not. If setup then returns 'Y' else returns 'N'.
---------------------------------------------------------------------*/
FUNCTION Check_Rule_Defined
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_calling_action  IN   VARCHAR2
) RETURN VARCHAR2
IS
l_credit_check_rule_id	NUMBER ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: INSIDE CHECK RULE DEFINED' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_CALLING_ACTION => '|| P_CALLING_ACTION ) ;
  END IF;

  G_credit_check_rule_id := NULL ;
  -- Entry Credit Check Rule.
  IF p_calling_action = 'BOOKING' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: SELECTING THE ENTRY RULE' ) ;
    END IF;
    --
    begin
/*7194250
      SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
      INTO   l_credit_check_rule_id
      FROM   oe_order_types_v
      WHERE  ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
    AND   ENTRY_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250


      OE_Verify_Payment_PUB.G_credit_check_rule := 'Ordering';  --ER#7479609

	 EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_credit_check_rule_id := 0;
    end;

  ELSE -- If not Use the Shipping Rule for all other calling Actions
    -- Fetch PICKING/PACKING/SHIPPING Credit check rules

    BEGIN
      IF p_calling_action = 'SHIPPING'
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: SELECTING THE SHIPPING RULE' ) ;
        END IF;
    --
        begin
/*7194250
          SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V
          WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
          SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
          WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
          AND   SHIPPING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
          AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250


      OE_Verify_Payment_PUB.G_credit_check_rule := 'Shipping';  --ER#7479609

	 EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_credit_check_rule_id := 0;
        end;
      END IF;

      IF p_calling_action = 'PACKING'
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: SELECTING THE PACKING RULE' ) ;
        END IF;
    --
        begin
/*7194250
          SELECT NVL(PACKING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V
          WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
          SELECT NVL(PACKING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
          WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
          AND   PACKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
          AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250


      OE_Verify_Payment_PUB.G_credit_check_rule := 'Packing';  --ER#7479609

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_credit_check_rule_id := 0;
        end;
      END IF;

      IF p_calling_action = 'PICKING'
      THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: SELECTING THE PICKING RULE' ) ;
        END IF;
    --
        begin
/*7194250
          SELECT NVL(PICKING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V
          WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
          SELECT NVL(PICKING_CREDIT_CHECK_RULE_ID, -1)
          INTO l_credit_check_rule_id
          FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
          WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
          AND   PICKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
          AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250


      OE_Verify_Payment_PUB.G_credit_check_rule := 'Picking/Purchase Release';  --ER#7479609

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_credit_check_rule_id := 0;
        end;
      END IF;
    END ;

  END IF; --- calling action

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_CREDIT_CHECK_RULE_ID => '|| L_CREDIT_CHECK_RULE_ID ) ;
  END IF;
  -- If no rule was found for the calling action
  -- Order is not subject to Payment Verification
  IF l_credit_check_rule_id > 0 THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RULE EXISTS' ) ;
    END IF;
      G_credit_check_rule_id := l_credit_check_rule_id ;
    RETURN ('Y') ;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: NO RULE FOUND' ) ;
    END IF;
      G_credit_check_rule_id := NULL ;
    RETURN ('N') ;
  END IF;



END Check_Rule_Defined;

/*-------------------------------------------------------------------
Returns 'Y' if the Order is being paid using a Credit Card
---------------------------------------------------------------------*/
FUNCTION Is_Electronic_Payment
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type )
RETURN 	VARCHAR2
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN IS ELECTRONIC PAYMENT' ) ;
  END IF;

  IF p_header_rec.payment_type_code = 'CREDIT_CARD' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: EXITING IS ELECTRONIC PAYMENT' ) ;
    END IF;
    RETURN ('Y') ;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: EXITING IS ELECTRONIC PAYMENT' ) ;
    END IF;
    RETURN ('N') ;
  END IF;

END Is_Electronic_Payment;

/*----------------------------------------------------------------------
Returns 'Y' if a specific Verify Hold already exists on the order
----------------------------------------------------------------------*/
PROCEDURE Hold_Exists
(  p_header_id      IN   NUMBER
,  p_hold_id        IN   NUMBER
,  p_hold_exists    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_hold_result   VARCHAR2(30);
l_return_status VARCHAR2(30);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CHECK FOR HOLD' ) ;
  END IF;

  --  Checking existense of unreleased holds on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING HOLDS ON HEADER '||P_HEADER_ID||' FOR HOLD '||P_HOLD_ID ) ;
  END IF;
  --
  OE_HOLDS_PUB.Check_Holds
		      ( p_api_version    => 1.0
		      , p_header_id      => p_header_id
			 , p_hold_id        => p_hold_id
			 , p_entity_code    => 'O'
		      , p_entity_id      => p_header_id
		      , x_result_out     => l_hold_result
		      , x_msg_count      => l_msg_count
		      , x_msg_data       => l_msg_data
		      , x_return_status  => l_return_status
		      );

  -- Check the Result
  IF l_hold_result = FND_API.G_TRUE THEN
    p_hold_exists := 'Y';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: HOLD EXISTS ON ORDER' ) ;
    END IF;
  ELSE
    p_hold_exists := 'N';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: NO HOLD ON ORDER' ) ;
    END IF;
  END IF;

  EXCEPTION

    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Hold_Exists'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Hold_Exists;

/*----------------------------------------------------------------------
Releases all Verify Holds on the Order, uses standard Hold APIs.
----------------------------------------------------------------------*/

PROCEDURE Release_Verify_Hold
(  p_header_id       IN   NUMBER
,  p_epayment_hold   IN   VARCHAR2
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_hold_entity_id    NUMBER := p_header_id;
l_hold_id	          NUMBER;
l_hold_exists       VARCHAR2(1);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(30);
l_release_reason    VARCHAR2(30);
l_hold_source_rec   OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN RELEASE VERIFY HOLD' ) ;
  END IF;

  -- Check What type of Holds to Release
  IF p_epayment_hold = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RELEASE EPAYMENT HOLDS FOR HEADER ID : ' || L_HOLD_ENTITY_ID ) ;
    END IF;

--    l_hold_release_rec  := OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;

    l_hold_id := 11 ;  -- Credit Card Authorization Failure Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Hold_Exists
                          ( p_header_id   => l_hold_entity_id
                          , p_hold_id     => l_hold_id
                          , p_hold_exists => l_hold_exists
                          ) ;

    IF l_hold_exists = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CC FAILURE HOLD ON ORDER HEADER ID:' || L_HOLD_ENTITY_ID ) ;
      END IF;
      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := l_hold_entity_id;

      l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';


      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING CREDIT CARD RISK HOLD FOR HEADER ID : ' || L_HOLD_ENTITY_ID ) ;
    END IF;

--    l_hold_release_rec  := OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;
    l_hold_id := 12 ; -- Credit Card Risk Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Hold_Exists
                          ( p_header_id   => l_hold_entity_id
                          , p_hold_id     => l_hold_id
                          , p_hold_exists => l_hold_exists
                          ) ;

    IF l_hold_exists = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CC RISK HOLD ON ORDER HEADER ID:' || L_HOLD_ENTITY_ID ) ;
      END IF;
      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := l_hold_entity_id;

      l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
      -- release pending payment authorization hold.
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING PENDING AUTHORIZATION HOLD FOR HEADER ID : ' || L_HOLD_ENTITY_ID ) ;
      END IF;

      l_hold_id := 16 ; -- Pending Payment Authorization Hold.

      -- Call Check for Hold to see if the Hold Exists
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
      END IF;
      --
      OE_Verify_Payment_PUB.Hold_Exists
                          ( p_header_id   => l_hold_entity_id
                          , p_hold_id     => l_hold_id
                          , p_hold_exists => l_hold_exists
                          ) ;

      IF l_hold_exists = 'Y' THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING PENDING AUTHORIZATION HOLD FOR HEADER ID:' || L_HOLD_ENTITY_ID ) ;
        END IF;
        l_hold_source_rec.hold_id          := l_hold_id;
        l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
        l_hold_source_rec.HOLD_ENTITY_ID   := l_hold_entity_id;

        l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';

        OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;  -- Do nothing if the hold has already been released.
    END IF;

  ELSE -- Release Other Verify Holds

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING CREDIT CHECKING HOLD FOR HEADER ID : ' || L_HOLD_ENTITY_ID ) ;
    END IF;

--    l_hold_release_rec  := OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;
    l_hold_id := 1 ; -- Credit Checking Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Hold_Exists
                          ( p_header_id   => l_hold_entity_id
                          , p_hold_id     => l_hold_id
                          , p_hold_exists => l_hold_exists
                          ) ;

    IF l_hold_exists = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CREDIT CHECKING HOLD ON ORDER HEADER ID:' || L_HOLD_ENTITY_ID ) ;
      END IF;

      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := l_hold_entity_id;

      l_hold_release_rec.release_reason_code := 'PASS_CREDIT';

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
        fnd_message.set_name('ONT', 'OE_CC_HOLD_REMOVED');
        oe_msg_pub.add;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

  END IF; -- Electronic Payment

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Release_Verify_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Release_Verify_Hold;

/*----------------------------------------------------------------------
Applies a Verify Hold which can be Credit Checking Failure, Credit
Card Authorization Failure or  Credit Card Risk Hold  based on the
Hold Id Passed IN, uses standard Hold APIs.
----------------------------------------------------------------------*/
PROCEDURE Apply_Verify_Hold
(   p_header_id       IN   NUMBER
,   p_hold_id         IN   NUMBER
,   p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data	       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS


l_hold_exists     VARCHAR2(1) := NULL ;
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(30);

l_hold_source_rec   OE_Holds_PVT.Hold_Source_REC_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN APPLY VERIFY HOLDS' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HEADER ID : '||P_HEADER_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HOLD ID : '||P_HOLD_ID ) ;
  END IF;

  -- Check if Hold already exists on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING IF REQUESTED VERIFY HOLD ALREADY APPLIED' ) ;
  END IF;
  --
  OE_Verify_Payment_PUB.Hold_Exists
                        ( p_header_id   => p_header_id
                        , p_hold_id     => p_hold_id
                        , p_hold_exists => l_hold_exists
                        );

  -- Return with Success if this Hold Already exists on the order
  IF l_hold_exists = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: HOLD ALREADY APPLIED ON HEADER ID : ' || P_HEADER_ID ) ;
    END IF;
    RETURN ;
  END IF ;

  -- Apply Verify Hold on Header
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLYING VERIFY HOLD ON HEADER ID : ' || P_HEADER_ID ) ;
  END IF;

  l_hold_source_rec.hold_id         := p_hold_id ;  -- Requested Hold
  l_hold_source_rec.hold_entity_code:= 'O';         -- Order Hold
  l_hold_source_rec.hold_entity_id  := p_header_id; -- Order Header

  OE_Holds_PUB.Apply_Holds
                (   p_api_version       =>      1.0
                ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                ,   p_hold_source_rec   =>      l_hold_source_rec
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                ,   x_return_status     =>      l_return_status
                );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_hold_id = 16 THEN
      FND_MESSAGE.SET_NAME('ONT','ONT_PENDING_AUTH_HOLD_APPLIED');
      FND_MESSAGE.SET_TOKEN('LEVEL','ORDER');
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVPPYB: Pending Payment Authorization hold  has been applied on order.', 3);
      END IF;
    END IF;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLIED VERIFY HOLD ON HEADER ID:' || P_HEADER_ID ) ;
  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Verify_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Apply_Verify_Hold;

-- bug 4339864, added this new procedure to do autonomous commit when
-- calling action is picking, packing or shipping.
/*----------------------------------------------------------------------
Applies a Verify Hold which can be Credit Checking Failure, Credit
Card Authorization Failure or  Credit Card Risk Hold  based on the
Hold Id Passed IN, uses standard Hold APIs.
----------------------------------------------------------------------*/
PROCEDURE Apply_Verify_Hold_and_Commit
(   p_header_id       IN   NUMBER
,   p_hold_id         IN   NUMBER
,   p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data	       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

-- bug 4339864
PRAGMA AUTONOMOUS_TRANSACTION;

l_hold_exists     VARCHAR2(1) := NULL ;
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(30);

l_hold_source_rec   OE_Holds_PVT.Hold_Source_REC_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN APPLY VERIFY HOLDS' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HEADER ID : '||P_HEADER_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HOLD ID : '||P_HOLD_ID ) ;
  END IF;

  -- Check if Hold already exists on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING IF REQUESTED VERIFY HOLD ALREADY APPLIED' ) ;
  END IF;
  --
  OE_Verify_Payment_PUB.Hold_Exists
                        ( p_header_id   => p_header_id
                        , p_hold_id     => p_hold_id
                        , p_hold_exists => l_hold_exists
                        );

  -- Return with Success if this Hold Already exists on the order
  IF l_hold_exists = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: HOLD ALREADY APPLIED ON HEADER ID : ' || P_HEADER_ID ) ;
    END IF;
    RETURN ;
  END IF ;

  -- Apply Verify Hold on Header
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLYING VERIFY HOLD ON HEADER ID : ' || P_HEADER_ID ) ;
  END IF;

  l_hold_source_rec.hold_id         := p_hold_id ;  -- Requested Hold
  l_hold_source_rec.hold_entity_code:= 'O';         -- Order Hold
  l_hold_source_rec.hold_entity_id  := p_header_id; -- Order Header

  OE_Holds_PUB.Apply_Holds
                (   p_api_version       =>      1.0
                ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                ,   p_hold_source_rec   =>      l_hold_source_rec
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                ,   x_return_status     =>      l_return_status
                );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_hold_id = 16 THEN
      FND_MESSAGE.SET_NAME('ONT','ONT_PENDING_AUTH_HOLD_APPLIED');
      FND_MESSAGE.SET_TOKEN('LEVEL','ORDER');
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVPPYB: Pending Payment Authorization hold  has been applied on order.', 3);
      END IF;
    END IF;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- bug 4339864
  IF l_debug_level  > 0 THEN
    OE_DEBUG_PUB.ADD(' Holds success ' , 3);
    OE_DEBUG_PUB.ADD(' About to Issue COMMIT', 3);
  END IF;

  COMMIT;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLIED VERIFY HOLD ON HEADER ID:' || P_HEADER_ID ) ;
  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Verify_Hold_and_Commit'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Apply_Verify_Hold_and_Commit;

/*----------------------------------------------------------------------
Main Procedure called for all Electronic Payment Processing.
----------------------------------------------------------------------*/
PROCEDURE Payment_Request (
  p_header_rec		IN	OE_Order_PUB.Header_Rec_Type,
  p_trxn_type		IN 	VARCHAR2,
  p_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER,
  p_msg_data		OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
  p_result_out      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  p_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2 )
IS
l_void_trxn_id      NUMBER := 0 ;
l_automatic_auth    VARCHAR2(1) ;
l_auth_code         VARCHAR2(80);
l_trxn_date         DATE;
l_msg_count         NUMBER := 0 ;
l_msg_data          VARCHAR2(2000) := NULL ;
l_return_status     VARCHAR2(30) := NULL;
l_void_supported    VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_result_out := 'PASS';
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN PAYMENT REQUEST MAIN' ) ;
  END IF;

  -- Return if iPayment is Not Installed
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING IPAYMENT IS INSTALLED OR NOT' ) ;
  END IF;
  --
  -- lkxu, fix bug 1701377
  /***
  IF ( OE_Verify_Payment_PUB.Check_Ipayment_Installed = 'N' ) THEN
    -- We don't want to continue and we want to RETURN a SUCCESS.
    RETURN ;
  END IF;
  ***/

  -- lkxu, for bug 1701377
  IF OE_GLOBALS.G_IPAYMENT_INSTALLED IS NULL THEN

     OE_GLOBALS.G_IPAYMENT_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(673);
  END IF;

  IF OE_GLOBALS.G_IPAYMENT_INSTALLED <> 'Y' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPVPMB: IPAYMENT IS NOT INSTALLED!' , 3 ) ;
     END IF;
     RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: TRANSACTION TYPE PASSED TO THE PROCEDURE IS '||P_TRXN_TYPE ) ;
  END IF;

  -- If Authorization is Requested then
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING THE TRANSACTION TYPE' ) ;
  END IF;
  --
  IF p_trxn_type = 'AUTHONLY' THEN

    -- Call Authorize Payment for Credit Card Authorization
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CALLING AUTHORIZE PAYMENT' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Authorize_Payment( p_header_rec   => p_header_rec
                                           , p_msg_count    => l_msg_count
                                           , p_msg_data     => l_msg_data
					   , p_result_out   => p_result_out
                                           , p_return_status=> l_return_status
                                           );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSIF p_trxn_type = 'VOIDAUTHONLY' THEN

    -- Call Fetch Authorization Trxn
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING FETCH AUTHORIZATION TRXN' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Fetch_Authorization_Trxn
                            (  p_header_rec     => p_header_rec
                            ,  p_trxn_id        => l_void_trxn_id
                            ,  p_automatic_auth => l_automatic_auth
					   );

    -- If a valid Transaction Id returned by above program then Void it.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING VALID TRANSACTION ID FOR VOIDING' ) ;
    END IF;
    --
    IF l_void_trxn_id > 0 THEN

      -- Void this Transaction
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING VOID PAYMENT FOR TRXN ID : '||L_VOID_TRXN_ID ) ;
      END IF;
      --
      OE_Verify_Payment_PUB.Void_Payment
						( p_void_trxn_id => l_void_trxn_id
                              , p_msg_count    => l_msg_count
                              , p_msg_data     => l_msg_data
                              , p_return_status=> l_return_status
						, p_void_supported => l_void_supported
                              ) ;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Return if VOID is not even supported.
    IF l_void_supported = 'N' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: VOID NOT SUPPORTED , RETURNING SUCCESS - 1' ) ;
      END IF;
	 RETURN;
    END IF;

    -- Update Auth Code, Date to Null only if it was an Automatic Auth.
    -- Payment Amount will still be updated to NULL.
    --
    IF l_automatic_auth = 'N' THEN
	 l_auth_code := p_header_rec.credit_card_approval_code;
	 l_trxn_date := p_header_rec.credit_card_approval_date;
    ELSE
	 l_auth_code := NULL;
	 l_trxn_date := NULL;
    END IF;

    -- Update Payment Amount and Authorization Code and DATE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CALLING UPDATE AUTH INFO TO UPDATE THE APPROVAL INFO TO NULL' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Update_Authorization_Info
                         ( p_header_rec.header_id
                          , NULL
			  , l_auth_code
			  , l_trxn_date
                          , l_msg_count
                          , l_msg_data
                          , l_return_status
			  );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Release any existing Credit Card Holds on the Order
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RELEASING EXISTING CC HOLDS SINCE AUTH HAS BEEN VOIDED' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Release_Verify_Hold
                               ( p_header_id     => p_header_rec.header_id
                               , p_epayment_hold => 'Y' -- We want to Release Credit Card Hold
                               , p_msg_count     => l_msg_count
                               , p_msg_data      => l_msg_data
                               , p_return_status => l_return_status
                               );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	 p_result_out := 'FAIL';
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 p_result_out := 'FAIL';
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
	 p_result_out := 'FAIL';
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Payment_Request'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

End Payment_Request;

/*----------------------------------------------------------------------
This Function returns 'Y' if iPayment is Installed else returns 'N'.
----------------------------------------------------------------------*/
FUNCTION Check_Ipayment_Installed return VARCHAR2
is
l_status               VARCHAR2(1)  := NULL;
l_industry             VARCHAR2(30) := NULL;
l_ipayment_product_id  NUMBER	      := 673 ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CHECK IPAYMENT INSTALLED' ) ;
  END IF;

  IF fnd_installation.get ( l_ipayment_product_id, l_ipayment_product_id, l_status, l_industry) THEN
    IF (l_status = 'I') THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: EXITING CHECK IPAYMENT INSTALLED' ) ;
      END IF;
      RETURN('Y') ;
    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: EXITING CHECK IPAYMENT INSTALLED' ) ;
      END IF;
      RETURN('N') ;
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: EXITING CHECK IPAYMENT INSTALLED' ) ;
    END IF;
    RETURN('N') ;
  END IF ;

END Check_IPayment_Installed;

/*----------------------------------------------------------------------
This Procedure returns tangibleid, amount if Voice Auth Needed
----------------------------------------------------------------------*/
PROCEDURE Voice_Auth_Requested
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_tangible_id     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,  p_amount          OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_line_id	     IN NUMBER DEFAULT NULL)
IS
Type IBYCurType IS REF CURSOR;
iby_cursor    IBYCurType;
l_ref_info    VARCHAR2(80);
l_sql_stmt    VARCHAR2(1000);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN VOICE AUTH REQUESTED' ) ;
  END IF;

  -- Query the data related to last authorization trxn for this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SQL FOR QUERYING THE LAST AUTHORIZATION TRXN' ) ;
  END IF;
  --

  -- modified for multiple payments.
  IF p_line_id IS NOT NULL THEN
    l_ref_info := TO_CHAR(p_line_id);
  ELSE
    l_ref_info := TO_CHAR(p_header_rec.header_id);
  END IF;

  -- Create the query string
  l_sql_stmt := 'SELECT IT.TANGIBLEID, IT.AMOUNT
                 FROM   IBY_TANGIBLE IT
                 WHERE  IT.REFINFO = :ref_info
                 AND    EXISTS
                       (SELECT ''Voice Auth Requested''
                        FROM   IBY_TRANS_ALL_V A
                        WHERE  A.REQTYPE    = ''ORAPMTREQ''
                        AND    A.STATUS     = 21
                        AND    A.TANGIBLEID = IT.TANGIBLEID)
                 AND    NOT
                        EXISTS
                       (SELECT ''Voice Auth Successful''
                        FROM   IBY_TRANS_ALL_V B
                        WHERE  B.REQTYPE    = ''ORAPMTREQ''
                        AND    B.STATUS     = 0
                        AND    B.TANGIBLEID = IT.TANGIBLEID)';

  --OE_DEBUG_PUB.ADD(l_sql_stmt);

  OPEN iby_cursor FOR l_sql_stmt USING l_ref_info;

  FETCH iby_cursor INTO p_tangible_id, p_amount;

  CLOSE iby_cursor;

  -- Return Tangible Id and Amount
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: VOICE AUTH TANGIBLE ID: '||P_TANGIBLE_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: VOICE AUTH AMOUNT: '||P_AMOUNT ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: EXITING VOICE AUTH REQUESTED' ) ;
  END IF;

END Voice_Auth_Requested;

/*----------------------------------------------------------------------
Returns Payment Method Details for a given Receipt Method Id
New local procedure created as a result of change done by AR
Now Merchant Id is stored in a new char column MERCHANT_REF.
----------------------------------------------------------------------*/
PROCEDURE Get_Pay_Method_Info
(   p_pay_method_id   IN   NUMBER
,   p_pay_method_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_merchant_ref    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN GET PAY METHOD INFO - LOCAL' ) ;
  END IF;

  -- Fetch Pay Method Name and Merchant Id based on Pay Method ID
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE FETCHING THE DETAILS' ) ;
  END IF;
  --
  begin
    SELECT
      name
    , merchant_ref
    INTO
      p_pay_method_name
    , p_merchant_ref
    FROM  AR_RECEIPT_METHODS
    WHERE RECEIPT_METHOD_ID = p_pay_method_id
    AND   SYSDATE >= NVL(START_DATE, SYSDATE)
    AND   SYSDATE <= NVL(END_DATE, SYSDATE)
    AND   PAYMENT_TYPE_CODE = 'CREDIT_CARD';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  end;

END Get_Pay_Method_Info;

/*----------------------------------------------------------------------
Calls iPayment's API to authorize a Credit Card Payment for an Order.
----------------------------------------------------------------------*/
PROCEDURE Authorize_Payment
(   p_header_rec        IN   OE_Order_PUB.Header_Rec_Type
,   p_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_result_out        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
is
l_void_trxn_id       NUMBER;
l_outbound_total     NUMBER;
l_order_value_chr    VARCHAR2(100);
l_order_value        NUMBER;
l_reauthorize_flag   VARCHAR2(1);
l_pay_method_id      NUMBER;
l_pay_method_name	 VARCHAR2(50);
l_bank_acct_id      NUMBER ;
l_bank_acct_uses_id NUMBER ;
l_merchant_id        NUMBER;
l_payee_id           VARCHAR2(80);
l_tangible_id        VARCHAR2(80);
l_ref_info           VARCHAR2(80) := TO_CHAR(p_header_rec.header_id);
l_payer_cust_id      NUMBER;
l_payer_address1     VARCHAR2(240);
l_payer_address2     VARCHAR2(240);
l_payer_address3     VARCHAR2(240);
l_payer_city         VARCHAR2(60);
l_payer_county       VARCHAR2(60);
l_payer_state        VARCHAR2(60);
l_payer_postalcode   VARCHAR2(60);
l_payer_country      VARCHAR2(60);
l_header_val_rec	 OE_Order_PUB.Header_Val_Rec_Type;
l_ship_to_address    VARCHAR2(10);
l_time_of_purchase   VARCHAR2(10);
l_block_str          VARCHAR2(5000);
l_risk_threshold	 NUMBER := 0 ;
l_riskresp_included  VARCHAR2(30);
l_risk_score         NUMBER := 0 ;
l_auth_code          VARCHAR2(80);
l_trxn_date          DATE;
l_status             NUMBER;
l_err_code           VARCHAR2(80);
l_err_mesg           VARCHAR2(255);
l_err_loc            NUMBER;
l_bep_err_code       VARCHAR2(80);
l_bep_err_mesg       VARCHAR2(255);
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;
l_return_status      VARCHAR2(30) := NULL ;
l_result_out         VARCHAR2(30) := NULL ;
l_void_supported     VARCHAR2(1);
l_voiceauth_flag     VARCHAR2(1) := 'N';
l_voice_auth_code    VARCHAR2(80):= NULL;
l_hold_exists        VARCHAR2(1);

l_ship_address1      VARCHAR2(240);
l_ship_address2      VARCHAR2(240);
l_ship_address3      VARCHAR2(240);
l_ship_city          VARCHAR2(60);
l_ship_postalcode    VARCHAR2(60);
l_ship_country       VARCHAR2(60);

l_trxn_id            NUMBER;
l_cust_trx_date	     DATE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_result_out := 'PASS' ;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN AUTHORIZE PAYMENT' ) ;
  END IF;

  -- Call Check Reauthorize Order to find out if Reauthorization is required
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING CHECK REAUTHORIZE FLAG' ) ;
  END IF;
  --
  OE_Verify_Payment_PUB.Check_Reauthorize_Order
					    ( p_header_rec      => p_header_rec
					    , p_void_trxn_id    => l_void_trxn_id
					    , p_outbound_total  => l_outbound_total
					    , p_reauthorize_out => l_reauthorize_flag
					    );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: REAUTHORIZE FLAG HAS BEEN SET TO : '||L_REAUTHORIZE_FLAG ) ;
  END IF;

  /*
  ** Fix for 1967295:
  ** As VOID has been de-supported by iPayment, commenting
  ** following code which was used to VOID existing Trxns.
  **
  -- If a valid Transaction Id returned by above program then Void it.
  OE_DEBUG_PUB.ADD('OEXPVPMB: Before Checking Valid Transaction ID for Voiding');
  --
  IF l_void_trxn_id > 0 THEN

    -- Void this Transaction
    OE_DEBUG_PUB.ADD('OEXPVPMB: Before Calling Void Payment for Trxn ID : '||l_void_trxn_id);
    --
    OE_Verify_Payment_PUB.Void_Payment
					    ( p_void_trxn_id => l_void_trxn_id
                             , p_msg_count    => l_msg_count
                             , p_msg_data     => l_msg_data
                             , p_return_status=> l_return_status
					    , p_void_supported => l_void_supported
                             ) ;
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      p_result_out := 'FAIL';
      RETURN;
    END IF;

  END IF;
  */

  -- Check Reauthorize Flag and proceed
  IF l_reauthorize_flag = 'N' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: NO NEED TO REAUTHORIZE' ) ;
    END IF;

    -- Check if Hold already exists on this order
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECK IF ORDER ON RISK HOLD' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Hold_Exists
                        ( p_header_id   => p_header_rec.header_id
                        , p_hold_id     => 12 -- Seed Id for CC Risk Hold
                        , p_hold_exists => l_hold_exists
                        );

    IF l_hold_exists = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: ORDER IS ON RISK HOLD' ) ;
      END IF;
      p_result_out := 'RISK';
    END IF;

    RETURN;

  ELSIF l_reauthorize_flag = 'V' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: SETUP A VOICE AUTHORIZATION' ) ;
    END IF;
    l_voiceauth_flag := 'Y';
    l_voice_auth_code:= p_header_rec.credit_card_approval_code;

  ELSE

    -- Call to see if an auth already exists which was not updated on order
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING FETCH LAST AUTH' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Fetch_Last_Auth ( p_header_rec  => p_header_rec
					  , p_trxn_id     => l_trxn_id
					  , p_tangible_id => l_tangible_id
                                          , p_auth_code   => l_auth_code
                                          , p_trxn_date   => l_trxn_date
                                          , p_amount      => l_order_value
                                          );

    IF l_trxn_id > 0 THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: GOING DIRECTLY TO UPDATE AUTH' ) ;
      END IF;
      goto UPDATE_AUTH;
    END IF;

  /*
  ** Fix for 1967295:
  ** As VOID has been de-supported by iPayment, commenting
  ** following code which was used to VOID existing Trxns.
  **
    -- Return if VOID is not even supported.
    IF l_void_supported = 'N' THEN
      OE_DEBUG_PUB.ADD('OEXPVPMB: Void Not Supported, Returning Success - 2');

      -- Check if Hold already exists on this order
      OE_DEBUG_PUB.ADD('OEXPVPMB: Check if Order on Risk Hold');
      --
      OE_Verify_Payment_PUB.Hold_Exists
                        ( p_header_id   => p_header_rec.header_id
                        , p_hold_id     => 12 -- Seed Id for CC Risk Hold
                        , p_hold_exists => l_hold_exists
                        );

      IF l_hold_exists = 'Y' THEN
        OE_DEBUG_PUB.ADD('OEXPVPMB: Order is on Risk Hold');
        p_result_out := 'RISK';
      END IF;

	 RETURN;
    END IF;
  */

  END IF;

  -- Check if Voice Auth was requested in previous call to iPayment for this order.
  Voice_Auth_Requested( p_header_rec  => p_header_rec
                      , p_tangible_id => l_tangible_id
                      , p_amount      => l_order_value
                      );

  IF l_tangible_id IS NOT NULL AND l_reauthorize_flag = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: WILL NOT REAUTHORIZE , VOICE AUTH REQUESTED' ) ;
      END IF;
      p_result_out := 'FAIL';
      RETURN;
  END IF;

  -- Check the Existence of attributes required for CC Payment Authorization
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING THE VALIDATE REQUIRED ATTRIBUTES' ) ;
  END IF;
  --
  IF NOT Validate_Required_Attributes(p_header_rec) THEN
    p_result_out := 'FAIL';
    RETURN;
  END IF;

  -- Get Primary Payment Method Id for this Customer, Site
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING GET PRIMARY PAYMENT METHOD' ) ;
  END IF;
  --
  l_pay_method_id := OE_Verify_Payment_PUB.Get_Primary_Pay_Method
					                  ( p_header_rec => p_header_rec ) ;

  -- Check if a valid method was selected
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING THE METHOD ID' ) ;
  END IF;
  --
  IF l_pay_method_id > 0 THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: PAYMENT METHOD ID IS : '||L_PAY_METHOD_ID ) ;
    END IF;

    -- Fetch Payment Method Name and Merchant Id based on the Method ID.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING GET PAY METHOD INFO' ) ;
    END IF;
    --
                          Get_Pay_Method_Info
					   ( p_pay_method_id   => l_pay_method_id
					   , p_pay_method_name => l_pay_method_name
					   , p_merchant_ref    => l_payee_id
					   ) ;

    -- If Merchant Id is invalid then set the out result to FAIL and return
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING THE PAYEE ID' ) ;
    END IF;
    --
    IF l_payee_id is NULL THEN

      -- Message "Unable to retrieve Payee/Merchant  ID for Customer's Primary Payment Method"
      FND_MESSAGE.SET_NAME('ONT','OE_VPM_NO_PAYEE_ID');
      OE_MSG_PUB.ADD;
      p_result_out := 'FAIL' ;
	 RETURN;

    END IF;

  ELSE -- Method ID is invalid

    -- Message "Unable to retrieve Primary Payment Method for the customer"
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_NO_PAY_METHOD');
    OE_MSG_PUB.ADD;
    p_result_out := 'FAIL' ;
    RETURN;

  END IF;

  -- Setup the Data Required to Call OraPmtReq, iPayment's API.

  -- The Payee Id is
--l_payee_id := TO_CHAR(l_merchant_id);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: PAYEE ID IS : '|| L_PAYEE_ID ) ;
  END IF;

  --IF l_debug_level  > 0 THEN
      --oe_debug_pub.add(  'OEXPVPMB: PAYER NAME IS : '|| P_HEADER_REC.CREDIT_CARD_HOLDER_NAME ) ;
  --END IF;

  -- Get a NEW tangible id only if it's not already pulled from Voice Auth
  IF l_tangible_id is NULL THEN
    -- Fetch the Tangible Id from sequence
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE FETCHING THE TANGIBLE ID' ) ;
    END IF;
    --
    begin
      SELECT TO_CHAR(OE_IPAYMENT_TANGIBLE_S.NEXTVAL)||'_ONT'
      INTO   l_tangible_id
      FROM   DUAL ;
    end ;
  END IF; -- tangible id null

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: TANGIBLE ID IS : '||L_TANGIBLE_ID ) ;
  END IF;

  -- Setup the Payer Address Record Type
  begin
    SELECT  ADDRESS_LINE_1
    ,       ADDRESS_LINE_2
    ,       ADDRESS_LINE_3
    ,       TOWN_OR_CITY
    ,       COUNTY
    ,       STATE
    ,       COUNTRY
    ,       POSTAL_CODE
    ,       CUSTOMER_ID
    INTO    l_payer_address1
    ,       l_payer_address2
    ,       l_payer_address3
    ,       l_payer_city
    ,       l_payer_county
    ,       l_payer_state
    ,       l_payer_country
    ,       l_payer_postalcode
    ,       l_payer_cust_id
    FROM    OE_INVOICE_TO_ORGS_V
    WHERE   ORGANIZATION_ID = p_header_rec.invoice_to_org_id;
  end ;

  -- Fix for Bug # 1586750.
  -- Call to Process_Cust_Bank_Account moved to this place
  -- so that invoice to org customer id can be used to set
  -- up the credit card bank account.

  -- Setup the Customer Bank Account in AP
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE SETTING UP THE CUSTOMER BANK ACCOUNT' ) ;
  END IF;
  --

  /**
  l_cust_trx_date := nvl(p_header_rec.ordered_date, sysdate)
               - nvl( to_number(fnd_profile.value('ONT_DAYS_TO_BACKDATE_BANK_ACCT')), 0);
  begin
    arp_bank_pkg.process_cust_bank_account
	             ( p_trx_date         => l_cust_trx_date
	             , p_currency_code    => p_header_rec.transactional_curr_code
          	     , p_cust_id          => l_payer_cust_id
	             , p_site_use_id      => p_header_rec.invoice_to_org_id
	             , p_credit_card_num  => p_header_rec.credit_card_number
		     , p_acct_name        => p_header_rec.credit_card_holder_name
	             , p_exp_date         => p_header_rec.credit_card_expiration_date
	             , p_bank_account_id      => l_bank_acct_id
	             , p_bank_account_uses_id => l_bank_acct_uses_id
	             ) ;
    EXCEPTION
	 WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_ACCT_NOT_SET');
        OE_MSG_PUB.ADD;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: ERROR IN ARP_BANK_PKG.PROCESS_CUST_BANK_ACCOUNT' ) ;
        END IF;
	   p_result_out := 'FAIL';
	   RETURN;
  end;
  **/

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AFTER SETTING UP THE CUSTOMER BANK ACCOUNT' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: INVOICE/CREDIT CARD HOLDER ADDRESS START .. ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 1 : '|| L_PAYER_ADDRESS1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 2 : '|| L_PAYER_ADDRESS2 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 3 : '|| L_PAYER_ADDRESS3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CITY : '|| L_PAYER_CITY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: COUNTY : '|| L_PAYER_COUNTY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: STATE : '|| L_PAYER_STATE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: COUNTRY : '|| L_PAYER_COUNTRY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: POSTAL CODE : '|| L_PAYER_POSTALCODE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: INVOICE/CREDIT CARD HOLDER TO ADDRESS END .. ' ) ;
  END IF;

  -- Fetch the Header Values
  /*
  ** Ship To Address is now selected from the table.
  l_header_val_rec := OE_Header_Util.Get_Values( p_header_rec => p_header_rec );
  */

  -- Get the Ship To Address Information
  begin
    SELECT  ADDRESS_LINE_1
    ,       ADDRESS_LINE_2
    ,       ADDRESS_LINE_3
    ,       TOWN_OR_CITY
    ,       POSTAL_CODE
    ,       COUNTRY
    INTO    l_ship_address1
    ,       l_ship_address2
    ,       l_ship_address3
    ,       l_ship_city
    ,       l_ship_postalcode
    ,       l_ship_country
    FROM    OE_SHIP_TO_ORGS_V
    WHERE   ORGANIZATION_ID = p_header_rec.ship_to_org_id;
  end ;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SHIP TO ADDRESS START .. ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 1 : '|| L_SHIP_ADDRESS1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 2 : '|| L_SHIP_ADDRESS2 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: ADDRESS 3 : '|| L_SHIP_ADDRESS3 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CITY : '|| L_SHIP_CITY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: COUNTRY : '|| L_SHIP_COUNTRY ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: POSTAL CODE : '|| L_SHIP_POSTALCODE ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SHIP TO ADDRESS END .. ' ) ;
  END IF;

  /*
  ** Fix Bug # 2262893
  ** Modified following IF condition to handle adresses with NULL values in line
  ** 1, 2 and 3 columns. City, Postal Code and Country are now checked separately.
  */
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING IF SHIP TO AND INVOICE TO ADDRESSES MATCH' ) ;
  END IF;
  --
  /*
  IF (l_header_val_rec.invoice_to_address1 = l_header_val_rec.ship_to_address1
  AND l_header_val_rec.invoice_to_address2 = l_header_val_rec.ship_to_address2
  AND l_header_val_rec.invoice_to_address3 = l_header_val_rec.ship_to_address3
  AND l_header_val_rec.invoice_to_address4 = l_header_val_rec.ship_to_address4) THEN
  */

  IF  nvl(ltrim(rtrim(l_payer_address1)), ' ')  = nvl(ltrim(rtrim(l_ship_address1)), ' ')
  AND nvl(ltrim(rtrim(l_payer_address2)), ' ')  = nvl(ltrim(rtrim(l_ship_address2)), ' ')
  AND nvl(ltrim(rtrim(l_payer_address3)), ' ')  = nvl(ltrim(rtrim(l_ship_address3)), ' ')
  AND nvl(ltrim(rtrim(l_payer_city)), ' ')      = nvl(ltrim(rtrim(l_ship_city)), ' ')
  AND nvl(ltrim(rtrim(l_payer_postalcode)), ' ')= nvl(ltrim(rtrim(l_ship_postalcode)), ' ')
  AND nvl(ltrim(rtrim(l_payer_country)), ' ')   = nvl(ltrim(rtrim(l_ship_country)), ' ')
  THEN
    l_ship_to_address := 'TRUE' ; -- Ship To and Invoice To Addresses Match
  ELSE
    l_ship_to_address := 'FALSE' ; -- Ship To and Invoice To Addresses DO NOT Match
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SHIP TO AND INVOICE TO MATCH : '|| L_SHIP_TO_ADDRESS ) ;
  END IF;

  -- Hour and Minutes after Mid Night in HH24:MM format
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: FETCHING HOUR AND MINUTES AFTER MIDNIGHT AS TIME OF PURCHASE' ) ;
  END IF;
  --
  SELECT TO_CHAR(sysdate, 'HH24:MI')
  INTO   l_time_of_purchase
  FROM   DUAL ;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: TIME OF PURCHASE AFTER MIDNIGHT HH24:MI IS : '|| L_TIME_OF_PURCHASE ) ;
  END IF;

  -- Set the Order Value to Outbound Total only if it's not already
  -- set to the tangible amount from the Voice Authorization.
  IF NVL(l_order_value, 0) <= 0 THEN
    l_order_value := l_outbound_total;
  END IF; -- tangible Amount not > 0

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AMOUNT TO BE AUTHORIZED , OUTBOUND TOTAL : '||L_ORDER_VALUE ) ;
  END IF;

  l_block_str := 'DECLARE

  /**** Declaration Section ****/
    l_ecapp_id       INTEGER := 660;
    l_payee_rec      IBY_Payment_Adapter_PUB.Payee_Rec_Type;
    l_payer_rec      IBY_Payment_Adapter_PUB.Payer_Rec_Type;
    l_payer_addr_rec IBY_Payment_Adapter_PUB.Address_Rec_Type;
    l_cc_instr_rec   IBY_Payment_Adapter_PUB.CreditCardInstr_Rec_Type;
    l_pmtinstr_rec   IBY_Payment_Adapter_PUB.PmtInstr_Rec_Type;
    l_tangible_rec   IBY_Payment_Adapter_PUB.Tangible_Rec_Type;
    l_pmtreqtrxn_rec IBY_Payment_Adapter_PUB.PmtReqTrxn_Rec_Type;
    l_riskinfo_rec   IBY_Payment_Adapter_PUB.RiskInfo_Rec_Type;
    l_reqresp_rec    IBY_Payment_Adapter_PUB.ReqResp_Rec_Type;
    l_return_status  VARCHAR2(30);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(2000);

  BEGIN
  /**** Setup PayEE Record ****/
    l_payee_rec.payee_id := :payee_id;
  /**** Setup PayER Record ****/
    l_payer_rec.payer_name := :payer_name;
  /**** Setup Payer Address Record ****/
    l_payer_addr_rec.address1 := :payer_addr1;
    l_payer_addr_rec.address2 := :payer_addr2;
    l_payer_addr_rec.address3 := :payer_addr3;
    l_payer_addr_rec.city     := :payer_city;
    l_payer_addr_rec.county   := :payer_county;
    l_payer_addr_rec.state    := :payer_state;
    l_payer_addr_rec.postalcode := :payer_postalcode;
    l_payer_addr_rec.country  := :payer_country;
  /**** Setup Credit Card Record ****/
    l_cc_instr_rec.CC_Type       := :cc_type;
    l_cc_instr_rec.CC_Num        := :cc_num;
    l_cc_instr_rec.CC_ExpDate    := :cc_expdate;
    l_cc_instr_rec.CC_HolderName := :cc_holdername;
    l_cc_instr_rec.CC_BillingAddr:= l_payer_addr_rec;
  /**** Setup Payment Instrument Record ****/
    l_pmtinstr_rec.creditcardinstr:= l_cc_instr_rec;
  /**** Setup Tangible Record ****/
    l_tangible_rec.tangible_id    := :tangible_id;
    l_tangible_rec.tangible_amount:= :order_value;
    l_tangible_rec.currency_code  := :currency_code;
    l_tangible_rec.refinfo        := :ref_info;
  /**** Setup Payment Request Trxn Record ****/
    l_pmtreqtrxn_rec.pmtmode   := ''ONLINE'';
    l_pmtreqtrxn_rec.auth_type := ''AUTHONLY'';
    l_pmtreqtrxn_rec.org_id    := :pmt_org_id;
    l_pmtreqtrxn_rec.voiceauthflag := :voice_auth_flag;
    l_pmtreqtrxn_rec.authcode  := :voice_auth_code;
  /**** Setup Risk Info Record ****/
    l_riskinfo_rec.shiptobillto_flag:= :shipto_address;
    l_riskinfo_rec.time_of_purchase:= :time_of_purchase;

  /**** Setup call to iPayment API OraPmtReq for Authorization ****/
    IBY_Payment_Adapter_PUB.OraPmtReq
    (  p_api_version      => 1.0
    ,  p_ecapp_id         => l_ecapp_id
    ,  p_payee_rec        => l_payee_rec
    ,  p_payer_rec        => l_payer_rec
    ,  p_pmtinstr_rec     => l_pmtinstr_rec
    ,  p_tangible_rec     => l_tangible_rec
    ,  p_pmtreqtrxn_rec   => l_pmtreqtrxn_rec
    ,  p_riskinfo_rec     => l_riskinfo_rec
    ,  x_return_status    => l_return_status
    ,  x_msg_count        => l_msg_count
    ,  x_msg_data         => l_msg_data
    ,  x_reqresp_rec      => l_reqresp_rec
    );

  /**** Return all the Responses so as to Handle Output of OraPmtReq ****/

    :riskrep_included := l_reqresp_rec.riskrespincluded;
    :risk_score    := l_reqresp_rec.riskresponse.risk_score;
    :auth_code     := l_reqresp_rec.authcode;
    :trxn_date     := l_reqresp_rec.trxn_date;
    :return_status := l_return_status;
    :msg_count     := l_msg_count;
    :msg_data      := l_msg_data;
    :status        := NVL(l_reqresp_rec.response.status,0);
    :err_code      := l_reqresp_rec.response.errcode;
    :err_mesg      := l_reqresp_rec.response.errmessage;
    :err_loc       := l_reqresp_rec.errorlocation;
    :bep_err_code  := l_reqresp_rec.beperrcode;
    :bep_err_mesg  := l_reqresp_rec.beperrmessage;

  END;';

  -- PL/SQL Block for call to OraPmtReq
  -- OE_DEBUG_PUB.ADD(l_block_str);
  --

  -- Before Executing the Block
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE EXECUTING THE PL/SQL BLOCK' ) ;
  END IF;
  --
  EXECUTE IMMEDIATE l_block_str
		    USING   IN l_payee_id
		          , IN p_header_rec.credit_card_holder_name
		          , IN l_payer_address1
		          , IN l_payer_address2
		          , IN l_payer_address3
		          , IN l_payer_city
		          , IN l_payer_county
		          , IN l_payer_state
		          , IN l_payer_postalcode
		          , IN l_payer_country
		          , IN p_header_rec.credit_card_code
		          , IN p_header_rec.credit_card_number
		          , IN p_header_rec.credit_card_expiration_date
		          , IN p_header_rec.credit_card_holder_name
		          , IN l_tangible_id
		          , IN l_order_value
		          , IN p_header_rec.transactional_curr_code
		          , IN l_ref_info
				, IN p_header_rec.org_id
				, IN l_voiceauth_flag
				, IN l_voice_auth_code
		          , IN l_ship_to_address
		          , IN l_time_of_purchase
  		          , OUT l_riskresp_included
  		          , OUT l_risk_score
  		          , OUT l_auth_code
  		          , OUT l_trxn_date
  		          , OUT l_return_status
		          , OUT l_msg_count
		          , OUT l_msg_data
				, OUT l_status
				, OUT l_err_code
				, OUT l_err_mesg
				, OUT l_err_loc
				, OUT l_bep_err_code
				, OUT l_bep_err_mesg;

  -- After Executing the Block
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AFTER EXECUTING THE PL/SQL BLOCK' ) ;
  END IF;
  --

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_status > 0 THEN
    --bug 4065891 commenting out the following code which checks for err_code = 'IBY_0008'
    -- Check if the Operation was Supported or not
/*    IF  NVL(l_err_code, 'XXX') = 'IBY_0008' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: OPERATION NOT SUPPORTED.' ) ;
      END IF;
	 RETURN;
    END IF;
*/

    -- Message "The following error(s) occurred when calling iPayment for Credit Card Transaction :"
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_IPAYMENT_ERROR');
    FND_MESSAGE.SET_TOKEN('ERRCODE',l_err_code);
    FND_MESSAGE.SET_TOKEN('ERRMESSAGE',l_err_mesg);
    FND_MESSAGE.SET_TOKEN('ERRLOCATION',l_err_loc);
    FND_MESSAGE.SET_TOKEN('BEPERRCODE',l_bep_err_code);
    FND_MESSAGE.SET_TOKEN('BEPERRMESSAGE',l_bep_err_mesg);
    OE_MSG_PUB.ADD;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: ERROR CODE : '||L_ERR_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: ERROR MESSAGE : '||L_ERR_MESG ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BACK END PAYMENT SYSTEM ERRORS : ' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: ERROR LOCATION : '||L_ERR_LOC ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEP ERR CODE : '||L_BEP_ERR_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEP ERR MESG : '||L_BEP_ERR_MESG ) ;
    END IF;

    p_result_out := 'FAIL';

    RETURN;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AUTHORIZATION SUCCEEDED ...' ) ;
  END IF;

  <<UPDATE_AUTH>>
  -- Update Payment Amount and Authorization Code and DATE
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE UPDATING AUTHORIZATION INFO' ) ;
      oe_debug_pub.add(  'OEXPVPMB: l_order_value is: '||l_order_value ) ;
      oe_debug_pub.add(  'OEXPVPMB: l_auth_code is: '||l_auth_code ) ;
  END IF;
  --
  OE_Verify_Payment_PUB.Update_Authorization_Info
		       	    ( p_header_rec.header_id
                            , l_order_value
                            , l_auth_code
                            , l_trxn_date
                            , l_msg_count
                            , l_msg_data
                            , l_return_status
                            );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    p_result_out := 'FAIL';
    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: RISK RESPONSE INCLUDED : '||L_RISKRESP_INCLUDED ) ;
  END IF;

  IF l_riskresp_included = 'YES' THEN
    l_risk_threshold := TO_NUMBER(NVL(fnd_profile.value('ONT_RISK_FAC_THRESHOLD'), '0')) ;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RISK SCORE : '||L_RISK_SCORE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: OM RISK FACTOR THRESHOLD : '||L_RISK_THRESHOLD ) ;
    END IF;

    -- If Transaction is Risky, then apply credit card Risk hold.
    IF l_risk_score > l_risk_threshold THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPVPMB: TRANSACTION WAS RISKY' ) ;
         END IF;
      -- Set the Out result to Risk to indicate a risky Transaction
	 p_result_out := 'RISK' ;
	 RETURN;

    END IF;
  END IF;



  EXCEPTION

    WHEN OTHERS THEN
	 p_result_out := 'FAIL';
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Authorize_Payment'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );


END Authorize_Payment;

/*----------------------------------------------------------------------
Returns
1. Last Authorization Transactions Associated to the Order
2. Authorization Transaction currently associated to the Order
3. The Order Total of Outbound Lines
4. Flag to indicate if Reauthorization is required or Not
5. Flag to indicate if the Current Transaction is Automatic or Manual
----------------------------------------------------------------------*/
PROCEDURE Check_Reauthorize_Order
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_void_trxn_id    OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_outbound_total  OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_reauthorize_out OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
l_automatic_auth   VARCHAR2(1);
l_outbound_total   NUMBER;
l_captured_total   NUMBER;
l_est_valid_days   NUMBER := 0 ;
l_reauthorize_flag VARCHAR2(1);
l_void_trxn_id     NUMBER;
l_prepaid_total    NUMBER;
l_commitment_total NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CHECK REAUTHORIZE ORDER' ) ;
  END IF;

  -- Call Fetch Authorization Trxn
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING FETCH AUTHORIZATION TRXN' ) ;
  END IF;
  --
  OE_Verify_Payment_PUB.Fetch_Authorization_Trxn
                          (  p_header_rec     => p_header_rec
                          ,  p_trxn_id        => l_void_trxn_id
                          ,  p_automatic_auth => l_automatic_auth
					 );

  -- Fetch the Order Total Amount
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: FETCH OUTBOUND LINES TOTAL' ) ;
  END IF;
  --
  p_outbound_total := OE_OE_TOTALS_SUMMARY.Outbound_Order_Total(p_header_rec.header_id);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: TOTAL VALUE OF OUTBOUND LINES : '||P_OUTBOUND_TOTAL ) ;
  END IF;

  /*
  ** Fix Bug # 2554360: OE_OE_TOTALS_SUMMARY.Outbound_Order_Total will now exclude closed
  ** lines. Following is not required as closed lines will be considered captured.
  -- Fetch the Captured Amount Total
  OE_DEBUG_PUB.ADD('OEXPVPMB: Fetch Captured Amount Total');
  --
  l_captured_total := OE_Verify_Payment_PUB.Captured_Amount_Total(p_header_rec.header_id);
  OE_DEBUG_PUB.ADD('OEXPVPMB: Total Amount already Captured : '||l_captured_total);

  -- Uncaptured outbound Total is
  p_outbound_total := l_outbound_total - l_captured_total;
  */

  -- Check the Following only if Outbound Total is greater than 0
  IF p_outbound_total > 0 THEN

    -- Credit Card Approval Code is NOT NULL
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING CC APPROVAL CODE' ) ;
    END IF;
    --
    IF p_header_rec.credit_card_approval_code IS NOT NULL THEN

      -- Fetch the value for profile "OM: Estimated Authorization Validity Period"
      -- This is required to estimate the validity of existing Authorizations.
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: FETCHING VALUE FOR OM: ESTIMATED AUTHORIZATION VALIDITY PERIOD' ) ;
      END IF;
      --
      l_est_valid_days := to_number( nvl(fnd_profile.value('ONT_EST_AUTH_VALID_DAYS'), '0') ) ;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: OM: ESTIMATED AUTHORIZATION VALIDITY PERIOD : '|| L_EST_VALID_DAYS ) ;
      END IF;

      -- If the Authorization was taken Automatically using iPayment
      --
      IF l_automatic_auth = 'Y' THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: IT IS AN AUTOMATIC AUTHORIZATION' ) ;
        END IF;

        -- If Transaction has already been captured then
	   IF (OE_Verify_Payment_PUB.Check_Trxn_Captured(l_void_trxn_id) = 'Y') THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: CURRENT AUTH CAPTURED , REAUTHORIZE' ) ;
          END IF;
          l_reauthorize_flag := 'Y' ;
	     l_void_trxn_id := 0 ;

        /*
        ** Fix for 1967295:
        ** As VOID has been de-supported by iPayment, commenting
        ** following code which was used to VOID existing Trxns.
        **
        -- If Order Total is greater than previously Authorized Amount.
        ELSIF ( p_outbound_total > nvl(p_header_rec.payment_amount, 0) ) THEN

          OE_DEBUG_PUB.ADD('OEXPVPMB: Current Auth is for amount lesser than Order Total, reauthorize ');
          l_reauthorize_flag := 'Y' ;
        */

        -- If based on the estimated authorization validity period,
        -- the authorization has expired then reauthorize.
        ELSIF ( p_header_rec.credit_card_approval_date + l_est_valid_days <= SYSDATE ) THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: CURRENT AUTH EXPIRED , REAUTHORIZE' ) ;
          END IF;
          l_reauthorize_flag := 'Y' ;

	   ELSE

	     -- Niether the Order should be reauthorized nor the existing transaction should be voided.
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: NO NEED TO REAUTHORIZE OR VOID EXISTING TRANSACTION' ) ;
          END IF;
          l_reauthorize_flag := 'N' ;
	     l_void_trxn_id := 0 ;

        END IF;

      ELSE -- Manual Authorization

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: IT IS A MANUAL AUTHORIZATION' ) ;
        END IF;

	   --
	   -- Check if Manual Auth is still valid, use Estimated Validity Period.
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING VALIDITITY OF MANUAL AUTHORIZATION' ) ;
        END IF;
	   --
	   IF    p_header_rec.credit_card_approval_date is NOT NULL
	   AND ( p_header_rec.credit_card_approval_date + l_est_valid_days ) > SYSDATE THEN

          -- Set Reauthorize Flag to 'N', as manual Authorization is valid
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: MANUAL AUTHORIZATION IS STILL VALID , VOID EXISTING AUTOMATIC AUTH' ) ;
          END IF;
	     --
	     l_reauthorize_flag := 'V' ; -- Now this procedure returns V to setup Voice Auth

        ELSE

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: THE ORDER SHOULD BE REAUTHORIZED' ) ;
          END IF;
	     l_reauthorize_flag := 'Y' ;

        END IF; -- Approval DATE Validity

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: AFTER CHECKING VALIDITITY OF MANUAL AUTHORIZATION' ) ;
        END IF;

      END IF; -- Manual/Automatic Authorization

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: END OF MANUAL AUTHORIZATION' ) ;
      END IF;

    ELSE

      l_reauthorize_flag := 'Y' ;

    END IF; -- Order NOT Authorized OR Approval Code Cleared due to some attribute change.

  ELSE

    -- If Outbound Total is <= 0 then NO need to Reauthorize
    l_reauthorize_flag := 'N';

  END IF; -- IF Outbound Total

  p_reauthorize_out := l_reauthorize_flag ;
  p_void_trxn_id    := 0 ;
--  p_outbound_total  := l_outbound_total ;

END Check_Reauthorize_Order;

/*----------------------------------------------------------------------
Returns TRUE if all the Required Attributes exists else returns FALSE.
----------------------------------------------------------------------*/
FUNCTION Validate_Required_Attributes
(  p_header_rec  IN  OE_Order_Pub.Header_Rec_Type )
RETURN BOOLEAN
IS
l_result BOOLEAN := TRUE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN VALIDATE REQUIRED ATTRIBUTES' ) ;
  END IF;

  -- Check For all Required Attributes
  IF p_header_rec.invoice_to_org_id is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_INV_TO_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: INVOICE_TO_ORG_ID IS REQUIRED' ) ;
    END IF;
    l_result := FALSE;
  ELSIF p_header_rec.credit_card_number is NULL THEN
    --R12 CC Encryption
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_NUM_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_NUMBER IS REQUIRED' ) ;
    END IF;
    l_result := FALSE;
  ELSIF p_header_rec.credit_card_expiration_date is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_EXP_DT_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_EXPIRATION_DATE IS REQUIRED' ) ;
    END IF;
    l_result := FALSE;
  ELSIF p_header_rec.credit_card_holder_name is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_HOLDER_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_HOLDER_NAME IS REQUIRED' ) ;
    END IF;
    l_result := FALSE;
  ELSE
    l_result := TRUE;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: EXITING VALIDATE REQUIRED ATTRIBUTES' ) ;
  END IF;
  RETURN l_result;

END Validate_Required_Attributes;

/*----------------------------------------------------------------------
Returns Primary Payment Method for the Customer
----------------------------------------------------------------------*/
FUNCTION Get_Primary_Pay_Method
(  p_header_rec  IN  OE_Order_PUB.Header_Rec_Type )
RETURN NUMBER
IS
l_cc_only  BOOLEAN := TRUE ;
l_pay_method_id       NUMBER := 0;
l_cust_pay_method_id  NUMBER := 0 ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_as_of_date        DATE; --bug 3881076
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN GET PRIMARY PAY METHOD' ) ;
  END IF;

  -- Get Primary Receipt Method Id for this Customer, Site
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: to get primary pay method.' ) ;
  END IF;
  --

  /* Changed code to query from AR table directly for R12 cc encryption
  l_pay_method_id := arp_bank_pkg.get_primary_pay_method
                                 ( p_customer_id => p_header_rec.sold_to_org_id
                                 , p_site_use_id => p_header_rec.invoice_to_org_id
				 , p_cc_only     => l_cc_only
				 , p_as_of_date  => sysdate
                                 );
  */

  BEGIN
    --bug 5204358
    --Changed the query to retrieve the receipt_method_id instead of
    --cust_receipt_method id as the pay method id corresponds to receipt_method_id
    SELECT receipt_method_id
    INTO   l_pay_method_id
    FROM   ra_cust_receipt_methods rm
    WHERE  rm.customer_id = p_header_rec.sold_to_org_id
    AND    rm.SITE_USE_ID = NVL( p_header_rec.invoice_to_org_id, -1)
    AND    sysdate BETWEEN rm.start_date AND NVL(rm.end_date, sysdate)
    AND    primary_flag = 'Y';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    null;
  END;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: PRIMARY PAYMENT METHOD ID AT SITE LEVEL: '||L_PAY_METHOD_ID ) ;
  END IF;

  -- Fix Bug # 2256571
  -- If No Primary Payment Method set at SITE level, check at CUSTOMER Level.

  IF NVL(l_pay_method_id, 0) <= 0 THEN
    /* Changed code to query from AR table directly for R12 cc encryption
    l_pay_method_id := arp_bank_pkg.get_primary_pay_method
                                  ( p_customer_id => p_header_rec.sold_to_org_id
                                  , p_site_use_id => null
                                  , p_cc_only     => l_cc_only
                                  , p_as_of_date  => sysdate
                                  );
     */

    BEGIN
      --bug 5204358
      --Changed the query to retrieve the receipt_method_id instead of
      --cust_receipt_method id as the pay method id corresponds to receipt_method_id
      SELECT receipt_method_id
      INTO   l_pay_method_id
      FROM   ra_cust_receipt_methods rm
      WHERE  rm.customer_id = p_header_rec.sold_to_org_id
      AND    rm.SITE_USE_ID IS NULL
      AND    sysdate BETWEEN rm.start_date AND NVL(rm.end_date, sysdate)
      AND    primary_flag = 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXPVPMB: PRIMARY PAYMENT METHOD ID AT CUSTOMER LEVEL: '||L_PAY_METHOD_ID ) ;
    END IF;
  END IF;

 /* comment out for R12 cc encryption
  -- Check if Primary Payment Method valid
  IF NVL(l_pay_method_id, 0) <= 0 THEN
    -- Fetch the Receipt Method ID from OM Profile Option
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: FETCHING PAYMENT METHOD ID FROM PROFILE OPTION' ) ;
    END IF;
    --
    l_pay_method_id := to_number(nvl(fnd_profile.value('ONT_RECEIPT_METHOD_ID'), '0')) ;
    --
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: PROFILE PAYMENT METHOD ID IS : '||L_PAY_METHOD_ID ) ;
    END IF;

    IF l_pay_method_id > 0 THEN
      -- Assign the Payment Method as Primary if setup in Profile
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING ARP_BANK_PKG.PROCESS_CUST_PAY_METHOD' ) ;
      END IF;

      -- comment out the code for R12 cc encryption project
      -- Fixed for the FP bug 3881076
      -- l_as_of_date := nvl(p_header_rec.ordered_date, sysdate)
      --               - nvl(to_number(fnd_profile.value('ONT_DAYS_TO_BACKDATE_BANK_ACCT')), 0);

      l_cust_pay_method_id := arp_bank_pkg.process_cust_pay_method
                              ( p_pay_method_id => l_pay_method_id
                              , p_customer_id   => p_header_rec.sold_to_org_id
                              , p_site_use_id   => p_header_rec.invoice_to_org_id
                           -- , p_as_of_date    => l_as_of_date --bug 3881076
                              , p_as_of_date    => sysdate
                              );
    END IF;
    END IF;
    */

  RETURN (l_pay_method_id);


END Get_Primary_Pay_Method ;

/*----------------------------------------------------------------------
Returns Payment Method Details for a given Receipt Method Id
----------------------------------------------------------------------*/
PROCEDURE Get_Pay_Method_Info
(   p_pay_method_id   IN   NUMBER
,   p_pay_method_name OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_merchant_id     OUT NOCOPY /* file.sql.39 change */  NUMBER
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN GET PAY METHOD INFO' ) ;
  END IF;

  -- Fetch Pay Method Name and Merchant Id based on Pay Method ID
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE FETCHING THE DETAILS' ) ;
  END IF;
  --
  begin
    SELECT
      name
    , null
    INTO
      p_pay_method_name
    , p_merchant_id
    FROM  AR_RECEIPT_METHODS
    WHERE RECEIPT_METHOD_ID = p_pay_method_id
    AND   SYSDATE >= NVL(START_DATE, SYSDATE)
    AND   SYSDATE <= NVL(END_DATE, SYSDATE)
    AND   PAYMENT_TYPE_CODE = 'CREDIT_CARD';
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
  end;

END Get_Pay_Method_Info ;

/*--------------------------------------------------------------
Voids an uncaptured authorization transaction
--------------------------------------------------------------*/
PROCEDURE Void_Payment
(   p_void_trxn_id      IN   NUMBER
,   p_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_void_supported    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_block_str      VARCHAR2(2000);
l_msg_count      NUMBER := 0 ;
l_msg_data       VARCHAR2(2000) := NULL ;
l_return_status  VARCHAR2(30) := NULL ;
l_status         NUMBER;
l_err_code       VARCHAR2(80);
l_err_mesg       VARCHAR2(255);
l_bep_err_code   VARCHAR2(80);
l_bep_err_mesg   VARCHAR2(255);
l_err_loc        NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  p_void_supported:= 'Y';

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN VOID PAYMENT' ) ;
  END IF;


  -- Return if Trxn has already been captured
  IF ( OE_Verify_Payment_PUB.Check_Trxn_Captured(p_void_trxn_id) = 'Y' ) THEN
    RETURN;
  END IF;

  -- Create the Dynamic SQL to Call the iPayment API
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CREATING DYNAMIC SQL TO CALL IPAYMENT API ORAPMTVOID' ) ;
  END IF;
  --
  l_block_str:= 'DECLARE
      /**** Declaration Section ****/
        l_ecapp_id      INTEGER := 660;
        l_voidtrxn_rec  IBY_Payment_Adapter_PUB.VoidTrxn_Rec_Type;
        l_voidresp_rec  IBY_Payment_Adapter_PUB.VoidResp_Rec_Type;
	   l_return_status VARCHAR2(30);
	   l_msg_count     NUMBER;
	   l_msg_data      VARCHAR2(2000);
      BEGIN

      /**** Setup Void Record ****/
        l_voidtrxn_rec.pmtmode  := ''ONLINE'';
        l_voidtrxn_rec.trxn_id  := :void_trxn_id;
        l_voidtrxn_rec.trxn_type:= 2; /* ID for Voiding AUTHONLY Trxn */

      /**** Setup Call to iPayment API OraPmtVoid for Trxn Void ****/
        IBY_Payment_Adapter_PUB.OraPmtVoid
        (  p_api_version   => 1.0
        ,  p_ecapp_id      => l_ecapp_id
        ,  p_voidtrxn_rec  => l_voidtrxn_rec
        ,  x_return_status => l_return_status
        ,  x_msg_count     => l_msg_count
        ,  x_msg_data      => l_msg_data
        ,  x_voidresp_rec  => l_voidresp_rec
	   );

      /**** Return all the Responses so as to Handle Output of OraPmtReq ****/

        :return_status := l_return_status;
        :msg_count     := l_msg_count;
        :msg_data      := l_msg_data;
        :status        := NVL(l_voidresp_rec.response.status,0);
	   :err_code      := l_voidresp_rec.response.errcode;
	   :err_mesg      := l_voidresp_rec.response.errmessage;
        :err_loc       := l_voidresp_rec.errorlocation;
	   :bep_err_code  := l_voidresp_rec.beperrcode;
	   :bep_err_mesg  := l_voidresp_rec.beperrmessage;

      END;';

  -- PL/SQL Block for call to iPayment
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  L_BLOCK_STR ) ;
  END IF;
  --

  -- Before Executing the Block
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE EXECUTING THE PL/SQL BLOCK' ) ;
  END IF;
  --
  EXECUTE IMMEDIATE l_block_str
		    USING   IN p_void_trxn_id
			    , OUT l_return_status
			    , OUT l_msg_count
			    , OUT l_msg_data
			    , OUT l_status
			    , OUT l_err_code
			    , OUT l_err_mesg
			    , OUT l_err_loc
			    , OUT l_bep_err_code
			    , OUT l_bep_err_mesg;

  -- After Executing the Block
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AFTER EXECUTING THE PL/SQL BLOCK' ) ;
  END IF;
  --

  -- Check the Response Status to ensure that there are NO errors
  IF l_status > 0 THEN

    -- Check if the Operation was Supported or not
    IF  NVL(l_err_code, 'XXX') = 'IBY_0008' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
	 p_void_supported:= 'N';
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: VOID TRANSACTION NOT SUPPORTED.' ) ;
      END IF;
	 RETURN;
    ELSE
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

    -- Message "The following error(s) occurred when calling iPayment for Credit Card Transaction :"
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_IPAYMENT_ERROR');
    FND_MESSAGE.SET_TOKEN('ERRCODE',l_err_code);
    FND_MESSAGE.SET_TOKEN('ERRMESSAGE',l_err_mesg);
    FND_MESSAGE.SET_TOKEN('ERRLOCATION',l_err_loc);
    FND_MESSAGE.SET_TOKEN('BEPERRCODE',l_bep_err_code);
    FND_MESSAGE.SET_TOKEN('BEPERRMESSAGE',l_bep_err_mesg);
    OE_MSG_PUB.ADD;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: ERROR CODE : '||L_ERR_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: ERROR MESSAGE : '||L_ERR_MESG ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BACK END PAYMENT SYSTEM ERRORS : ' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEP ERR LOCATION : '||L_ERR_LOC ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEP ERR CODE : '||L_BEP_ERR_CODE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEP ERR MESG : '||L_BEP_ERR_MESG ) ;
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Void_Payment'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Void_Payment ;

/*----------------------------------------------------------------------
This Function takes Transaction Id as input parameter and returns 'Y'
if Transaction has already been captured in iPayment.
----------------------------------------------------------------------*/
FUNCTION Check_Trxn_Captured
( p_trxn_id  IN  NUMBER)
RETURN VARCHAR2
IS
l_captured_flag VARCHAR2(1) := 'N';
l_sql_stmt      VARCHAR2(1000) := NULL;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CHECK TRANSACTION CAPTURED' ) ;
  END IF;
  -- Create the query string
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SQL STATEMENT TO CHECK IF TRANSACTION HAS BEEN CAPTURED' ) ;
  END IF;
  --
  l_sql_stmt := 'SELECT ''Y'' FROM   IBY_TRANS_ALL_V
                 WHERE  TRANSACTIONID = :trxn_id
                 AND  ((REQTYPE = ''ORAPMTCAPTURE'')
				OR (REQTYPE = ''ORAPMTREQ'' AND AUTHTYPE = ''AUTHCAPTURE''))
                 AND    NVL(AMOUNT, 0) > 0
			  AND    ROWNUM = 1';

  --OE_DEBUG_PUB.ADD(l_sql_stmt);

  begin
    EXECUTE IMMEDIATE l_sql_stmt
                 INTO l_captured_flag
    	           USING p_trxn_id ;
    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   l_captured_flag := 'N';
  end;

  RETURN (l_captured_flag);

END Check_Trxn_Captured ;

/*----------------------------------------------------------------------
Returns 'Y' if this authorization was taken through iPayment else 'N'.
Also returns the Transaction ID.
----------------------------------------------------------------------*/
PROCEDURE Fetch_Authorization_Trxn
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_automatic_auth  OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
l_trxn_id     NUMBER;
l_tangible_id VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN FETCH AUTHORIZATION TRANSACTION' ) ;
  END IF;

  -- Check if Authorization Code of the Order is NOT NULL
  IF p_header_rec.credit_card_approval_code IS NOT NULL THEN
    -- Call Fetch Current Auth
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING FETCH CURRENT AUTH' ) ;
    END IF;
    --
    OE_Verify_Payment_PUB.Fetch_Current_Auth
						( p_header_rec  => p_header_rec
						, p_trxn_id     => l_trxn_id
						, p_tangible_id => l_tangible_id
						);

    IF l_trxn_id > 0 THEN
      p_automatic_auth := 'Y' ;
	 p_trxn_id := l_trxn_id ;
    ELSE
      p_automatic_auth := 'N' ;
    END IF;

  END IF;

  -- If Credit Card Approval Code is NULL OR Current Authorization is Manual
  -- then select the last authorized transaction for this order. This will
  -- ensure that any existing  automatic authorizations are voided in case of
  -- reauthorization and valid manual authorizations.
  --
  /*
  ** Since VOIDS are no more supported, following call to fetch
  ** last authorization is unnecessary.
  ** Procedure Fetch_Last_Auth will now be used to find out the
  ** last authorization which might have been taken but was not
  ** updated on the order header due to some errors.
  **
  IF  p_header_rec.credit_card_approval_code IS NULL
  OR  p_automatic_auth = 'N' THEN

    -- Call Last Current Auth
    OE_DEBUG_PUB.ADD('OEXPVPMB: Before calling Fetch Last Auth');
    --
    OE_Verify_Payment_PUB.Fetch_Last_Auth
						( p_header_rec  => p_header_rec
						, p_trxn_id     => l_trxn_id
						, p_tangible_id => l_tangible_id
						);

    IF l_trxn_id > 0 THEN
	 p_trxn_id := l_trxn_id ;
    END IF;
  END IF;
  */

END Fetch_Authorization_Trxn;

/*----------------------------------------------------------------------
Fetches the authorization details for the approval code on the Order.
----------------------------------------------------------------------*/
PROCEDURE Fetch_Current_Auth
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_line_id	     IN NUMBER DEFAULT NULL
,  p_auth_code	     IN VARCHAR2 DEFAULT NULL
,  p_auth_date	     IN DATE DEFAULT NULL
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_tangible_id     OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
l_sql_stmt    VARCHAR2(5000) := NULL;
l_ref_info    VARCHAR2(80);
l_credit_card_approval_code	VARCHAR2(80);
l_credit_card_approval_date     DATE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN FETCH CURRENT AUTHORIZATION' ) ;
  END IF;

  IF p_line_id IS NOT NULL THEN
    l_ref_info := TO_CHAR(p_line_id);
    l_credit_card_approval_code := p_auth_code;
    l_credit_card_approval_date := p_auth_date;
  ELSE
    l_ref_info := TO_CHAR(p_header_rec.header_id);
    IF p_auth_code IS NOT NULL THEN
      l_credit_card_approval_code := p_auth_code;
      l_credit_card_approval_date := p_auth_date;
    ELSE
      l_credit_card_approval_code := p_header_rec.credit_card_approval_code;
      l_credit_card_approval_date := p_header_rec.credit_card_approval_date;
    END IF;
  END IF;

  -- Check if Authorization Code of the Order is NOT NULL
  IF l_credit_card_approval_code IS NOT NULL THEN

    -- If the Order was neither entered through UI nor copied
    -- then only update the REFINFO column.
    IF ( ( NVL(p_header_rec.order_source_id, 0 ) > 0
	      AND p_header_rec.order_source_id <> 2 )
    OR  ( NVL(p_header_rec.source_document_type_id, 0 ) > 0
	     AND p_header_rec.source_document_type_id <> 2 ) ) THEN

      -- Update REFINFO with Order HEADER_ID if not updated yet.
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: SQL STMT TO UPDATE REFINFO WITH HEADER_ID' ) ;
      END IF;
      --
      /* Bug 6700106
         l_sql_stmt := 'UPDATE IBY_TANGIBLE IT
                     SET    IT.REFINFO  = :ref_info1
                     WHERE  IT.TANGIBLEID IN
                           (SELECT DISTINCT ITAV.TANGIBLEID
                            FROM   IBY_TRANS_ALL_V ITAV
                            WHERE  ITAV.REQTYPE    = ''ORAPMTREQ''
                            AND    ITAV.ECAPPID   != 660
                            AND    ITAV.AUTHCODE   = :auth_code
                            AND    trunc(ITAV.UPDATEDATE) = trunc(:auth_date) --5932506
                            AND   (ITAV.REFINFO    IS NULL
                             OR    ITAV.REFINFO   != :ref_info2))';

      --OE_DEBUG_PUB.ADD(l_sql_stmt);

      begin
        EXECUTE IMMEDIATE l_sql_stmt
	               USING l_ref_info
				,     l_credit_card_approval_code
                    ,     l_credit_card_approval_date
                    ,     l_ref_info;
      Bug 6700106 */

-- Bug 6700106

   	BEGIN
             /*  UPDATE IBY_TANGIBLE IT
	                      SET  IT.REFINFO  = l_ref_info
	                      WHERE  IT.TANGIBLEID IN
	                       (SELECT DISTINCT ITAV.TANGIBLEID
	                       FROM   IBY_TRANS_ALL_V ITAV
	                       WHERE  ITAV.REQTYPE    = 'ORAPMTREQ'
	                       AND    ITAV.ECAPPID   <> 660
	                       AND    ITAV.AUTHCODE   = l_credit_card_approval_code
	                       AND    trunc(ITAV.UPDATEDATE) = trunc(l_credit_card_approval_date) --5932506
	                       AND   (ITAV.REFINFO IS NULL
                                OR    ITAV.REFINFO <> l_ref_info));
	     */
--Bug 6770094
               UPDATE IBY_TANGIBLE IT
                     SET    IT.REFINFO  = l_ref_info
                     WHERE  IT.TANGIBLEID IN
                           (SELECT DISTINCT ITAV.TANGIBLEID
                            FROM   IBY_TRANS_ALL_V ITAV
                            WHERE  ITAV.REQTYPE    = 'ORAPMTREQ'
                            AND    ITAV.AUTHCODE   = l_credit_card_approval_code
                            AND    trunc(ITAV.UPDATEDATE) = trunc(l_credit_card_approval_date)
                            AND  ((    ITAV.ECAPPID  = 697
                                   AND ITAV.REFINFO  = p_header_rec.source_document_id)
                             OR   (    ITAV.ECAPPID  NOT IN (660, 697, 222, 673)
                                   AND NVL(ITAV.REFINFO, -99) <> l_ref_info)));
--Bug 6770094

-- Bug 6700106


        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPVPMB: UPDATED '||SQL%ROWCOUNT||' ROWS.' ) ;
        END IF;

        EXCEPTION
	     WHEN OTHERS THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OEXPVPMB: UNEXPECTED ERROR UPDATING REFINFO.' ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OEXPVPMB: ERROR: '||SQLERRM ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end;

    END IF;

    -- Create the query string
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: SQL STATEMENT TO FETCH TRXN BASED ON ORDER AUTH CODE' ) ;
    END IF;
    --
    l_sql_stmt := 'SELECT TRANSACTIONID, TANGIBLEID
                   FROM  (SELECT A.TRANSACTIONID, A.TANGIBLEID
                          FROM   IBY_TRANS_ALL_V A
                          WHERE  A.AUTHCODE = :auth_code
                          AND    trunc(A.UPDATEDATE) = trunc(:auth_date) --5932506
                          AND    A.REQTYPE  = ''ORAPMTREQ''
                          AND    A.STATUS   = 0
                          AND    A.REFINFO  = :ref_info
                          AND    NOT
                                 EXISTS (SELECT ''Trxn Already Voided''
                                         FROM  IBY_TRANS_ALL_V B
                                         WHERE B.TANGIBLEID = A.TANGIBLEID
                                         AND   B.REQTYPE    = ''ORAPMTVOID''
                                         AND   B.STATUS     = 0)
                          ORDER  BY A.UPDATEDATE DESC)
                    WHERE ROWNUM = 1';

    --OE_DEBUG_PUB.ADD(l_sql_stmt);

    begin
      EXECUTE IMMEDIATE l_sql_stmt
                   INTO p_trxn_id, p_tangible_id
	             USING l_credit_card_approval_code
                    ,     l_credit_card_approval_date
                  ,     l_ref_info;
      EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		p_trxn_id := 0;
	   WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: UNEXPECTED ERROR IN FETCH_CURRENT_AUTH.' ) ;
          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPVPMB: ERROR: '||SQLERRM ) ;
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: FOUND TRXN WITH TANGBILE ID '||P_TANGIBLE_ID ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: EXITING FETCH CURRENT AUTHORIZATION' ) ;
  END IF;

END Fetch_Current_Auth;

/*----------------------------------------------------------------------
Fetches the Last Authorization Transaction for the Order
----------------------------------------------------------------------*/
PROCEDURE Fetch_Last_Auth
(  p_header_rec      IN   OE_Order_PUB.Header_Rec_Type
,  p_trxn_id         OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_tangible_id     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_auth_code       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_trxn_date       OUT NOCOPY /* file.sql.39 change */  DATE
,  p_amount          OUT NOCOPY /* file.sql.39 change */  NUMBER
)
IS
l_sql_stmt    VARCHAR2(5000);
l_req_date    DATE;
l_ref_info    VARCHAR2(80) :=TO_CHAR(p_header_rec.header_id);
l_est_valid_days   NUMBER  := 0 ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN FETCH LAST AUTHORIZATION' ) ;
  END IF;

  /*
  ** We don't want to trigger following processing if user is
  ** using the Authorize Payment action.
  */
  IF p_header_rec.credit_card_approval_code is null
  AND p_header_rec.credit_card_approval_date is not null THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: EXITING FETCH LAST AUTH , AUTH PAYMENT ACTION' ) ;
    END IF;
    RETURN;
  END IF;

  -- Query the data related to last authorized trxn for this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SQL FOR QUERYING THE LAST AUTHORIZED TRXN' ) ;
  END IF;
  --
  -- Create the query string
  l_sql_stmt := 'SELECT TRANSACTIONID, TANGIBLEID, AUTHCODE, UPDATEDATE, AMOUNT
                 FROM (SELECT A.TRANSACTIONID, A.TANGIBLEID, A.AUTHCODE, A.UPDATEDATE, A.AMOUNT
                       FROM IBY_TRANS_ALL_V A
                       WHERE A.REFINFO = :ref_info
                       AND   A.REQTYPE = ''ORAPMTREQ''
                       AND   A.ECAPPID = 660
                       AND   A.STATUS  = 0
                       AND   A.AUTHCODE IS NOT NULL
                       AND   NOT
                             EXISTS (SELECT ''Trxn Already Captured or Voided''
                                     FROM  IBY_TRANS_ALL_V B
                                     WHERE B.TANGIBLEID = A.TANGIBLEID
                                     AND ((B.REQTYPE    = ''ORAPMTVOID'')
                                      OR  (B.REQTYPE    = ''ORAPMTCAPTURE'')
                                      OR  (B.REQTYPE    = ''ORAPMTREQ''
                                      AND  B.AUTHTYPE   = ''AUTHCAPTURE''))
                                     AND   B.STATUS     = 0)
                       ORDER  BY A.UPDATEDATE DESC)
                 WHERE  ROWNUM = 1';

  --OE_DEBUG_PUB.ADD(l_sql_stmt);

  begin
    EXECUTE IMMEDIATE l_sql_stmt
                 INTO p_trxn_id, p_tangible_id, p_auth_code, p_trxn_date, p_amount
                USING l_ref_info;
    EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	   p_trxn_id := 0;
  end;

  IF p_trxn_id > 0 then

    -- Fetch the value for profile "OM: Estimated Authorization Validity Period"
    -- This is required to estimate the validity of Authorization which might
    -- have been taken through iPayment, but was not updated on the order header.
    l_est_valid_days := to_number( nvl(fnd_profile.value('ONT_EST_AUTH_VALID_DAYS'), '0') ) ;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: FETCH_LAST_AUTH , ESTIMATED AUTH VALIDITY PERIOD : '|| L_EST_VALID_DAYS ) ;
    END IF;

    IF (p_trxn_date + l_est_valid_days > SYSDATE) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: VALID AUTH ALREADY EXISTS , TANGIBLEID '||P_TANGIBLE_ID ) ;
      END IF;

    ELSE

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: NO PREVIOUS AUTH EXISTS' ) ;
      END IF;

      p_trxn_id   := 0;
      p_auth_code := null;
      p_trxn_date := null;
      p_amount    := null;
    END IF;

  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: EXITING FETCH LAST AUTHORIZATION' ) ;
  END IF;

END Fetch_Last_Auth;

/*----------------------------------------------------------------------
Updates Order Header with Authorized Amount, Authorization Code and DATE
----------------------------------------------------------------------*/
PROCEDURE Update_Authorization_Info
( p_header_id        IN   NUMBER
, p_auth_amount      IN   NUMBER
, p_auth_code        IN   VARCHAR2
, p_auth_date        IN   DATE
, p_msg_count        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_msg_data	      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_return_status    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_index                  NUMBER := 1;
l_notify_index           NUMBER := 1;  -- jolin
l_line_id                NUMBER;
l_header_rec             OE_ORDER_PUB.Header_Rec_Type;
l_old_header_rec         OE_ORDER_PUB.Header_Rec_Type;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_control_rec            OE_GLOBALS.Control_Rec_Type;
l_return_status          VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SAVEPOINT Update_Authorization_Info;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN UPDATE AUTHORIZATION INFORMATION' ) ;
  END IF;

  -- Set up the Header record
  OE_Header_Util.Lock_Row
		(p_header_id			=> p_header_id
		,p_x_header_rec		=> l_old_header_rec
		,x_return_status		=> l_return_status
		);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_header_rec := l_old_header_rec;

  l_header_rec.header_id                 := p_header_id;
  l_header_rec.credit_card_approval_code := p_auth_code;
  l_header_rec.credit_card_approval_date := p_auth_date;
  l_header_rec.last_updated_by		 := FND_GLOBAL.USER_ID;
  l_header_rec.last_update_date		 := SYSDATE;
  l_header_rec.last_update_login		 := FND_GLOBAL.LOGIN_ID;
  l_header_rec.lock_control		      := l_header_rec.lock_control + 1;
  l_header_rec.operation                 := OE_GLOBALS.G_OPR_UPDATE;

  -- Header needs to be requeried, setting the flag to true
  OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: UPDATING FIELDS ON HEADER' ) ;
  END IF;

  update oe_order_headers
  set credit_card_approval_code = p_auth_code
    , credit_card_approval_date = p_auth_date
    , last_updated_by = FND_GLOBAL.USER_ID
    , last_update_date = SYSDATE
    , last_update_login = FND_GLOBAL.LOGIN_ID
    , lock_control = lock_control + 1
  where header_id = p_header_id;

  -- aksingh performance
  -- As the update is on headers table, it is time to update
  -- cache also!
  OE_Order_Cache.Set_Order_Header(l_header_rec);

  -- Bug 1755817: clear the cached constraint results for header entity
  -- when order header is updated.
  OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
       (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);

-- jolin start
IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    -- call notification framework to get header index position
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_header_rec		=> l_header_rec
	, p_old_header_rec	=> l_old_header_rec
        , p_header_id 		=> l_header_rec.header_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FOR HDR IS: ' || L_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HDR INDEX IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

   IF l_notify_index is not null then
     -- modify Global Picture

    OE_ORDER_UTIL.g_header_rec.payment_amount:=
					l_header_rec.payment_amount;
    OE_ORDER_UTIL.g_header_rec.credit_card_approval_code:=
					l_header_rec.credit_card_approval_code;
    OE_ORDER_UTIL.g_header_rec.credit_card_approval_date:=
					l_header_rec.credit_card_approval_date;
    OE_ORDER_UTIL.g_header_rec.last_updated_by:=l_header_rec.last_updated_by;
    OE_ORDER_UTIL.g_header_rec.last_update_login:=l_header_rec.last_update_login;
    OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
    OE_ORDER_UTIL.g_header_rec.lock_control:=	l_header_rec.lock_control;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'GLOBAL HDR PAYMENT_AMOUNT IS: ' || OE_ORDER_UTIL.G_HEADER_REC.PAYMENT_AMOUNT , 1 ) ;
		END IF;
		--IF l_debug_level  > 0 THEN
		    --oe_debug_pub.add(  'GLOBAL HDR CC APPROVAL_CODE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.CREDIT_CARD_APPROVAL_CODE , 1 ) ;
		--END IF;
		--IF l_debug_level  > 0 THEN
		    --oe_debug_pub.add(  'GLOBAL HDR CC APPROVAL_DATE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.CREDIT_CARD_APPROVAL_DATE , 1 ) ;
		--END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Process requests is TRUE so still need to call it, but don't need to notify
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
  OE_Order_PVT.Process_Requests_And_Notify
	( p_process_requests		=> TRUE
	, p_notify			=> FALSE
	, p_header_rec			=> l_header_rec
	, p_old_header_rec		=> l_old_header_rec
	, x_return_status		=> l_return_status
	);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF ; /* global entity index null check */

ELSE /* pre- pack H */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
  OE_Order_PVT.Process_Requests_And_Notify
	( p_process_requests		=> TRUE
	, p_notify			=> TRUE
	, p_header_rec			=> l_header_rec
	, p_old_header_rec		=> l_old_header_rec
	, x_return_status		=> l_return_status
	);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- notification framework end
END IF; /* code set is pack H or higher */
/* jolin end*/

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	 ROLLBACK TO Update_Authorization_Info;
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO Update_Authorization_Info;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
	 ROLLBACK TO Update_Authorization_Info;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Authorization_Info'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Update_Authorization_Info ;

/*----------------------------------------------------------------------
Returns the Total Captured Amount for the Order.
----------------------------------------------------------------------*/
FUNCTION Captured_Amount_Total
(  p_header_id      IN   Number )
RETURN NUMBER
IS
l_sql_stmt    VARCHAR2(1000) := NULL;
l_captured    NUMBER;
l_ref_info    VARCHAR2(80)   := TO_CHAR(p_header_id);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CAPTURED AMOUNT TOTAL' ) ;
  END IF;

  -- Create the query string
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: SQL STATEMENT TO FETCH TOTAL AMOUNT CAPTURED FOR THE ORDER' ) ;
  END IF;
  --
  l_sql_stmt := 'SELECT NVL(SUM(AMOUNT), 0)
                 FROM   IBY_TRANS_ALL_V
                 WHERE  REFINFO  = :ref_info
			  AND    STATUS   = 0
                 AND  ((REQTYPE = ''ORAPMTCAPTURE'')
				OR (REQTYPE = ''ORAPMTREQ'' AND AUTHTYPE = ''AUTHCAPTURE''))';

  --OE_DEBUG_PUB.ADD(l_sql_stmt);

  begin
    EXECUTE IMMEDIATE l_sql_stmt
                 INTO l_captured
                USING l_ref_info ;
  end;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: EXITING CAPTURED AMOUNT TOTAL' ) ;
  END IF;

  RETURN (l_captured);

END Captured_Amount_Total;

PROCEDURE Authorize_MultiPayments
(   p_header_rec             IN   OE_Order_PUB.Header_Rec_Type
,   p_line_id                IN   NUMBER DEFAULT null --bug3524209
,   p_calling_action         IN   VARCHAR2
--comm rej,   p_reject_on_auth_failure IN VARCHAR2 DEFAULT NULL --R12 CC Encryption
--comm rej,   p_reject_on_risk_failure IN VARCHAR2 DEFAULT NULL
,   p_risk_eval_flag	     IN VARCHAR2 DEFAULT  NULL --'Y'
,   p_msg_count              OUT NOCOPY /* file.sql.39 change */  NUMBER
,   p_msg_data               OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_result_out             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_auth_code         		VARCHAR2(80);
l_trxn_date         		DATE;
l_msg_count         		NUMBER := 0 ;
l_msg_data          		VARCHAR2(2000) := NULL ;
l_return_status     		VARCHAR2(30) := NULL;
l_result_status     		VARCHAR2(30) := NULL;
l_format_mask	     		VARCHAR2(500);
l_amount_to_authorize     	NUMBER := 0;
l_reauthorize_flag   		VARCHAR2(1);
l_pay_method_id      		NUMBER;
l_pay_method_name		VARCHAR2(50);
l_merchant_id        		NUMBER;
l_payee_id           		VARCHAR2(80);
l_tangible_id        		VARCHAR2(80);
l_time_of_purchase   		VARCHAR2(10);
l_risk_threshold	 	NUMBER := 0 ;
l_riskresp_included  		VARCHAR2(30);
l_risk_score         		NUMBER := 0 ;
l_result_out         		VARCHAR2(30) := NULL ;
l_hold_exists        		VARCHAR2(1);
l_line_rec          		OE_Order_PUB.Line_Rec_Type;
l_ordered_date      		DATE;
l_currency_code     		VARCHAR2(15);
l_line_total			NUMBER := 0;
l_order_total			NUMBER := 0;

l_invoice_to_org_id		NUMBER;
l_ship_to_org_id		NUMBER;
l_line_id			NUMBER;
l_payments_tbl	        	OE_ORDER_PUB.Line_Payment_Tbl_Type;
l_count				NUMBER;
i				PLS_INTEGER;
l_prepaid_total			NUMBER;
l_outbound_total		NUMBER;
l_outbound_total_no_comt 	NUMBER;
l_downpayment 			NUMBER;
l_hold_result   		VARCHAR2(30);

--bug3225795 start
l_inv_interface_status_code     VARCHAR2(30) := 'NO';
l_inv_lines_total               NUMBER := 0;
l_line_total_exc_comt           NUMBER := 0;
l_balance_on_prepay             NUMBER := 0;
--bug3225795 end

--R12 CC Encryption
l_trxn_extension_id  	NUMBER;
l_payer		     	IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
l_payee_rec	     	IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
l_party_id	     	NUMBER;
l_org_type	     	VARCHAR2(30) := 'OPERATING_UNIT';
l_payment_function   	VARCHAR2(30) := 'CUSTOMER_PAYMENT';
l_result_rec	     	IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_auth_result	     	IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
l_amount	     	IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
l_auth_attribs       	IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
l_response	     	IBY_FNDCPT_COMMON_PUB.Result_rec_type;
l_RiskEval_Enable_Flag 	VARCHAR2(1) := 'N';
l_err_message	     	VARCHAR2(2000);
l_cust_account_id    	NUMBER;
--Verify
x_invoice_to_org_id  	NUMBER;
x_ship_from_org_id   	NUMBER;
x_ship_to_org_id     	NUMBER;
--R12 CC Encryption
--
l_debug_level CONSTANT 	NUMBER := oe_debug_pub.g_debug_level;
--

-- get line level credit card payments.
CURSOR line_payments_cur(p_header_id IN NUMBER) IS
SELECT line_id
      ,trxn_extension_id
      /*,credit_card_number --R12 CC Encryption
      ,credit_card_holder_name
      ,credit_card_expiration_date
      ,credit_card_approval_code
      ,credit_card_approval_date
      ,tangible_id*/
      ,receipt_method_id
      ,payment_number
      ,defer_payment_processing_flag
FROM   oe_payments
WHERE  payment_type_code = 'CREDIT_CARD'
AND    header_id = p_header_id
AND    line_id IS NOT NULL;

-- get header level credit card payments
CURSOR header_payments_cur(p_header_id IN NUMBER) IS
SELECT payment_number
      ,trxn_extension_id
      /*,credit_card_number  --R12 CC Encryption
      ,credit_card_holder_name
      ,credit_card_expiration_date
      ,credit_card_approval_code
      ,credit_card_approval_date
      ,tangible_id*/
      ,receipt_method_id
      ,defer_payment_processing_flag
FROM  oe_payments
WHERE payment_type_code = 'CREDIT_CARD'
AND   payment_collection_event = 'INVOICE'
AND   line_id is null
AND   header_id = p_header_id;

--bug3524209 New cursor for getting the line_payments given the line_id
CURSOR line_payments_cur_for_line(p_line_id IN NUMBER, p_header_id IN NUMBER) IS
SELECT line_id
      ,trxn_extension_id
      /*,credit_card_number --R12 CC Encryption
      ,credit_card_holder_name
      ,credit_card_expiration_date
      ,credit_card_approval_code
      ,credit_card_approval_date
      ,tangible_id*/
      ,receipt_method_id
      ,payment_number
      ,defer_payment_processing_flag
FROM   oe_payments
WHERE  payment_type_code = 'CREDIT_CARD'
AND    line_id = p_line_id
AND    header_id = p_header_id;

--R12 CC Encryption

--bug3225795 changing the following cursor to look into oe_order_lines_all
-- get those lines paid with payments other than the main one.
CURSOR lines_cur(p_header_id IN NUMBER) IS
SELECT line_id
FROM   oe_order_lines_all
WHERE  header_id = p_header_id
AND    payment_type_code IS NOT NULL
AND    payment_type_code <> 'COMMITMENT'
AND    nvl(invoice_interface_status_code,'NO') <> 'YES';

--bug3225795 New cursor to fetch all the invoiced lines given the header_id
CURSOR inv_lines_cur(p_header_id IN NUMBER) IS
SELECT line_id
FROM   oe_order_lines_all
WHERE  header_id = p_header_id
AND    nvl(invoice_interface_status_code,'NO') = 'YES';


BEGIN

  p_result_out := 'PASS' ;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN AUTHORIZE MULTIPLE PAYMENTS' ) ;
  END IF;

  IF OE_GLOBALS.G_IPAYMENT_INSTALLED IS NULL THEN

     OE_GLOBALS.G_IPAYMENT_INSTALLED := OE_GLOBALS.CHECK_PRODUCT_INSTALLED(673);
  END IF;

  IF OE_GLOBALS.G_IPAYMENT_INSTALLED <> 'Y' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPVPMB: IPAYMENT IS NOT INSTALLED!' , 3 ) ;
     END IF;
     RETURN;
  END IF;

  l_ordered_date := nvl(p_header_rec.ordered_date, sysdate);
  l_currency_code := p_header_rec.transactional_curr_code;

	       l_count := 1;
           --bug3524209
	   IF(p_line_id IS NULL) THEN
	       FOR c_payments_rec IN line_payments_cur(p_header_rec.header_id) LOOP
		 IF l_debug_level  > 0 THEN
		   oe_debug_pub.add(  'OEXPVPMB: In line_payments_cur', 5 ) ;
		 END IF;
		 --R12 CC Encryption
		 l_payments_tbl(l_count).line_id := c_payments_rec.line_id;
		 l_payments_tbl(l_count).trxn_extension_id := c_payments_rec.trxn_extension_id;
		 /*l_payments_tbl(l_count).credit_card_number := c_payments_rec.credit_card_number;
		 l_payments_tbl(l_count).credit_card_holder_name
				   := c_payments_rec.credit_card_holder_name;
		 l_payments_tbl(l_count).credit_card_expiration_date
				   := c_payments_rec.credit_card_expiration_date;
		 l_payments_tbl(l_count).credit_card_approval_code
				   := c_payments_rec.credit_card_approval_code;
		 l_payments_tbl(l_count).credit_card_approval_date
				   := c_payments_rec.credit_card_approval_date;
		 l_payments_tbl(l_count).tangible_id := c_payments_rec.tangible_id;*/
		 --R12 CC Encryption
		 l_payments_tbl(l_count).receipt_method_id := c_payments_rec.receipt_method_id;
		 l_payments_tbl(l_count).payment_number := c_payments_rec.payment_number;
		 l_payments_tbl(l_count).defer_payment_processing_flag := c_payments_rec.defer_payment_processing_flag;
		 l_count := l_count + 1;
	       END LOOP;

	       FOR c_payments_rec IN header_payments_cur(p_header_rec.header_id) LOOP
		 IF l_debug_level  > 0 THEN
		   oe_debug_pub.add(  'OEXPVPMB: In header_payments_cur', 5 ) ;
		 END IF;
		 l_payments_tbl(l_count).payment_number := c_payments_rec.payment_number;
		 --R12 CC Encryption
		 l_payments_tbl(l_count).trxn_extension_id := c_payments_rec.trxn_extension_id;
		 /*
		 l_payments_tbl(l_count).credit_card_number := c_payments_rec.credit_card_number;
		 l_payments_tbl(l_count).credit_card_holder_name
				   := c_payments_rec.credit_card_holder_name;
		 l_payments_tbl(l_count).credit_card_expiration_date
				   := c_payments_rec.credit_card_expiration_date;
		 l_payments_tbl(l_count).credit_card_approval_code
				   := c_payments_rec.credit_card_approval_code;
		 l_payments_tbl(l_count).credit_card_approval_date
				   := c_payments_rec.credit_card_approval_date;
		 l_payments_tbl(l_count).tangible_id := c_payments_rec.tangible_id;
                 */
		 --R12 CC Encryption
		 l_payments_tbl(l_count).receipt_method_id := c_payments_rec.receipt_method_id;
		 l_payments_tbl(l_count).defer_payment_processing_flag := c_payments_rec.defer_payment_processing_flag;
		 l_count := l_count + 1;
	       END LOOP;
            --bug3524209 start
	    ELSE
	        FOR c_payments_rec IN line_payments_cur_for_line(p_line_id, p_header_rec.header_id) LOOP
		 IF l_debug_level  > 0 THEN
		   oe_debug_pub.add(  'OEXPVPMB: In line_payments_cur_for_line', 5 ) ;
		 END IF;
		 l_payments_tbl(l_count).line_id := c_payments_rec.line_id;
		 --R12 CC Encryption
		 l_payments_tbl(l_count).trxn_extension_id := c_payments_rec.trxn_extension_id;
		 /*
		 l_payments_tbl(l_count).credit_card_number := c_payments_rec.credit_card_number;
		 l_payments_tbl(l_count).credit_card_holder_name
				   := c_payments_rec.credit_card_holder_name;
		 l_payments_tbl(l_count).credit_card_expiration_date
				   := c_payments_rec.credit_card_expiration_date;
		 l_payments_tbl(l_count).credit_card_approval_code
				   := c_payments_rec.credit_card_approval_code;
		 l_payments_tbl(l_count).credit_card_approval_date
				   := c_payments_rec.credit_card_approval_date;
		 l_payments_tbl(l_count).tangible_id := c_payments_rec.tangible_id;
                 */
		 --R12 CC Encryption
		 l_payments_tbl(l_count).receipt_method_id := c_payments_rec.receipt_method_id;
		 l_payments_tbl(l_count).payment_number := c_payments_rec.payment_number;
		 l_payments_tbl(l_count).defer_payment_processing_flag := c_payments_rec.defer_payment_processing_flag;
		 l_count := l_count + 1;
	       END LOOP;
	    END IF;
            --bug3524209 end

	    IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'OEXPVPMB.pls: Total count l_payment_tbl is : '||l_payments_tbl.COUNT);
	    END IF;

	    I := l_payments_tbl.FIRST;
	    WHILE I IS NOT NULL LOOP
	      IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('OEXPVPMB: Looping through payment records: '||I, 3);
	      END IF;
	      l_result_status := 'PASS' ;
              l_amount_to_authorize := 0;
	       IF l_payments_tbl(I).line_id IS NOT NULL THEN
		 -- place on line level CC authorization hold.
	         IF l_debug_level  > 0 THEN
	           oe_debug_pub.add('OEXPVPMB: processing authorization for line: '||l_payments_tbl(I).line_id, 3);
	         END IF;
		 IF p_calling_action IS NOT NULL
                    AND p_calling_action NOT IN ('SHIPPING','PACKING' ,'PICKING')
		    AND nvl(l_payments_tbl(I).defer_payment_processing_flag, 'N') = 'Y' THEN
		   IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  'OEXPVPMB: place order on Defer Payment Authorization hold for line: '||l_payments_tbl(I).line_id , 1 ) ;
		   END IF;
		   OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
		     ( p_header_id     => p_header_rec.header_id
		     , p_line_id       => l_payments_tbl(I).line_id
		     , p_hold_id       => 16
		     , p_msg_count     => l_msg_count
		     , p_msg_data      => l_msg_data
		     , p_return_status => l_return_status
		     );
		   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		     RAISE FND_API.G_EXC_ERROR;
		   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		   END IF;
		   goto Next_In_Loop;
		 END IF;

	      --bug3225795 start
              BEGIN
		 SELECT invoice_interface_status_code
		 INTO   l_inv_interface_status_code
		 FROM   oe_order_lines_all
		 WHERE  line_id = l_payments_tbl(I).line_id;
              EXCEPTION
		 WHEN NO_DATA_FOUND THEN
		    null;
	      END;

              IF nvl(l_inv_interface_status_code,'NO') <> 'YES' THEN
              --bug3225795 end
	            l_amount_to_authorize := l_amount_to_authorize +
		 	Get_Line_Total
                        ( p_line_id          	=> l_payments_tbl(I).line_id
                         ,p_header_id		=> p_header_rec.header_id
                         ,p_currency_code	=> l_currency_code
                         ,p_level		 => 'LINE'
                        );
               --bug3225795 start
               ELSE
                    l_amount_to_authorize :=0;
               END IF;
	       --bug3225795 end


	      IF l_debug_level  > 0 THEN
	        oe_debug_pub.add('OEXPVPMB: amount to authorize for line level is: '||l_amount_to_authorize, 3);
	      END IF;
     ELSE
       -- header level authorization.
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OEXPVPMB: processing header level authorization.', 3);
       END IF;
       IF p_calling_action IS NOT NULL
          AND p_calling_action NOT IN ('SHIPPING','PACKING' ,'PICKING')
          AND nvl(l_payments_tbl(I).defer_payment_processing_flag,'N') = 'Y' THEN
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPVPMB: place order on Defer Payment Authorization hold for header: '||l_payments_tbl(I).header_id , 1 ) ;
         END IF;

         -- place on header level CC authorization hold.
         OE_Verify_Payment_PUB.Apply_Verify_Hold
             ( p_header_id     => p_header_rec.header_id
             , p_hold_id       => 16
             , p_msg_count     => l_msg_count
             , p_msg_data      => l_msg_data
             , p_return_status => l_return_status
             );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         goto Next_In_Loop;
       END IF;

       -- Get the amount to be authorized for header multiple payments
       -- need to exclude total prepaid amount from authorization.
       -- we sum up payment_amount instead of prepaid_amount here
       -- as we need to include those deferred prepayment as well.
      BEGIN
      SELECT sum(nvl(payment_amount, 0))
      INTO   l_prepaid_total
      FROM   oe_payments
      WHERE  payment_collection_event = 'PREPAY'
      AND    header_id = p_header_rec.header_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_prepaid_total := 0;
      END;

      --bug3225795 start
      FOR c_inv_line_rec IN inv_lines_cur(p_header_rec.header_id) LOOP
        l_inv_lines_total := l_inv_lines_total + Get_Inv_Line_Total
                                         (p_line_id               => c_inv_line_rec.line_id
					 ,p_header_id             => p_header_rec.header_id
					 ,p_currency_code         => null
					 ,p_level                 => 'HEADER'
					 ,p_to_exclude_commitment => 'Y'
					 );
      END LOOP;

      IF l_prepaid_total > nvl(l_inv_lines_total,0) THEN
	 l_balance_on_prepay := l_prepaid_total - nvl(l_inv_lines_total,0);
      ELSE
	 l_balance_on_prepay := 0;
      END IF;
      --bug3225795 end

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('In Authorize_Multipayments: l_prepaid_total is : '||l_prepaid_total);
      END IF;

      -- Get the line total amount paid with payments other than the main one.
      FOR c_line_rec IN lines_cur(p_header_rec.header_id) LOOP
	--pnpl l_line_total is not required anymore
        /*
        l_line_total := l_line_total + Get_Line_Total
                              ( p_line_id      		=> c_line_rec.line_id
                               ,p_header_id		=> p_header_rec.header_id
                               ,p_currency_code		=> null --bug3225795
                               ,p_level 		=> 'HEADER'
			       ,p_to_exclude_commitment => 'N' --bug3225795
                              );
        */
	--bug3225795 start
        l_line_total_exc_comt := l_line_total_exc_comt + Get_Line_Total
                                      ( p_line_id      	       => c_line_rec.line_id
				      ,p_header_id	       => p_header_rec.header_id
				      ,p_currency_code         => null
				      ,p_level 		       => 'HEADER'
				      ,p_to_exclude_commitment => 'Y'
                              );
	--bug3225795 end
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('In lines_cur: line_id is : '||c_line_rec.line_id);
	--bug3225795
        oe_debug_pub.add('In lines_cur: l_line_total_exc_comt is : '||l_line_total_exc_comt );
      END IF;
      END LOOP;

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('In Authorize_Multipayments: l_line_total to exclude is : '||l_line_total_exc_comt);
      END IF;

      -- commitment applied amount has already been taken out from outbound total,
      -- no need to exclude commitment again here.

      -- l_outbound_total := OE_OE_TOTALS_SUMMARY.Outbound_Order_Total(p_header_rec.header_id);

      -- l_amount_to_authorize := l_outbound_total- nvl(l_prepaid_total,0) - nvl(l_line_total,0);

      --pnpl l_outbound_total_no_comt is not needed as the function Outbound_Order_Total takes care of returning the proper value based on the value in OE_PREPAYMENT_UTIL.Get_Installment_Options
      /*
      l_outbound_total_no_comt := Outbound_Order_Total --bug3225795
                                   (p_header_id             =>p_header_rec.header_id,
                                    p_to_exclude_commitment => 'N');
      */
      --bug3225795 start
      l_outbound_total := Outbound_Order_Total
                           (p_header_id             =>p_header_rec.header_id,
                            p_to_exclude_commitment => 'Y');
      --bug3225795 end

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('In Authorize_Multipayments: l_outbound_total is : '||l_outbound_total);
      END IF;

      --pnpl  The Outbound_Order_Total takes care of returning the proper value depending on the value in OE_PREPAYMENT_UTIL.Get_Installment_Options
      l_amount_to_authorize := l_outbound_total - nvl(l_balance_on_prepay,0) - nvl(l_line_total_exc_comt,0);


    END IF; -- end of header level or line level authorization.

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXPVPMB: amount to authorize is : '||l_amount_to_authorize);
    END IF;

     -- For each order line call Check Reauthorize Order to find out
     -- if Reauthorization is required
     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPVPMB.pls: Before Checking Reauthorize Flag for Multiple Payments.');
     END IF;

     IF l_payments_tbl(I).line_id IS NOT NULL THEN
     BEGIN
       SELECT invoice_to_org_id, ship_to_org_id
       INTO   l_invoice_to_org_id,l_ship_to_org_id
       FROM   oe_order_lines_all
       WHERE  line_id = l_payments_tbl(I).line_id;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       null;
     END;
   ELSE
     BEGIN
       SELECT invoice_to_org_id, ship_to_org_id
       INTO   l_invoice_to_org_id,l_ship_to_org_id
       FROM   oe_order_headers_all
       WHERE  header_id = p_header_rec.header_id;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       null;
     END;
   END IF;

   IF l_debug_level  > 0 THEN  --bug 5209584
      oe_debug_pub.add('OEXPVPMB: Header ID      : '||p_header_rec.header_id, 3);
      oe_debug_pub.add('OEXPVPMB: Line ID        : '||l_payments_tbl(I).line_id, 3);
      oe_debug_pub.add('OEXPVPMB: Payment Number : '||l_payments_tbl(I).payment_number, 3);
   END IF;

    OE_Verify_Payment_PUB.Check_ReAuth_for_MultiPmnts
        ( p_credit_card_approval_code 	=> l_payments_tbl(I).credit_card_approval_code
        , p_trxn_extension_id	      	=> l_payments_tbl(I).trxn_extension_id
        , p_amount_to_authorize       	=> l_amount_to_authorize
        , p_org_id			=> p_header_rec.org_id
        , p_site_use_id			=> l_invoice_to_org_id
        , p_header_id                   => p_header_rec.header_id  --bug 5209584
        , p_line_id                     => l_payments_tbl(I).line_id
        , p_payment_number              => l_payments_tbl(I).payment_number
	, p_reauthorize_out           	=> l_reauthorize_flag
        , x_msg_count      		=> l_msg_count
        , x_msg_data       		=> l_msg_data
        , x_return_status  		=> l_return_status
	);


      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: for Multiple Payments reauthorize Flag is set to : '||L_REAUTHORIZE_FLAG) ;
      END IF;

  -- Check Reauthorize Flag and proceed
  IF l_reauthorize_flag = 'N' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: NO NEED TO REAUTHORIZE' ) ;
    END IF;

    -- Check if Hold already exists on this order
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECK IF ORDER ON RISK HOLD' ) ;
    END IF;
    --

    IF l_payments_tbl(I).line_id IS NULL THEN
      -- header level authorization
      OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_rec.header_id
                      , p_hold_id        => 12
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_rec.header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

    ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
      -- line level authorization
      OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_rec.header_id
                      , p_line_id        => l_payments_tbl(I).line_id
                      , p_hold_id        => 12
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_rec.header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );
    END IF;

    IF l_hold_result = FND_API.G_TRUE THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: ORDER IS ON RISK HOLD' ) ;
      END IF;
      l_result_status := 'RISK';
    END IF;

    -- RETURN;
    goto Update_Verify_Hold;

  END IF;

  -- this validation moved to the code below.
  /*
  IF NOT Validate_Required_Attributes(p_header_rec) THEN
    p_result_out := 'FAIL';
    RETURN;
  END IF;
  */


    -- Fetch Payment Method Name and Merchant Id based on the Method ID.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING GET PAY METHOD INFO' ) ;
    END IF;

    IF l_payments_tbl(I).receipt_method_id IS NOT NULL THEN
      l_pay_method_id := l_payments_tbl(I).receipt_method_id;
    ELSE
      -- get from the payment type setup first.
      BEGIN
      SELECT receipt_method_id
      INTO l_pay_method_id
      FROM oe_payment_types_all
      WHERE payment_type_code = 'CREDIT_CARD'
      AND nvl(org_id, -99) = nvl(p_header_rec.org_id, -99);
      EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
      END;

      IF l_pay_method_id IS NULL THEN
        l_pay_method_id := OE_Verify_Payment_PUB.Get_Primary_Pay_Method
                            ( p_header_rec => p_header_rec ) ;
      END IF;
    END IF;

  IF nvl(l_pay_method_id, 0) > 0 THEN
    Get_Pay_Method_Info
	( p_pay_method_id   => l_pay_method_id
	, p_pay_method_name => l_pay_method_name
	, p_merchant_ref    => l_payee_id
	) ;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: receipt method id is: '|| l_payments_tbl(I).receipt_method_id ) ;
    END IF;

    -- If Merchant Id is invalid then set the out result to FAIL and return
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: BEFORE CHECKING THE PAYEE ID' ) ;
    END IF;

-- Commenting the following IF condition for the sake of bug6532165

/*    IF l_payee_id is NULL THEN
      -- Message "Unable to retrieve Payee/Merchant  ID
      -- for Customer's Primary Payment Method"
      FND_MESSAGE.SET_NAME('ONT','OE_VPM_NO_PAYEE_ID');
      OE_MSG_PUB.ADD;
      l_result_status := 'FAIL' ;
      goto Update_Verify_Hold;
      -- RETURN;
    END IF;      */
  ELSE -- Method ID is invalid

    -- Message "Unable to retrieve Primary Payment Method for the customer"
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_NO_PAY_METHOD');
    OE_MSG_PUB.ADD;
    l_result_status := 'FAIL' ;
    goto Update_Verify_Hold;
    -- RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: PAYEE ID IS : '|| L_PAYEE_ID ) ;
  END IF;


  -- move this piece of code to above before calling check_reauth_for_multipmts
  /*
  IF l_payments_tbl(I).line_id IS NOT NULL THEN
    BEGIN
      SELECT invoice_to_org_id, ship_to_org_id
      INTO   l_invoice_to_org_id,l_ship_to_org_id
      FROM   oe_order_lines_all
      WHERE  line_id = l_payments_tbl(I).line_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
  ELSE
    BEGIN
      SELECT invoice_to_org_id, ship_to_org_id
      INTO   l_invoice_to_org_id,l_ship_to_org_id
      FROM   oe_order_headers_all
      WHERE  header_id = p_header_rec.header_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      null;
    END;
  END IF;
  */

  --R12 CC Encryption
  /*l_cust_trx_date := l_ordered_date
               - nvl( to_number(fnd_profile.value('ONT_DAYS_TO_BACKDATE_BANK_ACCT')), 0);*/
     -- IF p_line_id is null then
     IF l_payments_tbl(I).line_id IS NULL THEN
        IF l_debug_level  > 0 THEN
		oe_debug_pub.add('Before getting trxn id'||l_payments_tbl(I).line_id||' and '||p_header_rec.header_id);
	END IF;
	BEGIN
		select trxn_extension_id
			into l_trxn_extension_id
		FROM OE_PAYMENTS
		WHERE HEADER_ID = p_header_rec.header_id and line_id is null
		AND nvl(payment_collection_event,'PREPAY') = 'INVOICE'; --bug 5020737
	EXCEPTION WHEN NO_DATA_FOUND THEN
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('Trxn extension id is null.....');
		END IF;
	END;
	x_invoice_to_org_id := OE_Order_Cache.g_invoice_to_rec.org_id;
	x_ship_from_org_id := OE_Order_Cache.g_ship_to_rec.ship_from_org_id;  --Verify
	x_ship_to_org_id := OE_Order_Cache.g_ship_to_rec.org_id;
    ELSE
	BEGIN
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('Before getting trxn id else'||l_payments_tbl(I).line_id||' and '||p_header_rec.header_id);
		END IF;
		select trxn_extension_id
			into l_trxn_extension_id
		FROM OE_PAYMENTS
		WHERE line_id = l_payments_tbl(I).line_id
                AND   header_id = p_header_rec.header_id
                AND  payment_type_code <> 'COMMITMENT';

		SELECT invoice_to_org_id, ship_from_org_id, ship_to_org_id
		INTO   x_invoice_to_org_id, x_ship_from_org_id, x_ship_to_org_id
		FROM   oe_order_lines_all
		WHERE  line_id = l_payments_tbl(I).line_id;
	 EXCEPTION WHEN NO_DATA_FOUND THEN
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add('Trxn extension id....'||nvl(l_trxn_extension_id,'0'));
		END IF;
	END;
    END IF;

  -- Check For all Required Attributes
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: Checking required attributes for multiple payments.' ) ;
  END IF;

  IF l_invoice_to_org_id is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_INV_TO_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: INVOICE_TO_ORG_ID IS REQUIRED' ) ;
    END IF;
    l_result_status := 'FAIL';
    goto Update_Verify_Hold;
    -- return;
  ELSIF l_payments_tbl(I).trxn_extension_id is NULL THEN  --R12 CC Encryption
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_NUM_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_NUMBER IS REQUIRED' ) ;
    END IF;
    l_result_status := 'FAIL';
    goto Update_Verify_Hold;
    -- return;
  END IF;

  /*
  ELSIF l_payments_tbl(I).credit_card_expiration_date is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_EXP_DT_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_EXPIRATION_DATE IS REQUIRED' ) ;
    END IF;
    l_result_status := 'FAIL';
    goto Update_Verify_Hold;
    -- return;
  ELSIF l_payments_tbl(I).credit_card_holder_name is NULL THEN
    FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_HOLDER_REQUIRED');
    OE_MSG_PUB.ADD;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CREDIT_CARD_HOLDER_NAME IS REQUIRED' ) ;
    END IF;
    l_result_status := 'FAIL';
    goto Update_Verify_Hold;
    -- return;
  END IF;
  */
  --R12 CC Encryption

  -- Hour and Minutes after Mid Night in HH24:MM format
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: FETCHING HOUR AND MINUTES AFTER MIDNIGHT AS TIME OF PURCHASE' ) ;
  END IF;
  --
  SELECT TO_CHAR(sysdate, 'HH24:MI')
  INTO   l_time_of_purchase
  FROM   DUAL ;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: TIME OF PURCHASE AFTER MIDNIGHT HH24:MI IS : '|| L_TIME_OF_PURCHASE ) ;
  END IF;

  Begin
	/*Select	party_site.party_id, acct_site.cust_account_id
	Into 	l_party_id, l_cust_account_id
	From 	HZ_CUST_SITE_USES_ALL SITE,
		HZ_PARTY_SITES             PARTY_SITE,
		HZ_CUST_ACCT_SITES         ACCT_SITE  --Verify
	Where 	SITE.SITE_USE_ID = p_header_rec.invoice_to_org_id
	AND	SITE.SITE_USE_CODE  = 'BILL_TO'
	AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
	AND   	ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
	AND  	 SITE.ORG_ID = ACCT_SITE.ORG_ID;
        */

 	SELECT hca.party_id,acctsite.cust_account_id --acct_site.	cust_account_id, site.cust_acct_site_id
 	INTO l_party_id, l_cust_account_id
 	FROM hz_cust_acct_sites_all acctsite, hz_cust_site_uses_all site, hz_cust_accounts_all hca
 	WHERE SITE.SITE_USE_CODE = 'BILL_TO'
 	AND SITE.CUST_ACCT_SITE_ID = ACCTSITE.CUST_ACCT_SITE_ID
	AND ACCTSITE.cust_account_id = HCA.cust_account_id
 	AND SITE.SITE_USE_ID  = p_header_rec.invoice_to_org_id;

  Exception When No_Data_Found THEN
	Null;
  End;

IF l_debug_level  > 0 THEN
	oe_debug_pub.add('Amount populated...'||l_amount_to_authorize);
	oe_debug_pub.add('account site id'||x_invoice_to_org_id);
END IF;

l_payer.payment_function := l_payment_function ;
l_payer.party_id := l_party_id;
l_payer.org_type := l_org_type;
l_payer.org_id	 := p_header_rec.org_id;
-- 6524493 l_payer.cust_account_id	:= p_header_rec.sold_to_org_id; --Verify l_cust_account_id
l_payer.cust_account_id	:= l_cust_account_id; --6524493
l_payer.account_site_id	:= p_header_rec.invoice_to_org_id; -- Verify x_invoice_to_org_id;
l_amount.value := l_amount_to_authorize;
l_amount.currency_code := p_header_rec.transactional_curr_code;

l_auth_attribs.RiskEval_Enable_Flag := p_risk_eval_flag;
l_auth_attribs.shipFrom_SiteUse_Id := x_ship_from_org_id;
l_auth_attribs.shipTo_SiteUse_Id := x_ship_to_org_id;
l_auth_attribs.Receipt_Method_Id := l_pay_method_id;  --9093338


  l_payee_rec.org_id := p_header_rec.org_id;
  l_payee_rec.org_type := 'OPERATING_UNIT';

  IF l_debug_level >0 THEN
    oe_debug_pub.add('Before call to create auth trxn_extension_id is: '||l_trxn_extension_id);
    oe_debug_pub.add('Payee id is...'||l_payee_id);
    oe_debug_pub.add('Payer context values ...');
    oe_debug_pub.add('payment function'||l_payment_function);
    oe_debug_pub.add('l_payer.party_id'||l_party_id);
    oe_debug_pub.add('l_payer.org_type'||l_org_type);
    oe_debug_pub.add('l_payer.org_id'||p_header_rec.sold_to_org_id);
    oe_debug_pub.add('l_payer.account_site_id'||l_invoice_to_org_id);
    oe_debug_pub.add('Cust acct id'||l_cust_account_id);
    oe_debug_pub.add('amount is '||l_amount.value);
    oe_debug_pub.add('currency is '||l_amount.currency_code);
    oe_debug_pub.add('risk eval flag is '||l_auth_attribs.RiskEval_Enable_Flag);
    oe_debug_pub.add('ship from is '||l_auth_attribs.shipFrom_SiteUse_Id);
    oe_debug_pub.add('ship to is '||l_auth_attribs.shipTo_SiteUse_Id);
  END IF;


 IBY_Fndcpt_Trxn_Pub.Create_Authorization
(p_api_version		=> 1.0,
 x_return_status	=> l_return_status,
 x_msg_count		=> l_msg_count,
 x_msg_data		=> l_msg_data,
 p_payer		=> l_payer,
 p_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
 p_payee		=> l_payee_rec,
 p_trxn_entity_id	=> l_trxn_extension_id,
 p_auth_attribs		=> l_auth_attribs,
 p_amount		=> l_amount,
 x_auth_result		=> l_auth_result,
 x_response		=> l_response);


  --For bug 3571485
  l_format_mask := get_format_mask(p_header_rec.transactional_curr_code);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS AND
  l_response.result_code = 'AUTH_SUCCESS' THEN

	IF l_debug_level >0 THEN
		oe_debug_pub.add('Authorization successful....');
		oe_debug_pub.add('Risk flag Value :'||p_risk_eval_flag);
	END IF;

        -- moved release hold code here before applying risk hold for bug 4543147
	-- Release Any existing CC Holds
	IF l_payments_tbl(I).line_id IS NULL THEN
	        OE_Verify_Payment_PUB.Release_Verify_Hold
	                                 ( p_header_id     => p_header_rec.header_id
	                                 , p_epayment_hold => 'Y' -- We want to Release Credit Card Holds
	                                 , p_msg_count     => l_msg_count
	                                 , p_msg_data      => l_msg_data
	                                 , p_return_status => l_return_status
	                                 );

	 ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
	         OE_Verify_Payment_PUB.Release_Verify_Line_Hold
	                                 ( p_header_id     => p_header_rec.header_id
	                                 , p_line_id       => l_payments_tbl(I).line_id
	                                 , p_epayment_hold => 'Y' -- We want to Release Credit Card Holds
	                                 , p_msg_count     => l_msg_count
	                                 , p_msg_data      => l_msg_data
	                                 , p_return_status => l_return_status
	                                 );
	 END IF;

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	           RAISE FND_API.G_EXC_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	--Risk Score evaluation -- Bug 	6805953
	IF  nvl(p_risk_eval_flag, 'Y') = 'Y' THEN --change flag to p_risk_eval_flag l_RiskEval_Enable_Flag verify
--		l_risk_threshold := oe_sys_parameters.value('RISK_FACTOR_THRESHOLD');
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Risk threshold value....'||L_auth_result.risk_result.Risk_Threshold_Val);
			oe_debug_pub.add('Risk score...'||L_auth_result.risk_result.risk_score);
                        oe_debug_pub.add('Risky Flag : ' || L_auth_result.risk_result.risky_flag);
		END IF;
--		IF L_auth_result.risk_result.risk_score > l_risk_threshold THEN
                IF L_auth_result.risk_result.risky_flag = 'Y' Then
			IF l_debug_level >0 THEN
				oe_debug_pub.add('Risk threshold exceeded...!');
			END IF;

		--comm rej	IF nvl(p_reject_on_risk_failure, 'N') = 'N' THEN  --R12 CVV2
	 			-- the value for parameter param3  is Hold, then
				IF l_payments_tbl(I).line_id IS NULL THEN
                                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                                   THEN
					OE_Verify_Payment_PUB.Apply_Verify_Hold_and_Commit
					( p_header_id     => p_header_rec.header_id
					, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
					, p_msg_count     => l_msg_count
					, p_msg_data      => l_msg_data
					, p_return_status => l_return_status
					);

                                   ELSE
					OE_Verify_Payment_PUB.Apply_Verify_Hold
					( p_header_id     => p_header_rec.header_id
					, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
					, p_msg_count     => l_msg_count
					, p_msg_data      => l_msg_data
					, p_return_status => l_return_status
					);
                                   END IF;
				ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
                                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                                   THEN
					OE_Verify_Payment_PUB.Apply_Verify_Line_Hold_Commit
					( p_header_id     => p_header_rec.header_id
					, p_line_id	=> l_payments_tbl(I).line_id
					, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
					, p_msg_count     => l_msg_count
					, p_msg_data      => l_msg_data
					, p_return_status => l_return_status
					);
                                   ELSE
					OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
					( p_header_id     => p_header_rec.header_id
					, p_line_id	=> l_payments_tbl(I).line_id
					, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
					, p_msg_count     => l_msg_count
					, p_msg_data      => l_msg_data
					, p_return_status => l_return_status
					);
                                   END IF;
				END IF; -- line id is not null

				FND_MESSAGE.SET_NAME('ONT','ONT_CC_RISK_HOLD_APPLIED');
				OE_MSG_PUB.ADD;
				RETURN;

                                oe_debug_pub.add('after commented message');
		/*comm rej	ELSE
				IF l_debug_level >0 THEN
					oe_debug_pub.add('Risk validation failed...!');
				END IF;
				-- the value is reject, then
				FND_MESSAGE.SET_NAME('ONT','ONT_RISK_VALIDATION_FAILED');
				OE_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;
			END IF; --Reject flag
                  comm rej  */
		END IF; -- risk score > threshold
	END IF; --risk eval flag = y
        oe_debug_pub.add('before uncommented message');
	FND_MESSAGE.SET_NAME('ONT','ONT_PAYMENT_AUTH_SUCCESS');
	FND_MESSAGE.SET_TOKEN('AMOUNT',TO_CHAR(l_amount_to_authorize,l_format_mask));
	OE_MSG_PUB.ADD;
        oe_debug_pub.add('after uncommented message');
	IF l_debug_level >0 THEN
		oe_debug_pub.add('After risk evaluation...!');
	END IF;

        -- update the payment amount field on order header, this is for backward compatibility
        -- we used to show the authorized amount on order header. We have to update header
        -- table directly here as we did in 11i code, as the payment amount field is also
        -- used for Cash and Check payment type.
        -- if line_id is null, then this is for header invoice payment.
        IF l_payments_tbl(I).line_id IS NULL THEN
          UPDATE oe_order_headers_all
          SET    payment_amount = l_amount.value
                , last_updated_by = FND_GLOBAL.USER_ID
                , last_update_date = SYSDATE
                , last_update_login = FND_GLOBAL.LOGIN_ID
                , lock_control = lock_control + 1
          WHERE  header_id = p_header_rec.header_id
          AND    payment_type_code = 'CREDIT_CARD';
        END IF;


  --bug 4767915
  --A new message has been added for the scenario when the
  --authorization is successful but security code validation has failed
  ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND
  l_response.result_code = 'SECURITY_CODE_WARNING' THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Security code warning...');
		oe_debug_pub.add('Message returned by payments...'||l_response.result_message);
		oe_debug_pub.add('Result code...'||l_Response.result_code);
	END IF;


	IF l_payments_tbl(I).line_id IS NULL THEN
           IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
           THEN
		OE_Verify_Payment_PUB.Apply_Verify_Hold_and_Commit
		( p_header_id     => p_header_rec.header_id
		, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
		, p_msg_count     => l_msg_count
		, p_msg_data      => l_msg_data
		, p_return_status => l_return_status
		);

           ELSE
		OE_Verify_Payment_PUB.Apply_Verify_Hold
		( p_header_id     => p_header_rec.header_id
		, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
		, p_msg_count     => l_msg_count
		, p_msg_data      => l_msg_data
		, p_return_status => l_return_status
		);
          END IF;

          -- update order header with the authorized amount for header invoice payment.
          UPDATE oe_order_headers_all
          SET    payment_amount = l_amount.value
                , last_updated_by = FND_GLOBAL.USER_ID
                , last_update_date = SYSDATE
                , last_update_login = FND_GLOBAL.LOGIN_ID
                , lock_control = lock_control + 1
          WHERE  header_id = p_header_rec.header_id
          AND    payment_type_code = 'CREDIT_CARD';

	ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
           IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
           THEN
		OE_Verify_Payment_PUB.Apply_Verify_Line_Hold_Commit
		( p_header_id     => p_header_rec.header_id
		, p_line_id	=> l_payments_tbl(I).line_id
		, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
		, p_msg_count     => l_msg_count
		, p_msg_data      => l_msg_data
		, p_return_status => l_return_status
		);

           ELSE
		OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
		( p_header_id     => p_header_rec.header_id
		, p_line_id	=> l_payments_tbl(I).line_id
		, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
		, p_msg_count     => l_msg_count
		, p_msg_data      => l_msg_data
		, p_return_status => l_return_status
		);
           END IF;
	END IF; -- line id is not null

	FND_MESSAGE.SET_NAME('ONT','ONT_CC_SECURITY_CODE_FAILED');
	OE_MSG_PUB.ADD;
	RETURN;
  --bug 4767915
  /*  ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND
  l_response.result_code = 'RISK_THRESHOLD_EXCEEDED' THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Risk threshold exceeded...');
		oe_debug_pub.add('Value of risky flag...'||L_auth_result.risk_result.risky_flag);
	END IF;

	IF L_auth_result.risk_result.risky_flag = 'Y' Then
		IF l_debug_level >0 THEN
			oe_debug_pub.add('Risk threshold exceeded...inside risky flag!');
		END IF;

		IF l_payments_tbl(I).line_id IS NULL THEN
                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                   THEN
			OE_Verify_Payment_PUB.Apply_Verify_Hold_and_Commit
			( p_header_id     => p_header_rec.header_id
			, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
			, p_msg_count     => l_msg_count
			, p_msg_data      => l_msg_data
			, p_return_status => l_return_status
			);
                   ELSE
			OE_Verify_Payment_PUB.Apply_Verify_Hold
			( p_header_id     => p_header_rec.header_id
			, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
			, p_msg_count     => l_msg_count
			, p_msg_data      => l_msg_data
			, p_return_status => l_return_status
			);
                  END IF;
		ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                   THEN
			OE_Verify_Payment_PUB.Apply_Verify_Line_Hold_Commit
			( p_header_id     => p_header_rec.header_id
			, p_line_id	=> l_payments_tbl(I).line_id
			, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
			, p_msg_count     => l_msg_count
			, p_msg_data      => l_msg_data
			, p_return_status => l_return_status
			);
                   ELSE
			OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
			( p_header_id     => p_header_rec.header_id
			, p_line_id	=> l_payments_tbl(I).line_id
			, p_hold_id       => 12 -- Seeded Id for CC Risk Hold
			, p_msg_count     => l_msg_count
			, p_msg_data      => l_msg_data
			, p_return_status => l_return_status
			);
                   END IF;
		END IF; -- line id is not null

		FND_MESSAGE.SET_NAME('ONT','ONT_CC_RISK_HOLD_APPLIED');
		OE_MSG_PUB.ADD;
		RETURN;
	END IF;*/
  ELSE
	IF l_debug_level >0 THEN
		oe_debug_pub.add('Authorization failure...!'||l_return_status);
		oe_debug_pub.add('l_response.result_code'||l_response.result_code);
		oe_debug_pub.add('Message....'||l_response.result_message);
		oe_debug_pub.add('SQLERRM '||sqlerrm);
	END IF;

        l_result_status := 'FAIL';

	-- add messages to message stack.
	oe_msg_pub.add_text(p_message_text => l_response.result_message);

	-- apply credit card authorization hold in case of auth failure.
--comm rej	IF nvl(p_reject_on_auth_failure, 'N') = 'N' THEN
		IF l_payments_tbl(I).line_id IS NULL THEN
                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                   THEN
			OE_Verify_Payment_PUB.Apply_Verify_Hold_and_Commit
				( p_header_id     => p_header_rec.header_id
				, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
				, p_msg_count     => l_msg_count
				, p_msg_data      => l_msg_data
				, p_return_status => l_return_status
				 );

                   ELSE
			OE_Verify_Payment_PUB.Apply_Verify_Hold
				( p_header_id     => p_header_rec.header_id
				, p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
				, p_msg_count     => l_msg_count
				, p_msg_data      => l_msg_data
				, p_return_status => l_return_status
				 );
                   END IF;
		ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
                   IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
                   THEN
			OE_Verify_Payment_PUB.Apply_Verify_Line_Hold_Commit
				( p_header_id     => p_header_rec.header_id
				 , p_line_id       => l_payments_tbl(I).line_id
				 , p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
				 , p_msg_count     => l_msg_count
				 , p_msg_data      => l_msg_data
				 , p_return_status => l_return_status
			 );

                   ELSE
			OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
				( p_header_id     => p_header_rec.header_id
				 , p_line_id       => l_payments_tbl(I).line_id
				 , p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
				 , p_msg_count     => l_msg_count
				 , p_msg_data      => l_msg_data
				 , p_return_status => l_return_status
			 );
                   END IF;
		END IF;

		FND_MESSAGE.SET_NAME('ONT','ONT_CC_AUTH_HOLD_APPLIED');
		FND_MESSAGE.SET_TOKEN('AMOUNT',TO_CHAR(l_amount_to_authorize,l_format_mask));
		OE_MSG_PUB.ADD;

/*comm rej	ELSE
	       -- the value is to reject on failure, then
		-- raise error so the transaction will fail
		FND_MESSAGE.SET_NAME('ONT',' ONT_CC_AUTH_FAILED');				 			FND_MESSAGE.SET_TOKEN('AMOUNT',TO_CHAR(l_amount_to_authorize,l_format_mask));
		OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
comm rej*/
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

  END IF; --Return status of create_auth

  /*IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: AUTHORIZATION SUCCEEDED ...' ) ;
  END IF;

  --For bug 3571485
  l_format_mask := get_format_mask(p_header_rec.transactional_curr_code);

  --bug3511992 start
  FND_MESSAGE.SET_NAME('ONT','ONT_PAYMENT_AUTH_SUCCESS');
  FND_MESSAGE.SET_TOKEN('AMOUNT',TO_CHAR(l_amount_to_authorize,l_format_mask)); --Format mask for bug 3571485
  OE_MSG_PUB.ADD;*/
  --bug3511992 end

  <<UPDATE_AUTH_FOR_MULTIPMNTS>>
  -- Update Payment Amount and Authorization Code and DATE
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE UPDATING AUTHORIZATION INFO FOR MULTIPLE PAYMENT.' ) ;
      oe_debug_pub.add(  'OEXPVPMB: l_amount_to_authorize is: '||l_amount_to_authorize ) ;
      oe_debug_pub.add(  'OEXPVPMB: l_auth_code is: '||l_auth_code ) ;
      oe_debug_pub.add(  'OEXPVPMB: payment_number is: '||l_payments_tbl(I).payment_number ) ;
  END IF;
  --

/*
  IF l_result_status = 'PASS' THEN
    OE_Verify_Payment_PUB.Update_AuthInfo_for_MultiPmnts
		           (  p_header_rec.header_id
                            , l_amount_to_authorize
                            , l_auth_code
                            , l_trxn_date
                            , l_tangible_id
                            , l_payments_tbl(I).line_id
                            , l_payments_tbl(I).payment_number
                            , l_msg_count
                            , l_msg_data
                            , l_return_status
                            );
  END IF;


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    p_result_out := 'FAIL';



    RETURN;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: RISK RESPONSE INCLUDED : '||L_RISKRESP_INCLUDED ) ;
  END IF;

  IF l_riskresp_included = 'YES' THEN
    l_risk_threshold := TO_NUMBER(NVL(fnd_profile.value('ONT_RISK_FAC_THRESHOLD'), '0')) ;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RISK SCORE : '||L_RISK_SCORE ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: OM RISK FACTOR THRESHOLD : '||L_RISK_THRESHOLD ) ;
    END IF;

    -- If Transaction is Risky, then apply credit card Risk hold.
    IF l_risk_score > l_risk_threshold THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPVPMB: TRANSACTION WAS RISKY' ) ;
         END IF;
      -- Set the Out result to Risk to indicate a risky Transaction
	 p_result_out := 'RISK' ;
	 RETURN;

    END IF;
  END IF;*/

  <<Update_Verify_Hold>>
    -- To either release or apply the verify hold.
    p_result_out := l_result_status;

    IF l_result_status = 'PASS'
       AND  l_return_status = FND_API.G_RET_STS_SUCCESS  THEN

	 -- Release Any existing CC Holds
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING LINE LEVEL CREDIT CARD HOLDS' ) ;
      END IF;
	 --

     IF l_payments_tbl(I).line_id IS NULL THEN
        OE_Verify_Payment_PUB.Release_Verify_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_epayment_hold => 'Y' -- We want to Release Credit Card Holds
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );

      ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
	 OE_Verify_Payment_PUB.Release_Verify_Line_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_line_id       => l_payments_tbl(I).line_id
                                 , p_epayment_hold => 'Y' -- We want to Release Credit Card Holds
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF l_result_status = 'RISK' THEN

	 -- Apply Risk Hold on the Order
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: APPLYING LINE LEVEL CC RISK HOLD' ) ;
      END IF;
	 --
      IF l_payments_tbl(I).line_id IS NULL THEN
	 OE_Verify_Payment_PUB.Apply_Verify_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_hold_id       => 12 -- Seed Id for CC Risk Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
	 OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_line_id       => l_payments_tbl(I).line_id
                                 , p_hold_id       => 12 -- Seed Id for CC Risk Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSE -- Failed

	 -- Apply CC Auth Failure Hold on the Order
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: APPLYING LINE LEVEL CC AUTH FAILURE HOLD' ) ;
      END IF;
	 --

      IF l_payments_tbl(I).line_id IS NULL THEN
	 OE_Verify_Payment_PUB.Apply_Verify_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      ELSIF l_payments_tbl(I).line_id IS NOT NULL THEN
	 OE_Verify_Payment_PUB.Apply_Verify_Line_Hold
                                 ( p_header_id     => p_header_rec.header_id
                                 , p_line_id       => l_payments_tbl(I).line_id
                                 , p_hold_id       => 11 -- Seeded Id for CC Auth Failure Hold
                                 , p_msg_count     => l_msg_count
                                 , p_msg_data      => l_msg_data
                                 , p_return_status => l_return_status
                                 );
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; -- IF Result Status.

  <<Next_In_Loop>>
  I := l_payments_tbl.NEXT(I);
END LOOP;

  p_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Authorization error....exc');
		oe_debug_pub.add('After call to Create_Authorization error'||l_return_status);
		oe_debug_pub.add('Result code'||l_response.result_code);
		oe_debug_pub.add('Error'||l_err_message);
	END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        l_err_message := SQLERRM;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Create_Authorization error....unxc');
		oe_debug_pub.add('After call to Create_Authorization error'||l_return_status);
		oe_debug_pub.add('Result code'||l_response.result_code);
		oe_debug_pub.add('f Error'||l_err_message);
	END IF;

      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      l_err_message := SQLERRM;
      oe_debug_pub.add('Returned error others part in Auth multi payments...'||l_err_message);

	 p_result_out := 'FAIL';
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Authorize_Payment'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );


END Authorize_MultiPayments;

PROCEDURE Check_ReAuth_for_MultiPmnts
(  p_credit_card_approval_code 	IN VARCHAR2
,  p_trxn_extension_id		IN NUMBER
,  p_amount_to_authorize	IN NUMBER
,  p_org_id			IN NUMBER
,  p_site_use_id		IN NUMBER
,  p_header_id                  IN NUMBER  --bug 5209584
,  p_line_id                    IN NUMBER
,  p_payment_number             IN NUMBER
,  p_reauthorize_out 		OUT NOCOPY VARCHAR2
,  x_msg_count                  OUT NOCOPY  NUMBER
,  x_msg_data                   OUT NOCOPY  VARCHAR2
,  x_return_status              OUT NOCOPY  VARCHAR2
)
IS

l_reauthorize_flag 	VARCHAR2(1) ; -- 4863717
l_settled_flag	 	VARCHAR2(1) := 'N';

l_return_Status		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_trxn_extension_id     NUMBER;
l_effective_auth_amount	NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN CHECK REAUTHORIZE ORDER' ) ;
  END IF;

   l_reauthorize_flag := 'N' ;

  IF p_amount_to_authorize > 0 THEN

  -- comment out for 4863717
  --  IF p_credit_card_approval_code IS NOT NULL THEN

      -- to check if the authorization has been settled
      BEGIN
      -- bug 8586227
        SELECT 	nvl(settled_flag, 'N')
        INTO	l_settled_flag
  	FROM 	IBY_EXTN_SETTLEMENTS_V
	WHERE   trxn_extension_id = p_trxn_extension_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
	l_settled_flag := 'N';
      END;

      IF l_settled_flag = 'Y' THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: authorization has been settled, need to re-authorize.');
        END IF;

        -- need to create a new payment transaction extension as the old one has been settled.
        Create_New_Payment_Trxn (p_trxn_extension_id => p_trxn_extension_id,
                                 p_org_id	     => p_org_id,
                                 p_site_use_id	     => p_site_use_id,
                                 x_trxn_extension_id => l_trxn_extension_id,
                                 x_msg_count         => x_msg_count,
                                 x_msg_data          => x_msg_data,
                                 x_return_status     => x_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       -- update oe_payments table
       UPDATE oe_payments
       SET    trxn_extension_id = l_trxn_extension_id
       WHERE  trxn_extension_id = p_trxn_extension_id
         AND  header_id         = p_header_id  --bug 5209584
         AND  nvl(line_id,-1)   = nvl(p_line_id,-1)
         AND  payment_number    = p_payment_number;

	p_reauthorize_out := 'Y' ;
	RETURN;

      END IF;

      -- need to re-authorize if the authorization has expired.
      -- effective_auth_amount of 0 indicates auth has expired.
      -- the auth would be valid if authorization_amount is equal to
      -- effective_auth_amount
      BEGIN
   	SELECT effective_auth_amount
        INTO   l_effective_auth_amount
	FROM   iby_trxn_ext_auths_v
	WHERE  trxn_extension_id = p_trxn_extension_id
        AND    INITIATOR_EXTENSION_ID =	p_trxn_extension_id  -- bug 9335940 /9145261
        AND    nvl(authorization_amount,0) > 0
        AND    authorization_status=0;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        -- if never been authorized
        l_reauthorize_flag := 'Y';
        p_reauthorize_out := l_reauthorize_flag ;
        -- if no entry found, need to auth without creating a new trxn id.
        RETURN;
      END;

      IF nvl(l_effective_auth_amount,0) = 0 THEN
        l_reauthorize_flag := 'Y';
        p_reauthorize_out := l_reauthorize_flag ;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPVPMB: authorization has either expired or not exists.');
        END IF;
      END IF;

      IF l_reauthorize_flag = 'Y' THEN
         -- need to create a new payment transaction extension as the old one has expired.
         Create_New_Payment_Trxn (p_trxn_extension_id => p_trxn_extension_id,
                                p_org_id	     => p_org_id,
                                p_site_use_id	     => p_site_use_id,
                                x_trxn_extension_id => l_trxn_extension_id,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                x_return_status     => x_return_status);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- update oe_payments table
         UPDATE oe_payments
         SET    trxn_extension_id = l_trxn_extension_id
         WHERE  trxn_extension_id = p_trxn_extension_id
           AND  header_id         = p_header_id  --bug 5209584
           AND  nvl(line_id,-1)   = nvl(p_line_id,-1)
           AND  payment_number    = p_payment_number;
       END IF;

   -- comment out for bug 4863717
   /*
   ELSE
      l_reauthorize_flag := 'Y' ;

   END IF;
   */

  ELSE

    -- If Outbound Total is less or equal to 0 then NO need to Reauthorize
    l_reauthorize_flag := 'N';

  END IF; -- IF Outbound Total

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXPVPMB: reauthorize flag is: '||l_reauthorize_flag);
  END IF;

  p_reauthorize_out := l_reauthorize_flag ;

  EXCEPTION WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_ReAuth_for_MultiPmnts'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

END Check_ReAuth_for_MultiPmnts;

-- This function needs to be changed later on to consider partially invoicing
FUNCTION Get_Line_Total
( p_line_id		  IN 	NUMBER
, p_header_id		  IN	NUMBER
, p_currency_code	  IN   	VARCHAR2
, p_level	 	  IN	VARCHAR2
, p_amount_type           IN    VARCHAR2 DEFAULT NULL --pnpl
, p_to_exclude_commitment IN    VARCHAR2 DEFAULT 'Y' --bug3225795
) RETURN NUMBER IS

l_tax_value  		NUMBER := 0;
l_extended_price	NUMBER := 0;
l_line_total		NUMBER := 0;
l_line_total_no_comt	NUMBER := 0;
l_charge_amount		NUMBER;
l_commitment_applied    NUMBER := 0;
l_header_id		NUMBER;
l_payment_term_id	NUMBER;
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_downpayment           number := 0;
l_downpayment_due       number := 0;
l_item_invoiceable	VARCHAR2(1) := 'Y';
i			pls_integer;

--pnpl start
l_pay_now_total_detail_tbl   AR_VIEW_TERM_GRP.amounts_table;
l_pay_now_total_summary_rec  AR_VIEW_TERM_GRP.summary_amounts_rec;
l_return_status              VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_return_value          NUMBER;
--pnpl end
Is_fmt           BOOLEAN;   --8241416

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_Verify_Payment_Pub.Get_Line_Total.' , 1 ) ;
  END IF;

--8241416 start
  IF OE_ORDER_UTIL.G_Precision IS NULL THEN
    Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_id);

    IF OE_ORDER_UTIL.G_Precision IS NULL THEN
       OE_ORDER_UTIL.G_Precision:=2;
    END IF;
  END IF;
--8241416 end


  -- Select the Tax Value and Outbound Extended Price
  BEGIN
  SELECT nvl(ool.tax_value,0)
       , nvl(ool.Ordered_Quantity,0) * ool.unit_selling_price
       , header_id
       , payment_term_id
  INTO   l_tax_value
       , l_extended_price
       , l_header_id
       , l_payment_term_id
  FROM  oe_order_lines_all ool
  WHERE ool.line_id = p_line_id
--  AND   ool.open_flag = 'Y' --bug3225795
  AND   ool.line_category_code <> 'RETURN'
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_tax_value := 0;
      l_extended_price := 0;
  END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'In Get_Line_Total, l_extended_price is: '||l_extended_price , 3 ) ;
    END IF;

    -- Select the committment applied amount
    BEGIN
    --pnpl added the Do_Commitment_Sequencing check
    IF OE_Commitment_Pvt.Do_Commitment_Sequencing THEN
       SELECT SUM(nvl(op.commitment_applied_amount,0))
       INTO   l_commitment_applied
       FROM   oe_payments op
       WHERE  op.line_id = p_line_id
       AND    op.header_id = p_header_id
       AND    NOT EXISTS
          (SELECT 'Non Invoiceable Item Line'
           FROM   mtl_system_items mti, oe_order_lines_all ool
           WHERE  ool.line_id           = op.line_id
           AND    mti.inventory_item_id = ool.inventory_item_id
           AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                          oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
           AND   (mti.invoiceable_item_flag = 'N'
                OR  mti.invoice_enabled_flag  = 'N'));
    ELSE
       SELECT nvl(ool.Ordered_Quantity,0) *(ool.unit_selling_price)
       INTO   l_commitment_applied
       FROM   oe_order_lines_all ool
       WHERE  ool.line_id      = p_line_id
       AND    ool.commitment_id is not null
       --AND    ool.open_flag      = 'Y'
       --AND    nvl(ool.invoice_interface_status_code,'NO') <> 'YES' --bug3225795
       AND    ool.line_category_code <> 'RETURN'
       AND   NOT EXISTS
	  (SELECT 'Non Invoiceable Item Line'
	   FROM   mtl_system_items mti
	   WHERE  mti.inventory_item_id = ool.inventory_item_id
	   AND    mti.organization_id   = nvl(ool.ship_from_org_id,
					      oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
	   AND   (mti.invoiceable_item_flag = 'N'
		  OR  mti.invoice_enabled_flag  = 'N'));
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_commitment_applied := 0;
    END;


    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'In Get_Line_Total, commitment_applied_amount is: '||l_commitment_applied , 3 ) ;
    END IF;

    -- get line level charges
    BEGIN
    SELECT SUM(
            ROUND(  --8241416
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,(-1) * (P.OPERAND)),
                               (-1) * (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0))),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                       )
           ,OE_ORDER_UTIL.G_Precision )  --8241416
                 )
     INTO l_charge_amount
     FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
     WHERE P.LINE_ID = p_line_id
     AND   P.LINE_ID = L.LINE_ID
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y'
     --Bug 6072691
     --Uninvoiced and invoiced charges will be returned in the first two conditions
     --Last condition will handle all the other amount types
     AND   ( (nvl(p_amount_type,'OTHERS') = 'UNINV_CHARGES'
              AND nvl(p.invoiced_flag,'N') = 'N')
            OR
             (nvl(p_amount_type,'OTHERS') = 'INV_CHARGES'
              AND nvl(p.invoiced_flag,'N') = 'Y')
            OR
             (nvl(p_amount_type,'OTHERS') NOT IN('UNINV_CHARGES','INV_CHARGES'))
           );

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_charge_amount := 0;
     END;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'In Get_Line_Total, l_charge_amount is: '||l_charge_amount , 3 ) ;
     END IF;

     l_line_total := nvl(l_extended_price,0) + nvl(l_tax_value,0)
                     + nvl(l_charge_amount,0) - nvl(l_commitment_applied,0);

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'In Get_Line_Total, l_line_total is: '||l_line_total , 3 ) ;
     END IF;

    l_line_total_no_comt := nvl(l_extended_price,0) + nvl(l_tax_value,0)
                              + nvl(l_charge_amount,0);

  --pnpl adding the checks w.r.t p_amount_type
  IF p_amount_type IS NULL THEN
      --IF oe_sys_parameters.value('ACCOUNT_FIRST_INSTALLMENT_ONLY') = 'Y'
       --pnpl
       IF Oe_Prepayment_Util.Get_Installment_Options = 'AUTHORIZE_FIRST_INSTALLMENT' THEN

	   l_pay_now_total_detail_tbl(1).line_id := p_line_id;
	   l_pay_now_total_detail_tbl(1).term_id := l_payment_term_id;
	   l_pay_now_total_detail_tbl(1).line_amount := nvl(l_extended_price,0);
           l_pay_now_total_detail_tbl(1).tax_amount := nvl(l_tax_value,0);
	   l_pay_now_total_detail_tbl(1).freight_amount := nvl(l_charge_amount,0);


           OE_PREPAYMENT_PVT.Get_First_Installment
	                      (p_currency_code               => OE_Order_Cache.g_header_rec.transactional_curr_code
			      ,p_x_due_now_total_detail_tbl 	=> l_pay_now_total_detail_tbl
			      ,x_due_now_total_summary_rec	=> l_pay_now_total_summary_rec
			      ,x_return_status    		=> l_return_status
			      ,x_msg_count			=> l_msg_count
			      ,x_msg_data			=> l_msg_data
			      );


	     IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  'In Get_Line_Total, First Installment is: '|| l_pay_now_total_summary_rec.total_amount , 3 ) ;
	     END IF;

             l_return_value :=  l_pay_now_total_summary_rec.total_amount;

       ELSIF OE_Prepayment_Util.Get_Installment_Options = 'ENABLE_PAY_NOW' THEN
	   l_pay_now_total_detail_tbl(1).line_id := p_line_id;
	   l_pay_now_total_detail_tbl(1).term_id := l_payment_term_id;
	   l_pay_now_total_detail_tbl(1).line_amount := nvl(l_extended_price,0);
           l_pay_now_total_detail_tbl(1).tax_amount := nvl(l_tax_value,0);
	   l_pay_now_total_detail_tbl(1).freight_amount := nvl(l_charge_amount,0);

	   -- calling AR API to get pay now total
	   AR_VIEW_TERM_GRP.pay_now_amounts
	                    (p_api_version         => 1.0
			    ,p_init_msg_list       => FND_API.G_TRUE
			    ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
			    ,p_currency_code       => OE_Order_Cache.g_header_rec.transactional_curr_code
			    ,p_amounts_tbl         => l_pay_now_total_detail_tbl
                            ,x_pay_now_summary_rec => l_pay_now_total_summary_rec
			    ,x_return_status       => l_return_status
			    ,x_msg_count           => l_msg_count
			    ,x_msg_data            => l_msg_data
			    );

	   IF l_debug_level > 0 THEN
	      oe_debug_pub.add('l_pay_now_total_summary_rec.total_amount is '|| l_pay_now_total_summary_rec.total_amount);
	   END IF;

	   -- return pay_now_total minus line level commitment applied amount.
	   l_return_value :=  l_pay_now_total_summary_rec.total_amount;
	ELSE --OE_Prepayment_Util.Get_Installment_Options = 'NONE'
           l_return_value := l_line_total_no_comt;
	END IF;

        IF p_level = 'LINE' THEN
	   RETURN l_return_value - nvl(l_commitment_applied,0);
	ELSE --p_level = 'HEADER'
	   IF p_to_exclude_commitment = 'Y' THEN
	       RETURN l_return_value - nvl(l_commitment_applied,0);
	   ELSE
	       RETURN l_return_value;
	   END IF;
	END IF;

  ELSE
     IF p_amount_type = 'SUBTOTAL' THEN
	Return nvl(l_extended_price,0);
     ELSIF p_amount_type = 'TAX' THEN
	Return nvl(l_tax_value,0);
     --Bug 6072691
     ELSIF p_amount_type IN('CHARGES','UNINV_CHARGES','INV_CHARGES') THEN
	Return nvl(l_charge_amount,0);
     ELSIF p_amount_type = 'TOTAL' THEN
	Return l_line_total_no_comt;
     ELSIF p_amount_type = 'COMMITMENT' THEN
	Return nvl(l_commitment_applied,0);
     END IF;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'Exiting OE_Verify_Payment_PUB.Get_Line_Total.' , 3 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Unexpected Error from OE_Verify_Payment_PUB.Get_Line_Total ' || SQLERRM ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Line_Total;

--bug3225795 start
--This function is currently similar to Get_Line_Total. Needs to be changed later to consider partial invoicing.
FUNCTION Get_Inv_Line_Total
( p_line_id		  IN 	NUMBER
, p_header_id		  IN	NUMBER
, p_currency_code	  IN   	VARCHAR2
, p_level	 	  IN	VARCHAR2
, p_to_exclude_commitment IN    VARCHAR2 DEFAULT 'Y' --bug3225795
) RETURN NUMBER IS

l_tax_value  		NUMBER := 0;
l_extended_price	NUMBER := 0;
l_line_total		NUMBER := 0;
l_line_total_no_comt	NUMBER := 0;
l_charge_amount		NUMBER;
l_commitment_applied    NUMBER := 0;
l_header_id		NUMBER;
l_payment_term_id	NUMBER;
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_downpayment           number := 0;
l_downpayment_due       number := 0;
l_item_invoiceable	VARCHAR2(1) := 'Y';
i			pls_integer;

--pnpl start
l_pay_now_total_detail_tbl   AR_VIEW_TERM_GRP.amounts_table;
l_pay_now_total_summary_rec  AR_VIEW_TERM_GRP.summary_amounts_rec;
l_return_status              VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_return_value          NUMBER;
--pnpl end


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_Verify_Payment_Pub.Get_Inv_Line_Total.' , 1 ) ;
  END IF;

  -- Select the Tax Value and Outbound Extended Price
  BEGIN
  SELECT nvl(ool.tax_value,0)
       , nvl(ool.Ordered_Quantity,0) * ool.unit_selling_price
       , header_id
       , payment_term_id
  INTO   l_tax_value
       , l_extended_price
       , l_header_id
       , l_payment_term_id
  FROM  oe_order_lines_all ool
  WHERE ool.line_id = p_line_id
--  AND   ool.open_flag = 'Y'
  AND   ool.line_category_code <> 'RETURN'
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_tax_value := 0;
      l_extended_price := 0;
  END;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'In Get_Inv_Line_Total, l_extended_price is: '||l_extended_price , 3 ) ;
  END IF;

  BEGIN
     --pnpl added the Do_Commitment_Sequencing check
    IF OE_Commitment_Pvt.Do_Commitment_Sequencing THEN
    -- Select the committment applied amount
       SELECT SUM(nvl(op.commitment_applied_amount,0))
       INTO   l_commitment_applied
       FROM   oe_payments op
       WHERE  op.line_id = p_line_id
       AND    op.header_id = p_header_id
       AND    NOT EXISTS
	  (SELECT 'Non Invoiceable Item Line'
	   FROM   mtl_system_items mti, oe_order_lines_all ool
	   WHERE  ool.line_id           = op.line_id
	   AND    mti.inventory_item_id = ool.inventory_item_id
	   AND    mti.organization_id   = nvl(ool.ship_from_org_id,
					      oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
	   AND   (mti.invoiceable_item_flag = 'N'
		OR  mti.invoice_enabled_flag  = 'N'));
     ELSE
	 SELECT nvl(ool.Ordered_Quantity,0) *(ool.unit_selling_price)
	 INTO   l_commitment_applied
	 FROM   oe_order_lines_all ool
	 WHERE  ool.line_id      = p_line_id
	 AND    ool.commitment_id is not null
	 AND    ool.line_category_code <> 'RETURN'
	 AND   NOT EXISTS
	    (SELECT 'Non Invoiceable Item Line'
	     FROM   mtl_system_items mti
	     WHERE  mti.inventory_item_id = ool.inventory_item_id
	     AND    mti.organization_id   = nvl(ool.ship_from_org_id,
						oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
	     AND   (mti.invoiceable_item_flag = 'N'
		    OR  mti.invoice_enabled_flag  = 'N'));
      END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_commitment_applied := 0;
    END;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'In Get_Inv_Line_Total, commitment_applied_amount is: '||l_commitment_applied , 3 ) ;
    END IF;

    -- get line level charges
    BEGIN
         SELECT SUM(
                DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,(-1) * (P.OPERAND)),
                               (-1) * (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0))),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               DECODE(L.ORDERED_QUANTITY,0,0,P.OPERAND),
                               (L.ORDERED_QUANTITY* nvl(P.ADJUSTED_AMOUNT,0)))
                       )
                 )
	  INTO l_charge_amount
	  FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
	  WHERE P.LINE_ID = p_line_id
	  AND   P.LINE_ID = L.LINE_ID
	  AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
	  AND   P.APPLIED_FLAG = 'Y';

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_charge_amount := 0;
     END;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'In Get_Inv_Line_Total, l_charge_amount is: '||l_charge_amount , 3 ) ;
     END IF;

     l_line_total := nvl(l_extended_price,0) + nvl(l_tax_value,0)
                     + nvl(l_charge_amount,0) - nvl(l_commitment_applied,0);

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'In Get_Inv_Line_Total, l_line_total is: '||l_line_total , 3 ) ;
     END IF;

    l_line_total_no_comt := nvl(l_extended_price,0) + nvl(l_tax_value,0)
                              + nvl(l_charge_amount,0);

   IF Oe_Prepayment_Util.Get_Installment_Options = 'AUTHORIZE_FIRST_INSTALLMENT' THEN
        l_pay_now_total_detail_tbl(1).line_id := p_line_id;
	   l_pay_now_total_detail_tbl(1).term_id := l_payment_term_id;
	   l_pay_now_total_detail_tbl(1).line_amount := nvl(l_extended_price,0);
           l_pay_now_total_detail_tbl(1).tax_amount := nvl(l_tax_value,0);
	   l_pay_now_total_detail_tbl(1).freight_amount := nvl(l_charge_amount,0);


           OE_PREPAYMENT_PVT.Get_First_Installment
	                      (p_currency_code               => OE_Order_Cache.g_header_rec.transactional_curr_code
			      ,p_x_due_now_total_detail_tbl 	=> l_pay_now_total_detail_tbl
			      ,x_due_now_total_summary_rec	=> l_pay_now_total_summary_rec
			      ,x_return_status    		=> l_return_status
			      ,x_msg_count			=> l_msg_count
			      ,x_msg_data			=> l_msg_data
			      );


	     IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  'In Get_Inv_Line_Total, First Installment is: '|| l_pay_now_total_summary_rec.total_amount , 3 ) ;
	     END IF;

             l_return_value :=  l_pay_now_total_summary_rec.total_amount;

    ELSIF OE_Prepayment_Util.Get_Installment_Options = 'ENABLE_PAY_NOW' THEN
        l_pay_now_total_detail_tbl(1).line_id := p_line_id;
	l_pay_now_total_detail_tbl(1).term_id := l_payment_term_id;
	l_pay_now_total_detail_tbl(1).line_amount := nvl(l_extended_price,0);
	l_pay_now_total_detail_tbl(1).tax_amount := nvl(l_tax_value,0);
	l_pay_now_total_detail_tbl(1).freight_amount := nvl(l_charge_amount,0);

        -- calling AR API to get pay now total
	AR_VIEW_TERM_GRP.pay_now_amounts
	    (p_api_version         => 1.0
	    ,p_init_msg_list       => FND_API.G_TRUE
	    ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
	    ,p_currency_code       => OE_Order_Cache.g_header_rec.transactional_curr_code
	    ,p_amounts_tbl         => l_pay_now_total_detail_tbl
	    ,x_pay_now_summary_rec => l_pay_now_total_summary_rec
	    ,x_return_status       => l_return_status
	    ,x_msg_count           => l_msg_count
	    ,x_msg_data            => l_msg_data
	    );

	   IF l_debug_level > 0 THEN
	      oe_debug_pub.add('l_pay_now_total_summary_rec.total_amount is '|| l_pay_now_total_summary_rec.total_amount);
	   END IF;

	   -- return pay_now_total minus line level commitment applied amount.
	   l_return_value :=  l_pay_now_total_summary_rec.total_amount;
      ELSE --OE_Prepayment_Util.Get_Installment_Options = 'NONE'
           l_return_value := l_line_total_no_comt;
      END IF;


    IF p_level = 'LINE' THEN
       RETURN l_return_value - nvl(l_commitment_applied,0);
    ELSE --p_level = 'HEADER'
       IF p_to_exclude_commitment = 'Y' THEN
	  RETURN l_return_value - nvl(l_commitment_applied,0);
       ELSE
	  RETURN l_return_value;
       END IF;
    END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting OE_Verify_Payment_PUB.Get_Inv_Line_Total.' , 3 ) ;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'FROM OE_Verify_Payment_PUB.Get_Inv_Line_Total' ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Inv_Line_Total;

--This function also needs to be modified later to consider partial invoicing
FUNCTION Outbound_Order_Total
( p_header_id     IN NUMBER
, p_to_exclude_commitment        IN VARCHAR2 DEFAULT 'Y'
, p_total_type                   IN VARCHAR2 DEFAULT NULL --pnpl
) RETURN NUMBER
IS
l_order_total     NUMBER;
l_tax_total       NUMBER;
l_charges         NUMBER;
l_outbound_total  NUMBER;
l_commitment_total NUMBER;
l_chgs_w_line_id   NUMBER := 0;
l_chgs_wo_line_id  NUMBER := 0;

--pnpl start
l_pay_now_subtotal NUMBER;
l_pay_now_tax      NUMBER;
l_pay_now_charges  NUMBER;
l_pay_now_total    NUMBER;
l_pay_now_commitment NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1);
--pnpl end

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Is_fmt           BOOLEAN;   --7010350
BEGIN
  -- bug#5946168 added round function
  -- Select the Tax Total and Outbound Extended Price
--7010350
   IF OE_ORDER_UTIL.G_Precision IS NULL THEN
     Is_fmt:= OE_ORDER_UTIL.Get_Precision(p_header_id=>p_header_id);

     IF OE_ORDER_UTIL.G_Precision IS NULL THEN
        OE_ORDER_UTIL.G_Precision:=2;
     END IF;
   END IF;
 --7010350

  SELECT
    SUM(ROUND(nvl(ool.tax_value,0),OE_ORDER_UTIL.G_Precision))
  , SUM(ROUND(nvl(ool.Ordered_Quantity,0)
	   *(ool.unit_selling_price),OE_ORDER_UTIL.G_Precision))
  INTO
    l_tax_total
  , l_order_total
  FROM  oe_order_lines_all ool
  WHERE ool.header_id      = p_header_id
  AND   ool.open_flag      = 'Y'
  AND   nvl(ool.invoice_interface_status_code,'NO') <> 'YES' --bug3225795
  AND   ool.line_category_code <> 'RETURN'
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));

  IF OE_Commitment_Pvt.Do_Commitment_Sequencing THEN
    -- Select the committment applied amount if Commitment Sequencing "On"
    SELECT SUM(ROUND(nvl(op.commitment_applied_amount,0),OE_ORDER_UTIL.G_Precision))
    INTO   l_commitment_total
    FROM   oe_payments op,
	   oe_order_lines_all ool --bug3225795
    WHERE  op.header_id = p_header_id
    AND    ool.header_id  = p_header_id --bug3225795
    AND    nvl(ool.invoice_interface_status_code,'NO') <> 'YES' --bug3225795
    AND    ool.line_id=op.line_id --bug3225795
    AND    NOT EXISTS
          (SELECT 'Non Invoiceable Item Line'
           FROM   mtl_system_items mti, oe_order_lines_all ool
           WHERE  ool.line_id           = op.line_id
           AND    mti.inventory_item_id = ool.inventory_item_id
           AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                          oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
           AND   (mti.invoiceable_item_flag = 'N'
              OR  mti.invoice_enabled_flag  = 'N'));
  ELSE
  -- Select the Outbound Extended Price for lines that have committment
  SELECT SUM(ROUND(nvl(ool.Ordered_Quantity,0) * (ool.unit_selling_price),OE_ORDER_UTIL.G_Precision))
  INTO   l_commitment_total
  FROM   oe_order_lines_all ool
  WHERE  ool.header_id      = p_header_id
  AND    ool.commitment_id is not null
  AND    ool.open_flag      = 'Y'
  AND    nvl(ool.invoice_interface_status_code,'NO') <> 'YES' --bug3225795
  AND    ool.line_category_code <> 'RETURN'
  AND   NOT EXISTS
       (SELECT 'Non Invoiceable Item Line'
        FROM   mtl_system_items mti
        WHERE  mti.inventory_item_id = ool.inventory_item_id
        AND    mti.organization_id   = nvl(ool.ship_from_org_id,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', ool.org_id))
        AND   (mti.invoiceable_item_flag = 'N'
           OR  mti.invoice_enabled_flag  = 'N'));
  END IF;

  -- Select the Outbound Charges Total

     SELECT SUM(
                ROUND(DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',(-1) * P.OPERAND,P.OPERAND),OE_ORDER_UTIL.G_Precision)
               )
     INTO l_chgs_wo_line_id
     FROM OE_PRICE_ADJUSTMENTS P
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID IS NULL
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y'
     AND   NVL(P.INVOICED_FLAG, 'N') = 'N';

     SELECT SUM(
                ROUND(DECODE(P.CREDIT_OR_CHARGE_FLAG,'C',
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               (-1) * (P.OPERAND),
                               (-1) * (L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT)),
                        DECODE(P.ARITHMETIC_OPERATOR, 'LUMPSUM',
                               P.OPERAND,
                               (L.ORDERED_QUANTITY*P.ADJUSTED_AMOUNT))
                      ),OE_ORDER_UTIL.G_Precision)
              )
     INTO l_chgs_w_line_id
     FROM OE_PRICE_ADJUSTMENTS P,
          OE_ORDER_LINES_ALL L
     WHERE P.HEADER_ID = p_header_id
     AND   P.LINE_ID = L.LINE_ID
     AND   P.LIST_LINE_TYPE_CODE = 'FREIGHT_CHARGE'
     AND   P.APPLIED_FLAG = 'Y'
     AND   L.header_id      = p_header_id
     AND   L.open_flag      = 'Y'
     AND   nvl(L.invoice_interface_status_code,'NO') <> 'YES' --bug3225795
     AND   L.line_category_code <> 'RETURN'
     AND   NOT EXISTS
          (SELECT 'Non Invoiceable Item Line'
           FROM   MTL_SYSTEM_ITEMS MTI
           WHERE  MTI.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID
           AND    MTI.ORGANIZATION_ID   = NVL(L.SHIP_FROM_ORG_ID,
                         oe_sys_parameters.value('MASTER_ORGANIZATION_ID', L.org_id))
           AND   (MTI.INVOICEABLE_ITEM_FLAG = 'N'
              OR  MTI.INVOICE_ENABLED_FLAG  = 'N'));

    l_charges := nvl(l_chgs_wo_line_id,0) + nvl(l_chgs_w_line_id,0);

 --pnpl added the conditions w.r.t p_total_type
 IF p_total_type IS NULL THEN
  IF OE_Prepayment_Util.Get_Installment_Options IN ('ENABLE_PAY_NOW','AUTHORIZE_FIRST_INSTALLMENT') THEN
     OE_Prepayment_PVT.Get_Pay_Now_Amounts
	 (p_header_id 		=> p_header_id
	 ,p_line_id		=> null
	 ,p_exc_inv_lines       => 'Y'
	 ,x_pay_now_subtotal 	=> l_pay_now_subtotal
	 ,x_pay_now_tax   	=> l_pay_now_tax
	 ,x_pay_now_charges  	=> l_pay_now_charges
	 ,x_pay_now_total	=> l_pay_now_total
	 ,x_pay_now_commitment  => l_pay_now_commitment
	 ,x_msg_count		=> l_msg_count
	 ,x_msg_data		=> l_msg_data
	 ,x_return_status       => l_return_status
	 );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('Error in  OE_Prepayment_PVT.Get_Pay_Now_Amounts... returning zero');
	END IF;
	RETURN 0;
     END IF;

     IF p_to_exclude_commitment = 'Y' THEN
	l_outbound_total := l_pay_now_total - nvl(l_pay_now_commitment,0);
     ELSE
	l_outbound_total := l_pay_now_total;
     END IF;

  ELSE -- OE_Prepayment_Util.Get_Installment_Options = 'NONE'

     IF p_to_exclude_commitment = 'Y' THEN
	l_outbound_total := nvl(l_order_total, 0) + nvl(l_tax_total, 0)
	   + nvl(l_charges, 0) - nvl(l_commitment_total,0);
     ELSE
	l_outbound_total := nvl(l_order_total, 0) + nvl(l_tax_total, 0)
	   + nvl(l_charges, 0);
     END IF;
  END IF; -- check for OE_Prepayment_Util.Get_Installment_Options

 ELSIF p_total_type = 'COMMITMENT' THEN
    l_outbound_total := NVL(l_commitment_total,0);
 ELSIF p_total_type = 'HEADER_CHARGES' THEN
    l_outbound_total := NVL(l_chgs_wo_line_id,0);
 END IF;

 IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALCULATING THE TOTAL AMOUNT TO BE AUTHORIZED FOR THIS ORDER ' , 1 ) ;
      oe_debug_pub.add(  'ORDER TOTAL -> '||TO_CHAR ( L_ORDER_TOTAL ) , 1 ) ;
      oe_debug_pub.add(  'TAX TOTAL -> '||TO_CHAR ( L_TAX_TOTAL ) , 1 ) ;
      oe_debug_pub.add(  'COMMITMENTS -> '||TO_CHAR ( L_COMMITMENT_TOTAL ) , 1 ) ;
      oe_debug_pub.add(  'OTHER CHARGES -> '||TO_CHAR ( L_CHARGES ) , 1 ) ;
      oe_debug_pub.add(  'P_TOTAL_TYPE -> '||P_TOTAL_TYPE);
      oe_debug_pub.add(  'L_OUTBOUND_TOTAL => '||TO_CHAR ( L_OUTBOUND_TOTAL ) , 1 ) ;
 END IF;
 RETURN (l_outbound_total);

  EXCEPTION
    WHEN OTHERS THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'FROM OUTBOUND TOTAL OTHERS: ' || SQLERRM ) ;
	 END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Outbound_Order_Total;

--bug3225795 end


/*----------------------------------------------------------------------
Updates Order Line with Authorized Amount, Authorization Code and DATE
----------------------------------------------------------------------*/
PROCEDURE Update_AuthInfo_for_MultiPmnts
( p_header_id           IN   NUMBER
, p_auth_amount         IN   NUMBER
, p_auth_code           IN   VARCHAR2
, p_auth_date           IN   DATE
, p_tangible_id         IN   VARCHAR2
, p_line_id             IN   NUMBER
, p_payment_number	IN   NUMBER
, p_msg_count           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_msg_data	        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, p_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_index                  NUMBER := 1;
l_notify_index           NUMBER := 1;
l_line_id                NUMBER;
l_Line_Payment_rec       OE_ORDER_PUB.Line_Payment_Rec_Type;
l_old_Line_Payment_rec   OE_ORDER_PUB.Line_Payment_Rec_Type;
l_Header_Payment_rec       OE_ORDER_PUB.Header_Payment_Rec_Type;
l_old_Header_Payment_rec   OE_ORDER_PUB.Header_Payment_Rec_Type;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_control_rec            OE_GLOBALS.Control_Rec_Type;
l_return_status          VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  SAVEPOINT Update_AuthInfo_for_MultiPmnts;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN UPDATE AUTHORIZATION INFORMATION' ) ;
  END IF;

/*
  -- Set up the Header record
  OE_Header_Payment_Util.Lock_Row
		(p_header_id			=> p_header_id
		,p_payment_number		=> null
		,p_x_Header_Payment_rec		=> l_old_Header_Payment_rec
		,x_return_status		=> l_return_status
		);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Line_Payment_rec := l_old_Line_Payment_rec;

  l_Line_Payment_rec.header_id                 := p_header_id;
  l_Line_Payment_rec.line_id                   := p_line_id;
  l_Line_Payment_rec.credit_card_approval_code := p_auth_code;
  l_Line_Payment_rec.credit_card_approval_date := p_auth_date;
  l_Line_Payment_rec.last_updated_by	 := FND_GLOBAL.USER_ID;
  l_Line_Payment_rec.last_update_date	 := SYSDATE;
  l_Line_Payment_rec.last_update_login	 := FND_GLOBAL.LOGIN_ID;
  l_Line_Payment_rec.lock_control        := l_header_rec.lock_control + 1;
  l_Line_Payment_rec.operation           := OE_GLOBALS.G_OPR_UPDATE;

  -- Header needs to be requeried, setting the flag to true
  -- OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: UPDATING FIELDS ON HEADER' ) ;
  END IF;
*/

  IF p_line_id IS NOT NULL THEN
    -- line level payments
    update oe_payments
    set credit_card_approval_code = p_auth_code
      , credit_card_approval_date = p_auth_date
      , tangible_id = p_tangible_id
      , last_updated_by = FND_GLOBAL.USER_ID
      , last_update_date = SYSDATE
      , last_update_login = FND_GLOBAL.LOGIN_ID
      , lock_control = lock_control + 1
    where nvl(payment_number, -1) = nvl(p_payment_number, -1)
    and   line_id = p_line_id
    and   header_id = p_header_id;
  ELSE
    -- header level payments
    update oe_payments
    set credit_card_approval_code = p_auth_code
      , credit_card_approval_date = p_auth_date
      , tangible_id = p_tangible_id
      , last_updated_by = FND_GLOBAL.USER_ID
      , last_update_date = SYSDATE
      , last_update_login = FND_GLOBAL.LOGIN_ID
      , lock_control = lock_control + 1
    where line_id IS NULL
    and payment_type_code = 'CREDIT_CARD'
    and payment_collection_event = 'INVOICE'
    and nvl(payment_number, -1) = nvl(p_payment_number, -1)
    and header_id = p_header_id;

    update oe_order_headers_all
    set credit_card_approval_code = p_auth_code
      , credit_card_approval_date = p_auth_date
    where header_id = p_header_id;
  END IF;


  -- aksingh performance
  -- As the update is on headers table, it is time to update
  -- cache also!
  -- ??? OE_Order_Cache.Set_Order_Header(l_header_rec);

  -- Bug 1755817: clear the cached constraint results for header entity
  -- when order header is updated.
  -- ?? OE_PC_Constraints_Admin_Pvt.Clear_Cached_Results
  -- ??     (p_validation_entity_id => OE_PC_GLOBALS.G_ENTITY_HEADER);


/*  commented out for multiple payments

IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN

    -- call notification framework to get header index position
    OE_ORDER_UTIL.Update_Global_Picture
	(p_Upd_New_Rec_If_Exists =>FALSE
	, p_header_rec		=> l_header_rec
	, p_old_header_rec	=> l_old_header_rec
        , p_header_id 		=> l_header_rec.header_id
        , x_index 		=> l_notify_index
        , x_return_status 	=> l_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FOR HDR IS: ' || L_RETURN_STATUS ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HDR INDEX IS: ' || L_NOTIFY_INDEX , 1 ) ;
    END IF;

   IF l_notify_index is not null then
     -- modify Global Picture

    OE_ORDER_UTIL.g_header_rec.payment_amount:=
					l_header_rec.payment_amount;
    OE_ORDER_UTIL.g_header_rec.credit_card_approval_code:=
					l_header_rec.credit_card_approval_code;
    OE_ORDER_UTIL.g_header_rec.credit_card_approval_date:=
					l_header_rec.credit_card_approval_date;
    OE_ORDER_UTIL.g_header_rec.last_updated_by:=l_header_rec.last_updated_by;
    OE_ORDER_UTIL.g_header_rec.last_update_login:=l_header_rec.last_update_login;
    OE_ORDER_UTIL.g_header_rec.last_update_date:=l_header_rec.last_update_date;
    OE_ORDER_UTIL.g_header_rec.lock_control:=	l_header_rec.lock_control;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'GLOBAL HDR PAYMENT_AMOUNT IS: ' || OE_ORDER_UTIL.G_HEADER_REC.PAYMENT_AMOUNT , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'GLOBAL HDR CC APPROVAL_CODE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.CREDIT_CARD_APPROVAL_CODE , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'GLOBAL HDR CC APPROVAL_DATE IS: ' || OE_ORDER_UTIL.G_HEADER_REC.CREDIT_CARD_APPROVAL_DATE , 1 ) ;
		END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Process requests is TRUE so still need to call it, but don't need to notify
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
  OE_Order_PVT.Process_Requests_And_Notify
	( p_process_requests		=> TRUE
	, p_notify			=> FALSE
	, p_header_rec			=> l_header_rec
	, p_old_header_rec		=> l_old_header_rec
	, x_return_status		=> l_return_status
	);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

 END IF ; -- global entity index null check

ELSE -- pre- pack H

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: BEFORE CALLING PROCESS_REQUESTS_AND_NOTIFY' ) ;
  END IF;
  OE_Order_PVT.Process_Requests_And_Notify
	( p_process_requests		=> TRUE
	, p_notify			=> TRUE
	, p_header_rec			=> l_header_rec
	, p_old_header_rec		=> l_old_header_rec
	, x_return_status		=> l_return_status
	);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- notification framework end
END IF; -- code set is pack H or higher
-- end of code commented out for Multiple Payments Project */

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	 ROLLBACK TO Update_AuthInfo_for_MultiPmnts;
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO Update_AuthInfo_for_MultiPmnts;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
	 ROLLBACK TO Update_AuthInfo_for_MultiPmnts;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_AuthInfo_for_MultiPmnts'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Update_AuthInfo_for_MultiPmnts ;

-- release line level authorization hold
PROCEDURE Release_Verify_Line_Hold
(  p_header_id       IN   NUMBER
,  p_line_id         IN   NUMBER
,  p_epayment_hold   IN   VARCHAR2
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

l_hold_id		NUMBER;
l_hold_source_rec   	OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  	OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_result   	VARCHAR2(30);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(30);
l_debug_level CONSTANT 	NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN RELEASE VERIFY LINE HOLD' ) ;
  END IF;

  -- Check What type of Holds to Release
  IF p_epayment_hold = 'Y' THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: RELEASE EPAYMENT HOLDS FOR LINE ID : ' || p_line_id ) ;
    END IF;

--    l_hold_release_rec  := OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;

    l_hold_id := 11 ;  -- Credit Card Authorization Failure Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;
    --

    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_line_id        => p_line_id
                      , p_hold_id        => l_hold_id
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

    -- Check the Result
    IF l_hold_result = FND_API.G_TRUE THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CC FAILURE HOLD ON ORDER HEADER ID:' || p_header_id ) ;
      END IF;
      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;
      l_hold_source_rec.LINE_ID	         := p_line_id;

      l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';


      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING CREDIT CARD RISK HOLD FOR LINE ID : ' || p_line_id ) ;
    END IF;

--    l_hold_release_rec  := OE_Hold_Sources_Pvt.G_MISS_Hold_Release_REC;
    l_hold_id := 12 ; -- Credit Card Risk Hold

    -- Call Check for Hold to see if the Hold Exists
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
    END IF;
    --
    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_line_id        => p_line_id
                      , p_hold_id        => l_hold_id
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

    -- Check the Result
    IF l_hold_result = FND_API.G_TRUE THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CC RISK HOLD ON ORDER LINE ID:' || p_line_id ) ;
      END IF;
      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;
      l_hold_source_rec.LINE_ID          := p_line_id;

      l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;  -- Do nothing if the hold has already been released.

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING CREDIT CARD RISK HOLD FOR LINE ID : ' || p_line_id ) ;
      END IF;

      l_hold_id := 16 ; -- Credit Card Risk Hold

      -- Call Check for Hold to see if the Hold Exists
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: CHECKING EXISTENCE OF HOLD ID : '||L_HOLD_ID ) ;
      END IF;
      --
      OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_line_id        => p_line_id
                      , p_hold_id        => l_hold_id
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

      -- Check the Result
      IF l_hold_result = FND_API.G_TRUE THEN

        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPVPMB: RELEASING CC RISK HOLD ON ORDER LINE ID:' || p_line_id ) ;
        END IF;
        l_hold_source_rec.hold_id          := l_hold_id;
        l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
        l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;
        l_hold_source_rec.LINE_ID          := p_line_id;

        l_hold_release_rec.release_reason_code := 'AUTH_EPAYMENT';

        OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;  -- Do nothing if the hold has already been released.
    END IF;

  END IF; -- Electronic Payment

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Release_Verify_Line_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );



END Release_Verify_Line_Hold;

-- apply line level authorization hold
PROCEDURE Apply_Verify_Line_Hold
(  p_header_id       IN   NUMBER
,  p_line_id         IN   NUMBER
,  p_hold_id         IN   NUMBER
,  p_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER
,  p_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  p_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

l_hold_id		NUMBER;
l_hold_source_rec   	OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  	OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_result   	VARCHAR2(30);
l_line_ind		VARCHAR2(240);
l_line_number		NUMBER;
l_shipment_number 	NUMBER;
l_option_number   	NUMBER;
l_component_number	NUMBER;
l_service_number	NUMBER;

l_msg_count         	NUMBER := 0;
l_msg_data          	VARCHAR2(2000);
l_return_status     	VARCHAR2(30);
l_debug_level CONSTANT 	NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: IN APPLY VERIFY LINE HOLDS' ) ;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: LINE ID : '||P_LINE_ID ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: HOLD ID : '||P_HOLD_ID ) ;
  END IF;

  -- Check if Hold already exists on this order
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: CHECKING IF REQUESTED VERIFY HOLD ALREADY APPLIED' ) ;
  END IF;
  --
    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_line_id        => p_line_id
                      , p_hold_id        => l_hold_id
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

  -- Return with Success if this Hold Already exists on the order
  IF l_hold_result = FND_API.G_TRUE THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPVPMB: HOLD ALREADY APPLIED ON LINE ID : ' || P_LINE_ID ) ;
    END IF;
    RETURN ;
  END IF ;

  -- Apply Verify Hold on Order Line
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLYING VERIFY HOLD ON LINE ID : ' || P_LINE_ID ) ;
  END IF;

  l_hold_source_rec.hold_id         := p_hold_id ;
  l_hold_source_rec.hold_entity_code:= 'O';
  l_hold_source_rec.hold_entity_id  := p_header_id;
  l_hold_source_rec.line_id         := p_line_id;

  OE_Holds_PUB.Apply_Holds
                (   p_api_version       =>      1.0
                ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                ,   p_hold_source_rec   =>      l_hold_source_rec
                ,   x_msg_count         =>      l_msg_count
                ,   x_msg_data          =>      l_msg_data
                ,   x_return_status     =>      l_return_status
                );

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_hold_id = 16 THEN

      BEGIN
       SELECT line_number,
              shipment_number,
              option_number,
              component_number,
              service_number
       INTO   l_line_number,
              l_shipment_number,
              l_option_number,
              l_component_number,
              l_service_number
       from  oe_order_lines_all
       where line_id = p_line_id;


      end;
      l_line_ind := RTRIM(l_line_number      || '.' ||
                             l_shipment_number  || '.' ||
                             l_option_number    || '.' ||
                             l_component_number || '.' ||
                             l_service_number, '.');


      FND_MESSAGE.SET_NAME('ONT','ONT_PENDING_AUTH_HOLD_APPLIED');
      FND_MESSAGE.SET_TOKEN('LEVEL','LINE '||l_line_ind);
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXVPPYB: Pending Payment Authorization hold  has been applied on order line.', 3);
      END IF;
    END IF;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPVPMB: APPLIED VERIFY HOLD ON LINE ID:' || P_LINE_ID ) ;
  END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_Verify_Line_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );


END Apply_Verify_Line_Hold;


-- For bug 3571485. Can use this function for Formatting number to two decimal places.
FUNCTION Get_Format_Mask(p_currency_code IN VARCHAR2)
RETURN  VARCHAR2
IS

l_precision         	NUMBER;
l_ext_precision     	NUMBER;
l_min_acct_unit     	NUMBER;
l_format_mask	        VARCHAR2(500);

 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
  FND_CURRENCY.Get_Info(p_currency_code,  -- IN variable
                        l_precision,
		       	l_ext_precision,
		 	l_min_acct_unit);

  FND_CURRENCY.Build_Format_Mask(l_format_mask, 20, l_precision,
                                 l_min_acct_unit, TRUE
                                 );

  RETURN l_format_mask;
END Get_Format_Mask;

PROCEDURE Create_New_Payment_Trxn
(  p_trxn_extension_id 		IN 	NUMBER
,  p_org_id			IN	NUMBER
,  p_site_use_id		IN	NUMBER
,  p_line_id                    IN   	NUMBER DEFAULT NULL
,  p_instrument_security_code   IN      VARCHAR2 DEFAULT NULL --bug 5028932
,  x_trxn_extension_id  	OUT  	NOCOPY NUMBER
,  x_msg_count       		OUT 	NOCOPY NUMBER
,  x_msg_data        		OUT 	NOCOPY VARCHAR2
,  x_return_status   		OUT 	NOCOPY VARCHAR2
) IS

L_return_status         VARCHAR2(30);
L_msg_count             NUMBER;
L_msg_data              VARCHAR2(2000);
L_response_code         IBY_FNDCPT_COMMON_PUB.Result_rec_type;
L_payer                 IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
L_assign_id             NUMBER;
L_trxn_attribs          IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
l_trxn_extension_id     NUMBER;
l_org_type              VARCHAR2(80) := 'OPERATING_UNIT';
l_cust_account_id	NUMBER;
l_party_id		NUMBER;
l_pos			NUMBER := 0;
l_retry_num		NUMBER := 0;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Entering Create_New_Payment_Trxn.', 1 ) ;
  END IF;

  Select  hca.party_id, acct_site.cust_account_id
  Into    l_party_id, l_cust_account_id
  From    HZ_CUST_SITE_USES_ALL      SITE,
          HZ_CUST_ACCT_SITES         ACCT_SITE,
          HZ_CUST_ACCOUNTS_ALL       HCA
  Where   SITE.SITE_USE_ID = p_site_use_id
  AND     SITE.SITE_USE_CODE  = 'BILL_TO'
  AND     SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
  AND     ACCT_SITE.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
  AND     SITE.ORG_ID = ACCT_SITE.ORG_ID;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Party id in Create payment trxn'||l_party_id);
  END IF;

  l_payer.payment_function :=  'CUSTOMER_PAYMENT'; --Verify
  l_payer.party_id        := l_party_id;
  l_payer.org_type        := l_org_type;
  l_payer.org_id          := p_org_id;
  l_payer.cust_account_id        := l_cust_account_id;
  l_payer.account_site_id        := p_site_use_id;


  IBY_FNDCPT_TRXN_PUB.Get_Transaction_Extension
                        (p_api_version          => 1.0,
                        X_return_status         => l_return_status,
                        X_msg_count             => l_msg_count,
                        X_msg_data              => l_msg_data,
                        P_entity_id             => p_trxn_extension_id,
                        P_payer                 => l_payer,
                        X_trxn_attribs          => l_trxn_attribs,
                        X_response              => l_response_code);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Result error code in Get_Transaction_Extension'||l_response_code.result_code);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Result error code in Get_Transaction_Extension'||l_response_code.result_code);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Get_Transaction_Extension assignment Successful....');
      oe_debug_pub.add('After call to Get Transaction Extension'||l_return_status);
      oe_debug_pub.add('After call to get trxn...instr sec code'||l_trxn_attribs.instrument_security_code);
    END IF;
  END IF;

  -- get assignment id from the payments table
  begin
   -- bug 8586227
  select instr_assignment_id
  into   l_assign_id
  from   IBY_EXTN_INSTR_DETAILS_V
  where  trxn_extension_id = p_trxn_extension_id;
  exception when NO_DATA_FOUND THEN
    null;
  end;

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('Instrument assignment id for existing instrument'||l_assign_id);
  END IF;

  IF p_line_id IS NOT NULL THEN
  -- this is for line split
  l_trxn_attribs.trxn_ref_number1 := p_line_id;


  ELSE
  -- update trxn_ref_number2 to append string "R(n+1)" , where n is the
  -- previous retry number. The was suggested by IBY to avoid IBY restriction
  -- that order_id, ref_number1 and ref_number2 must be unique for each
  -- trxn_extension_id.
  l_pos := instr(l_trxn_attribs.trxn_ref_number2,'R');


  IF l_pos > 0 THEN
    l_retry_num := substr(l_trxn_attribs.trxn_ref_number2, l_pos+1, length(l_trxn_attribs.trxn_ref_number2)) + 1;
  l_trxn_attribs.trxn_ref_number2 := substr(l_trxn_attribs.trxn_ref_number2, 1, l_pos)||to_char(l_retry_num);
  ELSE
    l_retry_num := 1;
  l_trxn_attribs.trxn_ref_number2 := l_trxn_attribs.trxn_ref_number2||'R'||to_char(l_retry_num);
  END IF;
  END IF;

  IF l_debug_level > 0 THEN
    oe_debug_pub.add('l_pos is: '||l_pos, 3);
    oe_debug_pub.add('l_retry_num is: '||l_retry_num, 3);
    oe_debug_pub.add('trxn_ref_number2 in Create_New_Payment_Trxn is: '||l_trxn_attribs.trxn_ref_number2, 3);
    oe_debug_pub.add('Before calling create_transaction extension', 3);
    oe_debug_pub.add('Assignment id ---->'|| l_assign_id ,3);
    oe_debug_pub.add('l_trxn_attribs.Instrument_Security_Code --->'||l_trxn_attribs.Instrument_Security_Code, 3);
    oe_debug_pub.add('l_trxn_attribs.order_id ----> '||l_trxn_attribs.order_id ,3);
    oe_debug_pub.add('l_trxn_attribs.trxn_ref_number1 --->'||l_trxn_attribs.trxn_ref_number1, 3);
    oe_debug_pub.add('l_trxn_attribs.trxn_ref_number2 --->'||l_trxn_attribs.trxn_ref_number2, 3);
  END IF;

  --bug 5028932
  IF Oe_Payment_Trxn_Util.Get_CC_Security_Code_Use = 'REQUIRED'
  AND (l_trxn_attribs.Instrument_Security_Code IS NULL OR
  OE_GLOBALS.Equal(l_trxn_attribs.Instrument_Security_Code,FND_API.G_MISS_CHAR))
  THEN
	IF p_instrument_security_code IS NOT NULL AND
	NOT OE_GLOBALS.Equal(p_instrument_security_code,FND_API.G_MISS_CHAR) THEN
		l_trxn_attribs.Instrument_Security_Code := p_instrument_security_code;
	ELSE
		FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
		OE_Msg_Pub.Add;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
  END IF;
  --bug 5028932

  -- create new payment transaction extension id
  IBY_Fndcpt_Trxn_Pub.Create_Transaction_Extension
                                (p_api_version          => 1.0,
                                p_init_msg_list         => FND_API.G_TRUE,
                                p_commit                => FND_API.G_FALSE,
                                X_return_status         => l_return_status,
                                X_msg_count             => l_msg_count,
                                X_msg_data              => l_msg_data,
                                P_payer                 => l_payer,
                                P_payer_equivalency     => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
                                P_pmt_channel           => 'CREDIT_CARD',
                                P_instr_assignment      => l_assign_id,
                                P_trxn_attribs          => l_trxn_attribs,
                                x_entity_id             => x_trxn_extension_id,
                                X_response              => l_response_code);


  IF l_debug_level > 0 THEN
    oe_debug_pub.add('Result code'||l_Response_code.result_code);
    oe_debug_pub.add('Return status'||l_Return_Status);
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Result error code in Create_Transaction_Extension'||l_response_code.result_code);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
    IF l_debug_level > 0 THEN
      oe_debug_pub.add('Create_Transaction_Extension assignment Successful....');
      oe_debug_pub.add('After call to Create_Transaction_Extension'||l_return_status);
      oe_debug_pub.add('New trxn extension id'||x_trxn_extension_id);
    END IF;
  END IF;

  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting Create_New_Payment_Trxn.', 1 ) ;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      X_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_Verify_Payment_PUB'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Create_New_Payment_Trxn;

END OE_Verify_Payment_PUB ;

/
