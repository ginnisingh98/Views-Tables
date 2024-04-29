--------------------------------------------------------
--  DDL for Package Body HR_PERSON_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_INTERNAL" as
/* $Header: peperbsi.pkb 120.9.12010000.5 2008/08/06 09:26:29 ubhat ship $ */
--
-- Package Variables
--
g_package varchar2(33) := '  hr_person_internal.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< product_installed >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE product_installed(p_application_short_name IN varchar2
                           ,p_status                 OUT NOCOPY varchar2
                           ,p_yes_no                 OUT NOCOPY varchar2
                           ,p_oracle_username        OUT NOCOPY varchar2)
IS
  --
  l_proc varchar2(72) := g_package||'product_installed';
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  p_yes_no := 'N';
  p_oracle_username := 'DUMMY';
  --
  begin
    select 'Y', fpi.status
    into   p_yes_no, p_status
    from   fnd_product_installations fpi
    where  fpi.status = 'I'
    and    fpi.application_id =
           (select fa.application_id
            from   fnd_application fa
            where  fa.application_short_name = P_APPLICATION_SHORT_NAME
           );

  exception
     when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
  --
END product_installed;
--
-- ----------------------------------------------------------------------------
-- |------------------------< person_existance_check >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
-- Raises error (and hence falls right out of package) if this person does
-- not exist.
--
PROCEDURE person_existance_check (p_person_id  number)
IS
  --
  l_dummy    number(15);
  --
BEGIN
  --
  select count(*)
  into   l_dummy
  from   per_all_people_f p
  where  p.person_id = P_PERSON_ID;
  --
EXCEPTION
  when NO_DATA_FOUND then
    --
    hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token ('PROCEDURE','PERSON_EXISTANCE_CHECK');
    hr_utility.set_message_token ('STEP', '1');
    hr_utility.raise_error;
    --
END person_existance_check;
--
-- ----------------------------------------------------------------------------
-- |------------------------< aol_predel_validation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description : Foreign key reference check.
--
PROCEDURE aol_predel_validation (p_person_id    number)
IS
  --
  l_delete_permitted    varchar2(1);
  --
BEGIN
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists
          (select null
           from   fnd_user aol
           where  aol.employee_id = P_PERSON_ID
          );
     --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6274_ALL_AOL_PER_NO_DEL');
        hr_utility.raise_error;
  end;
  --
END aol_predel_validation;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< assignment_set_check >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Sets error code and status if this person has any assignments which are
-- the only ones in an assignment set and where that assginment is included.
--
PROCEDURE assignment_set_check (p_person_id IN number)
IS
  --
  l_delete_permitted    varchar2(1);
  --
BEGIN
  --
  select 'Y'
  into   l_delete_permitted
  from   sys.dual
  where  not exists
        (select null
         from   per_assignments_f ass,
                hr_assignment_set_amendments asa
         where  asa.assignment_id = ass.assignment_id
         and    ass.person_id  = P_PERSON_ID
         and    asa.include_or_exclude    = 'I'
         and    not exists
               (select null
                from   hr_assignment_set_amendments asa2
                where  asa2.assignment_set_id = asa.assignment_set_id
                and    asa2.assignment_id <> asa.assignment_id)
        );
  --
EXCEPTION
  when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6305_ALL_ASSGT_SET_NO_DEL');
        hr_utility.raise_error;
  --
END assignment_set_check;
--
-- ----------------------------------------------------------------------------
-- |------------------------< pay_predel_validation >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Ensures that there are no assignments actions for this person other than
-- Purge actions. If there are then raise an error and disallow delete.
--
PROCEDURE pay_predel_validation (p_person_id    number)
IS
  --
  l_delete_permitted    varchar2(1);
  --
BEGIN
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists
          (select null
           from   pay_assignment_actions paa
                 ,per_assignments_f ass
                 ,pay_payroll_actions ppa
           where  paa.assignment_id = ass.assignment_id
           and    ass.person_id = P_PERSON_ID
           and    ppa.payroll_action_id = paa.payroll_action_id
           and    ppa.action_type <> 'Z');
     --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6237_ALL_ASS_ACTIONS_EXIST');
        hr_utility.raise_error;
  end;
  --
END pay_predel_validation;
--
-- ----------------------------------------------------------------------------
-- |------------------------< ben_predel_validation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description : Ensures that there are no open life events for a person.
--
PROCEDURE ben_predel_validation(p_person_id NUMBER
                               ,p_effective_date DATE)
IS
  --
  --
BEGIN
  --
  ben_person_delete.check_ben_rows_before_delete(p_person_id
                                                ,p_effective_date);
  --
END ben_predel_validation;
--
-- ----------------------------------------------------------------------------
-- |----------------------< closed_element_entry_check >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
-- Check that for any element entries that are about to be deleted, the
-- element type is not closed for the duration of that entry. Also check
-- that if the assignment is to a payroll, the payroll period is not closed.
-- If any of these 2 checks fail, the delete is disallowed.
--
PROCEDURE closed_element_entry_check(p_person_id    IN number
                                    ,p_effective_date IN date)
IS
  --
  CURSOR csr_this_persons_ee IS
  SELECT l.element_type_id, e.effective_start_date,
         e.effective_end_date, a.assignment_id
  FROM   pay_element_entries_f e,
         per_assignments_f a,
         pay_element_links_f l
  WHERE  a.person_id = P_PERSON_ID
  and    a.assignment_id = e.assignment_id
  and    e.effective_start_date between
         a.effective_start_date and a.effective_end_date
  and    e.element_link_id = l.element_link_id
  and    e.effective_start_date between
            l.effective_start_date and l.effective_end_date;
  --
  l_proc varchar2(72) := g_package||'closed_element_entry_check';
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  FOR each_entry in csr_this_persons_ee LOOP
    --
    hr_entry.chk_element_entry_open(each_entry.element_type_id,
                each_entry.effective_start_date,
                each_entry.effective_start_date,
                each_entry.effective_end_date,
                each_entry.assignment_id);
    --
  END LOOP;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 10);
  end if;
  --
END closed_element_entry_check;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< contact_cobra_validation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Searches for any contacts of the person being deleted who have
-- COBRA Coverage Enrollments which are as a result of the Persons
-- Assignments.
--
PROCEDURE contact_cobra_validation (p_person_id    number)
IS
  --
  l_delete_permitted    varchar2(1);
  --
BEGIN
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists
          (select null
           from   per_assignments_f a
                 ,per_contact_relationships c
                 ,per_cobra_cov_enrollments e
           where  a.person_id = P_PERSON_ID
           and    a.assignment_id = e.assignment_id
           and    c.person_id = P_PERSON_ID
           and    c.contact_relationship_id = e.contact_relationship_id);
     --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6981_ALL_CONT_COBRA_EXISTS');
        hr_utility.raise_error;
  end;
  --
END contact_cobra_validation;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< contracts_check >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Raise an error if related contracts exist for the given person.
--
PROCEDURE contracts_check (p_person_id number)
IS
  --
  l_delete_permitted    varchar2(1);
  --
  l_proc varchar2(72) := g_package||'contracts_check';
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Check that no child records exist for the
  -- person on per_contracts_f when
  -- the person is deleted
  --
  select null
  into   l_delete_permitted
  from   sys.dual
  where  not exists
        (select null
         from   per_contracts_f
         where  person_id = p_person_id);
  --
exception
  when NO_DATA_FOUND then
    hr_utility.set_message(800,'PER_52851_PER_NO_DEL_CONTRACTS');
    hr_utility.raise_error;
  --
END contracts_check;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_contact >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Is this contact a contact for anybody else? If so then do nothing.
-- If not then check if this person has ever been an employee or
-- applicant. If they have not then check whether they have any extra
-- info entered for them (other than default info). If they have not
-- then delete this contact also. Otherwise do nothing.
--
-- NOTES
--   p_person_id                Non-contact in relationship.
--   p_contact_person_id        Contact in this relationship - the person
--                              who the check is performed against.
--   p_contact_relationship_id  Relationship which is currently being
--                              considered for this contact.
--
PROCEDURE check_contact(p_person_id  IN number
                       ,p_contact_person_id IN number
                       ,p_contact_relationship_id IN number
                       ,p_effective_date IN date)
IS
  --
  l_contact_elsewhere    varchar2(1);
  l_other_only           varchar2(1);
  l_delete_contact       varchar2(1);
  l_proc varchar2(72) := g_package||'check_contact';
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  hr_person_internal.person_existance_check(P_CONTACT_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_contact_elsewhere
    from   sys.dual
    where  exists
          (select null
           from   per_contact_relationships r
           where  r.contact_relationship_id <> P_CONTACT_RELATIONSHIP_ID
           and    r.contact_person_id = P_CONTACT_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if SQL%ROWCOUNT > 0 then
    return;
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_other_only
    from   sys.dual
    where  not exists
          (select null
           from   per_people_f p
           where  p.person_id = P_CONTACT_PERSON_ID
           and    p.current_emp_or_apl_flag = 'Y');
    --
  exception
    when NO_DATA_FOUND then return;
  end;
  --
  begin
    --
    --  Can contact be deleted? If strong val errors then just trap
    --  error as we will continue as usual. If it succeeds then delete
    --  contact.
    --
    begin
        l_delete_contact := 'Y';
        hr_person_internal.strong_predel_validation(P_CONTACT_PERSON_ID,
                            p_effective_date);
    exception
        when hr_utility.hr_error then
            l_delete_contact := 'N';
    end;
    --
    if l_delete_contact = 'Y' then
       hr_person_internal.people_default_deletes(P_CONTACT_PERSON_ID);
    end if;
    --
  end;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 99);
  end if;
END check_contact;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_org_manager >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_org_manager(p_person_id in number
                            ,p_effective_date in date
                            ,p_person_org_manager_warning out nocopy varchar2) IS
  --
  cursor csr_org_details(p_organization_id number) is
    select org_info.organization_id,
           org_info.org_information_id,
           org_info.org_information_context,
           org_info.org_information1,
           org_info.org_information2,
           org_info.org_information3,
           org_info.org_information4,
           org_info.org_information5,
           org_info.org_information6,
           org_info.org_information7,
           org_info.org_information8,
           org_info.org_information9,
           org_info.org_information10,
           org_info.org_information11,
           org_info.org_information12,
           org_info.org_information13,
           org_info.org_information14,
           org_info.org_information15,
           org_info.org_information16,
           org_info.org_information17,
           org_info.org_information18,
           org_info.org_information19,
           org_info.org_information20,
           org_info.object_version_number,
           org_info.attribute_category,
           org_info.attribute1,
           org_info.attribute2,
           org_info.attribute3,
           org_info.attribute4,
           org_info.attribute5,
           org_info.attribute6,
           org_info.attribute7,
           org_info.attribute8,
           org_info.attribute9,
           org_info.attribute10,
           org_info.attribute11,
           org_info.attribute12,
           org_info.attribute13,
           org_info.attribute14,
           org_info.attribute15,
           org_info.attribute16,
           org_info.attribute17,
           org_info.attribute18,
           org_info.attribute19,
           org_info.attribute20
    from   hr_organization_information org_info
    where  org_info.organization_id = p_organization_id
    and    org_info.org_information_context = 'Organization Name Alias'
    and    org_info.org_information2 = to_char(p_person_id);
  --
  l_org_details csr_org_details%rowtype;
  --
  cursor csr_per_mgr_orgs is
    select org.organization_id,
           org_tl.name
    from   hr_all_organization_units org,
           hr_all_organization_units_tl org_tl
    where  org.organization_id = org_tl.organization_id
    and    exists (select null
                   from   hr_organization_information org_info
                   where  org_info.organization_id = org.organization_id
                   and    org_info.org_information_context = 'Organization Name Alias'
                   and    org_info.org_information2 = to_char(p_person_id));
  --
  l_per_mgr_orgs csr_per_mgr_orgs%rowtype;
  --
  l_per_is_org_mgr_warning boolean := FALSE;
  l_warning boolean;
  --
BEGIN
  --
  if p_person_id is not null then
    --
    -- Check whether this will have any impact on org_managers
    --
    open csr_per_mgr_orgs;
      --
      loop
        --
        fetch csr_per_mgr_orgs into l_per_mgr_orgs;
        exit when csr_per_mgr_orgs%notfound;
        --
        l_per_is_org_mgr_warning := TRUE;
        --
        open csr_org_details(l_per_mgr_orgs.organization_id);
          --
          loop
            --
            fetch csr_org_details into l_org_details;
            exit when csr_org_details%notfound;
            --
            if l_org_details.org_information1 is null then
              --
              hr_organization_api.delete_org_manager
                (p_org_information_id    => l_org_details.org_information_id,
                 p_object_version_number => l_org_details.object_version_number);
              --
            else
              --
              hr_organization_api.update_org_manager
                (p_effective_date        => p_effective_date
                ,p_organization_id       => l_org_details.organization_id
                ,p_org_information_id    => l_org_details.org_information_id
                ,p_org_info_type_code    => l_org_details.org_information_context
                ,p_org_information1      => l_org_details.org_information1
                ,p_org_information2      => null
                ,p_org_information3      => null
                ,p_org_information4      => null
                ,p_org_information5      => l_org_details.org_information5
                ,p_org_information6      => l_org_details.org_information6
                ,p_org_information7      => l_org_details.org_information7
                ,p_org_information8      => l_org_details.org_information8
                ,p_org_information9      => l_org_details.org_information9
                ,p_org_information10     => l_org_details.org_information10
                ,p_org_information11     => l_org_details.org_information11
                ,p_org_information12     => l_org_details.org_information12
                ,p_org_information13     => l_org_details.org_information13
                ,p_org_information14     => l_org_details.org_information14
                ,p_org_information15     => l_org_details.org_information15
                ,p_org_information16     => l_org_details.org_information16
                ,p_org_information17     => l_org_details.org_information17
                ,p_org_information18     => l_org_details.org_information18
                ,p_org_information19     => l_org_details.org_information19
                ,p_org_information20     => l_org_details.org_information20
                ,p_attribute_category    => l_org_details.attribute_category
                ,p_attribute1            => l_org_details.attribute1
                ,p_attribute2            => l_org_details.attribute2
                ,p_attribute3            => l_org_details.attribute3
                ,p_attribute4            => l_org_details.attribute4
                ,p_attribute5            => l_org_details.attribute5
                ,p_attribute6            => l_org_details.attribute6
                ,p_attribute7            => l_org_details.attribute7
                ,p_attribute8            => l_org_details.attribute8
                ,p_attribute9            => l_org_details.attribute9
                ,p_attribute10           => l_org_details.attribute10
                ,p_attribute11           => l_org_details.attribute11
                ,p_attribute12           => l_org_details.attribute12
                ,p_attribute13           => l_org_details.attribute13
                ,p_attribute14           => l_org_details.attribute14
                ,p_attribute15           => l_org_details.attribute15
                ,p_attribute16           => l_org_details.attribute16
                ,p_attribute17           => l_org_details.attribute17
                ,p_attribute18           => l_org_details.attribute18
                ,p_attribute19           => l_org_details.attribute19
                ,p_attribute20           => l_org_details.attribute20
                ,p_object_version_number => l_org_details.object_version_number
                ,p_warning               => l_warning);
              --
            end if;
            --
          end loop;
          --
        close csr_org_details;
        --
      end loop;
      --
    close csr_per_mgr_orgs;
    --
  end if;
  --
  IF l_per_is_org_mgr_warning THEN
    --
    p_person_org_manager_warning :=
          fnd_message.get_string('PER','HR_449563_PER_DEL_ORG_MGR');
    --
  END IF;
  --
END delete_org_manager;
--
-- ----------------------------------------------------------------------------
-- |------------------------< weak_predel_validation >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE weak_predel_validation(p_person_id    IN number
                                ,p_effective_date IN date)
IS
  --
  -- Declare the local variables
  --
  l_pay_installed    varchar2(1);
  l_pay_status       varchar2(1);
  l_ben_installed    varchar2(1);
  l_ben_status       varchar2(1);
  l_oracle_id        varchar2(30);
  l_delete_permitted varchar2(1);
  --
  l_proc varchar2(72) := g_package||'weak_predel_validation';
  --
  -- Bug 4672901 Starts Here
    CURSOR ben_ext_chg_log (
       p_person_id   NUMBER
       ) IS
       SELECT        ext_chg_evt_log_id
       FROM          ben_ext_chg_evt_log
       WHERE         person_id = p_person_id
       FOR UPDATE OF ext_chg_evt_log_id;
       --
       l_id   NUMBER;
  -- Bug 4672901 Ends Here
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  hr_person_internal.person_existance_check(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  hr_person_internal.product_installed('PAY'
                                       ,l_pay_status
                                       ,l_pay_installed
                                       ,l_oracle_id);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  hr_person_internal.aol_predel_validation(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  hr_person_internal.assignment_set_check(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  if (l_pay_installed = 'Y') then
     --
     if g_debug then
       hr_utility.set_location(l_proc, 55);
     end if;
     --
     hr_person_internal.pay_predel_validation(P_PERSON_ID);
     --
  end if;

  -- Bug 4672901 Starts Here

  OPEN ben_ext_chg_log (p_person_id);
  --
  LOOP
    FETCH ben_ext_chg_log INTO l_id;
    EXIT WHEN ben_ext_chg_log%NOTFOUND;
    DELETE FROM ben_ext_chg_evt_log
    WHERE  CURRENT OF ben_ext_chg_log;
  END LOOP;
  --
  CLOSE ben_ext_chg_log;

  -- Bug 4672901 Ends Here
  --

  --
  -- Removed check for ben install
  -- as OSB can now have enrollment results
  -- and unrestricted Life events in progress
  --
  hr_person_internal.ben_predel_validation(P_PERSON_ID,p_effective_date);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  hr_person_internal.closed_element_entry_check(P_PERSON_ID, p_effective_date);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  hr_person_internal.contact_cobra_validation(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 80);
  end if;
  --
  hr_person_internal.contracts_check(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 100);
  end if;
  --
END weak_predel_validation;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< strong_predel_validation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Descrption:
--
-- It performs many checks to find if additional data has been entered for this
-- person. It is more stringent than weak_predel_validation and ensures that
-- this person only has the default data set up by entering a person, contact
-- or applicant afresh onto the system. If additional data is found then the
-- delete of this person from the calling module is invalid as it is beyond
-- its scope. The Delete Person form should therefore be used (which only
-- performs weak_predel_validation) if a delete really is required.
--
PROCEDURE strong_predel_validation(p_person_id    IN number
                                  ,p_effective_date IN date)
IS
  --
  l_person_types     number;
  l_delete_permitted varchar2(1);
  --
  -- Bug 3524713 Starts Here
  CURSOR ben_ext_chg_log (
     p_person_id   NUMBER
     ) IS
     SELECT        ext_chg_evt_log_id
     FROM          ben_ext_chg_evt_log
     WHERE         person_id = p_person_id
     FOR UPDATE OF ext_chg_evt_log_id;
     --
     l_id   NUMBER;
-- Bug 3524713 Ends Here
  --
  l_proc varchar2(72) := g_package||'strong_predel_validation';
  --
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  --   check if person type changes exist.
  --
  -- Fix for bug 7045968 starts here
 -- Modified the select statement to use the person_type_id from
 -- per_person_type_usages_f
 -- rather than per_people_f

 /*select count(*)
  into   l_person_types
  from   per_people_f ppf,
         per_person_types ppt
  where  ppf.person_id     = P_PERSON_ID
  and    ppf.effective_end_date >= p_effective_date
  and    ppf.person_type_id = ppt.person_type_id
  and (   exists
         (select null
          from   per_people_f ppf2,
                 per_person_types ppt2
          where  ppf2.person_id    = ppf.person_id
          and    ppf2.effective_end_date >= p_effective_date
          and    ppf2.person_type_id = ppt2.person_type_id
          and    ppt2.system_person_type <> ppt.system_person_type
         )
   or exists
          (select null
           from per_periods_of_placement ppp
           where ppp.person_id=ppf.person_id
           and actual_termination_date>=p_effective_date
           and actual_termination_date is not null)
   or exists
          (select null
           from per_periods_of_placement ppp
           where ppp.person_id=ppf.person_id
           and ppp.date_start>p_effective_date
           )
   ); */ --fix for bug 6730008.


   select count(*)
  into   l_person_types
  from   per_person_type_usages_f ptu
  where  ptu.person_id     = P_PERSON_ID
  and    ptu.effective_start_date >= p_effective_date;

     -- Fix for bug 7045968 ends here


  --
  if l_person_types > 0 then
    --
    hr_utility.set_message (801,'HR_6324_ALL_PER_ADD_NO_DEL');
    hr_utility.raise_error;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  begin
    --
    -- bug fix 3732129.
    -- Select statement modified to improve performance.
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_letter_request_lines r
           where  r.person_id    = P_PERSON_ID
           and    r.date_from >= p_effective_date );
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_letter_request_lines r
           where  exists (
                  select null
                  from   per_assignments_f a
                  where  a.person_id     = P_PERSON_ID
                  and    a.effective_start_date >= p_effective_date
                  and    a.assignment_id = r.assignment_id));
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6325_ALL_PER_RL_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_contact_relationships r
           where  r.person_id     = P_PERSON_ID
           or    r.contact_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6326_ALL_PER_CR_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_events e
           where  e.internal_contact_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6328_ALL_PER_EVENT_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_bookings b
           where  b.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6329_ALL_PER_BOOK_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  1 >= (
           select count(*)
           from   per_assignments_f a
           where  a.person_id = P_PERSON_ID
           and    a.effective_start_date >= p_effective_date);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6330_ALL_PER_ASSGT_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_assignments_f a
           where  a.recruiter_id  = P_PERSON_ID
           or     a.supervisor_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6331_ALL_PER_RT_SUP_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 80);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_periods_of_service p
           where  p.termination_accepted_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6332_ALL_PER_TERM_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 90);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_person_analyses a
           where  a.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6334_ALL_PER_ANAL_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 100);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_absence_attendances a
           where  a.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6335_ALL_PER_ABS_ATT_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 110);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_absence_attendances a
           where  a.authorising_person_id = P_PERSON_ID
           or     a.replacement_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6336_ALL_PER_AUTH_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 120);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_recruitment_activities r
           where  r.authorising_person_id = P_PERSON_ID
           or     r.internal_contact_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6337_ALL_PER_REC_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 130);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_appraisals apr
           where  apr.appraisee_person_id = P_PERSON_ID
           or     apr.appraiser_person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
         fnd_message.set_name('PER','PER_52467_APR_PAR_REC_NO_DEL');
         fnd_message.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 140);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select  null
           from    per_participants par
           where   par.person_id = P_PERSON_ID);
    --
  exception
      when NO_DATA_FOUND then
           fnd_message.set_name('PER','PER_52467_APR_PAR_REC_NO_DEL');
           fnd_message.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 150);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_requisitions r
           where  r.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6338_ALL_PER_REQ_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 160);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_vacancies v
           where  v.recruiter_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6339_ALL_PER_VAC_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 170);
  end if;
  --
  --  Any discretionary link element entries?
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   pay_element_entries_f e,
                  per_assignments_f a,
                  pay_element_links_f    l
           where  a.person_id = P_PERSON_ID
           and    a.assignment_id = e.assignment_id
           and    e.element_link_id = l.element_link_id
           and    l.standard_link_flag = 'N');
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6340_ALL_PER_DISC_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 180);
  end if;
  --
  --   Any entry adjustments, overrides etc.?
  --   (We cannot capture manual enty of standard link entries)
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   pay_element_entries_f e,
                  per_assignments_f a
           where  a.person_id = P_PERSON_ID
           and    a.assignment_id = e.assignment_id
           and    e.entry_type <> 'E');
    --
  exception
     when NO_DATA_FOUND then
          hr_utility.set_message (801,'HR_6375_ALL_PER_ENTRY_NO_DEL');
          hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 190);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_assignment_extra_info i
           where  exists (
                  select null
                  from   per_assignments_f a
                  where  a.person_id = P_PERSON_ID
                  and    a.assignment_id = i.assignment_id));
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6341_ALL_PER_ASS_INFO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 200);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_secondary_ass_statuses s
           where  exists (
                  select null
                  from   per_assignments_f a
                  where  a.person_id = P_PERSON_ID
                  and    a.assignment_id = s.assignment_id));
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6340_ALL_PER_DISC_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 210);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_events e
           where  exists (
                  select null
                  from   per_assignments_f a
                  where  a.person_id = P_PERSON_ID
                  and    a.assignment_id = e.assignment_id));
    --
  exception
    when NO_DATA_FOUND then
        hr_utility.set_message (801,'HR_6344_ALL_PER_INT_NO_DEL');
        hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 220);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_spinal_point_placements_f p
           where  exists  (
                  select null
                  from   per_assignments_f a
                  where  a.person_id = P_PERSON_ID
                  and    a.assignment_id = p.assignment_id));
    --
  exception
      when NO_DATA_FOUND then
              hr_utility.set_message (801,'HR_6374_ALL_PER_SPINE_NO_DEL');
              hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 230);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_quickpaint_result_text t
           where  exists  (
                  select null
                  from   per_assignments_f a
                  where  a.person_id     = P_PERSON_ID
                  and    a.assignment_id = t.assignment_id));
    --
  exception
      when NO_DATA_FOUND then
           hr_utility.set_message (801,'HR_6379_ALL_PER_QP_NO_DEL');
           hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 240);
  end if;
  --
  begin
    --
    select 'Y'
    into   l_delete_permitted
    from   sys.dual
    where  not exists (
           select null
           from   per_cobra_cov_enrollments c
           where  exists  (
                  select null
                  from   per_assignments_f a
                  where  a.person_id     = P_PERSON_ID
                  and    a.assignment_id = c.assignment_id));
    --
  exception
     when NO_DATA_FOUND then
           hr_utility.set_message (801,'HR_6476_ALL_PER_COB_NO_DEL');
           hr_utility.raise_error;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 250);
  end if;
  --
  OPEN ben_ext_chg_log (p_person_id);
  --
  LOOP
    --
    FETCH ben_ext_chg_log INTO l_id;
    EXIT WHEN ben_ext_chg_log%NOTFOUND;
    --
    DELETE FROM ben_ext_chg_evt_log
    WHERE  CURRENT OF ben_ext_chg_log;
    --
  END LOOP;
  --
  CLOSE ben_ext_chg_log;
  --
  -- Bug 3524713 Ends Here
  --
  ben_person_delete.perform_ri_check(p_person_id);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 260);
  end if;
  --
  -- Validation for OTA.
  --
  per_ota_predel_validation.ota_predel_per_validation(P_PERSON_ID);
  --
  -- validation for PA
  --
  if g_debug then
    hr_utility.set_location(l_proc, 270);
  end if;
  --
  pa_person.pa_predel_validation(P_PERSON_ID);
  --
  -- validation for WIP
  --
  if g_debug then
    hr_utility.set_location(l_proc, 280);
  end if;
  --
  wip_person.wip_predel_validation(P_PERSON_ID);
  --
  -- validation for ENG
  --
  if g_debug then
    hr_utility.set_location(l_proc, 290);
  end if;
  --
  eng_person.eng_predel_validation(P_PERSON_ID);
  --
  -- validation for AP
  --
  if g_debug then
    hr_utility.set_location(l_proc, 300);
  end if;
  --
  ap_person.ap_predel_validation(P_PERSON_ID);
  --
  -- validation for FA
  --
  if g_debug then
    hr_utility.set_location(l_proc, 310);
  end if;
  --
  fa_person.fa_predel_validation(P_PERSON_ID);
  --
  -- validation for PO
  --
  if g_debug then
    hr_utility.set_location(l_proc, 320);
  end if;
  --
  po_person.po_predel_validation(P_PERSON_ID);
  --
  -- validation for RCV
  --
  if g_debug then
    hr_utility.set_location(l_proc, 330);
  end if;
  --
  rcv_person.rcv_predel_validation(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
END strong_predel_validation;
--
-- ----------------------------------------------------------------------------
-- |----------------------< people_default_deletes >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Delete routine for deleting information set up as default when people
-- are created. Used primarily for delete on PERPEEPI (Enter Person).
-- The strong_predel_validation should first be performed to ensure that
-- no additional info (apart from default) has been entered.
--
-- NOTE
--
--  See delete_person for p_form_call details. Further, p_form_call is
--  set to TRUE when this procedure is called from check_contact as
--  there is no need to check the existance of the contact.
--
PROCEDURE people_default_deletes (p_person_id    IN number)
IS
  --
  l_assignment_id    number(15);
  l_proc             varchar2(72) := g_package||'people_default_deletes';
  l_pk1_value1       varchar2(72) := p_person_id;

  --
  CURSOR lock_person_rows IS
  select person_id
  from   per_people_f
  where  person_id = P_PERSON_ID
  FOR    UPDATE;
  --
  CURSOR   attached_docs_cursor1  IS
    SELECT attached_document_id
    FROM   fnd_attached_documents
    WHERE  pk1_value = l_pk1_value1;
--
   cursor delattachments_cursor1 (x_attached_document_id in number) is
        select datatype_id
          from fnd_attached_docs_form_vl
         where attached_document_id =  x_attached_document_id;
--
  l_datatype_id             number;
  l_attached_document_id    number;
  deldatarec1               delattachments_cursor1%ROWTYPE;
--
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  hr_person_internal.person_existance_check(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  open LOCK_PERSON_ROWS;
  --
  --  Now start cascade.
  --
  -- Start of Fix for WWBUG 1294400
  -- All of benefits is a child of HR and PAY so its safe to delete
  -- benefits stuff first.
  --
  ben_person_delete.delete_ben_rows(p_person_id);
  --
  -- End of Fix for WWBUG 1294400
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  hr_security.delete_per_from_list(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  --  Lock assignments now, delete at end.
  --  Can select into a variable as max one assignment should exist (as
  --  strong_predel_validation has already been performed).
  --  May not be assignments (for contacts, for eg) so exception.
  --
  begin
    --
    select ass.assignment_id
    into   l_assignment_id
    from   per_assignments_f ass
    where  ass.person_id = P_PERSON_ID
    FOR UPDATE;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    --
    delete from pay_personal_payment_methods p
    where  p.assignment_id = l_assignment_id;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  begin
    --
    delete from per_assignment_budget_values_f v
    where  v.assignment_id = l_assignment_id;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  begin
    delete from per_addresses a
    where  a.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 80);
  end if;
  --
  begin
    delete from per_phones a
    where  a.parent_id = P_PERSON_ID
    and    a.parent_table = 'PER_ALL_PEOPLE_F';
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 90);
  end if;
  --
  begin
    delete from pay_cost_allocations_f a
    where  a.assignment_id = l_assignment_id;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 100);
  end if;
  --
  begin
    delete from pay_element_entry_values_f v
    where  v.element_entry_id in
          (select e.element_entry_id
           from   pay_element_entries_f e
           where  e.assignment_id = l_assignment_id);
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 110);
  end if;
  --
  begin
    delete from pay_run_results r
    where  r.source_type = 'E'
    and    r.source_id in
          (select e.element_entry_id
           from   pay_element_entries_f e
           where  e.assignment_id = l_assignment_id);
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 120);
  end if;
  --
  begin
    delete from pay_element_entries_f e
    where  e.assignment_id = l_assignment_id;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 130);
  end if;
  --
  --  No exception, should succeed.
  --
  begin
    delete from per_assignments_f ass
    where  ass.assignment_id = l_assignment_id;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 140);
  end if;
  --
  begin
    delete from per_periods_of_service p
    where  p.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 150);
  end if;
  --
  begin
    delete from per_applications a
    where  a.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  --  Added this delete for quickhire checklists
  --
  if g_debug then
    hr_utility.set_location(l_proc, 160);
  end if;
  --
  begin
    delete from per_checklist_items
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  -- End addition for quickhire checklists
  --
  --
  if g_debug then
    hr_utility.set_location(l_proc, 170);
  end if;
  --
  close LOCK_PERSON_ROWS;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 180);
  end if;
  --
  begin
    delete from per_people_f
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 190);
  end if;
  --
  begin
    delete from per_periods_of_placement p
    where  p.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
  begin
    for attached_docs_rec in attached_docs_cursor1
      LOOP
        if attached_docs_cursor1%NOTFOUND then
           return;
        end if;
        l_attached_document_id := attached_docs_rec.attached_document_id;
        open delattachments_cursor1 (l_attached_document_id);
           FETCH delattachments_cursor1 into deldatarec1;
           if delattachments_cursor1%NOTFOUND then
              return;
           end if;
        l_datatype_id := deldatarec1.datatype_id ;
        FND_ATTACHED_DOCUMENTS3_PKG.delete_row (l_attached_document_id,
                                                l_datatype_id,
                                                'Y' );
        CLOSE delattachments_cursor1;
      END LOOP;
        exception
        when NO_DATA_FOUND then null;
  end;
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
END people_default_deletes;
--
-- ----------------------------------------------------------------------------
-- |---------------------< applicant_default_deletes >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--
-- Delete routine for deleting information set up as default when
-- applicants are entered.  Used primarily for delete on PERREAQE
-- (Applicant Quick Entry). The strong_predel_validation should first be
-- performed to ensure that no additional info (apart from default) has
-- been entered.
--
PROCEDURE applicant_default_deletes(p_person_id IN number)
IS
  --
  l_assignment_id      number(15);
  l_proc               varchar2(72) := g_package||'applicant_default_deletes';
  l_pk1_value2         varchar2(72) := p_person_id;

  --
  CURSOR lock_person_rows IS
  SELECT person_id
  FROM   per_people_f
  WHERE  person_id = P_PERSON_ID
  FOR    UPDATE;
  --
  CURSOR   attached_docs_cursor2  IS
    SELECT attached_document_id
    FROM   fnd_attached_documents
    WHERE  pk1_value = l_pk1_value2;
--
   cursor delattachments_cursor2 (x_attached_document_id in number) is
        select datatype_id
          from fnd_attached_docs_form_vl
         where attached_document_id =  x_attached_document_id;
--
  l_datatype_id             number;
  l_attached_document_id    number;
  deldatarec2               delattachments_cursor2%ROWTYPE;
--
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  hr_person_internal.person_existance_check(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 10);
  end if;
  --
  open LOCK_PERSON_ROWS;
  --
  --  Now start cascade.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  begin
    delete  from per_person_list l
    where    l.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  --  Can select into a variable as only one assignment should exist (as
  --  strong_predel_validation has already been performed).
  --
  begin
    select ass.assignment_id
    into   l_assignment_id
    from   per_assignments_f ass
    where  ass.person_id = P_PERSON_ID
    FOR    UPDATE;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 40);
  end if;
  --
  begin
    delete from per_addresses a
    where  a.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    delete from per_phones a
    where  a.parent_id = P_PERSON_ID
    and    a.parent_table = 'PER_ALL_PEOPLE_F';
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 60);
  end if;
  --
  begin
    delete from per_assignments_f ass
    where  ass.assignment_id = l_assignment_id;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  begin
    delete from per_applications a
    where  a.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  --  Added this delete for quickhire checklists
  --
  if g_debug then
    hr_utility.set_location(l_proc, 80);
  end if;
  --
  begin
    delete from per_checklist_items
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  -- End addition for quickhire checklists
  --
  --  Added this delete for PTU
  --
  if g_debug then
    hr_utility.set_location(l_proc, 90);
  end if;
  --
  begin
    delete from per_person_type_usages_f
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  -- End addition for PTU
  --
  if g_debug then
    hr_utility.set_location(l_proc, 100);
  end if;
  --
  close LOCK_PERSON_ROWS;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 110);
  end if;
  --
  begin
    delete from per_people_f
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
  begin
    for attached_docs_rec in attached_docs_cursor2
      LOOP
        if attached_docs_cursor2%NOTFOUND then
            return;
        end if;
        l_attached_document_id := attached_docs_rec.attached_document_id;
        open delattachments_cursor2 (l_attached_document_id);
        FETCH delattachments_cursor2 into deldatarec2;
          if delattachments_cursor2%NOTFOUND then
             return;
          end if;
          l_datatype_id := deldatarec2.datatype_id ;
          FND_ATTACHED_DOCUMENTS3_PKG.delete_row (l_attached_document_id,
                                                  l_datatype_id,
                                                  'Y' );
        CLOSE delattachments_cursor2;
      END LOOP;
        exception
        when NO_DATA_FOUND then null;
  end;
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
END applicant_default_deletes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_person (p_person_id          IN number
                        ,p_effective_date     IN date)
IS
  --
    l_pk1_value3   varchar2(72) := p_person_id;
  --
  CURSOR csr_this_persons_contacts IS
  SELECT contact_person_id,
         contact_relationship_id
  FROM   per_contact_relationships
  WHERE  person_id = P_PERSON_ID;
  --
  CURSOR csr_lock_person_rows IS
  SELECT person_id
  FROM   per_people_f
  WHERE  person_id = P_PERSON_ID
  FOR    UPDATE;
  --
  CURSOR csr_lock_assignment_rows IS
  SELECT assignment_id
  FROM   per_assignments_f
  WHERE  person_id    = P_PERSON_ID
  FOR    UPDATE;
  --
  CURSOR csr_delete_components IS
  SELECT pp.pay_proposal_id
  FROM   per_pay_proposals pp,
         per_assignments_f pa
  WHERE  pa.person_id = P_PERSON_ID
  AND    pa.assignment_id = pp.assignment_id
  FOR    UPDATE;
  --
  CURSOR csr_medical_assessment_records IS
  SELECT medical_assessment_id,
         object_version_number
  FROM   per_medical_Assessments pma
  WHERE  pma.person_id = p_person_id;
  --
  CURSOR csr_work_incidents IS
  SELECT incident_id, object_version_number
  FROM   per_work_incidents
  WHERE  person_id =  p_person_id;
  --
  CURSOR csr_disabilities IS
  SELECT disability_id, object_version_number,
         effective_start_date, effective_end_date
  FROM   per_disabilities_f
  WHERE  person_id = p_person_id;
  --
  CURSOR csr_roles IS
  SELECT role_id, object_version_number
  FROM   per_roles
  WHERE  person_id= p_person_id;
  --
  CURSOR csr_ptu IS
  SELECT distinct person_type_usage_id
  FROM   per_person_type_usages_f ptu
  WHERE  ptu.person_id = p_person_id
  ORDER BY person_type_usage_id;
  --
  CURSOR csr_asg IS
  SELECT distinct assignment_id
  FROM   per_assignments_f
  WHERE  person_id = p_person_id;
  --
  CURSOR   attached_docs_cursor  IS
    SELECT attached_document_id
    FROM   fnd_attached_documents
    WHERE  pk1_value = l_pk1_value3;
--
   cursor delattachments_cursor (x_attached_document_id in number) is
        select datatype_id
          from fnd_attached_docs_form_vl
         where attached_document_id =  x_attached_document_id;
  --
  --
  -- local variables
  --
  l_dummy                 number(3) := null;  /* Bug 941 591 */
  l_proposal_id           number;
  l_review_cursor         number;
  l_rows_processed        number;
  l_incident_id           per_work_incidents.person_id%TYPE;
  l_disability_id         per_disabilities_f.disability_id%TYPE;
  l_object_version_no     per_disabilities_f.object_version_number%TYPE;
  l_ovn_roles             per_roles.object_version_number%TYPE;
  l_role_id               per_roles.role_id%TYPE;
  --
  l_person_type_usage_id  per_person_type_usages_f.person_type_usage_id%TYPE;
  l_effective_date        date;
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
  -- bug fix 3732129 starts here.
  -- to improve performance assignment id fetched into a pl/sql table.
  --
  type assignmentid is table of per_all_assignments_f.assignment_id%type
  index by binary_integer;
  --
  l_assignment_id assignmentid;
  l_proc varchar2(72) := g_package||'delete_person';
  --
  l_datatype_id             number;
  l_attached_document_id    number;
  deldatarec                delattachments_cursor%ROWTYPE;
  --
  -- Fix for 4490489 starts here
  l_party_id    number(15);
  l_count       number(15);

  -- Fix for 4490489 ends here
BEGIN
  --
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 10);
  end if;
  --
  --  Lock person rows, delete at end of procedure.
  --
  OPEN csr_lock_person_rows;
  --
  --  Now start cascade.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- bug fix 3732129 starts here.
  -- fetching the assignment ids into a pl/sql table.
  --
  OPEN  csr_asg;
  FETCH csr_asg bulk collect into l_assignment_id;
  CLOSE csr_asg;
  --
  -- bug fix 3732129 ends here.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
  end if;
  --
  begin
    --
    update per_requisitions r
    set    r.person_id    = null
    where  r.person_id    = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 40);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 50);
  end if;
  --
  begin
    -- bug fix 3732129.
    -- Delete statement modified to improve performance.
    delete from per_letter_request_lines l
    where  l.person_id = P_PERSON_ID;
    --
    forall i in 1..l_assignment_id.count
        delete from per_letter_request_lines l
        where l.assignment_id = l_assignment_id(i);
    --
  exception
    when NO_DATA_FOUND then
        if g_debug then
          hr_utility.set_location(l_proc, 60);
        end if;
  end;
  --
  --  Leave per_letter_requests for the moment - may not be necessary to
  --  delete the parent with no children which requires some work with
  --  cursors.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 70);
  end if;
  --
  begin
    --
    delete from per_absence_attendances a
    where  a.person_id    = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 80);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 90);
  end if;
  --
  begin
    --
    update per_absence_attendances a
    set    a.authorising_person_id    = null
    where  a.authorising_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 100);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 110);
  end if;
  --
  begin
    --
    update    per_absence_attendances a
    set    a.replacement_person_id    = null
    where     a.replacement_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 120);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 130);
  end if;
  --
  begin
    --
    delete from per_person_analyses a
    where  a.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 140);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 150);
  end if;
  --
  --  Delete of per_periods_of_service at end after delete of
  --  per_assignments_f.
  --
  begin
    --
    update per_periods_of_service p
    set    p.termination_accepted_person_id = null
    where  p.termination_accepted_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 160);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 170);
  end if;
  --
  begin
    --
    update per_recruitment_activities r
    set    r.authorising_person_id    = null
    where  r.authorising_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 180);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 190);
  end if;
  --
  begin
    --
    update per_recruitment_activities r
    set    r.internal_contact_person_id = null
    where    r.internal_contact_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 200);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 210);
  end if;
  --
  -- Bug 4873360 fix for performance repository sql id 14960331.
  -- Rewrote the delete query commented out below (and already once tuned for
  -- bug 3619599) to avoid a merge join cartesian and a full table scan on
  -- PER_PARTICIPANTS, HR_QUEST_ANSWER_VALUES and PER_APPRAISALS
  --
  -- Broke query into two peices using conditional logic in a pl/sql block to
  -- see if delete needs to be run.
  --
  begin -- Delete from HR_QUEST_ANSWER_VALUES
  begin -- Delete from HR_QUEST_ANSWER_VALUES: PARTICIPANTS
    begin
     select 1
     into l_dummy
     from sys.dual
     where exists (
            select null
              from per_participants par
             where par.person_id = P_PERSON_ID);
    exception
     when NO_DATA_FOUND then
       l_dummy := null;
       if g_debug then
         hr_utility.set_location(l_proc, 211);
       end if;
    end;
     if l_dummy = 1
     then
        l_dummy := null;
        delete from hr_quest_answer_values qsv2
         where qsv2.quest_answer_val_id in
       (select qsv.quest_answer_val_id
          from hr_quest_answer_values qsv
              ,hr_quest_answers qsa
              ,per_participants par
          where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
            and qsa.type_object_id = par.participant_id
            and qsa.type = 'PARTICIPANT'
            and par.person_id = P_PERSON_ID);
      end if;
      if g_debug then
         hr_utility.set_location(l_proc, 215);
      end if;
   end;  -- Delete from HR_QUEST_ANSWER_VALUES: PARTICIPANTS
   begin -- Delete from HR_QUEST_ANSWER_VALUES: APPRAISALS
    begin
     select 2
     into l_dummy
     from sys.dual
     where exists (
            select null
                  from per_appraisals apr
                 where (apr.appraiser_person_id = P_PERSON_ID
            or  apr.appraisee_person_id = P_PERSON_ID));
    exception
      when NO_DATA_FOUND then
       l_dummy := null;
       if g_debug then
         hr_utility.set_location(l_proc, 220);
       end if;
    end;
     if l_dummy = 2
     then
        l_dummy := null;
        delete from hr_quest_answer_values qsv2
         where qsv2.quest_answer_val_id in
       (select qsv.quest_answer_val_id
          from hr_quest_answer_values qsv
              ,hr_quest_answers qsa
              ,per_appraisals apr
         where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
         and   qsa.type_object_id = apr.appraisal_id
         and   qsa.type='APPRAISAL'
         and   (apr.appraisee_person_id = P_PERSON_ID
         or     apr.appraiser_person_id = P_PERSON_ID));
       if g_debug then
         hr_utility.set_location(l_proc, 221);
       end if;
   end if;
   end; -- Delete from HR_QUEST_ANSWER_VALUES: APPRAISALS
   end; -- Delete from HR_QUEST_ANSWER_VALUES
-- original sql.
/*    -- Delete from HR_QUEST_ANSWER_VALUES
    delete from hr_quest_answer_values qsv2
    where qsv2.quest_answer_val_id in
          (select qsv.quest_answer_val_id
           from   hr_quest_answer_values qsv
                 ,hr_quest_answers qsa
                 ,per_appraisals apr
                 ,per_participants par
           where qsv.questionnaire_answer_id = qsa.questionnaire_answer_id
           and   (qsa.type_object_id = apr.appraisal_id
                  and qsa.type='APPRAISAL'
                  and (apr.appraisee_person_id = P_PERSON_ID
                        or  apr.appraiser_person_id = P_PERSON_ID))
           or    (qsa.type_object_id = par.participant_id
                  and qsa.type='PARTICIPANT'
                  and par.person_id = P_PERSON_ID)
          ); -- Fix 3619599
     exception
     when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 220);
       end if;
     end;  */
  -- Now delete from HR_QUEST_ANSWERS
  begin
    --
    -- Fix 3619599 and 4894116
       delete from hr_quest_answers qsa2
       where  qsa2.questionnaire_answer_id in
           (
            select qsa.questionnaire_answer_id
            from   hr_quest_answers qsa
                  ,per_appraisals apr
            where  (qsa.type_object_id = apr.appraisal_id
                    and qsa.type='APPRAISAL'
                    and (apr.appraiser_person_id = p_person_id
                          or  apr.appraisee_person_id = p_person_id))
            Union  All

            select qsa.questionnaire_answer_id
            from   hr_quest_answers qsa
                  ,per_participants par
            where  (qsa.type_object_id = par.participant_id
                    and qsa.type='PARTICIPANT'
                    and  par.person_id =  p_person_id )
           ) ;

    --
  exception
     when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 230);
       end if;
  end;
  --
  -- Now delete from per_participants
  begin

      -- Fix 4894116
       delete from per_participants par2
       where  par2.participant_id in
       (  select par.participant_id
          from   per_participants par
          where  par.person_id =  P_PERSON_Id
          union all
          select  par.participant_id
          from    per_participants par
                 ,per_appraisals apr
          where
                 (par.participation_in_column = 'APPRAISAL_ID'
                  and par.participation_in_table = 'PER_APPRAISALS'
                  and participation_in_id = apr.appraisal_id
                  and (apr.appraisee_person_id = P_PERSON_ID
                       or apr.appraiser_person_id = p_person_id)
                  )
           );
  --
  exception
     when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 240);
       end if;
  end;
  --
  -- Now delete from per_appraisals
  --
  begin
    --
    delete from per_appraisals apr
    where  apr.appraiser_person_id = P_PERSON_ID
    or     apr.appraisee_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 250);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 260);
  end if;
  --
  hr_security.delete_per_from_list(P_PERSON_ID);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 270);
  end if;
  --
  begin
    --
    update per_vacancies v
    set    v.recruiter_id = null
    where  v.recruiter_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 280);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 290);
  end if;
  --
  begin
    --
    update per_assignments_f ass
    set    ass.person_referred_by_id = null
    where  ass.person_referred_by_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 300);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 310);
  end if;
  --
  begin
    --
    update per_assignments_f a
    set    a.recruiter_id = null
    where  a.recruiter_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 320);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 330);
  end if;
  --
  begin
    --
    update per_assignments_f a
    set    a.supervisor_id = null
    where  a.supervisor_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 340);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 350);
  end if;
  --
  --  LOCK ASSIGNMENTS NOW: have to use cursor as cannot return >1 row for
  --  'into' part of PL/SQL.
  --
  OPEN csr_lock_assignment_rows;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 360);
  end if;
  --
  begin
    --
    --  Bug 349818. Delete from per_pay_proposal_components before
    --  deleting from the parent record in per_pay_proposals to
    --  maintain referential integrity, using the cursor csr_delete_components
    --  and the original per_pay_proposals delete.
    --
    OPEN csr_delete_components;
    LOOP
      FETCH csr_delete_components INTO l_proposal_id;
      EXIT WHEN csr_delete_components%NOTFOUND;
      DELETE FROM per_pay_proposal_components
      WHERE pay_proposal_id = l_proposal_id;
    END LOOP;
    --
    CLOSE csr_delete_components;
    --
    --  Now delete the parent proposal record.
    --
    delete from per_pay_proposals p
    where  exists (
           select null
           from   per_assignments_f ass
           where  ass.assignment_id = p.assignment_id
           and    ass.person_id     = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 370);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 380);
  end if;
  --
  begin
    --
    delete from pay_personal_payment_methods_f m
    where  m.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id  = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 390);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 400);
  end if;
  --
  begin
    --
    delete from per_assignment_budget_values_f a
    where  a.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 410);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 420);
  end if;
  --
  begin
    --
    delete from per_assignment_extra_info a
    where  a.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 430);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 440);
  end if;
  --
  begin
    --
    delete from per_secondary_ass_statuses a
    where  a.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 450);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 460);
  end if;
  --
  --  Delete COBRA references and then any contact relationships. COBRA
  --  must be deleted first as PER_COBRA_COV_ENROLLMENTS has a
  --  contact_relationship_id which may be constrained later.
  --
  begin
    --
    delete from per_cobra_coverage_benefits c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
           where  exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = c.assignment_id
                  and    ass.person_id = P_PERSON_ID)
          );
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 470);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 480);
  end if;
  --
  begin
    --
    delete from per_cobra_coverage_benefits c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
                 ,per_contact_relationships r
           where  r.contact_person_id = P_PERSON_ID
           and    c.contact_relationship_id = r.contact_relationship_id
           and    exists
                  (select  null
                   from    per_assignments_f ass
                   where   ass.assignment_id = c.assignment_id
                   and     ass.person_id = r.person_id)
          );
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 490);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 500);
  end if;
  --
  begin
    --
    delete from per_cobra_coverage_statuses c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
           where  exists
           (select  null
            from    per_assignments_f ass
            where   ass.assignment_id = c.assignment_id
            and     ass.person_id = P_PERSON_ID)
        );
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 510);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 520);
  end if;
  --
  begin
    --
    delete from per_cobra_coverage_statuses c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
                 ,per_contact_relationships r
           where  r.contact_person_id = P_PERSON_ID
           and    c.contact_relationship_id = r.contact_relationship_id
           and    exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = c.assignment_id
                  and    ass.person_id = r.person_id)
          );
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 530);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 540);
  end if;
  --
  begin
    --
    delete from per_sched_cobra_payments c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
           where  exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = c.assignment_id
                  and    ass.person_id = P_PERSON_ID)
          );
    --
  exception
    when NO_DATA_FOUND then
      if g_debug then
        hr_utility.set_location(l_proc, 550);
      end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 560);
  end if;
  --
  begin
    --
    delete from per_sched_cobra_payments c2
    where  c2.cobra_coverage_enrollment_id in
          (select c.cobra_coverage_enrollment_id
           from   per_cobra_cov_enrollments c
                 ,per_contact_relationships r
           where  r.contact_person_id = P_PERSON_ID
           and    c.contact_relationship_id = r.contact_relationship_id
           and    exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = c.assignment_id
                  and    ass.person_id = r.person_id)
          );
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 570);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 580);
  end if;
  --
  begin
    --
    delete from per_cobra_cov_enrollments c
    where  c.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 590);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 600);
  end if;
  --
  begin
    --
    delete from per_cobra_cov_enrollments c
    where  exists
          (select null
           from   per_contact_relationships r
           where  r.contact_person_id = P_PERSON_ID
           and    c.contact_relationship_id = r.contact_relationship_id
           and exists
              (select null
               from   per_assignments_f ass
               where  ass.assignment_id = c.assignment_id
               and    ass.person_id = r.person_id)
          );
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 610);
       end if;
  end;
  --
  --Bug# 3026024 Start Here
  --Description : Delete the entry in the table ben_covered_dependents_f for the
  --              contact person whom is getting deleted.
  --
  --
  if g_debug then
    hr_utility.set_location(l_proc, 620);
  end if;
  --
  begin
    --
    delete from ben_covered_dependents_f c
    where  c.contact_relationship_id in
          (select r.contact_relationship_id
           from per_contact_relationships r
           where r.contact_person_id = p_person_id
          );
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 630);
       end if;
  end;
  --
  --Bug# 3026024 End Here
  --
  --
  --  If this person has any contacts then check whether they have had any
  --  extra info entered for them. If they have not then delete the
  --  contacts as well. If they do have extra info then just delete the
  --  relationship.
  --
  -- NB If b is created as a contact of b then 2 contact relationships are
  -- are created:  a,b  and  b,a   so that they can be queried in either
  -- direction. Hence must delete both here.
  --
  if g_debug then
    hr_utility.set_location(l_proc, 640);
  end if;
  --
  begin
    --
    select count(*)
    into   l_dummy
    from   per_contact_relationships r
    where  r.person_id = P_PERSON_ID;
    --
    if l_dummy > 0 then
      for EACH_CONTACT in csr_this_persons_contacts loop
        --
        delete from per_contact_relationships r
        where  (r.person_id = P_PERSON_ID
                and r.contact_person_id = EACH_CONTACT.CONTACT_PERSON_ID)
        or     (r.person_id = EACH_CONTACT.CONTACT_PERSON_ID
                and    r.contact_person_id = P_PERSON_ID);
        --
        hr_person_internal.check_contact(P_PERSON_ID,
                    EACH_CONTACT.CONTACT_PERSON_ID,
                    EACH_CONTACT.CONTACT_RELATIONSHIP_ID,
                    p_effective_date);
        --
      end loop;
      --
    end if;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 650);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 660);
  end if;
  --
  begin
    --
    delete from per_contact_relationships r
    where  r.contact_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 670);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 680);
  end if;
  --
  begin
    --
    delete from per_addresses a
    where  a.person_id    = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 690);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 700);
  end if;
  --
  begin
    --
    delete from per_phones a
    where  a.parent_id = P_PERSON_ID
    and    a.parent_table = 'PER_ALL_PEOPLE_F';
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 710);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 720);
  end if;
  --
  -- we must do this delete in dynamic sql because the per_performance_reviews
  -- table will not exist if the database has not been upgraded to new salary
  -- admin (introduced April 1998). The procedure would not compile if this
  -- was not dynamic. if the table is not found then the error (which starts
  -- with 'ORA-00942') is ignored.
  --
  begin
    --
    l_review_cursor:=dbms_sql.open_cursor;
    dbms_sql.parse(l_review_cursor,'DELETE from PER_PERFORMANCE_REVIEWS
                                     where person_id=:x',dbms_sql.v7);
    dbms_sql.bind_variable(l_review_cursor, ':x',P_PERSON_ID);
    l_rows_processed:=dbms_sql.execute(l_review_cursor);
    dbms_sql.close_cursor(l_review_cursor);
    --
  exception
    when NO_DATA_FOUND then dbms_sql.close_cursor(l_review_cursor);
    when OTHERS then
    dbms_sql.close_cursor(l_review_cursor);
    --
    if(substr(sqlerrm,0,9)<>'ORA-00942') then
        raise;
    end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 730);
  end if;
  --
  --  About to delete interview events for assignments. However, must
  --  first delete bookings (interviewers) for those events.
  --
  begin
    -- bug fix 3732129.
    -- Delete statement modified to improve performance.
    --
    forall i in 1..l_assignment_id.count
       delete from per_bookings b
        where b.event_id in
             (select e.event_id
              from   per_events e
              where  e.assignment_id = l_assignment_id(i));

        /*delete  from per_bookings b
        where    b.event_id in
        (select    e.event_id
         from    per_events e
         where    exists (
            select    null
            from    per_assignments_f ass
            where    ass.assignment_id    = e.assignment_id
            and    ass.person_id         = P_PERSON_ID)
        );*/
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 740);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 750);
  end if;
  --
  begin
    -- bug fix 3732129.
    -- Delete statement modified to improve performance.
    --
    forall i in 1..l_assignment_id.count
      delete from per_events e
      where  e.assignment_id = l_assignment_id(i);

       /* delete    from per_events e
        where    e.assignment_id in (
                    select ass.assignment_id
                    from   per_assignments_f ass
                    where  ass.person_id           = P_PERSON_ID);*/
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 760);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 770);
  end if;
  --
  begin
    --
    update per_events e
    set    e.internal_contact_person_id = null
    where  e.internal_contact_person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 780);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 790);
  end if;
  --
  begin
    --
    delete from per_bookings b
    where  b.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 800);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 810);
  end if;
  --
  begin
    --
    delete from per_quickpaint_result_text q
    where  q.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 820);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 830);
  end if;
  --
  --  Validation has already been performed against
  --  hr_assignment_set_amendments in weak_predel_validation.
  --
  begin
    --
    delete from hr_assignment_set_amendments h
    where  h.assignment_id in
    (select ass.assignment_id
     from   per_assignments_f ass
     where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 840);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 850);
  end if;
  --
  begin
    --
    delete from pay_cost_allocations_f a
    where  a.assignment_id in
          (select  ass.assignment_id
           from    per_assignments_f ass
           where   ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 860);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 870);
  end if;
  --
  begin
    --
    delete from per_spinal_point_placements_f p
    where  p.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 880);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 890);
  end if;
  --
  --  Validation has already been performed against
  --  pay_assignment_actions in weak_predel_validation.
  --
  begin
    --
    delete from pay_assignment_actions a
    where  a.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 900);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 910);
  end if;
  --
  begin
    --
    delete from pay_assignment_latest_balances b
    where  b.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 920);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 930);
  end if;
  --
  begin
    -- bug fix 3732129
    -- Delete statement modified to improve performance.
    --
    forall i in 1..l_assignment_id.count
        delete from pay_assignment_link_usages_f u
        where  u.assignment_id  = l_assignment_id(i);

        /*delete  from pay_assignment_link_usages_f u
        where
        u.assignment_id in (
                   select ass.assignment_id
                   from per_assignments_f ass
                   where ass.person_id = P_PERSON_ID); */
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 940);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 950);
  end if;
  --
  begin
    --
    delete from pay_element_entry_values_f v
    where  v.element_entry_id in
          (select e.element_entry_id
           from   pay_element_entries_f e
           where  exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = e.assignment_id
                  and    ass.person_id = P_PERSON_ID)
          );
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 960);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 970);
  end if;
  --
  begin
    --
    delete from pay_run_results r
    where  r.source_type = 'E'
    and    r.source_id in
          (select e.element_entry_id
           from   pay_element_entries_f e
           where  exists
                 (select null
                  from   per_assignments_f ass
                  where  ass.assignment_id = e.assignment_id
                  and    ass.person_id = P_PERSON_ID)
          );
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 980);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 990);
  end if;
  --
  begin
    --
    delete from pay_element_entries_f e
    where  e.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = P_PERSON_ID);
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 10);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Rmonge Bug 1686922 22-FEB-2002
  -- Tax records were not being deleted. Therefore, there were orphans rows in
  -- the pay_us_fed_tax_rules_f, pay_us_state_tax_rules_f,
  -- pay_us_county_tax_rules_f, and pay_us_city_tax_rules_f.
  --
  begin
    --
    Delete pay_us_emp_fed_tax_rules_f peft
    Where  peft.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = p_person_id );
    --
  exception
    when no_data_found then
       if g_debug then
         hr_utility.set_location(l_proc, 30);
       end if;
  end;
  --
  begin
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    Delete pay_us_emp_state_tax_rules_f pest
    Where  pest.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = p_person_id );
    --
  exception
    when no_data_found then
       if g_debug then
         hr_utility.set_location(l_proc, 50);
       end if;
  end;
  --
  begin
    --
    if g_debug then
      hr_utility.set_location(l_proc, 60);
    end if;
    --
    Delete pay_us_emp_county_tax_rules_f pect
    Where  pect.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = p_person_id );
    --
  exception
    when no_data_found then
       if g_debug then
         hr_utility.set_location(l_proc, 70);
       end if;
  end;
  --
  begin
    --
    if g_debug then
      hr_utility.set_location(l_proc, 80);
    end if;
    --
    Delete pay_us_emp_city_tax_rules_f pecit
    Where  pecit.assignment_id in
          (select ass.assignment_id
           from   per_assignments_f ass
           where  ass.person_id = p_person_id );
    --
  exception
    when no_data_found then
       if g_debug then
         hr_utility.set_location(l_proc, 90);
       end if;
  end;
  --  Finished, now unlock assignments and delete them.
  --
  close csr_lock_assignment_rows;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 100);
  end if;
  --
  begin
    --
    delete from per_all_assignments_f a
    where  a.person_id  = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 110);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 120);
  end if;
  --
  begin
    --
    delete from per_periods_of_service p
    where  p.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 130);
       end if;
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 140);
  end if;
  --
  begin
    --
    delete from per_applications a
    where  a.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 150);
       end if;
  end;
  --
  -- 03/18/98 Bug #642566
  -- delete per_people_extra_info records
  if g_debug then
    hr_utility.set_location(l_proc, 160);
  end if;
  --
  begin
    --
    delete from per_people_extra_info  e
    where  e.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 170);
       end if;
  end;
  -- 03/18/98 Change Ends
  --
  -- 03/18/98 Change Ends
  --
  -- 28/5/98
  -- Add delete from per_person_type_usages_f
  if g_debug then
    hr_utility.set_location(l_proc, 180);
  end if;
  --
  for ptu_rec in csr_ptu loop
    --
    select min(ptu1.effective_start_date)
    into   l_effective_date
    from   per_person_type_usages_f ptu1
    where  ptu1.person_type_usage_id = ptu_rec.person_type_usage_id;
    --
    select ptu2.object_version_number
    into   l_object_version_number
    from   per_person_type_usages_f ptu2
    where  ptu2.person_type_usage_id = ptu_rec.person_type_usage_id
    and    ptu2.effective_start_date = l_effective_date;
    --
    if g_debug then
     --
     hr_utility.set_location('l_person_type_usage_id = '||to_char(ptu_rec.person_type_usage_id),44);
     hr_utility.set_location('l_effective_date  = '||to_char(l_effective_date,'DD/MM/YYYY'),44);
     hr_utility.set_location('l_object_version_number = '||to_char(l_object_version_number),44);
     --
    end if;
    begin
      --
--    hr_per_type_usage_internal.maintain_ptu(
--                 p_person_id               => p_person_id,
--                 p_action                  => 'DELETE',
--                 p_period_of_service_id    => NULL,
--                 p_actual_termination_date => NULL,
--                 p_business_group_id       => NULL,
--                 p_date_start              => NULL,
--                 p_leaving_reason          => NULL,
--                 p_old_date_start          => NULL,
--                 p_old_leaving_reason      => NULL);

      hr_per_type_usage_internal.delete_person_type_usage
                (p_person_type_usage_id  => ptu_rec.person_type_usage_id
                ,p_effective_date        => l_effective_date
                ,p_datetrack_mode        => 'ZAP'
                ,p_object_version_number => l_object_version_number
                ,p_effective_start_date  => l_effective_start_date
                ,p_effective_end_date    => l_effective_end_date
                );
    exception
        when NO_DATA_FOUND then null;
    end;
    --
  end loop;
  --
  -- delete per_person_dlvry_methods
  if g_debug then
    hr_utility.set_location(l_proc, 190);
  end if;
  --
  begin
    --
    delete from per_person_dlvry_methods
    where  person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  --  Added this delete for quickhire checklists
  --
  if g_debug then
    hr_utility.set_location(l_proc, 200);
  end if;
  begin
    --
    delete from per_checklist_items
    where person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then null;
  end;
  --
  -- End addition for quickhire checklists
  --
  -- delete per_qualification and per_subjects_taken records
  if g_debug then
    hr_utility.set_location(l_proc, 210);
  end if;
  --
  begin
  -- Fix for 4490489 starts here
  --
  select distinct party_id into l_party_id
    from per_all_people_f
   where person_id = p_person_id;
  --
  select count(distinct person_id) into l_count
    from per_all_people_f
   where party_id = l_party_id;
  --
  if l_count = 1  then
  --PMFLETCH Added delete from tl table
  --
    delete from per_subjects_taken_tl st
          where st.subjects_taken_id IN
            (select s.subjects_taken_id
               from per_subjects_taken s
                   ,per_qualifications q
             where q.party_id = l_party_id
               and s.qualification_id = q.qualification_id
         );
    --
    if g_debug then
      hr_utility.set_location(l_proc, 220);
    end if;
    --
    delete from per_subjects_taken s
          where s.qualification_id in
            (select qualification_id
               from per_qualifications
               where party_id = l_party_id );
    --
    if g_debug then
      hr_utility.set_location(l_proc, 230);
    end if;
    --PMFLETCH Added delete from tl table
    delete from per_qualifications_tl  qt
           where qt.qualification_id in
             (select q.qualification_id
               from per_qualifications q
               where q.party_id = l_party_id);
    --
    if g_debug then
      hr_utility.set_location(l_proc, 240);
    end if;
    --
    delete from per_qualifications  q
         where q.party_id = l_party_id;
    --
  end if;
--
  exception
    when NO_DATA_FOUND then
    if g_debug then
       hr_utility.set_location(l_proc, 250);
    end if;
  end;
--
  -- Fix for 4490489 ends here
--
--
    --PMFLETCH Added delete from tl table
 /*   delete from per_subjects_taken_tl st
    where st.subjects_taken_id IN
         (select s.subjects_taken_id
          from   per_subjects_taken s
                ,per_qualifications q
          where  q.person_id = P_PERSON_ID
          and    s.qualification_id = q.qualification_id
         );
    --
    if g_debug then
      hr_utility.set_location(l_proc, 220);
    end if;
    --
    delete from per_subjects_taken s
    where s.qualification_id in
         (select qualification_id
          from   per_qualifications
          where  person_id = P_PERSON_ID );
    --
    if g_debug then
      hr_utility.set_location(l_proc, 230);
    end if;
    --PMFLETCH Added delete from tl table
    delete from per_qualifications_tl  qt
    where qt.qualification_id in
         (select q.qualification_id
          from   per_qualifications q
          where  q.person_id = P_PERSON_ID);
    --
    if g_debug then
      hr_utility.set_location(l_proc, 240);
    end if;
    --
    delete  from per_qualifications  q
    where   q.person_id = P_PERSON_ID;
    --
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 250);
       end if;
  end; */
  --
  close csr_lock_person_rows;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 260);
  end if;

--changes for 5166353 starts here
ben_person_delete.delete_ben_rows(P_PERSON_ID);
--changes for 5166353 ends here
 --
  begin
    --
    delete    from per_all_people_f
    where    person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 270);
       end if;
  end;
  --
  -- Now remove contracts
  --
  hr_contract_api.maintain_contracts (
      P_PERSON_ID,
      NULL,
      NULL);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 280);
  end if;
  --
  -- Now remove Medical Assessments
  --
  FOR mea_rec IN csr_medical_assessment_records LOOP
    --
    per_medical_assessment_api.delete_medical_assessment
       (FALSE
       ,mea_rec.medical_assessment_id
       ,mea_rec.object_version_number);
     --
  END LOOP;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 290);
  end if;
  --
  --
  -- Now remove disabilities
  --
  open csr_disabilities;
  LOOP
    fetch csr_disabilities INTO l_disability_id, l_object_version_no, l_effective_start_date, l_effective_end_date;
    EXIT when csr_disabilities%NOTFOUND;
    per_disability_api.delete_disability(false,p_effective_date ,'ZAP',l_disability_id, l_object_version_no, l_effective_start_date, l_effective_end_date);
  END LOOP;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 300);
  end if;
  --
  --
  -- Now remove Work incidences
  --
  open csr_work_incidents;
  LOOP
    fetch  csr_work_incidents INTO l_incident_id, l_object_version_number;
    EXIT when csr_work_incidents%NOTFOUND;
    per_work_incident_api.delete_work_incident(false,l_incident_id, l_object_version_number);
  END LOOP;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 310);
  end if;
  --
  --
  --  Now remove Supplementary Roles
  --
  OPEN csr_roles;
  LOOP
    fetch csr_roles into l_role_id, l_ovn_roles;
    EXIT when csr_roles%notfound;
    per_supplementary_role_api.delete_supplementary_role(false, l_role_id, l_ovn_roles);
  END LOOP;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 320);
  end if;
  --
  --
  begin
    delete from per_periods_of_placement p
    where  p.person_id = P_PERSON_ID;
  exception
    when NO_DATA_FOUND then
       if g_debug then
         hr_utility.set_location(l_proc, 330);
       end if;
  end;
  --
  --
  --  Now remove Attachments
  --
  begin
    for attached_docs_rec in attached_docs_cursor
      LOOP
         if attached_docs_cursor%NOTFOUND then
            return;
         end if;
         l_attached_document_id := attached_docs_rec.attached_document_id;
         open delattachments_cursor (l_attached_document_id);
         FETCH delattachments_cursor into deldatarec;
           if delattachments_cursor%NOTFOUND then
              return;
           end if;
         l_datatype_id := deldatarec.datatype_id ;
         FND_ATTACHED_DOCUMENTS3_PKG.delete_row (l_attached_document_id,
                                                 l_datatype_id,
                                                 'Y' );
         CLOSE delattachments_cursor;
      END LOOP;
        exception
         when NO_DATA_FOUND then null;
  end;
   --
  if g_debug then
    hr_utility.set_location('Leaving:'||l_proc, 999);
  end if;
  --
END delete_person;
end hr_person_internal;

/
