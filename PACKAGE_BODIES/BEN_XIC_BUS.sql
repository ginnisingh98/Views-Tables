--------------------------------------------------------
--  DDL for Package Body BEN_XIC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XIC_BUS" as
/* $Header: bexicrhi.pkb 120.2 2006/03/20 13:02:22 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xic_bus.';  -- Global package name
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |----------------------< not_exists_in_hr_lookups >------------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_hr_lookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists     varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_hr_look is
    select null
      from hr_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
  if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;
  hr_utility.set_location(hr_api.g_package||'not_exists_in_hr_lookups', 10);
  --
  open csr_hr_look;
  fetch csr_hr_look into l_exists;
  if csr_hr_look%notfound then
    close csr_hr_look;
    return true;
  else
    close csr_hr_look;
    return false;
  end if;
end not_exists_in_hr_lookups;
--
-- ----------------------------------------------------------------------------
-- |---------------------< not_exists_in_hrstanlookups >----------------------|
-- ----------------------------------------------------------------------------
--
function not_exists_in_hrstanlookups
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return boolean is
  --
  -- Declare Local Variables
  --
  l_exists  varchar2(1);
  --
  -- Declare Local cursors
  --
  cursor csr_hr_look is
    select null
      from hr_standard_lookups
     where lookup_code  = p_lookup_code
       and lookup_type  = p_lookup_type
       and p_effective_date between
               nvl(start_date_active, p_effective_date)
           and nvl(end_date_active, p_effective_date);
  --
begin
  --
  -- When the lookup_type is YES_NO attempt to validate without
  -- executing the cursor. This is to reduce checking time for
  -- valid values in row handlers which have a lot of Yes No flags.
  --
    if p_lookup_type = 'YES_NO' then
    if p_lookup_code = 'Y' or p_lookup_code = 'N' then
      return false;
    end if;
    -- If the value is not known then go onto check against the
    -- hr_lookups view. Just in case there has been a change to
    -- the system defined lookup.
  end if;
  hr_utility.set_location(hr_api.g_package||'not_exists_in_hrstanlookups', 10);
  --
  open csr_hr_look;
  fetch csr_hr_look into l_exists;
  if csr_hr_look%notfound then
    close csr_hr_look;
    return true;
  else
    close csr_hr_look;
    return false;
  end if;

end not_exists_in_hrstanlookups;

--

Procedure set_security_group_id
  (p_ext_incl_chg_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , ben_ext_incl_chg xic
     where xic.ext_incl_chg_id = p_ext_incl_chg_id
       and pbg.business_group_id = xic.business_group_id;
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
    ,p_argument           => 'ext_incl_chg_id'
    ,p_argument_value     => p_ext_incl_chg_id
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
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_incl_chg_id >------|
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
--   ext_incl_chg_id PK of record being inserted or updated.
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
Procedure chk_ext_incl_chg_id(p_ext_incl_chg_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_incl_chg_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xic_shd.api_updating
    (p_ext_incl_chg_id                => p_ext_incl_chg_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_incl_chg_id,hr_api.g_number)
     <>  ben_xic_shd.g_old_rec.ext_incl_chg_id) then
    --
    -- raise error as PK has changed
    --
    ben_xic_shd.constraint_error('BEN_EXT_INCL_CHG_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_incl_chg_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xic_shd.constraint_error('BEN_EXT_INCL_CHG_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_incl_chg_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rcd_in_file_id >------|
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
--   p_ext_incl_chg_id PK
--   p_ext_rcd_in_file_id ID of FK column
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
Procedure chk_ext_rcd_in_file_id (p_ext_incl_chg_id          in number,
                            p_ext_rcd_in_file_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rcd_in_file_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_rcd_in_file a
    where  a.ext_rcd_in_file_id = p_ext_rcd_in_file_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xic_shd.api_updating
     (p_ext_incl_chg_id            => p_ext_incl_chg_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_in_file_id,hr_api.g_number)
     <> nvl(ben_xic_shd.g_old_rec.ext_rcd_in_file_id,hr_api.g_number)
     or not l_api_updating) and
     p_ext_rcd_in_file_id is not null then
    --
    -- check if ext_rcd_in_file_id value exists in ben_ext_rcd_in_file table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_rcd_in_file
        -- table.
        --
        ben_xic_shd.constraint_error('BEN_EXT_INCL_CHG_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_rcd_in_file_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_data_elmt_in_rcd_id >------|
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
--   p_ext_incl_chg_id PK
--   p_ext_data_elmt_in_rcd_id ID of FK column
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
Procedure chk_ext_data_elmt_in_rcd_id (p_ext_incl_chg_id          in number,
                            p_ext_data_elmt_in_rcd_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_data_elmt_in_rcd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_data_elmt_in_rcd a
    where  a.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xic_shd.api_updating
     (p_ext_incl_chg_id            => p_ext_incl_chg_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_in_rcd_id,hr_api.g_number)
     <> nvl(ben_xic_shd.g_old_rec.ext_data_elmt_in_rcd_id,hr_api.g_number)
     or not l_api_updating) and
     p_ext_data_elmt_in_rcd_id is not null then
    --
    -- check if ext_data_elmt_in_rcd_id value exists in ben_ext_data_elmt_in_rcd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_data_elmt_in_rcd
        -- table.
        --
        ben_xic_shd.constraint_error('BEN_EXT_INCL_CHG_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_data_elmt_in_rcd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_chg_evt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_incl_chg_id PK of record being inserted or updated.
--   chg_evt_cd Value of lookup code.
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
Procedure chk_chg_evt_cd(p_ext_incl_chg_id            in number,
			p_ext_rcd_in_file_id	      in number,
			p_ext_data_elmt_in_rcd_id     in number,
                        p_chg_evt_cd                  in varchar2,
                        p_chg_evt_source              in varchar2,
                        p_effective_date              in date,
                        p_business_group_id           in number,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_chg_evt_cd';
  l_api_updating boolean;
  --
  cursor c1 is select sprs_cd
  from ben_ext_rcd_in_file
  where ext_rcd_in_file_id = p_ext_rcd_in_file_id;
  cursor c2 is select sprs_cd
  from ben_ext_data_elmt_in_rcd
  where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

 cursor c3 is
 select 'x'
 from pay_event_groups
 where event_group_id = p_chg_evt_cd
  ;
 l_dummy varchar2(1) ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Inside .hrstanlookups..'||l_proc||' '||p_chg_evt_cd, 8);
  --
  l_api_updating := ben_xic_shd.api_updating
    (p_ext_incl_chg_id                => p_ext_incl_chg_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_chg_evt_cd
      <> nvl(ben_xic_shd.g_old_rec.chg_evt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_chg_evt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_chg_evt_source is null or p_chg_evt_source = 'BEN' then
       if p_business_group_id is not null then
         if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_CHG_EVT',
             p_lookup_code    => p_chg_evt_cd,
             p_effective_date => p_effective_date) then
           --
           -- raise error as does not exist as lookup
           --

           fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
           -- Commented for Bug 2493525
	        /*
		        fnd_message.set_token('FIELD','p_chg_evt_cd');
		        fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
		        */
		        fnd_message.set_token('VALUE',p_chg_evt_cd);
			fnd_message.set_token('FIELD','Value');
		fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
   	 -- End of Bug 2493525

           fnd_message.raise_error;
           --
         end if;
       --
       else
         if not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_CHG_EVT',
             p_lookup_code    => p_chg_evt_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --

           fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
         -- Commented for Bug 2493525
           /*
	        fnd_message.set_token('FIELD','p_chg_evt_cd');
	        fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
	        */
	        fnd_message.set_token('VALUE',p_chg_evt_cd);
		fnd_message.set_token('FIELD','Value');
         	fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
         	 -- End of Bug 2493525
           fnd_message.raise_error;
           --
         end if;
          --
       end if;
   end if ;
   --- pay roll change event
   if  p_chg_evt_source = 'PAY' then
       open c3 ;
       fetch c3 into l_dummy  ;
       if c3%notfound then
          close c3 ;
          fnd_message.set_token('VALUE',p_chg_evt_cd);
          fnd_message.set_token('FIELD','Value');
          fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
       end if ;
       close c3 ;

   end if ;
    --
  /*if p_ext_rcd_in_file_id is not null then
  for crec in c1 loop
   if (p_chg_evt_cd is null and crec.sprs_cd= 'C') or
   (p_chg_evt_cd is not null and crec.sprs_cd='A') then
         	fnd_message.set_name('BEN','BEN_91869_CHG_EVT_NULL');
         	fnd_message.raise_error;
	end if;
  end loop;
  end if;

  if p_ext_data_elmt_in_rcd_id is not null then
  for crec in c2 loop
   if (p_chg_evt_cd is null and crec.sprs_cd= 'C') or
   (p_chg_evt_cd is not null and crec.sprs_cd='A') then
         	fnd_message.set_name('BEN','BEN_91869_CHG_EVT_NULL');
         	fnd_message.raise_error;
	end if;
  end loop;
  end if;*/
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_chg_evt_cd;
--
--


Procedure chk_unique_chg_evt_cd(p_ext_incl_chg_id            in number,
			p_ext_rcd_in_file_id	      in number,
			p_ext_data_elmt_in_rcd_id     in number,
                        p_chg_evt_cd                  in varchar2,
                        p_chg_evt_source              in varchar2,
                        p_effective_date              in date,
                        p_business_group_id           in number,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_unique_chg_evt_cd';
  l_api_updating boolean;
  --
  cursor c1 is select 'x'
  from ben_ext_incl_chg
  where ext_rcd_in_file_id = p_ext_rcd_in_file_id
  and   chg_evt_cd = p_chg_evt_cd
  and   (p_ext_incl_chg_id <> ext_incl_chg_id or p_ext_incl_chg_id is null ) ;


   cursor c2 is select 'x'
  from ben_ext_incl_chg
  where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
  and   chg_evt_cd = p_chg_evt_cd
  and   (p_ext_incl_chg_id <> ext_incl_chg_id or p_ext_incl_chg_id is null ) ;
 l_dummy varchar2(1) ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('Inside .hrstanlookups..'||l_proc||' '||p_chg_evt_cd, 8);
  --
  if p_ext_rcd_in_file_id is not null then
     open c1 ;
     fetch  c1 into l_dummy  ;
     if  c1%found then
         close c1 ;
         fnd_message.set_name('BEN','BEN_91912_EXT_VAL1_NOT_UNIQUE');
       	 fnd_message.raise_error;
     end if ;
     close c1 ;

  end if ;

  if p_ext_data_elmt_in_rcd_id is not null then
     open c2 ;
     fetch  c2 into l_dummy  ;
     if  c2%found then
         close c2 ;
         fnd_message.set_name('BEN','BEN_91912_EXT_VAL1_NOT_UNIQUE');
       	 fnd_message.raise_error;

     end if ;
     close c2 ;
  end if ;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_unique_chg_evt_cd;
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xic_shd.g_rec_type
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
  chk_ext_incl_chg_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_in_file_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id          => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_in_rcd_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_chg_evt_cd
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id       =>p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id	=>p_rec.ext_data_elmt_in_rcd_id,
   p_chg_evt_cd               => p_rec.chg_evt_cd,
   p_chg_evt_source         => p_rec.chg_evt_source,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_unique_chg_evt_cd
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id       =>p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id	=>p_rec.ext_data_elmt_in_rcd_id,
   p_chg_evt_cd               => p_rec.chg_evt_cd,
   p_chg_evt_source         => p_rec.chg_evt_source,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xic_shd.g_rec_type
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
  chk_ext_incl_chg_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_in_file_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id          => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_in_rcd_id
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_chg_evt_cd
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id		=>p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id	=>p_rec.ext_data_elmt_in_rcd_id,
   p_chg_evt_cd         => p_rec.chg_evt_cd,
   p_chg_evt_source        => p_rec.chg_evt_source,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_unique_chg_evt_cd
  (p_ext_incl_chg_id          => p_rec.ext_incl_chg_id,
   p_ext_rcd_in_file_id       =>p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id	=>p_rec.ext_data_elmt_in_rcd_id,
   p_chg_evt_cd               => p_rec.chg_evt_cd,
   p_chg_evt_source         => p_rec.chg_evt_source,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xic_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(False
                    ,ben_xic_shd.g_old_rec.business_group_id
                    ,ben_xic_shd.g_old_rec.legislation_code);
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
  (p_ext_incl_chg_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select b.business_group_id
    from   ben_ext_incl_chg b
    where b.ext_incl_chg_id      = p_ext_incl_chg_id
    ;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_business_group_id number ;
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'ext_incl_chg_id',
                             p_argument_value => p_ext_incl_chg_id);
  --
  open csr_leg_code;
    --
    fetch csr_leg_code into l_business_group_id ;
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

    l_legislation_code  :=  hr_api.return_legislation_code(l_business_group_id) ;
    --
  close csr_leg_code;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
  return l_legislation_code;
  --
end return_legislation_code;
--
end ben_xic_bus;

/
