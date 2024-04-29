--------------------------------------------------------
--  DDL for Package Body PAY_CALC_HOURS_WORKED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CALC_HOURS_WORKED" as
/* $Header: paycalchrswork.pkb 120.0.12010000.2 2009/04/17 13:34:08 sudedas ship $ */
/*
+======================================================================+
|                Copyright (c) 1994 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : PAY_CALC_HOURS_WORKED
    Filename    : paycalchrswork.pkh
    Change List
    -----------
    Date        Name            Vers    Bug No  Description
    ----        ----            ----    ------  -----------
    28-APR-2005 sodhingr        115.0   4338404 Package to deliver new
                                                functioanlity to calculate
                                                hours worked
    09-MAY-2005 sodhingr        115.1           changed the function calculate_hours_worked
                                                to get the legislation code if it's not passed
                                                as a parameter. Legislation code is not required
                                                parameter for international localization
    15-APR-2009 sudedas        115.2   8414024  Modified dynamic function call and logic for
                                                calculate_actual_hours_worked.

*/

g_legislation_code VARCHAR2(10);

FUNCTION standard_hours_worked(
				p_std_hrs	in NUMBER,
				p_range_start	in DATE,
				p_range_end	in DATE,
				p_std_freq	in VARCHAR2) RETURN NUMBER IS

c_wkdays_per_week	NUMBER(5,2)		;
c_wkdays_per_month	NUMBER(5,2)		;
c_wkdays_per_year	NUMBER(5,2)		;

/* 353434, 368242 : Fixed number width for total hours */
v_total_hours	NUMBER(15,7)	;
v_wrkday_hours	NUMBER(15,7) 	;	 -- std hrs/wk divided by 5 workdays/wk
v_curr_date	DATE;
v_curr_day	VARCHAR2(3); -- 3 char abbrev for day of wk.
v_day_no        NUMBER;

BEGIN -- standard_hours_worked

 /* Init */
c_wkdays_per_week := 5;
c_wkdays_per_month := 20;
c_wkdays_per_year := 250;
v_total_hours := 0;
v_wrkday_hours :=0;
v_curr_date := NULL;
v_curr_day :=NULL;

-- Check for valid range
hr_utility.trace('Entered standard_hours_worked');

IF p_range_start > p_range_end THEN
  hr_utility.trace('p_range_start greater than p_range_end');
  RETURN v_total_hours;
--  hr_utility.set_message(801,'PAY_xxxx_INVALID_DATE_RANGE');
--  hr_utility.raise_error;
END IF;
--

IF UPPER(p_std_freq) = 'WEEK' THEN
  hr_utility.trace('p_std_freq = WEEK ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_week;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_week ='||to_number(c_wkdays_per_week));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'MONTH' THEN

  hr_utility.trace('p_std_freq = MONTH ');

  v_wrkday_hours := p_std_hrs / c_wkdays_per_month;


 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_month ='||to_number(c_wkdays_per_month));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSIF UPPER(p_std_freq) = 'YEAR' THEN

  hr_utility.trace('p_std_freq = YEAR ');
  v_wrkday_hours := p_std_hrs / c_wkdays_per_year;

 hr_utility.trace('p_std_hrs ='||to_number(p_std_hrs));
 hr_utility.trace('c_wkdays_per_year ='||to_number(c_wkdays_per_year));
 hr_utility.trace('v_wrkday_hours ='||to_number(v_wrkday_hours));

ELSE
hr_utility.trace('p_std_freq in ELSE ');
  v_wrkday_hours := p_std_hrs;
END IF;

v_curr_date := p_range_start;

hr_utility.trace('v_curr_date is range start'||to_char(v_curr_date));


LOOP

  v_day_no := TO_CHAR(v_curr_date, 'D');


  IF v_day_no > 1 and v_day_no < 7 then


    v_total_hours := nvl(v_total_hours,0) + v_wrkday_hours;

   hr_utility.trace('  v_day_no  = '||to_char(v_day_no));
   hr_utility.trace('  v_total_hours  = '||to_char(v_total_hours));
  END IF;

  v_curr_date := v_curr_date + 1;
  EXIT WHEN v_curr_date > p_range_end;
END LOOP;
hr_utility.trace('  Final v_total_hours  = '||to_char(v_total_hours));
hr_utility.trace('  Leaving standard_hours_worked' );
--
RETURN v_total_hours;
--
END standard_hours_worked;


FUNCTION calculate_actual_hours_worked
          (assignment_action_id   IN number   --Context
           ,assignment_id         IN number   --Context
           ,business_group_id     IN number   --Context
           ,element_entry_id      IN number   --Context
           ,date_earned           IN date     --Context
           ,p_period_start_date   IN date
           ,p_period_end_date     IN date
           ,p_schedule_category   IN varchar2  --Optional
           ,p_include_exceptions  IN varchar2  --Optional
           ,p_busy_tentative_as   IN varchar2   --Optional
           ,p_legislation_code    IN varchar2
           ,p_schedule_source     IN OUT nocopy varchar2
           ,p_schedule            IN OUT nocopy varchar2
           ,p_return_status       OUT nocopy number
           ,p_return_message      OUT nocopy varchar2)
RETURN NUMBER IS
    l_work_schedule_found   BOOLEAN;
    l_total_hours           NUMBER;
    l_normal_hours          NUMBER;
    l_asg_frequency         VARCHAR2(20);
    lv_wk_sch_found         VARCHAR2(20);

    CURSOR get_asg_hours_freq(p_date_earned date,
                              p_assignment_id number)IS
        SELECT hr_general.decode_lookup('FREQUENCY', ASSIGN.frequency)
               ,ASSIGN.normal_hours
        FROM  per_all_assignments_f         ASSIGN
        where date_earned
            BETWEEN ASSIGN.effective_start_date
        AND ASSIGN.effective_end_date
        and     ASSIGN.assignment_id = p_assignment_id;

    CURSOR get_leg_code(p_business_group_id VARCHAR2) IS
       select ORG_INFORMATION9
       from hr_organization_information
       where org_information_context = 'Business Group Information'
       and organization_id = p_business_group_id;


BEGIN
   l_work_schedule_found := FALSE;
   l_total_hours  := 0;

     hr_utility.trace( 'date_earned '||date_earned);
     hr_utility.trace('assignment_action_id=' || assignment_action_id);
     hr_utility.trace('assignment_id='        || assignment_id);
     hr_utility.trace('business_group_id='    || business_group_id);
     hr_utility.trace('element_entry_id='     || element_entry_id);
     hr_utility.trace( 'date_earned '||date_earned);
     hr_utility.trace('p_period_start_date='  || p_period_start_date);
     hr_utility.trace('p_period_end_date='    || p_period_end_date);
     hr_utility.trace('p_legislation_code='   || p_legislation_code);
     hr_utility.trace('p_schedule_category='  || p_schedule_category);
     hr_utility.trace('p_schedule_source='    || p_schedule_source);
     hr_utility.trace('p_include_exceptions=' || p_include_exceptions);
     hr_utility.trace('p_busy_tentative_as='  || p_busy_tentative_as);
     hr_utility.trace('p_schedule='     || p_schedule);


   IF (p_legislation_code IS NULL) AND (g_legislation_code IS NULL) THEN
      OPEN get_leg_code(business_group_id);
      FETCH get_leg_code INTO g_legislation_code;
      CLOSE get_leg_code;
   END IF;



   IF length(p_schedule_source) = 0  THEN
      p_schedule_source := 'PER_ASG';
   END IF;

   IF length(p_schedule) = 0 THEN
       /* THis might needs to be changed once the HR API , HR_WRK_SCH_PKG.GET_PER_ASG_SCHEDULE
          will be available */
      p_schedule := 'WORK';
   END IF;


  /* Calculate hours worked based on ATG work schedule information using
     API :  HR_WRK_SCH_PKG.GET_PER_ASG_SCHEDULE ()
     This part will be coded later once this API is available from HR
        IF p_include_exceptions IS NULL THEN
         use  p_include_exceptions = 'Y';

   */

   IF NOT l_work_schedule_found THEN
     BEGIN
       hr_utility.trace( 'getting work schedule from SCL ');
       lv_wk_sch_found := 'FALSE';
       EXECUTE IMMEDIATE 'BEGIN :1 := PAY_'||g_legislation_code||
                    '_RULES.Work_Schedule_Total_Hours(:2,:3,:4,:5,:6,:7,:8,:9); END;'
       USING OUT l_total_hours,
       IN assignment_action_id,IN assignment_id,IN business_group_id,IN element_entry_id
      ,IN date_earned,IN p_period_start_date,IN p_period_end_date,IN OUT lv_wk_sch_found;

       /*
       IF l_total_hours > 0 THEN
          hr_utility.trace( 'work schedule found from SCL ');
          l_work_schedule_found := TRUE;
          return l_total_hours;
       END IF;
       */

       -- Changing above logic for Bug# 8414024
       -- "0" total hours returned by the function does not necessarily
       -- mean Work Schedule is NOT found. In case of FLSA / Proration,
       -- total hours returned by work schedule may be zero for the FLSA
       -- or pro ration period.

       IF lv_wk_sch_found = 'TRUE' THEN
          hr_utility.trace( 'work schedule found from SCL ');
          l_work_schedule_found := TRUE;
          return l_total_hours;
       END IF;

     EXCEPTION
        WHEN OTHERS THEN
          NULL;
     END;
  END IF;

  /* Calculate hours worked based on standard conditions if the actual hours
     worked are not available from either ATG work schedule or work schedule
     at assignment/org level */

  IF NOT l_work_schedule_found THEN
     hr_utility.trace('Calculating hours based on Standard conditions ');
     hr_utility.trace( 'Assignment Id '||assignment_id);
     hr_utility.trace( 'date_earned '||date_earned);
     OPEN get_asg_hours_freq(date_earned,assignment_id);
     FETCH get_asg_hours_freq
     INTO l_asg_frequency, l_normal_hours;
     CLOSE get_asg_hours_freq;

     hr_utility.trace( 'l_asg_frequency '||l_asg_frequency);
     hr_utility.trace( 'l_normal_hours '||l_normal_hours);

     IF l_asg_frequency IS NOT NULL and l_normal_hours IS NOT NULL THEN
       	l_total_hours := standard_hours_worked(l_normal_hours
                                			   ,p_period_start_date
				                               ,p_period_end_date
											   ,l_asg_frequency);
        return l_total_hours;
     END IF;

  END IF;
  return 0;
END calculate_actual_hours_worked;
END pay_calc_hours_worked;

/
