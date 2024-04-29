--------------------------------------------------------
--  DDL for Package Body MST_CMP_KPIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_CMP_KPIS" AS
/* $Header: MSTCKPIB.pls 120.0 2005/05/26 17:49:28 appldev noship $ */
-- -------------------------------------------------------------
-- Note:
-- =====
-- This is just a first cut of design and need to be changed
-- further to validation. There exists some SQL's which really
-- need to be changed. All the SQL's are replicas of those
-- mentioned in the KPI's calculation doc. This comment will be
-- removed once the code is been validated and tested.
-- -------------------------------------------------------------

    g_plan_level        CONSTANT NUMBER(1) := 1;
    g_mode_level        CONSTANT NUMBER(1) := 2;
    g_customer_level    CONSTANT NUMBER(1) := 3;
    g_supplier_level    CONSTANT NUMBER(1) := 4;
    g_carrier_level     CONSTANT NUMBER(1) := 5;
    g_facility_level    CONSTANT NUMBER(1) := 6;

    g_precision         CONSTANT NUMBER := 3;

    g_tload             CONSTANT VARCHAR2(6) := 'TRUCK';
    g_ltl               CONSTANT VARCHAR2(3) := 'LTL';
    g_parcel            CONSTANT VARCHAR2(6) := 'PARCEL';

    g_act_dist_travel   CONSTANT NUMBER := 1;
    g_dir_route_dist    CONSTANT NUMBER := 2;

    CURSOR cur_get_parameters IS
    SELECT NVL(COST_DISTANCE_ALLOC_METHOD,1)
    FROM mst_parameters
    WHERE user_Id = -9999;

    CURSOR cur_plan_info(p_plan_id IN NUMBER) IS
    SELECT PLAN_ID, currency_uom
    FROM mst_plans
    WHERE plan_id = p_plan_id;

    g_rec_plan_info cur_plan_info%ROWTYPE;

    FUNCTION get_location(p_facility_id IN NUMBER) RETURN NUMBER IS
        CURSOR cur_location IS
        SELECT wl.wsh_location_id
        FROM wsh_locations wl,
             fte_location_parameters fte
        WHERE wl.wsh_location_id = fte.location_id
        AND fte.facility_id = p_facility_id;
        l_location_id NUMBER;
    BEGIN
        OPEN cur_location;
        FETCH cur_location INTO l_location_id;
        CLOSE cur_location;
        RETURN l_location_id;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_location;

    -- Cost per Unit Weight (KPI - 38)
    -- ===============================
    FUNCTION Cost_per_Unit_Weight(  p_plan_id             IN NUMBER,
                                    p_level               IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_supplier_id         IN NUMBER,
                                    p_carrier_id          IN NUMBER,
                                    p_mode_of_transport   IN VARCHAR2,
                                    p_fac_loc_id          IN NUMBER)
        RETURN NUMBER IS

        -- Plan level
        -- -----------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan, Total Cost
        -- (as measured by KPI 22) divided by Total Weight
        -- (as measured by KPI 3) at the plan level.
        -- ---------------------------------------------------
        /*CURSOR cur_cpuw_plan IS
        SELECT T.TotalCost/NVL(P.TOTAL_WEIGHT, 1) AS CostPerUnitWeight
        FROM (SELECT T1.PLAN_ID,
                     SUM(NVL(T1.TOTAL_HANDLING_COST, 0)       +
                         NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                         NVL(T1.TOTAL_STOP_COST, 0)            +
                         NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                         NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                         NVL(T1.TOTAL_ACCESSORIAL_COST, 0)      ) TotalCost
              FROM MST_TRIPS T1
              WHERE T1.PLAN_ID = p_plan_Id
              GROUP BY T1.PLAN_ID) T,
            MST_PLANS P
        WHERE T.PLAN_ID = P.PLAN_ID;*/
        -- -----------------------------------------
        -- As per bug#3535276, We always need to go
        -- with delivery legs to compute total cost.
        -- -----------------------------------------
        -- -----------------------------------------
        -- As per bug#3555250, exclude weight of
        -- unassigned deliveries.
        -- -----------------------------------------
        CURSOR cur_cpuw_plan IS
        --SELECT NVL(P.TOTAL_PLAN_COST,0)/NVL(P.TOTAL_WEIGHT, 1) AS CostPerUnitWeight
        SELECT NVL(P.TOTAL_PLAN_COST,0)/DECODE((
                                         NVL(P.TOTAL_TL_WEIGHT, 0) +
                                         NVL(P.TOTAL_LTL_WEIGHT, 0) +
                                         NVL(P.TOTAL_PARCEL_WEIGHT, 0) ),0,1,
               								        (NVL(P.TOTAL_TL_WEIGHT, 0) +
                                                     NVL(P.TOTAL_LTL_WEIGHT, 0) +
                                                     NVL(P.TOTAL_PARCEL_WEIGHT, 0)))
                                            AS CostPerUnitWeight
        FROM MST_PLANS P
        WHERE P.PLAN_ID = P_PLAN_ID;

        -- Mode level
        -- ----------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and mode of
        -- transportation, Total Cost (as measured by KPI 22)
        -- divided by Total Weight (as measured by KPI 3) for
        -- that mode.
        -- ---------------------------------------------------

            -- Mode level - TL
            -- ----------------
            CURSOR cur_cpuw_Truck IS
            SELECT T.TotalCost/NVL(P.TOTAL_TL_WEIGHT, 1) CostPerUnitWeight
            FROM (SELECT T1.PLAN_ID,
                     SUM(NVL(T1.TOTAL_HANDLING_COST, 0)         +
                         NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)  +
                         NVL(T1.TOTAL_STOP_COST, 0)             +
                         NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)      +
                         NVL(T1.TOTAL_LAYOVER_COST, 0)          +
                         NVL(T1.TOTAL_ACCESSORIAL_COST, 0)       ) TotalCost
                  FROM MST_TRIPS T1
                  WHERE T1.PLAN_ID = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_tload -- 'TRUCK'
                  GROUP BY T1.PLAN_ID ) T,
                MST_PLANS P
            WHERE T.PLAN_ID = P.PLAN_ID;

            -- Mode level - LTL
            -- -----------------
            CURSOR cur_cpuw_ltl IS
            SELECT T.TotalCost/NVL(P.TOTAL_LTL_WEIGHT, 1) CostPerUnitWeight
            FROM (SELECT T1.PLAN_ID,
                       SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)  +
                           NVL(T1.TOTAL_ACCESSORIAL_COST, 0)      +
                           NVL(T1.TOTAL_HANDLING_COST ,0 )         ) TotalCost
                  FROM MST_TRIPS T1
                  WHERE T1.PLAN_ID = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_ltl
                  GROUP BY T1.PLAN_ID ) T,
                MST_PLANS P
            WHERE T.PLAN_ID = P.PLAN_ID;

            -- Mode level - Parcel
            -- -------------------
            CURSOR cur_cpuw_parcel IS
            SELECT T.TotalCost/NVL(P.TOTAL_PARCEL_WEIGHT, 1) CostPerUnitWeight
            FROM (SELECT T1.PLAN_ID,
                       SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                           NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     +
                           NVL(T1.TOTAL_HANDLING_COST, 0)         ) TotalCost
                  FROM MST_TRIPS T1
                  WHERE T1.PLAN_ID = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_parcel
                  GROUP BY T1.PLAN_ID ) T,
                MST_PLANS P
            WHERE T.PLAN_ID = P.PLAN_ID;

        -- Carrier level
        -- -------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and carrier,
        -- Total Cost (as measured by KPI 22) divided by Total
        -- Weight (as measured by KPI 3) for that carrier.
        -- ---------------------------------------------------
        CURSOR cur_cpuw_carr IS
        SELECT T11.TotalCost/NVL(T12.TotalWeight, 1) CostPerUnitWeight
        FROM (SELECT SUM(
                         NVL(T1.TOTAL_HANDLING_COST, 0)      +
                         NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                         NVL(T1.TOTAL_STOP_COST, 0)            +
                         NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                         NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                         NVL(T1.TOTAL_ACCESSORIAL_COST, 0)      ) TotalCost
              FROM MST_TRIPS T1
              WHERE T1.PLAN_ID = p_plan_Id
              AND   T1.CARRIER_ID = p_carrier_id
             ) T11,
            (SELECT SUM(D.GROSS_WEIGHT) TotalWeight
             FROM MST_DELIVERIES D
             WHERE D.PLAN_ID = p_plan_id
             AND   D.DELIVERY_ID IN
                                ( SELECT DL.DELIVERY_ID
                                  FROM MST_DELIVERY_LEGS DL,
                                       MST_TRIPS T2
                                  WHERE dl.plan_id  = d.plan_id
                                  AND   T2.PLAN_ID  = dl.PLAN_ID
                                  AND   T2.TRIP_ID  = dl.TRIP_ID
                                  AND   T2.CARRIER_ID = p_carrier_id
                                  )
             )T12;

        -- Customer level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and customer,
        -- Total Cost (as measured by KPI 22) divided by Total
        -- Weight (as measured by KPI 3) for that customer.
        -- ---------------------------------------------------
        CURSOR cur_cpuw_cust IS
        SELECT T1.TotalCost/T2.TotalWeight CostPerUnitWeight
        FROM (SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)     +
                         NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0)   +
                         NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0)    +
                         NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0)    +
                         NVL(DL.ALLOCATED_TRANSPORT_COST, 0)    ) TotalCost
              FROM MST_DELIVERY_LEGS DL,
                   MST_DELIVERIES D
              WHERE DL.PLAN_ID = p_plan_Id
              AND   DL.PLAN_ID = D.PLAN_ID
              AND   DL.DELIVERY_ID = D.DELIVERY_ID
              AND   D.CUSTOMER_ID = p_customer_id
             ) T1,
             (SELECT SUM(D1.GROSS_WEIGHT) TotalWeight
              FROM MST_DELIVERIES D1
              WHERE D1.PLAN_ID = p_plan_id
              AND D1.CUSTOMER_ID = p_customer_id
              AND EXISTS (SELECT DL1.DELIVERY_LEG_ID
                          FROM MST_DELIVERY_LEGS DL1
                          WHERE DL1.PLAN_ID  = D1.PLAN_ID
                          AND   DL1.DELIVERY_ID = D1.DELIVERY_ID
                            )
             ) T2;

        -- Supplier level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and supplier,
        -- the Total Cost (as measured by KPI 22) divided by
        -- Total Weight (as measured by KPI 3) for that supplier.
        -- ---------------------------------------------------
        CURSOR cur_cpuw_supp IS
        SELECT T1.TotalCost/T2.TotalWeight CostPerUnitWeight
        FROM (  SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)   +
                           NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0) +
                           NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_TRANSPORT_COST, 0)      ) TotalCost
                FROM MST_DELIVERY_LEGS DL,
                     MST_DELIVERIES D
                WHERE DL.PLAN_ID = p_plan_id
                AND   DL.PLAN_ID = D.PLAN_ID
                AND   DL.DELIVERY_ID = D.DELIVERY_ID
                AND   D.SUPPLIER_ID = p_Supplier_ID
                ) T1,
            (   SELECT SUM(D1.GROSS_WEIGHT) TotalWeight
                FROM MST_DELIVERIES D1
                WHERE D1.PLAN_ID = p_plan_id
                AND   D1.SUPPLIER_ID = p_Supplier_ID
                AND EXISTS (SELECT DL1.DELIVERY_LEG_ID
                            FROM MST_DELIVERY_LEGS DL1
                            WHERE DL1.PLAN_ID  = D1.PLAN_ID
                            AND   DL1.DELIVERY_ID = D1.DELIVERY_ID
                            )
              ) T2;

        -- Facility level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and facility
        -- (location id), Total Cost (as measured by KPI 22)
        -- divided by Total Weight (as measured by KPI 3) for
        -- that facility.
        -- ---------------------------------------------------
        CURSOR cur_cpuw_fac(p_location_id IN NUMBER) IS
        SELECT T1.TotalCost/T2.TotalWeight CostPerUnitWeight
        FROM (  SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)   +
                           NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0) +
                           NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_TRANSPORT_COST, 0)      ) TotalCost
                FROM MST_DELIVERY_LEGS DL,
                     MST_DELIVERIES D
                WHERE DL.PLAN_ID = p_plan_id
                AND   DL.PLAN_ID = D.PLAN_ID
                AND   DL.DELIVERY_ID = D.DELIVERY_ID
                AND (   D.PICKUP_LOCATION_ID = p_location_id
                     OR D.DROPOFF_LOCATION_ID = p_location_id )
             ) T1,
            (   SELECT SUM(D1.GROSS_WEIGHT) TotalWeight
                FROM MST_DELIVERIES D1
                WHERE D1.PLAN_ID = p_plan_Id
                AND   (   D1.DROPOFF_LOCATION_ID = p_location_id
                       OR D1.PICKUP_LOCATION_ID = p_location_id )
                AND EXISTS (SELECT DL1.DELIVERY_LEG_ID
                            FROM MST_DELIVERY_LEGS DL1
                            WHERE DL1.DELIVERY_ID = D1.DELIVERY_ID
                            AND   DL1.PLAN_ID     = D1.PLAN_ID
                            )
             ) T2;

        l_costperunitweight NUMBER;
        l_location_id NUMBER;

    BEGIN
        IF P_LEVEL = g_plan_level THEN
            OPEN cur_cpuw_plan;
            FETCH cur_cpuw_plan INTO l_costperunitweight;
            CLOSE cur_cpuw_plan;
        ELSIF p_level = g_mode_level THEN
            IF p_mode_of_transport = g_tload THEN
                OPEN cur_cpuw_Truck;
                FETCH cur_cpuw_Truck INTO l_costperunitweight;
                CLOSE cur_cpuw_Truck;
            ELSIF p_mode_of_transport = g_ltl THEN
                OPEN cur_cpuw_ltl;
                FETCH cur_cpuw_ltl INTO l_costperunitweight;
                CLOSE cur_cpuw_ltl;
            ELSIF p_mode_of_transport = g_parcel THEN
                OPEN cur_cpuw_parcel;
                FETCH cur_cpuw_parcel INTO l_costperunitweight;
                CLOSE cur_cpuw_parcel;
            END IF;
        ELSIF p_level = g_customer_level THEN
            OPEN cur_cpuw_cust;
            FETCH cur_cpuw_cust INTO l_costperunitweight;
            CLOSE cur_cpuw_cust;
        ELSIF p_level = g_supplier_level THEN
            OPEN cur_cpuw_supp;
            FETCH cur_cpuw_supp INTO l_costperunitweight;
            CLOSE cur_cpuw_supp;
        ELSIF p_level = g_carrier_level THEN
            OPEN cur_cpuw_carr;
            FETCH cur_cpuw_carr INTO l_costperunitweight;
            CLOSE cur_cpuw_carr;
        ELSIF p_level = g_facility_level THEN
            l_location_id := get_location(p_fac_loc_id);
            OPEN cur_cpuw_fac(l_location_id);
            FETCH cur_cpuw_fac INTO l_costperunitweight;
            CLOSE cur_cpuw_fac;
        END IF;
        /**IF g_rec_plan_info.plan_Id <> p_plan_id THEN
            OPEN cur_plan_info(p_plan_id);
            FETCH cur_plan_info INTO g_rec_plan_info;
            CLOSE cur_plan_info;
            IF g_rec_plan_info.currency_uom IS NOT NULL THEN
                fnd_currency.get_info
                    (g_rec_plan_info.currency_uom,
                     g_precision,
                     g_ext_precision,
                     g_mau);
            END IF;
        END IF;
        IF g_precision IS NOT NULL THEN
            l_costperunitweight:= round(l_costperunitweight,g_precision);
        END IF;*/
        IF l_costperunitweight IS NULL THEN
            l_costperunitweight := 0;
        END IF;
        l_costperunitweight:= round(l_costperunitweight,g_precision);
        RETURN l_costperunitweight;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END Cost_per_Unit_Weight;

    -- Cost per Unit Volume (KPI - 39)
    -- ===============================
    FUNCTION Cost_per_Unit_Volume(  p_plan_id             IN NUMBER,
                                    p_level               IN NUMBER,
                                    p_customer_id         IN NUMBER,
                                    p_supplier_id         IN NUMBER,
                                    p_carrier_id          IN NUMBER,
                                    p_mode_of_transport   IN VARCHAR2,
                                    p_fac_loc_id          IN NUMBER)
        RETURN NUMBER IS


        -- Plan level
        -- ----------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan, Total Cost
        -- (as measured by KPI 22) divided by Total Volume
        -- (as measured by KPI 4) at the plan level.
        -- ---------------------------------------------------
        /*CURSOR cur_cpuv_plan IS
        SELECT (T.TotalCost/NVL(P.TOTAL_VOLUME,1)) AS CostPerUnitVolume
        FROM (  SELECT T1.PLAN_ID,
                   SUM(NVL(T1.TOTAL_HANDLING_COST, 0)        +
                       NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                       NVL(T1.TOTAL_STOP_COST, 0)            +
                       NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                       NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                       NVL(T1.TOTAL_ACCESSORIAL_COST, 0)      ) TotalCost
                FROM MST_TRIPS T1
                WHERE t1.PLAN_ID = p_plan_id
                GROUP BY T1.PLAN_ID
                ) T,
                MST_PLANS P
        WHERE T.PLAN_ID = P.PLAN_ID;*/
        -- -----------------------------------------
        -- As per bug#3535276, We always need to go
        -- with delivery legs to compute total cost.
        -- -----------------------------------------
        -- -----------------------------------------
        -- As per bug#3555250, exclude VOLUME of
        -- unassigned deliveries.
        -- -----------------------------------------
        CURSOR cur_cpuv_plan IS
        --SELECT NVL(P.TOTAL_PLAN_COST,0)/NVL(P.TOTAL_VOLUME, 1) AS CostPerUnitVolume
        SELECT NVL(P.TOTAL_PLAN_COST,0)/DECODE((
                                         NVL(P.TOTAL_TL_VOLUME, 0) +
                                         NVL(P.TOTAL_LTL_VOLUME, 0) +
                                         NVL(P.TOTAL_PARCEL_VOLUME, 0) ),0,1,
               								        (NVL(P.TOTAL_TL_VOLUME, 0) +
                                                     NVL(P.TOTAL_LTL_VOLUME, 0) +
                                                     NVL(P.TOTAL_PARCEL_VOLUME, 0)))
                                            AS CostPerUnitVolume
        FROM MST_PLANS P
        WHERE P.PLAN_ID = P_PLAN_ID;
        -- Mode level - TL
        -- ---------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and mode of
        -- transportation, Total Cost (as measured by KPI 22)
        -- divided by Total Volume (as measured by KPI 4) for
        -- that mode.
        -- ---------------------------------------------------
        CURSOR cur_cpuv_Truck IS
        SELECT T.TotalCost/NVL(P.TOTAL_TL_VOLUME, 1) AS CostPerUnitVolume
        FROM ( SELECT T1.PLAN_ID,
                  SUM(NVL(T1.TOTAL_HANDLING_COST, 0)        +
                      NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                      NVL(T1.TOTAL_STOP_COST, 0)            +
                      NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                      NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                      NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalCost
                FROM MST_TRIPS T1
                WHERE T1.PLAN_ID = p_plan_id
                AND   T1.MODE_OF_TRANSPORT = g_tload
                GROUP BY T1.PLAN_ID) T,
            MST_PLANS P
        WHERE T.PLAN_ID = P.PLAN_ID;

        -- Mode level - LTL
        -- -----------------
        CURSOR cur_cpuv_LTL IS
        SELECT T.TotalCost/NVL(P.TOTAL_LTL_VOLUME, 1) AS CostPerUnitVolume
        FROM ( SELECT T1.PLAN_ID,
                  SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                      NVL(T1.TOTAL_ACCESSORIAL_COST, 0)    +
                      NVL(T1.TOTAL_HANDLING_COST, 0)        ) TotalCost
                FROM MST_TRIPS T1
                WHERE T1.PLAN_ID = p_plan_id
                AND   T1.MODE_OF_TRANSPORT = g_ltl
                GROUP BY T1.PLAN_ID) T,
            MST_PLANS P
        WHERE T.PLAN_ID = P.PLAN_ID;

        -- Mode level - Parcel
        -- -------------------
        CURSOR cur_cpuv_Parcel IS
        SELECT T.TotalCost/NVL(P.TOTAL_PARCEL_VOLUME, 1) AS CostPerUnitVolume
        FROM ( SELECT T1.PLAN_ID,
                  SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                      NVL(T1.TOTAL_ACCESSORIAL_COST, 0)    +
                      NVL(T1.TOTAL_HANDLING_COST, 0)        ) TotalCost
                FROM MST_TRIPS T1
                WHERE T1.PLAN_ID = p_plan_id
                AND   T1.MODE_OF_TRANSPORT = g_parcel
                GROUP BY T1.PLAN_ID) T,
            MST_PLANS P
        WHERE T.PLAN_ID = P.PLAN_ID;

        -- Carrier level
        -- -------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and carrier,
        -- Total Cost (as measured by KPI 22) divided by Total
        -- Volume (as measured by KPI 4) for that carrier.
        -- ---------------------------------------------------
        CURSOR cur_cpuv_carr IS
        SELECT T11.TotalCost/T12.TotalVolume CostPerUnitVolume
        FROM ( SELECT SUM(
                          NVL(T1.TOTAL_HANDLING_COST, 0)       +
                          NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                          NVL(T1.TOTAL_STOP_COST, 0)           +
                          NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)    +
                          NVL(T1.TOTAL_LAYOVER_COST, 0)        +
                          NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalCost
                FROM MST_TRIPS T1
                WHERE T1.PLAN_ID = p_plan_id
                AND   T1.CARRIER_ID = p_carrier_id
            ) T11,
               (SELECT SUM(d.VOLUME) TotalVolume
                FROM MST_DELIVERIES D
                WHERE D.PLAN_ID = p_plan_id
                AND   D.DELIVERY_ID IN
                                ( SELECT DL.DELIVERY_ID
                                  FROM MST_DELIVERY_LEGS DL,
                                       MST_TRIPS T2
                                  WHERE DL.PLAN_ID  = d.PLAN_ID
                                  AND   T2.PLAN_ID  = dl.PLAN_ID
                                  AND   T2.TRIP_ID  = dl.TRIP_ID
                                  AND   T2.PLAN_ID  = p_plan_id
                                  AND   T2.CARRIER_ID = p_carrier_id
                                  )
                ) T12;

        -- Customer level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and customer,
        -- Total Cost (as measured by KPI 22) divided by Total
        -- Volume (as measured by KPI 4) for that customer.
        -- ---------------------------------------------------
        CURSOR cur_cpuv_cust IS
        SELECT T1.TotalCost/T2.TotalVolume CostPerUnitVolume
        FROM ( SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)  +
                          NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0)+
                          NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0) +
                          NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0) +
                          NVL(DL.ALLOCATED_TRANSPORT_COST, 0)     ) TotalCost
               FROM MST_DELIVERY_LEGS DL,
                    MST_DELIVERIES D
               WHERE DL.PLAN_ID = p_plan_id
               AND   DL.PLAN_ID = D.PLAN_ID
               AND   DL.DELIVERY_ID = D.DELIVERY_ID
               AND   D.CUSTOMER_ID = p_customer_id
            ) T1,
            ( SELECT SUM(D1.VOLUME) TotalVolume
              FROM MST_DELIVERIES D1
              WHERE D1.PLAN_ID = p_plan_id
              AND   D1.CUSTOMER_ID = p_customer_id
              AND   EXISTS (SELECT DL1.DELIVERY_LEG_ID
                            FROM MST_DELIVERY_LEGS DL1
                            WHERE DL1.PLAN_ID     = D1.PLAN_ID
                            AND   DL1.DELIVERY_ID = D1.DELIVERY_ID
                            )
            ) T2;

        -- Supplier level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and supplier,
        -- Total Cost (as measured by KPI 22) divided by Total
        -- Volume (as measured by KPI 4) for that supplier.
        -- ---------------------------------------------------
        CURSOR cur_cpuv_Supp IS
        SELECT T1.TotalCost/T2.TotalVolume CostPerUnitVolume
        FROM ( SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)  +
                          NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0)+
                          NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0) +
                          NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0) +
                          NVL(DL.ALLOCATED_TRANSPORT_COST, 0)     ) TotalCost
               FROM MST_DELIVERY_LEGS DL,
                    MST_DELIVERIES D
               WHERE DL.PLAN_ID = p_plan_id
               AND   DL.PLAN_ID = D.PLAN_ID
               AND   DL.DELIVERY_ID = D.DELIVERY_ID
               AND   D.SUPPLIER_ID = p_supplier_id
                ) T1,
               (SELECT SUM(D1.VOLUME) TotalVolume
                FROM MST_DELIVERIES D1
                WHERE D1.PLAN_ID = p_plan_id
                AND   D1.SUPPLIER_ID = p_supplier_id
                AND   EXISTS ( SELECT DL1.DELIVERY_LEG_ID
                               FROM MST_DELIVERY_LEGS DL1
                               WHERE DL1.PLAN_ID     = D1.PLAN_ID
                               AND   DL1.DELIVERY_ID = D1.DELIVERY_ID
                                )
                ) T2;

        -- Facility level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and facility
        -- (location id), Total Cost (as measured by KPI 22)
        -- divided by Total Volume (as measured by KPI 4) for
        -- that facility.
        -- ---------------------------------------------------
        CURSOR cur_cpuv_fac(p_location_id IN NUMBER) IS
        SELECT T1.TotalCost/T2.TotalVolume CostPerUnitVolume
        FROM (  SELECT SUM(NVL(DL.ALLOCATED_FAC_LOADING_COST, 0)   +
                           NVL(DL.ALLOCATED_FAC_UNLOADING_COST, 0) +
                           NVL(DL.ALLOCATED_FAC_SHP_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_FAC_REC_HAND_COST, 0)  +
                           NVL(DL.ALLOCATED_TRANSPORT_COST, 0) ) TotalCost
                FROM MST_DELIVERY_LEGS DL,
                     MST_DELIVERIES D
                WHERE DL.PLAN_ID = p_plan_id
                AND   DL.PLAN_ID = D.PLAN_ID
                AND   DL.DELIVERY_ID = D.DELIVERY_ID
                AND (   D.PICKUP_LOCATION_ID = p_location_id
                     OR D.DROPOFF_LOCATION_ID = p_location_id )
            ) T1,
            (   SELECT SUM(D1.VOLUME) TotalVolume
                FROM MST_DELIVERIES D1
                WHERE D1.PLAN_ID = p_plan_id
                AND   (   D1.DROPOFF_LOCATION_ID = p_location_id
                       OR D1.PICKUP_LOCATION_ID = p_location_id )
                AND EXISTS (SELECT DL1.DELIVERY_LEG_ID
                            FROM MST_DELIVERY_LEGS DL1
                            WHERE DL1.DELIVERY_ID = D1.DELIVERY_ID
                            AND   DL1.PLAN_ID     = D1.PLAN_ID
                            )
            ) T2;

        l_CostPerUnitVolume NUMBER;
        l_location_id NUMBER;
    BEGIN
        IF P_LEVEL = g_plan_level THEN
            OPEN cur_cpuv_plan;
            FETCH cur_cpuv_plan INTO l_CostPerUnitVolume;
            CLOSE cur_cpuv_plan;
        ELSIF p_level = g_mode_level THEN
            IF p_mode_of_transport = g_tload THEN
                OPEN cur_cpuv_Truck;
                FETCH cur_cpuv_Truck INTO l_CostPerUnitVolume;
                CLOSE cur_cpuv_Truck;
            ELSIF p_mode_of_transport = g_ltl THEN
                OPEN cur_cpuv_ltl;
                FETCH cur_cpuv_ltl INTO l_CostPerUnitVolume;
                CLOSE cur_cpuv_ltl;
            ELSIF p_mode_of_transport = g_parcel THEN
                OPEN cur_cpuv_parcel;
                FETCH cur_cpuv_parcel INTO l_CostPerUnitVolume;
                CLOSE cur_cpuv_parcel;
            END IF;
        ELSIF p_level = g_customer_level THEN
            OPEN cur_cpuv_cust;
            FETCH cur_cpuv_cust INTO l_CostPerUnitVolume;
            CLOSE cur_cpuv_cust;
        ELSIF p_level = g_supplier_level THEN
            OPEN cur_cpuv_supp;
            FETCH cur_cpuv_supp INTO l_CostPerUnitVolume;
            CLOSE cur_cpuv_supp;
        ELSIF p_level = g_carrier_level THEN
            OPEN cur_cpuv_carr;
            FETCH cur_cpuv_carr INTO l_CostPerUnitVolume;
            CLOSE cur_cpuv_carr;
        ELSIF p_level = g_facility_level THEN
            l_location_id := get_location(p_fac_loc_id);
            OPEN cur_cpuv_fac(l_location_id);
            FETCH cur_cpuv_fac INTO l_CostPerUnitVolume;
            CLOSE cur_cpuv_fac;
        END IF;
        IF l_CostPerUnitVolume IS NULL THEN
            l_CostPerUnitVolume := 0;
        END IF;
        l_CostPerUnitVolume := round(l_CostPerUnitVolume,g_precision);
        RETURN l_CostPerUnitVolume;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END Cost_per_Unit_Volume;

    -- TL Cost per Unit Distance (KPI - 40)
    -- ====================================
    FUNCTION TL_Cost_per_Unit_Dist( p_plan_id       IN NUMBER,
                                    p_level         IN NUMBER,
                                    p_carrier_id    IN NUMBER)
        RETURN NUMBER IS

        -- Plan level
        -- ----------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan, Total TL
        -- Cost (as measured by KPI 24) divided by Total TL
        -- Distance (as measured by KPI 47).
        -- ---------------------------------------------------
        CURSOR cur_cpud_plan IS
        SELECT (SUM(NVL(T.TOTAL_HANDLING_COST, 0)       +
                    NVL(T.TOTAL_BASIC_TRANSPORT_COST, 0)+
                    NVL(T.TOTAL_STOP_COST, 0)           +
                    NVL(T.TOTAL_LOAD_UNLOAD_COST, 0)    +
                    NVL(T.TOTAL_LAYOVER_COST, 0)        +
                    NVL(T.TOTAL_ACCESSORIAL_COST, 0)     ) /
                SUM(T.TOTAL_TRIP_DISTANCE)                )TLCostPerUnitDist
        FROM MST_TRIPS T
        WHERE T.PLAN_ID = p_plan_id
        AND   T.MODE_OF_TRANSPORT = g_tload;


        -- Carrier Level
        -- -------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and carrier
        -- id, Total TL Cost (as measured by KPI 24) divided
        -- by Total TL Distance (as measured by KPI 47) at the
        -- carrier level for that carrier.
        -- ---------------------------------------------------
        CURSOR cur_cpud_carr IS
        SELECT (SUM(
                    NVL(T.TOTAL_HANDLING_COST, 0)       +
                    NVL(T.TOTAL_BASIC_TRANSPORT_COST,0) +
                    NVL(T.TOTAL_STOP_COST, 0)           +
                    NVL(T.TOTAL_LOAD_UNLOAD_COST, 0)    +
                    NVL(T.TOTAL_LAYOVER_COST, 0)        +
                    NVL(T.TOTAL_ACCESSORIAL_COST, 0)     ) /
                SUM(T.TOTAL_TRIP_DISTANCE)                  )TLCostPerUnitDist
        FROM MST_TRIPS T
        WHERE T.PLAN_ID = p_plan_id
        AND   T.MODE_OF_TRANSPORT = g_tload
        AND   T.CARRIER_ID = p_carrier_id;

        l_CostPerUnitDist NUMBER;
    BEGIN
        IF P_LEVEL = g_plan_level THEN
            OPEN cur_cpud_plan;
            FETCH cur_cpud_plan INTO l_CostPerUnitDist;
            CLOSE cur_cpud_plan;
         ELSIF p_level = g_carrier_level THEN
            OPEN cur_cpud_carr;
            FETCH cur_cpud_carr INTO l_CostPerUnitDist;
            CLOSE cur_cpud_carr;
        END IF;
        IF l_CostPerUnitDist IS NULL THEN
            l_CostPerUnitDist := 0;
        END IF;
        l_CostPerUnitDist:= round(l_CostPerUnitDist, g_precision);
        RETURN l_CostPerUnitDist;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END TL_Cost_per_Unit_Dist;

    -- TL Cost per Unit Cube-Distance (KPI - 41)
    -- =========================================
    FUNCTION TL_Cost_per_Unit_Cube_Dist(p_plan_id     IN NUMBER,
                                        p_level       IN NUMBER,
                                        p_customer_id IN NUMBER,
                                        p_supplier_id IN NUMBER,
                                        p_carrier_id  IN NUMBER,
                                        p_fac_loc_id  IN NUMBER)
        RETURN NUMBER IS

    -- ---------------------------------------------------
    -- To compute this KPI we compute Total TL Cost (as
    -- measured by KPI 24) divided by TL cube-distance. TL
    -- Cube Distance is computed, depending on profile
    -- options, as
    --  (a)    Profile option is "actual distance traveled"
    --            sum(Volume * DistanceTraveled)
    --  (b)    Profile option is "direct route distance"
    --            sum(Volume * DirectRouteDistance)
    -- Calculation of this KPI requires cost-allocation to
    -- delivery legs.
    -- ---------------------------------------------------

        -- Plan Level
        -- -----------
        -- ---------------------------------------------------
        -- Expected result: For a given plan, Total TL Cost
        -- (as measured by KPI 24) at plan level divided by
        -- total TL Cube Distance.
        -- ---------------------------------------------------
            -- Using actual distance traveled:
            -- -------------------------------
            CURSOR cur_tl_cpucd_act_plan IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLCubeDist) TLCostPerUnitCubeDist
            FROM (  SELECT SUM(NVL(T.TOTAL_BASIC_TRANSPORT_COST, 0) +
                               NVL(T.TOTAL_STOP_COST, 0)            +
                               NVL(T.TOTAL_LAYOVER_COST, 0)         +
                               NVL(T.TOTAL_LOAD_UNLOAD_COST, 0)     +
                               NVL(T.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                    FROM MST_TRIPS T
                    WHERE T.PLAN_ID = p_plan_id
                    AND   T.MODE_OF_TRANSPORT = g_tload
                ) T11,
                ( SELECT SUM(NVL(TS.DISTANCE_TO_NEXT_STOP, 0) *
                             NVL(TS.DEPARTURE_VOLUME, 0)       ) TotalTLCubeDist
                  FROM MST_TRIP_STOPS TS,
                       MST_TRIPS T1
                  WHERE TS.PLAN_ID = T1.PLAN_ID
                  AND   TS.TRIP_ID = T1.TRIP_ID
                  AND   T1.PLAN_ID  = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_tload
                ) T12;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpucd_direct_plan IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLCubeDist) TLCostPerUnitCubeDist
            FROM (  SELECT SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                               NVL(T1.TOTAL_STOP_COST, 0)            +
                               NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                               NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                               NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                    FROM MST_TRIPS T1
                    WHERE T1.PLAN_ID = p_plan_id
                    AND   T1.MODE_OF_TRANSPORT = g_tload
                    ) T11,
                    ( SELECT SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                                 NVL(D.VOLUME, 0)) TotalTLCubeDist
                      FROM MST_DELIVERY_LEGS DL,
                           MST_DELIVERIES D,
                           MST_TRIPS T2,
                           MST_TRIP_STOPS TS
                      WHERE DL.PLAN_ID = D.PLAN_ID
                      AND   DL.DELIVERY_ID = D.DELIVERY_ID
                      AND   DL.PLAN_ID = TS.PLAN_ID
                      AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                             OR DL.DROP_OFF_STOP_ID = TS.STOP_ID )
                      AND   TS.PLAN_ID = T2.PLAN_ID
                      AND   TS.TRIP_ID = T2.TRIP_ID
                      AND   T2.PLAN_ID  = p_plan_id
                      AND   T2.MODE_OF_TRANSPORT = g_tload
                    ) T12;

        -- Carrier level
        -- -------------
        -- ---------------------------------------------------
        -- Expected result: For a given plan and carrier, Total
        -- TL Cost (as measured by KPI 24) at carrier level
        -- divided by Total TL Cube Distance per carrier.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpucd_act_carr IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLCubeDist) TLCostPerUnitCubeDist
            FROM ( SELECT SUM(
                              NVL(T.TOTAL_BASIC_TRANSPORT_COST, 0) +
                              NVL(T.TOTAL_STOP_COST, 0)            +
                              NVL(T.TOTAL_LAYOVER_COST, 0)         +
                              NVL(T.TOTAL_LOAD_UNLOAD_COST, 0)     +
                              NVL(T.TOTAL_ACCESSORIAL_COST, 0)      ) TotalTLCost
                   FROM MST_TRIPS T
                   WHERE T.PLAN_ID = p_plan_id
                   AND   T.CARRIER_ID = p_carrier_id
                   AND   T.MODE_OF_TRANSPORT = g_tload
                ) T11,
                ( SELECT SUM(NVL(TS.DISTANCE_TO_NEXT_STOP, 0) *
                             NVL(TS.DEPARTURE_VOLUME, 0)         ) TotalTLCubeDist
                  FROM MST_TRIP_STOPS TS,
                       MST_TRIPS T1
                  WHERE TS.PLAN_ID = T1.PLAN_ID
                  AND   TS.TRIP_ID = T1.TRIP_ID
                  AND   T1.PLAN_ID = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_tload
                  AND   T1.CARRIER_ID = p_Carrier_ID
                ) T12;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpucd_direct_carr IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLCubeDist) TLCostPerUnitCubeDist
            FROM ( SELECT SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0) +
                              NVL(T1.TOTAL_STOP_COST, 0)            +
                              NVL(T1.TOTAL_LAYOVER_COST, 0)         +
                              NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)     +
                              NVL(T1.TOTAL_ACCESSORIAL_COST, 0)      ) TotalTLCost
                   FROM MST_TRIPS T1
                   WHERE T1.PLAN_ID = p_plan_id
                   AND   T1.CARRIER_ID = p_carrier_id
                   AND   T1.MODE_OF_TRANSPORT = g_tload
                ) T11,
                ( SELECT SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                             NVL(D.VOLUME, 0)            ) TotalTLCubeDist
                  FROM MST_DELIVERY_LEGS DL,
                       MST_DELIVERIES D,
                       MST_TRIPS T2,
                       MST_TRIP_STOPS TS
                  WHERE DL.PLAN_ID = D.PLAN_ID
                  AND   DL.DELIVERY_ID = D.DELIVERY_ID
                  AND   DL.PLAN_ID = TS.PLAN_ID
                  AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                         OR DL.DROP_OFF_STOP_ID = TS.STOP_ID )
                  AND   TS.PLAN_ID = T2.PLAN_ID
                  AND   TS.TRIP_ID = T2.TRIP_ID
                  AND   T2.PLAN_ID  = p_plan_id
                  AND   T2.MODE_OF_TRANSPORT = g_tload
                  AND   T2.CARRIER_ID = p_carrier_id
                ) T12;

        -- Customer level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and customer,
        -- Total TL Cost (as measured by KPI 24) at the
        -- customer level divided by Total TL Cube Distance
        -- for orders corresponding to that customer.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpucd_act_cust IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST)   /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)              )   ) TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.CUSTOMER_ID = p_customer_Id
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpucd_direct_cust IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)            )  ) AS TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.CUSTOMER_ID = p_customer_id
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

        -- Supplier level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and supplier,
        -- Total TL Cost (as measured by KPI 24) at the
        -- supplier level divided by Total TL Cube Distance
        -- for orders corresponding to that supplier.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpucd_act_supp IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST)   /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)              ) ) TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.SUPPLIER_ID = p_supplier_id
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpucd_direct_supp IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)            )  ) TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.SUPPLIER_ID = p_supplier_id
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

        -- Facility level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and facility
        -- (location id), Total TL Cost (as measured by KPI 24)
        -- divided by Total TL Cube Distance for deliveries
        -- originating (ship from) or ending (ship to) at that
        -- facility.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpucd_act_fac(p_location_id IN NUMBER) IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)            )   ) AS TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   TS.STOP_LOCATION_ID = p_location_id
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpucd_direct_fac(p_location_id IN NUMBER) IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.VOLUME, 0)               )   ) TLCostPerUnitCubeDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   TS.STOP_LOCATION_ID = p_location_id
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

            l_TLCostPerUnitCubeDist NUMBER;
            l_dist_calc_type NUMBER := 1; -- default "actual distance traveled"
            l_location_id NUMBER;
    BEGIN
        OPEN cur_get_parameters;
        FETCH cur_get_parameters INTO l_dist_calc_type;
        CLOSE cur_get_parameters;
        IF l_dist_calc_type = g_act_dist_travel THEN
            IF P_LEVEL = g_plan_level THEN
                OPEN cur_tl_cpucd_act_plan;
                FETCH cur_tl_cpucd_act_plan INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_act_plan;
            ELSIF p_level = g_customer_level THEN
                OPEN cur_tl_cpucd_act_cust;
                FETCH cur_tl_cpucd_act_cust INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_act_cust;
            ELSIF p_level = g_supplier_level THEN
                OPEN cur_tl_cpucd_act_supp;
                FETCH cur_tl_cpucd_act_supp INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_act_supp;
            ELSIF p_level = g_carrier_level THEN
                OPEN cur_tl_cpucd_act_carr;
                FETCH cur_tl_cpucd_act_carr INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_act_carr;
            ELSIF p_level = g_facility_level THEN
                l_location_id := get_location(p_fac_loc_id);
                OPEN cur_tl_cpucd_act_fac(l_location_id);
                FETCH cur_tl_cpucd_act_fac INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_act_fac;
            END IF;
        ELSIF l_dist_calc_type = g_dir_route_dist THEN
            IF P_LEVEL = g_plan_level THEN
                OPEN cur_tl_cpucd_direct_plan;
                FETCH cur_tl_cpucd_direct_plan INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_direct_plan;
            ELSIF p_level = g_customer_level THEN
                OPEN cur_tl_cpucd_direct_cust;
                FETCH cur_tl_cpucd_direct_cust INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_direct_cust;
            ELSIF p_level = g_supplier_level THEN
                OPEN cur_tl_cpucd_direct_supp;
                FETCH cur_tl_cpucd_direct_supp INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_direct_supp;
            ELSIF p_level = g_carrier_level THEN
                OPEN cur_tl_cpucd_direct_carr;
                FETCH cur_tl_cpucd_direct_carr INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_direct_carr;
            ELSIF p_level = g_facility_level THEN
                l_location_id := get_location(p_fac_loc_id);
                OPEN cur_tl_cpucd_direct_fac(l_location_id);
                FETCH cur_tl_cpucd_direct_fac INTO l_TLCostPerUnitCubeDist;
                CLOSE cur_tl_cpucd_direct_fac;
            END IF;
        END IF;
        IF l_TLCostPerUnitCubeDist IS NULL THEN
            l_TLCostPerUnitCubeDist := 0 ;
        END IF;
        l_TLCostPerUnitCubeDist := round(l_TLCostPerUnitCubeDist, g_precision);
        RETURN l_TLCostPerUnitCubeDist;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END TL_Cost_per_Unit_Cube_Dist;

    -- TL Cost per Unit Weight-Distance (KPI - 42)
    -- ===========================================
    FUNCTION TL_Cost_per_Unit_Wt_Dist(p_plan_id     IN NUMBER,
                                      p_level       IN NUMBER,
                                      p_customer_id IN NUMBER,
                                      p_supplier_id IN NUMBER,
                                      p_carrier_id  IN NUMBER,
                                      p_fac_loc_id  IN NUMBER)
        RETURN NUMBER IS

    -- ---------------------------------------------------
    -- To compute this KPI we compute Total TL Cost (as
    -- measured by KPI 24) divided by TL weight-distance.
    -- Total TL Weight Distance is computed, depending on
    -- profile options, as
    --  (c) Profile option is "actual distance traveled"
    --          sum(GrossWeight * DistanceTraveled)
    --  (d) Profile option is "direct route distance"
    --          sum(GrossWeight * DirectRouteDistance)
    -- Calculation of this KPI requires cost-allocation to
    -- delivery legs.
    -- ---------------------------------------------------

        -- Plan level
        -- -----------
        -- ---------------------------------------------------
        -- Expected result: For a given plan, Total TL Cost
        -- (as measured by KPI 24) at plan level divided by
        -- Total TL Weight Distance.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- -------------------------------
            CURSOR cur_tl_cpuwd_act_plan IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLWeightDist) TLCostPerUnitWtDist
            FROM (  SELECT SUM(NVL(T.TOTAL_BASIC_TRANSPORT_COST, 0)   +
                               NVL(T.TOTAL_STOP_COST, 0)              +
                               NVL(T.TOTAL_LAYOVER_COST, 0)           +
                               NVL(T.TOTAL_LOAD_UNLOAD_COST, 0)       +
                               NVL(T.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                    FROM MST_TRIPS T
                    WHERE T.PLAN_ID = p_plan_id
                    AND T.MODE_OF_TRANSPORT = g_tload
                    ) T11,
                ( SELECT SUM(NVL(TS.DISTANCE_TO_NEXT_STOP, 0) *
                             NVL(TS.DEPARTURE_GROSS_WEIGHT, 0) ) TotalTLWeightDist
                  FROM MST_TRIP_STOPS TS,
                       MST_TRIPS T1
                  WHERE TS.PLAN_ID = T1.PLAN_ID
                  AND   TS.TRIP_ID = T1.TRIP_ID
                  AND   T1.PLAN_ID  = p_plan_id
                  AND   T1.MODE_OF_TRANSPORT = g_tload
                    ) T12;

            -- Using direct route distance
            -- ----------------------------
            CURSOR cur_tl_cpuwd_direct_plan IS
            SELECT (T11.TotalTLCost /
                    T12.TotalTLWeightDist) TLCostPerUnitWtDist
            FROM ( SELECT SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                              NVL(T1.TOTAL_STOP_COST, 0)           +
                              NVL(T1.TOTAL_LAYOVER_COST, 0)        +
                              NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)    +
                              NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                   FROM MST_TRIPS T1
                   WHERE T1.PLAN_ID = p_plan_id
                   AND   T1.MODE_OF_TRANSPORT = g_tload
                   ) T11,
                ( SELECT SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                             NVL(D.GROSS_WEIGHT, 0) ) TotalTLWeightDist
                  FROM MST_DELIVERY_LEGS DL,
                       MST_DELIVERIES D,
                       MST_TRIPS T2,
                       MST_TRIP_STOPS TS
                  WHERE DL.PLAN_ID = D.PLAN_ID
                  AND   DL.DELIVERY_ID = D.DELIVERY_ID
                  AND   DL.PLAN_ID = TS.PLAN_ID
                  AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                         OR DL.DROP_OFF_STOP_ID = TS.STOP_ID )
                  AND   TS.PLAN_ID = T2.PLAN_ID
                  AND   TS.TRIP_ID = T2.TRIP_ID
                  AND   T2.PLAN_ID  = p_plan_id
                  AND   T2.MODE_OF_TRANSPORT = g_tload
                   ) T12;

        -- Carrier level
        -- -------------
        -- ---------------------------------------------------
        -- Expected result: For a given plan and carrier, Total
        -- TL Cost (as measured by KPI 24) at carrier level
        -- divided by Total Weight Distance per carrier.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpuwd_act_carr IS
            SELECT (T11.TotalTLCost / T12.TotalTLWeightDist)
                                        TLCostPerUnitWtDist
            FROM ( SELECT SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                              NVL(T1.TOTAL_STOP_COST, 0)           +
                              NVL(T1.TOTAL_LAYOVER_COST, 0)        +
                              NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)    +
                              NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                   FROM MST_TRIPS T1
                   WHERE T1.PLAN_ID = p_plan_id
                   AND   T1.MODE_OF_TRANSPORT = g_tload
                   AND   T1.CARRIER_ID = p_carrier_id
                   ) T11,
                 ( SELECT SUM(NVL(TS.DISTANCE_TO_NEXT_STOP, 0) *
                              NVL(TS.DEPARTURE_GROSS_WEIGHT, 0) ) TotalTLWeightDist
                   FROM     MST_TRIP_STOPS TS,
                            MST_TRIPS T2
                   WHERE TS.PLAN_ID = T2.PLAN_ID
                   AND   TS.TRIP_ID = T2.TRIP_ID
                   AND   T2.PLAN_ID  = p_plan_id
                   AND   T2.MODE_OF_TRANSPORT = g_tload
                   AND   T2.CARRIER_ID = p_carrier_id
                   ) T12;

            -- Using direct route distance:
            -- ----------------------------
            CURSOR cur_tl_cpuwd_direct_carr IS
            SELECT (T11.TotalTLCost / T12.TotalTLWeightDist)
                                        TLCostPerUnitWtDist
            FROM ( SELECT SUM(NVL(T1.TOTAL_BASIC_TRANSPORT_COST, 0)+
                              NVL(T1.TOTAL_STOP_COST, 0)           +
                              NVL(T1.TOTAL_LAYOVER_COST, 0)        +
                              NVL(T1.TOTAL_LOAD_UNLOAD_COST, 0)    +
                              NVL(T1.TOTAL_ACCESSORIAL_COST, 0)     ) TotalTLCost
                   FROM MST_TRIPS T1
                   WHERE T1.PLAN_ID = p_plan_id
                   AND   T1.MODE_OF_TRANSPORT = g_tload
                   AND   T1.CARRIER_ID = p_carrier_id
                   ) T11,
                 ( SELECT SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                              NVL(D.GROSS_WEIGHT, 0) ) TotalTLWeightDist
                   FROM MST_DELIVERY_LEGS DL,
                        MST_DELIVERIES D,
                        MST_TRIPS T2,
                        MST_TRIP_STOPS TS
                   WHERE DL.PLAN_ID = D.PLAN_ID
                   AND   DL.DELIVERY_ID = D.DELIVERY_ID
                   AND   DL.PLAN_ID = TS.PLAN_ID
                   AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                          OR DL.DROP_OFF_STOP_ID = TS.STOP_ID )
                   AND   TS.PLAN_ID = T2.PLAN_ID
                   AND   TS.TRIP_ID = T2.TRIP_ID
                   AND   T2.PLAN_ID  = p_plan_id
                   AND   T2.MODE_OF_TRANSPORT = g_tload
                   AND   T2.CARRIER_ID = p_carrier_id
                   ) T12;


        -- Customer level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and customer,
        -- the Total TL Cost (as measured by KPI 24) at the
        -- customer level divided by Total TL Weight Distance
        -- for orders corresponding to that customer.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpuwd_act_cust IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)         )   ) TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.CUSTOMER_ID = p_customer_id
            AND   DL.PLAN_iD = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.PLAN_ID = p_plan_id
            AND   T.MODE_OF_TRANSPORT = g_tload;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpuwd_direct_cust IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)        )   ) TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.CUSTOMER_ID = p_customer_id
            AND   DL.PLAN_iD = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.PLAN_ID = p_plan_id
            AND   T.MODE_OF_TRANSPORT = g_tload;


        -- Supplier level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and supplier,
        -- Total TL Cost (as measured by KPI 24) at the
        -- supplier level divided by Total TL Weight Distance
        -- for orders corresponding to that supplier.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpuwd_act_supp IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)         )   ) TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.SUPPLIER_ID = p_supplier_id
            AND   DL.PLAN_iD = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.PLAN_ID = p_plan_id
            AND   T.MODE_OF_TRANSPORT = g_tload;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpuwd_direct_supp IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)         )   ) TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   D.SUPPLIER_ID = p_supplier_id
            AND   DL.PLAN_iD = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   T.PLAN_ID = p_plan_id
            AND   T.MODE_OF_TRANSPORT = g_tload;

        -- Facility level
        -- --------------
        -- ---------------------------------------------------
        -- Expected result: Given a specific plan and facility
        -- (location id), Total TL Cost (as measured by KPI 24)
        -- divided by Total TL Weight Distance for orders
        -- originating (ship from) or ending (ship to) at
        -- that facility.
        -- ---------------------------------------------------
            -- Using actual distance traveled
            -- ------------------------------
            CURSOR cur_tl_cpuwd_act_fac(p_location_id IN NUMBER) IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.TRAVELED_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)         )   ) AS TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   TS.STOP_LOCATION_ID = p_location_id
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

            -- Using direct route distance
            -- ---------------------------
            CURSOR cur_tl_cpuwd_direct_fac(p_location_id IN NUMBER) IS
            SELECT (SUM(DL.ALLOCATED_TRANSPORT_COST) /
                    SUM(NVL(DL.DIRECT_DISTANCE, 0) *
                        NVL(D.GROSS_WEIGHT, 0)         )   ) TLCostPerUnitWtDist
            FROM MST_DELIVERY_LEGS DL,
                 MST_DELIVERIES D,
                 MST_TRIPS T,
                 MST_TRIP_STOPS TS
            WHERE DL.PLAN_ID = D.PLAN_ID
            AND   DL.DELIVERY_ID = D.DELIVERY_ID
            AND   DL.PLAN_ID = TS.PLAN_ID
            AND   (   DL.PICK_UP_STOP_ID = TS.STOP_ID
                   OR DL.DROP_OFF_STOP_ID = TS.STOP_ID)
            AND   TS.PLAN_ID = T.PLAN_ID
            AND   TS.TRIP_ID = T.TRIP_ID
            AND   TS.STOP_LOCATION_ID = p_location_id
            AND   T.MODE_OF_TRANSPORT = g_tload
            AND   T.PLAN_ID           = p_plan_id;

        l_TLCostPerUnitWtDist NUMBER;
        l_dist_calc_type NUMBER := 1; -- default "actual distance traveled"
        l_location_id NUMBER;

    BEGIN

        OPEN cur_get_parameters;
        FETCH cur_get_parameters INTO l_dist_calc_type;
        CLOSE cur_get_parameters;

        IF l_dist_calc_type = g_act_dist_travel THEN
            IF P_LEVEL = g_plan_level THEN
                OPEN cur_tl_cpuwd_act_plan;
                FETCH cur_tl_cpuwd_act_plan INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_act_plan;
            ELSIF p_level = g_customer_level THEN
                OPEN cur_tl_cpuwd_act_cust;
                FETCH cur_tl_cpuwd_act_cust INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_act_cust;
            ELSIF p_level = g_supplier_level THEN
                OPEN cur_tl_cpuwd_act_supp;
                FETCH cur_tl_cpuwd_act_supp INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_act_supp;
            ELSIF p_level = g_carrier_level THEN
                OPEN cur_tl_cpuwd_act_carr;
                FETCH cur_tl_cpuwd_act_carr INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_act_carr;
            ELSIF p_level = g_facility_level THEN
                l_location_id := get_location(p_fac_loc_id);
                OPEN cur_tl_cpuwd_act_fac(l_location_id);
                FETCH cur_tl_cpuwd_act_fac INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_act_fac;
            END IF;
        ELSIF l_dist_calc_type = g_dir_route_dist THEN
            IF P_LEVEL = g_plan_level THEN
                OPEN cur_tl_cpuwd_direct_plan;
                FETCH cur_tl_cpuwd_direct_plan INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_direct_plan;
            ELSIF p_level = g_customer_level THEN
                OPEN cur_tl_cpuwd_direct_cust;
                FETCH cur_tl_cpuwd_direct_cust INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_direct_cust;
            ELSIF p_level = g_supplier_level THEN
                OPEN cur_tl_cpuwd_direct_supp;
                FETCH cur_tl_cpuwd_direct_supp INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_direct_supp;
            ELSIF p_level = g_carrier_level THEN
                OPEN cur_tl_cpuwd_direct_carr;
                FETCH cur_tl_cpuwd_direct_carr INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_direct_carr;
            ELSIF p_level = g_facility_level THEN
                l_location_id := get_location(p_fac_loc_id);
                OPEN cur_tl_cpuwd_direct_fac(l_location_id);
                FETCH cur_tl_cpuwd_direct_fac INTO l_TLCostPerUnitWtDist;
                CLOSE cur_tl_cpuwd_direct_fac;
            END IF;
        END IF;
        IF l_TLCostPerUnitWtDist IS NULL THEN
            l_TLCostPerUnitWtDist := 0;
        END IF;
        l_TLCostPerUnitWtDist := round(l_TLCostPerUnitWtDist, g_precision);

        RETURN l_TLCostPerUnitWtDist;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END TL_Cost_per_Unit_Wt_Dist;

    FUNCTION mst_performance_targets(p_target_level  IN VARCHAR2,
                                     p_dimension_id  IN VARCHAR2 )
         RETURN NUMBER IS

        CURSOR get_target_id(p_tgt_short_name IN VARCHAR2,
                             p_dim_id         IN VARCHAR2 ) IS
        SELECT t.target_id
        FROM bisfv_targets t,
             bisbv_target_levels tl,
             bisbv_application_measures am
        WHERE am.measure_short_name = p_tgt_short_name
        AND   am.measure_id         = tl.measure_id
        AND   tl.target_level_id    = t.target_level_id
        AND   decode(p_tgt_short_name,'MST_COST_PU_WT_PLAN'       ,t.dim1_level_value_id
                                     ,'MST_COST_PU_VOL_PLAN'      ,t.dim1_level_value_id
                                     ,'MST_COST_PU_DIST_PLAN'     ,t.dim1_level_value_id
                                     ,'MST_COST_PU_VOL_DIST_PLAN' ,t.dim1_level_value_id
                                     ,'MST_COST_PU_WT_DIST_PLAN'  ,t.dim1_level_value_id
                                     ,'MST_COST_PU_VOL_DIST_CARR' ,t.dim3_level_value_id
                                     ,'MST_COST_PU_WT_CARR'       ,t.dim3_level_value_id
                                     ,'MST_COST_PU_VOL_CARR'      ,t.dim3_level_value_id
                                     ,'MST_COST_PU_DIST_CARR'     ,t.dim3_level_value_id
                                     ,'MST_COST_PU_WT_DIST_CARR'  ,t.dim3_level_value_id
                                     ,'MST_COST_PU_WT_CUST'       ,t.dim1_level_value_id
                                     ,'MST_COST_PU_VOL_CUST'      ,t.dim1_level_value_id
                                     ,'MST_COST_PU_WT_DIST_CUST'  ,t.dim1_level_value_id
                                     ,'MST_COST_PU_VOL_DIST_CUST' ,t.dim1_level_value_id
                                     ,'MST_COST_PU_WT_SUPP'       ,t.dim2_level_value_id
                                     ,'MST_COST_PU_VOL_SUPP'      ,t.dim2_level_value_id
                                     ,'MST_COST_PU_VOL_DIST_SUPP' ,t.dim2_level_value_id
                                     ,'MST_COST_PU_WT_DIST_SUPP'  ,t.dim2_level_value_id
                                     ,'MST_COST_PU_WT_FAC'        ,t.dim4_level_value_id
                                     ,'MST_COST_PU_VOL_FAC'       ,t.dim4_level_value_id
                                     ,'MST_COST_PU_VOL_DIST_FAC'  ,t.dim4_level_value_id
                                     ,'MST_COST_PU_WT_DIST_FAC'   ,t.dim4_level_value_id
                                     ,'MST_COST_PU_WT_MODE'       ,t.dim5_level_value_id
                                     ,'MST_COST_PU_VOL_MODE'      ,t.dim5_level_value_id
                                                                  ,t.dim1_level_value_id) = p_dim_id;

        l_return_status   VARCHAR2(3);
        l_error_tbl       BIS_UTILITIES_PUB.error_tbl_type;

        l_target_rec      BIS_TARGET_PUB.target_rec_type;
        l_target_rec_out  BIS_TARGET_PUB.target_rec_type;

        invalid_target EXCEPTION;

    BEGIN

        OPEN get_target_id(p_target_level, p_dimension_id);
        FETCH get_target_id INTO l_target_rec.target_id;
        IF get_target_id%found THEN
            BIS_Target_Pub.retrieve_target(p_api_version => 1,
                                           p_target_rec => l_target_rec,
                                           p_all_info => FND_API.G_TRUE,
                                           x_target_rec => l_target_rec_out,
                                           x_return_status => l_return_status,
                                           x_error_tbl => l_error_tbl);
            IF l_return_status = 'E' THEN
                CLOSE get_target_id;
                RAISE invalid_target;
            END IF;

            --DBMS_OUTPUT.put_line('Range1_low is '||l_target_rec_out.Range1_low||
            --                ' and Hig val is '||l_target_rec_out.Range1_high||
            --                ' and target is '||l_target_rec_out.target);
        ELSE
            --dbms_output.put_line('target not defined!!!');
            NULL;
        END IF;
        CLOSE get_target_id;
        RETURN NVL(l_target_rec_out.target,0);
    EXCEPTION
        WHEN invalid_target THEN
            for i in 1..l_error_tbl.count loop
                DBMS_OUTPUT.put_line('error is '||l_error_tbl(i).Error_Description);
            end loop;
            RETURN 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.put_line('error is '||sqlerrm(sqlcode));
            return 0;
    END mst_performance_targets;
END MST_CMP_KPIS;

/
