--------------------------------------------------------
--  DDL for Package Body BEN_PTP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTP_BUS" as
/* $Header: beptprhi.pkb 120.1 2005/06/02 03:22:51 bmanyam noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ptp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_typ_id >------|
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
--   pl_typ_id PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_pl_typ_id(p_pl_typ_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_typ_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_typ_id                => p_pl_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_typ_id,hr_api.g_number)
     <>  ben_ptp_shd.g_old_rec.pl_typ_id) then
    --
    -- raise error as PK has changed
    --
    ben_ptp_shd.constraint_error('BEN_PL_TYP_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_typ_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ptp_shd.constraint_error('BEN_PL_TYP_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mn_enrl_num_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   no_mn_enrl_num_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_enrl_num_dfnd_flag(p_pl_typ_id                in number,
                            p_no_mn_enrl_num_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_enrl_num_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_enrl_num_dfnd_flag
      <> nvl(ben_ptp_shd.g_old_rec.no_mn_enrl_num_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_enrl_num_dfnd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_enrl_num_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_enrl_num_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_no_mx_enrl_num_dfnd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   no_mx_enrl_num_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_enrl_num_dfnd_flag(p_pl_typ_id                in number,
                            p_no_mx_enrl_num_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_enrl_num_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_enrl_num_dfnd_flag
      <> nvl(ben_ptp_shd.g_old_rec.no_mx_enrl_num_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_enrl_num_dfnd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_enrl_num_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_enrl_num_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_opt_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   opt_typ_cd Value of lookup code.
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
Procedure chk_opt_typ_cd(p_pl_typ_id                in number,
                            p_opt_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_opt_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_opt_typ_cd
      <> nvl(ben_ptp_shd.g_old_rec.opt_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_OPT_TYP',
           p_lookup_code    => p_opt_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_opt_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_irec_pln_in_rptg_grp >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if option type is changed from "Individual
--   Compensation Distribution" to something else, than the plans associated with the
--   the plan type being changed should not be associated to any reporting groups
--   of type "iRecruitment"
--   Called from update_validate.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id              PK of record being inserted or updated.
--   opt_typ_cd             Value of lookup code.
--   effective_date         effective date
--   business_group_id      Business group of the plan (null allowed in ben_pl_typ_f)
--   object_version_number  Object version number of record being
--                          inserted or updated.
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
Procedure chk_irec_pln_in_rptg_grp(p_pl_typ_id                in number,
                                   p_opt_typ_cd               in varchar2,
                                   p_effective_date              in date,
			           p_validation_start_date       in date,
			           p_validation_end_date         in date,
                                   p_business_group_id           in number,
                                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_irec_pln_in_rptg_grp';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from ben_pl_f pln, ben_popl_rptg_grp_f rgr, ben_rptg_grp bnr
    where pln.pl_typ_id = p_pl_typ_id
    and ( pln.business_group_id = p_business_group_id or p_business_group_id is null)
    and p_validation_start_date <= pln.effective_end_date
    and p_validation_end_date >= pln.effective_Start_date
    and pln.pl_id = rgr.pl_id
    and ( rgr.business_group_id = p_business_group_id or p_business_group_id is null)
    and greatest(p_validation_start_date, pln.effective_start_date) <= rgr.effective_end_date
    and least(p_validation_end_date, pln.effective_end_date) >= rgr.effective_Start_date
    and rgr.rptg_grp_id = bnr.rptg_grp_id
    and bnr.rptg_prps_cd = 'IREC'
    and ( bnr.business_group_id = p_business_group_id  or p_business_group_id is null);
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_opt_typ_cd <> nvl(ben_ptp_shd.g_old_rec.opt_typ_cd,hr_api.g_varchar2)
      and nvl(ben_ptp_shd.g_old_rec.opt_typ_cd,hr_api.g_varchar2) = 'COMP')
  then
    --
    --
      open c1;
      fetch c1 into l_dummy;
      if c1%found
      then
        --
	close c1;
	--
	-- Raise error : as there is plan associated with the plan type being updated - which
	-- is also associated to iRecruitment Reporting Group
	--
	fnd_message.set_name('BEN','BEN_93922_PTP_PL_RPTG_GRP_IREC');
	fnd_message.raise_error;
	--
      end if;
      --
      close c1;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_irec_pln_in_rptg_grp;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_opt_dsply_fmt_cd >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id              PK of record being inserted or updated.
--   opt_typ_cd             Option Type selected for the Plan Type
--   opt_dsply_fmt_cd       Value of lookup code.
--   effective_date         effective date
--   object_version_number  Object version number of record being
--                          inserted or updated.
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_opt_dsply_fmt_cd(p_pl_typ_id                in number,
			       p_opt_typ_cd               in varchar2,    --iRec
                               p_opt_dsply_fmt_cd         in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_opt_dsply_fmt_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_opt_dsply_fmt_cd
      <> nvl(ben_ptp_shd.g_old_rec.opt_dsply_fmt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_opt_dsply_fmt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_OPT_DSPLY_FMT',
           p_lookup_code    => p_opt_dsply_fmt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;

    --iRec
    --
    --Check if Self Service Display codes match Option Type code
    --When Option Type = Individual Compensation Distribution then valid SS Display values
    --are Check Box, Enterable Amount, List of Values, Radio Buttons, Select List
    --When Option Type is other than Individual Compensation Distribution then valid SS
    --Display values are Horizontally and Vertically
    --
 /* -- commented below code for it causes confusion for ICD.
    if ( p_opt_typ_cd = 'COMP' and p_opt_dsply_fmt_cd not in ('CB','EA','LOV','RB','SL') )
       OR ( p_opt_typ_cd <> 'COMP' and p_opt_dsply_fmt_cd not in ('HRZ','VRT') )
    then
      --
      -- Raise error as Self Service Display code does not match Option Type code
      --
      fnd_message.set_name('BEN','BEN_93923_OPTYP_SSDISP_INVALID');
      fnd_message.raise_error;
      --
    end if;
*/
    --
    --iRec
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_opt_dsply_fmt_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_comp_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   comp_typ_cd Value of lookup code.
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
Procedure chk_comp_typ_cd(p_pl_typ_id                in number,
                               p_comp_typ_cd              in varchar2,
                               p_effective_date           in date,
                               p_object_version_number    in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_comp_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date           => p_effective_date,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and p_comp_typ_cd
      <> nvl(ben_ptp_shd.g_old_rec.comp_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_comp_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_COMP_TYP',
           p_lookup_code    => p_comp_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_comp_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_typ_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   pl_typ_stat_cd Value of lookup code.
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
Procedure chk_pl_typ_stat_cd(p_pl_typ_id                in number,
                            p_pl_typ_stat_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_typ_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_pl_typ_id                => p_pl_typ_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pl_typ_stat_cd
      <> nvl(ben_ptp_shd.g_old_rec.pl_typ_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_typ_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_pl_typ_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pl_typ_stat_cd;



------------------------------------------------------------------------
----
-- |------< chk_name >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   Here we ensure that the name is unique
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   name name of the plan
--   validation_start_date the start date of the new row
--   validation_end_date the end date of the new row
--   business_group_id just what the parameter name is
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
Procedure chk_name(p_pl_typ_id                   in number,
                   p_name                        in varchar2,
                   p_effective_date              in date,
                   p_validation_start_date         in date,
                   p_validation_end_date           in date,
                   p_business_group_id           in number,
                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  --
  cursor csr_name is
     select null
        from BEN_PL_TYP_F
        where name = p_name
          and pl_typ_id <> nvl(p_pl_typ_id, hr_api.g_number)
          and business_group_id + 0 = p_business_group_id
          and p_validation_start_date <= effective_end_date
          and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_typ_id                     => p_pl_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_name <> ben_ptp_shd.g_old_rec.name) or
      not l_api_updating then
    --
    hr_utility.set_location('Entering:'||l_proc, 10);
    --
    -- check if this name already exist
    --
    open csr_name;
    fetch csr_name into l_exists;
    if csr_name%found then
      close csr_name;
      --
      -- raise error as UK1 is violated
      --
    fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
    fnd_message.raise_error;
--      ben_reg_shd.constraint_error('BEN_PL_TYP_F_UK1');
      --
    end if;
    --
    close csr_name;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
End chk_name;
--


------------------------------------------------------------------------
----
-- |------< chk_mn_mx_num >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to check that maximum enrollments allowed nuumber
--   >= Minimum enrollments allowed number.
--    max age number.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   mn_enrl_rqwd_num Value of Minimum enrollments allowed number.
--   mx_enrl_alwd_num Value of Maximum enrollments allowed number.
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
Procedure chk_mn_mx_num(p_pl_typ_id                in number,
                         p_no_mn_enrl_num_dfnd_flag  in varchar2,
                         p_mn_enrl_rqd_num                 in number,
                         p_no_mx_enrl_num_dfnd_flag  in varchar2,
                         p_mx_enrl_alwd_num                   in number,
                         p_object_version_number       in number) is
  --
  l_proc   varchar2(72)  := g_package || 'chk_mn_mx_num';
  l_api_updating   boolean;
  l_dummy  varchar2(1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --   Maximum enrollments allowed nuumber
  --   >= Minimum enrollments allowed number.
  --   if both are used.
  --
  if p_mn_enrl_rqd_num is not null and p_mx_enrl_alwd_num is not null then
      --
      -- raise error if max value not greater than or equal to min value
      --
    if  (p_mx_enrl_alwd_num < p_mn_enrl_rqd_num)  then
      fnd_message.set_name('BEN','BEN_91069_INVALID_MIN_MAX');
      fnd_message.raise_error;
    end if;
      --
      --
  end if;
    --
      -- If No Maximum enrolled allowed flag set to "on" (Y),
      --    then maximum enroll allowed number must be 0.
      --
   if  nvl( p_no_mx_enrl_num_dfnd_flag, hr_api.g_varchar2)  <> 'N'
         and (nvl(p_mx_enrl_alwd_num, 0) <> 0) then
      fnd_message.set_name('BEN','BEN_91056_MIN_VAL_NOT_NULL');
      fnd_message.raise_error;
   end if;
      --
   if  nvl( p_no_mn_enrl_num_dfnd_flag, hr_api.g_varchar2)  <> 'N'
         and (nvl(p_mn_enrl_rqd_num, 0) <> 0) then
      fnd_message.set_name('BEN','BEN_91054_MIN_VAL_NOT_NULL');
      fnd_message.raise_error;
   end if;
   --
   --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_mx_num;



--
--
------------------------------------------------------------------------
----
-- |------< chk_gsp_opt_typ_cd >------|
--
------------------------------------------------------------------------
----
--
-- Description
--   This procedure is used to ensure that there is only one active plan
--   type of type 'GSP'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_typ_id PK of record being inserted or updated.
--   mn_enrl_rqwd_num Value of Minimum enrollments allowed number.
--   mx_enrl_alwd_num Value of Maximum enrollments allowed number.
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
Procedure chk_gsp_opt_typ_cd(p_pl_typ_id                in number,
			     p_opt_typ_cd               in varchar2,
                             p_effective_date           in date,
                             --p_validation_start_date    in date,
                             --p_validation_end_date      in date,
                             p_business_group_id        in number,
                             p_object_version_number    in number) is
  --

  cursor c_opt_typ_cd is
    select 1
    from ben_pl_typ_f
    where opt_typ_cd = 'GSP'
    and pl_typ_id <> nvl(p_pl_typ_id, hr_api.g_number)
    and p_effective_date between effective_start_date and effective_end_date
    and business_group_id = p_business_group_id
    ;

  l_proc   varchar2(72)  := g_package || 'chk_gsp_opt_typ_cd';
  l_api_updating   boolean;
  l_dummy  number;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  l_api_updating := ben_ptp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_typ_id                     => p_pl_typ_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_opt_typ_cd = 'GSP' and
     ((l_api_updating
      and p_opt_typ_cd <> ben_ptp_shd.g_old_rec.opt_typ_cd) or
      not l_api_updating )then
    --
    open c_opt_typ_cd;
    fetch c_opt_typ_cd into l_dummy;
    if c_opt_typ_cd%found then
      close c_opt_typ_cd;
      --
      -- raise error there's already a GSP pln type
      --
      --fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
      fnd_message.set_name('BEN', 'BEN_93528_GSP_PLN_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
    close c_opt_typ_cd;
    --
  end if;
  --

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_gsp_opt_typ_cd;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
            (
	     p_datetrack_mode		     in varchar2,
             p_validation_start_date	     in date,
	     p_validation_end_date	     in date) Is
--
  l_proc	    varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name	    all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack update mode is valid
  --
  If (dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode)) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    --
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
            (p_pl_typ_id		in number,
             p_datetrack_mode		in varchar2,
	     p_validation_start_date	in date,
	     p_validation_end_date	in date) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'datetrack_mode',
     p_argument_value => p_datetrack_mode);
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = 'DELETE' or
      p_datetrack_mode = 'ZAP') then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_start_date',
       p_argument_value => p_validation_start_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'validation_end_date',
       p_argument_value => p_validation_end_date);
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'pl_typ_id',
       p_argument_value => p_pl_typ_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ptip_f',
           p_base_key_column => 'pl_typ_id',
           p_base_key_value  => p_pl_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ptip_f_1';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_f',
           p_base_key_column => 'pl_typ_id',
           p_base_key_value  => p_pl_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_f';
      Raise l_rows_exist;
    End If;
    -- 4395957 check existence of rows in ben_pl_typ_opt_typ_f as well.
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_typ_opt_typ_f',
           p_base_key_column => 'pl_typ_id',
           p_base_key_value  => p_pl_typ_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'BEN_PL_TYP_OPT_TYP_F_1';
      raise l_rows_exist;
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    ben_utility.child_exists_error(p_table_name => l_table_name);
    --
    --
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_ptp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_pl_typ_id
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_enrl_num_dfnd_flag
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mn_enrl_num_dfnd_flag         => p_rec.no_mn_enrl_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_enrl_num_dfnd_flag
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mx_enrl_num_dfnd_flag         => p_rec.no_mx_enrl_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_opt_typ_cd
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_opt_typ_cd         => p_rec.opt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_opt_dsply_fmt_cd
  (p_pl_typ_id             => p_rec.pl_typ_id,
   p_opt_typ_cd            => p_rec.opt_typ_cd,            --iRec
   p_opt_dsply_fmt_cd      => p_rec.opt_dsply_fmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_comp_typ_cd
  (p_pl_typ_id             => p_rec.pl_typ_id,
   p_comp_typ_cd           => p_rec.comp_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_typ_stat_cd
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_pl_typ_stat_cd         => p_rec.pl_typ_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_name               => p_rec.name,
   p_effective_date     => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_mx_num
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mn_enrl_num_dfnd_flag         => p_rec.no_mn_enrl_num_dfnd_flag,
   p_mn_enrl_rqd_num         => p_rec.mn_enrl_rqd_num,
   p_no_mx_enrl_num_dfnd_flag         => p_rec.no_mx_enrl_num_dfnd_flag,
   p_mx_enrl_alwd_num         => p_rec.mx_enrl_alwd_num,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gsp_opt_typ_cd(p_pl_typ_id   => p_rec.pl_typ_id,
		     p_opt_typ_cd  => p_rec.opt_typ_cd,
                     p_effective_date  => p_effective_date,
                     --p_validation_start_date
                     --p_validation_end_date
                     p_business_group_id  => p_rec.business_group_id,
                     p_object_version_number => p_rec.object_version_number  ) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ptp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
    hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_pl_typ_id
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_enrl_num_dfnd_flag
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mn_enrl_num_dfnd_flag         => p_rec.no_mn_enrl_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_enrl_num_dfnd_flag
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mx_enrl_num_dfnd_flag         => p_rec.no_mx_enrl_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_opt_typ_cd
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_opt_typ_cd         => p_rec.opt_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_opt_dsply_fmt_cd
  (p_pl_typ_id             => p_rec.pl_typ_id,
   p_opt_typ_cd            => p_rec.opt_typ_cd,            --iRec
   p_opt_dsply_fmt_cd      => p_rec.opt_dsply_fmt_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  --iRec
  chk_irec_pln_in_rptg_grp
  (p_pl_typ_id             => p_rec.pl_typ_id,
   p_opt_typ_cd            => p_rec.opt_typ_cd,
   p_effective_date        => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --iRec
  chk_comp_typ_cd
  (p_pl_typ_id             => p_rec.pl_typ_id,
   p_comp_typ_cd           => p_rec.comp_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pl_typ_stat_cd
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_pl_typ_stat_cd         => p_rec.pl_typ_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_name
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_name               => p_rec.name,
   p_effective_date     => p_effective_date,
   p_validation_start_date => p_validation_start_date,
   p_validation_end_date   => p_validation_end_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_mn_mx_num
  (p_pl_typ_id          => p_rec.pl_typ_id,
   p_no_mn_enrl_num_dfnd_flag         => p_rec.no_mn_enrl_num_dfnd_flag,
   p_mn_enrl_rqd_num         => p_rec.mn_enrl_rqd_num,
   p_no_mx_enrl_num_dfnd_flag         => p_rec.no_mx_enrl_num_dfnd_flag,
   p_mx_enrl_alwd_num         => p_rec.mx_enrl_alwd_num,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gsp_opt_typ_cd(p_pl_typ_id   => p_rec.pl_typ_id,
		     p_opt_typ_cd  => p_rec.opt_typ_cd,
                     p_effective_date  => p_effective_date,
                     --p_validation_start_date
                     --p_validation_end_date
                     p_business_group_id  => p_rec.business_group_id,
                     p_object_version_number => p_rec.object_version_number  ) ;

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in ben_ptp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_pl_typ_id		=> p_rec.pl_typ_id);
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

  (p_pl_typ_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pl_typ_f b
    where b.pl_typ_id      = p_pl_typ_id
    and   a.business_group_id = b.business_group_id;
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
                             p_argument       => 'pl_typ_id',
                             p_argument_value => p_pl_typ_id);
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
end ben_ptp_bus;

/
