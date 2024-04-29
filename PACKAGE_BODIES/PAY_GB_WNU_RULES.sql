--------------------------------------------------------
--  DDL for Package Body PAY_GB_WNU_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_WNU_RULES" as
/* $Header: pygbwnu1.pkb 115.6 2003/12/18 00:27:09 asengar noship $ */
Procedure wnu_update
  (p_assignment_id                in    number,
   p_effective_date               in    date,
   p_assignment_number            in    varchar2 default null,
   p_assignment_number_old        in    varchar2 default null,
   p_not_included_in_wnu          in    varchar2 default null,
   p_object_version_number        in out NOCOPY number,
   p_assignment_extra_info_id     out NOCOPY  number
  ) is
--
l_ass_extra_info_id      number(9):= null;
l_ass_extra_info_id_out  number(9);
l_legislation_code       varchar2(2);
l_proc                   varchar2(72) := 'pay_gb_wnu_rules';
l_current_employee       varchar2(30) := null;
l_assignment_id          number(15):= null;
l_ass_number             varchar2(30):= null;
l_ass_number_old         varchar2(30):= null;
l_not_included_in_wnu    varchar2(30);
l_ovn                    number(15):=null;
l_ovn_out                number(15);
--
cursor csr_employee is
       select upper(apf.current_employee_flag)
       from   per_all_people_f apf,
	      per_all_assignments_f aaf
       where  aaf.person_id = apf.person_id
       and    aaf.assignment_id = p_assignment_id
       and    p_effective_date between
	      apf.effective_start_date and apf.effective_end_date;
--
cursor csr_extra_info is
       select aei.assignment_extra_info_id ,
              object_version_number,
              aei_information2
       from   per_assignment_extra_info aei
       where  aei.assignment_id = p_assignment_id
       and    information_type = 'GB_WNU';
--
cursor csr_bg is
       select pbg.legislation_code
       from   per_business_groups pbg,
	      per_all_assignments_f aaf
       where  aaf.assignment_id = p_assignment_id
       and    aaf.business_group_id = pbg.business_group_id
       and    p_effective_date between
	      aaf.effective_start_date and aaf.effective_end_date;
--
begin
--
hr_utility.set_location('Entering:'|| l_proc, 10);
--
-- Assign Variables
--
l_assignment_id := p_assignment_id;
l_ass_number_old := p_assignment_number_old;
l_ass_number := p_assignment_number;
--
-- Only perform the upadate if the Assignment Numer
-- has been amended.

--if upper(l_ass_number) <> upper(l_ass_number_old) then

--
-- Will only update Currnt Employee Records
--
  open csr_employee;
  fetch csr_employee into l_current_employee ;
  close csr_employee;
--
  if l_current_employee = 'Y' then
--
-- Validation in addition to Row Handlers
-- Check that the specified business group is valid.
--
    open csr_bg;
    fetch csr_bg into l_legislation_code;
    if csr_bg%notfound then
        close csr_bg;
        hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
    end if;
    --
    close csr_bg;
    --
    -- Check that the legislation of the specified business
    -- group is 'GB'. Allow for the fact that the package
    -- could be called via API or Forms.
    --
    if l_legislation_code = 'GB' then
    --
         --
         -- check to see if assignment extra info
         -- exists for this assignemnt_id
         --
         open csr_extra_info;
         fetch csr_extra_info into l_ass_extra_info_id, l_ovn, l_not_included_in_wnu;

         if csr_extra_info%notfound then
           --
           hr_utility.set_location(l_proc, 20);
           --
           -- Create an entry for WNU
           --
           if p_not_included_in_wnu is not null then
             l_not_included_in_wnu := p_not_included_in_wnu;
           else
             l_not_included_in_wnu := 'N';
           end if;
           hr_assignment_extra_info_api.create_assignment_extra_info
            (p_validate                       => false,
             p_assignment_id                  => l_assignment_id,
             p_information_type               => 'GB_WNU',
	     p_aei_information_category       => 'GB_WNU',
	     p_aei_information1               => l_ass_number_old,
             p_aei_information2               => l_not_included_in_wnu,
	     p_object_version_number          => l_ovn_out,
             p_assignment_extra_info_id       => l_ass_extra_info_id_out
            );

             p_object_version_number := l_ovn_out;
             p_assignment_extra_info_id := l_ass_extra_info_id_out;
           close csr_extra_info;

          else
             --
             hr_utility.set_location(l_proc, 30);
             --
             -- Update Existing Entry for WNU
             --
             if p_not_included_in_wnu is not null then
                l_not_included_in_wnu := p_not_included_in_wnu;
             end if;
             hr_assignment_extra_info_api.update_assignment_extra_info
            (p_validate                       => false,
	     p_object_version_number          => l_ovn,
             p_assignment_extra_info_id       => l_ass_extra_info_id,
             p_aei_information_category       => 'GB_WNU',
             p_aei_information1               => l_ass_number_old,
             p_aei_information2               => l_not_included_in_wnu
            );
             p_object_version_number := l_ovn;
         --
            close csr_extra_info;
         --
           end if ;
         --
        end if;
     --
     end if;
     --
--end if;
--
hr_utility.set_location('Leaving:'|| l_proc, 100);
--
end;
--
-- BUG 3294480 Added this for the case when NI gets updated
Procedure wnu_update
  (p_person_id                    in number,
   p_effective_date               in    date,
   p_aggregated_assignment        in    varchar2 default null,
   p_ni_number_update             in    varchar2 default null,
   p_not_included_in_wnu          in    varchar2 default null,
   p_object_version_number        in out NOCOPY number,
   p_assignment_extra_info_id     out NOCOPY  number
  ) is
--
l_ass_extra_info_id      number(9):= null;
l_ass_extra_info_id_out  number(9);
l_legislation_code       varchar2(2);
l_proc                   varchar2(72) := 'pay_gb_wnu_rules';
l_current_employee       varchar2(30) := null;
l_assignment_id          number(15):= null;
l_ass_number             varchar2(30):= null;
l_ass_number_old         varchar2(30):= null;
l_not_included_in_wnu    varchar2(30);
l_ovn                    number(15):=null;
l_ovn_out                number(15);
l_ni_number_update       varchar2(30):= null;
--
cursor csr_employee is
       select upper(apf.current_employee_flag)
       from   per_all_people_f apf
       where  apf.person_id = p_person_id
       and    p_effective_date between
	      apf.effective_start_date and apf.effective_end_date;
--
cursor csr_extra_info(c_assignment_id NUMBER) is
       select aei.assignment_extra_info_id ,
              object_version_number,
              aei_information1,
              aei_information2,
              aei_information3
       from   per_assignment_extra_info aei
       where  aei.assignment_id = c_assignment_id
       and    information_type = 'GB_WNU';
--
cursor csr_assignment is
       select aaf.assignment_id assignment_id
       from  per_all_assignments_f aaf
       where aaf.person_id = p_person_id
       and   p_effective_date between
	     aaf.effective_start_date and aaf.effective_end_date;
--
cursor csr_bg(c_assignment_id NUMBER) is
       select pbg.legislation_code
       from   per_business_groups pbg,
	      per_all_assignments_f aaf
       where  aaf.assignment_id = c_assignment_id
       and    aaf.business_group_id = pbg.business_group_id
       and    p_effective_date between
	      aaf.effective_start_date and aaf.effective_end_date;
--
cursor csr_agg_assignment is
       select min(aaf.assignment_id) assignment_id
       from  per_all_assignments_f aaf,
             hr_soft_coding_keyflex hsck,
             pay_all_payrolls_f papf,
             per_assignment_status_types past
       where aaf.person_id = p_person_id
       AND   p_effective_date between
	     aaf.effective_start_date and aaf.effective_end_date
       AND   hsck.soft_coding_keyflex_id = papf.soft_coding_keyflex_id
       AND   papf.payroll_id =aaf.payroll_id
       AND   past.assignment_status_type_id = aaf.assignment_status_type_id
       AND   aaf.person_id = p_person_id
       AND   past.per_system_status='ACTIVE_ASSIGN'
       AND   p_effective_date BETWEEN aaf.effective_start_date AND aaf.effective_end_date
       AND   p_effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
       AND   hsck.segment1 in ( SELECT distinct(hsck.segment1)
                               FROM hr_soft_coding_keyflex hsck2,
                                    pay_all_payrolls_f papf2,
                                    per_all_assignments_f paaf,
                                    per_assignment_status_types past2
                               WHERE hsck2.soft_coding_keyflex_id = papf2.soft_coding_keyflex_id
                               AND papf2.payroll_id =paaf.payroll_id
                               AND past2.assignment_status_type_id = paaf.assignment_status_type_id
                               AND paaf.person_id = p_person_id
                               AND past2.per_system_status='ACTIVE_ASSIGN'
                               AND p_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
                               AND p_effective_date BETWEEN papf2.effective_start_date AND papf2.effective_end_date)
       GROUP BY hsck.segment1;
--
begin
--
hr_utility.set_location('Entering:'|| l_proc, 10);

-- Will only update Currnt Employee Records
--
  open csr_employee;
  fetch csr_employee into l_current_employee ;
  close csr_employee;
--
  if l_current_employee = 'Y' then
--
-- Validation in addition to Row Handlers
-- Check that the specified business group is valid.
--
  if p_aggregated_assignment = 'Y' then
-- This is for the case when there are aggregated assignments.
--
  for asg_id in csr_agg_assignment loop
--
      open csr_bg(asg_id.assignment_id);
      fetch csr_bg into l_legislation_code;
      if csr_bg%notfound then
          close csr_bg;
          hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
          hr_utility.raise_error;
      end if;
      --
      close csr_bg;
      --
      -- Check that the legislation of the specified business
      -- group is 'GB'. Allow for the fact that the package
      -- could be called via API or Forms.
      --
      if l_legislation_code = 'GB' then
      --
           --
           -- check to see if assignment extra info
           -- exists for this assignemnt_id
           --
           open csr_extra_info(asg_id.assignment_id);
           fetch csr_extra_info into l_ass_extra_info_id, l_ovn,l_ass_number_old, l_not_included_in_wnu,l_ni_number_update;

           if csr_extra_info%notfound then
             --
             hr_utility.set_location(l_proc, 20);
             --
             -- Create an entry for WNU
             --
             if p_not_included_in_wnu is not null then
               l_not_included_in_wnu := p_not_included_in_wnu;
             else
               l_not_included_in_wnu := 'N';
             end if;
             hr_assignment_extra_info_api.create_assignment_extra_info
              (p_validate                       => false,
               p_assignment_id                  => asg_id.assignment_id,
               p_information_type               => 'GB_WNU',
  	       p_aei_information_category       => 'GB_WNU',
  	       p_aei_information1               =>  null,
               p_aei_information2               => l_not_included_in_wnu,
               p_aei_information3               => p_ni_number_update,
  	       p_object_version_number          => l_ovn_out,
               p_assignment_extra_info_id       => l_ass_extra_info_id_out
              );

               p_object_version_number := l_ovn_out;
               p_assignment_extra_info_id := l_ass_extra_info_id_out;
             close csr_extra_info;

            else
               --
               hr_utility.set_location(l_proc, 30);
               --
               -- Update Existing Entry for WNU
               --
               if p_not_included_in_wnu is not null then
                  l_not_included_in_wnu := p_not_included_in_wnu;
               end if;
               if nvl(l_ni_number_update,'N') <> 'Y' then
               hr_assignment_extra_info_api.update_assignment_extra_info
              (p_validate                       => false,
  	       p_object_version_number          => l_ovn,
               p_assignment_extra_info_id       => l_ass_extra_info_id,
               p_aei_information_category       => 'GB_WNU',
               p_aei_information1               => l_ass_number_old,
               p_aei_information2               => l_not_included_in_wnu,
               p_aei_information3               => p_ni_number_update
              );
               p_object_version_number := l_ovn;
               --
               end if;
           --
              close csr_extra_info;
           --
             end if ;
           --
      end if;
           --
    end loop;
  else
  -- This is for the case when there are no aggregated assignment
  for asg_id in csr_assignment loop

    open csr_bg(asg_id.assignment_id);
    fetch csr_bg into l_legislation_code;
    if csr_bg%notfound then
        close csr_bg;
        hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
        hr_utility.raise_error;
    end if;
    --
    close csr_bg;
    --
    -- Check that the legislation of the specified business
    -- group is 'GB'. Allow for the fact that the package
    -- could be called via API or Forms.
    --
    if l_legislation_code = 'GB' then
    --
         --
         -- check to see if assignment extra info
         -- exists for this assignemnt_id
         --
         open csr_extra_info(asg_id.assignment_id);
         fetch csr_extra_info into l_ass_extra_info_id, l_ovn,l_ass_number_old, l_not_included_in_wnu,l_ni_number_update;

         if csr_extra_info%notfound then
           --
           hr_utility.set_location(l_proc, 20);
           --
           -- Create an entry for WNU
           --
           if p_not_included_in_wnu is not null then
             l_not_included_in_wnu := p_not_included_in_wnu;
           else
             l_not_included_in_wnu := 'N';
           end if;
           hr_assignment_extra_info_api.create_assignment_extra_info
            (p_validate                       => false,
             p_assignment_id                  => asg_id.assignment_id,
             p_information_type               => 'GB_WNU',
	     p_aei_information_category       => 'GB_WNU',
	     p_aei_information1               => null,
             p_aei_information2               => l_not_included_in_wnu,
	     p_object_version_number          => l_ovn_out,
             p_assignment_extra_info_id       => l_ass_extra_info_id_out,
             p_aei_information3               => p_ni_number_update
            );

             p_object_version_number := l_ovn_out;
             p_assignment_extra_info_id := l_ass_extra_info_id_out;
           close csr_extra_info;

          else
             --
             hr_utility.set_location(l_proc, 30);
             --
             -- Update Existing Entry for WNU
             --
             if p_not_included_in_wnu is not null then
                l_not_included_in_wnu := p_not_included_in_wnu;
             end if;
             if nvl(l_ni_number_update,'N') <> 'Y' then
             hr_assignment_extra_info_api.update_assignment_extra_info
            (p_validate                       => false,
	     p_object_version_number          => l_ovn,
             p_assignment_extra_info_id       => l_ass_extra_info_id,
             p_aei_information_category       => 'GB_WNU',
             p_aei_information1               => l_ass_number_old,
             p_aei_information2               => l_not_included_in_wnu,
             p_aei_information3               => p_ni_number_update
             );
             p_object_version_number := l_ovn;
         --
            end if;
            close csr_extra_info;
         --
           end if ;
         --
        end if;
     --
        end loop;
     end if;
     --
end if;
--
hr_utility.set_location('Leaving:'|| l_proc, 100);
--
end;
--
end pay_gb_wnu_rules;

/
