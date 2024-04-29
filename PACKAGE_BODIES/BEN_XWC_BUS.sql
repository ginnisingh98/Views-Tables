--------------------------------------------------------
--  DDL for Package Body BEN_XWC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XWC_BUS" as
/* $Header: bexwcrhi.pkb 120.3 2006/04/27 11:31:07 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xwc_bus.';  -- Global package name

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
  (p_ext_where_clause_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_where_clause xwc
     where xwc.ext_where_clause_id = p_ext_where_clause_id
       and pbg.business_group_id = xwc.business_group_id;
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
    ,p_argument           => 'ext_where_clause_id'
    ,p_argument_value     => p_ext_where_clause_id
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
-- |------< chk_ext_where_clause_id >------|
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
--   ext_where_clause_id PK of record being inserted or updated.
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
Procedure chk_ext_where_clause_id(p_ext_where_clause_id in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_where_clause_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xwc_shd.api_updating
    (p_ext_where_clause_id                => p_ext_where_clause_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_where_clause_id,hr_api.g_number)
     <>  ben_xwc_shd.g_old_rec.ext_where_clause_id) then
    --
    -- raise error as PK has changed
    --
    ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_where_clause_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_where_clause_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cond_ext_elmt_in_rcd_id >------|
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
--   p_ext_where_clause_id PK
--   p_cond_ext_data_elmt_in_rcd_id ID of FK column
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
Procedure chk_cond_ext_elmt_in_rcd_id (p_ext_where_clause_id          in number,
                            p_cond_ext_data_elmt_in_rcd_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cond_ext_elmt_in_rcd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_data_elmt_in_rcd a
    where  a.ext_data_elmt_in_rcd_id = p_cond_ext_data_elmt_in_rcd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xwc_shd.api_updating
     (p_ext_where_clause_id => p_ext_where_clause_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cond_ext_data_elmt_in_rcd_id,hr_api.g_number)
     <> nvl(ben_xwc_shd.g_old_rec.cond_ext_data_elmt_in_rcd_id,hr_api.g_number)
     or not l_api_updating) and
     p_cond_ext_data_elmt_in_rcd_id is not null then
    --
    -- check if cond_ext_data_elmt_in_rcd_id value exists in ben_ext_data_elmt_in_rcd table
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
        ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_FK6');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cond_ext_elmt_in_rcd_id;
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
--   p_ext_where_clause_id PK
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
Procedure chk_ext_rcd_in_file_id (p_ext_where_clause_id          in number,
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
  l_api_updating := ben_xwc_shd.api_updating
     (p_ext_where_clause_id => p_ext_where_clause_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_in_file_id,hr_api.g_number)
     <> nvl(ben_xwc_shd.g_old_rec.ext_rcd_in_file_id,hr_api.g_number)
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
        ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_FK4');
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
--   p_ext_where_clause_id PK
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
Procedure chk_ext_data_elmt_in_rcd_id (p_ext_where_clause_id          in number,
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
  l_api_updating := ben_xwc_shd.api_updating
     (p_ext_where_clause_id => p_ext_where_clause_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_in_rcd_id,hr_api.g_number)
     <> nvl(ben_xwc_shd.g_old_rec.ext_data_elmt_in_rcd_id,hr_api.g_number)
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
        ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_FK3');
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
-- |------< chk_cond_ext_data_elmt_id >------|
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
--   p_ext_where_clause_id PK
--   p_cond_ext_data_elmt_id ID of FK column
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
Procedure chk_cond_ext_data_elmt_id (p_ext_where_clause_id          in number,
                            p_cond_ext_data_elmt_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cond_ext_data_elmt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_data_elmt a
    where  a.ext_data_elmt_id = p_cond_ext_data_elmt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xwc_shd.api_updating
     (p_ext_where_clause_id => p_ext_where_clause_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cond_ext_data_elmt_id,hr_api.g_number)
     <> nvl(ben_xwc_shd.g_old_rec.cond_ext_data_elmt_id,hr_api.g_number)
     or not l_api_updating) and
     p_cond_ext_data_elmt_id is not null then
    --
    -- check if cond_ext_data_elmt_id value exists in ben_ext_data_elmt table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_data_elmt
        -- table.
        --
        ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_cond_ext_data_elmt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_data_elmt_id >------|
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
--   p_ext_where_clause_id PK
--   p_ext_data_elmt_id ID of FK column
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
Procedure chk_ext_data_elmt_id (p_ext_where_clause_id          in number,
                            p_ext_data_elmt_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_data_elmt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_data_elmt a
    where  a.ext_data_elmt_id = p_ext_data_elmt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xwc_shd.api_updating
     (p_ext_where_clause_id            => p_ext_where_clause_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_id,hr_api.g_number)
     <> nvl(ben_xwc_shd.g_old_rec.ext_data_elmt_id,hr_api.g_number)
     or not l_api_updating) and
     p_ext_data_elmt_id is not null then
    --
    -- check if ext_data_elmt_id value exists in ben_ext_data_elmt table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_data_elmt
        -- table.
        --
        ben_xwc_shd.constraint_error('BEN_EXT_WHERE_CLAUSE_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_data_elmt_id;
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
--   ext_where_clause_id PK of record being inserted or updated.
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
Procedure chk_oper_cd(p_ext_where_clause_id                in number,
                            p_oper_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_oper_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xwc_shd.api_updating
    (p_ext_where_clause_id                => p_ext_where_clause_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_oper_cd
      <> nvl(ben_xwc_shd.g_old_rec.oper_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_oper_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_EXT_OPER',
               p_lookup_code    => p_oper_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_oper_cd');
          fnd_message.set_token('TYPE','BEN_EXT_OPER');
          fnd_message.raise_error;
          --
        end if;
    else
    /* BG is null, so alternative call is required */
        if hr_api.not_exists_in_hrstanlookups
              (p_lookup_type    => 'BEN_EXT_OPER',
               p_lookup_code    => p_oper_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_oper_cd');
          fnd_message.set_token('TYPE','BEN_EXT_OPER');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if; /* if (l_api_updating... */
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_oper_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_and_or_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_where_clause_id PK of record being inserted or updated.
--   and_or_cd Value of lookup code.
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
Procedure chk_and_or_cd(p_ext_where_clause_id                in number,
                            p_and_or_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id		  in varchar2,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_and_or_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xwc_shd.api_updating
    (p_ext_where_clause_id                => p_ext_where_clause_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_and_or_cd
      <> nvl(ben_xwc_shd.g_old_rec.and_or_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_and_or_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    /* BG is set, so use the existing call, with no modifications*/
        if hr_api.not_exists_in_hr_lookups
              (p_lookup_type    => 'BEN_EXT_AND_OR',
               p_lookup_code    => p_and_or_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_and_or_cd');
          fnd_message.set_token('TYPE','BEN_EXT_AND_OR');
          fnd_message.raise_error;
          --
        end if;
    else
    /* BG is null, so alternative call is required */
        if hr_api.not_exists_in_hrstanlookups
              (p_lookup_type    => 'BEN_EXT_AND_OR',
               p_lookup_code    => p_and_or_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_and_or_cd');
          fnd_message.set_token('TYPE','BEN_EXT_AND_OR');
          fnd_message.raise_error;
          --
        end if;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_and_or_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the val is valid by running it
--     through a quick dynamic sql test.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_where_clause_id PK of record being inserted or updated.
--   and_or_cd Value of lookup code.
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
Procedure chk_val(p_ext_where_clause_id                in number,
                            p_oper_cd                     in varchar2,
                            p_val                         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_val';
  l_api_updating boolean;
  l_dynamic_condition varchar2(500);
  l_str   varchar2(2000) ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xwc_shd.api_updating
    (p_ext_where_clause_id                => p_ext_where_clause_id,
     p_object_version_number       => p_object_version_number);
  --
  if (
     (l_api_updating and (p_val <> nvl(ben_xwc_shd.g_old_rec.val,hr_api.g_varchar2))) or
     (l_api_updating and (p_oper_cd <> nvl(ben_xwc_shd.g_old_rec.oper_cd,hr_api.g_varchar2))) or
      not l_api_updating
      ) then


     ben_ext_adv_conditions.g_ext_adv_ct_validation  := 'N' ;
     ben_ext_adv_ct_check.chk_val
                    (p_ext_where_clause_id          => p_ext_where_clause_id,
                     p_oper_cd                      => p_oper_cd,
                     p_val                          => p_val,
                     p_effective_date               => p_effective_date
                    );

    if ben_ext_adv_conditions.g_ext_adv_ct_validation  = 'N' then


       --
       -- check if value of lookup falls within lookup type.
       --
       --  make sure the p_val string starts  with  '  or (
       --  make sure no function is callled from here

              if  not (substr( ltrim(rtrim(p_val)),1,1) = '''' or substr( ltrim(rtrim(p_val)),1,1) = '(' )  then
                 fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
              fnd_message.raise_error;
           end if ;

           --if the first string starts with ( then the second string should be  '
           -- to avoid ( tilak() )  kind
          if substr( ltrim(rtrim(p_val)),1,1) = '('  then
             if  substr( rtrim(ltrim( substr(ltrim(rtrim(p_val)),2)) ), 1,1)  <>  '''' then
                    fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
                 fnd_message.raise_error;
             end if ;
          end if ;

          -- make sure the last string also the ' or ) , between amy call with sceond string as function
          -- to avoid  '0000' and tilak() kind
          if  not (substr( ltrim(rtrim(p_val)), -1) = '''' or substr( ltrim(rtrim(p_val)),-1) = ')' )  then
              fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
              fnd_message.raise_error;
          end if ;

          -- to avoid '0000' and ( tilak () )  kind

          if  substr( ltrim(rtrim(p_val)),-1) = ')' then
              l_str := substr(rtrim(p_val), 1, length(rtrim(p_val)) -1 ) ;
              if substr( ltrim(rtrim(l_str)),-1) <> ''''   then
                  fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
                  fnd_message.raise_error;
              end if ;
          end if ;

          -- to avoid '0000' and tilak('xxxx')
          if  p_oper_cd = 'BETWEEN' then
           l_str  := ltrim( substr( p_val, instr(upper(p_val),'AND')+3)) ;

              if not (substr( ltrim(rtrim(l_str)),1,1) = '''' or substr( ltrim(rtrim(l_str)),1,1) = '(' )  then
                  fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
                  fnd_message.raise_error;
              end if ;

              -- to avoid ( tilak() )  kind
              if substr( ltrim(rtrim(l_str)),1,1) = '('  then
                 if substr( rtrim(ltrim( substr(ltrim(rtrim(l_str)),2)) ), 1,1)  <>  '''' then
                    fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
                    fnd_message.raise_error;
                 end if ;
              end if ;

          end if ;

          -- to avoid 'xxxx'||tilak()||'xxx'
          if  instr(p_val , '||')  > 0 then
              fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
              fnd_message.raise_error;
          end if ;

          l_dynamic_condition := 'Begin If ''TestValue '' ' || p_oper_cd || ' ' || p_val ||
           ' then null; end if; end;';

          begin
           execute immediate l_dynamic_condition;
          exception
            when others then
              fnd_message.set_name('BEN','BEN_92302_DYN_SQL_ERROR');
              fnd_message.raise_error;
          end;
     end if;
  end if ;
     --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_val;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dup_seq_no  >----------------------------|
-- ----------------------------------------------------------------------------
-- The proc is added in fixing 4658335
procedure chk_dup_seq_no(p_business_group_id   in number
                        ,p_legislation_code    in varchar2
                        ,p_ext_where_clause_id in number
                        ,p_ext_rcd_in_file_id  in number
                        ,p_ext_data_elmt_in_rcd_id in number
                        ,p_ext_data_elmt_id    in number
                        ,p_seq_num             in number
                        ,p_object_version_number in number) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_api_updating boolean;
--
 cursor c_xwc is
  SELECT null
  FROM ben_ext_where_clause xwc
  WHERE ( business_group_id is null
      or business_group_id = p_business_group_id )
  and (legislation_code is null
      or legislation_code = p_legislation_code )
  and (ext_rcd_in_file_id = p_ext_rcd_in_file_id
      or p_ext_rcd_in_file_id is null )
  and (ext_data_elmt_in_rcd_id  = p_ext_data_elmt_in_rcd_id
      or p_ext_data_elmt_in_rcd_id is null)
  and (ext_data_elmt_id = p_ext_data_elmt_id
      or p_ext_data_elmt_id is null)
  and seq_num = p_seq_num
  and (ext_where_clause_id <> p_ext_where_clause_id
      or p_ext_where_clause_id is null);
--
 l_dummy number ;
Begin
  --
  -- bug 4658335, check only when seq num is changed. or inserting
  l_api_updating := ben_xwc_shd.api_updating
    (p_ext_where_clause_id                => p_ext_where_clause_id,
     p_object_version_number              => p_object_version_number);
  --
  If (
     (l_api_updating and (p_seq_num <> nvl(ben_xwc_shd.g_old_rec.seq_num,hr_api.g_number))) or
      not l_api_updating
      ) then
    Open c_xwc;
    --
    Fetch c_xwc into l_Dummy;
    If c_xwc%FOUND then
       Close c_xwc ;
       -- Raise Sequence Error
       fnd_message.set_name('BEN','BEN_94223_DUP_ORDR_NUM');
       fnd_message.raise_error;
    End If;
    Close c_xwc;
  --
  End if;
--
end chk_dup_seq_no;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xwc_shd.g_rec_type
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
  chk_ext_where_clause_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cond_ext_elmt_in_rcd_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_cond_ext_data_elmt_in_rcd_id          => p_rec.cond_ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_in_file_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_rcd_in_file_id          => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_in_rcd_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cond_ext_data_elmt_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_cond_ext_data_elmt_id          => p_rec.cond_ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_cd
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_oper_cd         => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_and_or_cd
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_and_or_cd         => p_rec.and_or_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_oper_cd         => p_rec.oper_cd,
   p_val             => p_rec.val,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dup_seq_no
  (p_business_group_id       => p_rec.business_group_id,
   p_legislation_code        => p_rec.legislation_code,
   p_ext_where_clause_id     => p_rec.ext_where_clause_id,
   p_ext_rcd_in_file_id      => p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id => p_rec.ext_data_elmt_in_rcd_id ,
   p_ext_data_elmt_id        => p_rec.ext_data_elmt_id,
   p_seq_num                 => p_rec.seq_num,
   p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xwc_shd.g_rec_type
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
  chk_ext_where_clause_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cond_ext_elmt_in_rcd_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_cond_ext_data_elmt_in_rcd_id          => p_rec.cond_ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_in_file_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_rcd_in_file_id          => p_rec.ext_rcd_in_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_in_rcd_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cond_ext_data_elmt_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_cond_ext_data_elmt_id          => p_rec.cond_ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_id
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_oper_cd
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_oper_cd         => p_rec.oper_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_and_or_cd
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_and_or_cd         => p_rec.and_or_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_val
  (p_ext_where_clause_id          => p_rec.ext_where_clause_id,
   p_oper_cd         => p_rec.oper_cd,
   p_val             => p_rec.val,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dup_seq_no
  (p_business_group_id       => p_rec.business_group_id,
   p_legislation_code        => p_rec.legislation_code,
   p_ext_where_clause_id     => p_rec.ext_where_clause_id,
   p_ext_rcd_in_file_id      => p_rec.ext_rcd_in_file_id,
   p_ext_data_elmt_in_rcd_id => p_rec.ext_data_elmt_in_rcd_id ,
   p_ext_data_elmt_id        => p_rec.ext_data_elmt_id      ,
   p_seq_num                 => p_rec.seq_num,
   p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xwc_shd.g_rec_type
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
                      ,ben_xwc_shd.g_old_rec.business_group_id
                      ,ben_xwc_shd.g_old_rec.legislation_code);
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
  (p_ext_where_clause_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_where_clause b
    where b.ext_where_clause_id      = p_ext_where_clause_id
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
                             p_argument       => 'ext_where_clause_id',
                             p_argument_value => p_ext_where_clause_id);
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
end ben_xwc_bus;

/
