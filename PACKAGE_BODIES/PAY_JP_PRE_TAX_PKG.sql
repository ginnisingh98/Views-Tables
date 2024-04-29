--------------------------------------------------------
--  DDL for Package Body PAY_JP_PRE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_PRE_TAX_PKG" AS
/* $Header: pyjppret.pkb 120.5 2006/09/14 13:39:17 sgottipa noship $ */

-----------------------------------------------------------------------
	FUNCTION ERROR_MESSAGE(p_error_name VARCHAR2) RETURN VARCHAR2
-----------------------------------------------------------------------
	IS
		l_message	VARCHAR2(255);
	BEGIN
		if p_error_name = 'INVALID_MODE' then
			fnd_message.set_name('PAY','PAY_JP_INVALID_MODE');
			l_message := fnd_message.get;
		elsif p_error_name = 'ASSACT_NOT_FOUND' then
			fnd_message.set_name('PAY','PAY_JP_ASSACT_NOT_EXISTS');
			l_message := fnd_message.get;
		elsif p_error_name = 'ASSACT_STATUS_UP' then
			fnd_message.set_name('PAY','PAY_JP_ASSACT_PROCESSING');
			l_message := fnd_message.get;
		elsif p_error_name = 'ASSACT_STATUS_UPC' then
			fnd_message.set_name('PAY','PAY_JP_ASSACT_PROC_COMPLETED');
			l_message := fnd_message.get;
		else
			l_message := NULL;
		end if;

		return	l_message;
	END ERROR_MESSAGE;

-----------------------------------------------------------------------
	PROCEDURE RUN_ASSACT(
-----------------------------------------------------------------------
	  p_errbuf			 OUT NOCOPY VARCHAR2,
	  p_retcode			 OUT NOCOPY VARCHAR2,
	  p_locked_assignment_action_id	 IN  pay_assignment_actions.assignment_action_id%TYPE,
          p_locking_assignment_action_id IN  pay_assignment_actions.assignment_action_id%TYPE )
	IS
                l_effective_date        pay_payroll_actions.effective_date%TYPE;
                l_value                 pay_jp_custom_pkg.value_rec;
                l_business_group_id     pay_payroll_actions.business_group_id%TYPE;
                l_assact_action_status  pay_assignment_actions.action_status%TYPE;
                l_date_earned           pay_payroll_actions.date_earned%TYPE;
                l_assignment_id         pay_assignment_actions.assignment_id%TYPE;

		----------------------------------------
		-- Cursor
		----------------------------------------
                CURSOR csr_assact IS
                  select  ppa.business_group_id,
                          paa.action_status       ASSACT_ACTION_STATUS,
                          ppa.date_earned,
                          ppa.effective_date,
                          paa.assignment_id
                  from    pay_payroll_actions     ppa,
                          pay_assignment_actions  paa
                  where   paa.assignment_action_id=p_locked_assignment_action_id
                  and     paa.action_status='C'
                  and     ppa.payroll_action_id=paa.payroll_action_id
                  and     ppa.action_type in ('R','Q','B','I')
                for update of paa.assignment_action_id;
--
      PROCEDURE get_assignment_details(
             p_errbuf                   OUT NOCOPY VARCHAR2,
             p_retcode                  OUT NOCOPY VARCHAR2,
             p_assignment_id            IN  pay_assignment_actions.assignment_id%TYPE,
             p_effective_date           IN  pay_payroll_actions.effective_date%TYPE,
             p_person_id                OUT NOCOPY per_all_assignments_f.person_id%TYPE,
             p_period_of_service_id     OUT NOCOPY per_all_assignments_f.period_of_service_id%TYPE,
             p_date_start               OUT NOCOPY per_periods_of_service.date_start%TYPE,
             p_leaving_reason           OUT NOCOPY per_periods_of_service.leaving_reason%TYPE,
             p_actual_termination_date  OUT NOCOPY per_periods_of_service.actual_termination_date%TYPE,
             p_employment_category      OUT NOCOPY per_all_assignments_f.employment_category%TYPE)
      IS

      BEGIN

        hr_utility.set_location('pay_jp_pre_tax_pkg.get_assignment_details',10);

        select asg.person_id,
               asg.period_of_service_id,
               pds.date_start,
               pds.leaving_reason,
               pds.actual_termination_date,
               asg.employment_category
        into   p_person_id,
               p_period_of_service_id,
               p_date_start,
               p_leaving_reason,
               p_actual_termination_date,
               p_employment_category
        from   per_all_assignments_f  asg,
               per_periods_of_service pds
        where  asg.assignment_id = p_assignment_id
        and    p_effective_date between asg.effective_start_date and asg.effective_end_date
        and    pds.period_of_service_id = asg.period_of_service_id;

      EXCEPTION

        WHEN OTHERS THEN

          hr_utility.set_location('pay_jp_pre_tax_pkg.get_assignment_details',20);

          p_errbuf  := substrb(sqlerrm,1,255);
          p_retcode := '2';

      END get_assignment_details;
--
      PROCEDURE insert_row(
        p_errbuf                       OUT NOCOPY VARCHAR2,
        p_retcode                      OUT NOCOPY VARCHAR2,
        p_locked_assignment_action_id  IN pay_assignment_actions.assignment_action_id%TYPE,
        p_locking_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
        p_assignment_id                IN pay_assignment_actions.assignment_id%TYPE,
        p_effective_date               IN pay_payroll_actions.effective_date%TYPE,
        p_value                        IN pay_jp_custom_pkg.value_rec)
      IS
        l_action_status            VARCHAR2(1);
        l_message                  VARCHAR2(255);
        l_person_id                per_all_assignments_f.person_id%TYPE;
        l_period_of_service_id     per_all_assignments_f.period_of_service_id%TYPE;
        l_date_start               per_periods_of_service.date_start%TYPE;
        l_leaving_reason           per_periods_of_service.leaving_reason%TYPE;
        l_actual_termination_date  per_periods_of_service.actual_termination_date%TYPE;
        l_employment_category      per_all_assignments_f.employment_category%TYPE;

                  l_action_info_id1 pay_action_information.action_information_id%TYPE;
                  l_action_info_id2 pay_action_information.action_information_id%TYPE;
                  l_ovn             pay_action_information.object_version_number%TYPE;

      BEGIN

        hr_utility.set_location('pay_jp_pre_tax_pkg.insert_row',10);

        pay_jp_custom_pkg.validate_record(
                        p_value         => p_value,
                        p_action_status => l_action_status,
                        p_message       => l_message);

        p_errbuf  := substrb(l_message,1,255);
        if l_action_status = 'C' then
          p_retcode := '0';
        elsif l_action_status = 'I' then
          p_retcode := '1';
        elsif l_action_status = 'E' then
          p_retcode := '2';
        end if;

        if l_action_status = 'C' then

          get_assignment_details(
            p_errbuf                    =>  p_errbuf
            ,p_retcode                  =>  p_retcode
            ,p_assignment_id            =>  p_assignment_id
            ,p_effective_date           =>  p_effective_date
            ,p_person_id                =>  l_person_id
            ,p_period_of_service_id     =>  l_period_of_service_id
            ,p_date_start               =>  l_date_start
            ,p_leaving_reason           =>  l_leaving_reason
            ,p_actual_termination_date  =>  l_actual_termination_date
            ,p_employment_category      =>  l_employment_category
          );

          if (l_person_id is not null) then

            pay_action_information_api.create_action_information
            (
            p_action_information_id         =>  l_action_info_id1
           ,p_action_context_id             =>  p_locking_assignment_action_id
           ,p_action_context_type           =>  'AAP'
           ,p_object_version_number         =>  l_ovn
           ,p_effective_date                =>  p_effective_date
           ,p_assignment_id                 =>  p_assignment_id
           ,p_action_information_category   =>  'JP_PRE_TAX_1'
           ,p_action_information1      =>  p_locked_assignment_action_id
           ,p_action_information2      =>  fnd_number.number_to_canonical(p_value.taxable_sal_amt)
           ,p_action_information3      =>  fnd_number.number_to_canonical(p_value.taxable_mat_amt)
           ,p_action_information4      =>  fnd_number.number_to_canonical(l_person_id)
           ,p_action_information5      =>  p_value.hi_org_id
           ,p_action_information6      =>  fnd_number.number_to_canonical(p_value.hi_prem_ee)
           ,p_action_information7      =>  fnd_number.number_to_canonical(p_value.hi_prem_er)
           ,p_action_information8      =>  p_value.wp_org_id
           ,p_action_information9      =>  fnd_number.number_to_canonical(p_value.wp_prem_ee)
           ,p_action_information10     =>  fnd_number.number_to_canonical(p_value.wp_prem_er)
           ,p_action_information11     =>  p_value.wpf_org_id
           ,p_action_information12     =>  fnd_number.number_to_canonical(p_value.wpf_prem_ee)
           ,p_action_information13     =>  p_value.salary_category
           ,p_action_information14     =>  fnd_number.number_to_canonical(p_value.mutual_aid)
           ,p_action_information15     =>  fnd_number.number_to_canonical(l_period_of_service_id)
           ,p_action_information16     =>  fnd_date.date_to_canonical(l_date_start)
           ,p_action_information17     =>  l_leaving_reason
           ,p_action_information18     =>  fnd_date.date_to_canonical(l_actual_termination_date)
           ,p_action_information19     =>  p_value.ui_org_id
           ,p_action_information20     =>  fnd_number.number_to_canonical(p_value.ui_prem_ee)
           ,p_action_information21     =>  p_value.itax_org_id
           ,p_action_information22     =>  p_value.itax_category
           ,p_action_information23     =>  p_value.itax_yea_category
           ,p_action_information24     =>  fnd_number.number_to_canonical(p_value.itax)
           ,p_action_information25     =>  fnd_number.number_to_canonical(p_value.itax_adjustment)
           ,p_action_information29     =>  fnd_number.number_to_canonical(p_value.disaster_tax_reduction)
           ,p_action_information30     =>  l_employment_category
          );

            pay_action_information_api.create_action_information
            (
            p_action_information_id         =>  l_action_info_id2
           ,p_action_context_id             =>  p_locking_assignment_action_id
           ,p_action_context_type           =>  'AAP'
           ,p_object_version_number         =>  l_ovn
           ,p_effective_date                =>  p_effective_date
           ,p_assignment_id                 =>  p_assignment_id
           ,p_action_information_category   =>  'JP_PRE_TAX_2'
           ,p_action_information1      =>  p_locked_assignment_action_id
           ,p_action_information3      =>  p_value.ltax_district_code
           ,p_action_information5      =>  fnd_number.number_to_canonical(p_value.ltax)
           ,p_action_information6      =>  fnd_number.number_to_canonical(p_value.ltax_lumpsum)
           ,p_action_information7      =>  fnd_number.number_to_canonical(p_value.sp_ltax)
           ,p_action_information8      =>  fnd_number.number_to_canonical(p_value.sp_ltax_income)
           ,p_action_information9      =>  fnd_number.number_to_canonical(p_value.sp_ltax_shi)
           ,p_action_information10     =>  fnd_number.number_to_canonical(p_value.sp_ltax_to)
           ,p_action_information11     =>  fnd_number.number_to_canonical(p_value.ci_prem_ee)
           ,p_action_information12     =>  fnd_number.number_to_canonical(p_value.ci_prem_er)
           ,p_action_information14     =>  p_value.ui_category
           ,p_action_information15     =>  p_value.sp_ltax_district_code
           ,p_action_information16     =>  fnd_number.number_to_canonical(p_value.ui_sal_amt)
           ,p_action_information17     =>  p_value.wai_org_id
           ,p_action_information18     =>  p_value.wai_category
           ,p_action_information19     =>  fnd_number.number_to_canonical(p_value.wai_sal_amt)
           ,p_action_information20     =>  fnd_number.number_to_canonical(p_value.wpf_prem_er)
          );

        end if;

      end if;

      hr_utility.set_location('pay_jp_pre_tax_pkg.insert_row',20);

      EXCEPTION

        WHEN OTHERS THEN

          hr_utility.set_location('pay_jp_pre_tax_pkg.insert_row',20);

          p_errbuf  := substrb(sqlerrm,1,255);
          p_retcode := '2';

    END insert_row;

  BEGIN
    hr_utility.set_location('pay_jp_pre_tax_pkg.run_assact',10);

    open csr_assact;
    fetch csr_assact into l_business_group_id,
                          l_assact_action_status,
                          l_date_earned,
                          l_effective_date,
                          l_assignment_id;
    if csr_assact%NOTFOUND then
      close csr_assact;
      p_errbuf	:= error_message('ASSACT_NOT_FOUND');
      p_retcode	:= '1';
      return;
    end if;
    close csr_assact;

    pay_jp_custom_pkg.fetch_values(
      P_BUSINESS_GROUP_ID     => l_business_group_id,
      P_ASSIGNMENT_ACTION_ID  => p_locked_assignment_action_id,
      P_ASSIGNMENT_ID         => l_assignment_id,
      P_DATE_EARNED           => l_date_earned,
      P_VALUE                 => l_value);

    insert_row(
      p_errbuf                         =>  p_errbuf
      ,p_retcode                       =>  p_retcode
      ,p_locked_assignment_action_id   =>  p_locked_assignment_action_id
      ,p_locking_assignment_action_id  =>  p_locking_assignment_action_id
      ,p_assignment_id                 =>  l_assignment_id
      ,p_effective_date                =>  l_effective_date
      ,p_value                         =>  l_value
    );

    hr_utility.set_location('pay_jp_pre_tax_pkg.run_assact',20);

  EXCEPTION
    when OTHERS then
      p_errbuf	:= substrb(sqlerrm,1,255);
      p_retcode := '2';
  END RUN_ASSACT;

-----------------------------------------------------------------------
        PROCEDURE REFRESH(
-----------------------------------------------------------------------
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY VARCHAR2)
        IS
        BEGIN
                -- Delete rollbacked assignment_action_id.
                delete pay_action_information  pai
                where  (action_information_category='JP_PRE_TAX_1'
                        or action_information_category='JP_PRE_TAX_2')
                and    action_context_type='AAP'
                and    not exists(
                                select  NULL
                                from    pay_assignment_actions  paa
                                where   paa.assignment_action_id=pai.action_information1);

                commit;

                retcode := '0';
        EXCEPTION
                when OTHERS then
                        errbuf  := substrb(sqlerrm,1,255);
                        retcode := '2';
        END REFRESH;
--
-----------------------------------------------------------------------
             PROCEDURE ROLLBACK_ASSACT(
-----------------------------------------------------------------------
               p_errbuf            OUT NOCOPY VARCHAR2,
               p_retcode           OUT NOCOPY VARCHAR2,
               p_business_group_id IN  pay_payroll_actions.business_group_id%TYPE,
               p_payroll_id        IN  pay_all_payrolls_f.payroll_id%TYPE,
               p_from_date         IN  DATE,
               p_to_date           IN  DATE) IS
--

  CURSOR csr_assact IS
    SELECT DISTINCT paa1.assignment_action_id, ppa1.payroll_action_id
    FROM   pay_payroll_actions ppa, pay_assignment_actions paa,
           pay_payroll_actions ppa1, pay_assignment_actions paa1,
           pay_action_information pai
    WHERE  ppa.business_group_id = p_business_group_id
    AND    ppa.payroll_id = p_payroll_id
    AND    ppa.date_earned BETWEEN p_from_date AND p_to_date
    AND    ppa.payroll_action_id = paa.payroll_action_id
    AND    pai.action_information_category = 'JP_PRE_TAX_1'
    AND    pai.action_context_type = 'AAP'
    AND    pai.action_information1 = paa.assignment_action_id
    AND    pai.action_context_id = paa1.assignment_action_id
    AND    paa1.payroll_action_id = ppa1.payroll_action_id
    AND    ppa1.business_group_id = p_business_group_id
    AND    ppa1.action_type = 'X';

  TYPE t_assact_rec IS RECORD(
    payroll_action_id pay_payroll_actions.payroll_action_id%TYPE,
    assignment_action_id pay_assignment_actions.assignment_action_id%TYPE);

  TYPE t_assact_tab IS TABLE OF t_assact_rec INDEX BY BINARY_INTEGER;

  l_assact_tab         t_assact_tab;

  l_payroll_action_id  pay_payroll_actions.payroll_action_id%TYPE;
  l_index              NUMBER := 1;
  l_count              NUMBER;

BEGIN

  l_assact_tab.DELETE;

  for l_assact_rec in csr_assact
  loop

    l_assact_tab(l_index).payroll_action_id := l_assact_rec.payroll_action_id;
    l_assact_tab(l_index).assignment_action_id := l_assact_rec.assignment_action_id;
    l_index := l_index+1;

  end loop;

  if (l_index<>1) then

    for l_count in 1..l_assact_tab.COUNT
    loop

      py_rollback_pkg.rollback_ass_action(
          p_assignment_action_id=>l_assact_tab(l_count).assignment_action_id);

    end loop;

    l_count := l_assact_tab.COUNT;

    l_payroll_action_id := l_assact_tab(l_count).payroll_action_id;

    SELECT COUNT(1)
    INTO   l_count
    FROM   pay_assignment_actions
    WHERE  payroll_action_id = l_payroll_action_id;

    IF (l_count=0) THEN
      py_rollback_pkg.rollback_payroll_action(
          p_payroll_action_id=>l_payroll_action_id);
    END IF;

    commit;

  end if;

  p_retcode := '0';

EXCEPTION
  when OTHERS then
    p_errbuf  := substrb(sqlerrm,1,255);
    p_retcode := '2';

END ROLLBACK_ASSACT;
--
-----------------------------------------------------------------------
        PROCEDURE RUN_SINGLE_ASSACT(
-----------------------------------------------------------------------
          p_errbuf               OUT NOCOPY VARCHAR2,
          p_retcode              OUT NOCOPY VARCHAR2,
          p_assignment_action_id IN  pay_assignment_actions.assignment_action_id%TYPE) IS

  l_count NUMBER;

  l_errbuf  VARCHAR2(255);
  l_retcode CHAR(1) := '0';

BEGIN

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_action_information
  WHERE  action_information_category = 'JP_PRE_TAX_1'
  AND    action_context_type = 'AAP'
  AND    action_information1 = p_assignment_action_id;

  if (l_count=0) then

    run_assact(
      p_errbuf			     => l_errbuf,
      p_retcode			     => l_retcode,
      p_locked_assignment_action_id  => p_assignment_action_id,
      p_locking_assignment_action_id => p_assignment_action_id);

    if (NVL(l_retcode,'0')='0') then
      commit;
    end if;

  end if;

  p_errbuf  := l_errbuf;
  p_retcode := l_retcode;

EXCEPTION
  when OTHERS then
    p_errbuf  := substrb(sqlerrm,1,255);
    p_retcode := '2';

END RUN_SINGLE_ASSACT;
--
END PAY_JP_PRE_TAX_PKG;

/
