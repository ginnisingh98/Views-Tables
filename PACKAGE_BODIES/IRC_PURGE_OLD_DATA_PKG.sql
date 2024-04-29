--------------------------------------------------------
--  DDL for Package Body IRC_PURGE_OLD_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PURGE_OLD_DATA_PKG" as
/* $Header: ircpurge.pkb 120.3.12010000.9 2010/04/13 13:23:00 prasashe ship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< anonymize_candidate_data >--------------------|
-- ----------------------------------------------------------------------------
--
procedure anonymize_candidate_data
(
  p_party_id       in number
 ,p_effective_date in date
) is
--
  l_proc varchar2(72) := 'anonymize_candidate_data';
  l_person_ovn number;
  l_notif_pref_ovn number;
  l_notif_pref_id number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_full_name                 per_all_people_f.full_name%type;
  l_employee_number           per_all_people_f.employee_number%type;
  l_comment_id                number;
  l_name_combination_warning  boolean;
  l_assign_payroll_warning    boolean;
  l_orig_hire_warning         boolean;
  --
  cursor csr_update_person is
    select person_id, object_version_number,employee_number,effective_start_date
    from per_all_people_f
    where party_id = p_party_id;
  --
  cursor csr_update_notif_pref is
   select object_version_number,notification_preference_id
   from irc_notification_preferences
   where party_id = p_party_id;
--
begin
  --
  -- Update all the person records to Anonymous
  --
  hr_utility.set_location('Entering Anonymize Candidate Data:'||l_proc, 10);
  for rec_person in csr_update_person loop
    hr_utility.set_location(l_proc, 20);
    l_person_ovn := rec_person.object_version_number;
    l_employee_number := rec_person.employee_number;
    --
    /* call to hr_person_api.update_person to set the names to Anonymous */
    hr_person_api.update_person
    (
      p_effective_date               => rec_person.effective_start_date
     ,p_datetrack_update_mode        => 'CORRECTION'
     ,p_person_id                    => rec_person.person_id
     ,p_object_version_number        => l_person_ovn
     ,p_employee_number              => l_employee_number
     ,p_last_name                    => fnd_message.get_string
                                        ('PER','IRC_412172_ANONYMOUS_NAME')
     ,p_first_name                   => ''
     ,p_known_as                     => ''
     ,p_middle_names                 => ''
     ,p_previous_last_name           => ''
     ,p_effective_start_date         => l_effective_start_date
     ,p_effective_end_date           => l_effective_end_date
     ,p_full_name                    => l_full_name
     ,p_comment_id                   => l_comment_id
     ,p_name_combination_warning     => l_name_combination_warning
     ,p_assign_payroll_warning       => l_assign_payroll_warning
     ,p_orig_hire_warning            => l_orig_hire_warning
    );
  end loop;
  --
  -- Update the irc_notification_preferences table to make the candidate
  -- non-searchable
  --
  open csr_update_notif_pref;
  fetch csr_update_notif_pref into l_notif_pref_ovn,l_notif_pref_id;
  hr_utility.set_location(l_proc, 40);
  if csr_update_notif_pref%found
  then
    irc_notification_prefs_api.update_notification_prefs
    (
      p_notification_preference_id => l_notif_pref_id
     ,p_effective_date             => p_effective_date
     ,p_allow_access               => 'N'
     ,p_receive_info_mail          => 'N'
     ,p_object_version_number      => l_notif_pref_ovn
    );
  end if;
  close csr_update_notif_pref;
  hr_utility.set_location('Leaving Anonymize Candidate Data:'||l_proc, 100);
end anonymize_candidate_data;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< send_notification_to_person >-----------------|
-- ----------------------------------------------------------------------------
--
procedure send_notification_to_person
(
  p_person_id in number
) is
--
l_proc varchar2(72) := 'send_notification_to_person';
l_subject fnd_new_messages.message_text%type :=
  fnd_message.get_string('PER','IRC_412169_PURGE_SUBJECT');
l_nid number;
l_name per_all_people_f.full_name%type;
l_message_conc_html varchar2(15600);
l_message_conc_text varchar2(15600);
l_usrName varchar2(200);
--
cursor csr_name is
  select full_name
  from per_all_people_f
  where person_id = p_person_id;

 cursor csr_getfnduser(l_personIdIn in number) is
  select user_name
    from fnd_user
     where employee_id = l_personIdIn;
--
begin
--
  hr_utility.set_location('Entering Send Notification to Person:'||l_proc, 10);
  open csr_name;
  fetch csr_name into l_name;
  close csr_name;
--
  open csr_getfnduser(p_person_id);
  fetch csr_getfnduser into l_usrName;
  close csr_getfnduser;
  if l_usrName is null then
    raise_application_error (-20001,'No wf role is assigned to the candidate');
  end if;
--
  fnd_message.set_name('PER','IRC_412170_PURGE_MESSAGE_TEXT');
  fnd_message.set_token('PERSON_FULL_NAME',l_name);
  l_message_conc_text := fnd_message.get;
--
  fnd_message.set_name('PER','IRC_412171_PURGE_MESSAGE_HTML');
  fnd_message.set_token('PERSON_FULL_NAME',l_name);
  l_message_conc_html := fnd_message.get;
--
  l_nid := irc_notification_helper_pkg.send_notification(
                                       p_person_id => p_person_id
                                      ,p_subject => l_subject
                                      ,p_html_body => l_message_conc_html
                                      ,p_text_body => l_message_conc_text
                                      );
  hr_utility.set_location('Leaving Send Notification to Person:'||l_proc, 100);
--
end send_notification_to_person;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_person >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person
(
  p_party_id       in number
 ,p_root_person_id in number
 ,p_effective_date in date
) is
--
  l_user_name   fnd_user.user_name%type;
  --
  cursor csr_ias_del is
   select ias.assignment_status_id, ias.object_version_number
   from irc_assignment_statuses ias, per_all_assignments_f asg,
     per_all_people_f per
   where asg.assignment_id = ias.assignment_id
   and p_effective_date between per.effective_start_date
     and per.effective_end_date
   and p_effective_date between asg.effective_start_date
     and asg.effective_end_date
   and asg.person_id = per.person_id
   and per.party_id = p_party_id;
  --
  cursor csr_per_del is
   select per.person_id
   from per_all_people_f per
   where per.party_id = p_party_id
   and p_effective_date between per.effective_start_date
     and per.effective_end_date;
  --
  cursor csr_usr_del is
   select usr.user_name
   from fnd_user usr
   where usr.employee_id = p_root_person_id;
  --
begin
  --
  -- Delete Fnd User record
  --
  open csr_usr_del;
  fetch csr_usr_del into l_user_name;
  close csr_usr_del;
  --
  if l_user_name is not null then
     fnd_user_pkg.UpdateUser(
       x_user_name => l_user_name
      ,x_owner => 'CUST'
      ,x_employee_id => fnd_user_pkg.null_number
     );
     --
     -- Disable user
     --
     fnd_user_pkg.DisableUser(
        username => l_user_name
     );
  end if;
  --
  --  Delete Irc Assignment Statuses record
  --
  for rec_ias in csr_ias_del
  loop
    irc_ias_del.del
    (
      p_assignment_status_id   => rec_ias.assignment_status_id
     ,p_object_version_number  => rec_ias.object_version_number
    );
  end loop;
  --
  -- Delete Person record using hr_person_delete.delete_a_person. This
  -- procedure deletes a person completely from the HR database. Deletes
  -- from all tables referencing this person.
  --
  for rec_ppf in csr_per_del
  loop
    hr_person_delete.delete_a_person
    (
      p_person_id    => rec_ppf.person_id
     ,p_form_call    => false
     ,p_session_date => p_effective_date
    );
  end loop;
--
end delete_person;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_person_child_data >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_child_data
(
  p_party_id       in number
 ,p_root_person_id in number
 ,p_effective_date in date
 ,p_process_type   in varchar2
) is
--
  l_proc varchar2(72) := 'delete_person_child_data';
  --

  cursor csr_irc_doc is
    select document_id, object_version_number , party_id,end_date,type,person_id
    from irc_documents
    where party_id = p_party_id;
  --
  cursor csr_irc_notif is
    select notification_preference_id, object_version_number
    from irc_notification_preferences
    where party_id = p_party_id;
  --
  cursor csr_jbi is
   select job_basket_item_id, object_version_number
   from irc_job_basket_items
   where party_id = p_party_id;
  --
  cursor csr_per_qual is
    select qualification_id, object_version_number
    from per_qualifications
    where party_id = p_party_id;
  --
  cursor csr_per_est_att is
    select attendance_id, object_version_number
    from per_establishment_attendances
    where party_id = p_party_id;
  --
  cursor csr_per_prev_empl is
    select previous_employer_id, object_version_number
    from per_previous_employers
    where party_id = p_party_id;
  --
  cursor csr_per_comps is
    select competence_element_id, object_version_number
    from per_competence_elements
    where party_id = p_party_id;
  --
  cursor csr_per_addr is
    select address_id, object_version_number
    from per_addresses
    where party_id = p_party_id
    order by primary_flag, date_from desc;
  --
  cursor csr_isc_work is
    select search_criteria_id, object_version_number
    from irc_search_criteria
    where object_id = p_root_person_id
    and object_type = 'WPREF';
  --
  cursor csr_isc_person is
    select search_criteria_id, object_version_number
    from irc_search_criteria
    where object_id = p_root_person_id
    and object_type = 'PERSON';
  --
  cursor csr_phn_party is
    select phone_id, object_version_number
    from per_phones
    where party_id = p_party_id;
  --
    cursor csr_ivc_cons is
    select vacancy_consideration_id, object_version_number
    from irc_vacancy_considerations
    where party_id = p_party_id;
--

 -- For IRC_INTERVIEW_DETAILS
    -------------------------
    cursor csr_irc_iid is
    select iid.interview_details_id, iid.object_version_number, iid.start_date, iid.end_date
      from irc_interview_details iid,
           per_events pe
     where pe.party_id = p_party_id
       and iid.event_id = pe.event_id;

 -- For IRC_COMM_MESSAGES
    ---------------------
    cursor csr_irc_cmm is
    select icm.COMMUNICATION_MESSAGE_ID, icm.OBJECT_VERSION_NUMBER
      from irc_comm_messages icm,
           irc_comm_topics ict,
           irc_communications ic,
           per_all_assignments_f paf,
           per_all_people_f ppf
     where ppf.party_id = p_party_id
       and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
       and paf.person_id = ppf.person_id
       and paf.effective_end_date in (select max(paf1.effective_end_date)
                                        from per_all_assignments_f paf1
                                       where paf1.assignment_id = paf.assignment_id )
       and ic.object_id = paf.assignment_id
       and ict.COMMUNICATION_ID = ic.COMMUNICATION_ID
       and icm.COMMUNICATION_TOPIC_ID = ict.COMMUNICATION_TOPIC_ID;

 -- For IRC_COMM_RECIPIENTS
    -----------------------
    cursor csr_irc_cmr is
    select icr.COMMUNICATION_RECIPIENT_ID, icr.OBJECT_VERSION_NUMBER
      from irc_comm_recipients icr,
           irc_comm_topics ict,
           irc_communications ic,
           per_all_assignments_f paf,
           per_all_people_f ppf
     where ppf.party_id = p_party_id
       and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
       and paf.person_id = ppf.person_id
       and paf.effective_end_date in (select max(paf1.effective_end_date)
                                        from per_all_assignments_f paf1
                                       where paf1.assignment_id = paf.assignment_id )
       and ic.object_id = paf.assignment_id
       and ict.COMMUNICATION_ID = ic.COMMUNICATION_ID
       and icr.COMMUNICATION_OBJECT_ID = ict.COMMUNICATION_TOPIC_ID
       and icr.COMMUNICATION_OBJECT_TYPE = 'TOPIC';

 -- For IRC_COMM_TOPICS
    -------------------
    cursor csr_irc_cmt is
    select ict.COMMUNICATION_TOPIC_ID, ict.OBJECT_VERSION_NUMBER
      from irc_comm_topics ict,
           irc_communications ic,
           per_all_assignments_f paf,
           per_all_people_f ppf
     where ppf.party_id = p_party_id
       and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
       and paf.person_id = ppf.person_id
       and paf.effective_end_date in (select max(paf1.effective_end_date)
                                        from per_all_assignments_f paf1
                                       where paf1.assignment_id = paf.assignment_id )
       and ic.object_id = paf.assignment_id
       and ict.COMMUNICATION_ID = ic.COMMUNICATION_ID;

 -- For IRC_COMMUNICATIONS
    ----------------------
    cursor csr_irc_cmc is
    select ic.COMMUNICATION_ID, ic.OBJECT_VERSION_NUMBER
      from irc_communications ic,
           per_all_assignments_f paf,
           per_all_people_f ppf
     where ppf.party_id = p_party_id
       and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
       and paf.person_id = ppf.person_id
       and paf.effective_end_date in (select max(paf1.effective_end_date)
                                        from per_all_assignments_f paf1
                                       where paf1.assignment_id = paf.assignment_id )
       and ic.object_id = paf.assignment_id;
--
begin
  hr_utility.set_location('Entering Purge Person Info:'||l_proc, 10);
  --
  -- Delete from IRC_DOCUMENTS
  --

 for rec_irc_doc in csr_irc_doc loop
    irc_document_api.delete_document
    (p_document_id           => rec_irc_doc.document_id
    ,p_object_version_number => rec_irc_doc.object_version_number
    ,p_effective_date        => p_effective_date
    ,p_person_id  => rec_irc_doc.person_id
    ,p_party_id	=> rec_irc_doc.party_id
    ,p_end_date => rec_irc_doc.end_date
    ,p_type    =>rec_irc_doc.type
    );
  end loop;





  --
  -- Delete from PER_QUALIFICATIONS
  --
  hr_utility.set_location(l_proc, 20);
  for rec_per_qual in csr_per_qual loop
    per_qualifications_api.delete_qualification
    (p_qualification_id      => rec_per_qual.qualification_id
    ,p_object_version_number => rec_per_qual.object_version_number
    );
  end loop;
  --
  -- Delete from PER_ESTABLISHMENT_ATTENDANCES
  -- There should not be a child record in Per Qualification table mapped
  -- by Attendance ID
  --
  hr_utility.set_location(l_proc, 30);
  for rec_per_est_att in csr_per_est_att loop
    per_estab_attendances_api.delete_attended_estab
    (p_attendance_id         => rec_per_est_att.attendance_id
    ,p_object_version_number => rec_per_est_att.object_version_number
    );
  end loop;
  --
  -- Delete from Per_Previous_Employers
  -- This deletes data from Per_Previous_jobs an per_previous_job_usages also
  --
  hr_utility.set_location(l_proc, 40);
  for rec_per_prev_empl in csr_per_prev_empl  loop
    hr_previous_employment_api.delete_previous_employer
    (p_previous_employer_id  => rec_per_prev_empl.previous_employer_id
    ,p_object_version_number => rec_per_prev_empl.object_version_number
    );
  end loop;
  --
  -- Api checks for competence_element_id being a parent.
  -- Delete from Per_Competence_Elements
  --
  hr_utility.set_location(l_proc, 50);
  for rec_per_comps in csr_per_comps loop
    hr_competence_element_api.delete_competence_element
    (p_competence_element_id => rec_per_comps.competence_element_id
    ,p_object_version_number => rec_per_comps.object_version_number
    );
  end loop;
  --
  --Delete from Per_Addresses
  --
  hr_utility.set_location(l_proc, 60);
  for rec_per_addr in csr_per_addr loop
    per_add_del.del
    (p_address_id            => rec_per_addr.address_id
    ,p_object_version_number => rec_per_addr.object_version_number
    );
  end loop;
  --
  -- Delete from IRC_JOB_BASKET_ITEMS
  --
  hr_utility.set_location(l_proc, 80);
  for rec_jbi in csr_jbi loop
    irc_job_basket_items_api.delete_job_basket_item
    (p_job_basket_item_id    => rec_jbi.job_basket_item_id
    ,p_object_version_number => rec_jbi.object_version_number
    );
  end loop;
  --
  -- Delete the work preferences
  --
  hr_utility.set_location(l_proc, 90);
  for rec_isc_work in csr_isc_work loop
    irc_search_criteria_api.delete_work_choices
    (p_search_criteria_id    => rec_isc_work.search_criteria_id
    ,p_object_version_number => rec_isc_work.object_version_number
    );
  end loop;
  --
  -- Delete the Job  Saved Searches
  --
  hr_utility.set_location(l_proc, 100);
  for rec_isc_party in csr_isc_person loop
    irc_search_criteria_api.delete_saved_search
    (p_search_criteria_id    => rec_isc_party.search_criteria_id
    ,p_object_version_number => rec_isc_party.object_version_number
    );
  end loop;
  --
  -- Delete from PER_PHONES
  --
  hr_utility.set_location(l_proc, 110);
  for rec_phn in csr_phn_party loop
    hr_phone_api.delete_phone
    (p_phone_id              => rec_phn.phone_id
    ,p_object_version_number => rec_phn.object_version_number
    );
  end loop;
  --
  -- Delete from IRC_VACANCY_CONSIDERATIONS
  --
  hr_utility.set_location(l_proc, 112);
  for rec_ivc in csr_ivc_cons loop
    irc_vacancy_considerations_api.delete_vacancy_consideration
    (p_vacancy_consideration_id  => rec_ivc.vacancy_consideration_id
    ,p_object_version_number => rec_ivc.object_version_number
    );
  end loop;
  --
  -- Delete from IRC_INTERVIEW_DETAILS
  --
  for rec_irc_iid in csr_irc_iid loop
    delete from irc_interview_details
    where       interview_details_id  = rec_irc_iid.interview_details_id;
  end loop;
  --
  -- Delete from IRC_COMM_MESSAGES
  --
  for rec_irc_cmm in csr_irc_cmm loop
    irc_cmm_del.del
    (p_communication_message_id             => rec_irc_cmm.COMMUNICATION_MESSAGE_ID
    ,p_object_version_number                => rec_irc_cmm.OBJECT_VERSION_NUMBER
    );
  end loop;
  --
  -- Delete from IRC_COMM_RECIPIENTS
  --
  for rec_irc_cmr in csr_irc_cmr loop
    irc_cmr_del.del
    (p_communication_recipient_id           => rec_irc_cmr.COMMUNICATION_RECIPIENT_ID
    ,p_object_version_number                => rec_irc_cmr.OBJECT_VERSION_NUMBER
    );
  end loop;
  --
  -- Delete from IRC_COMM_TOPICS
  --
  for rec_irc_cmt in csr_irc_cmt loop
    irc_cmt_del.del
    (p_communication_topic_id               => rec_irc_cmt.COMMUNICATION_TOPIC_ID
    ,p_object_version_number                => rec_irc_cmt.OBJECT_VERSION_NUMBER
    );
  end loop;
  --
  -- Delete from IRC_COMMUNICATIONS
  --
  for rec_irc_cmc in csr_irc_cmc loop
    irc_cmc_del.del
    (p_communication_id                     => rec_irc_cmc.COMMUNICATION_ID
    ,p_object_version_number                => rec_irc_cmc.OBJECT_VERSION_NUMBER
    );
  end loop;
  --
  if(p_process_type='DEL') then
    --
    -- Delete from IRC_NOTIFICATION_PREFERENCES
    --
    hr_utility.set_location(l_proc, 115);
    for rec_irc_notif in csr_irc_notif loop
      irc_notification_prefs_api.delete_notification_prefs
      (p_notification_preference_id => rec_irc_notif.notification_preference_id
      ,p_object_version_number      => rec_irc_notif.object_version_number
      );
    end loop;
    --
    -- Call a procedure to delete the person,asignment and the related records
    --
    hr_utility.set_location(l_proc, 120);
    irc_purge_old_data_pkg.delete_person
    (p_party_id         => p_party_id
    ,p_root_person_id   => p_root_person_id
    ,p_effective_date   => p_effective_date
    );
  --
  elsif(p_process_type ='DELUPD') then
  --
  -- Call a procedure to update the person record
  --
    hr_utility.set_location(l_proc, 130);
    irc_purge_old_data_pkg.anonymize_candidate_data
    (p_party_id         => p_party_id
    ,p_effective_date   => p_effective_date
    );
  --
  end if ;
--
hr_utility.set_location('Leaving Purge Person Info:'||l_proc,200);
end delete_person_child_data;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< notify_or_purge >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure notify_or_purge
(
  p_effective_date in date
 ,p_process_type   in varchar2
 ,p_party_id       in number
 ,p_root_person_id in number
) is
--
  l_proc varchar2(72) := 'notify_or_purge';
  l_print_element_info  varchar2(32000);
  l_person_full_name per_all_people_f.full_name%type;
  cursor csr_full_name is
         select full_name
           from per_all_people_f
          where person_id = p_root_person_id
            and p_effective_date between effective_start_date
            and effective_end_date;
--
begin
--
  hr_utility.set_location('Entering Notify or Purge:'||l_proc, 10);
-- Fetch the person full name
--
  open csr_full_name;
  fetch csr_full_name into l_person_full_name;
  close csr_full_name;
--
  if(p_process_type = 'NOTIFY') then
    --
    hr_utility.set_location(l_proc, 20);
    irc_purge_old_data_pkg.send_notification_to_person
    (p_person_id => p_root_person_id
    );
  elsif(p_process_type = 'UPD') then
    --
    hr_utility.set_location(l_proc, 30);
    irc_purge_old_data_pkg.anonymize_candidate_data
    (p_party_id         => p_party_id
    ,p_effective_date   => p_effective_date
    );
  elsif(p_process_type = 'DEL' or p_process_type = 'DELUPD') then
    --
    hr_utility.set_location(l_proc, 40);
    irc_purge_old_data_pkg.delete_person_child_data
    (p_party_id         => p_party_id
    ,p_root_person_id   => p_root_person_id
    ,p_effective_date   => p_effective_date
    ,p_process_type     => p_process_type
    );
  end if;
  commit;
  --
  -- Write the details of the person record
  --
  l_print_element_info :=  rpad(nvl(l_person_full_name,' '),60)||'  '||
                           rpad(nvl(to_char(p_root_person_id),' '),10)||'  '||
                           rpad(nvl(to_char(p_party_id),' '),10)||'  '||
                           rpad(nvl('SUCCESS',' '),10);
  --
  Fnd_file.put_line(FND_FILE.LOG,l_print_element_info);
  hr_utility.set_location('Leaving Notify or Purge:'||l_proc, 100);
  exception
    when others then
     l_print_element_info :=  rpad(nvl(l_person_full_name,' '),60)||'  '||
                           rpad(nvl(to_char(p_root_person_id),' '),10)||'  '||
                           rpad(nvl(to_char(p_party_id),' '),10)||'  '||
                           rpad(nvl('FAILURE',' '),10);
     Fnd_file.put_line(FND_FILE.LOG,l_print_element_info);
     Fnd_file.put_line(FND_FILE.LOG,'      FAILURE REASON:'||sqlerrm);
     hr_utility.set_location('Leaving Notify or Purge:'||l_proc, 100);
  rollback;
end notify_or_purge;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_max_updated_date >------------------------|
-- ----------------------------------------------------------------------------
--
function get_max_updated_date
(
  p_person_id in number
) return date is
--
  l_max_date date := null;
  --
  cursor csr_max_updated_date is
    select GREATEST (
             NVL (MAX (addr.last_update_date), hr_api.g_sot),
             NVL (MAX (phn.last_update_date), hr_api.g_sot),
             NVL (MAX (ido.last_update_date), hr_api.g_sot),
             NVL (MAX (pem.last_update_date), hr_api.g_sot),
             NVL (MAX (esa.last_update_date), hr_api.g_sot),
             NVL (MAX (qua.last_update_date), hr_api.g_sot),
             NVL (MAX (pce.last_update_date), hr_api.g_sot),
             NVL (MAX (jbo.last_update_date), hr_api.g_sot),
             NVL (MAX (iscw.last_update_date), hr_api.g_sot),
             NVL (MAX (iscp.last_update_date), hr_api.g_sot),
             MAX (per2.last_update_date),
             NVL (MAX (asg.last_update_date), hr_api.g_sot)
           )
    from per_addresses addr,
         per_phones phn,
         irc_documents ido,
         irc_search_criteria iscp,
         irc_search_criteria iscw,
         per_previous_employers pem,
         per_establishment_attendances esa,
         per_qualifications qua,
         per_competence_elements pce,
         irc_job_basket_items jbo,
         per_all_people_f per1,
         per_all_assignments_f asg,
         per_all_people_f per2
    where per1.person_id=p_person_id
    and trunc(sysdate) between per1.effective_start_date and per1.effective_end_date
    and per1.party_id = per2.party_id
    and per2.person_id = asg.person_id(+)
    and per1.person_id = ido.person_id(+)
    and per1.person_id = addr.person_id(+)
    and per1.person_id = phn.parent_id(+)
    and phn.parent_table(+) = 'PER_ALL_PEOPLE_F'
    and per1.person_id = pem.person_id(+)
    and per1.person_id = esa.person_id(+)
    and per1.person_id = qua.person_id(+)
    and per1.person_id = pce.person_id(+)
    and per1.person_id = jbo.person_id(+)
    and per1.person_id = iscp.object_id(+)
    and per1.person_id = iscw.object_id(+)
    and iscp.object_type(+)  = 'PERSON'
    and iscw.object_type(+) = 'WPREF';
  --
  begin
    open csr_max_updated_date;
    fetch csr_max_updated_date into l_max_date;
    close csr_max_updated_date;
    return l_max_date;
end get_max_updated_date;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< last_application_date >-----------------------|
-- ----------------------------------------------------------------------------
--
function last_application_date
(
  p_party_id       in number
 ,p_effective_date in date
)
return date is
--
  l_max_application_date date  := null;
  --
  cursor csr_last_application_date is
    select max(asg.effective_start_date)
    from per_all_assignments_f asg, per_all_people_f per
    where per.party_id = p_party_id
    and p_effective_date
        between per.effective_start_date and per.effective_end_date
    and asg.person_id = per.person_id
    and asg.assignment_type = 'A'
    and not exists (select 1 from per_all_assignments_f asg2
                    where asg.assignment_id = asg2.assignment_id
                    and asg.effective_start_date > asg2.effective_start_date);
--
begin
--
  open csr_last_application_date;
  fetch csr_last_application_date into l_max_application_date;
  close csr_last_application_date;
  return l_max_application_date;
--
end last_application_date;
--
function is_free_to_purge(p_party_id number,p_effective_date date) return string is
cursor c1 (p_party_id number,p_effective_date date) is
select 1
from per_all_people_f per1
,per_person_type_usages_f ptu
,per_person_types ppt
where per1.party_id = p_party_id
and per1.person_id = ptu.person_id
and p_effective_date between per1.effective_start_date and per1.effective_end_date
and ptu.effective_end_date > p_effective_date
and ptu.person_type_id = ppt.person_type_id
and ppt.system_person_type not in ('EX_APL', 'OTHER','IRC_REG_USER');
l_dummy number;
begin
open c1(p_party_id,p_effective_date);
fetch c1 into l_dummy;
if c1%found then
  close c1;
  return 'FALSE';
else
  close c1;
  return 'TRUE';
end if;
end is_free_to_purge;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< purge_records >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_records
(
  p_effective_date in Date
 ,p_process_type  in Varchar2
 ,p_months in Number
 ,p_measure_type Varchar2
) is
--
  l_proc varchar2(72) := 'purge_records';
  l_header Varchar2(500);
  l_underline Varchar2(500);
  --
  cursor csr_last_login_date is
    select inp.person_id,
    inp.party_id
    from irc_notification_preferences inp
    , fnd_user usr
    where inp.person_id = usr.employee_id
    and is_free_to_purge(inp.party_id,p_effective_date)='TRUE'
    and p_months < months_between(p_effective_date,usr.last_logon_date);
  --
  cursor csr_last_update_date is
    select  inp.person_id,
     inp.party_id
    from irc_notification_preferences inp
    where is_free_to_purge(inp.party_id,p_effective_date)='TRUE'
    and p_months <  months_between(p_effective_date
       ,inp.last_update_date)
    and p_months <  months_between(p_effective_date
       ,irc_purge_old_data_pkg.get_max_updated_date(inp.person_id));
  --
  cursor csr_last_application_date is
    select  inp.person_id,
            inp.party_id
    from irc_notification_preferences inp
    where exists (select 1
                  from per_all_people_f per
                     , per_person_type_usages_f ptu,
                       per_person_types ppt
                 where per.party_id=inp.party_id
                   and nvl(per.current_emp_or_apl_flag,'N')='N'
                   and nvl(per.current_npw_flag,'N')='N'
                   and per.person_id=ptu.person_id
                   and p_effective_date between per.effective_start_date
                   and per.effective_end_date
                   and p_effective_date between ptu.effective_start_date
                   and ptu.effective_end_date
                   and ptu.person_type_id=ppt.person_type_id
                   and ppt.system_person_type = 'EX_APL'
                   )
    and irc_purge_old_data_pkg.is_free_to_purge(inp.party_id,p_effective_date)='TRUE'
    and p_months <  months_between(p_effective_date,
      irc_purge_old_data_pkg.last_application_date
               (inp.party_id,p_effective_date)) ;
--
begin
--
  hr_utility.set_location('Entering Purge Records:'||l_proc, 10);
  l_header :=   rpad('FULL_NAME',60)||'  '||
                rpad('PERSON_ID',10)||'  '||
                rpad('PARTY_ID',10)||'  '||
                rpad('RESULT',10);
  --
  l_underline := rpad('-',60,'-')||'  '||
                 rpad('-',10,'-')||'  '||
                 rpad('-',10,'-')||'  '||
                 rpad('-',10,'-');
  --
  Fnd_file.put_line(FND_FILE.LOG,l_header);
  Fnd_file.put_line(FND_FILE.LOG,l_underline);
  if(p_measure_type = 'LOGINDATE') then
    --
    hr_utility.set_location(l_proc, 20);
    for rec_last_login_date in csr_last_login_date loop
      irc_purge_old_data_pkg.notify_or_purge
      (p_effective_date => p_effective_date
      ,p_process_type   => p_process_type
      ,p_party_id       => rec_last_login_date.party_id
      ,p_root_person_id => rec_last_login_date.person_id
      );
    end loop;
  elsif(p_measure_type = 'UPDATEDATE') then
    --
    hr_utility.set_location(l_proc, 30);
    for rec_last_update_date in csr_last_update_date loop
      irc_purge_old_data_pkg.notify_or_purge
      (p_effective_date         => p_effective_date
      ,p_process_type   => p_process_type
      ,p_party_id        => rec_last_update_date.party_id
      ,p_root_person_id  => rec_last_update_date.person_id
      );
    end loop;
  elsif(p_measure_type = 'APPLDATE') then
    --
    hr_utility.set_location(l_proc, 40);
    for rec_last_appl_date in csr_last_application_date loop
      irc_purge_old_data_pkg.notify_or_purge
      (p_effective_date => p_effective_date
      ,p_process_type   => p_process_type
      ,p_party_id       => rec_last_appl_date.party_id
      ,p_root_person_id => rec_last_appl_date.person_id
      );
    end loop;
  end if;
  hr_utility.set_location('Leaving Purge Records:'||l_proc, 100);
end purge_records;
-- ----------------------------------------------------------------------------
-- |--------------------------< purge_record_process >------------------------|
-- ----------------------------------------------------------------------------
--
procedure purge_record_process (errbuf  out nocopy varchar2
                               ,retcode out nocopy varchar2
                               ,p_effective_date in varchar2
                               ,p_process_type   in varchar2
                               ,p_measure_type   in varchar2
                               ,p_months         in number) is
--
  l_proc varchar2(72) := 'purge_record_process';
  --
  l_process_type varchar2(50);
  l_measure_type varchar2(50);
  cursor getprstype(l_prcCodeIn in varchar2) is
   select meaning
     from hr_lookups
     where lookup_type = 'IRC_PROCESS_TYPE'
       and lookup_code = l_prcCodeIn;

  cursor getmeasureType(l_msrCodeIn in varchar2) is
   select meaning
     from hr_lookups
     where lookup_type = 'IRC_MEASURE_TYPE'
       and lookup_code = l_msrCodeIn;
begin
--
  hr_utility.set_location('Entering Purge Record Process:'||l_proc, 10);
  --
   open getprstype(p_process_type);
   fetch getprstype into l_process_type;
   close getprstype;
   open getmeasureType(p_measure_type);
   fetch getmeasureType into l_measure_type;
   close getmeasureType;
  Fnd_file.put_line(FND_FILE.LOG,'This report shows the result of the candidates processed using following');
  Fnd_file.put_line(FND_FILE.LOG,'parameter');
  Fnd_file.put_line(FND_FILE.LOG,'  ');
  Fnd_file.put_line(FND_FILE.LOG,'Purge Type:'||l_measure_type);
  Fnd_file.put_line(FND_FILE.LOG,'Activity Criteria:'||l_process_type);
  Fnd_file.put_line(FND_FILE.LOG,'Effective Date:'||p_effective_date);
  Fnd_file.put_line(FND_FILE.LOG,'Months Since Activity:'||p_months);
  irc_purge_old_data_pkg.purge_records
  (p_effective_date => fnd_date.canonical_to_date(p_effective_date)
  ,p_process_type   => p_process_type
  ,p_months         => p_months
  ,p_measure_type   => p_measure_type
  );
  retcode := 0;
  hr_utility.set_location('Leaving Purge Record Process:'||l_proc, 70);
exception
  when others then
--
    hr_utility.set_location('Leaving Purge Record Process:'||l_proc, 80);
    rollback;
    --
    -- Set the return parameters to indicate failure
    --
    errbuf := sqlerrm;
    retcode := 2;
--
end purge_record_process;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< clean_employee_data >-------------------------|
-- ----------------------------------------------------------------------------
procedure clean_employee_data(p_process_ctrl      IN varchar2
                             ,p_start_pkid        IN number
                             ,p_end_pkid          IN number
                             ,p_rows_processed    OUT nocopy number
                             )
is
  cursor csr_upd_employee is
    select user_name
      from fnd_user u
     where u.employee_id is not null
       and u.user_id between p_start_pkid and p_end_pkid
       and not exists(select null
                        from per_all_people_f
                       where person_id = u.employee_id
                     );
  l_rows_processed number := 0;
begin
  for csr_rec in csr_upd_employee
  loop
    fnd_user_pkg.UpdateUser(
    x_user_name => csr_rec.user_name
   ,x_owner => 'CUST'
   ,x_employee_id => fnd_user_pkg.null_number
    );
    l_rows_processed := l_rows_processed + 1;
  end loop;
  p_rows_processed := l_rows_processed;
end clean_employee_data;
--
end irc_purge_old_data_pkg;

/
