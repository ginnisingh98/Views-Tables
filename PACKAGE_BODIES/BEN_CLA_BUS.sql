--------------------------------------------------------
--  DDL for Package Body BEN_CLA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLA_BUS" as
/* $Header: beclarhi.pkb 120.0 2005/05/28 01:03:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_cla_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cmbn_age_los_fctr_id >------|
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
--   cmbn_age_los_fctr_id PK of record being inserted or updated.
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
Procedure chk_cmbn_age_los_fctr_id(p_cmbn_age_los_fctr_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cmbn_age_los_fctr_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cla_shd.api_updating
    (p_cmbn_age_los_fctr_id                => p_cmbn_age_los_fctr_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cmbn_age_los_fctr_id,hr_api.g_number)
     <>  ben_cla_shd.g_old_rec.cmbn_age_los_fctr_id) then
    --
    -- raise error as PK has changed
    --
    ben_cla_shd.constraint_error('BEN_CMB_AGE_LGTH_OF_SVC_FCT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cmbn_age_los_fctr_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_cla_shd.constraint_error('BEN_CMB_AGE_LGTH_OF_SVC_FCT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cmbn_age_los_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_age_fctr_id >------|
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
--   p_cmbn_age_los_fctr_id PK
--   p_age_fctr_id ID of FK column
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
Procedure chk_age_fctr_id (p_cmbn_age_los_fctr_id          in number,
                            p_age_fctr_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_age_fctr_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_age_fctr a
    where  a.age_fctr_id = p_age_fctr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cla_shd.api_updating
     (p_cmbn_age_los_fctr_id            => p_cmbn_age_los_fctr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_age_fctr_id,hr_api.g_number)
     <> nvl(ben_cla_shd.g_old_rec.age_fctr_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if age_fctr_id value exists in ben_age_fctr table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_age_fctr
        -- table.
        --
        ben_cla_shd.constraint_error('BEN_CMB_AGE_LGH_OF_SVC_FCT_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_age_fctr_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_los_fctr_id >------|
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
--   p_cmbn_age_los_fctr_id PK
--   p_los_fctr_id ID of FK column
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
Procedure chk_los_fctr_id (p_cmbn_age_los_fctr_id          in number,
                            p_los_fctr_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_los_fctr_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_los_fctr a
    where  a.los_fctr_id = p_los_fctr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_cla_shd.api_updating
     (p_cmbn_age_los_fctr_id            => p_cmbn_age_los_fctr_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_los_fctr_id,hr_api.g_number)
     <> nvl(ben_cla_shd.g_old_rec.los_fctr_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if los_fctr_id value exists in ben_los_fctr table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_los_fctr
        -- table.
        --
        ben_cla_shd.constraint_error('BEN_CMB_AGE_LGH_OF_SVC_FCT_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_los_fctr_id;

------------------------------------------------------------------------
----
-- |------< chk_cmbn_mn_mx_val >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that minimum combined value is always
--     less than
--    max age number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_cmbn_age_los_fctr_id PK of record being inserted or updated.
--   cmbnd_min_val Value of combined Minimum.
--   cmbnd_max_val Value of combined Maximum.
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
Procedure chk_cmbn_mn_mx_val( p_cmbn_age_los_fctr_id   in number,
                         p_cmbnd_min_val                 in number,
                         p_cmbnd_max_val                 in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_cmbn_mn_mx_val';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- cmbnd_min_val must be < cmbnd_max_val,
  -- if both are used.
  --
    if p_cmbnd_min_val is not null and p_cmbnd_max_val is not null then
      --
      -- raise error if max value not greater than min value
      --
     -- Bug fix 1873685
     if  (p_cmbnd_max_val < p_cmbnd_min_val)  then
     -- if  (p_cmbnd_max_val <= p_cmbnd_min_val)  then
     -- End fix 1873685
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cmbn_mn_mx_val;
--
------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that the Name is unique in a business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbn_age_los_fctr_id PK of record being inserted or updated.
--   name Value of Name.
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
Procedure chk_name(p_cmbn_age_los_fctr_id          in number,
                         p_business_group_id       in number,
                         p_name                    in varchar2,
                         -- p_effective_date          in date,
                         p_object_version_number   in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_name';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cmbn_age_los_fctr  cla
    where  cla.business_group_id = p_business_group_id and
           cla.name = p_name;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_cla_shd.api_updating
    (p_cmbn_age_los_fctr_id       => p_cmbn_age_los_fctr_id,
     -- p_effective_date          => p_effective_date,
     p_object_version_number      => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_name,hr_api.g_varchar2)
      <> ben_cla_shd.g_old_rec.name
      or not l_api_updating)
      and p_name is not null then
    --
    -- check if name already used.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the

      -- name is invalid otherwise its valid
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
--

--Bug 2978945 begin

-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that Combined age and LOS child records do not
--   exist when the user deletes the record in the
--   BEN_CMBN_AGE_LOS_FCTR table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cmbn_age_los_fctr_id        PK of record being inserted or updated.
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
procedure chk_child_records(p_cmbn_age_los_fctr_id  in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';


begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

 --Used in variable rate profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_CMBN_AGE_LOS_RT_F',
              p_base_key_column => 'cmbn_age_los_fctr_id',
              p_base_key_value  => p_cmbn_age_los_fctr_id
             )) Then
	  	ben_utility.child_exists_error('BEN_CMBN_AGE_LOS_RT_F');
   End If;

  --Used in eligibility profiles
   If (ben_batch_utils.rows_exist
             (p_base_table_name => 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F',
              p_base_key_column => 'cmbn_age_los_fctr_id',
              p_base_key_value  => p_cmbn_age_los_fctr_id
             )) Then
	  	ben_utility.child_exists_error('BEN_ELIG_CMBN_AGE_LOS_PRTE_F');
  End If;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --

end chk_child_records;

--Bug 2978945

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_cla_shd.g_rec_type) is
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
  chk_cmbn_age_los_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_age_fctr_id          => p_rec.age_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_los_fctr_id          => p_rec.los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cmbn_mn_mx_val
  ( p_cmbn_age_los_fctr_id     => p_rec.cmbn_age_los_fctr_id,
    p_cmbnd_min_val            =>p_rec.cmbnd_min_val,
    p_cmbnd_max_val            =>p_rec.cmbnd_max_val,
    p_object_version_number    => p_rec.object_version_number);
  --
  chk_name
  (p_cmbn_age_los_fctr_id      => p_rec.cmbn_age_los_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name                      => p_rec.name,
   -- p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_cla_shd.g_rec_type) is
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
  chk_cmbn_age_los_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_age_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_age_fctr_id          => p_rec.age_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_los_fctr_id
  (p_cmbn_age_los_fctr_id          => p_rec.cmbn_age_los_fctr_id,
   p_los_fctr_id          => p_rec.los_fctr_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_cmbn_mn_mx_val
  ( p_cmbn_age_los_fctr_id   => p_rec.cmbn_age_los_fctr_id,
    p_cmbnd_min_val       =>p_rec.cmbnd_min_val,
    p_cmbnd_max_val       =>p_rec.cmbnd_max_val,
    p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_name
  (p_cmbn_age_los_fctr_id      => p_rec.cmbn_age_los_fctr_id,
   p_business_group_id         => p_rec.business_group_id,
   p_name                      => p_rec.name,
   -- p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_cla_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_child_records(p_cmbn_age_los_fctr_id => p_rec.cmbn_age_los_fctr_id); --Bug 2978945
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_cmbn_age_los_fctr_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cmbn_age_los_fctr b
    where b.cmbn_age_los_fctr_id      = p_cmbn_age_los_fctr_id
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
                             p_argument       => 'cmbn_age_los_fctr_id',
                             p_argument_value => p_cmbn_age_los_fctr_id);
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
end ben_cla_bus;

/
