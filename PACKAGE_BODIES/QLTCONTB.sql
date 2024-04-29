--------------------------------------------------------
--  DDL for Package Body QLTCONTB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTCONTB" as
/* $Header: qltcontb.plb 120.2 2006/04/10 16:11:20 bso noship $ */

-- 3/19/96 - CREATED
-- Jacqueline Chang

  TYPE numbertable is TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  PROCEDURE X_BAR_R (sql_string VARCHAR2,
			subgrp_size NUMBER,
			num_subgroups IN OUT NOCOPY NUMBER,
			dec_prec NUMBER,
			grand_mean IN OUT NOCOPY NUMBER,
			range_average IN OUT NOCOPY NUMBER,
			UCL OUT NOCOPY NUMBER,
			LCL OUT NOCOPY NUMBER,
			R_UCL OUT NOCOPY NUMBER,
			R_LCL OUT NOCOPY NUMBER,
			not_enough_data OUT NOCOPY NUMBER,
			compute_new_limits IN BOOLEAN default FALSE) IS

  results_cursor	INTEGER;
  result		NUMBER;
  ignore		INTEGER;
  i			INTEGER;
  temp_results 		numbertable;
  rows_retrieved	INTEGER;
  num_points 		INTEGER;
  first_point		INTEGER;
  have_to_round		BOOLEAN := FALSE;
    -- have_to_round is true if we have to perform a MOD operation
    -- to make sure the number of points we're using is a multiple of
    -- the subgroup size

  subgroup_number	INTEGER;
  average_table	numbertable;
  range_table   numbertable;
  maximum	NUMBER;
  minimum	NUMBER;
  total		NUMBER;

  grand_mean_sum 	NUMBER := 0;
  range_sum		NUMBER := 0;

  -- variables to hold constants for computing control limits
  A2	NUMBER;
  D3	NUMBER;
  D4	NUMBER;


  BEGIN
    results_cursor := dbms_sql.open_cursor;
    dbms_sql.parse (results_cursor, sql_string, dbms_sql.v7);
    dbms_sql.define_column (results_cursor, 1, result);

    ignore := dbms_sql.execute(results_cursor);

    i := 0;
    LOOP
      IF dbms_sql.fetch_rows (results_cursor) > 0 THEN
        i := i + 1;
        dbms_sql.column_value(results_cursor, 1, result);

        temp_results(i) := result;

      ELSE
        -- no more results to fetch
        exit;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(results_cursor);

    rows_retrieved := i;
    IF rows_retrieved = 0 THEN
      -- no results entered
      not_enough_data := 1;
      RETURN;
    END IF;

    -- determine the first data point to use
    IF num_subgroups IS NOT NULL THEN
      num_points := subgrp_size * num_subgroups;
      first_point := rows_retrieved - num_points + 1;
      IF first_point < 1 THEN
        -- user specified more points than there are data points
        -- should give user a message here.
	have_to_round := TRUE;
      END IF;
    ELSE
      -- user didn't specify number of subgroups to use; use all data
      have_to_round := TRUE;
    END IF;

    IF have_to_round THEN
      -- this is only true when using all data points; mod using
      -- rows_retrieved
      num_subgroups := TRUNC (rows_retrieved / subgrp_size);
      IF num_subgroups < 1 THEN
	not_enough_data := 1;
	RETURN;
      END IF;

      first_point := MOD (rows_retrieved, subgrp_size) + 1;
    END IF;

    i := first_point;
    subgroup_number := 1;
    WHILE i <= rows_retrieved LOOP
      total := 0;
      maximum := temp_results(i);
      minimum := temp_results(i);

      FOR j IN 1..subgrp_size LOOP
        total := total + temp_results(i);
        IF temp_results(i) > maximum THEN
          maximum := temp_results(i);
        END IF;
        IF temp_results(i) < minimum THEN
          minimum := temp_results(i);
        END IF;

        i := i + 1;

      END LOOP;  -- for loop

      -- the following computations are performed per subgroup
      average_table(subgroup_number) := total / subgrp_size;
      range_table(subgroup_number) := maximum - minimum;

      subgroup_number := subgroup_number + 1;

    END LOOP;  -- while loop


    IF (NOT compute_new_limits) THEN
      -- want to populate qa_chart_data with latest data
      FOR j IN 1..num_subgroups LOOP
        INSERT INTO QA_CHART_DATA
  	  (LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   SUBGROUP_NUMBER,
           AVERAGE,
           RANGE,
	   BAR_NUMBER,
	   HIST_RANGE,
	   NUM_OCCURRENCES)
        VALUES
	  (SYSDATE,
	   1,
	   SYSDATE,
	   1,
	   NULL,
	   j,
	   average_table(j),
	   range_table(j),
	   null,
	   null,
	   null);
      END LOOP;

    ELSE
      -- compute new limits.

      FOR j IN 1..num_subgroups LOOP
        grand_mean_sum := grand_mean_sum + average_table(j);
        range_sum := range_sum + range_table(j);
      END LOOP;

      grand_mean := grand_mean_sum / num_subgroups;
      range_average := range_sum / num_subgroups;

      -- compute the control limits
      SELECT A2, D3, D4 INTO A2, D3, D4
      FROM QA_CHART_CONSTANTS
      WHERE SUBGROUP_SIZE = subgrp_size;

      UCL := round(grand_mean + (A2 * range_average), dec_prec);
      LCL := round(grand_mean - (A2 * range_average), dec_prec);

      R_UCL := round(D4 * range_average, dec_prec);
      R_LCL := round(D3 * range_average, dec_prec);

      grand_mean := round(grand_mean, dec_prec);
      range_average := round(range_average, dec_prec);

    END IF;

  END X_BAR_R;


  PROCEDURE X_BAR_S (sql_string VARCHAR2,
			subgrp_size NUMBER,
			num_subgroups IN OUT NOCOPY NUMBER,
			dec_prec NUMBER,
			grand_mean IN OUT NOCOPY NUMBER,
			std_dev_average IN OUT NOCOPY NUMBER,
			UCL OUT NOCOPY NUMBER,
			LCL OUT NOCOPY NUMBER,
			R_UCL OUT NOCOPY NUMBER,
			R_LCL OUT NOCOPY NUMBER,
			not_enough_data OUT NOCOPY NUMBER,
			compute_new_limits IN BOOLEAN default FALSE) IS

  results_cursor	INTEGER;
  result		NUMBER;
  ignore		INTEGER;
  i			INTEGER;
  temp_results 		numbertable;
  rows_retrieved	INTEGER;
  num_points 		INTEGER;
  first_point		INTEGER;
  have_to_round		BOOLEAN := FALSE;
    -- have_to_round is true if we have to perform a MOD operation
    -- to make sure the number of points we're using is a multiple of
    -- the subgroup size

  subgroup_number	INTEGER;
  average_table		numbertable;
  std_dev_table 	numbertable;
  total			NUMBER;
  sum_of_squares 	NUMBER;

  grand_mean_sum 	NUMBER := 0;
  std_dev_sum		NUMBER := 0;

  -- variables to hold constants for computing control limits
  A1	NUMBER;
  B3	NUMBER;
  B4	NUMBER;


  BEGIN
    results_cursor := dbms_sql.open_cursor;
    dbms_sql.parse (results_cursor, sql_string, dbms_sql.v7);
    dbms_sql.define_column (results_cursor, 1, result);

    ignore := dbms_sql.execute(results_cursor);

    i := 0;
    LOOP
      IF dbms_sql.fetch_rows (results_cursor) > 0 THEN
        i := i + 1;
        dbms_sql.column_value(results_cursor, 1, result);

        temp_results(i) := result;

      ELSE
        -- no more results to fetch
        exit;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(results_cursor);

    rows_retrieved := i;

    -- determine the first data point to use
    IF num_subgroups IS NOT NULL THEN
      num_points := subgrp_size * num_subgroups;
      first_point := rows_retrieved - num_points + 1;
      IF first_point < 1 THEN
        -- user specified more points than there are data points
        -- should give user a message here.
	have_to_round := TRUE;
      END IF;
    ELSE
      -- user didn't specify number of subgroups to use; use all data
      have_to_round := TRUE;
    END IF;

    IF have_to_round THEN
      -- this is only true when using all data points; mod using
      -- rows_retrieved
      num_subgroups := TRUNC (rows_retrieved / subgrp_size);
      IF num_subgroups < 1 THEN
	not_enough_data := 1;
	RETURN;
      END IF;

      first_point := MOD (rows_retrieved, subgrp_size) + 1;
    END IF;

    i := first_point;
    subgroup_number := 1;
    WHILE i <= rows_retrieved LOOP
      total := 0;
      sum_of_squares := 0;

      FOR j IN 1..subgrp_size LOOP
        total := total + temp_results(i);
	sum_of_squares := sum_of_squares + (temp_results(i) * temp_results(i));

        i := i + 1;

      END LOOP;  -- for loop

      -- the following computations are performed per subgroup
      average_table(subgroup_number) := round(total / subgrp_size, dec_prec);

      std_dev_table(subgroup_number) :=
	round(sqrt(((subgrp_size*sum_of_squares) - (total * total))/
		(subgrp_size * (subgrp_size - 1))), dec_prec);

      subgroup_number := subgroup_number + 1;

    END LOOP;  -- while loop

    IF (NOT compute_new_limits) THEN
      -- want to populate qa_chart_data with latest data
      FOR j IN 1..num_subgroups LOOP
        INSERT INTO QA_CHART_DATA
  	  (LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   SUBGROUP_NUMBER,
           AVERAGE,
           RANGE,
	   BAR_NUMBER,
	   HIST_RANGE,
	   NUM_OCCURRENCES)
        VALUES
	  (SYSDATE,
	   1,
	   SYSDATE,
	   1,
	   NULL,
	   j,
	   average_table(j),
	   std_dev_table(j),
	   null,
	   null,
	   null);
      END LOOP;

    ELSE
      -- compute new limits.

      FOR j IN 1..num_subgroups LOOP
        grand_mean_sum := grand_mean_sum + average_table(j);
        std_dev_sum := std_dev_sum + std_dev_table(j);
      END LOOP;

      grand_mean := grand_mean_sum / num_subgroups;
      std_dev_average := std_dev_sum / num_subgroups;

      -- compute the control limits
      SELECT A1, B3, B4 INTO A1, B3, B4
      FROM QA_CHART_CONSTANTS
      WHERE SUBGROUP_SIZE = subgrp_size;

      UCL := round(grand_mean + (A1 * std_dev_average), dec_prec);
      LCL := round(grand_mean - (A1 * std_dev_average), dec_prec);

      R_UCL := round(B4 * std_dev_average, dec_prec);
      R_LCL := round(B3 * std_dev_average, dec_prec);

      grand_mean := round(grand_mean, dec_prec);
      std_dev_average := round(std_dev_average, dec_prec);

    END IF;

  END X_BAR_S;

  PROCEDURE XmR (sql_string VARCHAR2,
		subgrp_size NUMBER,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		grand_mean IN OUT NOCOPY NUMBER,
		range_average IN OUT NOCOPY NUMBER,
		UCL OUT NOCOPY NUMBER,
		LCL OUT NOCOPY NUMBER,
		R_UCL OUT NOCOPY NUMBER,
		R_LCL OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER,
		compute_new_limits IN BOOLEAN default FALSE) IS

  results_cursor	INTEGER;
  result		NUMBER;
  ignore		INTEGER;
  i			INTEGER;
  j			INTEGER;
  temp_results 		numbertable;
  rows_retrieved	INTEGER;
  first_x_point		INTEGER;
  first_range_point     INTEGER;

  min_table	numbertable;
  max_table	numbertable;
  range_table   numbertable;

  grand_mean_sum	NUMBER := 0;
  range_sum		NUMBER := 0;

  -- variables to hold constants for computing control limits
  D3	NUMBER;
  D4	NUMBER;
  E2    NUMBER;


  BEGIN

    results_cursor := dbms_sql.open_cursor;
    dbms_sql.parse (results_cursor, sql_string, dbms_sql.v7);
    dbms_sql.define_column (results_cursor, 1, result);

    ignore := dbms_sql.execute(results_cursor);

    i := 0;
    LOOP
      IF dbms_sql.fetch_rows (results_cursor) > 0 THEN
        i := i + 1;
        dbms_sql.column_value(results_cursor, 1, result);

        temp_results(i) := result;

      ELSE
        -- no more results to fetch
        exit;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(results_cursor);

    rows_retrieved := i;

    -- determine the first data point to use
    IF num_points IS NOT NULL THEN
      first_x_point := rows_retrieved - num_points + 1;
      IF first_x_point < 1 THEN
        -- user specified more points than there are data points
        -- should give user a message here.
	first_x_point := 1;
      END IF;
    ELSE
      first_x_point := 1;
    END IF;

    first_range_point := first_x_point + subgrp_size - 1;

    IF first_range_point > rows_retrieved THEN
      -- not enough data to chart what the user wants to
      not_enough_data := 1;
      return;
    END IF;

    -- populate the first subgrp_size - 1 points with NULL for range.  We need
    -- to do this so that later we can sum the total properly (see below)
    FOR k IN first_x_point..first_range_point-1 LOOP
      range_table(k) := NULL;
    END LOOP;

    IF subgrp_size = 2 THEN
      FOR j IN first_range_point.. rows_retrieved LOOP
        range_table(j) := ABS(temp_results(j) - temp_results(j-1));
      END LOOP;

    ELSE
      -- subgrp_size > 2.  Have to keep around maxs, mins.
      i := first_x_point;
      j := first_range_point;
      -- the first subgroup will be the points between the first x point
      -- and the first range point.  We will increment each of these every
      -- time we go through the loop (we have a moving `window' of points
      -- we use for the moving range).

      -- we need to treat the first subgroup differently than the rest because
      -- there is no `discarded' point from a previous subgroup

      max_table(j) := temp_results(j);
      min_table(j) := temp_results(j);
      FOR k IN i..j LOOP
        IF temp_results(k) > max_table(j) THEN
          max_table(j) := temp_results(k);
        END IF;
        IF temp_results(k) < min_table(j) THEN
          min_table(j) := temp_results(k);
        END IF;
      END LOOP;

      range_table(j) := max_table(j) - min_table(j);

      i := i + 1;
      j := j + 1;

      WHILE j <= rows_retrieved LOOP
	min_table(j) := min_table(j - 1);
	max_table(j) := max_table(j - 1);

        IF temp_results(i - 1) = min_table(j - 1) THEN
          min_table(j) := temp_results(i);
          FOR k IN i+1..j LOOP
            IF temp_results(k) < min_table(j) THEN
              min_table(j) := temp_results(k);
            END IF;
          END LOOP;

        ELSIF temp_results(i - 1) = max_table(j - 1) THEN
          max_table(j) := temp_results(i);
          FOR k IN i+1..j LOOP
            IF temp_results(k) > max_table(j) THEN
              max_table(j) := temp_results(k);
            END IF;
          END LOOP;
        END IF;

        -- check out the new point.
        IF temp_results(j) < min_table(j) THEN
  	  min_table(j) := temp_results(j);
        END IF;

        IF temp_results(j) > max_table(j) THEN
  	  max_table(j) := temp_results(j);
        END IF;

        -- now we have the new maxs and mins.  can compute the range.
        range_table(j) := max_table(j) - min_table(j);

        i := i + 1;
        j := j + 1;

      END LOOP;  -- while loop

    END IF;

    IF (NOT compute_new_limits) THEN
      -- want to populate qa_chart_data with latest data
      FOR k IN first_x_point..rows_retrieved LOOP

        INSERT INTO QA_CHART_DATA
  	  (LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   SUBGROUP_NUMBER,
           AVERAGE,
           RANGE,
	   BAR_NUMBER,
	   HIST_RANGE,
	   NUM_OCCURRENCES)
        VALUES
	  (SYSDATE,
	   1,
	   SYSDATE,
	   1,
	   NULL,
	   k,
	   temp_results(k),
	   range_table(k),
	   null,
	   null,
	   null);
      END LOOP;

    ELSE
      -- we're computing new limits.

      FOR k IN first_x_point..rows_retrieved LOOP
        grand_mean_sum := grand_mean_sum + temp_results(k);
        range_sum := range_sum + NVL(range_table(k), 0);
      END LOOP;

      grand_mean := grand_mean_sum / (rows_retrieved - first_x_point + 1);
      range_average := range_sum / (rows_retrieved - first_range_point + 1);

      -- compute the control limits

      SELECT D3, D4, E2 INTO D3, D4, E2
      FROM QA_CHART_CONSTANTS
      WHERE SUBGROUP_SIZE = subgrp_size;

      UCL := round(grand_mean + (E2 * range_average), dec_prec);
      LCL := round(grand_mean - (E2 * range_average), dec_prec);

      R_UCL := round(D4 * range_average, dec_prec);
      R_LCL := round(D3 * range_average, dec_prec);

      grand_mean := round(grand_mean, dec_prec);
      range_average := round(range_average, dec_prec);

    END IF;

  END XmR;


  PROCEDURE mXmR (sql_string VARCHAR2,
		subgrp_size NUMBER,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		grand_mean IN OUT NOCOPY NUMBER,
		range_average IN OUT NOCOPY NUMBER,
		UCL OUT NOCOPY NUMBER,
		LCL OUT NOCOPY NUMBER,
		R_UCL OUT NOCOPY NUMBER,
		R_LCL OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER,
		compute_new_limits IN BOOLEAN default FALSE) IS

  results_cursor	INTEGER;
  result		NUMBER;
  ignore		INTEGER;
  i			INTEGER;
  j			INTEGER;
  temp_results 		numbertable;
  rows_retrieved	INTEGER;
  first_point		INTEGER;

  min_table	numbertable;
  max_table	numbertable;
  average_table numbertable;
  range_table   numbertable;

  temp_total		NUMBER := 0;
  grand_mean_sum 	NUMBER := 0;
  range_sum		NUMBER := 0;

  -- variables to hold constants for computing control limits
  A2	NUMBER;
  D3	NUMBER;
  D4	NUMBER;


  BEGIN

--delete from jc_temp;
--commit;

--insert into jc_temp values (sql_string);
--commit;
    results_cursor := dbms_sql.open_cursor;
    dbms_sql.parse (results_cursor, sql_string, dbms_sql.v7);
    dbms_sql.define_column (results_cursor, 1, result);

    ignore := dbms_sql.execute(results_cursor);

    i := 0;
    LOOP
      IF dbms_sql.fetch_rows (results_cursor) > 0 THEN
        i := i + 1;
        dbms_sql.column_value(results_cursor, 1, result);

        temp_results(i) := result;

--insert into jc_temp values ('temp_results(i): ' || to_char(temp_results(i)));
--commit;

      ELSE
        -- no more results to fetch
        exit;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(results_cursor);

    rows_retrieved := i;

--insert into jc_temp values ('rows_retrieved: ' || to_char (i));
--commit;

    -- determine the first data point to use
    IF num_points IS NOT NULL THEN
      first_point := rows_retrieved - num_points + 1;
      IF first_point < 1 THEN
        -- user specified more points than there are data points
        -- should give user a message here.
	first_point := 1;
      END IF;
    ELSE
      first_point := 1;
    END IF;

    -- figure out the first point to actually do computations on
    first_point := first_point + subgrp_size - 1;

    IF first_point > rows_retrieved THEN
      -- not enough data to chart what the user wants to
      not_enough_data := 1;
      RETURN;
    END IF;

    IF subgrp_size = 2 THEN
      FOR j IN first_point..rows_retrieved LOOP
        average_table(j) := ((temp_results(j) + temp_results(j-1)) / 2);
        range_table(j) := ABS(temp_results(j) - temp_results(j-1));
      END LOOP;

    ELSE
      -- subgrp_size > 2.  Have to keep around maxs, mins.
      i := first_point - subgrp_size + 1;
      j := first_point;

      -- we need to treat the first subgroup differently than the rest because
      -- there is no `discarded' point from a previous subgroup

      max_table(j) := temp_results(j);
      min_table(j) := temp_results(j);
      FOR k IN i..j LOOP
	temp_total := temp_total + temp_results(k);

        IF temp_results(k) > max_table(j) THEN
          max_table(j) := temp_results(k);
        END IF;
        IF temp_results(k) < min_table(j) THEN
          min_table(j) := temp_results(k);
        END IF;
      END LOOP;

      average_table(j) := round(temp_total/subgrp_size, dec_prec);
      range_table(j) := max_table(j) - min_table(j);

      i := i + 1;
      j := j + 1;

      WHILE j <= rows_retrieved LOOP
        -- update the sum
	temp_total := temp_total - temp_results(i - 1) + temp_results(j);

	-- now do the range stuff
	min_table(j) := min_table(j - 1);
	max_table(j) := max_table(j - 1);

        IF temp_results(i - 1) = min_table(j - 1) THEN
          min_table(j) := temp_results(i);
          FOR k IN i+1..j LOOP
            IF temp_results(k) < min_table(j) THEN
              min_table(j) := temp_results(k);
            END IF;
          END LOOP;

        ELSIF temp_results(i - 1) = max_table(j - 1) THEN
          max_table(j) := temp_results(i);
          FOR k IN i+1..j LOOP
            IF temp_results(k) > max_table(j) THEN
              max_table(j) := temp_results(k);
            END IF;
          END LOOP;
        END IF;

        -- check out the new point.
        IF temp_results(j) < min_table(j) THEN
  	  min_table(j) := temp_results(j);
        END IF;

        IF temp_results(j) > max_table(j) THEN
  	  max_table(j) := temp_results(j);
        END IF;

        -- now we have all the new data.  can compute average, range.
        average_table(j) := round(temp_total/subgrp_size, dec_prec);
        range_table(j) := max_table(j) - min_table(j);

        i := i + 1;
        j := j + 1;

      END LOOP;  -- while loop


/* FOR k IN first_point..rows_retrieved LOOP
insert into jc_temp values ('min_table(' || k || '): ' || to_char(min_table(k)));
insert into jc_temp values ('max_table(' || k || '): ' || to_char(max_table(k)));
insert into jc_temp values ('average_table(' || k || '): ' || to_char(average_table(k)));
insert into jc_temp values ('range_table(' || k || '): ' || to_char(range_table(k)));
commit;
END LOOP;
*/

    END IF;

    IF (NOT compute_new_limits) THEN
      -- want to populate qa_chart_data with latest data
      FOR k IN first_point..rows_retrieved LOOP

        INSERT INTO QA_CHART_DATA
  	  (LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_LOGIN,
	   SUBGROUP_NUMBER,
           AVERAGE,
           RANGE,
	   BAR_NUMBER,
	   HIST_RANGE,
	   NUM_OCCURRENCES)
        VALUES
	  (SYSDATE,
	   1,
	   SYSDATE,
	   1,
	   NULL,
	   k,
	   average_table(k),
	   range_table(k),
	   null,
	   null,
           null);
      END LOOP;

    ELSE

      -- compute new limits.

      FOR k IN first_point..rows_retrieved LOOP
        grand_mean_sum := grand_mean_sum + average_table(k);
        range_sum := range_sum + range_table(k);
      END LOOP;

      grand_mean :=
	round(grand_mean_sum / (rows_retrieved - first_point + 1), dec_prec);
      range_average :=
	round(range_sum / (rows_retrieved - first_point + 1), dec_prec);

      -- compute the control limits

      SELECT A2, D3, D4 INTO A2, D3, D4
      FROM QA_CHART_CONSTANTS
      WHERE SUBGROUP_SIZE = subgrp_size;

      UCL := round(grand_mean + (A2 * range_average), dec_prec);
      LCL := round(grand_mean - (A2 * range_average), dec_prec);

      R_UCL := round(D4 * range_average, dec_prec);
      R_LCL := round(D3 * range_average, dec_prec);

    END IF;

  END mXmR;


  -- Bug 5130547.  Boundary condition issue.  If num_points is 1,
  -- cp and cpk are undefined.  Their OUT values will remain the
  -- same as IN value, presumably NULL, in that case.
  -- bso Mon Apr 10 15:38:15 PDT 2006

  PROCEDURE HISTOGRAM (sql_string VARCHAR2,
		num_points IN OUT NOCOPY NUMBER,
		dec_prec NUMBER,
		num_bars IN OUT NOCOPY NUMBER,
		USL IN NUMBER,
		LSL IN NUMBER,
		cp IN OUT NOCOPY NUMBER,
		cpk IN OUT NOCOPY NUMBER,
		not_enough_data OUT NOCOPY NUMBER) IS

  results_cursor	INTEGER;
  result		NUMBER;
  ignore		INTEGER;
  i			INTEGER;
  j			INTEGER;
  temp_results 		numbertable;
  rows_retrieved	INTEGER;
  first_point		INTEGER;

  maximum	NUMBER;
  minimum	NUMBER;
  range		NUMBER;
  step_size     NUMBER;
  curr	        NUMBER;

  num_points_used INTEGER;
  total		 NUMBER;
  mean 		 NUMBER;
  sum_of_squares NUMBER;
  s		 NUMBER;

  boundary	numbertable; -- holds boundary values of bars
  occurrences   numbertable;

  BEGIN
    results_cursor := dbms_sql.open_cursor;
    dbms_sql.parse (results_cursor, sql_string, dbms_sql.v7);
    dbms_sql.define_column (results_cursor, 1, result);

    ignore := dbms_sql.execute(results_cursor);

    i := 0;
    LOOP
      IF dbms_sql.fetch_rows (results_cursor) > 0 THEN
        i := i + 1;
        dbms_sql.column_value(results_cursor, 1, result);

        temp_results(i) := result;
      ELSE
        -- no more results to fetch
        exit;
      END IF;
    END LOOP;
    dbms_sql.close_cursor(results_cursor);

    rows_retrieved := i;

    --
    -- Bug 5130638 The num_points variable was not correctly
    -- reset if it was bigger than the no. of rows retrieved.
    -- IF..THEN now rewritten to properly set its value.
    -- bso Mon Apr 10 16:08:21 PDT 2006
    --
    -- determine the first data point to use
    IF num_points IS NOT NULL AND num_points <= rows_retrieved THEN
      first_point := rows_retrieved - num_points + 1;
    ELSE
      first_point := 1;
      num_points := rows_retrieved;
    END IF;

    IF first_point > rows_retrieved THEN
      -- not enough data to chart what the user wants to
      not_enough_data := 1;
      RETURN;
    END IF;

    num_points_used := rows_retrieved - first_point + 1;

    maximum := temp_results(first_point);
    minimum := temp_results(first_point);
    FOR i IN first_point+1..rows_retrieved LOOP
      IF temp_results(i) > maximum THEN
        maximum := temp_results(i);
      END IF;
      IF temp_results(i) < minimum THEN
        minimum := temp_results(i);
      END IF;
    END LOOP;

    range := maximum - minimum;
    IF num_bars IS NULL THEN
      num_bars := round(sqrt(num_points));
    END IF;
    step_size := range/num_bars;

    curr := minimum;
    FOR i IN 1..num_bars-1 LOOP
      boundary(i) := round(curr + step_size, dec_prec);
      curr := curr + step_size;
      occurrences(i) := 0;
    END LOOP;

    -- to accommodate any rounding errors
    boundary(num_bars) := maximum;
    occurrences(num_bars) := 0;

    total := 0;
    sum_of_squares := 0;
    FOR i IN first_point..rows_retrieved LOOP
      -- keep running totals of sum of results and sum of squares, to be
      -- used later in computing cp, cpk
      total := total + temp_results(i);
      sum_of_squares := sum_of_squares + (temp_results(i) * temp_results(i));

      j := 1;
      WHILE boundary(j) <= temp_results(i) LOOP
        -- note that the intervals are inclusive on the lower end and
        -- exclusive on the upper end.  thus, the comparison is the way
        -- it is (for the while loop).

        -- if j = num_bars, we're looking at the maximum.  Don't increment
        -- j any more.
        IF j = num_bars THEN
	  EXIT;
        ELSE
          j := j + 1;
        END IF;
      END LOOP;
      occurrences(j) := occurrences(j) + 1;
    END LOOP;

    --
    -- Bug 5130547.  Boundary condition check.  If num_points_used = 1
    -- then standard deviation s is undefined.  Nor is cp and cpk.
    -- Let them remain null and skip computation.  Mean can be computed
    -- so extracted the mean calculation to outside the IF.  Side note:
    -- cp and cpk are discarded as dummies even though they are returned
    -- to the calling procedure.  I assume this is for future use.  The
    -- cp and cpk displayed in Descriptive Stats page is calculated by
    -- QLTSCMDF.fmb CONTROL_PRIVATE.run_stats program.
    -- bso Mon Apr 10 15:10:31 PDT 2006
    --

    mean := round(total/num_points_used, dec_prec);
    IF num_points_used > 1 THEN
        -- compute cp, cpk.  First compute s, the estimator of sigma.
        s := sqrt(((num_points_used * sum_of_squares) - (total * total))/
            ((num_points_used) * (num_points_used - 1)));

        IF (USL IS NULL AND LSL IS NULL) THEN
          -- cp, cpk don't make sense
          null;
        ELSIF (USL IS NULL) THEN
          -- one-sided spec limit.  cp doesn't make sense in this case, so only
          -- compute cpk.
          cpk := round((mean - LSL)/(3 * s), 2);
        ELSIF (LSL IS NULL) THEN
          cpk := round((USL - mean)/(3 * s), 2);
        ELSE
          -- neither USL nor LSL is null
          cp := round((USL - LSL) / (6 * s), 2);
          IF ((USL - mean) <= (mean - LSL)) THEN
            cpk := round((USL - mean)/(3 * s), 2);
          ELSE
            cpk := round((mean - LSL)/(3 * s), 2);
          END IF;
      END IF;
    END IF;

    -- insert the first point.  has to be treated a bit differently because
    -- of the lower boundary
    INSERT INTO QA_CHART_DATA
      (LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_LOGIN,
	SUBGROUP_NUMBER,
	AVERAGE,
        RANGE,
	BAR_NUMBER,
        HIST_RANGE,
        NUM_OCCURRENCES)
    VALUES
       (SYSDATE,
	1,
	SYSDATE,
	1,
	NULL,
	null,
        null,
        null,
	1,
	to_char(minimum) || ' - ' || to_char(boundary(1)),
	occurrences(1));

    FOR i IN 2..num_bars LOOP
      INSERT INTO QA_CHART_DATA
        (LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 SUBGROUP_NUMBER,
	 AVERAGE,
	 RANGE,
	 BAR_NUMBER,
	 HIST_RANGE,
	 NUM_OCCURRENCES)
      VALUES
	(SYSDATE,
	 1,
	 SYSDATE,
	 1,
	 NULL,
	 null,
	 null,
	 null,
	 i,
	 to_char(boundary(i-1)) || ' - ' || to_char(boundary(i)),
	 occurrences(i));
    END LOOP;

  END HISTOGRAM;

  FUNCTION validate_query(p_query_str IN VARCHAR2,x_error_num OUT NOCOPY NUMBER)
     RETURN VARCHAR2 IS

   -- Bug 2459633. This function executes the sql and handles the exception.
   -- return true only if the query fetches record.
   -- rponnusa Mon Jul 15 04:31:49 PDT 2002

   TYPE cur_typ IS REF CURSOR;
      c cur_typ;

   dummy VARCHAR2(1000):= NULL;
   l_status VARCHAR2(1);
   BEGIN

    BEGIN
      -- Bug 3464464 ksoh Tue Mar  2 13:54:21 PST 2004
      -- sometimes the query returns 1 column, sometimes 2
      -- need kludge SQL to make sure there is only 1 column to be returned
      -- 10g throws exception when the cursor return type mismatch
      OPEN c FOR 'select 1 from (' || p_query_str || ')';
      FETCH c INTO dummy;

      IF c%ROWCOUNT = 0 THEN
         x_error_num := 1403;
         l_status := 'F';
      ELSE
         l_status := 'T';
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
           x_error_num := SQLCODE;
           l_status := 'F';
    END;
    CLOSE c;

    RETURN l_status;

 END validate_query;


END QLTCONTB;


/
