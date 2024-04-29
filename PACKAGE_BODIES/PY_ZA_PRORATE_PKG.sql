--------------------------------------------------------
--  DDL for Package Body PY_ZA_PRORATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_PRORATE_PKG" as
/* $Header: pyzapror.pkb 120.4.12010000.2 2009/04/29 07:00:44 rbabla ship $ */
/* +=======================================================================+
   | Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA |
   |                       All rights reserved.                            |
   +=======================================================================+

   PRODUCT
      Oracle Payroll - ZA Localisation

   NAME
      py_za_prorate_pkg.pkb

   DESCRIPTION
      This package contains functions that can be used in proration
      functionality.

   PUBLIC FUNCTIONS
      Descriptions in package header
      get_workdays
      pro_rate
      pro_rate_days

   NOTES
      .

   MODIFICATION HISTORY
      Person      Date(DD-MM-YYYY)   Version   Comments
      ---------   ----------------   -------   -----------------------------
      J.N. Louw   07-09-2001         115.2     Updated pro_rate_days
      A.Stander   19-11-1998         110.0     Initial version
*/

-------------------------------------------------------------------
function get_workdays(period_1 IN date,
                      period_2 IN date)
                      return number is
working_days      number;
days              varchar2(10);
next_date         date;

BEGIN
 working_days := 0;
 next_date  := period_1;
 BEGIN
 loop

 exit when next_date > period_2;

 select to_char(next_date, 'DAY') into days from dual;



 If rtrim(days) in ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY') then
    working_days := working_days + 1;
 end if;
 next_date := next_date + 1;
 end loop;
 return(working_days);
-- pragma restrict_references(get_workdays,WNDS); -- Bug 4543522
 END;
END;
-----------------------------------------------------------------------
FUNCTION pro_rate(payroll_action_id  IN number
                  ,assignment_id     IN number)
                 RETURN NUMBER IS

        CURSOR   c2 (x_payroll_action_id number, x_assignment_id number) is
	                       select effective_start_date,effective_end_date
                                 from per_assignments_f
                                where payroll_id    = (select payroll_id
                                                         from pay_payroll_actions
                                                        where payroll_action_id = x_payroll_action_id)
                                  and assignment_id = x_assignment_id  --Modified for Bug 8464020
                               order by effective_start_date;


      eff_start_date       DATE;
      start_date           DATE;
      end_date             DATE;
      eff_end_date         DATE;
      total_days           NUMBER;
      days_worked          NUMBER;
      total_days_worked    NUMBER;
      pay_fraction         NUMBER;
      flactuation          NUMBER;
      x_time_period_id     NUMBER;
      x_payroll_action_id  NUMBER;
      x_assignment_id      NUMBER;


     BEGIN
            pay_fraction      := 0;
            days_worked       := 0;
            total_days_worked := 0;
            x_payroll_action_id := payroll_action_id;
	    x_assignment_id     := assignment_id;

            BEGIN
              select time_period_id
                into x_time_period_id
                from pay_payroll_actions
               where payroll_action_id = x_payroll_action_id;

              exception
                 when no_data_found then
                      x_time_period_id := 0;

            END;
            BEGIN
                               SELECT  start_date,end_date
                                 into  start_date,end_date
                                 from  per_time_periods
                                where  payroll_id     = (select payroll_id
                                                         from pay_payroll_actions
                                                        where payroll_action_id = x_payroll_action_id)
                                  and  time_period_id = x_time_period_id;



            select get_workdays(start_date,end_date) into
                       total_days from dual;
            END;

            BEGIN
            OPEN C2 (x_payroll_action_id,x_assignment_id);
            LOOP
            FETCH c2 into eff_start_date,eff_end_date;
            exit when c2%NOTFOUND;

            if  eff_start_date < start_date  and
                eff_end_date >=  start_date  and
                eff_end_date <=  end_date   then

                select get_workdays(start_date,eff_end_date) into
                       days_worked from dual;

            end if;

            if  eff_start_date >= start_date and
                eff_end_date   <= end_date   then
                select get_workdays(eff_start_date,eff_end_date) into
                       days_worked from dual;

            end if;

            if eff_start_date >= start_date and
               eff_start_date <= end_date   and
               eff_end_date   > end_date    then
               select get_workdays(eff_start_date,end_date) into
                      days_worked from dual;
            end if;

                 total_days_worked := total_days_worked + days_worked;
                 days_worked := 0;
            END LOOP;

               IF total_days < 22 then
                  flactuation := 21.6666 - total_days;
                  total_days_worked := total_days_worked + flactuation;
               END IF;

               IF total_days  = 23 then
                  if total_days_worked  = 22 then
                     total_days_worked := 21;
                  end if;
                  if total_days_worked = 21 then
                     total_days_worked := 20.6666;
                  end if;
               END IF;

               IF total_days = total_days_worked then
                  total_days_worked := 21.6666;
               end if;
             pay_fraction := total_days_worked / 21.6666;
        END;
                  if pay_fraction = 0 then
                     pay_fraction := 1;
                  end if;

                  RETURN pay_fraction;

      END ;

----------------------------------------------------------------------


-------------------------------------------------------------------------------
-- pro_rate_days
--    Returns the number of days worked in the pay period
--    as a fraction of the total number of days in the period
-------------------------------------------------------------------------------
FUNCTION pro_rate_days
   ( PAYROLL_ACTION_ID IN NUMBER
   , ASSIGNMENT_ID     IN NUMBER
   )
RETURN NUMBER AS
   -------------------------------------------------
   -- Cursor c_Timeperiod
   --    Returns the start and end dates of a period
   --    for a payroll_action_id
   -------------------------------------------------
   CURSOR c_Timeperiod(
      p_ppa_id IN pay_payroll_actions.payroll_action_id%TYPE
      )
   IS
      SELECT ptp.start_date
           , ptp.end_date
        FROM per_time_periods ptp
           , pay_payroll_actions ppa
       WHERE ppa.payroll_action_id = p_ppa_id
         AND ptp.time_period_id = ppa.time_period_id;
   -------------------------------------------
   -- Cursor c_Assignment
   --    Returns the start and end dates of an
   --    assignment
   -------------------------------------------
   CURSOR c_Assignment(
      p_asg_id IN per_all_assignments_f.assignment_id%TYPE
      )
   IS
      SELECT min(asg.effective_start_date) start_date
           , max(asg.effective_end_date)   end_date
        FROM per_assignment_status_types past
           , per_all_assignments_f       asg
       WHERE asg.assignment_id = p_asg_id
         AND asg.assignment_status_type_id = past.assignment_status_type_id
         AND past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

   ------------
   -- Variables
   ------------
   l_Pdates c_Timeperiod%ROWTYPE;
   l_Adates c_Assignment%ROWTYPE;

   l_asg_dys_wrkd NUMBER;
   l_dys_in_prd   NUMBER;
   l_frctn        NUMBER;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('py_za_prorate_pkg.pro_rate_days',1);

   OPEN c_Timeperiod(PAYROLL_ACTION_ID);
   FETCH c_Timeperiod INTO l_Pdates;
   IF c_Timeperiod%NOTFOUND THEN
      raise no_data_found;
   END IF;
   CLOSE c_Timeperiod;

   hr_utility.set_location('py_za_prorate_pkg.pro_rate_days',2);

   OPEN c_Assignment(ASSIGNMENT_ID);
   FETCH c_Assignment INTO l_Adates;
   IF c_Assignment%NOTFOUND THEN
      raise no_data_found;
   END IF;
   CLOSE c_Assignment;

   hr_utility.set_location('py_za_prorate_pkg.pro_rate_days',3);

   l_asg_dys_wrkd :=    LEAST(l_Pdates.end_date,l_Adates.end_date)
                   - GREATEST(l_Pdates.start_date,l_Adates.start_date)
                   + 1;
   l_dys_in_prd := l_Pdates.end_date - l_Pdates.start_date + 1;

   l_frctn := l_asg_dys_wrkd / l_dys_in_prd;

   hr_utility.set_location('py_za_prorate_pkg.pro_rate_days',4);
   RETURN l_frctn;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('py_za_prorate_pkg.pro_rate_days',5);
      hr_utility.set_message(801, 'py_za_prorate_pkg: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END pro_rate_days;


END py_za_prorate_pkg;

/
