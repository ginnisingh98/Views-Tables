--------------------------------------------------------
--  DDL for Package Body PAY_DK_HOLIDAY_PAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_HOLIDAY_PAY_PKG" AS
/* $Header: pydkholp.pkb 120.9.12010000.4 2010/04/02 11:22:00 abraghun ship $ */
--
--

FUNCTION get_allowance_perc(p_payroll_id NUMBER
			   ,p_date_earned DATE ) RETURN NUMBER IS



l_value  PER_TIME_PERIODS.PRD_INFORMATION1%TYPE;
CURSOR get_perc_from_ddf(p_payroll_id NUMBER , p_date_earned DATE) IS
  SELECT nvl(PRD_INFORMATION1 ,0)
  FROM PER_TIME_PERIODS ptp
  WHERE PAYROLL_ID = p_payroll_id
  AND p_date_earned BETWEEN ptp.START_DATE AND ptp.END_DATE;


BEGIN
  OPEN get_perc_from_ddf(p_payroll_id, p_date_earned);
  FETCH get_perc_from_ddf INTO l_value;
  CLOSE get_perc_from_ddf;
  /* Change the to_number to fnd_number.canonical_to_number */
  RETURN fnd_number.canonical_to_number(l_value);

END  get_allowance_perc;


FUNCTION get_prev_bal(p_assignment_id NUMBER
		    , p_balance_name VARCHAR2
		    , p_balance_dim VARCHAR2
		    , p_virtual_date DATE) RETURN NUMBER IS

l_context1 PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_value    NUMBER;


CURSOR get_dbal_id(p_balance_name VARCHAR2 , p_balance_dim VARCHAR2) IS
  SELECT pdb.defined_balance_id
  FROM   pay_defined_balances  pdb
	,pay_balance_types  pbt
	,pay_balance_dimensions  pbd
  WHERE  pbt.legislation_code='DK'
  AND    pbt.balance_name = p_balance_name
  AND    pbd.legislation_code = 'DK'
  AND    pbd.database_item_suffix = p_balance_dim
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;


BEGIN
  OPEN get_dbal_id(p_balance_name, p_balance_dim);
  FETCH get_dbal_id INTO l_context1;
  CLOSE get_dbal_id;

  l_value := pay_balance_pkg.get_value(l_context1,p_assignment_id,p_virtual_date);

  RETURN l_value;

  END  get_prev_bal;


/* Bug fix 4950983 added parameter p_work_pattern */
/* Bug#8293282 fix - Added out parameter p_hol_all_reduction */
FUNCTION get_le_holiday_details

	(p_org_id IN NUMBER,
	 p_sal_accrual_rate    OUT NOCOPY NUMBER,
	 p_hourly_accrual_rate OUT NOCOPY NUMBER,
	 p_use_holiday_card    OUT NOCOPY VARCHAR2,
	 p_work_pattern        OUT NOCOPY VARCHAR2,
         p_hol_all_reduction   OUT NOCOPY VARCHAR2) RETURN NUMBER is

	/* Bug fix 4950983 added org_information1 in select clause */
       /* Change the to_number to fnd_number.canonical_to_number */
	 CURSOR csr_get_hol_rates(p_org_id NUMBER) is
	 SELECT fnd_number.canonical_to_number(org_information3), fnd_number.canonical_to_number(org_information4), org_information5, org_information1, org_information8
	 FROM hr_organization_information
	 WHERE organization_id = p_org_id
	 and org_information_context = 'DK_HOLIDAY_ENTITLEMENT_INFO';

	 BEGIN

	/* Bug fix 4950983 added p_work_pattern in fetch statement */
	 OPEN csr_get_hol_rates(p_org_id);
	 FETCH csr_get_hol_rates INTO p_sal_accrual_rate,p_hourly_accrual_rate,p_use_holiday_card,p_work_pattern,p_hol_all_reduction;
	 CLOSE csr_get_hol_rates;

	 RETURN 1;


END get_le_holiday_details;


 FUNCTION get_le_employment_details
  (p_org_id                     IN      NUMBER
  ,p_le_work_hours              OUT NOCOPY NUMBER
  ,p_freq                       OUT NOCOPY VARCHAR2
  )RETURN NUMBER IS
  --
  CURSOR get_details(p_org_id VARCHAR2) IS
  SELECT   hoi.org_information3
	 , hoi.org_information4
  FROM     hr_organization_information  hoi
  WHERE    hoi.org_information_context='DK_EMPLOYMENT_DEFAULTS'
  AND      hoi.organization_id =  p_org_id ;

  --
 BEGIN
  --
  OPEN  get_details(p_org_id);
  FETCH get_details INTO p_le_work_hours,p_freq;
  CLOSE get_details;


  RETURN 1;
  --
 END get_le_employment_details;


FUNCTION get_eligible_days(p_assignment_id     IN NUMBER
			  ,p_org_id            IN NUMBER
			  ,p_period_start_date IN DATE
			  ,p_period_end_date   IN DATE
			  ,p_5days             OUT NOCOPY NUMBER
			  ,p_6days             OUT NOCOPY NUMBER) RETURN NUMBER is

/* return 5day days and 6day days as out parameter, in the formula calculate accrual*/
l_assignment_id NUMBER;
l_org_id NUMBER;
l_elig_start_date DATE;
l_elig_end_date DATE;
l_wrkp_start_date DATE;
l_wrkp_end_date DATE;

l_input_value VARCHAR2(80);

l_elig_record l_rec;
l_wrkp_record l_rec;

l_elig_records NUMBER;
l_wrkp_records NUMBER;
l_el_start_date DATE;
l_el_end_date DATE;
l_eligible VARCHAR2(5);

l_wp_start_date DATE;
l_wp_end_date DATE;
l_work_pattern VARCHAR2(5);

l_le_work_pattern VARCHAR2(5);

l_5days NUMBER;
l_6days NUMBER;
l_eligibility_change VARCHAR2(1);

CURSOR csr_get_accrual_elig(p_assignment_id NUMBER,p_period_start_date DATE,p_period_end_date DATE,p_input_value VARCHAR2) IS
   SELECT  distinct eev.effective_start_date,eev.effective_end_date,eev.screen_entry_value
   FROM   per_all_assignments_f      asg
	 ,per_all_people_f           per
	 ,pay_element_links_f        el
	 ,pay_element_types_f        et
	 ,pay_input_values_f         iv
	 ,pay_element_entries_f      ee
	 ,pay_element_entry_values_f eev
   WHERE  asg.assignment_id        = p_assignment_id
     AND  per.person_id            = asg.person_id
     AND  et.element_name          = 'Holiday Accrual'
     AND  et.legislation_code      = 'DK'
     AND  iv.element_type_id       = et.element_type_id
     AND  iv.name                  = p_input_value
     AND  el.business_group_id     = per.business_group_id
     AND  el.element_type_id       = et.element_type_id
     AND  ee.assignment_id         = asg.assignment_id
     AND  ee.element_link_id       = el.element_link_id
     AND  eev.element_entry_id     = ee.element_entry_id
     AND  eev.input_value_id       = iv.input_value_id
     AND  eev.effective_end_date >= p_period_start_date /* knadhan */
     AND  eev.effective_start_date <= p_period_end_date;
     /*
     AND  eev.effective_start_date >= p_period_start_date
     AND  eev.effective_start_date <= p_period_end_date;
     */
CURSOR csr_get_asg_work_pattern(p_assignment_id NUMBER,p_period_start_date DATE,p_period_end_date DATE) IS
	SELECT  effective_start_date, effective_end_date, segment10
	FROM    per_all_assignments_f  paa,
		hr_soft_coding_keyflex kf
	WHERE  assignment_id = p_assignment_id
	AND  paa.SOFT_CODING_KEYFLEX_ID = kf.SOFT_CODING_KEYFLEX_ID
	AND  ((p_period_start_date BETWEEN paa.effective_start_date AND paa.effective_end_date)
	   OR
	   (p_period_end_date BETWEEN paa.effective_start_date AND paa.effective_end_date)
	   OR
	   (p_period_start_date < paa.effective_start_date AND p_period_end_date > paa.effective_end_date));


CURSOR csr_get_le_work_pattern(p_org_id NUMBER) IS
	 SELECT org_information1
	 FROM hr_organization_information
	 WHERE organization_id = p_org_id
	 and org_information_context = 'DK_HOLIDAY_ENTITLEMENT_INFO';

BEGIN

l_elig_start_date := p_period_start_date;
l_elig_end_date := p_period_end_date;
l_assignment_id := p_assignment_id;
l_org_id := p_org_id;

l_le_work_pattern := ' ';
l_eligibility_change := 'Y';

l_5days := 0;
l_6days := 0;

l_input_value := 'Holiday Accrual Eligibility';
OPEN csr_get_accrual_elig(l_assignment_id,l_elig_start_date ,l_elig_end_date,l_input_value);
FETCH csr_get_accrual_elig BULK COLLECT INTO l_elig_record;
CLOSE csr_get_accrual_elig;

IF l_elig_record.count = 0 THEN
	l_wrkp_start_date := l_elig_start_date;
	l_wrkp_end_date := l_elig_end_date;

	OPEN csr_get_asg_work_pattern(l_assignment_id,l_el_start_date ,l_el_end_date);
	FETCH csr_get_asg_work_pattern BULK COLLECT INTO l_wrkp_record;
	CLOSE csr_get_asg_work_pattern;

	l_wrkp_records := l_wrkp_record.count;

	IF l_wrkp_records = 0 THEN
		IF l_le_work_pattern = '6DAY' THEN
			l_6days := (l_wrkp_end_date - l_wrkp_start_date) + 1;
		ELSE
			l_5days := (l_wrkp_end_date - l_wrkp_start_date)+ 1;
		END IF;
		p_5days := l_5days;
		p_6days := l_6days;
		RETURN -1;
	ELSE
		FOR l_wrkp_index IN 1 .. l_wrkp_records LOOP
			l_wp_start_date := l_wrkp_record(l_wrkp_index).date1;
			l_wp_end_date := l_wrkp_record(l_wrkp_index).date2;
			l_work_pattern := l_wrkp_record(l_wrkp_index).value;

			IF (l_wp_start_date < l_wrkp_start_date) THEN
			       l_wp_start_date := l_wrkp_start_date;
			END IF;

			IF (l_wp_end_date > l_wrkp_end_date) THEN
			       l_wp_end_date := l_wrkp_end_date;
			END IF;

			IF l_work_pattern = '5DAY' THEN
				l_5days := l_5days + (l_wp_end_date - l_wp_start_date) + 1;
			ELSIF l_work_pattern = '6DAY' THEN
				l_6days := l_6days + (l_wp_end_date - l_wp_start_date) + 1;
			ELSIF l_le_work_pattern = '6DAY' THEN
				l_6days := l_6days + (l_wp_end_date - l_wp_start_date) + 1;
			ELSE
				l_5days := l_5days + (l_wp_end_date - l_wp_start_date) + 1;
			END IF;

		END LOOP;
	END IF;

	p_5days := l_5days;
	p_6days := l_6days;
	RETURN 1;

ELSE
	OPEN csr_get_le_work_pattern(l_org_id);
	FETCH csr_get_le_work_pattern INTO l_le_work_pattern;
	CLOSE csr_get_le_work_pattern;

	l_elig_records := l_elig_record.count;

	FOR l_elig_index IN 1 .. l_elig_records LOOP
		l_el_start_date := l_elig_record(l_elig_index).date1;
		l_el_end_date := l_elig_record(l_elig_index).date2;
		l_eligible := l_elig_record(l_elig_index).value;

		IF l_eligible = 'N' THEN
			null;
		ELSE

		    IF (l_el_start_date < l_elig_start_date) THEN
			l_el_start_date := l_elig_start_date;
		    END IF;

		    IF (l_el_end_date > l_elig_end_date) THEN
		       l_el_end_date := l_elig_end_date;
		    END IF;

		    /* work pattern record*/
		    l_wrkp_start_date := l_el_start_date;
		    l_wrkp_end_date := l_el_end_date;

		    OPEN csr_get_asg_work_pattern(l_assignment_id,l_el_start_date ,l_el_end_date);
		    FETCH csr_get_asg_work_pattern BULK COLLECT INTO l_wrkp_record;
		    CLOSE csr_get_asg_work_pattern;

		    l_wrkp_records := l_wrkp_record.count;


		     FOR l_wrkp_index IN 1 .. l_wrkp_records LOOP
			    l_wp_start_date := l_wrkp_record(l_wrkp_index).date1;
			    l_wp_end_date := l_wrkp_record(l_wrkp_index).date2;
			    l_work_pattern := l_wrkp_record(l_wrkp_index).value;

			    IF (l_wp_start_date < l_wrkp_start_date) THEN
			       l_wp_start_date := l_wrkp_start_date;
			    END IF;

			    IF (l_wp_end_date > l_wrkp_end_date) THEN
			       l_wp_end_date := l_wrkp_end_date;
			    END IF;

			    IF l_work_pattern = '5DAY' THEN
				l_5days := l_5days + (l_wp_end_date - l_wp_start_date) + 1;
			    ELSIF l_work_pattern = '6DAY' THEN
				l_6days := l_6days + (l_wp_end_date - l_wp_start_date) + 1;
			    ELSIF l_le_work_pattern = '6DAY' THEN
				l_6days := l_6days + (l_wp_end_date - l_wp_start_date) + 1;
			    ELSE
				l_5days := l_5days + (l_wp_end_date - l_wp_start_date) + 1;
			    END IF;

			END LOOP;
	    END IF;

	END LOOP;
	p_5days := l_5days;
	p_6days := l_6days;
	RETURN 1;
END IF;

END get_eligible_days;

/* Bug Fix 4947637, Added function get_weekdays */
FUNCTION get_weekdays(p_period_start_date IN DATE
		     ,p_period_end_date   IN DATE
		     ,p_work_pattern      IN VARCHAR) RETURN NUMBER IS

/* Version 115.8 Bug fix 5185910 */
/* Commented to add new logic

l_abs_start_date  date;
l_abs_end_date    date;
l_loop_start_date date;
l_days    number;
l_start_d number;
l_end_d   number;
l_work_pattern varchar2(6);
l_index     number;
l_weekdays  number;
l_curr_date date;
l_d         number;
*/


/* Bug fix 5185910 , added cursor and variable */
/* Version 115.8 Bug fix 5185910 */
/* Commented to add new logic
CURSOR csr_get_territory IS
SELECT value FROM nls_database_parameters
WHERE  parameter = 'NLS_TERRITORY';
l_territory varchar2(80);

begin
l_abs_start_date := p_period_start_date;
l_abs_end_date := p_period_end_date;
l_days := (l_abs_end_date - l_abs_start_date) + 1;
l_days := (l_abs_end_date - l_abs_start_date) + 1;
l_weekdays := 0;
l_curr_date := l_abs_start_date;
l_work_pattern := p_work_pattern;
*/

/* Bug fix 5185910 , added fetch statement */
/* Version 115.8 Bug fix 5185910 */
/* Commented to add new logic
OPEN csr_get_territory;
FETCH csr_get_territory INTO l_territory;
CLOSE csr_get_territory;

IF l_work_pattern = '5DAY' then
FOR l_index IN 1..l_days
loop
    l_curr_date := l_abs_start_date + (l_index - 1);
    l_d := to_number(to_char(l_curr_date,'d'));
    */
    /* Bug fix 5084425 , Danish Weekends to be considered instead of American weekends
    In American territory case Sunday is considered as day 1, where as in Denmark monday is
    to be considered as day 1 of the week */
    /*IF l_d NOT IN (7,1) then*/

    /* Bug fix 5185910 commented following if statement
    IF l_d NOT IN (6,7) then
	l_weekdays := l_weekdays +1;
    END IF;*/

    /* Bug fix 5185910 , added following logic */
    /* Version 115.8 Bug fix 5185910 */
    /* Commented to add new logic

    IF l_territory = 'DENMARK' THEN
	IF l_d NOT IN (6,7) then
	    l_weekdays := l_weekdays +1;
        END IF;
    ELSE
	IF l_d NOT IN (7,1) THEN
	    l_weekdays := l_weekdays +1;
        END IF;
    END IF;


END loop;
END if;
*/

/* Version 115.8 Bug fix 5185910 */
    /* Commented to add new logic
IF l_work_pattern = '6DAY' then
FOR l_index IN 1..l_days
loop
    l_curr_date := l_abs_start_date + (l_index - 1);
    l_d := to_number(to_char(l_curr_date,'d'));*/
    /* Bug fix 5084425 , Danish Weekends to be considered instead of American weekends
    In American territory case Sunday is considered as day 1, where as in Denmark monday is
    to be considered as day 1 of the week */
    /*IF l_d <> 1 then*/
    /* Bug fix 5185910 commented following if statement
    IF l_d <> 7 then
	l_weekdays := l_weekdays +1;
    END IF;*/

    /* Bug fix 5185910 , added following logic */
    /* Version 115.8 Bug fix 5185910 */
    /* Commented to add new logic
    IF l_territory = 'DENMARK' THEN
	IF l_d <> 7 then
	    l_weekdays := l_weekdays +1;
        END IF;
    ELSE
	IF l_d <> 1 THEN
	    l_weekdays := l_weekdays +1;
        END IF;
    END IF;

END  loop;
END if;
*/


/* Version 115.8 Bug fix 5185910 */
/* Following logic is added to determine weekdays */
v_st_date date;
v_en_date date;
v_beg_of_week date;
v_end_of_week date;
l_weekdays number;
v_work_pattern varchar2(20);
begin
	v_st_date :=p_period_start_date;
	v_en_date :=p_period_end_date;
	l_weekdays    := 0;
	v_work_pattern := p_work_pattern;
	if p_period_start_date > p_period_end_date then
		return l_weekdays;
	end if;
	--Determine the Beginning of Week Date for Start Date
	--and End of Week Date for End Date
	v_beg_of_week := v_st_date - (get_day_of_week(v_st_date)-1);
	v_end_of_week  := v_en_date;
	if get_day_of_week(v_en_date) NOT IN('1') then
		v_end_of_week := v_en_date + (7- get_day_of_week(v_en_date)+1);
	end if;
	IF v_work_pattern = '5DAY' THEN
		--Calculate the Total Week Days @ of 5 per week
		l_weekdays := ((v_end_of_week-v_beg_of_week)/7)*5;
		--Adjust the Total Week Days by subtracting
		--No of Days before the Start Date
		if (v_st_date > (v_beg_of_week+1)) then
			l_weekdays := l_weekdays - (v_st_date - (v_beg_of_week+1)) ;
		end if;
		if v_end_of_week <> v_en_date then
			v_end_of_week := v_end_of_week -2;
		else
			if v_st_date = v_en_date then
				l_weekdays := 0;
			end if;
		end if;
		--Adjust the Total Week Days by subtracting
		--No of Days After the End Date
		if (v_end_of_week - v_en_date) >= 0 then
			l_weekdays := l_weekdays - (v_end_of_week - v_en_date) ;
		end if;

	ELSE
		--Calculate the Total Week Days @ of 6 per week
		l_weekdays := ((v_end_of_week-v_beg_of_week)/7)*6;
		--Adjust the Total Week Days by subtracting
		--No of Days before the Start Date
		if (v_st_date > (v_beg_of_week+1)) then
			l_weekdays := l_weekdays - (v_st_date - (v_beg_of_week+1)) ;
		end if;
		if v_end_of_week <> v_en_date then
			v_end_of_week := v_end_of_week -1;
		else
			if v_st_date = v_en_date then
				l_weekdays := 0;
			end if;
		end if;
		--Adjust the Total Week Days by subtracting
		--No of Days After the End Date
		if (v_end_of_week - v_en_date) >= 0 then
			l_weekdays := l_weekdays - (v_end_of_week - v_en_date) ;
		end if;
	END IF;

	return (l_weekdays);


END get_weekdays;

/* Bug fix 5185910 , added function get_day_of_week
This Function returns the day of the week.
Sunday is considered to be the first day of the week*/
FUNCTION  get_day_of_week(p_date DATE) RETURN NUMBER IS
l_reference_date date:=to_date('01/01/1984','DD/MM/YYYY');
v_index number;

BEGIN
v_index := abs(p_date - l_reference_date);
v_index := mod(v_index,7);
v_index := v_index + 1;
RETURN v_index;

END get_day_of_week;

/* Added for Public Holiday Pay */
FUNCTION get_pub_hol_pay_details(p_assignment_id IN NUMBER
                                    ,p_organization_id IN NUMBER
                                    ,p_effective_date IN DATE
                                    ,p_sh_payment_rate OUT NOCOPY NUMBER)

RETURN NUMBER IS

        l_sh_payment_rate NUMBER;
        l_sh_payment_percentage NUMBER;

        CURSOR csr_le_holidaypay(csr_organization_id IN NUMBER) IS
        SELECT hoi.org_information6,
               hoi.org_information7
        FROM hr_organization_information hoi
        WHERE organization_id = csr_organization_id
        AND org_information_context = 'DK_HOLIDAY_ENTITLEMENT_INFO';

        CURSOR csr_asg_holidaypay IS
        SELECT scl.segment19
              ,scl.segment20
        FROM hr_soft_coding_keyflex scl,
             per_all_assignments_f paaf
        WHERE scl.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id
        AND paaf.assignment_id = p_assignment_id
        AND p_effective_date between paaf.effective_start_date and effective_end_date;

BEGIN

                FOR csr_asg_val IN csr_asg_holidaypay
                LOOP
                         l_sh_payment_rate := csr_asg_val.segment19;
                         l_sh_payment_percentage := csr_asg_val.segment20;
                END LOOP;

             IF l_sh_payment_rate IS NULL OR l_sh_payment_percentage IS NULL THEN

                FOR csr_le_val IN csr_le_holidaypay(p_organization_id)
                LOOP
                 IF l_sh_payment_rate IS NULL THEN
                        l_sh_payment_rate := csr_le_val.org_information6;
                 END IF;
                 IF l_sh_payment_percentage IS NULL THEN
                        l_sh_payment_percentage := csr_le_val.org_information7;
                 END IF;

                END LOOP;
             END IF;

	      p_sh_payment_rate := l_sh_payment_rate;

        RETURN l_sh_payment_percentage;

END get_pub_hol_pay_details;

/*9495504 abraghun*/
FUNCTION get_max_carryover_days(p_assignment_id IN NUMBER
                               ,p_organization_id IN NUMBER
                               ,p_effective_date IN DATE) RETURN NUMBER is

  ----Assignment setting----
  CURSOR csr_assignment_carryover(c_assignment_id number) IS
  SELECT
    aei_information1 asg_max_carryover
  FROM
    per_assignment_extra_info
  WHERE assignment_id = c_assignment_id
    AND aei_information_category = 'DK_HOLIDAY_ENTITLEMENT';

  ----Legal Employer setting----
  CURSOR csr_organization_carryover(c_organization_id number) IS
  SELECT
    org_information9 org_max_carryover
  FROM
    hr_organization_information
  WHERE organization_id = c_organization_id
    AND org_information_context = 'DK_HOLIDAY_ENTITLEMENT_INFO';

  ----Global Setting----
  CURSOR csr_global_carryover(c_effective_date DATE) IS
  SELECT
    global_value gbl_max_carryover
  FROM
    ff_globals_f
  WHERE global_name = 'DK_HOLIDAY_MAX_CARRYOVER_DAYS'
    AND legislation_code = 'DK'
    AND c_effective_date BETWEEN effective_start_date AND effective_end_date;

    l_gbl_max_carryover NUMBER;
    l_org_max_carryover NUMBER;
    l_asg_max_carryover NUMBER;
    l_max_carryover     NUMBER;

BEGIN

  OPEN csr_assignment_carryover(p_assignment_id);
  FETCH csr_assignment_carryover INTO l_asg_max_carryover;
  CLOSE csr_assignment_carryover;

  OPEN csr_organization_carryover(p_organization_id);
  FETCH csr_organization_carryover INTO l_org_max_carryover;
  CLOSE csr_organization_carryover;

  OPEN csr_global_carryover(p_effective_date);
  FETCH csr_global_carryover INTO l_gbl_max_carryover;
  CLOSE csr_global_carryover;

  /* Set Global Value to Zero if not set */
  l_gbl_max_carryover := NVL(l_gbl_max_carryover,0);

  IF l_asg_max_carryover IS NOT NULL THEN
    l_max_carryover := LEAST(l_asg_max_carryover,l_gbl_max_carryover);
  ELSIF l_org_max_carryover IS NOT NULL THEN
    l_max_carryover := LEAST(l_org_max_carryover,l_gbl_max_carryover);
  ELSE
    l_max_carryover := l_gbl_max_carryover;
  END IF;

  RETURN l_max_carryover;

END get_max_carryover_days;

END PAY_DK_HOLIDAY_PAY_PKG;

/
