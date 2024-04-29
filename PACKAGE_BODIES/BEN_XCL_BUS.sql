--------------------------------------------------------
--  DDL for Package Body BEN_XCL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCL_BUS" as
/* $Header: bexclrhi.pkb 115.7 2002/12/24 21:28:21 rpillay ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcl_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_chg_evt_log_id >------|
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
--   ext_chg_evt_log_id PK of record being inserted or updated.
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
Procedure chk_ext_chg_evt_log_id(p_ext_chg_evt_log_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_chg_evt_log_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcl_shd.api_updating
    (p_ext_chg_evt_log_id                => p_ext_chg_evt_log_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_chg_evt_log_id,hr_api.g_number)
     <>  ben_xcl_shd.g_old_rec.ext_chg_evt_log_id) then
    --
    -- raise error as PK has changed
    --
    ben_xcl_shd.constraint_error('BEN_EXT_CHG_EVT_LOG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_chg_evt_log_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xcl_shd.constraint_error('BEN_EXT_CHG_EVT_LOG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_chg_evt_log_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_person_id >------|
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
--   p_ext_chg_evt_log_id PK
--   p_person_id ID of FK column
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
Procedure chk_person_id (p_ext_chg_evt_log_id          in number,
                            p_person_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_person_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcl_shd.api_updating
     (p_ext_chg_evt_log_id            => p_ext_chg_evt_log_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_xcl_shd.g_old_rec.person_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people_f
        -- table.
        --
        ben_xcl_shd.constraint_error('BEN_EXT_CHG_EVT_LOG_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_chg_evt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_chg_evt_log_id PK of record being inserted or updated.
--   chg_evt_cd Value of lookup code.
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
Procedure chk_chg_evt_cd(p_ext_chg_evt_log_id                in number,
                            p_chg_evt_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_chg_evt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcl_shd.api_updating
    (p_ext_chg_evt_log_id                => p_ext_chg_evt_log_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_chg_evt_cd
      <> nvl(ben_xcl_shd.g_old_rec.chg_evt_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_CHG_EVT',
           p_lookup_code    => p_chg_evt_cd,
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
end chk_chg_evt_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xcl_shd.g_rec_type
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
  chk_ext_chg_evt_log_id
  (p_ext_chg_evt_log_id          => p_rec.ext_chg_evt_log_id,
   p_object_version_number => p_rec.object_version_number);
  --
 /* chk_chg_evt_cd
  (p_ext_chg_evt_log_id          => p_rec.ext_chg_evt_log_id,
   p_chg_evt_cd         => p_rec.chg_evt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number); */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xcl_shd.g_rec_type
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
  chk_ext_chg_evt_log_id
  (p_ext_chg_evt_log_id          => p_rec.ext_chg_evt_log_id,
   p_object_version_number => p_rec.object_version_number);
  --
  /*chk_chg_evt_cd
  (p_ext_chg_evt_log_id          => p_rec.ext_chg_evt_log_id,
   p_chg_evt_cd         => p_rec.chg_evt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xcl_shd.g_rec_type
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
  (p_ext_chg_evt_log_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_chg_evt_log b
    where b.ext_chg_evt_log_id      = p_ext_chg_evt_log_id
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
                             p_argument       => 'ext_chg_evt_log_id',
                             p_argument_value => p_ext_chg_evt_log_id);
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
end ben_xcl_bus;

/
