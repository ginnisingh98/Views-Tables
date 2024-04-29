--------------------------------------------------------
--  DDL for Package Body IRC_NOTIFICATION_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTIFICATION_DATA_PKG" as
  /* $Header: irntfdat.pkb 120.10.12010000.8 2009/09/09 13:42:56 mkjayara ship $ */
--+
--+ getParamValue
--+
  function getParamValue ( p_param     in varchar2
                         , p_eventData in varchar2) return varchar2 is
    l_index      number;
    l_leftIndex  number;
    l_rightIndex number;
    l_proc       varchar2(50) := 'getParamValue';
    begin
      l_index := instr(p_eventData, p_param||':');
      if( l_index = 0) then
        return null;
      end if;
      l_leftIndex  := instr(p_eventData, ':', l_index);
      l_rightIndex := instr(p_eventData, ';', l_index);
      return substr(p_eventData
                   ,l_leftIndex + 1
                   ,l_rightIndex-1-l_leftIndex);
    exception
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_proc ,10);
        hr_utility.set_location('Error Message: ' || sqlerrm, 20);
        return null;
  end getParamValue;
--+
--+ getVacancyId
--+
  function getVacancyId ( p_assignmentId  in number
                        , p_effectiveDate in date) return number as
    cursor csrVacancyId(c_assignmentId in number
                       ,c_effectiveDate in date) is
      select vacancy_id
      from per_all_assignments_f
      where assignment_id = c_assignmentId
        and trunc(c_effectiveDate)
             between trunc(effective_start_date) and trunc(effective_end_date);
    l_vacancyId number;
    l_func varchar2(50) := 'getVacancyId';
    begin
      open csrVacancyId(p_assignmentId, p_effectiveDate);
      fetch csrVacancyId into l_vacancyId;
      close csrVacancyId;
      return l_vacancyId;
   exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
   end getVacancyId;
--+
--+ getCandidatePersonId
--+
function getCandidatePersonId ( p_assignmentId      in number
                              , p_effectiveDate     in date
                              , p_event_name        in  varchar2 default null) return number as
    cursor csrCandidateId(c_assignmentId in number
                         ,c_effectiveDate in date) is
      select person_id
      from per_all_assignments_f
      where assignment_id = c_assignmentId
       and trunc(c_effectiveDate)
             between trunc(effective_start_date) and trunc(effective_end_date);
    cursor csrTermntdCandidateId(c_assignmentId in number) is
      select person_id
      from per_all_assignments_f
      where assignment_id = c_assignmentId
      and rownum<2;

    l_candidateId number;
    l_func varchar2(50) := 'getCandidatePersonId';
    begin
      open csrCandidateId(p_assignmentId, p_effectiveDate);
      fetch csrCandidateId into l_candidateId;
      if(csrCandidateId%NOTFOUND and (p_event_name = 'COMTOPCRE' or p_event_name = 'COMTOPUPD')) then
        open csrTermntdCandidateId(p_assignmentId);
        fetch csrTermntdCandidateId into l_candidateId;
        close csrTermntdCandidateId;
      end if;
      close csrCandidateId;
      return l_candidateId;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getCandidatePersonId;
--+
--+
--+
  function getCandidateAgencyId(p_candidateId    in number
                                ,p_effectiveDate in date)
                               return varchar2 is
    cursor csrCandidateAgencyId (c_candidateId    in number
                                ,c_effectiveDate in date) is
      select 'IRC_CAND_AGENCY_ID:'
             || inp.agency_id
             || ';'
      from irc_notification_preferences inp
           ,per_all_people_f ppf
      where inp.person_id = c_candidateId
            and ppf.person_id = c_candidateId
            and c_effectiveDate between ppf.effective_start_date
                and ppf.effective_end_date;
    l_candidateAgencyId varchar2(100);
    l_func varchar2(50) := 'getCandidateAgencyId';
    begin
      open csrCandidateAgencyId(p_candidateId, p_effectiveDate);
      fetch csrCandidateAgencyId into l_candidateAgencyId;
      close csrCandidateAgencyId;
      return l_candidateAgencyId;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getCandidateAgencyId;
--+
--+ getManagerPersonId
--+
  function getManagerPersonId ( p_vacancyId     in number
                              , p_effectiveDate in date) return number as
    cursor csrManagerId(c_vacancyId in number
                       ,c_effectiveDate in date) is
      select manager_id
      from per_all_vacancies
      where vacancy_id = c_vacancyId
        and trunc(c_effectiveDate)
             between trunc(date_from) and nvl(trunc(date_to),to_date('31-12-4712','DD-MM-RRRR'));
     l_managerId number;
     l_func varchar2(50) := 'getManagerPersonId';
     begin
       open csrManagerId(p_vacancyId, p_effectiveDate);
       fetch csrManagerId into l_managerId;
       close csrManagerId;
       return l_managerId;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getManagerPersonId;
--+
--+ getRecruiterPersonId
--+
  function getRecruiterPersonId ( p_assignmentId     in number
                                , p_effectiveDate in date) return number as
    cursor csrRecruiterId(c_assignmentId in number
                         ,c_effectiveDate in date) is
      select recruiter_id
      from per_all_assignments_f
      where assignment_id = c_assignmentId
        and trunc(c_effectiveDate)
             between trunc(effective_start_date) and trunc(effective_end_date);
    l_recruiterId number;
    l_func varchar2(50) := 'getRecruiterPersonId';
    begin
      open csrRecruiterId(p_assignmentId, p_effectiveDate);
      fetch csrRecruiterId into l_recruiterId;
      close csrRecruiterId;
      return l_recruiterId;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getRecruiterPersonId;
--+
--+ getVacancyDetails
--+
  function getVacancyDetails ( p_vacancyId     in number
                             , p_effectiveDate in date) return varchar2 as
    cursor csrVacancyDetails(c_vacancyId in number
                            ,c_effectiveDate in date) is
      select 'IRC_VACANCY_NAME:'
             || pav.name
             || ';IRC_VAC_BG_ID:'
             || pav.business_group_id
             || ';IRC_VAC_CATEGORY:'
             || pav.vacancy_category
             || ';IRC_VAC_JOB_TITLE:'
             || pj.name
             || ';IRC_VAC_POSITION_TITLE:'
             || pp.name
             || ';IRC_POSTING_ID:'
             || pav.primary_posting_id
             || ';IRC_JOB_POSTING_TITLE:'
             || ipc.name
             || ';IRC_RECRUITING_SITE_ID:'
             || pra.recruiting_site_id
             ||';'
      from per_all_vacancies pav,
           per_jobs pj,
           hr_all_positions_f pp,
           per_recruitment_activities pra,
           irc_posting_contents_vl ipc
      where vacancy_id = c_vacancyId
        and pav.job_id = pj.job_id(+)
        and pav.position_id = pp.position_id(+)
        and trunc(c_effectiveDate) between trunc(pav.date_from)
          and nvl(trunc(pav.date_to),to_date('31-12-4712','DD-MM-RRRR'))
        and trunc(c_effectiveDate)
             between trunc(pp.effective_start_date(+)) and trunc(pp.effective_end_date(+))
        and pra.posting_content_id(+) = pav.primary_posting_id
        and ipc.posting_content_id(+) = pav.primary_posting_id
        and rownum = 1;
    l_vacancyDetails varchar2(500);
    l_func varchar2(50) := 'getVacancyDetails';
    begin
      open csrVacancyDetails(p_vacancyId, p_effectiveDate);
      fetch csrVacancyDetails into l_vacancyDetails;
      close csrVacancyDetails;
      return l_vacancyDetails;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getVacancyDetails;
--+
--+ getCommTopicDetailsFromTopicId
--+
  function getCommunicationTopicDetails ( p_topicId   in number
                                        , p_messageId in number) return varchar2 as
    cursor csrCommunicationTopicDetails (c_topicId in number
                                        ,c_messageId in number) is
      select 'IRC_COMM_TOPIC_SUBJECT:'
             || ict.SUBJECT
             || ';IRC_COMM_MSG_SENDER_TYPE:'
             || icm.SENDER_TYPE
             || ';IRC_COMM_MSG_SENDER_ID:'
             || icm.SENDER_ID
             || ';IRC_COMM_MSG_SUBJECT:'
             || icm.MESSAGE_SUBJECT
             || ';IRC_COMM_MSG_BODY:'
             || icm.MESSAGE_BODY
             || ';'
      from  IRC_COMM_MESSAGES icm
           ,IRC_COMM_TOPICS ict
      where ict.COMMUNICATION_TOPIC_ID   = c_topicId
        and icm.COMMUNICATION_TOPIC_ID   = c_topicId
        and icm.COMMUNICATION_MESSAGE_ID = c_messageId;
     l_communicationTopicDetails varchar2(10000);
     l_func varchar2(50) := 'getCommunicationTopicDetails';
    begin
      open csrCommunicationTopicDetails(p_topicId, p_messageId);
      fetch csrCommunicationTopicDetails into l_communicationTopicDetails;
      close csrCommunicationTopicDetails;
      return l_communicationTopicDetails;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getCommunicationTopicDetails;
--+
--+ getInterviewDetails
--+
  function getInterviewDetails ( p_interviewId   in number
                               , p_effectiveDate in date) return varchar2 as
    cursor csrInterviewDetails ( c_interviewId in number
                               , c_effectiveDate in date) is
      select 'IRC_INTVW_LOC_ID:'
             || pe.location_id
             || ';IRC_INTVW_LOC_DETAILS:'
             || loc.description
             || ';IRC_INTVW_LOC_CODE:'
             || loc.location_code
             || ';IRC_INTVW_DERIVED_LOCALE:'
             || loc.derived_locale
             || ';IRC_INTVW_DATE_START:'
             ||  pe.date_start
             || ';IRC_INTVW_DATE_END:'
             ||  pe.date_end
             || ';IRC_INTVW_TIME_START:'
             || pe.time_start
             || ';IRC_INTVW_TIME_END:'
             || pe.time_end
             || ';IRC_INTVW_INT_CONTACT:'
             || ppf.full_name
             || ';IRC_INTVW_INT_CONTACT_NUMBER:'
             || pe.contact_telephone_number
             || ';IRC_INTVW_EXT_CONTACT:'
             || pe.external_contact
             || ';IRC_INTVW_FEEDBACK:'
             || iid.feedback
             || ';IRC_INTVW_RESULT:'
             || iid.result
             || ';IRC_INTVW_NOTES:'
             || iid.notes
             || ';IRC_INTVW_CAND_NOTES:'
             || iid.notes_to_candidate
             || ';IRC_INTVW_CATEGORY:'
             || hlk.meaning
             || ';IRC_INTVW_TYPE:'
             || hlk1.meaning
             || ';IRC_INTVW_TIME_ZONE:'
             || ft.name
             || ';'
      from  per_events pe
           ,irc_interview_details iid
           ,hr_locations_all loc
           ,per_all_people_f ppf
           ,hr_lookups hlk
           ,hr_lookups hlk1
           ,fnd_timezones_vl ft
      where pe.event_id = c_interviewId
        and iid.event_id = pe.event_id
        and c_effectiveDate between iid.start_date and iid.end_date
        and loc.location_id(+) = pe.location_id
        and ppf.person_id(+) = pe.internal_contact_person_id
        and (pe.internal_contact_person_id is null or trunc(c_effectiveDate)
             between trunc(ppf.effective_start_date) and trunc(ppf.effective_end_date))
        and hlk.lookup_code(+) = iid.category
        and (iid.category is null or hlk.lookup_type = 'IRC_INTERVIEW_CATEGORY')
        and hlk1.lookup_code(+) = pe.type
        and (pe.type is null or hlk1.lookup_type = 'IRC_INTERVIEW_TYPE')
        and ft.TIMEZONE_CODE(+) =  loc.TIMEZONE_CODE;
      l_interviewDetails varchar2(10000);
      l_func varchar2(50) := 'getInterviewDetails';
    begin
      open csrInterviewDetails(p_interviewId, p_effectiveDate);
      fetch csrInterviewDetails into l_interviewDetails;
      close csrInterviewDetails;
      return l_interviewDetails;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end  getInterviewDetails;
--+
--+ getPersonDetails
--+
  function getPersonDetails ( p_personId      in number
                            , p_role          in varchar2
                            , p_effectiveDate in date) return varchar2 as
    cursor csrPersonDetails(c_personId in number
                           ,c_role in varchar2
                           ,c_effectiveDate in date) is
      select 'IRC_'
             || c_role
             || '_HZP_ID:'
             || per.party_id
             || ';IRC_'
             || c_role
             || '_FIRST_NAME:'
             || per.first_name
             || ';IRC_'
             || c_role
             || '_LAST_NAME:'
             || per.last_name
             || ';IRC_'
             || c_role
             || '_FULL_NAME:'
             || per.full_name
             || ';IRC_'
             || c_role
             || '_EMAIL_ID:'
             || per.email_address
             || ';'
      from  per_all_people_f per
      where per.person_id = c_personId
        and trunc(c_effectiveDate)
             between trunc(per.effective_start_date) and trunc(per.effective_end_date);
    l_personDetails varchar2(1000);
    l_func varchar2(50) := 'getPersonDetails';
    begin
      open csrPersonDetails(p_personId, p_role, p_effectiveDate);
      fetch csrPersonDetails into l_personDetails;
      close csrPersonDetails;
      return l_personDetails;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
  end getPersonDetails;

--+
--+ getApplicationExtStatus
--+
function getApplicationExtStatus ( p_assignmentStatusCode in number) return varchar2 is
    cursor csrApplicationExternalStatus (c_assignmentStatusCode in number) is
      select 'IRC_JOB_APPL_NEW_STATUS:'
             || per_system_status
             || ';IRC_APPL_NEW_EXTERNAL_STATUS:'
             || external_status
             || ';'
      from PER_ASSIGNMENT_STATUS_TYPES_V
      where ASSIGNMENT_STATUS_TYPE_ID = c_assignmentStatusCode;
    l_applicationExtStatus varchar2(500);
    l_func_name varchar2(50) := 'getApplicationExtStatus';
    begin
      open csrApplicationExternalStatus(p_assignmentStatusCode);
      fetch csrApplicationExternalStatus into l_applicationExtStatus;
      close csrApplicationExternalStatus;
      return l_applicationExtStatus;
    exception
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func_name ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        if csrApplicationExternalStatus%ISOPEN then
        close csrApplicationExternalStatus;
        end if;
      return null;
end getApplicationExtStatus;

--+
--+ getApplicationStatus
--+
function getApplicationStatus ( p_assignmentStatusCode in number) return varchar2 is
    cursor csrApplicationStatus (c_assignmentStatusCode in number) is
      select 'IRC_JOB_APPL_NEW_STATUS:'
             || per_system_status
             || ';IRC_JOB_APPL_NEW_USER_STATUS:'
             || user_status
             || ';'
      from PER_ASSIGNMENT_STATUS_TYPES
      where ASSIGNMENT_STATUS_TYPE_ID = c_assignmentStatusCode;
    l_applicationStatus varchar2(500);
    l_func varchar2(50) := 'getApplicationStatus';
    begin
      open csrApplicationStatus(p_assignmentStatusCode);
      fetch csrApplicationStatus into l_applicationStatus;
      close csrApplicationStatus;
      return l_applicationStatus;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
      return null;
end getApplicationStatus;
--+
--+ getInterviewStatusMeaning
--+
  function getInterviewStatusMeaning (p_interviewStatusCode in varchar2
                                     ,p_attributeName       in varchar2) return varchar2 is
    cursor csrInterviewStatusMeaning (c_interviewStatusCode in varchar2
                                     ,c_attributeName       in varchar2) is
      select c_attributeName
             || ':'
             || meaning
             || ';'
      from HR_LOOKUPS
     where LOOKUP_TYPE = 'IRC_INTERVIEW_STATUS'
       and LOOKUP_CODE = c_interviewStatusCode;
    l_interviewStatusMeaning varchar2(500);
    l_func varchar2(50) := 'getInterviewStatusMeaning';
    begin
      open csrInterviewStatusMeaning(p_interviewStatusCode, p_attributeName);
      fetch csrInterviewStatusMeaning into l_interviewStatusMeaning;
      close csrInterviewStatusMeaning;
      return l_interviewStatusMeaning;
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
      return null;
  end getInterviewStatusMeaning;

 --+
--+ getApplicationOldExtStatus
--+
function getApplicationOldExtStatus ( p_assignmentOldStatusCode in number) return varchar2 is
    cursor csrApplicationOldExtStatus (c_assignmentOldStatusCode in number) is
      select 'IRC_JOB_APPL_OLD_STATUS:'
             || external_status
             || ';'
      from PER_ASSIGNMENT_STATUS_TYPES_V
      where ASSIGNMENT_STATUS_TYPE_ID = c_assignmentOldStatusCode;
    l_applicationOldExtStatus varchar2(500);
    l_func_name varchar2(50) := 'getApplicationOldExtStatus';
    begin
      open csrApplicationOldExtStatus(p_assignmentOldStatusCode);
      fetch csrApplicationOldExtStatus into l_applicationOldExtStatus;
      close csrApplicationOldExtStatus;
      return l_applicationOldExtStatus;
    exception
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func_name ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        if csrApplicationOldExtStatus%ISOPEN then
        close csrApplicationOldExtStatus;
        end if;
      return null;
end getApplicationOldExtStatus;
--+
--+ getInterviersNamesHTML
--+
  function getInterviersNamesHTML( p_interviewId  in number
                                , p_effectiveDate in date)
           return varchar2 is
  cursor csrInterviewersNames(c_interviewId number
                             , c_effectiveDate date) is
    select '<LI>'
           || ppf.full_name
           || '</LI>' interviewer
    from per_all_people_f ppf
         , per_bookings pb
    where ppf.person_id = pb.person_id
      and pb.event_id = c_interviewId
      and trunc(c_effectiveDate) between trunc(ppf.effective_start_date) and trunc(ppf.effective_end_date);
    l_interviewersName varchar2(5000) := null;
    l_func varchar2(50) := 'getInterviersNamesHTML';
    begin
      for l_temp in csrInterviewersNames(p_interviewId, p_effectiveDate) loop
        l_interviewersName := l_interviewersName || l_temp.interviewer;
      end loop;
      return 'IRC_INTERVIEWER_NAMES:<UL>' || l_interviewersName || '</UL>;';
    exception
      when no_data_found then
        hr_utility.set_location('No Data Found Error : ' || g_package||'.'|| l_func ,10);
        return null;
      when others then
        hr_utility.set_location('Error : ' || g_package||'.'|| l_func ,20);
        hr_utility.set_location('Error Message: ' || sqlerrm, 30);
        return null;
    end getInterviersNamesHTML;
--+
end IRC_NOTIFICATION_DATA_PKG;

/
