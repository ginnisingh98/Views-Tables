--------------------------------------------------------
--  DDL for Package Body IRC_VACANCY_COMMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VACANCY_COMMIT" AS
/* $Header: ircvaccm.pkb 120.3 2006/04/01 01:52:18 mmillmor noship $ */
--
-- private function for 9i and 10g compatability
--
function valueOf(N xmldom.DOMNode, pattern varchar2)
return  varchar2 is
l_retval varchar2(32767);
begin
  xslprocessor.valueOf(N,pattern,l_retval);
  return l_retval;
end valueOf;

----------------------------------------------------------
----------------------------------------------------------
--                                                      --
--  This function can be called to check if there are   --
--  any errors in the stack.                            --
--                                                      --
--  It returns:                                         --
--  - TRUE if there are any errors in the stack.        --
--  - FALSE otherwise.                                  --
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
FUNCTION is_error_message return boolean IS
--
  l_no_of_messages number := 0;
  l_current_no number := 0;
  l_message varchar2(2000);
  l_message_type varchar2(1);
  l_error_found boolean := false;
--
BEGIN
--
hr_utility.trace('Entering is_error_message');
--
  l_no_of_messages := fnd_msg_pub.count_msg();
--
hr_utility.trace('Number of messages found :' || to_char(l_no_of_messages) || ':');
--
  while(l_current_no < l_no_of_messages)
  loop
    if l_current_no = 0
    then
      l_message := fnd_msg_pub.get_detail(fnd_msg_pub.g_first);
    else
      l_message := fnd_msg_pub.get_detail(fnd_msg_pub.g_next);
    end if;
--
    fnd_message.set_encoded(l_message);
    l_message_type := fnd_message.get_token('FND_MESSAGE_TYPE','Y');
--
    if l_message_type = 'E'
    then
--
hr_utility.trace('Error message found');
--
      l_error_found := true;
      exit;
    end if;
--
    l_current_no := l_current_no + 1;
  end loop;
--
hr_utility.trace('Exiting is_error_message');
--
  return l_error_found;
--
end is_error_message;
--
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
--  This Procedure can be called when an approver has   --
--  rejected the transaction outright.                  --
--                                                      --
--  It performs the following functions:                --
--  - it updates the AME transaction as 'REJECTED'.     --
--  - it removes the HR_WIP_TRANSACTION record          --
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
--
procedure reject_transaction (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2) is
--
BEGIN
--
hr_utility.trace('Entering reject_transaction');
--
-- Mark Approval as Rejected
--
-- mmillmor commented out the following to make this compile
-- with the new approvals code
--  IRC_APPROVALS.updateAsRejected
--    (itemtype, itemkey, actid, funcmode, resultout);
--
-- Remove hr_wip_transaction record
--
   hr_wip_txns.delete_transaction(
        p_item_type  => itemtype
       ,p_item_key   => itemkey);
--
hr_utility.trace('Exiting reject_transaction');
--
----------------------------------------------------------
END reject_transaction;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
--
procedure commit_insert (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2) is
--
  transaction_number number;
  transaction_id     varchar2(30);
--
  parser xmlparser.Parser;
  xmldoc xmldom.DOMDocument;
  xmlelt xmldom.DOMElement;
  XMLParseError EXCEPTION;
  xmlClob CLOB;
  wellFormed BOOLEAN;
  error VARCHAR2(4000);
  errorFlag BOOLEAN;
  nodeName varchar2(240);
--
  commitNodes xmldom.DOMNodeList;
  commitNode xmldom.DOMNode;
--
  internal_date_change     number;
  external_date_change     number;
  dummyVarchar    varchar2(20);
  l_return_status varchar2(1);
--
  internalStartDate date;
  l_effective_date date;
--
  PRAGMA EXCEPTION_INIT(XMLParseError, -20100);
--
BEGIN
--
hr_utility.trace('Entering commit_insert for :' || itemtype || '-' || itemkey || ':');
--
  savepoint vacancy_commit;
--
  errorFlag := false;
--
  if (isSelfApprove(itemtype, itemkey)) then
--
hr_utility.trace('Exiting - Self Approve');
--
    resultout := 'SELF';
    return;
  end if;
--
  l_effective_date := to_date(
                      wf_engine.getItemAttrText
                      (itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'IRC_EFFECTIVE_DATE'), 'YYYY-MM-DD');
--
hr_utility.trace('Effective date is :' || to_char(l_effective_date) || ':');
--
  select transaction_id
    into transaction_number
    from hr_wip_transactions
   where item_key = itemkey
     and item_type = itemtype;
--
  transaction_id := to_char(transaction_number);
--
hr_utility.trace('Transaction Id is :' || transaction_id || ':');
--
  select vo_cache
    into xmlClob
    from hr_wip_transactions
   where transaction_id = transaction_number;
--
  parser := xmlparser.newParser;
--
  xmlparser.ParseCLOB(parser,xmlClob);
  xmldoc := xmlparser.getDocument(parser);
--
  l_return_status := 'S';
--
hr_utility.trace('Inserting PER_REQUISITIONS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRequisitionsVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_requisition(commitNode, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting PER_REQUISITIONS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting IRC_POSTING_CONTENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcPostingContentsVlVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_posting_content(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting IRC_POSTING_CONTENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting PER_ALL_VACANCIES records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditVacancyVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_vacancy(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting PER_ALL_VACANCIES records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting IRC_SEARCH_CRITERIA records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVacancySearchCriteriaVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_search_criteria(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting IRC_SEARCH_CRITERIA records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting IRC_VARIABLE_COMP_ELEMENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVariableCompElementsVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_variable_comp_element(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting IRC_VARIABLE_COMP_ELEMENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting PER_COMPETENCE_ELEMENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVacancyCompetenceVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_competence_element(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting PER_COMPETENCE_ELEMENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting IRC_REC_TEAM_MEMBERS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcRecTeamDisplayVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_rec_team_member(commitNode, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting IRC_REC_TEAM_MEMBERS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting IRC_AGENCY_VACANCY records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'AgencyVacanciesVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_agency_vacancy(commitNode, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting IRC_AGENCY_VACANCY records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting PER_RECRUITMENT_ACTIVITIES records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRecruitmentActivitiesVORow');
--
  get_date_changes (commitNodes, external_date_change, internal_date_change);
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (is_site_internal(valueOf(commitNode,'RecruitingSiteId')) = 'I') then
hr_utility.trace('Committing internal site');
      commit_i_recruitment_activity(commitNode, internal_date_change, l_return_status);
    else
hr_utility.trace('Committing external site');
      commit_i_recruitment_activity(commitNode, external_date_change, l_return_status);
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting PER_RECRUITMENT_ACTIVITIES records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Inserting PER_RECRUITMENT_ACTIVITY_FOR records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRecruitmentActivityForVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_i_rec_activity_for(commitNode, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Inserting PER_RECRUITMENT_ACTIVITY_FOR records');
       errorFlag := true;
    end if;
  end loop;
--
  xmlparser.freeParser(parser);
  wellFormed := TRUE;
--
  if(errorFlag) then
  --
hr_utility.trace('Error found');
--
    error := get_error(itemtype, itemkey);
    rollback to vacancy_commit;
    set_up_error_message(itemtype, itemkey, error);
    resultout := 'COMMITERROR';
  --
  else
  --
hr_utility.trace('No error found');
  --
  -- Remove hr_wip_transaction record
  --
    hr_wip_txns.delete_transaction(
         p_item_type  => itemtype
        ,p_item_key   => itemkey);
  --
    resultout := 'OK';
  end if;
--
hr_utility.trace('Exiting commit_insert');
--
EXCEPTION
--
WHEN XMLParseError THEN
--
hr_utility.trace('XMLParseError found');
--
  xmlparser.freeParser(parser);
  wellFormed := FALSE;
  error := SQLERRM;
  --
  rollback to vacancy_commit;
  set_up_error_message(itemtype, itemkey, error);
  resultout := 'COMMITERROR';
  --
WHEN others THEN
--
hr_utility.trace('other error found');
--
  error := SQLERRM;
  rollback to vacancy_commit;
  set_up_error_message(itemtype, itemkey, error);
  resultout := 'COMMITERROR';
--
----------------------------------------------------------
END commit_insert;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
--
procedure commit_update (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2) is
--
  transaction_number number;
  transaction_id     varchar2(30);
--
  parser xmlparser.Parser;
  xmldoc xmldom.DOMDocument;
  xmlelt xmldom.DOMElement;
  XMLParseError EXCEPTION;
  xmlClob CLOB;
  wellFormed BOOLEAN;
  error VARCHAR2(240);
  nodeName varchar2(240);
  errorFlag BOOLEAN;
--
  commitNodes xmldom.DOMNodeList;
  commitNode xmldom.DOMNode;
--
  dummyVarchar varchar2(20);
  l_return_status varchar2(1);
  l_effective_date date;
--
  PRAGMA EXCEPTION_INIT(XMLParseError, -20100);
--
BEGIN
--
hr_utility.trace('Entering commit_update');
--
  savepoint vacancy_commit;
  errorFlag := false;
--
  if (isSelfApprove(itemtype, itemkey)) then
--
hr_utility.trace('Exiting - Self Approve');
--
    resultout := 'SELF';
    return;
  end if;
--
  l_effective_date := to_date(
                      wf_engine.getItemAttrText
                      (itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'IRC_EFFECTIVE_DATE'), 'YYYY-MM-DD');
--
hr_utility.trace('Effective date is :' || to_char(l_effective_date) || ':');
--
  select transaction_id
    into transaction_number
    from hr_wip_transactions
   where item_key = itemkey
     and item_type = itemtype;
--
  transaction_id := to_char(transaction_number);
--
hr_utility.trace('Transaction Id is :' || transaction_id || ':');
--
  select vo_cache
    into xmlClob
    from hr_wip_transactions
   where transaction_id = transaction_number;
--
  parser := xmlparser.newParser;
--
  xmlparser.ParseCLOB(parser,xmlClob);
  xmldoc := xmlparser.getDocument(parser);
--
  l_return_status := 'S';
--
hr_utility.trace('Updating PER_REQUISITIONS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRequisitionsVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_u_requisition(commitNode, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating PER_REQUISITIONS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating IRC_POSTING_CONTENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcPostingContentsVlVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if(found_IrcPostingContent(commitNode)) then
      commit_u_posting_content(commitNode, l_return_status);
    else
      commit_i_posting_content(commitNode, l_effective_date, l_return_status);
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating IRC_POSTING_CONTENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating PER_ALL_VACANCIES records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditVacancyVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    commit_u_vacancy(commitNode, l_effective_date, l_return_status);
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating PER_ALL_VACANCIES records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating IRC_SEARCH_CRITERIA records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVacancySearchCriteriaVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (found_IrcSearchCriteria(commitNode)) then
      commit_u_search_criteria(commitNode, l_effective_date, l_return_status);
    else
      commit_i_search_criteria(commitNode, l_effective_date, l_return_status);
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating IRC_SEARCH_CRITERIA records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating IRC_VARIABLE_COMP_ELEMENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVariableCompElementsVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_variable_comp_element(commitNode, l_return_status);
    else
      if (not found_IrcVariableCompElements(commitNode)) then
        commit_i_variable_comp_element(commitNode, l_effective_date, l_return_status);
      end if;
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating IRC_VARIABLE_COMP_ELEMENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating PER_COMPETENCE_ELEMENTS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcVacancyCompetenceVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_competence_element(commitNode, l_return_status);
    else
      if (found_IrcVacancyCompetence(commitNode)) then
        commit_u_competence_element(commitNode, l_effective_date, l_return_status);
      else
        commit_i_competence_element(commitNode, l_effective_date, l_return_status);
      end if;
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating PER_COMPETENCE_ELEMENTS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating IRC_REC_TEAM_MEMBERS records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcRecTeamDisplayVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_rec_team_member(commitNode, l_return_status);
    else
      if (found_IrcRecTeamDisplay(commitNode)) then
        commit_u_rec_team_member(commitNode, l_return_status);
      else
        commit_i_rec_team_member(commitNode, l_return_status);
      end if;
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating IRC_REC_TEAM_MEMBERS records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Updating IRC_AGENCY_VACANCY records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'AgencyVacanciesVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
    commitNode:=xmldom.item(commitNodes,j-1);
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_agency_vacancy(commitNode, l_return_status);
    else
      if (found_agency_vacancy(commitNode)) then
        commit_u_agency_vacancy(commitNode, l_return_status);
      else
        commit_i_agency_vacancy(commitNode, l_return_status);
      end if;
    end if;
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating IRC_AGENCY_VACANCY records');
       errorFlag := true;
    end if;
  end loop;
--
hr_utility.trace('Deleting PER_RECRUITMENT_ACTIVITY_FOR records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRecruitmentActivityForVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
--
    commitNode:=xmldom.item(commitNodes,j-1);
--
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_rec_activity_for(commitNode, l_return_status);
      if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Deleting PER_RECRUITMENT_ACTIVITY_FOR records');
         errorFlag := true;
      end if;
    end if;
--
  end loop;
--
hr_utility.trace('Updating PER_RECRUITMENT_ACTIVITIES records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRecruitmentActivitiesVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
--
    commitNode:=xmldom.item(commitNodes,j-1);
--
    if (valueOf(commitNode,'@bc4j-action') = 'remove') then
      commit_d_recruitment_activity(commitNode, l_return_status);
    else
      if (found_rec_activity(commitNode)) then
        commit_u_recruitment_activity(commitNode, l_return_status);
      else
        commit_i_recruitment_activity(commitNode, 0, l_return_status);
      end if;
    end if;
--
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating PER_RECRUITMENT_ACTIVITIES records');
       errorFlag := true;
    end if;
--
  end loop;
--
hr_utility.trace('Updating PER_RECRUITMENT_ACTIVITY_FOR records');
--
  commitNodes := xmldom.getElementsByTagName(xmldoc, 'IrcEditRecruitmentActivityForVORow');
--
  for j in 1..xmldom.getLength(commitNodes) loop
--
    commitNode:=xmldom.item(commitNodes,j-1);
--
    if (nvl(valueOf(commitNode,'@bc4j-action'),' ') <> 'remove') then
      if (not found_rec_activity_for(commitNode)) then
        commit_i_rec_activity_for(commitNode, l_return_status);
      end if;
    end if;
--
    if (l_return_status <> 'S' and is_error_message) then
hr_utility.trace('ERROR Updating PER_RECRUITMENT_ACTIVITY_FOR records');
       errorFlag := true;
    end if;
  end loop;
--
--
  xmlparser.freeParser(parser);
  wellFormed := TRUE;
--
  if(errorFlag) then
  --
hr_utility.trace('Error found');
  --
    error := get_error(itemtype, itemkey);
    rollback to vacancy_commit;
    set_up_error_message(itemtype, itemkey, error);
    resultout := 'COMMITERROR';
  --
  else
  --
hr_utility.trace('No error found');
  --
  -- Remove hr_wip_transaction record
  --
    hr_wip_txns.delete_transaction(
         p_item_type  => itemtype
        ,p_item_key   => itemkey);
    resultout := 'OK';
--
  end if;
--
hr_utility.trace('Exiting commit_update');
--
EXCEPTION
--
WHEN XMLParseError THEN
--
hr_utility.trace('XMLParseError found');
--
  xmlparser.freeParser(parser);
  wellFormed := FALSE;
  error := SQLERRM;
  rollback to vacancy_commit;
  set_up_error_message(itemtype, itemkey, error);
  resultout := 'COMMITERROR';
  --
WHEN others then
--
hr_utility.trace('other error found');
--
  error := SQLERRM;
  rollback to vacancy_commit;
  set_up_error_message(itemtype, itemkey, error);
  resultout := 'COMMITERROR';
--
----------------------------------------------------------
END commit_update;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_requisition (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_requisition');
--
l_object_version_number := to_number(valueOf(commitNode,'ObjectVersionNumber'));
--
per_requisitions_swi.create_requisition (
   P_BUSINESS_GROUP_ID      => valueOf(commitNode,'BusinessGroupId')
  ,P_DATE_FROM              => date_value(valueOf(commitNode,'DateFrom'))
  ,P_NAME                   => valueOf(commitNode,'Name')
  ,P_PERSON_ID              => valueOf(commitNode,'PersonId')
  ,P_COMMENTS               => valueOf(commitNode,'Comments')
  ,P_DATE_TO                => date_value(valueOf(commitNode,'DateTo'))
  ,P_DESCRIPTION            => valueOf(commitNode,'Description')
  ,P_ATTRIBUTE_CATEGORY     => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1             => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2             => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3             => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4             => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5             => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6             => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7             => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8             => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9             => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10            => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11            => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12            => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13            => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14            => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15            => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16            => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17            => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18            => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19            => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20            => valueOf(commitNode,'Attribute20')
  ,P_REQUISITION_ID         => valueOf(commitNode,'RequisitionId')
  ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE               => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_requisition');
--
----------------------------------------------------------
END commit_i_requisition;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_requisition (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_d_requisition');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_requisitions_swi.delete_requisition (
   P_REQUISITION_ID        => valueOf(commitNode,'RequisitionId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => valueOf(commitNode,''));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_requisition');
--
----------------------------------------------------------
END commit_d_requisition;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_requisition (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_u_requisition');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_requisitions_swi.update_requisition (
   P_REQUISITION_ID       => valueOf(commitNode,'RequisitionId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_DATE_FROM            => date_value(valueOf(commitNode,'DateFrom'))
  ,P_PERSON_ID            => valueOf(commitNode,'PersonId')
  ,P_COMMENTS             => valueOf(commitNode,'Comments')
  ,P_DATE_TO              => date_value(valueOf(commitNode,'DateTo'))
  ,P_DESCRIPTION          => valueOf(commitNode,'Description')
  ,P_ATTRIBUTE_CATEGORY => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1           => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2           => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3           => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4           => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5           => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6           => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7           => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8           => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9           => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10          => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11          => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12          => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13          => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14          => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15          => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16          => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17          => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18          => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19          => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20          => valueOf(commitNode,'Attribute20')
  ,P_RETURN_STATUS        => l_return_status
  ,P_VALIDATE             => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_requisition');
--
----------------------------------------------------------
END commit_u_requisition;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_vacancy (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_vacancy');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_vacancy_swi.CREATE_VACANCY (
   P_REQUISITION_ID               => valueOf(commitNode,'RequisitionId')
  ,P_DATE_FROM                    => date_value(valueOf(commitNode,'DateFrom'))
  ,P_NAME                         => valueOf(commitNode,'Name')
  ,P_SECURITY_METHOD              => valueOf(commitNode,'SecurityMethod')
  ,P_BUSINESS_GROUP_ID            => valueOf(commitNode,'BusinessGroupId')
  ,P_POSITION_ID                  => valueOf(commitNode,'PositionId')
  ,P_JOB_ID                       => valueOf(commitNode,'JobId')
  ,P_GRADE_ID                     => valueOf(commitNode,'GradeId')
  ,P_ORGANIZATION_ID              => valueOf(commitNode,'OrganizationId')
  ,P_PEOPLE_GROUP_ID              => valueOf(commitNode,'PeopleGroupId')
  ,P_LOCATION_ID                  => valueOf(commitNode,'LocationId')
  ,P_RECRUITER_ID                 => valueOf(commitNode,'RecruiterId')
  ,P_DATE_TO                      => date_value(valueOf(commitNode,'DateTo'))
  ,P_DESCRIPTION                  => valueOf(commitNode,'Description')
  ,P_NUMBER_OF_OPENINGS           => valueOf(commitNode,'NumberOfOpenings')
  ,P_STATUS                       => 'APPROVED'
  ,P_BUDGET_MEASUREMENT_TYPE      => valueOf(commitNode,'BudgetMeasurementType')
  ,P_BUDGET_MEASUREMENT_VALUE     => valueOf(commitNode,'BudgetMeasurementValue')
  ,P_VACANCY_CATEGORY             => valueOf(commitNode,'VacancyCategory')
  ,P_MANAGER_ID                   => valueOf(commitNode,'ManagerId')
  ,P_PRIMARY_POSTING_ID           => valueOf(commitNode,'PrimaryPostingId')
  ,P_ASSESSMENT_ID                => valueOf(commitNode,'AssessmentId')
  ,P_ATTRIBUTE_CATEGORY           => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                   => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                   => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                   => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                   => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                   => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                   => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                   => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                   => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                   => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10                  => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11                  => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12                  => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13                  => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14                  => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15                  => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16                  => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17                  => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18                  => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19                  => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20                  => valueOf(commitNode,'Attribute20')
  ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
  ,P_VACANCY_ID                   => valueOf(commitNode,'VacancyId')
  ,P_RETURN_STATUS                => l_return_status
  ,P_VALIDATE                     => g_validate
  ,P_EFFECTIVE_DATE               => l_effective_date);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_vacancy');
--
----------------------------------------------------------
END commit_i_vacancy;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_vacancy (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
l_inv_pos_grade_warning boolean;
l_inv_job_grade_warning boolean;
l_assignment_changed number;
l_return_status varchar2(1);
l_object_version_number number;
status varchar2(20);
--
BEGIN
--
hr_utility.trace('Entering commit_u_vacancy');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
  status := valueOf(commitNode,'StatusCode');
  if (status = 'PENDING') then
    status := 'APPROVED';
  end if;
--
per_vacancy_swi.UPDATE_VACANCY (
   P_VACANCY_ID                   => valueOf(commitNode,'VacancyId')
  ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
  ,P_DATE_FROM                    => date_value(valueOf(commitNode,'DateFrom'))
  ,P_POSITION_ID                  => valueOf(commitNode,'PositionId')
  ,P_JOB_ID                       => valueOf(commitNode,'JobId')
  ,P_GRADE_ID                     => valueOf(commitNode,'GradeId')
  ,P_ORGANIZATION_ID              => valueOf(commitNode,'OrganizationId')
  ,P_PEOPLE_GROUP_ID              => valueOf(commitNode,'PeopleGroupId')
  ,P_LOCATION_ID                  => valueOf(commitNode,'LocationId')
  ,P_RECRUITER_ID                 => valueOf(commitNode,'RecruiterId')
  ,P_DATE_TO                      => date_value(valueOf(commitNode,'DateTo'))
  ,P_SECURITY_METHOD              => valueOf(commitNode,'SecurityMethod')
  ,P_DESCRIPTION                  => valueOf(commitNode,'Description')
  ,P_NUMBER_OF_OPENINGS           => valueOf(commitNode,'NumberOfOpenings')
  ,P_STATUS                       => status
  ,P_BUDGET_MEASUREMENT_TYPE      => valueOf(commitNode,'BudgetMeasurementType')
  ,P_BUDGET_MEASUREMENT_VALUE     => valueOf(commitNode,'BudgetMeasurementValue')
  ,P_VACANCY_CATEGORY             => valueOf(commitNode,'VacancyCategory')
  ,P_MANAGER_ID                   => valueOf(commitNode,'ManagerId')
  ,P_PRIMARY_POSTING_ID           => valueOf(commitNode,'PrimaryPostingId')
  ,P_ASSESSMENT_ID                => valueOf(commitNode,'AssessmentId')
  ,P_ATTRIBUTE_CATEGORY           => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                   => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                   => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                   => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                   => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                   => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                   => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                   => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                   => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                   => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10                  => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11                  => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12                  => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13                  => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14                  => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15                  => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16                  => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17                  => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18                  => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19                  => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20                  => valueOf(commitNode,'Attribute20')
  ,P_ASSIGNMENT_CHANGED           => l_assignment_changed
  ,P_RETURN_STATUS                => l_return_status
  ,P_VALIDATE                     => g_validate
  ,P_EFFECTIVE_DATE               => l_effective_date);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_vacancy');
--
----------------------------------------------------------
END commit_u_vacancy;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_search_criteria (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_search_criteria');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_search_criteria_swi.create_vacancy_criteria (
   P_VACANCY_ID                => valueOf(commitNode,'ObjectId')
  ,P_EFFECTIVE_DATE            => l_effective_date
  ,P_LOCATION                  => valueOf(commitNode,'Location')
  ,P_EMPLOYEE                  => valueOf(commitNode,'Employee')
  ,P_CONTRACTOR                => valueOf(commitNode,'Contractor')
  ,P_EMPLOYMENT_CATEGORY       => valueOf(commitNode,'EmploymentCategory')
  ,P_KEYWORDS                  => valueOf(commitNode,'Keywords')
  ,P_TRAVEL_PERCENTAGE         => valueOf(commitNode,'TravelPercentage')
  ,P_MIN_SALARY                => valueOf(commitNode,'MinSalary')
  ,P_MAX_SALARY                => valueOf(commitNode,'MaxSalary')
  ,P_SALARY_CURRENCY           => valueOf(commitNode,'SalaryCurrency')
  ,P_SALARY_PERIOD             => valueOf(commitNode,'SalaryPeriod')
  ,P_PROFESSIONAL_AREA         => valueOf(commitNode,'ProfessionalArea')
  ,P_WORK_AT_HOME              => valueOf(commitNode,'WorkAtHome')
  ,P_MIN_QUAL_LEVEL            => valueOf(commitNode,'MinQualLevel')
  ,P_MAX_QUAL_LEVEL            => valueOf(commitNode,'MaxQualLevel')
  ,P_ATTRIBUTE_CATEGORY        => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10               => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11               => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12               => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13               => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14               => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15               => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16               => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17               => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18               => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19               => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20               => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21               => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22               => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23               => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24               => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25               => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26               => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27               => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28               => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29               => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30               => valueOf(commitNode,'Attribute30')
  ,P_ISC_INFORMATION_CATEGORY  => valueOf(commitNode,'IscInformationCategory')
  ,P_ISC_INFORMATION1          => valueOf(commitNode,'IscInformation1')
  ,P_ISC_INFORMATION2          => valueOf(commitNode,'IscInformation2')
  ,P_ISC_INFORMATION3          => valueOf(commitNode,'IscInformation3')
  ,P_ISC_INFORMATION4          => valueOf(commitNode,'IscInformation4')
  ,P_ISC_INFORMATION5          => valueOf(commitNode,'IscInformation5')
  ,P_ISC_INFORMATION6          => valueOf(commitNode,'IscInformation6')
  ,P_ISC_INFORMATION7          => valueOf(commitNode,'IscInformation7')
  ,P_ISC_INFORMATION8          => valueOf(commitNode,'IscInformation8')
  ,P_ISC_INFORMATION9          => valueOf(commitNode,'IscInformation9')
  ,P_ISC_INFORMATION10         => valueOf(commitNode,'IscInformation10')
  ,P_ISC_INFORMATION11         => valueOf(commitNode,'IscInformation11')
  ,P_ISC_INFORMATION12         => valueOf(commitNode,'IscInformation12')
  ,P_ISC_INFORMATION13         => valueOf(commitNode,'IscInformation13')
  ,P_ISC_INFORMATION14         => valueOf(commitNode,'IscInformation14')
  ,P_ISC_INFORMATION15         => valueOf(commitNode,'IscInformation15')
  ,P_ISC_INFORMATION16         => valueOf(commitNode,'IscInformation16')
  ,P_ISC_INFORMATION17         => valueOf(commitNode,'IscInformation17')
  ,P_ISC_INFORMATION18         => valueOf(commitNode,'IscInformation18')
  ,P_ISC_INFORMATION19         => valueOf(commitNode,'IscInformation19')
  ,P_ISC_INFORMATION20         => valueOf(commitNode,'IscInformation20')
  ,P_ISC_INFORMATION21         => valueOf(commitNode,'IscInformation21')
  ,P_ISC_INFORMATION22         => valueOf(commitNode,'IscInformation22')
  ,P_ISC_INFORMATION23         => valueOf(commitNode,'IscInformation23')
  ,P_ISC_INFORMATION24         => valueOf(commitNode,'IscInformation24')
  ,P_ISC_INFORMATION25         => valueOf(commitNode,'IscInformation25')
  ,P_ISC_INFORMATION26         => valueOf(commitNode,'IscInformation26')
  ,P_ISC_INFORMATION27         => valueOf(commitNode,'IscInformation27')
  ,P_ISC_INFORMATION28         => valueOf(commitNode,'IscInformation28')
  ,P_ISC_INFORMATION29         => valueOf(commitNode,'IscInformation29')
  ,P_ISC_INFORMATION30         => valueOf(commitNode,'IscInformation30')
  ,P_OBJECT_VERSION_NUMBER     => l_object_version_number
  ,P_RETURN_STATUS             => l_return_status
  ,P_VALIDATE                  => g_validate
  ,P_SEARCH_CRITERIA_ID        => valueOf(commitNode,'SearchCriteriaId')
  ,P_DESCRIPTION               => valueOf(commitNode,'Description'));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_search_criteria');
--
----------------------------------------------------------
END commit_i_search_criteria;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_search_criteria (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_d_search_criteria');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_search_criteria_swi.delete_vacancy_criteria (
   P_SEARCH_CRITERIA_ID    => valueOf(commitNode,'SearchCriteriaId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS         => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_search_criteria');
--
----------------------------------------------------------
END commit_d_search_criteria;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_search_criteria (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_u_search_criteria');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_search_criteria_swi.update_vacancy_criteria (
   P_VACANCY_ID               => valueOf(commitNode,'ObjectId')
  ,P_EFFECTIVE_DATE           => l_effective_date
  ,P_LOCATION                 => valueOf(commitNode,'Location')
  ,P_EMPLOYEE                 => valueOf(commitNode,'Employee')
  ,P_CONTRACTOR               => valueOf(commitNode,'Contractor')
  ,P_EMPLOYMENT_CATEGORY      => valueOf(commitNode,'EmploymentCategory')
  ,P_KEYWORDS                 => valueOf(commitNode,'Keywords')
  ,P_TRAVEL_PERCENTAGE        => valueOf(commitNode,'TravelPercentage')
  ,P_MIN_SALARY               => valueOf(commitNode,'MinSalary')
  ,P_MAX_SALARY               => valueOf(commitNode,'MaxSalary')
  ,P_SALARY_CURRENCY          => valueOf(commitNode,'SalaryCurrency')
  ,P_SALARY_PERIOD            => valueOf(commitNode,'SalaryPeriod')
  ,P_PROFESSIONAL_AREA        => valueOf(commitNode,'ProfessionalArea')
  ,P_WORK_AT_HOME             => valueOf(commitNode,'WorkAtHome')
  ,P_MIN_QUAL_LEVEL           => valueOf(commitNode,'MinQualLevel')
  ,P_MAX_QUAL_LEVEL           => valueOf(commitNode,'MaxQualLevel')
  ,P_ATTRIBUTE_CATEGORY       => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1               => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2               => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3               => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4               => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5               => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6               => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7               => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8               => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9               => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10              => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11              => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12              => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13              => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14              => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15              => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16              => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17              => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18              => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19              => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20              => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21              => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22              => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23              => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24              => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25              => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26              => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27              => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28              => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29              => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30              => valueOf(commitNode,'Attribute30')
  ,P_ISC_INFORMATION_CATEGORY => valueOf(commitNode,'IscInformationCategory')
  ,P_ISC_INFORMATION1         => valueOf(commitNode,'IscInformation1')
  ,P_ISC_INFORMATION2         => valueOf(commitNode,'IscInformation2')
  ,P_ISC_INFORMATION3         => valueOf(commitNode,'IscInformation3')
  ,P_ISC_INFORMATION4         => valueOf(commitNode,'IscInformation4')
  ,P_ISC_INFORMATION5         => valueOf(commitNode,'IscInformation5')
  ,P_ISC_INFORMATION6         => valueOf(commitNode,'IscInformation6')
  ,P_ISC_INFORMATION7         => valueOf(commitNode,'IscInformation7')
  ,P_ISC_INFORMATION8         => valueOf(commitNode,'IscInformation8')
  ,P_ISC_INFORMATION9         => valueOf(commitNode,'IscInformation9')
  ,P_ISC_INFORMATION10        => valueOf(commitNode,'IscInformation10')
  ,P_ISC_INFORMATION11        => valueOf(commitNode,'IscInformation11')
  ,P_ISC_INFORMATION12        => valueOf(commitNode,'IscInformation12')
  ,P_ISC_INFORMATION13        => valueOf(commitNode,'IscInformation13')
  ,P_ISC_INFORMATION14        => valueOf(commitNode,'IscInformation14')
  ,P_ISC_INFORMATION15        => valueOf(commitNode,'IscInformation15')
  ,P_ISC_INFORMATION16        => valueOf(commitNode,'IscInformation16')
  ,P_ISC_INFORMATION17        => valueOf(commitNode,'IscInformation17')
  ,P_ISC_INFORMATION18        => valueOf(commitNode,'IscInformation18')
  ,P_ISC_INFORMATION19        => valueOf(commitNode,'IscInformation19')
  ,P_ISC_INFORMATION20        => valueOf(commitNode,'IscInformation20')
  ,P_ISC_INFORMATION21        => valueOf(commitNode,'IscInformation21')
  ,P_ISC_INFORMATION22        => valueOf(commitNode,'IscInformation22')
  ,P_ISC_INFORMATION23        => valueOf(commitNode,'IscInformation23')
  ,P_ISC_INFORMATION24        => valueOf(commitNode,'IscInformation24')
  ,P_ISC_INFORMATION25        => valueOf(commitNode,'IscInformation25')
  ,P_ISC_INFORMATION26        => valueOf(commitNode,'IscInformation26')
  ,P_ISC_INFORMATION27        => valueOf(commitNode,'IscInformation27')
  ,P_ISC_INFORMATION28        => valueOf(commitNode,'IscInformation28')
  ,P_ISC_INFORMATION29        => valueOf(commitNode,'IscInformation29')
  ,P_ISC_INFORMATION30        => valueOf(commitNode,'IscInformation30')
  ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
  ,P_RETURN_STATUS            => l_return_status
  ,P_VALIDATE                 => g_validate
  ,P_SEARCH_CRITERIA_ID       => valueOf(commitNode,'SearchCriteriaId')
  ,P_DESCRIPTION              => valueOf(commitNode,'Description'));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_search_criteria');
--
----------------------------------------------------------
END commit_u_search_criteria;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_competence_element (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_competence_element');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
hr_competence_element_swi.create_competence_element (
   P_COMPETENCE_ELEMENT_ID        => valueOf(commitNode,'CompetenceElementId')
  ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
  ,P_TYPE                         => valueOf(commitNode,'Type')
  ,P_BUSINESS_GROUP_ID            => valueOf(commitNode,'BusinessGroupId')
  ,P_ENTERPRISE_ID                => valueOf(commitNode,'EnterpriseId')
  ,P_COMPETENCE_ID                => valueOf(commitNode,'CompetenceId')
  ,P_PROFICIENCY_LEVEL_ID         => valueOf(commitNode,'ProficiencyLevelId')
  ,P_HIGH_PROFICIENCY_LEVEL_ID    => valueOf(commitNode,'HighProficiencyLevelId')
  ,P_WEIGHTING_LEVEL_ID           => valueOf(commitNode,'WeightingLevelId')
  ,P_RATING_LEVEL_ID              => valueOf(commitNode,'RatingLevelId')
  ,P_PERSON_ID                    => valueOf(commitNode,'PersonId')
  ,P_JOB_ID                       => valueOf(commitNode,'JobId')
  ,P_VALID_GRADE_ID               => valueOf(commitNode,'ValidGradeId')
  ,P_POSITION_ID                  => valueOf(commitNode,'PositionId')
  ,P_ORGANIZATION_ID              => valueOf(commitNode,'OrganizationId')
  ,P_PARENT_COMPETENCE_ELEMENT_ID => valueOf(commitNode,'ParentCompetenceElementId')
  ,P_ACTIVITY_VERSION_ID          => valueOf(commitNode,'ActivityVersionId')
  ,P_ASSESSMENT_ID                => valueOf(commitNode,'AssessmentId')
  ,P_ASSESSMENT_TYPE_ID           => valueOf(commitNode,'AssessmentTypeId')
  ,P_MANDATORY                    => valueOf(commitNode,'Mandatory')
  ,P_EFFECTIVE_DATE_FROM          => valueOf(commitNode,'EffectiveDateFrom')
  ,P_EFFECTIVE_DATE_TO            => valueOf(commitNode,'EffectiveDateTo')
  ,P_GROUP_COMPETENCE_TYPE        => valueOf(commitNode,'GroupCompetenceType')
  ,P_COMPETENCE_TYPE              => valueOf(commitNode,'CompetenceType')
  ,P_NORMAL_ELAPSE_DURATION       => valueOf(commitNode,'NormalElapseDuration')
  ,P_NORMAL_ELAPSE_DURATION_UNIT  => valueOf(commitNode,'NormalElapseDurationUnit')
  ,P_SEQUENCE_NUMBER              => valueOf(commitNode,'SequenceNumber')
  ,P_SOURCE_OF_PROFICIENCY_LEVEL  => valueOf(commitNode,'SourceOfProficiencyLevel')
  ,P_LINE_SCORE                   => valueOf(commitNode,'LineScore')
  ,P_CERTIFICATION_DATE           => date_value(valueOf(commitNode,'CertificationDate'))
  ,P_CERTIFICATION_METHOD         => valueOf(commitNode,'CertificationMethod')
  ,P_NEXT_CERTIFICATION_DATE      => valueOf(commitNode,'NextCertificationDate')
  ,P_COMMENTS                     => valueOf(commitNode,'Comments')
  ,P_ATTRIBUTE_CATEGORY           => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                   => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                   => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                   => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                   => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                   => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                   => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                   => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                   => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                   => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10                  => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11                  => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12                  => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13                  => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14                  => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15                  => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16                  => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17                  => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18                  => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19                  => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20                  => valueOf(commitNode,'Attribute20')
  ,P_EFFECTIVE_DATE               => l_effective_date
  ,P_OBJECT_ID                    => valueOf(commitNode,'ObjectId')
  ,P_OBJECT_NAME                  => valueOf(commitNode,'ObjectName')
  ,P_PARTY_ID                     => valueOf(commitNode,'PartyId')
  ,P_RETURN_STATUS                => l_return_status
  ,P_VALIDATE                     => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_competence_element');
--
----------------------------------------------------------
END commit_i_competence_element;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_competence_element (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_u_competence_element');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
hr_competence_element_swi.update_competence_element (
   P_COMPETENCE_ELEMENT_ID       => valueOf(commitNode,'CompetenceElementId')
  ,P_OBJECT_VERSION_NUMBER       => l_object_version_number
  ,P_PROFICIENCY_LEVEL_ID        => valueOf(commitNode,'ProficiencyLevelId')
  ,P_HIGH_PROFICIENCY_LEVEL_ID   => valueOf(commitNode,'HighProficiencyLevelId')
  ,P_WEIGHTING_LEVEL_ID          => valueOf(commitNode,'WeightingLevelId')
  ,P_RATING_LEVEL_ID             => valueOf(commitNode,'RatingLevelId')
  ,P_MANDATORY                   => valueOf(commitNode,'Mandatory')
  ,P_EFFECTIVE_DATE_FROM         => date_value(valueOf(commitNode,'EffectiveDateFrom'))
  ,P_EFFECTIVE_DATE_TO           => date_value(valueOf(commitNode,'EffectiveDateTo'))
  ,P_GROUP_COMPETENCE_TYPE       => valueOf(commitNode,'GroupCompetenceType')
  ,P_COMPETENCE_TYPE             => valueOf(commitNode,'CompetenceType')
  ,P_NORMAL_ELAPSE_DURATION      => valueOf(commitNode,'NormalElapseDuration')
  ,P_NORMAL_ELAPSE_DURATION_UNIT => valueOf(commitNode,'NormalElapseDurationUnit')
  ,P_SEQUENCE_NUMBER             => valueOf(commitNode,'SequenceNumber')
  ,P_SOURCE_OF_PROFICIENCY_LEVEL => valueOf(commitNode,'SourceOfProficiencyLevel')
  ,P_LINE_SCORE                  => valueOf(commitNode,'LineScore')
  ,P_CERTIFICATION_DATE          => date_value(valueOf(commitNode,'CertificationDate'))
  ,P_CERTIFICATION_METHOD        => valueOf(commitNode,'CertificationMethod')
  ,P_NEXT_CERTIFICATION_DATE     => date_value(valueOf(commitNode,'NextCertificationDate'))
  ,P_COMMENTS                    => valueOf(commitNode,'Comments')
  ,P_ATTRIBUTE_CATEGORY          => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                  => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                  => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                  => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                  => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                  => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                  => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                  => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                  => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                  => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10                 => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11                 => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12                 => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13                 => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14                 => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15                 => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16                 => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17                 => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18                 => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19                 => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20                 => valueOf(commitNode,'Attribute20')
  ,P_EFFECTIVE_DATE              => l_effective_date
  ,P_PARTY_ID                    => valueOf(commitNode,'PartyId')
  ,P_RETURN_STATUS               => l_return_status
  ,P_VALIDATE                    => g_validate
  ,P_COMPETENCE_ID               => valueOf(commitNode,'CompetenceId'));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_competence_element');
--
----------------------------------------------------------
END commit_u_competence_element;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_competence_element (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_d_competence_element');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
hr_competence_element_swi.delete_competence_element (
   P_COMPETENCE_ELEMENT_ID => valueOf(commitNode,'CompetenceElementId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_competence_element');
--
----------------------------------------------------------
END commit_d_competence_element;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_variable_comp_element (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_variable_comp_element');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
  irc_variable_comp_element_swi.create_variable_compensation (
     P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
    ,P_VARIABLE_COMP_LOOKUP  => valueOf(commitNode,'LookupCode')
    ,P_EFFECTIVE_DATE        => l_effective_date
    ,P_OBJECT_VERSION_NUMBER => l_object_version_number
    ,P_RETURN_STATUS         => l_return_status
    ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_variable_comp_element');
--
----------------------------------------------------------
END commit_i_variable_comp_element;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_variable_comp_element (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_d_variable_comp_element');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_variable_comp_element_swi.delete_variable_compensation (
   P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
  ,P_VARIABLE_COMP_LOOKUP  => valueOf(commitNode,'LookupCode')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_variable_comp_element');
--
----------------------------------------------------------
END commit_d_variable_comp_element;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_rec_team_member (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_i_rec_team_member');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_rec_team_members_swi.create_rec_team_member (
   P_REC_TEAM_MEMBER_ID    => valueOf(commitNode,'RecTeamMemberId')
  ,P_PERSON_ID             => valueOf(commitNode,'PersonId')
  ,P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
  ,P_JOB_ID                => valueOf(commitNode,'JobId')
  ,P_START_DATE            => date_value(valueOf(commitNode,'StartDate'))
  ,P_END_DATE              => date_value(valueOf(commitNode,'EndDate'))
  ,P_UPDATE_ALLOWED        => valueOf(commitNode,'UpdateAllowed')
  ,P_DELETE_ALLOWED        => valueOf(commitNode,'DeleteAllowed')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS         => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_rec_team_member');
--
----------------------------------------------------------
END commit_i_rec_team_member;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_rec_team_member (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_d_rec_team_member');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_rec_team_members_swi.delete_rec_team_member (
   P_REC_TEAM_MEMBER_ID    => valueOf(commitNode,'RecTeamMemberId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS         => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_rec_team_member');
--
----------------------------------------------------------
END commit_d_rec_team_member;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_rec_team_member (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_u_rec_team_member');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_rec_team_members_swi.update_rec_team_member (
   P_REC_TEAM_MEMBER_ID    => valueOf(commitNode,'RecTeamMemberId')
  ,P_PERSON_ID             => valueOf(commitNode,'PersonId')
  ,P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_JOB_ID                => valueOf(commitNode,'JobId')
  ,P_START_DATE            => date_value(valueOf(commitNode,'StartDate'))
  ,P_END_DATE              => date_value(valueOf(commitNode,'EndDate'))
  ,P_UPDATE_ALLOWED        => valueOf(commitNode,'UpdateAllowed')
  ,P_DELETE_ALLOWED        => valueOf(commitNode,'DeleteAllowed')
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_rec_team_member');
--
----------------------------------------------------------
END commit_u_rec_team_member;
----------------------------------------------------------
--
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_i_agency_vacancy');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_agency_vacancies_swi.create_agency_vacancy (
   P_VALIDATE               => g_validate
  ,P_AGENCY_ID              => valueOf(commitNode,'AgencyId')
  ,P_VACANCY_ID             => valueOf(commitNode,'VacancyId')
  ,P_START_DATE             => date_value(valueOf(commitNode,'StartDate'))
  ,P_END_DATE               => date_value(valueOf(commitNode,'EndDate'))
  ,P_MAX_ALLOWED_APPLICANTS    => valueOf(commitNode,'MaxAllowedApplicants')
  ,P_MANAGE_APPLICANTS_ALLOWED => valueOf(commitNode,'ManageApplicantsAllowed')
  ,P_AGENCY_VACANCY_ID      => valueOf(commitNode,'AgencyVacancyId')
  ,P_ATTRIBUTE_CATEGORY     => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1             => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2             => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3             => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4             => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5             => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6             => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7             => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8             => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9             => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10            => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11            => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12            => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13            => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14            => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15            => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16            => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17            => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18            => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19            => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20            => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21            => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22            => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23            => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24            => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25            => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26            => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27            => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28            => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29            => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30            => valueOf(commitNode,'Attribute30')
  ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_agency_vacancy');
--
----------------------------------------------------------
END commit_i_agency_vacancy;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_d_agency_vacancy');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_agency_vacancies_swi.delete_agency_vacancy (
   P_AGENCY_VACANCY_ID        => valueOf(commitNode,'AgencyVacancyId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_agency_vacancy');
--
----------------------------------------------------------
END commit_d_agency_vacancy;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
--
--
l_return_status varchar2(1);
l_object_version_number number;
--
BEGIN
--
hr_utility.trace('Entering commit_u_agency_vacancy');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_agency_vacancies_swi.update_agency_vacancy (
   P_AGENCY_ID            => valueOf(commitNode,'AgencyId')
  ,P_VACANCY_ID           => valueOf(commitNode,'VacancyId')
  ,P_START_DATE           => date_value(valueOf(commitNode,'StartDate'))
  ,P_END_DATE             => date_value(valueOf(commitNode,'EndDate'))
  ,P_MAX_ALLOWED_APPLICANTS => valueOf(commitNode,'MaxAllowedApplicants')
  ,P_MANAGE_APPLICANTS_ALLOWED => valueOf(commitNode,'ManageApplicantsAllowed')
  ,P_AGENCY_VACANCY_ID    => valueOf(commitNode,'AgencyVacancyId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_ATTRIBUTE_CATEGORY => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1           => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2           => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3           => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4           => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5           => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6           => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7           => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8           => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9           => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10          => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11          => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12          => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13          => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14          => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15          => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16          => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17          => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18          => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19          => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20          => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21          => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22          => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23          => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24          => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25          => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26          => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27          => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28          => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29          => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30          => valueOf(commitNode,'Attribute30')
  ,P_RETURN_STATUS        => l_return_status
  ,P_VALIDATE             => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_agency_vacancy');
--
----------------------------------------------------------
END commit_u_agency_vacancy;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_rec_activity_for (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_i_rec_activity_for');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_rec_activity_for_swi.create_rec_activity_for (
   P_REC_ACTIVITY_FOR_ID   => valueOf(commitNode,'RecruitmentActivityForId')
  ,P_BUSINESS_GROUP_ID     => valueOf(commitNode,'BusinessGroupId')
  ,P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
  ,P_REC_ACTIVITY_ID       => valueOf(commitNode,'RecruitmentActivityId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_rec_activity_for');
--
----------------------------------------------------------
END commit_i_rec_activity_for;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_rec_activity_for (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_d_rec_activity_for');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_rec_activity_for_swi.delete_rec_activity_for (
   P_REC_ACTIVITY_FOR_ID   => valueOf(commitNode,'RecruitmentActivityForId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_rec_activity_for');
--
----------------------------------------------------------
END commit_d_rec_activity_for;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_rec_activity_for (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_u_rec_activity_for');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_rec_activity_for_swi.update_rec_activity_for (
   P_REC_ACTIVITY_FOR_ID   => valueOf(commitNode,'RecruitmentActivityForId')
  ,P_VACANCY_ID            => valueOf(commitNode,'VacancyId')
  ,P_REC_ACTIVITY_ID       => valueOf(commitNode,'RecruitmentActivityId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_rec_activity_for');
--
----------------------------------------------------------
END commit_u_rec_activity_for;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_recruitment_activity (commitNode in xmldom.DOMNode
,p_date_change in number
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_i_recruitment_activity');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_recruitment_activity_swi.create_recruitment_activity (
   P_BUSINESS_GROUP_ID        => valueOf(commitNode,'BusinessGroupId')
  ,P_DATE_START               => date_value(valueOf(commitNode,'DateStart')) + nvl(p_date_change,0)
  ,P_NAME                     => valueOf(commitNode,'Name')
  ,P_AUTHORISING_PERSON_ID    => valueOf(commitNode,'AuthorisingPersonId')
  ,P_RUN_BY_ORGANIZATION_ID   => valueOf(commitNode,'RunByOrganizationId')
,P_INTERNAL_CONTACT_PERSON_ID => valueOf(commitNode,'InternalContactPersonId')
,P_PARENT_RECRUITMENT_ACTIVITY=> valueOf(commitNode,'ParentRecruitmentActivityId')
  ,P_CURRENCY_CODE            => valueOf(commitNode,'CurrencyCode')
  ,P_ACTUAL_COST              => valueOf(commitNode,'ActualCost')
  ,P_COMMENTS                 => valueOf(commitNode,'Comments')
  ,P_CONTACT_TELEPHONE_NUMBER => valueOf(commitNode,'ContactTelephoneNumber')
  ,P_DATE_CLOSING             => date_value(valueOf(commitNode,'DateClosing'))
  ,P_DATE_END                 => date_value(valueOf(commitNode,'DateEnd'))
  ,P_EXTERNAL_CONTACT         => valueOf(commitNode,'ExternalContact')
  ,P_PLANNED_COST             => valueOf(commitNode,'PlannedCost')
  ,P_TYPE                     => valueOf(commitNode,'Type')
  ,P_ATTRIBUTE_CATEGORY       => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1               => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2               => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3               => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4               => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5               => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6               => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7               => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8               => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9               => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10              => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11              => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12              => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13              => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14              => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15              => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16              => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17              => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18              => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19              => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20              => valueOf(commitNode,'Attribute20')
  ,P_POSTING_CONTENT_ID       => valueOf(commitNode,'PostingContentId')
  ,P_STATUS                   => valueOf(commitNode,'Status')
  ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
  ,P_RECRUITMENT_ACTIVITY_ID  => valueOf(commitNode,'RecruitmentActivityId')
  ,P_RETURN_STATUS            => l_return_status
  ,P_VALIDATE                 => g_validate
  ,P_RECRUITING_SITE_ID       => valueOf(commitNode,'RecruitingSiteId')
  ,P_RECRUITING_SITE_RESPONSE => valueOf(commitNode,'RecruitingSiteResponse'));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_recruitment_activity');
--
----------------------------------------------------------
END commit_i_recruitment_activity;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_recruitment_activity (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_d_recruitment_activity');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_recruitment_activity_swi.delete_recruitment_activity (
   P_OBJECT_VERSION_NUMBER   => l_object_version_number
  ,P_RECRUITMENT_ACTIVITY_ID => valueOf(commitNode,'RecruitmentActivityId')
  ,P_RETURN_STATUS           => l_return_status
  ,P_VALIDATE                => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_recruitment_activity');
--
----------------------------------------------------------
END commit_d_recruitment_activity;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_recruitment_activity (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_u_recruitment_activity');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
per_recruitment_activity_swi.update_recruitment_activity (
   P_RECRUITMENT_ACTIVITY_ID     => valueOf(commitNode,'RecruitmentActivityId')
  ,P_AUTHORISING_PERSON_ID       => valueOf(commitNode,'AuthorisingPersonId')
  ,P_RUN_BY_ORGANIZATION_ID      => valueOf(commitNode,'RunByOrganizationId')
  ,P_INTERNAL_CONTACT_PERSON_ID  => valueOf(commitNode,'InternalContactPersonId')
  ,P_PARENT_RECRUITMENT_ACTIVITY => valueOf(commitNode,'ParentRecruitmentActivityId')
  ,P_CURRENCY_CODE               => valueOf(commitNode,'CurrencyCode')
  ,P_DATE_START                  => date_value(valueOf(commitNode,'DateStart'))
  ,P_NAME                        => valueOf(commitNode,'Name')
  ,P_ACTUAL_COST                 => valueOf(commitNode,'ActualCost')
  ,P_COMMENTS                    => valueOf(commitNode,'Comments')
  ,P_CONTACT_TELEPHONE_NUMBER    => valueOf(commitNode,'ContactTelephoneNumber')
  ,P_DATE_CLOSING                => date_value(valueOf(commitNode,'DateClosing'))
  ,P_DATE_END                    => date_value(valueOf(commitNode,'DateEnd'))
  ,P_EXTERNAL_CONTACT            => valueOf(commitNode,'ExternalContact')
  ,P_PLANNED_COST                => valueOf(commitNode,'PlannedCost')
  ,P_TYPE                        => valueOf(commitNode,'Type')
  ,P_ATTRIBUTE_CATEGORY          => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1                  => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2                  => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3                  => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4                  => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5                  => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6                  => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7                  => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8                  => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9                  => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10                 => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11                 => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12                 => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13                 => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14                 => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15                 => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16                 => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17                 => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18                 => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19                 => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20                 => valueOf(commitNode,'Attribute20')
  ,P_POSTING_CONTENT_ID          => valueOf(commitNode,'PostingContentId')
  ,P_STATUS                      => valueOf(commitNode,'Status')
  ,P_OBJECT_VERSION_NUMBER       => l_object_version_number
  ,P_RETURN_STATUS               => l_return_status
  ,P_VALIDATE                    => g_validate
  ,P_RECRUITING_SITE_ID          => valueOf(commitNode,'RecruitingSiteId')
  ,P_RECRUITING_SITE_RESPONSE    => valueOf(commitNode,'RecruitingSiteResponse'));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_recruitment_activity');
--
----------------------------------------------------------
END commit_u_recruitment_activity;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_i_posting_content (commitNode in xmldom.DOMNode
,l_effective_date in date
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_i_posting_content');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_posting_content_swi.create_posting_content (
   P_DISPLAY_MANAGER_INFO   => valueOf(commitNode,'DisplayManagerInfo')
  ,P_DISPLAY_RECRUITER_INFO => valueOf(commitNode,'DisplayRecruiterInfo')
  ,P_NAME                   => valueOf(commitNode,'Name')
  ,P_ORG_NAME               => valueOf(commitNode,'OrgName')
  ,P_ORG_DESCRIPTION        => valueOf(commitNode,'OrgDescription')
  ,P_JOB_TITLE              => valueOf(commitNode,'JobTitle')
  ,P_BRIEF_DESCRIPTION      => valueOf(commitNode,'BriefDescription')
  ,P_DETAILED_DESCRIPTION   => valueOf(commitNode,'DetailedDescription')
  ,P_JOB_REQUIREMENTS       => valueOf(commitNode,'JobRequirements')
  ,P_ADDITIONAL_DETAILS     => valueOf(commitNode,'AdditionalDetails')
  ,P_HOW_TO_APPLY           => valueOf(commitNode,'HowToApply')
  ,P_BENEFIT_INFO           => valueOf(commitNode,'BenefitInfo')
  ,P_IMAGE_URL              => valueOf(commitNode,'ImageUrl')
  ,P_ALT_IMAGE_URL          => valueOf(commitNode,'ImageUrlAlt')
  ,P_ATTRIBUTE_CATEGORY     => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1             => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2             => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3             => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4             => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5             => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6             => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7             => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8             => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9             => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10            => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11            => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12            => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13            => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14            => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15            => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16            => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17            => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18            => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19            => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20            => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21            => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22            => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23            => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24            => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25            => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26            => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27            => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28            => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29            => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30            => valueOf(commitNode,'Attribute30')
  ,P_IPC_INFORMATION_CATEGORY => valueOf(commitNode,'IpcInformationCategory')
  ,P_IPC_INFORMATION1       => valueOf(commitNode,'IpcInformation1')
  ,P_IPC_INFORMATION2       => valueOf(commitNode,'IpcInformation2')
  ,P_IPC_INFORMATION3       => valueOf(commitNode,'IpcInformation3')
  ,P_IPC_INFORMATION4       => valueOf(commitNode,'IpcInformation4')
  ,P_IPC_INFORMATION5       => valueOf(commitNode,'IpcInformation5')
  ,P_IPC_INFORMATION6       => valueOf(commitNode,'IpcInformation6')
  ,P_IPC_INFORMATION7       => valueOf(commitNode,'IpcInformation7')
  ,P_IPC_INFORMATION8       => valueOf(commitNode,'IpcInformation8')
  ,P_IPC_INFORMATION9       => valueOf(commitNode,'IpcInformation9')
  ,P_IPC_INFORMATION10      => valueOf(commitNode,'IpcInformation10')
  ,P_IPC_INFORMATION11      => valueOf(commitNode,'IpcInformation11')
  ,P_IPC_INFORMATION12      => valueOf(commitNode,'IpcInformation12')
  ,P_IPC_INFORMATION13      => valueOf(commitNode,'IpcInformation13')
  ,P_IPC_INFORMATION14      => valueOf(commitNode,'IpcInformation14')
  ,P_IPC_INFORMATION15      => valueOf(commitNode,'IpcInformation15')
  ,P_IPC_INFORMATION16      => valueOf(commitNode,'IpcInformation16')
  ,P_IPC_INFORMATION17      => valueOf(commitNode,'IpcInformation17')
  ,P_IPC_INFORMATION18      => valueOf(commitNode,'IpcInformation18')
  ,P_IPC_INFORMATION19      => valueOf(commitNode,'IpcInformation19')
  ,P_IPC_INFORMATION20      => valueOf(commitNode,'IpcInformation20')
  ,P_IPC_INFORMATION21      => valueOf(commitNode,'IpcInformation21')
  ,P_IPC_INFORMATION22      => valueOf(commitNode,'IpcInformation22')
  ,P_IPC_INFORMATION23      => valueOf(commitNode,'IpcInformation23')
  ,P_IPC_INFORMATION24      => valueOf(commitNode,'IpcInformation24')
  ,P_IPC_INFORMATION25      => valueOf(commitNode,'IpcInformation25')
  ,P_IPC_INFORMATION26      => valueOf(commitNode,'IpcInformation26')
  ,P_IPC_INFORMATION27      => valueOf(commitNode,'IpcInformation27')
  ,P_IPC_INFORMATION28      => valueOf(commitNode,'IpcInformation28')
  ,P_IPC_INFORMATION29      => valueOf(commitNode,'IpcInformation29')
  ,P_IPC_INFORMATION30      => valueOf(commitNode,'IpcInformation30')
  ,P_POSTING_CONTENT_ID     => valueOf(commitNode,'PostingContentId')
  ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE               => g_validate
  ,P_DATE_APPROVED          => l_effective_date);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_i_posting_content');
--
----------------------------------------------------------
END commit_i_posting_content;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_d_posting_content (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_d_posting_content');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_posting_content_swi.delete_posting_content (
   P_POSTING_CONTENT_ID    => valueOf(commitNode,'PostingContentId')
  ,P_OBJECT_VERSION_NUMBER => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE              => g_validate);
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_d_posting_content');
--
----------------------------------------------------------
END commit_d_posting_content;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
PROCEDURE commit_u_posting_content (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2
) AS
--
l_object_version_number number;
l_return_status varchar2(1);
--
BEGIN
--
hr_utility.trace('Entering commit_u_posting_content');
--
l_object_version_number := valueOf(commitNode,'ObjectVersionNumber');
--
irc_posting_content_swi.update_posting_content (
   P_POSTING_CONTENT_ID     => valueOf(commitNode,'PostingContentId')
  ,P_DISPLAY_MANAGER_INFO   => valueOf(commitNode,'DisplayManagerInfo')
  ,P_DISPLAY_RECRUITER_INFO => valueOf(commitNode,'DisplayRecruiterInfo')
  ,P_NAME                   => valueOf(commitNode,'Name')
  ,P_ORG_NAME               => valueOf(commitNode,'OrgName')
  ,P_ORG_DESCRIPTION        => valueOf(commitNode,'OrgDescription')
  ,P_JOB_TITLE              => valueOf(commitNode,'JobTitle')
  ,P_BRIEF_DESCRIPTION      => valueOf(commitNode,'BriefDescription')
  ,P_DETAILED_DESCRIPTION   => valueOf(commitNode,'DetailedDescription')
  ,P_JOB_REQUIREMENTS       => valueOf(commitNode,'JobRequirements')
  ,P_ADDITIONAL_DETAILS     => valueOf(commitNode,'AdditionalDetails')
  ,P_HOW_TO_APPLY           => valueOf(commitNode,'HowToApply')
  ,P_BENEFIT_INFO           => valueOf(commitNode,'BenefitInfo')
  ,P_IMAGE_URL              => valueOf(commitNode,'ImageUrl')
  ,P_ALT_IMAGE_URL          => valueOf(commitNode,'ImageUrlAlt')
  ,P_ATTRIBUTE_CATEGORY     => valueOf(commitNode,'AttributeCategory')
  ,P_ATTRIBUTE1             => valueOf(commitNode,'Attribute1')
  ,P_ATTRIBUTE2             => valueOf(commitNode,'Attribute2')
  ,P_ATTRIBUTE3             => valueOf(commitNode,'Attribute3')
  ,P_ATTRIBUTE4             => valueOf(commitNode,'Attribute4')
  ,P_ATTRIBUTE5             => valueOf(commitNode,'Attribute5')
  ,P_ATTRIBUTE6             => valueOf(commitNode,'Attribute6')
  ,P_ATTRIBUTE7             => valueOf(commitNode,'Attribute7')
  ,P_ATTRIBUTE8             => valueOf(commitNode,'Attribute8')
  ,P_ATTRIBUTE9             => valueOf(commitNode,'Attribute9')
  ,P_ATTRIBUTE10            => valueOf(commitNode,'Attribute10')
  ,P_ATTRIBUTE11            => valueOf(commitNode,'Attribute11')
  ,P_ATTRIBUTE12            => valueOf(commitNode,'Attribute12')
  ,P_ATTRIBUTE13            => valueOf(commitNode,'Attribute13')
  ,P_ATTRIBUTE14            => valueOf(commitNode,'Attribute14')
  ,P_ATTRIBUTE15            => valueOf(commitNode,'Attribute15')
  ,P_ATTRIBUTE16            => valueOf(commitNode,'Attribute16')
  ,P_ATTRIBUTE17            => valueOf(commitNode,'Attribute17')
  ,P_ATTRIBUTE18            => valueOf(commitNode,'Attribute18')
  ,P_ATTRIBUTE19            => valueOf(commitNode,'Attribute19')
  ,P_ATTRIBUTE20            => valueOf(commitNode,'Attribute20')
  ,P_ATTRIBUTE21            => valueOf(commitNode,'Attribute21')
  ,P_ATTRIBUTE22            => valueOf(commitNode,'Attribute22')
  ,P_ATTRIBUTE23            => valueOf(commitNode,'Attribute23')
  ,P_ATTRIBUTE24            => valueOf(commitNode,'Attribute24')
  ,P_ATTRIBUTE25            => valueOf(commitNode,'Attribute25')
  ,P_ATTRIBUTE26            => valueOf(commitNode,'Attribute26')
  ,P_ATTRIBUTE27            => valueOf(commitNode,'Attribute27')
  ,P_ATTRIBUTE28            => valueOf(commitNode,'Attribute28')
  ,P_ATTRIBUTE29            => valueOf(commitNode,'Attribute29')
  ,P_ATTRIBUTE30            => valueOf(commitNode,'Attribute30')
  ,P_IPC_INFORMATION_CATEGORY => valueOf(commitNode,' IpcInformationCategory')
  ,P_IPC_INFORMATION1       => valueOf(commitNode,'IpcInformation1')
  ,P_IPC_INFORMATION2       => valueOf(commitNode,'IpcInformation2')
  ,P_IPC_INFORMATION3       => valueOf(commitNode,'IpcInformation3')
  ,P_IPC_INFORMATION4       => valueOf(commitNode,'IpcInformation4')
  ,P_IPC_INFORMATION5       => valueOf(commitNode,'IpcInformation5')
  ,P_IPC_INFORMATION6       => valueOf(commitNode,'IpcInformation6')
  ,P_IPC_INFORMATION7       => valueOf(commitNode,'IpcInformation7')
  ,P_IPC_INFORMATION8       => valueOf(commitNode,'IpcInformation8')
  ,P_IPC_INFORMATION9       => valueOf(commitNode,'IpcInformation9')
  ,P_IPC_INFORMATION10      => valueOf(commitNode,'IpcInformation10')
  ,P_IPC_INFORMATION11      => valueOf(commitNode,'IpcInformation11')
  ,P_IPC_INFORMATION12      => valueOf(commitNode,'IpcInformation12')
  ,P_IPC_INFORMATION13      => valueOf(commitNode,'IpcInformation13')
  ,P_IPC_INFORMATION14      => valueOf(commitNode,'IpcInformation14')
  ,P_IPC_INFORMATION15      => valueOf(commitNode,'IpcInformation15')
  ,P_IPC_INFORMATION16      => valueOf(commitNode,'IpcInformation16')
  ,P_IPC_INFORMATION17      => valueOf(commitNode,'IpcInformation17')
  ,P_IPC_INFORMATION18      => valueOf(commitNode,'IpcInformation18')
  ,P_IPC_INFORMATION19      => valueOf(commitNode,'IpcInformation19')
  ,P_IPC_INFORMATION20      => valueOf(commitNode,'IpcInformation20')
  ,P_IPC_INFORMATION21      => valueOf(commitNode,'IpcInformation21')
  ,P_IPC_INFORMATION22      => valueOf(commitNode,'IpcInformation22')
  ,P_IPC_INFORMATION23      => valueOf(commitNode,'IpcInformation23')
  ,P_IPC_INFORMATION24      => valueOf(commitNode,'IpcInformation24')
  ,P_IPC_INFORMATION25      => valueOf(commitNode,'IpcInformation25')
  ,P_IPC_INFORMATION26      => valueOf(commitNode,'IpcInformation26')
  ,P_IPC_INFORMATION27      => valueOf(commitNode,'IpcInformation27')
  ,P_IPC_INFORMATION28      => valueOf(commitNode,'IpcInformation28')
  ,P_IPC_INFORMATION29      => valueOf(commitNode,'IpcInformation29')
  ,P_IPC_INFORMATION30      => valueOf(commitNode,'IpcInformation30')
  ,P_OBJECT_VERSION_NUMBER  => l_object_version_number
  ,P_RETURN_STATUS          => l_return_status
  ,P_VALIDATE               => g_validate
  ,P_DATE_APPROVED          => date_value(valueOf(commitNode,'DateApproved')));
--
  p_return_status := l_return_status;
--
hr_utility.trace('Exiting commit_u_posting_content');
--
----------------------------------------------------------
END commit_u_posting_content;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
function date_value(string_value varchar2)
return date IS
--
BEGIN
--
 return trunc(to_date(substrb(string_value, 0, 19), 'YYYY/MM/DD HH24:MI:SS'));
--
----------------------------------------------------------
END date_value;
----------------------------------------------------------
--
FUNCTION isSelfApprove(itemtype   in varchar2,
                       itemkey    in varchar2)
                       return boolean as
--
approver  varchar2(240);
requestor varchar2(240);
--
BEGIN
--
hr_utility.trace('Entering isSelfApprove');
--
  approver  := wf_engine.getItemAttrText
               (itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'IRC_APPROVER');
--
  if (approver is null) then
hr_utility.trace('Exiting isSelfApprove returning TRUE');
     return true;
  end if;
--
hr_utility.trace('Exiting isSelfApprove returning FALSE');
  return false;
--
END isSelfApprove;
--
FUNCTION found_IrcVacancyCompetence (commitNode in xmldom.DOMNode)
  return boolean as
--
  l_competence_element_id number;
  l_row_count             number;
--
BEGIN
--
hr_utility.trace('Entering found_IrcVacancyCompetence');
--
  l_competence_element_id :=
    valueOf(commitNode,'CompetenceElementId');
--
  select count(*)
    into l_row_count
    from per_competence_elements
   where competence_element_id = l_competence_element_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_IrcVacancyCompetence returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_IrcVacancyCompetence returning TRUE');
--
  return true;
--
END found_IrcVacancyCompetence;
--
--
FUNCTION found_IrcRecTeamDisplay (commitNode in xmldom.DOMNode)
  return boolean as
--
  l_party_id   number;
  l_vacancy_id number;
  l_row_count  number;
--
BEGIN
--
  l_party_id    := valueOf(commitNode,'PartyId');
  l_vacancy_id  := valueOf(commitNode,'VacancyId');
--
  select count(*)
    into l_row_count
    from irc_rec_team_members
   where party_id   = l_party_id
     and vacancy_id = l_vacancy_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_IrcRecTeamDisplay returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_IrcRecTeamDisplay returning TRUE');
  return true;
--
END found_IrcRecTeamDisplay;
--
FUNCTION found_agency_vacancy (commitNode in xmldom.DOMNode)
  return boolean as
--
  l_agency_vacancy_id number;
  l_row_count  number;
--
BEGIN
--
  l_agency_vacancy_id  := valueOf(commitNode,'AgencyVacancyId');
--
  select count(*)
    into l_row_count
    from IRC_AGENCY_VACANCIES
   where agency_vacancy_id = l_agency_vacancy_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_agency_vacancy returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_agency_vacancy returning TRUE');
  return true;
--
END found_agency_vacancy;
--
FUNCTION found_IrcVariableCompElements (commitNode in xmldom.DOMNode)
  return boolean as
--
  l_vacancy_id  number;
  l_lookup_code varchar2(10);
  l_row_count   number;
--
BEGIN
--
  l_vacancy_id   := valueOf(commitNode,'VacancyId');
  l_lookup_code  := valueOf(commitNode,'LookupCode');
--
  select count(*)
    into l_row_count
    from irc_variable_comp_elements
   where vacancy_id   = l_vacancy_id
     and variable_comp_lookup = l_lookup_code;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_IrcVariableCompElements returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_IrcVariableCompElements returning TRUE');
  return true;
--
END found_IrcVariableCompElements;
--
--
FUNCTION found_rec_activity(commitNode in xmldom.DOMNode)
  return boolean as
--
  l_recruitment_activity_id  number;
  l_row_count   number;
--
BEGIN
--
  l_recruitment_activity_id   :=
    valueOf(commitNode,'RecruitmentActivityId');
--
  select count(*)
    into l_row_count
    from per_recruitment_activities
   where recruitment_activity_id   = l_recruitment_activity_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_rec_activity returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_rec_activity returning TRUE');
  return true;
--
END found_rec_activity;
--
--
FUNCTION found_rec_activity_for(commitNode in xmldom.DOMNode)
  return boolean as
--
  l_recruitment_activity_for_id  number;
  l_row_count   number;
--
BEGIN
--
  l_recruitment_activity_for_id   :=
    valueOf(commitNode,'RecruitmentActivityForId');
--
  select count(*)
    into l_row_count
    from per_recruitment_activity_for
   where recruitment_activity_for_id   = l_recruitment_activity_for_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_rec_activity_for returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_rec_activity_for returning TRUE');
  return true;
--
END found_rec_activity_for;
--
--
FUNCTION found_IrcSearchCriteria(commitNode in xmldom.DOMNode)
  return boolean as
--
  l_search_criteria_id  number;
  l_row_count   number;
--
BEGIN
--
  l_search_criteria_id   :=
    valueOf(commitNode,'SearchCriteriaId');
--
  select count(*)
    into l_row_count
    from irc_search_criteria
   where search_criteria_id = l_search_criteria_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_IrcSearchCriteria returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_IrcSearchCriteria returning TRUE');
  return true;
--
END found_IrcSearchCriteria;
--
--
FUNCTION found_IrcPostingContent(commitNode in xmldom.DOMNode)
  return boolean as
--
  l_posting_content_id  number;
  l_row_count   number;
--
BEGIN
--
  l_posting_content_id   :=
    valueOf(commitNode,'PostingContentId');
--
  select count(*)
    into l_row_count
    from irc_posting_contents
   where posting_content_id   = l_posting_content_id;
--
  if (l_row_count = 0) then
hr_utility.trace('Exiting found_IrcPostingContent returning FALSE');
    return false;
  end if;
--
hr_utility.trace('Exiting found_IrcPostingContent returning TRUE');
  return true;
--
END found_IrcPostingContent;
--
--
----------------------------------------------------------
----------------------------------------------------------
FUNCTION get_internal_posting_days return number IS
--
number_of_days varchar2(10);
--
BEGIN
--
hr_utility.trace('Entering get_internal_posting_days');
--
number_of_days := fnd_profile.value('IRC_INTERNAL_POSTING_DAYS');

if (number_of_days is null) then
hr_utility.trace('Number of days is null - returning -1');
  return -1;
else
hr_utility.trace('Returning number of days as :' || number_of_days || ':');
  return to_number(number_of_days);
end if;
--
END get_internal_posting_days;
--
--
----------------------------------------------------------
----------------------------------------------------------
FUNCTION is_site_internal (p_site_id varchar2
) return varchar2 IS
--
l_internal    irc_all_recruiting_sites.INTERNAL%type;
l_external    irc_all_recruiting_sites.EXTERNAL%type;
l_third_party irc_all_recruiting_sites.THIRD_PARTY%type;
--
cursor csr_irs(c_site_id irc_all_recruiting_sites.RECRUITING_SITE_ID%type) is
--
 select INTERNAL, EXTERNAL, THIRD_PARTY
  from irc_all_recruiting_sites
 where RECRUITING_SITE_ID = c_site_id;
--
BEGIN
--
hr_utility.trace('Entering is_site_internal');
--
  open csr_irs(p_site_id);
  fetch csr_irs into l_internal, l_external, l_third_party;
  if csr_irs%notfound then
     close csr_irs;
     return '0';
  end if;
  close csr_irs;
--
  if (l_internal = 'Y') then
--
hr_utility.trace('internal=Y so return I');
--
    return 'I';
  end if;
--
  if (l_external = 'Y') then
--
hr_utility.trace('external=Y so return X');
--
    return 'X';
  end if;
--
hr_utility.trace('neither internal nor external is Y so return 3');
  return '3';
--
END is_site_internal;
--
PROCEDURE get_date_changes (
commitNodes xmldom.DOMNodeList,
external_date_change out nocopy number,
internal_date_change out nocopy number) as
--
  commitNode xmldom.DOMNode;
  internalStartDate date;
--
BEGIN
--
hr_utility.trace('Entering get_date_changes');
--
--  If the start date of the external posting was not enterable
--  because the IRC: Internal Posting Days profile option was set then
--    the start date of the external posting will be set to be that
--    number of days after the start date of the internal posting.
--
--  external_date_change := get_internal_posting_days();
  external_date_change := 0;
--
--  find the internal site and determine any correction to
--  the start date required
--
--  If the start date of the internal posting is before the approval date then
--    the start date of the internal posting will be moved to the approval date
--    the start date of the external posting will be moved by the same amount.
--
  for j in 1..xmldom.getLength(commitNodes) loop
--
hr_utility.trace('Checking node :' || to_char(j) || ':');
--
    commitNode:=xmldom.item(commitNodes,j-1);
--
    if (is_site_internal(valueOf(commitNode,'RecruitingSiteId')) = 'I') then
--
      internalStartDate := date_value(valueOf(commitNode,'DateStart'));
--
hr_utility.trace('Internal Site date found :' || to_char(internalStartDate) || ':');
--
      if (internalStartDate < sysdate) then
        internal_date_change := sysdate - internalStartDate;
--
hr_utility.trace('internalStartDate < sysdate, internal change :'
               || internal_date_change || ':');
--
        if (external_date_change = -1) then
          external_date_change := internal_date_change;
--
hr_utility.trace('external_date_change found as -1, changing to :'
              || external_date_change || ':');
--
        else
          external_date_change := internal_date_change + external_date_change;
--
hr_utility.trace('external_date_change set to :' || external_date_change || ':');
--
        end if;
      end if;
    end if;
  end loop;
--
  if (external_date_change = -1) then
--
hr_utility.trace('external_date_change is still -1, changing it to 0');
--
    external_date_change := 0;
  end if;
--
hr_utility.trace('Exiting get_date_changes');
--
  return;
--
END get_date_changes;
--
--                                                      --
----------------------------------------------------------
----------------------------------------------------------
function get_error(itemtype in varchar2,
                       itemkey in varchar2) return varchar2 is
--
  error_tabs error_tab;
--
  pMessageCount number;
  messageBuffer varchar2(1000);
  error_list varchar2(4000);
  error_tabs1 varchar2(4000);
  errorField varchar2(1000);
  messageType varchar2(1000);
  messageText varchar2(1000);
--
BEGIN
--
hr_utility.trace('Entering get_error for :' || itemtype || '-' || itemkey || ':');
--
  pMessageCount := FND_MSG_PUB.COUNT_MSG();
--
  messageBuffer := FND_MSG_PUB.GET_DETAIL(p_msg_index => FND_MSG_PUB.G_FIRST);
  FND_MESSAGE.Set_Encoded(messageBuffer);
  errorField := FND_MESSAGE.GET_TOKEN('FND_ERROR_LOCATION_FIELD','Y');
  messageType := FND_MESSAGE.GET_TOKEN('FND_MESSAGE_TYPE','Y');
  error_tabs1 := FND_MESSAGE.GET;
--
hr_utility.trace('Exiting get_error returning :' || error_tabs1 || ':');
--
  return error_tabs1;
--
----------------------------------------------------------
END get_error;
----------------------------------------------------------
--
----------------------------------------------------------
----------------------------------------------------------
--
PROCEDURE set_up_error_message(itemtype    in varchar2,
                               itemkey     in varchar2,
                               error_tabs  in varchar2) as
--
  apr_item_type varchar2(240);
  vacancy_name varchar2(4000);
  launching_page varchar2(4000);
  transId varchar2(4000);
  apr_message varchar2(4000);
  urlBase varchar2(4000);
  htmlCall fnd_form_functions.web_html_call%type;
  approval_process varchar2(4000);
  l_encrypted_id varchar2(2000);
--
BEGIN
--
hr_utility.trace('Entering set_up_error_message with message :'
               || error_tabs || ':');
--
  apr_item_type := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALITEM');
--
  approval_process := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALPROCESS');
--
  vacancy_name := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRC_APPROVAL_ITEM_NAME');
--
  transId := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRC_APPROVE_TRANS_ID');
--
  fnd_message.set_name('PER','IRC_' || apr_item_type || '_CORRECTION_SUBJECT');
  fnd_message.set_token('VACANCYNAME',vacancy_name, false);
  apr_message := fnd_message.get;
  wf_engine.setItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALSUBJECT',
                  avalue   => apr_message);
--
  fnd_message.set_name('PER','IRC_' || apr_item_type || '_AUTO_CORRECT_TEXT');
  fnd_message.set_token('ERROR_TEXT1',error_tabs, false);
  apr_message := fnd_message.get;
  wf_engine.setItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALTEXTBODY',
                  avalue   => apr_message);
--
  fnd_message.set_name('PER','IRC_' || apr_item_type || '_AUTO_CORRECT_HTML');
  fnd_message.set_token('ERROR_TEXT1',error_tabs, false);
  apr_message := fnd_message.get;
  wf_engine.setItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALHTMLBODY',
                  avalue   => apr_message);
--
  launching_page := wf_engine.getItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRC_LAUNCHING_PAGE');
--
urlBase:='JSP:/OA_HTML/OA.jsp?OAFunc='||launching_page
||'&correctionTransactionId='||transId||'&retainAM=Y';
--
  wf_engine.setItemAttrText
                 (itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'IRCAPPROVALURL',
                  avalue   => urlBase);
--
hr_utility.trace('Exiting set_up_error_message');
--
  return;
--
----------------------------------------------------------
END set_up_error_message;
----------------------------------------------------------
--
END IRC_VACANCY_COMMIT;

/
