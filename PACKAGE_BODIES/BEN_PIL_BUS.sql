--------------------------------------------------------
--  DDL for Package Body BEN_PIL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PIL_BUS" as
/* $Header: bepilrhi.pkb 120.3 2006/09/26 10:56:35 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pil_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_per_in_ler_id >------|
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
--   per_in_ler_id PK of record being inserted or updated.
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
Procedure chk_per_in_ler_id(p_per_in_ler_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_in_ler_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pil_shd.api_updating
    (p_per_in_ler_id                => p_per_in_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_per_in_ler_id,hr_api.g_number)
     <>  ben_pil_shd.g_old_rec.per_in_ler_id) then
    --
    -- raise error as PK has changed
    --
    ben_pil_shd.constraint_error('BEN_PER_IN_LER_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_per_in_ler_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pil_shd.constraint_error('BEN_PER_IN_LER_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_per_in_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ler_id >------|
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
--   p_per_in_ler_id PK
--   p_ler_id ID of FK column
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
Procedure chk_ler_id (p_per_in_ler_id          in number,
                            p_ler_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ler_f a
    where  a.ler_id = p_ler_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pil_shd.api_updating
     (p_per_in_ler_id            => p_per_in_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ler_id,hr_api.g_number)
     <> nvl(ben_pil_shd.g_old_rec.ler_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ler_id value exists in ben_ler_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ler_f
        -- table.
        --
        ben_pil_shd.constraint_error('BEN_PER_IN_LER_DT1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ler_id;
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
--   p_per_in_ler_id PK
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
Procedure chk_person_id (p_per_in_ler_id          in number,
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
  l_api_updating := ben_pil_shd.api_updating
     (p_per_in_ler_id            => p_per_in_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_person_id,hr_api.g_number)
     <> nvl(ben_pil_shd.g_old_rec.person_id,hr_api.g_number)
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
        ben_pil_shd.constraint_error('BEN_PER_IN_LER_DT2');
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_prvs_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   per_in_ler_id PK of record being inserted or updated.
--   prvs_stat_cd Value of lookup code.
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
Procedure chk_prvs_stat_cd(p_per_in_ler_id                in number,
                            p_prvs_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prvs_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pil_shd.api_updating
    (p_per_in_ler_id                => p_per_in_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_prvs_stat_cd
      <> nvl(ben_pil_shd.g_old_rec.prvs_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prvs_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PER_IN_LER_STAT',
           p_lookup_code    => p_prvs_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prvs_stat_cd');
      fnd_message.set_token('TYPE','BEN_PER_IN_LER_STAT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prvs_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_per_in_ler_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   per_in_ler_id PK of record being inserted or updated.
--   per_in_ler_stat_cd Value of lookup code.
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
Procedure chk_per_in_ler_stat_cd(p_per_in_ler_id                in number,
                            p_per_in_ler_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_per_in_ler_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pil_shd.api_updating
    (p_per_in_ler_id                => p_per_in_ler_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_per_in_ler_stat_cd
      <> nvl(ben_pil_shd.g_old_rec.per_in_ler_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_per_in_ler_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PER_IN_LER_STAT',
           p_lookup_code    => p_per_in_ler_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_per_in_ler_stat_cd');
      fnd_message.set_token('TYPE','BEN_PER_IN_LER_STAT_CD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_per_in_ler_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_bckt_per_in_ler_id >------|
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
--   p_per_in_ler_id PK
--   p_bckt_per_in_ler_id ID of FK column
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
Procedure chk_bckt_per_in_ler_id (p_per_in_ler_id         in number,
                      p_bckt_per_in_ler_id    in number,
                      p_effective_date        in date,
                      p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_bckt_per_in_ler_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_per_in_ler a
    where  a.per_in_ler_id = p_bckt_per_in_ler_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pil_shd.api_updating
     (p_per_in_ler_id            => p_per_in_ler_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_bckt_per_in_ler_id,hr_api.g_number)
     <> nvl(ben_pil_shd.g_old_rec.bckt_per_in_ler_id,hr_api.g_number)
     or not l_api_updating)
     and p_bckt_per_in_ler_id is not null
  then
    --
    -- check if bckt_per_in_ler_id value exists in ben_per_in_ler table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_per_in_ler
        -- table.
        --
        ben_pil_shd.constraint_error('BEN_PER_IN_LER_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_bckt_per_in_ler_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_ws_mgr_id >---------------------------|
-- ----------------------------------------------------------------------------
--  Validates ws_mgr_id. Any person B, below in the hierarchy to person A,
--  cannot be re-assigned as the manager to A.
--
procedure chk_ws_mgr_id(
   p_per_in_ler_id number,
   p_ws_mgr_id              number,
   p_effective_date         date) is

   cursor c1 is
   select per1.full_name person1,
          per2.full_name person2
     from ben_cwb_group_hrchy cwb1,
          ben_per_in_ler pil1,
          per_all_people_f per1,
          per_all_people_f per2
    where cwb1.mgr_per_in_ler_id = p_per_in_ler_id
      and cwb1.lvl_num > 0
      and pil1.per_in_ler_id = cwb1.mgr_per_in_ler_id
      and per1.person_id = pil1.person_id
      and trunc(p_effective_date) between per1.effective_start_date
      and per1.effective_end_date
      and per2.person_id = p_ws_mgr_id
      and trunc(p_effective_date) between per2.effective_start_date
      and per2.effective_end_date
      and exists
      ( select 'x'
          from ben_per_in_ler pil2
         where pil2.person_id = p_ws_mgr_id
           and pil2.lf_evt_ocrd_dt = pil1.lf_evt_ocrd_dt
           and pil2.ler_id = pil1.ler_id
           and pil2.per_in_ler_id = cwb1.emp_per_in_ler_id);

   l_person1 per_all_people_f.full_name%type;
   l_person2 per_all_people_f.full_name%type;
   l_proc varchar2(72) := g_package||'chk_ws_mgr_id';

begin

   hr_utility.set_location(' Entering:'||l_proc, 10);

   if (p_ws_mgr_id
       <> nvl(ben_pil_shd.g_old_rec.ws_mgr_id,hr_api.g_number)) then

      open c1;
      fetch c1 into l_person1,l_person2;
      if c1%found then
         close c1;
         fnd_message.set_name('BEN','BEN_93251_CWB_CANNOT_REASSIGN');
         fnd_message.set_token('PERSON1', l_person1);
         fnd_message.set_token('PERSON2', l_person2);
         fnd_message.raise_error;
      end if;
      close c1;

   end if;

   hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_ws_mgr_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_pil_shd.g_rec_type
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
  chk_per_in_ler_id
  (p_per_in_ler_id          => p_rec.per_in_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_in_ler_stat_cd
  (p_per_in_ler_id          => p_rec.per_in_ler_id,
   p_per_in_ler_stat_cd         => p_rec.per_in_ler_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prvs_stat_cd
  (p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_prvs_stat_cd          => p_rec.prvs_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --
  chk_bckt_per_in_ler_id
  (p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_bckt_per_in_ler_id    => p_rec.bckt_per_in_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_pil_shd.g_rec_type
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
  chk_per_in_ler_id
  (p_per_in_ler_id          => p_rec.per_in_ler_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_per_in_ler_stat_cd
  (p_per_in_ler_id          => p_rec.per_in_ler_id,
   p_per_in_ler_stat_cd         => p_rec.per_in_ler_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prvs_stat_cd
  (p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_prvs_stat_cd          => p_rec.prvs_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_bckt_per_in_ler_id
  (p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_bckt_per_in_ler_id    => p_rec.bckt_per_in_ler_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ws_mgr_id
  (p_per_in_ler_id         => p_rec.per_in_ler_id,
   p_ws_mgr_id             => p_rec.ws_mgr_id ,
   p_effective_date        => p_effective_date
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_pil_shd.g_rec_type
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
  (p_per_in_ler_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_per_in_ler b
    where b.per_in_ler_id      = p_per_in_ler_id
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
                             p_argument       => 'per_in_ler_id',
                             p_argument_value => p_per_in_ler_id);
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
end ben_pil_bus;

/
