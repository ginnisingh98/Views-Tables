--------------------------------------------------------
--  DDL for Package Body BEN_ERC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ERC_BUS" as
/* $Header: beercrhi.pkb 115.2 2002/12/11 11:16:15 hnarayan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_erc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_rt_ctfn_id >------|
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
--   enrt_rt_ctfn_id PK of record being inserted or updated.
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
Procedure chk_enrt_rt_ctfn_id(p_enrt_rt_ctfn_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_rt_ctfn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erc_shd.api_updating
    (p_enrt_rt_ctfn_id                => p_enrt_rt_ctfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_enrt_rt_ctfn_id,hr_api.g_number)
     <>  ben_erc_shd.g_old_rec.enrt_rt_ctfn_id) then
    --
    -- raise error as PK has changed
    --
    ben_erc_shd.constraint_error('BEN_enrt_rt_ctfn_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_enrt_rt_ctfn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_erc_shd.constraint_error('BEN_enrt_rt_ctfn_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_enrt_rt_ctfn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_rt_ctfn_id PK of record being inserted or updated.
--   rqd_flag Value of lookup code.
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
Procedure chk_rqd_flag(p_enrt_rt_ctfn_id                in number,
                            p_rqd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erc_shd.api_updating
    (p_enrt_rt_ctfn_id                => p_enrt_rt_ctfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_flag
      <> nvl(ben_erc_shd.g_old_rec.rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_rqd_flag,
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
end chk_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_enrt_ctfn_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   enrt_rt_ctfn_id PK of record being inserted or updated.
--   enrt_ctfn_typ_cd Value of lookup code.
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
Procedure chk_enrt_ctfn_typ_cd(p_enrt_rt_ctfn_id                in number,
                            p_enrt_ctfn_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_enrt_ctfn_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_erc_shd.api_updating
    (p_enrt_rt_ctfn_id                => p_enrt_rt_ctfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_enrt_ctfn_typ_cd
      <> nvl(ben_erc_shd.g_old_rec.enrt_ctfn_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CTFN_TYP',
           p_lookup_code    => p_enrt_ctfn_typ_cd,
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
end chk_enrt_ctfn_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_erc_shd.g_rec_type
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
  chk_enrt_rt_ctfn_id
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_ctfn_typ_cd
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_enrt_ctfn_typ_cd         => p_rec.enrt_ctfn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_erc_shd.g_rec_type
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
  chk_enrt_rt_ctfn_id
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_enrt_ctfn_typ_cd
  (p_enrt_rt_ctfn_id          => p_rec.enrt_rt_ctfn_id,
   p_enrt_ctfn_typ_cd         => p_rec.enrt_ctfn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_erc_shd.g_rec_type
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
  (p_enrt_rt_ctfn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_enrt_rt_ctfn b
    where b.enrt_rt_ctfn_id      = p_enrt_rt_ctfn_id
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
                             p_argument       => 'enrt_rt_ctfn_id',
                             p_argument_value => p_enrt_rt_ctfn_id);
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
end ben_erc_bus;

/
