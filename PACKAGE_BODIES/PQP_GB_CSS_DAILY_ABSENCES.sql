--------------------------------------------------------
--  DDL for Package Body PQP_GB_CSS_DAILY_ABSENCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_CSS_DAILY_ABSENCES" AS
/* $Header: pqgbdcss.pkb 120.1.12010000.3 2009/07/30 15:31:42 vaibgupt ship $ */
-----------------

        e_novalue        EXCEPTION;
-----------------

    g_nested_level     NUMBER:= 0;
    g_package_name     VARCHAR2(31) := 'pqp_gb_css_daily_absences.' ;
    -- g_plan_information pqp_absval_pkg.rec_plan_information ;
    g_debug            BOOLEAN ;
-- Cache for rounding of factors
  g_pt_entitl_rounding_type       VARCHAR2(10):=null;
  g_pt_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_ft_rounding_precision         pqp_gap_daily_absences.duration%TYPE;
  g_ft_entitl_rounding_type       VARCHAR2(10):=null ;
  g_open_ended_no_pay_days        NUMBER;

  PROCEDURE debug
    (p_trace_message  IN     VARCHAR2
    ,p_trace_location IN     NUMBER
    )
  IS
  BEGIN
    pqp_utilities.debug(p_trace_message,p_trace_location);
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_number   IN     NUMBER )
  IS
  BEGIN
      debug(fnd_number.number_to_canonical(p_trace_number));
  END debug;
--
--
--
  PROCEDURE debug
    (p_trace_date     IN     DATE )
  IS
  BEGIN
      debug(fnd_date.date_to_canonical(p_trace_date));
  END debug;
--
--
--
  PROCEDURE debug_enter
    (p_proc_name IN VARCHAR2
    ,p_trace_on  IN VARCHAR2
    )
  IS
--     l_trace_options    VARCHAR2(200);
  BEGIN
    pqp_utilities.debug_enter(p_proc_name,p_trace_on);
  END debug_enter;
--
--
--
  PROCEDURE debug_exit
    (p_proc_name IN VARCHAR2
    ,p_trace_off IN VARCHAR2
    )
  IS
  BEGIN
    pqp_utilities.debug_exit(p_proc_name,p_trace_off);
  END debug_exit;

-- This Procedure is called from pqp_absval_pkg.create_absence_plan_details
-- The logic of derving Review Dates and calculating the Remaining
-- entitlement is coded in this.

PROCEDURE create_absence_plan_details
            ( p_assignment_id      IN  NUMBER
             ,p_business_group_id  IN  NUMBER
             ,p_absence_id         IN  NUMBER
             ,p_pl_id              IN  NUMBER
             ,p_pl_typ_id          IN  NUMBER
             ,p_create_start_date  IN  DATE
             ,p_create_end_date    IN  DATE
	     ,p_entitlements       IN pqp_absval_pkg.t_entitlements
	     ,p_plan_information   IN pqp_absval_pkg.rec_plan_information
	     ,p_entitlements_remaining OUT NOCOPY pqp_absval_pkg.t_entitlements
	     ,p_entitlement_UOM        OUT NOCOPY VARCHAR2
	     ,p_working_days_per_week  OUT NOCOPY NUMBER
             ,p_fte  OUT NOCOPY NUMBER
            )  IS

    l_error_code             fnd_new_messages.message_number%TYPE := 0 ;
    l_proc_name  VARCHAR2(61) := g_package_name||'create_absence_plan_details';
    l_proc_step                   NUMBER(20,10);
    l_nopay_review_date      DATE;
    l_halfpay_review_date    DATE;
    l_dual_rolling_period   NUMBER;
    l_secondary_rolling_period NUMBER;
    l_total_entitlements       NUMBER := 0 ;
    l_total_remaining           NUMBER ;
    l_fullpay_duration         NUMBER ;
    l_error_message            fnd_new_messages.message_text%TYPE;
    l_working_days_in_week
         pqp_gap_daily_absences.working_days_per_week%TYPE ;
    i NUMBER ;

   l_entitlements_remaining_nc pqp_absval_pkg.t_entitlements
                                := p_entitlements_remaining;
   l_entitlement_UOM_nc    VARCHAR2(30) := p_entitlement_UOM ;
   l_working_days_per_week_nc pqp_gap_daily_absences.working_days_per_week%TYPE
                               := p_working_days_per_week;
   l_standard_work_days_in_week
           pqp_gap_daily_absences.working_days_per_week%TYPE ;
   l_fulltime BOOLEAN ;

BEGIN

    g_debug := hr_utility.debug_enabled ;

    IF g_debug THEN
     debug_enter(l_proc_name) ;
     debug('p_assignment_id:'||p_assignment_id);
     debug('p_business_group_id:'||p_business_group_id);
     debug('p_absence_id:'||p_absence_id);
     debug('p_pl_id:'||p_pl_id);
     debug('p_pl_typ_id:'||p_pl_typ_id);
     debug('p_start_date:'||p_create_start_date);
     debug('p_end_date:'||p_create_end_date);
    END IF ;


    --Set the global rounding factor cache if the values are not already set

    IF g_ft_entitl_rounding_type is null THEN
        PQP_GB_OSP_FUNCTIONS.set_osp_omp_rounding_factors
          (p_pl_id                    => p_pl_id
          ,p_pt_entitl_rounding_type  => g_pt_entitl_rounding_type
          ,p_pt_rounding_precision    => g_pt_rounding_precision
          ,p_ft_entitl_rounding_type  => g_ft_entitl_rounding_type
          ,p_ft_rounding_precision    => g_ft_rounding_precision
          );
    END IF;

   IF g_debug THEN
      debug('p_pt_entitl_rounding_type' || g_pt_entitl_rounding_type);
      debug('p_pt_rounding_precision' , g_pt_rounding_precision);
      debug('p_ft_entitl_rounding_type' || g_ft_entitl_rounding_type);
      debug('p_ft_rounding_precision' , g_ft_rounding_precision);
      debug(l_proc_name, 15);
  END IF;


-- The Input parameters we have are the Entitlements and Plan Information
--  we need to work out the Review Dates and calculate the entitlements
-- Remaining
-- First loop through the entitlements and determine the Entitlements
-- Over a 4 year period duration.
-- then call get_review_date to derive NoPAY Review Date i.e. the Date NoPay
-- Starts and Half Pay Review Date i.e. the date Half Pay Starts
-- Once these 2 dates are determined along with the duration check for
-- the work pattern attached and the number of working days in a week.
-- If there is no work pattern attached or workpattern with working days
-- morethan 5 then mark that as a Full Time employee i.e. the entitlements
-- and Payments both will be set to Calendar ( we set entitlements only
-- to calendar here.Payment will be picked up from scheme info )
-- If the employee is Part Time i.e. the number of working days in the week
-- are less than 5 then mark his entitlements as Working Days.
-- Calculate the BAND1 and BANd2 days and populate the structure
-- p_entitlements_remaining.


       i := p_entitlements.FIRST;

       WHILE i IS NOT NULL
       LOOP

         IF g_debug THEN
	  debug('i:'||i);
	 END IF ;
          l_total_entitlements := l_total_entitlements +
	                           p_entitlements(i).entitlement ;
          i := p_entitlements.NEXT(i);
       END LOOP ;


       l_proc_step := 10 ;

       l_dual_rolling_period :=fnd_number.canonical_to_number(
                               p_plan_information.dual_rolling_period_duration
			       );

          l_proc_step := 20 ;


         l_working_days_in_week :=
	                pqp_schedule_calculation_pkg.
	                    get_working_days_in_week
		           (
                            p_assignment_id     => p_assignment_id
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date    => p_create_start_date
			   ,p_default_wp =>
			    p_plan_information.default_work_pattern_name
                           ) ;

        l_standard_work_days_in_week :=
               pqp_schedule_calculation_pkg.get_working_days_in_week (
                     p_assignment_id     => p_assignment_id
                    ,p_business_group_id => p_business_group_id
                    ,p_effective_date    => p_create_start_date
		    ,p_override_wp       =>
		     p_plan_information.default_work_pattern_name
                    ) ;

        l_proc_step := 50 ;
	 IF g_debug THEN
           debug(' No of Working Days in Week:'||l_working_days_in_week);
	 END IF;

         IF NVL(l_working_days_in_week,l_standard_work_days_in_week) >=
	        l_standard_work_days_in_week THEN
            p_entitlement_uom := 'C' ;
	    p_working_days_per_week := 7 ;
	    l_fulltime := TRUE ;
	    p_fte:=1;
	 ELSE
            p_entitlement_uom := 'W' ;
            p_fte:= l_working_days_in_week/l_standard_work_days_in_week;
            p_working_days_per_week := l_working_days_in_week ;
	    l_fulltime := FALSE ;
         END IF;

	l_proc_step := 60 ;
         IF g_debug THEN
            debug(' No of Working Days in week:'||p_working_days_per_week);
	 END IF;


     l_nopay_review_date :=
      get_review_date(
        p_absence_start_date    => trunc(p_create_start_date)
       ,p_absence_end_date      => trunc(p_create_end_date)
       ,p_assignment_id         => p_assignment_id
       ,p_business_group_id     => p_business_group_id
       ,p_pl_typ_id             => p_pl_typ_id
       ,p_scheme_period_duration => l_dual_rolling_period
       ,p_scheme_period_type     => p_plan_information.scheme_period_type
       ,p_scheme_period_uom      => p_plan_information.dual_rolling_period_uom
       ,p_total_entitlement     => l_total_entitlements
       ,p_total_remaining       => l_total_remaining
       ,p_4_year_rolling_period => TRUE
       ,p_working_days_in_week  => p_working_days_per_week
       ,p_standard_work_days_in_week => l_standard_work_days_in_week
       ,p_fulltime              => l_fulltime
       ,p_lookup_type  => p_plan_information.plan_types_to_extend_period
       ) ;

          l_proc_step := 30 ;
          IF g_debug THEN
             debug(' 4-Year Review Date:'||l_nopay_review_date );
	     debug(' Remaining Entitlements:'||l_total_remaining);
	  END IF ;


     l_halfpay_review_date :=
      get_review_date(
        p_absence_start_date    => trunc(p_create_start_date)
       ,p_absence_end_date      => trunc(p_create_end_date)
       ,p_assignment_id         => p_assignment_id
       ,p_business_group_id     => p_business_group_id
       ,p_pl_typ_id             => p_pl_typ_id
       ,p_scheme_period_duration => p_plan_information.scheme_period_duration
       ,p_scheme_period_type     => p_plan_information.scheme_period_type
       ,p_scheme_period_uom      => p_plan_information.scheme_period_uom
       ,p_total_entitlement     => p_entitlements(1).entitlement
       ,p_total_remaining       => l_fullpay_duration
       ,p_4_year_rolling_period => FALSE
       ,p_working_days_in_week  => p_working_days_per_week
       ,p_standard_work_days_in_week => l_standard_work_days_in_week
       ,p_fulltime              => l_fulltime
       ,p_lookup_type => p_plan_information.plan_types_to_extend_period
       ) ;
        l_proc_step := 40 ;
          IF g_debug THEN
             debug(' 1-Year Review Date:'||l_halfpay_review_date);
	     debug(' Remaining Entitlements:'||l_fullpay_duration);
	  END IF ;

/*         l_working_days_in_week :=
	                pqp_schedule_calculation_pkg.
	                    get_working_days_in_week
		           (
                            p_assignment_id     => p_assignment_id
                           ,p_business_group_id => p_business_group_id
                           ,p_effective_date    => p_create_start_date
                           ) ;

        l_proc_step := 50 ;
	 IF g_debug THEN
           debug(' No of Working Days in Week:'||l_working_days_in_week);
	 END IF;

         IF NVL(l_working_days_in_week,5) >= 5 THEN
            p_entitlement_uom := 'C' ;
	    p_working_days_per_week := 7 ;
	 ELSE
            p_entitlement_uom := 'W' ;
            p_working_days_per_week := l_working_days_in_week ;
         END IF;

        l_proc_step := 60 ;
         IF g_debug THEN
            debug(' No of Working Days in week:'||p_working_days_per_week);
	 END IF;

*/

    -- Look at deriving BAND1 Days and BAND2 Days logic again
    -- try to get it from dates rather than the existing procedure

      IF l_fullpay_duration > l_total_remaining THEN
         l_fullpay_duration := l_total_remaining ;
      END IF;


        l_proc_step := 70 ;


     /*IF p_entitlement_uom = 'W' THEN

        l_fullpay_duration := FLOOR(l_fullpay_duration *
	                           (l_working_days_in_week/7)
				   );
	  -- Hard Coded 7..try to generalize it.
         l_total_remaining := FLOOR(l_total_remaining*
	                           (l_working_days_in_week/7)
				   );

	IF g_debug THEN
          debug(' Full Pay Duration :'||l_fullpay_duration);
          debug(' Total Duration :'||l_total_remaining);
	END IF;

      END IF; */


	IF g_debug THEN
           debug('Band1 :'||l_fullpay_duration);
           debug('l_total_duration:'||l_total_remaining);
	END IF;


	p_entitlements_remaining(1).band := 'BAND1' ;
        p_entitlements_remaining(1).entitlement := l_fullpay_duration ;
        p_entitlements_remaining(2).band := 'BAND2' ;
        p_entitlements_remaining(2).entitlement := l_total_remaining
	                                          - l_fullpay_duration ;


       IF g_debug THEN
         debug_exit(l_proc_name) ;
       END IF;
EXCEPTION
WHEN OTHERS THEN
     p_entitlements_remaining := l_entitlements_remaining_nc ;
     p_entitlement_UOM := l_entitlement_UOM_nc ;
     p_working_days_per_week := l_working_days_per_week_nc ;

    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END create_absence_plan_details ;



--4 Years Rolling Period Calculation.
--This process will calculate the date an employee goes onto 'Unpaid Sickness'
--1.	Go back 4 years from the absence Start Date.
--2.	Identify any 'excluded' days within the 4 year period and
--      extend the 4 year period by this number of days.
--3.	Identify if any 'excluded' days fall within the extended period.
--      If so, further extend the 4 year period by this number of days.
--      Repeat this process until all 'excluded' days are identified
--4.	Count total days paid at Full Pay or Half Pay within period
--      up to absence Start Date.
--5.	Subtract these days from 365
--6.	If balance <= 0 Stop. The full duration of the absence
--      should be unpaid.
--7.	If balance is >0 add number of days to Start Date to get Review Date1
--8.	Go back 4 years from Review Date 1
--9.	Identify any 'excluded' days within the 4 year period and extend
--      the 4 year period by this number of days.
--10.	Identify if any 'excluded' days fall within the extended period.
--      If so, further extend the 4 year period by this number of days.
--      Repeat this process until all 'excluded' days are identified
--11.	Count total days paid at Full Pay or Half Pay within period up
--      to Review Date 1 (this will now include the current absence days)
--12.	Subtract these days from 365
--13.	If balance <= 0 Stop.
--14.	If balance is >0 add number of days to Start Date to get Review Date 2
--15.	Repeat steps 8-14 for Review Date 2 and any additional Review Dates
--      until the balance is = 0.
--16.	This final Review Date is the date the employee is due
--      to start Unpaid Sick leave

-- The same logic applies to 1-Year rolling period
-- and the Half Pay Start date is also calculated using the similar logic
-- with only change in the extending the rolling period part.

FUNCTION get_review_date ( p_absence_start_date     IN DATE
                          ,p_absence_end_date       IN DATE
                          ,p_assignment_id          IN NUMBER
			  ,p_business_group_id      IN NUMBER
                          ,p_pl_typ_id              IN NUMBER
			  ,p_scheme_period_duration IN NUMBER
			  ,p_scheme_period_type     IN VARCHAR2
			  ,p_scheme_period_uom      IN VARCHAR2
			  ,p_total_entitlement      IN NUMBER
			  ,p_total_remaining        IN OUT NOCOPY NUMBER
			  ,p_4_year_rolling_period  IN BOOLEAN--TRUE for 4year
-- PT Changes
                          ,p_working_days_in_week   IN NUMBER
                          ,p_standard_work_days_in_week IN NUMBER
                          ,p_fulltime               IN BOOLEAN
			  ,p_lookup_type            IN VARCHAR2
                         ) RETURN DATE IS

  l_absences_taken pqp_absval_pkg.t_entitlements ;
  l_rolling_end_date  DATE := p_absence_start_date ;
  l_rolling_start_date    DATE ;
  l_total_entitlement   NUMBER := 0 ; --p_total_entitlement ; -- PT Changes
  l_total_absences_taken NUMBER := 0 ;
  l_work_pattern_count  NUMBER ;
  l_remaining_entitlements NUMBER ;
  l_proc_name  VARCHAR2(61) := g_package_name||'get_review_date';
  l_proc_step  NUMBER(20,10) ;
  l_total_remaining_nc NUMBER ;
  l_error_code fnd_new_messages.message_number%TYPE ;
  l_error_message fnd_new_messages.message_text%TYPE ;
  i NUMBER ;
  l_decimal_part NUMBER ;

BEGIN

    g_debug := hr_utility.debug_enabled ;

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_absence_start_date:'||p_absence_start_date);
    debug('p_absence_end_date:'||p_absence_end_date);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_pl_typ_id:'||p_pl_typ_id);
    debug('p_scheme_period_duration:'||p_scheme_period_duration);
    debug('p_scheme_period_type:'||p_scheme_period_type);
    debug('p_scheme_period_uom:'||p_scheme_period_uom);
    debug('p_total_entitlement:'||p_total_entitlement);
   END IF;

-- the logic followed to acheive the steps described above.
-- First rollback by the duration that is passed
-- determining the rolling start including the extension part is
-- coded in get_rolling_start_date

-- Now need to calcualte the remaining entitlements
-- First calculate the entitlements used and deduct from
-- the entitlements to get the remaining
-- now add the remaining to the start date will get a date letus call
-- Review Date1
-- what we did effectively in the above step is
-- we have added the remaining entitlements and derived a date. note that
-- these days are not processed yet so they are not there in the database
-- they are simply projected.so add the duration projected to the variable
-- absences taken.
-- 01-jan-00     30                01-jan-04
--- |-----------|--|---------------------|
-- let us say that there were 30 absences taken in the rolling period
-- ( dont look at it whether it is 4 year or 1 year. logic remains same)
-- at this point entitlements remaining in 4 years = 365 - 30 = 335
-- now add this to absence start date = 01-jan-04 + 335 = 01-dec-04
-- now when u loop through we should go back from 01-dec-04 to check the
-- entitlements remaining. but the figure 335 is not there in the database
-- yet.so add this 335 to absences taken so = 365.
-- now on 01-dec-04 the entitlements - absneces taken = 0
-- this is the review date.


   -- PT Changes
     -- Converting the entitlements into Weeks
     -- For Full timers keeping the faction also
     -- For Part timers round it down.
         IF p_fulltime THEN
             l_total_entitlement := p_total_entitlement/7 ;
	 ELSE
	     l_total_entitlement := (p_total_entitlement/7) ;
	 END IF;

      p_total_remaining := 0 ;

   loop

   -- get_rolling_start_date should be = pqp_absbal_pkg.get_scheme_start_date
   -- and adjust_scheme_start_date. this could be a new function???
   -- to use this for both 4-year and 1-year pass some variable for
   -- nopay days logic ( BOOLEAN variable)
    l_proc_step := 10 ;
   l_rolling_start_date :=
            get_rolling_start_date(
                 p_rolling_end_date => l_rolling_end_date
                ,p_scheme_period_duration => p_scheme_period_duration
	        ,p_assignment_id      => p_assignment_id
                ,p_business_group_id  => p_business_group_id
                ,p_scheme_period_type     => p_scheme_period_type
                ,p_scheme_period_uom      => p_scheme_period_uom
                ,p_pl_typ_id              => p_pl_typ_id
                ,p_4_year_rolling_period => p_4_year_rolling_period
		,p_lookup_type           => p_lookup_type
		) ;
    l_proc_step := 20 ;
   IF g_debug THEN
    debug('Rolling Start date:'||l_rolling_start_date);
    debug('Eligible Days:'||l_total_entitlement);
   END IF;

-- get_paid_absence_days use get_absences_taken in pqp_absval_pkg
-- For 4 year scheme sum all the bands returned from that
-- For Full Paid only take BAND1

         IF g_debug THEN
	   debug('p_assignment_id:'||p_assignment_id);
           debug('p_pl_typ_id:'||p_pl_typ_id);
           debug('l_rolling_start_date:'||l_rolling_start_date);
	   debug('l_rolling_end_date:'||l_rolling_end_date);
	 END IF ;
         l_absences_taken.DELETE;
         pqp_absval_pkg.get_absences_taken
                    (p_assignment_id   => p_assignment_id
                    ,p_pl_typ_id       => p_pl_typ_id
                    ,p_range_from_date => l_rolling_start_date
                    ,p_range_to_date   => l_rolling_end_date-1
                    ,p_absences_taken  => l_absences_taken
                     ) ;
          -- The above procedure returns the absneces taken Band wise in
	  -- PL/SQL table. loop through it and sum the required Bands.
	  -- if this proc is called for 4-Year rolling period calcualtion
	  -- sum all the bands i.e. BAND% or NOBAND
	  -- If called from 1-Year Review Date then count only BAND1 days.
         l_proc_Step := 30 ;

	IF p_4_year_rolling_period THEN

	       i := l_absences_taken.FIRST;

           WHILE i IS NOT NULL
           LOOP
              l_proc_step := 40 ;
            IF g_debug THEN
              debug('Band:'||l_absences_taken(i).band);
              debug('Absences taken:'||l_absences_taken(i).duration_per_week);
	    END IF;

	--begin changes for bug 8704523
		-- Made changes according to Profile option (Newly added)
		--'Count Unpaid Absence' Whose value if No then doesn't calculate
		-- OSP NOBAND absences in the count of total absences
		-- as it was originally required in the bug 7585452.
		--hr_utility.set_location('vaibhav I am here : '||fnd_profile.value('BEN_COUNT_UNPAID_ABSENCE'),419);
	    IF (fnd_profile.value('BEN_COUNT_UNPAID_ABSENCE')='N') THEN
		--hr_utility.set_location('vaibhav I am here in N: ',420);
		     IF l_absences_taken(i).band like 'BAND%' --OR
		       --l_absences_taken(i).band like 'NOBAND%'     --bug 7585452, changed by vaibgupt
								     -- NOBAND should not be counted in absences taken

		       THEN
		       l_total_absences_taken:=l_total_absences_taken +
					       l_absences_taken(i).duration_per_week;
		     END IF ;
	    ELSE
		--hr_utility.set_location('vaibhav I am here in Y: ',421);
			IF l_absences_taken(i).band like 'BAND%' OR
		       l_absences_taken(i).band like 'NOBAND%' THEN
		       l_total_absences_taken:=l_total_absences_taken +
					       l_absences_taken(i).duration_per_week;
		     END IF ;
	    END IF;
      -- end changes for bug 8704523


		i := l_absences_taken.NEXT(i);
	   END LOOP ;

         IF g_debug THEN
	   debug('l_total_absences_taken:'||l_total_absences_taken);
         END IF;
	ELSE -- IF p_4_year_rolling_period THEN
               i := l_absences_taken.FIRST;

           WHILE i IS NOT NULL
           LOOP
            l_proc_step := 50 ;
            IF g_debug THEN
              debug('Band:'||l_absences_taken(i).band);
              debug('Absences taken:'||l_absences_taken(i).duration_per_week);
	    END IF;
            IF l_absences_taken(i).band = 'BAND1' THEN
             l_total_absences_taken:=l_absences_taken(i).duration_per_week;
	    END IF;
                i := l_absences_taken.NEXT(i);
	   END LOOP ;


         IF g_debug THEN
	   debug('l_total_absences_taken BAND1:'||l_total_absences_taken);
	 END IF;

	END IF; --IF p_4_year_rolling_period THEN

         l_proc_step := 60 ;

-- PT Changes
         -- Here need to convert the total entitlements into weeks
	 -- then get the absences taken also in weeks
	 -- deduct and convert that into days by multiplying by the
	 -- no of working days in week or 7

       IF g_debug THEN
          debug('Entitled Weeks :'||l_total_entitlement);
       END IF ;

        l_remaining_entitlements := ( l_total_entitlement -
	                            NVL(l_total_absences_taken,0) ) *
				    p_working_days_in_week ;

	-- Round the Remaining Entitlements first to 2 decimals
        --l_remaining_entitlements := ROUND(l_remaining_entitlements,2) ;

        --- then round to
        -- For Full timers always a upper 0.5
	-- For Part-timers round it to lower 0.5
	-- 4.4 for PT = 4. or 4.6 = 4.5
	-- 4.4 for a FT = 4.5 or 4.6 = 5

      /*   IF p_fulltime THEN
           -- For FT round to the upper 0.5
          l_remaining_entitlements :=
	       pqp_utilities.round_value_up_down(
                       p_value_to_round => l_remaining_entitlements
                      ,p_base_value     => g_ft_rounding_precision
                      ,p_rounding_type  => g_ft_entitl_rounding_type
                      ) ;

	 ELSE --  IF p_fulltime THEN
           -- For PT round to the lower 0.5

          l_remaining_entitlements :=
	       pqp_utilities.round_value_up_down(
                       p_value_to_round => l_remaining_entitlements
                      ,p_base_value     => g_pt_rounding_precision
                      ,p_rounding_type  => g_pt_entitl_rounding_type
                      ) ;
         END IF ; --  IF p_fulltime THEN
	*/
         IF g_debug THEN
           debug('Remaining Ent Days :'||l_remaining_entitlements);
	 END IF;
      -- PT Changes cchappid
      exit when l_remaining_entitlements <= 0 ;

     --IF l_remaining_entitlements < 0 THEN
     --   l_remaining_entitlements := 0 ;
     --END IF;
      l_proc_step := 70 ;
      p_total_remaining := p_total_remaining + l_remaining_entitlements ;

      l_total_entitlement := l_total_absences_taken ;

       IF g_debug THEN
        debug(' Rolling Start Date :'||l_rolling_start_date);
       END IF ;


        -- PT Changes
	-- Here we need check if FT or PT and add days accrodingly
	-- From 5 Change it to refer to Default_work_pattern days

      IF p_working_days_in_week < p_standard_work_days_in_week THEN
           -- call add_working_days function here
	   l_proc_step := 75 ;
--        l_rolling_end_date :=
--	    pqp_schedule_calculation_pkg.add_working_days
--              (p_assignment_id     => p_assignment_id
--              ,p_business_group_id => p_business_group_id
--              ,p_date_start        => l_rolling_end_date
--              ,p_days              => l_remaining_entitlements - 1
--              ,p_error_code        => l_error_code
--              ,p_error_message     => l_error_message
--	      ) ;
       l_rolling_end_date :=
          pqp_schedule_calculation_pkg.add_working_days_using_one_wp
               (p_assignment_id          => p_assignment_id
               ,p_business_group_id      => p_business_group_id
               ,p_date_start             => l_rolling_end_date
               ,p_working_days_to_add    => l_remaining_entitlements
               ) ;
       l_rolling_end_date := l_rolling_end_date + 1 ;
      ELSE
      	   l_proc_step := 80 ;
        l_rolling_end_date := l_rolling_end_date + l_remaining_entitlements ;
      END IF;

       IF g_debug THEN
         debug(' Rolling End Date :'||l_rolling_end_date);
       END IF ;
-- PT Changes
     -- check if this exit part needs to be commented out
--      IF p_absence_end_date < l_rolling_end_date THEN
--         l_rolling_end_date := p_absence_end_date ;
--         p_total_remaining := l_rolling_end_date - p_absence_start_date + 1 ;
--	 exit ;
--      END IF;

      -- moved this as we shud recalculate the review date
      -- though the remaining entitlements are 0 but
      -- absence end date is before the review date
      -- exit when l_remaining_entitlements <= 0 ;
       l_total_absences_taken := 0 ;
   end loop ;

      IF p_fulltime THEN
           -- For FT round to the upper 0.5
          p_total_remaining :=
	       pqp_utilities.round_value_up_down(
                       p_value_to_round => p_total_remaining
                      ,p_base_value     => g_ft_rounding_precision
                      ,p_rounding_type  => g_ft_entitl_rounding_type
                      ) ;

	   ELSE --  IF p_fulltime THEN
           -- For PT round to the lower 0.5

          p_total_remaining :=
	       pqp_utilities.round_value_up_down(
                       p_value_to_round => p_total_remaining
                      ,p_base_value     => g_pt_rounding_precision
                      ,p_rounding_type  => g_pt_entitl_rounding_type
                      ) ;
         END IF ; --  IF p_fulltime THEN

      l_proc_step := 90 ;
      IF g_debug THEN
         debug('Review Date :'||l_rolling_end_date);
         debug('Remaining Absence :'||p_total_remaining);
         debug_exit(l_proc_name) ;
      END IF ;

      RETURN l_rolling_end_date ;

EXCEPTION
WHEN OTHERS THEN
  p_total_remaining := l_total_remaining_nc;
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_review_date ;


-- The function returns the Rolling period Start date,
-- based on Rolling period and Rolling End Date.

FUNCTION get_rolling_start_date ( p_rolling_end_date IN DATE
                                 ,p_scheme_period_duration IN NUMBER
                                 ,p_assignment_id      IN NUMBER
                                 ,p_business_group_id         IN NUMBER
   			         ,p_scheme_period_type IN VARCHAR2
                                 ,p_scheme_period_uom  IN VARCHAR2
				 ,p_pl_typ_id          IN NUMBER
				 ,p_4_year_rolling_period IN BOOLEAN
				 ,p_lookup_type           IN VARCHAR2
				 -- lookup type that contains the plan types
				 -- to exendn the rolling period.
                                )  RETURN DATE IS
     l_period_end_date date := p_rolling_end_date ;
     l_period_start_date   date ;
     l_no_pay_days number ;
     l_proc_name  VARCHAR2(61) := g_package_name||'get_rolling_start_date';
     l_proc_step NUMBER(20,10) ;
  BEGIN
    g_debug := hr_utility.debug_enabled ;
   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_rolling_end_date:'||p_rolling_end_date);
    debug('p_scheme_period_duration:'||p_scheme_period_duration);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_scheme_period_type:'||p_scheme_period_type);
    debug('p_scheme_period_uom:'||p_scheme_period_uom);
    debug('p_pl_typ_id:'||p_pl_typ_id);
   END IF;

     l_proc_step := 10 ;
    -- get period end date for the calander period
    l_period_start_date :=
            pqp_absval_pkg.get_scheme_start_date(
               p_assignment_id          => p_assignment_id
              ,p_scheme_period_type     => p_scheme_period_type
              ,p_scheme_period_duration => p_scheme_period_duration
              ,p_scheme_period_uom      => p_scheme_period_uom
              ,p_fixed_year_start_date  => fnd_date.date_to_canonical(
	                                            p_rolling_end_date)
              ,p_balance_effective_date => p_rolling_end_date
              ) ;
    -- get all no pay days in the period (including sickness + maternity
    -- + NOPAY absences extend the period end date by no of nopay days
    -- to find any more nopay days in the extended period.
    -- loop thru the extended period till there are no more nopay days.

    loop
    --Was earlier calling get_no_pay_days of the same package
      l_no_pay_days :=
            pqp_absval_pkg.get_calendar_days_to_extend(
               p_period_start_date        => l_period_start_date
              ,p_period_end_date          => l_period_end_date
	      ,p_assignment_id             => p_assignment_id
	      ,p_business_group_id         => p_business_group_id
	      ,p_pl_typ_id                 => p_pl_typ_id
	      ,p_count_nopay_days => p_4_year_rolling_period
              ,p_plan_types_lookup_type               => p_lookup_type
	      );

     -- For 4 Years
     -- get_no_pay_days should be split into
     -- 1.get any nopay days except the sickness ( = CSS )
     -- i.e. excluding this plan type
     -- 2. get paid maternity i.e. in the date range if there are
     -- any paid maternities
     -- extend the period by sum of 1 + 2
     -- For 1 Year
     -- 1.get any nopay days inc;uding the sickness ( = CSS )
     -- i.e. include this plan type
     -- 2. get paid maternity i.e. in the date range if there
     -- are any paid maternities
     -- extend the period by sum of 1 + 2

       l_proc_step := 20 ;
       IF g_debug THEN
         debug('NOPAY Days are :'||l_no_pay_days);
       END IF ;

      exit when l_no_pay_days <= 0 ;
      -- if no more unpaid days are left in the extended period exit the loop
      l_period_end_date := l_period_start_date ;
      l_period_start_date := l_period_end_date - l_no_pay_days ;
    end loop ;

     l_proc_step := 30 ;
    IF g_debug THEN
      debug_exit(l_proc_name) ;
    END IF ;

    RETURN l_period_start_date ;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

  END get_rolling_start_date;


-- Function returns all non paid absences in the given duration
-- include absences + maternity + NOPAY absences.
FUNCTION get_no_pay_days ( p_rolling_start_date        IN DATE
                          ,p_rolling_end_date          IN DATE
			  ,p_assignment_id             IN NUMBER
			  ,p_business_group_id         IN NUMBER
			  ,p_pl_typ_id                 IN NUMBER
			  ,p_dont_count_css_nopay_days IN BOOLEAN
			  ,p_lookup_type               IN VARCHAR2
			 ) RETURN NUMBER IS
    l_tot_no_pay_days     NUMBER ;
    l_tot_css_no_pay_days NUMBER ;
    l_proc_name  VARCHAR2(61) := g_package_name||'get_no_pay_days';
    l_proc_step  NUMBER(20,10) ;

-- This cursor gets the NOPAID days only
-- for Civil Service Scheme, as in 4 years
CURSOR csr_css_no_pay_days IS
  select NVL(SUM(gda.duration),0)
  from  pqp_gap_daily_absences gda
       ,pqp_gap_absence_plans gap
       ,ben_pl_f pl
  where pl.pl_id = gap.pl_id
    and pl.pl_typ_id = p_pl_typ_id
    and gap.gap_absence_plan_id = gda.gap_absence_plan_id
    and gap.assignment_id = p_assignment_id
    and gda.level_of_pay = 'NOBAND'
    and gda.absence_date between p_rolling_start_date
                           and   p_rolling_end_date ;

  l_pl_typ_id ben_pl_f.pl_typ_id%TYPE ;
BEGIN

   IF g_debug THEN
    debug_enter(l_proc_name);
    debug('p_rolling_start_date:'||p_rolling_start_date);
    debug('p_rolling_end_date:'||p_rolling_end_date);
    debug('p_assignment_id:'||p_assignment_id);
    debug('p_business_group_id:'||p_business_group_id);
    debug('p_pl_typ_id:'||p_pl_typ_id);
   END IF;

-- the number of days to be extended are returned by this function
-- for both 4-year and 1-year we have to roll back by all paid absences
-- and nopiad absences of absences other than CS.
-- only exception being for 1-year we have to extend even the NOPAID days
-- of CS.
-- So assume that the plan types are stored for all the absence categories
-- that needs to be considered in extending in a lookup
-- PQP_GAP_PLAN_TYPES_TO_EXTEND. This is required as there is no UI option
-- yet to support the selection of such plan types.
-- if it is for 4-year return the sum of those plan types absences
-- if for 1-year include even the CS NOPAID days and return.

   l_proc_step := 10 ;

   OPEN csr_get_days_to_extend (
             p_business_group_id => p_business_group_id
            ,p_assignment_id  => p_assignment_id
            ,p_rolling_start_date => p_rolling_start_date
            ,p_rolling_end_date => p_rolling_end_date
            ,p_lookup_type => p_lookup_type --'PQP_GAP_PLAN_TYPES_TO_EXTEND'
	    ) ;
   FETCH csr_get_days_to_extend INTO l_tot_no_pay_days ;
   CLOSE csr_get_days_to_extend ;

   l_proc_step := 20 ;
   -- p_dont_chk_pl_typ_id should have FALSE for 1-year rolling period
   -- and TRUE for 4-year rolling period
   IF NOT p_dont_count_css_nopay_days THEN

      l_proc_step := 30 ;

      OPEN csr_css_no_pay_days ;
      FETCH csr_css_no_pay_days INTO l_tot_css_no_pay_days ;
      CLOSE csr_css_no_pay_days ;

      l_tot_no_pay_days := l_tot_no_pay_days + l_tot_css_no_pay_days ;

      l_proc_step := 40 ;
      IF g_debug THEN
        debug('4-Year Rolling Period no pay days:'||l_tot_no_pay_days);
      ENd IF;

   END IF;

    IF g_debug THEN
      debug('No Pay Days:'||l_tot_no_pay_days);
      debug_exit(l_proc_name) ;
    END IF ;

   RETURN NVL(l_tot_no_pay_days,0) ;

EXCEPTION
WHEN OTHERS THEN
    IF SQLCODE <> hr_utility.HR_ERROR_NUMBER THEN
      pqp_utilities.debug_others
        (l_proc_name
        ,l_proc_step
        );
      IF g_debug THEN
        debug('Leaving: '||l_proc_name,-999);
      END IF;
      fnd_message.raise_error;
    ELSE
      RAISE;
    END IF;

END get_no_pay_days ;

END pqp_gb_css_daily_absences ;

/
