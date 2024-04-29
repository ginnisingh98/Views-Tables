--------------------------------------------------------
--  DDL for Package Body PER_KR_EXTRA_ASSIGNMENT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_EXTRA_ASSIGNMENT_RULES" as
/* $Header: pekrexas.pkb 120.1 2005/06/05 22:16:12 appldev noship $ */
--
procedure chk_establishment_id(
            p_establishment_id   in number,
            p_assignment_type    in varchar2,
            p_payroll_id         in number,
            p_effective_date     in date)
is
  l_exists  varchar2(1);
  cursor csr_bp is
    select  'Y'
    from    hr_kr_establishments_v
    where   organization_id = p_establishment_id
    and     p_effective_date
            between date_from and nvl(date_to, p_effective_date);
begin

  -- 4409795: skip validation if KR legislation is not installed
  if not hr_utility.chk_product_install('Oracle Human Resources', 'KR') then
    hr_utility.trace ('KR Legislation not installed. Not performing the validations.');
    return;
  end if;

  --
  -- Check whether the establishment is valid Business Place.
  --
  if p_establishment_id is not null then
    open csr_bp;
    fetch csr_bp into l_exists;
    if csr_bp%NOTFOUND then
      close csr_bp;
      fnd_message.set_name('PER', 'PER_52818_INVALID_ESTAB');
      fnd_message.raise_error;
    end if;
    close csr_bp;
  else
    --
    -- When payroll_id is specified, establishment_id is mandatory.
    -- This validation is done only for Payroll Assignment.
    -- Applicant and Benefit Assignment are not eligible for this validation.
    --
    if p_assignment_type = 'E' and p_payroll_id is not null then
      fnd_message.set_name('PAY', 'HR_INV_LEG_ENT_KR');
      fnd_message.raise_error;
    end if;
  end if;
end chk_establishment_id;
--
procedure chk_establishment_id_upd(
            p_establishment_id   in number,
            p_establishment_id_o in number,
            p_assignment_type    in varchar2,
            p_payroll_id         in number,
            p_effective_date     in date)
is
begin

  -- 4409795: skip validation if KR legislation is not installed

  if not hr_utility.chk_product_install('Oracle Human Resources', 'KR') then
    hr_utility.trace ('KR Legislation not installed. Not performing the validations.');
    return;
  end if;

  if nvl(p_establishment_id, hr_api.g_number) <> nvl(p_establishment_id_o, hr_api.g_number) then
    chk_establishment_id(
      p_establishment_id => p_establishment_id,
      p_assignment_type  => p_assignment_type,
      p_payroll_id       => p_payroll_id,
      p_effective_date   => p_effective_date);
  else
    --
    -- When payroll_id is specified, establishment_id is mandatory.
    -- This validation is done only for Payroll Assignment.
    -- Applicant and Benefit Assignment are not eligible for this validation.
    --
    if p_assignment_type = 'E' and p_payroll_id is not null and p_establishment_id is null then
      fnd_message.set_name('PAY', 'HR_INV_LEG_ENT_KR');
      fnd_message.raise_error;
    end if;
  end if;
end chk_establishment_id_upd;
--
end per_kr_extra_assignment_rules;

/
