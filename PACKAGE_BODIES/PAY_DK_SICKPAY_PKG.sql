--------------------------------------------------------
--  DDL for Package Body PAY_DK_SICKPAY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_SICKPAY_PKG" AS
/* $Header: pydksckp.pkb 120.0 2006/03/23 04:03:16 knelli noship $ */

function get_worked_hours(
	   	          p_assignment_id IN number
			 ,p_period_start_date IN date
			 ,p_period_end_date IN date)RETURN NUMBER is

l_assignment_id NUMBER;
l_period_start_date DATE;
l_period_end_date DATE;
l_period_start_time varchar2(5);
l_period_end_time varchar2(5);

l_input_value varchar2(30);
l_screen_value varchar2(30);
l_rec_start_date l_type;
l_rec_end_date l_type;
l_rec_start_time l_type;
l_rec_end_time l_type;

l_records number;
l_absent_hours number;
l_return number;
l_duration number;
l_days_or_hours varchar2(2);
l_include_event varchar2(2);
l_hours_in_period number;
l_worked_hours number;

l_start_date date;
l_end_date date;
l_start_time varchar2(10);
l_end_time varchar2(10);


CURSOR csr_get_details(p_period_start_date DATE,p_period_end_date DATE,p_assignment_id NUMBER,p_input_value VARCHAR2) is
  SELECT eev.screen_entry_value  screen_entry_value
  FROM   per_all_assignments_f      asg
        ,per_all_people_f           per
        ,pay_element_links_f        el
        ,pay_element_types_f        et
        ,pay_input_values_f         iv
        ,pay_element_entries_f      ee
        ,pay_element_entry_values_f eev
   WHERE  asg.assignment_id     = p_assignment_id
     AND  per.person_id         = asg.person_id
     AND  et.element_name       IN ('Absent Sick','Absent Holiday')
     AND  et.legislation_code   = 'DK'
     AND  iv.element_type_id    = et.element_type_id
     AND  iv.name               = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.element_link_id    = el.element_link_id
     and  ee.assignment_id      = asg.assignment_id
     AND  eev.element_entry_id  = ee.element_entry_id
     AND  eev.input_value_id    = iv.input_value_id
     AND  ((p_period_start_date BETWEEN ee.effective_start_date AND ee.effective_end_date)
           OR
	   (p_period_end_date BETWEEN ee.effective_start_date AND ee.effective_end_date)
	   OR
	   (p_period_start_date < ee.effective_start_date AND p_period_end_date > ee.effective_end_date))
    ORDER BY ee.element_entry_id;


begin

l_period_start_date := p_period_start_date;
l_period_end_date := p_period_end_date;
l_assignment_id := p_assignment_id;

l_period_start_time := '00.00';
l_period_end_time := '23.59';

l_hours_in_period :=0;
l_worked_hours :=0;

hr_utility.set_location('get worked Hours function call',10);

l_input_value := 'Start Date';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_start_date;
CLOSE csr_get_details;

l_input_value := 'End Date';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_end_date;
CLOSE csr_get_details;

l_input_value := 'Start Time';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_start_time;
CLOSE csr_get_details;

l_input_value := 'End Time';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_end_time;
CLOSE csr_get_details;

l_records := l_rec_start_date.count;
l_absent_hours := 0;
l_return := -1;
l_duration := -1;
l_days_or_hours := 'H';
l_include_event := 'Y';

FOR l_index IN 1 .. l_records LOOP
    l_start_date := to_date(substr(l_rec_start_date(l_index),1,10),'YYYY/MM/DD');
    l_end_date := to_date(substr(l_rec_end_date(l_index),1,10),'YYYY/MM/DD');
    l_start_time := l_rec_start_time(l_index);
    l_end_time := l_rec_end_time(l_index);

    IF (l_start_date < l_period_start_date) then
       l_start_date := l_period_start_date;
    END IF;

    IF (l_end_date > l_period_end_date) then
       l_end_date := l_period_end_date;
    END IF;

    l_return := hr_loc_work_schedule.calc_sch_based_dur(
			      				p_assignment_id => l_assignment_id,
			       				p_days_or_hours => l_days_or_hours,
			       				p_include_event => l_include_event,
                               				p_date_start    => l_start_date,
                               				p_date_end      => l_end_date,
                               				p_time_start    => l_start_time,
                               				p_time_end      => l_end_time,
                               				p_duration      => l_duration);

	/*  Handled availability of work schedule for Sickness Report */
	IF l_return <> 0 then
	   l_worked_hours := -1;
	ELSE
           l_absent_hours := l_absent_hours + l_duration;
	END if;
END LOOP;
IF l_worked_hours = -1 then
   RETURN l_worked_hours;
END IF;
/*  Handled availability of work schedule for Sickness Report */

l_duration := -1;
l_include_event := 'Y';

l_return := hr_loc_work_schedule.calc_sch_based_dur(
			      			    p_assignment_id => l_assignment_id,
			       			    p_days_or_hours => l_days_or_hours,
                               			    p_include_event => l_include_event,
			       			    p_date_start    => l_period_start_date,
                               			    p_date_end      => l_period_end_date,
                               			    p_time_start    => l_period_start_time,
                               			    p_time_end      => l_period_end_time,
                               			    p_duration      => l_duration);

   l_hours_in_period := l_duration;
   l_worked_hours := l_hours_in_period - l_absent_hours;


RETURN l_worked_hours;
END get_worked_hours;


/*Bug 5047360 fix- Passing p_abs_start_time and p_abs_end_time*/
FUNCTION get_sickness_dur_details
	 (p_assignment_id               IN      NUMBER
	 ,p_effective_date              IN      DATE
	 ,p_abs_start_date              IN      DATE
	 ,p_abs_end_date                IN      DATE
	 ,p_abs_start_time              IN      VARCHAR2 --Bug 5047360 fix
	 ,p_abs_end_time                IN      VARCHAR2 --Bug 5047360 fix
	 ,p_start_date                  OUT NOCOPY DATE
	 ,p_end_date                    OUT NOCOPY DATE
	 ,p_sick_days                   OUT NOCOPY NUMBER
	 ,p_sick_hours                  OUT NOCOPY NUMBER
	 ) RETURN NUMBER IS
  CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE ) IS
   SELECT ee.element_entry_id element_entry_id
          , eev1.screen_entry_value  screen_entry_value
          , iv1.name
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  et.element_name       = 'Override Sickness Duration'
     AND  et.legislation_code   = 'DK'
     AND  iv1.element_type_id   = et.element_type_id
     /*Bug 5047360 fix */
    /* AND  iv1.name            in ('Start Date', 'End Date', 'Sick Days', 'Sick Hours')*/
     AND  iv1.name              in ('Start Date', 'End Date', 'Sick Days','Start Time','End Time', 'Sick Hours')
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     ORDER BY ee.element_entry_id, DECODE(iv1.name, 'Start Date', 1,'End Date', 2, 'Sick Days', 3,'Start Time', 4,'End Time', 5,'Sick Hours', 6) ;
  --
  TYPE l_record is record (eeid    pay_element_entries_f.element_entry_id%TYPE,
                           eevalue pay_element_entry_values_f.screen_entry_value%TYPE,
                           eename  pay_input_values_f.name%TYPE );
  l_rec l_record;
  TYPE l_table  is table of l_record index by BINARY_INTEGER;
  l_tab l_table;

  l_start_date date;
  l_end_date date;
  l_sick_hours number;
  l_sick_days number;
  l_counter number ;
  l_bool_match boolean;
  l_num_match number;
  /*Bug 5047360 fix */
  l_start_time pay_element_entry_values_f.screen_entry_value%TYPE;
  l_end_time pay_element_entry_values_f.screen_entry_value%TYPE;
  --
 BEGIN
  --
  l_counter := 1;
  l_bool_match := FALSE;

  -- Open cursor to fetch all screen entry values of Sickness Duration element.
  OPEN  get_details(p_assignment_id , p_effective_date );
  -- Assign the values to a table type
  FETCH get_details BULK COLLECT INTO l_tab;
  CLOSE get_details;

  -- Loop through each values for processing.
  FOR l_cur in 1..l_tab.count LOOP
        -- Assign values to local variables.
        IF l_tab(l_cur).eename = 'Start Date' THEN
           l_start_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss') ;
        elsif l_tab(l_cur).eename = 'End Date' THEN
           l_end_date := to_date(l_tab(l_cur).eevalue,'yyyy/mm/dd hh24:mi:ss');
        elsif l_tab(l_cur).eename = 'Sick Days' THEN
           l_sick_days := l_tab(l_cur).eevalue;
	  /*Bug 5047360 fix */
         elsif l_tab(l_cur).eename = 'Start Time' THEN
           l_start_time := NVL(l_tab(l_cur).eevalue,'0');
        elsif l_tab(l_cur).eename = 'End Time' THEN
           l_end_time := NVL(l_tab(l_cur).eevalue,'0');
        elsif l_tab(l_cur).eename = 'Sick Hours' THEN
           l_sick_hours := l_tab(l_cur).eevalue;
        end if;
        -- Check no. of input values of override element is 4
        --IF l_counter < 4 then
	  /*Bug 5047360 fix */
         -- Check no. of input values of override element is 6
	  IF l_counter < 6 then
           l_counter := l_counter + 1;
        else
           -- Check override element's start and end date matches with Absent element.
           --if l_start_date = p_abs_start_date and l_end_date = p_abs_end_date then
            /*Bug 5047360 fix-Check override element's start date,end date,start time and end time
	      matches with Absent element */
            IF l_start_date = p_abs_start_date AND  l_end_date = p_abs_end_date
            AND l_start_time = p_abs_start_time AND l_end_time  = p_abs_end_time THEN
              -- Multiple entry exists with same start and end date
              IF l_bool_match THEN
                 p_start_date := null;
                 p_end_date := null;
                 p_sick_days := null;
                 p_sick_hours := null;
                 return -1;
              -- Exact match found
              ELSE
                 l_bool_match := True;
              END IF;
              -- Assign input values to output variables.
              p_start_date := l_start_date;
              p_end_date := l_end_date;
              p_sick_days := l_sick_days;
              p_sick_hours := l_sick_hours;
           end if;
           l_counter := 1;
        end if;
  END LOOP;

  -- Match found successfully
  IF p_start_date is not null then
     RETURN 1;
  -- Override element exists but date doesnt match.
  /*Bug 5047360 fix- commenting the else if part*/
  /*elsif p_start_date is null and l_tab.count > 0 then
     RETURN 2;*/
  -- No override element attached
  else
     RETURN 0;
  end if;
  --
 END get_sickness_dur_details;


   FUNCTION get_le_sickpay_details
	(p_effective_date IN DATE,
	 p_org_id IN NUMBER,
	 p_section27 OUT NOCOPY VARCHAR2
	 ) RETURN NUMBER is

	 /* Modified cursor */
	 CURSOR csr_get_sickpay_defaults(p_effective_date DATE, p_org_id NUMBER) is
	 SELECT org_information1
	 FROM hr_organization_information
	 WHERE organization_id = p_org_id
	 and org_information_context = 'DK_SICKPAY_DEFAULTS'
	 AND p_effective_date BETWEEN fnd_date.canonical_to_date( org_information2) and fnd_date.canonical_to_date( org_information3)
	 order by org_information2;
	 TYPE l_record is record (sec_27 varchar2(1));
	 l_rec l_record;
	 TYPE l_table  is table of l_record index by BINARY_INTEGER;
	 l_tab l_table;
	 begin
	 OPEN csr_get_sickpay_defaults(p_effective_date,p_org_id);
	 FETCH csr_get_sickpay_defaults BULK COLLECT INTO l_tab;
	 CLOSE csr_get_sickpay_defaults;
	 IF l_tab.COUNT = 1 then
	     p_section27 := l_tab(1).sec_27;
	     RETURN 1;
	 Elsif l_tab.COUNT = 0 then
	     RETURN 0;
	 else
	     RETURN -1;
	 END if;
 END get_le_sickpay_details;

/*Bug 5020916 fix - Fucntion to get the section 28 value based on the payroll processing start date*/
FUNCTION get_section28_details
     (p_assignment_id IN NUMBER
     ,p_effective_date IN DATE --payroll processing start date
     ) RETURN VARCHAR2 IS
CURSOR csr_section28 IS
SELECT
    NVL(hsck.segment18,'N')
FROM
	per_all_assignments_f paaf
	,hr_soft_coding_keyflex hsck
WHERE
	paaf.assignment_id = p_assignment_id
	AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND hsck.soft_coding_keyflex_id = paaf.soft_coding_keyflex_id;

l_section28_reg hr_soft_coding_keyflex.segment18%TYPE ;

BEGIN
	OPEN csr_section28;
	FETCH csr_section28 INTO l_section28_reg;
	CLOSE csr_section28;
	RETURN l_section28_reg;
END get_section28_details;


/* Bug fix 5045710, added function get_worked_days */
FUNCTION get_worked_days(p_assignment_id     IN number
			,p_period_start_date IN date
			,p_period_end_date   IN date)RETURN NUMBER is

l_assignment_id NUMBER;
l_period_start_date DATE;
l_period_end_date DATE;
l_period_start_time varchar2(5);
l_period_end_time varchar2(5);

l_input_value varchar2(30);
l_screen_value varchar2(30);
l_rec_start_date l_type;
l_rec_end_date l_type;
l_rec_start_time l_type;
l_rec_end_time l_type;

l_records number;
l_absent_days number;
l_return number;
l_duration number;
l_days_or_hours varchar2(2);
l_include_event varchar2(2);
l_days_in_period number;
l_worked_days number;

l_start_date date;
l_end_date date;
l_start_time varchar2(10);
l_end_time varchar2(10);


CURSOR csr_get_details(p_period_start_date DATE,p_period_end_date DATE,p_assignment_id NUMBER,p_input_value VARCHAR2) is
  SELECT eev.screen_entry_value  screen_entry_value
  FROM   per_all_assignments_f      asg
        ,per_all_people_f           per
        ,pay_element_links_f        el
        ,pay_element_types_f        et
        ,pay_input_values_f         iv
        ,pay_element_entries_f      ee
        ,pay_element_entry_values_f eev
   WHERE  asg.assignment_id     = p_assignment_id
     AND  per.person_id         = asg.person_id
     AND  et.element_name       IN ('Absent Sick','Absent Holiday')
     AND  et.legislation_code   = 'DK'
     AND  iv.element_type_id    = et.element_type_id
     AND  iv.name               = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.element_link_id    = el.element_link_id
     and  ee.assignment_id      = asg.assignment_id
     AND  eev.element_entry_id  = ee.element_entry_id
     AND  eev.input_value_id    = iv.input_value_id
     AND  ((p_period_start_date BETWEEN ee.effective_start_date AND ee.effective_end_date)
           OR
	   (p_period_end_date BETWEEN ee.effective_start_date AND ee.effective_end_date)
	   OR
	   (p_period_start_date < ee.effective_start_date AND p_period_end_date > ee.effective_end_date))
    ORDER BY ee.element_entry_id;


begin

l_period_start_date := p_period_start_date;
l_period_end_date := p_period_end_date;
l_assignment_id := p_assignment_id;

l_period_start_time := '00.00';
l_period_end_time := '23.59';

l_days_in_period :=0;
l_worked_days :=0;

l_input_value := 'Start Date';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_start_date;
CLOSE csr_get_details;

l_input_value := 'End Date';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_end_date;
CLOSE csr_get_details;

l_input_value := 'Start Time';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_start_time;
CLOSE csr_get_details;

l_input_value := 'End Time';
OPEN csr_get_details(l_period_start_date ,l_period_end_date ,l_assignment_id ,l_input_value );
FETCH csr_get_details BULK COLLECT INTO l_rec_end_time;
CLOSE csr_get_details;

l_records := l_rec_start_date.count;
l_absent_days := 0;
l_return := -1;
l_duration := -1;
l_days_or_hours := 'D';
l_include_event := 'N';

FOR l_index IN 1 .. l_records LOOP
    l_start_date := to_date(substr(l_rec_start_date(l_index),1,10),'YYYY/MM/DD');
    l_end_date := to_date(substr(l_rec_end_date(l_index),1,10),'YYYY/MM/DD');

    l_start_time := '00.00';
    l_end_time := '23.59';

    IF (l_start_date < l_period_start_date) then
       l_start_date := l_period_start_date;
    END IF;

    IF (l_end_date > l_period_end_date) then
       l_end_date := l_period_end_date;
    END IF;

    l_duration := -1;
    l_return := hr_loc_work_schedule.calc_sch_based_dur(
			      				p_assignment_id => l_assignment_id,
			       				p_days_or_hours => l_days_or_hours,
			       				p_include_event => l_include_event,
                               				p_date_start    => l_start_date,
                               				p_date_end      => l_end_date,
                               				p_time_start    => l_start_time,
                               				p_time_end      => l_end_time,
                               				p_duration      => l_duration);

	/*  Handled availability of work schedule for Sickness Report */
	IF l_return <> 0 then
	   l_worked_days := -1;
	ELSE
           l_absent_days := l_absent_days + l_duration;
	END if;
END LOOP;
IF l_worked_days = -1 then
   RETURN l_worked_days;
END IF;
/*  Handled availability of work schedule for Sickness Report */

l_duration := -1;
l_include_event := 'Y';
l_days_or_hours := 'D';

l_return := hr_loc_work_schedule.calc_sch_based_dur(
			      			    p_assignment_id => l_assignment_id,
			       			    p_days_or_hours => l_days_or_hours,
                               			    p_include_event => l_include_event,
			       			    p_date_start    => l_period_start_date,
                               			    p_date_end      => l_period_end_date,
                               			    p_time_start    => l_period_start_time,
                               			    p_time_end      => l_period_end_time,
                               			    p_duration      => l_duration);

   l_days_in_period := l_duration;
   l_worked_days := l_days_in_period - l_absent_days;

RETURN l_worked_days;


END get_worked_days;


FUNCTION get_worked_hours_flag(p_assignment_id      IN number
			      ,p_worked_days_limit  IN number
			      ,p_worked_hours_limit IN number
			      ,p_period_end_date    IN date) RETURN varchar2 is

l_assignment_id NUMBER;
l_worked_days_limit NUMBER;
l_worked_hours_limit NUMBER;
l_period_start_date DATE;
l_period_end_date DATE;
l_worked_hours number;
l_worked_days number;
l_total_worked_hours number;
l_total_worked_days number;
l_return varchar2(2);

begin

l_assignment_id := p_assignment_id;
l_worked_days_limit := p_worked_days_limit;
l_worked_hours_limit := p_worked_hours_limit;
l_period_end_date :=  p_period_end_date - 1;
l_period_start_date := p_period_end_date - l_worked_days_limit;

l_total_worked_days := -1;
l_total_worked_hours := -1;
l_worked_hours := -1;
l_worked_days := -1;
l_return := 'N';

l_total_worked_hours := get_worked_hours(
	   	                        l_assignment_id
			               ,l_period_start_date
			               ,l_period_end_date);

l_total_worked_days := get_worked_days(
	   	                      l_assignment_id
			             ,l_period_start_date
			             ,l_period_end_date);
/* reopned bug fix 5045710, following statement caused problem, which is not required
l_total_worked_days := l_total_worked_days - 1;
*/

/* reopned bug fix 5045710, following conditions corrected
IF l_worked_hours > l_worked_hours_limit THEN
   l_return := 'Y';
   RETURN l_return;
ELSIF l_total_worked_days >= l_worked_days_limit AND l_worked_hours < l_worked_hours_limit THEN
   l_return := 'N';
   RETURN l_return;
END IF;
*/

IF l_total_worked_hours >= l_worked_hours_limit THEN
   l_return := 'Y';
   RETURN l_return;
ELSIF l_total_worked_days >= l_worked_days_limit AND l_total_worked_hours < l_worked_hours_limit THEN
   l_return := 'N';
   RETURN l_return;
END IF;

l_period_end_date := l_period_start_date - 1;
l_period_start_date := l_period_start_date - (l_worked_days_limit - l_total_worked_days);

WHILE (l_total_worked_hours < l_worked_hours_limit AND l_total_worked_days < l_worked_days_limit)
LOOP

	 l_worked_hours := get_worked_hours(
	   	                           l_assignment_id
			                  ,l_period_start_date
			                  ,l_period_end_date);
	l_total_worked_hours := l_total_worked_hours + l_worked_hours;

	l_worked_days := get_worked_days(
	   	                        l_assignment_id
			               ,l_period_start_date
			               ,l_period_end_date);
	l_total_worked_days := l_total_worked_days + l_worked_days;

	l_period_end_date := l_period_start_date - 1;
	l_period_start_date := l_period_start_date - (l_worked_days_limit - l_total_worked_days);

END LOOP;

IF l_total_worked_hours > l_worked_hours_limit THEN
   l_return := 'Y';
ELSE
   l_return := 'N';
END IF;

RETURN l_return;

END get_worked_hours_flag;

END pay_dk_sickpay_pkg;

/
