--------------------------------------------------------
--  DDL for Package Body PER_HRTCA_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HRTCA_MERGE" as
/* $Header: perhrtca.pkb 120.19.12010000.9 2008/11/12 06:36:42 sidsaxen ship $ */
  --PER_USE_TITLE_IN_FULL_NAME
  g_package varchar2(30) := 'per_hrtca_merge.';
  g_count   number := 0;
  --
  procedure update_person(p_rec in out nocopy per_all_people_f%rowtype) is
    --
    l_effective_start_date     date;
    l_effective_end_date       date;
    l_full_name                varchar2(240);
    l_comment_id               number;
    l_name_combination_warning boolean;
    l_assign_payroll_warning   boolean;
    l_orig_hire_warning        boolean;
    l_proc                     varchar2(80) := g_package||'update_person';
    --
  begin
    --
    -- This routine calls the person row handler and sets the party_id
    -- column to a value that has been passed in.
    -- This is called during the initial migration of all persons and
    -- for when a manual party merge takes place.
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Call the hr_person_api.update_person. This causes problems as there are
    -- rules within the APi that are not enforced properly by the form hence
    -- many people will experience rows that will not be migrated. We can't
    -- risk having this as otherwise people will not be able to see their
    -- qualifications, establishment attendances, etc.
    --
    /*
    hr_person_api.update_person
      (p_effective_date           => p_rec.effective_start_date,
       p_datetrack_update_mode    => 'CORRECTION',
       p_person_id                => p_rec.person_id,
       p_object_version_number    => p_rec.object_version_number,
       p_employee_number          => p_rec.employee_number,
       p_party_id                 => p_rec.party_id,
       p_effective_start_date     => l_effective_start_date,
       p_effective_end_date       => l_effective_end_date,
       p_full_name                => l_full_name,
       p_comment_id               => l_comment_id,
       p_name_combination_warning => l_name_combination_warning,
       p_assign_payroll_warning   => l_assign_payroll_warning,
       p_orig_hire_warning        => l_orig_hire_warning);
    */
    update per_all_people_f
    set    party_id = p_rec.party_id
    where  person_id = p_rec.person_id
    and    p_rec.effective_start_date
           between effective_start_date
           and     effective_end_date;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end update_person;
  --
  procedure update_child_tables(p_rec in out nocopy per_all_people_f%rowtype) is
    --
    l_proc varchar2(80) := g_package||'update_child_tables';
    --
    cursor c_competences is
      select *
      from   per_competence_elements
      where  person_id = p_rec.person_id;
    --
    l_competences c_competences%rowtype;
    --
    -- Bug 3648761
    -- Added Hint to use index for Performance.
    --
    cursor c_events is
      select /*+ INDEX(per_events) */ *
      from   per_events
      where  assignment_id in (select assignment_id
                               from   per_all_assignments_f
                               where  person_id = p_rec.person_id);
    --
    l_events c_events%rowtype;
    --
    cursor c_addresses is
      select *
      from   per_addresses
      where  person_id = p_rec.person_id;
    --
    l_addresses c_addresses%rowtype;
    --
    cursor c_phones is
      select *
      from   per_phones
      where  parent_id = p_rec.person_id
      and    parent_table = 'PER_ALL_PEOPLE_F';
    --
    l_phones c_phones%rowtype;
    --
    cursor c_qualifications is
      select *
      from   per_qualifications
      where  person_id = p_rec.person_id;
    --
    l_qualifications c_qualifications%rowtype;
    --
    cursor c_establishment_attendances is
      select *
      from   per_establishment_attendances
      where  person_id = p_rec.person_id;
    --
    cursor c_qualifications_estab is
      select qua.*
      from   per_qualifications qua,
             per_establishment_attendances esa
      where  esa.attendance_id = qua.attendance_id
      and    esa.person_id = p_rec.person_id;
    --
    l_establishment_attendances c_establishment_attendances%rowtype;
    --
    cursor c_prev_employers is
      select *
      from   per_previous_employers
      where  person_id = p_rec.person_id;
    --
    l_prev_employers c_prev_employers%rowtype;
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- This package repeatedly calls the child table related API's for a
    -- particular person and update the party_id column to the party_id
    -- that has been passed in.
    --
    -- 1) Competences
    -- 2) Events
    -- 3) Addresses
    -- 4) Phones
    -- 5) Qualifications
    -- 6) Establishment Attendances
    -- 7) Previous Employers
    --
    -- Loop through all of a persons competence records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN COMPETENCES',10);
    --
    open c_competences;
      --
      loop
        --
        fetch c_competences into l_competences;
        exit when c_competences%notfound;
        --
        update per_competence_elements
        set    party_id = p_rec.party_id
        where  competence_element_id = l_competences.competence_element_id;
        --
        /*
        hr_competence_element_api.update_competence_element
          (p_competence_element_id => l_competences.competence_element_id,
           p_object_version_number => l_competences.object_version_number,
           p_effective_date        => p_rec.effective_start_date,
           p_party_id              => p_rec.party_id);
        */
        --
      end loop;
      --
    close c_competences;
    --
    hr_utility.set_location('FIRST ATTACK : CLOSE COMPETENCES',10);
    --
    -- Loop through all of a persons event records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN EVENTS',10);
    open c_events;
      --
      loop
        --
        fetch c_events into l_events;
        exit when c_events%notfound;
        --
        update per_events
        set    party_id = p_rec.party_id
        where  event_id = l_events.event_id;
        /*
        per_events_api.update_event
          (p_event_id              => l_events.event_id,
           p_party_id              => p_rec.party_id,
           p_object_version_number => l_events.object_version_number);
        */
        --
      end loop;
      --
    close c_events;
    hr_utility.set_location('FIRST ATTACK : CLOSE EVENTS',10);
    --
    -- Loop through all of a persons address records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN ADDRESSES',10);
    open c_addresses;
      --
      loop
        --
        fetch c_addresses into l_addresses;
        exit when c_addresses%notfound;
        --
/*
        hr_person_address_api.update_person_address
          (p_effective_date        => p_rec.effective_start_date,
           p_address_id            => l_addresses.address_id,
           p_party_id              => p_rec.party_id,
           p_object_version_number => l_addresses.object_version_number);
*/
        update per_addresses
          set party_id = p_rec.party_id
          where address_id = l_addresses.address_id;
        --
      end loop;
      --
    close c_addresses;
    hr_utility.set_location('FIRST ATTACK : CLOSE ADDRESSES',10);
    --
    -- Loop through all of a persons phone records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN PHONES',10);
    open c_phones;
      --
      loop
        --
        fetch c_phones into l_phones;
        exit when c_phones%notfound;
        --
        /*
        hr_phone_api.update_phone
          (p_phone_id              => l_phones.phone_id,
           p_object_version_number => l_phones.object_version_number,
           p_party_id              => p_rec.party_id,
           p_effective_date        => p_rec.effective_start_date);
        */
        update per_phones
        set    party_id = p_rec.party_id
        where  phone_id = l_phones.phone_id;
        --
      end loop;
      --
    close c_phones;
    hr_utility.set_location('FIRST ATTACK : CLOSE PHONES',10);
    --
    -- Loop through all of a persons qualification records
    --
    open c_qualifications;
      --
      loop
        --
        fetch c_qualifications into l_qualifications;
        exit when c_qualifications%notfound;
        --
        -- No API at the moment so use base table.
        --
        update per_qualifications
          set party_id = p_rec.party_id
          where qualification_id = l_qualifications.qualification_id;
        --
      end loop;
      --
    close c_qualifications;
    --
    open c_qualifications_estab;
      --
      loop
        --
        fetch c_qualifications_estab into l_qualifications;
        exit when c_qualifications_estab%notfound;
        --
        -- No API at the moment so use base table.
        --
        update per_qualifications
          set party_id = p_rec.party_id
          where qualification_id = l_qualifications.qualification_id;
        --
      end loop;
      --
    close c_qualifications_estab;
    --
    -- Loop through all of a persons establishment attendance records
    --
    open c_establishment_attendances;
      --
      loop
        --
        fetch c_establishment_attendances into l_establishment_attendances;
        exit when c_establishment_attendances%notfound;
        --
        -- No API at the moment so use base table.
        --
        update per_establishment_attendances
          set party_id = p_rec.party_id
          where attendance_id = l_establishment_attendances.attendance_id;
        --
      end loop;
      --
    close c_establishment_attendances;
    --
    --
    -- Loop through all of a persons previous employers records
    --
    open c_prev_employers;
      --
      loop
        --
        fetch c_prev_employers into l_prev_employers;
        exit when c_prev_employers%notfound;  --Bug fix 3618727
        --
        --
        update per_previous_employers
          set party_id = p_rec.party_id
          where previous_employer_id = l_prev_employers.previous_employer_id;
        --
      end loop;
      --
    close c_prev_employers;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end update_child_tables;
  --
  function propagate_value
    (p_old_value      in date,
     p_new_value      in date,
     p_overwrite_data in varchar2) return date is
    --
    l_proc             varchar2(80) := g_package||'propagate_value';
    --
  begin
    --
    -- This routine is used as part of the propogation strategy for updates
    -- to person records. On inserts we do not want to overwrite data with
    -- null values.
    --
    -- If p_overwrite_data = 'Y' then
    --   return p_new_value
    -- else
    --   only overwrite old value if new value is not null
    -- end if;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Bug fix 4146782
    -- If condition added to check whether the value is not
    -- null. Values are propogated across BG only if it is
    -- not null
    --
    if p_overwrite_data = 'Y' and p_new_value is not null then
      --
      return p_new_value;
      --
    else
      --
      if p_new_value is not null then
        --
        return p_new_value;
        --
      else
        --
        return p_old_value;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end propagate_value;
  --
  function propagate_value
    (p_old_value      in varchar2,
     p_new_value      in varchar2,
     p_overwrite_data in varchar2) return varchar2 is
    --
    l_proc             varchar2(80) := g_package||'propagate_value';
    --
  begin
    --
    -- This routine is used as part of the propogation strategy for updates
    -- to person records. On inserts we do not want to overwrite data with
    -- null values.
    --
    -- If p_overwrite_data = 'Y' then
    --   return p_new_value
    -- else
    --   only overwrite old value if new value is not null
    -- end if;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Bug fix 4146782
    -- If condition added to check whether the value is not
    -- null. Values are propogated across BG only if it is
    -- not null
    --
    if p_overwrite_data = 'Y' and p_new_value is not null then
       --
       return p_new_value;
      --
    else
      --
      if p_new_value is not null then
        --
        return p_new_value;
        --
      else
        --
        return p_old_value;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end propagate_value;
  --
  function propagate_value
    (p_old_value      in number,
     p_new_value      in number,
     p_overwrite_data in varchar2) return varchar2 is
    --
    l_proc             varchar2(80) := g_package||'propagate_value';
    --
  begin
    --
    -- This routine is used as part of the propogation strategy for updates
    -- to person records. On inserts we do not want to overwrite data with
    -- null values.
    --
    -- If p_overwrite_data = 'Y' then
    --   return p_new_value
    -- else
    --   only overwrite old value if new value is not null
    -- end if;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Bug fix 4146782
    -- If condition added to check whether the value is not
    -- null. Values are propogated across BG only if it is
    -- not null
    --
    if p_overwrite_data = 'Y' and p_new_value is not null then
       --
       return p_new_value;
      --
    else
      --
      if p_new_value is not null then
        --
        return p_new_value;
        --
      else
        --
        return p_old_value;
        --
      end if;
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end propagate_value;
  --
  function get_legislation_code
    (p_business_group_id in number) return varchar2 is
    --
    l_proc             varchar2(80) := g_package||'get_legislation_code';
    l_legislation_code varchar2(80);
    --
  begin
    --
    -- This procedure returns the legislation code for a particular business
    -- group.
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    select legislation_code
    into   l_legislation_code
    from   per_business_groups
    where  business_group_id = p_business_group_id;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
    return l_legislation_code;
    --
  end get_legislation_code;
  --
  procedure migrate_all_hr_persons(p_number_of_workers in number default 1,
                                   p_current_worker    in number default 1) is
    --
    l_proc varchar2(80) := g_package||'migrate_all_hr_persons';
    --
    cursor c_person is
      select *
      from   per_all_people_f
      where  party_id is null
      and    mod(person_id,p_number_of_workers) = p_current_worker-1
      and    effective_end_date = hr_api.g_eot;
    --
    cursor c_old_person(p_person_id number) is
      select *
      from   per_all_people_f
      where  party_id is null
      and    effective_end_date <> hr_api.g_eot
      and    person_id = p_person_id;
    --
    l_person     c_person%rowtype;
    l_old_person c_old_person%rowtype;
    l_count      number := 0;
    l_data_migrator_mode varchar2(30);
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- This routine will create party_records for all person
    -- records in HRMS. It will then link the created party
    -- to the child tables of person and these include
    -- 1) Competences
    -- 2) Events
    -- 3) Addresses
    -- 4) Phones
    -- 5) Qualifications
    -- 6) Establishment Attendances
    --
    -- Stage 1 - Select person latest records and create TCA
    --           person records.
    --
    l_data_migrator_mode := hr_general.g_data_migrator_mode;
    hr_general.g_data_migrator_mode := 'Y';
    --
    g_count := 100;
    --
    open c_person;
      --
      loop
        --
        fetch c_person into l_person;
        exit when c_person%notfound;
        --
        begin
          --
          savepoint last_position;
          --
          create_tca_person(p_rec => l_person);
          --
          -- Stage 2 - Apply newly created party id to latest
          --           person record.
          --
          update_person(p_rec => l_person);
          --
          -- Stage 3 - Take the newly created party_id from the
          --           person just created and update the old
          --           person records with that same party_id.
          --
          open c_old_person(l_person.person_id);
            --
            loop
              --
              fetch c_old_person into l_old_person;
              exit when c_old_person%notfound;
              --
              l_old_person.party_id := l_person.party_id;
              --
              update_person(p_rec => l_old_person);
              --
            end loop;
            --
          close c_old_person;
          --
          -- Stage 4 - Take the newly created party id from the
          --           person just created and update the related
          --           person child information.
          --
          update_child_tables(p_rec => l_person);
          --
          l_count := l_count + 1;
          --
          if mod(l_count,10) = 0 then
            --
            -- Commit every ten persons
            --
            commit;
            l_count := 0;
            --
          end if;
          --
        end;
        --
      end loop;
      --
    close c_person;
    --
    -- Get the last set of records in the chunk.
    --
    commit;
    --
    g_count := 0;
    --
    hr_general.g_data_migrator_mode := l_data_migrator_mode;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
  end;
  --
  procedure create_update_contact_point
    (p_rec                in out nocopy per_all_people_f%rowtype) is
    --
    l_proc          varchar2(80) := g_package||'create_update_contact_point';
    --
    -- Cursor to select existing email address from hz_parties
    CURSOR c1 IS
       SELECT email_address, last_update_date,contact_point_id,status
       FROM hz_contact_points hcp
       WHERE hcp.contact_point_type = 'EMAIL'
       and hcp.owner_table_name = 'HZ_PARTIES'
       and hcp.owner_table_id = p_rec.party_id
       order by last_update_date desc,contact_point_id desc;


    --Define local variables
    -- Modified for bug # 2648797
    -- The call has been made to TCA v2 file (hz_contact_point_v2pub)
    -- object version number has been added
    l_c1 c1%rowtype;
    l_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    l_email_rec hz_contact_point_v2pub.email_rec_type;
    l_return_status varchar2(30);
    l_msg_count number;
    l_msg_data varchar2(2000);
    l_contact_point_id number;
    l_object_version_number number;
    l_web_rec hz_contact_point_v2pub.web_rec_type;
    l_edi_rec hz_contact_point_v2pub.edi_rec_type;
    l_phone_rec hz_contact_point_v2pub.phone_rec_type;
    l_telex_rec hz_contact_point_v2pub.telex_rec_type;
    l_init_msg_list varchar2(30);
--bug no 5546586 starts here
    l_email_changed	boolean:=false;
--bug no 5546586 ends here
BEGIN
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    --Added for bug 2648797
    l_contact_point_rec.created_by_module := 'HR API';
    --
    --
    --
--bug no 5546586 starts here
    if g_old_email_address is null then
    	if p_rec.email_address is not null then
    		l_email_changed:=true;
    	end if;
    else
    	if p_rec.email_address is null then
    		l_email_changed:=true;
    	elsif g_old_email_address<>p_rec.email_address then
    		l_email_changed:=true;
    	end if;
    end if;
    g_old_email_address:=null;
--bug no 5546586 ends here
    OPEN c1;
    FETCH c1 INTO l_c1;
    IF c1%found THEN
    --
    hr_utility.set_location(l_proc,20);
    --
    --Added for bug 2648797
    --Get the object version number
    select max(object_version_number)
    into   l_object_version_number
    from   hz_contact_points hcp
    where hcp.contact_point_id = l_c1.contact_point_id;
    --
--bug no 5546586 starts here
   if(l_email_changed) then
--bug no 5546586 ends here
       IF (l_c1.email_address is null or l_c1.email_address = 'NULL')
           and (p_rec.email_address is not null) THEN
              --
              hr_utility.set_location('Entering '||l_proc,30);
              --
              l_contact_point_rec.contact_point_id := l_c1.contact_point_id;
              l_email_rec.email_address := p_rec.email_address;
              --
              --Modified for Bug 2648797
              -- api version and p_last_update_date have been commented as TCA V2 does
              -- not include them
                 --Added for 4697454
                 -- Set Created by Module only when creatinbg
                 -- set to null when updating.
                 l_contact_point_rec.created_by_module := null;
             hz_contact_point_v2pub.update_contact_point
               (
               --p_api_version        => 1.0,
                p_contact_point_rec => l_contact_point_rec,
                p_email_rec          => l_email_rec,
               -- p_last_update_date   => l_c1.last_update_date,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_web_rec           => l_web_rec,
                p_edi_rec          => l_edi_rec,
                p_phone_rec         => l_phone_rec,
                p_telex_rec         => l_telex_rec,
                p_init_msg_list     => l_init_msg_list,
                p_object_version_number  => l_object_version_number
                );
            --
            hr_utility.set_location(l_proc,40);
            --
        if l_return_status in ('E','U') then
          --
          -- bug 4632157 Starts
          if l_msg_count > 1 then
            for i in 1..l_msg_count
            loop
              l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            end loop;
          end if;
          -- bug 4632157 ends
          --
          hr_utility.set_location(l_msg_data,10);
          fnd_message.raise_error;

        end if;


       ELSIF (l_c1.email_address is not null and p_rec.email_address is not null)
              and  (l_c1.email_address <> p_rec.email_address) THEN
            --
            hr_utility.set_location(l_proc,50);
            --
            l_contact_point_rec.contact_point_type := 'EMAIL';
            l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
            l_contact_point_rec.owner_table_id := p_rec.party_id;
            l_contact_point_rec.status := 'A';
            l_contact_point_rec.primary_flag := 'Y';
            l_email_rec.email_address := p_rec.email_address;
            --
             --Modified for Bug 2648797
             -- api version has been commented as TCA V2 does not include it
                 --Added for 4697454
                 -- Set Created by Module only when creatinbg
                 -- set to null when updating.
                 l_contact_point_rec.created_by_module := 'HR API';
            hz_contact_point_v2pub.create_contact_point
              (
               --p_api_version        => 1.0,
               p_contact_point_rec => l_contact_point_rec,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_web_rec           => l_web_rec,
               p_edi_rec          => l_edi_rec,
               p_email_rec        => l_email_rec,
               p_phone_rec         => l_phone_rec,
               p_telex_rec         => l_telex_rec,
               p_init_msg_list     => l_init_msg_list,
               x_contact_point_id   => l_contact_point_id
               );
            --
            hr_utility.set_location(l_proc,60);
            --
            if l_return_status in ('E','U') then
            --

                hr_utility.set_location(l_msg_count,10);
                -- bug 4632157 Starts
                if l_msg_count > 1 then
                  for i in 1..l_msg_count
                  loop
                    l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  end loop;
                end if;
                -- bug 4632157 ends
                hr_utility.set_location(l_msg_data,10);
                fnd_message.raise_error;
            --
            end if;
            --

            hr_utility.set_location(l_proc,70);
            --
              l_contact_point_rec.contact_point_id := l_c1.contact_point_id;
              l_contact_point_rec.status := 'I';
              l_contact_point_rec.primary_flag := 'N';
              l_email_rec.email_address := l_c1.email_address;
             --
             -- Start of fix for bug 3374509
             -- Requerying last_update_date from hz_contact_points
             -- before passing it tto update contact API.
             -- Due to Validation relaxation by TCA API. All previous records
             -- are updated by create contact points API.
             --
              select last_update_date
              into l_c1.last_update_date
              from  hz_contact_points
              where contact_point_id = l_c1.contact_point_id;
              --Modified for Bug 2648797
              -- api version and p_last_update_date have been commented as TCA V2 does
              -- not include them
                 --Added for 4697454
                 -- Set Created by Module only when creatinbg
                 -- set to null when updating.
                 l_contact_point_rec.created_by_module := null;
             hz_contact_point_v2pub.update_contact_point
               (
                --p_api_version        => 1.0,
                p_contact_point_rec => l_contact_point_rec,
                p_email_rec          => l_email_rec,
               -- p_last_update_date   => l_c1.last_update_date,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_web_rec           => l_web_rec,
                p_edi_rec          => l_edi_rec,
                p_phone_rec         => l_phone_rec,
                p_telex_rec         => l_telex_rec,
                p_init_msg_list     => l_init_msg_list,
                p_object_version_number  => l_object_version_number
                );
             --
             hr_utility.set_location(l_proc,80);
             --

             if l_return_status in ('E','U') then
                --

                -- bug 4632157 Starts
                if l_msg_count > 1 then
                  for i in 1..l_msg_count
                  loop
                    l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  end loop;
                end if;
                -- bug 4632157 ends
                hr_utility.set_location(l_msg_data,10);
                fnd_message.raise_error;
                --
            end if;
     -- added <> 'NULL' condition below for bug 4694355
     ELSIF ( l_c1.email_address is not null and l_c1.email_address <> 'NULL' )
            and (p_rec.email_address is null) then
              --
              hr_utility.set_location(l_proc,90);
              --

              l_contact_point_rec.contact_point_id := l_c1.contact_point_id;
              l_contact_point_rec.status := 'I';
              --Modified for Bug 2648797
              -- api version and p_last_update_date have been commented as TCA V2 does
              -- not include them
                 --Added for 4697454
                 -- Set Created by Module only when creatinbg
                 -- set to null when updating.
                 l_contact_point_rec.created_by_module := null;
              hz_contact_point_v2pub.update_contact_point
               (
                --p_api_version        => 1.0,
                p_contact_point_rec => l_contact_point_rec,
                p_email_rec          => l_email_rec,
               -- p_last_update_date   => l_c1.last_update_date,
                x_return_status      => l_return_status,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data,
                p_web_rec           => l_web_rec,
                p_edi_rec          => l_edi_rec,
                p_phone_rec         => l_phone_rec,
                p_telex_rec         => l_telex_rec,
                p_init_msg_list     => l_init_msg_list,
                p_object_version_number  => l_object_version_number
                );
              --
              hr_utility.set_location(l_proc,100);
              --
              if l_return_status in ('E','U') then
                --

                -- bug 4632157 Starts
                if l_msg_count > 1 then
                  for i in 1..l_msg_count
                  loop
                    l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  end loop;
                end if;
                -- bug 4632157 ends
                hr_utility.set_location(l_msg_data,10);
                fnd_message.raise_error;
                --
              end if;

       END IF;
--bug no 5546586 starts here
   end if;
--bug no 5546586 ends here
    ELSE
         --
         hr_utility.set_location(l_proc,110);
         --
         IF (p_rec.email_address is not null) THEN
            --
            hr_utility.set_location(l_proc,120);
            --
            l_contact_point_rec.contact_point_type := 'EMAIL';
            l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
            l_contact_point_rec.owner_table_id := p_rec.party_id;
            l_contact_point_rec.status := 'A';
            l_contact_point_rec.primary_flag := 'Y';
            l_email_rec.email_address := p_rec.email_address;
            --
              --Modified for Bug 2648797
              -- api version has been commented as TCA V2 does not include it
                 --Added for 4697454
                 -- Set Created by Module only when creatinbg
                 -- set to null when updating.
                 l_contact_point_rec.created_by_module := 'HR API';
                 --
             hz_contact_point_v2pub.create_contact_point
              (
               --p_api_version        => 1.0,
               p_contact_point_rec => l_contact_point_rec,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_web_rec           => l_web_rec,
               p_edi_rec          => l_edi_rec,
               p_email_rec        => l_email_rec,
               p_phone_rec         => l_phone_rec,
               p_telex_rec         => l_telex_rec,
               p_init_msg_list     => l_init_msg_list,
               x_contact_point_id   => l_contact_point_id
              );
            --
            hr_utility.set_location(l_proc,130);
            --
            if l_return_status in ('E','U') then
            --

                hr_utility.set_location(l_msg_count,10);
                -- bug 4632157 Starts
                if l_msg_count > 1 then
                  for i in 1..l_msg_count
                  loop
                    l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                  end loop;
                end if;
                -- bug 4632157 ends
                hr_utility.set_location(l_msg_data,10);
                fnd_message.raise_error;
            --
            end if;

         END IF;
    END IF;

    --
    hr_utility.set_location('Leaving '||l_proc,140);
    --

  end create_update_contact_point;
  --
  -- ------------------------------------------------------------------------------
  -- |--------------------------< get_system_person_type >------------------------|
  -- ------------------------------------------------------------------------------
  FUNCTION get_system_person_type
    (p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    )
  RETURN VARCHAR2
  IS
    CURSOR csr_person_types
      (p_effective_date               IN     DATE
      ,p_person_id                    IN     NUMBER
      )
    IS
      SELECT typ.system_person_type
      FROM per_person_types typ
          ,per_person_type_usages_f ptu
      WHERE typ.person_type_id = ptu.person_type_id
      --AND typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
      AND p_effective_date BETWEEN ptu.effective_start_date
                               AND ptu.effective_end_date
      AND ptu.person_id = p_person_id
      ORDER BY DECODE(typ.system_person_type
                    ,'EMP'   ,1
                    ,'CWK'   ,2
                    ,'APL'   ,3
                    ,'EX_EMP',4
                    ,'EX_CWK',5
                    ,'EX_APL',6
                             ,7
                    );
    l_system_person_type  VARCHAR2(2000);
    l_separator           varchar2(1) :='_';
    l_proc       varchar2(80) := g_package||'.get_system_person_type';
  BEGIN
  --
    hr_utility.set_location('Entering  '||l_proc,10);
    --
    FOR l_person_type IN csr_person_types
      (p_effective_date               => p_effective_date
      ,p_person_id                    => p_person_id
      )
    LOOP
      IF (l_system_person_type IS NULL)
      THEN
        l_system_person_type := l_person_type.system_person_type;
      ELSE
        l_system_person_type := l_system_person_type
                           || l_separator
                           || l_person_type.system_person_type;
      END IF;
    END LOOP;
    --
    hr_utility.set_location('Leaving  '||l_proc,10);
    --
    RETURN l_system_person_type;
    --
  END get_system_person_type;
  --
  -- ------------------------------------------------------------------------------
  -- |--------------------------< get_tca_merge_actions >-----------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Function returns actions to be performed depending upon the person_id,
  -- party_id and the system_person_type, at the end of time.
  --
  FUNCTION get_tca_merge_actions
    (p_person_id  in number
    ,p_party_id   in number
    )
  RETURN VARCHAR2
  is
    --
    -- Bug fix 3260686. l_sytem_person_type changed to varchar2(2000).
    -- l_system_person_type  per_person_types.system_person_type%type;
    l_system_person_type   varchar2(2000);
    --
    l_effective_date      date := hr_api.g_eot;
    l_return_value        varchar2(30);
    l_proc       varchar2(80) := g_package||'.get_tca_merge_actions';
    --
    -- Cursor to check for persons of a valid person_type for given party_id
    --
    cursor person_type_party_cur
       (
        p_effective_date      in  date,
        p_party_id            in number
       )
     IS
       SELECT typ.system_person_type
       FROM  per_all_people_f ppf
            ,per_person_types typ
            ,per_person_type_usages_f ptu
       WHERE ppf.party_id           = p_party_id
       AND   ppf.effective_end_date = p_effective_date
       AND   ppf.person_id          = ptu.person_id
       AND   typ.person_type_id     = ptu.person_type_id
       --Remove this as we want to view all PTU types.
       --AND   typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
       AND   ptu.effective_end_date = p_effective_date
       ORDER BY DECODE(typ.system_person_type
                      ,'EMP'   ,1
                      ,'CWK'   ,2
                      ,'APL'   ,3
                      ,'EX_EMP',4
                      ,'EX_CWK',5
                      ,'EX_APL',6
                               ,7
                      );
    --
    -- Cursor to check for persons of a valid person_type for given person_id
    --
    cursor person_type_person_cur
       (
        p_effective_date      in  date,
        p_person_id           in number
       )
     IS
       SELECT typ.system_person_type
       FROM  per_all_people_f ppf
            ,per_person_types typ
            ,per_person_type_usages_f ptu
       WHERE ppf.person_id          = p_person_id
       AND   ppf.effective_end_date = p_effective_date
       AND   ppf.person_id          = ptu.person_id
       AND   typ.person_type_id     = ptu.person_type_id
       --Remove this as we want to view all PTU types.
       --AND   typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
       AND   ptu.effective_end_date = p_effective_date
       ORDER BY DECODE(typ.system_person_type
                      ,'EMP'   ,1
                      ,'CWK'   ,2
                      ,'APL'   ,3
                      ,'EX_EMP',4
                      ,'EX_CWK',5
                      ,'EX_APL',6
                               ,7
                      );

    --
  Begin
  --
    hr_utility.set_location('Entering  '||l_proc,10);
    --
    l_system_person_type := per_hrtca_merge.get_system_person_type(
                                              l_effective_date,
                                              p_person_id);

    if p_party_id is null then
      --
      --
      -- If the person type is not OTHER and includes CTW then valid for
      -- propagation otherwise not a valid case of propagation
      --
      -- Notes from MB.
      -- ==============
      -- Remove composite types as they will never occur in the PTU table.
      --
      -- As this will normally only get called when creating a person or when
      -- converting an EX person to a current person we should be able to
      -- ignore the EX types.
      --
      for person_type in person_type_person_cur(l_effective_date,p_person_id)
      loop
        --
        hr_utility.set_location('Person Type  '||person_type.system_person_type,20);
        --
        --
        -- 4120469 Added the Ex-Emp/Ex-Cwk/Ex-Apl
        --
        if person_type.system_person_type in ('APL','CWK',
                                              'EMP','EX_APL',
                                              'EX_CWK','EX_EMP') then
           l_return_value := 'CREATE PARTY';
           --
           -- since atleast one person has a valid person type,
           -- no need to check further
           --
           exit;
           --
        -- 4120469 commented this as part of fix of bug retaining party id for
        -- Ex-Emp/Ex-Cwk/Ex-Apl and contacts.
--       elsif person_type.system_person_type in ('EX_APL','EX_CWK',
--                                 'EX_EMP') then
--           --
--         -- It's valid to have a party but only if not also contact. So
--         -- set return value and contineu through the rest of the records.
--         --
--         l_return_value := 'PARTY VALID';
--         --
        else
           --
           l_return_value := 'AVOID CREATE PARTY';
           --
        end if;
        --
      end loop;
      --
    else
      -- We need to check all persons in all business groups to find a valid person
      -- with a valid person_type exists.
      --
      for person_type in person_type_party_cur(l_effective_date,p_party_id) loop
        --
        hr_utility.set_location('Person Type '||person_type.system_person_type,30);
        --
        --
        -- 4120469 Added the Ex-Emp/Ex-Cwk/Ex-Apl
        --
        if person_type.system_person_type in ('APL','CWK',
                                              'EMP','EX_APL',
                                              'EX_CWK','EX_EMP') then
           l_return_value := 'PARTY VALID';
           --
           -- since atleast one person has a valid person type, no need to check further
           --
           exit;
           --
      -- 4120469 Commented out the whole for retaining party id for
      -- Ex-Emp/Ex-Cwk/Ex-Apl.
--        elsif person_type.system_person_type in ('EX_APL','EX_CWK',
--                                 'EX_EMP') then
--           --
--         -- It's valid to have a party but only if not also contact. So
--         -- set return value and contineu through the rest of the records.
--         --
--         l_return_value := 'PARTY VALID';
--
--         --
        else
           --
           l_return_value := 'PARTY INVALID';
           --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Start of fix for IRC Bug 3202002
    if l_return_value <> 'CREATE PARTY'
       and irc_candidate_test.is_person_a_candidate(p_person_id) then
          l_return_value := 'CREATE PARTY';
    end if;
    --
    -- End of fix for IRC Bug 3202002
    hr_utility.set_location('Leaving  '||l_proc,10);
    --
    return (l_return_value);
    --
  end get_tca_merge_actions;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |--------------------------< clear_party_from_hrms >-----------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Procedure to clear the party_id from all tables in HRMS that reference it.
  -- This is performed when a person is no longer eligible for a party,
  -- the party may have been purged from TCA so we also want to break the link to
  -- the party in HRMS.
  --
  procedure clear_party_from_hrms
    (p_party_id           in number) is
    --
    l_proc varchar2(80) := g_package||'clear_party_from_hrms';

  begin

    hr_utility.set_location('Entering : '||l_proc,10);
    /*
    ** Clear party_id information from all records relating to the current
    ** party_id across all business groups.
    **
    ** For performance reasons just use direct SQL and not the APIs
    */
    begin
      update PER_ADDRESSES
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_COMPETENCE_ELEMENTS
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_ESTABLISHMENT_ATTENDANCES
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_EVENTS
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_PHONES
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_PREVIOUS_EMPLOYERS
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_QUALIFICATIONS
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_ALL_PEOPLE_F
         set party_id = null
       where party_id = p_party_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    hr_utility.set_location('Leaving : '||l_proc, 100);

  end clear_party_from_hrms;
  --
  -- ------------------------------------------------------------------------------
  -- |--------------------------< clear_parties_from_hrms >-----------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure clear_parties_from_hrms is
    --
    l_proc varchar2(80) := g_package||'clear_parties_from_hrms';
    l_data_migrator_mode            varchar2(30);
    --
    cursor c_competences is
      select pce.party_id
      from   per_competence_elements pce,
             hr_tca_party_unmerge punm
      where  pce.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_pce_party_id          g_party_id_type;
    --
    cursor c_events is
      select eve.party_id
      from   per_events eve,
             hr_tca_party_unmerge punm
      where  eve.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_eve_party_id          g_party_id_type;
    --
    cursor c_addresses is
      select addr.party_id
      from   per_addresses addr,
             hr_tca_party_unmerge punm
      where  addr.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_add_party_id          g_party_id_type;
    --
    cursor c_phones is
      select phn.party_id
      from   per_phones phn,
             hr_tca_party_unmerge punm
      where  phn.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_phn_party_id          g_party_id_type;
    --
    cursor c_qualifications is
      select qua.party_id
      from   per_qualifications qua,
             hr_tca_party_unmerge punm
      where  qua.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_qua_party_id          g_party_id_type;
    --
    cursor c_establishment_attendances is
      select esta.party_id
      from   per_establishment_attendances esta,
             hr_tca_party_unmerge punm
      where  esta.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_esta_party_id          g_party_id_type;
    --
    cursor c_prev_employers is
      select pemp.party_id
      from   per_previous_employers pemp,
             hr_tca_party_unmerge punm
      where  pemp.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_pemp_party_id          g_party_id_type;
    --
    cursor c_people is
      select papf.party_id
      from   per_all_people_f papf,
             hr_tca_party_unmerge punm
      where  papf.party_id = punm.party_id
      and    punm.status  = 'PURGE';
    --
    t_papf_party_id          g_party_id_type;
    --
  begin
      --
      l_data_migrator_mode := hr_general.g_data_migrator_mode;
      hr_general.g_data_migrator_mode := 'Y';
      --
    --
    /*
    hr_utility.set_location('Entering : '||l_proc,10);
    ** Clear party_id information from all records relating to the current
    ** party_id across all business groups.
    **
    ** For performance reasons just use direct SQL and not the APIs
    */

    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- This package repeatedly calls the child table related API's for a
    -- particular party and updates the party_id column to null for the
    -- party_id that has been passed in.
    --
    -- 1) Competences
    -- 2) Events
    -- 3) Addresses
    -- 4) Phones
    -- 5) Qualifications
    -- 6) Establishment Attendances
    -- 7) Previous Employers
    -- 8) Per all people f
    --
    -- Loop through all of a persons competence records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN COMPETENCES',10);
    --
    open c_competences;
      --
      loop
        --
        fetch c_competences BULK COLLECT into t_pce_party_id LIMIT 2000;
        if t_pce_party_id.count = 0 then
          exit;
        end if;
        --
        FORALL i in t_pce_party_id.FIRST..t_pce_party_id.LAST
        update per_competence_elements
        set    party_id = null
        where  party_id = t_pce_party_id(i);
        --
        commit;
        --fix for 3831453
        t_pce_party_id.delete;
        --
      end loop;
      --
    close c_competences;
    --
    -- Loop through all of a persons event records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN EVENTS',10);
    open c_events;
      --
      loop
        --
        fetch c_events BULK COLLECT into t_eve_party_id LIMIT 2000;
        --
        if t_eve_party_id.count = 0 then
          exit;
        end if;
        --
        forall i in t_eve_party_id.first..t_eve_party_id.last
        update per_events
          set    party_id = null
          where  party_id = t_eve_party_id(i);
        --
        commit;
        --fix for 3831453
        t_eve_party_id.delete;
        --
      end loop;
      --
    close c_events;
    --hr_utility.set_location('FIRST ATTACK : CLOSE EVENTS',10);
    --
    -- Loop through all of a persons address records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN ADDRESSES',10);
    open c_addresses;
      --
      loop
        --
        fetch c_addresses BULK COLLECT into t_add_party_id LIMIT 2000;
        --
        if t_add_party_id.count = 0 then
          exit;
        end if;
        --
        FORALL i in t_add_party_id.FIRST..t_add_party_id.LAST
        update per_addresses
          set party_id = null
          where party_id = t_add_party_id(i);
        --
        commit;
        --fix for 3831453
        t_add_party_id.delete;
        --
      end loop;
      --
    close c_addresses;
    --hr_utility.set_location('FIRST ATTACK : CLOSE ADDRESSES',10);
    --
    -- Loop through all of a persons phone records
    --
    hr_utility.set_location('FIRST ATTACK : OPEN PHONES',10);
    open c_phones;
      --
      loop
        --
        fetch c_phones BULK COLLECT into t_phn_party_id limit 2000;
        --
        if t_phn_party_id.count = 0 then
          exit;
        end if;
        --
        FORALL i in t_phn_party_id.FIRST..t_phn_party_id.LAST
        update per_phones
        set    party_id = null
        where  party_id = t_phn_party_id(i);
        --
        commit;
        --fix for 3831453
        t_phn_party_id.delete;
        --
      end loop;
      --
    close c_phones;
    --hr_utility.set_location('FIRST ATTACK : CLOSE PHONES',10);
    --
    -- Loop through all of a persons qualification records
    --
    open c_qualifications;
      --
      loop
        --
        fetch c_qualifications BULK COLLECT into t_qua_party_id limit 2000;
        --
        if t_qua_party_id.count = 0 then
          exit;
        end if;
        --
        forall i in t_qua_party_id.first..t_qua_party_id.last
        update per_qualifications
          set party_id = null
          where party_id = t_qua_party_id(i);
        --
        commit;
        --fix for 3831453
        t_qua_party_id.delete;
        --
      end loop;
      --
    close c_qualifications;
    --
    -- Loop through all of a persons establishment attendance records
    --
    open c_establishment_attendances;
      --
      loop
        --
        fetch c_establishment_attendances BULK COLLECT into t_esta_party_id limit 2000;
        --
        if t_esta_party_id.count = 0 then
          exit;
        end if;
        --
        -- No API at the moment so use base table.
        --
        forall i in t_esta_party_id.first..t_esta_party_id.last
        update per_establishment_attendances
          set party_id = null
          where party_id = t_esta_party_id(i);
        --
        commit;
        --fix for 3831453
        t_esta_party_id.delete;
        --
      end loop;
      --
    close c_establishment_attendances;
    --
    --
    -- Loop through all of a persons establishment attendance records
    --
    open c_prev_employers;
      --
      loop
        --
        fetch c_prev_employers BULK COLLECT  into t_pemp_party_id LIMIT 2000;
        --
        if t_pemp_party_id.count = 0 then
          exit;
        end if;
        --
        -- No API at the moment so use base table.
        --
        forall i in t_pemp_party_id.first..t_pemp_party_id.last
        update per_previous_employers
          set party_id = null
          where party_id = t_pemp_party_id(i);
        --
        commit;
        --fix for 3831453
        t_pemp_party_id.delete;
        --
      end loop;
      --
    close c_prev_employers;
    --
    open c_people;
      --
      loop
        --
        fetch c_people BULK COLLECT  into t_papf_party_id LIMIT 2000;
        --
        if t_papf_party_id.count = 0 then
          exit;
        end if;
        --
        forall i in t_papf_party_id.first..t_papf_party_id.last
        update per_all_people_f
          set party_id = null
          where party_id = t_papf_party_id(i);
        --
        commit;
        --fix for 3831453
        t_papf_party_id.delete;
        --
      end loop;
      --
    close c_people;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
      --
      hr_general.g_data_migrator_mode := l_data_migrator_mode;
      --
    --
  end clear_parties_from_hrms;
  --
  -- ------------------------------------------------------------------------------
  -- |----------------------------< set_party_in_hrms >-------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Procedure to set the party_id in all tables in HRMS that reference it.
  -- This is performed when a person with no party becomes eligible for a
  -- party. e.g. a contact becomes an employee.
  --
  procedure set_party_in_hrms
    (p_person_id          in number
    ,p_party_id           in number) is
    --
    l_proc varchar2(80) := g_package||'set_party_in_hrms';
    -- Bug fix 3632535 starts here

    type assignmentid is table of per_all_assignments_f.assignment_id%type index by binary_integer;
    l_assignment_id assignmentid;

    -- Bug fix 3632535 ends here

  begin

    hr_utility.set_location('Entering : '||l_proc,10);
    /*
    ** Clear party_id information from all records relating to the current
    ** party_id across all business groups.
    **
    ** For performance reasons just use direct SQL and not the APIs
    */
    begin
      update PER_ADDRESSES
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_COMPETENCE_ELEMENTS
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_ESTABLISHMENT_ATTENDANCES
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      -- bug fix 3632535 starts here
      -- update statement split into two to
      -- improve performance.

      select assignment_id
      bulk collect into l_assignment_id
      from   per_all_assignments_f
      where  person_id = p_person_id;

      forall i in 1..l_assignment_id.count
            update PER_EVENTS
            set party_id = p_party_id
            where assignment_id = l_assignment_id(i);

      -- bug fix 3632535 ends here.

      /*update PER_EVENTS
         set party_id = p_party_id
       where assignment_id in (select assignment_id
                              from per_all_assignments_f
                              where person_id = p_person_id);*/
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_PHONES
         set party_id = p_party_id
       -- There is no person_id column in per_phones table
       -- where person_id = p_person_id;
       where parent_id = p_person_id
       and   parent_table = 'PER_ALL_PEOPLE_F';
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_PREVIOUS_EMPLOYERS
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_QUALIFICATIONS
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    begin
      update PER_ALL_PEOPLE_F
         set party_id = p_party_id
       where person_id = p_person_id;
    exception
      when no_data_found then
         null;
      when others then
         raise;
    end;

    hr_utility.set_location('Leaving : '||l_proc, 100);

  end set_party_in_hrms;

    --
  -- ------------------------------------------------------------------------------
  -- |------------------------< clear_purge_parties_temp >----------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Procedure to clear the data from the temp table..
  --
  procedure clear_purge_parties_temp
  is
    l_proc varchar2(100) := g_package||'.clear_purge_parties_temp';
  begin
    hr_utility.set_location('Entering :'||l_proc,10);
    delete from hr_purge_parties_gt;
    hr_utility.set_location('Leaving :'||l_proc,20);
  end;

  --
  -- ------------------------------------------------------------------------------
  -- |---------------------------< add_party_for_purge >------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Procedure to add a party to the list of parties which are candidates
  -- for purging.  The list of party_id's to be processed is held in a
  -- global temporary table.
  --
  procedure add_party_for_purge(p_party_id number)
  is
    l_proc varchar2(100) := g_package||'add_party_for_purge';
  begin
    hr_utility.set_location('Entering : '||l_proc,10);

    begin
      insert into hr_purge_parties_gt (party_id) values (p_party_id);
    exception
      when others then
        raise;
    end;

    hr_utility.set_location('Leaving : '||l_proc,20);
  end add_party_for_purge;

  --
  -- ------------------------------------------------------------------------------
  -- |------------------------------< purge_parties >---------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- Procedure to interface with TCA party purge process. This sets up a purge
  -- batch for the parties contained with the temporary table and then calls
  -- the TCA party purge process.
  --
  -- This routine will operate differently depending on the maintenance pack
  -- level.  If the databse is at 11.5.6 or later then the full party purge
  -- process will be executed.  If it is at an earlier level then a cut
  -- down purge will be implemented which simply removes the party without any
  -- FK validation.
  --
  procedure purge_parties
  is
    l_proc varchar2(100) := g_package||'purge_parties';
    l_parent_entity_name hz_merge_dictionary.parent_entity_name%type;
    l_errbuf varchar2(1000);
    l_retcode varchar2(250);
    l_batchid number;
    l_subset_sql varchar2(1000) := 'party_id in (select party_id
                                                   from hr_purge_parties_gt)';

    cursor csr_get_purge_parties is
      select party_id
      from hr_purge_parties_gt;

    l_return_status  varchar2(100);
    l_msg_count      number;
    l_msg_data       varchar2(1000);
  begin

    hr_utility.set_location('Entering : '||l_proc,10);

    /* Insert the details into HZ_PURGE_BATCHES.
    */
    hr_utility.set_location(l_proc,30);
    select hz_purge_batches_s.nextval
      into l_batchid
      from sys.dual;

    hr_utility.set_location(l_proc,40);
    insert into hz_purge_batches (batch_id,
                                  batch_name,
                                  subset_sql,
                                  creation_date,
                                  created_by,
                                  last_update_date,
                                  last_updated_by)
                          values (l_batchid,
                                  'HR Contact Purge - '||l_batchid,
                                  l_subset_sql,
                                  sysdate,
                                  fnd_global.login_id,
                                  sysdate,
                                  fnd_global.login_id);

    /* Process the batch and determine the candidate parties for the purge..
    */
    hr_utility.set_location(l_proc,50);
    hz_purge.identify_purge_parties(l_errbuf, l_retcode,
                                    to_char(l_batchid), 'N');

    if l_retcode = 2 then
      /*
      ** The identify got an error, details of which are in l_errbuf.
      ** Raise an error and report the details we've got.
      */

      fnd_message.set_name('PER','PER_289974_TCA_PERSON');
      fnd_message.set_token('PROCEDURE','per_hrtca_merge.purge_parties');
      fnd_message.set_token('STEP','20');
      fnd_message.set_token('ERROR', l_errbuf);
      fnd_message.raise_error;
    else
      /* The identify candidates was successful so now actually perform
      ** the purge of those parties.
      */
      l_errbuf := null;
      l_retcode := null;
      hr_utility.set_location(l_proc,60);
      hz_purge.purge_parties(l_errbuf, l_retcode, to_char(l_batchid), 'N');

      if l_retcode = 2 then
        /*
        ** The purge got an error, details of which are in l_errbuf.
        ** Raise an error and report the details we've got.
        */
        fnd_message.set_name('PER','PER_289974_TCA_PERSON');
        fnd_message.set_token('PROCEDURE','per_hrtca_merge.purge_parties');
        fnd_message.set_token('STEP','30');
        fnd_message.set_token('ERROR', l_errbuf);
        fnd_message.raise_error;
      end if;
    end if;

    /* Clear the temp table.
    */
    clear_purge_parties_temp;

    hr_utility.set_location('Leaving : '||l_proc,100);
  end purge_parties;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------------< partyCleanup >----------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- procedure to process a range of person_ids and purge party data when
  -- required.
  --
  -- This is a re-written procedure to use bulk collect.

    procedure partyCleanup(
      p_process_ctrl   IN            varchar2,
      p_start_rowid     IN            rowid,
      p_end_rowid       IN            rowid,
      p_rows_processed    OUT nocopy number) is


     --TYPE g_party_id_type IS TABLE OF NUMBER(15);
      TYPE l_person_id_type IS TABLE OF NUMBER(15) index by binary_integer;
      t_party_id          g_party_id_type;
      t_person_id         l_person_id_type;
      t_party_id_to_purge g_party_id_type;
      t_party_id_notto_purge g_party_id_type;

    cursor csr_get_party_ids is
      select  distinct p.person_id, p.party_id
      from    per_all_people_f p
      where   p.rowid
      between p_start_rowid and p_end_rowid
      and     p.party_id is not null
      and not exists (select null
                      from hr_tca_party_unmerge ptyun
                      where ptyun.party_id = p.party_id);
    --
    l_effective_date      date := hr_api.g_eot;
    l_return_value        varchar2(30);
    --
    -- Cursor to check for persons of a valid person_type for given party_id
    --
    cursor person_type_party_cur
       (
        p_effective_date      in  date,
        p_party_id            in number
       )
     IS
       SELECT typ.system_person_type
       FROM  per_all_people_f ppf
            ,per_person_types typ
            ,per_person_type_usages_f ptu
       WHERE ppf.party_id           = p_party_id
       AND   ppf.effective_end_date = p_effective_date
       AND   ppf.person_id          = ptu.person_id
       AND   typ.person_type_id     = ptu.person_type_id
       --Remove this as we want to view all PTU types.
       --AND   typ.system_person_type IN ('APL','EMP','EX_APL','EX_EMP','CWK','EX_CWK','OTHER')
       AND   ptu.effective_end_date = p_effective_date
       ORDER BY DECODE(typ.system_person_type
                      ,'EMP'   ,1
                      ,'CWK'   ,2
                      ,'APL'   ,3
                      ,'EX_EMP',4
                      ,'EX_CWK',5
                      ,'EX_APL',6
                               ,7
                      );
    --
    l_have_rows_topurge number :=0;
    --
  begin

    p_rows_processed := 0;

    -- bulk collect
    open csr_get_party_ids;
    LOOP

      --
      fetch csr_get_party_ids BULK COLLECT INTO t_person_id, t_party_id LIMIT 2000;
      --close csr_get_party_ids;

      -- if no rows fetched exit out of proc
      if t_person_id.COUNT = 0 THEN
        EXIT;
      end if;

      -- loop through each person_id/party
      for i in t_person_id.FIRST..t_person_id.LAST loop
      --
      -- End of code shifted from a procedure
      --
      -- We need to check all persons in all business groups to find a valid person
      -- with a valid person_type exists.
      --
        for person_type in person_type_party_cur(l_effective_date,t_party_id(i)) loop
        --
        --
        -- 4120469 Added the Ex-Emp/Ex-Cwk/Ex-Apl
        --
          if person_type.system_person_type in ('APL','CWK',
                                                'EMP','EX_APL',
                                                'EX_CWK','EX_EMP') then
             l_return_value := 'PARTY VALID';
             --
             -- since atleast one person has a valid person type, no need to check further
             --
             exit;
            --
            -- 4120469 Commented out the whole for retaining party id for
            -- Ex-Emp/Ex-Cwk/Ex-Apl.
--         elsif person_type.system_person_type in ('EX_APL','EX_CWK',
--                                 'EX_EMP') then
--            --
--          -- It's valid to have a party but only if not also contact. So
--          -- set return value and contineu through the rest of the records.
--          --
--          l_return_value := 'PARTY VALID';
--          --
          else
            --
            l_return_value := 'PARTY INVALID';
            --
          end if;
        --
        end loop;
        --
        -- bug fix 4075396
        -- Condition added to check whether the person is an irec candidate.

        if l_return_value = 'PARTY INVALID' and
                NOT irc_candidate_test.is_person_a_candidate(t_person_id(i)) THEN
          /*
          ** The party is eligible for purging so add
          ** to the cache set of parties to be purged.
          */
          t_party_id_to_purge(t_party_id_to_purge.COUNT + 1) := t_party_id(i);

        else
          t_party_id_notto_purge(t_party_id_notto_purge.COUNT + 1) := t_party_id(i);
        end if;
        --
        -- End of code shifted from a procedure
        --
      end loop;
      --
      -- bulk insert into hr_tca_party_unmerge added new
      --
      IF t_party_id_notto_purge.COUNT > 0 THEN
        FORALL i IN t_party_id_notto_purge.FIRST..t_party_id_notto_purge.LAST
          INSERT INTO hr_tca_party_unmerge (party_id,status) VALUES (t_party_id_notto_purge(i),'NOPURGE');
          --
          t_party_id_notto_purge.delete;
          --
      END IF;

      -- do we have any parties to purge?
      IF t_party_id_to_purge.COUNT > 0 THEN
        -- bulk insert into hr_tca_party_unmerge
        FORALL i IN t_party_id_to_purge.FIRST..t_party_id_to_purge.LAST
          INSERT INTO hr_tca_party_unmerge (party_id,status) VALUES (t_party_id_to_purge(i),'PURGE');
          --
          t_party_id_to_purge.delete;
          --
        /*
        ** This call is being called after the loop, since the parties to be purged
        ** are stored in a table, and to avoid no_data_found exception in clear_parties proc.
        */
        --clear_parties_from_hrms(p_party_id_to_purge => t_party_id_to_purge);
        END IF;

      p_rows_processed := t_party_id_to_purge.COUNT+t_party_id_notto_purge.COUNT;
      l_have_rows_topurge := l_have_rows_topurge+t_party_id_to_purge.COUNT;
      --
      commit;
      -- Bug 3619347
      t_person_id.delete;
      t_party_id.delete;
      EXIT WHEN csr_get_party_ids%NOTFOUND;
      --
    END LOOP;
    --
    close csr_get_party_ids;
    --
  end partyCleanup;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< partycleanup_full_conc >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure partycleanup_full_conc(errbuf        out NOCOPY  varchar2,
                                   retcode       out NOCOPY  varchar2) is

  l_have_rows_topurge number := 0;
  --
  cursor chk_rows_exist is
    select count(party_id)
    from hr_tca_party_unmerge
    where status = 'PURGE';
  --
  l_start_rowid           rowid;
  l_end_rowid             rowid;
  l_rows_processed        number;
  --
  cursor get_rowid_range is
    select min(rowid),
           max(rowid)
    from   per_all_people_f;
  --
  l_release_name fnd_product_groups.release_name%type;
  --
  cursor csr_get_release_name is
      select release_name
        from fnd_product_groups;

  l_data_migrator_mode      varchar2(30);
  --
begin
  --
    FND_FILE.NEW_LINE(FND_FILE.log, 1);
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
  --
  open csr_get_release_name;
  fetch csr_get_release_name into l_release_name;
    --
    if csr_get_release_name%found and
      l_release_name not in ('11.5.1','11.5.2','11.5.3','11.5.4',
                             '11.5.5') then
--      and (nvl(fnd_profile.value('HR:TCA_UNMERGE_PROCESS_OPTION'),'I') ='D'
--          or nvl(fnd_profile.value('HR:TCA_UNMERGE_PROCESS_OPTION'),'I') ='P') then
      --
      open get_rowid_range;
      fetch get_rowid_range into l_start_rowid,l_end_rowid;
      close get_rowid_range;
      --
      if l_start_rowid is not null then
        per_hrtca_merge.partycleanup(
                          p_process_ctrl   => null,
                          p_start_rowid    => l_start_rowid,
                          p_end_rowid      => l_end_rowid,
                          p_rows_processed => l_rows_processed
               );
      end if;
      --

        --
        open chk_rows_exist;
        fetch chk_rows_exist into l_have_rows_topurge;
        close chk_rows_exist;
        --
      if l_have_rows_topurge > 0 then
        --
        --
        l_data_migrator_mode := hr_general.g_data_migrator_mode;
        hr_general.g_data_migrator_mode := 'Y';
        --
        clear_parties_from_hrms();
        --
        hr_general.g_data_migrator_mode := l_data_migrator_mode;
        --
        begin
          insert into hr_purge_parties_gt (PARTY_ID)
             select distinct party_id
             from hr_tca_party_unmerge
             where status = 'PURGE';
        end;

        /*
        ** Process the set of parties which require removing from an HRMS
        ** perspective.  This routine actually calls the HZ purge process.
        */
        -- Log message
        FND_FILE.put_line(fnd_file.log,'Begin TCA process to identify/purge in HR tables');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Begin HRMS process to identify/purge in HR tables');
        --
        --
        purge_parties();
        --
        commit;
        -- Log message
        FND_FILE.put_line(fnd_file.log,'End TCA process to identify/purge in HR tables');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'End TCA process to identify/purge in HR tables');
        --
        begin
          update hr_tca_party_unmerge
            set status = 'PURGE COMPLETED'
            where status = 'PURGE';
        end;
          --
        commit;
      end if;  -- have rows to purge
      --
      --
    end if;  --Version Control
    close csr_get_release_name;
    --
    retcode := '0';                     -- (successful completion)
    errbuf  := ' ';
  exception
    when others then
      retcode := '2';                   -- (error)
      errbuf := sqlerrm;

  end partycleanup_full_conc;
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< partycleanup_tca_conc >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure partycleanup_tca_conc(errbuf        out NOCOPY  varchar2,
                                  retcode       out NOCOPY  varchar2) is
--  procedure partycleanup_tca_conc is
    l_have_rows_topurge number :=0;
    --
    cursor chk_rows_exist is
      select count(party_id)
      from hr_tca_party_unmerge
      where status = 'PURGE';
    --
    l_data_migrator_mode            varchar2(30);
    --
  begin
    --
      FND_FILE.NEW_LINE(FND_FILE.log, 1);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 1);
    --
    open chk_rows_exist;
    fetch chk_rows_exist into l_have_rows_topurge;
    close chk_rows_exist;
    --
    if l_have_rows_topurge > 0 then
    --
      --
      l_data_migrator_mode := hr_general.g_data_migrator_mode;
      hr_general.g_data_migrator_mode := 'Y';
      --
      clear_parties_from_hrms();
      --
      --
      hr_general.g_data_migrator_mode := l_data_migrator_mode;
      --
      begin
        insert into hr_purge_parties_gt (PARTY_ID)
           select distinct party_id
           from hr_tca_party_unmerge
           where status = 'PURGE';
      end;

      /*
      ** Process the set of parties which require removing from an HRMS
      ** perspective.  This routine actually calls the HZ purge process.
      */
      -- Log message
      FND_FILE.put_line(fnd_file.log,'Begin TCA process to identify/purge in HR tables');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Begin HRMS process to identify/purge in HR tables');
      --
      --
        purge_parties();
      --
        commit;
      -- Log message
        FND_FILE.put_line(fnd_file.log,'End TCA process to identify/purge in HR tables');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'End TCA process to identify/purge in HR tables');
        --
      begin
        update hr_tca_party_unmerge
          set status = 'PURGE COMPLETED'
          where status = 'PURGE';
      end;
      --
      commit;
    end if;  -- have rows to purge
    --
    retcode := '0';          -- (successful completion)
    errbuf  := ' ';
    --
  exception
    when others then
      retcode := '2';        -- (error)
      errbuf := sqlerrm;

  end partycleanup_tca_conc;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< CHK_GUPUD_RUN_BOOLEAN >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  -- this returns string 'TRUE' or 'FALSE' for running the TCA unmerge processes
  --
  procedure CHK_GUPUD_RUN_BOOLEAN(retstring     out NOCOPY  varchar2) is
    l_retstring varchar2(10) := 'TRUE';
  begin
    -- For now, this procedure always returns TRUE.
    -- need to add appropriate code later
    --
    retstring := l_retstring;
  end;
  --
 -- ------------------------------------------------------------------------------
  -- |----------------------------< get_column_length >---------------------------|
  -- ------------------------------------------------------------------------------
  -- Added to fix 4201545
  -- modified for bug 6931585
function get_column_length(tab_name in varchar2
                          ,col_name in varchar2
					 ,fndApplicationIdIn in integer default 800) return number is
  --
  cursor col_len_cur is
    select width
      from fnd_columns
     where column_name = col_name
	  and application_id = fndApplicationIdIn
       and table_id = (select table_id
                         from fnd_tables
                        where table_name = tab_name
				    and application_id = fndApplicationIdIn); --modified for bug 6931585
  l_col_length   number;
  begin
    open col_len_cur;
    fetch col_len_cur into l_col_length;
    if col_len_cur%found then
      return l_col_length;
    else
      return null;
    end if;
    close col_len_cur;
--
end get_column_length;
--
  --  =============================================================================
  -- ------------------------------------------------------------------------------
  -- |----------------------------< create_tca_person >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure create_tca_person
    (p_rec                in out nocopy per_all_people_f%rowtype) is
    --
    l_proc          varchar2(80) := g_package||'create_tca_person';
    l_return_status varchar2(30);
    l_msg_count     number;
    l_msg_data      varchar2(2000);
    l_party_id      number;
    l_party_number  varchar2(2000);
    l_profile_id    number;
    l_leg_code      varchar2(80);
    l_person_rec    hz_party_v2pub.person_rec_type;  --Modified for Bug #2648797
    l_party_rec     hz_party_v2pub.party_rec_type;   --Modified for Bug #2648797
    --
    l_place_of_birth hz_person_profiles.place_of_birth%type;
    l_place_of_birth_len pls_integer := 0;
    --
    l_prev_last_name hz_person_profiles.person_previous_last_name%type;
    l_prev_last_name_len pls_integer := 0;
    --
    l_tab_exists varchar2(1);
    --
    -- where clause of the cursor is changed to add two other conditions
    -- view_application_id = 222, is for the product AR. and
    -- looking for valid is not sufficient, but rather we need to check
    -- the valid dates.
    --
    cursor c1(p_lookup_type varchar2, p_lookup_code varchar2) is
      select null
      from   fnd_lookup_values
      where  lookup_type = p_lookup_type
      and    lookup_code = p_lookup_code
      and    enabled_flag = 'Y'
      and    view_application_id = 222
      and    trunc(sysdate) between nvl(start_date_active,sysdate)
                            and     nvl(end_date_active,sysdate)
      and SECURITY_GROUP_ID = fnd_global.lookup_security_group(LOOKUP_TYPE, VIEW_APPLICATION_ID)
      and    language = userenv('LANG');
    --
    l_dummy varchar2(1);
    l_tca_merge_action varchar2(30);
    l_release_name fnd_product_groups.release_name%type;
    --
    cursor csr_get_release_name is
      select release_name
        from fnd_product_groups;
    --
  begin
    --
    -- This routine will create a person in TCA. It calls the TCA API passing
    -- in the correct column values based on the legislation of the HRMS person.
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Begin New code added for PARTY UNMERGE
    --
    --  function get_tca_merge_actions returns four possible values
    --
    --  CREATE PARTY
    --  AVOID CREATE PARTY
    --  PARTY INVALID
    --  PARTY VALID
    --
    --  if the function returns either 'CREATE PARTY' or 'PARTY VALID' regular
    --  create_tca_person needs to be processed.
    --
    --  if the function returns AVOID CREATE PARTY create_tca_person will
    --  be aborted. This person is not eligible to be merged into TCA.
    --
    --  if the function returns PARTY INVALID
    --     CLEAR_PARTY_FROM_HRMS procedure is called to clear the party from HRMS.
    --     ADD_PARTY_FOR_PURGE   procedure is called to purge the party from TCA.
    --     party_id will be forced to null fro the existing record.
    --
    --  if the function returns PARTY_VALID
    --     Regular processing continues normally
    --
    hr_utility.set_location('Party unmerge  '||l_proc,10);
    --
    --Added for bug  2648797
    l_person_rec.created_by_module := 'HR API';
    --
    l_tca_merge_action := per_hrtca_merge.get_tca_merge_actions
                            (p_person_id => p_rec.person_id
                            ,p_party_id  => p_rec.party_id
                            );
    --
    hr_utility.set_location('ACTION = :'||l_tca_merge_action,11);
    --
    if l_tca_merge_action = 'AVOID CREATE PARTY' then
       --
       -- This person is not eligible to be migrated. Do nothing and return
       --
       return;
       --
    elsif l_tca_merge_action = 'PARTY INVALID' then

       --
       -- We don't need this party any longer.  Remove the party_id
       -- from HRMS tables.
       --
       per_hrtca_merge.clear_party_from_hrms
                            (p_party_id  => p_rec.party_id);
       --
       -- Bug fix 4227635 starts here--
       -- Updated orig_system_reference to party id when the
       -- link is broken between the TCA and HR.

       update hz_parties
       set orig_system_reference = p_rec.party_id
       where party_id = p_rec.party_id
       and   substr(orig_system_reference,1,4) = 'PER:';

       -- bug fix 4227635 ends here --
       --
       -- Bug fix 4005740 starts here--

       -- Call to purge_parties is commented to improve performance.
       -- Party id is inserted into table HR_TCA_PARTY_UNMERGE
       -- so that party id will be purged when the user run the
       -- party unmerge program next time.

       INSERT INTO hr_tca_party_unmerge (party_id,status)
            VALUES (p_rec.party_id,'PURGE');
       /*
       --
       -- If we are at the appropropriate maintenance pack(11.5.6 or later)
       -- then purge the party from TCA.
       --
       open csr_get_release_name;
       fetch csr_get_release_name into l_release_name;

       if csr_get_release_name%found and
          l_release_name not in ('11.5.1','11.5.2','11.5.3','11.5.4',
                                 '11.5.5') then
         hr_utility.set_location(l_proc,12);
         --
         -- We've found the release details and are at 11.5.6 or above
         -- we have all the TCA infrastructure therefore we can continue
         -- with the purge.
         --
         -- Make calls to party purge for this party_id.
         --
         --
         per_hrtca_merge.add_party_for_purge
                            (p_party_id  => p_rec.party_id
                            );
         --
         per_hrtca_merge.purge_parties;
         --
       end if;*/
       --
       -- bug fix 4005740 ends here --
       p_rec.party_id := null;
       return;
       --
    end if;
    hr_utility.set_location('END Party unmerge  '||l_proc,20);
    --
    --
    -- End New code added for PARTY UNMERGE
    --
    --
    -- Check if party_id is already passed in, in this case we
    -- do not create the person but instead update the person.
    --
    if p_rec.party_id is not null then
      --
      update_tca_person(p_rec            => p_rec,
                        p_overwrite_data => 'N');
      retUrn;
      --
    end if;
    --
    -- Get the persons legislation code for the business group
    --
    l_leg_code :=
      get_legislation_code(p_business_group_id => p_rec.business_group_id);
    --
    -- START WWBUG 2735866
    -- Get the length of person_previous_last_name and assign it to
    -- per_hrtca_merge.g_prev_last_name, if not assigned already
    --
    -- Modiifed to fix 4201545 starts here
      hr_utility.set_location('Before prev_last_name loop ',99);
      per_hrtca_merge.g_prev_last_name_len := get_column_length('HZ_PERSON_PROFILES','PERSON_PREVIOUS_LAST_NAME',222); --for bug 6331673
     --
    if per_hrtca_merge.g_prev_last_name_len is null then
      begin
        --
        hr_utility.set_location('Before prev_last_name loop ',99);
        loop
          l_prev_last_name     := l_prev_last_name||'x';
          l_prev_last_name_len := l_prev_last_name_len + 1;
        end loop;
        --
      exception
        --
        when others then
          -- error caused by overflow
          -- clear the l_prev_last_name to save memory
          l_prev_last_name := NULL;
          -- the l_prev_last_name_len var will contain the length
          -- assign this to the pkg.global variable.
          per_hrtca_merge.g_prev_last_name_len := l_prev_last_name_len;
          --
      end;
    end if;
    -- Modiifed to fix 4201545 ends here
    l_prev_last_name_len := per_hrtca_merge.g_prev_last_name_len;
        hr_utility.set_location('Before prev_last_name '||l_prev_last_name_len,99);
    -- End WWBUG 2735866
    --
    -- Assign variables to TCA structure based on legislation
    --
    -- WWBUG 2098068
    if l_leg_code = 'JP' then
      --
      l_person_rec.person_last_name := p_rec.per_information18;
      l_person_rec.person_first_name := p_rec.per_information19;
      l_person_rec.person_name_phonetic := p_rec.full_name;
      l_person_rec.person_first_name_phonetic := p_rec.first_name;
      l_person_rec.person_last_name_phonetic := p_rec.last_name;
      --
    elsif l_leg_code = 'KR' then
      --
      l_person_rec.person_first_name := p_rec.first_name;
      l_person_rec.person_last_name := p_rec.last_name;
      l_person_rec.person_last_name_phonetic := p_rec.per_information1;
      l_person_rec.person_first_name_phonetic := p_rec.per_information2;
      --
    else
      --
      l_person_rec.person_first_name := p_rec.first_name;
      l_person_rec.person_last_name := p_rec.last_name;
      --
    end if;
    --
    -- First Name is mandatory so pass some asterisks if first name is null
    -- HZ comically removed and added this rule between HZ B and F hence we
    -- leave this logic in.
    -- Commented for Bug #2738916
    -- The TCA code can now accept first name as null. Hence the passing of asterisks
    -- is not required.

    /* if l_person_rec.person_first_name is null then
      --
      l_person_rec.person_first_name := '***********';
      --
    end if;*/
    --
    -- Assign all other variables
    --
    l_person_rec.person_middle_name := p_rec.middle_names;
    l_person_rec.person_name_suffix := p_rec.suffix;
    --l_person_rec.previous_last_name := substr(p_rec.previous_last_name,1,40);
    -- This column length is changed to 150 in one of the latest HZ FP.
    -- to make it work on both old (40) and new (150) we need substr equal
    -- to the length of the column in the database, which is stored in
    -- l_prev_last_name_len     -- WWBUG 2735866
    l_person_rec.person_previous_last_name := substr(p_rec.previous_last_name,
                                              1,l_prev_last_name_len);
    l_person_rec.known_as := p_rec.known_as;
    l_person_rec.person_identifier := p_rec.person_id;
    --
    -- WWBUG 2689895
    -- Mask data if HZ profile set.
    --
    if nvl(fnd_profile.value('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'Y' then
      --
      l_person_rec.date_of_birth := p_rec.date_of_birth;
      --
      if p_rec.sex is null then
        l_person_rec.gender := 'UNSPECIFIED';
      elsif p_rec.sex = 'F' then
        l_person_rec.gender := 'FEMALE';
      elsif p_rec.sex = 'M' then
        l_person_rec.gender := 'MALE';
      end if;
      --
      -- Modiifed to fix 4201545 starts here
       l_place_of_birth_len := get_column_length('HZ_PERSON_PROFILES','PLACE_OF_BIRTH',222); --for bug 6331673
      --
      if  l_place_of_birth_len is null then
      begin
        --
        loop
          l_place_of_birth     := l_place_of_birth||'x';
          l_place_of_birth_len := l_place_of_birth_len + 1;
        end loop;
        --
      exception
        --
        when others then
          -- error caused by overflow
          -- clear the l_place_of_birth to save memory
          l_place_of_birth := NULL;
          -- the l_place_of_birth_len var will contain the length
      end;
      --
      end if;
    --
    -- Modiifed to fix 4201545 ends here
      l_person_rec.place_of_birth := substr(p_rec.town_of_birth,1,l_place_of_birth_len);
      --
      -- Ensure that all the variables we map to TCA are valid.
      --
      if p_rec.marital_status is not null then
        --
        open c1('MARITAL_STATUS',p_rec.marital_status);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            l_person_rec.marital_status := null;
            --
          else
            --
            l_person_rec.marital_status := p_rec.marital_status;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    else
      --
      l_person_rec.marital_status := null;
      l_person_rec.date_of_birth := null;
      l_person_rec.place_of_birth := null;
      l_person_rec.gender := null;
      --
    end if;
    --
    l_person_rec.date_of_death := p_rec.date_of_death;
    l_person_rec.party_rec.orig_system_reference := 'PER:'||p_rec.person_id;
    --
    if p_rec.title is not null then
      --
      open c1('CONTACT_TITLE',p_rec.title);
        --
        fetch c1 into l_dummy;
        if c1%notfound then
          --
          l_person_rec.person_pre_name_adjunct := null;
          --
        else
          --
          l_person_rec.person_pre_name_adjunct := p_rec.title;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
    -- Call TCA API and create the person.
    --
    -- Bug 4149356 Start of Fix
    -- Write only the first 80 characters of first_name to the trace file
    --
    hr_utility.set_location(substr(l_person_rec.person_first_name,1,70),10);
    --
    -- Bug 4149356 End of Fix
    --Modified Created by Module Code to 'HR API'
    fnd_profile.put('HZ_CREATED_BY_MODULE','HR API');
    --
  -- declare added by risgupta for bug 4375792
  declare
    l_hzprofile_value   varchar2(20);
    l_hzprofile_changed varchar2(1) := 'N';
  begin
  --Modified for Bug 2648797
  -- api version,p_commit and p_validation_level have been commented as TCA V2 does
  -- not include them
    -- START risgupta bug 4375792
    l_hzprofile_value := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if nvl(l_hzprofile_value, 'Y') = 'N' then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
      l_hzprofile_changed := 'Y';
    end if;
    -- END risgupta bug 4375792

    hz_party_v2pub.create_person
      (
       --p_api_version      => 1.0,
       p_init_msg_list    => 'F',
       --p_commit           => 'F',
       p_person_rec       => l_person_rec,
       x_return_status    => l_return_status,
       x_msg_count        => l_msg_count,
       x_msg_data         => l_msg_data,
       x_party_id         => l_party_id,
       x_party_number     => l_party_number,
       x_profile_id       => l_profile_id
      -- p_validation_level => 100
      );
     -- START risgupta bug 4375792
     if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
    -- END risgupta bug 4375792
    --
    if l_return_status in ('E','U') then
      --
       -- bug 4632157 Starts
       if l_msg_count > 1 then
         for i in 1..l_msg_count
         loop
           l_msg_data := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
         end loop;
       end if;
       -- bug 4632157 ends
       fnd_message.raise_error;
      --
    end if;
   exception
     when others then
       -- START risgupta bug 4375792
       if nvl(l_hzprofile_changed,'N') = 'Y' then
         fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
         l_hzprofile_changed := 'N';
       end if;
       -- END risgupta bug 4375792
       --
       fnd_message.set_name('PER', 'PER_289974_TCA_PERSON');
       fnd_message.set_token('PROCEDURE','per_hrtca_merge.create_tca_person');
       fnd_message.set_token('STEP','5');
       fnd_message.set_token('ERROR', sqlerrm);
       fnd_message.raise_error;
      --
   end;
    --
    -- Assign party_id back to party_id for per_all_people_f row
    --
    hr_utility.set_location('Party ID = '||l_party_id,10);
    --
    p_rec.party_id := l_party_id;
    --
    -- We've now got a party_id, this may be for a new person but
    -- it might be for an existing person.  We therefore need to
    -- ripple the party_id down to all the tables in HR which hold
    -- it for this person.
    --
    per_hrtca_merge.set_party_in_hrms(
             p_party_id  => p_rec.party_id,
             p_person_id => p_rec.person_id);
    --
    if p_rec.email_address is not null then
      --
      create_update_contact_point(p_rec => p_rec);
      --
    end if;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------------< upate_tca_person >--------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure update_tca_person
    (p_rec                in out nocopy per_all_people_f%rowtype,
     p_overwrite_data     in            varchar2 default 'Y') is
    --
    l_proc                   varchar2(80) := g_package||'.update_tca_person';
    l_return_status          varchar2(30);
    l_msg_count              number;
    l_msg_data               varchar2(2000);
    l_leg_code               varchar2(80);
    l_profile_id             number;
    l_party_object_version_number number;
    l_party_last_update_date date;
    l_person_rec             hz_party_v2pub.person_rec_type;  --Modified for bug# 2648797
    l_party_rec              hz_party_v2pub.party_rec_type;   --Modified for bug# 2648797
    l_dummy                  number;
    l_tca_merge_action varchar2(30);
    --
    l_place_of_birth hz_person_profiles.place_of_birth%type;
    l_place_of_birth_len pls_integer := 0;
    --
    l_prev_last_name hz_person_profiles.person_previous_last_name%type;
    l_prev_last_name_len pls_integer := 0;
    --
    l_tab_exists varchar2(1);
    --
    -- Cursor is modified to reflect the ar_lookups so that the lookup value
    -- validation does not fail in TCA.
    -- added view_application_id = 222 , and sysddate between active dates
    -- and security_group clauses, as the ar_lookups is based on this.
    --
    cursor c1(p_lookup_type varchar2, p_lookup_code varchar2) is
      select 1
      from   fnd_lookup_values
      where  lookup_type = p_lookup_type
      and    lookup_code = p_lookup_code
      and    enabled_flag = 'Y'
      and    view_application_id = 222
      and    trunc(sysdate) between nvl(start_date_active,sysdate)
                            and     nvl(end_date_active,sysdate)
      and    SECURITY_GROUP_ID =
             fnd_global.lookup_security_group(LOOKUP_TYPE, VIEW_APPLICATION_ID)
      and    language = userenv('LANG');
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    --
    -- Begin New code added for PARTY UNMERGE
    --
    -- since party unmerge, it is possible to have null party_id for a person
    -- and no point in processing this code if party_id does not exist for
    -- this person, as this person will not have been created in tca.
    -- stop processing where party_id is null.
    --
    if p_rec.party_id is null then
      --
      return;
      --
    end if;
    --

    if p_rec.effective_end_date <> hr_api.g_eot then
      --
      -- Record being updated isn't for the end of time so call replicate
      -- routine and then return to the calling procedure.
      --
      g_count := g_count + 1;
      --
      if g_count = 1 then
        --
        replicate_person_across_bg(p_rec            => p_rec,
                                   p_overwrite_data => p_overwrite_data);
        g_count := 0;
        --
      end if;
      --
      return;
      --
    end if;
    --
    -- Get the persons legislation code for the business group
    --
    l_leg_code :=
      get_legislation_code(p_business_group_id => p_rec.business_group_id);
    --
    -- START WWBUG 2735866
    -- Get the length of person_previous_last_name and assign it to
    -- per_hrtca_merge.g_prev_last_name, if not assigned already
    --
    -- Modiifed to fix 4201545 starts here
       hr_utility.set_location('Before prev_last_name loop ',99);
       per_hrtca_merge.g_prev_last_name_len := get_column_length('HZ_PERSON_PROFILES','PERSON_PREVIOUS_LAST_NAME',222); --for bug 6331673
    --
    if per_hrtca_merge.g_prev_last_name_len is null then
      begin
        --
        hr_utility.set_location('Before prev_last_name loop ',99);
        loop
          l_prev_last_name     := l_prev_last_name||'x';
          l_prev_last_name_len := l_prev_last_name_len + 1;
        end loop;
        --
      exception
        --
        when others then
          -- error caused by overflow
          -- clear the l_prev_last_name to save memory
          l_prev_last_name := NULL;
          -- the l_prev_last_name_len var will contain the length
          -- assign this to the pkg.global variable.
          per_hrtca_merge.g_prev_last_name_len := l_prev_last_name_len;
          --
      end;
    --
    end if;
    -- Modiifed to fix 4201545 ends here
    l_prev_last_name_len := per_hrtca_merge.g_prev_last_name_len;
        hr_utility.set_location('Before prev_last_name '||l_prev_last_name_len,99);
    -- End WWBUG 2735866
    --
    -- Assign variables to TCA structure based on legislation
    --
    -- WWBUG 2096068
    if l_leg_code = 'JP' then
      --
      l_person_rec.person_last_name := p_rec.per_information18;
      l_person_rec.person_first_name := p_rec.per_information19;
      l_person_rec.person_name_phonetic := p_rec.full_name;
      l_person_rec.person_first_name_phonetic := p_rec.first_name;
      l_person_rec.person_last_name_phonetic := p_rec.last_name;
      --
    elsif l_leg_code = 'KR' then
      --
      l_person_rec.person_first_name := p_rec.first_name;
      l_person_rec.person_last_name := p_rec.last_name;
      l_person_rec.person_last_name_phonetic := p_rec.per_information1;
      l_person_rec.person_first_name_phonetic := p_rec.per_information2;
      --
    else
      --
      l_person_rec.person_first_name := p_rec.first_name;
      l_person_rec.person_last_name := p_rec.last_name;
      --
    end if;
    --
    -- First Name is mandatory so pass some asterisks if first name is null
    -- HZ removed and added this rule between HZ B and F.
    --
    -- Commented for Bug #2738916
    -- The TCA code can now accept first name as null. Hence the passing of asterisks
    -- is not required.

   /* if l_person_rec.person_first_name is null then
      --
      l_person_rec.person_first_name := '***********';
      --
    end if; */
    --
    -- Assign all other variables
    --
    hr_utility.set_location('UPDATE_TCA_PERSON Before middle Name ###'||p_rec.middle_names||'***',99);
    l_person_rec.person_middle_name := nvl(p_rec.middle_names,FND_API.G_MISS_CHAR); -- for bug 6609549.
    l_person_rec.person_name_suffix := nvl(p_rec.suffix,FND_API.G_MISS_CHAR);--fix for bug7411512.
    --l_person_rec.previous_last_name := substr(p_rec.previous_last_name,1,40);
    -- This column length is changed to 150 in one of the latest HZ FP.
    -- to make it work on both old (40) and new (150) we need substr equal
    -- to the length of the column in the database, which is stored in
    -- l_prev_last_name_len     -- WWBUG 2735866
    l_person_rec.person_previous_last_name := substr(p_rec.previous_last_name,
                                              1,l_prev_last_name_len);
    l_person_rec.known_as := p_rec.known_as;
    l_person_rec.person_identifier := p_rec.person_id;
    --
    -- WWBUG 2689895
    -- Mask data if HZ profile set.
    --
    if nvl(fnd_profile.value('HZ_PROTECT_HR_PERSON_INFO'),'-1') <> 'Y' then
      --
      if p_rec.sex is null then
        l_person_rec.gender := 'UNSPECIFIED';
      elsif p_rec.sex = 'F' then
        l_person_rec.gender := 'FEMALE';
      elsif p_rec.sex = 'M' then
        l_person_rec.gender := 'MALE';
      else
        l_person_rec.gender := p_rec.sex;
      end if;
      --
      l_person_rec.date_of_birth := p_rec.date_of_birth;
      --
      -- Modified to fix 4201545 starts here
         l_place_of_birth_len := get_column_length('HZ_PERSON_PROFILES','PLACE_OF_BIRTH',222); --for bug 6331673
      --
      if  l_place_of_birth_len is null then
      begin
        --
        loop
          --
          l_place_of_birth     := l_place_of_birth||'x';
          l_place_of_birth_len := l_place_of_birth_len + 1;
          --
        end loop;
        --
      exception
        --
        when others then
          -- error caused by overflow
          -- clear the l_place_of_birth to save memory
          l_place_of_birth := NULL;
          -- the l_place_of_birth_len var will contain the length
      end;
      --
     end if;
    --
    -- Modified to fix 4201545 ends here
      l_person_rec.place_of_birth := substr(p_rec.town_of_birth,1,l_place_of_birth_len);
      --
      -- Ensure that all the variables we map to TCA are valid.
      --
      if p_rec.marital_status is not null then
        --
        open c1('MARITAL_STATUS',p_rec.marital_status);
          --
          fetch c1 into l_dummy;
          if c1%notfound then
            --
            l_person_rec.marital_status := null;
            --
          else
            --
            l_person_rec.marital_status := p_rec.marital_status;
            --
          end if;
          --
        close c1;
        --
      end if;
      --
    else
      --
      l_person_rec.marital_status := null;
      l_person_rec.place_of_birth := null;
      l_person_rec.date_of_birth := null;
      l_person_rec.gender := null;
      --
    end if;
    --
    l_person_rec.date_of_death := p_rec.date_of_death;
    --
    -- Set party_id of record we are updating
    --
    l_person_rec.party_rec.party_id := p_rec.party_id;
    --
    if p_rec.title is not null then
      --
      open c1('CONTACT_TITLE',p_rec.title);
        --
        fetch c1 into l_dummy;
        if c1%notfound then
          --
          l_person_rec.person_pre_name_adjunct := null;
          --
        else
          --
          l_person_rec.person_pre_name_adjunct := p_rec.title;
          --
        end if;
        --
      close c1;
      --
    end if;
    --
    -- Get the latest person record
    --
    select max(last_update_date)
    into   l_party_last_update_date
    from   hz_parties
    where  party_id = p_rec.party_id;
    --
    --Added for bug 2648797
    --Get the object version number

    select max(object_version_number)
    into   l_party_object_version_number
    from   hz_parties
    where  party_id = p_rec.party_id;
    --
    -- Call TCA API and update the person.
    --
    -- Set HR security profile as HR can only update these records.
    --Modified Created by Module Code to 'HR API'
    fnd_profile.put('HZ_CREATED_BY_MODULE','HR API');
    --
   begin
  --Modified for Bug 2648797
  -- api version,p_commit,p_party_last_update_date and p_validation_level have been commented as TCA V2 does
  -- not include them
  -- object version number has been added

    hz_party_v2pub.update_person
      (
       --p_api_version            => 1.0,
       p_init_msg_list          => 'F',
       --p_commit                 => 'F',
       p_person_rec             => l_person_rec,
       --p_party_last_update_date => l_party_last_update_date,
       p_party_object_version_number => l_party_object_version_number,  --Added for bug# 2648797
       x_profile_id             => l_profile_id,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data
       --p_validation_level       => 100
        );
    --
    if l_return_status in ('E','U') then
      --
      hr_utility.set_location(substr(l_msg_data,1,80),10);
      fnd_message.set_token('POO',p_rec.party_id);
      fnd_message.raise_error;
      --
    end if;

   exception
   when others then
      --
       fnd_message.set_name('PER','PER_289974_TCA_PERSON');
       fnd_message.set_token('PROCEDURE','per_hrtca_merge.update_tca_person');
       fnd_message.set_token('STEP','10');
     --  fnd_message.set_token('ERROR', sqlerrm);  Bug  5408534 should use l_msg_data
       fnd_message.set_token('ERROR', l_msg_data);
       fnd_message.raise_error;
     --
   end;
    --
    -- Update the reference for special case where we have created a party
    -- and then assigned that party to an HR person.
    -- This will prevent any future updates to the TCA data unless the update
    -- comes from HR.
    --
    update hz_parties
      set orig_system_reference = 'PER:'||p_rec.person_id
      where party_id = p_rec.party_id
      and   substr(orig_system_reference,1,4) <> 'PER:';
    --
    -- Dirty hack to get around 2078156
    -- PER_CONTACT_RELATIONSHIPS_PKG checks for SQL%NOTFOUND
    -- after call to update_tca_person, and raises NO_DATA_FOUND
    -- if true. This update statement is causing PER_CONTACT_RELATIONSHIPS
    -- to fail - so, force a dummy query to reset SQL%NOTFOUND here
    if (SQL%NOTFOUND) then
      select 1 into l_dummy from dual;
    end if;
    --
    --Modified Created by Module Code to 'HR API'
    fnd_profile.put('HZ_CREATED_BY_MODULE','HR API');
    --
    g_count := g_count + 1;
    --
    if g_count = 1 then
      --
      replicate_person_across_bg(p_rec            => p_rec,
                                 p_overwrite_data => p_overwrite_data);
      g_count := 0;
      --
    end if;
    --
    -- Dirty hack to get around 2078156
    -- PER_CONTACT_RELATIONSHIPS_PKG checks for SQL%NOTFOUND
    -- after call to update_tca_person, and raises NO_DATA_FOUND
    -- if true. Statements in this routine can result in SQL%NOTFOUND
    -- being true, causing PER_CONTACT_RELATIONSHIPS
    -- to fail erroneously - so, force a dummy query
    -- to reset SQL%NOTFOUND here
    if (SQL%NOTFOUND) then
      select 1 into l_dummy from dual;
    end if;
    --
    create_update_contact_point(p_rec => p_rec);
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  exception
    --
    when others then
      --
      fnd_profile.put('HZ_CREATED_BY_MODULE','NON HR');
      raise;
      --
  end;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------< replicate_person_across_bg >----------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure replicate_person_across_bg
    (p_rec                in out nocopy per_all_people_f%rowtype,
     p_overwrite_data     in            varchar2 default 'Y') is
    --
    l_proc       varchar2(80) := g_package||'.replicate_person_across_bg';
    l_host_leg   varchar2(30);
    l_target_leg varchar2(30);
    --
    cursor c_person is
      select *
      from   per_all_people_f
      where  effective_start_date <= p_rec.effective_end_date
      and    effective_end_date >= p_rec.effective_start_date
      and    person_id <> p_rec.person_id
      and    party_id = p_rec.party_id
      order  by person_id, effective_start_date;
    --
    type l_person_tab is table of c_person%rowtype index by binary_integer;
    l_person l_person_tab;
    --
    cursor csr_get_person_details(cp_person_id      number,
                                  cp_effective_date date) is
          select *
          from per_all_people_f
          where person_id = cp_person_id
          and   cp_effective_date  between effective_start_date and effective_end_date;
    l_person_rec csr_get_person_details%rowtype;
    --
    l_last_bg_id               number := -1;
    l_correction               boolean;
    l_update                   boolean;
    l_update_override          boolean;
    l_update_change_insert     boolean;
    l_datetrack_mode           varchar2(30);
    l_effective_start_date     date;
    l_effective_end_date       date;
    l_full_name                varchar2(240);
    l_duplicate_flag           varchar2(30);
    l_comment_id               number;
    l_name_combination_warning boolean;
    l_assign_payroll_warning   boolean;
    l_orig_hire_warning        boolean;
    l_validation_start_date    date;
    l_validation_end_date      date;
    l_dummy_lock_id            number;
    l_copy_rec                 per_all_people_f%rowtype;
    l_ref_person_id            number;
    l_ref_effective_start_date date;
    --
    l_local_name               per_all_people_f.local_name%TYPE;
    l_global_name               per_all_people_f.global_name%TYPE;
    l_order_name               per_all_people_f.order_name%TYPE;
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- Bug fix 3598173. NVL added to if condition.

    if nvl(fnd_profile.value('HR_PROPAGATE_DATA_CHANGES'),'N') <> 'Y' then
      --
      return;
      --
    end if;
    --
    -- Get all records with the same party id where the effective start date
    -- <= host effective end date and effective end date >= effective start
    -- date of host record.
    --
    open c_person;
      --
      loop
        --
        fetch c_person into l_person(l_person.count+1);
        exit when c_person%notfound;
        --
      end loop;
      --
    close c_person;
    --
    if l_person.count = 0 then
      --
      return;
      --
    end if;
    --
    -- Get the host legislation
    --
    l_host_leg :=
      get_legislation_code(p_business_group_id => p_rec.business_group_id);
    --
    for l_count in 1..l_person.count loop
      --
      -- Get the target legislation only if the business group has changed.
      --
      if l_target_leg is null or
        l_person(l_count).business_group_id <> l_last_bg_id then
        --
        l_target_leg := get_legislation_code
         (p_business_group_id => l_person(l_count).business_group_id);
        --
      end if;
      --
      -- WWBUG 2560449
      --
      if l_host_leg <> l_target_leg and
        (l_host_leg in ('KR','JP') or l_target_leg in ('KR','JP')) then
        --
        -- Lets skip this update as the legislations are not compatible.
        --
        null;
        --
      else
        --
        -- We now have four possible scenarios for any update that takes
        -- place and they are as follows.
        --
        -- Effective Start Date of target record and Effective End Date of
        -- target record fall between Effective Start Date and Effective End
        -- Date of host record. This means a correction.
        --
        -- Effective Start Date of target record is before Effective Start
        -- Date of host record and Effective End Date of target record is
        -- before Effective End Date of host record. This means an update
        -- change insert.
        --
        -- Effective Start Date of target record is after the Effective Start
        -- Date of host record and Effective End Date of target record is
        -- after Effective End Date of host record. This means a
        -- correction followed by an update or update_change_insert based
        -- on whether future records exist.
        --
        -- Effective Start Date of target record is before the Effective
        -- Start Date of host record and Effective End Date of target record
        -- is after the Effective End Date of host record. This means an
        -- update_change_insert or update followed by an update_change_insert
        -- or update based on whether future rows exist.
        --
        if l_person(l_count).effective_start_date >= p_rec.effective_start_date and
          l_person(l_count).effective_end_date <= p_rec.effective_end_date then
          --
          l_datetrack_mode := 'CORRECTION';
          --
        elsif l_person(l_count).effective_start_date >= p_rec.effective_start_date and
          l_person(l_count).effective_end_date > p_rec.effective_end_date then
          --
          l_datetrack_mode := 'CORRECTION';
          --
          -- Then an update or update_change_insert
          --
        elsif l_person(l_count).effective_start_date < p_rec.effective_start_date and
          l_person(l_count).effective_end_date <= p_rec.effective_end_date then
          --
          if l_person(l_count).effective_end_date <> hr_api.g_eot then
            --
            l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
            --
          elsif l_person(l_count).effective_end_date = hr_api.g_eot then
            --
            l_datetrack_mode := 'UPDATE';
            --
          end if;
          --
        elsif l_person(l_count).effective_start_date < p_rec.effective_start_date and
          l_person(l_count).effective_end_date > p_rec.effective_end_date then
          --
          if l_person(l_count).effective_end_date <> hr_api.g_eot then
            --
            l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
            --
          elsif l_person(l_count).effective_end_date = hr_api.g_eot then
            --
            l_datetrack_mode := 'UPDATE';
            --
          end if;
          --
          -- Then another update_change_insert or update
          --
        end if;
        --
        -- Now call the API with the appropriate calling mode.
        --
        -- To avoid the ora-1002 error that comes from recursive calls
        -- we have to make sure that the update routine calls update
        -- tca person and then calls replicate just once. Replicate must
        -- then handle the update to all other person records and the
        -- update to TCA. We can not let the API's handle this as otherwise
        -- we get into a recursive nightmare with the following happening :
        -- API -> TCA -> REPLICATE -> API -> TCA.....
        -- We will make it work like so :
        -- API -> TCA -> REPLICATE.
        --
        -- It works fine through API's but not when called from the forms
        -- interface. Correct code will be left to make transistion easier.
        --
        hr_utility.set_location('Locking Record',10);
        hr_utility.set_location('Person_ID '||l_person(l_count).person_id,10);
        hr_utility.set_location('Effective Date '||to_char(p_rec.effective_start_date,'DD/MM/YYYY'),10);
        hr_utility.set_location('OVN '||l_person(l_count).object_version_number,10);
        hr_utility.set_location('DT mode '||l_datetrack_mode,10);
        --
        -- We have to lock ourselves as the row handler locks per_people_f
        -- which could mean that we can't lock the other records due to
        -- security issues. Additionally we have to use a loop to go through
        -- the records as otherwise we raise a 1002 error, fetch out of
        -- sequence.
        --
        -- Fix for 9i.
        -- No array referencing in SQL seems to be allowed.
        --
        l_ref_effective_start_date := l_person(l_count).effective_start_date;
        l_ref_person_id := l_person(l_count).person_id;
        --
        select person_id
        into   l_dummy_lock_id
        from   per_all_people_f
        where  l_ref_effective_start_date
               between effective_start_date
               and     effective_end_date
        and    person_id = l_ref_person_id
        for    update nowait;
        /*
        per_per_shd.lck
          (p_person_id             => l_person(l_count).person_id,
           p_datetrack_mode        => l_datetrack_mode,
           p_object_version_number => l_person(l_count).object_version_number,
           p_effective_date        => p_rec.effective_start_date,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date   => l_validation_end_date);
        */
        --
        if l_datetrack_mode = 'CORRECTION' then
          --
          hr_utility.set_location('Updating Record in Correction mode',10);
          --
          -- Set the values of the columns.
          --
          l_copy_rec.date_of_birth :=
            propagate_value
            (l_person(l_count).date_of_birth,
             p_rec. date_of_birth,
             p_overwrite_data);
          l_copy_rec.first_name :=
            propagate_value
            (l_person(l_count).first_name,
             p_rec.first_name,
             p_overwrite_data);
          l_copy_rec.known_as :=
            propagate_value
            (l_person(l_count).known_as,
             p_rec.known_as,
             p_overwrite_data);
          l_copy_rec.marital_status :=
            propagate_value
            (l_person(l_count).marital_status,
             p_rec.marital_status,
             p_overwrite_data);
          l_copy_rec.middle_names :=
            propagate_value
            (l_person(l_count).middle_names,
             p_rec.middle_names,
             p_overwrite_data);
          l_copy_rec.nationality :=
            propagate_value
            (l_person(l_count).nationality,
             p_rec.nationality,
             p_overwrite_data);
          l_copy_rec.sex :=
            propagate_value
            (l_person(l_count).sex,
             p_rec.sex,
             p_overwrite_data);
          l_copy_rec.title :=
            propagate_value
            (l_person(l_count).title,
             p_rec.title,
             p_overwrite_data);
          l_copy_rec.blood_type :=
            propagate_value
            (l_person(l_count).blood_type,
             p_rec.blood_type,
             p_overwrite_data);
          l_copy_rec.correspondence_language :=
            propagate_value
            (l_person(l_count).correspondence_language,
             p_rec.correspondence_language,
             p_overwrite_data);
          l_copy_rec.honors :=
            propagate_value
            (l_person(l_count).honors,
             p_rec.honors,
             p_overwrite_data);
          l_copy_rec.pre_name_adjunct :=
            propagate_value
            (l_person(l_count).pre_name_adjunct,
             p_rec.pre_name_adjunct,
             p_overwrite_data);
          l_copy_rec.rehire_authorizor :=
            propagate_value
            (l_person(l_count).rehire_authorizor,
             p_rec.rehire_authorizor,
             p_overwrite_data);
          l_copy_rec.rehire_recommendation :=
            propagate_value
            (l_person(l_count).rehire_recommendation,
             p_rec.rehire_recommendation,
             p_overwrite_data);
          l_copy_rec.resume_exists :=
            propagate_value
            (l_person(l_count).resume_exists,
             p_rec.resume_exists,
             p_overwrite_data);
          l_copy_rec.resume_last_updated :=
            propagate_value
            (l_person(l_count).resume_last_updated,
             p_rec.resume_last_updated,
             p_overwrite_data);
          l_copy_rec.second_passport_exists :=
            propagate_value
            (l_person(l_count).second_passport_exists,
             p_rec.second_passport_exists,
             p_overwrite_data);
          l_copy_rec.student_status :=
            propagate_value
            (l_person(l_count).student_status,
             p_rec.student_status,
             p_overwrite_data);
          l_copy_rec.suffix :=
            propagate_value
            (l_person(l_count).suffix,
             p_rec.suffix,
             p_overwrite_data);
          l_copy_rec.date_of_death :=
            propagate_value
            (l_person(l_count).date_of_death,
             p_rec.date_of_death,
             p_overwrite_data);
          l_copy_rec.uses_tobacco_flag :=
            propagate_value
            (l_person(l_count).uses_tobacco_flag,
             p_rec.uses_tobacco_flag,
             p_overwrite_data);
          l_copy_rec.town_of_birth :=
            propagate_value
            (l_person(l_count).town_of_birth,
             p_rec.town_of_birth,
             p_overwrite_data);
          l_copy_rec.region_of_birth :=
            propagate_value
            (l_person(l_count).region_of_birth,
             p_rec.region_of_birth,
             p_overwrite_data);
          l_copy_rec.country_of_birth :=
            propagate_value
            (l_person(l_count).country_of_birth,
             p_rec.country_of_birth,
             p_overwrite_data);
          l_copy_rec.fast_path_employee :=
            propagate_value
            (l_person(l_count).fast_path_employee,
             p_rec.fast_path_employee,
             p_overwrite_data);
          l_copy_rec.email_address := propagate_value
            (l_person(l_count).email_address,
             p_rec.email_address,
             p_overwrite_data);
          l_copy_rec.fte_capacity := propagate_value
            (l_person(l_count).fte_capacity,
             p_rec.fte_capacity,
             p_overwrite_data);
          -- Bug fix 3598173 starts here
          l_copy_rec.previous_last_name :=
            propagate_value
            (l_person(l_count).previous_last_name,
             p_rec.previous_last_name,
             p_overwrite_data);
          -- Bug fix 3598173 ends here.
          --
          --hr_person.derive_full_name
          --  (p_first_name        => l_copy_rec.first_name,
          --   p_middle_names      => l_copy_rec.middle_names,
          --   p_last_name         => p_rec.last_name,
          --   p_known_as          => l_copy_rec.known_as,
          --   p_title             => l_copy_rec.title,
          --   p_suffix            => l_copy_rec.suffix,
          --   p_pre_name_adjunct  => l_copy_rec.pre_name_adjunct,
          --   p_date_of_birth     => l_copy_rec.date_of_birth,
          --   p_person_id         => l_person(l_count).person_id,
          --   p_business_group_id => l_person(l_count).business_group_id,
          --   p_full_name         => l_full_name,
          --   p_duplicate_flag    => l_duplicate_flag);
          --
          hr_person_name.derive_person_names  -- #3889584
            (p_format_name        =>  NULL, -- derive all person names
             p_business_group_id  =>  l_person(l_count).business_group_id,
             p_person_id          =>  l_person(l_count).person_id,
             p_first_name         =>  l_copy_rec.first_name,
             p_middle_names       =>  l_copy_rec.middle_names,
             p_last_name          =>  p_rec.last_name,
             p_known_as           =>  l_copy_rec.known_as,
             p_title              =>  l_copy_rec.title,
             p_suffix             =>  l_copy_rec.suffix,
             p_pre_name_adjunct   =>  l_copy_rec.pre_name_adjunct,
             p_date_of_birth      =>  l_copy_rec.date_of_birth,
             p_previous_last_name =>  l_copy_rec.previous_last_name ,
             p_email_address     =>   l_copy_rec.email_address,
             p_employee_number    =>  l_person(l_count).employee_number  ,
             p_applicant_number   =>  l_person(l_count).applicant_number  ,
             p_npw_number         =>  l_person(l_count).npw_number,
             p_per_information1   =>  l_person(l_count).per_information1  ,
             p_per_information2   =>  l_person(l_count).per_information2  ,
             p_per_information3   =>  l_person(l_count).per_information3  ,
             p_per_information4   =>  l_person(l_count).per_information4  ,
             p_per_information5   =>  l_person(l_count).per_information5  ,
             p_per_information6   =>  l_person(l_count).per_information6  ,
             p_per_information7   =>  l_person(l_count).per_information7  ,
             p_per_information8   =>  l_person(l_count).per_information8  ,
             p_per_information9   =>  l_person(l_count).per_information9  ,
             p_per_information10  =>  l_person(l_count).per_information10  ,
             p_per_information11  =>  l_person(l_count).per_information11  ,
             p_per_information12  =>  l_person(l_count).per_information12  ,
             p_per_information13  =>  l_person(l_count).per_information13  ,
             p_per_information14  =>  l_person(l_count).per_information14  ,
             p_per_information15  =>  l_person(l_count).per_information15  ,
             p_per_information16  =>  l_person(l_count).per_information16  ,
             p_per_information17  =>  l_person(l_count).per_information17  ,
             p_per_information18  =>  l_person(l_count).per_information18  ,
             p_per_information19  =>  l_person(l_count).per_information19  ,
             p_per_information20  =>  l_person(l_count).per_information20  ,
             p_per_information21  =>  l_person(l_count).per_information21  ,
             p_per_information22  =>  l_person(l_count).per_information22  ,
             p_per_information23  =>  l_person(l_count).per_information23  ,
             p_per_information24  =>  l_person(l_count).per_information24  ,
             p_per_information25  =>  l_person(l_count).per_information25  ,
             p_per_information26  =>  l_person(l_count).per_information26  ,
             p_per_information27  =>  l_person(l_count).per_information27  ,
             p_per_information28  =>  l_person(l_count).per_information28  ,
             p_per_information29  =>  l_person(l_count).per_information29  ,
             p_per_information30  =>  l_person(l_count).per_information30  ,
             p_attribute1         =>  l_person(l_count).attribute1  ,
             p_attribute2         =>  l_person(l_count).attribute2  ,
             p_attribute3         =>  l_person(l_count).attribute3  ,
             p_attribute4         =>  l_person(l_count).attribute4  ,
             p_attribute5         =>  l_person(l_count).attribute5  ,
             p_attribute6         =>  l_person(l_count).attribute6  ,
             p_attribute7         =>  l_person(l_count).attribute7  ,
             p_attribute8         =>  l_person(l_count).attribute8  ,
             p_attribute9         =>  l_person(l_count).attribute9  ,
             p_attribute10        =>  l_person(l_count).attribute10  ,
             p_attribute11        =>  l_person(l_count).attribute11  ,
             p_attribute12        =>  l_person(l_count).attribute12  ,
             p_attribute13        =>  l_person(l_count).attribute13  ,
             p_attribute14        =>  l_person(l_count).attribute14  ,
             p_attribute15        =>  l_person(l_count).attribute15  ,
             p_attribute16        =>  l_person(l_count).attribute16  ,
             p_attribute17        =>  l_person(l_count).attribute17  ,
             p_attribute18        =>  l_person(l_count).attribute18  ,
             p_attribute19        =>  l_person(l_count).attribute19  ,
             p_attribute20        =>  l_person(l_count).attribute20  ,
             p_attribute21        =>  l_person(l_count).attribute21  ,
             p_attribute22        =>  l_person(l_count).attribute22  ,
             p_attribute23        =>  l_person(l_count).attribute23,
             p_attribute24        =>  l_person(l_count).attribute24,
             p_attribute25        =>  l_person(l_count).attribute25,
             p_attribute26        =>  l_person(l_count).attribute26,
             p_attribute27        =>  l_person(l_count).attribute27,
             p_attribute28        =>  l_person(l_count).attribute28,
             p_attribute29        =>  l_person(l_count).attribute29,
             p_attribute30        =>  l_person(l_count).attribute30,
             p_full_name          =>  l_full_name,
             p_order_name         =>  l_order_name,
             p_global_name        =>  l_global_name,
             p_local_name         =>  l_local_name,
             p_duplicate_flag     =>  l_duplicate_flag);

          l_ref_effective_start_date := l_person(l_count).effective_start_date;
          l_ref_person_id := l_person(l_count).person_id;
          --
          update per_all_people_f
          set  last_name                = p_rec.last_name,
               full_name                = l_full_name,
               date_of_birth            = l_copy_rec.date_of_birth,
               first_name               = l_copy_rec.first_name,
               known_as                 = l_copy_rec.known_as,
               marital_status           = l_copy_rec.marital_status,
               middle_names             = l_copy_rec.middle_names,
               nationality              = l_copy_rec.nationality,
               sex                      = l_copy_rec.sex,
               title                    = l_copy_rec.title,
               blood_type               = l_copy_rec.blood_type,
               correspondence_language  = l_copy_rec.correspondence_language,
               honors                   = l_copy_rec.honors,
               pre_name_adjunct         = l_copy_rec.pre_name_adjunct,
               rehire_authorizor        = l_copy_rec.rehire_authorizor,
               rehire_recommendation    = l_copy_rec.rehire_recommendation,
               resume_exists            = l_copy_rec.resume_exists,
               resume_last_updated      = l_copy_rec.resume_last_updated,
               second_passport_exists   = l_copy_rec.second_passport_exists,
               student_status           = l_copy_rec.student_status,
               suffix                   = l_copy_rec.suffix,
               date_of_death            = l_copy_rec.date_of_death,
               uses_tobacco_flag        = l_copy_rec.uses_tobacco_flag,
               town_of_birth            = l_copy_rec.town_of_birth,
               region_of_birth          = l_copy_rec.region_of_birth,
               country_of_birth         = l_copy_rec.country_of_birth,
               fast_path_employee       = l_copy_rec.fast_path_employee,
               email_address            = l_copy_rec.email_address,
               fte_capacity             = l_copy_rec.fte_capacity,
                    previous_last_name       = l_copy_rec.previous_last_name, -- bug fix 3598173.
               order_name               = l_order_name,
               global_name              = l_global_name,
               local_name               = l_local_name
          where  person_id = l_ref_person_id
          and    l_ref_effective_start_date
                 between effective_start_date
                 and     effective_end_date;
          --
        elsif l_datetrack_mode = 'UPDATE' then
          --
          hr_utility.set_location('Updating Record in update mode',10);
          --
          l_ref_effective_start_date := l_person(l_count).effective_start_date;
          l_ref_person_id := l_person(l_count).person_id;
          --
          update per_all_people_f
          set    effective_end_date = p_rec.effective_start_date-1
          where  person_id = l_ref_person_id
          and    l_ref_effective_start_date
                 between effective_start_date
                 and     effective_end_date;
          --
          hr_utility.set_location('Getting max OVN in update mode',10);
          --
          l_person(l_count).object_version_number :=
            dt_api.get_object_version_number
              (p_base_table_name      => 'per_all_people_f',
               p_base_key_column      => 'person_id',
               p_base_key_value       => l_person(l_count).person_id);
          --
          hr_utility.set_location('inserting new record in update mode',10);
          --
          l_copy_rec.date_of_birth :=
            propagate_value
            (l_person(l_count).date_of_birth,
             p_rec. date_of_birth,
             p_overwrite_data);
          l_copy_rec.first_name :=
            propagate_value
            (l_person(l_count).first_name,
             p_rec.first_name,
             p_overwrite_data);
          l_copy_rec.known_as :=
            propagate_value
            (l_person(l_count).known_as,
             p_rec.known_as,
             p_overwrite_data);
          l_copy_rec.marital_status :=
            propagate_value
            (l_person(l_count).marital_status,
             p_rec.marital_status,
             p_overwrite_data);
          l_copy_rec.middle_names :=
            propagate_value
            (l_person(l_count).middle_names,
             p_rec.middle_names,
             p_overwrite_data);
          l_copy_rec.nationality :=
            propagate_value
            (l_person(l_count).nationality,
             p_rec.nationality,
             p_overwrite_data);
          l_copy_rec.sex :=
            propagate_value
            (l_person(l_count).sex,
             p_rec.sex,
             p_overwrite_data);
          l_copy_rec.title :=
            propagate_value
            (l_person(l_count).title,
             p_rec.title,
             p_overwrite_data);
          l_copy_rec.blood_type :=
            propagate_value
            (l_person(l_count).blood_type,
             p_rec.blood_type,
             p_overwrite_data);
          l_copy_rec.correspondence_language :=
            propagate_value
            (l_person(l_count).correspondence_language,
             p_rec.correspondence_language,
             p_overwrite_data);
          l_copy_rec.honors :=
            propagate_value
            (l_person(l_count).honors,
             p_rec.honors,
             p_overwrite_data);
          l_copy_rec.pre_name_adjunct :=
            propagate_value
            (l_person(l_count).pre_name_adjunct,
             p_rec.pre_name_adjunct,
             p_overwrite_data);
          l_copy_rec.rehire_authorizor :=
            propagate_value
            (l_person(l_count).rehire_authorizor,
             p_rec.rehire_authorizor,
             p_overwrite_data);
          l_copy_rec.rehire_recommendation :=
            propagate_value
            (l_person(l_count).rehire_recommendation,
             p_rec.rehire_recommendation,
             p_overwrite_data);
          l_copy_rec.resume_exists :=
            propagate_value
            (l_person(l_count).resume_exists,
             p_rec.resume_exists,
             p_overwrite_data);
          l_copy_rec.resume_last_updated :=
            propagate_value
            (l_person(l_count).resume_last_updated,
             p_rec.resume_last_updated,
             p_overwrite_data);
          l_copy_rec.second_passport_exists :=
            propagate_value
            (l_person(l_count).second_passport_exists,
             p_rec.second_passport_exists,
             p_overwrite_data);
          l_copy_rec.student_status :=
            propagate_value
            (l_person(l_count).student_status,
             p_rec.student_status,
             p_overwrite_data);
          l_copy_rec.suffix :=
            propagate_value
            (l_person(l_count).suffix,
             p_rec.suffix,
             p_overwrite_data);
          l_copy_rec.date_of_death :=
            propagate_value
            (l_person(l_count).date_of_death,
             p_rec.date_of_death,
             p_overwrite_data);
          l_copy_rec.uses_tobacco_flag :=
            propagate_value
            (l_person(l_count).uses_tobacco_flag,
             p_rec.uses_tobacco_flag,
             p_overwrite_data);
          l_copy_rec.town_of_birth :=
            propagate_value
            (l_person(l_count).town_of_birth,
             p_rec.town_of_birth,
             p_overwrite_data);
          l_copy_rec.region_of_birth :=
            propagate_value
            (l_person(l_count).region_of_birth,
             p_rec.region_of_birth,
             p_overwrite_data);
          l_copy_rec.country_of_birth :=
            propagate_value
            (l_person(l_count).country_of_birth,
             p_rec.country_of_birth,
             p_overwrite_data);
          l_copy_rec.fast_path_employee :=
            propagate_value
            (l_person(l_count).fast_path_employee,
             p_rec.fast_path_employee,
             p_overwrite_data);
          l_copy_rec.email_address := propagate_value
            (l_person(l_count).email_address,
             p_rec.email_address,
             p_overwrite_data);
          l_copy_rec.fte_capacity := propagate_value
            (l_person(l_count).fte_capacity,
             p_rec.fte_capacity,
             p_overwrite_data);
          --
          -- Bug fix 3598173 starts here
          l_copy_rec.previous_last_name :=
            propagate_value
            (l_person(l_count).previous_last_name,
             p_rec.previous_last_name,
             p_overwrite_data);
          -- Bug fix 3598173 ends here.

          open csr_get_person_details(l_person(l_count).person_id, p_rec.effective_start_date-1);
          fetch csr_get_person_details into l_person_rec;
          if csr_get_person_details%FOUND then
             close csr_get_person_details;

            --hr_person.derive_full_name
            --(p_first_name        => l_copy_rec.first_name,
            -- p_middle_names      => l_copy_rec.middle_names,
            -- p_last_name         => p_rec.last_name,
            -- p_known_as          => l_copy_rec.known_as,
            -- p_title             => l_copy_rec.title,
            -- p_suffix            => l_copy_rec.suffix,
            -- p_pre_name_adjunct  => l_copy_rec.pre_name_adjunct,
            -- p_date_of_birth     => l_copy_rec.date_of_birth,
            -- p_person_id         => l_person(l_count).person_id,
            -- p_business_group_id => l_person(l_count).business_group_id,
            -- p_full_name         => l_full_name,
            -- p_duplicate_flag    => l_duplicate_flag);
          --
          hr_person_name.derive_person_names -- #3889584
            (p_format_name        =>  NULL, -- derive all person names
             p_business_group_id  =>  l_person(l_count).business_group_id,
             p_person_id          =>  l_person(l_count).person_id,
             p_first_name         =>  l_copy_rec.first_name,
             p_middle_names       =>  l_copy_rec.middle_names,
             p_last_name          =>  p_rec.last_name,
             p_known_as           =>  l_copy_rec.known_as,
             p_title              =>  l_copy_rec.title,
             p_suffix             =>  l_copy_rec.suffix,
             p_pre_name_adjunct   =>  l_copy_rec.pre_name_adjunct,
             p_date_of_birth      =>  l_copy_rec.date_of_birth,
             p_previous_last_name =>  l_copy_rec.previous_last_name ,
             p_email_address     =>   l_copy_rec.email_address,
             p_employee_number    =>  l_person_rec.employee_number  ,
             p_applicant_number   =>  l_person_rec.applicant_number  ,
             p_npw_number         =>  l_person_rec.npw_number,
             p_per_information1   =>  l_person_rec.per_information1  ,
             p_per_information2   =>  l_person_rec.per_information2  ,
             p_per_information3   =>  l_person_rec.per_information3  ,
             p_per_information4   =>  l_person_rec.per_information4  ,
             p_per_information5   =>  l_person_rec.per_information5  ,
             p_per_information6   =>  l_person_rec.per_information6  ,
             p_per_information7   =>  l_person_rec.per_information7  ,
             p_per_information8   =>  l_person_rec.per_information8  ,
             p_per_information9   =>  l_person_rec.per_information9  ,
             p_per_information10  =>  l_person_rec.per_information10  ,
             p_per_information11  =>  l_person_rec.per_information11  ,
             p_per_information12  =>  l_person_rec.per_information12  ,
             p_per_information13  =>  l_person_rec.per_information13  ,
             p_per_information14  =>  l_person_rec.per_information14  ,
             p_per_information15  =>  l_person_rec.per_information15  ,
             p_per_information16  =>  l_person_rec.per_information16  ,
             p_per_information17  =>  l_person_rec.per_information17  ,
             p_per_information18  =>  l_person_rec.per_information18  ,
             p_per_information19  =>  l_person_rec.per_information19  ,
             p_per_information20  =>  l_person_rec.per_information20  ,
             p_per_information21  =>  l_person_rec.per_information21  ,
             p_per_information22  =>  l_person_rec.per_information22  ,
             p_per_information23  =>  l_person_rec.per_information23  ,
             p_per_information24  =>  l_person_rec.per_information24  ,
             p_per_information25  =>  l_person_rec.per_information25  ,
             p_per_information26  =>  l_person_rec.per_information26  ,
             p_per_information27  =>  l_person_rec.per_information27  ,
             p_per_information28  =>  l_person_rec.per_information28  ,
             p_per_information29  =>  l_person_rec.per_information29  ,
             p_per_information30  =>  l_person_rec.per_information30  ,
             p_attribute1         =>  l_person_rec.attribute1  ,
             p_attribute2         =>  l_person_rec.attribute2  ,
             p_attribute3         =>  l_person_rec.attribute3  ,
             p_attribute4         =>  l_person_rec.attribute4  ,
             p_attribute5         =>  l_person_rec.attribute5  ,
             p_attribute6         =>  l_person_rec.attribute6  ,
             p_attribute7         =>  l_person_rec.attribute7  ,
             p_attribute8         =>  l_person_rec.attribute8  ,
             p_attribute9         =>  l_person_rec.attribute9  ,
             p_attribute10        =>  l_person_rec.attribute10  ,
             p_attribute11        =>  l_person_rec.attribute11  ,
             p_attribute12        =>  l_person_rec.attribute12  ,
             p_attribute13        =>  l_person_rec.attribute13  ,
             p_attribute14        =>  l_person_rec.attribute14  ,
             p_attribute15        =>  l_person_rec.attribute15  ,
             p_attribute16        =>  l_person_rec.attribute16  ,
             p_attribute17        =>  l_person_rec.attribute17  ,
             p_attribute18        =>  l_person_rec.attribute18  ,
             p_attribute19        =>  l_person_rec.attribute19  ,
             p_attribute20        =>  l_person_rec.attribute20  ,
             p_attribute21        =>  l_person_rec.attribute21  ,
             p_attribute22        =>  l_person_rec.attribute22  ,
             p_attribute23        =>  l_person_rec.attribute23,
             p_attribute24        =>  l_person_rec.attribute24,
             p_attribute25        =>  l_person_rec.attribute25,
             p_attribute26        =>  l_person_rec.attribute26,
             p_attribute27        =>  l_person_rec.attribute27,
             p_attribute28        =>  l_person_rec.attribute28,
             p_attribute29        =>  l_person_rec.attribute29,
             p_attribute30        =>  l_person_rec.attribute30,
             p_full_name          =>  l_full_name,
             p_order_name         =>  l_order_name,
             p_global_name        =>  l_global_name,
             p_local_name         =>  l_local_name,
             p_duplicate_flag     =>  l_duplicate_flag);

          hr_utility.set_location('Before insert for update event',10);
          hr_utility.set_location('Person ID '||l_person(l_count).person_id,10);
          hr_utility.set_location('OVN '||l_person(l_count).object_version_number,10);
          --
          insert into per_all_people_f
          (person_id,
           effective_start_date,
           effective_end_date,
           business_group_id,
           person_type_id,
           last_name,
           full_name,
           start_date,
           applicant_number,
           comment_id,
           current_applicant_flag,
           current_emp_or_apl_flag,
           current_employee_flag,
           date_employee_data_verified,
           date_of_birth,
           email_address,
           employee_number,
           expense_check_send_to_address,
           first_name,
           known_as,
           marital_status,
           middle_names,
           nationality,
           national_identifier,
           previous_last_name,
           registered_disabled_flag,
           sex,
           title,
           vendor_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           attribute16,
           attribute17,
           attribute18,
           attribute19,
           attribute20,
           attribute21,
           attribute22,
           attribute23,
           attribute24,
           attribute25,
           attribute26,
           attribute27,
           attribute28,
           attribute29,
           attribute30,
           per_information_category,
           per_information1,
           per_information2,
           per_information3,
           per_information4,
           per_information5,
           per_information6,
           per_information7,
           per_information8,
           per_information9,
           per_information10,
           per_information11,
           per_information12,
           per_information13,
           per_information14,
           per_information15,
           per_information16,
           per_information17,
           per_information18,
           per_information19,
           per_information20,
           object_version_number,
           suffix,
           DATE_OF_DEATH,
           BACKGROUND_CHECK_STATUS         ,
           BACKGROUND_DATE_CHECK           ,
           BLOOD_TYPE                      ,
           CORRESPONDENCE_LANGUAGE         ,
           FAST_PATH_EMPLOYEE              ,
           FTE_CAPACITY                    ,
           HOLD_APPLICANT_DATE_UNTIL       ,
           HONORS                          ,
           INTERNAL_LOCATION               ,
           LAST_MEDICAL_TEST_BY            ,
           LAST_MEDICAL_TEST_DATE          ,
           MAILSTOP                        ,
           OFFICE_NUMBER                   ,
           ON_MILITARY_SERVICE             ,
           ORDER_NAME                      ,
           PRE_NAME_ADJUNCT                ,
           PROJECTED_START_DATE            ,
           REHIRE_AUTHORIZOR               ,
           REHIRE_RECOMMENDATION           ,
           RESUME_EXISTS                   ,
           RESUME_LAST_UPDATED             ,
           SECOND_PASSPORT_EXISTS          ,
           STUDENT_STATUS                  ,
           WORK_SCHEDULE                   ,
           PER_INFORMATION21               ,
           PER_INFORMATION22               ,
           PER_INFORMATION23               ,
           PER_INFORMATION24               ,
           PER_INFORMATION25               ,
           PER_INFORMATION26               ,
           PER_INFORMATION27               ,
           PER_INFORMATION28               ,
           PER_INFORMATION29                  ,
           PER_INFORMATION30               ,
           REHIRE_REASON                   ,
           benefit_group_id                ,
           receipt_of_death_cert_date      ,
           coord_ben_med_pln_no            ,
           coord_ben_no_cvg_flag           ,
           COORD_BEN_MED_EXT_ER,
           COORD_BEN_MED_PL_NAME,
           COORD_BEN_MED_INSR_CRR_NAME,
           COORD_BEN_MED_INSR_CRR_IDENT,
           COORD_BEN_MED_CVG_STRT_DT,
           COORD_BEN_MED_CVG_END_DT,
           uses_tobacco_flag               ,
           dpdnt_adoption_date             ,
           dpdnt_vlntry_svce_flag          ,
           original_date_of_hire           ,
           town_of_birth                ,
           region_of_birth              ,
           country_of_birth             ,
           global_person_id             ,
           party_id             ,
           created_by,
           creation_date,
           last_update_date,
           last_updated_by,
           last_update_login,
           global_name,
           local_name,
           npw_number, -- 5123559
           current_npw_flag) -- 5123559)
         -- ----------------------- +
          VALUES
         -- ----------------------- +
           (l_person(l_count).person_id,
           p_rec.effective_start_date,
           hr_api.g_eot,
           l_person_rec.business_group_id,
           l_person_rec.person_type_id,
           p_rec.last_name,
           l_full_name,
           l_person_rec.start_date,
           l_person_rec.applicant_number,
           l_person_rec.comment_id,
           l_person_rec.current_applicant_flag,
           l_person_rec.current_emp_or_apl_flag,
           l_person_rec.current_employee_flag,
           l_person_rec.date_employee_data_verified,
           l_copy_rec.date_of_birth,
           l_copy_rec.email_address,
           l_person_rec.employee_number,
           l_person_rec.expense_check_send_to_address,
           l_copy_rec.first_name,
           l_copy_rec.known_as,
           l_copy_rec.marital_status,
           l_copy_rec.middle_names,
           l_copy_rec.nationality,
           l_person_rec.national_identifier,
           l_copy_rec.previous_last_name, -- Bug fix 3598173.
           l_person_rec.registered_disabled_flag,
           l_copy_rec.sex,
           l_copy_rec.title,
           l_person_rec.vendor_id,
           l_person_rec.request_id,
           l_person_rec.program_application_id,
           l_person_rec.program_id,
           l_person_rec.program_update_date,
           l_person_rec.attribute_category,
           l_person_rec.attribute1,
           l_person_rec.attribute2,
           l_person_rec.attribute3,
           l_person_rec.attribute4,
           l_person_rec.attribute5,
           l_person_rec.attribute6,
           l_person_rec.attribute7,
           l_person_rec.attribute8,
           l_person_rec.attribute9,
           l_person_rec.attribute10,
           l_person_rec.attribute11,
           l_person_rec.attribute12,
           l_person_rec.attribute13,
           l_person_rec.attribute14,
           l_person_rec.attribute15,
           l_person_rec.attribute16,
           l_person_rec.attribute17,
           l_person_rec.attribute18,
           l_person_rec.attribute19,
           l_person_rec.attribute20,
           l_person_rec.attribute21,
           l_person_rec.attribute22,
           l_person_rec.attribute23,
           l_person_rec.attribute24,
           l_person_rec.attribute25,
           l_person_rec.attribute26,
           l_person_rec.attribute27,
           l_person_rec.attribute28,
           l_person_rec.attribute29,
           l_person_rec.attribute30,
           l_person_rec.per_information_category,
           l_person_rec.per_information1,
           l_person_rec.per_information2,
           l_person_rec.per_information3,
           l_person_rec.per_information4,
           l_person_rec.per_information5,
           l_person_rec.per_information6,
           l_person_rec.per_information7,
           l_person_rec.per_information8,
           l_person_rec.per_information9,
           l_person_rec.per_information10,
           l_person_rec.per_information11,
           l_person_rec.per_information12,
           l_person_rec.per_information13,
           l_person_rec.per_information14,
           l_person_rec.per_information15,
           l_person_rec.per_information16,
           l_person_rec.per_information17,
           l_person_rec.per_information18,
           l_person_rec.per_information19,
           l_person_rec.per_information20,
           l_person(l_count).object_version_number,
           l_copy_rec.suffix,
           l_copy_rec.DATE_OF_DEATH,
           l_person_rec.BACKGROUND_CHECK_STATUS           ,
           l_person_rec.BACKGROUND_DATE_CHECK             ,
           l_copy_rec.BLOOD_TYPE,
           l_copy_rec.CORRESPONDENCE_LANGUAGE,
           l_copy_rec.FAST_PATH_EMPLOYEE,
           l_copy_rec.FTE_CAPACITY,
           l_person_rec.HOLD_APPLICANT_DATE_UNTIL         ,
           l_copy_rec.HONORS,
           l_person_rec.INTERNAL_LOCATION                 ,
           l_person_rec.LAST_MEDICAL_TEST_BY              ,
           l_person_rec.LAST_MEDICAL_TEST_DATE            ,
           l_person_rec.MAILSTOP                          ,
           l_person_rec.OFFICE_NUMBER                     ,
           l_person_rec.ON_MILITARY_SERVICE               ,
           l_ORDER_NAME                        ,
           l_copy_rec.PRE_NAME_ADJUNCT,
           l_person_rec.PROJECTED_START_DATE              ,
           l_copy_rec.REHIRE_AUTHORIZOR,
           l_copy_rec.REHIRE_RECOMMENDATION,
           l_copy_rec.RESUME_EXISTS,
           l_copy_rec.RESUME_LAST_UPDATED,
           l_copy_rec.SECOND_PASSPORT_EXISTS,
           l_copy_rec.STUDENT_STATUS,
           l_person_rec.WORK_SCHEDULE                     ,
           l_person_rec.per_iNFORMATION21                 ,
           l_person_rec.per_iNFORMATION22                 ,
           l_person_rec.per_iNFORMATION23                 ,
           l_person_rec.per_iNFORMATION24                 ,
           l_person_rec.per_iNFORMATION25                 ,
           l_person_rec.per_iNFORMATION26                 ,
           l_person_rec.per_iNFORMATION27                 ,
           l_person_rec.per_iNFORMATION28                 ,
           l_person_rec.per_iNFORMATION29                 ,
           l_person_rec.per_iNFORMATION30                 ,
           l_person_rec.REHIRE_REASON                     ,
           l_person_rec.BENEFIT_GROUP_ID                  ,
           l_person_rec.RECEIPT_OF_DEATH_CERT_DATE        ,
           l_person_rec.COORD_BEN_MED_PLN_NO              ,
           l_person_rec.COORD_BEN_NO_CVG_FLAG             ,
           l_person_rec.COORD_BEN_MED_EXT_ER,
           l_person_rec.COORD_BEN_MED_PL_NAME,
           l_person_rec.COORD_BEN_MED_INSR_CRR_NAME,
           l_person_rec.COORD_BEN_MED_INSR_CRR_IDENT,
           l_person_rec.COORD_BEN_MED_CVG_STRT_DT,
           l_person_rec.COORD_BEN_MED_CVG_END_DT ,
           l_copy_rec.USES_TOBACCO_FLAG,
           l_person_rec.DPDNT_ADOPTION_DATE               ,
           l_person_rec.DPDNT_VLNTRY_SVCE_FLAG            ,
           l_person_rec.ORIGINAL_DATE_OF_HIRE             ,
           l_copy_rec.town_of_birth,
           l_copy_rec.region_of_birth,
           l_copy_rec.country_of_birth,
           l_person_rec.global_person_id                        ,
           l_person_rec.party_id                        ,
           l_person_rec.created_by,
           l_person_rec.creation_date,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           l_global_name,
           l_local_name,
           l_person_rec.npw_number, -- 5123559
           l_person_rec.current_npw_flag); -- 5123559
          else
             close csr_get_person_details;
          end if;
          --
        elsif l_datetrack_mode = 'UPDATE_CHANGE_INSERT' then
          --
          hr_utility.set_location('updating record in update change insert mode',10);
          --
          update per_all_people_f
          set    effective_end_date = p_rec.effective_start_date-1
          where  person_id = l_person(l_count).person_id
          and    p_rec.effective_start_date
                 between effective_start_date
                 and     effective_end_date;
          --
          hr_utility.set_location('getting max ovn in update change insert mode',10);
          --
          l_person(l_count).object_version_number :=
            dt_api.get_object_version_number
              (p_base_table_name      => 'per_all_people_f',
               p_base_key_column      => 'person_id',
               p_base_key_value       => l_person(l_count).person_id);
          --
          hr_utility.set_location('inserting record in update change insert mode',10);
          --
          l_copy_rec.date_of_birth :=
            propagate_value
            (l_person(l_count).date_of_birth,
             p_rec. date_of_birth,
             p_overwrite_data);
          l_copy_rec.first_name :=
            propagate_value
            (l_person(l_count).first_name,
             p_rec.first_name,
             p_overwrite_data);
          l_copy_rec.known_as :=
            propagate_value
            (l_person(l_count).known_as,
             p_rec.known_as,
             p_overwrite_data);
          l_copy_rec.marital_status :=
            propagate_value
            (l_person(l_count).marital_status,
             p_rec.marital_status,
             p_overwrite_data);
          l_copy_rec.middle_names :=
            propagate_value
            (l_person(l_count).middle_names,
             p_rec.middle_names,
             p_overwrite_data);
          l_copy_rec.nationality :=
            propagate_value
            (l_person(l_count).nationality,
             p_rec.nationality,
             p_overwrite_data);
          l_copy_rec.sex :=
            propagate_value
            (l_person(l_count).sex,
             p_rec.sex,
             p_overwrite_data);
          l_copy_rec.title :=
            propagate_value
            (l_person(l_count).title,
             p_rec.title,
             p_overwrite_data);
          l_copy_rec.blood_type :=
            propagate_value
            (l_person(l_count).blood_type,
             p_rec.blood_type,
             p_overwrite_data);
          l_copy_rec.correspondence_language :=
            propagate_value
            (l_person(l_count).correspondence_language,
             p_rec.correspondence_language,
             p_overwrite_data);
          l_copy_rec.honors :=
            propagate_value
            (l_person(l_count).honors,
             p_rec.honors,
             p_overwrite_data);
          l_copy_rec.pre_name_adjunct :=
            propagate_value
            (l_person(l_count).pre_name_adjunct,
             p_rec.pre_name_adjunct,
             p_overwrite_data);
          l_copy_rec.rehire_authorizor :=
            propagate_value
            (l_person(l_count).rehire_authorizor,
             p_rec.rehire_authorizor,
             p_overwrite_data);
          l_copy_rec.rehire_recommendation :=
            propagate_value
            (l_person(l_count).rehire_recommendation,
             p_rec.rehire_recommendation,
             p_overwrite_data);
          l_copy_rec.resume_exists :=
            propagate_value
            (l_person(l_count).resume_exists,
             p_rec.resume_exists,
             p_overwrite_data);
          l_copy_rec.resume_last_updated :=
            propagate_value
            (l_person(l_count).resume_last_updated,
             p_rec.resume_last_updated,
             p_overwrite_data);
          l_copy_rec.second_passport_exists :=
            propagate_value
            (l_person(l_count).second_passport_exists,
             p_rec.second_passport_exists,
             p_overwrite_data);
          l_copy_rec.student_status :=
            propagate_value
            (l_person(l_count).student_status,
             p_rec.student_status,
             p_overwrite_data);
          l_copy_rec.suffix :=
            propagate_value
            (l_person(l_count).suffix,
             p_rec.suffix,
             p_overwrite_data);
          l_copy_rec.date_of_death :=
            propagate_value
            (l_person(l_count).date_of_death,
             p_rec.date_of_death,
             p_overwrite_data);
          l_copy_rec.uses_tobacco_flag :=
            propagate_value
            (l_person(l_count).uses_tobacco_flag,
             p_rec.uses_tobacco_flag,
             p_overwrite_data);
          l_copy_rec.town_of_birth :=
            propagate_value
            (l_person(l_count).town_of_birth,
             p_rec.town_of_birth,
             p_overwrite_data);
          l_copy_rec.region_of_birth :=
            propagate_value
            (l_person(l_count).region_of_birth,
             p_rec.region_of_birth,
             p_overwrite_data);
          l_copy_rec.country_of_birth :=
            propagate_value
            (l_person(l_count).country_of_birth,
             p_rec.country_of_birth,
             p_overwrite_data);
          l_copy_rec.fast_path_employee :=
            propagate_value
            (l_person(l_count).fast_path_employee,
             p_rec.fast_path_employee,
             p_overwrite_data);
          l_copy_rec.email_address := propagate_value
            (l_person(l_count).email_address,
             p_rec.email_address,
             p_overwrite_data);
          l_copy_rec.fte_capacity := propagate_value
            (l_person(l_count).fte_capacity,
             p_rec.fte_capacity,
             p_overwrite_data);
          -- Bug fix 3598173 starts here
          l_copy_rec.previous_last_name :=
            propagate_value
            (l_person(l_count).previous_last_name,
             p_rec.previous_last_name,
             p_overwrite_data);
          -- Bug fix 3598173 ends here.
          --
          open csr_get_person_details(l_person(l_count).person_id, p_rec.effective_start_date-1);
          fetch csr_get_person_details into l_person_rec;
          if csr_get_person_details%FOUND then
             close csr_get_person_details;

            --hr_person.derive_full_name
            --(p_first_name        => l_copy_rec.first_name,
            -- p_middle_names      => l_copy_rec.middle_names,
            -- p_last_name         => p_rec.last_name,
            -- p_known_as          => l_copy_rec.known_as,
            -- p_title             => l_copy_rec.title,
            -- p_suffix            => l_copy_rec.suffix,
            -- p_pre_name_adjunct  => l_copy_rec.pre_name_adjunct,
            -- p_date_of_birth     => l_copy_rec.date_of_birth,
            -- p_person_id         => l_person(l_count).person_id,
            -- p_business_group_id => l_person(l_count).business_group_id,
            -- p_full_name         => l_full_name,
            -- p_duplicate_flag    => l_duplicate_flag);
          --
          hr_person_name.derive_person_names -- #3889584
            (p_format_name        =>  NULL, -- derive all person names
             p_business_group_id  =>  l_person(l_count).business_group_id,
             p_person_id          => l_person(l_count).person_id,
             p_first_name         =>  l_copy_rec.first_name,
             p_middle_names       =>  l_copy_rec.middle_names,
             p_last_name          =>  p_rec.last_name,
             p_known_as           =>  l_copy_rec.known_as,
             p_title              =>  l_copy_rec.title,
             p_suffix             =>  l_copy_rec.suffix,
             p_pre_name_adjunct   =>  l_copy_rec.pre_name_adjunct,
             p_date_of_birth      =>  l_copy_rec.date_of_birth,
             p_previous_last_name =>  l_copy_rec.previous_last_name ,
             p_email_address     =>   l_copy_rec.email_address,
             p_employee_number    =>  l_person_rec.employee_number  ,
             p_applicant_number   =>  l_person_rec.applicant_number  ,
             p_npw_number         =>  l_person_rec.npw_number,
             p_per_information1   =>  l_person_rec.per_information1  ,
             p_per_information2   =>  l_person_rec.per_information2  ,
             p_per_information3   =>  l_person_rec.per_information3  ,
             p_per_information4   =>  l_person_rec.per_information4  ,
             p_per_information5   =>  l_person_rec.per_information5  ,
             p_per_information6   =>  l_person_rec.per_information6  ,
             p_per_information7   =>  l_person_rec.per_information7  ,
             p_per_information8   =>  l_person_rec.per_information8  ,
             p_per_information9   =>  l_person_rec.per_information9  ,
             p_per_information10  =>  l_person_rec.per_information10  ,
             p_per_information11  =>  l_person_rec.per_information11  ,
             p_per_information12  =>  l_person_rec.per_information12  ,
             p_per_information13  =>  l_person_rec.per_information13  ,
             p_per_information14  =>  l_person_rec.per_information14  ,
             p_per_information15  =>  l_person_rec.per_information15  ,
             p_per_information16  =>  l_person_rec.per_information16  ,
             p_per_information17  =>  l_person_rec.per_information17  ,
             p_per_information18  =>  l_person_rec.per_information18  ,
             p_per_information19  =>  l_person_rec.per_information19  ,
             p_per_information20  =>  l_person_rec.per_information20  ,
             p_per_information21  =>  l_person_rec.per_information21  ,
             p_per_information22  =>  l_person_rec.per_information22  ,
             p_per_information23  =>  l_person_rec.per_information23  ,
             p_per_information24  =>  l_person_rec.per_information24  ,
             p_per_information25  =>  l_person_rec.per_information25  ,
             p_per_information26  =>  l_person_rec.per_information26  ,
             p_per_information27  =>  l_person_rec.per_information27  ,
             p_per_information28  =>  l_person_rec.per_information28  ,
             p_per_information29  =>  l_person_rec.per_information29  ,
             p_per_information30  =>  l_person_rec.per_information30  ,
             p_attribute1         =>  l_person_rec.attribute1  ,
             p_attribute2         =>  l_person_rec.attribute2  ,
             p_attribute3         =>  l_person_rec.attribute3  ,
             p_attribute4         =>  l_person_rec.attribute4  ,
             p_attribute5         =>  l_person_rec.attribute5  ,
             p_attribute6         =>  l_person_rec.attribute6  ,
             p_attribute7         =>  l_person_rec.attribute7  ,
             p_attribute8         =>  l_person_rec.attribute8  ,
             p_attribute9         =>  l_person_rec.attribute9  ,
             p_attribute10        =>  l_person_rec.attribute10  ,
             p_attribute11        =>  l_person_rec.attribute11  ,
             p_attribute12        =>  l_person_rec.attribute12  ,
             p_attribute13        =>  l_person_rec.attribute13  ,
             p_attribute14        =>  l_person_rec.attribute14  ,
             p_attribute15        =>  l_person_rec.attribute15  ,
             p_attribute16        =>  l_person_rec.attribute16  ,
             p_attribute17        =>  l_person_rec.attribute17  ,
             p_attribute18        =>  l_person_rec.attribute18  ,
             p_attribute19        =>  l_person_rec.attribute19  ,
             p_attribute20        =>  l_person_rec.attribute20  ,
             p_attribute21        =>  l_person_rec.attribute21  ,
             p_attribute22        =>  l_person_rec.attribute22  ,
             p_attribute23        =>  l_person_rec.attribute23,
             p_attribute24        =>  l_person_rec.attribute24,
             p_attribute25        =>  l_person_rec.attribute25,
             p_attribute26        =>  l_person_rec.attribute26,
             p_attribute27        =>  l_person_rec.attribute27,
             p_attribute28        =>  l_person_rec.attribute28,
             p_attribute29        =>  l_person_rec.attribute29,
             p_attribute30        =>  l_person_rec.attribute30,
             p_full_name          =>  l_full_name,
             p_order_name         =>  l_order_name,
             p_global_name        =>  l_global_name,
             p_local_name         =>  l_local_name,
             p_duplicate_flag     =>  l_duplicate_flag);


          insert into per_all_people_f
          (person_id,
           effective_start_date,
           effective_end_date,
           business_group_id,
           person_type_id,
           last_name,
           full_name,
           start_date,
           applicant_number,
           comment_id,
           current_applicant_flag,
           current_emp_or_apl_flag,
           current_employee_flag,
           date_employee_data_verified,
           date_of_birth,
           email_address,
           employee_number,
           expense_check_send_to_address,
           first_name,
           known_as,
           marital_status,
           middle_names,
           nationality,
           national_identifier,
           previous_last_name,
           registered_disabled_flag,
           sex,
           title,
           vendor_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           attribute16,
           attribute17,
           attribute18,
           attribute19,
           attribute20,
           attribute21,
           attribute22,
           attribute23,
           attribute24,
           attribute25,
           attribute26,
           attribute27,
           attribute28,
           attribute29,
           attribute30,
           per_information_category,
           per_information1,
           per_information2,
           per_information3,
           per_information4,
           per_information5,
           per_information6,
           per_information7,
           per_information8,
           per_information9,
           per_information10,
           per_information11,
           per_information12,
           per_information13,
           per_information14,
           per_information15,
           per_information16,
           per_information17,
           per_information18,
           per_information19,
           per_information20,
           object_version_number,
           suffix,
           DATE_OF_DEATH,
           BACKGROUND_CHECK_STATUS         ,
           BACKGROUND_DATE_CHECK           ,
           BLOOD_TYPE                      ,
           CORRESPONDENCE_LANGUAGE         ,
           FAST_PATH_EMPLOYEE              ,
           FTE_CAPACITY                    ,
           HOLD_APPLICANT_DATE_UNTIL       ,
           HONORS                          ,
           INTERNAL_LOCATION               ,
           LAST_MEDICAL_TEST_BY            ,
           LAST_MEDICAL_TEST_DATE          ,
           MAILSTOP                        ,
           OFFICE_NUMBER                   ,
           ON_MILITARY_SERVICE             ,
           ORDER_NAME                      ,
           PRE_NAME_ADJUNCT                ,
           PROJECTED_START_DATE            ,
           REHIRE_AUTHORIZOR               ,
           REHIRE_RECOMMENDATION           ,
           RESUME_EXISTS                   ,
           RESUME_LAST_UPDATED             ,
           SECOND_PASSPORT_EXISTS          ,
           STUDENT_STATUS                  ,
           WORK_SCHEDULE                   ,
           PER_INFORMATION21               ,
           PER_INFORMATION22               ,
           PER_INFORMATION23               ,
           PER_INFORMATION24               ,
           PER_INFORMATION25               ,
           PER_INFORMATION26               ,
           PER_INFORMATION27               ,
           PER_INFORMATION28               ,
           PER_INFORMATION29                  ,
           PER_INFORMATION30               ,
           REHIRE_REASON                   ,
           benefit_group_id                ,
           receipt_of_death_cert_date      ,
           coord_ben_med_pln_no            ,
           coord_ben_no_cvg_flag           ,
           COORD_BEN_MED_EXT_ER,
           COORD_BEN_MED_PL_NAME,
           COORD_BEN_MED_INSR_CRR_NAME,
           COORD_BEN_MED_INSR_CRR_IDENT,
           COORD_BEN_MED_CVG_STRT_DT,
           COORD_BEN_MED_CVG_END_DT,
           uses_tobacco_flag               ,
           dpdnt_adoption_date             ,
           dpdnt_vlntry_svce_flag          ,
           original_date_of_hire           ,
           town_of_birth                ,
           region_of_birth              ,
           country_of_birth             ,
           global_person_id             ,
           party_id             ,
           created_by,
           creation_date,
           last_update_date,
           last_updated_by,
           last_update_login,
           global_name,
           local_name)
          -- ------------------------ +
          VALUES
          -- ------------------------ +
           (l_person(l_count).person_id,
           p_rec.effective_start_date,
           l_person(l_count).effective_end_date,
           l_person_rec.business_group_id,
           l_person_rec.person_type_id,
           p_rec.last_name,
           l_full_name,
           l_person_rec.start_date,
           l_person_rec.applicant_number,
           l_person_rec.comment_id,
           l_person_rec.current_applicant_flag,
           l_person_rec.current_emp_or_apl_flag,
           l_person_rec.current_employee_flag,
           l_person_rec.date_employee_data_verified,
           l_copy_rec.date_of_birth,
           l_copy_rec.email_address,
           l_person_rec.employee_number,
           l_person_rec.expense_check_send_to_address,
           l_copy_rec.first_name,
           l_copy_rec.known_as,
           l_copy_rec.marital_status,
           l_copy_rec.middle_names,
           l_copy_rec.nationality,
           l_person_rec.national_identifier,
           l_copy_rec.previous_last_name, -- bug fix 3598173.
           l_person_rec.registered_disabled_flag,
           l_copy_rec.sex,
           l_copy_rec.title,
           l_person_rec.vendor_id,
           l_person_rec.request_id,
           l_person_rec.program_application_id,
           l_person_rec.program_id,
           l_person_rec.program_update_date,
           l_person_rec.attribute_category,
           l_person_rec.attribute1,
           l_person_rec.attribute2,
           l_person_rec.attribute3,
           l_person_rec.attribute4,
           l_person_rec.attribute5,
           l_person_rec.attribute6,
           l_person_rec.attribute7,
           l_person_rec.attribute8,
           l_person_rec.attribute9,
           l_person_rec.attribute10,
           l_person_rec.attribute11,
           l_person_rec.attribute12,
           l_person_rec.attribute13,
           l_person_rec.attribute14,
           l_person_rec.attribute15,
           l_person_rec.attribute16,
           l_person_rec.attribute17,
           l_person_rec.attribute18,
           l_person_rec.attribute19,
           l_person_rec.attribute20,
           l_person_rec.attribute21,
           l_person_rec.attribute22,
           l_person_rec.attribute23,
           l_person_rec.attribute24,
           l_person_rec.attribute25,
           l_person_rec.attribute26,
           l_person_rec.attribute27,
           l_person_rec.attribute28,
           l_person_rec.attribute29,
           l_person_rec.attribute30,
           l_person_rec.per_information_category,
           l_person_rec.per_information1,
           l_person_rec.per_information2,
           l_person_rec.per_information3,
           l_person_rec.per_information4,
           l_person_rec.per_information5,
           l_person_rec.per_information6,
           l_person_rec.per_information7,
           l_person_rec.per_information8,
           l_person_rec.per_information9,
           l_person_rec.per_information10,
           l_person_rec.per_information11,
           l_person_rec.per_information12,
           l_person_rec.per_information13,
           l_person_rec.per_information14,
           l_person_rec.per_information15,
           l_person_rec.per_information16,
           l_person_rec.per_information17,
           l_person_rec.per_information18,
           l_person_rec.per_information19,
           l_person_rec.per_information20,
           l_person(l_count).object_version_number,
           l_copy_rec.suffix,
           l_copy_rec.DATE_OF_DEATH,
           l_person_rec.BACKGROUND_CHECK_STATUS           ,
           l_person_rec.BACKGROUND_DATE_CHECK             ,
           l_copy_rec.BLOOD_TYPE,
           l_copy_rec.CORRESPONDENCE_LANGUAGE,
           l_copy_rec.FAST_PATH_EMPLOYEE,
           l_copy_rec.FTE_CAPACITY,
           l_person_rec.HOLD_APPLICANT_DATE_UNTIL         ,
           l_copy_rec.HONORS,
           l_person_rec.INTERNAL_LOCATION                 ,
           l_person_rec.LAST_MEDICAL_TEST_BY              ,
           l_person_rec.LAST_MEDICAL_TEST_DATE            ,
           l_person_rec.MAILSTOP                          ,
           l_person_rec.OFFICE_NUMBER                     ,
           l_person_rec.ON_MILITARY_SERVICE               ,
           l_ORDER_NAME                        ,
           l_copy_rec.PRE_NAME_ADJUNCT,
           l_person_rec.PROJECTED_START_DATE              ,
           l_copy_rec.REHIRE_AUTHORIZOR,
           l_copy_rec.REHIRE_RECOMMENDATION,
           l_copy_rec.RESUME_EXISTS,
           l_copy_rec.RESUME_LAST_UPDATED,
           l_copy_rec.SECOND_PASSPORT_EXISTS,
           l_copy_rec.STUDENT_STATUS,
           l_person_rec.WORK_SCHEDULE                     ,
           l_person_rec.per_iNFORMATION21                 ,
           l_person_rec.per_iNFORMATION22                 ,
           l_person_rec.per_iNFORMATION23                 ,
           l_person_rec.per_iNFORMATION24                 ,
           l_person_rec.per_iNFORMATION25                 ,
           l_person_rec.per_iNFORMATION26                 ,
           l_person_rec.per_iNFORMATION27                 ,
           l_person_rec.per_iNFORMATION28                 ,
           l_person_rec.per_iNFORMATION29                 ,
           l_person_rec.per_iNFORMATION30                 ,
           l_person_rec.REHIRE_REASON                     ,
           l_person_rec.BENEFIT_GROUP_ID                  ,
           l_person_rec.RECEIPT_OF_DEATH_CERT_DATE        ,
           l_person_rec.COORD_BEN_MED_PLN_NO              ,
           l_person_rec.COORD_BEN_NO_CVG_FLAG             ,
           l_person_rec.COORD_BEN_MED_EXT_ER,
           l_person_rec.COORD_BEN_MED_PL_NAME,
           l_person_rec.COORD_BEN_MED_INSR_CRR_NAME,
           l_person_rec.COORD_BEN_MED_INSR_CRR_IDENT,
           l_person_rec.COORD_BEN_MED_CVG_STRT_DT,
           l_person_rec.COORD_BEN_MED_CVG_END_DT ,
           l_copy_rec.USES_TOBACCO_FLAG,
           l_person_rec.DPDNT_ADOPTION_DATE               ,
           l_person_rec.DPDNT_VLNTRY_SVCE_FLAG            ,
           l_person_rec.ORIGINAL_DATE_OF_HIRE             ,
           l_copy_rec.town_of_birth,
           l_copy_rec.region_of_birth,
           l_copy_rec.country_of_birth,
           l_person_rec.global_person_id                        ,
           l_person_rec.party_id                        ,
           l_person_rec.created_by,
           l_person_rec.creation_date,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           l_global_name,
           l_local_name);
        else
           close csr_get_person_details;
        end if;
      end if;
/*
        hr_person_api.update_person
          (p_effective_date           => p_rec.effective_start_date,
           p_datetrack_update_mode    => l_datetrack_mode,
           p_person_id                => l_person(l_count).person_id,
           p_object_version_number    => l_person(l_count).object_version_number,
           p_employee_number          => l_person(l_count).employee_number,
           p_last_name                => p_rec.last_name,
           p_date_of_birth            => p_rec.date_of_birth,
           p_first_name               => p_rec.first_name,
           p_known_as                 => p_rec.known_as,
           p_marital_status           => p_rec.marital_status,
           p_middle_names             => p_rec.middle_names,
           p_nationality              => p_rec.nationality,
           p_sex                      => p_rec.sex,
           p_title                    => p_rec.title,
           p_blood_type               => p_rec.blood_type,
           p_correspondence_language  => p_rec.correspondence_language,
           p_honors                   => p_rec.honors,
           p_pre_name_adjunct         => p_rec.pre_name_adjunct,
           p_rehire_authorizor        => p_rec.rehire_authorizor,
           p_rehire_recommendation    => p_rec.rehire_recommendation,
           p_resume_exists            => p_rec.resume_exists,
           p_resume_last_updated      => p_rec.resume_last_updated,
           p_second_passport_exists   => p_rec.second_passport_exists,
           p_student_status           => p_rec.student_status,
           p_suffix                   => p_rec.suffix,
           p_date_of_death            => p_rec.date_of_death,
           p_uses_tobacco_flag        => p_rec.uses_tobacco_flag,
           p_town_of_birth            => p_rec.town_of_birth,
           p_region_of_birth          => p_rec.region_of_birth,
           p_country_of_birth         => p_rec.country_of_birth,
           p_fast_path_employee       => p_rec.fast_path_employee,
           p_email_address            => p_rec.email_address,
           p_fte_capacity             => p_rec.fte_capacity,
           p_effective_start_date     => l_effective_start_date,
           p_effective_end_date       => l_effective_end_date,
           p_full_name                => l_full_name,
           p_comment_id               => l_comment_id,
           p_name_combination_warning => l_name_combination_warning,
           p_assign_payroll_warning   => l_assign_payroll_warning,
           p_orig_hire_warning        => l_orig_hire_warning);
*/
        --
        if l_person(l_count).effective_start_date >= p_rec.effective_start_date and
          l_person(l_count).effective_end_date > p_rec.effective_end_date or
          l_person(l_count).effective_start_date < p_rec.effective_start_date and
          l_person(l_count).effective_end_date > p_rec.effective_end_date then
          --
          hr_utility.set_location('finding dt delete modes',10);
          --
          dt_api.find_dt_upd_modes
            (p_effective_date       => p_rec.effective_end_date,
             p_base_table_name      => 'PER_ALL_PEOPLE_F',
             p_base_key_column      => 'PERSON_ID',
             p_base_key_value       => l_person(l_count).person_id,
             p_correction           => l_correction,
             p_update               => l_update,
             p_update_override      => l_update_override,
             p_update_change_insert => l_update_change_insert);
          --
          -- Put old values back to what they were.
          --
          if l_update_change_insert then
            --
            l_datetrack_mode := 'UPDATE_CHANGE_INSERT';
            --
          elsif l_update then
            --
            l_datetrack_mode := 'UPDATE';
            --
          else
            --
            l_datetrack_mode := 'CORRECTION';
            --
          end if;
          --
          -- Now call the API with the appropriate calling mode.
          --
          if l_datetrack_mode = 'UPDATE' then
            --
            hr_utility.set_location('updating person in update mode',10);
            --
            update per_all_people_f
            set    effective_end_date = p_rec.effective_end_date
            where  person_id = l_person(l_count).person_id
            and    p_rec.effective_start_date
                   between effective_start_date
                   and     effective_end_date;
            --
            hr_utility.set_location('getting max ovn in update mode',10);
            --
            l_person(l_count).object_version_number :=
              dt_api.get_object_version_number
                (p_base_table_name      => 'per_all_people_f',
                 p_base_key_column      => 'person_id',
                 p_base_key_value       => l_person(l_count).person_id);
            --
            hr_utility.set_location('inserting record in update mode',10);
            --
            -- Now the insert
            --
            insert into per_all_people_f
            (person_id,
             effective_start_date,
             effective_end_date,
             business_group_id,
             person_type_id,
             last_name,
             start_date,
             applicant_number,
             comment_id,
             current_applicant_flag,
             current_emp_or_apl_flag,
             current_employee_flag,
             date_employee_data_verified,
             date_of_birth,
             email_address,
             employee_number,
             expense_check_send_to_address,
             first_name,
             full_name,
             known_as,
             marital_status,
             middle_names,
             nationality,
             national_identifier,
             previous_last_name,
             registered_disabled_flag,
             sex,
             title,
             vendor_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20,
             attribute21,
             attribute22,
             attribute23,
             attribute24,
             attribute25,
             attribute26,
             attribute27,
             attribute28,
             attribute29,
             attribute30,
             per_information_category,
             per_information1,
             per_information2,
             per_information3,
             per_information4,
             per_information5,
             per_information6,
             per_information7,
             per_information8,
             per_information9,
             per_information10,
             per_information11,
             per_information12,
             per_information13,
             per_information14,
             per_information15,
             per_information16,
             per_information17,
             per_information18,
             per_information19,
             per_information20,
             object_version_number,
             suffix,
             DATE_OF_DEATH,
             BACKGROUND_CHECK_STATUS         ,
             BACKGROUND_DATE_CHECK           ,
             BLOOD_TYPE                      ,
             CORRESPONDENCE_LANGUAGE         ,
             FAST_PATH_EMPLOYEE              ,
             FTE_CAPACITY                    ,
             HOLD_APPLICANT_DATE_UNTIL       ,
             HONORS                          ,
             INTERNAL_LOCATION               ,
             LAST_MEDICAL_TEST_BY            ,
             LAST_MEDICAL_TEST_DATE          ,
             MAILSTOP                        ,
             OFFICE_NUMBER                   ,
             ON_MILITARY_SERVICE             ,
             ORDER_NAME                      ,
             PRE_NAME_ADJUNCT                ,
             PROJECTED_START_DATE            ,
             REHIRE_AUTHORIZOR               ,
             REHIRE_RECOMMENDATION           ,
             RESUME_EXISTS                   ,
             RESUME_LAST_UPDATED             ,
             SECOND_PASSPORT_EXISTS          ,
             STUDENT_STATUS                  ,
             WORK_SCHEDULE                   ,
             PER_INFORMATION21               ,
             PER_INFORMATION22               ,
             PER_INFORMATION23               ,
             PER_INFORMATION24               ,
             PER_INFORMATION25               ,
             PER_INFORMATION26               ,
             PER_INFORMATION27               ,
             PER_INFORMATION28               ,
             PER_INFORMATION29                  ,
             PER_INFORMATION30               ,
             REHIRE_REASON                   ,
             benefit_group_id                ,
             receipt_of_death_cert_date      ,
             coord_ben_med_pln_no            ,
             coord_ben_no_cvg_flag           ,
             COORD_BEN_MED_EXT_ER,
             COORD_BEN_MED_PL_NAME,
             COORD_BEN_MED_INSR_CRR_NAME,
             COORD_BEN_MED_INSR_CRR_IDENT,
             COORD_BEN_MED_CVG_STRT_DT,
             COORD_BEN_MED_CVG_END_DT,
             uses_tobacco_flag               ,
             dpdnt_adoption_date             ,
             dpdnt_vlntry_svce_flag          ,
             original_date_of_hire           ,
             town_of_birth                ,
             region_of_birth              ,
             country_of_birth             ,
             global_person_id             ,
             party_id             ,
             created_by,
             creation_date,
             last_update_date,
             last_updated_by,
             last_update_login,
             global_name,
             local_name)
            select
             l_person(l_count).person_id,
             p_rec.effective_end_date+1,
             hr_api.g_eot,
             business_group_id,
             person_type_id,
             p_rec.last_name,
             start_date,
             applicant_number,
             comment_id,
             current_applicant_flag,
             current_emp_or_apl_flag,
             current_employee_flag,
             date_employee_data_verified,
             p_rec.date_of_birth,
             p_rec.email_address,
             employee_number,
             expense_check_send_to_address,
             p_rec.first_name,
             full_name,
             p_rec.known_as,
             p_rec.marital_status,
             p_rec.middle_names,
             p_rec.nationality,
             national_identifier,
             p_rec.previous_last_name, -- Bug fix 3598173.
             registered_disabled_flag,
             p_rec.sex,
             p_rec.title,
             vendor_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20,
             attribute21,
             attribute22,
             attribute23,
             attribute24,
             attribute25,
             attribute26,
             attribute27,
             attribute28,
             attribute29,
             attribute30,
             per_information_category,
             per_information1,
             per_information2,
             per_information3,
             per_information4,
             per_information5,
             per_information6,
             per_information7,
             per_information8,
             per_information9,
             per_information10,
             per_information11,
             per_information12,
             per_information13,
             per_information14,
             per_information15,
             per_information16,
             per_information17,
             per_information18,
             per_information19,
             per_information20,
             l_person(l_count).object_version_number,
             p_rec.suffix,
             p_rec.DATE_OF_DEATH                     ,
             BACKGROUND_CHECK_STATUS           ,
             BACKGROUND_DATE_CHECK             ,
             p_rec.BLOOD_TYPE                        ,
             p_rec.CORRESPONDENCE_LANGUAGE           ,
             p_rec.FAST_PATH_EMPLOYEE                ,
             p_rec.FTE_CAPACITY                      ,
             HOLD_APPLICANT_DATE_UNTIL         ,
             p_rec.HONORS                            ,
             INTERNAL_LOCATION                 ,
             LAST_MEDICAL_TEST_BY              ,
             LAST_MEDICAL_TEST_DATE            ,
             MAILSTOP                          ,
             OFFICE_NUMBER                     ,
             ON_MILITARY_SERVICE               ,
             ORDER_NAME                        ,
             p_rec.PRE_NAME_ADJUNCT                  ,
             PROJECTED_START_DATE              ,
             p_rec.REHIRE_AUTHORIZOR                 ,
             p_rec.REHIRE_RECOMMENDATION             ,
             p_rec.RESUME_EXISTS                     ,
             p_rec.RESUME_LAST_UPDATED               ,
             p_rec.SECOND_PASSPORT_EXISTS            ,
             p_rec.STUDENT_STATUS                    ,
             WORK_SCHEDULE                     ,
             PER_INFORMATION21                 ,
             PER_INFORMATION22                 ,
             PER_INFORMATION23                 ,
             PER_INFORMATION24                 ,
             PER_INFORMATION25                 ,
             PER_INFORMATION26                 ,
             PER_INFORMATION27                 ,
             PER_INFORMATION28                 ,
             PER_INFORMATION29                 ,
             PER_INFORMATION30                 ,
             REHIRE_REASON                     ,
             BENEFIT_GROUP_ID                  ,
             RECEIPT_OF_DEATH_CERT_DATE        ,
             COORD_BEN_MED_PLN_NO              ,
             COORD_BEN_NO_CVG_FLAG             ,
             COORD_BEN_MED_EXT_ER,
             COORD_BEN_MED_PL_NAME,
             COORD_BEN_MED_INSR_CRR_NAME,
             COORD_BEN_MED_INSR_CRR_IDENT,
             COORD_BEN_MED_CVG_STRT_DT,
             COORD_BEN_MED_CVG_END_DT ,
             p_rec.USES_TOBACCO_FLAG                 ,
             DPDNT_ADOPTION_DATE               ,
             DPDNT_VLNTRY_SVCE_FLAG            ,
             ORIGINAL_DATE_OF_HIRE             ,
             p_rec.town_of_birth                           ,
             p_rec.region_of_birth                         ,
             p_rec.country_of_birth                        ,
             global_person_id                        ,
             party_id                        ,
             created_by,
             creation_date,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             global_name,
             local_name
            from per_all_people_f
            where person_id = l_person(l_count).person_id
            and   p_rec.effective_start_date-1
                  between effective_start_date
                  and effective_end_date;
            --
          elsif l_datetrack_mode = 'UPDATE_CHANGE_INSERT' then
            --
            hr_utility.set_location('updating record in update change insert mode',10);
            --
            update per_all_people_f
            set    effective_end_date = p_rec.effective_end_date
            where  person_id = l_person(l_count).person_id
            and    p_rec.effective_start_date
                   between effective_start_date
                   and     effective_end_date;
            --
            hr_utility.set_location('getting max ovn in update change insert mode',10);
            --
            l_person(l_count).object_version_number :=
              dt_api.get_object_version_number
                (p_base_table_name      => 'per_all_people_f',
                 p_base_key_column      => 'person_id',
                 p_base_key_value       => l_person(l_count).person_id);
            --
            -- Now the insert
            --
            hr_utility.set_location('inserting record in update change insert mode',10);
            --
            insert into per_all_people_f
            (person_id,
             effective_start_date,
             effective_end_date,
             business_group_id,
             person_type_id,
             last_name,
             start_date,
             applicant_number,
             comment_id,
             current_applicant_flag,
             current_emp_or_apl_flag,
             current_employee_flag,
             date_employee_data_verified,
             date_of_birth,
             email_address,
             employee_number,
             expense_check_send_to_address,
             first_name,
             full_name,
             known_as,
             marital_status,
             middle_names,
             nationality,
             national_identifier,
             previous_last_name,
             registered_disabled_flag,
             sex,
             title,
             vendor_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20,
             attribute21,
             attribute22,
             attribute23,
             attribute24,
             attribute25,
             attribute26,
             attribute27,
             attribute28,
             attribute29,
             attribute30,
             per_information_category,
             per_information1,
             per_information2,
             per_information3,
             per_information4,
             per_information5,
             per_information6,
             per_information7,
             per_information8,
             per_information9,
             per_information10,
             per_information11,
             per_information12,
             per_information13,
             per_information14,
             per_information15,
             per_information16,
             per_information17,
             per_information18,
             per_information19,
             per_information20,
             object_version_number,
             suffix,
             DATE_OF_DEATH,
             BACKGROUND_CHECK_STATUS         ,
             BACKGROUND_DATE_CHECK           ,
             BLOOD_TYPE                      ,
             CORRESPONDENCE_LANGUAGE         ,
             FAST_PATH_EMPLOYEE              ,
             FTE_CAPACITY                    ,
             HOLD_APPLICANT_DATE_UNTIL       ,
             HONORS                          ,
             INTERNAL_LOCATION               ,
             LAST_MEDICAL_TEST_BY            ,
             LAST_MEDICAL_TEST_DATE          ,
             MAILSTOP                        ,
             OFFICE_NUMBER                   ,
             ON_MILITARY_SERVICE             ,
             ORDER_NAME                      ,
             PRE_NAME_ADJUNCT                ,
             PROJECTED_START_DATE            ,
             REHIRE_AUTHORIZOR               ,
             REHIRE_RECOMMENDATION           ,
             RESUME_EXISTS                   ,
             RESUME_LAST_UPDATED             ,
             SECOND_PASSPORT_EXISTS          ,
             STUDENT_STATUS                  ,
             WORK_SCHEDULE                   ,
             PER_INFORMATION21               ,
             PER_INFORMATION22               ,
             PER_INFORMATION23               ,
             PER_INFORMATION24               ,
             PER_INFORMATION25               ,
             PER_INFORMATION26               ,
             PER_INFORMATION27               ,
             PER_INFORMATION28               ,
             PER_INFORMATION29                  ,
             PER_INFORMATION30               ,
             REHIRE_REASON                   ,
             benefit_group_id                ,
             receipt_of_death_cert_date      ,
             coord_ben_med_pln_no            ,
             coord_ben_no_cvg_flag           ,
             COORD_BEN_MED_EXT_ER,
             COORD_BEN_MED_PL_NAME,
             COORD_BEN_MED_INSR_CRR_NAME,
             COORD_BEN_MED_INSR_CRR_IDENT,
             COORD_BEN_MED_CVG_STRT_DT,
             COORD_BEN_MED_CVG_END_DT,
             uses_tobacco_flag               ,
             dpdnt_adoption_date             ,
             dpdnt_vlntry_svce_flag          ,
             original_date_of_hire           ,
             town_of_birth                ,
             region_of_birth              ,
             country_of_birth             ,
             global_person_id             ,
             party_id             ,
             created_by,
             creation_date,
             last_update_date,
             last_updated_by,
             last_update_login,
             global_name,
             local_name)
            select
             l_person(l_count).person_id,
             p_rec.effective_end_date+1,
             l_person(l_count).effective_end_date,
             business_group_id,
             person_type_id,
             p_rec.last_name,
             start_date,
             applicant_number,
             comment_id,
             current_applicant_flag,
             current_emp_or_apl_flag,
             current_employee_flag,
             date_employee_data_verified,
             p_rec.date_of_birth,
             p_rec.email_address,
             employee_number,
             expense_check_send_to_address,
             p_rec.first_name,
             full_name,
             p_rec.known_as,
             p_rec.marital_status,
             p_rec.middle_names,
             p_rec.nationality,
             national_identifier,
             p_rec.previous_last_name, -- bug fix 3598173
             registered_disabled_flag,
             p_rec.sex,
             p_rec.title,
             vendor_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             attribute_category,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute16,
             attribute17,
             attribute18,
             attribute19,
             attribute20,
             attribute21,
             attribute22,
             attribute23,
             attribute24,
             attribute25,
             attribute26,
             attribute27,
             attribute28,
             attribute29,
             attribute30,
             per_information_category,
             per_information1,
             per_information2,
             per_information3,
             per_information4,
             per_information5,
             per_information6,
             per_information7,
             per_information8,
             per_information9,
             per_information10,
             per_information11,
             per_information12,
             per_information13,
             per_information14,
             per_information15,
             per_information16,
             per_information17,
             per_information18,
             per_information19,
             per_information20,
             l_person(l_count).object_version_number,
             p_rec.suffix,
             p_rec.DATE_OF_DEATH                     ,
             BACKGROUND_CHECK_STATUS           ,
             BACKGROUND_DATE_CHECK             ,
             p_rec.BLOOD_TYPE                        ,
             p_rec.CORRESPONDENCE_LANGUAGE           ,
             p_rec.FAST_PATH_EMPLOYEE                ,
             p_rec.FTE_CAPACITY                      ,
             HOLD_APPLICANT_DATE_UNTIL         ,
             p_rec.HONORS                            ,
             INTERNAL_LOCATION                 ,
             LAST_MEDICAL_TEST_BY              ,
             LAST_MEDICAL_TEST_DATE            ,
             MAILSTOP                          ,
             OFFICE_NUMBER                     ,
             ON_MILITARY_SERVICE               ,
             ORDER_NAME                        ,
             p_rec.PRE_NAME_ADJUNCT                  ,
             PROJECTED_START_DATE              ,
             p_rec.REHIRE_AUTHORIZOR                 ,
             p_rec.REHIRE_RECOMMENDATION             ,
             p_rec.RESUME_EXISTS                     ,
             p_rec.RESUME_LAST_UPDATED               ,
             p_rec.SECOND_PASSPORT_EXISTS            ,
             p_rec.STUDENT_STATUS                    ,
             WORK_SCHEDULE                     ,
             PER_INFORMATION21                 ,
             PER_INFORMATION22                 ,
             PER_INFORMATION23                 ,
             PER_INFORMATION24                 ,
             PER_INFORMATION25                 ,
             PER_INFORMATION26                 ,
             PER_INFORMATION27                 ,
             PER_INFORMATION28                 ,
             PER_INFORMATION29                 ,
             PER_INFORMATION30                 ,
             REHIRE_REASON                     ,
             BENEFIT_GROUP_ID                  ,
             RECEIPT_OF_DEATH_CERT_DATE        ,
             COORD_BEN_MED_PLN_NO              ,
             COORD_BEN_NO_CVG_FLAG             ,
             COORD_BEN_MED_EXT_ER,
             COORD_BEN_MED_PL_NAME,
             COORD_BEN_MED_INSR_CRR_NAME,
             COORD_BEN_MED_INSR_CRR_IDENT,
             COORD_BEN_MED_CVG_STRT_DT,
             COORD_BEN_MED_CVG_END_DT ,
             p_rec.USES_TOBACCO_FLAG                 ,
             DPDNT_ADOPTION_DATE               ,
             DPDNT_VLNTRY_SVCE_FLAG            ,
             ORIGINAL_DATE_OF_HIRE             ,
             p_rec.town_of_birth                           ,
             p_rec.region_of_birth                         ,
             p_rec.country_of_birth                        ,
             global_person_id                        ,
             party_id                        ,
             created_by,
             creation_date,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             global_name,
             local_name
            from per_all_people_f
            where person_id = l_person(l_count).person_id
            and   p_rec.effective_start_date-1
                  between effective_start_date
                  and effective_end_date;
          --
        end if;
/*
          hr_person_api.update_person
            (p_effective_date           => p_rec.effective_end_date,
             p_datetrack_update_mode    => l_datetrack_mode,
             p_person_id                => l_person(l_count).person_id,
             p_object_version_number    => l_person(l_count).object_version_number,
             p_employee_number          => l_person(l_count).employee_number,
             p_last_name                => l_person(l_count).last_name,
             p_date_of_birth            => l_person(l_count).date_of_birth,
             p_first_name               => l_person(l_count).first_name,
             p_known_as                 => l_person(l_count).known_as,
             p_marital_status           => l_person(l_count).marital_status,
             p_middle_names             => l_person(l_count).middle_names,
             p_nationality              => l_person(l_count).nationality,
             p_sex                      => l_person(l_count).sex,
             p_title                    => l_person(l_count).title,
             p_blood_type               => l_person(l_count).blood_type,
             p_correspondence_language  => l_person(l_count).correspondence_language,
             p_honors                   => l_person(l_count).honors,
             p_pre_name_adjunct         => l_person(l_count).pre_name_adjunct,
             p_rehire_authorizor        => l_person(l_count).rehire_authorizor,
             p_rehire_recommendation    => l_person(l_count).rehire_recommendation,
             p_resume_exists            => l_person(l_count).resume_exists,
             p_resume_last_updated      => l_person(l_count).resume_last_updated,
             p_second_passport_exists   => l_person(l_count).second_passport_exists,
             p_student_status           => l_person(l_count).student_status,
             p_suffix                   => l_person(l_count).suffix,
             p_date_of_death            => l_person(l_count).date_of_death,
             p_uses_tobacco_flag        => l_person(l_count).uses_tobacco_flag,
             p_town_of_birth            => l_person(l_count).town_of_birth,
             p_region_of_birth          => l_person(l_count).region_of_birth,
             p_country_of_birth         => l_person(l_count).country_of_birth,
             p_fast_path_employee       => l_person(l_count).fast_path_employee,
             p_email_address            => l_person(l_count).email_address,
             p_fte_capacity             => l_person(l_count).fte_capacity,
             p_effective_start_date     => l_effective_start_date,
             p_effective_end_date       => l_effective_end_date,
             p_full_name                => l_full_name,
             p_comment_id               => l_comment_id,
             p_name_combination_warning => l_name_combination_warning,
             p_assign_payroll_warning   => l_assign_payroll_warning,
             p_orig_hire_warning        => l_orig_hire_warning);
*/
          --
        end if;
        --
      end if;
      --
      l_last_bg_id := l_person(l_count).business_group_id;
      --
    end loop;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |------------------------------< per_party_merge >---------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure per_party_merge
    (p_entity_name        in  varchar2,
     p_from_id            in  number,
     p_to_id              out nocopy number,
     p_from_fk_id         in  number,
     p_to_fk_id           in  number,
     p_parent_entity_name in  varchar2,
     p_batch_id           in  number,
     p_batch_party_id     in  number,
     p_return_status      out nocopy varchar2) is
    --
    l_proc      varchar2(80) := g_package||'.per_party_merge';
    --
    cursor c_person is
      select ppf.*
      from   per_all_people_f ppf
      where  ppf.party_id = p_from_fk_id
      order  by ppf.effective_start_date;
    --
    l_person c_person%rowtype;
    l_effective_start_date     date;
    l_effective_end_date       date;
    l_full_name                varchar2(255);
    l_comment_id               number;
    l_name_combination_warning boolean;
    l_assign_payroll_warning   boolean;
    l_orig_hire_warning        boolean;
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    --
    -- This routine must select all the person record information and
    -- child information and update the party accordingly.
    --
    -- The code will first update all the person records for a person
    -- and then update all the child tables for that person.
    --
    g_count := 100;
    --
    open c_person;
      --
      loop
        --
        fetch c_person into l_person;
        exit when c_person%notfound;
        --
        l_person.party_id := p_to_fk_id;
        --
        -- Update the person record.
        --
/*
        hr_person_api.update_person
          (p_effective_date           => l_person.effective_start_date,
           p_datetrack_update_mode    => 'CORRECTION',
           p_person_id                => l_person.person_id,
           p_object_version_number    => l_person.object_version_number,
           p_employee_number          => l_person.employee_number,
           p_party_id                 => l_person.party_id,
           p_effective_start_date     => l_effective_start_date,
           p_effective_end_date       => l_effective_end_date,
           p_full_name                => l_full_name,
           p_comment_id               => l_comment_id,
           p_name_combination_warning => l_name_combination_warning,
           p_assign_payroll_warning   => l_assign_payroll_warning,
           p_orig_hire_warning        => l_orig_hire_warning);
        --
        -- Update all the child table records.
        --
*/
        update per_all_people_f
        set    party_id = l_person.party_id
        where  person_id = l_person.person_id
        and    effective_start_date = l_person.effective_start_date;
        --
        if l_person.effective_end_date = hr_api.g_eot then
          --
          update_child_tables(p_rec => l_person);
          --
        end if;
        --
      end loop;
      --
    close c_person;
    --
    g_count := 0;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  exception
    when others then
      p_return_status := 'F';
  end;
  --
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< get_party_details >-------------------------|
  -- ----------------------------------------------------------------------------
  function get_party_details
           (p_party_id           in number,
            p_effective_date     in date) return per_per_shd.g_rec_type is
      --
      cursor c1 is
             select *
             from    per_all_people_f
             where   party_id = p_party_id
             and     p_effective_date
             between effective_start_date
             and     effective_end_date;
      --
      l_c1 c1%rowtype;
      l_rec per_per_shd.g_rec_type;
      --
  begin
      --
      if nvl(fnd_profile.value('HR_PROPAGATE_DATA_CHANGES'),'N') <> 'Y' then
        --
        return l_rec;
        --
      end if;
      --
      -- Just get the first record regardless.
      --
      open c1;
        --
        fetch c1 into l_c1;
        --
        -- Assigining the fields to the records type
        if c1%found then
           l_rec.first_name := l_c1.first_name;
           l_rec.sex := l_c1.sex;
           l_rec.title := l_c1.title;
           l_rec.date_of_birth := l_c1.date_of_birth;
           l_rec.date_of_death := l_c1.date_of_death;
           l_rec.known_as := l_c1.known_as;
           l_rec.marital_status := l_c1.marital_status;
           l_rec.middle_names := l_c1.middle_names;
           l_rec.nationality := l_c1.nationality;
           l_rec.blood_type := l_c1.blood_type;
           l_rec.correspondence_language := l_c1.correspondence_language;
           l_rec.honors := l_c1.honors;
           l_rec.pre_name_adjunct := l_c1.pre_name_adjunct;
           l_rec.rehire_authorizor := l_c1.rehire_authorizor;
           l_rec.rehire_recommendation := l_c1.rehire_recommendation;
           l_rec.resume_exists := l_c1.resume_exists;
           l_rec.resume_last_updated := l_c1.resume_last_updated;
           l_rec.second_passport_exists := l_c1.second_passport_exists;
           l_rec.student_status := l_c1.student_status;
           l_rec.suffix := l_c1.suffix;
           l_rec.uses_tobacco_flag := l_c1.uses_tobacco_flag;
           l_rec.town_of_birth := l_c1.town_of_birth;
           l_rec.region_of_birth := l_c1.region_of_birth;
           l_rec.country_of_birth := l_c1.country_of_birth;
           l_rec.fast_path_employee := l_c1.fast_path_employee;
           l_rec.email_address := l_c1.email_address;
           l_rec.fte_capacity := l_c1.fte_capacity;
        end if;
        --
      close c1;
      --
      return l_rec;
      --
  end get_party_details;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |---------------------------< migrate_all_hr_email >-------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure migrate_all_hr_email(p_number_of_workers in number default 1,
                                 p_current_worker    in number default 1) is
    --
    l_proc varchar2(80) := g_package||'migrate_all_hr_email';
    --
    cursor c_person is
      select *
      from   per_all_people_f ppf
      where  ppf.email_address is not null
      and    mod(ppf.person_id,p_number_of_workers) = p_current_worker-1
      and    ppf.effective_end_date = hr_api.g_eot
      and    ppf.party_id is not null
      and    not exists(select null
                        from   hz_contact_points
                        where  owner_table_name = 'HZ_PARTIES'
                        and    owner_table_id = ppf.party_id
                        and    email_address = nvl(ppf.email_address,'NULL'));
    --
    l_person     c_person%rowtype;
    l_count      number := 0;
    l_data_migrator_mode varchar2(30);
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    -- This routine will create contact point records for all person
    -- records in HRMS which have an email address.
    --
    -- Stage 1 - Select person latest records and create TCA contact point
    -- records.
    --
    open c_person;
      --
      loop
        --
        fetch c_person into l_person;
        exit when c_person%notfound;
        --
        l_count := l_count + 1;
        --
        create_update_contact_point(p_rec => l_person);
        --
        if mod(l_count,10) = 0 then
          --
          -- Commit every ten persons
          --
          commit;
          l_count := 0;
          --
        end if;
        --
      end loop;
      --
    close c_person;
    --
    -- Get the last set of records in the chunk.
    --
    commit;
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
  end;
  --
  --
  -- ------------------------------------------------------------------------------
  -- |---------------------------< migrate_all_hr_gender >------------------------|
  -- ------------------------------------------------------------------------------
  --
  procedure migrate_all_hr_gender(p_number_of_workers in number default 1,
                                  p_current_worker    in number default 1) is
    --
    l_proc varchar2(80) := g_package||'migrate_all_hr_gender';
    --
    cursor c_person is
      select *
      from   per_all_people_f ppf
      where  mod(ppf.person_id,p_number_of_workers) = p_current_worker-1
      and    ppf.effective_end_date = hr_api.g_eot
      and    ppf.party_id is not null
      and    exists(select null
                    from   hz_person_profiles
                    where  party_id = ppf.party_id
                    and    nvl(gender,'Z') in ('Z','U','M','F'));
    --
    l_person     c_person%rowtype;
    l_count      number := 0;
    --
  begin
    --
    hr_utility.set_location('Entering '||l_proc,10);
    --
    open c_person;
      --
      loop
        --
        fetch c_person into l_person;
        exit when c_person%notfound;
        --
        l_count := l_count + 1;
        --
        update hz_person_profiles
          set  gender = decode(l_person.sex,null,'UNSPECIFIED'
                                           ,'F','FEMALE'
                                           ,'MALE')
          where party_id = l_person.party_id;
        --
        if mod(l_count,10) = 0 then
          --
          -- Commit every ten persons
          --
          commit;
          l_count := 0;
          --
        end if;
        --
      end loop;
      --
    close c_person;
    --
    commit;
    --
    hr_utility.set_location('Leaving '||l_proc,10);
    --
  end migrate_all_hr_gender;
  --
  function get_person_details
           (p_party_id           in number,
            p_person_id           in number,
            p_effective_date     in date) return per_per_shd.g_rec_type is

      --
      l_proc varchar2(80) := g_package||'get_person_details';
      --
      cursor c1 is
             select *
             from    per_all_people_f
             where   party_id = p_party_id
             and     person_id = p_person_id
             and     p_effective_date
             between effective_start_date
             and     effective_end_date;
      --
      l_c1 c1%rowtype;
      l_rec per_per_shd.g_rec_type;
      --
  begin
      --

      hr_utility.set_location('Entering '||l_proc,10);

      if nvl(fnd_profile.value('HR_PROPAGATE_DATA_CHANGES'),'N') <> 'Y' then
        --
        return l_rec;
        --
      end if;
      --
      -- Just get the first record regardless.
      --
      hr_utility.set_location(l_proc,20);
      --
      open c1;

      fetch c1 into l_c1;
      --
      -- Assigining the fields to the records type
      if c1%found then

        l_rec.first_name := l_c1.first_name;
        l_rec.sex := l_c1.sex;
        l_rec.title := l_c1.title;
        l_rec.date_of_birth := l_c1.date_of_birth;
        l_rec.date_of_death := l_c1.date_of_death;
        l_rec.known_as := l_c1.known_as;
        l_rec.marital_status := l_c1.marital_status;
        l_rec.middle_names := l_c1.middle_names;
        l_rec.nationality := l_c1.nationality;
        l_rec.blood_type := l_c1.blood_type;
        l_rec.correspondence_language := l_c1.correspondence_language;
        l_rec.honors := l_c1.honors;
        l_rec.pre_name_adjunct := l_c1.pre_name_adjunct;
        l_rec.rehire_authorizor := l_c1.rehire_authorizor;
        l_rec.rehire_recommendation := l_c1.rehire_recommendation;
        l_rec.resume_exists := l_c1.resume_exists;
        l_rec.resume_last_updated := l_c1.resume_last_updated;
        l_rec.second_passport_exists := l_c1.second_passport_exists;
        l_rec.student_status := l_c1.student_status;
        l_rec.suffix := l_c1.suffix;
        l_rec.uses_tobacco_flag := l_c1.uses_tobacco_flag;
        l_rec.town_of_birth := l_c1.town_of_birth;
        l_rec.region_of_birth := l_c1.region_of_birth;
        l_rec.country_of_birth := l_c1.country_of_birth;
        l_rec.fast_path_employee := l_c1.fast_path_employee;
        l_rec.email_address := l_c1.email_address;
        l_rec.fte_capacity := l_c1.fte_capacity;

      end if;
      --
      close c1;
      --
      hr_utility.set_location('Leaving '||l_proc,30);
      --
      return l_rec;
      --
  end get_person_details;

  -- Bug fix 4137950 starts here --
  -- Over loaded procedure added --

  procedure migrate_all_hr_persons(p_start_rowid in rowid,
                                   p_end_rowid in rowid,
                                   p_rows_processed out NOCOPY number) is

    -- Pl/sql table fetch person ids into.
    TYPE l_person_id_type IS TABLE OF NUMBER(15) index by binary_integer;
    --
    t_party_id          g_party_id_type;
    t_person_id         l_person_id_type;
    t_elig_person_id    l_person_id_type;
    --
    -- variable to store the count of person record to be updated
    -- with party id.
    l_elig_person_cnt number;
    -- Cursor to fetch the person id in the range.
    cursor csr_person is
    select person_id
    from   per_all_people_f
    where  party_id is null
    and    rowid between p_start_rowid and p_end_rowid
    and    effective_end_date = hr_api.g_eot;
    --
    -- Cursor to fecth the details for a person.
    --
    cursor csr_per_details(p_person_id number) is
    select *
    from per_all_people_f
    where person_id = p_person_id
    and    effective_end_date = hr_api.g_eot;
    --
    l_per_rec csr_per_details%rowtype;
    --
  begin
    -- intialize the rows processed count
    -- and the eligible person count
    p_rows_processed := 0;
    l_elig_person_cnt := 0;
    --
    open csr_person;
    loop
      -- fetch the person ids into pl/sql table.
      fetch csr_person bulk collect into t_person_id limit 1000;
      --
      if t_person_id.count = 0 then
         exit;
      end if;
      --
      -- Loop to create party records for the person with party id
      -- as null.
      --
      for i in t_person_id.first..t_person_id.last
      loop

        open csr_per_details(t_person_id(i));
        fetch csr_per_details into l_per_rec;
        close csr_per_details;

        per_hrtca_merge.create_tca_person( p_rec => l_per_rec );

        if l_per_rec.party_id is not null then
           --
           l_elig_person_cnt := l_elig_person_cnt+1;
           t_party_id(l_elig_person_cnt) := l_per_rec.party_id;
           t_elig_person_id(l_elig_person_cnt) := t_person_id(i);
           --
        end if;

      end loop;
      --
      -- Update all HR tables having party id column with
      -- respective party id stored in pl/sql table.
      --
      -- Bulk update person records if there are person records
      -- to be updated.
      --
      if t_elig_person_id.count > 0 then
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
          update per_all_people_f
          set party_id = t_party_id(i)
          where person_id = t_elig_person_id(i);
        --
        -- Bulk update competence records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_competence_elements
            set    party_id = t_party_id(i)
            where person_id = t_elig_person_id(i);
        --
        -- Bulk update events records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_events
            set    party_id = t_party_id(i)
            where  assignment_id in
                   (select assignment_id
                    from   per_all_assignments_f
                    where  person_id = t_elig_person_id(i));
        --
        -- Bulk update address records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_addresses
            set    party_id = t_party_id(i)
            where person_id = t_elig_person_id(i);
        --
        -- Bulk update phone records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_phones
            set    party_id = t_party_id(i)
            where parent_id = t_elig_person_id(i)
            and    parent_table = 'PER_ALL_PEOPLE_F';
        --
        -- Bulk update qualification records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_qualifications
            set    party_id = t_party_id(i)
            where  person_id = t_elig_person_id(i);
        --
        -- Bulk update etablishment attendances records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_establishment_attendances
            set    party_id = t_party_id(i)
            where  person_id = t_elig_person_id(i);
        --
        -- Bulk update previous employment records
        --
        forall i in t_elig_person_id.first..t_elig_person_id.last
            update per_previous_employers
            set    party_id = t_party_id(i)
            where  person_id = t_elig_person_id(i);
        --
      end if;
      --
      -- update the rows processed count.
      --
      p_rows_processed := p_rows_processed + t_person_id.count;
      --
      -- commit the migrated records.
      --
      commit;
      --
      -- Clear the pl/sql tables
      t_person_id.delete;
      t_party_id.delete;
      t_elig_person_id.delete;
      --
      l_elig_person_cnt := 0;
      --
    end loop;
    --
    close csr_person;
    --
  end migrate_all_hr_persons;
  -- Bug fix 4137950 ends here --
  --
  -- Bug fix 5247146 starts here --
  -- Over loaded procedure added --
 -- ------------------------------------------------------------------------------
 -- |---------------------------< migrate_all_hr_email >-------------------------|
 -- ------------------------------------------------------------------------------
 --
  procedure migrate_all_hr_email(p_start_rowid in rowid,
                                 p_end_rowid in rowid,
                                 p_rows_processed out NOCOPY number) is
  --
  l_proc varchar2(80) := g_package||'migrate_all_hr_email2';
    --
 cursor c_person is
 select /*+ rowid(ppf) */ *
      from   per_all_people_f ppf
      where  ppf.email_address is not null
      and    ppf.ROWID between  p_start_rowid and p_end_rowid
      and    ppf.effective_end_date = hr_api.g_eot
      and    ppf.party_id is not null
      and    not exists(select /*+ no_unnest */ null
                        from   hz_contact_points
                        where  owner_table_name = 'HZ_PARTIES'
                        and    owner_table_id = ppf.party_id
                        and    email_address = nvl(ppf.email_address,'NULL'));

 --
    l_person     c_person%rowtype;
    l_count      number := 0;
    l_data_migrator_mode varchar2(30);
    --

begin

hr_utility.set_location('Entering '||l_proc,10);

l_data_migrator_mode := hr_general.g_data_migrator_mode;
hr_general.g_data_migrator_mode := 'Y';

 -- intialize the rows processed count
    p_rows_processed := 0;

open c_person;
      --
      loop
        --
        fetch c_person into l_person;
        exit when c_person%notfound;
        --
  --
  -- Issue a savepoint.
  --
  begin
        savepoint last_pos;

        l_count := l_count + 1;
        --
        create_update_contact_point(p_rec => l_person);
        --
        if mod(l_count,10) = 0 then
          --
          -- Commit every ten persons
          --
         commit;
         l_count := 0;
          --
        end if;
        --
        p_rows_processed :=p_rows_processed+1;
  exception
    when others then
    ROLLBACK TO last_pos;
  end;
      end loop;
      --
close c_person;
--
-- Get the last set of records in the chunk.
--
commit;

--
hr_general.g_data_migrator_mode := l_data_migrator_mode;
--
hr_utility.set_location('Leaving '||l_proc,20);
--
end migrate_all_hr_email;
--
 -- Bug fix 5395601 starts here --
 -- ------------------------------------------------------------------------------
 -- |---------------------------< Purge_person >-------------------------|
 -- ------------------------------------------------------------------------------
 --
 procedure purge_person (p_person_id number,p_party_id  number ) is
    begin

    hr_utility.set_location('purge_person ', 12);
      --fix for bug 6620368 starts here.
      -- Call to purge_parties is commented to improve performance.
       -- Party id is inserted into table HR_TCA_PARTY_UNMERGE
       -- so that party id will be purged when the user run the
       -- party unmerge program next time.

       INSERT INTO hr_tca_party_unmerge (party_id,status)
            VALUES (p_party_id,'PURGE');


    /*  hr_utility.set_location('before calling add_party_for_purge ', 12);
      per_hrtca_merge.add_party_for_purge (p_party_id  => p_party_id);
      hr_utility.set_location('before calling purge_parties ', 13);
      per_hrtca_merge.purge_parties;
      hr_utility.set_location('After call ', 14);*/

     hr_utility.set_location('purge_person ', 13);
           --fix for bug 6620368 ends here.
   exception
     when others then
      ROLLBACK TO hr_delete_person;
   end purge_person;
--
end per_hrtca_merge;
--

/
