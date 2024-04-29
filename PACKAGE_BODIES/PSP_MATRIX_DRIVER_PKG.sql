--------------------------------------------------------
--  DDL for Package Body PSP_MATRIX_DRIVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_MATRIX_DRIVER_PKG" as
/* $Header: PSPLSMTB.pls 120.5.12010000.4 2009/01/27 07:54:38 sabvenug ship $  */

start_period	BINARY_INTEGER:=1;
global_run_id   NUMBER(9);

TYPE	mat_tab IS TABLE OF DATE
	INDEX BY BINARY_INTEGER;
TYPE	type_tab IS TABLE OF CHAR
	INDEX BY BINARY_INTEGER;
 dat mat_tab;
 dat1 mat_tab;
 type_dat type_tab;

--	Introduced the following for bug fix 3697471
TYPE schedule_chunk_rec IS RECORD
	(schedule_begin_date	mat_tab,
	schedule_end_date	mat_tab);

schedule_chunk	schedule_chunk_rec;
--	End of changes for bug fix 3697471

/* The following procedure initializes the global variable run_id which distinguishes records inserted into the temporary table by each session*/

procedure set_runid is
BEGIN
select psp_ls_runid_s.nextval into global_run_id
from dual;
END;

/* this procedure deletes all the records that have been inserted into the temp table in that session*/

procedure clear_table (event VARCHAR2)is
BEGIN
delete from psp_matrix_driver
where run_id = global_run_id;
if (event = 'POST-FORM') then
--For Bug 2720395 : Uncommenting the Commit
COMMIT;
--null;
--End of bug Changes
end if;
END;

/* defines the upper limit of time periods that are displayed in the dynamic view*/

procedure set_start_period(n NUMBER) is
BEGIN
start_period:=n;
END set_start_period;

/* returns the maximum # of distinct periods existing in the temp table. Its also equal to the no. of records in the pl/sql table*/

FUNCTION get_max_periods RETURN NUMBER is
BEGIN
/* RETURN dat.COUNT-1;  Commented for bug 4511249*/
RETURN schedule_chunk.schedule_begin_date.COUNT-1;
END;

/* the function formats the start and end period of each distict period in the temp table and returns the appropriate string to the corresponding prompt in the form*/

FUNCTION get_dynamic_prompt(n NUMBER, s_id number) RETURN VARCHAR2 IS
new_line varchar2(30);		-- Moved default value assignment to pl/sql block as part of bug fix 3697471
prompt varchar2(30);
prompt1 varchar2(30);
prompt2 varchar2(30);
v_count1 number;
v_count2 number;
v_count3 number;
v_count4 number;
BEGIN
	new_line := '
';			-- Introduced for bug fix 3697471 to fix GSCC warning File.Sql.35

---if (start_period+n > get_max_periods) --  commented this line
   if (start_period+n <0) then           -- and added this condn for 2365076
	return null;
else
/*
--
--If it is the first period, then if dat(i+1) is a Begin Date in schedule lines, period prompt would be
--from dat(i) to (dat(i+1)-1), else dat(i) to dat(i+1).
--
	if ((start_period+n)=1) then
	  select count(*) into v_count1 from psp_schedule_lines
	  where schedule_begin_date = dat(start_period+n+1)
	  and schedule_hierarchy_id = s_id;
	  if v_count1 = 0 then
           prompt1 := to_char(dat(start_period+n));
           prompt2 := to_char(dat(start_period+n+1));
	  else
	   prompt1 := to_char(dat(start_period+n));
           prompt2 := to_char(dat(start_period+n+1)-1);
	  end if;

          prompt1:=substr(prompt1,1,2)||substr(prompt1,4,3)||substr(prompt1,8,2);
          prompt2:=substr(prompt2,1,2)||substr(prompt2,4,3)||substr(prompt2,8,2);

          prompt:= prompt1||new_line||prompt2;

--
--If it is not the first period, then...
--if dat(i) is a Begin Date in schedule lines, period prompt would start from dat(i), else from dat(i)+1.
--if dat(i) is a Begin Date as well as End Date in schedule lines, period prompt would start from
--(dat(i)+1).
--if dat(i+1) is not a Begin Date, but is an End Date in schedule lines, period prompt would end at
--dat(i+1), else at (dat(i+1)-1).
--
--if dat(i) = dat(i+1) or dat(i+1) = dat(i)+1, period prompt would be from dat(i) to dat(i+1).
--

	else
	  select count(*) into v_count1 from psp_schedule_lines
	  where schedule_begin_date = dat(start_period+n)
	  and schedule_hierarchy_id = s_id;

	  select count(*) into v_count2 from psp_schedule_lines
	  where schedule_begin_date = dat(start_period+n+1)
	  and schedule_hierarchy_id = s_id;

	  select count(*) into v_count3 from psp_schedule_lines
	  where schedule_end_date = dat(start_period+n)
	  and schedule_hierarchy_id = s_id;

	  select count(*) into v_count4 from psp_schedule_lines
	  where schedule_end_date = dat(start_period+n+1)
	  and schedule_hierarchy_id = s_id;

	  if v_count1 = 0 then
		prompt1 := to_char(dat(start_period+n)+1);
	  else
		prompt1 := to_char(dat(start_period+n));
	  end if;

	  if v_count1 <> 0 and v_count3 <> 0 then
		prompt1 := to_char(dat(start_period+n)+1);
	  end if;

	  if v_count2 = 0 and v_count4 <> 0 then
		prompt2 := to_char(dat(start_period+n+1));
	  else
		prompt2 := to_char(dat(start_period+n+1)-1);
	  end if;

	  if dat(start_period+n) = dat(start_period+n+1)
		or dat(start_period+n+1) = dat(start_period+n)+1 then
                   prompt1 := to_char(dat(start_period+n));
                   prompt2 := to_char(dat(start_period+n+1));
	  end if;

          prompt1:=substr(prompt1,1,2)||substr(prompt1,4,3)||substr(prompt1,8,2);
          prompt2:=substr(prompt2,1,2)||substr(prompt2,4,3)||substr(prompt2,8,2);

          prompt:= prompt1||new_line||prompt2;

	end if;
	 Commented for Bug 4511249 */

	/* Introduced the following for Bug 4511249 */

	  prompt1 := to_char(schedule_chunk.schedule_begin_date(start_period+n+1));
          prompt2 := to_char(schedule_chunk.schedule_end_date(start_period+n+1));

          prompt1:=substr(prompt1,1,2)||substr(prompt1,4,3)||substr(prompt1,8,2);
          prompt2:=substr(prompt2,1,2)||substr(prompt2,4,3)||substr(prompt2,8,2);
          prompt:= prompt1||new_line||prompt2;


	/* End of code chages for Bug 4511249 */

	RETURN prompt;
end if;
END;
/* the function returns the total scheduled percentage of each distinct period in the temp table*/

FUNCTION get_dynamic_totals(n NUMBER) RETURN NUMBER IS
total NUMBER;
st_date DATE;
BEGIN
-- st_date:= dat(start_period+n); Commented for bug 4511249
st_date:= schedule_chunk.schedule_begin_date(start_period+n+1);
if (start_period+n > get_max_periods) then
	return null;
else
  select sum(PERIOD_SCHEDULE_PERCENT)
	into total
	from psp_matrix_driver
	where run_id = global_run_id
	and  period_start_date = st_date
	and  period_end_date = schedule_chunk.schedule_end_date(start_period+n+1);
  return total;
end if;
END;


FUNCTION get_run_id RETURN NUMBER is
begin
return global_run_id;
end;

FUNCTION get_start_period(n NUMBER) RETURN DATE is
i BINARY_INTEGER;
BEGIN
i:=start_period+n;
/*if (i > get_max_periods) then
	RETURN null;
else*/
-- RETURN dat(i); Commented for bug fix 4511249
RETURN schedule_chunk.schedule_begin_date(start_period + n + 1);
--end if;
END;

FUNCTION get_end_period(n NUMBER) RETURN DATE is
i BINARY_INTEGER;
BEGIN
i:=start_period+n+1;
/*if (i > get_max_periods) then
	RETURN null;
else*/
-- RETURN dat(i); Commented for bug fix 4511249
RETURN schedule_chunk.schedule_end_date(start_period + n + 1);
--end if;
END;

-- deletes the records in the pl/sql table

procedure purge_table is
begin
 dat.DELETE;
 dat1.DELETE;
 type_dat.DELETE;
 schedule_chunk.schedule_end_date.delete; -- Commented for bug fix 4511249
 schedule_chunk.schedule_begin_date.delete; -- Commented  for bug fix 4511249
 end purge_table;

/* this is the procedure that is responsible for the bulk of the work. It sorts the pool of begin and end dates specified on the various schedule lines.*/
/* After the sort it inserts the dates into pl/sql table thereby forming distinct periods of consistent charging instructions. */
/*Once the pl/sql table is loaded, the start and end dates of the distinct periods are inserted into the temp table. */
/*As the cursor parses through each record a correponding schedule percentage is inserted according to the overlap of these distinct periods with the periods specified on each schedule line*/

procedure load_table(sch_id  number) is
  CURSOR sched_lines(s_id NUMBER) IS
    SELECT 	schedule_line_id l_id,
		schedule_begin_date sbd,
		schedule_end_date sed,
		schedule_percent sp
    FROM	psp_schedule_lines
    WHERE	schedule_hierarchy_id = s_id;

--Get the dates (schedule begin dates and end dates) in ascending order of dates. If a date is present in
--begin as well as the end date, bring the End Date first.
  CURSOR dates(s_id NUMBER) IS
    SELECT 	schedule_begin_date dat , 'B'
    FROM	psp_schedule_lines
    WHERE	schedule_hierarchy_id = s_id
    UNION
    SELECT 	schedule_end_date dat , 'E'
    FROM	psp_schedule_lines
    WHERE	schedule_hierarchy_id = s_id
    ORDER BY	1, 2 ;

  i BINARY_INTEGER :=0;
  j BINARY_INTEGER :=0;
  k BINARY_INTEGER :=1;

  sch_rec sched_lines%ROWTYPE;
  per number;
  temp date;
  num number;
  dummy char(1);
  v_count1	number;
  v_count2	number;
BEGIN
/*****  Commented for Bug Fix 4511249
--From the cursor, get the dates in pl/sql table dat1.
  OPEN dates(sch_id);
  LOOP
     i:=i+1;
  FETCH dates INTO temp, dummy;
  EXIT WHEN dates%NOTFOUND;
  --dbms_output.put_line('date is:'||to_char(temp));
  dat1(i):=temp;
  type_dat(i) := dummy;
  END LOOP;

 -- Added the following for Bug no 2836176 by tbalacha
-- This code was added to avoid when No_DATA_FOUND exception for hierarchy that dont have schedule lines
--   defined

  IF (dates%ROWCOUNT = 0) THEN
     RETURN;
  END IF;

-- End of code for Bug no 2836176
  CLOSE dates;

--
--Copy dates from table 'dat1' to table 'dat'. If there is a Begin Date which is exactly 1 day greater
--than the End Date, DO NOT include this Begin Date in table 'dat'.
  i := 1;
  dat(i) := dat1(i);
  j := 2;
  FOR i IN 2..dat1.COUNT LOOP

	if dat1(i) = dat1(i-1) + 1 then
		if type_dat(i) = 'B' and type_dat(i-1) = 'E' then
			null;
		else
			dat(j) := dat1(i);
			j := j + 1;
		end if;
	else
		dat(j) := dat1(i);
		j := j + 1;
	end if;

  END LOOP;

--
--Insert records in temporary table PSP_MATRIX_DRIVER. There may be some dates in 'dat1' which were not
--included in 'dat' because Begin Date was exactly 1 day greater than the End Date. In such a case,
--instead of comparing dates of 'dat' with those of psp_schedule_lines, compare (Begin Date+1) and End
--Date of 'dat' with those of psp_schedule_lines.
--
  OPEN sched_lines(sch_id);
  LOOP
  	FETCH sched_lines INTO sch_rec;
  	EXIT WHEN sched_lines%NOTFOUND;
	num:=dat.COUNT-1;
  	FOR i in 1 .. num LOOP

	if dat(i+1) = dat1(i+1) then

  	  if ((dat(i) between sch_rec.sbd and sch_rec.sed) AND (dat(i+1) between sch_rec.sbd and sch_rec.sed)) THEN
      	    per:= sch_rec.sp;
          else
            per:=0;
  	  end if;

	 else

	  if ((((dat(i)+1) between sch_rec.sbd and sch_rec.sed) AND (dat(i+1) between sch_rec.sbd and sch_rec.sed))
--		Added the following condition for bug 2267098
		OR (dat(i) = dat(i + 1) AND(dat(i) between sch_rec.sbd AND sch_rec.sed))) THEN
      	    per:= sch_rec.sp;
          else
            per:=0;
  	  end if;

	 end if;

  	  insert into psp_matrix_driver(RUN_ID,
				SCHEDULE_LINE_ID,
				PERIOD_START_DATE,
				PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT) values
				(global_run_id,
				 sch_rec.l_id,
				 dat(i),
				 dat(i+1),
				 per);
  	END LOOP;
  END LOOP;

  End of comment for bug fix 4511249	*****/


 /**** Introduced the following for bug fix 4511249	****/

                       OPEN dates(sch_id);
			FETCH dates BULK COLLECT INTO dat, type_dat;
			CLOSE dates;

			FOR rowno IN 1..(dat.COUNT - 1) LOOP
				IF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'B') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno);
					schedule_chunk.schedule_end_date(k) := dat(rowno+1) - 1;
					k := k+1;
				ELSIF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'E') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno);
					schedule_chunk.schedule_end_date(k) := dat(rowno+1);
					k := k+1;
				ELSIF (type_dat(rowno) = 'E' AND type_dat(rowno+1) = 'E') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno) + 1;
					schedule_chunk.schedule_end_date(k) := dat(rowno+1);
					k := k+1;
				ELSIF (dat(rowno+1) - dat(rowno) > 1) THEN   -- Bug 6623195
				        schedule_chunk.schedule_begin_date(k) := dat(rowno) + 1;
					schedule_chunk.schedule_end_date(k) := dat(rowno+1) - 1;
					k := k+1;
				END IF;
			END LOOP;

			k:=1;
			FOR rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
			LOOP
				dat(k) := schedule_chunk.schedule_begin_date(rowno);
				IF schedule_chunk.schedule_begin_date(rowno) = schedule_chunk.schedule_end_date(rowno) THEN
					dat(k) := schedule_chunk.schedule_end_date(rowno);
					k := k + 1;
				ELSE
					dat(k+1) := schedule_chunk.schedule_end_date(rowno);
					k := k + 2;
				END IF;
			END LOOP;

			FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
			INSERT INTO psp_matrix_driver
				(RUN_ID,					SCHEDULE_LINE_ID,
				PERIOD_START_DATE,
				PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT)
			SELECT 	global_run_id,					schedule_line_id,
				schedule_chunk.schedule_begin_date(rowno),
				schedule_chunk.schedule_end_date(rowno),
				schedule_percent
			FROM	psp_schedule_lines psl
			WHERE	schedule_hierarchy_id = sch_id
			AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
			AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

			FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
			INSERT INTO psp_matrix_driver
				(RUN_ID,					SCHEDULE_LINE_ID,
				PERIOD_START_DATE,
				PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT)
			SELECT 	global_run_id,					schedule_line_id,
				schedule_chunk.schedule_begin_date(rowno),
				schedule_chunk.schedule_end_date(rowno),
				0
			FROM	psp_schedule_lines psl
			WHERE	schedule_hierarchy_id = sch_id
			AND	(psl.schedule_begin_date > schedule_chunk.schedule_end_date(rowno)
				OR	psl.schedule_end_date < schedule_chunk.schedule_begin_date(rowno));

 /**** End of changes for bug fix 4511249	****/

END load_table;

/* this function is used to check the exceedence of the total of the schedule percentages of each distinct period in the temp table over the 100 percent limit*/
/* Added the following code for check exceedence for bug no 2836176 ,
 Introduced the parameter p_payroll_id */
-- Note : The Below code to check for max timeperiod
-- shouldn't be changed as it may effect the existing customers

-- FUNCTION check_exceedence (p_payroll_id		IN   NUMBER)  RETURN Commented Bug 4511249
FUNCTION check_exceedence (p_assignment_id	IN   NUMBER) RETURN
BOOLEAN  IS

-- Introduced payroll_end_date_cur for Bug 2836176

CURSOR  payroll_end_date_cur  IS
SELECT  max(ptp.end_date)
FROM    per_time_periods ptp
WHERE   (ptp.time_period_id,payroll_id) in  (SELECT MAX(ppc.time_period_id),ppc.payroll_id
                                FROM    psp_payroll_controls ppc ,
					psp_payroll_lines ppl  -- Introduced for Bug 4511249
			--	WHERE	ppc.payroll_id = p_payroll_id Commented for Bug 4511249
                                WHERE	ppc.payroll_control_id  = ppl.payroll_control_id
				AND	ppl.assignment_id = p_assignment_id
                                AND     ppc.source_type  IN ('O','N')
				group by ppc.payroll_id);


l_payroll_end_date	DATE; --For Bug no 2836176

-- for bug fix 1779346
CURSOR	sum_percent_cur IS --changed from sum to sum_percent_cur
SELECT	sum(PERIOD_SCHEDULE_PERCENT)
FROM	psp_matrix_driver
WHERE	run_id = global_run_id
AND	period_end_date  >  TRUNC (  NVL ( l_payroll_end_date,fnd_date.canonical_to_date('1900/01/01')))-- added this and conditoin for bug 2836176
GROUP BY period_start_date , period_end_date;


-- Bug 7634722
-- Added cursor sum_percent_cur_left to include newly created schedule periods
--(whose end-dates < payroll_last_run_date) to be included in the check for LS>100%
CURSOR	sum_percent_cur_left IS
SELECT	sum(PERIOD_SCHEDULE_PERCENT)
FROM	psp_matrix_driver
WHERE	run_id = global_run_id
AND	period_end_date  <=  TRUNC (  NVL ( l_payroll_end_date,fnd_date.canonical_to_date('1900/01/01')))-- added this and conditoin for bug 2836176
GROUP BY period_start_date , period_end_date;



l_sum_percent		NUMBER(5,2);

BEGIN
  -- Added for Bug no 2836176 by tbalacha

  OPEN  payroll_end_date_cur;
  FETCH payroll_end_date_cur INTO l_payroll_end_date;
  CLOSE payroll_end_date_cur;

-- end of changes for 2836176

  OPEN	sum_percent_cur;
  LOOP
  FETCH sum_percent_cur   INTO  l_sum_percent;
  EXIT WHEN sum_percent_cur%NOTFOUND;
  IF  (l_sum_percent >100 ) THEN
       CLOSE sum_percent_cur;
       RETURN  FALSE;
  END IF;

  END LOOP;
  CLOSE  sum_percent_cur;

-- Bug 7634722
-- Added cursor sum_percent_cur_left to include newly created schedule periods
--(whose end-dates < payroll_last_run_date) to be included in the check for LS>100%

  OPEN	sum_percent_cur_left;
    LOOP
    FETCH sum_percent_cur_left   INTO  l_sum_percent;
    EXIT WHEN sum_percent_cur_left%NOTFOUND;
    IF  (l_sum_percent >100 ) THEN
         CLOSE sum_percent_cur_left;
         RETURN  FALSE;
    END IF;

    END LOOP;
  CLOSE  sum_percent_cur_left;





  RETURN  TRUE;
END check_exceedence;

/* End of code for bug no 2836176 */


/* this function is used to check the exceedence of the total of the schedule percentages of each distinct period in the temp table over the 1
00 percent limit in the SC_COPY form.*/

FUNCTION check_exceedence_sc_copy RETURN BOOLEAN IS
--For bug Fix  1779346
CURSOR sums IS
        select sum(PERIOD_SCHEDULE_PERCENT)
        from psp_matrix_driver
        where run_id = global_run_id
        group by  PERIOD_START_DATE, PERIOD_END_DATE;
per number(5,2);

begin
  OPEN sums;
  LOOP
        FETCH sums INTO per;
        EXIT WHEN sums%NOTFOUND;
        if (per >50) then
                RETURN FALSE;
        end if;
  END LOOP;
  RETURN TRUE;
  CLOSE sums ;

--REM ================================================================
end check_exceedence_sc_copy;

/*	The following procedure loads all the schedule lines associated with respective schedule hierarchies
	for all those persons who are employees for the selected organizations.
	The procedure finds all the schedule hierarchies and internally calls the load_table function to load
	the corresponding schedule lines */

PROCEDURE load_organizations	(retcode		OUT NOCOPY NUMBER,
				p_organization_id	IN VARCHAR2,
				p_period_from		IN DATE,
				p_period_to		IN DATE,
				p_report_type		IN VARCHAR2,
				p_business_group_id	IN NUMBER,
				p_set_of_books_id	IN NUMBER) IS

CURSOR	sch_hier_cur(v_organization_id NUMBER) IS
SELECT	distinct psh.schedule_hierarchy_id
FROM	psp_schedule_hierarchy psh,
	psp_schedule_lines psl,
	per_assignments_f paf
WHERE	psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
AND	paf.assignment_id = psh.assignment_id
AND	paf.organization_id = v_organization_id
AND	psl.schedule_begin_date <= p_period_to
AND	psl.schedule_end_date >= p_period_from
AND	psl.business_group_id = p_business_group_id
AND	psl.set_of_books_id = p_set_of_books_id
--	Included the following condition for bug fix 2020596 to prevent duplicate import of schedule data
--	for assignments that are assigned to more than one organization
AND	NOT EXISTS (SELECT 1 FROM psp_matrix_driver pmd
		WHERE	pmd.run_id = global_run_id
		AND	pmd.schedule_line_id = psl.schedule_line_id);

sch_hier_rec		sch_hier_cur%ROWTYPE;
l_run_id		number;
l_req_id		number;
l_organization_id	NUMBER;
l_start_position	NUMBER DEFAULT 1;
l_end_position		NUMBER DEFAULT 1;
l_org_length		NUMBER;
l_report_type		VARCHAR2(10);		-- Moved default value initialization to pl/sql block for bug fix 3697471

--	Introduced the following for bug fix 3697471
CURSOR	sched_lines(schedule_hierarchy_id NUMBER) IS
SELECT	schedule_line_id l_id,
	schedule_begin_date sbd,
	schedule_end_date sed,
	schedule_percent sp
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = schedule_hierarchy_id
AND	schedule_end_date >= p_period_from
AND	schedule_begin_date <= p_period_to;

CURSOR	dates(p_schedule_hierarchy_id NUMBER) IS
SELECT 	schedule_begin_date dat , 'B'
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = p_schedule_hierarchy_id
AND	schedule_end_date >= p_period_from
AND	schedule_begin_date <= p_period_to
UNION
SELECT 	schedule_end_date dat , 'E'
FROM	psp_schedule_lines
WHERE	schedule_hierarchy_id = p_schedule_hierarchy_id
AND	schedule_end_date >= p_period_from
AND	schedule_begin_date <= p_period_to
ORDER BY	1, 2 ;

k	BINARY_INTEGER;
--	End of changes for bug fix 3697471

/* Changes for bug 2863953 */

Cursor c_all_org is
SELECT	distinct paf.organization_id
FROM	psp_schedule_hierarchy psh,
	psp_schedule_lines psl,
	per_assignments_f paf
WHERE	psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
AND	paf.assignment_id = psh.assignment_id
AND	psl.schedule_begin_date <= p_period_to
AND	psl.schedule_end_date >= p_period_from
AND	psl.business_group_id = p_business_group_id
AND	psl.set_of_books_id = p_set_of_books_id;


/* End of changes for bug 2863953 */
BEGIN
	l_report_type := 'Regular';	-- Introduced for bug fix 3697471 to fix GSCC Warning file.Sql.35

-- Initialize the fnd message routine
--	errbuf := 'Message Initialization failed';
	fnd_msg_pub.initialize;

-- set the run id for this run
--	errbuf := 'Run ID Initialization failed';
	psp_matrix_driver_pkg.set_runid;

-- Introduced the if condition for bug 2863953
If p_organization_id is null then

FOR org_rec in  c_all_org  Loop
OPEN sch_hier_cur(org_rec.organization_id);
 LOOP -- Looping for all schedule hierarchies
  FETCH sch_hier_cur INTO sch_hier_rec;
  IF (sch_hier_cur%NOTFOUND) THEN
    EXIT;
  END IF;
--  call the matrix driver procedure to load the respective schedule lines
--  errbuf := 'Loading Matrix Driver for Schedule Hierarchy: ' ||
--  sch_hier_rec.schedule_hierarchy_id || ' had Failed';


   k := 1;

   OPEN dates(sch_hier_rec.schedule_hierarchy_id);
   FETCH dates BULK COLLECT INTO dat, type_dat;
   CLOSE dates;

   FOR rowno IN 1..(dat.COUNT - 1) LOOP
		IF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'B') THEN
			schedule_chunk.schedule_begin_date(k) := dat(rowno);
			schedule_chunk.schedule_end_date(k) := dat(rowno+1) - 1;
			k := k+1;
		ELSIF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(k) := dat(rowno);
			schedule_chunk.schedule_end_date(k) := dat(rowno+1);
			k := k+1;
		ELSIF (type_dat(rowno) = 'E' AND type_dat(rowno+1) = 'E') THEN
			schedule_chunk.schedule_begin_date(k) := dat(rowno) + 1;
			schedule_chunk.schedule_end_date(k) := dat(rowno+1);
			k := k+1;
		END IF;
    END LOOP;

    FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
	INSERT INTO psp_matrix_driver
		(RUN_ID,					SCHEDULE_LINE_ID,
		PERIOD_START_DATE,
		PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT)
			SELECT 	global_run_id,					schedule_line_id,
				GREATEST(p_period_from, schedule_chunk.schedule_begin_date(rowno)),
				LEAST(p_period_to, schedule_chunk.schedule_end_date(rowno)),
				schedule_percent
			FROM	psp_schedule_lines psl
			WHERE	schedule_hierarchy_id = sch_hier_rec.schedule_hierarchy_id
			AND	psl.schedule_begin_date <= p_period_to
			AND	psl.schedule_end_date >= p_period_from
			AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
			AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

			dat.delete;
			type_dat.delete;
			schedule_chunk.schedule_end_date.delete;
			schedule_chunk.schedule_begin_date.delete;

   END LOOP; -- End Schedule Hierarchies
   CLOSE sch_hier_cur;


END LOOP; -- End loop for for c_all_org cursor


ELSE

	l_org_length := LENGTH(p_organization_id);

-- Split the selected organizations into individual Organizations and retrieve Schedule Hierarchies for them
	LOOP -- Loop for splitting Organization ID

		l_end_position := INSTR(p_organization_id, ',', l_start_position);

		IF (l_end_position = 0) THEN
			l_end_position := l_org_length + 1;
		END IF;

--		errbuf := 'Retrieving Organizations failed';
		l_organization_id := TO_NUMBER(SUBSTR(p_organization_id, l_start_position,
			(l_end_position - l_start_position)));

--		errbuf := 'Retrieving Schedule Hierarchies failed for Organization: ' || TO_CHAR(l_organization_id);
		OPEN sch_hier_cur(l_organization_id);
		LOOP -- Looping for all schedule hierarchies
			FETCH sch_hier_cur INTO sch_hier_rec;
			IF (sch_hier_cur%NOTFOUND) THEN
				EXIT;
			END IF;
--			call the matrix driver procedure to load the respective schedule lines
--			errbuf := 'Loading Matrix Driver for Schedule Hierarchy: ' ||
--				sch_hier_rec.schedule_hierarchy_id || ' had Failed';

--			psp_matrix_driver_pkg.load_table(sch_hier_rec.schedule_hierarchy_id);	Commented for bug fix 3697471
--			psp_matrix_driver_pkg.purge_table;					Commented for bug fix 3697471


--	Introduced the following for bug fix 3697471
			k := 1;

			OPEN dates(sch_hier_rec.schedule_hierarchy_id);
			FETCH dates BULK COLLECT INTO dat, type_dat;
			CLOSE dates;

			FOR rowno IN 1..(dat.COUNT - 1) LOOP
				IF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'B') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno);
					schedule_chunk.schedule_end_date(k) := dat(rowno+1) - 1;
					k := k+1;
				ELSIF (type_dat(rowno) = 'B' AND type_dat(rowno+1) = 'E') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno);
					schedule_chunk.schedule_end_date(k) := dat(rowno+1);
					k := k+1;
				ELSIF (type_dat(rowno) = 'E' AND type_dat(rowno+1) = 'E') THEN
					schedule_chunk.schedule_begin_date(k) := dat(rowno) + 1;
					schedule_chunk.schedule_end_date(k) := dat(rowno+1);
					k := k+1;
				END IF;
			END LOOP;


			FORALL rowno IN 1..schedule_chunk.schedule_begin_date.COUNT
			INSERT INTO psp_matrix_driver
				(RUN_ID,					SCHEDULE_LINE_ID,
				PERIOD_START_DATE,
				PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT)
			SELECT 	global_run_id,					schedule_line_id,
				GREATEST(p_period_from, schedule_chunk.schedule_begin_date(rowno)),
				LEAST(p_period_to, schedule_chunk.schedule_end_date(rowno)),
				schedule_percent
			FROM	psp_schedule_lines psl
			WHERE	schedule_hierarchy_id = sch_hier_rec.schedule_hierarchy_id
			AND	psl.schedule_begin_date <= p_period_to
			AND	psl.schedule_end_date >= p_period_from
			AND	psl.schedule_begin_date <= schedule_chunk.schedule_end_date(rowno)
			AND	psl.schedule_end_date >= schedule_chunk.schedule_begin_date(rowno);

			dat.delete;
			type_dat.delete;
			schedule_chunk.schedule_end_date.delete;
			schedule_chunk.schedule_begin_date.delete;
--	End of changes for bug fix 3697471

		END LOOP; -- End Schedule Hierarchies
		CLOSE sch_hier_cur;

		IF (l_end_position > l_org_length) THEN
			EXIT;
		END IF;

		l_start_position := l_end_position + 1;
	END LOOP; -- End Organization Id split

End if ; /* Introduced for bug 2863953  */

/*****	Commented for bug fix 3697471
--	Update the psp_matrix_driver table for the current run, deleting zero schedule percent records
--	errbuf := 'Deleting zero schedule percent records failed';
	DELETE	psp_matrix_driver pmd
	WHERE	run_id = global_run_id
	AND	period_schedule_percent = 0;

/ *	Commented for bug fix 2368498
	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = global_run_id
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl,
				psp_schedule_lines psl2
			WHERE	psl.schedule_line_id = pmd.schedule_line_id
			AND	psl2.schedule_hierarchy_id = psl.schedule_hierarchy_id
			AND	psl2.schedule_end_date = pmd.period_start_date
			AND	psl2.schedule_line_id <> psl.schedule_line_id);

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = global_run_id
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl,
				psp_schedule_lines psl2
			WHERE	psl.schedule_line_id = pmd.schedule_line_id
			AND	psl2.schedule_hierarchy_id = psl.schedule_hierarchy_id
			AND	psl2.schedule_begin_date = pmd.period_end_date
			AND	psl2.schedule_line_id <> psl.schedule_line_id);
	End of comment for bug 2368498	* /

--	Introduced for bug fix 2368498
--	Updating the period_start_date for periods in between schedule begin and end dates
--	errbuf := 'Period End Date Update of Matrix Driver failed';
	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = global_run_id
	AND	period_start_date < period_end_date
	AND	period_start_date = (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id))
	AND	EXISTS (SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id));

	UPDATE	psp_matrix_driver pmd
	SET	period_end_date = period_end_date - 1
	WHERE	run_id = global_run_id
	AND	period_start_date < period_end_date
	AND	NOT (NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_begin_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					where psl2.schedule_line_id = pmd.schedule_line_id))
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_end_date = pmd.period_end_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id)))
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id));

--	Updating the period_start_date for periods in between schedule begin and end dates
--	errbuf := 'Period Start Date Update of Matrix Driver failed';
	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = global_run_id
	AND	period_start_date < period_end_date
	AND	NOT EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id))
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id));

	UPDATE	psp_matrix_driver pmd
	SET	period_start_date = period_start_date + 1
	WHERE	run_id = global_run_id
	AND	period_start_date < period_end_date
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_begin_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id))
	AND	EXISTS	(SELECT	1
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_line_id <> pmd.schedule_line_id
			AND	psl1.schedule_end_date = pmd.period_start_date
			AND	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id))
	AND	period_start_date <> (SELECT	MIN(psl1.schedule_begin_date)
			FROM	psp_schedule_lines psl1
			WHERE	psl1.schedule_hierarchy_id = (SELECT psl2.schedule_hierarchy_id
					FROM	psp_schedule_lines psl2
					WHERE	psl2.schedule_line_id = pmd.schedule_line_id));
--	End of Bug fix 2368498
	End of changes for bug fix 3697471	*****/

--	For Exception Report delete records in psp_matrix_driver for which the schedule percentage is 100
	IF (p_report_type = 'E') THEN
--		errbuf := 'Deleting schedules equal to 100 percent failed';
		l_report_type := 'Exception';
		DELETE	psp_matrix_driver pmd
		WHERE	run_id = global_run_id
		AND	EXISTS	(SELECT	1
				FROM	psp_schedule_lines psl,
					psp_schedule_lines psl2
				WHERE	psl2.schedule_hierarchy_id = psl.schedule_hierarchy_id
				AND	psl.schedule_line_id = pmd.schedule_line_id
				AND	psl2.schedule_begin_date <= pmd.period_end_date
				AND	psl2.schedule_end_date >= pmd.period_start_date
				GROUP BY psl2.schedule_hierarchy_id
				HAVING SUM(psl2.schedule_percent) = 100);
	END IF;

/*****	Commented for bug fix 3697471
--	Update the period_end_date to p_period_to if period_end_date > p_period_to
	UPDATE	psp_matrix_driver
	SET	period_end_date = p_period_to
	WHERE	run_id = global_run_id
	AND	period_end_date > p_period_to;

	UPDATE	psp_matrix_driver
	SET	period_start_date = p_period_from
	WHERE	run_id = global_run_id
	AND	period_start_date < p_period_from;
	End of comment for bug fix 3697471	*****/

	retcode := 0;

EXCEPTION
WHEN OTHERS THEN
--	psp_message_s.print_error(	p_mode		=>	FND_FILE.LOG,
--					p_print_header	=>	FND_API.G_FALSE);
	retcode := 2;
END load_organizations;



/**********************************************************
Created By : lveerubh

Date Created By : 05-SEP-2001

Purpose : This procedure does the following jobs :
		  X=10:Sets the Run id for the psp_matrix_table
		  X=20:For each organization chosen by the user (p_list_organization_id)
		  	    it loads the table psp_matrix_Driver by calling procedure
				load_table_schedule
		  X=30:Updates the period_start_date of the schedule_lines in matrix_driver table
		  	   ,for each organization,except the schedule lines with minimum period_start_date
			   so that data in the table becomes as required for the report PSPLSODR.rdf
	      	  X=40:Deletes the schedule lines with zero schedule percent for that run_id.
		  X=50:Checks if the user has asked for an Exception report. If yes, then it deletes
		  	   for a particular organization and particular period_start_date,period_end_date ,
			   all those schedule lines whose sum of period_schedule_percent equals 100


Know limitations, enhancements or remarks

Change History

Who			   When 		   	  What
Lveerubh	   05-SEP-2001		  Created the procedure
Lveerubh	   03-OCT-2001		  1. Removing the call for the report from the package  -Bug 2022193

***************************************************************/
procedure load_org_schedule(p_return_status 	   	OUT NOCOPY	NUMBER,
		            p_log_message		OUT NOCOPY	VARCHAR2,
		    	    p_list_organization_id      IN 	VARCHAR2,
			    p_period_from 		IN	VARCHAR2,
			    p_period_to	       		IN	VARCHAR2,
			    p_report_type		IN	VARCHAR2,
			    p_business_group_id		IN	NUMBER,
			    p_set_of_books_id		IN	NUMBER
          		)
IS


CURSOR c_schedule_percent(F_run_id	NUMBER)
IS
SELECT 		pdls.organization_id,
		pmd.period_start_date,
		pmd.period_end_date
FROM		psp_default_labor_schedules 	pdls,
		psp_matrix_driver		pmd
WHERE		pdls.org_schedule_id	=	pmd.schedule_line_id
AND 		pmd.run_id 		= 	F_run_id
GROUP BY	pdls.organization_id,
		pmd.period_start_date,
		pmd.period_end_date
HAVING	SUM(pmd.period_schedule_percent) = 	100;


CURSOR   c_schedule_line_id(  F_organization_id		NUMBER,
		              F_period_start_date	DATE,
		              F_period_end_date		DATE,
		              F_run_id			NUMBER)
IS
SELECT	 pdls.org_schedule_id
FROM	psp_default_labor_schedules pdls,
	psp_matrix_driver 	pmd
WHERE	pdls.organization_id	 	=	F_organization_id
AND 	pdls.schedule_begin_date	<=	F_period_end_date
AND 	pdls.schedule_end_date		>=	F_period_start_date
AND	pmd.schedule_line_id		= 	pdls.org_Schedule_id
AND  	pmd.run_id			=	F_run_id;


CURSOR c_period_start_date(F_run_id NUMBER)
IS
SELECT   min(pmd1.period_start_date) period_start_date,
	 pdls.organization_id
FROM     psp_matrix_driver pmd1,
 	 psp_default_labor_schedules pdls
WHERE    pmd1.run_id 		=   F_run_id
AND      pmd1.schedule_line_id 	= 	pdls.org_schedule_id
GROUP BY pdls.organization_id;

rec_sch_percent				c_schedule_percent%ROWTYPE;
rec_sch_line_id				c_schedule_line_id%ROWTYPE;
rec_period_start_date  			c_period_start_date%ROWTYPE;

l_req_id                NUMBER;
l_call_status           BOOLEAN;
l_rphase                VARCHAR2(30);
l_rstatus               VARCHAR2(30);
l_dphase                VARCHAR2(30);
l_dstatus               VARCHAR2(30);
l_message               VARCHAR2(240);
l_run_id		NUMBER;
l_period_start_date	DATE;
l_end_position		NUMBER   DEFAULT  1;
l_begin_position	NUMBER   DEFAULT  1;
l_new_position		NUMBER ;
l_org_id		VARCHAR2(10);
l_org_length		NUMBER;
l_report_type		VARCHAR2(10);		-- Moved default value initialization to pl/sql block for bug fix 3697471


CURSOR c_all_org
IS
SELECT	distinct organization_id
FROM	psp_default_labor_schedules
WHERE	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id;


BEGIN
	l_report_type := 'Regular';	-- Introduced for bug fix 3697471 to fix GSCC Warning file.Sql.35
-- Initialize the fnd message routine
       fnd_msg_pub.initialize;

--set the Run Id for the current request
--dbms_output.put_line('Organization List '||p_list_organization_id);

--X=10
psp_matrix_driver_pkg.set_runid;
l_run_id := psp_matrix_driver_pkg.get_run_id;
--dbms_output.put_line(l_run_id);
--errbuf := 'Run id '||global_run_id;
psp_matrix_driver_pkg.purge_table;

--X=20

If p_list_organization_id  is null then

For l_org_rec in  c_all_org
loop
psp_matrix_driver_pkg.load_table_schedule(to_number(l_org_rec.organization_id)
  ,p_business_group_id,p_set_of_books_id);
psp_matrix_driver_pkg.purge_table;
end loop;


else

l_org_length := length(p_list_organization_id) ;
LOOP -- Loop for splitting Organization ID
		l_end_position := INSTR(p_list_organization_id, ',', l_begin_position);
		IF (l_end_position = 0) THEN
			l_end_position := l_org_length + 1;
		END IF;
		l_org_id := TO_NUMBER(SUBSTR(p_list_organization_id, l_begin_position,(l_end_position - l_begin_position)));
		psp_matrix_driver_pkg.load_table_schedule(to_number(l_org_id),p_business_group_id,p_set_of_books_id);
		psp_matrix_driver_pkg.purge_table;
		IF (l_end_position > l_org_length) THEN
			EXIT;
		END IF;
		 l_begin_position := l_end_position + 1;
 END LOOP; -- End Organization Id split

end if;
--X=30
--Updating the records created in psp_matrix_driver in the manner required to be displayed in the report
                UPDATE  psp_matrix_driver pmd
        	SET     period_start_date = period_start_date + 1
       	        WHERE   run_id =l_run_id
         	AND     EXISTS (SELECT 1
    				FROM     psp_default_labor_schedules pdls1,
   				psp_default_labor_schedules pdls2
   				WHERE    pdls1.org_schedule_id=pmd.schedule_line_id
  		       	        AND      pdls1.organization_id=pdls2.organization_id
  				AND      pdls1.org_schedule_id<>pdls2.org_schedule_id
  				AND      pdls2.schedule_end_date=pmd.period_start_date);

		UPDATE   psp_matrix_driver pmd
       		SET      period_end_date = period_end_date - 1
                WHERE   run_id =l_run_id
 		AND     EXISTS  (SELECT pmd.period_end_date
  		   		FROM     psp_default_labor_schedules pdls1,
   		       		psp_default_labor_schedules pdls2
		 		WHERE    pdls1.org_schedule_id=pmd.schedule_line_id
		 		AND      pdls2.organization_id=pdls1.organization_id
		  		AND      pdls2.schedule_begin_date=pmd.period_end_date
		 		AND      pdls1.org_schedule_id<>pdls2.org_schedule_id);

--X=40
-- Delete  the Zero Schedule Percent
   DELETE  psp_matrix_driver
   WHERE   run_id = global_run_id
   AND     period_schedule_percent = 0;

--X=50
---Deleting Schedule Percent equal to 100
	IF	p_report_type = 'E' THEN
--                l_report_type:='Exception';
	OPEN	c_schedule_percent(l_run_id);
	LOOP
	FETCH 	c_schedule_percent	INTO	rec_sch_percent	;
	EXIT 	WHEN c_schedule_percent%NOTFOUND;

	OPEN	c_schedule_line_id(rec_sch_percent.organization_id,
				   rec_sch_percent.period_start_date,
				   rec_sch_percent.period_end_date,
				l_run_id);
	LOOP
	FETCH	c_schedule_line_id	INTO	rec_sch_line_id;
	EXIT	WHEN c_schedule_line_id%NOTFOUND;

                DELETE  psp_matrix_driver pmd
        	WHERE   pmd.run_id 		= 	l_run_id
        	And	pmd.schedule_line_id	=	rec_sch_line_id.org_schedule_id
        	And	pmd.period_start_date	=	rec_sch_percent.period_start_date
        	And	pmd.period_end_date	=	rec_sch_percent.period_end_date;

    	END LOOP;	--End of c_schedule_line_id
	CLOSE c_schedule_line_id;
	END LOOP;	--End of c_schedule_percent
	CLOSE c_schedule_percent;
	END IF;

--Updating the records greater  than p_period_to to NUll ,so that in Schedule Summary in report these will be
--displayed  with end date as p_period_to
	UPDATE  psp_matrix_driver
        SET     period_end_date 	= p_period_to
        WHERE   run_id 			= l_run_id
        AND     period_end_date 	> p_period_to;

	UPDATE	psp_matrix_driver
	SET	period_start_date 	= p_period_from
	WHERE	run_id 			= l_run_id
	AND	period_start_date 	< p_period_from;

p_return_status :=	0;
p_log_message   := 	'Success';

EXCEPTION
WHEN OTHERS THEN
p_log_message := sqlerrm;
p_return_status :=2;
END load_org_schedule;

/**********************************************************
Created By : lveerubh

Date Created By : 05-SEP-2001

Purpose : This procedure is introduced to populate psp_matrix_driver with the
		  data from psp_default_labor_schedules.It sorts the pool of begin and end dates
		  specified on the various schedule lines. After the sort it inserts the dates into
		  pl/sql table thereby forming distinct periods of consistent charging instructions.
          Once the pl/sql table is loaded, the start and end dates of the distinct periods are
		  inserted into the temp table.As the cursor parses through each record a correponding
		  schedule percentage is inserted according to the overlap of these distinct periods with
		  the periods specified on each schedule line
Know limitations, enhancements or remarks

Change History

Who			   When 		   	  What
Lveerubh	   05-SEP-2001		  Created the procedure

***************************************************************/


PROCEDURE  load_table_schedule(sch_id  NUMBER,
			       p_business_group_id NUMBER,
			       p_set_of_books_id   NUMBER)
IS
  CURSOR sched_lines(s_id NUMBER)
  IS
  SELECT 	org_schedule_id l_id,
		schedule_begin_date sbd,
		schedule_end_date sed,
		schedule_percent sp
  FROM		psp_default_labor_schedules
  WHERE		organization_id 	= s_id
   AND		business_group_id 	= p_business_group_id
   AND   	set_of_books_id	  	= p_set_of_books_id;

--Get the dates (schedule begin dates and end dates) in ascending order of dates. If a date is present in
--begin as well as the end date, bring the End Date first.
  CURSOR dates(s_id NUMBER) IS
    SELECT 	schedule_begin_date dat , 'B'
    FROM	psp_default_labor_schedules
    WHERE	organization_id  	= s_id
    AND		business_group_id 	= p_business_group_id
    AND   	set_of_books_id	  	= p_set_of_books_id
    UNION
    SELECT 	schedule_end_date dat , 'E'
    FROM	psp_default_labor_schedules
    WHERE	organization_id 	= s_id
    AND		business_group_id 	= p_business_group_id
    AND   	set_of_books_id	  	= p_set_of_books_id
    ORDER BY	1, 2 ;
  i BINARY_INTEGER :=0;
  j BINARY_INTEGER :=0;

  sch_rec 	sched_lines%ROWTYPE;
  per number;
  temp date;
  num number;
  dummy char(1);
  v_count1	number;
  v_count2	number;
  l_count3	number;
BEGIN
--From the cursor, get the dates in pl/sql table dat1.
  OPEN dates(sch_id);
  LOOP
     i	:=	i+1;
  FETCH dates INTO temp, dummy;
  EXIT WHEN dates%NOTFOUND;
--  dbms_output.put_line('date is:'||to_char(temp)||' the organization_id '||sch_id);
  dat1(i)	:=	temp;
  type_dat(i)   := 	dummy;
  END LOOP;
  CLOSE dates;
--
--Copy dates from table 'dat1' to table 'dat'. If there is a Begin Date which is exactly 1 day greater
--than the End Date, DO NOT include this Begin Date in table 'dat'.
  i := 1;
  dat(i) 	:= 	dat1(i);
  j := 2;
  FOR i IN 2..dat1.COUNT LOOP

	IF dat1(i) = dat1(i-1) + 1 THEN
		IF type_dat(i) = 'B' and type_dat(i-1) = 'E' THEN
			null;
		ELSE
			dat(j) := dat1(i);
			j := j + 1;
		END IF;
	ELSE
		dat(j) := dat1(i);
		j := j + 1;
	END IF;

  END LOOP;

--
--Insert records in temporary table PSP_MATRIX_DRIVER. There may be some dates in 'dat1' which were not
--included in 'dat' because Begin Date was exactly 1 day greater than the End Date. In such a case,
--instead of comparing dates of 'dat' with those of psp_schedule_lines, compare (Begin Date+1) and End
--Date of 'dat' with those of psp_schedule_lines.
--
  OPEN sched_lines(sch_id);
  LOOP
  	FETCH sched_lines INTO sch_rec;
  	EXIT WHEN sched_lines%NOTFOUND;
	num:=dat.COUNT-1;
  	FOR i in 1 .. num LOOP

	IF dat(i+1) = dat1(i+1) THEN

  	  IF ((dat(i) between sch_rec.sbd and sch_rec.sed) AND (dat(i+1) between sch_rec.sbd and sch_rec.sed)) THEN
      	    per:= sch_rec.sp;

          ELSE
            per:=0;

  	  END IF;

	 ELSE
	  IF (((dat(i)+1) between sch_rec.sbd and sch_rec.sed) AND (dat(i+1) between sch_rec.sbd and sch_rec.sed)) THEN
      	    per:= sch_rec.sp;

          ELSE
            per:=0;

  	  END IF;

	 END IF;

  	  INSERT INTO psp_matrix_driver(RUN_ID,
				SCHEDULE_LINE_ID,
				PERIOD_START_DATE,
				PERIOD_END_DATE,
				PERIOD_SCHEDULE_PERCENT) values
				(global_run_id,
				 sch_rec.l_id,
				 dat(i),
				 dat(i+1),
				 per);
  	END LOOP;
  END LOOP;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 null;
 WHEN OTHERS THEN
 null;
 END load_table_schedule;


/*****************************************************************************************
  Procedure name: check_sch_hierarchy
  Purpose : This Procedure checks the hierarchy for the current asignment and prevents
  that user from committing any new changes when there are any existing / new errors.
  Description: this procedure checks for schedules exceeding 100% issue for al the hierarchies
  and for the respective assignment.It takes assignment_id and payroll_id as parameters to
  validate the schedule lines that are valid after the last imported payroll_date.
  Creation date :14-APR-2003
*****************************************************************************************/

PROCEDURE  check_sch_hierarchy(p_assignment_id		IN   NUMBER,
			       p_payroll_id		IN   NUMBER,
			       p_hierarchy_id		OUT  NOCOPY	NUMBER,
			       p_invalid_count		OUT  NOCOPY	NUMBER) IS


    CURSOR sch_hier_cur IS
    SELECT schedule_hierarchy_id
    FROM psp_schedule_hierarchy
    WHERE  assignment_id = p_assignment_id;

   l_schedule_hierarchy_id	NUMBER ( 15 );
   l_invalid_count		NUMBER  DEFAULT 0;

   BEGIN
    OPEN sch_hier_cur;
    LOOP
    FETCH sch_hier_cur INTO l_schedule_hierarchy_id;
    EXIT WHEN sch_hier_cur%NOTFOUND;
    psp_matrix_driver_pkg.clear_table('REFRESH');
    psp_matrix_driver_pkg.purge_table;
    psp_matrix_driver_pkg.load_table(l_schedule_hierarchy_id);
    IF (NOT psp_matrix_driver_pkg.check_exceedence(p_assignment_id)) THEN
	l_invalid_count  := l_invalid_count + 1;
	p_hierarchy_id :=l_schedule_hierarchy_id;
    END IF;
    END LOOP;
    CLOSE sch_hier_cur;
    psp_matrix_driver_pkg.clear_table('REFRESH');
    psp_matrix_driver_pkg.purge_table;
    p_invalid_count := l_invalid_count;
   END check_sch_hierarchy;

/* End of code for Bug no 2836176 By tbalacha*/


end psp_matrix_driver_pkg;

/
