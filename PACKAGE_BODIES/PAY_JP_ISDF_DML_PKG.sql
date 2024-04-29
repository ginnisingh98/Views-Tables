--------------------------------------------------------
--  DDL for Package Body PAY_JP_ISDF_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_ISDF_DML_PKG" as
/* $Header: pyjpisfa.pkb 120.2.12000000.2 2007/09/20 02:37:45 keyazawa noship $ */
--
c_package  constant varchar2(30) := 'pay_jp_isdf_dml_pkg.';
g_debug    boolean := hr_utility.debug_enabled;
--
-- -------------------------------------------------------------------------
-- next_action_information_id
-- -------------------------------------------------------------------------
function next_action_information_id return number
is
  l_action_information_id number;
  l_proc varchar2(80) := c_package||'next_action_information_id';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select pay_action_information_s.nextval
  into   l_action_information_id
  from   dual;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
  return  l_action_information_id;
--
end next_action_information_id;
--
-- -------------------------------------------------------------------------
-- lock_pact
-- -------------------------------------------------------------------------
procedure lock_pact(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_pact_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_pact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_pact_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND', 'FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_pact;
--
-- -------------------------------------------------------------------------
-- lock_assact
-- -------------------------------------------------------------------------
procedure lock_assact(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_assact_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_assact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_assact_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_assact;
--
-- -------------------------------------------------------------------------
-- lock_emp
-- -------------------------------------------------------------------------
procedure lock_emp(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_emp_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_emp';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_emp_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND', 'FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_emp;
--
-- -------------------------------------------------------------------------
-- lock_entry
-- -------------------------------------------------------------------------
procedure lock_entry(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_entry_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_entry';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_entry_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_entry;
--
-- -------------------------------------------------------------------------
-- lock_calc_dct
-- -------------------------------------------------------------------------
procedure lock_calc_dct(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_calc_dct_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_calc_dct';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_calc_dct_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_calc_dct;
--
-- -------------------------------------------------------------------------
-- lock_life_gen
-- -------------------------------------------------------------------------
procedure lock_life_gen(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_life_gen_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_life_gen';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_life_gen_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_life_gen;
--
-- -------------------------------------------------------------------------
-- lock_life_pens
-- -------------------------------------------------------------------------
procedure lock_life_pens(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_life_pens_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_life_pens';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_life_pens_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_life_pens;
--
-- -------------------------------------------------------------------------
-- lock_nonlife
-- -------------------------------------------------------------------------
procedure lock_nonlife(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_nonlife_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_nonlife';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_nonlife_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_nonlife;
--
-- -------------------------------------------------------------------------
-- lock_social
-- -------------------------------------------------------------------------
procedure lock_social(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_social_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_social';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_social_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_social;
--
-- -------------------------------------------------------------------------
-- lock_mutual_aid
-- -------------------------------------------------------------------------
procedure lock_mutual_aid(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_mutual_aid_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_mutual_aid';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_mutual_aid_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_mutual_aid;
--
-- -------------------------------------------------------------------------
-- lock_spouse
-- -------------------------------------------------------------------------
procedure lock_spouse(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_spouse_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_spouse';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_spouse_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_spouse;
--
-- -------------------------------------------------------------------------
-- lock_spouse_inc
-- -------------------------------------------------------------------------
procedure lock_spouse_inc(
  p_action_information_id in number,
  p_object_version_number in number,
  p_rec                   out nocopy pay_jp_isdf_spouse_inc_v%rowtype)
is
  l_proc varchar2(80) := c_package||'lock_spouse_inc';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  select *
  into   p_rec
  from   pay_jp_isdf_spouse_inc_v
  where  action_information_id = p_action_information_id
  for update nowait;
--
  if p_rec.object_version_number <> p_object_version_number then
    fnd_message.set_name('FND','FND_RECORD_CHANGED_ERROR');
    fnd_message.raise_error;
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
  when hr_api.object_locked then
    fnd_message.set_name('FND','FND_LOCK_RECORD_ERROR');
    fnd_message.raise_error;
  when no_data_found then
    fnd_message.set_name('FND','FND_RECORD_DELETED_ERROR');
    fnd_message.raise_error;
--
end lock_spouse_inc;
--
-- -------------------------------------------------------------------------
-- create_pact
-- -------------------------------------------------------------------------
procedure create_pact(
  p_action_information_id       in number,
  p_payroll_action_id           in number,
  p_action_context_type         in varchar2,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_payroll_id                  in number,
  p_organization_id             in number,
  p_assignment_set_id           in number,
  p_submission_period_status    in varchar2,
  p_submission_start_date       in date,
  p_submission_end_date         in date,
  p_tax_office_name             in varchar2,
  p_salary_payer_name           in varchar2,
  p_salary_payer_address        in varchar2,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_pact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_pact_dml_v(
    action_information_id,
    object_version_number,
    payroll_action_id,
    action_context_type,
    effective_date,
    action_information_category,
    payroll_id,
    organization_id,
    assignment_set_id,
    submission_period_status,
    submission_start_date,
    submission_end_date,
    tax_office_name,
    salary_payer_name,
    salary_payer_address)
  values(
    p_action_information_id,
    p_object_version_number,
    p_payroll_action_id,
    p_action_context_type,
    p_effective_date,
    p_action_information_category,
    fnd_number.number_to_canonical(p_payroll_id),
    fnd_number.number_to_canonical(p_organization_id),
    fnd_number.number_to_canonical(p_assignment_set_id),
    p_submission_period_status,
    fnd_date.date_to_canonical(p_submission_start_date),
    fnd_date.date_to_canonical(p_submission_end_date),
    p_tax_office_name,
    p_salary_payer_name,
    p_salary_payer_address);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_pact;
--
-- -------------------------------------------------------------------------
-- update_pact
-- -------------------------------------------------------------------------
procedure update_pact(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_submission_period_status    in varchar2,
  p_submission_start_date       in date,
  p_submission_end_date         in date,
  p_tax_office_name             in varchar2,
  p_salary_payer_name           in varchar2,
  p_salary_payer_address        in varchar2)
is
  l_rec  pay_jp_isdf_pact_v%rowtype;
  l_proc varchar2(80) := c_package||'update_pact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_pact(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_pact_dml_v
  set    object_version_number    = p_object_version_number,
         submission_period_status = p_submission_period_status,
         submission_start_date    = fnd_date.date_to_canonical(p_submission_start_date),
         submission_end_date      = fnd_date.date_to_canonical(p_submission_end_date),
         tax_office_name          = p_tax_office_name,
         salary_payer_name        = p_salary_payer_name,
         salary_payer_address     = p_salary_payer_address
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_pact;
--
-- -------------------------------------------------------------------------
-- create_assact
-- -------------------------------------------------------------------------
procedure create_assact(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_tax_type                    in varchar2,
  p_transaction_status          in varchar2,
  p_finalized_date              in date,
  p_finalized_by                in number,
  p_user_comments               in varchar2,
  p_admin_comments              in varchar2,
  p_transfer_status             in varchar2,
  p_transfer_date               in date,
  p_expiry_date                in date,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_assact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_assact_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    tax_type,
    transaction_status,
    finalized_date,
    finalized_by,
    user_comments,
    admin_comments,
    transfer_status,
    transfer_date,
    expiry_date)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_tax_type,
    p_transaction_status,
    fnd_date.date_to_canonical(p_finalized_date),
    fnd_number.number_to_canonical(p_finalized_by),
    p_user_comments,
    p_admin_comments,
    p_transfer_status,
    fnd_date.date_to_canonical(p_transfer_date),
    fnd_date.date_to_canonical(p_expiry_date));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_assact;
--
-- -------------------------------------------------------------------------
-- update_assact
-- -------------------------------------------------------------------------
procedure update_assact(
  p_action_information_id in number,
  p_object_version_number in out nocopy number,
  p_transaction_status    in varchar2,
  p_finalized_date        in date,
  p_finalized_by          in number,
  p_user_comments         in varchar2,
  p_admin_comments        in varchar2,
  p_transfer_status       in varchar2,
  p_transfer_date         in date,
  p_expiry_date           in date)
is
  l_rec  pay_jp_isdf_assact_v%rowtype;
  l_proc varchar2(80) := c_package||'update_assact';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_assact(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_assact_dml_v
  set    object_version_number = p_object_version_number,
         transaction_status    = p_transaction_status,
         finalized_date        = fnd_date.date_to_canonical(p_finalized_date),
         finalized_by          = fnd_number.number_to_canonical(p_finalized_by),
         user_comments         = p_user_comments,
         admin_comments        = p_admin_comments,
         transfer_status       = p_transfer_status,
         transfer_date         = fnd_date.date_to_canonical(p_transfer_date),
         expiry_date           = fnd_date.date_to_canonical(p_expiry_date)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_assact;
--
-- -------------------------------------------------------------------------
-- create_emp
-- -------------------------------------------------------------------------
procedure create_emp(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_employee_number             in varchar2,
  p_last_name_kana              in varchar2,
  p_first_name_kana             in varchar2,
  p_last_name                   in varchar2,
  p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_emp';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_emp_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    employee_number,
    last_name_kana,
    first_name_kana,
    last_name,
    first_name,
    postal_code,
    address)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_employee_number,
    p_last_name_kana,
    p_first_name_kana,
    p_last_name,
    p_first_name,
    p_postal_code,
    p_address);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_emp;
--
-- -------------------------------------------------------------------------
-- update_emp
-- -------------------------------------------------------------------------
procedure update_emp(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_postal_code                 in varchar2,
  p_address                     in varchar2)
is
  l_rec  pay_jp_isdf_emp_v%rowtype;
  l_proc varchar2(80) := c_package||'update_emp';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_emp(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_emp_dml_v
  set    object_version_number = p_object_version_number,
         postal_code           = p_postal_code,
         address               = p_address
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_emp;
--
-- -------------------------------------------------------------------------
-- create_entry
-- -------------------------------------------------------------------------
procedure create_entry(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_ins_datetrack_update_mode    in varchar2,
  p_ins_element_entry_id         in number,
  p_ins_ee_object_version_number in number,
  p_life_gen_ins_prem            in number,
  p_life_gen_ins_prem_o          in number,
  p_life_pens_ins_prem           in number,
  p_life_pens_ins_prem_o         in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_long_ins_prem_o      in number,
  p_nonlife_short_ins_prem       in number default null,
  p_nonlife_short_ins_prem_o     in number default null,
  p_earthquake_ins_prem          in number,
  p_earthquake_ins_prem_o        in number,
  p_is_datetrack_update_mode     in varchar2,
  p_is_element_entry_id          in number,
  p_is_ee_object_version_number  in number,
  p_social_ins_prem              in number,
  p_social_ins_prem_o            in number,
  p_mutual_aid_prem              in number,
  p_mutual_aid_prem_o            in number,
  p_spouse_income                in number,
  p_spouse_income_o              in number,
  p_national_pens_ins_prem       in number,
  p_national_pens_ins_prem_o     in number,
  p_object_version_number        out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_ins_entry';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_entry_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    ins_datetrack_update_mode,
    ins_element_entry_id,
    ins_ee_object_version_number,
    life_gen_ins_prem,
    life_gen_ins_prem_o,
    life_pens_ins_prem,
    life_pens_ins_prem_o,
    nonlife_long_ins_prem,
    nonlife_long_ins_prem_o,
    nonlife_short_ins_prem,
    nonlife_short_ins_prem_o,
    earthquake_ins_prem,
    earthquake_ins_prem_o,
    is_datetrack_update_mode,
    is_element_entry_id,
    is_ee_object_version_number,
    social_ins_prem,
    social_ins_prem_o,
    mutual_aid_prem,
    mutual_aid_prem_o,
    spouse_income,
    spouse_income_o,
    national_pens_ins_prem,
    national_pens_ins_prem_o)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    p_ins_datetrack_update_mode,
    fnd_number.number_to_canonical(p_ins_element_entry_id),
    fnd_number.number_to_canonical(p_ins_ee_object_version_number),
    fnd_number.number_to_canonical(p_life_gen_ins_prem),
    fnd_number.number_to_canonical(p_life_gen_ins_prem_o),
    fnd_number.number_to_canonical(p_life_pens_ins_prem),
    fnd_number.number_to_canonical(p_life_pens_ins_prem_o),
    fnd_number.number_to_canonical(p_nonlife_long_ins_prem),
    fnd_number.number_to_canonical(p_nonlife_long_ins_prem_o),
    fnd_number.number_to_canonical(p_nonlife_short_ins_prem),
    fnd_number.number_to_canonical(p_nonlife_short_ins_prem_o),
    fnd_number.number_to_canonical(p_earthquake_ins_prem),
    fnd_number.number_to_canonical(p_earthquake_ins_prem_o),
    p_is_datetrack_update_mode,
    fnd_number.number_to_canonical(p_is_element_entry_id),
    fnd_number.number_to_canonical(p_is_ee_object_version_number),
    fnd_number.number_to_canonical(p_social_ins_prem),
    fnd_number.number_to_canonical(p_social_ins_prem_o),
    fnd_number.number_to_canonical(p_mutual_aid_prem),
    fnd_number.number_to_canonical(p_mutual_aid_prem_o),
    fnd_number.number_to_canonical(p_spouse_income),
    fnd_number.number_to_canonical(p_spouse_income_o),
    fnd_number.number_to_canonical(p_national_pens_ins_prem),
    fnd_number.number_to_canonical(p_national_pens_ins_prem_o));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_entry;
--
-- -------------------------------------------------------------------------
-- update_entry
-- -------------------------------------------------------------------------
procedure update_entry(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_life_gen_ins_prem           in number,
  p_life_gen_ins_prem_o         in number,
  p_life_pens_ins_prem          in number,
  p_life_pens_ins_prem_o        in number,
  p_nonlife_long_ins_prem       in number,
  p_nonlife_long_ins_prem_o     in number,
  p_nonlife_short_ins_prem      in number default null,
  p_nonlife_short_ins_prem_o    in number default null,
  p_earthquake_ins_prem         in number,
  p_earthquake_ins_prem_o       in number,
  p_social_ins_prem             in number,
  p_social_ins_prem_o           in number,
  p_mutual_aid_prem             in number,
  p_mutual_aid_prem_o           in number,
  p_spouse_income               in number,
  p_spouse_income_o             in number,
  p_national_pens_ins_prem      in number,
  p_national_pens_ins_prem_o    in number)
is
  l_rec  pay_jp_isdf_entry_v%rowtype;
  l_proc varchar2(80) := c_package||'update_entry';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_entry(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_entry_dml_v
  set    object_version_number    = p_object_version_number,
         status                   = p_status,
         life_gen_ins_prem        = fnd_number.number_to_canonical(p_life_gen_ins_prem),
         life_gen_ins_prem_o      = fnd_number.number_to_canonical(p_life_gen_ins_prem_o),
         life_pens_ins_prem       = fnd_number.number_to_canonical(p_life_pens_ins_prem),
         life_pens_ins_prem_o     = fnd_number.number_to_canonical(p_life_pens_ins_prem_o),
         nonlife_long_ins_prem    = fnd_number.number_to_canonical(p_nonlife_long_ins_prem),
         nonlife_long_ins_prem_o  = fnd_number.number_to_canonical(p_nonlife_long_ins_prem_o),
         nonlife_short_ins_prem   = fnd_number.number_to_canonical(p_nonlife_short_ins_prem),
         nonlife_short_ins_prem_o = fnd_number.number_to_canonical(p_nonlife_short_ins_prem_o),
         earthquake_ins_prem      = fnd_number.number_to_canonical(p_earthquake_ins_prem),
         earthquake_ins_prem_o    = fnd_number.number_to_canonical(p_earthquake_ins_prem_o),
         social_ins_prem          = fnd_number.number_to_canonical(p_social_ins_prem),
         social_ins_prem_o        = fnd_number.number_to_canonical(p_social_ins_prem_o),
         mutual_aid_prem          = fnd_number.number_to_canonical(p_mutual_aid_prem),
         mutual_aid_prem_o        = fnd_number.number_to_canonical(p_mutual_aid_prem_o),
         spouse_income            = fnd_number.number_to_canonical(p_spouse_income),
         spouse_income_o          = fnd_number.number_to_canonical(p_spouse_income_o),
         national_pens_ins_prem   = fnd_number.number_to_canonical(p_national_pens_ins_prem),
         national_pens_ins_prem_o = fnd_number.number_to_canonical(p_national_pens_ins_prem_o)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_entry;
--
-- -------------------------------------------------------------------------
-- create_calc_dct
-- -------------------------------------------------------------------------
procedure create_calc_dct(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_life_gen_ins_prem            in number,
  p_life_pens_ins_prem           in number,
  p_life_gen_ins_calc_prem       in number,
  p_life_pens_ins_calc_prem      in number,
  p_life_ins_deduction           in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_short_ins_prem       in number default null,
  p_earthquake_ins_prem          in number,
  p_nonlife_long_ins_calc_prem   in number,
  p_nonlife_short_ins_calc_prem  in number default null,
  p_earthquake_ins_calc_prem     in number,
  p_nonlife_ins_deduction        in number,
  p_national_pens_ins_prem       in number,
  p_social_ins_deduction         in number,
  p_mutual_aid_deduction         in number,
  p_sp_earned_income_calc        in number,
  p_sp_business_income_calc      in number,
  p_sp_miscellaneous_income_calc in number,
  p_sp_dividend_income_calc      in number,
  p_sp_real_estate_income_calc   in number,
  p_sp_retirement_income_calc    in number,
  p_sp_other_income_calc         in number,
  p_sp_income_calc               in number,
  p_spouse_income                in number,
  p_spouse_deduction             in number,
  p_object_version_number        out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_calc_dct';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_calc_dct_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    life_gen_ins_prem,
    life_pens_ins_prem,
    life_gen_ins_calc_prem,
    life_pens_ins_calc_prem,
    life_ins_deduction,
    nonlife_long_ins_prem,
    nonlife_short_ins_prem,
    earthquake_ins_prem,
    nonlife_long_ins_calc_prem,
    nonlife_short_ins_calc_prem,
    earthquake_ins_calc_prem,
    nonlife_ins_deduction,
    social_ins_deduction,
    mutual_aid_deduction,
    sp_earned_income_calc,
    sp_business_income_calc,
    sp_miscellaneous_income_calc,
    sp_dividend_income_calc,
    sp_real_estate_income_calc,
    sp_retirement_income_calc,
    sp_other_income_calc,
    sp_income_calc,
    spouse_income,
    spouse_deduction,
    national_pens_ins_prem)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_life_gen_ins_prem),
    fnd_number.number_to_canonical(p_life_pens_ins_prem),
    fnd_number.number_to_canonical(p_life_gen_ins_calc_prem),
    fnd_number.number_to_canonical(p_life_pens_ins_calc_prem),
    fnd_number.number_to_canonical(p_life_ins_deduction),
    fnd_number.number_to_canonical(p_nonlife_long_ins_prem),
    fnd_number.number_to_canonical(p_nonlife_short_ins_prem),
    fnd_number.number_to_canonical(p_earthquake_ins_prem),
    fnd_number.number_to_canonical(p_nonlife_long_ins_calc_prem),
    fnd_number.number_to_canonical(p_nonlife_short_ins_calc_prem),
    fnd_number.number_to_canonical(p_earthquake_ins_calc_prem),
    fnd_number.number_to_canonical(p_nonlife_ins_deduction),
    fnd_number.number_to_canonical(p_social_ins_deduction),
    fnd_number.number_to_canonical(p_mutual_aid_deduction),
    fnd_number.number_to_canonical(p_sp_earned_income_calc),
    fnd_number.number_to_canonical(p_sp_business_income_calc),
    fnd_number.number_to_canonical(p_sp_miscellaneous_income_calc),
    fnd_number.number_to_canonical(p_sp_dividend_income_calc),
    fnd_number.number_to_canonical(p_sp_real_estate_income_calc),
    fnd_number.number_to_canonical(p_sp_retirement_income_calc),
    fnd_number.number_to_canonical(p_sp_other_income_calc),
    fnd_number.number_to_canonical(p_sp_income_calc),
    fnd_number.number_to_canonical(p_spouse_income),
    fnd_number.number_to_canonical(p_spouse_deduction),
    fnd_number.number_to_canonical(p_national_pens_ins_prem));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_calc_dct;
--
-- -------------------------------------------------------------------------
-- update_calc_dct
-- -------------------------------------------------------------------------
procedure update_calc_dct(
  p_action_information_id        in number,
  p_object_version_number        in out nocopy number,
  p_status                       in varchar2,
  p_life_gen_ins_prem            in number,
  p_life_pens_ins_prem           in number,
  p_life_gen_ins_calc_prem       in number,
  p_life_pens_ins_calc_prem      in number,
  p_life_ins_deduction           in number,
  p_nonlife_long_ins_prem        in number,
  p_nonlife_short_ins_prem       in number default null,
  p_earthquake_ins_prem          in number,
  p_nonlife_long_ins_calc_prem   in number,
  p_nonlife_short_ins_calc_prem  in number default null,
  p_earthquake_ins_calc_prem     in number,
  p_nonlife_ins_deduction        in number,
  p_national_pens_ins_prem       in number,
  p_social_ins_deduction         in number,
  p_mutual_aid_deduction         in number,
  p_sp_earned_income_calc        in number,
  p_sp_business_income_calc      in number,
  p_sp_miscellaneous_income_calc in number,
  p_sp_dividend_income_calc      in number,
  p_sp_real_estate_income_calc   in number,
  p_sp_retirement_income_calc    in number,
  p_sp_other_income_calc         in number,
  p_sp_income_calc               in number,
  p_spouse_income                in number,
  p_spouse_deduction             in number)
is
  l_rec  pay_jp_isdf_calc_dct_v%rowtype;
  l_proc varchar2(80) := c_package||'update_calc_dct';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_calc_dct(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_calc_dct_dml_v
  set    object_version_number        = p_object_version_number,
         status                       = p_status,
         life_gen_ins_prem            = fnd_number.number_to_canonical(p_life_gen_ins_prem),
         life_pens_ins_prem           = fnd_number.number_to_canonical(p_life_pens_ins_prem),
         life_gen_ins_calc_prem       = fnd_number.number_to_canonical(p_life_gen_ins_calc_prem),
         life_pens_ins_calc_prem      = fnd_number.number_to_canonical(p_life_pens_ins_calc_prem),
         life_ins_deduction           = fnd_number.number_to_canonical(p_life_ins_deduction),
         nonlife_long_ins_prem        = fnd_number.number_to_canonical(p_nonlife_long_ins_prem),
         nonlife_short_ins_prem       = fnd_number.number_to_canonical(p_nonlife_short_ins_prem),
         earthquake_ins_prem          = fnd_number.number_to_canonical(p_earthquake_ins_prem),
         nonlife_long_ins_calc_prem   = fnd_number.number_to_canonical(p_nonlife_long_ins_calc_prem),
         nonlife_short_ins_calc_prem  = fnd_number.number_to_canonical(p_nonlife_short_ins_calc_prem),
         earthquake_ins_calc_prem     = fnd_number.number_to_canonical(p_earthquake_ins_calc_prem),
         nonlife_ins_deduction        = fnd_number.number_to_canonical(p_nonlife_ins_deduction),
         social_ins_deduction         = fnd_number.number_to_canonical(p_social_ins_deduction),
         mutual_aid_deduction         = fnd_number.number_to_canonical(p_mutual_aid_deduction),
         sp_earned_income_calc        = fnd_number.number_to_canonical(p_sp_earned_income_calc),
         sp_business_income_calc      = fnd_number.number_to_canonical(p_sp_business_income_calc),
         sp_miscellaneous_income_calc = fnd_number.number_to_canonical(p_sp_miscellaneous_income_calc),
         sp_dividend_income_calc      = fnd_number.number_to_canonical(p_sp_dividend_income_calc),
         sp_real_estate_income_calc   = fnd_number.number_to_canonical(p_sp_real_estate_income_calc),
         sp_retirement_income_calc    = fnd_number.number_to_canonical(p_sp_retirement_income_calc),
         sp_other_income_calc         = fnd_number.number_to_canonical(p_sp_other_income_calc),
         sp_income_calc               = fnd_number.number_to_canonical(p_sp_income_calc),
         spouse_income                = fnd_number.number_to_canonical(p_spouse_income),
         spouse_deduction             = fnd_number.number_to_canonical(p_spouse_deduction),
         national_pens_ins_prem       = fnd_number.number_to_canonical(p_national_pens_ins_prem)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_calc_dct;
--
-- -------------------------------------------------------------------------
-- create_life_gen
-- -------------------------------------------------------------------------
procedure create_life_gen(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_gen_ins_class               in varchar2,
  p_gen_ins_company_code        in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_life_gen';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_life_gen_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    assignment_extra_info_id,
    aei_object_version_number,
    gen_ins_class,
    gen_ins_company_code,
    ins_company_name,
    ins_type,
    ins_period,
    contractor_name,
    beneficiary_name,
    beneficiary_relship,
    annual_prem)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_assignment_extra_info_id),
    fnd_number.number_to_canonical(p_aei_object_version_number),
    p_gen_ins_class,
    p_gen_ins_company_code,
    p_ins_company_name,
    p_ins_type,
    p_ins_period,
    p_contractor_name,
    p_beneficiary_name,
    p_beneficiary_relship,
    fnd_number.number_to_canonical(p_annual_prem));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_life_gen;
--
-- -------------------------------------------------------------------------
-- update_life_gen
-- -------------------------------------------------------------------------
procedure update_life_gen(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number)
is
  l_rec  pay_jp_isdf_life_gen_v%rowtype;
  l_proc varchar2(80) := c_package||'update_life_gen';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_life_gen(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_life_gen_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         ins_company_name            = p_ins_company_name,
         ins_type                    = p_ins_type,
         ins_period                  = p_ins_period,
         contractor_name             = p_contractor_name,
         beneficiary_name            = p_beneficiary_name,
         beneficiary_relship         = p_beneficiary_relship,
         annual_prem                 = fnd_number.number_to_canonical(p_annual_prem)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_life_gen;
--
-- -------------------------------------------------------------------------
-- delete_life_gen
-- -------------------------------------------------------------------------
procedure delete_life_gen(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_life_gen_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_life_gen';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_life_gen(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_life_gen_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_life_gen;
-- -------------------------------------------------------------------------
-- create_life_pens
-- -------------------------------------------------------------------------
procedure create_life_pens(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_pens_ins_class              in varchar2,
  p_pens_ins_company_code       in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period_start_date       in date,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_life_pens';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_life_pens_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    assignment_extra_info_id,
    aei_object_version_number,
    pens_ins_class,
    pens_ins_company_code,
    ins_company_name,
    ins_type,
    ins_period_start_date,
    ins_period,
    contractor_name,
    beneficiary_name,
    beneficiary_relship,
    annual_prem)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_assignment_extra_info_id),
    fnd_number.number_to_canonical(p_aei_object_version_number),
    p_pens_ins_class,
    p_pens_ins_company_code,
    p_ins_company_name,
    p_ins_type,
    fnd_date.date_to_canonical(p_ins_period_start_date),
    p_ins_period,
    p_contractor_name,
    p_beneficiary_name,
    p_beneficiary_relship,
    fnd_number.number_to_canonical(p_annual_prem));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_life_pens;
--
-- -------------------------------------------------------------------------
-- update_life_pens
-- -------------------------------------------------------------------------
procedure update_life_pens(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period_start_date       in date,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number)
is
  l_rec  pay_jp_isdf_life_pens_v%rowtype;
  l_proc varchar2(80) := c_package||'update_life_pens';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_life_pens(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_life_pens_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         ins_company_name            = p_ins_company_name,
         ins_type                    = p_ins_type,
         ins_period_start_date       = fnd_date.date_to_canonical(p_ins_period_start_date),
         ins_period                  = p_ins_period,
         contractor_name             = p_contractor_name,
         beneficiary_name            = p_beneficiary_name,
         beneficiary_relship         = p_beneficiary_relship,
         annual_prem                 = fnd_number.number_to_canonical(p_annual_prem)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_life_pens;
--
-- -------------------------------------------------------------------------
-- delete_life_pens
-- -------------------------------------------------------------------------
procedure delete_life_pens(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_life_pens_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_life_pens';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_life_pens(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_life_pens_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_life_pens;
--
-- -------------------------------------------------------------------------
-- create_nonlife
-- -------------------------------------------------------------------------
procedure create_nonlife(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_assignment_extra_info_id    in number,
  p_aei_object_version_number   in number,
  p_nonlife_ins_class           in varchar2,
  p_nonlife_ins_term_type       in varchar2,
  p_nonlife_ins_company_code    in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_maturity_repayment          in varchar2 default null,
  p_annual_prem                 in number,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_nonlife';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_nonlife_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    assignment_extra_info_id,
    aei_object_version_number,
    nonlife_ins_class,
    nonlife_ins_term_type,
    nonlife_ins_company_code,
    ins_company_name,
    ins_type,
    ins_period,
    contractor_name,
    beneficiary_name,
    beneficiary_relship,
    maturity_repayment,
    annual_prem)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_assignment_extra_info_id),
    fnd_number.number_to_canonical(p_aei_object_version_number),
    p_nonlife_ins_class,
    p_nonlife_ins_term_type,
    p_nonlife_ins_company_code,
    p_ins_company_name,
    p_ins_type,
    p_ins_period,
    p_contractor_name,
    p_beneficiary_name,
    p_beneficiary_relship,
    p_maturity_repayment,
    fnd_number.number_to_canonical(p_annual_prem));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_nonlife;
--
-- -------------------------------------------------------------------------
-- update_nonlife
-- -------------------------------------------------------------------------
procedure update_nonlife(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_nonlife_ins_term_type       in varchar2,
  p_ins_company_name            in varchar2,
  p_ins_type                    in varchar2,
  p_ins_period                  in varchar2,
  p_contractor_name             in varchar2,
  p_beneficiary_name            in varchar2,
  p_beneficiary_relship         in varchar2,
  p_maturity_repayment          in varchar2 default null,
  p_annual_prem                 in number)
is
  l_rec  pay_jp_isdf_nonlife_v%rowtype;
  l_proc varchar2(80) := c_package||'update_nonlife';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_nonlife(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_nonlife_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         ins_company_name            = p_ins_company_name,
         ins_type                    = p_ins_type,
         ins_period                  = p_ins_period,
         contractor_name             = p_contractor_name,
         beneficiary_name            = p_beneficiary_name,
         beneficiary_relship         = p_beneficiary_relship,
         maturity_repayment          = p_maturity_repayment,
         annual_prem                 = fnd_number.number_to_canonical(p_annual_prem)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_nonlife;
--
-- -------------------------------------------------------------------------
-- delete_nonlife
-- -------------------------------------------------------------------------
procedure delete_nonlife(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_nonlife_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_nonlife';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_nonlife(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_nonlife_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_nonlife;
--
-- -------------------------------------------------------------------------
-- create_social
-- -------------------------------------------------------------------------
procedure create_social(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_ins_type                    in varchar2,
  p_ins_payee_name              in varchar2,
  p_debtor_name                 in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_national_pens_flag          in varchar2,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_social';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_social_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    ins_type,
    ins_payee_name,
    debtor_name,
    beneficiary_relship,
    annual_prem,
    national_pens_flag)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    p_ins_type,
    p_ins_payee_name,
    p_debtor_name,
    p_beneficiary_relship,
    fnd_number.number_to_canonical(p_annual_prem),
    p_national_pens_flag);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_social;
--
-- -------------------------------------------------------------------------
-- update_social
-- -------------------------------------------------------------------------
procedure update_social(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_ins_type                    in varchar2,
  p_ins_payee_name              in varchar2,
  p_debtor_name                 in varchar2,
  p_beneficiary_relship         in varchar2,
  p_annual_prem                 in number,
  p_national_pens_flag          in varchar2)
is
  l_rec  pay_jp_isdf_social_v%rowtype;
  l_proc varchar2(80) := c_package||'update_social';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_social(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_social_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         ins_type                    = p_ins_type,
         ins_payee_name              = p_ins_payee_name,
         debtor_name                 = p_debtor_name,
         beneficiary_relship         = p_beneficiary_relship,
         annual_prem                 = fnd_number.number_to_canonical(p_annual_prem),
         national_pens_flag          = p_national_pens_flag
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_social;
--
-- -------------------------------------------------------------------------
-- delete_social
-- -------------------------------------------------------------------------
procedure delete_social(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_social_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_social';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_social(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_social_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_social;
--
-- -------------------------------------------------------------------------
-- create_mutual_aid
-- -------------------------------------------------------------------------
procedure create_mutual_aid(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_enterprise_contract_prem    in number,
  p_pension_prem                in number,
  p_disable_sup_contract_prem   in number,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_mutual_aid';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_mutual_aid_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    enterprise_contract_prem,
    pension_prem,
    disable_sup_contract_prem)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_enterprise_contract_prem),
    fnd_number.number_to_canonical(p_pension_prem),
    fnd_number.number_to_canonical(p_disable_sup_contract_prem));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_mutual_aid;
--
-- -------------------------------------------------------------------------
-- update_mutual_aid
-- -------------------------------------------------------------------------
procedure update_mutual_aid(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_enterprise_contract_prem    in number,
  p_pension_prem                in number,
  p_disable_sup_contract_prem   in number)
is
  l_rec  pay_jp_isdf_mutual_aid_v%rowtype;
  l_proc varchar2(80) := c_package||'update_mutual_aid';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_mutual_aid(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_mutual_aid_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         enterprise_contract_prem    = fnd_number.number_to_canonical(p_enterprise_contract_prem),
         pension_prem                = fnd_number.number_to_canonical(p_pension_prem),
         disable_sup_contract_prem   = fnd_number.number_to_canonical(p_disable_sup_contract_prem)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_mutual_aid;
--
-- -------------------------------------------------------------------------
-- delete_mutual_aid
-- -------------------------------------------------------------------------
procedure delete_mutual_aid(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_mutual_aid_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_mutual_aid';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_mutual_aid(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_mutual_aid_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_mutual_aid;
--
-- -------------------------------------------------------------------------
-- create_spouse
-- -------------------------------------------------------------------------
procedure create_spouse(
  p_action_information_id       in number,
  p_assignment_action_id        in number,
  p_action_context_type         in varchar2,
  p_assignment_id               in number,
  p_effective_date              in date,
  p_action_information_category in varchar2,
  p_status                      in varchar2,
  p_full_name_kana              in varchar2,
  --p_last_name_kana              in varchar2,
  --p_first_name_kana             in varchar2,
  p_full_name                   in varchar2,
  --p_last_name                   in varchar2,
  --p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_emp_income                  in number,
  p_spouse_type                 in varchar2,
  p_widow_type                  in varchar2,
  p_spouse_dct_exclude          in varchar2,
  p_spouse_income_entry         in number,
  p_object_version_number       out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_spouse';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_spouse_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    full_name_kana,
    --last_name_kana,
    --first_name_kana,
    full_name,
    --last_name,
    --first_name,
    postal_code,
    address,
    emp_income,
    spouse_type,
    widow_type,
    spouse_dct_exclude,
    spouse_income_entry)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    p_full_name_kana,
    --p_last_name_kana,
    --p_first_name_kana,
    p_full_name,
    --p_last_name,
    --p_first_name,
    p_postal_code,
    p_address,
    fnd_number.number_to_canonical(p_emp_income),
    p_spouse_type,
    p_widow_type,
    p_spouse_dct_exclude,
    fnd_number.number_to_canonical(p_spouse_income_entry));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_spouse;
--
-- -------------------------------------------------------------------------
-- update_spouse
-- -------------------------------------------------------------------------
procedure update_spouse(
  p_action_information_id       in number,
  p_object_version_number       in out nocopy number,
  p_status                      in varchar2,
  p_full_name_kana              in varchar2,
  --p_last_name_kana              in varchar2,
  --p_first_name_kana             in varchar2,
  p_full_name                   in varchar2,
  --p_last_name                   in varchar2,
  --p_first_name                  in varchar2,
  p_postal_code                 in varchar2,
  p_address                     in varchar2,
  p_emp_income                  in number,
  p_spouse_type                 in varchar2,
  p_widow_type                  in varchar2,
  p_spouse_dct_exclude          in varchar2,
  p_spouse_income_entry         in number)
is
  l_rec  pay_jp_isdf_spouse_v%rowtype;
  l_proc varchar2(80) := c_package||'update_spouse';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_spouse(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_spouse_dml_v
  set    object_version_number       = p_object_version_number,
         status                      = p_status,
         full_name_kana              = p_full_name_kana,
         --last_name_kana              = p_last_name_kana,
         --first_name_kana             = p_first_name_kana,
         full_name                   = p_full_name,
         --last_name                   = p_last_name,
         --first_name                  = p_first_name,
         postal_code                 = p_postal_code,
         address                     = p_address,
         emp_income                  = fnd_number.number_to_canonical(p_emp_income),
         spouse_type                 = p_spouse_type,
         widow_type                  = p_widow_type,
         spouse_dct_exclude          = p_spouse_dct_exclude,
         spouse_income_entry         = fnd_number.number_to_canonical(p_spouse_income_entry)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_spouse;
--
-- -------------------------------------------------------------------------
-- delete_spouse
-- -------------------------------------------------------------------------
procedure delete_spouse(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_spouse_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_spouse';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_spouse(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_spouse_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_spouse;
--
-- -------------------------------------------------------------------------
-- create_spouse_inc
-- -------------------------------------------------------------------------
procedure create_spouse_inc(
  p_action_information_id        in number,
  p_assignment_action_id         in number,
  p_action_context_type          in varchar2,
  p_assignment_id                in number,
  p_effective_date               in date,
  p_action_information_category  in varchar2,
  p_status                       in varchar2,
  p_sp_earned_income             in number,
  p_sp_earned_income_exp         in number,
  p_sp_business_income           in number,
  p_sp_business_income_exp       in number,
  p_sp_miscellaneous_income      in number,
  p_sp_miscellaneous_income_exp  in number,
  p_sp_dividend_income           in number,
  p_sp_dividend_income_exp       in number,
  p_sp_real_estate_income        in number,
  p_sp_real_estate_income_exp    in number,
  p_sp_retirement_income         in number,
  p_sp_retirement_income_exp     in number,
  p_sp_other_income              in number,
  p_sp_other_income_exp          in number,
  p_sp_other_income_exp_dct      in number,
  p_sp_other_income_exp_temp     in number,
  p_sp_other_income_exp_temp_exp in number,
  p_object_version_number        out nocopy number)
is
  l_proc varchar2(80) := c_package||'create_spouse_inc';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  p_object_version_number := 1;
--
  insert into pay_jp_isdf_spouse_inc_dml_v(
    action_information_id,
    object_version_number,
    assignment_action_id,
    action_context_type,
    assignment_id,
    effective_date,
    action_information_category,
    status,
    sp_earned_income,
    sp_earned_income_exp,
    sp_business_income,
    sp_business_income_exp,
    sp_miscellaneous_income,
    sp_miscellaneous_income_exp,
    sp_dividend_income,
    sp_dividend_income_exp,
    sp_real_estate_income,
    sp_real_estate_income_exp,
    sp_retirement_income,
    sp_retirement_income_exp,
    sp_other_income,
    sp_other_income_exp,
    sp_other_income_exp_dct,
    sp_other_income_exp_temp,
    sp_other_income_exp_temp_exp)
  values(
    p_action_information_id,
    p_object_version_number,
    p_assignment_action_id,
    p_action_context_type,
    p_assignment_id,
    p_effective_date,
    p_action_information_category,
    p_status,
    fnd_number.number_to_canonical(p_sp_earned_income),
    fnd_number.number_to_canonical(p_sp_earned_income_exp),
    fnd_number.number_to_canonical(p_sp_business_income),
    fnd_number.number_to_canonical(p_sp_business_income_exp),
    fnd_number.number_to_canonical(p_sp_miscellaneous_income),
    fnd_number.number_to_canonical(p_sp_miscellaneous_income_exp),
    fnd_number.number_to_canonical(p_sp_dividend_income),
    fnd_number.number_to_canonical(p_sp_dividend_income_exp),
    fnd_number.number_to_canonical(p_sp_real_estate_income),
    fnd_number.number_to_canonical(p_sp_real_estate_income_exp),
    fnd_number.number_to_canonical(p_sp_retirement_income),
    fnd_number.number_to_canonical(p_sp_retirement_income_exp),
    fnd_number.number_to_canonical(p_sp_other_income),
    fnd_number.number_to_canonical(p_sp_other_income_exp),
    fnd_number.number_to_canonical(p_sp_other_income_exp_dct),
    fnd_number.number_to_canonical(p_sp_other_income_exp_temp),
    fnd_number.number_to_canonical(p_sp_other_income_exp_temp_exp));
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end create_spouse_inc;
--
-- -------------------------------------------------------------------------
-- update_spouse_inc
-- -------------------------------------------------------------------------
procedure update_spouse_inc(
  p_action_information_id        in number,
  p_object_version_number        in out nocopy number,
  p_status                       in varchar2,
  p_sp_earned_income             in number,
  p_sp_earned_income_exp         in number,
  p_sp_business_income           in number,
  p_sp_business_income_exp       in number,
  p_sp_miscellaneous_income      in number,
  p_sp_miscellaneous_income_exp  in number,
  p_sp_dividend_income           in number,
  p_sp_dividend_income_exp       in number,
  p_sp_real_estate_income        in number,
  p_sp_real_estate_income_exp    in number,
  p_sp_retirement_income         in number,
  p_sp_retirement_income_exp     in number,
  p_sp_other_income              in number,
  p_sp_other_income_exp          in number,
  p_sp_other_income_exp_dct      in number,
  p_sp_other_income_exp_temp     in number,
  p_sp_other_income_exp_temp_exp in number)
is
  l_rec  pay_jp_isdf_spouse_inc_v%rowtype;
  l_proc varchar2(80) := c_package||'update_spouse_inc';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_spouse_inc(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
  end if;
--
  p_object_version_number := p_object_version_number + 1;
--
  update pay_jp_isdf_spouse_inc_dml_v
  set    object_version_number        = p_object_version_number,
         status                       = p_status,
         sp_earned_income             = fnd_number.number_to_canonical(p_sp_earned_income),
         sp_earned_income_exp         = fnd_number.number_to_canonical(p_sp_earned_income_exp),
         sp_business_income           = fnd_number.number_to_canonical(p_sp_business_income),
         sp_business_income_exp       = fnd_number.number_to_canonical(p_sp_business_income_exp),
         sp_miscellaneous_income      = fnd_number.number_to_canonical(p_sp_miscellaneous_income),
         sp_miscellaneous_income_exp  = fnd_number.number_to_canonical(p_sp_miscellaneous_income_exp),
         sp_dividend_income           = fnd_number.number_to_canonical(p_sp_dividend_income),
         sp_dividend_income_exp       = fnd_number.number_to_canonical(p_sp_dividend_income_exp),
         sp_real_estate_income        = fnd_number.number_to_canonical(p_sp_real_estate_income),
         sp_real_estate_income_exp    = fnd_number.number_to_canonical(p_sp_real_estate_income_exp),
         sp_retirement_income         = fnd_number.number_to_canonical(p_sp_retirement_income),
         sp_retirement_income_exp     = fnd_number.number_to_canonical(p_sp_retirement_income_exp),
         sp_other_income              = fnd_number.number_to_canonical(p_sp_other_income),
         sp_other_income_exp          = fnd_number.number_to_canonical(p_sp_other_income_exp),
         sp_other_income_exp_dct      = fnd_number.number_to_canonical(p_sp_other_income_exp_dct),
         sp_other_income_exp_temp     = fnd_number.number_to_canonical(p_sp_other_income_exp_temp),
         sp_other_income_exp_temp_exp = fnd_number.number_to_canonical(p_sp_other_income_exp_temp_exp)
  where  row_id = l_rec.row_id;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end update_spouse_inc;
--
-- -------------------------------------------------------------------------
-- delete_spouse_inc
-- -------------------------------------------------------------------------
procedure delete_spouse_inc(
  p_action_information_id   in number,
  p_object_version_number   in number)
is
  l_rec  pay_jp_isdf_spouse_inc_v%rowtype;
  l_proc varchar2(80) := c_package||'delete_spouse_inc';
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  lock_spouse_inc(p_action_information_id, p_object_version_number, l_rec);
--
  if g_debug then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('status  : ' || l_rec.status);
  end if;
--
  if l_rec.status = 'I' then
  --
    delete
    from  pay_action_information
    where rowid = l_rec.row_id;
  --
  elsif l_rec.status = 'Q' then
  --
    update pay_jp_isdf_spouse_inc_dml_v
    set    object_version_number = l_rec.object_version_number + 1,
           status                = 'D'
    where  rowid = l_rec.row_id;
  --
  end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end delete_spouse_inc;
--
end pay_jp_isdf_dml_pkg;

/
