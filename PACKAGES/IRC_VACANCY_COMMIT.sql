--------------------------------------------------------
--  DDL for Package IRC_VACANCY_COMMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_COMMIT" AUTHID CURRENT_USER as
/* $Header: ircvaccm.pkh 120.0 2005/07/26 15:02:23 mbocutt noship $ */
--Package Variables
--
g_validate number := hr_api.g_false_num;
Type error_tab is table of varchar2(2000);

--
-- -------------------------------------------------------------------------
-- |-------------------------< reject_transaction >------------------------|
-- -------------------------------------------------------------------------
--
procedure reject_transaction (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
procedure commit_insert (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
procedure commit_update (itemtype in varchar2,
                         itemkey in varchar2,
                         actid in number,
                         funcmode in varchar2,
                         resultout out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_competence_element
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_competence_element
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_competence_element
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_posting_content
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_posting_content
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_posting_content
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_rec_activity_for
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_rec_activity_for
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_rec_activity_for
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_rec_team_member
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_rec_team_member
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_rec_team_member
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
PROCEDURE commit_i_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2);
--
PROCEDURE commit_d_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2);
--
PROCEDURE commit_u_agency_vacancy (commitNode in xmldom.DOMNode
,p_return_status                out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_recruitment_activity
  (commitNode in xmldom.DOMNode
  ,p_date_change in number
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_recruitment_activity
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_recruitment_activity
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_requisition
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_requisition
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_requisition
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_vacancy
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_vacancy
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_search_criteria
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_search_criteria
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_u_search_criteria
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_i_variable_comp_element
  (commitNode in xmldom.DOMNode
  ,l_effective_date in date
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
PROCEDURE commit_d_variable_comp_element
  (commitNode in xmldom.DOMNode
  ,p_return_status out nocopy varchar2);
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION date_value
  (string_value varchar2)
  return date;
--
-- -------------------------------------------------------------------------
-- |-------------------------<  >------------------------|
-- -------------------------------------------------------------------------
--
FUNCTION isSelfApprove(itemtype   in varchar2,
                       itemkey    in varchar2)
                       return boolean;
--
FUNCTION found_IrcVacancyCompetence (commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_IrcRecTeamDisplay (commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_agency_vacancy (commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_IrcVariableCompElements (commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_rec_activity(commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_rec_activity_for(commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_IrcSearchCriteria(commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION found_IrcPostingContent(commitNode in xmldom.DOMNode)
  return boolean;
--
FUNCTION get_internal_posting_days return number;
--
FUNCTION is_site_internal (p_site_id varchar2)
  return varchar2;
--
PROCEDURE get_date_changes (
commitNodes xmldom.DOMNodeList,
external_date_change out nocopy number,
internal_date_change out nocopy number);
--
function get_error(itemtype in varchar2,
                   itemkey in varchar2) return varchar2;
--
PROCEDURE set_up_error_message(itemtype    in varchar2,
                               itemkey     in varchar2,
                               error_tabs  in varchar2);
--
END IRC_VACANCY_COMMIT;

 

/
