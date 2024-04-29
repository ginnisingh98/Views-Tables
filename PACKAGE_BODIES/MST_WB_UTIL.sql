--------------------------------------------------------
--  DDL for Package Body MST_WB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_WB_UTIL" AS
/* $Header: MSTWUTLB.pls 120.1 2005/05/27 05:21:30 appldev  $ */
   --TYPE NUM_LIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   G_Time_delim CONSTANT VARCHAR2(1) := ':';
   --G_delim      CONSTANT VARCHAR2(1) := '#';

   --ORGANIZATION CONSTANT NUMBER := 1;
   --CUSTOMER CONSTANT NUMBER :=2;
   --CARRIER CONSTANT NUMBER := 3;
   --SUPPLIER CONSTANT NUMBER := 4;

   --TRUCK    CONSTANT VARCHAR2(5) := 'TRUCK';  -- TRUCK
   --DTL      CONSTANT VARCHAR2(3) := 'DTL';    -- Direct TL
   --MTL      CONSTANT VARCHAR2(3) := 'MTL';    -- Multistop TL
   --LTL      CONSTANT VARCHAR2(3) := 'LTL';    -- LESS THAN TRUCK
   --PARCEL   CONSTANT VARCHAR2(6) := 'PARCEL'; -- PARCEL

--Bug_Fix for 4394839
  FUNCTION get_company_type ( p_facility_id IN NUMBER )
  RETURN VARCHAR2
  IS
	l_Partner_Info VARCHAR2 ( 30 );
	l_Partner_Id NUMBER;
	l_Partner_Type NUMBER;
	l_partner_type_str VARCHAR2 ( 60 );
    l_Len NUMBER;
    l_Pos NUMBER;
    l_Delimiter VARCHAR2 ( 1 ) := ',';
  BEGIN
    l_Partner_Info := MST_WB_UTIL.Get_Facility_Owner ( p_Facility_Id, l_Delimiter );
    l_Len := LENGTH ( l_Partner_Info );

	IF l_Len > 3
	THEN
      l_Pos := instrb ( l_Partner_Info, l_Delimiter );
      l_Partner_Id := TO_NUMBER ( substrb ( l_Partner_Info, 1, ( l_Pos - 1 ) ) );
      l_Partner_Type := TO_NUMBER ( substrb ( l_Partner_Info, ( l_Pos + 1 ), l_Len ) );
    END IF;

	IF l_Partner_Id IS NOT NULL AND l_Partner_Type IS NOT NULL
	THEN
      IF l_Partner_Type = 1
      THEN -- Organization
		l_partner_type_str := fnd_profile.value ( 'MST_COMPANY_NAME' );
      ELSIF l_Partner_Type = 2
      THEN -- Customer
        l_partner_type_str := 'CUSTOMER';
      ELSIF l_Partner_Type = 3
      THEN -- Carrier
        l_partner_type_str := 'CARRIER';
      ELSIF l_Partner_Type = 4
      THEN -- Supplier
        l_partner_type_str := 'SUPPLIER';
      ELSE
      	l_partner_type_str := '';
      END IF;
    ELSE
      l_partner_type_str := '';
    END IF;

    RETURN l_partner_type_str;
  EXCEPTION
    WHEN OTHERS
    THEN
        l_partner_type_str := '';
        RETURN l_partner_type_str;
  END get_company_type;

  FUNCTION get_format_string ( p_format_type IN VARCHAR2 )
  RETURN VARCHAR2
  IS
--  Format for numbers
    NUMBER_FORMAT CONSTANT VARCHAR2 ( 24 ) := 'FM999G999G999G990';
  BEGIN
    IF ( p_format_type = 'NUMBER' )
    THEN
      RETURN ( NUMBER_FORMAT );
    ELSE
      RETURN ( NULL );
    END IF;
  END get_format_string;

   FUNCTION get_total_order_weight( p_plan_id IN NUMBER,
                                    p_source_code IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER IS

      L_Weight NUMBER;
   BEGIN
      -- Used in MyFacility Details UI
      SELECT NVL(sum(mdd.Gross_weight),0)
      INTO   l_weight
      FROM  mst_delivery_details mdd
      WHERE mdd.plan_id = p_plan_id
      AND   mdd.source_code = p_source_code
      AND   mdd.source_header_number = p_source_header_number;

      RETURN l_weight;

   EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
   END get_total_order_weight;

   FUNCTION get_total_order_volume( p_plan_id IN NUMBER,
                                    p_source_code IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER IS

      l_volume NUMBER;
   BEGIN
      -- Used in MyFacility Details UI
      SELECT NVL(sum(mdd.volume),0)
      INTO   l_volume
      FROM  mst_delivery_details mdd
      WHERE mdd.plan_id = p_plan_id
      AND   mdd.source_code = p_source_code
      AND   mdd.source_header_number = p_source_header_number;

      RETURN l_volume;
   EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
   END get_total_order_volume;

   FUNCTION get_total_order_pallets(p_plan_id IN NUMBER,
                                    p_source_code IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER IS

      l_pallets NUMBER;

   BEGIN
      -- Used in MyFacility Details UI
      SELECT NVL(sum(mdd.number_of_pallets),0)
      INTO   l_pallets
      FROM  mst_delivery_details mdd
      WHERE mdd.plan_id = p_plan_id
      AND   mdd.source_code = p_source_code
      AND   mdd.source_header_number = p_source_header_number;

      RETURN l_pallets;
   EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
   END get_total_order_pallets;

   FUNCTION get_total_order_pieces( p_plan_id IN NUMBER,
                                    p_source_code IN VARCHAR2,
                                    p_source_header_number IN VARCHAR2)
      RETURN NUMBER IS

      l_pieces NUMBER;

   BEGIN
      -- Used in MyFacility Details UI
      SELECT NVL(sum(mdd.requested_quantity),0)
      INTO  l_pieces
      FROM  mst_delivery_details mdd
      WHERE mdd.plan_id = p_plan_id
      AND   mdd.source_code = p_source_code
      AND   mdd.source_header_number = p_source_header_number;

      RETURN l_pieces;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
   END get_total_order_pieces;


   FUNCTION get_total_order_cost ( p_plan_id              IN NUMBER,
                                   p_source_code          IN VARCHAR2,
                                   p_source_header_number IN VARCHAR2)
      RETURN NUMBER IS

      l_cost NUMBER := 0;

   BEGIN
      -- Used in MyFacility Details UI
      SELECT NVL(sum(MDD.ALLOCATED_COST),0)
      INTO  l_cost
      FROM mst_delivery_details mdd
      WHERE   mdd.plan_id              = p_plan_id
      AND     mdd.source_code          = p_source_code
      AND     mdd.source_header_number = p_source_header_number;

      RETURN l_cost;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
   END get_total_order_cost;

  FUNCTION Get_Trip_Circuity(P_Plan_id IN NUMBER,
                             P_Trip_id IN NUMBER)
    RETURN NUMBER IS

    CURSOR Cur_Circuity IS
    SELECT (T.Total_trip_distance/T.Total_direct_distance -1)*100
    FROM mst_trips T
    WHERE T.plan_id = p_plan_id
    AND   T.trip_id = p_trip_id;

    v_circuity NUMBER;
  BEGIN
    -- Used in Truckload Details UI
    OPEN cur_circuity;
    FETCH cur_circuity INTO v_circuity;
    CLOSE cur_circuity;
    IF v_circuity < 0 THEN
        v_circuity := 0;
    END IF;

    RETURN v_circuity;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return
       RETURN 0;
  END Get_Trip_Circuity;

  FUNCTION Get_Trip_Stops(P_Plan_id IN NUMBER,
                          P_Trip_id IN NUMBER)
      RETURN NUMBER IS

    CURSOR Cur_Trip_Stops IS
    SELECT COUNT(TS.Stop_Id)
    FROM mst_trip_stops TS
    WHERE TS.plan_id = p_plan_id
    AND   TS.trip_id = p_trip_id;

    V_Trip_Stops NUMBER;
  BEGIN
    -- Used in Truckload Details and CM Details UI
    OPEN Cur_Trip_Stops;
    FETCH Cur_Trip_Stops into V_Trip_Stops;
    CLOSE Cur_Trip_Stops;

    RETURN V_Trip_Stops;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return
       RETURN 0;
  END Get_Trip_Stops;

  FUNCTION Get_Trip_Orders(    p_plan_id IN NUMBER, p_trip_id IN NUMBER )
            RETURN NUMBER IS

    /*skakani - commented on 16-10-03 ...
    CURSOR cur_get_trip_orders is
    SELECT COUNT(DISTINCT dd.source_header_number)
    FROM  mst_delivery_details dd,
          mst_delivery_assignments da
    WHERE dd.plan_id = p_plan_Id
    AND   dd.delivery_detail_id = da.delivery_detail_id
    AND   dd.plan_id            = da.plan_id
    AND   da.delivery_id IN
            (SELECT dl.delivery_id
             FROM  mst_delivery_legs dl
             WHERE dl.plan_id = da.plan_id
             AND   dl.trip_id = p_trip_id);*/

    CURSOR cur_get_trip_orders is
    SELECT COUNT(distinct nvl(dd.split_from_delivery_detail_id,dd.delivery_detail_id))
    FROM  mst_delivery_details dd,
          mst_delivery_assignments da
    WHERE dd.plan_id = p_plan_Id
    AND   dd.delivery_detail_id = da.delivery_detail_id
    AND   dd.plan_id            = da.plan_id
    AND   da.delivery_id IN
            (SELECT dl.delivery_id
             FROM  mst_delivery_legs dl
             WHERE dl.plan_id = da.plan_id
             AND   dl.trip_id = p_trip_id)
    AND   da.parent_delivery_detail_id is null;

    V_Orders NUMBER;
  BEGIN
    -- Used in Truckload/LTL/PARCEL Details and CM Details UI
    OPEN Cur_Get_Trip_Orders ;
    FETCH Cur_Get_Trip_Orders into V_Orders;
    CLOSE Cur_Get_Trip_Orders;

    RETURN v_Orders;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return.
    RETURN 0;
  END Get_Trip_Orders;

  FUNCTION Get_Trip_Det(P_plan_id    IN NUMBER,
                        p_trip_id    IN NUMBER,
                        p_stop_id    IN NUMBER,
                        p_stop_type  IN VARCHAR2,
                        p_return_val IN VARCHAR2)
    RETURN NUMBER IS

    CURSOR Cur_Org_Stop_Det(pp_plan_id IN NUMBER,
                            pp_trip_id IN NUMBER,
                            pp_stop_id IN NUMBER ) IS
    SELECT NVL(SUM(d.gross_weight),0), NVL(SUM(d.volume),0),
           NVL(SUM(d.number_of_pallets),0),NVL(SUM(d.number_of_pieces),0)
    FROM mst_deliveries d
    WHERE d.plan_id = pp_plan_id
    AND   d.delivery_id IN
            (SELECT delivery_id
             FROM mst_delivery_legs dl,
                  mst_trip_stops ts
             WHERE dl.plan_id          = d.plan_id
             AND   dl.pick_up_stop_id  = ts.stop_id
             AND   ts.plan_id          = dl.plan_id
             AND   ts.stop_id          = pp_stop_id
             AND   ts.trip_id          = pp_trip_id);

    CURSOR cur_dest_stop_det(pp_plan_id in NUMBER,
                             pp_trip_id in NUMBER,
                             pp_stop_id in NUMBER ) IS
    SELECT NVL(SUM(d.gross_weight),0), NVL(SUM(d.volume),0),
           NVL(SUM(d.number_of_pallets),0), NVL(SUM(d.number_of_pieces),0)
    FROM mst_deliveries d
    WHERE d.plan_id = pp_plan_id
    AND   d.delivery_id IN
            (SELECT delivery_id
             FROM mst_delivery_legs dl,
                  mst_trip_stops ts
             WHERE dl.plan_id          = d.plan_id
             AND   dl.drop_off_stop_id = ts.stop_id
             AND   ts.plan_id          = dl.plan_id
             AND   ts.stop_id          = pp_stop_id
             AND   ts.trip_id          = pp_trip_id);

    V_Weight  NUMBER;
    V_Volume  NUMBER;
    V_Pallets NUMBER;
    V_Pieces  NUMBER;
  BEGIN
    -- Used in Truckload details UI
    IF P_Stop_Type = 'O' THEN
        OPEN Cur_Org_Stop_Det(P_Plan_id, P_Trip_id, P_Stop_id) ;
        FETCH Cur_Org_Stop_Det into V_Weight,  V_Volume,
                                    V_Pallets, V_Pieces;
        CLOSE Cur_Org_Stop_Det;
    ELSIF P_Stop_Type = 'D' THEN
        OPEN Cur_Dest_Stop_Det(P_Plan_id, P_Trip_id, P_Stop_id) ;
        FETCH Cur_Dest_Stop_Det into V_Weight,  V_Volume,
                                    V_Pallets, V_Pieces;
        CLOSE Cur_Dest_Stop_Det;
    END IF;

    IF P_Return_Val = 'W' THEN
        RETURN v_Weight;
    ELSIF P_Return_Val = 'V' THEN
        RETURN v_Volume;
    ELSIF P_Return_Val = 'P' THEN
        RETURN v_Pallets;
    ELSIF P_Return_Val = 'PC' THEN
        RETURN v_Pieces;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return.
    RETURN 0;
  END Get_Trip_Det;

  FUNCTION Get_Trip_Det(P_plan_id    IN NUMBER,
                        P_TRIP_ID    IN NUMBER,
                        P_Return_val IN VARCHAR2)
    RETURN NUMBER IS

    CURSOR Cur_Stop_Det(pp_plan_id IN NUMBER,PP_TRIP_ID IN NUMBER ) IS
    SELECT NVL(SUM(D.Gross_Weight),0), NVL(SUM(D.Volume),0),
           NVL(SUM(D.NUMBER_OF_Pallets),0), NVL(SUM(D.NUMBER_OF_PIECES),0)
    FROM MST_DELIVERIES D
    WHERE D.PLAN_ID = pp_plan_id
    AND   D.DELIVERY_ID IN
               (SELECT DL.DELIVERY_ID
                FROM MST_DELIVERY_LEGS DL
                WHERE DL.plan_id = d.plan_id
                AND   dl.Trip_id = PP_Trip_Id);

    V_Weight  NUMBER;
    V_Volume  NUMBER;
    V_Pallets NUMBER;
    V_Pieces  NUMBER;
  BEGIN
  -- Used in LTL/PARCEL Details and CM Details UI
        OPEN Cur_Stop_Det(P_Plan_id, P_Trip_id ) ;
        FETCH Cur_Stop_Det into V_Weight,  V_Volume,
                                V_Pallets, V_Pieces;
        CLOSE Cur_Stop_Det;


    IF P_Return_Val = 'W' THEN
        RETURN v_Weight;
    ELSIF P_Return_Val = 'V' THEN
        RETURN v_Volume;
    ELSIF P_Return_Val = 'P' THEN
        RETURN v_Pallets;
    ELSIF P_Return_Val = 'PC' THEN
        RETURN v_Pieces;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return.
    RETURN 0;
  END Get_Trip_Det;

  FUNCTION Get_Stop_Orders( P_plan_id IN NUMBER,
                            P_TRIP_ID IN NUMBER,
                            P_STOP_ID IN NUMBER )
    RETURN NUMBER IS

    /*CURSOR Cur_Get_Trip_Stop_Orders IS
    SELECT COUNT(DISTINCT mdd.source_header_number)
    FROM mst_delivery_details mdd
    WHERE mdd.plan_id = p_plan_id
    AND   mdd.delivery_detail_id IN
                ( SELECT mda.delivery_detail_id
                  FROM mst_deliveries md,
                       mst_delivery_assignments mda,
                       mst_delivery_legs mdl
                  WHERE mda.plan_id = mdd.plan_id
                  AND   mda.plan_id = md.plan_id
                  AND   mda.delivery_id = md.delivery_id
                  AND   md.plan_id = mdl.plan_id
                  AND   md.delivery_id = mdl.delivery_id
                  AND   mdl.trip_id = p_trip_id
                  AND   (   mdl.pick_up_stop_id = p_stop_id
                         OR mdl.drop_off_stop_id = p_stop_id));*/

    CURSOR get_stop_det IS
    SELECT stop_sequence_number
    FROM mst_trip_stops
    WHERE plan_Id = p_plan_Id
    AND   trip_id = p_trip_id
    AND   stop_id = p_stop_id;

    /*CURSOR Cur_Get_Trip_Stop_Orders is
    SELECT COUNT(mdd.delivery_detail_id)
    FROM  mst_delivery_details mdd
    WHERE mdd.plan_id = p_plan_Id
    AND   mdd.delivery_detail_id IN
                ( SELECT mda.delivery_detail_id
                  FROM mst_delivery_assignments mda,
                       mst_delivery_legs mdl
                  WHERE mda.plan_id = mdd.plan_id
                  AND   mda.plan_id = mdl.plan_id
                  AND   mda.delivery_id = mdl.delivery_id
                  AND   mdl.trip_id = p_trip_id
                  AND   mdl.pick_up_stop_id = p_stop_id;*/

    CURSOR Cur_Get_pick_Orders(p_stop_sequence NUMBER) is
    SELECT COUNT(distinct nvl(mdd.split_from_delivery_detail_id,mdd.delivery_detail_id))
    FROM  mst_delivery_details mdd
    WHERE mdd.plan_id = p_plan_Id
    AND   mdd.delivery_detail_id IN
                ( SELECT mda.delivery_detail_id
                  FROM mst_delivery_assignments mda,
                       mst_delivery_legs mdl
                  WHERE mda.plan_id = mdd.plan_id
                  AND   mda.plan_id = mdl.plan_id
                  AND   mda.delivery_id = mdl.delivery_id
                  AND   mda.parent_delivery_detail_id is null
                  AND   mdl.trip_id = p_trip_id
                  AND   mdl.pick_up_stop_id IN
                          (SELECT mts1.stop_id
                           FROM mst_trip_stops mts1
                           WHERE mts1.plan_id = mdl.plan_Id
                           AND   mts1.trip_id = mdl.trip_id
                           AND   mts1.stop_sequence_number <= p_stop_sequence));

    CURSOR Cur_Get_drop_Orders(p_stop_sequence NUMBER) is
    SELECT COUNT(distinct nvl(mdd.split_from_delivery_detail_id,mdd.delivery_detail_id))
    FROM  mst_delivery_details mdd
    WHERE mdd.plan_id = p_plan_Id
    AND   mdd.delivery_detail_id IN
                ( SELECT mda.delivery_detail_id
                  FROM mst_delivery_assignments mda,
                       mst_delivery_legs mdl
                  WHERE mda.plan_id = mdd.plan_id
                  AND   mda.plan_id = mdl.plan_id
                  AND   mda.delivery_id = mdl.delivery_id
                  AND   mda.parent_delivery_detail_id is null
                  AND   mdl.trip_id = p_trip_id
                  AND   mdl.drop_off_stop_id IN
                          (SELECT mts1.stop_id
                           FROM mst_trip_stops mts1
                           WHERE mts1.plan_id = mdl.plan_Id
                           AND   mts1.trip_id = mdl.trip_id
                           AND   mts1.stop_sequence_number <= p_stop_sequence));

    l_stop_info get_stop_det%ROWTYPE;
    l_pick_orders NUMBER;
    l_drop_orders NUMBER;
    V_Orders Number := 0;
  BEGIN
    -- Used in Truckload Details UI
    /*
    OPEN Cur_Get_Trip_Stop_Orders ;
    FETCH Cur_Get_Trip_Stop_Orders INTO V_Orders;
    CLOSE Cur_Get_Trip_Stop_Orders;
    */
    OPEN get_stop_det;
    FETCH get_stop_det INTO l_stop_info;
    CLOSE get_stop_det;

    IF l_stop_info.stop_sequence_number IS NOT NULL THEN
        OPEN Cur_Get_pick_Orders(l_stop_info.stop_sequence_number);
        FETCH Cur_Get_pick_Orders INTO l_pick_orders;
        CLOSE Cur_Get_pick_Orders;
        OPEN Cur_Get_drop_Orders(l_stop_info.stop_sequence_number);
        FETCH Cur_Get_drop_Orders INTO l_drop_orders;
        CLOSE Cur_Get_drop_Orders;
        v_orders := NVL(l_pick_orders,0) - NVL(l_drop_orders,0);
    END IF;
    RETURN v_Orders;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return.
    RETURN 0;
  End Get_STOP_Orders;

  FUNCTION GET_DELIVERY_ORDERS( P_PLAN_ID       IN NUMBER,
                                P_DELIVERY_ID   IN NUMBER,
                                P_DELIVERY_FLAG IN VARCHAR2 )
    RETURN NUMBER IS

    CURSOR Cur_Get_Orders IS
     Select Count(distinct nvl(DD.split_from_delivery_Detail_id,DD.Delivery_Detail_Id))
     FROM Mst_Delivery_Details DD,
          Mst_Delivery_Assignments DA
     WHERE DD.PLAN_ID            = DA.PLAN_ID
     AND   DD.Delivery_Detail_Id = DA.Delivery_Detail_Id
     AND   DA.parent_delivery_detail_id is null
     AND   DA.Delivery_Id        = p_delivery_id
     AND   DA.plan_id = p_plan_id;

    V_Orders NUMBER;
   BEGIN
    -- Used in Truckload Details UI
    OPEN Cur_Get_Orders ;
    FETCH Cur_Get_Orders into V_Orders;
    CLOSE Cur_Get_Orders;

    RETURN v_Orders;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return.
    RETURN 0;
  END GET_DELIVERY_ORDERS;

  FUNCTION Get_Name(P_Location_id IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR CUR_COMPANY_NAME( P_PARTY_ID IN NUMBER ) IS
    SELECT HZP.PARTY_NAME
    FROM HZ_PARTIES HZP
    WHERE HZP.PARTY_ID = P_party_id;

    CURSOR chk_owner_info(p_location_id IN NUMBER) IS
    SELECT wlo.OWNER_TYPE, wlo.OWNER_PARTY_ID
    FROM wsh_location_owners wlo
    WHERE wlo.wsh_location_id = p_location_id;

    CURSOR chk_cust_site(p_location_id IN NUMBER, p_owner_party_id IN NUMBER) IS
    SELECT 1
    FROM hz_cust_acct_sites_all hzcasa,
         hz_party_sites hzps,
         hz_cust_accounts hzc
    WHERE hzc.party_id = hzps.party_id
    AND   hzps.location_id = p_location_id
    AND   hzps.party_site_id = hzcasa.party_site_id
    AND   hzcasa.cust_account_id = hzc.cust_account_id
    AND   hzps.party_id = p_owner_party_id;
    --AND   HZCASA.SHIP_TO_FLAG in ('P', 'Y');
    l_owner_type NUMBER;
    l_owner_party_id NUMBER;

    l_Name VARCHAR2(360);
    l_dummy NUMBER;

  BEGIN
    -- Used in Truckload/LTL/PARCEL/CM/CUSTOMER/SUPPLIER/MYFACILITY/CARRIER Details UI
    FOR rec_owner IN chk_owner_info(P_Location_id) LOOP
        l_owner_type := rec_owner.owner_type;
        l_owner_party_id := rec_owner.owner_party_id;
        IF l_owner_type = 2 THEN
            OPEN chk_cust_site(p_location_id, l_owner_party_id);
            FETCH chk_cust_site INTO l_dummy;
            IF chk_cust_site%FOUND THEN
                CLOSE chk_cust_site;
                EXIT;
            END IF;
            CLOSE chk_cust_site;
        ELSE
            IF chk_owner_info%rowcount > 1 THEN
                RAISE too_many_rows;
            END IF;
        END IF;
    END LOOP;

    IF l_owner_type = 1 THEN
        l_name := fnd_profile.value('MST_COMPANY_NAME');
    ELSE
        OPEN CUR_COMPANY_NAME(l_owner_party_ID);
        FETCH CUR_COMPANY_NAME INTO l_Name;
        CLOSE CUR_COMPANY_NAME;
    END IF;

    RETURN l_Name;
  EXCEPTION
    WHEN too_many_rows THEN
        l_name := Get_meaning('MST_STRING','33','MFG');
        RETURN L_NAME;
    WHEN OTHERS THEN
    -- Nothing to return
        RETURN NULL;
  END Get_Name;

  FUNCTION Get_meaning( p_Lookup_Type IN VARCHAR2,
                        p_Lookup_Code IN VARCHAR2,
                        p_Product     IN VARCHAR2)
      RETURN VARCHAR2 IS

   CURSOR Ml_Cur IS
   SELECT Meaning
   FROM MFG_Lookups
   WHERE Lookup_Code = P_Lookup_Code
   AND   Lookup_Type = P_Lookup_Type;

   CURSOR Wl_Cur Is
   SELECT Meaning
   FROM Wsh_Lookups
   WHERE Lookup_Code = P_Lookup_Code
   AND   Lookup_Type = P_Lookup_Type;

   l_meaning VARCHAR2(80);

   Invalid_Lookup EXCEPTION;

  BEGIN
    -- Used in Truckload/LTL/PARCEL/CM Details UI
    IF P_PRODUCT = 'MFG' THEN
        OPEN Ml_Cur;
        FETCH Ml_Cur INTO l_Meaning;
        IF Ml_Cur%NOTFOUND THEN
            CLOSE Ml_Cur;
            RAISE Invalid_Lookup;
        END IF;
        CLOSE Ml_Cur;
    ELSIF p_Product = 'WSH' THEN
        OPEN Wl_Cur;
        FETCH Wl_Cur INTO l_Meaning;
        IF Wl_Cur%NOTFOUND THEN
            CLOSE Wl_Cur;
            RAISE Invalid_Lookup;
        END IF;
        CLOSE Wl_Cur;
    END IF;
   RETURN l_Meaning;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END Get_meaning;

  FUNCTION Get_Partner_Name(P_PARTY_id IN Number, P_PARTY_TYPE IN Number)
      RETURN VARCHAR2 IS

    CURSOR CUR_PARTY_NAME( P_PARTY_ID IN NUMBER ) IS
    SELECT HZP.PARTY_NAME
    FROM HZ_PARTIES HZP, HZ_CUST_ACCOUNTS HCA
    WHERE HCA.CUST_ACCOUNT_ID = P_party_id
    AND HCA.PARTY_ID = HZP.PARTY_ID;

    CURSOR CUR_VENDOR_NAME( P_PARTY_ID IN NUMBER ) IS
    SELECT VENDOR_NAME
    FROM PO_VENDORS pov
    WHERE pov.VENDOR_ID = p_PARTY_ID;

    l_name VARCHAR2(360);
  BEGIN
    IF  p_party_type = 1 THEN
      OPEN CUR_PARTY_NAME(P_PARTY_id);
      FETCH CUR_PARTY_NAME INTO l_name;
      CLOSE CUR_PARTY_NAME;
    ELSIF p_party_type = 2 THEN
      OPEN CUR_VENDOR_NAME(P_PARTY_id);
      FETCH CUR_VENDOR_NAME INTO l_name;
      CLOSE CUR_VENDOR_NAME;
    END IF;
    RETURN l_name;

  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END Get_Partner_Name;

  FUNCTION Get_Cont_Move_Distance( p_Plan_Id IN NUMBER,
                                   p_cont_move_id IN NUMBER)
      RETURN NUMBER IS

    CURSOR Cm_Dist_Cur(Cp_Plan_Id      IN NUMBER,
                       Cp_Cont_Move_Id IN NUMBER) IS
    SELECT NVL(sum(Total_Trip_Distance),0)
    FROM Mst_Trips
    WHERE Plan_Id = Cp_Plan_Id
    AND   Continuous_Move_Id = Cp_Cont_Move_Id;

    l_Distance NUMBER;
  BEGIN
    -- Used in CM Details UI
    OPEN Cm_Dist_Cur(P_Plan_Id,P_Cont_Move_Id);
    FETCH Cm_Dist_Cur INTO l_Distance;
    IF Cm_Dist_Cur%NOTFOUND THEN
            CLOSE Cm_Dist_Cur;
            RAISE No_Data_Found;
    END IF;
    CLOSE Cm_Dist_Cur;
    RETURN l_Distance;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END Get_Cont_Move_Distance;

  FUNCTION Get_Cont_Move_total_loads( p_Plan_Id IN NUMBER,
                                      p_cont_move_id IN NUMBER)
      Return NUMBER IS
    CURSOR Cm_count_Cur(Cp_Plan_Id IN NUMBER,
                       Cp_Cont_Move_Id IN NUMBER) IS
    SELECT COUNT(Trip_id)
    FROM Mst_Trips
    WHERE Plan_Id = Cp_Plan_Id
    AND   Continuous_Move_Id = Cp_Cont_Move_Id;

    l_trips NUMBER;
  BEGIN
    -- Used in CM Details UI
    OPEN Cm_count_Cur(P_Plan_Id,P_Cont_Move_Id);
    FETCH Cm_count_Cur INTO l_trips;
    IF Cm_count_Cur%NOTFOUND THEN
            CLOSE Cm_count_Cur;
            RAISE No_Data_Found;
    END IF;
    CLOSE Cm_count_Cur;
    RETURN l_trips;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
  END Get_Cont_Move_total_loads;

  FUNCTION GET_FIRST_DEPARTURE_DATE(P_PLAN_ID IN NUMBER,
                                    P_TRIP_ID IN NUMBER)
    RETURN DATE IS
     CURSOR TRIP_STOP_CUR IS
     SELECT TS.PLANNED_DEPARTURE_DATE
     FROM MST_TRIP_STOPS TS
     WHERE TS.PLAN_ID = P_PLAN_ID
     AND   TS.TRIP_ID = P_TRIP_ID
     AND   TS.STOP_SEQUENCE_NUMBER =
                        (SELECT MIN(STOP_SEQUENCE_NUMBER)
                         FROM MST_TRIP_STOPS TS1
                         WHERE TS1.PLAN_ID = TS.PLAN_ID
                         AND   TS1.TRIP_ID = TS.TRIP_ID
                         GROUP BY TS1.PLAN_ID, TS1.TRIP_ID);
     l_Date DATE;
  BEGIN
    -- Used in LTL/PARCEL/CM Details UI
    OPEN TRIP_STOP_CUR;
    FETCH TRIP_STOP_CUR INTO l_Date;
    IF TRIP_STOP_CUR%NOTFOUND THEN
        CLOSE TRIP_STOP_CUR;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE TRIP_STOP_CUR;
    RETURN l_Date;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END GET_FIRST_DEPARTURE_DATE;

  FUNCTION GET_LAST_ARRIVAL_DATE(P_PLAN_ID IN NUMBER,
                                 P_TRIP_ID IN NUMBER)
   RETURN DATE IS

    CURSOR TRIP_STOP_CUR IS
    SELECT TS.PLANNED_ARRIVAL_DATE
    FROM MST_TRIP_STOPS TS
    WHERE TS.PLAN_ID = P_PLAN_ID
    AND   TS.TRIP_ID = P_TRIP_ID
    AND   TS.STOP_SEQUENCE_NUMBER =
                        (SELECT MAX(STOP_SEQUENCE_NUMBER)
                         FROM MST_TRIP_STOPS TS1
                         WHERE TS1.PLAN_ID = TS.PLAN_ID
                         AND   TS1.TRIP_ID = TS.TRIP_ID
                         GROUP BY TS1.PLAN_ID, TS1.TRIP_ID);
    l_Date DATE;
  BEGIN
    -- Used in LTL/PARCEL/CM Details UI
    OPEN TRIP_STOP_CUR;
    FETCH TRIP_STOP_CUR INTO l_Date;
    IF TRIP_STOP_CUR%NOTFOUND THEN
        CLOSE TRIP_STOP_CUR;
        RAISE NO_DATA_FOUND;
    END IF;
    CLOSE TRIP_STOP_CUR;
    RETURN l_Date;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END GET_LAST_ARRIVAL_DATE;

  FUNCTION get_effective_cube_capacity(p_plan_id  IN NUMBER,
                                p_trip_id IN NUMBER)
    RETURN NUMBER IS
    cursor stops is
    select departure_volume
    from mst_trip_stops
    where plan_id = p_plan_id
    and trip_id = p_trip_id;

    cursor trips is
    select nvl(peak_volume_utilization, 1)
    from mst_trips
    where plan_id = p_plan_id
    and trip_id = p_trip_id;

    l_peak_volume number := 0;
    l_peak_volume_utilization number;
  BEGIN
    for c_trip_stops in stops loop
      if l_peak_volume < c_trip_stops.departure_volume then
        l_peak_volume := c_trip_stops.departure_volume;
      end if;
    end loop;

    open trips;
    fetch trips into l_peak_volume_utilization;
    close trips;
    if l_peak_volume_utilization = 0 then
      l_peak_volume_utilization := 1;
    end if;
    return l_peak_volume/l_peak_volume_utilization;

  END get_effective_cube_capacity;

  FUNCTION get_vehicle_capacity(p_plan_id         IN NUMBER,
                                p_vehicle_type_id IN NUMBER,
                                p_ret_val         IN VARCHAR2)
   RETURN NUMBER IS

        CURSOR CUR_VEH_WT_CAPACITY(pp_plan_id IN NUMBER,
                                   pp_vehicle_type_id IN NUMBER) IS
        SELECT MSI.Maximum_Load_Weight
        FROM MTL_SYSTEM_ITEMS MSI,
             FTE_VEHICLE_TYPES FVT
        WHERE FVT.VEHICLE_TYPE_ID   = pp_vehicle_type_id
        AND   MSI.INVENTORY_ITEM_ID = FVT.INVENTORY_ITEM_ID
        AND   MSI.ORGANIZATION_ID   = FVT.ORGANIZATION_ID;

        CURSOR CUR_VEH_VOL_CAPACITY(pp_plan_id IN NUMBER,
                                    pp_vehicle_type_id IN NUMBER) IS
        SELECT (FVT.USABLE_LENGTH *
                FVT.USABLE_WIDTH *
                FVT.USABLE_HEIGHT) USABLE_VOLUME
        FROM MTL_SYSTEM_ITEMS MSI,
             FTE_VEHICLE_TYPES FVT
        WHERE FVT.VEHICLE_TYPE_ID   = pp_vehicle_type_id
        AND   MSI.INVENTORY_ITEM_ID = FVT.INVENTORY_ITEM_ID
        AND   MSI.ORGANIZATION_ID   = FVT.ORGANIZATION_ID;

        CURSOR CUR_VEH_PAL_CAPACITY(pp_plan_id IN NUMBER,
                                    pp_vehicle_type_id IN NUMBER) IS
        SELECT (FVT.PALLET_FLOOR_SPACE *
                FVT.PALLET_STACKING_HEIGHT ) Pallets
        FROM MTL_SYSTEM_ITEMS MSI,
             FTE_VEHICLE_TYPES FVT
        WHERE FVT.VEHICLE_TYPE_ID   = pp_vehicle_type_id
        AND   MSI.INVENTORY_ITEM_ID = FVT.INVENTORY_ITEM_ID
        AND   MSI.ORGANIZATION_ID   = FVT.ORGANIZATION_ID;

    v_capacity NUMBER;
  BEGIN
    -- Used in Truckload Details UI
    IF P_RET_VAL = 'W' then
        OPEN cur_veh_WT_capacity(p_plan_id, P_VEHICLE_TYPE_ID );
        FETCH cur_veh_WT_capacity INTO v_capacity;
        CLOSE cur_veh_WT_capacity;
    ELSIF P_RET_VAL = 'V' Then
        OPEN cur_veh_VOL_capacity(p_plan_id, P_VEHICLE_TYPE_ID );
        FETCH cur_veh_VOL_capacity INTO v_capacity;
        CLOSE cur_veh_VOL_capacity;
    ELSIF P_RET_VAL = 'P' Then
        OPEN Cur_Veh_Pal_Capacity(p_plan_id, P_VEHICLE_TYPE_ID );
        FETCH Cur_Veh_Pal_Capacity INTO v_capacity;
        CLOSE Cur_Veh_Pal_Capacity;
    END IF;
    --V_Capacity := NVL(V_Capacity, 0.001);
    RETURN V_Capacity;
  EXCEPTION
    WHEN OTHERS THEN
    -- Nothing to return
        RETURN 0;
  END get_vehicle_capacity;

  FUNCTION elapsed_time(p_start_date DATE,
                        p_end_date DATE)
   RETURN VARCHAR2 is
    v_hours   NUMBER;
    v_minutes NUMBER;
    v_string  VARCHAR2(10);
  BEGIN
    -- Used in Truckload Details UI
    v_hours := (p_end_date - p_start_date)*24;
    v_minutes := mod(v_hours,1);
    v_hours := v_hours - v_minutes;
    v_minutes := round(v_minutes*60);
    IF v_hours < 0 THEN
        v_hours := 0;
    END IF;
    IF v_minutes < 0 THEN
        v_minutes := 0;
    END IF;
    IF v_minutes < 10 THEN
        v_string := '0'||v_minutes;
    ELSE
        v_string := v_minutes;
    END IF;
    IF v_minutes IS NULL or v_hours IS NULL THEN
        v_string := '00'||G_Time_delim||'00';
    ELSE
        v_string := v_hours||G_Time_delim||v_string;
    END IF;
    RETURN v_string;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN '00'||G_Time_delim||'00';
  END elapsed_time;

  FUNCTION elapsed_time(p_end_date DATE, p_delay NUMBER)
   RETURN VARCHAR2 IS
    v_hours   NUMBER;
    v_minutes NUMBER;
    v_string  VARCHAR2(10);
  BEGIN
    -- Used in Truckload Details UI
    v_hours := (p_end_date - (p_end_date - p_delay))*24;
    v_minutes := mod(v_hours,1);
    v_hours := v_hours - v_minutes;
    v_minutes := round(v_minutes*60);
    IF v_hours < 0 THEN
        v_hours := 0;
    END IF;
    IF v_minutes <0 THEN
        v_minutes := 0;
    END IF;
    IF v_minutes < 10 THEN
        v_string := '0'||v_minutes;
    ELSE
        v_string := v_minutes;
    END IF;
    IF v_minutes IS NULL or v_hours IS NULL THEN
        v_string := '00'||G_Time_delim||'00';
    ELSE
        v_string := v_hours||G_Time_delim||v_string;
    END IF;
    RETURN v_string;
   EXCEPTION
    WHEN OTHERS THEN
        RETURN '00'||G_Time_delim||'00';
  END elapsed_time;

  FUNCTION get_threshold_value (p_exception_type IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR c1 (p_user_id IN NUMBER) IS
    SELECT TRIM(TO_CHAR(threshold_value))||' '||threshold_uom
    FROM mst_excep_preferences
    WHERE exception_type = p_exception_type
    AND   user_id = p_user_id;

    l_threshold VARCHAR2(100) := NULL;

  BEGIN
    OPEN c1(fnd_global.user_id);
    FETCH c1 into l_threshold;
    CLOSE c1;
    IF l_threshold IS NULL THEN
      OPEN c1(-9999);
      FETCH c1 INTO l_threshold;
      CLOSE c1;
    END IF;
    RETURN l_threshold;
  EXCEPTION
    WHEN OTHERS THEN
      IF c1%ISOPEN THEN
        CLOSE c1;
      END IF;
      RETURN NULL;
  END get_threshold_value;

  FUNCTION get_facility_owner(P_Facility_id IN NUMBER,
                              P_Delim IN VARCHAR2)
    RETURN VARCHAR2 IS
    -- SQL repository issues as on 25-05-04:
      -- Rewritten sql to avoid ORDER BY clause
    CURSOR get_owner(p_owner_type IN Number) IS
    SELECT wlo.owner_party_id, wlo.owner_type
    FROM wsh_location_owners wlo
    WHERE wlo.wsh_location_id =
      (SELECT flp.location_id
       FROM fte_location_parameters flp
       WHERE  flp.facility_id = p_facility_ID )
    AND Wlo.owner_type = p_owner_type;
    /*CURSOR get_owner IS
    SELECT wlo.owner_party_id, wlo.owner_type
    FROM wsh_location_owners wlo,
         fte_location_parameters flp
    WHERE wlo.wsh_location_id = flp.location_id
    AND   flp.facility_id = p_facility_ID
    ORDER BY wlo.owner_type;*/

    l_rec_owner get_owner%ROWTYPE;
    l_Partner_info VARCHAR2(30);
    j NUMBER := 0;

  BEGIN
    -- Used in ALL the screens where Link to facility need to be shown ( in UI).

    /*FOR rec_owner IN get_owner LOOP
        l_partner_info := rec_owner.owner_party_id ||p_delim||rec_owner.owner_type;
        IF rec_owner.owner_type IN (1,3) THEN
            EXIT;
        END IF;
    END LOOP;*/
    FOR I IN 1..4 LOOP -- 1 Org, 2 Cust, 3 Carr, 4 Supp
        IF i = 2 THEN
            j := 3;
        ELSIF i = 3 THEN
            j := 2;
        ELSE
            j := i;
        END IF;
        OPEN get_owner(j);
        FETCH get_owner INTO l_rec_owner;
        IF get_owner%FOUND THEN
            l_partner_info := l_rec_owner.owner_party_id ||p_delim||l_rec_owner.owner_type;
        END IF;
        CLOSE get_owner;
        EXIT WHEN l_rec_owner.owner_type IN (1,3);
    END LOOP;
    RETURN l_partner_info;
  EXCEPTION
    WHEN too_many_rows THEN
        l_partner_info := '-9999'||p_delim;
        RETURN l_partner_info;
    WHEN OTHERS THEN
      RETURN NULL;
  END get_facility_owner;

  FUNCTION Get_Contact_name(p_contact_id IN NUMBER)
   RETURN VARCHAR2 IS

    CURSOR cur_contact IS
    SELECT hzp.party_name
    FROM hz_parties hzp,
         HZ_CONTACT_POINTS hzcp
    WHERE hzp.party_id          = hzcp.owner_table_id
    AND   hzcp.CONTACT_POINT_ID = p_contact_id;

    l_Contact VARCHAR2(100);
  BEGIN
    -- Used in Customer/Supplier/Carrier/Myfacility Details UI
    OPEN cur_Contact;
    FETCH cur_contact INTO l_Contact;
    CLOSE cur_Contact;
    RETURN l_Contact;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END Get_Contact_name;

  FUNCTION get_phone_number(p_contact_id IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR cur_phone IS
    SELECT hzcp.PHONE_NUMBER
    FROM HZ_CONTACT_POINTS hzcp
    WHERE hzcp.CONTACT_POINT_ID = p_contact_id;

    l_Phone VARCHAR2(100);
  BEGIN
    -- Used in Customer/Supplier/Carrier/Myfacility Details UI
    OPEN cur_Phone;
    FETCH cur_Phone INTO l_Phone;
    CLOSE cur_Phone;
    RETURN l_Phone;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
  END get_phone_number;

  FUNCTION get_min_sec(p_hours NUMBER)
    RETURN VARCHAR2 IS

    v_hours   NUMBER;
    v_minutes NUMBER;
    v_seconds NUMBER;
    v_string  VARCHAR2(10);
  BEGIN

    v_hours := p_hours;
    IF v_hours > 1 THEN
        v_minutes := mod(v_hours,1);
        v_hours := v_hours - v_minutes;
    ELSE
        v_minutes := v_hours;
    END IF;

    v_minutes := v_minutes*60;
    v_seconds := mod(v_minutes,1);
    v_minutes := v_minutes - v_seconds;
    v_seconds := round(v_seconds*60,2);
    IF v_minutes IS NULL THEN
        v_minutes := 0;
    END IF;
    IF v_minutes < 10 THEN
        v_string := '0'||v_minutes;
    ELSE
        v_string := v_minutes;
    END IF;
    IF v_seconds IS NULL THEN
        v_seconds := 0;
    END IF;
    IF v_seconds < 10 THEN
        v_string := v_string||G_Time_delim||'0'||v_seconds;
    ELSE
        v_string := v_string||G_Time_delim||v_seconds;
    END IF;

    RETURN v_string;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN '00'||G_Time_delim||'00';
  END get_min_sec;

  FUNCTION get_hr_min (p_hours IN NUMBER)
   RETURN VARCHAR2 IS
    l_Hours NUMBER;
    l_Minutes NUMBER;
    l_String VARCHAR2(10);
    l_Null_Str_Exception EXCEPTION;
    l_sign varchar2(1);
  BEGIN
    IF p_hours IS NULL THEN
      RAISE l_Null_Str_Exception;
    END IF;

    IF p_Hours < 0 THEN
      l_sign := '-';
      l_Hours := TRUNC(p_Hours) * -1;
      l_Minutes := ROUND(((p_Hours * -1) - l_Hours) * 60);
    ELSE
      l_Hours := TRUNC(p_Hours);
      l_Minutes := ROUND((p_Hours - l_Hours) * 60);
    END IF;

    --Bug_Fix for 4211337
    IF l_Minutes = 60
    THEN
      l_Hours := l_Hours + 1;
      l_Minutes := 0;
    END IF;

    IF l_Hours = 0 THEN
      l_String := '00';
    ELSIF l_Hours < 10 THEN
      l_String := '0'||TO_CHAR(l_Hours);
    ELSE
      l_String := TO_CHAR(l_Hours);
    END IF;

    IF l_Minutes <= 0 THEN
      l_String := l_String||g_Time_Delim||'00';
    ELSIF l_Minutes < 10 THEN
      l_String := l_String||g_Time_Delim||'0'||TO_CHAR(l_Minutes);
    ELSE
      l_String := l_String||g_Time_Delim||TO_CHAR(l_Minutes);
    END IF;

    IF l_sign = '-' THEN
      l_String :=   '<' || l_String || '>';
    END IF;

    RETURN l_String;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN '00'||g_Time_Delim||'00';
  END get_hr_min;

  FUNCTION get_local_chardt(p_location_id IN NUMBER, p_date IN DATE)
    RETURN VARCHAR2 IS
    l_localDate DATE ;    --:= mst_geocoding.get_local_time(p_location_id, p_date);
    l_dateTimeStr VARCHAR2(30);
  BEGIN
    l_localDate := mst_geocoding.get_local_time(p_location_id, p_date);
    l_dateTimeStr := ltrim(rtrim(fnd_date.date_to_displayDT(l_localDate, fnd_timezones.get_server_timezone_code)));
    l_dateTimeStr := Substr(l_dateTimeStr,1,length(l_dateTimeStr)-3);
    RETURN l_dateTimeStr;
  EXCEPTION
    WHEN OTHERS THEN
        l_dateTimeStr := NULL;
        RETURN l_dateTimeStr;
  END get_local_chardt;

  FUNCTION get_local_chardtzone(p_location_id IN NUMBER, p_date IN DATE)
    RETURN VARCHAR2 IS
    l_localDate DATE ;   --:= mst_geocoding.get_local_time(p_location_id, p_date);
    l_timeZone VARCHAR2(10) ;   --:= mst_geocoding.get_timezone_code(p_location_id, p_date);
    l_dateTimeStr VARCHAR2(30);
  BEGIN
    l_localDate := mst_geocoding.get_local_time(p_location_id, p_date);
    l_timeZone := mst_geocoding.get_timezone_code(p_location_id, p_date);
    l_dateTimeStr := ltrim(rtrim(fnd_date.date_to_displaydt(l_localDate, fnd_timezones.get_server_timezone_code)));
    l_dateTimeStr := Substr(l_dateTimeStr,1,length(l_dateTimeStr)-3)||' '||l_timeZone;
    RETURN l_dateTimeStr;
  EXCEPTION
    WHEN OTHERS THEN
        l_dateTimeStr := NULL;
        RETURN l_dateTimeStr;
  END get_local_chardtzone;

  FUNCTION GET_LEG_NUMBER(P_PLAN_ID IN NUMBER,
                           P_TRIP_ID IN NUMBER,
                           P_STOP_ID IN NUMBER)
    RETURN NUMBER IS

    CURSOR Cur_Leg_num IS
    SELECT ts.stop_id
    FROM mst_trip_stops ts
    WHERE plan_id = p_plan_Id
    AND   ts.trip_id = p_trip_id
    ORDER BY ts.stop_sequence_number;
    l_stop_id NUMBER;
    l_leg     NUMBER;
  BEGIN
    OPEN cur_leg_num;
    LOOP
        FETCH Cur_Leg_num INTO l_stop_id;
        l_leg := Cur_Leg_num%ROWCOUNT;
        EXIT WHEN Cur_Leg_num%NOTFOUND OR l_stop_id = p_stop_id;
    END LOOP;
    CLOSE Cur_Leg_num;
    RETURN l_leg;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
    END get_leg_number;

FUNCTION GET_TRIP_UTILIZATION(P_PLAN_ID IN NUMBER,
                              P_TRIP_ID IN NUMBER)
RETURN NUMBER IS
   l_weight_utilization number;
   l_volume_utilization   number;
   l_pallet_utilization number;
   l_trip_utilization   number;
BEGIN
   select nvl(peak_weight_utilization,0)
   into   l_weight_utilization
   from   mst_trips mt
   where  mt.trip_id = p_trip_id
   and    mt.plan_id = p_plan_id;

   select nvl(peak_volume_utilization,0)
   into   l_volume_utilization
   from   mst_trips mt
   where  mt.trip_id = p_trip_id
   and    mt.plan_id = p_plan_id;

   select nvl(peak_pallet_utilization,0)
   into   l_pallet_utilization
   from   mst_trips mt
   where  mt.trip_id = p_trip_id
   and    mt.plan_id = p_plan_id;

   l_trip_utilization := l_weight_utilization;
   if (l_trip_utilization < l_volume_utilization) then
      l_trip_utilization := l_volume_utilization;
   end if;
   if (l_trip_utilization < l_pallet_utilization) then
      l_trip_utilization := l_pallet_utilization;
   end if;
   return l_trip_utilization;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END GET_TRIP_UTILIZATION;


FUNCTION GET_TRIP_REMAINING_TIME(P_PLAN_ID IN NUMBER,
                                 P_TRIP_ID IN NUMBER)
 RETURN NUMBER IS
   l_time_remaining number;
BEGIN
   select (trip_start_date - sysdate)
   into l_time_remaining
   from mst_trips
   where plan_id = p_plan_id
   and   trip_id = p_trip_id;
   if l_time_remaining < 0 then
      return 0;
   else
      return l_time_remaining*24;  -- in hours
   end if;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END GET_TRIP_REMAINING_TIME;

FUNCTION GET_CM_REMAINING_TIME(P_PLAN_ID IN NUMBER,
                               P_CM_ID IN NUMBER)
 RETURN NUMBER IS
   l_time_remaining number;
BEGIN
   select (start_date - sysdate)
   into l_time_remaining
   from mst_cm_trips
   where plan_id = p_plan_id
   and   continuous_move_id = p_cm_id;
   if l_time_remaining < 0 then
      return 0;
   else
      return l_time_remaining*24;  -- in hours
   end if;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END GET_CM_REMAINING_TIME;

FUNCTION GET_TRIP_TOKENIZED_EXCEPTION(P_PLAN_ID IN NUMBER,
                                      P_EXCEPTION_DETAIL_ID IN NUMBER,
  				      P_TRIP_ID IN NUMBER,
				      P_LINE_NUM IN NUMBER)
RETURN VARCHAR2 IS
  l_message VARCHAR2(2000);
  l_exception_type NUMBER;
  l_temp  VARCHAR2(2500);
  l_temp1  VARCHAR2(2500);
  l_temp2  varchar2(2500);
  l_temp3  varchar2(2500);
  l_id1 NUMBER;
  l_id2 NUMBER;
  l_id3 NUMBER;
  l_id4 NUMBER;
  l_id5 NUMBER;
  l_id6 NUMBER;
  l_id7 NUMBER;
  l_id8 NUMBER;
  l_str1 VARCHAR2(2500);

  l_date1 date;
  l_date2 date;
BEGIN
  SELECT exception_type
  INTO l_exception_type
  FROM mst_exception_details
  WHERE plan_id = P_PLAN_ID
  AND exception_detail_id = P_EXCEPTION_DETAIL_ID;

-- added by giyer
  IF l_exception_type = 220 THEN --Item Mode Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_220_1');
        --Trip_number, mode_of_transport
        SELECT mt.trip_number, wlk.meaning
        INTO l_id1, l_temp
        FROM mst_trips mt,  wsh_lookups wlk
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID
        and wlk.lookup_type = 'WSH_MODE_OF_TRANSPORT'
        and mt.mode_of_transport = wlk.lookup_code;
      fnd_message.set_token('TRIP_NUMBER', l_id1);
      fnd_message.set_token('MODE_OF_TRANSPORT', l_temp);
        -- item_description
        select description, med.delivery_detail_id
        into l_temp1, l_id2
        from mtl_system_items_tl msitl, mst_delivery_details mdd, mst_exception_details med
        where med.plan_id=p_plan_id
        and med.exception_detail_id = P_EXCEPTION_DETAIL_ID
        and med.delivery_detail_id = mdd.delivery_detail_id
        and med.plan_id = mdd.plan_id
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
      fnd_message.set_token('DELIVERY_DETAIL_ID', l_id2);
      fnd_message.set_token('ITEM_DESCRIPTION', l_temp1);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 221 THEN --Item Carrier Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_221_1');
        --Trip_number
        SELECT trip_number, carrier_id
        INTO l_id1, l_id2
        FROM mst_trips
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID;
        -- item_description
        select description, med.delivery_detail_id
        into l_temp, l_id3
        from mtl_system_items_tl msitl, mst_delivery_details mdd, mst_exception_details med
        where med.plan_id=p_plan_id
        and med.exception_detail_id = P_EXCEPTION_DETAIL_ID
        and med.delivery_detail_id = mdd.delivery_detail_id
        and med.plan_id=mdd.plan_id
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
        --carrier name
        SELECT freight_code into l_temp1
        FROM wsh_carriers
        WHERE carrier_id = l_id2;
      fnd_message.set_token('TRIP_NUMBER', l_id1);
      fnd_message.set_token('DELIVERY_DETAIL_ID', l_id3);
      fnd_message.set_token('CARRIER_NAME', l_temp1);
      fnd_message.set_token('ITEM_DESCRIPTION', l_temp);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 222 THEN --Ship Set Violation
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_222_1');
        --Ship_set
        select number1
        into l_id1
        from mst_exception_details med
        where med.exception_detail_id = p_exception_detail_id
        and med.plan_id=p_plan_id;
        -- Ship_set Name
        select set_name into l_temp
        from oe_sets os
        where os.set_id=l_id1;
      fnd_message.set_token('SHIP_SET', l_temp);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 223 THEN -- Arrival Set Violation
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_223_1');
        --Arrival_set
        select number1
        into l_id1
        from mst_exception_details med
        where med.exception_detail_id = p_exception_detail_id
        and med.plan_id=p_plan_id;
        --Arrival_set Name
        select set_name into l_temp
        from oe_sets os
        where os.set_id=l_id1;
      fnd_message.set_token('ARRIVAL_SET', l_temp);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 301 THEN --Carrier Commitment Underutilization
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_301_1');
        --start_date, end_date, shortfall
        select carrier_id
        , fnd_date.DATE_TO_CHARDATE(date1)
        , fnd_date.DATE_TO_CHARDATE(date2)
        , decode ( fsrr.attribute_name
            , 'SPEND'
            , to_char ( ( med.number3 - med.number2 ) , fnd_currency.get_format_mask ( fsl.uom_code, 67 ) )
            , to_char( round ( med.number3 ) - round ( med.number2 ), mst_wb_util.get_format_string ( 'NUMBER' ) ) )
        into l_id2,l_temp1,l_temp2,l_temp3
        from mst_exception_details med
        , fte_sel_rule_restrictions fsrr
        , fte_sel_rules fsl
        where med.exception_detail_id = p_exception_detail_id
        and med.number1 = fsrr.rule_id
        and med.number1 = fsl.rule_id
        and med.plan_id=p_plan_id;
     fnd_message.set_token('START_DATE', l_temp1);
     fnd_message.set_token('END_DATE', l_temp2);
     fnd_message.set_token('SHORTFALL', l_temp3);
        --Carrier name
        SELECT freight_code INTO l_temp
        FROM wsh_carriers
        WHERE carrier_id = l_id2;
     fnd_message.set_token('CARRIER', l_temp);
        --get Lane_Number
        select LANE
        into l_temp
        from(
        select fl.lane_number "LANE"
        from fte_lanes fl, mst_exception_details med
        where med.lane_id = fl.lane_id
        and med.exception_detail_id=p_exception_detail_id
        and med.plan_id=p_plan_id
        union all
        select flg.name "LANE"
        from fte_lane_groups flg, mst_exception_details med
        where med.lane_set_id = flg.lane_group_id
        and med.exception_detail_id=p_exception_detail_id
        and med.plan_id=p_plan_id);
        --as per dld, Lane_Number = fl.lane_number or flg.name whichever is not null
     fnd_message.set_token('LANE_NAME', l_temp);
     l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 406 THEN --Carrier Facility Appointment violation
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_406_1');
        --facility_description
        select flp.facility_code
        into l_temp
        from fte_location_parameters flp, mst_trip_stops mts, mst_exception_details med
        where mts.stop_id = med.stop_id1
        and mts.stop_location_id = flp.location_id
        and med.exception_detail_id = p_exception_detail_id
        and med.plan_id = mts.plan_id
        and med.plan_id = p_plan_id;
      fnd_message.set_token('FACILITY_DESCRIPTION', l_temp);
        --trip_number,carrier_name
        SELECT trip_number, carrier_id
        INTO l_id1, l_id2
        FROM mst_trips
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID;
        --carrier name
        SELECT freight_code INTO l_temp
        FROM wsh_carriers
        WHERE carrier_id = l_id2;
      fnd_message.set_token('CARRIER_NAME', l_temp);
      fnd_message.set_token('TRIP_NUMBER', l_id1);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 602 THEN --Item Vehicle Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_602_1');
        --Trip_number, item_description,vehicle_type
        --Trip_number
        SELECT mt.trip_number,vehicle_type_id
        INTO l_id1,l_id2
        FROM mst_trips mt
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);
        -- item_description
        select msitl.description into l_temp1
        from mtl_system_items_tl msitl, mst_delivery_details mdd, mst_exception_details med
        where med.plan_id=p_plan_id
        and med.plan_id = mdd.plan_id
        and med.exception_detail_id = P_EXCEPTION_DETAIL_ID
        and med.delivery_detail_id = mdd.delivery_detail_id
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
      fnd_message.set_token('ITEM_DESCRIPTION', l_temp1);
        -- vehicle_type
        SELECT msikfv.concatenated_segments
        into l_temp
        FROM mtl_system_items_kfv msikfv, fte_vehicle_types fvt
        WHERE fvt.vehicle_type_id = l_id2
        AND fvt.organization_id = msikfv.organization_id
        AND fvt.inventory_item_id = msikfv.inventory_item_id;
      fnd_message.set_token('VEHICLE_TYPE', l_temp);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 705 THEN --Facility Item Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_705_1');
        --Trip_Number, Item_description, facility_description
        --Trip_number
        SELECT mt.trip_number
        INTO l_id1
        FROM mst_trips mt
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);
        -- item_description
        select msitl.description into l_temp1
        from mtl_system_items_tl msitl, mst_delivery_details mdd, mst_exception_details med
        where med.plan_id=p_plan_id
        and med.plan_id = mdd.plan_id
        and med.exception_detail_id = P_EXCEPTION_DETAIL_ID
        and med.delivery_detail_id = mdd.delivery_detail_id
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
      fnd_message.set_token('ITEM_DESCRIPTION', l_temp1);
        -- Facility_Description
        select flp.description
        into l_temp
        from fte_location_parameters flp, mst_exception_details med
        where
        med.location_id = flp.location_id
        and med.plan_id=p_plan_id
        and med.exception_detail_id=p_exception_detail_id;
      fnd_message.set_token('FACILITY_DESCRIPTION', l_temp);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 706 THEN --Facility Mode Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_706_1');
        --Trip_number, mode_of_transport, facility_description
        --Trip_number, mode_of_transport
        SELECT mt.trip_number, wlk.meaning
        INTO l_id1, l_temp
        FROM mst_trips mt,  wsh_lookups wlk
        WHERE plan_id = P_PLAN_ID
        AND trip_id = P_TRIP_ID
        and wlk.lookup_type = 'WSH_MODE_OF_TRANSPORT'
        and mt.mode_of_transport = wlk.lookup_code;
      fnd_message.set_token('TRIP_NUMBER', l_id1);
      fnd_message.set_token('MODE_OF_TRANSPORT', l_temp);
        --facility_description
        select flp.description
        into l_temp1
        from fte_location_parameters flp, mst_exception_details med
        where
        med.location_id = flp.location_id
        and med.plan_id=p_plan_id
        and med.exception_detail_id=p_exception_detail_id;
      fnd_message.set_token('FACILITY_DESCRIPTION', l_temp1);
      l_message := fnd_message.get;
    END IF;

  ELSIF l_exception_type = 707 THEN --Facility Facility Incompatibility
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_707_1');
        --Delivery_number
        select md.delivery_number
        into l_id1
        from mst_deliveries md, mst_exception_details med
        where med.delivery_id = md.delivery_id
        and med.plan_id=p_plan_id
        and med.plan_id = md.plan_id
        and med.exception_detail_id=p_exception_detail_id;
      fnd_message.set_token('DELIVERY_NUMBER', l_id1);
        --End_facility_name, intermediate_facility_name
        select flp1.facility_code, flp2.facility_code
        into l_temp1, l_temp2
        from fte_location_parameters flp1, fte_location_parameters flp2, mst_exception_details med
        where med.location_id = flp1.location_id
        and med.number1 = flp2.location_id
        and med.plan_id = p_plan_id
        and med.exception_detail_id = p_exception_detail_id;
      fnd_message.set_token('END_FACILITY_NAME', l_temp1);
      fnd_message.set_token('INTERMEDIATE_FACILITY_NAME', l_temp2);
      l_message := fnd_message.get;
    END IF;-- end giyer

  ELSIF l_exception_type = 200 THEN
    IF P_LINE_NUM = 1 THEN
     fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_200_1');
     SELECT carrier_id, origin_location_id, destination_location_id, trip_number
     INTO l_id1, l_id2, l_id3, l_id4
     FROM mst_trips
     WHERE plan_id = P_PLAN_ID
     AND trip_id = P_TRIP_ID;
     fnd_message.set_token('TRIP_NUMBER', l_id4);

     SELECT freight_code INTO l_temp
     FROM wsh_carriers
     WHERE carrier_id = l_id1;
     fnd_message.set_token('FREIGHT_CODE', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id2;
     fnd_message.set_token('ORIGIN_CITY', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id3;
     fnd_message.set_token('DESTINATION_CITY', l_temp);

      SELECT distance_uom
      INTO l_str1
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;
      fnd_message.set_token('DISTANCE_UOM', l_str1);

      SELECT round(number3), round(number4)
      INTO l_id1, l_id2
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('MAX_DISTANCE_IN_24HR', l_id2);
      fnd_message.set_token('DISTANCE_IN_24HR', l_id1);

      SELECT round(number1), round(number2)
      INTO l_id1, l_id2
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('MAXIMUM_DISTANCE', l_id2);
      fnd_message.set_token('DISTANCE', l_id1);
      l_message := fnd_message.get;

    END IF;
  ELSIF l_exception_type = 207 THEN
    IF P_LINE_NUM = 1 THEN
     fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_207_1');
     SELECT carrier_id, origin_location_id, destination_location_id, trip_number
     INTO l_id1, l_id2, l_id3, l_id4
     FROM mst_trips
     WHERE plan_id = P_PLAN_ID
     AND trip_id = P_TRIP_ID;
     fnd_message.set_token('TRIP_NUMBER', l_id4);

     SELECT freight_code INTO l_temp
     FROM wsh_carriers
     WHERE carrier_id = l_id1;
     fnd_message.set_token('FREIGHT_CODE', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id2;
     fnd_message.set_token('ORIGIN_CITY', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id3;
     fnd_message.set_token('DESTINATION_CITY', l_temp);

     SELECT nvl(round(wcs.max_driving_time_in_24hr),0)
      INTO l_id2
      FROM wsh_carrier_services wcs,
           mst_exception_details med
      WHERE wcs.carrier_service_id = med.carrier_service_id
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('ALLOWED_DRIVING_TIME', l_id2);

      SELECT nvl(round(number1),0)
      INTO l_id1
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('DRIVING_TIME', l_id1);

      SELECT nvl(round(wcs.max_total_time),0)
      INTO l_id2
      FROM wsh_carrier_services wcs,
           mst_exception_details med
      WHERE wcs.carrier_service_id = med.carrier_service_id
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('MAX_TIME', l_id2);

      SELECT nvl(round(wcs.max_duty_time_in_24hr),0)
      INTO l_id2
      FROM wsh_carrier_services wcs,
           mst_exception_details med
      WHERE wcs.carrier_service_id = med.carrier_service_id
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('ALLOWED_DUTY_TIME', l_id2);

      SELECT nvl(round(number2),0)
      INTO l_id1
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('DUTY_TIME', l_id1);

      SELECT nvl(round(wcs.min_layover_time),0)
      INTO l_id2
      FROM wsh_carrier_services wcs,
           mst_exception_details med
      WHERE wcs.carrier_service_id = med.carrier_service_id
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('MIN_LAYOVER_TIME', l_id2);

      SELECT nvl(round(number3),0)
      INTO l_id1
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('LAYOVER_TIME', l_id1);

      SELECT nvl(round(((trip_end_date - trip_start_date) * 24)),0)
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TIME', l_id1);

     l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 206 THEN
    IF P_LINE_NUM = 1 THEN
     fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_206_1');
     SELECT carrier_id, origin_location_id, destination_location_id, trip_number
     INTO l_id1, l_id2, l_id3, l_id4
     FROM mst_trips
     WHERE plan_id = P_PLAN_ID
     AND trip_id = P_TRIP_ID;
     fnd_message.set_token('TRIP_NUMBER', l_id4);

     SELECT freight_code INTO l_temp
     FROM wsh_carriers
     WHERE carrier_id = l_id1;
     fnd_message.set_token('FREIGHT_CODE', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id2;
     fnd_message.set_token('ORIGIN_CITY', l_temp);

     SELECT city INTO l_temp
     FROM wsh_locations
     WHERE wsh_location_id = l_id3;
     fnd_message.set_token('DESTINATION_CITY', l_temp);
     l_message := fnd_message.get;
    ELSIF P_LINE_NUM = 2 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_206_2');
      SELECT number1, number2
      INTO l_id1, l_id2
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND trip_id1 = P_TRIP_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('STOPS', l_id1);
      fnd_message.set_token('MAX_STOPS', l_id2);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 208 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_208_1');
      SELECT carrier_id, origin_location_id, destination_location_id, trip_number
      INTO l_id1, l_id2, l_id3, l_id4
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id4);

      SELECT freight_code INTO l_temp
      FROM wsh_carriers
      WHERE carrier_id = l_id1;
      fnd_message.set_token('FREIGHT_CODE', l_temp);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id2;
      fnd_message.set_token('ORIGIN_CITY', l_temp);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('DESTINATION_CITY', l_temp);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 201 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_201_1');
      SELECT distance_uom INTO l_temp
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;
      fnd_message.set_token('DISTANCE_UOM', l_temp);

      SELECT carrier_id, continuous_move_id, round(number2), round(number3)
      INTO l_id1, l_id2, l_id3, l_id4
      FROM mst_exception_details
      WHERE plan_id = P_PLAN_ID
      AND exception_detail_id = P_EXCEPTION_DETAIL_ID;

      fnd_message.set_token('ACTUAL_DEADHEAD_DISTANCE', l_id3);
      fnd_message.set_token('MAX_DEADHEAD_DISTANCE', l_id4);

      SELECT freight_code INTO l_temp
      FROM wsh_carriers
      WHERE carrier_id = l_id1;
      fnd_message.set_token('FREIGHT_CODE', l_temp);

      SELECT cm_trip_number, start_location_id, end_location_id
      INTO l_id1, l_id3, l_id4
      FROM mst_cm_trips
      WHERE plan_id = P_PLAN_ID
      AND continuous_move_id = l_id2;
      fnd_message.set_token('CM_TRIP_NUMBER', l_id1);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('ORIGIN_CITY', l_temp);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id4;
      fnd_message.set_token('DESTINATION_CITY', l_temp);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 202 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_202_1');
      SELECT origin_location_id, destination_location_id, trip_number
      INTO l_id2, l_id3, l_id4
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id4);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id2;
      fnd_message.set_token('ORIGIN_CITY', l_temp);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('DESTINATION_CITY', l_temp);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 203 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_203_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT mts.stop_sequence_number, mts.stop_location_id
      INTO l_id2, l_id3
      FROM mst_trip_stops mts,
           mst_exception_details med
      WHERE mts.plan_id = med.plan_id
      AND med.plan_id = P_PLAN_ID
      AND mts.trip_id = med.trip_id1
      AND mts.stop_id = med.stop_id1
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('STOP_SEQUENCE_NUMBER', l_id2);

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('CITY', l_temp);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 204 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_204_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT mts.stop_location_id, mts.planned_departure_date, round(med.number1)
      INTO l_id1, l_date1, l_id3
      FROM mst_trip_stops mts,
           mst_exception_details med
      WHERE mts.plan_id = med.plan_id
      AND mts.stop_id = med.stop_id1
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id1;
      fnd_message.set_token('ORIGIN_CITY', l_temp);
      fnd_message.set_token('REQUIRED_TRANSIT_TIME', l_id3);

      SELECT mts.stop_location_id, mts.planned_arrival_date
      INTO l_id3, l_date2
      FROM mst_trip_stops mts,
           mst_exception_details med
      WHERE mts.plan_id = med.plan_id
      AND mts.stop_id = med.stop_id2
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;

      SELECT city INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('DESTINATION_CITY', l_temp);

      l_id1 := round(((l_date2 - l_date1) * 24));
      fnd_message.set_token('PLANNED_TRANSIT_TIME', l_id1);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 205 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_205_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT round(nvl(number1, 0)), round(nvl(number2, 0)), round(nvl(number3, 0)), round(nvl(number4, 0))
      INTO l_id1, l_id2, l_id3, l_id7
      FROM mst_exception_details med
      WHERE exception_detail_id = P_EXCEPTION_DETAIL_ID
      AND plan_id = P_PLAN_ID;

      SELECT round(nvl(max_drive_time, 0)), round(nvl(max_duty_time, 0)), round(nvl(minimum_lay_time, 0)), round(nvl(max_driving_distance, 0))
      INTO l_id4, l_id5, l_id6, l_id8
      FROM mst_parameters
      WHERE user_id = -9999;

      fnd_message.set_token('ALLOWED_DRIVING_TIME', l_id4);
      fnd_message.set_token('DRIVING_TIME', l_id2);
      fnd_message.set_token('ALLOWED_DUTY_TIME', l_id5);
      fnd_message.set_token('DUTY_TIME', l_id3);
      fnd_message.set_token('MINIMUM_LAYOVER_TIME', l_id6);
      fnd_message.set_token('LAYOVER_TIME', l_id1);
      fnd_message.set_token('MAX_DISTANCE', l_id8);
      fnd_message.set_token('DISTANCE', l_id7);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 400 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_400_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT description into l_temp
      FROM fte_location_parameters
      WHERE location_id in (SELECT mts.stop_location_id
            FROM mst_trip_stops mts,
                 mst_exception_details med
            WHERE mts.plan_id = med.plan_id
            AND mts.stop_id = med.stop_id1
            AND med.plan_id = P_PLAN_ID
            AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID);
      fnd_message.set_token('FACILITY_DESC', l_temp);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 401 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_401_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT flp.description, round(nvl(med.number1, 0), 1), round((mts.planned_departure_date - mts.planned_arrival_date) * 24, 1)
      INTO l_temp, l_id1, l_id2
      FROM fte_location_parameters flp,
           mst_trip_stops mts,
           mst_exception_details med
      WHERE flp.location_id = mts.stop_location_id
      AND mts.plan_id = med.plan_id
      AND mts.stop_id = med.stop_id1
      AND med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('FACILITY_DESC', l_temp);
      fnd_message.set_token('REQUIRED_STOP_TIME', ltrim(to_char(l_id1, '999990.0')));
      fnd_message.set_token('STOP_TIME', ltrim(to_char(l_id2, '999990.0')));

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 500 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_500_1');
      SELECT trip_number, origin_location_id, destination_location_id, carrier_id,
             round((nvl(total_basic_transport_cost,0) + nvl(total_accessorial_cost,0) + nvl(total_layover_cost,0) + nvl(total_load_unload_cost,0) + nvl(total_stop_cost,0)))
      INTO l_id1, l_id2, l_id3, l_id4, l_id5
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT freight_code
      INTO l_temp
      FROM wsh_carriers
      WHERE carrier_id = l_id4;
      fnd_message.set_token('FREIGHT_CODE', l_temp);

      SELECT city
      INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id2;
      fnd_message.set_token('ORIGIN_CITY', l_temp);

      SELECT city
      INTO l_temp
      FROM wsh_locations
      WHERE wsh_location_id = l_id3;
      fnd_message.set_token('DESTINATION_CITY', l_temp);

      SELECT wc.freight_code, round(nvl(med.number1, 0))
      INTO l_temp, l_id1
      FROM wsh_carriers wc,
           mst_exception_details med
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID
      AND med.carrier_id = wc.carrier_id;

      fnd_message.set_token('LOW_COST_CARRIER_COST', l_id1);
      fnd_message.set_token('LOW_COST_CARRIER', l_temp);
      fnd_message.set_token('COST', l_id5);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 501 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_501_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 600 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_600_1');
      SELECT mt.trip_number, mt.peak_weight_utilization,
	     mt.peak_volume_utilization,
	     mt.peak_pallet_utilization,
	     med.number2,
	     med.number1,
	     med.number3,
	     med.vehicle_type_id
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7, l_id8
      FROM mst_trips mt,
           mst_exception_details med
      WHERE mt.plan_id = med.plan_id
      AND med.plan_id = P_PLAN_ID
      AND mt.trip_id = P_TRIP_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      fnd_message.set_token('PEAK_WEIGHT_UTILIZATION', round(l_id2 * 100));
      fnd_message.set_token('PEAK_VOLUME_UTILIZATION', round(l_id3 * 100));
      fnd_message.set_token('PEAK_PALLET_UTILIZATION', round(l_id4 * 100));

      fnd_message.set_token('PEAK_WEIGHT', round(l_id2 * l_id5));
      fnd_message.set_token('PEAK_VOLUME', round(l_id3 * l_id6));
      fnd_message.set_token('PEAK_PALLETS', round(l_id4 * l_id7));

      fnd_message.set_token('MAX_WEIGHT', round(l_id5));
      fnd_message.set_token('MAX_VOLUME', round(l_id6));
      fnd_message.set_token('MAX_PALLETS', round(l_id7));

      SELECT volume_uom
      INTO l_temp
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;

      SELECT msikfv.internal_volume * get_uom_conversion_rate (msikfv.volume_uom_code,
                                                               l_temp,
                                                               msikfv.organization_id,
                                                               msikfv.inventory_item_id)
      INTO l_id1
      FROM mtl_system_items_kfv msikfv,
           fte_vehicle_types fvt
      WHERE msikfv.inventory_item_id = fvt.inventory_item_id
      AND msikfv.organization_id = fvt.organization_id
      AND fvt.vehicle_type_id = l_id8;

      If l_id1 is not null Then
        fnd_message.set_token('PHYSICAL_CAPACITY', l_id1);
      Else
        fnd_message.set_token('PHYSICAL_CAPACITY', '');
      End If;

      SELECT weight_uom, volume_uom
      INTO l_temp, l_temp1
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;

      fnd_message.set_token('WEIGHT_UOM', l_temp);
      fnd_message.set_token('VOLUME_UOM', l_temp1);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 601 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_601_1');
      SELECT mt.trip_number, mt.peak_weight_utilization,
	     mt.peak_volume_utilization,
	     mt.peak_pallet_utilization,
	     med.number2,
	     med.number1,
	     med.number3
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7
      FROM mst_trips mt,
           mst_exception_details med
      WHERE mt.plan_id = med.plan_id
      AND med.plan_id = P_PLAN_ID
      AND mt.trip_id = P_TRIP_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      fnd_message.set_token('PEAK_WEIGHT_UTILIZATION', round(l_id2 * 100));
      fnd_message.set_token('PEAK_VOLUME_UTILIZATION', round(l_id3 * 100));
      fnd_message.set_token('PEAK_PALLET_UTILIZATION', round(l_id4 * 100));

      fnd_message.set_token('PEAK_WEIGHT', round(l_id2 * l_id5));
      fnd_message.set_token('PEAK_VOLUME', round(l_id3 * l_id6));
      fnd_message.set_token('PEAK_PALLETS', round(l_id4 * l_id7));

      fnd_message.set_token('MAX_WEIGHT', round(l_id5));
      fnd_message.set_token('MAX_VOLUME', round(l_id6));
      fnd_message.set_token('MAX_PALLETS', round(l_id7));

      SELECT weight_uom, volume_uom
      INTO l_temp, l_temp1
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;

      fnd_message.set_token('WEIGHT_UOM', l_temp);
      fnd_message.set_token('VOLUME_UOM', l_temp1);

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 800 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_800_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT wc.freight_code
      INTO l_temp
      FROM mst_exception_details med,
           wsh_carriers wc
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID
      AND med.carrier_id = wc.carrier_id;
      fnd_message.set_token('FREIGHT_CODE', l_temp);

      SELECT Get_Partner_Name(decode(med.customer_id, null, med.supplier_id, med.customer_id),
                              decode(med.customer_id, null, 2, 1))
      INTO l_temp
      FROM mst_exception_details med
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;

      fnd_message.set_token('TRADING_PARTNER', l_temp);
      fnd_message.set_token('FACILITY_DESC', 'facility description');

      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 801 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_801_1');
      SELECT trip_number, carrier_id
      INTO l_id1, l_id2
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT wc.freight_code
      INTO l_temp
      FROM wsh_carriers wc
      WHERE wc.carrier_id = l_id2;
      fnd_message.set_token('FREIGHT_CODE', l_temp);

      SELECT flp.description
      INTO l_temp
      FROM fte_location_parameters flp,
           mst_exception_details med,
	   mst_trip_stops mts
      WHERE med.stop_id1 = mts.stop_id
      AND mts.plan_id = P_PLAN_ID
      AND med.exception_detail_id = P_EXCEPTION_DETAIL_ID
      AND mts.stop_location_id = flp.location_id;
      fnd_message.set_token('FACILITY_DESC', l_temp);

      SELECT Get_Partner_Name(decode(med.customer_id, null, med.supplier_id, med.customer_id),
                              decode(med.customer_id, null, 2, 1))
      INTO l_temp
      FROM mst_exception_details med
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('CUST_SUPPLIER', l_temp);
      l_message := fnd_message.get;
    END IF;
  ELSIF l_exception_type = 803 THEN
    IF P_LINE_NUM = 1 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_803_1');
      SELECT trip_number
      INTO l_id1
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = P_TRIP_ID;
      fnd_message.set_token('TRIP_NUMBER', l_id1);

      SELECT Get_Partner_Name(med.customer_id, 1)
      INTO l_temp
      FROM mst_exception_details med
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('CUSTOMER1', l_temp);

      SELECT Get_Partner_Name(med.number1, 1)
      INTO l_temp
      FROM mst_exception_details med
      WHERE med.plan_id = P_PLAN_ID
      AND med.exception_detail_id =  P_EXCEPTION_DETAIL_ID;
      fnd_message.set_token('CUSTOMER2', l_temp);

      l_message := fnd_message.get;
    END IF;
  ELSE
     SELECT ml.meaning INTO l_message
     FROM mfg_lookups ml, mst_exception_details med
     WHERE med.exception_type = ml.lookup_code
     AND ml.lookup_type = 'MST_EXCEPTION_TYPE'
     and med.exception_detail_id = P_EXCEPTION_DETAIL_ID;
  END IF;
  RETURN l_message;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GET_TRIP_TOKENIZED_EXCEPTION;

function get_contact_info (p_contact_id in number
                         , p_ret_str_type in varchar2
			 , p_owner_type_id in number default null)
return varchar2 is
    -- SQL repository issues as on 25-05-04:
      -- Removed distinct clause
  cursor cur_contact_name (l_contact_id in number) is
  SELECT hzp.party_name
  from  hz_parties hzp
  where hzp.party_id = l_contact_id;

  cursor cur_prim_contact (l_contact_id in number, l_ret_str_type in varchar2) is
  select hzcp.phone_country_code||'-'||hzcp.phone_area_code||'-'||hzcp.phone_number||'-'||hzcp.phone_extension
  , hzcp.email_address
  from  hz_contact_points hzcp
  where hzcp.owner_table_id = l_contact_id
  and   hzcp.contact_point_type = l_ret_str_type
  and   hzcp.primary_flag = 'Y'
  and   hzcp.owner_table_name = 'HZ_PARTIES'
  and   hzcp.status = 'A';

  cursor cur_sec_contact (l_contact_id in number, l_ret_str_type in varchar2) is
  select hzcp.phone_country_code||'-'||hzcp.phone_area_code||'-'||hzcp.phone_number||'-'||hzcp.phone_extension
  , hzcp.email_address
  from  hz_contact_points hzcp
  where hzcp.owner_table_id = l_contact_id
  and   hzcp.contact_point_type = l_ret_str_type
  and   hzcp.primary_flag = 'N'
  and   hzcp.owner_table_name = 'HZ_PARTIES'
  and   hzcp.status = 'A';

  l_contact_person varchar2(100);
  l_phone_num      varchar2(100);
  l_email_address  varchar2(100);

begin
  if p_owner_type_id = 1 then
    if p_ret_str_type = 'NAME' then
      l_contact_person := fnd_profile.value('MST_COMPANY_CONTACT_NAME');
      return l_contact_person;
    elsif p_ret_str_type = 'PHONE' then
      l_phone_num := fnd_profile.value('MST_COMPANY_CONTACT_PHONE');
      return l_phone_num;
    elsif p_ret_str_type = 'EMAIL' then
      l_email_address := fnd_profile.value('MST_COMPANY_CONTACT_EMAIL');
      return l_email_address;
    else
      return null;
    end if;
  else
    if p_ret_str_type = 'NAME' then
     --get the contact person name
      open  cur_contact_name (p_contact_id);
      fetch cur_contact_name into l_contact_person;
      close cur_contact_name;

      return l_contact_person;
    elsif p_ret_str_type IN ('PHONE','EMAIL') then
     --get the primary phone number OR email
      open  cur_prim_contact (p_contact_id, p_ret_str_type);
      fetch cur_prim_contact into l_phone_num, l_email_address;
       if cur_prim_contact%notfound then
         close cur_prim_contact;
         --else get one secondary phone number OR email
         open  cur_sec_contact (p_contact_id, p_ret_str_type);
         fetch cur_sec_contact into l_phone_num, l_email_address;
         close cur_sec_contact;
       else
 	 close cur_prim_contact;
       end if;
       if  p_ret_str_type = 'PHONE' then
         return l_phone_num;
       elsif  p_ret_str_type = 'EMAIL' then
         return l_email_address;
       end if;
    else
      return null;
    end if;
  end if;

  exception
  when others then
    return null;
end get_contact_info;


--***************USED IN REPORTS **************************

function r_get_canonical_number (p_number in number
                               , p_format_mask_ident in number default 1)
return varchar2 is
  l_format_mask varchar2(50);
  l_string      varchar2(50);
begin
  if p_format_mask_ident = 1 then
    l_format_mask := 'FM999G999G999G990';
  elsif p_format_mask_ident = 2 then
    l_format_mask := 'FM999G999G999G990D09999';
  elsif p_format_mask_ident = 3 then
    l_format_mask := 'FM999G999G999G990D00';
  else
    l_format_mask := null;
  end if;

  if l_format_mask is not null then
    l_string := to_char(p_number, l_format_mask);
  else
    l_string := 'Format Mask Not Defined';
  end if;
  return l_string;
exception
  when others then
    return 'Exception Raised';
end r_get_canonical_number;

  FUNCTION r_get_company_name(P_Location_id IN NUMBER, P_Owner_Type IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR CUR_COMPANY_NAME( P_PARTY_ID IN NUMBER ) IS
    SELECT HZP.PARTY_NAME
    FROM HZ_PARTIES HZP
    WHERE HZP.PARTY_ID = P_party_id;

    l_owner_type NUMBER;
    l_owner_party_id NUMBER;

    l_Name VARCHAR2(360);

  BEGIN
    SELECT wlo.OWNER_PARTY_ID
    INTO l_owner_party_id
    FROM wsh_location_owners wlo
    WHERE wlo.wsh_location_id = P_Location_id
    AND   wlo.owner_type = P_Owner_Type;
    IF P_Owner_Type = 1 THEN
        l_Name := fnd_profile.value('MST_COMPANY_NAME');
    ELSE
        OPEN CUR_COMPANY_NAME(l_owner_party_id);
        FETCH CUR_COMPANY_NAME INTO l_Name;
        CLOSE CUR_COMPANY_NAME;
    END IF;

    RETURN l_Name;
  EXCEPTION
    WHEN too_many_rows THEN
        l_name := Get_meaning('MST_STRING','33','MFG');
        RETURN L_NAME;
    WHEN OTHERS THEN
    -- Nothing to return
        RETURN NULL;
  END r_get_company_name;

function r_plan_value (p_plan_id in number)
return number
is l_plan_value number;
begin
/*   select sum(nvl(mt.total_basic_transport_cost,0)
            + nvl(mt.total_accessorial_cost,0)
            + nvl(mt.total_handling_cost,0)
            + nvl(mt.total_layover_cost,0)
            + nvl(mt.total_load_unload_cost,0)
            + nvl(mt.total_stop_cost,0))
   into l_plan_value
   from mst_trips mt
   where mt.plan_id = p_plan_id;
*/
-- Changed as per bug # 3509257
-- The Plan value should be calculated from the selling price at the delivery lines.
-- The data model supports the selling price in the mst_delivery_details table
-- as unit price column, which is directly snapshot from the wsh_delivery_details.unit_price.

  select sum(nvl(mdd.unit_price,0)* mdd.requested_quantity)
  into l_plan_value
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  where mdd.plan_id = p_plan_id
  and mda.plan_id = mdd.plan_id
  and mda.delivery_detail_id = mdd.delivery_detail_id
  and mda.parent_delivery_detail_id is null;

   return l_plan_value;
exception
when others then
	 return 0;
end r_plan_value;


function r_plan_alloc_cost (p_plan_id in number)
return number
is l_plan_alloc_cost number;
begin
  select sum(nvl(mdl.allocated_transport_cost,0)
          + (nvl(allocated_fac_shp_hand_cost, 0) + nvl(allocated_fac_rec_hand_cost, 0))
          + nvl(mdl.allocated_fac_loading_cost,0)
          + nvl(mdl.allocated_fac_unloading_cost,0)) allocated_cost
  into l_plan_alloc_cost
  from mst_delivery_legs mdl
  where mdl.plan_id = p_plan_id;

  return l_plan_alloc_cost;
exception
when others then
	 return 0;
end r_plan_alloc_cost;

/*
function r_total_orders_myfac(p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2, p_activity_type in varchar2)
 return number is
      l_total_orders number :=0;
 begin
 */
/*
   if p_activity_type is null then
      select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
           mst_trip_stops mts,
           mst_delivery_legs mdl,
           mst_deliveries md,
           mst_delivery_details mdd,
           mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   (mdl.pick_up_stop_id = mts.stop_id or
            mdl.drop_off_stop_id = mts.stop_id)
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;
    elsif p_activity_type = 'L' then
      select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md,
         mst_delivery_details mdd,
         mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   mdl.pick_up_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;
    elsif p_activity_type = 'U' then
      select count(mdd.delivery_detail_id)
      into l_total_orders
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md,
         mst_delivery_details mdd,
         mst_delivery_assignments mda
      where mt.plan_id = p_plan_id
      and   mt.mode_of_transport = p_mode
      and   mt.trip_id = mts.trip_id
      and   mt.trip_id = mdl.trip_id
      and   mdl.drop_off_stop_id = mts.stop_id
      and   mts.stop_location_id = p_my_fac_location_id
      and   mdl.delivery_id = md.delivery_id
      and   md.delivery_id = mda.delivery_id
      and   mda.delivery_detail_id = mdd.delivery_detail_id
      and   mda.parent_delivery_detail_id is null
      and   mdd.split_from_delivery_detail_id is null;
    end if;
*/
/*
  select count(distinct mdd.source_header_number)
  into l_total_orders
  from mst_delivery_details mdd,
       mst_deliveries md,
       mst_delivery_assignments mda
  where md.plan_id = mda.plan_id
  and md.delivery_id = mda.delivery_id
  and md.delivery_id in
          (select mdl.delivery_id
           from mst_trips t,
                mst_trip_stops ts,
                mst_delivery_legs mdl
           where mdl.plan_id = md.plan_id
           and ts.plan_id  = mdl.plan_id
           and ts.stop_id  = mdl.pick_up_stop_id
           and ts.stop_location_id = p_my_fac_location_id
           and ts.plan_id  = t.plan_id
           and ts.trip_id  = t.trip_id
           and t.mode_of_transport = p_mode)
  and   mda.plan_id = mdd.plan_id
  and   mda.delivery_detail_id = mdd.delivery_detail_id
  and   md.plan_id = p_plan_id
  and   mdd.container_flag = 2
  and   mdd.split_from_delivery_detail_id is null;

  return l_total_orders;
  exception
    when others then
        return 0;
 end r_total_orders_myfac;
*/


function r_total_cost_myfac  (p_plan_id in number,p_my_fac_location_id in number, p_mode in varchar2)
      return number is

      l_total_cost number;
      l_total_departing_cost number;
      l_total_arriving_cost number;

      cursor departing_delivery_leg(l_plan_id in number,l_my_fac_location_id in number, l_mode in varchar2) is
      select sum( nvl(mdl.allocated_fac_loading_cost,0)
                + nvl(mdl.allocated_fac_shp_hand_cost,0)
		+ nvl(mdl.allocated_transport_cost,0)) total_departing_cost
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
      where mt.plan_id = l_plan_id
      and   mt.mode_of_transport = l_mode
      and   mt.plan_id = mts.plan_id
      and   mt.trip_id = mts.trip_id
      and   mts.plan_id = mdl.plan_id
      and   mdl.pick_up_stop_id = mts.stop_id
      and   mts.stop_location_id = l_my_fac_location_id;

      cursor arriving_delivery_leg(l_plan_id in number,l_my_fac_location_id in number, l_mode in varchar2) is
      select sum( nvl(mdl.allocated_fac_unloading_cost,0)
                + nvl(mdl.allocated_fac_rec_hand_cost,0)
		+ nvl(mdl.allocated_transport_cost,0)) total_arriving_cost
      from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl
      where mt.plan_id = l_plan_id
      and   mt.mode_of_transport = l_mode
      and   mt.plan_id = mts.plan_id
      and   mt.trip_id = mts.trip_id
      and   mts.plan_id = mdl.plan_id
      and   mdl.drop_off_stop_id = mts.stop_id
      and   mts.stop_location_id = l_my_fac_location_id;
   begin
     open departing_delivery_leg(p_plan_id, p_my_fac_location_id, p_mode);
     fetch departing_delivery_leg into l_total_departing_cost;
     close departing_delivery_leg;
     open arriving_delivery_leg(p_plan_id, p_my_fac_location_id, p_mode);
     fetch arriving_delivery_leg into l_total_arriving_cost;
     close arriving_delivery_leg;

     l_total_cost := nvl(l_total_departing_cost,0) + nvl(l_total_arriving_cost,0);

     return l_total_cost;
  end r_total_cost_myfac;



--includes both loading and unloading weight. Name not changed to avoid regression
function r_loading_weight_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
      return number is
      l_loading_weight number;
   begin
    select sum(md.gross_weight)
    into l_loading_weight
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mts.trip_id = mt.trip_id
    and   mts.plan_id = mt.plan_id
    and   mdl.plan_id = mt.plan_id
    and   mdl.trip_id = mt.trip_id
    and   (mdl.pick_up_stop_id = mts.stop_id or mdl.drop_off_stop_id = mts.stop_id)
    and   mts.stop_location_id = p_my_fac_location_id
    and   md.delivery_id = mdl.delivery_id
    and   md.plan_id = mt.plan_id;
    if l_loading_weight IS NULL then
        l_loading_weight := 0;
    end if;
    return l_loading_weight;
  exception
    when others then
        return 0;
  end r_loading_weight_myfac;


--includes both loading and unloading cube. Name not changed to avoid regression
function r_loading_cube_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
      return number is
      l_loading_cube number;
   begin
    select sum(md.volume)
    into l_loading_cube
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mts.trip_id = mt.trip_id
    and   mts.plan_id = mt.plan_id
    and   mdl.plan_id = mt.plan_id
    and   mdl.trip_id = mt.trip_id
    and   (mdl.pick_up_stop_id = mts.stop_id or mdl.drop_off_stop_id = mts.stop_id)
    and   mts.stop_location_id = p_my_fac_location_id
    and   md.delivery_id = mdl.delivery_id
    and   md.plan_id = mt.plan_id;
    if l_loading_cube IS NULL then
        l_loading_cube := 0;
    end if;
    return l_loading_cube;
  exception
    when others then
        return 0;
  end r_loading_cube_myfac;



--includes both loading and unloading pieces. Name not changed to avoid regression
function r_loading_piece_myfac  (p_plan_id in number, p_my_fac_location_id in number, p_mode in varchar2)
      return number is
      l_loading_pieces number;
   begin
    select sum(md.number_of_pieces)
    into l_loading_pieces
    from mst_trips mt,
         mst_trip_stops mts,
         mst_delivery_legs mdl,
         mst_deliveries md
    where mt.plan_id = p_plan_id
    and   mt.mode_of_transport = p_mode
    and   mts.trip_id = mt.trip_id
    and   mts.plan_id = mt.plan_id
    and   mdl.plan_id = mt.plan_id
    and   mdl.trip_id = mt.trip_id
    and   (mdl.pick_up_stop_id = mts.stop_id or mdl.drop_off_stop_id = mts.stop_id)
    and   mts.stop_location_id = p_my_fac_location_id
    and   md.delivery_id = mdl.delivery_id
    and   md.plan_id = mt.plan_id;
    if l_loading_pieces IS NULL then
        l_loading_pieces := 0;
    end if;
    return l_loading_pieces;
  exception
    when others then
        return 0;
  end r_loading_piece_myfac;




function r_value_myfac(p_plan_id in number, p_facility_id in number)
return number
is
l_total_value number;
begin
 select sum(nvl(mt.total_basic_transport_cost,0)
          + nvl(mt.total_accessorial_cost,0)
          + nvl(mt.total_handling_cost,0)
	  + nvl(mt.total_layover_cost,0)
	  + nvl(mt.total_load_unload_cost,0)
	  + nvl(mt.total_stop_cost,0))
 into l_total_value
 from mst_trips mt
 where mt.plan_id = p_plan_id
 and (mt.origin_location_id IN (select distinct fte.location_id
                               from fte_location_parameters fte
	 		       where fte.facility_id = p_facility_id)
      or mt.destination_location_id IN (select distinct fte.location_id
                                       from fte_location_parameters fte
                                       where fte.facility_id = p_facility_id)
     );

 return l_total_value;

 exception
 when others then
   return 0;
end r_value_myfac;

function r_total_orders_myfac_general (p_plan_id in number, p_my_fac_location_id in number)
return number is l_total_orders number;
begin
/*  l_total_orders := nvl(r_total_orders_myfac(p_plan_id, p_facility_id, 'TRUCK', 'L'),0)
 		  + nvl(r_total_orders_myfac(p_plan_id, p_facility_id, 'LTL', 'L'),0)
 		  + nvl(r_total_orders_myfac(p_plan_id, p_facility_id, 'PARCEL', 'L'),0);
*/


-- As per bug # 3364598, this change is done for calculating total orders for myfac.

   select count(distinct mdd.source_header_number)
   into l_total_orders
   from mst_delivery_details mdd,
        mst_deliveries md,
        mst_delivery_assignments mda
   where md.plan_id     = mda.plan_id
   and   md.delivery_id = mda.delivery_id
   and   md.delivery_id in
                (select mdl.delivery_id
                 from mst_trips t,
                      mst_trip_stops ts,
                      mst_delivery_legs mdl
                 where mdl.plan_id = md.plan_id
                 and   ts.plan_id  = mdl.plan_id
                 and   (ts.stop_id  = mdl.pick_up_stop_id
                        or ts.stop_id = mdl.drop_off_stop_id)
                 and   ts.stop_location_id = p_my_fac_location_id
                 and   ts.plan_id  = t.plan_id
                 and   ts.trip_id  = t.trip_id)
   and   mda.plan_id = mdd.plan_id
   and   mda.delivery_detail_id = mdd.delivery_detail_id
   and   md.plan_id = p_plan_id
   and   mdd.container_flag = 2;

  return l_total_orders;

 exception
  when others then
   return 0;
end r_total_orders_myfac_general;

function r_total_weight_myfac (p_plan_id in number, p_facility_id in number)
return number is l_total_weight number;
begin
  l_total_weight := nvl(r_loading_weight_myfac(p_plan_id, p_facility_id, 'TRUCK'),0)
                  + nvl(r_loading_weight_myfac(p_plan_id, p_facility_id, 'LTL'),0)
                  + nvl(r_loading_weight_myfac(p_plan_id, p_facility_id, 'PARCEL'),0);

  return l_total_weight;

 exception
  when others then
    return 0;
end r_total_weight_myfac;


function r_total_cube_myfac (p_plan_id in number, p_facility_id in number)
return number is l_total_cube number;
begin
  l_total_cube := nvl(r_loading_cube_myfac(p_plan_id, p_facility_id, 'TRUCK'),0)
                + nvl(r_loading_cube_myfac(p_plan_id, p_facility_id, 'LTL'),0)
                + nvl(r_loading_cube_myfac(p_plan_id, p_facility_id, 'PARCEL'),0);

  return l_total_cube;

 exception
  when others then
    return 0;
end r_total_cube_myfac;


function r_total_pieces_myfac (p_plan_id in number, p_facility_id in number)
return number is l_total_pieces number;
begin
  l_total_pieces := nvl(r_loading_piece_myfac(p_plan_id, p_facility_id, 'TRUCK'),0)
                  + nvl(r_loading_piece_myfac(p_plan_id, p_facility_id, 'LTL'),0)
                  + nvl(r_loading_piece_myfac(p_plan_id, p_facility_id, 'PARCEL'),0);

  return l_total_pieces;

 exception
  when others then
    return 0;
end r_total_pieces_myfac;


function r_total_trans_cost_myfac (p_plan_id in number, p_facility_id in number)
return number is l_total_trans_cost number;
begin
  l_total_trans_cost := nvl(r_total_cost_myfac(p_plan_id, p_facility_id, 'TRUCK'),0)
                      + nvl(r_total_cost_myfac(p_plan_id, p_facility_id, 'LTL'),0)
                      + nvl(r_total_cost_myfac(p_plan_id, p_facility_id, 'PARCEL'),0);

  return l_total_trans_cost;

  exception
   when others then
     return 0;
end r_total_trans_cost_myfac;


function r_value_origin(p_plan_id in number, p_origin_id in number)
return number
is
l_total_value number;
begin
	 select sum(nvl(mt.total_basic_transport_cost,0)
                  + nvl(mt.total_accessorial_cost,0)
	  	  + nvl(mt.total_handling_cost,0)
		  + nvl(mt.total_layover_cost,0)
		  + nvl(mt.total_load_unload_cost,0)
		  + nvl(mt.total_stop_cost,0))
	 into l_total_value
	 from mst_trips mt
	 where mt.plan_id = p_plan_id
	 and mt.origin_location_id = p_origin_id;

	 return l_total_value;

	 exception
	 when others then
	 	  return 0;
end r_value_origin;




function r_get_alloc_cost_origin (p_plan_id in number, p_origin_id in number)
return number
is l_alloc_cost number;
begin
   select sum(nvl(mdl.allocated_transport_cost,0)
           + (nvl(allocated_fac_shp_hand_cost, 0) + nvl(allocated_fac_rec_hand_cost, 0))
 	   + nvl(mdl.allocated_fac_loading_cost,0)
	   + nvl(mdl.allocated_fac_unloading_cost,0)) allocated_cost
   into l_alloc_cost
   from mst_delivery_legs mdl
   , mst_trips mt
   where mdl.plan_id = mt.plan_id
   and mdl.trip_id = mt.trip_id
   and mt.plan_id = p_plan_id
   and mt.origin_location_id = p_origin_id;

   return l_alloc_cost;

   exception
     when others then
	 	  return 0;

end r_get_alloc_cost_origin;




function r_get_total_orders_origin (p_plan_id in number, p_origin_id in number)
return number is
  l_count_origin_orders number;
begin
  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  into l_count_origin_orders
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.pickup_location_id = p_origin_id
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = p_plan_id;

  return l_count_origin_orders;

  exception
  when others then
    return 0;
end r_get_total_orders_origin;


function r_get_count_stops_origin (p_plan_id in number, p_origin_id in number)
return number is
  l_count_stops_origin number;
begin
  select count(*)
  into l_count_stops_origin
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = p_plan_id
	and mt.origin_location_id = p_origin_id
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops > 2;

  return l_count_stops_origin;

  exception
  when others then
    return 0;
end r_get_count_stops_origin;


function r_get_total_weight_origin (p_plan_id in number, p_origin_id in number)
return number is
  l_total_weight_origin number;
begin
  select sum(md.gross_weight)
  into l_total_weight_origin
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.pickup_location_id = p_origin_id;

  return l_total_weight_origin;

  exception
  when others then
    return 0;
end r_get_total_weight_origin;



function r_get_total_volume_origin (p_plan_id in number, p_origin_id in number)
return number is
  l_total_volume_origin number;
begin
  select sum(md.volume)
  into l_total_volume_origin
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.pickup_location_id = p_origin_id;

  return l_total_volume_origin;

  exception
  when others then
    return 0;
end r_get_total_volume_origin;




function r_get_total_pieces_origin (p_plan_id in number, p_origin_id in number)
return number is
  l_total_pieces_origin number;
begin
  select sum(md.number_of_pieces)
  into l_total_pieces_origin
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.pickup_location_id = p_origin_id;

  return l_total_pieces_origin;

  exception
  when others then
    return 0;
end r_get_total_pieces_origin;



function r_get_trip_count_origin (p_plan_id in number, p_origin_id in number, p_mode_of_transport in varchar2)
return number is
  l_trip_count number;
begin
  select count (1)
  into 	l_trip_count
  from	mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.origin_location_id = p_origin_id;

  return l_trip_count;

  exception
  when others then
    return 0;
end r_get_trip_count_origin;



function r_get_cost_origin (p_plan_id in number, p_origin_id in number, p_mode_of_transport in varchar2)
return number is
  l_cost number;
begin
/*
  select nvl(sum(nvl(mt.total_accessorial_cost,0)
            + nvl(mt.total_basic_transport_cost,0)
	    + nvl(mt.total_layover_cost,0)
	    + nvl(mt.total_handling_cost,0)
	    + nvl(mt.total_load_unload_cost,0)
	    + nvl(mt.total_stop_cost,0)),0)
  into l_cost
  from 	mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.origin_location_id = p_origin_id;
*/

  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
               + nvl(mdl.ALLOCATED_FAC_SHP_HAND_COST,0)
	       + nvl(mdl.ALLOCATED_FAC_REC_HAND_COST,0)
	       + nvl(mdl.allocated_transport_cost,0)),0)
  into l_cost
  from mst_trips mt
  , mst_trip_stops mts
  , mst_delivery_legs mdl
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.origin_location_id = p_origin_id
  and mts.plan_id = mt.plan_id
  and mts.trip_id = mt.trip_id
  and mts.stop_location_id = mt.origin_location_id
  and mdl.plan_id = mt.plan_id
  and mdl.trip_id = mt.trip_id;

  return l_cost;

  exception
  when others then
    return 0;
end r_get_cost_origin;


function r_get_count_dtl_origin (p_plan_id in number, p_origin_id in number)
return number is
  total_dtl number := 0;
begin
  select count(*)
  into total_dtl
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
	where mt.plan_id = p_plan_id
	and mt.origin_location_id = p_origin_id
	and mt.mode_of_transport = 'TRUCK'
	and mts.plan_id = mt.plan_id
	and mts.trip_id = mt.trip_id
	group by mt.trip_id) temp
  where temp.num_stops = 2;

  return total_dtl;

  exception
  when others then
    return 0;
end r_get_count_dtl_origin;



function r_value_dest(p_plan_id in number, p_dest_id in number)
return number is
  l_total_value number;
begin
  select sum(nvl(mt.total_basic_transport_cost,0)
           + nvl(mt.total_accessorial_cost,0)
           + nvl(mt.total_handling_cost,0)
	   + nvl(mt.total_layover_cost,0)
	   + nvl(mt.total_load_unload_cost,0)
	   + nvl(mt.total_stop_cost,0))
  into l_total_value
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.destination_location_id = p_dest_id;

  return l_total_value;

  exception
  when others then
    return 0;
end r_value_dest;



function r_get_alloc_cost_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_alloc_cost number;
begin
  select sum(nvl(mdl.allocated_transport_cost,0)
          + (nvl(allocated_fac_shp_hand_cost, 0) + nvl(allocated_fac_rec_hand_cost, 0))
	  + nvl(mdl.allocated_fac_loading_cost,0)
	  + nvl(mdl.allocated_fac_unloading_cost,0)) allocated_cost
  into l_alloc_cost
  from mst_delivery_legs mdl
  , mst_trips mt
  where mdl.plan_id = mt.plan_id
  and mdl.trip_id = mt.trip_id
  and mt.plan_id = p_plan_id
  and mt.destination_location_id = p_dest_id;

  return l_alloc_cost;

  exception
    when others then
      return 0;
end r_get_alloc_cost_dest;


function r_get_total_orders_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_count_dest_orders number;
begin
  select count(distinct nvl(mdd.split_from_delivery_detail_id, mdd.delivery_detail_id))
  into l_count_dest_orders
  from mst_delivery_details mdd
  , mst_delivery_assignments mda
  , mst_deliveries md
  where md.plan_id = mda.plan_id
  and   md.delivery_id = mda.delivery_id
  and   md.dropoff_location_id = p_dest_id
  and   mdd.plan_id = mda.plan_id
  and   mdd.delivery_detail_id = mda.delivery_detail_id
  and   mda.parent_delivery_detail_id is null
  and   md.plan_id = p_plan_id;

  return l_count_dest_orders;

  exception
  when others then
    return 0;
end r_get_total_orders_dest;


function r_get_count_stops_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_count_stops_dest number;
begin
  select count(*)
  into l_count_stops_dest
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
        where mt.plan_id = p_plan_id
        and mt.destination_location_id = p_dest_id
        and mts.plan_id = mt.plan_id
        and mts.trip_id = mt.trip_id
        group by mt.trip_id) temp
  where temp.num_stops > 2;

  return l_count_stops_dest;

  exception
  when others then
    return 0;
end r_get_count_stops_dest;


function r_get_total_weight_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_total_weight_dest number;
begin
  select sum(md.gross_weight)
  into l_total_weight_dest
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.dropoff_location_id = p_dest_id;

  return l_total_weight_dest;

  exception
  when others then
    return 0;
end r_get_total_weight_dest;



function r_get_total_volume_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_total_volume_dest number;
begin
  select sum(md.volume)
  into l_total_volume_dest
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.dropoff_location_id = p_dest_id;

  return l_total_volume_dest;

  exception
  when others then
    return 0;
end r_get_total_volume_dest;


function r_get_total_pieces_dest (p_plan_id in number, p_dest_id in number)
return number is
  l_total_pieces_dest number;
begin
  select sum(md.number_of_pieces)
  into l_total_pieces_dest
  from mst_deliveries md
  where md.plan_id = p_plan_id
  and md.dropoff_location_id = p_dest_id;

  return l_total_pieces_dest;

  exception
  when others then
    return 0;
end r_get_total_pieces_dest;



function r_get_trip_count_dest (p_plan_id in number, p_dest_id in number, p_mode_of_transport in varchar2)
return number is
  l_trip_count number;
begin
  select count (1)
  into 	l_trip_count
  from	mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.destination_location_id = p_dest_id;

  return l_trip_count;

  exception
  when others then
    return 0;
end r_get_trip_count_dest;



function r_get_cost_dest (p_plan_id in number, p_dest_id in number, p_mode_of_transport in varchar2)
return number is
  l_cost number;
begin
/*
  select nvl(sum(nvl(mt.total_accessorial_cost,0)
            + nvl(mt.total_basic_transport_cost,0)
	    + nvl(mt.total_layover_cost,0)
	    + nvl(mt.total_handling_cost,0)
	    + nvl(mt.total_load_unload_cost,0)
	    + nvl(mt.total_stop_cost,0)),0)
  into l_cost
  from 	mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.destination_location_id = p_dest_id;
*/

  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
               + nvl(mdl.ALLOCATED_FAC_SHP_HAND_COST,0)
	       + nvl(mdl.ALLOCATED_FAC_REC_HAND_COST,0)
	       + nvl(mdl.allocated_transport_cost,0)),0)
  into l_cost
  from mst_trips mt
  , mst_trip_stops mts
  , mst_delivery_legs mdl
  where mt.plan_id = p_plan_id
  and mt.mode_of_transport = p_mode_of_transport
  and mt.destination_location_id = p_dest_id
  and mts.plan_id = mt.plan_id
  and mts.trip_id = mt.trip_id
  and mts.stop_location_id = mt.destination_location_id
  and mdl.plan_id = mt.plan_id
  and mdl.trip_id = mt.trip_id;

  return l_cost;

  exception
  when others then
    return 0;
end r_get_cost_dest;


function r_get_count_dtl_dest (p_plan_id in number, p_dest_id in number)
return number is
  total_dtl number := 0;
begin
  select count(*)
  into total_dtl
  from (select distinct mt.trip_id, count(*) num_stops
        from mst_trips mt
        , mst_trip_stops mts
        where mt.plan_id = p_plan_id
        and mt.destination_location_id = p_dest_id
	and mt.mode_of_transport = 'TRUCK'
        and mts.plan_id = mt.plan_id
        and mts.trip_id = mt.trip_id
        group by mt.trip_id) temp
  where temp.num_stops = 2;

  return total_dtl;

  exception
    when others then
      return 0;

end r_get_count_dtl_dest;



function r_value_cust(p_plan_id in number, p_customer_id in number)
return number is
   l_total_value number;
begin
 select sum(nvl(mt.total_basic_transport_cost,0)
            + nvl(mt.total_accessorial_cost,0)
 	    + nvl(mt.total_handling_cost,0)
	    + nvl(mt.total_layover_cost,0)
	    + nvl(mt.total_load_unload_cost,0)
	    + nvl(mt.total_stop_cost,0))
 into l_total_value
 from mst_trips mt
 where mt.plan_id = p_plan_id
 and mt.trip_id IN
                (select distinct mts.trip_id
                 from mst_trip_stops mts
                 , mst_delivery_legs mdl
                 , mst_deliveries md
                 where md.plan_id = mdl.plan_id
                 and md.customer_id = p_customer_id
                 and mts.plan_id = md.plan_id
                 and mts.stop_location_id = md.dropoff_location_id
                 and mdl.plan_id = md.plan_id
                 and mdl.delivery_id = md.delivery_id
                 and mdl.trip_id = mts.trip_id
                 and mdl.drop_off_stop_id = mts.stop_id);

 return l_total_value;

 exception
   when others then
     return 0;
end r_value_cust;





function r_get_alloc_cost_cust (p_plan_id in number, p_customer_id in number)
return number
is l_alloc_cost number;
begin
   select sum(nvl(mdl.allocated_transport_cost,0)
              + (nvl(allocated_fac_shp_hand_cost, 0) + nvl(allocated_fac_rec_hand_cost, 0))
 	      + nvl(mdl.allocated_fac_loading_cost,0)
	      + nvl(mdl.allocated_fac_unloading_cost,0)) allocated_cost
   into l_alloc_cost
   from mst_delivery_legs mdl
   where mdl.plan_id = p_plan_id
   and mdl.trip_id IN
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mdl.plan_id
                    and md.customer_id = p_customer_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id);

   return l_alloc_cost;

   exception
     when others then
	 return 0;
end r_get_alloc_cost_cust;



FUNCTION r_get_count_stops_cust (p_plan_id in number, p_customer_id in number)
RETURN number
IS
  l_count_stops number;
BEGIN
  select count(mt.trip_id)
  into l_count_stops
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_customer_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >2
        group by ts.trip_id);

  RETURN l_count_stops;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
 END r_get_count_stops_cust;


FUNCTION r_get_trip_count_cust (p_plan_id in number, p_customer_id in number, p_mode_of_transport in varchar2)
RETURN number IS
  l_trip_count number;
BEGIN
  select count(mt.trip_id)
  into l_trip_count
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.mode_of_transport = p_mode_of_transport
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_customer_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id);

  RETURN l_trip_count;

  EXCEPTION
    WHEN OTHERS THEN
	RETURN 0;
 END r_get_trip_count_cust;


FUNCTION r_get_cost_cust (p_plan_id in number, p_customer_id in number, p_mode_of_transport in varchar2)
RETURN number IS
  l_cost number;
BEGIN
/*
SELECT SUM (nvl(MT.TOTAL_ACCESSORIAL_COST,0)
            + nvl(MT.TOTAL_BASIC_TRANSPORT_COST,0)
	    + nvl(MT.TOTAL_LAYOVER_COST,0)
	    + nvl(MT.TOTAL_HANDLING_COST,0)
	    + nvl(MT.TOTAL_LOAD_UNLOAD_COST,0)
	    + nvl(MT.TOTAL_STOP_COST,0))
  INTO l_cost
  FROM 	MST_TRIPS MT
  WHERE MT.PLAN_ID = p_plan_id
  AND MT.MODE_OF_TRANSPORT = p_mode_of_transport
  AND MT.TRIP_ID IN
                (SELECT DISTINCT MTS.TRIP_ID
                 FROM MST_TRIP_STOPS MTS
                 , MST_DELIVERY_LEGS MDL
                 , MST_DELIVERIES MD
                 WHERE MD.PLAN_ID = MT.PLAN_ID
                 AND MD.CUSTOMER_ID = p_customer_id
                 AND MTS.PLAN_ID = MD.PLAN_ID
                 AND MTS.STOP_LOCATION_ID = MD.DROPOFF_LOCATION_ID
                 AND MDL.PLAN_ID = MD.PLAN_ID
                 AND MDL.DELIVERY_ID = MD.DELIVERY_ID
                 AND MDL.TRIP_ID = MTS.TRIP_ID
                 AND MDL.DROP_OFF_STOP_ID = MTS.STOP_ID);
*/

  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
               + nvl(mdl.ALLOCATED_FAC_SHP_HAND_COST,0)
               + nvl(mdl.ALLOCATED_FAC_REC_HAND_COST,0)
	       + nvl(mdl.allocated_transport_cost,0)),0)
  into l_cost
  from  mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = p_plan_id
  and   md.customer_id = p_customer_id
  and   md.plan_id = mdl.plan_id
  and   md.delivery_id = mdl.delivery_id
  and   mt.plan_id = mdl.plan_id
  and   mt.trip_id = mdl.trip_id
  and   mt.mode_of_transport = p_mode_of_transport;

  RETURN l_cost;

EXCEPTION
 WHEN OTHERS THEN
  RETURN 0;
END r_get_cost_cust;


FUNCTION r_get_count_dtl_cust (p_plan_id in number, p_customer_id in number)
RETURN number IS
  total_dtl number := 0;
BEGIN
  select count(mt.trip_id)
  into total_dtl
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.customer_id = p_customer_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.dropoff_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.drop_off_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) =2
        group by ts.trip_id);

RETURN total_dtl;

EXCEPTION
 WHEN OTHERS THEN
  RETURN 0;
END r_get_count_dtl_cust;



function r_value_supp(p_plan_id in number, p_supplier_id in number)
return number is
  l_total_value number;
begin
 select sum(nvl(mt.total_basic_transport_cost,0)
            + nvl(mt.total_accessorial_cost,0)
 	    + nvl(mt.total_handling_cost,0)
	    + nvl(mt.total_layover_cost,0)
	    + nvl(mt.total_load_unload_cost,0)
	    + nvl(mt.total_stop_cost,0))
 into l_total_value
 from mst_trips mt
 where mt.plan_id = p_plan_id
 and mt.trip_id IN
                (select distinct mts.trip_id
                 from mst_trip_stops mts
                 , mst_delivery_legs mdl
                 , mst_deliveries md
                 where md.plan_id = mdl.plan_id
                 and md.supplier_id = p_supplier_id
                 and mts.plan_id = md.plan_id
                 and mts.stop_location_id = md.pickup_location_id
                 and mdl.plan_id = md.plan_id
                 and mdl.delivery_id = md.delivery_id
                 and mdl.trip_id = mts.trip_id
                 and mdl.pick_up_stop_id = mts.stop_id);

  return l_total_value;

  exception
   when others then
    return 0;
end r_value_supp;




function r_get_alloc_cost_supp (p_plan_id in number, p_supplier_id in number)
return number
is l_alloc_cost number;
begin
   select sum(nvl(mdl.allocated_transport_cost,0)
              + (nvl(allocated_fac_shp_hand_cost, 0) + nvl(allocated_fac_rec_hand_cost, 0))
 	      + nvl(mdl.allocated_fac_loading_cost,0)
	      + nvl(mdl.allocated_fac_unloading_cost,0)) allocated_cost
   into l_alloc_cost
   from mst_delivery_legs mdl
   where mdl.plan_id = p_plan_id
   and mdl.trip_id IN
                (select distinct mts.trip_id
                 from mst_trip_stops mts
                 , mst_delivery_legs mdl
                 , mst_deliveries md
                 where md.plan_id = mdl.plan_id
                 and md.supplier_id = p_supplier_id
                 and mts.plan_id = md.plan_id
                 and mts.stop_location_id = md.pickup_location_id
                 and mdl.plan_id = md.plan_id
                 and mdl.delivery_id = md.delivery_id
                 and mdl.trip_id = mts.trip_id
                 and mdl.pick_up_stop_id = mts.stop_id);

   return l_alloc_cost;

   exception
     when others then
	return 0;
end r_get_alloc_cost_supp;




FUNCTION r_get_count_stops_supp (p_plan_id in number, p_supplier_id in number)
RETURN number IS
  l_count_stops number;
BEGIN
  select count(mt.trip_id)
  into l_count_stops
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_supplier_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) >2
        group by ts.trip_id);

RETURN l_count_stops;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END r_get_count_stops_supp;



FUNCTION r_get_trip_count_supp (p_plan_id in number, p_supplier_id in number, p_mode_of_transport in varchar2)
RETURN number IS
  l_trip_count number;
BEGIN
  select count(mt.trip_id)
  into l_trip_count
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.mode_of_transport = p_mode_of_transport
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_supplier_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id);

  RETURN l_trip_count;

  EXCEPTION
   WHEN OTHERS THEN
    RETURN 0;
END r_get_trip_count_supp;



FUNCTION r_get_cost_supp (p_plan_id in number, p_supplier_id in number, p_mode_of_transport in varchar2)
RETURN number IS
  l_cost number;
BEGIN
/*
SELECT SUM (nvl(MT.TOTAL_ACCESSORIAL_COST,0)
	          + nvl(MT.TOTAL_BASIC_TRANSPORT_COST,0)
		  + nvl(MT.TOTAL_LAYOVER_COST,0)
		  + nvl(MT.TOTAL_HANDLING_COST,0)
		  + nvl(MT.TOTAL_LOAD_UNLOAD_COST,0)
		  + nvl(MT.TOTAL_STOP_COST,0))
	INTO l_cost
	FROM 	MST_TRIPS MT
	WHERE MT.PLAN_ID = p_plan_id
        AND MT.MODE_OF_TRANSPORT = p_mode_of_transport
	AND MT.TRIP_ID IN
                   (SELECT DISTINCT MTS.TRIP_ID
                    FROM MST_TRIP_STOPS MTS
                    , MST_DELIVERY_LEGS MDL
                    , MST_DELIVERIES MD
                    WHERE MD.PLAN_ID = MT.PLAN_ID
                    AND MD.SUPPLIER_ID = p_supplier_id
                    AND MTS.PLAN_ID = MD.PLAN_ID
                    AND MTS.STOP_LOCATION_ID = MD.PICKUP_LOCATION_ID
                    AND MDL.PLAN_ID = MD.PLAN_ID
                    AND MDL.DELIVERY_ID = MD.DELIVERY_ID
                    AND MDL.TRIP_ID = MTS.TRIP_ID
                    AND MDL.PICK_UP_STOP_ID = MTS.STOP_ID);
*/

  select nvl(sum(nvl(mdl.allocated_fac_loading_cost,0)
               + nvl(mdl.allocated_fac_unloading_cost,0)
               + nvl(mdl.ALLOCATED_FAC_SHP_HAND_COST,0)
               + nvl(mdl.ALLOCATED_FAC_REC_HAND_COST,0)
	       + nvl(mdl.allocated_transport_cost,0)),0)
  into l_cost
  from  mst_deliveries md
  , mst_delivery_legs mdl
  , mst_trips mt
  where md.plan_id = p_plan_id
  and   md.supplier_id = p_supplier_id
  and   md.plan_id = mdl.plan_id
  and   md.delivery_id = mdl.delivery_id
  and   mt.plan_id = mdl.plan_id
  and   mt.trip_id = mdl.trip_id
  and   mt.mode_of_transport = p_mode_of_transport;

RETURN l_cost;

EXCEPTION
 WHEN OTHERS THEN
  RETURN 0;
END r_get_cost_supp;



FUNCTION r_get_count_dtl_supp (p_plan_id in number, p_supplier_id in number)
RETURN number IS
  total_dtl number := 0;
BEGIN
  select count(mt.trip_id)
  into total_dtl
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and   mt.trip_id in
                   (select distinct mts.trip_id
                    from mst_trip_stops mts
                    , mst_delivery_legs mdl
                    , mst_deliveries md
                    where md.plan_id = mt.plan_id
                    and md.supplier_id = p_supplier_id
                    and mts.plan_id = md.plan_id
                    and mts.stop_location_id = md.pickup_location_id
                    and mdl.plan_id = md.plan_id
                    and mdl.delivery_id = md.delivery_id
                    and mdl.trip_id = mts.trip_id
                    and mdl.pick_up_stop_id = mts.stop_id)
  and   mt.mode_of_transport = 'TRUCK'
  and   EXISTS
       (select ts.trip_id
        from mst_trip_stops ts
        where ts.plan_id = mt.plan_id
        and   ts.trip_id = mt.trip_id
        having count(ts.stop_id) =2
        group by ts.trip_id);

RETURN total_dtl;

EXCEPTION
 WHEN OTHERS THEN
  RETURN 0;
END r_get_count_dtl_supp;


function r_get_wait_time_at_stop (p_plan_id in number, p_stop_id in number, p_trip_id in number)
return varchar2 is
l_wait_time varchar2(20) := null;
l_arr_time date;
l_dep_time date;
l_wait_hrs_min number;
l_wait_hrs number;
l_wait_min number;

begin

select mts.planned_arrival_date, mts.planned_departure_date
into l_arr_time, l_dep_time
from mst_trip_stops mts
where mts.plan_id = p_plan_id
and mts.trip_id = p_trip_id
and mts.stop_id = p_stop_id;

if l_dep_time > l_arr_time then
   select (mts.planned_departure_date - mts.planned_arrival_date) * 24
        , TRUNC((mts.planned_departure_date - mts.planned_arrival_date) * 24)
   into l_wait_hrs_min, l_wait_hrs
   from mst_trip_stops mts
   where mts.plan_id = p_plan_id
   and mts.trip_id = p_trip_id
   and mts.stop_id = p_stop_id;

l_wait_min := (l_wait_hrs_min - l_wait_hrs)*60;

l_wait_time := CONCAT(CONCAT(TO_CHAR(l_wait_hrs, '99'), ':'), TO_CHAR(l_wait_min, '99'));

end if;

return l_wait_time;

exception
when others then
	 return null;
end r_get_wait_time_at_stop;



function r_get_prev_carr_detail (p_plan_id in number,p_delivery_id in number,p_trip_id in number, p_stop_location_id in number, p_identifier in varchar2)
return number
is

l_trip_id number := 0;
l_prev_carr number := 0;
l_carr_cost number := 0;

begin

select mt.carrier_id, mt.trip_id
into l_prev_carr, l_trip_id
from mst_delivery_legs mdl
, mst_trips mt
where mdl.plan_id = p_plan_id
and mdl.delivery_id = p_delivery_id
and mdl.trip_id <> p_trip_id
and mt.plan_id = mdl.plan_id
and mt.trip_id = mdl.trip_id
and (mdl.pick_up_stop_id IN (select mts.stop_id from mst_trip_stops mts
						   		   			   where mts.plan_id = p_plan_id
											   and mts.stop_location_id = p_stop_location_id)
    or mdl.drop_off_stop_id IN (select mts.stop_id from mst_trip_stops mts
   						  		  			  where mts.plan_id = p_plan_id
											  and mts.stop_location_id = p_stop_location_id)
    );

if p_identifier = 'F' then
  return nvl(l_prev_carr,0);
elsif p_identifier = 'C' then
  select nvl(mt.total_handling_cost,0) -- + mt.total_load_unload_cost)
  into l_carr_cost
  from mst_trips mt
  where mt.plan_id = p_plan_id
  and mt.trip_id = l_trip_id;
end if;

return nvl(l_carr_cost,0);

exception
when others then
  return 0;

end r_get_prev_carr_detail;



function r_get_prev_stop_seqnum (p_plan_id in number, p_trip_id in number, p_curr_seq_num in number)
return number is
l_seq_num number := 0;
exit_loop_flag number := 0;

cursor seq_num_cur is
select mts.stop_sequence_number
from mst_trip_stops mts
where mts.plan_id = p_plan_id
and mts.trip_id = p_trip_id
order by mts.stop_sequence_number desc;

begin

open seq_num_cur;
loop
fetch seq_num_cur into l_seq_num;
  exit when seq_num_cur%NOTFOUND;

  if exit_loop_flag = 1 then
    return l_seq_num;
  end if;

  if p_curr_seq_num = l_seq_num then
    exit_loop_flag := 1;
  end if;

end loop;
close seq_num_cur;

return l_seq_num;

exception
when others then
  return 0;

end r_get_prev_stop_seqnum;





function r_get_prev_trip_detail (p_plan_id in number, p_trip_id in number, p_curr_seq_num in number, p_identifier in varchar2)
return number
is
p_min_seq_num number := 0;
p_ret_val number := 0;

begin

select min(mts.stop_sequence_number)
into p_min_seq_num
from mst_trip_stops mts
where mts.plan_id = p_plan_id
and mts.trip_id = p_trip_id;

if p_curr_seq_num = p_min_seq_num then
   return p_ret_val;
else
	if p_identifier = 'D' then
		select mts.distance_to_next_stop
		into p_ret_val
		from mst_trip_stops mts
		where mts.plan_id = p_plan_id
		and mts.trip_id = p_trip_id
		and mts.stop_sequence_number = r_get_prev_stop_seqnum (p_plan_id, p_trip_id, p_curr_seq_num);
	elsif p_identifier = 'T' then
		select mts.drv_time_to_next_stop
		into p_ret_val
		from mst_trip_stops mts
		where mts.plan_id = p_plan_id
		and mts.trip_id = p_trip_id
		and mts.stop_sequence_number = r_get_prev_stop_seqnum (p_plan_id, p_trip_id, p_curr_seq_num);
	elsif p_identifier = 'C' then
		select mts.distance_cost
		into p_ret_val
		from mst_trip_stops mts
		where mts.plan_id = p_plan_id
		and mts.trip_id = p_trip_id
		and mts.stop_sequence_number = r_get_prev_stop_seqnum (p_plan_id, p_trip_id, p_curr_seq_num);
	else
		return 0;
	end if;
end if;

	return p_ret_val;

Exception
when others then
return 0;
end r_get_prev_trip_detail;

FUNCTION r_get_pool_loc_detail (ret_type IN VARCHAR2
                              , loc_id   IN NUMBER)
RETURN VARCHAR2
IS
  l_code    VARCHAR2(5)  := NULL;
  l_name1   VARCHAR2(10) := NULL;
  l_address VARCHAR2(20) := NULL;
  l_city    VARCHAR2(10) := NULL;
  l_state   VARCHAR2(10) := NULL;
  l_zip     VARCHAR2(5)  := NULL;
  l_ret_val VARCHAR2(20) := NULL;

BEGIN
	SELECT substr(wl.location_code,1,5)
	, substr(mst_wb_util.get_name(loc_id),1,10)
	, substr(wl.address1,1,20)
	, substr(wl.city,1,10)
	, substr(wl.state,1,10)
	, substr(wl.postal_code,1,5)
	INTO l_code
	, l_name1
	, l_address
	, l_city
	, l_state
	, l_zip
	FROM wsh_locations wl
  WHERE wl.wsh_location_id = loc_id;

	IF ret_type = 'O' THEN
	  l_ret_val := l_code;
	ELSIF ret_type = 'N' THEN
	  l_ret_val := l_name1;
	ELSIF ret_type = 'A' THEN
	  l_ret_val := l_address;
	ELSIF ret_type = 'C' THEN
	  l_ret_val := l_city;
	ELSIF ret_type = 'S' THEN
	  l_ret_val := l_state;
	ELSIF ret_type = 'Z' THEN
	  l_ret_val := l_zip;
  END IF;

  RETURN l_ret_val;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END r_get_pool_loc_detail;


function r_dep_frm_dest(p_plan_id in number, p_trip_id in number, p_stop_location_id in number)
return varchar2 is latest_depart_date_frm_dest varchar2(20) := null;
begin
	 select substr(mst_wb_util.get_local_chardt(p_stop_location_id, min(mts.planned_departure_date)),1,20)
	 into latest_depart_date_frm_dest
	 from mst_delivery_legs mdl
	 , mst_trip_stops mts
	 where mdl.plan_id = p_plan_id
	 and mdl.delivery_id in (select distinct mdl1.delivery_id from mst_delivery_legs mdl1
					   		   							 	  where mdl1.plan_id = mdl.plan_id
														 	  and mdl1.trip_id = p_trip_id)
     and mdl.trip_id <> p_trip_id
	 and mts.plan_id = mdl.plan_id
	 and mts.trip_id = mdl.trip_id
	 and mts.stop_location_id = p_stop_location_id -- will be destination_location_id of the previous trip
	 and mdl.pick_up_stop_id in (select distinct mts1.stop_id from mst_trip_stops mts1
						  		  		   					  where mts1.plan_id = mts.plan_id
															  and mts1.trip_id = mts.trip_id);

     return latest_depart_date_frm_dest;

	 exception
	 when others then
	 	  return null;

end r_dep_frm_dest;



function r_get_order_cost(p_source_code in varchar2,p_source_header_number in varchar2)
return number is

l_order_cost number;

begin
  select sum(mdd.allocated_cost)
  into   l_order_cost
  from  mst_delivery_details mdd
  where mdd.source_code = p_source_code
  and   mdd.source_header_number = p_source_header_number;

  return l_order_cost;
EXCEPTION
   WHEN OTHERS THEN
       RETURN 0;
end r_get_order_cost;




function r_checkif_orig_ispool (p_plan_id in number,p_delivery_id in number,p_delivery_leg_id in number,p_pick_up_stop_id in number)
return varchar2 is
l_pool_indicator varchar2(1) := null;
l_loc_id number;
leg_pickup_loc_id number;

cursor pickup_loc_cur is
	select mt.destination_location_id
	from mst_deliveries md
	, mst_delivery_legs mdl
	, mst_trips mt
	where md.plan_id = p_plan_id
	and md.delivery_id = p_delivery_id
	and mdl.plan_id = md.plan_id
	and mdl.delivery_id = md.delivery_id
	and mdl.delivery_leg_id <> p_delivery_leg_id
	and mt.plan_id = mdl.plan_id
	and mt.trip_id = mdl.trip_id;

begin

select mts.stop_location_id
into leg_pickup_loc_id
from mst_trip_stops mts
where mts.plan_id = p_plan_id
and mts.stop_id = p_pick_up_stop_id;

open pickup_loc_cur;
loop
	fetch pickup_loc_cur into l_loc_id;
	exit when pickup_loc_cur%NOTFOUND;

	if l_loc_id = leg_pickup_loc_id then
	     l_pool_indicator := 'P';
		 return l_pool_indicator;
	end if;
end loop;
close pickup_loc_cur;

return l_pool_indicator;

end r_checkif_orig_ispool;





function r_checkif_dest_ispool (p_plan_id in number,p_delivery_id in number,p_delivery_leg_id in number,p_drop_off_stop_id in number)
return varchar2 is
l_pool_indicator varchar2(1) := null;
l_loc_id number;
leg_dropoff_loc_id number;

cursor dropoff_loc_cur is
	select mt.origin_location_id
	from mst_deliveries md
	, mst_delivery_legs mdl
	, mst_trips mt
	where md.plan_id = p_plan_id
	and md.delivery_id = p_delivery_id
	and mdl.plan_id = md.plan_id
	and mdl.delivery_id = md.delivery_id
	and mdl.delivery_leg_id <> p_delivery_leg_id
	and mt.plan_id = mdl.plan_id
	and mt.trip_id = mdl.trip_id;

begin

select mts.stop_location_id
into leg_dropoff_loc_id
from mst_trip_stops mts
where mts.plan_id = p_plan_id
and mts.stop_id = p_drop_off_stop_id;

open dropoff_loc_cur;
loop
	fetch dropoff_loc_cur into l_loc_id;
	exit when dropoff_loc_cur%NOTFOUND;

	if l_loc_id = leg_dropoff_loc_id then
	     l_pool_indicator := 'P';
		 return l_pool_indicator;
	end if;
end loop;
close dropoff_loc_cur;

return l_pool_indicator;

end r_checkif_dest_ispool;

  PROCEDURE Execute_Report (ERRBUF OUT NOCOPY VARCHAR2
                    ,RETCODE OUT NOCOPY VARCHAR2
                    , request_id out nocopy number
                    , arg1 in number
                    , arg2 in number
                    , arg3 in number
                    , arg4 in number
                    , arg5 in number
                    , arg6 in number
                    , arg7 in varchar2
                    , arg8 in varchar2
                    , arg9 in number
                    , arg10 in number
                    ) IS
  l_req_id number := 0;
  BEGIN
    if arg1 = 1 then
      l_req_id := fnd_request.submit_request ('MST', 'MSTMASSU', '', '', FALSE, arg2, arg4, arg5, arg7, arg8, chr(0), '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    elsif arg1 = 2 then
      l_req_id := fnd_request.submit_request ('MST', 'MSTMCLSD', '', '', FALSE, arg2, arg3, arg4, arg5, arg7, arg8, chr(0),
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    elsif arg1 = 3 then
      l_req_id := fnd_request.submit_request ('MST', 'MSTMAORD', '', '', FALSE, arg2, arg4, arg5, arg7, arg8, chr(0), '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    elsif arg1 = 4 then
      l_req_id := fnd_request.submit_request ('MST', 'MSTFLDSH', '', '', FALSE, arg2, arg4, arg5, arg6, arg7, arg8, chr(0),
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    elsif arg1 = 5 then
      l_req_id := fnd_request.submit_request ('MST', 'MSTPOSPA', '', '', FALSE, arg2, arg4, arg5, arg6, arg7, arg8, chr(0),
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    elsif arg1 = 6 then
--      l_req_id := fnd_request.submit_request ('MST', 'MSTSHLAD', '', '', FALSE, arg2, arg5, arg8, chr(0), '', '', '',
--Bug_Fix for 3713710
      l_req_id := fnd_request.submit_request ('MST', 'MSTSHLAD', '', '', FALSE, arg2, arg4, arg5, arg7, arg8, chr(0), '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '', '', '',
                                  '', '', '', '', '', '', '', '');
    end if;

    request_id := l_req_id;

      if (l_req_id = 0) then
 --        fnd_message.retrieve;
 --        fnd_message.error;
           null;
      else
         commit;
      end if;
  exception
    when others then
      ERRBUF := SQLERRM;
      RETCODE := SQLCODE;

  END Execute_Report;

  FUNCTION get_cost_wihtout_cm_for_trips (p_plan_id number, p_trip_id1 number, p_trip_id2 number)
  RETURN NUMBER IS
    l_cost NUMBER;
  BEGIN
    SELECT SUM(total_basic_transport_cost + total_accessorial_cost +
               total_handling_cost + total_layover_cost +
	       total_load_unload_cost + total_stop_cost)
    INTO l_cost
    FROM mst_trips
    WHERE plan_id = p_plan_id
    AND trip_id IN (p_trip_id1, p_trip_id2);
    RETURN l_cost;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END get_cost_wihtout_cm_for_trips;

  FUNCTION get_load_type (p_plan_id IN NUMBER,
                          p_trip_id IN NUMBER)
  RETURN VARCHAR2 IS
    l_count NUMBER;
    l_str VARCHAR2(80);
    l_lookup_code NUMBER;
  BEGIN
    SELECT COUNT('x')
    INTO l_count
    FROM mst_delivery_legs
    WHERE plan_id = p_plan_id
    AND trip_id = p_trip_id;

    If l_count > 0 Then
      l_lookup_code := 2;
    Else
      l_lookup_code := 1;
    End If;
    SELECT meaning
    INTO l_str
    FROM mfg_lookups
    WHERE lookup_type = 'MST_TRIP_LOADING_STATUS'
    AND lookup_code = l_lookup_code;

    RETURN l_str;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN '' ;
  END get_load_type;

  FUNCTION GET_ACT_TOKENIZED_EXCEPTION(P_PLAN_ID IN NUMBER,
                                       P_OUT_REQUEST_DETAIL_ID IN NUMBER,
				       P_EXCEPTION_TYPE IN NUMBER,
				       P_LINE_NUM IN NUMBER)
  RETURN VARCHAR2 IS
    l_message VARCHAR2(2000);
    l_id1 NUMBER;
    l_id2 NUMBER;
    l_id3 NUMBER;
    l_id4 NUMBER;
    l_id5 NUMBER;
    l_id6 NUMBER;
    l_id7 NUMBER;
    l_id8 NUMBER;
    l_id9 NUMBER;
    l_str1 VARCHAR2(2500);
    l_str2  VARCHAR2(2500);
    l_str3  VARCHAR2(2500);
    l_date1 date;
    l_date2 date;

    CURSOR l_city_cur (p_location_id IN NUMBER) IS
    SELECT city
    FROM wsh_locations
    WHERE wsh_location_id = p_location_id;

    CURSOR l_carrier_cur (p_carrier_id IN NUMBER) IS
    SELECT freight_code
    FROM wsh_carriers
    WHERE carrier_id = p_carrier_id;

    CURSOR l_uom_cur IS
    SELECT distance_uom, weight_uom, volume_uom
    FROM mst_plans
    WHERE plan_id = P_PLAN_ID;

    CURSOR l_vehicle_cur (p_vehicle_type_id IN NUMBER) IS
    SELECT msikfv.concatenated_segments
    FROM mtl_system_items_kfv msikfv,
         fte_vehicle_types fvt
    WHERE fvt.vehicle_type_id = p_vehicle_type_id
    AND fvt.organization_id = msikfv.organization_id
    AND fvt.inventory_item_id = msikfv.inventory_item_id;
    l_uom l_uom_cur%ROWTYPE;

    CURSOR l_lanes_cur (p_lane_id NUMBER) IS
    SELECT lane_number
    FROM fte_lanes
    WHERE lane_id = p_lane_id;

    CURSOR l_fac_desc_cur (p_location_id NUMBER) IS
    SELECT description
    FROM fte_location_parameters
    WHERE location_id = p_location_id;

    l_new_trip VARCHAR2(200);

  BEGIN
    FND_MESSAGE.SET_NAME('MST', 'MST_NEW_TRIP');
    l_new_trip := FND_MESSAGE.GET;
    IF P_EXCEPTION_TYPE IN (100, 101, 102, 103) THEN
      SELECT nvl(number1, 0), round(nvl(number2, 0), 1)
      INTO l_id1, l_id2
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      l_str1 := ltrim(to_char(l_id2, '999990.0'));
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_' || P_EXCEPTION_TYPE || '_1');
      fnd_message.set_token('DELIVERY_DETAIL_ID', l_id1);
      fnd_message.set_token('SEVERITY', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 200 THEN
      IF P_LINE_NUM = 1 THEN
	SELECT number1, number2, number3, number4
	INTO l_id1, l_id2, l_id3, l_id4
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_200_1');
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;
	Open l_city_cur(l_id3);
	Fetch l_city_cur Into l_str1;
	If l_city_cur%NotFound Then
	  l_str1 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('ORIGIN_CITY', l_str1);

	Open l_city_cur(l_id4);
	Fetch l_city_cur Into l_str2;
	If l_city_cur%NotFound Then
	  l_str2 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('DESTINATION_CITY', l_str2);

	Open l_carrier_cur(l_id2);
	Fetch l_carrier_cur Into l_str3;
	If l_carrier_cur%NotFound Then
	  l_str3 := '';
	End If;
	Close l_carrier_cur;
	fnd_message.set_token('FREIGHT_CODE', l_str3);

	SELECT round(nvl(number7, 0)), round(nvl(number8, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_token('MAX_DISTANCE_IN_24HR', l_id2);
	fnd_message.set_token('DISTANCE_IN_24HR', l_id1);

	SELECT round(nvl(number5, 0)), round(nvl(number6, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;

	Open l_uom_cur;
	Fetch l_uom_cur Into l_uom;
	If l_uom_cur%Found Then
	  l_str1 := l_uom.distance_uom;
	Else
	  l_str1 := '';
	End If;
	Close l_uom_cur;
	fnd_message.set_token('DISTANCE_UOM', l_str1);
	fnd_message.set_token('MAXIMUM_DISTANCE', l_id2);
	fnd_message.set_token('DISTANCE', l_id1);
      END IF;
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 201 THEN
      SELECT number1, number2, number3, number4, round(nvl(number5, 0)), round(nvl(number6, 0))
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;

      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_201_1');
      fnd_message.set_token('CM_TRIP_NUMBER', l_id1);
      fnd_message.set_token('ACTUAL_DEADHEAD_DISTANCE', l_id5);
      fnd_message.set_token('MAX_DEADHEAD_DISTANCE', l_id6);
      Open l_uom_cur;
      Fetch l_uom_cur Into l_uom;
      If l_uom_cur%Found Then
	l_str1 := l_uom.distance_uom;
      Else
	l_str1 := '';
      End If;
      Close l_uom_cur;
      fnd_message.set_token('DISTANCE_UOM', l_str1);
      Open l_city_cur(l_id3);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
	l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('ORIGIN_CITY', l_str1);

      Open l_city_cur(l_id4);
      Fetch l_city_cur Into l_str2;
      If l_city_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('DESTINATION_CITY', l_str2);
      Open l_carrier_cur(l_id2);
      Fetch l_carrier_cur Into l_str3;
      If l_carrier_cur%NotFound Then
	l_str3 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str3);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 202 THEN
      SELECT nvl(number1, -1)
      INTO l_id1
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;

      SELECT trip_number, origin_location_id, destination_location_id
      INTO l_id2, l_id3, l_id4
      FROM mst_trips
      WHERE plan_id = P_PLAN_ID
      AND trip_id = l_id1;

      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_202_1');
      IF l_id2 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id2);
      END IF;

      Open l_city_cur(l_id3);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
	l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('ORIGIN_CITY', l_str1);

      Open l_city_cur(l_id4);
      Fetch l_city_cur Into l_str2;
      If l_city_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('DESTINATION_CITY', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 203 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_203_1');
      SELECT nvl(number1, -1), nvl(number2, -1)
      INTO l_id1, l_id2
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;

      SELECT trip_number
      INTO l_id3
      FROM mst_trips
      WHERE trip_id = l_id1
      AND plan_id = P_PLAN_ID;

      IF l_id3 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id3);
      END IF;

      SELECT stop_location_id, stop_sequence_number
      INTO l_id4, l_id5
      FROM mst_trip_stops
      WHERE plan_id = P_PLAN_ID
      AND stop_id = l_id2;
      fnd_message.set_token('STOP_SEQUENCE_NUMBER', l_id5);

      Open l_city_cur(l_id4);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
	l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('CITY', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 204 THEN
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_204_1');
      SELECT number1, number2, number3, round(nvl(number4, 0)), round(nvl(number5, 0))
      INTO l_id1, l_id2, l_id3, l_id4, l_id5
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;

      IF l_id1 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      fnd_message.set_token('PLANNED_TRANSIT_TIME', l_id4);
      fnd_message.set_token('REQUIRED_TRANSIT_TIME', l_id5);

      Open l_city_cur(l_id2);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
	l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('ORIGIN_CITY', l_str1);

      Open l_city_cur(l_id3);
      Fetch l_city_cur Into l_str2;
      If l_city_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('DESTINATION_CITY', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 205 THEN
      SELECT number1, round(nvl(number2, 0)), round(nvl(number3, 0)), round(nvl(number4, 0)), round(nvl(number5, 0)), round(nvl(number6, 0)), round(nvl(number7, 0)), round(nvl(number8, 0)), round(nvl(number9, 0))
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7, l_id8, l_id9
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_205_1');
      IF l_id1 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;
      fnd_message.set_token('MINIMUM_LAYOVER_TIME', l_id3);
      fnd_message.set_token('LAYOVER_TIME', l_id2);
      fnd_message.set_token('ALLOWED_DRIVING_TIME', l_id5);
      fnd_message.set_token('DRIVING_TIME', l_id4);
      fnd_message.set_token('ALLOWED_DUTY_TIME', l_id7);
      fnd_message.set_token('DUTY_TIME', l_id6);
      fnd_message.set_token('MAX_DISTANCE', l_id9);
      fnd_message.set_token('DISTANCE', l_id8);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 206 THEN
      IF P_LINE_NUM = 1 THEN
        SELECT number1, number2, number3, number4
        INTO l_id1, l_id2, l_id3, l_id4
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_206_1');
        IF l_id1 < 0 THEN
           fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	   fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;
        Open l_city_cur(l_id3);
	Fetch l_city_cur Into l_str1;
	If l_city_cur%NotFound Then
	  l_str1 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('ORIGIN_CITY', l_str1);

	Open l_city_cur(l_id4);
	Fetch l_city_cur Into l_str2;
	If l_city_cur%NotFound Then
	  l_str2 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('DESTINATION_CITY', l_str2);

	Open l_carrier_cur(l_id2);
	Fetch l_carrier_cur Into l_str3;
	If l_carrier_cur%NotFound Then
	  l_str3 := '';
	End If;
	Close l_carrier_cur;
	fnd_message.set_token('FREIGHT_CODE', l_str3);
	l_message := fnd_message.get;
      ELSIF P_LINE_NUM = 2 THEN
	SELECT nvl(number5, 0), nvl(number6, 0)
        INTO l_id1, l_id2
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_206_2');
        fnd_message.set_token('MAX_STOPS', l_id2);
	fnd_message.set_token('STOPS', l_id1);
	l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 207 THEN
      IF P_LINE_NUM = 1 THEN
	SELECT number1, number2, number3, number4
	INTO l_id1, l_id2, l_id3, l_id4
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_207_1');
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;
	Open l_city_cur(l_id3);
	Fetch l_city_cur Into l_str1;
	If l_city_cur%NotFound Then
	  l_str1 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('ORIGIN_CITY', l_str1);

	Open l_city_cur(l_id4);
	Fetch l_city_cur Into l_str2;
	If l_city_cur%NotFound Then
	  l_str2 := '';
	End If;
	Close l_city_cur;
	fnd_message.set_token('DESTINATION_CITY', l_str2);

	Open l_carrier_cur(l_id2);
	Fetch l_carrier_cur Into l_str3;
	If l_carrier_cur%NotFound Then
	  l_str3 := '';
	End If;
	Close l_carrier_cur;
	fnd_message.set_token('FREIGHT_CODE', l_str3);

	SELECT round(nvl(number5, 0)), round(nvl(number6, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_token('ALLOWED_DRIVING_TIME', l_id2);
	fnd_message.set_token('DRIVING_TIME', l_id1);

	SELECT round(nvl(number7, 0)), round(nvl(number8, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_token('ALLOWED_DUTY_TIME', l_id2);
	fnd_message.set_token('DUTY_TIME', l_id1);

	SELECT round(nvl(number9, 0)), round(nvl(number10, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_token('MIN_LAYOVER_TIME', l_id2);
	fnd_message.set_token('LAYOVER_TIME', l_id1);

	SELECT round(nvl(number11, 0)), round(nvl(number12, 0))
	INTO l_id1, l_id2
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
	fnd_message.set_token('MAX_TIME', l_id2);
	fnd_message.set_token('TIME', l_id1);
      END IF;
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 208 THEN
      SELECT number1, number2, number3, number4
      INTO l_id1, l_id2, l_id3, l_id4
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_208_1');
      IF l_id1 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;
      Open l_city_cur(l_id3);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('ORIGIN_CITY', l_str1);
      Open l_city_cur(l_id4);
      Fetch l_city_cur Into l_str2;
      If l_city_cur%NotFound Then
	l_str2 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('DESTINATION_CITY', l_str2);

      Open l_carrier_cur(l_id2);
      Fetch l_carrier_cur Into l_str3;
      If l_carrier_cur%NotFound Then
        l_str3 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str3);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 220 THEN --Item Mode Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_220_1');
        SELECT number1, number2, char1
        INTO l_id1, l_id2, l_str1
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;
        fnd_message.set_token('DELIVERY_DETAIL_ID', l_id2);

        SELECT wlk.meaning
        INTO l_str2
        FROM wsh_lookups wlk
        WHERE wlk.lookup_type = 'WSH_MODE_OF_TRANSPORT'
        and wlk.lookup_code = l_str1;
        fnd_message.set_token('MODE_OF_TRANSPORT', l_str2);

        -- item_description
        select msitl.description into l_str3
        from mtl_system_items_tl msitl, mst_delivery_details mdd
        where mdd.plan_id = P_PLAN_ID
	and mdd.delivery_detail_id = l_id2
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
        fnd_message.set_token('ITEM_DESCRIPTION', l_str3);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 221 THEN --Item Carrier Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_221_1');
        --Trip_number
        SELECT number1, number2, number3
        INTO l_id1, l_id2, l_id3
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;
        fnd_message.set_token('DELIVERY_DETAIL_ID', l_id2);

        -- item_description
        select msitl.description into l_str2
        from mtl_system_items_tl msitl, mst_delivery_details mdd
        where mdd.plan_id = P_PLAN_ID
	and mdd.delivery_detail_id = l_id2
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
        fnd_message.set_token('ITEM_DESCRIPTION', l_str2);

        --carrier name
        SELECT freight_code into l_str3
        FROM wsh_carriers
        WHERE carrier_id = l_id3;
        fnd_message.set_token('CARRIER_NAME', l_str3);

        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 222 THEN --Ship Set Violation
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_222_1');
        --Ship_set
        SELECT number1
        INTO l_id1
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;

        -- Ship_set Name
        select set_name into l_str1
        from oe_sets os
        where os.set_id=l_id1;
        fnd_message.set_token('SHIP_SET', l_str1);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 223 THEN --Ship Set Violation
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_223_1');
        --Ship_set
        SELECT number1
        INTO l_id1
        FROM mst_out_request_details
        WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
        AND exception_type = P_EXCEPTION_TYPE;

        -- Ship_set Name
        select set_name into l_str1
        from oe_sets os
        where os.set_id=l_id1;
        fnd_message.set_token('ARRIVAL_SET', l_str1);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 300 THEN
      SELECT number1, number2, number3, number4, nvl(number5, 0), nvl(number6, 0)
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_300_1');
      Open l_carrier_cur(l_id1);
      Fetch l_carrier_cur Into l_str1;
      If l_carrier_cur%NotFound Then
        l_str1 := '';
      End If;
      fnd_message.set_token('FREIGHT_CODE', l_str1);
      Close l_carrier_cur;
      Open l_vehicle_cur(l_id2);
      Fetch l_vehicle_cur Into l_str2;
      If l_vehicle_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_vehicle_cur;
      fnd_message.set_token('VEHICLE_TYPE', l_str2);

      Open l_lanes_cur (l_id3);
      Fetch l_lanes_cur Into l_str3;
      If l_lanes_cur%NotFound Then
        l_str3 := '';
      End If;
      Close l_lanes_cur;
      fnd_message.set_token('LANE', l_str3);
      fnd_message.set_token('TOTAL_LOADS', l_id5);
      fnd_message.set_token('VEHICLE_AVAILABILITY', l_id6);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 301 THEN  -- Carrier commitment under-utilization
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_301_1');

      SELECT number1, number3, number4, number5, date1, date2
      INTO l_id1, l_id3, l_id4, l_id5, l_date1, l_date2
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;

      fnd_message.set_token('START_DATE', fnd_date.DATE_TO_CHARDATE(l_date1));
      fnd_message.set_token('END_DATE', fnd_date.DATE_TO_CHARDATE(l_date2));
      fnd_message.set_token('SHORTFALL', round(l_id5));

      --Carrier name
      SELECT freight_code INTO l_str1
      FROM wsh_carriers
      WHERE carrier_id = l_id1;
      fnd_message.set_token('CARRIER', l_str1);

      --get Lane_Number
        select LANE
        into l_str2
        from(
        select fl.lane_number "LANE"
        from fte_lanes fl
        where fl.lane_id = l_id3
        UNION ALL
        select flg.name "LANE"
        from fte_lane_groups flg
        where flg.lane_group_id = l_id4);
        --as per dld, Lane_Number = fl.lane_number or flg.name whichever is not null
       fnd_message.set_token('LANE_NAME', l_str2);
       l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 400 THEN
      SELECT number1, number2
      INTO l_id1, l_id2
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_400_1');
      IF l_id1 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_fac_desc_cur (l_id2);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 401 THEN
      SELECT number1, number2, round(nvl(number3, 0), 2), round(nvl(number4, 0), 2)
      INTO l_id1, l_id2, l_id3, l_id4
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_401_1');
      IF l_id1 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_fac_desc_cur (l_id2);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      fnd_message.set_token('REQUIRED_STOP_TIME', ltrim(to_char(l_id4, '999990.0')));
      fnd_message.set_token('STOP_TIME', ltrim(to_char(l_id3, '999990.0')));
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 402 THEN
      SELECT number1, number2, number3, number4, round(nvl(number5, 0), 2), round(nvl(number6, 0), 2)
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_402_1');
      fnd_message.set_token('DELIVERY_DETAIL_ID', l_id1);
      IF l_id2 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER1', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER1', l_id2);
      END IF;
      IF l_id3 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER2', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER2', l_id3);
      END IF;

      Open l_fac_desc_cur (l_id4);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      fnd_message.set_token('REQUIRED_CONNECT_TIME', ltrim(to_char(l_id6, '999990.0')));
      fnd_message.set_token('CONNECT_TIME', ltrim(to_char(l_id5, '999990.0')));
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 403 THEN
      SELECT number1, number2, number3
      INTO l_id1, l_id2, l_id3
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_403_1');
      fnd_message.set_token('CM_TRIP_NUMBER', l_id1);
      IF l_id2 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER1', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER1', l_id2);
      END IF;
      IF l_id3 < 0 THEN
         fnd_message.set_token('TRIP_NUMBER2', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER2', l_id3);
      END IF;
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 406 THEN --Carrier Facility Appointment violation
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_406_1');
	SELECT number1, number2, number3, number4
	INTO l_id1, l_id2, l_id3, l_id4
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
	AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;

        --facility_description
	select flp.facility_code
	into l_str1
	from fte_location_parameters flp
	where flp.location_id = l_id2;

        fnd_message.set_token('FACILITY_DESCRIPTION', l_str1);

        --carrier name
        SELECT freight_code INTO l_str2
        FROM wsh_carriers
        WHERE carrier_id = l_id4;
        fnd_message.set_token('CARRIER_NAME', l_str2);

        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 500 THEN
      SELECT number1, number2, number3, number4, round(nvl(number5, 0)), number6, round(nvl(number7, 0))
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_500_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;
      fnd_message.set_token('LOW_COST_CARRIER_COST', l_id7);

      Open l_city_cur(l_id2);
      Fetch l_city_cur Into l_str1;
      If l_city_cur%NotFound Then
	l_str1 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('ORIGIN_CITY', l_str1);

      Open l_city_cur(l_id3);
      Fetch l_city_cur Into l_str2;
      If l_city_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_city_cur;
      fnd_message.set_token('DESTINATION_CITY', l_str2);

      Open l_carrier_cur(l_id4);
      Fetch l_carrier_cur Into l_str1;
      If l_carrier_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str1);

      Open l_carrier_cur(l_id6);
      Fetch l_carrier_cur Into l_str2;
      If l_carrier_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('LOW_COST_CARRIER', l_str2);
      fnd_message.set_token('COST', l_id5);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 501 THEN
      SELECT number1
      INTO l_id1
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_501_1');
      fnd_message.set_token('TRIP_NUMBER', l_id1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 600 THEN
      SELECT number1, round(number2), round(number3), round(number4), round(number5), round(number6), round(number7), number8
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7, l_id8
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_' || P_EXCEPTION_TYPE || '_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      SELECT volume_uom
      INTO l_str1
      FROM mst_plans
      WHERE plan_id = P_PLAN_ID;

      SELECT msikfv.internal_volume * get_uom_conversion_rate (msikfv.volume_uom_code,
                                                               l_str1,
                                                               msikfv.organization_id,
                                                               msikfv.inventory_item_id)
      INTO l_id9
      FROM mtl_system_items_kfv msikfv,
           fte_vehicle_types fvt
      WHERE msikfv.inventory_item_id = fvt.inventory_item_id
      AND msikfv.organization_id = fvt.organization_id
      AND fvt.vehicle_type_id = l_id8;

      If l_id9 is not null Then
        fnd_message.set_token('PHYSICAL_CAPACITY', l_id9);
      Else
        fnd_message.set_token('PHYSICAL_CAPACITY', '');
      End If;

      If l_id3 > 0 Then
        l_id8 := round((l_id2/l_id3) * 100);
        l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_VOLUME_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_VOLUME', l_id2);
      fnd_message.set_token('MAX_VOLUME', l_id3);

      If l_id5 > 0 Then
        l_id8 := round((l_id4/l_id5) * 100);
	l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_WEIGHT_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_WEIGHT', l_id4);
      fnd_message.set_token('MAX_WEIGHT', l_id5);

      If l_id7 > 0 Then
        l_id8 := round((l_id6/l_id7) * 100);
	l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_PALLET_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_PALLETS', l_id6);
      fnd_message.set_token('MAX_PALLETS', l_id7);

      Open l_uom_cur;
      Fetch l_uom_cur Into l_uom;
      If l_uom_cur%Found Then
        l_str1 := l_uom.weight_uom;
	l_str2 := l_uom.volume_uom;
      Else
        l_str1 := '';
	l_str2 := '';
      End If;
      Close l_uom_cur;
      fnd_message.set_token('WEIGHT_UOM', l_str1);
      fnd_message.set_token('VOLUME_UOM', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 601 THEN
      SELECT number1, round(number2), round(number3), round(number4), round(number5), round(number6), round(number7)
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6, l_id7
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_' || P_EXCEPTION_TYPE || '_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      If l_id3 > 0 Then
        l_id8 := round((l_id2/l_id3) * 100);
	l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_VOLUME_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_VOLUME', l_id2);
      fnd_message.set_token('MAX_VOLUME', l_id3);

      If l_id5 > 0 Then
        l_id8 := round((l_id4/l_id5) * 100);
        l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_WEIGHT_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_WEIGHT', l_id4);
      fnd_message.set_token('MAX_WEIGHT', l_id5);

      If l_id7 > 0 Then
        l_id8 := round((l_id6/l_id7) * 100);
        l_str1 := l_id8;
      Else
        l_str1 := ' ';
      End If;
      fnd_message.set_token('PEAK_PALLET_UTILIZATION', l_str1);
      fnd_message.set_token('PEAK_PALLETS', l_id6);
      fnd_message.set_token('MAX_PALLETS', l_id7);

      Open l_uom_cur;
      Fetch l_uom_cur Into l_uom;
      If l_uom_cur%Found Then
        l_str1 := l_uom.weight_uom;
	l_str2 := l_uom.volume_uom;
      Else
        l_str1 := '';
	l_str2 := '';
      End If;
      Close l_uom_cur;
      fnd_message.set_token('WEIGHT_UOM', l_str1);
      fnd_message.set_token('VOLUME_UOM', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 602 THEN --Item Vehicle Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_602_1');

	SELECT number1, number2, number3
	INTO l_id1, l_id2, l_id3
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
	AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;

        -- item_description
        select msitl.description into l_str1
        from mtl_system_items_tl msitl, mst_delivery_details mdd
        where mdd.plan_id = P_PLAN_ID
	and mdd.delivery_detail_id = l_id2
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
        fnd_message.set_token('ITEM_DESCRIPTION', l_str1);

        SELECT msikfv.concatenated_segments
        into l_str2
        FROM mtl_system_items_kfv msikfv, fte_vehicle_types fvt
        WHERE fvt.vehicle_type_id = l_id3
        AND fvt.organization_id = msikfv.organization_id
        AND fvt.inventory_item_id = msikfv.inventory_item_id;
        fnd_message.set_token('VEHICLE_TYPE', l_str2);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE IN (700, 701) THEN
      SELECT number1
      INTO l_id1
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_' || P_EXCEPTION_TYPE || '_1');

      Open l_fac_desc_cur (l_id1);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 702 THEN
      SELECT number1, number2, number3
      INTO l_id1, l_id2, l_id3
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_702_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_vehicle_cur(l_id2);
      Fetch l_vehicle_cur Into l_str2;
      If l_vehicle_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_vehicle_cur;
      fnd_message.set_token('VEHICLE_TYPE', l_str2);

      Open l_fac_desc_cur (l_id3);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 703 THEN
      SELECT number1, number2, number3
      INTO l_id1, l_id2, l_id3
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_703_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
	fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_carrier_cur(l_id2);
      Fetch l_carrier_cur Into l_str2;
      If l_carrier_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str2);

      Open l_fac_desc_cur (l_id3);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 705 THEN --Facility Item Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_705_1');
        SELECT number1, number2, number3
	INTO l_id1, l_id2, l_id3
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
	AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;

        -- item_description
        select msitl.description into l_str1
        from mtl_system_items_tl msitl, mst_delivery_details mdd
        where mdd.plan_id = P_PLAN_ID
	and mdd.delivery_detail_id = l_id2
        and mdd.inventory_item_id = msitl.inventory_item_id
        and mdd.organization_id = msitl.organization_id
        and msitl.language = userenv('LANG');
        fnd_message.set_token('ITEM_DESCRIPTION', l_str1);

        -- Facility_Description
        select flp.description
        into l_str2
        from fte_location_parameters flp
        where flp.location_id = l_id3;
        fnd_message.set_token('FACILITY_DESCRIPTION', l_str2);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 706 THEN --Facility Mode Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_706_1');
        SELECT number1, number3, char1
	INTO l_id1,  l_id3, l_str1
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
	AND exception_type = P_EXCEPTION_TYPE;
        IF l_id1 < 0 THEN
          fnd_message.set_token('TRIP_NUMBER', l_new_trip);
        ELSE
	  fnd_message.set_token('TRIP_NUMBER', l_id1);
        END IF;

	SELECT wlk.meaning
        INTO l_str2
        FROM  wsh_lookups wlk
        WHERE wlk.lookup_type = 'WSH_MODE_OF_TRANSPORT'
        and wlk.lookup_code = l_str1;

        fnd_message.set_token('MODE_OF_TRANSPORT', l_str2);

        -- Facility_Description
        select flp.description
        into l_str3
        from fte_location_parameters flp
        where flp.location_id = l_id3;
        fnd_message.set_token('FACILITY_DESCRIPTION', l_str3);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 707 THEN --Facility Facility Incompatibility
      IF P_LINE_NUM = 1 THEN
        fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_707_1');

        SELECT number1, number2, number3, number4
	INTO l_id1, l_id2, l_id3, l_id4
	FROM mst_out_request_details
	WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
	AND exception_type = P_EXCEPTION_TYPE;
        fnd_message.set_token('DELIVERY_NUMBER', l_id1);

        --End_facility_name, intermediate_facility_name
        select flp1.facility_code
        into l_str1
        from fte_location_parameters flp1
        where flp1.location_id = l_id2;

        fnd_message.set_token('END_FACILITY_NAME', l_str1);
	select flp1.facility_code
        into l_str2
        from fte_location_parameters flp1
        where flp1.location_id = l_id3;
        fnd_message.set_token('INTERMEDIATE_FACILITY_NAME', l_str2);
        l_message := fnd_message.get;
      END IF;
    ELSIF P_EXCEPTION_TYPE = 800 THEN
      SELECT number1, number2, number3, number4, number5
      INTO l_id1, l_id2, l_id3, l_id4, l_id5
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_800_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
        fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_carrier_cur(l_id2);
      Fetch l_carrier_cur Into l_str2;
      If l_carrier_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str2);

      Open l_fac_desc_cur (l_id3);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);

      If l_id4 Is Not Null Then
	l_str2 := Get_Partner_Name(l_id4, 1);
      Elsif l_id5 Is Not Null Then
	l_str2 := Get_Partner_Name(l_id5, 2);
      End If;

      fnd_message.set_token('TRADING_PARTNER', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 801 THEN
      SELECT number1, number2, number3, number4, number5, number6
      INTO l_id1, l_id2, l_id3, l_id4, l_id5, l_id6
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_801_1');
      IF l_id1 < 0 THEN
        fnd_message.set_token('TRIP_NUMBER', l_new_trip);
      ELSE
        fnd_message.set_token('TRIP_NUMBER', l_id1);
      END IF;

      Open l_carrier_cur(l_id2);
      Fetch l_carrier_cur Into l_str2;
      If l_carrier_cur%NotFound Then
        l_str2 := '';
      End If;
      Close l_carrier_cur;
      fnd_message.set_token('FREIGHT_CODE', l_str2);

      Open l_fac_desc_cur (l_id3);
      Fetch l_fac_desc_cur Into l_str1;
      If l_fac_desc_cur%NotFound Then
        l_str1 := '';
      End If;
      Close l_fac_desc_cur;
      fnd_message.set_token('FACILITY_DESC', l_str1);

      If l_id4 Is Not Null Then
	l_str2 := Get_Partner_Name(l_id4, 1);
      Elsif l_id5 Is Not Null Then
	l_str2 := Get_Partner_Name(l_id5, 2);
      Elsif l_id6 Is Not Null Then
        l_str2 := fnd_profile.value('MST_COMPANY_NAME');
      End If;
      fnd_message.set_token('CUST_SUPPLIER', l_str2);
      l_message := fnd_message.get;
    ELSIF P_EXCEPTION_TYPE = 1000 THEN
      SELECT number1
      INTO l_id1
      FROM mst_out_request_details
      WHERE out_request_detail_id = P_OUT_REQUEST_DETAIL_ID
      AND exception_type = P_EXCEPTION_TYPE;
      fnd_message.set_name('MST', 'MST_EXCEP_TOKEN_1000_1');
      fnd_message.set_token('DELIVERY_NUMBER', l_id1);
      l_message := fnd_message.get;
    ELSE
      SELECT meaning
      INTO l_message
      FROM mfg_lookups
      WHERE lookup_type = 'MST_EXCEPTION_TYPE'
      AND lookup_code = P_EXCEPTION_TYPE;
    END IF;
    return l_message;
  EXCEPTION
    WHEN OTHERS THEN
       RETURN '';
  END GET_ACT_TOKENIZED_EXCEPTION;

  FUNCTION adjust_to_server_time(p_datetime    IN DATE,
                                 p_location_id IN NUMBER,
                                 p_facility_id IN NUMBER) RETURN DATE IS

    CURSOR cur_location(P_facility_id IN NUMBER) IS
    SELECT flp.location_id
    FROM   fte_location_parameters flp
    WHERE  flp.facility_id = P_facility_id;

    l_server_datetime date;
    l_location_id number;
  BEGIN
    IF p_location_id IS NULL THEN
        open cur_location(P_facility_id);
        fetch cur_location into l_location_id;
        close cur_location;
    ELSE
        l_location_id:= p_location_id;
    END IF;
    l_server_datetime:= MST_GEOCODING.Get_server_time(l_location_id, p_datetime);
    RETURN l_server_datetime;
  EXCEPTION
    WHEN OTHERS THEN
        RETURN p_datetime;
  END adjust_to_server_time;

  FUNCTION convert_time(p_time      IN NUMBER,
                        p_uom_from  IN VARCHAR2,
                        p_uom_to    IN VARCHAR2) RETURN NUMBER IS

    l_factor_to_hour   NUMBER;
    l_factor_from_hour NUMBER;
  BEGIN

    -- factor to convert into hours
    IF p_uom_from = 'WK' THEN -- week
      l_factor_to_hour := 24*7;
    ELSIF p_uom_from = 'DAY' THEN
      l_factor_to_hour := 24;
    ELSIF p_uom_from = 'HR' THEN
      l_factor_to_hour := 1;
    ELSIF p_uom_from = 'MIN' THEN
      l_factor_to_hour := 1/60;
    ELSIF p_uom_from = 'SEC' THEN
      l_factor_to_hour := 1/(60*60);
    END IF;

    -- factor to convert from hours
    IF p_uom_to = 'WK' THEN -- week
      l_factor_from_hour := 1/(24*7);
    ELSIF p_uom_to = 'DAY' THEN
      l_factor_from_hour := 1/24;
    ELSIF p_uom_to = 'HR' THEN
      l_factor_from_hour := 1;
    ELSIF p_uom_to = 'MIN' THEN
      l_factor_from_hour := 60;
    ELSIF p_uom_to = 'SEC' THEN
      l_factor_from_hour := 60*60;
    END IF;

    RETURN p_time * l_factor_from_hour * l_factor_to_hour;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN p_time;
  END convert_time;

  /**************FOLLOWING ARE BEING USED FOR PURGE PLAN************************/
  procedure print_info(p_purge_debug_control in number, p_info_str in varchar2) is
  begin
    if p_purge_debug_control = 1 then
      fnd_file.put_line(fnd_file.log, p_info_str);
      --dbms_output.put_line(p_info_str);
      --abc123pro(p_info_str);
    end if;
  end print_info;

  procedure purge_plan (p_err_code           OUT NOCOPY VARCHAR2
                      , p_err_buff           OUT NOCOPY VARCHAR2
                      , p_plan_id            IN         NUMBER
                      , p_compile_designator IN         VARCHAR2
                      , p_description        IN         VARCHAR2) is
    l_message varchar2(1000);
  begin
    l_message := 'Purge of plan '||p_compile_designator||':'||p_description||' started by '||fnd_global.user_name;
    print_info(1,l_message);

    delete from MST_DELIVERY_LEGS
    where plan_id = p_plan_id;

    delete from MST_TRIP_STOPS
    where plan_id = p_plan_id;

    delete from MST_TRIPS
    where plan_id = p_plan_id;

    delete from MST_CM_TRIPS
    where plan_id = p_plan_id;

    delete from MST_DELIVERY_ASSIGNMENTS
    where plan_id = p_plan_id;

    delete from MST_DELIVERY_DETAILS
    where plan_id = p_plan_id;

    delete from MST_DELIVERIES
    where plan_id = p_plan_id;

    delete from MST_EXCEPTION_DETAILS
    where plan_id = p_plan_id;

    delete from MST_EXCEPTIONS
    where plan_id = p_plan_id;

    delete from MST_FILES
    where plan_id = p_plan_id;

    delete from MST_IN_REQUESTS
    where plan_id = p_plan_id;

    delete from MST_LOAD_SUMMARY
    where plan_id = p_plan_id;

    delete from MST_OUT_REQUEST_DETAILS
    where plan_id = p_plan_id;

    delete from MST_OUT_REQUESTS
    where plan_id = p_plan_id;

    delete from MST_PERSONAL_QUERY_RESULTS
    where plan_id = p_plan_id;

    delete from MST_PLAN_CONSTRAINT_RULES
    where plan_id = p_plan_id;

    delete from MST_PLAN_FACILITIES
    where plan_id = p_plan_id;

    delete from MST_PLAN_PENALTY_BREAKS
    where plan_id = p_plan_id;

    delete from MST_PLAN_ZIP_LOCATIONS
    where plan_id = p_plan_id;

    delete from MST_RELATED_LOADS_TEMP
    where plan_id = p_plan_id;

    delete from MST_RELEASE_TEMP
    where plan_id = p_plan_id;

    delete from MST_SNAPSHOT_TASKS
    where plan_id = p_plan_id;

    delete from MST_TMP_PLN_LOC
    where plan_id = p_plan_id;

    delete from MST_EXCEPT_DETAILS_DETAILS
    where plan_id = p_plan_id;

    delete from MST_PLANS
    where plan_id = p_plan_id;

    commit;
    l_message := 'Purge of plan '||p_compile_designator||':'||p_description||' successfully completed.';
    print_info(1,l_message);
  exception
    when others then
      rollback;
      l_message := 'Purge of plan '||p_compile_designator||':'||p_description||' unsuccessfully completed.';
      print_info(1,l_message);
      l_message := to_char(SQLCODE)||':'||SQLERRM;
      print_info(1,l_message);
  end purge_plan;

  procedure submit_purge_plan_request ( p_request_id         OUT NOCOPY NUMBER
                                      , p_plan_id            IN         NUMBER
                                      , p_compile_designator IN         VARCHAR2
                                      , p_description        IN         VARCHAR2) is
  begin
    p_request_id := fnd_request.submit_request('MST', 'MSTPRGPL', NULL, NULL, NULL, p_plan_id, p_compile_designator, p_description);
    if p_request_id > 0 then
      commit;
    end if;
  end submit_purge_plan_request;

  /******************************************************************************/

    function get_org_id(p_plan_id in number, p_delivery_id in number) return number is
        cursor cur_orgs is
        select mdd.organization_id
        from mst_deliveries md
           , mst_delivery_assignments mda
           , mst_delivery_details mdd
        where mdd.plan_id  = mda.plan_id
        and   mdd.delivery_detail_id = mda.delivery_detail_id
        and   mda.plan_id = md.plan_id
        and   mda.delivery_id = md.delivery_id
        and   md.plan_id = p_plan_id
        and   md.delivery_id  = p_delivery_id;

        l_org_id number;
    begin
        open cur_orgs;
        fetch cur_orgs into l_org_id;
        close cur_orgs;

        return l_org_id;
     exception
        when others then
            return 0;
    end get_org_id;

function get_workflow_status(p_plan_id in number, p_exception_detail_id in number) return varchar2 is
  l_image_name varchar2(20);

  cursor cur_check_notification (l_plan_id in number, l_exception_detail_id in number)
  is
  select '1'
  from wf_item_activity_statuses
  where item_type ='MSTEXPWF'
  and item_key = l_plan_id || '-' || l_exception_detail_id
  and notification_id is not null;

begin
  open cur_check_notification (p_plan_id, p_exception_detail_id);
  fetch cur_check_notification into l_image_name;
  if cur_check_notification%notfound then
    l_image_name := 'jtfgnull.gif';
  else
    l_image_name := 'jtfuwnac.gif';
  end if;
  close cur_check_notification;
  return l_image_name;
exception
  when others then
    if cur_check_notification%isopen then
      close cur_check_notification;
    end if;
    return 'jtfgnull.gif';
end get_workflow_status;

function get_city_code(p_location_id NUMBER) return VARCHAR2 IS
  Cursor city_code is
  select nvl(wr.city_code, wr.city) from
wsh_locations wsh,
wsh_region_locations wlr,
wsh_regions_v wr
where wsh.wsh_location_id = p_location_id
and wsh.wsh_location_id = wlr.location_id
and wlr.region_type = 2 -- city
and wlr.region_id = wr.region_id;

CURSOR wsh_city_name IS
  SELECT substr(wl.city , 1, 10)
  FROM wsh_locations wl
  WHERE wsh_location_id = p_location_id;

l_city_code VARCHAR2(60);
BEGIN
  open city_code;
  fetch city_code into l_city_code;
  close city_code;

  IF l_city_code IS NULL THEN
    open wsh_city_name;
    fetch wsh_city_name into l_city_code;
    close wsh_city_name;
  END IF;

  return l_city_code;
END get_city_code;

procedure Compute_Exception_Counts(p_Plan_Id IN NUMBER, p_Exp_Summary_Where_Clause IN VARCHAR2, p_Exp_Details_Where_Clause IN VARCHAR2) is
  --pragma autonomous_transaction;

  cursor Cur_Exp_Details (l_Plan_Id IN NUMBER, l_Dummy IN NUMBER)
  is
  select exception_type
  from mst_exceptions
  where plan_id = l_plan_id
  and exception_count_context = l_dummy;

  type number_tab_type is table of number index by binary_integer;
  l_Exception_Type_Tab number_tab_type;
  l_Count_Tab number_tab_type;
begin
  execute immediate 'update mst_exceptions
                     set exception_count_context = -9999
                     where '||p_Exp_Summary_Where_Clause;

  open Cur_Exp_Details (p_Plan_Id, -9999);
  fetch Cur_Exp_Details bulk collect into l_Exception_Type_Tab;
  close Cur_Exp_Details;

  if nvl(l_Exception_Type_Tab(1),0) > 0 then
    for i in 1..l_Exception_Type_Tab.count loop
      execute immediate 'select count(1)
                         from mst_exception_details
                         where '||replace(p_Exp_Details_Where_Clause,'!~!',l_Exception_Type_Tab(i))
                         into l_Count_Tab(i);
    end loop;
    forall i in 1..l_Exception_Type_Tab.last
      update mst_exceptions
      set exception_count_context = l_count_Tab(i)
      where Plan_id = p_Plan_Id
      and exception_type = l_Exception_Type_Tab(i);
    commit;
--  else
--    rollback;
  end if;
exception
  when others then
--    rollback;
null;
end Compute_Exception_Counts;

PROCEDURE run_dynamic_sql(p_query_string IN VARCHAR2) IS
BEGIN
  EXECUTE IMMEDIATE p_query_string;
END;

  PROCEDURE notify_engine(p_plan_id     IN NUMBER,
                          p_object_type IN NUMBER,
                          p_object_id   IN NUMBER,
                          p_firm_status IN NUMBER) IS
    l_status NUMBER;
  BEGIN
    --g_plan_id := p_plan_id;
    IF p_object_type = 1 THEN -- delivery
        DBMS_PIPE.PACK_MESSAGE('D|' || p_object_id || '|' || p_firm_status);
    ELSIF p_object_type = 2 THEN -- trip
        DBMS_PIPE.PACK_MESSAGE('T|' || p_object_id || '|' || p_firm_status);
    ELSIF p_object_type = 3 THEN  -- cm trip
      DBMS_PIPE.PACK_MESSAGE('C|' || p_object_id || '|' || p_firm_status);
    END IF;
    l_status := DBMS_PIPE.SEND_MESSAGE('MST_IP_' || p_plan_id, 0);
  END notify_engine;

  PROCEDURE Update_Del_And_Rel_Trips(p_Plan_Id      IN  NUMBER,
                                     p_Trip_Id      IN  NUMBER,
                                     p_Planned_Flag IN  NUMBER,
                                     P_Notified     OUT NOCOPY NUMBER) IS

    CURSOR cur_affected_deliveries(p_plan_id IN NUMBER,
                                   p_trip_id IN NUMBER) IS
    SELECT DELIVERY_ID, PLANNED_FLAG, KNOWN_TE_FIRM_STATUS, PRESERVE_GROUPING_FLAG
    FROM MST_DELIVERIES md
    WHERE md.plan_id = p_plan_id
    AND   md.DELIVERY_ID IN (SELECT mdl.DELIVERY_ID
                             FROM MST_DELIVERY_LEGS mdl
                             WHERE mdl.PLAN_ID = md.Plan_Id
                             AND   mdl.TRIP_ID = p_Trip_Id)
    FOR UPDATE OF PLANNED_FLAG NOWAIT;

    CURSOR cur_affected_trips(p_plan_id IN NUMBER,
                              p_trip_id IN NUMBER) IS
    SELECT TRIP_ID, PLANNED_FLAG
    FROM mst_trips mt
    WHERE mt.PLAN_ID = p_Plan_Id
    AND mt.TRIP_ID IN (SELECT mdl2.TRIP_ID
                       FROM  MST_DELIVERY_LEGS mdl1
                           , MST_DELIVERY_LEGS mdl2
                       WHERE mdl1.PLAN_ID = mdl2.PLAN_ID
                       AND mdl1.DELIVERY_ID = mdl2.DELIVERY_ID
                       AND mdl1.TRIP_ID <> mdl2.TRIP_ID
                       AND mdl1.PLAN_ID = mt.Plan_Id
                       AND mdl1.TRIP_ID = p_Trip_Id);

    l_rec_affected_deliveries cur_affected_deliveries%ROWTYPE;
    l_rec_affected_trips cur_affected_trips%ROWTYPE;
    l_update_stmt VARCHAR2(500);
    l_planned_flag NUMBER;
  BEGIN
    IF p_Planned_Flag IN (1,3) THEN
        OPEN cur_affected_deliveries(p_plan_id, p_trip_id);
        LOOP
            l_planned_flag := NULL;
            FETCH cur_affected_deliveries INTO l_rec_affected_deliveries;
            EXIT WHEN cur_affected_deliveries%NOTFOUND;

            l_update_stmt := 'UPDATE MST_DELIVERIES '||
                             ' SET  PLANNED_FLAG = decode(:p_Planned_Flag,1,1,3,2,PLANNED_FLAG) '||
                             '    , PRESERVE_GROUPING_FLAG = DECODE(:p_Planned_Flag, '||
                             '                   3, DECODE(KNOWN_TE_FIRM_STATUS, '||
                             '                             2                   , 1, '||
                             '                                                   PRESERVE_GROUPING_FLAG), '||
                             '                   PRESERVE_GROUPING_FLAG) '||
                             ' WHERE plan_id = :p_plan_id '||
                             ' and   delivery_id = :p_delivery_id '||
                             ' RETURNING planned_flag into :l_planned_flag';

            EXECUTE IMMEDIATE l_update_stmt
                              USING p_planned_flag, p_planned_flag,
                                    p_plan_id, l_rec_affected_deliveries.delivery_id
                              RETURNING INTO l_planned_flag;
            IF l_rec_affected_deliveries.planned_flag <> l_planned_flag THEN
                notify_engine(p_plan_id, 1, l_rec_affected_deliveries.delivery_id, l_planned_flag);
                P_Notified := 1;
            END IF;

            --dbms_output.put_line('planned_flag changed from ' ||l_rec_affected_deliveries.planned_flag ||
            --                                           ' to ' ||l_planned_flag);
        END LOOP;
        CLOSE cur_affected_deliveries;

        OPEN cur_affected_trips(p_plan_id, p_trip_id);
        LOOP
            l_planned_flag := NULL;
            FETCH cur_affected_trips INTO l_rec_affected_trips;
            EXIT WHEN cur_affected_trips%NOTFOUND;
            l_update_stmt := ' UPDATE MST_TRIPS '||
                             ' SET PLANNED_FLAG = DECODE(:p_Planned_Flag, '||
                             '                           1, DECODE(SIGN(PLANNED_FLAG-2), '||
                             '                                     -1, PLANNED_FLAG, 2), '||
                             '                           3,DECODE(SIGN(PLANNED_FLAG-2), '||
                             '                                     -1, 2, PLANNED_FLAG), '||
                             '                           PLANNED_FLAG) '||
                             ' WHERE PLAN_ID = :p_Plan_Id '||
                             ' AND TRIP_ID   = :p_trip_id '||
                             ' RETURNING planned_flag into :l_planned_flag';

            EXECUTE IMMEDIATE l_update_stmt
                              USING p_planned_flag, p_plan_id, l_rec_affected_trips.trip_id
                              RETURNING INTO l_planned_flag;

            IF l_rec_affected_trips.planned_flag <> l_planned_flag THEN
                notify_engine(p_plan_id, 2, l_rec_affected_trips.trip_id, l_planned_flag);
                P_Notified := 1;
            END IF;
            --dbms_output.put_line('planned_flag changed from ' ||l_rec_affected_trips.planned_flag ||
            --                                           ' to ' ||l_planned_flag);
        END LOOP;
        CLOSE cur_affected_trips;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
        IF cur_affected_deliveries%ISOPEN THEN
            CLOSE cur_affected_deliveries;
        END IF;
        IF cur_affected_trips%ISOPEN THEN
            CLOSE cur_affected_trips;
        END IF;
        RAISE;
  END Update_Del_And_Rel_Trips;

  PROCEDURE Update_Trips_Of_CM(p_Plan_Id            IN  NUMBER,
                               p_Continuous_Move_Id IN  NUMBER,
                               P_Notified           OUT NOCOPY NUMBER) IS

    CURSOR cur_affected_trips(p_plan_id            IN NUMBER,
                              p_Continuous_Move_Id IN NUMBER) IS
    SELECT TRIP_ID, PLANNED_FLAG
    FROM mst_trips mt
    WHERE plan_id = p_plan_id
    AND   Continuous_Move_Id = p_Continuous_Move_Id
    FOR UPDATE OF PLANNED_FLAG NOWAIT;

    l_rec_affected_trips cur_affected_trips%ROWTYPE;
    l_update_stmt VARCHAR2(500);
    l_planned_flag NUMBER;
  BEGIN
    OPEN cur_affected_trips(p_plan_id, p_Continuous_Move_Id);
    LOOP
        l_planned_flag := NULL;
        FETCH cur_affected_trips INTO l_rec_affected_trips;
        EXIT WHEN cur_affected_trips%NOTFOUND;
        l_update_stmt := ' UPDATE MST_TRIPS '||
                         ' SET PLANNED_FLAG = DECODE(SIGN(PLANNED_FLAG-2),-1,PLANNED_FLAG,2) '||
                         ' WHERE PLAN_ID = :p_Plan_Id '||
                         ' AND TRIP_ID = :p_trip_id '||
                         ' RETURNING planned_flag into :l_planned_flag';
        EXECUTE IMMEDIATE l_update_stmt
                          USING p_plan_id, l_rec_affected_trips.trip_id
                          RETURNING INTO l_planned_flag;
        IF l_rec_affected_trips.planned_flag <> l_planned_flag THEN
            notify_engine(p_plan_id, 2, l_rec_affected_trips.trip_id, l_planned_flag);
            P_Notified := 1;
        END IF;
        --dbms_output.put_line('planned_flag changed from ' ||l_rec_affected_trips.planned_flag ||
        --                                           ' to ' ||l_planned_flag);
    END LOOP;
    CLOSE cur_affected_trips;
  EXCEPTION
    WHEN OTHERS THEN
        IF cur_affected_trips%ISOPEN THEN
            CLOSE cur_affected_trips;
        END IF;
        RAISE;
  END Update_Trips_Of_CM;

  FUNCTION GET_UOM_CONVERSION_RATE (p_from_uom_code VARCHAR2, p_to_uom_code VARCHAR2, p_org_id NUMBER, p_inventory_item_id NUMBER)
  RETURN NUMBER IS
    l_from_uom_class VARCHAR2(80);
    l_to_uom_class VARCHAR2(80);
    l_conversion_rate NUMBER := 1;

    CURSOR l_uom_class (p_uom_code VARCHAR2) IS
    SELECT uom_class
    FROM mtl_units_of_measure
    WHERE uom_code = p_uom_code;

    CURSOR l_intraclass_conversion_cur (p_from_uom_code VARCHAR2, p_to_uom_code VARCHAR2) IS
    SELECT muc2.conversion_rate/muc1.conversion_rate
    FROM mtl_uom_conversions muc1,
       mtl_uom_conversions muc2
    WHERE muc1.inventory_item_id = 0
    AND muc2.inventory_item_id = 0
    AND muc1.uom_class = l_to_uom_class
    AND muc1.uom_code = p_to_uom_code
    AND muc2.uom_class = l_from_uom_class
    AND muc2.uom_code = p_from_uom_code;

    CURSOR l_interclass_conversion_cur (p_uom1 VARCHAR2, p_uom2 VARCHAR2, p_org_id NUMBER, p_inventory_item_id NUMBER) IS
    SELECT muc.conversion_rate
    FROM mtl_uom_conversions_view muc
    WHERE muc.inventory_item_id = p_inventory_item_id
    AND muc.organization_id = p_org_id
    AND muc.primary_uom_code = p_uom1
    AND muc.uom_code = p_uom2;

  BEGIN
    OPEN l_uom_class (p_from_uom_code);
    FETCH l_uom_class INTO l_from_uom_class;
    IF l_uom_class%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_uom_class;

    OPEN l_uom_class (p_to_uom_code);
    FETCH l_uom_class INTO l_to_uom_class;
    IF l_uom_class%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_uom_class;

    IF l_from_uom_class = l_to_uom_class THEN
      Open l_intraclass_conversion_cur(p_from_uom_code, p_to_uom_code);
      Fetch l_intraclass_conversion_cur INTO l_conversion_rate;
      Close l_intraclass_conversion_cur;
    ELSE
      Open l_interclass_conversion_cur(p_from_uom_code, p_to_uom_code, p_org_id, p_inventory_item_id);
      Fetch l_interclass_conversion_cur INTO l_conversion_rate;
      If l_interclass_conversion_cur%notfound Then
        Close l_interclass_conversion_cur;
        Open l_interclass_conversion_cur(p_to_uom_code, p_from_uom_code, p_org_id, p_inventory_item_id);
        Fetch l_interclass_conversion_cur INTO l_conversion_rate;
        If l_interclass_conversion_cur%found Then
          If l_conversion_rate = 0 Then
            RAISE NO_DATA_FOUND;
        Else
          l_conversion_rate := 1/l_conversion_rate;
	End If;
      End If;
    END IF;
    Close l_interclass_conversion_cur;
  END IF;

  RETURN l_conversion_rate;

 EXCEPTION
  WHEN OTHERS THEN
    IF l_uom_class%ISOPEN THEN
      CLOSE l_uom_class;
    END IF;
    IF l_intraclass_conversion_cur%ISOPEN THEN
      CLOSE l_intraclass_conversion_cur;
    END IF;
    IF l_interclass_conversion_cur%ISOPEN THEN
      CLOSE l_interclass_conversion_cur;
    END IF;
    RETURN l_conversion_rate;
 END GET_UOM_CONVERSION_RATE;

  FUNCTION get_rule_type ( p_rule_id IN NUMBER )
  RETURN VARCHAR2 IS
    CURSOR rules IS
    SELECT 'x'
    FROM fte_sel_rule_restrictions fsrr
    WHERE fsrr.rule_id = p_rule_id
    AND fsrr.attribute_name = 'SPEND';

    l_return VARCHAR2 (1);
  BEGIN
    OPEN rules;
    FETCH rules into l_return;
    CLOSE rules;

    IF l_return IS NULL
    THEN
      RETURN 'NOT_SPEND';
    ELSE
      RETURN 'SPEND';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
     IF rules%ISOPEN
     THEN
      CLOSE rules;
     END IF;

     RETURN ( 'NOT_SPEND' );
  END get_rule_type;

  FUNCTION get_row_count (p_view_name IN VARCHAR2, p_where_clause IN VARCHAR2)
  RETURN NUMBER IS
   l_count NUMBER;
  BEGIN
    EXECUTE IMMEDIATE ' SELECT COUNT(1) FROM ' || p_view_name || ' WHERE ' || p_where_clause
                      INTO l_count;
    RETURN l_count;
  EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
  END get_row_count;


END MST_WB_UTIL;

/
