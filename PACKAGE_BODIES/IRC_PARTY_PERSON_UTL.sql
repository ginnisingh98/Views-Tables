--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_PERSON_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_PERSON_UTL" as
/* $Header: irptpeul.pkb 120.0 2005/07/26 15:16:00 mbocutt noship $ */
procedure update_party_records(p_mode varchar2) is

  type t_number is table of number index by binary_integer;
  l_party_ids t_number;
  l_person_ids t_number;
  l_old_row_count number;
  l_new_row_count number;
  l_rows_in_this_collect number;
  l_business_group_id number;
  l_person_type_id number;
  l_ptu_person_type_id number;
l_new_person_id number;
l_object_version_number    per_all_people_f.object_version_number%type;
l_effective_start_date     per_all_people_f.effective_start_date%type;
l_effective_end_date       per_all_people_f.effective_end_date%type;
l_full_name                per_all_people_f.full_name%type;
l_comment_id               per_all_people_f.comment_id%type;
l_name_combination_warning boolean;
l_orig_hire_warning        boolean;
l_assign_payroll_warning   boolean;
l_mode boolean;
l_employee_number varchar2(255);

  cursor get_party_id1 is
  select party_id,party_id person_id
  from hz_parties
  where orig_system_reference='PER:IRC'
  union
  select party_id,person_id
  from irc_notification_preferences;

  cursor get_party_id2 is
  select party_id,party_id person_id
  from hz_parties
  where orig_system_reference='PER:IRC'
  union
  select party_id,person_id
  from irc_notification_preferences
  union
  select party_id,person_id
  from per_addresses
  where party_id is not null
  and person_id is null
  union
  select party_id,parent_id person_id
  from per_phones
  where party_id is not null
  and parent_id is null
  union
  select party_id,person_id
  from per_previous_employers
  where party_id is not null
  and person_id is null
  union
  select party_id,person_id
  from per_qualifications
  where party_id is not null
  and person_id is null
  union
  select party_id,person_id
  from per_establishment_attendances
  where party_id is not null
  and person_id is null
  union
  select party_id,person_id
  from irc_documents
  where party_id is not null
  and person_id is null
  union
  select party_id,person_id
  from per_competence_elements
  where party_id is not null
  and person_id is null
  union
  select party_id,person_id
  from irc_job_basket_items
  where party_id is not null
  and person_id is null
  union
  select object_id party_id, object_id person_id
  from irc_search_criteria
  where object_type='WORK'
  union
  select party_id,person_id
  from irc_vacancy_considerations
  where party_id is not null
  and person_id is null;

  cursor get_party_rec(p_party_id number) is
  select hzpp.person_first_name
  ,hzpp.person_last_name
  ,hzpp.date_of_birth
  ,hzpp.person_title
  ,hzpp.gender
  ,hzpp.marital_status
  ,hzpp.person_previous_last_name
  ,hzpp.person_name_suffix
  ,hzpp.person_middle_name
  ,hzpp.known_as
  ,hzpp.person_first_name_phonetic
  ,hzpp.person_last_name_phonetic
  ,hzp.creation_date
  from hz_person_profiles hzpp
  ,    hz_parties hzp
  where hzpp.party_id=p_party_id
  and   hzp.party_id=hzpp.party_id
  and sysdate between hzpp.effective_start_date and nvl(hzpp.effective_end_date,sysdate);

  cursor get_email_rec(p_party_id number) is
  select usr1.email_address,usr1.start_date
  from fnd_user usr1
  where usr1.customer_id=p_party_id
  and usr1.start_date < sysdate
  union
  select usr1.email_address,usr1.start_date
  from fnd_user usr1
  ,per_all_people_f per1
  where usr1.employee_id=per1.person_id
  and usr1.start_date < sysdate
  and per1.party_id=p_party_id
  and trunc(sysdate) between per1.effective_start_date
  and per1.effective_end_date
  order by 2 desc;

  l_email_address varchar2(240);
  l_start_date_dummy date;

  party_rec get_party_rec%rowtype;

  cursor get_legislation_code is
  select legislation_code
  from per_business_groups
  where business_group_id=l_business_group_id;

  l_legislation_code varchar2(150);

  cursor get_person_rec(p_party_id number) is
  select person_id,effective_start_date
  from per_all_people_f
  where party_id=p_party_id
  and business_group_id=l_business_group_id
  order by effective_start_date asc;

  cursor get_current_person_rec(p_person_id number) is
  select email_address,object_version_number
  from per_all_people_f
  where person_id=p_person_id
  and trunc(sysdate) between effective_start_date and effective_end_date;

  cursor get_ptu_entry(p_person_id number) is
  select 1
  from per_person_type_usages_f ptu
  ,    per_person_types ppt
  where ptu.person_id=p_person_id
  and ptu.person_type_id=ppt.person_type_id
  and ppt.system_person_type='IRC_REG_USER';

  cursor get_user_rec(p_party_id number) is
  select user_name,employee_id
  from fnd_user
  where customer_id=p_party_id
  and employee_id is null
  and sysdate between start_date and nvl(end_date,sysdate);

  l_data_migrator_mode varchar2(30);
  l_limit number :=100;
  l_b boolean;

  cursor get_person_type_id is
  select org_information8
  from hr_organization_information
  where organization_id=l_business_group_id
  and ORG_INFORMATION_CONTEXT='BG Recruitment';

  cursor get_work_prefs(p_person_id number) is
  select 1 from irc_search_criteria
  where object_id=p_person_id
  and object_type='WPREF';

  cursor get_notification_prefs(p_party_id number) is
  select 1 from irc_notification_preferences
  where party_id=p_party_id;

  l_dummy number;
  l_start_date date;


begin

  if(p_mode='BASIC') then
    l_mode:=true;
  else
    l_mode:=false;
  end if;

  l_business_group_id:=to_number(fnd_profile.value('IRC_REGISTRATION_BG_ID'));
  if l_business_group_id is null then
    fnd_message.set_name('PER','IRC_412155_REG_BG_NOT_SET');
    fnd_message.raise_error;
  end if;

  open get_legislation_code;
  fetch get_legislation_code into l_legislation_code;
  close get_legislation_code;

  open get_person_type_id;
  fetch get_person_type_id into l_person_type_id;
  if get_person_type_id%notfound then
    close get_person_type_id;
    fnd_message.set_name('PER','IRC_412156_PERS_TYPE_NOT_SET');
    fnd_message.raise_error;
  else
    close get_person_type_id;
  end if;
  --
   -- get the PTU person type for iRecruitment Candidate
  --
  l_ptu_person_type_id:=hr_person_type_usage_info.get_default_person_type_id
                                         (l_business_group_id,
                                          'IRC_REG_USER');
  --
  l_data_migrator_mode:=hr_general.g_data_migrator_mode;
  hr_general.g_data_migrator_mode:='Y';
  --
  -- remap all employee data first
  --
  irc_global_remap_pkg.remap_employee(null,sysdate);
  --
  if(l_mode) then
    open get_party_id1;
  else
    open get_party_id2;
  end if;
  loop

    if(l_mode) then
      fetch get_party_id1
      bulk collect into
      l_party_ids,l_person_ids
      limit l_limit;
    else
      fetch get_party_id2
      bulk collect into
      l_party_ids,l_person_ids
      limit l_limit;
    end if;

    l_old_row_count := l_new_row_count;
    if(l_mode) then
      l_new_row_count := get_party_id1%ROWCOUNT;
    else
      l_new_row_count := get_party_id2%ROWCOUNT;
    end if;
    l_rows_in_this_collect := l_new_row_count - l_old_row_count;

    EXIT WHEN (l_rows_in_this_collect = 0);

    for i in l_party_ids.first..l_party_ids.last loop
      --
      -- first of all look for an existing person_record
      --
      open get_person_rec(l_party_ids(i));
      fetch get_person_rec into l_person_ids(i),l_start_date;
      if get_person_rec%notfound then
        close get_person_rec;
        -- look for the e-mail address of the person
        --
        open get_email_rec(l_party_ids(i));
        fetch get_email_rec into l_email_address,l_start_date_dummy;
        close get_email_rec;
        --
        -- create a new person record in the default business group
        --
        open get_party_rec(l_party_ids(i));
        fetch get_party_rec into party_rec;
        close get_party_rec;
        l_start_date:=trunc(party_rec.creation_date)-2;
        if party_rec.gender='MALE' then
          party_rec.gender:='M';
        elsif party_rec.gender='FEMALE' then
          party_rec.gender:='F';
        else
          party_rec.gender:=null;
        end if;
        if rtrim(party_rec.person_last_name) is null then
          party_rec.person_last_name:=fnd_message.get_string('PER','IRC_412108_UNKNOWN_NAME');
       end if;
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date=>l_start_date
         ,p_lookup_type=>'TITLE'
         ,p_lookup_code=>party_rec.person_title) then
         party_rec.person_title:=null;
       end if;
       if hr_api.not_exists_in_hr_lookups
         (p_effective_date=>l_start_date
         ,p_lookup_type=>'MAR_STATUS'
         ,p_lookup_code=>party_rec.marital_status) then
         party_rec.marital_status:=null;
       end if;
        if l_legislation_code='JP' then
	  hr_contact_api.create_person
	  (p_start_date                    => l_start_date
	  ,p_business_group_id             => l_business_group_id
	  ,p_last_name                     => substrb(party_rec.person_last_name_phonetic,0,40)
	  ,p_first_name                    => substrb(party_rec.person_first_name_phonetic,0,20)
          ,p_per_information_category      => l_legislation_code
	  ,p_per_information18             => substrb(party_rec.person_last_name,0,150)
	  ,p_per_information19             => substrb(party_rec.person_first_name,0,150)
    	  ,p_sex                           => party_rec.gender
          ,p_title                         => party_rec.person_title
	  ,p_date_of_birth                 => party_rec.date_of_birth
	  ,p_known_as                      => substrb(party_rec.known_as,0,80)
          ,p_previous_last_name            => substrb(party_rec.person_previous_last_name,0,40)
	  ,p_marital_status                => party_rec.marital_status
          ,p_middle_names                  => substrb(party_rec.person_middle_name,0,60)
          ,p_suffix                        => substrb(party_rec.person_name_suffix,0,30)
          ,p_email_address                 => l_email_address
    	  ,p_person_type_id                => l_person_type_id
	  ,p_person_id                     => l_new_person_id
	  ,p_object_version_number         => l_object_version_number
	  ,p_effective_start_date          => l_effective_start_date
	  ,p_effective_end_date            => l_effective_end_date
	  ,p_full_name                     => l_full_name
	  ,p_comment_id                    => l_comment_id
	  ,p_name_combination_warning      => l_name_combination_warning
	  ,p_orig_hire_warning             => l_orig_hire_warning
	  );
          l_person_ids(i):=l_new_person_id;

        elsif l_legislation_code='KR' then
	  hr_contact_api.create_person
	  (p_start_date                    => l_start_date
	  ,p_business_group_id             => l_business_group_id
	  ,p_last_name                     => substrb(party_rec.person_last_name,0,40)
	  ,p_first_name                    => substrb(party_rec.person_first_name,0,20)
          ,p_per_information_category      => l_legislation_code
	  ,p_per_information1              => substrb(party_rec.person_last_name_phonetic,0,150)
	  ,p_per_information2              => substrb(party_rec.person_first_name_phonetic,0,150)
    	  ,p_sex                           => party_rec.gender
          ,p_title                         => party_rec.person_title
	  ,p_date_of_birth                 => party_rec.date_of_birth
	  ,p_known_as                      => substrb(party_rec.known_as,0,80)
          ,p_previous_last_name            => substrb(party_rec.person_previous_last_name,0,40)
	  ,p_marital_status                => party_rec.marital_status
          ,p_middle_names                  => substrb(party_rec.person_middle_name,0,60)
          ,p_suffix                        => substrb(party_rec.person_name_suffix,0,30)
          ,p_email_address                 => l_email_address
    	  ,p_person_type_id                => l_person_type_id
	  ,p_person_id                     => l_new_person_id
	  ,p_object_version_number         => l_object_version_number
	  ,p_effective_start_date          => l_effective_start_date
	  ,p_effective_end_date            => l_effective_end_date
	  ,p_full_name                     => l_full_name
	  ,p_comment_id                    => l_comment_id
	  ,p_name_combination_warning      => l_name_combination_warning
	  ,p_orig_hire_warning             => l_orig_hire_warning
	  );
          l_person_ids(i):=l_new_person_id;
        else
	  hr_contact_api.create_person
	  (p_start_date                    => l_start_date
	  ,p_business_group_id             => l_business_group_id
	  ,p_last_name                     => substrb(party_rec.person_last_name,0,40)
	  ,p_first_name                    => substrb(party_rec.person_first_name,0,20)
          ,p_per_information_category      => l_legislation_code
    	  ,p_sex                           => party_rec.gender
          ,p_title                         => party_rec.person_title
	  ,p_date_of_birth                 => party_rec.date_of_birth
	  ,p_known_as                      => substrb(party_rec.known_as,0,80)
          ,p_previous_last_name            => substrb(party_rec.person_previous_last_name,0,40)
	  ,p_marital_status                => party_rec.marital_status
          ,p_middle_names                  => substrb(party_rec.person_middle_name,0,60)
          ,p_suffix                        => substrb(party_rec.person_name_suffix,0,30)
          ,p_email_address                 => l_email_address
    	  ,p_person_type_id                => l_person_type_id
	  ,p_person_id                     => l_new_person_id
	  ,p_object_version_number         => l_object_version_number
	  ,p_effective_start_date          => l_effective_start_date
	  ,p_effective_end_date            => l_effective_end_date
	  ,p_full_name                     => l_full_name
	  ,p_comment_id                    => l_comment_id
	  ,p_name_combination_warning      => l_name_combination_warning
	  ,p_orig_hire_warning             => l_orig_hire_warning
	  );
          l_person_ids(i):=l_new_person_id;
        end if;
        --
        --set the party_id on the record
        --
        l_employee_number:=null;
        hr_person_api.update_person
        (p_effective_date=>l_start_date
        ,p_datetrack_update_mode=>'CORRECTION'
        ,p_person_id=>l_person_ids(i)
        ,p_object_version_number=>l_object_version_number
        ,p_party_id =>l_party_ids(i)
        ,p_employee_number=> l_employee_number
        ,p_effective_start_date          => l_effective_start_date
	,p_effective_end_date            => l_effective_end_date
	,p_full_name                     => l_full_name
	,p_comment_id                    => l_comment_id
	,p_name_combination_warning      => l_name_combination_warning
        ,p_assign_payroll_warning        => l_assign_payroll_warning
	,p_orig_hire_warning             => l_orig_hire_warning);
        --
        -- create the extra PTU entry for iRecruitment Candidate
        --
        hr_per_type_usage_internal.maintain_person_type_usage
        (p_effective_date       => l_start_date
        ,p_person_id            => l_person_ids(i)
        ,p_person_type_id       => l_ptu_person_type_id
        );
        --
      else
        -- the person already exists, but may not have the correct PTU entry.
        close get_person_rec;
        open get_ptu_entry(l_person_ids(i));
        fetch get_ptu_entry into l_dummy;
        if get_ptu_entry%notfound then
          close get_ptu_entry;
          hr_per_type_usage_internal.maintain_person_type_usage
          (p_effective_date       => l_start_date
          ,p_person_id            => l_person_ids(i)
          ,p_person_type_id       => l_ptu_person_type_id
          );
        else
          close get_ptu_entry;
        end if;
        -- update the e-mail address if it is not set
        open get_current_person_rec(l_person_ids(i));
        fetch get_current_person_rec into l_email_address,l_object_version_number;
        if get_current_person_rec%found and l_email_address is null then
          close get_current_person_rec;
          l_employee_number:=hr_api.g_varchar2;
          open get_email_rec(l_party_ids(i));
          fetch get_email_rec into l_email_address,l_start_date_dummy;
          close get_email_rec;
          hr_person_api.update_person
          (p_effective_date=>sysdate
          ,p_datetrack_update_mode=>'CORRECTION'
          ,p_person_id=>l_person_ids(i)
          ,p_object_version_number=>l_object_version_number
          ,p_employee_number=> l_employee_number
          ,p_email_address=>l_email_address
          ,p_effective_start_date          => l_effective_start_date
          ,p_effective_end_date            => l_effective_end_date
	  ,p_full_name                     => l_full_name
	  ,p_comment_id                    => l_comment_id
	  ,p_name_combination_warning      => l_name_combination_warning
          ,p_assign_payroll_warning        => l_assign_payroll_warning
	  ,p_orig_hire_warning             => l_orig_hire_warning);
        else
          close get_current_person_rec;
        end if;
      end if;
      --
      -- get any user records
      --
      for usr_rec in get_user_rec(l_party_ids(i)) loop
        fnd_user_pkg.updateUser
        (x_user_name=>usr_rec.user_name
        ,x_owner=>'CUST'
        ,x_employee_id=>l_person_ids(i)
        ,x_customer_id=>fnd_user_pkg.null_number);
      end loop;
      --
      -- update the phone records directly for performance
      --

      update per_phones
      set parent_id=l_person_ids(i)
      ,parent_table='PER_ALL_PEOPLE_F'
      where party_id=l_party_ids(i)
      and parent_id is null;

      --
      -- update the address records directly for performance
      --

      update per_addresses
      set person_id=l_person_ids(i)
      ,business_group_id=l_business_group_id
      where party_id=l_party_ids(i)
      and person_id is null
      and address_type='REC';
      --
      -- update the previous employers records directly for performance
      --

      update per_previous_employers
      set person_id=l_person_ids(i)
      ,business_group_id=l_business_group_id
      where party_id=l_party_ids(i)
      and person_id is null;
      --
      -- update the qualifications records directly for performance
      --

      update per_qualifications
      set person_id=l_person_ids(i)
      ,business_group_id=l_business_group_id
      where party_id=l_party_ids(i)
      and person_id is null;

      --
      -- update the establishment attendance records directly for performance
      --

      update per_establishment_attendances
      set person_id=l_person_ids(i)
      ,business_group_id=l_business_group_id
      where party_id=l_party_ids(i)
      and person_id is null;
      --
      -- update the competence records directly for performance
      --

      update per_competence_elements
      set person_id=l_person_ids(i)
      ,business_group_id=l_business_group_id
      where party_id=l_party_ids(i)
      and person_id is null;

      --
      -- update the documents records directly for performance
      --

      update irc_documents
      set person_id=l_person_ids(i)
      where party_id=l_party_ids(i)
      and person_id is null;

      --
      -- update the job basket records directly for performance
      --

      update irc_job_basket_items
      set person_id=l_person_ids(i)
      where party_id=l_party_ids(i)
      and person_id is null;

      --
      -- update the search criteria and work preferences
      --
      update irc_search_criteria
      set object_id=l_person_ids(i)
      ,object_type='PERSON'
      where object_type = 'PARTY'
      and object_id=l_party_ids(i);
      --
      -- update the search criteria and work preferences
      --
      update irc_search_criteria
      set object_id=l_person_ids(i)
      ,object_type='WPREF'
      where object_type = 'WORK'
      and object_id=l_party_ids(i);
      --
      -- check that the user has work preferences
      --
      open get_work_prefs(l_person_ids(i));
      fetch get_work_prefs into l_dummy;
      if get_work_prefs%found then
        close get_work_prefs;
      else
        close get_work_prefs;
        -- no work prefernces, so create some
        insert into irc_search_criteria
        (search_criteria_id
        ,object_id
        ,object_type
        ,employee
        ,contractor
        ,employment_category
        ,match_competence
        ,match_qualification
        ,salary_period
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,object_version_number)
        values
        (irc_search_criteria_s.nextval
        ,l_person_ids(i)
        ,'WPREF'
        ,'Y'
        ,'Y'
        ,'FULLTIME'
        ,'Y'
        ,'Y'
        ,'ANNUAL'
        ,sysdate
        ,1
        ,1
        ,1
        ,sysdate
        ,1);
      end if;
      --
      -- update the vacancy consideration records
      --

      update irc_vacancy_considerations
      set person_id=l_person_ids(i)
      where party_id=l_party_ids(i)
      and person_id is null;

    --
    -- update the notification preferences
    --
    open get_notification_prefs(l_party_ids(i));
     fetch get_notification_prefs into l_dummy;
     if get_notification_prefs%found then
      close get_notification_prefs;
      update  irc_notification_preferences inp
      set person_id=l_person_ids(i)
      where party_id=l_party_ids(i)
      and person_id is null;
    else
      close get_notification_prefs;
      insert into irc_notification_preferences
      (notification_preference_id
      ,party_id
      ,person_id
      ,matching_jobs
      ,matching_job_freq
      ,receive_info_mail
      ,allow_access
      ,last_update_date
      ,last_updated_by
      ,last_update_login
      ,created_by
      ,creation_date
      ,object_version_number)
      values
      (irc_notification_prefs_s.nextval
      ,l_party_ids(i)
      ,l_person_ids(i)
      ,'N'
      ,'1'
      ,'N'
      ,'N'
      ,sysdate
      ,1
      ,1
      ,1
      ,sysdate
      ,1);
    end if;
    end loop;

    commit;
    l_person_ids.delete;
    l_party_ids.delete;

  end loop;
  if(l_mode) then
    close get_party_id1;
  else
    close get_party_id2;
  end if;
  hr_general.g_data_migrator_mode:=l_data_migrator_mode;

end update_party_records;

procedure update_party_conc(errbuf  out nocopy varchar2
                           ,retcode out nocopy varchar2) is
--
l_proc varchar2(72) := 'irc_party_person_utl.update_party_conc';
--
begin
  hr_utility.set_location('Entering: '||l_proc, 10);
irc_party_person_utl.update_party_records;
  commit;
  retcode := 0;
  hr_utility.set_location('Leaving: '||l_proc, 20);
exception
  when others then
    rollback;
    --
    -- Set the return parameters to indicate failure
    --
    errbuf := sqlerrm;
    retcode := 2;
end update_party_conc;
end irc_party_person_utl;

/
