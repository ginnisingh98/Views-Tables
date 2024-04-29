--------------------------------------------------------
--  DDL for Package Body BEN_XRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XRC_BUS" as
/* $Header: bexrcrhi.pkb 120.0 2005/05/28 12:37:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xrc_bus.';  -- Global package name

--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  --
  IF (p_insert) THEN
    --
    -- Call procedure to check startup_action for inserts.
    --
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    --
    -- Call procedure to check startup_action for updates and deletes.
    --
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_rcd_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_rcd xrc
     where xrc.ext_rcd_id = p_ext_rcd_id
       and pbg.business_group_id = xrc.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ext_rcd_id'
    ,p_argument_value     => p_ext_rcd_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;

--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rcd_id >------|
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
--   ext_rcd_id PK of record being inserted or updated.
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
Procedure chk_ext_rcd_id(p_ext_rcd_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rcd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrc_shd.api_updating
    (p_ext_rcd_id                => p_ext_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_id,hr_api.g_number)
     <>  ben_xrc_shd.g_old_rec.ext_rcd_id) then
    --
    -- raise error as PK has changed
    --
    ben_xrc_shd.constraint_error('BEN_EXT_RCD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_rcd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xrc_shd.constraint_error('BEN_EXT_RCD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_rcd_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that an extract record must have a name and not two extract record have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is extract name
--     p_ext_rcd_id is extract record id
--     p_business_group_id
--     p_legislation_code
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
-- ----------------------------------------------------------------------------
Procedure chk_name_unique
          ( p_ext_rcd_id               in number
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number
           ,p_legislation_code     in   varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_ext_rcd
              Where ext_rcd_id <> nvl(p_ext_rcd_id,-1)
                and name = p_name
		and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
                           and business_group_id is null
		   	    and legislation_code = p_legislation_code)
		      or (business_group_id is not null
			    and business_group_id = p_business_group_id)
		    );
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_name is null then
      fnd_message.set_name('BEN','BEN_91783_NAME_NULL');
      fnd_message.raise_error;
  end if;
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
-- ----------------------------------------------------------------------------
-- |------< chk_rcd_type_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_rcd_id PK of record being inserted or updated.
--   rcd_type_cd Value of lookup code.
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
Procedure chk_rcd_type_cd(p_ext_rcd_id                in number,
                            p_rcd_type_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id		in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rcd_type_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrc_shd.api_updating
    (p_ext_rcd_id                => p_ext_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rcd_type_cd
      <> nvl(ben_xrc_shd.g_old_rec.rcd_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rcd_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
      if hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => 'BEN_EXT_RCD_TYP',
                 p_lookup_code    => p_rcd_type_cd,
                 p_effective_date => p_effective_date) then
            --
            -- raise error as does not exist as lookup
            --
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD','p_rcd_type_cd');
            fnd_message.set_token('TYPE','BEN_EXT_RCD_TYP');
            fnd_message.raise_error;
            --
      end if;
    else
    /* BG is null, so alternative call is required */
      if hr_api.not_exists_in_hrstanlookups
                (p_lookup_type    => 'BEN_EXT_RCD_TYP',
                 p_lookup_code    => p_rcd_type_cd,
                 p_effective_date => p_effective_date) then
            --
            -- raise error as does not exist as lookup
            --
            --
            fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
            fnd_message.set_token('FIELD','p_rcd_type_cd');
            fnd_message.set_token('TYPE','BEN_EXT_RCD_TYP');
            fnd_message.raise_error;
            --
      end if;
    end if;
    --
  end if; /* if (l_api_updating... */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rcd_type_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_low_lvl_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_rcd_id PK of record being inserted or updated.
--   low_lvl_cd Value of lookup code.
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
Procedure chk_low_lvl_cd(p_ext_rcd_id                in number,
                            p_low_lvl_cd             in varchar2,
                            p_effective_date         in date,
                            p_business_group_id	     in number,
                            p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_low_lvl_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrc_shd.api_updating
    (p_ext_rcd_id                => p_ext_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_low_lvl_cd
      <> nvl(ben_xrc_shd.g_old_rec.low_lvl_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_low_lvl_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_EXT_LVL',
               p_lookup_code    => p_low_lvl_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_low_lvl_cd');
          fnd_message.set_token('TYPE','BEN_EXT_LVL');
          fnd_message.raise_error;
          --
        end if;
    else
    /* BG is null, so alternative call is required */
        if hr_api.not_exists_in_hrstanlookups
              (p_lookup_type    => 'BEN_EXT_LVL',
               p_lookup_code    => p_low_lvl_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_low_lvl_cd');
          fnd_message.set_token('TYPE','BEN_EXT_LVL');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if; /* if (l_api_updating... */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_low_lvl_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rcd_data_typ >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the record type is consistent with
--   the data element type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_rcd_id PK of record being inserted or updated.
--   rcd_type_cd Value of record type.
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
Procedure chk_rcd_data_typ(p_ext_rcd_id                in number,
                           p_rcd_type_cd               in varchar2,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rcd_data_typ';
  l_api_updating boolean;

  cursor c1 is select data_elmt_typ_cd, alwd_in_rcd_cd
  from ben_ext_data_elmt a, ben_ext_fld b, ben_ext_data_elmt_in_rcd c
  where a.ext_fld_id = b.ext_fld_id
  and   a.ext_data_elmt_id = c.ext_data_elmt_id
  and   c.ext_rcd_id = p_ext_rcd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xrc_shd.api_updating
    (p_ext_rcd_id                => p_ext_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rcd_type_cd
      <> nvl(ben_xrc_shd.g_old_rec.rcd_type_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rcd_type_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
   for r1 in c1
   loop
     if r1.data_elmt_typ_cd in ('D','F') then
        if r1.alwd_in_rcd_cd in ('D','H','T') then
           if p_rcd_type_cd <> r1.alwd_in_rcd_cd then
      		fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
      		fnd_message.raise_error;
           end if;
        elsif r1.alwd_in_rcd_cd = 'B' then
           if p_rcd_type_cd not in ('H','T','L') then
      		fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
      		fnd_message.raise_error;
           end if;
        end if;
     elsif r1.data_elmt_typ_cd = 'R' then
        if p_rcd_type_cd <> 'D' then
      		fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
      		fnd_message.raise_error;
        end if;
     elsif r1.data_elmt_typ_cd = 'T' then
        if p_rcd_type_cd not in ('H','T', 'L') then
      		fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
      		fnd_message.raise_error;
        end if;
    end if;
  end loop;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rcd_data_typ;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xrc_shd.g_rec_type
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
  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_rcd_id
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);

  chk_rcd_type_cd
  (p_ext_rcd_id            => p_rec.ext_rcd_id,
   p_rcd_type_cd           => p_rec.rcd_type_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_low_lvl_cd
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_low_lvl_cd         => p_rec.low_lvl_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xrc_shd.g_rec_type
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
  chk_startup_action(False
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_rcd_id
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);

  chk_rcd_type_cd
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_rcd_type_cd         => p_rec.rcd_type_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_low_lvl_cd
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_low_lvl_cd         => p_rec.low_lvl_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rcd_data_typ
  (p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_rcd_type_cd         => p_rec.rcd_type_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xrc_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,ben_xrc_shd.g_old_rec.business_group_id
                    ,ben_xrc_shd.g_old_rec.legislation_code);
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
  (p_ext_rcd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_rcd b
    where b.ext_rcd_id      = p_ext_rcd_id
    and   a.business_group_id(+) = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%type ;
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'ext_rcd_id',
                             p_argument_value => p_ext_rcd_id);
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
end ben_xrc_bus;

/
