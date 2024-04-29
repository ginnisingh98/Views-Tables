--------------------------------------------------------
--  DDL for Package IRC_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APPROVALS" AUTHID CURRENT_USER as
/* $Header: ircame.pkh 120.12.12010000.2 2010/03/18 08:12:31 prasashe ship $ */

--
-- -------------------------------------------------------------------------
-- |------------------------< get_transaction_data >-----------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_data
  (p_transaction_id  in varchar2
  ,p_path       in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_transaction_number_data >-------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_number_data
(transaction_id in varchar2
,p_path           in varchar2)
return number;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
--
function get_vacancy_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
-- -------------------------------------------------------------------------
--
function get_vacancy_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
--
function get_search_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
-- -------------------------------------------------------------------------
--
function get_search_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_transaction_mode >-----------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_mode
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_vac_business_group_id >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_business_group_id
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_organization_id >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_organization_id
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_grade_id >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_grade_id
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_job_id >-------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_job_id
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_location_id >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_location_id
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_budget_value >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_value
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_budget_type >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_type
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_status >-------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_status
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_professional_area >-----------------|
-- -------------------------------------------------------------------------
--
function get_vac_professional_area
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_for_emp >---------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_for_emp
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_for_con >---------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_for_con
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_employment_category >--------------------|
-- -------------------------------------------------------------------------
--
function get_vac_employment_category
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_min_salary >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_min_salary
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_max_salary >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_max_salary
(transaction_id in varchar2)
return number;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_salary_currency >------------------------|
-- -------------------------------------------------------------------------
--
function get_salary_currency
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_work_at_home >-------------------------|
-- -------------------------------------------------------------------------
--
function get_work_at_home
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_organization_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_vac_organization_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_job_changed >--------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_job_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_grade_changed >------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_grade_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_position_changed >---------------------|
-- -------------------------------------------------------------------------
--
function get_vac_position_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_budget_value_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_value_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_budget_type_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_type_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_vac_status_changed >---------------------|
-- -------------------------------------------------------------------------
--
function get_vac_status_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_posting_title_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_posting_title_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_posting_job_title_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_job_title_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_posting_department_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_department_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |------------------< get_posting_dept_desc_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_posting_dept_desc_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-------------------< get_brief_description_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_brief_description_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_detailed_desc_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_detailed_desc_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_job_requirements_changed >----------------|
-- -------------------------------------------------------------------------
--
function get_job_requirements_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_additional_details_changed >----------------|
-- -------------------------------------------------------------------------
--
function get_additional_details_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_how_to_apply_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_how_to_apply_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_posting_graphic_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_graphic_changed
(transaction_id in varchar2)
return varchar2;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_ovn_changed >------------------------|
-- -------------------------------------------------------------------------
--
function get_ovn_changed
(transaction_id in varchar2)
return varchar2;
--
FUNCTION getTopOffersApprover(transaction_id in varchar2)
  return fnd_user.user_id%type;
--
FUNCTION getTopApprover(transaction_id in varchar2)
  return fnd_user.user_id%type;
--
procedure log (message in varchar2);
--
procedure check_self_approval
  (p_application_id       in         number
  ,p_transaction_type     in         varchar2
  ,p_transaction_id       in         varchar2
  ,p_number_of_approvers  out nocopy number
  );
--
procedure getNotifSubjectForCreate
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2);
--
procedure getNotifSubjectForEdit
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2);
--
procedure getNotificationSubject (document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2,
                                  flowmode      in     varchar2);
--
FUNCTION getPersonNameFromID
(p_person_id in per_all_people_f.person_id%type)
 return per_all_people_f.full_name%type;
--
procedure getOfferNotifSubjectForCreate
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2);
--
procedure getOfferNotifSubjectForEdit
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2);
--
procedure getOfferNotificationSubject (document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2,
                                  flowmode      in     varchar2);
--
function getVacancyIdFromAssignmentId(assignment_id number)
return number;
--
function getVacancyNameFromId(vacancy_id number)
return varchar;
--
end IRC_APPROVALS;

/
