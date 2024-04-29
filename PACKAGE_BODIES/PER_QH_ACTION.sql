--------------------------------------------------------
--  DDL for Package Body PER_QH_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_ACTION" as
/* $Header: peqhactn.pkb 120.5.12010000.2 2009/08/24 12:07:15 sgundoju ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_qh_action.';
procedure quick_hire_applicant
  (p_validate                  in      boolean   default false,
   p_hire_date                 in      date,
   p_person_id                 in      per_all_people_f.person_id%TYPE,
   p_assignment_id             in      number   default null,
   p_primary_assignment_id     in      number   default null,
   p_overwrite_primary         in      varchar2 default 'N',
   p_person_type_id            in      number   default null,
   p_national_identifier       in      per_all_people_f.national_identifier%type default hr_api.g_varchar2,
   p_per_object_version_number in out nocopy  per_all_people_f.object_version_number%TYPE,
   p_employee_number           in out nocopy  per_all_people_f.employee_number%TYPE,
   p_per_effective_start_date     out nocopy  date,
   p_per_effective_end_date       out nocopy  date,
   p_unaccepted_asg_del_warning   out nocopy  boolean,
   p_assign_payroll_warning       out nocopy  boolean,
   p_oversubscribed_vacancy_id    out nocopy  number
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'quick_hire_applicant';
  l_dummy number;
  l_system_person_type         per_person_types.system_person_type%TYPE;
  l_system_person_type2        per_person_types.system_person_type%TYPE;
  l_business_group_id          per_all_people_f.business_group_id%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_application_id             per_applications.application_id%TYPE;
  l_apl_object_version_number  per_applications.application_id%TYPE;
  l_per_effective_start_date   per_all_people_f.effective_start_date%type;
  l_per_effective_start_date2  per_all_people_f.effective_start_date%type;
  l_per_effective_end_date     per_all_people_f.effective_end_date%type;
  l_asg_effective_start_date   per_all_assignments_f.effective_start_date%type;
  l_asg_effective_end_date     per_all_assignments_f.effective_end_date%type;
  l_comment_id                 per_all_people_f.comment_id%type;
  l_current_applicant_flag     per_all_people_f.current_applicant_flag%type;
  l_current_emp_or_apl_flag    per_all_people_f.current_emp_or_apl_flag%type;
  l_current_employee_flag      per_all_people_f.current_employee_flag%type;
  l_full_name                  per_all_people_f.full_name%type;
  l_per_object_version_number  per_all_people_f.object_version_number%type;
  l_per_object_version_number2 per_all_people_f.object_version_number%type;
  l_asg_object_version_number  per_all_assignments_f.object_version_number%type;
  l_per_system_status          per_assignment_status_types.per_system_status%type;
  l_employee_number            per_all_people_f.employee_number%type;
  l_applicant_number            per_all_people_f.applicant_number%type;
  l_datetrack_update_mode      varchar2(30);
  l_dummyb boolean;
  --
  l_hire_date                  date;
  l_moved                      boolean;
  --
  --
  cursor csr_future_asg_changes is
    select 1
      from per_assignments_f asg
     where asg.person_id = p_person_id
       and asg.effective_start_date >= p_hire_date; -- bug 4681265 changed the condition from ' > ' to " >= " .
  --
  cursor csr_get_per_details(p_date date) is
    select ppt.system_person_type,
           per.effective_start_date,
           per.object_version_number
      from per_all_people_f per,
           per_person_types ppt
     where per.person_type_id    = ppt.person_type_id
       and per.person_id         = p_person_id
       and p_date       between per.effective_start_date
                               and per.effective_end_date;
  --
  cursor get_assignments(p_person_id number,p_date date) is
  select asg.assignment_id
  ,asg.object_version_number
  from per_all_assignments_f asg
  where asg.person_id=p_person_id
  and p_date=asg.effective_start_date;
  --
  cursor csr_asg_status(p_assignment_id number, p_date date) is
  select pas.per_system_status
  ,      asg.object_version_number
  ,      asg.effective_start_date
  from per_assignments_f asg,
        per_assignment_status_types pas
  where asg.assignment_id=p_assignment_id
  and asg.assignment_status_type_id = pas.assignment_status_type_id
  and p_date       between asg.effective_start_date
                   and asg.effective_end_date;
  --
  -- Start of Fix for WWBUG 1408379
  --
  cursor c1 is
    select *
    from   per_contact_relationships
    where  person_id=p_person_id
    and    date_start=l_hire_date;
  --
  cursor c2 is
    select *
    from   per_contact_relationships
    where  contact_person_id=p_person_id
    and    date_start=l_hire_date;
  --
  l_c1 c1%rowtype;
  l_c2 c2%rowtype;
  l_old ben_con_ler.g_con_ler_rec;
  l_new ben_con_ler.g_con_ler_rec;
  l_rows_found boolean := false;
  --
  -- End of Fix for WWBUG 1408379
  --
-- Bug 4755015 Starts
  cursor get_business_group(p_asg_id number) is
  select distinct PAAF.business_group_id
  from   per_all_assignments_f PAAF
  where  PAAF.assignment_id=p_asg_id;
  l_bg_id number;
-- Bug 4755015 Ends
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint quick_hire_applicant;
  l_hire_date                  := trunc(p_hire_date);
  l_per_object_version_number  := p_per_object_version_number;
  --
  -- Check that there are not any future changes to the assignment
  --
  open csr_future_asg_changes;
  fetch csr_future_asg_changes into l_dummy;
  --
  if csr_future_asg_changes%FOUND then
    --
    hr_utility.set_location(l_proc,30);
    close csr_future_asg_changes;
    --
    hr_utility.set_message(801,'HR_7975_ASG_INV_FUTURE_ASA');
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Get the derived details for the person DT instance
  --
  open  csr_get_per_details(l_hire_date);
  fetch csr_get_per_details
  into l_system_person_type,
       l_per_effective_start_date,
       l_per_object_version_number;
  if csr_get_per_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc,50);
    --
    close csr_get_per_details;
    --
    hr_utility.set_message(800,'PER_52097_APL_INV_PERSON_ID');
    hr_utility.raise_error;
    --
  else
    close csr_get_per_details;
  end if;
  --
  if l_system_person_type in ('APL','APL_EX_APL','EX_EMP_APL') then
  hr_utility.set_location(l_proc,50);
    --
    -- if we have an applicant then look to see if they are being hired at the start of their records
    --
    if l_per_effective_start_date=l_hire_date then
  hr_utility.set_location(l_proc,60);
      --
      -- the hire date is at the start of their record, so need to do some moving
      --
      open csr_get_per_details(l_hire_date-1);
      fetch csr_get_per_details
      into l_system_person_type2,
           l_per_effective_start_date2,
           l_per_object_version_number2;
      if csr_get_per_details%NOTFOUND then
        close csr_get_per_details;
        hr_utility.set_location(l_proc,70);
        --
        -- there is no record on the previous day, so move everything back 1 day
        --
        update per_all_people_f
        set
        effective_start_date=l_hire_date-1
        ,start_date=l_hire_date-1
        ,original_date_of_hire=decode(original_date_of_hire
                                     ,l_hire_date,l_hire_date-1
                                     ,original_date_of_hire)
        where person_id=p_person_id
        and effective_start_date=l_hire_date;
        --
        l_per_object_version_number:=l_per_object_version_number+1;
        --
        update per_applications
        set date_received=l_hire_date-1
        where person_id=p_person_id
        and date_received=l_hire_date;
        --
        -- move associated letter requests
        --
        update per_letter_request_lines
        set date_from=l_hire_date-1
        where assignment_id=(select asg2.assignment_id
                             from per_all_assignments_f asg2
                             where asg2.person_id=p_person_id
                             and asg2.assignment_type='A'
                             and asg2.effective_start_date=l_hire_date)
        and date_from=l_hire_date;
        --
        -- Fix for WWBUG 1408379
        --
        open c1;
          --
          loop
            --
            fetch c1 into l_c1;
            exit when c1%notfound;
            --
            update per_contact_relationships
            set    date_start=l_hire_date-1
            where  person_id=p_person_id
            and    date_start=l_hire_date
            and    contact_relationship_id = l_c1.contact_relationship_id;
            --
            -- Call life event routine
            --
            l_old.person_id := l_c1.person_id;
            l_old.contact_person_id := l_c1.contact_person_id;
            l_old.business_group_id := l_c1.business_group_id;
            l_old.date_start := l_c1.date_start;
            l_old.date_end := l_c1.date_end;
            l_old.contact_type := l_c1.contact_type;
            l_old.personal_flag := l_c1.personal_flag;
            l_old.start_life_reason_id := l_c1.start_life_reason_id;
            l_old.end_life_reason_id := l_c1.end_life_reason_id;
            l_old.rltd_per_rsds_w_dsgntr_flag := l_c1.rltd_per_rsds_w_dsgntr_flag;
            l_old.contact_relationship_id := l_c1.contact_relationship_id;
            l_new.person_id := l_c1.person_id;
            l_new.contact_person_id := l_c1.contact_person_id;
            l_new.business_group_id := l_c1.business_group_id;
            l_new.date_start := l_hire_date-1;
            l_new.date_end := l_c1.date_end;
            l_new.contact_type := l_c1.contact_type;
            l_new.personal_flag := l_c1.personal_flag;
            l_new.start_life_reason_id := l_c1.start_life_reason_id;
            l_new.end_life_reason_id := l_c1.end_life_reason_id;
            l_new.rltd_per_rsds_w_dsgntr_flag := l_c1.rltd_per_rsds_w_dsgntr_flag;
            l_new.contact_relationship_id := l_c1.contact_relationship_id;
            --
            ben_con_ler.ler_chk(p_old            => l_old,
                                p_new            => l_new,
                                p_effective_date => l_hire_date-1);
            --
          end loop;
          --
        close c1;
        --
        open c2;
          --
          loop
            --
            fetch c2 into l_c2;
            exit when c2%notfound;
            --
            update per_contact_relationships
            set    date_start=l_hire_date-1
            where  contact_person_id=p_person_id
            and    date_start=l_hire_date
            and    contact_relationship_id = l_c2.contact_relationship_id;
            --
            -- Call life event routine
            --
            l_old.person_id := l_c2.person_id;
            l_old.contact_person_id := l_c2.contact_person_id;
            l_old.business_group_id := l_c2.business_group_id;
            l_old.date_start := l_c2.date_start;
            l_old.date_end := l_c2.date_end;
            l_old.contact_type := l_c2.contact_type;
            l_old.personal_flag := l_c2.personal_flag;
            l_old.start_life_reason_id := l_c2.start_life_reason_id;
            l_old.end_life_reason_id := l_c2.end_life_reason_id;
            l_old.rltd_per_rsds_w_dsgntr_flag := l_c2.rltd_per_rsds_w_dsgntr_flag;
            l_old.contact_relationship_id := l_c2.contact_relationship_id;
            l_new.person_id := l_c2.person_id;
            l_new.contact_person_id := l_c2.contact_person_id;
            l_new.business_group_id := l_c2.business_group_id;
            l_new.date_start := l_hire_date;
            l_new.date_end := l_c2.date_end;
            l_new.contact_type := l_c2.contact_type;
            l_new.personal_flag := l_c2.personal_flag;
            l_new.start_life_reason_id := l_c2.start_life_reason_id;
            l_new.end_life_reason_id := l_c2.end_life_reason_id;
            l_new.rltd_per_rsds_w_dsgntr_flag := l_c2.rltd_per_rsds_w_dsgntr_flag;
            l_new.contact_relationship_id := l_c1.contact_relationship_id;
            --
            ben_con_ler.ler_chk(p_old            => l_old,
                                p_new            => l_new,
                                p_effective_date => l_hire_date);
            --
          end loop;
          --
        close c2;
        --
        -- we only need to move the start date, there can be no end dated asg before it.
        --
        update per_all_assignments_f
        set effective_start_date=l_hire_date-1
        where person_id=p_person_id
        and assignment_type='A'
        and effective_start_date=l_hire_date;
        --
        l_moved:=true;
        --
        hr_utility.set_location(l_proc,80);
        --
      else
        close csr_get_per_details;
        hr_utility.set_location(l_proc,90);
        --
        -- the applicant did exist yesterday too, so look to see if we can or need to move their data
        if (l_per_effective_start_date2 = l_hire_date-1)
            and l_system_person_type2<>l_system_person_type then
          --
          -- we have an effective start date on the hire date and on the day before.
          -- and the person was not an applicant yesterday, so we cannot move the records
            hr_utility.set_message(800,'PER_52621_CANNOT_MOVE_DATA');
            hr_utility.raise_error;
        end if;
      end if;
    end if;
    --
    -- the person is an applicant today and yesterday, so we can hire today,
    -- but now we must check that the assignment chosen is accepted today, or move it.
    --
    if p_assignment_id is not null then
      hr_utility.set_location(l_proc,100);
      open csr_asg_status(p_assignment_id,l_hire_date);
      fetch csr_asg_status into l_per_system_status
                               ,l_asg_object_version_number
                               ,l_asg_effective_start_date;
      if csr_asg_status%notfound then
        close csr_asg_status;
        hr_utility.set_message(800,'PER_52099_ASG_INV_ASG_ID');
        hr_utility.raise_error;
      else
        close csr_asg_status;
        hr_utility.set_location(l_proc,110);
      end if;
      if l_asg_effective_start_date=l_hire_date then
        hr_utility.set_location(l_proc,120);
        --
        -- the assignment starts today, so we must look to see what the status was yesterday
        --
        open csr_asg_status(p_assignment_id,l_hire_date-1);
        fetch csr_asg_status into l_per_system_status
                                 ,l_asg_object_version_number
                                 ,l_asg_effective_start_date;
        if csr_asg_status%notfound then
          close csr_asg_status;
          hr_utility.set_location(l_proc,130);
          --
          -- the assignment started today, so move it back one day to accept it yesterday
          --
          --
          -- move associated letter requests
          --
          update per_letter_request_lines
          set date_from=l_hire_date-1
          where assignment_id=(select asg2.assignment_id
                               from per_all_assignments_f asg2
                               where asg2.person_id=p_person_id
                               and asg2.assignment_type='A'
                               and asg2.effective_start_date=l_hire_date)
          and date_from=l_hire_date;
          --
          update per_all_assignments_f
          set effective_start_date=l_hire_date-1
          where person_id=p_person_id
          and assignment_type='A'
          and effective_start_date=l_hire_date;
          --
          l_moved:=true;
          hr_utility.set_location(l_proc,140);
        else
          close csr_asg_status;
          hr_utility.set_location(l_proc,150);
          if l_asg_effective_start_date=l_hire_date-1 then
            --
            -- there was an assignment change yesterday too, so we cannot move backwards
            --
            hr_utility.set_message(800,'PER_52621_CANNOT_MOVE_DATA');
            hr_utility.raise_error;
          else
            hr_utility.set_location(l_proc,160);
            --
            -- the earlier assignment row starts before yesterday, so we can move the
            -- recent end date back one day
            --
            -- move associated letter requests
            --
            update per_letter_request_lines
            set date_from=l_hire_date-1
            where assignment_id=(select asg2.assignment_id
                                 from per_all_assignments_f asg2
                                 where asg2.person_id=p_person_id
                                 and asg2.assignment_type='A'
                                 and asg2.effective_start_date=l_hire_date)
            and date_from=l_hire_date;
            --
            update per_all_assignments_f
            set effective_start_date=l_hire_date-1
            where person_id=p_person_id
            and assignment_type='A'
            and effective_start_date=l_hire_date;
            --
            update per_all_assignments_f
            set effective_end_date=l_hire_date-2
            where person_id=p_person_id
            and assignment_type='A'
            and effective_end_date=l_hire_date-1;
            --
            l_moved:=true;
            --
            hr_utility.set_location(l_proc,170);
          end if;
        end if; -- there was a previous row
      end if; -- this row starting today
    end if;
    hr_utility.set_location(l_proc,180);
    --
    -- we now have a person who was an applicant yesterday or before and
    -- if an assignment is specified then it started yesterday or before
    -- now we must accept the assignment if it is not already accepted.
    if p_assignment_id is not null then
      hr_utility.set_location(l_proc,190);
      open csr_asg_status(p_assignment_id,l_hire_date-1);
      fetch csr_asg_status into l_per_system_status
                               ,l_asg_object_version_number
                               ,l_asg_effective_start_date;
      if l_per_system_status<>'ACCEPTED' then
        hr_utility.set_location(l_proc,200);
        if l_asg_effective_start_date=l_hire_date-1 then
          l_datetrack_update_mode:='CORRECTION';
        else
          l_datetrack_update_mode:='UPDATE';
        end if;
        hr_utility.set_location(l_proc,210);
        hr_assignment_api.accept_apl_asg
                  (p_validate                     => false
                  ,p_effective_date               => l_hire_date-1
                  ,p_datetrack_update_mode        => l_datetrack_update_mode
                  ,p_assignment_id                => p_assignment_id
                  ,p_object_version_number        => l_asg_object_version_number
                  ,p_assignment_status_type_id    => null
                  ,p_change_reason                => null
                  ,p_effective_start_date         => l_asg_effective_start_date
                  ,p_effective_end_date           => l_asg_effective_end_date
                  );
      end if;   -- is it not accepted
    end if; -- is it specified
    hr_utility.set_location(l_proc,220);
    --
    -- now that they are moved and accepted, do the hire
    --
    hr_applicant_api.hire_applicant
        (p_validate                  => FALSE
        ,p_hire_date                 => l_hire_date
        ,p_person_id                 => p_person_id
        ,p_assignment_id             => p_primary_assignment_id
        ,p_person_type_id            => p_person_type_id
        ,p_national_identifier       => p_national_identifier
        ,p_per_object_version_number => l_per_object_version_number
        ,p_employee_number           => p_employee_number
        ,p_per_effective_start_date  => p_per_effective_start_date
        ,p_per_effective_end_date    => p_per_effective_end_date
        ,p_unaccepted_asg_del_warning => p_unaccepted_asg_del_warning
        ,p_assign_payroll_warning    => p_assign_payroll_warning
        ,p_oversubscribed_vacancy_id => p_oversubscribed_vacancy_id
        );
-- Bug 4755015 Starts
/*   open get_business_group(p_primary_assignment_id);
   fetch get_business_group into l_bg_id;
  --
   if get_business_group%NOTFOUND then
      close get_business_group;
      l_bg_id := hr_general.get_business_group_id;
   else
      close get_business_group;
   end if;
   --
   hrentmnt.maintain_entries_asg (
    p_assignment_id         => p_primary_assignment_id,
    p_business_group_id     => l_bg_id,
    p_operation             => 'ASG_CRITERIA',
    p_actual_term_date      => null,
    p_last_standard_date    => null,
    p_final_process_date    => null,
    p_dt_mode               => 'UPDATE',
    p_validation_start_date => p_per_effective_start_date,
    p_validation_end_date   => p_per_effective_end_date
   );*/
   --Commented this fix for Bug 8805585
-- Bug 4755015 Ends
    --
  elsif l_system_person_type ='EMP_APL' then
    hr_utility.set_location(l_proc,230);
    --
    -- if we have an emp_apl then look to see if they are being hired at the
    -- start of the current record
    --
    if l_per_effective_start_date=l_hire_date then
      hr_utility.set_location(l_proc,240);
      --
      -- the hire date is at the start of their record, so need to do some moving
      --
      open csr_get_per_details(l_hire_date-1);
      fetch csr_get_per_details
      into l_system_person_type2,
           l_per_effective_start_date2,
           l_per_object_version_number2;
      close csr_get_per_details;
      hr_utility.set_location(l_proc,250);
      --
      -- look to see if they were not an emp-apl yesterday
      --
      if l_system_person_type2<>'EMP_APL' then
        hr_utility.set_location(l_proc,260);
        --
        if (l_per_effective_start_date2 = l_hire_date-1) then
          --
          -- we have an effective start date on the hire date and on the day before.
          -- and the person was not an emp_apl yesterday, so we cannot move the records
            hr_utility.set_message(800,'PER_52621_CANNOT_MOVE_DATA');
            hr_utility.raise_error;
        end if;
        hr_utility.set_location(l_proc,270);
        --
        -- they weren't an emp-apl yesterday, but there is room to move that backwards
        --
        update per_all_people_f
        set effective_start_date=l_hire_date-1
        where person_id=p_person_id
        and effective_start_date=l_hire_date;
        --
        l_per_object_version_number:=l_per_object_version_number+1;
        --
        update per_all_people_f
        set effective_end_date=l_hire_date-2
        where person_id=p_person_id
        and effective_end_date=l_hire_date-1;
        --
        l_moved:=true;
        --
        hr_utility.set_location(l_proc,280);
      end if;
    end if;
    hr_utility.set_location(l_proc,290);
    --
    -- the person is an emp_apl today and yesterday, so we can hire today,
    -- but now we must check that the assignment chosen is accepted today, or move it.
    --
    if p_assignment_id is not null and p_overwrite_primary='N' then
      hr_utility.set_location(l_proc,300);
      open csr_asg_status(p_assignment_id,l_hire_date);
      fetch csr_asg_status into l_per_system_status
                               ,l_asg_object_version_number
                               ,l_asg_effective_start_date;
      if csr_asg_status%notfound then
        close csr_asg_status;
        hr_utility.set_message(800,'PER_52099_ASG_INV_ASG_ID');
        hr_utility.raise_error;
      else
        close csr_asg_status;
        hr_utility.set_location(l_proc,310);
      end if;
      if l_asg_effective_start_date=l_hire_date then
        hr_utility.set_location(l_proc,320);
        --
        -- the assignment starts today, so we must look to see what the status was yesterday
        --
        open csr_asg_status(p_assignment_id,l_hire_date-1);
        fetch csr_asg_status into l_per_system_status
                                 ,l_asg_object_version_number
                                 ,l_asg_effective_start_date;
        if csr_asg_status%notfound then
          close csr_asg_status;
          hr_utility.set_location(l_proc,330);
          --
          -- the assignment started today, so move it back one day to accept it yesterday
          --
          update per_all_assignments_f
          set effective_start_date=l_hire_date-1
          where person_id=p_person_id
          and assignment_type='A'
          and effective_start_date=l_hire_date;
          --
          -- the application may need moving
          --
          begin
            update per_applications
            set date_received=l_hire_date-1
            where person_id=p_person_id
            and date_received=l_hire_date;
          exception
            when no_data_found then
              null;
            when others then
              raise;
          end;
          --
          l_moved:=true;
          hr_utility.set_location(l_proc,340);
        else
          close csr_asg_status;
          hr_utility.set_location(l_proc,350);
          if l_asg_effective_start_date=l_hire_date-1 then
            --
            -- there was an assignment change yesterday too, so we cannot move backwards
            --
            hr_utility.set_message(800,'PER_52621_CANNOT_MOVE_DATA');
            hr_utility.raise_error;
          else
            hr_utility.set_location(l_proc,360);
            --
            -- the earlier assignment row starts before yesterday, so we can move the
            -- recent end date back one day
            --
            update per_all_assignments_f
            set effective_start_date=l_hire_date-1
            where person_id=p_person_id
            and assignment_type='A'
            and effective_start_date=l_hire_date;
            --
            update per_all_assignments_f
            set effective_end_date=l_hire_date-2
            where person_id=p_person_id
            and assignment_type='A'
            and effective_end_date=l_hire_date-1;
            --
            l_moved:=true;
            --
            hr_utility.set_location(l_proc,370);
          end if;
        end if; -- there was a previous row
      end if; -- this row starting today
    end if;
    hr_utility.set_location(l_proc,380);
    --
    if p_overwrite_primary IN ('Y','V') then
      hr_utility.set_location(l_proc,385);
      -- we should make sure that any applications that start on the hire date
      -- are moved back one day, along with the application
      begin
        update per_all_assignments_f
        set effective_start_date=l_hire_date-1
        where person_id=p_person_id
        and assignment_type='A'
        and effective_start_date=l_hire_date;
      exception
      when no_data_found then
        null;
      when others then
        raise;
      end;
      --
      -- the application may need moving
      --
      begin
        update per_applications
        set date_received=l_hire_date-1
        where person_id=p_person_id
        and date_received=l_hire_date;
      exception
      when no_data_found then
        null;
      when others then
        raise;
      end;
      --
    end if;
    --
    hr_utility.set_location(l_proc,385);
    --
    -- we now have a person who was an emp_apl yesterday or before and
    -- if an assignment is specified then it started yesterday or before
    -- now we must accept the assignment if it is not already accepted.
    if p_assignment_id is not null then
      hr_utility.set_location(l_proc,390);
      open csr_asg_status(p_assignment_id,l_hire_date-1);
      fetch csr_asg_status into l_per_system_status
                               ,l_asg_object_version_number
                               ,l_asg_effective_start_date;
      if l_per_system_status<>'ACCEPTED' then
        hr_utility.set_location(l_proc,400);
        if l_asg_effective_start_date=l_hire_date-1 then
          l_datetrack_update_mode:='CORRECTION';
        else
          l_datetrack_update_mode:='UPDATE';
        end if;
        hr_utility.set_location(l_proc,410);
        hr_assignment_api.accept_apl_asg
                  (p_validate                     => false
                  ,p_effective_date               => l_hire_date-1
                  ,p_datetrack_update_mode        => l_datetrack_update_mode
                  ,p_assignment_id                => p_assignment_id
                  ,p_object_version_number        => l_asg_object_version_number
                  ,p_assignment_status_type_id    => null
                  ,p_change_reason                => null
                  ,p_effective_start_date         => l_asg_effective_start_date
                  ,p_effective_end_date           => l_asg_effective_end_date
                  );
      end if;   -- is it not accepted
    end if; -- is it specified
    hr_utility.set_location(l_proc,420);
    --
    -- now that they are moved and accepted, do the hire
    --
    hr_employee_applicant_api.hire_employee_applicant
        (p_validate                  => FALSE
        ,p_hire_date                 => l_hire_date
        ,p_person_id                 => p_person_id
        ,p_primary_assignment_id     => p_primary_assignment_id
        ,p_person_type_id            => p_person_type_id
        ,p_overwrite_primary         => p_overwrite_primary
        ,p_per_object_version_number => l_per_object_version_number
        ,p_per_effective_start_date  => p_per_effective_start_date
        ,p_per_effective_end_date    => p_per_effective_end_date
        ,p_unaccepted_asg_del_warning => p_unaccepted_asg_del_warning
        ,p_assign_payroll_warning    => p_assign_payroll_warning
        ,p_oversubscribed_vacancy_id => p_oversubscribed_vacancy_id
        );
    --
    end if;
--
  hr_utility.set_location('Leaving '||l_proc,430);

end quick_hire_applicant;
--

function set_notification
(p_notification             wf_messages.name%type
,p_wf_name                  wf_item_types.name%type
,p_role                     varchar2 --wf_roles.name%type  Fix for bug 2741492
,p_person_id                per_all_people_f.person_id%type
,p_assignment_id            per_all_assignments_f.assignment_id%type
,p_effective_date           date
,p_hire_date                per_periods_of_service.date_start%type
,p_full_name                per_all_people_f.full_name%type
,p_per_effective_start_date per_all_people_f.effective_start_date%type
,p_title                    per_alL_people_f.title%type
,p_first_name               per_all_people_f.first_name%type
,p_last_name                per_all_people_f.last_name%type
,p_employee_number          per_all_people_f.employee_number%type
,p_applicant_number         per_all_people_f.applicant_number%type
,p_national_identifier      per_all_people_f.national_identifier%type
,p_asg_effective_start_date per_all_assignments_f.effective_start_date%type
,p_organization             hr_all_organization_units.name%type
,p_grade                    per_grades.name%type
,p_job                      per_jobs.name%type
,p_position                 hr_all_positions_f.name%type
,p_payroll                  pay_all_payrolls_f.payroll_name%type
,p_vacancy                  per_vacancies.name%type
,p_supervisor               per_all_people_f.full_name%type
,p_location                 hr_locations.location_code%type
,p_salary                   per_pay_proposals.proposed_salary_n%type
,p_salary_currency          pay_element_types_f.input_currency_code%type
,p_pay_basis                hr_lookups.meaning%type
,p_date_probation_end       per_all_assignments_f.date_probation_end%type
,p_npw_number               per_all_people_f.npw_number%type
,p_vendor                   po_vendors.vendor_name%type
,p_supplier_reference       per_all_assignments_f.vendor_employee_number%type
,p_placement_date_start     per_all_assignments_f.period_of_placement_date_start%type
,p_grade_ladder             ben_pgm_f.name%type
) return number is
  l_nid number;
  l_ff1 varchar2(240);
  l_ff2 varchar2(240);
  l_ff3 varchar2(240);
  l_ff4 varchar2(240);
  l_ff5 varchar2(240);
  --
  cursor csr_formula_id(p_name VARCHAR2)is
  select formula_id
  from ff_formulas_f fff
  ,    ff_formula_types fft
  where fff.formula_name = p_name
  and p_effective_date between fff.effective_start_date and fff.effective_end_date
  and fff.formula_type_id=fft.formula_type_id
  and fft.formula_type_name='People Management Message';
  --
  l_formula_id ff_formulas_f.formula_id%type;
  l_formula_inputs              ff_exec.inputs_t;
  l_formula_outputs             ff_exec.outputs_t;
  l_index_number                NUMBER;
  --
  l_proc                       varchar2(72) := g_package||'set_notification';
  l_user_name                  varchar2(50); -- # 3295399
begin
  --
  hr_utility.set_location('Entering:'||l_proc||'/'||p_wf_Name, 10);
  --
  l_nid:=wf_notification.send(p_role
                             ,p_wf_name
                             ,p_notification
                             ,null
                             ,null
                             ,null
                             ,null
                             );
  --
  hr_utility.set_location(l_proc, 20);
  --
  wf_notification.setAttrDate(l_nid,'HIRE_DATE',p_hire_date);
  wf_notification.setAttrText(l_nid,'FULL_NAME',p_full_name);
  wf_notification.setAttrDate(l_nid,'PER_EFFECTIVE_START_DATE',p_per_effective_start_date);
  wf_notification.setAttrText(l_nid,'TITLE',p_title);
  wf_notification.setAttrText(l_nid,'FIRST_NAME',p_first_name);
  wf_notification.setAttrText(l_nid,'LAST_NAME',p_last_name);
  wf_notification.setAttrText(l_nid,'EMPLOYEE_NUMBER',p_employee_number);
  wf_notification.setAttrText(l_nid,'APPLICANT_NUMBER',p_applicant_number);
  wf_notification.setAttrText(l_nid,'NATIONAL_IDENTIFIER',p_national_identifier);
  wf_notification.setAttrDate(l_nid,'ASG_EFFECTIVE_START_DATE',p_asg_effective_start_date);
  wf_notification.setAttrText(l_nid,'ORGANIZATION',p_organization);
  wf_notification.setAttrText(l_nid,'GRADE',p_grade);
  wf_notification.setAttrText(l_nid,'JOB',p_job);
  wf_notification.setAttrText(l_nid,'POSITION',p_position);
  wf_notification.setAttrText(l_nid,'PAYROLL',p_payroll);
  wf_notification.setAttrText(l_nid,'VACANCY',p_vacancy);
  wf_notification.setAttrText(l_nid,'SUPERVISOR',p_supervisor);
  wf_notification.setAttrText(l_nid,'LOCATION',p_location);
  wf_notification.setAttrNumber(l_nid,'SALARY',p_salary);
  wf_notification.setAttrText(l_nid,'SALARY_CURRENCY',p_salary_currency);
  wf_notification.setAttrText(l_nid,'PAY_BASIS',p_pay_basis);
  wf_notification.setAttrDate(l_nid,'DATE_PROBATION_END',p_date_probation_end);

  IF p_wf_name <> 'PECWKNOT' THEN -- # 3295399
    wf_notification.setAttrText(l_nid,'GRADE_LADDER',p_grade_ladder);
  END IF; -- # 3295399
  --
  -- Attributes for CWK seeded WORKFLOW.
  --
  IF p_wf_name = 'PECWKNOT' THEN
    --
    hr_utility.set_location(l_proc, 25);
    --
    wf_notification.setAttrText(l_nid,'NPW_NUMBER',p_npw_number);
    wf_notification.setAttrText(l_nid,'SUPPLIER_NAME',p_vendor);
    wf_notification.setAttrText(l_nid,'SUPPLIER_REFERENCE',p_supplier_reference);
    wf_notification.setAttrDate(l_nid,'START_DATE',p_placement_date_start);
    -- # 3295399 Start
    if p_notification ='NEW_CWK' then
       l_user_name := fnd_profile.value('USERNAME');
       wf_notification.setAttrText(l_nid,'#FROM_ROLE',l_user_name);
    End if;
    -- # 3295399 End
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 30);
  --
  open csr_formula_id(p_notification);
  fetch csr_formula_id into l_formula_id;
  if csr_formula_id%found then
    --
    hr_utility.set_location(l_proc, 40);
    --
    close csr_formula_id;
    ff_exec.init_formula(l_formula_id,p_effective_date,l_formula_inputs,l_formula_outputs);
    l_index_number := l_formula_inputs.FIRST;
    WHILE (l_index_number IS NOT NULL)
    loop
      if    (l_formula_inputs(l_index_number).name = 'ASSIGNMENT_ID') then
        l_formula_inputs(l_index_number).value := p_assignment_id;
      elsif (l_formula_inputs(l_index_number).name = 'PERSON_ID') then
        l_formula_inputs(l_index_number).value := p_person_id;
      elsif (l_formula_inputs(l_index_number).name = 'DATE_EARNED') then
        l_formula_inputs(l_index_number).value := fnd_date.date_to_canonical(p_effective_date);
      end if;
      l_index_number := l_formula_inputs.NEXT(l_index_number);
    end loop;
    --
    hr_utility.set_location(l_proc, 50);
    --
    ff_exec.run_formula(l_formula_inputs,l_formula_outputs);
    l_index_number := l_formula_outputs.FIRST;
    WHILE (l_index_number IS NOT NULL)
    loop
      if (l_formula_outputs(l_index_number).name = 'FF1') then
        l_ff1 := l_formula_outputs(l_index_number).value;
      elsif (l_formula_outputs(l_index_number).name = 'FF2') then
        l_ff2 := l_formula_outputs(l_index_number).value;
      elsif (l_formula_outputs(l_index_number).name = 'FF3') then
        l_ff3 := l_formula_outputs(l_index_number).value;
      elsif (l_formula_outputs(l_index_number).name = 'FF4') then
        l_ff4 := l_formula_outputs(l_index_number).value;
      elsif (l_formula_outputs(l_index_number).name = 'FF5') then
        l_ff5 := l_formula_outputs(l_index_number).value;
      end if;
      l_index_number := l_formula_outputs.NEXT(l_index_number);
    end loop;
    --
    hr_utility.set_location(l_proc, 60);
    --
  else
    --
    hr_utility.set_location(l_proc, 70);
    --
    close csr_formula_id;
  end if;
  --
  wf_notification.setAttrText(l_nid,'FF1',l_ff1);
  wf_notification.setAttrText(l_nid,'FF2',l_ff2);
  wf_notification.setAttrText(l_nid,'FF3',l_ff3);
  wf_notification.setAttrText(l_nid,'FF4',l_ff4);
  wf_notification.setAttrText(l_nid,'FF5',l_ff5);
  --
  hr_utility.set_location(l_proc, 80);
  --
  return l_nid;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 90);
  --
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
    l_nid:=null;
    return l_nid;
end set_notification;

procedure send_notification
(p_notification             wf_messages.name%type
,p_wf_name                  wf_item_types.name%type
,p_role                     varchar2 --wf_roles.name%type  Fix for bug 2741492
,p_person_id                per_all_people_f.person_id%type
,p_assignment_id            per_all_assignments_f.assignment_id%type
,p_effective_date           date
,p_hire_date                per_periods_of_service.date_start%type
,p_full_name                per_all_people_f.full_name%type
,p_per_effective_start_date per_all_people_f.effective_start_date%type
,p_title                    per_alL_people_f.title%type
,p_first_name               per_all_people_f.first_name%type
,p_last_name                per_all_people_f.last_name%type
,p_employee_number          per_all_people_f.employee_number%type
,p_applicant_number         per_all_people_f.applicant_number%type
,p_national_identifier      per_all_people_f.national_identifier%type
,p_asg_effective_start_date per_all_assignments_f.effective_start_date%type
,p_organization             hr_all_organization_units.name%type
,p_grade                    per_grades.name%type
,p_job                      per_jobs.name%type
,p_position                 hr_all_positions_f.name%type
,p_payroll                  pay_all_payrolls_f.payroll_name%type
,p_vacancy                  per_vacancies.name%type
,p_supervisor               per_all_people_f.full_name%type
,p_location                 hr_locations.location_code%type
,p_salary                   per_pay_proposals.proposed_salary_n%type
,p_salary_currency          pay_element_types_f.input_currency_code%type
,p_pay_basis                hr_lookups.meaning%type
,p_date_probation_end       per_all_assignments_f.date_probation_end%type
,p_npw_number               per_all_people_f.npw_number%type
,p_vendor                   po_vendors.vendor_name%type
,p_supplier_reference       per_all_assignments_f.vendor_employee_number%type
,p_placement_date_start     per_all_assignments_f.period_of_placement_date_start%type
,p_grade_ladder             ben_pgm_f.name%type
) is
  pragma autonomous_transaction;
  l_nid number;
  l_proc                       varchar2(72) := g_package||'send_notification';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_nid:=set_notification
  (p_notification             => p_notification
  ,p_wf_name                  => p_wf_name
  ,p_role                     => p_role
  ,p_person_id                => p_person_id
  ,p_assignment_id            => p_assignment_id
  ,p_effective_date           => p_effective_date
  ,p_hire_date                => p_hire_date
  ,p_full_name                => p_full_name
  ,p_per_effective_start_date => p_per_effective_start_date
  ,p_title                    => p_title
  ,p_first_name               => p_first_name
  ,p_last_name                => p_last_name
  ,p_employee_number          => p_employee_number
  ,p_applicant_number         => p_applicant_number
  ,p_national_identifier      => p_national_identifier
  ,p_asg_effective_start_date => p_asg_effective_start_date
  ,p_organization             => p_organization
  ,p_grade                    => p_grade
  ,p_job                      => p_job
  ,p_position                 => p_position
  ,p_payroll                  => p_payroll
  ,p_vacancy                  => p_vacancy
  ,p_supervisor               => p_supervisor
  ,p_location                 => p_location
  ,p_salary                   => p_salary
  ,p_salary_currency          => p_salary_currency
  ,p_pay_basis                => p_pay_basis
  ,p_date_probation_end       => p_date_probation_end
  ,p_npw_number               => p_npw_number
  ,p_vendor                   => p_vendor
  ,p_supplier_reference       => p_supplier_reference
  ,p_placement_date_start     => p_placement_date_start
  ,p_grade_ladder             => p_grade_ladder
  );
  hr_utility.set_location(l_proc, 20);
  --
   --Added for bug 5586890
  WF_NOTIFICATION.Denormalize_Notification(l_nid);
  commit;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 30);
  --
end send_notification;
--
procedure get_notification_preview
(p_notification             in     wf_messages.name%type
,p_wf_name                  in     wf_item_types.name%type
,p_role                     in     varchar2 --wf_roles.name%type  Fix for bug 2741492
,p_person_id                in     per_all_people_f.person_id%type
,p_assignment_id            in     per_all_assignments_f.assignment_id%type
,p_effective_date           in     date
,p_hire_date                in     per_periods_of_service.date_start%type
,p_full_name                in     per_all_people_f.full_name%type
,p_per_effective_start_date in     per_all_people_f.effective_start_date%type
,p_title                    in     per_alL_people_f.title%type
,p_first_name               in     per_all_people_f.first_name%type
,p_last_name                in     per_all_people_f.last_name%type
,p_employee_number          in     per_all_people_f.employee_number%type
,p_applicant_number         in     per_all_people_f.applicant_number%type
,p_national_identifier      in     per_all_people_f.national_identifier%type
,p_asg_effective_start_date in     per_all_assignments_f.effective_start_date%type
,p_organization             in     hr_all_organization_units.name%type
,p_grade                    in     per_grades.name%type
,p_job                      in     per_jobs.name%type
,p_position                 in     hr_all_positions_f.name%type
,p_payroll                  in     pay_all_payrolls_f.payroll_name%type
,p_vacancy                  in     per_vacancies.name%type
,p_supervisor               in     per_all_people_f.full_name%type
,p_location                 in     hr_locations.location_code%type
,p_salary                   in     per_pay_proposals.proposed_salary_n%type
,p_salary_currency          in     pay_element_types_f.input_currency_code%type
,p_pay_basis                in     hr_lookups.meaning%type
,p_date_probation_end       in     per_all_assignments_f.date_probation_end%type
,p_npw_number               in     per_all_people_f.npw_number%type
,p_vendor                   in     po_vendors.vendor_name%type
,p_supplier_reference       in     per_all_assignments_f.vendor_employee_number%type
,p_placement_date_start     in     per_all_assignments_f.period_of_placement_date_start%type
,p_grade_ladder             in     ben_pgm_f.name%type
,p_subject                     out nocopy varchar2
,p_body                        out nocopy varchar2
) is
  pragma autonomous_transaction;
  l_nid number;
  l_subject varchar2(240);
  l_body varchar2(4000);
  l_proc                       varchar2(72) := g_package||'get_notification_preview';
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_nid:=set_notification
  (p_notification             => p_notification
  ,p_wf_name                  => p_wf_name
  ,p_role                     => p_role
  ,p_person_id                => p_person_id
  ,p_assignment_id            => p_assignment_id
  ,p_effective_date           => p_effective_date
  ,p_hire_date                => p_hire_date
  ,p_full_name                => p_full_name
  ,p_per_effective_start_date => p_per_effective_start_date
  ,p_title                    => p_title
  ,p_first_name               => p_first_name
  ,p_last_name                => p_last_name
  ,p_employee_number          => p_employee_number
  ,p_applicant_number         => p_applicant_number
  ,p_national_identifier      => p_national_identifier
  ,p_asg_effective_start_date => p_asg_effective_start_date
  ,p_organization             => p_organization
  ,p_grade                    => p_grade
  ,p_job                      => p_job
  ,p_position                 => p_position
  ,p_payroll                  => p_payroll
  ,p_vacancy                  => p_vacancy
  ,p_supervisor               => p_supervisor
  ,p_location                 => p_location
  ,p_salary                   => p_salary
  ,p_salary_currency          => p_salary_currency
  ,p_pay_basis                => p_pay_basis
  ,p_date_probation_end       => p_date_probation_end
  ,p_npw_number               => p_npw_number
  ,p_vendor                   => p_vendor
  ,p_supplier_reference       => p_supplier_reference
  ,p_placement_date_start     => p_placement_date_start
  ,p_grade_ladder             => p_grade_ladder
  );
  hr_utility.set_location(l_proc, 20);
  --
  if l_nid is not null then
    hr_utility.set_location(l_proc, 30);
    l_subject:=wf_notification.getSubject(l_nid);
    l_body:=wf_notification.getBody(l_nid);
  else
    hr_utility.set_location(l_proc, 40);
    l_subject:=null;
    l_body:=null;
  end if;
  --
  rollback;
  --
  p_subject:=l_subject;
  p_body:=l_body;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  --
end get_notification_preview;
--
end per_qh_action;

/
