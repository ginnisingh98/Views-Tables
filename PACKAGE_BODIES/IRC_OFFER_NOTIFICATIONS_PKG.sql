--------------------------------------------------------
--  DDL for Package Body IRC_OFFER_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFER_NOTIFICATIONS_PKG" as
/* $Header: irofrnotif.pkb 120.21.12010000.8 2010/02/02 13:19:17 prasashe ship $ */

-- ----------------------------------------------------------------------------
-- CURSORS
-- ----------------------------------------------------------------------------

-- ***************************************************************************
-- Cursor to get employee id for the given person id
-- ***************************************************************************
CURSOR csr_get_employee_id
       (p_person_id IN number)
IS
  select
   fnd.employee_id as applicant_id
  from
   fnd_user fnd
  where fnd.person_party_id in
     (select party_id
      from per_all_people_f
      where person_id = p_person_id
      and trunc(sysdate) between effective_start_date and effective_end_date
     );

-- ***************************************************************************
-- Cursor to get employee id for the given user id
-- ***************************************************************************

CURSOR csr_get_user_employee_id
       (p_user_id IN number)
IS
  select
   usr.employee_id
  from
   fnd_user usr
  where usr.user_id = p_user_id;

-- ***************************************************************************
-- Cursor to get offer sent date
-- ***************************************************************************
CURSOR csr_get_offer_sent_date
       (p_offer_id IN number)
IS
  select max(ioh.status_change_date)
  from   irc_offer_status_history ioh
  where  ioh.offer_id = p_offer_id
  and    ioh.offer_status ='EXTENDED';

-- ***************************************************************************
-- Cursor to get offer details for the given offer id
-- ***************************************************************************
CURSOR csr_send_offer_rcvd
       (p_offer_id IN number)
IS
  select iof.applicant_assignment_id
        ,vac.name as vacancy_name
        ,vac.manager_id as manager_id
	,asg.recruiter_id as recruiter_id
        ,job.name as job_title
        ,asg.person_id as applicant_id
        ,ppf.full_name as applicant_name
        ,iof.created_by as creator_id
  from  irc_offers iof
       ,per_all_vacancies vac
       ,per_jobs_vl job
       ,per_all_assignments_f asg
       ,per_all_people_f ppf
  where
      iof.offer_status = 'EXTENDED'
  and iof.vacancy_id = vac.vacancy_id
  and vac.job_id = job.job_id(+)
  and asg.assignment_id = iof.applicant_assignment_id
  and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
  and ppf.person_id = asg.person_id
  and iof.offer_id = p_offer_id;

-- ***************************************************************************
-- Cursor to get offer details for the given offer id
-- ***************************************************************************
CURSOR csr_send_apl_resp
       (p_offer_id IN number)
IS
  select vac.name as vacancy_name
        ,asg.supervisor_id as manager_id
        ,asg.recruiter_id as recruiter_id
        ,iof.created_by as creator
        ,job.name as job_title
        ,asg.person_id as applicant_id
        ,ppf.full_name as applicant_name
        ,ipc.name as job_posting_title
        ,iof.last_updated_by as last_updated
  from  irc_offers iof
       ,per_all_vacancies vac
       ,per_jobs_vl job
       ,per_all_assignments_f asg
       ,per_all_people_f ppf
       ,irc_posting_contents_vl ipc
  where
      iof.offer_status = 'CLOSED'
  and iof.vacancy_id = vac.vacancy_id
  and vac.job_id = job.job_id(+)
  and asg.assignment_id = iof.offer_assignment_id
  and asg.effective_start_date = (select max(effective_start_date)
                               from per_assignments_f asg2 where
                       asg.assignment_id=asg2.assignment_id
                       and asg2.effective_start_date <= trunc(sysdate))
  and trunc(sysdate) between ppf.effective_start_date
                           and ppf.effective_end_date
  and ppf.person_id = asg.person_id
  and iof.offer_id = p_offer_id
  and ipc.posting_content_id(+) = vac.primary_posting_id;

-- ***************************************************************************
-- Cursor to find offers which are about to expire in p_number_of_days
-- ***************************************************************************
CURSOR csr_get_expiry_offer_rec
            (p_number_of_days in number)
IS
  select iof.offer_id
        ,nvl((iof.offer_extended_method),
	      (fnd_profile.VALUE('IRC_OFFER_SEND_METHOD'))) extended_method
        ,iof.applicant_assignment_id
        ,vac.name as vacancy_name
        ,vac.manager_id as manager_id
        ,job.name as job_title
        ,asg.person_id as applicant_id
        ,ppf.full_name as applicant_name
	,iof.expiry_date
        ,iof.created_by as creator_id
  from irc_offers iof
       ,per_all_vacancies vac
       ,per_jobs_vl job
       ,per_all_assignments_f asg
       ,per_all_people_f ppf
  where
      iof.offer_status = 'EXTENDED'
  and iof.latest_offer = 'Y'
  and iof.vacancy_id = vac.vacancy_id
  and vac.job_id = job.job_id(+)
  and asg.assignment_id = iof.applicant_assignment_id
  and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
  and ppf.person_id = asg.person_id
  and (iof.expiry_date between trunc(sysdate) + 0 and
                                      trunc(sysdate) + p_number_of_days);

-- ***************************************************************************
-- Cursor to find offers which are expired in the past day
-- ***************************************************************************

CURSOR csr_get_expired_offer_rec
IS
  select iof.offer_id
        ,vac.name as vacancy_name
        ,vac.manager_id as manager_id
        ,job.name as job_title
        ,asg.person_id as applicant_id
        ,ppf.full_name as applicant_name
        ,iof.created_by as creator_id
  from irc_offers iof
       ,per_all_vacancies vac
       ,per_jobs_vl job
       ,per_all_assignments_f asg
       ,per_all_people_f ppf
  where
     iof.vacancy_id = vac.vacancy_id
  and iof.offer_status = 'EXTENDED'
  and iof.latest_offer = 'Y'
  and vac.job_id = job.job_id(+)
  and asg.assignment_id = iof.applicant_assignment_id
  and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
  and ppf.person_id = asg.person_id
  and iof.expiry_date < trunc(sysdate) + 0;

-- ***************************************************************************
-- Cursor to get offer details for the given offer id
-- ***************************************************************************
CURSOR csr_onhold_offer
       (p_offer_id IN number)
IS
  select vac.name as vacancy_name
        ,iof.created_by as creator_id
        ,job.name as job_title
        ,ppf.full_name as applicant_name
  from  irc_offers iof
       ,per_all_vacancies vac
       ,per_jobs_vl job
       ,per_all_assignments_f asg
       ,per_all_people_f ppf
  where
      iof.offer_status = 'HOLD'
  and iof.vacancy_id = vac.vacancy_id
  and vac.job_id = job.job_id(+)
  and asg.assignment_id = iof.applicant_assignment_id
  and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
  and ppf.person_id = asg.person_id
  and iof.offer_id = p_offer_id;

CURSOR csr_get_user_name
       (p_user_id IN number)
IS
  select
   usr.user_name
  from
   fnd_user usr
  where usr.user_id = p_user_id;
--
cursor csr_get_apl_assignment_id (p_offer_id in number) is
  select applicant_assignment_id
    from irc_offers
   where offer_id = p_offer_id;
--
-- ----------------------------------------------------------------------------
-- FUNCTIONS
-- ----------------------------------------------------------------------------

--
-- -------------------------------------------------------------------------
-- |-----------------------< get_view_offer_url >--------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_view_offer_url
  ( p_person_id          number
   ,p_apl_asg_id         number)
RETURN varchar2
IS
  l_url                  varchar2(4000);
  l_apps_fwk_agent       varchar2(2000);
--
  l_resp_key    fnd_responsibility.responsibility_key%type;
  l_resp_id     fnd_responsibility.responsibility_id%type;
  l_apl_id      fnd_application.application_id%type;
  l_function_name fnd_profile_option_values.profile_option_value%type;
--
--
  CURSOR csr_get_apl_id (apl_short_name varchar2)
    IS
    select application_id
     from fnd_application
     where application_short_name = apl_short_name;
--
  CURSOR csr_get_resp_id (resp_key varchar2,apl_id number)
    IS
    SELECT responsibility_id
      FROM fnd_responsibility
      WHERE responsibility_key = resp_key
        AND application_id = apl_id;
--
BEGIN
  if (irc_utilities_pkg.is_internal_person(p_person_id,trunc(sysdate))='TRUE') then
    l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT')
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_resp_key := 'IRC_EMP_CANDIDATE';
  else
    l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),
                                     fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                          ||fnd_profile.value('ICX_PREFIX'),'/');
    l_resp_key := 'IRC_EXT_CANDIDATE';
  end if;
--
  open csr_get_apl_id('PER');
  fetch csr_get_apl_id into l_apl_id ;
  close csr_get_apl_id;
--
  open csr_get_resp_id(l_resp_key,l_apl_id);
  fetch csr_get_resp_id into l_resp_id ;
  close csr_get_resp_id;
--
  l_function_name := fnd_profile.value_specific
                             (name              => 'IRC_VIEW_OFFER_DETAILS_FUNC'
                             ,responsibility_id => l_resp_id
                             ,application_id => l_apl_id);
--
  l_url:=l_apps_fwk_agent
        ||'/OA_HTML/OA.jsp?OAFunc='
        ||l_function_name
        ||'&addBreadCrumb=Y'
        ||'&TabAction=OfferDetails'
        ||'&retainAM=Y&p_aplid='||to_char(p_apl_asg_id);
  RETURN l_url;
END get_view_offer_url;
--
-- -------------------------------------------------------------------------
-- |------------------< get_manager_view_offer_url >-----------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_manager_view_offer_url
  ( p_person_id          number
   ,p_apl_asg_id         number)
RETURN varchar2
IS
 cursor c_func(p_function_name varchar2) is
          select function_id from fnd_form_functions
                  where function_name = p_function_name;
--
  l_url                  varchar2(4000);
  l_apps_fwk_agent       varchar2(2000);
  l_params               varchar2(32767);
  l_funcId               number;
BEGIN
  l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT')
                          ||fnd_profile.value('ICX_PREFIX'),'/');
--
  l_apps_fwk_agent := l_apps_fwk_agent ||'/OA_HTML';
--
  open c_func('IRC_RELAUNCH_PG');
  fetch c_func into l_funcId;
  close c_func;
--
 l_params := 'IrcAction=OfferDetails'
        ||'&p_aplid='||to_char(p_apl_asg_id)
        ||'&p_sprty='||to_char(p_person_id);
--
  l_url:=   fnd_run_function.get_run_function_url ( p_function_id =>l_funcId,
                                p_resp_appl_id =>-1,
                                p_resp_id =>-1,
                                p_security_group_id =>0,
                                p_override_agent=>l_apps_fwk_agent,
                                p_parameters =>l_params,
                                p_encryptParameters =>true ) ;
--
  RETURN l_url;
END get_manager_view_offer_url;
--
-- -------------------------------------------------------------------------
-- |------------------< get_extend_offer_duration_url >--------------------|
-- -------------------------------------------------------------------------
--
FUNCTION get_extend_offer_duration_url
  ( p_person_id          number
  , p_offer_id           number)
RETURN varchar2
IS
  l_url                  varchar2(4000);
  l_apps_fwk_agent       varchar2(2000);
BEGIN
  l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT')
                          ||fnd_profile.value('ICX_PREFIX'),'/');

  l_url:=l_apps_fwk_agent
        ||'/OA_HTML/OA.jsp?OAFunc='
        ||fnd_profile.value('IRC_EXTEND_OFFER_DURATION_FUNC')
        ||'&addBreadCrumb=Y'
        ||'&retainAM=Y&p_sofferid='||to_char(p_offer_id);
  RETURN l_url;
END get_extend_offer_duration_url;


--
-- ----------------------------------------------------------------------------
--  send_rcvd_wf_notification                                                --
--     called internally to send offer received notification :               --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_rcvd_wf_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2) is
--


Event wf_event_t;
EventDocument CLOB;
l_note        CLOB;

l_id           number;
l_applicant_id number;
l_manager_id   number;
l_recruiter_id number;
l_offer_id     number;
l_apl_asg_id   number;
l_creator_id   number;
l_begining     number;
l_end          number := 1;
l_offer_status_history_id number;

l_note_text      varchar2(32767);
l_creator_name   varchar2(4000);
l_vacancy_name   varchar2(4000);
l_job_title      varchar2(4000);
l_offer_status   varchar2(4000);
l_applicant_name varchar2(4000);
l_url            varchar2(4000);

l_subject    varchar2(15599);
l_html_body  varchar2(15599);
l_text_body  varchar2(15599);
l_proc varchar2(30) default '.send_rcvd_wf_notification';
--
cursor csr_offer_notes (p_offer_status_history_id IN NUMBER) is
  select note.note_text
    from irc_notes note
   where note.offer_status_history_id = p_offer_status_history_id
   order by creation_date desc;

--
BEGIN
--
  hr_utility.set_location(l_proc, 10);
  IF (funcmode='RUN') THEN

    hr_utility.set_location(l_proc, 20);

    -- get the event name
    Event:=wf_engine.getActivityAttrEvent
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,actid    => actid
    ,name    => 'EVENT');

    -- get event data
    EventDocument:=Event.getEventData();
    l_offer_id:= to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_id'));
    l_offer_status:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status');
    l_offer_status_history_id:=to_number(irc_xml_util.valueOf(EventDocument,
                                               '/offer_status_history/offer_status_history_id'));

    -- only when the new row is inserted with 'EXTENDED' offer status in irc_offer_status_history table,
    -- proceed further
    IF ( l_offer_status = 'EXTENDED') THEN

      hr_utility.set_location(l_proc, 30);

      -- get the note entered when extending the offer
      open csr_offer_notes(l_offer_status_history_id);
      fetch csr_offer_notes into l_note;
      if csr_offer_notes%found then
        --
        -- convert clob data to varchar2
        --
        l_begining := DBMS_LOB.GETLENGTH(l_note);
        DBMS_LOB.READ(l_note, l_begining, l_end, l_note_text);
      end if;
      close csr_offer_notes;

      open csr_send_offer_rcvd(l_offer_id);
      fetch csr_send_offer_rcvd into l_apl_asg_id,l_vacancy_name,l_manager_id, l_recruiter_id,
                        l_job_title,l_applicant_id,l_applicant_name,l_creator_id;
      close csr_send_offer_rcvd;

      -- get the user name for creator
      open csr_get_user_name(l_creator_id);
      fetch csr_get_user_name into l_creator_name;
      close csr_get_user_name;

      hr_utility.set_location(l_proc, 40);

      -- get the view offer letter url
      -- pass the applicant assignment id because drilldown used in application details page uses it
      l_url := get_view_offer_url
                   (p_person_id => l_applicant_id
                   ,p_apl_asg_id  => l_apl_asg_id);


      -- get the employee id for the applicant
      -- this is required to send notification
      open csr_get_employee_id(l_applicant_id);
      fetch csr_get_employee_id into l_applicant_id;
      close csr_get_employee_id;


      hr_utility.set_location(l_proc, 50);

      -- build subject message
      fnd_message.set_name('PER','IRC_OFFER_RECEIVED_APL_SUBJECT');
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_subject := fnd_message.get;

      hr_utility.set_location(l_proc, 60);

      -- build html body
      fnd_message.set_name('PER','IRC_OFFER_RECEIVED_APL_HTML');
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_html_body := fnd_message.get;

      --

      l_html_body := l_html_body
                 ||   '<BR>' || l_note_text;

if (fnd_profile.value('IRC_OFFER_SEND_METHOD')='SYSTEM') then
      l_html_body := l_html_body
                 ||   '<BR><BR><a HREF="'||l_url
                 ||        '">'
                 ||       'View Offer'
                 ||       '</a>'
                 ||       '<BR>';
end if;

      hr_utility.set_location(l_proc, 70);

      -- build text body
      --
      fnd_message.set_name('PER','IRC_OFFER_RECEIVED_APL_TEXT');
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_text_body := fnd_message.get;

      --
      l_text_body := l_text_body
                 ||   '\n' || l_note_text;

      if (fnd_profile.value('IRC_OFFER_SEND_METHOD')='SYSTEM') then
        l_text_body := l_text_body
                 ||   '\n\n'||'View Offer'
                 ||   '\n'||l_url
                 ||   '\n';
      end if;

      --
      hr_utility.set_location(l_proc, 80);

        -- send notification
        if l_applicant_id is not null then
          l_id := irc_notification_helper_pkg.send_notification
                ( p_person_id  => l_applicant_id
                , p_subject    => l_subject
                , p_html_body  => l_html_body
                , p_text_body  => l_text_body
                , p_from_role  => l_creator_name
                );
        end if;
      hr_utility.set_location(l_proc, 90);

      -- now send the notification to manager also
      IF( l_manager_id is not null or l_recruiter_id is not null) THEN
      --
        hr_utility.set_location(l_proc, 100);

        -- get the employee id for manager
        open csr_get_employee_id(l_manager_id);
        fetch csr_get_employee_id into l_manager_id;
        close csr_get_employee_id;

	-- get the employee id for recruiter
        open csr_get_employee_id(l_recruiter_id);
        fetch csr_get_employee_id into l_recruiter_id;
        close csr_get_employee_id;

        -- build subject message
        fnd_message.set_name('PER','IRC_OFFER_SENT_MGR_SUBJECT');
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_subject := fnd_message.get;

        hr_utility.set_location(l_proc, 110);


        -- build html body
        fnd_message.set_name('PER','IRC_OFFER_SENT_MGR_HTML');
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_html_body := fnd_message.get || '<BR>' || l_note_text;

        --
        hr_utility.set_location(l_proc, 120);

        -- build text body
        --
        fnd_message.set_name('PER','IRC_OFFER_SENT_MGR_TEXT');
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_text_body := fnd_message.get || '\n' || l_note_text;

        --
        hr_utility.set_location(l_proc, 130);

        -- send notification to manager
	if l_manager_id is not null then
        l_id := irc_notification_helper_pkg.send_notification
                ( p_person_id  => l_manager_id
                , p_subject    => l_subject
                , p_html_body  => l_html_body
                , p_text_body  => l_text_body
                , p_from_role  => l_creator_name
                );
        end if;
        -- send notification to recruiter
	if l_recruiter_id is not null and l_manager_id <> l_recruiter_id then
	  l_id := irc_notification_helper_pkg.send_notification
                ( p_person_id  => l_recruiter_id
                , p_subject    => l_subject
                , p_html_body  => l_html_body
                , p_text_body  => l_text_body
                , p_from_role  => l_creator_name
                );
        end if;
        hr_utility.set_location(l_proc, 140);

      --
      END IF;
    END IF;
    --
  END IF;
  resultout:='COMPLETE';
  hr_utility.set_location(' Leaving:'||l_proc, 150);
--
END send_rcvd_wf_notification;
--
--
-- ----------------------------------------------------------------------------
--  send_expiry_notification                                                 --
--     called from concurrent process to send offer expiry notification :    --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_expiry_notification
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number
             , p_number_of_days  in number)
 is
--
  l_id  number;
  l_applicant_id number;
  l_apl_asg_id number;
  l_manager_id number;
  l_creator_name varchar2(4000);

  l_subject        varchar2(240);
  l_html_body      varchar2(32000);
  l_text_body      varchar2(32000);
  l_url            varchar2(4000);
  l_proc varchar2(30) default '.send_expiry_notification';
  l_extend_method  varchar2(30);
  l_offer_sent_date date;


--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
  -- Loop through all the job seekers and send them
  -- a general notification.
  for offer_expiry_rec in csr_get_expiry_offer_rec
               (p_number_of_days => p_number_of_days)loop
    l_apl_asg_id := offer_expiry_rec.applicant_assignment_id;
    -- build subject message
    fnd_message.set_name('PER','IRC_OFFER_EXPIRY_SUBJECT');
    fnd_message.set_token('DAY_OF_EXPIRY',offer_expiry_rec.expiry_date, false);
    fnd_message.set_token('VACANCY_NAME',offer_expiry_rec.vacancy_name, false);
    fnd_message.set_token('JOB_TITLE',offer_expiry_rec.job_title, false);
    l_subject := fnd_message.get;

    --get offer sent date
    open csr_get_offer_sent_date(offer_expiry_rec.offer_id);
    fetch csr_get_offer_sent_date into l_offer_sent_date;
    close csr_get_offer_sent_date;

    --get the user name for creator
    open csr_get_user_name(offer_expiry_rec.creator_id);
    fetch csr_get_user_name into l_creator_name;
    close csr_get_user_name;

    hr_utility.set_location(l_proc,20);

    -- get offer view url
    l_url := get_view_offer_url
                     (p_person_id => offer_expiry_rec.applicant_id
                     ,p_apl_asg_id  => l_apl_asg_id);


    -- get the employee id for applicant
    open csr_get_employee_id(offer_expiry_rec.applicant_id);
    fetch csr_get_employee_id into l_applicant_id;
    close csr_get_employee_id;

    hr_utility.set_location(l_proc,30);



    --
    -- Build the body of the message both in text and html
    --

    -- build html body
    fnd_message.set_name('PER','IRC_OFFER_EXPIRY_APL_HTML');
    fnd_message.set_token('SENT_DATE',l_offer_sent_date, false);
    fnd_message.set_token('DAY_OF_EXPIRY',offer_expiry_rec.expiry_date, false);
    l_html_body := fnd_message.get;

    --
    l_extend_method := offer_expiry_rec.extended_method;
    if (l_extend_method='SYSTEM') then
      l_html_body := l_html_body
                 ||   '<BR><a HREF="'||l_url
                 ||        '">'
                 ||       'View Offer'
                 ||       '</a>'
                 ||       '<BR>';
    end if;
    --
    hr_utility.set_location(l_proc,40);

    -- build text body

    fnd_message.set_name('PER','IRC_OFFER_EXPIRY_APL_TEXT');
    fnd_message.set_token('SENT_DATE',l_offer_sent_date, false);
    fnd_message.set_token('DAY_OF_EXPIRY',offer_expiry_rec.expiry_date, false);
    l_text_body := fnd_message.get;

    --
    if (l_extend_method='SYSTEM') then
      l_text_body := l_text_body
                 ||   '\n'||'View Offer'
                 ||   '\n'||l_url
                 ||   '\n';
    end if;
    --
    hr_utility.set_location(l_proc,50);

    -- send notification to applicant
    if l_applicant_id is not null then
    l_id := irc_notification_helper_pkg.send_notification
            ( p_person_id  => l_applicant_id
            , p_subject    => l_subject
            , p_html_body  => l_html_body
            , p_text_body  => l_text_body
            , p_from_role  => l_creator_name
            );
    end if;
    hr_utility.set_location(l_proc,60);

    -- send notification to manager
    IF ( offer_expiry_rec.manager_id is not null) THEN

      hr_utility.set_location(l_proc,70);

      --get the employee id for manager
      open csr_get_employee_id(offer_expiry_rec.manager_id);
      fetch csr_get_employee_id into l_manager_id;
      close csr_get_employee_id;

      hr_utility.set_location(l_proc,80);

      -- get extend offer duration url
      l_url := get_extend_offer_duration_url
                      (p_person_id => l_manager_id
                      ,p_offer_id  => offer_expiry_rec.offer_id);


      hr_utility.set_location(l_proc,90);

      --
      -- Build the body of the message both in text and html
      --

      -- build html body
      fnd_message.set_name('PER','IRC_OFFER_EXPIRY_MGR_HTML');
      fnd_message.set_token('APPLICANT_NAME',offer_expiry_rec.applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',offer_expiry_rec.vacancy_name, false);
      fnd_message.set_token('DAY_OF_EXPIRY',offer_expiry_rec.expiry_date, false);
      l_html_body := fnd_message.get;
      --
      l_html_body := l_html_body
                   ||   '<BR><a HREF="'||l_url
                   ||        '">'
                   ||       'Extend Duration'
                   ||       '</a>'
                   ||       '<BR>';
      --
      hr_utility.set_location(l_proc,100);

      -- build text body

      fnd_message.set_name('PER','IRC_OFFER_EXPIRY_MGR_TEXT');
      fnd_message.set_token('APPLICANT_NAME',offer_expiry_rec.applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',offer_expiry_rec.vacancy_name, false);
      fnd_message.set_token('DAY_OF_EXPIRY',offer_expiry_rec.expiry_date, false);
      l_text_body := fnd_message.get;

      --
      l_text_body := l_text_body
                   ||   '\n'||'Extend Duration'
                   ||   '\n'||l_url
                   ||   '\n';
      --
      hr_utility.set_location(l_proc,110);
      if l_manager_id is not null then
       l_id := irc_notification_helper_pkg.send_notification
              ( p_person_id  => l_manager_id
              , p_subject    => l_subject
              , p_html_body  => l_html_body
              , p_text_body  => l_text_body
              , p_from_role  => l_creator_name
              );
      end if;
    END IF;

    hr_utility.set_location(l_proc,120);


  end loop;
  hr_utility.set_location(' Leaving:'||l_proc, 130);

--
END send_expiry_notification;
--
--
--
-- ----------------------------------------------------------------------------
--  send_expired_notification                                                --
--     called from concurrent process to send offer expired notification :   --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_expired_notification
            (  errbuf    out nocopy varchar2
             , retcode   out nocopy number)
 is
--
  l_id  number;
  l_applicant_id number;
  l_manager_id number;
  l_creator_name varchar2(4000);

  l_subject      varchar2(240);
  l_html_body    varchar2(32000);
  l_text_body    varchar2(32000);
  l_url          varchar2(4000);
  l_proc varchar2(30) default '.send_expired_notification';
  l_offer_sent_date date;

--
BEGIN
--
  hr_utility.set_location('Entering'||l_proc, 10);
  -- Loop through all the job seekers and send them
  -- a general notification.
  for offer_expired_rec in csr_get_expired_offer_rec loop

    -- build subject message
    fnd_message.set_name('PER','IRC_OFFER_EXPIRED_SUBJECT');
    fnd_message.set_token('VACANCY_NAME',offer_expired_rec.vacancy_name, false);
    fnd_message.set_token('JOB_TITLE',offer_expired_rec.job_title, false);
    l_subject := fnd_message.get;

    --get offer sent date
    open csr_get_offer_sent_date(offer_expired_rec.offer_id);
    fetch csr_get_offer_sent_date into l_offer_sent_date;
    close csr_get_offer_sent_date;

    --get the user name for creator
    open csr_get_user_name(offer_expired_rec.creator_id);
    fetch csr_get_user_name into l_creator_name;
    close csr_get_user_name;

    hr_utility.set_location(l_proc,20);

    -- get the person id
    open csr_get_employee_id(offer_expired_rec.applicant_id);
    fetch csr_get_employee_id into l_applicant_id;
    close csr_get_employee_id;


    hr_utility.set_location(l_proc,30);

    --
    -- Build the body of the message both in text and html
    --

    -- build html body
    fnd_message.set_name('PER','IRC_OFFER_EXPIRED_APL_HTML');
    fnd_message.set_token('SENT_DATE',l_offer_sent_date, false);
    l_html_body := fnd_message.get;

    --
    hr_utility.set_location(l_proc,40);

    -- build text body
    fnd_message.set_name('PER','IRC_OFFER_EXPIRED_APL_TEXT');
    fnd_message.set_token('SENT_DATE',l_offer_sent_date, false);
    l_text_body := fnd_message.get;

    --
    hr_utility.set_location(l_proc,50);

    -- send notification
    if l_applicant_id is not null then
      l_id := irc_notification_helper_pkg.send_notification
            ( p_person_id  => l_applicant_id
            , p_subject    => l_subject
            , p_html_body  => l_html_body
            , p_text_body  => l_text_body
            , p_from_role  => l_creator_name
            );
    end if;
    hr_utility.set_location(l_proc,60);

    -- send notification to manager
    IF ( offer_expired_rec.manager_id is not null) THEN
    --
      hr_utility.set_location(l_proc,70);

      --get the employee id for manager
      open csr_get_employee_id(offer_expired_rec.manager_id);
      fetch csr_get_employee_id into l_manager_id;
      close csr_get_employee_id;
      --
      -- Build the body of the message both in text and html
      --
      -- get extend offer duration url
      l_url := get_extend_offer_duration_url
                      (p_person_id => l_manager_id
                      ,p_offer_id  => offer_expired_rec.offer_id);


      -- build html body
      fnd_message.set_name('PER','IRC_OFFER_EXPIRED_MGR_HTML');
      fnd_message.set_token('APPLICANT_NAME',offer_expired_rec.applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',offer_expired_rec.vacancy_name, false);
      l_html_body := fnd_message.get;

      --
      l_html_body := l_html_body
                   ||   '<BR><a HREF="'||l_url
                   ||        '">'
                   ||       'Extend Duration'
                   ||       '</a>'
                   ||       '<BR>';
      --
      hr_utility.set_location(l_proc,80);

      -- build text body
      fnd_message.set_name('PER','IRC_OFFER_EXPIRED_MGR_TEXT');
      fnd_message.set_token('APPLICANT_NAME',offer_expired_rec.applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',offer_expired_rec.vacancy_name, false);
      l_text_body := fnd_message.get;

      --
      l_text_body := l_text_body
                   ||   '\n'||'Extend Duration'
                   ||   '\n'||l_url
                   ||   '\n';
      --
      hr_utility.set_location(l_proc,90);
      if l_manager_id is not null then
      l_id := irc_notification_helper_pkg.send_notification
              ( p_person_id  => l_manager_id
              , p_subject    => l_subject
              , p_html_body  => l_html_body
              , p_text_body  => l_text_body
              , p_from_role  => l_creator_name
              );
      end if;
    hr_utility.set_location(l_proc,100);
    --
    END IF;

    -- Set the offer status to 'CLOSED' for the expired offers
    irc_offers_api.close_offer
    ( p_validate                     => false
     ,p_effective_date               => trunc(sysdate)
     ,p_offer_id                     => offer_expired_rec.offer_id
     ,p_change_reason                => 'EXPIRED'
     ,p_status_change_date           => trunc(sysdate)
    );

    hr_utility.set_location(l_proc,110);

  end loop;
  hr_utility.set_location(' Leaving:'||l_proc, 120);
--
END send_expired_notification;
--
-- ----------------------------------------------------------------------------
--  send_applicant_response                                                  --
--     called internally to send notification about applicant response  :    --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_applicant_response(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2) is
--
Event wf_event_t;
EventDocument CLOB;
l_note        CLOB;

l_id           number;
l_applicant_id number;
l_offer_id     number;
l_manager_id   number;
l_recruiter_id number;
l_creator_id   number;
l_referrer_id  number;
l_begining     number;
l_user_id      number;
l_end          number := 1;
l_offer_status_history_id number;
l_creator_name varchar2(4000);

l_apl_response boolean := false;
l_apl_accepted boolean := false;

l_note_text      varchar2(32767);
l_vacancy_name   varchar2(4000);
l_job_title      varchar2(4000);
l_applicant_name varchar2(4000);
l_offer_status   varchar2(4000);
l_change_reason  varchar2(4000);
l_decline_reason varchar2(4000);
l_decline_reason_meaning varchar2(4000);
l_job_posting_title varchar2(4000);
l_last_updated_by number;

l_subject    varchar2(15599);
l_html_body  varchar2(15599);
l_text_body  varchar2(15599);
l_url        varchar2(4000);
l_applicant_asg_id     number;

l_proc varchar2(30) default '.send_applicant_response';
--
cursor csr_offer_notes (p_offer_status_history_id IN NUMBER) is
  select note.note_text
    from irc_notes note
   where note.offer_status_history_id = p_offer_status_history_id
   order by creation_date desc;
--
cursor csr_get_decline_reason (p_decline_reason IN VARCHAR2) is
  select meaning
    from hr_lookups
   where lookup_type = 'IRC_OFFER_DECLINE_REASON' and
         lookup_code = p_decline_reason;
--
cursor csr_get_apl_referrer_id (p_offer_id in number) is
  select iri.source_person_id
    from irc_referral_info iri,
         irc_offers iof
   where iri.object_id = iof.APPLICANT_ASSIGNMENT_ID
     and iri.object_type = 'APPLICATION'
     and iof.offer_id = p_offer_id;
--
BEGIN
--

  hr_utility.set_location(l_proc, 10);
  IF (funcmode='RUN') THEN

    hr_utility.set_location(l_proc, 20);

    Event:=wf_engine.getActivityAttrEvent
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,actid    => actid
    ,name    => 'EVENT');

    EventDocument:=Event.getEventData();
    l_offer_id:= to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_id'));
    l_offer_status:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status');
    l_change_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/change_reason');
    l_offer_status_history_id:=to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status_history_id'));


    IF ( l_offer_status = 'CLOSED' and l_change_reason = 'APL_ACCEPTED') THEN
      l_apl_response := true;
      l_apl_accepted := true;
    ELSIF( l_offer_status = 'CLOSED' and l_change_reason = 'APL_DECLINED') THEN
      l_apl_response := true;
      l_apl_accepted := false;
    ELSE
      l_apl_response := false;
    END IF;

    IF ( l_apl_response = true ) THEN
    --
      hr_utility.set_location(l_proc, 30);

      open csr_send_apl_resp(l_offer_id);
      fetch csr_send_apl_resp into l_vacancy_name,l_manager_id,l_recruiter_id,l_creator_id,l_job_title,l_applicant_id,l_applicant_name,l_job_posting_title,l_last_updated_by;
      close csr_send_apl_resp;

     --get the user name for creator
      open csr_get_user_name(l_creator_id);
      fetch csr_get_user_name into l_creator_name;
      close csr_get_user_name;

     --get the person id for creator
      open csr_get_user_employee_id(l_creator_id);
      fetch csr_get_user_employee_id into l_creator_id;
      close csr_get_user_employee_id;

      hr_utility.set_location(l_proc, 40);

      -- get the person id
      open csr_get_employee_id(l_applicant_id);
      fetch csr_get_employee_id into l_applicant_id;
      close csr_get_employee_id;

      -- get the person id for referrer
      open csr_get_apl_referrer_id(l_offer_id);
      fetch csr_get_apl_referrer_id into l_referrer_id;
      close csr_get_apl_referrer_id;

      hr_utility.set_location(l_proc, 50);

      -- build subject message for applicant
      fnd_message.set_name('PER','IRC_OFFER_RESPONSE_APL_SUBJECT');
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_subject := fnd_message.get;
      --

      --
      hr_utility.set_location(l_proc, 60);

      open csr_offer_notes(l_offer_status_history_id);
      fetch csr_offer_notes into l_note;
      if csr_offer_notes%found then
        --
        -- convert clob data to varchar2
        --
        l_begining := DBMS_LOB.GETLENGTH(l_note);
        DBMS_LOB.READ(l_note, l_begining, l_end, l_note_text);
      end if;
      close csr_offer_notes;

      -- build html body for applicant
      IF ( l_apl_accepted = true ) THEN
        fnd_message.set_name('PER','IRC_OFFER_ACCEPTED_APL_HTML');
      ELSE
        fnd_message.set_name('PER','IRC_OFFER_REJECTED_APL_HTML');
      END IF;

      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_html_body := fnd_message.get || '<BR>' || l_note_text;

      hr_utility.set_location(l_proc, 70);

      -- build text body
      IF ( l_apl_accepted = true ) THEN
        fnd_message.set_name('PER','IRC_OFFER_ACCEPTED_APL_TEXT');
      ELSE
        fnd_message.set_name('PER','IRC_OFFER_REJECTED_APL_TEXT');
      END IF;
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      fnd_message.set_token('JOB_TITLE',l_job_title, false);
      l_text_body := fnd_message.get || '\n' || l_note_text;


      --
      hr_utility.set_location(l_proc, 80);

      -- send notification
      if l_applicant_id is not null then
      l_id := irc_notification_helper_pkg.send_notification
              ( p_person_id  => l_applicant_id
              , p_subject    => l_subject
              , p_html_body  => l_html_body
              , p_text_body  => l_text_body
              , p_from_role  => l_creator_name
              );
      end if;
      hr_utility.set_location(l_proc, 90);

      --send notification to manager
      IF( l_manager_id is not null or l_recruiter_id is not null or l_creator_id is not null) THEN

        hr_utility.set_location(l_proc, 100);

        IF ( l_apl_accepted = false ) THEN
          -- get the decline reason
          l_decline_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/decline_reason');
          open csr_get_decline_reason(l_decline_reason);
          fetch csr_get_decline_reason into l_decline_reason_meaning;
          close csr_get_decline_reason;
        END IF;

        -- build subject message for manager
        IF ( l_apl_accepted = true ) THEN
          fnd_message.set_name('PER','IRC_OFFER_ACCEPTED_MGR_SUBJECT');
        ELSE
          fnd_message.set_name('PER','IRC_OFFER_REJECTED_MGR_SUBJECT');
        END IF;
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_subject := fnd_message.get;

        -- build html body for applicant
        IF ( l_apl_accepted = true ) THEN
          fnd_message.set_name('PER','IRC_OFFER_ACCEPTED_MGR_HTML');
        ELSE
          fnd_message.set_name('PER','IRC_OFFER_REJECTED_MGR_HTML');
          fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
        END IF;

        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_html_body := fnd_message.get || '<BR>' || l_note_text;
        --
        hr_utility.set_location(l_proc, 120);
        --
        -- get the applicant_assignment_id
        open csr_get_apl_assignment_id (l_offer_id);
        fetch csr_get_apl_assignment_id into l_applicant_asg_id;
        close csr_get_apl_assignment_id;
        --
        hr_utility.set_location(l_proc, 130);
        --
      	l_url := get_manager_view_offer_url( p_person_id  =>l_applicant_id
                                            ,p_apl_asg_id =>l_applicant_asg_id);
        --
        hr_utility.set_location(l_proc, 140);
        --
        l_html_body := l_html_body
                   ||   '<BR>Click <a HREF="'||l_url
                   ||        '">'
                   ||       'here'
                   ||       '</a> to view details.'
                   ||       '<BR>';
        --

        hr_utility.set_location(l_proc, 110);

        -- build text body
        IF ( l_apl_accepted = true ) THEN
          fnd_message.set_name('PER','IRC_OFFER_ACCEPTED_MGR_TEXT');
        ELSE
          fnd_message.set_name('PER','IRC_OFFER_REJECTED_MGR_TEXT');
          fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
        END IF;
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_text_body := fnd_message.get || '\n' || l_note_text;
        --
        l_text_body := l_text_body
                   ||   '\n\n'||'View Details'
                   ||   '\n'||l_url
                   ||   '\n';
        --
        hr_utility.set_location(l_proc, 120);

        -- send notification to manager
        IF( l_manager_id is not null ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_manager_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 130);
        END IF;
        -- send notification to recruiter
        IF( l_recruiter_id is not null
           and (l_manager_id is null or l_recruiter_id <> l_manager_id) ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_recruiter_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 140);
        END IF;
        -- send notification to creator
        IF( l_creator_id is not null
            and (l_recruiter_id is null or l_creator_id <> l_recruiter_id )
            and (l_manager_id is null or l_creator_id <> l_manager_id )) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_creator_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                 );
          hr_utility.set_location(l_proc, 150);

        END IF;

        -- send notification to referrer
          IF( l_referrer_id is not null
              and l_apl_accepted = true
              and (l_creator_id is null or l_referrer_id <> l_creator_id)
              and (l_recruiter_id is null or l_referrer_id <> l_recruiter_id)
              and (l_manager_id is null or l_referrer_id <> l_manager_id) ) THEN
            -- build subject message for referrer
            fnd_message.set_name('PER','IRC_412441_OFR_ACCEPT_REF_SUB');
            fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
            fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
            l_subject := fnd_message.get;

            -- build html body for applicant
            fnd_message.set_name('PER','IRC_412442_OFR_ACCEPT_REF_HTML');
            fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
            fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
            l_html_body := fnd_message.get;

            hr_utility.set_location(l_proc, 155);

            -- build text body
            fnd_message.set_name('PER','IRC_412509_OFR_ACCEPT_REF_TEXT');
            fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
            fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
            l_text_body := fnd_message.get;
            if l_referrer_id is not null then
            l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_referrer_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                 );
            end if;
          end if;
      --
      END IF;
    END IF;
    --
  END IF;
  resultout:='COMPLETE';
  hr_utility.set_location(' Leaving:'||l_proc, 160);
--
END send_applicant_response;
--
-- ----------------------------------------------------------------------------
--  send_applicant_response                                                  --
--     called internally to send notification about applicant response  :    --
--     sends the notification to applicant and manager                       --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_onhold_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2) is
--
Event wf_event_t;
EventDocument CLOB;

l_id           number;
l_offer_id     number;
l_creator_id   number;

l_vacancy_name   varchar2(4000);
l_job_title      varchar2(4000);
l_applicant_name varchar2(4000);
l_offer_status   varchar2(4000);
l_creator_name   varchar2(4000);

l_subject    varchar2(15599);
l_html_body  varchar2(15599);
l_text_body  varchar2(15599);

l_proc varchar2(30) default '.send_onhold_notification';
--
BEGIN
--

  hr_utility.set_location(l_proc, 10);
  IF (funcmode='RUN') THEN

    hr_utility.set_location(l_proc, 20);

    Event:=wf_engine.getActivityAttrEvent
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,actid    => actid
    ,name    => 'EVENT');

    EventDocument:=Event.getEventData();
    l_offer_id:= to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_id'));
    l_offer_status:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status');


    hr_utility.set_location(l_proc, 30);
    open csr_onhold_offer(l_offer_id);
    fetch csr_onhold_offer into l_vacancy_name,l_creator_id,l_job_title,l_applicant_name;
    close csr_onhold_offer;

    --get the user name for creator
    open csr_get_user_name(l_creator_id);
    fetch csr_get_user_name into l_creator_name;
    close csr_get_user_name;

    --get the person id for creator
    open csr_get_user_employee_id(l_creator_id);
    fetch csr_get_user_employee_id into l_creator_id;
    close csr_get_user_employee_id;

    hr_utility.set_location(l_proc, 40);

    --send notification to manager
    IF(l_creator_id is not null) THEN

      hr_utility.set_location(l_proc, 50);

      -- build subject message for manager
      fnd_message.set_name('PER','IRC_OFFER_ONHOLD_MGR_SUBJECT');
      fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      l_subject := fnd_message.get;

      -- build html body for applicant
      fnd_message.set_name('PER','IRC_OFFER_ONHOLD_MGR_HTML');
      fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      l_html_body := fnd_message.get;

      -- build text body
      fnd_message.set_name('PER','IRC_OFFER_ONHOLD_MGR_TEXT');
      fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
      fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
      l_text_body := fnd_message.get;

      --
      hr_utility.set_location(l_proc, 60);

      -- send notification to creator
      IF( l_creator_id is not null ) THEN
        l_id := irc_notification_helper_pkg.send_notification
                ( p_person_id  => l_creator_id
                , p_subject    => l_subject
                , p_html_body  => l_html_body
                , p_text_body  => l_text_body
                , p_from_role  => l_creator_name
                );
        hr_utility.set_location(l_proc, 70);

      END IF;
    --
    END IF;

  END IF;
  resultout:='COMPLETE';
  hr_utility.set_location(' Leaving:'||l_proc, 90);
--
END send_onhold_notification;
-- ----------------------------------------------------------------------------
--  send_withdrawal_notification                                             --
--  called internally to send notification about offer withdrawal  :         --
--  sends the notification to applicant and manager/recruiter                --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_withdrawal_notification(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2) is
--
Event wf_event_t;
EventDocument CLOB;
l_note        CLOB;

l_id           number;
l_applicant_id number;
l_offer_id     number;
l_manager_id   number;
l_recruiter_id number;
l_creator_id   number;
l_begining     number;
l_user_id      number;
l_end          number := 1;
l_offer_status_history_id number;
l_creator_name varchar2(4000);
l_action_performer varchar2(4000);
l_last_updated_by number;
l_last_updated_emp_id number;
l_mgr_withdraw boolean := false;

l_note_text      varchar2(32767);
l_vacancy_name   varchar2(4000);
l_job_title      varchar2(4000);
l_applicant_name varchar2(4000);
l_offer_status   varchar2(4000);
l_change_reason  varchar2(4000);
l_prev_change_reason   varchar2(4000);
l_prev_offer_status    varchar2(4000);
l_withdrawal_reason varchar2(4000);
l_withdrawal_reason_meaning varchar2(4000);
l_hiring_manager   varchar2(4000);
l_recruiter   varchar2(4000);
l_job_posting_title varchar2(4000);

l_subject    varchar2(15599);
l_html_body  varchar2(15599);
l_text_body  varchar2(15599);
l_url          varchar2(4000);
l_applicant_asg_id     number;

l_proc varchar2(30) default '.send_withdrawal_notification';
--
cursor csr_offer_notes (p_offer_status_history_id IN NUMBER) is
  select note.note_text
    from irc_notes note
   where note.offer_status_history_id = p_offer_status_history_id
   order by creation_date desc;
--
cursor csr_get_withdrawal_reason (p_withdrawal_reason IN VARCHAR2) is
  select meaning
    from hr_lookups
   where lookup_type = 'IRC_OFFER_WITHDRAWAL_REASON' and
         lookup_code = p_withdrawal_reason;
--
cursor csr_get_prev_offer_details (p_offer_status_history_id IN NUMBER,p_offer_id IN NUMBER) is
  select offer_status,change_reason
    from irc_offer_status_history
   where offer_id = p_offer_id
     and status_change_date = (select max(status_change_date)
                                 from irc_offer_status_history
				where offer_id = p_offer_id
				  and offer_status_history_id <> p_offer_status_history_id);
--
CURSOR csr_get_name
       (p_person_id IN number)
IS
  select ppf.full_name
  from  per_all_people_f ppf
  where ppf.person_id = p_person_id
    and sysdate between effective_start_date and effective_end_date;
--

--
BEGIN
--

  hr_utility.set_location(l_proc, 10);
  IF (funcmode='RUN') THEN

    hr_utility.set_location(l_proc, 20);

    Event:=wf_engine.getActivityAttrEvent
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,actid    => actid
    ,name    => 'EVENT');

    EventDocument:=Event.getEventData();
    l_offer_id:= to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_id'));
    l_offer_status:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status');
    l_change_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/change_reason');
    l_offer_status_history_id:=to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status_history_id'));

    open csr_get_prev_offer_details(l_offer_status_history_id,l_offer_id);
    fetch csr_get_prev_offer_details into l_prev_offer_status,l_prev_change_reason;
    close csr_get_prev_offer_details;


    IF ( l_offer_status = 'CLOSED' and l_change_reason = 'MGR_WITHDRAW') THEN
      l_mgr_withdraw := true;
    ELSE
      l_mgr_withdraw := false;
    END IF;

    IF ( l_mgr_withdraw = true ) THEN
    --
      hr_utility.set_location(l_proc, 30);

      open csr_send_apl_resp(l_offer_id);
      fetch csr_send_apl_resp into l_vacancy_name,l_manager_id,l_recruiter_id,l_creator_id,l_job_title,l_applicant_id,l_applicant_name,l_job_posting_title,l_last_updated_by;
      close csr_send_apl_resp;

     --get the user name for creator
      open csr_get_user_name(l_creator_id);
      fetch csr_get_user_name into l_creator_name;
      close csr_get_user_name;

      -- get the recruiter name
      open csr_get_name(l_recruiter_id);
      fetch csr_get_name into l_recruiter;
      close csr_get_name;

      -- get the manager name
      open csr_get_name(l_manager_id);
      fetch csr_get_name into l_hiring_manager;
      close csr_get_name;

     --get the person id for creator
      open csr_get_user_employee_id(l_creator_id);
      fetch csr_get_user_employee_id into l_creator_id;
      close csr_get_user_employee_id;

      hr_utility.set_location(l_proc, 40);

      -- get the person id
      open csr_get_employee_id(l_applicant_id);
      fetch csr_get_employee_id into l_applicant_id;
      close csr_get_employee_id;

      hr_utility.set_location(l_proc, 50);

      open csr_offer_notes(l_offer_status_history_id);
      fetch csr_offer_notes into l_note;
      if csr_offer_notes%found then
        --
        -- convert clob data to varchar2
        --
        l_begining := DBMS_LOB.GETLENGTH(l_note);
        DBMS_LOB.READ(l_note, l_begining, l_end, l_note_text);
      end if;
      close csr_offer_notes;

      hr_utility.set_location(l_proc, 55);
      -- Send notification to the candidate only when the offer has already been extended

      if l_prev_offer_status='EXTENDED' or l_prev_offer_status='PENDING_EXTENDED_DURATION' or l_prev_change_reason='APL_ACCEPTED' then

      -- build subject message for applicant
      fnd_message.set_name('PER','IRC_412572_OFFER_WITHDRAW_APL');
      fnd_message.set_token('JOB_TITLE',l_job_posting_title, false);
      l_subject := fnd_message.get;
      --

      --
      hr_utility.set_location(l_proc, 60);

      -- build html body for applicant
      fnd_message.set_name('PER','IRC_412573_WITHDRAWAL_APL_HTML');
      fnd_message.set_token('JOB_TITLE',l_job_posting_title, false);
      fnd_message.set_token('HIRING_MANAGER',l_hiring_manager, false);
      l_html_body := fnd_message.get || '<BR>' || l_note_text;

      hr_utility.set_location(l_proc, 70);

     -- build text body
      fnd_message.set_name('PER','IRC_412574_WITHDRAWAL_APL_TEXT');
      fnd_message.set_token('JOB_TITLE',l_job_posting_title, false);
      fnd_message.set_token('HIRING_MANAGER',l_hiring_manager, false);

      l_text_body := fnd_message.get || '\n' || l_note_text;

      --
      hr_utility.set_location(l_proc, 80);

      -- send notification
      if l_applicant_id is not null then
      l_id := irc_notification_helper_pkg.send_notification
              ( p_person_id  => l_applicant_id
              , p_subject    => l_subject
              , p_html_body  => l_html_body
              , p_text_body  => l_text_body
              , p_from_role  => l_creator_name
              );
      end if;
      hr_utility.set_location(l_proc, 90);

      end if;

      --send notification to manager
      IF( l_manager_id is not null or l_recruiter_id is not null or l_creator_id is not null) THEN

        hr_utility.set_location(l_proc, 100);

        hr_utility.set_location('l_last_updated_by' || l_last_updated_by, 20);

        open csr_get_user_employee_id(l_last_updated_by);
        fetch csr_get_user_employee_id into l_last_updated_emp_id;
        close csr_get_user_employee_id;

        hr_utility.set_location('l_last_updated_emp_id' || l_last_updated_emp_id, 20);

        open csr_get_name(l_last_updated_emp_id);
        fetch csr_get_name into l_action_performer;
        close csr_get_name;

        hr_utility.set_location('l_action_performer' || l_action_performer, 20);

        -- get the decline reason
        l_withdrawal_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/decline_reason');
        open csr_get_withdrawal_reason(l_withdrawal_reason);
        fetch csr_get_withdrawal_reason into l_withdrawal_reason_meaning;
        close csr_get_withdrawal_reason;

        -- build subject message for manager
        fnd_message.set_name('PER','IRC_412575_OFFER_WITHDRAW_MGR');
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_subject := fnd_message.get;

        -- build html body for applicant
        fnd_message.set_name('PER','IRC_412564_WITHDRAWAL_MGR_HTML');
        fnd_message.set_token('ACTION_PERFORMER',l_action_performer, false);
        fnd_message.set_token('WITHDRAWAL_REASON',l_withdrawal_reason_meaning, false);
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        fnd_message.set_token('NOTES',l_note_text, false);

        l_html_body := fnd_message.get;
        --
        -- get the applicant_assignment_id
        open csr_get_apl_assignment_id (l_offer_id);
        fetch csr_get_apl_assignment_id into l_applicant_asg_id;
        close csr_get_apl_assignment_id;
        --
        hr_utility.set_location(l_proc, 110);
        --
	      l_url := get_manager_view_offer_url( p_person_id  =>l_applicant_id
                                            ,p_apl_asg_id =>l_applicant_asg_id);
        --
        hr_utility.set_location(l_proc, 120);
        --
        l_html_body := l_html_body
                   ||   '<BR>Click <a HREF="'||l_url
                   ||        '">'
                   ||       'here'
                   ||       '</a> to view details.'
                   ||       '<BR>';
        --
        hr_utility.set_location(l_proc, 115);

        -- build text body
        fnd_message.set_name('PER','IRC_412565_WITHDRAWAL_MGR_TEXT');
        fnd_message.set_token('ACTION_PERFORMER',l_action_performer, false);
        fnd_message.set_token('WITHDRAWAL_REASON',l_withdrawal_reason_meaning, false);
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        fnd_message.set_token('NOTES',l_note_text, false);

        l_text_body := fnd_message.get;
        --
        l_text_body := l_text_body
                   ||   '\n\n'||'View Details'
                   ||   '\n'||l_url
                   ||   '\n';
        --
        hr_utility.set_location(l_proc, 120);

        -- send notification to manager
        IF( l_manager_id is not null ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_manager_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 130);
        END IF;
        -- send notification to recruiter
        IF( l_recruiter_id is not null
           and (l_manager_id is null or l_recruiter_id <> l_manager_id) ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_recruiter_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 140);
        END IF;
        -- send notification to creator
        IF( l_creator_id is not null
            and (l_recruiter_id is null or l_creator_id <> l_recruiter_id )
            and (l_manager_id is null or l_creator_id <> l_manager_id )) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_creator_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                 );
          hr_utility.set_location(l_proc, 150);

        END IF;

      END IF;
    END IF;
    --
  END IF;
  resultout:='COMPLETE';
  hr_utility.set_location(' Leaving:'||l_proc, 160);
--
END send_withdrawal_notification;
--
-- ----------------------------------------------------------------------------
--  send_dcln_acptd_offer_notif                                             --
--  called internally to send notification about the applicant declining     --
--  offer after acceptance :
--  sends the notification to applicant and manager/recruiter                --
-- ----------------------------------------------------------------------------
--
PROCEDURE send_dcln_acptd_offer_notif(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            funcmode in varchar2,
                            resultout out nocopy varchar2) is
--
Event wf_event_t;
EventDocument CLOB;
l_note        CLOB;

l_id           number;
l_applicant_id number;
l_offer_id     number;
l_manager_id   number;
l_recruiter_id number;
l_creator_id   number;
l_begining     number;
l_user_id      number;
l_end          number := 1;
l_offer_status_history_id number;
l_creator_name varchar2(4000);
l_last_updated_by number;
l_apl_dec_acpt boolean := false;

l_note_text      varchar2(32767);
l_vacancy_name   varchar2(4000);
l_job_title      varchar2(4000);
l_applicant_name varchar2(4000);
l_change_reason  varchar2(4000);
l_offer_status   varchar2(4000);
l_decline_reason varchar2(4000);
l_decline_reason_meaning varchar2(4000);
l_hiring_manager   varchar2(4000);
l_recruiter   varchar2(4000);
l_job_posting_title varchar2(4000);

l_subject    varchar2(15599);
l_html_body  varchar2(15599);
l_text_body  varchar2(15599);
l_url          varchar2(4000);
l_applicant_asg_id     number;
l_proc varchar2(30) default '.send_dcln_acptd_offer_notif';
--
cursor csr_offer_notes (p_offer_status_history_id IN NUMBER) is
  select note.note_text
    from irc_notes note
   where note.offer_status_history_id = p_offer_status_history_id
   order by creation_date desc;
--
cursor csr_get_decline_reason (p_decline_reason IN VARCHAR2) is
  select meaning
    from hr_lookups
   where lookup_type = 'IRC_OFFER_DECLINE_REASON' and
         lookup_code = p_decline_reason;
--
cursor csr_get_prev_offer_details (p_offer_status_history_id IN NUMBER,p_offer_id IN NUMBER) is
  select offer_status,change_reason
    from irc_offer_status_history
   where offer_id = p_offer_id
     and status_change_date = (select max(status_change_date)
                                 from irc_offer_status_history
				where offer_id = p_offer_id
				  and offer_status_history_id <> p_offer_status_history_id);
--
CURSOR csr_get_name
       (p_person_id IN number)
IS
  select ppf.full_name
  from  per_all_people_f ppf
  where ppf.person_id = p_person_id
    and sysdate between effective_start_date and effective_end_date;
--

--
BEGIN
--

  hr_utility.set_location(l_proc, 10);
  IF (funcmode='RUN') THEN

    hr_utility.set_location(l_proc, 20);

    Event:=wf_engine.getActivityAttrEvent
    (itemtype => itemtype
    ,itemkey  => itemkey
    ,actid    => actid
    ,name    => 'EVENT');

    EventDocument:=Event.getEventData();
    l_offer_id:= to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_id'));
    l_offer_status:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status');
    l_change_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/change_reason');
    l_offer_status_history_id:=to_number(irc_xml_util.valueOf(EventDocument,'/offer_status_history/offer_status_history_id'));

    IF ( l_offer_status = 'CLOSED' and l_change_reason = 'APL_DECLINED_ACCEPTANCE') THEN
      l_apl_dec_acpt := true;
    ELSE
      l_apl_dec_acpt := false;
    END IF;

    IF ( l_apl_dec_acpt = true ) THEN
    --
      hr_utility.set_location(l_proc, 30);

      open csr_send_apl_resp(l_offer_id);
      fetch csr_send_apl_resp into l_vacancy_name,l_manager_id,l_recruiter_id,l_creator_id,l_job_title,l_applicant_id,l_applicant_name,l_job_posting_title,l_last_updated_by;
      close csr_send_apl_resp;

     --get the user name for creator
      open csr_get_user_name(l_creator_id);
      fetch csr_get_user_name into l_creator_name;
      close csr_get_user_name;

      -- get the recruiter name
      open csr_get_name(l_recruiter_id);
      fetch csr_get_name into l_recruiter;
      close csr_get_name;

      -- get the manager name
      open csr_get_name(l_manager_id);
      fetch csr_get_name into l_hiring_manager;
      close csr_get_name;

     --get the person id for creator
      open csr_get_user_employee_id(l_creator_id);
      fetch csr_get_user_employee_id into l_creator_id;
      close csr_get_user_employee_id;

      hr_utility.set_location(l_proc, 40);

      -- get the person id
      open csr_get_employee_id(l_applicant_id);
      fetch csr_get_employee_id into l_applicant_id;
      close csr_get_employee_id;

      hr_utility.set_location(l_proc, 50);

      open csr_offer_notes(l_offer_status_history_id);
      fetch csr_offer_notes into l_note;
      if csr_offer_notes%found then
        --
        -- convert clob data to varchar2
        --
        l_begining := DBMS_LOB.GETLENGTH(l_note);
        DBMS_LOB.READ(l_note, l_begining, l_end, l_note_text);
      end if;
      close csr_offer_notes;

              -- get the decline reason
      l_decline_reason:= irc_xml_util.valueOf(EventDocument,'/offer_status_history/decline_reason');
      open csr_get_decline_reason(l_decline_reason);
      fetch csr_get_decline_reason into l_decline_reason_meaning;
      close csr_get_decline_reason;

      hr_utility.set_location(l_proc, 55);

      -- build subject message for applicant
      fnd_message.set_name('PER','IRC_412566_DECLINED_ACCEPT_APL');
      fnd_message.set_token('JOB_TITLE',l_job_posting_title, false);
      l_subject := fnd_message.get;
      --

      --
      hr_utility.set_location(l_proc, 60);

      -- build html body for applicant
      fnd_message.set_name('PER','IRC_412567_DEC_ACCEPT_APL_HTML');
      fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
      fnd_message.set_token('HIRING_MANAGER',l_hiring_manager, false);
      l_html_body := fnd_message.get || '<BR>' || l_note_text;

      hr_utility.set_location(l_proc, 70);

     -- build text body
      fnd_message.set_name('PER','IRC_412568_DEC_ACCEPT_APL_TEXT');
      fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
      fnd_message.set_token('HIRING_MANAGER',l_hiring_manager, false);

      l_text_body := fnd_message.get || '\n' || l_note_text;

      --
      hr_utility.set_location(l_proc, 80);

      -- send notification
      if l_applicant_id is not null then
      l_id := irc_notification_helper_pkg.send_notification
              ( p_person_id  => l_applicant_id
              , p_subject    => l_subject
              , p_html_body  => l_html_body
              , p_text_body  => l_text_body
              , p_from_role  => l_creator_name
              );
      end if;
      hr_utility.set_location(l_proc, 90);

      end if;

      --send notification to manager
      IF( l_manager_id is not null or l_recruiter_id is not null or l_creator_id is not null) THEN

        hr_utility.set_location(l_proc, 100);

        -- build subject message for manager
        fnd_message.set_name('PER','IRC_412569_DECLINED_ACCEPT_MGR');
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        l_subject := fnd_message.get;

        -- build html body for applicant
        fnd_message.set_name('PER','IRC_412570_DEC_ACCEPT_MGR_HTML');
        fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        fnd_message.set_token('NOTES',l_note_text, false);

        l_html_body := fnd_message.get;
        -- get the applicant_assignment_id
        open csr_get_apl_assignment_id (l_offer_id);
        fetch csr_get_apl_assignment_id into l_applicant_asg_id;
        close csr_get_apl_assignment_id;
        --
      	l_url := get_manager_view_offer_url( p_person_id  =>l_applicant_id
                                            ,p_apl_asg_id =>l_applicant_asg_id);
        --
        l_html_body := l_html_body
                   ||   '<BR>Click <a HREF="'||l_url
                   ||        '">'
                   ||       'here'
                   ||       '</a> to view details.'
                   ||       '<BR>';
        --
        hr_utility.set_location(l_proc, 110);
        -- build text body
        fnd_message.set_name('PER','IRC_412571_DEC_ACCEPT_MGR_TEXT');
        fnd_message.set_token('DECLINE_REASON',l_decline_reason_meaning, false);
        fnd_message.set_token('APPLICANT_NAME',l_applicant_name, false);
        fnd_message.set_token('VACANCY_NAME',l_vacancy_name, false);
        fnd_message.set_token('NOTES',l_note_text, false);
        --
        l_text_body := fnd_message.get;
        --
        l_text_body := l_text_body
                   ||   '\n\n'||'View Details'
                   ||   '\n'||l_url
                   ||   '\n';
        --
        hr_utility.set_location(l_proc, 120);

        -- send notification to manager
        IF( l_manager_id is not null ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_manager_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 130);
        END IF;
        -- send notification to recruiter
        IF( l_recruiter_id is not null
           and (l_manager_id is null or l_recruiter_id <> l_manager_id) ) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_recruiter_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                  );
          hr_utility.set_location(l_proc, 140);
        END IF;
        -- send notification to creator
        IF( l_creator_id is not null
            and (l_recruiter_id is null or l_creator_id <> l_recruiter_id )
            and (l_manager_id is null or l_creator_id <> l_manager_id )) THEN
          l_id := irc_notification_helper_pkg.send_notification
                  ( p_person_id  => l_creator_id
                  , p_subject    => l_subject
                  , p_html_body  => l_html_body
                  , p_text_body  => l_text_body
                  , p_from_role  => l_creator_name
                 );
          hr_utility.set_location(l_proc, 150);

        END IF;

      END IF;
    --
  END IF;
  resultout:='COMPLETE';
  hr_utility.set_location(' Leaving:'||l_proc, 160);
--
END send_dcln_acptd_offer_notif;

--
END irc_offer_notifications_pkg;

/
