--------------------------------------------------------
--  DDL for Package Body BEN_XDF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDF_BUS" as
/* $Header: bexdfrhi.pkb 120.6 2006/07/10 21:53:55 tjesumic ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xdf_bus.';  -- Global package name
--
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_ext_dfn_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups_perf pbg
         , ben_ext_dfn dfn
     where dfn.ext_dfn_id = p_ext_dfn_id
       and pbg.business_group_id = dfn.business_group_id;
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
    ,p_argument           => 'ext_dfn_id'
    ,p_argument_value     => p_ext_dfn_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;

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
-- |------< chk_ext_dfn_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the primary key for the table
--   is created properly. It should be null on insert and
--   should not be able to be updated.
--r
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
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
Procedure chk_ext_dfn_id(p_ext_dfn_id                in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_dfn_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_dfn_id,hr_api.g_number)
     <>  ben_xdf_shd.g_old_rec.ext_dfn_id) then
    --
    -- raise error as PK has changed
    --
    ben_xdf_shd.constraint_error('BEN_EXT_DFN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_ext_dfn_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_xdf_shd.constraint_error('BEN_EXT_DFN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_ext_dfn_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_ext_file_id >------|
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
--   p_ext_dfn_id PK
--   p_ext_file_id ID of FK column
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
Procedure chk_ext_file_id (p_ext_dfn_id          in number,
                            p_ext_file_id          in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_file_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_ext_file a
    where  a.ext_file_id = p_ext_file_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_xdf_shd.api_updating
     (p_ext_dfn_id            => p_ext_dfn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_file_id,hr_api.g_number)
     <> nvl(ben_xdf_shd.g_old_rec.ext_file_id,hr_api.g_number)
     or not l_api_updating) and
     p_ext_file_id is not null then
    --
    -- check if ext_file_id value exists in ben_ext_file table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_ext_file
        -- table.
        --
        ben_xdf_shd.constraint_error('BEN_EXT_DFN_FK2');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_ext_file_id;
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
--   p_ext_dfn_id PK
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
Procedure chk_ext_crit_prfl_id (p_ext_dfn_id          in number,
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
  l_api_updating := ben_xdf_shd.api_updating
     (p_ext_dfn_id            => p_ext_dfn_id,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_ext_crit_prfl_id,hr_api.g_number)
     <> nvl(ben_xdf_shd.g_old_rec.ext_crit_prfl_id,hr_api.g_number)
     or not l_api_updating) and
     p_ext_crit_prfl_id is not null then
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
        ben_xdf_shd.constraint_error('BEN_EXT_DFN_FK1');
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
-- |------< chk_data_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   data_typ_cd Value of lookup code.
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
Procedure chk_data_typ_cd(p_ext_dfn_id                in number,
                            p_data_typ_cd               in varchar2,
			    p_ext_crit_prfl_id		in number,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_data_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_data_typ_cd is null then
      fnd_message.set_name('BEN','BEN_91784_DATA_NULL');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_data_typ_cd
      <> nvl(ben_xdf_shd.g_old_rec.data_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_data_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --

    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_DATA_TYP',
           p_lookup_code    => p_data_typ_cd,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_data_typ_cd');
        fnd_message.set_token('TYPE','BEN_EXT_DATA_TYP');
        fnd_message.raise_error;
        --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'BEN_EXT_DATA_TYP',
           p_lookup_code    => p_data_typ_cd,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_data_typ_cd');
        fnd_message.set_token('TYPE','BEN_EXT_DATA_TYP');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
    --
   if p_data_typ_cd = 'C' then
	if p_ext_crit_prfl_id is null then
         fnd_message.set_name('BEN','BEN_91782_EXT_CRIT_PRFL_NULL');
         fnd_message.raise_error;
	end if;
   end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_data_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_apnd_rqst_id_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   It also checks if output filename is null when apnd_rqst_id_flag=yes.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   apnd_rqst_id_flag Value of lookup code.
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
Procedure chk_apnd_rqst_id_flag(p_ext_dfn_id                in number,
				p_output_name		    in varchar2,
                            p_apnd_rqst_id_flag               in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_apnd_rqst_id_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_apnd_rqst_id_flag
      <> nvl(ben_xdf_shd.g_old_rec.apnd_rqst_id_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_apnd_rqst_id_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --

    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_apnd_rqst_id_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_apnd_rqst_id_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_apnd_rqst_id_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_apnd_rqst_id_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;

    --
  end if;

  if p_apnd_rqst_id_flag = 'Y' then
        if p_output_name is null then
         fnd_message.set_name('BEN','BEN_91774_OUTPUT_NAME_NULL');
         fnd_message.raise_error;
        end if;
   end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_apnd_rqst_id_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_kickoff_wrt_prc_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   kickoff_wrt_prc_flag Value of lookup code.
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
Procedure chk_kickoff_wrt_prc_flag(p_ext_dfn_id           in number,
                            p_kickoff_wrt_prc_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_kickoff_wrt_prc_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_kickoff_wrt_prc_flag
      <> nvl(ben_xdf_shd.g_old_rec.kickoff_wrt_prc_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_kickoff_wrt_prc_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_kickoff_wrt_prc_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_kickoff_wrt_prc_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
            (p_lookup_type    => 'YES_NO',
             p_lookup_code    => p_kickoff_wrt_prc_flag,
             p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_kickoff_wrt_prc_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_kickoff_wrt_prc_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_spcl_hndl_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   spcl_hndl_flag Value of lookup code.
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
Procedure chk_spcl_hndl_flag(p_ext_dfn_id           in number,
                            p_spcl_hndl_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_spcl_hndl_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_spcl_hndl_flag
      <> nvl(ben_xdf_shd.g_old_rec.spcl_hndl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_spcl_hndl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_spcl_hndl_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_spcl_hndl_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_spcl_hndl_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_spcl_hndl_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_spcl_hndl_flag;
--



Procedure chk_ext_global_flag(p_ext_dfn_id           in number,
                            p_ext_global_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ext_global_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ext_global_flag
      <> nvl(ben_xdf_shd.g_old_rec.ext_global_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_ext_global_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ext_global_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_ext_global_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ext_global_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_ext_global_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ext_global_flag;




Procedure chk_cm_display_flag(p_ext_dfn_id           in number,
                            p_cm_display_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cm_display_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cm_display_flag
      <> nvl(ben_xdf_shd.g_old_rec.cm_display_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cm_display_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cm_display_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_cm_display_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cm_display_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','cm_display_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cm_display_flag;


-- ----------------------------------------------------------------------------
-- |------< chk_upd_cm_sent_dt_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   upd_cm_sent_dt_flag Value of lookup code.
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
Procedure chk_upd_cm_sent_dt_flag(p_ext_dfn_id           in number,
                            p_upd_cm_sent_dt_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_upd_cm_sent_dt_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_upd_cm_sent_dt_flag
      <> nvl(ben_xdf_shd.g_old_rec.upd_cm_sent_dt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_upd_cm_sent_dt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_upd_cm_sent_dt_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_upd_cm_sent_dt_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_upd_cm_sent_dt_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_upd_cm_sent_dt_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_upd_cm_sent_dt_flag;
--
/*
-- ----------------------------------------------------------------------------
-- |------< chk_use_eff_dt_for_chgs_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   use_eff_dt_for_chgs_flag Value of lookup code.
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
Procedure chk_use_eff_dt_for_chgs_flag(p_ext_dfn_id           in number,
                            p_use_eff_dt_for_chgs_flag        in varchar2,
                            p_effective_date              in date,
                            p_business_group_id           in number,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_eff_dt_for_chgs_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_eff_dt_for_chgs_flag
      <> nvl(ben_xdf_shd.g_old_rec.use_eff_dt_for_chgs_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_eff_dt_for_chgs_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_eff_dt_for_chgs_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_use_eff_dt_for_chgs_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
       --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_eff_dt_for_chgs_flag,
           p_effective_date => p_effective_date) then
        --
        -- raise error as does not exist as lookup
        --
        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_use_eff_dt_for_chgs_flag');
        fnd_message.set_token('TYPE','YES_NO');
        fnd_message.raise_error;
       --
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_use_eff_dt_for_chgs_flag;
--
*/
/*
-- ----------------------------------------------------------------------------
-- |------< chk_dates >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the lookup value is valid
--   and if not whether it is a valid oracle date.
--   It also checks if extract type is FULL PROFILE then startdate is required and
--   enddate should be NULL and if extract type is COMMUNICATIONS or CHANGES ONLY
--   then both dates are required.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   ext_dfn_id PK of record being inserted or updated.
--   data_typ_cd .
--   strt_dt Value of lookup code.
--   end_dt Value of lookup code.
--   effective_date effective date
--   object_version_number Object version number of record being
--                         inserted or updated.
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure x
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_dates(p_ext_dfn_id                in number,
                            p_data_typ_cd       in varchar2,
                            p_strt_dt           in varchar2,
                            p_end_dt            in varchar2,
                            p_effective_date    in date,
                            p_business_group_id           in number,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dates';
  l_api_updating boolean;
  l_dummy	date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_xdf_shd.api_updating
    (p_ext_dfn_id                => p_ext_dfn_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_data_typ_cd = 'F' then
    if not (p_strt_dt is not null
      and p_end_dt is null) then
      fnd_message.set_name('BEN','BEN_91776_END_DT_NULL');
      fnd_message.raise_error;
    end if;
  end if;
  --
  if p_data_typ_cd in ('C', 'CM') then
    if not (p_strt_dt is not null
      and p_end_dt is not null) then
      fnd_message.set_name('BEN','BEN_91780_STRT_DT_NULL');
      fnd_message.raise_error;
    end if;
  end if;
  --
  if (l_api_updating
      and p_strt_dt
      <> nvl(ben_xdf_shd.g_old_rec.strt_dt,hr_api.g_varchar2)
      or not l_api_updating)
      and p_strt_dt is not null then

     if substr(p_strt_dt,1,1) in ('0','1','2','3','4','5','6','7','8','9') then

       begin
--
	l_dummy := to_date(p_strt_dt,'DD/MM/YYYY');
        exception
          when others then
            fnd_message.set_name('BEN','BEN_91826_INVALID_DT');
            fnd_message.raise_error;
	end;
    else
    -- check if value of lookup falls within lookup type.
    --

    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_DT',
           p_lookup_code    => p_strt_dt,
           p_effective_date => p_effective_date) then
        --
        -- raise error

        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_strt_dt');
        fnd_message.set_token('TYPE','BEN_EXT_DT');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'BEN_EXT_DT',
           p_lookup_code    => p_strt_dt,
           p_effective_date => p_effective_date) then
        --
        -- raise error

        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_strt_dt');
        fnd_message.set_token('TYPE','BEN_EXT_DT');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
    --
    end if;
  end if;
  --
  if (l_api_updating
      and p_end_dt
      <> nvl(ben_xdf_shd.g_old_rec.end_dt,hr_api.g_varchar2)
      or not l_api_updating)
      and p_end_dt is not null then
	if substr(p_end_dt,1,1) in ('0','1','2','3','4','5','6','7','8','9') then
       begin
--
	l_dummy := to_date(p_end_dt,'DD/MM/YYYY');
        exception
          when others then
            fnd_message.set_name('BEN','BEN_91826_INVALID_DT');
            fnd_message.raise_error;
	end;

   else
    -- check if value of lookup falls within lookup type.
    --
    if p_business_group_id is not null then
    --
      if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_EXT_DT',
           p_lookup_code    => p_end_dt,
           p_effective_date => p_effective_date) then
        --
        -- raise error

        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_end_dt');
        fnd_message.set_token('TYPE','BEN_EXT_DT');
        fnd_message.raise_error;
      --
      end if;
    --
    else
    --
      if hr_api.not_exists_in_hrstanlookups
          (p_lookup_type    => 'BEN_EXT_DT',
           p_lookup_code    => p_end_dt,
           p_effective_date => p_effective_date) then
        --
        -- raise error

        fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
        fnd_message.set_token('FIELD','p_end_dt');
        fnd_message.set_token('TYPE','BEN_EXT_DT');
        fnd_message.raise_error;
      --
      end if;
    --
    end if;
    --
  end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dates;

--
*/
-- ----------------------------------------------------------------------------
-- |------------------------< chk_output_file >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that output file names do not have blank spaces.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_output_name is output file name
--     p_drctry_name is drctry file name
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
Procedure chk_output_file
           (p_output_name                 in   varchar2
           ,p_drctry_name                 in   varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_output_file';
l_dummy    char(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if instr(p_output_name,' ') > 0 or instr(p_drctry_name,' ') > 0 then
      fnd_message.set_name('BEN','BEN_91955_NAME_HAS_SPACE');
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_output_file;





Procedure chk_xdo_template_id
           (p_output_type                 in   varchar2
           ,p_xdo_template_id             in   number
           ,p_cm_display_flag             in   varchar2 )
is
l_proc      varchar2(72) := g_package||'chk_xdo_template_id';
l_dummy    char(1);
--
 cursor c is
 select data_source_code
 from xdo_templates_b
 where template_id = p_xdo_template_id ;

 l_source_code  xdo_templates_b.data_source_code%type ;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (  (not nvl(p_output_type,'F')  in ( 'F' , 'X' ) )  and p_xdo_template_id is null )
     or ( p_xdo_template_id is not null and (  p_output_type in ('F' , 'X') ) )
     then
      fnd_message.set_name('BEN','BEN_94036_EXT_XDO_PDF_NULL');
      fnd_message.raise_error;
  end if;

  if  p_xdo_template_id is not null then
      open c ;
      fetch c into l_source_code   ;
      if c%notfound then
          close c ;
          fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
          fnd_message.set_token('PROCEDURE', l_proc);
          fnd_message.set_token('CONSTRAINT_NAME', 'XDO_TEMPLATE_ID');
          fnd_message.raise_error;
      end if ;
      close c ;

      -- make sure correct template attched to correct extract defintionm
      -- display on must be attached to BENXMLWRIT
      -- display off must be attached to BENXWRIT

      if (p_cm_display_flag = 'Y' and  l_source_code <> 'BENXMLWRIT' ) OR
         (p_cm_display_flag <> 'Y' and  l_source_code =  'BENXMLWRIT' )  then

          fnd_message.set_name('BEN', 'BEN_94499_EXT_WRONG_XDO');
          fnd_message.raise_error;

      end if ;


  end if  ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_xdo_template_id;


--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_name_unique >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   ensure that an extract must have a name and not two extracts have the same name
--
-- Pre Conditions
--   None.
--
-- In Parameters
--     p_name is extract name
--     p_ext_dfn_id is extract definition id
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
          ( p_ext_dfn_id               in number
           ,p_name                 in   varchar2
           ,p_business_group_id    in   number
           ,p_legislation_code     in   varchar2)
is
l_proc	    varchar2(72) := g_package||'chk_name_unique';
l_dummy    char(1);
cursor c1 is select null
               from ben_ext_dfn
              Where ext_dfn_id <> nvl(p_ext_dfn_id,-1)
              and name = p_name
              and ((business_group_id is null and legislation_code is null) or
              (legislation_code is not null and
               business_group_id is null and
               legislation_code = p_legislation_code) or
              (business_group_id is not null and
               business_group_id = p_business_group_id));
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
hr_utility.trace('Call hr_startup_data_api_support.chk_upd_del_startup_action');
hr_utility.trace('BG = '||to_char(p_business_group_id));
hr_utility.trace('LC = '||p_legislation_code);

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

Procedure chk_child_recs(p_ext_dfn_id        in number
                         ) is
  --
  l_proc         varchar2(72) := g_package||'chk_child_recs';


  cursor c_ext_rslt is
  select 'x'
  from   ben_ext_rslt
  where  ext_dfn_id  = p_ext_dfn_id ;

  l_dummy  varchar2(1) ;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    open c_ext_rslt;
    fetch c_ext_rslt into l_dummy ;
    close c_ext_rslt;

    if l_dummy  is not null then
      fnd_message.set_name('PER','HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME','Extract Results');
      fnd_message.raise_error;

    end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_child_recs;


-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ben_xdf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_startup_action(True
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
  --
     hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  --
  END IF;

  --
  -- Call all supporting business operations
  --
  chk_ext_dfn_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_file_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_file_id          => p_rec.ext_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_prfl_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_apnd_rqst_id_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_output_name         => p_rec.output_name,
   p_apnd_rqst_id_flag         => p_rec.apnd_rqst_id_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_typ_cd
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_data_typ_cd         => p_rec.data_typ_cd,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_kickoff_wrt_prc_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_kickoff_wrt_prc_flag         => p_rec.kickoff_wrt_prc_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_use_eff_dt_for_chgs_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_use_eff_dt_for_chgs_flag         => p_rec.use_eff_dt_for_chgs_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_spcl_hndl_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_spcl_hndl_flag         => p_rec.spcl_hndl_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_global_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_global_flag         => p_rec.ext_global_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_cm_display_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_cm_display_flag         => p_rec.cm_display_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);

  chk_upd_cm_sent_dt_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_upd_cm_sent_dt_flag         => p_rec.upd_cm_sent_dt_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);
  --
/*
  chk_dates
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_data_typ_cd         => p_rec.data_typ_cd,
   p_strt_dt             => p_rec.strt_dt,
   p_end_dt              => p_rec.end_dt,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_output_file
  (p_output_name	=>p_rec.output_name
  ,p_drctry_name	=>p_rec.drctry_name);
  --
  chk_xdo_template_id
  (p_output_type        =>p_rec.output_type
  ,p_xdo_template_id    =>p_rec.xdo_template_id
  ,p_cm_display_flag    =>p_rec.cm_display_flag
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ben_xdf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  chk_startup_action(False
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code);
  IF hr_startup_data_api_support.g_startup_mode NOT IN ('GENERIC','STARTUP') THEN
  --
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate bus_grp
  --
  END IF;

  --
  -- Call all supporting business operations
  --
  chk_ext_dfn_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_file_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_file_id          => p_rec.ext_file_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_ext_crit_prfl_id
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_apnd_rqst_id_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_output_name         => p_rec.output_name,
   p_apnd_rqst_id_flag         => p_rec.apnd_rqst_id_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_data_typ_cd
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_data_typ_cd         => p_rec.data_typ_cd,
   p_ext_crit_prfl_id          => p_rec.ext_crit_prfl_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_kickoff_wrt_prc_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_kickoff_wrt_prc_flag         => p_rec.kickoff_wrt_prc_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
/*
  chk_use_eff_dt_for_chgs_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_use_eff_dt_for_chgs_flag         => p_rec.use_eff_dt_for_chgs_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_spcl_hndl_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_spcl_hndl_flag         => p_rec.spcl_hndl_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
   chk_ext_global_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_ext_global_flag        => p_rec.ext_global_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  ---
   chk_cm_display_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_cm_display_flag         => p_rec.cm_display_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  ---
  chk_upd_cm_sent_dt_flag
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_upd_cm_sent_dt_flag         => p_rec.upd_cm_sent_dt_flag,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name_unique
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
  p_name                 => p_rec.name,
  p_business_group_id    => p_rec.business_group_id,
  p_legislation_code     => p_rec.legislation_code);
  --
/*
  chk_dates
  (p_ext_dfn_id          => p_rec.ext_dfn_id,
   p_data_typ_cd         => p_rec.data_typ_cd,
   p_strt_dt         => p_rec.strt_dt,
   p_end_dt         => p_rec.end_dt,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
*/
  --
  chk_output_file
  (p_output_name	=>p_rec.output_name
  ,p_drctry_name	=>p_rec.drctry_name);
  --
  chk_xdo_template_id
  (p_output_type        =>p_rec.output_type
  ,p_xdo_template_id    =>p_rec.xdo_template_id
  ,p_cm_display_flag    =>p_rec.cm_display_flag
  );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_xdf_shd.g_rec_type
                         ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  chk_child_recs ( p_rec.ext_dfn_id);
  -- Call all supporting business operations
  --
  chk_startup_action(False
                    ,ben_xdf_shd.g_old_rec.business_group_id
                    ,ben_xdf_shd.g_old_rec.legislation_code);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_ext_dfn_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select b.business_group_id
    from  ben_ext_dfn b
    where b.ext_dfn_id      = p_ext_dfn_id
    ;
  --
  -- Declare local variables
  --
  l_business_group_id  number ;
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
                             p_argument       => 'ext_dfn_id',
                             p_argument_value => p_ext_dfn_id);
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
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
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
end ben_xdf_bus;

/
