--------------------------------------------------------
--  DDL for Package Body BEN_PDP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PDP_BUS" as
/* $Header: bepdprhi.pkb 120.10.12010000.4 2008/08/05 15:08:01 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_pdp_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------< chk_elig_cvrd_dpnt_id >------|
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
--   elig_cvrd_dpnt_id PK of record being inserted or updated.
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
Procedure chk_elig_cvrd_dpnt_id(p_elig_cvrd_dpnt_id                in number,
                           p_effective_date              in date,
                           p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_elig_cvrd_dpnt_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pdp_shd.api_updating
    (p_effective_date              => p_effective_date,
     p_elig_cvrd_dpnt_id                => p_elig_cvrd_dpnt_id,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_elig_cvrd_dpnt_id,hr_api.g_number)
     <>  ben_pdp_shd.g_old_rec.elig_cvrd_dpnt_id) then
    --
    -- raise error as PK has changed
    --
    ben_pdp_shd.constraint_error('BEN_ELIG_CVRD_DPNT_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_elig_cvrd_dpnt_id is not null then
      --
      -- raise error as PK is not null
      --
      ben_pdp_shd.constraint_error('BEN_ELIG_CVRD_DPNT_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End chk_elig_cvrd_dpnt_id;

--
-- ---------------------------------------------------------------------------
-- |------< chk_ovrdn_flag >------|
-- ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
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
Procedure chk_ovrdn_flag(p_elig_cvrd_dpnt_id                in number,
                            p_ovrdn_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_ovrdn_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pdp_shd.api_updating
    (p_elig_cvrd_dpnt_id                => p_elig_cvrd_dpnt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_ovrdn_flag
      <> nvl(ben_pdp_shd.g_old_rec.ovrdn_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_ovrdn_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_ovrdn_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_ovrdn_flag;

-- ---------------------------------------------------------------------------
-- |----------------------< CHK_CVG_PNDG_FLAG >-------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that the lookup value is valid.
--
-- Pre Conditions
--   None.
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
Procedure chk_cvg_pndg_flag(p_elig_cvrd_dpnt_id                in number,
                            p_cvg_pndg_flag               in varchar2,
                            p_effective_date              in date,
                            p_object_version_number       in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_pndg_flag';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_api_updating := ben_pdp_shd.api_updating
    (p_elig_cvrd_dpnt_id                => p_elig_cvrd_dpnt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);
  --
  if (l_api_updating
      and p_cvg_pndg_flag
      <> nvl(ben_pdp_shd.g_old_rec.cvg_pndg_flag,hr_api.g_varchar2)
      or not l_api_updating) then
    --
    -- check if value of lookup falls within lookup type.
    --
    --
    if hr_api.not_exists_in_hr_lookups
          (p_lookup_type    => 'YES_NO',
           p_lookup_code    => p_cvg_pndg_flag,
           p_effective_date => p_effective_date) then
      --
      -- raise error as does not exist as lookup
      --
      fnd_message.set_name('BEN','BEN_91628_LOOKUP_TYPE_GENERIC');
      fnd_message.set_token('FIELD', p_cvg_pndg_flag);
      fnd_message.set_token('TYPE','YES_NO');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_pndg_flag;
--
-- ----------------------------------------------------------------------------
-- |------< chk_cvg_dates >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to check that cvg start date is less then cvr thru date
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   elig_cvrd_dpnt_id PK of record being inserted or updated.
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
Procedure chk_cvg_dates(p_cvg_strt_dt    in date,
                        p_cvg_thru_dt    in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_cvg_dates';
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  if  p_cvg_strt_dt is not null and p_cvg_thru_dt is not null and
         p_cvg_strt_dt > p_cvg_thru_dt then
      --
      -- raise error as dates are out of seq
      --
      fnd_message.set_name('BEN', 'BEN_91649_CVG_STRT_THRU_DT');
      fnd_message.raise_error;
      --
  --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_cvg_dates;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_dpnt_person_id >------|
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
--   p_elig_cvrd_dpnt_id PK
--   p_dpnt_person_id ID of FK column
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
Procedure chk_dpnt_person_id (p_elig_cvrd_dpnt_id       in number,
                              p_dpnt_person_id          in number,
                              p_prtt_enrt_rslt_id       in number,
                              p_validation_start_date   in date,
                              p_validation_end_date     in date,
                              p_effective_date          in date,
                              p_cvg_strt_dt             in date,
                              p_business_group_id       in number,
                              p_object_version_number   in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_dpnt_person_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_exists       varchar2(1);
  l_exists_2     varchar2(1);
  --
  cursor c3 is
     select null
       from ben_elig_cvrd_dpnt_f ecd
           ,ben_per_in_ler pil
         where ecd.dpnt_person_id = p_dpnt_person_id
           and ecd.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
           and ecd.elig_cvrd_dpnt_id <> nvl(p_elig_cvrd_dpnt_id, hr_api.g_number)
           and ecd.business_group_id = p_business_group_id
           and p_cvg_strt_dt between ecd.cvg_strt_dt and ecd.cvg_thru_dt
           and ecd.cvg_thru_dt <= ecd.effective_end_date
           and ecd.per_in_ler_id = pil.per_in_ler_id(+)
           and nvl(pil.per_in_ler_stat_cd, 'A') not in ('VOIDD', 'BCKDT')
           --and p_validation_start_date <= effective_end_date
           --and p_validation_end_date >= effective_start_date
           ;
  --
  cursor c1 is
    select null
    from   per_all_people_f a
    where  a.person_id = p_dpnt_person_id
      and  a.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pdp_shd.api_updating
     (p_elig_cvrd_dpnt_id       => p_elig_cvrd_dpnt_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating
     and nvl(p_dpnt_person_id,hr_api.g_number)
      <> nvl(ben_pdp_shd.g_old_rec.dpnt_person_id, hr_api.g_number)
     or not l_api_updating) then
    --
    -- check if dpnt_person_id value exists in per_all_people_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in per_all_people
        -- table.
        --
        ben_pdp_shd.constraint_error('BEN_ELIG_CVRD_DPNT_FK1');
        --
      end if;
      --
    close c1;
    --
    if p_prtt_enrt_rslt_id is not null then
      open c3;
      fetch c3 into l_exists_2;
      if c3%found then
        close c3;
        --
        -- raise error as this dependent already exists for this enrt rslt
        --
        fnd_message.set_name('BEN', 'BEN_91651_DUP_CVRD_DPNT');
        fnd_message.raise_error;
        --
      end if;
      close c3;
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_dpnt_person_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_prtt_enrt_rslt_id >------|
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
--   p_elig_cvrd_dpnt_id PK
--   p_prtt_enrt_rslt_id ID of FK column
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
Procedure chk_prtt_enrt_rslt_id (p_elig_cvrd_dpnt_id     in number,
                                 p_prtt_enrt_rslt_id     in number,
                                 p_validation_start_date in date,
                                 p_validation_end_date   in date,
                                 p_effective_date        in date,
                                 p_business_group_id     in number,
                                 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_prtt_enrt_rslt_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  --
  --
  cursor c1 is
    select null
    from   ben_prtt_enrt_rslt_f a
    where  a.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  a.prtt_enrt_rslt_stat_cd is null
      and  a.business_group_id + 0 = p_business_group_id
           and p_validation_start_date <= effective_end_date
           and p_validation_end_date >= effective_start_date
           ;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := ben_pdp_shd.api_updating
     (p_elig_cvrd_dpnt_id       => p_elig_cvrd_dpnt_id,
      p_effective_date          => p_effective_date,
      p_object_version_number   => p_object_version_number);
  --
  if p_prtt_enrt_rslt_id is not null
     and (l_api_updating
            and nvl(p_prtt_enrt_rslt_id, hr_api.g_number)
             <> nvl(ben_pdp_shd.g_old_rec.prtt_enrt_rslt_id, hr_api.g_number)
          or not l_api_updating) then
    --
    -- check if prtt_enrt_rslt_id value exists in ben_prtt_enrt_rslt_f table
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
        --
        close c1;
        --
        -- raise error as FK does not relate to PK in ben_prtt_enrt_rslt_f
        -- table.
        --
        ben_pdp_shd.constraint_error('BEN_ELIG_CVRD_DPNT_FK2');
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
End chk_prtt_enrt_rslt_id;
--
--
-- ----------------------------------------------------------------------------
-- |------< chk_max_num_dpnt >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the number of covered dependents does not
--   exceed the maximum set for the PL or OIPL.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_elig_cvrd_dpnt_id PK
--   p_dpnt_person_id
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
Procedure chk_max_num_dpnt (p_elig_cvrd_dpnt_id      in number,
                            p_prtt_enrt_rslt_id      in number,
                            p_dpnt_person_id         in number,
                            p_cvg_strt_dt            in date,
                            p_cvg_thru_dt            in date,
                            p_effective_date         in date,
                            p_business_group_id      in number,
                            p_object_version_number  in number) is
--
  l_proc         varchar2(72) := g_package||'chk_max_num_dpnt';
  l_api_updating boolean;
--
  l_temp                   varchar2(1);
  l_total_num_dpnt         number(15);
  l_rlshp_num_dpnt         number(15);
  l_person_id              number(15);
  l_pl_id                  number(15);
  l_oipl_id                number(15);
  l_opt_id                 number(15);
  l_contact_type           per_contact_relationships.contact_type%type ; -- UTF8 varchar2(30);
  l_t_mx_dpnts_alwd_num    number(15);
  l_t_no_mx_num_dfnd_flag  varchar2(1);
  l_r_mx_dpnts_alwd_num    number(15);
  l_r_no_mx_num_dfnd_flag  varchar2(1);
  l_dsgn_rqmt_id           number(15);
  l_heir                   number(15);
  --
  --  get required info
  --
  cursor info1_c is
    select r.person_id
          ,r.pl_id
          ,r.oipl_id
          ,o.opt_id
    from   ben_prtt_enrt_rslt_f       r ,
           ben_oipl_f o
    where  r.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
      and  r.prtt_enrt_rslt_stat_cd is null
      and  r.business_group_id + 0 = p_business_group_id
      and  p_effective_date between r.effective_start_date
                                and r.effective_end_date
      and  o.oipl_id(+) = r.oipl_id
      and  o.business_group_id(+)= p_business_group_id
      and  p_effective_date between o.effective_start_date(+)
                                and o.effective_end_date(+)
           ;
  --
  cursor info2_c is
    select c.contact_type
    from   per_contact_relationships  c
    where  c.person_id = l_person_id
      and  c.contact_person_id = p_dpnt_person_id
      -- bug 1762932 added personal_flag
      and  nvl(c.personal_flag,'N') = 'Y'
      and  c.business_group_id + 0 = p_business_group_id
      and  p_effective_date between nvl(c.date_start, p_effective_date)
                                and nvl(c.date_end, p_effective_date)
           ;
  --
  -- total designation requirements
  --
  cursor total_rqmt_c is
    select  mx_dpnts_alwd_num
           ,no_mx_num_dfnd_flag
           ,decode(oipl_id, null, decode(opt_id, null, 3, 2), 1) heir
      from  ben_dsgn_rqmt_f
      where
           ((nvl(pl_id, hr_api.g_number) = l_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = l_oipl_id)
        or (nvl(opt_id, hr_api.g_number) = l_opt_id))
        and dsgn_typ_cd = 'DPNT'
        and grp_rlshp_cd is null
        and business_group_id + 0 = p_business_group_id
        and p_effective_date between effective_start_date
                                 and effective_end_date
        order by heir
           ;

  --
  -- any designation requirements for this comp object?
  --
  cursor any_rqmt_c is
    select 's'
    from ben_dsgn_rqmt_f       r
     where ((nvl(pl_id, hr_api.g_number) = l_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = l_oipl_id)
        or (nvl(opt_id, hr_api.g_number) = l_opt_id))
       and r.dsgn_typ_cd = 'DPNT'
       and r.business_group_id + 0 = p_business_group_id
       and p_effective_date between nvl(r.effective_start_date, p_effective_date)
                                and nvl(r.effective_end_date, p_effective_date)
       ;

  --
  -- designation requirement for relationship type of this dpnt
  --
  cursor rlshp_rqmt_c is
    select r.mx_dpnts_alwd_num
          ,r.no_mx_num_dfnd_flag
          ,r.dsgn_rqmt_id
          ,decode(oipl_id, null, decode(opt_id, null, 3, 2), 1) heir
    from ben_dsgn_rqmt_f       r,
         ben_dsgn_rqmt_rlshp_typ dr
     where ((nvl(pl_id, hr_api.g_number) = l_pl_id)
        or (nvl(oipl_id, hr_api.g_number) = l_oipl_id)
        or (nvl(opt_id, hr_api.g_number) = l_opt_id))
       and r.dsgn_typ_cd = 'DPNT'
       and r.business_group_id + 0 = p_business_group_id
       and p_effective_date between nvl(r.effective_start_date, p_effective_date)
                                and nvl(r.effective_end_date, p_effective_date)
       and dr.dsgn_rqmt_id = r.dsgn_rqmt_id
       and dr.rlshp_typ_cd = l_contact_type
       order by heir
       ;
  --
  -- total number of covered dependents for the result
  --
  cursor total_num_dpnt_c is
    select count(elig_cvrd_dpnt_id)
      from ben_elig_cvrd_dpnt_f
      where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and  cvg_strt_dt is not null
        and  cvg_thru_dt = hr_api.g_eot
        -- and  cvrd_flag = 'Y'
        and  business_group_id + 0 = p_business_group_id
        and  p_effective_date between effective_start_date
                                  and effective_end_date
        and  p_cvg_strt_dt <= nvl(cvg_thru_dt, hr_api.g_date)
        and  nvl(p_cvg_thru_dt, hr_api.g_date) >= cvg_strt_dt
        ;
  --
  --
  -- number of covered dependents of any of the rel types covered
  -- by the appropriate dsgn rqmt.

  cursor rlshp_num_dpnt_c is
    select count(*)
      from  per_contact_relationships c
          , ben_elig_cvrd_dpnt_f  d
      where
             c.person_id = l_person_id
        and  c.contact_person_id = d.dpnt_person_id
        and  d.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
        and  d.cvg_strt_dt is not null
        and  d.cvg_thru_dt = hr_api.g_eot
        and  p_cvg_strt_dt <= nvl(d.cvg_thru_dt, hr_api.g_date)
        and  nvl(p_cvg_thru_dt, hr_api.g_date) >= d.cvg_strt_dt
        and  c.business_group_id + 0 = p_business_group_id
        and  p_effective_date between nvl(c.date_start, p_effective_date)
                                  and nvl(c.date_end, p_effective_date)
        and  d.effective_end_date = hr_api.g_eot  -- bug 1237204
        and  d.business_group_id + 0 = p_business_group_id
        and  c.contact_type in
             (select rlshp_typ_cd
              from ben_dsgn_rqmt_rlshp_typ
              where dsgn_rqmt_id = l_dsgn_rqmt_id)
           ;
  --

Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --

  l_api_updating := ben_pdp_shd.api_updating
    (p_elig_cvrd_dpnt_id           => p_elig_cvrd_dpnt_id,
     p_effective_date              => p_effective_date,
     p_object_version_number       => p_object_version_number);

  -- check that we are inserting a new covered dpnt or updating an
  -- existing not-covered dependent to 'covered'.

  if p_prtt_enrt_rslt_id is not null  and
     p_cvg_strt_dt is not null        and
     p_cvg_thru_dt = hr_api.g_eot     and
     (not l_api_updating or
      ben_pdp_shd.g_old_rec.cvg_strt_dt = null)
     then
    --
    hr_utility.set_location('open info1_c :'||l_proc,10);
    --
    open info1_c;
    --
    fetch info1_c into l_person_id
                       ,l_pl_id
                       ,l_oipl_id
                       ,l_opt_id
                       ;
    --
    if info1_c%notfound then
      --
      close info1_c;
      --
      -- raise error as FK does not relate to PK in ben_prtt_enrt_rslt_f
      -- table.
      --
      ben_pdp_shd.constraint_error('BEN_ELIG_CVRD_DPNT_FK2');
      --
    else
      --
      --
      close info1_c;
      open info2_c;
      fetch info2_c into l_contact_type;
      if info2_c%notfound then
        --
        close info2_c;
        --
        -- raise error as there are no contact relationship
        --
        fnd_message.set_name('BEN', 'BEN_91652_NO_CNTCT_RLSHP');
        fnd_message.raise_error;
        --
      else
        -- Check if there are any requirements at all
        -- Check total max requirement is done as part of post-forms-commit
        -- process. The procedure is chk_max_num_dpnt_for_pen
        null;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,99);
  --
end chk_max_num_dpnt;

--
--
-- ----------------------------------------------------------------------------
-- |------< chk_crt_ordr >------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to enforce that if a dependent has an active court
--   order they can not be uncovered.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   dpnt_person_id
--   cvg_strt_dt
--   cvg_thru_dt
--   business_group_id
--   effective_date effective date
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
Procedure chk_crt_ordr(p_dpnt_person_id          in number,
                       p_cvg_strt_dt             in date,
                       p_cvg_thru_dt             in date,
                       p_business_group_id       in number,
                       p_effective_date          in date) is
  --
  l_proc         varchar2(72) := g_package||'chk_crt_ordr';
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   ben_crt_ordr crt,
           ben_crt_ordr_cvrd_per crc
    where  crc.person_id = p_dpnt_person_id
    and    crc.business_group_id = p_business_group_id
    and    crc.crt_ordr_id = crt.crt_ordr_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
    if p_cvg_thru_dt <> hr_api.g_eot then
    --
    -- check if there is an active court order.
    --
    open c1;
      --
      -- fetch value from cursor if it returns a record then there
      -- is an open court order for the dependent
      --
      fetch c1 into l_dummy;
      if c1%found then
        --
        close c1;
        --
        -- raise error
        --
          fnd_message.set_name('BEN','BEN_92093_DPNT_ACTV_CRTORDR');                        fnd_message.raise_error;
       --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
end chk_crt_ordr;
--
-- ---------------------------------------------------------------------------
-- |------------------------< crt_ordr_warning >----------------------------|
-- ---------------------------------------------------------------------------
-- Procedure used to create warning messages for crt_ordrs.
--
-- Description
--   This procedure is used to create warning messages for persons
--   not designated as covered dependents but reqired to be covered
--   under court orders.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   effective_date effective date
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
PROCEDURE crt_ordr_warning (
   p_prtt_enrt_rslt_id   IN   NUMBER,
   p_effective_date      IN   DATE,
   p_business_group_id   IN   NUMBER
)
IS
   --
   l_proc                  VARCHAR2 (72)     := g_package || 'crt_ordr_warning';
   l_api_updating          BOOLEAN;
   l_level                 VARCHAR2 (30)     := 'PL';
   l_code                  VARCHAR2 (30);
   --
   CURSOR c_rslt
   IS
      SELECT person_id, pgm_id, pl_id, ptip_id, pl_typ_id,
             enrt_cvg_strt_dt, enrt_cvg_thru_dt, per_in_ler_id
        FROM ben_prtt_enrt_rslt_f rslt
       WHERE rslt.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         and rslt.prtt_enrt_rslt_stat_cd is null
         AND rslt.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN rslt.effective_start_date
                                  AND rslt.effective_end_date;
   --
   rslt_person_id          NUMBER (15);
   rslt_pgm_id             NUMBER (15);
   rslt_pl_id              NUMBER (15);
   rslt_ptip_id            NUMBER (15);
   rslt_pl_typ_id          NUMBER (15);
   rslt_enrt_cvg_strt_dt   DATE;
   rslt_enrt_cvg_thru_dt   DATE;
   rslt_per_in_ler_id      NUMBER (15);
   --
   CURSOR c_pgm
   IS
      SELECT dpnt_dsgn_lvl_cd, dpnt_dsgn_cd, pgm_typ_cd
        FROM ben_pgm_f pgm
       WHERE pgm.pgm_id = rslt_pgm_id
         AND pgm.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN pgm.effective_start_date
                                  AND pgm.effective_end_date;
   --
   l_pgm                   c_pgm%ROWTYPE;
   --
   CURSOR c_plan
   IS
      SELECT pl.dpnt_dsgn_cd
        FROM ben_pl_f pl
       WHERE pl.pl_id = rslt_pl_id
         AND pl.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN pl.effective_start_date
                                  AND pl.effective_end_date;
   --
   l_plan                  c_plan%ROWTYPE;
   --
   CURSOR c_ptip
   IS
      SELECT ptip.dpnt_dsgn_cd
        FROM ben_ptip_f ptip
       WHERE ptip.ptip_id = rslt_ptip_id
         AND ptip.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN ptip.effective_start_date
                                  AND ptip.effective_end_date;
   --
   l_ptip                  c_ptip%ROWTYPE;
   --
   CURSOR c_plan_flag
   IS
      SELECT pl.alws_qmcso_flag, pl.alws_qdro_flag, pl.pl_typ_id
        FROM ben_pl_f pl
       WHERE pl.pl_id = rslt_pl_id
         AND pl.business_group_id = p_business_group_id
         AND p_effective_date BETWEEN pl.effective_start_date
                                  AND pl.effective_end_date;
   --
   l_alws_qmcso            VARCHAR2 (30);
   l_alws_qdro             VARCHAR2 (30);
   l_pl_typ_id_pl          NUMBER (15);
   l_benefit_name          ben_pl_typ_f.NAME%TYPE;
   --
   l_lf_evt_ocrd_dt    DATE;
   --
   CURSOR c_lf_evt_ocrd_dt
   IS
      SELECT lf_evt_ocrd_dt
        FROM ben_per_in_ler pil
       WHERE pil.per_in_ler_id = rslt_per_in_ler_id;
   --
   CURSOR c_crt_ordr
      IS
         SELECT per.first_name || ' ' || per.last_name NAME, lkp.meaning,
                cvr.person_id, bpl.NAME, crt.CRT_ORDR_TYP_CD
           FROM ben_crt_ordr crt,
                ben_crt_ordr_cvrd_per cvr,
                per_all_people_f per,
                per_contact_relationships con,
                hr_lookups lkp,
                ben_pl_f bpl
          WHERE crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
            AND crt.person_id = rslt_person_id
            AND crt.pl_id = rslt_pl_id
            AND crt.crt_ordr_id = cvr.crt_ordr_id
            AND cvr.person_id = per.person_id
            AND cvr.person_id = con.contact_person_id
            AND con.contact_type = lkp.lookup_code
            AND lkp.lookup_type = 'CONTACT'
            AND p_effective_date BETWEEN NVL (lkp.start_date_active,
                                              p_effective_date
                                             )
                                     AND NVL (lkp.end_date_active,
                                              p_effective_date
                                             )
            AND GREATEST (l_lf_evt_ocrd_dt, rslt_enrt_cvg_strt_dt)
                                      BETWEEN GREATEST
                                                       (NVL (apls_perd_strtg_dt,
                                                             p_effective_date
                                                            ),
                                                        NVL (detd_qlfd_ordr_dt,
                                                             apls_perd_strtg_dt
                                                            )
                                                       )
                                           AND NVL (apls_perd_endg_dt,
                                                    rslt_enrt_cvg_thru_dt
                                                   )
            AND crt.business_group_id = p_business_group_id
            AND cvr.business_group_id = p_business_group_id
            AND p_effective_date BETWEEN NVL (con.date_start, p_effective_date)
                                     AND NVL (con.date_end, p_effective_date)
            AND con.business_group_id = p_business_group_id
            AND bpl.pl_id = rslt_pl_id
            AND p_effective_date BETWEEN NVL (bpl.effective_start_date,
                                              p_effective_date
                                             )
                                     AND NVL (bpl.effective_end_date,
                                              p_effective_date
                                             )
         UNION
         SELECT per.first_name || ' ' || per.last_name NAME, lkp.meaning,
                cvr.person_id, bpt.NAME, crt.CRT_ORDR_TYP_CD
           FROM ben_crt_ordr crt,
                ben_crt_ordr_cvrd_per cvr,
                per_all_people_f per,
                per_contact_relationships con,
                hr_lookups lkp,
                ben_pl_typ_f bpt
          WHERE crt.crt_ordr_typ_cd IN ('QMCSO','QDRO')
            AND crt.person_id = rslt_person_id
            AND crt.pl_typ_id = l_pl_typ_id_pl
            AND crt.crt_ordr_id = cvr.crt_ordr_id
            AND cvr.person_id = per.person_id
            AND cvr.person_id = con.contact_person_id
            AND con.contact_type = lkp.lookup_code
            AND lkp.lookup_type = 'CONTACT'
            AND p_effective_date BETWEEN NVL (lkp.start_date_active,
                                              p_effective_date
                                             )
                                     AND NVL (lkp.end_date_active,
                                              p_effective_date
                                             )
            AND GREATEST(l_lf_evt_ocrd_dt, rslt_enrt_cvg_strt_dt)
                                       BETWEEN GREATEST
                                                       (NVL (apls_perd_strtg_dt,
                                                             p_effective_date
                                                            ),
                                                        NVL (detd_qlfd_ordr_dt,
                                                             apls_perd_strtg_dt
                                                            )
                                                       )
                                           AND NVL (apls_perd_endg_dt,
                                                    rslt_enrt_cvg_thru_dt
                                                   )
            AND crt.business_group_id = p_business_group_id
            AND cvr.business_group_id = p_business_group_id
            AND p_effective_date BETWEEN NVL (con.date_start, p_effective_date)
                                     AND NVL (con.date_end, p_effective_date)
            AND con.business_group_id = p_business_group_id
            AND bpt.pl_typ_id = l_pl_typ_id_pl
            AND p_effective_date BETWEEN NVL (bpt.effective_start_date,
                                              p_effective_date
                                             )
                                     AND NVL (bpt.effective_end_date,
                                              p_effective_date
                                             );

   --
   l_name                  VARCHAR2 (500);
   l_contact_type          per_contact_relationships.contact_type%TYPE;
   l_dpnt_id               NUMBER (15);
   l_crt_ordr_typ_cd       VARCHAR2(30);
   l_crt_ordr_meaning      VARCHAR2(80);
   --
   --
   -- Bug 4718038 : Check PDP record for court order warning as of life event occurred date
   --
   CURSOR c_elig_dpnt
   IS
      SELECT NULL
        FROM ben_elig_cvrd_dpnt_f pdp, ben_per_in_ler pil
       WHERE pdp.dpnt_person_id = l_dpnt_id
         AND pdp.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
         AND p_effective_date BETWEEN pdp.effective_start_date
                                  AND pdp.effective_end_date
         AND GREATEST(pil.lf_evt_ocrd_dt, rslt_enrt_cvg_strt_dt ) BETWEEN cvg_strt_dt
                                                                      AND cvg_thru_dt
         AND pdp.business_group_id = p_business_group_id
         AND pil.business_group_id = p_business_group_id
         AND pdp.per_in_ler_id = pil.per_in_ler_id;

   --
   l_dummy                 VARCHAR2 (1);
   l_message               fnd_new_messages.message_name%TYPE      := 'BEN_92430_CRT_ORD_WARNING';
   l_cobra_pgm             BOOLEAN                                 := FALSE;
--
BEGIN
   --
   hr_utility.set_location ('Entering:' || l_proc, 5);
   --
   hr_utility.set_location ('Checking court order at PDP level : ' || p_prtt_enrt_Rslt_id, 12);
   --
   IF p_prtt_enrt_rslt_id IS NOT NULL
   THEN
      --
      OPEN c_rslt;
      --
      FETCH c_rslt INTO rslt_person_id,
                        rslt_pgm_id,
                        rslt_pl_id,
                        rslt_ptip_id,
                        rslt_pl_typ_id,
                        rslt_enrt_cvg_strt_dt,
                        rslt_enrt_cvg_thru_dt,
                        rslt_per_in_ler_id;
      --
      IF c_rslt%FOUND
      THEN
         --
         IF rslt_pgm_id IS NOT NULL
         THEN
            --
            -- find the level from the program
            --
            OPEN c_pgm;
            --
               FETCH c_pgm INTO l_pgm;
               --
               IF c_pgm%NOTFOUND
               THEN
                  --
                  CLOSE c_pgm;

                  fnd_message.set_name ('BEN', 'BEN_91470_PGM_NOT_FOUND');
                  fnd_message.raise_error;
               --
               END IF;
               --
            CLOSE c_pgm;
            --
            l_level := l_pgm.dpnt_dsgn_lvl_cd;
            --
            IF l_pgm.pgm_typ_cd IN ('COBRANFLX', 'COBRAFLX')
            THEN
               --
               l_cobra_pgm := TRUE;
               --
            END IF;
            --
         ELSE
            --
            -- PLAN level
            --
            l_level := 'PL';
            --
         END IF;
         --
         -- Retrieve designation code
         --
         hr_utility.set_location ('Level = ' || l_level, 40);
         --
         IF l_level = 'PGM'
         THEN
            --
            l_code := l_pgm.dpnt_dsgn_cd;
            --
         ELSIF l_level = 'PTIP'
         THEN
            --
            OPEN c_ptip;
               --
               FETCH c_ptip INTO l_ptip;
               --
               IF c_ptip%NOTFOUND
               THEN
                  --
                  CLOSE c_ptip;

                  fnd_message.set_name ('BEN', 'BEN_91471_MISSING_PLAN_TYPE');
                  fnd_message.raise_error;
               --
               END IF;
               --
            CLOSE c_ptip;
            --
            l_code := l_ptip.dpnt_dsgn_cd;
            --
         ELSIF l_level = 'PL'
         THEN
            --
            OPEN c_plan;
               --
               FETCH c_plan INTO l_plan;
               --
               IF c_plan%NOTFOUND
               THEN
                  --
                  CLOSE c_plan;
                  --
                  fnd_message.set_name ('BEN', 'BEN_91472_PLAN_NOT_FOUND');
                  fnd_message.raise_error;
               --
               END IF;
               --
            CLOSE c_plan;
            --
            l_code := l_plan.dpnt_dsgn_cd;
            --
         ELSE
            --
            l_code := NULL;
            --
         END IF;
         --
         hr_utility.set_location ('dsgn code = ' || l_code, 40);
         --
         IF l_code IS NOT NULL AND
            NOT l_cobra_pgm
         THEN
            --
            OPEN c_plan_flag;
               --
               FETCH c_plan_flag INTO l_alws_qmcso,
                                      l_alws_qdro,
                                      l_pl_typ_id_pl;
               --
               IF c_plan_flag%NOTFOUND
               THEN
                  --
                  CLOSE c_plan_flag;
                  --
                  fnd_message.set_name ('BEN', 'BEN_91472_PLAN_NOT_FOUND');
                  fnd_message.raise_error;
                  --
               END IF;
               --
            CLOSE c_plan_flag;
            --
            OPEN c_lf_evt_ocrd_dt;
               --
               FETCH c_lf_evt_ocrd_dt into l_lf_evt_ocrd_dt;
               --
            CLOSE c_lf_evt_ocrd_dt;
            --
            /*
            hr_utility.set_location('ACE l_lf_evt_ocrd_dt = ' || l_lf_evt_ocrd_dt, 9999);
            hr_utility.set_location('ACE rslt_enrt_cvg_strt_dt = ' || rslt_enrt_cvg_strt_dt, 9999);
            hr_utility.set_location('ACE p_prtt_enrt_rslt_id = ' || p_prtt_enrt_rslt_id, 9999);
            hr_utility.set_location('ACE p_effective_date = ' || p_effective_date, 9999);
            */

            OPEN c_crt_ordr;
            --
            LOOP
               --
               FETCH c_crt_ordr INTO l_name,
                                     l_contact_type,
                                     l_dpnt_id,
                                     l_benefit_name,
                                     l_crt_ordr_typ_cd;
               --
               EXIT WHEN c_crt_ordr%NOTFOUND;
               --
               hr_utility.set_location('Court Order Found', 9999);
               /*
               hr_utility.set_location ('dpnt name = ' || l_name, 40);
               hr_utility.set_location ('type = ' || l_contact_type, 40);
               hr_utility.set_location ('dpnt id = ' || l_dpnt_id, 40);
               */
               --
               OPEN c_elig_dpnt;
                  --
                  FETCH c_elig_dpnt INTO l_dummy;
                  --
                  IF c_elig_dpnt%NOTFOUND
                  THEN
                     --
                     hr_utility.set_location('C_ELIG_DPNT Returned No Rows', 9999);
                     --
                     l_crt_ordr_meaning := hr_general.decode_lookup
                                          (p_lookup_type                 => 'BEN_CRT_ORDR_TYP',
                                           p_lookup_code                 => l_crt_ordr_typ_cd
                                          );
                     --
                     ben_warnings.load_warning
                                          (p_application_short_name      => 'BEN',
                                           p_message_name                => l_message,
                                           p_parma                       => l_benefit_name,
                                           p_parmb                       => l_contact_type || ' , ' || l_name,
                                           p_parmc                       => l_crt_ordr_meaning,
                                           p_person_id                   => rslt_person_id
                                          );
                  --
                  END IF;
                  --
               CLOSE c_elig_dpnt;
               --
            END LOOP;
            --
            CLOSE c_crt_ordr;
            --
         END IF;
         --
      END IF;
      --
      CLOSE c_rslt;
      --
   END IF;

   hr_utility.set_location ('Leaving:' || l_proc, 10);
END crt_ordr_warning;

-- ---------------------------------------------------------------------------
-- |------------------------< crt_ordr_warning_ss >----------------------------|
-- ---------------------------------------------------------------------------
-- Function is called from SS to check court order(s) for a dependent.
--
-- In Parameters
--   p_prtt_enrt_rslt_id PK of enrollment record
--   p_enrt_cvg_strt_dt  Enrollment coverage start date
--   p_person_id         PK of person
--   p_dpnt_person_id    PK of contact person
--   p_pl_id             PK of plan to query for court order
--   p_pl_typ_id         PK of plan type to query for court order
--   p_effective_date    Effective date
--   p_per_in_ler_id     PK of person LE
--   p_business_group_id Business group in which we need to query for court order(s)
--
-- Out Parameters
--   l_return            Y/N Flag denoting whether court order(s) exist
--                       for above IN parameters
--
Function  crt_ordr_warning_ss
          (p_prtt_enrt_rslt_id   in number
					,p_enrt_cvg_strt_dt    in date
					,p_enrt_cvg_thru_dt    in date
					,p_person_id           in number
					,p_dpnt_person_id      in number
					,p_pl_id               in number
					,p_pl_typ_id           in number
          ,p_effective_date      in date
					,p_per_in_ler_id       in number
          ,p_business_group_id   in number)
Return VARCHAR2 is
--
cursor c_leod is
	select lf_evt_ocrd_dt
	from   ben_per_in_ler
	where  per_in_ler_id = p_per_in_ler_id;
--
cursor   c_crt_ordr(p_lf_evt_ocrd_dt date) is
  select 'Y'
  from   ben_crt_ordr crt,
         ben_crt_ordr_cvrd_per cvr
  where  crt.crt_ordr_typ_cd in ('QMCSO','QDRO')
  and    crt.person_id = p_person_id
  and    (crt.pl_id = p_pl_id or crt.pl_typ_id = p_pl_typ_id)
  and    crt.crt_ordr_id = cvr.crt_ordr_id
  and    cvr.person_id = p_dpnt_person_id
  and    (greatest(p_enrt_cvg_strt_dt, p_lf_evt_ocrd_dt) between greatest(nvl(crt.apls_perd_strtg_dt,p_effective_date)
                                              ,nvl(crt.detd_qlfd_ordr_dt,crt.apls_perd_strtg_dt))
                            and    nvl(crt.apls_perd_endg_dt,p_enrt_cvg_thru_dt))
  and    crt.business_group_id = p_business_group_id
  and    cvr.business_group_id = p_business_group_id;
--
	l_leod   date;
  l_return VARCHAR2(1) := 'N';
Begin
	--
	open c_leod;
	fetch c_leod into l_leod;
	close c_leod;
  --
	open c_crt_ordr(l_leod);
	fetch c_crt_ordr into l_return;
	close c_crt_ordr;

	return l_return;
	--
End crt_ordr_warning_ss;
--
/*--Bug#5088571
-- ---------------------------------------------------------------------------
-- |------------------------< chk_dpnt_strt_end_dt >----------------------------|
-- ---------------------------------------------------------------------------
-- Description
--   This procedure is used to check whether the Rate Start date is greater than Rate End date.
--

procedure chk_dpnt_strt_end_dt
                         (p_cvg_strt_dt                in date,
                       	  p_cvg_thru_dt                in date,
			  p_prtt_enrt_rslt_id          in number
        		  ) is
--
  l_proc         varchar2(72) := g_package||'chk_dpnt_strt_end_dt';
  l_person_id    number;
  l_message_name varchar2(500) := 'BEN_94592_RT_STRT_GT_END_DT';
--
cursor c_person_id is
 select person_id
 from   ben_prtt_enrt_rslt_f pen
 where  pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open c_person_id;
  fetch c_person_id into l_person_id;
  close c_person_id;
  --
  if p_cvg_strt_dt > p_cvg_thru_dt then
     benutils.write(p_text=>fnd_message.get);
     ben_warnings.load_warning
           (p_application_short_name  => 'BEN'
            ,p_message_name            => l_message_name
            ,p_parma                   => 'Dependent Coverage End Date' || ' ' || fnd_date.date_to_displaydate(p_cvg_thru_dt)
	    ,p_parmb    	       => 'Dependent Coverage Start Date' ||' '|| fnd_date.date_to_displaydate(p_cvg_strt_dt)
	    ,p_person_id               =>  l_person_id
	    );
  end if;
 --
  hr_utility.set_location('Leaving:'||l_proc,10);
 --
end chk_dpnt_strt_end_dt;
--
----Bug#5088571*/
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
            (p_prtt_enrt_rslt_id             in number default hr_api.g_number,
	       p_datetrack_mode		         in varchar2,
             p_validation_start_date	   in date,
             p_validation_end_date	         in date) Is
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
   /*
    If ((nvl(p_prtt_enrt_rslt_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'ben_prtt_enrt_rslt_f',
             p_base_key_column => 'prtt_enrt_rslt_id',
             p_base_key_value  => p_prtt_enrt_rslt_id,
             p_from_date       => p_validation_start_date,
             p_to_date         => p_validation_end_date)))  Then
      l_table_name := 'ben_prtt_enrt_rslt_f';
      Raise l_integrity_error;
    End If;
   */
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
    -- ben_utility.parent_integrity_error(p_table_name => l_table_name);
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
            (p_elig_cvrd_dpnt_id		in number,
             p_datetrack_mode		      in varchar2,
	       p_validation_start_date	in date,
	       p_validation_end_date	      in date) Is
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
       p_argument       => 'elig_cvrd_dpnt_id',
       p_argument_value => p_elig_cvrd_dpnt_id);
    --
    If (dt_api.rows_exist
          (p_base_table_name => 'ben_cvrd_dpnt_ctfn_prvdd_f',
           p_base_key_column => 'elig_cvrd_dpnt_id',
           p_base_key_value  => p_elig_cvrd_dpnt_id,
           p_from_date       => p_validation_start_date,
           p_to_date         => p_validation_end_date)) Then
      l_table_name := 'ben_cvrd_dpnt_ctfn_prvdd_f';
      Raise l_rows_exist;
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
    -- ben_utility.child_exists_error(p_table_name => l_table_name);
    --
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
	(p_rec 			 in ben_pdp_shd.g_rec_type,
	 p_effective_date	       in date,
	 p_datetrack_mode	       in varchar2,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_cvrd_dpnt_id
  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_max_num_dpnt
  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_dpnt_person_id        => p_rec.dpnt_person_id,
   p_cvg_strt_dt           => p_rec.cvg_strt_dt,
   p_cvg_thru_dt           => p_rec.cvg_thru_dt,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
  --
  --chk_cvg_dates
  --(p_cvg_strt_dt           => p_rec.cvg_strt_dt,
  -- p_cvg_thru_dt           => p_rec.cvg_thru_dt);
  --
  chk_dpnt_person_id
  (p_elig_cvrd_dpnt_id      => p_rec.elig_cvrd_dpnt_id,
   p_dpnt_person_id         => p_rec.dpnt_person_id,
   p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id,
   p_validation_start_date  => p_validation_start_date,
   p_validation_end_date    => p_validation_end_date,
   p_effective_date         => p_effective_date,
   p_cvg_strt_dt            => p_rec.cvg_strt_dt,
   p_business_group_id      => p_rec.business_group_id,
   p_object_version_number  => p_rec.object_version_number);
  --
--
--  chk_prtt_enrt_rslt_id
--  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
--   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
--   p_validation_start_date => p_validation_start_date,
--   p_validation_end_date   => p_validation_end_date,
--   p_effective_date        => p_effective_date,
--   p_business_group_id     => p_rec.business_group_id,
--   p_object_version_number => p_rec.object_version_number);

  --
  chk_ovrdn_flag
  (p_elig_cvrd_dpnt_id          => p_rec.elig_cvrd_dpnt_id,
   p_ovrdn_flag         => p_rec.ovrdn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  chk_cvg_pndg_flag
  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_cvg_pndg_flag            => p_rec.cvg_pndg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);
  --
  /*
  Bug 3756863 : Moved to POST_INSERT
  --
  crt_ordr_warning
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  */
  --
/* chk_dpnt_strt_end_dt
 (p_cvg_strt_dt          =>   p_rec.cvg_strt_dt,
  p_cvg_thru_dt          =>   p_rec.cvg_thru_dt,
  p_prtt_enrt_rslt_id    =>   p_rec.prtt_enrt_rslt_id);   */
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in ben_pdp_shd.g_rec_type,
	 p_effective_date	       in date,
	 p_datetrack_mode	       in varchar2,
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_elig_cvrd_dpnt_id
  (p_elig_cvrd_dpnt_id          => p_rec.elig_cvrd_dpnt_id,
   p_effective_date             => p_effective_date,
   p_object_version_number      => p_rec.object_version_number);
  --
  --
  chk_max_num_dpnt
  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_dpnt_person_id        => p_rec.dpnt_person_id,
   p_cvg_strt_dt           => p_rec.cvg_strt_dt,
   p_cvg_thru_dt           => p_rec.cvg_thru_dt,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id,
   p_object_version_number => p_rec.object_version_number);
 --
  chk_dpnt_person_id
  (p_elig_cvrd_dpnt_id       => p_rec.elig_cvrd_dpnt_id,
   p_dpnt_person_id          => p_rec.dpnt_person_id,
   p_prtt_enrt_rslt_id       => p_rec.prtt_enrt_rslt_id,
   p_validation_start_date   => p_validation_start_date,
   p_validation_end_date     => p_validation_end_date,
   p_effective_date          => p_effective_date,
   p_cvg_strt_dt             => p_rec.cvg_strt_dt,
   p_business_group_id       => p_rec.business_group_id,
   p_object_version_number   => p_rec.object_version_number);
  --
--
--  chk_prtt_enrt_rslt_id
--  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
--   p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
--   p_validation_start_date => p_validation_start_date,
--   p_validation_end_date   => p_validation_end_date,
--   p_effective_date        => p_effective_date,
--   p_business_group_id     => p_rec.business_group_id,
--   p_object_version_number => p_rec.object_version_number);
  --
  chk_ovrdn_flag
  (p_elig_cvrd_dpnt_id          => p_rec.elig_cvrd_dpnt_id,
   p_ovrdn_flag         => p_rec.ovrdn_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  chk_cvg_pndg_flag
  (p_elig_cvrd_dpnt_id     => p_rec.elig_cvrd_dpnt_id,
   p_cvg_pndg_flag            => p_rec.cvg_pndg_flag,
   p_effective_date        => p_effective_date,
   p_object_version_number => p_rec.object_version_number);

  --
--  chk_crt_ordr
--  (p_dpnt_person_id     => p_rec.dpnt_person_id,
--   p_cvg_strt_dt        => p_rec.cvg_strt_dt,
--   p_cvg_thru_dt        => p_rec.cvg_thru_dt,
--   p_business_group_id  => p_rec.business_group_id,
--   p_effective_date     => p_effective_date);
  --
  /*
  --
  Bug 3756863 : Moved to POST_UPDATE
  crt_ordr_warning
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  */
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_prtt_enrt_rslt_id      => p_rec.prtt_enrt_rslt_id,
     p_datetrack_mode              => p_datetrack_mode,
     p_validation_start_date	     => p_validation_start_date,
     p_validation_end_date	     => p_validation_end_date);
  --
/* chk_dpnt_strt_end_dt
 (p_cvg_strt_dt          =>   p_rec.cvg_strt_dt,
  p_cvg_thru_dt          =>   p_rec.cvg_thru_dt,
  p_prtt_enrt_rslt_id    =>   p_rec.prtt_enrt_rslt_id);   */
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_validate
	(p_rec 			 in ben_pdp_shd.g_rec_type,
	 p_effective_date	       in date,
	 p_datetrack_mode	       in varchar2,
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
     p_elig_cvrd_dpnt_id	=> p_rec.elig_cvrd_dpnt_id);
  --
  /*
  --
  Bug 3756863 : Moved to POST_DELETE
  crt_ordr_warning
  (p_prtt_enrt_rslt_id     => p_rec.prtt_enrt_rslt_id,
   p_effective_date        => p_effective_date,
   p_business_group_id     => p_rec.business_group_id);
  */
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_elig_cvrd_dpnt_id in number) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select a.legislation_code
    from   per_business_groups a,
           ben_elig_cvrd_dpnt_f b
    where b.elig_cvrd_dpnt_id      = p_elig_cvrd_dpnt_id
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
                             p_argument       => 'elig_cvrd_dpnt_id',
                             p_argument_value => p_elig_cvrd_dpnt_id);
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
end ben_pdp_bus;

/
