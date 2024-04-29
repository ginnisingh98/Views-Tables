--------------------------------------------------------
--  DDL for Package Body MSC_ATP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_REQ" AS
/* $Header: MSCRATPB.pls 120.29.12010000.13 2009/07/01 08:43:33 sbnaik ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_ATP_REQ';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

-- The resource functions will perform atp_consume and add the infinite time
-- fence and populate all the output tables correctly
-- The material functions will only execute the sqls. atp_consume and
-- adding the itf will be done elsewhere. Also, making sure all 3
-- output tables are populated is also done elsewhere.

PROCEDURE Print_Dates_Qtys(
   p_atp_dates          IN MRP_ATP_PUB.date_arr,
   p_atp_qtys           IN MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                for i in 1..p_atp_dates.count loop
                        msc_sch_wb.atp_debug('date: ' || p_atp_dates(i) ||
                                             ' qty: ' || p_atp_qtys(i));
                end loop;
        END IF;
END Print_Dates_Qtys;

--4570421
FUNCTION INTEGER_SCALING ( p_scale_qty IN NUMBER,
                           p_scale_multiple IN NUMBER,
                           p_scale_rounding_variance IN NUMBER,
                           p_rounding_direction IN NUMBER
)
RETURN NUMBER IS
var number;
rem_var number;
floor_qty number;
floor_deviation number;
ceil_qty number;
ceil_deviation number;
l_Scale_qty number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Integer Scaling');
      msc_sch_wb.atp_debug('Integer Scaling : p_scale_qty ' || p_scale_qty);
      msc_sch_wb.atp_debug('Integer Scaling : p_scale_multiple ' || p_scale_multiple);
      msc_sch_wb.atp_debug('Integer Scaling : p_scale_rounding_variance ' || p_scale_rounding_variance);
      msc_sch_wb.atp_debug('Integer Scaling : p_rounding_direction ' || p_rounding_direction);
  END IF;

  l_scale_qty := p_scale_qty;

  --variance
  var := p_scale_rounding_variance * l_scale_qty/100;

  IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Integer Scaling: : var ' || var);
  END IF;
  --variance remainder
  rem_var := l_scale_qty / p_scale_multiple;

  IF ( P_ROUNDING_DIRECTION = 1 ) THEN -- 1 for Down
      floor_qty := floor(rem_var) * p_scale_multiple;
      floor_deviation := l_scale_qty - floor_qty;
      IF (var >= floor_deviation AND floor_qty <> 0) THEN
         l_scale_qty := floor_qty;
      END IF;
  ELSIF ( P_ROUNDING_DIRECTION = 2 )THEN -- 2 for Up
      ceil_qty := ceil(rem_var) * p_scale_multiple;
      ceil_deviation := ceil_qty - l_scale_qty;
      IF (var >= ceil_deviation AND ceil_qty <> 0) THEN
          l_scale_qty := ceil_qty;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Integer Scaling:  Rounding direction: UP, l_scale_qty: ' || l_scale_qty);
      END IF;
  ELSIF ( P_ROUNDING_DIRECTION = 0 )THEN --0 for Both
     IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Integer Scaling:  Rounding direction: BOTH');
     END IF;
     floor_qty := floor(rem_var) * p_scale_multiple;
     floor_deviation := l_scale_qty - floor_qty;
     ceil_qty := ceil(rem_var) * p_scale_multiple;
     ceil_deviation := ceil_qty - l_scale_qty;
     IF ( floor_qty = 0 OR ceil_qty = 0 ) THEN
        --retain the value
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('retaining the value');
        END IF;
     ELSIF (var >= ceil_deviation AND ceil_qty <> 0) THEN --4904094, changed the cindition from var > ceil_deviation to var >= ceil_deviation
            l_scale_qty := ceil_qty;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Integer Scaling: Qty CEILed, l_scale_qty: ' || l_scale_qty);
           END IF;
     ELSIF (var >= floor_deviation AND floor_qty <> 0) THEN
           l_scale_qty := floor_qty;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Integer Scaling: Qty FLOORed, l_scale_qty: ' || l_scale_qty);
           END IF;
     END IF;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Integer Scaling :l_scale_qty ' || l_scale_qty);
  END IF;

  return l_scale_qty;

EXCEPTION
    WHEN ZERO_DIVIDE THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Integer Scaling: Division by Zero');
        END IF;
        l_scale_qty := p_scale_multiple;
        return l_scale_qty;
END integer_scaling;

-- 2859130
-- The final decision on this bug is to not change the sql for unconstrained plan and
-- not to change the logic to find the first available bucket. The sqls are moved out
-- into separate functions to improve readability
-- The only change to the unconstrained plan sqls is to add an itf
-- constrained plan
PROCEDURE get_res_avail_opt(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate); --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_opt');
        END IF;

        SELECT  SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (
           SELECT  -- 2859130
                   --C.CALENDAR_DATE SD_DATE,
                   -- Bug 3348095
                   -- For ATP created records use end_date otherwise start_date
                   DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)) ,
                           TRUNC(REQ.START_DATE)) SD_DATE,
                   -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                      DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))  SD_QTY
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
           FROM    MSC_DEPARTMENT_RESOURCES DR,
                   MSC_RESOURCE_REQUIREMENTS REQ,
                   -- CTO Option Dependent Resources ODR
                   -- Option Dependent Resources Capacity Check
                   -- Add Link to Items
                   MSC_SYSTEM_ITEMS I
                   -- 2859130
                   -- MSC_CALENDAR_DATES C
                   -- Bug 2675504, 2665805,
           --bug3394866
           WHERE   DR.PLAN_ID = p_plan_id
           AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
           AND     DR.RESOURCE_ID = p_res_id
           AND     DR.SR_INSTANCE_ID = p_instance_id
           -- krajan: 2408696 --
           AND     DR.organization_id = p_org_id

           AND     REQ.PLAN_ID = DR.PLAN_ID
           AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
           AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
           AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
           AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
           --bug3394866
           -- End Bug 2675504, 2665805,
           AND     NVL(REQ.PARENT_ID, 1) = 1 -- parent_id is 1 for constrained plans. Bug 2809639
           -- CTO Option Dependent Resources ODR
           -- Option Dependent Resources Capacity Check
           AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
           AND     I.PLAN_ID = REQ.PLAN_ID
           AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
           AND     I.inventory_item_id = REQ.assembly_item_id
           AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
           -- End CTO Option Dependent Resources ODR
           -- 2859130
           --AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
           --AND     C.CALENDAR_CODE = p_cal_code
           --AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
           --AND     C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
           -- AND     C.SEQ_NUM IS NOT NULL -- 2859130
           --bug 2341075: chnage sysdate to plan_start_date
           --AND     C.CALENDAR_DATE >= trunc(sysdate)
           --AND     C.CALENDAR_DATE >= p_plan_start_date
           --bug3693892 added trunc
           AND TRUNC(REQ.START_DATE) >= p_plan_start_date
           -- 2859130
           AND TRUNC(REQ.START_DATE) < trunc(nvl(p_itf,REQ.START_DATE+1))--4135752
           UNION ALL
           SELECT  trunc(SHIFT_DATE) SD_DATE,--4135752
                   CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                   to_time,to_time + 24*3600,
                        to_time) - from_time)/3600) SD_QTY
           FROM    MSC_NET_RESOURCE_AVAIL
           WHERE   PLAN_ID = p_plan_id
           AND     NVL(PARENT_ID, -2) <> -1
           AND     SR_INSTANCE_ID = p_instance_id
           AND     RESOURCE_ID = p_res_id
           AND     DEPARTMENT_ID = p_dept_id
           --bug 2341075: chnage sysdate to plan_start_date
           --AND     SHIFT_DATE >= trunc(sysdate)
           AND     trunc(SHIFT_DATE) >= p_plan_start_date --4135752
           AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130--4135752
        )
        GROUP BY SD_DATE
        ORDER BY SD_DATE;
END get_res_avail_opt;

-- unconstrained plan
PROCEDURE get_res_avail_unopt(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate); --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_unopt');
        END IF;

        SELECT  SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (
         SELECT  C.CALENDAR_DATE SD_DATE,
                 -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                    DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                   -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))  SD_QTY
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
         FROM    MSC_DEPARTMENT_RESOURCES DR,
                 MSC_RESOURCE_REQUIREMENTS REQ,
                 -- CTO Option Dependent Resources ODR
                 -- Option Dependent Resources Capacity Check
                 -- Add Link to Items
                 MSC_SYSTEM_ITEMS I,
                 MSC_CALENDAR_DATES C
                 -- Bug 2675504, 2665805,
         --bug3394866
         WHERE   DR.PLAN_ID = p_plan_id
         AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
         AND     DR.RESOURCE_ID = p_res_id
         AND     DR.SR_INSTANCE_ID = p_instance_id
           -- krajan: 2408696 --
         AND     DR.organization_id = p_org_id

         AND     REQ.PLAN_ID = DR.PLAN_ID
         AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
         --bug3394866
         -- End Bug 2675504, 2665805
         AND     NVL(REQ.PARENT_ID, MSC_ATP_PVT.G_OPTIMIZED_PLAN) = MSC_ATP_PVT.G_OPTIMIZED_PLAN
         -- CTO Option Dependent Resources ODR
         -- Option Dependent Resources Capacity Check
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.inventory_item_id = REQ.assembly_item_id
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources ODR
         AND     C.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3394866
         AND     C.CALENDAR_CODE = p_cal_code
         AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                 -- Bug 3348095
                 -- Ensure that the ATP created resource Reqs
                 -- do not get double counted.
         AND     C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                          TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                 -- End Bug 3348095
         AND     C.SEQ_NUM IS NOT NULL
         --bug 2341075: chnage sysdate to plan_start_date
         --AND     C.CALENDAR_DATE >= trunc(sysdate)
         AND     C.CALENDAR_DATE >= p_plan_start_date
         -- 2859130
         AND     C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
         UNION ALL
         SELECT  trunc(SHIFT_DATE) SD_DATE,--4135752
                 CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                 to_time,to_time + 24*3600,
                      to_time) - from_time)/3600) SD_QTY
         FROM    MSC_NET_RESOURCE_AVAIL
         WHERE   PLAN_ID = p_plan_id
         AND     NVL(PARENT_ID, -2) <> -1
         AND     SR_INSTANCE_ID = p_instance_id
         AND     RESOURCE_ID = p_res_id
         AND     DEPARTMENT_ID = p_dept_id
         --bug 2341075: chnage sysdate to plan_start_date
         --AND     SHIFT_DATE >= trunc(sysdate)
         AND     trunc(SHIFT_DATE) >= p_plan_start_date
         AND     trunc(SHIFT_DATE) < nvl(p_itf, SHIFT_DATE+1) -- 2859130
         )
         GROUP BY SD_DATE
         ORDER BY SD_DATE;
END get_res_avail_unopt;

-- constrained plan batching
PROCEDURE get_res_avail_opt_bat(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate);--4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_opt_bat');
        END IF;

        SELECT  SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (
           SELECT  -- 2859130 C.CALENDAR_DATE SD_DATE,
                   -- Bug 3348095
                   -- For ATP created records use end_date otherwise start_date
                   DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)),
                           TRUNC(REQ.START_DATE)) SD_DATE,
                   -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                       DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                      -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))
                      -- For ATP created records use resource_hours
                      -- End Bug 3348095
                           *
                         DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                          NVL(MUC.CONVERSION_RATE,1) * NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY) SD_QTY

           FROM    MSC_DEPARTMENT_RESOURCES DR,
                   MSC_RESOURCE_REQUIREMENTS REQ,
                   -- 2859130 MSC_CALENDAR_DATES C,
                   --- add table for resource batching
                   --- these tables are added to determine how much apacity has already been consumed by the
                   --- existing supplies
                   MSC_SYSTEM_ITEMS I,
                   MSC_SUPPLIES S,
                   MSC_UOM_CONVERSIONS MUC
           -- Bug 2675504, 2665805,
           --bug3394866
           WHERE   DR.PLAN_ID = p_plan_id
           AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
           AND     DR.RESOURCE_ID = p_res_id
           AND     DR.SR_INSTANCE_ID = p_instance_id
           -- krajan: 2408696 --
           AND     DR.organization_id = p_org_id

           AND     REQ.PLAN_ID = DR.PLAN_ID
           AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
           AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
           AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
           AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
           --bug3394866
           -- End Bug 2675504, 2665805,
           AND     NVL(REQ.PARENT_ID, 1) = 1 -- parent_id is 1 for constrained plans. Bug 2809639
           AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_Id
           AND     I.PLAN_ID = S.PLAN_ID
           AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
           AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
           AND     DECODE(p_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
           AND     MUC.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
           AND     MUC.INVENTORY_ITEM_ID  (+)= 0
           AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
           AND     S.PLAN_ID = REQ.PLAN_ID
           AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
           AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                   -- Exclude Cancelled Supplies 2460645
           AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
           -- CTO Option Dependent Resources ODR
           -- Option Dependent Resources Capacity Check
           AND     I.inventory_item_id = REQ.assembly_item_id
           AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
           -- End CTO Option Dependent Resources ODR
           -- 2859130
           --AND     C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
           --AND     C.CALENDAR_CODE = p_cal_code
           --AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
           --AND     C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
           -- AND     C.SEQ_NUM IS NOT NULL -- 2859130
           ---bug 2341075: change sysdate to plan_start_date
           --AND     C.CALENDAR_DATE >= trunc(sysdate)
           --AND     C.CALENDAR_DATE >= p_plan_start_date
           --bug3693892 added trunc
           AND     TRUNC(REQ.START_DATE) >= p_plan_start_date
           -- 2859130
           AND TRUNC(REQ.START_DATE) < trunc(nvl(p_itf, REQ.START_DATE+1)) --4135752
           UNION ALL
           SELECT  trunc(SHIFT_DATE) SD_DATE,--4135752
                   CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                   to_time,to_time + 24*3600,
                        to_time) - from_time)/3600)* p_max_capacity * p_res_conv_rate SD_QTY
           FROM    MSC_NET_RESOURCE_AVAIL
           WHERE   PLAN_ID = p_plan_id
           AND     NVL(PARENT_ID, -2) <> -1
           AND     SR_INSTANCE_ID = p_instance_id
           AND     RESOURCE_ID = p_res_id
           AND     DEPARTMENT_ID = p_dept_id
           -- krajan : 2408696 -- agilent
           AND     organization_id = p_org_id
           ---bug 2341075: change sysdate to plan_start_date
           --AND     SHIFT_DATE >= trunc(sysdate)
           AND     trunc(SHIFT_DATE) >= p_plan_start_date --4135752
           AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130 --4135752
        )
        GROUP BY SD_DATE
        ORDER BY SD_DATE;
END get_res_avail_opt_bat;

-- unconstrained plan batching
PROCEDURE get_res_avail_unopt_bat(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate);--4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_unopt_bat');
        END IF;

        SELECT  SD_DATE,
                SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (
         SELECT  C.CALENDAR_DATE SD_DATE,
               -1*DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                     DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                      -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))
                      -- For ATP created records use resource_hours
                      -- End Bug 3348095
                       *
                       DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME) *
                        NVL(MUC.CONVERSION_RATE,1) * NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY) SD_QTY

         FROM    MSC_DEPARTMENT_RESOURCES DR,
                 MSC_RESOURCE_REQUIREMENTS REQ,
                 MSC_CALENDAR_DATES C,
                 --- add table for resource batching
                 --- these tables are added to determine how much apacity has already been consumed by the
                 --- existing supplies
                 MSC_SYSTEM_ITEMS I,
                 MSC_SUPPLIES S,
                 MSC_UOM_CONVERSIONS MUC
         -- Bug 2675504, 2665805,
         --bug3394866
         WHERE   DR.PLAN_ID = p_plan_id
         AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
         AND     DR.RESOURCE_ID = p_res_id
         AND     DR.SR_INSTANCE_ID = p_instance_id
           -- krajan: 2408696 --
         AND     DR.organization_id = p_org_id

         AND     REQ.PLAN_ID = DR.PLAN_ID
         AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
         AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
         AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
         AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
         --bug3394866
         -- End Bug 2675504, 2665805,
         AND     NVL(REQ.PARENT_ID, MSC_ATP_PVT.G_OPTIMIZED_PLAN) = MSC_ATP_PVT.G_OPTIMIZED_PLAN
         AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_ID
         AND     I.PLAN_ID = S.PLAN_ID
         AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
         AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
         AND     DECODE(p_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
         AND     MUC.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
         AND     MUC.INVENTORY_ITEM_ID  (+)= 0
         AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
         AND     S.PLAN_ID = REQ.PLAN_ID
         AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
         AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                 -- Exclude Cancelled Supplies 2460645
         AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         -- CTO Option Dependent Resources ODR
         -- Option Dependent Resources Capacity Check
         AND     I.inventory_item_id = REQ.assembly_item_id
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources ODR
         AND     C.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3394866
         AND     C.CALENDAR_CODE = p_cal_code
         AND     C.EXCEPTION_SET_ID = p_cal_exc_set_id
                 -- Bug 3348095
                 -- Ensure that the ATP created resource Reqs
                 -- do not get double counted.
         AND     C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                          TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                   AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                 -- End Bug 3348095
         AND     C.SEQ_NUM IS NOT NULL
         ---bug 2341075: change sysdate to plan_start_date
         --AND     C.CALENDAR_DATE >= trunc(sysdate)
         AND     C.CALENDAR_DATE >= p_plan_start_date
         -- 2859130
         AND     C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
         UNION ALL
         SELECT  trunc(SHIFT_DATE) SD_DATE,  --4135752
                 CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                 to_time,to_time + 24*3600,
                      to_time) - from_time)/3600)* p_max_capacity * p_res_conv_rate SD_QTY
         FROM    MSC_NET_RESOURCE_AVAIL
         WHERE   PLAN_ID = p_plan_id
         AND     NVL(PARENT_ID, -2) <> -1
         AND     SR_INSTANCE_ID = p_instance_id
         AND     RESOURCE_ID = p_res_id
         AND     DEPARTMENT_ID = p_dept_id
         -- krajan : 2408696 -- agilent
         AND     organization_id = p_org_id
         ---bug 2341075: change sysdate to plan_start_date
         --AND     SHIFT_DATE >= trunc(sysdate)
         AND     trunc(SHIFT_DATE) >= p_plan_start_date  --4135752
         AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130  --4135752
         )
         GROUP BY SD_DATE
         ORDER BY SD_DATE;
END get_res_avail_unopt_bat;

-- constrained plan details
PROCEDURE get_res_avail_opt_dtls(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_code           IN VARCHAR2,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate); --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_opt_dtls');
        END IF;

         INSERT INTO msc_atp_sd_details_temp (
                ATP_Level,
                Order_line_id,
                Scenario_Id,
                Inventory_Item_Id,
                Request_Item_Id,
                Organization_Id,
                Department_Id,
                Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
                From_Organization_Id,
                From_Location_Id,
                To_Organization_Id,
                To_Location_Id,
                Ship_Method,
                UOM_code,
                Supply_Demand_Type,
                Supply_Demand_Source_Type,
                Supply_Demand_Source_Type_Name,
                Identifier1,
                Identifier2,
                Identifier3,
                Identifier4,
                Supply_Demand_Quantity,
                Supply_Demand_Date,
                Disposition_Type,
                Disposition_Name,
                Pegging_Id,
                End_Pegging_Id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login
        )

        (SELECT
                p_level col1,
                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_org_id col6,
                p_dept_id col7,
                p_res_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                p_uom_code col16,
                1 col17, -- demand
                MSC_ATP_FUNC.Get_Order_Type(REQ.SUPPLY_ID, p_plan_id) col18,
                l_null_char col19,
  --              	L.MEANING col19 ,
                REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
                REQ.TRANSACTION_ID col22,
                l_null_num col23,
                -- Bug 3348095
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                    -- For ATP created records use resource_hours
                      DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) col24,
                -- C.CALENDAR_DATE col25, -- 2859130
                -- For ATP created records use end_date otherwise start_date
                DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)),
                           TRUNC(REQ.START_DATE)) col25,
                -- End Bug 3348095
                l_null_num col26,
                MSC_ATP_FUNC.Get_Order_Number(REQ.SUPPLY_ID, p_plan_id) col27,
                l_null_num col28,
               l_null_num col29,
                l_sysdate,
                FND_GLOBAL.User_ID,
                l_sysdate,
                FND_GLOBAL.User_ID,
                FND_GLOBAL.User_ID
        FROM    MSC_DEPARTMENT_RESOURCES DR,
                MSC_RESOURCE_REQUIREMENTS REQ,
                -- CTO Option Dependent Resources
                -- Option Dependent Resources Capacity Check
                -- Add Link to Items
                MSC_SYSTEM_ITEMS I
               -- 2859130 MSC_CALENDAR_DATES C
        -- Bug 2675504, 2665805,
        --bug3394866
        WHERE   DR.PLAN_ID = p_plan_id
        AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
        AND     DR.RESOURCE_ID = p_res_id
        AND     DR.SR_INSTANCE_ID = p_instance_id
        -- krajan: 2408696 --
        AND     DR.organization_id = p_org_id

        AND     REQ.PLAN_ID = DR.PLAN_ID
        AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
        AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
        AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
        AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
        --bug3394866-- End Bug 2675504, 2665805,
        AND    NVL(REQ.PARENT_ID, 1) = 1 -- parent_id is 1 for constrained plans. Bug 2809639
         -- CTO Option Dependent Resources ODR
         -- Option Dependent Resources Capacity Check
         AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
         AND     I.PLAN_ID = REQ.PLAN_ID
         AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
         AND     I.inventory_item_id = REQ.assembly_item_id
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources ODR
        -- 2859130
        --AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
        --AND    C.CALENDAR_CODE = p_cal_code
        --AND    C.EXCEPTION_SET_ID = p_cal_exc_set_id
        --AND    C.CALENDAR_DATE = TRUNC(REQ.START_DATE)  -- Bug 2809639
        -- AND    C.SEQ_NUM IS NOT NULL -- 2859130
        ---bug 2341075: change sysdate to plan_start_date
        --AND    C.CALENDAR_DATE >= trunc(sysdate)
        --AND    C.CALENDAR_DATE >= p_plan_start_date
        --bug3693892 added trunc
        AND    TRUNC(REQ.START_DATE) >= p_plan_start_date
        -- 2859130
        AND TRUNC(REQ.START_DATE) < nvl(p_itf, REQ.START_DATE+1)
        UNION ALL
        SELECT
                p_level col1,
                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_org_id col6,
                p_dept_id col7,
                p_res_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                p_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
  --              	L.MEANING col19 ,
                SR_INSTANCE_ID col20,
                l_null_num col21,
                TRANSACTION_ID col22,
                l_null_num col23,
                CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                        to_time,to_time + 24*3600,
                       to_time) - from_time)/3600) col24,
                trunc(SHIFT_DATE) col25, --4135752
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
                l_null_num col29,
                l_sysdate,
                FND_GLOBAL.User_ID,
                l_sysdate,
                FND_GLOBAL.User_ID,
                FND_GLOBAL.User_ID
        FROM    MSC_NET_RESOURCE_AVAIL
        WHERE   PLAN_ID = p_plan_id
        AND     NVL(PARENT_ID, -2) <> -1
        AND     SR_INSTANCE_ID = p_instance_id
        AND     RESOURCE_ID = p_res_id
        -- 2408696 : krajan
        AND     organization_id = p_org_id
        AND     DEPARTMENT_ID = p_dept_id
        ---bug 2341075: change sysdate to plan_start_date
        --AND     SHIFT_DATE >= trunc(sysdate)
        AND     trunc(SHIFT_DATE) >= p_plan_start_date --4135752
        AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130  --4135752
        );
END get_res_avail_opt_dtls;

-- unconstrained plan dtls
PROCEDURE get_res_avail_unopt_dtls(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_code           IN VARCHAR2,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate); --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_unopt_dtls');
        END IF;

		 INSERT INTO msc_atp_sd_details_temp (
			ATP_Level,
			Order_line_id,
			Scenario_Id,
			Inventory_Item_Id,
			Request_Item_Id,
			Organization_Id,
			Department_Id,
			Resource_Id,
			Supplier_Id,
			Supplier_Site_Id,
			From_Organization_Id,
			From_Location_Id,
			To_Organization_Id,
			To_Location_Id,
			Ship_Method,
			UOM_code,
			Supply_Demand_Type,
			Supply_Demand_Source_Type,
			Supply_Demand_Source_Type_Name,
			Identifier1,
			Identifier2,
			Identifier3,
			Identifier4,
			Supply_Demand_Quantity,
			Supply_Demand_Date,
			Disposition_Type,
			Disposition_Name,
			Pegging_Id,
			End_Pegging_Id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login
		)

          	(SELECT
                	p_level col1,
                	MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                	p_scenario_id col3,
                	l_null_num col4 ,
                	l_null_num col5,
                	p_org_id col6,
                	p_dept_id col7,
                	p_res_id col8,
                	l_null_num col9,
                	l_null_num col10,
                	l_null_num col11,
                	l_null_num col12,
                	l_null_num col13,
                	l_null_num col14,
                	l_null_char col15,
                	p_uom_code col16,
                	1 col17, -- demand
                	MSC_ATP_FUNC.Get_Order_Type(REQ.SUPPLY_ID, p_plan_id) col18,
	                l_null_char col19,
--              	L.MEANING col19 ,
                	REQ.SR_INSTANCE_ID col20,
                	l_null_num col21,
                	REQ.TRANSACTION_ID col22,
                	l_null_num col23,
                        -- Bug 3348095
                        -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                          DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                        -- For ATP created records use resource_hours
                            DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) col24,
                        -- End Bug 3348095
                	C.CALENDAR_DATE col25,
                	l_null_num col26,
                	MSC_ATP_FUNC.Get_Order_Number(REQ.SUPPLY_ID, p_plan_id) col27,
                	l_null_num col28,
         	       l_null_num col29,
			l_sysdate,
			FND_GLOBAL.User_ID,
			l_sysdate,
			FND_GLOBAL.User_ID,
			FND_GLOBAL.User_ID
         	FROM   MSC_DEPARTMENT_RESOURCES DR,
                	MSC_RESOURCE_REQUIREMENTS REQ,
                       -- CTO Option Dependent Resources
                       -- Option Dependent Resources Capacity Check
                       -- Add Link to Items
                       MSC_SYSTEM_ITEMS I,
         	       MSC_CALENDAR_DATES C
               -- Bug 2675504, 2665805,
               --bug3394866
               WHERE   DR.PLAN_ID = p_plan_id
               AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
               AND     DR.RESOURCE_ID = p_res_id
               AND     DR.SR_INSTANCE_ID = p_instance_id
               -- krajan: 2408696 --
               AND     DR.organization_id = p_org_id

               AND     REQ.PLAN_ID = DR.PLAN_ID
               AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
               AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
               AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
               AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
               --bug3394866-- End Bug 2675504, 2665805,
               AND    NVL(REQ.PARENT_ID, MSC_ATP_PVT.G_OPTIMIZED_PLAN) = MSC_ATP_PVT.G_OPTIMIZED_PLAN
                -- CTO Option Dependent Resources ODR
                -- Option Dependent Resources Capacity Check
                AND     I.SR_INSTANCE_ID = REQ.SR_INSTANCE_Id
                AND     I.PLAN_ID = REQ.PLAN_ID
                AND     I.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                AND     I.inventory_item_id = REQ.assembly_item_id
                AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
                      -- bom_item_type not model and option_class always committed.
                           AND   (I.atp_flag <> 'N')
                      -- atp_flag is 'Y' then committed.
                           OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
                     -- if record created by ATP then committed.
                -- End CTO Option Dependent Resources ODR
         	AND    C.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3394866
         	AND    C.CALENDAR_CODE = p_cal_code
         	AND    C.EXCEPTION_SET_ID = p_cal_exc_set_id
                       -- Bug 3348095
                       -- Ensure that the ATP created resource Reqs
                       -- do not get double counted.
                AND    C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                            TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                         AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                       -- End Bug 3348095
         	AND    C.SEQ_NUM IS NOT NULL
                ---bug 2341075: change sysdate to plan_start_date
         	--AND    C.CALENDAR_DATE >= trunc(sysdate)
         	AND    C.CALENDAR_DATE >= p_plan_start_date
                -- 2859130
                AND     C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
         	UNION ALL
         	SELECT
                	p_level col1,
                	MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                	p_scenario_id col3,
                	l_null_num col4 ,
                	l_null_num col5,
                	p_org_id col6,
                	p_dept_id col7,
                	p_res_id col8,
                	l_null_num col9,
                	l_null_num col10,
                	l_null_num col11,
                	l_null_num col12,
                	l_null_num col13,
                	l_null_num col14,
                	l_null_char col15,
                	p_uom_code col16,
                	2 col17, -- supply
                	l_null_num col18,
	                l_null_char col19,
--              	L.MEANING col19 ,
                	SR_INSTANCE_ID col20,
                	l_null_num col21,
                	TRANSACTION_ID col22,
                	l_null_num col23,
                	CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                	       	to_time,to_time + 24*3600,
                	       to_time) - from_time)/3600) col24,
                	trunc(SHIFT_DATE) col25,  --4135752
                	l_null_num col26,
                	l_null_char col27,
                	l_null_num col28,
        	        l_null_num col29,
			l_sysdate,
			FND_GLOBAL.User_ID,
			l_sysdate,
			FND_GLOBAL.User_ID,
			FND_GLOBAL.User_ID
        	FROM    MSC_NET_RESOURCE_AVAIL
        	WHERE   PLAN_ID = p_plan_id
        	AND     NVL(PARENT_ID, -2) <> -1
        	AND     SR_INSTANCE_ID = p_instance_id
        	AND     RESOURCE_ID = p_res_id
                -- 2408696 : krajan
                AND     organization_id = p_org_id
        	AND     DEPARTMENT_ID = p_dept_id
                ---bug 2341075: change sysdate to plan_start_date
        	--AND     SHIFT_DATE >= trunc(sysdate)
        	AND     trunc(SHIFT_DATE) >= p_plan_start_date  --4135752
                AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130  --4135752
     	   	);
		-- dsting removed 'order by col25'
END get_res_avail_unopt_dtls;

-- constrained plan batching details
PROCEDURE get_res_avail_opt_bat_dtls(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate);  --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_opt_bat_dtls');
        END IF;

        INSERT INTO msc_atp_sd_details_temp (
                ATP_Level,
                Order_line_id,
                Scenario_Id,
                Inventory_Item_Id,
                Request_Item_Id,
                Organization_Id,
                Department_Id,
                Resource_Id,
                Supplier_Id,
                Supplier_Site_Id,
                From_Organization_Id,
                From_Location_Id,
                To_Organization_Id,
                To_Location_Id,
                Ship_Method,
                UOM_code,
                Supply_Demand_Type,
                Supply_Demand_Source_Type,
                Supply_Demand_Source_Type_Name,
                Identifier1,
                Identifier2,
                Identifier3,
                Identifier4,
                Supply_Demand_Quantity,
                Supply_Demand_Date,
                Disposition_Type,
                Disposition_Name,
                Pegging_Id,
                End_Pegging_Id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login
        )

        (SELECT
                p_level col1,
                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_org_id col6,
                p_dept_id col7,
                p_res_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                p_uom_code col16,
                1 col17, -- demand
                MSC_ATP_FUNC.Get_Order_Type(REQ.SUPPLY_ID, p_plan_id) col18,
                l_null_char col19,
  --              	L.MEANING col19 ,
                REQ.SR_INSTANCE_ID col20,
                l_null_num col21,
                REQ.TRANSACTION_ID col22,
                l_null_num col23,
                -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE, -- 2859130 remove daily_resource_hours
                           REQ.RESOURCE_HOURS) *
                              DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME)
                              * NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY) col24,
                -- 2859130 C.CALENDAR_DATE col25,
                -- Bug 3348095
                -- For ATP created records use end_date otherwise start_date
                DECODE(REQ.record_source, 2, TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)),
                           TRUNC(REQ.START_DATE)) col25,
                -- End Bug 3348095
                l_null_num col26,
                MSC_ATP_FUNC.Get_Order_Number(REQ.SUPPLY_ID, p_plan_id) col27,
                l_null_num col28,
               l_null_num col29,
                l_sysdate,
                FND_GLOBAL.User_ID,
                l_sysdate,
                FND_GLOBAL.User_ID,
                FND_GLOBAL.User_ID
        FROM   MSC_DEPARTMENT_RESOURCES DR,
                MSC_RESOURCE_REQUIREMENTS REQ,
               -- 2859130 MSC_CALENDAR_DATES C,
               ---tables added for resource batching
               MSC_SYSTEM_ITEMS I,
               MSC_SUPPLIES S,
               MSC_UOM_CONVERSIONS MUC
        -- Bug 2675504, 2665805,
        --bug3394866
        WHERE   DR.PLAN_ID = p_plan_id
        AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
        AND     DR.RESOURCE_ID = p_res_id
        AND     DR.SR_INSTANCE_ID = p_instance_id
        -- krajan: 2408696 --
        AND     DR.organization_id = p_org_id

        AND     REQ.PLAN_ID = DR.PLAN_ID
        AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
        AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
        AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
        AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
        --bug3394866
        -- End Bug 2675504, 2665805,
        AND     NVL(REQ.PARENT_ID, 1) = 1 -- parent_id is 1 for constrained plans. Bug 2809639
        AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_Id
        AND     I.PLAN_ID = S.PLAN_ID
        AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
        AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
        AND     DECODE(p_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
        AND     MUC.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
        AND     MUC.INVENTORY_ITEM_ID (+) = 0
        AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
        AND     S.PLAN_ID = REQ.PLAN_ID
        AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
        AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                -- Exclude Cancelled Supplies 2460645
        AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
         -- CTO Option Dependent Resources ODR
         -- Option Dependent Resources Capacity Check
         AND     I.inventory_item_id = REQ.assembly_item_id
         AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
               -- bom_item_type not model and option_class always committed.
                    AND   (I.atp_flag <> 'N')
               -- atp_flag is 'Y' then committed.
                    OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
              -- if record created by ATP then committed.
         -- End CTO Option Dependent Resources ODR
        -- 2859130
        --AND    C.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
        --AND    C.CALENDAR_CODE = p_cal_code
        --AND    C.EXCEPTION_SET_ID = p_cal_exc_set_id
        --AND    C.CALENDAR_DATE = TRUNC(REQ.START_DATE) -- Bug 2809639
        -- AND    C.SEQ_NUM IS NOT NULL -- 2859130
        ---bug 2341075: change sysdate to plan_start_date
        --AND    C.CALENDAR_DATE >= trunc(sysdate)
        -- AND    C.CALENDAR_DATE >= p_plan_start_date
        --bug3693892 added trunc
        AND TRUNC(REQ.START_DATE) >= p_plan_start_date
        -- 2859130
        AND TRUNC(REQ.START_DATE) < trunc(nvl(p_itf, REQ.START_DATE+1))  --4135752
        UNION ALL
        SELECT
                p_level col1,
                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                p_scenario_id col3,
                l_null_num col4 ,
                l_null_num col5,
                p_org_id col6,
                p_dept_id col7,
                p_res_id col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                p_uom_code col16,
                2 col17, -- supply
                l_null_num col18,
                l_null_char col19,
  --              	L.MEANING col19 ,
                SR_INSTANCE_ID col20,
                l_null_num col21,
                TRANSACTION_ID col22,
                l_null_num col23,
                CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                        to_time,to_time + 24*3600,
                       to_time) - from_time)/3600) * p_max_capacity * p_res_conv_rate col24,
                trunc(SHIFT_DATE) col25,  --4135752
                l_null_num col26,
                l_null_char col27,
                l_null_num col28,
                l_null_num col29,
                l_sysdate,
                FND_GLOBAL.User_ID,
                l_sysdate,
                FND_GLOBAL.User_ID,
                FND_GLOBAL.User_ID
        FROM    MSC_NET_RESOURCE_AVAIL
        WHERE   PLAN_ID = p_plan_id
        AND     NVL(PARENT_ID, -2) <> -1
        AND     SR_INSTANCE_ID = p_instance_id
        AND     RESOURCE_ID = p_res_id
        -- 2408696 : krajan agilent
        AND     organization_id = p_org_id

        AND     DEPARTMENT_ID = p_dept_id
        ---bug 2341075: chnage sysdate to plan_start_date
        --AND     SHIFT_DATE >= trunc(sysdate)
        AND     trunc(SHIFT_DATE) >= p_plan_start_date  --4135752
        AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130  --4135752
        );
END get_res_avail_opt_bat_dtls;

-- unconstrained plan batching details
PROCEDURE get_res_avail_unopt_bat_dtls(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER
) IS
l_null_num      NUMBER;
l_null_char     VARCHAR2(1);
l_sysdate       DATE := trunc(sysdate);  --4135752
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('get_res_avail_unopt_bat_dtls');
        END IF;

	 	 INSERT INTO msc_atp_sd_details_temp (
			ATP_Level,
			Order_line_id,
			Scenario_Id,
			Inventory_Item_Id,
			Request_Item_Id,
			Organization_Id,
			Department_Id,
			Resource_Id,
			Supplier_Id,
			Supplier_Site_Id,
			From_Organization_Id,
			From_Location_Id,
			To_Organization_Id,
			To_Location_Id,
			Ship_Method,
			UOM_code,
			Supply_Demand_Type,
			Supply_Demand_Source_Type,
			Supply_Demand_Source_Type_Name,
			Identifier1,
			Identifier2,
			Identifier3,
			Identifier4,
			Supply_Demand_Quantity,
			Supply_Demand_Date,
			Disposition_Type,
			Disposition_Name,
			Pegging_Id,
			End_Pegging_Id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login
		)

          	(SELECT
                	p_level col1,
                	MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                	p_scenario_id col3,
                	l_null_num col4 ,
                	l_null_num col5,
                	p_org_id col6,
                	p_dept_id col7,
                	p_res_id col8,
                	l_null_num col9,
                	l_null_num col10,
                	l_null_num col11,
                	l_null_num col12,
                	l_null_num col13,
                	l_null_num col14,
                	l_null_char col15,
                	p_uom_code col16,
                	1 col17, -- demand
                	MSC_ATP_FUNC.Get_Order_Type(REQ.SUPPLY_ID, p_plan_id) col18,
	                l_null_char col19,
--              	L.MEANING col19 ,
                	REQ.SR_INSTANCE_ID col20,
                	l_null_num col21,
                	REQ.TRANSACTION_ID col22,
                	l_null_num col23,
                        -- Bug 3348095
                        -1* DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                          DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                        -- For ATP created records use resource_hours
                            DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))
                        -- End Bug 3348095
                	          *
                               DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, UNIT_VOLUME)
                                * NVL(MUC.CONVERSION_RATE, 1) * NVL(S.NEW_ORDER_QUANTITY, S.FIRM_QUANTITY) col24,
                	C.CALENDAR_DATE col25,
                	l_null_num col26,
                	MSC_ATP_FUNC.Get_Order_Number(REQ.SUPPLY_ID, p_plan_id) col27,
                	l_null_num col28,
         	       l_null_num col29,
			l_sysdate,
			FND_GLOBAL.User_ID,
			l_sysdate,
			FND_GLOBAL.User_ID,
			FND_GLOBAL.User_ID
         	FROM   MSC_DEPARTMENT_RESOURCES DR,
                	MSC_RESOURCE_REQUIREMENTS REQ,
         	       MSC_CALENDAR_DATES C,
                       ---tables added for resource batching
                       MSC_SYSTEM_ITEMS I,
                       MSC_SUPPLIES S,
                       MSC_UOM_CONVERSIONS MUC
                -- Bug 2675504, 2665805,
                --bug3394866
                WHERE   DR.PLAN_ID = p_plan_id
                AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
                AND     DR.RESOURCE_ID = p_res_id
                AND     DR.SR_INSTANCE_ID = p_instance_id
                -- krajan: 2408696 --
                AND     DR.organization_id = p_org_id

                AND     REQ.PLAN_ID = DR.PLAN_ID
                AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
                AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
                AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
                AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
                --bug3394866
                -- End Bug 2675504, 2665805,
         	AND    NVL(REQ.PARENT_ID, MSC_ATP_PVT.G_OPTIMIZED_PLAN) = MSC_ATP_PVT.G_OPTIMIZED_PLAN
                AND     I.SR_INSTANCE_ID = S.SR_INSTANCE_Id
                AND     I.PLAN_ID = S.PLAN_ID
                AND     I.ORGANIZATION_ID = S.ORGANIZATION_ID
                AND     I.INVENTORY_ITEM_ID = S.INVENTORY_ITEM_ID
                AND     DECODE(p_uom_type, 1, I.WEIGHT_UOM, 2 , I.VOLUME_UOM) = MUC.UOM_CODE (+)
                AND     MUC.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
                AND     MUC.INVENTORY_ITEM_ID (+) = 0
                AND     S.TRANSACTION_ID = REQ.SUPPLY_ID
                AND     S.PLAN_ID = REQ.PLAN_ID
                AND     S.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID
                AND     S.ORGANIZATION_ID = REQ.ORGANIZATION_ID
                        -- Exclude Cancelled Supplies 2460645
                AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                -- CTO Option Dependent Resources ODR
                -- Option Dependent Resources Capacity Check
                AND     I.inventory_item_id = REQ.assembly_item_id
                AND     ((I.bom_item_type <> 1 and I.bom_item_type <> 2)
                      -- bom_item_type not model and option_class always committed.
                           AND   (I.atp_flag <> 'N')
                      -- atp_flag is 'Y' then committed.
                           OR    (REQ.record_source = 2) ) -- this OR may be changed during performance analysis.
                     -- if record created by ATP then committed.
                -- End CTO Option Dependent Resources ODR
         	AND    C.SR_INSTANCE_ID = REQ.SR_INSTANCE_ID --bug3394866
         	AND    C.CALENDAR_CODE = p_cal_code
         	AND    C.EXCEPTION_SET_ID = p_cal_exc_set_id
                       -- Bug 3348095
                       -- Ensure that the ATP created resource Reqs
                       -- do not get double counted.
                AND    C.CALENDAR_DATE BETWEEN DECODE(REQ.record_source, 2,
                            TRUNC(NVL(REQ.END_DATE, REQ.START_DATE)), TRUNC(REQ.START_DATE))
                         AND TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))
                       -- End Bug 3348095
         	AND    C.SEQ_NUM IS NOT NULL
                ---bug 2341075: change sysdate to plan_start_date
         	--AND    C.CALENDAR_DATE >= trunc(sysdate)
         	AND    C.CALENDAR_DATE >= trunc(p_plan_start_date)  --4135752
                -- 2859130
                AND     C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE+1)
         	UNION ALL
         	SELECT
                	p_level col1,
                	MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                	p_scenario_id col3,
                	l_null_num col4 ,
                	l_null_num col5,
                	p_org_id col6,
                	p_dept_id col7,
                	p_res_id col8,
                	l_null_num col9,
                	l_null_num col10,
                	l_null_num col11,
                	l_null_num col12,
                	l_null_num col13,
                	l_null_num col14,
                	l_null_char col15,
                	p_uom_code col16,
                	2 col17, -- supply
                	l_null_num col18,
	                l_null_char col19,
--              	L.MEANING col19 ,
                	SR_INSTANCE_ID col20,
                	l_null_num col21,
                	TRANSACTION_ID col22,
                	l_null_num col23,
                	CAPACITY_UNITS * ((DECODE(LEAST(from_time, to_time),
                	       	to_time,to_time + 24*3600,
                	       to_time) - from_time)/3600) * p_max_capacity * p_res_conv_rate col24,
                	trunc(SHIFT_DATE) col25,  --4135752
                	l_null_num col26,
                	l_null_char col27,
                	l_null_num col28,
        	        l_null_num col29,
			l_sysdate,
			FND_GLOBAL.User_ID,
			l_sysdate,
			FND_GLOBAL.User_ID,
			FND_GLOBAL.User_ID
        	FROM    MSC_NET_RESOURCE_AVAIL
        	WHERE   PLAN_ID = p_plan_id
        	AND     NVL(PARENT_ID, -2) <> -1
        	AND     SR_INSTANCE_ID = p_instance_id
        	AND     RESOURCE_ID = p_res_id
                -- 2408696 : krajan agilent
                AND     organization_id = p_org_id

        	AND     DEPARTMENT_ID = p_dept_id
                ---bug 2341075: chnage sysdate to plan_start_date
        	--AND     SHIFT_DATE >= trunc(sysdate)
        	AND     trunc(SHIFT_DATE) >= p_plan_start_date  --4135752
                AND     trunc(SHIFT_DATE) < trunc(nvl(p_itf, SHIFT_DATE+1)) -- 2859130  --4135752
     	   	);
END get_res_avail_unopt_bat_dtls;

PROCEDURE get_res_avail_summ(
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_refresh_number     IN NUMBER,  -- For summary enhancement
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('get_res_avail_summ');
    END IF;

    SELECT  SD_DATE,
            SUM(SD_QTY)
    BULK COLLECT INTO x_atp_dates, x_atp_qtys
    FROM
        (
            select  /*+ INDEX(r MSC_ATP_SUMMARY_RES_U1) */
                    trunc(r.sd_date) SD_DATE,  --4135752
                    r.sd_qty
            from    msc_atp_summary_res r
            where   r.plan_id = p_plan_id and
                    r.sr_instance_id = p_instance_id and
                    r.organization_id = p_org_id and
                    r.department_id = p_dept_id and
                    r.resource_id = p_res_id and
                    ---bug 2341075: change sysdate to plan start date
                    --sd_date >= trunc(sysdate) and
                    sd_date >= p_plan_start_date and  --4135752
                    sd_date < trunc(nvl(p_itf, sd_date + 1)) and -- 2859130  --4135752
                    sd_qty <> 0

            UNION ALL

            -- Summary enhancement : differences from non summary SQL:
            --  1. No union with MSC_NET_RES_AVAIL
            --  2. Get the hours always from RESOURCE_HOURS - never from LOAD_RATE or DAILY_RESOURCE_HOURS
            --  3. PARENT_ID removed from where clause. No difference between constrained and unconstrained plans
            --  4. MSC_SYSTEM_ITEMS not included in the join because the filters on items is not applied for ATP records
            --  5. MSC_PLANS included in the join to get latest refresh number
            --  6. Filter records based on refresh_number
                    -- Bug 3348095
                    -- For ATP created records use end_date otherwise start_date
            SELECT  TRUNC(NVL(REQ.END_DATE, REQ.START_DATE))   SD_DATE,
                    -- End Bug 3348095
                    -1 * REQ.RESOURCE_HOURS SD_QTY  -- Summary enhancement: Need to bother only about ATP generated records
            FROM    MSC_DEPARTMENT_RESOURCES DR,
                    MSC_RESOURCE_REQUIREMENTS REQ,
                    MSC_PLANS P                     -- For summary enhancement
            --bug3394866
            WHERE   DR.PLAN_ID = p_plan_id
            AND     NVL(DR.OWNING_DEPARTMENT_ID, DR.DEPARTMENT_ID)=p_dept_id
            AND     DR.RESOURCE_ID = p_res_id
            AND     DR.SR_INSTANCE_ID = p_instance_id
            AND     DR.organization_id = p_org_id
            AND     REQ.PLAN_ID = DR.PLAN_ID
            AND     REQ.SR_INSTANCE_ID = DR.SR_INSTANCE_ID
            AND     REQ.RESOURCE_ID = DR.RESOURCE_ID
            AND     REQ.DEPARTMENT_ID = DR.DEPARTMENT_ID
            AND     REQ.ORGANIZATION_ID = DR.ORGANIZATION_ID
            --bug3394866
            --bug3693892 added trunc
            AND     TRUNC(REQ.START_DATE) >= p_plan_start_date  --4135752
            AND     TRUNC(REQ.START_DATE) < trunc(nvl(p_itf, REQ.START_DATE+1))
            AND     P.PLAN_ID = REQ.PLAN_ID
            AND     (REQ.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR REQ.REFRESH_NUMBER = p_refresh_number)
        )
    GROUP BY SD_DATE
    ORDER BY SD_DATE;

    print_dates_qtys(x_atp_dates, x_atp_qtys);

    IF MSC_ATP_PVT.G_RES_CONSUME = 'Y' THEN
        MSC_ATP_PROC.atp_consume(x_atp_qtys, x_atp_qtys.COUNT);
    END IF;

END get_res_avail_summ;

PROCEDURE get_res_avail(
   p_batching_flag      IN NUMBER,
   p_optimized_flag     IN NUMBER,
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('get_res_avail');
   END IF;

   IF nvl(p_batching_flag, 0) = 1 THEN
      IF nvl(p_optimized_flag, 0) = 1 THEN
         get_res_avail_opt_bat(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_max_capacity,
            p_res_conv_rate,
            x_atp_dates,
            x_atp_qtys
         );
      ELSE
         get_res_avail_unopt_bat(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_max_capacity,
            p_res_conv_rate,
            p_cal_code,
            p_cal_exc_set_id,
            x_atp_dates,
            x_atp_qtys
         );
      END IF;
   ELSE
      IF nvl(p_optimized_flag, 0) = 1 THEN
         get_res_avail_opt(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            x_atp_dates,
            x_atp_qtys
         );
      ELSE
         get_res_avail_unopt(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_cal_code,
            p_cal_exc_set_id,
            x_atp_dates,
            x_atp_qtys
         );
      END IF;
   END IF;

   IF MSC_ATP_PVT.G_RES_CONSUME = 'Y' THEN
       MSC_ATP_PROC.atp_consume(x_atp_qtys, x_atp_qtys.COUNT);
   END IF;

END get_res_avail;

PROCEDURE get_res_avail_dtls(
   p_batching_flag      IN NUMBER,
   p_optimized_flag     IN NUMBER,
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_item_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   x_atp_period         OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ
) IS
BEGIN

   MSC_ATP_DB_UTILS.Clear_SD_Details_temp();

   IF nvl(p_batching_flag, 0) = 1 THEN
      IF nvl(p_optimized_flag, 0) = 1 THEN
         get_res_avail_opt_bat_dtls(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_uom_code,
            p_max_capacity,
            p_res_conv_rate,
            p_level,
            p_scenario_id
         );
      ELSE
         get_res_avail_unopt_bat_dtls(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_uom_code,
            p_max_capacity,
            p_res_conv_rate,
            p_level,
            p_scenario_id,
            p_cal_code,
            p_cal_exc_set_id
         );
      END IF;
   ELSE
      IF nvl(p_optimized_flag, 0) = 1 THEN
         get_res_avail_opt_dtls(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_code,
            p_level,
            p_scenario_id
         );
      ELSE
         get_res_avail_unopt_dtls(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_code,
            p_level,
            p_scenario_id,
            p_cal_code,
            p_cal_exc_set_id
         );
      END IF;
   END IF;

   MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);
   x_atp_period.cumulative_quantity := x_atp_period.period_quantity;

print_dates_qtys(x_atp_period.period_start_date,x_atp_period.period_quantity);
   IF MSC_ATP_PVT.G_RES_CONSUME = 'Y' THEN
       MSC_ATP_PROC.atp_consume(x_atp_period.Cumulative_Quantity,
                                x_atp_period.Cumulative_Quantity.count);
   END IF;

END get_res_avail_dtls;

PROCEDURE get_unalloc_res_avail(
   p_insert_flag        IN NUMBER,
   p_batching_flag      IN NUMBER,
   p_optimized_flag     IN NUMBER,
   p_instance_id        IN NUMBER,
   p_org_id             IN NUMBER,
   p_plan_id            IN NUMBER,
   p_plan_start_date    IN DATE,
   p_dept_id            IN NUMBER,
   p_res_id             IN NUMBER,
   p_itf                IN DATE,
   p_uom_type           IN NUMBER,
   p_uom_code           IN VARCHAR2,
   p_max_capacity       IN NUMBER,
   p_res_conv_rate      IN NUMBER,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_item_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_summary_flag       IN VARCHAR2,    -- For summary enhancement
   p_refresh_number     IN NUMBER,      -- For summary enhancement
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr,
   x_atp_period         OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ
) IS
BEGIN
  IF nvl(p_insert_flag,0) = 1 THEN
     get_res_avail_dtls(
            p_batching_flag,
            p_optimized_flag,
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_uom_code,
            p_max_capacity,
            p_res_conv_rate,
            p_level,
            p_scenario_id,
            p_item_id,
            p_cal_code,
            p_cal_exc_set_id,
            x_atp_period
     );

     IF p_itf IS NOT NULL THEN
         MSC_ATP_PROC.add_inf_time_fence_to_period(
                 p_level,
                 MSC_ATP_PVT.G_ORDER_LINE_ID, -- identifier
                 p_scenario_id,
                 p_item_id,
                 p_item_id, -- requested item id
                 p_org_id,
                 null,                -- p_supplier_id
                 null,                -- p_supplier_site_id
                 p_itf,
                 x_atp_period);

     END IF;

     x_atp_dates := x_atp_period.Period_Start_Date;
     x_atp_qtys  := x_atp_period.Cumulative_Quantity;
  ELSE
     IF p_summary_flag = 'Y' AND  -- MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND -- changed for summary enhancement
        (MSC_ATP_PVT.G_ALLOCATED_ATP = 'N' OR
            (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y' AND
             MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND
             MSC_ATP_PVT.G_ALLOCATION_METHOD = 1))
     THEN
        get_res_avail_summ(
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_refresh_number,   -- For summary enhancement
            x_atp_dates,
            x_atp_qtys
        );
     ELSE
        get_res_avail(
            p_batching_flag,
            p_optimized_flag,
            p_instance_id,
            p_org_id,
            p_plan_id,
            p_plan_start_date,
            p_dept_id,
            p_res_id,
            p_itf,
            p_uom_type,
            p_max_capacity,
            p_res_conv_rate,
            p_cal_code,
            p_cal_exc_set_id,
            x_atp_dates,
            x_atp_qtys
         );
      END IF;

      IF p_itf IS NOT NULL THEN
        -- add one more entry to indicate infinite time fence date
        -- and quantity.
        x_atp_dates.EXTEND;
        x_atp_qtys.EXTEND;
        x_atp_dates(x_atp_dates.count) := p_itf;
        x_atp_qtys(x_atp_qtys.count) := MSC_ATP_PVT.INFINITE_NUMBER;
      END IF;

   END IF;
END get_unalloc_res_avail;

----------------------------------------------------------------------------

PROCEDURE get_mat_avail_ods_summ (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_demand_class       IN VARCHAR2,
   p_default_atp_rule_id IN NUMBER,
   p_default_dmd_class  IN VARCHAR2,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_ods_summ');
        END IF;

        SELECT SD_DATE, sum(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM
        (SELECT  /*+ INDEX(D MSC_ATP_SUMMARY_SO_U1) */
                 trunc(D.SD_DATE) SD_DATE,   --4135752
                 -1* D.SD_QTY SD_QTY
        FROM        MSC_ATP_SUMMARY_SO D,
                    MSC_ATP_RULES R,
                    MSC_SYSTEM_ITEMS I
        WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
        AND         I.ORGANIZATION_ID = p_org_id
        AND         I.SR_INSTANCE_ID = p_instance_id
        AND         I.PLAN_ID = p_plan_id
        AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND	    R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND	    D.PLAN_ID = I.PLAN_ID
        AND	    D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND	    D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND 	    D.ORGANIZATION_ID = I.ORGANIZATION_ID
        AND         trunc(D.SD_DATE) < trunc(NVL(p_itf,  --4135752
                         D.SD_DATE + 1))
        AND         NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                             DECODE(R.DEMAND_CLASS_ATP_FLAG,
                             1, NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')),
                             NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')))
        AND D.SD_QTY <> 0
        UNION ALL

        SELECT      /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                    trunc(S.SD_DATE) SD_DATE,   --4135752
                    S.SD_QTY SD_QTY
        FROM        MSC_ATP_SUMMARY_SD S,
                    MSC_ATP_RULES R,
                    MSC_SYSTEM_ITEMS I
        WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
        AND         I.ORGANIZATION_ID = p_org_id
        AND         I.SR_INSTANCE_ID = p_instance_id
        AND         I.PLAN_ID = p_plan_id
        AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND         R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND	    S.PLAN_ID = I.PLAN_ID
        AND	    S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND	    S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND 	    S.ORGANIZATION_ID = I.ORGANIZATION_ID
        AND         trunc(S.SD_DATE) < trunc(NVL(p_itf, S.SD_DATE + 1))  --4135752
        AND         NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                             DECODE(R.DEMAND_CLASS_ATP_FLAG,
                             1, NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')),
                             NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')))
        AND      S.SD_QTY <> 0

        )
        group by SD_DATE
        order by SD_DATE;--4698199
END get_mat_avail_ods_summ;

PROCEDURE get_mat_avail_summ (
    p_item_id           IN NUMBER,
    p_org_id            IN NUMBER,
    p_instance_id       IN NUMBER,
    p_plan_id           IN NUMBER,
    p_itf               IN DATE,
    p_refresh_number    IN NUMBER,   -- For summary enhancement
    x_atp_dates         OUT NoCopy MRP_ATP_PUB.date_arr,
    x_atp_qtys          OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_summ');
        END IF;

    -- SQL changed for summary enhancement
    SELECT  SD_DATE, SUM(SD_QTY)
    BULK COLLECT INTO x_atp_dates, x_atp_qtys
    FROM   (
            SELECT  /*+ INDEX(S MSC_ATP_SUMMARY_SD_U1) */
                    SD_DATE, SD_QTY
            FROM    MSC_ATP_SUMMARY_SD S,
                    MSC_SYSTEM_ITEMS I
            WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
            AND     I.ORGANIZATION_ID = p_org_id
            AND     I.SR_INSTANCE_ID = p_instance_id
            AND     I.PLAN_ID = p_plan_id
            AND     S.PLAN_ID = I.PLAN_ID
            AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND     trunc(S.SD_DATE) < trunc(NVL(p_itf, S.SD_DATE + 1))  --4135752

            UNION ALL

            SELECT  TRUNC(NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)) SD_DATE,--plan by request,promise,schedule date
                    decode(D.USING_REQUIREMENT_QUANTITY,            -- Consider unscheduled orders as dummy supplies
                    0, nvl(D.OLD_DEMAND_QUANTITY,0), --4658238                -- For summary enhancement
                    -1 * D.USING_REQUIREMENT_QUANTITY)  SD_QTY
            FROM    MSC_DEMANDS D,
                    MSC_SYSTEM_ITEMS I,
                    MSC_PLANS P                                     -- For summary enhancement
            WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
            AND     I.ORGANIZATION_ID = p_org_id
            AND     I.SR_INSTANCE_ID = p_instance_id
            AND     I.PLAN_ID = p_plan_id
            AND     D.PLAN_ID = I.PLAN_ID
            AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND     D.ORIGINATION_TYPE NOT IN (4,5,7,8,9,11,15,22,28,29,31)
            AND     D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
                    --bug3693892 added trunc
            AND     trunc(NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)) <
            		   trunc(NVL(p_itf, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE) + 1))
            		   --plan by requestdate,promisedate,scheduledate
            AND     P.PLAN_ID = I.PLAN_ID
            AND     (D.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR D.REFRESH_NUMBER = p_refresh_number)

            UNION ALL

            SELECT  TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                    NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM    MSC_SUPPLIES S,
                    MSC_SYSTEM_ITEMS I,
                    MSC_PLANS P                                     -- For summary enhancement
            WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
            AND     I.ORGANIZATION_ID = p_org_id
            AND     I.SR_INSTANCE_ID = p_instance_id
            AND     I.PLAN_ID = p_plan_id
            AND     S.PLAN_ID = I.PLAN_ID
            AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND     NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2          -- These two conditions
            AND     NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0  -- may not be required
            AND     TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1)
            AND     P.PLAN_ID = I.PLAN_ID
            AND     (S.REFRESH_NUMBER > P.LATEST_REFRESH_NUMBER
                     OR S.REFRESH_NUMBER = p_refresh_number)

    )
    GROUP BY SD_DATE
    ORDER BY SD_DATE;
END get_mat_avail_summ;

PROCEDURE get_mat_avail_ods (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sysdate_seq_num    IN NUMBER,
   p_sys_next_date      IN DATE,
   p_demand_class       IN VARCHAR2,
   p_default_atp_rule_id IN NUMBER,
   p_default_dmd_class  IN VARCHAR2,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_ods');
        END IF;

        -- SQL Query changes Begin 2640489
        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
        SELECT  C.PRIOR_DATE SD_DATE,
                -1* D.USING_REQUIREMENT_QUANTITY SD_QTY
        FROM    MSC_CALENDAR_DATES C,
                MSC_DEMANDS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I
        WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
        AND     I.ORGANIZATION_ID = p_org_id
        AND     I.SR_INSTANCE_ID = p_instance_id
        AND     I.PLAN_ID = p_plan_id
        AND     R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND     D.PLAN_ID = I.PLAN_ID
        AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
        -- 1243985
        AND     USING_REQUIREMENT_QUANTITY <> 0
        AND     D.ORIGINATION_TYPE in (
                DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
                DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
                DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
        -- Bug 1530311, forecast to be excluded
        AND	C.CALENDAR_CODE = p_cal_code
        AND	C.EXCEPTION_SET_ID = p_cal_exc_set_id
        AND     C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        -- since we store repetitive schedule demand in different ways for
        -- ods (total quantity on start date) and pds  (daily quantity from
        -- start date to end date), we need to make sure we only select work day
        -- for pds's repetitive schedule demand.
        AND     C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                          D.USING_ASSEMBLY_DEMAND_DATE))
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
        AND     (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
        -- AND     C.PRIOR_SEQ_NUM >= DECODE(R.PAST_DUE_DEMAND_CUTOFF_FENCE,
        --                NULL, C.PRIOR_SEQ_NUM,
        --                p_sysdate_seq_num - NVL(R.PAST_DUE_DEMAND_CUTOFF_FENCE,0))
        AND     C.PRIOR_DATE < NVL(p_itf,
                                 C.PRIOR_DATE + 1)
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
        AND     (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                 NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                   NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
        -- AND     NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
        --         DECODE(R.DEMAND_CLASS_ATP_FLAG,
        --         1, NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')),
        --         NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')))
        UNION ALL
        -- bug 2461071 to_date and trunc
        SELECT  DECODE(D.RESERVATION_TYPE, 2, p_sys_next_date, -- to_date removed to avoid GSCC error
                TRUNC(D.REQUIREMENT_DATE)) SD_DATE, --2287148
                -1*(D.PRIMARY_UOM_QUANTITY-GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                    D.COMPLETED_QUANTITY)) SD_QTY
        FROM
                -- Bug 1756263, performance fix, use EXISTS subquery instead.
                --MSC_CALENDAR_DATES C,
                MSC_SALES_ORDERS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_CALENDAR_DATES C
        WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
        AND     I.ORGANIZATION_ID = p_org_id
        AND     I.SR_INSTANCE_ID = p_instance_id
        AND     I.PLAN_ID = p_plan_id
        AND     R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND     D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND     D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND     D.ORGANIZATION_ID = I.ORGANIZATION_ID
        AND     D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
        AND     D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
        AND     D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                D.COMPLETED_QUANTITY)
        AND     DECODE(MSC_ATP_PVT.G_APPS_VER,3,D.COMPLETED_QUANTITY,0) = 0 -- 2300767
        AND     (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                   (SELECT S.SUB_INVENTORY_CODE
                    FROM   MSC_SUB_INVENTORIES S
                    WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
                    AND    S.PLAN_ID = I.PLAN_ID
                    AND    S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                    AND    S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   2, 1, S.NETTING_TYPE)))
        AND     (D.RESERVATION_TYPE = 2
                 OR D.PARENT_DEMAND_ID IS NULL
                 OR (D.RESERVATION_TYPE = 3 AND
                     ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                      (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
                -- new clause, remove existing Exists Query 2640489
        AND     (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                    C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
        AND     C.CALENDAR_CODE = p_cal_code
        AND     C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND     C.EXCEPTION_SET_ID = -1
        AND     C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
        AND     C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
        -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
        AND         (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                     NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                       NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
        UNION ALL
        SELECT  C.NEXT_DATE SD_DATE,
                Decode(order_type,
                30, Decode(Sign(S.Daily_rate * (TRUNC(C.Calendar_date) -  TRUNC(S.FIRST_UNIT_START_DATE))- S.qty_completed),
                             -1,S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) +1)- S.qty_completed,
                              S.Daily_rate),
                5, NVL(S.DAILY_RATE, NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)),
                    (NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) - NVL(S.NON_NETTABLE_QTY, 0)) )SD_QTY
        FROM    MSC_CALENDAR_DATES C,
                MSC_SUPPLIES S,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SUB_INVENTORIES MSI
        WHERE   I.SR_INVENTORY_ITEM_ID = p_item_id
        AND     I.ORGANIZATION_ID = p_org_id
        AND     I.SR_INSTANCE_ID = p_instance_id
        AND     I.PLAN_ID = p_plan_id
        AND     R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
        AND     R.SR_INSTANCE_ID (+)= I.SR_INSTANCE_ID
        AND     S.PLAN_ID = I.PLAN_ID
        AND     S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND     S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
        AND     S.ORGANIZATION_ID = I.ORGANIZATION_ID
        --AND   NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
        ---bug 1843471, 2563139
                -- Bug 2132288, 2442009, 2453938
                -- Do not include supplies equal to 0 as per 1243985
                -- However at the same time, support negative supplies as per Bug 2362079 use ABS.
                -- Support Repetitive schedules as per 1843471
                -- Support Repetitive MPS as per 2132288, 2442009
        AND     Decode(S.order_type, 30, S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) + 1),
                                     5, NVL(S.Daily_rate, ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ),
                                     ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ) >
                      Decode(S.order_type, 30, S.qty_completed,0)
                -- End Bug 2132288, 2442009, 2453938
        AND     (S.ORDER_TYPE IN (
                DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
                DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), --1882898
                DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
                DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
                DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
                DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
                OR
                (INCLUDE_INTERNAL_REQS = 1 AND S.ORDER_TYPE = 2 AND
                 S.SOURCE_ORGANIZATION_ID IS NOT NULL)
                OR
                (INCLUDE_SUPPLIER_REQS = 1 AND S.ORDER_TYPE = 2 AND
                 S.SOURCE_ORGANIZATION_ID IS NULL)
                OR
                ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                S.ORDER_TYPE = 5
                -- bug 2461071
                AND exists (SELECT '1'
                                FROM    MSC_DESIGNATORS
                                WHERE   INVENTORY_ATP_FLAG = 1
                                AND     DESIGNATOR_TYPE = 2
                                AND     DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID
                                AND     DECODE(R.demand_class_atp_flag,1,
                                        nvl(demand_class,
                                        nvl(p_default_dmd_class,'@@@')),'@@@') =
                                        DECODE(R.demand_class_atp_flag,1,
                                        nvl(p_demand_class,
                                        nvl(p_default_dmd_class,'@@@')),'@@@')
    )))
                --AND MSC_ATP_FUNC.MPS_ATP(S.SCHEDULE_DESIGNATOR_ID) = 1))
        AND	C.CALENDAR_CODE = p_cal_code
        AND	C.EXCEPTION_SET_ID = p_cal_exc_set_id
        AND     C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
                -- Bug 2132288, 2442009
        AND     C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                    AND TRUNC(NVL(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE), NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
        AND     DECODE(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE),
                       NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                 -- End Bug 2132288, 2442009
                 -- new clause 2640489, SIMPLIFY FOR CBO
        AND     (S.ORDER_TYPE = 18
                 OR R.PAST_DUE_SUPPLY_CUTOFF_FENCE is NULL
                 OR C.NEXT_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
        AND     C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                28, TRUNC(SYSDATE),
                                                    C.NEXT_DATE)
        AND     C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
        AND     (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR S.ORDER_TYPE = 5
                 OR NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                    NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
                                         ---bug 1735580
                --- filter out non-atpable sub-inventories
        AND     MSI.plan_id (+) =  p_plan_id
        AND     MSI.organization_id (+) = p_org_id
        AND     MSI.sr_instance_id (+) =  p_instance_id
        --aND     S.subinventory_code = (+) MSI.sub_inventory_code
        AND     MSI.sub_inventory_code (+) = S.subinventory_code
        AND     NVL(MSI.inventory_atp_code,1) <> 2 -- filter out non-atpable subinventories
        -- SQL Query changes End 2640489
    )
    GROUP BY SD_DATE
    order by SD_DATE;--4698199
END get_mat_avail_ods;

PROCEDURE get_mat_avail_opt (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_opt');
        END IF;

        -- 2859130 repetitive schedule demands (4) not supported
        -- remove join to msc_calendar_dates
        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
            SELECT     -- C.PRIOR_DATE SD_DATE, -- 2859130
            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                       TRUNC(DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) SD_DATE,
                                                 --plan by requestdate,promisedate,scheduledate
                       -- -1*D.USING_REQUIREMENT_QUANTITY SD_QTY
                       -1*(D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) SD_QTY --5027568
            FROM        MSC_DEMANDS D,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         D.PLAN_ID = I.PLAN_ID
            AND         D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         D.ORGANIZATION_ID = I.ORGANIZATION_ID
            AND         D.ORIGINATION_TYPE NOT IN (4,5,7,8,9,11,15,22,28,29,31,52) -- ignore copy SO for summary enhancement
            -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
            -- Bug 1530311, forecast to be excluded
            -- new clause 2640489 SIMPLIFY
            -- AND         (C.SEQ_NUM IS NOT NULL OR D.ORIGINATION_TYPE  <> 4)
            -- AND         ((D.ORIGINATION_TYPE = 4 AND C.SEQ_NUM IS NOT NULL) OR
            --               (D.ORIGINATION_TYPE  <> 4))
            -- AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
            --bug3693892 added trunc
            AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
            AND         TRUNC(DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
            		< TRUNC(NVL(p_itf, DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
                                                 --plan by request date,promise date ,ship date
            UNION ALL
            SELECT      -- C.NEXT_DATE SD_DATE, -- 2859130
                        TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) SD_DATE,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM        MSC_SUPPLIES S,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND         S.PLAN_ID = I.PLAN_ID
            AND         S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND         S.ORGANIZATION_ID = I.ORGANIZATION_ID
                        -- Exclude Cancelled Supplies 2460645
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            -- AND         DECODE(S.LAST_UNIT_COMPLETION_DATE,
            --                   NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
            -- AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
            AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1) -- 2859130
                                                 ---bug 1735580
        )
        GROUP BY SD_DATE
        ORDER BY SD_DATE; --4698199
END get_mat_avail_opt;

PROCEDURE get_mat_avail_unopt (
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_itf                IN DATE,
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_unopt');
        END IF;

        SELECT 	SD_DATE, SUM(SD_QTY)
        BULK COLLECT INTO x_atp_dates, x_atp_qtys
        FROM (
            SELECT     -- C.PRIOR_DATE SD_DATE, -- 2859130
                       C.CALENDAR_DATE SD_DATE,
                       -1* DECODE(D.ORIGINATION_TYPE,
                                           4, D.DAILY_DEMAND_RATE,
                                           --D.USING_REQUIREMENT_QUANTITY) SD_QTY
                                           (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))) SD_QTY --5027568
            FROM        MSC_CALENDAR_DATES C,
                        MSC_DEMANDS D,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND		D.PLAN_ID = I.PLAN_ID
            AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
            -- 1243985
            AND         D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- ignore copy SO for summary enhancement
            -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
            -- Bug 1530311, forecast to be excluded
            AND		C.CALENDAR_CODE = p_cal_code
            AND		C.EXCEPTION_SET_ID = p_cal_exc_set_id
            AND         C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
            -- since we store repetitive schedule demand in different ways for
            -- ods (total quantity on start date) and pds  (daily quantity from
            -- start date to end date), we need to make sure we only select work day
            -- for pds's repetitive schedule demand.
            -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
            -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
            AND         C.CALENDAR_DATE
            		BETWEEN
            		TRUNC(DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
            		AND
                        TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                              DECODE(D.RECORD_SOURCE,
                                    2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                       DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                              2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                                 NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))
                                                 --plan by request date, promise date, schedule date
                        -- new clause 2640489 SIMPLIFY
            AND         (C.SEQ_NUM IS NOT NULL OR D.ORIGINATION_TYPE  <> 4)
            -- AND         ((D.ORIGINATION_TYPE = 4 AND C.SEQ_NUM IS NOT NULL) OR
            --               (D.ORIGINATION_TYPE  <> 4))
            -- AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
            AND         C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE + 1)
            UNION ALL
            SELECT      -- C.NEXT_DATE SD_DATE, -- 2859130
                        C.CALENDAR_DATE SD_DATE,
                        NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)  SD_QTY
            FROM        MSC_CALENDAR_DATES C,
                        MSC_SUPPLIES S,
                        MSC_SYSTEM_ITEMS I
            WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
            AND         I.ORGANIZATION_ID = p_org_id
            AND         I.SR_INSTANCE_ID = p_instance_id
            AND         I.PLAN_ID = p_plan_id
            AND		S.PLAN_ID = I.PLAN_ID
            AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
            AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
                        -- Exclude Cancelled Supplies 2460645
            AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
            AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
            AND		C.CALENDAR_CODE = p_cal_code
            AND		C.EXCEPTION_SET_ID = p_cal_exc_set_id
            AND         C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
            AND		C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                                AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
            -- 2859130 change next_seq_num to 1
            AND         DECODE(S.LAST_UNIT_COMPLETION_DATE,
                               NULL, 1, C.SEQ_NUM) IS NOT NULL
            -- AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
            AND         C.CALENDAR_DATE < NVL(p_itf, C.CALENDAR_DATE + 1) -- 2859130
                                                 ---bug 1735580
        )
        GROUP BY SD_DATE
        ORDER BY SD_DATE; --5353882
END get_mat_avail_unopt;

PROCEDURE get_mat_avail_ods_dtls (
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sysdate_seq_num    IN NUMBER,
   p_sys_next_date      IN DATE,
   p_demand_class       IN VARCHAR2,
   p_default_atp_rule_id IN NUMBER,
   p_default_dmd_class  IN VARCHAR2,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
) IS
   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_null_date  DATE; --bug3814584
   l_sysdate    DATE := sysdate;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_ods_dtls');
        END IF;

-- dsting: S/D details changes
INSERT INTO msc_atp_sd_details_temp (
	ATP_Level,
	Order_line_id,
	Scenario_Id,
	Inventory_Item_Id,
	Request_Item_Id,
	Organization_Id,
	Department_Id,
	Resource_Id,
	Supplier_Id,
	Supplier_Site_Id,
	From_Organization_Id,
	From_Location_Id,
	To_Organization_Id,
	To_Location_Id,
	Ship_Method,
	UOM_code,
	Supply_Demand_Type,
	Supply_Demand_Source_Type,
	Supply_Demand_Source_Type_Name,
	Identifier1,
	Identifier2,
	Identifier3,
	Identifier4,
	Supply_Demand_Quantity,
	Supply_Demand_Date,
	Disposition_Type,
	Disposition_Name,
	Pegging_Id,
	End_Pegging_Id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
        ORIG_CUSTOMER_SITE_NAME,--bug3263368
        ORIG_CUSTOMER_NAME, --bug3263368
        ORIG_DEMAND_CLASS, --bug3263368
        ORIG_REQUEST_DATE --bug3263368
                )

(        -- SQL Query changes Begin 2640489
    SELECT	p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
		p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		I.UOM_CODE col16,
		1 col17, -- demand
		D.ORIGINATION_TYPE col18,
                l_null_char col19,
		D.SR_INSTANCE_ID col20,
                l_null_num col21,
		D.DEMAND_ID col22,
		l_null_num col23,
                -1* D.USING_REQUIREMENT_QUANTITY col24,
		C.PRIOR_DATE col25,
                l_null_num col26,
                DECODE(D.ORIGINATION_TYPE, 1, to_char(D.DISPOSITION_ID), D.ORDER_NUMBER) col27,
                       -- rajjain 04/25/2003 Bug 2771075
                       -- For Planned Order Demands We will populate disposition_id
                       -- in disposition_name column
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                trunc(DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,  --4135752
                                           D.REQUEST_SHIP_DATE)) --bug3263368
    FROM        MSC_CALENDAR_DATES C,
		MSC_DEMANDS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND		I.SR_INSTANCE_ID = p_instance_id
    AND		I.PLAN_ID = p_plan_id
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		D.PLAN_ID = I.PLAN_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         USING_REQUIREMENT_QUANTITY <> 0
    AND	        D.ORIGINATION_TYPE in (
                DECODE(R.INCLUDE_DISCRETE_WIP_DEMAND, 1, 3, -1),
                DECODE(R.INCLUDE_FLOW_SCHEDULE_DEMAND, 1, 25, -1),
                DECODE(R.INCLUDE_USER_DEFINED_DEMAND, 1, 42, -1),
                DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 2, -1),
                DECODE(R.INCLUDE_REP_WIP_DEMAND, 1, 4, -1))
    AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    AND		C.CALENDAR_CODE=p_cal_code
    AND		C.EXCEPTION_SET_ID=p_cal_exc_set_id
    AND         C.SR_INSTANCE_ID = p_instance_id
    -- since we store repetitive schedule demand in different ways for
    -- ods (total quantity on start date) and pds  (daily quantity from
    -- start date to end date), we need to make sure we only select work day
    -- for pds's repetitive schedule demand.
    AND         C.CALENDAR_DATE BETWEEN TRUNC(D.USING_ASSEMBLY_DEMAND_DATE) AND
                TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                          D.USING_ASSEMBLY_DEMAND_DATE))
    AND         (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                 NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                   NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                I.UOM_CODE col16,
                1 col17, -- demand
                DECODE(D.RESERVATION_TYPE, 1, 30, 10)  col18,
                l_null_char col19,
                D.SR_INSTANCE_ID col20,
                l_null_num col21,
                to_number(D.DEMAND_SOURCE_LINE) col22,
                l_null_num col23,
                -1*(D.PRIMARY_UOM_QUANTITY-
                GREATEST(NVL(D.RESERVATION_QUANTITY,0), D.COMPLETED_QUANTITY))
                col24,
	DECODE(D.RESERVATION_TYPE,2,p_sys_next_date, TRUNC(D.REQUIREMENT_DATE)) col25 ,  -- to_date removed to avoid GSCC error
                l_null_num col26,
                D.SALES_ORDER_NUMBER col27,
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                trunc(DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,  --4135752
                                           D.REQUEST_SHIP_DATE)) --bug3263368
    FROM
		MSC_SALES_ORDERS D,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_CALENDAR_DATES C,
                MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_SALES_ORDERS,2,2,-1)
    AND         D.DEMAND_SOURCE_TYPE <> DECODE(R.INCLUDE_INTERNAL_ORDERS,2,8,-1)
    AND         D.PRIMARY_UOM_QUANTITY > GREATEST(NVL(D.RESERVATION_QUANTITY,0),
                D.COMPLETED_QUANTITY)
    AND         DECODE(MSC_ATP_PVT.G_APPS_VER,3,D.COMPLETED_QUANTITY,0) = 0 -- 2300767
    AND         (D.SUBINVENTORY IS NULL OR D.SUBINVENTORY IN
                   (SELECT S.SUB_INVENTORY_CODE
                    FROM   MSC_SUB_INVENTORIES S
                    WHERE  S.ORGANIZATION_ID=D.ORGANIZATION_ID
                    AND    S.PLAN_ID = I.PLAN_ID
                    AND    S.SR_INSTANCE_ID = D.SR_INSTANCE_ID
                    AND    S.INVENTORY_ATP_CODE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   1, 1, NULL, 1, S.INVENTORY_ATP_CODE)
                    AND    S.NETTING_TYPE =DECODE(R.DEFAULT_ATP_SOURCES,
                                   2, 1, S.NETTING_TYPE)))
    AND         (D.RESERVATION_TYPE = 2
                 OR D.PARENT_DEMAND_ID IS NULL
                 OR (D.RESERVATION_TYPE = 3 AND
                     ((R.INCLUDE_DISCRETE_WIP_RECEIPTS = 1) or
                      (R.INCLUDE_NONSTD_WIP_RECEIPTS = 1))))
                -- new clause, remove existing Exists Query 2640489
    AND         D.SHIP_TO_SITE_USE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    AND      (R.PAST_DUE_DEMAND_CUTOFF_FENCE is NULL OR
                 C.PRIOR_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_DEMAND_CUTOFF_FENCE)
    AND      C.CALENDAR_CODE = p_cal_code
    AND      C.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND      C.EXCEPTION_SET_ID = -1
    AND      C.CALENDAR_DATE = TRUNC(D.REQUIREMENT_DATE)
    AND      C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
                -- new clause 2640489, DECODE is also OR, Explicit OR gives CBO choices
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1 OR
                 NVL(D.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                   NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                I.UOM_CODE col16,
                2 col17, -- supply
                S.ORDER_TYPE col18,
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
                Decode(order_type,
                30, Decode(Sign(S.Daily_rate * (TRUNC(C.Calendar_date) -  TRUNC(S.FIRST_UNIT_START_DATE) )- S.qty_completed),
                             -1,S.Daily_rate* (TRUNC(C.Calendar_date) - TRUNC(S.First_Unit_Start_date) +1)- S.qty_completed,
                              S.Daily_rate),
                5, NVL(S.DAILY_RATE, NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)),

                    (NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) - NVL(S.NON_NETTABLE_QTY, 0)) ) col24,
                C.NEXT_DATE col25,
                l_null_num col26,
                DECODE(S.ORDER_TYPE,
                       1, S.ORDER_NUMBER,
		       2, S.ORDER_NUMBER,
		       3, S.ORDER_NUMBER,
                       7, S.ORDER_NUMBER,
                       8, S.ORDER_NUMBER,
                       5, MSC_ATP_FUNC.Get_Designator(S.SCHEDULE_DESIGNATOR_ID),
                      11, S.ORDER_NUMBER,
                      12, S.ORDER_NUMBER,
                      14, S.ORDER_NUMBER,
                      15, S.ORDER_NUMBER,
                      27, S.ORDER_NUMBER,
                      28, S.ORDER_NUMBER,
                      41, S.ORDER_NUMBER, -- bug 3745082 'User Defined Supply'
                      -- NULL) col27,
                      l_null_char) col27, --bug3814584
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		--null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
                --null, --bug3263368 ORIG_CUSTOMER_NAME
                --null, --bug3263368 ORIG_DEMAND_CLASS
                --null  --bug3263368 ORIG_REQUEST_DATE
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM        MSC_CALENDAR_DATES C,
		MSC_SUPPLIES S,
                MSC_ATP_RULES R,
                MSC_SYSTEM_ITEMS I,
                MSC_SUB_INVENTORIES MSI
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND         R.RULE_ID (+) = NVL(I.ATP_RULE_ID, p_default_atp_rule_id)
    AND         R.SR_INSTANCE_ID (+) = I.SR_INSTANCE_ID
    AND		S.PLAN_ID = I.PLAN_ID
    AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         Decode(S.order_type, 30, S.Daily_rate* (TRUNC(C.Calendar_date)
					- TRUNC(S.First_Unit_Start_date) + 1),
                                     5, NVL(S.Daily_rate, ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ),
                        ABS(NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY)) ) >
                      Decode(S.order_type, 30, S.qty_completed,0)
    AND		(S.ORDER_TYPE IN (
		DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 1, -1),
		DECODE(R.INCLUDE_PURCHASE_ORDERS, 1, 8, -1), -- 1882898
		DECODE(R.INCLUDE_DISCRETE_WIP_RECEIPTS, 1, 3, -1),
		DECODE(R.INCLUDE_REP_WIP_RECEIPTS, 1, 30, -1),
		DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 7, -1),
		DECODE(R.INCLUDE_NONSTD_WIP_RECEIPTS, 1, 15, -1),
		DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 11, -1),
                DECODE(R.INCLUDE_INTERORG_TRANSFERS, 1, 12, -1),
		DECODE(R.INCLUDE_ONHAND_AVAILABLE, 1, 18, -1),
                DECODE(R.INCLUDE_USER_DEFINED_SUPPLY, 1, 41, -1),
		DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 27, -1),
		DECODE(R.INCLUDE_FLOW_SCHEDULE_RECEIPTS, 1, 28, -1))
                OR
                (INCLUDE_INTERNAL_REQS = 1 AND S.ORDER_TYPE = 2 AND
                 S.SOURCE_ORGANIZATION_ID IS NOT NULL)
                OR
                (INCLUDE_SUPPLIER_REQS = 1 AND S.ORDER_TYPE = 2 AND
                 S.SOURCE_ORGANIZATION_ID IS NULL)
                OR
                ((R.INCLUDE_REP_MPS = 1 OR R.INCLUDE_DISCRETE_MPS = 1) AND
                S.ORDER_TYPE = 5
                 -- bug 2461071
                AND exists (SELECT '1'
                            FROM    MSC_DESIGNATORS
                            WHERE   INVENTORY_ATP_FLAG = 1
                            AND     DESIGNATOR_TYPE = 2
                            AND     DESIGNATOR_ID = S.SCHEDULE_DESIGNATOR_ID
                            AND     DECODE(R.demand_class_atp_flag,1,
                                    nvl(demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@') =
                                    DECODE(R.demand_class_atp_flag,1,
                                    nvl(p_demand_class,
                                    nvl(p_default_dmd_class,'@@@')),'@@@')
)))
                --AND MSC_ATP_FUNC.MPS_ATP(S.SCHEDULE_DESIGNATOR_ID) = 1
    AND		C.CALENDAR_CODE = p_cal_code
    AND		C.EXCEPTION_SET_ID = p_cal_exc_set_id
    AND         C.SR_INSTANCE_ID = p_instance_id
                 -- Bug 2132288, 2442009
    AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
                    AND TRUNC(NVL(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE), NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
    AND         DECODE(DECODE(S.ORDER_TYPE, 5, S.LAST_UNIT_START_DATE,
                                   S.LAST_UNIT_COMPLETION_DATE),
                       NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
                 -- End Bug 2132288, 2442009
                 -- new clause 2640489, SIMPLIFY FOR CBO
    AND         (S.ORDER_TYPE = 18
                 OR R.PAST_DUE_SUPPLY_CUTOFF_FENCE is NULL
                 OR C.NEXT_SEQ_NUM >= p_sysdate_seq_num - R.PAST_DUE_SUPPLY_CUTOFF_FENCE)
    AND         C.NEXT_DATE >= DECODE(S.ORDER_TYPE, 27, TRUNC(SYSDATE),
                                                28, TRUNC(SYSDATE),
                                                    C.NEXT_DATE)
    AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)
    AND         (R.DEMAND_CLASS_ATP_FLAG <> 1
                 OR S.ORDER_TYPE = 5
                 OR NVL(S.DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) =
                    NVL(P_DEMAND_CLASS, NVL(p_default_dmd_class,'@@@')) )
                --- filter out non-atpable sub-inventories
    AND          MSI.plan_id (+) = p_plan_id
    AND          MSI.organization_id (+) = p_org_id
    AND          MSI.sr_instance_id (+) = p_instance_id
    -- AND          S.subinventory_code = MSI.sub_inventory_code
    AND          MSI.sub_inventory_code (+) = S.subinventory_code
    AND          NVL(MSI.inventory_atp_code,1)  <> 2  -- filter out non-atpable subinventories
    -- SQL Query changes End 2640489
)
;
-- dsting 'removed order by col25'
END get_mat_avail_ods_dtls;


PROCEDURE get_mat_avail_opt_dtls (
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
) IS
   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_null_date  DATE; --bug3814584
   l_sysdate    DATE := sysdate;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_opt_dtls');
        END IF;

INSERT INTO msc_atp_sd_details_temp (
	ATP_Level,
	Order_line_id,
	Scenario_Id,
	Inventory_Item_Id,
	Request_Item_Id,
	Organization_Id,
	Department_Id,
	Resource_Id,
	Supplier_Id,
	Supplier_Site_Id,
	From_Organization_Id,
	From_Location_Id,
	To_Organization_Id,
	To_Location_Id,
	Ship_Method,
	UOM_code,
	Supply_Demand_Type,
	Supply_Demand_Source_Type,
	Supply_Demand_Source_Type_Name,
	Identifier1,
	Identifier2,
	Identifier3,
	Identifier4,
	Supply_Demand_Quantity,
	Supply_Demand_Date,
	Disposition_Type,
	Disposition_Name,
	Pegging_Id,
	End_Pegging_Id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	ORIG_CUSTOMER_SITE_NAME,--bug3263368
        ORIG_CUSTOMER_NAME, --bug3263368
        ORIG_DEMAND_CLASS, --bug3263368
        ORIG_REQUEST_DATE --bug3263368
     )
(
    SELECT      p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
		p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		I.UOM_CODE col16,
		1 col17, -- demand
		--D.ORIGINATION_TYPE col18,
		DECODE( D.ORIGINATION_TYPE, -100, 30, D.ORIGINATION_TYPE) col18, --5027568
                l_null_char col19,
		D.SR_INSTANCE_ID col20,
                l_null_num col21,
		D.DEMAND_ID col22,
		l_null_num col23,
                -- -1* D.USING_REQUIREMENT_QUANTITY col24,
                -1*(D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0)) col24, --5027568
		-- C.PRIOR_DATE col25, -- 2859130
		-- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                TRUNC(DECODE(D.RECORD_SOURCE,
                             2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                                DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                       2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                          NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))) col25,
                                          --plan by request date,promise date, schedule date
                l_null_num col26,
                D.ORDER_NUMBER col27,
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                           D.REQUEST_SHIP_DATE) --bug3263368
    FROM        MSC_SYSTEM_ITEMS I,
		MSC_DEMANDS D,
		MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND		I.SR_INSTANCE_ID = p_instance_id
    AND		I.PLAN_ID = p_plan_id
    AND		D.PLAN_ID = I.PLAN_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    -- 1243985
    -- 2859130 repetitive schedule (4) not supported for constrained plan
    AND	        D.ORIGINATION_TYPE NOT IN (4,5,7,8,9,11,15,22,28,29,31,52) -- ignore copy SO for summary enhancement
    -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
    -- Bug 1530311, need to exclude forecast
    -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
    -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
    --bug3693892 added trunc
    AND         TRUNC(DECODE(D.RECORD_SOURCE,
                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                               DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                      2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
    		< TRUNC(NVL(p_itf,
    			DECODE(D.RECORD_SOURCE,
                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                               DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                      2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))) + 1))
                                         --plan by request date, promise date, schedule date
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                I.UOM_CODE col16,
                2 col17, -- supply
                S.ORDER_TYPE col18,
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
		NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) col24,
                -- C.NEXT_DATE col25, -- 2859130
                TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) col25,
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		--null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
                --null, --bug3263368 ORIG_CUSTOMER_NAME
                --null, --bug3263368 ORIG_DEMAND_CLASS
                --null  --bug3263368 ORIG_REQUEST_DATE
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM        MSC_SYSTEM_ITEMS I,
		MSC_SUPPLIES S
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND		S.PLAN_ID = I.PLAN_ID
    AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
                -- Exclude Cancelled Supplies 2460645
    AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
    AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
    AND         TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) < NVL(p_itf, TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)) + 1)
)
;
END get_mat_avail_opt_dtls;

PROCEDURE get_mat_avail_unopt_dtls (
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
) IS
   l_null_num   NUMBER;
   l_null_char  VARCHAR2(1);
   l_null_date  DATE; --bug3814584
   l_sysdate    DATE := sysdate;
BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Begin get_mat_avail_unopt_dtls');
        END IF;

INSERT INTO msc_atp_sd_details_temp (
	ATP_Level,
	Order_line_id,
	Scenario_Id,
	Inventory_Item_Id,
	Request_Item_Id,
	Organization_Id,
	Department_Id,
	Resource_Id,
	Supplier_Id,
	Supplier_Site_Id,
	From_Organization_Id,
	From_Location_Id,
	To_Organization_Id,
	To_Location_Id,
	Ship_Method,
	UOM_code,
	Supply_Demand_Type,
	Supply_Demand_Source_Type,
	Supply_Demand_Source_Type_Name,
	Identifier1,
	Identifier2,
	Identifier3,
	Identifier4,
	Supply_Demand_Quantity,
	Supply_Demand_Date,
	Disposition_Type,
	Disposition_Name,
	Pegging_Id,
	End_Pegging_Id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	ORIG_CUSTOMER_SITE_NAME,--bug3263368
        ORIG_CUSTOMER_NAME, --bug3263368
        ORIG_DEMAND_CLASS, --bug3263368
        ORIG_REQUEST_DATE --bug3263368
)
(
    SELECT      p_level col1,
		p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
		p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
		l_null_char col15,
		I.UOM_CODE col16,
		1 col17, -- demand
		--D.ORIGINATION_TYPE col18,
		DECODE( D.ORIGINATION_TYPE, -100, 30, D.ORIGINATION_TYPE) col18, --5027568
                l_null_char col19,
		D.SR_INSTANCE_ID col20,
                l_null_num col21,
		D.DEMAND_ID col22,
		l_null_num col23,
                -1* DECODE(D.ORIGINATION_TYPE,
                                    4, D.DAILY_DEMAND_RATE,
                                    --D.USING_REQUIREMENT_QUANTITY) col24,
                                    (D.USING_REQUIREMENT_QUANTITY - NVL(d.reserved_quantity, 0))) col24, --5027568
		-- C.PRIOR_DATE col25, -- 2859130
                C.CALENDAR_DATE col25,
                l_null_num col26,
                D.ORDER_NUMBER col27,
                l_null_num col28,
                l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		MTPS.LOCATION, --bug3263368
                MTP.PARTNER_NAME, --bug3263368
                D.DEMAND_CLASS, --bug3263368
                DECODE(D.ORDER_DATE_TYPE_CODE,2,D.REQUEST_DATE,
                                            D.REQUEST_SHIP_DATE) --bug3263368
    FROM        MSC_SYSTEM_ITEMS I,
		MSC_DEMANDS D,
                MSC_CALENDAR_DATES C,
                MSC_TRADING_PARTNERS    MTP,--bug3263368
                MSC_TRADING_PARTNER_SITES    MTPS --bug3263368
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND		I.SR_INSTANCE_ID = p_instance_id
    AND		I.PLAN_ID = p_plan_id
    AND		D.PLAN_ID = I.PLAN_ID
    AND		D.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		D.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	D.ORGANIZATION_ID = I.ORGANIZATION_ID
    AND         D.USING_REQUIREMENT_QUANTITY <> 0 --4501434
    AND         D.SHIP_TO_SITE_ID = MTPS.PARTNER_SITE_ID(+) --bug3263368
    AND         D.CUSTOMER_ID = MTP.PARTNER_ID(+) --bug3263368
    -- 1243985
    AND	        D.ORIGINATION_TYPE NOT IN (5,7,8,9,11,15,22,28,29,31,52) -- ignore copy SO for summary enhancement
    -- Bug1990155, 1995835 exclude the expired lots demand datreya 9/18/2001
    -- Bug 1530311, need to exclude forecast
    AND		C.CALENDAR_CODE=p_cal_code
    AND	        C.EXCEPTION_SET_ID=p_cal_exc_set_id
    AND         C.SR_INSTANCE_ID = D.SR_INSTANCE_ID
    -- since we store repetitive schedule demand in different ways for
    -- ods (total quantity on start date) and pds  (daily quantity from
    -- start date to end date), we need to make sure we only select work day
    -- for pds's repetitive schedule demand.
    -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
    -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
    AND         C.CALENDAR_DATE
                BETWEEN
                TRUNC(DECODE(D.RECORD_SOURCE,
                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                               DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                      2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))))
                AND
                TRUNC(NVL(D.ASSEMBLY_DEMAND_COMP_DATE,
                      DECODE(D.RECORD_SOURCE,
                            2, NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                               DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                                      2, NVL(D.IMPLEMENT_SHIP_DATE,NVL(D.FIRM_DATE,NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE))),
                                         NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)))))--plan by request date,promisedate, schedule date
                -- new clause 2640489 SIMPLIFY
    AND         (C.SEQ_NUM IS NOT NULL OR D.ORIGINATION_TYPE  <> 4)
    -- AND         ((D.ORIGINATION_TYPE = 4 AND C.SEQ_NUM IS NOT NULL) OR
    --               (D.ORIGINATION_TYPE  <> 4))
    AND         C.PRIOR_DATE < NVL(p_itf, C.PRIOR_DATE + 1)
    UNION ALL
    SELECT      p_level col1,
                p_identifier col2,
                p_scenario_id col3,
                p_item_id col4 ,
                p_request_item_id col5,
                p_org_id col6,
                l_null_num col7,
                l_null_num col8,
                l_null_num col9,
                l_null_num col10,
                l_null_num col11,
                l_null_num col12,
                l_null_num col13,
                l_null_num col14,
                l_null_char col15,
                I.UOM_CODE col16,
                2 col17, -- supply
                S.ORDER_TYPE col18,
                l_null_char col19,
                S.SR_INSTANCE_ID col20,
                l_null_num col21,
                S.TRANSACTION_ID col22,
                l_null_num col23,
		NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) col24,
                -- C.NEXT_DATE col25, -- 2859130
                C.CALENDAR_DATE col25,
                l_null_num col26,
                -- Bug 2771075. For Planned Orders, we will populate transaction_id
		-- in the disposition_name column to be consistent with Planning.
		-- S.ORDER_NUMBER col27,
		DECODE(S.ORDER_TYPE, 5, to_char(S.TRANSACTION_ID), S.ORDER_NUMBER) col27,
                l_null_num col28,
		l_null_num col29,
		l_sysdate,
		FND_GLOBAL.User_ID,
		l_sysdate,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.User_ID,
		--null, --bug3263368 ORIG_CUSTOMER_SITE_NAME
                --null, --bug3263368 ORIG_CUSTOMER_NAME
                --null, --bug3263368 ORIG_DEMAND_CLASS
                --null  --bug3263368 ORIG_REQUEST_DATE
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_char, --bug3814584
                l_null_date  --bug3814584
    FROM        MSC_SYSTEM_ITEMS I,
		MSC_SUPPLIES S,
                MSC_CALENDAR_DATES C
    WHERE       I.SR_INVENTORY_ITEM_ID = p_item_id
    AND         I.ORGANIZATION_ID = p_org_id
    AND         I.SR_INSTANCE_ID = p_instance_id
    AND         I.PLAN_ID = p_plan_id
    AND		S.PLAN_ID = I.PLAN_ID
    AND		S.SR_INSTANCE_ID = I.SR_INSTANCE_ID
    AND		S.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
    AND 	S.ORGANIZATION_ID = I.ORGANIZATION_ID
                -- Exclude Cancelled Supplies 2460645
    AND         NVL(S.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
    AND         NVL(S.FIRM_QUANTITY,S.NEW_ORDER_QUANTITY) <> 0 -- 1243985
    AND		C.CALENDAR_CODE = p_cal_code
    AND		C.EXCEPTION_SET_ID = p_cal_exc_set_id
    AND         C.SR_INSTANCE_ID = S.SR_INSTANCE_ID
    AND         C.CALENDAR_DATE BETWEEN TRUNC(NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE))
    AND TRUNC(NVL(S.LAST_UNIT_COMPLETION_DATE, NVL(S.FIRM_DATE,S.NEW_SCHEDULE_DATE)))
    AND         DECODE(S.LAST_UNIT_COMPLETION_DATE,
                       NULL, C.NEXT_SEQ_NUM, C.SEQ_NUM) IS NOT NULL
    AND         C.NEXT_DATE < NVL(p_itf, C.NEXT_DATE + 1)

)
;
-- dsting 'removed order by col25'
END get_mat_avail_unopt_dtls;

PROCEDURE get_mat_avail (
   p_summary_flag       IN VARCHAR2,
   p_optimized_plan     IN NUMBER,
   p_item_id            IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sysdate_seq_num    IN NUMBER,
   p_sys_next_date      IN DATE,
   p_demand_class       IN VARCHAR2,
   p_default_atp_rule_id IN NUMBER,
   p_default_dmd_class  IN VARCHAR2,
   p_itf                IN DATE,
   p_refresh_number     IN NUMBER,  -- For summary enhancement
   x_atp_dates          OUT NoCopy MRP_ATP_PUB.date_arr,
   x_atp_qtys           OUT NoCopy MRP_ATP_PUB.number_arr
) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Begin get_mat_avail');
   END IF;

   IF MSC_ATP_PVT.G_INV_CTP = 5 THEN
      -- ODS atp
      IF p_summary_flag = 'Y' THEN
         -- summary ODS atp
         get_mat_avail_ods_summ(
            p_item_id,
            p_org_id,
            p_instance_id,
            p_plan_id,
            p_demand_class,
            p_default_atp_rule_id,
            p_default_dmd_class,
            p_itf,
            x_atp_dates,
            x_atp_qtys
         );
      ELSE
         -- ODS atp
         get_mat_avail_ods(
            p_item_id,
            p_org_id,
            p_instance_id,
            p_plan_id,
            p_cal_code,
            p_cal_exc_set_id,
            p_sysdate_seq_num,
            p_sys_next_date,
            p_demand_class,
            p_default_atp_rule_id,
            p_default_dmd_class,
            p_itf,
            x_atp_dates,
            x_atp_qtys
         );
      END IF;
   ELSE
      -- PDS atp
      IF p_summary_flag = 'Y' THEN
         -- ATP4drp Changes to support ATP for DRP plans.
         IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
             -- DRP plan call DRP plan specific summary
             MSC_ATP_DRP.get_mat_avail_drp_summ(
                p_item_id,
                p_org_id,
                p_instance_id,
                p_plan_id,
                p_itf,
                p_refresh_number,   -- For summary enhancement
                x_atp_dates,
                x_atp_qtys
             );
         ELSE -- Call regular summary
             get_mat_avail_summ(
                p_item_id,
                p_org_id,
                p_instance_id,
                p_plan_id,
                p_itf,
                p_refresh_number,   -- For summary enhancement
                x_atp_dates,
                x_atp_qtys
             );
         END IF;
         -- End ATP4drp
      ELSE
         IF nvl(p_optimized_plan, 2) = 1 THEN
            -- constrained plan
            -- ATP4drp Changes to support ATP for DRP plans.
            IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
              MSC_ATP_DRP.get_mat_avail_drp(
                 p_item_id,
                 p_org_id,
                 p_instance_id,
                 p_plan_id,
                 p_itf,
                 x_atp_dates,
                 x_atp_qtys
              );
            ELSE
              get_mat_avail_opt(
                 p_item_id,
                 p_org_id,
                 p_instance_id,
                 p_plan_id,
                 p_itf,
                 x_atp_dates,
                 x_atp_qtys
              );
            END IF;
            -- End ATP4drp
         ELSE
            -- unconstrained plan
            get_mat_avail_unopt(
               p_item_id,
               p_org_id,
               p_instance_id,
               p_plan_id,
               p_cal_code,
               p_cal_exc_set_id,
               p_itf,
               x_atp_dates,
               x_atp_qtys
            );
         END IF; -- (un)optimized plan
      END IF; -- summary atp
   END IF; -- ODS/PDS
END get_mat_avail;

PROCEDURE get_mat_avail_dtls (
   p_optimized_plan     IN NUMBER,
   p_item_id            IN NUMBER,
   p_request_item_id    IN NUMBER,
   p_org_id             IN NUMBER,
   p_instance_id        IN NUMBER,
   p_plan_id            IN NUMBER,
   p_cal_code           IN VARCHAR2,
   p_cal_exc_set_id     IN NUMBER,
   p_sysdate_seq_num    IN NUMBER,
   p_sys_next_date      IN DATE,
   p_demand_class       IN VARCHAR2,
   p_default_atp_rule_id IN NUMBER,
   p_default_dmd_class  IN VARCHAR2,
   p_itf                IN DATE,
   p_level              IN NUMBER,
   p_scenario_id        IN NUMBER,
   p_identifier         IN NUMBER
) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Begin get_mat_avail_dtls');
   END IF;

   IF MSC_ATP_PVT.G_INV_CTP = 5 THEN
      -- ODS atp
      get_mat_avail_ods_dtls(
         p_item_id,
         p_request_item_id,
         p_org_id,
         p_instance_id,
         p_plan_id,
         p_cal_code,
         p_cal_exc_set_id,
         p_sysdate_seq_num,
         p_sys_next_date,
         p_demand_class,
         p_default_atp_rule_id,
         p_default_dmd_class,
         p_itf,
         p_level,
         p_scenario_id,
         p_identifier
      );
   ELSE
      -- PDS atp
      IF nvl(p_optimized_plan, 2) = 1 THEN
         -- constrained plan
         -- ATP4drp Changes to support ATP for DRP plans.
         IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
              MSC_ATP_DRP.get_mat_avail_drp_dtls(
                 p_item_id,
                 p_request_item_id,
                 p_org_id,
                 p_instance_id,
                 p_plan_id,
                 p_itf,
                 p_level,
                 p_scenario_id,
                 p_identifier
              );
         ELSE
              get_mat_avail_opt_dtls(
                 p_item_id,
                 p_request_item_id,
                 p_org_id,
                 p_instance_id,
                 p_plan_id,
                 p_itf,
                 p_level,
                 p_scenario_id,
                 p_identifier
              );
         END IF;
         -- End ATP4drp
      ELSE
         -- unconstrained plan
         get_mat_avail_unopt_dtls(
            p_item_id,
            p_request_item_id,
            p_org_id,
            p_instance_id,
            p_plan_id,
            p_cal_code,
            p_cal_exc_set_id,
            p_itf,
            p_level,
            p_scenario_id,
            p_identifier
         );
      END IF; -- (un)optimized plan
   END IF; -- ODS/PDS
END get_mat_avail_dtls;
-- 2859130 end sqls

/*--Calculate_Atp_Dates_Qtys------------------------------------------------
|  o  New private procedure added as part of time_phased_atp project
|  o  Moved ATP dates and qty calculation code from Get_Material_Atp_Info
|     procedure to this procedure
+-------------------------------------------------------------------------*/
PROCEDURE Calculate_Atp_Dates_Qtys (
        p_atp_period_tab                      IN    MRP_ATP_PUB.Date_arr,
        p_atp_qty_tab                         IN    MRP_ATP_PUB.Number_arr,
        p_requested_date                      IN    DATE,
        p_atf_date                            IN    DATE,
        p_quantity_ordered                    IN    NUMBER,
        p_sys_next_date                       IN    DATE,
        p_round_flag                          IN    NUMBER,
        x_requested_date_quantity             OUT   NOCOPY NUMBER,
        x_atf_date_quantity                   OUT   NOCOPY NUMBER,
        x_atp_date_this_level                 OUT   NOCOPY DATE,
        x_atp_date_quantity_this_level        OUT   NOCOPY NUMBER,
        x_return_status                       OUT   NOCOPY VARCHAR2
)
IS
        l_atp_requested_date            DATE;
        l_next_period			DATE;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('********** Calculate_Atp_Dates_Qtys **********');
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_requested_date: '|| to_char(p_requested_date));
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_quantity_ordered: '|| to_char(p_quantity_ordered));
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_sys_next_date: '|| to_char(p_sys_next_date));
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_round_flag: '|| to_char(p_round_flag));
        END IF;

        -- initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- if requested date is eariler than sysdate, we have an issue here.
        -- this is possible since we have the offset from requested arrival
        -- date.  if requested date is eariler than sysdate, we should set
        -- the x_requested_date_quantity = 0, and find the atp date and
        -- quantity from sysdate.

        -- we use this l_atp_requested_date to do the search
        l_atp_requested_date := GREATEST(p_requested_date, trunc(p_sys_next_date));

        IF (l_atp_requested_date < p_atp_period_tab(1)) THEN

            -- let say the first period is on Day5 but your
            -- request in on Day2.  for bug 948863
            x_requested_date_quantity := 0;
            FOR k IN 1..p_atp_period_tab.COUNT LOOP
                IF K = p_atp_period_tab.COUNT THEN
                    -- RAJJAIN Bug 2558593, in case component is available only on infinite time fence
                    -- which is prior to PTF date, return PTF date as the avaialble date
                    IF p_atp_qty_tab(k) >= p_quantity_ordered THEN
                       IF (p_round_flag = 1) THEN
                          x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(k));
                       ELSE
                          x_atp_date_quantity_this_level := p_atp_qty_tab(k);
                       END IF;
                       x_atp_date_this_level := GREATEST(p_atp_period_tab(k), MSC_ATP_PVT.G_PTF_DATE);
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || x_atp_date_quantity_this_level);
                          msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || x_atp_date_this_level);
                       END IF;

                    END IF;
                    EXIT;
                ELSIF (p_atp_qty_tab(k) >= p_quantity_ordered) AND
                      ((p_atp_period_tab(k) <= MSC_ATP_PVT.G_PTF_DATE AND
                      p_atp_period_tab(k+1)> MSC_ATP_PVT.G_PTF_DATE)
                          OR (p_atp_period_tab(k) > MSC_ATP_PVT.G_PTF_DATE))  THEN
                    IF (p_round_flag = 1) THEN
                       x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(k));
                    ELSE
                       x_atp_date_quantity_this_level := p_atp_qty_tab(k);
                    END IF;
                    x_atp_date_this_level := GREATEST(p_atp_period_tab(k), MSC_ATP_PVT.G_PTF_DATE);
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || x_atp_date_quantity_this_level);
                       msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || x_atp_date_this_level);
                    END IF;
                    EXIT;
                END IF;
            END LOOP; -- end of k loop

        ELSE
                -- find the requested date atp quantity

                -- if requested date is eariler than sysdate, we have an issue here.
                -- this is possible since we have the offset from requested arrival
                -- date.  if requested date is eariler than sysdate, we should set
                -- the x_requested_date_quantity = 0, and find the atp date and
                -- quantity from sysdate.
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'I am here 1');
                END IF;
                FOR j IN 1..p_atp_period_tab.COUNT LOOP

                    -- time_phased_atp changes begin
                    IF (x_atf_date_quantity is null) and (p_atf_date is not null) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('*********************');
                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_period_tab(j): ' || p_atp_period_tab(j));
                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atf_date: ' || p_atf_date);
                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_qty_tab(j): ' || p_atp_qty_tab(j));
                        END IF;
                        IF p_atp_period_tab(j) = p_atf_date THEN
                            x_atf_date_quantity := p_atp_qty_tab(j);
                        ELSIF p_atp_period_tab(j) > p_atf_date THEN
                            IF j = 1 THEN
                                x_atf_date_quantity := 0;
                            ELSE
                                IF PG_DEBUG in ('Y', 'C') THEN
                                    msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_qty_tab(j-1): ' || p_atp_qty_tab(j-1));
                                END IF;
                                x_atf_date_quantity := p_atp_qty_tab(j-1);
                            END IF;
                        END IF;

                        IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: x_atf_date_quantity: ' || x_atf_date_quantity);
                        END IF;
                    END IF;
                    -- time_phased_atp changes end

                    -- Please state reason for the else condition here
                    -- the reason that we need this else condition is the following
                    -- let say the last record in the bucket is Day5, and request
                    -- date is Day10.  So the bucket that the the request date is
                    -- falling into is Day5. So we should use Day5's quantity
                    -- as the quantity for Day10. By setting l_next_period this way,
                    -- we make sure we are using the right bucket to get
                    -- request date quantuty.

                    IF j < p_atp_period_tab.LAST THEN
                        l_next_period := p_atp_period_tab(j+1);
                    ELSE
                        l_next_period := l_atp_requested_date + 1;
                    END IF;
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'I am here 2');
                    END IF;

                    --- bug 1819638:  If sysdate is non-work day then we want to check the request on
                    --- next working day (p_sys_next_date)

                    IF ((p_atp_period_tab(j) <= GREATEST(l_atp_requested_date, p_sys_next_date)) and
                           (l_next_period > GREATEST(l_atp_requested_date, p_sys_next_date))) THEN


                        --IF p_requested_date < l_atp_requested_date THEN
        		IF PG_DEBUG in ('Y', 'C') THEN
        		   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'I am here 3');
        		END IF;
                        -- Bug 3512996 - For request before PTF return 0 as request date quantity
                        -- IF (p_requested_date < l_atp_requested_date) THEN
                        -- IF (p_requested_date < GREATEST(l_atp_requested_date,MSC_ATP_PVT.G_PTF_DATE)) THEN
                        IF (p_requested_date < l_atp_requested_date) THEN -- Bug 3828469 - Undo the regression introduced by Bug 3512996
                              IF PG_DEBUG in ('Y', 'C') THEN
                                 msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_requested_date < l_atp_requested_date');
                              END IF;
                              x_requested_date_quantity := 0;
                        ELSE
                              IF (p_round_flag = 1) THEN --- bug 1774959
                                   x_requested_date_quantity := FLOOR(p_atp_qty_tab(j));
                              ELSE
                                   x_requested_date_quantity := p_atp_qty_tab(j);
                              END IF;
                              IF PG_DEBUG in ('Y', 'C') THEN
                                 msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_requested_date > l_atp_requested_date');
                              END IF;
                        END IF;
                	IF PG_DEBUG in ('Y', 'C') THEN
                	   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'x_requested_date_quantity: '|| to_char(x_requested_date_quantity));
                	   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'test line p_atp_qty_tab(j): '|| to_char(p_atp_qty_tab(j)));
                	   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'p_quantity_ordered: '|| to_char(p_quantity_ordered));
                	END IF;

                        --  now find the atp_date_quantity and atp_date at this level
                        IF p_atp_qty_tab(j) >= p_quantity_ordered AND
                          (p_atp_period_tab(j) >= NVL(MSC_ATP_PVT.G_PTF_DATE,p_sys_next_date)) THEN
                            IF(p_round_flag = 1) THEN --- bug 1774959
                                x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(j));
                            ELSE
                                x_atp_date_quantity_this_level := p_atp_qty_tab(j);
                            END IF;
                            -- bug 1560255
                            --x_atp_date_quantity_this_level := p_quantity_ordered;
                            IF PG_DEBUG in ('Y', 'C') THEN
                               msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'Checkpoint 1');
                            END IF;
                            x_atp_date_this_level := GREATEST(l_atp_requested_date, p_sys_next_date);

                            IF PG_DEBUG in ('Y', 'C') THEN
                               msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'x_atp_date_this_level: '|| to_char(x_atp_date_this_level));
                               msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'x_atp_date_quantity_this_level: '|| to_char(x_atp_date_quantity_this_level));
                            END IF;


                        ELSE
                            IF j = p_atp_period_tab.COUNT THEN
                                IF p_atp_qty_tab(j) >= p_quantity_ordered THEN
                                   IF(p_round_flag = 1) THEN --- bug 1774959
                                      x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(j));
                                   ELSE
                                      x_atp_date_quantity_this_level := p_atp_qty_tab(j);
                                   END IF;

                                   x_atp_date_this_level := GREATEST(p_atp_period_tab(j),
                                                        GREATEST(MSC_ATP_PVT.G_PTF_DATE,p_sys_next_date));
                                ELSE
                                   x_atp_date_quantity_this_level := NULL;
                                   x_atp_date_this_level := NULL;
                                END IF;

                            ELSIF (p_atp_qty_tab(j) >= p_quantity_ordered AND
                                           p_atp_period_tab(j+1) > NVL(MSC_ATP_PVT.G_PTF_DATE,p_sys_next_date)) THEN
                                IF(p_round_flag = 1) THEN --- bug 1774959
                                   x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(j));
                                ELSE
                                   x_atp_date_quantity_this_level := p_atp_qty_tab(j);
                                END IF;
                                -- bug 1560255
                                --x_atp_date_quantity_this_level := p_quantity_ordered;
                                IF PG_DEBUG in ('Y', 'C') THEN
                                   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'Checkpoint 3');
                                END IF;
                                x_atp_date_this_level := GREATEST(NVL(MSC_ATP_PVT.G_PTF_DATE,p_sys_next_date)
                                                                  , p_atp_period_tab(j));
                            ELSE
                                IF PG_DEBUG in ('Y', 'C') THEN
                                   msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'Checkpoint 2');
                                END IF;
                                FOR k IN j+1..p_atp_period_tab.COUNT LOOP

                                    -- time_phased_atp changes begin
                                    IF (x_atf_date_quantity is null) and (p_atf_date is not null) THEN
                                        IF PG_DEBUG in ('Y', 'C') THEN
                                            msc_sch_wb.atp_debug('*********************');
                                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_period_tab(k): ' || p_atp_period_tab(k));
                                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atf_date: ' || p_atf_date);
                                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_qty_tab(k): ' || p_atp_qty_tab(k));
                                        END IF;
                                        IF p_atp_period_tab(k) = p_atf_date THEN
                                            x_atf_date_quantity := p_atp_qty_tab(k);
                                        ELSIF p_atp_period_tab(k) > p_atf_date THEN
                                            IF k = 1 THEN
                                                x_atf_date_quantity := 0;
                                            ELSE
                                                IF PG_DEBUG in ('Y', 'C') THEN
                                                    msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: p_atp_qty_tab(k-1): ' || p_atp_qty_tab(k-1));
                                                END IF;
                                                x_atf_date_quantity := p_atp_qty_tab(k-1);
                                            END IF;
                                        END IF;

                                        IF PG_DEBUG in ('Y', 'C') THEN
                                            msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: x_atf_date_quantity: ' || x_atf_date_quantity);
                                        END IF;
                                    END IF;
                                    -- time_phased_atp changes end

                                    IF (p_atp_qty_tab(k) >= p_quantity_ordered) AND
                                        p_atp_period_tab(k) >= NVL(MSC_ATP_PVT.G_PTF_DATE, p_sys_next_date) THEN

                                        IF(p_round_flag = 1) THEN --- bug 1774959
                                           x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(k));
                                        ELSE
                                           x_atp_date_quantity_this_level := p_atp_qty_tab(k);
                                        END IF;
                                        x_atp_date_this_level := p_atp_period_tab(k);
                                        EXIT;
                                    ELSIF (p_atp_qty_tab(k) >= p_quantity_ordered) AND k = p_atp_period_tab.COUNT THEN
                                        --bug 2787159: This condition is redundant
                                        --IF p_atp_qty_tab(j) >= p_quantity_ordered THEN
                                           IF(p_round_flag = 1) THEN --- bug 1774959
                                              x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(k));
                                           ELSE
                                              x_atp_date_quantity_this_level := p_atp_qty_tab(k);
                                           END IF;
                                           --bug 2787159: We should be using the record which has higher capacity.
                                           ---Record with j will
                                           -- always have lower quantity or lower date than G_PTF_DATE.
                                           --x_atp_date_this_level := GREATEST(p_atp_period_tab(j),
                                           x_atp_date_this_level := GREATEST(p_atp_period_tab(k),
                                                         GREATEST(MSC_ATP_PVT.G_PTF_DATE,p_sys_next_date));
                                        --ELSE
                                        --    x_atp_date_quantity_this_level := NULL;
                                        --    x_atp_date_this_level := NULL;
                                        --END IF;

                                    ELSIF  (p_atp_qty_tab(k) >= p_quantity_ordered) AND
                                             -- Bug 3862224, handled the case where ptf_date has some supply/demand activity, removed equality check
                                             --p_atp_period_tab(k+1) >=
                                             p_atp_period_tab(k+1) >
                                                   NVL(MSC_ATP_PVT.G_PTF_DATE, p_sys_next_date) THEN

                                         x_atp_date_this_level := NVL(MSC_ATP_PVT.G_PTF_DATE, p_sys_next_date);
                                         IF PG_DEBUG in ('Y', 'C') THEN
                                             msc_sch_wb.atp_debug('x_atp_date_this_level '||x_atp_date_this_level);
                                         END IF;
                                         IF(p_round_flag = 1) THEN --- bug 1774959
                                            x_atp_date_quantity_this_level := FLOOR(p_atp_qty_tab(k));
                                         ELSE
                                            x_atp_date_quantity_this_level := p_atp_qty_tab(k);
                                         END IF;
                                         EXIT;


                                    END IF;
                                END LOOP; -- end of k loop
                            END IF; -- end if j = p_atp_period_tab.COUNT
                        END IF; -- end if p_atp_qty_tab(j)>=p_quantity_ordered
                        EXIT;
                    END IF; -- end if we find the bucket
                END LOOP; -- end j loop
        END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'Encountered error = ' || sqlerrm);
           msc_sch_wb.atp_debug('Calculate_Atp_Dates_Qtys: ' || 'Error Code = ' || sqlcode);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

END Calculate_Atp_Dates_Qtys;

PROCEDURE Check_Substitutes(
  p_atp_record        IN OUT NoCopy MRP_ATP_PVT.AtpRec,
  p_parent_pegging_id IN     NUMBER,
  p_instance_id       IN     NUMBER,
  p_scenario_id       IN     NUMBER,
  p_level             IN     NUMBER,
  p_search            IN     NUMBER,
  p_plan_id           IN     NUMBER,
  p_inventory_item_id IN     NUMBER,
  p_organization_id   IN     NUMBER,
  p_quantity          IN     NUMBER,
  l_net_demand        IN OUT NoCopy NUMBER,
  l_supply_demand     IN OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  l_atp_period        IN OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  l_substitutes_rec   OUT    NoCopy MSC_ATP_REQ.get_subs_out_rec,--5216528
  l_return_status     OUT    NoCopy varchar2,
  p_refresh_number    IN     NUMBER) -- For summary enhancement
IS
  /* Bug 4741012 changed the cursor.
  CURSOR substitute(l_requested_ship_date date) IS
  SELECT msi.inventory_item_id, msi.sr_inventory_item_id,
         (sub.usage_quantity/comp.usage_quantity),
         msi.atp_flag,msi.atp_components_flag,comp.usage_quantity
         , msi.item_name        -- Modularize remove unecessary calls.
         --diag_atp
         --bug3609031 adding ceil
         ,ceil(msi.postprocessing_lead_time), ceil(msi.preprocessing_lead_time),
          msi.variable_lead_time, msi.fixed_lead_time,
          msi.unit_weight, msi.unit_volume,
          msi.weight_uom, msi.volume_uom, msi.rounding_control_type
         --time_phased_atp
        -- ,nvl(msi.product_family_id, msi.inventory_item_id)
         --bug 4891470
        ,DECODE(msi.atp_flag, 'N', msi.inventory_item_id,
                DECODE(msi.product_family_id,
           NULL, msi.inventory_item_id,
           -23453, msi.inventory_item_id,
          msi.product_family_id))
         ,msi.aggregate_time_fence_date
         --4570421
         ,comp.scaling_type scaling_type
         ,comp.scale_multiple scale_multiple
         ,comp.scale_rounding_variance scale_rounding_variance
         ,comp.rounding_direction rounding_direction
         ,comp.component_yield_factor component_yield_factor

  FROM   msc_system_items msi, msc_component_substitutes sub,
         msc_bom_components comp, msc_boms bom, msc_system_items ch,
         msc_system_items pt, mrp_atp_details_temp peg
  WHERE  peg.session_id = MSC_ATP_PVT.G_SESSION_ID
  AND    peg.pegging_id = p_parent_pegging_id
  AND    pt.sr_instance_id = p_instance_id
  AND    pt.organization_id = peg.organization_id
  AND    pt.sr_inventory_item_id = peg.inventory_item_id
  AND    pt.plan_id = p_plan_id
  AND    ch.plan_id = pt.plan_id
  AND    ch.organization_id = pt.organization_id
  AND    ch.sr_instance_id = pt.sr_instance_id
  AND    ch.sr_inventory_item_id = p_inventory_item_id
  AND    bom.plan_id = pt.plan_id
  AND    bom.assembly_item_id = pt.inventory_item_id
  AND    bom.organization_id = peg.organization_id
-- performance dsting change p_instance_id to pt.sr_instance_id
  AND    bom.sr_instance_id = pt.sr_instance_id
  and    bom.alternate_bom_designator is null
  AND    comp.bill_sequence_id = bom.bill_sequence_id
  AND    comp.inventory_item_id = ch.inventory_item_id
  AND    TRUNC(NVL(comp.DISABLE_DATE, l_requested_ship_date+1)) >  -- 1221363
                  trunc(l_requested_ship_date)
  AND    TRUNC(comp.EFFECTIVITY_DATE) <= TRUNC(l_requested_ship_date)
  AND    comp.plan_id = bom.plan_id
  AND    sub.bill_sequence_id = comp.bill_sequence_id
  AND    sub.plan_id = comp.plan_id
  AND    sub.component_sequence_id = comp.component_sequence_id
  AND    msi.inventory_item_id = sub.substitute_item_id
  AND    msi.organization_id = comp.organization_id
  AND    msi.sr_instance_id = comp.sr_instance_id
  AND    msi.plan_id = sub.plan_id
  -- BUG 2752227 only get ATPeable substitutes.
  AND    msi.atp_flag in ('Y', 'C')
  ORDER BY priority;
  */
  CURSOR substitute(l_requested_ship_date date) IS
  SELECT msi.inventory_item_id, msi.sr_inventory_item_id,
         decode (NVL(MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG),
                 MSC_ATP_PVT.DISCRETE_ORG, decode (nvl (comp.scaling_type, 1),
                                                   1, (sub.usage_quantity/comp.usage_quantity),
	                                           2,  sub.usage_quantity
	                                           ),
	         MSC_ATP_PVT.OPM_ORG     , decode (nvl (comp.scaling_type, 1),
	                                           0,  sub.usage_quantity,
	                                           1, (sub.usage_quantity/comp.usage_quantity),
	                                           2,  sub.usage_quantity,
	                                           3, (sub.usage_quantity/comp.usage_quantity),
	                                           4, (sub.usage_quantity/comp.usage_quantity),
	                                           5, (sub.usage_quantity/comp.usage_quantity)
	                                           )
	 ), --5008983
         --(sub.usage_quantity/comp.usage_quantity),
         msi.atp_flag,msi.atp_components_flag,comp.usage_quantity
         , msi.item_name        -- Modularize remove unecessary calls.
         --diag_atp
         --bug3609031 adding ceil
         ,ceil(msi.postprocessing_lead_time), ceil(msi.preprocessing_lead_time),
          msi.variable_lead_time, msi.fixed_lead_time,
          msi.unit_weight, msi.unit_volume,
          msi.weight_uom, msi.volume_uom, msi.rounding_control_type
         --time_phased_atp
         --,nvl(msi.product_family_id, msi.inventory_item_id) --5006799
         ,DECODE(msi.product_family_id,
           NULL, msi.inventory_item_id,
           -23453, msi.inventory_item_id,
          msi.product_family_id)
         ,msi.aggregate_time_fence_date
         --4570421
         ,comp.scaling_type scaling_type
         ,comp.scale_multiple scale_multiple
         ,comp.scale_rounding_variance scale_rounding_variance
         ,comp.rounding_direction rounding_direction
         ,comp.component_yield_factor component_yield_factor
         ,sub.usage_quantity/(comp.usage_quantity*comp.component_yield_factor) usage_qty --4775920

  FROM   msc_system_items msi, msc_component_substitutes sub,
         msc_bom_components comp, msc_system_items ch
  WHERE  ch.plan_id = p_plan_id
  AND    ch.organization_id = p_organization_id
  AND    ch.sr_instance_id = p_instance_id
  AND    ch.sr_inventory_item_id = p_inventory_item_id
  AND    comp.bill_sequence_id = p_atp_record.bill_seq_id
  AND    comp.inventory_item_id = ch.inventory_item_id
  AND    TRUNC(NVL(comp.DISABLE_DATE, l_requested_ship_date+1)) >
                  trunc(l_requested_ship_date)
  AND    TRUNC(comp.EFFECTIVITY_DATE) <= TRUNC(l_requested_ship_date)
  AND    comp.plan_id = ch.plan_id
  AND    sub.bill_sequence_id = comp.bill_sequence_id
  AND    sub.plan_id = comp.plan_id
  AND    sub.component_sequence_id = comp.component_sequence_id
  AND    msi.inventory_item_id = sub.substitute_item_id
  AND    msi.organization_id = comp.organization_id
  AND    msi.sr_instance_id = comp.sr_instance_id
  AND    msi.plan_id = sub.plan_id
  AND    msi.atp_flag in ('Y', 'C')
  ORDER BY priority;

  l_requested_ship_date          date;
  l_atp_date_this_level          date;
  l_atp_date_quantity_this_level number;
  l_requested_date_quantity      number;
  l_substitute_id                number := 0.0;
  l_primary_comp_usage           number;
  --4570421
  l_demand_quantity              number; --4570421
  l_usage                        number;
  l_demand_id                    number;
  g_atp_record                   MRP_ATP_PVT.AtpRec;
  l_atp_insert_rec               MRP_ATP_PVT.AtpRec;
  g_atp_period                   MRP_ATP_PUB.ATP_Period_Typ;
  g_atp_supply_demand            MRP_ATP_PUB.ATP_Supply_Demand_Typ;
  l_pegging_rec                  mrp_atp_details_temp%ROWTYPE;
  l_pegging_id                   number;
  l_atp_pegging_id               number;
  l_atp_flag                     varchar2(1) := 'Y';
  l_atp_comp_flag                varchar2(1) := 'N';
  --l_sysdate                      date;
  l_plan_id                      number;
  l_assign_set_id                number;
  l_inv_item_name                varchar2(250); --bug 2246200
  l_org_code                     varchar2(7);
  l_inv_item_id                  number; -- 1665483
  l_summary_flag		 varchar2(1);
  l_plan_info_rec                MSC_ATP_PVT.plan_info_rec;   -- added for bug 2392456

  --diag_atp
  L_GET_MAT_IN_REC               MSC_ATP_REQ.GET_MAT_IN_REC;
  l_get_mat_out_rec              MSC_ATP_REQ.get_mat_out_rec;
  l_post_pro_lt                  number;
  l_pre_pro_lt                   number;
  l_process_lt                   number;
  l_fixed_lt                     number;
  l_variable_lt                  number;
  l_rounding_control_flag        number;
  l_weight_capacity              number;
  l_volume_capacity              number;
  l_weight_uom                   varchar2(3);
  l_volume_uom                   varchar2(3);

  -- time_phased_atp
  l_pf_item_id                   NUMBER;
  l_atf_date                     DATE;
  l_time_phased_atp              VARCHAR2(1) := 'N';
  l_pf_atp                       VARCHAR2(1) := 'N';
  l_mat_atp_info_rec             ATP_INFO_REC;
  l_atf_date_qty                 NUMBER;
  --4570421
  l_scaling_type                 NUMBER;
  l_scale_multiple               number;
  l_scale_rounding_variance      number;
  l_rounding_direction           number;
  l_component_yield_factor       NUMBER;
  l_lot_fail                     NUMBER := 0;
  l_usage_qty                    NUMBER; --4775920
  l_index                        NUMBER := 2; --5216528 as it points to substitutes/ 5216528
  x_substitutes_rec              MSC_ATP_REQ.get_subs_out_rec;-- 5216528/5216528
  l_item_info_rec                MSC_ATP_PVT.item_attribute_rec; --5147647


  -- ATP4drp Bug 3986053, 4052808
  -- Once the item changes the corresponding global data should change.
--  l_item_info_rec                MSC_ATP_PVT.item_attribute_rec;
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Check_Substitutes Procedure************');
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('********** INPUT DATA:Check_Substitutes **********');
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_parent_pegging_id: '|| to_char(p_parent_pegging_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_instance_id: '|| to_char(p_instance_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_scenario_id: '|| to_char(p_scenario_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_level: '|| to_char(p_level));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_search: '|| to_char(p_search));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_plan_id: '|| to_char(p_plan_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_inventory_item_id: '|| to_char(p_inventory_item_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_organization_id: '|| to_char(p_organization_id));
        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_quantity: '|| to_char(p_quantity));
    END IF;
  -- Loop through the substitutes and do a single level check for each of them
  -- If partial quantity is available, insert that into the details and also
  -- set the flag that the component is substitute so that UI can check that
  -- Keep decrementing the net_demand and exit if it is <= 0
  -- If the net_demand is still > 0, pass that back to the calling routing
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Check_Substitutes: ' || 'Opening the substitute cursor:' || to_char(MSC_ATP_PVT.G_SESSION_ID) || ':' ||
	to_char(p_parent_pegging_id) || ':' || to_char(p_plan_id) || ':'
  	|| to_char(p_instance_id) || ':' || p_inventory_item_id  || ':' || p_atp_record.bill_seq_id); --4741012
  END IF;
  --bug3583705
  /*l_sysdate := MSC_ATP_FUNC.prev_work_day(p_atp_record.organization_id,
                             p_atp_record.instance_id,
                             sysdate);*/
  -- Note that p_quantity is the amount of the component B that is not yet
  -- fulfilled; B is the primary and B` the substitute component
  --               A
  --              / \
  --             B   B`
  -- We will resolve this quantity into remaining quantity for A that is needed and

  l_net_demand := p_quantity;

  --- store the summary flag so that the flag can be restored to the value with which we entered this
  --- module
  l_summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;

  /* rajjain 3008611 select component substitutes for which:
   * effective date is greater than or equal to greatest of PTF date, sysdate and component due date
   * disable date is less than or equal to greatest of PTF date, sysdate and component due date*/
  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_atp_record.requested_ship_date: ' || p_atp_record.requested_ship_date);
     msc_sch_wb.atp_debug('Check_Substitutes: ' || 'p_atp_record.shipping_cal_code: ' || p_atp_record.shipping_cal_code);
     msc_sch_wb.atp_debug('Check_Substitutes: ' || 'Date passed to cursor: ' ||
                                                GREATEST(p_atp_record.requested_ship_date, sysdate, MSC_ATP_PVT.G_PTF_DATE));
  END IF;

  --5216528/5216528 Start First should be having the main item.
  x_substitutes_rec.inventory_item_id.EXTEND;
  x_substitutes_rec.pegging_id.EXTEND;
  x_substitutes_rec.sub_atp_qty.EXTEND;
  x_substitutes_rec.demand_id.EXTEND;
  x_substitutes_rec.atf_date_quantity.EXTEND; --5283809
  x_substitutes_rec.quantity_ordered.EXTEND;
  x_substitutes_rec.pf_item_id.EXTEND;
  --5216528/5216528 End

  OPEN substitute(GREATEST(p_atp_record.requested_ship_date, sysdate, MSC_ATP_PVT.G_PTF_DATE));
  LOOP
    FETCH substitute INTO  l_inv_item_id, l_substitute_id, l_usage, l_atp_flag,  --4570421
                        l_atp_comp_flag, l_primary_comp_usage, l_inv_item_name
                        --diag_atp
                        ,l_post_pro_lt, l_pre_pro_lt, l_variable_lt, l_fixed_lt,
                        l_weight_capacity, l_volume_capacity,
                        l_weight_uom, l_volume_uom, l_rounding_control_flag
                        -- time_phased_atp
                        ,l_pf_item_id, l_atf_date,
                         --4570421
                         l_scaling_type,
                         l_scale_multiple,
                         l_scale_rounding_variance,
                         l_rounding_direction ,
                         l_component_yield_factor,
                         l_usage_qty --4775920
                         ;
    EXIT WHEN substitute%NOTFOUND;
    /* Make an array of inventory_ids of the substitutes
       and return to ATP_Check to do a CTP on Substitutes.
    */
    if l_atp_comp_flag <> 'N' then
    --5216528/5216528 Start Insert the subtitutes
    x_substitutes_rec.inventory_item_id.EXTEND;
    x_substitutes_rec.pegging_id.EXTEND;
    x_substitutes_rec.sub_atp_qty.EXTEND;
    x_substitutes_rec.demand_id.EXTEND;
    x_substitutes_rec.atf_date_quantity.EXTEND; --5283809
    x_substitutes_rec.quantity_ordered.EXTEND;
    x_substitutes_rec.pf_item_id.EXTEND;

    x_substitutes_rec.inventory_item_id(l_index) :=   l_substitute_id;
    --5216528/5216528 End
    end if;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Check_Substitutes: ' || '**Substitute:' || to_char(l_substitute_id) || ':'
              || to_char(l_usage) || ':' || l_atp_flag || ':' ||
                 to_char(l_primary_comp_usage));
         --4570421
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_scaling_type: ' || l_scaling_type);
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_scale_multiple: ' || l_scale_multiple);
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_scale_rounding_variance: ' || l_scale_rounding_variance);
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_rounding_direction: ' || l_rounding_direction);
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_component_yield_factor: ' || l_component_yield_factor);
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_usage_qty: ' || l_usage_qty);


      END IF;
      -- Setup new g_atp_record during each loop, we should not resue the
      -- original record, because we need the original one for CTP if there
      -- is not enough supply of components

      g_atp_record.error_code := MSC_ATP_PVT.ALLSUCCESS;
      g_atp_record.instance_id := p_atp_record.instance_id;
      g_atp_record.identifier := p_atp_record.identifier;

      --5147647, populating the global item info rec.
      MSC_ATP_PROC.get_global_item_info(p_atp_record.instance_id,
                                            p_plan_id,
                                            l_substitute_id, --sr_inventory_item_id
                                            p_atp_record.organization_id,
                                            l_item_info_rec );

      /* time_phased_atp
         To support PF ATP for components*/
      g_atp_record.inventory_item_id :=
                            MSC_ATP_PF.Get_PF_Atp_Item_Id(
                                p_atp_record.instance_id,
                                p_plan_id,
                                l_substitute_id,
                                p_atp_record.organization_id
                            );
      g_atp_record.request_item_id := l_substitute_id;
      -- time_phased_atp changes end

      g_atp_record.organization_id := p_atp_record.organization_id;
      --4570421 , here multiply by conversion rate
      IF ( ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(l_scaling_type,1) = 2) OR
           (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_scaling_type,1) IN (0,2))) then --Lot based ot Fixed Scaling
           --g_atp_record.quantity_ordered := l_net_demand
           --g_atp_record.quantity_ordered := l_usage/l_component_yield_factor; --4570421 , here multiply by conversion rate
           g_atp_record.quantity_ordered := l_usage; --4767982
      ELSIF (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_scaling_type,1) IN (4,5)) THEN  --Integer Scaling
            g_atp_record.quantity_ordered := integer_scaling (l_net_demand * l_usage,--4570421 , here multiply by conversion rate
                                             l_scale_multiple,
	                                     l_scale_rounding_variance ,
	                                     l_rounding_direction) ;
      ELSE
           g_atp_record.quantity_ordered := l_net_demand * l_usage; --4570421 , here multiply by conversion rate
      END IF; --4570421
      --g_atp_record.quantity_ordered := l_net_demand * l_usage; -- remaining qty --4570421
      g_atp_record.quantity_UOM := p_atp_record.quantity_UOM;
      g_atp_record.requested_ship_date := p_atp_record.requested_ship_date;
      g_atp_record.requested_arrival_date :=
                            p_atp_record.requested_arrival_date;
      g_atp_record.latest_acceptable_date :=
                            p_atp_record.latest_acceptable_date;
      g_atp_record.delivery_lead_time := p_atp_record.delivery_lead_time;
      g_atp_record.freight_carrier := p_atp_record.freight_carrier;
      g_atp_record.ship_method := p_atp_record.ship_method;
      g_atp_record.demand_class := p_atp_record.demand_class;
      g_atp_record.override_flag := p_atp_record.override_flag;
      g_atp_record.action := p_atp_record.action;
      g_atp_record.ship_date := p_atp_record.ship_date;
      g_atp_record.available_quantity := NULL;
      g_atp_record.requested_date_quantity :=
                            p_atp_record.requested_date_quantity;
      g_atp_record.supplier_id := NULL;
      g_atp_record.supplier_site_id := NULL;
      g_atp_record.insert_flag := p_atp_record.insert_flag;
      g_atp_record.order_number := p_atp_record.order_number;

      l_requested_ship_date := g_atp_record.requested_ship_date;


        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Check_Substitutes: ' || 'Before calling subs atp info');
        END IF;

        -- bug 1665483:
        --IF (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2) AND ((MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y')
        --        OR MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) THEN
        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y')  THEN
          g_atp_record.demand_class :=
          MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(MSC_ATP_PVT.G_PARTNER_ID,
                           MSC_ATP_PVT.G_PARTNER_SITE_ID,
                           l_inv_item_id,
                           g_atp_record.organization_id,
                           g_atp_record.instance_id,
                           l_requested_ship_date,
                           NULL, -- level_id
                           g_atp_record.demand_class);
        END IF;

        /*
        -- New procedure for obtaining plan data : Supplier Capacity Lead Time (SCLT) proj.
        MSC_ATP_PROC.get_global_plan_info(g_atp_record.instance_id,
                                          g_atp_record.request_item_id,
                                          g_atp_record.organization_id,
                                          g_atp_record.demand_class);*/

        /* time_phased_atp changes begin
           Call new procedure Get_PF_Plan_Info*/
        MSC_ATP_PF.Get_PF_Plan_Info(
               g_atp_record.instance_id,
               g_atp_record.request_item_id,
               g_atp_record.inventory_item_id,
               g_atp_record.organization_id,
               g_atp_record.demand_class,
               g_atp_record.atf_date,
               g_atp_record.error_code,
               l_return_status,
               p_plan_id --bug3510475
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Check_Substitutes: ' || 'Error encountered in call to Get_PF_Plan_Info');
                END IF;
        END IF;
        /* time_phased_atp changes end*/

        l_plan_info_rec := MSC_ATP_PVT.G_PLAN_INFO_REC;
        -- End New procedure for obtaining plan data : Supplier Capacity Lead Time proj.

        l_plan_id       := l_plan_info_rec.plan_id;
        l_assign_set_id := l_plan_info_rec.assignment_set_id;
        -- changes for bug 2392456 ends

        -- 24x7
        IF (l_plan_id is NULL) or (l_plan_id IN (-100, -200)) THEN
            -- this should not happen but just in case
            l_plan_id := p_plan_id;
            /* time_phased_atp
               As we are using the same plan for substitutes set ATF date for substitute id*/
            g_atp_record.atf_date := l_atf_date;
        END IF;

        if (l_plan_id = -300) then
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Check_Substitutes: ' || 'ATP Downtime Encountered');
            END IF;
            RAISE MSC_ATP_PVT.EXC_NO_PLAN_FOUND;
        end if;

        -- ATP4drp Product Family ATP not supported for DRP plans.
        IF MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type = 5 THEN
           l_pf_atp := 'N';
           l_time_phased_atp := 'N';
           g_atp_record.atf_date := NULL;
           -- To handle case where family item id is different re-set it.
           g_atp_record.inventory_item_id := g_atp_record.request_item_id;
           l_pf_item_id := l_inv_item_id;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
              msc_sch_wb.atp_debug('Check_Substitutes: ' || 'PF and Allocated ATP not applicable for DRP plans');
              msc_sch_wb.atp_debug('Check_Substitutes: ' || 'g_atp_record.inventory_item_id' ||
                                                                   g_atp_record.inventory_item_id);
              msc_sch_wb.atp_debug('Check_Substitutes: ' || 'g_atp_record.request_item_id' ||
                                                                   g_atp_record.request_item_id);
           END IF;
        ELSE
          -- time_phased_atp changes begin
          IF g_atp_record.atf_date is not null THEN
                l_time_phased_atp := 'Y';
                l_pf_atp := 'N';
          ELSE
                l_time_phased_atp := 'N';
                l_pf_atp := 'Y';
          END IF;
        END IF;
        -- Call Item Info Global Procedure to obtain Component Substitute
        -- Data into memory.
        -- ATP4drp Bug 3986053, 4052808
        -- Once the item changes the corresponding global data should change.
        MSC_ATP_PROC.get_global_item_info(g_atp_record.instance_id,
                                        --3917625: Read data from the plan
                                        -- -1,
                                        p_plan_id,
                                        g_atp_record.request_item_id,
                                        g_atp_record.organization_id,
                                        l_item_info_rec);
        -- End ATP4drp
        l_mat_atp_info_rec.instance_id                       := g_atp_record.instance_id;
        l_mat_atp_info_rec.plan_id                           := l_plan_id;
        l_mat_atp_info_rec.level                             := p_level + 1;
        l_mat_atp_info_rec.identifier                        := g_atp_record.identifier;
        l_mat_atp_info_rec.scenario_id                       := p_scenario_id;
        l_mat_atp_info_rec.inventory_item_id                 := g_atp_record.inventory_item_id;
        l_mat_atp_info_rec.request_item_id                   := g_atp_record.request_item_id;
        l_mat_atp_info_rec.organization_id                   := g_atp_record.organization_id;
        l_mat_atp_info_rec.requested_date                    := l_requested_ship_date;
        l_mat_atp_info_rec.quantity_ordered                  := g_atp_record.quantity_ordered;
        l_mat_atp_info_rec.demand_class                      := g_atp_record.demand_class;
        l_mat_atp_info_rec.insert_flag                       := g_atp_record.insert_flag;
        l_mat_atp_info_rec.rounding_control_flag             := l_get_mat_in_rec.rounding_control_flag;
        l_mat_atp_info_rec.dest_inv_item_id                  := l_get_mat_in_rec.dest_inv_item_id;
        l_mat_atp_info_rec.infinite_time_fence_date          := l_get_mat_in_rec.infinite_time_fence_date;
        l_mat_atp_info_rec.plan_name                         := l_get_mat_in_rec.plan_name;
        l_mat_atp_info_rec.optimized_plan                    := l_get_mat_in_rec.optimized_plan;
        l_mat_atp_info_rec.requested_date_quantity           := null;
        l_mat_atp_info_rec.atp_date_this_level               := null;
        l_mat_atp_info_rec.atp_date_quantity_this_level      := null;
        l_mat_atp_info_rec.substitution_window               := null;
        l_mat_atp_info_rec.atf_date                          := g_atp_record.atf_date; -- For time_phased_atp
        l_mat_atp_info_rec.refresh_number                    := p_refresh_number;   -- For summary enhancement
        l_mat_atp_info_rec.shipping_cal_code                 := p_atp_record.shipping_cal_code; -- Bug 3371817

        --4570421
        l_mat_atp_info_rec.scaling_type                      := p_atp_record.scaling_type;
        l_mat_atp_info_rec.scale_multiple                    := p_atp_record.scale_multiple;
        l_mat_atp_info_rec.scale_rounding_variance           := p_atp_record.scale_rounding_variance;
        l_mat_atp_info_rec.rounding_direction                := p_atp_record.rounding_direction;
        l_mat_atp_info_rec.component_yield_factor            := p_atp_record.component_yield_factor; --4570421
        l_mat_atp_info_rec.usage_qty                         := p_atp_record.usage_qty; --4775920
        l_mat_atp_info_rec.organization_type                 := p_atp_record.organization_type; --4775920

        MSC_ATP_REQ.Get_Material_Atp_Info(
                l_mat_atp_info_rec,
                g_atp_period,
                g_atp_supply_demand,
                l_return_status);

        l_requested_date_quantity                    := l_mat_atp_info_rec.requested_date_quantity;
        l_atf_date_qty                               := l_mat_atp_info_rec.atf_date_quantity;
        l_atp_date_this_level                        := l_mat_atp_info_rec.atp_date_this_level;
        l_atp_date_quantity_this_level               := l_mat_atp_info_rec.atp_date_quantity_this_level;
        l_get_mat_out_rec.atp_rule_name              := l_mat_atp_info_rec.atp_rule_name;
        l_get_mat_out_rec.infinite_time_fence_date   := l_mat_atp_info_rec.infinite_time_fence_date;
        p_atp_record.requested_date_quantity         := l_requested_date_quantity;
        -- time_phased_atp changes end

      -- BUG 2752227: Only substitutes with atp_flag in ('Y', 'C') are selected, don't need END IF.
      -- END IF;  -- end if atp_flag in ('Y', 'C')

      -- Normalize this demand to the primary component B
      --4570421
      IF ( ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(l_scaling_type,1) = 2) OR
           (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_scaling_type,1) IN (0,2))) then --Lot based ot Fixed Scaling
         IF ( l_requested_date_quantity < g_atp_record.quantity_ordered ) THEN
              l_net_demand := g_atp_record.quantity_ordered;
              l_lot_fail := 1;
         ElSE
              l_net_demand := 0;
         END IF;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Check_Substitutes: Lot Based or Fixed Scaling ');
            msc_sch_wb.atp_debug('Check_Substitutes: l_lot_fail : '|| to_char(l_lot_fail));
         END IF;
      ELSIF (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_scaling_type,1) IN (4,5)) THEN  --Integer Scaling
        l_net_demand :=    (g_atp_record.quantity_ordered -
                            FLOOR(greatest(l_requested_date_quantity, 0)/l_scale_multiple) *l_scale_multiple);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Check_Substitutes: Integer_scaling ');
        END IF;
      ELSE
      l_net_demand := (g_atp_record.quantity_ordered -
                            greatest(l_requested_date_quantity, 0)) *
                         (1/l_usage);
      END IF;

      /*l_net_demand := (g_atp_record.quantity_ordered -
                            greatest(l_requested_date_quantity, 0)) *
                         (1/l_usage); */

      -- print the net_demand
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Check_Substitutes: ' || 'l_net_demand : '|| to_char(l_net_demand));
      END IF;

      -- if we don't have atp for this sub component , don't bother
      -- generate pegging tree, demand record.
      /* --5373603 we need to add pegging
      IF (p_atp_record.requested_date_quantity  > 0 AND l_lot_fail = 0 ) --4570421
	 OR MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1
      THEN

            -- prepare the insert record
            -- no matter it is a demand or not, we need to insert this
            -- record into database since it is a recursive procedure
            -- and we will rollback in ATP procedure if it is not a demand. */
	IF p_atp_record.requested_date_quantity > 0 THEN
            l_atp_insert_rec.instance_id := g_atp_record.instance_id;
            -- time_phased_atp changes begin
            l_atp_insert_rec.inventory_item_id := l_pf_item_id;
            l_atp_insert_rec.request_item_id := l_inv_item_id;
            l_atp_insert_rec.atf_date_quantity := l_atf_date_qty;
            -- time_phased_atp end
            l_atp_insert_rec.organization_id := g_atp_record.organization_id;
            l_atp_insert_rec.identifier := g_atp_record.identifier;
            l_atp_insert_rec.demand_source_type:=
                          nvl(g_atp_record.demand_source_type, 2);
            l_atp_insert_rec.demand_source_header_id :=
                            nvl(g_atp_record.demand_source_header_id, -1);
            l_atp_insert_rec.demand_source_delivery :=
                            g_atp_record.demand_source_delivery;
            -- bug 1279984: we only demand the quantity that we have
            l_atp_insert_rec.quantity_ordered:= LEAST(
                                          p_atp_record.requested_date_quantity,
                                          g_atp_record.quantity_ordered);
            l_atp_insert_rec.requested_ship_date := l_requested_ship_date;
            l_atp_insert_rec.demand_class := g_atp_record.demand_class;
            l_atp_insert_rec.refresh_number := p_refresh_number; -- summary enhancement g_atp_record.refresh_number;
            l_atp_insert_rec.order_number := g_atp_record.order_number;
            -- ATP4drp Component Subst. we are dealing with a component
            -- then set the origination type to Constrained Kit Demand
            -- for DRP plans.
            IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5 THEN
                l_atp_insert_rec.origination_type := 47;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Check_Substitutes: ' || 'DRP origination_type ='|| l_atp_insert_rec.origination_type);
                   msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                END IF;
            ELSE
                l_atp_insert_rec.origination_type := 1;
            END IF;
            -- End ATP4drp

	    MSC_ATP_DB_UTILS.Add_Mat_Demand(l_atp_insert_rec,
                              l_plan_id,
                              0,
                              l_demand_id);
	END IF;

            -- populate insert rec to pegging tree for this demand

            -- for performance reason, we call these function here and
            -- then populate the pegging tree with the values

            /* Modularize Item and Org Info */
            MSC_ATP_PROC.get_global_org_info (g_atp_record.instance_id,
                                              g_atp_record.organization_id);
            l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
            /*Modularize Item and Org Info */


            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
            l_pegging_rec.atp_level:= p_level;
            l_pegging_rec.organization_id:= g_atp_record.organization_id;
            l_pegging_rec.organization_code := l_org_code;
            l_pegging_rec.identifier1:= g_atp_record.instance_id;
            l_pegging_rec.identifier2 := l_plan_id;
            l_pegging_rec.identifier3 := l_demand_id;
            --4570421
            l_pegging_rec.scaling_type                      := l_scaling_type;
            l_pegging_rec.scale_multiple                    := l_scale_multiple;
            l_pegging_rec.scale_rounding_variance           := l_scale_rounding_variance;
            l_pegging_rec.rounding_direction                := l_rounding_direction;
            l_pegging_rec.component_yield_factor            := l_component_yield_factor;
            l_pegging_rec.usage                             := l_usage_qty; --4775920
            l_pegging_rec.organization_type                 := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920
            --4570421

            -- time_phased_atp changes begin
            IF l_pf_atp = 'Y' THEN
                    l_pegging_rec.inventory_item_id:= g_atp_record.inventory_item_id;
            ELSE
                    l_pegging_rec.inventory_item_id:= g_atp_record.request_item_id;
            END IF;
            l_pegging_rec.request_item_id:= g_atp_record.request_item_id;
            l_pegging_rec.aggregate_time_fence_date := g_atp_record.atf_date;
            -- time_phased_atp changes end

            l_pegging_rec.inventory_item_name := l_inv_item_name;
            l_pegging_rec.resource_id := NULL;
            l_pegging_rec.resource_code := NULL;
            l_pegging_rec.department_id := NULL;
            l_pegging_rec.department_code := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= 1;  -- cchen 08/31
            -- bug 1279984: we only demand the quantity that we have

	    -- dsting diag_atp only add demand for available quantity for component substitute
	    l_pegging_rec.supply_demand_quantity:= LEAST(
                                          p_atp_record.requested_date_quantity,
                                          g_atp_record.quantity_ordered);
            l_pegging_rec.supply_demand_type:= 1;
            l_pegging_rec.supply_demand_date:= l_requested_ship_date;
            l_pegging_rec.number1 := 1;

	    -- dsting ATO 2465370
	    l_pegging_rec.required_date := l_requested_ship_date;
            --bug 3328421: comp subst si supported only for backward ATP. Therefroe we always store req_date
            l_pegging_rec.actual_supply_demand_date := l_requested_ship_date;

            -- for demo:1153192
            l_pegging_rec.constraint_flag := 'N';
	    l_pegging_rec.component_identifier :=
			NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;

            --diag_atp
	    l_pegging_rec.pegging_type := MSC_ATP_PVT.ORG_DEMAND; -- demand node
            l_pegging_rec.constraint_type := NULL;
            --s_cto_rearch
            l_pegging_rec.dest_inv_item_id := l_pf_item_id;

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= l_pegging_id;
            l_pegging_rec.atp_level:= p_level + 1;
            l_pegging_rec.organization_id:= g_atp_record.organization_id;
            l_pegging_rec.organization_code:= l_org_code;
            l_pegging_rec.identifier1:= g_atp_record.instance_id;
            l_pegging_rec.identifier2 := l_plan_id;
            l_pegging_rec.identifier3 := NULL;
            l_pegging_rec.inventory_item_id:= g_atp_record.inventory_item_id;
            l_pegging_rec.inventory_item_name := l_inv_item_name;

            -- time_phased_atp changes begin
            IF l_time_phased_atp = 'Y' and l_requested_ship_date <= g_atp_record.atf_date THEN
                    l_pegging_rec.inventory_item_id:= g_atp_record.request_item_id;
                    l_pegging_rec.inventory_item_name := g_atp_record.request_item_name;
            ELSE
                    l_pegging_rec.inventory_item_id:= p_atp_record.inventory_item_id;
                    l_pegging_rec.inventory_item_name := l_inv_item_name;
            END IF;
            l_pegging_rec.request_item_id:= g_atp_record.request_item_id;
            -- time_phased_atp changes end

            l_pegging_rec.resource_id := NULL;
            l_pegging_rec.resource_code := NULL;
            l_pegging_rec.department_id := NULL;
            l_pegging_rec.department_code := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
            l_pegging_rec.supply_demand_quantity:=
                            p_atp_record.requested_date_quantity;
            l_pegging_rec.supply_demand_date:= l_requested_ship_date;
            l_pegging_rec.supply_demand_type:= 2;
            l_pegging_rec.source_type := 0;
            l_pegging_rec.component_identifier :=
			 NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);

            -- for demo:1153192
            IF  (p_search = 1) AND
	       ( g_atp_record.quantity_ordered >= l_requested_date_quantity)
	    THEN
                  l_pegging_rec.constraint_flag := 'Y';
            ELSE
                  l_pegging_rec.constraint_flag := 'N';

            END IF;

            l_pegging_rec.pegging_type := MSC_ATP_PVT.ATP_SUPPLY; ---atp supply node
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;
             -- Bug 3826234
            l_pegging_rec.manufacturing_cal_code :=  p_atp_record.manufacturing_cal_code;

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_atp_pegging_id);

            -- Add pegging_id to the l_atp_period and l_atp_supply_demand

            FOR i in 1..g_atp_period.Level.COUNT LOOP
                g_atp_period.Pegging_Id(i) := l_atp_pegging_id;
                g_atp_period.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
            END LOOP;

	    IF p_atp_record.insert_flag <> 0 THEN
	   	MSC_ATP_DB_UTILS.move_SD_temp_into_mrp_details(l_atp_pegging_id,
				MSC_ATP_PVT.G_DEMAND_PEGGING_ID);
   	    END IF;


            MSC_ATP_PROC.Details_Output(g_atp_period,
       			     g_atp_supply_demand,
                             l_atp_period,
                             l_supply_demand,
                             l_return_status);

      --END IF;  -- IF p_atp_record.requested_date_quantity > 0 --5373603
       if l_atp_comp_flag <> 'N' then
               --5216528/5216528 insert the remaining values.
               x_substitutes_rec.pegging_id(l_index) := l_pegging_id;
               x_substitutes_rec.sub_atp_qty(l_index) :=  l_pegging_rec.supply_demand_quantity;
               x_substitutes_rec.demand_id(l_index) := l_demand_id;
               x_substitutes_rec.pf_item_id(l_index) := l_pf_item_id; --5283809
               x_substitutes_rec.atf_date_quantity(l_index) := l_atf_date_qty; --5283809
               x_substitutes_rec.quantity_ordered(l_index) := g_atp_record.quantity_ordered; --5283809
               l_index := l_index + 1;
       end if;
      --4570421
      l_lot_fail := 0; --resetting the variable to zero

      IF (l_net_demand <= 0) then
          EXIT;
      END IF;
  END LOOP;
         l_substitutes_rec := x_substitutes_rec;
  CLOSE substitute;
  MSC_ATP_PVT.G_SUMMARY_FLAG := l_summary_flag;
EXCEPTION
  -- 24x7
  WHEN MSC_ATP_PVT.EXC_NO_PLAN_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Check Substitutes : Plan Downtime encountered');
     END IF;
     MSC_ATP_PVT.G_DOWNTIME_HIT := 'Y';
     MSC_ATP_PVT.G_SUMMARY_FLAG := l_summary_flag;
     l_return_status := FND_API.G_RET_STS_ERROR;
     CLOSE substitute;
     RAISE MSC_ATP_PVT.EXC_NO_PLAN_FOUND;

  WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN --bug3583705
     IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Check Substitutes : NO_MATCHING_DATE_IN_CAL');
     END IF;
     MSC_ATP_PVT.G_SUMMARY_FLAG := l_summary_flag;
     l_return_status := FND_API.G_RET_STS_ERROR;
     CLOSE substitute;
     RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;

  WHEN OTHERS THEN
    MSC_ATP_PVT.G_SUMMARY_FLAG := l_summary_flag;
    l_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE substitute;
    return;
END Check_Substitutes;

/* time_phased_atp
   Grouped various input parameters to this procedure in a new record Atp_Info_Rec*/
PROCEDURE Get_Material_Atp_Info (
    p_mat_atp_info_rec      IN OUT  NOCOPY Atp_Info_Rec,
    x_atp_period            OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
    x_atp_supply_demand     OUT     NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    x_return_status         OUT     NoCopy VARCHAR2
)
IS
l_infinite_time_fence_date	DATE;
l_sysdate_seq_num               NUMBER;
l_requested_date                DATE;
--l_atp_mat_atp_info_rec.requested_date            DATE; -- time_phased_atp
i 				PLS_INTEGER := 1;
l_atp_period_tab 		MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_atp_qty_tab 			MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
--l_next_period			DATE; -- time_phased_atp
l_return_status			VARCHAR2(1);
g_atp_record                    MRP_ATP_PVT.AtpRec;
l_net_demand                    number;
g_quantity_ordered              number;
my_sqlcode			NUMBER;
tmp1				DATE;
tmp2				NUMBER;
temp				NUMBER;
l_default_atp_rule_id           NUMBER;
l_calendar_code                 VARCHAR2(14);
l_calendar_exception_set_id     NUMBER;
l_default_demand_class          VARCHAR2(34);
l_atp_info            		MRP_ATP_PVT.ATP_Info;
l_pre_process_date		DATE;
l_processing_lead_time		NUMBER;
l_sysdate			DATE;
l_sys_next_date                 DATE;
l_sys_next_osc_date             DATE; -- Bug 3371817
--l_round_flag			NUMBER; -- time_phased_atp
l_Summary_atp 		        VARCHAR(1);
--bug 2152184
l_request_item_id               NUMBER;

L_SUBST_LIMIT_DATE              DATE;


l_org_code                      VARCHAR2(7);

 --diag_atp
  L_GET_MAT_IN_REC               MSC_ATP_REQ.GET_MAT_IN_REC;

-- for summary enhancement
l_summary_flag                  NUMBER := -1;  -- Bug 3813302 - Initiallize the variable.

-- time_phased_atp
l_time_phased_atp               VARCHAR2(1) := 'N';

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Get_Material_Atp_Info Procedure************');
    END IF;

    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('********** INPUT DATA:Get_Material_Atp_Info **********');
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.inventory_item_id: '|| to_char(p_mat_atp_info_rec.inventory_item_id));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.request_item_id: '|| to_char(p_mat_atp_info_rec.request_item_id));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.organization_id: '|| to_char(p_mat_atp_info_rec.organization_id));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.requested_date: '|| to_char(p_mat_atp_info_rec.requested_date));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.instance_id: '|| to_char(p_mat_atp_info_rec.instance_id));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.plan_id: '|| to_char(p_mat_atp_info_rec.plan_id));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.quantity_ordered: '|| to_char(p_mat_atp_info_rec.quantity_ordered));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.insert_flag: '|| to_char(p_mat_atp_info_rec.insert_flag));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.demand_class: '|| p_mat_atp_info_rec.demand_class);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.substitution_window := '|| p_mat_atp_info_rec.substitution_window);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.atf_date: '|| p_mat_atp_info_rec.atf_date);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.shipping_cal_code: '|| p_mat_atp_info_rec.shipping_cal_code);
    END IF;
     /* time_phased_atp changes begin*/
     IF (MSC_ATP_PVT.G_INV_CTP = 4)
        and (p_mat_atp_info_rec.inventory_item_id <> p_mat_atp_info_rec.request_item_id)
            and (p_mat_atp_info_rec.atf_date is null)
     THEN
         l_request_item_id := p_mat_atp_info_rec.inventory_item_id;
     ELSIF (MSC_ATP_PVT.G_INV_CTP = 4)
        and (p_mat_atp_info_rec.inventory_item_id <> p_mat_atp_info_rec.request_item_id)
            and (p_mat_atp_info_rec.atf_date is not null)
     THEN
         l_request_item_id := p_mat_atp_info_rec.request_item_id;
         l_time_phased_atp := 'Y';
     ELSE
         l_request_item_id := p_mat_atp_info_rec.request_item_id;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_request_item_id := ' || l_request_item_id);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Time Phased ATP = ' || l_time_phased_atp);
     END IF;
     /* time_phased_atp changes end*/

    -- get the infinite time fence date if it exists
    /*l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_mat_atp_info_rec.instance_id,
        p_mat_atp_info_rec.inventory_item_id,p_mat_atp_info_rec.organization_id, p_mat_atp_info_rec.plan_id); */
    --diag_atp
    MSC_ATP_PROC.get_infinite_time_fence_date(p_mat_atp_info_rec.instance_id,
                                              p_mat_atp_info_rec.inventory_item_id,
                                              p_mat_atp_info_rec.organization_id,
                                              p_mat_atp_info_rec.plan_id,
                                              l_infinite_time_fence_date,
                                              p_mat_atp_info_rec.atp_rule_name);

    p_mat_atp_info_rec.infinite_time_fence_date := l_infinite_time_fence_date;
    l_get_mat_in_rec.infinite_time_fence_date := l_infinite_time_fence_date;
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || ' ATP Rule := ' || p_mat_atp_info_rec.atp_rule_name);
    END IF;

    -- 2859130 get if this is a constrained plan or not
    IF p_mat_atp_info_rec.plan_id <> -1 THEN
        BEGIN
            SELECT  DECODE(plans.plan_type, 4, 2,
                        DECODE(daily_material_constraints, 1, 1,
                            DECODE(daily_resource_constraints, 1, 1,
                                DECODE(weekly_material_constraints, 1, 1,
                                    DECODE(weekly_resource_constraints, 1, 1,
                                        DECODE(period_material_constraints, 1, 1,
                                            DECODE(period_resource_constraints, 1, 1, 2)
                                              )
                                          )
                                      )
                                  )
                              )
                          ),
                    summary_flag
            INTO    MSC_ATP_PVT.G_OPTIMIZED_PLAN, l_summary_flag    -- For summary enhancement
            FROM    msc_plans plans
            WHERE   plans.plan_id = p_mat_atp_info_rec.plan_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            MSC_ATP_PVT.G_OPTIMIZED_PLAN := 2;
        END;
    END IF;
    l_get_mat_in_rec.optimized_plan := MSC_ATP_PVT.G_OPTIMIZED_PLAN; -- 2859130

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Optimized plan: ' || MSC_ATP_PVT.G_OPTIMIZED_PLAN);
    END IF;

    --- bug 1819638:  get next working day.

    -- msc_calendar.select_calendar_defaults(p_mat_atp_info_rec.organization_id,p_mat_atp_info_rec.instance_id,
    --          l_calendar_code, l_exception_set_id);
    /* Modularize Item and Org Info */
    -- changed call, re-use info already obtained.
    MSC_ATP_PROC.get_global_org_info(p_mat_atp_info_rec.instance_id, p_mat_atp_info_rec.organization_id);
    l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
    l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
    l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
    l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
    l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
    /*Modularize Item and Org Info */


    /************ Bug 1510853 ATP Rule Check ************/
    IF (MSC_ATP_PVT.G_INV_CTP = 5) AND
        (l_default_atp_rule_id IS NULL) AND    -- no default rule at org level
        (MSC_ATP_PVT.G_ATP_RULE_FLAG = 'N') THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || ' RAISING EXCEPTION for NO ATP RULE ');
        END IF;
        RAISE MSC_ATP_PVT.EXC_NO_ATP_RULE;  -- ATPeable item has no rule
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'ATP RULE EXISTS at Item or Org level ' ||
                'ORG LEVEL Default Rule: '||l_default_atp_rule_id);
        END IF;
        MSC_ATP_PVT.G_ATP_RULE_FLAG := 'Y';  -- Item has an applicable ATP rule
    END IF;
    /************ Bug 1510853 ATP Rule Check ************/

    --- Write SQL statement so that we do not need to
    --- make two calls to database for l_sysdate_seq_num and l_sys_next_date

    BEGIN
        SELECT  cal.next_seq_num, cal.next_date
        INTO    l_sysdate_seq_num, l_sys_next_date
        FROM    msc_calendar_dates  cal
        WHERE   cal.exception_set_id = l_calendar_exception_set_id
        AND     cal.calendar_code = l_calendar_code
        AND     cal.calendar_date = TRUNC(sysdate)
        AND     cal.sr_instance_id = p_mat_atp_info_rec.instance_id ;

        -- Bug 3371817 - Calculate OSC sysdate
        IF p_mat_atp_info_rec.shipping_cal_code = l_calendar_code THEN
            -- OMC and OSC are same or looking at components for make case
            l_sys_next_osc_date := l_sys_next_date;
        ELSE
            l_sys_next_osc_date := MSC_CALENDAR.NEXT_WORK_DAY(
                                    p_mat_atp_info_rec.shipping_cal_code,
                                    p_mat_atp_info_rec.instance_id,
                                    TRUNC(sysdate));
        END IF;
        l_get_mat_in_rec.sys_next_osc_date :=  l_sys_next_osc_date; --bug3333114
    EXCEPTION
        WHEN OTHERS THEN
            RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    END;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_sysdate_seq_num = ' || l_sysdate_seq_num);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_sys_next_date = ' || l_sys_next_date);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_sys_next_osc_date = ' || l_sys_next_osc_date);
    END IF;
    -- in case we want to support flex date
    l_requested_date := p_mat_atp_info_rec.requested_date;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_infinite_time_fence_date: '|| to_char(l_infinite_time_fence_date));
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_requested_date: '|| to_char(p_mat_atp_info_rec.requested_date));
    END IF;

    IF (l_requested_date >=
        NVL(l_infinite_time_fence_date, l_requested_date +1)) THEN
        -- requested date outside the infinite time fence.  no need to do
        -- the actual atp check.
       MSC_ATP_DB_UTILS.Clear_SD_Details_temp(); --bug 4618369
        p_mat_atp_info_rec.requested_date_quantity := MSC_ATP_PVT.INFINITE_NUMBER;
        p_mat_atp_info_rec.atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;
        p_mat_atp_info_rec.atp_date_this_level := l_requested_date;

    ELSE

        -- Check if full summary has been run - for summary enhancement
        IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND
            l_summary_flag NOT IN (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN, MSC_POST_PRO.G_SF_PREALLOC_COMPLETED,
                                   MSC_POST_PRO.G_SF_FULL_SUMMARY_RUNNING) THEN
            -- Summary SQL can be used
            MSC_ATP_PVT.G_SUMMARY_SQL := 'Y';
        ELSE
            -- Use the SQL for non summary case
            MSC_ATP_PVT.G_SUMMARY_SQL := 'N';
        END IF;

        -- we need to have a branch here for allocated atp
        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'N') THEN
            -- if we need the detail information, we will get individual s/d rows
            -- and do the sum ourselves.  if we don't need the detail infomation,
            -- we will do a group by and select the sum in the sql statement.
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'MSC_ATP_PVT.G_SUMMARY_FLAG := ' || MSC_ATP_PVT.G_SUMMARY_FLAG);
            END IF;

            -- 2859130 replace sql stmts with calls to procedures containing the sql stmts
            IF nvl(p_mat_atp_info_rec.insert_flag, 0) = 0 THEN
                IF p_mat_atp_info_rec.inventory_item_id = l_request_item_id  THEN
                    get_mat_avail(
                            MSC_ATP_PVT.G_SUMMARY_SQL, -- MSC_ATP_PVT.G_SUMMARY_FLAG, -- changed for summary enhancement
                            MSC_ATP_PVT.G_OPTIMIZED_PLAN,
                            p_mat_atp_info_rec.inventory_item_id,
                            p_mat_atp_info_rec.organization_id,
                            p_mat_atp_info_rec.instance_id,
                            p_mat_atp_info_rec.plan_id,
                            l_calendar_code,
                            l_calendar_exception_set_id,
                            l_sysdate_seq_num,
                            l_sys_next_date,
                         -- l_default_atp_rule_id,
                         -- p_mat_atp_info_rec.demand_class,
                            p_mat_atp_info_rec.demand_class, --Sequence of parameters changed as a part of cmro changes
                            l_default_atp_rule_id,--to correct them
                            l_default_demand_class,
                            l_infinite_time_fence_date,
                            p_mat_atp_info_rec.refresh_number,           -- For summary enhancement
                            l_atp_period_tab,
                            l_atp_qty_tab
                    );
                ELSE
                    -- time_phased_atp
                    MSC_ATP_PF.Get_Mat_Avail_Pf(
                            MSC_ATP_PVT.G_SUMMARY_SQL, -- MSC_ATP_PVT.G_SUMMARY_FLAG, -- changed for summary enhancement
                            p_mat_atp_info_rec.inventory_item_id,
                            p_mat_atp_info_rec.request_item_id,
                            p_mat_atp_info_rec.organization_id,
                            p_mat_atp_info_rec.instance_id,
                            p_mat_atp_info_rec.plan_id,
                            l_calendar_code,
                            l_sysdate_seq_num,
                            l_sys_next_date,
                            p_mat_atp_info_rec.demand_class,
                            l_default_atp_rule_id,
                            l_default_demand_class,
                            l_infinite_time_fence_date,
                            p_mat_atp_info_rec.refresh_number,           -- For summary enhancement
                            l_atp_period_tab,
                            l_atp_qty_tab,
                            l_return_status
                    );
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Error occured in procedure Get_Mat_Avail_Pf');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'after getting netted qtys');
                END IF;

                -- time_phased_atp
                IF l_time_phased_atp = 'Y' THEN
                    MSC_ATP_PF.pf_atp_consume(
                           l_atp_qty_tab,
                           l_return_status,
                           l_atp_period_tab,
                           MSC_ATP_PF.Bw_Fw_Cum, --b/w, f/w consumption and accumulation
                           p_mat_atp_info_rec.atf_date);
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Error occured in procedure Pf_Atp_Consume');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                    END IF;
                ELSE
                    MSC_ATP_PROC.atp_consume(l_atp_qty_tab, l_atp_qty_tab.count);
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'after atp_consume');
                END IF;

                /* Cum drop issue changes begin*/
                MSC_AATP_PROC.Atp_Remove_Negatives(l_atp_qty_tab, l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                       END IF;
                       RAISE FND_API.G_EXC_ERROR;
                END IF;
                /* Cum drop issue changes end*/

                IF l_infinite_time_fence_date IS NOT NULL THEN
                    -- add one more entry to indicate infinite time fence date
                    -- and quantity.
                    IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'adding itf');
                    END IF;
                    l_atp_period_tab.EXTEND;
                    l_atp_qty_tab.EXTEND;
                    l_atp_period_tab(l_atp_period_tab.count) := l_infinite_time_fence_date;
                    l_atp_qty_tab(l_atp_qty_tab.count) := MSC_ATP_PVT.INFINITE_NUMBER;
                END IF;

                Print_Dates_Qtys(l_atp_period_tab, l_atp_qty_tab);

            ELSE    -- IF nvl(p_mat_atp_info_rec.insert_flag, 0) = 0 THEN

                l_get_mat_in_rec.infinite_time_fence_date := l_infinite_time_fence_date;
                l_get_mat_in_rec.dest_inv_item_id := p_mat_atp_info_rec.dest_inv_item_id;

                MSC_ATP_REQ.Insert_Details(p_mat_atp_info_rec.instance_id,
                        p_mat_atp_info_rec.plan_id,
                        p_mat_atp_info_rec.level,
                        p_mat_atp_info_rec.identifier,
                        p_mat_atp_info_rec.scenario_id,
                        p_mat_atp_info_rec.request_item_id,
                        p_mat_atp_info_rec.inventory_item_id,
                        p_mat_atp_info_rec.organization_id,
                        p_mat_atp_info_rec.demand_class,
                        p_mat_atp_info_rec.insert_flag,
                        x_atp_period,
                        x_atp_supply_demand,
                        l_return_status,
                        --diag_atp
                        l_get_mat_in_rec,
                        p_mat_atp_info_rec.atf_date); -- For time_phased_atp

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'after Insert_Details');
                END IF;

                l_atp_period_tab := x_atp_period.Period_Start_Date;
                l_atp_qty_tab := x_atp_period.Cumulative_Quantity;

                Print_Dates_Qtys(l_atp_period_tab, l_atp_qty_tab);
            END IF; -- IF nvl(p_mat_atp_info_rec.insert_flag, 0) = 0 THEN

        ELSE  -- IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'N') THEN

            -- we are using allocated atp
            /* Modularize Item and Org Info */
            -- changed call, re-use info already obtained.
            MSC_ATP_PROC.get_global_org_info(p_mat_atp_info_rec.instance_id, p_mat_atp_info_rec.organization_id);
            l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
            l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
            l_calendar_exception_set_id :=
                                MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
            l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
            l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
            /*Modularize Item and Org Info */

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_default_atp_rule_id='|| l_default_atp_rule_id);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_calendar_code='||l_calendar_code);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_default_demand_class'|| l_default_demand_class);
            END IF;
            IF MSC_ATP_PVT.G_ALLOCATION_METHOD = 1 AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Pre-alllocated demand class AATP');
                END IF;

                --diag_atp: pass infinite time fence as in parameter so that we dont need to recalculate it
                l_get_mat_in_rec.infinite_time_fence_date := l_infinite_time_fence_date;
                l_get_mat_in_rec.dest_inv_item_id := p_mat_atp_info_rec.dest_inv_item_id;

                MSC_AATP_REQ.Item_Pre_Allocated_Atp(p_mat_atp_info_rec.plan_id,
                                                    p_mat_atp_info_rec.level,
                                                    p_mat_atp_info_rec.identifier,
                                                    p_mat_atp_info_rec.scenario_id,
                                                    p_mat_atp_info_rec.inventory_item_id,
                                                    p_mat_atp_info_rec.organization_id,
                                                    p_mat_atp_info_rec.instance_id,
                                                    p_mat_atp_info_rec.demand_class,
                                                    l_requested_date,
                                                    p_mat_atp_info_rec.insert_flag,
                                                    l_atp_info,
                                                    x_atp_period,
                                                    x_atp_supply_demand,
                                                    --diag_atp
                                                    l_get_mat_in_rec,
                                                    p_mat_atp_info_rec.refresh_number,   -- For summary enhancement
                                                    p_mat_atp_info_rec.request_item_id,  -- For time_phased_atp
                                                    p_mat_atp_info_rec.atf_date);        -- For time_phased_atp


            -- rajjain 02/20/2003 Bug 2813095 Begin
            ELSIF MSC_ATP_PVT.G_ALLOCATION_METHOD = 1 AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2 THEN
                RAISE MSC_ATP_PVT.ALLOC_ATP_INVALID_PROFILE;
                -- rajjain 02/20/2003 Bug 2813095 End
            ELSE

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Customer class or Allocation based demand class AATP');
                END IF;
                --diag_atp: pass infinite time fence as in parameter so that we dont need to recalculate it
                l_get_mat_in_rec.infinite_time_fence_date := l_infinite_time_fence_date;
                l_get_mat_in_rec.dest_inv_item_id := p_mat_atp_info_rec.dest_inv_item_id;
                MSC_AATP_PVT.Item_Alloc_Cum_Atp(p_mat_atp_info_rec.plan_id,
                                                p_mat_atp_info_rec.level,
                                                p_mat_atp_info_rec.identifier,
                                                p_mat_atp_info_rec.scenario_id,
                                                p_mat_atp_info_rec.inventory_item_id,
                                                p_mat_atp_info_rec.organization_id,
                                                p_mat_atp_info_rec.instance_id,
                                                NVL(p_mat_atp_info_rec.demand_class,
                                                    NVL(l_default_demand_class, '@@@')),
                                                l_requested_date,
                                                p_mat_atp_info_rec.insert_flag,
                                                l_atp_info,
                                                x_atp_period,
                                                x_atp_supply_demand,
                                                l_get_mat_in_rec,
                                                p_mat_atp_info_rec.request_item_id,  -- For time_phased_atp
                                                p_mat_atp_info_rec.atf_date);         -- For time_phased_atp
            END IF;
            l_atp_period_tab := l_atp_info.atp_period;
            l_atp_qty_tab := l_atp_info.atp_qty;

            --bug2471377 pumehta Begin Changes
            --copy the period information which can be used
            --later in atp_check procedure in the case where
            -- comp_flag is 'N' and stealing has happened.
            --Copy these values only if we are at Top assembly level.

            IF NVL(p_mat_atp_info_rec.insert_flag,0) = 0 and
                p_mat_atp_info_rec.level = 1 AND
                nvl(MSC_ATP_PVT.G_ITEM_INFO_REC.atp_comp_flag,'N') = 'N' THEN
                x_atp_period.cumulative_quantity := l_atp_info.atp_qty;
                x_atp_period.period_start_date := l_atp_info.atp_period;
            END IF;
            --Bug2471377 End Changes.

            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_atp_info.atp_period.count = '||l_atp_info.atp_period.COUNT);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_atp_info.atp_qty.count = '||l_atp_info.atp_qty.COUNT);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_atp_info.limit_qty.count = '||l_atp_info.limit_qty.COUNT);
            END IF;

        END IF; -- end of G_ALLOCATED_ATP

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_atp_period_tabl.count = '||l_atp_period_tab.COUNT);
        END IF;

        IF l_atp_period_tab.COUNT = 0 THEN
            -- need to add error message
            RAISE NO_DATA_FOUND;
        END IF;

        /* time_phased_atp
        Atp dates qtys calculation code moved to a private procedure*/
        Calculate_Atp_Dates_Qtys(
                l_atp_period_tab,
                l_atp_qty_tab,
                l_requested_date,
                p_mat_atp_info_rec.atf_date,
                p_mat_atp_info_rec.quantity_ordered,
                -- l_sys_next_date, Bug 3371817
                l_sys_next_osc_date,
                p_mat_atp_info_rec.rounding_control_flag,
                p_mat_atp_info_rec.requested_date_quantity,
                p_mat_atp_info_rec.atf_date_quantity,
                p_mat_atp_info_rec.atp_date_this_level,
                p_mat_atp_info_rec.atp_date_quantity_this_level,
                x_return_status
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        END IF;
    END IF; --end if l_requested_date > l_infinite_time_fence_date
    --- subst
    --- IF future date is after substitution window then we will move atp date to infinite time fence date
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.atp_date_this_level :=' || p_mat_atp_info_rec.atp_date_this_level);
        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_infinite_time_fence_date := ' || l_infinite_time_fence_date);
    END IF;

    IF MSC_ATP_PVT.G_SUBSTITUTION_FLAG = 'Y' AND NVL(p_mat_atp_info_rec.substitution_window,0) > 0
        AND p_mat_atp_info_rec.atp_date_this_level is not null THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'we have substitution window');
        END IF;
        IF l_infinite_time_fence_date is not null and p_mat_atp_info_rec.atp_date_this_level = l_infinite_time_fence_date THEN
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.atp_date_this_level = infinite supply, dont move the date');
            END IF;
        ELSE
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Do substitution check');
            END IF;
            l_subst_limit_date := MSC_CALENDAR.DATE_OFFSET(
                                                p_mat_atp_info_rec.organization_id,
                                                p_mat_atp_info_rec.instance_id,
                                                1,
                                                p_mat_atp_info_rec.requested_date,
                                                p_mat_atp_info_rec.substitution_window);
            IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'l_subst_limit_date := ' || l_subst_limit_date);
                msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'p_mat_atp_info_rec.atp_date_this_level := ' || p_mat_atp_info_rec.atp_date_this_level);
            END IF;
            IF p_mat_atp_info_rec.atp_date_this_level > l_subst_limit_date THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || ' p_mat_atp_info_rec.atp_date_this_level > l_subst_limit_date');
                    msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'moving p_mat_atp_info_rec.atp_date_this_level to infinite time fence');
                END IF;
                p_mat_atp_info_rec.atp_date_this_level := l_infinite_time_fence_date;
                p_mat_atp_info_rec.atp_date_quantity_this_level := MSC_ATP_PVT.INFINITE_NUMBER;
            END IF;
        END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Get_Material_Atp_Info Procedure************');
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        --        x_return_status := FND_API.G_RET_STS_ERROR;
        p_mat_atp_info_rec.requested_date_quantity := 0.0;

        -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


        --- Bug 1819638: This exception is added too handel error
        --- when no next_date corresponding to sys date is found in
        --- the calendar
        ---- This exception raises exception NO_MATCHING_DATE_IN_CAL
        --- This exception is defined in ATP_CHECK.
        --- Since we can't pass back the error code to atp_check from get_mat_atp_info,
        --- we are using exceptions
    WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN
        p_mat_atp_info_rec.requested_date_quantity := 0.0;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'No match for sysdate in cal');
        END IF;
        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;

    /************ Bug 1510853 ATP Rule Check ************/
    WHEN MSC_ATP_PVT.EXC_NO_ATP_RULE  THEN
        p_mat_atp_info_rec.requested_date_quantity := 0.0;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'No Applicable ATP rule in Get Material ATP Info');
        END IF;
        RAISE MSC_ATP_PVT.EXC_NO_ATP_RULE;

    -- rajjain 02/20/2003 Bug 2813095
    WHEN MSC_ATP_PVT.ALLOC_ATP_INVALID_PROFILE THEN
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' ||
                'Incompatible setup of MSC: ATP Allocation Method and MSC: Class Hierarchy');
        END IF;
        RAISE MSC_ATP_PVT.ALLOC_ATP_INVALID_PROFILE;

    WHEN OTHERS THEN
        temp := SQLCODE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Get_Mater, sqlcode= '||temp);
            msc_sch_wb.atp_debug ('Get_Material_Atp_Info: IN Exception Block in others');
            msc_sch_wb.atp_debug ('error := ' || SQLERRM);
        END IF;
        --bug3583705 commenting this out as this resets the FND_MESSAGE.SET_NAME
        /*IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Get_Material_Atp_Info');
        END IF;*/

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Material_Atp_Info;

/*
 * dsting: 9/16/2002. S/D performance enh using temp table
 *
 * x_atp_supply_demand never gets populated
 *
 */
PROCEDURE Insert_Details (
  p_instance_id         IN    NUMBER,
  p_plan_id             IN    NUMBER,
  p_level               IN    NUMBER,
  p_identifier          IN    NUMBER,
  p_scenario_id         IN    NUMBER,
  p_request_item_id     IN    NUMBER,
  p_inventory_item_id   IN    NUMBER,
  p_organization_id     IN    NUMBER,
  p_demand_class        IN    VARCHAR2,
  p_insert_flag         IN    NUMBER,
  x_atp_period          OUT   NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   OUT   NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT   NoCopy VARCHAR2,
  p_get_mat_in_rec      In    MSC_ATP_REQ.get_mat_in_rec,
  p_atf_date            IN    DATE      -- For time_phased_atp
)

IS
i PLS_INTEGER;
j PLS_INTEGER;
l_null_num  number := null;
l_null_char    varchar2(3) := null;
l_infinite_time_fence_date DATE;
l_sysdate_seq_num               NUMBER;
l_sys_next_date                 DATE;
l_default_atp_rule_id           NUMBER;
l_calendar_code                 VARCHAR2(14);
l_calendar_exception_set_id     NUMBER;
l_default_demand_class          VARCHAR2(34);
l_request_item_id               NUMBER;

l_org_code                      VARCHAR2(7);
--bug3583705
--NO_MATCHING_CAL_DATE            EXCEPTION;

l_sysdate			DATE := trunc(sysdate);  --4135752

-- time_phased_atp
l_time_phased_atp               VARCHAR2(1):= 'N';
l_return_status                 VARCHAR2(1);

Begin

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Insert_Details Procedure *****');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_insert_flag >0 THEN

     /* time_phased_atp changes begin*/
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Insert_Details: ' || 'p_atf_date := ' || p_atf_date);
     END IF;
     IF (MSC_ATP_PVT.G_INV_CTP = 4) and (p_inventory_item_id <> p_request_item_id) and (p_atf_date is null) THEN
         l_request_item_id := p_inventory_item_id;
     ELSIF (MSC_ATP_PVT.G_INV_CTP = 4) and (p_inventory_item_id <> p_request_item_id) and (p_atf_date is not null) THEN
         l_request_item_id := p_request_item_id;
         l_time_phased_atp := 'Y';
     ELSE
         l_request_item_id := p_request_item_id;
     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Insert_Details: ' || 'p_request_item_id := ' || p_request_item_id);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'p_inventory_item_id := ' || p_inventory_item_id);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'l_request_item_id := ' || l_request_item_id);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'Time Phased ATP = ' || l_time_phased_atp);
     END IF;
     /* time_phased_atp changes end*/

     --diag_atp
     /*l_infinite_time_fence_date := MSC_ATP_FUNC.get_infinite_time_fence_date(p_instance_id,
             p_inventory_item_id,p_organization_id,p_plan_id);
     */
     l_infinite_time_fence_date := p_get_mat_in_rec.infinite_time_fence_date;
     /* --bug 2287148
         l_sysdate_seq_num := MSC_ATP_FUNC.NEXT_WORK_DAY_SEQNUM(p_organization_id,
                                              p_instance_id,
                                              sysdate);
     */
     -- for performance reason, we need to get the following info and
     -- store in variables instead of joining it

     /* Modularize Item and Org Info */
     -- changed call, re-use info already obtained.
     MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
     l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
     l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
     l_calendar_exception_set_id :=
                            MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
     l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
     l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
     /*Modularize Item and Org Info */

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Insert_Details: ' || 'l_default_atp_rule_id='|| l_default_atp_rule_id);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'l_calendar_code='||l_calendar_code);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'l_calendar_exception_set_id'|| l_calendar_exception_set_id);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'l_default_demand_class'|| l_default_demand_class);
     END IF;

     --Bug 2287148
     BEGIN
        SELECT cal.next_seq_num,cal.next_date
        INTO   l_sysdate_seq_num,l_sys_next_date
        FROM   msc_calendar_dates  cal
        WHERE  cal.exception_set_id = l_calendar_exception_set_id
        AND    cal.calendar_code = l_calendar_code
        AND    cal.calendar_date = TRUNC(sysdate)
        AND    cal.sr_instance_id = p_instance_id ;
     EXCEPTION
        WHEN OTHERS THEN
           --RAISE NO_MATCHING_CAL_DATE; bug3583705
           RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;

     END;
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Insert_Details: ' || 'System Next Date is : '|| l_sys_next_date);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'Sequence Number Is :'|| l_sysdate_seq_num);
        msc_sch_wb.atp_debug('Insert_Details: ' || 'before select');
     END IF;

	MSC_ATP_DB_UTILS.Clear_SD_Details_temp();

        --- bug 2152184: compare p_inventory_item_id and l_request_item_id
        -- previous condition : p_inventory_item_id = p_request_item_id
        -- 2859130
        IF p_inventory_item_id = l_request_item_id THEN
           get_mat_avail_dtls(
                 MSC_ATP_PVT.G_OPTIMIZED_PLAN,
                 p_inventory_item_id,
                 p_request_item_id,
                 p_organization_id,
                 p_instance_id,
                 p_plan_id,
                 l_calendar_code,
                 l_calendar_exception_set_id,
                 l_sysdate_seq_num,
                 l_sys_next_date,
                 p_demand_class,
                 l_default_atp_rule_id,
                 l_default_demand_class,
                 l_infinite_time_fence_date,
                 p_level,
                 p_scenario_id,
                 p_identifier
           );
        ELSE
           -- time_phased_atp
           MSC_ATP_PF.Get_Mat_Avail_Pf_Dtls(
                 p_inventory_item_id,
                 p_request_item_id,
                 p_organization_id,
                 p_instance_id,
                 p_plan_id,
                 l_calendar_code,
                 l_sysdate_seq_num,
                 l_sys_next_date,
                 p_demand_class,
                 l_default_atp_rule_id,
                 l_default_demand_class,
                 l_infinite_time_fence_date,
                 p_level,
                 p_scenario_id,
                 p_identifier,
                 l_return_status
           );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Details: ' || 'Error occured in procedure Get_Mat_Avail_Pf_Dtls');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Insert_Details: ' || 'after inserting into msc_atp_sd_details_temp');
           msc_sch_wb.atp_debug('Insert_Details: ' || 'Total Supply/Demand Recs : '|| SQL%ROWCOUNT);
        END IF;

        -- time_phased_atp
        IF l_time_phased_atp = 'Y' THEN
	    MSC_ATP_PF.get_period_data_from_SD_temp(x_atp_period, l_return_status);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Details: ' || 'Error occured in procedure Get_Period_Data_From_Sd_Temp');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
	ELSE
	    MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);
	END IF;

        x_atp_period.Cumulative_Quantity := x_atp_period.Period_Quantity;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Insert_Details: ' || 'before atp_consume');
        END IF;

        -- time_phased_atp changes begin
        Print_Dates_Qtys(x_atp_period.Period_Start_Date, x_atp_period.Cumulative_Quantity);

        IF l_time_phased_atp = 'Y' THEN
            MSC_ATP_PF.pf_atp_consume(
                   x_atp_period.Cumulative_Quantity,
                   l_return_status,
                   x_atp_period.Period_Start_Date,
                   MSC_ATP_PF.Bw_Fw_Cum, --b/w, f/w consumption and accumulation
                   p_atf_date);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Insert_Details: ' || 'Error occured in procedure pf_atp_consume');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
            END IF;
        -- time_phased_atp changes end
        ELSE
            MSC_ATP_PROC.atp_consume(x_atp_period.Cumulative_Quantity,
                   x_atp_period.Cumulative_Quantity.COUNT);
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Insert_Details: ' || 'after atp_consume');
        END IF;

        /* Cum drop issue changes begin*/
        MSC_AATP_PROC.Atp_Remove_Negatives(x_atp_period.Cumulative_Quantity, l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('Get_Material_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        /* Cum drop issue changes end*/

        IF l_infinite_time_fence_date IS NOT NULL THEN
        	MSC_ATP_PROC.add_inf_time_fence_to_period(
        		p_level,
        		p_identifier,
        		p_scenario_id,
        		p_inventory_item_id,
        		p_request_item_id,
        		p_organization_id,
        		null,  -- p_supplier_id
        		null,  -- p_supplier_site_id
        		l_infinite_time_fence_date,
        		x_atp_period
        	);
        END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Insert_Details Procedure *****');
  END IF;

END Insert_Details;

PROCEDURE Get_Res_Requirements (
    p_instance_id           IN      NUMBER,
    p_plan_id               IN      NUMBER,
    p_level                 IN      NUMBER,
    p_scenario_id           IN      NUMBER,
    p_inventory_item_id     IN      NUMBER,
    p_organization_id       IN      NUMBER,
    p_parent_pegging_id     IN      NUMBER,
    p_requested_quantity    IN      NUMBER,
    p_requested_date        IN      DATE,
    p_refresh_number        IN      NUMBER,
    p_insert_flag           IN      NUMBER,
    p_search                IN      NUMBER,
    p_demand_class          IN      VARCHAR2,
    --(ssurendr) Bug 2865389 Added routing Sequence id and Bill sequence id for OPM issue.
    p_routing_seq_id        IN      NUMBER,
    p_bill_seq_id           IN      NUMBER,
    p_parent_ship_date      IN      DATE,       -- Bug 2814872 Cut-off Date for Resource Check
    p_line_identifier       IN      NUMBER,     -- CTO ODR Identifies the line being processed.
    x_avail_assembly_qty    OUT     NoCopy NUMBER,
    x_atp_date              OUT     NoCopy DATE,
    x_atp_period            OUT     NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
    x_atp_supply_demand     OUT     NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    x_return_status         OUT     NoCopy VARCHAR2
)
IS
l_res_requirements 		MRP_ATP_PVT.Atp_Res_Typ;
l_atp_period_tab                MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_atp_qty_tab                   MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_requested_date_quantity	number;
l_resource_id			number;
l_department_id 		number;
l_requested_date 		date;
l_resource_usage 		number;
l_basis_type 			number;
l_efficiency                    number;
l_utilization                   number;
l_requested_res_qty		number;
l_op_seq_num     		number;
l_avail_assembly_qty		number;
l_next_period			date;
i				PLS_INTEGER;
j				PLS_INTEGER;
k                               PLS_INTEGER;
m                               PLS_INTEGER;
/************ BUG 2313497, 2126520  ************/
h                               PLS_INTEGER;
res_count                       PLS_INTEGER;
l_lead_time                     number;
/************ BUG 2313497, 2126520  ************/
/*  Bug  3348095  */
l_res_start_date                DATE := NULL;
-- Variable to store the start date.
/*  Bug  3348095  */
l_atp_comp_flag			VARCHAR2(1);
l_supply_id                     number;
l_transaction_id                number;
l_pegging_rec			mrp_atp_details_temp%ROWTYPE;
l_resource_hours                number;
l_pegging_id                    number;
l_null_num                      number := null;
l_null_char                     varchar2(3) := null;
l_infinite_time_fence_date      DATE;
-- Bug 3036513, Place holder for out parameter in get_infinite_time_fence_date.
l_atp_rule_name                 VARCHAR2(80);
-- End Bug 3036513
l_return_status                 VARCHAR2(1);
l_atp_period                    MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand             MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_null_atp_period               MRP_ATP_PUB.ATP_Period_Typ;
l_null_atp_supply_demand        MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_res_atp_date                  date;
l_res_atp_qty                   number;
l_uom_code                      varchar2(10);
l_plan_id                       NUMBER;
l_assign_set_id                 NUMBER;
l_use_bor                       NUMBER;
l_org_code                      VARCHAR2(7);
l_resource_code                 VARCHAR2(16);--4774169
l_department_code               VARCHAR2(10);  -- 1487344
l_default_atp_rule_id           NUMBER;
l_calendar_code                 VARCHAR2(14);
l_calendar_exception_set_id     NUMBER;
l_default_demand_class          VARCHAR2(34);
l_demand_class                  VARCHAR2(34);  -- Bug 2424357
l_atp_info                      MRP_ATP_PVT.ATP_Info;
l_inv_item_id                   NUMBER;
l_parent_line_id                NUMBER;  --  CTO Option Dependent Resources ODR
l_routing_seq_id                NUMBER;  --  CTO Option Dependent Resources ODR
l_routing_Type						  NUMBER;
l_routing_number                NUMBER;
l_inventory_item_id				  NUMBER;
l_MSO_Batch_Flag                  VARCHAR2(1);
l_constraint_plan               NUMBER;
l_use_batching                  NUMBER;
l_max_capacity                  NUMBER;
l_batchable_flag                NUMBER;
l_req_unit_capacity             NUMBER;
l_req_capacity_uom              VARCHAR2(3);
l_std_op_code                   VARCHAR2(7);
l_item_conversion_rate		number :=1;
l_res_conversion_rate           number :=1;
l_uom_type			number;
l_res_uom                       varchar2(3);
l_assembly_quantity             number := 1;
l_mso_lead_time_factor          number;
l_res_qty_before_ptf            number;
l_plan_start_date               date;
-- Bug 2372577
l_msc_cap_allocation            VARCHAR2(1);
-- Bug 4108546
-- Variable to track PL/SQL Index when l_res_qty_before_ptf is set.
l_res_ptf_indx                  NUMBER;

--diag_atp
l_owning_department_code        VARCHAR2(10);
l_allocation_rule_name          VARCHAR2(30);

l_sysdate DATE := sysdate;

-- 2869380
l_rounding_flag                 number;

l_batching_flag                 number;
l_item_info_rec                 MSC_ATP_PVT.item_attribute_rec;

-- for summary enhancement
l_summary_flag  NUMBER;
l_summary_sql   VARCHAR2(1);

-- Bug 3432530 Obtain Item Data into local variables.
l_item_fixed_lt                 NUMBER;
l_item_var_lt                   NUMBER;
l_item_unit_vol                 NUMBER;
l_item_unit_wt                  NUMBER;
l_item_vol_uom                  VARCHAR2(3);
l_item_wt_uom                   VARCHAR2(3);
-- End Bug 3432530
--bug 3516835
CONST_USE_BOR CONSTANT NUMBER := 2;
l_network_scheduling_method    NUMBER; --bug3601223
--4198893,4198445
l_res_availability_date        date;

l_unadj_resource_hours         NUMBER; --5093604
l_touch_time                   NUMBER; --5093604

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Get_Res_Requirements Procedure *****');
    END IF;
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_uom_code := NVL(fnd_profile.value('MSC:HOUR_UOM_CODE'),
                      fnd_profile.value('BOM:HOUR_UOM_CODE'));
    l_MSO_Batch_flag := NVL(fnd_profile.value('MSO_BATCHABLE_FLAG'),'N');
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'mso batchable flag := ' || l_MSO_Batch_flag );
    END IF;

    -- 3027711
    -- for performance reason, we need to get the following info and
    -- store in variables instead of joining it

    /* Modularize Item and Org Info */
    -- changed call, re-use info already obtained.
    MSC_ATP_PROC.get_global_org_info(p_instance_id, p_organization_id);
    l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
    l_calendar_code := MSC_ATP_PVT.G_ORG_INFO_REC.cal_code;
    l_calendar_exception_set_id := MSC_ATP_PVT.G_ORG_INFO_REC.cal_exception_set_id;
    l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
    l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
    l_network_scheduling_method := MSC_ATP_PVT.G_ORG_INFO_REC.network_scheduling_method; --bug3601223
    /*Modularize Item and Org Info */

      /* Modularize Item and Org Info */
      -- Move the item fetch outside of the IF ELSE for BOR
      MSC_ATP_PROC.get_global_item_info(p_instance_id,
                                        --3917625: Read data from the plan
                                        -- -1,
                                        p_plan_id,
                                        p_inventory_item_id,
                                        p_organization_id,
                                        l_item_info_rec);
    -- 2869830
    l_rounding_flag := nvl(MSC_ATP_PVT.G_ITEM_INFO_REC.rounding_control_type,
2);
    -- initially set the x_avail_assembly_qty to the p_request_quantity,
    -- and we adjust that later

    -- 2869830
    IF l_rounding_flag = 1 THEN
       x_avail_assembly_qty := CEIL(p_requested_quantity);
    ELSE
       x_avail_assembly_qty := trunc(p_requested_quantity, 6) ;		--5598066
    END IF;

    -- 2178544
    --x_atp_date := sysdate;
    x_atp_date := GREATEST(p_requested_date, MSC_ATP_PVT.G_FUTURE_ORDER_DATE, MSC_ATP_PVT.G_FUTURE_START_DATE);

    IF (p_routing_seq_id is null) AND
       (MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type <> 1 )THEN
        RETURN;
    END IF;
    -- end 3027711

    Begin

    --3516835: Honor plan options to see if routing or BOR need to be used
    --SELECT decode(designator_type, 2, 1, 0),
    SELECT decode(daily_rtg_aggregation_level, CONST_USE_BOR, 1, 0),
           DECODE(plans.plan_type, 4, 2,
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 2)
                           )
                         )
                       )
                     )
                   )
                 ),
           DECODE(l_MSO_Batch_Flag, 'Y', DECODE(plans.plan_type, 4, 0,2,0,  -- filter out MPS plans
             DECODE(daily_material_constraints, 1, 1,
               DECODE(daily_resource_constraints, 1, 1,
                 DECODE(weekly_material_constraints, 1, 1,
                   DECODE(weekly_resource_constraints, 1, 1,
                     DECODE(period_material_constraints, 1, 1,
                       DECODE(period_resource_constraints, 1, 1, 0)
                           )
                         )
                       )
                     )
                   )
                 ), 0),
           plans.summary_flag              -- for summary enhancement
    INTO   l_use_bor, MSC_ATP_PVT.G_OPTIMIZED_PLAN, l_constraint_plan, l_summary_flag
    FROM   msc_designators desig,
           msc_plans plans
    WHERE  plans.plan_id = p_plan_id
    AND    desig.designator = plans.compile_designator
    AND    desig.sr_instance_id = plans.sr_instance_id
    AND    desig.organization_id = plans.organization_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
           l_use_bor := 0;
           MSC_ATP_PVT.G_OPTIMIZED_PLAN := 2;
           l_constraint_plan := 0;
    END;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_bor = '||l_use_bor);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_OPTIMIZED_PLAN = '||MSC_ATP_PVT.G_OPTIMIZED_PLAN);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_constaint_plan  =' || l_constraint_plan);
    END IF;
    IF (l_MSO_Batch_Flag = 'Y') and (l_use_bor = 0) and (l_constraint_plan = 1) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Do Batching');
        END IF;
        l_use_batching := 1;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'No Batching');
        END IF;
        l_use_batching := 0;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_batching =' || l_use_batching);
    END IF;

    -- Check if full summary has been run - for summary enhancement
    IF MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y' AND
        l_summary_flag NOT IN (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN, MSC_POST_PRO.G_SF_PREALLOC_COMPLETED,
                               MSC_POST_PRO.G_SF_FULL_SUMMARY_RUNNING) THEN
        -- Summary SQL can be used
        l_summary_sql := 'Y';
    ELSE
        -- Use the SQL for non summary case
        l_summary_sql := 'N';
    END IF;

    l_null_atp_period := x_atp_period;
    l_null_atp_supply_demand := x_atp_supply_demand;
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_uom_code = ' || l_uom_code);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_insert_flag = '||p_insert_flag);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_instance_id = '||p_instance_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_plan_id = '||p_plan_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_level = '||p_level);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_scenario_id = '||p_scenario_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_inventory_item_id = '||p_inventory_item_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_organization_id = '||p_organization_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_parent_pegging_id = '||p_parent_pegging_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_requested_quantity = '||p_requested_quantity);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_requested_date = '||p_requested_date);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_refresh_number = '||p_refresh_number);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_search = '||p_search);
       -- Then add the latest parameter
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_bill_seq_id = '|| p_bill_seq_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_parent_ship_date = '|| p_parent_ship_date);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'p_line_identifier = '|| p_line_identifier);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' ||
           'MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type= '||
                    MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type);
       --bug3601223
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_network_scheduling_method = '|| l_network_scheduling_method);
       -- End Bug 2814872
    END IF;
    --- get msc_lead_time factor
    l_mso_lead_time_factor := MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR;

    -- CTO Option Dependent Resources ODR
    l_parent_line_id := NULL;
    -- Set Destination Inventory Item Id
    l_inventory_item_id  :=  MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;
    -- Bug 3432530 Obtain Item Data into local variables.
    l_item_fixed_lt      :=  MSC_ATP_PVT.G_ITEM_INFO_REC.fixed_lt;
    l_item_var_lt        :=  MSC_ATP_PVT.G_ITEM_INFO_REC.variable_lt;
    l_item_unit_vol      :=  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume;
    l_item_unit_wt       :=  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight;
    --Bug 3976771 assigned correct values to local variables.
    --l_item_vol_uom       :=  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume;
    --l_item_wt_uom        :=  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight;
    l_item_vol_uom       :=  MSC_ATP_PVT.G_ITEM_INFO_REC.volume_uom;
    l_item_wt_uom        :=  MSC_ATP_PVT.G_ITEM_INFO_REC.weight_uom;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_fixed_lt = '
                                                            || l_item_fixed_lt);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_var_lt = '
                                                            || l_item_var_lt);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_unit_vol = '
                                                            ||l_item_unit_vol);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_unit_wt  = '
                                                            ||l_item_unit_wt);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_wt_uom = '
                                                            ||l_item_wt_uom);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_vol_uom  = '
                                                            ||l_item_vol_uom);
    END IF;
    -- End Bug 3432530
    IF MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type in (1, 2) THEN
          BEGIN
             -- Bug 3358981
             -- Default the ATO_PARENT_MODEL_LINE_ID for models to line_id
             SELECT DECODE(MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type, 1,
                            p_line_identifier, ATO_PARENT_MODEL_LINE_ID)
             -- End Bug 3358981
             INTO   l_parent_line_id
             FROM   msc_cto_bom
             WHERE  line_id = p_line_identifier
             AND    session_id = MSC_ATP_PVT.G_SESSION_ID
             AND    sr_inventory_item_id = p_inventory_item_id;

             -- Common Routing check
             IF p_routing_seq_id IS NOT NULL THEN
                 l_routing_seq_id := p_routing_seq_id;
             ELSE
                 SELECT routing_sequence_id
                 INTO   l_routing_seq_id
                 FROM   msc_routings
                 WHERE  sr_instance_id = p_instance_id
                 AND    plan_id = p_plan_id
                 AND    organization_id = p_organization_id
                 AND    assembly_item_id = l_inventory_item_id;
             END IF;

          EXCEPTION
            WHEN OTHERS THEN
                l_parent_line_id := NULL;
          END;
    ELSE
       l_routing_seq_id := p_routing_seq_id;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_parent_line_id= '|| l_parent_line_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_inventory_item_id= '|| l_inventory_item_id);
       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_routing_sequence_id= '|| l_routing_seq_id);
    END IF;
    -- End CTO Option Dependent Resources ODR
    -- 3027711 moved getting item/org info to beginning

    IF (l_use_bor <> 1) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'not using BOR');
      END IF;
      -- get resource requirements
     	-- OSFM changes
      l_inventory_item_id  :=  MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;
      /*Modularize Item and Org Info */
    	-- get the routing flag to determine the type of routing
      BEGIN
         SELECT cfm_routing_flag, routing_sequence_id
         INTO   l_routing_type,l_routing_number
      	 FROM   msc_routings
         WHERE  plan_id = p_plan_id and
                organization_id = p_organization_id and
                sr_instance_id = p_instance_id and
                assembly_item_id = l_inventory_item_id and
                routing_sequence_id = l_routing_seq_id;  -- CTO ODR
                --routing_sequence_id = p_routing_seq_id;
                --(ssurendr) Bug 28655389 removed the alternate routing desgnator
                --condition for OPM fix.
      EXCEPTION
      	WHEN OTHERS THEN
         	l_routing_type := null;
      END;


      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'cfm_routing_flag= '|| l_routing_type);
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'routing sequence id = ' || l_routing_number);
       END IF;
      IF l_routing_type = 3 THEN --- network routing

       -- CTO Option Dependent Resources
       -- Option Dependent Routing ODR Determination
       IF MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type in (1, 2) THEN
      	SELECT  DISTINCT            -- collapse common into one in case union all is used.
                -- Uncomment: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                department_id,
                owning_department_id,
        	resource_id,
           	basis_type,
           	resource_usage,
           	requested_date,
           	lead_time,
           	efficiency,
           	utilization,
                batch_flag,
                max_capacity,
                required_unit_capacity,
                required_capacity_uom,
                res_uom,
                res_uom_type,
                std_op_code,
                --diag_atp
                resource_offset_percent,
                operation_sequence,
                actual_resource_usage,
                reverse_cumulative_yield,
                department_code,
                resource_code

      	BULK COLLECT INTO l_res_requirements.department_id,
                      l_res_requirements.owning_department_id,
                      l_res_requirements.resource_id,
                      l_res_requirements.basis_type,
                      l_res_requirements.resource_usage,
                      l_res_requirements.requested_date,
                      l_res_requirements.lead_time,
                      l_res_requirements.efficiency,
                      l_res_requirements.utilization,
                      --- these columns have been added for resource batching
                      l_res_requirements.batch_flag,
                      l_res_requirements.max_capacity,
                      l_res_requirements.required_unit_capacity,
                      l_res_requirements.required_capacity_uom,
                      l_res_requirements.res_uom,
                      l_res_requirements.res_uom_type,
                      l_res_requirements.std_op_code,
                      ---diag_atp
                      l_res_requirements.resource_offset_percent,
                      l_res_requirements.operation_sequence,
                      l_res_requirements.actual_resource_usage,
                      l_res_requirements.reverse_cumulative_yield,
                      l_res_requirements.department_code,
                      l_res_requirements.resource_code
      	FROM (
         -- First select mandatory operations
         -- for common routing cases the mandatory for option classes
         -- will be clubbed together with the model.
       	 SELECT   /*+ ordered */ DISTINCT  DR.DEPARTMENT_ID department_id,
                  -- Distinct: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)*
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0*
                        --bug3601223 Only if network_scheduling_method is planning percent then use % else 100%
                        Decode(l_network_scheduling_method,2,
                        (NVL(OP.NET_PLANNING_PERCENT,100)/100),1)
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
                	C2.CALENDAR_DATE requested_date,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's lead times.
                	CEIL(((NVL(l_item_fixed_lt,0)+
                        NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                        --  End Bug 3432530 Use local variables.
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's item data.
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_unit_wt, 2, l_item_unit_vol) required_unit_capacity,
                        ---bug 1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_wt_uom, 2, l_item_vol_uom) required_capacity_uom ,
                        --  End Bug 3432530 Use local variables.
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield ,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield ,--4694958
                        DR.Department_code department_code,
                        DR.resource_code resource_code

       	FROM
                	MSC_CTO_BOM  mcbom1,
                        -- MSC_SYSTEM_ITEMS I, Bug 3432530 Comment out Join table
                	MSC_ROUTINGS RTG,
                	MSC_ROUTING_OPERATIONS OP,
                	MSC_OPERATION_RESOURCE_SEQS SEQ,
                	MSC_OPERATION_RESOURCES RES,
                        MSC_DEPARTMENT_RESOURCES DR, -- this is the sharing dept
                	MSC_CALENDAR_DATES C1,
                	MSC_CALENDAR_DATES C2

       	WHERE    mcbom1.session_id = MSC_ATP_PVT.G_SESSION_ID
        AND      mcbom1.sr_instance_id = p_instance_id
                 -- Bug 3358981 line is a model then include,
        AND      (mcbom1.ATO_PARENT_MODEL_LINE_ID = l_parent_line_id OR mcbom1.line_id = l_parent_line_id)
                 -- get all lines having the same parent model End Bug 3358981
        AND      (  --mcbom1.parent_line_id = p_line_identifier or
                    -- Handle situation when parent_line_id is null.
                    -- Basic thing is that this section should handle all cases.
                    mcbom1.inventory_item_id = l_inventory_item_id )
        AND      mcbom1.quantity <> 0
        -- Get the routing
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID =  mcbom1.sr_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
--       	AND      RTG.ROUTING_SEQUENCE_ID = p_routing_seq_id -- Local var for common and others
                 -- Bug 3432530
                 -- Comment out join conditions for msc_system_items
                  -- 3358981 Eliminate semi cartesian product, streamline query.
        AND      RTG.assembly_item_id = mcbom1.inventory_item_id
        -- Join to system items
        -- AND      I.PLAN_ID = RTG.PLAN_ID
        -- AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        -- AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
        -- AND      I.INVENTORY_ITEM_ID = RTG.assembly_item_id
                   -- 3358981 Eliminate semi cartesian product, streamline query.
        -- AND      I.INVENTORY_ITEM_ID = l_inventory_item_id
                 -- End Bug 3432530
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
        --  Get all operations for the routing
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
        /* Operation is of type Event (Do not select process) */
        and      NVL(OP.operation_type,1 ) = 1
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
        	         	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
         	      	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
                 -- SMCs/Mandatory Operations
        AND      OP.option_dependent_flag = 2
                 -- for the configuration
        -- Obtain the Resource Seq numbers.
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
                 -- Bug 3432530 Use RTG instead of MSC_SYSTEM_ITEMS I
       	AND      C1.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
                 --  Bug 3432530 Use local variables.
                 --  In case of common routing, use model's lead times.
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(l_item_fixed_lt,0)+
                    NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                       (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
                 -- End Bug 3432530
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696  -- cchen
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan: 2408696 - agilent
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = RTG.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      DR.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
        -- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
       	--bug3601223 get the operations that lie on primary path
       	AND      (l_network_scheduling_method = 2
       	OR
       	         OP.OPERATION_SEQUENCE_ID IN
                              ( SELECT FROM_OP_SEQ_ID
                                FROM  MSC_OPERATION_NETWORKS
                                WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
--				AND    ROUTING_SEQUENCE_ID = p_routing_seq_id
				AND    TRANSITION_TYPE = 1

                                UNION ALL

                                SELECT TO_OP_SEQ_ID
				FROM  MSC_OPERATION_NETWORKS
				WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
--				AND    ROUTING_SEQUENCE_ID = p_routing_seq_id
				AND    TRANSITION_TYPE = 1
			      )
	          )
        UNION -- ALL
         -- Obtain Option Dependent Routing
       	SELECT   /*+ ordered */  DISTINCT DR.DEPARTMENT_ID department_id,
                 -- Distinct: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)*
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0*
                        --bug3601223 Only if network_scheduling_method is planning percent then use % else 100%
                        Decode(l_network_scheduling_method,2,
                              (NVL(OP.NET_PLANNING_PERCENT,100)/100),1)
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
                	C2.CALENDAR_DATE requested_date,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's lead times.
                	CEIL(((NVL(l_item_fixed_lt,0)+
                        NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                        --  End Bug 3432530 Use local variables.
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's item data.
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_unit_wt, 2, l_item_unit_vol) required_unit_capacity,
                        ---bug 1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_wt_uom, 2, l_item_vol_uom) required_capacity_uom ,
                        --  End Bug 3432530 Use local variables.
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield ,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield ,--4694958
                        DR.Department_code department_code,
                        DR.resource_code resource_code

       	FROM
                	MSC_CTO_BOM  mcbom1,
                        MSC_PROCESS_EFFECTIVITY proc,
                        MSC_CTO_BOM  mcbom2,
                        -- MSC_SYSTEM_ITEMS I, Bug 3432530 Comment out Join table
                	MSC_ROUTINGS RTG,
                	MSC_ROUTING_OPERATIONS OP,
                        MSC_BOM_COMPONENTS mbc,
                        MSC_OPERATION_COMPONENTS  moc,
                	MSC_OPERATION_RESOURCE_SEQS SEQ,
                	MSC_OPERATION_RESOURCES RES,
                        MSC_DEPARTMENT_RESOURCES DR, -- this is the sharing dept
                	MSC_CALENDAR_DATES C1,
                	MSC_CALENDAR_DATES C2

       	WHERE    mcbom1.session_id = MSC_ATP_PVT.G_SESSION_ID
        AND      mcbom1.sr_instance_id = p_instance_id
                 -- Bug 3358981 line is a model then include,
        AND      (mcbom1.ATO_PARENT_MODEL_LINE_ID = l_parent_line_id OR mcbom1.line_id = l_parent_line_id)
                 -- get all lines having the same parent model End Bug 3358981
        AND      mcbom1.bom_item_type in (1, 2)
        AND      mcbom1.inventory_item_id =
                       decode(MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type,
                              1, mcbom1.inventory_item_id,
                              2, l_inventory_item_id)
        --AND      (mcbom1.parent_line_id = p_line_identifier or
                    -- Handle situation when parent_line_id is null.
                    -- Basic thing is that this section should handle all cases.
        --            mcbom1.inventory_item_id = l_inventory_item_id )
        -- Join to msc_process_effectivity
        AND      proc.plan_id = p_plan_id
        AND      proc.sr_instance_id = mcbom1.sr_instance_id
        AND      proc.organization_id = p_organization_id
        AND      proc.item_id  = mcbom1.inventory_item_id
                 -- Ensure that only items that have a common routing are processed with
                 -- the model. OC Items having a separate routing will be processed separately.
                 -- This check below with decode on the left side will be removed while
                 -- ones below that achieve the same thing retained if performance is an issue.
        AND      decode(MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type,  1, -- bom_item_type for model
                         NVL(proc.routing_sequence_id, l_routing_seq_id),
--                         NVL(proc.routing_sequence_id, p_routing_seq_id),
                         proc.routing_sequence_id  -- all other cases including option_classes
                       ) =  l_routing_seq_id
        -- Quantity filter
        AND      mcbom1.quantity BETWEEN NVL(proc.minimum_quantity,0) AND
                  DECODE(NVL(proc.maximum_quantity,0),0,99999999,proc.maximum_quantity)
        -- Date Filter
        -- effective date should be greater than or equal to greatest of PTF date,
        -- sysdate and start date, disable date
        -- should be less than or equal to greatest of PTF date, sysdate and start date
        -- Note p_requested_date is used instead of C2.calendar_date currently,
        -- since p_requested_date is used in MSC_ATP_PROC.get_process_effectivity
        -- and also from performance considerations.
        AND   TRUNC(proc.effectivity_date) <=
                          TRUNC(GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        AND   TRUNC(NVL(proc.disable_date,GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1))
               > TRUNC(GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        -- Join again to msc_cto_bom to obtain the components as well.
        AND     mcbom2.sr_instance_id = mcbom1.sr_instance_id
        AND     mcbom2.session_id = mcbom1.session_id
        AND     mcbom2.ato_parent_model_line_id = mcbom1.ATO_PARENT_MODEL_LINE_ID
        AND     NVL(mcbom2.parent_line_id, l_parent_line_id) = mcbom1.line_id
        -- to obtain all option classes that have a common routing.
        -- Get the routing
       	AND      RTG.PLAN_ID = proc.plan_id
       	AND      RTG.SR_INSTANCE_ID =  proc.sr_instance_id -- Qry streamline 3358981
       	AND      RTG.ORGANIZATION_ID = proc.organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID =  NVL(proc.routing_sequence_id,
                                                 RTG.ROUTING_SEQUENCE_ID)
                 -- Bug 3432530
                 -- Comment out join conditions for msc_system_items
                  -- 3358981 Eliminate semi cartesian product, streamline query.
        AND      RTG.assembly_item_id = DECODE (proc.routing_sequence_id, NULL,
                                               proc.item_id, l_inventory_item_id )
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
        -- Join to system items
        -- AND      I.PLAN_ID = RTG.PLAN_ID
        -- AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        -- AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
                 -- Bug 3358981
        -- AND      I.INVENTORY_ITEM_ID = RTG.assembly_item_id
                 -- 3358981 Eliminate semi cartesian product, streamline query.
                 -- Ensure that only items that have a common routing are processed with
                 -- the model. OC Items having a separate routing will be processed separately.
        -- AND      I.INVENTORY_ITEM_ID = DECODE (proc.routing_sequence_id, NULL,
        --                        RTG.assembly_item_id, l_inventory_item_id ) -- model's item_id
                 -- End Bug 3358981
                 -- End Bug 3432530
        --  Get all operations for the routing
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
                 -- filter only on those components that are in the pseudo bom
                 -- AND OP.option_dependent_flag = 1 --
        /* Operation is of type Event (Do not select process) */
        and      NVL(OP.operation_type,1 ) = 1
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
        	         	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
         	      	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
        -- Validate Model's BOM in sales order with model's bom in manufacturing org.
        AND     mbc.sr_instance_id = RTG.sr_instance_id -- Qry streamline 3358981
        AND     mbc.plan_id =  RTG.plan_id
        AND     mbc.organization_id = RTG.organization_id
                -- Bug 3358981
                -- Ensure that only items that have a common routing are processed with
                -- the model. OC Items having a separate routing will be processed separately.
        AND     mbc.bill_sequence_id = DECODE(proc.routing_sequence_id, NULL,
                                                proc.bill_sequence_id, p_bill_seq_id)
                -- End Bug 3358981
        AND     mbc.using_assembly_id = RTG.assembly_item_id -- Qry streamline 3358981
        AND      TRUNC(NVL(MBC.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE,
                         sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
               TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
                     AND      TRUNC(MBC.EFFECTIVITY_DATE) <=
               TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        AND    mbc.inventory_item_id  = mcbom2.inventory_item_id
                 -- Optional Items selected in the Sales Order
                 -- Select the option dependent operations which are needed
                 -- for the configuration
        -- Join to determine all the operations
        and      moc.plan_id = mbc.plan_id
        and      moc.sr_instance_id = mbc.sr_instance_id
        and      moc.organization_id = mbc.organization_id
        and      moc.bill_sequence_id = mbc.bill_sequence_id
        and      moc.component_sequence_id = mbc.component_sequence_id
        and      moc.routing_sequence_id = rtg.routing_sequence_id
        and      moc.operation_sequence_id = OP.operation_sequence_id
        -- Obtain the Resource Seq numbers.
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
                 -- Bug 3432530 Use RTG instead of MSC_SYSTEM_ITEMS I
       	AND      C1.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
                 --  Bug 3432530 Use local variables.
                 --  In case of common routing, use model's lead times.
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(l_item_fixed_lt,0)+
                    NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                       (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
                 -- End Bug 3432530
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696  -- cchen
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan: 2408696 - agilent
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = RTG.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      DR.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
        -- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
        --bug3601223  get the operations that lie on primary path
       	AND      (l_network_scheduling_method = 2
       	OR
       	         OP.OPERATION_SEQUENCE_ID IN
                              ( SELECT FROM_OP_SEQ_ID
                                FROM  MSC_OPERATION_NETWORKS
                                WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
				AND    TRANSITION_TYPE = 1

                                UNION ALL

                                SELECT TO_OP_SEQ_ID
				FROM  MSC_OPERATION_NETWORKS
				WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
				AND    TRANSITION_TYPE = 1
			      )
	          )
	)
        ORDER   BY  requested_date,    -- Bug 2313497 Ensure proper order in fetch
                    operation_sequence, resource_code;
       ELSE -- Not Processing CTO BOM Model or Option Class. ODR
      	SELECT  department_id,
                owning_department_id,
        	resource_id,
           	basis_type,
           	resource_usage,
           	requested_date,
           	lead_time,
           	efficiency,
           	utilization,
                batch_flag,
                max_capacity,
                required_unit_capacity,
                required_capacity_uom,
                res_uom,
                res_uom_type,
                std_op_code,
                --diag_atp
                resource_offset_percent,
                operation_sequence,
                actual_resource_usage,
                reverse_cumulative_yield,
                department_code,
                resource_code

      	BULK COLLECT INTO l_res_requirements.department_id,
                      l_res_requirements.owning_department_id,
                      l_res_requirements.resource_id,
                      l_res_requirements.basis_type,
                      l_res_requirements.resource_usage,
                      l_res_requirements.requested_date,
                      l_res_requirements.lead_time,
                      l_res_requirements.efficiency,
                      l_res_requirements.utilization,
                      --- these columns have been added for resource batching
                      l_res_requirements.batch_flag,
                      l_res_requirements.max_capacity,
                      l_res_requirements.required_unit_capacity,
                      l_res_requirements.required_capacity_uom,
                      l_res_requirements.res_uom,
                      l_res_requirements.res_uom_type,
                      l_res_requirements.std_op_code,
                      ---diag_atp
                      l_res_requirements.resource_offset_percent,
                      l_res_requirements.operation_sequence,
                      l_res_requirements.actual_resource_usage,
                      l_res_requirements.reverse_cumulative_yield,
                      l_res_requirements.department_code,
                      l_res_requirements.resource_code
      	FROM (
       	SELECT   /*+ ordered */  DR.DEPARTMENT_ID department_id,
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)*
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0*
                        --bug3601223 Only if network_scheduling_method is planning percent then use % else 100%
                        Decode(l_network_scheduling_method,2,
                        (NVL(OP.NET_PLANNING_PERCENT,100)/100),1)
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
                	C2.CALENDAR_DATE requested_date,
                	CEIL(((NVL(I.FIXED_LEAD_TIME,0)+
                        NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, I.UNIT_VOLUME) required_unit_capacity,
                        ---bug 1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, I.WEIGHT_UOM, 2, I.VOLUME_UOM) required_capacity_uom ,
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield ,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield ,--4694958
                        DR.Department_code department_code,
                        DR.resource_code resource_code

       	FROM
                        -- krajan : 2408696
                        --agilent chnages: since plan already store the data in right uom, we dont need to convert it
                	-- MSC_UOM_CONVERSIONS MUC2,
                	-- MSC_UOM_CONVERSIONS MUC1,
                	MSC_SYSTEM_ITEMS  I,
                	MSC_ROUTINGS RTG,
                	MSC_ROUTING_OPERATIONS OP,
                	MSC_OPERATION_RESOURCE_SEQS SEQ,
                	MSC_OPERATION_RESOURCES RES,
                        MSC_DEPARTMENT_RESOURCES DR, -- this is the sharing dept
                	MSC_CALENDAR_DATES C1,
                	MSC_CALENDAR_DATES C2

       	WHERE    I.PLAN_ID = RTG.PLAN_ID
       	AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      I.INVENTORY_ITEM_ID = RTG.ASSEMBLY_ITEM_ID
       	AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID = p_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
        	         	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
         	      	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
       	AND      C1.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(I.FIXED_LEAD_TIME,0)+
                        NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696  -- cchen
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan: 2408696 - agilent
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = I.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      DR.ORGANIZATION_ID = I.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
        -- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
       	--bug3601223  get the operations that lie on primary path
       	AND      (l_network_scheduling_method = 2
       	OR
       	          OP.OPERATION_SEQUENCE_ID IN
                              ( SELECT FROM_OP_SEQ_ID
                                FROM  MSC_OPERATION_NETWORKS
                                WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
				AND    TRANSITION_TYPE = 1

                                UNION ALL

                                SELECT TO_OP_SEQ_ID
				FROM  MSC_OPERATION_NETWORKS
				WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = l_routing_seq_id
				AND    TRANSITION_TYPE = 1
			      )
	           )

	)
        ORDER   BY  requested_date,   -- Bug 2313497 Ensure proper order in fetch
                    operation_sequence, resource_code;
       END IF;
       -- End CTO Option Dependent Resources ODR
      ELSE -- traditional routing
       -- CTO Option Dependent Resources
       -- Option Dependent Routing ODR Determination
       IF MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type in (1, 2) THEN
      	 SELECT DISTINCT            -- collapse common into one in case union all is used.
                -- Uncomment: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                department_id,
           	owning_department_id,
           	resource_id,
           	basis_type,
           	resource_usage,
           	requested_date,
           	lead_time,
           	efficiency,
           	utilization,
                batch_flag,
                max_capacity,
                required_unit_capacity,
                required_capacity_uom,
                res_uom,
                res_uom_type,
                std_op_code,
                --diag_atp
                resource_offset_percent,
                operation_sequence,
                actual_resource_usage,
                reverse_cumulative_yield,
                department_code,
                resource_code
      	BULK COLLECT INTO l_res_requirements.department_id,
                      	l_res_requirements.owning_department_id,
                      	l_res_requirements.resource_id,
                      	l_res_requirements.basis_type,
                      	l_res_requirements.resource_usage,
                      	l_res_requirements.requested_date,
                      	l_res_requirements.lead_time,
                      	l_res_requirements.efficiency,
                      	l_res_requirements.utilization,
                        --- the following columns are added for resource batching
                        l_res_requirements.batch_flag,
                        l_res_requirements.max_capacity,
                        l_res_requirements.required_unit_capacity,
                        l_res_requirements.required_capacity_uom,
			l_res_requirements.res_uom,
                        l_res_requirements.res_uom_type,
                        l_res_requirements.std_op_code,
                        ---diag_atp
                        l_res_requirements.resource_offset_percent,
                        l_res_requirements.operation_sequence,
                        l_res_requirements.actual_resource_usage,
                        l_res_requirements.reverse_cumulative_yield,
                        l_res_requirements.department_code,
                        l_res_requirements.resource_code

      	FROM (
         -- First select mandatory operations
         -- for common routing cases the mandatory for option classes
         -- will be clubbed together with the model.
       	SELECT  /*+ ordered */ DISTINCT DR.DEPARTMENT_ID department_id,
                -- Distinct: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
			--(NVL(OP.NET_PLANNING_PERCENT,100)/100)/NVL(OP.REVERSE_CUMULATIVE_YIELD,1) resource_usage,
                	C2.CALENDAR_DATE requested_date,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's lead times.
                	CEIL(((NVL(l_item_fixed_lt,0)+
                        NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                        --  End Bug 3432530 Use local variables.
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's item data.
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_unit_wt, 2, l_item_unit_vol) required_unit_capacity,
                        ---bug 1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_wt_uom, 2, l_item_vol_uom) required_capacity_uom ,
                        --  End Bug 3432530 Use local variables.
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield,--4694958
                        DR.Department_code Department_code,
                        DR.Resource_code Resource_code
        FROM
                	MSC_CTO_BOM  mcbom1,
                        -- MSC_SYSTEM_ITEMS I, Bug 3432530 Comment out Join table
                	MSC_ROUTINGS RTG,
                	MSC_ROUTING_OPERATIONS OP,
                	MSC_OPERATION_RESOURCE_SEQS SEQ,
                	MSC_OPERATION_RESOURCES RES,
                        MSC_DEPARTMENT_RESOURCES DR, -- this is the sharing dept
                	MSC_CALENDAR_DATES C1,
                	MSC_CALENDAR_DATES C2

       	WHERE    mcbom1.session_id = MSC_ATP_PVT.G_SESSION_ID
        AND      mcbom1.sr_instance_id = p_instance_id
                 -- Bug 3358981 line is a model then include,
        AND      (mcbom1.ATO_PARENT_MODEL_LINE_ID = l_parent_line_id OR mcbom1.line_id = l_parent_line_id)
                 -- get all lines having the same parent model End Bug 3358981
        AND      (  --mcbom1.parent_line_id = p_line_identifier or
                    -- Handle situation when parent_line_id is null.
                    -- Basic thing is that this section should handle all cases.
                    mcbom1.inventory_item_id = l_inventory_item_id )
        AND      mcbom1.quantity <> 0
        -- Get the routing
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID = mcbom1.sr_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id -- For common routing this will be null.
                 -- Bug 3432530
                 -- Comment out join conditions for msc_system_items
                  -- 3358981 Eliminate semi cartesian product, streamline query.
        AND      RTG.assembly_item_id = mcbom1.inventory_item_id
        -- Join to system items
        -- AND      I.PLAN_ID = RTG.PLAN_ID
        -- AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        -- AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
        -- AND      I.INVENTORY_ITEM_ID = RTG.assembly_item_id
                 -- 3358981 Eliminate semi cartesian product, streamline query.
        -- AND      I.INVENTORY_ITEM_ID = l_inventory_item_id
                 -- End Bug 3432530
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
        --  Get all operations for the routing
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
         /* Operation is of type Event (Do not select process) */
        and      NVL(OP.operation_type,1 ) = 1
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
                 -- SMCs/Mandatory Operations
        and     OP.option_dependent_flag = 2
                 -- for the configuration
        -- Obtain the Resource Seq numbers.
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
                 -- Bug 3432530 Use RTG instead of MSC_SYSTEM_ITEMS I
       	AND      C1.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
                 --  Bug 3432530 Use local variables.
                 --  In case of common routing, use model's lead times.
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(l_item_fixed_lt,0)+
                    NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                       (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
                 -- End Bug 3432530
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan : 2408696
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = RTG.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        AND     DR.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
	-- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
       	UNION ALL
         -- Obtain Option Dependent Routing
       	SELECT  /*+ ordered */ DISTINCT DR.DEPARTMENT_ID department_id,
                -- Distinct: Bug 3432530 For CTO we obtain the Op. Seq. related data only once.
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
			--(NVL(OP.NET_PLANNING_PERCENT,100)/100)/NVL(OP.REVERSE_CUMULATIVE_YIELD,1) resource_usage,
                	C2.CALENDAR_DATE requested_date,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's lead times.
                	CEIL(((NVL(l_item_fixed_lt,0)+
                        NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                        --  End Bug 3432530 Use local variables.
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        --  Bug 3432530 Use local variables.
                        --  In case of common routing, use model's item data.
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_unit_wt, 2, l_item_unit_vol) required_unit_capacity,
                        ---bug 1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, l_item_wt_uom, 2, l_item_vol_uom) required_capacity_uom ,
                        --  End Bug 3432530 Use local variables.
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield,--4694958
                        DR.Department_code Department_code,
                        DR.Resource_code Resource_code
        FROM
                	MSC_CTO_BOM  mcbom1,
                        MSC_PROCESS_EFFECTIVITY proc,
                        MSC_CTO_BOM  mcbom2,
                        -- MSC_SYSTEM_ITEMS I, Bug 3432530 Comment out Join table
                	MSC_ROUTINGS RTG,
                	MSC_ROUTING_OPERATIONS OP,
                        MSC_BOM_COMPONENTS mbc,
                        MSC_OPERATION_COMPONENTS  moc,
                	MSC_OPERATION_RESOURCE_SEQS SEQ,
                	MSC_OPERATION_RESOURCES RES,
                        MSC_DEPARTMENT_RESOURCES DR, -- this is the sharing dept
                	MSC_CALENDAR_DATES C1,
                	MSC_CALENDAR_DATES C2

       	WHERE    mcbom1.session_id = MSC_ATP_PVT.G_SESSION_ID
        AND      mcbom1.sr_instance_id = p_instance_id
                 -- Bug 3358981 line is a model then include,
        AND      (mcbom1.ATO_PARENT_MODEL_LINE_ID = l_parent_line_id OR mcbom1.line_id = l_parent_line_id)
                 -- get all lines having the same parent model End Bug 3358981
        AND      mcbom1.bom_item_type in (1, 2)
        AND      mcbom1.inventory_item_id =
                       decode(MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type,
                              1, mcbom1.inventory_item_id,
                              2, l_inventory_item_id)
        --AND      (mcbom1.parent_line_id = p_line_identifier or
                    -- Handle situation when parent_line_id is null.
                    -- Basic thing is that this section should handle all cases.
        --            mcbom1.inventory_item_id = l_inventory_item_id )
         -- Join to msc_process_effectivity
        AND      proc.plan_id = p_plan_id
        AND      proc.sr_instance_id = mcbom1.sr_instance_id
        AND      proc.organization_id = p_organization_id
        AND      proc.item_id  = mcbom1.inventory_item_id
                 -- Ensure that only items that have a common routing are processed with
                 -- the model. OC Items having a separate routing will be processed separately.
                 -- This check below with decode on the left side will be removed while
                 -- ones below that achieve the same thing retained if performance is an issue.
        AND      decode(MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type, 1, -- bom_item_type for model
                         NVL(proc.routing_sequence_id, l_routing_seq_id),
                         proc.routing_sequence_id  -- all other cases including option_classes
                       ) =  l_routing_seq_id
        -- Quantity filter
        AND      mcbom1.quantity BETWEEN NVL(proc.minimum_quantity,0) AND
                  DECODE(NVL(proc.maximum_quantity,0),0,99999999,proc.maximum_quantity)
        -- Date Filter
        -- effective date should be greater than or equal to greatest of PTF date,
        -- sysdate and start date, disable date
        -- should be less than or equal to greatest of PTF date, sysdate and start date
        -- Note p_requested_date is used instead of C2.calendar_date currently,
        -- since p_requested_date is used in MSC_ATP_PROC.get_process_effectivity
        -- and also from performance considerations.
        AND   TRUNC(proc.effectivity_date) <=
                          TRUNC(GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        AND   TRUNC(NVL(proc.disable_date,GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1))
               > TRUNC(GREATEST(p_requested_date, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        -- Join again to msc_cto_bom to obtain the components as well.
        AND     mcbom2.sr_instance_id = mcbom1.sr_instance_id
        AND     mcbom2.session_id = mcbom1.session_id
        AND     mcbom2.ato_parent_model_line_id = mcbom1.ATO_PARENT_MODEL_LINE_ID
        AND     NVL(mcbom2.parent_line_id, l_parent_line_id) = mcbom1.line_id
        -- to obtain all option classes that have a common routing.
        -- Get the routing
       	AND      RTG.PLAN_ID = proc.plan_id
       	AND      RTG.SR_INSTANCE_ID = proc.sr_instance_id -- Qry Streamline 3358981
       	AND      RTG.ORGANIZATION_ID = proc.organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = NVL(proc.routing_sequence_id,
                                                 RTG.ROUTING_SEQUENCE_ID)
                 -- Bug 3432530
                 -- Comment out join conditions for msc_system_items
                  -- 3358981 Eliminate semi cartesian product, streamline query.
        AND      RTG.assembly_item_id = DECODE (proc.routing_sequence_id, NULL,
                                               proc.item_id, l_inventory_item_id )
        -- Join to system items
        -- AND      I.PLAN_ID = RTG.PLAN_ID
        -- AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        -- AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
                 -- Bug 3358981
        -- AND      I.INVENTORY_ITEM_ID = RTG.assembly_item_id
                 -- 3358981 Eliminate semi cartesian product, streamline query.
                 -- Ensure that only items that have a common routing are processed with
                 -- the model. OC Items having a separate routing will be processed separately.
        -- AND      I.INVENTORY_ITEM_ID = DECODE (proc.routing_sequence_id, NULL,
        --                        RTG.assembly_item_id, l_inventory_item_id ) -- model's item_id
                 -- End Bug 3358981
                 -- End Bug 3432530
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
        --  Get all operations for the routing
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
                 -- filter only on those components that are in the pseudo bom
                 -- AND OP.option_dependent_flag = 1 --
         /* Operation is of type Event (Do not select process) */
        and      NVL(OP.operation_type,1 ) = 1
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
        -- Validate Model's BOM in sales order with model's bom in manufacturing org.
        AND     mbc.sr_instance_id = RTG.sr_instance_id -- Qry Streamline 3358981
        AND     mbc.plan_id =  RTG.plan_id
        AND     mbc.organization_id = RTG.organization_id
                -- Bug 3358981
                -- Ensure that only items that have a common routing are processed with
                -- the model. OC Items having a separate routing will be processed separately.
        AND     mbc.bill_sequence_id = DECODE(proc.routing_sequence_id, NULL,
                                                proc.bill_sequence_id, p_bill_seq_id)
                -- End Bug 3358981
        AND     mbc.using_assembly_id = RTG.assembly_item_id -- Qry Streamline 3358981
        AND      TRUNC(NVL(MBC.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE,
                         sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
               TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
                     AND      TRUNC(MBC.EFFECTIVITY_DATE) <=
               TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
        AND     mbc.inventory_item_id  = mcbom2.inventory_item_id
                 -- Optional Items selected in the Sales Order
                 -- Select the option dependent operations which are needed.
                 -- for the configuration
        -- Join to determine all the operations
        and     moc.plan_id = mbc.plan_id
        and     moc.sr_instance_id = mbc.sr_instance_id
        and     moc.organization_id = mbc.organization_id
        and     moc.bill_sequence_id = mbc.bill_sequence_id
        and     moc.component_sequence_id = mbc.component_sequence_id
        and     moc.routing_sequence_id = rtg.routing_sequence_id
        and     moc.operation_sequence_id = OP.operation_sequence_id
        -- Obtain the Resource Seq numbers.
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
                 -- Bug 3432530 Use RTG instead of MSC_SYSTEM_ITEMS I
       	AND      C1.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
                 --  Bug 3432530 Use local variables.
                 --  In case of common routing, use model's lead times.
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(l_item_fixed_lt,0)+
                    NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                       (1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
                 -- End Bug 3432530
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan : 2408696
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = RTG.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
        AND     DR.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
	-- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
       	UNION ALL
       	SELECT   RTG.LINE_ID department_id,
                	RTG.LINE_ID owning_department_id ,
                	-1 resource_id,
                	1 basis_type,
                	1 resource_usage,
                	C2.CALENDAR_DATE requested_date,
                	CEIL((NVL(I.FIXED_LEAD_TIME,0)+
                   	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor)) lead_time,
                	1 efficiency,
                	1 utilization,
                        2 batch_flag,
                        0 max_capacity,
                        0 required_unit_capacity,
                        --bug 2845383: Change all direct reference to null to local variables
                        l_null_char required_capacity_uom,
                        l_null_char res_uom,
                        1 res_uom_type,
                        l_null_char std_op_code,
                        --diag_atp
                        l_null_num resource_offset_percent,
                        l_null_num operation_sequence,
                        1 actual_resource_usage,
                        l_null_num reverse_cumulative_yield,
                        l_null_char department_code,
                        l_null_char resource_Code
       	FROM 	MSC_CALENDAR_DATES C2,
                	MSC_CALENDAR_DATES C1,
                	MSC_ROUTINGS RTG,
                	MSC_SYSTEM_ITEMS  I
       	WHERE    I.PLAN_ID = RTG.PLAN_ID
       	AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      I.INVENTORY_ITEM_ID = RTG.ASSEMBLY_ITEM_ID
       	AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID = p_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
       	AND	RTG.CTP_FLAG = 1
       	AND      RTG.LINE_ID IS NOT NULL
       	AND      C1.CALENDAR_DATE = p_requested_date
       	AND      C1.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL((NVL(I.FIXED_LEAD_TIME,0)+
                        	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
      	)
        ORDER by requested_date,     -- Bug 2313497 Ensure proper order in fetch
                    operation_sequence, resource_code;
       ELSE -- Not Processing CTO BOM Model or Option Class. ODR
      	SELECT department_id,
           	owning_department_id,
           	resource_id,
           	basis_type,
           	resource_usage,
           	requested_date,
           	lead_time,
           	efficiency,
           	utilization,
                batch_flag,
                max_capacity,
                required_unit_capacity,
                required_capacity_uom,
                res_uom,
                res_uom_type,
                std_op_code,
                --diag_atp
                resource_offset_percent,
                operation_sequence,
                actual_resource_usage,
                reverse_cumulative_yield,
                department_code,
                resource_code
      	BULK COLLECT INTO l_res_requirements.department_id,
                      	l_res_requirements.owning_department_id,
                      	l_res_requirements.resource_id,
                      	l_res_requirements.basis_type,
                      	l_res_requirements.resource_usage,
                      	l_res_requirements.requested_date,
                      	l_res_requirements.lead_time,
                      	l_res_requirements.efficiency,
                      	l_res_requirements.utilization,
                        --- the following columns are added for resource batching
                        l_res_requirements.batch_flag,
                        l_res_requirements.max_capacity,
                        l_res_requirements.required_unit_capacity,
                        l_res_requirements.required_capacity_uom,
			l_res_requirements.res_uom,
                        l_res_requirements.res_uom_type,
                        l_res_requirements.std_op_code,
                        ---diag_atp
                        l_res_requirements.resource_offset_percent,
                        l_res_requirements.operation_sequence,
                        l_res_requirements.actual_resource_usage,
                        l_res_requirements.reverse_cumulative_yield,
                        l_res_requirements.department_code,
                        l_res_requirements.resource_code

      	FROM (
       	SELECT  /*+ ordered */  DR.DEPARTMENT_ID department_id,
                	DR.OWNING_DEPARTMENT_ID owning_department_id,
                	DR.RESOURCE_ID resource_id,
                	RES.BASIS_TYPE basis_type,
                        --bug 3766224: Do not chnage usage for lot based resource
                        ROUND(DECODE(RES.BASIS_TYPE, 2, NVL(RES.RESOURCE_USAGE,0),
                	(NVL(RES.RESOURCE_USAGE,0)
                        -- krajan : 2408696
                        -- MUC2.CONVERSION_RATE/MUC1.CONVERSION_RATE, 0
                        /DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD,1)))
                        /(Decode (nvl (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG), MSC_ATP_PVT.OPM_ORG, --Bug-4694958
                                  decode (RES.BASIS_TYPE, 3,
                                          NVL(DR.MAX_CAPACITY,1),  nvl(rtg.routing_quantity,1)
                                         ),
                                  nvl(rtg.routing_quantity,1)
                                 )
                         )),6) resource_usage, --4694958
                            -- Bug 2865389 (ssurendr) routing quantity added for OPM fix.
			--(NVL(OP.NET_PLANNING_PERCENT,100)/100)/NVL(OP.REVERSE_CUMULATIVE_YIELD,1) resource_usage,
                	C2.CALENDAR_DATE requested_date,
                	CEIL(((NVL(I.FIXED_LEAD_TIME,0)+
                        	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        	(1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0))) lead_time,
                	NVL((DR.EFFICIENCY/100), 1) efficiency,
                	NVL((DR.UTILIZATION/100), 1) utilization,
                        NVL(DR.BATCHABLE_FLAG, 2) batch_flag,
                        NVL(DR.MAX_CAPACITY,0) max_capacity,
                        DECODE(DR.UOM_CLASS_TYPE, 1, I.UNIT_WEIGHT, 2, I.UNIT_VOLUME) required_unit_capacity,
                        --1905284
                        DECODE(DR.UOM_CLASS_TYPE, 1, I.WEIGHT_UOM, 2, I.VOLUME_UOM) required_capacity_uom,
                        DR.UNIT_OF_MEASURE res_uom,
                        DR.UOM_CLASS_TYPE res_uom_type,
                        OP.STANDARD_OPERATION_CODE std_op_code,
                        --diag_atp
                        SEQ.RESOURCE_OFFSET_PERCENT resource_offset_percent,
                        OP.OPERATION_SEQ_NUM operation_sequence,
                        RES.RESOURCE_USAGE actual_resource_usage,
                        --NVL(OP.REVERSE_CUMULATIVE_YIELD, 1) reverse_cumulative_yield,
                        DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,1,NVL(OP.REVERSE_CUMULATIVE_YIELD, 1)) reverse_cumulative_yield,--4694958
                        DR.Department_code Department_code,
                        DR.Resource_code Resource_code
        FROM
                 MSC_SYSTEM_ITEMS I,
                 MSC_ROUTINGS  RTG,
                 MSC_ROUTING_OPERATIONS OP,
                 MSC_OPERATION_RESOURCE_SEQS SEQ,
                 MSC_OPERATION_RESOURCES RES,
                 MSC_DEPARTMENT_RESOURCES DR,
                 MSC_CALENDAR_DATES C1,
                 MSC_CALENDAR_DATES C2

       	WHERE    I.PLAN_ID = RTG.PLAN_ID
       	AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      I.INVENTORY_ITEM_ID = RTG.ASSEMBLY_ITEM_ID
       	AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID = p_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
       	AND      OP.PLAN_ID = RTG.PLAN_ID
       	AND      OP.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      OP.ROUTING_SEQUENCE_ID = RTG.ROUTING_SEQUENCE_ID
        /* rajjain 3008611
         * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
         * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       	AND      TRUNC(NVL(OP.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       	AND      TRUNC(OP.EFFECTIVITY_DATE) <=
                  	TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
       	AND      SEQ.PLAN_ID = OP.PLAN_ID
       	AND      SEQ.ROUTING_SEQUENCE_ID  = OP.ROUTING_SEQUENCE_ID
       	AND      SEQ.SR_INSTANCE_ID = OP.SR_INSTANCE_ID
       	AND      SEQ.OPERATION_SEQUENCE_ID = OP.OPERATION_SEQUENCE_ID
       	AND      RES.BASIS_TYPE in (1,2,3) --4694958
       	AND      RES.PLAN_ID = SEQ.PLAN_ID
       	AND      RES.ROUTING_SEQUENCE_ID = SEQ.ROUTING_SEQUENCE_ID
       	AND      RES.SR_INSTANCE_ID = SEQ.SR_INSTANCE_ID
       	AND      RES.OPERATION_SEQUENCE_ID = SEQ.OPERATION_SEQUENCE_ID
       	AND      RES.RESOURCE_SEQ_NUM = SEQ.RESOURCE_SEQ_NUM
       	AND      NVL(RES.ALTERNATE_NUMBER, 0) = 0 -- bug 1170698
       	AND      C1.CALENDAR_DATE = p_requested_date
       	AND      C1.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL(((NVL(I.FIXED_LEAD_TIME,0)+
                        	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))*
                        	(1-NVL(SEQ.RESOURCE_OFFSET_PERCENT, 0)))
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID -- krajan : 2408696
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
       	-- krajan : 2408696
        -- AND   	MUC1.UOM_CODE = l_uom_code
       	-- AND   	MUC1.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CLASS = MUC1.UOM_CLASS
       	-- AND   	MUC2.INVENTORY_ITEM_ID = 0
       	-- AND   	MUC2.UOM_CODE = RES.UOM_CODE
        AND      RES.UOM_CODE = l_uom_code
       	AND      DR.PLAN_ID = I.PLAN_ID
       	AND      DR.SR_INSTANCE_ID = I.SR_INSTANCE_ID
        AND     DR.ORGANIZATION_ID = I.ORGANIZATION_ID
       	AND      DR.RESOURCE_ID = RES.RESOURCE_ID
       	AND      DR.DEPARTMENT_ID = OP.DEPARTMENT_ID
	-- performance dsting remove nvl from dr.ctp_flag
       	AND      DR.CTP_FLAG = 1
       	UNION ALL
       	SELECT   RTG.LINE_ID department_id,
                	RTG.LINE_ID owning_department_id ,
                	-1 resource_id,
                	1 basis_type,
                	1 resource_usage,
                	C2.CALENDAR_DATE requested_date,
                	CEIL((NVL(I.FIXED_LEAD_TIME,0)+
                   	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor)) lead_time,
                	1 efficiency,
                	1 utilization,
                        2 batch_flag,
                        0 max_capacity,
                        0 required_unit_capacity,
                        --bug 2845383: Change all direct reference to null to local variables
                        l_null_char required_capacity_uom,
                        l_null_char res_uom,
                        1 res_uom_type,
                        l_null_char std_op_code,
                        --diag_atp
                        l_null_num resource_offset_percent,
                        l_null_num operation_sequence,
                        1 actual_resource_usage,
                        l_null_num reverse_cumulative_yield,
                        l_null_char department_code,
                        l_null_char resource_Code
       	FROM 	MSC_CALENDAR_DATES C2,
                	MSC_CALENDAR_DATES C1,
                	MSC_ROUTINGS RTG,
                	MSC_SYSTEM_ITEMS  I
       	WHERE    I.PLAN_ID = RTG.PLAN_ID
       	AND      I.SR_INSTANCE_ID = RTG.SR_INSTANCE_ID
       	AND      I.INVENTORY_ITEM_ID = RTG.ASSEMBLY_ITEM_ID
       	AND      I.ORGANIZATION_ID = RTG.ORGANIZATION_ID
       	AND      RTG.PLAN_ID = p_plan_id
       	AND      RTG.SR_INSTANCE_ID = p_instance_id
       	AND      RTG.ORGANIZATION_ID = p_organization_id
       	AND      RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
        --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
        --we are accessing Routing by Routing sequance id.
        --We are Driving by routing table for performance gains.
       	--AND      RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
       	AND	RTG.CTP_FLAG = 1
       	AND      RTG.LINE_ID IS NOT NULL
       	AND      C1.CALENDAR_DATE = p_requested_date
       	AND      C1.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C1.CALENDAR_CODE = l_calendar_code
       	AND      C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
       	AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL((NVL(I.FIXED_LEAD_TIME,0)+
                        	NVL(I.VARIABLE_LEAD_TIME,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))
       	AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       	AND      C2.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       	AND      C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
      	)
        ORDER by requested_date,     -- Bug 2313497 Ensure proper order in fetch
                    operation_sequence, resource_code;
       END IF;
       -- End CTO Option Dependent Resources ODR
      END IF;  ---- If l_routing_flag = 3 THEN
     ELSE

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'using BOR');
      END IF;

      -- Added on 01/09/2001 by ngoel for performance improvement
      /* Modularize Item and Org Info */
      l_inv_item_id  :=  MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;
      /* Modularize Item and Org Info */
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Modular change l_inv_item_id : '||l_inv_item_id);
      END IF;

      SELECT b.department_id,
           dr.owning_department_id,
           b.resource_id,
           b.basis,
           DECODE(b.resource_id, -1, 1, b.resource_department_hours),
           c2.calendar_date,
           b.setback_days,
           nvl((dr.efficiency/100), 1),
           nvl((dr.utilization/100), 1),
           --- even though resource batching is not used in case of BOR
           --- the following columns are added because the process
           -- for all cases is done by the same code. Adding following
           --- columns will ensure proper extension of tables
           2 batch_flag,
           0 max_capacity,
           0 required_unit_capacity,
           --2845383: change direct refrence to null to local varibale
           l_null_char required_capacity_uom,
           l_null_char res_uom,
           l_null_char res_uom_type,
           l_null_char  std_op_code,
           --diag_atp
           l_null_num resource_offset_percent,
           l_null_num operation_sequence,
           DECODE(b.resource_id, -1, 1, b.resource_department_hours) actual_resource_usage,
           1 reverse_cumulative_yield,
           dr.department_code department_code,
           dr.resource_code resource_Code

      BULK COLLECT INTO l_res_requirements.department_id,
                      l_res_requirements.owning_department_id,
                      l_res_requirements.resource_id,
                      l_res_requirements.basis_type,
                      l_res_requirements.resource_usage,
                      l_res_requirements.requested_date,
                      l_res_requirements.lead_time,
                      l_res_requirements.efficiency,
                      l_res_requirements.utilization,
                       --- the following columns are added for resource batching
                      l_res_requirements.batch_flag,
                      l_res_requirements.max_capacity,
                      l_res_requirements.required_unit_capacity,
                      l_res_requirements.required_capacity_uom ,
                      l_res_requirements.res_uom,
                      l_res_requirements.res_uom_type,
                      l_res_requirements.std_op_code,
                      ---diag_atp
                      l_res_requirements.resource_offset_percent,
                      l_res_requirements.operation_sequence,
                      l_res_requirements.actual_resource_usage,
                      l_res_requirements.reverse_cumulative_yield,
                      l_res_requirements.department_code,
                      l_res_requirements.resource_code

      FROM msc_department_resources dr,
           msc_bor_requirements b,
           msc_calendar_dates c1,
           msc_calendar_dates c2
      WHERE B.PLAN_ID = p_plan_id
      AND   B.SR_INSTANCE_ID = p_instance_id
      AND   B.ORGANIZATION_ID = p_organization_id
      AND   B.ASSEMBLY_ITEM_ID = l_inv_item_id

	-- Chnaged on 01/09/2001 by ngoel for performance improvement
	-- MSC_ATP_FUNC.get_inv_item_id(p_instance_id, p_inventory_item_id, p_organization_id)
      AND   C1.CALENDAR_DATE = p_requested_date
      AND   C1.SR_INSTANCE_ID = B.SR_INSTANCE_ID
      AND   C1.CALENDAR_CODE = l_calendar_code
      AND   C1.EXCEPTION_SET_ID = l_calendar_exception_set_id
      AND   C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - B.SETBACK_DAYS
      AND   C2.CALENDAR_CODE = C1.CALENDAR_CODE
      AND   C2.SR_INSTANCE_ID = B.SR_INSTANCE_ID
      AND   C2.EXCEPTION_SET_ID = C1.EXCEPTION_SET_ID
      AND   DR.PLAN_ID = B.PLAN_ID
      AND   DR.SR_INSTANCE_ID = B.SR_INSTANCE_ID
      AND   DR.RESOURCE_ID = B.RESOURCE_ID
      AND   DR.DEPARTMENT_ID = B.DEPARTMENT_ID
      AND   DR.ORGANIZATION_ID = B.ORGANIZATION_ID
      -- performance dsting remove nvl from dr.ctp_flag
      AND   DECODE(DR.LINE_FLAG, 1, 1, DR.CTP_FLAG) = 1
      AND   (DR.LINE_FLAG <> 1
            OR
            (DR.LINE_FLAG = 1 AND
             EXISTS ( SELECT 'CTP'
                      FROM   MSC_ROUTINGS RTG
                      WHERE  RTG.PLAN_ID = p_plan_id
      		      AND    RTG.SR_INSTANCE_ID = B.SR_INSTANCE_ID
                      AND    RTG.ASSEMBLY_ITEM_ID = B.ASSEMBLY_ITEM_ID
                      AND    RTG.ORGANIZATION_ID = B.ORGANIZATION_ID
                      AND    RTG.ROUTING_SEQUENCE_ID = l_routing_seq_id
                      --(ssurendr) Bug 2865389 OPM fix
                      -- AND    RTG.ALTERNATE_ROUTING_DESIGNATOR IS NULL
                      AND    RTG.LINE_ID = B.DEPARTMENT_ID
                      AND    NVL(RTG.CTP_FLAG, 2) = 1)))
      ORDER BY C2.CALENDAR_DATE;  -- Bug 2313497 Ensure proper order in fetch


    END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'After getting resource information');
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' ||
               'l_res_requirements.resource_id.COUNT ' || l_res_requirements.resource_id.COUNT);
      END IF;
      -- go over each resource
      j := l_res_requirements.resource_id.FIRST;

      -- if j is null, that means we don't have any resource requirements
      -- need to consider, so we can assume that we have infinite resource
      -- to make the assembly.
      -- otherwise we need to know how many assemblies we can make
      -- by loop through each resource and find the availibility.
      -- If we can make more than the requested quantity, we return
      -- the requested quantity.

      -- initially set the x_avail_assembly_qty to the p_request_quantity,
      -- and we adjust that later

      -- Initialize l_infinite_time_fence_date, since this is pds,
      -- use planning's cutoff date as the infinite time fence date
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'x_atp_date := ' || x_atp_date);
      END IF;
      IF j IS NOT NULL THEN
         ---bug 2341075: read plan start date

         -- Supplier Capacity and Lead Time (SCLT) Proj
         -- Commented out
         -- SELECT curr_cutoff_date, trunc(plan_start_date)
         -- INTO   l_infinite_time_fence_date, l_plan_start_date
         -- FROM   msc_plans
         -- WHERE  plan_id = p_plan_id;

         -- Instead re-assigned local values using global variable
         l_plan_start_date := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_start_date;
         --l_infinite_time_fence_date := MSC_ATP_PVT.G_PLAN_INFO_REC.curr_cutoff_date; (ssurendr) Bug 2865389
         l_infinite_time_fence_date := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_cutoff_date;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Plan Start Date := ' || l_plan_start_date );
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Infinite Time Fence := ' ||
                                                               l_infinite_time_fence_date );
         END IF;
         -- End Supplier Capacity and Lead Time Proj

      END IF;


      ---- bug 1950528
      ---- Get assembly item id if 1) there is resource def 2) MSC_corpod is on 3) Its not a BOR
      IF (j IS NOT NULL) AND (MSC_ATP_PVT.G_PLAN_COPRODUCTS = 'Y') AND (l_use_bor <> 1)
         AND (NVL (MSC_ATP_PVT.G_ORG_INFO_REC.org_type,MSC_ATP_PVT.DISCRETE_ORG) = MSC_ATP_PVT.DISCRETE_ORG) THEN  --Bug-4694958
           BEGIN
              SELECT BOMS.ASSEMBLY_QUANTITY
              INTO l_assembly_quantity
              FROM MSC_BOMS BOMS
              WHERE    BOMS.PLAN_ID  = p_plan_id
              AND      BOMS.SR_INSTANCE_ID  = p_instance_id
              AND      BOMS.ORGANIZATION_ID  = p_organization_id
              AND      BOMS.BILL_SEQUENCE_ID = p_bill_seq_id;
              --(ssurendr) Bug 2865389 Removed condition for Alternate bom designator as
              --we are accessing bom by bill sequance id. Also removed MSC_SYSTEM_ITEMS from the SQL
              --AND      BOMS.ALTERNATE_BOM_DESIGNATOR IS NULL;
           EXCEPTION
              WHEN OTHERS THEN
                  l_assembly_quantity := 1;
           END;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_assembly_quantity := ' || l_assembly_quantity);
      END IF;


      --// BUG 2313497, 2126520
      res_count := l_res_requirements.resource_id.COUNT;
      --// BUG 2313497, 2126520
      WHILE j IS NOT NULL LOOP

         -- Bug 1610561
         -- Now perform infinite_time_fence_date processing for each resource.
         -- First Initialize the infinite_time_fence_date to NULL

         l_infinite_time_fence_date := NULL;

         -- Resource Id and Department ID assignment is moved up to here.

         l_resource_id := l_res_requirements.resource_id(j);
         l_department_id := NVL(l_res_requirements.owning_department_id(j),
                                l_res_requirements.department_id(j));
         -- Now obtain the infinite time fence date if an ATP rule is specified.

         -- Bug 3036513 Get infinite time fence date for resource
         -- Existing SQL commented out.
         -- Call the Library routine that is now common for both items and resources.

         MSC_ATP_PROC.get_infinite_time_fence_date ( p_instance_id,
                                                     l_inv_item_id,
                                                     p_organization_id,
                                                     p_plan_id,
                                                     l_infinite_time_fence_date,
                                                     l_atp_rule_name,
                                                     l_resource_id,
                                                     l_department_id );

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Resource Id := ' ||
                                                                      l_resource_id);
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'New Infinite Time Fence := '
                                                          || l_infinite_time_fence_date );
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Plan Cutoff Date := ' ||
                                                MSC_ATP_PVT.G_PLAN_INFO_REC.plan_cutoff_date);
            msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'ATP RULE NAME for Resource := '
                                                          || l_atp_rule_name );
         END IF;
         -- Bug 3036513

         -- End Bug 1610561

        --diag_atp
        l_pegging_rec.operation_sequence_id := null;
        l_pegging_rec.usage := null;
        l_pegging_rec.offset := null;
        l_pegging_rec.efficiency := null;
        l_pegging_rec.utilization := null;
        l_pegging_rec.REVERSE_CUM_YIELD := null;
        l_pegging_rec.owning_department := null;
        l_pegging_rec.pegging_type := null;
        l_pegging_rec.required_quantity:=null;
        l_pegging_rec.required_date := null;
        l_pegging_rec.basis_type := null;
        l_pegging_rec.allocation_rule := null;
        l_pegging_rec.constraint_type := null;
        l_pegging_rec.actual_supply_demand_date := null;

        /** BUG 2313497, 2126520  Check Resource Availability on End Date **/
        -- Changing the code to check Resource Availability on
        -- resource End Date instead of start date.
        -- Typically, if there are two resources
        -- R1 and R2 then We calculate the Availability of R1 until
        -- R2 is about to be used. i.e R2's start date becomes
        -- R1's End date and thus we do availability check on R1's
        -- End date.

        IF j = res_count THEN
          l_requested_date := p_requested_date;
          l_lead_time := 0;

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Setting the Lead time 0 for forward case');
          END IF;
        ELSE
          -- Check the the start date of the next resource and
          -- Use it as End date of current resource by
          -- storing the index. If next resource's Start date
          -- is same as current resource's start date then
          -- move in the loop until we find the resource whose
          -- start date is less then current resource's start date.
          For h in j+1..res_count
            LOOP
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'h = ' || h);
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'J' ||l_res_requirements.requested_date(j));
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'H' ||l_res_requirements.requested_date(h));
              END IF;
              IF l_res_requirements.requested_date(j)
                < l_res_requirements.requested_date(h) THEN
                   -- Bug 3348095
                   -- Assign the Resource start Date
                   l_res_start_date := l_res_requirements.requested_date(j);
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Get_Res_Requirements: Init. l_res_start_date ' ||
                                                                         l_res_start_date);
                      msc_sch_wb.atp_debug('Get_Res_Requirements: ' || l_res_requirements.requested_date(h));
                   END IF;
                   -- Bug 3348095
                   l_lead_time := l_res_requirements.lead_time(h);
                   l_requested_date := l_res_requirements.requested_date(h);
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Next Date found..Exiting');
                   END IF;
                   EXIT;
              ELSIF h = res_count THEN
                   l_requested_date := p_requested_date;
                   l_lead_time := 0;
              -- Bug 3348095
              -- Assign the Resource start Date
              ELSE
                   -- Set resource start date to NULL
                   l_res_start_date := NULL;
              -- Bug 3348095
              END IF;

            END LOOP;
        END IF;

        -- Bug 3494178, need to reset l_res_requirements.requested_date(j) same as l_requested_date
        l_res_requirements.requested_date(j) := l_requested_date;

        msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'New Requested Date: ' ||l_res_requirements.requested_date(j));

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Resource Lead time:' || l_lead_time);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_requested_date:'|| l_requested_date);
        END IF;

        -- 1610561
        -- l_resource_id := l_res_requirements.resource_id(j);
        -- l_department_id := NVL(l_res_requirements.owning_department_id(j),
        --                       l_res_requirements.department_id(j));
        -- l_requested_date already assigned above
        --l_requested_date := l_res_requirements.requested_date(j);
        /** BUG 2313497, 2126520 END Changes: Check Resource Availability **/

        l_resource_usage := l_res_requirements.resource_usage(j);
        l_basis_type := l_res_requirements.basis_type(j);
        l_efficiency := l_res_requirements.efficiency(j);
        l_utilization := l_res_requirements.utilization(j);
        ---resource batching
        l_max_capacity := l_res_requirements.max_capacity(j);
        l_batchable_flag := l_res_requirements.batch_flag(j);
        l_req_unit_capacity := l_res_requirements.required_unit_capacity(j);
        l_req_capacity_uom := NVL(l_res_requirements.required_capacity_uom(j), ' ');
        l_std_op_code := l_res_requirements.std_op_code(j);
        l_uom_type := l_res_requirements.res_uom_type(j);
        l_res_uom := l_res_requirements.res_uom(j);

        -- ODR
        l_op_seq_num := l_res_requirements.operation_sequence(j);

        If (l_batchable_flag <> 1 ) OR  (l_use_batching <> 1) THEN
          --- if item is not batchable or batching is not done then
          -- set the std_op_code back to null
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'batch flag back to null');
              msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Dont do batching');
           END IF;
          l_batchable_flag := 2;
          --l_use_batching := 0;
        END IF;

        l_atp_period := l_null_atp_period;
        l_atp_supply_demand := l_null_atp_supply_demand;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'j := '||j);
	   msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_resource_id := '||l_resource_id);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_department_id := '||l_department_id);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_requested_date := '||l_requested_date);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_resource_usage := '||l_resource_usage);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_basis_type := '||l_basis_type);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_efficiency := '||l_efficiency);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_utilization := '||l_utilization);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag := '||l_batchable_flag);
           -- ODR
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_op_seq_num := '||l_op_seq_num);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Offset % := '
                                                ||l_res_requirements.resource_offset_percent(j));
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Lead Time := '
                                         ||l_res_requirements.lead_time(j));
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Actual Resource_Usage := '
                                               ||l_res_requirements.actual_resource_usage(j));
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Reverse Cum Yield := '
                                             ||l_res_requirements.reverse_cumulative_yield(j));
        END IF;
        --- resource batching
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_max_capacity = '|| l_max_capacity);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag = '|| l_batchable_flag);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_req_unit_capacity = '||l_req_unit_capacity);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_req_capacity_uom = ' || l_req_capacity_uom);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'UOM type := ' || l_UOM_type);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_uom := '|| l_res_uom);
        END IF;

        --- get conversion rate for resource
        IF ((l_batchable_flag = 1) and (l_use_batching = 1)) THEN
               --do unit conversions into base uom
               ---first do item unit conversion to base uom
               BEGIN
               	  SELECT conversion_rate
                  INTO   l_item_conversion_rate
                  FROM   msc_uom_conversions
                  WHERE  inventory_item_id = 0
                  AND    sr_instance_id = p_instance_id
                  AND    UOM_CODE = l_req_capacity_uom;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       l_item_conversion_rate := 1;
               END;
               --- now convert resource uom into base uom
               BEGIN
                  SELECT conversion_rate
                  INTO   l_res_conversion_rate
                  FROM   msc_uom_conversions
                  WHERE  inventory_item_id = 0
                  AND    sr_instance_id = p_instance_id
                  AND    UOM_CODE = l_res_uom;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       l_res_conversion_rate := 1;
               END;

        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_item_conversion_rate := ' || l_item_conversion_rate);
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_conversion_rate := ' || l_res_conversion_rate);
        END IF;

        --diag_atp
        IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 and p_search = 1 THEN

           IF ((l_batchable_flag = 1) and (l_use_batching = 1)) then
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Batching quantity, diagnostic atp');
               END IF;
               l_requested_res_qty := (l_resource_usage * l_req_unit_capacity * p_requested_quantity)
                                       * (l_item_conversion_rate )/(l_efficiency * l_utilization * l_assembly_quantity);
           ELSIF l_basis_type in (1,3) THEN --4694958
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Basis type 1,3 qty, diagnostic ATP'); --4694958
               END IF;
               l_requested_res_qty := (l_resource_usage * p_requested_quantity)/
                                   (l_efficiency * l_utilization * l_assembly_quantity);
           ELSIF l_basis_type = 2 THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Basis type 2 qty, diagnostic ATP');
               END IF;
               --bug 3766202: do not inflate the resource in case of pure lot base resource
               ---(no batching) as ATP doesn't consider batch size
               l_requested_res_qty := l_resource_usage/
                                   --(l_efficiency * l_utilization * l_assembly_quantity);
                                   (l_efficiency * l_utilization);
           END IF;

        ELSE
           IF ((l_batchable_flag = 1) and (l_use_batching = 1)) then
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Batching quantity');
               END IF;
               l_requested_res_qty := (l_resource_usage * l_req_unit_capacity * x_avail_assembly_qty)
                                       * (l_item_conversion_rate )/(l_efficiency * l_utilization * l_assembly_quantity);
           ELSIF l_basis_type in (1,3) THEN --4694958
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Basis type 1,3 qty'); --4694958
               END IF;
               l_requested_res_qty := (l_resource_usage * x_avail_assembly_qty)/
                                   (l_efficiency * l_utilization * l_assembly_quantity);
           ELSIF l_basis_type = 2 THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Basis type 2 qty');
               END IF;
               --bug 3766202: do not inflate the resource in case of pure lot base resource
               ---(no batching) as ATP doesn't consider batch size
               l_requested_res_qty := l_resource_usage/
                                   (l_efficiency * l_utilization);
           END IF;
        --diag_atp
        END IF; --IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 and p_search = 1 THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_requested_res_qty := '||l_requested_res_qty);
        END IF;

        -- we need to have a branch here for allocated atp
        -- Bug 2372577 . Check value of profile option : krajan
        l_msc_cap_allocation := NVL(FND_PROFILE.VALUE('MSC_CAP_ALLOCATION'), 'Y');

        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'N') OR
           (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y' AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND
             MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) OR
             -- added for bug 2372577
            (l_msc_cap_allocation = 'N') THEN

            l_batching_flag := 0;
            IF l_batchable_flag = 1 and l_use_batching = 1 THEN
               l_batching_flag := 1;
            END IF;

            -- 2859130
            get_unalloc_res_avail(
               p_insert_flag,
               l_batching_flag,
               MSC_ATP_PVT.G_Optimized_Plan,
               p_instance_id,
               p_organization_id,
               p_plan_id,
               l_plan_start_date,
               l_department_id,
               l_resource_id,
               l_infinite_time_fence_date,
               l_uom_type,
               l_uom_code,
               l_max_capacity,
               l_res_conversion_rate,
               p_level,
               p_scenario_id,
               p_inventory_item_id,
               l_calendar_code,
               l_calendar_exception_set_id,
               l_summary_sql,       -- For summary enhancement
               p_refresh_number,    -- For summary enhancement
               l_atp_period_tab,
               l_atp_qty_tab,
               l_atp_period
            );

            Print_Dates_Qtys(l_atp_period_tab, l_atp_qty_tab);

        ELSE -- of G_ALLOCATED_ATP
           -- we are using allocated atp
           -- Begin Bug 2424357
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'MSC_ATP_PVT.G_ATP_DEMAND_CLASS := ' || MSC_ATP_PVT.G_ATP_DEMAND_CLASS);
           END IF;
           l_demand_Class := MSC_AATP_FUNC.Get_Res_Hierarchy_demand_class(
                                                  MSC_ATP_PVT.G_PARTNER_ID,
                                                  MSC_ATP_PVT.G_PARTNER_SITE_ID,
                                                  l_department_id,
                                                  l_resource_id,
                                                  p_organization_id,
                                                  p_instance_id,
                                                  l_requested_date,
                                                  NULL,
                                                  MSC_ATP_PVT.G_ATP_DEMAND_CLASS);

           --diag_atp
           l_allocation_rule_name := MSC_ATP_PVT.G_ALLOCATION_RULE_NAME;
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_demand_Class := '|| l_demand_Class);
           END IF;
           -- End Bug 2424357

           MSC_AATP_PVT.Res_Alloc_Cum_Atp(p_plan_id,
                              p_level,
                              MSC_ATP_PVT.G_ORDER_LINE_ID,
                              p_scenario_id,
                              l_department_id,
                              l_resource_id,
                              p_organization_id,
                              p_instance_id,
                              l_demand_Class, -- Bug 2424357
                              --p_demand_class,
                              l_requested_date,
                              p_insert_flag,
                              l_max_capacity,
                              l_batchable_flag,
                              l_res_conversion_rate,
                              l_uom_type,
                              l_atp_info,
                              l_atp_period,
                              l_atp_supply_demand);

           l_atp_period_tab := l_atp_info.atp_period;
           l_atp_qty_tab := l_atp_info.atp_qty;

        END IF; -- of G_ALLOCATED_ATP

        IF l_atp_period_tab.COUNT > 0 THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_atp_period_tab.count='||l_atp_period_tab.COUNT);
             FOR i in 1..l_atp_period_tab.COUNT LOOP
                 msc_sch_wb.atp_debug('Date '||l_atp_period_tab(i)||' Qty '||
                                  l_atp_qty_tab(i));
             END LOOP;
          END IF;
          l_res_qty_before_ptf := 0;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_PTF_DATE_THIS_LEVEL := ' || MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL);
          END IF;
          --bug 2341075: we should not consider any resources available before sysdate.Therefore,
          --- we get rid of all the resources availability before sysdate. Before this fix we use to ommit all
          --- the resources before pTF. Now we get rid off all resource availability prior to greatest of
          ---sysdate anf PTF date
          --Bug3394751 Added Trunc on the sysdate.

          FOR i in 1..l_atp_period_tab.COUNT LOOP
              IF (i = 1 AND l_atp_period_tab(i) >= GREATEST(MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL, trunc(sysdate))) THEN
                  l_res_qty_before_ptf := 0;
                  EXIT;
              ELSIF (i < l_atp_period_tab.COUNT AND
                      l_atp_period_tab(i) <  GREATEST(MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL, trunc(sysdate)) AND
                      l_atp_period_tab(i+1) >= GREATEST(MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL, trunc(sysdate)) ) THEN
                  l_res_qty_before_ptf := l_atp_qty_tab(i);
                  -- Bug 4108546 Set the Index value
                  l_res_ptf_indx := i;
                  EXIT;
              ELSIF i = l_atp_period_tab.COUNT THEN
                  IF l_atp_qty_tab(i) = MSC_ATP_PVT.INFINITE_NUMBER  THEN
                     l_res_qty_before_ptf := 0;
                  ELSE
                     l_res_qty_before_ptf := l_atp_qty_tab(i);
                     -- Bug 4108546 Set the Index value
                     l_res_ptf_indx := i;
                  END IF;
                  EXIT;
              END IF;
          END LOOP;
          l_res_qty_before_ptf := GREATEST(l_res_qty_before_ptf, 0);
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_qty_before_ptf := ' || l_res_qty_before_ptf);
             -- Bug 4108546 Print the value of Index
             IF (l_res_ptf_indx IS NOT NULL) THEN
                msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_ptf_indx := ' || l_res_ptf_indx);
             END IF;
             -- End Bug 4108546
          END IF;
          IF p_search = 1 THEN -- backward

            IF (l_requested_date < l_atp_period_tab(1)) THEN
            -- let say the first period is on Day5 but your
            -- request in on Day2.

                l_requested_date_quantity := 0;
            ELSIF (l_requested_date < trunc(sysdate)) THEN

                l_requested_date_quantity := 0;

            ELSE
             IF MSC_ATP_PVT.G_RES_CONSUME = 'Y' THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_RES_CONSUME = '||MSC_ATP_PVT.G_RES_CONSUME);
              END IF;
              FOR k IN 1..l_atp_period_tab.COUNT LOOP
                IF k < l_atp_period_tab.LAST THEN
                  l_next_period := l_atp_period_tab(k+1);
                ELSE
                  l_next_period := l_requested_date + 1;
                END IF;

                IF ((l_atp_period_tab(k) <= l_requested_date) and
                        (l_next_period > l_requested_date)) THEN

                  -- Bug found during fixing 3036513
                  -- Change > to >= so that if requested_date is infinite time fence date
                  -- then the quantity returned is also infinite.
                  IF (l_requested_date >= l_infinite_time_fence_date) THEN
                    l_requested_date_quantity := l_atp_qty_tab(k);
                  ELSE
                    l_requested_date_quantity := GREATEST((l_atp_qty_tab(k) - l_res_qty_before_ptf), 0);
                  END IF;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: l_atp_period_tab(k) :' || l_atp_period_tab(k) );
                     msc_sch_wb.atp_debug('Get_Res_Requirements: l_requested_date_quantity :' || l_requested_date_quantity );
                  END IF;
                  EXIT;
                END IF;
              END LOOP;
             ELSE -- IF G_RES_CONSUME = 'N'
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_RES_CONSUME = '||MSC_ATP_PVT.G_RES_CONSUME);
              END IF;
              -- first we initialize the l_requested_date_quantity so that
              -- if we cannot find any date that match the requested date,
              -- the l_requested_date_quantity is set to 0.

              l_requested_date_quantity := 0.0;
              FOR k IN 1..l_atp_period_tab.COUNT LOOP
                IF l_atp_period_tab(k) = l_requested_date THEN
                  l_requested_date_quantity := l_atp_qty_tab(k);
                  EXIT;
                END IF;
              END LOOP;
             END IF;  -- END IF G_RES_CONSUME = 'Y'


            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_requested_date_quantity ='||l_requested_date_quantity);
            END IF;

            IF l_requested_date_quantity >= l_requested_res_qty THEN
                -- for this resource, we satisfy the resource requirement
                -- so we don't need to change the x_avail_assembly_qty
                -- for the assembly.
                NULL;

            ELSIF l_requested_date_quantity >0 THEN
            -- for this resource, we cannot satisfy the resource
            -- requirement.  so we need to change the x_avail_assembly_qty
                --- resource batching: If req_dat_qty < req_qty then we set the avail_qty = 0
                IF l_basis_type = 2 OR MSC_ATP_PVT.G_RES_CONSUME = 'N'OR
                         (l_batchable_flag = 1 AND l_use_batching = 1) THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_RES_CONSUME = '||MSC_ATP_PVT.G_RES_CONSUME);
                       msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_basis_type = '||l_basis_type);
                    END IF;
                    -- this requirement is per lot, so we cannot have any
                    -- final assembly made
                    x_avail_assembly_qty :=0;
                    --diag_atp: we want to check for next resource in daignostic mode even if
                    --available qty for this resource is zero.
                    IF NOT (MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1) THEN

		       EXIT;
                    END IF;
                ELSE
                    -- this requirement is per item, so we can make partial of
                    -- the requested_quantity.  notes, we should
                    -- use the min to get the x_avail_assembly_qty.

                    x_avail_assembly_qty := LEAST(x_avail_assembly_qty,
                          trunc((l_requested_date_quantity * l_efficiency * l_utilization)/
                                l_resource_usage,6));	-- 5598066

                    -- 2869830
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('avail_assembly_qty: ' ||
                          x_avail_assembly_qty);
                    END IF;
                    IF l_rounding_flag = 1 THEN
                       x_avail_assembly_qty := FLOOR(x_avail_assembly_qty);
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('rounded avail qty: ' ||
                             x_avail_assembly_qty);
                       END IF;
                    END IF;

                END IF;
            ELSE
                -- since we don't have any resource left, we cannot make any
                -- assembly.
                x_avail_assembly_qty :=0;
                --diag_atp: we want to check for next resource in daignostic mode even if
                --available qty for this resource is zero.
                IF NOT (MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1) THEN
                   EXIT;
                END IF;
            END IF;
          ELSE
            -- now this is forward.  so what we want to know is the date
            -- when whole quantity is available.
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'in forward, resource check');
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_requested_date = '||l_requested_date);
            END IF;

            -- Bug 3450725, requested date must be at least PTF Date + Lead Time w/ offset % from start of job.
            -- Lets say, there are 3 resources R1, R2 and R3 with offset % as 0, 50% and 70% respectively,
            -- and Total LT (F+V*Qty)* (1+mso_LT_factor) = 10 days and PTF is D10.
            -- Request Date for each resource in this example must be minimum D15, D17 and D20 for R1, R2 and R3.
            -- This will ensure start date for 3 resources (assumed to be sequential) be D10, D15 and D17 respectively.
			-- Use Org's Manuf. Calendar

            ---2178544
            l_requested_date := GREATEST(l_requested_date,
                     				MSC_CALENDAR.DATE_OFFSET
                                    (p_organization_id,
                                     p_instance_id,
                                     1,
                                     MSC_ATP_PVT.G_PTF_DATE,
                    				 CEIL(((NVL(l_item_fixed_lt,0)+
                        					NVL(l_item_var_lt,0)* p_requested_quantity) * (1+ l_mso_lead_time_factor))
                        					- l_lead_time)));--4198893,4198445


            ---2178544
            --l_requested_date := GREATEST(l_requested_date, MSC_ATP_PVT.G_PTF_DATE);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'New l_requested_date = '||l_requested_date);
            END IF;

            FOR k IN 1..l_atp_period_tab.COUNT LOOP

                -- bug 1510408
                IF k < l_atp_period_tab.LAST THEN
                  l_next_period := l_atp_period_tab(k+1);
                ELSE
                  l_next_period := l_requested_date + 1;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_atp_period_tab('||k||')='||l_atp_period_tab(k));
                   msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_atp_qty_tab('||k||')='||l_atp_qty_tab(k));
                END IF;

                IF (l_atp_qty_tab(k)  -l_res_qty_before_ptf >= l_requested_res_qty) AND
                    --((l_atp_period_tab(k) >= trunc(sysdate) AND --4198893,4198445
                    ((l_atp_period_tab(k) >= trunc(sysdate) AND -- bug 8552388
                     l_next_period > l_requested_date
                     AND MSC_ATP_PVT.G_RES_CONSUME = 'Y') OR
                     (l_atp_period_tab(k) >= l_requested_date
                     AND MSC_ATP_PVT.G_RES_CONSUME = 'N')) THEN

                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'inside the loop to find x_atp_date');
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'x_atp_date = '||x_atp_date);
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_requirements.lead_time(j) = '||l_res_requirements.lead_time(j));
                  END IF;

                  -- we need to store this quantity and date somewhere
                  -- so that we can use them to add to pegging tree

                -- Bug 1418766 and 1417110. In case of forward scheduling,
                -- instead of using resources on the earliest available date
                -- use them on the latest date before the greatest of requested date
                -- and l_res_atp_date

                  l_res_atp_date := GREATEST(l_atp_period_tab(k), l_requested_date);
                  -- BUG found during ODR/CTO-Rearch/ATP_Simplified Pegging.
                  -- Bug found during fixing 3036513
                  -- Change = to >= so that if requested_date is infinite time fence date
                  -- then the quantity returned is also infinite.
                  IF (l_res_atp_date >= l_infinite_time_fence_date) THEN
                     l_res_atp_qty := l_atp_qty_tab(k)  ;
                  ELSE
                     l_res_atp_qty := l_atp_qty_tab(k) - l_res_qty_before_ptf ;
                  END IF;
                  -- End BUG found during ODR/CTO-Rearch/ATP_Simplified Pegging.

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_atp_date = '||l_res_atp_date);
            END IF;
		 --4198893,4198445 First calculate individual availability date. This date will be used to calculate
		 --start date.
                  IF nvl(l_lead_time, 0) > 0 THEN
                     l_res_availability_date := MSC_CALENDAR.DATE_OFFSET
                                    (p_organization_id,
                                     p_instance_id,
                                     1,
                                     l_res_atp_date,
                                     NVL(l_lead_time, 0));
                     /* x_atp_date :=  GREATEST(MSC_CALENDAR.DATE_OFFSET
                                    (p_organization_id,
                                     p_instance_id,
                                     1,
                                     l_res_atp_date,
                                     NVL(l_lead_time, 0)), --BUG 2313497, 2126520
                                     x_atp_date);
                     */
                     --// BUG 2313497, 2126520
                  ELSE
                    -- Bug 3598486: Taking the greatest of the 2 dates
                    --4198445: l_res_availability_date is same as l_res_atp_date
                    --x_atp_date := GREATEST(l_res_atp_date, x_atp_date);

                    l_res_availability_date := l_res_atp_date;
                  END IF;
                  x_atp_date := GREATEST(l_res_availability_date, x_atp_date);
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_lead_time = '||l_lead_time);
                  END IF;
                  --// BUG 2313497, 2126520
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_res_requirements.lead_time(j) = '||
                               l_res_requirements.lead_time(j));
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'x_atp_date = '||x_atp_date);
                  END IF;

                  EXIT;
                ELSIF k = l_atp_period_tab.last THEN -- bug 1169539
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'end of l_atp_period_tab, setting x_atp_date to null');
                  END IF;
                  x_atp_date := null;
                END IF;
            END LOOP;

            IF x_atp_date IS NULL THEN
                -- no available date exists for this resource, we should
                -- exit this resource loop then.
		-- Bug 1608755, set available qty = 0 in this case.
                x_avail_assembly_qty :=0;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'exiting from resource loop');
                END IF;

                EXIT;
            END IF;

          END IF; -- end if p_search

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'x_avail_assembly_qty='||x_avail_assembly_qty);
          END IF;

        ELSE  -- else of 'if l_atp_period_tab.count > 0'

            -- no supply demand record for this resource, that means we
            -- cannot make any assembly.
            x_avail_assembly_qty :=0;
            x_atp_date := NULL;
            --diag_atp: we want to check for next resource in daignostic mode even if
            --available qty for this resource is zero.
            IF NOT (MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 AND p_search = 1) THEN

                EXIT;
            END IF;
        END IF;  -- end if l_atp_period_tab.count > 0

        -- Note:  we need to post those requirements into database so that
        -- if we happen to check the resource again, we won't mess up the
        -- quantity. not yet done!!!

        IF p_search = 1 THEN   -- Backward Scheduling
          --diag_atp
          IF x_avail_assembly_qty <> 0 or MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 THEN
            -- get supply_id from the pegging_id
            SELECT IDENTIFIER3
            INTO   l_supply_id
            FROM   MRP_ATP_DETAILS_TEMP
            WHERE  PEGGING_ID = p_parent_pegging_id
            AND    RECORD_TYPE = 3
            AND    SESSION_ID = MSC_ATP_PVT.G_SESSION_ID;
            --diag_atp:
            IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 THEN
              --since we are checking on full quantity, we do not need to convert it back
              IF (l_basis_type in (1,3)) THEN --4694958
                 --bug 3766202: divide by l_assembly qty to correctly project resource hours
                 --- for co-producs
                 l_resource_hours       := (p_requested_quantity*l_resource_usage) /
                                           (l_efficiency * l_utilization * l_assembly_quantity);

                 l_unadj_resource_hours := (p_requested_quantity*l_resource_usage)/
                                            l_assembly_quantity; --5093604

                 l_touch_time           := (p_requested_quantity*l_resource_usage)/
                                             (l_efficiency * l_assembly_quantity); --5093604
              --bug 3766202: Do not inflate resource qty for unbatachable lot based resource
              ELSIF ((l_batchable_flag =1 and l_use_batching = 1)) THEN
                 --bug 3766202: divide by l_assembly qty to correctly project resource hours
                 --- for co-producs
                 l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization * l_assembly_quantity);

                 l_unadj_resource_hours := l_resource_usage/l_assembly_quantity; --5093604

                 l_touch_time           := l_resource_usage/(l_efficiency * l_assembly_quantity); --5093604

              ELSE
                 l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization);

                 l_unadj_resource_hours := l_resource_usage; --5093604

                 l_touch_time           := l_resource_usage/l_efficiency; --5093604
              END IF;
            ELSE
               IF (l_basis_type in (1,3)) THEN --4694958
                 --bug 3766202: divide by l_assembly qty to correctly project resource hours
                 --- for co-producs
                 l_resource_hours       := (x_avail_assembly_qty*l_resource_usage) /
                                           (l_efficiency * l_utilization * l_assembly_quantity);

                 l_unadj_resource_hours := (x_avail_assembly_qty*l_resource_usage)/
                                            l_assembly_quantity; --5093604

                 l_touch_time           := (x_avail_assembly_qty*l_resource_usage)/
                                            (l_efficiency * l_assembly_quantity); --5093604

               --bug 3766202: Do not inflate resource qty for unbatachable lot based resource
               ELSIF ((l_batchable_flag =1 and l_use_batching = 1)) THEN
                 --l_resource_hours := l_requested_res_qty / (l_efficiency * l_utilization);
                 --bug: resource hours were getting inflated twice.
                 --- replaced l_requested_res_qty with l_resource_usage
                 --bug 3766202: divide by l_assembly qty to correctly project resource hours
                 --- for co-producs
                 l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization * l_assembly_quantity);

                 l_unadj_resource_hours := l_resource_usage/l_assembly_quantity; --5093604

                 l_touch_time           := l_resource_usage/(l_efficiency * l_assembly_quantity); --5093604

               ELSE
                 l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization);

                 l_unadj_resource_hours := l_resource_usage; --5093604

                 l_touch_time           := l_resource_usage/l_efficiency; --5093604
               END IF;
            END IF;

            /*IF (l_basis_type = 2 ) THEN
              l_resource_hours := l_requested_res_qty / (l_efficiency * l_utilization);
            ELSIF (l_basis_type = 1 ) THEN
              l_resource_hours := (x_avail_assembly_qty*l_resource_usage) /
                                        (l_efficiency * l_utilization);
            END IF; */

            -- Bug 3348095
            -- Calculate the start date given the end date in backward case.
            IF (l_res_start_date IS NULL) THEN
              l_res_start_date :=  LEAST(MSC_CALENDAR.DATE_OFFSET
                                    (p_organization_id,
                                     p_instance_id,
                                     1,
                                     l_requested_date,
                                     -1 * l_res_requirements.lead_time(j)),
                                     l_requested_date);

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: Calc. value-1 l_res_start_date ' ||
                                                                         l_res_start_date);
              END IF;
            END IF;
            -- End Bug 3348095
              -- Bug 3450725
              -- Ensure SYSDATE/PTF_DATE integrity while calculating start_date
              -- for resource_requirements
              -- Bug 3562873 only PTF check is needed.
              l_res_start_date := trunc(GREATEST(l_res_start_date,
                        --Bug 3562873   l_res_requirements.requested_date(j),
                                        MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL)); --4135752
              -- End Bug 3562873.

              IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Res_Requirements: l_res_requirements.requested_date(j) '||
                                                        l_res_requirements.requested_date(j));
                msc_sch_wb.atp_debug('Get_Res_Requirements: Calc. value-2 l_res_start_date ' ||
                                                                         l_res_start_date);
              END IF;
              -- End Bug 3450725

            MSC_ATP_DB_UTILS.Add_Resource_Demand(p_instance_id,
                                                 p_plan_id,
                                                 l_supply_id,
                                                 p_organization_id,
                                                 l_resource_id,
                                                 l_res_requirements.department_id(j),
                                                 -- Bug 3348095 Pass in Resource Start Dt.
                                                 l_res_start_date,
                                                 -- End Bug 3348095
                                                 l_requested_date,
                                                 l_resource_hours, --5093604
                                                 l_unadj_resource_hours , --5093604
                                                 l_touch_time, --5093604
                                                 l_std_op_code,
                                                 l_requested_res_qty,
                                                 l_inventory_item_id,   -- CTO Option Dependent Resources ODR
                                                 l_basis_type,  -- CTO Option Dependent Resources ODR
                                                 l_op_seq_num,  -- CTO Option Dependent Resources ODR
                                                 p_refresh_number,      -- For summary enhancement
                                                 l_transaction_id,
                                                 l_return_status);

             msc_sch_wb.atp_debug('Out of the ADD RESOURCE DEMAND');
            -- Bug 3348095
            -- End date of this resource will be the start date of next resource.
            -- Bug 3562873 Comment out this assignment, redundant, done above.
            -- l_res_start_date := l_requested_date;
            /*
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: Set l_res_start_date for next Res. ' ||
                                                                         l_res_start_date);
            END IF;
            */
            -- End Bug 3562873
            -- End 3348095

            -- add pegging info for this demand

            -- for performance reason, we call these function here and
            -- then populate the pegging tree with the values

            -- 1487344: instead of getting resource code and department code
            -- separately, we get them together to ensure we won't accidently
            -- get the line info.  Because we display either owing dept or
            -- dept for supply or demand pegging tree, we need to get the name
            -- each time.
            --diag_atp: we are already getting the department code in actual query
            IF l_res_requirements.department_code(j) is null THEN
               MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_res_requirements.department_id(j),
                              l_resource_id,
                              p_organization_id,
                              l_department_code,
                              l_resource_code);
            ELSE
               l_department_code := l_res_requirements.department_code(j);
               l_resource_code := l_res_requirements.resource_code(j);
            END IF;

            IF NVL(l_res_requirements.department_id(j), -1) <> NVL(l_res_requirements.owning_department_id(j),
                                                                  NVL(l_res_requirements.department_id(j), -1)) THEN
               MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_res_requirements.owning_department_id(j),
                              l_resource_id,
                              p_organization_id,
                              l_owning_department_code,
                              l_resource_code);
            ELSE
               l_owning_department_code := l_department_code;
            END IF;

            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
            l_pegging_rec.atp_level:= p_level;
            l_pegging_rec.organization_id:= p_organization_id;
            l_pegging_rec.organization_code := l_org_code;
            l_pegging_rec.identifier1:= p_instance_id;
            l_pegging_rec.identifier2:= p_plan_id;
            l_pegging_rec.identifier3 := l_supply_id; -- link to assembly's supply l_transaction_id;
            l_pegging_rec.identifier3 := l_transaction_id;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= 1;
            --l_pegging_rec.supply_demand_quantity:=l_resource_hours;
            --- Resource batching
            IF (l_use_batching = 1 AND l_batchable_flag = 1) THEN
                l_pegging_rec.supply_demand_quantity:=l_requested_res_qty;
            ELSE
                l_pegging_rec.supply_demand_quantity:=l_resource_hours;
            END IF;
            l_pegging_rec.supply_demand_type:= 1;
            l_pegging_rec.supply_demand_date:= l_requested_date;
	    l_pegging_rec.department_id := l_res_requirements.department_id(j);
            l_pegging_rec.department_code := l_department_code;
	    l_pegging_rec.resource_id := l_resource_id;
            l_pegging_rec.resource_code := l_resource_code;
            l_pegging_rec.inventory_item_id := NULL;
            l_pegging_rec.inventory_item_name := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;
            --- resource batching
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_batching = ' || l_use_batching);
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag = ' || l_batchable_flag);
            END IF;
            ---bug 1907419: set batchable_flag =1 for batchable resource
            --IF (l_use_batching = 1 and l_batchable_flag = 1) THEN
            -- add batch flag to pegging
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'ADD batch flag to pegging');
            END IF;
            l_pegging_rec.batchable_flag := l_batchable_flag;
            --END IF;

            --diag_atp
            l_pegging_rec.pegging_type := MSC_ATP_PVT.RESOURCE_DEMAND; --resource demand node

            -- Bug 3348161
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_ITEM_INFO_REC.base_item_id ' ||
                                      MSC_ATP_PVT.G_ITEM_INFO_REC.base_item_id);
            END IF;
            ---s_cto_rearch and ODR
            l_pegging_rec.dest_inv_item_id := l_inventory_item_id;
            IF (MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type in (1, 2) OR
                  -- Handle Configuration Items as well.
                  MSC_ATP_PVT.G_ITEM_INFO_REC.base_item_id is NOT NULL) THEN
               l_pegging_rec.model_sd_flag := 1;
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Set model_sd_flag');
               END IF;
            END IF;
            --e_cto_rearch and ODR
            -- End Bug 3348161

	    -- dsting ATO 2465370
	    l_pegging_rec.required_date := TRUNC(l_requested_date) + MSC_ATP_PVT.G_END_OF_DAY;

            --bug 3328421
            l_pegging_rec.actual_supply_demand_date := TRUNC(l_requested_date) + MSC_ATP_PVT.G_END_OF_DAY;

            -- for demo:1153192
            l_pegging_rec.constraint_flag := 'N';
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;
            -- Bug 3826234
            l_pegging_rec.manufacturing_cal_code :=  NULL;
            l_pegging_rec.organization_type  := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

            -- 1487344: instead of getting resource code and department code
            -- separately, we get them together to ensure we won't accidently
            -- get the line info.  Because we display either owing dept or
            -- dept for supply or demand pegging tree, we need to get the name
            -- each time.

            --diag_atp: we already got the owning department code before adding pegging for resource demand
            l_department_code := l_owning_department_code;


            /*MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_department_id,
                              l_resource_id,
                              p_organization_id,
                              l_department_code,
                              l_resource_code); */

            -- add pegging info for the supply

            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= l_pegging_id;
            l_pegging_rec.atp_level:= p_level+1;
            l_pegging_rec.organization_id:= p_organization_id;
            l_pegging_rec.organization_code := l_org_code;
            l_pegging_rec.identifier1:= p_instance_id;
            l_pegging_rec.identifier2:= p_plan_id;
            l_pegging_rec.identifier3 := -1;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
            l_pegging_rec.supply_demand_quantity:=l_requested_date_quantity;
            l_pegging_rec.supply_demand_type:= 2;
            l_pegging_rec.supply_demand_date:= l_requested_date;
            l_pegging_rec.department_id := l_department_id;
            l_pegging_rec.department_code := l_department_code;
            l_pegging_rec.resource_id := l_resource_id;
            l_pegging_rec.resource_code := l_resource_code;
            l_pegging_rec.inventory_item_id := NULL;
            l_pegging_rec.inventory_item_name := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;
              --- resource batching
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_batching = ' || l_use_batching);
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag = ' || l_batchable_flag);
            END IF;
            --- bug 1907419
            ---IF (l_use_batching = 1 and l_batchable_flag = 1) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'ADD batch flag to pegging');
            END IF;
            l_pegging_rec.batchable_flag := l_batchable_flag;
            --END IF;

            --diag_atp
            l_pegging_rec.operation_sequence_id := l_res_requirements.operation_sequence(j);
            l_pegging_rec.usage := l_res_requirements.actual_resource_usage(j);
            l_pegging_rec.offset := l_res_requirements.resource_offset_percent(j);
            l_pegging_rec.efficiency := l_res_requirements.efficiency(j);
            l_pegging_rec.utilization := l_res_requirements.utilization(j);
            l_pegging_rec.REVERSE_CUM_YIELD := l_res_requirements.reverse_cumulative_yield(j);
            l_pegging_rec.owning_department := l_owning_department_code;
            l_pegging_rec.pegging_type := MSC_ATP_PVT.RESOURCE_SUPPLY; --resource supply node

            l_pegging_rec.model_sd_flag := NULL; -- cto_rearch ODR unset flag for supply.

            IF (l_use_batching = 1 AND l_batchable_flag = 1) THEN
                l_pegging_rec.required_quantity:=l_requested_res_qty;
            ELSE
                l_pegging_rec.required_quantity:=l_resource_hours;
            END IF;
            l_pegging_rec.required_date := TRUNC(l_requested_date) + MSC_ATP_PVT.G_END_OF_DAY;
            --bug 3328421:
            l_pegging_rec.actual_supply_demand_date := TRUNC(l_requested_date) + MSC_ATP_PVT.G_END_OF_DAY;
            l_pegging_rec.basis_type := l_res_requirements.basis_type(j);
            IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 THEN
               IF l_requested_res_qty > l_requested_date_quantity THEN
                 l_pegging_rec.constraint_type := 6;
               END IF;
            END IF;
            l_pegging_rec.allocation_rule := l_allocation_rule_name;
            --diag_atp_end

            -- for demo:1153192
            IF l_resource_hours >= l_requested_date_quantity THEN
              l_pegging_rec.constraint_flag := 'Y';
            ELSE
              l_pegging_rec.constraint_flag := 'N';
            END IF;

            l_pegging_rec.source_type := 0;
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;

            -- Bug 3036513 Add Infinite_Time_fence and ATP Rule Data to Pegging
            l_pegging_rec.infinite_time_fence := l_infinite_time_fence_date;
            l_pegging_rec.atp_rule_name := l_atp_rule_name;
            -- End Bug 3036513
            -- Bug 3826234
            l_pegging_rec.manufacturing_cal_code :=  l_calendar_code;
            l_pegging_rec.organization_type  := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

          END IF;

        ELSE
           --IF p_search = 2 THEN, Forward Scheduling

          IF x_atp_date IS NOT NULL THEN
            -- get supply_id from the pegging_id
            SELECT IDENTIFIER3
            INTO   l_supply_id
            FROM   MRP_ATP_DETAILS_TEMP
            WHERE  PEGGING_ID = p_parent_pegging_id
            AND    RECORD_TYPE = 3
            AND    SESSION_ID = MSC_ATP_PVT.G_SESSION_ID;

            IF (l_basis_type in (1,3)) THEN --4694958
              --bug 3766202: divide by l_assembly qty to correctly project resource hours
              --- for co-producs
              l_resource_hours       := (x_avail_assembly_qty*l_resource_usage) /
                                        (l_efficiency * l_utilization * l_assembly_quantity);

              l_unadj_resource_hours := (x_avail_assembly_qty*l_resource_usage)/
                                         l_assembly_quantity; --5093604

              l_touch_time           := (x_avail_assembly_qty*l_resource_usage)/
                                         (l_efficiency * l_assembly_quantity); --5093604

            --bug 3766202: Do no inflate res req for nonbatchable resource
            ELSIF (l_batchable_flag =1 and l_use_batching = 1) THEN

              --bug 3766202: divide by l_assembly qty to correctly project resource hours
              --- for co-producs
              l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization * l_assembly_quantity);

              l_unadj_resource_hours := l_resource_usage/l_assembly_quantity; --5093604

              l_touch_time           := l_resource_usage/(l_efficiency * l_assembly_quantity);  --5093604

            ELSE
              l_resource_hours       := l_resource_usage / (l_efficiency * l_utilization);

              l_unadj_resource_hours := l_resource_usage; --5093604

              l_touch_time           := l_resource_usage/l_efficiency; --5093604

            END IF;

            -- Bug 3348095
            -- Calculate the start date given the end date in forward case.
            l_res_start_date :=  LEAST(MSC_CALENDAR.DATE_OFFSET
                                    (p_organization_id,
                                     p_instance_id,
                                     1,
                                     l_res_availability_date,
                                     -1 * l_res_requirements.lead_time(j)),
                                     l_res_atp_date);
                                     --4198893,4198445: Calculate start date from individual resource's end date
                                     --l_res_atp_date);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: Calculated val-1 l_res_start_date ' || l_res_start_date);
            END IF;
            -- Bug 3450725
            -- Ensure SYSDATE/PTF_DATE integrity while calculating start_date
            -- for resource_requirements
            -- Bug 3562873 only PTF check is needed.
            l_res_start_date := trunc(GREATEST(l_res_start_date,
                      --Bug 3562873   l_res_requirements.requested_date(j),
                                        MSC_ATP_PVT.G_PTF_DATE_THIS_LEVEL));  --4135752
            -- End Bug 3562873.

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: l_res_requirements.requested_date(j) ' ||
                                                        l_res_requirements.requested_date(j));
               msc_sch_wb.atp_debug('Get_Res_Requirements: Calculated val-2 l_res_start_date ' || l_res_start_date);
            END IF;
            -- End Bug 3450725
            -- End Bug 3348095

            MSC_ATP_DB_UTILS.Add_Resource_Demand(p_instance_id,
                                                 p_plan_id,
                                                 l_supply_id,
                                                 p_organization_id,
                                                 l_resource_id,
                                                 l_res_requirements.department_id(j),
                                                 -- Bug 3348095 Pass in Resource Start Dt.
                                                 l_res_start_date,
                                                 -- End Bug 3348095
                                                 l_res_atp_date,  -- bug 1238910
                                                 --l_requested_res_qty,
                                                 l_resource_hours, --5093604
                                                 l_unadj_resource_hours, --5093604
                                                 l_touch_time, --5093604
                                                 l_std_op_code,
                                                 l_requested_res_qty,
                                                 l_inventory_item_id,   -- CTO Option Dependent Resources ODR
                                                 l_basis_type,  -- CTO Option Dependent Resources ODR
                                                 l_op_seq_num,  -- CTO Option Dependent Resources ODR
                                                 p_refresh_number,      -- For summary enhancement
                                                 l_transaction_id,
                                                 l_return_status);

            -- add pegging info for this demand

            -- for performance reason, we call these function here and
            -- then populate the pegging tree with the values

            -- 1487344: instead of getting resource code and department code
            -- separately, we get them together to ensure we won't accidently
            -- get the line info.  Because we display either owing dept or
            -- dept for supply or demand pegging tree, we need to get the name
            -- each time.

            --diag_atp: we are already getting the department code in actual query
            IF l_res_requirements.department_code(j) is null THEN
               MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_res_requirements.department_id(j),
                              l_resource_id,
                              p_organization_id,
                              l_department_code,
                              l_resource_code);
            ELSE
               l_department_code := l_res_requirements.department_code(j);
               -- Bug 3308237 Set the assignment right.
               -- It was l_res_requirements.resource_id(j) before
               l_resource_code := l_res_requirements.resource_code(j);
            END IF;

            IF NVL(l_res_requirements.department_id(j), -1) <> NVL(l_res_requirements.owning_department_id(j),
                                                                 NVL(l_res_requirements.department_id(j), -1)) THEN
               MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_res_requirements.owning_department_id(j),
                              l_resource_id,
                              p_organization_id,
                              l_owning_department_code,
                              l_resource_code);
            ELSE
               l_owning_department_code := l_department_code;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'in forward piece, adding resource demand pegging');
            END IF;
            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
            l_pegging_rec.atp_level:= p_level;
            l_pegging_rec.organization_id:= p_organization_id;
            l_pegging_rec.organization_code := l_org_code;
            l_pegging_rec.identifier1:= p_instance_id;
            l_pegging_rec.identifier2:= p_plan_id;
            l_pegging_rec.identifier3 := l_transaction_id;
            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= 1;
            l_pegging_rec.supply_demand_quantity:=l_requested_res_qty;
            l_pegging_rec.supply_demand_type:= 1;
            --- 2178544
            l_pegging_rec.supply_demand_date:= l_res_requirements.requested_date(j);
            --l_pegging_rec.supply_demand_date:= l_requested_date;
	    l_pegging_rec.department_id := l_res_requirements.department_id(j);
            l_pegging_rec.department_code := l_department_code;
	    l_pegging_rec.resource_id := l_resource_id;
            l_pegging_rec.resource_code := l_resource_code;

            l_pegging_rec.inventory_item_id := NULL;
            l_pegging_rec.inventory_item_name := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;

              --- resource batching
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_batching = ' || l_use_batching);
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag = ' || l_batchable_flag);
            END IF;
            --- bug 1907419
            --IF (l_use_batching = 1 and l_batchable_flag = 1) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'ADD batch flag to pegging');
            END IF;
            l_pegging_rec.batchable_flag := l_batchable_flag;
            --END IF;

            --diag_atp
            l_pegging_rec.pegging_type := MSC_ATP_PVT.RESOURCE_DEMAND; --resource demand node

            -- for demo:1153192
            l_pegging_rec.constraint_flag := 'N';
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;

	    -- dsting ATO 2465370
            --bug 3328421: store actual req date in req_date col and actual supply demand date in
	    --l_pegging_rec.required_date := TRUNC(l_res_atp_date) + MSC_ATP_PVT.G_END_OF_DAY;
            l_pegging_rec.required_date := l_res_requirements.requested_date(j);
            l_pegging_rec.actual_supply_demand_date := TRUNC(l_res_atp_date) + MSC_ATP_PVT.G_END_OF_DAY;

            -- Bug 3348161
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'G_ITEM_INFO_REC.base_item_id ' ||
                                      MSC_ATP_PVT.G_ITEM_INFO_REC.base_item_id);
            END IF;
            ---s_cto_rearch and ODR,
            -- Bug 3348161 set model_sd_flag for future case.
            l_pegging_rec.dest_inv_item_id := l_inventory_item_id;
            IF (MSC_ATP_PVT.G_ITEM_INFO_REC.bom_item_type in (1, 2) OR
                  -- Handle Configuration Items as well.
                  MSC_ATP_PVT.G_ITEM_INFO_REC.base_item_id is NOT NULL) THEN
               l_pegging_rec.model_sd_flag := 1;
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'Set model_sd_flag');
               END IF;
            END IF;
            --e_cto_rearch and ODR
            -- End Bug 3348161
             -- Bug 3826234
            l_pegging_rec.manufacturing_cal_code :=  NULL;
            l_pegging_rec.organization_type  := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

            -- 1487344: instead of getting resource code and department code
            -- separately, we get them together to ensure we won't accidently
            -- get the line info.  Because we display either owing dept or
            -- dept for supply or demand pegging tree, we need to get the name
            -- each time.

            --diag_atp: we already got the owning department code before adding pegging for resource demand
            l_department_code := l_owning_department_code;


            /*MSC_ATP_PROC.get_dept_res_code(p_instance_id,
                              l_department_id,
                              l_resource_id,
                              p_organization_id,
                              l_department_code,
                              l_resource_code); */

            -- add pegging info for the supply
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'in forward piece, adding resource supply pegging');
END IF;


            l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
            l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
            l_pegging_rec.parent_pegging_id:= l_pegging_id;
            l_pegging_rec.atp_level:= p_level+1;
            l_pegging_rec.organization_id:= p_organization_id;
            l_pegging_rec.organization_code := l_org_code;
            l_pegging_rec.identifier1:= p_instance_id;
            l_pegging_rec.identifier2:= p_plan_id;
            l_pegging_rec.identifier3 := -1;

            l_pegging_rec.scenario_id:= p_scenario_id;
            l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
            l_pegging_rec.supply_demand_quantity:= l_res_atp_qty;
            l_pegging_rec.supply_demand_type:= 2;
            l_pegging_rec.supply_demand_date:= l_res_atp_date;
            l_pegging_rec.department_id := l_department_id;
            l_pegging_rec.department_code := l_department_code;
            l_pegging_rec.resource_id := l_resource_id;
            l_pegging_rec.resource_code := l_resource_code;
            l_pegging_rec.inventory_item_id := NULL;
            l_pegging_rec.inventory_item_name := NULL;
            l_pegging_rec.supplier_id := NULL;
            l_pegging_rec.supplier_name := NULL;
            l_pegging_rec.supplier_site_id := NULL;
            l_pegging_rec.supplier_site_name := NULL;

             --- resource batching
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_use_batching = ' || l_use_batching);
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'l_batchable_flag = ' || l_batchable_flag);
            END IF;
            --- bug 1907419
            ---IF (l_use_batching = 1 and l_batchable_flag = 1) THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements: ' || 'ADD batch flag to pegging');
            END IF;
            l_pegging_rec.batchable_flag := l_batchable_flag;
            ---END IF;
            --diag_atp
            l_pegging_rec.operation_sequence_id := l_res_requirements.operation_sequence(j);
            l_pegging_rec.usage := l_res_requirements.actual_resource_usage(j);
            l_pegging_rec.offset := l_res_requirements.resource_offset_percent(j);
            l_pegging_rec.efficiency := l_res_requirements.efficiency(j);
            l_pegging_rec.utilization := l_res_requirements.utilization(j);
            l_pegging_rec.REVERSE_CUM_YIELD := l_res_requirements.reverse_cumulative_yield(j);
            l_pegging_rec.owning_department := l_owning_department_code;
            l_pegging_rec.pegging_type := MSC_ATP_PVT.RESOURCE_SUPPLY; --resource supply node
            IF (l_use_batching = 1 AND l_batchable_flag = 1) THEN
                l_pegging_rec.required_quantity:=l_requested_res_qty;
            ELSE
                l_pegging_rec.required_quantity:=l_resource_hours;
            END IF;
            l_pegging_rec.required_date := TRUNC(l_requested_date) + MSC_ATP_PVT.G_END_OF_DAY;
            --bug 3328421:
            l_pegging_rec.actual_supply_demand_date :=  trunc(l_res_atp_date) + MSC_ATP_PVT.G_END_OF_DAY;
            l_pegging_rec.basis_type := l_res_requirements.basis_type(j);
            l_pegging_rec.allocation_rule := l_allocation_rule_name;

            -- Bug 3348161 Unset model_sd_flag for future supply case.
            l_pegging_rec.model_sd_flag := NULL; -- cto_rearch ODR unset flag for supply.

            l_pegging_rec.source_type := 0;

            -- for demo:1153192
            l_pegging_rec.constraint_flag := 'N';
            l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;

            --s_cto_rearch
            IF l_res_atp_date > l_requested_date THEN
               IF PG_DEBUG in ('Y', 'C') THEN

                  msc_sch_wb.atp_debug(' Add resource constraint in regular ATP');
               END IF;
               --l_pegging_rec.constraint_type := 7;
               l_pegging_rec.constraint_type := 6; --bug3533073
            END IF;
            --e_cto_rearch

            -- Bug 3036513 Add Infinite_Time_fence and ATP Rule Data to Pegging
            l_pegging_rec.infinite_time_fence := l_infinite_time_fence_date;
            l_pegging_rec.atp_rule_name := l_atp_rule_name;
            -- End Bug 3036513
             -- Bug 3826234
            l_pegging_rec.manufacturing_cal_code :=  l_calendar_code;
            l_pegging_rec.organization_type  := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920

            MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

          END IF;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('in get_res_requirements we are here 1');
        END IF;
        FOR i in 1..l_atp_period.Level.COUNT LOOP
            l_atp_period.Pegging_Id(i) := l_pegging_id;
            l_atp_period.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;

        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('in get_res_requirements we are here 2');
        END IF;

	-- dsting supply/demand details pl/sql tables no longer used
/*
        FOR i in 1..l_atp_supply_demand.Level.COUNT LOOP
            l_atp_supply_demand.Pegging_Id(i) := l_pegging_id;
            l_atp_supply_demand.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;
        END LOOP;
*/

	IF p_insert_flag <> 0 THEN
		MSC_ATP_DB_UTILS.move_SD_temp_into_mrp_details(l_pegging_id,
				      MSC_ATP_PVT.G_DEMAND_PEGGING_ID);
	END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('in get_res_requirements we are here 3');
        END IF;

        -- Bug 4108546
        -- Re-set the Period Data for HP Display

        FOR k IN 1..l_atp_period.level.COUNT LOOP
            IF (l_res_ptf_indx IS NOT NULL) THEN
               IF k <= l_res_ptf_indx THEN
                  l_atp_period.Cumulative_Quantity(k) := 0;
               ELSIF l_atp_period.Cumulative_Quantity(k)
                     <> MSC_ATP_PVT.INFINITE_NUMBER  THEN
                  l_atp_period.Cumulative_Quantity(k) :=
                  l_atp_period.Cumulative_Quantity(k) - l_res_qty_before_ptf;
               END IF;
               IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Res_Requirements: ' ||
                       'l_atp_period.Cumulative_Quantity(' || k || ') := ' ||
                           l_atp_period.Cumulative_Quantity(k));
               END IF;
            END IF;
        END LOOP;
        -- End Bug 4108546

        MSC_ATP_PROC.Details_Output(l_atp_period,
                       l_atp_supply_demand,
                       x_atp_period,
                       x_atp_supply_demand,
                       l_return_status);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('in get_res_requirements we are here 4');
        END IF;

        -- Bug 2814872
        IF (MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 2 AND p_search = 2 AND
                                  x_atp_date >= p_parent_ship_date) THEN
        -- No need to look at other resources in forward pass as for this resource
        -- the availability date is greater than or equal to the parent's ATP date.
        -- Note that when p_parent_ship_date is NULL all resources will get visited.
           IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Res_Requirements date obtained for parent item is better');
               msc_sch_wb.atp_debug('Get_Res_Requirements date for parent item :' ||
                                                                     p_parent_ship_date);
               msc_sch_wb.atp_debug('Get_Res_Requirements date obtained for Resource :' ||
                                                     l_resource_id || ' is ' || x_atp_date);
           END IF;
           EXIT; -- Exit the loop
        ELSE -- diagnostic ATP or resource provides better date.
           j := l_res_requirements.resource_id.NEXT(j);
        END IF;
        -- End Bug 2814872;

      END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Get_Res_Requirements Procedure *****');
  END IF;
Exception
    WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN --bug3583705
       IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Res_Requirements ' || 'No match for sysdate in cal');
       END IF;
     RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF PG_DEBUG in ('Y', 'C') THEN --bug3583705
           msc_sch_wb.atp_debug('Get_Res_Requirements ' || 'inside when others');
           msc_sch_wb.atp_debug ('error := ' || SQLERRM);
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Res_Requirements;


PROCEDURE Get_Comp_Requirements (
  p_instance_id				IN    NUMBER,
  p_plan_id                             IN    NUMBER,
  p_level 				IN    NUMBER,
  p_scenario_id				IN    NUMBER,
  p_inventory_item_id                   IN    NUMBER,
  p_organization_id                     IN    NUMBER,
  p_parent_pegging_id                   IN    NUMBER,
  p_demand_class			IN    VARCHAR2,
  p_requested_quantity			IN    NUMBER,
  p_requested_date		        IN    DATE,
  p_refresh_number			IN    NUMBER,
  p_insert_flag				IN    NUMBER,
  p_search                              IN    NUMBER,
  p_assign_set_id                       IN    NUMBER,
  --(ssurendr) Bug 2865389 Added routing Sequence id and Bill sequence id for OPM issue.
  p_routing_seq_id                      IN    NUMBER,
  p_bill_seq_id                         IN    NUMBER,
  p_family_id                           IN    NUMBER,   -- For time_phased_atp
  p_atf_date                            IN    DATE,     -- For time_phased_atp
  p_manufacturing_cal_code              IN    VARCHAR2, -- For ship_rec_cal
  x_avail_assembly_qty			OUT   NoCopy NUMBER,
  x_atp_date                            OUT   NoCopy DATE,
  x_atp_period                          OUT   NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT   NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT   NoCopy VARCHAR2,
  p_comp_info_rec                       IN OUT NOCOPY MSC_ATP_REQ.get_comp_info_rec,
  p_order_number                        IN    NUMBER := NULL,
  p_op_seq_id                           IN    NUMBER --4570421
       -- Add new parameter with default value to support creation of
       -- Sales Orders for CTO components in a MATO case.
)
IS
l_comp_requirements 		MRP_ATP_PVT.Atp_Comp_Typ;
l_explode_comp                  MRP_ATP_PVT.Atp_Comp_Typ;
l_atp_period_tab                MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_atp_qty_tab                   MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_requested_date_quantity	number;
l_resource_id			number;
l_department_id 		number;
l_requested_date 		date;
l_resource_usage 		number;
l_basis_type 			number;
l_requested_res_qty		number;
l_avail_assembly_qty		number;
l_next_period			date;
i				PLS_INTEGER;
j				PLS_INTEGER;
l_requested_comp_qty		number;
l_atp_rec               	MRP_ATP_PVT.AtpRec;
l_atp_period            	MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand     	MRP_ATP_PUB.ATP_Supply_Demand_Typ;

l_comp_item_id			number;
l_comp_usage			number;
--4570421
l_scaling_type                  NUMBER;
l_scale_multiple                number;
l_scale_rounding_variance       number;
l_rounding_direction            number;
l_component_yield_factor        NUMBER;
l_usage_qty                     NUMBER;
l_op_seq_id                     NUMBER; --4570421
l_comp_date			date;
l_comp_lead_time		number;
l_comp_pre_pro_lead_time	number;
l_comp_wip_supply_type		number;
l_comp_assembly_identifier	number;
l_comp_component_identifier	number;
l_plan_id                       number;
l_assign_set_id                 number;
l_cto_bom                       number := 0;
l_routing_type	        	number;
l_first_op_RCY			number;
-- l_inv_item_id             	number; -- Not required after 3004862 fix
l_processing_lead_time    	number;
l_temp_date		        DATE;
l_mso_lead_time_factor		number;
l_pre_processing_lead_time	NUMBER;
l_fix_var_lead_time		NUMBER;
l_future_order_date             DATE;
l_ptf_date                      DATE;
l_ptf_flag			NUMBER;
l_plan_info_rec                 MSC_ATP_PVT.plan_info_rec;      -- added for bug 2392456

l_comp_source_organization_id   NUMBER; -- krajan : 2400614
l_comp_atp_flag_src             VARCHAR2(1); -- krajan : 2462661

l_reverse_cumulative_yield      NUMBER;

--(3004862) circular BOM issue
l_bill_seq_id                   NUMBER;
l_routing_seq_id                NUMBER;
l_process_seq_id                NUMBER;

----OSFM Changes
--- cursor  for network routing

-- 2869830
l_rounding_flag                 number;

--s_cto_rearch
l_component_date               date;
l_model_flag                   number :=2;
L_PLAN_FOUND_FOR_MATCH         number;
L_MODEL_ATP_COMP_FLAG          varchar2(1);
L_MATCH_ITEM_ID                number;
L_CTO_BOM_REC                  MRP_ATP_PVT.Atp_Comp_Typ;
l_lead_time                    number;
L_REQUEST_DATE                 date;
L_MAND_COMP_INFO_REC           MSC_ATP_CTO.mand_comp_info_rec;
l_atp_comp_rec                 MRP_ATP_PVT.ATP_COMP_REC;
l_null_atp_comp_rec            MRP_ATP_PVT.ATP_COMP_REC;
l_item_info_rec                MSC_ATP_PVT.item_attribute_rec;
l_model_error_code                  number := 0;
--e_cto_rearch

-- time_phased_atp
l_atf_date                     date;
l_pegging_rec                  mrp_atp_details_temp%ROWTYPE;
l_org_code                     varchar2(7);
l_pegging_id                   number;
l_return_status                varchar2(1);
l_network_scheduling_method    NUMBER; --bug3601223
l_first_op_seq_num			   NUMBER; -- Bug 4143668

-- ATP4drp default variables
l_def_wip_sup_type             NUMBER := 1;
l_def_atf_date                 DATE := NULL;
l_comp_uom                    varchar2(3); --bug3110023

CURSOR net_rout_comp (l_bill_seq_id number, --(3004862) circular BOM issue: changed cursor parameter
             l_requested_date date,
             l_requested_quantity number,
             l_wip_supply_type number) IS --4106269
    select  v1.SR_INVENTORY_ITEM_ID,
            v1.INVENTORY_ITEM_ID,
            v1.qty,
            v1.CALENDAR_DATE,
            v1.PROCESSING_LEAD_TIME,
            v1.WIP_SUPPLY_TYPE,
            v1.PREPROCESSING_LEAD_TIME,
            v1.REVERSE_CUMULATIVE_YIELD,
            v1.AGGREGATE_TIME_FENCE_DATE,
            v1.UOM_CODE, --bug3110023
            v1.scaling_type,
            v1.SCALE_MULTIPLE,
            v1.SCALE_ROUNDING_VARIANCE,
            v1.ROUNDING_DIRECTION,
            v1.component_yield_factor,
            v1.usage_qty --4775920
    from
       (SELECT   I2.SR_INVENTORY_ITEM_ID,
                I2.INVENTORY_ITEM_ID, --(3004862) circular BOM issue: also select destination id
                --4570421
                --4862863, dividing by assembly_qty only in non-lot and non-fix cases.
                ROUND ((decode (NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG), 1, decode (nvl (mbc.scaling_type, 1), 1, (MBC.USAGE_QUANTITY*l_requested_quantity)
                                                                                                                                                /Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1),
	                                                                                                                                    2,  MBC.USAGE_QUANTITY),
	                                                                            MSC_ATP_PVT.OPM_ORG, decode (nvl (mbc.scaling_type, 1), 0,  MBC.USAGE_QUANTITY,
	                                                                                                                                    1, (MBC.USAGE_QUANTITY*l_requested_quantity)
	                                                                                                                                        /Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1),
	                                                                                                                                    2,  MBC.USAGE_QUANTITY,
	                                                                                                                                    3, (MBC.USAGE_QUANTITY*l_requested_quantity)
	                                                                                                                                        /Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1),
	                                                                                                                                    4, (MBC.USAGE_QUANTITY*l_requested_quantity)
	                                                                                                                                        /Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1),
	                                                                                                                                    5, (MBC.USAGE_QUANTITY*l_requested_quantity)
	                                                                                                                                        /Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1))
	               ))
	               --/Decode (MSC_ATP_PVT.G_PLAN_COPRODUCTS, 'Y', NVL (BOMS.ASSEMBLY_QUANTITY,1), 1) --4862863
	                  * DECODE (l_routing_type, 3,Decode (l_network_scheduling_method,
	                                                      2,(NVL(OP.NET_PLANNING_PERCENT,100)/100),1), 1)
	                 --/NVL (OP.REVERSE_CUMULATIVE_YIELD, DECODE (l_routing_type, 3, NVL (l_first_op_RCY, 1), 1))
	                 /DECODE(OP.REVERSE_CUMULATIVE_YIELD,
                                0,
                                DECODE(l_routing_type,
                                       3, NVL(l_first_op_RCY, 1)
                                       ,1
                                       ),
                                       NVL(OP.REVERSE_CUMULATIVE_YIELD, DECODE(l_routing_type,
                                                                               3,
                                                                               NVL(l_first_op_RCY, 1),1
                                                                               )
                                           )
                                )
	                 --/NVL (mbc.component_yield_factor, 1) --4767982
	        ,6) qty,
                C2.CALENDAR_DATE,
                --bug 4106269 changes start here
                /*----------------------------------------------------------------------
                We will include the Lead time for phantom items based on following parameter
                1)MSC: ATP explode phantom components
                2)Bom Parameter -Use Phantom Routing
                3)Bom Parameter -Inherit Phantom Op-Seq
                Various combinations are
                Case1 :
                MSC: ATP explode phantom components =Yes
                Use Phantom Routing =N/a
                Inherit Phantom Op-Seq =N/a

                Creates supply for ATPable phantom and uses its LT and Routing like a standard item.

                Case 2:
                MSC: ATP explode phantom components =No
                Use Phantom Routing =No
                Inherit Phantom Op-Seq =No

		Ignore ATPable phantom's Lead Time for calculating components requirement dates.
		Phantom is exploded to its components and no supply/resource requirements are created for phantom.


		Case 3:
		MSC: ATP explode phantom components =No
                Use Phantom Routing =Yes
                Inherit Phantom Op-Seq =No

                Adds ATPable phantom's Lead Time for calculating components requirement dates.
                Phantom is exploded to its components and no supply/resource requirements are created for phantom.

                Case 4:
                MSC: ATP explode phantom components =No
                Use Phantom Routing =No
                Inherit Phantom Op-Seq =Yes

                Ignore ATPable phantom's Lead Time for calculating components requirement dates.
                Phantom is exploded to its components and no supply/resource requirements are created for phantom.

                Case 5:

		MSC: ATP explode phantom components =No
                Use Phantom Routing =Yes
                Inherit Phantom Op-Seq =Yes

                Adds ATPable phantom's Lead Time for calculating components requirement dates.
                Phantom is exploded to its components and no supply/resource requirements are created for phantom.
                --------------------------------------------------------------------------*/
                DECODE(l_wip_supply_type,
       				       6,
       				 	DECODE(MSC_ATP_PVT.G_EXPLODE_PHANTOM,
       					'N',
       					decode(nvl(MSC_ATP_PVT.G_ORG_INFO_REC.use_phantom_routings,2),
       					       2,
       					       0,
       					       CEIL((NVL(I.FIXED_LEAD_TIME,0)+
       				                     NVL(I.VARIABLE_LEAD_TIME,0)*
       					                 l_requested_quantity
       					                 )
       					                 *(1 + l_mso_lead_time_factor)
       						      )
       						     ),
       						     CEIL( ( NVL(I.FIXED_LEAD_TIME,0)+
       							     NVL(I.VARIABLE_LEAD_TIME,0)*
       							     l_requested_quantity
       							    )*
       							   (1 + l_mso_lead_time_factor)
       							  )
       					        ),
       						CEIL((NVL(I.FIXED_LEAD_TIME,0)+
       						      NVL(I.VARIABLE_LEAD_TIME,0)*
       						      l_requested_quantity)*
       						      (1 + l_mso_lead_time_factor)
       						     )
       		        ) PROCESSING_LEAD_TIME,
       		        --4106269
                MBC.WIP_SUPPLY_TYPE,
                --bug3609031 adding ceil
                NVL(ceil(I.PREPROCESSING_LEAD_TIME),0) PREPROCESSING_LEAD_TIME,
                --diag_atp
                --NVL(OP.REVERSE_CUMULATIVE_YIELD, DECODE(l_routing_type, 3, NVL(l_first_op_RCY, 1),1)) REVERSE_CUMULATIVE_YIELD,
                DECODE(OP.REVERSE_CUMULATIVE_YIELD,0,DECODE(l_routing_type, 3, NVL(l_first_op_RCY, 1),1),NVL(OP.REVERSE_CUMULATIVE_YIELD, DECODE(l_routing_type, 3, NVL(l_first_op_RCY, 1),1))) REVERSE_CUMULATIVE_YIELD, --4694958
                -- time_phased_atp
                I2.AGGREGATE_TIME_FENCE_DATE,
                OP.OPERATION_SEQUENCE_ID,
                I2.UOM_CODE, --bug3110023
                --4570421
                mbc.scaling_type scaling_type,
                mbc.scale_multiple scale_multiple,
                mbc.scale_rounding_variance scale_rounding_variance,
                mbc.rounding_direction rounding_direction,
                mbc.component_yield_factor component_yield_factor,
                MBC.USAGE_QUANTITY*mbc.component_yield_factor usage_qty --4775920
       FROM     MSC_SYSTEM_ITEMS I2,
                MSC_CALENDAR_DATES C2,
	        MSC_CALENDAR_DATES C1,
                MSC_BOM_COMPONENTS MBC,
                MSC_BOMS BOMS,
                MSC_SYSTEM_ITEMS  I,
	        MSC_OPERATION_COMPONENTS OPC,
                MSC_ROUTING_OPERATIONS OP
       WHERE    I.PLAN_ID = BOMS.PLAN_ID
       AND      I.SR_INSTANCE_ID = BOMS.SR_INSTANCE_ID
       AND      I.INVENTORY_ITEM_ID = BOMS.ASSEMBLY_ITEM_ID
       AND      I.ORGANIZATION_ID = BOMS.ORGANIZATION_ID
       AND      BOMS.PLAN_ID = p_plan_id
       AND      BOMS.SR_INSTANCE_ID = p_instance_id
       AND      BOMS.ORGANIZATION_ID = p_organization_id
       AND      BOMS.BILL_SEQUENCE_ID = l_bill_seq_id --(3004862) circular BOM issue: use cursor parameter
       --(ssurendr) Bug 2865389 Removed condition for Alternate bom designator as
       --we are accessing bom by bill sequance id.
       --We can now drive by msc_boms for performance gains
       --AND      BOMS.ALTERNATE_BOM_DESIGNATOR IS NULL
       AND      MBC.USAGE_QUANTITY > 0
       AND      MBC.BILL_SEQUENCE_ID = BOMS.BILL_SEQUENCE_ID
       AND      MBC.PLAN_ID = I.PLAN_ID
       AND      MBC.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       --s_cto_rearch: we do not look at atp flags any more. Slection of components is contolled by
       --atp flags setting of the components itself
       --AND      MBC.ATP_FLAG = 1
       /* rajjain 3008611
        * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
        * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       AND      TRUNC(NVL(MBC.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                        TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       AND      TRUNC(MBC.EFFECTIVITY_DATE) <=
                        TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
       AND      C1.CALENDAR_DATE = l_requested_date
       AND      C1.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       --4106269
       AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM -  DECODE(l_wip_supply_type,
       				       6,
       				 	DECODE(MSC_ATP_PVT.G_EXPLODE_PHANTOM,
       					'N',
       					decode(nvl(MSC_ATP_PVT.G_ORG_INFO_REC.use_phantom_routings,2),
       					       2,
       					       0,
       					       CEIL((NVL(I.FIXED_LEAD_TIME,0)+
       				                     NVL(I.VARIABLE_LEAD_TIME,0)*
       					                 l_requested_quantity
       					                 )
       					                 *(1 + l_mso_lead_time_factor)
       						      )
       						     ),
       						     CEIL( ( NVL(I.FIXED_LEAD_TIME,0)+
       							     NVL(I.VARIABLE_LEAD_TIME,0)*
       							     l_requested_quantity
       							    )*
       							   (1 + l_mso_lead_time_factor)
       							  )
       					        ),
       						CEIL((NVL(I.FIXED_LEAD_TIME,0)+
       						      NVL(I.VARIABLE_LEAD_TIME,0)*
       						      l_requested_quantity)*
       						      (1 + l_mso_lead_time_factor)
       						     )
       		        )--4106269
       AND      C2.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       AND      I2.INVENTORY_ITEM_ID = MBC.INVENTORY_ITEM_ID
       AND      I2.ORGANIZATION_ID =MBC.ORGANIZATION_ID
       AND      I2.PLAN_ID = I.PLAN_ID
       --4570421
       AND      C1.CALENDAR_CODE = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_CODE
       AND      C1.EXCEPTION_SET_ID = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_EXCEPTION_SET_ID
       AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       AND      C2.EXCEPTION_SET_ID = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_EXCEPTION_SET_ID
       --s_cto_rearch
       -- select only atpable components. For model and option class, we do not look at atp components
       --flag as they do not carry any significance once config is created
       AND (I2.atp_flag <> 'N' or I2.atp_components_flag <> DECODE(I2.BOM_ITEM_TYPE,
                                                                          1, I2.atp_components_flag,
                                                                          2, I2.atp_components_flag,
                                                                          'N'))
       AND      I2.SR_INSTANCE_ID = I.SR_INSTANCE_ID
       AND      nvl(MBC.WIP_SUPPLY_TYPE,1) <> 5  --7354119,8413492, to filter out records where wip_supply_type is supplier
       AND      OPC.PLAN_ID (+) = MBC.PLAN_ID
       AND      OPC.ORGANIZATION_ID (+) = MBC.ORGANIZATION_ID
       AND      OPC.SR_INSTANCE_ID (+) = MBC.SR_INSTANCE_ID
       AND      OPC.COMPONENT_SEQUENCE_ID (+) = MBC.COMPONENT_SEQUENCE_ID
       AND      OPC.BILL_SEQUENCE_ID (+) = MBC.BILL_SEQUENCE_ID
       AND      OP.PLAN_ID (+) = OPC.PLAN_ID
       AND      OP.SR_INSTANCE_ID (+) = OPC.SR_INSTANCE_ID
       AND      OP.OPERATION_SEQUENCE_ID (+) = OPC.OPERATION_SEQUENCE_ID
       AND      OP.ROUTING_SEQUENCE_ID (+) = OPC.ROUTING_SEQUENCE_ID ) v1
       --bug3601223 get the components that are used on primary path
    where       l_routing_type <> 3
       OR       l_network_scheduling_method = 2
       OR       v1.OPERATION_SEQUENCE_ID IS NULL
       OR       v1.OPERATION_SEQUENCE_ID IN
                              ( SELECT FROM_OP_SEQ_ID
                                FROM  MSC_OPERATION_NETWORKS
                                WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = p_routing_seq_id
				AND    TRANSITION_TYPE = 1

                                UNION ALL

                                SELECT TO_OP_SEQ_ID
				FROM  MSC_OPERATION_NETWORKS
				WHERE  PLAN_ID = p_plan_id
				AND    SR_INSTANCE_ID = p_instance_id
				AND    ROUTING_SEQUENCE_ID = p_routing_seq_id
				AND    TRANSITION_TYPE = 1
			      );

-- ATP4drp New Cursor for handling DRP Kitting.
-- Routing, Net Planning Percent and Operations not applicable for DRP plans.
-- Co-products also not applicable for DRP plans.
CURSOR drp_comp (l_bill_seq_id number, --(3004862) circular BOM issue: changed cursor parameter
             l_requested_date date,
             l_requested_quantity number) IS
       SELECT   I2.SR_INVENTORY_ITEM_ID,
                I2.INVENTORY_ITEM_ID, --(3004862) circular BOM issue: also select destination id
                --ROUND((MBC.USAGE_QUANTITY * l_requested_quantity ),6),
                --4570421
                ROUND ((decode (NVL (MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG), 1, decode ( nvl(mbc.scaling_type, 1), 1,  (MBC.USAGE_QUANTITY*l_requested_quantity),
	                                                                                                                                   2, MBC.USAGE_QUANTITY),
	                                                                           MSC_ATP_PVT.OPM_ORG, decode (nvl (mbc.scaling_type, 1), 0, MBC.USAGE_QUANTITY,
	                                                                                                                                   1, (MBC.USAGE_QUANTITY*l_requested_quantity),
	                                                                                                                                   2, MBC.USAGE_QUANTITY,
	                                                                                                                                   3, (MBC.USAGE_QUANTITY*l_requested_quantity),
	                                                                                                                                   4, (MBC.USAGE_QUANTITY*l_requested_quantity),
	                                                                                                                                   5, (MBC.USAGE_QUANTITY*l_requested_quantity))
	               )) --/NVL (mbc.component_yield_factor, 1)     --4767982
	               ,6),
                C2.CALENDAR_DATE,
                CEIL((NVL(MSC_ATP_PVT.G_ITEM_INFO_REC.FIXED_LT,0)+
                        NVL(MSC_ATP_PVT.G_ITEM_INFO_REC.VARIABLE_LT,0)* l_requested_quantity)*(1 + l_mso_lead_time_factor)),
                DECODE(MBC.WIP_SUPPLY_TYPE, 6, l_def_wip_sup_type, MBC.WIP_SUPPLY_TYPE), -- phantoms not be supported for DRP plans
                NVL(ceil(MSC_ATP_PVT.G_ITEM_INFO_REC.PRE_PRO_LT),0),
                1, -- default for RCY Yield unsuppored for DRP plans.
                l_def_atf_date, -- ATF will be NULL as a default for DRP plans.
                I2.UOM_CODE, --bug3110023
                --4570421
                mbc.scaling_type,
                mbc.scale_multiple,
                mbc.scale_rounding_variance ,
                mbc.rounding_direction,
                mbc.component_yield_factor, --4570421
                MBC.USAGE_QUANTITY*mbc.component_yield_factor --4775920
       FROM     MSC_SYSTEM_ITEMS I2,
                MSC_CALENDAR_DATES C2,
	        MSC_CALENDAR_DATES C1,
                MSC_BOM_COMPONENTS MBC,
                MSC_BOMS BOMS
       WHERE    BOMS.PLAN_ID = p_plan_id
       AND      BOMS.SR_INSTANCE_ID = p_instance_id
       AND      BOMS.ORGANIZATION_ID = p_organization_id
       AND      BOMS.BILL_SEQUENCE_ID = l_bill_seq_id --(3004862) circular BOM issue: use cursor parameter
       AND      MBC.USAGE_QUANTITY > 0
       AND      MBC.BILL_SEQUENCE_ID = BOMS.BILL_SEQUENCE_ID
       AND      MBC.PLAN_ID = BOMS.PLAN_ID
       AND      MBC.SR_INSTANCE_ID = BOMS.SR_INSTANCE_ID
       AND      TRUNC(NVL(MBC.DISABLE_DATE, GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                        TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE))
       AND      TRUNC(MBC.EFFECTIVITY_DATE) <=
                        TRUNC(GREATEST(C2.CALENDAR_DATE, sysdate, MSC_ATP_PVT.G_PTF_DATE)) -- bug 1404312
       AND      C1.CALENDAR_DATE = l_requested_date
       AND      C1.SR_INSTANCE_ID = BOMS.SR_INSTANCE_ID
       AND      C1.CALENDAR_CODE = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_CODE
       AND      C1.EXCEPTION_SET_ID = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_EXCEPTION_SET_ID
       AND      C2.SEQ_NUM = C1.PRIOR_SEQ_NUM - CEIL((NVL(MSC_ATP_PVT.G_ITEM_INFO_REC.FIXED_LT,0)+
                        NVL(MSC_ATP_PVT.G_ITEM_INFO_REC.VARIABLE_LT,0)* l_requested_quantity)*(1 + l_mso_lead_time_factor))
       AND      C2.CALENDAR_CODE = C1.CALENDAR_CODE
       AND      C2.SR_INSTANCE_ID = C1.SR_INSTANCE_ID
       AND      C2.EXCEPTION_SET_ID = MSC_ATP_PVT.G_ORG_INFO_REC.CAL_EXCEPTION_SET_ID
       AND      I2.INVENTORY_ITEM_ID = MBC.INVENTORY_ITEM_ID
       AND      I2.ORGANIZATION_ID =MBC.ORGANIZATION_ID
       AND      I2.PLAN_ID = BOMS.PLAN_ID
                -- select only atpable components.
       AND      I2.atp_flag <> 'N'
       AND      I2.SR_INSTANCE_ID = BOMS.SR_INSTANCE_ID;
-- End ATP4drp New Cursor for handling DRP Kitting.

CURSOR cto_comp (l_inventory_item_id number,
             l_requested_date date,
             l_requested_quantity number,
             l_wip_supply_type number) IS
       SELECT   mbt.component_item_id,
                (mbt.quantity * l_requested_quantity),
                c2.calendar_date,
                DECODE(l_wip_supply_type,
			6, 0,
			CEIL((NVL(mbt.fixed_lt,0)+
                        NVL(mbt.variable_lt,0) * l_requested_quantity)*(1 + l_mso_lead_time_factor))) lead_time,
                wip_supply_type,
		mbt.assembly_identifier,
		mbt.component_identifier,
                mbt.pre_process_lt,
                -- krajan : 2400614
                mbt.source_organization_id,
                -- krajan : 2462661
                mbt.atp_flag
       FROM     msc_bom_temp mbt,
                msc_calendar_dates c2,
                msc_calendar_dates c1,
                msc_trading_partners tp
       WHERE	mbt.session_id = MSC_ATP_PVT.G_SESSION_ID
       --AND      mbt.assembly_identifier = MSC_ATP_PVT.G_ASSEMBLY_LINE_ID
       AND      mbt.assembly_identifier = MSC_ATP_PVT.G_COMP_LINE_ID
       AND      mbt.assembly_item_id = l_inventory_item_id
       /* rajjain 3008611
        * effective date should be greater than or equal to greatest of PTF date, sysdate and start date
        * disable date should be less than or equal to greatest of PTF date, sysdate and start date*/
       AND      TRUNC(NVL(mbt.disable_date, GREATEST(sysdate, c2.calendar_date, MSC_ATP_PVT.G_PTF_DATE)+1)) >
                  TRUNC(GREATEST(sysdate, c2.calendar_date, MSC_ATP_PVT.G_PTF_DATE))
       AND      TRUNC(mbt.effective_date) <=
                  TRUNC(GREATEST(sysdate, c2.calendar_date, MSC_ATP_PVT.G_PTF_DATE))
       AND	c1.calendar_date = l_requested_date
       AND      c1.sr_instance_id = tp.sr_instance_id
       AND      c1.calendar_code = tp.calendar_code
       AND      c1.exception_set_id = tp.calendar_exception_set_id
       AND      tp.sr_instance_id = p_instance_id
       AND      tp.sr_tp_id = p_organization_id
       AND      tp.partner_type = 3
       AND      c2.seq_num = c1.prior_seq_num -
                             DECODE(l_wip_supply_type,
                                6, 0,
                                CEIL((NVL(mbt.fixed_lt,0)+
                                     NVL(mbt.variable_lt,0) * l_requested_quantity)*(1 + l_mso_lead_time_factor)))
       AND      c2.calendar_code = tp.calendar_code
       AND      c2.sr_instance_id = tp.sr_instance_id
       AND      c2.exception_set_id = tp.calendar_exception_set_id;

BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Get_Comp_Requirements *****');
    END IF;

    -- Now get the material requirement
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_instance_id = '||p_instance_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_plan_id = '||p_plan_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_level = '||p_level);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_scenario_id = '||p_scenario_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_inventory_item_id = '||p_inventory_item_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_organization_id = '||p_organization_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_parent_pegging_id = '||p_parent_pegging_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_demand_class = '||p_demand_class);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_requested_quantity = '||p_requested_quantity);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_requested_date = '||p_requested_date);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_search = '||p_search);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_assign_set_id = '||p_assign_set_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_order_number = '||p_order_number);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_routing_seq_id = '||p_routing_seq_id);
       msc_sch_wb.atp_debug('bom_item_type := ' || p_comp_info_rec.bom_item_type);
       msc_sch_wb.atp_debug('atp flag := ' || p_comp_info_rec.atp_flag);
       msc_sch_wb.atp_debug('atp_comp_flag := ' || p_comp_info_rec.atp_comp_flag);
       msc_sch_wb.atp_debug('p_bill_seq_id := ' || p_bill_seq_id);
        msc_sch_wb.atp_debug('parent_so_quantity := ' || p_comp_info_rec.parent_so_quantity);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_family_id := ' || p_family_id);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_atf_date := ' || p_atf_date);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'TOP_MODEL_LINE_ID :=' || p_comp_info_rec.TOP_MODEL_LINE_ID);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'ATO_MODEL_LINE_ID :=' || p_comp_info_rec.ATO_MODEL_LINE_ID);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'ATO_PARENT_MODEL_LINE_ID := ' || p_comp_info_rec.ATO_PARENT_MODEL_LINE_ID);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'PARENT_LINE_ID := ' || p_comp_info_rec.PARENT_LINE_ID);
       --bug 3059305
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'ship date this level := '
                                                      || p_comp_info_rec.ship_date_this_level);


    END IF;
    --S_cto_rearch: If ATP flag on config is 'Y, N' then we check base model's
    -- cpacity based on bom level atp flag and atp flags of base model
    -- In this case we just need to check capacity on model. So model is only
    --component we need to check capacity on.
    MSC_ATP_PROC.get_global_item_info(p_instance_id,
                                      --3917625: Read data from the plan
                                      -- -1,
                                      p_plan_id,
                                      p_inventory_item_id,
                                      p_organization_id,
                                      l_item_info_rec);
    IF  p_comp_info_rec.check_model_capacity_flag = 1 THEN
       --check model's capacity. Add model to comp array

       MSC_ATP_REQ.Extend_Atp_Comp_Typ(l_comp_requirements);

       l_comp_requirements.inventory_item_id(1) :=  MSC_ATP_PF.Get_PF_Atp_Item_Id(
                                                                p_instance_id,
                                                                -1, -- plan_id
                                                                p_comp_info_rec.model_sr_inv_item_id,
                                                                p_organization_id
                                                        );
       l_comp_requirements.request_item_id(1) :=
                         p_comp_info_rec.model_sr_inv_item_id;

       -- I used this comp_usaget to store the required quantity at this level.
       l_comp_requirements.comp_usage(1) := p_requested_quantity;

       l_comp_requirements.requested_date(1) := p_requested_date;

       -- assume the wip supply type to be 1 (as long as it is not phantom)
       l_comp_requirements.wip_supply_type(1) := 1;
       l_comp_requirements.component_identifier(1) := MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;

       l_comp_requirements.bom_item_type(1) :=  1; -- hard code to model's bom type
       l_comp_requirements.parent_so_quantity(1) := p_comp_info_rec.parent_so_quantity;
       l_comp_requirements.assembly_identifier(1) :=  null;
       l_comp_requirements.top_model_line_id(1) := null;
       l_comp_requirements.ato_parent_model_line_id(1) := null;
       l_comp_requirements.ato_model_line_id(1) := null;
       l_comp_requirements.parent_line_id(1) := null;
       l_comp_requirements.fixed_lt(1) := 0;
       l_comp_requirements.variable_lt(1) := 0;
       l_comp_requirements.dest_inventory_item_id(1) :=  null;
       l_comp_requirements.lead_time(1) := 0;

    ELSE

       -- assign this assembly into the l_explode_comp record of tables.
       -- we will loop through this l_explode_comp to do the explosion.
       -- And we will add phantom item into this l_explode_comp so that
       -- we can explode through phantom.
       MSC_ATP_REQ.Extend_Atp_Comp_Typ(l_explode_comp);

       l_explode_comp.inventory_item_id(1) := p_inventory_item_id;

       -- I used this comp_usaget to store the required quantity at this level.
       l_explode_comp.comp_usage(1) := p_requested_quantity;

       l_explode_comp.requested_date(1) := p_requested_date;

       -- assume the wip supply type to be 1 (as long as it is not phantom)
       l_explode_comp.wip_supply_type(1) := 1;
       l_explode_comp.component_identifier(1) := MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;

       l_explode_comp.bom_item_type(1) :=  p_comp_info_rec.bom_item_type;
       l_explode_comp.parent_so_quantity(1) := p_comp_info_rec.parent_so_quantity;
       l_explode_comp.assembly_identifier(1) :=  p_comp_info_rec.line_id;
       l_explode_comp.top_model_line_id(1) := p_comp_info_rec.top_model_line_id;
       l_explode_comp.ato_parent_model_line_id(1) := p_comp_info_rec.ato_parent_model_line_id;
       l_explode_comp.ato_model_line_id(1) := p_comp_info_rec.ato_model_line_id;
       l_explode_comp.parent_line_id(1) := p_comp_info_rec.parent_line_id;
       l_explode_comp.fixed_lt(1) := p_comp_info_rec.fixed_lt;
       l_explode_comp.variable_lt(1) := p_comp_info_rec.variable_lt;
       l_explode_comp.dest_inventory_item_id(1) :=  MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id;

       --(3004862) circular BOM issue - initialize with end item's destination id.

        /*---bug 2680027: Extend lead_time field. This field will contain lead time of  the parent if
         the current comp is a phontom
       --We need to remember this lead time so that it could be passed to the component of the phantom

                    If Bom IS
                       A
                       |  Lead _time = 10
                       B
                       |  Lead time = 5
                       C
               If B is phantom then prior to this fix we were effectively saying that lead time between A and C is 5 days
               It should be 15 days instead. So in lead time field, we are going to save 0 form A
               as A doesn't have any par ent.
               For B, this filed will contain 10 as lead time between B and its Parent A is 10 days.

       */
       l_explode_comp.lead_time(1) := 0;
    END IF; --- p_comp_info_rec.check_model_capacity_flag = 1 THEN

    l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;
       --- get mso_sco_lead_time_factor
    l_mso_lead_time_factor := MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR;
    l_network_scheduling_method := MSC_ATP_PVT.G_ORG_INFO_REC.network_scheduling_method; --bug3601223

     IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'MSO LEAD TIME FACTOR =  ' || l_mso_lead_time_factor);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after assign the value');
       --bug3601223
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_network_scheduling_method = '|| l_network_scheduling_method);
    END IF;

    i :=  l_explode_comp.inventory_item_id.FIRST;
    l_bill_seq_id := p_bill_seq_id;  --(3004862) circular BOM issue

    -- Check if Records exist in MSC_BOM_TEMP table in case of PDS. If yes,
    -- open cto_comp cursor instead of cursor comp.

    -- 2869830
    l_rounding_flag := nvl(MSC_ATP_PVT.G_ITEM_INFO_REC.rounding_control_type, 2);

    -- 3027711 move this to the beginning
    -- initially set the x_avail_assembly_qty to the p_requested_quantity,
    -- and we adjust that later
    -- 2869830
    IF l_rounding_flag = 1 THEN
       x_avail_assembly_qty :=  CEIL(p_requested_quantity);
    ELSE
       x_avail_assembly_qty :=  trunc(p_requested_quantity, 6);    -- 5598066
    END IF;

    -- bug 2178544
    x_atp_date := GREATEST(p_requested_date, MSC_ATP_PVT.G_FUTURE_ORDER_DATE, MSC_ATP_PVT.G_FUTURE_START_DATE);
    l_ptf_date := MSC_ATP_PVT.G_PTF_DATE;

    IF p_bill_seq_id is null and p_comp_info_rec.check_model_capacity_flag = 2 THEN
       RETURN;
    END IF;
    -- end 3027711

    --s_cto_rearch
    IF p_comp_info_rec.bom_item_type = 1  and p_comp_info_rec.replenish_to_order_flag = 'Y' THEN
        IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('This is a model line');
        END IF;
        l_model_atp_comp_flag := p_comp_info_rec.atp_comp_flag;
        l_model_flag := p_comp_info_rec.bom_item_type;

        IF p_comp_info_rec.atp_flag = 'Y' THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Add this line to comp requirements table');
           END IF;
           --first extend the record
           MSC_ATP_REQ.Extend_Atp_Comp_Typ(l_comp_requirements);

           --now add the model iteself
           --l_comp_requirements.inventory_item_id(1) := p_inventory_item_id;
           /* time_phased_atp changes begin
              Support PF ATP for components*/
           -- check this with vivek if inventory_item_id, request_item_id and atf_date need to be populated for model
           l_comp_requirements.inventory_item_id(1) := p_family_id;
           l_comp_requirements.request_item_id(1) := p_inventory_item_id;
           l_comp_requirements.atf_date(1) := p_atf_date;
           -- time_phased_atp changes end

           l_comp_requirements.comp_usage(1) := 1;
           l_comp_requirements.requested_date(1) := p_requested_date;
           l_comp_requirements.lead_time(1) := 0;
           l_comp_requirements.wip_supply_type(1) := 1;
           l_comp_requirements.assembly_identifier(1) := p_comp_info_rec.line_id;
           l_comp_requirements.component_identifier(1) := null;
           l_comp_requirements.atp_flag(1) := p_comp_info_rec.atp_flag;
           l_comp_requirements.parent_item_id(1) := p_inventory_item_id;
        END IF;

    /* ELSIF  p_comp_info_rec.bom_item_type = 4 and p_comp_info_rec.replenish_to_order_flag = 'Y'
                                          and MSC_ATP_PVT.G_INV_CTP = 5 THEN
        l_model_flag := 1;
        l_model_atp_comp_flag := p_comp_info_rec.atp_comp_flag;
    */
    END IF;
    --e_cto_rearch

    --4570421
    l_routing_seq_id := p_routing_seq_id;
    l_op_seq_id := p_op_seq_id;

    WHILE i IS NOT NULL LOOP

       IF p_comp_info_rec.check_model_capacity_flag = 1 THEN
           -- we are checking only base model's capacity. Therefore, we already
           --have all the components we need. Threfore we exit out
           EXIT;
       END IF;

       -- l_inv_item_id  :=  MSC_ATP_PVT.G_ITEM_INFO_REC.dest_inv_item_id; -- Not required after 3004862 fix
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_explode_comp.component_identifier(' || i || ') : ' || l_explode_comp.component_identifier(i));
       END IF;

       -- Bug 4143668, reset routing type ti ensure correct data in between various iterations
       l_routing_type := NULL;

       -- 3027711
       IF l_routing_seq_id is not null THEN --4570421 replaced p_routing_seq_id by l_routing_seq_id
          BEGIN

             ---bug 2320808, set l_first_op_RCY to 1 if null
             -- Bug 4143668, Commented as separate SQLs will be used for routing_type, first_op_seq_num in msc_routings
             -- and l_first_op_RCY from msc_routing_operations
             /*
             SELECT r.cfm_routing_flag, NVL(op.reverse_cumulative_yield,1)
             INTO l_routing_type, l_first_op_RCY
             FROM msc_routings r, msc_routing_operations op
             WHERE r.plan_id = p_plan_id and
                   r.organization_id = p_organization_id and
                   r.sr_instance_id = p_instance_id and
                   -- r.assembly_item_id = l_inv_item_id and
                   -- (3004862) changed to l_explode_comp.component_identifier so that for i>1 phantom item's id is used.
                   r.assembly_item_id = l_explode_comp.component_identifier(i) and
                   r.routing_sequence_id = p_routing_seq_id and
                   --(ssurendr) Bug 2865389 Removed condition for Alternate Routing designator as
                   --we are accessing Routing by Routing sequance id.
                   --r.alternate_routing_designator IS NULL and
                   r.plan_id = op.plan_id and
                   r.sr_instance_id = op.sr_instance_id and
                                    --r.organization_id = op.organization_id and
                   r.routing_sequence_id = op.routing_sequence_id and
                   NVL(r.first_op_seq_num,op.operation_seq_num) = op.operation_seq_num and     -- bug4114765
                   rownum = 1; -- Bug 4143668, just pick one for case where r.first_op_seq_num is NULL
             */

             -- Bug 4143668, check routing type and first_op_seq_num at routing level
             -- Also removed check for assembly item and org as routing sequence, plan and instance is unique.
             SELECT r.cfm_routing_flag, r.first_op_seq_num
             INTO   l_routing_type, l_first_op_seq_num
             FROM   msc_routings r
             WHERE  r.plan_id = p_plan_id
             AND    r.sr_instance_id = p_instance_id
             AND    r.routing_sequence_id = l_routing_seq_id; --4570421 replaced p_routing_seq_id by l_routing_seq_id

             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_routing_type := ' || l_routing_type);
                msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'routing l_first_op_seq_num := ' || l_first_op_seq_num);
             END IF;

             -- Bug 4143668, check lowest op seq from routing operation as routing level data is only populated for network routings
             /* Not needed as of now as RCY is not populated for non-network routing.
             IF l_first_op_seq_num IS NULL THEN
                SELECT MIN(op.operation_seq_num)
                INTO   l_first_op_seq_num
                FROM   msc_routing_operations op
                WHERE  op.routing_sequence_id = p_routing_seq_id
                AND    op.sr_instance_id = p_instance_id
                AND    op.plan_id = p_plan_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'operations l_first_op_seq_num := ' || l_first_op_seq_num);
                END IF;
             END IF; 	-- IF l_first_op_seq_num IS NULL THEN
             */

             -- Bug 4143668, get first operation's RCY based on op seq num found earlier
             IF l_first_op_seq_num IS NOT NULL THEN
                SELECT DECODE(op.reverse_cumulative_yield,0,1,NVL(op.reverse_cumulative_yield,1)) --4694958
                INTO   l_first_op_RCY
                FROM   msc_routing_operations op
                WHERE  op.plan_id = p_plan_id
                AND    op.sr_instance_id = p_instance_id
                AND    op.routing_sequence_id = l_routing_seq_id --4570421 replaced p_routing_seq_id by l_routing_seq_id
                AND    op.operation_seq_num = l_first_op_seq_num
                and    op.operation_sequence_id = l_op_seq_id; --4570421

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_first_op_RCY := ' || l_first_op_RCY);
                END IF;
             ELSE
                l_first_op_RCY := 1; -- Bug 4143668, l_first_op_RCY to 1 if Null
             END IF; 	-- IF l_first_op_seq_num IS NOT NULL THEN
          EXCEPTION
              WHEN OTHERS THEN
                  -- Bug 4143668, add debug message for exception
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'exception in cfm: '|| sqlcode);
                     msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'set l_routing_type and l_first_op_RCY');
                  END IF;
                  l_routing_type := NVL(l_routing_type, 2); -- Bug 4143668, use l_routing_type if already set, else 2
                  l_first_op_RCY := 1; -- Bug 4143668, l_first_op_RCY to 1 for exception
          END;
       ELSE
          l_routing_type := NVL(l_routing_type, 2); -- Bug 4143668, use l_routing_type if already set, else 2
          l_first_op_RCY := 1; -- Bug 4143668, l_first_op_RCY to 1 if Null
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_routing_type := ' || l_routing_type);
          msc_sch_wb.atp_debug('l_model_flag := ' || l_model_flag);
       END IF;
       IF NVL(l_model_flag, 2) <> 1 THEN
           IF i <> 1 THEN
               -- (3004862) circular BOM issue: Call get process effectivity again
               -- for the Phantom Component's Bill.
               msc_sch_wb.atp_debug('Calling Process effectivity for Phantom:'|| l_explode_comp.component_identifier(i));
               MSC_ATP_PROC.get_process_effectivity(
                   p_plan_id,
                   l_explode_comp.component_identifier(i),
                   p_organization_id,
                   p_instance_id,
                   l_explode_comp.requested_date(i),
                   l_explode_comp.comp_usage(i),
                   l_process_seq_id,
                   l_routing_seq_id,
                   l_bill_seq_id,
                   l_op_seq_id, --4570421
                   x_return_status);
               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
           END IF;

           -- 3027711
           IF l_bill_seq_id is not null THEN

              ---- Get the bom from msc_bom_components and network routing
              -- ATP4drp open DRP specific cursor for DRP plans.
              IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) <> 5 THEN

                  OPEN net_rout_comp(l_bill_seq_id, -- (3004862) circular BOM issue: call with changed parameter
                                     l_explode_comp.requested_date(i),
                                     l_explode_comp.comp_usage(i),
                                     l_explode_comp.wip_supply_type(i)); --4106269
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after opening network routing cursor net_rout_com');
                  END IF;
              ELSE

                  OPEN drp_comp(l_bill_seq_id, -- (3004862) circular BOM issue: call with changed parameter
                                l_explode_comp.requested_date(i),
                                l_explode_comp.comp_usage(i));
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after opening DRP cursor drp_comp');
                     msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                  END IF;
              END IF;
              -- End ATP4drp

              IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after opening network routing cursor net_rout_com');
                  msc_sch_wb.atp_debug('l_bill_seq_id '||l_bill_seq_id);
                  msc_sch_wb.atp_debug('requested_date '||l_explode_comp.requested_date(i));
                  msc_sch_wb.atp_debug('comp_usage '|| l_explode_comp.comp_usage(i));
              END IF;
           END IF;
       ELSIF l_model_flag = 1 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Explode Model or its components  Bom');
             msc_sch_wb.atp_debug('l_model_atp_comp_flag := ' || l_model_atp_comp_flag);
          END IF;
          IF l_model_atp_comp_flag in ('Y', 'C') THEN
             ---explode mandatory components if model or option class
             IF l_explode_comp.bom_item_type(i) in (1,2) or
                       (l_explode_comp.bom_item_type(i) = 4 and MSC_ATP_PVT.G_INV_CTP = 5)  THEN

                 IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('i = ' || i);
                 END IF;
                 l_lead_time := CEIL((NVL(l_explode_comp.fixed_lt(i), 0) +
                                             NVL(l_explode_comp.variable_lt(i), 0)*l_explode_comp.comp_usage(i))
                                                 * (1 + l_mso_lead_time_factor));

                 IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('l_lead_time = ' || l_lead_time);
                 END IF;

                 IF nvl(l_lead_time, 0) > 0 THEN
                   l_request_date := MSC_CALENDAR.DATE_OFFSET
                                             (p_organization_id,
                                              p_instance_id,
                                              1,
                                              l_explode_comp.requested_date(i),
                                              -1 * l_lead_time);
                 ELSE
                    l_request_date := l_explode_comp.requested_date(i);
                 END IF;

                 IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('l_request_date := ' || l_request_date);
                 END IF;

                 MSC_ATP_CTO.Get_Mandatory_Components(p_plan_id,
                                                      p_instance_id,
                                                      p_organization_id,
                                                      l_explode_comp.inventory_item_id(i),
                                                      l_explode_comp.comp_usage(i),
                                                      l_request_date,
                                                      l_explode_comp.dest_inventory_item_id(i),
                                                      l_mand_comp_info_rec);

                 IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('After Get mand comp, add it to list of components');
                 END IF;

                 FOR l_cto_count in 1..l_mand_comp_info_rec.sr_inventory_item_id.count LOOP
                     l_atp_comp_rec := l_null_atp_comp_rec;

                     /* time_phased_atp changes begin
                        Support PF ATP for components*/
                     --l_atp_comp_rec.inventory_item_id := l_mand_comp_info_rec.sr_inventory_item_id(l_cto_count);
                     l_atp_comp_rec.inventory_item_id := MSC_ATP_PF.Get_PF_Atp_Item_Id(
                                                                p_instance_id,
                                                                -1, -- plan_id
                                                                l_mand_comp_info_rec.sr_inventory_item_id(l_cto_count),
                                                                p_organization_id
                                                         );
                     l_atp_comp_rec.request_item_id := l_mand_comp_info_rec.sr_inventory_item_id(l_cto_count);
                     l_atp_comp_rec.atf_date := l_mand_comp_info_rec.atf_date(l_cto_count);
                     l_atp_comp_rec.match_item_family_id := null;
                     -- time_phased_atp changes end
                     --4570421
                     l_atp_comp_rec.scaling_type                      := l_mand_comp_info_rec.scaling_type(l_cto_count);
                     l_atp_comp_rec.scale_multiple                    := l_mand_comp_info_rec.scale_multiple(l_cto_count);
                     l_atp_comp_rec.scale_rounding_variance           := l_mand_comp_info_rec.scale_rounding_variance(l_cto_count);
                     l_atp_comp_rec.rounding_direction                := l_mand_comp_info_rec.rounding_direction(l_cto_count);
                     l_atp_comp_rec.component_yield_factor            := l_mand_comp_info_rec.component_yield_factor(l_cto_count);
                     l_atp_comp_rec.usage_qty                         := l_mand_comp_info_rec.usage_qty(l_cto_count); --4775920
                     l_atp_comp_rec.organization_type                 := l_mand_comp_info_rec.organization_type(l_cto_count); --4775920
                     IF (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND l_atp_comp_rec.scaling_type IN (4,5)) THEN
                        l_atp_comp_rec.comp_usage := integer_scaling (l_mand_comp_info_rec.quantity(l_cto_count),
                                                                      l_mand_comp_info_rec.scale_multiple(l_cto_count),
	                                                              l_mand_comp_info_rec.scale_rounding_variance(l_cto_count) ,
	                                                              l_mand_comp_info_rec.rounding_direction(l_cto_count));
	             ELSE
                         l_atp_comp_rec.comp_usage := l_mand_comp_info_rec.quantity(l_cto_count);
                     END IF; --4570421

                     --l_atp_comp_rec.comp_usage := l_mand_comp_info_rec.quantity(l_cto_count);
                     l_atp_comp_rec.requested_date := l_request_date;
                     l_atp_comp_rec.lead_time := l_lead_time + l_explode_comp.lead_time(i);
                     l_atp_comp_rec.wip_supply_type := 1;
                     l_atp_comp_rec.assembly_identifier := l_explode_comp.assembly_identifier(i);
                     l_atp_comp_rec.component_identifier  := null;
                     --diag_atp
                     l_atp_comp_rec.reverse_cumulative_yield := 1;
                     --s_cto_rearch
                     l_atp_comp_rec.match_item_id := null;
                     l_atp_comp_rec.bom_item_type := l_mand_comp_info_rec.bom_item_type(l_cto_count);
                     l_atp_comp_rec.parent_line_id := l_explode_comp.assembly_identifier(i);
                     l_atp_comp_rec.top_model_line_id := l_explode_comp.top_model_line_id(i);
                     IF l_explode_comp.bom_item_type(i) = 1 THEN
                        l_atp_comp_rec.ato_parent_model_line_id := l_explode_comp.assembly_identifier(i);
                     ELSE
                         l_atp_comp_rec.ato_parent_model_line_id := l_explode_comp.ato_parent_model_line_id(i);
                     END IF;

                     l_atp_comp_rec.ato_model_line_id  := l_explode_comp.ato_model_line_id(i);
                     l_atp_comp_rec.MAND_COMP_FLAG  := 1;
                     l_atp_comp_rec.parent_so_quantity  := 0;
                     l_atp_comp_rec.fixed_lt  := l_mand_comp_info_rec.fixed_lead_time(l_cto_count);
                     l_atp_comp_rec.variable_lt  := l_mand_comp_info_rec.variable_lead_time(l_cto_count);
                     l_atp_comp_rec.oss_error_code  := null;
                     l_atp_comp_rec.model_flag := 1;
                     l_atp_comp_rec.requested_quantity := p_requested_quantity;
                     l_atp_comp_rec.atp_flag := l_mand_comp_info_rec.atp_flag(l_cto_count);
                     l_atp_comp_rec.atp_components_flag := l_mand_comp_info_rec.atp_components_flag(l_cto_count);
                     l_atp_comp_rec.dest_inventory_item_id := l_mand_comp_info_rec.dest_inventory_item_id(l_cto_count);
                     l_atp_comp_rec.parent_repl_ord_flag := NVL(p_comp_info_rec.replenish_to_order_flag, 'N');
                     l_atp_comp_rec.comp_uom := l_mand_comp_info_rec.uom_code(l_cto_count); --bug3110023
                     MSC_ATP_REQ.Add_To_Comp_List(l_explode_comp,
                                            l_comp_requirements,
                                            l_atp_comp_rec);


                 END LOOP;
             END IF;

             --now call for CTO Bom
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get CTO Bom');
              END IF;

		     MSC_ATP_CTO.Get_CTO_BOM(MSC_ATP_PVT.G_SESSION_ID,
					     l_cto_bom_rec,
					     l_explode_comp.assembly_identifier(i),
					     l_explode_comp.requested_date(i),
					     l_explode_comp.comp_usage(i),
					     l_explode_comp.parent_so_quantity(i),
					     l_explode_comp.inventory_item_id(i),
					     p_organization_id,
					     p_plan_id,
					     p_instance_id,
                                             l_explode_comp.fixed_lt(i),
                                             l_explode_comp.variable_lt(i));
		  END IF;

	       END IF;

	       IF PG_DEBUG in ('Y', 'C') THEN
		  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'i = '||i);
	       END IF;


	       -- 3027711
	       IF NVL(l_model_flag,2) <> 1 THEN
		  --standard item
		  LOOP

		    IF l_bill_seq_id is null THEN
		       EXIT;
		    END IF;

                    -- ATP4drp fetch from DRP specific cursor for DRP plans.
                    IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) <> 5 THEN
                       -- Non DRP Plan
		       IF PG_DEBUG in ('Y', 'C') THEN
			     msc_sch_wb.atp_debug('Before Fetch of net_rout_comp');
		       END IF;
		       FETCH net_rout_comp INTO
		             l_comp_item_id,
			     l_comp_component_identifier, -- (3004862) circular BOM issue
			     l_comp_usage,
			     l_comp_date,
			     l_comp_lead_time,
			     l_comp_wip_supply_type,
			     l_comp_pre_pro_lead_time,
			     --diag_atp
			     l_reverse_cumulative_yield,
			     -- time_phased_atp
		    	     l_atf_date,
		    	     l_comp_uom, --bug3110023
		    	     --4570421
		    	     l_scaling_type,
		    	     l_scale_multiple,
                             l_scale_rounding_variance,
                             l_rounding_direction,
                             l_component_yield_factor,
                             l_usage_qty; --4775920

		       EXIT WHEN net_rout_comp%NOTFOUND;
		       IF PG_DEBUG in ('Y', 'C') THEN
		    	  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after fetching cursor net_rout_comp');
		       END IF;
                    ELSE -- DRP plan
		       IF PG_DEBUG in ('Y', 'C') THEN
			     msc_sch_wb.atp_debug('Before Fetch of drp_comp');
		       END IF;
		       FETCH drp_comp INTO
		  	     l_comp_item_id,
			     l_comp_component_identifier, -- (3004862) circular BOM issue
			     l_comp_usage,
			     l_comp_date,
			     l_comp_lead_time,
			     l_comp_wip_supply_type,
			     l_comp_pre_pro_lead_time,
			     --diag_atp
			     l_reverse_cumulative_yield,
			     -- time_phased_atp
		    	     l_atf_date,
		    	     l_comp_uom, --bug3110023
		    	     --4570421
		    	     l_scaling_type,
		    	     l_scale_multiple,
                             l_scale_rounding_variance,
                             l_rounding_direction,
                             l_component_yield_factor,
                             l_usage_qty; --4775920

		       EXIT WHEN drp_comp%NOTFOUND;
		       IF PG_DEBUG in ('Y', 'C') THEN
		    	  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after fetching cursor drp_comp');
                          msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
		       END IF;
                    END IF;
                    -- END ATP4drp


		    IF PG_DEBUG in ('Y', 'C') THEN
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after fetch');
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_item_id = '||l_comp_item_id);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_usage = '||l_comp_usage);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_date = '||l_comp_date);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_lead_time = '||l_comp_lead_time);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_wip_supply_type = '||l_comp_wip_supply_type);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_assembly_identifier = '||l_comp_assembly_identifier);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_component_identifier = '||l_comp_component_identifier);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_pre_pro_lead_time = '||l_comp_pre_pro_lead_time);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_atf_date = '||l_atf_date);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'G_ASSEMBLY_LINE_ID = '||MSC_ATP_PVT.G_ASSEMBLY_LINE_ID);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'G_COMP_LINE_ID = '||MSC_ATP_PVT.G_COMP_LINE_ID);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_uom = '||l_comp_uom); --bug3110023
			--4570421
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_scaling_type = '||l_scaling_type);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_scale_multiple = '||l_scale_multiple);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_scale_rounding_variance = '||l_scale_rounding_variance);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_rounding_direction = '||l_rounding_direction);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_component_yield_factor = '||l_component_yield_factor);
			msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_usage_qty = '||l_usage_qty); --4775920



		    END IF;

		    IF NVL(MSC_ATP_PVT.G_EXPLODE_PHANTOM, 'N') = 'Y' THEN
			 --- agilent fix: If profile option is set to yes then we consider phantom
			 --- item as any other item and do not add it to the list of items to be exploded
			 l_comp_wip_supply_type := 1;
		    END IF;


		    l_comp_lead_time := l_comp_lead_time + l_explode_comp.lead_time(i);

		    l_atp_comp_rec := l_null_atp_comp_rec;

		    /* time_phased_atp changes begin
		       Support PF ATP for components*/
                    -- ATP4drp PF ATP not supported for DRP.
                    IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5 THEN
                       -- Turn Off Product Family ATP for components.
                       l_atp_comp_rec.inventory_item_id := l_comp_item_id ;
                       -- ATP4drp PF ATP not supported for DRP. Print out Debug Here.
                       IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) = 5 AND PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                          msc_sch_wb.atp_debug('Get_Comp_Requirements: l_atp_comp_rec.inventory_item_id '
                                                                            || l_atp_comp_rec.inventory_item_id );
                          msc_sch_wb.atp_debug('Get_Comp_Requirements: l_atp_comp_rec.request_item_id '
                                                                            || l_atp_comp_rec.request_item_id );
                          msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                       END IF;
                    ELSE -- Non DRP Plans
		       l_atp_comp_rec.inventory_item_id := MSC_ATP_PF.Get_PF_Atp_Item_Id(
							     p_instance_id,
							     -1, -- plan_id
							     l_comp_item_id,
							     p_organization_id
							   );
                    END IF;
                    -- End ATP4drp

		    l_atp_comp_rec.request_item_id := l_comp_item_id;
		    l_atp_comp_rec.atf_date := l_atf_date;
		    l_atp_comp_rec.match_item_family_id := null;
		    -- time_phased_atp changes end

		    l_atp_comp_rec.comp_usage := l_comp_usage;
		    l_atp_comp_rec.requested_date := l_comp_date;
		    l_atp_comp_rec.lead_time := l_comp_lead_time;
		    l_atp_comp_rec.wip_supply_type := l_comp_wip_supply_type;
		    l_atp_comp_rec.assembly_identifier := l_comp_assembly_identifier;
		    l_atp_comp_rec.component_identifier  := l_comp_component_identifier;
		    --4570421, add scaling_type and other parameters here !
		    l_atp_comp_rec.scaling_type := l_scaling_type;
		    l_atp_comp_rec.scale_multiple := l_scale_multiple;
		    l_atp_comp_rec.scale_rounding_variance := l_scale_rounding_variance;
		    l_atp_comp_rec.rounding_direction := l_rounding_direction;
		    l_atp_comp_rec.component_yield_factor := l_component_yield_factor; --4570421
		    l_atp_comp_rec.usage_qty := l_usage_qty; --4775920
		    l_atp_comp_rec.organization_type := NVL ( MSC_ATP_PVT.G_ORG_INFO_REC.org_type, MSC_ATP_PVT.DISCRETE_ORG); --4775920
		    --diag_atp
		    l_atp_comp_rec.reverse_cumulative_yield := l_reverse_cumulative_yield;
		    --s_cto_rearch
		    l_atp_comp_rec.match_item_id := null;
		    l_atp_comp_rec.bom_item_type := null;
		    l_atp_comp_rec.parent_line_id := null;
		    l_atp_comp_rec.top_model_line_id := null;
		    l_atp_comp_rec.ato_parent_model_line_id := null;
		    l_atp_comp_rec.ato_model_line_id  := null;
		    l_atp_comp_rec.MAND_COMP_FLAG  := null;
		    l_atp_comp_rec.parent_so_quantity  := null;
		    l_atp_comp_rec.fixed_lt  := null;
		    l_atp_comp_rec.variable_lt  := null;
		    l_atp_comp_rec.oss_error_code  := null;
		    l_atp_comp_rec.model_flag := l_model_flag;
		    l_atp_comp_rec.requested_quantity := p_requested_quantity;
                    l_atp_comp_rec.parent_repl_ord_flag := NVL(p_comp_info_rec.replenish_to_order_flag, 'N');
                    l_atp_comp_rec.comp_uom := l_comp_uom; --bug3110023
		    MSC_ATP_REQ.Add_To_Comp_List(l_explode_comp,
						 l_comp_requirements,
						 l_atp_comp_rec);


		  END LOOP; -- end the loop of fetch
	       ELSE
		  IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Model Entity ');
             msc_sch_wb.atp_debug('l_model_atp_comp_flag := ' || l_model_atp_comp_flag);
          END IF;

          IF l_model_atp_comp_flag in ('Y', 'C') THEN
             FOR l_cto_count in 1..l_cto_bom_rec.inventory_item_id.count LOOP
                 l_atp_comp_rec := l_null_atp_comp_rec;

                 /* time_phased_atp changes begin
                    Support PF ATP for components*/
                 l_atp_comp_rec.inventory_item_id := MSC_ATP_PF.Get_PF_Atp_Item_Id(
                                                         p_instance_id,
                                                         -1,
                                                         l_cto_bom_rec.inventory_item_id(l_cto_count),
                                                         p_organization_id
                                                     );
                 l_atp_comp_rec.request_item_id := l_cto_bom_rec.inventory_item_id(l_cto_count);
                 l_atp_comp_rec.atf_date := l_cto_bom_rec.atf_date(l_cto_count);
                 l_atp_comp_rec.match_item_family_id := MSC_ATP_PF.Get_PF_Atp_Item_Id(
                                                            p_instance_id,
                                                            -1,
                                                            l_cto_bom_rec.match_item_id(l_cto_count),
                                                            p_organization_id
                                                        );
                 -- time_phased_atp changes end

                 l_atp_comp_rec.comp_usage := l_cto_bom_rec.comp_usage(l_cto_count);
                 l_atp_comp_rec.requested_date := l_cto_bom_rec.requested_date(l_cto_count);
                 l_atp_comp_rec.lead_time := l_cto_bom_rec.lead_time(l_cto_count) + l_explode_comp.lead_time(i);
                 l_atp_comp_rec.wip_supply_type := l_cto_bom_rec.wip_supply_type(l_cto_count);
                 l_atp_comp_rec.assembly_identifier := l_cto_bom_rec.assembly_identifier(l_cto_count);
                 l_atp_comp_rec.component_identifier  := null;
                 --diag_atp
                 l_atp_comp_rec.reverse_cumulative_yield := null;
                 --s_cto_rearch
                 l_atp_comp_rec.match_item_id := l_cto_bom_rec.match_item_id(l_cto_count);
                 l_atp_comp_rec.bom_item_type := l_cto_bom_rec.bom_item_type(l_cto_count);
                 l_atp_comp_rec.parent_line_id := l_cto_bom_rec.parent_line_id(l_cto_count);
                 l_atp_comp_rec.top_model_line_id := l_cto_bom_rec.TOP_MODEL_LINE_ID(l_cto_count);
                 l_atp_comp_rec.ato_parent_model_line_id := l_cto_bom_rec.ATO_PARENT_MODEL_LINE_ID(l_cto_count);
                 l_atp_comp_rec.ato_model_line_id  := l_cto_bom_rec.ATO_MODEL_LINE_ID(l_cto_count);
                 l_atp_comp_rec.MAND_COMP_FLAG  := 2;
                 l_atp_comp_rec.parent_so_quantity  := l_cto_bom_rec.parent_so_quantity(l_cto_count);
                 l_atp_comp_rec.fixed_lt  := l_cto_bom_rec.fixed_lt(l_cto_count);
                 l_atp_comp_rec.variable_lt  := l_cto_bom_rec.variable_lt(l_cto_count);
                 l_atp_comp_rec.oss_error_code  := l_cto_bom_rec.oss_error_code(l_cto_count);
                 l_atp_comp_rec.model_flag := l_model_flag;
                 l_atp_comp_rec.requested_quantity := p_requested_quantity;
                 l_atp_comp_rec.atp_flag := l_cto_bom_rec.atp_flag(l_cto_count);
                 l_atp_comp_rec.atp_components_flag := l_cto_bom_rec.atp_components_flag(l_cto_count);
                 l_atp_comp_rec.dest_inventory_item_id := l_cto_bom_rec.dest_inventory_item_id(l_cto_count);
                 l_atp_comp_rec.parent_repl_ord_flag := NVL(p_comp_info_rec.replenish_to_order_flag, 'N');
                 l_atp_comp_rec.comp_uom := l_cto_bom_rec.comp_uom(l_cto_count); --bug3110023
                 l_atp_comp_rec.usage_qty := l_cto_bom_rec.usage_qty(l_cto_count); --4775920
                 l_atp_comp_rec.organization_type := l_cto_bom_rec.organization_type(l_cto_count); --4775920

                 MSC_ATP_REQ.Add_To_Comp_List(l_explode_comp,
                                            l_comp_requirements,
                                            l_atp_comp_rec);

             END LOOP;
          END IF;
       END IF;


       -- Bug 4042403, 4047183, 4070094 Check that l_bill_seq_id is not NULL
       IF ((l_routing_type = 3) OR (l_model_flag <> 1)) AND l_bill_seq_id IS NOT NULL THEN
           -- ATP4drp close DRP specific cursor for DRP plans.
           IF NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type, 1) <> 5 THEN
              -- Bug 4042403, 4047183, 4070094 Close the cursor only if it has been opened.
              IF net_rout_comp%ISOPEN THEN
                 CLOSE net_rout_comp;
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after closing cursor net_rout_comp');
                 END IF;
              END IF;
              -- End Bug 4042403, 4047183, 4070094
           ELSE -- DRP plan
              -- Bug 4042403, 4047183, 4070094 Close the cursor only if it has been opened.
              IF drp_comp%ISOPEN THEN
                 CLOSE drp_comp;
                 IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after closing cursor drp_comp');
                    msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                 END IF;
              END IF;
              -- End Bug 4042403, 4047183, 4070094
           END IF;
           -- End ATP4drp

       END IF;

       /*--s_cto_rearch:  do not open cusrosr for cto any more
       ELSIF l_cto_bom > 0 THEN
           CLOSE cto_comp;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'after closing cursor cto_comp');
           END IF;
       END IF;
       e_cto_rearch */
       i := l_explode_comp.inventory_item_id.NEXT(i);

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'second time, i = '||i);
       END IF;
    END LOOP;

    -- 3027711 move initializing x_atp_date/x_avail_assembly_qty to beginning

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'x_atp_date := ' || x_atp_date);
       msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_requirements.inventory_item_id.count = '||
                         l_comp_requirements.inventory_item_id.count);
    END IF;
    --msc_sch_wb.atp_debug('l_comp_requirements.pre_process_lead_time.count = '||
    --                    l_comp_requirements.pre_process_lead_time.count);

    j := l_comp_requirements.inventory_item_id.first;
    -- if j is null, that means we don't have any comp requirements
    -- need to consider, so we can assume that we have infinite comp
    -- to make the assembly. (that's why we initialize x_avail_assembly_qty
    -- that way).

    -- otherwise we need to know how many assemblies we can make
    -- by loop through each comp and find the availibility.
    -- If we can make more than the requested quantity, we return
    -- the requested quantity.

    WHILE j IS NOT NULL LOOP

        --- IN backward sched. check if request date - (fix + Var + preProcessing lead time)
        --- is greater than sysdate or not
        --- if not then we can't meet the requirement
        --- We check only when we are in first time.
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_search = '|| p_search);
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'j := '||j);
        END IF;

        ---diag_atp: we look for complete quantity in case of diagnostic ATP
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_comp_requirements.comp_usage(j) := '||l_comp_requirements.comp_usage(j));
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'x_avail_assembly_qty := '||x_avail_assembly_qty);
        END IF;
        IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 THEN
            --- for diagnostic atp we always order the full quantity.
            IF ( (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(l_comp_requirements.scaling_type(j),1) = 2) OR
                (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_comp_requirements.scaling_type(j),1) IN (0,2))) THEN
                 l_requested_comp_qty := l_comp_requirements.comp_usage(j);
            ELSE
                 l_requested_comp_qty := l_comp_requirements.comp_usage(j)* p_requested_quantity;
            END IF;
        ELSE --4570421
            IF ( (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(l_comp_requirements.scaling_type(j),1) = 2) OR
                (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_comp_requirements.scaling_type(j),1) IN (0,2))) THEN
                 l_requested_comp_qty := l_comp_requirements.comp_usage(j);
            ELSIF (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_comp_requirements.scaling_type(j),1) IN (4,5)) THEN
                 l_requested_comp_qty := integer_scaling (l_comp_requirements.comp_usage(j)*x_avail_assembly_qty,
                                                   l_comp_requirements.scale_multiple(j),
	                                           l_comp_requirements.scale_rounding_variance(j) ,
	                                           l_comp_requirements.rounding_direction(j));
	    ELSE
	         l_requested_comp_qty := l_comp_requirements.comp_usage(j)*x_avail_assembly_qty;
	    END IF;

        END IF;
        --4570421 , print l_requested_comp_qty here !
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_requested_comp_qty := '||l_requested_comp_qty);
        END IF;

        -- now call atp check for this item:
        -- 1: populate the atp rec
        -- 2: call ATP_Check

        l_atp_rec.error_code := 0;
        l_atp_rec.available_quantity := NULL;
        l_atp_rec.requested_date_quantity := NULL;

        -- Bug 1562754, we need to store the line id for a lower level model in
        -- case of CTO. For example, the BOM is like : Model A -> Model B -> Item C
        -- In such a case, if item C is not available enough say while making Model B
        -- in backward case, during adjustment of other resources and components, we want
        -- G_ASSEMBLY_LINE_ID to be set to line Id of Model B and not Model A.

        MSC_ATP_PVT.G_ASSEMBLY_LINE_ID := NVL(l_comp_requirements.assembly_identifier(j), MSC_ATP_PVT.G_ASSEMBLY_LINE_ID);
        MSC_ATP_PVT.G_COMP_LINE_ID := NVL(l_comp_requirements.component_identifier(j), MSC_ATP_PVT.G_COMP_LINE_ID);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'G_COMP_LINE_ID = '||MSC_ATP_PVT.G_COMP_LINE_ID);
        END IF;

        -- no need to do uom conversion
        l_atp_rec.instance_id := p_instance_id;
        l_atp_rec.identifier := MSC_ATP_PVT.G_ORDER_LINE_ID;
        l_atp_rec.component_identifier := l_comp_requirements.component_identifier(j);

        -- 2462661 : krajan
        --l_atp_rec.src_atp_flag := l_comp_requirements.src_atp_flag(j);

        select identifier3
        into   l_atp_rec.demand_source_line
        from   mrp_atp_details_temp
        where  pegging_id = p_parent_pegging_id
        and    record_type = 3
        and    session_id = MSC_ATP_PVT.G_SESSION_ID;


        -- l_atp_rec.demand_source_header_id:= l_atp_table.Demand_Source_Header_Id(i);
        -- l_atp_rec.demand_source_delivery:= l_atp_table.Demand_Source_Delivery(i);
        l_atp_rec.inventory_item_id := l_comp_requirements.inventory_item_id(j);

        /* time_phased_atp
           Support PF ATP for components*/
        l_atp_rec.request_item_id := l_comp_requirements.request_item_id(j);

        l_atp_rec.organization_id := p_organization_id;
        l_atp_rec.quantity_ordered := l_requested_comp_qty;
        -- l_atp_rec.quantity_uom := l_quantity_uom;
        l_atp_rec.requested_ship_date := l_comp_requirements.requested_date(j);

        -- krajan: 2408902: duplicate statement
        --l_atp_rec.demand_class := p_demand_class;


        l_atp_rec.insert_flag := p_insert_flag;

        IF l_model_flag = 1 THEN
           l_atp_rec.refresh_number := p_refresh_number;
        ELSE
           l_atp_rec.refresh_number := null;
        END IF;

	l_atp_rec.ship_date := null;

        -- krajan: 2408902: populate demand class from global variable
        -- Bug 2424357
        l_atp_rec.demand_class := NVL(MSC_ATP_PVT.G_ATP_DEMAND_CLASS, p_demand_class);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'Demand Class being passed is : '|| l_atp_rec.demand_class);
        END IF;
        -- end 2408902

        --s_cto_enhc
        l_plan_found_for_match := 0;
        l_model_error_code := 0;
        l_atp_rec.base_model_id   := null;


        IF l_model_flag = 1 and l_comp_requirements.atp_flag(j) is null
                            --exclude mand_comp flag as they will always be collected
                            and NVL(l_comp_requirements.MAND_COMP_FLAG(j), 2) = 2  THEN

           --item doesn't exists in the given organization
           l_model_error_code := MSC_ATP_PVT.ATP_ITEM_NOT_COLLECTED;

           IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Item not collected := ' || l_comp_requirements.inventory_item_id(j));
           END IF;

        ELSIF l_model_flag = 1 and l_comp_requirements.atp_flag(j) = 'N'
                               and l_comp_requirements.atp_components_flag(j) = 'N' THEN
           --model entity is non-atpable. Do not find plan, default to parent's plan
           l_plan_id := p_plan_id;
        ELSIF MSC_ATP_PVT.G_INV_CTP = 5 THEN
           l_plan_id := -1;
           l_assign_set_id := p_assign_set_id;
        ELSE

           IF l_comp_requirements.match_item_id(j) is not null then
              --check if match exists or not.

              /* time_phased_atp changes begin
                 Support PF ATP for components*/
              --l_atp_rec.inventory_item_id := l_comp_requirements.match_item_id(j);
              l_atp_rec.inventory_item_id := l_comp_requirements.match_item_family_id(j);
              l_atp_rec.request_item_id := l_comp_requirements.match_item_id(j);
              -- time_phased_atp changes end
              /*
              MSC_ATP_PROC.get_global_plan_info(p_instance_id,
                                             --l_atp_rec.inventory_item_id,
                                             l_atp_rec.request_item_id, -- time_phased_atp
                                             l_atp_rec.organization_id,
                                             l_atp_rec.demand_class);*/
              /* time_phased_atp changes begin
                 Call new procedure Get_PF_Plan_Info*/
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Match found := ' || l_atp_rec.inventory_item_id);
                 msc_sch_wb.atp_debug('Find plan for match');
              END IF;
              MSC_ATP_PF.Get_PF_Plan_Info(
                          p_instance_id,
                          l_atp_rec.request_item_id,
                          l_atp_rec.inventory_item_id,
                          l_atp_rec.organization_id,
                          l_atp_rec.demand_class,
                          l_atp_rec.atf_date,
                          l_atp_rec.error_code,
                          l_return_status,
                          p_plan_id --bug3510475 pass component's plan id as parent
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'Error encountered in Get_PF_Plan_Info');
                   END IF;
              END IF;
              /* time_phased_atp changes end*/

              IF MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id is not null and
                  NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id, -1) <> -1 then
                  IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Plan found for match := '  || MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id );
                   END IF;
                  ---plan found for match
                  l_plan_found_for_match := 1;
                  --l_atp_rec.request_item_id := l_comp_requirements.match_item_id(j);
                  l_atp_rec.base_model_id   := l_comp_requirements.inventory_item_id(j); -- check with Vivek

              ELSE
                  ---plan is not found for match. Do ATP on model level
                  --l_atp_rec.inventory_item_id := l_comp_requirements.inventory_item_id(j);
                  IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Plan not found for match := '  || MSC_ATP_PVT.G_PLAN_INFO_REC.plan_id );
                  END IF;
                  /* time_phased_atp
                     Support PF ATP for components*/
                  l_atp_rec.inventory_item_id := l_comp_requirements.inventory_item_id(j);
                  l_atp_rec.request_item_id := l_comp_requirements.request_item_id(j);
              END IF;
           END IF;

           IF l_plan_found_for_match = 0 THEN
              -- New procedure for obtaining plan data : Supplier Capacity Lead Time (SCLT) proj.
              /*
              MSC_ATP_PROC.get_global_plan_info(p_instance_id,
                                             --l_atp_rec.inventory_item_id,
                                             l_atp_rec.request_item_id, -- time_phased_atp
                                             l_atp_rec.organization_id,
                                             l_atp_rec.demand_class);*/

              /* time_phased_atp changes begin
                 Call new procedure Get_PF_Plan_Info*/

              MSC_ATP_PF.Get_PF_Plan_Info(
                          p_instance_id,
                          l_atp_rec.request_item_id,
                          l_atp_rec.inventory_item_id,
                          l_atp_rec.organization_id,
                          l_atp_rec.demand_class,
                          l_atp_rec.atf_date,
                          l_atp_rec.error_code,
                          l_return_status,
                          p_plan_id --bug3510475 pass component's plan id as parent
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'Error encountered in Get_PF_Plan_Info');
                   END IF;
              END IF;
              /* time_phased_atp changes end*/
           END IF;

           l_plan_info_rec := MSC_ATP_PVT.G_PLAN_INFO_REC;
           -- End New procedure for obtaining plan data : Supplier Capacity Lead Time proj

           l_plan_id       := l_plan_info_rec.plan_id;
           l_assign_set_id := l_plan_info_rec.assignment_set_id;

           --diag_atp
           l_atp_rec.plan_name := l_plan_info_rec.plan_name;
           l_atp_rec.reverse_cumulative_yield := l_comp_requirements.reverse_cumulative_yield(j);
           l_atp_rec.quantity_uom := l_comp_requirements.comp_uom(j); --bug3110023

           -- changes for bug 2392456 ends

           msc_sch_wb.atp_debug ('Plan ID in Get_Comp_Reqs : ' || l_plan_id);
           IF (l_plan_id is NULL) or (l_plan_id IN (-100, -200)) THEN
               --s_cto_rearch
               IF l_model_flag = 1 THEN
                  l_model_error_code := MSC_ATP_PVT.PLAN_NOT_FOUND;
               ELSE
                  --standard item
                  -- this should not happen but just in case
                  l_plan_id := p_plan_id;
                  l_assign_set_id := p_assign_set_id;
               END IF;
           END IF;

           -- 24x7
           IF (l_plan_id = -300) then
              l_atp_rec.error_code := MSC_ATP_PVT.TRY_ATP_LATER;
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Get_Comp_Req: ATP Downtime Detected');
                 msc_sch_wb.atp_debug('Get_Comp_Requirements: ATP Downtime');
              END IF;
              MSC_ATP_PVT.G_DOWNTIME_HIT := 'Y';
              RAISE MSC_ATP_PVT.EXC_NO_PLAN_FOUND;
           End IF;
        END IF;
        --subst
        l_atp_rec.original_item_flag := 2;
        l_atp_rec.top_tier_org_flag := 2;
        l_atp_rec.substitution_window := 0;

        /* ship_rec_cal changes begin */
        l_atp_rec.receiving_cal_code := p_manufacturing_cal_code;
        l_atp_rec.intransit_cal_code := p_manufacturing_cal_code;
        l_atp_rec.shipping_cal_code := p_manufacturing_cal_code;
        l_atp_rec.manufacturing_cal_code := p_manufacturing_cal_code;
        /* ship_rec_cal changes end */

        ---s_cto_rearch
        IF MSC_ATP_PVT.G_INV_CTP = 5 and
           p_comp_info_rec.bom_item_type = 4 and p_comp_info_rec.replenish_to_order_flag = 'Y' THEN
           --add ato item's components in ODS case share the same line id as ato item itself
           l_atp_rec.demand_source_line := p_comp_info_rec.line_id;
        ELSE

           l_atp_rec.demand_source_line := l_comp_requirements.assembly_identifier(j);
        END IF;
        l_atp_rec.order_number       := p_order_number;
        l_atp_rec.Top_Model_line_id := l_comp_requirements.Top_Model_line_id(j);

        l_atp_rec.ATO_Parent_Model_Line_Id := l_comp_requirements.ATO_Parent_Model_Line_Id(j);

        IF p_comp_info_rec.bom_item_type = 4 and p_comp_info_rec.replenish_to_order_flag = 'Y' THEN
           -- ato model line id id used to remove stealing records in demand priorit cases
           -- there for components for ATO items, we pass this line id
           l_atp_rec.ATO_Model_Line_Id := p_comp_info_rec.ATO_Model_Line_Id;
        ELSE
           l_atp_rec.ATO_Model_Line_Id := l_comp_requirements.ATO_Model_Line_Id(j);
        END IF;
        l_atp_rec.Parent_line_id :=  l_comp_requirements.Parent_line_id(j);
        l_atp_rec.wip_supply_type := l_comp_requirements.wip_supply_type(j);
        l_atp_rec.parent_atp_flag := p_comp_info_rec.atp_flag;
        l_atp_rec.parent_atp_comp_flag := p_comp_info_rec.atp_comp_flag;
        l_atp_rec.parent_repl_order_flag := p_comp_info_rec.replenish_to_order_flag;
        l_atp_rec.parent_bom_item_type := p_comp_info_rec.bom_item_type;
        l_atp_rec.mand_comp_flag := l_comp_requirements.mand_comp_flag(j);
        l_atp_rec.parent_so_quantity := l_comp_requirements.parent_so_quantity(j);
        l_atp_rec.wip_supply_type := l_comp_requirements.wip_supply_type(j);
        --- This flag is populated only for model where atp_flag = 'Y'
        -- This flag will be used in get_item_attribute to turn off ATP comp flag
        --- so that model is not reexploded.
        l_atp_rec.parent_item_id := l_comp_requirements.parent_item_id(j);

        l_atp_rec.bill_seq_id := l_bill_seq_id;      --4741012 for passing to ATP_Check.

        --4570421
        l_atp_rec.scaling_type                      := l_comp_requirements.scaling_type(j);
        l_atp_rec.scale_multiple                    := l_comp_requirements.scale_multiple(j);
        l_atp_rec.scale_rounding_variance           := l_comp_requirements.scale_rounding_variance(j);
        l_atp_rec.rounding_direction                := l_comp_requirements.rounding_direction(j);
        l_atp_rec.component_yield_factor            := l_comp_requirements.component_yield_factor(j); --4570421
        l_atp_rec.usage_qty                         := l_comp_requirements.usage_qty(j); --4775920
        l_atp_rec.organization_type                 := l_comp_requirements.organization_type(j); --4775920

        ---e_cto_rearch
        IF l_model_flag = 1 and l_model_error_code > 0 THEN

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Model entity and error has occured');
              msc_sch_wb.atp_debug('Error code := ' || l_model_error_code);
           END IF;

/* bug 7508506
 *        l_atp_rec.combined_requested_date_qty := 0;
 *        l_atp_rec.requested_date_quantity := 0;
 *        l_atp_rec.ship_date := null;
 *        */
           l_atp_rec.combined_requested_date_qty := l_requested_comp_qty;
           l_atp_rec.requested_date_quantity := l_requested_comp_qty;
           l_atp_rec.ship_date := l_comp_requirements.requested_date(j);


           --add pegging for diagnostic case
           IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 1 THEN
              l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
              l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
              l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
              l_pegging_rec.atp_level:= p_level;
              l_pegging_rec.organization_id:= p_organization_id;
              l_pegging_rec.organization_code := l_org_code;
              l_pegging_rec.identifier1:= p_instance_id;
              l_pegging_rec.identifier2 := null;
              l_pegging_rec.identifier3 := null;
              l_pegging_rec.inventory_item_id:= l_comp_requirements.inventory_item_id(j);
              l_pegging_rec.inventory_item_name := null; -- item is not collected, how do we show it??
              l_pegging_rec.resource_id := NULL;
              l_pegging_rec.resource_code := NULL;
              l_pegging_rec.department_id := NULL;
              l_pegging_rec.department_code := NULL;
              l_pegging_rec.supplier_id := NULL;
              l_pegging_rec.supplier_name := NULL;
              l_pegging_rec.supplier_site_id := NULL;
              l_pegging_rec.supplier_site_name := NULL;
              l_pegging_rec.scenario_id:= p_scenario_id;
              l_pegging_rec.supply_demand_source_type:= 6;
              l_pegging_rec.supply_demand_quantity := l_requested_comp_qty;
              l_pegging_rec.supply_demand_type:= 1;
              l_pegging_rec.supply_demand_date:= l_comp_requirements.requested_date(j);
              --4570421
              l_pegging_rec.scaling_type                      := l_comp_requirements.scaling_type(j);
              l_pegging_rec.scale_multiple                    := l_comp_requirements.scale_multiple(j);
              l_pegging_rec.scale_rounding_variance           := l_comp_requirements.scale_rounding_variance(j);
              l_pegging_rec.rounding_direction                := l_comp_requirements.rounding_direction(j);
              l_pegging_rec.component_yield_factor            := l_comp_requirements.component_yield_factor(j); --4570421
              l_pegging_rec.usage                             := l_comp_requirements.usage_qty(j); --4775920
              l_pegging_rec.organization_type                 := l_comp_requirements.organization_type(j); --4775920

              --e_cto_rearch

              l_pegging_rec.constraint_flag := 'N';
	      l_pegging_rec.component_identifier := null;


              --diag_atp
              l_pegging_rec.pegging_type := MSC_ATP_PVT.ORG_DEMAND; --demand pegging

              --s_cto_rearch
              l_pegging_rec.dest_inv_item_id := null;
              l_pegging_rec.error_code := l_model_error_code;
              --e_cto_rearch

              l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;     -- for summary enhancement
              MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);
           END IF;
        ELSE

           -- ATP4drp Assign parent_item_id for DRP Kitting in DRP plans.
           -- Assignment should not be detrimental in other plans.

           IF ( l_plan_id <> -1) THEN --4929084
              l_atp_rec.parent_item_id := p_inventory_item_id;
           END IF;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Requirements: l_atp_rec.parent_item_id ' || l_atp_rec.parent_item_id );
           END IF;
           -- End ATP4drp

           MSC_ATP_PVT.ATP_Check(l_atp_rec,
                     l_plan_id,
                     p_level ,
                     p_scenario_id,
                     p_search,
                     p_refresh_number,
                     p_parent_pegging_id,
                     l_assign_set_id,
                     l_atp_period,
                     l_atp_supply_demand,
                     x_return_status);

        END IF;
        --- bug 2178544
        -- Since PTF-Date might be chnaged by some different plan for components we reset the global varibale
        MSC_ATP_PVT.G_PTF_DATE := l_ptf_date;

        IF x_return_status = MSC_ATP_PVT.CTO_OSS_ERROR THEN

           RAISE MSC_ATP_PVT.INVALID_OSS_SOURCE;

           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || ' Error in OSS');
           END IF;

        -- Bug 1531429, in case return status is not success, raise an exception.
        -- krajan: 2400614
        -- krajan: If it is 'G', then it is a sourcing mismatch error.
        -- krajan: If it is MSC_ATP_PVT.G_ATO_SRC_MISMATCH, then it is a sourcing mismatch error.

        -- krajan: Basically for handling recursive ATP_CHECK <-> Get_Comp_Req calls
        -- krajan : 2752705 and dsting 2764213 : Other errors that need to go through to the
        --          top level model are also handled the same way as the mismatch case.
        ELSIF x_return_status = MSC_ATP_PVT.G_ATO_SRC_MISMATCH THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'Get_Comp_Req: Error in ATP_CHECK 0.1');
              msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'Error in lower level component check');
           END IF;
           RAISE MSC_ATP_PVT.G_ATO_SOURCING_MISMATCH;

         --bug 3308206: IF ATP rule is not defined on the item then error out with message
        ELSIF MSC_ATP_PVT.G_INV_CTP = 5 and x_return_status <>  FND_API.G_RET_STS_SUCCESS
               and l_atp_rec.error_code = MSC_ATP_PVT.ATP_BAD_RULE THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'No ATP rule on Component');
           END IF;
           RAISE MSC_ATP_PVT.EXC_NO_ATP_RULE;
        END IF;

        -- dsting 2764213
        IF x_return_status = MSC_ATP_PVT.G_NO_PLAN_FOUND THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Req: Error in ATP_CHECK 0.2');
              msc_sch_wb.atp_debug('Get_Comp_Requirements: Error in lower level component check');
           END IF;
           RAISE MSC_ATP_PVT.EXC_NO_PLAN_FOUND;
        END IF;

        -- krajan 2752705
        IF x_return_status = MSC_ATP_PVT.G_ATO_UNCOLL_ITEM THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Comp_Req: Error in ATP_CHECK 0.3');
              msc_sch_wb.atp_debug('Get_Comp_Requirements: Error in lower level component check');
           END IF;
           RAISE MSC_ATP_PVT.G_EXC_UNCOLLECTED_ITEM;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        MSC_ATP_PROC.Details_Output(l_atp_period,
                       l_atp_supply_demand,
                       x_atp_period,
                       x_atp_supply_demand,
                       x_return_status);



        -- now adjust the x_avail_assembly_qty
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_atp_rec.combined_requested_date_qty := ' || l_atp_rec.combined_requested_date_qty);
           msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'l_atp_rec.requested_date_quantity := ' ||l_atp_rec.requested_date_quantity);
        END IF;

        IF p_search = 1 THEN

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_search = 1');
          END IF;

          -- cchen 1238941
                    --4570421
          IF (NVL(l_atp_rec.combined_requested_date_qty,
              l_atp_rec.requested_date_quantity) >= l_requested_comp_qty) THEN
            NULL;
          ELSIF (NVL(l_atp_rec.combined_requested_date_qty,
                    l_atp_rec.requested_date_quantity) >0) THEN
                    IF ( (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(l_comp_requirements.scaling_type(j),1) = 2) OR
                         (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(l_comp_requirements.scaling_type(j),1) IN (0,2))) THEN
                        x_avail_assembly_qty := 0;
                        IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('Fixed or Lot Based Case: Lot qty not available: avail_assembly_qty: ' || x_avail_assembly_qty);
                        END IF;
                        IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 2 THEN --5403495
                           EXIT;
                        END IF;
                        --EXIT;
                    ELSIF ( (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG) AND (nvl(l_comp_requirements.scaling_type(j),1) IN (4,5)) ) THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('Before inverse scaling : avail_assembly_qty: ' || x_avail_assembly_qty);
                        END IF;
                        x_avail_assembly_qty := LEAST(x_avail_assembly_qty,
                                                      round(
                                                            FLOOR( NVL(l_atp_rec.combined_requested_date_qty,
                                                                       l_atp_rec.requested_date_quantity)/l_comp_requirements.scale_multiple(j))* l_comp_requirements.scale_multiple(j)
                                                            /l_comp_requirements.comp_usage(j),6));
                        IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('Integer Scaling case : avail_assembly_qty: ' || x_avail_assembly_qty);
                        END IF;
                    ELSE
                        x_avail_assembly_qty := LEAST(x_avail_assembly_qty,
                                                       trunc(NVL(l_atp_rec.combined_requested_date_qty,
                       																 			 l_atp_rec.requested_date_quantity)/
                       																 			 l_comp_requirements.comp_usage(j),6));	-- 5598066
                        IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('Item or Proportional case : avail_assembly_qty: ' || x_avail_assembly_qty);
                        END IF;
                    END IF;
          ELSE
              x_avail_assembly_qty := 0;
                      --diag_atp
              IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = 2 THEN
                EXIT;
              END IF;
          END IF;

          --4570421, adding for testing, remove it
          --x_avail_assembly_qty := 0;

          -- 2869830
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('avail_assembly_qty: ' || x_avail_assembly_qty);
          END IF;

          IF l_rounding_flag = 1 THEN
              x_avail_assembly_qty := FLOOR(x_avail_assembly_qty);
              msc_sch_wb.atp_debug('rounded avail qty: ' ||
                          x_avail_assembly_qty);
          END IF;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'x_avail_assembly_qty' || x_avail_assembly_qty);
          END IF;
        ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'p_search = 2');
          END IF;

          IF l_atp_rec.ship_date IS NOT NULL THEN
            x_atp_date :=  GREATEST(MSC_CALENDAR.DATE_OFFSET
                                 (p_organization_id,
                                  p_instance_id,
                                  1,
                                  l_atp_rec.ship_date,
                                  NVL(l_comp_requirements.lead_time(j), 0)),
                                  x_atp_date);

            ---bug 3059305: If x_atp_date is greater than or equal to ship date from last source
            -- then date from last source will be used as the availability date.
            ---Therefore, no need to continue further
            IF x_atp_date >= p_comp_info_rec.ship_date_this_level THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'x_atp_date := ' || x_atp_date);
                  msc_sch_wb.atp_debug('Get_Comp_Requirements: ' || 'x_atp_date > ship_date_this_level. Therefore exit');
               END IF;
               x_atp_date := null;
               EXIT;
            END IF;
          ELSE
            x_atp_date := NULL;
            EXIT;
          END IF;
        END IF;

        j := l_comp_requirements.inventory_item_id.NEXT(j);

    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Get_Comp_Requirements *****');
    END IF;


Exception

    WHEN MSC_ATP_PVT.INVALID_OSS_SOURCE THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Reqs: ' || 'Invalid OSS setup detected');
        END IF;
        x_avail_assembly_qty  := 0;
        x_atp_date            := null;
        x_return_status := MSC_ATP_PVT.CTO_OSS_Error;

    -- 2400614 : krajan
    WHEN MSC_ATP_PVT.G_ATO_SOURCING_MISMATCH THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Get_Comp_Reqs: IN Exception Block for G_ATO_SOURCE');
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        RAISE MSC_ATP_PVT.G_ATO_SOURCING_MISMATCH;

    -- dsting 2764213
    WHEN MSC_ATP_PVT.EXC_NO_PLAN_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Get_Comp_Reqs: IN Exception Block for EXC_NO_PLAN_FOUND');
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        RAISE MSC_ATP_PVT.EXC_NO_PLAN_FOUND;

    -- krajan 2752705
    WHEN MSC_ATP_PVT.G_EXC_UNCOLLECTED_ITEM THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Get_Comp_Reqs: IN Exception Block for G_EXC_UNCOLLECTED_ITEM');
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
        RAISE MSC_ATP_PVT.G_EXC_UNCOLLECTED_ITEM;

    ---bug 3308206: Add exception so that it could be propogated to ATP_check
    WHEN  MSC_ATP_PVT.EXC_NO_ATP_RULE THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Comp_Reqs: IN Exception Block for EXC_NO_ATP_RULE');
        END IF;
        RAISE MSC_ATP_PVT.EXC_NO_ATP_RULE;

    WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN --bug3583705
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Get_Comp_Reqs: IN Exception Block for NO_MATCHING_DATE_IN_CAL');
        END IF;
        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug ('Get_Comp_Reqs: IN Exception Block in others');
           msc_sch_wb.atp_debug ('error := ' || SQLERRM);
        END IF;
        x_return_status := NVL(x_return_status, FND_API.G_RET_STS_ERROR);
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Comp_Requirements;

/* Spec changes as part of ship_rec_cal changes
   Various input output parameters grouped in the record Atp_Info_Rec*/
PROCEDURE Get_Supplier_Atp_Info (
  p_sup_atp_info_rec                    IN OUT  NOCOPY  MSC_ATP_REQ.Atp_Info_Rec,
  x_atp_period                          OUT     NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT     NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT     NOCOPY  VARCHAR2
)
IS

i 			PLS_INTEGER := 1;
m                       PLS_INTEGER := 1;
k                       PLS_INTEGER := 1;
j                       PLS_INTEGER := 1; --4055719
l_requested_date	DATE;
l_atp_requested_date    DATE;
l_pre_process_date      DATE;
l_sysdate               DATE;

l_atp_period_tab 	MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_atp_qty_tab 		MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr();
l_next_period           DATE;
l_null_num              number := null;
l_null_char             varchar2(3) := null;
l_plan_start_date       DATE;
l_demand_class          varchar2(30) := null;
l_uom_code              varchar2(10);
l_instance_id           number;
l_org_id                number;
l_processing_lead_time  number;
l_postprocessing_lead_time      NUMBER;   -- SCLT new variable to remove join with msc_system_items

l_default_atp_rule_id           NUMBER;
l_calendar_code                 VARCHAR2(14);
l_calendar_exception_set_id     NUMBER;
l_default_demand_class          VARCHAR2(34);
l_atp_info                      MRP_ATP_PVT.ATP_Info;
l_cutoff_date                   DATE;
l_capacity_defined              NUMBER;
l_pre_process_lt		NUMBER;
l_fix_var_lt 			NUMBER;
l_tolerence_defined             NUMBER;

l_org_code                      VARCHAR2(7);
L_QTY_BEFORE_SYSDATE            number;

l_last_cap_date                 date;

--s_cto_rearch
l_inv_item_id                   number;
l_check_cap_model_flag          number;
--e_cto_rearch

-- For summary enhancement
l_summary_flag  NUMBER;
l_summary_sql   VARCHAR2(1);

-- Variables added for ship_rec_cal
-- l_plan_type                  PLS_INTEGER;    -- Variables commented for
-- l_enforce_sup_capacity       PLS_INTEGER;    -- Enforce Pur LT
l_last_cap_next_date		DATE;
l_atp_date_this_level           DATE := NULL ;
l_atp_date_quantity_this_level  NUMBER := NULL;
l_requested_date_quantity	NUMBER := 0;
-- l_optimized_plan             NUMBER;         -- Variables commented for
-- l_constrain_plan             NUMBER;         -- Enforce Pur LT

-- time_phased_atp
l_return_status                 VARCHAR2(1);

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Get_Supplier_Atp_Info Procedure *****');
        msc_sch_wb.atp_debug('********** INPUT DATA:Get_Supplier_Atp_Info **********');
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'inventory_item_id: '|| to_char(p_sup_atp_info_rec.inventory_item_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'organization_id: '|| to_char(p_sup_atp_info_rec.organization_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'requested_date: '|| to_char(p_sup_atp_info_rec.requested_date));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'instance_id: '|| to_char(p_sup_atp_info_rec.instance_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'plan_id: '|| to_char(p_sup_atp_info_rec.plan_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'quantity_ordered: '|| to_char(p_sup_atp_info_rec.quantity_ordered));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'insert_flag: '|| to_char(p_sup_atp_info_rec.insert_flag));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'supplier_id: '|| to_char(p_sup_atp_info_rec.supplier_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'supplier_site_id: '|| to_char(p_sup_atp_info_rec.supplier_site_id));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'sup_cap_cum_date: '|| to_char(p_sup_atp_info_rec.sup_cap_cum_date));
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || ' bom_item_type : ' || p_sup_atp_info_rec.bom_item_type);
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'rep_ord_flag := ' || p_sup_atp_info_rec.rep_ord_flag);
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'base item id := ' ||  p_sup_atp_info_rec.base_item_id);
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'MSC_ATP_PVT.G_PTF_DATE := ' || MSC_ATP_PVT.G_PTF_DATE);
    END IF;


    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_requested_date := trunc(p_sup_atp_info_rec.requested_date);

    ---profile option for including purchase order
    MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE := NVL(FND_PROFILE.VALUE('MSC_PO_DOCK_DATE_CALC_PREF'), 2);

    -- Instead re-assigned local values using global variable
    l_uom_code := MSC_ATP_PVT.G_ITEM_INFO_REC.uom_code;
    l_postprocessing_lead_time := MSC_ATP_PVT.G_ITEM_INFO_REC.pre_pro_lt;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('G_PURCHASE_ORDER_PREFERENCE := ' || G_PURCHASE_ORDER_PREFERENCE);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_uom_code and l_postprocessing_lead_time = '||
          l_uom_code ||' : '||l_postprocessing_lead_time);
    END IF;

    --s_cto_rearch
    IF (p_sup_atp_info_rec.bom_item_type = 4 and p_sup_atp_info_rec.rep_ord_flag = 'Y') THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('ATO item');
           END IF;
           l_inv_item_id := p_sup_atp_info_rec.base_item_id;
           l_check_cap_model_flag := 1;
    ELSIF  p_sup_atp_info_rec.bom_item_type = 1 THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Model entity');
           END IF;
           l_inv_item_id := p_sup_atp_info_rec.inventory_item_id;
           l_check_cap_model_flag := 1;

    --bug 8631827,7592457 - support aggregate capacity check for non-ATO cases also.
    ELSIF (p_sup_atp_info_rec.bom_item_type = 4 and p_sup_atp_info_rec.base_item_id is not null)  THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Category entity: Aggregate Supply');
           END IF;
           l_inv_item_id := p_sup_atp_info_rec.base_item_id;
           l_check_cap_model_flag := 1;
    ELSE
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Standard Item');
           END IF;
           l_inv_item_id := p_sup_atp_info_rec.inventory_item_id;
    END IF;
    --e_cto_rearch
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('l_inv_item_id := ' || l_inv_item_id);
    END IF;


    -- bug 1169467
    -- get the plan start date. later on we will use this restrict the
    -- availability

    -- Instead re-assigned local values using global variable
    l_plan_start_date := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_start_date;
    l_instance_id     := MSC_ATP_PVT.G_PLAN_INFO_REC.sr_instance_id;
    l_org_id          := MSC_ATP_PVT.G_PLAN_INFO_REC.organization_id;
    l_cutoff_date     := MSC_ATP_PVT.G_PLAN_INFO_REC.plan_cutoff_date;

    /* Modularize Item and Org Info */
    -- changed call, re-use info already obtained.
    -- Assumption is that since the instance and org is obtained using the plan_id,
    -- they are the same as the parameters p_sup_atp_info_rec.instance_id, p_sup_atp_info_rec.organization_id.
    MSC_ATP_PROC.get_global_org_info(l_instance_id, l_org_id);
    l_default_atp_rule_id := MSC_ATP_PVT.G_ORG_INFO_REC.default_atp_rule_id;
    l_default_demand_class := MSC_ATP_PVT.G_ORG_INFO_REC.default_demand_class;
    l_org_code := MSC_ATP_PVT.G_ORG_INFO_REC.org_code;

    /*
     Changes for ship_rec_cal begin
     1. For ship_rec_cal, Use SMC rather thn OMC for supplier capacity
     2. Supplier Capacity is considered infinite in following cases:
      (a) Plan is a constraint plan and 'enforce supplier capacity constraint' is unchecked.
      (b) No sources are defined. That means supplier_id = -99
      (b) Plan is an unconstraint plan and supplier is defined but it has not have any capacity, ie l_last_cap_date is null
    */
    l_calendar_code := p_sup_atp_info_rec.manufacturing_cal_code;

    l_calendar_exception_set_id := -1;
    -- l_enforce_sup_capacity	:= NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.enforce_sup_capacity, 2); -- Enforce Pur LT
    l_sysdate := MSC_CALENDAR.PREV_WORK_DAY(l_calendar_code, p_sup_atp_info_rec.instance_id, sysdate);
    l_requested_date := MSC_CALENDAR.PREV_WORK_DAY(l_calendar_code, p_sup_atp_info_rec.instance_id, p_sup_atp_info_rec.requested_date);

    /* Enforce Pur LT - capacity is always enforced
       Removed code to check the plan type. This was earlier required as capacity constraints were earlier enforced
       only for unconstrained plans or if the plan option to enforce capacity was enforced. Now this is not required
       as capacity is always enforced. */

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_plan_start_date = '||l_plan_start_date);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_instance_id = '||l_instance_id);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_org_id = '||l_org_id);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_cutoff_date = '||l_cutoff_date);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_default_atp_rule_id='||
                            l_default_atp_rule_id);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_calendar_code='||l_calendar_code);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_calendar_exception_set_id'||
                            l_calendar_exception_set_id);
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_default_demand_class'||
                            l_default_demand_class);
    END IF;

    /* Enforce Pur LT - capacity is always enforced.
       Aslo removed code to get last cap date as this code has been moved upstream in ATP_Check.
       Date is passed from there. If the passed date is NULL then it means capacity is not defined.*/
    -- IF (p_sup_atp_info_rec.supplier_id = -99) OR (l_plan_type = 1 AND l_enforce_sup_capacity = 2) THEN
    IF (p_sup_atp_info_rec.supplier_id = -99) OR p_sup_atp_info_rec.last_cap_date IS NULL THEN
	l_capacity_defined := 0;
	l_last_cap_next_date := MSC_CALENDAR.NEXT_WORK_DAY(
		l_calendar_code,
		p_sup_atp_info_rec.instance_id,
		GREATEST(l_plan_start_date, MSC_ATP_PVT.G_PTF_DATE, p_sup_atp_info_rec.sup_cap_cum_date));
    ELSE
	l_capacity_defined := 1;
	l_last_cap_next_date :=  MSC_CALENDAR.NEXT_WORK_DAY(
                l_calendar_code,
                p_sup_atp_info_rec.instance_id,
                p_sup_atp_info_rec.last_cap_date + 1);
    END IF;
    /* Enforce Pur LT changes end */

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_last_cap_next_date='||
                            l_last_cap_next_date);
    END IF;

    IF l_capacity_defined = 0 THEN
        -- no capacity is ever defined, treat it as infinite capacity and
        -- by pass the huge sql for net atp

        -- add one more entry to indicate sysdate
        -- and infinite quantity.
        l_atp_period_tab.EXTEND;
        l_atp_qty_tab.EXTEND;
        i:= l_atp_period_tab.COUNT;
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_plan_start_date := ' || l_plan_start_date);
        END IF;

        -- Ship_rec_cal.
        l_atp_period_tab(i) := l_last_cap_next_date;
        l_atp_qty_tab(i) := MSC_ATP_PVT.INFINITE_NUMBER;

        IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0) THEN

            -- dsting clear sd details temp table
            MSC_ATP_DB_UTILS.Clear_SD_Details_Temp();

            -- add one more entry to indicate infinite time fence date
            -- and quantity.
            MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);
            i:= x_atp_period.level.COUNT;

            x_atp_period.Level(i) := p_sup_atp_info_rec.level;
            x_atp_period.Identifier(i) := p_sup_atp_info_rec.identifier;
            x_atp_period.Scenario_Id(i) := p_sup_atp_info_rec.scenario_id;
            x_atp_period.Pegging_Id(i) := NULL;
            x_atp_period.End_Pegging_Id(i) := NULL;

            x_atp_period.Supplier_Id(i) := p_sup_atp_info_rec.supplier_id;
            x_atp_period.Supplier_Site_Id(i) := p_sup_atp_info_rec.supplier_site_id;
            x_atp_period.Organization_id(i) := p_sup_atp_info_rec.organization_id;

            --  ship_rec_cal changes begin
            x_atp_period.Period_Start_Date(i) := l_last_cap_next_date;
            --  ship_rec_cal changes end

            x_atp_period.Total_Supply_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
            x_atp_period.Total_Demand_Quantity(i) := 0;
            x_atp_period.Period_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
            x_atp_period.Cumulative_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;

        END IF;
    ELSE  -- else of l_capacity_defined = 0

        -- we really need to check net supplier site capacity
        -- we need to have a branch here for allocated atp
        IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'N') OR
           (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y' AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND
                 MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)  THEN

         -- check if we have tolerence defined for this item/org/supplier/site

         l_tolerence_defined := 0;
         BEGIN
           SELECT rownum
           INTO   l_tolerence_defined
           FROM   msc_supplier_flex_fences
           WHERE  plan_id = p_sup_atp_info_rec.plan_id
           AND    sr_instance_id = p_sup_atp_info_rec.instance_id
           AND    organization_id = p_sup_atp_info_rec.organization_id
           --s_cto_rearch
           --AND    inventory_item_id = p_sup_atp_info_rec.inventory_item_id
           AND    inventory_item_id = l_inv_item_id
           AND    supplier_id = p_sup_atp_info_rec.supplier_id
           AND    supplier_site_id = p_sup_atp_info_rec.supplier_site_id
           AND    rownum = 1;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
               l_tolerence_defined := 0;
        END;

        --  structure changed slightly for summary enhancement. Now it is as follows
        --  IF insert_flag = 0 THEN
        --      IF l_tolerence_defined = 0 AND G_SUMMARY_FLAG='Y' THEN
        --          IF summary_flag not in (1,3,9) THEN
        --              l_summary_sql := 'Y'
        --          ELSE
        --              l_summary_sql := 'N'
        --          END IF;
        --      END IF;
        --      IF l_summary_sql = 'Y' THEN
        --          use summary SQLs
        --      ELSE
        --          use non summary SQLs
        --      END IF;
        --  ELSE
        --      use details SQLs
        --  END IF;

        --=======================================================================================================
        --  ship_rec_cal changes
        --  use SMC instead of OMC for netting
        --  IF SMC is FOC get plan owning org's calendar. Since we assume that every org must have atleast a
        --  manufacturing calendar defined, we use plan owning org's calendar as it will be spanning atleast
        --  upto plan end date
        --=======================================================================================================
        IF l_calendar_code = '@@@' THEN
                SELECT  tp.calendar_code
                INTO    l_calendar_code
                FROM    msc_trading_partners tp,
                        msc_plans mp
                WHERE   mp.plan_id = p_sup_atp_info_rec.plan_id
                AND     tp.sr_instance_id  = mp.sr_instance_id
                AND     tp.partner_type    = 3
                AND     tp.sr_tp_id        = mp.organization_id;
        END IF;

        msc_sch_wb.atp_debug('l_calendar_code := ' || l_calendar_code);
        --=======================================================================================================
        -- ship_rec_cal changes begin
        --=======================================================================================================
        --  In all the SQLs that get supplier capacities following are the changes:
        --  1. Pass (c.seq_num - p_sup_atp_info_rec.sysdate_seq_num) to get_tolerance_percentage fn instead of
        --     passing c.calendar_date.
        --  2. If calendar code passed in FOC, we use plan owning org's calendar and remove p_seq_num is not
        --     null filter condition.
        --
        --  In all the SQLs that get planned orders, purchase orders and purchase requisitions following
        --  are the changes:
        --  1. We use new_dock_date or new_ship_date depending on whether supplier capacity is dock capacity or
        --     ship capacity.
        --     Earlier we used to look at new_schedule_date and offset post_processing_lead_time.
        --  2. Removed join with msc_calendar_dates
        --=======================================================================================================

        IF (NVL(p_sup_atp_info_rec.insert_flag, 0) = 0) THEN
            IF (l_tolerence_defined = 0) AND (MSC_ATP_PVT.G_SUMMARY_FLAG = 'Y') THEN
                ---- we do summary approach only if tolerance is not defined
                ---- since one of the components for calculating tolerance is difference of sys_date and
                ---- request date, we might not get a right data if we include tolerance in summary data

                -- Summary enhancement - check summary flag
                SELECT  summary_flag
                INTO    l_summary_flag
                FROM    msc_plans plans
                WHERE   plans.plan_id = p_sup_atp_info_rec.plan_id;

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_summary_flag := ' || l_summary_flag);
                END IF;

                IF l_summary_flag NOT IN (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN, MSC_POST_PRO.G_SF_PREALLOC_COMPLETED,
                                          MSC_POST_PRO.G_SF_FULL_SUMMARY_RUNNING) THEN
                    -- Summary SQL can be used
                    l_summary_sql := 'Y';
                ELSE
                    l_summary_sql := 'N';
                END IF;
            ELSE
                l_summary_sql := 'N';
            END IF;

            IF l_summary_sql = 'Y' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Summary mode supplier info');
                END IF;

                IF l_check_cap_model_flag = 1 THEN

                    SELECT  SD_DATE,
                            SUM(SD_QTY)
                    BULK COLLECT INTO l_atp_period_tab, l_atp_qty_tab
                    FROM
                        (
                            select  /*+ INDEX(msc_atp_summary_sup MSC_ATP_SUMMARY_SUP_U1) */
                                    sd_date,
                                    sd_qty
                            from    msc_atp_summary_sup
                            where   plan_id = p_sup_atp_info_rec.plan_id
                            and     sr_instance_id = p_sup_atp_info_rec.instance_id
                            and     supplier_id = p_sup_atp_info_rec.supplier_id
                            and     supplier_site_id = p_sup_atp_info_rec.supplier_site_id
                            --and     sd_date >= l_plan_start_date
                            and     sd_date BETWEEN l_plan_start_date
                                                    AND  least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date) --4055719
                            and     sd_qty <> 0
                            AND    (inventory_item_id = l_inv_item_id OR
                                    inventory_item_id in
                                           (select inventory_item_id from msc_system_items msi
                                            where  msi.base_item_id = l_inv_item_id
                                            and    msi.plan_id = p_sup_atp_info_rec.plan_id
                                            and    msi.organization_id = p_sup_atp_info_rec.organization_id
                                            and    msi.base_item_id = l_inv_item_id))

                            UNION ALL

                            -- Summary enhancement : differences from non summary SQL: ship/rec cal changes pending
                            --  1. No union with MSC_SUPPLIER_CAPACITIES
                            --  2. MSC_PLANS included in the join to get latest refresh number
                            --  3. Filter records based on refresh_number
                            --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                            SELECT  TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) l_date, -- For ship_rec_cal
                                    (NVL(p.implement_quantity,0) - p.new_order_quantity) quantity
                            FROM    msc_supplies p,
                                    msc_plans pl            -- For summary enhancement
                            WHERE  (p.order_type IN (5, 2,60)
                                    OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                    AND p.order_type = 1 AND p.promised_date IS NULL))
                            AND     p.plan_id = p_sup_atp_info_rec.plan_id
                            AND     p.sr_instance_id = p_sup_atp_info_rec.instance_id
                            AND     p.supplier_id  = p_sup_atp_info_rec.supplier_id
                            AND     NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                            AND     NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2
                            AND    (p.inventory_item_id = l_inv_item_id OR
                                    p.inventory_item_id in
                                           (select inventory_item_id from msc_system_items msi
                                            where  msi.sr_instance_id = p_sup_atp_info_rec.instance_id
                                            and    msi.plan_id = p_sup_atp_info_rec.plan_id
                                            and    msi.organization_id = p_sup_atp_info_rec.organization_id
                                            and    msi.base_item_id = l_inv_item_id))
                            AND     pl.plan_id = p.plan_id                          -- For summary enhancement
                            AND     (p.refresh_number > pl.latest_refresh_number    -- For summary enhancement
                                     OR p.refresh_number = p_sup_atp_info_rec.refresh_number)        -- For summary enhancement
                            AND    Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date) --4055719
                                          <= least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)
                        )
                    GROUP BY SD_DATE
                    ORDER BY SD_DATE;

                ELSE

                    SELECT  SD_DATE,
                            SUM(SD_QTY)
                    BULK COLLECT INTO l_atp_period_tab, l_atp_qty_tab
                    FROM
                        (
                            select  /*+ INDEX(msc_atp_summary_sup MSC_ATP_SUMMARY_SUP_U1) */
                                   trunc( sd_date) SD_DATE, --4135752
                                    sd_qty
                            from    msc_atp_summary_sup
                            where   plan_id = p_sup_atp_info_rec.plan_id
                            and     sr_instance_id = p_sup_atp_info_rec.instance_id
                            and     inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                            and     supplier_id = p_sup_atp_info_rec.supplier_id
                            and     supplier_site_id = p_sup_atp_info_rec.supplier_site_id
                            --and     sd_date >= l_plan_start_date
                            and     sd_date BETWEEN l_plan_start_date
                                                    AND  least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date) --4055719
                            and     sd_qty <> 0

                            UNION ALL

                            -- Summary enhancement : differences from non summary SQL: ship/rec cal changes pending
                            --  1. No union with MSC_SUPPLIER_CAPACITIES
                            --  2. MSC_PLANS included in the join to get latest refresh number
                            --  3. Filter records based on refresh_number
                            --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                            SELECT  TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) l_date, -- For ship_rec_cal
                                    (NVL(p.implement_quantity,0) - p.new_order_quantity) quantity
                            FROM    msc_supplies p,
                                    msc_plans pl            -- For summary enhancement
                            WHERE  (p.order_type IN (5, 2, 60)
                                    OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                    AND p.order_type = 1 AND p.promised_date IS NULL))
                            AND     p.plan_id = p_sup_atp_info_rec.plan_id
                            AND     p.sr_instance_id = p_sup_atp_info_rec.instance_id
                            AND     p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                            AND     p.supplier_id  = p_sup_atp_info_rec.supplier_id
                            AND     NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                            AND     NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2
                            AND     pl.plan_id = p.plan_id                          -- For summary enhancement
                            AND     (p.refresh_number > pl.latest_refresh_number    -- For summary enhancement
                                     OR p.refresh_number = p_sup_atp_info_rec.refresh_number)        -- For summary enhancement
                            AND     Decode(p_sup_atp_info_rec.sup_cap_type, 1, trunc(p.new_ship_date),trunc(p.new_dock_date)) --4055719 --4135752
                                          <= trunc(least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))          --4135752
                        )
                    GROUP BY SD_DATE
                    ORDER BY SD_DATE;

                END IF;

                MSC_ATP_PROC.atp_consume(l_atp_qty_tab, l_atp_qty_tab.COUNT);

                /* Cum drop issue changes begin*/
                MSC_AATP_PROC.Atp_Remove_Negatives(l_atp_qty_tab, l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                /* Cum drop issue changes end*/

            ELSE    -- IF l_summary_sql = 'Y' THEN

                IF l_check_cap_model_flag = 1 THEN
                    msc_sch_wb.atp_debug('Check Sources for model, details are off');

                    SELECT  trunc(l_date), SUM(quantity)  --4135752
                    BULK COLLECT INTO
                    l_atp_period_tab,
                    l_atp_qty_tab
                    FROM (
                    SELECT c.calendar_date l_date, s.capacity*(1+
                                                 DECODE(l_tolerence_defined, 0, 0,
                                                 NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                                 p_sup_atp_info_rec.instance_id,
                                                 p_sup_atp_info_rec.plan_id,
                                                 l_inv_item_id,
                                                 p_sup_atp_info_rec.organization_id,
                                                 p_sup_atp_info_rec.supplier_id,
                                                 p_sup_atp_info_rec.supplier_site_id,
                                                 -- ship_rec_cal
                                                 c.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))) quantity
                    FROM   msc_calendar_dates c,
                           msc_supplier_capacities s
                    WHERE  s.inventory_item_id = l_inv_item_id
                    AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                    AND    s.plan_id = p_sup_atp_info_rec.plan_id
                    AND    s.organization_id = p_sup_atp_info_rec.organization_id
                    AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                    AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                    AND    c.calendar_date BETWEEN trunc(s.from_date)
                                           --AND NVL(s.to_date,l_cutoff_date)
                                           AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                    AND    (c.seq_num IS NOT NULL OR p_sup_atp_info_rec.manufacturing_cal_code  = MSC_CALENDAR.FOC)
                    AND    c.calendar_code = l_calendar_code
                    AND    c.exception_set_id = l_calendar_exception_set_id
                    AND    c.sr_instance_id = s.sr_instance_id -- Changed from l_instance_id ?
                    AND    c.calendar_date >= p_sup_atp_info_rec.sup_cap_cum_date
                    -- Supplier Capacity (SCLT) Accumulation starts from this date.
                    -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                    UNION ALL
                    /* Net out planned orders, purchase orders and purchase requisitions */
                    -- bug 1303196
                    --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                    SELECT TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) l_date, -- For ship_rec_cal
        	           -- performance dsting rearrange signs to get rid of multiply times -1
                           (NVL(p.implement_quantity,0) - p.new_order_quantity) quantity
                    FROM   msc_supplies p
                    WHERE  (p.order_type IN (5, 2, 60)
                            --include purchase orders based on profile option
                            OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                AND p.order_type = 1 AND p.promised_date IS NULL))
                    -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
                    -- WHERE  p.order_type IN (5, 1, 2)
                    AND    p.plan_id = p_sup_atp_info_rec.plan_id
                    AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
              -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
                    AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
                    AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                           -- Exclude Cancelled Supplies 2460645
                    AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                    -- Supplier Capacity (SCLT) Changes End
                           ---only consider ATP inserted POs
                           --- Plan POs are tied to forecast.
                    AND    ((p.inventory_item_id = l_inv_item_id and p.record_source=2) OR
                            p.inventory_item_id in
                                   (select inventory_item_id from msc_system_items msi
                                    where  msi.sr_instance_id = p_sup_atp_info_rec.instance_id
                                    and    msi.plan_id = p_sup_atp_info_rec.plan_id
                                    and    msi.organization_id = p_sup_atp_info_rec.organization_id
                                    and    msi.base_item_id = l_inv_item_id))
                     AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                                 <= trunc(least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)))
                    GROUP BY l_date
                    ORDER BY l_date;

                    MSC_ATP_PROC.atp_consume(l_atp_qty_tab, l_atp_qty_tab.COUNT);

                    /* Cum drop issue changes begin*/
                    MSC_AATP_PROC.Atp_Remove_Negatives(l_atp_qty_tab, l_return_status);
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    /* Cum drop issue changes end*/

                ELSE

                    SELECT  trunc(l_date), SUM(quantity)  --4135752
                    BULK COLLECT INTO
                    l_atp_period_tab,
                    l_atp_qty_tab
                    FROM (
                    SELECT c.calendar_date l_date, s.capacity*(1+
                                                 DECODE(l_tolerence_defined, 0, 0,
                                                 NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                                 p_sup_atp_info_rec.instance_id,
                                                 p_sup_atp_info_rec.plan_id,
                                                 p_sup_atp_info_rec.inventory_item_id,
                                                 p_sup_atp_info_rec.organization_id,
                                                 p_sup_atp_info_rec.supplier_id,
                                                 p_sup_atp_info_rec.supplier_site_id,
                                                 -- ship_rec_cal
                                                 c.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))) quantity
                    FROM   msc_calendar_dates c,
                           msc_supplier_capacities s
                    WHERE  s.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                    AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                    AND    s.plan_id = p_sup_atp_info_rec.plan_id
                    AND    s.organization_id = p_sup_atp_info_rec.organization_id
                    AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                    AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                    AND    c.calendar_date BETWEEN trunc(s.from_date)
                                           --AND NVL(s.to_date,l_cutoff_date)
                                           AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                    AND    (c.seq_num IS NOT NULL OR p_sup_atp_info_rec.manufacturing_cal_code  = MSC_CALENDAR.FOC)
                    AND    c.calendar_code = l_calendar_code
                    AND    c.exception_set_id = l_calendar_exception_set_id
                    AND    c.sr_instance_id = s.sr_instance_id -- Changed from l_instance_id ?
                    AND    c.calendar_date >= trunc(p_sup_atp_info_rec.sup_cap_cum_date) --4135752
                    -- Supplier Capacity (SCLT) Accumulation starts from this date.
                    -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                    UNION ALL
                    /* Net out planned orders, purchase orders and purchase requisitions */
                    -- bug 1303196
                    --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                    SELECT TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) l_date, -- For ship_rec_cal
        	           -- performance dsting rearrange signs to get rid of multiply times -1
                           (NVL(p.implement_quantity,0) - p.new_order_quantity) quantity
                    FROM   msc_supplies p
                        WHERE  (p.order_type IN (5, 2, 60)
                                --include purchase orders based on profile option
                                OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                    AND p.order_type = 1 AND p.promised_date IS NULL))
                        -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
                        -- WHERE  p.order_type IN (5, 1, 2)
                        AND    p.plan_id = p_sup_atp_info_rec.plan_id
                        AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
                        AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                  -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
                        AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
                        AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                               -- Exclude Cancelled Supplies 2460645
                        AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2
                        AND   trunc( Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                                      <= trunc(least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)))
                        GROUP BY l_date
                        ORDER BY l_date;

                        MSC_ATP_PROC.atp_consume(l_atp_qty_tab, l_atp_qty_tab.COUNT);

                        /* Cum drop issue changes begin*/
                        MSC_AATP_PROC.Atp_Remove_Negatives(l_atp_qty_tab, l_return_status);
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                IF PG_DEBUG in ('Y', 'C') THEN
                                        msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                                END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        /* Cum drop issue changes end*/

                    END IF; --IF l_check_cap_model_flag = 1 THEN

                END IF; -- IF l_summary_sql = 'Y' THEN

            ELSE  -- now p_sup_atp_info_rec.insert_flag <> 0

                MSC_ATP_DB_UTILS.Clear_SD_Details_temp();

                IF l_check_cap_model_flag = 1 THEN
                    msc_sch_wb.atp_debug('Check Sources for model, details are on');
                    INSERT INTO msc_atp_sd_details_temp (
                       ATP_level,
                       Order_line_id,
                       Scenario_Id,
                       Inventory_Item_Id,
                       Request_Item_Id,
                       Organization_Id,
                       Department_Id,
                       Resource_Id,
                       Supplier_Id,
                       Supplier_Site_Id,
                       From_Organization_Id,
                       From_Location_Id,
                       To_Organization_Id,
                       To_Location_Id,
                       Ship_Method,
                       UOM_code,
                       Supply_Demand_Type,
                       Supply_Demand_Source_Type,
                       Supply_Demand_Source_Type_Name,
                       Identifier1,
                       Identifier2,
                       Identifier3,
                       Identifier4,
                       Supply_Demand_Quantity,
                       Supply_Demand_Date,
                       Disposition_Type,
                       Disposition_Name,
                       Pegging_Id,
                       End_Pegging_Id,
                       creation_date,
                       created_by,
                       last_update_date,
                       last_updated_by,
                       last_update_login
                    )

                         (SELECT
                                p_sup_atp_info_rec.level col1,
                                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                                p_sup_atp_info_rec.scenario_id col3,
                                l_null_num col4 ,
                                l_null_num col5,
                                p_sup_atp_info_rec.organization_id col6,
                                l_null_num col7,
                                l_null_num col8,
                                p_sup_atp_info_rec.supplier_id col9,
                                p_sup_atp_info_rec.supplier_site_id col10,
                                l_null_num col11,
                                l_null_num col12,
                                l_null_num col13,
                                l_null_num col14,
                                l_null_char col15,
                                l_uom_code col16,
                                2 col17, -- supply
                                l_null_num col18,
                                l_null_char col19,
                                p_sup_atp_info_rec.instance_id col20,
                                l_null_num col21,
                                l_null_num col22,
                                l_null_num col23,
                                s.capacity*(1+ DECODE(l_tolerence_defined, 0, 0,
                                                  NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                                  p_sup_atp_info_rec.instance_id,
                                                  p_sup_atp_info_rec.plan_id,
                                                  l_inv_item_id,
                                                  p_sup_atp_info_rec.organization_id,
                                                  p_sup_atp_info_rec.supplier_id,
                                                  p_sup_atp_info_rec.supplier_site_id,
                                                  -- ship_rec_cal
                                                  c.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))) col24,
                                C.CALENDAR_DATE col25,
                                l_null_num col26,
                                l_null_char col27,
                                l_null_num col28,
                                l_null_num col29,
                                l_sysdate,
                                FND_GLOBAL.User_ID,
                                l_sysdate,
                                FND_GLOBAL.User_ID,
                                FND_GLOBAL.User_ID
                         FROM   msc_calendar_dates c,
                                msc_supplier_capacities s
                         WHERE  s.inventory_item_id = l_inv_item_id
                         AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                         AND    s.plan_id = p_sup_atp_info_rec.plan_id
                         AND    s.organization_id = p_sup_atp_info_rec.organization_id
                         AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                         AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                         AND    c.calendar_date BETWEEN trunc(s.from_date)
                                                --AND NVL(s.to_date,l_cutoff_date)
                                                AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                         AND    (c.seq_num IS NOT NULL OR p_sup_atp_info_rec.manufacturing_cal_code  = MSC_CALENDAR.FOC)
                         AND    c.calendar_code = l_calendar_code
                         AND    c.exception_set_id = l_calendar_exception_set_id
                         AND    c.sr_instance_id = s.sr_instance_id  -- Changed from l_instance_id ?
                         AND    c.calendar_date >= trunc(p_sup_atp_info_rec.sup_cap_cum_date) --4135752
                         -- Supplier Capacity (SCLT) Accumulation starts from this date.
                         -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                         UNION ALL
                         SELECT
                                p_sup_atp_info_rec.level col1,
                                MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                                p_sup_atp_info_rec.scenario_id col3,
                                l_null_num col4 ,
                                l_null_num col5,
                                p_sup_atp_info_rec.organization_id col6,
                                l_null_num col7,
                                l_null_num col8,
                                p_sup_atp_info_rec.supplier_id col9,
                                p_sup_atp_info_rec.supplier_site_id col10,
                                l_null_num col11,
                                l_null_num col12,
                                l_null_num col13,
                                l_null_num col14,
                                l_null_char col15,
                                l_uom_code col16,
                                1 col17, -- demand
                                p.order_type col18,
                                l_null_char col19,
                                p_sup_atp_info_rec.instance_id col20,
                                l_null_num col21,
                                TRANSACTION_ID col22,
                                l_null_num col23,
                                -- performance dsting rearrange signs to get rid of multiply times - 1
                                (NVL(p.implement_quantity,0) - p.new_order_quantity) col24,
                                --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                                TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) col25, -- For ship_rec_cal
                                l_null_num col26,
                                --bug 4493399: show transaction id for PO
                                --p.order_number col27,
                                DECODE(p.ORDER_TYPE, 5, to_char(p.TRANSACTION_ID), p.order_number) col27,
                                l_null_num col28,
                                l_null_num col29,
                                l_sysdate,
                                FND_GLOBAL.User_ID,
                                l_sysdate,
                                FND_GLOBAL.User_ID,
                                FND_GLOBAL.User_ID
                                -- Supplier Capacity (SCLT) Changes Begin
                         FROM   msc_supplies p
                         WHERE  (p.order_type IN (5, 2, 60)
                                 --include purchase orders based on profile option
                                 OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                     AND p.order_type = 1 AND p.promised_date IS NULL))
                         -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
                         -- WHERE  p.order_type IN (5, 1, 2)
                         AND    p.plan_id = p_sup_atp_info_rec.plan_id
                         AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
                         --AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
                   -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
                         AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
                         AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                                -- Exclude Cancelled Supplies 2460645
                         AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2 -- Bug 2460645
                                 ---we only consider ATP inserted PO for MOdels.
                                 --Ignore Planning inserted POs for models as they would be tied to forecats
                         AND    ((p.inventory_item_id = l_inv_item_id and p.record_source=2) OR
                                    p.inventory_item_id in
                                           (select inventory_item_id from msc_system_items msi
                                            where  msi.sr_instance_id = p_sup_atp_info_rec.instance_id
                                            and    msi.plan_id = p_sup_atp_info_rec.plan_id
                                            and    msi.organization_id = p_sup_atp_info_rec.organization_id
                                            and    msi.base_item_id = l_inv_item_id))
                         AND    Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date) --4055719
                                       <= least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)
                    );
                ELSE
            	   INSERT INTO msc_atp_sd_details_temp (
            		   ATP_level,
            		   Order_line_id,
            		   Scenario_Id,
            		   Inventory_Item_Id,
            		   Request_Item_Id,
            		   Organization_Id,
            		   Department_Id,
            		   Resource_Id,
            		   Supplier_Id,
            		   Supplier_Site_Id,
            		   From_Organization_Id,
            		   From_Location_Id,
            		   To_Organization_Id,
            		   To_Location_Id,
            		   Ship_Method,
            		   UOM_code,
            		   Supply_Demand_Type,
            		   Supply_Demand_Source_Type,
            		   Supply_Demand_Source_Type_Name,
            		   Identifier1,
            		   Identifier2,
            		   Identifier3,
            		   Identifier4,
            		   Supply_Demand_Quantity,
            		   Supply_Demand_Date,
            		   Disposition_Type,
            		   Disposition_Name,
            		   Pegging_Id,
            		   End_Pegging_Id,
            		   creation_date,
            		   created_by,
            		   last_update_date,
            		   last_updated_by,
            		   last_update_login
            	   )

                         (SELECT
                               p_sup_atp_info_rec.level col1,
                               MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                               p_sup_atp_info_rec.scenario_id col3,
                               l_null_num col4 ,
                               l_null_num col5,
                               p_sup_atp_info_rec.organization_id col6,
                               l_null_num col7,
                               l_null_num col8,
                               p_sup_atp_info_rec.supplier_id col9,
                               p_sup_atp_info_rec.supplier_site_id col10,
                               l_null_num col11,
                               l_null_num col12,
                               l_null_num col13,
                               l_null_num col14,
                               l_null_char col15,
                               l_uom_code col16,
                               2 col17, -- supply
                               l_null_num col18,
                               l_null_char col19,
                               p_sup_atp_info_rec.instance_id col20,
                               l_null_num col21,
                               l_null_num col22,
                               l_null_num col23,
                               s.capacity*(1+ DECODE(l_tolerence_defined, 0, 0,
                                                  NVL(MSC_ATP_FUNC.get_tolerance_percentage(
                                                  p_sup_atp_info_rec.instance_id,
                                                  p_sup_atp_info_rec.plan_id,
                                                  p_sup_atp_info_rec.inventory_item_id,
                                                  p_sup_atp_info_rec.organization_id,
                                                  p_sup_atp_info_rec.supplier_id,
                                                  p_sup_atp_info_rec.supplier_site_id,
                                                  -- ship_rec_cal
                                                  c.seq_num - p_sup_atp_info_rec.sysdate_seq_num),0))) col24,
                               C.CALENDAR_DATE col25,
                               l_null_num col26,
                               l_null_char col27,
                               l_null_num col28,
                               l_null_num col29,
            		   l_sysdate,
            		   FND_GLOBAL.User_ID,
            		   l_sysdate,
            		   FND_GLOBAL.User_ID,
            		   FND_GLOBAL.User_ID
                     FROM   msc_calendar_dates c,
                            msc_supplier_capacities s
                     WHERE  s.inventory_item_id = l_inv_item_id
                     AND    s.sr_instance_id = p_sup_atp_info_rec.instance_id
                     AND    s.plan_id = p_sup_atp_info_rec.plan_id
                     AND    s.organization_id = p_sup_atp_info_rec.organization_id
                     AND    s.supplier_id = p_sup_atp_info_rec.supplier_id
                     AND    NVL(s.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                     AND    c.calendar_date BETWEEN trunc(s.from_date)
                                            --AND NVL(s.to_date,l_cutoff_date)
                                            AND trunc(NVL(s.to_date,least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date))) --4055719
                     AND    (c.seq_num IS NOT NULL OR p_sup_atp_info_rec.manufacturing_cal_code  = MSC_CALENDAR.FOC)
                     AND    c.calendar_code = l_calendar_code
                     AND    c.exception_set_id = l_calendar_exception_set_id
                     AND    c.sr_instance_id = s.sr_instance_id  -- Changed from l_instance_id ?
                     AND    c.calendar_date >= p_sup_atp_info_rec.sup_cap_cum_date
                     -- Supplier Capacity (SCLT) Accumulation starts from this date.
                     -- AND    c.calendar_date >= l_plan_start_date -- bug 1169467
                     UNION ALL
                     SELECT
                               p_sup_atp_info_rec.level col1,
                               MSC_ATP_PVT.G_ORDER_LINE_ID col2,
                               p_sup_atp_info_rec.scenario_id col3,
                               l_null_num col4 ,
                               l_null_num col5,
                               p_sup_atp_info_rec.organization_id col6,
                               l_null_num col7,
                               l_null_num col8,
                               p_sup_atp_info_rec.supplier_id col9,
                               p_sup_atp_info_rec.supplier_site_id col10,
                               l_null_num col11,
                               l_null_num col12,
                               l_null_num col13,
                               l_null_num col14,
                               l_null_char col15,
                               l_uom_code col16,
                               1 col17, -- demand
                               p.order_type col18,
                               l_null_char col19,
                               p_sup_atp_info_rec.instance_id col20,
                               l_null_num col21,
                               TRANSACTION_ID col22,
                               l_null_num col23,
            		   -- performance dsting rearrange signs to get rid of multiply times - 1
                               (NVL(p.implement_quantity,0) - p.new_order_quantity) col24,
                               --Fixing as a part of bug3709707 adding trunc so that 2 column are not seen in HP
                               TRUNC(Decode(p_sup_atp_info_rec.sup_cap_type,
                                                1, p.new_ship_date,
                                                p.new_dock_date)) col25, -- For ship_rec_cal
                               l_null_num col26,
                               --bug 4493399: show transaction id for PO
                               --p.order_number col27,
                               DECODE(p.ORDER_TYPE, 5, to_char(p.TRANSACTION_ID), p.order_number) col27,
                               l_null_num col28,
                               l_null_num col29,
            		   l_sysdate,
            		   FND_GLOBAL.User_ID,
            		   l_sysdate,
            		   FND_GLOBAL.User_ID,
            		   FND_GLOBAL.User_ID
                     -- Supplier Capacity (SCLT) Changes Begin
                     FROM   msc_supplies p
                     WHERE  (p.order_type IN (5, 2, 60)
                             --include purchase orders based on profile option
                             OR (MSC_ATP_REQ.G_PURCHASE_ORDER_PREFERENCE = MSC_ATP_REQ.G_PROMISE_DATE
                                 AND p.order_type = 1 AND p.promised_date IS NULL))
                     -- Supplier Capacity (SCLT) Accumulation Ignore Purchase Orders
                     -- WHERE  p.order_type IN (5, 1, 2)
                     AND    p.plan_id = p_sup_atp_info_rec.plan_id
                     AND    p.sr_instance_id = p_sup_atp_info_rec.instance_id
                     AND    p.inventory_item_id = p_sup_atp_info_rec.inventory_item_id
               -- 1214694      AND    p.organization_id = p_sup_atp_info_rec.organization_id
                     AND    p.supplier_id  = p_sup_atp_info_rec.supplier_id
                     AND    NVL(p.supplier_site_id, -1) = NVL(p_sup_atp_info_rec.supplier_site_id, -1)
                     AND    trunc(Decode(p_sup_atp_info_rec.sup_cap_type, 1, p.new_ship_date,p.new_dock_date)) --4055719 --4135752
                            <= trunc(least(p_sup_atp_info_rec.last_cap_date,l_cutoff_date)) --4135752
                            -- Exclude Cancelled Supplies 2460645
                     AND    NVL(P.DISPOSITION_STATUS_TYPE, 1) <> 2);
                     -- Supplier Capacity (SCLT) Changes End

                    -- dsting: removed 'order by col 25'
                END IF; -- IF l_check_cap_model_flag = 1 THEN

                -- for period ATP
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'after inserting into msc_atp_sd_details_temp');
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'rows processed: ' || SQL%ROWCOUNT);
                END IF;

                MSC_ATP_PROC.get_period_data_from_SD_temp(x_atp_period);

                x_atp_period.Cumulative_Quantity := x_atp_period.Period_Quantity;
                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'before atp_consume');
                END IF;
                -- do the accumulation
                -- 1487804
                -- atp_consume(x_atp_period.Cumulative_Quantity, m);
                MSC_ATP_PROC.atp_consume(x_atp_period.Cumulative_Quantity,
                    x_atp_period.Cumulative_Quantity.COUNT);

                IF PG_DEBUG in ('Y', 'C') THEN
                    msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'after atp_consume');
                END IF;

                /* Cum drop issue changes begin*/
                MSC_AATP_PROC.Atp_Remove_Negatives(x_atp_period.Cumulative_Quantity, l_return_status);
                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Error occured in procedure Atp_Remove_Negatives');
                        END IF;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                /* Cum drop issue changes end*/

                l_atp_period_tab := x_atp_period.Period_Start_Date;
                l_atp_qty_tab := x_atp_period.Cumulative_Quantity;


            END IF; -- p_sup_atp_info_rec.insert_flag <> 0

            --4055719

                l_atp_period_tab.EXTEND;
                l_atp_qty_tab.EXTEND;
                i:= l_atp_period_tab.COUNT;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_plan_start_date := ' || l_plan_start_date);
                END IF;

                -- ship_rec_cal
                l_atp_period_tab(i) := l_last_cap_next_date;
                l_atp_qty_tab(i) := MSC_ATP_PVT.INFINITE_NUMBER;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_plan_start_date1 := ' || l_plan_start_date);
                END IF;

                IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0) THEN

                   -- add one more entry to indicate infinite time fence date
                   -- and quantity.
                   MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);
                   i:= x_atp_period.level.COUNT;

                   x_atp_period.Level(i) := p_sup_atp_info_rec.level;
                   x_atp_period.Identifier(i) := p_sup_atp_info_rec.identifier;
                   x_atp_period.Scenario_Id(i) := p_sup_atp_info_rec.scenario_id;
                   x_atp_period.Pegging_Id(i) := NULL;
                   x_atp_period.End_Pegging_Id(i) := NULL;

                   x_atp_period.Supplier_Id(i) := p_sup_atp_info_rec.supplier_id;
                   x_atp_period.Supplier_Site_Id(i) := p_sup_atp_info_rec.supplier_site_id;
                   x_atp_period.Organization_id(i) := p_sup_atp_info_rec.organization_id;

                   -- ship_rec_cal
                   x_atp_period.Period_Start_Date(i) := l_last_cap_next_date;

                   x_atp_period.Total_Supply_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
                   x_atp_period.Total_Demand_Quantity(i) := 0;
                   x_atp_period.Period_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
                   x_atp_period.Cumulative_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;

                END IF;

            --=======================================================================================================
            -- ship_rec_cal changes end
            --=======================================================================================================

        ELSE --  (G_ALLOCATED_ATP = 'N')
            -- we are using allocated atp
            MSC_AATP_PVT.Supplier_Alloc_Cum_Atp(p_sup_atp_info_rec,
                               MSC_ATP_PVT.G_ORDER_LINE_ID,
                               l_requested_date,
                               l_atp_info,
                               x_atp_period,
                               x_atp_supply_demand);

            --4055719, this piece of code is moved from MSC_AATP_PVT.Supplier_Alloc_Cum_Atp to here.
            -- also l_last_cap_next_date is added instead of l_infinite_time_fence_date.
            IF l_last_cap_next_date IS NOT NULL THEN
               -- add one more entry to indicate infinite time fence date
               -- and quantity.
               l_atp_info.atp_qty.EXTEND;
               l_atp_info.atp_period.EXTEND;
               --- bug 1657855, remove support for min alloc
               l_atp_info.limit_qty.EXTEND;

               i := l_atp_info.atp_qty.COUNT;
               l_atp_info.atp_period(i) := l_last_cap_next_date;
               l_atp_info.atp_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;
               ---x_atp_info.limit_qty(i) := MSC_ATP_PVT.INFINITE_NUMBER;


              IF NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0 THEN
                 -- add one more entry to indicate infinite time fence date
                 -- and quantity.

                 x_atp_period.Cumulative_Quantity := l_atp_info.atp_qty;

                 j := x_atp_period.Level.COUNT;
                 MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, l_return_status);
                 j := j + 1;
                 IF j > 1 THEN
                    --x_atp_period.Period_End_Date(j-1) := l_infinite_time_fence_date -1; --4055719
                    x_atp_period.Period_End_Date(j-1) := l_last_cap_next_date -1;
                    x_atp_period.Identifier1(j) := x_atp_period.Identifier1(j-1);
                    x_atp_period.Identifier2(j) := x_atp_period.Identifier2(j-1);
                 END IF;

                 x_atp_period.Level(j) := p_sup_atp_info_rec.level;
                 x_atp_period.Identifier(j) := MSC_ATP_PVT.G_ORDER_LINE_ID;
                 x_atp_period.Scenario_Id(j) := p_sup_atp_info_rec.scenario_id;
                 x_atp_period.Pegging_Id(j) := NULL;
                 x_atp_period.End_Pegging_Id(j) := NULL;
                 x_atp_period.Supplier_Id(j) := p_sup_atp_info_rec.supplier_id;
                 x_atp_period.Supplier_site_id(j) := p_sup_atp_info_rec.supplier_site_id;
                 x_atp_period.Organization_id(j) := p_sup_atp_info_rec.organization_id;
                 --x_atp_period.Period_Start_Date(j) := l_infinite_time_fence_date; --4055719
                 x_atp_period.Period_Start_Date(j) := l_last_cap_next_date;
                 x_atp_period.Total_Supply_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
                 x_atp_period.Total_Demand_Quantity(j) := 0;
                 x_atp_period.Period_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
                 x_atp_period.Cumulative_Quantity(j) := MSC_ATP_PVT.INFINITE_NUMBER;
              END IF;
            END IF;

            l_atp_period_tab := l_atp_info.atp_period;
            l_atp_qty_tab := l_atp_info.atp_qty;

        END IF; -- end of G_ALLOCATED_ATP

        --4055719 , commented this piece of code because of following reasons
        -- 1. This code will lead to adding of infinite date/qty record twice
        -- 2. Seperated code is added to allocated/unallocated cases (we cannot join the
        --    code because appending of records are slightly diff in both cases.

        /* Removed redundant code as l_last_cap_date does not anyway get used after this point
           Done with Enforce Pur LT changes
        --sup_cap chnages
        --first get the next working from the last day on which capacity is defined.
        IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_last_cap_date := ' || l_last_cap_date);
        END IF;
        l_last_cap_date :=  MSC_CALENDAR.DATE_OFFSET(p_sup_atp_info_rec.organization_id,
                                                     p_sup_atp_info_rec.instance_id,
                                                     1,
                                                     l_last_cap_date,
                                                     1);
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_last_cap_date after offset := ' || l_last_cap_date);
        END IF;
        */

        -- add one more entry to indicate sysdate
        -- and infinite quantity.

        --4055719
        /*
        l_atp_period_tab.EXTEND;
        l_atp_qty_tab.EXTEND;
        i:= l_atp_period_tab.COUNT;
        IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_plan_start_date := ' || l_plan_start_date);
        END IF;

        -- ship_rec_cal
        l_atp_period_tab(i) := l_last_cap_next_date;
        l_atp_qty_tab(i) := MSC_ATP_PVT.INFINITE_NUMBER;


        IF (NVL(p_sup_atp_info_rec.insert_flag, 0) <> 0) THEN

           -- add one more entry to indicate infinite time fence date
           -- and quantity.
           MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);
           i:= x_atp_period.level.COUNT;

           x_atp_period.Level(i) := p_sup_atp_info_rec.level;
           x_atp_period.Identifier(i) := p_sup_atp_info_rec.identifier;
           x_atp_period.Scenario_Id(i) := p_sup_atp_info_rec.scenario_id;
           x_atp_period.Pegging_Id(i) := NULL;
           x_atp_period.End_Pegging_Id(i) := NULL;

           x_atp_period.Supplier_Id(i) := p_sup_atp_info_rec.supplier_id;
           x_atp_period.Supplier_Site_Id(i) := p_sup_atp_info_rec.supplier_site_id;
           x_atp_period.Organization_id(i) := p_sup_atp_info_rec.organization_id;

           -- ship_rec_cal
           x_atp_period.Period_Start_Date(i) := l_last_cap_next_date;

           x_atp_period.Total_Supply_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
           x_atp_period.Total_Demand_Quantity(i) := 0;
           x_atp_period.Period_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;
           x_atp_period.Cumulative_Quantity(i) := MSC_ATP_PVT.INFINITE_NUMBER;

        END IF; */

   END IF;  -- l_capacity_defined = 0

    i := l_atp_period_tab.COUNT;

    IF i = 0 THEN
      -- need to add error message
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'No rows in cursor!!!');
        END IF;
        RAISE NO_DATA_FOUND;
    END IF;

    FOR i in 1..l_atp_period_tab.COUNT LOOP
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'Date '||l_atp_period_tab(i)||' Qty '||
                                  l_atp_qty_tab(i));
        END IF;
    END LOOP;


    --bug 2341075: Capacity before sysdate should not be considered
    --- we find out how much is available before sydate and reduce it from cumulative qty

    -- Rewrite the l_qty_before_sysdate logic as part of ship_rec_cal changes for better performance
    IF (l_atp_period_tab(1) >= l_sysdate OR l_atp_period_tab(l_atp_period_tab.COUNT) <= l_sysdate) THEN
		l_qty_before_sysdate := 0;
    ELSE
		FOR i in 1..l_atp_period_tab.COUNT LOOP
			-- For loop will never reach COUNT as that case has already been handled above.
			IF (l_atp_period_tab(i) <  l_sysdate AND l_atp_period_tab(i+1) >= l_sysdate) THEN
				l_qty_before_sysdate := l_atp_qty_tab(i);
				EXIT;
			END IF;
		END LOOP;
    END IF;
    l_qty_before_sysdate := GREATEST(l_qty_before_sysdate, 0);

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_qty_before_sysdate := ' || l_qty_before_sysdate);
    END IF;


	-- we use this l_atp_requested_date to do the search
    l_atp_requested_date := GREATEST(l_requested_date, l_sysdate); -- Change for ship_rec_cal

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'l_atp_requested_date := ' || l_atp_requested_date);
    END IF;

    IF (l_atp_requested_date < l_atp_period_tab(1)) THEN
            -- let say the first period is on Day5 but your
            -- request in on Day2.  for bug 948863
            p_sup_atp_info_rec.requested_date_quantity := 0;
            FOR k IN 1..l_atp_period_tab.COUNT LOOP
                IF (l_atp_qty_tab(k) >= p_sup_atp_info_rec.quantity_ordered)
                    AND l_atp_period_tab(k) >= MSC_ATP_PVT.G_PTF_DATE THEN      -- Bug 3782472 - Added PTF check
                    p_sup_atp_info_rec.atp_date_quantity_this_level := l_atp_qty_tab(k);
                    p_sup_atp_info_rec.atp_date_this_level := l_atp_period_tab(k);
                    EXIT;
                ELSIF (l_atp_qty_tab(k) >= p_sup_atp_info_rec.quantity_ordered)
                    AND (l_atp_period_tab.COUNT = k
                        -- Bug 3862224, handled the case where ptf_date has some supply/demand activity, removed equality check.
                        --OR l_atp_period_tab(k+1) >= MSC_ATP_PVT.G_PTF_DATE) THEN      -- Bug 3782472 - Added PTF check
                        OR l_atp_period_tab(k+1) > MSC_ATP_PVT.G_PTF_DATE) THEN  -- Bug 3782472 - Added PTF check
                    p_sup_atp_info_rec.atp_date_quantity_this_level := l_atp_qty_tab(k);
                    p_sup_atp_info_rec.atp_date_this_level := MSC_ATP_PVT.G_PTF_DATE;
                    EXIT;
                END IF;
            END LOOP; -- end of k loop
    ELSE


        FOR j IN 1..l_atp_period_tab.COUNT LOOP

            -- Please state reason for the else condition here
            -- the reason that we need this else condition is the following
            -- let say the last record in the bucket is Day5, and request
            -- date is Day10.  So the bucket that the the request date is
            -- falling into is Day5. So we should use Day5's quantity
            -- as the quantity for Day10. By setting l_next_period this way,
            -- we make sure we are using the right bucket to get
            -- request date quantuty.

            IF j < l_atp_period_tab.LAST THEN
                l_next_period := l_atp_period_tab(j+1);
            ELSE
                l_next_period := l_atp_requested_date + 1;
            END IF;

            IF ((l_atp_period_tab(j) <= l_atp_requested_date) and
                        (l_next_period > l_atp_requested_date)) THEN

                IF (l_pre_process_date IS NOT NULL and l_pre_process_date < l_sysdate)
                   or (l_pre_process_date IS NULL and
                       l_requested_date < l_atp_requested_date) THEN
                       -- Bug 3828469 - Removed the regression introduced in 3782472
                       -- l_requested_date < GREATEST(MSC_ATP_PVT.G_PTF_DATE,l_atp_requested_date)) THEN -- Bug 3782472 - Added PTF check
                    p_sup_atp_info_rec.requested_date_quantity := 0;

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'inside p_sup_atp_info_rec.requested_date_quantity 0 = '||
                      p_sup_atp_info_rec.requested_date_quantity);
                    END IF;
                ELSE
                    ---bug 2341075: availability should not include what is available before sysdate
                    p_sup_atp_info_rec.requested_date_quantity := l_atp_qty_tab(j) - l_qty_before_sysdate;
                END IF;


                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'p_sup_atp_info_rec.requested_date_quantity: '|| to_char(p_sup_atp_info_rec.requested_date_quantity));
                END IF;
                --  now find the atp_date_quantity and atp_date at this level
                ---bug 2341075: Cum Qty should not include cum qty before sysdate
                IF (l_atp_qty_tab(j) - l_qty_before_sysdate) >= p_sup_atp_info_rec.quantity_ordered
                    AND l_atp_requested_date >= MSC_ATP_PVT.G_PTF_DATE THEN      -- Bug 3782472 - Added PTF check

                    p_sup_atp_info_rec.atp_date_quantity_this_level := l_atp_qty_tab(j) - l_qty_before_sysdate;
                    p_sup_atp_info_rec.atp_date_this_level := l_atp_requested_date;

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'p_sup_atp_info_rec.atp_date_this_level: '|| to_char(p_sup_atp_info_rec.atp_date_this_level));
                       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'p_sup_atp_info_rec.atp_date_quantity_this_level: '|| to_char(p_sup_atp_info_rec.atp_date_quantity_this_level));
                    END IF;

                ELSE
                    IF j = l_atp_period_tab.COUNT THEN
                        p_sup_atp_info_rec.atp_date_quantity_this_level := NULL;
                        p_sup_atp_info_rec.atp_date_this_level := NULL;

                    ELSE
                        FOR k IN j+1..l_atp_period_tab.COUNT LOOP
                            ---bug 2341075: exclude qty before sysdate
                            IF ((l_atp_qty_tab(k)- l_qty_before_sysdate) >= p_sup_atp_info_rec.quantity_ordered)
                                AND l_atp_period_tab(k) >= MSC_ATP_PVT.G_PTF_DATE THEN      -- Bug 3782472 - Added PTF check
                                p_sup_atp_info_rec.atp_date_quantity_this_level := l_atp_qty_tab(k) - l_qty_before_sysdate;
                                p_sup_atp_info_rec.atp_date_this_level := l_atp_period_tab(k);
                                EXIT;
                            ELSIF ((l_atp_qty_tab(k)- l_qty_before_sysdate) >= p_sup_atp_info_rec.quantity_ordered)
                                AND (l_atp_period_tab.COUNT = k
                                        -- Bug 3862224, handled the case where ptf_date has some supply/demand activity, removed equality check
                                        --OR l_atp_period_tab(k+1) >= MSC_ATP_PVT.G_PTF_DATE) THEN
                                        OR l_atp_period_tab(k+1) > MSC_ATP_PVT.G_PTF_DATE) THEN
                                p_sup_atp_info_rec.atp_date_quantity_this_level := l_atp_qty_tab(k) - l_qty_before_sysdate;
                                p_sup_atp_info_rec.atp_date_this_level := MSC_ATP_PVT.G_PTF_DATE;
                                EXIT;
                            END IF;
                        END LOOP; -- end of k loop
                    END IF; -- end if j = l_atp_period_tab.COUNT
                END IF; -- end if  l_atp_qty_tab(j) >=p_sup_atp_info_rec.quantity_ordered
                EXIT;
            END IF; -- end if we find the bucket
        END LOOP; -- end j loop
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Supplier_Atp_Info: ' || 'in supplier, count = '||x_atp_supply_demand.supplier_id.count);
       msc_sch_wb.atp_debug('***** End Get_Supplier_Atp_Info Procedure *****');
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        p_sup_atp_info_rec.requested_date_quantity := 0.0;
        x_return_status := FND_API.G_RET_STS_ERROR;
END Get_Supplier_Atp_Info;


PROCEDURE Get_Transport_Cap_Atp_Info (
  p_plan_id				IN    NUMBER,
  p_from_organization_id                IN    NUMBER,
  p_to_organization_id                  IN    NUMBER,
  p_ship_method                         IN    VARCHAR2,
  p_inventory_item_id                   IN    NUMBER,
  p_source_org_instance_id		IN    NUMBER,
  p_dest_org_instance_id		IN    NUMBER,
  p_requested_date                      IN    DATE,
  p_quantity_ordered                    IN    NUMBER,
  p_insert_flag                         IN    NUMBER,
  p_level				IN    NUMBER,
  p_scenario_id				IN    NUMBER,
  p_identifier				IN    NUMBER,
  p_parent_pegging_id			IN    NUMBER,
  x_requested_date_quantity             OUT   NoCopy NUMBER,
  x_atp_date_this_level                 OUT   NoCopy DATE,
  x_atp_date_quantity_this_level        OUT   NoCopy NUMBER,
  x_atp_period                          OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT   NoCopy VARCHAR2
)
IS

i                               PLS_INTEGER := 1;
l_requested_date                DATE;
l_unit_weight			NUMBER;
l_unit_volume			NUMBER;
l_available_quantity		NUMBER;
l_atp_period_tab                MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr();
l_atp_qty_tab                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atp_qty_tab2                  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_atp_period                    MRP_ATP_PUB.ATP_Period_Typ;
l_atp_period2                    MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand		MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_supply_demand2             MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_null_atp_period		MRP_ATP_PUB.ATP_Period_Typ;
l_null_atp_supply_demand	MRP_ATP_PUB.ATP_Supply_Demand_Typ;
m				NUMBER;
k				NUMBER;
l_item_weight_qty		NUMBER;
l_item_volume_qty		NUMBER;
l_atp_date_weight		NUMBER;
l_atp_date_volume		NUMBER;
l_pegging_rec                   mrp_atp_details_temp%ROWTYPE;
l_pegging_id			NUMBER;
l_vol_demand_pegging_id	        NUMBER;
l_wt_demand_pegging_id 		NUMBER;
--INFINITE_NUMBER                 CONSTANT NUMBER := 1.0e+10;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'inside get_TRANSPORT_info ');
  END IF;

  l_null_atp_period := x_atp_period;
  l_null_atp_supply_demand := x_atp_supply_demand;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'p_insert_flag = '||p_insert_flag);
  END IF;

  -- initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_requested_date := trunc(p_requested_date);

  -- Initialize the record with null

  l_atp_period := l_null_atp_period;
  l_atp_supply_demand := l_null_atp_supply_demand;
  l_atp_period2 := l_null_atp_period;
  l_atp_supply_demand2 := l_null_atp_supply_demand;

  -- Planning will be populating the 'weight_capacitiy_used' and
  -- 'volume_capacity_used' fields in msc_supplies. For now, we need
  -- to multiply the quantitiy by the unit volume and unit capacity
  -- to obtain capacity used.

  SELECT NVL(unit_weight,1), NVL(unit_volume,1)
  INTO   l_unit_weight, l_unit_volume
  FROM   msc_system_items
  WHERE  plan_id = p_plan_id
  AND    organization_id = p_to_organization_id
  AND    inventory_item_id = p_inventory_item_id
  AND    sr_instance_id = p_dest_org_instance_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'the unit weight is: '||to_char(l_unit_weight));
     msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'the unit volume is: '||to_char(l_unit_volume));
  END IF;

  SELECT  l_date, SUM(weight), SUM(volume)
  BULK COLLECT INTO
      l_atp_period_tab,
      l_atp_qty_tab,
      l_atp_qty_tab2
  FROM (
    SELECT c.calendar_date l_date,
             s.weight_capacity weight,
	     s.volume_capacity volume
      FROM   msc_calendar_dates c,
             msc_interorg_ship_methods s,
             msc_trading_partners tp,
	     msc_plans p
      WHERE  s.plan_id = p_plan_id
      AND    s.from_organization_id = p_from_organization_id
      AND    s.to_organization_id = p_to_organization_id
      AND    s.ship_method = p_ship_method
      AND    s.sr_instance_id = p_source_org_instance_id
      AND    s.sr_instance_id2 = p_dest_org_instance_id
      AND    s.from_organization_id = tp.sr_tp_id
      AND    tp.sr_instance_id = NVL(s.sr_instance_id, s.sr_instance_id2)
      AND    c.calendar_date BETWEEN trunc(SYSDATE) and trunc(p.curr_cutoff_date)   -- to_date changed to trunc to avoid GSCC error
      AND    c.calendar_code = tp.calendar_code
      AND    c.exception_set_id = tp.calendar_exception_set_id
      AND    p.plan_id = p_plan_id
      UNION ALL
      SELECT sup.new_schedule_date l_date,
             -1*(sup.new_order_quantity)*l_unit_weight weight,
	     -1*(sup.new_order_quantity)*l_unit_volume  volume
      FROM   msc_supplies sup
      WHERE  sup.plan_id = p_plan_id
      AND    sup.organization_id = p_to_organization_id
      AND    sup.sr_instance_id = p_dest_org_instance_id
      AND    sup.source_organization_id is not null
      AND    sup.source_organization_id = p_from_organization_id
      AND    sup.source_sr_instance_id = p_source_org_instance_id
      AND    sup.ship_method = p_ship_method
      AND    sup.inventory_item_id = p_inventory_item_id
      AND    sup.transaction_id <>     (SELECT identifier3
					FROM   mrp_atp_details_temp
					WHERE  record_type = 3
					AND    pegging_id = p_parent_pegging_id
                                        AND    session_id = MSC_ATP_PVT.G_SESSION_ID
				       ))
      GROUP BY l_date
      ORDER BY l_date;

      i := l_atp_period_tab.COUNT;

      IF i = 0 THEN
        -- need to add error message
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'No rows in cursor!!!');
        END IF;
        RAISE NO_DATA_FOUND;
      END IF;

      -- do accumulation for transportation capacity
      MSC_ATP_PROC.atp_consume(l_atp_qty_tab, i);
      MSC_ATP_PROC.atp_consume(l_atp_qty_tab2, i);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'just before printing values');
      END IF;

    FOR k IN 1..i LOOP
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'date is: '||to_char(l_atp_period_tab(k)));
         msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'weight is: '||to_char(l_atp_qty_tab(k)));
         msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'volume is: '||to_char(l_atp_qty_tab2(k)));
      END IF;

    END LOOP;

    -- find the requested date atp quantity

    FOR j IN 1..i LOOP

        IF ((l_atp_period_tab(j) <= l_requested_date) and
            (l_atp_period_tab(j+1) > l_requested_date)) THEN

            -- Convert volume and weight capacity to units

            l_item_weight_qty := l_atp_qty_tab(j)/l_unit_weight;
            l_item_volume_qty := l_atp_qty_tab2(j)/l_unit_volume;

            -- Find out volume or weight capacity is constraining to
            -- determine quantity for request date

            IF l_item_volume_qty > l_item_weight_qty THEN
              x_requested_date_quantity := l_item_weight_qty;
            ELSE
              x_requested_date_quantity := l_item_volume_qty;
            END IF;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'the date is: '||to_char(l_atp_period_tab(j)));
               msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'the quantity is: '||to_char(x_requested_date_quantity));
            END IF;

            --  now find the atp_date_quantity and atp_date at this level
            IF x_requested_date_quantity >= p_quantity_ordered THEN
                x_atp_date_quantity_this_level := x_requested_date_quantity;
                x_atp_date_this_level := p_requested_date;
		l_atp_date_weight := l_atp_qty_tab(j);
		l_atp_date_volume := l_atp_qty_tab2(j);

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'quantity is enough.');
                END IF;

   		k := j;
            ELSE

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'quantity is not enough.');
                END IF;

                FOR k IN j+1..i LOOP
		  -- Convert volume and weight capacity in units

                  l_item_weight_qty := l_atp_qty_tab(k)/l_unit_weight;
                  l_item_volume_qty := l_atp_qty_tab2(k)/l_unit_volume;

                    IF l_item_volume_qty > l_item_weight_qty THEN
                      l_available_quantity := l_item_weight_qty;
                    ELSE
                      l_available_quantity := l_item_volume_qty;
                    END IF;

                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'Date is: '||to_char(l_atp_period_tab(k)));
                       msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'Quantity available is: '||to_char(l_available_quantity));
                    END IF;

                    IF (l_available_quantity >= p_quantity_ordered) THEN
                        x_atp_date_quantity_this_level := l_available_quantity;
                        x_atp_date_this_level := l_atp_period_tab(k);

			l_atp_date_weight := l_atp_qty_tab(k);
	                l_atp_date_volume := l_atp_qty_tab2(k);

                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'done');
                           msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'quantity: '||to_char(x_atp_date_quantity_this_level));
                           msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'date: '||to_char(x_atp_date_this_level));
                        END IF;
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END LOOP;

    IF NVL(p_insert_flag,0) <> 0 THEN -- p_insert_flag
      -- add pegging info for weight demand

    l_pegging_rec.session_id := MSC_ATP_PVT.G_SESSION_ID;
    l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
    l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
    l_pegging_rec.atp_level:= p_level;
    l_pegging_rec.from_organization_id := p_from_organization_id;
    l_pegging_rec.to_organization_id := p_to_organization_id;
    l_pegging_rec.ship_method := p_ship_method;
    l_pegging_rec.identifier1 := p_source_org_instance_id;
    l_pegging_rec.identifier2 := 'WEIGHT';
--    l_pegging_rec.identifier3 := l_transaction_id;
    l_pegging_rec.identifier4 := p_dest_org_instance_id;
    l_pegging_rec.scenario_id:= p_scenario_id;
    l_pegging_rec.supply_demand_source_type:= 1;
    l_pegging_rec.supply_demand_quantity := p_quantity_ordered*l_unit_weight;
    l_pegging_rec.weight_capacity := p_quantity_ordered*l_unit_weight;
    l_pegging_rec.supply_demand_type:= 1;
    l_pegging_rec.supply_demand_date:= l_requested_date;
    l_pegging_rec.department_id := NULL;
    l_pegging_rec.department_code := NULL;
    l_pegging_rec.resource_id := NULL;
    l_pegging_rec.resource_code := NULL;
    l_pegging_rec.inventory_item_id := NULL;
    l_pegging_rec.inventory_item_name := NULL;
    l_pegging_rec.supplier_id := NULL;
    l_pegging_rec.supplier_name := NULL;
    l_pegging_rec.supplier_site_id := NULL;
    l_pegging_rec.supplier_site_name := NULL;


    MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

    l_wt_demand_pegging_id := l_pegging_id;

    -- add pegging info for volume demand

    l_pegging_rec.session_id := MSC_ATP_PVT.G_SESSION_ID;
    l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
    l_pegging_rec.parent_pegging_id:= p_parent_pegging_id;
    l_pegging_rec.atp_level:= p_level;
    l_pegging_rec.from_organization_id := p_from_organization_id;
    l_pegging_rec.to_organization_id := p_to_organization_id;
    l_pegging_rec.ship_method := p_ship_method;
    l_pegging_rec.identifier1 := p_source_org_instance_id;
    l_pegging_rec.identifier2 := 'VOLUME';
--    l_pegging_rec.identifier3 := l_transaction_id;
    l_pegging_rec.identifier4 := p_dest_org_instance_id;
    l_pegging_rec.scenario_id:= p_scenario_id;
    l_pegging_rec.supply_demand_source_type:= 1;
    l_pegging_rec.supply_demand_quantity := p_quantity_ordered*l_unit_volume;
    l_pegging_rec.volume_capacity := p_quantity_ordered*l_unit_volume;
    l_pegging_rec.supply_demand_type:= 1;
    l_pegging_rec.supply_demand_date:= l_requested_date;
    l_pegging_rec.department_id := NULL;
    l_pegging_rec.department_code := NULL;
    l_pegging_rec.resource_id := NULL;
    l_pegging_rec.resource_code := NULL;
    l_pegging_rec.inventory_item_id := NULL;
    l_pegging_rec.inventory_item_name := NULL;
    l_pegging_rec.supplier_id := NULL;
    l_pegging_rec.supplier_name := NULL;
    l_pegging_rec.supplier_site_id := NULL;
    l_pegging_rec.supplier_site_name := NULL;

    MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

    l_vol_demand_pegging_id := l_pegging_id;

    -- add pegging info for weight supply

    l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
    l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
    l_pegging_rec.parent_pegging_id:= l_wt_demand_pegging_id;
    l_pegging_rec.atp_level:= p_level;
    l_pegging_rec.from_organization_id := p_from_organization_id;
    l_pegging_rec.to_organization_id := p_to_organization_id;
    l_pegging_rec.ship_method := p_ship_method;
    l_pegging_rec.identifier1 := p_source_org_instance_id;
    l_pegging_rec.identifier2 := 'WEIGHT';
    l_pegging_rec.identifier3 := -1;
    l_pegging_rec.identifier4 := p_dest_org_instance_id;
    l_pegging_rec.scenario_id := p_scenario_id;
    l_pegging_rec.supply_demand_source_type := MSC_ATP_PVT.ATP;
    l_pegging_rec.supply_demand_quantity := l_atp_qty_tab(k);
    l_pegging_rec.weight_capacity := l_atp_qty_tab(k);
    l_pegging_rec.supply_demand_type := 2;
    l_pegging_rec.supply_demand_date := x_atp_date_this_level;
    l_pegging_rec.department_id := NULL;
    l_pegging_rec.department_code := NULL;
    l_pegging_rec.resource_id := NULL;
    l_pegging_rec.resource_code := NULL;
    l_pegging_rec.inventory_item_id := NULL;
    l_pegging_rec.inventory_item_name := NULL;
    l_pegging_rec.supplier_id := NULL;
    l_pegging_rec.supplier_name := NULL;
    l_pegging_rec.supplier_site_id := NULL;
    l_pegging_rec.supplier_site_name := NULL;
    l_pegging_rec.source_type := 0;

    MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

    -- add pegging info for volume supply

    l_pegging_rec.session_id := MSC_ATP_PVT.G_SESSION_ID;
    l_pegging_rec.order_line_id := MSC_ATP_PVT.G_ORDER_LINE_ID;
    l_pegging_rec.parent_pegging_id := l_vol_demand_pegging_id;
    l_pegging_rec.atp_level := p_level;
    l_pegging_rec.from_organization_id := p_from_organization_id;
    l_pegging_rec.to_organization_id := p_to_organization_id;
    l_pegging_rec.ship_method := p_ship_method;
    l_pegging_rec.identifier1 := p_source_org_instance_id;
    l_pegging_rec.identifier2 := 'VOLUME';
    l_pegging_rec.identifier3 := -1;
    l_pegging_rec.identifier4 := p_dest_org_instance_id;
    l_pegging_rec.scenario_id := p_scenario_id;
    l_pegging_rec.supply_demand_source_type := MSC_ATP_PVT.ATP;
    l_pegging_rec.supply_demand_quantity := l_atp_qty_tab2(k);
    l_pegging_rec.volume_capacity := l_atp_qty_tab2(k);
    l_pegging_rec.supply_demand_type := 2;
    l_pegging_rec.supply_demand_date := x_atp_date_this_level;
    l_pegging_rec.department_id := NULL;
    l_pegging_rec.department_code := NULL;
    l_pegging_rec.resource_id := NULL;
    l_pegging_rec.resource_code := NULL;
    l_pegging_rec.inventory_item_id := NULL;
    l_pegging_rec.inventory_item_name := NULL;
    l_pegging_rec.supplier_id := NULL;
    l_pegging_rec.supplier_name := NULL;
    l_pegging_rec.supplier_site_id := NULL;
    l_pegging_rec.supplier_site_name := NULL;

    l_pegging_rec.source_type := 0;

    MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);

    FOR i in 1..l_atp_period.Level.COUNT LOOP
            l_atp_period.Pegging_Id(i) := l_pegging_id;
            l_atp_period.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;

	    l_atp_period2.Pegging_Id(i) := l_pegging_id;
            l_atp_period2.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;

    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Get_Transport_Cap_Atp_Info: ' || 'in get_res_requirements we are here 2');
    END IF;

    FOR i in 1..l_atp_supply_demand.Level.COUNT LOOP
            l_atp_supply_demand.Pegging_Id(i) := l_pegging_id;
            l_atp_supply_demand.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;

            l_atp_supply_demand2.Pegging_Id(i) := l_pegging_id;
            l_atp_supply_demand2.End_Pegging_Id(i) := MSC_ATP_PVT.G_DEMAND_PEGGING_ID;

    END LOOP;

    -- select weight information into table

    SELECT
    col1,
    col2,
    col3,
    col4,
    col5,
    col6,
    col7,
    col8,
    col9,
    col10,
    col11,
    col12,
    col13,
    col14,
    col15,
    col16,
    col17,
    col18,
    col19,
    col20,
    col21,
    col22,
    col23,
    col24,
    col25,
    col26,
    col27,
    col28,
    col29
    BULK COLLECT INTO
		     l_atp_supply_demand.Level,
                     l_atp_supply_demand.Identifier,
                     l_atp_supply_demand.Inventory_Item_Id,
                     l_atp_supply_demand.Request_Item_Id,
                     l_atp_supply_demand.Organization_Id,
                     l_atp_supply_demand.Department_Id,
                     l_atp_supply_demand.Resource_Id,
                     l_atp_supply_demand.Supplier_Id,
                     l_atp_supply_demand.Supplier_Site_Id,
                     l_atp_supply_demand.From_Organization_Id,
                     l_atp_supply_demand.From_Location_Id,
                     l_atp_supply_demand.To_Organization_Id,
                     l_atp_supply_demand.To_Location_Id,
                     l_atp_supply_demand.Ship_Method,
                     l_atp_supply_demand.Uom,
                     l_atp_supply_demand.Supply_Demand_Type,
                     l_atp_supply_demand.Supply_Demand_Source_Type,
                     l_atp_supply_demand.Supply_Demand_Source_Type_Name,
                     l_atp_supply_demand.Identifier1,
                     l_atp_supply_demand.Identifier2,
                     l_atp_supply_demand.Identifier3,
                     l_atp_supply_demand.Identifier4,
                     l_atp_supply_demand.Supply_Demand_Quantity,
                     l_atp_supply_demand.Supply_Demand_Date,
                     l_atp_supply_demand.Disposition_Type,
                     l_atp_supply_demand.Disposition_Name,
		     l_atp_supply_demand.Scenario_Id,
                     l_atp_supply_demand.Pegging_Id,
                     l_atp_supply_demand.End_Pegging_Id
    FROM
    (
    SELECT
	     p_level col1,
	     p_identifier col2,
	     p_inventory_item_id col3,
	     null col4, -- request_item_id
	     null col5, -- organization_id
	     null col6, -- department_id
	     null col7, -- resource_id
	     null col8, -- supplier_id
	     null col9, -- supplier_site_id
	     p_from_organization_id col10,
	     null col11, -- from_location_id
	     p_to_organization_id col12,
	     null col13, -- to_location_id
	     p_ship_method col14,
	     s.weight_uom col15, -- uom
	     2 col16, -- supply
	     null col17, -- supply_demand_source_type
	     null col18, -- supply_demand_source_type_name
	     p_source_org_instance_id col19, -- identifier1
             1 col20, -- identifier2, weight(1) or volume(2)
             null col21, -- identifier3
             p_dest_org_instance_id col22, -- identifier4
	     s.weight_capacity col23,
	     c.calendar_date col24,
	     null col25, -- disposition_type
	     null col26, -- disposition_name
	     p_scenario_id col27, -- scenario_id
       	     null col28, -- pegging_id
	     null col29  -- end_pegging_id
    FROM
	     msc_calendar_dates c,
             msc_interorg_ship_methods s,
             msc_trading_partners tp,
             msc_plans p
    WHERE
 	     s.plan_id = p_plan_id
      AND    s.from_organization_id = p_from_organization_id
      AND    s.to_organization_id = p_to_organization_id
      AND    s.ship_method = p_ship_method
      AND    s.sr_instance_id = p_source_org_instance_id
      AND    s.sr_instance_id2 = p_dest_org_instance_id
      AND    s.from_organization_id = tp.sr_tp_id
      AND    tp.sr_instance_id = NVL(s.sr_instance_id, s.sr_instance_id2)
      AND    c.calendar_date BETWEEN trunc(SYSDATE) and trunc(p.curr_cutoff_date)    -- to_date changed to trunc to avoid GSCC error
      AND    c.calendar_code = tp.calendar_code
      AND    c.exception_set_id = tp.calendar_exception_set_id
      AND    p.plan_id = p_plan_id
      UNION ALL
      SELECT p_level col1,
             p_identifier col2,
             p_inventory_item_id col3,
             null col4, -- request_item_id
             null col5, -- organization_id
             null col6, -- department_id
             null col7, -- resource_id
             null col8, -- supplier_id
             null col9, -- supplier_site_id
             p_from_organization_id col10,
             null col11, -- from_location_id
             p_to_organization_id col12,
             null col13, -- to_location_id
             p_ship_method col14,
             s.weight_uom col15, -- uom
	     1 col16, -- demand
	     null col17, -- supply_demand_source_type
             null col18, -- supply_demand_source_type_name
	     p_source_org_instance_id col19, -- identifier1
             1 col20, -- identifier2, weight(1) or volume(2)
             null col21, -- identifier3
             p_dest_org_instance_id col22, -- identifier4
	     -1*(sup.new_order_quantity)*l_unit_weight col23,
	     sup.new_schedule_date col24,
             null col25, -- disposition_type
             null col26, -- disposition_name
             p_scenario_id col27, -- scenairo_id
             null col28, -- pegging_id
             null col29  -- end_pegging_id
      FROM   msc_supplies sup,
	     msc_interorg_ship_methods s
      WHERE  sup.plan_id = p_plan_id
      AND    sup.organization_id = p_to_organization_id
      AND    sup.sr_instance_id = p_dest_org_instance_id
      AND    sup.source_organization_id is not null
      AND    sup.source_organization_id = p_from_organization_id
      AND    sup.source_sr_instance_id = p_source_org_instance_id
      AND    sup.ship_method = p_ship_method
      AND    sup.inventory_item_id = p_inventory_item_id
      AND    s.plan_id = p_plan_id
      AND    s.from_organization_id = p_from_organization_id
      AND    s.to_organization_id = p_to_organization_id
      AND    s.ship_method = p_ship_method
      AND    s.sr_instance_id = p_source_org_instance_id
      AND    s.sr_instance_id2 = p_dest_org_instance_id
      )
      ORDER BY col25;

  -- select volume information into table
    SELECT
    col1,
    col2,
    col3,
    col4,
    col5,
    col6,
    col7,
    col8,
    col9,
    col10,
    col11,
    col12,
    col13,
    col14,
    col15,
    col16,
    col17,
    col18,
    col19,
    col20,
    col21,
    col22,
    col23,
    col24,
    col25,
    col26,
    col27,
    col28,
    col29
    BULK COLLECT INTO
		     l_atp_supply_demand2.Level,
                     l_atp_supply_demand2.Identifier,
                     l_atp_supply_demand2.Inventory_Item_Id,
                     l_atp_supply_demand2.Request_Item_Id,
                     l_atp_supply_demand2.Organization_Id,
                     l_atp_supply_demand2.Department_Id,
                     l_atp_supply_demand2.Resource_Id,
                     l_atp_supply_demand2.Supplier_Id,
                     l_atp_supply_demand2.Supplier_Site_Id,
                     l_atp_supply_demand2.From_Organization_Id,
                     l_atp_supply_demand2.From_Location_Id,
                     l_atp_supply_demand2.To_Organization_Id,
                     l_atp_supply_demand2.To_Location_Id,
                     l_atp_supply_demand2.Ship_Method,
                     l_atp_supply_demand2.Uom,
                     l_atp_supply_demand2.Supply_Demand_Type,
                     l_atp_supply_demand2.Supply_Demand_Source_Type,
                     l_atp_supply_demand2.Supply_Demand_Source_Type_Name,
                     l_atp_supply_demand2.Identifier1,
                     l_atp_supply_demand2.Identifier2,
                     l_atp_supply_demand2.Identifier3,
                     l_atp_supply_demand2.Identifier4,
                     l_atp_supply_demand2.Supply_Demand_Quantity,
                     l_atp_supply_demand2.Supply_Demand_Date,
                     l_atp_supply_demand2.Disposition_Type,
                     l_atp_supply_demand2.Disposition_Name,
		     l_atp_supply_demand2.Scenario_Id,
                     l_atp_supply_demand2.Pegging_Id,
                     l_atp_supply_demand2.End_Pegging_Id
    FROM
    (
    SELECT
	     p_level col1,
	     p_identifier col2,
	     p_inventory_item_id col3,
	     null col4, -- request_item_id
	     null col5, -- organization_id
	     null col6, -- department_id
	     null col7, -- resource_id
	     null col8, -- supplier_id
	     null col9, -- supplier_site_id
	     p_from_organization_id col10,
	     null col11, -- from_location_id
	     p_to_organization_id col12,
	     null col13, -- to_location_id
	     p_ship_method col14,
	     s.volume_uom col15, -- uom
	     2 col16, -- supply
	     null col17, -- supply_demand_source_type
             null col18, -- supply_demand_source_type_name
	     p_source_org_instance_id col19, -- identifier1
             2 col20, -- identifier2, weight(1) or volume(2)
             null col21, -- identifier3
             p_dest_org_instance_id col22, -- identifier4
	     s.volume_capacity col23,
	     c.calendar_date col24,
	     null col25, -- disposition_type
	     null col26, -- disposition_name
	     p_scenario_id col27, -- scenairo_id
       	     null col28, -- pegging_id
	     null col29  -- end_pegging_id
    FROM
	     msc_calendar_dates c,
             msc_interorg_ship_methods s,
             msc_trading_partners tp,
             msc_plans p
    WHERE
 	     s.plan_id = p_plan_id
      AND    s.from_organization_id = p_from_organization_id
      AND    s.to_organization_id = p_to_organization_id
      AND    s.ship_method = p_ship_method
      AND    s.sr_instance_id = p_source_org_instance_id
      AND    s.sr_instance_id2 = p_dest_org_instance_id
      AND    s.from_organization_id = tp.sr_tp_id
      AND    tp.sr_instance_id = NVL(s.sr_instance_id, s.sr_instance_id2)
      AND    c.calendar_date BETWEEN trunc(SYSDATE) and trunc(p.curr_cutoff_date)   -- to_date changed to trunc to avoid GSCC error
      AND    c.calendar_code = tp.calendar_code
      AND    c.exception_set_id = tp.calendar_exception_set_id
      AND    p.plan_id = p_plan_id
      UNION ALL
      SELECT p_level col1,
             p_identifier col2,
             p_inventory_item_id col3,
             null col4, -- request_item_id
             null col5, -- organization_id
             null col6, -- department_id
             null col7, -- resource_id
             null col8, -- supplier_id
             null col9, -- supplier_site_id
             p_from_organization_id col10,
             null col11, -- from_location_id
             p_to_organization_id col12,
             null col13, -- to_location_id
             p_ship_method col14,
             s.volume_uom col15, -- uom
	     1 col16, -- demand
	     null col17, -- supply_demand_source_type
             null col18, -- supply_demand_source_type_name
	     p_source_org_instance_id col19, -- identifier1
             2 col20, -- identifier2, weight(1) or volume(2)
             null col21, -- identifier3
             p_dest_org_instance_id col22, -- identifier4
	     -1*(sup.new_order_quantity)*l_unit_volume col23,
	     sup.new_schedule_date col24,
             null col25, -- disposition_type
             null col26, -- disposition_name
             p_scenario_id col27, -- scenairo_id
             null col28, -- pegging_id
             null col29  -- end_pegging_id
      FROM   msc_supplies sup,
	     msc_interorg_ship_methods s
      WHERE  sup.plan_id = p_plan_id
      AND    sup.organization_id = p_to_organization_id
      AND    sup.sr_instance_id = p_dest_org_instance_id
      AND    sup.source_organization_id is not null
      AND    sup.source_organization_id = p_from_organization_id
      AND    sup.source_sr_instance_id = p_source_org_instance_id
      AND    sup.ship_method = p_ship_method
      AND    sup.inventory_item_id = p_inventory_item_id
      AND    s.plan_id = p_plan_id
      AND    s.from_organization_id = p_from_organization_id
      AND    s.to_organization_id = p_to_organization_id
      AND    s.ship_method = p_ship_method
      AND    s.sr_instance_id = p_source_org_instance_id
      AND    s.sr_instance_id2 = p_dest_org_instance_id
      )
      ORDER BY col25;

      m := 1;

      IF l_atp_supply_demand.Supply_Demand_Date.COUNT > 0 THEN
        MSC_SATP_FUNC.Extend_Atp_Period(l_atp_period, x_return_status);

   	FOR i IN 1..l_atp_supply_demand.Supply_Demand_Date.COUNT LOOP
     	  l_atp_period.Level(m) := l_atp_supply_demand.Level(i);
          l_atp_period.Identifier(m) := l_atp_supply_demand.Identifier(i);
          l_atp_period.Scenario_Id(m) := l_atp_supply_demand.Scenario_Id(i);
	  l_atp_period.From_Organization_Id := l_atp_supply_demand.From_Organization_Id;
	  l_atp_period.To_Organization_Id := l_atp_supply_demand.To_Organization_Id;
	  l_atp_period.Ship_Method := l_atp_supply_demand.Ship_Method;
	  l_atp_period.Uom := l_atp_supply_demand.Uom;

	  IF i = 1 THEN
	    l_atp_period.Period_Start_Date(m) := l_atp_supply_demand.Supply_Demand_Date(i);

  	    l_atp_period.Identifier1(m) := l_atp_supply_demand.Identifier1(i);
            l_atp_period.Identifier2(m) := l_atp_supply_demand.Identifier2(i);

	    -- working on first supply demand record
            IF l_atp_supply_demand.Supply_Demand_Type(i) = 1 THEN
              l_atp_period.Total_Demand_Quantity(m) :=
                   l_atp_supply_demand.Supply_Demand_Quantity(i);
              l_atp_period.Total_Supply_Quantity(m) := 0;
              l_atp_period.Period_Quantity(m) :=
                   l_atp_period.Total_Supply_Quantity(m)+
                   l_atp_period.Total_Demand_Quantity(m);

	    ELSE
               l_atp_period.Total_Supply_Quantity(m) :=
                   l_atp_supply_demand.Supply_Demand_Quantity(i);
               l_atp_period.Total_Demand_Quantity(m) := 0;
               l_atp_period.Period_Quantity(m) :=
                   l_atp_period.Total_Supply_Quantity(m)+
                   l_atp_period.Total_Demand_Quantity(m);
            END IF;

	  ELSE
            -- working on 2nd record or later
            -- make sure the supply demand date of this record is
            -- greater than the previous bucket or not.
            IF l_atp_supply_demand.Supply_Demand_Date(i) >
               l_atp_period.Period_Start_Date(m) THEN

	       -- populate the period_end_date and
               -- period_atp information.
               l_atp_period.Period_End_Date(m) :=
                   l_atp_supply_demand.Supply_Demand_Date(i) -1;

               -- add one more bucket
               m:=m+1;

               MSC_SATP_FUNC.Extend_Atp_Period(l_atp_period, x_return_status);

	       l_atp_period.Level(m) := l_atp_supply_demand.Level(i);
               l_atp_period.Identifier(m) := l_atp_supply_demand.Identifier(i);
               l_atp_period.Scenario_Id(m) := l_atp_supply_demand.Scenario_Id(i);
               l_atp_period.From_Organization_Id := l_atp_supply_demand.From_Organization_Id;
               l_atp_period.To_Organization_Id := l_atp_supply_demand.To_Organization_Id;
               l_atp_period.Ship_Method := l_atp_supply_demand.Ship_Method;
               l_atp_period.Uom := l_atp_supply_demand.Uom;

               l_atp_period.Period_Start_Date(m) :=
                   l_atp_supply_demand.Supply_Demand_Date(i);

               l_atp_period.Identifier1(m):=l_atp_supply_demand.Identifier1(i);
               l_atp_period.Identifier2(m):=l_atp_supply_demand.Identifier2(i);

	       IF l_atp_supply_demand.Supply_Demand_Type(i) = 1 THEN
                   l_atp_period.Total_Demand_Quantity(m) :=
                   l_atp_supply_demand.Supply_Demand_Quantity(i);
                   l_atp_period.Total_Supply_Quantity(m) := 0;
                   l_atp_period.Period_Quantity(m) :=
                   l_atp_period.Total_Supply_Quantity(m)+
                   l_atp_period.Total_Demand_Quantity(m);

               ELSE
                   l_atp_period.Total_Supply_Quantity(m) :=
                   l_atp_supply_demand.Supply_Demand_Quantity(m);
                   l_atp_period.Total_Demand_Quantity(m) := 0;
                   l_atp_period.Period_Quantity(m) :=
                   l_atp_period.Total_Supply_Quantity(m)+
                   l_atp_period.Total_Demand_Quantity(m);

               END IF;

	    ELSE
	       -- same bucket
               IF l_atp_supply_demand.Supply_Demand_Type(i) = 1 THEN
                   l_atp_period.Total_Demand_Quantity(m) :=
                   l_atp_period.Total_Demand_Quantity(m) +
                   l_atp_supply_demand.Supply_Demand_Quantity(i);
               ELSE
                   l_atp_period.Total_Supply_Quantity(m) :=
                   l_atp_period.Total_Supply_Quantity(m)+
                   l_atp_supply_demand.Supply_Demand_Quantity(i);
               END IF;
               l_atp_period.Period_Quantity(m) :=
               l_atp_period.Total_Supply_Quantity(m)+
               l_atp_period.Total_Demand_Quantity(m);

           END IF;
 	END IF; -- end 2nd record or later
      END LOOP;
    END IF;

    m := 1;

      IF l_atp_supply_demand2.Supply_Demand_Date.COUNT > 0 THEN
        MSC_SATP_FUNC.Extend_Atp_Period(l_atp_period2, x_return_status);

   	FOR i IN 1..l_atp_supply_demand2.Supply_Demand_Date.COUNT LOOP
     	  l_atp_period2.Level(m) := l_atp_supply_demand2.Level(i);
          l_atp_period2.Identifier(m) := l_atp_supply_demand2.Identifier(i);
          l_atp_period2.Scenario_Id(m) := l_atp_supply_demand2.Scenario_Id(i);
	  l_atp_period2.From_Organization_Id := l_atp_supply_demand2.From_Organization_Id;
	  l_atp_period2.To_Organization_Id := l_atp_supply_demand2.To_Organization_Id;
	  l_atp_period2.Ship_Method := l_atp_supply_demand2.Ship_Method;
	  l_atp_period2.Uom := l_atp_supply_demand2.Uom;

	  IF i = 1 THEN
	    l_atp_period2.Period_Start_Date(m) := l_atp_supply_demand2.Supply_Demand_Date(i);

  	    l_atp_period2.Identifier1(m) := l_atp_supply_demand2.Identifier1(i);
            l_atp_period2.Identifier2(m) := l_atp_supply_demand2.Identifier2(i);

	    -- working on first supply demand record
            IF l_atp_supply_demand2.Supply_Demand_Type(i) = 1 THEN
              l_atp_period2.Total_Demand_Quantity(m) :=
                   l_atp_supply_demand2.Supply_Demand_Quantity(i);
              l_atp_period2.Total_Supply_Quantity(m) := 0;
              l_atp_period2.Period_Quantity(m) :=
                   l_atp_period2.Total_Supply_Quantity(m)+
                   l_atp_period2.Total_Demand_Quantity(m);

	    ELSE
               l_atp_period2.Total_Supply_Quantity(m) :=
                   l_atp_supply_demand2.Supply_Demand_Quantity(i);
               l_atp_period2.Total_Demand_Quantity(m) := 0;
               l_atp_period2.Period_Quantity(m) :=
                   l_atp_period2.Total_Supply_Quantity(m)+
                   l_atp_period2.Total_Demand_Quantity(m);
            END IF;

	  ELSE
            -- working on 2nd record or later
            -- make sure the supply demand date of this record is
            -- greater than the previous bucket or not.
            IF l_atp_supply_demand2.Supply_Demand_Date(i) >
               l_atp_period2.Period_Start_Date(m) THEN

	       -- populate the period_end_date and
               -- period_atp information.
               l_atp_period2.Period_End_Date(m) :=
                   l_atp_supply_demand2.Supply_Demand_Date(i) -1;

               -- add one more bucket
               m:=m+1;

               MSC_SATP_FUNC.Extend_Atp_Period(l_atp_period2, x_return_status);

	       l_atp_period2.Level(m) := l_atp_supply_demand2.Level(i);
               l_atp_period2.Identifier(m) := l_atp_supply_demand2.Identifier(i);
               l_atp_period2.Scenario_Id(m) := l_atp_supply_demand2.Scenario_Id(i);
               l_atp_period2.From_Organization_Id := l_atp_supply_demand2.From_Organization_Id;
               l_atp_period2.To_Organization_Id := l_atp_supply_demand2.To_Organization_Id;
               l_atp_period2.Ship_Method := l_atp_supply_demand2.Ship_Method;
               l_atp_period2.Uom := l_atp_supply_demand2.Uom;

               l_atp_period2.Period_Start_Date(m) :=
                   l_atp_supply_demand2.Supply_Demand_Date(i);

               l_atp_period2.Identifier1(m):=l_atp_supply_demand2.Identifier1(i);
               l_atp_period2.Identifier2(m):=l_atp_supply_demand2.Identifier2(i);

	       IF l_atp_supply_demand2.Supply_Demand_Type(i) = 1 THEN
                   l_atp_period2.Total_Demand_Quantity(m) :=
                   l_atp_supply_demand2.Supply_Demand_Quantity(i);
                   l_atp_period2.Total_Supply_Quantity(m) := 0;
                   l_atp_period2.Period_Quantity(m) :=
                   l_atp_period2.Total_Supply_Quantity(m)+
                   l_atp_period2.Total_Demand_Quantity(m);

               ELSE
                   l_atp_period2.Total_Supply_Quantity(m) :=
                   l_atp_supply_demand2.Supply_Demand_Quantity(m);
                   l_atp_period2.Total_Demand_Quantity(m) := 0;
                   l_atp_period2.Period_Quantity(m) :=
                   l_atp_period2.Total_Supply_Quantity(m)+
                   l_atp_period2.Total_Demand_Quantity(m);

               END IF;

	    ELSE
	       -- same bucket
               IF l_atp_supply_demand2.Supply_Demand_Type(i) = 1 THEN
                   l_atp_period2.Total_Demand_Quantity(m) :=
                   l_atp_period2.Total_Demand_Quantity(m) +
                   l_atp_supply_demand2.Supply_Demand_Quantity(i);
               ELSE
                   l_atp_period2.Total_Supply_Quantity(m) :=
                   l_atp_period2.Total_Supply_Quantity(m)+
                   l_atp_supply_demand2.Supply_Demand_Quantity(i);
               END IF;
               l_atp_period2.Period_Quantity(m) :=
               l_atp_period2.Total_Supply_Quantity(m)+
               l_atp_period2.Total_Demand_Quantity(m);

           END IF;
 	END IF; -- end 2nd record or later
      END LOOP;
    END IF;

    l_atp_period.Cumulative_Quantity := l_atp_period.Period_Quantity;
    -- do the accumulation
    MSC_ATP_PROC.atp_consume(l_atp_period.Cumulative_Quantity, m);

    l_atp_period2.Cumulative_Quantity := l_atp_period2.Period_Quantity;
    -- do the accumulation
    MSC_ATP_PROC.atp_consume(l_atp_period2.Cumulative_Quantity, m);

  END IF;

  MSC_ATP_PROC.Details_Output(l_atp_period2, l_atp_supply_demand2, l_atp_period, l_atp_supply_demand,
			x_return_status);

  x_atp_period := l_atp_period;
  x_atp_supply_demand := l_atp_supply_demand;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END Get_Transport_Cap_Atp_Info;


--s_cto_rearch
procedure Extend_Atp_Comp_Typ ( P_Atp_Comp_Typ IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ)
IS
BEGIN

   P_Atp_Comp_Typ.inventory_item_id.extend;
   P_Atp_Comp_Typ.comp_usage.extend;
   P_Atp_Comp_Typ.requested_date.extend;
   P_Atp_Comp_Typ.lead_time.extend;
   P_Atp_Comp_Typ.wip_supply_type.extend;
   P_Atp_Comp_Typ.assembly_identifier.extend;
   P_Atp_Comp_Typ.component_identifier.extend;
   P_Atp_Comp_Typ.reverse_cumulative_yield.extend;
   P_Atp_Comp_Typ.match_item_id.extend;
   P_Atp_Comp_Typ.bom_item_type.extend;
   P_Atp_Comp_Typ.parent_line_id.extend;
   P_Atp_Comp_Typ.top_model_line_id.extend;
   P_Atp_Comp_Typ.ato_parent_model_line_id.extend;
   P_Atp_Comp_Typ.ato_model_line_id.extend;
   P_Atp_Comp_Typ.mand_comp_flag.extend;
   P_Atp_Comp_Typ.parent_so_quantity.extend;
   P_Atp_Comp_Typ.fixed_lt.extend;
   p_atp_comp_typ.variable_lt.extend;
   p_atp_comp_typ.oss_error_code.extend;
   p_atp_comp_typ.atp_flag.extend;
   p_atp_comp_typ.atp_components_flag.extend;
   P_Atp_Comp_Typ.request_item_id.extend;       -- For time_phased_atp
   P_Atp_Comp_Typ.atf_date.extend;              -- For time_phased_atp
   P_Atp_Comp_Typ.match_item_family_id.extend;  -- For time_phased_atp
   P_Atp_Comp_Typ.dest_inventory_item_id.extend;
   P_Atp_Comp_Typ.parent_item_id.extend;
   P_Atp_Comp_Typ.comp_uom.extend; --bug3110023
   --4570421
   P_Atp_Comp_Typ.scaling_type.extend;
   P_Atp_Comp_Typ.scale_multiple.extend;
   P_Atp_Comp_Typ.scale_rounding_variance.extend;
   P_Atp_Comp_Typ.rounding_direction.extend;
   P_Atp_Comp_Typ.component_yield_factor.extend;
   P_Atp_Comp_Typ.usage_qty.extend; --4775920
   P_Atp_Comp_Typ.organization_type.extend; --4775920

END Extend_Atp_Comp_Typ;


Procedure Add_To_Comp_List(p_explode_comp_rec          IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                           p_component_rec             IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                           p_atp_comp_rec              IN MRP_ATP_PVT.ATP_COMP_REC)

IS
j  number;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Add_To_Comp_List: Enter Into Add_To_Comp_List');
       msc_sch_wb.atp_debug('Add_To_Comp_List: inventory_item_id := ' || p_atp_comp_rec.inventory_item_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: comp_usage := ' || p_atp_comp_rec.comp_usage );
       msc_sch_wb.atp_debug('Add_To_Comp_List: requested_date := ' || p_atp_comp_rec.requested_date );
       msc_sch_wb.atp_debug('Add_To_Comp_List: lead_time := ' || p_atp_comp_rec.lead_time );
       msc_sch_wb.atp_debug('Add_To_Comp_List: wip_supply_type := ' || p_atp_comp_rec.wip_supply_type );
       msc_sch_wb.atp_debug('Add_To_Comp_List: assembly_identifier := ' || p_atp_comp_rec.assembly_identifier );
       msc_sch_wb.atp_debug('Add_To_Comp_List: component_identifier := ' || p_atp_comp_rec.component_identifier );
       msc_sch_wb.atp_debug('Add_To_Comp_List: reverse_cumulative_yield := ' || p_atp_comp_rec.reverse_cumulative_yield );
       msc_sch_wb.atp_debug('Add_To_Comp_List: match_item_id:= ' || p_atp_comp_rec.match_item_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: match_item_family_id := ' || p_atp_comp_rec.match_item_family_id);
       msc_sch_wb.atp_debug('Add_To_Comp_List: bom_item_type := ' || p_atp_comp_rec.bom_item_type );
       msc_sch_wb.atp_debug('Add_To_Comp_List: parent_line_id := ' || p_atp_comp_rec.parent_line_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: top_model_line_id := ' || p_atp_comp_rec.top_model_line_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: ato_parent_model_line_id := ' || p_atp_comp_rec.ato_parent_model_line_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: ato_model_line_id := ' || p_atp_comp_rec.ato_model_line_id );
       msc_sch_wb.atp_debug('Add_To_Comp_List: MAND_COMP_FLAG := ' || p_atp_comp_rec.MAND_COMP_FLAG );
       msc_sch_wb.atp_debug('Add_To_Comp_List: parent_so_quantity := ' || p_atp_comp_rec.parent_so_quantity );
       msc_sch_wb.atp_debug('Add_To_Comp_List: fixed_lt := ' || p_atp_comp_rec.fixed_lt );
       msc_sch_wb.atp_debug('Add_To_Comp_List: variable_lt := ' || p_atp_comp_rec.variable_lt );
       msc_sch_wb.atp_debug('Add_To_Comp_List: oss_error_code := ' || p_atp_comp_rec.oss_error_code );
       msc_sch_wb.atp_debug('Add_To_Comp_List: model_flag := ' || p_atp_comp_rec.model_flag );
       msc_sch_wb.atp_debug('Add_To_Comp_List: requested_quantity := ' || p_atp_comp_rec.requested_quantity );
       msc_sch_wb.atp_debug('Add_To_Comp_List: atp flag := ' || p_atp_comp_rec.atp_flag);
       msc_sch_wb.atp_debug('Add_To_Comp_List: atp_comp_flag := '|| p_atp_comp_rec.atp_components_flag);
       msc_sch_wb.atp_debug('Add_To_Comp_List: atf_date := '|| p_atp_comp_rec.atf_date);
       msc_sch_wb.atp_debug('Add_To_Comp_List: dest_inventory_item_id := ' || p_atp_comp_rec.dest_inventory_item_id);
       msc_sch_wb.atp_debug('Add_To_Comp_List: parent_repl_ord_flag := ' || p_atp_comp_rec.parent_repl_ord_flag);
       msc_sch_wb.atp_debug('Add_To_Comp_List: comp_uom := ' || p_atp_comp_rec.comp_uom); --bug3110023

   END IF;

   IF ((p_atp_comp_rec.model_flag = 1 and p_atp_comp_rec.bom_item_type = 2) or
                                 (p_atp_comp_rec.model_flag <>  1 and p_atp_comp_rec.wip_supply_type = 6
                                                                  and p_atp_comp_rec.parent_repl_ord_flag = 'N'
                                                                  and MSC_ATP_PVT.G_INV_CTP = 4)) THEN
      -- this is phantom, add to explode list

      j := p_explode_comp_rec.inventory_item_id.COUNT;

      -- bug 1831563: removed the extend and assign to
      -- l_explode_comp.pre_process_lead_time since it is not needed.

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Add_To_Comp_List: ' || 'in side phantom, count = '||j);
          msc_sch_wb.atp_debug('Add_To_Comp_List: Count in explode comp := ' || p_explode_comp_rec.inventory_item_id.count);
      END IF;

      MSC_ATP_REQ.Extend_ATP_Comp_TYP(p_explode_comp_rec);

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Add_To_Comp_List: ' || 'after extend');
      END IF;

      p_explode_comp_rec.inventory_item_id(j+1):= p_atp_comp_rec.inventory_item_id;
      /* time_phased_atp changes begin
         Support PF ATP for components*/
      p_explode_comp_rec.request_item_id(j+1):= p_atp_comp_rec.request_item_id;
      p_explode_comp_rec.atf_date(j+1):= p_atp_comp_rec.atf_date;
      p_explode_comp_rec.match_item_family_id(j + 1) := p_atp_comp_rec.match_item_family_id;
      /* time_phased_atp changes end*/

      p_explode_comp_rec.requested_date(j+1) := p_atp_comp_rec.requested_date;
      p_explode_comp_rec.comp_usage(j+1) := p_atp_comp_rec.comp_usage;
      p_explode_comp_rec.wip_supply_type(j+1) := p_atp_comp_rec.wip_supply_type;
      --(3004862) circular BOM issue Assign the Inventory item id for component. We'll
      --be using this later when accessing process effectivity.
      p_explode_comp_rec.component_identifier(j+1) := p_atp_comp_rec.component_identifier;

      --- bug 2680027: Now remember the lead time for parent
      p_explode_comp_rec.lead_time(j+1) := p_atp_comp_rec.lead_time;

      p_explode_comp_rec.assembly_identifier(j +1) := p_atp_comp_rec.assembly_identifier;
      p_explode_comp_rec.match_item_id(j + 1) := p_atp_comp_rec.match_item_id;
      p_explode_comp_rec.bom_item_type(j + 1) := p_atp_comp_rec.bom_item_type;
      p_explode_comp_rec.top_model_line_id(j +1) := p_atp_comp_rec.top_model_line_id;
      p_explode_comp_rec.ato_parent_model_line_id(j +1 ) := p_atp_comp_rec.ato_parent_model_line_id;
      p_explode_comp_rec.ato_model_line_id(j+ 1) := p_atp_comp_rec.ato_model_line_id;
      p_explode_comp_rec.parent_line_id(j+1) := p_atp_comp_rec.parent_line_id;
      p_explode_comp_rec.reverse_cumulative_yield(j+1) := p_atp_comp_rec.reverse_cumulative_yield;
      p_explode_comp_rec.parent_so_quantity(j + 1) := p_atp_comp_rec.parent_so_quantity;
      p_explode_comp_rec.mand_comp_flag(j + 1) := p_atp_comp_rec.mand_comp_flag;
      p_explode_comp_rec.fixed_lt(j +1) := p_atp_comp_rec.fixed_lt;
      p_explode_comp_rec.variable_lt(j +1 ) := p_atp_comp_rec.variable_lt;
      p_explode_comp_rec.oss_error_code(j + 1) := p_atp_comp_rec.oss_error_code;
      p_explode_comp_rec.atp_flag(j +1 ) := p_atp_comp_rec.atp_flag;
      p_explode_comp_rec.atp_components_flag(j +1 ) := p_atp_comp_rec.atp_components_flag;
      p_explode_comp_rec.dest_inventory_item_id(j +1)  := p_atp_comp_rec.dest_inventory_item_id;
      p_explode_comp_rec.comp_uom(j +1)  := p_atp_comp_rec.comp_uom; --bug3110023
      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_To_Comp_List: explode lead_time := ' || p_explode_comp_rec.lead_time(j+1));
           msc_sch_wb.atp_debug('Add_To_Comp_List: ' || 'after assign ');
      END IF;
   END IF;

   IF p_atp_comp_rec.wip_supply_type <> 6 or
       p_atp_comp_rec.parent_repl_ord_flag = 'Y' or p_atp_comp_rec.model_flag = 1 THEN

         -- this is not phantom, add to the component list

         j := p_component_rec.inventory_item_id.COUNT;

         IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Add_To_Comp_List: ' || 'not phantom, j='||j);
         END IF;

         MSC_ATP_REQ.Extend_ATP_Comp_TYP(p_component_rec);

         p_component_rec.inventory_item_id(j+1):= p_atp_comp_rec.inventory_item_id;
         /* time_phased_atp changes begin
            Support PF ATP for components*/
         p_component_rec.request_item_id(j+1):= p_atp_comp_rec.request_item_id;
         p_component_rec.atf_date(j+1):= p_atp_comp_rec.atf_date;
         -- time_phased_atp changes end

         p_component_rec.requested_date(j+1) := p_atp_comp_rec.requested_date;
         --p_component_rec.comp_usage(j+1) := p_atp_comp_rec.comp_usage/p_atp_comp_rec.requested_quantity;
         --4570421
         IF ( (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.DISCRETE_ORG AND nvl(p_atp_comp_rec.scaling_type,1) = 1) OR
                (MSC_ATP_PVT.G_ORG_INFO_REC.org_type = MSC_ATP_PVT.OPM_ORG AND nvl(p_atp_comp_rec.scaling_type,1) IN (1,3,4,5))) THEN
                p_component_rec.comp_usage(j+1) := p_atp_comp_rec.comp_usage/p_atp_comp_rec.requested_quantity;
         ELSE
                p_component_rec.comp_usage(j+1) := p_atp_comp_rec.comp_usage;
         END IF;
         IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Add_To_Comp_List: p_atp_comp_rec.comp_usage ' || p_atp_comp_rec.comp_usage);
             msc_sch_wb.atp_debug('Add_To_Comp_List: p_atp_comp_rec.requested_quantity ' || p_atp_comp_rec.requested_quantity);
             msc_sch_wb.atp_debug('Add_To_Comp_List: p_component_rec.comp_usage(j+1) ' || p_component_rec.comp_usage(j+1));
         END IF;

         --4570421
         p_component_rec.scaling_type(j+1) := p_atp_comp_rec.scaling_type;
         p_component_rec.scale_multiple(j+1) := p_atp_comp_rec.scale_multiple;
         p_component_rec.scale_rounding_variance(j+1) := p_atp_comp_rec.scale_rounding_variance;
         p_component_rec.rounding_direction(j+1) := p_atp_comp_rec.rounding_direction;
         p_component_rec.component_yield_factor(j+1) := p_atp_comp_rec.component_yield_factor; --4570421
         p_component_rec.usage_qty(j+1) := p_atp_comp_rec.usage_qty; --4775920
         p_component_rec.organization_type(j+1) := p_atp_comp_rec.organization_type; --4775920

         --- bug 2680027: Add lead time from Parent
         --l_comp_requirements.lead_time(j+1) := l_atp_comp_rec.comp_lead_time;
         p_component_rec.lead_time(j+1) := p_atp_comp_rec.lead_time;

         p_component_rec.assembly_identifier(j+1) := p_atp_comp_rec.assembly_identifier;
         p_component_rec.component_identifier(j+1) := p_atp_comp_rec.component_identifier;

         p_component_rec.reverse_cumulative_yield(j+1) := p_atp_comp_rec.reverse_cumulative_yield;
         p_component_rec.wip_supply_type(j +1) := p_atp_comp_rec.wip_supply_type;
         p_component_rec.match_item_id(j+1) := p_atp_comp_rec.match_item_id;
         p_component_rec.bom_item_type(j +1) := p_atp_comp_rec.bom_item_type;
         p_component_rec.parent_line_id(j +1) := p_atp_comp_rec.parent_line_id;
         p_component_rec.top_model_line_id(j +1) := p_atp_comp_rec.top_model_line_id;
         p_component_rec.ato_parent_model_line_id(j+1) := p_atp_comp_rec.ato_parent_model_line_id;
         p_component_rec.ato_model_line_id(j+1) := p_atp_comp_rec.ato_model_line_id;
         p_component_rec.parent_so_quantity(j +1) := p_atp_comp_rec.parent_so_quantity;
         p_component_rec.mand_comp_flag(j +1) := p_atp_comp_rec.mand_comp_flag;
         p_component_rec.fixed_lt(j+1) := p_atp_comp_rec.fixed_lt;
         p_component_rec.variable_lt(j+1) := p_atp_comp_rec.variable_lt;
         p_component_rec.oss_error_code(j +1) := p_atp_comp_rec.oss_error_code;
         p_component_rec.atp_flag(j +1)  := p_atp_comp_rec.atp_flag;
         p_component_rec.atp_components_flag(j +1) := p_atp_comp_rec.atp_components_flag;
         p_component_rec.dest_inventory_item_id(j +1)  := p_atp_comp_rec.dest_inventory_item_id;
         p_component_rec.match_item_family_id(j + 1) := p_atp_comp_rec.match_item_family_id;
         p_component_rec.comp_uom(j + 1) := p_atp_comp_rec.comp_uom; --bug3110023


         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Add_To_Comp_List: ' || 'in side not phantom');
         END IF;
   END IF;

END Add_To_Comp_List;
---e_cto_rearch


END MSC_ATP_REQ;

/
