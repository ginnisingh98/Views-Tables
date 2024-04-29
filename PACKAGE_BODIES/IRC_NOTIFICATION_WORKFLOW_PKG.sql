--------------------------------------------------------
--  DDL for Package Body IRC_NOTIFICATION_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTIFICATION_WORKFLOW_PKG" as
  /* $Header: irntfwfl.pkb 120.14.12010000.20 2009/10/30 06:03:34 mkjayara ship $ */
--+
--+ loadWorkflowAttributes
--+
  procedure loadWorkflowAttributes ( p_eventData in varchar2
                                   , p_itemType  in varchar2
                                   , p_itemKey   in varchar2 )is
    l_temp  varchar2(32767);
    l_key   varchar2(200);
    l_value varchar2(500);
    l_proc  constant varchar2(50) := 'loadWorkflowAttributes';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      l_temp := p_eventData;
      while ( length(l_temp) <> 0) loop
        l_key   := substr(l_temp, 1, instr(l_temp, ':') - 1);
        l_temp  := substr(l_temp, instr(l_temp, ':') + 1);
        l_value := substr(l_temp, 1, instr(l_temp, ';') - 1);
        l_temp  := substr(l_temp, instr(l_temp, ';') + 1);
        begin
        wf_engine.setItemAttrText( itemtype => p_itemType
                                 , itemkey  => p_itemKey
                                 , aname    => l_key
                                 , avalue   => l_value);
        exception
          when others then
            hr_utility.set_location('Error Message : ' ||sqlerrm,50);
        end;
      end loop;
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 100);
    exception
      when others then
        hr_utility.set_location('Error - Exiting:' || g_package||'.'||l_proc, 110);
        hr_utility.set_location('Error Message : ' || sqlerrm,130);
    end loadWorkflowAttributes;
--+
--+ launchNotificationsWorkflow
--+
  function launchNotificationsWorkflow ( p_subscriptionGuid in raw
                                       , p_event             in out nocopy WF_EVENT_T ) return varchar2 is
    l_eventData                   varchar2(32767);
    l_assignmentId                number;
    l_vacancyId                   number;
    l_candidateId                 number;
    l_managerId                   number;
    l_recruiterId                 number;
    l_referrerId                  number;
    l_effectiveDate               date;
    l_assignmentStatusCode        number;
    l_assignmentOldStatusCode     number;
    l_topicId                     number;
    l_communicationObjectType     varchar2(30);
    l_messageId                   number;
    l_interviewId                 number;
    l_interviewStatusCode         varchar2(50);
    l_eventName                   varchar2(50);
    l_eventKey                    number;
    l_actionPerformerId           number;
    l_itemType                    varchar2(50);
    l_itemKey                     varchar2(50);
    l_proc                        constant varchar2(50) := 'launchNotificationsWorkflow';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      l_eventData := p_event.event_data;
      l_assignmentId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                             ( p_param     => 'IRC_ASSIGNMENT_ID'
                             , p_eventData => l_eventData);
      hr_utility.set_location('Assignment Id : ' || l_assignmentId, 20);
      l_eventName := IRC_NOTIFICATION_DATA_PKG.getParamValue
                             ( p_param     => 'IRC_EVENT_NAME'
                             , p_eventData => l_eventData);
      hr_utility.set_location('Event Name : ' || l_eventName, 30);
      l_effectiveDate := to_date( IRC_NOTIFICATION_DATA_PKG.getParamValue
                                     ( p_param     => 'IRC_EFFECTIVE_DATE'
                                     , p_eventData => l_eventData)
                                , 'DD-MM-RRRR');
      if l_effectiveDate is null then
        l_effectiveDate := sysdate;
      end if;
      hr_utility.set_location('Effective Date : ' || l_effectiveDate, 40);
      l_vacancyId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_VACANCY_ID'
                              , p_eventData => l_eventData);
      if l_vacancyId is null then
        l_vacancyId := IRC_NOTIFICATION_DATA_PKG.getVacancyId
                              ( p_assignmentId  => l_assignmentId
                              , p_effectiveDate => l_effectiveDate);
          l_eventData := l_eventData
                         || 'IRC_VACANCY_ID:'
                         || l_vacancyId
                         ||';';
      end if;
      hr_utility.set_location('Vacancy Id : ' || l_vacancyId, 50);
      if l_vacancyId is not null then
      l_eventData := l_eventData
                     || IRC_NOTIFICATION_DATA_PKG.getVacancyDetails
                                  ( p_vacancyId     => l_vacancyId
                                  , p_effectiveDate => l_effectiveDate);
      end if;
      l_candidateId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_CAND_PER_ID'
                              , p_eventData => l_eventData);
      if l_candidateId is null then
        l_candidateId := IRC_NOTIFICATION_DATA_PKG.getCandidatePersonId
                              ( p_assignmentId  => l_assignmentId
                              , p_effectiveDate => l_effectiveDate
                              , p_event_name    => l_eventName);
        l_candidateId := irc_utilities_pkg.GET_RECRUITMENT_PERSON_ID
                              ( p_person_id      => l_candidateId
                              , p_effective_date => l_effectiveDate);
      end if;
      hr_utility.set_location('Candidate Id : ' || l_candidateId, 60);
      if l_candidateId is not null then
        l_eventData := l_eventData
                       || 'IRC_CAND_PER_ID:'
                       || l_candidateId
                       ||';';
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getPersonDetails
                            ( p_personId      => l_candidateId
                            , p_role          => 'CAND'
                            , p_effectiveDate => l_effectiveDate);
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getCandidateAgencyId
                            (p_candidateId    => l_candidateId
                            , p_effectiveDate => l_effectiveDate);
      end if;
      l_managerId := IRC_NOTIFICATION_DATA_PKG.getManagerPersonId
                            ( p_vacancyId     => l_vacancyId
                            , p_effectiveDate => l_effectiveDate);
      hr_utility.set_location('Manager Id : ' || l_managerId, 70);
      if l_managerId IS NOT null then
        l_eventData := l_eventData
                       || 'IRC_MGR_PER_ID:'
                       || l_managerId
                       ||';';
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getPersonDetails
                              ( p_personId      => l_managerId
                              , p_role          => 'MGR'
                              , p_effectiveDate => l_effectiveDate);
      end if;
      l_recruiterId := IRC_NOTIFICATION_DATA_PKG.getRecruiterPersonId
                              ( p_assignmentId     => l_assignmentId
                              , p_effectiveDate => l_effectiveDate);
      hr_utility.set_location('Recruiter Id : ' || l_recruiterId, 80);
      if l_recruiterId IS NOT null then
        l_eventData := l_eventData
                       || 'IRC_REC_PER_ID:'
                       || l_recruiterId
                       ||';';
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getPersonDetails
                              ( p_personId      => l_recruiterId
                              , p_role          => 'REC'
                              , p_effectiveDate => l_effectiveDate);
      end if;
      l_referrerId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_REFR_PER_ID'
                              , p_eventData => l_eventData);
      hr_utility.set_location('Referrer Id : ' || l_referrerId, 90);
      if l_referrerId IS NOT null then
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getPersonDetails
                              ( p_personId      => l_referrerId
                              , p_role          => 'REFR'
                              , p_effectiveDate => l_effectiveDate);
      end if;
      l_actionPerformerId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                    ( p_param     => 'IRC_ACT_PERF_PER_ID'
                                    , p_eventData => l_eventData);
      hr_utility.set_location('Action Performer Id : ' || l_actionPerformerId, 100);
      if l_actionPerformerId is not null then
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getPersonDetails
                               ( p_personId      => l_actionPerformerId
                               , p_role          => 'ACT_PERF'
                               , p_effectiveDate => l_effectiveDate);
      end if;
      if l_eventName = 'APLSTACHG' then
        l_assignmentStatusCode := IRC_NOTIFICATION_DATA_PKG.getparamvalue
                                    ( p_param     => 'IRC_JOB_APPL_NEW_STATUS_CODE'
                                    , p_eventdata => l_eventData);
        l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getApplicationStatus
                                    ( p_assignmentStatusCode => l_assignmentStatusCode);

	l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getApplicationExtStatus
                                    ( p_assignmentStatusCode => l_assignmentStatusCode);


	l_assignmentOldStatusCode := IRC_NOTIFICATION_DATA_PKG.getparamvalue
                                    ( p_param     => 'IRC_JOB_APPL_OLD_STATUS_CODE'
                                    , p_eventdata => l_eventData);

	l_eventData := l_eventData
                       || IRC_NOTIFICATION_DATA_PKG.getApplicationOldExtStatus
                                    ( p_assignmentOldStatusCode => l_assignmentOldStatusCode);


      end if;
      if l_eventName = 'COMTOPCRE' or l_eventName = 'COMTOPUPD' then
        l_communicationObjectType := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_COMM_OBJ_TYPE'
                              , p_eventData => l_eventData);
        if(l_communicationObjectType is null) then
           l_communicationObjectType := 'TOPIC';
        end if;
        if(l_communicationObjectType = 'TOPIC') then
          l_topicId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_COMM_OBJ_ID'
                              , p_eventData => l_eventData);
          l_messageId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_COMM_MSG_ID'
                              , p_eventData => l_eventData);
          l_eventData := l_eventData
                         || IRC_NOTIFICATION_DATA_PKG.getCommunicationTopicDetails
                                   ( p_topicId   => l_topicId
                                   , p_messageId => l_messageId);
        end if;
      end if;
      if l_eventName = 'INTVCRE' or l_eventName = 'INTVUPD' then
          l_interviewId := IRC_NOTIFICATION_DATA_PKG.getParamValue
                              ( p_param     => 'IRC_INTVW_ID'
                              , p_eventData => l_eventData);
          l_eventData := l_eventData
                         || IRC_NOTIFICATION_DATA_PKG.getInterviewDetails
                                   ( p_interviewId   => l_interviewId
                                   , p_effectiveDate => l_effectiveDate);
          l_interviewStatusCode := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                       ( p_param     => 'IRC_INTVW_NEW_STATUS_CODE'
                                       , p_eventData => l_eventData);
          l_eventData := l_eventData
                         || IRC_NOTIFICATION_DATA_PKG.getinterviewstatusmeaning
                              ( p_interviewstatuscode => l_interviewStatusCode
                              , p_attributename => 'IRC_INTVW_NEW_STATUS');
          l_interviewStatusCode := IRC_NOTIFICATION_DATA_PKG.getParamValue
                                       ( p_param     => 'IRC_INTVW_OLD_STATUS_CODE'
                                       , p_eventData => l_eventData);
          l_eventData := l_eventData
                         || IRC_NOTIFICATION_DATA_PKG.getinterviewstatusmeaning
                              ( p_interviewstatuscode => l_interviewStatusCode
                              , p_attributename => 'IRC_INTVW_OLD_STATUS');
          l_eventData := l_eventData
                         || IRC_NOTIFICATION_DATA_PKG.getinterviersnameshtml
                              ( p_interviewid   => l_interviewId
                              , p_effectivedate => l_effectiveDate);
      end if;
      hr_utility.set_location('Populated all data:Create Workflow', 110);
      hr_utility.set_location('Event Data : '||l_eventData, 120);
      l_itemType := fnd_profile.value('IRC_NTF_WF_ITEM_TYPE');
      hr_utility.set_location('Item Type : '||l_itemType, 130);
      if l_itemType is not NULL then
        l_itemKey := p_event.event_key;
        wf_engine.CreateProcess(l_itemType
                               ,l_itemKey
                               ,'IRC_NOTIFICATION_PRC');
        loadWorkflowAttributes ( p_eventData => l_eventData
                               , p_itemType  => l_itemType
                               , p_itemKey   => l_itemKey );
        wf_engine.startprocess( l_itemType
                              , l_itemKey);
      else
        hr_utility.set_location('Workflow Item Type not set', 160);
      end if;
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 180);
      return 'SUCCESS';
    exception
     when others then
       hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 200);
       hr_utility.set_location('Error Message: ' || sqlerrm, 210);
       WF_CORE.CONTEXT('IRC_NOTIFICATIONS_WORKFLOW_PKG','launchNotificationsWorkflow',p_event.getEventName( ), p_subscriptionGuid);
       WF_EVENT.setErrorInfo(p_event, 'ERROR');
       return 'ERROR';
  end launchNotificationsWorkflow;
--+
--+constructURL
--+
procedure constructURL ( p_itemType in varchar2
                       , p_itemKey  in varchar2
                       , p_urlAttribute in varchar2
                       , p_recipientPersonId in varchar2
                       , p_personType in varchar2) is
    l_eventName            varchar2(100);
    l_url                  varchar2(4000) := null;
    l_apps_fwk_agent       varchar2(2000);
    l_assignmentId         varchar2(4000);
    l_isInternalPerson     varchar2(10);
    l_candidatePersonId    varchar2(4000);
    l_managerId            varchar2(100);
    l_recruiterId          varchar2(100);
    l_proc                 constant varchar2(50) := 'constructURL';
    l_params               varchar2(32767);
    l_func                 varchar2(200);
    l_funcId               number;

 cursor c_func(p_function_name varchar2) is
          select function_id from fnd_form_functions
                  where function_name = p_function_name;
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      l_eventName := wf_engine.getItemAttrText ( itemtype => p_itemType
                                              , itemkey  => p_itemKey
                                              , aname => 'IRC_EVENT_NAME');
      hr_utility.set_location('Event name : '||l_eventName,20);
      l_isInternalPerson := irc_utilities_pkg.is_internal_person
                             (p_person_id=> p_recipientPersonId,
                              p_eff_date => trunc(sysdate)
                             );
      if (p_personType <> 'CAND' OR l_isInternalPerson ='TRUE') then
        l_apps_fwk_agent := rtrim(fnd_profile.value_specific('APPS_FRAMEWORK_AGENT')
                            || fnd_profile.value('ICX_PREFIX'),'/');
      else
        l_apps_fwk_agent := rtrim(nvl(fnd_profile.value('IRC_FRAMEWORK_AGENT'),
                                      fnd_profile.value('APPS_FRAMEWORK_AGENT'))
                            ||fnd_profile.value('ICX_PREFIX'),'/');
      end if;

      l_apps_fwk_agent := l_apps_fwk_agent ||'/OA_HTML';

      l_assignmentId := wf_engine.getItemAttrText ( itemtype => p_itemType
                                                  , itemkey  => p_itemKey
                                                  , aname => 'IRC_ASSIGNMENT_ID');
      l_candidatePersonId := wf_engine.getItemAttrText ( itemtype => p_itemType
                                                       , itemkey  => p_itemKey
                                                       , aname => 'IRC_CAND_PER_ID');

      hr_utility.set_location('Assignment Id : '||l_assignmentId,30);
      hr_utility.set_location('Candidate Person Id : '||l_candidatePersonId,40);

      if p_personType = 'CAND' then
        if l_isInternalPerson = 'TRUE' then
          l_func := 'IRC_EMP_VIS_APPLY_LOGIN_PAGE';
        else
          l_func := 'IRC_VIS_APPLY_LOGIN_PAGE';
        end if;

        if l_eventName in ('APLSTACHG','APLFORJOB','UPDREF','COMTOPCRE',
                        'COMTOPUPD','REVTERACK','INTVCRE','INTVUPD') then
          l_params :=  'p_aplid=' || l_assignmentId;
          if(l_eventName in ('COMTOPCRE','COMTOPUPD')) then
            l_params := l_params|| '&TabAction=CommunicationDetails';
          end if;
        elsif l_eventName = 'UPDCANDREF' then
          l_params :=  'AccountDetails=Y';
        end if;
      else
        l_func := 'IRC_RELAUNCH_PG';

        if l_eventName in ('APLSTACHG','APLFORJOB','REQREVTER','WTDRAPL','UPDREF') then
          l_params := 'IrcAction=ApplicationDetails'
                || '&p_aplid=' || l_assignmentId
                || '&p_sprty=' || l_candidatePersonId;
        elsif l_eventName in ('CANDREG','UPDCANDREF') then
          l_params := 'IrcAction=CandidateDetails'
                || '&p_sprty=' || l_candidatePersonId;
        elsif l_eventName like 'COMTOP%' then
          l_params := 'IrcAction=CommunicationDetails'
                || '&p_aplid=' || l_assignmentId
                || '&p_sprty=' || l_candidatePersonId;
        elsif l_eventName like 'INTV%' then
          l_managerId := wf_engine.getItemAttrText ( itemtype => p_itemType
                                                   , itemkey  => p_itemKey
                                                   , aname => 'IRC_MGR_PER_ID');
          l_recruiterId := wf_engine.getItemAttrText ( itemtype => p_itemType
                                                   , itemkey  => p_itemKey
                                                   , aname => 'IRC_REC_PER_ID');
          l_params := 'IrcAction=InterviewDetails'
                || '&p_aplid=' || l_assignmentId
                || '&p_sprty=' || l_candidatePersonId;
          if p_recipientPersonId <> nvl(l_managerId,-1) and
             p_recipientPersonId <> nvl(l_recruiterId,-1) then
            l_params := l_params
                     || '&Interviewer=Y';
          end if;
        end if;
      end if;

 hr_utility.set_location('l_params:'||l_params,50);
 open c_func(l_func);
 fetch c_func into l_funcId;
 close c_func;

      l_url:=   fnd_run_function.get_run_function_url ( p_function_id =>l_funcId,
                                p_resp_appl_id =>-1,
                                p_resp_id =>-1,
                                p_security_group_id =>0,
                                p_override_agent=>l_apps_fwk_agent,
                                p_parameters =>l_params,
                                p_encryptParameters =>true ) ;

      hr_utility.set_location('Generated URL : '||l_url,60);
      wf_engine.setItemAttrText( itemtype => p_itemType
                               , itemkey  => p_itemKey
                               , aname    => p_urlAttribute
                               , avalue   => l_url);
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 70);
    exception
      when others then
        hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 200);
        hr_utility.set_location('Error Message : ' || sqlerrm, 210);
end constructURL;
--+
--+ parseAndReplaceFNDMessage
--+
function parseAndReplaceFNDMessage ( p_itemType in varchar2
                                   , p_itemKey  in varchar2
                                   , p_message  in varchar2
                                   , p_personId in varchar2 default null
                                   , p_personType in varchar2 default null) return varchar2 as
    l_leftIndex       number := 1;
    l_rightIndex      number ;
    l_returnMessage   varchar2(32767) := p_message;
    l_token           varchar2(1000);
    l_value           varchar2(10000):= null;
    l_proc            constant varchar2(50) := 'parseAndReplaceFNDMessage';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      while (l_leftIndex <> 0) loop
          l_value := null;
          l_leftIndex := instr(l_returnMessage, '&' || 'IRC');
          if (l_leftIndex = 0) then
            exit;
          end if;
          l_rightIndex := instr(l_returnMessage,' ', l_leftIndex);
          if (l_rightIndex = 0) then
            l_rightIndex := length(l_returnMessage);   --This is to cater for token at last
          end if;
          l_token := substr(l_returnMessage,l_leftIndex + 1, l_rightIndex-l_leftIndex-1);
          if l_token like 'IRC%HYPERLINK%' then
              hr_utility.set_location('Token for hyperlink',20);
              constructURL ( p_itemType => p_itemType
                           , p_itemKey  => p_itemKey
                           , p_urlAttribute => l_token
                           , p_recipientPersonId =>p_personId
                           , p_personType => p_personType);
          end if;
          begin
            l_value := wf_engine.GetItemAttrText( itemtype => p_itemType
                                              , itemkey  => p_itemKey
                                              , aname => l_token);
          exception
            when others then
              hr_utility.set_location('Error in getting Workflow attribute : ' || sqlerrm, 50);
          end;
          l_returnMessage := substr(l_returnMessage, 1, l_leftIndex -1 )
                             || l_value
                             || substr(l_returnMessage, l_rightIndex);
        end loop;
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 100);
      return l_returnMessage;
    exception
      when others then
        hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 120);
        hr_utility.set_location('Error Message : ' || sqlerrm, 130);
  end parseAndReplaceFNDMessage;
--+
--+ attatchDoc
--+
procedure attatchDoc(   document_id   IN VARCHAR2
                       ,display_type  IN VARCHAR2
                       ,document      IN OUT nocopy blob
                       ,document_type IN OUT nocopy VARCHAR2)


is
  l_blob        blob;
  l_mimetype    varchar2(30);
  l_file_name   varchar2(240);
  p_document_id varchar2(100);
  cursor csr_doc is
     select binary_doc,
            mime_type,
            file_name
        from irc_documents
       where document_id = p_document_id;
begin
  p_document_id := document_id;
  open csr_doc;
  fetch csr_doc into l_blob, l_mimetype,l_file_name;
  close csr_doc;
  document_type := l_mimetype||'; name='||l_file_name;
  dbms_lob.copy(document,l_blob,dbms_lob.getlength(l_blob));
end attatchDoc;
--+
--attach document
--+
procedure attachDocument(p_notificationIdIn in number,p_personIdIn in varchar2
                         ,p_eventName in varchar2,p_itemKey in varchar2
                         ,p_roleType in varchar2) is
   l_doc_ids         ame_util.idList;
   l_proc            varchar2(50);
   l_person_id       number;
   l_count           number;
   l_doc_type        varchar2(40);
   l_intw_status     varchar2(100);
   l_intw_id         number;
   cursor chkResumeExts(c_person_id in number ) is
      select count(*)
       from irc_documents
      where type = 'RESUME'
        and party_id =
           (select party_id
              from per_all_people_f
            where person_id = c_person_id
              and trunc(sysdate) between effective_start_date and effective_end_Date)
        and end_date is null;
   cursor getDocIdList(c_personIdIn in number,c_doc_type in varchar2) is
      select document_id
        from irc_documents
       where type  = c_doc_type
         and party_id =
           (select party_id
              from per_all_people_f
            where person_id = c_personIdIn
              and trunc(sysdate) between effective_start_date and effective_end_Date)
         and end_Date is null;
  cursor getInterViewStatus(c_interviewId in number) is
    select status
     from irc_interview_details
    where event_id = c_interviewId
      and sysdate between start_date and nvl(end_Date,sysdate);

begin
  l_proc := 'attatchDocument';
  open chkResumeExts(p_personIdIn);
  fetch chkResumeExts into l_count;
  close chkResumeExts;
  if l_count > 0 then
    l_doc_type := 'RESUME';
  else
    l_doc_type := 'AUTO_RESUME';
  end if;
  hr_utility.set_location('Entering attatchDocument:'|| g_package||'.'||l_proc, 10);
  hr_utility.set_location('attatchDocument:p_personIdIn:'||p_personIdIn, 30);
  hr_utility.set_location('attatchDocument:p_eventName:'||p_eventName, 40);
  if p_personIdIn is not null then
    l_person_id := to_number(p_personIdIn);
  else
    return;
  end if;
  if p_eventName is not null and p_eventName in ('INTVCRE','INTVUPD','APLFORJOB') then
    if p_eventName in ('INTVCRE','INTVUPD') then
      begin
        l_intw_id := to_number(IRC_NOTIFICATION_WORKFLOW_PKG.getWFAttrValue(p_itemKey,'IRC_INTVW_ID'));
        if l_intw_id is not null then
          open getInterViewStatus(l_intw_id);
          fetch getInterViewStatus into l_intw_status;
          close getInterViewStatus;
        end if;
        if l_intw_status is not null and l_intw_status not in ('PLANNED','CONFIRMED','RESCHEDULED') then
          return;
        end if;
      exception
       when others then
         hr_utility.set_location('error:'||sqlerrm, 30);
      end;
      if l_intw_status is not null and l_intw_status  in ('CONFIRMED','RESCHEDULED') then
        wf_notification.setAttrText(p_notificationIdIn,
                                     'IRC_CAL_ATTACHMENT',
                                     'plsqlblob:irc_notification_workflow_pkg.attatchICDoc/'||p_itemKey||':'||p_notificationIdIn);
      end if;
    end if;
    if p_roleType <> 'CAND' then
      open getDocIdList(l_person_id,l_doc_type);
      fetch getDocIdList bulk collect into l_doc_ids;
      close getDocIdList;
      for i in 1..l_doc_ids.count loop
         wf_notification.setAttrText(p_notificationIdIn,
                                     'IRC_ATTACHMENT_'||to_char(i),
                                     'plsqlblob:irc_notification_workflow_pkg.attatchDoc/'||l_doc_ids(i));
      end loop;
    end if;
  end if;
  hr_utility.set_location('Exiting attatchDocument:'|| g_package||'.'||l_proc, 60);
  exception
    when others then
      hr_utility.set_location('Error occurred in :'|| g_package||'.'||l_proc, 70);
      hr_utility.set_location('Error Message:'|| SQLERRM, 80);
end attachDocument;
--+
--+ getNextRecipient
--+
procedure getNextRecipient ( p_itemType   in varchar2
                           , p_itemKey    in varchar2
                           , p_activityId in number
                           , funmode      in varchar2
                           , result       out nocopy varchar2 ) is
    l_ameTransactionType           varchar2(50);
    l_nextApprovers                ame_util.approversTable2;
    l_approvalProcessCompleteYNOut varchar2(1);
    l_notificationId               number;
    l_messageSubjectName           varchar2(30);
    l_messageSubject               varchar2(5000);
    l_messageBodyName              varchar2(30);
    l_messageBody                  varchar2(30000);
    l_eventName                    varchar2(50);
    l_itemIndexesOut               ame_util.idList;
    l_itemClassesOut               ame_util.stringList;
    l_itemIdsOut                   ame_util.stringList;
    l_itemSourcesOut               ame_util.longStringList;
    l_productionIndexesOut         ame_util.idList;
    l_variableNamesOut             ame_util.stringList;
    l_variableValuesOut            ame_util.stringList;
    l_actionPerformerId            number;
    e_ameException                 exception;
    e_messageNameIsNull            exception;
    l_approverRole                 varchar2(50);
    l_message_type                 varchar2(100);
    l_proc                         constant varchar2(50) := 'getNextRecipient';
    l_candidatePersonId            varchar2(50);
    l_person_type                  varchar2(50);
    l_ntf_message_type             varchar2(50);
    l_oldExtStatus                 varchar2(50);
    l_newExtStatus                 varchar2(50);
    BEGIN
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);

      l_oldExtStatus := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => p_itemKey,aname => 'IRC_JOB_APPL_OLD_STATUS');
      l_newExtStatus := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => p_itemKey,aname => 'IRC_APPL_NEW_EXTERNAL_STATUS');

      l_ameTransactionType := fnd_profile.value('IRC_NTF_AME_TX_TYPE');
      l_person_type := null;
      if l_ameTransactionType is not NULL then
        hr_utility.set_location('AME Transaction Type : ' || l_ameTransactionType, 20);
        begin
          ame_api2.getNextApprovers2(applicationIdIn               => 800
                                  , transactionTypeIn            => l_ameTransactionType
                                  , transactionIdIn              => p_itemKey
                                  , approvalProcessCompleteYNOut => l_approvalprocesscompleteynout
                                  , nextApproversOut             => l_nextApprovers
                                  , itemIndexesOut               => l_itemIndexesOut
                                  , itemClassesOut               => l_itemClassesOut
                                  , itemIdsOut                   => l_itemIdsOut
                                  , itemSourcesOut               => l_itemSourcesOut
                                  , productionIndexesOut         => l_productionIndexesOut
                                  , variableNamesOut             => l_variableNamesOut
                                  , variableValuesOut            => l_variableValuesOut);
        exception
          when others then
            raise e_ameException;
        end;
        hr_utility.set_location('AME Transaction Complete : ' || l_approvalprocesscompleteynout,30);
        if l_approvalProcessCompleteYNOut = 'N' then
            hr_utility.set_location('Recipient : ' || l_nextApprovers(1).name,60);

            wf_engine.setItemAttrText ( itemtype => p_itemType
                                      , itemkey  => p_itemKey
                                      , aname    => 'IRC_APPROVER'
                                      , avalue   => l_nextApprovers(1).name );
            l_eventName := wf_engine.GetItemAttrText( itemtype => p_itemType
                                                    , itemkey  => p_itemKey
                                                    , aname => 'IRC_EVENT_NAME');
            l_messageSubjectName := null;
            l_messageBodyName := null;

            for i in 1..l_variableNamesOut.count loop
              if l_variableNamesOut(i) = 'IRECRUITMENT NOTIFICATION MSG SUBJECT' then
                l_messageSubjectName := l_variableValuesOut(i);
              elsif l_variableNamesOut(i) = 'IRECRUITMENT NOTIFICATION MSG BODY' then
                l_messageBodyName := l_variableValuesOut(i);
              elsif  l_variableNamesOut(i) = 'IRC_ROLE' then
                if l_person_type is null or l_person_type <> 'CAND' then
                  l_person_type := l_variableValuesOut(i);
                end if;
              end if;
            end loop;

            hr_utility.set_location('FND Message Name for Subject : ' || l_messageSubjectName,80);
            hr_utility.set_location('FND Message Name for Body : ' || l_messageBodyName,90);
            if l_messageSubjectName is null or l_messageBodyName is null then
              raise e_messageNameIsNull;
            else
            fnd_message.set_name('PER',l_messageSubjectName);
            l_messageSubject :=   parseAndReplaceFNDMessage( p_itemType => p_itemType
                                                           , p_itemKey  => p_itemKey
                                                           , p_message  => fnd_message.get);
              hr_utility.set_location('Message Subject sent to Recipient: '||l_messageSubject,120);
            wf_engine.setItemAttrText ( itemtype => p_itemType
                                      , itemkey  => p_itemKey
                                      , aname    => 'IRC_MESSAGE_SUBJECT'
                                      , avalue   => l_messageSubject);
            fnd_message.set_name('PER',l_messageBodyName);
            l_messageBody :=  parseAndReplaceFNDMessage( p_itemType => p_itemType
                                                       , p_itemKey  => p_itemKey
                                                       , p_message  => fnd_message.get
                                                       , p_personId => l_nextApprovers(1).orig_system_id
                                                       , p_personType => l_person_type);
              hr_utility.set_location('Message Body sent to recipient: '||l_messageBody,150);
              wf_engine.setitemattrtext( itemtype => p_itemType
                                          , itemkey  => p_itemKey
                                          , aname    => 'IRC_MESSAGE_BODY'
                                          , avalue   => l_messageBody);
              l_message_type :=fnd_profile.value('IRC_NTF_WF_ITEM_TYPE');
              if l_eventName in ('INTVCRE','INTVUPD') and l_person_type <> 'DLINT' then
                l_ntf_message_type := 'IRC_MESSAGE_WITH_ATTACHMENT';
              elsif l_person_type <> 'CAND'  and l_eventName = 'APLFORJOB' then
                l_ntf_message_type := 'IRC_MESSAGE_WITH_ATTACHMENT';
              else
                l_ntf_message_type := 'IRC_MESSAGE';
              end if;

	       if ((l_person_type = 'CAND') and (l_eventName = 'APLSTACHG') and (l_oldExtStatus = l_newExtStatus)) then
                   null; --no operation
               else
                   l_notificationId:=wf_notification.send(  l_nextApprovers(1).name
                                   ,  l_message_type
                                   ,  l_ntf_message_type
                                   );
               end if;


              hr_utility.set_location('Notification ID : ' || l_notificationId,180);
              wf_notification.setAttrText (l_notificationId, '#FROM_ROLE', 'SYSADMIN');
              wf_notification.setAttrText(l_notificationId, 'SUBJECT', l_messageSubject);
              wf_notification.setAttrText(l_notificationId, 'TEXT_BODY', l_messageBody);
              wf_notification.setAttrText(l_notificationId, 'HTML_BODY', l_messageBody);
              if  l_ntf_message_type = 'IRC_MESSAGE_WITH_ATTACHMENT' then
                l_candidatePersonId := wf_engine.GetItemAttrText( itemtype => p_itemType
                                                    , itemkey  => p_itemKey
                                                    , aname => 'IRC_CAND_PER_ID');
                attachDocument(l_notificationId,l_candidatePersonId,l_eventName,p_itemKey,l_person_type);
              end if;
              wf_notification.denormalize_notification(l_notificationId);
            result := 'COMPLETE:IRC_E';
            hr_utility.set_location('Recipients Exist - Exiting:'|| g_package||'.'||l_proc, 200);
          end if;
        else
          hr_utility.set_location('No more Recipients - Exiting:'|| g_package||'.'||l_proc, 220);
          result := 'COMPLETE:IRC_NE';
        end if;
      else
        hr_utility.set_location('Profile value for AME Transaction Type not set - Exiting :'|| g_package||'.'||l_proc, 240);
        result := 'COMPLETE:IRC_NE';
      end if;
    exception
      when e_ameException then
        hr_utility.set_location('AME Error - Exiting:'|| g_package||'.'||l_proc, 260);
        hr_utility.set_location('Error Message:'|| SQLERRM, 270);
        result := 'COMPLETE:IRC_NE';
      when e_messageNameIsNull then
        hr_utility.set_location('Error - Skipping'|| g_package||'.'||l_proc, 300);
        hr_utility.set_location('Error Message:'|| 'FND message not defined for this recipient', 310);
        result := 'COMPLETE:IRC_E';
      when others then
        hr_utility.set_location('Error - Skipping:'|| g_package||'.'||l_proc, 350);
        hr_utility.set_location('Error Message:'|| SQLERRM, 360);
        result := 'COMPLETE:IRC_E';
  end getNextRecipient;
--+
--+ getWFAttrValue
--+
  function getWFAttrValue ( p_itemKey in varchar2
                          , p_WFAttr  in varchar2 ) return varchar2 is
    l_value varchar2(1000);
    l_proc constant varchar2(50) := 'getWFAttrValue';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      g_WFItemType := fnd_profile.value('IRC_NTF_WF_ITEM_TYPE');
      hr_utility.set_location('Workflow Attribute : '|| p_WFAttr, 20);
      l_value := wf_engine.getitemattrtext( itemtype => g_WFItemType
                                          , itemkey  => p_itemKey
                                          , aname    => p_WFAttr);
      hr_utility.set_location('Success - Exiting:'|| g_package||'.'||l_proc, 60);
      return l_value;
    exception
      when others then
        hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 100);
        hr_utility.set_location('Error Message : ' || sqlerrm, 110);
        return null;
  end getWFAttrValue;
--+
--+ isValidRecipient
--+
  function isValidRecipient (p_recipient in VARCHAR2) return varchar2
  is
    cursor csrRoleExists (c_orig_system in VARCHAR2, c_orig_system_id in number) is
      select count(*)
        from wf_roles
       where c_orig_system = orig_system
         and c_orig_system_id = orig_system_id
         and status = 'ACTIVE';
    l_roleExists number;
    l_orig_system varchar2(50);
    l_orig_system_id number;
    l_pos number;
    l_proc constant varchar2(50) := 'isValidRecipient';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      l_pos:=instr(p_recipient,':');
      l_orig_system:=substr(p_recipient,1,l_pos-1);
      l_orig_system_id:=substr(p_recipient,l_pos+1,length(p_recipient));
      open csrRoleExists(l_orig_system,l_orig_system_id);
      fetch csrRoleExists into l_roleExists;
      close csrRoleExists;
      if l_roleExists > 0 then
        return 'true';
      else
        return 'false';
      end if;
    exception
      when others then
        hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 50);
        hr_utility.set_location('Error Message : ' || sqlerrm, 60);
  end isValidRecipient;

  function checkIfIntvwCandidateIncluded ( p_modifiedItemsString varchar2
                                         , p_eventName varchar2)
    return varchar2 is
    cursor csrCheckModifiedItems(c_modifiedItemsString varchar2) is
      select 'true'
      from dual
      where instr(c_modifiedItemsString,',LOCATIONID,')>0
            OR instr(c_modifiedItemsString,',DATESTART,')>0
            OR instr(c_modifiedItemsString,',DATEEND,')>0
            OR instr(c_modifiedItemsString,',TIMEEND,')>0
            OR instr(c_modifiedItemsString,',TIMESTART,')>0
            OR instr(c_modifiedItemsString,',CONTACTTELEPHONENUMBER,')>0
            OR instr(c_modifiedItemsString,',INTERNALCONTACTPERSONID,')>0
            OR instr(c_modifiedItemsString,',EXTERNALCONTACT,')>0
            OR instr(c_modifiedItemsString,',NOTESTOCANDIDATE,')>0
            OR instr(c_modifiedItemsString,',CATEGORY,')>0
            OR instr(c_modifiedItemsString,',STATUS,')>0;
    l_includeCandidate varchar2(10);
    l_proc constant varchar2(50) := 'checkIfIntvwCandidateIncluded';
    begin
      hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
      if p_eventName =  'INTVCRE' then
        l_includeCandidate := 'true';
      else
      open csrCheckModifiedItems(',' || p_modifiedItemsString || ',');
      fetch csrCheckModifiedItems into l_includeCandidate;
      if csrCheckModifiedItems%NOTFOUND then
        l_includeCandidate := 'false';
      end if;
      close csrCheckModifiedItems;
      end if;
      return l_includeCandidate;
    exception
      when others then
        hr_utility.set_location('Error - Exiting:'|| g_package||'.'||l_proc, 50);
        hr_utility.set_location('Error Message : ' || sqlerrm, 60);
    end checkIfIntvwCandidateIncluded;

  procedure getDocument (p_documentId   in varchar2
                        ,p_displayType  in varchar2
                        ,p_document in  out nocopy varchar2
                        ,p_documentType in out nocopy varchar2) is
  begin
    p_document := p_documentId;
  end getDocument;
--+
  procedure attatchICDoc( document_id   IN VARCHAR2
                       ,display_type  IN VARCHAR2
                       ,document      IN OUT nocopy blob
                       ,document_type IN OUT nocopy VARCHAR2) is
    l_position number;
    l_item_key varchar2(100);
    l_notification_id varchar2(100);
    l_start_date date;
    l_end_date date;
    l_start_time varchar2(10);
    l_end_time varchar2(10);
    l_time_zone varchar2(100);
    l_subject varchar2(400);
    l_description varchar2(500);
    l_data varchar2(32000);
    l_ignore_time_zone boolean := false;
    l_time_zone_code fnd_timezones_vl.timezone_code%type;
    l_loc_description varchar2(240);
    l_proc varchar2(20) := 'attatchICDoc';
    cursor getTimezoneCode(c_timezoneNameIn in varchar2) is
      select timezone_code
        from fnd_timezones_vl
       where name = c_timezoneNameIn
        and rownum < 2;
  begin
    hr_utility.set_location('Entering:'|| g_package||'.'||l_proc, 10);
    l_position := instrb(document_id,':',1,1);
  -- heredocumentid represent the item key and notification_id, which is used to get the required values
    if l_position is null then
      return;
    else
      l_item_key := substr(document_id,1,l_position-1);
      l_notification_id := to_number(substr(document_id,l_position+1,length(document_id)));
    end if;
    hr_utility.set_location('getting the interview details', 20);
    l_start_date := wf_engine.GetItemAttrDate ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_DATE_START');
    l_end_date := wf_engine.GetItemAttrDate ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_DATE_END');
    l_start_time := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_TIME_START',ignore_notfound=>true);
    l_end_time := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_TIME_END',ignore_notfound=>true);
    l_time_zone := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_TIME_ZONE',ignore_notfound=>true);
    l_loc_description := wf_engine.getItemAttrText ( itemtype => 'IRC_NTF', itemkey  => l_item_key,aname => 'IRC_INTVW_LOC_DETAILS',ignore_notfound=>true);
    if l_time_zone is null then
      l_ignore_time_zone := true;
    else
      open getTimezoneCode(l_time_zone);
      fetch getTimezoneCode into l_time_zone_code;
      close getTimezoneCode;
      if l_time_zone_code is null then
        l_ignore_time_zone := true;
      end if;
    end if;
    l_subject := wf_notification.GetAttrText (nid => l_notification_id, aname => 'SUBJECT',ignore_notfound => true);
    --l_description := wf_notification.GetAttrText (nid => l_notification_id, aname => 'TEXT_BODY',ignore_notfound => true);
    hr_utility.set_location('Contructing the ics file', 20);
    per_calendar_util.calendar_generate_ical
      (DTSTARTDATE	=> l_start_date
      ,DTENDDATE 	=> l_end_date
      ,DTSTARTTIME 	=> l_start_time
      ,DTENDTIME	=> l_end_time
      ,DTTIMEFORMAT     => 'HH24:MI'
      ,TIMEZONE         => l_time_zone_code
      ,SUBJECT          => l_subject
      ,LOCATION         => l_loc_description
      ,IGNORE_TIME_ZONE => l_ignore_time_zone
      ,ICAL	        => l_data
      );
    document := to_blob(UTL_RAW.CAST_TO_RAW(l_data));
    document_type := 'text/calendar' || ';name=event.ics';
    hr_utility.set_location('completed:'|| g_package||'.'||l_proc, 30);
    exception
      when others then
        hr_utility.set_location('Error:'|| g_package||'.'||l_proc, 50);
        hr_utility.set_location('Error:'|| sqlerrm, 50);
  end attatchICDoc;
--+
end IRC_NOTIFICATION_WORKFLOW_PKG;

/
