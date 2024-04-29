--------------------------------------------------------
--  DDL for Package Body IRC_GLOBAL_REMAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_GLOBAL_REMAP_PKG" as
/* $Header: ircremap.pkb 120.0 2005/07/26 15:00:29 mbocutt noship $ */

procedure remap_employee (p_person_id in number default null,
                          p_effective_date in date) is
--
  l_add_ovn per_addresses.object_version_number%type;
  l_phn_ovn per_phones.object_version_number%type;
  l_prev_emp_ovn per_previous_employers.object_version_number%type;
  l_qua_ovn per_qualifications.object_version_number%type;
  l_esa_ovn per_establishment_attendances.object_version_number%type;
  l_proc varchar2(72) := 'IRC_GLOBAL_REMAP_PKG.remap_employee';
  --
  cursor csr_address is
    select adr.address_id,
           adr.object_version_number,
           paf.business_group_id as bg_id
    from per_addresses adr, per_all_people_f paf
    where paf.party_id = adr.party_id
    and paf.person_id = p_person_id
    and adr.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  cursor csr_phones is
    select phn.phone_id,
           phn.object_version_number
    from per_phones phn, per_all_people_f paf
    where phn.party_id=paf.party_id
    and paf.person_id = p_person_id
    and phn.parent_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  cursor csr_prev_emp is
    select pem.previous_employer_id,
           pem.object_version_number,
           paf.business_group_id as bg_id
    from per_previous_employers pem, per_all_people_f paf
    where pem.party_id=paf.party_id
    and paf.person_id = p_person_id
    and pem.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  cursor csr_qual is
    select qua.qualification_id,
           qua.object_version_number,
           paf.business_group_id as bg_id
    from per_qualifications qua, per_all_people_f paf
    where qua.party_id=paf.party_id
    and paf.person_id = p_person_id
    and qua.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  cursor csr_estab_attend is
    select pea.attendance_id,
           pea.object_version_number,
           paf.business_group_id as bg_id
    from per_establishment_attendances pea, per_all_people_f paf
    where pea.party_id=paf.party_id
    and paf.person_id = p_person_id
    and pea.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date;

  cursor csr_all_address is
    select adr.address_id,
           adr.object_version_number,
           paf.business_group_id as bg_id,
	   paf.person_id as paf_person_id
    from per_addresses adr, per_all_people_f paf
    where paf.party_id = adr.party_id
    and paf.current_employee_flag = 'Y'
    and adr.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and not exists (select 1 from per_all_people_f per2
                    where paf.party_id=per2.party_id
                    and paf.person_id<>per2.person_id
                    and per2.current_employee_flag='Y'
                    and p_effective_date between per2.effective_start_date
                        and per2.effective_end_date
                    and paf.creation_date > per2.creation_date);

  cursor csr_all_phones is
    select phn.phone_id,
           phn.object_version_number,
	   paf.person_id as paf_person_id
    from per_phones phn, per_all_people_f paf
    where phn.party_id=paf.party_id
    and paf.current_employee_flag = 'Y'
    and phn.parent_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and not exists (select 1 from per_all_people_f per2
                    where paf.party_id=per2.party_id
                    and paf.person_id<>per2.person_id
                    and per2.current_employee_flag='Y'
                    and p_effective_date between per2.effective_start_date
                        and per2.effective_end_date
                    and paf.creation_date > per2.creation_date);

  cursor csr_all_prev_emp is
    select pem.previous_employer_id,
           pem.object_version_number,
           paf.business_group_id as bg_id,
	   paf.person_id as paf_person_id
    from per_previous_employers pem, per_all_people_f paf
    where pem.party_id=paf.party_id
    and paf.current_employee_flag = 'Y'
    and pem.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and not exists (select 1 from per_all_people_f per2
                    where paf.party_id=per2.party_id
                    and paf.person_id<>per2.person_id
                    and per2.current_employee_flag='Y'
                    and p_effective_date between per2.effective_start_date
                        and per2.effective_end_date
                    and paf.creation_date > per2.creation_date);

  cursor csr_all_qual is
    select qua.qualification_id,
           qua.object_version_number,
           paf.business_group_id as bg_id,
	   paf.person_id as paf_person_id
    from per_qualifications qua, per_all_people_f paf
    where qua.party_id=paf.party_id
    and paf.current_employee_flag = 'Y'
    and qua.person_id is null
    and qua.attendance_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and not exists (select 1 from per_all_people_f per2
                    where paf.party_id=per2.party_id
                    and paf.person_id<>per2.person_id
                    and per2.current_employee_flag='Y'
                    and p_effective_date between per2.effective_start_date
                        and per2.effective_end_date
                    and paf.creation_date > per2.creation_date);

  cursor csr_all_estab_attend is
    select pea.attendance_id,
           pea.object_version_number,
           paf.business_group_id as bg_id,
	   paf.person_id as paf_person_id
    from per_establishment_attendances pea, per_all_people_f paf
    where pea.party_id=paf.party_id
    and paf.current_employee_flag = 'Y'
    and pea.person_id is null
    and p_effective_date between paf.effective_start_date and paf.effective_end_date
    and not exists (select 1 from per_all_people_f per2
                    where paf.party_id=per2.party_id
                    and paf.person_id<>per2.person_id
                    and per2.current_employee_flag='Y'
                    and p_effective_date between per2.effective_start_date
                        and per2.effective_end_date
                    and paf.creation_date > per2.creation_date);

begin
--
  hr_utility.set_location('Entering Remap employee:'||l_proc, 10);
  --
  if (p_person_id is not null) then
    hr_utility.set_location('Entering Address updation:'||l_proc, 20);
    --
    -- Addresses Updation
    --
    for c_add_rec in csr_address loop
      l_add_ovn := c_add_rec.object_version_number;
      --
      -- Call to address row handler
      --
      hr_utility.set_location('Updating address:'||l_proc, 25);
      per_add_upd.upd
      (p_address_id                   => c_add_rec.address_id
      ,p_person_id                    => p_person_id
      ,p_business_group_id            => c_add_rec.bg_id
      ,p_object_version_number        => l_add_ovn
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving Address updation:'||l_proc, 30);
    --
    -- Phones Updation
    --
    hr_utility.set_location('Entering Phones updation:'||l_proc, 40);
    for c_phn_rec in csr_phones loop
      l_phn_ovn := c_phn_rec.object_version_number;
      --
      -- call to phones row handler
      --
      hr_utility.set_location('Updating phones:'||l_proc, 45);
      per_phn_upd.upd
      (p_phone_id                     => c_phn_rec.phone_id
      ,p_parent_id                    => p_person_id
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_object_version_number        => l_phn_ovn
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving Phones updation:'||l_proc, 50);
    --
    -- Previous Employment Updation
    --
    hr_utility.set_location('Entering Previous Employment updation:'||l_proc, 60);
    for c_pem_rec in csr_prev_emp loop
      l_prev_emp_ovn := c_pem_rec.object_version_number;
      --
      -- call to previous employer row handler
      --
      hr_utility.set_location('Updating previous employment:'||l_proc, 65);
      per_pem_upd.upd
      (p_effective_date                 => p_effective_date
      ,p_person_id                      => p_person_id
      ,p_previous_employer_id           => c_pem_rec.previous_employer_id
      ,p_object_version_number          => l_prev_emp_ovn
      ,p_business_group_id              => c_pem_rec.bg_id
      );
    end loop;
    hr_utility.set_location('Leaving Previous Employment updation:'||l_proc, 70);
    --
    -- Qualifications Updation
    --
    hr_utility.set_location('Entering Qualifications updation:'||l_proc, 80);
    for c_qua_rec in csr_qual loop
      l_qua_ovn := c_qua_rec.object_version_number;
      --
      -- call to qualifications row handler
      --
      hr_utility.set_location('Updating qualifications:'||l_proc, 85);
      per_qua_upd.upd
      (p_qualification_id             => c_qua_rec.qualification_id
      ,p_object_version_number        => l_qua_ovn
      ,p_person_id                    => p_person_id
      ,p_effective_date               => p_effective_date
      ,p_business_group_id            => c_qua_rec.bg_id
      );
    end loop;
    hr_utility.set_location('Leaving Qualifications updation:'||l_proc, 90);
    --
    -- Establishment Attendances Updation
    --
    hr_utility.set_location('Entering Establishment Attendances updation:'||l_proc, 100);
    for c_esa_rec in csr_estab_attend loop
      l_esa_ovn := c_esa_rec.object_version_number;
      --
      -- call to establishment attendances row handler
      --
      hr_utility.set_location('Updating establishment attendances:'||l_proc, 105);
      per_esa_upd.upd
      (p_attendance_id                => c_esa_rec.attendance_id
      ,p_business_group_id            => c_esa_rec.bg_id
      ,p_object_version_number        => l_esa_ovn
      ,p_person_id                    => p_person_id
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving Establishment Attendances updation:'||l_proc, 110);
  --
  else
  --
  -- Update all employee records
  --
    hr_utility.set_location('Entering All Addresses updation:'||l_proc, 120);
    --
    -- Addresses Updation
    --
    for c_add_rec in csr_all_address loop
      l_add_ovn := c_add_rec.object_version_number;
      hr_utility.set_location('Updating address:'||l_proc, 125);
      --
      -- Call to address row handler
      --
      per_add_upd.upd
      (p_address_id                   => c_add_rec.address_id
      ,p_person_id                    => c_add_rec.paf_person_id
      ,p_business_group_id            => c_add_rec.bg_id
      ,p_object_version_number        => l_add_ovn
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving All Addresses updation:'||l_proc, 130);
    --
    -- Phones Updation
    --
    hr_utility.set_location('Entering All Phones updation:'||l_proc, 140);
    for c_phn_rec in csr_all_phones loop
      l_phn_ovn := c_phn_rec.object_version_number;
      --
      -- call to phones row handler
      --
      hr_utility.set_location('Updating phones:'||l_proc, 145);
      per_phn_upd.upd
      (p_phone_id                     => c_phn_rec.phone_id
      ,p_parent_id                    => c_phn_rec.paf_person_id
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_object_version_number        => l_phn_ovn
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving All Phones updation:'||l_proc, 150);
    --
    -- Previous Employment Updation
    --
    hr_utility.set_location('Entering All Previous Employment updation:'||l_proc, 160);
    for c_pem_rec in csr_all_prev_emp loop
      l_prev_emp_ovn := c_pem_rec.object_version_number;
      --
      -- call to previous employer row handler
      --
      hr_utility.set_location('Updating previous employment:'||l_proc, 165);
      per_pem_upd.upd
      (p_effective_date                 => p_effective_date
      ,p_person_id                      => c_pem_rec.paf_person_id
      ,p_previous_employer_id           => c_pem_rec.previous_employer_id
      ,p_object_version_number          => l_prev_emp_ovn
      ,p_business_group_id              => c_pem_rec.bg_id
      );
    end loop;
    hr_utility.set_location('Leaving All Previous Employment updation:'||l_proc, 170);
    --
    -- Qualifications Updation
    --
    hr_utility.set_location('Entering All Qualifications updation:'||l_proc, 180);
    for c_qua_rec in csr_all_qual loop
      l_qua_ovn := c_qua_rec.object_version_number;
      --
      -- call to qualifications row handler
      --
      hr_utility.set_location('Updating qualifications:'||l_proc, 185);
      per_qua_upd.upd
      (p_qualification_id             => c_qua_rec.qualification_id
      ,p_object_version_number        => l_qua_ovn
      ,p_person_id                    => c_qua_rec.paf_person_id
      ,p_effective_date               => p_effective_date
      ,p_business_group_id            => c_qua_rec.bg_id
      );
    end loop;
    hr_utility.set_location('Leaving All Qualifications updation:'||l_proc, 190);
    --
    -- Establishment Attendances Updation
    --
    hr_utility.set_location('Entering All Establishment Attendances updation:'||l_proc, 200);
    for c_esa_rec in csr_all_estab_attend loop
      l_esa_ovn := c_esa_rec.object_version_number;
      --
      -- call to establishment attendances row handler
      --
      hr_utility.set_location('Updating establishment attendances:'||l_proc, 205);
      per_esa_upd.upd
      (p_attendance_id                => c_esa_rec.attendance_id
      ,p_object_version_number        => l_esa_ovn
      ,p_person_id                    => c_esa_rec.paf_person_id
      ,p_business_group_id            => c_esa_rec.bg_id
      ,p_effective_date               => p_effective_date
      );
    end loop;
    hr_utility.set_location('Leaving All Establishment Attendances updation:'||l_proc, 210);
  end if;
  NULL;
--
end remap_employee;
--
--
-- Procedure remap_employee for the concurrent process
--
procedure remap_employee (errbuf  out nocopy varchar2
                         ,retcode out nocopy varchar2
			 ,p_effective_date in varchar2
                         ,p_person_id in number ) is
--
l_proc varchar2(72) := 'IRC_GLOBAL_REMAP_PKG.remap_employee';
--
begin
  hr_utility.set_location('Entering Remap employee:'||l_proc, 10);
  remap_employee
  (p_person_id => p_person_id
  ,p_effective_date => fnd_date.canonical_to_date(p_effective_date)
  );
  commit;
  retcode := 0;
  hr_utility.set_location('Leaving Remap employee:'||l_proc, 20);
--
exception
  when others then
    rollback;
    --
    -- Set the return parameters to indicate failure
    --
    errbuf := sqlerrm;
    retcode := 2;
end remap_employee;
--
end irc_global_remap_pkg;

/
