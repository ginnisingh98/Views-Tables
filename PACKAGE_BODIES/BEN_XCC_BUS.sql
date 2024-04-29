--------------------------------------------------------
--  DDL for Package Body BEN_XCC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCC_BUS" as
/* $Header: bexccrhi.pkb 120.1 2005/10/31 11:39:19 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcc_bus.';  -- Global package name

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
  (p_ext_crit_cmbn_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_crit_cmbn xcc
     where xcc.ext_crit_cmbn_id = p_ext_crit_cmbn_id
       and pbg.business_group_id = xcc.business_group_id;
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
    ,p_argument           => 'ext_crit_cmbn_id'
    ,p_argument_value     => p_ext_crit_cmbn_id
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
-- |------< chk_ext_crit_cmbn_id >------|
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
--   ext_crit_cmbn_id PK of record being inserted or updated.
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
Procedure chk_ext_crit_cmbn_id(p_ext_crit_cmbn_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_cmbn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_cmbn_id,hr_api.g_number)
     <>  ben_xcc_shd.g_old_rec.ext_crit_cmbn_id) then
    --
    -- raise error as PK has changed
    --
    ben_xcc_shd.constraint_error('BEN_EXT_CRIT_CMBN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_crit_cmbn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xcc_shd.constraint_error('BEN_EXT_CRIT_CMBN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_crit_cmbn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_crit_val_id >------|
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
--   p_ext_crit_cmbn_id PK
--   p_ext_crit_val_id ID of FK column
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
Procedure chk_ext_crit_val_id (p_ext_crit_cmbn_id          in number,
                            p_ext_crit_val_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_crit_val_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_crit_val a
    where  a.ext_crit_val_id = p_ext_crit_val_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xcc_shd.api_updating
     (p_ext_crit_cmbn_id            => p_ext_crit_cmbn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_val_id,hr_api.g_number)
     <> nvl(ben_xcc_shd.g_old_rec.ext_crit_val_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_crit_val_id value exists in ben_ext_crit_val table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_crit_val
        -- table.
        --
        ben_xcc_shd.constraint_error('BEN_EXT_CRIT_CMBN_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_crit_val_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_oper_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_cmbn_id PK of record being inserted or updated.
--   oper_cd Value of lookup code.
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
Procedure chk_oper_cd(p_ext_crit_cmbn_id                in number,
                            p_oper_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id		  in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oper_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_oper_cd
      <> nvl(ben_xcc_shd.g_old_rec.oper_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_EXT_TTL_COND_OPER',
               p_lookup_code    => p_oper_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_oper_cd');
          fnd_message.set_token('TYPE','OPERATOR');
          fnd_message.raise_error;
          --
        end if;
    else
    /* BG is null, so alternative call is required */
        if hr_api.not_exists_in_hrstanlookups
              (p_lookup_type    => 'BEN_EXT_TTL_COND_OPER',
               p_lookup_code    => p_oper_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_oper_cd');
          fnd_message.set_token('TYPE','OPERATOR');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if; /* (l_api_updating... */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_oper_cd;
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
--   ext_crit_cmbn_id PK of record being inserted or updated.
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
Procedure chk_crit_typ_cd(p_ext_crit_cmbn_id                in number,
                            p_crit_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id		  in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crit_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_crit_typ_cd
      <> nvl(ben_xcc_shd.g_old_rec.crit_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
        --
        -- check if value of lookup falls within lookup type.
        --
        --
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_EXT_CRIT_TYP',
               p_lookup_code    => p_crit_typ_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_crit_typ_cd');
          fnd_message.set_token('TYPE','BEN_EXT_CRIT_TYP');
          fnd_message.raise_error;
          --
        end if;
    else
    /* BG is null, so alternative call is required */
        --
        -- check if value of lookup falls within lookup type.
        --
        --
        if hr_api.not_exists_in_hrstanlookups
              (p_lookup_type    => 'BEN_EXT_CRIT_TYP',
               p_lookup_code    => p_crit_typ_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_crit_typ_cd');
          fnd_message.set_token('TYPE','BEN_EXT_CRIT_TYP');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if; /* (l_api_updating...  */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crit_typ_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_crit_date >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if criteria is date, then
--   operator is '=' or 'between'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_cmbn_id PK of record being inserted or updated.
--   crit_typ_cd Value of lookup code.
--   oper_cd operator code
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
Procedure chk_crit_date(p_ext_crit_cmbn_id            in number,
                        p_crit_typ_cd                 in varchar2,
                        p_oper_cd                     in varchar2,
                        p_effective_date              in date,
                        p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crit_date';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (p_oper_cd
             <> nvl(ben_xcc_shd.g_old_rec.oper_cd,hr_api.g_varchar2)
           or p_crit_typ_cd
             <> nvl(ben_xcc_shd.g_old_rec.crit_typ_cd, hr_api.g_varchar2)
          )
      or not l_api_updating) then
    --
    -- check if criteria is date then operator is '=' or 'between'
    --
      --
      if p_crit_typ_cd = 'CAD' or p_crit_typ_cd = 'CED' then
        if p_oper_cd <> 'EQ' and p_oper_cd <> 'BE' then
          fnd_message.set_name('BEN','BEN_92173_CRIT_DT_OPER_EQ_BET');
          fnd_message.raise_error;
        end if;
      --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crit_date;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_crit_chg_evt >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if criteria is change event, then
--   operator is '=' or '!='
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_cmbn_id PK of record being inserted or updated.
--   crit_typ_cd Value of lookup code.
--   oper_cd operator code
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
Procedure chk_crit_chg_evt(p_ext_crit_cmbn_id            in number,
                           p_crit_typ_cd                 in varchar2,
                           p_oper_cd                     in varchar2,
                           p_val_1                       in varchar2,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_crit_chg_evt';
  l_api_updating boolean;
  --

  cursor c1 is
  select 'x' from
  hr_lookups where
  lookup_type = 'BEN_EXT_CHG_EVT'
  and lookup_code =  p_val_1
  ;


  cursor c2 is
  select 'x' from
  pay_event_groups  where
  event_group_id  =  p_val_1
  ;

  l_dummy varchar2(1) ;

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and (p_oper_cd
             <> nvl(ben_xcc_shd.g_old_rec.oper_cd,hr_api.g_varchar2)
           or
           p_crit_typ_cd
             <> nvl(ben_xcc_shd.g_old_rec.crit_typ_cd,hr_api.g_varchar2)
          )
      or not l_api_updating) then
    --
    -- check if criteria is change event then operator is '=' or '<>'
    --
      --
      if p_crit_typ_cd in ( 'CCE' , 'CPE')  then
        if p_oper_cd <> 'EQ' and p_oper_cd <> 'NE' then
          fnd_message.set_name('BEN','BEN_92174_CRIT_CHG_OPER_EQ_NEQ');
          fnd_message.raise_error;
        end if;
      --
      end if;


       if p_crit_typ_cd  = 'CCE'   then

           open c1 ;
           fetch c1 into l_dummy  ;
           if c1%notfound then
              close c1 ;
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              fnd_message.set_token('FIELD','Value 1');
              fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
              fnd_message.raise_error;
           end if ;
           close c1 ;
       end if ;

       if p_crit_typ_cd =  'CPE'  then

           open c2 ;
           fetch c2 into l_dummy ;
           if c2%notfound then
              close c2 ;
              fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
              fnd_message.set_token('FIELD','Value 1');
              fnd_message.set_token('TYPE','BEN_EXT_CHG_EVT');
              fnd_message.raise_error;
           end if ;
           close c2 ;
       end if ;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crit_chg_evt;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_oper_between >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if operator is between , then
--   value 1 and value 2 are not null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_cmbn_id PK of record being inserted or updated.
--   oper_cd operator code
--   val_1 value 1
--   val_2 value 2
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
Procedure chk_oper_between(p_ext_crit_cmbn_id            in number,
                           p_oper_cd                     in varchar2,
                           p_val_1                       in varchar2,
                           p_val_2                       in varchar2,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oper_between';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and ((p_oper_cd
      <> nvl(ben_xcc_shd.g_old_rec.oper_cd,hr_api.g_varchar2))
       or (p_val_1 <> nvl(ben_xcc_shd.g_old_rec.val_1, hr_api.g_varchar2))
       or (p_val_2 <> nvl(ben_xcc_shd.g_old_rec.val_2, hr_api.g_varchar2))
     ))
      or not l_api_updating then
    --
    -- check if operator is between then val_1 and val_2 are not null
    --
      --
      if p_oper_cd = 'BE' then
        if p_val_1 is null or p_val_2 is null then
          fnd_message.set_name('BEN','BEN_92175_OPER_BET_VAL_NULL');
          fnd_message.raise_error;
        end if;
      --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_oper_between;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_oper_eq_neq >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if operator is '=' or '!=', then
--   value 1 is not null and value 2 is null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_crit_cmbn_id PK of record being inserted or updated.
--   oper_cd operator code
--   val_1 value 1
--   val_2 value 2
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
Procedure chk_oper_eq_neq(p_ext_crit_cmbn_id            in number,
                          p_oper_cd                     in varchar2,
                          p_val_1                       in varchar2,
                          p_val_2                       in varchar2,
                          p_effective_date              in date,
                          p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oper_eq_neq';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xcc_shd.api_updating
    (p_ext_crit_cmbn_id                => p_ext_crit_cmbn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and ((p_oper_cd
      <> nvl(ben_xcc_shd.g_old_rec.oper_cd,hr_api.g_varchar2))
       or (p_val_1 <> nvl(ben_xcc_shd.g_old_rec.val_1, hr_api.g_varchar2))
       or (p_val_2 <> nvl(ben_xcc_shd.g_old_rec.val_2, hr_api.g_varchar2))
     ))
      or not l_api_updating then
    --
    -- check if operator is between then val_1 and val_2 are not null
    --
      --
      if p_oper_cd = 'EQ' or p_oper_cd = 'NE' then
        if p_val_1 is null or p_val_2 is not null then
          fnd_message.set_name('BEN','BEN_92176_OPER_EQ_NEQ_VAL');
          fnd_message.raise_error;
        end if;
      --
      end if;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_oper_eq_neq;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xcc_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_crit_cmbn_id
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_val_id
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_cd
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_oper_cd         => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id	   => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_typ_cd
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd         => p_rec.crit_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id	   => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_date
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd           => p_rec.crit_typ_cd,
   p_oper_cd               => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_chg_evt
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd           => p_rec.crit_typ_cd,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_between
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_val_2                 => p_rec.val_2,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_eq_neq
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_val_2                 => p_rec.val_2,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xcc_shd.g_rec_type
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
  chk_ext_crit_cmbn_id
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_val_id
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_ext_crit_val_id          => p_rec.ext_crit_val_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_cd
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_oper_cd         => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id	   => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_typ_cd
  (p_ext_crit_cmbn_id          => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd         => p_rec.crit_typ_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id	   => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_date
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd           => p_rec.crit_typ_cd,
   p_oper_cd               => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_crit_chg_evt
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_crit_typ_cd           => p_rec.crit_typ_cd,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_between
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_val_2                 => p_rec.val_2,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_eq_neq
  (p_ext_crit_cmbn_id      => p_rec.ext_crit_cmbn_id,
   p_oper_cd               => p_rec.oper_cd,
   p_val_1                 => p_rec.val_1,
   p_val_2                 => p_rec.val_2,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xcc_shd.g_rec_type
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
                    ,ben_xcc_shd.g_old_rec.business_group_id
                    ,ben_xcc_shd.g_old_rec.legislation_code);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_ext_crit_cmbn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_crit_cmbn b
    where b.ext_crit_cmbn_id      = p_ext_crit_cmbn_id
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
                             p_argument       => 'ext_crit_cmbn_id',
                             p_argument_value => p_ext_crit_cmbn_id);
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
end ben_xcc_bus;

/
