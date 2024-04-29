--------------------------------------------------------
--  DDL for Package Body PER_PERIODS_OF_SERVICE_PKG_V2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERIODS_OF_SERVICE_PKG_V2" AS
/* $Header: pepds02t.pkb 120.1 2006/05/08 08:44:47 lsilveir noship $ */
--
-- flemonni
-- hire date changes bug # 625423
----------------------------------------------------------------------------
--
-- hire date changes flemonni bug # 625423
--
TYPE Age_dates
IS RECORD
  ( min_date	date
  , max_date	date
  );
--
g_b2b_allowed 			BOOLEAN;
g_person_type_changes_exist	BOOLEAN;

l_start_of_time date 	:= hr_general.start_of_time;
l_end_of_time date 	:= hr_general.end_of_time;
----------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- FLEMONNI
-- hire date changes bug #625423
-------------------------------------------------------------------------------
FUNCTION Get_Max_Last_Process_date
  ( p_person_id IN NUMBER
  )
RETURN DATE
IS
--
  l_date	DATE;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Max_Last_Process_date';
--
  CURSOR cur_get_max_date (p_person_id NUMBER)
  IS
    SELECT max(final_process_date)
    FROM per_periods_of_service
    WHERE person_id = p_person_id;
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN cur_get_max_date (p_person_id => p_person_id);
  FETCH cur_get_max_date INTO l_date;
  IF cur_get_max_date%NOTFOUND THEN
    CLOSE cur_get_max_date;
    l_date := NULL;
  ELSE
    CLOSE cur_get_max_date;
  END IF;
--
  RETURN l_date;
END Get_Max_Last_Process_date;
-------------------------------------------------------------------------------
FUNCTION Get_Current_PDS_Record
  ( p_person_id 	IN per_people_f.person_id%TYPE
  )
RETURN per_periods_of_service%ROWTYPE
IS
  l_record	per_periods_of_service%ROWTYPE;
--
  CURSOR csr_pds_status
    ( p_person_id 	per_people_f.person_id%TYPE
    )
  IS
    SELECT *
    FROM per_periods_of_service
    WHERE period_of_service_id =
      ( SELECT max(period_of_service_id)
        FROM per_periods_of_service
        WHERE person_id = p_person_id
      );
BEGIN
  OPEN csr_pds_status
    ( p_person_id => p_person_id
    );
  FETCH csr_pds_status INTO l_record;
  IF csr_pds_status%NOTFOUND THEN
   CLOSE csr_pds_status;
  ELSE
   CLOSE csr_pds_status;
  END IF;
--
  RETURN l_record;
END Get_Current_PDS_Record;
-------------------------------------------------------------------------------
FUNCTION Get_Current_Open_PDS_id
  ( p_person_id 	IN per_people_f.person_id%TYPE
  )
RETURN NUMBER
IS
  l_record	per_periods_of_service%ROWTYPE;
BEGIN
  l_record := Get_Current_PDS_Record
  ( p_person_id => p_person_id);
--
  IF l_record.last_standard_process_date IS NULL THEN
    RETURN l_record.period_of_service_id;
  ELSE
    RETURN NULL;
  END IF;
END Get_Current_Open_PDS_id;
-------------------------------------------------------------------------------
FUNCTION Is_Max_PDS_Not_Closed
  ( p_person_id 	IN per_people_f.person_id%TYPE
  )
RETURN BOOLEAN
IS
--
  l_boolean	BOOLEAN := FALSE;
  l_record	per_periods_of_service%ROWTYPE;
BEGIN
  l_record := Get_Current_PDS_Record
  ( p_person_id => p_person_id);

    IF l_record.final_process_date IS NULL THEN
      l_boolean := TRUE;
    ELSE
      NULL;
    END IF;
--
  RETURN l_boolean;
END Is_Max_PDS_Not_Closed;
-------------------------------------------------------------------------------
FUNCTION Get_Person_Age_Min_Max_Dates
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_session_date	IN DATE
  , p_dob		IN DATE
  , p_business_group_id	IN NUMBER
  )
RETURN Age_dates
IS
  l_dob 		DATE;
  l_business_group_id 	NUMBER;
  l_record 		Age_dates;
  l_min			NUMBER;
  l_max			NUMBER;
  l_proc		VARCHAR2 (100) :=
			'per_periods_of_service_pkg_v2.Get_Person_Age_Min_Max_Dates';
--
  CURSOR csr_dob
    ( p_person_id per_all_people_f.person_id%TYPE
    , p_session_date DATE)
  IS
    SELECT date_of_birth, business_group_id
    FROM per_people_f ppf
    WHERE ppf.person_id = p_person_id
    AND p_session_date between effective_start_date and effective_end_date;
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
--
  IF p_dob IS NULL THEN
-- get data
    hr_utility.set_location(l_proc, 20);
    OPEN csr_dob
      ( p_person_id => p_person_id
      , p_session_date => p_session_date);
    FETCH csr_dob INTO l_dob, l_business_group_id;
    CLOSE csr_dob;
  ELSE
    hr_utility.set_location(l_proc, 30);
--  use parameters; dob may be supplied even if person_id is null
    l_dob := p_dob;
    l_business_group_id := p_business_group_id;
  END IF;
--
  hr_utility.set_location(l_proc, 40);
  hr_utility.set_location('   using dob ' || to_char(l_dob, 'DD-MON-RRRR'), 41);
  hr_utility.set_location('   using bgid ' || to_char(l_business_group_id), 42);
--
  per_people3_pkg.get_legislative_ages
    ( p_business_group_id => l_business_group_id
    , p_minimum_age => l_min
    , p_maximum_age => l_max);
--
  -- 887747: This processing is now not used for an error on the hire date
  -- but as a warning on commit_record processing
  -- l_record.min_date := nvl(add_months(l_dob, l_min * 12), l_start_of_time);
  -- l_record.max_date := nvl(add_months(l_dob, l_max * 12), l_end_of_time);
  l_record.min_date := l_start_of_time;
  l_record.max_date := l_end_of_time;
  RETURN l_record;
END Get_Person_Age_Min_Max_Dates;
-------------------------------------------------------------------------------
FUNCTION Get_atd
  ( p_person_id 		IN per_all_people_f.person_id%type
  , p_final_process_date 	IN DATE
  )
RETURN date
IS
  l_date 	DATE := null;
  l_proc	VARCHAR2 (100) := 'per_periods_of_service_pkg_v2.Get_atd';
--
  CURSOR csr_atd
    ( p_person_id per_all_people_f.person_id%type
    , p_final_process_date date)
  IS
    SELECT actual_termination_date
    FROM per_periods_of_service
    WHERE person_id = p_person_id
    AND final_process_date = p_final_process_date;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);

  OPEN csr_atd
    ( p_person_id => p_person_id
    , p_final_process_date => p_final_process_date);
  FETCH csr_atd INTO l_date;
  CLOSE csr_atd;
--
  RETURN l_date;
END Get_atd;
-------------------------------------------------------------------------------
FUNCTION Get_Current_PDS_Start_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_type 		IN VARCHAR2 DEFAULT NULL
  )
RETURN DATE
IS
  l_date 	DATE;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Current_PDS_Start_Date';
--
  CURSOR csr_pds_start_date
    (p_person_id per_all_people_f.person_id%TYPE)
  IS
    SELECT max(date_start)
    FROM per_periods_of_service
    WHERE person_id = p_person_id
    AND final_process_date is null;

  CURSOR csr_pds_start_date_nn
    (p_person_id per_all_people_f.person_id%TYPE)
  IS
    SELECT max(date_start)
    FROM per_periods_of_service
    WHERE person_id = p_person_id;

BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);

  IF p_type IS NULL THEN
    hr_utility.set_location(l_proc, 20);
-- look for a current employment only

    OPEN csr_pds_start_date
      ( p_person_id => p_person_id);
    FETCH csr_pds_start_date INTO l_date;
    CLOSE csr_pds_start_date;
  ELSE
    hr_utility.set_location(l_proc, 30);
-- look for the most recent hire date current or not
    OPEN csr_pds_start_date_nn
      ( p_person_id => p_person_id);
    FETCH csr_pds_start_date_nn INTO l_date;
    CLOSE csr_pds_start_date_nn;
  END IF;
--
  RETURN l_date;
END Get_Current_PDS_Start_Date;
-------------------------------------------------------------------------------
FUNCTION Get_Max_Asg_Hire_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_check_date 	IN date
  )
RETURN date
IS
  l_date 	DATE := NULL;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Max_Asg_Hire_Date';
--
  CURSOR Get_Max_Asg_Hire_Date
    ( p_person_id per_all_people_f.person_id%TYPE
    , p_check_date date)
  IS
    SELECT Min(effective_start_date) + 1
    FROM per_all_assignments_f
    WHERE person_id = p_person_id
    AND effective_start_date > p_check_date;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN Get_Max_Asg_Hire_Date
    ( p_person_id => p_person_id
    , p_check_date =>p_check_date);
  FETCH Get_Max_Asg_Hire_Date INTO l_date;
  CLOSE Get_Max_Asg_Hire_Date;
--
  RETURN l_date;
END Get_Max_Asg_Hire_Date;
-------------------------------------------------------------------------------
FUNCTION Get_Min_Asg_Hire_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_check_date 	IN date
  )
RETURN date
IS
  l_date 	DATE := NULL;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Min_Asg_Hire_Date';
--
  CURSOR Get_Min_Asg_Hire_Date
    ( p_person_id per_all_people_f.person_id%TYPE
    , p_check_date date)
  IS
    SELECT Max(effective_start_date) + 1
    FROM per_all_assignments_f
    WHERE person_id = p_person_id
    AND effective_start_date < p_check_date;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN Get_Min_Asg_Hire_Date
    ( p_person_id => p_person_id
    , p_check_date => p_check_date);
  FETCH Get_Min_Asg_Hire_Date INTO l_date;
  CLOSE Get_Min_Asg_Hire_Date;
--
  RETURN l_date;
END Get_Min_Asg_Hire_Date;
-------------------------------------------------------------------------------
FUNCTION Get_Min_Person_End_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_date_from		IN DATE
  , p_date_to		IN DATE
  )
RETURN DATE
IS
  l_date 	DATE;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Min_Person_End_Date';
--
  CURSOR csr_get_end_date
    ( p_person_id 	per_all_people_f.person_id%TYPE
    , p_date_from	DATE
    , p_date_to		DATE)
  IS
    SELECT min(effective_end_date)
    FROM per_all_people_f
    WHERE person_id = p_person_id
    AND effective_end_date between p_date_from + 1 and p_date_to -1;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN csr_get_end_date
    ( p_person_id 	=> p_person_id
    , p_date_from	=> p_date_from
    , p_date_to		=> p_date_to);
  FETCH csr_get_end_date INTO l_date;
  CLOSE csr_get_end_date;
--
  RETURN l_date;
END Get_Min_Person_End_Date;
-------------------------------------------------------------------------------
FUNCTION Get_Max_Person_Start_Date
  ( p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_date_from		IN DATE
  , p_date_to		IN DATE
  )
RETURN DATE
IS
  l_date 	DATE;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Max_Person_Start_Date';
--
  CURSOR csr_get_start_date
    ( p_person_id 	per_all_people_f.person_id%TYPE
    , p_date_from	DATE
    , p_date_to		DATE)
  IS
    SELECT max(effective_start_date) +1
    FROM per_all_people_f
    WHERE person_id = p_person_id
    AND effective_start_date between p_date_from + 1 and p_date_to -1;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN csr_get_start_date
    ( p_person_id 	=> p_person_id
    , p_date_from	=> p_date_from
    , p_date_to		=> p_date_to);
  FETCH csr_get_start_date INTO l_date;
  CLOSE csr_get_start_date;
--
  RETURN l_date;
END Get_Max_Person_Start_Date;
-------------------------------------------------------------------------------
FUNCTION Is_Back_to_Back_Allowed
  ( p_pds_hd_bb 	IN DATE
  , p_person_id 	IN per_all_people_f.person_id%TYPE
  , p_current_hire_date IN DATE)
RETURN BOOLEAN
IS
  l_boolean 			BOOLEAN;
  l_effective_start_date 	DATE;
  l_proc			VARCHAR2 (100) :=
				'per_periods_of_service_pkg_v2.
				Is_Back_to_Back_Allowed';
--
  CURSOR csr_person_type_change
    ( p_person_id  per_all_people_f.person_id%TYPE
    , p_current_hire_date DATE)
  IS
    SELECT effective_start_date
    FROM per_people_f ppf, per_person_types ppt
    WHERE ppf.person_id = p_person_id
    AND ppf.person_type_id = ppt.person_type_id
    AND ppf.effective_start_date > p_current_hire_date;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  IF p_pds_hd_bb = hr_general.start_of_time THEN
    hr_utility.set_location(l_proc, 20);
    l_boolean := FALSE;
  ELSE
    hr_utility.set_location(l_proc, 30);
    OPEN csr_person_type_change
      ( p_person_id => p_person_id
      , p_current_hire_date => p_current_hire_date);
    FETCH csr_person_type_change INTO l_effective_start_date;
--
    IF csr_person_type_change%FOUND THEN
      CLOSE csr_person_type_change;
      l_boolean := TRUE;
    ELSE
      CLOSE csr_person_type_change;
      l_boolean := FALSE;
    END IF;
  END IF;
--
  RETURN nvl(l_boolean, false);
END Is_Back_to_Back_Allowed;
-------------------------------------------------------------------------------
FUNCTION Set_Date_Using_FPD
  ( p_person_id IN per_all_people_f.person_id%TYPE
  , p_final_process_date date
  )
RETURN DATE
IS
  l_date 			DATE;
  l_actual_termination_date 	DATE;
  l_count			NUMBER;
  l_person_type_id		NUMBER;
  l_pt_changes_exist		BOOLEAN := FALSE;
  l_proc			VARCHAR2 (100) :=
				'per_periods_of_service_pkg_v2.Set_Date_Using_FPD';
--
-- + 2
-- there must be at least an ex_empp_ record but no other changes
--
  CURSOR csr_per_row_count
  IS
    SELECT COUNT (*), person_type_id
    FROM per_people_f
    WHERE person_id = p_person_id
    AND effective_start_date > p_final_process_date
    GROUP BY person_type_id;
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  IF p_final_process_date IS NULL THEN
    hr_utility.set_location(l_proc, 20);
    l_date := NULL;
    g_b2b_allowed := false;
  ELSE
    OPEN csr_per_row_count;
    LOOP
      FETCH csr_per_row_count INTO l_count, l_person_type_id;
      EXIT WHEN csr_per_row_count%NOTFOUND;
      hr_utility.set_location(l_proc, 30);
      IF csr_per_row_count%ROWCOUNT > 1 THEN
        hr_utility.set_location('     person type changes exist ', 31);
        l_pt_changes_exist := TRUE;
        EXIT;
      ELSE
        NULL;
      END IF;
    END LOOP;
--
      CLOSE csr_per_row_count;
--
-- if rowcount = 1 then = emp or exemp record and b2b allowed with hd = fpd + 1
-- but if > 1 then person type changes exist so cannot create a b2b
-- employment
--
    hr_utility.set_location(l_proc, 40);
    l_actual_termination_date :=
      get_atd
        ( p_person_id => p_person_id
        , p_final_process_date => p_final_process_date
        );
--
    hr_utility.set_location('     l_atd ' || to_char(l_actual_termination_date, 'DD-MON-RRRR'), 41);
    hr_utility.set_location('     p_fpd ' || to_char(p_final_process_date, 'DD-MON-RRRR'), 42);
--
-- flemonni changed
-- always = to fpd + 1
--
      l_date := p_final_process_date + 1;
    IF l_actual_termination_date = p_final_process_date
    AND NOT l_pt_changes_exist THEN
--      l_date := p_final_process_date + 1;
      g_b2b_allowed := TRUE;
    ELSE
--      l_date := p_final_process_date + 2;
      g_b2b_allowed := FALSE;
    END IF;
  END IF;
--
  g_person_type_changes_exist := l_pt_changes_exist;

--
  RETURN l_date;
END Set_Date_Using_FPD;
-------------------------------------------------------------------------------
FUNCTION Get_Min_Asg_Accepted
  ( p_person_id IN per_all_people_f.person_id%TYPE
  )
RETURN DATE
IS
  l_date 	DATE;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.Get_Min_Asg_Accepted';
--
  CURSOR csr_Get_Accepted_Asg
    (p_person_id per_all_people_f.person_id%TYPE)
  IS
    SELECT min(effective_start_date) + 1
    FROM per_all_assignments_f paf
    ,    per_assignment_status_types past
    WHERE person_id = p_person_id
    AND   paf.assignment_status_type_id = past.assignment_status_type_id
    AND   past.per_system_status = 'ACCEPTED';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  OPEN csr_Get_Accepted_Asg
    ( p_person_id => p_person_id);
  FETCH csr_Get_Accepted_Asg INTO l_date;
  CLOSE csr_Get_Accepted_Asg;
--
  RETURN l_date;
END Get_Min_Asg_Accepted;
-------------------------------------------------------------------------------
PROCEDURE Get_Valid_Hire_Dates
  ( p_person_id			IN per_all_people_f.person_id%TYPE
  , p_session_date		IN DATE
  , p_dob			IN DATE
  , p_business_group_id		IN NUMBER
  , p_min_date 			OUT NOCOPY DATE
  , p_max_date			OUT NOCOPY DATE
  , p_b2b_allowed		OUT NOCOPY BOOLEAN
  , p_pds_not_terminated	OUT NOCOPY BOOLEAN
  )
IS
  l_hd_min		DATE;
  l_hd_max		DATE;
  l_age_dates		Age_dates;
  l_pds_hd		DATE;
  l_fpd			DATE;
  l_atd			DATE;
  l_mod_fpd		DATE;
  l_most_recent_pds	DATE;
  l_min_asg_date	DATE;
  l_max_asg_date	DATE;
  l_min_asg_accept	DATE;
  l_max			DATE;
  l_min			DATE;
  l_min_years		NUMBER;
  l_max_years		NUMBER;
  l_fail_step		NUMBER;
  l_proc		VARCHAR2 (100) :=
			'per_periods_of_service_pkg_v2.Get_valid_hire_dates';
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
--
-- nb: hd = hire date
--     fpd = final process date (last payroll run)
--     atd = actual termination date (last physical day of contract)
--     pds = period of service
--     l_fail_step  to provide the step value for all procedure fail
--     if proc fails to retrieve data
--
-- GET AGE DATES: even if person_id is null, can use business_group_id
-- to retrieve age dates;  if age dates are null then set automatically to
-- start / end of time
--
-- person age dates
--
  l_fail_step := 10;

  l_age_dates := Get_Person_Age_Min_Max_Dates
    ( p_person_id 	=> p_person_id
    , p_session_date	=> p_session_date
    , p_dob		=> p_dob
    , p_business_group_id	=> p_business_group_id
    );

  hr_utility.set_location('  min age date ' || to_char(l_age_dates.min_date, 'DD-MON-RRRR') , 11);
  hr_utility.set_location('  max age date ' || to_char(l_age_dates.max_date, 'DD-MON-RRRR') , 12);

  IF p_person_id IS NULL THEN
    hr_utility.set_location(l_proc, 20);
--
-- NO PERSON RECORD EXISTS
--
    l_hd_min := l_age_dates.min_date; -- l_start_of_time;
    l_hd_max := l_age_dates.max_date; -- l_end_of_time;
  ELSE
    hr_utility.set_location(l_proc, 30);
--
-- period of service dates
--
    hr_utility.set_location(l_proc, 50);
    l_fail_step := 20;
--
    l_pds_hd := Get_Current_PDS_Start_Date (p_person_id => p_person_id);
    hr_utility.set_location('  pds hd ' || to_char(l_pds_hd, 'DD-MON-RRRR') , 51);
--
-- final process date
--
    hr_utility.set_location(l_proc, 60);
    l_fail_step := 30;
--
    l_fpd := Get_Max_Last_process_Date (p_person_id);
    l_atd := get_atd
	       ( p_person_id => p_person_id
	       , p_final_process_date => l_fpd);
    hr_utility.set_location('  fpd ' || to_char(l_fpd, 'DD-MON-RRRR') , 61);
    hr_utility.set_location('  atd ' || to_char(l_atd, 'DD-MON-RRRR') , 62);
--
-- GET ASSIGNMENT DATA
--
    hr_utility.set_location(l_proc, 70);
    l_fail_step := 40;
--
-- modified fpd : i.e. whether date of new emp record is date +1 or date +2
--
    l_mod_fpd := Set_Date_Using_FPD
 	         ( p_person_id => p_person_id
		 , p_final_process_date => l_fpd);
--
    hr_utility.set_location('  mod fpd ' || to_char(l_mod_fpd, 'DD-MON-RRRR') , 71);
--
-- asg : if mod_fpd null, pds hd [open emp] null and current hd null then
-- does not matter that asg check retrieves null
--
    l_most_recent_pds := Get_Current_PDS_Start_Date
			 ( p_person_id => p_person_id
			 , p_type => 'recent');
    hr_utility.set_location('  most recent pds ' || to_char(l_most_recent_pds, 'DD-MON-RRRR') , 72);

    l_min_asg_date := nvl(Get_Min_Asg_Hire_Date
 	      ( p_person_id => p_person_id
	      , p_check_date => GREATEST
                                  (nvl
                                     (l_mod_fpd
				     , l_most_recent_pds
				     )
                                  , l_most_recent_pds
				  )
	      ), l_start_of_time);
--
-- if no future dated changes exist (set in set_date_using_fpd
-- then compare the following
-- otherwise may have e.g. future application accepted (empapl)
-- but hire date must be within boundaries of two person type changes
-- i.e. exemp -> emp -> empapl : valid hire date range = exemp + 1 to
-- empapl - 1 (presuming no attribute changes in between)
--
    IF NOT g_person_type_changes_exist THEN
      l_min_asg_date :=
	GREATEST
 	  ( l_min_asg_date
	  , NVL(Get_Min_Asg_Accepted (p_person_id => p_person_id), l_min_asg_date)
          );
    ELSE
      NULL;
    END IF;

    hr_utility.set_location('  gmaa ' || to_char(Get_Min_Asg_Accepted (p_person_id => p_person_id), 'DD-MON-RRRR') , 721);
--
    l_max_asg_date := nvl(Get_Max_Asg_Hire_Date
 	      ( p_person_id => p_person_id
	      , p_check_date => GREATEST
                                  (nvl
                                     (l_mod_fpd, l_most_recent_pds)
				  , l_most_recent_pds)), l_end_of_time);
    hr_utility.set_location('  min asg date ' || to_char(l_min_asg_date, 'DD-MON-RRRR') , 73);
    hr_utility.set_location('  max asg date ' || to_char(l_max_asg_date, 'DD-MON-RRRR') , 74);
--
    IF l_pds_hd IS NULL AND l_fpd IS NULL THEN
--
      hr_utility.set_location(l_proc, 80);
      l_fail_step := 50;
--
--
-- PERSON RECORD EXISTS BUT NO PERIOD OF SERVICE RECORD - APPLICANT
--
      l_min_asg_accept := Get_Min_Asg_Accepted (p_person_id => p_person_id);
      hr_utility.set_location('  min asg accepted date ' || to_char(l_min_asg_accept, 'DD-MON-RRRR') , 81);
--
      IF l_min_asg_accept IS NULL THEN
--
      hr_utility.set_location(l_proc, 90);
--
--
-- NO HIRE DATE ALLOWED
--
        l_fail_step := 60;
        l_hd_min := NULL;
        l_hd_max := NULL;
--
        hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 91);
        hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 92);
      ELSE
--
        hr_utility.set_location(l_proc, 100);
--
-- HIRE DATE ALLOWED ON GMAA (i.e. Accepted + 1);
--
        l_fail_step := 70;
      l_hd_min := l_min_asg_accept;
--
        l_hd_max := LEAST
		      ( l_end_of_time
		      , l_age_dates.max_date);
        hr_utility.set_location('  l_hd_max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 101);

--
-- but must be lower than maximum assignment change
--
        l_hd_max := LEAST
		      ( l_hd_max
		      , l_max_asg_date);
        hr_utility.set_location('  l_hd_max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 102);
--
-- but must be higher than any person attribute change
--
        l_min := nvl(Get_Max_Person_Start_Date
		   ( p_person_id => p_person_id
		   , p_date_from => l_min_asg_accept
                   , p_date_to => l_end_of_time), l_min_asg_accept);

        hr_utility.set_location('  l_min ' || to_char(l_min, 'DD-MON-RRRR') , 103);
--
        l_hd_min := GREATEST
		      ( l_hd_min
		      , l_min
		      );
--
        hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 104);
        hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 105);
      END IF;
    ELSE
--
      hr_utility.set_location(l_proc, 110);
--
-- AT LEAST ONE EMP RECORD AND THEREFORE PDS START DATE EXISTS
--
      l_fail_step := 80;
      l_hd_min := GREATEST
		( l_start_of_time
		, l_age_dates.min_date
		, nvl(l_mod_fpd, l_start_of_time));
--
        hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 111);

      IF l_fpd IS NULL THEN
--
    hr_utility.set_location(l_proc, 120);
--
-- FIRST PDS
--
-- chg l_pds_hd to most_recent_pds
--
        l_fail_step := 90;
        l_max := nvl(Get_Min_Person_End_Date
                   ( p_person_id => p_person_id
		   , p_date_from => nvl(l_most_recent_pds, l_hd_min)
		   , p_date_to => l_end_of_time), l_end_of_time);
--
        hr_utility.set_location('  l_max ' || to_char(l_max, 'DD-MON-RRRR') , 121);
--
        l_hd_max := LEAST
		      ( l_end_of_time
		      , l_age_dates.max_date
		      , l_max);

        l_hd_max := LEAST
		      ( l_hd_max
		      , l_max_asg_date);
        hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 122);
/*
--
-- CHECK FUTURE ATTRIBUTE CHANGES
--
        l_min := nvl(Get_Max_Person_Start_Date
		   ( p_person_id => p_person_id
		   , p_date_from => nvl(l_most_recent_pds, l_start_of_time)
                   , p_date_to => l_end_of_time), l_start_of_time);
--
        l_hd_min := l_min;
*/
--
        hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 123);
--
      ELSE
--
        hr_utility.set_location(l_proc, 130);
--
-- NOT IN FIRST PDS
--
        l_fail_step := 100;
        l_min := Get_Max_Person_Start_Date
		   ( p_person_id => p_person_id
		   , p_date_from => l_atd + 1
                   , p_date_to => nvl(l_pds_hd, l_end_of_time));
--
        hr_utility.set_location('  l_min ' || to_char(l_min, 'DD-MON-RRRR') , 131);
--
        IF l_min IS NULL THEN
--
          hr_utility.set_location(l_proc, 140);
--
-- NO INTERFERING ATTRIBUTE CHANGES IN THE PERSON RECORD
--
          l_fail_step := 110;
          l_hd_max := LEAST
			( l_end_of_time
			, l_age_dates.max_date);
--
          hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 141);
        ELSE
--
    hr_utility.set_location(l_proc, 150);
--
-- ATTRIBUTES EXIST
--
          l_fail_step := 120;
          l_hd_min := l_min;
          g_b2b_allowed := FALSE;
--
          IF l_pds_hd IS NULL THEN
--
             hr_utility.set_location(l_proc, 160);
--
            l_hd_max := LEAST
			  ( l_end_of_time
			  , l_age_dates.max_date);
--
            hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 161);
          ELSE
--
            hr_utility.set_location(l_proc, 170);
--
            l_max := nvl(Get_Min_Person_End_Date
		       ( p_person_id => p_person_id
		       , p_date_from => l_pds_hd
		       , p_date_to => l_end_of_time), l_end_of_time);
--
            hr_utility.set_location('  l_max ' || to_char(l_max, 'DD-MON-RRRR') , 171);
--
            l_hd_max := LEAST
			  ( l_end_of_time
			  , l_age_dates.max_date
			  , l_max);
            hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 172);
          END IF;
        END IF;
      END IF;
--
      hr_utility.set_location(l_proc, 180);
--
      hr_utility.set_location('  l_hd_max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 181);
      hr_utility.set_location('  l_max_asg_date ' || to_char(l_max_asg_date, 'DD-MON-RRRR') , 182);

      l_hd_max := LEAST
 	            ( l_hd_max
		    , l_max_asg_date);
      l_hd_min := GREATEST
		    ( l_hd_min
		    , l_min_asg_date);
--
      hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 183);
      hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 184);
--
      IF l_hd_min >= l_hd_max THEN
--
-- there are no interfering records above the l_hd_max;
-- Therefore, use eot/age date as the max
--
        l_hd_max :=LEAST
		    ( l_end_of_time
		    , l_age_dates.max_date);
      ELSE
        NULL;
      END IF;
--
      hr_utility.set_location('  hd min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 185);
      hr_utility.set_location('  hd max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 186);

--
-- but may miss e.g. ex_emp changes; need to ensure that pers / asg changes
-- also compared to pds changes
--
/*
        l_hd_min := GREATEST
		      ( l_hd_min
		      , l_mod_fpd);
*/
    END IF;
  END IF;
--
-- assign out parameters
--
  l_fail_step := 130;
  p_min_date := l_hd_min;
  p_max_date := l_hd_max;
--
  IF g_b2b_allowed THEN
--
    hr_utility.set_location(l_proc, 190);
--
    p_b2b_allowed := TRUE;
  ELSE
--
    hr_utility.set_location(l_proc, 200);
--
    p_b2b_allowed := FALSE;
  END IF;
--
    p_pds_not_terminated := Is_Max_PDS_Not_Closed
			      ( p_person_id => p_person_id);

  hr_utility.set_location('  OUT min ' || to_char(l_hd_min, 'DD-MON-RRRR') , 201);
  hr_utility.set_location('  OUT max ' || to_char(l_hd_max, 'DD-MON-RRRR') , 202);
  hr_utility.set_location('Leaving ' || l_proc, 220);
--
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE','Per_period_of_service_pkg.Get_valid_Hire_dates',false);
    fnd_message.set_token('STEP', l_fail_step);
    RAISE;
END Get_Valid_Hire_Dates;
-------------------------------------------------------------------------------
FUNCTION IsBackToBackContract
  ( p_person_id			IN per_people_f.person_id%TYPE
  , p_hire_date_of_current_pds	IN DATE
  )
RETURN BOOLEAN
IS
--
  l_fpd		DATE;
  l_atd		DATE;
  l_boolean 	BOOLEAN;
  l_proc	VARCHAR2 (100) :=
		'per_periods_of_service_pkg_v2.IsBackToBackContract';
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc, 10);
  l_fpd := Get_Max_Last_process_Date (p_person_id);
  l_atd := get_atd
             ( p_person_id => p_person_id
             , p_final_process_date => l_fpd);
--
-- 115.3 (START)
--
  --IF l_fpd = l_atd
  --AND p_hire_date_of_current_pds = l_fpd + 1
  IF l_fpd IS NOT NULL
  AND p_hire_date_of_current_pds = l_atd + 1
--
-- 115.3 (END)
--
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END IsBackToBackContract;
--
END PER_PERIODS_OF_SERVICE_PKG_V2;

/
