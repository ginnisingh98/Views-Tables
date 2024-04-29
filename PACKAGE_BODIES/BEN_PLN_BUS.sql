--------------------------------------------------------
--  DDL for Package Body BEN_PLN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLN_BUS" as
/* $Header: beplnrhi.pkb 120.8.12010000.2 2008/08/18 09:47:19 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pln_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_pl_id >----------------------------|
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
--   pl_id          PK of record being inserted or updated.
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
Procedure chk_pl_id(p_pl_id                     in number,
                    p_effective_date            in date,
                    p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_pl_id,hr_api.g_number)
     <>  ben_pln_shd.g_old_rec.pl_id) then
    --
    -- raise error as PK has changed
    --
    ben_pln_shd.constraint_error('BEN_PL_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_pl_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pln_shd.constraint_error('BEN_PL_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_id;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_irec_pln_in_rptg_grp >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to ensure that change of plan type from "Individual
--   Compensation Distribution" plan type to plan type that is not of option
--   "Individual Compensation Distribution", is not allowed unless
--   the plan is not associated with the any reporting groups of type "iRecruitment"
--   Called from update_validate.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                  PK of record being inserted or updated.
--   pl_typ_id              Plan Type ID
--   effective_date         effective date
--   validation_start_date  Start date of the record
--   validation_end_date    End date of the record
--   business_group_id      Business group of the plan (null allowed in ben_pl_f)
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
Procedure chk_irec_pln_in_rptg_grp(p_pl_id                       in number,
                                   p_pl_typ_id                   in number,
                                   p_effective_date              in date,
			           p_validation_start_date       in date,
			           p_validation_end_date         in date,
                                   p_business_group_id           in number,
				   p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_irec_pln_in_rptg_grp';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_old_opt_typ_cd   varchar2(30);
  l_new_opt_typ_cd   varchar2(30);
 --
  cursor c1 is
    select null
    from ben_popl_rptg_grp_f rgr, ben_rptg_grp bnr
    where rgr.pl_id = p_pl_id
    and ( rgr.business_group_id = p_business_group_id or p_business_group_id is null)
    and p_validation_start_date <= rgr.effective_end_date
    and p_validation_end_date >= rgr.effective_Start_date
    and rgr.rptg_grp_id = bnr.rptg_grp_id
    and bnr.rptg_prps_cd = 'IREC'
    and ( bnr.business_group_id = p_business_group_id  or p_business_group_id is null);
  --
  cursor c_get_ptp_opt_typ_cd (p_pl_typ_id in number) is
    select opt_typ_cd
    from ben_pl_typ_f ptp
    where ptp.pl_typ_id = p_pl_typ_id
    and p_effective_date between ptp.effective_start_date and ptp.effective_end_date;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pl_typ_id <> nvl(ben_pln_shd.g_old_rec.pl_typ_id,hr_api.g_number) )
  then
    --
    --  Get Option Code for old plan type
    --
    open c_get_ptp_opt_typ_cd(ben_pln_shd.g_old_rec.pl_typ_id);
    fetch c_get_ptp_opt_typ_cd into l_old_opt_typ_cd;
    --
    if c_get_ptp_opt_typ_cd%found and l_old_opt_typ_cd = 'COMP'
    then
    --
      close c_get_ptp_opt_typ_cd;
      --
      -- Get Option code for new plan type
      --
      open c_get_ptp_opt_typ_cd(p_pl_typ_id);
      fetch c_get_ptp_opt_typ_cd into l_new_opt_typ_cd;
      --
      if c_get_ptp_opt_typ_cd%found and l_new_opt_typ_cd <> 'COMP'
      then
      --
        --
        -- Plan type has been changed from ICD to non ICD
	--
        open c1;
        fetch c1 into l_dummy;
	--
        if c1%found
        then
          --
          close c_get_ptp_opt_typ_cd;
	  close c1;
  	  --
  	  -- Raise error : as there is plan associated with the plan type being updated - which
	  -- is also associated to iRecruitment Reporting Group
	  --
	  fnd_message.set_name('BEN','BEN_93921_PL_RPTG_GRP_IREC');
	  fnd_message.raise_error;
	  --
        end if;
        --
        close c1;
      --
      end if;
      --close c_get_ptp_opt_typ_cd;
    --
    end if;
    close c_get_ptp_opt_typ_cd;
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_irec_pln_in_rptg_grp;
--
Procedure chk_compare_claims_cd (p_pl_id                 in number ,
                                 p_effective_date        in date,
                                 p_business_group_id     in number,
                                 p_cmpr_clms_to_cvg_or_bal_cd in varchar2,
                                 p_object_version_number in number) is
--
  l_proc         varchar2(300) := g_package||'chk_compare_claims_cd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_prtt_reimbmt_rqst_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.pl_id = p_pl_id
    and    a.prtt_reimbmt_rqst_stat_cd <> 'VOIDD';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and ben_pln_shd.g_old_rec.cmpr_clms_to_cvg_or_bal_cd is not null
     and nvl(p_cmpr_clms_to_cvg_or_bal_cd,'zzz') <>
       ben_pln_shd.g_old_rec.cmpr_clms_to_cvg_or_bal_cd )
   then
     --
     open c1;
     fetch c1 into l_dummy;
     if c1%found then
       --
       close c1;
       fnd_message.set_name('BEN','BEN_94621_CMPR_CLMS_CD');
       fnd_message.raise_error;
       --
     end if;
     close c1;
  end if;
end;


-- ----------------------------------------------------------------------------

Procedure chk_pl_group_child(p_pl_id                 in number ,
                             p_opt_typ_cd            in varchar2 ,
                             p_effective_date        in date,
                             p_name                  in varchar2) is



 cursor c_pl_cwb is
  select plt.opt_typ_cd
    from ben_pl_typ_f plt,
         ben_pl_f pl
   where pl.pl_id = p_pl_id
     and plt.pl_typ_id  = pl.pl_typ_id
     and p_effective_date between plt.effective_start_date
          and  plt.effective_end_Date
     and p_effective_date between pl.effective_start_date
          and  pl.effective_end_Date  ;

cursor c_child_exist is
   select 'x'
     from  ben_pl_f
     where group_pl_id = p_pl_id
       and pl_id <> p_pl_id
       and effective_end_date > p_effective_date
   ;
     -- dont validate the date
  l_dummy  varchar2(1) ;
  l_opt_typ_cd  ben_pl_typ_f.opt_typ_cd%type ;
  l_proc         varchar2(72) := g_package||'chk_pl_group_child';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  l_opt_typ_cd := p_opt_typ_cd ;
  if p_opt_typ_cd is null then
     open c_pl_cwb ;
     fetch c_pl_cwb into l_opt_typ_cd;
     close c_pl_cwb ;
  end if ;
  if l_opt_typ_cd = 'CWB' then
     open c_child_exist ;
     fetch c_child_exist into l_dummy ;
     if  c_child_exist%found then
       close c_child_exist ;
       fnd_message.set_name('BEN','BEN_93724_CWB_CHILD_EXIST');
       fnd_message.set_token('NAME', p_name);                      /* Bug 4057566 */
       fnd_message.raise_error;
     end if ;
     close c_child_exist ;
  end if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --

end chk_pl_group_child ;



Procedure chk_pl_group_id(p_pl_id                in number,
                          p_group_pl_id          in number,
                          p_pl_typ_id            in number,
                          p_effective_date       in date,
                          p_name                 in varchar2
                          ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_group_id';
  l_api_updating boolean;
  --
  cursor c_parent_pl is
   select 'x'
    from ben_pl_f
   where pl_id = p_group_pl_id
     and pl_id = group_pl_id
     and p_effective_date between effective_start_date
         and  effective_end_Date ;


  cursor c_pl_cwb is
  select opt_typ_cd
    from ben_pl_typ_f plt
   where plt.pl_typ_id  = p_pl_typ_id
     and plt.opt_typ_cd = 'CWB'
     and p_effective_date between plt.effective_start_date
          and  plt.effective_end_Date  ;



 l_dummy  varchar2(1) ;
 l_opt_typ_cd  ben_pl_typ_f.opt_typ_cd%type ;

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('p_group_pl_id:'||p_group_pl_id, 5);

  -- if the plan type is cwb and  group_pl_id null throw the error
  open c_pl_cwb ;
  fetch c_pl_cwb into l_opt_typ_cd ;
  if c_pl_cwb%found then
     if p_group_pl_id is  null then
        close c_pl_cwb ;
        fnd_message.set_name('BEN','BEN_93725_CWB_GROUP_PLN_NULL');
        fnd_message.raise_error;
     end if ;
  end if ;
  close c_pl_cwb ;

  if p_group_pl_id is not null then
     --check whether the plan belongs to CWB if not throw the error
     open c_pl_cwb ;
     fetch c_pl_cwb into l_opt_typ_cd ;
     if c_pl_cwb%notfound then
        close c_pl_cwb ;
        fnd_message.set_name('BEN','BEN_93725_CWB_GROUP_PLN_NULL');
        fnd_message.raise_error;
     end if ;
     close c_pl_cwb ;

     -- when the plan is child check the parent is real parent
     if p_pl_id <>  p_group_pl_id then
        open c_parent_pl ;
        fetch  c_parent_pl  into l_dummy ;
        if c_parent_pl%notfound then
           close c_parent_pl ;
           fnd_message.set_name('BEN','BEN_93726_CWB_PRTN_PLN_ERROR');
           fnd_message.raise_error;
        end if ;
        close c_parent_pl ;

        chk_pl_group_child(p_pl_id            => p_pl_id ,
                           p_opt_typ_cd       => l_opt_typ_cd ,
                           p_effective_date   => p_effective_date,
                           p_name             => p_name) ;
     end if ;

  end if ;
  -- if  the type got changed from cwb to non cwb validate the child
  if ben_pln_shd.g_old_rec.group_pl_id is not null and p_group_pl_id is null then
          chk_pl_group_child(p_pl_id          => p_pl_id ,
                           p_opt_typ_cd       => 'CWB' ,
                           p_effective_date   => p_effective_date,
                           p_name             => p_name) ;
  end  if ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_pl_group_id;
-- |------------------------< chk_plan_name_unique >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the plan name is unique within a
--   business group.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                 PK of record being inserted or updated.
--   name                  Plan name.
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
Procedure chk_plan_name_unique(p_pl_id                     in number,
                               p_name                      in varchar2,
                               p_effective_date            in date,
                               p_business_group_id         in number,
                               p_object_version_number     in number,
			       p_validation_start_date     in date,
			       p_validation_end_date      in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_plan_name_unique';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_pl_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.pl_id <> nvl(p_pl_id,-1)
    and    a.name = p_name
    and p_validation_start_date <= effective_end_date
    and p_validation_end_date >= effective_start_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_name,hr_api.g_varchar2)
     <>  ben_pln_shd.g_old_rec.name
     or not l_api_updating) then
    --
    -- Check if plan name is unique.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this plan name has already been used
        --
        fnd_message.set_name('BEN','BEN_93570_PDW_PLAN_NAME_UNIQ');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_plan_name_unique;

--

-- ----------------------------------------------------------------------------
-- |-----------------------< chk_auto_enrt_and_mthd >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the automatic enrollment flag
--   flag is checked at OIPL, the plan record for the option must have the
--   enrollment method = "Automatic".

/* Bug# 4990426 */

Procedure chk_auto_enrt_and_mthd(p_pl_id                    in number,
                                p_effective_date            in date,
				p_enrt_mthd_cd              in varchar2,
                                p_business_group_id         in number) is
 --
 l_proc         varchar2(72) := g_package||'chk_auto_enrt_and_mthd';
 l_dummy_c1 varchar2(1);
 --
 cursor c1 is
     select null
     from   ben_oipl_f cop
     where  cop.pl_id=p_pl_id
      and   cop.auto_enrt_flag = 'Y'
      and  p_effective_date between cop.effective_start_date
           and cop.effective_end_date
      and  cop.business_group_id(+) = p_business_group_id;

--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5555);
   --
 if  nvl(p_enrt_mthd_cd,'E') <> 'A' then
  open c1;
   --
  fetch c1 into l_dummy_c1;
  if c1%found then

   -- raise an error as the Enrollment Method Code has a value of
   -- "automatic".

  close c1;
   --
  fnd_message.set_name('BEN','BEN_91967_AUTO_ENRT_AND_MTHD');
  fnd_message.raise_error;
  --
  else
  --
  close c1;
  --
  end if;

end if;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
End chk_auto_enrt_and_mthd;

-- Bug# 5710248
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_pl_typ_change >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if enrollments exist for a plan then
--   the plan type cant be changed.

procedure chk_pl_typ_change
			(p_pl_id                    in number,
                         p_business_group_id        in number,
			 p_pl_typ_id                in number,
			 p_effective_date           in date ,
			 p_object_version_number    in number) is
 --
 l_proc         varchar2(72) := g_package||'chk_pl_typ_change';
 l_dummy varchar2(1);
 l_api_updating boolean;
 --
 cursor c_epe_exist is
     select null
     from   ben_elig_per_elctbl_chc epe,
	    ben_per_in_ler pil
     where  epe.pl_id = p_pl_id
      and   pil.per_in_ler_stat_cd not in ('VOIDD','BCKDT')
      and   epe.per_in_ler_id = pil.per_in_ler_id
      and   epe.business_group_id = p_business_group_id
      and   epe.business_group_id = pil.business_group_id;
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5555);
   --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pl_typ_id <> nvl(ben_pln_shd.g_old_rec.pl_typ_id,hr_api.g_number) ) then
  --
   open c_epe_exist;
   --
  fetch c_epe_exist into l_dummy;
   --
   if c_epe_exist%found then
    --
    close c_epe_exist;
    --
    fnd_message.set_name('BEN','BEN_91024_PEP_EXISTS');
    fnd_message.raise_error;
    --
  else
   --
   close c_epe_exist;
   --
  end if;
--
end if;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
end chk_pl_typ_change;

-- Bug# 5710248
-- ----------------------------------------------------------------------------
-- |--------------------< chk_cwb_plan_type_uniq_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the plan name is unique across all
--   business groups if the associated plan type has option type "Compensation Workbench"
--   and it is a group plan.
--
-- Bug : 3475996
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id			PK of record being inserted or updated.
--   name			Plan name.
--   pl_typ_id                  Id of Plan Type selected.
--   group_pl_id                Id of Group Plan to which the plan is associated.
--   effective_date		Session date of record.
--   business_group_id		Business group id of record being inserted.
--   object_version_number	Object version number of record being
--				inserted or updated.
--   validation_start_date	Validation start date of the record.
--   validation_end_date	Validation end date of the record.
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
Procedure chk_cwb_plan_type_uniq_plan(p_pl_id                     in number,
			              p_name                      in varchar2,
			              p_pl_typ_id                 in number,
				      p_group_pl_id               in number,
			              p_effective_date            in date,
                                      p_business_group_id         in number,
                                      p_object_version_number     in number,
			              p_validation_start_date     in date,
			              p_validation_end_date      in date) is
  --
  l_proc		varchar2(72) := g_package||'chk_cwb_plan_type_uniq_plan';
  l_api_updating	boolean;
  l_dummy		varchar2(1);
  l_opt_typ_cd		varchar2(30);
  l_exist_pl_id		number;
  l_exist_group_pl_id	number;
  --
  cursor c1 is
     select opt_typ_cd
     from ben_pl_typ_f
     where pl_typ_id = p_pl_typ_id
     and business_group_id = p_business_group_id
     and p_effective_date between effective_start_date and effective_end_date;
  --
  cursor c2 is
    select null
    from ben_pl_f pln, ben_pl_typ_f ptp
    where pln.pl_typ_id = ptp.pl_typ_id
    and ptp.opt_typ_cd = 'CWB'
    and pln.pl_id <> nvl(p_pl_id,-1)
    and pln.name = p_name
    and p_validation_start_date <= pln.effective_end_date
    and p_validation_end_date >= pln.effective_start_date
    and p_effective_date between ptp.effective_start_date and ptp.effective_end_date;
  --
  cursor c3 is
    select null
    from ben_pl_f pln, ben_pl_typ_f ptp
    where pln.pl_typ_id = ptp.pl_typ_id
    and ptp.opt_typ_cd = 'CWB'
    and pln.pl_id <> nvl(p_pl_id,-1)
    and pln.name = p_name
    and pln.pl_id = nvl(pln.group_pl_id, pl_id)
    and p_validation_start_date <= pln.effective_end_date
    and p_validation_end_date >= pln.effective_start_date
    and p_effective_date between ptp.effective_start_date and ptp.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Get the Option Type of the Plan Type
  --
  open c1;
  fetch c1 into l_opt_typ_cd;
  if  ( c1%found )
      and (l_opt_typ_cd = 'CWB') then
    --
    if nvl(p_pl_id,-1) = nvl(p_group_pl_id,nvl(p_pl_id,-1)) then
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
      --
        close c1;
        close c2;
        --
        fnd_message.set_name('BEN','BEN_93905_GRP_PLN_NAME_UNIQUE');
        fnd_message.raise_error;
	--
      end if;
      close c2;
    --
    else
    --
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
      --
        close c1;
        close c3;
        --
        fnd_message.set_name('BEN','BEN_93905_GRP_PLN_NAME_UNIQUE');
        fnd_message.raise_error;
	--
      --
      end if;
      close c3;
    --
    end if;
    --
  end if;
  --
  close c1;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_cwb_plan_type_uniq_plan;

--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_measures_allowed >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that if the Measures Allowed Code value is
--   'Percent Allowed Only', only the Beneficiary Increment Percent and Minimum
--   Designatable Percent should be allowed to be saved.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   bnf_pct_amt_alwd_cd   Measures Allowed Code
--   bnf_incrmt_amt        Increment Amount Allowed
--   bnf_pct_incrmt_val    Percent Increment Allowed
--   bnf_mn_dsgntbl_amt    Minimum Designatable Percent
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Errors handled by the procedure
--
-- Access Status
--   Internal table handler use only.
Procedure chk_measures_allowed(p_bnf_pct_amt_alwd_cd       in varchar2,
                               p_bnf_incrmt_amt            in number,
                               p_bnf_pct_incrmt_val        in number,
                               p_bnf_mn_dsgntbl_amt        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_measures_allowed';
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_bnf_pct_amt_alwd_cd = 'PCTO' and
      p_bnf_incrmt_amt is not null) then
        --
        -- raise an error as this measures amount code only allows percent
        -- increments
        --
        fnd_message.set_name('BEN','BEN_91617_INCR_AMT_NOT_ALWD');
        fnd_message.raise_error;
        --
    --
  end if;
  --
  if (p_bnf_pct_amt_alwd_cd = 'PCTO' and
      p_bnf_mn_dsgntbl_amt is not null) then
        --
        -- raise an error as this measures amount code only allows percent
        -- increments
        --
        fnd_message.set_name('BEN','BEN_91617_INCR_AMT_NOT_ALWD');
        fnd_message.raise_error;
       --
  end if;
--
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_measures_allowed;
--
-- Code Appended for Bug# 2334297
-- ----------------------------------------------------------------------------
-- |---------------------------------< chk_dflt_to_asn_pndg_ctfn_cd >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the Interim Assign Code.
--	If the Coverage Calculation is set to Flat Amount (FLFX)
-- 	and Enter Value at Enrollment is checked in the Coverages Form,
--	this procedure will not allow to set the interim assign code to
--	Next Lower
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id          PK of record being inserted or updated.
--   effective_date Effective Date of session
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
Procedure chk_dflt_to_asn_pndg_ctfn_cd(
		    p_dflt_to_asn_pndg_ctfn_cd  	in varchar2,
		    p_pl_id                     	in number,
                    p_effective_date            	in date,
                    p_business_group_id            	in number,
                    p_object_version_number     	in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dflt_to_asn_pndg_ctfn_cd';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null from BEN_CVG_AMT_CALC_MTHD_F cvg
    where nvl(cvg.pl_id,-1) = p_pl_id
    and cvg.cvg_mlt_cd = 'FLFX'
    and cvg.entr_val_at_enrt_flag = 'Y'
    and cvg.business_group_id = p_business_group_id
    and p_effective_date between cvg.effective_start_date and cvg.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if ( (l_api_updating
     and nvl(p_dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
     <>  nvl(ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd, '***'))
     or not l_api_updating)
     and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    if (instr(p_dflt_to_asn_pndg_ctfn_cd,'NL'))>0 then
      --
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        hr_utility.set_location('Inside :'||l_proc, 8);
        fnd_message.set_name('BEN', 'BEN_93113_CD_CANNOT_NEXTLOWER');
        fnd_message.raise_error;
        --
      else
        --
        close c1;
        --
      end if;
      --
    end if; -- End of instr end if
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_dflt_to_asn_pndg_ctfn_cd;

-- End of code Append Bug# 2334297
-- ----------------------------------------------------------------------------
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_flag_and_val >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the flag is turned on then
--   the value must be null
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_FLAG value of flag item.
--   P_VAL  value of value item
--   P_MSG  message name to dispaly if validation fails
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
Procedure chk_flag_and_val(p_flag      in varchar2,
                           p_val       in number,
                           p_msg       in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_flag_and_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_flag = 'Y' and p_val is not null then
      fnd_message.set_name('BEN', p_msg);
      fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_flag_and_val;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_code_rule_dpnd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Rule is only allowed to
--   have a value if the value of the Code = 'Rule', and if code is
--   = RL then p_rule must have a value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   P_CODE value of code item.
--   P_RULE value of rule item
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
Procedure chk_code_rule_dpnd(p_code      in varchar2,
                            p_rule       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_code_rule_dpnd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_code <> 'RL' and p_rule is not null then
      --
      fnd_message.set_name('BEN','BEN_91624_CD_RL_2');
      fnd_message.raise_error;
      --
  elsif p_code = 'RL' and p_rule is null then
      --
      fnd_message.set_name('BEN','BEN_91623_CD_RL_1');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_code_rule_dpnd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mn_val_mn_flag_mn_rule >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the minimum value, no
--   minimum flag, or the minimum rule is entered.  More than one of the
--   above mentioned may not have be entered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_mn_cvg_rqd_amt            value of Minimum Value
--   p_no_mn_cvg_amt_apls_flag   value of No Minimum Flag
--   p_mn_cvg_rl                 value of Minimum Rule
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
Procedure chk_mn_val_mn_flag_mn_rule(p_mn_cvg_rqd_amt          in number,
                                     p_no_mn_cvg_amt_apls_flag in varchar2,
                                     p_mn_cvg_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mn_val_mn_flag_mn_rule';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mn_cvg_rqd_amt is not null and (p_no_mn_cvg_amt_apls_flag = 'Y' or
     p_mn_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_mn_cvg_rl is not null and (p_no_mn_cvg_amt_apls_flag = 'Y' or
     p_mn_cvg_rqd_amt is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_no_mn_cvg_amt_apls_flag = 'Y' and (p_mn_cvg_rqd_amt is not null or
     p_mn_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91945_MN_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mn_val_mn_flag_mn_rule;


--
--
--
Procedure chk_vrfy_fmly_mmbr_rl
  (p_pl_id                 in number
  ,p_vrfy_fmly_mmbr_rl     in number
  ,p_business_group_id     in number
  ,p_effective_date        in date
  ,p_object_version_number in number)
is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_rl';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_vrfy_fmly_mmbr_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.vrfy_fmly_mmbr_rl
      or not l_api_updating)
      and p_vrfy_fmly_mmbr_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    if not benutils.formula_exists
       (p_formula_id        => p_vrfy_fmly_mmbr_rl,
        p_formula_type_id   => -21,
        p_business_group_id => p_business_group_id,
        p_effective_date    => p_effective_date) then
      --
      -- raise error

      fnd_message.set_name('BEN','BEN_91471_FORMULA_NOT_FOUND');
      fnd_message.set_token('ID',p_vrfy_fmly_mmbr_rl);
      fnd_message.set_token('TYPE_ID',-21);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_rl;
--

-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd >------------------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that
--    1. if p_dpnt_dsgn_cd is not null then p_dpnt_cvg_strt_dt_cd and
--       p_dpnt_cvg_end_dt_cd should also be not null.
--    2. if p_dpnt_dsgn_cd is null then p_dpnt_cvg_strt_dt_cd and
--       p_dpnt_cvg_end_dt_cd should also be null.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_dpnt_dsgn_cd              value of Plan Dependent Designation
--   p_dpnt_cvg_strt_dt_cd       value of Dependent Coverage Start Date
--   p_dpnt_cvg_end_dt_cd        value of Dependent Coverage End Date
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
  --
Procedure chk_dpnt_dsgn_cd(p_dpnt_dsgn_cd            in varchar2,
                           p_dpnt_cvg_strt_dt_cd     in varchar2,
                           p_dpnt_cvg_end_dt_cd      in varchar2) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_dsgn_cd';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_dpnt_dsgn_cd is not null) and
     (p_dpnt_cvg_strt_dt_cd is null or p_dpnt_cvg_end_dt_cd is null) then

    fnd_message.set_name('BEN','BEN_92512_DPNDNT_CVRG_DT_RQD');
    fnd_message.raise_error;
  end if;
  --

  if (p_dpnt_dsgn_cd is null) and
     (p_dpnt_cvg_strt_dt_cd is not null or p_dpnt_cvg_end_dt_cd is not null) then
     fnd_message.set_name('BEN','BEN_91375_PGM_DPNT_DSGN_RQD');
     fnd_message.raise_error;
  end if;

  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  --
end chk_dpnt_dsgn_cd;
--
--

Procedure chk_vrfy_fmly_mmbr_cd(p_pl_id                       in number,
                                p_vrfy_fmly_mmbr_cd           in varchar2,
                                p_effective_date              in date,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_vrfy_fmly_mmbr_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_vrfy_fmly_mmbr_cd
      <> nvl(ben_pln_shd.g_old_rec.vrfy_fmly_mmbr_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_vrfy_fmly_mmbr_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_FMLY_MMBR',
           p_lookup_code    => p_vrfy_fmly_mmbr_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_vrfy_fmly_mmbr_cd');
      fnd_message.set_token('TYPE','BEN_FMLY_MMBR');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_vrfy_fmly_mmbr_cd;
--

Procedure chk_use_csd_rsd_prccng_cd(p_pl_id                   in number,
                                p_use_csd_rsd_prccng_cd       in varchar2,
                                p_effective_date              in date,
                                p_pl_cd                       in varchar2,
                                p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_use_csd_rsd_prccng_cd';
  l_api_updating boolean;
  --
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
   l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_use_csd_rsd_prccng_cd
      <> nvl(ben_pln_shd.g_old_rec.use_csd_rsd_prccng_cd,hr_api.g_varchar2)
      or not l_api_updating)
     and p_use_csd_rsd_prccng_cd is not null
  then
    --
    -- check if value of lookup falls within lookup type.
    --

    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_USE_CSD_RSD_PRCCNG',
           p_lookup_code    => p_use_csd_rsd_prccng_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_use_csd_rsd_prccng_cd');
      fnd_message.set_token('TYPE','BEN_USE_CSD_RSD_PRCCNG');
      fnd_message.raise_error;
      --
    end if ;
    --
  end if;
  --
  if p_use_csd_rsd_prccng_cd is not null and   p_pl_cd <> 'MYNTBPGM' then
      fnd_message.set_name('BEN','BEN_93948_CSD_RSD_PLIP');
      fnd_message.raise_error;
  end if ;

  hr_utility.set_location('Leaving:'||l_proc,10);
  --
  --
end chk_use_csd_rsd_prccng_cd;
--


-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_dsgn_cd_detail >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   If dependent designation code is null then the following tables must
--   contain no records for that program:  BEN_LER_CHG_DPNT_CVG_F,
--   BEN_APLD_DPNT_CVG_ELIG_PRFL_F, BEN_PL_DPNT_CVG_CTFN_F.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id PK of record being inserted or updated.
--   dpnt_dsgn_cd Value of lookup code.
--    pl_id
--    business_group_id
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
Procedure chk_dpnt_dsgn_cd_detail(p_pl_id                      in number,
                                 p_dpnt_dsgn_cd                in varchar2,
                                 p_bnf_dsgn_cd                 in varchar2,
                                 p_business_group_id           in number,
                                 p_effective_date              in date,
				 p_validation_start_date       in date,-- bug 3981774
				 p_validation_end_date         in date,-- bug 3981774
                                 p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package || 'chk_dpnt_dsgn_cd_detail';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is select 'x'
                  from  ben_ler_chg_dpnt_cvg_f ldc1
                  where ldc1.pl_id = p_pl_id
                    and ldc1.business_group_id + 0 = p_business_group_id
                    /* start of bug 3981774
		    and p_effective_date between ldc1.effective_start_date
                                             and ldc1.effective_end_date; */
		    and p_validation_start_date <= ldc1.effective_end_date
                    and p_validation_end_date >= ldc1.effective_start_date ; /* end bug 3981774 */

  --bug 3981774 fix similar to c1 is done for c2,c3,c4
  cursor c2 is select 'x'
                  from  ben_apld_dpnt_cvg_elig_prfl_f ade1
                  where ade1.pl_id = p_pl_id
                    and ade1.business_group_id + 0 = p_business_group_id
                    /*and p_effective_date between ade1.effective_start_date
                                             and ade1.effective_end_date;*/
		    and p_validation_start_date <= ade1.effective_end_date
                    and p_validation_end_date >= ade1.effective_start_date ; /* end bug 3981774 */

  --
  cursor c3 is select 'x'
                  from  ben_pl_dpnt_cvg_ctfn_f pnd
                  where pnd.pl_id = p_pl_id
                    and pnd.business_group_id + 0 = p_business_group_id
                   /* and p_effective_date between pnd.effective_start_date
                                             and pnd.effective_end_date;*/
		   and p_validation_start_date <= pnd.effective_end_date
                   and p_validation_end_date >= pnd.effective_start_date ; /* end bug 3981774 */

  --
  cursor c4 is select 'x'
                  from  ben_pl_bnf_ctfn_f pcx
                  where pcx.pl_id = p_pl_id
                    and pcx.business_group_id + 0 = p_business_group_id
                    /*and p_effective_date between pcx.effective_start_date
                                             and pcx.effective_end_date;*/
		    and p_validation_start_date <= pcx.effective_end_date
                    and p_validation_end_date >= pcx.effective_start_date ; /* end bug 3981774 */

  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- If ldc1 records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c1;
      fetch c1 into l_dummy;
      if c1%found then
         --
         close c1;
         fnd_message.set_name('BEN','BEN_92524_DELETE_LDC2');
         fnd_message.raise_error;
         --
      else
        close c1;
      end if;
      --
    end if;
    --
    -- If ade1 records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c2;
      fetch c2 into l_dummy;
      if c2%found then
         --
         close c2;
         fnd_message.set_name('BEN','BEN_92523_DELETE_ADE2');
         fnd_message.raise_error;
         --
      else
         close c2;
      end if;
       --
    end if;
    --
    -- If pnd records exists and designation is null then error
    --
    if (p_dpnt_dsgn_cd is null) then
      open c3;
      fetch c3 into l_dummy;
      if c3%found then
         --
         close c3;
         fnd_message.set_name('BEN','BEN_92522_DELETE_PND');
         fnd_message.raise_error;
         --
      else
        close c3;
      end if;
      --
    end if;
    --
    -- If pcx records exists and designation is null then error
    --
    if (p_bnf_dsgn_cd is null) then
      open c4;
      fetch c4 into l_dummy;
      if c4%found then
         --
         close c4;
         fnd_message.set_name('BEN','BEN_92525_DELETE_PCX');
         fnd_message.raise_error;
         --
      else
        close c4;
      end if;
      --
    end if;
    --
  --
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_dpnt_dsgn_cd_detail;
--
-- ----------------------------------------------------------------------------
-- |------< chk_mx_val_mx_flag_mx_rule >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that either the maximum value, no
--   maximum flag, or the maximum rule is entered.  More than one of the
--   above mentioned may not have be entered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_mx_cvg_alwd_amt           value of Minimum Value
--   p_no_mx_cvg_amt_apls_flag   value of No Minimum Flag
--   p_mx_cvg_rl                 value of Minimum Rule
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
Procedure chk_mx_val_mx_flag_mx_rule(p_mx_cvg_alwd_amt         in number,
                                     p_no_mx_cvg_amt_apls_flag in varchar2,
                                     p_mx_cvg_rl               in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mx_val_mx_flag_mx_rule';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_mx_cvg_alwd_amt is not null and (p_no_mx_cvg_amt_apls_flag = 'Y' or
     p_mx_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_mx_cvg_rl is not null and (p_no_mx_cvg_amt_apls_flag = 'Y' or
     p_mx_cvg_alwd_amt is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  elsif p_no_mx_cvg_amt_apls_flag = 'Y' and (p_mx_cvg_alwd_amt is not null or
     p_mx_cvg_rl is not null) then
      --
      fnd_message.set_name('BEN','BEN_91946_MX_VAL_FLAG_RULE');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_mx_val_mx_flag_mx_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_mutual_exclusive_flags >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive flags
--   invk_dcln_elig_pl_flag
--   invk_flx_cr_pl_flag
--   svgs_pl_flag
--   are set correctly. Either one may be equal to yes or they may all be no.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                   PK of record being inserted or updated.
--   invk_dcln_prtn_pl_flag  flag.
--   invk_flx_cr_pl_flag     flag.
--   svgs_pl_flag            flag.
--   effective_date          Session date of record.
--   object_version_number   Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exclusive_flags(p_pl_id                     in number,
                                     p_invk_dcln_prtn_pl_flag    in varchar2,
                                     p_invk_flx_cr_pl_flag       in varchar2,
                                     p_svgs_pl_flag              in varchar2,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exclusive_flags';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if p_invk_dcln_prtn_pl_flag = 'Y' or
     p_invk_flx_cr_pl_flag = 'Y' or
     p_svgs_pl_flag = 'Y' then
    --
    -- OK at least one of our flags holds a true state, lets make sure it
    -- is just one by using a series of if statements
    --
    if (p_invk_dcln_prtn_pl_flag = 'Y' and
        (p_invk_flx_cr_pl_flag = 'Y' or
         p_svgs_pl_flag = 'Y')
        or
        p_invk_flx_cr_pl_flag = 'Y' and
        (p_invk_dcln_prtn_pl_flag = 'Y' or
         p_svgs_pl_flag = 'Y')
        or
        p_svgs_pl_flag = 'Y' and
        (p_invk_flx_cr_pl_flag = 'Y' or
         p_invk_dcln_prtn_pl_flag = 'Y')) then
      --
      -- OK flags are not mutaully exclusive so raise an error
      --
      fnd_message.set_name('BEN','BEN_93882_PLN_FLGS_MUTUAL_EXCL');  --Bug 3424424
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exclusive_flags;
-- ----------------------------------------------------------------------------
-- |----------------------< chk_mutual_exlsv_rule_num_uom >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the mutual exclusive fields
--   mx_wtg_perd_prte_det_rl and mx_wtg_perd_prte_val/mx_wtg_perd_prte_uom
--   are set correctly.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                   PK of record being inserted or updated.
--   mx_wtg_perd_prte_det_rl Rule.
--   mx_wtg_perd_prte_val    Number.
--   mx_wtg_perd_prte_uom    UOM.
--   effective_date          Session date of record.
--   object_version_number   Object version number of record being
--                           inserted or updated.
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
Procedure chk_mutual_exlsv_rule_num_uom(p_pl_id                  in number,
                                     p_mx_wtg_perd_rl            in number,
                                     p_mx_wtg_perd_prte_val      in number,
                                     p_mx_wtg_perd_prte_uom      in varchar2,
                                     p_effective_date            in date,
                                     p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_mutual_exlsv_rule_num_uom';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (p_mx_wtg_perd_rl is not null and
     (p_mx_wtg_perd_prte_val is not null  or
      p_mx_wtg_perd_prte_uom is not null)) then
    --
    -- OK fields are not mutaully exclusive so raise an error
    --
    fnd_message.set_name('PAY','PLN_RULE_NUM_MUTUAL_EXCLUSIVE');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_mutual_exlsv_rule_num_uom;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_flags >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the flag lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                        PK of record being inserted or updated.
--   alws_qdro_flag               Value of lookup code.
--   alws_qmcso_flag              Value of lookup code.
--   aply_pgm_elig_flag           Value of lookup code.
--   bnf_addl_instn_txt_alwd_flag Value of lookup code.
--   bnf_adrs_rqd_flag            Value of lookup code.
--   bnf_cntngt_bnfs_alwd_flag    Value of lookup code.
--   bnf_ctfn_rqd_flag            Value of lookup code.
--   bnf_dob_rqd_flag             Value of lookup code.
--   bnf_dsge_mnr_ttee_rqd_flag   Value of lookup code.
--   bnf_legv_id_rqd_flag         Value of lookup code.
--   bnf_may_dsgt_org_flag        Value of lookup code.
--   bnf_qdro_rl_apls_flag        Value of lookup code.
--   drvbl_fctr_apls_rts_flag     Value of lookup code.
--   drvbl_fctr_prtn_elig_flag    Value of lookup code.
--   elig_apls_flag               Value of lookup code.
--   invk_dcln_prtn_pl_flag       Value of lookup code.
--   invk_flx_cr_pl_flag          Value of lookup code.
--   nip_drvbl_dpnt_elig_flag     Value of lookup code.
--   nip_tmprl_dpnt_elig_flag     Value of lookup code.
--   trk_inelig_per_flag          Value of lookup code.
--   use_opt_ordr_num_flag        Value of lookup code.
--   dpnt_cvd_by_othr_apls_flag   Value of lookup code.
--   frfs_aply_flag               Value of lookup code.
--   hc_pl_subj_hcfa_aprvl_flag   Value of lookup code.
--   hghly_cmpd_rl_apls_flag      Value of lookup code.
--   nip_dpnt_adrs_rqd_flag       Value of lookup code.
--   nip_dpnt_dob_rqd_flag        Value of lookup code.
--   nip_dpnt_leg_id_rqd_flag     Value of lookup code.
--   nip_dpnt_no_ctfn_rqd_flag    Value of lookup code.
--   nip_mt_one_dpnt_elig_flag    Value of lookup code.
--   no_mn_cvg_amt_apls_flag      Value of lookup code.
--   no_mn_cvg_incr_apls_flag     Value of lookup code.
--   no_mn_opts_num_apls_flag     Value of lookup code.
--   no_mx_cvg_amt_apls_flag      Value of lookup code.
--   no_mx_cvg_incr_apls_flag     Value of lookup code.
--   no_mx_opts_num_apls_flag     Value of lookup code.
--   prtn_elig_ovrid_alwd_flag    Value of lookup code.
--   subj_to_imptd_incm_typ_cd    Value of lookup code.
--   use_all_asnts_elig_flag      Value of lookup code.
--   use_all_asnts_for_rt_flag    Value of lookup code.
--   vstg_apls_flag               Value of lookup code.
--   wvbl_flag                    Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_flags(p_pl_id                        in number,
                        p_alws_qdro_flag               in varchar2,
                        p_alws_qmcso_flag              in varchar2,
                        p_bnf_addl_instn_txt_alwd_flag in varchar2,
                        p_bnf_adrs_rqd_flag            in varchar2,
                        p_bnf_cntngt_bnfs_alwd_flag    in varchar2,
                        p_bnf_ctfn_rqd_flag            in varchar2,
                        p_bnf_dob_rqd_flag             in varchar2,
                        p_bnf_dsge_mnr_ttee_rqd_flag   in varchar2,
                        p_bnf_legv_id_rqd_flag         in varchar2,
                        p_bnf_may_dsgt_org_flag        in varchar2,
                        p_bnf_qdro_rl_apls_flag        in varchar2,
                        p_drvbl_fctr_apls_rts_flag     in varchar2,
                        p_drvbl_fctr_prtn_elig_flag    in varchar2,
                        p_elig_apls_flag               in varchar2,
                        p_invk_dcln_prtn_pl_flag       in varchar2,
                        p_invk_flx_cr_pl_flag          in varchar2,
                        p_drvbl_dpnt_elig_flag         in varchar2,
                        p_trk_inelig_per_flag          in varchar2,
                        p_dpnt_cvd_by_othr_apls_flag   in varchar2,
                        p_frfs_aply_flag               in varchar2,
                        p_hc_pl_subj_hcfa_aprvl_flag   in varchar2,
                        p_hghly_cmpd_rl_apls_flag      in varchar2,
                        p_no_mn_cvg_amt_apls_flag      in varchar2,
                        p_no_mn_cvg_incr_apls_flag     in varchar2,
                        p_no_mn_opts_num_apls_flag     in varchar2,
                        p_no_mx_cvg_amt_apls_flag      in varchar2,
                        p_no_mx_cvg_incr_apls_flag     in varchar2,
                        p_no_mx_opts_num_apls_flag     in varchar2,
                        p_prtn_elig_ovrid_alwd_flag    in varchar2,
                        p_subj_to_imptd_incm_typ_cd    in varchar2,
                        p_use_all_asnts_elig_flag      in varchar2,
                        p_use_all_asnts_for_rt_flag    in varchar2,
                        p_vstg_apls_flag               in varchar2,
                        p_wvbl_flag                    in varchar2,
                        p_alws_reimbmts_flag           in varchar2,
                        p_dpnt_adrs_rqd_flag           in varchar2,
                        p_dpnt_dob_rqd_flag            in varchar2,
                        p_dpnt_leg_id_rqd_flag         in varchar2,
                        p_dpnt_no_ctfn_rqd_flag        in varchar2,
                        p_svgs_pl_flag                 in varchar2,
                        p_enrt_pl_opt_flag             in varchar2,
                        p_MAY_ENRL_PL_N_OIPL_FLAG      in varchar2,
                        p_ALWS_UNRSTRCTD_ENRT_FLAG     in varchar2,
                        p_ALWS_TMPRY_ID_CRD_FLAG       in varchar2,
                        p_nip_dflt_flag                in varchar2,
                        p_post_to_gl_flag              in  varchar2,
                        p_effective_date               in date,
                        p_object_version_number        in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_flags';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_alws_qdro_flag
      <> nvl(ben_pln_shd.g_old_rec.alws_qdro_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_alws_qdro_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alws_qdro_flag,
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
  if (l_api_updating
      and p_alws_qmcso_flag
      <> nvl(ben_pln_shd.g_old_rec.alws_qmcso_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_alws_qmcso_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alws_qmcso_flag,
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
  if (l_api_updating
      and p_enrt_pl_opt_flag
      <> nvl(ben_pln_shd.g_old_rec.enrt_pl_opt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_pl_opt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_enrt_pl_opt_flag,
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
  if (l_api_updating
      and p_alws_reimbmts_flag
      <> nvl(ben_pln_shd.g_old_rec.alws_reimbmts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_alws_reimbmts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_alws_reimbmts_flag,
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
  if (l_api_updating
      and p_bnf_addl_instn_txt_alwd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_addl_instn_txt_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_addl_instn_txt_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_addl_instn_txt_alwd_flag,
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
  if (l_api_updating
      and p_bnf_adrs_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_adrs_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_adrs_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_adrs_rqd_flag,
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
  if (l_api_updating
      and p_bnf_cntngt_bnfs_alwd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_cntngt_bnfs_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_cntngt_bnfs_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_cntngt_bnfs_alwd_flag,
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
  if (l_api_updating
      and p_bnf_ctfn_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_ctfn_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_ctfn_rqd_flag,
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
  if (l_api_updating
      and p_bnf_dob_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_dob_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_dob_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_dob_rqd_flag,
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
  if (l_api_updating
      and p_bnf_dsge_mnr_ttee_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_dsge_mnr_ttee_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_dsge_mnr_ttee_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_dsge_mnr_ttee_rqd_flag,
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
  if (l_api_updating
      and p_bnf_legv_id_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_legv_id_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_legv_id_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_legv_id_rqd_flag,
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
  if (l_api_updating
      and p_bnf_may_dsgt_org_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_may_dsgt_org_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_may_dsgt_org_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_may_dsgt_org_flag,
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
  if (l_api_updating
      and p_bnf_qdro_rl_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.bnf_qdro_rl_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_qdro_rl_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_bnf_qdro_rl_apls_flag,
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
  if (l_api_updating
      and p_drvbl_fctr_apls_rts_flag
      <> nvl(ben_pln_shd.g_old_rec.drvbl_fctr_apls_rts_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_apls_rts_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_apls_rts_flag,
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
  if (l_api_updating
      and p_drvbl_fctr_prtn_elig_flag
      <> nvl(ben_pln_shd.g_old_rec.drvbl_fctr_prtn_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_fctr_prtn_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_fctr_prtn_elig_flag,
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
  if (l_api_updating
      and p_elig_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.elig_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_elig_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_elig_apls_flag,
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
  if (l_api_updating
      and p_invk_dcln_prtn_pl_flag
      <> nvl(ben_pln_shd.g_old_rec.invk_dcln_prtn_pl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_invk_dcln_prtn_pl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_invk_dcln_prtn_pl_flag,
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
  if (l_api_updating
      and p_invk_flx_cr_pl_flag
      <> nvl(ben_pln_shd.g_old_rec.invk_flx_cr_pl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_invk_flx_cr_pl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_invk_flx_cr_pl_flag,
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
  if (l_api_updating
      and p_drvbl_dpnt_elig_flag
      <> nvl(ben_pln_shd.g_old_rec.drvbl_dpnt_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_drvbl_dpnt_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_drvbl_dpnt_elig_flag,
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
  if (l_api_updating
      and p_dpnt_adrs_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.dpnt_adrs_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_adrs_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_adrs_rqd_flag,
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
  if (l_api_updating
      and p_trk_inelig_per_flag
      <> nvl(ben_pln_shd.g_old_rec.trk_inelig_per_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_trk_inelig_per_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_trk_inelig_per_flag,
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
  if (l_api_updating
      and p_svgs_pl_flag
      <> nvl(ben_pln_shd.g_old_rec.svgs_pl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_svgs_pl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_svgs_pl_flag,
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
  if (l_api_updating
      and p_dpnt_cvd_by_othr_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.dpnt_cvd_by_othr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_cvd_by_othr_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_cvd_by_othr_apls_flag,
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
  if (l_api_updating
      and p_frfs_aply_flag
      <> nvl(ben_pln_shd.g_old_rec.frfs_aply_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_frfs_aply_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_frfs_aply_flag,
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
  if (l_api_updating
      and p_hc_pl_subj_hcfa_aprvl_flag
      <> nvl(ben_pln_shd.g_old_rec.hc_pl_subj_hcfa_aprvl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hc_pl_subj_hcfa_aprvl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_hc_pl_subj_hcfa_aprvl_flag,
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
  if (l_api_updating
      and p_hghly_cmpd_rl_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.hghly_cmpd_rl_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hghly_cmpd_rl_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_hghly_cmpd_rl_apls_flag,
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
  if (l_api_updating
      and p_dpnt_leg_id_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.dpnt_leg_id_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_leg_id_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_leg_id_rqd_flag,
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
  if (l_api_updating
      and p_dpnt_dob_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.dpnt_dob_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_dob_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_dob_rqd_flag,
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
  if (l_api_updating
      and p_dpnt_no_ctfn_rqd_flag
      <> nvl(ben_pln_shd.g_old_rec.dpnt_no_ctfn_rqd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_no_ctfn_rqd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_dpnt_no_ctfn_rqd_flag,
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
  if (l_api_updating
      and p_no_mn_cvg_amt_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mn_cvg_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_cvg_amt_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_amt_apls_flag,
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
  if (l_api_updating
      and p_no_mn_cvg_incr_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mn_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_cvg_incr_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_cvg_incr_apls_flag,
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
  if (l_api_updating
      and p_no_mn_opts_num_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mn_opts_num_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mn_opts_num_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mn_opts_num_apls_flag,
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
  if (l_api_updating
      and p_no_mx_cvg_amt_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mx_cvg_amt_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_cvg_amt_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_amt_apls_flag,
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
  if (l_api_updating
      and p_no_mx_cvg_incr_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mx_cvg_incr_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_cvg_incr_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_cvg_incr_apls_flag,
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
  if (l_api_updating
      and p_no_mx_opts_num_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.no_mx_opts_num_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_no_mx_opts_num_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_no_mx_opts_num_apls_flag,
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
  if (l_api_updating
      and p_prtn_elig_ovrid_alwd_flag
      <> nvl(ben_pln_shd.g_old_rec.prtn_elig_ovrid_alwd_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtn_elig_ovrid_alwd_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_prtn_elig_ovrid_alwd_flag,
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
  if (l_api_updating
      and p_subj_to_imptd_incm_typ_cd
      <> nvl(ben_pln_shd.g_old_rec.subj_to_imptd_incm_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_subj_to_imptd_incm_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_IMPTD_INCM_TYP',
           p_lookup_code    => p_subj_to_imptd_incm_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN', 'BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_subj_to_imptd_incm_typ_cd');
      fnd_message.set_token('TYPE', 'BEN_IMPTD_INCM_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_use_all_asnts_elig_flag
      <> nvl(ben_pln_shd.g_old_rec.use_all_asnts_elig_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_all_asnts_elig_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_all_asnts_elig_flag,
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
  if (l_api_updating
      and p_use_all_asnts_for_rt_flag
      <> nvl(ben_pln_shd.g_old_rec.use_all_asnts_for_rt_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_use_all_asnts_for_rt_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_use_all_asnts_for_rt_flag,
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
  if (l_api_updating
      and p_vstg_apls_flag
      <> nvl(ben_pln_shd.g_old_rec.vstg_apls_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_vstg_apls_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_vstg_apls_flag,
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
  if (l_api_updating
      and p_wvbl_flag
      <> nvl(ben_pln_shd.g_old_rec.wvbl_flag,hr_api.g_varchar2)
      or not l_api_updating)
      and p_wvbl_flag is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_wvbl_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_MAY_ENRL_PL_N_OIPL_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ALWS_UNRSTRCTD_ENRT_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('PAY','HR_LOOKUP_DOES_NOT_EXIST');
      fnd_message.raise_error;
      --
    end if;
    --
    --
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ALWS_TMPRY_ID_CRD_flag,
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
end chk_all_flags;
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_all_lookups >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup values are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                        PK of record being inserted or updated.
--   bnf_dflt_bnf_cd              Value of lookup code.
--   bnf_pct_amt_alwd_cd          Value of lookup code.
--   dpnt_dsgn_cd                 Value of lookup code.
--   pl_cd                        Value of lookup code.
--   cmpr_clms_to_cvg_or_bal_cd   Value of lookup code.
--   cobra_pymt_due_dy_num        Value of lookup code.
--   enrt_mthd_cd                 Value of lookup code.
--   enrt_cd                      Value of lookup code.
--   enrt_strt_dt_cd              Value of lookup code.
--   deenrt_end_dt_cd             Value of lookup code.
--   mx_wtg_perd_prte_uom         Value of lookup code.
--   nip_dflt_enrt_cd             Value of lookup code.
--   nip_dpnt_cvg_end_dt_cd       Value of lookup code.
--   nip_dpnt_cvg_strt_dt_cd      Value of lookup code.
--   nip_pl_uom                   Value of lookup code.
--   rqd_perd_enrt_nenrt_uom      Value of lookup code.
--   nip_acty_ref_perd_cd         Value of lookup code.
--   nip_enrt_info_rt_freq_cd     Value of lookup code.
--   prort_prtl_yr_cvg_rstrn_cd   Value of lookup code.
--   hc_svc_typ_cd                Value of lookup code.
--   pl_stat_cd                   Value of lookup code.
--   prmry_fndg_mthd_cd           Value of lookup code.
--   prtn_end_dt_cd               Value of lookup code.
--   prtn_strt_dt_cd              Value of lookup code.
--   bnf_dsgn_cd                  Value of lookup code.
--   mx_wtg_dt_to_use_cd          Value of lookup code.
--   unsspnd_enrt_cd              Value of lookup code.
--   imptd_incm_calc_cd           Value of lookup code.
--   effective_date               effective date
--   object_version_number        Object version number of record being
--                                inserted or updated.
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
Procedure chk_all_lookups(p_pl_id                        in number,
                          p_bnf_dflt_bnf_cd              in varchar2,
                          p_bnf_pct_amt_alwd_cd          in varchar2,
                          p_pl_cd                        in varchar2,
                          p_cmpr_clms_to_cvg_or_bal_cd   in varchar2,
                          p_enrt_mthd_cd                 in varchar2,
                          p_enrt_cd                      in varchar2,
                          p_mx_wtg_perd_prte_uom         in varchar2,
                          p_nip_dflt_enrt_cd             in varchar2,
                          p_nip_pl_uom                   in varchar2,
                          p_rqd_perd_enrt_nenrt_uom      in varchar2,
                          p_nip_acty_ref_perd_cd         in varchar2,
                          p_nip_enrt_info_rt_freq_cd     in varchar2,
                          p_prort_prtl_yr_cvg_rstrn_cd   in varchar2,
                          p_hc_svc_typ_cd                in varchar2,
                          p_pl_stat_cd                   in varchar2,
                          p_prmry_fndg_mthd_cd           in varchar2,
                          p_bnf_dsgn_cd                  in varchar2,
                          p_mx_wtg_dt_to_use_cd          in varchar2,
                          p_dflt_to_asn_pndg_ctfn_cd     in varchar2,
                          p_dpnt_dsgn_cd                 in varchar2,
                          p_enrt_cvg_strt_dt_cd          in varchar2,
                          p_enrt_cvg_end_dt_cd           in varchar2,
                          p_dpnt_cvg_strt_dt_cd          in varchar2,
                          p_dpnt_cvg_end_dt_cd           in varchar2,
                          p_per_cvrd_cd                  in varchar2,
                          p_rt_end_dt_cd                 in varchar2,
                          p_rt_strt_dt_cd                in varchar2,
                          p_BNFT_OR_OPTION_RSTRCTN_CD    in varchar2,
                          p_CVG_INCR_R_DECR_ONLY_CD      in varchar2,
                          p_unsspnd_enrt_cd              in varchar2,
                          p_imptd_incm_calc_cd           in varchar2,
                          p_effective_date               in date,
                          p_object_version_number        in number) is
  --
  --
  cursor c1 is select currency_code
                      from fnd_currencies_vl
                      where currency_code = p_nip_pl_uom
                          and enabled_flag = 'Y';

  l_proc         varchar2(72) := g_package||'chk_all_lookups';
  l_api_updating boolean;
  l_dummy varchar2(30);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_bnf_dflt_bnf_cd
      <> nvl(ben_pln_shd.g_old_rec.bnf_dflt_bnf_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_dflt_bnf_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNF_DFLT',
           p_lookup_code    => p_bnf_dflt_bnf_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bnf_dflt_bnf_cd');
      fnd_message.set_token('TYPE', 'BEN_BNF_DFLT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bnf_pct_amt_alwd_cd
      <> nvl(ben_pln_shd.g_old_rec.bnf_pct_amt_alwd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_pct_amt_alwd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNF_PCT_AMT_ALWD',
           p_lookup_code    => p_bnf_pct_amt_alwd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bnf_pct_amt_alwd_cd');
      fnd_message.set_token('TYPE', 'BEN_BNF_PCT_AMT_ALWD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dpnt_dsgn_cd
      <> nvl(ben_pln_shd.g_old_rec.dpnt_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_DSGN',
           p_lookup_code    => p_dpnt_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_dsgn_cd');
      fnd_message.set_token('TYPE', 'BEN_DPNT_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_pl_cd
      <> nvl(ben_pln_shd.g_old_rec.pl_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PL',
           p_lookup_code    => p_pl_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_pl_cd');
      fnd_message.set_token('TYPE', 'BEN_PL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_cmpr_clms_to_cvg_or_bal_cd
      <> nvl(ben_pln_shd.g_old_rec.cmpr_clms_to_cvg_or_bal_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_cmpr_clms_to_cvg_or_bal_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CMPR_CLMS_TO_CVG_OR_BAL',
           p_lookup_code    => p_cmpr_clms_to_cvg_or_bal_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_cmpr_clms_to_cvg_or_bal_cd');
      fnd_message.set_token('TYPE', 'BEN_CMPR_CLMS_TO_CVG_OR_BAL');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_enrt_mthd_cd
      <> nvl(ben_pln_shd.g_old_rec.enrt_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_MTHD',
           p_lookup_code    => p_enrt_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_mthd_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_enrt_cd
      <> nvl(ben_pln_shd.g_old_rec.enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT',
           p_lookup_code    => p_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dflt_to_asn_pndg_ctfn_cd
      <> nvl(ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_TO_ASN_PNDG_CTFN',
           p_lookup_code    => p_dflt_to_asn_pndg_ctfn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dflt_to_asn_pndg_ctfn_cd');
      fnd_message.set_token('TYPE', 'BEN_DFLT_TO_ASN_PNDG_CTFN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_enrt_cvg_strt_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_STRT',
           p_lookup_code    => p_enrt_cvg_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cvg_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_CVG_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_enrt_cvg_end_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.enrt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_enrt_cvg_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_CVG_END',
           p_lookup_code    => p_enrt_cvg_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_enrt_cvg_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_CVG_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_mx_wtg_perd_prte_uom
      <> nvl(ben_pln_shd.g_old_rec.mx_wtg_perd_prte_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mx_wtg_perd_prte_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_TM_UOM',
           p_lookup_code    => p_mx_wtg_perd_prte_uom,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mx_wtg_perd_prte_uom');
      fnd_message.set_token('TYPE', 'BEN_TM_UOM');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_nip_dflt_enrt_cd
      <> nvl(ben_pln_shd.g_old_rec.nip_dflt_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nip_dflt_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DFLT_ENRT',
           p_lookup_code    => p_nip_dflt_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_nip_dflt_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_DFLT_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dpnt_cvg_end_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_cvg_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_END',
           p_lookup_code    => p_dpnt_cvg_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_cvg_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_DPNT_CVG_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_dpnt_cvg_strt_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_dpnt_cvg_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_DPNT_CVG_STRT',
           p_lookup_code    => p_dpnt_cvg_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_dpnt_cvg_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_DPNT_CVG_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_nip_pl_uom
      <> nvl(ben_pln_shd.g_old_rec.nip_pl_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nip_pl_uom is not null then
    --
    -- check if value of lookup falls within fnd_currencies.
    --
     open c1;
     fetch c1 into l_dummy;
     if c1%notfound then
        close c1;
        -- raise error as currency not found
        --
        fnd_message.set_name('BEN','BEN_91306_INV_PGM_UOM'); -- same msg for plan
        fnd_message.raise_error;
     end if;
     close c1;
    --
  end if;
  --

  if (l_api_updating
      and p_nip_acty_ref_perd_cd
      <> nvl(ben_pln_shd.g_old_rec.nip_acty_ref_perd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nip_acty_ref_perd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ACTY_REF_PERD',
           p_lookup_code    => p_nip_acty_ref_perd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_nip_acty_ref_perd_cd');
      fnd_message.set_token('TYPE', 'BEN_ACTY_REF_PERD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_nip_enrt_info_rt_freq_cd
      <> nvl(ben_pln_shd.g_old_rec.nip_enrt_info_rt_freq_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_nip_enrt_info_rt_freq_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_ENRT_INFO_RT_FREQ',
           p_lookup_code    => p_nip_enrt_info_rt_freq_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_nip_enrt_info_rt_freq_cd');
      fnd_message.set_token('TYPE', 'BEN_ENRT_INFO_RT_FREQ');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_prort_prtl_yr_cvg_rstrn_cd
      <> nvl(ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prort_prtl_yr_cvg_rstrn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRORT_PRTL_YR_CVG_RSTRN',
           p_lookup_code    => p_prort_prtl_yr_cvg_rstrn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prort_prtl_yr_cvg_rstrn_cd');
      fnd_message.set_token('TYPE', 'BEN_PRORT_PRTL_YR_CVG_RSTRN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_hc_svc_typ_cd
      <> nvl(ben_pln_shd.g_old_rec.hc_svc_typ_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_hc_svc_typ_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_HLTH_CARE_SVC_TYP',
           p_lookup_code    => p_hc_svc_typ_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_hc_svc_typ_cd');
      fnd_message.set_token('TYPE', 'BEN_HLTH_CARE_SVC_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_pl_stat_cd
      <> nvl(ben_pln_shd.g_old_rec.pl_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pl_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT',
           p_lookup_code    => p_pl_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_pl_stat_cd');
      fnd_message.set_token('TYPE', 'BEN_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_prmry_fndg_mthd_cd
      <> nvl(ben_pln_shd.g_old_rec.prmry_fndg_mthd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prmry_fndg_mthd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PRMRY_FNDG_MTHD',
           p_lookup_code    => p_prmry_fndg_mthd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_prmry_fndg_mthd_cd');
      fnd_message.set_token('TYPE', 'BEN_PRMRY_FNDG_MTHD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_end_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.rt_end_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_end_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_END',
           p_lookup_code    => p_rt_end_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rt_end_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_RT_END');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_rt_strt_dt_cd
      <> nvl(ben_pln_shd.g_old_rec.rt_strt_dt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rt_strt_dt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RT_STRT',
           p_lookup_code    => p_rt_strt_dt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_rt_strt_dt_cd');
      fnd_message.set_token('TYPE', 'BEN_RT_STRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_bnf_dsgn_cd
      <> nvl(ben_pln_shd.g_old_rec.bnf_dsgn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_bnf_dsgn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNF_DSGN',
           p_lookup_code    => p_bnf_dsgn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bnf_dsgn_cd');
      fnd_message.set_token('TYPE', 'BEN_BNF_DSGN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_per_cvrd_cd
      <> nvl(ben_pln_shd.g_old_rec.per_cvrd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_per_cvrd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PER_CVRD',
           p_lookup_code    => p_per_cvrd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_per_cvrd_cd');
      fnd_message.set_token('TYPE', 'BEN_PER_CVRD');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_mx_wtg_dt_to_use_cd
      <> nvl(ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_mx_wtg_dt_to_use_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_MX_WTG_DT_TO_USE',
           p_lookup_code    => p_mx_wtg_dt_to_use_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_mx_wtg_dt_to_use_cd');
      fnd_message.set_token('TYPE', 'BEN_MX_WTG_DT_TO_USE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_BNFT_OR_OPTION_RSTRCTN_cd
      <> nvl(ben_pln_shd.g_old_rec.BNFT_OR_OPTION_RSTRCTN_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_BNFT_OR_OPTION_RSTRCTN_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_BNFT_R_OPT_RSTRN',
           p_lookup_code    => p_BNFT_OR_OPTION_RSTRCTN_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_bnft_or_option_rstrctn_cd');
      fnd_message.set_token('TYPE', 'BEN_BNFT_R_OPT_RSTRN');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  if (l_api_updating
      and p_CVG_INCR_R_DECR_ONLY_cd
      <> nvl(ben_pln_shd.g_old_rec.CVG_INCR_R_DECR_ONLY_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_CVG_INCR_R_DECR_ONLY_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_CVG_INCR_R_DECR_ONLY',
           p_lookup_code    => p_CVG_INCR_R_DECR_ONLY_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_cvg_incr_r_decr_only_cd');
      fnd_message.set_token('TYPE', 'BEN_CVG_INCR_R_DECR_ONLY');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  if (l_api_updating
      and p_unsspnd_enrt_cd
      <> nvl(ben_pln_shd.g_old_rec.unsspnd_enrt_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_unsspnd_enrt_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_UNSSPND_ENRT',
           p_lookup_code    => p_unsspnd_enrt_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_unsspnd_enrt_cd');
      fnd_message.set_token('TYPE', 'BEN_UNSSPND_ENRT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  if (l_api_updating
      and p_imptd_incm_calc_cd
      <> nvl(ben_pln_shd.g_old_rec.imptd_incm_calc_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_imptd_incm_calc_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_IMPTD_INCM_TYP',
           p_lookup_code    => p_imptd_incm_calc_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', 'p_imptd_incm_calc_cd');
      fnd_message.set_token('TYPE', 'BEN_IMPTD_INCM_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_lookups;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_all_rules >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the Formula Rules are valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                      PK of record being inserted or updated.
--   auto_enrt_mthd_rl          Value of formula rule id.
--   mn_cvg_rl                  Value of formula rule id.
--   mx_cvg_rl                  Value of formula rule id.
--   mx_wtg_perd_rl             Value of formula rule id.
--   nip_dflt_enrt_det_rl       Value of formula rule id.
--   prort_prtl_yr_cvg_rstrn_rl Value of formula rule id.
--   mx_wtg_dt_to_use_rl        Value of formula rule id.
--   effective_date             effective date
--   object_version_number      Object version number of record being
--                              inserted or updated.
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
Procedure chk_all_rules(p_pl_id                      in number,
                        p_business_group_id          in number,
                        p_auto_enrt_mthd_rl          in number,
                        p_mn_cvg_rl                  in number,
                        p_mx_cvg_rl                  in number,
                        p_mx_wtg_perd_rl             in number,
                        p_nip_dflt_enrt_det_rl       in number,
                        p_dpnt_cvg_end_dt_rl         in number,
                        p_dpnt_cvg_strt_dt_rl        in number,
                        p_prort_prtl_yr_cvg_rstrn_rl in number,
                        p_mx_wtg_dt_to_use_rl        in number,
                        p_dflt_to_asn_pndg_ctfn_rl   in number,
                        p_enrt_cvg_end_dt_rl         in number,
                        p_postelcn_edit_rl           in number,
                        p_enrt_cvg_strt_dt_rl        in number,
                        p_rt_end_dt_rl               in number,
                        p_rt_strt_dt_rl              in number,
                        p_enrt_rl                    in number,
                        p_rqd_perd_enrt_nenrt_rl     in number,
                        p_effective_date             in date,
                        p_object_version_number      in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_all_rules';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1(p_rule number,p_rule_type_id number) is
    select null
    from   ff_formulas_f ff,
           per_business_groups pbg
    where  ff.formula_id = p_rule
    and    ff.formula_type_id = p_rule_type_id
    and    pbg.business_group_id = p_business_group_id
    and    nvl(ff.business_group_id,p_business_group_id) =
           p_business_group_id
    and    nvl(ff.legislation_code,pbg.legislation_code) =
           pbg.legislation_code
    and    p_effective_date
           between ff.effective_start_date
           and     ff.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_pl_id                       => p_pl_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_auto_enrt_mthd_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.auto_enrt_mthd_rl
      or not l_api_updating)
      and p_auto_enrt_mthd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_auto_enrt_mthd_rl,-146); -- BEN_AUTO_ENRT_MTHD
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
        fnd_message.set_token('ID',p_auto_enrt_mthd_rl);
        fnd_message.set_token('TYPE_ID',-146);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_mn_cvg_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.mn_cvg_rl
      or not l_api_updating)
      and p_mn_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_mn_cvg_rl,-164); -- BEN_MN_CVG_CALC
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
      fnd_message.set_token('ID',p_mn_cvg_rl);
      fnd_message.set_token('TYPE_ID',-164);
      fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_mx_cvg_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.mx_cvg_rl
      or not l_api_updating)
      and p_mx_cvg_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_mx_cvg_rl,-161); -- BEN_MX_CVG_CALC
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
        fnd_message.set_token('ID',p_mx_cvg_rl);
        fnd_message.set_token('TYPE_ID',-161);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_mx_wtg_perd_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.mx_wtg_perd_rl
      or not l_api_updating)
      and p_mx_wtg_perd_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_mx_wtg_perd_rl,-518); --BEN_MX_WTG_PERD_RL
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
        fnd_message.set_token('ID',p_mx_wtg_perd_rl);
        fnd_message.set_token('TYPE_ID',-518);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_rqd_perd_enrt_nenrt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.rqd_perd_enrt_nenrt_rl
      or not l_api_updating)
      and p_rqd_perd_enrt_nenrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_rqd_perd_enrt_nenrt_rl,-513);
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
        fnd_message.set_token('ID',p_rqd_perd_enrt_nenrt_rl);
        fnd_message.set_token('TYPE_ID',-513);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_nip_dflt_enrt_det_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.nip_dflt_enrt_det_rl
      or not l_api_updating)
      and p_nip_dflt_enrt_det_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_nip_dflt_enrt_det_rl,-32); --BEN_DFLT_ENRT_DET
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
        fnd_message.set_token('ID',p_nip_dflt_enrt_det_rl);
        fnd_message.set_token('TYPE_ID',-32);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.dpnt_cvg_end_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_dpnt_cvg_end_dt_rl,-28); --BEN_DPNT_CVG_END
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
        fnd_message.set_token('ID',p_dpnt_cvg_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-28);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_dpnt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.dpnt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_dpnt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_dpnt_cvg_strt_dt_rl,-27); --BEN_DPNT_CVG_STRT
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
        fnd_message.set_token('ID',p_dpnt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-27);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_dflt_to_asn_pndg_ctfn_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.dflt_to_asn_pndg_ctfn_rl
      or not l_api_updating)
      and p_dflt_to_asn_pndg_ctfn_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_dflt_to_asn_pndg_ctfn_rl,-454);
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
        fnd_message.set_token('ID',p_dflt_to_asn_pndg_ctfn_rl);
        fnd_message.set_token('TYPE_ID',-454);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_postelcn_edit_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.postelcn_edit_rl
      or not l_api_updating)
      and p_postelcn_edit_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_postelcn_edit_rl,-215);
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
        fnd_message.set_token('ID',p_postelcn_edit_rl);
        fnd_message.set_token('TYPE_ID',-215);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_prort_prtl_yr_cvg_rstrn_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.prort_prtl_yr_cvg_rstrn_rl
      or not l_api_updating)
      and p_prort_prtl_yr_cvg_rstrn_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_prort_prtl_yr_cvg_rstrn_rl,-166); --BEN_PRTL_YR_CVG_RSTRN
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
        fnd_message.set_token('ID',p_prort_prtl_yr_cvg_rstrn_rl);
        fnd_message.set_token('TYPE_ID',-166);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_rt_end_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.rt_end_dt_rl
      or not l_api_updating)
      and p_rt_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_rt_end_dt_rl,-67);
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
        fnd_message.set_token('ID',p_rt_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-67);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_rt_strt_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.rt_strt_dt_rl
      or not l_api_updating)
      and p_rt_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_rt_strt_dt_rl,-66);
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
        fnd_message.set_token('ID',p_rt_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-66);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_mx_wtg_dt_to_use_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.mx_wtg_dt_to_use_rl
      or not l_api_updating)
      and p_mx_wtg_dt_to_use_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_mx_wtg_dt_to_use_rl,-162);
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
        fnd_message.set_token('ID',p_mx_wtg_dt_to_use_rl);
        fnd_message.set_token('TYPE_ID',-162);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_strt_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.enrt_cvg_strt_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_strt_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_enrt_cvg_strt_dt_rl,-29);
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
        fnd_message.set_token('ID',p_enrt_cvg_strt_dt_rl);
        fnd_message.set_token('TYPE_ID',-29);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_enrt_cvg_end_dt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.enrt_cvg_end_dt_rl
      or not l_api_updating)
      and p_enrt_cvg_end_dt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_enrt_cvg_end_dt_rl,-30);
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
        fnd_message.set_token('ID',p_enrt_cvg_end_dt_rl);
        fnd_message.set_token('TYPE_ID',-30);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  if (l_api_updating
      and nvl(p_enrt_rl,hr_api.g_number)
      <> ben_pln_shd.g_old_rec.enrt_rl
      or not l_api_updating)
      and p_enrt_rl is not null then
    --
    -- check if value of formula rule is valid.
    --
    open c1(p_enrt_rl,-393);
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
        fnd_message.set_token('ID',p_enrt_rl);
        fnd_message.set_token('TYPE_ID',-393);
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_rules;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_cd_rl_combination >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check the code is RULE then the rule must be
--   defined else it should not be.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_dpnt_cvg_end_dt_cd        in varchar2
--   p_dpnt_cvg_end_dt_rl        in number,
--   p_vrfy_fmly_mmbr_cd         in varchar2,
--   p_vrfy_fmly_mmbr_rl         in number,
--   p_dpnt_cvg_strt_dt_cd       in varchar2,
--   p_dpnt_cvg_strt_dt_rl       in number,
--   p_enrt_cvg_end_dt_cd        in varchar2
--   p_enrt_cvg_end_dt_rl        in number,
--   p_enrt_cvg_strt_dt_cd       in varchar2,
--   p_enrt_cvg_strt_dt_rl       in number,
--   p_rt_strt_dt_cd             in varchar2,
--   p_rt_strt_dt_rl             in number,
--   p_rt_end_dt_cd              in varchar2,
--   p_rt_end_dt_rl              in number
--
-- object_version_number      Object version number of record being
--                            inserted or updated.
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
procedure chk_cd_rl_combination
(
   p_dpnt_cvg_end_dt_cd        in varchar2,
   p_dpnt_cvg_end_dt_rl        in number,
   p_vrfy_fmly_mmbr_cd         in varchar2,
   p_vrfy_fmly_mmbr_rl         in number,
   p_dpnt_cvg_strt_dt_cd       in varchar2,
   p_dpnt_cvg_strt_dt_rl       in number,
   p_enrt_cvg_end_dt_cd        in varchar2,
   p_enrt_cvg_end_dt_rl        in number,
   p_enrt_cvg_strt_dt_cd       in varchar2,
   p_enrt_cvg_strt_dt_rl       in number,
   p_rt_strt_dt_cd             in varchar2,
   p_rt_strt_dt_rl             in number,
   p_rt_end_dt_cd              in varchar2,
   p_rt_end_dt_rl              in number   ) IS
   l_proc         varchar2(72) := g_package||'chk_cd_rl_combination';
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  if    (p_vrfy_fmly_mmbr_cd <> 'RL' and p_vrfy_fmly_mmbr_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_vrfy_fmly_mmbr_cd = 'RL' and p_vrfy_fmly_mmbr_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  if    (p_dpnt_cvg_end_dt_cd <> 'RL' and p_dpnt_cvg_end_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_dpnt_cvg_end_dt_cd = 'RL' and p_dpnt_cvg_end_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  if    (p_dpnt_cvg_strt_dt_cd <> 'RL' and p_dpnt_cvg_strt_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_dpnt_cvg_strt_dt_cd = 'RL' and p_dpnt_cvg_strt_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  if    (p_enrt_cvg_end_dt_cd <> 'RL' and p_enrt_cvg_end_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_enrt_cvg_end_dt_cd = 'RL' and p_enrt_cvg_end_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  if    (p_enrt_cvg_strt_dt_cd <> 'RL' and p_enrt_cvg_strt_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_enrt_cvg_strt_dt_cd = 'RL' and p_enrt_cvg_strt_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  if    (p_rt_strt_dt_cd <> 'RL' and p_rt_strt_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_rt_strt_dt_cd = 'RL' and p_rt_strt_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  --
  if    (p_rt_end_dt_cd <> 'RL' and p_rt_end_dt_rl is not null)
  then
                fnd_message.set_name('BEN','BEN_91730_NO_RULE');
                fnd_message.raise_error;
  end if;

  if (p_rt_end_dt_cd = 'RL' and p_rt_end_dt_rl is null)
  then
                fnd_message.set_name('BEN','BEN_91731_RULE');
                fnd_message.raise_error;
  end if;
  -- Leaving Procedure.
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cd_rl_combination;

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_all_no_amount_flags >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the combination of the
--   "no amount" flags and the "amount" values is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   no_mn_cvg_dfnd_flag
--   mn_cvg_rqd_amt
--   no_mx_cvg_dfnd_flag
--   mx_cvg_rqd_amt
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
Procedure chk_all_no_amount_flags
     (p_no_mn_cvg_amt_apls_flag           in varchar2,
      p_mn_cvg_rqd_amt                    in number,
      p_no_mx_cvg_amt_apls_flag           in varchar2,
      p_mx_cvg_alwd_amt                   in number) is
  --
  l_proc varchar2(72) := g_package||'chk_all_no_amount_flags';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if it is a valid combination
  --
  if ((p_no_mn_cvg_amt_apls_flag='Y' and p_mn_cvg_rqd_amt>0) or
      (p_no_mn_cvg_amt_apls_flag='N' and p_mn_cvg_rqd_amt=0)) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91150_NO_MIN_CVG_APLS_FLAG');
    fnd_message.raise_error;
    --
  end if;
  --
  -- check if it is a valid combination
  --
  if ((p_no_mx_cvg_amt_apls_flag='Y' and p_mx_cvg_alwd_amt>0) or
      (p_no_mx_cvg_amt_apls_flag='N' and p_mx_cvg_alwd_amt=0)) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91149_NO_MAX_CVG_APLS_FLAG');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_all_no_amount_flags;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_mn_val_mx_val >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check if the min value is
--   less than the max value.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_mn_val minimum value
--   p_mx_val maximum value
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
Procedure chk_mn_val_mx_val(p_mn_val in number,
                        p_mx_val in number) is
  --
  l_proc varchar2(72) := g_package||'chk_mn_val_mx_val';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check the values
  -- note: Don't want an error if either one is null
  --
  if (p_mn_val >= p_mx_val) then
    --
    -- raise error as is not a valid combination
    --
    fnd_message.set_name('BEN','BEN_91142_MIN_LESS_NOT_EQ_MAX');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 5);
  --
end chk_mn_val_mx_val;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_plan_oipl_mutexcl >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the plan is mutually exclusive for the
--   actl_prem_id. An oipl cannot exist with this actl_prem_id due to the ARC
--   relationship on ben_actl_prem_f.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   pl_id                 PK of record being inserted or updated.
--   actl_prem_id          actl_prem_id.
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
Procedure chk_plan_oipl_mutexcl(p_pl_id                     in number,
                               p_actl_prem_id               in number,
                               p_effective_date            in date,
                               p_business_group_id         in number,
                               p_object_version_number     in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_plan_oipl_mutexcl';
  l_api_updating boolean;
  l_dummy varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_oipl_f a
    where  a.business_group_id +0 = p_business_group_id
    and    a.actl_prem_id = p_actl_prem_id
    and    p_effective_date
           between a.effective_start_date
           and     a.effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pln_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_pl_id                       => p_pl_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and p_actl_prem_id is not null) then
    --
    -- Check if actl_prem_id is mutually exclusive.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise an error as this actl_prem_id has been assigned to oipl(s).
        --
        fnd_message.set_name('BEN','BEN_91610_PLAN_OPTION_EXCL1');
        fnd_message.raise_error;
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_plan_oipl_mutexcl;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_nip_pln_uom >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description                                -- Procedure Added for Bug 2447647
--   This procedure is used to check that the Currency field on
--   the Not in Program tab is not null if the Plan Type linked
--   to the Plan has the option type of 'Compensation Work Bench'
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   p_pl_typ_id           Id of the Plan type being linked to the plan
--   p_pl_cd               Plan Usage code
--   p_nip_pl_uom          Not in Program plan Currency
--   p_effective_date      Session date of record
--   p_business_group_id   Business group id of record being inserted/updated.
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
Procedure chk_nip_pln_uom(p_pl_typ_id  in number,
                          p_pl_cd      in varchar2,
                          p_nip_pl_uom in varchar2,
                          p_effective_date in date,
                          p_business_group_id  in number) is
  --
  l_proc   varchar2(72) := g_package||'chk_nip_pln_uom';
  l_opt_typ_cd varchar2(30);
  l_comp_typ_cd varchar2(30);
  --
  cursor c_pln_typ_opt_typ_cd is
  select opt_typ_cd ,comp_typ_cd
  from   ben_pl_typ_f
  where  pl_typ_id = p_pl_typ_id
  and    business_group_id = p_business_group_id
  and    p_effective_date
         between effective_start_date
         and     effective_end_date;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if (p_pl_typ_id is not null) then
    --
    -- Get the option type code of the plan type linked to the plan
    --
    open c_pln_typ_opt_typ_cd;
    --
    fetch c_pln_typ_opt_typ_cd into l_opt_typ_cd,l_comp_typ_cd;
    --
    if c_pln_typ_opt_typ_cd%found then
      --
      close c_pln_typ_opt_typ_cd;
      --
      -- Bug2808250: raising error only if the compensation category
      -- is not the "CWB - Other"
      --
      if l_opt_typ_cd  is not null and ( l_opt_typ_cd = 'CWB'
         and l_comp_typ_cd <> 'ICM5' ) and p_pl_cd = 'MYNTBPGM' then
        --
        if p_nip_pl_uom is null then
          --
          -- raise an error as Currency field is null when Option Type code is CWB
          --
          fnd_message.set_name('BEN','BEN_93115_NIP_UOM_RQD');
          fnd_message.raise_error;
         null;
        end if;
        --
      end if;
      --
    else
      --
      close c_pln_typ_opt_typ_cd;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_nip_pln_uom;
--
-- bug 3876692
--
-- ----------------------------------------------------------------------------
-- |------< chk_prfl_rule_extnce >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks if they are already attached profiles or rules
--   to the current plan and if yes, then it won't allow the plan to be of type
--   flex shell or imputed income.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_pl_id PK
--   p_imptd_incm_calc_cd
--   p_invk_flx_cr_pl_flag
--   p_effective_date session date
--   p_object_version_number number
--   p_validation_start_date date
--   p_validation_end_date date
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_prfl_rule_extnce(
                      p_pl_id                 in number,
                      p_imptd_incm_calc_cd    in varchar2,
                      p_invk_flx_cr_pl_flag   in varchar2,
                      p_effective_date        in date,
					  p_object_version_number in number,
					  p_validation_start_date in date,
					  p_validation_end_date   in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_prfl_rule_extnce';
  l_api_updating boolean;
  l_exists       varchar2(1);
  --
  cursor c1 is
     select null
       from ben_prtn_elig_f epa, ben_prtn_elig_prfl_f cep, ben_prtn_eligy_rl_f cer
         where epa.pl_id = p_pl_id
           and ((epa.prtn_elig_id  = cep.prtn_elig_id
		   and p_validation_start_date <= cep.effective_end_date
           and p_validation_end_date >= cep.effective_start_date)
		                         or
		   (epa.prtn_elig_id  = cer.prtn_elig_id
		   and p_validation_start_date <= cer.effective_end_date
           and p_validation_end_date >= cer.effective_start_date));
  --
  cursor c2 is
     select null
       from ben_prtn_elig_f epa, ben_prtn_elig_prfl_f cep,
	        ben_prtn_eligy_rl_f cer, ben_plip_f plip
         where plip.pl_id = p_pl_id
		   and epa.plip_id = plip.plip_id
		   and p_effective_date between plip.effective_start_date and plip.effective_end_date
		   and ((p_validation_start_date <= cep.effective_end_date
               and p_validation_end_date >= cep.effective_start_date
               and epa.prtn_elig_id  = cep.prtn_elig_id)
                                   or
               (p_validation_start_date <= cer.effective_end_date
               and p_validation_end_date >= cer.effective_start_date
               and epa.prtn_elig_id  = cer.prtn_elig_id));
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pln_shd.api_updating
                    (p_effective_date              => p_effective_date,
                     p_pl_id                       => p_pl_id,
                     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and ((p_imptd_incm_calc_cd is not null and
          ben_pln_shd.g_old_rec.imptd_incm_calc_cd is null) or
          (p_invk_flx_cr_pl_flag = 'Y' and
		   ben_pln_shd.g_old_rec.invk_flx_cr_pl_flag = 'N'))) then
  --
    open c1;
    fetch c1 into l_exists;
    if c1%found then
      close c1;
      --
      -- raise error as plan can't be made flex credit or imputed shell
	  -- once eligibility profiles are attached to it
      --
      fnd_message.set_name('BEN','BEN_94066_PLN_UPD_VAL');
      fnd_message.raise_error;
    --
    else
      close c1;
      open c2;
      fetch c2 into l_exists;
      if c2%found then
          close c2;
      --
      -- raise error as plan can't be made flex credit or imputed shell
	  -- once eligibility rule are attached to it
      --
          fnd_message.set_name('BEN','BEN_94066_PLN_UPD_VAL');
          fnd_message.raise_error;
      --
      end if;
      close c2;
    --
    end if;
  --
  end if;
  --
    hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_prfl_rule_extnce;
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
            (p_auto_enrt_mthd_rl           in number default hr_api.g_number,
             p_mn_cvg_rl                   in number default hr_api.g_number,
             p_mx_cvg_rl                   in number default hr_api.g_number,
             p_mx_wtg_perd_rl              in number default hr_api.g_number,
             p_nip_dflt_enrt_det_rl        in number default hr_api.g_number,
             p_prort_prtl_yr_cvg_rstrn_rl  in number default hr_api.g_number,
             p_pl_typ_id                   in number default hr_api.g_number,
             p_actl_prem_id                in number default hr_api.g_number,
             p_mx_wtg_dt_to_use_rl         in number default hr_api.g_number,
             p_dflt_to_asn_pndg_ctfn_rl    in number default hr_api.g_number,
             p_dpnt_cvg_end_dt_rl          in number default hr_api.g_number,
             p_dpnt_cvg_strt_dt_rl         in number default hr_api.g_number,
             p_enrt_cvg_end_dt_rl          in number default hr_api.g_number,
             p_enrt_cvg_strt_dt_rl         in number default hr_api.g_number,
             p_postelcn_edit_rl            in number default hr_api.g_number,
             p_rt_end_dt_rl                in number default hr_api.g_number,
             p_rt_strt_dt_rl               in number default hr_api.g_number,
             p_ENRT_RL                     in NUMBER default hr_api.g_NUMBER,
             p_rqd_perd_enrt_nenrt_rl      in NUMBER default hr_api.g_NUMBER,
             p_bnft_prvdr_pool_id          in number default hr_api.g_NUMBER,
             p_datetrack_mode              in varchar2,
             p_validation_start_date       in date,
             p_validation_end_date         in date) Is
--
  l_proc        varchar2(72) := g_package||'dt_update_validate';
  l_integrity_error Exception;
  l_table_name        all_tables.table_name%TYPE;
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
    If ((nvl(p_auto_enrt_mthd_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_auto_enrt_mthd_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_mn_cvg_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_mn_cvg_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_mx_cvg_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_mx_cvg_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_bnft_prvdr_pool_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_bnft_prvdr_pool_f',
             p_base_key_column => 'bnft_prvdr_pool_id',
             p_base_key_value  => p_bnft_prvdr_pool_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_enrt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_enrt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_rqd_perd_enrt_nenrt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_rqd_perd_enrt_nenrt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_mx_wtg_perd_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_mx_wtg_perd_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_nip_dflt_enrt_det_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_nip_dflt_enrt_det_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_dpnt_cvg_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_dpnt_cvg_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_prort_prtl_yr_cvg_rstrn_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_prort_prtl_yr_cvg_rstrn_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    If ((nvl(p_pl_typ_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_pl_typ_f',
             p_base_key_column => 'pl_typ_id',
             p_base_key_value  => p_pl_typ_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_pl_typ_f';
      Raise l_integrity_error;
    End If;
    --

--    Commented out because actl_prem_f is parent of plan!!!!!!!!!
--
--    If ((nvl(p_actl_prem_id, hr_api.g_number) <> hr_api.g_number) and
--      NOT (dt_api.check_min_max_dates
--            (p_base_table_name => 'ben_actl_prem_f',
--             p_base_key_column => 'actl_prem_id',
--             p_base_key_value  => p_actl_prem_id,
--             p_from_date       => p_validation_start_date,
--             p_to_date         => p_validation_end_date)))  Then
--      l_table_name := 'ben_actl_prem_f';
--      Raise l_integrity_error;
--    End If;
    --
    If ((nvl(p_dflt_to_asn_pndg_ctfn_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dflt_to_asn_pndg_ctfn_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_dpnt_cvg_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_dpnt_cvg_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_dpnt_cvg_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_enrt_cvg_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_enrt_cvg_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_enrt_cvg_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_enrt_cvg_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_postelcn_edit_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_postelcn_edit_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_rt_end_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_rt_end_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
      Raise l_integrity_error;
    End If;
    --
    If ((nvl(p_rt_strt_dt_rl, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ff_formulas_f',
             p_base_key_column => 'formula_id',
             p_base_key_value  => p_rt_strt_dt_rl,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ff_formulas_f';
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
            (p_pl_id        in number,
             p_datetrack_mode        in varchar2,
         p_validation_start_date    in date,
         p_validation_end_date    in date,
         p_name                   in varchar2) Is
--
  l_proc    varchar2(72)     := g_package||'dt_delete_validate';
  l_rows_exist    Exception;
  l_table_name    all_tables.table_name%TYPE;
  --
  l_val number;
  --
  Cursor c_yr_perd_exists(p_pl_id in number ) Is
    select 1
    from   ben_popl_yr_perd  t
    where  t.pl_id       = p_pl_id ;
--
  Cursor c_cwb_exists(p_pl_id in number ) Is
    select 1
    from   ben_cwb_wksht_grp t
    where  t.pl_id       = p_pl_id ;
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
       p_argument       => 'pl_id',
       p_argument_value => p_pl_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_regy_bod_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_regy_bod_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_oipl_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_oipl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_enrt_typ_cycl_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_enrt_typ_cycl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_vald_rlshp_for_reimb_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_vald_rlshp_for_reimb_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_pl_nip_enrt_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_pl_nip_enrt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_gd_or_svc_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_gd_or_svc_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_plip_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_plip_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_regn_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_regn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_to_prte_rsn_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_to_prte_rsn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtn_elig_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtn_elig_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cvg_amt_calc_mthd_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cvg_amt_calc_mthd_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_ler_chg_dpnt_cvg_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_ler_chg_dpnt_cvg_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_org_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_org_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_per_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_per_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_acty_base_rt_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_acty_base_rt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_dpnt_cvg_ctfn_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_dpnt_cvg_ctfn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_bnf_ctfn_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_bnf_ctfn_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_popl_rptg_grp_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_rptg_grp_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_reimbmt_rqst_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_reimbmt_rqst_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_apld_dpnt_cvg_elig_prfl_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_apld_dpnt_cvg_elig_prfl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_dsgn_rqmt_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_dsgn_rqmt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_elig_prtt_anthr_pl_prte_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_elig_prtt_anthr_pl_prte_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_pl_r_oipl_asset_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_pl_r_oipl_asset_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_prtt_enrt_rslt_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_prtt_enrt_rslt_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_vrbl_rt_prfl_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_vrbl_rt_prfl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_wv_prtn_rsn_pl_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_wv_prtn_rsn_pl_f';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_bnft_rstrn_ctfn_f',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_bnft_rstrn_ctfn_f';
      Raise l_rows_exist;
    End If;
    /* If (dt_api.rows_exist  -- Bug 4304937
          (p_base_table_name => 'ben_popl_yr_perd',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_popl_yr_perd';
      Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist  -- Bug 4304937
          (p_base_table_name => 'ben_cwb_wksht_grp',
           p_base_key_column => 'pl_id',
           p_base_key_value  => p_pl_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cwb_wksht_grp';
      Raise l_rows_exist;
    End If;
    */
    --
    open c_yr_perd_exists(p_pl_id );
    fetch c_yr_perd_exists into l_val ;
    if c_yr_perd_exists%found
    then
       close c_yr_perd_exists;
       l_table_name := 'ben_popl_yr_perd';
       Raise l_rows_exist;
    end if;
    close c_yr_perd_exists;
    --
    open c_cwb_exists(p_pl_id );
    fetch c_cwb_exists into l_val ;
    if c_cwb_exists%found
    then
       close c_cwb_exists;
       l_table_name := 'ben_cwb_wksht_grp';
       Raise l_rows_exist;
    end if;
    close c_cwb_exists;
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
    ben_utility.child_exists_error(p_table_name               => l_table_name,
                                   p_parent_table_name        => 'BEN_PL_F',        /* Bug 4057566 */
                                   p_parent_entity_name       => p_name);      /* Bug 4057566 */
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
    (p_rec              in ben_pln_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
  --
  chk_pl_id
  (p_pl_id                     => p_rec.pl_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --

  chk_plan_name_unique
  (p_pl_id                     => p_rec.pl_id,
   p_name                      => p_rec.name,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date         => p_validation_end_date);
  --
  --Bug : 3475996
  chk_cwb_plan_type_uniq_plan(p_pl_id                 =>  p_rec.pl_id,
			      p_name                  =>  p_rec.name,
			      p_pl_typ_id             =>  p_rec.pl_typ_id,
			      p_group_pl_id           =>  p_rec.group_pl_id,
			      p_effective_date        =>  p_effective_date,
			      p_business_group_id     =>  p_rec.business_group_id,
			      p_object_version_number =>  p_rec.object_version_number,
			      p_validation_start_date =>  p_validation_start_date,
			      p_validation_end_date   =>  p_validation_end_date);
  --
  chk_vrfy_fmly_mmbr_cd
  (p_pl_id                 => p_rec.pl_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_use_csd_rsd_prccng_cd
  (p_pl_id                 => p_rec.pl_id,
   p_use_csd_rsd_prccng_cd => p_rec.use_csd_rsd_prccng_cd,
   p_effective_date        => p_effective_date,
   p_pl_cd                 => p_rec.pl_cd,
   p_object_version_number => p_rec.object_version_number);

  /* -- Bug 2562196
  chk_dflt_to_asn_pndg_ctfn_cd
  (p_dflt_to_asn_pndg_ctfn_cd  	=> p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_pl_id                     	=> p_rec.pl_id,
   p_effective_date            	=> p_effective_date,
   p_business_group_id          => p_rec.business_group_id,
   p_object_version_number 	=> p_rec.object_version_number);
  --
  */
  chk_vrfy_fmly_mmbr_rl
  (p_pl_id                 => p_rec.pl_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_measures_allowed
  (p_bnf_pct_amt_alwd_cd       => p_rec.bnf_pct_amt_alwd_cd,
   p_bnf_incrmt_amt            => p_rec.bnf_incrmt_amt,
   p_bnf_pct_incrmt_val        => p_rec.bnf_pct_incrmt_val,
   p_bnf_mn_dsgntbl_amt        => p_rec.bnf_mn_dsgntbl_amt);
  --
  chk_code_rule_dpnd
  (p_code                      => p_rec.mx_wtg_dt_to_use_cd,
   p_rule                      => p_rec.mx_wtg_dt_to_use_rl);
  --
  chk_mn_val_mn_flag_mn_rule
  (p_mn_cvg_rqd_amt            => p_rec.mn_cvg_rqd_amt,
   p_no_mn_cvg_amt_apls_flag   => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rl                 => p_rec.mn_cvg_rl);
  --
  chk_dpnt_dsgn_cd
  (p_dpnt_dsgn_cd        => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd);
  --
  chk_dpnt_dsgn_cd_detail
     (p_pl_id  => p_rec.pl_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_bnf_dsgn_cd => p_rec.bnf_dsgn_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_validation_start_date => p_validation_start_date,
      p_validation_end_date => p_validation_end_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_mx_val_mx_flag_mx_rule
  (p_mx_cvg_alwd_amt           => p_rec.mx_cvg_alwd_amt,
   p_no_mx_cvg_amt_apls_flag   => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_rl                 => p_rec.mx_cvg_rl);
  --
  chk_mutual_exclusive_flags
  (p_pl_id                     => p_rec.pl_id,
   p_invk_dcln_prtn_pl_flag    => p_rec.invk_dcln_prtn_pl_flag,
   p_invk_flx_cr_pl_flag       => p_rec.invk_flx_cr_pl_flag,
   p_svgs_pl_flag              => p_rec.svgs_pl_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_mutual_exlsv_rule_num_uom
  (p_pl_id                     => p_rec.pl_id,
   p_mx_wtg_perd_rl            => p_rec.mx_wtg_perd_rl,
   p_mx_wtg_perd_prte_val      => p_rec.mx_wtg_perd_prte_val,
   p_mx_wtg_perd_prte_uom      => p_rec.mx_wtg_perd_prte_uom,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_all_flags
  (p_pl_id                        => p_rec.pl_id,
   p_alws_qdro_flag               => p_rec.alws_qdro_flag,
   p_alws_qmcso_flag              => p_rec.alws_qmcso_flag,
   p_bnf_addl_instn_txt_alwd_flag => p_rec.bnf_addl_instn_txt_alwd_flag,
   p_bnf_adrs_rqd_flag            => p_rec.bnf_adrs_rqd_flag,
   p_bnf_cntngt_bnfs_alwd_flag    => p_rec.bnf_cntngt_bnfs_alwd_flag,
   p_bnf_ctfn_rqd_flag            => p_rec.bnf_ctfn_rqd_flag,
   p_bnf_dob_rqd_flag             => p_rec.bnf_dob_rqd_flag,
   p_bnf_dsge_mnr_ttee_rqd_flag   => p_rec.bnf_dsge_mnr_ttee_rqd_flag,
   p_bnf_legv_id_rqd_flag         => p_rec.bnf_legv_id_rqd_flag,
   p_bnf_may_dsgt_org_flag        => p_rec.bnf_may_dsgt_org_flag,
   p_bnf_qdro_rl_apls_flag        => p_rec.bnf_qdro_rl_apls_flag,
   p_drvbl_fctr_apls_rts_flag     => p_rec.drvbl_fctr_apls_rts_flag,
   p_drvbl_fctr_prtn_elig_flag    => p_rec.drvbl_fctr_prtn_elig_flag,
   p_elig_apls_flag               => p_rec.elig_apls_flag,
   p_invk_dcln_prtn_pl_flag       => p_rec.invk_dcln_prtn_pl_flag,
   p_invk_flx_cr_pl_flag          => p_rec.invk_flx_cr_pl_flag,
   p_drvbl_dpnt_elig_flag         => p_rec.drvbl_dpnt_elig_flag,
   p_trk_inelig_per_flag          => p_rec.trk_inelig_per_flag,
   p_dpnt_cvd_by_othr_apls_flag   => p_rec.dpnt_cvd_by_othr_apls_flag,
   p_frfs_aply_flag               => p_rec.frfs_aply_flag,
   p_hc_pl_subj_hcfa_aprvl_flag   => p_rec.hc_pl_subj_hcfa_aprvl_flag,
   p_hghly_cmpd_rl_apls_flag      => p_rec.hghly_cmpd_rl_apls_flag,
   p_no_mn_cvg_amt_apls_flag      => p_rec.no_mn_cvg_amt_apls_flag,
   p_no_mn_cvg_incr_apls_flag     => p_rec.no_mn_cvg_incr_apls_flag,
   p_no_mn_opts_num_apls_flag     => p_rec.no_mn_opts_num_apls_flag,
   p_no_mx_cvg_amt_apls_flag      => p_rec.no_mx_cvg_amt_apls_flag,
   p_no_mx_cvg_incr_apls_flag     => p_rec.no_mx_cvg_incr_apls_flag,
   p_no_mx_opts_num_apls_flag     => p_rec.no_mx_opts_num_apls_flag,
   p_prtn_elig_ovrid_alwd_flag    => p_rec.prtn_elig_ovrid_alwd_flag,
   p_subj_to_imptd_incm_typ_cd    => p_rec.subj_to_imptd_incm_typ_cd,
   p_use_all_asnts_elig_flag      => p_rec.use_all_asnts_elig_flag,
   p_use_all_asnts_for_rt_flag    => p_rec.use_all_asnts_for_rt_flag,
   p_vstg_apls_flag               => p_rec.vstg_apls_flag,
   p_wvbl_flag                    => p_rec.wvbl_flag,
   p_alws_reimbmts_flag           => p_rec.alws_reimbmts_flag,
   p_dpnt_adrs_rqd_flag           => p_rec.dpnt_adrs_rqd_flag,
   p_dpnt_dob_rqd_flag            => p_rec.dpnt_dob_rqd_flag,
   p_dpnt_leg_id_rqd_flag         => p_rec.dpnt_leg_id_rqd_flag,
   p_dpnt_no_ctfn_rqd_flag        => p_rec.dpnt_no_ctfn_rqd_flag,
   p_svgs_pl_flag                 => p_rec.svgs_pl_flag,
   p_enrt_pl_opt_flag             => p_rec.enrt_pl_opt_flag,
   p_MAY_ENRL_PL_N_OIPL_FLAG      => p_rec.may_enrl_pl_n_oipl_flag,
   p_ALWS_UNRSTRCTD_ENRT_FLAG     => p_rec.alws_unrstrctd_enrt_flag,
   p_ALWS_TMPRY_ID_CRD_FLAG       => p_rec.alws_tmpry_id_crd_flag,
   p_nip_dflt_flag                => p_rec.nip_dflt_flag,
   p_post_to_gl_flag              => p_rec.post_to_gl_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_all_lookups
  (p_pl_id                        => p_rec.pl_id,
   p_bnf_dflt_bnf_cd              => p_rec.bnf_dflt_bnf_cd,
   p_bnf_pct_amt_alwd_cd          => p_rec.bnf_pct_amt_alwd_cd,
   p_pl_cd                        => p_rec.pl_cd,
   p_cmpr_clms_to_cvg_or_bal_cd   => p_rec.cmpr_clms_to_cvg_or_bal_cd,
   p_enrt_mthd_cd                 => p_rec.enrt_mthd_cd,
   p_enrt_cd                      => p_rec.enrt_cd,
   p_mx_wtg_perd_prte_uom         => p_rec.mx_wtg_perd_prte_uom,
   p_nip_dflt_enrt_cd             => p_rec.nip_dflt_enrt_cd,
   p_nip_pl_uom                   => p_rec.nip_pl_uom,
   p_rqd_perd_enrt_nenrt_uom                   => p_rec.rqd_perd_enrt_nenrt_uom,
   p_nip_acty_ref_perd_cd         => p_rec.nip_acty_ref_perd_cd,
   p_nip_enrt_info_rt_freq_cd     => p_rec.nip_enrt_info_rt_freq_cd,
   p_prort_prtl_yr_cvg_rstrn_cd   => p_rec.prort_prtl_yr_cvg_rstrn_cd,
   p_hc_svc_typ_cd                => p_rec.hc_svc_typ_cd,
   p_pl_stat_cd                   => p_rec.pl_stat_cd,
   p_prmry_fndg_mthd_cd           => p_rec.prmry_fndg_mthd_cd,
   p_bnf_dsgn_cd                  => p_rec.bnf_dsgn_cd,
   p_mx_wtg_dt_to_use_cd          => p_rec.mx_wtg_dt_to_use_cd,
   p_dflt_to_asn_pndg_ctfn_cd     => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_dpnt_dsgn_cd                 => p_rec.dpnt_dsgn_cd,
   p_enrt_cvg_strt_dt_cd          => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_end_dt_cd           => p_rec.enrt_cvg_end_dt_cd,
   p_dpnt_cvg_strt_dt_cd          => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd           => p_rec.dpnt_cvg_end_dt_cd,
   p_per_cvrd_cd                  => p_rec.per_cvrd_cd,
   p_rt_end_dt_cd                 => p_rec.rt_end_dt_cd,
   p_rt_strt_dt_cd                => p_rec.rt_strt_dt_cd,
   p_BNFT_OR_OPTION_RSTRCTN_CD    => p_rec.BNFT_OR_OPTION_RSTRCTN_CD,
   p_CVG_INCR_R_DECR_ONLY_CD      => p_rec.CVG_INCR_R_DECR_ONLY_CD,
   p_unsspnd_enrt_cd              => p_rec.unsspnd_enrt_cd,
   p_imptd_incm_calc_cd           => p_rec.imptd_incm_calc_cd,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_all_rules
  (p_pl_id                      => p_rec.pl_id,
   p_business_group_id          => p_rec.business_group_id,
   p_auto_enrt_mthd_rl          => p_rec.auto_enrt_mthd_rl,
   p_mn_cvg_rl                  => p_rec.mn_cvg_rl,
   p_mx_cvg_rl                  => p_rec.mx_cvg_rl,
   p_mx_wtg_perd_rl             => p_rec.mx_wtg_perd_rl,
   p_nip_dflt_enrt_det_rl       => p_rec.nip_dflt_enrt_det_rl,
   p_dpnt_cvg_end_dt_rl         => p_rec.dpnt_cvg_end_dt_rl ,
   p_dpnt_cvg_strt_dt_rl        => p_rec.dpnt_cvg_strt_dt_rl,
   p_prort_prtl_yr_cvg_rstrn_rl => p_rec.prort_prtl_yr_cvg_rstrn_rl,
   p_mx_wtg_dt_to_use_rl        => p_rec.mx_wtg_dt_to_use_rl,
   p_dflt_to_asn_pndg_ctfn_rl   => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_enrt_cvg_end_dt_rl         => p_rec.enrt_cvg_end_dt_rl,
   p_postelcn_edit_rl           => p_rec.postelcn_edit_rl,
   p_enrt_cvg_strt_dt_rl        => p_rec.enrt_cvg_strt_dt_rl,
   p_rt_end_dt_rl               => p_rec.rt_end_dt_rl,
   p_rt_strt_dt_rl              => p_rec.rt_strt_dt_rl,
   p_enrt_rl                    => p_rec.enrt_rl,
   p_rqd_perd_enrt_nenrt_rl     => p_rec.rqd_perd_enrt_nenrt_rl,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
--
chk_cd_rl_combination
  (p_dpnt_cvg_end_dt_cd        => p_rec.dpnt_cvg_end_dt_cd,
   p_dpnt_cvg_end_dt_rl        => p_rec.dpnt_cvg_end_dt_rl,
   p_vrfy_fmly_mmbr_cd         => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl         => p_rec.vrfy_fmly_mmbr_rl,
   p_dpnt_cvg_strt_dt_cd       => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_strt_dt_rl       => p_rec.dpnt_cvg_strt_dt_rl,
   p_enrt_cvg_end_dt_cd        => p_rec.enrt_cvg_end_dt_cd,
   p_enrt_cvg_end_dt_rl        => p_rec.enrt_cvg_end_dt_rl,
   p_enrt_cvg_strt_dt_cd       => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_strt_dt_rl       => p_rec.enrt_cvg_strt_dt_rl,
   p_rt_strt_dt_cd             => p_rec.rt_strt_dt_cd,
   p_rt_strt_dt_rl             => p_rec.rt_strt_dt_rl,
   p_rt_end_dt_cd              => p_rec.rt_end_dt_cd,
   p_rt_end_dt_rl              => p_rec.rt_end_dt_rl);
--
  chk_all_no_amount_flags
  (p_no_mn_cvg_amt_apls_flag    => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rqd_amt             => p_rec.mn_cvg_rqd_amt,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_alwd_amt            => p_rec.mx_cvg_alwd_amt);
  --
  chk_mn_val_mx_val
  (p_mn_val                => p_rec.mn_cvg_rqd_amt,
   p_mx_val                => p_rec.mx_cvg_alwd_amt);
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mn_opts_num_apls_flag,
   p_val    => p_rec.mn_opts_rqd_num,
   p_msg    => 'BEN_91695_MIN_VAL_FLAG_EXCLSV');
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mx_opts_num_apls_flag,
   p_val    => p_rec.mx_opts_alwd_num,
   p_msg    => 'BEN_91696_MAX_VAL_FLAG_EXCLSV');
  --
  chk_nip_pln_uom     -- Added for Bug 2447647
  (p_pl_typ_id                 => p_rec.pl_typ_id,
   p_pl_cd                     => p_rec.pl_cd,
   p_nip_pl_uom                => p_rec.nip_pl_uom,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id);
  --
  /* Bug : 3460429
  chk_pl_group_id(p_pl_id            => p_rec.pl_id,
                   p_group_pl_id       => p_rec.group_pl_id,
                   p_pl_typ_id         => p_rec.pl_typ_id,
                   p_effective_date    => p_effective_date
                   ) ;
  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
    (p_rec              in ben_pln_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  if p_rec.business_group_id is not null and p_rec.legislation_code is null then
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  end if;
   --
  chk_pl_id
  (p_pl_id                     => p_rec.pl_id,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_plan_name_unique
  (p_pl_id                     => p_rec.pl_id,
   p_name                      => p_rec.name,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date         => p_validation_end_date);
  --
    chk_auto_enrt_and_mthd
   (p_pl_id               => p_rec.pl_id,
    p_effective_date      => p_effective_date,
    p_enrt_mthd_cd        => p_rec.enrt_mthd_cd,
    p_business_group_id   => p_rec.business_group_id);
  --
  --Bug 5710248
  chk_pl_typ_change
     (p_pl_id               => p_rec.pl_id,
      p_business_group_id   => p_rec.business_group_id,
      p_pl_typ_id           => p_rec.pl_typ_id,
      p_effective_date      => p_effective_date,
      p_object_version_number => p_rec.object_version_number);
  --Bug 5710248
  --Bug : 3475996
  chk_cwb_plan_type_uniq_plan(p_pl_id                 =>  p_rec.pl_id,
			      p_name                  =>  p_rec.name,
			      p_pl_typ_id             =>  p_rec.pl_typ_id,
			      p_group_pl_id           =>  p_rec.group_pl_id,
			      p_effective_date        =>  p_effective_date,
			      p_business_group_id     =>  p_rec.business_group_id,
			      p_object_version_number =>  p_rec.object_version_number,
			      p_validation_start_date =>  p_validation_start_date,
			      p_validation_end_date   =>  p_validation_end_date);
  --
  --iRec
  chk_irec_pln_in_rptg_grp
  (p_pl_id                     =>  p_rec.pl_id,
   p_pl_typ_id                 =>  p_rec.pl_typ_id,
   p_effective_date            =>  p_effective_date,
   p_validation_start_date     =>  p_validation_start_date,
   p_validation_end_date       =>  p_validation_end_date,
   p_business_group_id         =>  p_rec.business_group_id,
   p_object_version_number     =>  p_rec.object_version_number);
  --iRec
  --
  chk_measures_allowed
  (p_bnf_pct_amt_alwd_cd       => p_rec.bnf_pct_amt_alwd_cd,
   p_bnf_incrmt_amt            => p_rec.bnf_incrmt_amt,
   p_bnf_pct_incrmt_val        => p_rec.bnf_pct_incrmt_val,
   p_bnf_mn_dsgntbl_amt        => p_rec.bnf_mn_dsgntbl_amt);
  --
  chk_code_rule_dpnd
  (p_code                      => p_rec.mx_wtg_dt_to_use_cd,
   p_rule                      => p_rec.mx_wtg_dt_to_use_rl);
  --
  chk_mn_val_mn_flag_mn_rule
  (p_mn_cvg_rqd_amt            => p_rec.mn_cvg_rqd_amt,
   p_no_mn_cvg_amt_apls_flag   => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rl                 => p_rec.mn_cvg_rl);
  --
  chk_mx_val_mx_flag_mx_rule
  (p_mx_cvg_alwd_amt           => p_rec.mx_cvg_alwd_amt,
   p_no_mx_cvg_amt_apls_flag   => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_rl                 => p_rec.mx_cvg_rl);
  --
  chk_vrfy_fmly_mmbr_cd
  (p_pl_id                 => p_rec.pl_id,
   p_vrfy_fmly_mmbr_cd     => p_rec.vrfy_fmly_mmbr_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
 chk_use_csd_rsd_prccng_cd
  (p_pl_id                 => p_rec.pl_id,
   p_use_csd_rsd_prccng_cd => p_rec.use_csd_rsd_prccng_cd,
   p_effective_date        => p_effective_date,
   p_pl_cd                 => p_rec.pl_cd,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_vrfy_fmly_mmbr_rl
  (p_pl_id                 => p_rec.pl_id,
   p_vrfy_fmly_mmbr_rl     => p_rec.vrfy_fmly_mmbr_rl,
   p_business_group_id     => p_rec.business_group_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --

  chk_dpnt_dsgn_cd
  (p_dpnt_dsgn_cd        => p_rec.dpnt_dsgn_cd,
   p_dpnt_cvg_strt_dt_cd => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd  => p_rec.dpnt_cvg_end_dt_cd);
  --
  chk_dpnt_dsgn_cd_detail
     (p_pl_id  => p_rec.pl_id,
      p_dpnt_dsgn_cd => p_rec.dpnt_dsgn_cd,
      p_bnf_dsgn_cd => p_rec.bnf_dsgn_cd,
      p_business_group_id   => p_rec.business_group_id,
      p_effective_date => p_effective_date,
      p_validation_start_date => p_validation_start_date,
      p_validation_end_date => p_validation_end_date,
      p_object_version_number => p_rec.object_version_number);
  --
  chk_mutual_exclusive_flags
  (p_pl_id                     => p_rec.pl_id,
   p_invk_dcln_prtn_pl_flag    => p_rec.invk_dcln_prtn_pl_flag,
   p_invk_flx_cr_pl_flag       => p_rec.invk_flx_cr_pl_flag,
   p_svgs_pl_flag              => p_rec.svgs_pl_flag,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_mutual_exlsv_rule_num_uom
  (p_pl_id                     => p_rec.pl_id,
   p_mx_wtg_perd_rl            => p_rec.mx_wtg_perd_rl,
   p_mx_wtg_perd_prte_val      => p_rec.mx_wtg_perd_prte_val,
   p_mx_wtg_perd_prte_uom      => p_rec.mx_wtg_perd_prte_uom,
   p_effective_date            => p_effective_date,
   p_object_version_number     => p_rec.object_version_number);
  --
  chk_all_flags
  (p_pl_id                        => p_rec.pl_id,
   p_alws_qdro_flag               => p_rec.alws_qdro_flag,
   p_alws_qmcso_flag              => p_rec.alws_qmcso_flag,
   p_bnf_addl_instn_txt_alwd_flag => p_rec.bnf_addl_instn_txt_alwd_flag,
   p_bnf_adrs_rqd_flag            => p_rec.bnf_adrs_rqd_flag,
   p_bnf_cntngt_bnfs_alwd_flag    => p_rec.bnf_cntngt_bnfs_alwd_flag,
   p_bnf_ctfn_rqd_flag            => p_rec.bnf_ctfn_rqd_flag,
   p_bnf_dob_rqd_flag             => p_rec.bnf_dob_rqd_flag,
   p_bnf_dsge_mnr_ttee_rqd_flag   => p_rec.bnf_dsge_mnr_ttee_rqd_flag,
   p_bnf_legv_id_rqd_flag         => p_rec.bnf_legv_id_rqd_flag,
   p_bnf_may_dsgt_org_flag        => p_rec.bnf_may_dsgt_org_flag,
   p_bnf_qdro_rl_apls_flag        => p_rec.bnf_qdro_rl_apls_flag,
   p_drvbl_fctr_apls_rts_flag     => p_rec.drvbl_fctr_apls_rts_flag,
   p_drvbl_fctr_prtn_elig_flag    => p_rec.drvbl_fctr_prtn_elig_flag,
   p_elig_apls_flag               => p_rec.elig_apls_flag,
   p_invk_dcln_prtn_pl_flag       => p_rec.invk_dcln_prtn_pl_flag,
   p_invk_flx_cr_pl_flag          => p_rec.invk_flx_cr_pl_flag,
   p_drvbl_dpnt_elig_flag         => p_rec.drvbl_dpnt_elig_flag,
   p_trk_inelig_per_flag          => p_rec.trk_inelig_per_flag,
   p_dpnt_cvd_by_othr_apls_flag   => p_rec.dpnt_cvd_by_othr_apls_flag,
   p_frfs_aply_flag               => p_rec.frfs_aply_flag,
   p_hc_pl_subj_hcfa_aprvl_flag   => p_rec.hc_pl_subj_hcfa_aprvl_flag,
   p_hghly_cmpd_rl_apls_flag      => p_rec.hghly_cmpd_rl_apls_flag,
   p_no_mn_cvg_amt_apls_flag      => p_rec.no_mn_cvg_amt_apls_flag,
   p_no_mn_cvg_incr_apls_flag     => p_rec.no_mn_cvg_incr_apls_flag,
   p_no_mn_opts_num_apls_flag     => p_rec.no_mn_opts_num_apls_flag,
   p_no_mx_cvg_amt_apls_flag      => p_rec.no_mx_cvg_amt_apls_flag,
   p_no_mx_cvg_incr_apls_flag     => p_rec.no_mx_cvg_incr_apls_flag,
   p_no_mx_opts_num_apls_flag     => p_rec.no_mx_opts_num_apls_flag,
   p_prtn_elig_ovrid_alwd_flag    => p_rec.prtn_elig_ovrid_alwd_flag,
   p_subj_to_imptd_incm_typ_cd    => p_rec.subj_to_imptd_incm_typ_cd,
   p_use_all_asnts_elig_flag      => p_rec.use_all_asnts_elig_flag,
   p_use_all_asnts_for_rt_flag    => p_rec.use_all_asnts_for_rt_flag,
   p_vstg_apls_flag               => p_rec.vstg_apls_flag,
   p_wvbl_flag                    => p_rec.wvbl_flag,
   p_alws_reimbmts_flag           => p_rec.alws_reimbmts_flag,
   p_dpnt_adrs_rqd_flag           => p_rec.dpnt_adrs_rqd_flag,
   p_dpnt_dob_rqd_flag            => p_rec.dpnt_dob_rqd_flag,
   p_dpnt_leg_id_rqd_flag         => p_rec.dpnt_leg_id_rqd_flag,
   p_dpnt_no_ctfn_rqd_flag        => p_rec.dpnt_no_ctfn_rqd_flag,
   p_svgs_pl_flag                 => p_rec.svgs_pl_flag,
   p_enrt_pl_opt_flag             => p_rec.enrt_pl_opt_flag,
   p_MAY_ENRL_PL_N_OIPL_FLAG      => p_rec.MAY_ENRL_PL_N_OIPL_FLAG,
   p_ALWS_UNRSTRCTD_ENRT_FLAG     => p_rec.ALWS_UNRSTRCTD_ENRT_FLAG,
   p_ALWS_TMPRY_ID_CRD_FLAG     => p_rec.ALWS_TMPRY_ID_CRD_FLAG,
   p_nip_dflt_flag                => p_rec.nip_dflt_flag,
   p_post_to_gl_flag              => p_rec.post_to_gl_flag,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_all_lookups
  (p_pl_id                        => p_rec.pl_id,
   p_bnf_dflt_bnf_cd              => p_rec.bnf_dflt_bnf_cd,
   p_bnf_pct_amt_alwd_cd          => p_rec.bnf_pct_amt_alwd_cd,
   p_pl_cd                        => p_rec.pl_cd,
   p_cmpr_clms_to_cvg_or_bal_cd   => p_rec.cmpr_clms_to_cvg_or_bal_cd,
   p_enrt_mthd_cd                 => p_rec.enrt_mthd_cd,
   p_enrt_cd                      => p_rec.enrt_cd,
   p_mx_wtg_perd_prte_uom         => p_rec.mx_wtg_perd_prte_uom,
   p_nip_dflt_enrt_cd             => p_rec.nip_dflt_enrt_cd,
   p_nip_pl_uom                   => p_rec.nip_pl_uom,
   p_rqd_perd_enrt_nenrt_uom      => p_rec.rqd_perd_enrt_nenrt_uom,
   p_nip_acty_ref_perd_cd         => p_rec.nip_acty_ref_perd_cd,
   p_nip_enrt_info_rt_freq_cd     => p_rec.nip_enrt_info_rt_freq_cd,
   p_prort_prtl_yr_cvg_rstrn_cd   => p_rec.prort_prtl_yr_cvg_rstrn_cd,
   p_hc_svc_typ_cd                => p_rec.hc_svc_typ_cd,
   p_pl_stat_cd                   => p_rec.pl_stat_cd,
   p_prmry_fndg_mthd_cd           => p_rec.prmry_fndg_mthd_cd,
   p_bnf_dsgn_cd                  => p_rec.bnf_dsgn_cd,
   p_mx_wtg_dt_to_use_cd          => p_rec.mx_wtg_dt_to_use_cd,
   p_dflt_to_asn_pndg_ctfn_cd     => p_rec.dflt_to_asn_pndg_ctfn_cd,
   p_dpnt_dsgn_cd                 => p_rec.dpnt_dsgn_cd,
   p_enrt_cvg_strt_dt_cd          => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_end_dt_cd           => p_rec.enrt_cvg_end_dt_cd,
   p_dpnt_cvg_strt_dt_cd          => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_end_dt_cd           => p_rec.dpnt_cvg_end_dt_cd,
   p_per_cvrd_cd                  => p_rec.per_cvrd_cd,
   p_rt_end_dt_cd                 => p_rec.rt_end_dt_cd,
   p_rt_strt_dt_cd                => p_rec.rt_strt_dt_cd,
   p_BNFT_OR_OPTION_RSTRCTN_CD    => p_rec.BNFT_OR_OPTION_RSTRCTN_CD,
   p_CVG_INCR_R_DECR_ONLY_CD      => p_rec.CVG_INCR_R_DECR_ONLY_CD,
   p_unsspnd_enrt_cd              => p_rec.unsspnd_enrt_cd,
   p_imptd_incm_calc_cd           => p_rec.imptd_incm_calc_cd,
   p_effective_date               => p_effective_date,
   p_object_version_number        => p_rec.object_version_number);
  --
  chk_all_rules
  (p_pl_id                      => p_rec.pl_id,
   p_business_group_id          => p_rec.business_group_id,
   p_auto_enrt_mthd_rl          => p_rec.auto_enrt_mthd_rl,
   p_mn_cvg_rl                  => p_rec.mn_cvg_rl,
   p_mx_cvg_rl                  => p_rec.mx_cvg_rl,
   p_mx_wtg_perd_rl             => p_rec.mx_wtg_perd_rl,
   p_nip_dflt_enrt_det_rl       => p_rec.nip_dflt_enrt_det_rl,
   p_dpnt_cvg_end_dt_rl         => p_rec.dpnt_cvg_end_dt_rl ,
   p_dpnt_cvg_strt_dt_rl        => p_rec.dpnt_cvg_strt_dt_rl,
   p_prort_prtl_yr_cvg_rstrn_rl => p_rec.prort_prtl_yr_cvg_rstrn_rl,
   p_mx_wtg_dt_to_use_rl        => p_rec.mx_wtg_dt_to_use_rl,
   p_dflt_to_asn_pndg_ctfn_rl   => p_rec.dflt_to_asn_pndg_ctfn_rl,
   p_enrt_cvg_end_dt_rl         => p_rec.enrt_cvg_end_dt_rl,
   p_postelcn_edit_rl           => p_rec.postelcn_edit_rl,
   p_enrt_cvg_strt_dt_rl        => p_rec.enrt_cvg_strt_dt_rl,
   p_rt_end_dt_rl               => p_rec.rt_end_dt_rl,
   p_rt_strt_dt_rl              => p_rec.rt_strt_dt_rl,
   p_ENRT_RL                    => p_rec.ENRT_RL,
   p_rqd_perd_enrt_nenrt_rl     => p_rec.rqd_perd_enrt_nENRT_RL,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
--
chk_cd_rl_combination
(
   p_dpnt_cvg_end_dt_cd        => p_rec.dpnt_cvg_end_dt_cd,
   p_dpnt_cvg_end_dt_rl        => p_rec.dpnt_cvg_end_dt_rl,
   p_vrfy_fmly_mmbr_cd         => p_rec.vrfy_fmly_mmbr_cd,
   p_vrfy_fmly_mmbr_rl         => p_rec.vrfy_fmly_mmbr_rl,
   p_dpnt_cvg_strt_dt_cd       => p_rec.dpnt_cvg_strt_dt_cd,
   p_dpnt_cvg_strt_dt_rl       => p_rec.dpnt_cvg_strt_dt_rl,
   p_enrt_cvg_end_dt_cd        => p_rec.enrt_cvg_end_dt_cd,
   p_enrt_cvg_end_dt_rl        => p_rec.enrt_cvg_end_dt_rl,
   p_enrt_cvg_strt_dt_cd       => p_rec.enrt_cvg_strt_dt_cd,
   p_enrt_cvg_strt_dt_rl       => p_rec.enrt_cvg_strt_dt_rl,
   p_rt_strt_dt_cd             => p_rec.rt_strt_dt_cd,
   p_rt_strt_dt_rl             => p_rec.rt_strt_dt_rl,
   p_rt_end_dt_cd              => p_rec.rt_end_dt_cd,
   p_rt_end_dt_rl              => p_rec.rt_end_dt_rl
);

--
  chk_all_no_amount_flags
  (p_no_mn_cvg_amt_apls_flag    => p_rec.no_mn_cvg_amt_apls_flag,
   p_mn_cvg_rqd_amt             => p_rec.mn_cvg_rqd_amt,
   p_no_mx_cvg_amt_apls_flag    => p_rec.no_mx_cvg_amt_apls_flag,
   p_mx_cvg_alwd_amt            => p_rec.mx_cvg_alwd_amt);
  --
  chk_mn_val_mx_val
  (p_mn_val                     => p_rec.mn_cvg_rqd_amt,
   p_mx_val                     => p_rec.mx_cvg_alwd_amt);
  --
  chk_plan_oipl_mutexcl
  (p_pl_id                     => p_rec.pl_id,
   p_actl_prem_id              => p_rec.actl_prem_id,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id,
   p_object_version_number     => p_rec.object_version_number);
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_auto_enrt_mthd_rl             => p_rec.auto_enrt_mthd_rl,
     p_mn_cvg_rl                     => p_rec.mn_cvg_rl,
     p_mx_cvg_rl                     => p_rec.mx_cvg_rl,
     p_mx_wtg_perd_rl                => p_rec.mx_wtg_perd_rl,
     p_nip_dflt_enrt_det_rl          => p_rec.nip_dflt_enrt_det_rl,
     p_prort_prtl_yr_cvg_rstrn_rl    => p_rec.prort_prtl_yr_cvg_rstrn_rl,
     p_pl_typ_id                     => p_rec.pl_typ_id,
     p_actl_prem_id                  => p_rec.actl_prem_id,
     p_mx_wtg_dt_to_use_rl           => p_rec.mx_wtg_dt_to_use_rl,
     p_dflt_to_asn_pndg_ctfn_rl      => p_rec.dflt_to_asn_pndg_ctfn_rl,
     p_dpnt_cvg_end_dt_rl            => p_rec.dpnt_cvg_end_dt_rl,
     p_dpnt_cvg_strt_dt_rl           => p_rec.dpnt_cvg_strt_dt_rl,
     p_enrt_cvg_end_dt_rl            => p_rec.enrt_cvg_end_dt_rl,
     p_enrt_cvg_strt_dt_rl           => p_rec.enrt_cvg_strt_dt_rl,
     p_postelcn_edit_rl              => p_rec.postelcn_edit_rl,
     p_rt_end_dt_rl                  => p_rec.rt_end_dt_rl,
     p_rt_strt_dt_rl                 => p_rec.rt_strt_dt_rl,
     p_ENRT_RL                       => p_rec.enrt_rl,
     p_rqd_perd_enrt_nenrt_rl        => p_rec.rqd_perd_enrt_nenrt_rl,
     p_datetrack_mode                => p_datetrack_mode,
     p_validation_start_date         => p_validation_start_date,
     p_validation_end_date           => p_validation_end_date);
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mn_opts_num_apls_flag,
   p_val    => p_rec.mn_opts_rqd_num,
   p_msg    => 'BEN_91695_MIN_VAL_FLAG_EXCLSV');
  --
  chk_flag_and_val
  (p_flag   => p_rec.no_mx_opts_num_apls_flag,
   p_val    => p_rec.mx_opts_alwd_num,
   p_msg    => 'BEN_91696_MAX_VAL_FLAG_EXCLSV');
  --
  chk_nip_pln_uom         -- Added for Bug 2447647
  (p_pl_typ_id                 => p_rec.pl_typ_id,
   p_pl_cd                     => p_rec.pl_cd,
   p_nip_pl_uom                => p_rec.nip_pl_uom,
   p_effective_date            => p_effective_date,
   p_business_group_id         => p_rec.business_group_id);
  --
  /*
  --Bug 3460429
  chk_pl_group_id(p_pl_id            => p_rec.pl_id,
                  p_group_pl_id       => p_rec.group_pl_id,
		  p_pl_typ_id         => p_rec.pl_typ_id,
		  p_effective_date    => p_effective_date
                  ) ;
  --Bug 3460429
  */
  --
  --  Bug No: 3876692
  --
  chk_prfl_rule_extnce
  (p_pl_id                     =>  p_rec.pl_id,
   p_imptd_incm_calc_cd        =>  p_rec.imptd_incm_calc_cd,
   p_invk_flx_cr_pl_flag       =>  p_rec.invk_flx_cr_pl_flag,
   p_effective_date            =>  p_effective_date,
   p_object_version_number     =>  p_rec.object_version_number,
   p_validation_start_date     => p_validation_start_date,
   p_validation_end_date       => p_validation_end_date);
  --
  chk_compare_claims_cd (p_pl_id       => p_rec.pl_id,
                         p_effective_date =>  p_effective_date,
                         p_business_group_id => p_rec.business_group_id,
                         p_cmpr_clms_to_cvg_or_bal_cd => p_rec.cmpr_clms_to_cvg_or_bal_cd,
                         p_object_version_number =>  p_rec.object_version_number);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
    (p_rec              in ben_pln_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'delete_validate';
   --
   -- Bug 4057566
   --
   CURSOR c_plan_name
   IS
      SELECT pln.NAME
        FROM ben_pl_f pln
       WHERE pln.pl_id = p_rec.pl_id
         AND p_validation_start_date BETWEEN pln.effective_start_date
                                         AND pln.effective_end_date;
  --
  l_plan_name       varchar2(240);
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Bug 4057566
  --
  open c_plan_name;
    --
    fetch c_plan_name into l_plan_name;
    --
  close c_plan_name;
  --
  -- Call all supporting business operations
  --

  chk_pl_group_child(p_pl_id          => p_rec.pl_id ,
                     p_opt_typ_cd     => null ,
                     p_effective_date => p_effective_date,
                     p_name           => l_plan_name) ;

  dt_delete_validate
    (p_datetrack_mode           => p_datetrack_mode,
     p_validation_start_date    => p_validation_start_date,
     p_validation_end_date      => p_validation_end_date,
     p_pl_id                    => p_rec.pl_id,
     p_name                     => l_plan_name     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--


--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_pl_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_pl_f b
    where b.pl_id      = p_pl_id
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
                             p_argument       => 'pl_id',
                             p_argument_value => p_pl_id);
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
end ben_pln_bus;

/
