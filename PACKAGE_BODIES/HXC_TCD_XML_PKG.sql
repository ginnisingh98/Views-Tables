--------------------------------------------------------
--  DDL for Package Body HXC_TCD_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TCD_XML_PKG" AS
/* $Header: hxctcdrpt.pkb 120.8.12010000.12 2009/02/02 13:15:59 asrajago ship $ */


TYPE r_person_id IS RECORD (person_id NUMBER(15));
TYPE t_person_ids IS TABLE OF r_person_id INDEX BY BINARY_INTEGER;

g_tc_start_date DATE;

function afterpform return boolean is
begin

  	l_resource_id		:= p_resource_id;

  	l_rec_period_id		:= p_rec_period_id;
  	l_tc_period		:= p_tc_period;
  	l_period_start_date	:= p_period_start_date;
  	l_period_end_date	:= p_period_end_date;
  	l_supervisor_id		:= p_supervisor_id;
  	l_reptng_emp		:= p_reptng_emp;
  	l_org_id		:= p_org_id;
  	l_location_id		:= p_location_id;

  	l_sel_supervisor_id 	:= p_sel_supervisor_id;
  	l_sel_tc_status		:= p_sel_tc_status;

	l_rpt_status		:= 'IN PROGRESS';

	g_tc_start_date		:= l_period_start_date;

	SELECT name INTO l_rec_period
	  FROM hxc_recurring_periods
	 WHERE recurring_period_id = l_rec_period_id;

	SELECT full_name INTO l_supervisor_name
	  FROM per_all_people_f
	 WHERE person_id = l_supervisor_id
                              AND sysdate between effective_start_date and effective_end_date;

	l_location_name	:= null;
	l_org_name	:= null;

	IF p_org_id IS NOT null
	THEN
		SELECT name INTO l_org_name
		  FROM hr_all_organization_units
		 WHERE organization_id = l_org_id;
	END IF;

	IF p_location_id IS NOT null
	THEN
		SELECT location_code INTO l_location_name
		  FROM hr_locations_all
		 WHERE location_id = l_location_id;
	END IF;

	return (TRUE);
end;

function BeforeReport return boolean is
begin
  clear_report_table;
  populate_report_table;
		--hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
	--hr_standard.event('AFTER REPORT');
  clear_report_table;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--


PROCEDURE filter_person_ids(p_person_ids IN t_person_ids,
			    p_filtered_person_ids OUT NOCOPY t_person_ids)
IS

	l_index 	NUMBER;
	l_person_index	NUMBER;
	l_rec_period	NUMBER;
	l_pref_eval_date DATE;
	l_EvalDateSql	VARCHAR2(800);
BEGIN

	l_index := p_person_ids.FIRST;
	l_person_index := 1;

	 -- Bug 8205132
	 -- Added a group by person_id in the below dynamic sql text.
	 -- Since the person_ids table coming in might have some
	 -- unwanted person ids, the query might be run for persons
	 -- who are not active on the given period.
	 -- The below query would trim all that off fine, but since
	 -- the selected column is an MIN value without a GROUP BY
	 -- it would always return a value -- a NULL date.
	 -- This would create problems in the following Preference
	 -- Evaluation call.
	 -- Added the GROUP BY clause so no row is returned when
	 -- the WHERE clause fails.

	 l_EvalDateSql := 'SELECT GREATEST(:1,tmp.start_date)
	          	   FROM
			  (SELECT min(effective_start_date) start_date
			    FROM per_all_assignments_f
			   WHERE person_id = :2
			     AND assignment_type IN (''E'', ''C'')
			     AND primary_flag = ''Y''
			     AND ((trunc(effective_start_date) <= trunc(:3)
					AND trunc(effective_end_date) >= trunc(:4))
				OR (effective_start_date = (SELECT min(effective_start_date)
				  FROM per_all_assignments_f
				 WHERE person_id = :5
				   AND assignment_type IN (''E'', ''C'')
				   AND primary_flag = ''Y''
				   AND trunc(effective_start_date) > trunc(:6)
				   AND trunc(effective_start_date) <= trunc(:7)))) GROUP BY person_id ) tmp';
	LOOP
	EXIT WHEN NOT p_person_ids.exists(l_index);

           -- Bug 8205132
           -- The BEGIN-END block to handle the 1403 error due to the
           -- above changed behavior.
           -- If the query returns nothing, the l_rec_period value is set
           -- to -1 in the Exception block, and the person_id would not pass
           -- the filter.

           BEGIN

	     EXECUTE IMMEDIATE l_EvalDateSql INTO l_pref_eval_date USING
	     	l_period_start_date, p_person_ids(l_index).person_id, l_period_start_date,l_period_start_date,
	     	p_person_ids(l_index).person_id, l_period_start_date,l_period_end_date;

		l_rec_period := hxc_preference_evaluation.resource_preferences
						(p_person_ids(l_index).person_id,
                                                  'TC_W_TCRD_PERIOD',
                                                   1,
                                                   l_pref_eval_date, -99);

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  l_rec_period := -1;
           END;

		IF (l_rec_period = l_rec_period_id)
		THEN
			p_filtered_person_ids(l_person_index).person_id := p_person_ids(l_index).person_id;
			l_person_index := l_person_index + 1;
		END IF;

		l_index := p_person_ids.next(l_index);
	END LOOP;

END filter_person_ids;

FUNCTION get_timecard_start_date(p_person_id IN NUMBER, p_timecard_id IN NUMBER,
			p_period_start_date IN DATE DEFAULT null, p_period_end_date IN DATE default null)
RETURN DATE
IS
	l_index NUMBER;
	l_tc_start_date DATE;
	l_tc_start_time DATE;
	l_sql varchar2(800);
	l_dummy VARCHAR2(2);

	-- Bug 7658500
	-- Added a new not exists condition for the below cursor.
	-- The cursor originally added to look for a midperiod
	-- termination so that the timecard would be picked up
	-- even if the stop_time is less that the period end date.
	-- This introduced a problem in reverse termination.
	-- Eg. Emp has to submit timecard for 1-jan-07 to 7-jan-07


	-- If he is terminated on 4-Jan-07, Time store lets him enter
	-- timecard only for 1-jan to 4-jan.  Without the below cursor
	-- the timecard for 1-jan-07 to 7-jan-07 would look appear as
	-- NOT ENTERED because the stop times dont match.
	--
	-- This adds a problem for reverse termination.  If the termination
	-- is reversed as of 5-jan-07, the employee can submit a second timecard
	-- for the period, 5-jan-07 to 7-jan-07.
	-- Before this bug fix, the Dashboard and report would pull up
	-- an extra record for NOT ENTERED status because there is no timecard
	-- entered for the period end date -- at least that was not being
	-- checked here.  So the below cursor is altered to process this
	-- termination scenario only if there was no reverse termination
	-- happening.  The smaller timecard EXISTS condition is appended
	-- with a condition which checks if there is one timecard for
	-- the rest of the period -- dont pick up a record if there is one
	-- such timecard.

	-- Bug 8205132
	-- Added input values for the cursor below to pick up the
	-- exact values.


	CURSOR c_chk_tc_exists ( p_person_id         IN NUMBER,
                                 p_period_start_date IN DATE,
                                 p_period_end_date   IN DATE)
	    IS
		SELECT 'Y' FROM dual
		  WHERE (
                     EXISTS (
		      SELECT 'Y'
		        FROM hxc_timecard_summary
		       WHERE resource_id = p_person_id
		         AND TRUNC(start_time) >= p_period_start_date
		         AND TRUNC(stop_time) < p_period_end_date)
                   AND NOT  EXISTS (
		      SELECT 'Y'
		        FROM hxc_timecard_summary
		       WHERE resource_id = p_person_id
		         AND TRUNC(start_time) > p_period_start_date
		         AND TRUNC(stop_time) <= p_period_end_date)
                         )
		    AND EXISTS
			  (SELECT 'Y'
			   FROM per_all_assignments_f
			   WHERE person_id = p_person_id
			   AND assignment_type IN('E','C')
			   AND primary_flag = 'Y'
			   AND trunc(effective_start_date) <= trunc(p_period_start_date)
		           AND trunc(effective_end_date) >= trunc(p_period_end_date));
BEGIN

	hr_utility.trace(' ANUTHI Getting timecard start date for person id ' || p_person_id);

	IF p_period_start_date IS NOT NULL THEN
		l_period_start_date := p_period_start_date;
		g_tc_start_date := p_period_start_date;
	END IF;

	IF p_period_end_date IS NOT NULL THEN
		l_period_end_date := p_period_end_date;
	END IF;

	-- Get the max of effective start date, this will pick up the timecards for mid period rehires which are NOT ENTERED
        l_sql := 'SELECT max(effective_start_date)
		    FROM per_all_assignments_f
		   WHERE person_id = :1
		     AND assignment_type IN (''E'', ''C'')
		     AND primary_flag = ''Y''
		     AND ((effective_start_date <= :2
		     	   AND effective_end_date >= :3)
			OR (effective_start_date > :4
			     AND effective_start_date <= :5)
			OR (effective_start_date <= :6
 			     AND effective_end_date <= :7))';

	EXECUTE IMMEDIATE l_sql INTO l_tc_start_date USING
		p_person_id, l_period_start_date, l_period_end_date,
		l_period_start_date, l_period_end_date, l_period_start_date, l_period_end_date;

     	hr_utility.trace(' ANUTHI l_tc_start_date 1 ' || l_tc_start_date);

     	IF l_tc_start_date < l_period_start_date
     	THEN
     		l_tc_start_date := l_period_start_date;
	END IF;

	-- If a timecard exists, start date will be set to timecard start date
	IF p_timecard_id IS NOT NULL
	THEN
		SELECT start_time INTO l_tc_start_time FROM hxc_timecard_summary WHERE timecard_id = p_timecard_id;

		l_tc_start_date := l_tc_start_time;

	END IF;

	--In case of mid period reverse termination, check if a timecard already exists in the selected timecard period
	--but with the end date as the termination date
	--If yes, then there will be a not entered timecard for the rest of the timecard period

	-- Bug 8205132
	-- Added input parameters for the cursor.

	OPEN c_chk_tc_exists( p_person_id  => p_person_id,
                              p_period_start_date => l_period_start_date,
                              p_period_end_date  => l_period_end_date );

	FETCH c_chk_tc_exists INTO l_dummy;

	IF c_chk_tc_exists%NOTFOUND THEN
		CLOSE c_chk_tc_exists;
	ELSE
		CLOSE c_chk_tc_exists;
		IF p_timecard_id IS NULL THEN
		l_sql := null;
		-- Bug 8205132
		-- Added a TRUNC below to avoid the timestamp.
		l_sql := 'SELECT TRUNC(stop_time) + 1
			    FROM hxc_timecard_summary
			   WHERE resource_id = :1
			     AND TRUNC(start_time) >= :2
			     AND TRUNC(stop_time) < :3';

		EXECUTE IMMEDIATE l_sql INTO l_tc_start_time USING
			p_person_id, l_period_start_date, l_period_end_date;


		IF l_tc_start_time is NOT NULL AND l_tc_start_date < l_tc_start_time THEN
			l_tc_start_date := l_tc_start_time;
		END IF;
	   	END IF;
	 END IF;
	g_tc_start_date := l_tc_start_date;

     	hr_utility.trace(' ANUTHI g_tc_start_date ' || g_tc_start_date);

     	return l_tc_start_date;

END get_timecard_start_date;

FUNCTION get_timecard_end_date(p_person_id IN NUMBER, p_timecard_id IN NUMBER, p_period_end_date IN DATE default null)
RETURN DATE
IS
	l_pref_end_date DATE;
	l_pref_table  hxc_preference_evaluation.t_pref_table;
	l_start_date DATE;
	l_end_date DATE;
	l_index NUMBER;
	l_tc_end_date DATE;
	l_tc_stop_date DATE;
	l_sql VARCHAR2(500);
	l_rec_period varchar2(100);
	l_prev_rec_period varchar2(100);

BEGIN

	l_pref_table.DELETE;

	hr_utility.trace(' Getting timecard end date for person id ' || p_person_id);

	IF p_period_end_date IS NOT NULL THEN
		l_period_end_date := p_period_end_date;
	END IF;

	  hxc_preference_evaluation.resource_preferences(
	                  p_resource_id   => p_person_id
	                  ,p_preference_code => 'TC_W_TCRD_PERIOD'
	                  ,p_start_evaluation_date => g_tc_start_date
	                  ,p_end_evaluation_date => l_period_end_date
                  	  ,p_sorted_pref_table  => l_pref_table );

	hr_utility.trace(' l_pref_table.count   ' || l_pref_table.count);

	l_index := l_pref_table.FIRST;
	l_prev_rec_period := '';
	l_pref_end_date := l_pref_table(l_index).end_date;
	WHILE ( l_index IS NOT NULL )
	LOOP
		l_start_date := l_pref_table(l_index).start_date;
		l_end_date := l_pref_table(l_index).end_date;

		hr_utility.trace(' l_pref_table.start_date  ' || l_pref_table(l_index).start_date);
 	                          hr_utility.trace(' l_pref_table.end_date  ' || l_pref_table(l_index).end_date);

		l_rec_period := l_pref_table(l_index).attribute1;

		hr_utility.trace(' l_rec_period ' || l_rec_period);
 	                          hr_utility.trace(' l_prev_rec_period  ' || l_prev_rec_period);

		IF(l_rec_period = l_prev_rec_period) THEN
			l_pref_end_date := l_end_date;
		END IF;
 	                          l_prev_rec_period := l_rec_period;
		 l_index := l_pref_table.NEXT(l_index);
	END LOOP;
	SELECT max(effective_end_date) INTO l_tc_end_date
	  FROM per_all_assignments_f
	WHERE person_id = p_person_id
	and effective_end_date >= g_tc_start_date
	and primary_flag = 'Y'
	and assignment_type in ('E','C');

	SELECT LEAST(l_pref_end_date,l_tc_end_date,l_period_end_date) INTO l_tc_end_date FROM dual;

	IF p_timecard_id IS NOT NULL
	THEN
		SELECT stop_time INTO l_tc_stop_date FROM hxc_timecard_summary WHERE timecard_id = p_timecard_id;

		IF l_tc_end_date > l_tc_stop_date
		THEN
			l_tc_end_date := l_tc_stop_date;
		END IF;

	END IF;

	hr_utility.trace(' l_tc_end_date final ' || l_tc_end_date);

        return l_tc_end_date;
END get_timecard_end_date;

PROCEDURE populate_temp_table(p_person_ids IN t_person_ids)
IS

l_sql		VARCHAR2(32000);

TYPE r_tcd_rpt IS RECORD (
  PERSON_ID		NUMBER(15),
  PERSON_NAME		VARCHAR2(100),
  PERSON_NUMBER		NUMBER(15),
  APPROVAL_STATUS	VARCHAR2(20),
  SUPERVISOR		VARCHAR2(100),
  ORGANIZATION		VARCHAR2(100),
  LOCATION		VARCHAR2(100),
  PAYROLL		VARCHAR2(100),
  TC_START_DATE		DATE,
  TC_END_DATE		DATE,
  LAST_MODIFIED_BY	VARCHAR2(100),
  LAST_MODIFIED_DATE    DATE,
  PERSON_TYPE		VARCHAR2(30),
  APPLICATION		VARCHAR2(100)
 );

TYPE t_tcd_rpt IS TABLE OF r_tcd_rpt INDEX BY BINARY_INTEGER;

l_tcd_rpt t_tcd_rpt;

BEGIN

	hr_utility.trace(' In populate_temp_table ');

	l_sql := 'SELECT temp.*, ppt.user_person_type PERSON_TYPE, hasv.application_set_name APPLICATION
		  FROM
			(SELECT distinct person_id,
			 	person_name,
				person_number,
				(NVL(tim.approval_status,''NOTENTERED'')) AS approval_status,
				supervisor_name,
				organization,
				location,
				payroll,
				hxc_tcd_xml_pkg.get_timecard_start_date(person_id,tim.timecard_id) AS start_date,
			        hxc_tcd_xml_pkg.get_timecard_end_date(person_id,tim.timecard_id) AS end_date,
				 (SELECT user_name FROM fnd_user
				   WHERE user_id = (SELECT last_updated_by FROM hxc_time_building_blocks
						    WHERE scope = ''TIMECARD''
						      AND resource_id = person_id
						      AND time_building_block_id = tim.timecard_id
						      AND date_to = hr_general.end_of_time)
				 ) AS last_updated_by,
				 (SELECT last_update_date FROM hxc_time_building_blocks
				  WHERE scope = ''TIMECARD''
				    AND resource_id = person_id
   			            AND time_building_block_id = tim.timecard_id
				    AND date_to = hr_general.end_of_time
				) AS last_update_date
			   FROM HXC_TCD_DETAILS_V v,
			   ((SELECT resource_id, timecard_id, approval_status FROM hxc_timecard_summary
			   WHERE resource_id IN (
			   ';
	FOR i IN 1..p_person_ids.count
		LOOP
		     if i > 1
		     then
		     	l_sql := l_sql || ',';
		     end if;
		    l_sql :=  l_sql || p_person_ids(i).person_id;


	END LOOP;

	l_sql := l_sql || ') AND trunc(start_time) >= :1  AND trunc(stop_time) <= :2)
			UNION
			(SELECT person_id AS
			     resource_id,
			       NULL timecard_id,
			       NULL approval_status
			     FROM per_all_assignments_f paaf
			     WHERE person_id IN(';

		FOR i IN 1..p_person_ids.count
		LOOP
		     if i > 1
		     then
		     	l_sql := l_sql || ',';
		     end if;
		    l_sql :=  l_sql || p_person_ids(i).person_id;


	END LOOP;

	-- Bug 7658500
	-- Added a new not exists condition for the dynamic sql.
	-- The sql text originally added to look for a midperiod
	-- termination so that the timecard would be picked up
	-- even if the stop_time is less that the period end date.
	-- This introduced a problem in reverse termination.
	-- Eg. Emp has to submit timecard for 1-jan-07 to 7-jan-07


	-- If he is terminated on 4-Jan-07, Time store lets him enter
	-- timecard only for 1-jan to 4-jan.  Without the below cursor
	-- the timecard for 1-jan-07 to 7-jan-07 would look appear as
	-- NOT ENTERED because the stop times dont match.
	--
	-- This adds a problem for reverse termination.  If the termination
	-- is reversed as of 5-jan-07, the employee can submit a second timecard
	-- for the period, 5-jan-07 to 7-jan-07.
	-- Before this bug fix, the Dashboard and report would pull up
	-- an extra record for NOT ENTERED status because there is no timecard
	-- entered for the period end date -- at least that was not being
	-- checked here.  So the below cursor is altered to process this
	-- termination scenario only if there was no reverse termination
	-- happening.  The smaller timecard EXISTS condition is appended
	-- with a condition which checks if there is one timecard for
	-- the rest of the period -- dont pick up a record if there is one
	-- such timecard.


	l_sql := l_sql || '  )
			     AND( EXISTS
			      (SELECT ''Y''
			       FROM hxc_timecard_summary
			       WHERE resource_id = paaf.person_id
			       AND TRUNC(start_time) >= :3
			       AND TRUNC(stop_time) < :4)
                               AND  NOT EXISTS
			      (SELECT ''Y''
			       FROM hxc_timecard_summary
			       WHERE resource_id = paaf.person_id
			       AND TRUNC(start_time) > :31
			       AND TRUNC(stop_time) <= :41) )
			    AND EXISTS
			      (SELECT ''Y''
			       FROM per_all_assignments_f
			       WHERE person_id = paaf.person_id
			       AND assignment_type IN(''E'',    ''C'')
			       AND primary_flag = ''Y''
			       AND((TRUNC(effective_start_date) <= :5
			       AND TRUNC(effective_end_date) >= :6) OR(TRUNC(effective_start_date) > :7
       				AND TRUNC(effective_start_date) <= :8)))))
			tim ';

	l_sql := l_sql || ' WHERE v.person_id = tim.resource_id(+) AND v.person_id IN (' ;


	FOR i IN 1..p_person_ids.count
	LOOP
	     if i > 1
	     then
	     	l_sql := l_sql || ',';
	     end if;
	    l_sql :=  l_sql || p_person_ids(i).person_id;


	END LOOP;

	l_sql := l_sql || ')';

        -- Bug 7829336
        -- Added conditions to check for Mid period hire and
        -- mid period hire and terminate scenario.


        -- Bug 8205132
        -- Removed the above conditions and put up the correct conditions.
        -- Neednt have all the bind variables too, so removed them.


	l_sql := l_sql || 'AND trunc(effective_start_date) <= :9
                           AND trunc(effective_end_date) >= :10';


	IF l_sel_tc_status <> 'ALL' THEN

	  l_sql := l_sql || 'AND '''|| l_sel_tc_status ||''' = NVL(tim.approval_status,''NOTENTERED'')';
	END IF;

	IF l_org_id IS NULL OR l_org_id = ''
	THEN
		l_org_id := -1;
	ELSE
		l_sql := l_sql || ' AND organization_id = :11';
	END IF;

	IF l_location_id IS NULL OR l_location_id = '' THEN
		l_location_id := -1;
	ELSIF l_org_id <> -1 THEN
		l_sql := l_sql || ' AND location_id = :12';
	ELSE
		l_sql := l_sql || ' AND location_id = :11';
	END IF;

	l_sql := l_sql || ') temp, per_person_types ppt, per_person_type_usages_f ptu,hxc_application_sets_v hasv
			WHERE hasv.application_set_id =
				hxc_preference_evaluation.resource_preferences(temp.person_id,''TS_PER_APPLICATION_SET'',1,temp.start_date,-99)
		          AND ppt.person_type_id = ptu.person_type_id
		   	  AND ptu.person_id = temp.person_id
		   	  AND trunc(ptu.effective_start_date) <= trunc(temp.start_date)
		   	  AND trunc(effective_end_date) >= trunc(temp.start_date)';


	-- Bug 7658500
	-- Added a set of start and stop dates because
	-- the above sql is added with two new bind variables.

                -- Bug 7829336
                -- Added bind variables to include the changed queries.


        -- Bug 8205132
        -- Less complex query, less bind variables.
        -- Commented out the unwanted bind variables in
        -- all the below executions.

		IF l_org_id = -1 AND l_location_id = -1 THEN
			EXECUTE IMMEDIATE l_sql BULK COLLECT INTO l_tcd_rpt using
				l_period_start_date, l_period_end_date,   -- :1,:2
				l_period_start_date, l_period_end_date,   -- :3,:4
				l_period_start_date, l_period_end_date,   -- :31,:41
				l_period_start_date, l_period_end_date,   -- :5,:6
				l_period_start_date, l_period_end_date,   -- :7,:8
                                l_period_end_date,   l_period_start_date; -- :9,:10
/*				l_period_start_date, l_period_start_date, -- :9,:10
                                l_period_start_date, l_period_end_date,   -- :101,:102
                                l_period_start_date, l_period_start_date, -- :103,:104
                                l_period_end_date ;                       -- :105
*/
		ELSIF l_org_id <> -1 AND l_location_id = -1 THEN
			EXECUTE IMMEDIATE l_sql BULK COLLECT INTO l_tcd_rpt using
				l_period_start_date, l_period_end_date,   -- :1,:2
				l_period_start_date, l_period_end_date,	  -- :3,:4
				l_period_start_date, l_period_end_date,	  -- :31,:41
				l_period_start_date, l_period_end_date,	  -- :5,:6
				l_period_start_date, l_period_end_date,	  -- :7,:8
                                l_period_end_date,   l_period_start_date, -- :9,:10
/*				l_period_start_date, l_period_start_date, -- :9,:10
                                l_period_start_date, l_period_end_date,   -- :101,:102
                                l_period_start_date, l_period_start_date, -- :103,:104
                                l_period_end_date ;                       -- :105
*/
                                l_org_id;
		ELSIF l_org_id = -1 AND l_location_id <> -1 THEN
			EXECUTE IMMEDIATE l_sql BULK COLLECT INTO l_tcd_rpt using
				l_period_start_date, l_period_end_date,	    -- :1,:2
				l_period_start_date, l_period_end_date,	    -- :3,:4
				l_period_start_date, l_period_end_date,	    -- :31,:41
				l_period_start_date, l_period_end_date,	    -- :5,:6
				l_period_start_date, l_period_end_date,	    -- :7,:8
                                l_period_end_date,   l_period_start_date, -- :9,:10
/*				l_period_start_date, l_period_start_date, -- :9,:10
                                l_period_start_date, l_period_end_date,   -- :101,:102
                                l_period_start_date, l_period_start_date, -- :103,:104
                                l_period_end_date ;                       -- :105
*/
                                l_location_id;
		ELSE
			EXECUTE IMMEDIATE l_sql BULK COLLECT INTO l_tcd_rpt using
				l_period_start_date, l_period_end_date,	    -- :1,:2
				l_period_start_date, l_period_end_date,	    -- :3,:4
				l_period_start_date, l_period_end_date,	    -- :31,:41
				l_period_start_date, l_period_end_date,	    -- :5,:6
				l_period_start_date, l_period_end_date,	    -- :7,:8
                                l_period_end_date,   l_period_start_date, -- :9,:10
/*				l_period_start_date, l_period_start_date, -- :9,:10
                                l_period_start_date, l_period_end_date,   -- :101,:102
                                l_period_start_date, l_period_start_date, -- :103,:104
                                l_period_end_date ;                       -- :105
*/
                                l_org_id,l_location_id;
		END IF;


	IF l_sel_supervisor_id IS NULL OR l_sel_supervisor_id = '' THEN
		l_sel_supervisor_id := -1;
	END IF;

	FOR i IN l_tcd_rpt.FIRST..l_tcd_rpt.LAST
	LOOP

		INSERT INTO HXC_TCD_TMP_RPT(
		  RESOURCE_ID ,
		  REC_PERIOD_ID	,
		  PERIOD_START_DATE,
		  PERIOD_END_DATE  ,
		  SUPERVISOR_ID	,
		  LOCATION_ID	,
		  ORGANIZATION_ID,
		  SEL_SUPERVISOR_ID,
		  SEL_TC_STATUS	,
		  RPT_STATUS	,
		  PERSON_TYPE	,
		  PERSON_NAME	,
		  PERSON_NUMBER	,
		  APPROVAL_STATUS,
		  SUPERVISOR	,
		  ORGANIZATION	,
		  LOCATION	,
		  PAYROLL	,
		  APPLICATION	,
		  TC_START_DATE	,
		  TC_END_DATE	,
		  LAST_MODIFIED_BY,
		  LAST_MODIFIED_DATE
		)
		VALUES(l_resource_id,
			  l_rec_period_id,
			  l_period_start_date,
			  l_period_end_date,
			  l_supervisor_id,
			  l_location_id,
			  l_org_id,
			  l_sel_supervisor_id,
			  l_sel_tc_status,
			  l_rpt_status,
			  l_tcd_rpt(i).PERSON_TYPE,
			  l_tcd_rpt(i).PERSON_NAME,
			  l_tcd_rpt(i).PERSON_NUMBER,
			  l_tcd_rpt(i).APPROVAL_STATUS,
			  l_tcd_rpt(i).SUPERVISOR,
			  l_tcd_rpt(i).ORGANIZATION,
			  l_tcd_rpt(i).LOCATION,
			  l_tcd_rpt(i).PAYROLL,
			  l_tcd_rpt(i).APPLICATION,
			  l_tcd_rpt(i).TC_START_DATE,
			  l_tcd_rpt(i).TC_END_DATE,
			  l_tcd_rpt(i).LAST_MODIFIED_BY,
			  l_tcd_rpt(i).LAST_MODIFIED_DATE);
	END LOOP;
	commit;

END populate_temp_table;

PROCEDURE populate_report_table
IS

l_supervisor	varchar2(20);

l_person_ids	t_person_ids;
l_filtered_person_ids	t_person_ids;

l_directsSQL varchar2(2000);
l_allEmpSQL varchar2(2000);

BEGIN

	IF (l_sel_supervisor_id is not null)
	THEN
	-- Selected a link from dashboard summary
		l_supervisor := l_sel_supervisor_id;
	ELSE
	-- Selected a link from dashboard summary totals
		l_supervisor := l_supervisor_id;
	END IF;

	IF (l_reptng_emp = 'DIRECT_REPORTEES' OR
		l_sel_supervisor_id = l_supervisor_id)
	THEN



                -- Bug 8205132
                -- Commented out the below sql and rewrote with a more
                -- correct WHERE clause to trim out unwanted records.

/*
                -- Bug 7829336
                -- Added condition to check for Mid period hire
                -- and mid period hire and termination.
                -- Prior to this bug, the date check did not cover these aspects.



		l_directsSQL := 'SELECT DISTINCT person_id
			   	FROM per_all_assignments_f paaf
			  	WHERE assignment_type IN (''E'', ''C'')
			    	AND primary_flag = ''Y''
			    	AND supervisor_id = :1
			        AND (
                                      (     trunc(effective_start_date) <= :2
			               AND trunc(effective_end_date) >= :3
                                       )
                                     OR
                                      (     trunc(effective_start_date) > :4
			               AND trunc(effective_end_date) >= :5
                                       AND trunc(effective_end_date) > :6
                                       )
                                     OR
                                      (     trunc(effective_start_date) > :7
			               AND trunc(effective_end_date) < :8
                                       )
                                     )  ';

*/

		l_directsSQL := 'SELECT DISTINCT person_id
			   	FROM per_all_assignments_f paaf
			  	WHERE assignment_type IN (''E'', ''C'')
			    	AND primary_flag = ''Y''
			    	AND supervisor_id = :1
			        AND trunc(effective_start_date) <= :2
                                AND trunc(effective_end_date) >= :3 ';

		IF l_location_id IS NOT null
		THEN
			l_directsSQL := l_directsSQL || ' AND location_id = ' || l_location_id;
		END IF;

		IF l_org_id IS NOT null
		THEN
			l_directsSQL := l_directsSQL || ' AND organization_id = ' || l_org_id;
		END IF;

	        l_directsSQL := l_directsSQL || ' ORDER BY 1 ';

	        hr_utility.trace(' l_directsSQL ' || l_directsSQL);


                -- Bug 8205132
                -- New query, and less bind variables.
                -- Rewrote the Execute Immediate below.
                /*
                -- Bug 7829336
                -- Added bind variables to include the changed queries.

	        EXECUTE IMMEDIATE l_directsSQL BULK COLLECT INTO l_person_ids USING
	        	l_supervisor,l_period_start_date,l_period_start_date,  -- :1,:2,:3
                        l_period_start_date,l_period_end_date,l_period_start_date, -- :4,:5,:6
                        l_period_start_date,l_period_end_date; -- :7,:8

                */

	        EXECUTE IMMEDIATE l_directsSQL BULK COLLECT INTO l_person_ids USING
	        	l_supervisor,l_period_end_date,l_period_start_date ;


	ELSE
                l_allEmpSQL := 'SELECT distinct person_id
			     FROM per_all_assignments_f asgn
			     WHERE person_id <> :1
			       AND primary_flag = ''Y''
			       AND assignment_type in (''E'',''C'')';

		IF l_location_id IS NOT NULL
		THEN
			l_allEmpSQL := l_allEmpSQL || ' AND location_id = ' || l_location_id;
		END IF;

		IF l_org_id IS NOT NULL
		THEN
			l_allEmpSQL := l_allEmpSQL || ' AND organization_id = ' || l_org_id;
		END IF;


                -- Bug 8205132
                -- Rewrote the below SQL in line with the directs sql
                -- to avoid unwanted records.
                -- New query, less bind variables, hence rewrote
                -- the Execute Immediate also.
/*
                -- Bug 7829336
                -- Added condition to check for Mid period hire
                -- and mid period hire and termination.
                -- Prior to this bug, the date check did not cover these aspects.

		l_allEmpSQL := l_allEmpSQL ||
			   '  CONNECT BY PRIOR person_id = supervisor_id
			       AND (   (    trunc(effective_start_date) <= :2
				       AND trunc(effective_end_date) >= :3
                                       )
                                     OR
                                      (     trunc(effective_start_date) > :31
			               AND trunc(effective_end_date) >= :5
                                       AND trunc(effective_end_date) > :6
                                       )
                                     OR
                                      (     trunc(effective_start_date) > :7
			               AND trunc(effective_end_date) < :8
                                       )
                                     )
			     START WITH person_id = :4
			       AND trunc(effective_start_date) <= trunc(sysdate)
			       AND trunc(effective_end_date) >= trunc(sysdate)
	 		     ORDER BY 1';


                -- Bug 7829336
                -- Added bind variables to include the changed queries.

		EXECUTE IMMEDIATE l_allEmpSQL
		     BULK COLLECT
		             INTO l_person_ids
		            USING l_supervisor, l_period_start_date, l_period_start_date,    -- :1,:2,:3
				  l_period_start_date,l_period_end_date,l_period_start_date, -- :31,:5,:6
                        	  l_period_start_date,l_period_end_date,l_supervisor;        -- :7,:8,:4

*/


		l_allEmpSQL := l_allEmpSQL ||
			   '  CONNECT BY PRIOR person_id = supervisor_id
			       AND trunc(effective_start_date) <= :2
                               AND trunc(effective_end_date) >= :3
			     START WITH person_id = :4
			       AND trunc(effective_start_date) <= :5
			       AND trunc(effective_end_date) >= :6
	 		     ORDER BY 1';


		EXECUTE IMMEDIATE l_allEmpSQL
		     BULK COLLECT
		             INTO l_person_ids
		            USING l_supervisor, l_period_end_date, l_period_start_date,
                                  l_supervisor,
                                  l_period_end_date, l_period_start_date;


	END IF;

	filter_person_ids(p_person_ids => l_person_ids,
			  p_filtered_person_ids => l_filtered_person_ids);

	populate_temp_table(l_filtered_person_ids);


END populate_report_table;

PROCEDURE clear_report_table
IS

l_sql varchar2(1000);

BEGIN
	l_sql	:= 'DELETE FROM HXC_TCD_TMP_RPT
			WHERE RESOURCE_ID = :1
			  AND REC_PERIOD_ID = :2
			  AND PERIOD_START_DATE = :3
			  AND PERIOD_END_DATE = :4
			  AND SUPERVISOR_ID = :5
			  AND LOCATION_ID = :6
			  AND ORGANIZATION_ID = :7
			  AND SEL_SUPERVISOR_ID	= :8
			  AND SEL_TC_STATUS = :9
			  AND RPT_STATUS = :10';

	EXECUTE IMMEDIATE l_sql USING l_resource_id, l_rec_period_id, l_period_start_date, l_period_end_date,
			l_supervisor_id, l_location_id, l_org_id, l_sel_supervisor_id, l_sel_tc_status, l_rpt_status;

END clear_report_table;

END HXC_TCD_XML_PKG ;

/
