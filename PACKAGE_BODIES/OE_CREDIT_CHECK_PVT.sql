--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_PVT" 	OE_Credit_Check_PVT AS
-- $Header: OEXVCRCB.pls 120.1 2005/06/21 02:16:02 appldev ship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
G_PKG_NAME CONSTANT VARCHAR2(30)   := 'OE_Credit_Check_PVT';
G_DBG_MSG           VARCHAR2(200)  := NULL;
G_ORG_ID            NUMBER         := mo_global.get_current_org_id;--MOAC Changes FND_PROFILE.value('ORG_ID') ;
--- G_PROFILE       VARCHAR2(30)   := 'MULTI' ;
G_PROFILE           VARCHAR2(30)   :=
             FND_PROFILE.VALUE('AR_CREDIT_LIMIT_SELECTION') ;
G_category_set_id NUMBER ;

TYPE category_tmp_rec IS RECORD
 ( item_category_id NUMBER
 , profile_exist    VARCHAR2(1)
 );


TYPE category_tmp_tbl_type  IS TABLE OF category_tmp_rec
     INDEX BY BINARY_INTEGER;


-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

-----------------------------------------------------------------------------
--  PROCEDURE  : GET_Item_Limit           PUBLIC
--  COMMENT    : Returns the limit associated with the Items.
--
------------------------------------------------------------------------------
PROCEDURE GET_Item_Limit
( p_header_id                  IN NUMBER
, p_trx_curr_code              IN VARCHAR2
, p_site_use_id                IN NUMBER
, x_item_limits_tbl OUT NOCOPY

                  OE_CREDIT_CHECK_GLOBALS.item_limits_tbl_type
, x_lines_tbl OUT NOCOPY

                  OE_CREDIT_CHECK_GLOBALS.lines_Rec_tbl_type
)
IS
l_item_limits_tbl OE_CREDIT_CHECK_UTIL.item_limits_tbl_type ;
l_lines_tbl       OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXVCRCB: IN GET_ITEM_LIMIT ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING OE_CREDIT_CHECK_UTIL.GET_ITEM_LIMIT ' ) ;
  END IF;

   OE_CREDIT_CHECK_UTIL.GET_Item_Limit
   ( p_header_id                  => p_header_id
   , p_trx_curr_code              => p_trx_curr_code
   , p_site_use_id                => p_site_use_id
   , p_include_tax_flag           => 'N'
   , x_item_limits_tbl            => l_item_limits_tbl
   , x_lines_tbl                  => l_lines_tbl
   );

  FOR I IN 1 .. l_item_limits_tbl.COUNT
  LOOP

   x_item_limits_tbl(I) := l_item_limits_tbl(I) ;
  END LOOP;

   FOR J IN 1..l_lines_tbl.COUNT
   LOOP
   x_lines_tbl(J)       := l_lines_tbl(J) ;

  END LOOP;

  IF l_debug_level  > 0 THEN
oe_debug_pub.add( 'OEXVCRCB: OUT NOCOPY GET_ITEM_LIMIT ' ) ;

  END IF;

  EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
   ---DBMS_OUTPUT.PUT_LINE(G_DBG_MSG );

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_Item_Limit '
      );
    END IF;
    RAISE;


END GET_Item_Limit ;



------------------------------------------------------------------------------
--  PROCEDURE  : Get_Limit_Info        PUBLIC
--  COMMENT    : Returns the credit limit info of a customer or a site
------------------------------------------------------------------------------
PROCEDURE get_limit_info (
   p_header_id                   IN NUMBER
 , p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , p_suppress_unused_usages_flag IN  VARCHAR2 DEFAULT 'Y'
, x_limit_curr_code OUT NOCOPY

                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, x_trx_limit OUT NOCOPY NUMBER

, x_overall_limit OUT NOCOPY NUMBER

, x_credit_check_flag OUT NOCOPY VARCHAR2

, x_include_all_flag OUT NOCOPY VARCHAR2

, x_usage_curr_tbl OUT NOCOPY

                   OE_CREDIT_CHECK_GLOBALS.usage_curr_tbl_type
, x_default_limit_flag OUT NOCOPY VARCHAR2

)
IS
l_usage_curr_tbl  OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE ;
l_global_exposure_flag VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXVCRCB: IN GET_LIMIT_INFO ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING GET_LIMIT_INFO ' ) ;
  END IF;

/*
   OE_CREDIT_CHECK_UTIL.get_limit_info (
      p_header_id                   => p_header_id
    , p_entity_type                 => p_entity_type
    , p_entity_id                   => p_entity_id
    , p_trx_curr_code               => p_trx_curr_code
    , p_suppress_unused_usages_flag => 'Y'
    , x_limit_curr_code             => x_limit_curr_code
    , x_trx_limit                   => x_trx_limit
    , x_overall_limit               => x_overall_limit
    , x_credit_check_flag           => x_credit_check_flag
    , x_include_all_flag            => x_include_all_flag
    , x_usage_curr_tbl              => l_usage_curr_tbl
    , x_default_limit_flag          => x_default_limit_flag
    , x_global_exposure_flag        => l_global_exposure_flag
   );

   FOR I IN 1..l_usage_curr_tbl.COUNT
   LOOP
     x_usage_curr_tbl(I) := l_usage_curr_tbl(I) ;
   END LOOP ;
*/

IF l_debug_level  > 0 THEN
oe_debug_pub.add( 'OEXVCRCB: OUT NOCOPY GET_LIMIT_INFO ' ) ;

END IF;

END get_limit_info ;



------------------------------------------------------------------------------
--  PROCEDURE  : Get_Usages     PUBLIC
--  COMMENT    : Returns the Usages
--
------------------------------------------------------------------------------
PROCEDURE Get_Usages (
  p_entity_type                 IN  VARCHAR2
, p_entity_id                   IN  NUMBER
, p_limit_curr_code             IN
                       HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_suppress_unused_usages_flag IN  VARCHAR2 DEFAULT 'Y'
, p_default_limit_flag          IN  VARCHAR2 DEFAULT 'N'
, x_include_all_flag OUT NOCOPY VARCHAR2

, x_usage_curr_tbl OUT NOCOPY

                        OE_CREDIT_CHECK_GLOBALS.usage_curr_tbl_type
)
IS
l_usage_curr_tbl  OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXVCRCB: IN GET_USAGES ' ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING .OE_CREDIT_CHECK_UTIL.GET_USAGES' ) ;
  END IF;
/*
  OE_CREDIT_CHECK_UTIL.Get_Usages (
    p_entity_type                 => p_entity_type
  , p_entity_id                   => p_entity_id
  , p_limit_curr_code             => p_limit_curr_code
  , p_suppress_unused_usages_flag => p_suppress_unused_usages_flag
  , p_default_limit_flag          => p_default_limit_flag
  , x_include_all_flag            => x_include_all_flag
  , x_usage_curr_tbl              => l_usage_curr_tbl
  );

   FOR I IN 1 .. l_usage_curr_tbl.COUNT
  LOOP

     x_usage_curr_tbl(I) := l_usage_curr_tbl(I) ;
  END LOOP;
*/

  IF l_debug_level  > 0 THEN
oe_debug_pub.add( 'OEXVCRCB: OUT NOCOPY GET_USAGES ' ) ;

  END IF;
END get_usages ;

--========================================================================
-- PROCEDURE : Currency_List
-- Comments  : This procedure is used by the credit snapshot report to derive
--             a comma delimited string of currencies defined in credit usage
-- Parameters: c_entity_type       IN    'CUSTOMER' or 'SITE'
--	       c_entity_id         IN    Customer_Id or Site_Id
--             c_trx_curr_code     IN    Transaction Currency
--             l_limit_curr_code   OUT   Currency Limit used for credit checking
--             Curr_list           OUT   Comma delimited string of currencies
--                                       covered by limit currency code
--========================================================================
Procedure currency_list (
   c_entity_type          IN  VARCHAR2
 , c_entity_id            IN  NUMBER
 , c_trx_curr_code        IN  VARCHAR2
, l_limit_curr_code OUT NOCOPY VARCHAR2

, l_default_limit_flag OUT NOCOPY VARCHAR2

, Curr_list OUT NOCOPY VARCHAR2) IS


  i                       NUMBER;
  l_return_status         NUMBER;
  l_CREDIT_CHECK_FLAG     VARCHAR2(1);
  l_OVERALL_CREDIT_LIMIT  NUMBER;
  l_TRX_CREDIT_LIMIT      NUMBER;
  l_include_all_flag      VARCHAR2(1);
  l_usage_curr_tbl     OE_CREDIT_CHECK_GLOBALS.usage_curr_tbl_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
/*
  oe_credit_check_pvt.get_limit_info
    ( p_header_id             => NULL
    , p_entity_type           => c_entity_type
    , p_entity_id             => c_entity_id
    , p_trx_curr_code         => c_trx_curr_code
    , p_suppress_unused_usages_flag => 'Y'
    , x_limit_curr_code       => l_limit_curr_code
    , x_trx_limit             => l_trx_credit_limit
    , x_overall_limit         => l_overall_credit_limit
    , x_credit_check_flag     => l_credit_check_flag
    , x_include_all_flag      => l_include_all_flag
    , x_usage_curr_tbl        => l_usage_curr_tbl
    , x_default_limit_flag    => l_default_limit_flag
    );

  for i in 1 .. l_usage_curr_tbl.COUNT
  LOOP
    if i = 1 then null;
    else
      curr_list := concat(curr_list,',');
    end if;
    curr_list := concat(curr_list, l_usage_curr_tbl(i).usage_curr_code);
  END LOOP;
*/
null ;
END Currency_List;



END ;

/
