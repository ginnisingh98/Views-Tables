--------------------------------------------------------
--  DDL for Package Body BEN_BNG_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BNG_BUS" as
/* $Header: bebngrhi.pkb 120.0.12010000.2 2008/08/05 14:08:45 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bng_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_benfts_grp_id >------|
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
--   benfts_grp_id PK of record being inserted or updated.
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
Procedure chk_benfts_grp_id(p_benfts_grp_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_benfts_grp_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_bng_shd.api_updating
    (p_benfts_grp_id                => p_benfts_grp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_benfts_grp_id,hr_api.g_number)
     <>  ben_bng_shd.g_old_rec.benfts_grp_id) then
    --
    -- raise error as PK has changed
    --
    ben_bng_shd.constraint_error('BEN_BENFTS_GRP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_benfts_grp_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_bng_shd.constraint_error('BEN_BENFTS_GRP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_benfts_grp_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Benefits Group Name is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is Benefits Group name
--     p_benfts_grp_id is benfts_grp_id
--     p_business_group_id
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
---- ----------------------------------------------------------------------------
Procedure chk_name_unique
          ( p_benfts_grp_id        in   number
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number)
is
l_proc      varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
             from   ben_benfts_grp
             Where  benfts_grp_id <> nvl(p_benfts_grp_id,-1)
             and    name = p_name
             and    business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
--
-- ----------------------------------------------------------------------- --
-- -----------------------< chk_child_records >-----------------------------|
-- -------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that benefit groups do not exist in the
--   per_all_people_f table when the user deletes the record in the ben_
--   bnfts_grp table.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   benfts_grp_id      PK of record being inserted or updated.
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
procedure chk_child_records(p_benfts_grp_id  in number,
                            p_business_Group_id in number) is
  --
  l_proc         varchar2(72):= g_package||'chk_child_records';
  v_dummy        varchar2(1);
  --
   cursor chk_benefits_group is select null
                                from   per_all_people_f per
                                where  per.benefit_group_id = p_benfts_grp_id
                                  and  per.business_Group_id= p_business_group_id; /* Perf Bug 4882374 */
begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- check if benefit groups exists in the per_all_people_f table
    --
   open chk_benefits_group;
     --
     -- fetch value from cursor if it returns a record then the
     -- the user cannot delete the benefits group
     --
   fetch chk_benefits_group into v_dummy;
   if chk_benefits_group%found then
        close chk_benefits_group;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91740_BG_CHLD_RCD_EXISTS');
        fnd_message.raise_error;
        --
   end if;
   --
   close chk_benefits_group;
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_records;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_bng_shd.g_rec_type) is
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
  chk_benfts_grp_id
  (p_benfts_grp_id          => p_rec.benfts_grp_id,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_name_unique
     ( p_benfts_grp_id       => p_rec.benfts_grp_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_bng_shd.g_rec_type) is
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
  chk_benfts_grp_id
  (p_benfts_grp_id          => p_rec.benfts_grp_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
     ( p_benfts_grp_id       => p_rec.benfts_grp_id
      ,p_name                => p_rec.name
      ,p_business_group_id   => p_rec.business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_bng_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
 chk_child_records
  (p_benfts_grp_id           => p_rec.benfts_grp_id,
   p_business_Group_id       => p_rec.business_Group_id);
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
  (p_benfts_grp_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_benfts_grp b
    where b.benfts_grp_id      = p_benfts_grp_id
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
                             p_argument       => 'benfts_grp_id',
                             p_argument_value => p_benfts_grp_id);
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
end ben_bng_bus;

/
