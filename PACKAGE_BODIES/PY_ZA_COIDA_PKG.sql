--------------------------------------------------------
--  DDL for Package Body PY_ZA_COIDA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_COIDA_PKG" as
/* $Header: pyzacoid.pkb 120.3 2006/06/15 09:29:22 amahanty ship $         */
-- *****************************************************************************
-- This function calculates the total number of working days during a given
-- period. When this function is called the user has to specify if Saturday
-- is a working day.
-- *****************************************************************************

Function get_working_days
  (
   p_period_start in date
  ,p_period_end   in date
  )
Return number
as

l_tot_work_days  number;
l_next_date      date;         -- next date to process
l_days           varchar2(10);


Begin

 -- Initialise some variables

 l_tot_work_days := 0;
 l_next_date     := p_period_start;

 Loop

    If l_next_date > p_period_end then
       exit;
    End if;

    l_tot_work_days := l_tot_work_days + 1;

    -- go to next day
    l_next_date := l_next_date + 1;

  End Loop;

  Return (l_tot_work_days);

 End get_working_days;

-- *****************************************************************************
-- This function calculates the total number of absence days for all employees
-- within a given period (for a specific absence type).
-- *****************************************************************************
/* Bug 3612045
 Function get_emp_absence
  (
   p_start_date    date
  ,p_end_date      date
  ,p_type          varchar2
  )
 Return number
 as

 l_tot_absence_days  number := 0;

 Cursor c_absences is
   Select
        sum(absence_days)
   From
         per_absence_attendances      paa
   ,     per_absence_attendance_types pat
   Where
         pat.absence_attendance_type_id = paa.absence_attendance_type_id
   And   upper(pat.name) = upper(p_type)
   And   paa.date_start >= p_start_date
   And   paa.date_end   <= p_end_date
   And   paa.date_end   >= p_start_date
   And   paa.date_end   <= p_end_date;

 Begin

   Open c_absences;
   Fetch c_absences into l_tot_absence_days;
   Close c_absences;

   Return (l_tot_absence_days);

 End get_emp_absence;
*/
-- *****************************************************************************
-- This function calculates the total number of days actually worked by
-- a specified person_id. It accepts a period start, period end date,
-- payroll id and person id as parameters.
-- If the employee start date is earlier than the period start the function will
-- use the period start date when calculating the number of days worked, else it
-- would use the employee start date. If the period end date is before the
-- employee end date the function will use the period end date to calculate the
-- number of days worked, else it will use the employee end date.
-- Also one should keep in mind that the assignment dates cannot be used since
-- one person may have multiple assignments.
-- *****************************************************************************

 Function get_emp_days_worked
   (
    p_start_date  date
   ,p_end_date    date
   ,p_payroll_id  number
   ,p_person_id   number default null
   )
 Return number
 as

 l_tot_days_worked      number := 0;
 l_assignment_id            number;
 l_effective_start_date date;
 l_effective_end_date   date;
 l_assignment_status    number;

 lp_assignment_id        number := 0;
 lp_effective_start_date date := to_date('01-01-1001', 'DD-MM-YYYY');
 lp_effective_end_date   date := to_date('01-01-1001', 'DD-MM-YYYY');

 l_count                number := 0;

 -- Get the employee record(s) to process
 Cursor c_get_emps is

   Select
         paf.assignment_id,
         paf.effective_start_date,
         paf.effective_end_date,
         paf.assignment_status_type_id
   From
         per_assignments_f paf,
         per_assignment_status_types past,
         pay_payrolls_f ppaf,
         per_periods_of_service pos
   Where
-------------------------------------------------------------------------------------
         pos.PERSON_ID = paf.PERSON_ID
   and   nvl(pos.actual_termination_date, paf.effective_end_date) >= paf.EFFECTIVE_END_DATE
   and   paf.ASSIGNMENT_TYPE = 'E'
-------------------------------------------------------------------------------------
-- Per_Assignments_F
--       paf.person_id  = nvl(p_person_id,paf.person_id)
   And   paf.person_id  = p_person_id
   And   paf.payroll_id = p_payroll_id
   And   p_start_date <= paf.effective_end_date
   And   p_end_date >= paf.effective_start_date

   And   paf.assignment_status_type_id = past.assignment_status_type_id
   And   past.per_system_status = 'ACTIVE_ASSIGN'

-- Per_Payrolls_F
   And   paf.payroll_id = ppaf.payroll_id
   And   p_start_date <= ppaf.effective_end_date
   And   p_end_date >= ppaf.effective_start_date
   Order by
        2;

 Begin

   Open  c_get_emps;
   Fetch c_get_emps into l_assignment_id, l_effective_start_date,
         l_effective_end_date, l_assignment_status;

   If  p_person_id is not null then
        Loop                                                    -- There may be more than one record
           Exit when c_get_emps%notfound;                       -- for each employee i.e. broken service

        if  (l_effective_start_date <= lp_effective_end_date)
          And (l_effective_end_date > lp_effective_end_date) then
          l_effective_start_date := lp_effective_end_date + 1;
        Else
          null;
        End if;

        If l_effective_end_date <= lp_effective_end_date then
          l_effective_end_date := lp_effective_end_date;
        Else
          null;
        End if;

        -- check the start date
        If  l_effective_start_date < p_start_date then
          -- use p_start_date, the start of the period
          l_effective_start_date := p_start_date;
        Else
          -- use l_effective_start_date, employee start date
          null;
        End if;

        -- check the end date
        If  p_end_date < l_effective_end_date then
          -- use p_end_date, the end of the period
          l_effective_end_date := p_end_date;
        Else
          -- use l_effective_end_date, employee end date
          null;
        End if;

        -- now calculate the days worked and increment the total
        -- This is only done when the end date is not equal to the prev end date
        If l_effective_end_date <> lp_effective_end_date then
          l_count := l_count +  py_za_coida_pkg.get_working_days
            (
             l_effective_start_date,
             l_effective_end_date
            );
        End if;


        lp_effective_start_date := l_effective_start_date;
        lp_effective_end_date := l_effective_end_date;

        -- There may be more!
        Fetch c_get_emps into l_assignment_id, l_effective_start_date,
                l_effective_end_date, l_assignment_status;
        End Loop;

   Else

     Loop                                                       -- This loop is when there is no
        Exit when c_get_emps%notfound;                          -- emp id i.e. all employees

        -- check the start date
        If  l_effective_start_date < p_start_date then
            -- use p_start_date, the start of the period
            l_effective_start_date := p_start_date;
        Else
            -- use l_effective_start_date, employee start date
            null;
        End if;

        -- check the end date
        If  p_end_date < l_effective_end_date then
            -- use p_end_date, the end of the period
            l_effective_end_date := p_end_date;
        Else
            -- use l_effective_end_date, employee end date
            null;
        End if;

        -- now calculate the days worked and increment the total
        l_count := l_count +  py_za_coida_pkg.get_working_days
                             (
                                                 l_effective_start_date,
                                                 l_effective_end_date
                                                 );

        --  get the next employee record to process
        Fetch c_get_emps into l_assignment_id, l_effective_start_date,
                l_effective_end_date, l_assignment_status;

     End Loop;

   End if;

   -- Total for all employees
   l_tot_days_worked := l_count;

   Close c_get_emps;

   Return (l_tot_days_worked);

 End get_emp_days_worked;

End py_za_coida_pkg;

/
