--------------------------------------------------------
--  DDL for Package Body BEN_PRD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRD_BUS" as
/* $Header: beprdrhi.pkb 120.0.12010000.2 2008/08/05 15:20:11 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prd_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_paird_rt_id >------|
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
--   paird_rt_id PK of record being inserted or updated.
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
Procedure chk_paird_rt_id(p_paird_rt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_paird_rt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_paird_rt_id                => p_paird_rt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_paird_rt_id,hr_api.g_number)
     <>  ben_prd_shd.g_old_rec.paird_rt_id) then
    --
    -- raise error as PK has changed
    --
    ben_prd_shd.constraint_error('BEN_PAIRD_RT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_paird_rt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_prd_shd.constraint_error('BEN_PAIRD_RT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_paird_rt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_cmbnd_mn_amt_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   no_cmbnd_mn_amt_dfnd_flag Value of lookup code.
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
Procedure chk_no_cmbnd_mn_amt_dfnd_flag(p_paird_rt_id                in number,
                            p_no_cmbnd_mn_amt_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_cmbnd_mn_amt_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_cmbnd_mn_amt_dfnd_flag
      <> nvl(ben_prd_shd.g_old_rec.no_cmbnd_mn_amt_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_cmbnd_mn_amt_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_cmbnd_mn_amt_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_cmbnd_mx_amt_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   no_cmbnd_mx_amt_dfnd_flag Value of lookup code.
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
Procedure chk_no_cmbnd_mx_amt_dfnd_flag(p_paird_rt_id                in number,
                            p_no_cmbnd_mx_amt_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_cmbnd_mx_amt_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_cmbnd_mx_amt_dfnd_flag
      <> nvl(ben_prd_shd.g_old_rec.no_cmbnd_mx_amt_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_cmbnd_mx_amt_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_cmbnd_mx_amt_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_parnt_pymt_sched_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   use_parnt_pymt_sched_flag Value of lookup code.
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
Procedure chk_use_parnt_pymt_sched_flag(p_paird_rt_id                in number,
                            p_use_parnt_pymt_sched_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_parnt_pymt_sched_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_parnt_pymt_sched_flag
      <> nvl(ben_prd_shd.g_old_rec.use_parnt_pymt_sched_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_parnt_pymt_sched_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_parnt_pymt_sched_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_alloc_sme_as_parnt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   alloc_sme_as_parnt_flag Value of lookup code.
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
Procedure chk_alloc_sme_as_parnt_flag(p_paird_rt_id                in number,
                            p_alloc_sme_as_parnt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_alloc_sme_as_parnt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_alloc_sme_as_parnt_flag
      <> nvl(ben_prd_shd.g_old_rec.alloc_sme_as_parnt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alloc_sme_as_parnt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_alloc_sme_as_parnt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_parnt_prtl_mo_cd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   use_parnt_prtl_mo_cd_flag Value of lookup code.
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
Procedure chk_use_parnt_prtl_mo_cd_flag(p_paird_rt_id                in number,
                            p_use_parnt_prtl_mo_cd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_parnt_prtl_mo_cd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_parnt_prtl_mo_cd_flag
      <> nvl(ben_prd_shd.g_old_rec.use_parnt_prtl_mo_cd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_parnt_prtl_mo_cd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_parnt_prtl_mo_cd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_asn_on_chc_of_parnt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   asn_on_chc_of_parnt_flag Value of lookup code.
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
Procedure chk_asn_on_chc_of_parnt_flag(p_paird_rt_id                in number,
                            p_asn_on_chc_of_parnt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_asn_on_chc_of_parnt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_asn_on_chc_of_parnt_flag
      <> nvl(ben_prd_shd.g_old_rec.asn_on_chc_of_parnt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_asn_on_chc_of_parnt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_asn_on_chc_of_parnt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_use_parnt_ded_sched_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   use_parnt_ded_sched_flag Value of lookup code.
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
Procedure chk_use_parnt_ded_sched_flag(p_paird_rt_id                in number,
                            p_use_parnt_ded_sched_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_parnt_ded_sched_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_parnt_ded_sched_flag
      <> nvl(ben_prd_shd.g_old_rec.use_parnt_ded_sched_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_parnt_ded_sched_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_parnt_ded_sched_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_cmbnd_mx_pct_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   no_cmbnd_mx_pct_dfnd_flag Value of lookup code.
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
Procedure chk_no_cmbnd_mx_pct_dfnd_flag(p_paird_rt_id                in number,
                            p_no_cmbnd_mx_pct_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_cmbnd_mx_pct_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_cmbnd_mx_pct_dfnd_flag
      <> nvl(ben_prd_shd.g_old_rec.no_cmbnd_mx_pct_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_cmbnd_mx_pct_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_cmbnd_mx_pct_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_cmbnd_mn_pct_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   paird_rt_id PK of record being inserted or updated.
--   no_cmbnd_mn_pct_dfnd_flag Value of lookup code.
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
Procedure chk_no_cmbnd_mn_pct_dfnd_flag(p_paird_rt_id                in number,
                            p_no_cmbnd_mn_pct_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_cmbnd_mn_pct_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prd_shd.api_updating
    (p_paird_rt_id                => p_paird_rt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_cmbnd_mn_pct_dfnd_flag
      <> nvl(ben_prd_shd.g_old_rec.no_cmbnd_mn_pct_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_cmbnd_mn_pct_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_cmbnd_mn_pct_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_cmbnd_mx_amt_and_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the maximum amount is not
--   null or the no maximum amount defined flag is checked.  If the maximum
--   amount has a value, the flag cannot be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbnd_mx_amt                Maximum amount
--   no_cmbnd_mx_amt_dfnd_flag   No Maximum amount defined flag
--
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
Procedure chk_cmbnd_mx_amt_and_flag
                   (p_cmbnd_mx_amt                 in number,
                    p_no_cmbnd_mx_amt_dfnd_flag    in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_cmbnd_mx_amt_and_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_cmbnd_mx_amt is not null and p_no_cmbnd_mx_amt_dfnd_flag = 'Y') then
        --
        -- raise error if maximum amount is not null and the No Maximum Amount
        -- Defined flag is checked
        --
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
        --
    end if;
        --
    If (p_no_cmbnd_mx_amt_dfnd_flag = 'N' and p_cmbnd_mx_amt is null)  then
        --
        -- raise error if maximum amount is null and the No Maximum Amount
        -- Defined flag is not checked
        --
       fnd_message.set_name('BEN','BEN_91715_MUT_EXLSV_MX_VAL_FLG');
       fnd_message.raise_error;
        --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cmbnd_mx_amt_and_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_cmbnd_mn_amt_and_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the minimum amount is not
--   null or the no minimum amount defined flag is checked.  If the minimum
--   amount has a value, the flag cannot be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbnd_mn_amt                Minimum amount
--   no_cmbnd_mn_amt_dfnd_flag   No minimum amount defined flag
--
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
Procedure chk_cmbnd_mn_amt_and_flag
                   (p_cmbnd_mn_amt                 in number,
                    p_no_cmbnd_mn_amt_dfnd_flag    in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_cmbnd_mn_amt_and_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_cmbnd_mn_amt is not null and p_no_cmbnd_mn_amt_dfnd_flag = 'Y') then
        --
        -- raise error if minimum amount is not null and the No Minimum Amount
        -- Defined flag is checked
        --
       fnd_message.set_name('BEN','BEN_91729_MUT_EXLSV_MN_AMT_FLG');
       fnd_message.raise_error;
        --
    end if;
        --
    If (p_no_cmbnd_mn_amt_dfnd_flag = 'N' and p_cmbnd_mn_amt is null)  then
        --
        -- raise error if minimum amount is null and the No Minimum Amount
        -- Defined flag is not checked
        --
       fnd_message.set_name('BEN','BEN_91729_MUT_EXLSV_MN_AMT_FLG');
       fnd_message.raise_error;
        --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cmbnd_mn_amt_and_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_cmbnd_mx_pct_and_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the maximum percent is not
--   null or the no maximum percent defined flag is checked.  If the maximum
--   percent has a value, the flag cannot be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbnd_mx_pct_num            Maximum percent
--   no_cmbnd_mx_pct_dfnd_flag   No maximum percent defined flag
--
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
Procedure chk_cmbnd_mx_pct_and_flag
                   (p_cmbnd_mx_pct_num             in number,
                    p_no_cmbnd_mx_pct_dfnd_flag    in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_cmbnd_mx_pct_and_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_cmbnd_mx_pct_num is not null and p_no_cmbnd_mx_pct_dfnd_flag = 'Y')
        then
        --
        -- raise error if maximum percent is not null and the No Maximum Percent
        -- Defined flag is checked
        --
       fnd_message.set_name('BEN','BEN_91717_MUT_EXLSU_MX_PCT_FLG');
       fnd_message.raise_error;
        --
    end if;
        --
    If (p_no_cmbnd_mx_pct_dfnd_flag = 'N' and p_cmbnd_mx_pct_num is null)  then
        --
        -- raise error if maximum percent is null and the No Maximum Percent
        -- Defined flag is not checked
        --
       fnd_message.set_name('BEN','BEN_91717_MUT_EXLSU_MX_PCT_FLG');
       fnd_message.raise_error;
        --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cmbnd_mx_pct_and_flag;
--
-- ----------------------------------------------------------------------------
-- |--------------< chk_cmbnd_mn_pct_and_flag >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the minimum percent is not
--   null or the no minimum percent defined flag is checked.  If the minimum
--   percent has a value, the flag cannot be checked.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbnd_mn_pct_num            Minimum percent
--   no_cmbnd_mn_pct_dfnd_flag   No minimum percent defined flag
--
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
Procedure chk_cmbnd_mn_pct_and_flag
                   (p_cmbnd_mn_pct_num             in number,
                    p_no_cmbnd_mn_pct_dfnd_flag    in varchar2) is
  --
  l_proc      varchar2(72) := g_package||'chk_cmbnd_mn_pct_and_flag';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    If (p_cmbnd_mn_pct_num is not null and p_no_cmbnd_mn_pct_dfnd_flag = 'Y')
        then
        --
        -- raise error if minimum percent is not null and the No Minimum Percent
        -- Defined flag is checked
        --
       fnd_message.set_name('BEN','BEN_91728_MUT_EXLSU_MN_PCT_FLG');
       fnd_message.raise_error;
        --
    end if;
        --
    If (p_no_cmbnd_mn_pct_dfnd_flag = 'N' and p_cmbnd_mn_pct_num is null)  then
        --
        -- raise error if minimum percent is null and the No Minimum Percent
        -- Defined flag is not checked
        --
       fnd_message.set_name('BEN','BEN_91728_MUT_EXLSU_MN_PCT_FLG');
       fnd_message.raise_error;
        --
    end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cmbnd_mn_pct_and_flag;
--
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
            (p_parnt_acty_base_rt_id         in number default hr_api.g_number,
             p_chld_acty_base_rt_id          in number default hr_api.g_number,
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
    If ((nvl(p_parnt_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_parnt_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_chld_acty_base_rt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_acty_base_rt_f',
             p_base_key_column => 'acty_base_rt_id',
             p_base_key_value  => p_chld_acty_base_rt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_acty_base_rt_f';
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
    hr_utility.set_message(801, 'HR_7216_DT_UPD_INTEGRITY_ERR');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
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
            (p_paird_rt_id		in number,
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
       p_argument       => 'paird_rt_id',
       p_argument_value => p_paird_rt_id);
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
    hr_utility.set_message(801, 'HR_7215_DT_CHILD_EXISTS');
    hr_utility.set_message_token('TABLE_NAME', l_table_name);
    hr_utility.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_prd_shd.g_rec_type,
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
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_paird_rt_id
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mn_amt_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mn_amt_dfnd_flag         => p_rec.no_cmbnd_mn_amt_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mx_amt_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mx_amt_dfnd_flag         => p_rec.no_cmbnd_mx_amt_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_pymt_sched_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_pymt_sched_flag         => p_rec.use_parnt_pymt_sched_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_alloc_sme_as_parnt_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_alloc_sme_as_parnt_flag         => p_rec.alloc_sme_as_parnt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_prtl_mo_cd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_prtl_mo_cd_flag         => p_rec.use_parnt_prtl_mo_cd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asn_on_chc_of_parnt_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_asn_on_chc_of_parnt_flag         => p_rec.asn_on_chc_of_parnt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_ded_sched_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_ded_sched_flag         => p_rec.use_parnt_ded_sched_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mx_pct_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mx_pct_dfnd_flag         => p_rec.no_cmbnd_mx_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mn_pct_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mn_pct_dfnd_flag         => p_rec.no_cmbnd_mn_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cmbnd_mx_amt_and_flag
  (p_cmbnd_mx_amt               => p_rec.cmbnd_mx_amt,
   p_no_cmbnd_mx_amt_dfnd_flag  => p_rec.no_cmbnd_mx_amt_dfnd_flag);
  --
  chk_cmbnd_mn_amt_and_flag
  (p_cmbnd_mn_amt               => p_rec.cmbnd_mn_amt,
   p_no_cmbnd_mn_amt_dfnd_flag  => p_rec.no_cmbnd_mn_amt_dfnd_flag);
  --
  chk_cmbnd_mx_pct_and_flag
  (p_cmbnd_mx_pct_num           => p_rec.cmbnd_mx_pct_num,
   p_no_cmbnd_mx_pct_dfnd_flag  => p_rec.no_cmbnd_mx_pct_dfnd_flag);
  --
  chk_cmbnd_mn_pct_and_flag
  (p_cmbnd_mn_pct_num           => p_rec.cmbnd_mn_pct_num,
   p_no_cmbnd_mn_pct_dfnd_flag  => p_rec.no_cmbnd_mn_pct_dfnd_flag);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_prd_shd.g_rec_type,
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
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_paird_rt_id
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mn_amt_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mn_amt_dfnd_flag         => p_rec.no_cmbnd_mn_amt_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mx_amt_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mx_amt_dfnd_flag         => p_rec.no_cmbnd_mx_amt_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_pymt_sched_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_pymt_sched_flag         => p_rec.use_parnt_pymt_sched_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_alloc_sme_as_parnt_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_alloc_sme_as_parnt_flag         => p_rec.alloc_sme_as_parnt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_prtl_mo_cd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_prtl_mo_cd_flag         => p_rec.use_parnt_prtl_mo_cd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_asn_on_chc_of_parnt_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_asn_on_chc_of_parnt_flag         => p_rec.asn_on_chc_of_parnt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_use_parnt_ded_sched_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_use_parnt_ded_sched_flag         => p_rec.use_parnt_ded_sched_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mx_pct_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mx_pct_dfnd_flag         => p_rec.no_cmbnd_mx_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_cmbnd_mn_pct_dfnd_flag
  (p_paird_rt_id          => p_rec.paird_rt_id,
   p_no_cmbnd_mn_pct_dfnd_flag         => p_rec.no_cmbnd_mn_pct_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cmbnd_mx_amt_and_flag
  (p_cmbnd_mx_amt               => p_rec.cmbnd_mx_amt,
   p_no_cmbnd_mx_amt_dfnd_flag  => p_rec.no_cmbnd_mx_amt_dfnd_flag);
  --
  chk_cmbnd_mn_amt_and_flag
  (p_cmbnd_mn_amt               => p_rec.cmbnd_mn_amt,
   p_no_cmbnd_mn_amt_dfnd_flag  => p_rec.no_cmbnd_mn_amt_dfnd_flag);
  --
  chk_cmbnd_mx_pct_and_flag
  (p_cmbnd_mx_pct_num           => p_rec.cmbnd_mx_pct_num,
   p_no_cmbnd_mx_pct_dfnd_flag  => p_rec.no_cmbnd_mx_pct_dfnd_flag);
  --
  chk_cmbnd_mn_pct_and_flag
  (p_cmbnd_mn_pct_num           => p_rec.cmbnd_mn_pct_num,
   p_no_cmbnd_mn_pct_dfnd_flag  => p_rec.no_cmbnd_mn_pct_dfnd_flag);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_parnt_acty_base_rt_id         => p_rec.parnt_acty_base_rt_id,
     p_chld_acty_base_rt_id          => p_rec.chld_acty_base_rt_id,
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
	(p_rec 			 in ben_prd_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_paird_rt_id		=> p_rec.paird_rt_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_paird_rt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_paird_rt_f b
    where b.paird_rt_id      = p_paird_rt_id
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
                             p_argument       => 'paird_rt_id',
                             p_argument_value => p_paird_rt_id);
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
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
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
end ben_prd_bus;

/
