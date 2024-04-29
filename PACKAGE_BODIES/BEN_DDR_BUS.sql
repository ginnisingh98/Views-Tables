--------------------------------------------------------
--  DDL for Package Body BEN_DDR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DDR_BUS" as
/* $Header: beddrrhi.pkb 115.9 2003/03/12 07:36:29 rpgupta ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ddr_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dsgn_rqmt_id >----------------------------|
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
--   dsgn_rqmt_id PK of record being inserted or updated.
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
Procedure chk_dsgn_rqmt_id(p_dsgn_rqmt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsgn_rqmt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dsgn_rqmt_id,hr_api.g_number)
     <>  ben_ddr_shd.g_old_rec.dsgn_rqmt_id) then
    --
    -- raise error as PK has changed
    --
    ben_ddr_shd.constraint_error('BEN_DSGN_RQMT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_dsgn_rqmt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ddr_shd.constraint_error('BEN_DSGN_RQMT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dsgn_rqmt_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_dsgn_typ_cd >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id PK of record being inserted or updated.
--   dsgn_typ_cd Value of lookup code.
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
Procedure chk_dsgn_typ_cd(p_dsgn_rqmt_id                in number,
                            p_dsgn_typ_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dsgn_typ_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dsgn_typ_cd
      <> nvl(ben_ddr_shd.g_old_rec.dsgn_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dsgn_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DSGN_TYP',
           p_lookup_code    => p_dsgn_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dsgn_typ_cd;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_no_mn_dpnts_rqd_or_mn_num >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the no_mn_num_dfnd_flag and
--   mn_dpnts_rqd_num items are mutually exclusive.
--   When the flag is set 'Y' then the value of mn_dpnts_rqd_num
--   must be null.  When the flag is set to 'N' then there must be a value in
--   mn_dpnts_rqd_num
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id     PK of record being inserted or updated.
--   no_mn_num_dfnd_flag.
--   mn_dpnts_rqd_num.
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
Procedure chk_no_mn_dpnts_rqd_or_mn_num(p_dsgn_rqmt_id    in number,
                            p_no_mn_num_dfnd_flag         in varchar2,
                            p_mn_dpnts_rqd_num            in number,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_dpnts_rqd_or_mn_num';

  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --

 l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    -- If  no_mn_num_dfnd_flag is "on", then mn_dpnts_rqd_num
    -- must be null.
    If p_no_mn_num_dfnd_flag = 'Y' and p_mn_dpnts_rqd_num is not null then
       fnd_message.set_name('BEN','BEN_91788_NO_MIN_OR_MIN_NUM');
       fnd_message.raise_error;
    end if;
    If p_no_mn_num_dfnd_flag = 'N' and p_mn_dpnts_rqd_num is null  then
       fnd_message.set_name('BEN','BEN_91788_NO_MIN_OR_MIN_NUM');
       fnd_message.raise_error;
    end if;
    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_dpnts_rqd_or_mn_num;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_no_mx_dpnts_or_mx_num_alwd >---------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the no_mx_num_dfnd_flag and
--   mx_dpnts_alwd_num items are mutually exclusive.
--   When the flag is set 'Y' then the value of mx_dpnts_alwd_num
--   must be null.  When the flag is set to 'N' then there must be a value in
--   mx_dpnts_alwd_num.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id     PK of record being inserted or updated.
--   no_mx_num_dfnd_flag.
--   mx_dpnts_alwd_num.
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
Procedure chk_no_mx_dpnts_or_mx_num_alwd(p_dsgn_rqmt_id          in number,
                                   p_no_mx_num_dfnd_flag         in varchar2,
                                   p_mx_dpnts_alwd_num           in number,
                                   p_effective_date              in date,
                                   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_dpnts_or_mx_num_alwd';

  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --

 l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
    -- If  no_mx_num_dfnd_flag is "on", then mx_dpnts_alwd_num
    -- must be null.
    If p_no_mx_num_dfnd_flag = 'Y' and p_mx_dpnts_alwd_num is not null then
       fnd_message.set_name('BEN','BEN_91789_NO_MAX_OR_MAX_NUM');
       fnd_message.raise_error;
    end if;
    If p_no_mx_num_dfnd_flag = 'N' and p_mx_dpnts_alwd_num is null  then
       fnd_message.set_name('BEN','BEN_91789_NO_MAX_OR_MAX_NUM');
       fnd_message.raise_error;
    end if;

    --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_dpnts_or_mx_num_alwd;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_cvr_all_elig_flag >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id PK of record being inserted or updated.
--   cvr_all_elig_flag Value of lookup code.
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
Procedure chk_cvr_all_elig_flag(p_dsgn_rqmt_id                in number,
                            p_cvr_all_elig_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvr_all_elig_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvr_all_elig_flag
      <> nvl(ben_ddr_shd.g_old_rec.cvr_all_elig_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cvr_all_elig_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvr_all_elig_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_no_mx_num_dfnd_flag >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id PK of record being inserted or updated.
--   no_mx_num_dfnd_flag Value of lookup code.
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
Procedure chk_no_mx_num_dfnd_flag(p_dsgn_rqmt_id                in number,
                            p_no_mx_num_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mx_num_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mx_num_dfnd_flag
      <> nvl(ben_ddr_shd.g_old_rec.no_mx_num_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_num_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mx_num_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_no_mn_num_dfnd_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id PK of record being inserted or updated.
--   no_mn_num_dfnd_flag Value of lookup code.
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
Procedure chk_no_mn_num_dfnd_flag(p_dsgn_rqmt_id                in number,
                            p_no_mn_num_dfnd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_no_mn_num_dfnd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_no_mn_num_dfnd_flag
      <> nvl(ben_ddr_shd.g_old_rec.no_mn_num_dfnd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_num_dfnd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_no_mn_num_dfnd_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_grp_rlshp_cd >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id PK of record being inserted or updated.
--   grp_rlshp_cd Value of lookup code.
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
Procedure chk_grp_rlshp_cd(p_dsgn_rqmt_id                in number,
                            p_grp_rlshp_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_grp_rlshp_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_grp_rlshp_cd
      <> nvl(ben_ddr_shd.g_old_rec.grp_rlshp_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_grp_rlshp_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_GRP_RLSHP',
           p_lookup_code    => p_grp_rlshp_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      hr_utility.set_message(801,'HR_LOOKUP_DOES_NOT_EXIST');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_grp_rlshp_cd;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_pln_oipl_opt_mutexcl >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to enforce the ARC relationship existing on
--   ben_dsgn_rqmt_f between plan, oipl, and opt.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id          PK of record being inserted or updated.
--   pl_id
--   oipl_id
--   opt_id
--   effective_date        Session date of record.
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_pln_oipl_opt_mutexcl(p_dsgn_rqmt_id           in number,
                                   p_pl_id                  in number,
                                   p_oipl_id                in number,
				   p_opt_id                 in number,
			           p_effective_date         in date,
                                   p_business_group_id      in number,
                                   p_object_version_number  in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pln_oipl_opt_mutexcl';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_pl_id        ben_pl_f.pl_id%TYPE;
  l_oipl_id      ben_oipl_f.oipl_id%TYPE;
  l_opt_id       ben_opt_f.opt_id%TYPE;

  --
  cursor c1 is
    select a.pl_id, a.oipl_id, a.opt_id
--    into   l_pl_id, l_oipl_id, l_opt_id
    from   ben_dsgn_rqmt_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.dsgn_rqmt_id = p_dsgn_rqmt_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ddr_shd.api_updating
    (p_dsgn_rqmt_id                => p_dsgn_rqmt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     or not l_api_updating) then
    --
    -- Check if there is mutually exclusivity.
    --
    open c1;
      --
    fetch c1 into l_pl_id, l_oipl_id, l_opt_id;
    if c1%found then
        --
      if p_pl_id is not null and
        (l_opt_id is not null or
         l_oipl_id is not null) then
            fnd_message.set_name('BEN','BEN_91926_PLN_OIPL_OPT_MUTEXC');
            fnd_message.raise_error;
      elsif p_opt_id is not null and
        (l_pl_id is not null or
         l_oipl_id is not null) then
            fnd_message.set_name('BEN','BEN_91927_OIPL_PLN_OPT_MUTEXC');
	    fnd_message.raise_error;
      elsif p_oipl_id is not null and
        (l_opt_id is not null or
         l_pl_id is not null) then
             fnd_message.set_name('BEN','BEN_91928_OPT_PLN_OIPL_MUTEXC');
	    fnd_message.raise_error;
      end if;
      --
    end if;
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pln_oipl_opt_mutexcl;
--
-- bug 2837189
-- validate duplication of records
-- ----------------------------------------------------------------------------
-- |------------------------< chk_dsgn_rqmt_uniq >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to enforce uniquness of the designation requirements
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dsgn_rqmt_id          PK of record being inserted or updated.
--   pl_id		   Plan id
--   oipl_id		   Option in Plan id
--   effective_date        Session date of record.
--   grp_rlshp_cd	   Group Relationship code
--   dsgn_typ_cd	   Designation Type code
--   business_group_id     Business group id of record being inserted.
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
Procedure chk_dsgn_rqmt_uniq(p_dsgn_rqmt_id           in number,
                             p_pl_id                  in number,
                             p_oipl_id                in number,
			     p_effective_date         in date,
                             p_business_group_id      in number,
                             p_grp_rlshp_cd           in varchar2,
                             p_dsgn_typ_cd            in varchar2,
                             p_object_version_number  in number) is
--
  l_proc         varchar2(72) := g_package||'chk_dsgn_rqmt_uniq';
  l_dummy        varchar2(1);

--
cursor c_chk_uniq_dsgn_rqmt is
    select 'X'
    from   ben_dsgn_rqmt_f
    where  business_group_id  = p_business_group_id
    and    grp_rlshp_cd = p_grp_rlshp_cd
    and    dsgn_typ_cd = p_dsgn_typ_cd
    and    p_effective_date
           between effective_start_date
           and     effective_end_date
    and    (pl_id = p_pl_id
    	    or
    	    oipl_id = p_oipl_id)
    and    dsgn_rqmt_id <> nvl(p_dsgn_rqmt_id, -999);

--
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    -- Check if the record already exists
    --
    open c_chk_uniq_dsgn_rqmt;
    fetch c_chk_uniq_dsgn_rqmt into l_dummy;
    close c_chk_uniq_dsgn_rqmt;

    if l_dummy is not null then
        --
            fnd_message.set_name('BEN','BEN_93354_GRP_RLSHP_TYP_UNIQUE');
            fnd_message.raise_error;
        --
    end if;
      --

   --

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dsgn_rqmt_uniq;

-- end bug 2837189


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
            (p_oipl_id                       in number default hr_api.g_number,
             p_opt_id                        in number default hr_api.g_number,
             p_pl_id                         in number default hr_api.g_number,
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
    If ((nvl(p_oipl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_oipl_f',
             p_base_key_column => 'oipl_id',
             p_base_key_value  => p_oipl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_oipl_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_opt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_opt_f',
             p_base_key_column => 'opt_id',
             p_base_key_value  => p_opt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_opt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_f',
             p_base_key_column => 'pl_id',
             p_base_key_value  => p_pl_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_f';
      Raise l_integrity_error;
    End If;
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
    ben_utility.parent_integrity_error(p_table_name => l_table_name);
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
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
            (p_dsgn_rqmt_id		in number,
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
       p_argument       => 'dsgn_rqmt_id',
       p_argument_value => p_dsgn_rqmt_id);
    --
    --
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
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in ben_ddr_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_dsgn_rqmt_id
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dsgn_typ_cd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_dsgn_typ_cd         => p_rec.dsgn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_dpnts_rqd_or_mn_num
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mn_num_dfnd_flag   => p_rec.no_mn_num_dfnd_flag,
   p_mn_dpnts_rqd_num      => p_rec.mn_dpnts_rqd_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_dpnts_or_mx_num_alwd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mx_num_dfnd_flag   => p_rec.no_mx_num_dfnd_flag,
   p_mx_dpnts_alwd_num     => p_rec.mx_dpnts_alwd_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvr_all_elig_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_cvr_all_elig_flag         => p_rec.cvr_all_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_num_dfnd_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mx_num_dfnd_flag         => p_rec.no_mx_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_num_dfnd_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mn_num_dfnd_flag         => p_rec.no_mn_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grp_rlshp_cd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_grp_rlshp_cd         => p_rec.grp_rlshp_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pln_oipl_opt_mutexcl
  (p_dsgn_rqmt_id              => p_rec.dsgn_rqmt_id,
   p_pl_id                     => p_rec.pl_id,
   p_oipl_id                   => p_rec.oipl_id,
   p_opt_id                    => p_rec.opt_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
   --
   --

   --bug 2837189
   chk_dsgn_rqmt_uniq
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id  ,
   p_effective_date        => p_effective_date ,
   p_business_group_id     => p_rec.business_group_id ,
   p_grp_rlshp_cd          => p_rec.grp_rlshp_cd,
   p_dsgn_typ_cd           => p_rec.dsgn_typ_cd,
   p_pl_id		   => p_rec.pl_id,
   p_oipl_id		   => p_rec.oipl_id,
   p_object_version_number => p_rec.object_version_number ) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ddr_shd.g_rec_type,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_dsgn_rqmt_id
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dsgn_typ_cd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_dsgn_typ_cd         => p_rec.dsgn_typ_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_dpnts_rqd_or_mn_num
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mn_num_dfnd_flag   => p_rec.no_mn_num_dfnd_flag,
   p_mn_dpnts_rqd_num      => p_rec.mn_dpnts_rqd_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_dpnts_or_mx_num_alwd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mx_num_dfnd_flag   => p_rec.no_mx_num_dfnd_flag,
   p_mx_dpnts_alwd_num     => p_rec.mx_dpnts_alwd_num,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvr_all_elig_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_cvr_all_elig_flag         => p_rec.cvr_all_elig_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mx_num_dfnd_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mx_num_dfnd_flag         => p_rec.no_mx_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_no_mn_num_dfnd_flag
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_no_mn_num_dfnd_flag         => p_rec.no_mn_num_dfnd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_grp_rlshp_cd
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id,
   p_grp_rlshp_cd         => p_rec.grp_rlshp_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_pln_oipl_opt_mutexcl
  (p_dsgn_rqmt_id              => p_rec.dsgn_rqmt_id,
   p_pl_id                     => p_rec.pl_id,
   p_oipl_id                   => p_rec.oipl_id,
   p_opt_id                    => p_rec.opt_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  --bug 2837189
 chk_dsgn_rqmt_uniq
  (p_dsgn_rqmt_id          => p_rec.dsgn_rqmt_id  ,
   p_effective_date        => p_effective_date ,
   p_business_group_id     => p_rec.business_group_id ,
   p_grp_rlshp_cd          => p_rec.grp_rlshp_cd,
   p_dsgn_typ_cd           => p_rec.dsgn_typ_cd,
   p_pl_id		   => p_rec.pl_id,
   p_oipl_id		   => p_rec.oipl_id,
   p_object_version_number => p_rec.object_version_number ) ;
  --

  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_oipl_id                       => p_rec.oipl_id,
             p_opt_id                        => p_rec.opt_id,
             p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_ddr_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
  l_dummy       varchar2(30);
  --
  cursor chk_dsgn_rqmt_rlshp_typ is
         select null
         from   ben_dsgn_rqmt_rlshp_typ
         where  dsgn_rqmt_id = p_rec.dsgn_rqmt_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Check for existence of child records in BEN_DSGN_RQMT_RLSHP_TYP
  -- table when PURGING.
  --
  open chk_dsgn_rqmt_rlshp_typ;
  --
  fetch chk_dsgn_rqmt_rlshp_typ into l_dummy;
  --
  if chk_dsgn_rqmt_rlshp_typ%found and
     p_datetrack_mode = 'ZAP' then
     --
     close chk_dsgn_rqmt_rlshp_typ;
     fnd_message.set_name('BEN', 'BEN_91970_GRP_RLSHP_TYP');
     fnd_message.raise_error;
     --
  end if;
  --
  close chk_dsgn_rqmt_rlshp_typ;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_dsgn_rqmt_id		=> p_rec.dsgn_rqmt_id);
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
  (p_dsgn_rqmt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_dsgn_rqmt_f b
    where b.dsgn_rqmt_id      = p_dsgn_rqmt_id
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
                             p_argument       => 'dsgn_rqmt_id',
                             p_argument_value => p_dsgn_rqmt_id);
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
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
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
end ben_ddr_bus;

/
