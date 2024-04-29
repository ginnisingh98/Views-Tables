--------------------------------------------------------
--  DDL for Package Body MSC_ANALYSIS_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ANALYSIS_BUDGET" AS
/*  $Header: MSCAIBB.pls 120.0 2005/05/25 18:45:05 appldev noship $ */
--
--
--
   RECORD_BUDGET        CONSTANT NUMBER := 0;
   RECORD_SERVICE_LEVEL CONSTANT NUMBER := 1;
   RECORD_TARGET_SERVICE_LEVEL CONSTANT NUMBER := 2;

   UNDEFINED_CUSTOMER_CODE CONSTANT VARCHAR2(30) := '_MISC'; -- Used in Java
   UNDEFINED_CUSTOMER_ID   CONSTANT NUMBER := -1;

   CALENDAR_TYPE_MFG CONSTANT NUMBER := 1;
   CALENDAR_TYPE_BIS CONSTANT NUMBER := 0;

   PLAN_BUCKET_WEEK CONSTANT NUMBER := 2;
   PLAN_BUCKET_PERIOD CONSTANT NUMBER := 3;

   DETAIL_LEVEL_WEEK CONSTANT NUMBER := 1;
   DETAIL_LEVEL_PERIOD CONSTANT NUMBER := 0;

   BUDGET_CONSTRAINED_OFF CONSTANT NUMBER := 2;
   BUDGET_CONSTRAINED_ON CONSTANT NUMBER := 1;

   do_debug BOOLEAN := FALSE;

   TYPE Bucket IS RECORD
   (
      -- item key data
      plan_id             NUMBER := 0,
      instance_id         NUMBER := 0,
      org_id              NUMBER := 0,
      org_name            VARCHAR2(255) := NULL,
      sr_category_id      NUMBER := 0,
      category_name       VARCHAR2(255) := NULL,
      plan_name           VARCHAR2(255) := NULL,
      -- bucket key data
      bkt_start_date      DATE := NULL,
      bkt_end_date        DATE := NULL,
      period_nr           NUMBER := 0,
      week_nr             NUMBER := 0,
      period_start_date   DATE := NULL,
      bucket_type         NUMBER := 0,
      detail_level        NUMBER := NULL,
      -- budget measures
      achieved_budget_usd NUMBER := 0,
      -- service level measures
      delivered_quantity  NUMBER := 0,
      required_quantity   NUMBER := 0,
      target_sl           NUMBER := 0,
      num_target_sl       NUMBER := 0,
      -- service level or safety stock record
      record_type         NUMBER := NULL
   );

   TYPE Schedule IS TABLE OF Bucket INDEX BY BINARY_INTEGER;
   TYPE PlanList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

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


   PROCEDURE schedule_create_bis(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, calendar_type IN NUMBER)
   IS
      CURSOR c1(p_plan_id NUMBER) IS
      SELECT pd.detail_date, mbp.START_DATE, mbp.end_date
        FROM
        (SELECT DISTINCT mbid.detail_date
           FROM msc_bis_inv_detail mbid
          WHERE mbid.plan_id = p_Plan_id
            AND (mbid.period_type IS NULL OR mbid.period_type = 0)) pd,
         msc_plans mp, msc_bis_periods mbp
       WHERE mp.plan_id = p_plan_id
         AND mp.sr_instance_id = mbp.sr_instance_id
         AND mp.organization_id = mbp.organization_id
         AND mbp.period_set_name = 'Accounting'
         AND pd.detail_date = mbp.START_DATE
      ORDER BY pd.detail_date;

      c1Rec c1%ROWTYPE;

      currentBucket Bucket;
      current_period_nr NUMBER := 1;

   BEGIN

      OPEN c1(p_plan_id);
      LOOP
         FETCH c1 INTO c1Rec;
         EXIT WHEN c1%NOTFOUND;

         -- These three are only used for MFG calendar data
         currentBucket.week_nr             := NULL;
         currentBucket.period_start_date   := c1Rec.START_DATE;
         currentBucket.bucket_type         := PLAN_BUCKET_PERIOD;
         -- These are for BIS calendar data
         currentBucket.bkt_start_date    := c1Rec.start_date;
         currentBucket.bkt_end_date      := c1Rec.end_date;

         currentBucket.period_nr := current_period_nr;

         mainschedule(current_period_nr) := currentBucket;
         current_period_nr := current_period_nr + 1;
      END LOOP;
      CLOSE c1;

   END;

   PROCEDURE schedule_create_mfg(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, calendar_type IN NUMBER)
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

      c1Rec c1%ROWTYPE;

      currentBucket Bucket;
      currentBucketNr NUMBER := 1;
      current_period_nr NUMBER := 1;
      previous_period_start_date DATE := NULL;
      current_week_nr NUMBER := 1;

   BEGIN

      OPEN c1(p_plan_id);
      LOOP
         FETCH c1 INTO c1Rec;
         EXIT WHEN c1%NOTFOUND;

         -- These three are only used for MFG calendar data
         IF c1Rec.bucket_type = PLAN_BUCKET_WEEK THEN
            currentBucket.week_nr := current_week_nr;
            current_week_nr := current_week_nr + 1;
         ELSE
            currentBucket.week_nr := NULL;
         END IF;
         currentBucket.period_start_date   := c1Rec.period_start_date;
         currentBucket.bucket_type         := c1Rec.bucket_type;
         -- These are for BIS calendar data
         currentBucket.bkt_start_date    := c1Rec.bkt_start_date;
         currentBucket.bkt_end_date      := c1Rec.bkt_end_date;

         IF currentBucket.period_start_date <> previous_period_start_date THEN
            current_period_nr := current_period_nr + 1;
         END IF;
         currentBucket.period_nr := current_period_nr;

         previous_period_start_date := currentBucket.period_start_date;
         mainschedule(currentBucketNr) := currentBucket;
         currentBucketNr := currentBucketNr + 1;
      END LOOP;
      CLOSE c1;
   END;

   PROCEDURE schedule_output_record(query_id NUMBER, aRecord Bucket)
   IS
   BEGIN
      INSERT INTO msc_form_query
         (query_id, last_update_date, last_updated_by, creation_date, created_by,
          NUMBER1, NUMBER2, NUMBER3,
          CHAR1, NUMBER4, CHAR2,
          CHAR3, DATE1, DATE2,
          NUMBER5, NUMBER6, NUMBER7,
          NUMBER8, NUMBER9, NUMBER10,
          NUMBER11, NUMBER12, NUMBER13,
          NUMBER14,DATE3)
      VALUES
         (query_id, SYSDATE, -1, SYSDATE, -1,
          aRecord.plan_id, aRecord.instance_id, aRecord.org_id,
          aRecord.org_name, aRecord.sr_category_id, aRecord.category_name,
          aRecord.plan_name, aRecord.bkt_start_date, aRecord.bkt_end_date,
          aRecord.period_nr, aRecord.achieved_budget_usd, aRecord.delivered_quantity,
          aRecord.required_quantity, aRecord.target_sl, aRecord.num_target_sl,
          aRecord.record_type, aRecord.week_nr, aRecord.bucket_type,
          aRecord.detail_level,aRecord.period_start_date);

   END;

   PROCEDURE schedule_dump_header
   IS
   BEGIN
      IF do_debug = FALSE THEN
         RETURN;
      END IF;
      dbms_output.put('plan_id,instance_id,org_id,org_name,plan_name,cat_id,cat_name,bucket_type,');
      dbms_output.put_line('detail_level,start_date,end_date,period_nr,achieved_budget_dollars,record_type,required_qty,delivered_qty,target_sl_qty,nr_target_sl,week_nr,period_start_date');
   END;

   PROCEDURE schedule_dump_record(aRecord BUCKET)
   IS
   BEGIN
      IF do_debug = FALSE THEN
         RETURN;
      END IF;
         dbms_output.put('"'||aRecord.plan_id || '","' || aRecord.instance_id || '",');
         dbms_output.put('"'|| aRecord.org_id || '",');
         DBMS_OUTPUT.put('"' || aRecord.org_name || '","' || aRecord.plan_name || '",');
         dbms_output.put('"' || aRecord.sr_category_id || '","' || aRecord.category_name || '",');
         DBMS_OUTPUT.put('"' || aRecord.bucket_type || '",');
         DBMS_OUTPUT.put('"' || aRecord.detail_level || '",');
         dbms_output.put('"' || aRecord.bkt_start_date || '",');
         dbms_output.put('"' || aRecord.bkt_end_date || '",');
         dbms_output.put('"' || aRecord.period_nr || '",');
         dbms_output.put('"' || aRecord.achieved_budget_usd || '",');
         IF aRecord.record_type = RECORD_BUDGET THEN
            dbms_output.put('"BUDGET",');
         ELSIF aRecord.record_type = RECORD_SERVICE_LEVEL THEN
            dbms_output.put('"SERVICE_LEVEL",');
         ELSIF aRecord.record_type = RECORD_TARGET_SERVICE_LEVEL THEN
            dbms_output.put('"TARGET_SL",');
         ELSE
            dbms_output.put('"NULL",');
         END IF;

         dbms_output.put('"' || aRecord.required_quantity || '",');
         dbms_output.put('"' || aRecord.delivered_quantity || '",');
         dbms_output.put('"' || aRecord.target_sl || '",');
         dbms_output.put('"' || aRecord.num_target_sl || '",');
         dbms_output.put('"' || aRecord.week_nr || '",');
         dbms_output.put_line('"' || aRecord.period_start_date || '"');
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

   PROCEDURE bucket_budget_record(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket, end_date DATE)
   IS
   BEGIN
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF aRecord.detail_level = DETAIL_LEVEL_PERIOD THEN
            IF mainschedule(i).period_start_date = aRecord.bkt_start_date THEN
               mainschedule(i).achieved_budget_usd := mainschedule(i).achieved_budget_usd + aRecord.achieved_budget_usd;
               EXIT;
            END IF;
         ELSIF is_bucket_match(mainschedule(i), aRecord) THEN
            mainschedule(i).achieved_budget_usd := mainschedule(i).achieved_budget_usd + aRecord.achieved_budget_usd;
         END IF;
      END LOOP;
   END;

   PROCEDURE bucket_service_level_record(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket)
   IS
   BEGIN

      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF is_bucket_match(mainschedule(i), aRecord) THEN
            mainschedule(i).delivered_quantity := mainschedule(i).delivered_quantity + aRecord.delivered_quantity;
            mainschedule(i).required_quantity  := mainschedule(i).required_quantity + aRecord.required_quantity;
            mainschedule(i).target_sl          := mainschedule(i).target_sl + aRecord.target_sl;
            mainschedule(i).num_target_sl      := mainschedule(i).num_target_sl + aRecord.num_target_sl;
            EXIT;
         END IF;
      END LOOP;
   END;

   PROCEDURE schedule_initialize(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket)
   IS
   BEGIN

      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         mainschedule(i).achieved_budget_usd := 0;
         mainschedule(i).delivered_quantity  := 0;
         mainschedule(i).required_quantity   := 0;
         mainschedule(i).target_sl           := 0;
         mainschedule(i).num_target_sl       := 0;
         mainschedule(i).achieved_budget_usd := 0;

         mainschedule(i).plan_id := aRecord.plan_id;
         mainschedule(i).instance_id := aRecord.instance_id;
         mainschedule(i).org_id := aRecord.org_id;
         mainschedule(i).sr_category_id := aRecord.sr_category_id;
         mainschedule(i).category_name := aRecord.category_name;
         mainschedule(i).plan_name := aRecord.plan_name;
         mainschedule(i).org_name := aRecord.org_name;
         mainschedule(i).detail_level := aRecord.detail_level;
         mainschedule(i).record_type := aRecord.record_type;

      END LOOP;

   END;

   FUNCTION is_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF currRecord.plan_id <> prevRecord.plan_id OR
         currRecord.org_id <> prevRecord.org_id OR
         currRecord.instance_id <> prevRecord.instance_id OR
         currRecord.sr_category_id <> prevRecord.sr_category_id
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

   FUNCTION is_budget_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN

      IF is_key_changed(currRecord, prevRecord) OR
         currRecord.detail_level <> prevRecord.detail_level
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

   PROCEDURE schedule_bucket_budget(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
                            p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                            query_id NUMBER, p_calendar_type NUMBER, p_abc_id VARCHAR2)
   IS
      currRecord Bucket;
      prevRecord Bucket;

      l_default_category_set_id NUMBER;

     CURSOR c1 IS
     SELECT mbid.plan_id, mbid.sr_instance_id AS instance_id, mbid.organization_id as org_id, mtp.organization_code AS org_name,
               mic.sr_category_id, mic.category_name, mp.compile_designator AS plan_name, mbid.detail_date as bkt_start_date,
               NULL AS bkt_end_date, NULL AS period_nr,
               NULL AS week_nr, NULL AS period_start_date, NULL AS bucket_type, NVL(mbid.detail_level, DETAIL_LEVEL_PERIOD) AS detail_level,
               SUM(nvl(mbid.inventory_value, 0)) AS achieved_budget_usd, NULL as delivered_quantity, 0 as required_quantity,
               NULL AS target_sl, NULL AS num_target_sl, RECORD_BUDGET AS record_type
          FROM msc_bis_inv_detail mbid, msc_system_items mis, msc_item_categories mic,
               msc_trading_partners mtp, msc_plans mp
         WHERE mbid.plan_id = p_plan_id
           AND mbid.plan_id = mp.plan_id
           AND mbid.plan_id = mis.plan_id
           AND mbid.organization_id = mis.organization_id
           AND mbid.sr_instance_id = mis.sr_instance_id
           AND mbid.inventory_item_id = mis.inventory_item_id
           AND mbid.sr_instance_id = nvl(p_sr_instance_id, mbid.sr_instance_id)
           AND mbid.organization_id = nvl(p_sr_tp_id, mbid.organization_id)
           AND NVL(mbid.period_type, CALENDAR_TYPE_BIS) = p_calendar_type
           AND mis.organization_id = mic.organization_id
           AND mis.sr_instance_id = mic.sr_instance_id
           AND mis.inventory_item_id = mic.inventory_item_id
           AND mic.category_set_id = l_default_category_set_id
           AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
           AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
           AND mis.organization_id = mtp.sr_tp_id
           AND mis.sr_instance_id = mtp.sr_instance_id
           AND mis.budget_constrained = BUDGET_CONSTRAINED_ON
           AND mtp.partner_type = 3
           AND nvl(mis.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(mis.abc_class_name, 'XXXXX'))
        GROUP BY mbid.plan_id, mbid.sr_instance_id, mbid.organization_id, mtp.organization_code,
        mic.sr_category_id, mic.category_name, mp.compile_designator, mbid.detail_date, NVL(mbid.detail_level, DETAIL_LEVEL_PERIOD)
        ORDER BY mbid.plan_id, mbid.organization_id, mbid.sr_instance_id, mtp.organization_code,
        mic.sr_category_id, mic.category_name, NVL(mbid.detail_level, DETAIL_LEVEL_PERIOD), mbid.detail_date;

   BEGIN

      l_default_category_set_id := get_cat_set_id(p_plan_id);

      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               IF is_budget_key_changed(currRecord, prevRecord) THEN
                  bucket_budget_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
                  schedule_flush(mainschedule, query_id);
                  schedule_initialize(mainschedule, currRecord);
               ELSE
                  bucket_budget_record(mainschedule, prevRecord, currRecord.bkt_start_date);
               END IF;
            ELSE
               schedule_initialize(mainschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               bucket_budget_record(mainschedule, prevRecord, mainschedule(mainschedule.LAST).bkt_start_date + 1);
               schedule_flush(mainschedule, query_id);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END;

   PROCEDURE schedule_bucket_servicelevel(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
                                  p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                                  p_abc_id VARCHAR2, query_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;

      l_default_category_set_id NUMBER;
      CURSOR c1 IS
              SELECT msd.plan_id AS plan_id,
                 msd.sr_instance_id AS instance_id,
                 msd.organization_id AS org_id,
                 mtp.organization_code AS org_name,
                 mic.sr_category_id AS sr_category_id,
                 mic.category_name AS category_name,
                 mp.compile_designator AS plan_name,
                 trunc(msd.using_assembly_demand_date)  AS bkt_start_date,
                 NULL AS bkt_end_date,
                 NULL AS period_nr,
                 NULL AS week_nr, NULL AS period_start_date, NULL AS bucket_type, NULL AS detail_level,
                 0 AS achieved_budget_usd,
                 sum(nvl(msd.old_demand_quantity,0)*
                  nvl(msd.probability,1)) AS delivered_quantity,
                 sum(nvl(msd.using_requirement_quantity, 0)*
                  nvl(msd.probability,1)) AS required_quantity,
                 sum(nvl(msd.service_level, 50)) AS target_service_level,
                 count(*) AS num_target_service_level,
                  RECORD_SERVICE_LEVEL AS record_type
            FROM msc_plans mp, msc_plan_organizations mpo, msc_demands msd, msc_system_items msi,
                 msc_item_categories mic, msc_trading_partners mtp
           WHERE mp.plan_id = p_plan_id
             AND mp.plan_id = mpo.plan_id
             AND mpo.plan_id = msd.plan_id
             AND mpo.sr_instance_id = msd.sr_instance_id
             AND mpo.organization_id = msd.organization_id
             AND msd.plan_id = msi.plan_id
             AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
             AND msd.sr_instance_id = msi.sr_instance_id
             AND msd.organization_id = msi.organization_id
             AND msd.using_assembly_item_id = msi.inventory_item_id
             AND msd.plan_id = mp.plan_id
             AND msi.organization_id = mic.organization_id
             AND msi.sr_instance_id = mic.sr_instance_id
             AND msi.budget_constrained = BUDGET_CONSTRAINED_ON
             AND mic.category_set_id = l_default_category_set_id
             AND msi.inventory_item_id = mic.inventory_item_id
             AND msd.organization_id = mtp.sr_tp_id
             AND msd.sr_instance_id = mtp.sr_instance_id
             AND mtp.sr_instance_id = nvl(p_sr_instance_id, mtp.sr_instance_id)
             AND mtp.sr_tp_id = nvl(p_sr_tp_id, mtp.sr_tp_id)
             AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
             AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
             AND nvl(msi.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(msi.abc_class_name, 'XXXXX'))
             GROUP BY msd.plan_id, msd.sr_instance_id, msd.organization_id, mtp.organization_code,
             mic.sr_category_id, mic.category_name, mp.compile_designator, trunc(msd.using_assembly_demand_date)
             ORDER BY msd.plan_id, msd.organization_id, msd.sr_instance_id, mtp.organization_code,
             mic.sr_category_id, mic.category_name, trunc(msd.using_assembly_demand_date);
   BEGIN

      l_default_category_set_id := get_cat_set_id(p_plan_id);

      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               bucket_service_level_record(mainschedule, prevRecord);
               IF is_key_changed(currRecord, prevRecord) THEN
                  schedule_flush(mainschedule, query_id);
                  schedule_initialize(mainschedule, currRecord);
               END IF;
            ELSE
               schedule_initialize(mainschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               bucket_service_level_record(mainschedule, prevRecord);
               schedule_flush(mainschedule, query_id);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END;

   PROCEDURE schedule_target_service_level(
      mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER, p_sr_instance_id NUMBER,
      p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
      p_abc_id VARCHAR2, p_calendar_type NUMBER, query_id NUMBER)
   IS
      l_default_category_set_id NUMBER;

      CURSOR c1 IS
SELECT plan_id, instance_id, org_id, sr_category_id, category_name, plan_name, org_name, SUM(target_sl) AS target_sl, COUNT(*) AS num_target_sl
FROM
(
SELECT plan_id, instance_id, org_id, sr_category_id, category_name, plan_name, org_name, item_id, item_name, AVG(target_sl) AS target_sl
FROM
(
SELECT plan_id, instance_id, org_id,
      sr_category_id, category_name,
      plan_name,
      org_name, item_id, item_name,
      nvl(get_customer_target_sl(partner_id) ,
      msc_get_bis_values.service_target(plan_id,instance_id,org_id,item_id)) AS target_sl
FROM
(
SELECT DISTINCT msi.plan_id AS plan_id, msi.sr_instance_id AS instance_id, msi.organization_id AS org_id,
      msi.inventory_item_id AS item_id,
      mic.sr_category_id AS sr_category_id, mic.category_name AS category_name,
      mp.compile_designator AS plan_name,
      mtp.organization_code AS org_name,
      msi.item_name AS item_name, msd.customer_id AS partner_id
 FROM msc_plans mp, msc_system_items msi, msc_item_categories mic, msc_trading_partners mtp,
(SELECT demands.plan_id, demands.sr_instance_id, demands.organization_id, demands.using_assembly_item_id,
       demands.customer_id, demands.demand_id
  FROM msc_demands demands
WHERE demands.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)) msd,
(SELECT kpi.inventory_item_id, kpi.sr_instance_id, kpi.organization_id, kpi.plan_id
  FROM msc_bis_inv_detail kpi
 WHERE NVL(kpi.period_type, CALENDAR_TYPE_BIS) = p_calendar_type
   AND kpi.plan_id = p_plan_id) mbid
WHERE mp.plan_id = p_plan_id
  AND mp.plan_id = msi.plan_id
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
  AND msi.inventory_item_id = mbid.inventory_item_id (+)
  AND msi.organization_id = mbid.organization_id (+)
  AND msi.sr_instance_id = mbid.sr_instance_id (+)
  AND msi.inventory_item_id = mbid.inventory_item_id (+)
  AND msi.plan_id = mbid.plan_id (+)
  AND msi.sr_instance_id = nvl(p_sr_instance_id, msi.sr_instance_id)
  AND msi.organization_id = nvl(p_sr_tp_id, msi.organization_id)
  AND msi.plan_id = msd.plan_id (+)
  AND msi.sr_instance_id = msd.sr_instance_id (+)
  AND msi.organization_id = msd.organization_id (+)
  AND msi.inventory_item_id = msd.using_assembly_item_id (+)
  AND msi.budget_constrained = BUDGET_CONSTRAINED_ON
  AND nvl(msi.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(msi.abc_class_name, 'XXXXX'))
  AND (mbid.plan_id IS NOT NULL OR msd.demand_id IS NOT NULL)
))
GROUP BY plan_id, instance_id, org_id,
      sr_category_id, category_name,
      plan_name,
      org_name, item_id, item_name)
GROUP BY plan_id, instance_id, org_id,
      sr_category_id, category_name,
      plan_name,
      org_name;

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
            currRecord.sr_category_id,currRecord.category_name,
            currRecord.plan_name,currRecord.org_name,
            currRecord.target_sl, currRecord.num_target_sl;
         EXIT WHEN c1%NOTFOUND;

         currRecord.record_type := RECORD_TARGET_SERVICE_LEVEL;

         schedule_output_record(query_id, currRecord);
         schedule_dump_record(currRecord);
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

   FUNCTION get_sr_tp_id_from_org_key(org_id VARCHAR2)
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

   FUNCTION get_sr_cat_id_from_cat_key(cat_id VARCHAR2)
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

   FUNCTION get_inst_id_from_cat_key(cat_id VARCHAR2)
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

   PROCEDURE schedule_retrieve(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
             abc_id IN VARCHAR2, calendar_type IN NUMBER)
   IS
      mainschedule       Schedule;
      sr_instance_id     NUMBER;
      sr_tp_id           NUMBER;
      sr_cat_instance_id NUMBER;
      sr_cat_id          NUMBER;
      l_planlist         PlanList;

   BEGIN

      SELECT msc_form_query_s.nextval
        INTO query_id
      FROM dual;

      IF org_id IS NOT NULL THEN
         sr_instance_id := get_inst_id_from_org_key(org_id);
         sr_tp_id := get_sr_tp_id_from_org_key(org_id);
      END IF;

      IF cat_id IS NOT NULL THEN
         sr_cat_instance_id := get_inst_id_from_cat_key(cat_id);
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

         IF calendar_type = CALENDAR_TYPE_BIS THEN
            schedule_create_bis(mainschedule, l_planlist(l_index), calendar_type);
         ELSE
            schedule_create_mfg(mainschedule, l_planlist(l_index), calendar_type);
         END IF;

         schedule_bucket_budget(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
            sr_cat_instance_id, sr_cat_id, query_Id, calendar_type, abc_id);

         schedule_bucket_servicelevel(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
           sr_cat_instance_id, sr_cat_id, abc_id, query_Id);

         schedule_target_service_level(mainschedule, l_planlist(l_index), sr_instance_id, sr_tp_id,
           sr_cat_instance_id, sr_cat_id, abc_id, calendar_type, query_id);

      END LOOP;
   END;

END;

/
