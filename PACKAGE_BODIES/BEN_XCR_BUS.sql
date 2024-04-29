--------------------------------------------------------
--  DDL for Package Body BEN_XCR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCR_BUS" as
/* $Header: bexcrrhi.pkb 120.0 2005/05/28 12:25:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcr_bus.';  -- Global package name

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_crit_prfl_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_crit_prfl xcr
     where xcr.ext_crit_prfl_id = p_ext_crit_prfl_id
       and pbg.business_group_id = xcr.business_group_id;
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
    ,p_argument           => 'ext_crit_prfl_id'
    ,p_argument_value     => p_ext_crit_prfl_id
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
-- |------< chk_ext_crit_prfl_id >------|
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
--   ext_crit_prfl_id PK of record being inserted or updated.
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
Procedure chk_ext_crit_prfl_id(p_ext_crit_prfl_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_prfl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcr_shd.api_updating
    (p_ext_crit_prfl_id                => p_ext_crit_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_prfl_id,hr_api.g_number)
     <>  ben_xcr_shd.g_old_rec.ext_crit_prfl_id) then
    --
    -- raise error as PK has changed
    --
    ben_xcr_shd.constraint_error('BEN_EXT_CRIT_PRFL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_crit_prfl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xcr_shd.constraint_error('BEN_EXT_CRIT_PRFL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_crit_prfl_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that the Profile Name is unique
--   within business_group
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is Profile name
--     p_ext_crit_prfl_id
--     p_business_group_id
--     p_object_version_number
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
          ( p_ext_crit_prfl_id      in   number
           ,p_name                  in   varchar2
           ,p_business_group_id     in   number
           ,p_legislation_code	    in   varchar2
           ,p_object_version_number in   number) is
--
l_proc      varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
l_api_updating    boolean;
--
cursor c1 is select null
             from   ben_ext_crit_prfl a
             Where  a.ext_crit_prfl_id <> nvl(p_ext_crit_prfl_id,hr_api.g_number)
             and    a.name = p_name
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
  l_api_updating := ben_xcr_shd.api_updating
     (p_ext_crit_prfl_id           => p_ext_crit_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_name,hr_api.g_varchar2)
     <>  ben_xcr_shd.g_old_rec.name
     or not l_api_updating) then
    --
    open c1;
    fetch c1 into l_dummy;
    if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_name_unique;
--


Procedure chk_ext_global_flag
          ( p_ext_crit_prfl_id      in   number
           ,p_ext_global_flag       in   varchar2
           ,p_business_group_id     in   number
           ,p_legislation_code      in   varchar2
           ,p_object_version_number in   number
           ,p_effective_date        in   date
         ) is
--
l_proc      varchar2(72) := g_package||'chk_ext_global_flag';
l_dummy    char(1);
l_api_updating    boolean;

 cursor c is
 select 'x'
 from   ben_ext_crit_val  ecv ,
        ben_ext_crit_typ  ect
 where  ect.ext_Crit_prfl_id  =  p_ext_crit_prfl_id
 and    ecv.ext_crit_typ_id   =  ect.ext_crit_typ_id
 and    ecv.ext_crit_bg_id is not null
 and    ecv.ext_crit_bg_id <>  ecv.business_group_id
 ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcr_shd.api_updating
     (p_ext_crit_prfl_id           => p_ext_crit_prfl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_global_flag,hr_api.g_varchar2)
     <>  ben_xcr_shd.g_old_rec.ext_global_flag
     or not l_api_updating) then


     if p_business_group_id is not null then
   /* BG is set, so use the existing call, with no modifications*/
     if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ext_global_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error message
        --
        fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'p_ext_global_flag');
        fnd_message.set_token('TYPE', 'YES_NO');
        fnd_message.raise_error;
        --
     end if;
   else
    /* BG is null, so alternative call is required */
     if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ext_global_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error message
        --
        fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD', 'p_ext_global_flag');
        fnd_message.set_token('TYPE', 'YES_NO');
        fnd_message.raise_error;
        --
     end if;
   end if ;

    --- when the old flag is 'Y' and current flag 'N' then
    -- make sure no child belongs to  global
    if ben_xcr_shd.g_old_rec.ext_global_flag = 'Y' and  p_ext_global_flag = 'N' then
       open c  ;
       fetch c into  l_dummy ;
       if c%found then
          --- create new error
         fnd_message.set_name('BEN', 'BEN_92775_CHILD_REC_EXISTS');
         fnd_message.raise_error;

       end if ;
       close c ;
    end if ;

  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ext_global_flag;



-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xcr_shd.g_rec_type) is
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
  chk_ext_crit_prfl_id
  (p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  ( p_ext_crit_prfl_id => p_rec.ext_crit_prfl_id
   ,p_name             => p_rec.name
   ,p_business_group_id => p_rec.business_group_id
   ,p_legislation_code  => p_rec.legislation_code
   ,p_object_version_number => p_rec.object_version_number);
  --


   chk_ext_global_flag
          ( p_ext_crit_prfl_id      =>   p_rec.ext_crit_prfl_id
           ,p_ext_global_flag       =>   p_rec.ext_global_flag
           ,p_business_group_id     =>   p_rec.business_group_id
           ,p_legislation_code      =>   p_rec.legislation_code
           ,p_object_version_number =>   p_rec.object_version_number
           ,p_effective_date        =>   trunc(sysdate)
         ) ;



  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xcr_shd.g_rec_type) is
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
  chk_ext_crit_prfl_id
  (p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  ( p_ext_crit_prfl_id => p_rec.ext_crit_prfl_id
   ,p_name             => p_rec.name
   ,p_business_group_id => p_rec.business_group_id
   ,p_legislation_code  => p_rec.legislation_code
   ,p_object_version_number => p_rec.object_version_number);
  --

   chk_ext_global_flag
          ( p_ext_crit_prfl_id      =>   p_rec.ext_crit_prfl_id
           ,p_ext_global_flag       =>   p_rec.ext_global_flag
           ,p_business_group_id     =>   p_rec.business_group_id
           ,p_legislation_code      =>   p_rec.legislation_code
           ,p_object_version_number =>   p_rec.object_version_number
           ,p_effective_date        =>   trunc(sysdate)
         ) ;


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xcr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,ben_xcr_shd.g_old_rec.business_group_id
                    ,ben_xcr_shd.g_old_rec.legislation_code);
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
  (p_ext_crit_prfl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_crit_prfl b
    where b.ext_crit_prfl_id      = p_ext_crit_prfl_id
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
                             p_argument       => 'ext_crit_prfl_id',
                             p_argument_value => p_ext_crit_prfl_id);
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
end ben_xcr_bus;

/
