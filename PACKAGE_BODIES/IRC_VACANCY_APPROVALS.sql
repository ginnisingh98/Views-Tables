--------------------------------------------------------
--  DDL for Package Body IRC_VACANCY_APPROVALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VACANCY_APPROVALS" as
/* $Header: ircvacame.pkb 120.0 2006/03/31 23:28:53 mmillmor noship $ */

g_posting_path varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/IrcPostingContentsVlEORow';
g_vacancy_path varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/PerRequisitionsEORow/CEO/EO/PerAllVacanciesEORow';
g_search_path  varchar2(250) :=
  '/Transaction/TransCache/AM/TXN/EO/PerRequisitionsEORow/CEO/EO/PerAllVacanciesEORow/CEO/EO/IrcVacancySearchCriteriaEORow';

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
irc_vacancy_approvals.show('Entering get_transaction_data for transaction_id :' || p_transaction_id || ':');
irc_vacancy_approvals.show('Access path :' || p_path || ':');
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
irc_vacancy_approvals.show('Exiting get_transaction_data returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_transaction_number_data');
--
l_retval:=irc_vacancy_approvals.get_transaction_data
          (p_transaction_id       =>transaction_id
          ,p_path          =>p_path);
ln_retval:=to_number(l_retval);
--
irc_vacancy_approvals.show('Exiting get_transaction_number_data');
--
return ln_retval;
end get_transaction_number_data;
--
-- -------------------------------------------------------------------------
--
function get_transaction_mode
(transaction_id in varchar2)
--
return varchar2 is
l_retval varchar2(200);
begin
--
irc_vacancy_approvals.show('Entering get_transaction_mode');
--
l_retval:=irc_vacancy_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id
                    ,p_path => '/Transaction/TransCtx/CNode/dmlMode');
--
irc_vacancy_approvals.show('Exiting get_transaction_mode');
--
return l_retval;
end get_transaction_mode;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_number
(transaction_id in varchar2, data_name in varchar2)
return number is
l_retval  number;
begin
--
irc_vacancy_approvals.show('Entering get_posting_content_id');
--
l_retval:=irc_vacancy_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id,p_path => g_posting_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_posting_content_id');
--
return l_retval;
end get_posting_data_number;
--
-- -------------------------------------------------------------------------
--
function get_posting_data_varchar
(transaction_id in varchar2, data_name in varchar2)
return varchar2 is
l_retval  varchar2(200);
begin
--
irc_vacancy_approvals.show('Entering get_posting_content_id');
--
l_retval:=irc_vacancy_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id,p_path => g_posting_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_posting_content_id');
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
irc_vacancy_approvals.show('Entering get_vac_business_group_id');
--
l_retval:=irc_vacancy_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id
                    ,p_path => g_vacancy_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_vac_business_group_id');
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
irc_vacancy_approvals.show('Entering get_vac_budget_type');
--
l_retval:=irc_vacancy_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id
                    ,p_path => g_vacancy_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_vac_budget_type');
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
irc_vacancy_approvals.show('Entering get_search_data_number');
--
l_retval:=irc_vacancy_approvals.get_transaction_number_data
                    (transaction_id=>transaction_id,p_path => g_search_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_search_data_number');
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
irc_vacancy_approvals.show('Entering get_search_data_varchar');
--
l_retval:=irc_vacancy_approvals.get_transaction_data
                    (p_transaction_id=>transaction_id,p_path => g_search_path || '/' || data_name);
--
irc_vacancy_approvals.show('Exiting get_search_data_varchar');
--
return l_retval;
end get_search_data_varchar;
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
irc_vacancy_approvals.show('Entering get_vac_organization_changed');
--
  l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id := irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'OrganizationId');
--
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_vacancy_approvals.show('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_organization_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_job_changed');
--
  l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  l_new_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'JobId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_vacancy_approvals.show('Comparing old job id :' || to_char(l_old_id)
                   || ': to new job id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_job_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_grade_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'GradeId');
--
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_vacancy_approvals.show('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <> nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_grade_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_position_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_id     := irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'PositionId');
--
  l_vacancy_id := irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_vacancy_approvals.show('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <>nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_position_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_budget_value_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id)<>'INSERT' then
--
  l_new_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'BudgetMeasurementValue');
--
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_id(l_vacancy_id);
  fetch get_old_id into l_old_id;
  close get_old_id;
--
irc_vacancy_approvals.show('Comparing old org id :' || to_char(l_old_id)
                   || ': to new org id :' || to_char(l_new_id) || ':');
--
  if(nvl(l_new_id,hr_api.g_number)
     <>nvl(l_old_id,hr_api.g_number) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_budget_value_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_budget_type_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_new_value:=irc_vacancy_approvals.get_vacancy_data_varchar(transaction_id=>transaction_id,data_name=>'BudgetMeasurementType');
--
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_value(l_vacancy_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_budget_type_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_vac_status_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_new_value:=irc_vacancy_approvals.get_vacancy_data_varchar(transaction_id=>transaction_id,data_name=>'Status');
--
  l_vacancy_id:=irc_vacancy_approvals.get_vacancy_data_number(transaction_id=>transaction_id,data_name=>'VacancyId');
  open get_old_value(l_vacancy_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_vac_status_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_posting_title_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'Name');

  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_posting_title_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_posting_job_title_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'JobTitle');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_posting_job_title_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_posting_department_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'OrgName');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_old_value;
  close get_old_value;
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_posting_department_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_posting_dept_desc_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id, data_name => 'OrgDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
--
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_posting_dept_desc_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_brief_description_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'BriefDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;

  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_brief_description_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_detailed_desc_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'DetailedDescription');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_detailed_desc_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_job_requirements_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'JobRequirements');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_job_requirements_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_additional_details_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'AdditionalDetails');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_additional_details_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_how_to_apply_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id) <> 'INSERT' then
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
--
  l_new_value:=irc_vacancy_approvals.get_posting_data_varchar
                    (transaction_id=>transaction_id ,data_name => 'HowToApply');
--
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
      <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
end if;
--
irc_vacancy_approvals.show('Exiting get_how_to_apply_changed returning :' || l_retval || ':');
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
irc_vacancy_approvals.show('Entering get_posting_graphic_changed');
--
l_retval := 'false';
--
if irc_vacancy_approvals.get_transaction_mode(transaction_id)<> 'INSERT' then
--
  l_new_value := irc_vacancy_approvals.get_posting_data_varchar
    (transaction_id=>transaction_id ,data_name => 'ImageUrl');
--
  l_posting_content_id := irc_vacancy_approvals.get_posting_data_number
    (transaction_id=>transaction_id, data_name=>'PostingContentId');
  open get_old_value(l_posting_content_id);
  fetch get_old_value into l_clob_old_value;
  close get_old_value;
  l_old_value := dbms_lob.substr(l_clob_old_value);
--
irc_vacancy_approvals.show('Comparing old org value :' || l_old_value
                   || ': to new org value :' || l_new_value || ':');
--
  if(nvl(l_new_value,hr_api.g_varchar2)
     <> nvl(l_old_value,hr_api.g_varchar2) ) then
    l_retval:='true';
  end if;
--
end if;
--
irc_vacancy_approvals.show('Exiting get_posting_graphic_changed returning :' || l_retval || ':');
--
return l_retval;
--
end get_posting_graphic_changed;
--
procedure show(message in varchar2) is
BEGIN
  hr_utility.trace(message);
END show;
--
--
function get_custom_rule return varchar2 is
BEGIN
  return 'SEEDED_RULE';
END get_custom_rule;
--
--
END IRC_VACANCY_APPROVALS;

/
