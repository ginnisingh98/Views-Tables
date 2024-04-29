--------------------------------------------------------
--  DDL for Package Body BEN_PCP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PCP_BUS" as
/* $Header: bepcprhi.pkb 115.13 2002/12/16 12:00:12 vsethi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pcp_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pl_pcp_id                   number         default null;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_pcp_id >------|
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
--   pl_pcp_id PK of record being inserted or updated.
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
Procedure chk_pl_pcp_id(p_pl_pcp_id                      in number,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_pcp_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                   => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_pcp_id,hr_api.g_number)
     <>  ben_pcp_shd.g_old_rec.pl_pcp_id) then
    --
    -- raise error as PK has changed
    --
    ben_pcp_shd.constraint_error('BEN_PL_PCP_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_pcp_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pcp_shd.constraint_error('BEN_PL_PCP_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_pcp_id;
--
-- ----------------------------------------------------------------------------
-- |------< 1 chk_pl_pcp_rec_exist >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to make sure that the record doesn't exist for the --   --   same plan
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id of a record.
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

Procedure chk_pl_pcp_rec_exists
          ( p_pl_id            in   number,
            p_pl_pcp_id        in number
          ) is

l_proc     varchar2(72) := g_package|| ' chk_pl_pcp_rec_exists';
l_dummy    number;
--cursor to check the row exists in the database or not

cursor c1 is
select pcp.pl_pcp_id
from   ben_pl_pcp pcp
Where  pcp.pl_id = p_pl_id
and    pcp.pl_pcp_id <> nvl(p_pl_pcp_id,-1)
;

--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     open c1;
     fetch c1 into l_dummy;
     if c1%found then
        close c1;
       -- Create new message in seed database (Plan Already exists for the
       -- particular plan id
	 fnd_message.set_name('BEN','BEN_92595_REC_EXISTS');
       fnd_message.raise_error;
    end if;
    close c1;

  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_pcp_rec_exists;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_strt_dt_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_pcp_id PK of record being inserted or updated.
--   pcp_strt_dt_cd Value of lookup code.
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
Procedure chk_pcp_strt_dt_cd(p_pl_pcp_id                in number,
                            p_pcp_strt_dt_cd         in varchar2,
			          p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_strt_dt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                   => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
 if p_pcp_strt_dt_cd is null then
      fnd_message.set_name('BEN','BEN_92593_DATA_NULL');
      fnd_message.set_token('FIELD', 'Start Date Code');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_pcp_strt_dt_cd      <>       nvl(ben_pcp_shd.g_old_rec.pcp_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_STRT_DT',
           p_lookup_code    => p_pcp_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_strt_dt_cd');
      fnd_message.set_token('TYPE','BEN_PCP_STRT_DT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_strt_dt_cd;
--
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_pcp_id PK of record being inserted or updated.
--   pcp_dsgn_cd Value of lookup code.
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
Procedure chk_pcp_dsgn_cd(p_pl_pcp_id                in number,
                            p_pcp_dsgn_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                   => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
--Ask Sharmista what is the token name for this CD
 if p_pcp_dsgn_cd is null then
      fnd_message.set_name('BEN','BEN_92593_DATA_NULL');
      fnd_message.set_token('FIELD', 'Designation Code');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_pcp_dsgn_cd      <>       nvl(ben_pcp_shd.g_old_rec.pcp_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_DSGN',
           p_lookup_code    => p_pcp_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_dsgn_cd');
      fnd_message.set_token('TYPE','BEN_PCP_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_dsgn_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_dpnt_dsgn_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_pcp_id PK of record being inserted or updated.
--   pcp_dpnt_dsgn_cd Value of lookup code.
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
Procedure chk_pcp_dpnt_dsgn_cd(p_pl_pcp_id                in number,
                            p_pcp_dpnt_dsgn_cd         in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_dpnt_dsgn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                   => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
--Ask Sharmista what is the token name for this CD
 if p_pcp_dpnt_dsgn_cd is null then
      fnd_message.set_name('BEN','BEN_92593_DATA_NULL');
      fnd_message.set_token('FIELD', 'Dependent Designation Code');
      fnd_message.raise_error;
  end if;
  if (l_api_updating
      and p_pcp_dpnt_dsgn_cd      <>       nvl(ben_pcp_shd.g_old_rec.pcp_dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_dpnt_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PCP_DSGN',
           p_lookup_code    => p_pcp_dpnt_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_dpnt_dsgn_cd');
      fnd_message.set_token('TYPE','BEN_PCP_DPNT_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_dpnt_dsgn_cd;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_rpstry_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   when pcp_rpstry_flag=yes.
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_pcp_id PK of record being inserted or updated.
--   pcp_rpstry_flag Value of lookup code.
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
Procedure chk_pcp_rpstry_flag(p_pl_pcp_id                 in number,
				    p_pcp_rpstry_flag             in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_rpstry_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pcp_rpstry_flag
      <> nvl(ben_pcp_shd.g_old_rec.pcp_rpstry_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_rpstry_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pcp_rpstry_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_rpstry_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_rpstry_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_can_keep_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   It also checks if output filename is null when pcp_can_keep_flag=yes.
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_pcp_id PK of record being inserted or updated.
--   pcp_can_keep_flag Value of lookup code.
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
Procedure chk_pcp_can_keep_flag(p_pl_pcp_id                 in number,
                            p_pcp_can_keep_flag             in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_can_keep_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pcp_can_keep_flag
      <> nvl(ben_pcp_shd.g_old_rec.pcp_can_keep_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_can_keep_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pcp_can_keep_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_can_keep_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_can_keep_flag;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_pcp_radius_warn_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--   It also checks if output filename is null when pcp_radius_warn_flag=yes.
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_pcp_id PK of record being inserted or updated.
--   pcp_radius_warn_flag Value of lookup code.
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
Procedure chk_pcp_radius_warn_flag(p_pl_pcp_id                 in number,
                            p_pcp_radius_warn_flag             in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_radius_warn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pcp_shd.api_updating
    (p_pl_pcp_id                => p_pl_pcp_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pcp_radius_warn_flag
      <> nvl(ben_pcp_shd.g_old_rec.pcp_radius_warn_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pcp_radius_warn_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_pcp_radius_warn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pcp_radius_warn_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pcp_radius_warn_flag;
--
-- ----------------------------------------------------------------------------
-- |------< 1 chk_pl_pcp_radius_parm >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the pcp_radius, pcp_radius_uom, pcp_radius_warn_flag
--   can not have a value unless the pcp_rpstry_flag = 'Y'. However, the pcp_radius is not
--   required if the flag is 'Y'.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pcp_rpstry_flag of record
--   pcp_radius of record
--   pcp_radius_uom of record
--   pcp_radius_warn_flag of record.
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

Procedure chk_pl_pcp_radius_parm(p_pcp_rpstry_flag                 varchar2
                             ,p_pcp_radius                      number
                             ,p_pcp_radius_uom                  varchar2
                             ,p_pcp_radius_warn_flag            varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_pcp_radius_parm';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    --
    if p_pcp_rpstry_flag = 'N' then
       if (p_pcp_radius is not null or p_pcp_radius_uom is not null) then
        --
        -- Raise error as pcp_radius, pcp_radius_uom are null
        --
        fnd_message.set_name('BEN','BEN_92560_RADIUS_PARM');
        fnd_message.raise_error;
        end if;
    end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_pcp_radius_parm;
--
-- ----------------------------------------------------------------------------
-- |------< 3 chk_pl_pcp_record >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that the ben_pl_pcp record for plans that are
-- savings, inputed icome nor flex-plans could not be created
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id FK of record
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
Procedure chk_pl_pcp_record
          ( p_pl_id            in   number
          , p_effective_date   in   date) is

l_proc     varchar2(72) := g_package|| ' chk_pl_pcp_record';
l_svgs_pl_flag             ben_pl_f.svgs_pl_flag%type;
l_imptd_incm_calc_cd       ben_pl_f.imptd_incm_calc_cd%type;
l_invk_flx_cr_pl_flag      ben_pl_f.invk_flx_cr_pl_flag%type;
l_invk_dcln_prtn_pl_flag   ben_pl_f.invk_dcln_prtn_pl_flag%type;


--cursor to check the values in svgs_pl_flag, imptd_incm_calc_cd, invk_flx_cr_pl_flag
cursor c1 is
  select svgs_pl_flag, imptd_incm_calc_cd, invk_flx_cr_pl_flag, invk_dcln_prtn_pl_flag
       from   ben_pl_f
       Where  pl_id = p_pl_id
         and  p_effective_date between effective_start_date and
              effective_end_date;

--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     --- when the rate is imputing chek the plan in imputing
     open c1;
     fetch c1 into l_svgs_pl_flag, l_imptd_incm_calc_cd, l_invk_flx_cr_pl_flag, l_invk_dcln_prtn_pl_flag;
     close c1;

     if ((l_svgs_pl_flag = 'Y')
     or (l_imptd_incm_calc_cd is NOT NULL)
     or (l_invk_flx_cr_pl_flag = 'Y')
     or (l_invk_dcln_prtn_pl_flag = 'Y')) then
	 fnd_message.set_name('BEN','BEN_92562_SVG_INC');
         fnd_message.raise_error;
     end if;
  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_pcp_record;

-- ----------------------------------------------------------------------------
-- |------< 4 chk_pl_pcp_cds >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the pcp_dsgn_cd and pcp_dpnt_dsgn_cd's must
--   have a value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pcp_dpnt_cd of record
--   pcp_dpnt_dsgn_cd of record
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

Procedure chk_pl_pcp_cds(p_pcp_dsgn_cd                 varchar2
                        ,p_pcp_dpnt_dsgn_cd            varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_pcp_cds';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    -- check if pcp_dsgn_cd, pcp_dpnt_dsgn_cd is not null
    --
    if p_pcp_dsgn_cd is null or p_pcp_dpnt_dsgn_cd is null then
        --
        -- Raise error as pcp_dsgn_cd and pcp_dpnt_dsgn_cd should not be null
        --
        fnd_message.set_name('BEN','BEN_92563_DSGN_REQ');
        fnd_message.raise_error;
    end if;

  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_pcp_cds;
--
--
-- ----------------------------------------------------------------------------
-- |------< 5 chk_pl_pcp_rpstry >------|
-- ----------------------------------------------------------------------------
--
-- Description
-- This procedure is used to check that the plan cannot have a ben_pl_pcp row
-- with pcp_rpstry_flag = 'Y' until it has a ben_popl_org_f/ben_popl_org_role_f
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id
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

Procedure chk_pl_pcp_rpstry
          ( p_pl_id            in   number,
            p_pcp_rpstry_flag  in   varchar) is

l_proc     varchar2(72) := g_package|| ' chk_pl_pcp_rpstry';
l_dummy    varchar2(1);

--cursor to check the row exist in the ben_popl_org_f table.
cursor c1 is select 'x'
       from   ben_popl_org_f
       Where  pl_id = p_pl_id;
--
Begin
     hr_utility.set_location('Entering:'||l_proc, 5);
     --
     IF p_pcp_rpstry_flag = 'Y' then
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
	 fnd_message.set_name('BEN','BEN_92564_PCP_LOC');
       fnd_message.raise_error;
     end if;
     close c1;
     END IF;

  hr_utility.set_location('Leaving:'||l_proc, 15);
End chk_pl_pcp_rpstry;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pl_pcp_id                            in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ben_pl_pcp pcp
     where pcp.pl_pcp_id = p_pl_pcp_id
       and pbg.business_group_id = pcp.business_group_id;
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
    ,p_argument           => 'pl_pcp_id'
    ,p_argument_value     => p_pl_pcp_id
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
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_pl_pcp_id                            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ben_pl_pcp pcp
     where pcp.pl_pcp_id = p_pl_pcp_id
       and pbg.business_group_id = pcp.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pl_pcp_id'
    ,p_argument_value     => p_pl_pcp_id
    );
  --
  if ( nvl(ben_pcp_bus.g_pl_pcp_id, hr_api.g_number)
       = p_pl_pcp_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ben_pcp_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    ben_pcp_bus.g_pl_pcp_id         := p_pl_pcp_id;
    ben_pcp_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pl_pcp_id is not null)  and (
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute_category, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute1, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute2, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute3, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute4, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute5, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute6, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute7, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute8, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute9, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute10, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute11, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute12, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute13, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute14, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute15, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute16, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute17, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute18, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute19, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute20, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute21, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute22, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute23, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute24, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute25, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute26, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute27, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute28, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute29, hr_api.g_varchar2)  or
    nvl(ben_pcp_shd.g_old_rec.pcp_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pcp_attribute30, hr_api.g_varchar2) ))
    or (p_rec.pl_pcp_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'BEN'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'PCP_ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'PCP_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pcp_attribute1
      ,p_attribute2_name                 => 'PCP_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pcp_attribute2
      ,p_attribute3_name                 => 'PCP_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pcp_attribute3
      ,p_attribute4_name                 => 'PCP_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pcp_attribute4
      ,p_attribute5_name                 => 'PCP_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pcp_attribute5
      ,p_attribute6_name                 => 'PCP_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pcp_attribute6
      ,p_attribute7_name                 => 'PCP_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pcp_attribute7
      ,p_attribute8_name                 => 'PCP_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pcp_attribute8
      ,p_attribute9_name                 => 'PCP_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pcp_attribute9
      ,p_attribute10_name                => 'PCP_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pcp_attribute10
      ,p_attribute11_name                => 'PCP_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pcp_attribute11
      ,p_attribute12_name                => 'PCP_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pcp_attribute12
      ,p_attribute13_name                => 'PCP_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pcp_attribute13
      ,p_attribute14_name                => 'PCP_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pcp_attribute14
      ,p_attribute15_name                => 'PCP_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pcp_attribute15
      ,p_attribute16_name                => 'PCP_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pcp_attribute16
      ,p_attribute17_name                => 'PCP_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pcp_attribute17
      ,p_attribute18_name                => 'PCP_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pcp_attribute18
      ,p_attribute19_name                => 'PCP_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pcp_attribute19
      ,p_attribute20_name                => 'PCP_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pcp_attribute20
      ,p_attribute21_name                => 'PCP_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pcp_attribute21
      ,p_attribute22_name                => 'PCP_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pcp_attribute22
      ,p_attribute23_name                => 'PCP_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pcp_attribute23
      ,p_attribute24_name                => 'PCP_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pcp_attribute24
      ,p_attribute25_name                => 'PCP_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pcp_attribute25
      ,p_attribute26_name                => 'PCP_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pcp_attribute26
      ,p_attribute27_name                => 'PCP_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pcp_attribute27
      ,p_attribute28_name                => 'PCP_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pcp_attribute28
      ,p_attribute29_name                => 'PCP_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pcp_attribute29
      ,p_attribute30_name                => 'PCP_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pcp_attribute30
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in ben_pcp_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ben_pcp_shd.api_updating
      (p_pl_pcp_id                            => p_rec.pl_pcp_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in ben_pcp_shd.g_rec_type ,
   p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --

 chk_pl_pcp_id(p_pl_pcp_id                     => p_rec.pl_pcp_id,
               p_object_version_number         => p_rec.object_version_number);
  --

 chk_pl_pcp_rec_exists ( p_pl_id               => p_rec.pl_id,
                        p_pl_pcp_id               => p_rec.pl_pcp_id
                        );

 chk_pcp_strt_dt_cd(p_pl_pcp_id               => p_rec.pl_pcp_id,
                            p_pcp_strt_dt_cd           => p_rec.pcp_strt_dt_cd,
                            p_effective_date           => p_effective_date,
                            p_object_version_number    => p_rec.object_version_number);

 chk_pcp_dsgn_cd(p_pl_pcp_id                  =>  p_rec.pl_pcp_id,
                            p_pcp_dsgn_cd              =>  p_rec.pcp_dsgn_cd,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

 chk_pcp_dpnt_dsgn_cd(p_pl_pcp_id             =>  p_rec.pl_pcp_id,
                            p_pcp_dpnt_dsgn_cd         =>  p_rec.pcp_dpnt_dsgn_cd,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

 chk_pcp_rpstry_flag(p_pl_pcp_id              =>  p_rec.pl_pcp_id,
                            p_pcp_rpstry_flag          =>  p_rec.pcp_rpstry_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

 chk_pcp_can_keep_flag(p_pl_pcp_id            =>  p_rec.pl_pcp_id,
                            p_pcp_can_keep_flag        =>  p_rec.pcp_can_keep_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

 chk_pcp_radius_warn_flag(p_pl_pcp_id         =>  p_rec.pl_pcp_id,
                            p_pcp_radius_warn_flag     =>  p_rec.pcp_radius_warn_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

 chk_pl_pcp_radius_parm(p_pcp_rpstry_flag       => p_rec.pcp_rpstry_flag
                   ,p_pcp_radius            => p_rec.pcp_radius
                   ,p_pcp_radius_uom        => p_rec.pcp_radius_uom
                   ,p_pcp_radius_warn_flag  => p_rec.pcp_radius_warn_flag);

 chk_pl_pcp_record (p_pl_id          => p_rec.pl_id
                   ,p_effective_date => p_effective_date);

 chk_pl_pcp_cds(p_pcp_dsgn_cd         => p_rec.pcp_dsgn_cd
              ,p_pcp_dpnt_dsgn_cd    => p_rec.pcp_dpnt_dsgn_cd);

 chk_pl_pcp_rpstry ( p_pl_id           => p_rec.pl_id
                    ,p_pcp_rpstry_flag => p_rec.pcp_rpstry_flag);



  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  -- Call all supporting business operations
  --

  --ben_pcp_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in ben_pcp_shd.g_rec_type
  ,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_pl_pcp_id(p_pl_pcp_id                     => p_rec.pl_pcp_id,
               p_object_version_number         => p_rec.object_version_number);
   --
 chk_pl_pcp_rec_exists ( p_pl_id               => p_rec.pl_id,
                        p_pl_pcp_id               => p_rec.pl_pcp_id
                        );

  chk_pcp_strt_dt_cd(p_pl_pcp_id               => p_rec.pl_pcp_id,
                            p_pcp_strt_dt_cd           => p_rec.pcp_strt_dt_cd,
                            p_effective_date           => p_effective_date,
                            p_object_version_number    => p_rec.object_version_number);

  chk_pcp_dsgn_cd(p_pl_pcp_id                  =>  p_rec.pl_pcp_id,
                            p_pcp_dsgn_cd              =>  p_rec.pcp_dsgn_cd,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

  chk_pcp_dpnt_dsgn_cd(p_pl_pcp_id             =>  p_rec.pl_pcp_id,
                            p_pcp_dpnt_dsgn_cd         =>  p_rec.pcp_dpnt_dsgn_cd,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

  chk_pcp_rpstry_flag(p_pl_pcp_id              =>  p_rec.pl_pcp_id,
                            p_pcp_rpstry_flag          =>  p_rec.pcp_rpstry_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

   chk_pcp_can_keep_flag(p_pl_pcp_id            =>  p_rec.pl_pcp_id,
                            p_pcp_can_keep_flag        =>  p_rec.pcp_can_keep_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

   chk_pcp_radius_warn_flag(p_pl_pcp_id         =>  p_rec.pl_pcp_id,
                            p_pcp_radius_warn_flag     =>  p_rec.pcp_radius_warn_flag,
                            p_effective_date           =>  p_effective_date,
                            p_object_version_number    =>  p_rec.object_version_number);

   chk_pl_pcp_radius_parm(p_pcp_rpstry_flag       => p_rec.pcp_rpstry_flag
                   ,p_pcp_radius            => p_rec.pcp_radius
                   ,p_pcp_radius_uom        => p_rec.pcp_radius_uom
                   ,p_pcp_radius_warn_flag  => p_rec.pcp_radius_warn_flag);

   chk_pl_pcp_record (p_pl_id          => p_rec.pl_id
                     ,p_effective_date => p_effective_date);

   chk_pl_pcp_cds(p_pcp_dsgn_cd         => p_rec.pcp_dsgn_cd
              ,p_pcp_dpnt_dsgn_cd    => p_rec.pcp_dpnt_dsgn_cd);

   chk_pl_pcp_rpstry ( p_pl_id           => p_rec.pl_id
                    ,p_pcp_rpstry_flag => p_rec.pcp_rpstry_flag);

   hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
   --
   chk_non_updateable_args
    (p_rec              => p_rec
    );
   --
   --
   --ben_pcp_bus.chk_df(p_rec);
   --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ben_pcp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --chk_pl_pcp_rec_exists ( p_pl_id               => p_rec.pl_id);


  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ben_pcp_bus;

/
