--------------------------------------------------------
--  DDL for Package Body SSP_ERN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_ERN_BUS" as
/* $Header: spernrhi.pkb 120.5.12010000.2 2008/08/13 13:25:38 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ssp_ern_bus.';  -- Global package name
--
-- global variable used to pass the number of payment_periods, calculated in
-- procedure do_standard_calculation, to the form SSPWSENT.
form_variable number := null;
--
--
--  Business Validation Rules
--
--
-----------------------------------------------------------------------------
-- |---------------------------------< Check_Person_id >---------------------
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    Ensure that a valid person id is entered
--
Procedure check_person_id  (p_person_id      in number,
                            p_effective_date in date) is
 l_proc  varchar2(72) := g_package||'Check_Person_id';
 cursor c1 is
   select p.rowid
   from   per_all_people_f p
   where  p.person_id = p_person_id
     and  p_effective_date between p.effective_start_date and
                                   p.effective_end_date;
 c1_rec c1%ROWTYPE;
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  open c1;
  fetch c1 into c1_rec;
  if c1%NOTFOUND then
    fnd_message.set_name ('SSP' , 'SSP_35049_INV_PERSON_EFF_DATE' );
    fnd_message.raise_error;
  end if;
  close c1;
  hr_utility.set_location('Leaving :'||l_proc, 100);
End  check_person_id;
--
--
--  ------------------------------------------------------------------------
-- |-----------------------------< Check_Effective_Date >-------------------
--  ------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Ensure that a valid effective date is entered for a PErson
--
Procedure check_effective_date (p_person_id      in number,
                                p_effective_date in date) is

 l_proc  varchar2(72) := g_package||'Check_Effective_Date';

  cursor c2 is
    select s.person_id
    from   per_periods_of_service s
    where  s.person_id = p_person_id
     and  p_effective_date between s.date_start and
           nvl(s.actual_termination_date,hr_general.end_of_time);

  c2_rec c2%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 1);

  open c2;
  fetch c2 into c2_rec;
  if c2%NOTFOUND then
    fnd_message.set_name ('SSP' , 'SSP_35050_INV_EFFECTIVE_DATE' );
    fnd_message.raise_error;
  end if;
  close c2;
  hr_utility.set_location('Leaving :'||l_proc, 100);
END check_effective_date;
--
--
-- ------------------------------------------------------------------------
-- |----------------------< calculate_average_earnings >-------------------
-- ------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--
-- Calculate the average weekly earnings of a person over an approximate
-- 8 week period prior to a specified date. The calculation method is in
-- accordance with the requirements laid down for SSP/SMP in DSS document
-- CA30 (NI270) from April 1995
--
--
PROCEDURE CALCULATE_AVERAGE_EARNINGS (
        p_person_id                     in number,
        p_effective_date                in date,
        p_average_earnings_amount       out nocopy number,
        p_user_entered                  in varchar2 default 'Y',
	p_absence_category		in varchar2 --DFoster 1304683
        ) is
        --
l_proc                          varchar2(72) := g_package
                                                ||'calculate_average_earnings';
type date_table is table of date index by binary_integer;
l_assignment_average            number := 0;
l_person_average                number := 0;
l_period_of_service_id          number := null;
l_hire_date                     date := null;
l_payroll_frequency             varchar2 (30);
l_payday                        date_table;
l_start_of_relevant_period      date := null;
l_end_of_relevant_period        date := null;
l_start_of_coverage             date := null;
l_end_of_coverage               date := null;
l_assignment_id                 number := null;
l_payroll_id                    number := null;
l_new_employee                  boolean := FALSE;
cannot_derive_earnings          exception;
--
-- added variables for checking re-hired employees(abhaduri)
l_earlier_term_date            date;
l_noof_periods_service         number :=0;
--
cursor csr_NIable_earnings (p_balance_name in varchar2) is
        --
        -- Calculate the total of all NIable pay in a given period for an
        -- assignment.
        --
        select  /*+ ORDERED USE_NL(RUN_VALUE, RUN_RESULT, FEED, BALANCE) */
                nvl (sum (nvl (run_value.result_value, 0) * feed.scale),0) EARNINGS
        from    pay_assignment_actions  ASG_ACTION,
                pay_payroll_actions     PAY_ACTION,
                per_time_periods        PERIOD,
                pay_balance_types       BALANCE,
                pay_balance_feeds_f     FEED,
                pay_run_results         RUN_RESULT,
                pay_run_result_values   RUN_VALUE
                --
        -- where the tables join via primary/foreign keys
        where   pay_action.payroll_action_id = asg_action.payroll_action_id
        and     run_result.assignment_action_id=asg_action.assignment_action_id
        and     run_result.run_result_id = run_value.run_result_id
        and     run_value.input_value_id = feed.input_value_id
        and     feed.balance_type_id = balance.balance_type_id
        and     period.time_period_id = pay_action.time_period_id
        and     period.regular_payment_date between feed.effective_start_date and feed.effective_end_date
        --
        -- and the earnings are for the specified assignment
        and     asg_action.assignment_id = L_ASSIGNMENT_ID
        --
        -- and the run result has been processed
        and     run_result.status in ('P','PA') --like 'P%'
        --
        and     balance.balance_name = p_balance_name
        and     period.end_date between L_START_OF_RELEVANT_PERIOD and L_END_OF_RELEVANT_PERIOD;
        --
cursor csr_set_of_current_assignments is
        --
        -- Get all a person's assignments which fall within a period of service.
        -- Retrieve a row for each assignment/payroll combination so that we can
        -- treat payroll transfers effectively as if they were separate
        -- assignments.
        --
        -- Payroll_id not returned as causes do_standard_calculation /
        -- do_monthly_calculation to be called twice if there has been a change
        -- of payroll, and the relevant period ends up being calculated
        -- incorrectly.
        --
        select  distinct
                asg.assignment_id
        from    per_all_assignments_f       ASG
        where   asg.period_of_service_id = L_PERIOD_OF_SERVICE_ID
        and     asg.payroll_id is not null
        --6791913 begin  - To treat adoption in the same way as Maternity
        --and     ((      p_absence_category = 'M'
        and     ((      p_absence_category in ('M','GB_ADO')
        --6791913 end
                    and effective_end_date >= (p_effective_date - 68))
                 or -- p_absence = 'S'
                    effective_end_date >= (p_effective_date - 62)
                 );
        --
-- (abhaduri)added cursor to check whether employee has been re-hired
cursor csr_noof_periods_service is
        -- check the no of rows in per_periods_of_service table
        -- to calculate the no of times
        -- the employee has been employed by the employer
       select count(*) from per_periods_of_service
       where person_id = p_person_id;
--
-- (abhaduri) added cursor to get the last termination date
-- if employer has been employed more than once by the employer
cursor csr_earlier_term is
      -- get the termination date if it is not null
        select nvl(max(actual_termination_date),to_date('01/01/01','DD/MM/YY'))
        from per_periods_of_service
        where person_id = p_person_id
        and actual_termination_date is not null;
--

procedure derive_relevant_period is
        --
        -- Derive the 8-week period before the latest payday before the
        -- effective date.
        --
        l_proc varchar2 (72) := g_package||'derive_relevant_period';
        l_temp number;
        --
        cursor csr_end_period_m is
                --
                -- Get the end date of the last payroll period prior to the
                -- end of the week of the effective date for Maternities.
                --

                select  max (period.end_date)
                from    per_time_periods        PERIOD
                where   period.payroll_id = L_PAYROLL_ID
                and     period.regular_payment_date <= P_EFFECTIVE_DATE +6;

	--

        cursor csr_end_period_m2 is
                --
                -- Get the end date of the last payroll period prior to the
                -- end of the week of the effective date for Maternities.

                -- This cursor will be called when a new payroll has been
		    -- assigned to the employee and there has been no
		    -- payroll runs and the employee is going on a maternity leave.
		    -- The cursor csr_end_period_m would return null, which is incorrect.


			select max(ptp.end_date)
			from per_time_periods ptp
			where ptp.payroll_id in
		        	(	select papf.payroll_id
				        from pay_all_payrolls_f papf,
				        per_all_assignments_f paf,
				        per_all_people_f ppf,
				        per_time_periods ptp
				        where ppf.person_id = paf.person_id
					        and papf.payroll_id = paf.payroll_id
					        and paf.payroll_id = ptp.payroll_id
					        and ptp.regular_payment_date <=
						  P_EFFECTIVE_DATE  + 6
					        and paf.assignment_id = l_assignment_id)
			       and ptp.regular_payment_date <= P_EFFECTIVE_DATE + 6 ;
	--
	cursor csr_end_period_s is
		--
		-- Get the end date of the last payroll period prior to the
		-- end of the week of the effective date for Sicknesses.
		--
		select max (period.end_date)
		from	per_time_periods	PERIOD
		where	period.payroll_id = L_PAYROLL_ID
		and	period.regular_payment_date <= P_EFFECTIVE_DATE;

	--
      cursor csr_end_period_s2 is
			--
			-- Get the end date of the last payroll period prior to the
			-- end of the week of the effective date for Sicknesses.
			--
	            -- This cursor will be called when a new payroll has been
	   	      -- assigned to the employee and there has been no
			-- payroll runs and the employee is going on a leave.
			-- The cursor csr_end_period_s would return null, which is incorrect.

			select max(ptp.end_date)
			from per_time_periods ptp
			where ptp.payroll_id in
		        	(	select papf.payroll_id
				        from pay_all_payrolls_f papf,
				        per_all_assignments_f paf,
				        per_all_people_f ppf,
				        per_time_periods ptp
				        where ppf.person_id = paf.person_id
					        and papf.payroll_id = paf.payroll_id
					        and paf.payroll_id = ptp.payroll_id
					        and ptp.regular_payment_date <=
						  P_EFFECTIVE_DATE
					        and paf.assignment_id = l_assignment_id)
			       and ptp.regular_payment_date <= P_EFFECTIVE_DATE ;
	--
        cursor csr_start_period is
                --
                -- Get the start date of the payroll period which was at least
                -- 8 weeks prior to the end of the relevant period.
                --
                select  max (period.end_date) +1
                from    per_time_periods        PERIOD
                where   period.payroll_id = L_PAYROLL_ID
                and     period.end_date <= L_END_OF_RELEVANT_PERIOD - 56;
--
-- Cursor to return the payroll_id, as is no longer returned in
-- csr_set_of_current_assignments above, but is required in the
-- calculation of the relevant_period_start_date. The cursor returns
-- the payroll_id that the assignment is on, 56 days before the
-- l_end_of_relevant_period.
--
	cursor csr_get_payroll_id_start is
		select ppf.payroll_id
	        from pay_all_payrolls_f ppf
	        ,    per_all_assignments_f paf
	        where   ppf.payroll_id = paf.payroll_id
	        and     paf.assignment_id = l_assignment_id
	        and     l_start_of_relevant_period between
			paf.effective_start_date and paf.effective_end_date;
--
-- Get payroll id for this assignment just before the start of the absence so
-- we can then find the regular payment date which is used to identify the end
-- of the last eight weeks for calculating average earnings.
--
        cursor csr_get_payroll_id_end is
                select  payroll_id
                from    per_all_assignments_f paf
                where   paf.assignment_id = L_ASSIGNMENT_ID
                and     P_EFFECTIVE_DATE between
                	paf.effective_start_date and paf.effective_end_date;

--
--
     cursor csr_chk_asg is
     select 1
     from   per_all_assignments_f
     where  assignment_id = L_ASSIGNMENT_ID
     and    l_start_of_relevant_period between	effective_start_date and effective_end_date;

     cursor csr_get_start_date is
     select min(effective_start_date)
     from   per_all_assignments_f
     where  assignment_id = L_ASSIGNMENT_ID;
--
--
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        open csr_get_payroll_id_end;
        fetch csr_get_payroll_id_end into l_payroll_id;
        close csr_get_payroll_id_end;

        --
	-- Bug 1304683 DFoster
        -- Get the end date of the last pay period where the regular payment
	-- date is just before the effective date depending on whether a
	-- Sickness or a Maternity.
        --
        --6791913 Begin
        --if p_absence_category = 'M' then
        if p_absence_category in ('M','GB_ADO') then
        --6791913 End
		open csr_end_period_m;
		fetch csr_end_period_m into l_end_of_relevant_period;
		close csr_end_period_m;

		if l_end_of_relevant_period is null then
		      hr_utility.trace (l_proc||' finding the end of relevant period using the assignment id and not using the payroll id');
			open csr_end_period_m2;
			fetch csr_end_period_m2 into l_end_of_relevant_period;
			close csr_end_period_m2;
		end if;

	else --if p_absence_category = 'S' then
		open csr_end_period_s;
		fetch csr_end_period_s into l_end_of_relevant_period;
		close csr_end_period_s;

		if l_end_of_relevant_period is null then
		      hr_utility.trace (l_proc||' finding the end of relevant period using the assignment id and not using the payroll id');
			open csr_end_period_s2;
			fetch csr_end_period_s2 into l_end_of_relevant_period;
			close csr_end_period_s2;
		end if;

	end if;
	--
        -- the above csrs can return null when a new employee is hired
        -- assigned to new payroll and goes on sick leave!

        l_start_of_relevant_period := l_end_of_relevant_period - 56;
        --
        --
        -- the payrll id is reset to null as if the csr_get_payroll_id_start
        -- returns no rows, the old value of payroll id is retained
        -- and this causes error as l_start_of_relevant_period is not
        -- set to l_hire_date;
        -- the above csr can return null when a new employee is hired
        -- assigned to new payroll and foes on sick leave!

        l_payroll_id := null;

        open csr_get_payroll_id_start;
        fetch csr_get_payroll_id_start into l_payroll_id;
        close csr_get_payroll_id_start;
        --
        if l_payroll_id is null then
            if l_end_of_relevant_period is null then
               -- -1 because, the end date is the previous months payroll
               -- end date
                l_end_of_relevant_period := l_hire_date - 1 ;
                l_start_of_relevant_period := l_end_of_relevant_period - 56;
            else
                l_start_of_relevant_period := l_hire_date;
                -- if the assignment doesn't exits at the hire date (ie, multiple asg)
                -- then get the assignment start date
                open csr_chk_asg;
                fetch csr_chk_asg into l_temp;
                if csr_chk_asg%notfound then
                   open csr_get_start_date;
                   fetch csr_get_start_date into l_start_of_relevant_period;
                   close csr_get_start_date;
                end if;
                close csr_chk_asg;
            end if;
        else
            open csr_start_period;
            fetch csr_start_period into l_start_of_relevant_period;
            close csr_start_period;
        end if;
        --
        hr_utility.trace (l_proc||'     start of relevant period = '
                ||to_char (l_start_of_relevant_period));
        hr_utility.trace (l_proc||'     end of relevant period = '
                ||to_char (l_end_of_relevant_period));
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        end derive_relevant_period;
        --
procedure get_payroll_frequency is
        --
        -- Find out what payroll frequency the assignment is using
        --
        l_proc varchar2 (72) := g_package||'get_payroll_frequency';
        --
        cursor csr_payroll_frequency is
                --
                -- Get the payroll frequency for an assignment
                --
        -- This now returns all the payrolls that the person is on between the
        -- start and end of the 'relevant period', rather than just the payroll
        -- that the person is on as of the p_effective_date which is the
        -- PIW_start_date(SSP) or QW_start_date(SMP).
        --
        select  period_type.number_per_fiscal_year fiscal_year
        from    pay_all_payrolls_f          PAYROLL,
                per_all_assignments_f       ASSIGNMENT,
                per_time_period_types   PERIOD_TYPE
        where   assignment.assignment_id = l_assignment_id
        and     assignment.effective_start_date <= l_end_of_relevant_period
        and     assignment.effective_end_date >= l_start_of_relevant_period
        and     payroll.payroll_id = assignment.payroll_id
        and     payroll.period_type = period_type.period_type
        and     payroll.effective_start_date <= l_end_of_relevant_period
        and     payroll.effective_end_date >= l_start_of_relevant_period;
        --
        periods_per_fiscal_year number := 0;
        --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        l_payroll_frequency := 'MONTHLY';
        --
        for each_payroll in csr_payroll_frequency loop
            if each_payroll.fiscal_year <> 12 then
                l_payroll_frequency := 'NOT MONTHLY';
            end if;
        end loop;
        --
        hr_utility.trace ('l_payroll_frequency = '||l_payroll_frequency);
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        end get_payroll_frequency;
        --
procedure get_period_of_service is
        --
        -- Get the current period of service for the person
        --
        l_proc varchar2 (72) := g_package||'get_period_of_service';
        --
        cursor csr_period_of_service is
                --
                -- Get the period of service current as of a specified date
                --
                select  service.period_of_service_id,
                        service.date_start
                from    per_periods_of_service  SERVICE
                where   person_id = p_person_id
                and     p_effective_date between service.date_start
                                and nvl (service.actual_termination_date,
                                                hr_general.end_of_time);
                --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        -- Get the period of service current as of the effective date
        --
        open csr_period_of_service;
        fetch csr_period_of_service into l_period_of_service_id, l_hire_date;
        close csr_period_of_service;
        --
        hr_utility.trace (l_proc||'     l_period_of_service_id = '
                ||to_char (l_period_of_service_id));
        hr_utility.trace (l_proc||'     l_hire_date = '
                ||to_char (l_hire_date));
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        end get_period_of_service;
        --
procedure check_payroll_installed is
        --
        -- Checks that Payroll is installed before calculation of earnings is
        -- attempted.
        -- This code was copied and modified from hrapiapi.pkb
        --
        l_proc varchar2 (72) := g_package||'check_payroll_installed';
        l_pa_installed  fnd_product_installations.status%TYPE;
        l_industry      fnd_product_installations.industry%TYPE;
        l_pa_appid      fnd_product_installations.application_id%TYPE := 801;
        payroll_not_found       exception;
        --
        Begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        -- We need to determine if Payroll is installed.
        if (fnd_installation.get(
                --
                appl_id     => l_pa_appid,
                dep_appl_id => l_pa_appid,
                status      => l_pa_installed,
                industry    => l_industry))
        then
          --
          -- Check to see if the status = 'I'
          --
          If (l_pa_installed = 'I') then
            return; -- Payroll is installed
          else
            raise payroll_not_found;
          end If;
          --
        else
          raise payroll_not_found;
        end If;
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        exception
        when payroll_not_found then
          --
          -- Set warning message:
          -- "Average Earnings cannot be calculated automatically unless
          -- you have installed Oracle Payroll. You must enter the figure
          -- yourself."
          --
          ssp_smp_support_pkg.reason_for_no_earnings
                        := 'SSP_35024_NEED_PAYROLL_FOR_ERN';
          raise cannot_derive_earnings;
          --
        end check_payroll_installed;
        --
procedure stop_if_a_director is
        --
        cursor csr_director is
                select  1
                from    per_all_people_f
                where   per_information2 = 'Y' -- Director_flag
                and     person_id = p_person_id
                and     p_effective_date between effective_start_date
                                        and effective_end_date;
                --
        l_proc varchar2 (72) := g_package||'stop_if_a_director';
        l_dummy                 integer (1) := null;
        l_person_is_director    boolean := FALSE;
        --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        open csr_director;
        fetch csr_director into l_dummy;
        l_person_is_director := csr_director%found;
        close csr_director;
        --
        if l_person_is_director then
          --
          -- Set the warning message text to:
          -- "Oracle Payroll is unable to calculate the earnings of directors
          -- because it has no way to distinguish between voted fees and fees
          -- drawn in anticipation of voting. Please enter the average earnings
          -- figure for directors yourself."
          --
          ssp_smp_support_pkg.reason_for_no_earnings
                        := 'SSP_35025_NO_DIRECTOR_EARNINGS';
          raise cannot_derive_earnings;
          --
        end if;
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        end stop_if_a_director;
        --
function gross_NIable_pay
        --
        -- Calculate the gross NIable pay for an 8 week period
        --
        return number is
        --
        l_proc varchar2 (72) := g_package||'gross_NIable_pay';
        l_lel                   number := 0;
        l_weekly_pay            number(18,8) := 0;
        l_gross_NIable_pay      number := 0;
        l_gross_NIable_pay_acc  number(18,8) := 0;
        --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        for csr_Ne in csr_NIable_earnings ('NIable Pay')
        loop
           l_gross_NIable_pay_acc := csr_Ne.EARNINGS;
           l_gross_NIable_pay := l_gross_NIable_pay_acc;
        end loop;
        --
        hr_utility.trace('L_GROSS_NIABLE: '||l_gross_NIable_pay);
        --
        l_weekly_pay := l_gross_NIable_pay_acc * 6 / 52;
        l_lel := SSP_SMP_SUPPORT_PKG.NI_Lower_Earnings_Limit(
                                                     L_END_OF_RELEVANT_PERIOD);
        hr_utility.trace('l_lel: '||l_lel);
        --
        if l_weekly_pay < l_lel
        then
           for csr_Ne in csr_NIable_earnings ('NIable Earnings 1B')
           loop
              l_gross_NIable_pay_acc := l_gross_NIable_pay_acc+csr_Ne.EARNINGS;
              l_gross_NIable_pay := l_gross_NIable_pay_acc;
              --
              hr_utility.trace('L_GROSS_NIABLE inc 1B: '||l_gross_NIable_pay);
           end loop;
        end if;
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        return l_gross_NIable_pay;
        --
        end gross_NIable_pay;
        --
procedure do_monthly_calculation is
        --
        -- Calculate average earnings for an assignment on a monthly payroll.
        -- We handle calendar monthly payrolls separately because they have
        -- unequal numbers of days and so using the normal calculation method
        -- would give different results depending upon which months were being
        -- studied.
        --
        l_proc varchar2 (72) := g_package||'do_monthly_calculation';
        --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        --
        -- Take the gross payments from the last 2 months, multiply by 6 for
        -- the annual figure and divide by 52 for the weekly average
        --
        l_assignment_average :=
                l_assignment_average + ((gross_NIable_pay * 6) / 52);
        --
        hr_utility.trace (l_proc||'    gross_NIable_pay = '
                ||to_char (gross_NIable_pay));
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
        end do_monthly_calculation;
        --
procedure do_standard_calculation is
        --
        -- Calculate average weekly earnings for an assignment with any payroll
        -- frequency other than monthly, ie those consisting of equal numbers
        -- of days.
        --
        l_proc varchar2 (72) := g_package||'do_standard_calculation';
        l_days_covered  number := (l_end_of_relevant_period
                                        - greatest (l_start_of_relevant_period,
                                                        l_hire_date))
                                +1;
        --
        -- Csr_get_number_of_reg_payments is used in the new method of
        -- calculating weekly average earnings. Users will have to enter a
        -- value for a new element 'Average Earnings Period' to state the
        -- number of regular payment periods being processed in the one payroll
        -- process. If a value is returned then an irregular number of payments
        -- have been processed within the relevant period. The average amount
        -- is calculated as the total gross NIable pay / the number of periods
        -- paid. The value entered in this element is used to calculate the
        -- actual number of payment periods.
        --
        cursor csr_get_number_of_reg_payments is
        select peev.screen_entry_value
        from   per_all_assignments_f paf
        ,      pay_element_entry_values_f peev
        ,      pay_element_entries_f pee
        ,      pay_element_types_f pet
        ,      pay_element_links_f pel
        where  pee.element_entry_id = peev.element_entry_id
        and    pee.assignment_id = paf.assignment_id
        and    pet.element_type_id = pel.element_type_id
        and    pel.element_link_id = pee.element_link_id
        and    paf.assignment_id = l_assignment_id
        and    pet.element_name = 'Average Earnings Period'
        and    peev.effective_start_date between paf.effective_start_date
                                             and paf.effective_end_date
        and    peev.effective_start_date between pee.effective_start_date
                                             and pee.effective_end_date
        and    peev.effective_start_date between pet.effective_start_date
                                             and pet.effective_end_date
        and    peev.effective_start_date between pel.effective_start_date
                                             and pel.effective_end_date
        and    peev.effective_start_date
                    between greatest(l_start_of_relevant_period, l_hire_date)
                        and l_end_of_relevant_period
        and    peev.effective_end_date
                    between greatest(l_start_of_relevant_period, l_hire_date)
                        and l_end_of_relevant_period;
        --
        -- csr_number_of_days returns the payroll frequency that an assignment
        -- is on during the relevant period. If a person changes payroll within
        -- the relevant period, then they are considered to be on an irregular
        -- payroll and as such are calculated using do_standard_calculation,
        -- even if the person was on a Monthly payroll as some stage during the
        -- relevant period. Thus, if do_standard_calculation is being executed
        -- it is not for a Monthly payroll and so we never want csr_number_of
        -- _days to return a fiscal_year value of 12 (i.e. Monthly).
        --
        cursor csr_number_of_days is
            select  period_type.number_per_fiscal_year fiscal_year
            from    pay_all_payrolls_f          PAYROLL,
                    per_all_assignments_f       ASSIGNMENT,
                    per_time_period_types   PERIOD_TYPE
            where   assignment.assignment_id = l_assignment_id
            and     payroll.payroll_id = assignment.payroll_id
            and     payroll.period_type = period_type.period_type
            and     payroll.effective_start_date <= l_end_of_relevant_period
            and     payroll.effective_end_date >= l_start_of_relevant_period
            and     period_type.number_per_fiscal_year <> 12;
        --
        number_of_payments      number;
        total_number_payments   number;
        payroll_freq            number;
        number_of_days          number;
        user_ent_multi_reg_pays boolean;
        expected_num_of_periods number := null;
        --
        begin
        --
        hr_utility.set_location('Entering:'||l_proc,1);
        hr_utility.trace('days covered orig: '||l_days_covered);
        --
        -- Take the gross payments from the relevant period, divide by the
        -- number of days the payments cover, and multiply by 7.
        --
        number_of_payments      := 0;
        total_number_payments   := 0;
        --
        for payments in csr_get_number_of_reg_payments loop
           exit when csr_get_number_of_reg_payments%NOTFOUND
                  or csr_get_number_of_reg_payments%NOTFOUND is null;
            if payments.screen_entry_value < 1 then
               number_of_payments := -1;
            elsif payments.screen_entry_value >= 1 then
               number_of_payments := payments.screen_entry_value  -1;
            end if;

            total_number_payments := total_number_payments + number_of_payments;
            user_ent_multi_reg_pays := TRUE;
            hr_utility.trace('NUMBER OF PAYMENTS: '||number_of_payments);
        end loop;

        hr_utility.trace('TOTAL NUM PAYMENTS: '||total_number_payments);
--
        if user_ent_multi_reg_pays then
        --
        payroll_freq    := 0;
        number_of_days  := 0;
        --
        open csr_number_of_days;
        fetch csr_number_of_days into payroll_freq;
        close csr_number_of_days;
        --
        number_of_days := round(365/payroll_freq);
        --
        hr_utility.trace('PAYROLL FREQ: '||payroll_freq);
        hr_utility.trace('NUMBER OF DAYS: '||number_of_days);
        --
-- Next bit of code is for outputting the number of payments to the ssp entries
-- form. The value in form_variable is passed to the form via the function
-- number_of_periods. If the total_number_payments is 0 then then number of
-- payments in the relevant period is the regular number, so the value is not
-- output to the form. The user only wants to see a value on the form if it is
-- an irregular number of payment periods.
        --
        expected_num_of_periods := l_days_covered/number_of_days;
        --
        if total_number_payments = 0 then
           form_variable := null;
        else
           form_variable := expected_num_of_periods + total_number_payments;
        end if;
        --
        hr_utility.trace('expected num of periods '||expected_num_of_periods||
                         ', form variable '||form_variable);
        --
           l_days_covered := l_days_covered +
                                (number_of_days * total_number_payments);
        end if;
        hr_utility.trace('DAYS COVERED: '||l_days_covered);
        --
        if l_days_covered < 1 then
            l_assignment_average := 0;
        else
            l_assignment_average :=
                l_assignment_average + ((gross_NIable_pay
                                        -----------------
                                        / l_days_covered)
                                        * 7);
        end if;
        --
        hr_utility.trace('GROSS NIABLE PAY: '||gross_NIable_pay);
        hr_utility.trace ('l_days_covered = '||to_char (l_days_covered));
        hr_utility.trace ('l_assignment_average = '
                ||to_char (l_assignment_average));
        --
        hr_utility.set_location('Leaving :'||l_proc,100);
        --
end do_standard_calculation;
--
begin
--
hr_utility.set_location('Entering:'||l_proc, 1);
hr_utility.trace('P_EFFECTIVE_DATE IS: '||p_effective_date);
--
check_payroll_installed;
stop_if_a_director;
get_period_of_service;
--
FOR each_assignment in csr_set_of_current_assignments
LOOP
   -- Initialise assignment variables
   --
   l_assignment_id := each_assignment.assignment_id;
   l_assignment_average := 0;
   --
   derive_relevant_period;
   --
   l_new_employee := FALSE;
   --
   -- If the employee joined within the relevant period then we must note that
   -- fact for later  use.
   --
   if l_hire_date >= l_start_of_relevant_period
   then
     l_new_employee := TRUE;
     --
     hr_utility.trace ('Employee is NEW');
   end if;
   --
   -- The calculation of average earnings is done differently depending upon the
   -- payroll frequency. For new employees, we always treat them as if they were
   -- on irregular payroll frequencies so that we can pick up any payments they
   -- may have received.
   --
   get_payroll_frequency;
   --
   if l_payroll_frequency = 'MONTHLY' and not l_new_employee
   then
      do_monthly_calculation;
   else  -- any other payroll frequency or new employee
      do_standard_calculation;
   end if;
   --
   -- Increment the person's average earnings by the average earnings for the
   -- assignment just calculated.
   --
   l_person_average := l_person_average + l_assignment_average;
end loop;
--
if l_person_average = 0 and l_new_employee
then
   --
   -- If by the end of the calculation a new employee has zero average earnings
   -- it means he received no pay in the period. Therefore, we cannot calculate
   -- an average so it is determined by contracted pay. Since we cannot derive
   -- that, set a warning message telling the user why the earnings figure is
   -- zero: "Oracle Payroll cannot derive the average earnings for new employees
   -- who have not yet received any pay on which to base a calculation. Please
   -- enter the average earnings figure yourself, based upon the employee's
   -- contracted weekly earnings."
   --
   -- (abhaduri) 'IF' condition added to check for employees
   -- re-hired within 8 weeks of previous termination
   open csr_noof_periods_service;
   fetch csr_noof_periods_service into l_noof_periods_service;
   close csr_noof_periods_service;
   if l_noof_periods_service >1 then
   -- the employee has been re-hired
   -- check if the hiring has been within 8 weeks
    open csr_earlier_term;
    fetch csr_earlier_term into l_earlier_term_date;
    close csr_earlier_term;
    if l_hire_date - l_earlier_term_date <56 then
     ssp_smp_support_pkg.reason_for_no_earnings:='SSP_36076_EMP_REHIRED';
    else
      ssp_smp_support_pkg.reason_for_no_earnings:='SSP_35026_NO_NEW_EMP_EARNINGS';
    end if;
   else
   -- otherwise continue as earlier for a new employee
    ssp_smp_support_pkg.reason_for_no_earnings:= 'SSP_35026_NO_NEW_EMP_EARNINGS';
   end if;
   raise cannot_derive_earnings;
end if;
--
p_average_earnings_amount := nvl (round (l_person_average,2),0);
hr_utility.trace ('average earnings is '||to_char(l_person_average));
--
hr_utility.set_location('Leaving :'||l_proc, 100);
--
exception
when cannot_derive_earnings then
   hr_utility.set_location ('Leaving :'||l_proc||', exception',999);
   --
   p_average_earnings_amount := 0;
   --
   fnd_message.set_name ('SSP',ssp_smp_support_pkg.reason_for_no_earnings);
   --
   if p_user_entered = 'Y' then
      --
      -- We only fail the procedure if the user is entering the amount.
      -- If the system is calculating it (eg as part of the SSP/SMP process)
      -- then we must allow the process to continue and handle the error
      --
      fnd_message.raise_error;
  end if;
  --
end calculate_average_earnings;

-- ----------------------------------------------------------------------------
-- |---------------------------< number_of_periods >---------------------------|
-- ----------------------------------------------------------------------------
-- This function is used to pass the number of payment periods to the entries
-- form, SSPWSENT.
--
function number_of_periods return number is
--
        l_proc varchar2(72) := g_package||'number_of_periods';
begin
        hr_utility.set_location('Entering:'||l_proc, 1);
        --
        return form_variable;
        hr_utility.set_location('Leaving:'||l_proc, 100);
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call all supporting business operations
  --
  -- Following two calls are to ensure that the mandatory columns
  -- person_id and effective_date have been entered.
  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'person_id',
                              p_argument_value => p_rec.person_id);

  hr_api.mandatory_arg_error (p_api_name       => l_proc,
                              p_argument       => 'effective_date',
                              p_argument_value => p_rec.effective_date);
  --
  ssp_ern_bus.check_person_id(p_rec.person_id, p_rec.effective_date);
  --
  ssp_ern_bus.check_effective_date (p_rec.person_id, p_rec.effective_date);
  --
  if p_rec.average_earnings_amount is null
       or p_rec.average_earnings_amount = hr_api.g_number
  then
    p_rec.user_entered := 'N';
    ssp_ern_bus.calculate_average_earnings
       (p_rec.person_id,
        p_rec.effective_date,
        p_rec.average_earnings_amount,
        p_rec.user_entered,
	p_rec.absence_category --DFoster 1305683
       );
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in out nocopy ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call all supporting business operations
  --
  -- Following two bits of code used to ensure that the argument values
  -- have not been updated.
  --
  if (ssp_ern_shd.api_updating
          (p_earnings_calculations_id => p_rec.earnings_calculations_id,
           p_object_version_number    => p_rec.object_version_number)
       and
           p_rec.person_id <> ssp_ern_shd.g_old_rec.person_id)
  then
      hr_api.argument_changed_error
                     (p_api_name => l_proc, p_argument => 'Person_id');
  end if;

  if (ssp_ern_shd.api_updating
          (p_earnings_calculations_id => p_rec.earnings_calculations_id,
           p_object_version_number    => p_rec.object_version_number)
       and
           p_rec.effective_date <> ssp_ern_shd.g_old_rec.effective_date)
  then
      hr_api.argument_changed_error
                     (p_api_name => l_proc, p_argument => 'effective_date');
  end if;

  if p_rec.average_earnings_amount is null
       or p_rec.average_earnings_amount = hr_api.g_number
  then
    p_rec.user_entered := 'N';
    ssp_ern_bus.calculate_average_earnings
       (ssp_ern_shd.g_old_rec.person_id,
        ssp_ern_shd.g_old_rec.effective_date,
        p_rec.average_earnings_amount,
        p_rec.user_entered,
	p_rec.absence_category --DFoster 1304683
       );
  end if;
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ssp_ern_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- Call all supporting business operations - there are none
  --
  hr_utility.set_location('Leaving :'||l_proc, 100);
End delete_validate;
--
end ssp_ern_bus;

/
