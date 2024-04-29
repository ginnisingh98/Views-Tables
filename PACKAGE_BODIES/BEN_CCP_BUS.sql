--------------------------------------------------------
--  DDL for Package Body BEN_CCP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCP_BUS" as
/* $Header: beccprhi.pkb 120.1 2005/11/21 04:51:30 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ccp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvrd_dpnt_ctfn_prvdd_id >------|
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
--   cvrd_dpnt_ctfn_prvdd_id PK of record being inserted or updated.
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
Procedure chk_cvrd_dpnt_ctfn_prvdd_id(p_cvrd_dpnt_ctfn_prvdd_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvrd_dpnt_ctfn_prvdd_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_cvrd_dpnt_ctfn_prvdd_id                => p_cvrd_dpnt_ctfn_prvdd_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_cvrd_dpnt_ctfn_prvdd_id,hr_api.g_number)
     <>  ben_ccp_shd.g_old_rec.cvrd_dpnt_ctfn_prvdd_id) then
    --
    -- raise error as PK has changed
    --
    ben_ccp_shd.constraint_error('BEN_CVRD_DPNT_PVD_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_cvrd_dpnt_ctfn_prvdd_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_ccp_shd.constraint_error('BEN_CVRD_DPNT_PVD_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cvrd_dpnt_ctfn_prvdd_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_ctfn_rqd_flag >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvrd_dpnt_ctfn_prvdd_id PK of record being inserted or updated.
--   dpnt_dsgn_ctfn_rqd_flag Value of lookup code.
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
Procedure chk_dpnt_dsgn_ctfn_rqd_flag(p_cvrd_dpnt_ctfn_prvdd_id                in number,
                            p_dpnt_dsgn_ctfn_rqd_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_ctfn_rqd_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccp_shd.api_updating
    (p_cvrd_dpnt_ctfn_prvdd_id                => p_cvrd_dpnt_ctfn_prvdd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_ctfn_rqd_flag
      <> nvl(ben_ccp_shd.g_old_rec.dpnt_dsgn_ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_dsgn_ctfn_rqd_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dpnt_dsgn_ctfn_rqd_flag');
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_ctfn_rqd_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_ctfn_typ_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   cvrd_dpnt_ctfn_prvdd_id PK of record being inserted or updated.
--   dpnt_dsgn_ctfn_typ_cd Value of lookup code.
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
Procedure chk_dpnt_dsgn_ctfn_typ_cd(p_cvrd_dpnt_ctfn_prvdd_id     in number,
                                    p_dpnt_dsgn_ctfn_typ_cd       in varchar2,
                                    p_elig_cvrd_dpnt_id           in varchar2,
                                    p_prtt_enrt_actn_id           in varchar2,
                                    p_effective_date              in date,
                                    p_validation_start_date       in date,
                                    p_validation_end_date         in date,
                                    p_business_group_id           in number,
                                    p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_ctfn_typ_cd';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c3 is
     select null
       from ben_cvrd_dpnt_ctfn_prvdd_f ccp,
            ben_prtt_enrt_actn_f pea,
            ben_per_in_ler pil
         where ccp.elig_cvrd_dpnt_id = p_elig_cvrd_dpnt_id
           and ccp.dpnt_dsgn_ctfn_typ_cd = p_dpnt_dsgn_ctfn_typ_cd
           and pea.prtt_enrt_actn_id = p_prtt_enrt_actn_id
           and pea.prtt_enrt_actn_id = ccp.prtt_enrt_actn_id
           and pil.per_in_ler_id = pea.per_in_ler_id
           and pil.per_in_ler_stat_cd not in ('BCKDT', 'VOIDD')
           and ccp.cvrd_dpnt_ctfn_prvdd_id <> nvl(p_cvrd_dpnt_ctfn_prvdd_id, hr_api.g_number)
           and ccp.business_group_id  = p_business_group_id
           and p_effective_date between pea.effective_start_date
                                    and pea.effective_end_date
           and p_validation_start_date <= ccp.effective_end_date
           and p_validation_end_date >= ccp.effective_start_date

           ;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_ccp_shd.api_updating
    (p_cvrd_dpnt_ctfn_prvdd_id                => p_cvrd_dpnt_ctfn_prvdd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_ctfn_typ_cd
      <> nvl(ben_ccp_shd.g_old_rec.dpnt_dsgn_ctfn_typ_cd,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_CTFN_TYP',
           p_lookup_code    => p_dpnt_dsgn_ctfn_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_dpnt_dsgn_ctfn_typ_cd');
      fnd_message.set_token('TYPE','BEN_DPNT_CVG_CTFN_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
    open c3;
    fetch c3 into l_exists;
    if c3%found then
      close c3;
      --
      -- raise error as this ctfn row already exists for this beneficiary
    --
     fnd_message.set_name('BEN', 'BEN_91632_DUP_DPNT_CTFN');
     fnd_message.raise_error;
    --
    end if;
    close c3;
    --
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_ctfn_typ_cd;


--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_ctfn_recd_dt >------|
-- ----------------------------------------------------------------------------
--
-- Description
--  This procedure is used to check that the received date is not less
--   than the effective start date. W
--  Will be called only from UPDATE API.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_ctfn_prvdd_id PK of record being inserted or updated.
--   dpnt_dsgn_ctfn_recd_dt received date.
--   effective_date effective date.
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
Procedure chk_dpnt_dsgn_ctfn_recd_dt(
                     p_cvrd_dpnt_ctfn_prvdd_id in number,
                     p_effective_date          in date,
				     p_dpnt_dsgn_ctfn_recd_dt  in date,
                     p_validation_start_date   in date,
                     p_object_version_number   in number) is
  --
  -- 4740223, Added parameters cvrd_dpnt_ctfb_prvdd_id, eff_dt,
  -- OVN to the procedure
  l_proc  varchar2(72) := g_package||'chk_dpnt_dsgn_ctfn_recd_dt';
  l_api_updating boolean;
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := ben_ccp_shd.api_updating
    (p_cvrd_dpnt_ctfn_prvdd_id     => p_cvrd_dpnt_ctfn_prvdd_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_dpnt_dsgn_ctfn_recd_dt
      <> nvl(ben_ccp_shd.g_old_rec.dpnt_dsgn_ctfn_recd_dt,hr_api.g_date)
      or not l_api_updating) then
    --
    -- check if received date < than efective start date. .
    --
     if p_dpnt_dsgn_ctfn_recd_dt < p_validation_start_date then
      --
      fnd_message.set_name('BEN','BEN_94211_DPNT_CTFN_RECD_DT');
      fnd_message.raise_error;
      --
     end if;
    --
  End If;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_ctfn_recd_dt;
--
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
            (p_elig_cvrd_dpnt_id             in number default hr_api.g_number,
             p_prtt_enrt_actn_id             in number default hr_api.g_number,
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
    If ((nvl(p_elig_cvrd_dpnt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_elig_cvrd_dpnt_f',
             p_base_key_column => 'elig_cvrd_dpnt_id',
             p_base_key_value  => p_elig_cvrd_dpnt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_elig_cvrd_dpnt_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prtt_enrt_actn_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtt_enrt_actn_f',
             p_base_key_column => 'prtt_enrt_actn_id',
             p_base_key_value  => p_prtt_enrt_actn_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtt_enrt_actn_f';
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
            (p_cvrd_dpnt_ctfn_prvdd_id		in number,
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
       p_argument       => 'cvrd_dpnt_ctfn_prvdd_id',
       p_argument_value => p_cvrd_dpnt_ctfn_prvdd_id);
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
	(p_rec 			 in ben_ccp_shd.g_rec_type,
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
  chk_cvrd_dpnt_ctfn_prvdd_id
  (p_cvrd_dpnt_ctfn_prvdd_id          => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_ctfn_rqd_flag
  (p_cvrd_dpnt_ctfn_prvdd_id          => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_dpnt_dsgn_ctfn_rqd_flag         => p_rec.dpnt_dsgn_ctfn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_ctfn_typ_cd
  (p_cvrd_dpnt_ctfn_prvdd_id   => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_dpnt_dsgn_ctfn_typ_cd     => p_rec.dpnt_dsgn_ctfn_typ_cd,
   p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
   p_prtt_enrt_actn_id         => p_rec.prtt_enrt_actn_id,
   p_effective_date            => p_effective_date,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date       => p_validation_end_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  /* 4740223, Commented check in create API, coz the prvdd_dt can be
   < eff_strt_dt in case of Carry forward or recycle dependent.
   But such 'Update' is not allowed through the form.
   --
   chk_dpnt_dsgn_ctfn_recd_dt
   ( p_dpnt_dsgn_ctfn_recd_dt  => p_rec.dpnt_dsgn_ctfn_recd_dt,
     p_validation_start_date  => p_validation_start_date
    );
  rbingi */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_ccp_shd.g_rec_type,
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
  chk_cvrd_dpnt_ctfn_prvdd_id
  (p_cvrd_dpnt_ctfn_prvdd_id          => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_ctfn_rqd_flag
  (p_cvrd_dpnt_ctfn_prvdd_id          => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_dpnt_dsgn_ctfn_rqd_flag         => p_rec.dpnt_dsgn_ctfn_rqd_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_dpnt_dsgn_ctfn_typ_cd
  (p_cvrd_dpnt_ctfn_prvdd_id   => p_rec.cvrd_dpnt_ctfn_prvdd_id,
   p_dpnt_dsgn_ctfn_typ_cd     => p_rec.dpnt_dsgn_ctfn_typ_cd,
   p_elig_cvrd_dpnt_id         => p_rec.elig_cvrd_dpnt_id,
   p_prtt_enrt_actn_id         => p_rec.prtt_enrt_actn_id,
   p_effective_date            => p_effective_date,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date       => p_validation_end_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  -- 4740223, Added parameters cvrd_dpnt_ctfb_prvdd_id, eff_dt,
  -- ovn to the following call
  --
   chk_dpnt_dsgn_ctfn_recd_dt
   (p_cvrd_dpnt_ctfn_prvdd_id => p_rec.cvrd_dpnt_ctfn_prvdd_id,
    p_effective_date          => p_effective_date,
    p_dpnt_dsgn_ctfn_recd_dt  => p_rec.dpnt_dsgn_ctfn_recd_dt,
    p_validation_start_date   => p_validation_start_date,
    p_object_version_number   => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_elig_cvrd_dpnt_id             => p_rec.elig_cvrd_dpnt_id,
     p_prtt_enrt_actn_id             => p_rec.prtt_enrt_actn_id,
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
	(p_rec 			 in ben_ccp_shd.g_rec_type,
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
     p_cvrd_dpnt_ctfn_prvdd_id		=> p_rec.cvrd_dpnt_ctfn_prvdd_id);
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
  (p_cvrd_dpnt_ctfn_prvdd_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_cvrd_dpnt_ctfn_prvdd_f b
    where b.cvrd_dpnt_ctfn_prvdd_id      = p_cvrd_dpnt_ctfn_prvdd_id
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
                             p_argument       => 'cvrd_dpnt_ctfn_prvdd_id',
                             p_argument_value => p_cvrd_dpnt_ctfn_prvdd_id);
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
end ben_ccp_bus;


/
