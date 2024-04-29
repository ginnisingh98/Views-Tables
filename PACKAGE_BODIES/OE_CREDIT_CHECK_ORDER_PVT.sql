--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_ORDER_PVT" AS
-- $Header: OEXVCRHB.pls 120.11.12010000.4 2009/11/19 14:34:58 amimukhe ship $
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--|                                                                       |
--| FILENAME                                                              |
--|   OEXVCRHB.pls                                                        |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   Body of package OE_credit_check_order_PVT. It is used to determine  |
--|   if an order is subject to credit check. If it is, it will determine |
--|   the available credit for a given credit rule that will check against|
--|   the credit limits for the bill-to customer/site. The result returned|
--|   will be                                                             |
--|     'PASS' if the customer/site passes credit check                   |
--|     'FAIL' if the customer/site fails credit check                    |
--|                                                                       |
--| HISTORY                                                               |
--|   Jun-01-2001  rajkrish created                                       |
--|   Jan-29-2002  multi org 3PM                                          |
--|                ontdev => 115.19 2001/11/07 23:24:54                   |
--|   Feb-14-2002  vto      modified for external credit check API        |
--|   Feb-20-2002  vto      Added function Address_Value_To_ID            |
--|   Feb-25-2002  tsimmond Added code for days_honor_manual_release      |
--|                         to Check_Manual_Released_Holds function       |
--|   Mar-15-2002  vto      Set G_result_out in                           |
--|                         check_other_credit_limits                     |
--|   Mar-16-2002  tsimmond change condition in                           |
--|                         Check_Manual_Released_Holds                   |
--|   Mar-25-2002  tsimmond changed '>' to '>=" for manual holds          |
--|   Apr-16-2002  vto      fix bug 2325545. hold comment not set         |
--|   Apr-26-2002  rajkrish BUG 2338145                                   |
--|   Jun-11-2002  rajkrish 2412678                                       |
--|                rajkrish Bug 2787722                                   |
--|   Aug-28-2002  rajkrish BUG 2505245                                   |
--|   Sep-01-2002  tsimmond added code for FPI, submit AR                 |
--|                         Credit Management Review                      |
--|   Nov-19-2002                                                         |
--|   06-DEC-2002  vto      Added NOCOPY to OUT variables                 |
--|   07-Jan-2003  tsimmond changed parameters values in Submit           |
--|                         Credit Review                                 |
--|   07-Feb-2003           2787722                                       |
--|   Apr-01-2003  vto      2885044,2853800. Modify call to Check_Holds to|
--|                         pass in item_type and activity_name globals   |
--|   Apr-09-2003  tsimmond 2888032, changes in Submit Credit Review      |
--|   May-15-2003  vto      2894424, 2971689. New cc calling action:      |
--|                         AUTO HOLD, AUTO RELEASE.                      |
--|                         Obsolete calling action: AUTO                 |
--|   Bugbug2971644 June 12 rajkrish                                      |
--|   Bug 2948597 JUne 13 rajkrish                                        |
--|   Aug-24-2004 vto       modified to support partial payments.         |
--|                         also set created_by for release hold_source=1 |
--|   Jan-15-2004 vto       3364726.G_crmgmt_installed instead of =TRUE   |
--|   Mar-10-2004 aksingh   3462295. Added api Update_Comments_And_Commit |
--|   Jul-23-2004 vto       3788597.  Modified get_order_exposure to not  |
--|                         check hold if the calling action=EXTERNAL.    |
--|=======================================================================+

--------------------
-- TYPE DECLARATIONS
--------------------


------------
-- CONSTANTS
------------
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_credit_check_order_PVT';

---------------------------
-- PRIVATE GLOBAL VARIABLES
---------------------------
G_debug_flag VARCHAR2(1) := NVL( OE_CREDIT_CHECK_UTIL.check_debug_flag ,'N') ;
G_result_out  VARCHAR2(10) := 'PASS' ;
G_order       NUMBER       ;

g_hold_exist  VARCHAR2(1) := NULL ;
---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--------------------------------------------------
-- Build the holds table to store the different
-- type of holds on the order lines for processing
-- during the credit check cycle.
--------------------------------------------------

-------------------------------------------------------
-- Check if credit hold was manually released.
--   N: No release records found
--   Y: Release records found
-------------------------------------------------------
FUNCTION Check_Manual_Released_Holds
  ( p_calling_action    IN   VARCHAR2
  , p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
  , p_header_id         IN   NUMBER
  , p_line_id		IN   NUMBER
  , p_credit_check_rule_rec IN
                   OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  )
RETURN VARCHAR2
IS
  l_hold_release_id           NUMBER;
  l_dummy                     VARCHAR2(1);
  l_manual_hold_exists        VARCHAR2(1) := 'N';
  l_released_rec_exists       VARCHAR2(1) := 'Y';
  l_release_date              DATE;

BEGIN
  IF G_debug_flag = 'Y'
  THEN

    OE_DEBUG_PUB.Add('OEXVCRHB: In Check_Manual_Released_Holds');
    OE_DEBUG_PUB.Add('Check Header ID/Line ID: '||p_header_id||'/'||p_line_id);
    OE_DEBUG_PUB.Add('p_calling action = '|| p_calling_action );
    OE_DEBUG_PUB.Add('G_delayed_request = '||
       OE_credit_engine_GRP.G_delayed_request );
  END IF;

  -- Will check only if delayed_request is FALSE
  -- In other words, it will not check if the order is updated

  -- Adding 'AUTO HOLD' for bug# 4207478
  IF p_calling_action IN ('SHIPPING', 'PACKING' , 'PICKING', 'AUTO HOLD')
     AND NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
             FND_API.G_FALSE
  THEN

    BEGIN
        SELECT  /* MOAC_SQL_CHANGE */ NVL(MAX(H.HOLD_RELEASE_ID),0)
        INTO   l_hold_release_id
        FROM OE_ORDER_HOLDS h,
             OE_HOLD_SOURCES_ALL s
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
        OE_DEBUG_PUB.Add
         ('No data found ');
        l_released_rec_exists := 'N';
    END;

    IF l_released_rec_exists = 'Y' THEN
       BEGIN
         SELECT
           'Y',CREATION_DATE
         INTO
           l_manual_hold_exists
         , l_release_date
         FROM OE_HOLD_RELEASES
         WHERE HOLD_RELEASE_ID = l_hold_release_id
           AND RELEASE_REASON_CODE <> 'PASS_CREDIT'
           AND CREATED_BY <> 1;

         -----check if days_honor_manual_release expired
         IF p_credit_check_rule_rec.days_honor_manual_release IS NOT NULL
         THEN
           IF (l_release_date +
       p_credit_check_rule_rec.days_honor_manual_release
                     >= SYSDATE )
           THEN
             l_manual_hold_exists := 'Y';
           ELSE
             l_manual_hold_exists := 'N';
           END IF;
         END IF;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           OE_DEBUG_PUB.Add
            ('No manually released credit holds for Header ID/Line ID: '||
             p_header_id||'/'||p_line_id,1);
           l_manual_hold_exists := 'N';

       END;
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Check_Manual_Released_Holds:'||l_manual_hold_exists);
  END IF;

  RETURN l_manual_hold_exists;

EXCEPTION
  WHEN OTHERS THEN
      OE_DEBUG_PUB.ADD(SUBSTR(SQLERRM,1,300) ) ;

      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Check_Manual_Released_Holds'
      );

     RAISE;


END Check_Manual_Released_Holds;

-----------------------------------------------------
-- Check if credit hold exists already
------------------------------------------------------

FUNCTION Hold_Exists
  ( p_header_id         IN NUMBER
  , p_line_id           IN NUMBER
  )
RETURN BOOLEAN IS
  l_hold_result          VARCHAR2(30);
  l_return_status        VARCHAR2(30);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: In Hold_Exists');
    OE_DEBUG_PUB.ADD('OEXVCRHB: Check holds for Header ID : '
                 || p_header_id,1);
    OE_DEBUG_PUB.ADD('g_hold_exist => '|| g_hold_exist );


  END IF;

  IF g_hold_exist = 'Y'
  THEN
    l_hold_result := FND_API.G_TRUE ;
  ELSIF g_hold_exist = 'N'
  THEN
    l_hold_result := 'F' ;
  ELSE
    l_hold_result := NULL ;

    OE_DEBUG_PUB.ADD('Calling OE_HOLDS_PUB.Check_Holds ');

    OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_hold_id        => 1
                      , p_wf_item        =>
          OE_Credit_Engine_GRP.G_cc_hold_item_type
                      , p_wf_activity    =>
          OE_Credit_Engine_GRP.G_cc_hold_activity_name
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => l_return_status
                      );

       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.ADD('OEXVCRHB: Out Check_Holds ');
         OE_DEBUG_PUB.ADD('l_return_status = '|| l_return_status );
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  END IF;  -- g_hold_exist

  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXVCRHB: about to  Hold_Exists');
   OE_DEBUG_PUB.ADD('l_hold_result => '|| l_hold_result );
  END IF;

  IF l_hold_result = FND_API.G_TRUE THEN
    return TRUE;
  ELSE
    return FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Hold_Exists'
      );

     RAISE;
END Hold_Exists;


---------------------------------------------------
-- Write release message to the message table     |
-- table and  to the logfile if called from a     |
-- concurrent program.                            |
---------------------------------------------------

PROCEDURE Write_Release_Message (
    p_calling_action      IN VARCHAR2
  , p_order_number        IN NUMBER
  , p_line_number         IN NUMBER
 )
IS
BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Write_Release_Message');
  END IF;

  IF p_calling_action = 'AUTO RELEASE' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Order Number: '||TO_CHAR(p_order_number)
      ||'  Line Number: '||TO_CHAR(p_line_number)
      ||' released from credit check hold.');
  END IF;

  FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_REMOVED');
  FND_MESSAGE.Set_Token('ORDER_NUMBER',p_order_number);
  FND_MESSAGE.Set_Token('LINE_NUMBER',p_line_number);
  OE_MSG_PUB.Add;
  ---OE_MSG_PUB.Save_Messages(1);

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Write_Release_Message');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Write_Release_Message'
      );

     RAISE;

END Write_Release_Message;

---------------------------------------------------
-- Write appropriate message to either the message|
-- table or to the logfile if called from a       |
-- concurrent program for order level credit hold |
---------------------------------------------------

PROCEDURE Write_Order_Hold_Msg
  (
    p_calling_action      IN VARCHAR2
  , p_cc_limit_used       IN VARCHAR2 DEFAULT NULL
  , p_cc_profile_used     IN VARCHAR2 DEFAULT NULL
  , p_order_number        IN NUMBER
  , p_item_category       IN VARCHAR2 DEFAULT NULL
  , x_comment            OUT NOCOPY VARCHAR2
  )
IS
  l_comment     VARCHAR2(2000);
  l_cc_profile_used         VARCHAR2(30);  --6616741
  l_calling_activity        VARCHAR2(50);  --ER#7479609
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Write_Order_Hold_Msg');
    OE_DEBUG_PUB.Add('p_calling_action => '||
            p_calling_action );
    OE_DEBUG_PUB.Add('p_cc_limit_used => '||
             p_cc_limit_used );
    OE_DEBUG_PUB.Add('p_cc_profile_used => '||
          p_cc_profile_used );
    OE_DEBUG_PUB.Add('p_order_number => '||
             p_order_number );
  END IF;

l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', p_cc_profile_used);  --ER8880886
  -- Write to message stack anyway regardless of the calling action
  IF p_cc_limit_used <> 'ITEM' THEN
      IF p_calling_action <> 'EXTERNAL'
      THEN
         -- bug 4002820
         IF INSTR(p_cc_limit_used, ',') > 0 THEN
         l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', p_cc_profile_used);  -- 6616741
           FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_MSG');
           FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
           --6616741 FND_MESSAGE.Set_Token('CC_PROFILE',p_cc_profile_used);
           FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);  --6616741
           l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
           FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_MSG');
           FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
           --6616741 FND_MESSAGE.Set_Token('CC_PROFILE',p_cc_profile_used);
           FND_MESSAGE.Set_Token('CC_PROFILE',l_cc_profile_used);  --6616741
           OE_MSG_PUB.Add;
         ELSE
           FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                                --p_cc_profile_used); --commented ER8880886
                                                l_cc_profile_used);   --ER8880886
           l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
           FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                               --p_cc_profile_used);  --commented ER8880886
                                               l_cc_profile_used);    --ER8880886
           OE_MSG_PUB.Add;
         END IF;
      ELSE
	  --bug4583872
         IF INSTR(p_cc_limit_used, ',') > 0 THEN
	    FND_MESSAGE.Set_Name('ONT','OE_CC_EXT_MSG');
	    FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
	    FND_MESSAGE.Set_Token('CC_PROFILE',p_cc_profile_used);
	    l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
	    FND_MESSAGE.Set_Name('ONT','OE_CC_EXT_MSG');
	    FND_MESSAGE.Set_Token('LIMIT_USED',p_cc_limit_used);
	    FND_MESSAGE.Set_Token('CC_PROFILE',p_cc_profile_used);
	    OE_MSG_PUB.Add;
	 ELSE
	    FND_MESSAGE.Set_Name('ONT','OE_CC_EXT_'||p_cc_limit_used||'_'||
                                                p_cc_profile_used);
	    l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
	    FND_MESSAGE.Set_Name('ONT','OE_CC_EXT_'||p_cc_limit_used||'_'||
                                               p_cc_profile_used);
	    OE_MSG_PUB.Add;
	 END IF;
      END IF;
  ELSE
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_CATEGORY');
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      l_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_'||p_cc_limit_used||'_'||
                                                'CATEGORY');
      FND_MESSAGE.Set_Token('CATEGORY',p_item_category);
      OE_MSG_PUB.Add;
  END IF;
  --
  -- Write to logfile if original call was from a concurrent program
  --
  IF p_calling_action = 'AUTO HOLD' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order '||TO_CHAR(p_order_number)
      ||': Credit check hold applied');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Hold Comment: '||SUBSTR(l_comment,1,1000));
  END IF;

--ER#7479609 start
   IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO HOLD' THEN
      l_calling_activity := 'Credit Check Processor';
   ELSE
      l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
   END IF;

   FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
   FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
   FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

   l_comment := l_comment||SUBSTR(FND_MESSAGE.GET,1,2000);

--ER#7479609 end

  x_comment := l_comment;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('x_comment => '||
   x_comment );
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Write_Order_Hold_Msg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Write_Order_Hold_Msg'
      );

     RAISE;

END Write_Order_Hold_Msg;

---------------------------------------------------
-- Write release message to the screen or to the
-- log file if called from a concurrent program.
---------------------------------------------------
PROCEDURE Write_Order_Release_Msg
 (  p_calling_action      IN VARCHAR2
  , p_order_number        IN NUMBER
 )
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Write_Order_Release_Msg');
  END IF;

  IF p_calling_action = 'AUTO RELEASE' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Order '||TO_CHAR(p_order_number)
                      ||': Credit check hold released.');
  ELSE
    FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_REMOVED');
    OE_MSG_PUB.Add;
  END IF;
  --
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Write_Order_Release_Msg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Write_Order_Release_Msg'
      );

     RAISE;

END Write_Order_Release_Msg;

------------------------------------------------

PROCEDURE Apply_hold_and_commit
  ( p_hold_source_rec      IN
     OE_HOLDS_PVT.Hold_Source_Rec_Type
  , x_msg_count            OUT NOCOPY NUMBER
  , x_msg_data             OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  )
IS

  PRAGMA AUTONOMOUS_TRANSACTION;


BEGIN

  OE_DEBUG_PUB.ADD(' OEXVCRHB: In Apply_hold_and_commit ');
  OE_DEBUG_PUB.ADD(' Call OE_Holds_PUB.Apply_Holds ');


  OE_Holds_PUB.Apply_Holds
          (   p_api_version       => 1.0
          ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
          ,   p_hold_source_rec   => p_hold_source_rec
          ,   x_msg_count         => x_msg_count
          ,   x_msg_data          => x_msg_data
          ,   x_return_status     => x_return_status
          );

    OE_DEBUG_PUB.ADD(' Out OE_Holds_PUB.Apply_Holds ');
    OE_DEBUG_PUB.ADD(' x_return_status => '|| x_return_status );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

         OE_DEBUG_PUB.ADD(' Holds success ');
         OE_DEBUG_PUB.ADD(' About to Issue COMMIT');

         COMMIT;

         OE_DEBUG_PUB.ADD(' AFter Issue COMMIT');

        END IF;

  OE_DEBUG_PUB.ADD(' OEXVCRHB: OUT Apply_hold_and_commit ');

EXCEPTION
  WHEN OTHERS THEN
   rollback;
   OE_DEBUG_PUB.ADD(' Error in Apply_hold_and_commit ' );
   OE_DEBUG_PUB.ADD(' SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Apply_hold_and_commit'
      );

     RAISE;

END Apply_hold_and_commit ;

----------------------------------------------------
-- Procedure to Update Hold Comments And Commit   --
----------------------------------------------------
PROCEDURE Update_Comments_And_Commit
  ( p_hold_source_rec  IN         OE_HOLDS_PVT.Hold_Source_Rec_Type
  , x_msg_count        OUT NOCOPY NUMBER
  , x_msg_data         OUT NOCOPY VARCHAR2
  , x_return_status    OUT NOCOPY VARCHAR2
  )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: Entering Update_Comments_And_Commit');
    OE_DEBUG_PUB.ADD('OEXVCRHB: Before OE_Holds_PUB.Update_Hold_Comments');
  END IF;

  OE_Holds_PUB.Update_Hold_comments
      (   p_hold_source_rec   => p_hold_source_rec
      ,   x_msg_count         => x_msg_count
      ,   x_msg_data          => x_msg_data
      ,   x_return_status     => x_return_status
      );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: After OE_Holds_PUB.Update_Hold_Comments Status '
                     || x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRHB: Update Hold Comment Success, Issue COMMIT');
    END IF;

    COMMIT;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXVCRHB: After Issuing COMMIT');
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' OEXVCRHB: Exiting Update_Comments_And_Commit');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   rollback;
   OE_DEBUG_PUB.ADD('OEXVCRHB: Error in Update_Comments_And_Commit' );
   OE_DEBUG_PUB.ADD('SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Update_Comments_And_Commit'
      );

     RAISE;

END Update_Comments_And_Commit ;

--------------------------------------------------

---------------------------------------------------
-- Apply credit check hold on the specified order
---------------------------------------------------
/*
** Bug # 3415608 and 3430235
** Reverted changes done under bug # 3386382.
** Introduced new procedure Update_Comments_And_Commit to
** Update and Commit Hold Comments. Apply_Holds_And_Commit
** And Update_Comments_And_Commit are now called whenever
** Calling Action is Picking, Packing or Shipping ELSE
** Apply_Holds and Update_Hold_Comments are called.
*/

PROCEDURE Apply_Order_CC_Hold
 (  p_header_id            IN NUMBER
  , p_order_number         IN NUMBER
  , p_calling_action       IN VARCHAR2   DEFAULT 'BOOKING'
  , p_cc_limit_used        IN VARCHAR2
  , p_cc_profile_used      IN VARCHAR2
  , p_item_category_id     IN NUMBER
  , p_system_parameter_rec IN OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , p_credit_check_rule_rec IN
                  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , x_cc_hold_comment      OUT NOCOPY VARCHAR2
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  )
IS

  -- Cursor to select the category description
  CURSOR item_category_csr IS
    SELECT description
    FROM   mtl_categories
    WHERE  category_id = p_item_category_id;

  l_item_category      VARCHAR2(240):= NULL;
  l_cc_result_out      VARCHAR2(30) := 'FAIL_NONE';
  l_hold_exists        VARCHAR2(1) := NULL ;
  l_msg_count          NUMBER := 0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(30);
  l_hold_comment       VARCHAR2(2000);
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Apply_Order_CC_Hold');
  END IF;

  IF p_cc_limit_used = 'ITEM' THEN
    OPEN item_category_csr;
    FETCH item_category_csr INTO l_item_category;
    CLOSE item_category_csr;
  END IF;

  --
  -- Set hold source
  --
  l_hold_source_rec.hold_id          := 1;           -- credit hold
  l_hold_source_rec.hold_entity_code := 'O';         -- order hold
  l_hold_source_rec.hold_entity_id   := p_header_id; -- order header
  --
  IF Hold_Exists( p_header_id => p_header_id
                , p_line_id   => NULL
                ) THEN
    G_result_out  := 'FAIL' ;
    Write_Order_Hold_Msg
      (
         p_calling_action      => p_calling_action
       , p_cc_limit_used       => p_cc_limit_used
       , p_cc_profile_used     => p_cc_profile_used
       , p_order_number        => p_order_number
       , p_item_category       => l_item_category
       , x_comment             => l_hold_comment
      );

    l_hold_source_rec.hold_comment := l_hold_comment;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('OEXVCRHB: Hold already applied on Header ID:' ||
      p_header_id, 1);
    END IF;

    IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
    THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRHB: Call Update_Comments_And_Commit');
      END IF;

      Update_Comments_And_Commit
      (   p_hold_source_rec   => l_hold_source_rec
      ,   x_msg_count         => l_msg_count
      ,   x_msg_data          => l_msg_data
      ,   x_return_status     => l_return_status
      );

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRHB: Out Update_Comments_And_Commit');
      END IF;

    ELSIF  NVL( p_calling_action,'BOOKING') IN ('BOOKING','UPDATE','AUTO HOLD')
    THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRHB: Call OE_Holds_PUB.Update_Hold_Comments directly');
      END IF;

      OE_Holds_PUB.Update_hold_comments
      (   p_hold_source_rec   => l_hold_source_rec
      ,   x_msg_count         => l_msg_count
      ,   x_msg_data          => l_msg_data
      ,   x_return_status     => l_return_status
      );

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRHB: Out OE_Holds_PUB.Update_Hold_Comments directly');
      END IF;
    END IF;  -- Calling Action

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('OEXVCRHB: Updated Comments on Header ID:'
                     ||p_header_id, 1);
      END IF;
    END IF;
  ELSE
    IF Check_Manual_Released_Holds(
       p_calling_action    => p_calling_action
      ,p_hold_id           => 1
      ,p_header_id         => p_header_id
      ,p_line_id           => NULL
      ,p_credit_check_rule_rec=>p_credit_check_rule_rec
      ) = 'N'
    THEN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add('No manual released holds ');
      END IF;
      G_result_out  := 'FAIL' ;
      Write_Order_Hold_Msg
        (
          p_calling_action      => p_calling_action
        , p_cc_limit_used       => p_cc_limit_used
        , p_cc_profile_used     => p_cc_profile_used
        , p_order_number        => p_order_number
        , p_item_category       => l_item_category
        , x_comment             => l_hold_comment
        );
      l_hold_source_rec.hold_comment := l_hold_comment;

      ------------------------------------------------------------
      -- Call for all actions except for the
      -- concurrent program credit check processor
      IF NVL(p_calling_action, 'BOOKING') IN ('SHIPPING','PACKING','PICKING')
      THEN

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Call Apply_hold_and_commit ');
        END IF;

        Apply_hold_and_commit
           ( p_hold_source_rec   => l_hold_source_rec
            , x_msg_count        => l_msg_count
            , x_msg_data         => l_msg_data
            , x_return_status    => l_return_status
            );

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Out Apply_hold_and_commit ');
        END IF;

      ELSIF  NVL( p_calling_action,'BOOKING') IN ('BOOKING','UPDATE','AUTO HOLD')
      THEN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Call OE_Holds_PUB.Apply_Holds directly');
        END IF;


        OE_Holds_PUB.Apply_Holds
          ( p_api_version       => 1.0
          , p_validation_level  => FND_API.G_VALID_LEVEL_NONE
          , p_hold_source_rec   => l_hold_source_rec
          , x_msg_count         => l_msg_count
          , x_msg_data          => l_msg_data
          , x_return_status     => l_return_status
          );

        IF G_debug_flag = 'Y' THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Out OE_Holds_PUB.Apply_Holds directly');
        END IF;
      END IF; --check calling action


      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF G_debug_flag = 'Y' THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Credit check hold applied header_ID: '
                     ||p_header_id, 1);
        END IF;
      END IF;
      l_cc_result_out := 'FAIL_HOLD';
    END IF; -- Check manual holds
  END IF; -- Check hold exist
  x_cc_hold_comment   := l_hold_comment;
  x_cc_result_out     := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: Apply_Order_CC_Hold Result = '
            ||x_cc_result_out);
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Apply_Order_CC_Hold');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Apply_Order_CC_Hold'
      );

     RAISE;

END Apply_Order_CC_Hold;

-----------------------------------------
-- Release order level credit check hold
-- in the database.
-----------------------------------------

PROCEDURE Release_Order_CC_Hold
 (  p_header_id             IN NUMBER
  , p_order_number          IN NUMBER
  , p_calling_action        IN VARCHAR2   DEFAULT 'BOOKING'
  , P_SYSTEM_PARAMETER_REC  IN OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  )
IS

  --ER#7479609 l_hold_entity_id         NUMBER := p_header_id;
  l_hold_entity_id         oe_hold_sources_all.hold_entity_id%TYPE := p_header_id;  --ER#7479609
  l_hold_id                NUMBER;
  l_hold_exists            VARCHAR2(1);
  l_hold_result            VARCHAR2(30);
  l_msg_count              NUMBER := 0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(30);
  l_release_reason         VARCHAR2(30);
  l_cc_result_out          VARCHAR2(30) := 'PASS_NONE';
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
  l_hold_release_rec   OE_HOLDS_PVT.Hold_Release_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Release_REC;
  l_calling_activity   VARCHAR2(50);   --ER#7479609
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Release_Order_CC_Hold',1);
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Check if Holds exist to release ');
  END IF;

  IF hold_exists( p_header_id => p_header_id
                , p_line_id   => NULL
                )
  THEN
    l_hold_source_rec.hold_id := 1;  -- Credit Checking hold
    l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
    l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id;

    l_hold_release_rec.release_reason_code := 'PASS_CREDIT';
    l_hold_release_rec.release_comment := 'Credit Check Engine' ;
    l_hold_release_rec.created_by       := 1;  -- indicate non-manual release

--ER#7479609 start
   IF OE_Verify_Payment_PUB.G_init_calling_action = 'AUTO RELEASE' THEN
      l_calling_activity := 'Credit Check Processor';
   ELSE
      l_calling_activity := InitCap(OE_Verify_Payment_PUB.G_init_calling_action);
   END IF;

   FND_MESSAGE.Set_Name('ONT','OE_CC_HOLD_ACT_COM');
   FND_MESSAGE.Set_Token('CALLING_ACTIVITY',l_calling_activity);
   FND_MESSAGE.Set_Token('CREDIT_CHECK_RULE',OE_Verify_Payment_PUB.G_credit_check_rule);

   l_hold_release_rec.release_comment := l_hold_release_rec.release_comment||SUBSTR(FND_MESSAGE.GET,1,2000);

--ER#7479609 end


    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Attempt to Release hold on ' || p_header_id, 1);
    END IF;

    IF NVL(p_calling_action, 'BOOKING') <> 'AUTO HOLD' THEN
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
        Write_Order_Release_Msg(
          p_calling_action    => p_calling_action
        , p_order_number      => p_order_number
        );

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('OEXVCRHB: Released credit check hold on Header ID:'
                     || p_header_id, 1);
        END IF;
      END IF;
      l_cc_result_out := 'PASS_REL';
    END IF; -- calling action check
  END IF; -- hold exist
  x_cc_result_out := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Release_Order_CC_Hold');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Release_Order_CC_Hold'
      );

     RAISE;

END Release_Order_CC_Hold;


-------------------------------------------------
-- Chk_Past_Due_Invoice
-- Check if any Invoice exist with past due date

--------------------------------------------------
PROCEDURE Chk_Past_Due_Invoice
 ( p_customer_id        IN   NUMBER
 , p_site_use_id        IN   NUMBER
 , p_party_id           IN   NUMBER
 , p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
 , p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
 , p_credit_level       IN   VARCHAR2
 , p_usage_curr         IN   oe_credit_check_util.curr_tbl_type
 , p_include_all_flag   IN   VARCHAR2
 , p_global_exposure_flag IN VARCHAR2 := 'N'
 , x_cc_result_out      OUT  NOCOPY VARCHAR2
 , x_return_status      OUT  NOCOPY VARCHAR2
 )
IS
  l_exist_flag   VARCHAR2(1);

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: In Chk_Past_Due_Invoice');
    OE_DEBUG_PUB.ADD('p_global_exposure_flag = '|| p_global_exposure_flag );
    OE_DEBUG_PUB.ADD('Call Get_Past_Due_Invoice ');
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Default to pass
  x_cc_result_out := 'PASS';




  OE_CREDIT_CHECK_UTIL.Get_Past_Due_Invoice
  ( p_customer_id             => p_customer_id
  , p_site_use_id             => p_site_use_id
  , p_party_id                => p_party_id
  , p_credit_check_rule_rec   => p_credit_check_rule_rec
  , p_system_parameter_rec    => p_system_parameter_rec
  , p_credit_level            => p_credit_level
  , p_usage_curr              => p_usage_curr
  , p_include_all_flag        => p_include_all_flag
  , p_global_exposure_flag    => p_global_exposure_flag
  , x_exist_flag              => l_exist_flag
  , x_return_status           => x_return_status
  );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' After Get_Past_Due_Invoice ');
    OE_DEBUG_PUB.ADD(' x_return_status = '|| x_return_status);
    OE_DEBUG_PUB.ADD(' l_exist_flag = '|| l_exist_flag );
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF l_exist_flag = 'Y'
  THEN
    x_cc_result_out := 'FAIL';
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' x_cc_result_out  = '|| x_cc_result_out );
    OE_DEBUG_PUB.ADD('OEXVCRHB: Out Chk_Past_Due_Invoice');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Chk_Past_Due_invoice');
     END IF;
END Chk_Past_Due_Invoice;

--------------------------------------------------------------
-- Check_Trx_Limit
-- Check if the current order transaction amount exceeds the
-- credit limit
---------------------------------------------------------------
PROCEDURE Check_Trx_Limit
  (   p_header_rec	       IN   OE_ORDER_PUB.header_rec_type
  ,   p_customer_id            IN   NUMBER
  ,   p_site_use_id            IN   NUMBER
  ,   p_credit_level           IN   VARCHAR2
  ,   p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  ,   p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  ,   p_limit_curr_code        IN   VARCHAR2
  ,   p_trx_credit_limit       IN   NUMBER
  ,   p_calling_action         IN   VARCHAR2
  ,   p_transaction_amount     IN   NUMBER
  ,   x_cc_result_out          OUT  NOCOPY VARCHAR2
  ,   x_return_status          OUT  NOCOPY VARCHAR2
  ,   x_conversion_status      OUT  NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
  )
IS

  l_order_value	          NUMBER := 0 ;

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: In Check_Trx_Limit');
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Default to Pass
  x_cc_result_out := 'PASS';

  ----------------------------------------------
  -- additional task -  Read the value of      |
  -- include_tax_flag from credit check rule   |
  -- and calculate the value of l_order_values |
  -- accordingly. If the value of              |
  -- include_tax_flag is NULL that means it is |
  -- 'No'                                      |
  ----------------------------------------------
  --
  -- Call the get_transaction_amount procedure if the calling_action
  -- <> EXTERNAL, else call the GET_external_trx_amount procedure
  --
  IF NVL(p_calling_action,'BOOKING') <> 'EXTERNAL' THEN
    ----------------------------------------------
    -- Do not include lines with payment term    |
    -- that have credit check flag = N. NULL     |
    -- means Y.                                  |
    ----------------------------------------------
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' call GET_transaction_amount ');
    END IF;

    OE_CREDIT_CHECK_UTIL.GET_transaction_amount
    ( p_header_id              => p_header_rec.header_id
    , p_transaction_curr_code  => p_header_rec.transactional_curr_code
    , p_credit_check_rule_rec  => p_credit_check_rule_rec
    , p_system_parameter_rec   => p_system_parameter_rec
    , p_customer_id            => NULL
    , p_site_use_id            => NULL
    , p_limit_curr_code        => p_limit_curr_code
    , x_amount                 => l_order_value
    , x_conversion_status      => x_conversion_status
    , x_return_status          => x_return_status
   );

    IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.ADD(' after GET_transaction_amount with status  '
         || x_return_status );
    END IF;

  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' call GET_external_trx_amount ');
    END IF;

    OE_CREDIT_CHECK_UTIL.GET_external_trx_amount
    ( p_transaction_curr_code  => p_header_rec.transactional_curr_code
    , p_transaction_amount     => p_transaction_amount
    , p_credit_check_rule_rec  => p_credit_check_rule_rec
    , p_system_parameter_rec   => p_system_parameter_rec
    , p_limit_curr_code        => p_limit_curr_code
    , x_amount                 => l_order_value
    , x_conversion_status      => x_conversion_status
    , x_return_status          => x_return_status
    );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' after GET_transaction_amount with status  '
         || x_return_status );
    END IF;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' err curr table count = '
                     || x_conversion_status.COUNT );
  END IF;

  IF NVL(x_conversion_status.COUNT,0) > 0
  THEN
    IF G_debug_flag = 'Y'
    THEN
     OE_DEBUG_PUB.ADD(' Currency conversion failure ');
    END IF;

   x_cc_result_out := 'FAIL';

  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.Add('Fails trx credit limit');
  END IF;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' l_order_value = ' || l_order_value );
    OE_DEBUG_PUB.ADD(' p_trx_credit_limit = '|| p_trx_credit_limit );
  END IF;


  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF l_order_value > NVL(p_trx_credit_limit ,l_order_value )
  THEN
     x_cc_result_out := 'FAIL';

  END IF;

  IF NVL(x_conversion_status.COUNT,0) > 0
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' Currency conversion failure ');
    END IF;

   x_cc_result_out := 'FAIL';

   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
   FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
   FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
   FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));
   OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;

   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
   FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
   FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
   FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'));
   OE_MSG_PUB.ADD;

   G_result_out  := 'FAIL' ;
   x_cc_result_out := 'FAIL';
   x_return_status := FND_API.G_RET_STS_ERROR;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Return status after assigned as Error = '
          || x_return_status );
    END IF;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('x_cc_result_out = ' || x_cc_result_out );
    OE_DEBUG_PUB.ADD('OEXVCRHB: Out Check_Trx_Limit');
  END IF;
EXCEPTION
   WHEN others THEN
	OE_DEBUG_PUB.Add('Check_Trx_Limit: Other exceptions');
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Check_Trx_Limit'
       );
     END IF;
END Check_Trx_Limit;


-------------------------------------------------------------------
-- FUNCTION: check_credit_check_flags
-- COMMENT:
--           The function has been renamed from check_pay_term.
--           It check if there is at least one line in the order
--           that have both the associated payment term and payment
--           type code credit check flag set to Yes, then
--           the order requires credit check.
--           IF at least one line exists, THEN
--             RETURN 'Y'
--           ELSE RETURN 'N'.
--           It is used to determine if the order is subject to
--           credit check.
--           Default is Yes
---------------------------------------------------------------------
FUNCTION check_credit_check_flags
( p_header_id IN NUMBER )
RETURN VARCHAR2
IS

l_exist       VARCHAR2(1);
l_count       NUMBER ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' IN check_credit_check_flags ');
  END IF;

    SELECT /* MOAC_SQL_NO_CHANGE */ COUNT(line_id)
    INTO   l_count
    FROM   OE_ORDER_LINES_ALL L
    ,      OE_ORDER_HEADERS_ALL H
    ,      RA_TERMS_B T
    WHERE  h.HEADER_ID = p_header_id
    AND    L.HEADER_ID = H.HEADER_ID
    AND    T.TERM_ID   = L.PAYMENT_TERM_ID
    AND    NVL(T.CREDIT_CHECK_FLAG,'N') = 'Y'  --bug4888346
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(l.org_id,-99))
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

    IF l_count > 0
    THEN
      l_exist := 'Y' ;
    ELSE
      l_exist := 'N' ;
    END IF;


  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' l_exist = '|| l_exist );
    OE_DEBUG_PUB.Add(' l_count = '|| l_count );
    OE_DEBUG_PUB.Add(' OUT check_credit_check_flags ');
  END IF;

  RETURN l_exist;

EXCEPTION
   WHEN others THEN
    OE_DEBUG_PUB.Add('check_credit_check_flags: Other exceptions');
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'check_credit_check_flags'
       );
     END IF;
     RAISE;
END check_credit_check_flags;



 -----------------------------------------------------+
  -- A trx is subject to credit check if all the       |
  -- following four conditions are true:               |
  -- 1. related credit rule available for the trx type |
  -- 2. credit check enabled for the payment term      |
  -- 3. credit check enabled for site or cust          |
  -- 4. credit limits available for site or cust       |
  -- When true, the procedure returns limits/other info|
  ------------------------------------------------------

PROCEDURE Validate_other_credit_check
  ( p_header_rec           IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id          IN  NUMBER
  , p_site_use_id          IN  NUMBER
  , p_calling_action       IN  VARCHAR2  := 'BOOKING'
  , p_credit_check_rule_rec IN
              OE_Credit_Check_Util.OE_credit_rules_rec_type
  , p_party_id              IN NUMBER
  , x_check_order_flag     OUT NOCOPY VARCHAR2
  , x_credit_check_lvl_out OUT NOCOPY VARCHAR2
  , x_default_limit_flag   OUT NOCOPY VARCHAR2
  , x_limit_curr_code      OUT NOCOPY VARCHAR2
  , x_overall_credit_limit OUT NOCOPY NUMBER
  , x_trx_credit_limit     OUT NOCOPY NUMBER
  , x_usage_curr           OUT NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
  , x_include_all_flag     OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_global_exposure_flag OUT NOCOPY VARCHAR2
  , x_credit_limit_entity_id OUT NOCOPY NUMBER

  )
  IS

  l_suppress_flag              VARCHAR2(1) := 'N' ;
  l_credit_check_flag          VARCHAR2(1) ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXVCRHB: In Validate_other_credit_check');
    OE_DEBUG_PUB.ADD('HEADER id = '|| p_header_rec.header_id );
    OE_DEBUG_PUB.ADD('p_customer_id = '|| p_customer_id );
    OE_DEBUG_PUB.ADD('p_site_use_id = ' || p_site_use_id );
  END IF;

   x_check_order_flag := 'Y';
   x_return_status    := FND_API.G_RET_STS_SUCCESS;
   x_global_exposure_flag := 'N' ;

  -- If precalculated, no need to figure out the
  -- transaction curr first during ALL currency check

  IF NVL(p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG,'N') = 'N'
  THEN
   l_suppress_flag := 'Y' ;
  ELSE
   l_suppress_flag := 'N' ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.ADD('QUICK_CR_CHECK_FLAG = '||
            p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG );
     OE_DEBUG_PUB.ADD('l_suppress_flag = '|| l_suppress_flag );
     OE_DEBUG_PUB.ADD('----------------------------------------- ');
  END IF;



  ------------------------------------------------
  -- Program Logic:                              |
  -- 1. get site-level limit for the trx         |
  -- 2. If (1) fails, get-customer-level limit   |
  -----------------------------------------------|
  -- level | data         | meaning              |
  -----------------------------------------------|
  -- site  | credit_check | stop. credit check   |
  --       | flag = 'N'   | not reqd for the trx |
  -----------------------------------------------|
  -- site  | trx limit &  | check customer       |
  --       | overall limit| limits (and default  |
  --       | are null     | limit for the org)   |
  -----------------------------------------------|
  -- cust/ | credit_check | stop. credit check   |
  -- org   | flag = 'N'   | not reqd for the trx |
  -----------------------------------------------|
  -- cust/ | trx limit &  | stop. credit check   |
  -- org   | overall limit| not reqd for the trx |
  --       | are null     |                      |
  -----------------------------------------------|
  -- Note:                                       |
  -- all rules of customer limits apply to the   |
  -- default limits of the operating unit        |
  -- [a 11.5.3 feature]                          |
  ------------------------------------------------


    OE_CREDIT_CHECK_UTIL.Get_Limit_Info
    (  p_header_id                    => p_header_rec.header_id
    ,  p_entity_type                  => 'SITE'
    ,  p_entity_id                    => p_site_use_id
    ,  p_cust_account_id              => p_customer_id
    ,  p_party_id                     => p_party_id
    ,  p_trx_curr_code                => p_header_rec.transactional_curr_code
    ,  p_suppress_unused_usages_flag  => l_suppress_flag
    ,  p_navigate_to_next_level       => 'Y'
    ,  p_precalc_exposure_used        =>
                  p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG
    ,  x_limit_curr_code              => x_limit_curr_code
    ,  x_trx_limit                    => x_trx_credit_limit
    ,  x_overall_limit                => x_overall_credit_limit
    ,  x_include_all_flag             => x_include_all_flag
    ,  x_usage_curr_tbl               => x_usage_curr
    ,  x_default_limit_flag           => x_default_limit_flag
    ,  x_global_exposure_flag         => x_global_exposure_flag
    ,  x_credit_limit_entity_id       => x_credit_limit_entity_id
    ,  x_credit_check_level           => x_credit_check_lvl_out
    );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' after SITE  Get_Limit_Info ');
    OE_DEBUG_PUB.ADD(' l_credit_check_flag  ==> '|| l_credit_check_flag );
    OE_DEBUG_PUB.ADD(' x_limit_curr_code    ==> ' || x_limit_curr_code );
    OE_DEBUG_PUB.ADD(' x_trx_credit_limit   ==> '|| x_trx_credit_limit );
    OE_DEBUG_PUB.ADD(' x_overall_credit_limit
                          ==> '|| x_overall_credit_limit );
  END IF;

  IF (x_trx_credit_limit IS NULL AND
     x_overall_credit_limit IS NULL )
  THEN
    x_global_exposure_flag    := 'N' ;
    x_check_order_flag        := 'N' ;
    x_credit_limit_entity_id  := NULL;
    x_credit_check_lvl_out    := NULL ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.ADD(' ');
     OE_DEBUG_PUB.ADD('Results from the credit profiles check');
     OE_DEBUG_PUB.ADD('--------------------------------------------');
     OE_DEBUG_PUB.Add('x_check_order_flag      = '
                      || x_check_order_flag,1 );
     OE_DEBUG_PUB.Add('x_credit_check_lvl_out  = '
                       || x_credit_check_lvl_out,1);
     OE_DEBUG_PUB.Add('x_default_limit_flag    = '
                        || x_default_limit_flag);
     OE_DEBUG_PUB.Add('x_limit_curr_code       = '
                        || x_limit_curr_code,1);
     OE_DEBUG_PUB.Add('x_overall_credit_limit  = '
                          ||x_overall_credit_limit,1);
     OE_DEBUG_PUB.Add('x_trx_credit_limit      = '
                          || x_trx_credit_limit,1);
     OE_DEBUG_PUB.Add('x_include_all_flag      = '
                         ||x_include_all_flag);
     OE_DEBUG_PUB.add ('x_global_exposure_flag    = '||
              x_global_exposure_flag,1 );
     OE_DEBUG_PUB.add ('x_credit_limit_entity_id => '||
           x_credit_limit_entity_id );

     OE_DEBUG_PUB.ADD(' ');
     OE_DEBUG_PUB.ADD('****** List of associated Usage currency rules **** ');
     OE_DEBUG_PUB.ADD(' ');
  END IF;

  FOR K IN 1..x_usage_curr.COUNT
  LOOP
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' Usage currency ' || k || ' => ' ||
         x_usage_curr(K).usage_curr_code );
    END IF;

  END LOOP ;


  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' ');
    OE_DEBUG_PUB.ADD('**************** End of List *********************** ');
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Validate_other_credit_check');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Validate_other_credit_check'
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_other_credit_check;

-----------------------------------------------------------
-- PROCEDURE:   Check_order_exposure      PUBLIC
-- DESCRIPTION: Calculate the exposure and compare against
--              the overall credit limits to determine
--              credit check status (PASS or FAIL).
--              The calling_action can be the following:
--              BOOKING   - Called when booking an order
--              UPDATE    - Called when order is updated
--              SHIPPING  - Called from shipping
--              PACKING
--              PICKING
--              AUTO      - Obsolete. Was called from credit check processor
--              AUTO RELEASE - Called from credit check processor to
--                             release credit hold only.
--              AUTO HOLD    - Called from credit check processor to
--                             apply credit hold only.
--              EXTERNAL  - Called from Check External Credit API
-----------------------------------------------------------
PROCEDURE Check_order_exposure
( p_customer_id	          IN	NUMBER
, p_site_use_id	          IN	NUMBER
, p_party_id              IN    NUMBER
, p_header_id	          IN	NUMBER
, p_credit_level	  IN	VARCHAR2
, p_transaction_curr_code IN    VARCHAR2
, p_transaction_amount    IN    NUMBER DEFAULT 0
, p_limit_curr_code	  IN	VARCHAR2
, p_overall_credit_limit  IN	NUMBER
, p_calling_action	  IN	VARCHAR2
, p_usage_curr	          IN	OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_holds_rel_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_default_limit_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_credit_check_rule_rec IN	OE_Credit_Check_Util.OE_credit_rules_rec_type
, p_system_parameter_rec  IN	OE_Credit_Check_Util.OE_systems_param_rec_type
, p_global_exposure_flag  IN    VARCHAR2 := 'N'
, p_credit_limit_entity_id IN   VARCHAR2
, x_total_exposure	  OUT	NOCOPY NUMBER
, x_cc_result_out	  OUT 	NOCOPY VARCHAR2
, x_error_curr_tbl	  OUT	NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
, x_return_status	  OUT	NOCOPY VARCHAR2
)
IS


l_conversion_status  OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE ;
l_customer_id         NUMBER;
l_site_id             NUMBER;
l_transaction_value   NUMBER := 0;
l_current_order_value NUMBER := 0 ;
l_order_amount        NUMBER ;
l_order_hold_amount   NUMBER ;
l_ar_amount           NUMBER ;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN

    OE_DEBUG_PUB.Add('OEXVCRHB: IN Check_order_exposure ');
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('-******-------------********---------------**********--');
    OE_DEBUG_PUB.Add('p_header_id             = '|| p_header_id );
    OE_DEBUG_PUB.Add('p_customer_id           = '|| p_customer_id );
    OE_DEBUG_PUB.Add('p_site_use_id           = '|| p_site_use_id );
    OE_DEBUG_PUB.Add('p_party_id              = ' || p_party_id );
    OE_DEBUG_PUB.Add('p_credit_limit_entity_id = '||
          p_credit_limit_entity_id );
    OE_DEBUG_PUB.Add('p_credit_level          = '|| p_credit_level );
    OE_DEBUG_PUB.Add('p_transaction_curr_code = '|| p_transaction_curr_code );
    OE_DEBUG_PUB.Add('p_limit_curr_code       = '|| p_limit_curr_code );
    OE_DEBUG_PUB.Add('p_include_all_flag      = '|| p_include_all_flag );
    OE_DEBUG_PUB.Add('p_default_limit_flag    = '|| p_default_limit_flag );
    OE_DEBUG_PUB.Add('p_global_exposure_flag  = '|| p_global_exposure_flag );
    OE_DEBUG_PUB.Add('p_transaction_amount    = '|| p_transaction_amount );
    OE_DEBUG_PUB.Add('-******------------********---------------**********--');
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add(' Precalculated flag = '||
       p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG );
    OE_DEBUG_PUB.Add(' ');
  END IF;


  x_total_exposure := 0 ;
  l_conversion_status.DELETE ;

  IF p_credit_level = 'PARTY'
  THEN
   l_customer_id := NULL ;
   l_site_id     := NULL;
  ELSIF p_credit_level = 'CUSTOMER'
  THEN
   l_customer_id := p_customer_id ;
   l_site_id     := NULL;
  ELSE
   l_customer_id := p_customer_id ;
   l_site_id     := p_site_use_id ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('err curr table count = ' || l_conversion_status.COUNT );
  END IF;

  IF NVL(l_conversion_status.COUNT,0) > 0 THEN
    x_cc_result_out := 'FAIL';

  END IF;

  IF p_overall_credit_limit IS NOT NULL
  THEN
    --
    -- If the calling action is 'EXTERNAL', then convert the transaction_amount
    -- to the limit currency.
    --
    l_current_order_value := 0 ;

    IF NVL(p_calling_action, 'BOOKING') = 'EXTERNAL' THEN

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add('OEXVCRHB GET_external_trx_amount ');
      END IF;

      OE_CREDIT_CHECK_UTIL.GET_external_trx_amount
      ( p_transaction_curr_code  => p_transaction_curr_code
      , p_transaction_amount     => p_transaction_amount
      , p_credit_check_rule_rec  => p_credit_check_rule_rec
      , p_system_parameter_rec   => p_system_parameter_rec
      , p_limit_curr_code        => p_limit_curr_code
      , x_amount                 => l_transaction_value
      , x_conversion_status      => l_conversion_status
      , x_return_status          => x_return_status
      );

      IF G_debug_flag = 'Y'
      THEN

        OE_DEBUG_PUB.Add(' after get_external_trx_amount ');
        OE_DEBUG_PUB.Add(' x_return_status ' || x_return_status );
        OE_DEBUG_PUB.Add(' l_trasaction_value = '|| l_transaction_value );
        OE_DEBUG_PUB.ADD('err curr table count = '
            || l_conversion_status.COUNT );
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF NVL(l_conversion_status.COUNT,0) > 0 THEN
      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add(' Currency conversion failure ');
      END IF;
    ELSE
      -- Get exposure only when there are no previous conversion failures.
      -- otherwise, just fail the exposure credit check with status Error.

      g_hold_exist := NULL ;

      IF NVL(p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG,'N') = 'N'
      THEN

         OE_credit_check_util.Get_order_exposure
          ( p_header_id              => p_header_id
          , p_transaction_curr_code  => p_transaction_curr_code
          , p_customer_id            => p_customer_id
          , p_site_use_id            => p_site_use_id
          , p_credit_check_rule_rec  => p_credit_check_rule_rec
          , p_system_parameter_rec   => p_system_parameter_rec
          , p_credit_level           => p_credit_level
          , p_limit_curr_code        => p_limit_curr_code
          , p_usage_curr             => p_usage_curr
          , p_include_all_flag       => p_include_all_flag
          , p_global_exposure_flag   => p_global_exposure_flag
          , p_need_exposure_details   => 'N'
          , x_total_exposure         => x_total_exposure
          , x_order_amount           => l_order_amount
          , x_order_hold_amount      => l_order_hold_amount
          , x_ar_amount              => l_ar_amount
          , x_conversion_status      => l_conversion_status
          , x_return_status          => x_return_status
         );

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.Add(' after get_order_exposure ');
           OE_DEBUG_PUB.Add(' x_return_status ' || x_return_status );
           OE_DEBUG_PUB.Add(' x_total_exposure = '|| x_total_exposure );
           OE_DEBUG_PUB.Add(' err cur tbl count = '||
            l_conversion_status.COUNT );
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSE


        OE_CREDIT_EXPOSURE_PVT.Get_Exposure
        ( p_customer_id             => l_customer_id
        , p_site_use_id             => l_site_id
        , p_party_id                => p_credit_limit_entity_id
        , p_header_id               => p_header_id
        , p_credit_check_rule_rec   => p_credit_check_rule_rec
        , p_system_parameters_rec   => p_system_parameter_rec
        , p_limit_curr_code         => p_limit_curr_code
        , p_usage_curr_tbl          => p_usage_curr
        , p_include_all_flag        => p_include_all_flag
        , p_global_exposure_flag    => p_global_exposure_flag
        , p_need_exposure_details   => 'N'
        , x_total_exposure          => x_total_exposure
        , x_return_status           => x_return_status
        , x_order_amount           => l_order_amount
        , x_order_hold_amount      => l_order_hold_amount
        , x_ar_amount              => l_ar_amount
        , x_error_curr_tbl          => l_conversion_status
        );

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add('Out of Precalculated exposure ');
          OE_DEBUG_PUB.Add('x_return_status = '|| x_return_status );
          OE_DEBUG_PUB.Add('x_total_exposure = '|| x_total_exposure );
          OE_DEBUG_PUB.Add('Error table count = '||l_conversion_status.COUNT );
        END IF;

        -- BUG Fix 2338145
        -- Get the current order amount to be included into the
        -- pre-calc exposure during booking action

        -- Bug fix 2787722
        -- The current order amount should also be included
        -- for  Non-Booking actions if the
        -- credit check rule does notInclude
        -- OM Uninvoiced Orders exposure

        -- Add current Order amount if calling action <> BOOKING
        -- and credit check rule is EXCLUDE Order amount on Hold
        -- and current Order is already on Hold during Booking

        -- bug fix 4184524 for calling action <> BOOKING:
        -- if both orders_on_hold_flag and uninvoiced_orders_flag are
        -- all 'Y', no need to consider the current order amount as they
        -- would have already been considered when running the Credit Summary
        -- concurrent program.
        -- if orders_on_hold_flag is 'N' and uninvoiced_orders_flag is 'Y',
        -- then only need to considers order amount for orders that are on hold.
        -- if orders_on_hold_flag is 'N' and uninvoiced_orders_flag is 'N',
        -- then need to consider the current order amount regardless if there is
        -- hold or not.

        l_current_order_value := 0 ;
        g_hold_exist          := NULL;

        IF NVL(p_calling_action, 'BOOKING') = 'BOOKING' AND
           NVL(OE_credit_engine_GRP.G_delayed_request, FND_API.G_FALSE ) =
             FND_API.G_FALSE
        THEN
          l_current_order_value :=
            NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0) ;
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add('Calling action=BOOKING and G_delayed_request=FALSE');
          END IF;
        ELSIF NVL(p_calling_action, 'BOOKING') <> 'EXTERNAL'
        THEN
          IF p_calling_action <> 'BOOKING'
            AND NVL(p_credit_check_rule_rec.orders_on_hold_flag,'N') = 'N'
            AND p_credit_check_rule_rec.QUICK_CR_CHECK_FLAG = 'Y'
          THEN
            -- add this IF condition for bug fix 4184524
            IF NVL(p_credit_check_rule_rec.uninvoiced_orders_flag,'N') = 'Y'
            THEN
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' Call Hold_Exists after get_exposure ');
              END IF;
              --
              IF Hold_Exists( p_header_id => p_header_id
                            , p_line_id   => NULL )
              THEN
                g_hold_exist := 'Y' ;
              ELSE
                g_hold_exist := 'N' ;
              END IF;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' after g_hold_exist => '|| g_hold_exist );
              END IF;

              IF g_hold_exist = 'Y'
              THEN
                l_current_order_value :=
                  NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0) ;
              END IF;
            -- add this ELSIF for bug fix 4184524
            ELSIF NVL(p_credit_check_rule_rec.uninvoiced_orders_flag,'N') = 'N'
            THEN
              l_current_order_value :=
                  NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0) ;
            END IF; -- end of bug fix 4184524
          END IF;
        END IF;

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add('l_current_order_value       = '|| l_current_order_value );
          OE_DEBUG_PUB.Add('x_total_exposure before add = '|| x_total_exposure );
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF; -- get exposure
      -- Add up the exposure and the current transaction amount
      x_total_exposure := NVL(l_transaction_value,0) +
                          NVL(l_current_order_value,0) +
                          NVL(x_total_exposure,0);
    END IF;
  ELSE
    x_total_exposure := 0 ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add(' UNLIMITED overall credi '
                       || p_overall_credit_limit );
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: x_total_exposure  ' || x_total_exposure,1 );
    OE_DEBUG_PUB.Add('OEXVCRHB: p_overall_credit_limit '
          || p_overall_credit_limit,1 );
    OE_DEBUG_PUB.Add(' curr conv err count ' || l_conversion_status.COUNT );
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF NVL(l_conversion_status.COUNT,0) > 0
  THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add(' Currency conversion error ');
    END IF;
    x_cc_result_out := 'FAIL';


   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
   FND_MESSAGE.Set_Token('FROM',l_conversion_status(1).usage_curr_code );
   FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
   FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate')) ;
   OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;

   fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
   FND_MESSAGE.Set_Token('FROM',l_conversion_status(1).usage_curr_code );
   FND_MESSAGE.Set_Token('TO',p_limit_curr_code );
   FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate')) ;

   OE_MSG_PUB.ADD;

   G_result_out  := 'FAIL' ;
   x_cc_result_out := 'FAIL';
   x_return_status := FND_API.G_RET_STS_ERROR;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' Exposure CC Failed  due to currency failure');
    OE_DEBUG_PUB.ADD('Return status after assigned as Error = '
          || x_return_status );
  END IF;

  ELSE
    IF NVL(x_total_exposure,0) >
                NVL(p_overall_credit_limit,x_total_exposure)
    THEN
       x_cc_result_out := 'FAIL';
    ELSE
       x_cc_result_out := 'PASS';
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' x_cc_result_out = ' || x_cc_result_out );
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Check_order_Exposure ');
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('Check_order_exposure: Other exceptions');
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Check_order_exposure'
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.Add( SUBSTR(SQLERRM,1,300) ) ;
    END IF;
END Check_order_Exposure ;

-----------------------------------------------------------
-- Check item category limits within the given site
-- If credit check failed on any category, return failure
-- and the category being checked.
-----------------------------------------------------------
PROCEDURE Check_Item_Limits
  ( p_header_rec            IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id           IN  NUMBER
  , p_site_use_id           IN  NUMBER
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN
                OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN
                OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , x_cc_hold_comment       OUT NOCOPY VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  )
IS
  l_category_sum              NUMBER := 0 ;
  l_limit_category_sum        NUMBER := 0 ; -- Sum converted to Limit currency

  l_return_status             VARCHAR2(30);
  l_include_tax_flag          VARCHAR2(1)    := 'Y';
  l_item_limits               OE_CREDIT_CHECK_UTIL.item_limits_tbl_type;
  l_lines                     OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type;
  j                           BINARY_INTEGER := 1;
  i                           BINARY_INTEGER := 1;
  l_cc_result_out             VARCHAR2(30);
  l_check_category_id         NUMBER;
  l_limit_curr                VARCHAR2(30);
  l_cc_hold_comment           VARCHAR2(2000):= NULL;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Check_Item_Limits');
  END IF;
  --
  -- Initialize return status to success
  x_return_status     := FND_API.G_RET_STS_SUCCESS;
  -- Default to Pass

  l_cc_result_out     := 'PASS';

  -- Need to use new get_item_limits api
  --

  l_include_tax_flag  := p_credit_check_rule_rec.include_tax_flag ;


  OE_CREDIT_CHECK_UTIL.Get_Item_Limit
    (  p_header_id        => p_header_rec.header_id
     , p_include_tax_flag => p_credit_check_rule_rec.include_tax_flag
     , p_site_use_id      => NULL
     , p_trx_curr_code    => p_header_rec.transactional_curr_code
     , x_item_limits_tbl  => l_item_limits
     , x_lines_tbl        => l_lines
    );

  IF l_item_limits.count = 0
  THEN
    x_cc_result_out := 'NOCHECK';
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' Count of category table = 0 ');
    END IF;
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' start category LOOP ');
      OE_DEBUG_PUB.Add(' ===================== ');
    END IF;

    FOR i in 1..l_item_limits.count
    LOOP
      l_category_sum := 0;
      -- For each item category, sum the line values

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('  ');
        OE_DEBUG_PUB.Add(' ------------------------------------ ');
        OE_DEBUG_PUB.Add(' Category id     = '
                       || l_item_limits(i).item_category_id );
        OE_DEBUG_PUB.Add(' ctg_line_amount = '
                       || l_item_limits(i).ctg_line_amount );
        OE_DEBUG_PUB.Add(' limit_curr_code = '
                       || l_item_limits(i).limit_curr_code  );
        OE_DEBUG_PUB.Add(' item_limit      = '
                       || l_item_limits(i).item_limit );
        OE_DEBUG_PUB.Add(' grouping       = '
                       || l_item_limits(i).grouping_id  );
      END IF;

      l_category_sum := l_item_limits(i).ctg_line_amount ;

      -- compare sum with category limit
      -- what to do when there is not limit

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' l_category_sum = ' || l_category_sum );
        OE_DEBUG_PUB.Add(' GL_CURRENCY = '||
           OE_Credit_Engine_GRP.GL_currency );

        OE_DEBUG_PUB.Add(' ------------------------------------ ');
        OE_DEBUG_PUB.Add('   ');
      END IF;

      l_check_category_id := l_item_limits(i).item_category_id ;
      l_limit_curr        := l_item_limits(i).limit_curr_code ;
      l_limit_category_sum  :=
       OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
       ( p_amount	            => l_category_sum
       , p_transactional_currency   => p_header_rec.transactional_curr_code
       , p_limit_currency	      => l_item_limits(i).limit_curr_code
       , p_functional_currency	=> OE_Credit_Engine_GRP.GL_currency
       , p_conversion_date	      => SYSDATE
       , p_conversion_type          => p_credit_check_rule_rec.conversion_type
       ) ;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' l_limit_category_sum = ' || l_limit_category_sum );
        OE_DEBUG_PUB.Add(' item_limit = ' || l_item_limits(i).item_limit );
      END IF;

      IF l_limit_category_sum > l_item_limits(i).item_limit
      THEN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add
          ('Fails item category ID: '|| l_item_limits(i).item_category_id);
        END IF;
        Apply_Order_CC_Hold
           ( p_header_id            => p_header_rec.header_id
           , p_order_number         => p_header_rec.order_number
           , p_calling_action       => p_calling_action
           , p_cc_limit_used        => 'ITEM'
           , p_cc_profile_used      => 'CATEGORY'
           , p_item_category_id     => l_item_limits(i).item_category_id
           , p_system_parameter_rec => p_system_parameter_rec
           , p_credit_check_rule_rec=> p_credit_check_rule_rec
           , x_cc_hold_comment      => l_cc_hold_comment
           , x_cc_result_out        => l_cc_result_out
           );
        EXIT;  -- stop checking item limits
      END IF;
      l_limit_category_sum := 0 ;
      l_category_sum       := 0 ;
      l_limit_curr         := NULL ;

    END LOOP; -- category loop
    x_cc_hold_comment := l_cc_hold_comment;
    x_cc_result_out   := l_cc_result_out;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('x_cc_result_out = '|| x_cc_result_out );
    OE_DEBUG_PUB.ADD('OEXVCRHB: Out Check_Item_Limit');
  END IF;

EXCEPTION
   WHEN  GL_CURRENCY_API.NO_RATE
   THEN
   BEGIN
     IF G_debug_flag = 'Y' THEN
       OE_DEBUG_PUB.Add('EXCEPTION: GL_CURRENCY_API.NO_RATE ');
       OE_DEBUG_PUB.Add('Apply_Order_CC_Hold for Item category');
       OE_DEBUG_PUB.Add('currency = '|| p_header_rec.transactional_curr_code );
       OE_DEBUG_PUB.Add('checking category = '|| l_check_category_id );
     END IF;

     fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
     FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
     FND_MESSAGE.Set_Token('TO',l_limit_curr );
     FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate')) ;
     OE_Credit_Engine_GRP.G_currency_error_msg :=
      SUBSTR(FND_MESSAGE.GET,1,1000) ;

     fnd_message.set_name('ONT', 'OE_CC_CONVERSION_ERORR');
     FND_MESSAGE.Set_Token('FROM',p_header_rec.transactional_curr_code);
     FND_MESSAGE.Set_Token('TO',l_limit_curr );
     FND_MESSAGE.Set_Token('CONV',
               NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate')) ;

     OE_MSG_PUB.ADD ;

     G_result_out  := 'FAIL' ;
     x_cc_result_out := 'FAIL';
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF G_debug_flag = 'Y' THEN
       OE_DEBUG_PUB.Add(' Item CTG CC Failed  due to currency failure');
       OE_DEBUG_PUB.ADD('Return status after assigned as Error = '
          || x_return_status );
     END IF;
   END;

   WHEN others THEN
     IF G_debug_flag = 'Y' THEN
       OE_DEBUG_PUB.Add('Check_Item_Limit: Other exceptions');
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Check_Item_Limits'
       );
     END IF;
     IF G_debug_flag = 'Y' THEN
       OE_DEBUG_PUB.Add( SUBSTR(SQLERRM,1,300),1 ) ;
     END IF;
END Check_Item_Limits;

------------------------------------------------------------
-- PROCEDURE:   Check_Other_Credit_Limits            PRIVATE
-- DESCRIPTION: Get additional credit limit information and
--              perform credit check on customer/site/default
--              credit limits specified in the customer/site
--              or default credit profiles.
------------------------------------------------------------
PROCEDURE Check_Other_Credit_Limits
  ( p_header_rec            IN  OE_ORDER_PUB.header_rec_type
  , p_customer_id           IN  NUMBER
  , p_site_use_id           IN  NUMBER
  , p_calling_action        IN  VARCHAR2 := 'BOOKING'
  , p_credit_check_rule_rec IN
                    OE_Credit_Check_Util.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN
                    OE_Credit_Check_Util.OE_systems_param_rec_type
  , p_transaction_amount    IN NUMBER
  , p_party_id              IN NUMBER ---------------------new (FPI)
  , x_credit_level         OUT NOCOPY VARCHAR2
  , x_check_exposure_mode  OUT NOCOPY VARCHAR2
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  , x_cc_hold_comment      OUT NOCOPY VARCHAR2
  , x_return_status        OUT NOCOPY VARCHAR2
  , x_global_exposure_flag OUT NOCOPY VARCHAR2
  )
IS

  l_check_order 	    VARCHAR2(1);
  l_default_limit_flag      VARCHAR2(1);
  l_limit_curr_code 	    VARCHAR2(30);
  l_overall_credit_limit    NUMBER;
  l_trx_credit_limit        NUMBER;
  l_usage_curr	            OE_CREDIT_CHECK_UTIL.curr_tbl_type;
  l_include_all_flag	    VARCHAR2(1);
  l_prev_customer_id        NUMBER;
  l_customer_result_out     VARCHAR2(30) := NULL;
  l_total_exposure          NUMBER;
  l_orders                  NUMBER;
  l_orders_on_hold          NUMBER;
  l_payments_overdue        NUMBER;
  l_payments_at_risk        NUMBER;
  l_error_curr_tbl	    OE_CREDIT_CHECK_UTIL. curr_tbl_type ;
  l_cc_profile_used         VARCHAR2(30);
  l_cc_limit_used           VARCHAR2(80);
  l_cc_result_out           VARCHAR2(30);
  l_request_id              NUMBER;     -----------------------new (FPI)
  l_msg_count               NUMBER; -----------------------new (FPI)
  l_msg_data	            VARCHAR2(2000);-----------------------new (FPI)
  l_party_id                NUMBER;     -----------------------new (FPI)
  l_customer_id             NUMBER;     -----------------------new (FPI)
  l_site_use_id             NUMBER;     -----------------------new (FPI)
  l_source_org_id           NUMBER;     -----------------------new (FPI)
  l_source_user_id          NUMBER;     -----------------------new (FPI)
  l_source_resp_id          NUMBER;     -----------------------new (FPI)
  l_source_appln_id         NUMBER;     -----------------------new (FPI)
  l_source_security_group_id  NUMBER;     -----------------------new (FPI)

  l_credit_limit_entity_id  NUMBER ;
  l_support_party           VARCHAR2(1) := 'N' ;
  l_cc_trx_result_out           VARCHAR2(30);
  l_cc_duedate_result_out       VARCHAR2(30);
  l_cc_overall_result_out       VARCHAR2(30);
  ----Bug 4320650
  l_unrounded_exposure          NUMBER;
  --bug 5907331
  l_review_party_id       NUMBER;

  --ER8880886 Start
  --declaring the record type to send credit check failure reason to OCM
  l_hold_reason_rec AR_CMGT_CREDIT_REQUEST_API.hold_reason_rec_type
  	:= AR_CMGT_CREDIT_REQUEST_API.hold_reason_rec_type(NULL);
  i_hld_rec NUMBER := 0;
  --ER8880886 End

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Check_Other_Credit Limits',1);
  END IF;

  --
  -- Set the default behavior to pass credit check
  --
  x_cc_result_out := 'PASS';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_global_exposure_flag := 'N' ;

  l_cc_result_out := 'PASS';
  l_cc_trx_result_out := 'PASS';
  l_cc_duedate_result_out := 'PASS';
  l_cc_overall_result_out := 'PASS';

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('Calling action = '|| p_calling_action);
    OE_DEBUG_PUB.Add('p_customer_id  = '|| p_customer_id);
    OE_DEBUG_PUB.Add('p_site_use_id  = '|| p_site_use_id );
    OE_DEBUG_PUB.Add('p_party_id     => '|| p_party_id );
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('Calling Validate_other_credit_check');
  END IF;
  --
  -----------------------------------------------------------
  -- Check if order site use needs credit check. Also       |
  -- determine if credit check should be at customer level  |
  -- or the site level and the credit limits at that level. |
  -- The information returned will be used for credit check.|
  -----------------------------------------------------------
  --
  OE_credit_check_order_PVT.Validate_other_credit_check
          (   p_header_rec            => p_header_rec
          ,   p_customer_id           => p_customer_id
          ,   p_site_use_id           => p_site_use_id
          ,   p_calling_action        => p_calling_action
          ,   p_credit_check_rule_rec => p_credit_check_rule_rec
          ,   p_party_id              => p_party_id
          ,   x_check_order_flag      => l_check_order
          ,   x_credit_check_lvl_out  => x_credit_level
          ,   x_default_limit_flag    => l_default_limit_flag
          ,   x_limit_curr_code       => l_limit_curr_code
          ,   x_overall_credit_limit  => l_overall_credit_limit
          ,   x_trx_credit_limit      => l_trx_credit_limit
          ,   x_usage_curr            => l_usage_curr
          ,   x_include_all_flag      => l_include_all_flag
          ,   x_return_status         => x_return_status
          ,   x_global_exposure_flag  => x_global_exposure_flag
          ,   x_credit_limit_entity_id => l_credit_limit_entity_id
          );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --

  -----------------------------------------------------------
  -- Perform credit checks for due date, transaction limits,
  -- and overall limits.
  -----------------------------------------------------------
  IF l_check_order = 'Y' THEN
    --
    -- Determine the profile used
    --
    IF l_default_limit_flag = 'Y' THEN
      l_cc_profile_used := 'DEFAULT';
    ELSE
      l_cc_profile_used := x_credit_level ;
    END IF;
    --
    ----------------------------------------------------+
    -- order site use is subject to credit check:       |
    ----------------------------------------------------|
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('Calling Check Transaction Limit procedure');
    END IF;

    OE_credit_check_order_PVT.Check_Trx_Limit
        (   p_header_rec            => p_header_rec
        ,   p_customer_id           => p_customer_id
        ,   p_site_use_id           => p_site_use_id
        ,   p_credit_level          => x_credit_level
        ,   p_credit_check_rule_rec => p_credit_check_rule_rec
        ,   p_system_parameter_rec  => p_system_parameter_rec
        ,   p_limit_curr_code       => l_limit_curr_code
        ,   p_trx_credit_limit      => l_trx_credit_limit
        ,   p_calling_action        => p_calling_action
        ,   p_transaction_amount    => p_transaction_amount
        ,   x_cc_result_out         => l_cc_trx_result_out
        ,   x_return_status         => x_return_status
        ,   x_conversion_status     => l_error_curr_tbl
        );

      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add('Check_Trx_Limit: Result Out    ='||l_cc_trx_result_out);
        OE_DEBUG_PUB.Add('Check_Trx_Limit: Return Status ='|| x_return_status );
      END IF;

      -- bug 4002820
      IF l_cc_trx_result_out = 'FAIL' THEN
        -- only overwrite the l_cc_result_out if the current checking fails
        -- to make sure the l_cc_result_out is FAIL if any of the checkings fails.
        l_cc_result_out := l_cc_trx_result_out;
        l_cc_limit_used := 'TRX';

	--ER8880886
	i_hld_rec := i_hld_rec +1;
	l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_ORDER';
        --ER8880886

      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      g_order := OE_CREDIT_CHECK_UTIL.g_current_order_value ;


    -- IF l_cc_result_out = 'PASS' THEN
    -- Changed IF condition to fix bug 4002820, need to do overall
    -- limit checking even order limit checking failed when
    -- Credit Management is installed and used.

    IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
       THEN
       OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
       AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
    END IF;

    IF l_cc_trx_result_out = 'PASS'
       OR OE_CREDIT_CHECK_UTIL.G_crmgmt_installed = TRUE THEN
      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add('Calling Check Past Due Invoice procedure');
      END IF;

      OE_credit_check_order_PVT.Chk_Past_Due_Invoice
      (  p_customer_id           => p_customer_id
      ,  p_site_use_id           => p_site_use_id
      ,  p_party_id              => l_credit_limit_entity_id
      ,  p_credit_check_rule_rec => p_credit_check_rule_rec
      ,  p_system_parameter_rec  => p_system_parameter_rec
      ,  p_credit_level          => x_credit_level
      ,  p_usage_curr            => l_usage_curr
      ,  p_include_all_flag      => l_include_all_flag
      ,  p_global_exposure_flag  => x_global_exposure_flag
      ,  x_cc_result_out         => l_cc_duedate_result_out
      ,  x_return_status         => x_return_status
      );

      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add('Chk_Duedate_Limit: Result Out    ='|| l_cc_duedate_result_out );
        OE_DEBUG_PUB.Add('Chk_Duedate_Limit: Return Status ='|| x_return_status );
      END IF;

      -- bug 4002820
      IF l_cc_duedate_result_out = 'FAIL' THEN
         l_cc_result_out := l_cc_duedate_result_out;
         IF l_cc_limit_used IS NOT NULL THEN
             -- in order to disply useful message if two or more checkings fail.
             -- l_cc_limit_used := 'Order limit exceeded' || ', overdue invoices found';
             -- bug 4153299
             l_cc_limit_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'ORDER') || ', '
                             || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERDUE');

                  --ER8880886
                  i_hld_rec := i_hld_rec +1;
	          l_hold_reason_rec.extend;
	          l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERDUE';
        	  --ER8880886

         ELSE
           l_cc_limit_used := 'DUEDATE';

	   --ER8880886
	   i_hld_rec := i_hld_rec +1;
	   l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERDUE';
	   --ER8880886

         END IF;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- IF l_cc_result_out = 'PASS' THEN
      -- Changed IF condition to fix bug 4002813, need to do overall
      -- limit checking even order limit checking failed when
      -- Credit Management is installed and used.
      IF l_cc_duedate_result_out = 'PASS'
         OR OE_CREDIT_CHECK_UTIL.G_crmgmt_installed = TRUE THEN
        ----------------------------------------------------+
        -- order is subject to credit check:                |
        ----------------------------------------------------|
        -- check 1: item limit             <-- passed/failed|
        -- check 2: max-past-due-inv limit <-- passed       |
        -- check 3: trx limit              <-- passed       |
        -- check 4: overall limit          <-- in progress  |
        ----------------------------------------------------+

        x_check_exposure_mode := 'INLINE';

        IF G_debug_flag = 'Y' THEN
          OE_DEBUG_PUB.Add('x_check_exposure_mode = '|| x_check_exposure_mode );
          OE_DEBUG_PUB.Add('Calling Check order Exposure procedure');
        END IF;

        OE_credit_check_order_PVT.Check_order_exposure
            ( p_customer_id	        => p_customer_id
            , p_site_use_id	        => p_site_use_id
            , p_party_id                => p_party_id
            , p_header_id	        => p_header_rec.header_id
            , p_credit_level	        => x_credit_level
            , p_transaction_curr_code   => p_header_rec.transactional_curr_code
            , p_transaction_amount      => p_transaction_amount
            , p_limit_curr_code	        => l_limit_curr_code
            , p_overall_credit_limit    => l_overall_credit_limit
            , p_calling_action	        => p_calling_action
            , p_usage_curr	        => l_usage_curr
            , p_include_all_flag        => l_include_all_flag
            , p_holds_rel_flag	        => 'N'
            , p_default_limit_flag      => l_default_limit_flag
            , p_credit_check_rule_rec	=> p_credit_check_rule_rec
            , p_system_parameter_rec	=> p_system_parameter_rec
            , p_global_exposure_flag    => x_global_exposure_flag
            , p_credit_limit_entity_id  => l_credit_limit_entity_id
            , x_total_exposure	        => l_total_exposure
            , x_cc_result_out	        => l_cc_overall_result_out
            , x_error_curr_tbl	        => l_error_curr_tbl
            , x_return_status	        => x_return_status
            );

        IF G_debug_flag = 'Y' THEN
          OE_DEBUG_PUB.Add('After call to Check_order_exposure ');
          OE_DEBUG_PUB.Add('l_cc_result_out = ' || l_cc_result_out );
          OE_DEBUG_PUB.Add('total exposure  = ' || l_total_exposure );
          OE_DEBUG_PUB.Add('x_return_status = ' || x_return_status  );
          OE_DEBUG_PUB.Add(' Credit Rule Id = '
                       ||to_char(p_credit_check_rule_rec.credit_check_rule_id));
        END IF;
    	  --Bug 4320650
	  l_unrounded_exposure := l_total_exposure;

	  OE_CREDIT_CHECK_UTIL.Rounded_Amount(l_limit_curr_code,
					      l_unrounded_exposure,
					      l_total_exposure);

         -- bug 4002820
        IF l_cc_overall_result_out = 'FAIL' THEN
           l_cc_result_out := l_cc_overall_result_out;
           -- in order to disply useful message if two or more checkings fail.
           IF INSTR(l_cc_limit_used, ',') >0  THEN
             -- l_cc_limit_used := l_cc_limit_used || ', overall limit exceeded';
             --bug 4153299
             l_cc_limit_used := l_cc_limit_used || ', '
                       || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');

              --ER8880886
              i_hld_rec := i_hld_rec +1;
              l_hold_reason_rec.extend;
              l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
              --ER8880886

           ELSIF l_cc_limit_used IS NOT NULL THEN
           	--ER8880886
            	i_hld_rec := i_hld_rec +1;
            	l_hold_reason_rec.extend;
            	l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
           	--ER8880886
             IF l_cc_trx_result_out = 'FAIL' THEN
                -- l_cc_limit_used := 'Order limit, overall limit exceeded';
                -- bug 4153299
                l_cc_limit_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'ORDER') || ', '
               || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');

             ELSIF l_cc_duedate_result_out = 'FAIL' THEN
                -- l_cc_limit_used := 'Overdue invoices found'||', overall limit exceeded';
                 -- bug 4153299
                l_cc_limit_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERDUE') || ', '
                || OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_LIMIT', 'OVERALL');


             END IF;
           ELSE
             l_cc_limit_used := 'OVERALL';

             --ER8880886
             i_hld_rec := i_hld_rec +1;
             l_hold_reason_rec(i_hld_rec) := 'OE_CC_HOLD_OVERALL';
             --ER8880886

           END IF;
        END IF;

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- l_cc_limit_used := 'OVERALL';

      ELSE
        l_cc_limit_used := 'DUEDATE';
      END IF;
    ELSE
        l_cc_limit_used := 'TRX';
    END IF;
  ELSE
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('No credit check required');
    END IF;
    l_cc_result_out := 'NOCHECK';
  END IF;
  --
  -- Update database table with hold information
  --

  --- BUG 2505245
  --- set the result to NO check if trx credit check amt = 0
  ---

  IF G_debug_flag = 'Y'
  THEN

    OE_DEBUG_PUB.Add(' OEXVCRHB: l_cc_limit_used ==> '|| l_cc_limit_used );
    OE_DEBUG_PUB.Add(' before l_cc_result_out => '|| l_cc_result_out );

    OE_DEBUG_PUB.add(' g_current_order_value => '||
               OE_CREDIT_CHECK_UTIL.g_current_order_value );

    OE_DEBUG_PUB.Add('before g_order      ==> ' || g_order );
  END IF;

    -- IF NVL(g_order,0) = 0
    IF (OE_OE_FORM_CANCEL_LINE.g_ord_lvl_can)  --bug 3944617
    THEN
     l_cc_result_out := 'NOCHECK';
    END IF;
   -- g_order := NULL ;
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' AND --bug#5887290
       OE_Sys_Parameters.Value('CREDIT_HOLD_ZERO_VALUE_ORDER') = 'N'
    THEN
        IF NVL(g_order,0) = 0 THEN
         l_cc_result_out := 'NOCHECK';
        END IF;
    END IF;


  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('after l_cc_result_out => '|| l_cc_result_out );
    OE_DEBUG_PUB.Add('after g_order      ==> ' || g_order );
  END IF;

  IF l_cc_result_out = 'FAIL' THEN
    IF NVL(p_calling_action,'BOOKING') <> 'EXTERNAL' THEN
      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add('Calling Apply_Order_CC_Hold ');
      END IF;

        -- bug 4153299
      -- 6616741 l_cc_profile_used := OE_CREDIT_CHECK_UTIL.Get_CC_Lookup_Meaning('OE_CC_PROFILE', l_cc_profile_used);

      Apply_Order_CC_Hold
       (  p_header_id            => p_header_rec.header_id
        , p_order_number         => p_header_rec.order_number
        , p_calling_action       => p_calling_action
        , p_cc_limit_used        => l_cc_limit_used
        , p_cc_profile_used      => l_cc_profile_used
        , p_item_category_id     => NULL
        , p_system_parameter_rec => p_system_parameter_rec
        , p_credit_check_rule_rec=> p_credit_check_rule_rec
        , x_cc_hold_comment      => x_cc_hold_comment
        , x_cc_result_out        => l_cc_result_out
       );

      ---------------------- Start Credit Review --------------

       IF l_cc_result_out in ('FAIL_HOLD','FAIL_NONE','FAIL')
       THEN
         -- changed IF condition for bug 4002820
         -- IF l_cc_limit_used = 'OVERALL'
         --IF l_cc_overall_result_out = 'FAIL' --commented for ER8880886
         --THEN 			       --commented for ER8880886
           IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
           THEN
             OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
               AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
           END IF;

           IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed = TRUE
           THEN
             --bug 5907331
             l_review_party_id := p_party_id;
             ------check if the credit check level is PARTY, CUSTOMER or SITE
             IF x_credit_level ='PARTY'
             THEN
               l_customer_id:=NULL;
               l_site_use_id:=NULL;
                --bug 5907331
                IF p_party_id <> nvl(l_credit_limit_entity_id,p_party_id) THEN
                   l_review_party_id := l_credit_limit_entity_id;
                END IF;

             ELSIF x_credit_level ='CUSTOMER'
             THEN
               l_customer_id:=p_customer_id;
               l_site_use_id:=NULL;
             ELSIF x_credit_level ='SITE'
             THEN
               l_customer_id:=p_customer_id;
               l_site_use_id:=p_site_use_id;
             END IF;

             -------------get profile values:
 	     l_source_org_id  := p_header_rec.org_id; /* MOAC ORG_ID CHANGE */
             -- l_source_org_id  := FND_PROFILE.VALUE('ORG_ID');
             l_source_user_id := FND_PROFILE.VALUE ('USER_ID');
             l_source_resp_id := FND_PROFILE.VALUE ('RESP_ID');
             l_source_appln_id  := FND_PROFILE.VALUE ('RESP_APPL_ID');
             l_source_security_group_id
                     := FND_PROFILE.VALUE('SECURITY_GROUP_ID');

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.Add('Calling Create_credit_request,
                              credit check level= '||x_credit_level);

             OE_DEBUG_PUB.Add('Parameters: ');
             OE_DEBUG_PUB.Add('-------------------------------------------');
             OE_DEBUG_PUB.Add('p_requestor_id= '||TO_CHAR(fnd_global.employee_id));
             OE_DEBUG_PUB.Add('p_review_type= ORDER_HOLD');
             OE_DEBUG_PUB.Add('p_credit_classification= NULL');
             OE_DEBUG_PUB.Add('p_requested_amount= '||TO_CHAR(l_total_exposure ));
             OE_DEBUG_PUB.Add('p_requested_currency= '||l_limit_curr_code);
             OE_DEBUG_PUB.Add('p_trx_amount= '||TO_CHAR(g_order));
             OE_DEBUG_PUB.Add('p_trx_currency= '||p_header_rec.transactional_curr_code );
             OE_DEBUG_PUB.Add('p_credit_type = TRADE' );
             OE_DEBUG_PUB.Add('p_term_length = NULL' );
             OE_DEBUG_PUB.Add('p_credit_check_rule_id= '||
                    TO_CHAR(p_credit_check_rule_rec.credit_check_rule_id));
             OE_DEBUG_PUB.Add('p_credit_request_status = SUBMIT');
             OE_DEBUG_PUB.Add('p_party_id= '||TO_CHAR(p_party_id));
             OE_DEBUG_PUB.Add('p_cust_account_id= '||TO_CHAR(l_customer_id));
             OE_DEBUG_PUB.Add('p_cust_acct_site_id = NULL');
             OE_DEBUG_PUB.Add('p_site_use_id= '||TO_CHAR(l_site_use_id));
             OE_DEBUG_PUB.Add('p_contact_party_id = NULL');
             OE_DEBUG_PUB.Add('p_notes = NULL');
             OE_DEBUG_PUB.Add('p_source_org_id= '||TO_CHAR(l_source_org_id));
             OE_DEBUG_PUB.Add('p_source_user_id= '||TO_CHAR(l_source_user_id));
             OE_DEBUG_PUB.Add('p_source_resp_id= '||TO_CHAR(l_source_resp_id));
             OE_DEBUG_PUB.Add('p_source_appln_id= '||TO_CHAR(l_source_appln_id));
             OE_DEBUG_PUB.Add('p_source_security_group_id= '||TO_CHAR(l_source_security_group_id));
             OE_DEBUG_PUB.Add('p_source_name  = OM');
             OE_DEBUG_PUB.Add('p_source_column1 = header_id= '||
                  TO_CHAR(p_header_rec.header_id));
             OE_DEBUG_PUB.Add('p_source_column2 = order_number= '||
                  TO_CHAR(p_header_rec.order_number));
             OE_DEBUG_PUB.Add('p_source_column3= ORDER');

           END IF;
           ----------------Submit Credit Review--------------------
           AR_CMGT_CREDIT_REQUEST_API.Create_credit_request
           ( p_api_version           => 1.0
           , p_init_msg_list         => FND_API.G_FALSE
           , p_commit                => FND_API.G_FALSE
           , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
           , x_return_status         => x_return_status
           , x_msg_count             => l_msg_count
           , x_msg_data              => l_msg_data
           , p_application_number    => NULL
           , p_application_date      => SYSDATE
           , p_requestor_type        => NULL
           , p_requestor_id          => fnd_global.employee_id
           , p_review_type           => 'ORDER_HOLD'
           , p_credit_classification => NULL
           , p_requested_amount      => l_total_exposure
           , p_requested_currency    => l_limit_curr_code
           , p_trx_amount            => g_order
           , p_trx_currency          => p_header_rec.transactional_curr_code
           , p_credit_type           => 'TRADE'
           , p_term_length           => NULL  --the unit is no of months
           , p_credit_check_rule_id  =>
                   p_credit_check_rule_rec.credit_check_rule_id
           , p_credit_request_status => 'SUBMIT'
           , p_party_id              => l_review_party_id --bug 5907331
           , p_cust_account_id       => l_customer_id
           , p_cust_acct_site_id     => NULL
           , p_site_use_id           => l_site_use_id
           , p_contact_party_id      => NULL --party_id of the pseudo party
           , p_notes                 => NULL  --contact relationship.
           , p_source_org_id         => l_source_org_id
           , p_source_user_id        => l_source_user_id
           , p_source_resp_id        => l_source_resp_id
           , p_source_appln_id       => l_source_appln_id
           , p_source_security_group_id => l_source_security_group_id
           , p_source_name           => 'OM'
           , p_source_column1        => p_header_rec.header_id
           , p_source_column2        => p_header_rec.order_number
           , p_source_column3        => 'ORDER'
           , p_credit_request_id     => l_request_id
           , p_hold_reason_rec       => l_hold_reason_rec --ER8880886
           );

           IF x_return_status='S'
           THEN

             FND_MESSAGE.Set_Name('ONT','OE_CC_CMGT_REVIEW');
             FND_MESSAGE.Set_Token('REQUEST_ID',l_request_id);
             OE_MSG_PUB.Add;

           END IF;

           IF G_debug_flag = 'Y'
           THEN
             IF x_return_status='S'
             THEN

               OE_DEBUG_PUB.Add('Credit review submitted, request_id= '
                     ||TO_CHAR(l_request_id));
             ELSE
               OE_DEBUG_PUB.Add('Credit review has not been submitted');
             END IF;
           END IF;

           OE_DEBUG_PUB.Add('l_request_id= '||TO_CHAR(l_request_id));
           OE_DEBUG_PUB.Add('x_return_status= '||x_return_status);
           OE_DEBUG_PUB.Add('l_msg_count= '||TO_CHAR(l_msg_count));
           OE_DEBUG_PUB.Add('l_msg_data= '||l_msg_data);


         END IF;

        --END IF;         --commented for ER8880886

      END IF;
      --------------------------------- End Credit review ---------

    ELSE
      -- Create hold message for return to calling module.
      -- Also set the G_result_out variable to FAIL.
      G_result_out := 'FAIL';
      Write_Order_Hold_Msg
        (
           p_calling_action      => p_calling_action
         , p_cc_limit_used       => l_cc_limit_used
         , p_cc_profile_used     => l_cc_profile_used
         , p_order_number        => NULL
         , x_comment             => x_cc_hold_comment
        );
    END IF;
  END IF;
  x_cc_result_out   := l_cc_result_out;
  -- If no need to check order, then the non-item holds
  -- should be released.
  IF NVL(l_check_order,'N') = 'N' THEN
    x_check_exposure_mode := 'NOCHECK';
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('x_check_exposure_mode = ' || x_check_exposure_mode );
    OE_DEBUG_PUB.Add('x_cc_result_out = '|| x_cc_result_out );
    OE_DEBUG_PUB.Add('OEXVCRHB: Out Check_Other_Credit Limits');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
 	 OE_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME, 'Check_Other_Credit_Limits');
    END IF;
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add( SUBSTR(SQLERRM,1,300),1 ) ;
    END IF;
END Check_Other_Credit_Limits;

------------------------------------------------+
-- Mainline Function that will read an Order    |
-- Header and Determine if should be checked,   |
-- calculates total exposure, find credit       |
-- and determine result for calling function.   |
-------------------------------------------------

PROCEDURE Check_order_credit
  ( p_header_rec            IN  OE_ORDER_PUB.Header_Rec_Type
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , p_transaction_amount    IN  NUMBER DEFAULT NULL
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_cc_hold_comment       OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  ) IS

  l_credit_level            VARCHAR2(30); -- limits at cust or site level
  l_check_order             VARCHAR2(1);  -- if Order requires credit check
  l_check_exposure_mode     VARCHAR2(20);
  l_cc_profile_used         VARCHAR2(30) := NULL;
  l_cc_limit_used           VARCHAR2(30) := NULL;
  l_msg_count		    NUMBER;
  l_msg_data	            VARCHAR2(2000);
  l_release_order_hold      VARCHAR2(1) := 'Y';
  l_cc_result_out           VARCHAR2(30);
  l_own_customer_id         NUMBER;
  l_order_site_use_id       NUMBER;
  l_check_order_eligible    VARCHAR2(1);
  l_global_exposure_flag    VARCHAR2(1);
  l_party_id                NUMBER;          ---------------------new (FPI)
  l_cc_hold_comment         VARCHAR2(2000) := NULL;

BEGIN
  IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.Add('OEXVCRHB: In Check_order_credit API');
  END IF;
  --
  -- Set the default behavior to pass credit check
  --
  x_cc_result_out := 'NOCHECK';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  G_result_out    := 'PASS' ;
  l_global_exposure_flag := 'N' ;
  g_hold_exist    := NULL ;
  OE_Credit_Engine_GRP.G_currency_error_msg := NULL ;
  IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.Add( 'Initial start G_result_out = '|| G_result_out );
    OE_DEBUG_PUB.Add( 'Initial start G_currency_error_msg = '||
      substr(OE_Credit_Engine_GRP.G_currency_error_msg,1,10)) ;
    OE_DEBUG_PUB.Add('  ');
    OE_DEBUG_PUB.Add(' -------------------------------------------- ');
    OE_DEBUG_PUB.Add(' Calling action       = '|| p_calling_action);
    OE_DEBUG_PUB.Add(' Transaction Amount   = '|| p_transaction_amount);
    OE_DEBUG_PUB.Add(' Header ID            = '|| p_header_rec.header_id );
    OE_DEBUG_PUB.Add(' Order Number         = '|| p_header_rec.order_number );
    OE_DEBUG_PUB.Add(' Order currency       = '
                      || p_header_rec.transactional_curr_code );
    OE_DEBUG_PUB.Add(' sold_to_org          = '
                      || p_header_rec.sold_to_org_id );
    OE_DEBUG_PUB.Add(' Inv_to_org           = '
                     || p_header_rec.invoice_to_org_id );
    OE_DEBUG_PUB.Add(' Credit check level   = '
                 || p_credit_check_rule_rec.credit_check_level_code );
    OE_DEBUG_PUB.Add(' Conversion Type      = '
                  || p_credit_check_rule_rec.conversion_type );
    OE_DEBUG_PUB.Add(' User Conversion Type      = '
                  || p_credit_check_rule_rec.user_conversion_type );
    OE_DEBUG_PUB.Add(' Credit check rule id = '
                  || p_credit_check_rule_rec.credit_check_rule_id );
    OE_DEBUG_PUB.Add(' CHECK_ITEM_CATEGORIES_FLAG = '
                  || p_credit_check_rule_rec.CHECK_ITEM_CATEGORIES_FLAG );
    OE_DEBUG_PUB.Add(' SEND_HOLD_NOTIFICATIONS_FLAG = '
                  || p_credit_check_rule_rec.SEND_HOLD_NOTIFICATIONS_FLAG );
    OE_DEBUG_PUB.Add('g_hold_exist => '|| g_hold_exist );
    OE_DEBUG_PUB.Add(' -------------------------------------------- ');
    OE_DEBUG_PUB.Add('  ');
  END IF;
  --
  -- Check payment term only if the calling action is not EXTERNAL
  --
  IF NVL(p_calling_action,'BOOKING') <> 'EXTERNAL' THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add(' Call check_credit_check_flags ');
    END IF;
    l_check_order_eligible := check_credit_check_flags
                 ( p_header_id => p_header_rec.header_id );
  ELSE
    l_check_order_eligible := 'Y';
  END IF;

  IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.Add(' l_check_order_eligible  = '|| l_check_order_eligible );
  END IF;

  IF l_check_order_eligible = 'Y'
  THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('OEXVCRHB: Payment term YES CC checked , continue CC ');
    END IF;

    SELECT  /* MOAC_SQL_CHANGE */ cas.cust_account_id
            , su.site_use_id
            , ca.party_id      --------------------new (FPI)
    INTO    l_own_customer_id
          , l_order_site_use_id
          , l_party_id            -------------------new (FPI)
    FROM    HZ_CUST_SITE_USES_ALL su
          , HZ_CUST_ACCT_SITES_all cas
          , hz_cust_accounts_all ca    --------------new (FPI)
    WHERE   su.site_use_id = p_header_rec.invoice_to_org_id
           AND cas.CUST_ACCT_SITE_ID  = su.CUST_ACCT_SITE_ID
           AND cas.cust_account_id=ca.cust_account_id; ---------new (FPI)

    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('l_own_customer_id '|| l_own_customer_id );
      OE_DEBUG_PUB.Add('l_order_site_use_id '|| l_order_site_use_id);
    END IF;

     ---------------------------------------------------+
    -- order  is subject to credit check:      |
    ---------------------------------------------------|
    -- check 1: item limit             <-- in progress |
    -- check 2: max-past-due-inv limit                 |
    -- check 3: trx limit                              |
    -- check 4: overall limit                          |
    ---------------------------------------------------+

    IF p_credit_check_rule_rec.CHECK_ITEM_CATEGORIES_FLAG = 'Y'
    THEN
      Check_Item_Limits
        ( p_header_rec            => p_header_rec
         , p_customer_id           => l_own_customer_id
         , p_site_use_id           => l_order_site_use_id
         , p_calling_action        => p_calling_action
         , p_credit_check_rule_rec => p_credit_check_rule_rec
         , p_system_parameter_rec  => p_system_parameter_rec
         , x_cc_hold_comment       => x_cc_hold_comment
         , x_cc_result_out         => l_cc_result_out
         , x_return_status         => x_return_status
         );
      IF G_debug_flag = 'Y' THEN
        OE_DEBUG_PUB.Add('Check_Item_Limit: Result Out    = '
                             || l_cc_result_out );
        OE_DEBUG_PUB.Add('Check_Item_Limit: Return Status = '
                             || x_return_status );
      END IF;
    ELSE
       l_cc_result_out := 'PASS' ;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       IF G_debug_flag = 'Y' THEN
         OE_DEBUG_PUB.Add(' No Item category credit checking, flag OFF ');
         OE_DEBUG_PUB.Add('l_cc_result_out   = '
                           || l_cc_result_out );
         OE_DEBUG_PUB.Add('x_return_status = '
                           || x_return_status );
       END IF;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
    -- Apply the database hold and Exit the bill-to site loop if
    -- credit hold level is ORDER and the order failed credit check.
    --
    IF  l_cc_result_out = 'FAIL' OR l_cc_result_out = 'FAIL_HOLD' OR
        l_cc_result_out = 'FAIL_NONE'
    THEN
      -- set the order hold release flag
       l_release_order_hold := 'N';
       IF G_debug_flag = 'Y' THEN
         OE_DEBUG_PUB.Add(' l_release_order_hold = '||l_release_order_hold );
       END IF;
    ELSE
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.Add('Item checking PASS, call Check_Other_Credit_Limits' );
    END IF;

      ---------------------------------------------------+
      -- Check other credit limits for the bill-to site: |
      -- check 2: max-past-due-inv limit                 |
      -- check 3: trx limit                              |
      -- check 4: overall limit                          |
      ---------------------------------------------------+
      Check_Other_Credit_Limits
      ( p_header_rec            => p_header_rec
      , p_party_id              => l_party_id     -----------new  (FPI)
      , p_customer_id           => l_own_customer_id
      , p_site_use_id           => l_order_site_use_id
      , p_calling_action        => p_calling_action
      , p_credit_check_rule_rec => p_credit_check_rule_rec
      , p_system_parameter_rec  => p_system_parameter_rec
      , p_transaction_amount    => p_transaction_amount
      , x_credit_level          => l_credit_level
      , x_check_exposure_mode   => l_check_exposure_mode
      , x_cc_result_out         => l_cc_result_out
      , x_cc_hold_comment       => x_cc_hold_comment
      , x_return_status         => x_return_status
      , x_global_exposure_flag  => l_global_exposure_flag
      );

     IF G_debug_flag = 'Y'
     THEN
      OE_DEBUG_PUB.Add('Check_Other_Credit_Limits: Result Out = '
                         || l_cc_result_out );
      OE_DEBUG_PUB.Add('l_check_exposure_mode = '||
                          l_check_exposure_mode );
      OE_DEBUG_PUB.Add('l_credit_level = '||
                          l_credit_level );
      OE_DEBUG_PUB.Add('x_cc_hold_comment = '||
                          x_cc_hold_comment );
      OE_DEBUG_PUB.Add('Check_Other_Credit_Limits: Return Status = '
                        || x_return_status );
     END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Apply order level credit hold to the database if it necessary

        IF     l_cc_result_out = 'FAIL'
            OR l_cc_result_out = 'FAIL_HOLD' OR
               l_cc_result_out = 'FAIL_NONE'
        THEN
            -- set the order hold release flag
            l_release_order_hold := 'N';
            IF G_debug_flag = 'Y' THEN
              OE_DEBUG_PUB.Add(' l_release_order_hold = '||l_release_order_hold );
            END IF;
        END IF;

      END IF; -- else item checking

      IF l_cc_result_out = 'NOCHECK' THEN
        x_cc_result_out := 'NOCHECK';
      ELSE
        x_cc_result_out   := l_cc_result_out ;
      END IF;

     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.Add('OEXVCRHB: Check_order_credit Results');
       OE_DEBUG_PUB.Add('l_release_order_hold : '|| l_release_order_hold );
       OE_DEBUG_PUB.Add('l_cc_result_out  : '|| l_cc_result_out );
     END IF;

  ELSE
    x_cc_result_out := 'NOCHECK';
    l_release_order_hold := 'Y' ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('OEXVCRHB: Payment term NO CC checked ');
    END IF;

  END IF; --  payment term check

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add(' l_release_order_hold = '|| l_release_order_hold );
     OE_DEBUG_PUB.Add(' x_cc_result_out = ' || x_cc_result_out );
  END IF;
  --
  -- Also check calling action to release hold only when action not EXTERNAL
  --
  IF l_release_order_hold = 'Y'  AND
     NVL(p_calling_action, 'BOOKING') <> 'EXTERNAL'
  --   AND l_cc_result_out <> 'NOCHECK'
  THEN
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.Add(' CALL Release_Order_CC_Hold ' );
     END IF;

    Release_Order_CC_Hold
    ( p_header_id             => p_header_rec.header_id
    , p_order_number          => p_header_rec.order_number
    , p_calling_action        => p_calling_action
    , p_system_parameter_rec  => p_system_parameter_rec
    , x_cc_result_out         => l_cc_result_out
    );

     IF G_debug_flag = 'Y'
     THEN
        OE_DEBUG_PUB.Add(' Release_Order_CC_Hold : Result Out = '
                  || l_cc_result_out );
     END IF;

  END IF;

  -- Bug 4506263 FP
  -- x_cc_result_out   := G_result_out ;
     x_cc_result_out   := l_cc_result_out;

  g_hold_exist := NULL ;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add(' l_cc_result_out = '|| l_cc_result_out );
     OE_DEBUG_PUB.Add(' G_result_out = ' || G_result_out );
     OE_DEBUG_PUB.Add(' final x_cc_result_out = '|| x_cc_result_out );
     OE_DEBUG_PUB.Add('OEXVCRHB: Out Check_order_credit API');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('Check_order_credit:  Error ');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('Check_order_credit: Unexpected Error ');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add('Check_order_credit: Other Unexpected Error ');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Check_order_credit'
      );
    END IF;
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.Add( SUBSTR(SQLERRM,1,300),1 ) ;
    END IF;
    OE_MSG_PUB.Count_And_Get
      (   p_count       =>      x_msg_count
      ,   p_data        =>      x_msg_data
      );

END Check_order_credit;


END OE_credit_check_order_PVT ;

/
