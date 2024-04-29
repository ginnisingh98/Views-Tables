--------------------------------------------------------
--  DDL for Package Body BEN_XEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XEL_BUS" as
/* $Header: bexelrhi.pkb 120.1 2005/06/08 13:15:34 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xel_bus.';  -- Global package name
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_data_elmt_id                 in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_data_elmt xel
     where xel.ext_data_elmt_id = p_ext_data_elmt_id
       and pbg.business_group_id = xel.business_group_id;
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
    ,p_argument           => 'ext_data_elmt_id'
    ,p_argument_value     => p_ext_data_elmt_id
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
-- |------< chk_ext_data_elmt_id >------|
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
--   ext_data_elmt_id PK of record being inserted or updated.
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
Procedure chk_ext_data_elmt_id(p_ext_data_elmt_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_data_elmt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_id,hr_api.g_number)
     <>  ben_xel_shd.g_old_rec.ext_data_elmt_id) then
    --
    -- raise error as PK has changed
    --
    ben_xel_shd.constraint_error('BEN_EXT_DATA_ELMT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_data_elmt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xel_shd.constraint_error('BEN_EXT_DATA_ELMT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_data_elmt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_frmt_mask_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
--   frmt_mask_cd Value of lookup code.
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
Procedure chk_frmt_mask_cd(p_ext_data_elmt_id                in number,
                            p_frmt_mask_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_frmt_mask_cd';
  l_api_updating boolean;
  frmt_val	varchar2(240); -- UTF8
  invalid_frmt1	exception;
  invalid_frmt2	exception;
  Pragma Exception_Init(invalid_frmt1,-01821);
  Pragma Exception_Init(invalid_frmt2,-01481);
  p_meaning	        hr_lookups.meaning%type;
  p_part_meaning	hr_lookups.meaning%type;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_frmt_mask_cd
      <> nvl(ben_xel_shd.g_old_rec.frmt_mask_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frmt_mask_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_FRMT_MASK',
             p_lookup_code    => p_frmt_mask_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_frmt_mask_cd');
        fnd_message.set_token('TYPE','BEN_EXT_FRMT_MASK');
        fnd_message.raise_error;
        --
      end if;
    --
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_FRMT_MASK',
             p_lookup_code    => p_frmt_mask_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_frmt_mask_cd');
        fnd_message.set_token('TYPE','BEN_EXT_FRMT_MASK');
        fnd_message.raise_error;
        --
      end if;
    --
    end if;
    --
   select meaning into p_meaning from hr_lookups
   where lookup_type='BEN_EXT_FRMT_MASK'
   and lookup_code =p_frmt_mask_cd
   and enabled_flag='Y';
   if substr(p_frmt_mask_cd,1,1) = 'N' then
        if substr(p_meaning,length(p_meaning),1) in ('{','}') then
           p_part_meaning := substr(p_meaning,1,length(p_meaning)-1);
        else
           p_part_meaning := p_meaning;
        end if;
   	select to_char(123456789,p_part_meaning) into frmt_val from dual;
   elsif substr(p_frmt_mask_cd,1,1) = 'D' then
	select to_char(sysdate,p_meaning) into frmt_val from dual;
   elsif substr(p_frmt_mask_cd,1,1) = 'S' then
        if p_frmt_mask_cd not in ('S1','S2') then
         fnd_message.set_name('BEN','BEN_91960_FRMT_MSK_UNSPRTD');
         fnd_message.raise_error;
        end if;
   elsif substr(p_frmt_mask_cd,1,1) = 'P' then
        if p_frmt_mask_cd not in ('P1','P2','P3','P4','P5') then
         fnd_message.set_name('BEN','BEN_91960_FRMT_MSK_UNSPRTD');
         fnd_message.raise_error;
        end if;
  end if;
 end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
Exception
  When invalid_frmt1 or invalid_frmt2 then
         fnd_message.set_name('BEN','BEN_91959_INVLD_FRMT_MSK');
         fnd_message.raise_error;
end chk_frmt_mask_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_data_elmt_rl >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rule is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
--   data_elmt_rl Value of formula rule id.
--   effective_date effective date
--   object_version_number Object version number of record being
--                                      inserted or updated.
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
Procedure chk_data_elmt_rl(p_ext_data_elmt_id            in number,
                           p_data_elmt_rl                in number,
                           p_business_group_id           in number,
                           p_legislation_code            in varchar2,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_data_elmt_rl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ff_formulas_f ff
--           ,per_business_groups pbg
    where  ff.formula_id = p_data_elmt_rl
      and  ff.formula_type_id in (-413,-531,-536,-537,-538,-539,-540,-541,-542,-543,-544,-545,-546)
--      and    pbg.business_group_id = p_business_group_id
--      and  nvl(ff.business_group_id, p_business_group_id) =
--               p_business_group_id
--      and  nvl(ff.legislation_code, pbg.legislation_code) =
--               pbg.legislation_code
      and  (   -- exists globally
             (business_group_id is null
                and legislation_code is null
             )
            or -- exists within this legilsation
             (legislation_code is not null
                and legislation_code = p_legislation_code
             )
            or -- exists within this business group
             (business_group_id is not null
                and business_group_id = p_business_group_id
             )
           )
      and  p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date
    ;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_data_elmt_rl,hr_api.g_number)
      <> ben_xel_shd.g_old_rec.data_elmt_rl
      or not l_api_updating)
      and p_data_elmt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then the
      -- formula is valid otherwise its invalid
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error
        --
        fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
        fnd_message.set_token('ID',p_data_elmt_rl);
        fnd_message.set_token('TYPE_ID',-413);
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
end chk_data_elmt_rl;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_delete_allowed >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the user can delete the data element
--   only if its not in a record layout.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
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
Procedure chk_delete_allowed(p_ext_data_elmt_id in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_delete_allowed';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_data_elmt_in_rcd bed
    where  bed.ext_data_elmt_id = p_ext_data_elmt_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c1;
    --
    fetch c1 into l_dummy;
    if c1%found then
      --
      close c1;
      --
      -- raise error
      --
      fnd_message.set_name('BEN','BEN_92616_XER_RECS_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_delete_allowed;
-- ----------------------------------------------------------------------------
-- |------< chk_max_length_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the maximum length number is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--  max_length_num  of record being inserted or updated.
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
Procedure chk_max_length_num(p_max_length_num                in number,
                             p_dflt_val                   in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_max_length_num';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      --
	if p_max_length_num =0 or p_max_length_num <0  then
         fnd_message.set_name('BEN','BEN_91865_INVLD_MAX_NUM');
         fnd_message.raise_error;
	end if;
  --
	if p_max_length_num >0 then
		if p_dflt_val is not null then
			if length(p_dflt_val) > p_max_length_num then
                          fnd_message.set_name('BEN','BEN_91866_INVLD_DFLT_VAL');
                          fnd_message.raise_error;
                	end if;
	        end if;
	end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_max_length_num;
--
-- ----------------------------------------------------------------------------
-- |------< chk_data_elmt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
--   data_elmt_typ_cd Value of lookup code.
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
Procedure chk_data_elmt_typ_cd(p_ext_data_elmt_id         in number,
                            p_data_elmt_typ_cd            in varchar2,
                            p_string_val                  in varchar2,
                            p_max_length_num              in number,
                            p_data_elmt_rl                in number,
                            p_ttl_fnctn_cd                in varchar2,
                            p_effective_date              in date,
                            p_defined_balance_id          in number,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_data_elmt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and   (  ( p_data_elmt_typ_cd <> nvl(ben_xel_shd.g_old_rec.data_elmt_typ_cd,hr_api.g_varchar2))
             or( nvl(p_string_val,hr_api.g_varchar2)       <> nvl(ben_xel_shd.g_old_rec.string_val,hr_api.g_varchar2))
             or( nvl(p_max_length_num,hr_api.g_number)     <> nvl(ben_xel_shd.g_old_rec.max_length_num,hr_api.g_number))
             or( nvl(p_data_elmt_rl,hr_api.g_number)       <> nvl(ben_xel_shd.g_old_rec.data_elmt_rl,hr_api.g_number))
             or( nvl(p_ttl_fnctn_cd,hr_api.g_varchar2)     <> nvl(ben_xel_shd.g_old_rec.ttl_fnctn_cd,hr_api.g_varchar2))
             or( nvl(p_defined_balance_id,hr_api.g_number) <> nvl(ben_xel_shd.g_old_rec.defined_balance_id,hr_api.g_number))
            )
       or not l_api_updating)
      and p_data_elmt_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    hr_utility.set_location('update mode :' || p_string_val ||'  '|| ben_xel_shd.g_old_rec.string_val, 5);
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_DATA_ELMT_TYP',
             p_lookup_code    => p_data_elmt_typ_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_data_elmt_typ_cd');
        fnd_message.set_token('TYPE','BEN_EXT_DATA_ELMT_TYP');
        fnd_message.raise_error;
        --
      end if;
    --
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_DATA_ELMT_TYP',
             p_lookup_code    => p_data_elmt_typ_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_data_elmt_typ_cd');
        fnd_message.set_token('TYPE','BEN_EXT_DATA_ELMT_TYP');
        fnd_message.raise_error;
        --
      end if;
    --
    end if;
   -- allow to enter null for  string value
   -- Need to report fix number of space if the data not avaialble
   -- this may be need for ANSI
   if p_data_elmt_typ_cd = 'S' then
	if p_string_val is null and p_max_length_num is null  then
           fnd_message.set_name('BEN','BEN_91867_STR_VAL_NULL');
           fnd_message.raise_error;
	end if;
   end if;

   if p_data_elmt_typ_cd = 'R' then
	if p_data_elmt_rl is null then
           fnd_message.set_name('BEN','BEN_91868_RL_VAL_NULL');
           fnd_message.raise_error;
	end if;
   end if;

   if p_data_elmt_typ_cd = 'T' then
	if p_ttl_fnctn_cd is null then
           fnd_message.set_name('BEN','BEN_92138_FNCTN_CD_NULL');
           fnd_message.raise_error;
	end if;
   end if;
   if p_data_elmt_typ_cd = 'C' then
        if p_ttl_fnctn_cd is null then
           fnd_message.set_name('BEN','BEN_92138_FNCTN_CD_NULL');
           fnd_message.raise_error;
        end if;
   end if;

  if p_data_elmt_typ_cd = 'P' then
        if p_defined_balance_id  is null then
           fnd_message.set_name('BEN','BEN_94248_DEFINE_BAL_NULL');
           fnd_message.raise_error;
        end if;
   end if;


  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_data_elmt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_just_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
--   just_cd Value of lookup code.
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
Procedure chk_just_cd(p_ext_data_elmt_id            in number,
                      p_just_cd                     in varchar2,
                      p_effective_date              in date,
                      p_business_group_id           in varchar2,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_just_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_just_cd
      <> nvl(ben_xel_shd.g_old_rec.just_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_just_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_JUST',
             p_lookup_code    => p_just_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_just_cd');
        fnd_message.set_token('TYPE','BEN_EXT_JUST');
        fnd_message.raise_error;
        --
      end if;
    --
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_JUST',
             p_lookup_code    => p_just_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_just_cd');
        fnd_message.set_token('TYPE','BEN_EXT_JUST');
        fnd_message.raise_error;
        --
      end if;
    --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_just_cd;



-- ----------------------------------------------------------------------------
-- |------< chk_just_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_id PK of record being inserted or updated.
--   just_cd Value of lookup code.
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
Procedure chk_defined_balance(p_ext_data_elmt_id            in number,
                      p_defined_balance_id                  in varchar2,
                      p_effective_date              in date,
                      p_business_group_id           in varchar2,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_defined_balance';
  l_api_updating boolean;
  --
  cursor c is
  select 'x' from
  pay_defined_balances
  where defined_balance_id = p_defined_balance_id
  ;
  l_dummy varchar2(1) ;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_defined_balance_id
      <> nvl(ben_xel_shd.g_old_rec.defined_balance_id,hr_api.g_number)
      or not l_api_updating)
      and p_defined_balance_id is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    open c ;
    fetch c into l_dummy ;
    if c%notfound then
       close c ;
       fnd_message.set_name('BEN','BEN_94249_DEFINE_BAL_NOTFOUND');
       fnd_message.raise_error;

    end if ;
    close c ;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_defined_balance;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_xml_name_format >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_xml_name_format
          ( p_xml_tag_name         in out nocopy   varchar2
          ) is
 rgeflg varchar2(1);
l_proc	    varchar2(72) := g_package||'chk_xml_name_format';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

 if p_xml_tag_name  is not null then
     begin
        -- Check if name legal format eg no spaces, or special characters
         hr_chkfmt.checkformat (p_xml_tag_name, 'DB_ITEM_NAME', p_xml_tag_name,
                           null,null,'Y',rgeflg,null);
     exception
         when hr_utility.hr_error then
         hr_utility.set_message (802, 'FFHR_6016_ALL_RES_WORDS');
         hr_utility.set_message_token(802,'VALUE_NAME','XML Tag');
         hr_utility.raise_error;
  end;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_xml_name_format;
--

-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that not two data elements have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is data element name
--     p_ext_data_elmt_id is data elmt id
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
Procedure chk_name_unique
          (p_ext_data_elmt_id     in     number
          ,p_name                 in     varchar2
          ,p_business_group_id    in     number
          ,p_legislation_code     in     varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_ext_data_elmt
              Where ext_data_elmt_id <> nvl(p_ext_data_elmt_id,-1)
                and name = p_name
--                and business_group_id = p_business_group_id
                and ( (business_group_id is null -- is unique globally
                       and legislation_code is null
                      )
                     or -- is unique within this legilsation
                      (legislation_code is not null
                       and business_group_id is null
                       and legislation_code = p_legislation_code)
                     or -- is unique within this business group
                      (business_group_id is not null
                       and business_group_id = p_business_group_id)
                    )
                ;
 rgeflg varchar2(1);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
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
-- |------------------------< chk_ttl_cond >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Check that condition, function, operation have consistent values
--     for Totals
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_ext_data_elmt_id is data elmt id
--     p_ttl_fnctn_cd is value of ttl_fnctn_cd
--     p_ttl_sum_ext_data_elmt_id is value of ttl_sum_ext_data_elmt_id
--     p_ttl_cond_ext_data_elmt_id is value of ttl_cond_ext_data_elmt_id
--     p_ttl_cond_operation_cd is value of ttl_cond_operation_cd
--     p_ttl_cond_val is value of ttl_cond_val
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
Procedure chk_ttl_cond
          ( p_ext_data_elmt_id             in number
           ,p_data_elmt_typ_cd             in varchar2
           ,p_ttl_fnctn_cd                 in varchar2
           ,p_ttl_sum_ext_data_elmt_id     in number
           ,p_ttl_cond_ext_data_elmt_id    in number
           ,p_ttl_cond_operation_cd        in varchar2
           ,p_ttl_cond_val                 in varchar2
           ,p_object_version_number        in number )
is
l_proc	    		varchar2(72) := g_package||'chk_ttl_cond';
l_api_updating  	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xel_shd.api_updating
    (p_ext_data_elmt_id                => p_ext_data_elmt_id,
     p_object_version_number       => p_object_version_number);
  --
  hr_utility.set_location('p_ttl_fnctn_cd:'||p_ttl_fnctn_cd, 15);
  if (l_api_updating
      and nvl(p_ttl_fnctn_cd,hr_api.g_varchar2)
      <> nvl(ben_xel_shd.g_old_rec.ttl_fnctn_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
  	if p_ttl_fnctn_cd = 'CNT' then
               if p_ttl_sum_ext_data_elmt_id is not null then
      		fnd_message.set_name('BEN','BEN_92199_CHK_FNCTN_CD');
      		fnd_message.raise_error;
               end if;
  	elsif p_ttl_fnctn_cd = 'SUM' then
               if p_ttl_sum_ext_data_elmt_id is null then
      		fnd_message.set_name('BEN','BEN_92418_CHK_FNCTN_CD2');
      		fnd_message.raise_error;
               end if;
               if p_ttl_cond_ext_data_elmt_id is null then
      		fnd_message.set_name('BEN','BEN_92419_CHK_FNCTN_CD3');
                  -- if function is 'Sum' then a record must be specified.
      		fnd_message.raise_error;
               end if;

      elsif p_ttl_fnctn_cd in ( 'ADD','SUB','MLT','DIV' ) then
               if p_ttl_cond_ext_data_elmt_id is nulL then
                fnd_message.set_name('BEN','BEN_92419_CHK_FNCTN_CD3');
                  -- if function is 'Sum' then a record must be specified.
                fnd_message.raise_error;
               end if;

      elsif p_ttl_fnctn_cd is null then
           if p_ttl_sum_ext_data_elmt_id is not null then
      	     fnd_message.set_name('BEN','BEN_92200_CHK_COND_DATA_ELMT');
      	     fnd_message.raise_error;
           elsif p_ttl_cond_ext_data_elmt_id is not null then
      	     fnd_message.set_name('BEN','BEN_92201_CHK_COND_DATA_ELMT');
      	     fnd_message.raise_error;
              /* these fields no longer used
                 elsif p_ttl_cond_operation_cd is not null  then
      	     fnd_message.set_name('BEN','BEN_92202_CHK_COND_DATA_ELMT');
      	     fnd_message.raise_error;
               elsif p_ttl_cond_val is not null then
      	     fnd_message.set_name('BEN','BEN_92203_CHK_COND_DATA_ELMT');
      	     fnd_message.raise_error; */
               elsif p_data_elmt_typ_cd = 'T' then
                 fnd_message.set_name('BEN','BEN_92138_FNCTN_CD_NULL');
                 fnd_message.raise_error;
               end if;
  	end if;
  end if;
--
  if (l_api_updating
      and nvl(p_ttl_sum_ext_data_elmt_id,hr_api.g_number)
        <> nvl(ben_xel_shd.g_old_rec.ttl_sum_ext_data_elmt_id,hr_api.g_number)
      or not l_api_updating) then
  	if p_ttl_sum_ext_data_elmt_id is not null and p_ttl_fnctn_cd <> 'SUM' then
      		fnd_message.set_name('BEN','BEN_92200_CHK_SUM_DATA_ELMT');
      		fnd_message.raise_error;
  	elsif p_ttl_sum_ext_data_elmt_id is null and p_ttl_fnctn_cd = 'SUM' then
      		fnd_message.set_name('BEN','BEN_92199_CHK_FNCTN_CD');
      		fnd_message.raise_error;
  	end if;

  end if;
  hr_utility.set_location('p_ttl_fnctn_cd:'||p_ttl_fnctn_cd, 15);
  hr_utility.set_location('p_ttl_cond_ext_data_elmt_id:'||p_ttl_cond_ext_data_elmt_id, 15);
  if (l_api_updating
      and nvl(p_ttl_cond_ext_data_elmt_id,hr_api.g_number)
      <> nvl(ben_xel_shd.g_old_rec.ttl_cond_ext_data_elmt_id,hr_api.g_number)
      or not l_api_updating) then
    --
  	if p_ttl_cond_ext_data_elmt_id is not null then
     	  if p_ttl_fnctn_cd is null then
      	    fnd_message.set_name('BEN','BEN_92201_CHK_COND_DATA_ELMT');
      	    fnd_message.raise_error;
         end if;
      end if;
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_ttl_cond;
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
Procedure insert_validate(p_rec in ben_xel_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';

  -- Added for Bug fix 2091110
  l_legislation_code   per_business_groups.legislation_code%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  -- Bug fix 2091110
  -- legislation code should not be the one
  -- from p_rec always instead get it for the business group
  --
  -- Get the legislation code for this business group

  IF p_rec.business_group_id IS NOT NULL THEN
    l_legislation_code := hr_api.return_legislation_code (
                            p_business_group_id=> p_rec.business_group_id
                          );
  ELSE
    l_legislation_code := p_rec.legislation_code;
  END IF; -- End if of bg not null check ...

  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,l_legislation_code);
                   -- ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_data_elmt_id
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_frmt_mask_cd
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_frmt_mask_cd         => p_rec.frmt_mask_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_just_cd
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_just_cd         => p_rec.just_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_elmt_rl
  (p_ext_data_elmt_id      => p_rec.ext_data_elmt_id,
   p_data_elmt_rl          => p_rec.data_elmt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_legislation_code      => l_legislation_code,
--   p_legislation_code      => p_rec.legislation_code,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_elmt_typ_cd
  (p_ext_data_elmt_id      => p_rec.ext_data_elmt_id,
   p_data_elmt_typ_cd      => p_rec.data_elmt_typ_cd,
   p_string_val            => p_rec.string_val,
   p_max_length_num        => p_rec.max_length_num,
   p_data_elmt_rl          => p_rec.data_elmt_rl,
   p_ttl_fnctn_cd          => p_rec.ttl_fnctn_cd,
   p_effective_date        => p_effective_date,
   p_defined_balance_id    => p_rec.defined_balance_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_max_length_num
  (p_max_length_num    => p_rec.max_length_num,
   p_dflt_val          => p_rec.dflt_val);

  chk_name_unique
  (p_ext_data_elmt_id   => p_rec.ext_data_elmt_id
  ,p_name               => p_rec.name
  ,p_business_group_id  => p_rec.business_group_id
  ,p_legislation_code   => l_legislation_code);
 -- ,p_legislation_code   => p_rec.legislation_code);
  --
 chk_ttl_cond
          ( p_ext_data_elmt_id => p_rec.ext_data_elmt_id
           ,p_data_elmt_typ_cd => p_rec.data_elmt_typ_cd
           ,p_ttl_fnctn_cd => p_rec.ttl_fnctn_cd
           ,p_ttl_sum_ext_data_elmt_id => p_rec.ttl_sum_ext_data_elmt_id
           ,p_ttl_cond_ext_data_elmt_id => p_rec.ttl_cond_ext_data_elmt_id
           ,p_ttl_cond_operation_cd => p_rec.ttl_cond_oper_cd
           ,p_ttl_cond_val => p_rec.ttl_cond_val
   	   ,p_object_version_number => p_rec.object_version_number);
  --
  chk_defined_balance(p_ext_data_elmt_id         => p_rec.ext_data_elmt_id ,
                      p_defined_balance_id       => p_rec.defined_balance_id,
                      p_effective_date           => p_effective_date ,
                      p_business_group_id        => p_rec.business_group_id ,
                      p_object_version_number    => p_rec.object_version_number ) ;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xel_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';

  -- Added for bug fix 2091110
  l_legislation_code   per_business_groups.legislation_code%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  -- Bug fix 2091110
  -- legislation code should not be the one
  -- from p_rec always instead get it for the business group
  --
  -- Get the legislation code for this business group

  IF p_rec.business_group_id IS NOT NULL THEN
    l_legislation_code := hr_api.return_legislation_code (
                            p_business_group_id=> p_rec.business_group_id
                          );
  ELSE
    l_legislation_code := p_rec.legislation_code;
  END IF; -- End if of bg not null check ...

  chk_startup_action(False
                    ,p_rec.business_group_id
                    ,l_legislation_code);
                   -- ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  END IF;
  --
  chk_ext_data_elmt_id
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_frmt_mask_cd
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_frmt_mask_cd         => p_rec.frmt_mask_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_elmt_rl
  (p_ext_data_elmt_id      => p_rec.ext_data_elmt_id,
   p_data_elmt_rl          => p_rec.data_elmt_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_legislation_code      => l_legislation_code,
--   p_legislation_code      => p_rec.legislation_code,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_elmt_typ_cd
  (p_ext_data_elmt_id      => p_rec.ext_data_elmt_id,
   p_data_elmt_typ_cd      => p_rec.data_elmt_typ_cd,
   p_string_val            => p_rec.string_val,
   p_max_length_num        => p_rec.max_length_num,
   p_data_elmt_rl          => p_rec.data_elmt_rl,
   p_ttl_fnctn_cd          => p_rec.ttl_fnctn_cd,
   p_effective_date        => p_effective_date,
   p_defined_balance_id    => p_rec.defined_balance_id,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_just_cd
  (p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_just_cd         => p_rec.just_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_max_length_num
  (p_max_length_num    => p_rec.max_length_num,
   p_dflt_val          => p_rec.dflt_val);

  chk_name_unique
  (p_ext_data_elmt_id   => p_rec.ext_data_elmt_id
  ,p_name               => p_rec.name
  ,p_business_group_id  => p_rec.business_group_id
  ,p_legislation_code   => l_legislation_code);
--  ,p_legislation_code   => p_rec.legislation_code);
--
 chk_ttl_cond
          ( p_ext_data_elmt_id => p_rec.ext_data_elmt_id
           ,p_data_elmt_typ_cd => p_rec.data_elmt_typ_cd
           ,p_ttl_fnctn_cd => p_rec.ttl_fnctn_cd
           ,p_ttl_sum_ext_data_elmt_id => p_rec.ttl_sum_ext_data_elmt_id
           ,p_ttl_cond_ext_data_elmt_id => p_rec.ttl_cond_ext_data_elmt_id
           ,p_ttl_cond_operation_cd => p_rec.ttl_cond_oper_cd
           ,p_ttl_cond_val => p_rec.ttl_cond_val
   	   ,p_object_version_number => p_rec.object_version_number);

  chk_defined_balance(p_ext_data_elmt_id         => p_rec.ext_data_elmt_id ,
                      p_defined_balance_id       => p_rec.defined_balance_id,
                      p_effective_date           => p_effective_date ,
                      p_business_group_id        => p_rec.business_group_id ,
                      p_object_version_number    => p_rec.object_version_number ) ;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xel_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';

  -- Added for Bug fix 2091110
  l_legislation_code   per_business_groups.legislation_code%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  --
  -- Bug fix 2091110
  -- legislation code should not be the one
  -- from p_rec always instead get it for the business group
  --
  -- Get the legislation code for this business group

  IF ben_xel_shd.g_old_rec.business_group_id IS NOT NULL THEN
    l_legislation_code := hr_api.return_legislation_code (
                            p_business_group_id=> ben_xel_shd.g_old_rec.business_group_id
                          );
  ELSE
    l_legislation_code := ben_xel_shd.g_old_rec.legislation_code;
  END IF; -- End if of bg not null check ...

  chk_startup_action(False
                    ,ben_xel_shd.g_old_rec.business_group_id
                    ,l_legislation_code);
                   -- ,ben_xel_shd.g_old_rec.legislation_code);
  --
  chk_delete_allowed(p_ext_data_elmt_id => p_rec.ext_data_elmt_id);
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
  (p_ext_data_elmt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_data_elmt b
    where b.ext_data_elmt_id      = p_ext_data_elmt_id
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
                             p_argument       => 'ext_data_elmt_id',
                             p_argument_value => p_ext_data_elmt_id);
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
end ben_xel_bus;

/
