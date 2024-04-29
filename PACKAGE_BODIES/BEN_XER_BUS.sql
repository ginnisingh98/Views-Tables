--------------------------------------------------------
--  DDL for Package Body BEN_XER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XER_BUS" as
/* $Header: bexerrhi.pkb 120.1 2006/03/22 13:57:32 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xer_bus.';  -- Global package name
g_legislation_code            varchar2(150)  default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_data_elmt_in_rcd_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_ext_data_elmt_in_rcd bde
     where bde.ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
       and pbg.business_group_id = bde.business_group_id;
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
    ,p_argument           => 'ext_data_elmt_in_rcd_id'
    ,p_argument_value     => p_ext_data_elmt_in_rcd_id
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
-- |------< chk_ext_data_elmt_in_rcd_id >------|
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
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
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
Procedure chk_ext_data_elmt_in_rcd_id(p_ext_data_elmt_in_rcd_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_data_elmt_in_rcd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id                => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_in_rcd_id,hr_api.g_number)
     <>  ben_xer_shd.g_old_rec.ext_data_elmt_in_rcd_id) then
    --
    -- raise error as PK has changed
    --
    ben_xer_shd.constraint_error('BEN_EXT_DATA_ELMT_IN_RCD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_data_elmt_in_rcd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xer_shd.constraint_error('BEN_EXT_DATA_ELMT_IN_RCD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_data_elmt_in_rcd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_rcd_id >------|
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
--   p_ext_data_elmt_in_rcd_id PK
--   p_ext_rcd_id ID of FK column
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
Procedure chk_ext_rcd_id (p_ext_data_elmt_in_rcd_id          in number,
                            p_ext_rcd_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_rcd_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_rcd a
    where  a.ext_rcd_id = p_ext_rcd_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xer_shd.api_updating
     (p_ext_data_elmt_in_rcd_id            => p_ext_data_elmt_in_rcd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_rcd_id,hr_api.g_number)
     <> nvl(ben_xer_shd.g_old_rec.ext_rcd_id,hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if ext_rcd_id value exists in ben_ext_rcd table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_rcd
        -- table.
        --
        ben_xer_shd.constraint_error('BEN_EXT_DATA_ELMT_IN_RCD_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_rcd_id;
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
--   p_ext_data_elmt_in_rcd_id PK
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
Procedure chk_ext_data_elmt_id (p_ext_data_elmt_in_rcd_id          in number,
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
  l_api_updating := ben_xer_shd.api_updating
     (p_ext_data_elmt_in_rcd_id            => p_ext_data_elmt_in_rcd_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_data_elmt_id,hr_api.g_number)
     <> nvl(ben_xer_shd.g_old_rec.ext_data_elmt_id,hr_api.g_number)
     or not l_api_updating) then
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
        ben_xer_shd.constraint_error('BEN_EXT_DATA_ELMT_IN_RCD_FK1');
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
-- |------< chk_seq_num >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the sequence number is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--  seq_num  of record being inserted or updated.
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
Procedure chk_seq_num(p_seq_num                in number
		     ,p_ext_rcd_id	       in number
		     ,p_business_group_id      in number
		     ,p_legislation_code       in varchar2)
is
--
  l_proc         varchar2(72) := g_package||'chk_seq_num';
  l_dummy    char(1);
cursor c1 is select 1
               from ben_ext_data_elmt_in_rcd
              Where ext_rcd_id = p_ext_rcd_id
                and seq_num = p_seq_num
--                and business_group_id = p_business_group_id
                and ( (business_group_id is null -- is global
                       and legislation_code is null
                      )
                     or -- is legilsation specific
                      (legislation_code is not null
                       and legislation_code = p_legislation_code)
                     or -- is business group specific
                      (business_group_id is not null
                       and business_group_id = p_business_group_id)
                    )
;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      --
	if p_seq_num is null or p_seq_num < 1 or p_seq_num > 300
        then
         fnd_message.set_name('BEN','BEN_91863_INVLD_SEQ_NUM');
         fnd_message.raise_error;
	end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_seq_num;
--
-- ----------------------------------------------------------------------------
-- |------< chk_seq_num_unq >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the sequence number is unique.
-- Pre Conditions
--   None.
--
-- In Parameters
--  seq_num  of record being inserted or updated.
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
Procedure chk_seq_num_unq (p_ext_data_elmt_in_rcd_id in number
                          ,p_seq_num                 in number
			  ,p_ext_rcd_id		     in number
			  ,p_business_group_id       in number
			  ,p_legislation_code        in varchar2)
is
  --
  l_proc         varchar2(72) := g_package||'chk_seq_num_unq';
  l_dummy    char(1);
cursor c1 is select null
               from ben_ext_data_elmt_in_rcd
              Where ext_rcd_id = p_ext_rcd_id
                and ext_data_elmt_in_rcd_id  <> nvl(p_ext_data_elmt_in_rcd_id,-1)
                and seq_num = p_seq_num
--                and business_group_id = p_business_group_id
                and ( (business_group_id is null -- is global
                       and legislation_code is null
                      )
                     or -- is legilsation specific
                      (legislation_code is not null
                       and legislation_code = p_legislation_code)
                     or -- is business group specific
                      (business_group_id is not null
                       and business_group_id = p_business_group_id)
                    )
;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then
      close c1;
      fnd_message.set_name('BEN','BEN_91954_SEQ_NOT_UNIQUE');
      fnd_message.raise_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_seq_num_unq;
-- ----------------------------------------------------------------------------
-- |------< chk_strt_pos >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the strt position is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--  strt_pos  of record being inserted or updated.
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
Procedure chk_strt_pos(p_strt_pos                in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_strt_pos';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      --
	if p_strt_pos =0 or p_strt_pos <0  then
         fnd_message.set_name('BEN','BEN_91864_INVLD_STRT_POS');
         fnd_message.raise_error;
	end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_strt_pos;
--
-- ----------------------------------------------------------------------------
-- |------< chk_sprs_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
--   sprs_cd Value of lookup code.
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
Procedure chk_sprs_cd(p_ext_data_elmt_in_rcd_id     in number,
	              p_ext_rcd_id		    in number,
                      p_sprs_cd                     in varchar2,
                      p_effective_date              in date,
                      p_business_group_id           in number,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_sprs_cd';
  l_api_updating boolean;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id     => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_sprs_cd
      <> nvl(ben_xer_shd.g_old_rec.sprs_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_sprs_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_SPRS',
             p_lookup_code    => p_sprs_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_sprs_cd');
        fnd_message.set_token('TYPE','BEN_EXT_SPRS');
        fnd_message.raise_error;
        --
      end if;
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_SPRS',
             p_lookup_code    => p_sprs_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_sprs_cd');
        fnd_message.set_token('TYPE','BEN_EXT_SPRS');
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
end chk_sprs_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
--   rqd_flag Value of lookup code.
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
Procedure chk_rqd_flag(p_ext_data_elmt_in_rcd_id    in number,
                      p_rqd_flag                    in varchar2,
                      p_effective_date              in date,
                      p_business_group_id           in number,
                      p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id                => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rqd_flag
      <> nvl(ben_xer_shd.g_old_rec.rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_rqd_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_rqd_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
        --
      end if;
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_rqd_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_rqd_flag');
        fnd_message.set_token('TYPE','YES_NO');
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
end chk_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_any_or_all_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
--   any_or_all_cd Value of lookup code.
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
Procedure chk_any_or_all_cd(p_ext_data_elmt_in_rcd_id                in number,
                            p_any_or_all_cd               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_any_or_all_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id                => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_any_or_all_cd
      <> nvl(ben_xer_shd.g_old_rec.any_or_all_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_any_or_all_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'BEN_EXT_ANY_OR_ALL',
             p_lookup_code    => p_any_or_all_cd,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_any_or_all_cd');
        fnd_message.set_token('TYPE','BEN_EXT_ANY_OR_ALL');
        fnd_message.raise_error;
        --
      end if;
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'BEN_EXT_ANY_OR_ALL',
               p_lookup_code    => p_any_or_all_cd,
               p_effective_date => p_effective_date) then
          --
          -- raise error as does not exist as lookup
          --
          fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
          fnd_message.set_token('FIELD','p_any_or_all_cd');
          fnd_message.set_token('TYPE','BEN_EXT_ANY_OR_ALL');
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
end chk_any_or_all_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_hide_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
--   hide_flag Value of lookup code.
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
Procedure chk_hide_flag(p_ext_data_elmt_in_rcd_id    in number,
                       p_hide_flag                   in varchar2,
                       p_effective_date              in date,
                       p_business_group_id           in number,
                       p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_hide_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id                => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_hide_flag
      <> nvl(ben_xer_shd.g_old_rec.hide_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if p_business_group_id is not null then
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_hide_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_hide_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
        --
      end if;
    else
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_hide_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_hide_flag');
        fnd_message.set_token('TYPE','YES_NO');
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
end chk_hide_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_elmt_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the data element id is not null.
-- Pre Conditions
--   None.
--
-- In Parameters
--  ext_data_elmt_id  of record being inserted or updated.
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
Procedure chk_elmt_id(p_ext_data_elmt_id		in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elmt_id';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
      --
	if p_ext_data_elmt_id is null
        then
         fnd_message.set_name('BEN','BEN_92116_DATA_ELMT_NULL');
         fnd_message.raise_error;
	end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_elmt_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rcd_type >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check whether the record type is consistent with
--   the data elemnt type.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
--   ext_data_elmt_id data elmt PK of the record.
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
Procedure chk_rcd_type(p_ext_data_elmt_in_rcd_id        in number,
		       p_ext_rcd_id			in number,
                       p_ext_data_elmt_id               in number,
                       p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rcd_type';
  l_api_updating boolean;

  cursor c1 is select rcd_type_cd
  from ben_ext_rcd
  where ext_rcd_id = p_ext_rcd_id;

  cursor c2 is select data_elmt_typ_cd, alwd_in_rcd_cd
  from ben_ext_data_elmt a, ben_ext_fld b
  where a.ext_data_elmt_id = p_ext_data_elmt_id
  and a.ext_fld_id = b.ext_fld_id;

  typ_cd       ben_ext_rcd.rcd_type_cd%type;
  data_typ_cd  ben_ext_data_elmt.data_elmt_typ_cd%type;
  alwd_cd      ben_ext_fld.alwd_in_rcd_cd%type;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xer_shd.api_updating
    (p_ext_data_elmt_in_rcd_id     => p_ext_data_elmt_in_rcd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ext_data_elmt_id
      <> nvl(ben_xer_shd.g_old_rec.ext_data_elmt_id,hr_api.g_number)
      or not l_api_updating)
      and p_ext_data_elmt_id is not null then
    --
    open c1;
    fetch c1 into typ_cd;
    close c1;
    open c2;
    fetch c2 into data_typ_cd, alwd_cd;
    if data_typ_cd in ('D','F') then
	if alwd_cd in ('D','H','T') then
             if not ( alwd_cd = typ_cd  or typ_cd in ('S','L') )  then
         	fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
         	fnd_message.raise_error;
	     end if;
        elsif alwd_cd = 'B' then
             if typ_cd not in ('H','T' ,'L') then
         	fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
         	fnd_message.raise_error;
             end if;
        end if;
    elsif data_typ_cd = 'R' then
       if typ_cd <> 'D' then
         	fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
         	fnd_message.raise_error;
       end if;
    elsif data_typ_cd = 'T' then
       if typ_cd not in ('H','T','L') then
         	fnd_message.set_name('BEN','BEN_92198_CHK_RCD_TYP');
         	fnd_message.raise_error;
       end if;
    end if;

   close c2;
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rcd_type;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
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
--bug 2804169 -- check if child records exist
-- ----------------------------------------------------------------------------
-- |------< chk_child_recs >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check whether the data element has any child records
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_data_elmt_in_rcd_id PK of record being inserted or updated.
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
Procedure chk_child_recs(p_ext_data_elmt_in_rcd_id        in number
		         ) is
  --
  l_proc         varchar2(72) := g_package||'chk_child_recs';


  cursor c_ext_where_clause is
  select ext_where_clause_id
  from ben_ext_where_clause
  where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

  cursor c_ext_incl_chg_id is
    select ext_incl_chg_id
    from ben_ext_incl_chg
  where ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;

  l_ext_where_clause_id ben_ext_where_clause.ext_where_clause_id%TYPE;
  l_ext_incl_chg_id ben_ext_incl_chg.ext_incl_chg_id%TYPE;


  cursor c_ext_file_group   is
  select 'x'
  from ben_ext_file
  where EXT_DATA_ELMT_IN_RCD_ID1  = p_ext_data_elmt_in_rcd_id
     or EXT_DATA_ELMT_IN_RCD_ID2  = p_ext_data_elmt_in_rcd_id
  ;

  l_dummy varchar2(1) ;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    open c_ext_where_clause;
    fetch c_ext_where_clause into l_ext_where_clause_id;
    close c_ext_where_clause;

    if l_ext_where_clause_id is not null then
      fnd_message.set_name('PER','HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME','ben_ext_where_clause');
      fnd_message.raise_error;
    end if;



    open c_ext_incl_chg_id;
    fetch c_ext_incl_chg_id into l_ext_incl_chg_id;
    close c_ext_incl_chg_id;

    if l_ext_incl_chg_id is not null then
      fnd_message.set_name('PER','HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME','ben_ext_incl_chg');
      fnd_message.raise_error;

    end if;


   open c_ext_file_group ;
   fetch c_ext_file_group into l_dummy ;
   if c_ext_file_group%found then
      close c_ext_file_group ;
      fnd_message.set_name('PER','HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME','ben_ext_file.grouping');
      fnd_message.raise_error;

   end if ;
   close c_ext_file_group ;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_recs;
--

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xer_shd.g_rec_type
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
  chk_ext_data_elmt_in_rcd_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sprs_cd
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
  p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_sprs_cd         => p_rec.sprs_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_any_or_all_cd
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_any_or_all_cd         => p_rec.any_or_all_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_hide_flag
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_hide_flag         => p_rec.hide_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seq_num
  (p_seq_num           => p_rec.seq_num
  ,p_ext_rcd_id        => p_rec.ext_rcd_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code);
  --
  chk_seq_num_unq
   (p_ext_data_elmt_in_rcd_id  => p_rec.ext_data_elmt_in_rcd_id,
    p_seq_num                  => p_rec.seq_num,
    p_ext_rcd_id               => p_rec.ext_rcd_id,
    p_business_group_id        => p_rec.business_group_id,
    p_legislation_code         => p_rec.legislation_code);
  --
  chk_elmt_id(p_ext_data_elmt_id => p_rec.ext_data_elmt_id);
  --
  chk_strt_pos(p_strt_pos => p_rec.strt_pos);
  --
  chk_rcd_type
  (p_ext_data_elmt_in_rcd_id       => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_rcd_id                    => p_rec.ext_rcd_id,
   p_ext_data_elmt_id              => p_rec.ext_data_elmt_id,
   p_object_version_number         => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xer_shd.g_rec_type
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
  chk_ext_data_elmt_in_rcd_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_rcd_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_data_elmt_id
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_data_elmt_id          => p_rec.ext_data_elmt_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_sprs_cd
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_rcd_id          => p_rec.ext_rcd_id,
   p_sprs_cd         => p_rec.sprs_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rqd_flag
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_rqd_flag         => p_rec.rqd_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_any_or_all_cd
  (p_ext_data_elmt_in_rcd_id          => p_rec.ext_data_elmt_in_rcd_id,
   p_any_or_all_cd         => p_rec.any_or_all_cd,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_seq_num
  (p_seq_num           => p_rec.seq_num
  ,p_ext_rcd_id        => p_rec.ext_rcd_id
  ,p_business_group_id => p_rec.business_group_id
  ,p_legislation_code  => p_rec.legislation_code);
  --
  chk_seq_num_unq
   (p_ext_data_elmt_in_rcd_id => p_rec.ext_data_elmt_in_rcd_id,
    p_seq_num                 => p_rec.seq_num,
    p_ext_rcd_id              => p_rec.ext_rcd_id,
    p_business_group_id       => p_rec.business_group_id,
    p_legislation_code        => p_rec.legislation_code);
  --
  chk_elmt_id(p_ext_data_elmt_id => p_rec.ext_data_elmt_id);
  --
  chk_strt_pos(p_strt_pos => p_rec.strt_pos);
  --
  chk_rcd_type
  (p_ext_data_elmt_in_rcd_id       => p_rec.ext_data_elmt_in_rcd_id,
   p_ext_rcd_id                    => p_rec.ext_rcd_id,
   p_ext_data_elmt_id              => p_rec.ext_data_elmt_id,
   p_object_version_number         => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xer_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --bug 2804169 -- check if child records exist
  chk_child_recs ( p_rec.ext_data_elmt_in_rcd_id);
  --
  chk_startup_action(False
                    ,ben_xer_shd.g_old_rec.business_group_id
                    ,ben_xer_shd.g_old_rec.legislation_code);
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
  (p_ext_data_elmt_in_rcd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_ext_data_elmt_in_rcd b
    where b.ext_data_elmt_in_rcd_id      = p_ext_data_elmt_in_rcd_id
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
                             p_argument       => 'ext_data_elmt_in_rcd_id',
                             p_argument_value => p_ext_data_elmt_in_rcd_id);
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
end ben_xer_bus;

/
