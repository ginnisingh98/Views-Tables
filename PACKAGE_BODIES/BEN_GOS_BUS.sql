--------------------------------------------------------
--  DDL for Package Body BEN_GOS_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GOS_BUS" as
/* $Header: begosrhi.pkb 120.0 2005/05/28 03:08:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_gos_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_gd_or_svc_typ_id >------|
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
--   gd_or_svc_typ_id PK of record being inserted or updated.
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
Procedure chk_gd_or_svc_typ_id(p_gd_or_svc_typ_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_gd_or_svc_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_gos_shd.api_updating
    (p_gd_or_svc_typ_id                => p_gd_or_svc_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_gd_or_svc_typ_id,hr_api.g_number)
     <>  ben_gos_shd.g_old_rec.gd_or_svc_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_gos_shd.constraint_error('BEN_GD_OR_SVC_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_gd_or_svc_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_gos_shd.constraint_error('BEN_GD_OR_SVC_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_gd_or_svc_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   gd_or_svc_typ_id PK of record being inserted or updated.
--   typ_cd Value of lookup code.
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
Procedure chk_typ_cd(p_gd_or_svc_typ_id                in number,
                            p_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_gos_shd.api_updating
    (p_gd_or_svc_typ_id                => p_gd_or_svc_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_typ_cd
      <> nvl(ben_gos_shd.g_old_rec.typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
  hr_utility.set_location('In:'||l_proc||'lookup_code='||p_typ_cd,8);

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_GD_R_SVC_TYP',
           p_lookup_code    => p_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_name >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the name is unique.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   gd_or_svc_typ_id PK of record being inserted or updated.
--   name is the name of the record been updeated or inserted.
--   business_group_id is the business group id of the record
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
Procedure chk_name(p_gd_or_svc_typ_id            in number,
                   p_name                        in varchar2,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_name is
     select null
        from BEN_GD_OR_SVC_TYP
        where name = p_name
          and gd_or_svc_typ_id <> nvl(p_gd_or_svc_typ_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_gos_shd.api_updating
    (p_gd_or_svc_typ_id         => p_gd_or_svc_typ_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_gos_shd.g_old_rec.name) or
      not l_api_updating then
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- check if this name already exist
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      hr_utility.set_location('Entering:'||l_proc, 15);
      close csr_name;
      --
      -- raise error as Name is not Unique
      --
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_name;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_name;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_gos_shd.g_rec_type
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
  chk_gd_or_svc_typ_id
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_typ_cd
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_typ_cd         => p_rec.typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
  chk_name
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_name                      => p_rec.name,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_gos_shd.g_rec_type
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
  chk_gd_or_svc_typ_id
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_typ_cd
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_typ_cd         => p_rec.typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
--
  chk_name
  (p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_name                      => p_rec.name,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_gos_shd.g_rec_type
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
  (p_gd_or_svc_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_gd_or_svc_typ b
    where b.gd_or_svc_typ_id      = p_gd_or_svc_typ_id
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
                             p_argument       => 'gd_or_svc_typ_id',
                             p_argument_value => p_gd_or_svc_typ_id);
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
end ben_gos_bus;

/
