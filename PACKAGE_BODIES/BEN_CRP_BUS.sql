--------------------------------------------------------
--  DDL for Package Body BEN_CRP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CRP_BUS" as
/* $Header: becrprhi.pkb 115.4 2002/12/16 11:04:00 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_crp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cbr_per_in_ler_id >------|
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
--   cbr_per_in_ler_id PK of record being inserted or updated.
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
Procedure chk_cbr_per_in_ler_id(p_cbr_per_in_ler_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cbr_per_in_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crp_shd.api_updating
    (p_cbr_per_in_ler_id                => p_cbr_per_in_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cbr_per_in_ler_id,hr_api.g_number)
     <>  ben_crp_shd.g_old_rec.cbr_per_in_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_crp_shd.constraint_error('BEN_CBR_PER_IN_LER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cbr_per_in_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_crp_shd.constraint_error('BEN_CBR_PER_IN_LER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cbr_per_in_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cbr_quald_bnf_id >------|
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
--   p_cbr_per_in_ler_id PK
--   p_cbr_quald_bnf_id ID of FK column
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
Procedure chk_cbr_quald_bnf_id (p_cbr_per_in_ler_id          in number,
                            p_cbr_quald_bnf_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cbr_quald_bnf_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_cbr_quald_bnf a
    where  a.cbr_quald_bnf_id = p_cbr_quald_bnf_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_crp_shd.api_updating
     (p_cbr_per_in_ler_id            => p_cbr_per_in_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cbr_quald_bnf_id,hr_api.g_number)
     <> nvl(ben_crp_shd.g_old_rec.cbr_quald_bnf_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if cbr_quald_bnf_id value exists in ben_cbr_quald_bnf table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_cbr_quald_bnf
        -- table.
        --
        ben_crp_shd.constraint_error('BEN_CBR_PER_IN_LER_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cbr_quald_bnf_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_init_evt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cbr_per_in_ler_id PK of record being inserted or updated.
--   init_evt_flag Value of lookup code.
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
Procedure chk_init_evt_flag(p_cbr_per_in_ler_id                in number,
                            p_init_evt_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_init_evt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_crp_shd.api_updating
    (p_cbr_per_in_ler_id                => p_cbr_per_in_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_init_evt_flag
      <> nvl(ben_crp_shd.g_old_rec.init_evt_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_init_evt_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_init_evt_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;

      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_init_evt_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_crp_shd.g_rec_type
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
  chk_cbr_per_in_ler_id
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cbr_quald_bnf_id
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_cbr_quald_bnf_id          => p_rec.cbr_quald_bnf_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_init_evt_flag
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_init_evt_flag         => p_rec.init_evt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_crp_shd.g_rec_type
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
  chk_cbr_per_in_ler_id
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cbr_quald_bnf_id
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_cbr_quald_bnf_id          => p_rec.cbr_quald_bnf_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_init_evt_flag
  (p_cbr_per_in_ler_id          => p_rec.cbr_per_in_ler_id,
   p_init_evt_flag         => p_rec.init_evt_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_crp_shd.g_rec_type
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
  (p_cbr_per_in_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cbr_per_in_ler b
    where b.cbr_per_in_ler_id      = p_cbr_per_in_ler_id
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
                             p_argument       => 'cbr_per_in_ler_id',
                             p_argument_value => p_cbr_per_in_ler_id);
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
end ben_crp_bus;

/
