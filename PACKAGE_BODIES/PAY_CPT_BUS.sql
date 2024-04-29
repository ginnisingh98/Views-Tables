--------------------------------------------------------
--  DDL for Package Body PAY_CPT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CPT_BUS" as
/* $Header: pycprrhi.pkb 120.1.12010000.3 2008/08/06 07:04:33 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_cpt_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_assignment_id >------|
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_emp_province_tax_inf_id    in number
  ,p_assignment_id            in
                               pay_ca_emp_prov_tax_info_f.assignment_id%TYPE
  ,p_business_group_id        in
                           pay_ca_emp_prov_tax_info_f.business_group_id%TYPE
  ,p_effective_date           in date
  ,p_object_version_number    in number
  ) is
  --
  l_proc                    varchar2(72) := g_package||'chk_assignment_id';
  l_dummy                   varchar2(1);
  l_api_updating            boolean;
  l_business_group_id       per_assignments_f.business_group_id%TYPE;
  --
  cursor c1 is
    select business_group_id
    from   per_assignments_f asg
    where  asg.assignment_id = p_assignment_id
    and    p_effective_date between asg.effective_start_date
             and asg.effective_end_date;
  --
  cursor c2 is
    select null
    from   pay_ca_emp_fed_tax_info_f fed
    where  fed.assignment_id = p_assignment_id
    and    p_effective_date between fed.effective_start_date
             and fed.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- Check that the mandatory parameters have been set
  --
  if p_assignment_id is null then
    hr_utility.set_message(800, 'HR_74023_ASSIGNMENT_ID_NULL');
    hr_utility.raise_error;
  end if;
  --
  if p_business_group_id is null then
    hr_utility.set_message(800, 'HR_74024_BUSINESS_GROUP_ID_NULL');
    hr_utility.raise_error;
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  l_api_updating := pay_cpt_shd.api_updating
     (p_emp_province_tax_inf_id     => p_emp_province_tax_inf_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  --  Since assignment_id cannot be updated, the case of
  --  l_api_updating = TRUE is not considered
  --
  if (l_api_updating ) then
    if p_assignment_id <> pay_cpt_shd.g_old_rec.assignment_id then
--     dbms_output.put_line('cannot change assignment_id');
        hr_utility.set_message(800, 'HR_74027_ASSIGNMENT_ID_CHANGED');
        hr_utility.raise_error;
    end if;
  end if;
--
--  if (not l_api_updating) then
    --
    open c1;
      --
      fetch c1 into l_business_group_id;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as assignment_id not found in per_assignments_f
        -- table.
        --
        hr_utility.set_message(800, 'HR_74025_INVALID_ASSIGNMENT_ID');
        hr_utility.raise_error;
        --
      else
        --
        close c1;
        --
        if p_business_group_id <> l_business_group_id then
          --
          hr_utility.set_message(800, 'HR_74026_INVALID_BG_ID');
          hr_utility.raise_error;
          --
        else
          --
          open c2;
          fetch c2 into l_dummy;
          if c2%notfound then
            close c2;
            hr_utility.set_message(800, 'PAY_74029_NO_FED_TAX_INFO');
            hr_utility.raise_error;
          end if;
          close c2;
          --
        end if;
        --
      end if;
      --
--  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_assignment_id;
-- ----------------------------------------------------------------------------
-- |------< chk_emp_province_tax_inf_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   effective_date Effective Date of session
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_emp_province_tax_inf_id(p_emp_province_tax_inf_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_emp_province_tax_inf_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_emp_province_tax_inf_id,hr_api.g_number)
     <>  pay_cpt_shd.g_old_rec.emp_province_tax_inf_id) then
    --
    -- raise error as PK has changed
    --
    pay_cpt_shd.constraint_error('PAY_CA_EMP_PROVIN_TAX_RULES_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_emp_province_tax_inf_id is not null then
      --
      -- raise error as PK is not null
      --
      pay_cpt_shd.constraint_error('PAY_CA_EMP_PROVIN_TAX_RULES_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_emp_province_tax_inf_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_wc_exempt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   wc_exempt_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_wc_exempt_flag(p_emp_province_tax_inf_id                in number,
                            p_wc_exempt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_wc_exempt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_wc_exempt_flag
      <> nvl(pay_cpt_shd.g_old_rec.wc_exempt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_wc_exempt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_wc_exempt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_WC_EXEMPT_FLAG_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_wc_exempt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pmed_exempt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   pmed_exempt_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_pmed_exempt_flag(p_emp_province_tax_inf_id                in number,
                            p_pmed_exempt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pmed_exempt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pmed_exempt_flag
      <> nvl(pay_cpt_shd.g_old_rec.pmed_exempt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pmed_exempt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pmed_exempt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_PMED_EXEMPT_FLAG_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pmed_exempt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_prov_exempt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   prov_exempt_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_prov_exempt_flag(p_emp_province_tax_inf_id                in number,
                            p_prov_exempt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prov_exempt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prov_exempt_flag
      <> nvl(pay_cpt_shd.g_old_rec.prov_exempt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prov_exempt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prov_exempt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_PROV_EXEMPT_FLAG_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prov_exempt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_basic_exemption_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   basic_exemption_flag Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_basic_exemption_flag(p_emp_province_tax_inf_id                in number,
                            p_basic_exemption_flag        in varchar2,
                            p_tax_credit_amount           in number,
                            p_province_code               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_basic_exemption_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id     => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_basic_exemption_flag
      <> nvl(pay_cpt_shd.g_old_rec.basic_exemption_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_basic_exemption_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_basic_exemption_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_BASIC_EXEMPT_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;

    --
  end if;
    if nvl(p_basic_exemption_flag,'N') = 'N'
       and p_tax_credit_amount is null
     then
      hr_utility.set_message(800,'HR_74008_BOTH_NULL');
      hr_utility.raise_error;
      --
    end if;

    if nvl(p_basic_exemption_flag,'N') = 'Y'
       and p_tax_credit_amount is not null
     then
      hr_utility.set_message(800,'HR_74007_BOTH_NOT_NULL');
      hr_utility.raise_error;
      --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_basic_exemption_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_marriage_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   marriage_status Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_marriage_status(p_emp_province_tax_inf_id                in number,
                            p_marriage_status               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_marriage_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_marriage_status
      <> nvl(pay_cpt_shd.g_old_rec.marriage_status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_marriage_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_marriage_status,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_MARRIAGE_STATUS_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_marriage_status;
-- ----------------------------------------------------------------------------
-- |------< chk_disability_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   disability_status Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_disability_status(p_emp_province_tax_inf_id                in number,
                            p_disability_status               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_disability_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_disability_status
      <> nvl(pay_cpt_shd.g_old_rec.disability_status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_disability_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_disability_status,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_DISABILITY_STATUS_IS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_disability_status;
-- ----------------------------------------------------------------------------
-- |------< chk_non_resident_status >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   non_resident_status Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_non_resident_status(p_emp_province_tax_inf_id                in number,
                            p_non_resident_status               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_non_resident_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_non_resident_status
      <> nvl(pay_cpt_shd.g_old_rec.non_resident_status,hr_api.g_varchar2)
      or not l_api_updating)
      and p_non_resident_status is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_non_resident_status,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_NON_RESIDENT_STATUS_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_non_resident_status;
-- ----------------------------------------------------------------------------
-- |------< chk_tax_calc_method >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   tax_calc_method Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_tax_calc_method(p_emp_province_tax_inf_id                in number,
                            p_tax_calc_method               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tax_calc_method';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_tax_calc_method
      <> nvl(pay_cpt_shd.g_old_rec.tax_calc_method,hr_api.g_varchar2)
      or not l_api_updating)
      and p_tax_calc_method is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'QC_TAX_CALC_METHOD',
           p_lookup_code    => p_tax_calc_method,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_QC_TAX_CALC_METHOD');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_tax_calc_method;
-- ----------------------------------------------------------------------------
-- |------< chk_province_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   province_code Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_province_code(p_emp_province_tax_inf_id     in number,
                            p_province_code               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_province_code';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating ) then
      if p_province_code <>
           nvl(pay_cpt_shd.g_old_rec.province_code,hr_api.g_varchar2) then
        hr_utility.set_message(800, 'HR_74030_PROVINCE_CODE_CHANGED');
        hr_utility.raise_error;
    end if;
  end if;

  if (l_api_updating
      and p_province_code
      <> nvl(pay_cpt_shd.g_old_rec.province_code,hr_api.g_varchar2)
      or not l_api_updating)
      and p_province_code is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'CA_PROVINCE',
           p_lookup_code    => p_province_code,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(800,'HR_PROVINCE_CODE_WRONG');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_province_code;
-- ----------------------------------------------------------------------------
-- |------< chk_legislation_code >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   emp_province_tax_inf_id PK of record being inserted or updated.
--   non_resident_status Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_legislation_code(p_emp_province_tax_inf_id                in number,
                            p_legislation_code               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_legislation_code';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := pay_cpt_shd.api_updating
    (p_emp_province_tax_inf_id                => p_emp_province_tax_inf_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if l_api_updating
      and p_legislation_code
      <> nvl(pay_cpt_shd.g_old_rec.legislation_code,hr_api.g_varchar2)
      or not l_api_updating  then
  ---
      if p_legislation_code is null then
      -- raise error as legislation_code is NULL
      --
        hr_utility.set_message(800,'HR_74028_WRONG_LEGIS_CODE');
        hr_utility.raise_error;
      --
      end if;
    --
    -- check if value of lookup falls within lookup type.
    --
      if p_legislation_code <> 'CA' then
      -- raise error as legislation_code is not CA
      --
      hr_utility.set_message(800,'HR_74028_WRONG_LEGIS_CODE');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_legislation_code;
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (p_assignment_id                 in number default hr_api.g_number,
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    If ((nvl(p_assignment_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'per_all_assignments_f',
             p_base_key_column => 'assignment_id',
             p_base_key_value  => p_assignment_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'all assignments';
      Raise l_integrity_error;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(800, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_emp_province_tax_inf_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'emp_province_tax_inf_id',
       p_argument_value => p_emp_province_tax_inf_id);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    hr_utility.set_message(800, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in pay_cpt_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_emp_province_tax_inf_id
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_legislation_code          => p_rec.legislation_code,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_assignment_id
  (p_emp_province_tax_inf_id => p_rec.emp_province_tax_inf_id
  ,p_assignment_id         => p_rec.assignment_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_effective_date        => p_effective_date
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_province_code
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_province_code             => p_rec.province_code,
   p_effective_date            => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_wc_exempt_flag
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_wc_exempt_flag         => p_rec.wc_exempt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pmed_exempt_flag
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_pmed_exempt_flag         => p_rec.pmed_exempt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prov_exempt_flag
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_prov_exempt_flag         => p_rec.prov_exempt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_basic_exemption_flag
  (p_emp_province_tax_inf_id      => p_rec.emp_province_tax_inf_id,
   p_basic_exemption_flag         => p_rec.basic_exemption_flag,
   p_tax_credit_amount            => p_rec.tax_credit_amount,
   p_province_code                => p_rec.province_code,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_marriage_status
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_marriage_status         => p_rec.marriage_status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_non_resident_status
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_non_resident_status         => p_rec.non_resident_status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_disability_status
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_disability_status         => p_rec.disability_status,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tax_calc_method
  (p_emp_province_tax_inf_id          => p_rec.emp_province_tax_inf_id,
   p_tax_calc_method         => p_rec.tax_calc_method,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in pay_cpt_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_emp_province_tax_inf_id
  (p_emp_province_tax_inf_id     => p_rec.emp_province_tax_inf_id,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_legislation_code
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_legislation_code          => p_rec.legislation_code,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_assignment_id
  (p_emp_province_tax_inf_id => p_rec.emp_province_tax_inf_id
  ,p_assignment_id           => p_rec.assignment_id
  ,p_business_group_id       => p_rec.business_group_id
  ,p_effective_date          => p_effective_date
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_province_code
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_province_code             => p_rec.province_code,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_wc_exempt_flag
  (p_emp_province_tax_inf_id  => p_rec.emp_province_tax_inf_id,
   p_wc_exempt_flag           => p_rec.wc_exempt_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_pmed_exempt_flag
  (p_emp_province_tax_inf_id  => p_rec.emp_province_tax_inf_id,
   p_pmed_exempt_flag         => p_rec.pmed_exempt_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_prov_exempt_flag
  (p_emp_province_tax_inf_id  => p_rec.emp_province_tax_inf_id,
   p_prov_exempt_flag         => p_rec.prov_exempt_flag,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_basic_exemption_flag
  (p_emp_province_tax_inf_id     => p_rec.emp_province_tax_inf_id,
   p_basic_exemption_flag        => p_rec.basic_exemption_flag,
   p_tax_credit_amount           => p_rec.tax_credit_amount,
   p_province_code               => p_rec.province_code,
   p_effective_date              => p_effective_date,
   p_object_version_number       => p_rec.object_version_number);
  --
  chk_marriage_status
  (p_emp_province_tax_inf_id    => p_rec.emp_province_tax_inf_id,
   p_marriage_status            => p_rec.marriage_status,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_non_resident_status
  (p_emp_province_tax_inf_id    => p_rec.emp_province_tax_inf_id,
   p_non_resident_status        => p_rec.non_resident_status,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_disability_status
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_disability_status         => p_rec.disability_status,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_tax_calc_method
  (p_emp_province_tax_inf_id   => p_rec.emp_province_tax_inf_id,
   p_tax_calc_method           => p_rec.tax_calc_method,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_assignment_id                 => p_rec.assignment_id,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in pay_cpt_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is

-- commented csr_assigned cursor definition and redifined below, bug 6059473.
-- while checking whether any PAYROLL is execute, we have to consider
-- that we cannot terminate tax record if Final Process Date is
-- less than DATE EARNED.

/*  cursor csr_assigned is
  select PA.context_value from
  pay_action_contexts        PA,
  ff_contexts                C,
  pay_ca_emp_prov_tax_info_f PR
  where C.context_id     = PA.context_id
  and   C.context_name   = 'JURISDICTION_CODE'
  and   PA.context_value = PR.province_code
  and   PA.assignment_id = PR.assignment_id
  and   PR.emp_province_tax_inf_id = p_rec.emp_province_tax_inf_id; */


  cursor csr_assigned(p_csr_tmp_date in date) is
  select PA.context_value from
  pay_action_contexts        PA,
  ff_contexts                C,
  pay_ca_emp_prov_tax_info_f PR,
  pay_assignment_actions paa,
  per_assignments_f paf
  where C.context_id     = PA.context_id
  and   C.context_name   = 'JURISDICTION_CODE'
  and   PA.context_value = PR.province_code
  and   PA.assignment_id = PR.assignment_id
  and   PR.emp_province_tax_inf_id = p_rec.emp_province_tax_inf_id
  and   paf.assignment_id = PR.assignment_id
        and paf.assignment_id = paa.assignment_id
        and  exists (select null
                     from pay_payroll_actions ppa,
                          pay_payrolls_f ppf
                     where ppa.payroll_action_id = paa.payroll_action_id
                     and ppa.action_type in ('Q','R')
                     and ppa.date_earned > p_csr_tmp_date
                     and ppa.payroll_id = ppf.payroll_id
                     and ppa.effective_date between ppf.effective_start_date
                         and ppf.effective_end_date
                     and ppf.payroll_id > 0
                     and ppf.payroll_id = paf.payroll_id
                    );

  l_proc	varchar2(72) := g_package||'delete_validate';
  l_prov        varchar2(30);

  --l_effective_date variable added by sneelapa, bug 6059473
  l_effective_date          date;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  l_effective_date := trunc(p_effective_date);

  open csr_assigned(l_effective_date);
  fetch csr_assigned into l_prov;

  if csr_assigned%NOTFOUND then
    hr_utility.set_location(l_proc, 6);
       dt_delete_validate
         (p_datetrack_mode		=> p_datetrack_mode,
          p_validation_start_date	=> p_validation_start_date,
          p_validation_end_date  	=> p_validation_end_date,
          p_emp_province_tax_inf_id	=> p_rec.emp_province_tax_inf_id);
    hr_utility.set_location(l_proc, 7);
  else
  hr_utility.set_location(l_proc, 9);
       hr_utility.set_message(800,'HR_74039_CANNOT_PURGE_PROV');
       hr_utility.set_message_token('PROVINCECODE', l_prov);
       hr_utility.raise_error;
  end if;

  close csr_assigned;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_emp_province_tax_inf_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           pay_ca_emp_prov_tax_info_f b
    where b.emp_province_tax_inf_id      = p_emp_province_tax_inf_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'emp_province_tax_inf_id',
                             p_argument_value => p_emp_province_tax_inf_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(800,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end pay_cpt_bus;

/
