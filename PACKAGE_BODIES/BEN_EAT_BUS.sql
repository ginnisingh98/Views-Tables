--------------------------------------------------------
--  DDL for Package Body BEN_EAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EAT_BUS" as
/* $Header: beeatrhi.pkb 115.11 2002/12/16 11:53:54 vsethi ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_eat_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_actn_typ_id >------|
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
--   actn_typ_id PK of record being inserted or updated.
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
Procedure chk_actn_typ_id(p_actn_typ_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actn_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_eat_shd.api_updating
    (p_actn_typ_id                => p_actn_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_actn_typ_id,hr_api.g_number)
     <>  ben_eat_shd.g_old_rec.actn_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_eat_shd.constraint_error('BEN_ACTN_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_actn_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_eat_shd.constraint_error('BEN_ACTN_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_actn_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   actn_typ_id PK of record being inserted or updated.
--   type_cd Value of lookup code.
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
Procedure chk_type_cd(p_actn_typ_id               in number,
                      p_type_cd                   in varchar2,
                      p_business_group_id         in number,
                      p_effective_date            in date,
                      p_object_version_number     in number) is
--
cursor l_csr_eat is
    SELECT  'x'
    FROM    ben_actn_typ
    WHERE   type_cd                    = nvl(p_type_cd, hr_api.g_varchar2)
    AND     business_group_id + 0     = p_business_group_id;
  --
  l_db_eat_row   l_csr_eat%rowtype;
  l_proc         varchar2(72) := g_package||'chk_type_cd';
  l_api_updating boolean;
  l_table_name	all_tables.table_name%TYPE;
  l_dummy        varchar2(1);
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_eat_shd.api_updating
    (p_actn_typ_id                => p_actn_typ_id,
     p_object_version_number       => p_object_version_number);
  --
 if (l_api_updating and
        ben_eat_shd.g_old_rec.type_cd in ('BNF', 'BNFADDNL', 'BNFADDR', 'BNFCTFN',
                    'BNFDOB', 'BNFSSN','BNFTTEE', 'DD', 'DDADDNL','DDADDR','DDCTFN',
                    'DDDOB', 'DDSSN', 'LEECTFN', 'WVPRTNCTFN', 'ENRTCTFN', 'PC', 'TA')
        and nvl(p_type_cd,hr_api.g_varchar2) <> ben_eat_shd.g_old_rec.type_cd) then
        -- The user is not allowed to change these System Enrollment Action TYPES
        --
	fnd_message.set_name('BEN','BEN_91449_ACTN_TYP_CHG');
        fnd_message.raise_error;
    end if;

    if nvl(p_type_cd,hr_api.g_varchar2)
       <> nvl(ben_eat_shd.g_old_rec.type_cd,hr_api.g_varchar2)
        and
        p_type_cd in  ('BNF', 'BNFADDNL', 'BNFADDR', 'BNFCTFN',
                    'BNFDOB', 'BNFSSN', 'BNFTTEE', 'DD', 'DDADDNL','DDADDR','DDCTFN',
                    'DDDOB', 'DDSSN', 'LEECTFN', 'WVPRTNCTFN', 'ENRTCTFN', 'PC', 'TA') then
        -- Check to see if a eat already exists of this type.  If so, do not
        -- allow creation of it.  If not, allow creation.
        open l_csr_eat;
        fetch l_csr_eat into l_db_eat_row;
        if l_csr_eat%found then
           close l_csr_eat;
           -- The user is not allowed to create Actions of System type.
           fnd_message.set_name('BEN','BEN_91450_ACTN_TYP_INS');
           fnd_message.raise_error;
        else
           close l_csr_eat;
        end if;
    end if;


  if (l_api_updating
      and p_type_cd
      <> nvl(ben_eat_shd.g_old_rec.type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTN_TYP',
           p_lookup_code    => p_type_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_type_cd');
      fnd_message.set_token('TYPE','BEN_ACTN_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  -- Only allow the Type Code to change if the record is not being used in any
  -- foreign keys.  CAN change the type from null to something though.
  if (l_api_updating
      and nvl(p_type_cd,hr_api.g_varchar2)
      <> nvl(ben_eat_shd.g_old_rec.type_cd,hr_api.g_varchar2)
      and ben_eat_shd.g_old_rec.type_cd is not null) then
        null;
    --
	 declare
         cursor c1 is select null
                      from ben_prtt_enrt_actn_f
                      where actn_typ_id = p_actn_typ_id;
      begin
         open c1;
         fetch c1 into l_dummy;
         if c1%found then
            fnd_message.set_name('BEN','BEN_91424_DERIV_TYPE_INS');
            fnd_message.raise_error;
         end if;
      end;

  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_name >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a name is unique.
--
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_actn_typ_id PK
--   p_organization_id ID of FK column
--   p_effective_date Session date of record
--   p_object_version_number Object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_name(p_actn_typ_id                in number,
                   p_effective_date               in date,
                   p_name                         in varchar2,
                   p_business_group_id            in number,
                   p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_dummy       varchar2(1);
--
 cursor c1 is
  select null
  from ben_actn_typ
  where name = p_name
    and p_actn_typ_id <> nvl(p_actn_typ_id, hr_api.g_number)
    and business_group_id + 0 = p_business_group_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_eat_shd.api_updating
    (p_actn_typ_id                => p_actn_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_eat_shd.g_old_rec.name) or
      not l_api_updating then
   --
   -- check if name already exists
   --
   open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      --
      -- raise error as Name must be Unique
      --
        fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
          fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_name;
-- --
--
-- Procedure Added chk_actn_typ_sys_del, Bug 2366282
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_actn_typ_sys_del >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks whether the record being deleted
--   has a system defined action type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_actn_typ_id PK
--   p_object_version_number  Object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_actn_typ_sys_del(p_actn_typ_id           in number,
                               p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_actn_typ_sys_del';
  l_api_updating boolean;
  l_type_cd      varchar2(30);
  --
  cursor c_type_cd is
    select type_cd
    from ben_actn_typ
    where actn_typ_id = p_actn_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_eat_shd.api_updating
    (p_actn_typ_id              => p_actn_typ_id,
     p_object_version_number    => p_object_version_number);
  --
  open c_type_cd;
  fetch c_type_cd into l_type_cd;
  --
  if(l_api_updating and
     l_type_cd in ('BNF', 'BNFADDNL', 'BNFADDR', 'BNFCTFN', 'BNFDOB','BNFSSN',
                   'BNFTTEE', 'DD', 'DDADDNL','DDADDR','DDCTFN','DDDOB', 'DDSSN',
                   'LEECTFN', 'WVPRTNCTFN', 'ENRTCTFN', 'PC', 'TA')) then
     close c_type_cd;
     --
     -- raise error as System Defined Actions Types cannot be Deleted
     --
       fnd_message.set_name('PAY','HR_6044_STARTUP_CANNOT_DELETE');
       fnd_message.raise_error;
     --
   end if;
   --
  close c_type_cd;
  --
 hr_utility.set_location('Leaving:'||l_proc,10);
 --
end chk_actn_typ_sys_del;
--
-- End of fix, Bug 2366282
-- --
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_eat_shd.g_rec_type
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
  chk_actn_typ_id
  (p_actn_typ_id          => p_rec.actn_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_type_cd
  (p_actn_typ_id          => p_rec.actn_typ_id,
   p_type_cd              => p_rec.type_cd,
   p_business_group_id    => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
    (p_actn_typ_id                 => p_rec.actn_typ_id,
     p_effective_date              => p_effective_date,
     p_name                        => p_rec.name,
     p_business_group_id           => p_rec.business_group_id,
     p_object_version_number       => p_rec.object_version_number);

  --
 hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_eat_shd.g_rec_type
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
  chk_actn_typ_id
  (p_actn_typ_id          => p_rec.actn_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_type_cd
  (p_actn_typ_id          => p_rec.actn_typ_id,
   p_type_cd         => p_rec.type_cd,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
   (p_actn_typ_id                 => p_rec.actn_typ_id,
     p_effective_date              => p_effective_date,
     p_name                        => p_rec.name,
     p_business_group_id           => p_rec.business_group_id,
     p_object_version_number       => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_eat_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_actn_typ_sys_del                                      -- Bug 2366282
  (p_actn_typ_id          => p_rec.actn_typ_id,
   p_object_version_number => p_rec.object_version_number); -- Bug 2366282
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
  (p_actn_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_actn_typ b
    where b.actn_typ_id      = p_actn_typ_id
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
                             p_argument       => 'actn_typ_id',
                             p_argument_value => p_actn_typ_id);
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
end ben_eat_bus;

/
