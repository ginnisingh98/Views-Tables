--------------------------------------------------------
--  DDL for Package Body BEN_DETERMINE_ELIGIBILITY3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DETERMINE_ELIGIBILITY3" as
/* $Header: bendete3.pkb 120.4.12000000.1 2007/01/19 15:44:49 appldev noship $ */
--
-- -----------------------------------------------------
--  This procedure checks the designation requirements
--  for dependent eligibility and verifying family members
--  for participant eligibility.
-- -----------------------------------------------------
--
procedure check_dsgn_rqmts(p_oipl_id           in  number,
                           p_pl_id             in  number,
                           p_opt_id            in  number,
                           p_person_id         in  number,
                           p_business_group_id in  number,
                           p_lf_evt_ocrd_dt    in  date,
                           p_effective_date    in  date,
                           p_vrfy_fmm          in  boolean,
                           p_dpnt_elig_flag    out nocopy varchar2) is
  --
  l_proc              varchar2(100):= 'ben_determine_eligibility3.check_dsgn_rqmts';
  l_exists            varchar2(30);
  l_dpnt_elig_flag    varchar2(1) := 'Y';
  l_rlshp_count       number := 0;
  l_found_rows        boolean := FALSE;
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM
  --
  cursor   c_dsgn is
    select *
    from   ben_dsgn_rqmt_f ddr
    where  (ddr.oipl_id = p_oipl_id
            or ddr.pl_id = p_pl_id
            or ddr.opt_id = p_opt_id)
    and    ddr.dsgn_typ_cd = 'DPNT'
    and    ddr.business_group_id  = p_business_group_id
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt,p_effective_date))
           between ddr.effective_start_date
           and     ddr.effective_end_date;
    --
  cursor   c_get_rlshp_typ(p_dsgn_rqmt_id in number) is
    select *
    from   ben_dsgn_rqmt_rlshp_typ drr
    where  drr.dsgn_rqmt_id = p_dsgn_rqmt_id
    and    drr.business_group_id  = p_business_group_id;
    --
  cursor c_dsgn_rl_typ(p_mn_dpnts_rqd_num in number
                      ,p_dsgn_rqmt_id     in number) is
    select null
    from   per_contact_relationships ctr,
           per_all_people_f ppf
    where  ctr.person_id = p_person_id
    and    ctr.personal_flag = 'Y'
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt, p_effective_date))
           between nvl(ctr.date_start, hr_api.g_sot)
           and     nvl(ctr.date_end, hr_api.g_eot)
    and    ctr.business_group_id = p_business_group_id
    and    ctr.contact_person_id = ppf.person_id
    and    nvl(l_fonm_cvg_strt_dt,nvl(p_lf_evt_ocrd_dt, p_effective_date))
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    (ctr.contact_type in
                (select rlshp_typ_cd drr
                 from ben_dsgn_rqmt_rlshp_typ drr
                 where drr.dsgn_rqmt_id = p_dsgn_rqmt_id
                 and   drr.business_group_id = p_business_group_id)
           or not exists (select null
                          from ben_dsgn_rqmt_rlshp_typ drr
                          where drr.dsgn_rqmt_id = p_dsgn_rqmt_id
                          and   drr.business_group_id = p_business_group_id))
    having count(*) >= nvl(p_mn_dpnts_rqd_num, 0);
    --
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);

  hr_utility.set_location('p_oipl_id ' || p_oipl_id  ,99 ) ;
  hr_utility.set_location('p_pl_id  '  || p_pl_id    ,99 );
  hr_utility.set_location('p_opt_id '  || p_opt_id   , 99 ) ;
  -- hr_utility.set_location('Entering ' || l_package,10);
  --FONM
  if ben_manage_life_events.fonm = 'Y'
     and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
    --
    l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
    --
  end if;
  --END FONM
  --
  -- Check if designation requirements are met.
  -- The person must have the contact type(s)
  -- and minimum number of contacts defined.
  --
  for l_ddr_rec in c_dsgn loop
    --
    if p_vrfy_fmm then
      --
      open c_dsgn_rl_typ(l_ddr_rec.mn_dpnts_rqd_num,
                       l_ddr_rec.dsgn_rqmt_id);
      fetch c_dsgn_rl_typ into l_exists;
      if c_dsgn_rl_typ%notfound then
        close c_dsgn_rl_typ;
        l_dpnt_elig_flag := 'N';
        exit;
      end if;
      --
      close c_dsgn_rl_typ;
      --
    else
    --
    --  Get all relationship types and check if the eligible
    --  dependents meets the designation requirements.
    --
      l_rlshp_count := 0;
      l_found_rows := FALSE;
      --
      for l_drr_rec in c_get_rlshp_typ(l_ddr_rec.dsgn_rqmt_id) loop
        l_found_rows := TRUE;
        --
        --  The number of eligible dependents must have the right
        --  relationship type;
        --
        if ben_determine_eligibility.g_elig_dpnt_rec.first is not null then
          for l_counter in ben_determine_eligibility.g_elig_dpnt_rec.first..ben_determine_eligibility.g_elig_dpnt_rec.last loop
            if ben_determine_eligibility.g_elig_dpnt_rec(l_counter).contact_type = l_drr_rec.rlshp_typ_cd then
              l_rlshp_count := l_rlshp_count + 1;
            end if;
            --
          end loop;
        end if;
      end loop;
      --
      hr_utility.set_location( ' count ' || l_rlshp_count , 99 );
      --  If there are no relationship rows, then the number of dependents
      --  must meet the minimum number required for the comp object.
      --
      if l_found_rows = false then
       if ben_determine_eligibility.g_elig_dpnt_rec.count < nvl(l_ddr_rec.mn_dpnts_rqd_num,0) then
         l_dpnt_elig_flag := 'N';
         exit;
       end if;
      else
        if l_rlshp_count < nvl(l_ddr_rec.mn_dpnts_rqd_num,0) then
          l_dpnt_elig_flag := 'N';
          exit;
        end if;
       --
      end if;
      --
    end if;
    --
  end loop;
  --
  p_dpnt_elig_flag := l_dpnt_elig_flag;
  --
  hr_utility.set_location('Leaving: '||l_proc,20);
  --
end check_dsgn_rqmts;
--
-- -----------------------------------------------------------------------------
-- |--------------------< get_prtn_st_dt_aftr_wtg >----------------------------|
-- -----------------------------------------------------------------------------
--
-- This function applies the prtn_eff_strt_dt_cd to the waiting period end date
-- and returns the computed date.
--
function get_prtn_st_dt_aftr_wtg
  (p_person_id           in     number
  ,p_effective_date      in     date
  ,p_business_group_id   in     number
  ,p_prtn_eff_strt_dt_cd in     varchar2
  ,p_prtn_eff_strt_dt_rl in     number
  ,p_wtg_perd_cmpltn_dt  in     date
  ,p_pl_id               in     number
  ,p_pl_typ_id           in     number
  ,p_pgm_id              in     number
  ,p_oipl_id             in     number
  ,p_plip_id             in     number
  ,p_ptip_id             in     number
  ,p_opt_id              in     number
  )
return date
is
  --
  l_return_date       date;
  l_outputs           ff_exec.outputs_t;
  --
  l_proc              varchar2(80) := 'ben_determine_eligibility3.get_prtn_st_dt_aftr_wtg';
  l_ptip_rec          ben_ptip_f%rowtype;
  l_plip_rec          ben_plip_f%rowtype;
  l_ass_rec           per_all_assignments_f%rowtype;
  l_loc_rec           hr_locations_all%rowtype;
  l_pil_rec           ben_per_in_ler%rowtype;
  l_jurisdiction_code varchar2(30);
  --
  --FONM
  l_fonm_cvg_strt_dt DATE ;
  --END FONM

begin
  --
  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
    hr_utility.set_location('Entering : ' || l_proc, 10);
  end if;
  --
  if ben_manage_life_events.fonm = 'Y'
      and ben_manage_life_events.g_fonm_cvg_strt_dt is not null then
     --
     l_fonm_cvg_strt_dt := ben_manage_life_events.g_fonm_cvg_strt_dt ;
     --
  end if;
  --
  if p_plip_id is not null then
    --
    ben_comp_object.get_object(p_plip_id => p_plip_id,
                               p_rec     => l_plip_rec);
    --
  elsif p_ptip_id is not null then
    --
    ben_comp_object.get_object(p_ptip_id => p_ptip_id,
                               p_rec     => l_ptip_rec);
    --
  end if;
  --
  if p_prtn_eff_strt_dt_cd <> 'RL' then
    --
    -- Pass the wtg_perd_cmpltn_dt as the lf_evt_ocrd_dt to ben_determine_date
    -- This will cause the calculation to be based on p_wtg_perd_cmpltn_dt.
    --
    ben_determine_date.main
      (p_date_cd           => p_prtn_eff_strt_dt_cd,
       p_person_id         => p_person_id,
       p_pgm_id            => nvl(p_pgm_id,l_ptip_rec.pgm_id),
       p_pl_id             => nvl(p_pl_id,l_plip_rec.pl_id),
       p_oipl_id           => p_oipl_id,
       p_business_group_id => p_business_group_id,
       p_lf_evt_ocrd_dt    => p_wtg_perd_cmpltn_dt,
       p_start_date        => null,
       p_effective_date    => p_effective_date,
       p_returned_date     => l_return_date);
    --
  elsif p_prtn_eff_strt_dt_cd = 'RL' then
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_ass_rec);
    --
    if l_ass_rec.assignment_id is null then
      --
      ben_person_object.get_benass_object(p_person_id => p_person_id,
                                          p_rec       => l_ass_rec);
      --
    end if;
    --
    ben_person_object.get_object(p_person_id => p_person_id,
                                 p_rec       => l_pil_rec);
    --
    if l_ass_rec.location_id is not null then
      --
      ben_location_object.get_object(p_location_id => l_ass_rec.location_id,
                                     p_rec         => l_loc_rec);
      --
--      if l_loc_rec.region_2 is not null then
        --
--       l_jurisdiction_code :=
--         pay_mag_utils.lookup_jurisdiction_code
--          (p_state => l_loc_rec.region_2);
        --
--     end if;
      --
    end if;
    --
    -- Get the date from calling a fast formula rule
    --
    -- Rule = Participation Eligibility Start Date (ID = -82)
    --
    -- Call formula initialise routine
    --
    l_outputs := benutils.formula
       (p_formula_id        => p_prtn_eff_strt_dt_rl,
        p_effective_date    => p_effective_date,
        p_business_group_id => p_business_group_id,
        p_assignment_id     => l_ass_rec.assignment_id,
        p_organization_id   => l_ass_rec.organization_id,
        p_pl_id             => nvl(p_pl_id,l_plip_rec.pl_id),
        p_pl_typ_id         => p_pl_typ_id,
        p_pgm_id            => nvl(p_pgm_id,l_ptip_rec.pgm_id),
        p_opt_id            => p_opt_id,
        p_ler_id            => l_pil_rec.ler_id,
        p_param1            => 'BEN_IV_RT_STRT_DT',
        p_param1_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_rt_strt_dt),
        p_param2            => 'BEN_IV_CVG_STRT_DT',
        p_param2_value      => fnd_date.date_to_canonical(ben_manage_life_events.g_fonm_cvg_strt_dt),
	p_param3            => 'BEN_IV_PERSON_ID',            -- Bug 5331889
        p_param3_value      => to_char(p_person_id),
        p_jurisdiction_code => l_jurisdiction_code);
    --
    -- Formula will return a date but code defensively in case the
    -- date can not be typecast.
    --
    begin
      --
      l_return_date := fnd_date.canonical_to_date
                        (l_outputs(l_outputs.first).value);
      --
    exception
      --
      when others then
        --
        fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
        fnd_message.set_token('RL','prtn_eff_strt_dt_rl');
        fnd_message.set_token('PROC',l_proc);
        raise ben_manage_life_events.g_record_error;
        --
    end;
    --
  end if;
  --
  if g_debug then
    --
    hr_utility.set_location('Leaving : ' || l_proc, 10);
    --
  end if;
  --
  return l_return_date;
  --
end get_prtn_st_dt_aftr_wtg;
--
--
-- -----------------------------------------------------------------------------
-- |------------------------< save_to_restore >--------------------------------|
-- -----------------------------------------------------------------------------
--
procedure save_to_restore
  (p_current_per_in_ler_id   NUMBER,
   p_per_in_ler_id           NUMBER,
   p_elig_per_id             NUMBER,
   p_elig_per_opt_id         NUMBER,
   p_effective_date          DATE
  )
  IS
    --
    l_proc                  varchar2(100):='ben_determine_eligibility3.save_to_restore';
    --
    cursor c_le (v_per_in_ler_id  number,
                 v_effective_date date) is
    select 'W'
    from   ben_per_in_ler pil,
           ben_ler_f ler
    where  pil.per_in_ler_id = v_per_in_ler_id
    and    ler.ler_id = pil.ler_id
    and    ler.typ_cd not in ('COMP', 'ABS', 'SCHEDDU', 'GSP', 'IREC')   -- iRec
    and    v_effective_date
                     between ler.effective_start_date
                         and ler.effective_end_date ;
    --
    cursor c_upd_pep(v_elig_per_id    number,
                     v_effective_date date,
                     v_per_in_ler_id  number ) is
    select *
    from   ben_elig_per_f
    where  elig_per_id             =  v_elig_per_id
    and    effective_start_date    =  v_effective_date
    and    nvl(per_in_ler_id , -1) =  v_per_in_ler_id ;
    --
    cursor c_upd_epo(v_elig_per_opt_id number,
                     v_effective_date  date,
                     v_per_in_ler_id   number ) is
    select *
    from   ben_elig_per_opt_f
    where  elig_per_opt_id         = v_elig_per_opt_id
    and    nvl(per_in_ler_id , -1) = v_per_in_ler_id
    and    effective_start_date    = v_effective_date;
    --
    l_dummy varchar2(30) := NULL ;
    l_dummy2 varchar2(30) := NULL;
  BEGIN
    --
    hr_utility.set_location('Entering '||l_proc,10);
    hr_utility.set_location('p_per_in_ler_id '||p_per_in_ler_id,22);
    hr_utility.set_location('p_current_per_in_ler_id'||p_current_per_in_ler_id,22);
    hr_utility.set_location('p_elig_per_id'||p_elig_per_id,22);
    hr_utility.set_location('p_elig_per_opt_id'||p_elig_per_opt_id,22);
    hr_utility.set_location('p_effective_date '||p_effective_date,22);
    --
    open c_le(p_per_in_ler_id,p_effective_date);
      fetch c_le into l_dummy;
    close c_le;
    --
    IF NVL(l_dummy,'X') <> 'W' THEN
      hr_utility.set_location('Not Required '||l_proc,15);
      return ;
    ELSE
       open c_le(p_current_per_in_ler_id,p_effective_date);
         fetch c_le into l_dummy2;
       close c_le;
       --
       IF NVL(l_dummy2,'X') <> 'W' THEN
         hr_utility.set_location('Not Required '||l_proc,15);
         return ;
       END IF;
       --
    END IF;
    --
    --BEN_ELIG_PER_F
    IF p_elig_per_id IS NOT NULL THEN
           --
           FOR l_upd_pep_rec IN c_upd_pep(p_elig_per_id,
                                          p_effective_date,
                                          p_per_in_ler_id )
           LOOP
             --
             hr_utility.set_location('Inserting into BEN_LE_CLSN_N_RSTR PEP: '||p_elig_per_id,20);
             --
              insert into BEN_LE_CLSN_N_RSTR (
                  PER_IN_LER_ENDED_ID,
                  BKUP_TBL_TYP_CD,
                  PLIP_ID,
                  PTIP_ID,
                  WAIT_PERD_CMPLTN_DT,
                  PER_IN_LER_ID,
                  RT_FRZ_PCT_FL_TM_FLAG,
                  RT_FRZ_HRS_WKD_FLAG,
                  RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                  ONCE_R_CNTUG_CD,
                  BKUP_TBL_ID,         -- ELIG_PER_ID,
                  EFFECTIVE_START_DATE,
                  EFFECTIVE_END_DATE,
                  BUSINESS_GROUP_ID,
                  PL_ID,
                  PGM_ID,
                  LER_ID,
                  PERSON_ID,
                  DPNT_OTHR_PL_CVRD_RL_FLAG,
                  PRTN_OVRIDN_THRU_DT,
                  PL_KEY_EE_FLAG,
                  PL_HGHLY_COMPD_FLAG,
                  ELIG_FLAG,
                  COMP_REF_AMT,
                  CMBN_AGE_N_LOS_VAL,
                  COMP_REF_UOM,
                  AGE_VAL,
                  LOS_VAL,
                  PRTN_END_DT,
                  PRTN_STRT_DT,
                  WV_CTFN_TYP_CD,
                  HRS_WKD_VAL,
                  HRS_WKD_BNDRY_PERD_CD,
                  PRTN_OVRIDN_FLAG,
                  NO_MX_PRTN_OVRID_THRU_FLAG,
                  PRTN_OVRIDN_RSN_CD,
                  AGE_UOM,
                  LOS_UOM,
                  OVRID_SVC_DT,
                  FRZ_LOS_FLAG,
                  FRZ_AGE_FLAG,
                  FRZ_CMP_LVL_FLAG,
                  FRZ_PCT_FL_TM_FLAG,
                  FRZ_HRS_WKD_FLAG,
                  FRZ_COMB_AGE_AND_LOS_FLAG,
                  DSTR_RSTCN_FLAG,
                  PCT_FL_TM_VAL,
                  WV_PRTN_RSN_CD,
                  PL_WVD_FLAG,
                  LCR_ATTRIBUTE_CATEGORY,
                  LCR_ATTRIBUTE1,
                  LCR_ATTRIBUTE2,
                  LCR_ATTRIBUTE3,
                  LCR_ATTRIBUTE4,
                  LCR_ATTRIBUTE5,
                  LCR_ATTRIBUTE6,
                  LCR_ATTRIBUTE7,
                  LCR_ATTRIBUTE8,
                  LCR_ATTRIBUTE9,
                  LCR_ATTRIBUTE10,
                  LCR_ATTRIBUTE11,
                  LCR_ATTRIBUTE12,
                  LCR_ATTRIBUTE13,
                  LCR_ATTRIBUTE14,
                  LCR_ATTRIBUTE15,
                  LCR_ATTRIBUTE16,
                  LCR_ATTRIBUTE17,
                  LCR_ATTRIBUTE18,
                  LCR_ATTRIBUTE19,
                  LCR_ATTRIBUTE20,
                  LCR_ATTRIBUTE21,
                  LCR_ATTRIBUTE22,
                  LCR_ATTRIBUTE23,
                  LCR_ATTRIBUTE24,
                  LCR_ATTRIBUTE25,
                  LCR_ATTRIBUTE26,
                  LCR_ATTRIBUTE27,
                  LCR_ATTRIBUTE28,
                  LCR_ATTRIBUTE29,
                  LCR_ATTRIBUTE30,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN,
                  CREATED_BY,
                  CREATION_DATE,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
                  OBJECT_VERSION_NUMBER,
                  MUST_ENRL_ANTHR_PL_ID,
                  RT_COMP_REF_AMT,
                  RT_CMBN_AGE_N_LOS_VAL,
                  RT_COMP_REF_UOM,
                  RT_AGE_VAL,
                  RT_LOS_VAL,
                  RT_HRS_WKD_VAL,
                  RT_HRS_WKD_BNDRY_PERD_CD,
                  RT_AGE_UOM,
                  RT_LOS_UOM,
                  RT_PCT_FL_TM_VAL,
                  RT_FRZ_LOS_FLAG,
                  RT_FRZ_AGE_FLAG,
                  RT_FRZ_CMP_LVL_FLAG,
                  INELG_RSN_CD,
                  PL_ORDR_NUM,
                  PLIP_ORDR_NUM,
                  PTIP_ORDR_NUM  )
              values (
                 p_current_per_in_ler_id,
                 'BEN_ELIG_PER_F_CORRECT',
                 l_upd_pep_rec.PLIP_ID,
                 l_upd_pep_rec.PTIP_ID,
                 l_upd_pep_rec.WAIT_PERD_CMPLTN_DT,
                 l_upd_pep_rec.PER_IN_LER_ID,
                 l_upd_pep_rec.RT_FRZ_PCT_FL_TM_FLAG,
                 l_upd_pep_rec.RT_FRZ_HRS_WKD_FLAG,
                 l_upd_pep_rec.RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                 l_upd_pep_rec.ONCE_R_CNTUG_CD,
                 l_upd_pep_rec.ELIG_PER_ID,
                 l_upd_pep_rec.EFFECTIVE_START_DATE,
                 l_upd_pep_rec.EFFECTIVE_END_DATE,
                 l_upd_pep_rec.BUSINESS_GROUP_ID,
                 l_upd_pep_rec.PL_ID,
                 l_upd_pep_rec.PGM_ID,
                 l_upd_pep_rec.LER_ID,
                 l_upd_pep_rec.PERSON_ID,
                 l_upd_pep_rec.DPNT_OTHR_PL_CVRD_RL_FLAG,
                 l_upd_pep_rec.PRTN_OVRIDN_THRU_DT,
                 l_upd_pep_rec.PL_KEY_EE_FLAG,
                 l_upd_pep_rec.PL_HGHLY_COMPD_FLAG,
                 l_upd_pep_rec.ELIG_FLAG,
                 l_upd_pep_rec.COMP_REF_AMT,
                 l_upd_pep_rec.CMBN_AGE_N_LOS_VAL,
                 l_upd_pep_rec.COMP_REF_UOM,
                 l_upd_pep_rec.AGE_VAL,
                 l_upd_pep_rec.LOS_VAL,
                 l_upd_pep_rec.PRTN_END_DT,
                 l_upd_pep_rec.PRTN_STRT_DT,
                 l_upd_pep_rec.WV_CTFN_TYP_CD,
                 l_upd_pep_rec.HRS_WKD_VAL,
                 l_upd_pep_rec.HRS_WKD_BNDRY_PERD_CD,
                 l_upd_pep_rec.PRTN_OVRIDN_FLAG,
                 l_upd_pep_rec.NO_MX_PRTN_OVRID_THRU_FLAG,
                 l_upd_pep_rec.PRTN_OVRIDN_RSN_CD,
                 l_upd_pep_rec.AGE_UOM,
                 l_upd_pep_rec.LOS_UOM,
                 l_upd_pep_rec.OVRID_SVC_DT,
                 l_upd_pep_rec.FRZ_LOS_FLAG,
                 l_upd_pep_rec.FRZ_AGE_FLAG,
                 l_upd_pep_rec.FRZ_CMP_LVL_FLAG,
                 l_upd_pep_rec.FRZ_PCT_FL_TM_FLAG,
                 l_upd_pep_rec.FRZ_HRS_WKD_FLAG,
                 l_upd_pep_rec.FRZ_COMB_AGE_AND_LOS_FLAG,
                 l_upd_pep_rec.DSTR_RSTCN_FLAG,
                 l_upd_pep_rec.PCT_FL_TM_VAL,
                 l_upd_pep_rec.WV_PRTN_RSN_CD,
                 l_upd_pep_rec.PL_WVD_FLAG,
                 l_upd_pep_rec.PEP_ATTRIBUTE_CATEGORY,
                 l_upd_pep_rec.PEP_ATTRIBUTE1,
                 l_upd_pep_rec.PEP_ATTRIBUTE2,
                 l_upd_pep_rec.PEP_ATTRIBUTE3,
                 l_upd_pep_rec.PEP_ATTRIBUTE4,
                 l_upd_pep_rec.PEP_ATTRIBUTE5,
                 l_upd_pep_rec.PEP_ATTRIBUTE6,
                 l_upd_pep_rec.PEP_ATTRIBUTE7,
                 l_upd_pep_rec.PEP_ATTRIBUTE8,
                 l_upd_pep_rec.PEP_ATTRIBUTE9,
                 l_upd_pep_rec.PEP_ATTRIBUTE10,
                 l_upd_pep_rec.PEP_ATTRIBUTE11,
                 l_upd_pep_rec.PEP_ATTRIBUTE12,
                 l_upd_pep_rec.PEP_ATTRIBUTE13,
                 l_upd_pep_rec.PEP_ATTRIBUTE14,
                 l_upd_pep_rec.PEP_ATTRIBUTE15,
                 l_upd_pep_rec.PEP_ATTRIBUTE16,
                 l_upd_pep_rec.PEP_ATTRIBUTE17,
                 l_upd_pep_rec.PEP_ATTRIBUTE18,
                 l_upd_pep_rec.PEP_ATTRIBUTE19,
                 l_upd_pep_rec.PEP_ATTRIBUTE20,
                 l_upd_pep_rec.PEP_ATTRIBUTE21,
                 l_upd_pep_rec.PEP_ATTRIBUTE22,
                 l_upd_pep_rec.PEP_ATTRIBUTE23,
                 l_upd_pep_rec.PEP_ATTRIBUTE24,
                 l_upd_pep_rec.PEP_ATTRIBUTE25,
                 l_upd_pep_rec.PEP_ATTRIBUTE26,
                 l_upd_pep_rec.PEP_ATTRIBUTE27,
                 l_upd_pep_rec.PEP_ATTRIBUTE28,
                 l_upd_pep_rec.PEP_ATTRIBUTE29,
                 l_upd_pep_rec.PEP_ATTRIBUTE30,
                 l_upd_pep_rec.LAST_UPDATE_DATE,
                 l_upd_pep_rec.LAST_UPDATED_BY,
                 l_upd_pep_rec.LAST_UPDATE_LOGIN,
                 l_upd_pep_rec.CREATED_BY,
                 l_upd_pep_rec.CREATION_DATE,
                 l_upd_pep_rec.REQUEST_ID,
                 l_upd_pep_rec.PROGRAM_APPLICATION_ID,
                 l_upd_pep_rec.PROGRAM_ID,
                 l_upd_pep_rec.PROGRAM_UPDATE_DATE,
                 l_upd_pep_rec.OBJECT_VERSION_NUMBER,
                 l_upd_pep_rec.MUST_ENRL_ANTHR_PL_ID,
                 l_upd_pep_rec.RT_COMP_REF_AMT,
                 l_upd_pep_rec.RT_CMBN_AGE_N_LOS_VAL,
                 l_upd_pep_rec.RT_COMP_REF_UOM,
                 l_upd_pep_rec.RT_AGE_VAL,
                 l_upd_pep_rec.RT_LOS_VAL,
                 l_upd_pep_rec.RT_HRS_WKD_VAL,
                 l_upd_pep_rec.RT_HRS_WKD_BNDRY_PERD_CD,
                 l_upd_pep_rec.RT_AGE_UOM,
                 l_upd_pep_rec.RT_LOS_UOM,
                 l_upd_pep_rec.RT_PCT_FL_TM_VAL,
                 l_upd_pep_rec.RT_FRZ_LOS_FLAG,
                 l_upd_pep_rec.RT_FRZ_AGE_FLAG,
                 l_upd_pep_rec.RT_FRZ_CMP_LVL_FLAG,
                 l_upd_pep_rec.INELG_RSN_CD,
                 l_upd_pep_rec.PL_ORDR_NUM,
                 l_upd_pep_rec.PLIP_ORDR_NUM,
                 l_upd_pep_rec.PTIP_ORDR_NUM
               );
             --
           END LOOP;
    END IF;
    --
    --BEN_ELIG_PER_F
    IF p_elig_per_opt_id IS NOT NULL THEN
           --
           FOR l_upd_epo_rec IN c_upd_epo(p_elig_per_opt_id,
                                          p_effective_date,
                                          p_per_in_ler_id )
           LOOP
             --
             hr_utility.set_location('Inserting into BEN_LE_CLSN_N_RSTR EPO: '||p_elig_per_opt_id,20);
             --
             insert into BEN_LE_CLSN_N_RSTR (
                 PER_IN_LER_ENDED_ID,
                 BKUP_TBL_TYP_CD,
                 INELG_RSN_CD,
                 PER_IN_LER_ID,
                 AGE_UOM,
                 LOS_UOM,
                 FRZ_LOS_FLAG,
                 FRZ_AGE_FLAG,
                 FRZ_CMP_LVL_FLAG,
                 FRZ_PCT_FL_TM_FLAG,
                 FRZ_HRS_WKD_FLAG,
                 FRZ_COMB_AGE_AND_LOS_FLAG,
                 OVRID_SVC_DT,
                 WAIT_PERD_CMPLTN_DT,
                 COMP_REF_AMT,
                 CMBN_AGE_N_LOS_VAL,
                 COMP_REF_UOM,
                 AGE_VAL,
                 LOS_VAL,
                 HRS_WKD_VAL,
                 HRS_WKD_BNDRY_PERD_CD,
                 RT_COMP_REF_AMT,
                 RT_CMBN_AGE_N_LOS_VAL,
                 RT_COMP_REF_UOM,
                 RT_AGE_VAL,
                 RT_LOS_VAL,
                 RT_HRS_WKD_VAL,
                 RT_HRS_WKD_BNDRY_PERD_CD,
                 RT_AGE_UOM,
                 RT_LOS_UOM,
                 RT_PCT_FL_TM_VAL,
                 RT_FRZ_LOS_FLAG,
                 RT_FRZ_AGE_FLAG,
                 RT_FRZ_CMP_LVL_FLAG,
                 RT_FRZ_PCT_FL_TM_FLAG,
                 RT_FRZ_HRS_WKD_FLAG,
                 RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                 BKUP_TBL_ID,   -- ELIG_PER_OPT_ID,
                 ELIG_PER_ID,
                 EFFECTIVE_START_DATE,
                 EFFECTIVE_END_DATE,
                 PRTN_OVRIDN_FLAG,
                 PRTN_OVRIDN_THRU_DT,
                 NO_MX_PRTN_OVRID_THRU_FLAG,
                 ELIG_FLAG,
                 PRTN_STRT_DT,
                 PRTN_OVRIDN_RSN_CD,
                 PCT_FL_TM_VAL,
                 OPT_ID,
                 BUSINESS_GROUP_ID,
                 LCR_ATTRIBUTE_CATEGORY,
                 LCR_ATTRIBUTE1,
                 LCR_ATTRIBUTE2,
                 LCR_ATTRIBUTE3,
                 LCR_ATTRIBUTE4,
                 LCR_ATTRIBUTE5,
                 LCR_ATTRIBUTE6,
                 LCR_ATTRIBUTE7,
                 LCR_ATTRIBUTE8,
                 LCR_ATTRIBUTE9,
                 LCR_ATTRIBUTE10,
                 LCR_ATTRIBUTE11,
                 LCR_ATTRIBUTE12,
                 LCR_ATTRIBUTE13,
                 LCR_ATTRIBUTE14,
                 LCR_ATTRIBUTE15,
                 LCR_ATTRIBUTE16,
                 LCR_ATTRIBUTE17,
                 LCR_ATTRIBUTE18,
                 LCR_ATTRIBUTE19,
                 LCR_ATTRIBUTE20,
                 LCR_ATTRIBUTE21,
                 LCR_ATTRIBUTE22,
                 LCR_ATTRIBUTE23,
                 LCR_ATTRIBUTE24,
                 LCR_ATTRIBUTE25,
                 LCR_ATTRIBUTE26,
                 LCR_ATTRIBUTE27,
                 LCR_ATTRIBUTE28,
                 LCR_ATTRIBUTE29,
                 LCR_ATTRIBUTE30,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN,
                 CREATED_BY,
                 CREATION_DATE,
                 REQUEST_ID,
                 PROGRAM_APPLICATION_ID,
                 PROGRAM_ID,
                 PROGRAM_UPDATE_DATE,
                 OBJECT_VERSION_NUMBER,
                 ONCE_R_CNTUG_CD,
                 OIPL_ORDR_NUM,
                 PRTN_END_DT  )
             values (
                p_current_per_in_ler_id,
                'BEN_ELIG_PER_OPT_F_CORRECT',
                l_upd_epo_rec.INELG_RSN_CD,
                l_upd_epo_rec.PER_IN_LER_ID,
                l_upd_epo_rec.AGE_UOM,
                l_upd_epo_rec.LOS_UOM,
                l_upd_epo_rec.FRZ_LOS_FLAG,
                l_upd_epo_rec.FRZ_AGE_FLAG,
                l_upd_epo_rec.FRZ_CMP_LVL_FLAG,
                l_upd_epo_rec.FRZ_PCT_FL_TM_FLAG,
                l_upd_epo_rec.FRZ_HRS_WKD_FLAG,
                l_upd_epo_rec.FRZ_COMB_AGE_AND_LOS_FLAG,
                l_upd_epo_rec.OVRID_SVC_DT,
                -- l_upd_epo_rec.WAIT_PERD_CMPLTN_DT,
                l_upd_epo_rec.WAIT_PERD_CMPLTN_DATE,
                l_upd_epo_rec.COMP_REF_AMT,
                l_upd_epo_rec.CMBN_AGE_N_LOS_VAL,
                l_upd_epo_rec.COMP_REF_UOM,
                l_upd_epo_rec.AGE_VAL,
                l_upd_epo_rec.LOS_VAL,
                l_upd_epo_rec.HRS_WKD_VAL,
                l_upd_epo_rec.HRS_WKD_BNDRY_PERD_CD,
                l_upd_epo_rec.RT_COMP_REF_AMT,
                l_upd_epo_rec.RT_CMBN_AGE_N_LOS_VAL,
                l_upd_epo_rec.RT_COMP_REF_UOM,
                l_upd_epo_rec.RT_AGE_VAL,
                l_upd_epo_rec.RT_LOS_VAL,
                l_upd_epo_rec.RT_HRS_WKD_VAL,
                l_upd_epo_rec.RT_HRS_WKD_BNDRY_PERD_CD,
                l_upd_epo_rec.RT_AGE_UOM,
                l_upd_epo_rec.RT_LOS_UOM,
                l_upd_epo_rec.RT_PCT_FL_TM_VAL,
                l_upd_epo_rec.RT_FRZ_LOS_FLAG,
                l_upd_epo_rec.RT_FRZ_AGE_FLAG,
                l_upd_epo_rec.RT_FRZ_CMP_LVL_FLAG,
                l_upd_epo_rec.RT_FRZ_PCT_FL_TM_FLAG,
                l_upd_epo_rec.RT_FRZ_HRS_WKD_FLAG,
                l_upd_epo_rec.RT_FRZ_COMB_AGE_AND_LOS_FLAG,
                l_upd_epo_rec.ELIG_PER_OPT_ID,
                l_upd_epo_rec.ELIG_PER_ID,
                l_upd_epo_rec.EFFECTIVE_START_DATE,
                l_upd_epo_rec.EFFECTIVE_END_DATE,
                l_upd_epo_rec.PRTN_OVRIDN_FLAG,
                l_upd_epo_rec.PRTN_OVRIDN_THRU_DT,
                l_upd_epo_rec.NO_MX_PRTN_OVRID_THRU_FLAG,
                l_upd_epo_rec.ELIG_FLAG,
                l_upd_epo_rec.PRTN_STRT_DT,
                l_upd_epo_rec.PRTN_OVRIDN_RSN_CD,
                l_upd_epo_rec.PCT_FL_TM_VAL,
                l_upd_epo_rec.OPT_ID,
                l_upd_epo_rec.BUSINESS_GROUP_ID,
                l_upd_epo_rec.EPO_ATTRIBUTE_CATEGORY,
                l_upd_epo_rec.EPO_ATTRIBUTE1,
                l_upd_epo_rec.EPO_ATTRIBUTE2,
                l_upd_epo_rec.EPO_ATTRIBUTE3,
                l_upd_epo_rec.EPO_ATTRIBUTE4,
                l_upd_epo_rec.EPO_ATTRIBUTE5,
                l_upd_epo_rec.EPO_ATTRIBUTE6,
                l_upd_epo_rec.EPO_ATTRIBUTE7,
                l_upd_epo_rec.EPO_ATTRIBUTE8,
                l_upd_epo_rec.EPO_ATTRIBUTE9,
                l_upd_epo_rec.EPO_ATTRIBUTE10,
                l_upd_epo_rec.EPO_ATTRIBUTE11,
                l_upd_epo_rec.EPO_ATTRIBUTE12,
                l_upd_epo_rec.EPO_ATTRIBUTE13,
                l_upd_epo_rec.EPO_ATTRIBUTE14,
                l_upd_epo_rec.EPO_ATTRIBUTE15,
                l_upd_epo_rec.EPO_ATTRIBUTE16,
                l_upd_epo_rec.EPO_ATTRIBUTE17,
                l_upd_epo_rec.EPO_ATTRIBUTE18,
                l_upd_epo_rec.EPO_ATTRIBUTE19,
                l_upd_epo_rec.EPO_ATTRIBUTE20,
                l_upd_epo_rec.EPO_ATTRIBUTE21,
                l_upd_epo_rec.EPO_ATTRIBUTE22,
                l_upd_epo_rec.EPO_ATTRIBUTE23,
                l_upd_epo_rec.EPO_ATTRIBUTE24,
                l_upd_epo_rec.EPO_ATTRIBUTE25,
                l_upd_epo_rec.EPO_ATTRIBUTE26,
                l_upd_epo_rec.EPO_ATTRIBUTE27,
                l_upd_epo_rec.EPO_ATTRIBUTE28,
                l_upd_epo_rec.EPO_ATTRIBUTE29,
                l_upd_epo_rec.EPO_ATTRIBUTE30,
                l_upd_epo_rec.LAST_UPDATE_DATE,
                l_upd_epo_rec.LAST_UPDATED_BY,
                l_upd_epo_rec.LAST_UPDATE_LOGIN,
                l_upd_epo_rec.CREATED_BY,
                l_upd_epo_rec.CREATION_DATE,
                l_upd_epo_rec.REQUEST_ID,
                l_upd_epo_rec.PROGRAM_APPLICATION_ID,
                l_upd_epo_rec.PROGRAM_ID,
                l_upd_epo_rec.PROGRAM_UPDATE_DATE,
                l_upd_epo_rec.OBJECT_VERSION_NUMBER,
                l_upd_epo_rec.ONCE_R_CNTUG_CD,
                l_upd_epo_rec.OIPL_ORDR_NUM,
                l_upd_epo_rec.PRTN_END_DT
             );
             --
           END LOOP;
    END IF;
    --
    hr_utility.set_location('Leaving  '||l_proc,10);
  END save_to_restore ;
end ben_determine_eligibility3;

/
