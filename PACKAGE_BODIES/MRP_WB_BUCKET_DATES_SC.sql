--------------------------------------------------------
--  DDL for Package Body MRP_WB_BUCKET_DATES_SC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_WB_BUCKET_DATES_SC" AS
/* $Header: MRPPWBBB.pls 115.10 2004/04/05 21:52:03 skanta ship $ */

DAILY_BUCKET	CONSTANT INTEGER := 1;
WEEKLY_BUCKET	CONSTANT INTEGER := 2;
PERIODIC_BUCKET	CONSTANT INTEGER := 3;
--
HP_DAILY_BUCKET	CONSTANT INTEGER := 4;
HP_WEEKLY_BUCKET	CONSTANT INTEGER := 5;
HP_PERIODIC_BUCKET	CONSTANT INTEGER := 6;

MAX_BUCKETS     CONSTANT INTEGER := 36;
var_plan_start_date DATE;

-- ==============================================================
-- This procedure populates one row in MRP_WORKBENCH_BUCKET_DATES
-- ==============================================================
PROCEDURE populate_row(arg_organization_id IN NUMBER,
                       arg_planned_organization IN NUMBER,
      		       arg_compile_designator IN VARCHAR2,
                       arg_bucket_type IN NUMBER,
                       arg_bucket_desc IN VARCHAR2 DEFAULT NULL,
                       arg_num_days IN NUMBER DEFAULT NULL,
                       arg_num_weeks IN NUMBER DEFAULT NULL) IS

TYPE calendar_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

var_calendar_code	VARCHAR2(10); -- Calendar Code
var_exception_set_id	NUMBER;	      -- Exception set id
var_num_days	NUMBER;		      -- Number of days
var_num_weeks	NUMBER;		      -- Number of weeks
var_num_periods	NUMBER;		      -- Number of periods
var_user_id	NUMBER;		      -- User id
var_the_date	DATE;		      -- Last fetched date
counter	BINARY_INTEGER := 0;	      -- Array counter

-- -------------------------------------------------------------------
-- Date array to store days/weeks/periods this array will be used to
-- insert into MRP_WORKBENCH_BUCKET_DATES.  It will have the following
-- data in it
-- 1 ... arg_num_days 					Daily
-- arg_num_days + 1 ... arg_num_days + arg_num_weeks	Weekly
-- arg_num_daye + arg_num_weeks + 1 ... MAX_BUCKETS + 1	Periodic
-- -------------------------------------------------------------------
var_dates	CALENDAR_DATE;
var_dates1	CALENDAR_DATE;


BEGIN
/* $Header: MRPPWBBB.pls 115.10 2004/04/05 21:52:03 skanta ship $ */

 -- -------------------------
 -- Get the calendat defaults
 -- -------------------------
 --  dbms_output.put_line('Getting defaults');

 mrp_calendar.select_calendar_defaults(arg_planned_organization,
                              var_calendar_code,
                              var_exception_set_id);
   --dbms_output.put_line('Got defaults');

 -- ----------------------------------------------
 -- Figure out each number of buckets of each type
 -- ----------------------------------------------
 IF (arg_bucket_type = DAILY_BUCKET OR arg_bucket_type = HP_DAILY_BUCKET )
          OR (arg_bucket_type = -1 OR arg_bucket_type = -4) THEN

  --dbms_output.put_line('Creating daily buckets');
  var_num_days	  := MAX_BUCKETS;
  var_num_weeks   := 0;
  var_num_periods := 0;
 ELSIF (arg_bucket_type = WEEKLY_BUCKET OR arg_bucket_type = HP_WEEKLY_BUCKET)
              OR (arg_bucket_type = -2 OR arg_bucket_type = -5) THEN

  --dbms_output.put_line('Creating weekly buckets');
  var_num_days	  := 0;
  var_num_weeks   := MAX_BUCKETS;
  var_num_periods := 0;
 ELSIF (arg_bucket_type = PERIODIC_BUCKET OR arg_bucket_type = HP_PERIODIC_BUCKET)
               OR (arg_bucket_type = -3 OR arg_bucket_type = -6 ) THEN

  --dbms_output.put_line('Creating periodic buckets');
  var_num_days	  := 0;
  var_num_weeks   := 0;
  var_num_periods := MAX_BUCKETS;
 ELSE

  --dbms_output.put_line('Creating customized buckets');
  DECLARE dummy NUMBER;
  BEGIN
   SELECT count(*)
   INTO   dummy
   FROM   mfg_lookups
   WHERE  lookup_type = 'MRP_WORKBENCH_BUCKET_TYPE'
   AND    lookup_code = arg_bucket_type;

   IF dummy = 0 THEN
    -- -------------------------------------
    -- The bucket type is not in MFG_LOOKUPS
    -- -------------------------------------
    --dbms_output.put_line('Creating new lookup');
    INSERT INTO mfg_lookups
    	(lookup_type,
	 lookup_code,
	 last_update_date,
	 last_updated_by,
	 creation_date,
	 created_by,
	 meaning,
         enabled_flag)
    VALUES
	('MRP_WORKBENCH_BUCKET_TYPE',
         arg_bucket_type,
         SYSDATE,
         -1,
         SYSDATE,
         -1,
         NVL(arg_bucket_desc , '???'),
         'Y');
   END IF;
  END;

  -- ----------------------------------------------------
  -- If num days is negative then make it zero.
  -- If num days is greater than MAX_BUCKETS then make it
  -- MAX_BUCKETS.
  -- ----------------------------------------------------
  var_num_days := LEAST(GREATEST(arg_num_days,0), MAX_BUCKETS);

  -- ------------------------------------------------------
  -- If num weeks is negative then make it zero.
  -- If num weeks is greater that MAX_BUCKETS minus num days
  -- make it MAX_BUCKETS minus num days
  -- ------------------------------------------------------
  var_num_weeks := LEAST(GREATEST(arg_num_weeks,0),MAX_BUCKETS-var_num_days);

  -- ------------------------------
  -- Make num periods the left over
  -- ------------------------------
  var_num_periods := MAX_BUCKETS - var_num_days - var_num_weeks;

 END IF;

 --dbms_output.put_line('Number of days   :'||var_num_days);
 --dbms_output.put_line('Number of weeks  :'||var_num_weeks);
 --dbms_output.put_line('Number of periods:'||var_num_periods);

 var_the_date := var_plan_start_date;
 --dbms_output.put_line('var_the_date: '||var_the_date);


 IF var_num_days > 0 THEN

  -- --------------------------------------------------------------------
  -- The DAYS cursor gets at most num_days + 1 workdays from the calendar
  -- beginning at the plan start_date
  -- --------------------------------------------------------------------
  DECLARE CURSOR DAYS IS
  SELECT  calendar_date
  FROM 	  bom_calendar_dates
  WHERE   calendar_code = var_calendar_code
  AND     exception_set_id = var_exception_set_id
  AND     seq_num IS NOT NULL
  AND     calendar_date >= var_the_date
--  AND     rownum <= var_num_days + 1
  ORDER BY calendar_date;
  --
  -- bug 3468984
  CURSOR HP_DAYS IS
  SELECT  calendar_date
  FROM    bom_calendar_dates
  WHERE   calendar_code = var_calendar_code
  AND     exception_set_id = var_exception_set_id
  --AND     seq_num IS NOT NULL
  AND     calendar_date >= var_the_date
--  AND     rownum <= var_num_days + 1
  ORDER BY calendar_date;

   BEGIN
   OPEN DAYS;
   -- -------------------------------------------------------------
   -- Get the days portion and place it in the front section of the
   -- array var_the_dates
   -- -------------------------------------------------------------
   LOOP
    counter := counter + 1;
    FETCH DAYS INTO var_dates(counter);
    EXIT WHEN DAYS%NOTFOUND;
    IF counter > var_num_days +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates(counter);
   END LOOP;
   counter := counter - 1;
   CLOSE DAYS;
   --
  counter := 0;
  var_the_date := var_plan_start_date;
    OPEN HP_DAYS;
  LOOP
    counter := counter + 1;
    FETCH HP_DAYS INTO var_dates1(counter);
    EXIT WHEN HP_DAYS%NOTFOUND;
    IF counter > var_num_days +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates1(counter);
  END LOOP;
  counter := counter - 1;
  CLOSE HP_DAYS;
  END;
 END IF; -- var_num_days

 IF var_num_weeks > 0 THEN

  -- -----------------------------------------------------------------
  -- The WEEKS cursor gets at most num_weeks workdays from the calendar
  -- beginning at var_the_date.
  --
  -- NOTE
  -- If we are doing only weeks then the first week should be the
  -- beginning of the week that include var_the_date
  -- -----------------------------------------------------------------
  DECLARE CURSOR WEEKS IS
  SELECT  week_start_date
  FROM 	  bom_cal_week_start_dates
  WHERE   calendar_code = var_calendar_code
  AND     exception_set_id = var_exception_set_id
  AND     seq_num IS NOT NULL
  AND     week_start_date >=  var_the_date + DECODE(counter, 0, 0, 1)
--  AND     rownum <= var_num_weeks + DECODE(counter, 0, 1, 0)
  ORDER BY week_start_date;
  --
  CURSOR HP_WEEKS IS
  SELECT  week_start_date
  FROM 	  bom_cal_week_start_dates
  WHERE   calendar_code = var_calendar_code
  AND     exception_set_id = var_exception_set_id
  --AND     seq_num IS NOT NULL
  AND     week_start_date >=  var_the_date + DECODE(counter, 0, 0, 1)
--  AND     rownum <= var_num_weeks + DECODE(counter, 0, 1, 0)
  ORDER BY week_start_date;

  BEGIN

   IF counter = 0 THEN

    var_the_date := mrp_calendar.prev_work_day(arg_planned_organization,
           				        WEEKLY_BUCKET,
						var_the_date);
   END IF;
   OPEN WEEKS;
   -- --------------------------------------------------------------
   -- Get the weeks portion and place it in the front section of the
   -- array var_the_dates
   -- --------------------------------------------------------------
   LOOP
    counter := counter + 1;
    FETCH WEEKS INTO var_dates(counter);
    EXIT WHEN WEEKS%NOTFOUND;
    IF counter > var_num_weeks +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates(counter);
   END LOOP;
   CLOSE WEEKS;
   counter := counter - 1;
--
  counter := 0;
  var_the_date := var_plan_start_date;
   var_the_date := mrp_calendar.prev_work_day(arg_planned_organization,
                                                WEEKLY_BUCKET,
                                                var_the_date);
    OPEN HP_WEEKS;
   LOOP
    counter := counter + 1;
    FETCH HP_WEEKS INTO var_dates1(counter);
    EXIT WHEN HP_WEEKS%NOTFOUND;
    IF counter > var_num_weeks +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates1(counter);
   END LOOP;
   CLOSE HP_WEEKS;
   counter := counter - 1;
  END;
 END IF; -- var_num_weeks

 IF var_num_periods > 0 THEN

  -- -----------------------------------------------------------------
  -- The WEEKS cursor gets at most num_days workdays from the calendar
  -- beginning at the plan start_date
  -- -----------------------------------------------------------------
  DECLARE CURSOR PERIODS IS
  SELECT  period_start_date
  FROM 	  bom_period_start_dates
  WHERE   calendar_code = var_calendar_code
  AND     exception_set_id = var_exception_set_id
  AND     period_start_date >=   var_the_date + DECODE(counter, 0, 0, 1)
--  AND     rownum <= var_num_periods + DECODE(counter, 0, 1, 0)
  ORDER BY period_start_date;

  BEGIN

   IF counter = 0 THEN
    var_the_date := mrp_calendar.prev_work_day(arg_planned_organization,
           					PERIODIC_BUCKET,
						var_the_date);
   END IF;

   OPEN PERIODS;
   -- --------------------------------------------------------------
   -- Get the weeks portion and place it in the front section of the
   -- array var_the_dates
   -- --------------------------------------------------------------
   LOOP
    counter := counter + 1;
    FETCH PERIODS INTO var_dates(counter);
    EXIT WHEN PERIODS%NOTFOUND;
    IF counter > var_num_periods +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates(counter);
   END LOOP;
   counter := counter - 1;
   CLOSE PERIODS;
   --
    counter := 0;
  var_the_date := var_plan_start_date;
   var_the_date := mrp_calendar.prev_work_day(arg_planned_organization,
                                                PERIODIC_BUCKET,
                                                var_the_date);

   OPEN PERIODS;
   LOOP
    counter := counter + 1;
    FETCH PERIODS INTO var_dates1(counter);
    EXIT WHEN PERIODS%NOTFOUND;
    IF counter > var_num_periods +1 THEN
      EXIT;
    END IF;
    var_the_date := var_dates1(counter);
   END LOOP;
   counter := counter - 1;
   CLOSE PERIODS;

  END;
 END IF; -- var_num_periods

 IF counter < MAX_BUCKETS + 1 THEN

  -- -----------------------------------------------------------
  -- This means that there weren't enough days ,weeks and months
  -- to fill out all the columns in the table. We will set the
  -- remaining columns with one day increment from the last date
  -- -----------------------------------------------------------
  --dbms_output.put_line('There were not enough dates');
  --dbms_output.put_line('The date counter is: '||counter);
  IF counter <= 1 THEN

   -- ----------------------------------------------------
   -- We found no dates at all. Set the first entry in the
   -- var_dates array to avoid an out of bounds exception
   -- in the loop bellow.
   -- ----------------------------------------------------
   --dbms_output.put_line('There were no dates');
   counter := 1;
   var_dates(counter) := var_the_date;
   var_dates1(counter) := var_the_date;
   --dbms_output.put_line('Set first date to '||var_dates(counter));
  END IF;

  FOR j IN (counter + 1) .. MAX_BUCKETS + 1 LOOP

   -- ----------------------------------------------------------
   -- Set the current element of the var_dates array to one plus
   -- the previous elemnt
   -- ----------------------------------------------------------
   var_dates(j) := var_dates(j - 1) + 1;
   var_dates1(j) := var_dates(j - 1) + 1;
   --dbms_output.put_line('Set date '||j||' to:'||var_dates(j));
  END LOOP;
 END IF; -- < MAX_BUCKETS

 -- ----------------------------------------------------------
 -- Insert the var_dates array into MRP_WORKBENCH_BUCKET_DATES
 -- ----------------------------------------------------------
 var_user_id := FND_PROFILE.VALUE('USER_ID');
 IF arg_bucket_type in (1,2,3,-1,-2,-3) THEN
 INSERT INTO mrp_workbench_bucket_dates
	(organization_id,
        planned_organization,
	compile_designator,
	bucket_type,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by,
 	date1,  date2,  date3,  date4,   date5,  date6,
	date7,  date8,  date9,  date10,  date11, date12,
	date13, date14, date15, date16, date17, date18,
	date19, date20, date21, date22, date23, date24,
	date25, date26, date27, date28, date29, date30,
	date31, date32, date33, date34, date35, date36,
	date37)
 VALUES
	(arg_organization_id,
        arg_planned_organization,
	arg_compile_designator,
	arg_bucket_type,
	SYSDATE,
	-1, -- var_user_id,
	SYSDATE,
	-1, -- var_user_id,
 	var_dates(1),  var_dates(2),  var_dates(3),  var_dates(4),
	var_dates(5),  var_dates(6),  var_dates(7),  var_dates(8),
	var_dates(9),  var_dates(10), var_dates(11), var_dates(12),
	var_dates(13), var_dates(14), var_dates(15), var_dates(16),
	var_dates(17), var_dates(18), var_dates(19), var_dates(20),
	var_dates(21), var_dates(22), var_dates(23), var_dates(24),
	var_dates(25), var_dates(26), var_dates(27), var_dates(28),
	var_dates(29), var_dates(30), var_dates(31), var_dates(32),
	var_dates(33), var_dates(34), var_dates(35), var_dates(36),
	var_dates(37));
  --
 ELSE
  INSERT INTO mrp_workbench_bucket_dates
        (organization_id,
        planned_organization,
        compile_designator,
        bucket_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        date1,  date2,  date3,  date4,   date5,  date6,
        date7,  date8,  date9,  date10,  date11, date12,
        date13, date14, date15, date16, date17, date18,
        date19, date20, date21, date22, date23, date24,
        date25, date26, date27, date28, date29, date30,
        date31, date32, date33, date34, date35, date36,
        date37)
 VALUES
        (arg_organization_id,
        arg_planned_organization,
        arg_compile_designator,
        arg_bucket_type,
        SYSDATE,
        -1, -- var_user_id,
        SYSDATE,
        -1, -- var_user_id,
        var_dates1(1),  var_dates1(2),  var_dates1(3),  var_dates1(4),
        var_dates1(5),  var_dates1(6),  var_dates1(7),  var_dates1(8),
        var_dates1(9),  var_dates1(10), var_dates1(11), var_dates1(12),
        var_dates1(13), var_dates1(14), var_dates1(15), var_dates1(16),
        var_dates1(17), var_dates1(18), var_dates1(19), var_dates1(20),
        var_dates1(21), var_dates1(22), var_dates1(23), var_dates1(24),
        var_dates1(25), var_dates1(26), var_dates1(27), var_dates1(28),
        var_dates1(29), var_dates1(30), var_dates1(31), var_dates1(32),
        var_dates1(33), var_dates1(34), var_dates1(35), var_dates1(36),
        var_dates1(37));
  END IF;
END populate_row;


-- ====================================================================
-- Create all rows in MRP_WORKBENCH_BUCKET_DATES
-- ====================================================================
PROCEDURE populate_bucket_dates ( arg_organization_id IN NUMBER,
                                  arg_compile_designator IN VARCHAR2,
                                  arg_planned_organization IN NUMBER DEFAULT NULL) IS

var_current_start_date	DATE;		-- Current first date in
					-- MRP_WORKBENCH_BUCKET_DATES
recreate	BOOLEAN := FALSE;
var_curr_start_date1 DATE;  -- Current first date in MRP_WORKBENCH_BUCKET_DATES
                            -- for current data.
recreate1   BOOLEAN := FALSE;

BEGIN

 -- --------------------------------------------------
 -- First figure out if we need to do recreate rows in
 -- MRP_WORKBENCH_BUCKET_DATES
 -- apatanka -- Fix for Bug No. 353458
 -- MRP workbench duplicate rows.
 -- --------------------------------------------------

 BEGIN

  SELECT date1
  INTO   var_current_start_date
  FROM 	 mrp_workbench_bucket_dates
  WHERE  compile_designator = arg_compile_designator
  AND	 organization_id = arg_organization_id
--  AND    planned_organization = arg_planned_organization
  AND    NVL(planned_organization,organization_id) = arg_planned_organization
  AND    bucket_type = HP_DAILY_BUCKET;


  EXCEPTION WHEN NO_DATA_FOUND THEN

   -- -------------------------------------------
   -- There are no rows so we need to create them
   -- -------------------------------------------
   recreate := TRUE;
  -- dbms_output.put_line('No rows exist. Will recreate them');

 END;

 --  ------------------------------------------------------
 --  We will select the first date for current data buckets
 --  -------------------------------------------------------
 BEGIN

    SELECT date1
    INTO    var_curr_start_date1
    FROM    mrp_workbench_bucket_dates
    WHERE   compile_designator = arg_compile_designator
    AND     NVL(planned_organization, organization_id) =
				arg_planned_organization
    AND     bucket_type = -4;

   -- dbms_output.put_line('Current Start Date for Current Data is '||
    --    var_curr_start_date1);
 EXCEPTION WHEN NO_DATA_FOUND THEN
    recreate1 := TRUE;
    --dbms_output.put_line('No rows exist for Current Data Buckets.
     --   Will recreate them');
 END;


 SELECT TRUNC(plan_start_date)
 INTO	var_plan_start_date
 FROM	mrp_plans
 WHERE  compile_designator = arg_compile_designator
 AND	organization_id = arg_organization_id;

 var_plan_start_date := mrp_calendar.next_work_day(arg_planned_organization,
						   DAILY_BUCKET,
           					   var_plan_start_date);


 IF (var_plan_start_date <> var_current_start_date) THEN

   -- ------------------------------------------------------------------
   -- The plan start date has changed since the last time the rows where
   -- created so we need to recreate them
   -- ------------------------------------------------------------------
   recreate := TRUE;

 END IF;

 IF (var_curr_start_date1 <> TRUNC(sysdate)) THEN
    -- -------------------------------------------------------------------
    -- The start date for current data buckets is changed so we need to
    -- recreate them
    -- -------------------------------------------------------------------
    recreate1 := TRUE;
 END IF;


 IF recreate = TRUE THEN

  DELETE mrp_workbench_bucket_dates
  WHERE  compile_designator = arg_compile_designator
  AND    organization_id    = arg_organization_id
  AND    NVL(planned_organization,organization_id) = arg_planned_organization
  AND    bucket_type IN (DAILY_BUCKET, WEEKLY_BUCKET, PERIODIC_BUCKET,HP_DAILY_BUCKET,HP_WEEKLY_BUCKET,HP_PERIODIC_BUCKET);

-- apatanka
--  AND    planned_organization = arg_planned_organization;
   --dbms_output.put_line('Blah');

  DELETE mrp_material_plans
  WHERE  compile_designator = arg_compile_designator
  AND    organization_id    = arg_organization_id;
   --dbms_output.put_line('Blah');


  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   DAILY_BUCKET);
   --dbms_output.put_line('Blah');

  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   WEEKLY_BUCKET);

  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   PERIODIC_BUCKET);
  --
  -- Populate data for HP
  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   HP_DAILY_BUCKET);

  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   HP_WEEKLY_BUCKET);

  mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
                                   arg_planned_organization,
                                   arg_compile_designator,
                                   HP_PERIODIC_BUCKET);

  mrp_custom_wb.mrp_custom_wb_bucket_dates(arg_organization_id,
                             arg_compile_designator);

 --ELSE
  -- ----------------------------------
  -- Return because nothing has changed
  -- ----------------------------------
  --dbms_output.put_line('Nothing has changed');
 END IF;

    -- ------------------------------------------
    -- We will recreate buckets for current data
    -- ------------------------------------------
    IF recreate1 = TRUE THEN

        -- ----------------------------------------------
        -- Reset var_plan_start_date to sysdate
        -- ----------------------------------------------
        var_plan_start_date := TRUNC(sysdate);
        BEGIN
        DELETE mrp_workbench_bucket_dates
        WHERE  compile_designator = arg_compile_designator
        AND    organization_id    = arg_organization_id
        AND    NVL(planned_organization,organization_id) =
					arg_planned_organization
        AND    bucket_type IN (-1, -2, -3,-4,-5,-6);
        EXCEPTION WHEN NO_DATA_FOUND THEN
         NULL;
        END;

        BEGIN
        DELETE mrp_material_plans
        WHERE  compile_designator = arg_compile_designator
        AND    organization_id    = arg_organization_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            NULL;
        END;

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
										arg_planned_organization,
                                       arg_compile_designator,
                                       -1);

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
									   arg_planned_organization,
                                       arg_compile_designator,
                                       -2);

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
									   arg_planned_organization,
                                       arg_compile_designator,
                                       -3);

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
										arg_planned_organization,
                                       arg_compile_designator,
                                       -4);

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
									   arg_planned_organization,
                                       arg_compile_designator,
                                       -5);

      mrp_wb_bucket_dates_sc.populate_row(arg_organization_id,
									   arg_planned_organization,
                                       arg_compile_designator,
                                       -6);

      mrp_custom_wb.mrp_custom_wb_bucket_dates(arg_organization_id,
                                 arg_compile_designator);
    --ELSE

      --dbms_output.put_line('Nothing has changed for Current data');

    END IF;

    COMMIT WORK;
END populate_bucket_dates;

END MRP_WB_BUCKET_DATES_sc;

/
