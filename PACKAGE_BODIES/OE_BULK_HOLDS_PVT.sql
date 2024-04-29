--------------------------------------------------------
--  DDL for Package Body OE_BULK_HOLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BULK_HOLDS_PVT" AS
/* $Header: OEBVHLDB.pls 120.1.12010000.11 2011/12/27 14:51:24 sujithku ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_Bulk_Holds_PVT';


/****************************************************************************
 Valid Entity Combination
 ^^^^^^^^^^^^^^^^^^^^^^^^
 > 1. Customer - Header Level
 > 2. item  - Line Level
 > 3. ship_to  - Line Level
 > 4. bill to  - Line Level
 > 5. warehouse  - Line Level
 > 6. Item - Customer  - Line Level
 > 7. Item - Customer Ship to Site  - Line Level
 > 8. Item - Customer Bill to Site  - Line Level
 > 9. Item - Warehouse  - Line Level
 > 10. Warehouse - Customer  - Line Level
 > 11. Warehouse - Customer Ship to Site  - Line Level
 > 12. Warehouse - Customer Bill to Site  - Line Level

***************************************************************************/
PROCEDURE Extend_Holds_Tbl;

PROCEDURE Extend_Hold_Source_Rec;

--ER# 3667551  new Function added to return Customer Account ID for the Site ID passed in
FUNCTION CustAcctID_func
  (
    p_in_site_id IN NUMBER,
    p_out_IDfound OUT NOCOPY VARCHAR2)
  RETURN NUMBER IS
  l_Custid NUMBER := 0;
BEGIN
  p_out_IDfound:='N';
  SELECT 'Y',
    cust.cust_account_id
  INTO p_out_IDfound ,
    l_Custid
  FROM HZ_CUST_ACCOUNTS_ALL cust ,
    HZ_CUST_ACCT_SITES_ALL site,
    hz_cust_site_uses_all siteuse
  WHERE siteuse.site_use_id  = p_in_site_id
  AND site.cust_acct_site_id = siteuse.cust_acct_site_id
  AND siteuse.site_use_code  ='BILL_TO'
  AND siteuse.status         = 'A'
  AND cust.cust_account_id   =site.cust_account_id ;

  oe_debug_pub.add(' CustAcctID_func -l_Custid- '||l_Custid);
  RETURN(l_Custid);
EXCEPTION
WHEN NO_DATA_FOUNd THEN
  oe_debug_pub.add(' CustAcctID_func, No Data Found, p_in_site_id= '||p_in_site_id);
  p_out_IDfound:='N';
  RETURN 0;
WHEN OTHERS THEN
  oe_debug_pub.add(' CustAcctID_func, When Others Exception, p_in_site_id='||p_in_site_id);
  p_out_IDfound:='N';
  RETURN 0;
END;
--ER# 3667551 END

PROCEDURE Initialize_Holds_Tbl IS
BEGIN

  -- Clear the Globals.
  g_hold_header_id.DELETE;
  g_hold_line_id.DELETE;
  g_hold_Source_Id.DELETE;
  g_hold_ship_set.DELETE;
  g_hold_arrival_set.DELETE;
  g_hold_top_model_line_id.DELETE;
  g_hold_activity_name.DELETE;

  g_hold_source_rec.HOLD_ID.DELETE;
  g_hold_source_rec.HOLD_SOURCE_ID.DELETE;
  g_hold_source_rec.HOLD_ENTITY_CODE.DELETE;
  g_hold_source_rec.HOLD_ENTITY_ID.DELETE;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Initialize_Holds_Tbl'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Initialize_Holds_Tbl;

PROCEDURE Load_Hold_Sources
IS
CURSOR C_Hold_Sources IS
    SELECT HS.HOLD_SOURCE_ID,
           HS.HOLD_ENTITY_ID,
           HS.HOLD_ENTITY_CODE,
           HS.HOLD_ENTITY_ID2,
           HS.HOLD_ENTITY_CODE2,
           HLD.ACTIVITY_NAME,
	   HS.HOLD_ID --ER# 3667551
     FROM  OE_HOLD_SOURCES HS,
           OE_HOLD_DEFINITIONS HLD
     WHERE --ER#7479609 HS.HOLD_ENTITY_CODE IN ('C','I','B','W','S')
           HS.HOLD_ENTITY_CODE IN ('C','I','B','D','W','S','PL','OT','CD','SC','P','SM','EC','IC')		--ER#7479609 --ER# 12571983 added ,'EC' --ER# 13331078 added 'IC'
       AND ROUND( NVL(HS.HOLD_UNTIL_DATE, SYSDATE ) ) >=
                                     ROUND( SYSDATE )
       AND HS.RELEASED_FLAG = 'N'
       AND HLD.HOLD_ID = HS.HOLD_ID
       AND SYSDATE
               BETWEEN NVL( HLD.START_DATE_ACTIVE, SYSDATE )
                   AND NVL( HLD.END_DATE_ACTIVE, SYSDATE )
     ORDER BY HS.HOLD_ENTITY_CODE,HS.HOLD_ENTITY_CODE2,HS.HOLD_ENTITY_ID,
              HS.HOLD_ENTITY_ID2;

  T_HOLD_SOURCE_ID     OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM();
  --ER#7479609 T_HOLD_ENTITY_ID     OE_WSH_BULK_GRP.T_NUM;
  T_HOLD_ENTITY_ID     OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50();  --ER#7479609
  T_HOLD_ENTITY_CODE   OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();
  --ER#7479609 T_HOLD_ENTITY_ID2    OE_WSH_BULK_GRP.T_NUM;
  T_HOLD_ENTITY_ID2    OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50();  --ER#7479609
  T_HOLD_ENTITY_CODE2  OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();
  T_HOLD_ACTIVITY_NAME OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30();
  T_HOLD_ID     OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50();--ER# 3667551

  l_count   BINARY_INTEGER;
BEGIN

  oe_debug_pub.add('Entering OE_Bulk_Holds_PVT.Load_Hold_Sources');  --ER#7479609 debug
  -- Clear the Globals.
  g_hold_header_id.DELETE;
  g_hold_line_id.DELETE;
  g_hold_Source_Id.DELETE;
  g_hold_ship_set.DELETE;
  g_hold_arrival_set.DELETE;
  g_hold_top_model_line_id.DELETE;
  g_hold_activity_name.DELETE;

  Customer_Pointer.DELETE;
  Item_Pointer.DELETE;
  ship_to_Pointer.DELETE;
  bill_to_Pointer.DELETE;
  Warehouse_Pointer.DELETE;
  --ER#7479609 start
  PriceList_Pointer.DELETE;
  OrderType_Pointer.DELETE;
  CreationDate_Pointer.DELETE;
  SalesChannel_Pointer.DELETE;
  PaymentType_Pointer.DELETE;
  ShipMethod_Pointer.DELETE;
  deliver_to_Pointer.DELETE;
  --ER#7479609 end

  Item_Customer_Pointer.DELETE;
  Item_shipto_Pointer.DELETE;
  Item_Billto_Pointer.DELETE;
  Item_Warehouse_Pointer.DELETE;
  --ER#7479609 start
  Item_ShipMethod_Pointer.DELETE;
  Item_Deliverto_Pointer.DELETE;
  Item_PriceList_Pointer.DELETE;
  --ER#7479609 Item_Project_Pointer.DELETE;
  Item_SourceType_Pointer.DELETE;
  Item_LineType_Pointer.DELETE;
  --ER#7479609 end

  Warehouse_Customer_Pointer.DELETE;
  Warehouse_shipto_Pointer.DELETE;
  Warehouse_Billto_Pointer.DELETE;
  --ER#7479609 start
  Warehouse_LineType_Pointer.DELETE;
  Warehouse_ShipMethod_Pointer.DELETE;
  Warehouse_Deliverto_Pointer.DELETE;
  Warehouse_SourceType_Pointer.DELETE;
  --ER#7479609 end

  --ER#7479609 start
  Cust_SourceType_Pointer.DELETE;
  Cust_Billto_Pointer.DELETE;
  Cust_Shipto_Pointer.DELETE;
  Cust_Deliverto_Pointer.DELETE;
  Cust_PriceList_Pointer.DELETE;
  Cust_LineType_Pointer.DELETE;
  Cust_PayTerm_Pointer.DELETE;
  Cust_OrderType_Pointer.DELETE;
  Cust_PaymentType_Pointer.DELETE;
  Cust_Curr_Pointer.DELETE;
  Cust_SalesChannel_Pointer.DELETE;


  --ER#7479609 Project_Task_Pointer.DELETE;

  PriceList_Curr_Pointer.DELETE;

  OrderType_Curr_Pointer.DELETE;
  OrderType_LineType_Pointer.DELETE;

  CreDate_CreBy_Pointer.DELETE;
  --ER#7479609 end

  Customer_Hold.DELETE;
  Item_Hold.DELETE;
  ship_to_Hold.DELETE;
  bill_to_Hold.DELETE;
  Warehouse_Hold.DELETE;
  --ER#7479609 start
  PriceList_Hold.DELETE;
  OrderType_Hold.DELETE;
  CreationDate_Hold.DELETE;
  SalesChannel_Hold.DELETE;
  PaymentType_Hold.DELETE;
  ShipMethod_Hold.DELETE;
  deliver_to_Hold.DELETE;
  --ER#7479609 end

  Item_Customer_Hold.DELETE;
  Item_shipto_Hold.DELETE;
  Item_Billto_Hold.DELETE;
  Item_Warehouse_Hold.DELETE;
  --ER#7479609 start
  Item_ShipMethod_Hold.DELETE;
  Item_Deliverto_Hold.DELETE;
  Item_PriceList_Hold.DELETE;
  Item_SourceType_Hold.DELETE;
  Item_LineType_Hold.DELETE;
  --ER#7479609 end

  Warehouse_Customer_Hold.DELETE;
  Warehouse_shipto_Hold.DELETE;
  Warehouse_Billto_Hold.DELETE;
  --ER#7479609 start
  Warehouse_LineType_Hold.DELETE;
  Warehouse_ShipMethod_Hold.DELETE;
  Warehouse_Deliverto_Hold.DELETE;
  Warehouse_SourceType_Hold.DELETE;
  --ER#7479609 end

--ER#7479609 start
  Cust_SourceType_Hold.DELETE;
  Cust_Billto_Hold.DELETE;
  Cust_Shipto_Hold.DELETE;
  Cust_Deliverto_Hold.DELETE;
  Cust_PriceList_Hold.DELETE;
  Cust_LineType_Hold.DELETE;
  Cust_PayTerm_Hold.DELETE;
  Cust_OrderType_Hold.DELETE;
  Cust_PaymentType_Hold.DELETE;
  Cust_Curr_Hold.DELETE;
  Cust_SalesChannel_Hold.DELETE;



  PriceList_Curr_Hold.DELETE;

  OrderType_Curr_Hold.DELETE;
  OrderType_LineType_Hold.DELETE;

  CreDate_CreBy_Hold.DELETE;
--ER#7479609 end

--ER# 12571983 start added for 'EC'

EndCust_Pointer.Delete;
Item_EndCust_Pointer.Delete;
Warehouse_EndCust_Pointer.Delete;
EndCust_SourceType_Pointer.Delete;
EndCust_Billto_Pointer.Delete;
EndCust_Shipto_Pointer.Delete;
EndCust_Deliverto_Pointer.Delete;
EndCust_PriceList_Pointer.Delete;
EndCust_LineType_Pointer.Delete;
EndCust_PayTerm_Pointer.Delete;
EndCust_OrderType_Pointer.Delete;
EndCust_PaymentType_Pointer.Delete;
EndCust_Curr_Pointer.Delete;
EndCust_SalesChannel_Pointer.Delete;
EndCust_EndCustLoc_Pointer.Delete;

EndCust_Hold.Delete;
Item_EndCust_Hold.Delete;
Warehouse_EndCust_Hold.Delete;
EndCust_SourceType_Hold.Delete;
EndCust_Billto_Hold.Delete;
EndCust_Shipto_Hold.Delete;
EndCust_Deliverto_Hold.Delete;
EndCust_PriceList_Hold.Delete;
EndCust_LineType_Hold.Delete;
EndCust_PayTerm_Hold.Delete;
EndCust_OrderType_Hold.Delete;
EndCust_PaymentType_Hold.Delete;
EndCust_Curr_Hold.Delete;
EndCust_SalesChannel_Hold.Delete;
EndCust_EndCustLoc_Hold.Delete;

--ER# 12571983 end added for 'EC'

 oe_debug_pub.add('Before opening C_Hold_Sources');  --ER#7479609 debug
  -- Load the Hold Sources into Globals.
  OPEN C_Hold_Sources;
  FETCH C_Hold_Sources BULK COLLECT INTO
                       T_HOLD_SOURCE_ID,
                       T_HOLD_ENTITY_ID,
                       T_HOLD_ENTITY_CODE,
                       T_HOLD_ENTITY_ID2,
                       T_HOLD_ENTITY_CODE2,
                       T_HOLD_ACTIVITY_NAME,
		       T_HOLD_ID;--ER# 3667551
  CLOSE C_Hold_Sources;
  oe_debug_pub.add('After Closing C_Hold_Sources:'||T_HOLD_SOURCE_ID.COUNT);  --ER#7479609 debug

  FOR i IN 1..T_HOLD_SOURCE_ID.COUNT LOOP

    -- Load Customer Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := Customer_Hold.COUNT;
      Customer_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Customer_Hold(l_count+1).Entity_Id2 := NULL;
      Customer_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Customer_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);
	  Customer_Hold(l_count+1).HOLD_ID:=T_HOLD_ID(i);--ER# 3667551

      IF NOT Customer_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Customer_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) IS NULL
    THEN
      l_count := EndCust_Hold.COUNT;
      EndCust_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_Hold(l_count+1).Entity_Id2 := NULL;
      EndCust_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end

    -- Load Item Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := Item_Hold.COUNT;
      Item_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Hold(l_count+1).Entity_Id2 := NULL;
      Item_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    -- Load Ship_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'S' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := Ship_to_Hold.COUNT;
      Ship_to_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Ship_to_Hold(l_count+1).Entity_Id2 := NULL;
      Ship_to_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Ship_to_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Ship_to_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Ship_to_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    -- Load Bill_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'B' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := Bill_to_Hold.COUNT;
      Bill_to_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Bill_to_Hold(l_count+1).Entity_Id2 := NULL;
      Bill_to_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Bill_to_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Bill_to_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Bill_to_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    -- Load Warehouse Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := Warehouse_Hold.COUNT;
      Warehouse_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_Hold(l_count+1).Entity_Id2 := NULL;
      Warehouse_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;



--ER#7479609 start

    IF T_HOLD_ENTITY_CODE(i) = 'PL' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := PriceList_Hold.COUNT;
      PriceList_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      PriceList_Hold(l_count+1).Entity_Id2 := NULL;
      PriceList_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      PriceList_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT PriceList_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        PriceList_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'OT' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := OrderType_Hold.COUNT;
      OrderType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      OrderType_Hold(l_count+1).Entity_Id2 := NULL;
      OrderType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      OrderType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT OrderType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        OrderType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'CD' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := CreationDate_Hold.COUNT;
      CreationDate_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      CreationDate_Hold(l_count+1).Entity_Id2 := NULL;
      CreationDate_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      CreationDate_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT CreationDate_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        CreationDate_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'SC' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := SalesChannel_Hold.COUNT;
      SalesChannel_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      SalesChannel_Hold(l_count+1).Entity_Id2 := NULL;
      SalesChannel_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      SalesChannel_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT SalesChannel_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        SalesChannel_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    oe_debug_pub.add('Before Loading payment type');  --ER#7479609 debug
    IF T_HOLD_ENTITY_CODE(i) = 'P' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := PaymentType_Hold.COUNT;
      PaymentType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      PaymentType_Hold(l_count+1).Entity_Id2 := NULL;
      PaymentType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      PaymentType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT PaymentType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        PaymentType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'SM' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := ShipMethod_Hold.COUNT;
      ShipMethod_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ShipMethod_Hold(l_count+1).Entity_Id2 := NULL;
      ShipMethod_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ShipMethod_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ShipMethod_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ShipMethod_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'D' AND T_HOLD_ENTITY_ID2(i) IS NULL
    THEN
      l_count := deliver_to_Hold.COUNT;
      deliver_to_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      deliver_to_Hold(l_count+1).Entity_Id2 := NULL;
      deliver_to_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      deliver_to_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT deliver_to_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        deliver_to_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

--ER#7479609 end

--ER#7479609 start

    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'ST'
    THEN
      l_count := Cust_SourceType_Hold.COUNT;
      Cust_SourceType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_SourceType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_SourceType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_SourceType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_SourceType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_SourceType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'ST'
    THEN
      l_count := EndCust_SourceType_Hold.COUNT;
      EndCust_SourceType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_SourceType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_SourceType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_SourceType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_SourceType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_SourceType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end

    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'B'
    THEN
      l_count := Cust_Billto_Hold.COUNT;
      Cust_Billto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_Billto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_Billto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_Billto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_Billto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_Billto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'B'
    THEN
      l_count := EndCust_Billto_Hold.COUNT;
      EndCust_Billto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_Billto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_Billto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_Billto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_Billto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_Billto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'S'
    THEN
      l_count := Cust_Shipto_Hold.COUNT;
      Cust_Shipto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_Shipto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_Shipto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_Shipto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_Shipto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_Shipto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'S'
    THEN
      l_count := EndCust_Shipto_Hold.COUNT;
      EndCust_Shipto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_Shipto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_Shipto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_Shipto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_Shipto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_Shipto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'D'
    THEN
      l_count := Cust_Deliverto_Hold.COUNT;
      Cust_Deliverto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_Deliverto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_Deliverto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_Deliverto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_Deliverto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_Deliverto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start

	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'D'
    THEN
      l_count := EndCust_Deliverto_Hold.COUNT;
      EndCust_Deliverto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_Deliverto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_Deliverto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_Deliverto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_Deliverto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_Deliverto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'PL'
    THEN
      l_count := Cust_PriceList_Hold.COUNT;
      Cust_PriceList_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_PriceList_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_PriceList_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_PriceList_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_PriceList_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_PriceList_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_ID2(i) = 'PL'
    THEN
      l_count := EndCust_PriceList_Hold.COUNT;
      EndCust_PriceList_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_PriceList_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_PriceList_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_PriceList_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_PriceList_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_PriceList_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'LT'
    THEN
      l_count := Cust_LineType_Hold.COUNT;
      Cust_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'LT'
    THEN
      l_count := EndCust_LineType_Hold.COUNT;
      EndCust_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'PT'
    THEN
      l_count := Cust_PayTerm_Hold.COUNT;
      Cust_PayTerm_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_PayTerm_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_PayTerm_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_PayTerm_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_PayTerm_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_PayTerm_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'PT'
    THEN
      l_count := EndCust_PayTerm_Hold.COUNT;
      EndCust_PayTerm_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_PayTerm_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_PayTerm_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_PayTerm_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_PayTerm_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_PayTerm_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'OT'
    THEN
      l_count := Cust_OrderType_Hold.COUNT;
      Cust_OrderType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_OrderType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_OrderType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_OrderType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_OrderType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_OrderType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'OT'
    THEN
	  l_count := EndCust_OrderType_Hold.COUNT;
      EndCust_OrderType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_OrderType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_OrderType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_OrderType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_OrderType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
	    EndCust_OrderType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'P'
    THEN
      l_count := Cust_PaymentType_Hold.COUNT;
      Cust_PaymentType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_PaymentType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_PaymentType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_PaymentType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_PaymentType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_PaymentType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'P'
    THEN
      l_count := EndCust_PaymentType_Hold.COUNT;
      EndCust_PaymentType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_PaymentType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_PaymentType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_PaymentType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_PaymentType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_PaymentType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'TC'
    THEN
      l_count := Cust_Curr_Hold.COUNT;
      Cust_Curr_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_Curr_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_Curr_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_Curr_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_Curr_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_Curr_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'TC'
    THEN
      l_count := EndCust_Curr_Hold.COUNT;
      EndCust_Curr_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_Curr_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_Curr_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_Curr_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_Curr_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_Curr_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


    IF T_HOLD_ENTITY_CODE(i) = 'C' AND T_HOLD_ENTITY_ID2(i) = 'SC'
    THEN
      l_count := Cust_SalesChannel_Hold.COUNT;
      Cust_SalesChannel_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Cust_SalesChannel_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Cust_SalesChannel_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Cust_SalesChannel_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Cust_SalesChannel_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Cust_SalesChannel_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'SC'
    THEN
      l_count := EndCust_SalesChannel_Hold.COUNT;
      EndCust_SalesChannel_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_SalesChannel_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_SalesChannel_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_SalesChannel_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_SalesChannel_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_SalesChannel_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	IF T_HOLD_ENTITY_CODE(i) = 'EC' AND T_HOLD_ENTITY_CODE2(i) = 'EL'
    THEN
	  l_count := EndCust_EndCustLoc_Hold.COUNT;
      EndCust_EndCustLoc_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      EndCust_EndCustLoc_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      EndCust_EndCustLoc_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      EndCust_EndCustLoc_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT EndCust_EndCustLoc_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        EndCust_EndCustLoc_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end


--ER#7479609 end

    -- Load Item Customer Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'C'
    THEN
      l_count := Item_Customer_Hold.COUNT;
      Item_Customer_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Customer_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_Customer_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Customer_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Customer_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Customer_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'EC'
    THEN
      l_count := Item_EndCust_Hold.COUNT;
      Item_EndCust_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_EndCust_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_EndCust_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_EndCust_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_EndCust_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_EndCust_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end

    -- Load Item Ship_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'S'
    THEN
      l_count := Item_Shipto_Hold.COUNT;
      Item_Shipto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Shipto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_Shipto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Shipto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Shipto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Shipto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    -- Load Item Bill_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'B'
    THEN
      l_count := Item_Billto_Hold.COUNT;
      Item_Billto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Billto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_Billto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Billto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Billto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Billto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    -- Load Item Warehouse Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'W'
    THEN
      l_count := Item_Warehouse_Hold.COUNT;
      Item_Warehouse_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Warehouse_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_Warehouse_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Warehouse_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Warehouse_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Warehouse_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

--ER#7479609 start
    -- Load Item Linetype Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'LT'
    THEN
      l_count := Item_LineType_Hold.COUNT;
      Item_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;
--ER#7479609 end

--ER#7479609 start

    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'SM'
    THEN
      l_count := Item_ShipMethod_Hold.COUNT;
      Item_ShipMethod_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_ShipMethod_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_ShipMethod_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_ShipMethod_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_ShipMethod_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_ShipMethod_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'D'
    THEN
      l_count := Item_Warehouse_Hold.COUNT;
      Item_Deliverto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_Deliverto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_Deliverto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_Deliverto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_Deliverto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_Deliverto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'PL'
    THEN
      l_count := Item_PriceList_Hold.COUNT;
      Item_PriceList_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_PriceList_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_PriceList_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_PriceList_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_PriceList_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_PriceList_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    IF T_HOLD_ENTITY_CODE(i) = 'I' AND T_HOLD_ENTITY_CODE2(i) = 'ST'
    THEN
      l_count := Item_SourceType_Hold.COUNT;
      Item_SourceType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Item_SourceType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Item_SourceType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Item_SourceType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Item_SourceType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Item_SourceType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

--ER#7479609 end
    oe_debug_pub.add('Before Loading Ware House');  --ER#7479609 debug
    -- Load Warehouse Customer Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'C'
    THEN
      l_count := Warehouse_Customer_Hold.COUNT;
      Warehouse_Customer_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_Customer_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_Customer_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_Customer_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_Customer_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_Customer_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 start
	IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'EC'
    THEN
      l_count := Warehouse_EndCust_Hold.COUNT;
      Warehouse_EndCust_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_EndCust_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_EndCust_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_EndCust_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_EndCust_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_EndCust_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end

    -- Load Warehouse Shipto Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'S'
    THEN
      l_count := Warehouse_shipto_Hold.COUNT;
      Warehouse_Shipto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_Shipto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_Shipto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_Shipto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_Shipto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_Shipto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    -- Load Warehouse Billto Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'B'
    THEN
      l_count := Warehouse_Billto_hold.COUNT;
      Warehouse_Billto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_Billto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_Billto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_Billto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_Billto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_Billto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

--ER#7479609 start

    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'LT'
    THEN
      l_count := Warehouse_LineType_Hold.COUNT;
      Warehouse_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'SM'
    THEN
      l_count := Warehouse_ShipMethod_Hold.COUNT;
      Warehouse_ShipMethod_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_ShipMethod_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_ShipMethod_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_ShipMethod_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_ShipMethod_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_ShipMethod_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'D'
    THEN
      l_count := Warehouse_Deliverto_Hold.COUNT;
      Warehouse_Deliverto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_Deliverto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_Deliverto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_Deliverto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_Deliverto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_Deliverto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    IF T_HOLD_ENTITY_CODE(i) = 'W' AND T_HOLD_ENTITY_CODE2(i) = 'ST'
    THEN
      l_count := Warehouse_SourceType_Hold.COUNT;
      Warehouse_SourceType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      Warehouse_SourceType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      Warehouse_SourceType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      Warehouse_SourceType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT Warehouse_SourceType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        Warehouse_SourceType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

--ER#7479609 end

--ER#7479609 start
-- Misc


    IF T_HOLD_ENTITY_CODE(i) = 'PL' AND T_HOLD_ENTITY_CODE2(i) = 'TC'
    THEN
      l_count := PriceList_Curr_Hold.COUNT;
      PriceList_Curr_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      PriceList_Curr_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      PriceList_Curr_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      PriceList_Curr_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT PriceList_Curr_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        PriceList_Curr_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    IF T_HOLD_ENTITY_CODE(i) = 'OT' AND T_HOLD_ENTITY_CODE2(i) = 'TC'
    THEN
      l_count := OrderType_Curr_Hold.COUNT;
      OrderType_Curr_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      OrderType_Curr_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      OrderType_Curr_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      OrderType_Curr_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT OrderType_Curr_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        OrderType_Curr_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    IF T_HOLD_ENTITY_CODE(i) = 'OT' AND T_HOLD_ENTITY_CODE2(i) = 'LT'
    THEN
      l_count := OrderType_LineType_Hold.COUNT;
      OrderType_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      OrderType_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      OrderType_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      OrderType_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT OrderType_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        OrderType_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    IF T_HOLD_ENTITY_CODE(i) = 'CD' AND T_HOLD_ENTITY_CODE2(i) = 'CB'
    THEN
      l_count := CreDate_CreBy_Hold.COUNT;
      CreDate_CreBy_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      CreDate_CreBy_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      CreDate_CreBy_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      CreDate_CreBy_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT CreDate_CreBy_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        CreDate_CreBy_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


--ER#7479609 end

--ER# 13331078 START for 'IC'

--Item Category Hold
IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) IS NULL
    THEN
      l_count := ItemCat_Hold.COUNT;
      ItemCat_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Hold(l_count+1).Entity_Id2 := NULL;
      ItemCat_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

-- Load Item Category,Customer Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'C'
    THEN
      l_count := ItemCat_Customer_Hold.COUNT;
      ItemCat_Customer_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Customer_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_Customer_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Customer_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Customer_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Customer_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	--ER# 12571983 as well
	-- Load Item Category, End Customer Hold Source
	IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'EC'
    THEN
      l_count := ItemCat_EndCust_Hold.COUNT;
      ItemCat_EndCust_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_EndCust_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_EndCust_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_EndCust_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_EndCust_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_EndCust_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;
	--ER# 12571983 end

    -- Load Item Category,Ship_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'S'
    THEN
      l_count := ItemCat_Shipto_Hold.COUNT;
      ItemCat_Shipto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Shipto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_Shipto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Shipto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Shipto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Shipto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    -- Load Item Category,Bill_To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'B'
    THEN
      l_count := ItemCat_Billto_Hold.COUNT;
      ItemCat_Billto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Billto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_Billto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Billto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Billto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Billto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

    -- Load Item Category,Warehouse Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'W'
    THEN
      l_count := ItemCat_Warehouse_Hold.COUNT;
      ItemCat_Warehouse_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Warehouse_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_Warehouse_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Warehouse_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Warehouse_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Warehouse_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;


    -- Load Item Category,Linetype Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'LT'
    THEN
      l_count := ItemCat_LineType_Hold.COUNT;
      ItemCat_LineType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_LineType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_LineType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_LineType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_LineType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_LineType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;
    END IF;

	-- Load Item Category,Ship Method Hold Source

    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'SM'
    THEN
      l_count := ItemCat_ShipMethod_Hold.COUNT;
      ItemCat_ShipMethod_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_ShipMethod_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_ShipMethod_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_ShipMethod_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_ShipMethod_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_ShipMethod_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

 -- Load Item Category,Deliver To Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'D'
    THEN
      l_count := ItemCat_Deliverto_Hold.COUNT;
      ItemCat_Deliverto_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_Deliverto_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_Deliverto_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_Deliverto_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_Deliverto_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_Deliverto_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

	-- Load Item Category,Price List Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'PL'
    THEN
      l_count := ItemCat_PriceList_Hold.COUNT;
      ItemCat_PriceList_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_PriceList_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_PriceList_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_PriceList_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_PriceList_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_PriceList_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

-- Load Item Category,Source Type Hold Source
    IF T_HOLD_ENTITY_CODE(i) = 'IC' AND T_HOLD_ENTITY_CODE2(i) = 'ST'
    THEN
      l_count := ItemCat_SourceType_Hold.COUNT;
      ItemCat_SourceType_Hold(l_count+1).Entity_Id1 := T_HOLD_ENTITY_ID(i);
      ItemCat_SourceType_Hold(l_count+1).Entity_Id2 := T_HOLD_ENTITY_ID2(i);
      ItemCat_SourceType_Hold(l_count+1).Hold_Source_Id := T_HOLD_SOURCE_ID(i);
      ItemCat_SourceType_Hold(l_count+1).activity_name := T_HOLD_ACTIVITY_NAME(i);

      IF NOT ItemCat_SourceType_Pointer.EXISTS(T_HOLD_ENTITY_ID(i)) THEN
        ItemCat_SourceType_Pointer(T_HOLD_ENTITY_ID(i)) := l_count+1;
      END IF;

    END IF;

--ER# 13331078 END for 'IC'

  END LOOP;

  oe_debug_pub.add('Exitting OE_Bulk_Holds_PVT.Load_Hold_Sources');  --ER#7479609 debug

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Load_Hold_Sources'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Hold_Sources;



--ER#7479609 start
PROCEDURE Evaluate_Holds(
p_header_rec        IN OE_Order_PUB.Header_Rec_Type,
p_line_rec           IN OE_Order_PUB.Line_Rec_Type,
p_check_only_warehouse_holds IN BOOLEAN := FALSE,
p_on_generic_hold            OUT NOCOPY BOOLEAN,
p_on_booking_hold            OUT NOCOPY BOOLEAN,
p_on_scheduling_hold         OUT NOCOPY BOOLEAN
)
IS
i  NUMBER;
j NUMBER;
l_activity_name VARCHAR2(30);
l_inventory_item_id  NUMBER;


l_itemcategory_id NUMBER :=''; --ER# 13331078

--ER# 3667551 start
l_credithold_syspar varchar2(10) := NVL(OE_SYS_PARAMETERS.value('ONT_CREDITHOLD_TYPE'),'S') ;
l_custlin_hold CHAR := 'N';
l_invoice_Custid NUMBER := 0;
--ER# 3667551 end;

BEGIN
oe_debug_pub.add('Entering OE_Bulk_Holds_PVT.Evaluate_Holds');
oe_debug_pub.add('Header'||p_header_rec.header_id);
oe_debug_pub.add('Line:'||p_line_rec.header_id||':'||p_line_rec.line_id);

  -- Set the OUT parameter
  p_on_generic_hold := FALSE;
  p_on_booking_hold := FALSE;
  p_on_scheduling_hold := FALSE;

  IF p_line_rec.line_id IS NULL THEN -- Header Level Holds

     -- Check Customer Hold
     IF Customer_Pointer.EXISTS(p_header_rec.sold_to_org_id) THEN

         j := Customer_Pointer(p_header_rec.sold_to_org_id);
         WHILE Customer_hold(j).Entity_Id1 = p_header_rec.sold_to_org_id
         LOOP
		 --ER# 3667551 start, if System param set to 'BillToCustomerLine' then no header hold
		 -- Also for Bill To Customer and Sold to Customer being same with parameter as 'BTH'
		 -- applying hold is handled seperately below this section so no hold to be applied for BTH also here
		 --
		 If(l_credithold_syspar IN('BTL','BTH') AND Customer_hold(j).hold_id=1) then
		 j := j+1; -- Increment counter so that next hold data is processed
		 oe_debug_pub.add('Credit Hold TYpe System Parameter set to BillToCustomer, no header level hold');
		 Else
		 --ER# 3667551 end
             Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Customer_hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Customer_hold(j).activity_name,
                  p_attribute => 'Customer',
                  p_top_model_line_id => NULL
                  );
             IF Customer_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF Customer_hold(j).activity_name = 'BOOK_ORDER' THEN
               p_on_booking_hold := TRUE;
             END IF;
             j := j+1;
            End If; --ER# 3667551, added end if;

			 IF j > Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;

	 --ER# 3667551 start
	 -- Check Customer Hold , for Credit Hold checking with System parameter "Apply Credit Hold Based On"
	 --set to 'Bill To Customer Header'
		l_invoice_Custid:=CustAcctID_func(p_in_site_id => p_header_rec.invoice_to_org_id,
                                          p_out_IDfound=> l_custlin_hold);

     IF l_custlin_hold='Y' and Customer_Pointer.EXISTS(l_invoice_Custid) THEN

         j := Customer_Pointer(l_invoice_Custid);

         WHILE Customer_hold(j).Entity_Id1 = l_invoice_Custid
         LOOP

		 If(l_credithold_syspar='BTH' AND Customer_hold(j).hold_id=1) then

             Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Customer_hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Customer_hold(j).activity_name,
                  p_attribute => 'Customer',
                  p_top_model_line_id => NULL
                  );
             IF Customer_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF Customer_hold(j).activity_name = 'BOOK_ORDER' THEN
               p_on_booking_hold := TRUE;
             END IF;
            End If; -- end if of BTH check
			j := j+1;
             IF j > Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;
     --ER# 3667551 end


--ER#7479609 start

     -- Check Sales channel Hold
     IF SalesChannel_Pointer.EXISTS(p_header_rec.sales_channel_code) THEN

         j := SalesChannel_Pointer(p_header_rec.sales_channel_code);
         WHILE SalesChannel_Hold(j).Entity_Id1 = p_header_rec.sales_channel_code
         LOOP
             Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => SalesChannel_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => SalesChannel_Hold(j).activity_name,
                  p_attribute => 'Sales Channel',
                  p_top_model_line_id => NULL
                  );
             IF SalesChannel_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF SalesChannel_Hold(j).activity_name = 'BOOK_ORDER' THEN
               p_on_booking_hold := TRUE;
             END IF;
             j := j+1;

             IF j > SalesChannel_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;

     -- Check Payment Type Hold
     IF PaymentType_Pointer.EXISTS(p_header_rec.payment_type_code) THEN

         j := PaymentType_Pointer(p_header_rec.payment_type_code);
         WHILE PaymentType_Hold(j).Entity_Id1 = p_header_rec.payment_type_code
         LOOP
             Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => PaymentType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => PaymentType_Hold(j).activity_name,
                  p_attribute => 'Payment Type',
                  p_top_model_line_id => NULL
                  );
             IF PaymentType_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF PaymentType_Hold(j).activity_name = 'BOOK_ORDER' THEN
               p_on_booking_hold := TRUE;
             END IF;
             j := j+1;

             IF j > PaymentType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;

     -- Check Customer Order Type Holds
     IF p_header_rec.sold_to_org_id IS NOT NULL AND
        p_header_rec.order_type_id IS NOT NULL AND
        Cust_OrderType_Pointer.EXISTS(p_header_rec.sold_to_org_id)
     THEN
         j := Cust_OrderType_Pointer(p_header_rec.sold_to_org_id);
         WHILE Cust_OrderType_Hold(j).Entity_Id1 = p_header_rec.sold_to_org_id
         LOOP

             IF Cust_OrderType_Hold(j).Entity_Id2 = p_header_rec.order_type_id
             THEN
              Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Cust_OrderType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_OrderType_Hold(j).activity_name,
                  p_attribute => 'Customer/Order Type',
                  p_top_model_line_id => NULL
                  );
               IF Cust_OrderType_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF Cust_OrderType_Hold(j).activity_name = 'BOOK_ORDER' THEN
                 p_on_booking_hold := TRUE;
               END IF;

             END IF;
             j := j + 1;

             IF j > Cust_OrderType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Customer payment Type Holds

     IF p_header_rec.sold_to_org_id IS NOT NULL AND
        p_header_rec.payment_type_code IS NOT NULL AND
        Cust_PaymentType_Pointer.EXISTS(p_header_rec.sold_to_org_id)
     THEN
         j := Cust_PaymentType_Pointer(p_header_rec.sold_to_org_id);
         WHILE Cust_PaymentType_Hold(j).Entity_Id1 = p_header_rec.sold_to_org_id
         LOOP

             IF Cust_PaymentType_Hold(j).Entity_Id2 = p_header_rec.payment_type_code
             THEN
              Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Cust_PaymentType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_PaymentType_Hold(j).activity_name,
                  p_attribute => 'Customer/Payment Type',
                  p_top_model_line_id => NULL
                  );
               IF Cust_PaymentType_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF Cust_PaymentType_Hold(j).activity_name = 'BOOK_ORDER' THEN
                 p_on_booking_hold := TRUE;
               END IF;

             END IF;
             j := j + 1;

             IF j > Cust_PaymentType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer currency Holds
     IF p_header_rec.sold_to_org_id IS NOT NULL AND
        p_header_rec.transactional_curr_code  IS NOT NULL AND
        Cust_Curr_Pointer.EXISTS(p_header_rec.sold_to_org_id)
     THEN
         j := Cust_Curr_Pointer(p_header_rec.sold_to_org_id);
         WHILE Cust_Curr_Hold(j).Entity_Id1 = p_header_rec.sold_to_org_id
         LOOP

             IF Cust_Curr_Hold(j).Entity_Id2 = p_header_rec.transactional_curr_code
             THEN
              Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Cust_Curr_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_Curr_Hold(j).activity_name,
                  p_attribute => 'Customer/Currency',
                  p_top_model_line_id => NULL
                  );
               IF Cust_Curr_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF Cust_Curr_Hold(j).activity_name = 'BOOK_ORDER' THEN
                 p_on_booking_hold := TRUE;
               END IF;

             END IF;
             j := j + 1;

             IF j > Cust_Curr_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer Sales Channel Holds
     IF p_header_rec.sold_to_org_id IS NOT NULL AND
        p_header_rec.sales_channel_code IS NOT NULL AND
        Cust_SalesChannel_Pointer.EXISTS(p_header_rec.sold_to_org_id)
     THEN
         j := Cust_SalesChannel_Pointer(p_header_rec.sold_to_org_id);
         WHILE Cust_SalesChannel_Hold(j).Entity_Id1 = p_header_rec.sold_to_org_id
         LOOP

             IF Cust_SalesChannel_Hold(j).Entity_Id2 = p_header_rec.sales_channel_code
             THEN
              Mark_Hold(p_header_id => p_header_rec.header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Cust_SalesChannel_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_SalesChannel_Hold(j).activity_name,
                  p_attribute => 'Customer/Sales Channel',
                  p_top_model_line_id => NULL
                  );
               IF Cust_SalesChannel_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF Cust_SalesChannel_Hold(j).activity_name = 'BOOK_ORDER' THEN
                 p_on_booking_hold := TRUE;
               END IF;

             END IF;
             j := j + 1;

             IF j > Cust_SalesChannel_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 end
  ELSE  -- Line Level Holds

  --ER# 13331078 start
       BEGIN
	   select mic.category_id
	   into l_itemcategory_id
	   from mtl_item_categories mic,
	   mtl_default_category_sets  mdc
	   where mic.inventory_item_id = p_line_rec.inventory_item_id
	   and mic.organization_id = p_line_rec.ship_from_org_id
	   AND mdc.functional_area_id=7
	   AND mdc.category_set_id = mic.category_set_id;
	   EXCEPTION WHEN OTHERS THEN
	   l_itemcategory_id := '';
	   END;

	--ER# 13331078 end


     IF p_check_only_warehouse_holds THEN
        GOTO Just_WareHouse_Holds;
     END IF;

	 --ER# 3667551 start
	 -- Check Customer Hold at Line Level for Credit Hold Enabled with SystemParameter to BillTo
	  -- check should be for hold source entry of Bill To Customer of Line
	 l_invoice_Custid:=CustAcctID_func(p_in_site_id => p_line_rec.invoice_to_org_id,
                                          p_out_IDfound=> l_custlin_hold);
     --IF Customer_Pointer.EXISTS(p_line_rec.sold_to_org_id) THEN
	 IF (Customer_Pointer.EXISTS(l_invoice_Custid) AND l_custlin_hold = 'Y') THEN
		  j := Customer_Pointer(l_invoice_Custid);
		  oe_debug_pub.add(' CH sold_to_org_id= ' ||p_line_rec.sold_to_org_id||'invoice_to_org_id= '||p_line_rec.invoice_to_org_id);

		 WHILE (Customer_hold(j).Entity_Id1 = l_invoice_Custid )
         LOOP

			If(l_credithold_syspar='BTL' AND Customer_hold(j).hold_id=1) then
			  Mark_Hold(p_header_id => p_line_rec.header_id,
						p_line_id => p_line_rec.line_id,
						p_line_number => p_line_rec.line_number,
						p_hold_source_id => Customer_hold(j).hold_source_id,
						p_ship_set_name => NULL,
						p_arrival_set_name => NULL,
						p_activity_name => Customer_hold(j).activity_name,
						p_attribute => 'Customer',
						p_top_model_line_id => p_line_rec.top_model_line_id
						);

			  IF Customer_hold(j).activity_name   IS NULL THEN
				p_on_generic_hold                 := TRUE;
			  ELSIF Customer_hold(j).activity_name = 'LINE_SCHEDULING' THEN
				p_on_scheduling_hold              := TRUE;
			  END IF;

			END IF;
			j   := j+1;

			IF j > Customer_hold.COUNT THEN
			  EXIT;
			END IF;

		  END LOOP;
		END IF;
		--ER# 3667551, END

     -- Check Item Hold
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        Item_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_Pointer(p_line_rec.inventory_item_id);
         WHILE item_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_hold(j).activity_name,
                  p_attribute => 'Item',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF item_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF item_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Item_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Ship_To Hold
     IF p_line_rec.ship_to_org_id IS NOT NULL AND
        Ship_To_Pointer.EXISTS(p_line_rec.ship_to_org_id)
     THEN
         j := ship_to_Pointer(p_line_rec.ship_to_org_id);
         WHILE Ship_to_hold(j).Entity_Id1 = p_line_rec.ship_to_org_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Ship_to_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Ship_to_hold(j).activity_name,
                  p_attribute => 'Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF Ship_to_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Ship_to_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Ship_to_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Bill_To Hold
     IF p_line_rec.invoice_to_org_id IS NOT NULL AND
        Bill_To_Pointer.EXISTS(p_line_rec.invoice_to_org_id)
     THEN
         j := Bill_To_Pointer(p_line_rec.invoice_to_org_id);
         WHILE Bill_To_hold(j).Entity_Id1 = p_line_rec.invoice_to_org_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Bill_To_hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Bill_To_hold(j).activity_name,
                  p_attribute => 'Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF Bill_To_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Bill_To_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Bill_to_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

--ER#7479609 start

     -- Check Price List Hold
     IF p_line_rec.price_list_id  IS NOT NULL AND
        PriceList_Pointer.EXISTS(p_line_rec.price_list_id)
     THEN
         j := PriceList_Pointer(p_line_rec.price_list_id);
         WHILE PriceList_Hold(j).Entity_Id1 = p_line_rec.price_list_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => PriceList_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => PriceList_Hold(j).activity_name,
                  p_attribute => 'Price List',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF PriceList_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF PriceList_Hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > PriceList_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Order Type Hold
     IF p_header_rec.order_type_id  IS NOT NULL AND
        OrderType_Pointer.EXISTS(p_header_rec.order_type_id)
     THEN
         j := OrderType_Pointer(p_header_rec.order_type_id);
         WHILE OrderType_Hold(j).Entity_Id1 = p_header_rec.order_type_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => OrderType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => OrderType_Hold(j).activity_name,
                  p_attribute => 'POrder Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF OrderType_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF OrderType_Hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > OrderType_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Creation Date Hold
     IF p_line_rec.creation_date  IS NOT NULL AND
        CreationDate_Pointer.EXISTS(to_char(p_line_rec.creation_date,'DD-MON-RRRR'))
     THEN
         j := CreationDate_Pointer(to_char(p_line_rec.creation_date,'DD-MON-RRRR'));
         WHILE CreationDate_Hold(j).Entity_Id1 = to_char(p_line_rec.creation_date,'DD-MON-RRRR')
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => CreationDate_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => CreationDate_Hold(j).activity_name,
                  p_attribute => 'Creation Date',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF CreationDate_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF CreationDate_Hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > CreationDate_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;


     -- Check Shipping Method Hold
     IF p_line_rec.shipping_method_code IS NOT NULL AND
        ShipMethod_Pointer.EXISTS(p_line_rec.shipping_method_code)
     THEN
         j := ShipMethod_Pointer(p_line_rec.shipping_method_code);
         WHILE ShipMethod_Hold(j).Entity_Id1 = p_line_rec.shipping_method_code
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ShipMethod_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ShipMethod_Hold(j).activity_name,
                  p_attribute => 'Shipping Method',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF ShipMethod_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF ShipMethod_Hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > ShipMethod_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;


--ER#7479609 end


     -- Check Item Customer Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.sold_to_org_id IS NOT NULL AND
        Item_Customer_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_Customer_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_Customer_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_Customer_Hold(j).Entity_Id2 = p_line_rec.sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_Customer_Hold(j).activity_name,
                  p_attribute => 'Item\Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Shipto Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.ship_to_org_id IS NOT NULL AND
        Item_Shipto_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_shipto_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_shipto_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_shipto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_shipto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_shipto_Hold(j).activity_name,
                  p_attribute => 'Item\Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_shipto_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item LineType Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        Item_LineType_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_LineType_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_LineType_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_LineType_Hold(j).activity_name,
                  p_attribute => 'Item\Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 start


     -- Check Item Customer Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.sold_to_org_id IS NOT NULL AND
        Item_Customer_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_Customer_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_Customer_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_Customer_Hold(j).Entity_Id2 = p_line_rec.sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_Customer_Hold(j).activity_name,
                  p_attribute => 'Item\Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Ship Method Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.shipping_method_code IS NOT NULL AND
        Item_ShipMethod_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_ShipMethod_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_ShipMethod_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_ShipMethod_Hold(j).Entity_Id2 = p_line_rec.shipping_method_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_ShipMethod_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_ShipMethod_Hold(j).activity_name,
                  p_attribute => 'Item\Ship Method',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_ShipMethod_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_ShipMethod_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_ShipMethod_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Deliver to Site Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.deliver_to_org_id IS NOT NULL AND
        Item_Deliverto_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_Deliverto_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_Deliverto_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_Deliverto_Hold(j).Entity_Id2 = p_line_rec.deliver_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_Deliverto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_Deliverto_Hold(j).activity_name,
                  p_attribute => 'Item\Deliver to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_Deliverto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Deliverto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Deliverto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Price List Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.price_list_id IS NOT NULL AND
        Item_PriceList_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_PriceList_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_PriceList_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_PriceList_Hold(j).Entity_Id2 = p_line_rec.price_list_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_PriceList_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_PriceList_Hold(j).activity_name,
                  p_attribute => 'Item\Price List',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_PriceList_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_PriceList_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_PriceList_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Source Type Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.source_type_code IS NOT NULL AND
        Item_SourceType_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_SourceType_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_SourceType_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_SourceType_Hold(j).Entity_Id2 = p_line_rec.source_type_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_SourceType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_SourceType_Hold(j).activity_name,
                  p_attribute => 'Item\Source Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_SourceType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_SourceType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_SourceType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 end

     -- Check Item BillTo Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.invoice_to_org_id IS NOT NULL AND
        Item_Billto_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_billto_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_billto_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_billto_Hold(j).Entity_Id2 = p_line_rec.invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_billto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_billto_Hold(j).activity_name,
                  p_attribute => 'Item\Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_billto_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 start

     -- Check Customer Source Type  Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.source_type_code IS NOT NULL AND
        Cust_SourceType_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_SourceType_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_SourceType_Hold(j).Entity_Id1 = p_line_rec.sold_to_org_id
         LOOP

             IF Cust_SourceType_Hold(j).Entity_Id2 = p_line_rec.source_type_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_SourceType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_SourceType_Hold(j).activity_name,
                  p_attribute => 'Customer/Source Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_SourceType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_SourceType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_SourceType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer Bill to Site  Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.invoice_to_org_id IS NOT NULL AND
        Cust_Billto_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_Billto_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_Billto_Hold(j).Entity_Id1 = p_line_rec.sold_to_org_id
         LOOP

             IF Cust_Billto_Hold(j).Entity_Id2 = p_line_rec.invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_Billto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_Billto_Hold(j).activity_name,
                  p_attribute => 'Customer/Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_Billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_Billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_Billto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer Ship to Site  Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.ship_to_org_id IS NOT NULL AND
        Cust_Shipto_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_Shipto_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_Shipto_Hold(j).Entity_Id1 = p_line_rec.sold_to_org_id
         LOOP

             IF Cust_Shipto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_Shipto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_Shipto_Hold(j).activity_name,
                  p_attribute => 'Customer/Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_Shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_Shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_Shipto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Customer Deliver to Site  Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.deliver_to_org_id IS NOT NULL AND
        Cust_Deliverto_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_Deliverto_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_Deliverto_Hold(j).Entity_Id1 = p_line_rec.deliver_to_org_id
         LOOP

             IF Cust_Deliverto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_Deliverto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_Deliverto_Hold(j).activity_name,
                  p_attribute => 'Customer/Deliver to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_Deliverto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_Deliverto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_Deliverto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Customer Price List Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.price_list_id IS NOT NULL AND
        Cust_PriceList_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_PriceList_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_PriceList_Hold(j).Entity_Id1 = p_line_rec.deliver_to_org_id
         LOOP

             IF Cust_PriceList_Hold(j).Entity_Id2 = p_line_rec.price_list_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_PriceList_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_PriceList_Hold(j).activity_name,
                  p_attribute => 'Customer/Price List',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_PriceList_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_PriceList_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_PriceList_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer Line type Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        Cust_LineType_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_LineType_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_LineType_Hold(j).Entity_Id1 = p_line_rec.deliver_to_org_id
         LOOP

             IF Cust_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_LineType_Hold(j).activity_name,
                  p_attribute => 'Customer/Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Customer Payment term Holds
     IF p_line_rec.sold_to_org_id IS NOT NULL AND
        p_line_rec.payment_term_id IS NOT NULL AND
        Cust_PayTerm_Pointer.EXISTS(p_line_rec.sold_to_org_id)
     THEN
         j := Cust_PayTerm_Pointer(p_line_rec.sold_to_org_id);
         WHILE Cust_PayTerm_Hold(j).Entity_Id1 = p_line_rec.deliver_to_org_id
         LOOP

             IF Cust_PayTerm_Hold(j).Entity_Id2 = p_line_rec.payment_term_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Cust_PayTerm_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Cust_PayTerm_Hold(j).activity_name,
                  p_attribute => 'Customer/Payment Term',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Cust_PayTerm_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Cust_PayTerm_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Cust_PayTerm_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Order Type Line Type Holds
     IF p_header_rec.order_type_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        OrderType_LineType_Pointer.EXISTS(p_header_rec.order_type_id)
     THEN
         j := OrderType_LineType_Pointer(p_header_rec.order_type_id);
         WHILE OrderType_LineType_Hold(j).Entity_Id1 = p_header_rec.order_type_id
         LOOP

             IF OrderType_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => OrderType_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => OrderType_LineType_Hold(j).activity_name,
                  p_attribute => 'Order Type/Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF OrderType_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF OrderType_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > OrderType_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Creation date/Creation By Holds
     IF p_line_rec.creation_date IS NOT NULL AND
        p_line_rec.created_by IS NOT NULL AND
        CreDate_CreBy_Pointer.EXISTS(to_char(p_line_rec.creation_date,'DD-MON-RRRR'))
     THEN
         j := CreDate_CreBy_Pointer(to_char(p_line_rec.creation_date,'DD-MON-RRRR'));
         WHILE CreDate_CreBy_Hold(j).Entity_Id1 = to_char(p_line_rec.creation_date,'DD-MON-RRRR')
         LOOP

             IF CreDate_CreBy_Hold(j).Entity_Id2 = p_line_rec.created_by
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => CreDate_CreBy_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => CreDate_CreBy_Hold(j).activity_name,
                  p_attribute => 'Creation Date/Creation By',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF CreDate_CreBy_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF CreDate_CreBy_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > CreDate_CreBy_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


--ER#7479609 end
    --ER# 12571983 start
	-- Check EndCustomer Holds
	IF EndCust_Pointer.EXISTS(p_line_rec.end_customer_id) THEN

         j := EndCust_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP
             Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id =>  p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_Hold(j).activity_name,
                  p_attribute => 'End Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
             IF EndCust_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF EndCust_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;
             j := j+1;

             IF j > EndCust_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;

	 -- Check End Customer, Order Type Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_header_rec.order_type_id IS NOT NULL AND
        EndCust_OrderType_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_OrderType_Pointer(p_line_rec.end_customer_id);

		 WHILE EndCust_OrderType_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP
             IF EndCust_OrderType_Hold(j).Entity_Id2 = p_header_rec.order_type_id
             THEN
              Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_OrderType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_OrderType_Hold(j).activity_name,
                  p_attribute => 'End Customer/Order Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
               IF EndCust_OrderType_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF EndCust_OrderType_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_OrderType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check End Customer, payment Type Holds

     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_header_rec.payment_type_code IS NOT NULL AND
        EndCust_PaymentType_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_PaymentType_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_PaymentType_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_PaymentType_Hold(j).Entity_Id2 = p_header_rec.payment_type_code
             THEN
              Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_PaymentType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_PaymentType_Hold(j).activity_name,
                  p_attribute => 'End Customer/Payment Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
               IF EndCust_PaymentType_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF EndCust_PaymentType_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_PaymentType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check End Customer, currency Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_header_rec.transactional_curr_code  IS NOT NULL AND
        EndCust_Curr_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_Curr_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_Curr_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_Curr_Hold(j).Entity_Id2 = p_header_rec.transactional_curr_code
             THEN
              Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_Curr_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_Curr_Hold(j).activity_name,
                  p_attribute => 'End Customer/Currency',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
               IF EndCust_Curr_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF EndCust_Curr_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_Curr_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check End Customer, Sales Channel Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_header_rec.sales_channel_code IS NOT NULL AND
        EndCust_SalesChannel_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_SalesChannel_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_SalesChannel_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_SalesChannel_Hold(j).Entity_Id2 = p_header_rec.sales_channel_code
             THEN
              Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_SalesChannel_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_SalesChannel_Hold(j).activity_name,
                  p_attribute => 'End Customer/Sales Channel',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
               IF EndCust_SalesChannel_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF EndCust_SalesChannel_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_SalesChannel_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

	 -- Check End Customer, End Customer Location Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.end_customer_site_use_id IS NOT NULL AND
        EndCust_EndCustLoc_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
	     j := EndCust_EndCustLoc_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_EndCustLoc_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_EndCustLoc_Hold(j).Entity_Id2 = p_line_rec.end_customer_site_use_id
             THEN
              Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_EndCustLoc_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_EndCustLoc_Hold(j).activity_name,
                  p_attribute => 'End Customer/End Customer Location',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
               IF EndCust_EndCustLoc_Hold(j).activity_name IS NULL THEN
                 p_on_generic_hold := TRUE;
               ELSIF EndCust_EndCustLoc_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_EndCustLoc_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

    -- Check Item, EndCustomer Holds
	 IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.end_customer_id IS NOT NULL AND
        Item_EndCust_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_EndCust_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_EndCust_Hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_EndCust_Hold(j).Entity_Id2 = p_line_rec.end_customer_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_EndCust_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_EndCust_Hold(j).activity_name,
                  p_attribute => 'Item\End Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_EndCust_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_EndCust_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_EndCust_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

	 -- Check End Customer, Source Type  Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.source_type_code IS NOT NULL AND
        EndCust_SourceType_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_SourceType_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_SourceType_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_SourceType_Hold(j).Entity_Id2 = p_line_rec.source_type_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_SourceType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_SourceType_Hold(j).activity_name,
                  p_attribute => 'End Customer/Source Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_SourceType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_SourceType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_SourceType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check End Customer, Bill to Site  Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.invoice_to_org_id IS NOT NULL AND
        EndCust_Billto_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_Billto_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_Billto_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_Billto_Hold(j).Entity_Id2 = p_line_rec.invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_Billto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_Billto_Hold(j).activity_name,
                  p_attribute => 'End Customer/Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_Billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_Billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_Billto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check End Customer, Ship to Site  Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.ship_to_org_id IS NOT NULL AND
        EndCust_Shipto_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_Shipto_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_Shipto_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_Shipto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_Shipto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_Shipto_Hold(j).activity_name,
                  p_attribute => 'End Customer/Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_Shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_Shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_Shipto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check End Customer, Deliver to Site  Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.deliver_to_org_id IS NOT NULL AND
        EndCust_Deliverto_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_Deliverto_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_Deliverto_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_Deliverto_Hold(j).Entity_Id2 = p_line_rec.deliver_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_Deliverto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_Deliverto_Hold(j).activity_name,
                  p_attribute => 'End Customer/Deliver to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_Deliverto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_Deliverto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_Deliverto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check End Customer, Price List Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.price_list_id IS NOT NULL AND
        EndCust_PriceList_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_PriceList_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_PriceList_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_PriceList_Hold(j).Entity_Id2 = p_line_rec.price_list_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_PriceList_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_PriceList_Hold(j).activity_name,
                  p_attribute => 'End Customer/Price List',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_PriceList_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_PriceList_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_PriceList_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check End Customer, Line type Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        EndCust_LineType_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_LineType_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_LineType_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_LineType_Hold(j).activity_name,
                  p_attribute => 'End Customer/Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check EndCustomer, Payment term Holds
     IF p_line_rec.end_customer_id IS NOT NULL AND
        p_line_rec.payment_term_id IS NOT NULL AND
        EndCust_PayTerm_Pointer.EXISTS(p_line_rec.end_customer_id)
     THEN
         j := EndCust_PayTerm_Pointer(p_line_rec.end_customer_id);
         WHILE EndCust_PayTerm_Hold(j).Entity_Id1 = p_line_rec.end_customer_id
         LOOP

             IF EndCust_PayTerm_Hold(j).Entity_Id2 = p_line_rec.payment_term_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => EndCust_PayTerm_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => EndCust_PayTerm_Hold(j).activity_name,
                  p_attribute => 'End Customer/Payment Term',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF EndCust_PayTerm_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF EndCust_PayTerm_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > EndCust_PayTerm_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;
	 --ER# 12571983 end

	 --ER# 13331078 START added for 'IC'
-- Check Item Category Hold
     IF l_itemcategory_id IS NOT NULL AND
        ItemCat_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_Pointer(l_itemcategory_id);
         WHILE ItemCat_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_Hold(j).activity_name,
                  p_attribute => 'ItemCategory',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF ItemCat_Hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF ItemCat_Hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > ItemCat_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

	 -- Check Item Category,Customer Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.sold_to_org_id IS NOT NULL AND
        ItemCat_Customer_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_Customer_Pointer(l_itemcategory_id);
         WHILE ItemCat_Customer_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_Customer_Hold(j).Entity_Id2 = p_line_rec.sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_Customer_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_Customer_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


	 -- Check Item Category,Shipto Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.ship_to_org_id IS NOT NULL AND
        ItemCat_shipto_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_shipto_Pointer(l_itemcategory_id);
         WHILE ItemCat_shipto_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_shipto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_shipto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_shipto_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_shipto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Category,LineType Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        ItemCat_LineType_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_LineType_Pointer(l_itemcategory_id);
         WHILE ItemCat_LineType_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_LineType_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Category,Ship Method Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.shipping_method_code IS NOT NULL AND
        ItemCat_ShipMethod_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_ShipMethod_Pointer(l_itemcategory_id);
         WHILE ItemCat_ShipMethod_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_ShipMethod_Hold(j).Entity_Id2 = p_line_rec.shipping_method_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_ShipMethod_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_ShipMethod_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Ship Method',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_ShipMethod_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_ShipMethod_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_ShipMethod_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Category,Deliver to Site Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.deliver_to_org_id IS NOT NULL AND
        ItemCat_Deliverto_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_Deliverto_Pointer(l_itemcategory_id);
         WHILE ItemCat_Deliverto_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_Deliverto_Hold(j).Entity_Id2 = p_line_rec.deliver_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_Deliverto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_Deliverto_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Deliver to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_Deliverto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_Deliverto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_Deliverto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Category,Price List Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.price_list_id IS NOT NULL AND
        ItemCat_PriceList_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_PriceList_Pointer(l_itemcategory_id);
         WHILE ItemCat_PriceList_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_PriceList_Hold(j).Entity_Id2 = p_line_rec.price_list_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_PriceList_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_PriceList_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Price List',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_PriceList_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_PriceList_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_PriceList_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Category,Source Type Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.source_type_code IS NOT NULL AND
        ItemCat_SourceType_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_SourceType_Pointer(l_itemcategory_id);
         WHILE ItemCat_SourceType_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_SourceType_Hold(j).Entity_Id2 = p_line_rec.source_type_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_SourceType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_SourceType_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Source Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_SourceType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_SourceType_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_SourceType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Item Category,BillTo Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.invoice_to_org_id IS NOT NULL AND
        ItemCat_Billto_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_Billto_Pointer(l_itemcategory_id);
         WHILE ItemCat_Billto_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_Billto_Hold(j).Entity_Id2 = p_line_rec.invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_Billto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_Billto_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_Billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_Billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_Billto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

	 -- Check Item, EndCustomer Holds, for --ER# 12571983 as well
	 IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.end_customer_id IS NOT NULL AND
        ItemCat_EndCust_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_EndCust_Pointer(l_itemcategory_id);
         WHILE ItemCat_EndCust_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_EndCust_Hold(j).Entity_Id2 = p_line_rec.end_customer_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_EndCust_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_EndCust_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\End Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_EndCust_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_EndCust_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_EndCust_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

	 --ER# 13331078 END added for 'IC'


     <<Just_WareHouse_Holds>>

     -- Check Item Warehouse Holds
     IF p_line_rec.inventory_item_id IS NOT NULL AND
        p_line_rec.ship_from_org_id  IS NOT NULL AND
        Item_Warehouse_Pointer.EXISTS(p_line_rec.inventory_item_id)
     THEN
         j := Item_Warehouse_Pointer(p_line_rec.inventory_item_id);
         WHILE Item_Warehouse_hold(j).Entity_Id1 = p_line_rec.inventory_item_id
         LOOP

             IF Item_Warehouse_Hold(j).Entity_Id2 = p_line_rec.ship_from_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Item_Warehouse_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Item_Warehouse_Hold(j).activity_name,
                  p_attribute => 'Item\Warehouse',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF Item_Warehouse_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Warehouse_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Warehouse_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Hold
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        Warehouse_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP
            Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_hold(j).activity_name,
                  p_attribute => 'Warehouse',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
            IF Warehouse_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Warehouse_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Warehouse_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Warehouse Customer Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.sold_to_org_id IS NOT NULL AND
        Warehouse_Customer_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_Customer_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_Customer_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_Customer_Hold(j).Entity_Id2 = p_line_rec.sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id =>Warehouse_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_Customer_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_Customer_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Shipto Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.ship_to_org_id IS NOT NULL AND
        Warehouse_shipto_pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_shipto_pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_shipto_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_shipto_Hold(j).Entity_Id2 = p_line_rec.ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_shipto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_shipto_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Ship to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_shipto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse BillTo Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.invoice_to_org_id IS NOT NULL AND
        Warehouse_billto_pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_billto_pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_billto_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_billto_Hold(j).Entity_Id2 = p_line_rec.invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_billto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_billto_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Bill to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_billto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 start

     -- Check Warehouse Line Type Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.line_type_id IS NOT NULL AND
        Warehouse_LineType_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_LineType_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_LineType_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_LineType_Hold(j).Entity_Id2 = p_line_rec.line_type_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_LineType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_LineType_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Line Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_LineType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_LineType_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_LineType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Shipping Method Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.shipping_method_code IS NOT NULL AND
        Warehouse_ShipMethod_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_ShipMethod_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_ShipMethod_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_ShipMethod_Hold(j).Entity_Id2 = p_line_rec.shipping_method_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_ShipMethod_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_ShipMethod_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Shipping Method',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_ShipMethod_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_ShipMethod_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_ShipMethod_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Deliver to Site Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.deliver_to_org_id IS NOT NULL AND
        Warehouse_Deliverto_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_Deliverto_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_Deliverto_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_Deliverto_Hold(j).Entity_Id2 = p_line_rec.deliver_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_Deliverto_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_Deliverto_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Deliver to Site',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_Deliverto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_Deliverto_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_Deliverto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;


     -- Check Warehouse Source type Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.source_type_code IS NOT NULL AND
        Warehouse_SourceType_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_SourceType_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_SourceType_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_SourceType_Hold(j).Entity_Id2 = p_line_rec.source_type_code
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => Warehouse_SourceType_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_SourceType_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Source Type',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_SourceType_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_SourceType_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_SourceType_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

--ER#7479609 end

   --ER# 12571983 start
    -- Check Warehouse, EndCustomer Holds
     IF p_line_rec.ship_from_org_id IS NOT NULL AND
        p_line_rec.end_customer_id IS NOT NULL AND
        Warehouse_EndCust_Pointer.EXISTS(p_line_rec.ship_from_org_id)
     THEN
         j := Warehouse_EndCust_Pointer(p_line_rec.ship_from_org_id);
         WHILE Warehouse_EndCust_Hold(j).Entity_Id1 = p_line_rec.ship_from_org_id
         LOOP

             IF Warehouse_EndCust_Hold(j).Entity_Id2 = p_line_rec.end_customer_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id =>Warehouse_EndCust_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Warehouse_EndCust_Hold(j).activity_name,
                  p_attribute => 'Warehouse\End Customer',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                IF Warehouse_EndCust_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_EndCust_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_EndCust_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;
	--ER# 12571983 end

	--ER# 13331078 START added fro 'IC'
	  --Check Item Category,Warehouse Holds
     IF l_itemcategory_id IS NOT NULL AND
        p_line_rec.ship_from_org_id  IS NOT NULL AND
        ItemCat_Warehouse_Pointer.EXISTS(l_itemcategory_id)
     THEN
         j := ItemCat_Warehouse_Pointer(l_itemcategory_id);
         WHILE ItemCat_Warehouse_Hold(j).Entity_Id1 = l_itemcategory_id
         LOOP

             IF ItemCat_Warehouse_Hold(j).Entity_Id2 = p_line_rec.ship_from_org_id
             THEN
                 Mark_Hold(p_header_id => p_line_rec.header_id,
                  p_line_id => p_line_rec.line_id,
                  p_line_number => p_line_rec.line_number,
                  p_hold_source_id => ItemCat_Warehouse_Hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => ItemCat_Warehouse_Hold(j).activity_name,
                  p_attribute => 'ItemCategory\Warehouse',
                  p_top_model_line_id => p_line_rec.top_model_line_id
                  );
                 IF ItemCat_Warehouse_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF ItemCat_Warehouse_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > ItemCat_Warehouse_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

	 --ER# 13331078 END added 'IC'

  END IF;
oe_debug_pub.add('Exitting OE_Bulk_Holds_PVT.Evaluate_Holds');  --ER#7479609 debug
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Evaluate_Holds'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Evaluate_Holds;

--ER#7479609 end



PROCEDURE Evaluate_Holds(
p_header_id                  IN NUMBER,
p_line_id                    IN NUMBER,
p_line_number                IN NUMBER,
p_sold_to_org_id             IN NUMBER,
p_inventory_item_id          IN NUMBER,
p_ship_from_org_id           IN NUMBER,
p_invoice_to_org_id          IN NUMBER,
p_ship_to_org_id             IN NUMBER,
p_top_model_line_id          IN NUMBER,
p_ship_set_name              IN VARCHAR2,
p_arrival_set_name           IN VARCHAR2,
p_check_only_warehouse_holds IN BOOLEAN := FALSE,
p_on_generic_hold            OUT NOCOPY BOOLEAN,
p_on_booking_hold            OUT NOCOPY BOOLEAN,
p_on_scheduling_hold         OUT NOCOPY BOOLEAN
)
IS
i  NUMBER;
j NUMBER;
l_activity_name VARCHAR2(30);
BEGIN
  -- Set the OUT parameter
  p_on_generic_hold := FALSE;
  p_on_booking_hold := FALSE;
  p_on_scheduling_hold := FALSE;

  IF p_line_id IS NULL THEN -- Header Level Holds

     -- Check Customer Hold
     IF Customer_Pointer.EXISTS(p_sold_to_org_id) THEN

         j := Customer_Pointer(p_sold_to_org_id);
         WHILE Customer_hold(j).Entity_Id1 = p_sold_to_org_id
         LOOP
             Mark_Hold(p_header_id => p_header_id,
                  p_line_id => NULL,
                  p_line_number => NULL,
                  p_hold_source_id => Customer_hold(j).hold_source_id,
                  p_ship_set_name => NULL,
                  p_arrival_set_name => NULL,
                  p_activity_name => Customer_hold(j).activity_name,
                  p_attribute => 'Customer',
                  p_top_model_line_id => NULL
                  );
             IF Customer_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
             ELSIF Customer_hold(j).activity_name = 'BOOK_ORDER' THEN
               p_on_booking_hold := TRUE;
             END IF;
             j := j+1;

             IF j > Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;

     END IF;

  ELSE  -- Line Level Holds

     IF p_check_only_warehouse_holds THEN
        GOTO Just_WareHouse_Holds;
     END IF;

     -- Check Item Hold
     IF p_inventory_item_id IS NOT NULL AND
        Item_Pointer.EXISTS(p_inventory_item_id)
     THEN
         j := Item_Pointer(p_inventory_item_id);
         WHILE item_hold(j).Entity_Id1 = p_inventory_item_id
         LOOP
            Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Item_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Item_hold(j).activity_name,
                  p_attribute => 'Item',
                  p_top_model_line_id => p_top_model_line_id
                  );
            IF item_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF item_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Item_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Ship_To Hold
     IF p_ship_to_org_id IS NOT NULL AND
        Ship_To_Pointer.EXISTS(p_ship_to_org_id)
     THEN
         j := ship_to_Pointer(p_ship_to_org_id);
         WHILE Ship_to_hold(j).Entity_Id1 = p_ship_to_org_id
         LOOP
            Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Ship_to_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Ship_to_hold(j).activity_name,
                  p_attribute => 'Ship to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
            IF Ship_to_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Ship_to_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Ship_to_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Bill_To Hold
     IF p_invoice_to_org_id IS NOT NULL AND
        Bill_To_Pointer.EXISTS(p_invoice_to_org_id)
     THEN
         j := Bill_To_Pointer(p_invoice_to_org_id);
         WHILE Bill_To_hold(j).Entity_Id1 = p_invoice_to_org_id
         LOOP
            Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Bill_To_hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Bill_To_hold(j).activity_name,
                  p_attribute => 'Bill to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
            IF Bill_To_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Bill_To_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Bill_to_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;


     -- Check Item Customer Holds
     IF p_inventory_item_id IS NOT NULL AND
        p_sold_to_org_id IS NOT NULL AND
        Item_Customer_Pointer.EXISTS(p_inventory_item_id)
     THEN
         j := Item_Customer_Pointer(p_inventory_item_id);
         WHILE Item_Customer_hold(j).Entity_Id1 = p_inventory_item_id
         LOOP

             IF Item_Customer_Hold(j).Entity_Id2 = p_sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Item_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Item_Customer_Hold(j).activity_name,
                  p_attribute => 'Item\Customer',
                  p_top_model_line_id => p_top_model_line_id
                  );
                 IF Item_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Customer_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item Shipto Holds
     IF p_inventory_item_id IS NOT NULL AND
        p_ship_to_org_id IS NOT NULL AND
        Item_Shipto_Pointer.EXISTS(p_inventory_item_id)
     THEN
         j := Item_shipto_Pointer(p_inventory_item_id);
         WHILE Item_shipto_hold(j).Entity_Id1 = p_inventory_item_id
         LOOP

             IF Item_shipto_Hold(j).Entity_Id2 = p_ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Item_shipto_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Item_shipto_Hold(j).activity_name,
                  p_attribute => 'Item\Ship to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
                 IF Item_shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_shipto_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Item BillTo Holds
     IF p_inventory_item_id IS NOT NULL AND
        p_invoice_to_org_id IS NOT NULL AND
        Item_Billto_Pointer.EXISTS(p_inventory_item_id)
     THEN
         j := Item_billto_Pointer(p_inventory_item_id);
         WHILE Item_billto_hold(j).Entity_Id1 = p_inventory_item_id
         LOOP

             IF Item_billto_Hold(j).Entity_Id2 = p_invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Item_billto_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Item_billto_Hold(j).activity_name,
                  p_attribute => 'Item\Bill to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
                 IF Item_billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_billto_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     <<Just_WareHouse_Holds>>

     -- Check Item Warehouse Holds
     IF p_inventory_item_id IS NOT NULL AND
        p_ship_from_org_id IS NOT NULL AND
        Item_Warehouse_Pointer.EXISTS(p_inventory_item_id)
     THEN
         j := Item_Warehouse_Pointer(p_inventory_item_id);
         WHILE Item_Warehouse_hold(j).Entity_Id1 = p_inventory_item_id
         LOOP

             IF Item_Warehouse_Hold(j).Entity_Id2 = p_ship_from_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Item_Warehouse_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Item_Warehouse_Hold(j).activity_name,
                  p_attribute => 'Item\Warehouse',
                  p_top_model_line_id => p_top_model_line_id
                  );
                 IF Item_Warehouse_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                 ELSIF Item_Warehouse_Hold(j).activity_name = 'LINE_SCHEDULING'
                 THEN
                    p_on_scheduling_hold := TRUE;
                 END IF;

             END IF;
             j := j + 1;

             IF j > Item_Warehouse_hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Hold
     IF p_ship_from_org_id IS NOT NULL AND
        Warehouse_Pointer.EXISTS(p_ship_from_org_id)
     THEN
         j := Warehouse_Pointer(p_ship_from_org_id);
         WHILE Warehouse_hold(j).Entity_Id1 = p_ship_from_org_id
         LOOP
            Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Warehouse_hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Warehouse_hold(j).activity_name,
                  p_attribute => 'Warehouse',
                  p_top_model_line_id => p_top_model_line_id
                  );
            IF Warehouse_hold(j).activity_name IS NULL THEN
               p_on_generic_hold := TRUE;
            ELSIF Warehouse_hold(j).activity_name = 'LINE_SCHEDULING' THEN
               p_on_scheduling_hold := TRUE;
            END IF;
            j := j+1;
            IF j > Warehouse_Hold.COUNT THEN
                EXIT;
            END IF;

         END LOOP;

     END IF;

     -- Check Warehouse Customer Holds
     IF p_ship_from_org_id IS NOT NULL AND
        p_sold_to_org_id IS NOT NULL AND
        Warehouse_Customer_Pointer.EXISTS(p_ship_from_org_id)
     THEN
         j := Warehouse_Customer_Pointer(p_ship_from_org_id);
         WHILE Warehouse_Customer_Hold(j).Entity_Id1 = p_ship_from_org_id
         LOOP

             IF Warehouse_Customer_Hold(j).Entity_Id2 = p_sold_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id =>Warehouse_Customer_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Warehouse_Customer_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Customer',
                  p_top_model_line_id => p_top_model_line_id
                  );
                IF Warehouse_Customer_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_Customer_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_Customer_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse Shipto Holds
     IF p_ship_from_org_id IS NOT NULL AND
        p_ship_to_org_id IS NOT NULL AND
        Warehouse_shipto_pointer.EXISTS(p_ship_from_org_id)
     THEN
         j := Warehouse_shipto_pointer(p_ship_from_org_id);
         WHILE Warehouse_shipto_Hold(j).Entity_Id1 = p_ship_from_org_id
         LOOP

             IF Warehouse_shipto_Hold(j).Entity_Id2 = p_ship_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Warehouse_shipto_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Warehouse_shipto_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Ship to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
                IF Warehouse_shipto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_shipto_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_shipto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

     -- Check Warehouse BillTo Holds
     IF p_ship_from_org_id IS NOT NULL AND
        p_invoice_to_org_id IS NOT NULL AND
        Warehouse_billto_pointer.EXISTS(p_ship_from_org_id)
     THEN
         j := Warehouse_billto_pointer(p_ship_from_org_id);
         WHILE Warehouse_billto_Hold(j).Entity_Id1 = p_ship_from_org_id
         LOOP

             IF Warehouse_billto_Hold(j).Entity_Id2 = p_invoice_to_org_id
             THEN
                 Mark_Hold(p_header_id => p_header_id,
                  p_line_id => p_line_id,
                  p_line_number => p_line_number,
                  p_hold_source_id => Warehouse_billto_Hold(j).hold_source_id,
                  p_ship_set_name => p_ship_set_name,
                  p_arrival_set_name => p_arrival_set_name,
                  p_activity_name => Warehouse_billto_Hold(j).activity_name,
                  p_attribute => 'Warehouse\Bill to Site',
                  p_top_model_line_id => p_top_model_line_id
                  );
                IF Warehouse_billto_Hold(j).activity_name IS NULL THEN
                    p_on_generic_hold := TRUE;
                ELSIF Warehouse_billto_Hold(j).activity_name = 'LINE_SCHEDULING'
                THEN
                    p_on_scheduling_hold := TRUE;
                END IF;

             END IF;
             j := j + 1;

             IF j > Warehouse_billto_Hold.COUNT THEN
                 EXIT;
             END IF;

         END LOOP;
     END IF;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Evaluate_Holds'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Evaluate_Holds;

PROCEDURE Extend_Holds_Tbl
IS
BEGIN

  G_Hold_header_id.EXTEND;
  G_Hold_line_id.EXTEND;
  G_Hold_source_id.EXTEND;
  G_hold_ship_set.EXTEND;
  G_hold_arrival_set.EXTEND;
  G_hold_top_model_line_id.EXTEND;
  G_hold_activity_name.EXTEND;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Extend_Holds_Tbl'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Extend_Holds_Tbl;

PROCEDURE Create_Holds
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_org_id      number :=mo_global.get_current_org_id; --5488209
BEGIN

    IF l_debug_level > 0 THEN
        oe_debug_pub.add('No. of holds to create is '||G_Hold_header_id.COUNT);
        oe_debug_pub.add('No. of holds sources to create is '
                          ||g_hold_source_rec.HOLD_SOURCE_ID.COUNT);
    END IF;

    FORALL i IN 1..G_Hold_header_id.COUNT
    --added org_id in insert for bug 5488209
    INSERT INTO OE_ORDER_HOLDS
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    VALUES
   (    OE_ORDER_HOLDS_S.NEXTVAL
    ,   SYSDATE
    ,   NVL(FND_GLOBAL.USER_ID, -1)
    ,   SYSDATE
    ,   NVL(FND_GLOBAL.USER_ID, -1)
    ,   NULL
    ,   G_hold_source_id(i)
    ,   G_Hold_header_id(i)
    ,   G_Hold_line_id(i)
    ,   'N'
    ,   l_org_id
    );

  -- Clear the Globals.
  g_hold_header_id.DELETE;
  g_hold_line_id.DELETE;
  g_hold_Source_Id.DELETE;
  g_hold_ship_set.DELETE;
  g_hold_arrival_set.DELETE;
  g_hold_top_model_line_id.DELETE;
  g_hold_activity_name.DELETE;

  IF g_hold_source_rec.HOLD_SOURCE_ID.COUNT > 0 THEN
      FORALL i IN 1..g_hold_source_rec.HOLD_SOURCE_ID.COUNT
          --added org_id in insert for bug 5488209
          INSERT INTO OE_HOLD_SOURCES
          (  HOLD_SOURCE_ID
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , CREATION_DATE
           , CREATED_BY
           , LAST_UPDATE_LOGIN
           , PROGRAM_APPLICATION_ID
           , PROGRAM_ID
           , PROGRAM_UPDATE_DATE
           , REQUEST_ID
           , HOLD_ID
           , HOLD_ENTITY_CODE
           , HOLD_ENTITY_ID
           , HOLD_UNTIL_DATE
           , RELEASED_FLAG
	   , ORG_ID
          )
     VALUES
          (  g_hold_source_rec.hold_source_id(i)
           , sysdate
           , NVL(FND_GLOBAL.USER_ID, -1)
           , sysdate
           , NVL(FND_GLOBAL.USER_ID, -1)
           , NULL
           , NULL
           , NULL
           , NULL
           , NULL
           , g_hold_source_rec.HOLD_ID(i)
           , g_hold_source_rec.HOLD_ENTITY_CODE(i)
           , g_hold_source_rec.HOLD_ENTITY_ID(i)
           , NULL
           , 'N'
	   , l_org_id
           );

          g_hold_source_rec.HOLD_ID.DELETE;
          g_hold_source_rec.HOLD_SOURCE_ID.DELETE;
          g_hold_source_rec.HOLD_ENTITY_CODE.DELETE;
          g_hold_source_rec.HOLD_ENTITY_ID.DELETE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('In OTHERS error ' || SUBSTR(sqlerrm,1,240), 1);
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Create_Holds'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Create_Holds;

PROCEDURE Mark_Hold(p_header_id IN NUMBER,
                    p_line_id IN NUMBER,
                    p_line_number IN NUMBER,
                    p_hold_source_id IN NUMBER,
                    p_ship_set_name IN VARCHAR2,
                    p_arrival_set_name IN VARCHAR2,
                    p_activity_name IN VARCHAR2,
                    p_attribute IN VARCHAR2,
                    p_top_model_line_id IN NUMBER
                    )
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  i BINARY_INTEGER;
BEGIN

    i := G_Hold_header_id.COUNT;
    Extend_Holds_Tbl;

    G_Hold_header_id(i+1) := p_header_id;
    G_Hold_line_id(i+1) := p_line_id;
    G_Hold_source_id(i+1) := p_hold_source_id;
    G_Hold_ship_set(i+1) := p_ship_set_name;
    G_Hold_arrival_set(i+1) := p_arrival_set_name;
    G_Hold_top_model_line_id(i+1) := p_top_model_line_id;
    G_Hold_activity_name(i+1) := p_activity_name;

    IF p_line_id IS NULL THEN
        FND_MESSAGE.SET_NAME('ONT','OE_HLD_APPLIED');
    ELSE
        FND_MESSAGE.SET_NAME('ONT','OE_HLD_APPLIED_LINE');
        FND_MESSAGE.SET_TOKEN('LINE_NUMBER',p_line_number);
    END IF;
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',p_attribute);
    OE_BULK_MSG_PUB.ADD;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('In OTHERS error - Mark_Hold ' ||
                          SUBSTR(sqlerrm,1,240), 1);
    END IF;
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Mark_Hold'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Mark_Hold;

FUNCTION Is_Header_On_Hold(
p_header_id         IN NUMBER,
p_hold_index        IN OUT NOCOPY NUMBER
) RETURN BOOLEAN
IS
i        NUMBER;
l_old_header_id  NUMBER;
BEGIN

    IF g_hold_header_id.COUNT > 0 THEN

        IF p_hold_index IS NULL THEN
           p_hold_index := 1;
        END IF;

        l_old_header_id := g_hold_header_id(p_hold_index);

        FOR i IN p_hold_index..g_hold_header_id.COUNT LOOP

            -- IF there are NO Header Level Holds
            IF g_hold_line_id(i) IS NOT NULL THEN
                RETURN FALSE;
            END IF;

            -- Since the search is a linear one with incremental header_id
            IF g_hold_header_id(i) > p_header_id THEN
                RETURN  FALSE;
            END IF;

            IF g_hold_header_id(i) <> l_old_header_id THEN
               p_hold_index := i;
            END IF;

            IF p_header_id = g_hold_header_id(i) AND
               g_hold_activity_name(i) IS NULL THEN
                RETURN TRUE;
            END IF;
            l_old_header_id := g_hold_header_id(i);

        END LOOP;

    END IF;

    RETURN FALSE;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Is_Header_On_Hold'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Is_Header_On_Hold;

FUNCTION Is_Line_On_Hold(
p_header_id         IN NUMBER,
p_line_id           IN NUMBER,
p_top_model_line_id IN NUMBER,
p_ship_set_name     IN VARCHAR2,
p_arrival_set_name  IN VARCHAR2,
p_hold_index        IN OUT NOCOPY NUMBER
) RETURN BOOLEAN
IS
i        BINARY_INTEGER;
l_old_header_id  NUMBER;
BEGIN

    IF g_hold_header_id.COUNT > 0 THEN

        i := 1;
        l_old_header_id := g_hold_header_id(p_hold_index);
        -- Check if the header is on hold
        WHILE g_hold_line_id(i) IS NULL LOOP
            IF p_header_id = g_hold_header_id(i) AND
               g_hold_activity_name(i) IS NULL THEN
                RETURN TRUE;
            END IF;
            i := i+1;

            IF i > g_hold_header_id.COUNT THEN
                RETURN FALSE;
            END IF;

        END LOOP;

        -- Header is not on HOLD.

        IF p_hold_index IS NULL THEN

            IF i <= g_hold_header_id.COUNT THEN
                p_hold_index := i;
            END IF;

            -- IF there are no lines on hold then
            IF p_hold_index IS NULL THEN
                RETURN FALSE;
            END IF;

        END IF;

        IF p_header_id > g_hold_header_id(g_hold_header_id.LAST) THEN
            RETURN FALSE;
        END IF;

        l_old_header_id := g_hold_header_id(p_hold_index);

        FOR i IN p_hold_index..g_hold_header_id.COUNT LOOP

            -- Since the search is a linear one with incremental header_id
            IF g_hold_header_id(i) > p_header_id THEN
                RETURN  FALSE;
            END IF;

            IF g_hold_header_id(i) <> l_old_header_id THEN
               p_hold_index := i;
            END IF;

            -- Check if there is a Match
            IF p_header_id = g_hold_header_id(i) AND
            (p_top_model_line_id = g_hold_top_model_line_id(i) OR
             p_ship_set_name = g_hold_ship_set(i) OR
             p_arrival_set_name = g_hold_arrival_set(i)) AND
             g_hold_activity_name(i) IS NULL
            THEN
                RETURN TRUE;
            END IF;

            l_old_header_id := g_hold_header_id(i);

        END LOOP;
    END IF;

    RETURN FALSE;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  WHEN OTHERS THEN
    OE_BULK_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
        ,   'Is_Line_On_Hold'
        );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Is_Line_On_Hold;

PROCEDURE Apply_GSA_Hold(p_header_id IN NUMBER,
                    p_line_id IN NUMBER,
                    p_line_number IN NUMBER,
                    p_hold_id IN NUMBER,
                    p_ship_set_name IN VARCHAR2,
                    p_arrival_set_name IN VARCHAR2,
                    p_activity_name IN VARCHAR2,
                    p_attribute IN VARCHAR2,
                    p_top_model_line_id IN NUMBER,
                    x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2    --bug 3735141
                    )
IS
i  BINARY_INTEGER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check the count of the Global Table for Hold Source Rec
    i := g_hold_source_rec.HOLD_ID.COUNT;

    -- Assign memory
    Extend_Hold_Source_Rec;

    g_hold_source_rec.HOLD_ID(i+1) := p_hold_id;

    -- Get the Hold Source Id
    SELECT  OE_HOLD_SOURCES_S.NEXTVAL
    INTO g_hold_source_rec.HOLD_SOURCE_ID(i+1)
    FROM DUAL;

    g_hold_source_rec.HOLD_ENTITY_CODE(i+1) := 'O';
    g_hold_source_rec.HOLD_ENTITY_ID(i+1) := p_header_id; --bug 3716296
    -- passing header_id as hold_entity_id instead of line_id

    Mark_Hold(p_header_id => p_header_id,
              p_line_id => p_line_id,
              p_line_number => NULL,
              p_hold_source_id => g_hold_source_rec.HOLD_SOURCE_ID(i+1),
              p_ship_set_name => NULL,
              p_arrival_set_name => NULL,
              p_activity_name => NULL,
              p_attribute => 'GSA PRICE Violation',
              p_top_model_line_id => p_top_model_line_id
              );

--bug 3735141
EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level > 0 THEN
        oe_debug_pub.add('In OTHERS error - Apply GSA Hold ' ||
                          SUBSTR(sqlerrm,1,240), 1);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--bug 3735141

END Apply_GSA_Hold;

PROCEDURE Extend_Hold_Source_Rec
IS
BEGIN
    g_hold_source_rec.HOLD_ID.EXTEND;
    g_hold_source_rec.HOLD_SOURCE_ID.EXTEND;
    g_hold_source_rec.HOLD_ENTITY_CODE.EXTEND;
    g_hold_source_rec.HOLD_ENTITY_ID.EXTEND;
END Extend_Hold_Source_Rec;

------------------------------------------------------------------------
-- FUNCTION Check_for_Holds
-- This API is called by scheduling
--
-- Checks if there are any holds on the order or order line. If
-- order line, then checks for holds on the order that it belongs to.
-- If ATO line, then checks for holds on other lines belonging to the
-- same ATO model. If SMC line, then checks for other lines in the SMC.
-- If included item line then checks for hold on its immediate parent
-- if included item flag is set appropriately in the hold definition.
------------------------------------------------------------------------
FUNCTION Check_For_Holds(p_header_id IN NUMBER,
                         p_line_id IN NUMBER,
                         p_line_index IN NUMBER,
                         p_header_index IN NUMBER,
                         p_top_model_line_index IN NUMBER,
                         p_ship_model_complete_flag IN VARCHAR2,
                         p_ato_line_index IN NUMBER,
                         p_ii_parent_line_index IN NUMBER
                        ) RETURN BOOLEAN
IS

l_result BOOLEAN;
l_header_hold_index BINARY_INTEGER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'IN OE_BULK_HOLDS_PVT.Check_For_Holds');
    oe_debug_pub.add(  'p_line_index is '||p_line_index);
  END IF;

  -- Initialize API return value to False
  l_result := FALSE;

-- First Check if the line is on generic HOLD
  IF G_Line_Holds_Tbl.EXISTS(p_line_index) THEN
    IF G_Line_Holds_Tbl(p_line_index).On_Generic_Hold = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'Line on Generic Hold' ||p_line_id ) ;
      END IF;
      RETURN TRUE;

    END IF;
  END IF;

  -- Check if the header is on HOLD.
  l_result := Is_Header_On_Hold(p_header_id => p_header_id ,
                                 p_hold_index => l_header_hold_index );

  IF l_result THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( 'HEADER LEVEL HOLD EXISTS' ) ;
      END IF;
      RETURN l_result;
  END IF;

  -- Check if the line is part of an ATO model.
  IF p_ato_line_index IS NOT NULL AND
     p_top_model_line_index IS NOT NULL
  THEN
      -- Check if the ato_line has been marked for Hold.
      IF G_Line_Holds_Tbl.EXISTS(p_ato_line_index) THEN
        IF G_Line_Holds_Tbl(p_ato_line_index).Any_ato_line_on_hold = 'Y' THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'Line is part of ATO model and one of the lines
is on Generic Hold') ;
          END IF;
          RETURN TRUE;
        END IF;
      END IF;
  END IF;

 -- Check if the line is part of an SMC Model or Kit-included items.
  IF p_top_model_line_index IS NOT NULL AND
     p_ship_model_complete_flag = 'Y'
  THEN
      -- Check if the Top Model line has been marked for Hold.
      IF G_Line_Holds_Tbl.EXISTS(p_top_model_line_index) THEN
        IF G_Line_Holds_Tbl(p_top_model_line_index).Any_SMC_Line_on_hold = 'Y'
        THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'Line is part of SMC model and one of the lines
is on Generic Hold') ;
          END IF;
          RETURN TRUE;
        END IF;
      END IF;
  END IF;

  -- Check if the line is an included item line.
  IF p_ii_parent_line_index IS NOT NULL THEN
      -- Check if the parent is on generic hold and hold source says that put
      -- included items also on hold
      IF G_Line_Holds_Tbl.EXISTS(p_ii_parent_line_index) THEN

        IF G_Line_Holds_Tbl(p_ii_parent_line_index).On_Generic_Hold = 'Y' AND
           G_Line_Holds_Tbl(p_ii_parent_line_index).hold_ii_flag = 'Y'
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'II Parent line is on Generic Hold') ;
          END IF;
          RETURN TRUE;
        END IF;
      END IF;
  END IF;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'Exiting OE_BULK_HOLDS_PVT.Check_For_Holds');
  END IF;
  RETURN FALSE;

EXCEPTION
    WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'In others of OE_BULK_HOLDS_PVT.Check_For_Holds');
  END IF;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_For_Holds'
            );
        END IF;

END Check_For_Holds;

END OE_Bulk_Holds_PVT;

/
