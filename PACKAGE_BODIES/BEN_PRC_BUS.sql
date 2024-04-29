--------------------------------------------------------
--  DDL for Package Body BEN_PRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRC_BUS" as
/* $Header: beprcrhi.pkb 120.7.12010000.2 2008/08/05 15:19:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prc_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_reimbmt_rqst_id >------|
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
--   prtt_reimbmt_rqst_id PK of record being inserted or updated.
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
Procedure chk_prtt_reimbmt_rqst_id
             (p_prtt_reimbmt_rqst_id    in number,
              p_effective_date          in date,
              p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_reimbmt_rqst_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prc_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_prtt_reimbmt_rqst_id                => p_prtt_reimbmt_rqst_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_prtt_reimbmt_rqst_id,hr_api.g_number)
     <>  ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_id) then
    --
    -- raise error as PK has changed
    --
    ben_prc_shd.constraint_error('BEN_PRTT_REIMBMT_RQST_F_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_prtt_reimbmt_rqst_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_prc_shd.constraint_error('BEN_PRTT_REIMBMT_RQST_F_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_prtt_reimbmt_rqst_id;
--

function get_year_balance (
              p_person_id            in   number
             ,p_pgm_id               in   number
             ,p_pl_id                in   number
             ,p_business_group_id    in   number
             ,p_per_in_ler_id        in   number
             ,p_prtt_enrt_rslt_id    in   number
             ,p_effective_date       in   date
             -- ,p_incrd_from_dt        in   date -- 2272862
             ,p_exp_incurd_dt        in   date
              ) return number is



  cursor get_epe is
   select pil.lf_evt_ocrd_dt,
          epe.pgm_id,
          epe.pl_id,
          epe.oipl_id,
          epe.per_in_ler_id,
          epe.yr_perd_id,
          pel.enrt_perd_id,
          pel.lee_rsn_id,
          pil.business_group_id
   from   ben_elig_per_elctbl_chc epe,
          ben_pil_elctbl_chc_popl pel,
          ben_per_in_ler          pil
   where  pil.per_in_ler_id          = p_per_in_ler_id
   and    pil.business_group_id      = p_business_group_id
   and    epe.per_in_ler_id          = pil.per_in_ler_id
   and    epe.pgm_id                 = p_pgm_id
   and    epe.pl_id                  = p_pl_id
   and    epe.per_in_ler_id          = p_per_in_ler_id
   and    epe.pil_elctbl_chc_popl_id = pel.pil_elctbl_chc_popl_id ;

  --
  l_get_epe get_epe%rowtype;
  --
  cursor c_yrp is
     select yrp.start_date , yrp.end_date
     from   ben_yr_perd yrp
     where  yrp.yr_perd_id        = l_get_epe.yr_perd_id
     and    yrp.business_group_id = p_business_group_id;
  --
   cursor c_prv is
      select acty_base_rt_id
      from ben_prtt_rt_val
      where prtt_enrt_rslt_id   = p_prtt_enrt_rslt_id
      and prtt_reimbmt_rqst_id is null ;

   l_acty_base_rt_id   ben_acty_base_rt_f.acty_base_rt_id%type ;
  --
   cursor c_abr_name is
      select name
      from ben_acty_base_rt_f
      where acty_base_rt_id = l_acty_base_rt_id
        and p_effective_date between effective_start_date and effective_end_date ;
   l_abr_name   ben_acty_base_rt_f.name%type ;
  --
     cursor abr_balance is
     select abr.ptd_comp_lvl_fctr_id,
            abr.clm_comp_lvl_fctr_id,
            abr.det_pl_ytd_cntrs_cd,
            abr.acty_base_rt_id
     from   ben_acty_base_rt_f abr
     where  acty_base_rt_id  = l_acty_base_rt_id
      and   p_effective_date between
         abr.effective_start_date and
         abr.effective_end_date;

  --
  --
  cursor c_abr_prv is
     select distinct prv.acty_base_rt_id prv_rate,
            abr.name abr_name,
            clf.*
     from ben_prtt_rt_val prv,
          ben_acty_base_rt_f abr,
          ben_comp_lvl_fctr clf
     where prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
       and prv.acty_base_rt_id   = abr.acty_base_rt_id
       and abr.acty_typ_cd not like 'PRD%'
       and abr.acty_typ_cd <>  'PRFRFS'
       and abr.ttl_comp_lvl_fctr_id = clf.comp_lvl_fctr_id (+)
       and prv.prtt_rt_val_stat_cd is null
       -- and p_incrd_from_dt between --2272862
       -- and  p_exp_incurd_dt between
       --      prv.rt_strt_dt and prv.rt_end_dt
       and p_effective_date between
           abr.effective_start_date and abr.effective_end_date;
  --
  cursor c_asg(p_assignment_type varchar2,p_person_id number ) is
    select paf.assignment_id
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type <> 'C'
    and    paf.assignment_type = p_assignment_type
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  --
  cursor c_yr_perd is
    select yrp.end_date
    from ben_yr_perd yrp,
         ben_popl_yr_perd cyp
    where yrp.yr_perd_id = cyp.yr_perd_id
    -- and   p_incrd_from_dt between yrp.start_date and yrp.end_date -- 2278262
    and   p_exp_incurd_dt between yrp.start_date and yrp.end_date
    and   cyp.pl_id = p_pl_id;
  --
   cursor c_bnft_bal(p_bnfts_bal_id number, p_person_id number) is
    select bnb.val
    from   ben_per_bnfts_bal_f bnb
    where  bnb.bnfts_bal_id = p_bnfts_bal_id
    and    bnb.person_id    = p_person_id
    and    bnb.business_group_id  = p_business_group_id
    and    p_effective_date
           between bnb.effective_start_date
           and     bnb.effective_end_date;
  --
  l_abr_prv         c_abr_prv%rowtype;
  l_abr_balance     abr_balance%rowtype;
  l_proc            varchar2(100) :=  'get_year_balance' ;
  l_ptd_balance     ben_prtt_reimbmt_rqst_f.rqst_amt%type ;
  l_yr_start_date   date;
  l_yr_end_date     date;
  l_assignment_id   number;
  l_assignment_action_id number;
begin
  hr_utility.set_location('Entering:'||l_proc,5);
  hr_utility.set_location ('Effective  date'||p_effective_date,111);
  l_assignment_id := null;
  open c_asg('E',p_person_id );
  fetch c_asg into l_assignment_id;
  close c_asg;
  IF l_assignment_id IS NULL THEN
   --
    hr_utility.set_location (' employee failed   ' || l_assignment_id , 30) ;
    open c_asg('B',p_person_id);
    fetch c_asg into l_assignment_id;
    close c_asg;
   --
   -- 9999 Error out if assignment is not found for person.
   --
  END IF;
  --
  open  c_yr_perd;
  fetch c_yr_perd into l_yr_end_date;
  close c_yr_perd;
  --
  open c_abr_prv;
  fetch c_abr_prv into l_abr_prv;
  close c_abr_prv;

  hr_utility.set_location(' result id  ' || p_prtt_enrt_rslt_id ,293);
  hr_utility.set_location(' acty_base_rt ' || l_acty_base_rt_id,293);
  hr_utility.set_location(' ytd cntr cd ' || l_abr_balance.det_pl_ytd_cntrs_cd,293);
  hr_utility.set_location(' ptd level  ' || l_abr_balance.ptd_comp_lvl_fctr_id,293);
  hr_utility.set_location(' acty_base_rt ' || l_abr_balance.acty_base_rt_id,293);
  hr_utility.set_location(' p_effective_date ' || p_effective_date ,293);
  hr_utility.set_location(' yr_perd_id ' || l_get_epe.yr_perd_id ,293);
  hr_utility.set_location(' bnfts_bal_id ' || l_abr_prv.bnfts_bal_id ,293);
  hr_utility.set_location(' bnfts_bal_id ' || l_abr_prv.bnfts_bal_id ,293);
  hr_utility.set_location(' person_id  ' || p_person_id ,293);

  if l_abr_prv.comp_src_cd is not null then
     --
     if l_abr_prv.comp_src_cd =  'BALTYP' THEN

        ben_derive_part_and_rate_facts.set_taxunit_context
        (p_person_id           => p_person_id
        ,p_business_group_id   => p_business_group_id
        ,p_effective_date      => least(p_effective_date,l_yr_end_date)
        ) ;
        --
        -- Bug 3818453. Pass assignment_action_id to get_value() to
        -- improve performance
        --
        l_assignment_action_id :=
                          ben_derive_part_and_rate_facts.get_latest_paa_id
                          (p_person_id         => p_person_id
                          ,p_business_group_id => p_business_group_id
                          ,p_effective_date    => least(p_effective_date,l_yr_end_date));

        if l_assignment_action_id is not null then
           --
           begin
              l_ptd_balance  :=
              pay_balance_pkg.get_value(l_abr_prv.defined_balance_id
              ,l_assignment_action_id);
           exception
             when others then
             l_ptd_balance := null ;
           end ;
           --
          --
        end if ;
        --
        -- old code prior to 3818453
        --
/*
        l_ptd_balance  :=
                       pay_balance_pkg.get_value(l_abr_prv.defined_balance_id
                      ,l_assignment_id
                      ,least(p_effective_date,l_yr_end_date));
*/
     elsif l_abr_prv.comp_src_cd = 'BNFTBALTYP' then
         hr_utility.set_location(' bnfts_bal_id ' || l_abr_prv.bnfts_bal_id ,293);
         hr_utility.set_location(' person_id  ' || p_person_id ,293);
        open c_bnft_bal(l_abr_prv.bnfts_bal_id, p_person_id);
        fetch c_bnft_bal into l_ptd_balance;
        close c_bnft_bal;
     end if;
     --
  else
    fnd_message.set_name('BEN', 'BEN_92668_CONTR_BAL_NOT_EXIST');
    fnd_message.set_token('STD_RATE_NAME ', l_abr_prv.name);
    fnd_message.raise_error;

  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
  hr_utility.set_location('ptd_balance '||l_ptd_balance , 293);
  return nvl(l_ptd_balance,0);
end get_year_balance ;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< plan_year_claim >---------------------------|
-- this finction to calcualte the reimbursement for the plan year
-- ----------------------------------------------------------------------------
Procedure plan_year_claim(
          p_pl_id                 in number
         ,p_person_id             in number
         ,p_business_group_id     in number
         ,p_prtt_reimbmt_rqst_id  in number
         ,p_effective_date        in date
         ,p_exp_incurd_dt         in date
         ,p_popl_yr_perd_id_1     in number
         ,p_popl_yr_perd_id_2     in number
         ,p_amt_1                 out nocopy  number
         ,p_amt_2                 out nocopy number
         ) is
-- future created entry to be  taken for calc so p_effective_Date is not validated with
-- start date and end date   . thi may lead into a problem of entry is date tracked
-- curent entry is not taken for calc tath is added in calling proc this helps while updating
/*cursor c1 is select sum(nvl(prc.aprvd_for_pymt_amt,0))
                from   ben_prtt_reimbmt_rqst_f prc,
                       ben_pl_f pl,
                       ben_popl_yr_perd pyr,
                       ben_yr_perd yr
                where  prc.submitter_person_id = p_person_id
                and    prc.prtt_reimbmt_rqst_stat_cd not in ('DND','VOIDED','DPLICT')
                and    pl.pl_id                = p_pl_id
                and    pl.pl_id                = prc.pl_id
                and    p_effective_date between  pl.effective_start_date and pl.effective_end_date
                and    prc.effective_end_date  = hr_api.g_eot --future created entry to be  taken for calc
                and    (p_prtt_reimbmt_rqst_id    is null
                       or prc.prtt_reimbmt_rqst_id <> p_prtt_reimbmt_rqst_id)
                and    pl.pl_id                = pyr.pl_id
                and    pyr.yr_perd_id          = yr.yr_perd_id
                -- if the reimp belong to the current year then  the
                -- both condition has to match
                and    p_exp_incurd_dt  between yr.start_date and yr.end_date
                and    prc.exp_incurd_dt  between yr.start_date and yr.end_date
                -- and    p_incrd_from_dt  between yr.start_date and yr.end_date -- 2272862
                -- and    prc.incrd_from_dt  between yr.start_date and yr.end_date
                and    prc.business_group_id  = p_business_group_id
                and    pl.business_group_id   = p_business_group_id
                and    pyr.business_group_id  = p_business_group_id
                and    yr.business_group_id   = p_business_group_id;
*/
 cursor c_year_claim_amt1 (p_popl_yr_perd number) is
   select sum(nvl(prc.amt_year1,0))
   from   ben_prtt_reimbmt_rqst_f prc
   where  prc.submitter_person_id = p_person_id
   and    prc.prtt_reimbmt_rqst_stat_cd not in ('DND','VOIDED','DPLICT')
   and    prc.pl_id = p_pl_id
   and    prc.effective_end_date  = hr_api.g_eot
   and    (p_prtt_reimbmt_rqst_id    is null
                       or prc.prtt_reimbmt_rqst_id <> p_prtt_reimbmt_rqst_id)
   and   prc.popl_yr_perd_id_1 = p_popl_yr_perd;
  --
  cursor c_year_claim_amt2 (p_popl_yr_perd number) is
   select sum(nvl(prc.amt_year2,0))  --+ sum(nvl(prc.amt_year2,0))
   from   ben_prtt_reimbmt_rqst_f prc
   where  prc.submitter_person_id = p_person_id
   and    prc.prtt_reimbmt_rqst_stat_cd not in ('DND','VOIDED','DPLICT')
   and    prc.pl_id = p_pl_id
   and    prc.effective_end_date  = hr_api.g_eot
   and    (p_prtt_reimbmt_rqst_id    is null
                       or prc.prtt_reimbmt_rqst_id <> p_prtt_reimbmt_rqst_id)
   and   prc.popl_yr_perd_id_2 = p_popl_yr_perd;


 l_year_bal    ben_prtt_reimbmt_rqst_f.rqst_amt%type ;
 l_proc         varchar2(100) := ' plan_year_claim' ;


begin
  hr_utility.set_location('Entering:'||l_proc,5);
/*
  hr_utility.set_location('pl'     ||p_pl_id ,5);
  hr_utility.set_location('reimbq '||p_prtt_reimbmt_rqst_id ,5);
  hr_utility.set_location('person '||p_person_id ,5);
  hr_utility.set_location('b group'||p_business_group_id ,5);
  hr_utility.set_location('eff dt '||p_effective_date ,5);
  open  c1;
  fetch c1 into l_year_bal ;
  close c1 ;
  */
  l_year_bal := 0;
  open c_year_claim_amt1 (p_popl_yr_perd_id_1);
  fetch c_year_claim_amt1 into l_year_bal;
  close c_year_claim_amt1;
  p_amt_1 := nvl(l_year_bal,0);
  --
  open c_year_claim_amt2 (p_popl_yr_perd_id_1);
  fetch c_year_claim_amt2 into l_year_bal;
  close c_year_claim_amt2;
  p_amt_1 := p_amt_1 + nvl(l_year_bal,0);

  l_year_bal := 0;
  --
  if p_popl_yr_perd_id_2 is not null then
    --
    open c_year_claim_amt1 (p_popl_yr_perd_id_2);
    fetch c_year_claim_amt1 into l_year_bal;
    close c_year_claim_amt1;
    --
    p_amt_2 := nvl(l_year_bal,0);
    --
    open c_year_claim_amt2 (p_popl_yr_perd_id_2);
    fetch c_year_claim_amt2 into l_year_bal;
    close c_year_claim_amt2;
    --
    p_amt_2 := p_amt_2 + nvl(l_year_bal,0);
    --
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 10);
end   plan_year_claim ;

--
-- ----------------------------------------------------------------------------
-- |------< chk_gd_or_svc_typ_id >------|
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
--   p_prtt_reimbmt_rqst_id PK
--   p_gd_or_svc_typ_id ID of FK column
--   p_effective_date session date
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
Procedure chk_gd_or_svc_typ_id (p_prtt_reimbmt_rqst_id          in number,
                            p_gd_or_svc_typ_id          in number,
                            p_effective_date        in date,
                            p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_gd_or_svc_typ_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_gd_or_svc_typ a
    where  a.gd_or_svc_typ_id = p_gd_or_svc_typ_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prc_shd.api_updating
     (p_prtt_reimbmt_rqst_id            => p_prtt_reimbmt_rqst_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_gd_or_svc_typ_id,hr_api.g_number)
     <> nvl(ben_prc_shd.g_old_rec.gd_or_svc_typ_id,hr_api.g_number)
     or not l_api_updating) and
     p_gd_or_svc_typ_id is not null then
    --
    -- check if gd_or_svc_typ_id value exists in ben_gd_or_svc_typ table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_gd_or_svc_typ
        -- table.
        --
        ben_prc_shd.constraint_error('BEN_PRTT_REIMBMT_RQST_F_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_gd_or_svc_typ_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_provider_person_id >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that a referenced foreign key actually exists
--   in the referenced table.
--   The Provider Person Id can be either a person in PER_ALL_PEOPLE_F
--   or an Org Unit ifrom HR_ALL_ORGANIZATION_UNITS.  both places must
--   be checked.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtt_reimbmt_rqst_id PK
--   p_provider_person_id ID of FK column
--   p_effective_date session date
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
Procedure chk_provider_person_id
          (p_prtt_reimbmt_rqst_id  in number,
           p_provider_person_id    in number,
           p_effective_date        in date,
           p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_provider_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   hr_all_organization_units a
    where  a.organization_id = p_provider_person_id;
  --
  cursor c2 is
    select null
    from   per_all_people_f
    where  person_id = p_provider_person_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prc_shd.api_updating
     (p_prtt_reimbmt_rqst_id    => p_prtt_reimbmt_rqst_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_provider_person_id,hr_api.g_number)
     <> nvl(ben_prc_shd.g_old_rec.provider_person_id,hr_api.g_number)
     or not l_api_updating) and
     p_provider_person_id is not null then
    --
    -- check if provider_person_id value exists in hr_all_organization_units table
    --
    open c1;
    fetch c1 into l_dummy;
    if c1%notfound then
        --
        -- not exist in HR_ALL_ORGANIZATION_UNITS so will check PER_ALL_PEOPLE_F
        --
        open c2;
        fetch c2 into l_dummy;
        if c2%notfound then
            --
            close c1;
            close c2;
            --
            -- raise error as FK does not relate to PK in hr_all_organization_units
            -- table or PER_ALL_PEOPLE_F table.
            --
            ben_prc_shd.constraint_error('BEN_PRTT_REIMBMT_RQST_F_DT6');
            --
        end if;
          --
        close c2;
        --
    end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_provider_person_id;
--
-- ----------------------------------------------------------------------------
-- |------< chk_rcrrg_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_reimbmt_rqst_id PK of record being inserted or updated.
--   rcrrg_cd Value of lookup code.
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
Procedure chk_rcrrg_cd(p_prtt_reimbmt_rqst_id                in number,
                            p_rcrrg_cd               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_rcrrg_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id                => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_rcrrg_cd
      <> nvl(ben_prc_shd.g_old_rec.rcrrg_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rcrrg_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REIMBMT_RQST_RCRG',
           p_lookup_code    => p_rcrrg_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rcrrg_cd');
      fnd_message.set_token('VALUE', p_rcrrg_cd);
      fnd_message.set_token('TYPE','BEN_REIMBMT_RQST_RCRG');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_rcrrg_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_reimbmt_ctfn_typ_prvdd_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_reimbmt_rqst_id PK of record being inserted or updated.
--   reimbmt_ctfn_typ_prvdd_cd Value of lookup code.
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
Procedure chk_reimbmt_ctfn_typ_prvdd_cd
             (p_prtt_reimbmt_rqst_id        in number,
              p_reimbmt_ctfn_typ_prvdd_cd   in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_reimbmt_ctfn_typ_prvdd_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id        => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_reimbmt_ctfn_typ_prvdd_cd
      <> nvl(ben_prc_shd.g_old_rec.reimbmt_ctfn_typ_prvdd_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_reimbmt_ctfn_typ_prvdd_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_RMBMT_CTFN_TYP',
           p_lookup_code    => p_reimbmt_ctfn_typ_prvdd_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_reimbmt_ctfn_typ_prvdd_cd');
      fnd_message.set_token('VALUE', p_reimbmt_ctfn_typ_prvdd_cd);
      fnd_message.set_token('TYPE','BEN_RMBMT_CTFN_TYP');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_reimbmt_ctfn_typ_prvdd_cd;



-- ----------------------------------------------------------------------------
-- |------< chk_prtt_reimbmt_stat_apprvd >------|
-- ----------------------------------------------------------------------------

Procedure chk_prtt_reimbmt_stat_apprvd
             (p_prtt_reimbmt_rqst_id        in number,
              p_aprvd_for_pymt_amt          in number ,
              p_prtt_reimbmt_rqst_stat_cd   in out nocopy  varchar2,
              p_stat_rsn_cd                 in out nocopy  varchar2,
              p_effective_date              in date
             ) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_reimbmt_stat_apprvd';
  l_api_updating boolean;

  cursor c_pcg is
   select 'x' from
   ben_prtt_clm_gd_or_svc_typ pcg
   where prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id  ;
  --
  l_ctfn_pending_flag varchar2(1) ;
  l_dummy_var varchar2(1) ;
Begin

 hr_utility.set_location('Entering:'||l_proc, 5);

 if p_prtt_reimbmt_rqst_stat_cd  in ('APPRVD','PDINFL','PRTLYPD')  then

   -- Check the approved amount is entered
   if nvl(p_aprvd_for_pymt_amt,0) = 0   then
      fnd_message.set_name('BEN','BEN_92715_APRVD_AMT_IS_NULL');
      fnd_message.raise_error ;
   end if ;

   -- Check the goods/service are defiend if not
   -- changes the status to pending
   open c_pcg ;
   fetch c_pcg into l_dummy_var ;
   close c_pcg ;

   if l_dummy_var is null  then
      p_prtt_reimbmt_rqst_stat_cd := 'PNDNG' ;
      p_stat_rsn_cd  :=  'RMBGRVREQ' ;
   else

      ----Certification is required validate
      ben_PRTT_CLM_GD_R_SVC_TYP_api.check_remb_rqst_ctfn_prvdd
        (p_prtt_reimbmt_rqst_id        => p_prtt_reimbmt_rqst_id
        ,p_effective_date              => p_effective_date
        ,p_ctfn_pending_flag           => l_ctfn_pending_flag ) ;

      if l_ctfn_pending_flag = 'Y' then
           --fnd_message.set_name('BEN','BEN_92706_REIMB_CTFN_NOT_PRVDD');
           --fnd_message.show ;
           p_prtt_reimbmt_rqst_stat_cd := 'PNDNG' ;
           p_stat_rsn_cd  :=  'RMBCTFNRQD' ;
       end if ;
    end if ;


 end if ;
 --
 hr_utility.set_location('Leaving:'||l_proc,10);
 --

end chk_prtt_reimbmt_stat_apprvd ;
--


--
-- ----------------------------------------------------------------------------
-- |------< chk_stat_rsn_cd >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_stat_rsn_cd
             (p_prtt_reimbmt_rqst_id        in number,
              p_stat_rsn_cd                 in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_stat_rsn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_stat_rsn_cd
     <> nvl(ben_prc_shd.g_old_rec.stat_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_stat_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_STAT_RSN',
           p_lookup_code    => p_stat_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_stat_rsn_cd');
      fnd_message.set_token('VALUE', p_stat_rsn_cd);
      fnd_message.set_token('TYPE','BEN_STAT_RSN');
      fnd_message.raise_error;
      --
    end if;

    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_stat_rsn_cd;



-- ----------------------------------------------------------------------------
-- |------< chk_pymt_stat_rsn_cd >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_pymt_stat_rsn_cd
             (p_prtt_reimbmt_rqst_id        in number,
              p_pymt_stat_rsn_cd            in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_stat_rsn_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pymt_stat_rsn_cd
     <> nvl(ben_prc_shd.g_old_rec.pymt_stat_rsn_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pymt_stat_rsn_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PYMT_STAT_RSN',
           p_lookup_code    => p_pymt_stat_rsn_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
     --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pymt_stat_rsn_cd');
      fnd_message.set_token('VALUE', p_pymt_stat_rsn_cd);
      fnd_message.set_token('TYPE','BEN_PYMT_STAT_RSN');
      fnd_message.raise_error;
      --
    end if;

    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pymt_stat_rsn_cd;


-- ----------------------------------------------------------------------------
-- |------< chk_pymt_stat_cd >------|
-- ----------------------------------------------------------------------------
--
Procedure chk_pymt_stat_cd
             (p_prtt_reimbmt_rqst_id        in number,
              p_pymt_stat_cd            in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_pymt_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_pymt_stat_cd
     <> nvl(ben_prc_shd.g_old_rec.pymt_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_pymt_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_PYMT_STAT',
           p_lookup_code    => p_pymt_stat_cd,
           p_effective_date => p_effective_date) then
      --
     -- raise error as does not exist as lookup
     --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_pymt_stat_cd');
      fnd_message.set_token('VALUE', p_pymt_stat_cd);
      fnd_message.set_token('TYPE','BEN_PYMT_STAT');
      fnd_message.raise_error;
      --
    end if;

    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_pymt_stat_cd;


--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_reimbmt_rqst_stat_cd >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_reimbmt_rqst_id PK of record being inserted or updated.
--   prtt_reimbmt_rqst_stat_cd Value of lookup code.
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
Procedure chk_prtt_reimbmt_rqst_stat_cd
             (p_prtt_reimbmt_rqst_id        in number,
              p_prtt_reimbmt_rqst_stat_cd   in varchar2,
              p_effective_date              in date,
              p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_reimbmt_rqst_stat_cd';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id       => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

  ----If the Status is Approved or VOID dont allow to changed
  --- This has to be REMOVED or UPDATED whne the status logic change

  -- hnarayan -- bug fix 2223214
  -- before this, no updates where allowed on a claim record once the
  -- status is approved.
  -- Now, there can be a change from any of the approved status to a non-approved status
  -- But change is not allowed between the three approved statuses once the claim is approved.
  --
  -- Now we should throw error only if user tries to change from one Approved status to another
  -- Approved status. Hence modified the if condn below.
  --
  if l_api_updating -- added l_api_updating to perform the check only when updating
  	and ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd in  ('APPRVD','PDINFL','PRTLYPD')
     	and p_prtt_reimbmt_rqst_stat_cd	in ('APPRVD','PDINFL','PRTLYPD')  then
    --
    fnd_message.set_name('BEN','BEN_92705_REIMB_RQST_APPROVD');
    fnd_message.raise_error;
    --
  end if ;

  -- hnarayan -- bug fix 2223214
  -- i am not changing the logic for update of Voided claims
  -- since it makes more sense for a voided claim to be just present for
  -- information sake and not for processing
  -- But, since no payment is made for a voided claim,
  -- presence of voided claims shud not prevent back-out of a life event.
  --
  ----Once voiced rquest is not allowd to be cahnged
  if l_api_updating and ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd = 'VOIDED' then
     fnd_message.set_name('BEN','BEN_92708_REIMB_RQST_VOIDED');
     fnd_message.raise_error;
  end if ;

  if (l_api_updating
      and p_prtt_reimbmt_rqst_stat_cd
      <> nvl(ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd,hr_api.g_varchar2)
      or not l_api_updating)
      and p_prtt_reimbmt_rqst_stat_cd is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'BEN_REIMBMT_RQST_STAT',
           p_lookup_code    => p_prtt_reimbmt_rqst_stat_cd,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_prtt_reimbmt_rqst_stat_cd');
      fnd_message.set_token('VALUE', p_prtt_reimbmt_rqst_stat_cd);
      fnd_message.set_token('TYPE','BEN_REIMBMT_RQST_STAT');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_prtt_reimbmt_rqst_stat_cd;
--
-- ----------------------------------------------------------------------------
-- |------< chk_pl_id_rqst_amt_and_uom >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_reimbmt_rqst_id PK of record being inserted or updated.
--   rqst_amt_uom Value of lookup code.
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
Procedure chk_pl_id_rqst_amt_and_uom(p_prtt_reimbmt_rqst_id     in number,
                            p_rqst_amt_uom                in varchar2,
                            p_rqst_amt                    in number,
                            p_pl_id                       in number,
                            p_submitter_person_id         in number,
                            p_business_group_id           in number,
                            p_effective_date              in date,
                            p_object_version_number       in number,
                            p_prtt_enrt_rslt_id           in number,
                            p_prtt_reimbmt_rqst_stat_cd   in out nocopy varchar2,
                            p_stat_rsn_cd                 in out nocopy varchar2,
                            p_pymt_stat_cd                in out nocopy varchar2,
                            p_pymt_stat_rsn_cd            in out nocopy varchar2,
                            p_pymt_amount                 in out nocopy number ,
                            p_aprvd_for_pymt_amt          in out nocopy number ,
                            p_popl_yr_perd_id_1              in number,
                            p_popl_yr_perd_id_2              in number,
                            p_amt_1                       out nocopy number,
                            p_amt_2                       out nocopy number,
                            -- p_incrd_from_dt               in date    ) is -- 2272862
                            p_exp_incurd_dt               in date    ) is
  --
  l_proc         varchar2(72) := g_package||'chk_pl_id_rqst_amt_and_uom';
  l_api_updating boolean;


  cursor c1 is
  select 'x'
  from   fnd_currencies curr
  where  curr.currency_code = p_rqst_amt_uom
    and  curr.enabled_flag = 'Y'
    and  p_effective_date
         between nvl(curr.start_date_active, p_effective_date)
         and nvl(curr.end_date_active, p_effective_date) ;
  l_test varchar2(1) := null;

  ---- This cursor changed to pickup the latest coverage value
  ---  from the plan year  the EOT may not work if the
  ---  coverage ended/changed in future date # 2469785
  --- changed to pickup the latest wihtin the plan year
  cursor c2 (p_popl_yr_perd_id number) is
  select  pen.bnft_amt
         , pln.cmpr_clms_to_cvg_or_bal_cd
         ,pen.pgm_id
         ,per_in_ler_id
  from   ben_prtt_enrt_rslt_f pen,
         ben_pl_f pln,
         ben_popl_yr_perd       cpy,
         ben_yr_perd            yrp
  where  pln.pl_id = p_pl_id
  and    pln.pl_id = pen.pl_id
  and    pen.person_id = p_submitter_person_id
  and    pln.business_group_id = p_business_group_id
  and    cpy.pl_id  = pln.pl_id
  and    cpy.yr_perd_id    = yrp.yr_perd_id
  and    cpy.popl_yr_perd_id = p_popl_yr_perd_id
  and    pen.enrt_cvg_strt_dt <= yrp.end_date
  and    pen.enrt_cvg_thru_dt >= yrp.start_date
  and    pen.prtt_enrt_rslt_stat_cd is null
  AND    pen.enrt_cvg_thru_dt >= pen.effective_start_date   /* Bug 5607655 : To remove invalid records */
  and    pen.effective_start_date =
            (select max(pen_1.effective_start_date)
             from ben_prtt_enrt_rslt_f   pen_1
             where pen_1.person_id = pen.person_id
               and  pen_1.pl_id    = pen.pl_id
               and  pen_1.prtt_enrt_rslt_stat_cd is null
               and    pen_1.enrt_cvg_strt_dt <= yrp.end_date
               and    pen_1.enrt_cvg_thru_dt >= yrp.start_date ) ;
  --
  cursor c_pln (p_pl_id number) is
    select pln.cmpr_clms_to_cvg_or_bal_cd
    from ben_pl_f pln
    where pln.pl_id = p_pl_id
    and pln.business_group_id = p_business_group_id
    and p_effective_date between pln.effective_start_date
     and pln.effective_end_date;
  --
  l_cmpr_clms_to_cvg_or_bal_cd  varchar2(300);
  l_c2_rec c2%rowtype;
  l_ptd_balance   ben_prtt_reimbmt_rqst_f.rqst_amt%type ;
  l_amt_1     number;
  l_amt_2     number;
  prev_yr_cvg  number;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_prc_shd.api_updating
    (p_prtt_reimbmt_rqst_id        => p_prtt_reimbmt_rqst_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --

   hr_utility.set_location(' p_exp_incurd_dt ' || p_exp_incurd_dt ,192);

  -- Check the UOM value
  if (l_api_updating
      and p_rqst_amt_uom
      <> nvl(ben_prc_shd.g_old_rec.rqst_amt_uom,hr_api.g_varchar2)
      or not l_api_updating)
      and p_rqst_amt_uom is not null then
    --
    -- check if value of lookup falls within lookup type.
    --
    open c1;
    fetch c1 into l_test;
    close c1;
    if l_test is null then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD','p_rqst_amt_uom');
      fnd_message.set_token('VALUE', p_rqst_amt_uom);
      fnd_message.set_token('TYPE','fnd_currencies');
      fnd_message.raise_error;
      --
    end if;
  end if;

  -- Check the plan id
  open c2 (p_popl_yr_perd_id_1);
  fetch c2 into l_c2_rec;
  if c2%notfound and p_popl_yr_perd_id_2 is null then
         close c2;
         fnd_message.set_name('BEN','BEN_91452_PL_ENRT_MISSING');
         fnd_message.set_token('PERSON_ID', p_submitter_person_id);
         fnd_message.set_token('PLAN_ID', p_pl_id);
         fnd_message.raise_error;
  end if;
  close c2;
  --
  if l_c2_rec.cmpr_clms_to_cvg_or_bal_cd is null then
    --
    open c_pln(p_pl_id);
    fetch c_pln into l_cmpr_clms_to_cvg_or_bal_cd;
    close c_pln;
    --
  else
    --
    l_cmpr_clms_to_cvg_or_bal_cd := l_c2_rec.cmpr_clms_to_cvg_or_bal_cd;
    --
  end if;


  ---if the aproved amount is more than the requested amount then error
  if nvl(p_rqst_amt,0) < nvl(p_aprvd_for_pymt_amt,0) then
      fnd_message.set_name('BEN','BEN_92714_APRVD_MORE_THAN_RMT');
      fnd_message.raise_error;
  end if ;

  -- check the rqst_amt
  ---tilak : this check removed ,approved amount is no stored
  --- so it is necessary to validates while approving
  --- approval can happend without any changes in amount
  --- When the amount is compered with coverage , if the coverage amount is
  --  not sufficient then the status is changed but in case of balance
  --- payment status is changed
  --if (l_api_updating
  --    and p_rqst_amt
  --    <> nvl(ben_prc_shd.g_old_rec.rqst_amt,hr_api.g_number)
  --    or not l_api_updating)
  --    and p_rqst_amt is not null then

      -- if the plan's CMPR_CLMS_TO_CVG_OR_BAL_CD is cvg, the amt
      -- cannot exceed the result's coverage amount.
      l_amt_1 := 0;
      l_amt_2 := 0;
      plan_year_claim(
          p_pl_id                 => p_pl_id
         ,p_person_id             => p_submitter_person_id
         ,p_business_group_id     => p_business_group_id
         ,p_prtt_reimbmt_rqst_id  => p_prtt_reimbmt_rqst_id
         ,p_effective_date        => p_effective_date
         ,p_popl_yr_perd_id_1     => p_popl_yr_perd_id_1
         ,p_popl_yr_perd_id_2     => p_popl_yr_perd_id_2
         ,p_amt_1                 => l_amt_1
         ,p_amt_2                 => l_amt_2
         ,p_exp_incurd_dt         => p_exp_incurd_dt  );

       hr_utility.set_location('claim amount I year' || l_amt_1 , 293  );
       hr_utility.set_location('claim amount II year ' || l_amt_2 , 294  );

      if l_cmpr_clms_to_cvg_or_bal_cd in ('CVG', 'BAL') then
        -- if the expense is not in grace period
        if p_popl_yr_perd_id_2 is null then
         if nvl(l_c2_rec.bnft_amt,0) < l_amt_1+nvl(p_aprvd_for_pymt_amt,p_rqst_amt) then
            -- chek there is no fund or partial fund
            if (nvl(l_c2_rec.bnft_amt,0) -  l_amt_1 ) <=  0 then
               p_pymt_amount               := null       ;
               p_aprvd_for_pymt_amt        := null       ;
               p_prtt_reimbmt_rqst_stat_cd := 'DND'      ;
               p_stat_rsn_cd               := 'RMBINCVG' ;
            Else
               P_PYMT_STAT_CD        := 'RMBPRTPAID' ;
               p_stat_rsn_cd         := 'RMBINCVG' ;
               p_pymt_amount         :=  (nvl(l_c2_rec.bnft_amt,0) -  l_amt_1 ) ;
               p_aprvd_for_pymt_amt  :=  p_pymt_amount   ;
               p_amt_1               := p_aprvd_for_pymt_amt;
            End if ;
            --
         Else
             --
             hr_utility.set_location ('Fully Paid'||p_aprvd_for_pymt_amt,11);
             P_PYMT_STAT_CD        := 'RMBFLPAID'   ;
             p_pymt_amount        :=  nvl(p_aprvd_for_pymt_amt,p_rqst_amt)  ;
             p_amt_1              := p_pymt_amount;
             --
         end if;
       --if the expense in grace period
       else
         --
         hr_utility.set_location ('Previos year coverage'||l_c2_rec.bnft_amt,12);
         prev_yr_cvg := nvl(l_c2_rec.bnft_amt,0);
         open c2 (p_popl_yr_perd_id_2);
         fetch c2 into l_c2_rec;
         if c2%notfound  then
           close c2;
           fnd_message.set_name('BEN','BEN_91452_PL_ENRT_MISSING');
           fnd_message.set_token('PERSON_ID', p_submitter_person_id);
           fnd_message.set_token('PLAN_ID', p_pl_id);
           fnd_message.raise_error;
          end if;
          close c2;
           --
         if   prev_yr_cvg <= l_amt_1 or prev_yr_cvg = 0 then
           -- the previous year benefit amount fully used so consider for this year
           -- there was no coverage in the previous year
           hr_utility.set_location ('Previous fully used or no coverage',100);
           hr_utility.set_location ('Benefit amont '||l_c2_rec.bnft_amt,101);
           hr_utility.set_location ('Approved amount '||p_aprvd_for_pymt_amt,102);
           hr_utility.set_location (l_amt_2 + nvl(p_aprvd_for_pymt_amt,p_rqst_amt),103);
           if nvl(l_c2_rec.bnft_amt,0) < (l_amt_2 + nvl(p_aprvd_for_pymt_amt,p_rqst_amt))
           then
             -- chek there is no fund or partial fund
             hr_utility.set_location ('Partial payment',103);
             if (nvl(l_c2_rec.bnft_amt,0) -  l_amt_2 ) <=  0 then
                p_pymt_amount               := null       ;
                p_aprvd_for_pymt_amt        := null       ;
                p_prtt_reimbmt_rqst_stat_cd := 'DND'      ;
                p_stat_rsn_cd               := 'RMBINCVG' ;
             Else
                P_PYMT_STAT_CD        := 'RMBPRTPAID' ;
                p_stat_rsn_cd         := 'RMBINCVG' ;
                p_pymt_amount         :=  (nvl(l_c2_rec.bnft_amt,0) -  l_amt_2 )
 ;
                p_aprvd_for_pymt_amt  :=  p_pymt_amount   ;
                p_amt_2               := p_aprvd_for_pymt_amt;
             End if ;
             --
            else
              --
              hr_utility.set_location ('Fully Paid', 105);
              P_PYMT_STAT_CD        := 'RMBFLPAID'   ;
              p_pymt_amount        :=  nvl(p_aprvd_for_pymt_amt,p_rqst_amt)  ;
              p_amt_2              := p_pymt_amount;
              --
           end if;
           --
        else -- balance available in previous year
          --
          hr_utility.set_location ('Balance Available prev yr',13);
          if prev_yr_cvg >= l_amt_1 + nvl(p_aprvd_for_pymt_amt,p_rqst_amt) then
            --
            hr_utility.set_location ('previous year fully paid',14);
            P_PYMT_STAT_CD        := 'RMBFLPAID'   ;
            p_pymt_amount        :=  nvl(p_aprvd_for_pymt_amt,p_rqst_amt)  ;
            p_amt_1              := p_pymt_amount;
            --
          elsif (prev_yr_cvg + nvl(l_c2_rec.bnft_amt,0)) >= (l_amt_1 + l_amt_2 +
                         nvl(p_aprvd_for_pymt_amt,p_rqst_amt)) then
            --
            hr_utility.set_location ('Claim falls on two year',15);
            P_PYMT_STAT_CD        := 'RMBFLPAID'   ;
            p_pymt_amount        :=  nvl(p_aprvd_for_pymt_amt,p_rqst_amt)  ;
            p_amt_1              := prev_yr_cvg - l_amt_1;
            p_amt_2              := p_pymt_amount - p_amt_1;
          elsif nvl(l_c2_rec.bnft_amt,0) = 0 then --no current coverage
            --
            hr_utility.set_location ('No current year coverage',16);
            p_pymt_amount := prev_yr_cvg - l_amt_1;
            p_amt_1       := p_pymt_amount;
            P_PYMT_STAT_CD        := 'RMBPRTPAID' ;
            p_stat_rsn_cd         := 'RMBINCVG' ;
            p_aprvd_for_pymt_amt  :=  p_pymt_amount   ;
            --
          elsif (prev_yr_cvg + nvl(l_c2_rec.bnft_amt,0)) < (l_amt_1 + l_amt_2 +
                         nvl(p_aprvd_for_pymt_amt,p_rqst_amt)) then
            --
            hr_utility.set_location ('Partially paid for two years',17);
            p_amt_1 := prev_yr_cvg - l_amt_1;
            p_amt_2 := nvl(l_c2_rec.bnft_amt,0) - l_amt_2;
            p_pymt_amount := p_amt_1 + p_amt_2;
            P_PYMT_STAT_CD        := 'RMBPRTPAID' ;
            p_stat_rsn_cd         := 'RMBINCVG' ;
            p_aprvd_for_pymt_amt  :=  p_pymt_amount   ;
            --
          end if;
       end if;
      end if;
    end if;
    --
    /*
    If l_c2_rec.cmpr_clms_to_cvg_or_bal_cd = 'BAL' then
             -- compare amt to a balance.
            l_ptd_balance :=  get_year_balance (
              p_person_id            =>   p_submitter_person_id
             ,p_pgm_id               =>   l_c2_rec.pgm_id
             ,p_pl_id                =>   p_pl_id
             ,p_business_group_id    =>   p_business_group_id
             ,p_per_in_ler_id        =>   l_c2_rec.per_in_ler_id
             ,p_prtt_enrt_rslt_id    =>   p_prtt_enrt_rslt_id
             ,p_effective_date       =>   p_effective_date
             ,p_exp_incurd_dt        =>   p_exp_incurd_dt
              ) ;


            if l_ptd_balance < l_amt_1+nvl(p_aprvd_for_pymt_amt,p_rqst_amt) then
               -- chek there is no fund or partial fund
               if (nvl(l_ptd_balance,0) -  l_amt_1 ) <=  0 then
                  P_PYMT_STAT_CD        := 'RMBPNDNG'   ;
                  p_pymt_amount        :=  null ;
               Else
                  P_PYMT_STAT_CD        := 'RMBPRTPAID' ;
                  p_pymt_amount        := (nvl(l_ptd_balance,0) -  l_amt_1 );
               End if ;
               ----validate for coverage whether the amount is less then coveragwe
             if nvl(l_c2_rec.bnft_amt,0) < l_amt_1+nvl(p_aprvd_for_pymt_amt,p_rqst_amt) then

                 if (nvl(l_c2_rec.bnft_amt,0) -  l_amt_1 ) <=  0 then
                    p_pymt_amount               := null       ;
                    p_aprvd_for_pymt_amt        := null       ;
                    p_prtt_reimbmt_rqst_stat_cd := 'DND'      ;
                    p_stat_rsn_cd               := 'RMBINCVG' ;
                Else
                    p_stat_rsn_cd         := 'RMBINCVG' ;
                    p_pymt_amount         :=  (nvl(l_c2_rec.bnft_amt,0) - l_amt_1 ) ;
                    p_aprvd_for_pymt_amt  :=  p_pymt_amount   ;
                End if ;

             end if;

         Else
            P_PYMT_STAT_CD        := 'RMBFLPAID'   ;
            p_pymt_amount        :=  nvl(p_aprvd_for_pymt_amt,p_rqst_amt)  ;
            p_amt_1              := p_pymt_amount;
         end if;
    end if;  */
    hr_utility.set_location(' pyment amount ' || p_pymt_amount ,110);

  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_pl_id_rqst_amt_and_uom;

------------------------------------------------------------------------------
-- |------< chk_remb_status >-----|
-- ----------------------------------------------------------------------------

procedure chk_remb_status(
        p_prtt_reimbmt_rqst_stat_cd in varchar2
        )is
  l_proc         varchar2(72) := g_package||' chk_remb_status';
begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_prtt_reimbmt_rqst_stat_cd in  ('APPRVD','PDINFL','PRTLYPD')  then
     fnd_message.set_name('BEN','BEN_92705_REIMB_RQST_APPROVD');
     fnd_message.raise_error;
  end if ;
  if  p_prtt_reimbmt_rqst_stat_cd = 'VOIDED' then
      fnd_message.set_name('BEN','BEN_92708_REIMB_RQST_VOIDED');
      fnd_message.raise_error;
  end if ;

  hr_utility.set_location('Leaving:'||l_proc,10);
end chk_remb_status;


--
------------------------------------------------------------------------------
-- |------< chk_future_dated >-----|
-- ----------------------------------------------------------------------------
---- check future dated reimbursement requst or election exist
  procedure chk_future_dated(
                             p_pl_id                      in number,
                             p_submitter_person_id        in number,
                             p_prtt_reimbmt_rqst_id       in number,
                             p_business_group_id          in number,
                             p_effective_date             in date
                             ) is

   cursor c_prc is
     select 'x'  from ben_prtt_reimbmt_rqst_f
     where prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
       and effective_start_date > p_effective_date ;

   cursor c_asg is
      select  assignment_id
             ,payroll_id
       from  per_all_assignments_f
      where person_id = p_submitter_person_id
        and assignment_type <> 'C'
        and p_effective_Date between
            effective_start_date  and effective_end_date ;


   cursor c_prv is
      select acty_base_rt_id , rt_strt_dt
      from ben_prtt_rt_val
      where prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id ;




   cursor c_per  is
     select  'x'
      from   ben_prtt_enrt_rslt_f pen, ben_pl_f pln
      where  pln.pl_id = p_pl_id
       and   pln.pl_id = pen.pl_id
       and   pen.person_id = p_submitter_person_id
       and   pln.business_group_id = p_business_group_id
       and   pen.effective_start_date >  p_effective_date
       and   p_effective_date between
             pln.effective_start_date and pln.effective_end_date
        and  pen.prtt_enrt_rslt_stat_cd is null ;


   cursor c_get_end_dt(p_payroll_id        in number
                     ,p_acty_base_rt_id   in number
                     ,p_business_group_id in number
                     ,p_assignment_id     in number
                     ,p_effective_date    in date)
    is
    select /*+ leading(d) use_nl(d i e h a j g b) index(h PAY_RUN_RESULTS_N50) */
    max(g.end_date) end_date
    from
    pay_run_result_values a,
    pay_element_types_f b,
    pay_assignment_actions d,
    pay_payroll_actions e,
    per_time_periods g,
    pay_run_results h,
    ben_acty_base_rt_f i,
    pay_input_values_f j
    where d.assignment_id = p_assignment_id
    and d.payroll_action_id = e.payroll_action_id
    and i.input_value_id = j.input_value_id
    and i.element_type_id = b.element_type_id
    and i.acty_base_rt_id = p_acty_base_rt_id
    and p_effective_date
    between i.effective_start_date and i.effective_end_date
    and i.business_group_id = p_business_group_id
    and g.payroll_id = p_payroll_id
    and b.element_type_id = h.element_type_id
    and d.assignment_action_id = h.assignment_action_id
    and e.date_earned between
        g.start_date and g.end_date
    and a.input_value_id = j.input_value_id
    and a.run_result_id = h.run_result_id
    and j.element_type_id = b.element_type_id
    and p_effective_date between
        b.effective_start_date and b.effective_end_date
    and p_effective_date between
        j.effective_start_date and j.effective_end_date;

   g_max_end_date date := null;
   l_dummy_var         varchar2(1) ;
   l_proc              varchar2(72) := g_package||'chk_future_date';
   l_payroll_id        number ;
   l_assignment_id     number ;
   l_acty_base_rt_id   number ;
   l_rt_strt_dt       date   ;
  begin

    hr_utility.set_location('Entering:'||l_proc,5);
    -- when future date tracked row in available for the reimbmt req
    /* thery may be status cahnges though there is futer dated entry there
    hr_utility.set_location('checking for futrue prc:'||l_proc,5);
    open c_prc ;
    fetch c_prc into l_dummy_var   ;
    if c_prc%found then
       close c_prc ;
       fnd_message.set_name('BEN', 'BEN_92663_FUTURE_DTD_REIMB_REQ');
       fnd_message.raise_error;
    end if ;
    close c_prc ;
    */
    -- when the future date tracked election is avaialble
    hr_utility.set_location('checking for future election:'||l_proc,5);
    /*
    open c_per ;
    fetch c_per into l_dummy_var ;
    if c_per%found then
       close c_per ;
       fnd_message.set_name('BEN', 'BEN_92663_FUTURE_DTD_ELE_EXIST');
       fnd_message.raise_error;
    end if ;
    close c_per ;
   */
    --
    ---chek run result exist foe the element
    open c_asg;
    fetch c_asg into l_assignment_id, l_payroll_id ;
    close c_asg ;

    open c_prv ;
    fetch c_prv into l_acty_base_rt_id,l_rt_strt_dt ;
    close c_prv ;


    hr_utility.set_location('checking for runresult:'||l_proc,5);
    g_max_end_date := null;
    open   c_get_end_dt(p_payroll_id        => l_payroll_id
                     ,p_acty_base_rt_id   => l_acty_base_rt_id
                     ,p_business_group_id => p_business_group_id
                     ,p_assignment_id     => l_assignment_id
                     ,p_effective_date    => l_rt_strt_dt);
    fetch c_get_end_dt into g_max_end_date;
    close c_get_end_dt;
    if g_max_end_date is not null and (g_max_end_date +1) > l_rt_strt_dt then
       -- Issue a warning to the user.  These will display on the enrt forms.
            fnd_message.set_name('BEN', 'BEN_92455_STRT_RUN_RESULTS');
             fnd_message.set_token('PARMA', l_rt_strt_dt);
             fnd_message.set_token('PARMB',g_max_end_date);
             fnd_message.raise_error;

    end if;
    hr_utility.set_location('Leaving:' ||l_proc,5);
  end chk_future_dated ;

--






-------------------------------------------------------------------------------
-- |-------------------------< chk_incrd_dt >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that incrd dt lies within plan year period
--   and also within enrollment cvrg date range for the plan for the submitter.
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_prtt_reimbmt_rqst_id
--   p_submitter_person_id
--   p_pl_id
--   p_incrd_from_dt
--   p_incrd_to_dt
--   p_effective_date
--   p_business_group_id
--   p_object_version_number
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
Procedure chk_incrd_dt(
		      p_prtt_reimbmt_rqst_id  in number,
                      p_pl_id                 in number,
	 	      p_submitter_person_id   in number,
		      p_incrd_from_dt         in date,
		      p_incrd_to_dt           in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
		      p_object_version_number in number,
                      p_rqst_amt              in number,
                      p_prtt_reimbmt_rqst_stat_cd   in out nocopy  varchar2,
                      p_stat_rsn_cd                 in out nocopy  varchar2,
                      p_exp_incurd_dt         in date    -- 2272862
                   ) is
  --
  l_proc              varchar2(72) := g_package||'chk_incrd_dt';
  l_api_updating      boolean;
  --
  l_enrt_cvg_strt_dt       date;
  l_enrt_cvg_thru_dt       date;
  l_yrp_start_date         date;
  l_yrp_end_date           date;
  l_acpt_clm_rqsts_thru_dt date;
  l_py_clms_thru_dt        date;
  --
  l_over_dated_gds_exists  boolean  := FALSE;
  l_tmp_str                varchar2(2000);
  l_gds_date_str	   varchar2(2000);
  -- Coverage start date should lowest possible date with in year record
  -- cvg end date should be highest record end date with in year record
  -- This cursor is to check if the expense incurd dt is valid
  -- and to get other data to check if the incrd from and to dates are within the covrage period
  -- and to get acpt_clm_rqsts_thru_dt to check if the effective date is well within valid limits
  --
  --bug#4541750 - changed made to cursor to fetch details from multiple results
  --for the same plan year
  cursor c1 is
     select distinct
            pen_l.enrt_cvg_strt_dt enrt_cvg_strt_dt
     	   ,nvl(pen.enrt_cvg_thru_dt,pen_l.enrt_cvg_thru_dt) enrt_cvg_thru_dt
     	   ,yrp.start_date
     	   ,yrp.end_date
     	   ,nvl(cpy.acpt_clm_rqsts_thru_dt, pen.enrt_cvg_thru_dt) acpt_clm_rqsts_thru_dt
	   ,nvl(cpy.PY_CLMS_THRU_DT, yrp.end_date) PY_CLMS_THRU_DT
     from   ben_prtt_enrt_rslt_f   pen,
            ben_prtt_enrt_rslt_f   pen_l,
            ben_popl_yr_perd       cpy,
            ben_yr_perd            yrp
     where  cpy.pl_id = p_pl_id
     and    pen.pl_id = cpy.pl_id
     and    pen.person_id     = p_submitter_person_id
     and    cpy.yr_perd_id    = yrp.yr_perd_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    pen_l.prtt_enrt_rslt_stat_cd is null
     and    pen.effective_end_date = hr_api.g_eot
     and    pen_l.effective_end_date = hr_api.g_eot
     and    p_exp_incurd_dt >= yrp.start_date
     and    p_exp_incurd_dt <= nvl(cpy.PY_CLMS_THRU_DT, yrp.end_date)
     and    pen.pl_id = pen_l.pl_id
     and    pen.person_id   =  pen_l.person_id
     and    cpy.business_group_id = p_business_group_id
     and    yrp.business_group_id = p_business_group_id
     and    pen.business_group_id = p_business_group_id
     -- to find the highest possible record within the year #2469785
     --and    pen.enrt_cvg_strt_dt   <= yrp.end_date
     --and    pen.enrt_cvg_thru_dt   >= yrp.start_date
     --and    pen_l.enrt_cvg_strt_dt <= yrp.end_date
     --and    pen_l.enrt_cvg_thru_dt >= yrp.start_date
     --- effective date is not used to control
     --- there is poosibility of cvg may  start
     --- much before effective date start
     --and    pen.effective_start_date   <= yrp.end_date
     --and    pen.effective_end_date   >= yrp.start_date
     --and    pen_l.effective_start_date <= yrp.end_date
     --and    pen_l.effective_end_date >= yrp.start_date
     ---
     and    pen.prtt_enrt_rslt_id =
            (select max(pen2.prtt_enrt_rslt_id)
             from ben_prtt_enrt_rslt_f   pen2
             where pen2.person_id = pen.person_id
               and  pen2.pl_id    = pen.pl_id
               and  pen2.prtt_enrt_rslt_stat_cd is null
               and  pen2.SSPNDD_FLAG = 'N'
               and    pen2.enrt_cvg_strt_dt <= yrp.end_date
               and    pen2.enrt_cvg_thru_dt >= yrp.start_date
               and    pen2.effective_end_date = hr_api.g_eot
                )
    and    pen_l.prtt_enrt_rslt_id =
            (select min(pen_l2.prtt_enrt_rslt_id)
             from ben_prtt_enrt_rslt_f   pen_l2
             where pen_l2.person_id = pen_l.person_id
               and pen_l2.pl_id    = pen_l.pl_id
               and pen_l2.SSPNDD_FLAG = 'N'
               and pen_l2.prtt_enrt_rslt_stat_cd is null
               and pen_l2.enrt_cvg_strt_dt <= yrp.end_date
               and pen_l2.enrt_cvg_thru_dt >= yrp.start_date
               and    pen_l.effective_end_date = hr_api.g_eot
             )
    ;
   --
   -- This cursor will check if the incrd_to_dt is less than the earliest submission date for
   -- all the goods or services claimed as part of this reimbursement request.
   --
   cursor c2 is
     select gds.name,
            decode(pgs.GD_SVC_RECD_BASIS_CD, 'DATE', GD_SVC_RECD_BASIS_DT,
               decode(pgs.GD_SVC_RECD_BASIS_CD, 'MOINCRDT', add_months(p_exp_incurd_dt,pgs.GD_SVC_RECD_BASIS_MO),
                  decode(pgs.GD_SVC_RECD_BASIS_CD, 'MOPLYRND', add_months(yrp.end_date,pgs.GD_SVC_RECD_BASIS_MO),yrp.end_date))) earliest_submit_date
     from   ben_prtt_enrt_rslt_f   pen,
            ben_popl_yr_perd       cpy,
            ben_yr_perd            yrp,
            ben_prtt_clm_gd_or_svc_typ pcg,
            ben_pl_gd_or_svc_f     pgs,
            ben_gd_or_svc_typ      gds
     where  pcg.prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
     and    pcg.pl_gd_or_svc_id = pgs.pl_gd_or_svc_id
     and    pgs.gd_or_svc_typ_id = gds.gd_or_svc_typ_id
     and    cpy.pl_id = pgs.pl_id
     and    pen.pl_id = cpy.pl_id
     and    pen.person_id     = p_submitter_person_id
     and    cpy.yr_perd_id    = yrp.yr_perd_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    p_exp_incurd_dt >= yrp.start_date
     and    p_exp_incurd_dt <= nvl(cpy.PY_CLMS_THRU_DT, yrp.end_date)
     and    p_incrd_from_dt >= pen.enrt_cvg_strt_dt
     and    p_incrd_to_dt   <= pen.enrt_cvg_thru_dt
     and    p_incrd_from_dt  <= p_incrd_to_dt
     and    p_incrd_from_dt  >= yrp.start_date
     and    p_incrd_to_dt    >  decode(pgs.GD_SVC_RECD_BASIS_CD, 'DATE', GD_SVC_RECD_BASIS_DT,
               		           decode(pgs.GD_SVC_RECD_BASIS_CD, 'MOINCRDT', add_months(p_exp_incurd_dt,pgs.GD_SVC_RECD_BASIS_MO),
                  	            decode(pgs.GD_SVC_RECD_BASIS_CD, 'MOPLYRND', add_months(yrp.end_date,pgs.GD_SVC_RECD_BASIS_MO),yrp.end_date)))
     and    p_effective_date between
            pen.effective_start_date and pen.effective_end_date
     and    p_effective_date between
            pgs.effective_start_date and pgs.effective_end_date
     and    cpy.business_group_id = p_business_group_id
     and    yrp.business_group_id = p_business_group_id
     and    pen.business_group_id = p_business_group_id
     and    pcg.business_group_id = p_business_group_id
     and    pgs.business_group_id = p_business_group_id
     and    gds.business_group_id = p_business_group_id;



  /* ************** bug 2272862
  -- This is to chek the claim happend on the year
  -- allow the futur date within the year
  cursor c1 is
     select nvl(cpy.acpt_clm_rqsts_thru_dt, pen.enrt_cvg_thru_dt)
     from   ben_prtt_enrt_rslt_f   pen,
            ben_popl_yr_perd       cpy,
            ben_yr_perd            yrp
     where  cpy.pl_id = p_pl_id
     and    pen.pl_id = p_pl_id
     and    pen.person_id     = p_submitter_person_id
     and    cpy.yr_perd_id    = yrp.yr_perd_id
     and    pen.prtt_enrt_rslt_stat_cd is null
     and    p_incrd_from_dt >= pen.enrt_cvg_strt_dt
     and    p_incrd_to_dt   <= pen.enrt_cvg_thru_dt
     and    p_incrd_from_dt  <= p_incrd_to_dt
     and    p_incrd_from_dt  >= yrp.start_date
     and    p_incrd_to_dt    <= yrp.end_date
     --and    p_incrd_to_dt    <= p_effective_date // allowing futur date with pndg status
     and    p_effective_date between
            pen.effective_start_date and pen.effective_end_date
     --and    p_effective_date  >= yrp.start_date
     and    cpy.business_group_id = p_business_group_id
     and    yrp.business_group_id = p_business_group_id
     and    pen.business_group_id = p_business_group_id;
  **************** */
  --
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_prc_shd.api_updating
     (p_prtt_reimbmt_rqst_id    => p_prtt_reimbmt_rqst_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if ((l_api_updating
       and (nvl(p_incrd_from_dt, hr_api.g_date)
             <> nvl(ben_prc_shd.g_old_rec.incrd_from_dt, hr_api.g_date)
            or nvl(p_incrd_to_dt, hr_api.g_date)
             <> nvl(ben_prc_shd.g_old_rec.incrd_to_dt, hr_api.g_date)
            or nvl(p_exp_incurd_dt, hr_api.g_date)
             <> nvl(ben_prc_shd.g_old_rec.exp_incurd_dt, hr_api.g_date)
            or nvl(p_rqst_amt,0) <> nvl(ben_prc_shd.g_old_rec.rqst_amt,0)
            or nvl(p_prtt_reimbmt_rqst_stat_cd ,'-1')<>
               nvl(ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd ,'-1')
            or nvl(p_pl_id,-1)   <> nvl(ben_prc_shd.g_old_rec.pl_id,-1) ))
     or not l_api_updating) then

    hr_utility.set_location('validating'||l_proc,5);


    /* ************** bug 2272862
    --
    --
    -- check incrd_to_dt is not greater than effective date
    if p_incrd_to_dt > p_effective_date then
     --
       --fnd_message.set_name('BEN', 'BEN_92689_TO_DATE_EFF_DATE');
       --fnd_message.raise_error;

        p_prtt_reimbmt_rqst_stat_cd := 'PNDNG' ;
        p_stat_rsn_cd  :=  'RMBFUTRDT'  ;

     --
    end if;
    **************** */

    for i in   c1 Loop

       hr_utility.set_location( ' from st dt ' || i.enrt_cvg_strt_dt, 90) ;
       hr_utility.set_location( ' from en dt ' || i.enrt_cvg_thru_dt, 90) ;
       if l_enrt_cvg_strt_dt  is null then
          l_enrt_cvg_strt_dt := i.enrt_cvg_strt_dt ;
       else
          l_enrt_cvg_strt_dt := least(i.enrt_cvg_strt_dt,l_enrt_cvg_strt_dt) ;
       end if ;

       if l_enrt_cvg_thru_dt is null then
          l_enrt_cvg_thru_dt :=  i.enrt_cvg_thru_dt ;
       else
          l_enrt_cvg_thru_dt :=  greatest(i.enrt_cvg_thru_dt,l_enrt_cvg_thru_dt) ;
       end if ;

       hr_utility.set_location( ' from st dt ' || l_enrt_cvg_strt_dt, 99) ;
       hr_utility.set_location( ' from en dt ' || l_enrt_cvg_thru_dt, 99) ;
       l_yrp_start_date         :=  i.start_date ;
       l_yrp_end_date           :=  i.end_date ;
       l_acpt_clm_rqsts_thru_dt :=  i.acpt_clm_rqsts_thru_dt ;
       l_py_clms_thru_dt        :=  i.PY_CLMS_THRU_DT ;
    end Loop ;

    if l_enrt_cvg_strt_dt is null or l_enrt_cvg_thru_dt  is null then
      --
      fnd_message.set_name('PAY', 'HR_52965_COL_RANGE');
      fnd_message.set_token('COLUMN','Expense Incurred Date', TRUE);
      fnd_message.set_token('MINIMUM','Plan Year Start Date', TRUE);
      fnd_message.set_token('MAXIMUM','Expense Must Be Incurred On Or Before Date', TRUE);
      fnd_message.raise_error;
      --
    else
      --
      --
      if p_effective_date < l_yrp_start_date then
        --
        -- bug fix 2509297 - message change
        --
        -- fnd_message.set_name('PAY', 'HR_52965_COL_RANGE');
        -- fnd_message.set_token('COLUMN','Effective Date', TRUE);
        -- fnd_message.set_token('MINIMUM','Plan Year Start Date', TRUE);
        -- fnd_message.set_token('MAXIMUM','Request Must Be Received On Or Before Date', TRUE);
        --
        fnd_message.set_name('BEN', 'BEN_93189_EFFDT_NB_PLYR_RQRCV');
        --
        -- end fix 2509297
        --
        fnd_message.raise_error;
        --
      end if;
      --
      hr_utility.set_location(' p_effective_date  ' || p_effective_date  , 98 );
      hr_utility.set_location(' l_acpt_clm_rqsts_thru_dt  ' || l_acpt_clm_rqsts_thru_dt  , 98 );
      if p_effective_date > l_acpt_clm_rqsts_thru_dt then
        --
        -- No claim to be accepted beyond acpt_clm_rqsts_thru_dt.
        -- If acpt_clm_rqsts_thru_dt not specified, use enrt_cvg_thru_dt
        -- Effective beyond the date, so raise error.
        --
        fnd_message.set_name('BEN', 'BEN_92499_CLM_AFTR_ALWD_DT');
        fnd_message.set_token('RQST_THRU_DT', to_char(l_acpt_clm_rqsts_thru_dt,'DD-MON-RRRR'));
        fnd_message.set_token('EFFECTIVE_DATE', to_char(p_effective_date,'DD-MON-RRRR'));
        fnd_message.raise_error;
        --
      end if;
      --
      hr_utility.set_location(' p_incrd_from_dt ' || p_incrd_from_dt , 98 );
      hr_utility.set_location(' p_incrd_to_dt ' || p_incrd_to_dt , 98 );
      hr_utility.set_location(' l_enrt_cvg_strt_dt ' || l_enrt_cvg_strt_dt , 98 );
      hr_utility.set_location(' l_enrt_cvg_thru_dt ' || l_enrt_cvg_thru_dt , 98 );
      hr_utility.set_location(' l_yrp_start_date ' || l_yrp_start_date , 98 );
      hr_utility.set_location(' l_yrp_end_date ' || l_yrp_end_date , 98 );
      if not (p_incrd_from_dt  >= l_enrt_cvg_strt_dt
         -- if a  person last coverage beore the yr end allow him up to the year  end
      	 and  p_incrd_to_dt    <= greatest(l_enrt_cvg_thru_dt,l_yrp_end_date)
      	 and  p_incrd_from_dt  <= p_incrd_to_dt
      	 and  p_incrd_from_dt  >= l_yrp_start_date ) then
        --
        -- The service "from" and "to" date is beyond the coverage range.
        -- So, raise error.
        --
        fnd_message.set_name('BEN', 'BEN_92498_RQST_BYND_CVG_DT');
        fnd_message.raise_error;
        --
      end if;
      --
    end if;
    --

    if p_prtt_reimbmt_rqst_stat_cd in ('APPRVD','PDINFL','PRTLYPD') then
      --
      -- Check for presence of claimed goods or services whose earliest submit date
      -- is less than the claim date (incrd_to_dt)
      --
      for l_c2 in c2 loop
        --
	-- bug fix 2508246 -- added date formatting to l_c2.earliest_submit_date
	-- for showing in DD-MON-RRRR
        if not l_over_dated_gds_exists then
          l_tmp_str := l_c2.name || ' - ' || to_char(l_c2.earliest_submit_date, 'DD-MON-RRRR');
        else
          l_tmp_str := l_gds_date_str || ', ' || l_c2.name || ' - ' || to_char(l_c2.earliest_submit_date, 'DD-MON-RRRR');
        end if;
        --
        l_over_dated_gds_exists := TRUE;
        --
        if length(l_tmp_str) > 1700 then
          --commit;
exit;
        else
          l_gds_date_str := l_tmp_str;
        end if;
        --
      end loop;
      --
      /*
      if l_over_dated_gds_exists then
        --
        fnd_message.set_name('BEN', 'BEN_93106_CLM_GD_SBMTDT_XCEED');
        fnd_message.set_token('GDS_DATE', l_gds_date_str);
        fnd_message.raise_error;
        --
      end if;
      --
     */
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_incrd_dt;
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
            (p_pl_id                         in number ,
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
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
-- ----------------------------------------------------------------------------
-- |--------------------------< prv_rows_exists >--------------------------|
-- ----------------------------------------------------------------------------

Function prv_rows_exists (p_prtt_reimbmt_rqst_id in number ) Return Boolean  is

  l_proc         varchar2(72) := g_package||'prv_rows_exists';
  l_dummy        varchar2(1);

  cursor c1 is
    select null
    from   ben_prtt_rt_val a
    where  a.prtt_reimbmt_rqst_id  = p_prtt_reimbmt_rqst_id;

Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  -- check if child rows exists in ben_prtt_rt_val.
  --
  open c1;
  fetch c1 into l_dummy;
  if c1%found then

        close c1;
        --
        -- raise error as child rows exists.
        --
        Return(true);
  Else
    close c1;
    Return(false);
  end if;
  hr_utility.set_location('Leaving:'||l_proc,10);
End prv_rows_exists;

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
            (p_prtt_reimbmt_rqst_id		in number,
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
       p_argument       => 'prtt_reimbmt_rqst_id',
       p_argument_value => p_prtt_reimbmt_rqst_id);
    --
    If (prv_rows_exists(p_prtt_reimbmt_rqst_id => p_prtt_reimbmt_rqst_id)) Then
       l_table_name := 'ben_prtt_rt_val';
       Raise l_rows_exist;
    End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore we must error
    ben_utility.child_exists_error(p_table_name => l_table_name);
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
  chk_prtt_reimbmt_rqst_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gd_or_svc_typ_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_provider_person_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_provider_person_id          => p_rec.provider_person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rcrrg_cd
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_rcrrg_cd         => p_rec.rcrrg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_reimbmt_ctfn_typ_prvdd_cd
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_reimbmt_ctfn_typ_prvdd_cd         => p_rec.reimbmt_ctfn_typ_prvdd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_reimbmt_rqst_stat_cd
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_prtt_reimbmt_rqst_stat_cd         => p_rec.prtt_reimbmt_rqst_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_stat_rsn_cd
  (p_prtt_reimbmt_rqst_id   => p_rec.prtt_reimbmt_rqst_id,
   p_stat_rsn_cd            => p_rec.stat_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_stat_rsn_cd
  (p_prtt_reimbmt_rqst_id   => p_rec.prtt_reimbmt_rqst_id,
   p_pymt_stat_rsn_cd       => p_rec.pymt_stat_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
   --
  chk_pymt_stat_cd
  (p_prtt_reimbmt_rqst_id   => p_rec.prtt_reimbmt_rqst_id,
   p_pymt_stat_cd           => p_rec.pymt_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_prtt_reimbmt_stat_apprvd
             (p_prtt_reimbmt_rqst_id        => p_rec.prtt_reimbmt_rqst_id,
              p_aprvd_for_pymt_amt          => p_rec.aprvd_for_pymt_amt ,
              p_prtt_reimbmt_rqst_stat_cd   => p_rec.prtt_reimbmt_rqst_stat_cd  ,
              p_stat_rsn_cd                 => p_rec.stat_rsn_cd  ,
              p_effective_date              => p_effective_date
             ) ;

  chk_incrd_dt
        (p_prtt_reimbmt_rqst_id       => p_rec.prtt_reimbmt_rqst_id,
        p_pl_id                       => p_rec.pl_id,
        p_submitter_person_id         => p_rec.submitter_person_id,
        p_incrd_from_dt               => p_rec.incrd_from_dt,
        p_incrd_to_dt                 => p_rec.incrd_to_dt,
        p_effective_date              => p_effective_date,
        p_business_group_id           => p_rec.business_group_id,
        p_object_version_number       => p_rec.object_version_number,
        p_rqst_amt                    => p_rec.rqst_amt ,
        p_prtt_reimbmt_rqst_stat_cd   => p_rec.prtt_reimbmt_rqst_stat_cd  ,
        p_stat_rsn_cd                 => p_rec.stat_rsn_cd,
        p_exp_incurd_dt		      => p_rec.exp_incurd_dt	-- 2272862
   );


  --
  chk_pl_id_rqst_amt_and_uom
  (p_prtt_reimbmt_rqst_id     => p_rec.prtt_reimbmt_rqst_id,
   p_rqst_amt_uom             => p_rec.rqst_amt_uom,
   p_rqst_amt                 => p_rec.rqst_amt,
   p_pl_id                    => p_rec.pl_id,
   p_submitter_person_id      => p_rec.submitter_person_id,
   p_business_group_id        => p_rec.business_group_id,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number,
   p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id ,
   p_prtt_reimbmt_rqst_stat_cd=> p_rec.prtt_reimbmt_rqst_stat_cd,
   p_stat_rsn_cd              => p_rec.stat_rsn_cd ,
   p_pymt_stat_cd             => p_rec.pymt_stat_cd,
   p_pymt_stat_rsn_cd         => p_rec.pymt_stat_rsn_cd,
   p_pymt_amount              => p_rec.pymt_amount,
   p_aprvd_for_pymt_amt       => p_rec.aprvd_for_pymt_amt,
   p_exp_incurd_dt	      => p_rec.exp_incurd_dt,
   p_popl_yr_perd_id_1           => p_rec.popl_yr_perd_id_1,
   p_popl_yr_perd_id_2           => p_rec.popl_yr_perd_id_2,
   p_amt_1                    => p_rec.amt_year1,
   p_amt_2                    => p_rec.amt_year2 );

  hr_utility.set_location('after stat check ' || p_rec.prtt_reimbmt_rqst_stat_cd, 110);
  hr_utility.set_location('after stat check ' || p_rec.stat_rsn_cd, 110);
  hr_utility.set_location('after stat check ' || p_rec.Pymt_stat_cd, 110);
  hr_utility.set_location('after stat check ' || p_rec.pymt_stat_rsn_cd, 110);


  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
  chk_prtt_reimbmt_rqst_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_gd_or_svc_typ_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_gd_or_svc_typ_id          => p_rec.gd_or_svc_typ_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_provider_person_id
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_provider_person_id          => p_rec.provider_person_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_rcrrg_cd
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_rcrrg_cd         => p_rec.rcrrg_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_reimbmt_ctfn_typ_prvdd_cd
  (p_prtt_reimbmt_rqst_id          => p_rec.prtt_reimbmt_rqst_id,
   p_reimbmt_ctfn_typ_prvdd_cd         => p_rec.reimbmt_ctfn_typ_prvdd_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_prtt_reimbmt_rqst_stat_cd
  (p_prtt_reimbmt_rqst_id       => p_rec.prtt_reimbmt_rqst_id,
   p_prtt_reimbmt_rqst_stat_cd  => p_rec.prtt_reimbmt_rqst_stat_cd,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  chk_stat_rsn_cd
  (p_prtt_reimbmt_rqst_id   => p_rec.prtt_reimbmt_rqst_id,
   p_stat_rsn_cd            => p_rec.stat_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_stat_rsn_cd
  (p_prtt_reimbmt_rqst_id   => p_rec.prtt_reimbmt_rqst_id,
   p_pymt_stat_rsn_cd       => p_rec.pymt_stat_rsn_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_pymt_stat_cd
  (p_prtt_reimbmt_rqst_id  => p_rec.prtt_reimbmt_rqst_id,
   p_pymt_stat_cd          => p_rec.pymt_stat_cd,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_incrd_dt
    (p_prtt_reimbmt_rqst_id        => p_rec.prtt_reimbmt_rqst_id,
     p_pl_id                       => p_rec.pl_id,
     p_submitter_person_id         => p_rec.submitter_person_id,
     p_incrd_from_dt               => p_rec.incrd_from_dt,
     p_incrd_to_dt                 => p_rec.incrd_to_dt,
     p_effective_date              => p_effective_date,
     p_business_group_id           => p_rec.business_group_id,
     p_object_version_number       => p_rec.object_version_number,
     p_rqst_amt                    => p_rec.rqst_amt ,
     p_prtt_reimbmt_rqst_stat_cd   => p_rec.prtt_reimbmt_rqst_stat_cd  ,
     p_stat_rsn_cd                 => p_rec.stat_rsn_cd,
     p_exp_incurd_dt		   => p_rec.exp_incurd_dt     -- 2272862
   );

 hr_utility.set_location('after date  check ' || p_rec.stat_rsn_cd, 110);

  --
  chk_pl_id_rqst_amt_and_uom
  (p_prtt_reimbmt_rqst_id     => p_rec.prtt_reimbmt_rqst_id,
   p_rqst_amt_uom             => p_rec.rqst_amt_uom,
   p_rqst_amt                 => p_rec.rqst_amt,
   p_pl_id                    => p_rec.pl_id,
   p_submitter_person_id      => p_rec.submitter_person_id,
   p_business_group_id        => p_rec.business_group_id,
   p_effective_date           => p_effective_date,
   p_object_version_number    => p_rec.object_version_number,
   p_prtt_enrt_rslt_id        => p_rec.prtt_enrt_rslt_id,
   p_prtt_reimbmt_rqst_stat_cd=> p_rec.prtt_reimbmt_rqst_stat_cd,
   p_stat_rsn_cd              => p_rec.stat_rsn_cd,
   p_pymt_stat_cd             => p_rec.pymt_stat_cd,
   p_pymt_stat_rsn_cd         => p_rec.pymt_stat_rsn_cd,
   p_pymt_amount              => p_rec.pymt_amount,
   p_aprvd_for_pymt_amt       => p_rec.aprvd_for_pymt_amt,
   p_exp_incurd_dt	      => p_rec.exp_incurd_dt,
   p_popl_yr_perd_id_1           => p_rec.popl_yr_perd_id_1,
   p_popl_yr_perd_id_2           => p_rec.popl_yr_perd_id_2,
   p_amt_1                    => p_rec.amt_year1,
   p_amt_2                    => p_rec.amt_year2 );


 hr_utility.set_location('after uom  check ' || p_rec.stat_rsn_cd, 110);
  chk_prtt_reimbmt_stat_apprvd
   (p_prtt_reimbmt_rqst_id        => p_rec.prtt_reimbmt_rqst_id,
    p_aprvd_for_pymt_amt          => p_rec.aprvd_for_pymt_amt ,
    p_prtt_reimbmt_rqst_stat_cd   => p_rec.prtt_reimbmt_rqst_stat_cd  ,
    p_stat_rsn_cd                 => p_rec.stat_rsn_cd   ,
    p_effective_date              => p_effective_date
   ) ;


 hr_utility.set_location('after stat check ' || p_rec.prtt_reimbmt_rqst_stat_cd, 110);
 hr_utility.set_location('after sta check ' || p_rec.stat_rsn_cd, 110);
 hr_utility.set_location('after stat check ' || p_rec.Pymt_stat_cd, 110);
 hr_utility.set_location('after stat check ' || p_rec.pymt_stat_rsn_cd, 110);




   chk_future_dated(
       p_pl_id                    => p_rec.pl_id ,
       p_submitter_person_id      => p_rec.submitter_person_id,
       p_prtt_reimbmt_rqst_id     => p_rec.prtt_reimbmt_rqst_id,
       p_business_group_id        => p_rec.business_group_id,
       p_effective_date           => p_effective_date  );

  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_pl_id                         => p_rec.pl_id,
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
	(p_rec 			 in ben_prc_shd.g_rec_type,
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
 chk_remb_status (
        p_prtt_reimbmt_rqst_stat_cd => ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_stat_cd );

 chk_future_dated(
       p_pl_id                    => ben_prc_shd.g_old_rec.pl_id ,
       p_submitter_person_id      => ben_prc_shd.g_old_rec.submitter_person_id,
       p_prtt_reimbmt_rqst_id     => ben_prc_shd.g_old_rec.prtt_reimbmt_rqst_id,
       p_business_group_id        => ben_prc_shd.g_old_rec.business_group_id,
       p_effective_date           => p_effective_date  );


  dt_delete_validate
    (p_datetrack_mode		=> p_datetrack_mode,
     p_validation_start_date	=> p_validation_start_date,
     p_validation_end_date	=> p_validation_end_date,
     p_prtt_reimbmt_rqst_id		=> p_rec.prtt_reimbmt_rqst_id);
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
  (p_prtt_reimbmt_rqst_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_prtt_reimbmt_rqst_f b
    where b.prtt_reimbmt_rqst_id      = p_prtt_reimbmt_rqst_id
    and   a.business_group_id = b.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.legislation_code%TYPE; --UTF8 varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'prtt_reimbmt_rqst_id',
                             p_argument_value => p_prtt_reimbmt_rqst_id);
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
end ben_prc_bus;

/
