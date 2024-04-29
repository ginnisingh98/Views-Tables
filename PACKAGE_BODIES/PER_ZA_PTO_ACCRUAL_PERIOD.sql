--------------------------------------------------------
--  DDL for Package Body PER_ZA_PTO_ACCRUAL_PERIOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_PTO_ACCRUAL_PERIOD" as
/* $Header: perzaapl.pkb 120.5.12010000.2 2009/07/21 07:50:23 rbabla ship $ */
/* ======================================================================
REM Change List:
REM ------------
REM
REM Name           Date       Version Bug     Text
REM -------------- ---------- ------- ------- ------------------------------------+
REM R. Kingham     15-MAR-00  110.0           Initial Version
REM J.N. Louw      24-Aug-00  115.0           Updated for ZAPatch11i.01
REM L.Kloppers     21-Dec-00  115.1           Put 'create...' on one line
REM P.Vaish        07-JUL-02  115.2           Changed to calculate currect
REM                                           PTO Carry Over as per Legislative Rules.
REM P.Vaish        15-JUL-02  115.3           Changed to calculate the
REM                                           PTO Carry Over for each period correctly.
REM V.Kannan       17-MAR-03  115.4  2848607  Removed the rounding of l_Accrual_Rate in
REM                                           za_pto_annleave_period_loop,which caused the
REM                                           number of days accrued per Period inaccurate.
REM R.Pahune       14-Aug-03  115.5               Added Procedure
REM					      ZA_PTO_CARRYOVER_RESI_VALUE
REM					      for the bug no 2932073
REM					      if the carry over is -ve made it 0
REM					      along with earlier ZA specific
REM					      requirements. (code from version
REM					      115.20.1158.2 by lklopper)
REM A. Mahanty     05-MAY-05  115.7  4293298  Modified procedure ZA_PTO_CARRYOVER_RESI_VALUE
REM                                           to have correct carryover and
REM                                           net entitlement value when there is
REM                                           negative net entitlement.
REM Kaladhaur P    09-MAR-06  115.8  5043294  Modified procedure ZA_PTO_SICKLEAVE_PERIOD_LOOP
REM                                           to have correct Total Accrued Sick Leave.
REM A. Mahanty     22-SEP-06  115.9           Modified the procedure ZA_PTO_CARRYOVER_RESI_VALUE.
REM                                           The other contributions(leave adjustments) need to
REM                                           be subtracted before the residual value is calculated.
REM                                           The adjustments in the current accrual cycle must not
REM                                           be forfeited.
REM R. Babla       26-NOV-07  115.12 6617789  Modified function ZA_PTO_SICKLEAVE_PERIOD_LOOP to
REM                                           calculate the accrual of 1 for 26 working days for
REM                                           employee's first six months of employment.
   ==============================================================================*/

/* ======================================================================
   Name    : ZA_PTO_ANNLEAVE_PERIOD_LOOP
   Purpose : This function is called by the ZA_PTO_ANNUAL_LEAVE_MONTHLY_ACCRUAL
             formula, and replaces the Sub-Accrual formula which calculated
             total PTO accrued per period.
   Returns : Total Accrued entitlement
   ======================================================================*/
function ZA_PTO_ANNLEAVE_PERIOD_LOOP         (p_Assignment_ID IN  Number
                                             ,p_Plan_ID       IN  Number
                                             ,p_Payroll_ID    IN  Number
                                             ,p_calculation_date    IN  Date)
return number is

    l_CSDate                    date;
    l_Period_SD                 date;
    l_Period_ED                 date;
    l_Last_Period_SD            date;
    l_Last_Period_ED            date;
    l_Beginning_Calc_Year_SD    date;
    l_Total_Accrued_PTO         number := 0;
    l_Pay_Periods_Year          number;
    l_Period_Accrued_PTO        number;
    l_Accrual_Rate              number;
    l_Period_Others             number;
    l_Amount_Over_Ceiling       number;
    l_Annual_Rate               number := 0;
    l_Upper_Limit               number := 0;
    l_Ceiling                   number := 0;
    l_Years_Service             number;
    l_Absence                   number;
    l_Carryover                 number;
    l_Other                     number;
    l_Continue_Processing_Flag  boolean := true;
    l_Error                     number;
    l_Acc_Freq                  char;
    l_Acc_Mult                  number;
    l_Net_PTO                   number;
    /*  - P.Vaish - Defined for Bug No. - 2266289 - */
    l_calculation_year          date;
    l_last_start_period         date;
    l_last_end_period           date;
    l_six_month_current         date;
    l_Left_Over                 number := 0;
    l_last_period		date;
    l_anniversary_date		date;
    l_diff			number := 0;
begin
/*  Get global variables.  */
    l_Last_Period_SD         := per_formula_functions.get_date('LAST_PERIOD_SD');
    l_Last_Period_ED         := per_formula_functions.get_date('LAST_PERIOD_ED');
    l_CSDate                 := per_formula_functions.get_date('CONTINUOUS_SERVICE_DATE');
    l_Beginning_Calc_Year_SD := per_formula_functions.get_date('BEGINNING_OF_CALCULATION_YEAR');
    l_Pay_Periods_Year       := per_formula_functions.get_number('PAYROLL_YEAR_NUMBER_OF_PERIODS');
    l_Acc_Freq               := per_formula_functions.get_text('ACCRUING_FREQUENCY');
    l_Acc_Mult               := per_formula_functions.get_number('ACCRUING_MULTIPLIER');

    hr_utility.set_location('ZA_PTO_ANNLEAVE_PERIOD_LOOP', 26);

     /*  - P.Vaish - Defined for Bug No. - 2266289 - */
     l_diff := LAST_DAY(l_Last_Period_ED) - l_Last_Period_ED + 1;

     IF (((l_Acc_Freq = 'W') AND (l_diff < 7))
     OR (((l_Acc_Freq = 'M') OR (l_Acc_Freq = 'D')) AND (l_diff <= l_Acc_Mult))) THEN
	 l_last_period := l_Last_Period_ED + l_diff;
     ELSE
	 l_last_period := l_Last_Period_ED;
     END IF;

     IF (months_between(l_Last_Period,l_Beginning_Calc_Year_SD) >= 12 ) THEN
	 hr_utility.trace('Setting l_calculation_year to l_Beginning_Calc_Year_SD + 1 ');
	 l_calculation_year := add_months(l_Beginning_Calc_Year_SD,12);
     ELSE
	 hr_utility.trace('Setting l_calculation_year to l_Beginning_Calc_Year_SD');
	 l_calculation_year := l_Beginning_Calc_Year_SD;
     END IF;

     IF to_char(l_CSDate,'DDMM') = '2902' THEN
	l_last_start_period := to_date('0103' || to_char(l_calculation_year,'YYYY'),'DDMMYYYY');
     ELSE
	l_last_start_period := to_date(to_char(l_CSDate,'DDMM') || to_char(l_calculation_year,'YYYY'),'DDMMYYYY');
     END IF;

     l_anniversary_date := l_last_start_period;

     IF l_last_start_period > l_calculation_year THEN
	 l_last_end_period   := add_months(l_last_start_period,-12);
	 l_last_start_period := add_months(l_last_start_period,-18);
	 l_six_month_current := add_months(l_last_end_period,6);
     ELSE
	 l_last_end_period   := l_last_start_period;
	 l_last_start_period := add_months(l_last_start_period,-6);
	 l_six_month_current := add_months(l_last_end_period,6);
     END IF;

     l_Years_Service := Floor(Months_Between(l_calculation_year,l_CSDate) / 12);

     IF ((l_Years_Service > 0) and (l_six_month_current >= l_Last_Period_ED)) THEN
  	   hr_utility.trace('Before Six Month');
	   l_Left_Over := per_accrual_calc_functions.GET_CARRY_OVER(p_Assignment_id, p_Plan_id, (l_last_end_period + 1), l_last_start_period) +
		 per_accrual_calc_functions.GET_OTHER_NET_CONTRIBUTION(p_Assignment_id, p_Plan_id, (l_last_end_period + 1), l_last_start_period) -
		 per_accrual_calc_functions.GET_ABSENCE(p_Assignment_id, p_Plan_id, l_last_end_period, l_last_start_period);

	   IF l_Left_Over < 0 THEN
		l_Left_Over := 0;
	   END IF;

	   l_diff := p_calculation_date - l_anniversary_date;

	   IF (l_Left_Over > 0) THEN
	        IF (l_Acc_Freq = 'M') THEN
			IF ((l_diff >= 0) AND (l_diff < (add_months(l_anniversary_date,l_Acc_Mult) - l_anniversary_date))) THEN
				l_Continue_Processing_Flag := FALSE;
			END IF;
		ELSIF (l_Acc_Freq = 'W') THEN
			IF ((l_diff >= 0) AND (l_diff < (7 * l_Acc_Mult))) THEN
				l_Continue_Processing_Flag := FALSE;
			END IF;
		END IF;
	   END IF;

	   IF ((to_char(p_calculation_date,'DDMM') = to_char(l_CSDate - 1,'DDMM')) AND NOT l_Continue_Processing_Flag) THEN
		l_Continue_Processing_Flag := TRUE;
	   END IF;
      ELSIF ((l_Years_Service > 0) and (l_six_month_current < l_Last_Period_ED)) THEN
	   hr_utility.trace('After Six Month');
	   IF (per_utility_functions.get_accrual_band(p_Plan_ID, l_Years_Service) = 0 ) THEN
		l_Left_Over := per_formula_functions.get_number('MAX_CARRY_OVER');
		l_Annual_Rate := 0;
		l_Upper_Limit := 0;
		l_Ceiling     := 0;
	   ELSE
		l_Left_Over := 0;
	   END IF;
      ELSE
	   l_Left_Over := 0;
      END IF;
    /**/

  hr_utility.set_location('Before LOOP', 27);

  while l_Continue_Processing_Flag loop
      l_Period_SD := per_formula_functions.get_date('PERIOD_SD');
      l_Period_ED := per_formula_functions.get_date('PERIOD_ED');
      l_Years_Service := Floor(Months_Between(l_Period_ED,l_CSDate) / 12);

/* Accrual bands based on length of service, but could also use grades   */
      if   l_Upper_Limit = 0
      or  (l_Years_service >= l_Upper_Limit) then
           if  (per_utility_functions.get_accrual_band(p_Plan_ID, l_Years_Service) = 0 ) then
               l_Annual_Rate := per_formula_functions.get_number('ANNUAL_RATE');
               l_Upper_Limit := per_formula_functions.get_number('UPPER_LIMIT');
               l_Ceiling     := per_formula_functions.get_number('CEILING');
           else
               exit;
           end if;
      end if;
      --Bug:2848607.
      l_Accrual_Rate := l_Annual_Rate / l_Pay_Periods_Year;

      l_Period_Accrued_PTO := l_Accrual_Rate;

/* Extract any absence, carry over etc for the year in question          */
      l_Absence   := per_accrual_calc_functions.GET_ABSENCE(p_Assignment_id, p_Plan_id, l_Period_ED, l_Beginning_Calc_Year_SD);

    /*  - P.Vaish - Set for Bug No. - 2266289 - */
      l_CarryOver := l_Left_Over;
      l_Other     := per_accrual_calc_functions.GET_OTHER_NET_CONTRIBUTION(p_Assignment_id, p_Plan_id, l_Period_ED, l_Beginning_Calc_Year_SD);
      l_Period_Others := l_CarryOver + l_Other - l_Absence;
      l_Net_PTO := l_Total_Accrued_PTO + l_Period_Accrued_PTO + l_Period_Others;

/* Only accrue if PTO < CEILING      */
      if  l_Ceiling > 0 then
          if  ((l_Net_PTO - l_Ceiling) > l_Left_Over) then
              l_Amount_Over_Ceiling := l_Net_PTO - l_Ceiling - l_Left_Over;
              if  l_Amount_Over_Ceiling > l_Period_Accrued_PTO then
                  l_Period_Accrued_PTO := 0;
              else
                  l_Period_Accrued_PTO := l_Period_Accrued_PTO - l_Amount_Over_Ceiling;
              end if;
          end if;
      end if;
      l_Total_Accrued_PTO := l_Total_Accrued_PTO + l_Period_Accrued_PTO;

/* End loop if final period and set globals to next payroll period  */
      if  l_Period_SD >= l_Last_Period_SD then
          l_Continue_Processing_Flag := false;
      else
          l_Period_ED := l_Period_ED + 1;
          l_error := per_utility_functions.GET_PERIOD_DATES( l_Period_ED
                                                            ,l_Acc_Freq
                                                            ,l_Beginning_Calc_Year_SD
                                                            ,l_Acc_Mult);
          l_error := per_formula_functions.set_date('PERIOD_SD',
                                             per_formula_functions.get_date('PERIOD_START_DATE'));
          l_error := per_formula_functions.set_date('PERIOD_ED',
                                             per_formula_functions.get_date('PERIOD_END_DATE'));
          l_Continue_Processing_Flag := true;
      end if;
  end loop;

  l_error := per_formula_functions.set_number('TOTAL_ACCRUED_PTO', l_Total_Accrued_PTO);

  Return l_Total_Accrued_PTO;

end ZA_PTO_ANNLEAVE_PERIOD_LOOP;
--
/* ======================================================================
   Name    : ZA_PTO_SICKLEAVE_PERIOD_LOOP
   Purpose : This function is called by the ZA_PTO_SICK_LEAVE_ACCRUAL
             formula, and replaces the Sub-Accrual formula which calculated
             total Sick PTO accrued per period.
   Returns : Total Sick PTO Accrued entitlement
   ======================================================================*/
function ZA_PTO_SICKLEAVE_PERIOD_LOOP       (p_Assignment_ID IN  Number
                                            ,p_Plan_ID       IN  Number
                                            ,p_Payroll_ID    IN  Number)
return number is
    l_Beginning_Calc_Year_SD    date;
    l_CSDate                    date;
    l_Period_SD                 date;
    l_Period_ED                 date;
    l_Last_Period_SD            date;
    l_Last_Period_ED            date;
    l_Total_Accrued_PTO         number := 0;
    l_Continue_Processing_Flag  boolean := true;
    l_Accrual_Rate              number;
    l_Error                     number;
    l_Acc_Freq                  char;
    l_Acc_Mult                  number;
    l_daysoff                   number;
    l_proc                      varchar2(80) := 'PER_ZA_PTO_ACCRUAL_PERIOD.ZA_PTO_SICKLEAVE_PERIOD_LOOP';
    l_calc_date                 date;
    l_totdays                   number:=0;
    l_daysoff1                  number:=0;
    l_month_PTO                 number:=0;
    l_prev_period_SD            date;
    l_prev_period_ED            date;

begin
    l_Beginning_Calc_Year_SD := per_formula_functions.get_date('BEGINNING_OF_CALCULATION_YEAR');
    l_Last_Period_SD := per_formula_functions.get_date('LAST_PERIOD_SD');
    l_Last_Period_ED := per_formula_functions.get_date('LAST_PERIOD_ED');
    l_CSDate         := per_formula_functions.get_date('CONTINUOUS_SERVICE_DATE');
 -- l_Accrual_Rate   := per_formula_functions.get_number('ACCRUAL_RATE');
    l_Accrual_Rate   := per_formula_functions.get_number('ZA_SICK_LEAVE_ACCRUAL_RATE');
    l_Acc_Freq               := per_formula_functions.get_text('ACCRUING_FREQUENCY');
    l_Acc_Mult               := per_formula_functions.get_number('ACCRUING_MULTIPLIER');
    --Added for Bug 8192694
    l_calc_date              := per_formula_functions.get_date('CALC_DATE');

    hr_utility.set_location(l_proc,5);
    hr_utility.trace('l_Accrual_Rate: '||to_char(l_Accrual_Rate));

    --Added for Bug 8192694
    /* l_calc_date is populated only when SICK LEAVE ACCRUAL formulaes delivered through patch 8192694
       is used. So if copy of previous formula is created, then it may lead to endless loop. Hence If condition
       calculates 1 leave for 26 working days if this variable is set, else the employee will accrue a percentage
       of a leave based on the days worked (previous logic)*/
    IF l_calc_date IS NOT NULL then
        while l_Continue_Processing_Flag loop
        /*Get the first period start and end dates */
                  l_Period_SD := per_formula_functions.get_date('PERIOD_SD');
                  l_Period_ED := per_formula_functions.get_date('PERIOD_ED');

                 --Calculate the days off in the particular period
                  l_daysoff :=PER_ZA_ABS_DURATION.ZA_DAYSOFF(l_Period_SD,l_Period_ED);
                  hr_utility.trace('l_daysoff: '||to_char(l_daysoff));
		  --Calculate the total working days in the period
                  l_totdays :=((l_Period_ED - l_Period_SD)+1) - l_daysoff;

                  hr_utility.trace('l_totdays:'||to_char(l_totdays));
                  hr_utility.trace('l_Period_ED:'||to_char(l_Period_ED,'dd-mon-yyyy'));
                  hr_utility.trace('l_calc_date:'||to_char(l_calc_date,'dd-mon-yyyy'));

                  /* If the total working days are less than 26 in the particular period, then increase the period
		  end date and loop until total working days are 26*/
                  while l_totdays < 26
		  loop
                      l_Period_ED :=l_Period_ED + 1;
                      if l_Period_ED >l_calc_date then

                         l_Continue_Processing_Flag := false;
                         l_month_PTO:=0;
                         hr_utility.trace('l_Period_ED >=l_calc_date');
                         l_error := per_formula_functions.set_date('PERIOD_SD',
                                             l_prev_period_SD);
                         l_error := per_formula_functions.set_date('PERIOD_ED',
                                             l_prev_period_ED);
                         exit;
                     else
                        l_daysoff1:=PER_ZA_ABS_DURATION.ZA_DAYSOFF(l_Period_SD,l_Period_ED);
                        l_totdays :=((l_Period_ED - l_Period_SD)+1) - l_daysoff1;
                        hr_utility.set_location('l_Period_ED:'||to_char(l_Period_ED,'dd-mon-yyyy'),10);
                        hr_utility.set_location('l_Period_SD:'||to_char(l_Period_SD,'dd-mon-yyyy'),10);
                        hr_utility.set_location('l_daysoff1:'||to_char(l_daysoff1),10);
                        hr_utility.set_location('l_totdays:'||to_char(l_totdays),10);
                        l_Continue_Processing_Flag := true;
                     end if;
                  end loop;

                  /* If total working days are 26, then set the PERIOD_SD and PERIOD_ED to next period dates*/
                  if l_totdays=26 then
                    l_Period_ED := l_Period_ED + 1;
                    l_month_PTO:=1;
                    l_prev_period_SD:=l_Period_SD;
                    l_prev_period_ED:=l_Period_ED -1;
                    l_error := per_formula_functions.set_date('PERIOD_SD',
                                             l_Period_ED);
                    l_error := per_formula_functions.set_date('PERIOD_ED',
                                             l_Period_ED + 31);
                  end if;

                  l_Total_Accrued_PTO:=l_Total_Accrued_PTO+l_month_PTO;
                  hr_utility.set_location('l_month_PTO:'||to_char(l_month_PTO),11);
                  hr_utility.set_location('l_Total_Accrued_PTO:'||to_char(l_Total_Accrued_PTO),11);
        end loop;
   -- End changes for Bug 8192694
    else
        while l_Continue_Processing_Flag loop
                 l_Period_SD := per_formula_functions.get_date('PERIOD_SD');
                 l_Period_ED := per_formula_functions.get_date('PERIOD_ED');

                 -- Bug 5043294; Removed comments and unnessary if/else logic
                 -- Calculating the working days in the period
                 l_daysoff :=PER_ZA_ABS_DURATION.ZA_DAYSOFF(l_Period_SD,l_Period_ED);
                 hr_utility.trace('l_daysoff: '||to_char(l_daysoff));
                 l_Total_Accrued_PTO := round(l_Total_Accrued_PTO + (((l_Period_ED - l_Period_SD)+1) - l_daysoff)/l_Accrual_Rate , 2);

                 if  l_Period_SD = l_Last_Period_SD then
                   l_Continue_Processing_Flag := false;
                 else
                    l_Period_ED := l_Period_ED + 1;
                    l_error := per_utility_functions.GET_PERIOD_DATES( l_Period_ED
                                                            ,l_Acc_Freq
                                                            ,l_Beginning_Calc_Year_SD
                                                            ,l_Acc_Mult);
                    l_error := per_formula_functions.set_date('PERIOD_SD',
                                             per_formula_functions.get_date('PERIOD_START_DATE'));
                    l_error := per_formula_functions.set_date('PERIOD_ED',
                                             per_formula_functions.get_date('PERIOD_END_DATE'));
                    l_Continue_Processing_Flag := true;

                end if;
        end loop;
    END if;
    l_error := per_formula_functions.set_number('TOTAL_ACCRUED_PTO', l_Total_Accrued_PTO);
    Return l_Total_Accrued_PTO;

end ZA_PTO_SICKLEAVE_PERIOD_LOOP;
--
/* Start of 2932073 and 2878657 */

/* ======================================================================
   Name    : ZA_PTO_CARRYOVER_RESI_VALUE
   Purpose : This function is called by the pto_carry_over_for_asg for the
             South Africa Localisation ('ZA'). And it calculate the Carry
	     over value and residual value.
	     If the carry over is -ve it will be set to ZERO (0).
   Returns : residula value and carry over value.
   ======================================================================*/

procedure ZA_PTO_CARRYOVER_RESI_VALUE (p_assignment_id			IN Number
				  ,p_plan_id				IN Number
				  ,l_payroll_id				IN Number
				  ,p_business_group_id                  IN Number
				  ,l_effective_date			IN Date
				  ,l_total_accrual			IN Number
				  ,l_net_entitlement			IN number
				  ,l_max_carryover			IN Number
				  ,l_residual				OUT NOCOPY Number
				  ,l_carryover				OUT NOCOPY Number) Is

  -- Declaring local variables
  l_start_date            date;
  l_end_date            date;
  l_dummy13            date;
  l_net_entitlement2   number;
  l_effective_date2    date;
  l_total_accrual2     number;
  l_proc    varchar2(80) := 'PER_ZA_PTO_ACCRUAL_PERIOD.ZA_PTO_CARRYOVER_RESI_VALUE';
  l_carryover_pre     number;   --Bug 4293298
  l_Beginning_Calc_Year   date;
  l_other2 number;

Begin
       /*l_effective_date2 := l_effective_date + 1;

       -- Get total accrual on above date, it will only return non-zero where the
       -- carry over runs for a ZA HRMS "Semi-annual" leave cycle anniversary
       per_accrual_calc_functions.Get_Net_Accrual (
         P_Assignment_ID          => p_assignment_id
        ,P_Plan_ID                => p_plan_id
        ,P_Payroll_ID             => l_payroll_id
        ,P_Business_Group_ID      => p_business_group_id
        ,P_Assignment_Action_Id   => -1
        ,P_Accrual_Start_Date     => null
        ,P_Accrual_Latest_Balance => null
        ,P_Calculation_Date       => l_effective_date2
        ,P_Start_Date             => l_dummy11
        ,P_End_Date               => l_dummy12
        ,P_Accrual_End_Date       => l_dummy13
        ,P_Accrual                => l_total_accrual2
        ,P_Net_Entitlement        => l_net_entitlement2
       );

       hr_utility.set_location(l_proc, 10);
       hr_utility.trace('l_total_accrual2: '||to_char(l_total_accrual2));
       hr_utility.trace('l_net_entitlement2: '||to_char(l_net_entitlement2)); */

       /* The above code is commented so that to avoid the calculation
	 l_net_entitlement > l_max_carryover while fixing the bug 2932073 */
       hr_utility.set_location(l_proc,5);
       hr_utility.trace('p_assignment_id: '||to_char(p_assignment_id));
       hr_utility.trace('p_plan_id: '||to_char(p_plan_id));
       hr_utility.trace('l_payroll_id: '||to_char(l_payroll_id));
       hr_utility.trace('l_effective_date: '||to_char(l_effective_date));
       hr_utility.trace('l_total_accrual: '||to_char(l_total_accrual));
       hr_utility.trace('l_net_entitlement: '||to_char(l_net_entitlement));
       hr_utility.trace('l_max_carryover: '||to_char(l_max_carryover));

      if l_net_entitlement <= l_max_carryover then
       --
         hr_utility.set_location(l_proc,10);
        l_Beginning_Calc_Year := per_formula_functions.get_date('BEGINNING_OF_CALCULATION_YEAR');
        --
          IF (l_net_entitlement <= 0
               AND to_char(l_effective_date + 1,'MM') <> to_char(l_Beginning_Calc_Year,'MM')
              )THEN
          -- Bug 4293298 in case net entitlement is -ve and the carryover process is not for the
          -- end of the annual accrual period.
	      l_carryover := 0;
          --get the carryover in the previous half of the accrual year
            l_carryover_pre := per_accrual_calc_functions.get_carry_over
                                (
                                 p_assignment_id => p_assignment_id,
                                 p_plan_id => p_plan_id,
                                 p_start_date => (l_effective_date-30),
                                 p_calculation_date => (l_effective_date-1));
             hr_utility.trace('l_carryover_pre: '||to_char(l_carryover_pre));
             IF l_carryover_pre < 0 THEN
                   l_carryover := l_carryover_pre;
             END IF ;
          hr_utility.set_location(l_proc,50);
	  ELSE
             l_carryover := round(l_net_entitlement, 3);
             hr_utility.set_location(l_proc,60);
	  END IF;
          --End for bug no 2932073 14-Aug-2003
	 l_residual  := 0;
       --
      else
       --
          l_effective_date2 := l_effective_date + 1;

       -- Get total accrual on above date, it will only return non-zero where the
       -- carry over runs for a ZA HRMS "Semi-annual" leave cycle anniversary
         per_accrual_calc_functions.Get_Net_Accrual (
		 P_Assignment_ID          => p_assignment_id
		,P_Plan_ID                => p_plan_id
		,P_Payroll_ID             => l_payroll_id
		,P_Business_Group_ID      => p_business_group_id
		,P_Assignment_Action_Id   => -1
		,P_Accrual_Start_Date     => null
		,P_Accrual_Latest_Balance => null
		,P_Calculation_Date       => l_effective_date2
		,P_Start_Date             => l_start_date
		,P_End_Date               => l_end_date
		,P_Accrual_End_Date       => l_dummy13
		,P_Accrual                => l_total_accrual2
		,P_Net_Entitlement        => l_net_entitlement2
	       );

        -- The other contributions(leave adjustments) need to be subtracted before the residual value
        -- is calculated. The adjustments in the current accrual cycle must not be forfeited.
        -- Only for semi-annual run.
        l_Beginning_Calc_Year := per_formula_functions.get_date('BEGINNING_OF_CALCULATION_YEAR');

       IF to_char(l_effective_date + 1,'MM') <> to_char(l_Beginning_Calc_Year,'MM') THEN
          hr_utility.set_location(l_proc, 15);
          l_other2 := per_accrual_calc_functions.Get_Other_Net_Contribution(
                         P_Assignment_ID    => p_assignment_id
                        ,P_Plan_ID          => p_plan_id
                        ,p_start_date       => l_start_date
                        ,p_calculation_date => l_end_date
                        );
        ELSE
          l_other2 := 0;
        END IF;
--
       hr_utility.set_location(l_proc, 20);
       hr_utility.trace('l_total_accrual2: '||to_char(l_total_accrual2));
       hr_utility.trace('l_net_entitlement2: '||to_char(l_net_entitlement2));
       hr_utility.trace('l_other2: '||to_char(l_other2));
       hr_utility.trace('l_start_date: '||to_char(l_start_date));
       hr_utility.trace('l_end_date: '||to_char(l_end_date));
       hr_utility.trace('l_Beginning_Calc_Year: '||to_char(l_Beginning_Calc_Year));
       hr_utility.trace('l_effective_date: '||to_char(l_effective_date));
--
         hr_utility.set_location(l_proc, 30);
         l_carryover := round(l_max_carryover, 3);
         l_residual  := round((l_net_entitlement - l_max_carryover - l_total_accrual2 - l_other2), 3);
         --Bug 4293298 if residual value is -ve ..then it is set to 0
         IF l_residual < 0 THEN
         l_residual := 0;
         END IF ;
       --
       end if;
       hr_utility.set_location(l_proc, 40);
       hr_utility.trace('l_carryover: '||to_char(l_carryover));
       hr_utility.trace('l_residual: '||to_char(l_residual));


End ZA_PTO_CARRYOVER_RESI_VALUE;

/* End of 2932073 and 2878657 */

--
end PER_ZA_PTO_ACCRUAL_PERIOD;

/
