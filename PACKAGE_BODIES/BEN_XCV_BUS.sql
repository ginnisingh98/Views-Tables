--------------------------------------------------------
--  DDL for Package Body BEN_XCV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCV_BUS" as
/* $Header: bexcvrhi.pkb 120.3 2006/04/11 11:18:40 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcv_bus.';  -- Global package name


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
  (p_ext_crit_val_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , ben_ext_crit_val xcv
     where xcv.ext_crit_val_id = p_ext_crit_val_id
       and pbg.business_group_id = xcv.business_group_id;
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
    ,p_argument           => 'ext_crit_val_id'
    ,p_argument_value     => p_ext_crit_val_id
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
-- |------< chk_ext_crit_val_id >------|
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
--   ext_crit_val_id PK of record being inserted or updated.
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
Procedure chk_ext_crit_val_id(p_ext_crit_val_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_val_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcv_shd.api_updating
    (p_ext_crit_val_id                => p_ext_crit_val_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_val_id,hr_api.g_number)
     <>  ben_xcv_shd.g_old_rec.ext_crit_val_id) then
    --
    -- raise error as PK has changed
    --
    ben_xcv_shd.constraint_error('BEN_EXT_CRIT_VAL_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_crit_val_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xcv_shd.constraint_error('BEN_EXT_CRIT_VAL_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_crit_val_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_crit_typ_id >------|
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
--   p_ext_crit_val_id PK
--   p_ext_crit_typ_id ID of FK column
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
Procedure chk_ext_crit_typ_id (p_ext_crit_val_id          in number,
                            p_ext_crit_typ_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_crit_typ a
    where  a.ext_crit_typ_id = p_ext_crit_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcv_shd.api_updating
     (p_ext_crit_val_id            => p_ext_crit_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_typ_id,hr_api.g_number)
     <> nvl(ben_xcv_shd.g_old_rec.ext_crit_typ_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_crit_typ_id value exists in ben_ext_crit_typ table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_crit_typ
        -- table.
        --
        ben_xcv_shd.constraint_error('BEN_EXT_CRIT_VAL_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_crit_typ_id;



Procedure chk_ext_crit_bg_id(p_ext_crit_val_id          in number,
                             p_ext_crit_bg_id           in number,
                             p_ext_crit_typ_id          in number,
                             p_business_group_id        in number,
                             p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_bg_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_business_groups_perf  a
    where  a.business_group_id  = p_ext_crit_bg_id ;

  cursor c2 is
  select ecp.ext_global_flag
  from ben_ext_crit_prfl ecp ,
       ben_ext_crit_typ  ect
  where  ect.ext_crit_typ_id = p_ext_crit_typ_id
   and   ect.ext_crit_prfl_id = ecp.ext_crit_prfl_id
  ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcv_shd.api_updating
     (p_ext_crit_val_id            => p_ext_crit_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_bg_id,hr_api.g_number)
     <> nvl(ben_xcv_shd.g_old_rec.ext_crit_bg_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_crit_typ_id value exists in ben_ext_crit_typ table
    --
    if p_ext_crit_bg_id is not null  and   p_ext_crit_bg_id <> p_business_group_id then
       open c1;
       --
       fetch c1 into l_dummy;
       if c1%notfound then
         --
         close c1;
         --
         -- raise error as FK does not relate to PK in ben_ext_crit_typ
         -- table.
         --
         ben_xcv_shd.constraint_error('BEN_EXT_CRIT_VAL_FK3');
        --
       end if;
       --
       close c1;
       l_dummy := null ;

       open c2 ;
       fetch c2 into l_dummy;
       close c2;
       if l_dummy  = 'N'  then
          fnd_message.set_name('BEN','BEN_92776_PARENT_REC_EXISTS');
          fnd_message.raise_error;
       end if ;
    end if;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_crit_bg_id;




--
-- ----------------------------------------------------------------------------
-- |------< chk_val_1 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks when a Criterion Value is inserted or updated, it is
--   valid for it's parent crit_typ_cd.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_val_1
--   p_ext_crit_val_id PK
--   p_ext_crit_typ_id ID of FK column
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
Procedure chk_val_1 (       p_val_1                    in varchar2,
                            p_ext_crit_val_id          in number,
                            p_ext_crit_typ_id          in number,
                            p_effective_date           in date,
                            p_business_group_id        in number,
                            p_ext_crit_bg_id           in number,
                            p_legislation_code	       in varchar2,
                            p_object_version_number    in number ,
                            p_val_2                    in varchar2
                            ) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_1';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_crit_typ_cd varchar2(30);
  l_number       number;
  --
  cursor c1 is
    select a.crit_typ_cd
    from   ben_ext_crit_typ a
    where  a.ext_crit_typ_id = p_ext_crit_typ_id;
  --
  cursor c2 (p_business_group_id number)  is
    select null
    from   per_all_people_f per
    where  per.person_id = l_number
           and p_effective_date between per.effective_start_date
               and per.effective_end_date
           and per.business_group_id = p_business_group_id;
  --
  cursor c3 (p_business_group_id number)  is
    select null
    from  hr_all_organization_units_vl  org
    where org.organization_id = l_number
      and org.internal_external_flag = 'INT'
      and p_effective_date between org.date_from
               and nvl(org.date_to,p_effective_date)
      and org.business_group_id = p_business_group_id;
  --
  cursor c4 is
    select null
    from  hr_locations loc
    where loc.location_id = l_number
      and p_effective_date <= nvl(loc.inactive_date,p_effective_date);
  --
  cursor c5 (p_business_group_id number)  is
    select null
    from  hr_tax_units_v gre
    where gre.tax_unit_id = l_number
      and p_effective_date between gre.date_from
               and nvl(gre.date_to,p_effective_date)
      and gre.business_group_id = p_business_group_id;
  --
  cursor c6 (p_business_group_id number) is
    select null
    from   ben_pl_f pln
    where  pln.pl_id = l_number
           and p_effective_date between pln.effective_start_date
               and pln.effective_end_date
           and pln.business_group_id = p_business_group_id;
  --
  cursor c7 (p_business_group_id number) is
    select null
    from   ben_benfts_grp bgr
    where  bgr.benfts_grp_id = l_number
           and bgr.business_group_id = p_business_group_id;
  --
  cursor c8 (p_business_group_id number) is
    select null
    from   per_assignment_status_types ast
    where  ast.assignment_status_type_id = l_number
       and ast.active_flag = 'Y'
    ;
  /*
       and ((ast.business_group_id is null and ast.legislation_code is null)
             or (ast.legislation_code is not null
	   	    and ast.legislation_code = p_legislation_code)
             or (ast.business_group_id is not null
	            and ast.business_group_id = p_business_group_id)
           );
  */


--           and nvl(ast.business_group_id,p_business_group_id) = p_business_group_id;
           -- need to somehow add legislation code to this cursor.
  --
  cursor c9 is
    select null
    from   ben_ext_crit_typ a,
           ben_ext_crit_val b
    where  a.ext_crit_typ_id = b.ext_crit_typ_id
      and  a.ext_crit_typ_id = p_ext_crit_typ_id
      and  b.val_1 = p_val_1;


  cursor c10 is
    select null
    from   pay_event_groups
    where  event_group_id  = p_val_1
     ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcv_shd.api_updating
     (p_ext_crit_val_id            => p_ext_crit_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_val_1,hr_api.g_varchar2)
     <> nvl(ben_xcv_shd.g_old_rec.val_1,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    -- val_1 is mandatory
    --
    open c1;
      -- won't fail because already checked in above edit.
      fetch c1 into l_crit_typ_cd;
      --
    close c1;
    if l_crit_typ_cd = 'PPC' and p_val_1 is null then
      --
      fnd_message.set_name('BEN','BEN_91910_EXT_VAL1_RQD');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    -- numeric check for those that store foreign keys
    --
    if l_crit_typ_cd in ('PID','POR','PLO','PLE','BPL','PBG','PAS') then
      begin
      l_number := to_number(p_val_1);
      exception
        when invalid_number then
          fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
          fnd_message.raise_error;
      end;
    end if;
    --
    if l_crit_typ_cd = 'PID' then
      --
      open c2 (nvl(p_ext_crit_bg_id,p_business_group_id ) ) ;
      fetch c2 into l_dummy;
      if c2%notfound then
        close c2;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c2;
    --
    elsif l_crit_typ_cd = 'PST' then
      --
      -- check if value of lookup falls within lookup type.
      --
      if p_business_group_id is not null then
      /* BG is set, so use the existing call, with no modifications*/
              if hr_api.not_exists_in_hr_lookups
                  (p_lookup_type    => 'US_STATE',
                   p_lookup_code    => p_val_1,
                   p_effective_date => p_effective_date) then
                --
                -- raise error as does not exist as lookup
                --
                fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                fnd_message.set_token('FIELD','p_val_1');
                fnd_message.set_name('TYPE','US_STATE');
                fnd_message.raise_error;
              --
              end if;
      else
      /* BG is null, so alternative call is required */
              if not_exists_in_hrstanlookups
                  (p_lookup_type    => 'US_STATE',
                   p_lookup_code    => p_val_1,
                   p_effective_date => p_effective_date) then
                --
                -- raise error as does not exist as lookup
                --
                fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                fnd_message.set_token('FIELD','p_val_1');
                fnd_message.set_name('TYPE','US_STATE');
                fnd_message.raise_error;
              --
              end if;
      end if;
    --
    elsif l_crit_typ_cd = 'PPC' then

      -- Postal Code is not edited, not even for numeric because
      -- Canada has letters in it's postal code.
      null;

    elsif l_crit_typ_cd = 'POR' then
      --
      open c3 (nvl(p_ext_crit_bg_id,p_business_group_id ) );
      fetch c3 into l_dummy;
      if c3%notfound then
        close c3;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c3;
      --
    elsif l_crit_typ_cd = 'PLO' then
      --
      open c4;
      fetch c4 into l_dummy;
      if c4%notfound then
        close c4;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c4;
      --
    elsif l_crit_typ_cd = 'PLE' then
      --
      open c5(nvl(p_ext_crit_bg_id,p_business_group_id ) );
      fetch c5 into l_dummy;
      if c5%notfound then
        close c5;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c5;
      --
    elsif l_crit_typ_cd = 'BPL' then
      --
      open c6(nvl(p_ext_crit_bg_id,p_business_group_id ) );
      fetch c6 into l_dummy;
      if c6%notfound then
        close c6;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c6;


  elsif l_crit_typ_cd = 'CELT' then
      --
      -- check if value of lookup falls within lookup type.
      --
      if p_business_group_id is not null then
      /* BG is set, so use the existing call, with no modifications*/
            if hr_api.not_exists_in_hr_lookups
                (p_lookup_type    => 'BEN_EXT_CHG_TYP',
                 p_lookup_code    => p_val_1,
                 p_effective_date => p_effective_date) then
              --
              -- raise error as does not exist as lookup
              --
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              -- Commented for Bug 2493525
                /* fnd_message.set_token('FIELD','p_val_1');
                fnd_message.set_name('TYPE','BEN_EXT_CHG_TYP'); */

                fnd_message.set_token('VALUE',p_val_1);
                fnd_message.set_token('FIELD','Value');
                fnd_message.set_token('TYPE','BEN_EXT_CHG_TYP');
              -- End of Bug 2493525
              fnd_message.raise_error;
              --
            end if;
      else
   /* BG is null, so alternative call is required */
            if not_exists_in_hrstanlookups
                (p_lookup_type    => 'BEN_EXT_CHG_TYP',
                 p_lookup_code    => p_val_1,
                 p_effective_date => p_effective_date) then
              --
              -- raise error as does not exist as lookup
              --
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              -- Commented for Bug 2493525
                /* fnd_message.set_token('FIELD','p_val_1');
                fnd_message.set_name('TYPE','BEN_EXT_CHG_TYP'); */

                fnd_message.set_token('VALUE',p_val_1);
                fnd_message.set_token('FIELD','Value');
                fnd_message.set_token('TYPE','BEN_EXT_CHG_TYP');
              -- End of Bug 2493525
              fnd_message.raise_error;
              --
            end if;
      end if;

      --
    elsif l_crit_typ_cd = 'CCE' then
      --
      -- check if value of lookup falls within lookup type.
      --
      if p_val_2 is null or p_val_2 = 'BEN' then
         if p_business_group_id is not null then
         /* BG is set, so use the existing call, with no modifications*/
               if hr_api.not_exists_in_hr_lookups
                   (p_lookup_type    => 'BEN_EXT_CHG_EVT',
                    p_lookup_code    => p_val_1,
                    p_effective_date => p_effective_date) then
                 --
                 -- raise error as does not exist as lookup
                 --
                 fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                 -- Commented for Bug 2493525
		/* fnd_message.set_token('FIELD','p_val_1');
		fnd_message.set_name('TYPE','BEN_EXT_CHG_EVT'); */

		fnd_message.set_token('VALUE',p_val_1);
	        fnd_message.set_token('FIELD','Value');
		fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
                 -- End of Bug 2493525
                 fnd_message.raise_error;
                 --
               end if;
         else
         /* BG is null, so alternative call is required */
               if not_exists_in_hrstanlookups
                   (p_lookup_type    => 'BEN_EXT_CHG_EVT',
                    p_lookup_code    => p_val_1,
                    p_effective_date => p_effective_date) then
                 --
                 -- raise error as does not exist as lookup
                 --
                 fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
                 -- Commented for Bug 2493525
   		/* fnd_message.set_token('FIELD','p_val_1');
   		fnd_message.set_name('TYPE','BEN_EXT_CHG_EVT'); */

		fnd_message.set_token('VALUE',p_val_1);
	        fnd_message.set_token('FIELD','Value');
		fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
                 -- End of Bug 2493525
                 fnd_message.raise_error;
                 --
               end if;
         end if;
      elsif  p_val_2 = 'PAY' then

          open c10 ;
          fetch c10 into l_dummy ;
          if c10%notfound then
             close c10 ;
             fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
             fnd_message.raise_error;
          end if ;

          close c10 ;


      end if ;
      --
    elsif l_crit_typ_cd = 'PBG' then
      --
      open c7(nvl(p_ext_crit_bg_id,p_business_group_id ) );
      fetch c7 into l_dummy;
      if c7%notfound then
        close c7;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c7;
      --
    elsif l_crit_typ_cd = 'PAS' then
      --
      open c8(nvl(p_ext_crit_bg_id,p_business_group_id ) );
      fetch c8 into l_dummy;
      if c8%notfound then
        close c8;
        fnd_message.set_name('BEN','BEN_91911_EXT_INVLD_VAL1');
        fnd_message.raise_error;
      end if;
      close c8;
      --
    end if;
    --
    -- make sure val_1 is unique within parent crit_typ_cd.
    --
    if l_crit_typ_cd = 'PPC' then
    open c9;
    fetch c9 into l_dummy;
    if c9%found then
      close c9;
      fnd_message.set_name('BEN','BEN_91912_EXT_VAL1_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
    close c9;
    --
    end if;

    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_val_1;
-- ----------------------------------------------------------------------------
-- |------< chk_val_2 >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks when a Criterion Value is inserted or updated, it is
--   valid for it's parent crit_typ_cd.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_val_2
--   p_ext_crit_val_id PK
--   p_ext_crit_typ_id ID of FK column
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
Procedure chk_val_2 (       p_val_2                    in varchar2,
			    p_val_1			in varchar2,
                            p_ext_crit_val_id          in number,
                            p_ext_crit_typ_id          in number,
                            p_effective_date           in date,
                            p_business_group_id        in number,
                            p_ext_crit_bg_id           in number,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_2';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_crit_typ_cd varchar2(30);
  --
  cursor c1 is
    select a.crit_typ_cd
    from   ben_ext_crit_typ a
    where  a.ext_crit_typ_id = p_ext_crit_typ_id;
  --
  cursor c2 is
    select null
    from   ben_ext_crit_typ a,
           ben_ext_crit_val b
    where  a.ext_crit_typ_id = b.ext_crit_typ_id
      and  a.ext_crit_typ_id = p_ext_crit_typ_id
      and  b.val_2 = p_val_2;
  --
  cursor c3 is
    select null
    from   ben_ext_crit_typ a,
           ben_ext_crit_val b
    where  a.ext_crit_typ_id = b.ext_crit_typ_id
      and  a.ext_crit_typ_id = p_ext_crit_typ_id
      and  b.val_1 = p_val_1
      and  b.val_2 = p_val_2;
  Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcv_shd.api_updating
     (p_ext_crit_val_id            => p_ext_crit_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_val_2,hr_api.g_varchar2)
     <> nvl(ben_xcv_shd.g_old_rec.val_2,hr_api.g_varchar2)
     or not l_api_updating) then
    --
    open c1;
      -- won't fail because already checked in above edit.
      fetch c1 into l_crit_typ_cd;
      --
    close c1;
    --
    -- val_2 is currently only valid with parent crit_typ_cd = PPC
    --
    /*if p_val_2 is not null and l_crit_typ_cd <> 'PPC' then
    --
        fnd_message.set_name('BEN','BEN_91913_EXT_INVLD_VAL2');
        fnd_message.raise_error;
    --
    end if;*/
    --
    -- make sure val_2 is unique within parent crit_typ_cd.
    --
   if l_crit_typ_cd = 'PPC' then
    open c2;
    fetch c2 into l_dummy;
    if c2%found then
      close c2;
      fnd_message.set_name('BEN','BEN_91914_EXT_VAL2_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
    close c2;
   elsif l_crit_typ_cd = 'REE' then
    open c3;
    fetch c3 into l_dummy;
    if c3%found then
      close c3;
      fnd_message.set_name('BEN','BEN_91982_EXT_VAL_NOT_UNIQUE');
      fnd_message.raise_error;
    end if;
    close c3;
    --
   end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_val_2;
-- ----------------------------------------------------------------------------
-- |------< chk_val_dpndcy >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks the dependency between val_1 and val_2, specifically:
--        if val_2 exists it must be greater than val_1.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_val_1
--   p_val_2
--   p_ext_crit_val_id PK
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
Procedure chk_val_dpndcy (
                            p_val_1                    in varchar2,
                            p_val_2                    in varchar2,
                            p_ext_crit_val_id          in number,
                            p_ext_crit_typ_id          in number,
                            p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val_dpndcy';
  l_api_updating boolean;
  --
 l_crit_typ_cd	varchar2(30);
  cursor c1 is
    select a.crit_typ_cd
    from   ben_ext_crit_typ a
    where  a.ext_crit_typ_id = p_ext_crit_typ_id;
  --
  Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcv_shd.api_updating
     (p_ext_crit_val_id            => p_ext_crit_val_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and
     (nvl(p_val_1,hr_api.g_varchar2)
     <> nvl(ben_xcv_shd.g_old_rec.val_1,hr_api.g_varchar2) or
     nvl(p_val_2,hr_api.g_varchar2)
     <> nvl(ben_xcv_shd.g_old_rec.val_2,hr_api.g_varchar2))
     or not l_api_updating) then
    --
    open c1;
      fetch c1 into l_crit_typ_cd;
      --
    close c1;
    -- val_2 must be > val_1.
    --
    if l_crit_typ_cd = 'REE' and p_val_2 is not null and p_val_1 is null then
      --
      fnd_message.set_name('BEN','BEN_91910_EXT_VAL1_RQD');
      fnd_message.raise_error;
      --
    end if;
    if l_crit_typ_cd = 'PPC' and p_val_2 is not null and p_val_1 >= p_val_2 then
    --
        fnd_message.set_name('BEN','BEN_91915_EXT_VAL1_GT_VAL2');
        fnd_message.raise_error;
    --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_val_dpndcy;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xcv_shd.g_rec_type
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
  chk_ext_crit_val_id
  (p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_typ_id
  (p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_1
  (p_val_1                    => p_rec.val_1,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_effective_date           => p_effective_date,
   p_business_group_id        => p_rec.business_group_id,
   p_ext_crit_bg_id           => p_rec.ext_crit_bg_id,
   p_legislation_code	      => p_rec.legislation_code,
   p_object_version_number    => p_rec.object_version_number,
   p_val_2                    => p_rec.val_2
   );
  --
  chk_val_2
  (p_val_2                    => p_rec.val_2,
  p_val_1                    => p_rec.val_1,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_effective_date           => p_effective_date,
   p_business_group_id        => p_rec.business_group_id,
   p_ext_crit_bg_id           => p_rec.ext_crit_bg_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_val_dpndcy
  (p_val_1                    => p_rec.val_1,
   p_val_2                    => p_rec.val_2,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_ext_crit_bg_id(p_ext_crit_val_id        => p_rec.ext_crit_val_id,
                     p_ext_crit_bg_id         => p_rec.ext_crit_bg_id,
                     p_ext_crit_typ_id        => p_rec.ext_crit_typ_id,
                     p_business_group_id      => p_rec.business_group_id,
                     p_object_version_number  => p_rec.object_version_number)
                     ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xcv_shd.g_rec_type
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
  chk_ext_crit_val_id
  (p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_typ_id
  (p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val_1
  (p_val_1                    => p_rec.val_1,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_effective_date           => p_effective_date,
   p_business_group_id        => p_rec.business_group_id,
   p_ext_crit_bg_id           => p_rec.ext_crit_bg_id   ,
   p_legislation_code	      => p_rec.legislation_code,
   p_object_version_number    => p_rec.object_version_number,
   p_val_2                    => p_rec.val_2
   );
  --
  chk_val_2
  (p_val_2                    => p_rec.val_2,
  p_val_1                    => p_rec.val_1,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_effective_date           => p_effective_date,
   p_business_group_id        => p_rec.business_group_id,
   p_ext_crit_bg_id           => p_rec.ext_crit_bg_id,
   p_object_version_number    => p_rec.object_version_number);
  --
  chk_val_dpndcy
  (p_val_1                    => p_rec.val_1,
   p_val_2                    => p_rec.val_2,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_ext_crit_typ_id          => p_rec.ext_crit_typ_id,
   p_object_version_number    => p_rec.object_version_number);
  --
    --
  chk_ext_crit_bg_id(p_ext_crit_val_id        => p_rec.ext_crit_val_id,
                     p_ext_crit_bg_id         => p_rec.ext_crit_bg_id,
                     p_ext_crit_typ_id        => p_rec.ext_crit_typ_id,
                     p_business_group_id      => p_rec.business_group_id,
                     p_object_version_number  => p_rec.object_version_number)
                     ;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xcv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,ben_xcv_shd.g_old_rec.business_group_id
                    ,ben_xcv_shd.g_old_rec.legislation_code);
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
  (p_ext_crit_val_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups_perf  a,
           ben_ext_crit_val b
    where b.ext_crit_val_id      = p_ext_crit_val_id
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
                             p_argument       => 'ext_crit_val_id',
                             p_argument_value => p_ext_crit_val_id);
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
end ben_xcv_bus;

/
