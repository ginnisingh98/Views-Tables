--------------------------------------------------------
--  DDL for Package Body BEN_CLP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLP_BUS" as
/* $Header: beclprhi.pkb 120.0.12010000.2 2008/08/05 14:17:49 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clp_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_clpse_lf_evt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_clpse_lf_evt_f b
    where b.clpse_lf_evt_id      = p_clpse_lf_evt_id
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
                             p_argument       => 'clpse_lf_evt_id',
                             p_argument_value => p_clpse_lf_evt_id);
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
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
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
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_clpse_lf_evt_id >------------------|
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
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   effective_date        Effective Date of session
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
Procedure chk_clpse_lf_evt_id(p_clpse_lf_evt_id       in number,
                              p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_clpse_lf_evt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_clpse_lf_evt_id,hr_api.g_number)
     <>  ben_clp_shd.g_old_rec.clpse_lf_evt_id) then
    --
    -- raise error as PK has changed
    --
    ben_clp_shd.constraint_error('BEN_CLPSE_LF_EVT_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_clpse_lf_evt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_clp_shd.constraint_error('BEN_CLPSE_LF_EVT_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_clpse_lf_evt_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_seq >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the sequence is unique.
--   within the business group for the effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   effective_date        Effective Date of session
--   seq                   Sequence Number
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
Procedure chk_seq(p_clpse_lf_evt_id       in number,
                  p_seq                   in number,
                  p_effective_date        in date,
                  p_business_group_id     in number,
                  p_object_version_number in number,
		  p_validation_start_date in date, -- 5951251 : Added these two Parameters
		  p_validation_end_date in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_seq';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_clpse_lf_evt_f clp
    where  clp.clpse_lf_evt_id <> nvl(p_clpse_lf_evt_id,-1)
    and    clp.business_group_id+0 = p_business_group_id
    and    clp.seq = p_seq
    and    ((p_effective_date between clp.effective_start_date
               and     clp.effective_end_date)
	   or
           -- 5951251: Added validation date Check
	   not ((p_validation_end_date<clp.effective_start_date)
	            or (p_validation_start_date>clp.effective_end_date)));

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_seq,hr_api.g_number)
     <>  ben_clp_shd.g_old_rec.seq)
     or not l_api_updating then
    --
    -- Check if sequence is unique within this business group.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        fnd_message.set_name('BEN','BEN_92124_CLP_SEQ_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_seq;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_ler1_id >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the sequence is unique.
--   within the business group for the effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   effective_date        Effective Date of session
--   ler1_id               Primary Life Event
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
Procedure chk_ler1_id(p_clpse_lf_evt_id       in number,
                      p_ler1_id               in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler1_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_ler1_id is null then
    --
    fnd_message.set_name('BEN','BEN_92125_PRMRY_LER_ID');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ler1_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_eval_ler_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the sequence is unique.
--   within the business group for the effective date.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   effective_date        Effective Date of session
--   eval_ler_id           Evaluated Life Event
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
Procedure chk_eval_ler_id(p_clpse_lf_evt_id       in number,
                          p_eval_ler_id           in number,
                          p_effective_date        in date,
                          p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eval_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_eval_ler_id is null then
    --
    fnd_message.set_name('BEN','BEN_92126_EVAL_LER_ID');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_eval_ler_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_tlrnc_dys_num >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the tolerance days number is greater
--   or equal to 0.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   effective_date        Effective Date of session
--   tlrnc_dys_num         Number of tolerance days
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
Procedure chk_tlrnc_dys_num(p_clpse_lf_evt_id       in number,
                            p_tlrnc_dys_num         in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_tlrnc_dys_num';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if nvl(p_tlrnc_dys_num,0) < 0 then
    --
    fnd_message.set_name('BEN','BEN_92127_TLRNC_DYS_NUM');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_tlrnc_dys_num;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_ler_bool_seq >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the boolean expression are compatible
--   with the sequence of life events. In other words the life event should
--   encapsulate the boolean expressions and viceversa.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id              PK of record being inserted or updated.
--   ler1_id                      Life Event Reason.
--   bool1_cd                     Value of lookup code.
--   ler2_id                      Life Event Reason.
--   bool2_cd                     Value of lookup code.
--   ler3_id                      Life Event Reason.
--   bool3_cd                     Value of lookup code.
--   ler4_id                      Life Event Reason.
--   bool4_cd                     Value of lookup code.
--   ler5_id                      Life Event Reason.
--   bool5_cd                     Value of lookup code.
--   ler6_id                      Life Event Reason.
--   bool6_cd                     Value of lookup code.
--   ler7_id                      Life Event Reason.
--   bool7_cd                     Value of lookup code.
--   ler8_id                      Life Event Reason.
--   bool8_cd                     Value of lookup code.
--   ler9_id                      Life Event Reason.
--   bool9_cd                     Value of lookup code.
--   ler10_id                     Life Event Reason.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_ler_bool_seq(p_clpse_lf_evt_id              in number,
                           p_ler1_id                      in number,
                           p_bool1_cd                     in varchar2,
                           p_ler2_id                      in number,
                           p_bool2_cd                     in varchar2,
                           p_ler3_id                      in number,
                           p_bool3_cd                     in varchar2,
                           p_ler4_id                      in number,
                           p_bool4_cd                     in varchar2,
                           p_ler5_id                      in number,
                           p_bool5_cd                     in varchar2,
                           p_ler6_id                      in number,
                           p_bool6_cd                     in varchar2,
                           p_ler7_id                      in number,
                           p_bool7_cd                     in varchar2,
                           p_ler8_id                      in number,
                           p_bool8_cd                     in varchar2,
                           p_ler9_id                      in number,
                           p_bool9_cd                     in varchar2,
                           p_ler10_id                     in number,
                           p_effective_date               in date,
                           p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_bool_seq';
  l_api_updating boolean;
  l_error        boolean := false;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ler1_id
      <> nvl(ben_clp_shd.g_old_rec.ler1_id,hr_api.g_number)
      or p_bool1_cd
      <> nvl(ben_clp_shd.g_old_rec.bool1_cd,hr_api.g_varchar2)
      or p_ler2_id
      <> nvl(ben_clp_shd.g_old_rec.ler2_id,hr_api.g_number)
      or p_bool2_cd
      <> nvl(ben_clp_shd.g_old_rec.bool2_cd,hr_api.g_varchar2)
      or p_ler3_id
      <> nvl(ben_clp_shd.g_old_rec.ler3_id,hr_api.g_number)
      or p_bool3_cd
      <> nvl(ben_clp_shd.g_old_rec.bool3_cd,hr_api.g_varchar2)
      or p_ler4_id
      <> nvl(ben_clp_shd.g_old_rec.ler4_id,hr_api.g_number)
      or p_bool4_cd
      <> nvl(ben_clp_shd.g_old_rec.bool4_cd,hr_api.g_varchar2)
      or p_ler5_id
      <> nvl(ben_clp_shd.g_old_rec.ler5_id,hr_api.g_number)
      or p_bool5_cd
      <> nvl(ben_clp_shd.g_old_rec.bool5_cd,hr_api.g_varchar2)
      or p_ler6_id
      <> nvl(ben_clp_shd.g_old_rec.ler6_id,hr_api.g_number)
      or p_bool6_cd
      <> nvl(ben_clp_shd.g_old_rec.bool6_cd,hr_api.g_varchar2)
      or p_ler7_id
      <> nvl(ben_clp_shd.g_old_rec.ler7_id,hr_api.g_number)
      or p_bool7_cd
      <> nvl(ben_clp_shd.g_old_rec.bool7_cd,hr_api.g_varchar2)
      or p_ler8_id
      <> nvl(ben_clp_shd.g_old_rec.ler8_id,hr_api.g_number)
      or p_bool8_cd
      <> nvl(ben_clp_shd.g_old_rec.bool8_cd,hr_api.g_varchar2)
      or p_ler9_id
      <> nvl(ben_clp_shd.g_old_rec.ler9_id,hr_api.g_number)
      or p_bool9_cd
      <> nvl(ben_clp_shd.g_old_rec.bool9_cd,hr_api.g_varchar2)
      or p_ler10_id
      <> nvl(ben_clp_shd.g_old_rec.ler10_id,hr_api.g_number))
      or not l_api_updating then
    --
    -- We need to check that any bool_cd that has a value is surrounded by
    -- its adjacent life event reasons
    --
    if p_bool1_cd is not null and
       (p_ler1_id is null or p_ler2_id is null) then
      --
      l_error := true;
      --
    elsif p_bool2_cd is not null and
       (p_ler2_id is null or p_ler3_id is null) then
      --
      l_error := true;
      --
    elsif p_bool3_cd is not null and
       (p_ler3_id is null or p_ler4_id is null) then
      --
      l_error := true;
      --
    elsif p_bool4_cd is not null and
       (p_ler4_id is null or p_ler5_id is null) then
      --
      l_error := true;
      --
    elsif p_bool5_cd is not null and
       (p_ler5_id is null or p_ler6_id is null) then
      --
      l_error := true;
      --
    elsif p_bool6_cd is not null and
       (p_ler6_id is null or p_ler7_id is null) then
      --
      l_error := true;
      --
    elsif p_bool7_cd is not null and
       (p_ler7_id is null or p_ler8_id is null) then
      --
      l_error := true;
      --
    elsif p_bool8_cd is not null and
       (p_ler8_id is null or p_ler9_id is null) then
      --
      l_error := true;
      --
    elsif p_bool9_cd is not null and
       (p_ler9_id is null or p_ler10_id is null) then
      --
      l_error := true;
      --
      -- Now lets check for the life event reasons not being encapsulated by
      -- the boolean codes
      --
    elsif p_ler2_id is not null and
       (p_bool1_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler3_id is not null and
       (p_bool2_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler4_id is not null and
       (p_bool3_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler5_id is not null and
       (p_bool4_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler6_id is not null and
       (p_bool5_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler7_id is not null and
       (p_bool6_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler8_id is not null and
       (p_bool7_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler9_id is not null and
       (p_bool8_cd is null) then
      --
      l_error := true;
      --
    elsif p_ler10_id is not null and
       (p_bool9_cd is null) then
      --
      l_error := true;
      --
    end if;
    --
    if l_error then
      --
      -- We have an encapsulation problem on either life events or boolean
      -- codes. This must be fixed as otherwise we can not parse the
      --
      fnd_message.set_name('BEN','BEN_92140_LER_BOOL_SEQ');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
end chk_ler_bool_seq;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_bool_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the bool lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id              PK of record being inserted or updated.
--   bool1_cd                     Value of lookup code.
--   bool2_cd                     Value of lookup code.
--   bool3_cd                     Value of lookup code.
--   bool4_cd                     Value of lookup code.
--   bool5_cd                     Value of lookup code.
--   bool6_cd                     Value of lookup code.
--   bool7_cd                     Value of lookup code.
--   bool8_cd                     Value of lookup code.
--   bool9_cd                     Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_bool_cd(p_clpse_lf_evt_id              in number,
                      p_bool1_cd                     in varchar2,
                      p_bool2_cd                     in varchar2,
                      p_bool3_cd                     in varchar2,
                      p_bool4_cd                     in varchar2,
                      p_bool5_cd                     in varchar2,
                      p_bool6_cd                     in varchar2,
                      p_bool7_cd                     in varchar2,
                      p_bool8_cd                     in varchar2,
                      p_bool9_cd                     in varchar2,
                      p_effective_date               in date,
                      p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bool_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bool1_cd
      <> nvl(ben_clp_shd.g_old_rec.bool1_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool1_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool1_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool1_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool2_cd
      <> nvl(ben_clp_shd.g_old_rec.bool2_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool2_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool2_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool2_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool3_cd
      <> nvl(ben_clp_shd.g_old_rec.bool3_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool3_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool3_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool3_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool4_cd
      <> nvl(ben_clp_shd.g_old_rec.bool4_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool4_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool4_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool4_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool5_cd
      <> nvl(ben_clp_shd.g_old_rec.bool5_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool5_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool5_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool5_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool6_cd
      <> nvl(ben_clp_shd.g_old_rec.bool6_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool6_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool6_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool6_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool7_cd
      <> nvl(ben_clp_shd.g_old_rec.bool7_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool7_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool7_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool7_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool8_cd
      <> nvl(ben_clp_shd.g_old_rec.bool8_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool8_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool8_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool8_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bool9_cd
      <> nvl(ben_clp_shd.g_old_rec.bool9_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bool9_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BOOL',
           p_lookup_code    => p_bool9_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_bool9_cd');
      fnd_message.set_token('TYPE','BEN_BOOL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_bool_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_eval_rl >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   eval_rl               Value of formula rule id.
--   business_group_id     Value of business group id.
--   effective_date        effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_eval_rl(p_clpse_lf_evt_id       in number,
                      p_eval_rl               in number,
                      p_business_group_id     in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eval_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_eval_rl,hr_api.g_number)
      <> ben_clp_shd.g_old_rec.eval_rl
      or not l_api_updating)
      and p_eval_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_eval_rl,
        p_formula_type_id   => -506,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_eval_rl);
      fnd_message.set_token('TYPE_ID',-506);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_eval_rl;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_eval_ler_det_rl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   eval_ler_det_rl       Value of formula rule id.
--   business_group_id     Value of business group id.
--   effective_date        effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_eval_ler_det_rl(p_clpse_lf_evt_id       in number,
                              p_eval_ler_det_rl       in number,
                              p_business_group_id     in number,
                              p_effective_date        in date,
                              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_eval_ler_det_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_eval_ler_det_rl,hr_api.g_number)
      <> ben_clp_shd.g_old_rec.eval_ler_det_rl
      or not l_api_updating)
      and p_eval_ler_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_eval_ler_det_rl,
        p_formula_type_id   => -505,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_eval_ler_det_rl);
      fnd_message.set_token('TYPE_ID',-505);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_eval_ler_det_rl;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_consecutive_bool_cd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the bool codes are consecutive. This
--   is needed for evaluation of life events.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bool1_cd                     Value of lookup code.
--   bool2_cd                     Value of lookup code.
--   bool3_cd                     Value of lookup code.
--   bool4_cd                     Value of lookup code.
--   bool5_cd                     Value of lookup code.
--   bool6_cd                     Value of lookup code.
--   bool7_cd                     Value of lookup code.
--   bool8_cd                     Value of lookup code.
--   bool9_cd                     Value of lookup code.
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
Procedure chk_consecutive_bool_cd(p_bool1_cd             in varchar2,
                                  p_bool2_cd             in varchar2,
                                  p_bool3_cd             in varchar2,
                                  p_bool4_cd             in varchar2,
                                  p_bool5_cd             in varchar2,
                                  p_bool6_cd             in varchar2,
                                  p_bool7_cd             in varchar2,
                                  p_bool8_cd             in varchar2,
                                  p_bool9_cd             in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_consecutive_bool_cd';
  l_found        boolean := false;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_bool1_cd is null and
    (p_bool2_cd is not null or
     p_bool3_cd is not null or
     p_bool4_cd is not null or
     p_bool5_cd is not null or
     p_bool6_cd is not null or
     p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool2_cd is null and
    (p_bool3_cd is not null or
     p_bool4_cd is not null or
     p_bool5_cd is not null or
     p_bool6_cd is not null or
     p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool3_cd is null and
    (p_bool4_cd is not null or
     p_bool5_cd is not null or
     p_bool6_cd is not null or
     p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool4_cd is null and
    (p_bool5_cd is not null or
     p_bool6_cd is not null or
     p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool5_cd is null and
    (p_bool6_cd is not null or
     p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool6_cd is null and
    (p_bool7_cd is not null or
     p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool7_cd is null and
    (p_bool8_cd is not null or
     p_bool9_cd is not null) then
    --
    l_found := true;
    --
  elsif p_bool8_cd is null and
    (p_bool9_cd is not null) then
    --
    l_found := true;
    --
  end if;
  --
  if l_found then
    --
    -- Raise error as user must use consecutive boolean codes as otherwise
    -- the parsing becomes more complex.
    --
    fnd_message.set_name('BEN','BEN_92128_CONSEC_BOOLEAN');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
end chk_consecutive_bool_cd;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_consecutive_ler_id >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the ler id codes are consecutive. This
--   is needed for evaluation of life events.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ler1_id                      ID of life event.
--   ler2_id                      ID of life event.
--   ler3_id                      ID of life event.
--   ler4_id                      ID of life event.
--   ler5_id                      ID of life event.
--   ler6_id                      ID of life event.
--   ler7_id                      ID of life event.
--   ler8_id                      ID of life event.
--   ler9_id                      ID of life event.
--   ler10_id                     ID of life event.
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
Procedure chk_consecutive_ler_id(p_ler1_id              in number,
                                 p_ler2_id              in number,
                                 p_ler3_id              in number,
                                 p_ler4_id              in number,
                                 p_ler5_id              in number,
                                 p_ler6_id              in number,
                                 p_ler7_id              in number,
                                 p_ler8_id              in number,
                                 p_ler9_id              in number,
                                 p_ler10_id             in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_consecutive_ler_id';
  l_found        boolean := false;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_ler1_id is null and
     (p_ler2_id is not null or
      p_ler3_id is not null or
      p_ler4_id is not null or
      p_ler5_id is not null or
      p_ler6_id is not null or
      p_ler7_id is not null or
      p_ler8_id is not null or
      p_ler9_id is not null or
      p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler2_id is null and
    (p_ler3_id is not null or
     p_ler4_id is not null or
     p_ler5_id is not null or
     p_ler6_id is not null or
     p_ler7_id is not null or
     p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler3_id is null and
    (p_ler4_id is not null or
     p_ler5_id is not null or
     p_ler6_id is not null or
     p_ler7_id is not null or
     p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler4_id is null and
    (p_ler5_id is not null or
     p_ler6_id is not null or
     p_ler7_id is not null or
     p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler5_id is null and
    (p_ler6_id is not null or
     p_ler7_id is not null or
     p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler6_id is null and
    (p_ler7_id is not null or
     p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler7_id is null and
    (p_ler8_id is not null or
     p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler8_id is null and
    (p_ler9_id is not null or
     p_ler10_id is not null) then
    --
    l_found := true;
    --
  elsif p_ler9_id is null and
    (p_ler10_id is not null) then
    --
    l_found := true;
    --
  end if;
  --
  if l_found then
    --
    -- Raise error as user must use consecutive boolean codes as otherwise
    -- the parsing becomes more complex.
    --
    fnd_message.set_name('BEN','BEN_92129_CONSEC_LER');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
end chk_consecutive_ler_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_eval_cd >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Evaluation code is in the lookup
--   for the code.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   eval_cd               Code for lookup
--   effective_date        effective date
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
Procedure chk_eval_cd(p_clpse_lf_evt_id             in number,
                      p_eval_cd                     in varchar2,
                      p_effective_date              in date,
                      p_object_version_number       in number) is
--
  l_proc         varchar2(72) := g_package||'chk_eval_cd';
  l_api_updating boolean;
  l_dummy        varchar2(1);
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_eval_cd
      <> nvl(ben_clp_shd.g_old_rec.eval_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EVAL',
           p_lookup_code    => p_eval_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_eval_cd');
      fnd_message.set_token('TYPE','BEN_EVAL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_eval_cd;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_eval_ler_det_cd >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Evaluation ler det code is in
--   the lookup for the code.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   clpse_lf_evt_id       PK of record being inserted or updated.
--   eval_ler_det_cd       Code for lookup
--   effective_date        effective date
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
Procedure chk_eval_ler_det_cd(p_clpse_lf_evt_id             in number,
                              p_eval_ler_det_cd             in varchar2,
                              p_effective_date              in date,
                              p_object_version_number       in number) is
--
  l_proc         varchar2(72) := g_package||'chk_eval_ler_det_cd';
  l_api_updating boolean;
  l_dummy        varchar2(1);
 --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_clp_shd.api_updating
    (p_clpse_lf_evt_id             => p_clpse_lf_evt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_eval_ler_det_cd
      <> nvl(ben_clp_shd.g_old_rec.eval_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EVAL_DET',
           p_lookup_code    => p_eval_ler_det_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_eval_ler_det_cd');
      fnd_message.set_token('TYPE','BEN_EVAL_DET');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_eval_ler_det_cd;
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
            (p_ler1_id                       in number default hr_api.g_number,
             p_ler2_id                       in number default hr_api.g_number,
             p_ler3_id                       in number default hr_api.g_number,
             p_ler4_id                       in number default hr_api.g_number,
             p_ler5_id                       in number default hr_api.g_number,
             p_ler6_id                       in number default hr_api.g_number,
             p_ler7_id                       in number default hr_api.g_number,
             p_ler8_id                       in number default hr_api.g_number,
             p_ler9_id                       in number default hr_api.g_number,
             p_ler10_id                      in number default hr_api.g_number,
             p_eval_ler_id                   in number default hr_api.g_number,
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
    If ((nvl(p_ler1_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler1_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler2_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler2_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler3_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler3_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler4_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler4_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler5_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler5_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler6_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler6_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler7_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler7_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler8_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler8_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler9_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler9_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_ler10_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_ler10_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_eval_ler_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_ler_f',
             p_base_key_column => 'ler_id',
             p_base_key_value  => p_eval_ler_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_ler_f';
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
            (p_clpse_lf_evt_id		in number,
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
       p_argument       => 'clpse_lf_evt_id',
       p_argument_value => p_clpse_lf_evt_id);
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
	(p_rec 			 in ben_clp_shd.g_rec_type,
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
  chk_clpse_lf_evt_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seq
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_seq                   => p_rec.seq,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date, -- 5951251: Added these two Parameters
   p_validation_end_date   => p_validation_end_date);

  --
  chk_ler1_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_ler1_id               => p_rec.ler1_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_id           => p_rec.eval_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tlrnc_dys_num
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_tlrnc_dys_num         => p_rec.tlrnc_dys_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bool_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_bool1_cd              => p_rec.bool1_cd,
   p_bool2_cd              => p_rec.bool2_cd,
   p_bool3_cd              => p_rec.bool3_cd,
   p_bool4_cd              => p_rec.bool4_cd,
   p_bool5_cd              => p_rec.bool5_cd,
   p_bool6_cd              => p_rec.bool6_cd,
   p_bool7_cd              => p_rec.bool7_cd,
   p_bool8_cd              => p_rec.bool8_cd,
   p_bool9_cd              => p_rec.bool9_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_rl
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_rl               => p_rec.eval_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_det_rl
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_det_rl       => p_rec.eval_ler_det_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_consecutive_bool_cd
  (p_bool1_cd              => p_rec.bool1_cd,
   p_bool2_cd              => p_rec.bool2_cd,
   p_bool3_cd              => p_rec.bool3_cd,
   p_bool4_cd              => p_rec.bool4_cd,
   p_bool5_cd              => p_rec.bool5_cd,
   p_bool6_cd              => p_rec.bool6_cd,
   p_bool7_cd              => p_rec.bool7_cd,
   p_bool8_cd              => p_rec.bool8_cd,
   p_bool9_cd              => p_rec.bool9_cd);
  --
  chk_consecutive_ler_id
  (p_ler1_id               => p_rec.ler1_id,
   p_ler2_id               => p_rec.ler2_id,
   p_ler3_id               => p_rec.ler3_id,
   p_ler4_id               => p_rec.ler4_id,
   p_ler5_id               => p_rec.ler5_id,
   p_ler6_id               => p_rec.ler6_id,
   p_ler7_id               => p_rec.ler7_id,
   p_ler8_id               => p_rec.ler8_id,
   p_ler9_id               => p_rec.ler9_id,
   p_ler10_id              => p_rec.ler10_id);
  --
  chk_eval_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_cd               => p_rec.eval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_det_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_det_cd       => p_rec.eval_ler_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_bool_seq
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_ler1_id               => p_rec.ler1_id,
   p_bool1_cd              => p_rec.bool1_cd,
   p_ler2_id               => p_rec.ler2_id,
   p_bool2_cd              => p_rec.bool2_cd,
   p_ler3_id               => p_rec.ler3_id,
   p_bool3_cd              => p_rec.bool3_cd,
   p_ler4_id               => p_rec.ler4_id,
   p_bool4_cd              => p_rec.bool4_cd,
   p_ler5_id               => p_rec.ler5_id,
   p_bool5_cd              => p_rec.bool5_cd,
   p_ler6_id               => p_rec.ler6_id,
   p_bool6_cd              => p_rec.bool6_cd,
   p_ler7_id               => p_rec.ler7_id,
   p_bool7_cd              => p_rec.bool7_cd,
   p_ler8_id               => p_rec.ler8_id,
   p_bool8_cd              => p_rec.bool8_cd,
   p_ler9_id               => p_rec.ler9_id,
   p_bool9_cd              => p_rec.bool9_cd,
   p_ler10_id              => p_rec.ler10_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_clp_shd.g_rec_type,
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
  chk_clpse_lf_evt_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seq
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_seq                   => p_rec.seq,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number,
   p_validation_start_date => p_validation_start_date, -- 5951251: Added these two Parameters
   p_validation_end_date   => p_validation_end_date);

  --
  chk_ler1_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_ler1_id               => p_rec.ler1_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_id
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_id           => p_rec.eval_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_tlrnc_dys_num
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_tlrnc_dys_num         => p_rec.tlrnc_dys_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bool_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_bool1_cd              => p_rec.bool1_cd,
   p_bool2_cd              => p_rec.bool2_cd,
   p_bool3_cd              => p_rec.bool3_cd,
   p_bool4_cd              => p_rec.bool4_cd,
   p_bool5_cd              => p_rec.bool5_cd,
   p_bool6_cd              => p_rec.bool6_cd,
   p_bool7_cd              => p_rec.bool7_cd,
   p_bool8_cd              => p_rec.bool8_cd,
   p_bool9_cd              => p_rec.bool9_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_rl
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_rl               => p_rec.eval_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_det_rl
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_det_rl       => p_rec.eval_ler_det_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_consecutive_bool_cd
  (p_bool1_cd              => p_rec.bool1_cd,
   p_bool2_cd              => p_rec.bool2_cd,
   p_bool3_cd              => p_rec.bool3_cd,
   p_bool4_cd              => p_rec.bool4_cd,
   p_bool5_cd              => p_rec.bool5_cd,
   p_bool6_cd              => p_rec.bool6_cd,
   p_bool7_cd              => p_rec.bool7_cd,
   p_bool8_cd              => p_rec.bool8_cd,
   p_bool9_cd              => p_rec.bool9_cd);
  --
  chk_consecutive_ler_id
  (p_ler1_id               => p_rec.ler1_id,
   p_ler2_id               => p_rec.ler2_id,
   p_ler3_id               => p_rec.ler3_id,
   p_ler4_id               => p_rec.ler4_id,
   p_ler5_id               => p_rec.ler5_id,
   p_ler6_id               => p_rec.ler6_id,
   p_ler7_id               => p_rec.ler7_id,
   p_ler8_id               => p_rec.ler8_id,
   p_ler9_id               => p_rec.ler9_id,
   p_ler10_id              => p_rec.ler10_id);
  --
  chk_eval_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_cd               => p_rec.eval_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_eval_ler_det_cd
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_eval_ler_det_cd       => p_rec.eval_ler_det_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ler_bool_seq
  (p_clpse_lf_evt_id       => p_rec.clpse_lf_evt_id,
   p_ler1_id               => p_rec.ler1_id,
   p_bool1_cd              => p_rec.bool1_cd,
   p_ler2_id               => p_rec.ler2_id,
   p_bool2_cd              => p_rec.bool2_cd,
   p_ler3_id               => p_rec.ler3_id,
   p_bool3_cd              => p_rec.bool3_cd,
   p_ler4_id               => p_rec.ler4_id,
   p_bool4_cd              => p_rec.bool4_cd,
   p_ler5_id               => p_rec.ler5_id,
   p_bool5_cd              => p_rec.bool5_cd,
   p_ler6_id               => p_rec.ler6_id,
   p_bool6_cd              => p_rec.bool6_cd,
   p_ler7_id               => p_rec.ler7_id,
   p_bool7_cd              => p_rec.bool7_cd,
   p_ler8_id               => p_rec.ler8_id,
   p_bool8_cd              => p_rec.bool8_cd,
   p_ler9_id               => p_rec.ler9_id,
   p_bool9_cd              => p_rec.bool9_cd,
   p_ler10_id              => p_rec.ler10_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_ler1_id                       => p_rec.ler1_id,
     p_ler2_id                       => p_rec.ler2_id,
     p_ler3_id                       => p_rec.ler3_id,
     p_ler4_id                       => p_rec.ler4_id,
     p_ler5_id                       => p_rec.ler5_id,
     p_ler6_id                       => p_rec.ler6_id,
     p_ler7_id                       => p_rec.ler7_id,
     p_ler8_id                       => p_rec.ler8_id,
     p_ler9_id                       => p_rec.ler9_id,
     p_ler10_id                      => p_rec.ler10_id,
     p_eval_ler_id                   => p_rec.eval_ler_id,
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
	(p_rec 			 in ben_clp_shd.g_rec_type,
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
     p_clpse_lf_evt_id		=> p_rec.clpse_lf_evt_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_clp_bus;

/
