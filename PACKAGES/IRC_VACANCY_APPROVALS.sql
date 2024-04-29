--------------------------------------------------------
--  DDL for Package IRC_VACANCY_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_APPROVALS" AUTHID CURRENT_USER as
/* $Header: ircvacame.pkh 120.0 2006/03/31 23:28:26 mmillmor noship $ */

--
--
function get_transaction_data
  (p_transaction_id  in varchar2
  ,p_path       in varchar2)
return varchar2;
--
--
function get_transaction_number_data
(transaction_id in varchar2
,p_path           in varchar2)
return number;
--
--
function get_transaction_mode
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
--
function get_posting_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
--
function get_vacancy_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
--
function get_vacancy_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
--
function get_search_data_number
(transaction_id in varchar2, data_name in varchar2)
return number;
--
--
function get_search_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2;
--
--
function get_vac_organization_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_job_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_grade_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_position_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_budget_value_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_budget_type_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_vac_status_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_title_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_job_title_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_department_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_dept_desc_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_brief_description_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_detailed_desc_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_job_requirements_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_additional_details_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_how_to_apply_changed
(transaction_id in varchar2)
return varchar2;
--
--
function get_posting_graphic_changed
(transaction_id in varchar2)
return varchar2;
--
procedure show(message in varchar2);
--
function get_custom_rule return varchar2;
--
--
END IRC_VACANCY_APPROVALS;

 

/
