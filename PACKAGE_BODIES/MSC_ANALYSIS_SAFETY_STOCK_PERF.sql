--------------------------------------------------------
--  DDL for Package Body MSC_ANALYSIS_SAFETY_STOCK_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ANALYSIS_SAFETY_STOCK_PERF" AS
/*  $Header: MSCIORB.pls 120.11.12010000.4 2009/12/24 00:52:03 minduvad ship $ */
--
-- Preprocesses safety stock/service level data for subsequent digestion in
-- Inventory Optimization's Analysis View "Safety Stock and Service Level Report"
--
--

   RECORD_SAFETY_STOCK         CONSTANT NUMBER := 0;
   RECORD_SERVICE_LEVEL        CONSTANT NUMBER := 1;
   RECORD_INVENTORY_VALUE      CONSTANT NUMBER := 2;
   RECORD_SERVICE_LEVEL_BRKDOWN        CONSTANT NUMBER := 3;
   RECORD_COST_BRKDOWN        CONSTANT NUMBER := 4;


   UNDEFINED_CUSTOMER_CODE CONSTANT VARCHAR2(30) := '_MISC'; -- Used in Java
   UNDEFINED_CUSTOMER_ID   CONSTANT NUMBER := -1;

   DETAIL_LEVEL_WEEK CONSTANT NUMBER := 1;
   DETAIL_LEVEL_PERIOD CONSTANT NUMBER := 0;

   BUDGET_CONSTRAINED_OFF CONSTANT NUMBER := 2;
   BUDGET_CONSTRAINED_ON CONSTANT NUMBER := 1;

   CALENDAR_TYPE_MFG CONSTANT NUMBER := 1;
   CALENDAR_TYPE_BIS CONSTANT NUMBER := 0;

   g_user_id number;

   do_debug BOOLEAN := TRUE;
   g_perf_prof_on BOOLEAN := TRUE;

    TYPE CurTyp IS REF CURSOR;


   TYPE PlanList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 TYPE Bucket IS RECORD
   (
      -- item key
      plan_id             NUMBER := 0,
      instance_id         NUMBER := 0,
      org_id              NUMBER := 0,
      item_id             NUMBER := 0,
      sr_category_inst_id NUMBER := 0,
      sr_category_id      NUMBER := 0,
      category_name       VARCHAR2(255) := NULL,
      -- bucket data
      bkt_start_date      DATE := NULL,
      bkt_end_date        DATE := NULL,
      period_start_date   DATE := NULL,
      last_week_of_period VARCHAR2(1) := 'N',
      -- safety stock measures
      achieved_ss_qty     NUMBER := 0,
      achieved_ss_dollars NUMBER := 0,
      achieved_ss_days    NUMBER := 0,
      target_ss_qty       NUMBER := 0,
      target_ss_dollars   NUMBER := 0,
      target_ss_days      NUMBER := 0,
      userdef_ss_qty      NUMBER := 0,
      userdef_ss_dollars  NUMBER := 0,
      userdef_ss_days     NUMBER := 0,
      nr_ss_records       NUMBER := 0,
      inv_value_dollars   NUMBER := 0,
      period_type         NUMBER := 0,
      total_unpooled_safety_stock number := 0,
      demand_var_ss_percent number := 0,
      mfg_ltvar_ss_percent number := 0,
      transit_ltvar_ss_percent number := 0,
      sup_ltvar_ss_percent number := 0,
      -- service level measures
      delivered_quantity  NUMBER := 0, -- Achieved Service Level = delivered / required
      required_quantity   NUMBER := 0,
      target_service_level NUMBER := 0,
      nr_sl_records       NUMBER := 0,  -- # demand records for service level
      partner_id          NUMBER := NULL,
      customer_class_code VARCHAR2(30) := NULL,
      -- service level or safety stock record
      record_type         NUMBER := NULL
   );

   TYPE Schedule IS TABLE OF Bucket INDEX BY BINARY_INTEGER;

  PROCEDURE put_line (p_msg varchar2) IS
  BEGIN
    --insert into msc_test values (p_msg);
    --commit;
    --dbms_output.put_line(p_msg);
    null;
  END put_line;

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

  function get_plan_type(p_plan_id number) return number is
    cursor c_plan (p_plan_id number) is
    select plan_type
    from msc_plans
    where plan_id = p_plan_id;

    l_plan_type number;
  begin

    open c_plan(p_plan_id);
    fetch c_plan into l_plan_type;
    close c_plan;

    return l_plan_type;
  end get_plan_type;


   FUNCTION get_cat_set_id(p_plan_id number) RETURN NUMBER
   IS
      l_cat_set_id NUMBER;
      l_def_pref_id  number;
      l_plan_type number;
   BEGIN
      -- Get category set from profile option for IO
      -- SELECT fnd_profile.value('MSR_BUDGET_CATEGORY_SET') INTO l_cat_set_id FROM dual;
    l_plan_type := get_plan_type(p_plan_id);
    l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
    l_cat_set_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);
    return l_cat_set_id;

   END get_cat_set_id;

   PROCEDURE schedule_create_weeks(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER)
   IS
      CURSOR c1(p_plan_id NUMBER) IS
      SELECT mp.plan_id, mp.compile_designator, mtp.calendar_code, mpb.bkt_start_date, mpb.bkt_end_date,
             mpsd.period_start_date
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
        AND mpb.bucket_type = 2
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
         IF currentBucket.period_start_date <> previous_period_start_date THEN
            -- Need the last week of the period for collapsing ss across weeks
            IF current_week_nr > 1 THEN
               mainschedule(current_week_nr - 1).last_week_of_period := 'Y';
            END IF;
         END IF;

         mainschedule(current_week_nr) := currentBucket;

         previous_period_start_date := currentBucket.period_start_date;
         current_week_nr := current_week_nr + 1;
      END LOOP;
      CLOSE c1;

   END;

   PROCEDURE schedule_create_periods(mainschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER)
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
        AND mpb.bucket_type IN (2,3)
        AND mpb.sr_instance_id = mpsd.sr_instance_id
        AND mpsd.exception_set_id = mtp.calendar_exception_set_id
        AND mpsd.calendar_code = mtp.calendar_code
        AND (mpb.bkt_start_date >= mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date)
      ORDER BY mpb.bkt_start_date;

      currentBucket Bucket;
      currentPosition BINARY_INTEGER := 1;
      c1Rec c1%ROWTYPE;
      previous_period_start_date DATE := NULL;
      current_period_nr NUMBER := 0;

   BEGIN

      OPEN c1(p_plan_id);
      LOOP
         FETCH c1 INTO c1Rec;
         EXIT WHEN c1%NOTFOUND;

         IF c1Rec.period_start_date <> previous_period_start_date OR
            previous_period_start_date IS NULL
         THEN
            current_period_nr := current_period_nr + 1;
            currentBucket.bkt_start_date    := c1Rec.bkt_start_date;
            currentBucket.bkt_end_date      := c1Rec.bkt_end_date;
            currentBucket.period_start_date := c1Rec.period_start_date;
            mainschedule(current_period_nr) := currentBucket;
         END IF;

         IF c1Rec.period_start_date = previous_period_start_date THEN
            mainschedule(current_period_nr).bkt_end_date := c1Rec.bkt_end_date;
         END IF;

         previous_period_start_date := c1Rec.period_start_date;

      END LOOP;
      CLOSE c1;
   END;


   PROCEDURE schedule_initialize_bkt(target IN OUT NOCOPY Bucket, template Bucket)
   IS
   BEGIN
      target.achieved_ss_qty     := 0;
      target.achieved_ss_dollars := 0;
      target.achieved_ss_days    := 0;
      target.target_ss_qty       := 0;
      target.target_ss_dollars   := 0;
      target.target_ss_days      := 0;
      target.userdef_ss_qty      := 0;
      target.userdef_ss_dollars  := 0;
      target.userdef_ss_days     := 0;
      target.delivered_quantity  := 0;
      target.required_quantity   := 0;
      target.target_service_level := 0;
      target.total_unpooled_safety_stock := 0;
      target.demand_var_ss_percent := 0;
      target.mfg_ltvar_ss_percent := 0;
      target.transit_ltvar_ss_percent := 0;
      target.sup_ltvar_ss_percent := 0;
      target.nr_sl_records := 0;
      target.nr_ss_records := 0;

      target.plan_id := template.plan_id;
      target.instance_id := template.instance_id;
      target.org_id := template.org_id;
      target.sr_category_inst_id := template.sr_category_inst_id;
      target.sr_category_id := template.sr_category_id;
      target.category_name := template.category_name;
      target.item_id        := template.item_id;
      target.partner_id := template.partner_id;
      target.record_type := template.record_type;
      target.customer_class_code := template.customer_class_code;
      target.period_type := template.period_type;
   END;

   PROCEDURE schedule_initialize(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket)
   IS
      l_target_service_level NUMBER;
   BEGIN
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         schedule_initialize_bkt(mainschedule(i), aRecord);
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
      l_prev_total_unpooled_ss number;
      l_prev_nr_ss_records NUMBER := NULL;

   BEGIN
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR currentIndex IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF mainschedule(currentIndex).nr_ss_records IS NULL AND l_prev_nr_ss_records IS NOT NULL THEN
            mainschedule(currentIndex).userdef_ss_qty := l_prev_userdef_ss_qty;
            mainschedule(currentIndex).userdef_ss_days := l_prev_userdef_ss_days;
            mainschedule(currentIndex).userdef_ss_dollars := l_prev_userdef_ss_dollars;
            mainschedule(currentIndex).achieved_ss_qty := l_prev_achieved_ss_qty;
            mainschedule(currentIndex).achieved_ss_days := l_prev_achieved_ss_days;
            mainschedule(currentIndex).achieved_ss_dollars := l_prev_achieved_ss_dollars;
            mainschedule(currentIndex).target_ss_qty := l_prev_target_ss_qty;
            mainschedule(currentIndex).target_ss_days := l_prev_target_ss_days;
            mainschedule(currentIndex).target_ss_dollars := l_prev_target_ss_dollars;
            mainschedule(currentIndex).total_unpooled_safety_stock := l_prev_total_unpooled_ss;
            mainschedule(currentIndex).nr_ss_records := l_prev_nr_ss_records;
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
         l_prev_total_unpooled_ss   := mainschedule(currentIndex).total_unpooled_safety_stock;
         l_prev_nr_ss_records    := mainschedule(currentIndex).nr_ss_records;
      END LOOP;
   END schedule_ss_fill_gaps;

   PROCEDURE schedule_aggregate_output(aRecord Bucket, periodschedule BOOLEAN)
   IS
      l_achieved_service_level NUMBER;
      l_target_service_level NUMBER;
      l_week_start_date DATE;
      l_week_nr NUMBER;
   BEGIN

      IF aRecord.record_type = RECORD_SAFETY_STOCK THEN
         IF aRecord.nr_ss_records = 0 THEN
            RETURN;
         END IF;
      END IF;

      IF aRecord.record_type = RECORD_SERVICE_LEVEL THEN
         IF aRecord.nr_sl_records = 0 THEN
            RETURN;
         ELSE
            l_target_service_level := aRecord.target_service_level / aRecord.nr_sl_records;
         END IF;
      END IF;

      IF nvl(aRecord.required_quantity, 0) = 0 THEN
         l_achieved_service_level := NULL;
      ELSE
         l_achieved_service_level := aRecord.delivered_quantity * 100 / aRecord.required_quantity;
      END IF;

      IF periodschedule THEN
         l_week_start_date := NULL;
      ELSE
         l_week_start_date := aRecord.bkt_start_date;
      END IF;

      INSERT INTO msc_analysis_aggregate
      (
         plan_id,
         record_type,
         safety_stock_qty,
         safety_stock_dollars,
         safety_stock_dos,
         target_safety_stock_qty,
         target_safety_stock_dollars,
         target_safety_stock_dos,
         userdef_safety_stock_qty,
         userdef_safety_stock_dollars,
         userdef_safety_stock_dos,
         total_unpooled_safety_stock,
         demand_var_ss_percent,
         mfg_ltvar_ss_percent,
         transit_ltvar_ss_percent,
         sup_ltvar_ss_percent,
         achieved_service_level,
         target_service_level,
         inventory_value_dollars,
         period_type,
         week_start_date,
         period_start_date,
         sr_instance_id,
         organization_id,
         sr_cat_instance_id,
         sr_category_id,
         category_name,
         inventory_item_id,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 last_update_login
      )
      VALUES
      (
         aRecord.plan_id,
         aRecord.record_type,
         aRecord.achieved_ss_qty,
         aRecord.achieved_ss_dollars,
         aRecord.achieved_ss_days,
         aRecord.target_ss_qty,
         aRecord.target_ss_dollars,
         aRecord.target_ss_days,
         aRecord.userdef_ss_qty,
         aRecord.userdef_ss_dollars,
         aRecord.userdef_ss_days,
         aRecord.total_unpooled_safety_stock,
         aRecord.demand_var_ss_percent,
         aRecord.mfg_ltvar_ss_percent,
         aRecord.transit_ltvar_ss_percent,
         aRecord.sup_ltvar_ss_percent,
         l_achieved_service_level,
         l_target_service_level,
         NULL,
         CALENDAR_TYPE_MFG,
         l_week_start_date,
         aRecord.period_start_date,
         aRecord.instance_id,
         aRecord.org_id,
         aRecord.sr_category_inst_id,
         aRecord.sr_category_id,
         aRecord.category_name,
         aRecord.item_id,
	 sysdate,
	 g_user_id,
	 sysdate,
	 g_user_id,
	 to_number(null)
      );

   END;

   PROCEDURE schedule_output_record(query_id NUMBER, aRecord IN OUT NOCOPY Bucket, periodschedule BOOLEAN DEFAULT FALSE)
   IS
      l_achieved_service_level NUMBER;
      l_target_service_level NUMBER;
      l_bkt_start_date DATE;
      l_bkt_end_date DATE;
      l_week_nr NUMBER;
   BEGIN

      IF aRecord.record_type = RECORD_SAFETY_STOCK THEN
         IF aRecord.nr_ss_records = 0 THEN
            RETURN;
         END IF;
      END IF;

      IF aRecord.record_type = RECORD_SERVICE_LEVEL THEN
         IF aRecord.nr_sl_records = 0 THEN
            RETURN;
         ELSE
            aRecord.target_service_level := aRecord.target_service_level / aRecord.nr_sl_records;
            aRecord.nr_sl_records := 1;
         END IF;
      END IF;

      IF nvl(aRecord.required_quantity, 0) = 0 THEN
         l_achieved_service_level := NULL;
      ELSE
         l_achieved_service_level := aRecord.delivered_quantity * 100 / aRecord.required_quantity;
      END IF;

      l_bkt_start_date := aRecord.bkt_start_date;
      l_bkt_end_date := aRecord.bkt_end_date;

      IF periodschedule THEN
         l_bkt_start_date := NULL;
         l_bkt_end_date := NULL;
      END IF;

      INSERT INTO msc_form_query
         (query_id, last_update_date, last_updated_by,creation_date, created_by,
          NUMBER1,NUMBER2,NUMBER3,
          NUMBER4,NUMBER5,CHAR1,
          DATE1,DATE2,DATE3,
          NUMBER9, NUMBER10, NUMBER11,
          NUMBER12,NUMBER13,NUMBER14,
          NUMBER15,NUMBER16,PROGRAM_ID,
          PROGRAM_APPLICATION_ID, REQUEST_ID,
          LAST_UPDATE_LOGIN, NUMBER7,
          CHAR7, CHAR6, char11, char12, char13, char14, char15)
      VALUES
         (query_id, SYSDATE, -1, SYSDATE, aRecord.record_type,
          aRecord.plan_id, aRecord.instance_id, aRecord.org_id,
          aRecord.item_id, aRecord.sr_category_id, aRecord.category_name,
          l_bkt_start_date,l_bkt_end_date, aRecord.period_start_date,
          aRecord.achieved_ss_qty,aRecord.achieved_ss_dollars,aRecord.achieved_ss_days,
          aRecord.target_ss_qty,aRecord.target_ss_dollars,aRecord.target_ss_days,
          aRecord.userdef_ss_qty,aRecord.userdef_ss_dollars,aRecord.userdef_ss_days,
          l_achieved_service_level, aRecord.sr_category_inst_id,
          aRecord.target_service_level, aRecord.period_type,
          aRecord.partner_id, aRecord.customer_class_code,
          aRecord.total_unpooled_safety_stock, aRecord.demand_var_ss_percent,
	  aRecord.mfg_ltvar_ss_percent, aRecord.transit_ltvar_ss_percent, aRecord.sup_ltvar_ss_percent);
   END;

   PROCEDURE schedule_flush(mainschedule IN OUT NOCOPY Schedule, query_id NUMBER, periodschedule BOOLEAN DEFAULT FALSE)
   IS
   BEGIN
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         schedule_output_record(query_id, mainschedule(i), periodschedule);
         -- schedule_dump_record(mainschedule(i));
      END LOOP;
   END;

   PROCEDURE schedule_aggregate_flush(mainschedule Schedule, periodschedule BOOLEAN DEFAULT FALSE)
   IS
   BEGIN
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         schedule_aggregate_output(mainschedule(i), periodschedule);
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
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF is_bucket_match(mainschedule(i), aRecord) THEN
            mainschedule(i).delivered_quantity := mainschedule(i).delivered_quantity + aRecord.delivered_quantity;
            mainschedule(i).required_quantity := mainschedule(i).required_quantity + aRecord.required_quantity;
            mainschedule(i).target_service_level := mainschedule(i).target_service_level + aRecord.target_service_level;
            mainschedule(i).nr_sl_records := mainschedule(i).nr_sl_records + aRecord.nr_sl_records;
            RETURN;
         END IF;
      END LOOP;
   END bucket_service_level_record;


   PROCEDURE bucket_ss_copy(target IN OUT NOCOPY Bucket, src Bucket)
   IS
   BEGIN
      IF src.achieved_ss_qty IS NOT NULL THEN
         target.achieved_ss_qty := src.achieved_ss_qty;
         IF src.achieved_ss_days > target.achieved_ss_days THEN
            target.achieved_ss_days := src.achieved_ss_days;
         END IF;
         target.achieved_ss_dollars := src.achieved_ss_dollars;
      END IF;

      IF src.target_ss_qty IS NOT NULL THEN
         target.target_ss_qty := src.target_ss_qty;
         IF src.target_ss_days > target.target_ss_days THEN
            target.target_ss_days := src.target_ss_days;
         END IF;
         target.target_ss_dollars := src.target_ss_dollars;
      END IF;

      IF src.userdef_ss_qty IS NOT NULL OR src.userdef_ss_days IS NOT NULL THEN
         target.userdef_ss_qty := src.userdef_ss_qty;
         IF src.userdef_ss_days > target.userdef_ss_days THEN
            target.userdef_ss_days := src.userdef_ss_days;
         END IF;
         target.userdef_ss_dollars := src.userdef_ss_dollars;
      END IF;

      --pabram1111
      IF src.demand_var_ss_percent IS NOT NULL THEN
        target.demand_var_ss_percent := src.demand_var_ss_percent;
      end if;

      IF src.mfg_ltvar_ss_percent IS NOT NULL THEN
        target.mfg_ltvar_ss_percent := src.mfg_ltvar_ss_percent;
      end if;

      IF src.transit_ltvar_ss_percent IS NOT NULL THEN
        target.transit_ltvar_ss_percent := src.transit_ltvar_ss_percent;
      end if;
      IF src.sup_ltvar_ss_percent IS NOT NULL THEN
        target.sup_ltvar_ss_percent := src.sup_ltvar_ss_percent;
      end if;

      IF src.total_unpooled_safety_stock IS NOT NULL THEN
        target.total_unpooled_safety_stock := src.total_unpooled_safety_stock;
      end if;

      target.nr_ss_records := target.nr_ss_records + 1; -- Weight for DOS
   END bucket_ss_copy;

   PROCEDURE bucket_safety_stock_record(mainschedule IN OUT NOCOPY Schedule, aRecord Bucket, end_date DATE)
   IS
   BEGIN
      if (mainschedule.count = 0 ) then
        return;
      end if;
      FOR i IN mainschedule.FIRST..mainschedule.LAST LOOP
         IF is_bucket_match(mainschedule(i), aRecord) THEN
            bucket_ss_copy(mainschedule(i), aRecord);
         END IF;
      END LOOP;
   END bucket_safety_stock_record;

   FUNCTION is_service_level_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF currRecord.plan_id <> prevRecord.plan_id OR
         nvl(currRecord.org_id, 0) <> nvl(prevRecord.org_id, 0) OR
         nvl(currRecord.instance_id, 0) <> nvl(prevRecord.instance_id, 0) OR
         nvl(currRecord.item_id, 0) <> nvl(prevRecord.item_id, 0) OR
         nvl(currRecord.sr_category_inst_id, -1) <> nvl(prevRecord.sr_category_inst_id, -1) OR
         nvl(currRecord.sr_category_id, -1) <> nvl(prevRecord.sr_category_id, -1) OR
         nvl(currRecord.partner_id, -2) <> nvl(prevRecord.partner_id, -2) OR
         nvl(currRecord.customer_class_code, 'XXXX') <> nvl(prevRecord.customer_class_code, 'XXXX')
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END is_service_level_key_changed;

   FUNCTION is_safety_stock_key_changed(currRecord IN Bucket, prevRecord IN Bucket)
   RETURN BOOLEAN
   IS
   BEGIN
      IF currRecord.plan_id <> prevRecord.plan_id OR
         NVL(currRecord.org_id, -1) <> NVL(prevRecord.org_id, -1) OR
         NVL(currRecord.instance_id, -1) <> NVL(prevRecord.instance_id, -1) OR
         NVL(currRecord.item_id, -1) <> NVL(prevRecord.item_id, -1) OR
         NVL(currRecord.sr_category_inst_id, 0) <> NVL(prevRecord.sr_category_inst_id, 0) OR
         NVL(currRecord.sr_category_id, 0) <> NVL(prevRecord.sr_category_id, 0)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END is_safety_stock_key_changed;


   PROCEDURE schedule_bucket_service_level(weekschedule IN OUT NOCOPY Schedule, periodschedule IN OUT NOCOPY Schedule,
                                 p_plan_id NUMBER, p_sr_instance_id NUMBER,
                                 p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                                 p_item_id NUMBER, p_partner_id NUMBER, p_customer_class_code VARCHAR2,
                                 p_abc_id VARCHAR2, query_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;
      l_start_date DATE;
      l_end_date DATE;

      l_default_category_set_id NUMBER;

      CURSOR c1 IS
    SELECT msd.plan_id AS plan_id,
       msd.sr_instance_id AS instance_id,
       msd.organization_id AS org_id,
       msd.inventory_item_id AS item_id,
       mic.sr_instance_id AS sr_category_inst_id,
       mic.sr_category_id AS sr_category_id,
       mic.category_name AS category_name,
       trunc(msd.using_assembly_demand_date)  AS week_start_date,
       NULL AS week_next_date,
       NULL AS period_start_date,
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
       0 AS nr_ss_records,
       NULL AS inv_value_dollars,
       CALENDAR_TYPE_MFG AS period_type,
       NULL AS total_unpooled_safety_stock,
       NULL AS demand_var_ss_percent,
       NULL AS mfg_ltvar_ss_percent,
       NULL AS transit_ltvar_ss_percent,
       NULL AS sup_ltvar_ss_percent,
       sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) AS delivered_quantity,
       sum(nvl(msd.using_requirement_quantity, 0) * nvl(msd.probability,1)) AS required_quantity,
       sum(nvl(msd.service_level, 50)) AS target_service_level,
       count(*) AS nr_sl_records,
       decode(GROUPING(msd.customer_id), 1, NULL, nvl(msd.customer_id, UNDEFINED_CUSTOMER_ID)) AS partner_id,
       decode(GROUPING(cust.customer_class_code), 1, NULL, NVL(cust.customer_class_code, UNDEFINED_CUSTOMER_CODE)) AS customer_class_code,
       RECORD_SERVICE_LEVEL AS record_type
  FROM msc_demands msd, msc_system_items msi,
       msc_item_categories mic, msc_plans mp, msc_plan_organizations mpo, msc_trading_partners cust
 WHERE mp.plan_id = p_plan_id
   AND msd.plan_id = msi.plan_id
   AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
   AND trunc(msd.using_assembly_demand_date) between l_start_date AND l_end_date
   AND msd.sr_instance_id = msi.sr_instance_id
   AND msd.organization_id = msi.organization_id
   AND msd.inventory_item_id = msi.inventory_item_id
   AND msd.plan_id = mp.plan_id
   AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
   AND msi.organization_id = mic.organization_id
   AND msi.sr_instance_id = mic.sr_instance_id
   AND mpo.sr_instance_id = nvl(p_sr_instance_id, mpo.sr_instance_id)
   AND mpo.organization_id = nvl(p_sr_tp_id, mpo.organization_id)
   AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
   AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
   AND mic.category_set_id = l_default_category_set_id
   AND msi.inventory_item_id = mic.inventory_item_id
   AND nvl(msi.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(msi.abc_class_name, 'XXXXX'))
   AND mp.plan_id = mpo.plan_id
   AND msd.organization_id = mpo.organization_id
   AND msd.sr_instance_id = mpo.sr_instance_id
   AND msd.customer_id = cust.partner_id (+)
GROUP BY msd.plan_id, mp.compile_designator, trunc(msd.using_assembly_demand_date) ,
CUBE (msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name,
      msd.customer_id, cust.customer_class_code)
HAVING (
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(msd.customer_id) = 0 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 0 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 1 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 1 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 0 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 0 AND GROUPING(cust.customer_class_code) = 0 OR
 GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 1 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 1 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 1 OR
 GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(msd.customer_id) = 1 AND GROUPING(cust.customer_class_code) = 0
)
   ORDER BY 1,2,3,4, 5, 6, 28, 29, 8;

   aNumber NUMBER;

   CURSOR c2 IS
      SELECT curr_start_date, curr_cutoff_date
         FROM msc_plans
      WHERE plan_id = p_plan_id;

   c2Rec c2%ROWTYPE;

   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      OPEN c2;
      FETCH c2 INTO c2Rec;

      if (weekschedule.count = 0) then
         l_start_date := c2Rec.curr_start_date;
      else
         l_start_date := weekschedule(weekschedule.FIRST).bkt_start_date;
      end if;
      if (periodschedule.count = 0) then
         l_end_date := c2Rec.curr_cutoff_date;
      else
         l_end_date := periodschedule(periodschedule.LAST).bkt_end_date;
      end if;
      CLOSE c2;

      prevRecord.record_type := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.record_type IS NOT NULL THEN -- prev record exists
               IF is_service_level_key_changed(currRecord, prevRecord) THEN
                  IF (weekschedule.count = 0) THEN
                     null;
                  ELSE
                     bucket_service_level_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
                  END IF;
                  IF (periodschedule.count = 0) THEN
                     null;
                  ELSE
                     bucket_service_level_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
                  END IF;
                  schedule_flush(weekschedule, query_id);
                  schedule_flush(periodschedule, query_id, TRUE);
                  schedule_initialize(weekschedule, currRecord);
                  schedule_initialize(periodschedule, currRecord);
               ELSE
                  bucket_service_level_record(weekschedule, prevRecord, currRecord.bkt_start_date);
                  bucket_service_level_record(periodschedule, prevRecord, currRecord.bkt_start_date);
               END IF;
            ELSE
               schedule_initialize(weekschedule, currRecord);
               schedule_initialize(periodschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.record_type IS NOT NULL THEN
               bucket_service_level_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
               bucket_service_level_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
               schedule_flush(weekschedule, query_id);
               schedule_flush(periodschedule, query_id, TRUE);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END schedule_bucket_service_level;


PROCEDURE schedule_aggregate_sl_perf(p_plan_id NUMBER) IS
  l_default_category_set_id NUMBER;
BEGIN
  -- Get default category set
  l_default_category_set_id := get_cat_set_id(p_plan_id);

  -- Do it once for MFG calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL AS record_type,
    sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 as achieved_service_level_qty1,
    sum(nvl(msd.using_requirement_quantity, 0) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_MFG AS period_type,
    mpb.bkt_start_date AS week_start_date,
    mpsd.period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_plan_buckets mpb,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners owning,
    msc_period_start_dates mpsd
  WHERE mp.plan_id = p_plan_id
    AND msd.plan_id = msi.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msd.plan_id = mp.plan_id
    AND mp.plan_id = mpb.plan_id
    AND mpb.bucket_type IN (2,3)
    AND trunc(msd.using_assembly_demand_date) BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
    AND mp.sr_instance_id = owning.sr_instance_id
    AND mp.organization_id = owning.sr_tp_id
    AND owning.partner_type = 3
    AND owning.calendar_code = mpsd.calendar_code
    AND exception_set_id = mpsd.exception_set_id
    AND mpb.sr_instance_id = mpsd.sr_instance_id
    AND mpb.bkt_start_date >=  mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND mic.category_set_id = l_default_category_set_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
  GROUP BY msd.plan_id, mpsd.period_start_date, mpb.bucket_type,
    CUBE (mpb.bkt_start_date, msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
  HAVING (
  (
GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR

      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
  AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
  AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 1 OR

      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
  AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
  AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 0
    )
    AND (mpb.bucket_type <> 3 OR GROUPING(mpb.bkt_start_date) <> 0)
  );

  -- And once for the BIS calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL AS record_type,
    sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 as achieved_service_level_qty1,
    sum(nvl(msd.using_requirement_quantity, 0) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_BIS AS period_type,
    NULL AS week_start_date,
    msbp.START_DATE AS period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_system_items msi,
    msc_item_categories mic,
    msc_bis_periods msbp
 WHERE mp.plan_id = p_plan_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
    AND msd.plan_id = mpo.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.plan_id = msi.plan_id
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND mp.sr_instance_id = msbp.sr_instance_id
    AND mp.organization_id = msbp.organization_id
    AND msbp.period_set_name = 'Accounting'
    AND TRUNC(msd.using_assembly_demand_date) >= msbp.START_DATE AND TRUNC(msd.using_assembly_demand_date) < msbp.end_date
  GROUP BY msd.plan_id, msbp.start_date,
    CUBE (msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
  HAVING (
    GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 1 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 1 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msd.inventory_item_id) = 0 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msd.inventory_item_id) = 1
  );
END schedule_aggregate_sl_perf;


PROCEDURE schedule_aggregate_sl(p_plan_id NUMBER) IS
  l_default_category_set_id NUMBER;
BEGIN
  if(g_perf_prof_on) then
    schedule_aggregate_sl_perf(p_plan_id);
  else

  -- Get default category set
  l_default_category_set_id := get_cat_set_id(p_plan_id);

  -- Do it once for MFG calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL AS record_type,
    sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 as achieved_service_level_qty1,
    sum(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_MFG AS period_type,
    mpb.bkt_start_date AS week_start_date,
    mpsd.period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_plan_buckets mpb,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners owning,
    msc_period_start_dates mpsd
  WHERE mp.plan_id = p_plan_id
    AND msd.plan_id = msi.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msd.plan_id = mp.plan_id
    AND mp.plan_id = mpb.plan_id
    AND mpb.bucket_type IN (2,3)
    AND trunc(msd.using_assembly_demand_date) BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
    AND mp.sr_instance_id = owning.sr_instance_id
    AND mp.organization_id = owning.sr_tp_id
    AND owning.partner_type = 3
    AND owning.calendar_code = mpsd.calendar_code
    AND exception_set_id = mpsd.exception_set_id
    AND mpb.sr_instance_id = mpsd.sr_instance_id
    AND mpb.bkt_start_date >=  mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND mic.category_set_id = l_default_category_set_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
  GROUP BY msd.plan_id, mpsd.period_start_date, mpb.bucket_type,
    CUBE (mpb.bkt_start_date, msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
  HAVING (
    (
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 1 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1
	AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1
	AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
	AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1
	AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 0 AND GROUPING(mpb.bkt_start_date) = 0 OR
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
      AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
      AND GROUPING(msd.inventory_item_id) = 1 AND GROUPING(mpb.bkt_start_date) = 0
    )
    AND (mpb.bucket_type <> 3 OR GROUPING(mpb.bkt_start_date) <> 0)
  );

  -- And once for the BIS calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL AS record_type,
    sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 as achieved_service_level_qty1,
    sum(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_BIS AS period_type,
    NULL AS week_start_date,
    msbp.START_DATE AS period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_system_items msi,
    msc_item_categories mic,
    msc_bis_periods msbp
 WHERE mp.plan_id = p_plan_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
    AND msd.plan_id = mpo.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.plan_id = msi.plan_id
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND mp.sr_instance_id = msbp.sr_instance_id
    AND mp.organization_id = msbp.organization_id
    AND msbp.period_set_name = 'Accounting'
    AND TRUNC(msd.using_assembly_demand_date) >= msbp.START_DATE AND TRUNC(msd.using_assembly_demand_date) < msbp.end_date
  GROUP BY msd.plan_id, msbp.start_date,
    CUBE (msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
  HAVING (
    GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 1 OR
    GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 0 OR
    GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msd.inventory_item_id) = 1 OR
    GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msd.inventory_item_id) = 0 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 1 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msd.inventory_item_id) = 0 OR
    GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msd.inventory_item_id) = 1
  );
  end if;
END schedule_aggregate_sl;

PROCEDURE schedule_aggregate_sl_brkdown(p_plan_id NUMBER) IS
  l_default_category_set_id NUMBER;
BEGIN
  -- Get default category set
  l_default_category_set_id := get_cat_set_id(p_plan_id);

/*
  -- Do it once for MFG calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    demand_class,
    category_set_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL_BRKDOWN AS record_type,
    SUM(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 AS achieved_service_level_qty1,
    SUM(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_MFG AS period_type,
    mpb.bkt_start_date AS week_start_date,
    mpsd.period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    msd.demand_class as demand_class,
    mic.category_set_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_plan_buckets mpb,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners owning,
    msc_period_start_dates mpsd
  WHERE mp.plan_id = p_plan_id
    AND msd.plan_id = msi.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msd.plan_id = mp.plan_id
    AND mp.plan_id = mpb.plan_id
    AND mpb.bucket_type IN (2,3)
    AND trunc(msd.using_assembly_demand_date) BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
    AND mp.sr_instance_id = owning.sr_instance_id
    AND mp.organization_id = owning.sr_tp_id
    AND owning.partner_type = 3
    AND owning.calendar_code = mpsd.calendar_code
    AND exception_set_id = mpsd.exception_set_id
    AND mpb.sr_instance_id = mpsd.sr_instance_id
    AND mpb.bkt_start_date >=  mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND mic.category_set_id = l_default_category_set_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
  GROUP BY msd.plan_id, mpsd.period_start_date, mpb.bucket_type, mic.category_set_id,
    CUBE (mpb.bkt_start_date, msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name,
    msd.demand_class)
  HAVING (
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
        AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) =0
	AND ( GROUPING(msd.demand_class) = 0)
	-- AND ( GROUPING(mpb.bkt_start_date) = 0)
  );
*/

  -- Do it once for MFG calendar
  --insert the week data first
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    demand_class,
    category_set_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL_BRKDOWN AS record_type,
    SUM(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 AS achieved_service_level_qty1,
    SUM(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_MFG AS period_type,
    mpb.bkt_start_date AS week_start_date,
    null as period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    msd.demand_class as demand_class,
    mic.category_set_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_plan_buckets mpb,
    msc_system_items msi,
    msc_item_categories mic,
    msc_trading_partners owning
    --msc_period_start_dates mpsd
  WHERE mp.plan_id = p_plan_id
    AND msd.plan_id = msi.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msd.plan_id = mp.plan_id
    AND mp.plan_id = mpb.plan_id
    AND mpb.bucket_type IN (2)
    AND trunc(msd.using_assembly_demand_date) BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
    AND mp.sr_instance_id = owning.sr_instance_id
    AND mp.organization_id = owning.sr_tp_id
    AND owning.partner_type = 3
   -- AND owning.calendar_code = mpsd.calendar_code
    --AND exception_set_id = mpsd.exception_set_id
    --AND mpb.sr_instance_id = mpsd.sr_instance_id
    --AND mpb.bkt_start_date >=  mpsd.period_start_date AND mpb.bkt_start_date < mpsd.next_date
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND mic.category_set_id = l_default_category_set_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
    and mpb.bkt_start_date between mp.curr_start_date and mp.curr_cutoff_date
  GROUP BY msd.plan_id,  mpb.bkt_start_date, mpb.bucket_type, mic.category_set_id,
    msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name,  msd.demand_class;

  --insert the period data for MFG
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    demand_class,
    category_set_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL_BRKDOWN AS record_type,
    SUM(NVL(msd.old_demand_quantity,0) * NVL(msd.probability,1)) * 100 AS achieved_service_level_qty1,
    SUM(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * NVL(msd.probability,1)) AS achieved_service_level_qty2,
    DECODE(COUNT(*), 0, 50, SUM(NVL(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_MFG AS period_type,
    NULL AS week_start_date,
    mpsd.period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    msd.demand_class AS demand_class,
    mic.category_set_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_trading_partners owning,
    msc_period_start_dates mpsd,
    msc_demands msd,
    msc_system_items msi,
    msc_item_categories mic
  WHERE mp.plan_id = p_plan_id
    AND mp.sr_instance_id = owning.sr_instance_id
    AND mp.organization_id = owning.sr_tp_id
    AND owning.partner_type = 3
    AND owning.calendar_code = mpsd.calendar_code
    --    AND exception_set_id = exception_set_id
    AND owning.sr_instance_id = mpsd.sr_instance_id
		AND mpsd.next_date > mp.curr_start_date
    AND mpsd.period_start_date <= mp.curr_cutoff_date
    AND msi.plan_id = mp.plan_id
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND msd.plan_id = msi.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND TRUNC(msd.using_assembly_demand_date) BETWEEN mpsd.period_start_date AND mpsd.next_date
GROUP BY msd.plan_id,mpsd.period_start_date, mic.category_set_id,
     msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name, msd.demand_class;

  -- And once for the BIS calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    achieved_service_level_qty1,
    achieved_service_level_qty2,
    target_service_level,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    demand_class,
    category_set_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    msd.plan_id,
    RECORD_SERVICE_LEVEL_BRKDOWN AS record_type,
    SUM(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 AS achieved_service_level_qty1,
    SUM(DECODE(NVL(msd.using_requirement_quantity, 1) ,0 ,1 , NVL(msd.using_requirement_quantity, 1)) * nvl(msd.probability,1)) AS achieved_service_level_qty2,
    decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
    CALENDAR_TYPE_BIS AS period_type,
    NULL AS week_start_date,
    msbp.START_DATE AS period_start_date,
    msd.sr_instance_id AS instance_id,
    msd.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    msd.inventory_item_id AS item_id,
    msd.demand_class as demand_class,
    mic.category_set_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_demands msd,
    msc_system_items msi,
    msc_item_categories mic,
    msc_bis_periods msbp
 WHERE mp.plan_id = p_plan_id
    AND mp.plan_id = mpo.plan_id
    AND msd.organization_id = mpo.organization_id
    AND msd.sr_instance_id = mpo.sr_instance_id
    AND msd.plan_id = mpo.plan_id
    AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
    AND msd.plan_id = msi.plan_id
    AND msd.sr_instance_id = msi.sr_instance_id
    AND msd.organization_id = msi.organization_id
    AND msd.inventory_item_id = msi.inventory_item_id
    AND msi.organization_id = mic.organization_id
    AND msi.sr_instance_id = mic.sr_instance_id
    AND msi.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND mp.sr_instance_id = msbp.sr_instance_id
    AND mp.organization_id = msbp.organization_id
    AND msbp.period_set_name = 'Accounting'
    AND TRUNC(msd.using_assembly_demand_date) >= msbp.START_DATE AND TRUNC(msd.using_assembly_demand_date) < msbp.end_date
  GROUP BY msd.plan_id, msbp.start_date,mic.category_set_id,
    CUBE (msd.inventory_item_id, msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name, msd.demand_class)
  HAVING (
      GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0
        AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
	AND GROUPING(msd.inventory_item_id) =0
	AND GROUPING(msd.demand_class) = 0
  );
END schedule_aggregate_sl_brkdown;

  -- for search by plan and view by plan only
PROCEDURE schedule_aggregate_cost(p_plan_id NUMBER) IS
  l_default_category_set_id NUMBER;
BEGIN
  -- Get default category set
  l_default_category_set_id := get_cat_set_id(p_plan_id);

  -- Do it once for MFG calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    plan_name,
    record_type,
    planned_production_cost,
    planned_carrying_cost,
    planned_purchasing_cost,
    planned_tp_cost,
    planned_total_cost,
    planned_revenue,
    period_type,
    detail_level,
    category_set_id,
    category_id,
    category_name,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    plan_id,
    plan_name,
    RECORD_COST_BRKDOWN AS record_type,
    sum(planned_production_cost),
    sum(planned_carrying_cost),
    sum(planned_purchasing_cost),
    0,
    sum(planned_total_cost),
    sum(planned_revenue),
    CALENDAR_TYPE_MFG AS period_type,
    detail_level,
    category_set_id,
    category_id,
    category_name,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_cost_breakdown_notpcost_v
  WHERE plan_id = p_plan_id
  and nvl(detail_level,0) = 0
  and nvl(period_type,0) = 1
  GROUP BY plan_id, plan_name, period_type,period_type, detail_level,category_set_id, category_id,category_name;

  -- And once for the BIS calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    plan_name,
    record_type,
    planned_production_cost,
    planned_carrying_cost,
    planned_purchasing_cost,
    planned_tp_cost,
    planned_total_cost,
    planned_revenue,
    period_type,
    detail_level,
    category_set_id,
    category_id,
    category_name,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    plan_id,
    plan_name,
    RECORD_COST_BRKDOWN AS record_type,
    sum(planned_production_cost),
    sum(planned_carrying_cost),
    sum(planned_purchasing_cost),
    0,
    sum(planned_total_cost),
    sum(planned_revenue),
    CALENDAR_TYPE_BIS AS period_type,
    detail_level,
    category_set_id,
    category_id,
    category_name,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_cost_breakdown_notpcost_v
  WHERE plan_id = p_plan_id
  and nvl(detail_level,0) = 0
  and nvl(period_type,0) = 0
  GROUP BY plan_id, plan_name, period_type,period_type, detail_level,category_set_id,category_id,category_name;

END schedule_aggregate_cost;



PROCEDURE schedule_aggregate_iv(p_plan_id NUMBER) IS
  l_default_category_set_id NUMBER;
BEGIN
  -- Get default category set
  l_default_category_set_id := get_cat_set_id(p_plan_id);

  -- Do it once for the MFG calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    inventory_value_dollars,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    mp.plan_id,
    RECORD_INVENTORY_VALUE AS record_type,
    SUM(nvl(mbid.inventory_value, 0)) AS inventory_value_dollars,
    CALENDAR_TYPE_MFG AS period_type,
    decode(NVL(mbid.detail_level, 0), 0, NULL, mbid.detail_date) AS week_start_date,
    mpsd.period_start_date,
    mpo.sr_instance_id AS instance_id,
    mpo.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    NULL AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_bis_inv_detail mbid,
    msc_system_items mis,
    msc_item_categories mic,
    msc_trading_partners mtp,
    msc_period_start_dates mpsd,
    msc_plan_buckets mpb
  WHERE mp.plan_id = p_plan_id
    AND mp.plan_id = mpo.plan_id
    AND mpo.plan_id = mbid.plan_id
    AND mpo.organization_id = mbid.organization_id
    AND mpo.sr_instance_id = mbid.sr_instance_id
    AND mbid.period_type = CALENDAR_TYPE_MFG
    -- BEGIN FUNNY SECTION
    -- For some strange reason MSC_BIS_INV_DETAIL has week records for period buckets
    -- So we need to filter thsese out before we aggregate
    AND mpb.plan_id = mbid.plan_id
    AND (mpb.bucket_type = 2 OR nvl(detail_level, DETAIL_LEVEL_PERIOD) = DETAIL_LEVEL_PERIOD)
    AND mbid.detail_date BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
    -- END FUNNY SECTION
    AND mbid.plan_id = mis.plan_id
    AND mbid.organization_id = mis.organization_id
    AND mbid.sr_instance_id = mis.sr_instance_id
    AND mbid.inventory_item_id = mis.inventory_item_id
    AND mis.budget_constrained = BUDGET_CONSTRAINED_ON
    AND mis.organization_id = mic.organization_id
    AND mis.sr_instance_id = mic.sr_instance_id
    AND mis.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND mtp.sr_tp_id = mp.organization_id
    AND mtp.sr_instance_id = mp.sr_instance_id
    AND mtp.partner_type = 3
    AND mtp.sr_Instance_id = mpsd.sr_instance_id
    AND mtp.calendar_code = mpsd.calendar_code
    AND mtp.calendar_exception_set_id = mpsd.exception_set_id
    AND ((nvl(mbid.detail_level, DETAIL_LEVEL_PERIOD) = DETAIL_LEVEL_PERIOD AND mbid.detail_date = mpsd.period_start_date) OR
      (mbid.detail_level = DETAIL_LEVEL_WEEK AND mbid.detail_date >= mpsd.period_start_date AND mbid.detail_date < mpsd.next_date))
  GROUP BY mp.plan_id, mbid.period_type, mpsd.period_start_date, mbid.detail_date, NVL(mbid.detail_level, 0),
    CUBE(mpo.sr_instance_id, mpo.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
  HAVING (
    GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
    GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 OR
    GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
    GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
  );

  -- Do it again for the BIS calendar
  INSERT INTO msc_analysis_aggregate
  (
    plan_id,
    record_type,
    inventory_value_dollars,
    period_type,
    week_start_date,
    period_start_date,
    sr_instance_id,
    organization_id,
    sr_cat_instance_id,
    sr_category_id,
    category_name,
    inventory_item_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login
  )
  SELECT
    mp.plan_id,
    RECORD_INVENTORY_VALUE AS record_type,
    SUM(nvl(mbid.inventory_value, 0)) AS inventory_value_dollars,
    CALENDAR_TYPE_BIS AS period_type,
    NULL AS week_start_date,
    mpsd.start_date,
    mpo.sr_instance_id AS instance_id,
    mpo.organization_id AS org_id,
    mic.sr_instance_id AS sr_cat_instance_id,
    mic.sr_category_id AS sr_category_id,
    mic.category_name AS category_name,
    NULL AS item_id,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    to_number(null)
  FROM msc_plans mp,
    msc_plan_organizations mpo,
    msc_bis_inv_detail mbid,
    msc_system_items mis,
    msc_item_categories mic,
    msc_bis_periods mpsd
  WHERE mp.plan_id = p_plan_id
    AND mp.plan_id = mpo.plan_id
    AND mpo.plan_id = mbid.plan_id
    AND mpo.organization_id = mbid.organization_id
    AND mpo.sr_instance_id = mbid.sr_instance_id
    AND nvl(mbid.period_type, CALENDAR_TYPE_BIS) = CALENDAR_TYPE_BIS
    AND mbid.plan_id = mis.plan_id
    AND mbid.organization_id = mis.organization_id
    AND mbid.sr_instance_id = mis.sr_instance_id
    AND mbid.inventory_item_id = mis.inventory_item_id
    AND mis.budget_constrained = BUDGET_CONSTRAINED_ON
    AND mis.organization_id = mic.organization_id
    AND mis.sr_instance_id = mic.sr_instance_id
    AND mis.inventory_item_id = mic.inventory_item_id
    AND mic.category_set_id = l_default_category_set_id
    AND mp.sr_instance_id = mpsd.sr_instance_id
    AND mp.organization_id = mpsd.organization_id
    AND mpsd.period_set_name = 'Accounting'
    AND mbid.detail_date = mpsd.START_DATE
    GROUP BY mp.plan_id, mbid.period_type, mpsd.start_date, mbid.detail_date, NVL(mbid.detail_level, 0),
      CUBE(mpo.sr_instance_id, mpo.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
    HAVING (
      GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
      GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 OR
      GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
      GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
    );
END schedule_aggregate_iv;

   PROCEDURE schedule_bucket_week_to_period(weekschedule IN OUT NOCOPY Schedule, periodschedule IN OUT NOCOPY Schedule)
   IS
   BEGIN
      if (weekschedule.count = 0 ) then
        return;
      end if;
      FOR i IN weekschedule.FIRST..weekschedule.LAST LOOP
         IF weekschedule(i).last_week_of_period = 'Y' THEN
            FOR j IN periodschedule.FIRST..periodschedule.LAST LOOP
               IF is_bucket_match(periodschedule(j), weekschedule(i)) THEN
                  schedule_initialize_bkt(periodschedule(j), periodschedule(j));
                  bucket_ss_copy(periodschedule(j), weekschedule(i));
               END IF;
            END LOOP;
         END IF;
      END LOOP;
   END schedule_bucket_week_to_period;

   PROCEDURE schedule_aggregate_ss(weekschedule IN OUT NOCOPY Schedule,
                        periodschedule IN OUT NOCOPY Schedule, p_plan_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;

      l_default_category_set_id NUMBER;

      CURSOR c1 IS
    SELECT mss.plan_id AS plan_id,
       mss.sr_instance_id AS instance_id,
       mss.organization_id AS org_id,
       msi.inventory_item_id AS item_id,
       mic.sr_instance_id AS sr_category_inst_id,
       mic.sr_category_id AS sr_category_id,
       mic.category_name AS category_name,
       trunc(mss.period_start_date) AS week_start_date,
       NULL AS week_next_date,
       NULL AS period_start_date,
       'N' AS last_week_of_period,
       sum(nvl(mss.safety_stock_quantity, 0)) AS achieved_ss_qty,
       sum(nvl(mss.safety_stock_quantity*msi.standard_cost, 0)) AS achieved_ss_dollars,
       sum(nvl(mss.achieved_days_of_supply, 0)) AS achieved_ss_days,
       sum(nvl(mss.target_safety_stock, 0)) AS target_ss_qty,
       sum(nvl(mss.target_safety_stock * msi.standard_cost, 0)) AS target_ss_dollars,
       sum(nvl(mss.target_days_of_supply, 0)) AS target_ss_days,
       sum(nvl(mss.user_defined_safety_stocks, 0)) AS userdef_ss_qty,
       sum(nvl(mss.user_defined_safety_stocks * msi.standard_cost, 0)) AS userdef_ss_dollars,
       sum(nvl(mss.user_defined_dos, 0)) AS userdef_ss_days,
       0 AS nr_ss_records,
       NULL AS inv_value_dollars,
       NULL AS period_type,
       sum(nvl(mss.total_unpooled_safety_stock, 0)) AS total_unpooled_safety_stock,
      decode( sum(mss.total_unpooled_safety_stock), 0, 0,
          sum((mss.demand_var_ss_percent *mss.total_unpooled_safety_stock)/100)
          / sum(mss.total_unpooled_safety_stock))*100 AS demand_var_ss_percent,
      decode( sum(mss.total_unpooled_safety_stock), 0, 0,
          sum((mss.mfg_ltvar_ss_percent *mss.total_unpooled_safety_stock)/100)
          / sum(mss.total_unpooled_safety_stock))*100 AS mfg_ltvar_ss_percent,
      decode( sum(mss.total_unpooled_safety_stock), 0, 0,
          sum((mss.transit_ltvar_ss_percent *mss.total_unpooled_safety_stock)/100)
          / sum(mss.total_unpooled_safety_stock))*100 AS transit_ltvar_ss_percent,
      decode( sum(mss.total_unpooled_safety_stock), 0, 0,
          sum((mss.sup_ltvar_ss_percent *mss.total_unpooled_safety_stock)/100)
          / sum(mss.total_unpooled_safety_stock))*100 AS sup_ltvar_ss_percent,
       NULL AS delivered_quantity,
       NULL AS required_quantity,
       NULL AS target_service_level,
       0 AS nr_sl_records,
       NULL AS partner_id,
       NULL AS customer_class_code,
       RECORD_SAFETY_STOCK AS record_type
     FROM msc_plan_organizations mpo, msc_safety_stocks mss,
          msc_system_items msi, msc_item_categories mic
    WHERE mss.sr_instance_id = msi.sr_instance_id
      AND mss.plan_id = msi.plan_id
      AND mss.organization_id = msi.organization_id
      AND mss.inventory_item_id = msi.inventory_item_id
      AND msi.sr_instance_id = mic.sr_instance_id
      AND msi.inventory_item_id = mic.inventory_item_id
      AND msi.organization_id = mic.organization_id
      AND mic.category_set_id = l_default_category_set_id
      AND mss.plan_id = p_plan_id
      AND mss.plan_id = mpo.plan_id
      AND mss.organization_id = mpo.organization_id
      AND mss.sr_instance_id = mpo.sr_instance_id
   GROUP BY mss.plan_id, TRUNC(mss.period_start_date),
      CUBE (msi.inventory_item_id, mss.sr_instance_id, mss.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
   HAVING
      GROUPING (mss.sr_instance_id) = 1 AND GROUPING (mss.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 1 OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 1 OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msi.inventory_item_id) = 1 OR
      GROUPING (mss.sr_instance_id) = 1 AND GROUPING (mss.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msi.inventory_item_id) = 1 OR
      GROUPING (mss.sr_instance_id) = 1 AND GROUPING (mss.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msi.inventory_item_id) = 0 OR
      GROUPING (mss.sr_instance_id) = 1 AND GROUPING (mss.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 0 OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 0
   ORDER BY 1,2,3,4, 5, 6, 11;

    CURSOR cperf IS
    SELECT mss.plan_id AS plan_id,
       mss.sr_instance_id AS instance_id,
       mss.organization_id AS org_id,
       msi.inventory_item_id AS item_id,
       mic.sr_instance_id AS sr_category_inst_id,
       mic.sr_category_id AS sr_category_id,
       mic.category_name AS category_name,
       --trunc(mss.period_start_date) AS week_start_date,
       trunc(mpb.bkt_start_date) AS week_start_date,
       NULL AS week_next_date,
       NULL AS period_start_date,
       'N' AS last_week_of_period,
       sum(nvl(mss.safety_stock_quantity, 0)) AS achieved_ss_qty,
       sum(nvl(mss.safety_stock_quantity*msi.standard_cost, 0)) AS achieved_ss_dollars,
       sum(nvl(mss.achieved_days_of_supply, 0)) AS achieved_ss_days,
       sum(nvl(mss.target_safety_stock, 0)) AS target_ss_qty,
       sum(nvl(mss.target_safety_stock * msi.standard_cost, 0)) AS target_ss_dollars,
       sum(nvl(mss.target_days_of_supply, 0)) AS target_ss_days,
       sum(nvl(mss.user_defined_safety_stocks, 0)) AS userdef_ss_qty,
       sum(nvl(mss.user_defined_safety_stocks * msi.standard_cost, 0)) AS userdef_ss_dollars,
       sum(nvl(mss.user_defined_dos, 0)) AS userdef_ss_days,
       0 AS total_unpooled_safety_stock,
       0 AS demand_var_ss_percent,
       0 AS mfg_ltvar_ss_percent,
       0 AS transit_ltvar_ss_percent,
       0 AS sup_ltvar_ss_percent,
       0 AS nr_ss_records,
       NULL AS inv_value_dollars,
       NULL AS period_type,
       NULL AS delivered_quantity,
       NULL AS required_quantity,
       NULL AS target_service_level,
       0 AS nr_sl_records,
       NULL AS partner_id,
       NULL AS customer_class_code,
       RECORD_SAFETY_STOCK AS record_type
     FROM msc_plan_organizations mpo, msc_safety_stocks mss,
          msc_system_items msi, msc_item_categories mic,
          msc_plan_buckets mpb
    WHERE mss.sr_instance_id = msi.sr_instance_id
      AND mss.plan_id = msi.plan_id
      AND mss.organization_id = msi.organization_id
      AND mss.inventory_item_id = msi.inventory_item_id
      AND msi.sr_instance_id = mic.sr_instance_id
      AND msi.inventory_item_id = mic.inventory_item_id
      AND msi.organization_id = mic.organization_id
      AND mic.category_set_id = l_default_category_set_id
      AND mss.plan_id = p_plan_id
      AND mss.plan_id = mpo.plan_id
      AND mss.plan_id = mpb.plan_id
      AND mss.organization_id = mpo.organization_id
      AND mss.sr_instance_id = mpo.sr_instance_id
      AND mss.period_start_date between mpb.bkt_start_date and mpb.bkt_end_date
   GROUP BY mss.plan_id, TRUNC(mpb.bkt_start_date),
      CUBE (msi.inventory_item_id, mss.sr_instance_id, mss.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
   HAVING
      GROUPING (mss.sr_instance_id) = 1 AND GROUPING (mss.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 1  OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 AND GROUPING(msi.inventory_item_id) = 1  OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msi.inventory_item_id) = 1  OR
      GROUPING (mss.sr_instance_id) = 0 AND GROUPING (mss.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 AND GROUPING(msi.inventory_item_id) = 0
   ORDER BY 1,2,3,4, 5, 6, 11;

   curFound Boolean := FALSE;

  TYPE curType IS REF CURSOR;
  l_cursor curType;

  cFound BOOLEAN;

   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned

      if(g_perf_prof_on) then
        open cperf;
      else
        open c1;
      end if;
      LOOP
      if(g_perf_prof_on) then
        FETCH cperf INTO currRecord;
        IF cperf%FOUND THEN
          cFound := TRUE;
        END IF;
      else
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
          cFound := TRUE;
        END IF;
      end if;
         IF (cFound) THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               IF is_safety_stock_key_changed(currRecord, prevRecord) THEN
                  if (weekschedule.count = 0) then
                    null;
                  else
                     bucket_safety_stock_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
                  END IF;
                  if (periodschedule.count = 0) then
                    null;
                  else
                     bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
                  END IF;
                  schedule_bucket_week_to_period(weekschedule, periodschedule);
                  schedule_ss_fill_gaps(weekschedule);
                  schedule_ss_fill_gaps(periodschedule);
                  schedule_aggregate_flush(weekschedule);
                  schedule_aggregate_flush(periodschedule, TRUE);
                  schedule_initialize(weekschedule, currRecord);
                  schedule_initialize(periodschedule, currRecord);
               ELSE

                  bucket_safety_stock_record(weekschedule, prevRecord, currRecord.bkt_start_date);
                  if (periodschedule.count = 0) then
           		      null;
                  else
                     bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
                  end if;
               END IF;
            ELSE
               schedule_initialize(weekschedule, currRecord);
               schedule_initialize(periodschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               if (weekschedule.count = 0) then
        		      null;
               else
                  bucket_safety_stock_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
               end if;
               if (weekschedule.count = 0) then
        		      null;
               else
                  bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
               end if;
               schedule_bucket_week_to_period(weekschedule, periodschedule);
               schedule_ss_fill_gaps(weekschedule);
               schedule_ss_fill_gaps(periodschedule);
               schedule_aggregate_flush(weekschedule);
               schedule_aggregate_flush(periodschedule, TRUE);
            END IF;
            EXIT;
         END IF;
         cFound := FALSE;
      END LOOP;
      if(g_perf_prof_on) then
        CLOSE cperf;
      else
        CLOSE c1;
      end if;
   END schedule_aggregate_ss;

   PROCEDURE schedule_bucket_safety_stock(weekschedule IN OUT NOCOPY Schedule, periodschedule IN OUT NOCOPY Schedule,
                                 p_plan_id NUMBER, p_sr_instance_id NUMBER,
                                 p_sr_tp_id NUMBER, p_sr_cat_instance_id NUMBER, p_sr_cat_id NUMBER,
                                 p_item_id NUMBER, query_id NUMBER)
   IS
      currRecord Bucket;
      prevRecord Bucket;
      l_start_date DATE;
      l_end_date DATE;

      l_default_category_set_id NUMBER;

      CURSOR c1 IS
    SELECT mss.plan_id AS plan_id, mss.sr_instance_id AS instance_id, mss.organization_id AS org_id,
       mss.inventory_item_id AS item_id,
       mic.sr_instance_id AS sr_category_inst_id,
       mic.sr_category_id AS sr_category_id, mic.category_name AS category_name,
       mss.period_start_date AS week_start_date,
       NULL AS week_next_date,
       NULL AS period_start_date,
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
       0 AS nr_ss_records,
       NULL AS inv_value_dollars,
       CALENDAR_TYPE_MFG AS period_type,
       nvl(mss.total_unpooled_safety_stock, 0) AS total_unpooled_safety_stock,
       nvl(mss.demand_var_ss_percent, 0) AS demand_var_ss_percent,
       nvl(mss.mfg_ltvar_ss_percent, 0) AS mfg_ltvar_ss_percent,
       nvl(mss.transit_ltvar_ss_percent, 0) AS transit_ltvar_ss_percent,
       nvl(mss.sup_ltvar_ss_percent, 0) AS sup_ltvar_ss_percent,
       NULL AS delivered_quantity,
       NULL AS required_quantity,
       NULL AS target_service_level,
       0 AS nr_sl_records,
       NULL AS partner_id,
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
      AND mss.period_start_date BETWEEN l_start_date AND l_end_date
      AND mpo.sr_instance_id = nvl(p_sr_instance_id, mpo.sr_instance_id)
      AND mpo.organization_id = nvl(p_sr_tp_id, mpo.organization_id)
      AND mic.sr_instance_id = nvl(p_sr_cat_instance_id, mic.sr_instance_id)
      AND mic.sr_category_id = nvl(p_sr_cat_id, mic.sr_category_id)
   ORDER BY 2,3,4,5,6;

   CURSOR c2 IS
      SELECT curr_start_date, curr_cutoff_date
         FROM msc_plans
      WHERE plan_id = p_plan_id;

   c2Rec c2%ROWTYPE;


   BEGIN
      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      OPEN c2;
      FETCH c2 INTO c2Rec;

      if(weekschedule.count = 0) then
         l_start_date := c2Rec.curr_start_date;
      else
         l_start_date := weekschedule(weekschedule.FIRST).bkt_start_date;
      end if;

      if (periodschedule.count = 0) then
         l_end_date := c2Rec.curr_cutoff_date;
      else
         l_end_date := periodschedule(periodschedule.LAST).bkt_end_date;
      end if;

      CLOSE c2;


      prevRecord.bkt_start_date := NULL; -- Used to test if the previous record was assigned
      OPEN c1;
      LOOP
         FETCH c1 INTO currRecord;
         IF c1%FOUND THEN
            IF prevRecord.bkt_start_date IS NOT NULL THEN -- prev record exists
               IF is_safety_stock_key_changed(currRecord, prevRecord) THEN

                  if (weekschedule.count = 0) then
           		      null;
                  else
                     bucket_safety_stock_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
                  end if;
                  if (periodschedule.count = 0) then
           		      null;
                  else
                     bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
                  end if;
                  schedule_bucket_week_to_period(weekschedule, periodschedule);
                  schedule_ss_fill_gaps(weekschedule);
                  schedule_ss_fill_gaps(periodschedule);
                  schedule_flush(weekschedule, query_id);
                  schedule_flush(periodschedule, query_id, TRUE);
                  schedule_initialize(weekschedule, currRecord);
                  schedule_initialize(periodschedule, currRecord);
               ELSE
                  bucket_safety_stock_record(weekschedule, prevRecord, currRecord.bkt_start_date);
                  if (periodschedule.count = 0) then
                     null;
                  else
                     bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
                  end if;
               END IF;
            ELSE
               schedule_initialize(weekschedule, currRecord);
               schedule_initialize(periodschedule, currRecord);
            END IF;
            prevRecord := currRecord;
         ELSE
            IF prevRecord.bkt_start_date IS NOT NULL THEN
               if (weekschedule.count = 0) then
                  null;
               else
                 bucket_safety_stock_record(weekschedule, prevRecord, weekschedule(weekschedule.LAST).bkt_start_date + 1);
               end if;
               if (periodschedule.count = 0) then
                  null;
               else
                  bucket_safety_stock_record(periodschedule, prevRecord, periodschedule(periodschedule.LAST).bkt_start_date + 1);
               end if;
               schedule_bucket_week_to_period(weekschedule, periodschedule);
               schedule_ss_fill_gaps(weekschedule);
               schedule_ss_fill_gaps(periodschedule);
               schedule_flush(weekschedule, query_id);
               schedule_flush(periodschedule, query_id, TRUE);
            END IF;
            EXIT;
         END IF;
      END LOOP;
      CLOSE c1;
   END schedule_bucket_safety_stock;

   FUNCTION validate_plan(p_plan_id NUMBER)
   RETURN BOOLEAN
   IS
      CURSOR c1(p_plan_id NUMBER) IS
      SELECT 1
        FROM msc_plans mp
       WHERE mp.curr_plan_type = 4 OR mp.curr_plan_type = 9
         AND mp.curr_start_date IS NOT NULL
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
   END validate_plan;

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
   END get_sr_cat_id_from_cat_key;

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
   END get_inst_id_from_org_key;

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
   END get_sr_tp_id_from_org_key;

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
   END get_inst_id_from_category_key;

   PROCEDURE schedule_details_iv(p_query_id OUT NOCOPY NUMBER, p_period_type IN NUMBER,
      p_plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2, p_abc_id IN VARCHAR2)
   IS
      weekschedule       Schedule;
      periodschedule     Schedule;
      l_sr_instance_id     NUMBER;
      l_sr_tp_id           NUMBER;
      l_sr_cat_instance_id NUMBER;
      l_sr_cat_id          NUMBER;
      l_planlist         PlanList;
      l_index            BINARY_INTEGER;
      l_default_category_set_id NUMBER;

   BEGIN

      -- Get default category set
      l_default_category_set_id := get_cat_set_id(p_plan_id);

      SELECT msc_form_query_s.nextval
        INTO p_query_id
      FROM dual;

      IF org_id IS NOT NULL THEN
         l_sr_instance_id := get_inst_id_from_org_key(org_id);
         l_sr_tp_id := get_sr_tp_id_from_org_key(org_id);
      END IF;

      IF cat_id IS NOT NULL THEN
         l_sr_cat_instance_id := get_inst_id_from_category_key(cat_id);
         l_sr_cat_id := get_sr_cat_id_from_cat_key(cat_id);
      END IF;

      parse_planlist(p_plan_id, l_planlist);
      IF l_planlist.COUNT = 0 THEN
         p_query_id := -1;
         RETURN;
      END IF;

      FOR l_index IN l_planlist.FIRST..l_planlist.LAST LOOP
         IF validate_plan(l_planlist(l_index)) = FALSE THEN
            p_query_id := -1;
            RETURN;
         END IF;

         IF p_period_type = CALENDAR_TYPE_MFG THEN

            INSERT INTO msc_form_query
            (
            query_id,
            NUMBER1, -- PLAN_ID
            CREATED_BY, -- RECORD_TYPE
            NUMBER9, -- achieved_ss_qty
            NUMBER10,
            NUMBER11,
            NUMBER12,
            NUMBER13,
            NUMBER14,
            NUMBER15,
            NUMBER16,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID, -- achieved_sl
            LAST_UPDATE_LOGIN, -- target_sl
            NUMBER6, -- inventory_value_dollars
            NUMBER7, -- period_type
            DATE1, -- week_start_date
            DATE3, -- period_start_date
            NUMBER2, -- sr_instance_id
            NUMBER3, -- org_id
            REQUEST_ID, -- sr_cat_instance_id
            NUMBER5, -- sr_category_id
            CHAR1, -- category_name
            NUMBER4, -- inventory_item_id
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE
            )
          SELECT
             p_query_id,
             mp.plan_id,
             RECORD_INVENTORY_VALUE AS record_type,
             NULL AS achieved_ss_qty,
             NULL AS achieved_ss_dollars,
             NULL AS achieved_ss_days,
             NULL AS target_ss_qty,
             NULL AS target_ss_dollars,
             NULL AS target_ss_days,
             NULL AS userdef_ss_qty,
             NULL AS userdef_ss_dollars,
             NULL AS userdef_ss_days,
             NULL AS achieved_sl,
             NULL AS target_service_level,
             SUM(nvl(mbid.inventory_value, 0)) AS inventory_value_dollars,
             CALENDAR_TYPE_MFG AS period_type,
             decode(NVL(mbid.detail_level, 0), 0, NULL, mbid.detail_date) AS week_start_date,
             mpsd.period_start_date,
             mpo.sr_instance_id AS instance_id,
             mpo.organization_id AS org_id,
             mic.sr_instance_id AS sr_cat_instance_id,
             mic.sr_category_id AS sr_category_id,
             mic.category_name AS category_name,
             NULL AS item_id,
             SYSDATE AS last_update_date,
             -1 AS last_updated_by,
             SYSDATE AS CREATION_DATE
          FROM msc_plans mp, msc_plan_organizations mpo, msc_bis_inv_detail mbid, msc_system_items mis, msc_item_categories mic,
               msc_trading_partners mtp, msc_period_start_dates mpsd, msc_plan_buckets mpb
         WHERE mp.plan_id = l_planlist(l_index)
           AND mp.plan_id = mpo.plan_id
           AND mpo.plan_id = mbid.plan_id
           AND mpo.organization_id = mbid.organization_id
           AND mpo.sr_instance_id = mbid.sr_instance_id
           AND mpo.sr_instance_id = nvl(l_sr_instance_id, mpo.sr_instance_id)
           AND mpo.organization_id = nvl(l_sr_tp_id, mpo.organization_id)
           AND mbid.period_type = CALENDAR_TYPE_MFG
           -- BEGIN FUNNY SECTION
           -- For some strange reason MSC_BIS_INV_DETAIL has week records for period buckets
           -- So we need to filter these out before we aggregate
           AND mpb.plan_id = mbid.plan_id
           AND (mpb.bucket_type = 2 OR nvl(detail_level, DETAIL_LEVEL_PERIOD) = DETAIL_LEVEL_PERIOD)
           AND mbid.detail_date BETWEEN mpb.bkt_start_date AND mpb.bkt_end_date
           -- END FUNNY SECTION
           AND mbid.plan_id = mis.plan_id
           AND mbid.organization_id = mis.organization_id
           AND mbid.sr_instance_id = mis.sr_instance_id
           AND mbid.inventory_item_id = mis.inventory_item_id
           AND nvl(mis.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(mis.abc_class_name, 'XXXXX'))
           AND mis.budget_constrained = BUDGET_CONSTRAINED_ON
           AND mis.organization_id = mic.organization_id
           AND mis.sr_instance_id = mic.sr_instance_id
           AND mis.inventory_item_id = mic.inventory_item_id
           AND mic.sr_instance_id = nvl(l_sr_cat_instance_id, mic.sr_instance_id)
           AND mic.sr_category_id = nvl(l_sr_cat_id, mic.sr_category_id)
           AND mic.category_set_id = l_default_category_set_id
           AND mtp.sr_tp_id = mp.organization_id
           AND mtp.sr_instance_id = mp.sr_instance_id
           AND mtp.partner_type = 3
           AND mtp.sr_Instance_id = mpsd.sr_instance_id
           AND mtp.calendar_code = mpsd.calendar_code
           AND mtp.calendar_exception_set_id = mpsd.exception_set_id
           AND ((nvl(mbid.detail_level, DETAIL_LEVEL_PERIOD) = DETAIL_LEVEL_PERIOD AND mbid.detail_date = mpsd.period_start_date) OR
                (mbid.detail_level = DETAIL_LEVEL_WEEK AND mbid.detail_date >= mpsd.period_start_date AND mbid.detail_date < mpsd.next_date))
           GROUP BY mp.plan_id, mbid.period_type, mpsd.period_start_date, mbid.detail_date, NVL(mbid.detail_level, 0),
              CUBE(mpo.sr_instance_id, mpo.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
           HAVING (
              GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
              GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 OR
              GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
              GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
           );

         ELSIF p_period_type = CALENDAR_TYPE_BIS THEN

            INSERT INTO msc_form_query
            (
            query_id,
            NUMBER1, -- PLAN_ID
            CREATED_BY, -- RECORD_TYPE
            NUMBER9, -- achieved_ss_qty
            NUMBER10,
            NUMBER11,
            NUMBER12,
            NUMBER13,
            NUMBER14,
            NUMBER15,
            NUMBER16,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID, -- achieved_sl
            LAST_UPDATE_LOGIN, -- target_sl
            NUMBER6, -- inventory_value_dollars
            NUMBER7, -- period_type
            DATE1, -- week_start_date
            DATE3, -- period_start_date
            NUMBER2, -- sr_instance_id
            NUMBER3, -- org_id
            REQUEST_ID, -- sr_cat_instance_id
            NUMBER5, -- sr_category_id
            CHAR1, -- category_name
            NUMBER4, -- inventory_item_id
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE
            )
          SELECT
             p_query_id,
             mp.plan_id,
             RECORD_INVENTORY_VALUE AS record_type,
             NULL AS achieved_ss_qty,
             NULL AS achieved_ss_dollars,
             NULL AS achieved_ss_days,
             NULL AS target_ss_qty,
             NULL AS target_ss_dollars,
             NULL AS target_ss_days,
             NULL AS userdef_ss_qty,
             NULL AS userdef_ss_dollars,
             NULL AS userdef_ss_days,
             NULL AS achieved_sl,
             NULL AS target_service_level,
             SUM(nvl(mbid.inventory_value, 0)) AS inventory_value_dollars,
             CALENDAR_TYPE_BIS AS period_type,
             NULL AS week_start_date,
             mpsd.start_date,
             mpo.sr_instance_id AS instance_id,
             mpo.organization_id AS org_id,
             mic.sr_instance_id AS sr_cat_instance_id,
             mic.sr_category_id AS sr_category_id,
             mic.category_name AS category_name,
             NULL AS item_id,
             SYSDATE AS last_update_date,
             -1 AS last_updated_by,
             SYSDATE AS CREATION_DATE
          FROM msc_plans mp, msc_plan_organizations mpo, msc_bis_inv_detail mbid, msc_system_items mis, msc_item_categories mic,
               msc_bis_periods mpsd
         WHERE mp.plan_id = l_planlist(l_index)
           AND mp.plan_id = mpo.plan_id
           AND mpo.plan_id = mbid.plan_id
           AND mpo.organization_id = mbid.organization_id
           AND mpo.sr_instance_id = mbid.sr_instance_id
           AND mpo.sr_instance_id = nvl(l_sr_instance_id, mpo.sr_instance_id)
           AND mpo.organization_id = nvl(l_sr_tp_id, mpo.organization_id)
           AND nvl(mbid.period_type, CALENDAR_TYPE_BIS) = CALENDAR_TYPE_BIS
           AND mbid.plan_id = mis.plan_id
           AND mbid.organization_id = mis.organization_id
           AND mbid.sr_instance_id = mis.sr_instance_id
           AND mbid.inventory_item_id = mis.inventory_item_id
           AND nvl(mis.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(mis.abc_class_name, 'XXXXX'))
           AND mis.budget_constrained = BUDGET_CONSTRAINED_ON
           AND mis.organization_id = mic.organization_id
           AND mis.sr_instance_id = mic.sr_instance_id
           AND mis.inventory_item_id = mic.inventory_item_id
           AND mic.category_set_id = l_default_category_set_id
           AND mic.sr_instance_id = nvl(l_sr_cat_instance_id, mic.sr_instance_id)
           AND mic.sr_category_id = nvl(l_sr_cat_id, mic.sr_category_id)
           AND mp.sr_instance_id = mpsd.sr_instance_id
           AND mp.organization_id = mpsd.organization_id
           AND mpsd.period_set_name = 'Accounting'
           AND mbid.detail_date = mpsd.START_DATE
           GROUP BY mp.plan_id, mbid.period_type, mpsd.start_date, mbid.detail_date, NVL(mbid.detail_level, 0),
              CUBE(mpo.sr_instance_id, mpo.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
           HAVING (
              GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
              GROUPING(mpo.sr_instance_id) = 1 AND GROUPING(mpo.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 OR
              GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
              GROUPING(mpo.sr_instance_id) = 0 AND GROUPING(mpo.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
           );
         END IF;

      END LOOP;

   END schedule_details_iv;

   PROCEDURE schedule_details_ss(query_id OUT NOCOPY NUMBER, plan_id IN VARCHAR2, org_id IN VARCHAR2, cat_id IN VARCHAR2,
             item_id IN NUMBER)
   IS
      weekschedule       Schedule;
      periodschedule     Schedule;
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

         schedule_create_weeks(weekschedule, l_planlist(l_index));
         schedule_create_periods(periodschedule, l_planlist(l_index));

         schedule_bucket_safety_stock(weekschedule, periodschedule, l_planlist(l_index),
            sr_instance_id, sr_tp_id, sr_cat_instance_id, sr_cat_id, item_id, query_Id);
      END LOOP;
   END schedule_details_ss;

   PROCEDURE schedule_details_sl(p_query_id OUT NOCOPY NUMBER, p_period_type NUMBER, plan_id IN VARCHAR2,
      org_id IN VARCHAR2, cat_id IN VARCHAR2, p_item_id IN NUMBER, customer_id IN NUMBER,
      customer_class_code IN VARCHAR2, p_abc_id IN VARCHAR2)
   IS
      weekschedule       Schedule;
      periodschedule     Schedule;
      l_sr_instance_id     NUMBER;
      l_sr_tp_id           NUMBER;
      l_sr_cat_instance_id NUMBER;
      l_sr_cat_id          NUMBER;
      l_planlist         PlanList;
      l_index            BINARY_INTEGER;
      l_default_category_set_id NUMBER;

   BEGIN

      -- Get default category set
      l_default_category_set_id := get_cat_set_id(plan_id);

      SELECT msc_form_query_s.nextval
        INTO p_query_id
      FROM dual;

      IF org_id IS NOT NULL THEN
         l_sr_instance_id := get_inst_id_from_org_key(org_id);
         l_sr_tp_id := get_sr_tp_id_from_org_key(org_id);
      END IF;

      IF cat_id IS NOT NULL THEN
         l_sr_cat_instance_id := get_inst_id_from_category_key(cat_id);
         l_sr_cat_id := get_sr_cat_id_from_cat_key(cat_id);
      END IF;

      parse_planlist(plan_id, l_planlist);
      IF l_planlist.COUNT = 0 THEN
         p_query_id := -1;
         RETURN;
      END IF;

      FOR l_index IN l_planlist.FIRST..l_planlist.LAST LOOP
         IF validate_plan(l_planlist(l_index)) = FALSE THEN
            p_query_id := -1;
            RETURN;
         END IF;

         IF p_period_type = CALENDAR_TYPE_MFG THEN

            schedule_create_weeks(weekschedule, l_planlist(l_index));
            schedule_create_periods(periodschedule, l_planlist(l_index));

            schedule_bucket_service_level(weekschedule, periodschedule, l_planlist(l_index),
               l_sr_instance_id, l_sr_tp_id,
               l_sr_cat_instance_id, l_sr_cat_id, p_item_id, customer_id, customer_class_code,p_abc_id,p_query_Id);
         ELSIF p_period_type = CALENDAR_TYPE_BIS THEN
         -- BIS implies Inventory Budget report: No items, no customer/customer class
            INSERT INTO msc_form_query
            (
            query_id,
            NUMBER1, -- PLAN_ID
            CREATED_BY, -- RECORD_TYPE
            NUMBER9, -- achieved_ss_qty
            NUMBER10,
            NUMBER11,
            NUMBER12,
            NUMBER13,
            NUMBER14,
            NUMBER15,
            NUMBER16,
            PROGRAM_ID,
            PROGRAM_APPLICATION_ID, -- achieved_sl  --_qty2
            LAST_UPDATE_LOGIN, -- target_sl
            NUMBER6, -- inventory_value_dollars
            NUMBER7, -- period_type
            DATE1, -- week_start_date
            DATE3, -- period_start_date
            NUMBER2, -- sr_instance_id
            NUMBER3, -- org_id
            REQUEST_ID, -- sr_cat_instance_id
            NUMBER5, -- sr_category_id
            CHAR1,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE
            )
            SELECT
               p_query_id,
               msd.plan_id,
               RECORD_SERVICE_LEVEL AS record_type,
               NULL AS achieved_ss_qty,
               NULL AS achieved_ss_dollars,
               NULL AS achieved_ss_days,
               NULL AS target_ss_qty,
               NULL AS target_ss_dollars,
               NULL AS target_ss_days,
               NULL AS userdef_ss_qty,
               NULL AS userdef_ss_dollars,
               NULL AS userdef_ss_days,
               sum(nvl(msd.old_demand_quantity,0) * nvl(msd.probability,1)) * 100 /
               sum(nvl(msd.using_requirement_quantity, 0) * nvl(msd.probability,1)) AS achieved_sl,
               decode(count(*), 0, 50, sum(nvl(msd.service_level, 50)) / COUNT(*)) AS target_service_level,
               NULL AS inventory_value_dollars,
               CALENDAR_TYPE_BIS AS period_type,
               NULL AS week_start_date,
               msbp.START_DATE AS period_start_date,
               msd.sr_instance_id AS instance_id,
               msd.organization_id AS org_id,
               mic.sr_instance_id AS sr_cat_instance_id,
               mic.sr_category_id AS sr_category_id,
               mic.category_name AS category_name,
               SYSDATE,
               -1,
               SYSDATE
          FROM msc_plans mp, msc_plan_organizations mpo, msc_demands msd, msc_system_items msi,
               msc_item_categories mic, msc_bis_periods msbp
         WHERE mp.plan_id = l_planlist(l_index)
           AND mp.plan_id = mpo.plan_id
           AND msd.organization_id = mpo.organization_id
           AND msd.sr_instance_id = mpo.sr_instance_id
           AND msd.plan_id = mpo.plan_id
           AND msd.origination_type IN (6,7,8,9,11,12,15,22,28,29,30)
           AND msd.plan_id = msi.plan_id
           AND msd.sr_instance_id = msi.sr_instance_id
           AND msd.organization_id = msi.organization_id
           AND msd.inventory_item_id = msi.inventory_item_id
           AND nvl(msi.abc_class_name, 'XXXXX') = nvl(p_abc_id, nvl(msi.abc_class_name, 'XXXXX'))
           AND msi.inventory_item_id = NVL(p_item_id, msi.inventory_item_id)
           AND msi.organization_id = mic.organization_id
           AND msi.sr_instance_id = mic.sr_instance_id
           AND msi.inventory_item_id = mic.inventory_item_id
           AND mic.category_set_id = l_default_category_set_id
           AND mpo.sr_instance_id = nvl(l_sr_instance_id, mpo.sr_instance_id)
           AND mpo.organization_id = nvl(l_sr_tp_id, mpo.organization_id)
           AND mic.sr_instance_id = nvl(l_sr_cat_instance_id, mic.sr_instance_id)
           AND mic.sr_category_id = nvl(l_sr_cat_id, mic.sr_category_id)
           AND mp.sr_instance_id = msbp.sr_instance_id
           AND mp.organization_id = msbp.organization_id
           AND msbp.period_set_name = 'Accounting'
           AND TRUNC(msd.using_assembly_demand_date) BETWEEN msbp.START_DATE AND msbp.end_date
        GROUP BY msd.plan_id, msbp.start_date,
        CUBE (msd.sr_instance_id, msd.organization_id, mic.sr_instance_id, mic.sr_category_id, mic.category_name)
        HAVING (
         GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
         GROUPING (msd.sr_instance_id) = 1 AND GROUPING (msd.organization_id) = 1 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0 OR
         GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 1 AND GROUPING(mic.sr_category_id) = 1 AND GROUPING(mic.category_name) = 1 OR
         GROUPING (msd.sr_instance_id) = 0 AND GROUPING (msd.organization_id) = 0 AND GROUPING(mic.sr_instance_id) = 0 AND GROUPING(mic.sr_category_id) = 0 AND GROUPING(mic.category_name) = 0
        );
         END IF;
      END LOOP;

   END schedule_details_sl;

      function manage_partitions(p_plan_id number, p_part_mode number) return number is
   l_partitioned_table varchar2(100);
   l_partition_name varchar2(300);
   sql_stmt varchar2(300);
   dummy1       varchar2(50);
   dummy2       varchar2(50);
   l_applsys_schema  varchar2(100);
   errbuf varchar2(2000);
   retcode number := 0;

 begin
    IF (fND_INSTALLATION.GET_APP_INFO('FND',dummy1,dummy2,l_applsys_schema) = FALSE) then
      retcode := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('MSC','MSC_PART_UNDEFINED_SCHEMA');
      errbuf := fnd_message.get;
      put_line(errbuf);
      return retcode;
    end if;

    l_partitioned_table :='MSC_ANALYSIS_AGGREGATE';
    l_partition_name := substr(l_partitioned_table,5)||'_'||to_char(p_plan_id);

    if (p_part_mode = 1) then
      -- create partitions
      sql_stmt := 'alter table ' || l_partitioned_table || ' add partition '
                || l_partition_name || ' values less than ('|| to_char(p_plan_id+1) || ')';
    elsif (p_part_mode = 2) then
      --drop partitions
      sql_stmt := 'alter table ' || l_partitioned_table || ' drop partition '|| l_partition_name ;
    end if;

    put_line(sql_stmt);
    ad_ddl.do_ddl(l_applsys_schema,'MSC', ad_ddl.alter_table,sql_stmt,l_partitioned_table);

    return retcode;
    exception
      when others then
        retcode := 1;
        errbuf := 'Error in manage_partitions api '||SQLCODE||' -ERROR- '||SQLERRM;
        put_line(errbuf);
        return retcode;
  end manage_partitions;


   PROCEDURE schedule_aggregate(p_plan_id IN NUMBER)
   IS
      weekschedule       Schedule;
      periodschedule     Schedule; l_part_retval NUMBER;
      l_temp number;
      lv_share_partition varchar2(2);


   BEGIN
      IF validate_plan(p_plan_id) = FALSE THEN
         RETURN;
      END IF;

      g_user_id := fnd_global.user_id;

      select count(*) into l_temp from sys.all_tab_partitions where table_name = 'MSC_ANALYSIS_AGGREGATE'
      AND PARTITION_NAME = 'ANALYSIS_AGGREGATE_'||P_PLAN_ID;
      lv_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

      if (l_temp = 0 and lv_share_partition <> 'Y')then --create partition
        l_part_retval := manage_partitions(p_plan_id, 1);
        if (l_part_retval <> 0) then
          put_line('Error while creating partitions ');
        end if;
        put_line('partition created '|| l_part_retval);
        --dbms_output.put_line('partition created '|| l_part_retval);
      else
        DELETE FROM msc_analysis_aggregate WHERE plan_id = p_plan_id;
      end if;

     COMMIT;


      schedule_aggregate_sl(p_plan_id);
      COMMIT;
      --dbms_output.put_line('schedule aggregate sl');

      schedule_aggregate_iv(p_plan_id);
      COMMIT;

      schedule_aggregate_sl_brkdown(p_plan_id);
      COMMIT;
      --dbms_output.put_line('schedule aggregate sl brkdown');

      schedule_create_weeks(weekschedule, p_plan_id);
      schedule_create_periods(periodschedule, p_plan_id);
      schedule_aggregate_ss(weekschedule, periodschedule, p_plan_id);
      --dbms_output.put_line('schedule aggregate ss');
      COMMIT;

      schedule_aggregate_cost(p_plan_id);
      COMMIT;
   END schedule_aggregate;

END MSC_ANALYSIS_SAFETY_STOCK_PERF;

/
