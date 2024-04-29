--------------------------------------------------------
--  DDL for Package Body MSC_ANALYSIS_SAFETY_STOCK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ANALYSIS_SAFETY_STOCK" AS
/*  $Header: MSCASSB.pls 120.0 2005/05/25 17:33:45 appldev noship $ */
--
-- Preprocesses safety stock/service level data for subsequent digestion in
-- Inventory Optimization's Analysis View "Safety Stock and Service Level Report"
--
--

   RECORD_SAFETY_STOCK         CONSTANT NUMBER := 0;
   RECORD_SERVICE_LEVEL        CONSTANT NUMBER := 1;
   RECORD_TARGET_SL_VIEWBY_ITEM CONSTANT NUMBER := 2;
   RECORD_TARGET_SL_VIEWBY_CUST CONSTANT NUMBER := 3;

   UNDEFINED_CUSTOMER_CODE CONSTANT VARCHAR2(30) := '_MISC'; -- Used in Java
   UNDEFINED_CUSTOMER_ID   CONSTANT NUMBER := -1;

   do_debug BOOLEAN := FALSE;

   TYPE Bucket IS RECORD
   (
      -- item key
      plan_id             NUMBER := 0,
      instance_id         NUMBER := 0,
      org_id              NUMBER := 0,
      item_id             NUMBER := 0,
      sr_category_id      NUMBER := 0,
      category_name       VARCHAR2(255) := NULL,
      plan_name           VARCHAR2(255) := NULL,
      org_name            VARCHAR2(255) := NULL,
      item_name           VARCHAR2(255) := NULL,
      -- bucket data
      bkt_start_date      DATE := NULL,
      bkt_end_date        DATE := NULL,
      week_nr             NUMBER := 0,
      period_start_date   DATE := NULL,
      period_nr           NUMBER := 0,
      bucket_type         NUMBER := 0,
      last_week_of_period VARCHAR2(1) := 'N',
      -- budget measures
      achieved_ss_qty     NUMBER := 0,
      achieved_ss_dollars NUMBER := 0,
      achieved_ss_days    NUMBER := 0,
      target_ss_qty       NUMBER := 0,
      target_ss_dollars   NUMBER := 0,
      target_ss_days      NUMBER := 0,
      userdef_ss_qty      NUMBER := 0,
      userdef_ss_dollars  NUMBER := 0,
      userdef_ss_days     NUMBER := 0,
      num_safety_stock    NUMBER := 0,
      -- service level measures
      delivered_quantity  NUMBER := 0, -- Achieved Service Level = delivered / required
      required_quantity   NUMBER := 0, -- These are kept separate for UI aggregation
      target_service_level NUMBER := 0,
      num_target_service_level NUMBER := 0,  -- weight for UI aggregation
      partner_id          NUMBER := NULL,
      partner_name        VARCHAR2(255) := NULL,
      customer_class_code VARCHAR2(30) := NULL,
      -- service level or safety stock record
      record_type         NUMBER := NULL
   );

   TYPE Schedule IS TABLE OF Bucket INDEX BY BINARY_INTEGER;
   TYPE PlanList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   PROCEDURE parse_planlist(p_plans VARCHAR2, p_planlist IN OUT NOCOPY PlanList)
   IS
      occurrence NUMBER := 1;
      stringstart NUMBER := 1;
      stringend NUMBER := 1;
      planfound NUMBER := 1;
      pos NUMBER;
      token NUMBER;
   BEGIN

      LOOP
         pos := INSTR(p_plans, ',', 1, occurrence);
         occurrence := occurrence + 1;
         IF pos = 0 THEN
            stringend := LENGTH(p_plans);
            token := to_number(SUBSTR(p_plans, stringstart, stringend - stringstart + 1));
            IF token IS NOT NULL THEN
               p_planlist(planfound) := token;
               planfound := planfound + 1;
            END IF;
            EXIT;
         END IF;
         stringend := pos - 1;
         token := to_number(SUBSTR(p_plans, stringstart, stringend - stringstart + 1));
         IF token IS NOT NULL THEN
            p_planlist(planfound) := token;
            planfound := planfound + 1;
         END IF;
         stringstart := stringend + 2;
      END LOOP;

   END;

   FUNCTION get_customer_target_sl(customer_id NUMBER)
   RETURN NUMBER
   IS
      l_target_service_level NUMBER;
   BEGIN
      SELECT service_level
        INTO l_target_service_level
        FROM msc_trading_partners
       WHERE partner_type = 2
         AND partner_id = customer_id;
      RETURN l_target_service_level;
   EXCEPTION WHEN OTHERS THEN RETURN NULL;
   END;

   FUNCTION get_cat_set_id(arg_plan_id number) RETURN NUMBER is
  l_cat_set_id number;
  l_def_pref_id number;
  l_plan_type number;
  cursor plan_type_c(v_plan_id number) is
  select curr_plan_type
  from msc_plans
  where plan_id = v_plan_id;
  BEGIN
  open plan_type_c(arg_plan_id);
  fetch plan_type_c into l_plan_type;
  close plan_type_c;

  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  l_cat_set_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);
  return l_cat_set_id;
  END get_cat_set_id;
   PROCEDURE schedule_create(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER)
   IS

      CURSOR c1(p_plan_id NUMBER) IS
      SELECT mp.plan_id, mp.compile_designator, mtp.calendar_code, mpb.bkt_start_date, mpb.bkt_end_date,
             mpsd.period_start_date, mpb.bucket_type
      FROM msc_plans mp, msc_trading_partners mtp, msc_plan_buckets mpb, msc_period_start_dates mpsd
      WHERE mp.plan_id = p_plan_id
        AND mtp.sr_tp_id = mp.organization_id
        AND mtp.sr_instance_id = mp.sr_instance_id
        AND mtp.partner_type = 3
        AND mp.plan_id = mpb.plan_id
        AND mp.sr_instance_id = mpb.sr_instance_id
        AND mp.organization_id = mpb.organization_id
        AND mtp.sr_Instance_id = mpsd.sr_instance_id
        AND mtp.calendar_code = mpsd.calendar_code
        AND mpb.bucket_type in (2,3)
        AND mpb.sr_instance_id = mpsd.sr_instance_id
        AND mpsd.exception_set_id = mtp.calendar_exception_set_id
        AND mpsd.calendar_code = mtp.calendar_code
        AND (mpb.bkt_start_date >= mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date)
      ORDER BY mpb.bkt_start_date;

      currentBucket Bucket;
      currentPosition BINARY_INTEGER := 1;
      c1Rec c1%ROWTYPE;
      previous_period_start_date DATE := NULL;
      current_week_nr NUMBER := 1;
      current_period_nr NUMBER := 1;

   BEGIN

      OPEN c1(p_plan_id);
      LOOP
         FETCH c1 INTO c1Rec;
         IF c1%NOTFOUND THEN
            IF current_week_nr > 1 THEN
               mainschedule(current_week_nr - 1).last_week_of_period := 'Y';
            END IF;
            EXIT;
         END IF;

         currentBucket.bkt_start_date    := c1Rec.bkt_start_date;
         currentBucket.bkt_end_date      := c1Rec.bkt_end_date;
         currentBucket.period_start_date := c1Rec.period_start_date;
         currentBucket.week_nr           := current_week_nr;
         currentBucket.bucket_type       := c1Rec.bucket_type;
         IF currentBucket.period_start_date <> previous_period_start_date THEN
            current_period_nr := current_period_nr + 1;
            -- Need the last week of the period for collapsing ss across weeks
            IF current_week_nr > 1 THEN
               mainschedule(current_week_nr - 1).last_week_of_period := 'Y';
            END IF;
         END IF;
         currentBucket.period_nr := current_period_nr;

         mainschedule(current_week_nr) := currentBucket;

         previous_period_start_date := currentBucket.period_start_date;
         current_week_nr := current_week_nr + 1;
      END LOOP;
      CLOSE c1;

   END;

   PROCEDURE schedule_dump_header
   IS
   BEGIN
      IF do_debug = FALSE THEN
         RETURN;
      END IF;
      dbms_output.put('plan_id,inst_id,org_id,item_id,cat_id,record,lwop,start,end,period_start,period_nr,weeknr,achieved_ss,');
      dbms_output.put('achieved_ss_dl,target_ss,target_ss_dl,target_ss_ds,userdef_ss,userdef_ss_dl,userdef_ss_ds,num_ss,delivered,');
      dbms_output.put_line('required,target_sl,num_target_sl,customer_id');
   END;

   PROCEDURE schedule_dump_record(aRecord BUCKET)
   IS
   BEGIN

      IF do_debug = FALSE THEN
         RETURN;
      END IF;
      dbms_output.put('"'||aRecord.plan_id || '","' || aRecord.instance_id || '",');
      dbms_output.put('"'|| aRecord.org_id || '","' || aRecord.item_id || '",');
      dbms_output.put('"' || aRecord.sr_category_id  || '",');
      IF aRecord.record_type = RECORD_SERVICE_LEVEL THEN
         DBMS_OUTPUT.put('"SL",');
      ELSIF aRecord.record_type = RECORD_SAFETY_STOCK THEN
         DBMS_OUTPUT.put('"SS",');
      ELSIF aRecord.record_type = RECORD_TARGET_SL_VIEWBY_ITEM THEN
         DBMS_OUTPUT.put('"TLI",');
      ELSIF aRecord.record_type = RECORD_TARGET_SL_VIEWBY_CUST THEN
         DBMS_OUTPUT.put('"TLC",');
      END IF;
      dbms_output.put('"' || aRecord.last_week_of_period || '",');
      dbms_output.put('"' || aRecord.bkt_start_date || '","' || aRecord.bkt_end_date || '",');
      dbms_output.put('"' || aRecord.period_start_date || '",');
      dbms_output.put('"' || aRecord.week_nr || '","' || aRecord.period_nr || '",');
      dbms_output.put('"' || aRecord.achieved_ss_qty || '",');
      dbms_output.put('"' || aRecord.achieved_ss_dollars || '",');
      dbms_output.put('"' || aRecord.target_ss_qty || '",');
      dbms_output.put('"' || aRecord.target_ss_dollars || '",');
      dbms_output.put('"' || aRecord.target_ss_days || '",');
      dbms_output.put('"' || aRecord.userdef_ss_qty || '",');
      dbms_output.put('"' || aRecord.userdef_ss_dollars || '",');
      dbms_output.put('"' || aRecord.userdef_ss_days || '",');
      dbms_output.put('"' || aRecord.num_safety_stock || '",');
      dbms_output.put('"' || aRecord.delivered_quantity || '",');
      dbms_output.put('"' || aRecord.required_quantity || '",');
      dbms_output.put('"' || aRecord.target_service_level || '",');
      dbms_output.put('"' || aRecord.num_target_service_level || '",');
      dbms_output.put_line('"' || aRecord.partner_id || '"');
   END;

   PROCEDURE schedule_initialize(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket)
   IS
      l_target_service_level NUMBER;
   BEGIN

      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         mainschedule(i).achieved_ss_qty     := 0;
         mainschedule(i).achieved_ss_dollars := 0;
         mainschedule(i).achieved_ss_days    := 0;
         mainschedule(i).target_ss_qty       := 0;
         mainschedule(i).target_ss_dollars   := 0;
         mainschedule(i).target_ss_days      := 0;
         mainschedule(i).userdef_ss_qty      := 0;
         mainschedule(i).userdef_ss_dollars  := 0;
         mainschedule(i).userdef_ss_days     := 0;
         mainschedule(i).delivered_quantity  := 0;
         mainschedule(i).required_quantity   := 0;
         mainschedule(i).target_service_level := 0;
         mainschedule(i).num_target_service_level := 0;
         mainschedule(i).num_safety_stock := 0;

         mainschedule(i).target_service_level := NULL;
         mainschedule(i).num_target_service_level := 1;

         mainschedule(i).plan_id := aRecord.plan_id;
         mainschedule(i).plan_name := aRecord.plan_name;
         mainschedule(i).instance_id := aRecord.instance_id;
         mainschedule(i).org_id := aRecord.org_id;
         mainschedule(i).org_name := aRecord.org_name;
         mainschedule(i).sr_category_id := aRecord.sr_category_id;
         mainschedule(i).category_name := aRecord.category_name;
         mainschedule(i).item_id        := aRecord.item_id;
         mainschedule(i).item_name      := aRecord.item_name;
         mainschedule(i).partner_id := nvl(aRecord.partner_id, UNDEFINED_CUSTOMER_ID);
         mainschedule(i).partner_name := aRecord.partner_name;
         mainschedule(i).record_type := aRecord.record_type;
         mainschedule(i).sr_category_id := aRecord.sr_category_id;
         mainschedule(i).category_name := aRecord.category_name;
         mainschedule(i).customer_class_code := nvl(aRecord.customer_class_code, UNDEFINED_CUSTOMER_CODE);
      END LOOP;

   END;

   PROCEDURE schedule_ss_fill_gaps(mainschedule IN OUT NOCOPY Schedule)
   IS
      l_prev_userdef_ss_qty NUMBER;
      l_prev_userdef_ss_days NUMBER;
      l_prev_userdef_ss_dollars NUMBER;
      l_prev_achieved_ss_qty NUMBER;
      l_prev_achieved_ss_days NUMBER;
      l_prev_achieved_ss_dollars NUMBER;
      l_prev_target_ss_qty NUMBER;
      l_prev_target_ss_days NUMBER;
      l_prev_target_ss_dollars NUMBER;
      l_prev_num_safety_stock NUMBER := NULL;

   BEGIN
      FOR currentIndex IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF mainschedule(currentIndex).num_safety_stock IS NULL AND l_prev_num_safety_stock IS NOT NULL THEN
            mainschedule(currentIndex).userdef_ss_qty := l_prev_userdef_ss_qty;
            mainschedule(currentIndex).userdef_ss_days := l_prev_userdef_ss_days;
            mainschedule(currentIndex).userdef_ss_dollars := l_prev_userdef_ss_dollars;
            mainschedule(currentIndex).achieved_ss_qty := l_prev_achieved_ss_qty;
            mainschedule(currentIndex).achieved_ss_days := l_prev_achieved_ss_days;
            mainschedule(currentIndex).achieved_ss_dollars := l_prev_achieved_ss_dollars;
            mainschedule(currentIndex).target_ss_qty := l_prev_target_ss_qty;
            mainschedule(currentIndex).target_ss_days := l_prev_target_ss_days;
            mainschedule(currentIndex).target_ss_dollars := l_prev_target_ss_dollars;
            mainschedule(currentIndex).num_safety_stock := l_prev_num_safety_stock;
         END IF;
         l_prev_userdef_ss_qty      := mainschedule(currentIndex).userdef_ss_qty;
         l_prev_userdef_ss_days     := mainschedule(currentIndex).userdef_ss_days;
         l_prev_userdef_ss_dollars  := mainschedule(currentIndex).userdef_ss_dollars;
         l_prev_achieved_ss_qty     := mainschedule(currentIndex).achieved_ss_qty;
         l_prev_achieved_ss_days    := mainschedule(currentIndex).achieved_ss_days;
         l_prev_achieved_ss_dollars := mainschedule(currentIndex).achieved_ss_dollars;
         l_prev_target_ss_qty       := mainschedule(currentIndex).target_ss_qty;
         l_prev_target_ss_days      := mainschedule(currentIndex).target_ss_days;
         l_prev_target_ss_dollars   := mainschedule(currentIndex).target_ss_dollars;
         l_prev_num_safety_stock    := mainschedule(currentIndex).num_safety_stock;
      END LOOP;
   END schedule_ss_fill_gaps;

   PROCEDURE schedule_output_record(query_id NUMBER, aRecord Bucket)
   IS
   BEGIN
      INSERT INTO msc_form_query
         (query_id, last_update_date, creation_date, created_by,
          NUMBER1,NUMBER2,NUMBER3,
          NUMBER4,NUMBER5,CHAR1,
          CHAR2, CHAR3, CHAR4,
          DATE1,DATE2,NUMBER6,
          DATE3,NUMBER7,NUMBER8,
          NUMBER9, NUMBER10, NUMBER11,
          NUMBER12,NUMBER13,NUMBER14,
          NUMBER15,NUMBER16,PROGRAM_ID,
          PROGRAM_APPLICATION_ID, REQUEST_ID,
          LAST_UPDATE_LOGIN, LAST_UPDATED_BY,
          CHAR7, CHAR5,
          CHAR6, CHAR8,
          CHAR9)
      VALUES
         (query_id, SYSDATE, SYSDATE, aRecord.record_type,
          aRecord.plan_id, aRecord.instance_id, aRecord.org_id,
          aRecord.item_id, aRecord.sr_category_id, aRecord.category_name,
          aRecord.plan_name, aRecord.org_name, aRecord.item_name,
          aRecord.bkt_start_date,aRecord.bkt_end_date,aRecord.week_nr,
          aRecord.period_start_date,aRecord.period_nr,aRecord.bucket_type,
          aRecord.achieved_ss_qty,aRecord.achieved_ss_dollars,aRecord.achieved_ss_days,
          aRecord.target_ss_qty,aRecord.target_ss_dollars,aRecord.target_ss_days,
          aRecord.userdef_ss_qty,aRecord.userdef_ss_dollars,aRecord.userdef_ss_days,
          aRecord.delivered_quantity,aRecord.required_quantity,
          aRecord.target_service_level,aRecord.num_target_service_level,
          aRecord.partner_id, aRecord.partner_name,
          aRecord.customer_class_code, aRecord.num_safety_stock,
          aRecord.last_week_of_period);

   END;

   PROCEDURE schedule_flush(mainschedule Schedule, query_id NUMBER)
   IS
   BEGIN

      schedule_dump_header;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         schedule_output_record(query_id, mainschedule(i));
         schedule_dump_record(mainschedule(i));
      END LOOP;
   END;

   FUNCTION is_bucket_match(aBucket Bucket, aRecord Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF aRecord.bkt_start_date >= aBucket.bkt_start_date AND
         aRecord.bkt_start_date <= aBucket.bkt_end_date
      THEN
         RETURN TRUE;
      END IF;

      RETURN FALSE;
   END;

   PROCEDURE bucket_service_level_record(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket, end_date DATE)
   IS
   BEGIN

      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF is_bucket_match(mainschedule(i), aRecord) THEN
            mainschedule(i).delivered_quantity := mainschedule(i).delivered_quantity + aRecord.delivered_quantity;
            mainschedule(i).required_quantity := mainschedule(i).required_quantity + aRecord.required_quantity;
         END IF;
      END LOOP;

   END;

   PROCEDURE bucket_safety_stock_record(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket, end_date DATE)
   IS
   BEGIN

      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF is_bucket_match(mainschedule(i), aRecord) THEN
            IF aRecord.userdef_ss_qty IS NOT NULL OR aRecord.userdef_ss_days IS NOT NULL THEN
               mainschedule(i).userdef_ss_qty := aRecord.userdef_ss_qty;
               mainschedule(i).userdef_ss_days := aRecord.userdef_ss_days;
               mainschedule(i).userdef_ss_dollars := aRecord.userdef_ss_dollars;
            END IF;

            IF aRecord.achieved_ss_qty IS NOT NULL THEN
               mainschedule(i).achieved_ss_qty := aRecord.achieved_ss_qty;
               mainschedule(i).achieved_ss_days := aRecord.achieved_ss_days;
               mainschedule(i).achieved_ss_dollars := aRecord.achieved_ss_dollars;
            END IF;

            IF aRecord.target_ss_qty IS NOT NULL THEN
               mainschedule(i).target_ss_qty := aRecord.target_ss_qty;
               mainschedule(i).target_ss_days := aRecord.target_ss_days;
               mainschedule(i).target_ss_dollars := aRecord.target_ss_dollars;
            END IF;

            mainschedule(i).num_safety_stock := 1; -- Weight for DOS
         END IF;
      END LOOP;
   END;

   FUNCTION is_service_level_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF currRecord.plan_id <> prevRecord.plan_id OR
         currRecord.org_id <> prevRecord.org_id OR
         currRecord.instance_id <> prevRecord.instance_id OR
         currRecord.item_id <> prevRecord.item_id OR
         nvl(currRecord.partner_id, -1) <> nvl(prevRecord.partner_id, -1)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

   FUNCTION is_safety_stock_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF currRecord.plan_id <> prevRecord.plan_id OR
         currRecord.org_id <> prevRecord.org_id OR
         currRecord.instance_id <> prevRecord.instance_id OR
         currRecord.item_id <> prevRecord.item_id
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

   PROCEDURE schedule_target_service_level(
      mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
      p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
      p_item_id NUMBER, p_partner_id NUMBER, p_customer_class_code VARCHAR2,
      query_id NUMBER)
   IS
      l_default_category_set_id NUMBER;

      CURSOR c1 IS
SELECT plan_id, instance_id, org_id,
      item_id,
      sr_category_id, category_name,
      plan_name,
      org_name,
      item_name,
      avg(nvl(get_customer_target_sl(partner_id) ,
      msc_get_bis_values.service_target(plan_id,instance_id,org_id,item_id))) AS target_sl
FROM
(
SELECT DISTINCT msi.plan_id AS plan_id, msi.sr_instance_id AS instance_id, msi.organization_id AS org_id,
      msi.inventory_item_id AS item_id,
      mic.sr_category_id AS sr_category_id, mic.category_name AS category_name,
      mp.compile_designator AS plan_name,
      mtp.organization_code AS org_name,
      msi.item_name AS item_name, cust.partner_id
 FROM msc_plans mp, msc_system_items msi, msc_item_categories mic, msc_trading_partners mtp, msc_trading_partners cust,
      msc_safety_stocks mss,
(SELECT demands.plan_id, demands.sr_instance_id, demands.organization_id, demands.using_assembly_item_id,
       demands.customer_id, demands.demand_id
  FROM msc_demands demands
WHERE demands.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)) msd
WHERE mp.plan_id = p_plan_id
  AND mp.plan_id = msi.plan_id
  AND msi.organization_id = mic.organization_id
  AND msi.sr_instance_id = mic.sr_instance_id
  AND msi.inventory_item_id = mic.inventory_item_id
  AND mic.category_set_id = l_default_category_set_id
  AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
  AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
  AND msi.organization_id = mtp.sr_tp_id
  AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
  AND msi.sr_instance_id = mtp.sr_instance_id
  AND mtp.partner_type = 3
  AND mtp.sr_instance_id = nvl(p_sr_instance_id, mtp.sr_instance_id)
  AND mtp.sr_tp_id = nvl(p_sr_tp_id, mtp.sr_tp_id)
  AND msi.sr_instance_id = mss.sr_instance_id (+)
  AND msi.plan_id = mss.plan_id (+)
  AND msi.organization_id = mss.organization_id (+)
  AND msi.inventory_item_id = mss.inventory_item_id (+)
  AND msi.plan_id = msd.plan_id (+)
  AND msi.sr_instance_id = msd.sr_instance_id (+)
  AND msi.organization_id = msd.organization_id (+)
  AND msi.inventory_item_id = msd.using_assembly_item_id (+)
  AND nvl(msd.customer_id, -1) = nvl(p_partner_id, nvl(msd.customer_id, -1))
  AND msd.customer_id = cust.partner_id (+)
  AND nvl(cust.customer_class_code, 'XXXXX') = nvl(p_customer_class_code, nvl(cust.customer_class_code, 'XXXXX'))
  AND (mss.safety_stock_quantity IS  NOT NULL OR msd.demand_id IS NOT NULL))
GROUP BY plan_id, instance_id, org_id,
      item_id,
      sr_category_id, category_name,
      plan_name,
      org_name,
      item_name;

   -- view by customer service levels
      CURSOR c2 IS
SELECT plan_id, nvl(partner_id, UNDEFINED_CUSTOMER_ID), partner_name, nvl(customer_class_code, UNDEFINED_CUSTOMER_CODE),
      avg(nvl(get_customer_target_sl(partner_id) ,
      msc_get_bis_values.service_target(plan_id,instance_id,org_id,item_id))) AS target_sl
FROM
(SELECT DISTINCT msi.plan_id AS plan_id, msi.sr_instance_id AS instance_id, msi.organization_id AS org_id,
      msi.inventory_item_id AS item_id,
      mic.sr_category_id AS sr_category_id, mic.category_name AS category_name,
      mp.compile_designator AS plan_name,
      mtp.organization_code AS org_name,
      cust.partner_id, cust.partner_name, cust.customer_class_code, msi.item_name AS item_name
 FROM msc_plans mp, msc_system_items msi, msc_item_categories mic, msc_trading_partners mtp, msc_trading_partners cust,
(SELECT demands.plan_id, demands.sr_instance_id, demands.organization_id, demands.using_assembly_item_id,
       demands.customer_id, demands.demand_id
  FROM msc_demands demands
WHERE demands.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)) msd
WHERE mp.plan_id = p_plan_id
  AND mp.plan_id = msi.plan_id
  AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
  AND msi.organization_id = mic.organization_id
  AND msi.sr_instance_id = mic.sr_instance_id
  AND msi.inventory_item_id = mic.inventory_item_id
  AND mic.category_set_id = l_default_category_set_id
  AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
  AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
  AND msi.organization_id = mtp.sr_tp_id
  AND msi.sr_instance_id = mtp.sr_instance_id
  AND mtp.partner_type = 3
  AND mtp.sr_instance_id = nvl(p_sr_instance_id, mtp.sr_instance_id)
  AND mtp.sr_tp_id = nvl(p_sr_tp_id, mtp.sr_tp_id)
  AND msi.plan_id = msd.plan_id
  AND msi.sr_instance_id = msd.sr_instance_id
  AND msi.organization_id = msd.organization_id
  AND msi.inventory_item_id = msd.using_assembly_item_id
  AND msd.customer_id = cust.partner_id (+)
  AND nvl(msd.customer_id, -1) = nvl(p_partner_id, nvl(msd.customer_id, -1))
  AND nvl(cust.customer_class_code, 'XXXXX') = nvl(p_customer_class_code, nvl(cust.customer_class_code, 'XXXXX')))
GROUP BY plan_id, partner_id, partner_name, customer_class_code;

      currRecord Bucket;
      l_target_service_level NUMBER;
   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      -- item,org,inst,plan service levels
      schedule_dump_header;
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord.plan_id,currRecord.instance_id,currRecord.org_id,
            currRecord.item_id, currRecord.sr_category_id,currRecord.category_name,
            currRecord.plan_name,currRecord.org_name,currRecord.item_name,
            currRecord.target_service_level;
         EXIT WHEN c1%NOTFOUND;

         currRecord.num_target_service_level := 1;
         currRecord.record_type := RECORD_TARGET_SL_VIEWBY_ITEM;

         schedule_output_record(query_id, currRecord);
         schedule_dump_record(currRecord);
      END LOOP;
      CLOSE c1;

      -- customer_id service levels
      schedule_dump_header;
      OPEN c2;
      LOOP
         FETCH c2 INTO currRecord.plan_id, currRecord.partner_id,
            currRecord.partner_name,currRecord.customer_class_code, currRecord.target_service_level;
         EXIT WHEN c2%NOTFOUND;

         currRecord.num_target_service_level := 1;
         currRecord.record_type := RECORD_TARGET_SL_VIEWBY_CUST;

         schedule_output_record(query_id, currRecord);
         schedule_dump_record(currRecord);
      END LOOP;
      CLOSE c2;
   END;

   PROCEDURE schedule_bucket_service_level(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
                                 p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                                 p_item_id NUMBER, p_partner_id NUMBER, p_customer_class_code VARCHAR2,
                                 query_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;

      l_default_category_set_id NUMBER;

      CURSOR c1 IS
    SELECT msd.plan_id AS plan_id,
       msd.sr_instance_id AS instance_id,
       msd.organization_id AS org_id,
       msd.using_assembly_item_id AS item_id,
       mic.sr_category_id AS sr_category_id,
       mic.category_name AS category_name,
       mp.compile_designator AS plan_name,
       mpo.organization_code AS org_name,
       msi.item_name AS item_name,
       trunc(msd.using_assembly_demand_date)  AS week_start_date,
       NULL AS week_next_date,
       NULL AS week_nr,
       NULL AS period_start_date,
       NULL AS period_nr,
       NULL AS bucket_type,
       'N' AS last_week_of_period,
       NULL AS achieved_ss_qty,
       NULL AS achieved_ss_dollars,
       NULL AS achieved_ss_days,
       NULL AS target_ss_qty,
       NULL AS target_ss_dollars,
       NULL AS target_ss_days,
       NULL AS userdef_ss_qty,
       NULL AS userdef_ss_dollars,
       NULL AS userdef_ss_days,
       0 AS num_safety_stock,
       nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1) AS delivered_quantity,
       msd.using_requirement_quantity * nvl(msd.probability,1) AS required_quantity,
       NULL AS target_service_level,
       0 AS num_target_service_level,
       msd.customer_id AS partner_id,
       cust.partner_name AS partner_name,
       cust.customer_class_code AS customer_class_code,
         RECORD_SERVICE_LEVEL AS record_type
  FROM msc_demands msd, msc_system_items msi,
       msc_item_categories mic, msc_plans mp, msc_plan_organizations mpo,
       msc_trading_partners cust
 WHERE mp.plan_id = p_plan_id
   AND msd.plan_id = msi.plan_id
   AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
   AND msd.sr_instance_id = msi.sr_instance_id
   AND msd.organization_id = msi.organization_id
   AND msd.using_assembly_item_id = msi.inventory_item_id
   AND msd.plan_id = mp.plan_id
   AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
   AND msi.organization_id = mic.organization_id
   AND msi.sr_instance_id = mic.sr_instance_id
   AND mic.category_set_id = l_default_category_set_id
   AND msi.inventory_item_id = mic.inventory_item_id
   AND mp.plan_id = mpo.plan_id
   AND msd.organization_id = mpo.organization_id
   AND msd.sr_instance_id = mpo.sr_instance_id
   AND mpo.sr_instance_id = nvl(p_sr_instance_id, mpo.sr_instance_id)
   AND mpo.organization_id = nvl(p_sr_tp_id, mpo.organization_id)
   AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
   AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
   AND nvl(msd.customer_id, -1) = nvl(p_partner_id, nvl(msd.customer_id, -1))
   AND nvl(cust.customer_class_code, 'XXXXX') = nvl(p_customer_class_code, nvl(cust.customer_class_code, 'XXXXX'))
   AND msd.customer_id = cust.partner_id (+)
   ORDER BY msd.plan_id,msd.sr_instance_id,msd.organization_id,msd.using_assembly_item_id,msd.customer_id;

   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               IF is_service_level_key_changed(currRecord, prevRecord) THEN
                  bucket_service_level_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
                  schedule_flush(mainschedule, query_id);
                  schedule_initialize(mainschedule, currRecord);
               ELSE
                  bucket_service_level_record(mainschedule, prevRecord, currRecord.bkt_start_date);
               END IF;
            ELSE
               schedule_initialize(mainschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               bucket_service_level_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
               schedule_flush(mainschedule, query_id);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END;

   PROCEDURE schedule_bucket_safety_stock(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
                                 p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                                 p_item_id NUMBER, query_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;

      l_default_category_set_id NUMBER;

      CURSOR c1 IS
    SELECT mss.plan_id AS plan_id, mss.sr_instance_id AS instance_id, mss.organization_id AS org_id,
       mss.inventory_item_id AS item_id,
       mic.sr_category_id AS sr_category_id, mic.category_name AS category_name,
       mp.compile_designator AS plan_name,
       mpo.organization_code AS org_name,
       msi.item_name,
       mss.period_start_date AS week_start_date,
       NULL AS week_next_date,
       NULL AS week_nr, NULL AS period_start_date, NULL AS period_nr,
       NULL AS bucket_type,
       'N' AS last_week_of_period,
       mss.safety_stock_quantity AS achieved_ss_qty,
       mss.safety_stock_quantity*msi.standard_cost
           AS achieved_ss_dollars,
       mss.achieved_days_of_supply AS achieved_ss_days,
       mss.target_safety_stock AS target_ss_qty,
       mss.target_safety_stock * msi.standard_cost
           AS target_ss_dollars,
       mss.target_days_of_supply AS target_ss_days,
       mss.user_defined_safety_stocks AS userdef_ss_qty,
       mss.user_defined_safety_stocks * msi.standard_cost
           AS userdef_ss_dollars,
       mss.user_defined_dos AS userdef_ss_days,
       0 AS num_safety_stock,
       NULL AS delivered_quantity,
       NULL AS required_quantity,
       NULL AS target_service_level,
       0 AS num_target_service_level,
       NULL AS partner_id,
       NULL AS partner_name,
       NULL AS customer_class_code,
         RECORD_SAFETY_STOCK AS record_type
     FROM msc_safety_stocks mss, msc_system_items msi, msc_item_categories mic,
          msc_plans mp, msc_plan_organizations mpo
    WHERE mss.sr_instance_id = msi.sr_instance_id
      AND mss.plan_id = msi.plan_id
      AND mss.organization_id = msi.organization_id
      AND mss.inventory_item_id = msi.inventory_item_id
      AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
      AND msi.sr_instance_id = mic.sr_instance_id
      AND msi.inventory_item_id = mic.inventory_item_id
      AND msi.organization_id = mic.organization_id
      AND mic.category_set_id = l_default_category_set_id
      AND mss.plan_id = p_plan_id
      AND mss.plan_id = mp.plan_id
      AND mp.plan_id = mpo.plan_id
      AND mss.organization_id = mpo.organization_id
      AND mss.sr_instance_id = mpo.sr_instance_id
      AND mpo.sr_instance_id = nvl(p_sr_instance_id, mpo.sr_instance_id)
      AND mpo.organization_id = nvl(p_sr_tp_id, mpo.organization_id)
      AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
      AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
   ORDER BY 1,2,3,4;

   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               IF is_safety_stock_key_changed(currRecord, prevRecord) THEN
                  bucket_safety_stock_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
                  schedule_ss_fill_gaps(mainschedule);
                  schedule_flush(mainschedule, query_id);
                  schedule_initialize(mainschedule, currRecord);
               ELSE
                  bucket_safety_stock_record(mainschedule, prevRecord, currRecord.bkt_start_date);
               END IF;
            ELSE
               schedule_initialize(mainschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               bucket_safety_stock_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
               schedule_ss_fill_gaps(mainschedule);
               schedule_flush(mainschedule, query_id);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END;

   FUNCTION validate_plan(p_plan_id NUMBER)
   RETURN BOOLEAN
   IS
      CURSOR c1(p_plan_id NUMBER) IS
      SELECT 1
        FROM msc_plans_tree_v mpt, msc_plans mp
       WHERE mpt.curr_plan_type = 4
         AND mpt.plan_id = mp.plan_id
         AND mp.plan_start_date IS NOT NULL
         AND mp.plan_id = p_plan_id;

      l_result NUMBER := NULL;
   BEGIN

      OPEN c1(p_plan_id);
      FETCH c1 INTO l_result;
      CLOSE c1;

      IF l_result = 1 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   FUNCTION get_sr_cat_id_from_cat_key(org_id VARCHAR2)
   RETURN NUMBER
   IS
      dash NUMBER;
   BEGIN
      IF org_id IS NULL THEN
         RETURN NULL;
      END IF;

      dash := INSTR(org_id, '-');

      IF dash = 0 OR dash = 1 THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR(org_id, dash + 1);
   END;

   FUNCTION get_inst_id_from_org_key(org_id VARCHAR2)
   RETURN NUMBER
   IS
      dash NUMBER;
   BEGIN
      IF org_id IS NULL THEN
         RETURN NULL;
      END IF;

      dash := INSTR(org_id, '-');

      IF dash = 0 OR dash = 1 THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR(org_id, 1, dash - 1);
   END;

   FUNCTION get_sr_tp_id_from_org_key(cat_id VARCHAR2)
   RETURN NUMBER
   IS
      dash NUMBER;
   BEGIN
      IF cat_id IS NULL THEN
         RETURN NULL;
      END IF;

      dash := INSTR(cat_id, '-');

      IF dash = 0 OR dash = 1 THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR(cat_id, dash + 1);
   END;

   FUNCTION get_inst_id_from_category_key(cat_id VARCHAR2)
   RETURN NUMBER
   IS
      dash NUMBER;
   BEGIN
      IF cat_id IS NULL THEN
         RETURN NULL;
      END IF;

      dash := INSTR(cat_id, '-');

      IF dash = 0 OR dash = 1 THEN
         RETURN NULL;
      END IF;

      RETURN SUBSTR(cat_id, 1, dash - 1);
   END;

   PROCEDURE schedule_retrieve(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
             item_id IN NUMBER, customer_id IN NUMBER, customer_class_code IN VARCHAR2)
   IS
      mainschedule       Schedule;
      sr_instance_id     NUMBER;
      sr_tp_id           NUMBER;
      sr_cat_instance_id NUMBER;
      sr_cat_id          NUMBER;
      l_planlist         PlanList;
      l_index            BINARY_INTEGER;
   BEGIN

      SELECT msc_form_query_s.nextval
        INTO query_id
      FROM dual;

      IF org_id IS NOT NULL THEN
         sr_instance_id := get_inst_id_from_org_key(org_id);
         sr_tp_id := get_sr_tp_id_from_org_key(org_id);
      END IF;

      IF cat_id IS NOT NULL THEN
         sr_cat_instance_id := get_inst_id_from_category_key(cat_id);
         sr_cat_id := get_sr_cat_id_from_cat_key(cat_id);
      END IF;

      parse_planlist(plan_id, l_planlist);
      IF l_planlist.COUNT = 0 THEN
         query_id := -1;
         RETURN;
      END IF;

      FOR l_index IN l_planlist.FIRST..l_planlist.LAST LOOP
         IF validate_plan(l_planlist(l_index)) = FALSE THEN
            query_id := -1;
            RETURN;
         END IF;

         schedule_create(mainschedule, l_planlist(l_index));

         IF customer_id IS NULL AND customer_class_code IS NULL THEN
           schedule_bucket_safety_stock(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
              sr_cat_instance_id, sr_cat_id, item_id, query_Id);
         END IF;

         schedule_bucket_service_level(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
            sr_cat_instance_id, sr_cat_id, item_id, customer_id, customer_class_code,query_Id);

         schedule_target_service_level(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
            sr_cat_instance_id, sr_cat_id, item_id, customer_id, customer_class_code,query_Id);

      END LOOP;
   END;

END;

/
