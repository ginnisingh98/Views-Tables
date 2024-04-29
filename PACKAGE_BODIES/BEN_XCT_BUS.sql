--------------------------------------------------------
--  DDL for Package Body BEN_XCT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCT_BUS" as
/* $Header: bexctrhi.pkb 115.12 2002/12/31 20:39:06 stee ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xct_bus.';  -- Global package name

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_crit_typ_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_crit_typ xct
     where xct.ext_crit_typ_id = p_ext_crit_typ_id
       and pbg.business_group_id = xct.business_group_id;
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
    ,p_argument           => 'ext_crit_typ_id'
    ,p_argument_value     => p_ext_crit_typ_id
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
-- ----------------------------------------------------------------------------
-- |------< chk_ext_crit_typ_id >------|
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
--   ext_crit_typ_id PK of record being inserted or updated.
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
Procedure chk_ext_crit_typ_id(p_ext_crit_typ_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xct_shd.api_updating
    (p_ext_crit_typ_id                => p_ext_crit_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_typ_id,hr_api.g_number)
     <>  ben_xct_shd.g_old_rec.ext_crit_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_xct_shd.constraint_error('BEN_EXT_CRIT_TYP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_crit_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xct_shd.constraint_error('BEN_EXT_CRIT_TYP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_crit_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_crit_prfl_id >------|
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
--   p_ext_crit_typ_id PK
--   p_ext_crit_prfl_id ID of FK column
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
Procedure chk_ext_crit_prfl_id (p_ext_crit_typ_id          in number,
                            p_ext_crit_prfl_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_prfl_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_crit_prfl a
    where  a.ext_crit_prfl_id = p_ext_crit_prfl_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xct_shd.api_updating
     (p_ext_crit_typ_id            => p_ext_crit_typ_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_prfl_id,hr_api.g_number)
     <> nvl(ben_xct_shd.g_old_rec.ext_crit_prfl_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_crit_prfl_id value exists in ben_ext_crit_prfl table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_crit_prfl
        -- table.
        --
        ben_xct_shd.constraint_error('BEN_EXT_CRIT_TYP_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_crit_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crit_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_typ_id PK of record being inserted or updated.
--   crit_typ_cd Value of lookup code.
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
Procedure chk_crit_typ_cd(p_ext_crit_typ_id             in number,
                            p_crit_typ_cd               in varchar2,
                            p_effective_date            in date,
                            p_business_group_id    in   number,
                            p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crit_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xct_shd.api_updating
    (p_ext_crit_typ_id                => p_ext_crit_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_crit_typ_cd is null then
      fnd_message.set_name('BEN','BEN_91900_CRIT_CD_NULL');
      fnd_message.raise_error;
  end if;
  --
  if (l_api_updating
      and p_crit_typ_cd
      <> nvl(ben_xct_shd.g_old_rec.crit_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_crit_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
   if p_business_group_id is not null then
   /* BG is set, so use the existing call, with no modifications*/
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_CRIT_TYP',
           p_lookup_code    => p_crit_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_crit_typ_cd');
      fnd_message.set_name('TYPE','BEN_EXT_CRIT_TYP');
      fnd_message.raise_error;
      --
    end if;
   else
    /* BG is null, so alternative call is required */
    if hr_api.not_exists_in_hrstanlookups
               (p_lookup_type    => 'BEN_EXT_CRIT_TYP',
                p_lookup_code    => p_crit_typ_cd,
                p_effective_date => p_effective_date) then
           --
           -- raise error as does not exist as lookup
           --
           fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
           fnd_message.set_token('FIELD','p_crit_typ_cd');
           fnd_message.set_name('TYPE','BEN_EXT_CRIT_TYP');
           fnd_message.raise_error;
           --
    end if;
    --
   end if; /* p_business_group_id is not null */
    --
  end if; /* l_api_updating.. */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crit_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_crit_typ_cd_upd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that the user cannot update the criteria
--   type code if there are children records present for it.  The message
--   returned instructs the user to first delete the child records before
--   updating criteria type code.  This is not called from insert Validate.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_typ_id PK of record being inserted or updated.
--   crit_typ_cd Value of lookup code.
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
Procedure chk_crit_typ_cd_upd(p_ext_crit_typ_id                in number,
                            p_crit_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  cursor c1 is select null
               from ben_ext_crit_typ xct,
			  ben_ext_crit_val xcv
              where xct.ext_crit_typ_id = p_ext_crit_typ_id
                and xcv.ext_crit_typ_id = xct.ext_crit_typ_id;
  --
  l_proc         varchar2(72) := g_package||'chk_crit_typ_cd_upd';
  l_api_updating boolean;
  l_dummy    char(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xct_shd.api_updating
    (p_ext_crit_typ_id                => p_ext_crit_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  -- on perform this edit if updating, and if value has changed.
  --
  if (l_api_updating and p_crit_typ_cd
      <> nvl(ben_xct_shd.g_old_rec.crit_typ_cd,hr_api.g_varchar2)) then
    --
    -- error if child records exist
    --
    open c1;
    fetch c1 into l_dummy;
    if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91898_EXT_CRIT_TYP_UPD');
      fnd_message.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crit_typ_cd_upd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_crit_cd_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that not two criteria code have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_crit_typ_cd is crit code  name
--     p_ext_crit_prfl_id is criteria prfl id
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
--
-- ----------------------------------------------------------------------------
Procedure chk_crit_cd_unique
          ( p_ext_crit_prfl_id               in number
           ,p_ext_crit_typ_id               in number
           ,p_crit_typ_cd                 in   varchar2
           ,p_business_group_id    in   number
	   ,p_legislation_code	   in  varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_crit_cd_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_ext_crit_typ
              Where ext_crit_prfl_id = p_ext_crit_prfl_id
	      and ext_crit_typ_id <> nvl(p_ext_crit_typ_id,-1)
                and crit_typ_cd = p_crit_typ_cd
                and ((business_group_id is null and legislation_code is null)
                      or (legislation_code is not null
		   	    and legislation_code = p_legislation_code)
		      or (business_group_id is not null
			    and business_group_id = p_business_group_id)
		    );
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91899_EXT_CRIT_TYP_EXISTS');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_crit_cd_unique;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_excld_flag >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   this procedure is used to check that excld_flag has a valid value
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ext_crit_typ_id is primary key of the record
--     p_excld_flag is value of the exclude flag
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
--
-- ----------------------------------------------------------------------------
Procedure chk_excld_flag
          ( p_ext_crit_typ_id               in   number
           ,p_excld_flag                    in   varchar2
           ,p_effective_date                in   date
           ,p_business_group_id		    in   number
           ,p_object_version_number         in   number)
is
l_proc	    varchar2(72) := g_package||'chk_excld_flag';
l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xct_shd.api_updating
      (p_ext_crit_typ_id          => p_ext_crit_typ_id,
       p_object_version_number    => p_object_version_number);
  --
  -- ensure that excld_flag is not null
  --
  if p_excld_flag is null then
      fnd_message.set_name('BEN','BEN_92123_EXCLD_FLAG_NULL');
      fnd_message.raise_error;
  end if;
  --
  -- ensure that the excld_flag has a valid value
  --
  if (l_api_updating
      and p_excld_flag
      <> nvl(ben_xct_shd.g_old_rec.excld_flag, hr_api.g_varchar2)
      or not l_api_updating)
      and p_excld_flag is not null then
     --
     -- check if the value is present for the lookup type
     --
   if p_business_group_id is not null then
   /* BG is set, so use the existing call, with no modifications*/
     if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_excld_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error message
        --
        fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'p_excld_flag');
        fnd_message.set_token('TYPE', 'YES_NO');
        fnd_message.raise_error;
        --
     end if;
   else
    /* BG is null, so alternative call is required */
     if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_excld_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error message
        --
        fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'p_excld_flag');
        fnd_message.set_token('TYPE', 'YES_NO');
        fnd_message.raise_error;
        --
     end if;
    --
   end if; /* p_business_group_id is not null */
  --
  end if; /* if (l_api_updating.. */
  --
End chk_excld_flag;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xct_shd.g_rec_type
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
  chk_ext_crit_typ_id
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_prfl_id
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_typ_cd
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_crit_typ_cd           => p_rec.crit_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id    => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_crit_cd_unique
          ( p_ext_crit_prfl_id =>p_rec.ext_crit_prfl_id
          , p_ext_crit_typ_id =>p_rec.ext_crit_typ_id
           ,p_crit_typ_cd                =>p_rec.crit_typ_cd
           ,p_business_group_id    => p_rec.business_group_id
           ,p_legislation_code     => p_rec.legislation_code);
  --
  chk_excld_flag
  (p_ext_crit_typ_id      => p_rec.ext_crit_typ_id,
   p_excld_flag           => p_rec.excld_flag,
   p_effective_date       => p_effective_date,
   p_business_group_id    => p_rec.business_group_id,
   p_object_version_number=> p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xct_shd.g_rec_type
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
  chk_ext_crit_typ_id
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_prfl_id
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_typ_cd
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_crit_typ_cd         => p_rec.crit_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id    => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_typ_cd_upd
  (p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_crit_typ_cd         => p_rec.crit_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_crit_cd_unique
          ( p_ext_crit_prfl_id =>p_rec.ext_crit_prfl_id
          , p_ext_crit_typ_id =>p_rec.ext_crit_typ_id
           ,p_crit_typ_cd                =>p_rec.crit_typ_cd
           ,p_business_group_id    =>p_rec.business_group_id
           ,p_legislation_code     => p_rec.legislation_code);
  --
  chk_excld_flag
  (p_ext_crit_typ_id      => p_rec.ext_crit_typ_id,
   p_excld_flag           => p_rec.excld_flag,
   p_effective_date       => p_effective_date,
   p_business_group_id    => p_rec.business_group_id,
   p_object_version_number=> p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xct_shd.g_rec_type
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
                    ,ben_xct_shd.g_old_rec.business_group_id
                    ,ben_xct_shd.g_old_rec.legislation_code);
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
  (p_ext_crit_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_crit_typ b
    where b.ext_crit_typ_id      = p_ext_crit_typ_id
    and   a.business_group_id(+) = b.business_group_id;
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
                             p_argument       => 'ext_crit_typ_id',
                             p_argument_value => p_ext_crit_typ_id);
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
end ben_xct_bus;

/
