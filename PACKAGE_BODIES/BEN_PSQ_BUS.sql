--------------------------------------------------------
--  DDL for Package Body BEN_PSQ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PSQ_BUS" as
/* $Header: bepsqrhi.pkb 120.0 2005/05/28 11:20:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_psq_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pymt_sched_py_freq_id >------|
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
--   pymt_sched_py_freq_id PK of record being inserted or updated.
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
Procedure chk_pymt_sched_py_freq_id(p_pymt_sched_py_freq_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_sched_py_freq_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_psq_shd.api_updating
    (p_pymt_sched_py_freq_id                => p_pymt_sched_py_freq_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pymt_sched_py_freq_id,hr_api.g_number)
     <>  ben_psq_shd.g_old_rec.pymt_sched_py_freq_id) then
    --
    -- raise error as PK has changed
    --
    ben_psq_shd.constraint_error('BEN_PYMT_SCHED_PY_FREQ_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pymt_sched_py_freq_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_psq_shd.constraint_error('BEN_PYMT_SCHED_PY_FREQ_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pymt_sched_py_freq_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_acty_rt_pymt_sched_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pymt_sched_py_freq_id PK
--   p_acty_rt_pymt_sched_id ID of FK column
--   p_effective_date Session Date of record
--   p_object_version_number object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_acty_rt_pymt_sched_id (p_pymt_sched_py_freq_id          in number,
                            p_acty_rt_pymt_sched_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_acty_rt_pymt_sched_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_acty_rt_pymt_sched_f a
    where  a.acty_rt_pymt_sched_id = p_acty_rt_pymt_sched_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_psq_shd.api_updating
     (p_pymt_sched_py_freq_id            => p_pymt_sched_py_freq_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_acty_rt_pymt_sched_id,hr_api.g_number)
     <> nvl(ben_psq_shd.g_old_rec.acty_rt_pymt_sched_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if acty_rt_pymt_sched_id value exists in ben_acty_rt_pymt_sched_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_acty_rt_pymt_sched_f
        -- table.
        --
        ben_psq_shd.constraint_error('BEN_PYMT_SCHED_PY_FREQ_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_acty_rt_pymt_sched_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dflt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pymt_sched_py_freq_id PK of record being inserted or updated.
--   dflt_flag Value of lookup code.
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
Procedure chk_dflt_flag(p_pymt_sched_py_freq_id                in number,
                            p_dflt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_psq_shd.api_updating
    (p_pymt_sched_py_freq_id                => p_pymt_sched_py_freq_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dflt_flag
      <> nvl(ben_psq_shd.g_old_rec.dflt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dflt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91006_INVALID_FLAG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dflt_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_py_freq_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pymt_sched_py_freq_id PK of record being inserted or updated.
--   py_freq_cd Value of lookup code.
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
Procedure chk_py_freq_cd(p_pymt_sched_py_freq_id                in number,
                            p_py_freq_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_py_freq_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_psq_shd.api_updating
    (p_pymt_sched_py_freq_id                => p_pymt_sched_py_freq_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_py_freq_cd
      <> nvl(ben_psq_shd.g_old_rec.py_freq_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FREQ',
           p_lookup_code    => p_py_freq_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91199_INVLD_PY_FREQ_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_py_freq_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_psq_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pymt_sched_py_freq_id
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_py_freq_cd
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_py_freq_cd         => p_rec.py_freq_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_psq_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_pymt_sched_py_freq_id
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dflt_flag
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_dflt_flag         => p_rec.dflt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_py_freq_cd
  (p_pymt_sched_py_freq_id          => p_rec.pymt_sched_py_freq_id,
   p_py_freq_cd         => p_rec.py_freq_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_psq_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
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
  (p_pymt_sched_py_freq_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pymt_sched_py_freq b
    where b.pymt_sched_py_freq_id      = p_pymt_sched_py_freq_id
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
                             p_argument       => 'pymt_sched_py_freq_id',
                             p_argument_value => p_pymt_sched_py_freq_id);
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
end ben_psq_bus;

/
