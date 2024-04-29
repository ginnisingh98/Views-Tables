--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE3_PKG" AS
/* $Header: peper03t.pkb 120.2.12010000.2 2009/02/09 12:10:36 pchowdav ship $ */
--
--
procedure get_number_generation_property(p_business_group_id NUMBER
                                         ,p_property_on NUMBER
                                         ,p_property_off NUMBER
                                         ,p_employee_property in out nocopy NUMBER
                                         ,p_applicant_property in out nocopy NUMBER) is
--
-- Returns Number Generation properties of the current business group
-- takes in forms 'NUMBERS' property_on and property_off.
-- setting the values of p_employee_property,p_applicant_property to
-- be property_off when an automatic method is used.
--
begin
   --
   select decode(pbg.METHOD_OF_GENERATION_EMP_NUM,'A'
                                       , p_property_off , p_property_on)
         ,decode(pbg.METHOD_OF_GENERATION_APL_NUM,'A'
                                       , p_property_off, p_property_on)
   into p_employee_property
   ,    p_applicant_property
   from per_business_groups pbg
   where pbg.business_group_id = p_business_group_id;
   --
   exception
      when no_data_found then
          hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE'
                         ,'per_people3_pkg.get_number_generation_property');
         hr_utility.set_message_token('STEP','2');
      when too_many_rows then
         hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE'
                        ,'per_people3_pkg.get_number_generation_property');
         hr_utility.set_message_token('STEP','2');
end get_number_generation_property;
--
procedure get_legislative_ages(p_business_group_id NUMBER
                              ,p_minimum_age IN OUT NOCOPY NUMBER
                              ,p_maximum_age IN OUT NOCOPY NUMBER) is
begin
  select hoi1.org_information12
  ,      hoi1.org_information13
  into   p_minimum_age
  ,      p_maximum_age
  from hr_organization_information hoi1
  where  p_business_group_id +0 = hoi1.organization_id
  and    hoi1.org_information_context = 'Business Group Information';
  --
  exception
     when no_data_found then
          hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE'
                         ,'per_people3_pkg.get_legislative_ages');
         hr_utility.set_message_token('STEP','1');
      when too_many_rows then
         hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE'
                        ,'per_people3_pkg.get_legislative_ages');
         hr_utility.set_message_token('STEP','2');
end get_legislative_ages;
--

procedure get_default_person_type(p_required_type VARCHAR2
                                ,p_business_group_id NUMBER
                                ,p_legislation_code VARCHAR2
                                ,p_person_type IN OUT NOCOPY NUMBER) is
--
-- Define Cursor.
--
cursor per_type is
   select past.assignment_status_type_id
   from   per_assignment_status_types past
   ,      per_ass_status_type_amends pasa
   where  pasa.assignment_status_type_id(+) = past.assignment_status_type_id
   and    pasa.business_group_id(+) + 0 = p_business_group_id
   and    nvl(past.business_group_id,p_business_group_id) = p_business_group_id
   and    nvl(past.legislation_code, p_legislation_code) =p_legislation_code
   and    nvl(pasa.active_flag,past.active_flag) = 'Y'
   and    nvl(pasa.default_flag,past.default_flag) = 'Y'
   and    nvl(pasa.per_system_status,past.per_system_status) = p_required_type;
--
begin
   open per_type;
   fetch per_type into p_person_type;
   --
   if per_type%ROWCOUNT <>1 then
      hr_utility.set_message('800','HR_289296_SEC_PROF_SETUP_ERR');
      hr_utility.raise_error;
   end if;
   --
   close per_type;
end get_default_person_type;
--
procedure get_ddf_exists(p_legislation_code VARCHAR2
                        ,p_ddf_exists IN OUT NOCOPY VARCHAR2) is
cursor ddf is
select 'Y'
from sys.dual
where exists( select 1 from FND_DESCR_FLEX_CONTEXTS fdfc
              where fdfc.APPLICATION_ID = 800
              and fdfc.DESCRIPTIVE_FLEXFIELD_NAME = 'Person Developer DF'
              and fdfc.enabled_flag = 'Y'
              and fdfc.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_legislation_code);
begin
  open ddf;
  fetch ddf into p_ddf_exists;
  if ddf%notfound then
     p_ddf_exists := 'N';
  close ddf;
  end if;
end get_ddf_exists;
--
-- Verifies if PER_PEOPLE descriptive flexfield has enabled segments
-- #1799586
procedure get_people_ddf_exists(p_legislation_code VARCHAR2
                               ,p_people_ddf_exists IN OUT NOCOPY VARCHAR2) is
cursor ddf is
select 'Y'
from sys.dual
where exists( select 1 from fnd_descr_flex_column_usages fdfc
              where fdfc.APPLICATION_ID = 800
              and fdfc.DESCRIPTIVE_FLEXFIELD_NAME = 'PER_PEOPLE'
              and fdfc.enabled_flag = 'Y');
begin
  open ddf;
  fetch ddf into p_people_ddf_exists;
  if ddf%notfound then
     p_people_ddf_exists := 'N';
  end if;
  close ddf;

end get_people_ddf_exists;
--
--
procedure initialize(p_business_group_id NUMBER
                  ,p_legislation_code VARCHAR2
                  ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                  ,p_property_on NUMBER
                  ,p_property_off NUMBER
                  ,p_employee_property IN OUT NOCOPY NUMBER
                  ,p_applicant_property IN OUT NOCOPY NUMBER
                  ,p_required_emp_type VARCHAR2
                  ,p_required_app_type VARCHAR2
                  ,p_emp_person_type IN OUT NOCOPY NUMBER
                  ,p_app_person_type IN OUT NOCOPY NUMBER
                  ,p_minimum_age IN  OUT NOCOPY NUMBER
                  ,p_maximum_age IN OUT NOCOPY NUMBER) is
l_people_ddf_exists varchar2(1);
begin

  per_people3_pkg.initialize(p_business_group_id
                 ,p_legislation_code
                 ,p_ddf_exists
                 ,p_property_on
                 ,p_property_off
                 ,p_employee_property
                 ,p_applicant_property
                 ,p_required_emp_type
                 ,p_required_app_type
                 ,p_emp_person_type
                 ,p_app_person_type
                 ,p_minimum_age
                 ,p_maximum_age
                 ,l_people_ddf_exists);
end initialize;
--
procedure initialize(p_business_group_id NUMBER
                  ,p_legislation_code VARCHAR2
                  ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                  ,p_property_on NUMBER
                  ,p_property_off NUMBER
                  ,p_employee_property IN OUT NOCOPY NUMBER
                  ,p_applicant_property IN OUT NOCOPY NUMBER
                  ,p_required_emp_type VARCHAR2
                  ,p_required_app_type VARCHAR2
                  ,p_emp_person_type IN OUT NOCOPY NUMBER
                  ,p_app_person_type IN OUT NOCOPY NUMBER) is
l_minimum_age NUMBER;
l_maximum_age NUMBER;
begin
  per_people3_pkg.initialize(p_business_group_id
                 ,p_legislation_code
                 ,p_ddf_exists
                 ,p_property_on
                 ,p_property_off
                 ,p_employee_property
                 ,p_applicant_property
                 ,p_required_emp_type
                 ,p_required_app_type
                 ,p_emp_person_type
                 ,p_app_person_type
                 ,l_minimum_age
                 ,l_maximum_age);
end initialize;
--
procedure initialize(p_business_group_id NUMBER
                  ,p_legislation_code VARCHAR2
                  ,p_ddf_exists IN OUT NOCOPY VARCHAR2
                  ,p_property_on NUMBER
                  ,p_property_off NUMBER
                  ,p_employee_property IN OUT NOCOPY NUMBER
                  ,p_applicant_property IN OUT NOCOPY NUMBER
                  ,p_required_emp_type VARCHAR2
                  ,p_required_app_type VARCHAR2
                  ,p_emp_person_type IN OUT NOCOPY NUMBER
                  ,p_app_person_type IN OUT NOCOPY NUMBER
                  ,p_minimum_age IN  OUT NOCOPY NUMBER
                  ,p_maximum_age IN OUT NOCOPY NUMBER
                  ,p_people_ddf_exists IN OUT NOCOPY VARCHAR2) is
--
begin
   --
   -- Get the item properties for employee and applicant number
   --
   per_people3_pkg.get_number_generation_property(
                                 p_business_group_id => p_business_group_id
                                 ,p_property_on => p_property_on
                                 ,p_property_off => p_property_off
                                 ,p_employee_property => p_employee_property
                                 ,p_applicant_property => p_applicant_property);
--
  per_people3_pkg.get_legislative_ages(p_business_group_id
                                   ,p_minimum_age
                                   ,p_maximum_age);
   --
   -- Get the default person_type_id's for employee.
   --
   per_people3_pkg.get_default_person_type(p_required_type => p_required_emp_type
                                    ,p_business_group_id => p_business_group_id
                                    ,p_legislation_code => p_legislation_code
                                    ,p_person_type => p_emp_person_type);
   --
   -- Get the default person_type_id for applicant.
   --
   per_people3_pkg.get_default_person_type(p_required_type => p_required_app_type
                                    ,p_business_group_id => p_business_group_id
                                    ,p_legislation_code => p_legislation_code
                                    ,p_person_type => p_app_person_type);
   --
   -- Does a ddf exisrts for this legislation?
   --
   per_people3_pkg.get_ddf_exists(p_legislation_code => p_legislation_code
                                ,p_ddf_exists => p_ddf_exists);
   --
   -- #1799586
   per_people3_pkg.get_people_ddf_exists
                   (p_legislation_code  => p_legislation_code
                   ,p_people_ddf_exists => p_people_ddf_exists);
end initialize;
--
procedure check_future_apl(p_person_id NUMBER
                          ,p_hire_date DATE) is
--
-- Local Variables
--
l_dummy VARCHAR2(1);
--
cursor fut_apl is select 'Y'
                  from sys.dual
                  where exists (select 'future assignment exists'
                                from   per_assignments_f paf
                                where  paf.person_id = p_person_id
                                and    paf.assignment_type = 'A'
                                and    paf.effective_start_date >= p_hire_date);
begin
   open fut_apl;
   fetch fut_apl into l_dummy;
   if fut_apl%FOUND then
     hr_utility.set_message('801','HR_7975_ASG_INV_FUTURE_ASA');
     app_exception.raise_exception;
   end if;
   close fut_apl;
end;
--
--overloaded procedure added for bug 5403222
procedure check_future_apl(p_person_id NUMBER
                          ,p_hire_date DATE
                          ,p_table     HR_EMPLOYEE_APPLICANT_API.t_ApplTable ) is
--
-- Local Variables
--
l_dummy VARCHAR2(1);
l_index number;
l_max_ele number;
l_assignment_id per_all_assignments_f.assignment_id%type;
--
--
cursor fut_apl(l_assignment_id number) is select 'Y'
                  from sys.dual
                  where exists (select 'future assignment exists'
                                from   per_assignments_f paf
                                where  paf.assignment_id = l_assignment_id
                                and    paf.assignment_type = 'A'
                                and    paf.effective_start_date >= p_hire_date);
begin

l_index := 0;
l_max_ele := p_table.COUNT;

if l_max_ele > 0 then
  l_index := 1;
  loop
    hr_utility.trace('p_table(l_index).process_flag >> '||p_table(l_index).process_flag);
    hr_utility.trace('p_table(l_index).id >> '||p_table(l_index).id);
    if nvl(p_table(l_index).process_flag,'E') <> 'R' then
      open fut_apl(p_table(l_index).id);
      fetch fut_apl into l_dummy;
      if fut_apl%FOUND then
        close fut_apl;
        hr_utility.trace('12345');
        hr_utility.set_message('801','HR_7975_ASG_INV_FUTURE_ASA');
        app_exception.raise_exception;
      end if;
              hr_utility.trace('123458');
      close fut_apl;
    end if;
    l_index := l_index + 1;
    EXIT when l_index > l_max_ele ;
  end loop;
end if;
end;
procedure update_period(p_person_id number
      ,p_hire_date date
      ,p_new_hire_date date
      ,p_adjusted_svc_date in date ) is
--
-- Update Period of serivice start date when Hire_date
-- has changed and Person_type has not.
--
-- Define Cursor.
--
cursor pps is select rowid,pps.*
               from per_periods_of_service pps
               where person_id = p_person_id
               and   date_start = p_hire_date
               for update of date_start nowait;
--
-- Local Variables.
--
   pps_rec pps%rowtype;
   l_adjusted_svc_date DATE;
--
begin
--
   open pps;
   <<pps_loop>>
   loop
      exit pps_loop when pps%NOTFOUND;
      fetch pps into pps_rec;
   end loop pps_loop;
   --
   if pps%rowcount <>1 then
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','per_people3_pkg.UPDATE_PERIOD');
      hr_utility.raise_error;
   end if;
   --
   close pps;
   --
  -- # 1573563
  if nvl(p_adjusted_svc_date,hr_general.end_of_time) <> hr_api.g_date then
     l_adjusted_svc_date := p_adjusted_svc_date;
  else
     l_adjusted_svc_date := pps_rec.adjusted_svc_date;
  end if;
   -- Now update the row;
   --
   per_periods_of_service_pkg.update_row(p_row_id  => pps_rec.rowid
   ,p_period_of_service_id           => pps_rec.PERIOD_OF_SERVICE_ID
   ,p_business_group_id              => pps_rec.BUSINESS_GROUP_ID
   ,p_person_id                      => pps_rec.PERSON_ID
   ,p_date_start                     => p_new_hire_date
   ,p_termination_accepted_per_id => pps_rec.TERMINATION_ACCEPTED_PERSON_ID
   ,p_accepted_termination_date      => pps_rec.ACCEPTED_TERMINATION_DATE
   ,p_actual_termination_date        => pps_rec.ACTUAL_TERMINATION_DATE
   ,p_comments                       => pps_rec.COMMENTS
   ,p_final_process_date             => pps_rec.FINAL_PROCESS_DATE
   ,p_last_standard_process_date     => pps_rec.LAST_STANDARD_PROCESS_DATE
   ,p_leaving_reason                 => pps_rec.LEAVING_REASON
   ,p_notified_termination_date      => pps_rec.NOTIFIED_TERMINATION_DATE
   ,p_projected_termination_date     => pps_rec.PROJECTED_TERMINATION_DATE
   ,p_request_id                     => pps_rec.REQUEST_ID
   ,p_program_application_id         => pps_rec.PROGRAM_APPLICATION_ID
   ,p_program_id                     => pps_rec.PROGRAM_ID
   ,p_program_update_date            => pps_rec.PROGRAM_UPDATE_DATE
   ,p_attribute_category             => pps_rec.ATTRIBUTE_CATEGORY
   ,p_attribute1                     => pps_rec.ATTRIBUTE1
   ,p_attribute2                     => pps_rec.ATTRIBUTE2
   ,p_attribute3                     => pps_rec.ATTRIBUTE3
   ,p_attribute4                     => pps_rec.ATTRIBUTE4
   ,p_attribute5                     => pps_rec.ATTRIBUTE5
   ,p_attribute6                     => pps_rec.ATTRIBUTE6
   ,p_attribute7                     => pps_rec.ATTRIBUTE7
   ,p_attribute8                     => pps_rec.ATTRIBUTE8
   ,p_attribute9                     => pps_rec.ATTRIBUTE9
   ,p_attribute10                    => pps_rec.ATTRIBUTE10
   ,p_attribute11                    => pps_rec.ATTRIBUTE11
   ,p_attribute12                    => pps_rec.ATTRIBUTE12
   ,p_attribute13                    => pps_rec.ATTRIBUTE13
   ,p_attribute14                    => pps_rec.ATTRIBUTE14
   ,p_attribute15                    => pps_rec.ATTRIBUTE15
   ,p_attribute16                    => pps_rec.ATTRIBUTE16
   ,p_attribute17                    => pps_rec.ATTRIBUTE17
   ,p_attribute18                    => pps_rec.ATTRIBUTE18
   ,p_attribute19                    => pps_rec.ATTRIBUTE19
   ,p_attribute20                    => pps_rec.ATTRIBUTE20
   ,p_pds_information_category       => pps_rec.PDS_INFORMATION_CATEGORY
   ,p_pds_information1               => pps_rec.PDS_INFORMATION1
   ,p_pds_information2               => pps_rec.PDS_INFORMATION2
   ,p_pds_information3               => pps_rec.PDS_INFORMATION3
   ,p_pds_information4               => pps_rec.PDS_INFORMATION4
   ,p_pds_information5               => pps_rec.PDS_INFORMATION5
   ,p_pds_information6               => pps_rec.PDS_INFORMATION6
   ,p_pds_information7               => pps_rec.PDS_INFORMATION7
   ,p_pds_information8               => pps_rec.PDS_INFORMATION8
   ,p_pds_information9               => pps_rec.PDS_INFORMATION9
   ,p_pds_information10              => pps_rec.PDS_INFORMATION10
   ,p_pds_information11              => pps_rec.PDS_INFORMATION11
   ,p_pds_information12              => pps_rec.PDS_INFORMATION12
   ,p_pds_information13              => pps_rec.PDS_INFORMATION13
   ,p_pds_information14              => pps_rec.PDS_INFORMATION14
   ,p_pds_information15              => pps_rec.PDS_INFORMATION15
   ,p_pds_information16              => pps_rec.PDS_INFORMATION16
   ,p_pds_information17              => pps_rec.PDS_INFORMATION17
   ,p_pds_information18              => pps_rec.PDS_INFORMATION18
   ,p_pds_information19              => pps_rec.PDS_INFORMATION19
   ,p_pds_information20              => pps_rec.PDS_INFORMATION20
   ,p_pds_information21              => pps_rec.PDS_INFORMATION21
   ,p_pds_information22              => pps_rec.PDS_INFORMATION22
   ,p_pds_information23              => pps_rec.PDS_INFORMATION23
   ,p_pds_information24              => pps_rec.PDS_INFORMATION24
   ,p_pds_information25              => pps_rec.PDS_INFORMATION25
   ,p_pds_information26              => pps_rec.PDS_INFORMATION26
   ,p_pds_information27              => pps_rec.PDS_INFORMATION27
   ,p_pds_information28              => pps_rec.PDS_INFORMATION28
   ,p_pds_information29              => pps_rec.PDS_INFORMATION29
   ,p_pds_information30              => pps_rec.PDS_INFORMATION30
   ,p_adjusted_svc_date              => l_adjusted_svc_date);
   --
end update_period;
--
procedure run_alu_ee(p_alu_mode VARCHAR2
   ,p_business_group_id NUMBER
   ,p_person_id NUMBER
   ,p_old_start DATE
   ,p_start_date date) is
--
-- Checks the assignment link usages and Element_entries
-- code for changes in assignment and Personal qualifying criteria
--
-- Local Variables.
--
l_assignment_id         number; -- assignment_id of employee assignment.
l_validation_start_date date;   -- End date_of Assignment.
l_validation_end_date   date;   -- End date_of Assignment.
l_entries_changed       VARCHAR2(1);
--
-- Cursor
--
cursor ass_cur is
select assignment_id
from   per_all_assignments_f paf
where  paf.person_id       = p_person_id
and    paf.assignment_type = 'E'
and    p_start_date between
       paf.effective_start_date and paf.effective_end_date;
--
begin
   -- Set the correct validation start and end dates for
   -- the assignments.  These are the same for all
   -- assignments of a multiple assignment person.
   if(p_start_date > p_old_start) then
      -- We have moved the hire date forwards.
      l_validation_start_date := p_old_start;
      l_validation_end_date   := (p_start_date - 1);
   elsif(p_start_date < p_old_start) then
      -- We have moved the hire date backwards.
      l_validation_start_date := p_start_date;
      l_validation_end_date   := (p_old_start - 1);
   end if;
--
   open ass_cur;
   loop
      fetch ass_cur into l_assignment_id;
      exit when ass_cur%NOTFOUND;
      if p_alu_mode = 'ASG_CRITERIA' then
         -- changed cal to use p_old_payroll_id => 2
         -- and p_new_payroll_id=> 1 so that the NR entries get updated.
			if(p_start_date <> p_old_start) then
			   -- Only call this if the hire dates have actually changed.
            hrentmnt.maintain_entries_asg
                           (p_assignment_id =>l_assignment_id
                           ,p_old_payroll_id =>2
                           ,p_new_payroll_id =>1
                           ,p_business_group_id =>p_business_group_id
                           ,p_operation =>p_alu_mode
                           ,p_actual_term_date => NULL
                           ,p_last_standard_date =>NULL
                           ,p_final_process_date => NULL
                           ,p_validation_start_date => l_validation_start_date
                           ,p_validation_end_date => l_validation_end_date
                           ,p_dt_mode =>'CORRECTION'
                           ,p_old_hire_date => p_old_start
                           ,p_entries_changed =>l_entries_changed);
         end if;
      end if;
      --
      hrentmnt.maintain_entries_asg(l_assignment_id
                                    ,p_business_group_id
                                    ,'CHANGE_PQC'
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL);
   end loop;
   close ass_cur;
end;
--
procedure vacancy_chk(p_person_id NUMBER
    ,p_fire_warning in out nocopy VARCHAR2
    ,p_vacancy_id in out nocopy NUMBER
   -- #2381925
    ,p_table IN HR_EMPLOYEE_APPLICANT_API.t_ApplTable
   --
) is
--
-- Check all Vacanicies person has applied for and check for
-- them being over-subscribed.
--
-- Local Variables
--
l_vacancy_name VARCHAR2(30);-- Name of returned vacancy.
l_dummy_id NUMBER(15);      -- Dummy variable.
over_subscribed EXCEPTION;  -- Over-subscribed exception.
--
l_asg_id  number;           -- #2381925: assignment id returned
--
-- Cursor.
-- note p_last_vacancy is a parameter to the cursor defineition.
--
   cursor app_ass(p_last_vacancy number) is
   select pav.vacancy_id,pav.name
         ,pa.assignment_id -- #2381925
     from per_assignments pa, per_all_vacancies pav
   , per_assignment_status_types pas
   where person_id = p_person_id
   and   pav.vacancy_id = pa.vacancy_id
   and   pa.assignment_status_type_id = pas.assignment_status_type_id
   and   pas.per_system_status = 'ACCEPTED'
   and   pa.assignment_type = 'A'
   and   pav.vacancy_id >nvl(p_last_vacancy,0)
   order by pav.vacancy_id asc;
--
begin
   --
   -- set warning to not fire.
   --
   p_fire_warning := 'N';
   --
   -- Get all vacancies that employee has applied for.
   --
   open app_ass(p_vacancy_id);
   loop
      fetch app_ass into p_vacancy_id,l_vacancy_name, l_asg_id; --#2381925
      exit when app_ass%NOTFOUND;
      begin
        -- 2381925: Verify if vacancy is over-subscribed ONLY if applicant
        -- assignment is being hired.
        --
        if hr_employee_applicant_api.is_convert(p_table,l_asg_id) then

           select vacancy_id
           into  l_dummy_id
           from per_all_vacancies pav
           where pav.number_of_openings <
                  (select count(distinct assignment_id) + 1
                    from per_all_assignments_f paf
                    where paf.vacancy_id = pav.vacancy_id
                    and   paf.assignment_type = 'E')
           and pav.vacancy_id = p_vacancy_id;
           --
           -- If a row is returned then the vacancy is over-subscribed
           -- set message and warning flag.
           -- raise exception.
           --
           fnd_message.set_name('PER','HR_EMP_VAC_FILLED');
           fnd_message.set_token('VAC',l_vacancy_name);
           p_fire_warning := 'Y';
           raise over_subscribed;
         end if; -- is asg hired ?
      exception
           when no_data_found then
               null;
           when too_many_rows then
               fnd_message.set_name('PER','HR_EMP_VAC_FILLED');
               fnd_message.set_token('VAC','Too many rows');
               app_exception.raise_exception;
      end;
   end loop;
   --
   close app_ass;
   --
   exception
      when over_subscribed then
         close app_ass;
      when no_data_found then
         if app_ass%rowcount < 1 then
            raise;
         end if;
         close app_ass;
      when too_many_rows then
         raise;
end;
--
procedure get_accepted_appls(p_person_id NUMBER
      ,p_num_accepted_appls in out nocopy  NUMBER
      ,p_new_primary_id in out nocopy NUMBER) is
--
   no_accepted_assign exception;
--
begin
   --
   -- Get the number of currently accepted assignments.
   --
   select count(pa.assignment_id)
   into   p_num_accepted_appls
   from   per_assignments pa
   ,      per_assignment_status_types past
   where  pa.person_id =  p_person_id
   and    pa.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status = 'ACCEPTED';
   --
   -- Test to see how many there are.
   --
   if p_num_accepted_appls = 0 then
      raise no_accepted_assign;
   elsif p_num_accepted_appls = 1 then
      --
      -- If there is only one return it's value.
      --
      begin
         select pa.assignment_id
         into   p_new_primary_id
         from   per_assignments pa
         ,      per_assignment_status_types past
         where  pa.person_id =  p_person_id
         and    pa.assignment_status_type_id = past.assignment_status_type_id
         and    past.per_system_status = 'ACCEPTED';
         exception
            when no_data_found then
               raise no_accepted_assign;
            when too_many_rows then
               raise;
      end;
   end if;
   --
   exception
      when no_accepted_assign then
         hr_utility.set_message('801','HR_6428_EMP_NO_ACCEPT_ASS');
         hr_utility.raise_error;
      when others then
         raise;
end;
--
procedure get_all_current_appls(p_person_id NUMBER
         ,p_num_appls in out nocopy NUMBER) is
--
begin
   --
   -- Get the number of application assignments
   -- which are current.
   --
   select count(pa.assignment_id)
   into   p_num_appls
   from   per_assignments pa
   where  pa.person_id =p_person_id
   and    pa.assignment_type = 'A';
end;
--
procedure get_date_range(p_person_id in number
                        ,p_min_start in out nocopy date
                        ,p_max_end in out nocopy date) is
--
-- Get the absolute date ranges that datetrack can
-- use to change the session date
--
cursor get_dates is
	select min(effective_start_date), max(effective_end_date)
	from   per_people_f
	where  person_id = p_person_id;
begin
	open get_dates;
	fetch get_dates into p_min_start, p_max_end;
	if get_dates%NOTFOUND then
		hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE','get_date_range');
		hr_utility.set_message_token('STEP','1');
		hr_utility.raise_error;
	end if;
	close get_dates;
end;
--
procedure get_asg_date_range(p_assignment_id in number
                            ,p_min_start in out nocopy date
                            ,p_max_end in out nocopy date) is
--
-- Get the absolute date ranges that datetrack can
-- use to change the session date
--
cursor get_dates is
	select min(effective_start_date), max(effective_end_date)
	from   per_assignments_f
	where  assignment_id = p_assignment_id;
begin
	open get_dates;
	fetch get_dates into p_min_start, p_max_end;
	if get_dates%NOTFOUND then
		hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE','get_asg_date_range');
		hr_utility.set_message_token('STEP','1');
		hr_utility.raise_error;
	end if;
	close get_dates;
end;
--
procedure form_post_query(p_ethnic_code IN VARCHAR2
                         ,p_ethnic_meaning IN OUT NOCOPY VARCHAR2
                         ,p_visa_code IN VARCHAR2
                         ,p_visa_meaning IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code IN VARCHAR2
                         ,p_veteran_meaning IN OUT NOCOPY VARCHAR2
			 ,p_i9_code IN VARCHAR2
			 ,p_i9_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code IN VARCHAR2)
IS
l_new_hire_code VARCHAR2(30);
l_new_hire_meaning VARCHAR2(80);
l_reason_for_code VARCHAR2(30);
l_reason_for_meaning VARCHAR2(80);
l_ethnic_disc_code VARCHAR2(30);
l_ethnic_disc_meaning VARCHAR2(80);
begin
   per_people3_pkg.form_post_query(
                          p_ethnic_code
                         ,p_ethnic_meaning
                         ,p_visa_code
                         ,p_visa_meaning
                         ,p_veteran_code
                         ,p_veteran_meaning
			 ,p_i9_code
			 ,p_i9_meaning
                         ,l_new_hire_code
                         ,l_new_hire_meaning
                         ,l_reason_for_code
                         ,l_reason_for_meaning
                         ,l_ethnic_disc_code
                         ,l_ethnic_disc_meaning
                         ,p_legislation_code
                         );
end;
--
procedure form_post_query(p_ethnic_code        IN VARCHAR2
                         ,p_ethnic_meaning     IN OUT NOCOPY VARCHAR2
                         ,p_visa_code          IN VARCHAR2
                         ,p_visa_meaning       IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code       IN VARCHAR2
                         ,p_veteran_meaning    IN OUT NOCOPY VARCHAR2
			 ,p_i9_code            IN VARCHAR2
			 ,p_i9_meaning         IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code      IN VARCHAR2
                         ,p_new_hire_meaning   IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code    IN VARCHAR2
                         ,p_reason_for_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code   IN VARCHAR2)
IS
l_ethnic_disc_code VARCHAR2(30);
l_ethnic_disc_meaning VARCHAR2(80);
begin
   per_people3_pkg.form_post_query(
                          p_ethnic_code
                         ,p_ethnic_meaning
                         ,p_visa_code
                         ,p_visa_meaning
                         ,p_veteran_code
                         ,p_veteran_meaning
			 ,p_i9_code
			 ,p_i9_meaning
                         ,p_new_hire_code
                         ,p_new_hire_meaning
                         ,p_reason_for_code
                         ,p_reason_for_meaning
                         ,l_ethnic_disc_code
                         ,l_ethnic_disc_meaning
                         ,p_legislation_code
                         );
end;
--
procedure form_post_query(p_ethnic_code         IN VARCHAR2
                         ,p_ethnic_meaning      IN OUT NOCOPY VARCHAR2
                         ,p_visa_code           IN VARCHAR2
                         ,p_visa_meaning        IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code        IN VARCHAR2
                         ,p_veteran_meaning     IN OUT NOCOPY VARCHAR2
			 ,p_i9_code             IN VARCHAR2
			 ,p_i9_meaning          IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code       IN VARCHAR2
                         ,p_new_hire_meaning    IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code     IN VARCHAR2
                         ,p_reason_for_meaning  IN OUT NOCOPY VARCHAR2
                         ,p_ethnic_disc_code    IN VARCHAR2
                         ,p_ethnic_disc_meaning IN OUT NOCOPY VARCHAR2
                         ,p_legislation_code    IN VARCHAR2
			   ) is
l_vets100A_code VARCHAR2(30);
l_vets100A_meaning VARCHAR2(80);
begin
   per_people3_pkg.form_post_query(
                          p_ethnic_code
                         ,p_ethnic_meaning
                         ,p_visa_code
                         ,p_visa_meaning
                         ,p_veteran_code
                         ,p_veteran_meaning
			 ,p_i9_code
			 ,p_i9_meaning
                         ,p_new_hire_code
                         ,p_new_hire_meaning
                         ,p_reason_for_code
                         ,p_reason_for_meaning
                         ,p_ethnic_disc_code
                         ,p_ethnic_disc_meaning
			 ,l_vets100A_code
			 ,l_vets100A_meaning
                         ,p_legislation_code
                         );
end;
--
-- Overloaded procedure for bug 7608613
procedure form_post_query(p_ethnic_code         IN VARCHAR2
                         ,p_ethnic_meaning      IN OUT NOCOPY VARCHAR2
                         ,p_visa_code           IN VARCHAR2
                         ,p_visa_meaning        IN OUT NOCOPY VARCHAR2
                         ,p_veteran_code        IN VARCHAR2
                         ,p_veteran_meaning     IN OUT NOCOPY VARCHAR2
			 ,p_i9_code             IN VARCHAR2
			 ,p_i9_meaning          IN OUT NOCOPY VARCHAR2
                         ,p_new_hire_code       IN VARCHAR2
                         ,p_new_hire_meaning    IN OUT NOCOPY VARCHAR2
                         ,p_reason_for_code     IN VARCHAR2
                         ,p_reason_for_meaning  IN OUT NOCOPY VARCHAR2
                         ,p_ethnic_disc_code    IN VARCHAR2
                         ,p_ethnic_disc_meaning IN OUT NOCOPY VARCHAR2
                         ,p_vets100A_code       IN VARCHAR2
                         ,p_vets100A_meaning    IN OUT NOCOPY VARCHAR2
			 ,p_legislation_code    IN VARCHAR2
                         ) is
begin
  if (p_legislation_code = 'US') then
    if (p_ethnic_code is not null) then
      select fcl.meaning
      into p_ethnic_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_ETHNIC_GROUP'
      and application_id = 800
      and fcl.lookup_code = p_ethnic_code;
    end if;
    if (p_visa_code is not null) then
      select fcl.meaning
      into p_visa_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_VISA_TYPE'
      and application_id = 800
      and fcl.lookup_code = p_visa_code;
    end if;
    if (p_veteran_code is not null) then
      select fcl.meaning
      into p_veteran_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_VETERAN_STATUS'
      and application_id = 800
      and fcl.lookup_code = p_veteran_code;
    end if;
    if (p_i9_code is not null) then
      select fcl.meaning
      into p_i9_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'PER_US_I9_STATE'
      and application_id = 800
      and fcl.lookup_code = p_i9_code;
    end if;
    if (p_new_hire_code is not null) then
      select fcl.meaning
      into p_new_hire_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_NEW_HIRE_STATUS'
      and application_id = 800
      and fcl.lookup_code = p_new_hire_code;
    end if;
    if (p_reason_for_code is not null) then
      select fcl.meaning
      into p_reason_for_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_NEW_HIRE_EXCEPTIONS'
      and application_id = 800
      and fcl.lookup_code = p_reason_for_code;
    end if;
    if (p_ethnic_disc_code is not null) then
      select fcl.meaning
      into p_ethnic_disc_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_ETHNIC_DISCLOSURE'
      and application_id = 800
      and fcl.lookup_code = p_ethnic_disc_code;
    end if;
    if (p_vets100A_code is not null) then
      select fcl.meaning
      into p_vets100A_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'US_VETERAN_STATUS_VETS100A'
      and application_id = 800
      and fcl.lookup_code = p_vets100A_code;
    end if;
  elsif (p_legislation_code = 'GB') then
    if (p_ethnic_code is not null) then
      select fcl.meaning
      into p_ethnic_meaning
      from fnd_common_lookups fcl
      where fcl.lookup_type = 'ETH_TYPE'
      and application_id = 800
      and fcl.lookup_code = p_ethnic_code;
    end if;
  end if;
end;
--
function chk_events_exist(p_person_id number
                          ,p_business_group_id number
                          ,p_hire_date date ) return boolean is
--
l_temp VARCHAR2(1);
--
begin
select 'X'
into l_temp
from   sys.dual
where  exists ( select 'Events rows exist'
                from   per_events pe
                ,      per_assignments_f a
                where  pe.business_group_id  +0 = p_business_group_id
                and    pe.assignment_id = a.assignment_id
                and    pe.date_start
                     between a.effective_start_date and a.effective_end_date
                and    pe.date_start > p_hire_date
                and    a.person_id = p_person_id
              );
--
  return true;
--
exception
  when no_data_found then
    return false;
end chk_events_exist;
--
--
END per_people3_pkg;

/
