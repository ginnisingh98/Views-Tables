--------------------------------------------------------
--  DDL for Package Body IRC_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_APPROVALS" as
/* $Header: ircame.pkb 120.20.12010000.2 2010/03/18 08:13:20 prasashe ship $ */

g_posting_path varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/IrcPostingContentsVlEORow';
g_vacancy_path varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/PerRequisitionsEORow/CEO/EO/PerAllVacanciesEORow';
g_search_path  varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/PerRequisitionsEORow/CEO/EO/PerAllVacanciesEORow/CEO/EO/IrcVacancySearchCriteriaEORow';
g_rec_activity_path  varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/IrcPostingContentsVlEORow/CEO/EO/PerRecruitmentActivitiesEORow';

--
-- -------------------------------------------------------------------------
-- |------------------------< get_transaction_data >-----------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_data
  (p_transaction_id  in varchar2
  ,p_path       in varchar2)
return varchar2 is
--
l_retval varchar2(32000);
transactionDoc hr_api_transactions.transaction_document%type;
--
cursor get_doc is
select transaction_document
from hr_api_transactions
where transaction_id = p_transaction_id;
--
begin
--
irc_approvals.log('Entering get_transaction_data for transaction_id :' || p_transaction_id || ':');
irc_approvals.log('Access path :' || p_path || ':');
--
open get_doc;
fetch get_doc into transactionDoc;
if get_doc %notfound then
  close get_doc;
  l_retval:=null;
else
  close get_doc;
  l_retval:=irc_xml_util.valueOf(transactionDoc,p_path);
end if;
--
irc_approvals.log('Exiting get_transaction_data returning :' || l_retval || ':');
--
return l_retval;
--
end get_transaction_data;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_transaction_number_data >-------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_number_data
(transaction_id in varchar2
,p_path           in varchar2)
return number is
l_retval varchar2(32000);
ln_retval number;
--
begin
--
irc_approvals.log('Entering get_transaction_number_data');
--
l_retval:=irc_approvals.get_transaction_data
          (p_transaction_id       =>transaction_id
          ,p_path          =>p_path);
ln_retval:=to_number(l_retval);
--
irc_approvals.log('Exiting get_transaction_number_data');
--
return ln_retval;
end get_transaction_number_data;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_number
(transaction_id in varchar2, data_name in varchar2)
return number is
l_retval  number;
begin
--
irc_approvals.log('Entering get_posting_content_id');
--
l_retval:=irc_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id,p_path => g_posting_path || '/' || data_name);
--
irc_approvals.log('Exiting get_posting_content_id');
--
return l_retval;
end get_posting_data_number;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2 is
l_retval  varchar2(32000);
begin
--
irc_approvals.log('Entering get_posting_content_id');
--
l_retval:=irc_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id,p_path => g_posting_path || '/' || data_name);
--
irc_approvals.log('Exiting get_posting_content_id');
--
return l_retval;
end get_posting_data_varchar;
--
-- -------------------------------------------------------------------------
--
function get_vacancy_data_number
(transaction_id in varchar2, data_name in varchar2)
return number is
l_retval  number;
begin
--
irc_approvals.log('Entering get_vac_business_group_id');
--
l_retval:=irc_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id
                    ,p_path => g_vacancy_path || '/' || data_name);
--
irc_approvals.log('Exiting get_vac_business_group_id');
--
return l_retval;
end get_vacancy_data_number;
--
-- -------------------------------------------------------------------------
--
function get_vacancy_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2 is
l_retval varchar2(200);
begin
--
irc_approvals.log('Entering get_vac_budget_type');
--
l_retval:=irc_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id
                    ,p_path => g_vacancy_path || '/' || data_name);
--
irc_approvals.log('Exiting get_vac_budget_type');
--
return l_retval;
end get_vacancy_data_varchar;
--
-- -------------------------------------------------------------------------
--
function get_search_data_number
(transaction_id in varchar2, data_name in varchar2)
return number is
l_retval  number;
begin
--
irc_approvals.log('Entering get_search_data_number');
--
l_retval:=irc_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id,p_path => g_search_path || '/' || data_name);
--
irc_approvals.log('Exiting get_search_data_number');
--
return l_retval;
end get_search_data_number;
--
-- -------------------------------------------------------------------------
--
function get_search_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2 is
l_retval  varchar2(200);
begin
--
irc_approvals.log('Entering get_search_data_varchar');
--
l_retval:=irc_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id,p_path => g_search_path || '/' || data_name);
--
irc_approvals.log('Exiting get_search_data_varchar');
--
return l_retval;
end get_search_data_varchar;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_transaction_mode >-----------------------|
-- -------------------------------------------------------------------------
--
function get_transaction_mode
(transaction_id in varchar2)
return varchar2 is
--
l_retval varchar2(200);
begin
--
irc_approvals.log('Entering get_transaction_mode');
--
l_retval:=irc_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id
                    ,p_path => '/Transaction/TransCtx/CNode/dmlMode');
--
irc_approvals.log('Exiting get_transaction_mode');
--
return l_retval;
end get_transaction_mode;
--
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vacancy_id >----------------------------|
-- -------------------------------------------------------------------------
--
function get_vacancy_id
(transaction_id in varchar2)
return number is
BEGIN
return irc_approvals.get_vacancy_data_number(transaction_id, 'VacancyId');
end get_vacancy_id;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_posting_content_id >-----------------------|
-- -------------------------------------------------------------------------
--
function get_posting_content_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_posting_data_number(transaction_id, 'PostingContentId');
end get_posting_content_id;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_vac_business_group_id >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_business_group_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'BusinessGroupId');
end get_vac_business_group_id;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_organization_id >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_organization_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'OrganizationId');
end get_vac_organization_id;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_grade_id >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_grade_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'GradeId');
end get_vac_grade_id;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_job_id >-------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_job_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'JobId');
end get_vac_job_id;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_location_id >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_location_id
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'LocationId');
end get_vac_location_id;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_budget_value >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_value
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_vacancy_data_number(transaction_id, 'BudgetMeasurementValue');
end get_vac_budget_value;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_budget_type >----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_type
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_vacancy_data_varchar(transaction_id, 'BudgetMeasurementType');
end get_vac_budget_type;
--
-- -------------------------------------------------------------------------
-- |----------------------------< get_vac_status >-------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_status
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_vacancy_data_varchar(transaction_id, 'Status');
end get_vac_status;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_professional_area >-----------------|
-- -------------------------------------------------------------------------
--
function get_vac_professional_area
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'ProfessionalArea');
end get_vac_professional_area;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_for_emp >---------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_for_emp
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'Employee');
end get_vac_for_emp;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_vac_for_con >---------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_for_con
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'Contractor');
end get_vac_for_con;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_employment_category >--------------------|
-- -------------------------------------------------------------------------
--
function get_vac_employment_category
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'EmploymentCategory');
end get_vac_employment_category;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_min_salary >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_min_salary
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_search_data_number(transaction_id, 'MinSalary');
end get_vac_min_salary;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_vac_max_salary >-----------------------|
-- -------------------------------------------------------------------------
--
function get_vac_max_salary
(transaction_id in varchar2)
return number is
begin
return irc_approvals.get_search_data_number(transaction_id, 'MaxSalary');
end get_vac_max_salary;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_salary_currency >------------------------|
-- -------------------------------------------------------------------------
--
function get_salary_currency
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'SalaryCurrency');
end get_salary_currency;
--
-- -------------------------------------------------------------------------
-- |--------------------------< get_work_at_home >-------------------------|
-- -------------------------------------------------------------------------
--
function get_work_at_home
(transaction_id in varchar2)
return varchar2 is
begin
return irc_approvals.get_search_data_varchar(transaction_id, 'WorkAtHome');
end get_work_at_home;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_organization_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_vac_organization_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select organization_id
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_organization_changed');
--
  l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id := irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'OrganizationId');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_vac_organization_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_organization_changed;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_job_changed >--------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_job_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select job_id
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_job_changed');
--
  l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  l_new_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'JobId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old job id :' || to_char(l_old_id)
                   || ': to new job id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_vac_job_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_job_changed;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_grade_changed >------------------------|
-- -------------------------------------------------------------------------
--
function get_vac_grade_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select grade_id
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_grade_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'GradeId');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_approvals.log('Exiting get_vac_grade_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_grade_changed;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_vac_position_changed >---------------------|
-- -------------------------------------------------------------------------
--
function get_vac_position_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select position_id
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_position_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id     := irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'PositionId');
--
  l_vacancy_id := irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <>nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_approvals.log('Exiting get_vac_position_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_position_changed;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_budget_value_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_value_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select fnd_number.number_to_canonical(budget_measurement_value)
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_budget_value_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id)<>'INSERT' then
--
  l_new_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'BudgetMeasurementValue');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <>nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_approvals.log('Exiting get_vac_budget_value_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_budget_value_changed;
--
-- -------------------------------------------------------------------------
-- |--------------------< get_vac_budget_type_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_vac_budget_type_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(4000);
l_vacancy_id number;
l_old_value varchar2(4000);
--
l_retval varchar2(30);
cursor get_old_value(p_vacancy_id number) is
select budget_measurement_type
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_budget_type_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_value:=irc_approvals.get_vacancy_data_varchar(transaction_id=>transaction_id,data_name=>'BudgetMeasurementType');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_value(l_vacancy_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_vac_budget_type_changed returning :' || l_retval || ':');
--
return l_retval;
--
end get_vac_budget_type_changed;
--
-- -------------------------------------------------------------------------
-- |------------------------< get_vac_status_changed >---------------------|
-- -------------------------------------------------------------------------
--
function get_vac_status_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(4000);
l_vacancy_id number;
l_old_value varchar2(4000);
--
l_retval varchar2(30);
cursor get_old_value(p_vacancy_id number) is
select status
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_vac_status_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_new_value:=irc_approvals.get_vacancy_data_varchar(transaction_id=>transaction_id,data_name=>'Status');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_value(l_vacancy_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_vac_status_changed returning :' || l_retval || ':');
--
return l_retval;
end get_vac_status_changed;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_posting_title_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_posting_title_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(4000);
l_posting_content_id number;
l_old_value varchar2(4000);
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select name
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_posting_title_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'Name');

  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_posting_title_changed returning :' || l_retval || ':');
--
return l_retval;
end get_posting_title_changed;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_posting_job_title_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_job_title_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(4000);
l_posting_content_id number;
l_old_value varchar2(4000);
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select job_title
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_posting_job_title_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'JobTitle');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_posting_job_title_changed returning :' || l_retval || ':');
--
return l_retval;
end get_posting_job_title_changed;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_posting_department_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_department_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(4000);
l_posting_content_id number;
l_old_value varchar2(4000);
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select org_name
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_posting_department_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'OrgName');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_posting_department_changed returning :' || l_retval || ':');
--
return l_retval;
end get_posting_department_changed;
--
-- -------------------------------------------------------------------------
-- |------------------< get_posting_dept_desc_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_posting_dept_desc_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.org_description%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select org_description
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_posting_dept_desc_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'OrgDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
--
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_posting_dept_desc_changed returning :' || l_retval || ':');
--
return l_retval;
end get_posting_dept_desc_changed;
--
-- -------------------------------------------------------------------------
-- |-------------------< get_brief_description_changed >-------------------|
-- -------------------------------------------------------------------------
--
function get_brief_description_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.brief_description%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select brief_description
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_brief_description_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'BriefDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;

  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_brief_description_changed returning :' || l_retval || ':');
--
return l_retval;
end get_brief_description_changed;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_detailed_desc_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_detailed_desc_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.detailed_description%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select detailed_description
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_detailed_desc_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'DetailedDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_detailed_desc_changed returning :' || l_retval || ':');
--
return l_retval;
end get_detailed_desc_changed;
--
-- -------------------------------------------------------------------------
-- |----------------------< get_job_requirements_changed >----------------|
-- -------------------------------------------------------------------------
--
function get_job_requirements_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.job_requirements%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select job_requirements
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_job_requirements_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'JobRequirements');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_job_requirements_changed returning :' || l_retval || ':');
--
return l_retval;
end get_job_requirements_changed;
--
-- -------------------------------------------------------------------------
-- |---------------------< get_additional_details_changed >----------------|
-- -------------------------------------------------------------------------
--
function get_additional_details_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.additional_details%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select additional_details
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_additional_details_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'AdditionalDetails');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_additional_details_changed returning :' || l_retval || ':');
--
return l_retval;
end get_additional_details_changed;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_how_to_apply_changed >--------------------|
-- -------------------------------------------------------------------------
--
function get_how_to_apply_changed
(transaction_id in varchar2)
return varchar2 is
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.how_to_apply%type;
l_retval varchar2(30);
cursor get_old_value(p_posting_content_id number) is
select how_to_apply
from irc_posting_contents_vl
where posting_content_id=p_posting_content_id;
begin
--
irc_approvals.log('Entering get_how_to_apply_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'HowToApply');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_approvals.log('Exiting get_how_to_apply_changed returning :' || l_retval || ':');
--
return l_retval;
end get_how_to_apply_changed;
--
-- -------------------------------------------------------------------------
-- |-----------------------< get_posting_graphic_changed >-----------------|
-- -------------------------------------------------------------------------
--
function get_posting_graphic_changed
(transaction_id in varchar2)
return varchar2 is
--
l_new_value varchar2(32000);
l_posting_content_id number;
l_old_value varchar2(32000);
l_clob_old_value irc_posting_contents_vl.image_url%type;
l_retval varchar2(30);
--
cursor get_old_value(p_posting_content_id number) is
select image_url
  from irc_posting_contents_vl
 where posting_content_id=p_posting_content_id;
--
BEGIN
--
irc_approvals.log('Entering get_posting_graphic_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_new_value := irc_approvals.get_posting_data_varchar
    (transaction_id=>transaction_id ,data_name => 'ImageUrl');
--
  l_posting_content_id := irc_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_approvals.log('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_approvals.log('Exiting get_posting_graphic_changed returning :' || l_retval || ':');
--
return l_retval;
--
end get_posting_graphic_changed;
--
-- -------------------------------------------------------------------------
-- |-------------------------< get_ovn_changed >---------------------------|
-- -------------------------------------------------------------------------
--
function get_ovn_changed
(transaction_id in varchar2)
return varchar2 is
l_new_id number;
l_vacancy_id number;
l_old_id number;
--
l_retval varchar2(30);
cursor get_old_id(p_vacancy_id number) is
select object_version_number
from per_all_vacancies
where vacancy_id=p_vacancy_id;
begin
--
irc_approvals.log('Entering get_ovn_changed');
--
l_retval := 'false';
--
if irc_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'ObjectVersionNumber');
--
  l_vacancy_id:=irc_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_approvals.log('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_approvals.log('Exiting get_ovn_changed returning :' || l_retval || ':');
--
return l_retval;
end get_ovn_changed;
--
-- ----------------------------------------------------------------------------
-- getTopApprover --
-- This function is accessed by mandatory OAM Attribute --
-- TOP_SUPERVISOR_PERSON_ID to retrieve the top supervisor in the chain. --
-- ----------------------------------------------------------------------------
--
FUNCTION getTopOffersApprover(transaction_id in varchar2)
  return fnd_user.user_id%type is

p_creator_person_id per_all_people_f.person_id%type default null;
c_approver_id per_all_people_f.person_id%type default null;
c_top_approver_id per_all_people_f.person_id%type default null;

cursor csr_app(c_person_id per_people_f.person_id%TYPE) is
select supervisor_id
 from per_all_assignments_f
 where person_id = c_person_id
 and primary_flag = 'Y'
 and trunc(sysdate)
 between effective_start_date
 and effective_end_date;
--
cursor csr_trans(c_transaction_id hr_api_transactions.transaction_id%TYPE) is
select creator_person_id
 from hr_api_transactions
where transaction_id = c_transaction_id;
--
BEGIN
--
  open csr_trans(transaction_id);
  fetch csr_trans into p_creator_person_id;
  if csr_trans%notfound then
    close csr_trans;
  end if;
--
  c_top_approver_id := p_creator_person_id;

  for i2 in 1..3 loop
    open csr_app(c_top_approver_id);
    fetch csr_app into c_approver_id;
    if csr_app%notfound then
      close csr_app;
      return c_top_approver_id;
    end if;
  c_top_approver_id := nvl(c_approver_id, c_top_approver_id);
  close csr_app;
  end loop;
--
  return c_top_approver_id;
--
END getTopOffersApprover;
--
FUNCTION getTopApprover(transaction_id in varchar2)
  return fnd_user.user_id%type is
--
BEGIN
--
  return getTopOffersApprover(transaction_id);
--
END getTopApprover;
--
procedure log (message in varchar2) is
--
BEGIN
--
  hr_utility.trace(message);
--
end log;
--
--
procedure check_self_approval
  (p_application_id       in         number
  ,p_transaction_type     in         varchar2
  ,p_transaction_id       in         varchar2
  ,p_number_of_approvers  out nocopy number
  )
is
  approvalComplete varchar2(20) := ame_util.booleanFalse;
  approvers ame_util.approversTable2;

begin
  --
  irc_approvals.log('Entering check_self_approval');
  --
  ame_api2.getAllApprovers7
    (applicationIdIn                => p_application_id
    ,transactionTypeIn              => p_transaction_type
    ,transactionIdIn                => p_transaction_id
    ,approvalProcessCompleteYNOut   => approvalComplete
    ,approversOut                   => approvers);

  p_number_of_approvers := approvers.count;
  if p_number_of_approvers = 1 then
   if fnd_global.user_name = approvers(1).name then
    p_number_of_approvers := 0;
   end if;
  end if;
  irc_approvals.log('Exiting check_self_approval');
  --
end check_self_approval;
--
procedure getNotifSubjectForCreate
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2) is
begin
--
  getNotificationSubject (
     document_id   => document_id
    ,display_type  => display_type
    ,document      => document
    ,document_type => document_type
    ,flowmode      => 'CREATE');
--
end getNotifSubjectForCreate;
--
procedure getNotifSubjectForEdit
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2) is
begin
--
  getNotificationSubject (
     document_id   => document_id
    ,display_type  => display_type
    ,document      => document
    ,document_type => document_type
    ,flowmode      => 'EDIT');
--
end getNotifSubjectForEdit;
--
procedure getNotificationSubject (document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2,
                                  flowmode      in     varchar2) is
--
  l_vacancy_name     per_all_vacancies.name%type;
  l_transaction_id   hr_api_transactions.transaction_id%type;
  l_originators_name per_all_people_f.full_name%type;
--
Begin
--
  hr_utility.trace('Fetching transaction id :');
--
  l_transaction_id := wf_notification.getattrnumber(document_id,'HR_TRANSACTION_REF_ID_ATTR');
  if l_transaction_id is null then
  --
    if flowmode = 'CREATE' then
      fnd_message.set_name('PER','IRC_VACANCY_APPROVAL_NEW');
      document := fnd_message.get;
    else
      fnd_message.set_name('PER','IRC_VACANCY_APPROVAL_UPDATE');
      document := fnd_message.get;
    end if;
  --
  else
  --
    l_vacancy_name :=
      irc_approvals.get_vacancy_data_varchar(
         transaction_id => l_transaction_id,
         data_name      => 'Name');
    --
       l_originators_name :=
         getPersonNameFromID(
           irc_approvals.get_transaction_number_data (
             transaction_id => to_char(l_transaction_id),
             p_path         => '/Transaction/TransCtx/CNode/loggedInPersonId'));
    --
       fnd_message.set_name('PER','IRC_VACANCY_APPROVAL_' || flowmode);
       fnd_message.set_token('PERSONNAME',  l_originators_name, false);
       fnd_message.set_token('VACANCYNAME', l_vacancy_name, false);
       document := fnd_message.get;
    --
  --
  end if;
--
end getNotificationSubject;
--
-- ----------------------------------------------------------------------------
--  getPersonNameFromID                                                      --
--     called internally to give the person name for the given user name     --
-- ----------------------------------------------------------------------------
--
FUNCTION getPersonNameFromID
(p_person_id per_all_people_f.person_id%type)
 return per_all_people_f.full_name%type is
--
cursor csr_full_name
  is   select full_name
         from per_all_people_f papf
        where papf.person_id = p_person_id
          and trunc(sysdate) between effective_start_date
          and effective_end_date;
--
l_employee_name per_all_people_f.full_name%type;
--
BEGIN
--
hr_utility.trace('Finding Person name for person_id :' || p_person_id || ':');
--
  open csr_full_name;
  fetch csr_full_name into l_employee_name;
--
  if csr_full_name%notfound then
    l_employee_name := ' ';
  end if;
  close csr_full_name;
--
hr_utility.trace('Found :' || l_employee_name || ':');
--
  return l_employee_name;
--
END getPersonNameFromID;
--
--
procedure getOfferNotifSubjectForCreate
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2) is
begin
--
  getOfferNotificationSubject (
     document_id   => document_id
    ,display_type  => display_type
    ,document      => document
    ,document_type => document_type
    ,flowmode      => 'CREATE');
--
end getOfferNotifSubjectForCreate;
--
procedure getOfferNotifSubjectForEdit
  (document_id in varchar2,
  display_type in varchar2,
  document in out nocopy varchar2,
  document_type in out nocopy varchar2) is
begin
--
  getOfferNotificationSubject (
     document_id   => document_id
    ,display_type  => display_type
    ,document      => document
    ,document_type => document_type
    ,flowmode      => 'UPDATE');
--
end getOfferNotifSubjectForEdit;
--
procedure getOfferNotificationSubject (document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2,
                                  flowmode      in     varchar2) is
--
  l_vacancy_name     per_all_vacancies.name%type;
  l_transaction_id   hr_api_transactions.transaction_id%type;
  l_applicant_name per_all_people_f.full_name%type;
--
Begin
--
  hr_utility.trace('Fetching transaction id :');
--
  l_transaction_id := wf_notification.getattrnumber(document_id,'HR_TRANSACTION_REF_ID_ATTR');
  if l_transaction_id is null then
  --
    if flowmode = 'CREATE' then
      fnd_message.set_name('PER','IRC_CREATE_OFFER_APPROVAL');
      document := fnd_message.get;
    else
      fnd_message.set_name('PER','IRC_UPDATE_OFFER_APPROVAL');
      document := fnd_message.get;
    end if;
  --
  else
  --
    l_vacancy_name :=
      getVacancyNameFromId(
        getVacancyIdFromAssignmentId(
            irc_approvals.get_transaction_number_data (
             transaction_id => to_char(l_transaction_id),
             p_path         => '/Transaction/TransCtx/PrsnAssignmentId')));
    --
       l_applicant_name :=
         getPersonNameFromID(
           irc_approvals.get_transaction_number_data (
             transaction_id => to_char(l_transaction_id),
             p_path         => '/Transaction/TransCtx/PrsnId'));
    --
       if flowmode = 'CREATE' then
	fnd_message.set_name('PER','IRC_412390_OFFER_APPR_CREATE');
       else
	fnd_message.set_name('PER','IRC_412391_OFFER_APPR_EDIT');
       end if;
       fnd_message.set_token('PERSON_NAME',  l_applicant_name, false);
       fnd_message.set_token('VACANCY_NAME', l_vacancy_name, false);
       document := fnd_message.get;
    --
  --
  end if;
--
end getOfferNotificationSubject;

function getVacancyNameFromId(vacancy_id number)
return varchar
is
  vac_name per_all_vacancies.name%type;
  cursor vac_name_from_id (vac_id number) is
    select name
    from per_all_vacancies
    where vacancy_id=vac_id;
begin

  open vac_name_from_id(vacancy_id);
  fetch vac_name_from_id into vac_name;
  close vac_name_from_id;

return vac_name;

end getVacancyNameFromId;

function getVacancyIdFromAssignmentId(assignment_id number)
return number
is
  vac_id per_all_vacancies.vacancy_id%type;
  cursor vac_id_from_assn_id (assn_id number) is
    select vacancy_id
    from per_all_assignments_f
    where assignment_id=assn_id;
begin

  open vac_id_from_assn_id(assignment_id);
  fetch vac_id_from_assn_id into vac_id;
  close vac_id_from_assn_id;

  return vac_id;

end getVacancyIdFromAssignmentId;


END IRC_APPROVALS;

/
