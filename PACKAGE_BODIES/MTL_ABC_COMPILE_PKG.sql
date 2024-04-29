--------------------------------------------------------
--  DDL for Package Body MTL_ABC_COMPILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ABC_COMPILE_PKG" AS
/* $Header: INVCAACB.pls 120.2.12010000.2 2008/07/29 12:52:09 ptkumar ship $ */

PROCEDURE COMPILE_FUTURE_VALUE(x_organization_id IN NUMBER,
                               x_compile_id IN NUMBER,
                               x_forc_name IN VARCHAR2,
                               x_org_cost_group_id IN NUMBER,
                               x_cal_code IN VARCHAR2,
                               x_except_id IN NUMBER,
                               x_start_date IN VARCHAR2,
                               x_cutoff_date IN VARCHAR2,
                               x_item_scope_code IN NUMBER,
                               x_subinventory IN VARCHAR2) IS
 Type item_id IS TABLE OF NUMBER;
 Type qty_demand_total IS TABLE OF NUMBER;
 Type value_demand_total IS TABLE OF NUMBER;
 l_item_id item_id;
 l_qty_demand_total qty_demand_total;
 l_value_demand_total value_demand_total;
 i NUMBER;
BEGIN
    SELECT F.INVENTORY_ITEM_ID,
                       SUM(F.ORIGINAL_FORECAST_QUANTITY),
                       SUM(F.ORIGINAL_FORECAST_QUANTITY *
                           MTL_ABC_COMPILE_PKG.get_item_cost(F.ORGANIZATION_ID,
                                                          F.INVENTORY_ITEM_ID,
                                                          F.PROJECT_ID,
                                                          x_org_cost_group_id))
       BULK COLLECT INTO l_item_id,l_qty_demand_total,l_value_demand_total
       FROM
              BOM_CALENDAR_DATES        C1,
              MRP_FORECAST_DESIGNATORS  D1,
              MRP_FORECAST_DESIGNATORS  D2,
              MRP_FORECAST_DATES  F,
              MTL_ABC_COMPILES ABC
       WHERE  D2.FORECAST_DESIGNATOR = x_forc_name
       AND    D1.ORGANIZATION_ID = x_organization_id
       AND    D2.ORGANIZATION_ID = x_organization_id
       AND    D1.FORECAST_SET = NVL(D2.FORECAST_SET, x_forc_name)
       AND    D1.FORECAST_DESIGNATOR = DECODE(D2.FORECAST_SET, NULL,
                     D1.FORECAST_DESIGNATOR, x_forc_name)
       AND    ABC.ORGANIZATION_ID = F.ORGANIZATION_ID
       AND    ABC.COMPILE_ID = x_compile_id
       AND    F.INVENTORY_ITEM_ID = ABC.INVENTORY_ITEM_ID
       AND    F.ORGANIZATION_ID = x_organization_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 1
       AND    C1.CALENDAR_CODE = x_cal_code
       AND    C1.EXCEPTION_SET_ID = x_except_id
       AND  ( C1.CALENDAR_DATE >= F.FORECAST_DATE
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    C1.CALENDAR_DATE >=  FND_DATE.canonical_to_date(x_start_date)
       AND    C1.CALENDAR_DATE <=  FND_DATE.canonical_to_date(x_cutoff_date)
       AND    C1.CALENDAR_DATE = C1.NEXT_DATE
       AND    C1.CALENDAR_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE ))
       group by F.INVENTORY_ITEM_ID
       UNION ALL
       SELECT F.INVENTORY_ITEM_ID,
              SUM(F.ORIGINAL_FORECAST_QUANTITY/(C2.NEXT_SEQ_NUM-C3.NEXT_SEQ_NUM)),
              SUM((F.ORIGINAL_FORECAST_QUANTITY/(C2.NEXT_SEQ_NUM-C3.NEXT_SEQ_NUM)) *
                                        MTL_ABC_COMPILE_PKG.get_item_cost(F.ORGANIZATION_ID,
                                                                       F.INVENTORY_ITEM_ID,
                                                                       F.PROJECT_ID,
                                                                      x_org_cost_group_id))
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_CAL_WEEK_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1, MRP_FORECAST_DESIGNATORS D2,
              MTL_ABC_COMPILES ABC
       WHERE  D2.FORECAST_DESIGNATOR = x_forc_name
       AND    D1.ORGANIZATION_ID = x_organization_id
       AND    D2.ORGANIZATION_ID = x_organization_id
       AND    D1.FORECAST_SET = NVL(D2.FORECAST_SET, x_forc_name)
       AND    D1.FORECAST_DESIGNATOR = DECODE(D2.FORECAST_SET, NULL,
                     D1.FORECAST_DESIGNATOR, x_forc_name)
       AND    ABC.ORGANIZATION_ID = F.ORGANIZATION_ID
       AND    ABC.COMPILE_ID = x_compile_id
       AND    F.INVENTORY_ITEM_ID = ABC.INVENTORY_ITEM_ID
       AND    F.ORGANIZATION_ID = x_organization_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 2
       AND    W1.CALENDAR_CODE = x_cal_code
       AND    W1.EXCEPTION_SET_ID = x_except_id
       AND    (W1.WEEK_START_DATE >= F.FORECAST_DATE
       AND    W1.WEEK_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    W1.NEXT_DATE >     FND_DATE.canonical_to_date(x_start_date)
       AND    C1.CALENDAR_CODE = x_cal_code
       AND    C2.CALENDAR_CODE = x_cal_code
       AND    C3.CALENDAR_CODE = x_cal_code
       AND    C1.EXCEPTION_SET_ID = x_except_id
       AND    C2.EXCEPTION_SET_ID = x_except_id
       AND    C3.EXCEPTION_SET_ID = x_except_id
       AND    C3.CALENDAR_DATE= W1.WEEK_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    C1.CALENDAR_DATE >= FND_DATE.canonical_to_date(x_start_date)
       AND    C1.CALENDAR_DATE <= FND_DATE.canonical_to_date(x_cutoff_date)
       AND    C1.CALENDAR_DATE  = C1.NEXT_DATE
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       group by F.INVENTORY_ITEM_ID
       UNION ALL
       SELECT F.INVENTORY_ITEM_ID,
                SUM(F.ORIGINAL_FORECAST_QUANTITY/
                     (C2.NEXT_SEQ_NUM - C3.NEXT_SEQ_NUM)),
                SUM(F.ORIGINAL_FORECAST_QUANTITY/
                     (C2.NEXT_SEQ_NUM - C3.NEXT_SEQ_NUM) *
                           MTL_ABC_COMPILE_PKG.get_item_cost(F.ORGANIZATION_ID,
                                                          F.INVENTORY_ITEM_ID,
                                                          F.PROJECT_ID,
                                                          x_org_cost_group_id))
       FROM   BOM_CALENDAR_DATES C1, BOM_CALENDAR_DATES C2,
              BOM_CALENDAR_DATES C3,
              BOM_PERIOD_START_DATES W1, MRP_FORECAST_DATES F,
              MRP_FORECAST_DESIGNATORS D1, MRP_FORECAST_DESIGNATORS D2,
              MTL_ABC_COMPILES ABC
       WHERE  D2.FORECAST_DESIGNATOR = x_forc_name
       AND    D1.ORGANIZATION_ID = x_organization_id
       AND    D2.ORGANIZATION_ID = x_organization_id
       AND    D1.FORECAST_SET = NVL(D2.FORECAST_SET, x_forc_name)
       AND    D1.FORECAST_DESIGNATOR = DECODE(D2.FORECAST_SET, NULL,
                     D1.FORECAST_DESIGNATOR, x_forc_name)
       AND    ABC.ORGANIZATION_ID = F.ORGANIZATION_ID
       AND    ABC.COMPILE_ID = x_compile_id
       AND    F.INVENTORY_ITEM_ID = ABC.INVENTORY_ITEM_ID
       AND    F.ORGANIZATION_ID = x_organization_id
       AND    F.FORECAST_DESIGNATOR = D1.FORECAST_DESIGNATOR
       AND    F.BUCKET_TYPE = 3
       AND    W1.CALENDAR_CODE = x_cal_code
       AND    W1.EXCEPTION_SET_ID = x_except_id
       AND    (W1.PERIOD_START_DATE >= F.FORECAST_DATE
       AND    W1.PERIOD_START_DATE <= NVL(F.RATE_END_DATE, F.FORECAST_DATE))
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    W1.NEXT_DATE >   FND_DATE.canonical_to_date(x_start_date)
       AND    C1.CALENDAR_CODE = x_cal_code
       AND    C2.CALENDAR_CODE = x_cal_code
       AND    C3.CALENDAR_CODE = x_cal_code
       AND    C1.EXCEPTION_SET_ID = x_except_id
       AND    C2.EXCEPTION_SET_ID = x_except_id
       AND    C3.EXCEPTION_SET_ID = x_except_id
       AND    C3.CALENDAR_DATE= W1.PERIOD_START_DATE
       AND    C2.CALENDAR_DATE = W1.NEXT_DATE
       AND    (C1.CALENDAR_DATE >= C3.CALENDAR_DATE
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    C1.CALENDAR_DATE >=   FND_DATE.canonical_to_date(x_start_date)
       AND    C1.CALENDAR_DATE  = C1.NEXT_DATE
       --Added format mask while using to_date function to comply with
       --GSCC File.Date.5 standard. Bug:4410902
       -- Bug# 6819570, replaced the to_date function used earlier with
       -- FND_DATE.canonical_to_date which does not require format mask,
       -- hence avoiding ORA-01861 'literal does not match format string' error.
       AND    C1.CALENDAR_DATE <=   FND_DATE.canonical_to_date(x_cutoff_date)
       AND    C1.CALENDAR_DATE < C2.CALENDAR_DATE)
       group by F.INVENTORY_ITEM_ID;

     FORALL i IN l_item_id.FIRST .. l_item_id.LAST
         UPDATE MTL_ABC_COMPILES
            SET COMPILE_QUANTITY = COMPILE_QUANTITY + l_qty_demand_total(i),
                COMPILE_VALUE = COMPILE_VALUE + l_value_demand_total(i)
           WHERE ORGANIZATION_ID = x_organization_id
             AND inventory_item_id = l_item_id(i)
             AND compile_id = x_compile_id;

END COMPILE_FUTURE_VALUE;

FUNCTION GET_ITEM_COST(x_organization_id IN NUMBER,
                       x_inventory_item_id IN NUMBER,
                       x_project_id IN NUMBER,
                       x_cost_group_id IN NUMBER) return NUMBER
IS
 l_item_cost NUMBER := 0.0;
BEGIN
  IF (x_project_id IS NOT NULL) THEN
      SELECT NVL(CCICV.ITEM_COST,0) into l_item_cost
        FROM CST_CG_ITEM_COSTS_VIEW CCICV,
             MRP_PROJECT_PARAMETERS MPP
       WHERE CCICV.ORGANIZATION_ID = x_organization_id
         AND CCICV.INVENTORY_ITEM_ID = x_inventory_item_id
         AND CCICV.COST_GROUP_ID = MPP.COSTING_GROUP_ID
         AND MPP.PROJECT_ID = x_project_id
         AND MPP.ORGANIZATION_ID = x_organization_id;
  ELSIF (x_project_id IS NULL) THEN
     SELECT NVL(CCICV.ITEM_COST,0) into l_item_cost
       FROM CST_CG_ITEM_COSTS_VIEW CCICV
      WHERE CCICV.ORGANIZATION_ID = x_organization_id
        AND CCICV.INVENTORY_ITEM_ID = x_inventory_item_id
        AND CCICV.COST_GROUP_ID = x_cost_group_id;
  END IF;
  RETURN l_item_cost;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
     RETURN l_item_cost;
END GET_ITEM_COST;

-- BEGIN INVCONV
PROCEDURE CALCULATE_COMPILE_VALUE (
   p_organization_id   NUMBER
 , p_compile_id        NUMBER
 , p_cost_type_id      NUMBER) IS
   --
   -- variable declarations
   l_result_code        VARCHAR2 (30);
   l_return_status      VARCHAR2 (30);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2 (2000);
   l_transaction_date   DATE;
   l_cost_mthd          VARCHAR2 (15);
   l_cost_mthd_1        VARCHAR2 (15);
   l_cmpntcls           NUMBER;
   l_analysis_code      VARCHAR2 (15);
   l_item_cost          NUMBER;
   l_no_of_rows         NUMBER;

   CURSOR cur_get_abc_compiles IS
      SELECT     organization_id
               , inventory_item_id
               , compile_id
            FROM mtl_abc_compiles
           WHERE compile_id = p_compile_id
      FOR UPDATE;

BEGIN
   BEGIN
      SELECT cost_mthd_code
        INTO l_cost_mthd
        FROM cm_mthd_mst
       WHERE cost_type_id = p_cost_type_id;
   EXCEPTION WHEN OTHERS THEN
      l_cost_mthd := NULL;
   END;

   FOR i IN cur_get_abc_compiles LOOP
      -- variable assignments
      l_result_code := NULL;
      l_return_status := NULL;
      l_msg_count := NULL;
      l_msg_data := NULL;
      l_transaction_date := SYSDATE;
      l_cmpntcls := NULL;
      l_analysis_code := NULL;
      l_item_cost := NULL;
      l_no_of_rows := NULL;
      l_cost_mthd_1 := l_cost_mthd;

      -- call the costing API.
      l_result_code :=
         gmf_cmcommon.get_process_item_cost
            (p_api_version => 1
           , p_init_msg_list => 'F'
           , x_return_status => l_return_status
           , x_msg_count => l_msg_count
           , x_msg_data => l_msg_data
           , p_inventory_item_id => i.inventory_item_id
           , p_organization_id => i.organization_id
           , p_transaction_date => l_transaction_date   /* Cost as on date */
           , p_detail_flag => 1   /*  1 = total cost, 2 = details; 3 = cost for a specific component class/analysis code, etc. */
           , p_cost_method => l_cost_mthd_1   /* OPM Cost Method */
           , p_cost_component_class_id => l_cmpntcls
           , p_cost_analysis_code => l_analysis_code
           , x_total_cost => l_item_cost   /* total cost */
           , x_no_of_rows => l_no_of_rows   /* number of detail rows retrieved */
           );

      IF l_result_code <> 1 THEN
         l_item_cost := 0;
      END IF;

      UPDATE mtl_abc_compiles
         SET compile_value = compile_quantity * l_item_cost
       WHERE CURRENT OF cur_get_abc_compiles;

   END LOOP;

END CALCULATE_COMPILE_VALUE;
-- END INVCONV

END MTL_ABC_COMPILE_PKG;

/
