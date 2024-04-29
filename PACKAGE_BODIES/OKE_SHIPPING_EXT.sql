--------------------------------------------------------
--  DDL for Package Body OKE_SHIPPING_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_SHIPPING_EXT" AS
/* $Header: OKEXWSHB.pls 115.3 2002/08/14 01:43:10 alaw ship $ */

--
--  Name          : Cost_Of_Sales_Account
--  Pre-reqs      :
--  Function      : This function returns the cost of sales account
--                  for a given shipping delivery detail
--
--
--  Parameters    :
--  IN            : X_Delivery_Detail_ID        NUMBER
--  OUT           : None
--
--  Returns       : NUMBER
--

FUNCTION Cost_Of_Sales_Account
( X_Delivery_Detail_ID    NUMBER
) RETURN NUMBER
IS

retval   NUMBER;

CURSOR c IS
  SELECT nvl( ITEM.Cost_Of_Sales_Account
            , ORG.Cost_Of_Sales_Account )
  FROM   mtl_system_items       ITEM
  ,      mtl_parameters         ORG
  ,      wsh_delivery_details   DD
  WHERE  DD.Delivery_Detail_ID  = X_Delivery_Detail_ID
  AND    ITEM.Inventory_Item_ID = DD.Inventory_Item_ID
  AND    ITEM.Organization_ID   = DD.Organization_ID
  AND    ORG.Organization_ID    = ORG.Organization_ID;

BEGIN

  OPEN c;
  FETCH c INTO retval;

  IF ( c%notfound ) THEN
    CLOSE c;
    return ( NULL );
  END IF;

  CLOSE c;
  return ( retval );

EXCEPTION
WHEN OTHERS THEN
  return ( NULL );

END Cost_Of_Sales_Account;

END OKE_SHIPPING_EXT;

/
