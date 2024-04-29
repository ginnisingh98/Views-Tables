--------------------------------------------------------
--  DDL for Package Body PAY_FR_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_TERMINATION_PKG" as
/* $Header: pyfrterm.pkb 120.0 2005/05/29 05:11:23 appldev noship $ */
/*---------------------------------------------------------------------------------------------------------------
   This function obtains details of the number of hours an employee has worked relative to a full time employee.
   For a full time employee the value is = to the number of hours they would normally have worked
   (asignment.normal hours * months). For part time employees, the number of hours worked relative to the monthly
   reference hours needs to be calculated. The procedure also splits the hours worked by pre service ( any service
   that is greater than 10 years date and post service any hours after the pre service :

                               01-JAN-2011
                                |
   Hire Date 01-JAN-01          |                  Termination Date 28-FEB-2014
   |<------ Pre Service ------->|<--Post Service-->|


---------------------------------------------------------------------------------------------------------------*/
Function get_termination_service_det     (p_business_group_id in number,
		  		       -- p_person_id in number,
                                          p_assignment_id    in number,
                                          p_termination_date in date,
                                          p_pre_service_ratio  out NOCOPY number,
                                          p_post_service_ratio out NOCOPY number)
Return number is

ZERO_NORMAL_HOURS exception;

-- l_greater_than_10_years_service varchar2(1) := 'N';
l_date_greater_than_10_years date;
l_total_service number :=0;
l_post_service_date date;
l_person_id number;
l_hire_date date;
l_10_years_ago date;
l_total_pre_service number := 0;
l_total_post_service number := 0;
l_normal_monthly_hours number := 0;
l_months_worked_pre_service number := 0;
l_months_worked_post_service number := 0;
l_last_day_worked DATE;
l_actual_months_worked number := 0;
l_period_of_service_id number;
g_package varchar2(30) := 'PAY_FR_TERMINATION_PKG';
l_proc               varchar2(72) := g_package||'get_termination_service_det';
i  number :=0;

l_current_monthly_ref_hours number :=0;
l_indx PLS_INTEGER;

TYPE assignment_rec IS RECORD
 (business_group_id    NUMBER,
  assignment_id        NUMBER,
  effective_start_date DATE,
  effective_end_date   DATE,
  normal_hours         NUMBER,
  frequency            VARCHAR2(1),
  establishment_id     NUMBER,
  period_of_service_id NUMBER,
  part_time_flag       VARCHAR2(1));

TYPE t_assignments IS TABLE OF assignment_rec INDEX BY BINARY_INTEGER;
l_assignments t_assignments;

TYPE monthly_hours_rec IS RECORD
 ( monthly_hours NUMBER,
   date_from     DATE,
   date_to      DATE);

TYPE t_monthly_hours IS TABLE OF monthly_hours_rec INDEX BY BINARY_INTEGER;
l_monthly_hours t_monthly_hours;

cursor assignments(c_person_id number) is
select assign.business_group_id,
       assign.assignment_id,
       assign.effective_start_date,
       assign.effective_end_date,
       -- Modified as part of time analysis changes
       -- normal_hours,
       -- frequency,
       decode(contract.ctr_information12, 'HOUR', fnd_number.canonical_to_number(contract.ctr_information11), assign.normal_hours) normal_hours,
       decode(contract.ctr_information12, 'HOUR', contract.ctr_information13, assign.frequency) frequency,
       --
       assign.establishment_id,
       assign.period_of_service_id,
       substr(hruserdt.get_table_value (assign.business_group_id,'FR_CIPDZ','CIPDZ',assign.employment_category,P_termination_date),1,1) part_time_flag
from
       per_all_assignments_f assign,
       --
       per_contracts_f       contract
where  assign.person_id = c_person_id
  --
  and  assign.contract_id = contract.contract_id
  --
order by  assign.effective_start_date;

/* get table of historical monthly hours from org eit */
Cursor monthly_hours(c_org_id number) is
select to_number(org_information3) monthly_hours,
       fnd_date.canonical_to_date(org_information1) date_from,
       fnd_date.canonical_to_date(org_information2) date_to
from
       hr_organization_information
where
       org_information_context = 'FR_HISTORICAL_MONTHLY_REF_HRS'
       and organization_id = c_org_id
order by fnd_date.canonical_to_date(org_information1);


Function Find_Hours(p_date_start date) return number is
l_hours_index number :=0;

l_found varchar2(1) := 'N';
l_proc               varchar2(72) := g_package||'Find_Hours';

Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.trace('p_date_start = ' || p_date_start);
  While l_hours_index < l_monthly_hours.count and l_found = 'N' loop
    l_hours_index := l_hours_index + 1;

hr_utility.trace('mth hrs st and end = ' || ' ' || l_monthly_hours(l_hours_index).date_from || ' ' || l_monthly_hours(l_hours_index).date_to);


    If p_date_start between l_monthly_hours(l_hours_index).date_from and
                            l_monthly_hours(l_hours_index).date_to Then
       l_found := 'Y';
    End if;
  End loop;

  If l_found = 'Y' Then
     Return l_hours_index;
  Else
     hr_utility.trace('no monthly reference hours found for date ' || p_date_start);
     Return 0;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

End;

Procedure Calculate_Service(p_hours_index       in number,
                            p_start             in date,
                            p_end               in date) is

l_number_of_months        number := 0;
l_normal_monthly_hours    number := 0;
l_actual_months_worked    number := 0;
l_proc               varchar2(72) := g_package||'Calculate_Service';

Function Calculate_Pre_and_Post_Service (p_start_period date, p_end_period date)
Return number is

l_proc          varchar2(72) := g_package||'Calculate_Service';

Begin

    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.trace('p_start = '|| p_start_period || 'p_end_period = ' || p_end_period);

    l_number_of_months := months_between(p_end_period + 1,p_start_period);
    IF l_assignments(i).part_time_flag = 'P' THEN
       /* Convert the assignment normal hours to a monthly frequency if it is not monthly already */
       IF l_assignments(i).frequency <> 'M' THEN
          l_normal_monthly_hours := PAY_FR_GENERAL.convert_hours
                                                (p_effective_date       => p_start_period
                                                ,p_business_group_id    => l_assignments(i).business_group_id
                                                ,p_assignment_id        => l_assignments(i).assignment_id
                                                ,p_hours                => l_assignments(i).normal_hours
                                                ,p_from_freq_code       => l_assignments(i).frequency
                                                ,p_to_freq_code         => 'M');
       ELSE
          l_normal_monthly_hours := l_assignments(i).normal_hours;
       END IF;

       /* multiply l_nomber_of_months by above to give hours worked during period and then divide by historical
       monthly hours to give months worked relative to a full time employee */

       l_actual_months_worked := l_number_of_months *
                                 (l_normal_monthly_hours/ l_monthly_hours(p_hours_index).monthly_hours);

       hr_utility.trace('l_actual_months_worked = ' || l_actual_months_worked);
       hr_utility.trace('l_number_of_months = ' || l_number_of_months );
       hr_utility.trace('l_normal_monthly_hours = ' || l_normal_monthly_hours);
       hr_utility.trace('l_monthly_hours(l_indx) = ' || l_monthly_hours(p_hours_index).monthly_hours);

    ELSE
       l_actual_months_worked := l_number_of_months;

       hr_utility.trace('l_number_of_months = ' || l_number_of_months );

    END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 70);

    Return l_actual_months_worked;

End;

Begin

    hr_utility.set_location('Entering:'|| l_proc, 10);

/* Is this service in the pre service period or service in the post period ? We may need to
split this service up so that the correct amount is processed in the pre and post periods */

    If p_start <= l_date_greater_than_10_years and p_end <= l_date_greater_than_10_years Then /* All Pre Service */
       l_total_pre_service := l_total_pre_service  + Calculate_Pre_and_Post_Service(p_start, p_end);
    Elsif
       p_start <= l_date_greater_than_10_years and p_end > l_date_greater_than_10_years then /* pre and some is post */
       l_total_pre_service := l_total_pre_service + Calculate_Pre_and_Post_Service
 							(p_start, l_date_greater_than_10_years);
       l_total_post_service := l_total_post_service +
--	 Calculate_Pre_and_Post_Service ((l_date_greater_than_10_years + 1 ), p_end);
         Calculate_Pre_and_Post_Service (l_date_greater_than_10_years , p_end);
    Elsif
       p_start > l_date_greater_than_10_years Then /* then all post service */
       l_total_post_service := l_total_post_service + Calculate_Pre_and_Post_Service (p_start, p_end);
    End if;

    hr_utility.set_location(' Leaving:'||l_proc, 70);

End;

Procedure Process_days(p_hours_index in number , p_date_end in date) is
l_hours_index number :=0;
l_new_date_start date;
l_new_date_end date;
l_days_to_process number :=0;
l_found_hours varchar2(1) := 'Y';

l_proc               varchar2(72) := g_package||'Process_days';

Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_hours_index := p_hours_index;
  l_new_date_start := l_assignments(i).effective_start_date;
  l_new_date_end   := least(p_date_end,l_assignments(i).effective_end_date);
  While l_new_date_start <= l_assignments(i).effective_end_date And l_found_hours = 'Y' loop
    l_days_to_process := l_new_date_end - l_new_date_start;
    Calculate_Service(p_hours_index => l_hours_index, p_start => l_new_date_start, p_end => l_new_date_end);
    l_hours_index := find_hours(p_date_start => (l_new_date_end + 1));
    If l_hours_index <> 0 Then
       l_new_date_start := l_new_date_end + 1;
       l_new_date_end   := least(l_assignments(i).effective_end_date,l_monthly_hours(l_hours_index).date_to);
    Else
      l_found_hours := 'N';
    End If;
  End Loop;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

EXCEPTION
  when others then
      hr_utility.set_location('process_details',20);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      Raise;

End Process_days;

Procedure Process_assignment_row is

l_proc               varchar2(72) := g_package||'Process_assignment_row';
l_index number :=0;
Begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_utility.trace('l_assignments(i).effective_start_date = ' || l_assignments(i).effective_start_date);

  l_index := Find_Hours(l_assignments(i).effective_start_date); -- will always contain at least one row

  hr_utility.trace('l_monthly_hours(l_index).date_to = ' || l_monthly_hours(l_index).date_to);

  Process_days(l_index,l_monthly_hours(l_index).date_to);

  hr_utility.set_location(' Leaving:'||l_proc, 70);

End Process_assignment_row;

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_10_years_ago :=  add_months (p_termination_date,-120);

  select distinct person_id
  into l_person_id
  from per_all_assignments_f
  where assignment_id = p_assignment_id
  and business_group_id = p_business_group_id;

  select min(start_date)
  into l_hire_date
  from per_all_people_f
  where person_id = l_person_id;

  If add_months(l_hire_date, 120) < p_termination_date Then
  -- l_greater_than_10_years_service = 'Y'
     l_date_greater_than_10_years := add_months(l_hire_date,120) -1;
  Else
  -- l_greater_than_10_years_service = 'N';
     l_date_greater_than_10_years := p_termination_date + 365;
  END IF;

  hr_utility.trace ('hire date = ' || l_hire_date);
  hr_utility.trace ('l_date_greater_than_10_years = ' || l_date_greater_than_10_years);

  l_indx := 1;
  For a in assignments(l_person_id) loop
      l_assignments(l_indx).effective_start_date := a.effective_start_date;
      l_assignments(l_indx).assignment_id        := a.assignment_id;
      l_assignments(l_indx).effective_end_date   := a.effective_end_date;
      l_assignments(l_indx).period_of_service_id := a.period_of_service_id;
      If a.part_time_flag = 'P' And ( a.normal_hours is null or a.frequency is null) Then
         RAISE ZERO_NORMAL_HOURS;
      Else
     	 l_assignments(l_indx).normal_hours         := a.normal_hours;
     	 l_assignments(l_indx).frequency            := a.frequency;
     	 l_assignments(l_indx).part_time_flag       := a.part_time_flag;
     	 l_assignments(l_indx).business_group_id    := a.business_group_id;
         l_assignments(l_indx).establishment_id     := a.establishment_id;
    	 l_indx := l_indx + 1;
      End If;
  End loop;

/* For the last assignment effective end date, make it equal to the last day worked */

  hr_utility.trace('last period of service_id = ' || l_assignments(l_assignments.last).period_of_service_id);
  l_period_of_service_id := l_assignments(l_assignments.last).period_of_service_id;
  Select fnd_date.canonical_to_date(pds_information10)
  into
  l_last_day_worked
  from per_periods_of_service
  where period_of_service_id = l_period_of_service_id;

  l_assignments(l_assignments.last).effective_end_date := l_last_day_worked;

  hr_utility.trace ('start date 1 = ' || l_assignments(1).effective_start_date);

  i :=0;
  While i < l_assignments.last Loop
     i := i + 1;
     select to_number(org_information4)
     into   l_current_monthly_ref_hours
     from   hr_organization_information
     where  org_information_context = 'FR_ESTAB_INFO'
       and organization_id      = l_assignments(i).establishment_id;
        l_monthly_hours.delete;
        l_indx := 2;
        For h in monthly_hours(l_assignments(i).establishment_id) loop
            l_monthly_hours(l_indx).monthly_hours := h.monthly_hours;
            l_monthly_hours(l_indx).date_from     := h.date_from;
            l_monthly_hours(l_indx).date_to       := h.date_to;

            hr_utility.trace('date from and date to = ' || l_monthly_hours(l_indx).date_from || ' ' || l_monthly_hours(l_indx).date_to);
            l_indx := l_indx + 1;
        End loop;

        /* If any historical reference hours were found then add a row at the beginning of the table to cater
	   for assignments that start before the first historical monthly reference hours row. If we found
           no historical data then we still want to process the assignments so use the current monthly reference
           hours - store this in the last row.
        */

        hr_utility.trace(' 1. l_indx = ' || l_indx || ' count = ' || l_monthly_hours.count);

        If l_monthly_hours.count > 0 Then
           IF l_assignments(1).effective_start_date < l_monthly_hours(2).date_from Then
              l_monthly_hours(1).date_from := l_assignments(1).effective_start_date - 50;
              l_monthly_hours(1).date_to   := l_monthly_hours(2).date_from - 1;
           Else
              l_monthly_hours(1).date_from := l_monthly_hours(2).date_from - 50;
              l_monthly_hours(1).date_to   := l_monthly_hours(2).date_from - 1;
       --  l_indx := l_monthly_hours.count + 1;
       --  l_monthly_hours(1).monthly_hours := l_monthly_hours(2).monthly_hours;
       --  l_monthly_hours(1).date_from := to_char(to_date('01-JAN-1900','DD-MON-YYYY'),'DD-MON-YYYY');
       --  l_monthly_hours(1).date_to   := l_monthly_hours(2).date_from - 1;
           End If;
           l_indx := l_monthly_hours.count + 1;
           l_monthly_hours(1).monthly_hours := l_monthly_hours(2).monthly_hours;
           l_monthly_hours(l_indx).monthly_hours := l_current_monthly_ref_hours;
           l_monthly_hours(l_indx).date_from     := l_monthly_hours(l_indx - 1).date_to + 1;

           hr_utility.trace('l_indx = ' || l_indx || ' count = ' || l_monthly_hours.count);
           hr_utility.trace(' l_monthly_hours.date to = ' || l_monthly_hours(l_monthly_hours.count).date_to);
           hr_utility.trace(' l_monthly_hours(l_indx).date_from = ' ||  l_monthly_hours(l_indx).date_from);

           l_monthly_hours(l_indx).date_to       := l_assignments(l_assignments.last).effective_end_date + 365;
        Else
           l_monthly_hours(1).monthly_hours := l_current_monthly_ref_hours;
           l_monthly_hours(1).date_from     := l_assignments(1).effective_start_date - 50;
           l_monthly_hours(1).date_to       := l_assignments(l_assignments.last).effective_end_date + 365;
        End if;

        process_assignment_row;
  End loop;

  /* Bug 2859175
  NOTE Due to bug 2859175 pre_service is now returned as the total service and post service is returned as
  the service greater than 10 years. So if an employee had 13 years service then pre service is
  returned as 13 years and post service is returned as 3 years. */

  -- p_pre_service_ratio := round(l_total_pre_service);
  l_total_service := (l_total_pre_service + l_total_post_service) / 12;
  p_pre_service_ratio := l_total_service;
  p_post_service_ratio := l_total_post_service / 12;
  -- p_post_service_ratio := round(l_total_post_service);

  Return 0;

  hr_utility.set_location(' Leaving:'||l_proc, 70);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    hr_utility.trace('No Data Found');
    p_pre_service_ratio := 0;
    p_post_service_ratio := 0;
    RETURN 999;

    WHEN ZERO_NORMAL_HOURS THEN
    p_pre_service_ratio := 0;
    p_post_service_ratio := 0;
    hr_utility.trace('raised exception ZERO_NORMAL_HOURS - raised when part time employee has no values for
                      assignment normal hours or frequency');
    RETURN 998;
    RAISE;


    when others then
      hr_utility.set_location('l_proc',80);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      p_pre_service_ratio := 0;
      p_post_service_ratio := 0;
      RETURN 999;
      Raise;

End get_termination_service_det;
end PAY_FR_TERMINATION_PKG;

/
