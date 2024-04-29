--------------------------------------------------------
--  DDL for Package Body BEN_ELP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELP_CACHE" as
/* $Header: benelpch.pkb 120.1 2005/06/22 04:33:08 ssarkar noship $ */
--
-- Declare globals
--
g_package   varchar2(50) := 'ben_elp_cache.';
g_hash_key  number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
-- cobcep
--
g_cobcep_lookup ben_cache.g_cache_lookup_table;
g_cobcep_inst   ben_elp_cache.g_cobcep_cache;
g_cobcep_cached boolean := FALSE;
--
-- eligibility profile person type by eligibility profile
--
g_cache_elpept_lookup ben_cache.g_cache_lookup_table;
g_cache_elpept_inst ben_elp_cache.g_cache_elpept_instor;
--
-- eligibility profile people group by eligibility profile
--
g_cache_elpepg_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepg_inst ben_elp_cache.g_cache_elpepg_instor;
--
-- eligibility profile rule by eligibility profile
--
g_cache_elperl_lookup ben_cache.g_cache_lookup_table;
g_cache_elperl_inst ben_elp_cache.g_cache_elperl_instor;
--
-- eligibility profile assignment status type by eligibility profile
--
g_cache_elpees_lookup ben_cache.g_cache_lookup_table;
g_cache_elpees_inst ben_elp_cache.g_cache_elpees_instor;
--
-- eligibility profile length of service by eligibility profile
--
g_cache_elpels_lookup ben_cache.g_cache_lookup_table;
g_cache_elpels_inst ben_elp_cache.g_cache_elpels_instor;
--
-- eligibility profile age/los combination by eligibility profile
--
g_cache_elpecp_lookup ben_cache.g_cache_lookup_table;
g_cache_elpecp_inst ben_elp_cache.g_cache_elpecp_instor;
--
-- eligibility profile location by eligibility profile
--
g_cache_elpewl_lookup ben_cache.g_cache_lookup_table;
g_cache_elpewl_inst ben_elp_cache.g_cache_elpewl_instor;
--
-- eligibility profile assignment set by eligibility profile
--
g_cache_elpean_lookup ben_cache.g_cache_lookup_table;
g_cache_elpean_inst ben_elp_cache.g_cache_elpean_instor;
--
-- eligibility profile organization by eligibility profile
--
g_cache_elpeou_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeou_inst ben_elp_cache.g_cache_elpeou_instor;
--
-- eligibility profile pay frequency by eligibility profile
--
g_cache_elpehs_lookup ben_cache.g_cache_lookup_table;
g_cache_elpehs_inst ben_elp_cache.g_cache_elpehs_instor;
--
-- eligibility profile full/part time by eligibility profile
--
g_cache_elpefp_lookup ben_cache.g_cache_lookup_table;
g_cache_elpefp_inst ben_elp_cache.g_cache_elpefp_instor;
--
-- eligibility profile scheduled hours by eligibility profile
--
g_cache_elpesh_lookup ben_cache.g_cache_lookup_table;
g_cache_elpesh_inst ben_elp_cache.g_cache_elpesh_instor;
--
-- eligibility profile compensation level by eligibility profile
--
g_cache_elpecl_lookup ben_cache.g_cache_lookup_table;
g_cache_elpecl_inst ben_elp_cache.g_cache_elpecl_instor;
--
-- eligibility profile hours worked by eligibility profile
--
g_cache_elpehw_lookup ben_cache.g_cache_lookup_table;
g_cache_elpehw_inst ben_elp_cache.g_cache_elpehw_instor;
--
-- eligibility profile full time by eligibility profile
--
g_cache_elpepf_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepf_inst ben_elp_cache.g_cache_elpepf_instor;
--
-- eligibility profile grade by eligibility profile
--
g_cache_elpegr_lookup ben_cache.g_cache_lookup_table;
g_cache_elpegr_inst ben_elp_cache.g_cache_elpegr_instor;
--
-- eligibility profile sex by eligibility profile
--
g_cache_elpegn_lookup ben_cache.g_cache_lookup_table;
g_cache_elpegn_inst ben_elp_cache.g_cache_elpegn_instor;
--
-- eligibility profile job by eligibility profile
--
g_cache_elpejp_lookup ben_cache.g_cache_lookup_table;
g_cache_elpejp_inst ben_elp_cache.g_cache_elpejp_instor;
--
-- eligibility profile pay basis by eligibility profile
--
g_cache_elpepb_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepb_inst ben_elp_cache.g_cache_elpepb_instor;
--
-- eligibility profile service area by eligibility profile
--
g_cache_elpesa_lookup ben_cache.g_cache_lookup_table;
g_cache_elpesa_inst ben_elp_cache.g_cache_elpesa_instor;
--
-- eligibility profile payroll by eligibility profile
--
g_cache_elpepy_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepy_inst ben_elp_cache.g_cache_elpepy_instor;
--
-- eligibility profile bargaining unit by eligibility profile
--
g_cache_elpebu_lookup ben_cache.g_cache_lookup_table;
g_cache_elpebu_inst ben_elp_cache.g_cache_elpebu_instor;
--
-- eligibility profile labour union membership by eligibility profile
--
g_cache_elpelu_lookup ben_cache.g_cache_lookup_table;
g_cache_elpelu_inst ben_elp_cache.g_cache_elpelu_instor;
--
-- eligibility profile leave of absence reason by eligibility profile
--
g_cache_elpelr_lookup ben_cache.g_cache_lookup_table;
g_cache_elpelr_inst ben_elp_cache.g_cache_elpelr_instor;
--
-- eligibility profile age details by eligibility profile
--
g_cache_elpeap_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeap_inst ben_elp_cache.g_cache_elpeap_instor;
--
-- eligibility profile zip code range by eligibility profile
--
g_cache_elpepz_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepz_inst ben_elp_cache.g_cache_elpepz_instor;
--
-- eligibility profile benefits group by eligibility profile
--
g_cache_elpebn_lookup ben_cache.g_cache_lookup_table;
g_cache_elpebn_inst ben_elp_cache.g_cache_elpebn_instor;
--
-- eligibility profile legal entity by eligibility profile
--
g_cache_elpeln_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeln_inst ben_elp_cache.g_cache_elpeln_instor;
--
-- eligibility profile other plan by eligibility profile
--
g_cache_elpepp_lookup ben_cache.g_cache_lookup_table;
g_cache_elpepp_inst ben_elp_cache.g_cache_elpepp_instor;
--
-- eligibility profile elig other ptip by eligibility profile
--
g_cache_elpeoy_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeoy_inst ben_elp_cache.g_cache_elpeoy_instor;
--
-- eligibility profile no other coverage participate by eligibility profile
--
g_cache_elpetd_lookup ben_cache.g_cache_lookup_table;
g_cache_elpetd_inst ben_elp_cache.g_cache_elpetd_instor;
--
-- eligibility profile no other dpnt coverage participate by elig profile
--
g_cache_elpeno_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeno_inst ben_elp_cache.g_cache_elpeno_instor;
--
-- eligibility profile enrolled another plan by eligibility profile
--
g_cache_elpeep_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeep_inst ben_elp_cache.g_cache_elpeep_instor;
--
-- eligibility profile enrolled in another oipl by eligibility profile
--
g_cache_elpeei_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeei_inst ben_elp_cache.g_cache_elpeei_instor;
--
-- eligibility profile enrolled in another pgm by eligibility profile
--
g_cache_elpeeg_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeeg_inst ben_elp_cache.g_cache_elpeeg_instor;
--
-- eligibility profile dependent covered other plan by eligibility profile
--
g_cache_elpedp_lookup ben_cache.g_cache_lookup_table;
g_cache_elpedp_inst ben_elp_cache.g_cache_elpedp_instor;
--
-- eligibility profile leaving reason participate by eligibility profile
--
g_cache_elpelv_lookup ben_cache.g_cache_lookup_table;
g_cache_elpelv_inst ben_elp_cache.g_cache_elpelv_instor;
--
-- eligibility profile opted for medicare participate by eligibility profile
--
g_cache_elpeom_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeom_inst ben_elp_cache.g_cache_elpeom_instor;
--
-- eligibility profile enrolled in another plip by eligibility profile
--
g_cache_elpeai_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeai_inst ben_elp_cache.g_cache_elpeai_instor;
--
-- eligibility profile dependent covered othr plip by eligibility profile
--
g_cache_elpedi_lookup ben_cache.g_cache_lookup_table;
g_cache_elpedi_inst ben_elp_cache.g_cache_elpedi_instor;
--
-- eligibility profile enrolled another ptip by eligibility profile
--
g_cache_elpeet_lookup ben_cache.g_cache_lookup_table;
g_cache_elpeet_inst ben_elp_cache.g_cache_elpeet_instor;
--
-- eligibility profile dependent covered in other ptip by eligibility profile
--
g_cache_elpedt_lookup ben_cache.g_cache_lookup_table;
g_cache_elpedt_inst ben_elp_cache.g_cache_elpedt_instor;
--
-- eligibility profile dependent covered in other program by eligibility profile
--
g_cache_elpedg_lookup ben_cache.g_cache_lookup_table;
g_cache_elpedg_inst ben_elp_cache.g_cache_elpedg_instor;
--
-- eligibility profile cobra qualified beneficiary by eligibility profile
--
g_cache_elpecq_lookup ben_cache.g_cache_lookup_table;
g_cache_elpecq_inst ben_elp_cache.g_cache_elpecq_instor;
--
g_copcep_odlookup ben_cache.g_cache_lookup_table;
g_copcep_nxelenum number;
g_copcep_odinst   ben_elp_cache.g_cobcep_odcache := ben_elp_cache.g_cobcep_odcache();
g_copcep_odcached pls_integer := 0;
--
procedure write_cobcep_cache
  (p_business_group_id in     number
  ,p_effective_date    in     date
  )
is
  --
  l_proc varchar2(72) := g_package||'write_cobcep_cache';
  --
  l_torrwnum        pls_integer;
  l_prev_hv         pls_integer;
  l_hv              pls_integer;
  l_not_hash_found  boolean;

  cursor c_lookup
    (c_business_group_id   NUMBER
    ,c_effective_date      DATE
    )
  is
    SELECT MAS1.PGM_ID,
           MAS1.PTIP_ID,
           MAS1.PLIP_ID,
           MAS1.PL_ID,
           MAS1.OIPL_ID
    FROM BEN_PRTN_ELIG_F MAS1
    WHERE MAS1.BUSINESS_GROUP_ID = c_business_group_id
    AND c_effective_date
      BETWEEN MAS1.EFFECTIVE_START_DATE AND MAS1.EFFECTIVE_END_DATE
    and exists(select null
               from  ben_prtn_elig_prfl_f mas2
               where mas1.prtn_elig_id = mas2.prtn_elig_id
               AND c_effective_date
                 BETWEEN MAS2.EFFECTIVE_START_DATE AND MAS2.EFFECTIVE_END_DATE
               )
    ORDER BY MAS1.PGM_ID,
           MAS1.PTIP_ID,
           MAS1.PLIP_ID,
           MAS1.PL_ID,
           MAS1.OIPL_ID;
  --
  cursor c_instance
    (c_business_group_id      NUMBER
    ,c_effective_date         DATE
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_GNDR_FLAG,
            tab3.ELIG_MRTL_STS_FLAG,
            tab3.ELIG_DSBLTY_CTG_FLAG,
            tab3.ELIG_DSBLTY_RSN_FLAG,
            tab3.ELIG_DSBLTY_DGR_FLAG,
            tab3.ELIG_SUPPL_ROLE_FLAG,
            tab3.ELIG_QUAL_TITL_FLAG,
            tab3.ELIG_PSTN_FLAG,
            tab3.ELIG_PRBTN_PERD_FLAG,
            tab3.ELIG_SP_CLNG_PRG_PT_FLAG,
            tab3.BNFT_CAGR_PRTN_CD,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.business_group_id = c_business_group_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date
        and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date
        and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date
    and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
begin
  --
--  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  for row in c_lookup
    (c_business_group_id => p_business_group_id
    ,c_effective_date    => p_effective_date
    )
  loop
    --
    l_hv := mod(nvl(row.pgm_id,1)+nvl(row.ptip_id,2)+nvl(row.plip_id,3)
            +nvl(row.pl_id,4)+nvl(row.oipl_id,5),ben_hash_utility.get_hash_key);
    --
    while ben_elp_cache.g_cobcep_lookup.exists(l_hv)
    loop
      --
      l_hv := l_hv+g_hash_jump;
      --
    end loop;
    --
    ben_elp_cache.g_cobcep_lookup(l_hv).id      := row.pgm_id;
    ben_elp_cache.g_cobcep_lookup(l_hv).fk_id   := row.ptip_id;
    ben_elp_cache.g_cobcep_lookup(l_hv).fk1_id  := row.plip_id;
    ben_elp_cache.g_cobcep_lookup(l_hv).fk2_id  := row.pl_id;
    ben_elp_cache.g_cobcep_lookup(l_hv).fk3_id  := row.oipl_id;
    --
  end loop;
  --
--  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_torrwnum := 0;
  l_prev_hv  := -1;
  --
  if ben_elp_cache.g_cobcep_lookup.count > 0 then
    --
    for objinst in c_instance
      (c_business_group_id => p_business_group_id
      ,c_effective_date    => p_effective_date
      )
    loop
      --
    --  hr_utility.set_location(' St inst loop  '||l_proc,10);
      --
      l_hv := mod(nvl(objinst.pgm_id,1)+nvl(objinst.ptip_id,2)+nvl(objinst.plip_id,3)
              +nvl(objinst.pl_id,4)+nvl(objinst.oipl_id,5),ben_hash_utility.get_hash_key);
      --
      if nvl(ben_elp_cache.g_cobcep_lookup(l_hv).id,-1) =  nvl(objinst.pgm_id,-1)
        and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk_id,-1) = nvl(objinst.ptip_id,-1)
        and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk1_id,-1) = nvl(objinst.plip_id,-1)
        and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk2_id,-1) = nvl(objinst.pl_id,-1)
        and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk3_id,-1) = nvl(objinst.oipl_id,-1)
      then
        --
        null;
        --
      else
        --
        l_hv := l_hv+g_hash_jump;
        --
        loop
          --
          if nvl(ben_elp_cache.g_cobcep_lookup(l_hv).id,-1) = nvl(objinst.pgm_id,-1)
            and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk_id,-1) = nvl(objinst.ptip_id,-1)
            and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk1_id,-1) = nvl(objinst.plip_id,-1)
            and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk2_id,-1) = nvl(objinst.pl_id,-1)
            and nvl(ben_elp_cache.g_cobcep_lookup(l_hv).fk3_id,-1) = nvl(objinst.oipl_id,-1)
          then
            --
            exit;
            --
          else
            --
            l_hv := l_hv+g_hash_jump;
            --
          end if;
          --
        end loop;
        --
      end if;
      --
      if l_prev_hv = -1 then
        ben_elp_cache.g_cobcep_lookup(l_hv).starttorele_num := l_torrwnum;
      elsif l_hv <> l_prev_hv then
        ben_elp_cache.g_cobcep_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
        ben_elp_cache.g_cobcep_lookup(l_hv).starttorele_num := l_torrwnum;
      end if;
      --
    --  hr_utility.set_location(' Assign inst  '||l_proc,10);
      --
      g_cobcep_inst(l_torrwnum).pgm_id                   := objinst.pgm_id;
      g_cobcep_inst(l_torrwnum).ptip_id                  := objinst.ptip_id;
      g_cobcep_inst(l_torrwnum).plip_id                  := objinst.plip_id;
      g_cobcep_inst(l_torrwnum).pl_id                    := objinst.pl_id;
      g_cobcep_inst(l_torrwnum).oipl_id                  := objinst.oipl_id;
      g_cobcep_inst(l_torrwnum).prtn_elig_id             := objinst.prtn_elig_id;
      g_cobcep_inst(l_torrwnum).mndtry_flag              := objinst.mndtry_flag;
      g_cobcep_inst(l_torrwnum).eligy_prfl_id            := objinst.eligy_prfl_id;
      g_cobcep_inst(l_torrwnum).asmt_to_use_cd           := objinst.asmt_to_use_cd;
      g_cobcep_inst(l_torrwnum).elig_enrld_plip_flag     := objinst.elig_enrld_plip_flag;
      g_cobcep_inst(l_torrwnum).elig_cbr_quald_bnf_flag  := objinst.elig_cbr_quald_bnf_flag;
      g_cobcep_inst(l_torrwnum).elig_enrld_ptip_flag     := objinst.elig_enrld_ptip_flag;
      g_cobcep_inst(l_torrwnum).elig_dpnt_cvrd_plip_flag := objinst.elig_dpnt_cvrd_plip_flag;
      g_cobcep_inst(l_torrwnum).elig_dpnt_cvrd_ptip_flag := objinst.elig_dpnt_cvrd_ptip_flag;
      g_cobcep_inst(l_torrwnum).elig_dpnt_cvrd_pgm_flag  := objinst.elig_dpnt_cvrd_pgm_flag;
      g_cobcep_inst(l_torrwnum).elig_job_flag            := objinst.elig_job_flag;
      g_cobcep_inst(l_torrwnum).elig_hrly_slrd_flag      := objinst.elig_hrly_slrd_flag;
      g_cobcep_inst(l_torrwnum).elig_pstl_cd_flag        := objinst.elig_pstl_cd_flag;
      g_cobcep_inst(l_torrwnum).elig_lbr_mmbr_flag       := objinst.elig_lbr_mmbr_flag;
      g_cobcep_inst(l_torrwnum).elig_lgl_enty_flag       := objinst.elig_lgl_enty_flag;
      g_cobcep_inst(l_torrwnum).elig_benfts_grp_flag     := objinst.elig_benfts_grp_flag;
      g_cobcep_inst(l_torrwnum).elig_wk_loc_flag         := objinst.elig_wk_loc_flag;
      g_cobcep_inst(l_torrwnum).elig_brgng_unit_flag     := objinst.elig_brgng_unit_flag;
      g_cobcep_inst(l_torrwnum).elig_age_flag            := objinst.elig_age_flag;
      g_cobcep_inst(l_torrwnum).elig_los_flag            := objinst.elig_los_flag;
      g_cobcep_inst(l_torrwnum).elig_per_typ_flag        := objinst.elig_per_typ_flag;
      g_cobcep_inst(l_torrwnum).elig_fl_tm_pt_tm_flag    := objinst.elig_fl_tm_pt_tm_flag;
      g_cobcep_inst(l_torrwnum).elig_ee_stat_flag        := objinst.elig_ee_stat_flag;
      g_cobcep_inst(l_torrwnum).elig_grd_flag            := objinst.elig_grd_flag;
      g_cobcep_inst(l_torrwnum).elig_pct_fl_tm_flag      := objinst.elig_pct_fl_tm_flag;
      g_cobcep_inst(l_torrwnum).elig_asnt_set_flag       := objinst.elig_asnt_set_flag;
      g_cobcep_inst(l_torrwnum).elig_hrs_wkd_flag        := objinst.elig_hrs_wkd_flag;
      g_cobcep_inst(l_torrwnum).elig_comp_lvl_flag       := objinst.elig_comp_lvl_flag;
      g_cobcep_inst(l_torrwnum).elig_org_unit_flag       := objinst.elig_org_unit_flag;
      g_cobcep_inst(l_torrwnum).elig_loa_rsn_flag        := objinst.elig_loa_rsn_flag;
      g_cobcep_inst(l_torrwnum).elig_pyrl_flag           := objinst.elig_pyrl_flag;
      g_cobcep_inst(l_torrwnum).elig_schedd_hrs_flag     := objinst.elig_schedd_hrs_flag;
      g_cobcep_inst(l_torrwnum).elig_py_bss_flag         := objinst.elig_py_bss_flag;
      g_cobcep_inst(l_torrwnum).eligy_prfl_rl_flag       := objinst.eligy_prfl_rl_flag;
      g_cobcep_inst(l_torrwnum).elig_cmbn_age_los_flag   := objinst.elig_cmbn_age_los_flag;
      g_cobcep_inst(l_torrwnum).cntng_prtn_elig_prfl_flag := objinst.cntng_prtn_elig_prfl_flag;
      g_cobcep_inst(l_torrwnum).elig_prtt_pl_flag         := objinst.elig_prtt_pl_flag;
      g_cobcep_inst(l_torrwnum).elig_ppl_grp_flag         := objinst.elig_ppl_grp_flag;
      g_cobcep_inst(l_torrwnum).elig_svc_area_flag        := objinst.elig_svc_area_flag;
      g_cobcep_inst(l_torrwnum).elig_ptip_prte_flag       := objinst.elig_ptip_prte_flag;
      g_cobcep_inst(l_torrwnum).elig_no_othr_cvg_flag     := objinst.elig_no_othr_cvg_flag;
      g_cobcep_inst(l_torrwnum).elig_enrld_pl_flag        := objinst.elig_enrld_pl_flag;
      g_cobcep_inst(l_torrwnum).elig_enrld_oipl_flag      := objinst.elig_enrld_oipl_flag;
      g_cobcep_inst(l_torrwnum).elig_enrld_pgm_flag       := objinst.elig_enrld_pgm_flag;
      g_cobcep_inst(l_torrwnum).elig_dpnt_cvrd_pl_flag    := objinst.elig_dpnt_cvrd_pl_flag;
      g_cobcep_inst(l_torrwnum).elig_lvg_rsn_flag         := objinst.elig_lvg_rsn_flag;
      g_cobcep_inst(l_torrwnum).elig_optd_mdcr_flag       := objinst.elig_optd_mdcr_flag;
      g_cobcep_inst(l_torrwnum).elig_tbco_use_flag        := objinst.elig_tbco_use_flag;
      g_cobcep_inst(l_torrwnum).elig_dpnt_othr_ptip_flag  := objinst.elig_dpnt_othr_ptip_flag;
      g_cobcep_inst(l_torrwnum).ELIG_GNDR_FLAG            := objinst.ELIG_GNDR_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_MRTL_STS_FLAG        := objinst.ELIG_MRTL_STS_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_DSBLTY_CTG_FLAG      := objinst.ELIG_DSBLTY_CTG_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_DSBLTY_RSN_FLAG      := objinst.ELIG_DSBLTY_RSN_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_DSBLTY_DGR_FLAG      := objinst.ELIG_DSBLTY_DGR_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_SUPPL_ROLE_FLAG      := objinst.ELIG_SUPPL_ROLE_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_QUAL_TITL_FLAG       := objinst.ELIG_QUAL_TITL_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_PSTN_FLAG            := objinst.ELIG_PSTN_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_PRBTN_PERD_FLAG      := objinst.ELIG_PRBTN_PERD_FLAG;
      g_cobcep_inst(l_torrwnum).ELIG_SP_CLNG_PRG_PT_FLAG  := objinst.ELIG_SP_CLNG_PRG_PT_FLAG;
      g_cobcep_inst(l_torrwnum).BNFT_CAGR_PRTN_CD         := objinst.BNFT_CAGR_PRTN_CD;
      g_cobcep_inst(l_torrwnum).ELIG_DSBLD_FLAG       	  := objinst.ELIG_DSBLD_FLAG       ;
      g_cobcep_inst(l_torrwnum).ELIG_TTL_CVG_VOL_FLAG	  := objinst.ELIG_TTL_CVG_VOL_FLAG ;
      g_cobcep_inst(l_torrwnum).ELIG_TTL_PRTT_FLAG    	  := objinst.ELIG_TTL_PRTT_FLAG    ;
      g_cobcep_inst(l_torrwnum).ELIG_COMPTNCY_FLAG    	  := objinst.ELIG_COMPTNCY_FLAG    ;
      g_cobcep_inst(l_torrwnum).ELIG_HLTH_CVG_FLAG    	  := objinst.ELIG_HLTH_CVG_FLAG    ;
      g_cobcep_inst(l_torrwnum).ELIG_ANTHR_PL_FLAG    	  := objinst.ELIG_ANTHR_PL_FLAG    ;

      --
    --  hr_utility.set_location(' Dn Assign inst  '||l_proc,10);
      --
      l_torrwnum := l_torrwnum+1;
      l_prev_hv := l_hv;
      --
    end loop;
    --
    ben_elp_cache.g_cobcep_lookup(l_prev_hv).endtorele_num := l_torrwnum-1;
    --
  end if;
  --
--  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_cobcep_cache;
--
procedure cobcep_getdets
  (p_business_group_id in number
  ,p_effective_date in date
  ,p_pgm_id in number default hr_api.g_number
  ,p_pl_id in number default hr_api.g_number
  ,p_oipl_id in number default hr_api.g_number
  ,p_plip_id in number default hr_api.g_number
  ,p_ptip_id in number default hr_api.g_number
  --
  ,p_inst_set out nocopy ben_elp_cache.g_cobcep_cache
  ,p_inst_count out nocopy number
  )
is
  --
  l_torrwnum      pls_integer;
  l_insttorrw_num pls_integer;
  l_hv            pls_integer;
  l_not_hash_found boolean;
  --
begin
  --
  if not g_cobcep_cached
  then
    --
    -- Build the cache
    --
    write_cobcep_cache
      (p_business_group_id => p_business_group_id
      ,p_effective_date    => p_effective_date
      );
    --
    g_cobcep_cached := TRUE;
    --
  end if;
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5),ben_hash_utility.get_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  if ben_elp_cache.g_cobcep_lookup.exists(l_hv) then
    --
    if nvl(g_cobcep_lookup(l_hv).id,-1) = nvl(p_pgm_id,-1)
      and nvl(g_cobcep_lookup(l_hv).fk_id,-1) = nvl(p_ptip_id,-1)
      and nvl(g_cobcep_lookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_cobcep_lookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_cobcep_lookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
    then
       -- Matched row
       null;
    else
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
        --
        -- Check if the hash index exists, and compare the values
        --
        if nvl(g_cobcep_lookup(l_hv).id,-1) = nvl(p_pgm_id,-1)
          and nvl(g_cobcep_lookup(l_hv).fk_id,-1) = nvl(p_ptip_id,-1)
          and nvl(g_cobcep_lookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
          and nvl(g_cobcep_lookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
          and nvl(g_cobcep_lookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
        then
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    l_torrwnum := 0;
    --
    for l_insttorrw_num in g_cobcep_lookup(l_hv).starttorele_num ..
      g_cobcep_lookup(l_hv).endtorele_num loop
      --
      p_inst_set(l_torrwnum) := g_cobcep_inst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
    p_inst_count := l_torrwnum;
    --
  end if;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end cobcep_getdets;
--
procedure write_cobcep_odcache
  (p_effective_date in     date
  ,p_pgm_id         in     number default hr_api.g_number
  ,p_pl_id          in     number default hr_api.g_number
  ,p_oipl_id        in     number default hr_api.g_number
  ,p_plip_id        in     number default hr_api.g_number
  ,p_ptip_id        in     number default hr_api.g_number
  --
  ,p_hv               out nocopy  pls_integer
  )
is
  --
  l_proc varchar2(72) := g_package||'write_cobcep_odcache';
  --
  l_hv              pls_integer;
  l_not_hash_found  boolean;
  l_torrwnum        pls_integer;
  l_starttorele_num pls_integer;
  --
  cursor c_pgminstance
    (c_pgm_id         number
    ,c_effective_date date
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.pgm_id = c_pgm_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date  and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date  and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date  and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  l_instance c_pgminstance%rowtype;
  --
  cursor c_ptipinstance
    (c_ptip_id        number
    ,c_effective_date date
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.ptip_id = c_ptip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date  and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date  and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date  and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_plipinstance
    (c_plip_id        number
    ,c_effective_date date
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.plip_id = c_plip_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date     and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date     and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date     and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_plinstance
    (c_pl_id          number
    ,c_effective_date date
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.pl_id = c_pl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date     and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date     and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date     and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
  cursor c_oiplinstance
    (c_oipl_id        number
    ,c_effective_date date
    )
  is
    select  tab1.pgm_id,
            tab1.ptip_id,
            tab1.plip_id,
            tab1.pl_id,
            tab1.oipl_id,
            tab1.prtn_elig_id,
            tab2.mndtry_flag,
            tab3.eligy_prfl_id,
            tab3.asmt_to_use_cd,
            tab3.elig_enrld_plip_flag,
            tab3.elig_cbr_quald_bnf_flag,
            tab3.elig_enrld_ptip_flag,
            tab3.elig_dpnt_cvrd_plip_flag,
            tab3.elig_dpnt_cvrd_ptip_flag,
            tab3.elig_dpnt_cvrd_pgm_flag,
            tab3.elig_job_flag,
            tab3.elig_hrly_slrd_flag,
            tab3.elig_pstl_cd_flag,
            tab3.elig_lbr_mmbr_flag,
            tab3.elig_lgl_enty_flag,
            tab3.elig_benfts_grp_flag,
            tab3.elig_wk_loc_flag,
            tab3.elig_brgng_unit_flag,
            tab3.elig_age_flag,
            tab3.elig_los_flag,
            tab3.elig_per_typ_flag,
            tab3.elig_fl_tm_pt_tm_flag,
            tab3.elig_ee_stat_flag,
            tab3.elig_grd_flag,
            tab3.elig_pct_fl_tm_flag,
            tab3.elig_asnt_set_flag,
            tab3.elig_hrs_wkd_flag,
            tab3.elig_comp_lvl_flag,
            tab3.elig_org_unit_flag,
            tab3.elig_loa_rsn_flag,
            tab3.elig_pyrl_flag,
            tab3.elig_schedd_hrs_flag,
            tab3.elig_py_bss_flag,
            tab3.eligy_prfl_rl_flag,
            tab3.elig_cmbn_age_los_flag,
            tab3.cntng_prtn_elig_prfl_flag,
            tab3.elig_prtt_pl_flag,
            tab3.elig_ppl_grp_flag,
            tab3.elig_svc_area_flag,
            tab3.elig_ptip_prte_flag,
            tab3.elig_no_othr_cvg_flag,
            tab3.elig_enrld_pl_flag,
            tab3.elig_enrld_oipl_flag,
            tab3.elig_enrld_pgm_flag,
            tab3.elig_dpnt_cvrd_pl_flag,
            tab3.elig_lvg_rsn_flag,
            tab3.elig_optd_mdcr_flag,
            tab3.elig_tbco_use_flag,
            tab3.elig_dpnt_othr_ptip_flag,
            tab3.ELIG_DSBLD_FLAG,
            tab3.ELIG_TTL_CVG_VOL_FLAG,
            tab3.ELIG_TTL_PRTT_FLAG,
            tab3.ELIG_COMPTNCY_FLAG,
            tab3.ELIG_HLTH_CVG_FLAG,
            tab3.ELIG_ANTHR_PL_FLAG
    from  ben_prtn_elig_f tab1,
          ben_prtn_elig_prfl_f tab2,
          ben_eligy_prfl_f tab3
    where tab1.oipl_id = c_oipl_id
    and tab1.prtn_elig_id = tab2.prtn_elig_id
    and c_effective_date
      between tab1.effective_start_date   and tab1.effective_end_date
    and tab2.eligy_prfl_id = tab3.eligy_prfl_id
    and c_effective_date
      between tab2.effective_start_date   and tab2.effective_end_date
    and c_effective_date
      between tab3.effective_start_date   and tab3.effective_end_date
    order by tab1.pgm_id,
             tab1.ptip_id,
             tab1.plip_id,
             tab1.pl_id,
             tab1.oipl_id,
             decode(tab2.mndtry_flag,'Y',1,2);
  --
begin
  --
  hr_utility.set_location(' Entering  '||l_proc,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5),ben_hash_utility.get_hash_key);
  --
  -- Get a unique hash value
  --
  if g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
    then
      --
      null;
      --
    else
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
        --
        -- Check if the hash index exists, and compare the values
        --
        if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
        then
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  g_copcep_odlookup(l_hv).id     := p_pgm_id;
  g_copcep_odlookup(l_hv).fk_id  := p_ptip_id;
  g_copcep_odlookup(l_hv).fk1_id := p_plip_id;
  g_copcep_odlookup(l_hv).fk2_id := p_pl_id;
  g_copcep_odlookup(l_hv).fk3_id := p_oipl_id;
  --
  hr_utility.set_location(' Dn Look  '||l_proc,10);
  --
  l_starttorele_num := nvl(g_copcep_nxelenum,1);
  l_torrwnum        := l_starttorele_num;
  --
  hr_utility.set_location(' Bef inst loop  '||l_proc,10);
  --
  if p_pgm_id is not null then
    --
    open c_pgminstance
      (c_pgm_id         => p_pgm_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_ptip_id is not null then
    --
    open c_ptipinstance
      (c_ptip_id        => p_ptip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_plip_id is not null then
    --
    open c_plipinstance
      (c_plip_id        => p_plip_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_pl_id is not null then
    --
    open c_plinstance
      (c_pl_id          => p_pl_id
      ,c_effective_date => p_effective_date
      );
    --
  elsif p_oipl_id is not null then
    --
    open c_oiplinstance
      (c_oipl_id        => p_oipl_id
      ,c_effective_date => p_effective_date
      );
    --
  end if;
  --
  loop
    --
    if p_pgm_id is not null then
      --
      fetch c_pgminstance into l_instance;
      exit when c_pgminstance%NOTFOUND;
      --
    elsif p_ptip_id is not null then
      --
      fetch c_ptipinstance into l_instance;
      exit when c_ptipinstance%NOTFOUND;
      --
    elsif p_plip_id is not null then
      --
      fetch c_plipinstance into l_instance;
      exit when c_plipinstance%NOTFOUND;
      --
    elsif p_pl_id is not null then
      --
      fetch c_plinstance into l_instance;
      exit when c_plinstance%NOTFOUND;
      --
    elsif p_oipl_id is not null then
      --
      fetch c_oiplinstance into l_instance;
      exit when c_oiplinstance%NOTFOUND;
      --
    end if;
    --
    hr_utility.set_location(' Assign inst  '||l_proc,10);
    --
    g_copcep_odinst.extend(1);
    g_copcep_odinst(l_torrwnum).pgm_id                   := l_instance.pgm_id;
    g_copcep_odinst(l_torrwnum).ptip_id                  := l_instance.ptip_id;
    g_copcep_odinst(l_torrwnum).plip_id                  := l_instance.plip_id;
    g_copcep_odinst(l_torrwnum).pl_id                    := l_instance.pl_id;
    g_copcep_odinst(l_torrwnum).oipl_id                  := l_instance.oipl_id;
    g_copcep_odinst(l_torrwnum).prtn_elig_id             := l_instance.prtn_elig_id;
    g_copcep_odinst(l_torrwnum).mndtry_flag              := l_instance.mndtry_flag;
    g_copcep_odinst(l_torrwnum).eligy_prfl_id            := l_instance.eligy_prfl_id;
    g_copcep_odinst(l_torrwnum).asmt_to_use_cd           := l_instance.asmt_to_use_cd;
    g_copcep_odinst(l_torrwnum).elig_enrld_plip_flag     := l_instance.elig_enrld_plip_flag;
    g_copcep_odinst(l_torrwnum).elig_cbr_quald_bnf_flag  := l_instance.elig_cbr_quald_bnf_flag;
    g_copcep_odinst(l_torrwnum).elig_enrld_ptip_flag     := l_instance.elig_enrld_ptip_flag;
    g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_plip_flag := l_instance.elig_dpnt_cvrd_plip_flag;
    g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_ptip_flag := l_instance.elig_dpnt_cvrd_ptip_flag;
    g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_pgm_flag  := l_instance.elig_dpnt_cvrd_pgm_flag;
    g_copcep_odinst(l_torrwnum).elig_job_flag            := l_instance.elig_job_flag;
    g_copcep_odinst(l_torrwnum).elig_hrly_slrd_flag      := l_instance.elig_hrly_slrd_flag;
    g_copcep_odinst(l_torrwnum).elig_pstl_cd_flag        := l_instance.elig_pstl_cd_flag;
    g_copcep_odinst(l_torrwnum).elig_lbr_mmbr_flag       := l_instance.elig_lbr_mmbr_flag;
    g_copcep_odinst(l_torrwnum).elig_lgl_enty_flag       := l_instance.elig_lgl_enty_flag;
    g_copcep_odinst(l_torrwnum).elig_benfts_grp_flag     := l_instance.elig_benfts_grp_flag;
    g_copcep_odinst(l_torrwnum).elig_wk_loc_flag         := l_instance.elig_wk_loc_flag;
    g_copcep_odinst(l_torrwnum).elig_brgng_unit_flag     := l_instance.elig_brgng_unit_flag;
    g_copcep_odinst(l_torrwnum).elig_age_flag            := l_instance.elig_age_flag;
    g_copcep_odinst(l_torrwnum).elig_los_flag            := l_instance.elig_los_flag;
    g_copcep_odinst(l_torrwnum).elig_per_typ_flag        := l_instance.elig_per_typ_flag;
    g_copcep_odinst(l_torrwnum).elig_fl_tm_pt_tm_flag    := l_instance.elig_fl_tm_pt_tm_flag;
    g_copcep_odinst(l_torrwnum).elig_ee_stat_flag        := l_instance.elig_ee_stat_flag;
    g_copcep_odinst(l_torrwnum).elig_grd_flag            := l_instance.elig_grd_flag;
    g_copcep_odinst(l_torrwnum).elig_pct_fl_tm_flag      := l_instance.elig_pct_fl_tm_flag;
    g_copcep_odinst(l_torrwnum).elig_asnt_set_flag       := l_instance.elig_asnt_set_flag;
    g_copcep_odinst(l_torrwnum).elig_hrs_wkd_flag        := l_instance.elig_hrs_wkd_flag;
    g_copcep_odinst(l_torrwnum).elig_comp_lvl_flag       := l_instance.elig_comp_lvl_flag;
    g_copcep_odinst(l_torrwnum).elig_org_unit_flag       := l_instance.elig_org_unit_flag;
    g_copcep_odinst(l_torrwnum).elig_loa_rsn_flag        := l_instance.elig_loa_rsn_flag;
    g_copcep_odinst(l_torrwnum).elig_pyrl_flag           := l_instance.elig_pyrl_flag;
    g_copcep_odinst(l_torrwnum).elig_schedd_hrs_flag     := l_instance.elig_schedd_hrs_flag;
    g_copcep_odinst(l_torrwnum).elig_py_bss_flag         := l_instance.elig_py_bss_flag;
    g_copcep_odinst(l_torrwnum).eligy_prfl_rl_flag       := l_instance.eligy_prfl_rl_flag;
    g_copcep_odinst(l_torrwnum).elig_cmbn_age_los_flag   := l_instance.elig_cmbn_age_los_flag;
    g_copcep_odinst(l_torrwnum).cntng_prtn_elig_prfl_flag := l_instance.cntng_prtn_elig_prfl_flag;
    g_copcep_odinst(l_torrwnum).elig_prtt_pl_flag         := l_instance.elig_prtt_pl_flag;
    g_copcep_odinst(l_torrwnum).elig_ppl_grp_flag         := l_instance.elig_ppl_grp_flag;
    g_copcep_odinst(l_torrwnum).elig_svc_area_flag        := l_instance.elig_svc_area_flag;
    g_copcep_odinst(l_torrwnum).elig_ptip_prte_flag       := l_instance.elig_ptip_prte_flag;
    g_copcep_odinst(l_torrwnum).elig_no_othr_cvg_flag     := l_instance.elig_no_othr_cvg_flag;
    g_copcep_odinst(l_torrwnum).elig_enrld_pl_flag        := l_instance.elig_enrld_pl_flag;
    g_copcep_odinst(l_torrwnum).elig_enrld_oipl_flag      := l_instance.elig_enrld_oipl_flag;
    g_copcep_odinst(l_torrwnum).elig_enrld_pgm_flag       := l_instance.elig_enrld_pgm_flag;
    g_copcep_odinst(l_torrwnum).elig_dpnt_cvrd_pl_flag    := l_instance.elig_dpnt_cvrd_pl_flag;
    g_copcep_odinst(l_torrwnum).elig_lvg_rsn_flag         := l_instance.elig_lvg_rsn_flag;
    g_copcep_odinst(l_torrwnum).elig_optd_mdcr_flag       := l_instance.elig_optd_mdcr_flag;
    g_copcep_odinst(l_torrwnum).elig_tbco_use_flag        := l_instance.elig_tbco_use_flag;
    g_copcep_odinst(l_torrwnum).elig_dpnt_othr_ptip_flag  := l_instance.elig_dpnt_othr_ptip_flag;
    g_copcep_odinst(l_torrwnum).ELIG_DSBLD_FLAG       	  := l_instance.ELIG_DSBLD_FLAG       ;
    g_copcep_odinst(l_torrwnum).ELIG_TTL_CVG_VOL_FLAG	  := l_instance.ELIG_TTL_CVG_VOL_FLAG ;
    g_copcep_odinst(l_torrwnum).ELIG_TTL_PRTT_FLAG    	  := l_instance.ELIG_TTL_PRTT_FLAG    ;
    g_copcep_odinst(l_torrwnum).ELIG_COMPTNCY_FLAG    	  := l_instance.ELIG_COMPTNCY_FLAG    ;
    g_copcep_odinst(l_torrwnum).ELIG_HLTH_CVG_FLAG    	  := l_instance.ELIG_HLTH_CVG_FLAG    ;
    g_copcep_odinst(l_torrwnum).ELIG_ANTHR_PL_FLAG    	  := l_instance.ELIG_ANTHR_PL_FLAG    ;
    hr_utility.set_location(' Dn Assign inst  '||l_proc,10);
    --
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  if p_pgm_id is not null then
    --
    close c_pgminstance;
    --
  elsif p_ptip_id is not null then
    --
    close c_ptipinstance;
    --
  elsif p_plip_id is not null then
    --
    close c_plipinstance;
    --
  elsif p_pl_id is not null then
    --
    close c_plinstance;
    --
  elsif p_oipl_id is not null then
    --
    close c_oiplinstance;
    --
  end if;
  --
  -- Check if any rows were found
  --
  if l_torrwnum > nvl(g_copcep_nxelenum,1)
  then
    --
    g_copcep_odlookup(l_hv).starttorele_num := l_starttorele_num;
    g_copcep_odlookup(l_hv).endtorele_num   := l_torrwnum-1;
    g_copcep_nxelenum := l_torrwnum;
    --
    p_hv := l_hv;
    --
  else
    --
    p_hv := null;
    --
  end if;
  --
  begin
    --
    dbms_session.free_unused_user_memory;
    --
  end;
  hr_utility.set_location(' Leaving  '||l_proc,10);
end write_cobcep_odcache;
--
procedure cobcep_odgetdets
  (p_effective_date in     date
  ,p_pgm_id         in     number default hr_api.g_number
  ,p_pl_id          in     number default hr_api.g_number
  ,p_oipl_id        in     number default hr_api.g_number
  ,p_plip_id        in     number default hr_api.g_number
  ,p_ptip_id        in     number default hr_api.g_number
  --
  ,p_inst_set       in out nocopy ben_elp_cache.g_cobcep_odcache
  )
is
  --
  l_proc varchar2(72) := g_package||'cobcep_odgetdets';
  --
  l_inst_set       ben_elp_cache.g_cobcep_odcache := ben_elp_cache.g_cobcep_odcache();
  --
  l_hv             pls_integer;
  l_not_hash_found boolean;
  l_insttorrw_num  pls_integer;
  l_torrwnum       pls_integer;
  --
begin
  --
  if g_copcep_odcached = 0
  then
    --
    -- Build the cache
    --
    clear_down_cache;
    --
    g_copcep_odcached := 1;
    --
  end if;
  hr_utility.set_location(' Derive hv  '||l_proc,10);
  --
  -- Get the instance details
  --
  l_hv := mod(nvl(p_pgm_id,1)+nvl(p_ptip_id,2)+nvl(p_plip_id,3)
          +nvl(p_pl_id,4)+nvl(p_oipl_id,5),ben_hash_utility.get_hash_key);
  --
  -- Check if hashed value is already allocated
  --
  if g_copcep_odlookup.exists(l_hv) then
    --
    if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
      and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
    then
      --
      null;
      --
    else
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_hv := ben_hash_utility.get_next_hash_index(p_hash_index => l_hv);
        --
        -- Check if the hash index exists, and compare the values
        --
        if nvl(g_copcep_odlookup(l_hv).id,-1)        = nvl(p_pgm_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk_id,-1)  = nvl(p_ptip_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk1_id,-1) = nvl(p_plip_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk2_id,-1) = nvl(p_pl_id,-1)
          and nvl(g_copcep_odlookup(l_hv).fk3_id,-1) = nvl(p_oipl_id,-1)
        then
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  else
    --
    write_cobcep_odcache
      (p_effective_date => p_effective_date
      ,p_pgm_id         => p_pgm_id
      ,p_pl_id          => p_pl_id
      ,p_oipl_id        => p_oipl_id
      ,p_plip_id        => p_plip_id
      ,p_ptip_id        => p_ptip_id
      --
      ,p_hv             => l_hv
      );
    --
  end if;
  hr_utility.set_location(' Got hv  '||l_proc,10);
  --
  if l_hv is not null then
    --
    l_torrwnum := 1;
    --
    hr_utility.set_location(' Get loop  '||l_proc,10);
    for l_insttorrw_num in g_copcep_odlookup(l_hv).starttorele_num ..
      g_copcep_odlookup(l_hv).endtorele_num
    loop
      --
      l_inst_set.extend(1);
      l_inst_set(l_torrwnum) := g_copcep_odinst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end loop;
    --
    hr_utility.set_location(' Dn Get loop  '||l_proc,10);
    p_inst_set := l_inst_set;
    --
  end if;
  hr_utility.set_location(' Leaving  '||l_proc,10);
exception
  --
  when no_data_found then
    --
    null;
    --
end cobcep_odgetdets;
--
procedure elpelc_getdets
(p_business_group_id in     number
,p_effective_date    in     date
,p_eligy_prfl_id in     number default hr_api.g_number
,p_cache_code in     varchar2 default hr_api.g_varchar2
--
,p_inst_set             out nocopy ben_elp_cache.g_elpelc_cache
,p_inst_count           out nocopy number
)
is
--
l_proc varchar2(72) :=  'elpelc_getdets';
--
l_instcolnm_set    ben_cache.InstColNmType;
l_tabdet_set       ben_cache.TabDetType;
--
l_torrwnum         pls_integer;
l_insttorrw_num    pls_integer;
l_index            pls_integer;
l_instcolnm_num    pls_integer;
l_not_hash_found   boolean;
l_mastertab_name   varchar2(100);
l_masterpkcol_name varchar2(100);
l_lkup_name        varchar2(100);
l_inst_name        varchar2(100);
l_table1_name      varchar2(100);
l_tab1jncol_name   varchar2(100);
l_table2_name      varchar2(100);
l_tab2jncol_name   varchar2(100);
l_table3_name      varchar2(100);
--
begin
--
-- Check if the lookup cache is populated
--
if (p_cache_code = 'ELPEPT' and ben_elp_cache.g_elpept_lookup.count = 0)
or (p_cache_code = 'ELPEES' and ben_elp_cache.g_elpees_lookup.count = 0)
or (p_cache_code = 'ELPESA' and ben_elp_cache.g_elpesa_lookup.count = 0)
or (p_cache_code = 'ELPEHS' and ben_elp_cache.g_elpehs_lookup.count = 0)
or (p_cache_code = 'ELPELS' and ben_elp_cache.g_elpels_lookup.count = 0)
or (p_cache_code = 'ELPECP' and ben_elp_cache.g_elpecp_lookup.count = 0)
then
--
-- Column and cache details
--
if p_cache_code = 'ELPEPT' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpept_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpept_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_per_typ_prte_f';
--
elsif p_cache_code = 'ELPEES' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpees_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpees_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_ee_stat_prte_f';
--
elsif p_cache_code = 'ELPESA' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpesa_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpesa_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_svc_area_prte_f';
l_tabdet_set(0).tab_jncolnm := 'svc_area_id';
l_tabdet_set(1).tab_name    := 'ben_svc_area_pstl_zip_rng_f';
l_tabdet_set(1).tab_jncolnm := 'pstl_zip_rng_id';
l_tabdet_set(2).tab_name    := 'ben_pstl_zip_rng_f';
--
elsif p_cache_code = 'ELPEHS' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpehs_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpehs_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_hrly_slrd_prte_f';
--
elsif p_cache_code = 'ELPELS' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpels_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpels_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_los_prte_f';
l_tabdet_set(0).tab_jncolnm := 'los_fctr_id';
l_tabdet_set(1).tab_name    := 'ben_los_fctr';
l_tabdet_set(1).tab_datetype := 'nondt';
--
elsif p_cache_code = 'ELPECP' then
--
l_mastertab_name            := 'ben_eligy_prfl_f';
l_masterpkcol_name          := 'eligy_prfl_id';
l_lkup_name                 := 'ben_elp_cache.g_elpecp_lookup';
l_inst_name                 := 'ben_elp_cache.g_elpecp_inst';
l_tabdet_set(0).tab_name    := 'ben_elig_cmbn_age_los_prte_f';
l_tabdet_set(0).tab_jncolnm := 'cmbn_age_los_fctr_id';
l_tabdet_set(1).tab_name    := 'ben_cmbn_age_los_fctr';
l_tabdet_set(1).tab_datetype := 'nondt';
--
end if;
--
l_instcolnm_num := 0;
--
l_instcolnm_set(l_instcolnm_num).col_name    := l_masterpkcol_name;
l_instcolnm_set(l_instcolnm_num).caccol_name := 'eligy_prfl_id';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
l_instcolnm_set(l_instcolnm_num).col_type    := 'MASTER';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'excld_flag';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'excld_flag';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
if p_cache_code = 'ELPEPT' then
-- Not supporting per_typ_cd,instead use person_type_id
--l_instcolnm_set(l_instcolnm_num).col_name    := 'per_typ_cd';
l_instcolnm_set(l_instcolnm_num).col_name    := 'person_type_id';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'code';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
elsif p_cache_code = 'ELPEES' then
l_instcolnm_set(l_instcolnm_num).col_name    := 'assignment_status_type_id';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'id';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table1';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
elsif p_cache_code = 'ELPESA' then
l_instcolnm_set(l_instcolnm_num).col_name    := 'from_value';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'from_value';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table3';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'to_value';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'to_value';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table3';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
elsif p_cache_code = 'ELPELS' then
l_instcolnm_set(l_instcolnm_num).col_name    := 'mx_los_num';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'mx_num';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'mn_los_num';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'mn_num';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mx_los_num_apls_flag';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mx_num_apls_flag';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'no_mn_los_num_apls_flag';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'no_mn_num_apls_flag';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
elsif p_cache_code = 'ELPECP' then
l_instcolnm_set(l_instcolnm_num).col_name    := 'los_fctr_id';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'id';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'age_fctr_id';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'id1';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'cmbnd_min_val';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'cmbnd_min_val';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
l_instcolnm_set(l_instcolnm_num).col_name    := 'cmbnd_max_val';
l_instcolnm_set(l_instcolnm_num).caccol_name := 'cmbnd_max_val';
l_instcolnm_set(l_instcolnm_num).col_alias   := 'table2';
l_instcolnm_set(l_instcolnm_num).col_type    := 'SELECT';
l_instcolnm_num := l_instcolnm_num+1;
--
end if;
ben_cache.Write_BGP_Cache
(p_mastertab_name    => l_mastertab_name
,p_masterpkcol_name  => l_masterpkcol_name
,p_tabdet_set        => l_tabdet_set
,p_table1_name       => l_table1_name
,p_tab1jncol_name    => l_tab1jncol_name
,p_table2_name       => l_table2_name
,p_tab2jncol_name    => l_tab2jncol_name
,p_table3_name       => l_table3_name
,p_business_group_id => p_business_group_id
,p_effective_date    => p_effective_date
,p_lkup_name         => l_lkup_name
,p_inst_name         => l_inst_name
,p_instcolnm_set     => l_instcolnm_set
);
--
end if;
--
-- Get the instance details
--
l_torrwnum := 0;
--
if upper(p_cache_code) = 'ELPEPT' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpept_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpept_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpept_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpept_lookup(l_index).starttorele_num ..
g_elpept_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpept_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
elsif upper(p_cache_code) = 'ELPEES' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpees_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpees_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpees_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpees_lookup(l_index).starttorele_num ..
g_elpees_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpees_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
elsif upper(p_cache_code) = 'ELPESA' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpesa_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpesa_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpesa_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpesa_lookup(l_index).starttorele_num ..
g_elpesa_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpesa_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
elsif upper(p_cache_code) = 'ELPEHS' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpehs_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpehs_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpehs_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpehs_lookup(l_index).starttorele_num ..
g_elpehs_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpehs_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
elsif upper(p_cache_code) = 'ELPELS' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpels_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpels_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpels_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpels_lookup(l_index).starttorele_num ..
g_elpels_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpels_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
elsif upper(p_cache_code) = 'ELPECP' then
--
l_index  := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
--
-- Check if hashed value is already allocated
--
if g_elpecp_lookup.exists(l_index) then
--
-- If it does exist make sure its the right one
--
if g_elpecp_lookup(l_index).id <> p_eligy_prfl_id then
--
l_not_hash_found := false;
--
-- Loop until un-allocated has value is derived
--
while not l_not_hash_found loop
--
l_index := ben_hash_utility.get_next_hash_index
(p_hash_index => l_index);
--
-- Check if the hash index exists, if not we can use it
--
if not g_elpecp_lookup.exists(l_index) then
--
-- Lets store the hash value in the index
--
l_not_hash_found := true;
exit;
--
else
--
l_not_hash_found := false;
--
end if;
--
end loop;
--
end if;
--
end if;
--
for l_insttorrw_num in g_elpecp_lookup(l_index).starttorele_num ..
g_elpecp_lookup(l_index).endtorele_num
loop
--
--
p_inst_set(l_torrwnum) := g_elpecp_inst(l_insttorrw_num);
l_torrwnum := l_torrwnum+1;
--
end loop;
--
end if;
--
p_inst_count := l_torrwnum;
--
exception
when no_data_found then
--
p_inst_count := 0;
--
end elpelc_getdets;
--
procedure elpepg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepg_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepg_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_ppl_grp_prte_f epg
                  where  p_effective_date
                         between epg.effective_start_date
                         and     epg.effective_end_date
                 and     epg.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpepg_inst is
    select epg.eligy_prfl_id,
           epg.elig_ppl_grp_prte_id pk_id,
           'EPG' short_code,
           epg.people_group_id,
           epg.excld_flag,
           epg.criteria_score,
           epg.criteria_weight,
           ppg.segment1 ,
           ppg.segment2 ,
           ppg.segment3 ,
           ppg.segment4 ,
           ppg.segment5 ,
           ppg.segment6 ,
           ppg.segment7 ,
           ppg.segment8 ,
           ppg.segment9 ,
           ppg.segment10,
           ppg.segment11,
           ppg.segment12,
           ppg.segment13,
           ppg.segment14,
           ppg.segment15,
           ppg.segment16,
           ppg.segment17,
           ppg.segment18,
           ppg.segment19,
           ppg.segment20,
           ppg.segment21,
           ppg.segment22,
           ppg.segment23,
           ppg.segment24,
           ppg.segment25,
           ppg.segment26,
           ppg.segment27,
           ppg.segment28,
           ppg.segment29,
           ppg.segment30
    from   ben_elig_ppl_grp_prte_f epg
          ,pay_people_groups ppg
    where  p_effective_date
             between epg.effective_start_date
             and     epg.effective_end_date
           and epg.people_group_id = ppg.people_group_id
    order  by epg.eligy_prfl_id,
           decode(epg.excld_flag,'Y',1,2),
           epg.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepg_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepg_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepg_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepg_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepg_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepg_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepg_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepg_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepg_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepg_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpepg_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpepg_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpepg_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpepg_inst(l_torrwnum).people_group_id := objinst.people_group_id;
    g_cache_elpepg_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpepg_inst(l_torrwnum).segment1  := objinst.segment1 ;
    g_cache_elpepg_inst(l_torrwnum).segment2  := objinst.segment2 ;
    g_cache_elpepg_inst(l_torrwnum).segment3  := objinst.segment3 ;
    g_cache_elpepg_inst(l_torrwnum).segment4  := objinst.segment4 ;
    g_cache_elpepg_inst(l_torrwnum).segment5  := objinst.segment5 ;
    g_cache_elpepg_inst(l_torrwnum).segment6  := objinst.segment6 ;
    g_cache_elpepg_inst(l_torrwnum).segment7  := objinst.segment7 ;
    g_cache_elpepg_inst(l_torrwnum).segment8  := objinst.segment8 ;
    g_cache_elpepg_inst(l_torrwnum).segment9  := objinst.segment9 ;
    g_cache_elpepg_inst(l_torrwnum).segment10 := objinst.segment10;
    g_cache_elpepg_inst(l_torrwnum).segment11 := objinst.segment11;
    g_cache_elpepg_inst(l_torrwnum).segment12 := objinst.segment12;
    g_cache_elpepg_inst(l_torrwnum).segment13 := objinst.segment13;
    g_cache_elpepg_inst(l_torrwnum).segment14 := objinst.segment14;
    g_cache_elpepg_inst(l_torrwnum).segment15 := objinst.segment15;
    g_cache_elpepg_inst(l_torrwnum).segment16 := objinst.segment16;
    g_cache_elpepg_inst(l_torrwnum).segment17 := objinst.segment17;
    g_cache_elpepg_inst(l_torrwnum).segment18 := objinst.segment18;
    g_cache_elpepg_inst(l_torrwnum).segment19 := objinst.segment19;
    g_cache_elpepg_inst(l_torrwnum).segment20 := objinst.segment20;
    g_cache_elpepg_inst(l_torrwnum).segment21 := objinst.segment21;
    g_cache_elpepg_inst(l_torrwnum).segment22 := objinst.segment22;
    g_cache_elpepg_inst(l_torrwnum).segment23 := objinst.segment23;
    g_cache_elpepg_inst(l_torrwnum).segment24 := objinst.segment24;
    g_cache_elpepg_inst(l_torrwnum).segment25 := objinst.segment25;
    g_cache_elpepg_inst(l_torrwnum).segment26 := objinst.segment26;
    g_cache_elpepg_inst(l_torrwnum).segment27 := objinst.segment27;
    g_cache_elpepg_inst(l_torrwnum).segment28 := objinst.segment28;
    g_cache_elpepg_inst(l_torrwnum).segment29 := objinst.segment29;
    g_cache_elpepg_inst(l_torrwnum).segment30 := objinst.segment30;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepg_writecache;
--
procedure elpepg_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepg_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepg_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepg_lookup.delete;
    g_cache_elpepg_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepg_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepg_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepg_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepg_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepg_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
    --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepg_lookup(l_index).starttorele_num ..
    g_cache_elpepg_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepg_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepg_getcacdets;
--
procedure elpept_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpept_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpept_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_per_typ_prte_f ept
                  where  p_effective_date
                         between ept.effective_start_date
                         and     ept.effective_end_date
                  and    ept.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  -- Not supporting per_typ_cd,instead use person_type_id
  --
  cursor c_elpept_inst is
    select ept.eligy_prfl_id,
           ept.elig_per_typ_prte_id pk_id,
           'EPT' short_code,
           --ept.per_typ_cd,
           ept.person_type_id,
           ept.excld_flag,
           ept.criteria_score,
           ept.criteria_weight
    from   ben_elig_per_typ_prte_f ept
    where  p_effective_date
           between ept.effective_start_date
           and     ept.effective_end_date
    order  by ept.eligy_prfl_id,
           decode(ept.excld_flag,'Y',1,2),
           ept.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpept_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpept_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpept_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpept_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpept_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpept_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpept_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpept_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpept_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpept_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpept_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpept_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpept_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpept_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpept_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpept_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    --
    -- Not supporting per_typ_cd,instead use person_type_id
    -- g_cache_elpept_inst(l_torrwnum).per_typ_cd := objinst.per_typ_cd;
    --
    g_cache_elpept_inst(l_torrwnum).person_type_id := objinst.person_type_id;
    g_cache_elpept_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpept_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpept_writecache;
--
procedure elpept_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpept_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpept_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpept_lookup.delete;
    g_cache_elpept_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpept_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpept_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpept_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpept_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpept_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpept_lookup(l_index).starttorele_num ..
    g_cache_elpept_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpept_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpept_getcacdets;
--
procedure elpean_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpean_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpean_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_asnt_set_prte_f ean
                  where  p_effective_date
                         between ean.effective_start_date
                         and     ean.effective_end_date
                  and    ean.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpean_inst is
    select ean.eligy_prfl_id,
           ean.elig_asnt_set_prte_id pk_id,
           'EAN' short_code,
           ass.formula_id,
           ean.excld_flag,
           ean.criteria_score,
           ean.criteria_weight
    from   ben_elig_asnt_set_prte_f ean,
           hr_assignment_sets ass
    where  p_effective_date
           between ean.effective_start_date
           and     ean.effective_end_date
    and    ean.assignment_set_id = ass.assignment_set_id
    order  by ean.eligy_prfl_id,
           decode(ean.excld_flag,'Y',1,2),
           ean.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpean_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpean_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpean_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpean_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpean_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpean_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpean_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpean_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpean_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpean_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpean_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpean_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpean_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpean_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpean_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpean_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpean_inst(l_torrwnum).formula_id := objinst.formula_id;
    g_cache_elpean_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpean_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpean_writecache;
--
procedure elpean_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpean_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpean_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpean_lookup.delete;
    g_cache_elpean_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpean_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpean_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpean_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpean_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpean_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpean_lookup(l_index).starttorele_num ..
    g_cache_elpean_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpean_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpean_getcacdets;
--
procedure elperl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elperl_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elperl_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_eligy_prfl_rl_f erl
                  where  p_effective_date
                         between erl.effective_start_date
                         and     erl.effective_end_date
                  and    erl.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elperl_inst is
    select erl.eligy_prfl_id,
           erl.eligy_prfl_rl_id pk_id,
           'ERL' short_code,
           erl.formula_id,
           erl.criteria_score,
           erl.criteria_weight
    from   ben_eligy_prfl_rl_f erl
    where  p_effective_date
           between erl.effective_start_date
           and     erl.effective_end_date
    order  by erl.eligy_prfl_id,
           erl.ordr_to_aply_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elperl_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elperl_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elperl_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elperl_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elperl_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elperl_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elperl_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elperl_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elperl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elperl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elperl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elperl_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elperl_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elperl_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elperl_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elperl_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elperl_inst(l_torrwnum).formula_id := objinst.formula_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elperl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elperl_writecache;
--
procedure elperl_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elperl_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elperl_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elperl_lookup.delete;
    g_cache_elperl_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elperl_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elperl_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elperl_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elperl_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elperl_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elperl_lookup(l_index).starttorele_num ..
    g_cache_elperl_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elperl_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elperl_getcacdets;
--
procedure elpees_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpees_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpees_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_ee_stat_prte_f ees
                  where  p_effective_date
                         between ees.effective_start_date
                         and     ees.effective_end_date
                  and    ees.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpees_inst is
    select ees.eligy_prfl_id,
           ees.elig_ee_stat_prte_id pk_id,
           'EES' short_code,
           ees.assignment_status_type_id,
           ees.excld_flag,
           ees.criteria_score,
           ees.criteria_weight
    from   ben_elig_ee_stat_prte_f ees
    where  p_effective_date
           between ees.effective_start_date
           and ees.effective_end_date
    order  by ees.eligy_prfl_id,
           decode(ees.excld_flag,'Y',1,2),
           ees.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpees_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpees_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpees_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpees_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpees_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpees_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpees_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpees_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpees_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpees_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpees_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpees_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpees_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpees_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpees_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpees_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpees_inst(l_torrwnum).assignment_status_type_id := objinst.assignment_status_type_id;
    g_cache_elpees_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpees_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpees_writecache;
--
procedure elpees_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpees_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpees_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpees_lookup.delete;
    g_cache_elpees_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpees_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpees_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpees_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpees_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpees_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpees_lookup(l_index).starttorele_num ..
    g_cache_elpees_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpees_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpees_getcacdets;
--
procedure elpesa_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpesa_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpesa_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists (select null
                   from   ben_elig_svc_area_prte_f esa,
                          ben_svc_area_pstl_zip_rng_f saz,
                          ben_pstl_zip_rng_f rzr
                   where  p_effective_date
                          between esa.effective_start_date
                          and     esa.effective_end_date
                   and    esa.svc_area_id = saz.svc_area_id
                   and    esa.business_group_id = saz.business_group_id
                   and    p_effective_date
                          between rzr.effective_start_date
                          and     rzr.effective_end_date
                   and    saz.pstl_zip_rng_id = rzr.pstl_zip_rng_id
                   and    esa.business_group_id = rzr.business_group_id
                   and    esa.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpesa_inst is
    select esa.eligy_prfl_id,
           esa.elig_svc_area_prte_id pk_id,
           'ESA' short_code,
           esa.excld_flag,
           esa.criteria_score,
           esa.criteria_weight,
           rzr.from_value,
           rzr.to_value
    from   ben_elig_svc_area_prte_f esa,
           ben_svc_area_pstl_zip_rng_f saz,
           ben_pstl_zip_rng_f rzr
    where  p_effective_date
           between esa.effective_start_date
           and     esa.effective_end_date
    and    esa.svc_area_id = saz.svc_area_id
    and    esa.business_group_id = saz.business_group_id
    and    p_effective_date
           between rzr.effective_start_date
           and     rzr.effective_end_date
    and    saz.pstl_zip_rng_id = rzr.pstl_zip_rng_id
    and    saz.business_group_id = rzr.business_group_id
    order  by esa.eligy_prfl_id,
           decode(esa.excld_flag,'Y',1,2),
           esa.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpesa_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpesa_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpesa_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpesa_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpesa_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpesa_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpesa_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpesa_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpesa_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpesa_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpesa_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpesa_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpesa_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpesa_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpesa_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpesa_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpesa_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpesa_inst(l_torrwnum).from_value := objinst.from_value;
    g_cache_elpesa_inst(l_torrwnum).to_value := objinst.to_value;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpesa_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpesa_writecache;
--
procedure elpesa_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpesa_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpesa_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpesa_lookup.delete;
    g_cache_elpesa_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpesa_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpesa_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpesa_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpesa_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpesa_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpesa_lookup(l_index).starttorele_num ..
    g_cache_elpesa_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpesa_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpesa_getcacdets;
--
procedure elpels_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpels_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpels_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_los_prte_f els,
                         ben_los_fctr lsf
                  where  p_effective_date
                         between els.effective_start_date
                         and     els.effective_end_date
                  and    els.los_fctr_id = lsf.los_fctr_id
                  and    els.business_group_id = lsf.business_group_id
                  and    els.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpels_inst is
    select els.eligy_prfl_id,
           els.elig_los_prte_id pk_id,
           'ELS' short_code,
           els.los_fctr_id,
           els.excld_flag,
           els.criteria_score,
           els.criteria_weight,
           lsf.mx_los_num,
           lsf.mn_los_num,
           lsf.no_mx_los_num_apls_flag,
           lsf.no_mn_los_num_apls_flag
    from   ben_elig_los_prte_f els,
           ben_los_fctr lsf
    where  p_effective_date
           between els.effective_start_date
           and     els.effective_end_date
    and    els.los_fctr_id = lsf.los_fctr_id
    and    els.business_group_id = lsf.business_group_id
    order  by els.eligy_prfl_id,
           decode(els.excld_flag,'Y',1,2),
           els.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpels_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpels_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpels_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpels_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpels_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpels_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpels_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpels_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpels_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpels_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpels_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpels_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpels_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpels_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpels_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpels_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpels_inst(l_torrwnum).los_fctr_id := objinst.los_fctr_id;
    g_cache_elpels_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpels_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpels_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpels_inst(l_torrwnum).mx_los_num := objinst.mx_los_num;
    g_cache_elpels_inst(l_torrwnum).mn_los_num := objinst.mn_los_num;
    g_cache_elpels_inst(l_torrwnum).no_mx_los_num_apls_flag := objinst.no_mx_los_num_apls_flag;
    g_cache_elpels_inst(l_torrwnum).no_mn_los_num_apls_flag := objinst.no_mn_los_num_apls_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpels_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpels_writecache;
--
procedure elpels_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpels_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpels_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpels_lookup.delete;
    g_cache_elpels_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpels_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpels_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpels_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpels_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpels_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpels_lookup(l_index).starttorele_num ..
    g_cache_elpels_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpels_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpels_getcacdets;
--
procedure elpecp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpecp_writecache';
  --
  l_torrwnum pls_integer;
  --
  l_prev_id number;
  l_id number;
  --
  cursor c_elpecp_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_cmbn_age_los_prte_f ecp,
                         ben_cmbn_age_los_fctr cla
                  where  ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
                  and    ecp.business_group_id = cla.business_group_id
                  and    p_effective_date
                         between ecp.effective_start_date
                         and     ecp.effective_end_date
                  and    ecp.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpecp_inst is
    select ecp.eligy_prfl_id,
           ecp.elig_cmbn_age_los_prte_id pk_id,
           'ECP' short_code,
           ecp.cmbn_age_los_fctr_id,
           ecp.excld_flag,
           ecp.criteria_score,
           ecp.criteria_weight,
           cla.cmbnd_min_val,
           cla.cmbnd_max_val,
           cla.los_fctr_id,
           cla.age_fctr_id
    from   ben_elig_cmbn_age_los_prte_f ecp,
           ben_cmbn_age_los_fctr cla
    where  ecp.cmbn_age_los_fctr_id = cla.cmbn_age_los_fctr_id
    and    ecp.business_group_id = cla.business_group_id
    and    p_effective_date
           between ecp.effective_start_date
           and     ecp.effective_end_date
    order  by ecp.eligy_prfl_id,
           decode(ecp.excld_flag,'Y',1,2),
           ecp.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpecp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpecp_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpecp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpecp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecp_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpecp_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpecp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpecp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpecp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpecp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpecp_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpecp_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpecp_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpecp_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpecp_inst(l_torrwnum).cmbn_age_los_fctr_id := objinst.cmbn_age_los_fctr_id;
    g_cache_elpecp_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpecp_inst(l_torrwnum).cmbnd_min_val := objinst.cmbnd_min_val;
    g_cache_elpecp_inst(l_torrwnum).cmbnd_max_val := objinst.cmbnd_max_val;
    g_cache_elpecp_inst(l_torrwnum).los_fctr_id := objinst.los_fctr_id;
    g_cache_elpecp_inst(l_torrwnum).age_fctr_id := objinst.age_fctr_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpecp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpecp_writecache;
--
procedure elpecp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpecp_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpecp_lookup.delete;
    g_cache_elpecp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpecp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpecp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpecp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpecp_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpecp_lookup(l_index).starttorele_num ..
    g_cache_elpecp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpecp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpecp_getcacdets;
--
procedure elpewl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpewl_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpewl_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_wk_loc_prte_f ewl
                  where  p_effective_date
                         between ewl.effective_start_date
                         and     ewl.effective_end_date
                  and    ewl.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpewl_inst is
    select ewl.eligy_prfl_id,
           ewl.elig_wk_loc_prte_id pk_id,
           'EWL' short_code,
           ewl.location_id,
           ewl.excld_flag,
           ewl.criteria_score,
           ewl.criteria_weight
    from   ben_elig_wk_loc_prte_f ewl
    where  p_effective_date
           between ewl.effective_start_date
           and     ewl.effective_end_date
    order  by ewl.eligy_prfl_id,
           decode(ewl.excld_flag,'Y',1,2),
           ewl.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpewl_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpewl_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpewl_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpewl_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpewl_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpewl_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpewl_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpewl_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpewl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpewl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpewl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpewl_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpewl_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpewl_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpewl_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpewl_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpewl_inst(l_torrwnum).location_id := objinst.location_id;
    g_cache_elpewl_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpewl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpewl_writecache;
--
procedure elpewl_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpewl_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpewl_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpewl_lookup.delete;
    g_cache_elpewl_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpewl_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpewl_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpewl_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpewl_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpewl_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpewl_lookup(l_index).starttorele_num ..
    g_cache_elpewl_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpewl_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpewl_getcacdets;
--
procedure elpeou_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeou_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeou_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_org_unit_prte_f eou
                  where  p_effective_date
                         between eou.effective_start_date
                         and     eou.effective_end_date
                  and    eou.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeou_inst is
    select eou.eligy_prfl_id,
           eou.elig_org_unit_prte_id pk_id,
           'EOU' short_code,
           eou.organization_id,
           eou.excld_flag,
           eou.criteria_score,
           eou.criteria_weight
    from   ben_elig_org_unit_prte_f eou
    where  p_effective_date
           between eou.effective_start_date
           and     eou.effective_end_date
    order  by eou.eligy_prfl_id,
           decode(eou.excld_flag,'Y',1,2),
           eou.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeou_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeou_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeou_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpeou_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeou_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeou_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeou_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeou_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeou_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeou_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeou_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeou_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeou_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpeou_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpeou_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpeou_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpeou_inst(l_torrwnum).organization_id := objinst.organization_id;
    g_cache_elpeou_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeou_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeou_writecache;
--
procedure elpeou_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeou_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeou_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeou_lookup.delete;
    g_cache_elpeou_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeou_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeou_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeou_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeou_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeou_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeou_lookup(l_index).starttorele_num ..
    g_cache_elpeou_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeou_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeou_getcacdets;
--
procedure elpehs_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpehs_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpehs_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_hrly_slrd_prte_f ehs
                  where  p_effective_date
                         between ehs.effective_start_date
                         and     ehs.effective_end_date
                  and    ehs.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpehs_inst is
    select ehs.eligy_prfl_id,
           ehs.elig_hrly_slrd_prte_id pk_id,
           'EHS' short_code,
           ehs.hrly_slrd_cd,
           ehs.excld_flag,
           ehs.criteria_score,
           ehs.criteria_weight
    from   ben_elig_hrly_slrd_prte_f ehs
    where  p_effective_date
           between ehs.effective_start_date
           and ehs.effective_end_date
    order  by ehs.eligy_prfl_id,
           decode(ehs.excld_flag,'Y',1,2),
           ehs.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpehs_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpehs_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpehs_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpehs_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpehs_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpehs_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpehs_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpehs_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpehs_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpehs_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpehs_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpehs_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpehs_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpehs_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpehs_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpehs_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpehs_inst(l_torrwnum).hrly_slrd_cd := objinst.hrly_slrd_cd;
    g_cache_elpehs_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpehs_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpehs_writecache;
--
procedure elpehs_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpehs_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpehs_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
--  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpehs_lookup.delete;
    g_cache_elpehs_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpehs_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpehs_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
--  hr_utility.set_location('Done write cache : '||l_proc,20);
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpehs_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpehs_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
    --  hr_utility.set_location('Hashing  '||l_proc,40);
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpehs_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
--  hr_utility.set_location('Populate  '||l_proc,80);
  for l_insttorrw_num in g_cache_elpehs_lookup(l_index).starttorele_num ..
    g_cache_elpehs_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpehs_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
--  hr_utility.set_location('Leaving : '||l_proc,100);
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpehs_getcacdets;
--
procedure elpefp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpefp_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpefp_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_fl_tm_pt_tm_prte_f efp
                  where  p_effective_date
                         between efp.effective_start_date
                         and     efp.effective_end_date
                  and efp.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpefp_inst is
    select efp.eligy_prfl_id,
           efp.elig_fl_tm_pt_tm_prte_id pk_id,
           'EFP' short_code,
           efp.fl_tm_pt_tm_cd,
           efp.excld_flag,
           efp.criteria_score,
           efp.criteria_weight
    from   ben_elig_fl_tm_pt_tm_prte_f efp
    where  p_effective_date
           between efp.effective_start_date
           and efp.effective_end_date
    order  by efp.eligy_prfl_id,
           decode(efp.excld_flag,'Y',1,2),
           efp.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpefp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpefp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpefp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpefp_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpefp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpefp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpefp_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpefp_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpefp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpefp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpefp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpefp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpefp_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpefp_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpefp_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpefp_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpefp_inst(l_torrwnum).fl_tm_pt_tm_cd := objinst.fl_tm_pt_tm_cd;
    g_cache_elpefp_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpefp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpefp_writecache;
--
procedure elpefp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpefp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpefp_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpefp_lookup.delete;
    g_cache_elpefp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpefp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpefp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpefp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpefp_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpefp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpefp_lookup(l_index).starttorele_num ..
    g_cache_elpefp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpefp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpefp_getcacdets;
--
procedure elpesh_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpesh_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpesh_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and elp.effective_end_date
    and    exists(select null
                  from   ben_elig_schedd_hrs_prte_f esh
                  where  p_effective_date
                         between esh.effective_start_date
                         and     esh.effective_end_date
                  and    esh.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpesh_inst is
    select esh.eligy_prfl_id,
           esh.elig_schedd_hrs_prte_id pk_id,
           'ESH' short_code,
           esh.hrs_num,
           esh.determination_cd,
           esh.determination_rl,
           esh.rounding_cd,
           esh.rounding_rl,
           esh.max_hrs_num,
           esh.schedd_hrs_rl,
           esh.freq_cd,
           esh.excld_flag,
           esh.criteria_score,
           esh.criteria_weight
    from   ben_elig_schedd_hrs_prte_f esh
    where  p_effective_date
           between esh.effective_start_date
           and     esh.effective_end_date
    order  by esh.eligy_prfl_id,
           decode(esh.excld_flag,'Y',1,2),
           esh.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpesh_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpesh_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpesh_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpesh_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpesh_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpesh_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpesh_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpesh_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpesh_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpesh_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpesh_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpesh_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpesh_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpesh_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpesh_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpesh_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpesh_inst(l_torrwnum).hrs_num := objinst.hrs_num;
    g_cache_elpesh_inst(l_torrwnum).determination_cd:= objinst.determination_cd;
    g_cache_elpesh_inst(l_torrwnum).determination_rl:= objinst.determination_rl;
    g_cache_elpesh_inst(l_torrwnum).rounding_cd:= objinst.rounding_cd;
    g_cache_elpesh_inst(l_torrwnum).rounding_rl:= objinst.rounding_rl;
    g_cache_elpesh_inst(l_torrwnum).max_hrs_num:= objinst.max_hrs_num;
    g_cache_elpesh_inst(l_torrwnum).schedd_hrs_rl:= objinst.schedd_hrs_rl;
    g_cache_elpesh_inst(l_torrwnum).freq_cd := objinst.freq_cd;
    g_cache_elpesh_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpesh_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpesh_writecache;
--
procedure elpesh_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpesh_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpesh_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpesh_lookup.delete;
    g_cache_elpesh_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpesh_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpesh_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpesh_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpesh_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpesh_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpesh_lookup(l_index).starttorele_num ..
    g_cache_elpesh_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpesh_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpesh_getcacdets;
--
procedure elpehw_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpehw_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpehw_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_hrs_wkd_prte_f ecl,
                         ben_hrs_wkd_in_perd_fctr clf
                  where  ecl.hrs_wkd_in_perd_fctr_id =
                         clf.hrs_wkd_in_perd_fctr_id
                  and    ecl.business_group_id = clf.business_group_id
                  and    p_effective_date
                         between ecl.effective_start_date
                         and     ecl.effective_end_date
                  and    ecl.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpehw_inst is
    select ecl.eligy_prfl_id,
           ecl.elig_hrs_wkd_prte_id pk_id,
           'EHW' short_code,
           ecl.hrs_wkd_in_perd_fctr_id,
           ecl.excld_flag,
           ecl.criteria_score,
           ecl.criteria_weight,
           clf.mn_hrs_num,
           clf.mx_hrs_num,
           clf.no_mn_hrs_wkd_flag,
           clf.no_mx_hrs_wkd_flag,
           clf.hrs_src_cd
    from   ben_elig_hrs_wkd_prte_f ecl,
           ben_hrs_wkd_in_perd_fctr clf
    where  ecl.hrs_wkd_in_perd_fctr_id = clf.hrs_wkd_in_perd_fctr_id
    and    ecl.business_group_id = clf.business_group_id
    and    p_effective_date
           between ecl.effective_start_date
           and     ecl.effective_end_date
    order  by ecl.eligy_prfl_id,
           decode(ecl.excld_flag,'Y',1,2),
           ecl.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpehw_look loop
  --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpehw_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpehw_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpehw_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpehw_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpehw_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpehw_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpehw_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpehw_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpehw_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpehw_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpehw_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpehw_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpehw_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpehw_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpehw_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpehw_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpehw_inst(l_torrwnum).mn_hrs_num := objinst.mn_hrs_num;
    g_cache_elpehw_inst(l_torrwnum).mx_hrs_num := objinst.mx_hrs_num;
    g_cache_elpehw_inst(l_torrwnum).no_mn_hrs_wkd_flag := objinst.no_mn_hrs_wkd_flag;
    g_cache_elpehw_inst(l_torrwnum).no_mx_hrs_wkd_flag := objinst.no_mx_hrs_wkd_flag;
    g_cache_elpehw_inst(l_torrwnum).hrs_src_cd := objinst.hrs_src_cd;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpehw_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpehw_writecache;
--
procedure elpehw_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_hrs_src_cd        in  varchar2 default null,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpehw_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpehw_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpehw_lookup.delete;
    g_cache_elpehw_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpehw_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpehw_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpehw_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpehw_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpehw_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpehw_lookup(l_index).starttorele_num ..
    g_cache_elpehw_lookup(l_index).endtorele_num loop
    --
    if nvl(g_cache_elpehw_inst(l_insttorrw_num).hrs_src_cd,'ZZZZZ') = nvl(p_hrs_src_cd,'XXXXX') then
      --
      p_inst_set(l_torrwnum) := g_cache_elpehw_inst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end if;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpehw_getcacdets;
--
procedure elpecl_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpecl_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpecl_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and elp.effective_end_date
    and    exists(select null
                  from   ben_elig_comp_lvl_prte_f ecl,
                         ben_comp_lvl_fctr clf
                  where  ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
                  and    ecl.business_group_id = clf.business_group_id
                  and    p_effective_date
                         between ecl.effective_start_date
                         and     ecl.effective_end_date
                  and ecl.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpecl_inst is
    select ecl.eligy_prfl_id,
           ecl.elig_comp_lvl_prte_id pk_id,
           'ECL' short_code,
           ecl.excld_flag,
           ecl.criteria_score,
           ecl.criteria_weight,
           clf.mn_comp_val,
           clf.mx_comp_val,
           clf.no_mn_comp_flag,
           clf.no_mx_comp_flag,
           clf.comp_src_cd,
           clf.comp_lvl_fctr_id
    from   ben_elig_comp_lvl_prte_f ecl,
           ben_comp_lvl_fctr clf
    where  ecl.comp_lvl_fctr_id = clf.comp_lvl_fctr_id
    and    ecl.business_group_id = clf.business_group_id
    and    p_effective_date
           between ecl.effective_start_date
           and     ecl.effective_end_date
    order  by ecl.eligy_prfl_id,
           decode(ecl.excld_flag,'Y',1,2),
           ecl.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpecl_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecl_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecl_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpecl_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpecl_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpecl_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecl_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpecl_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpecl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpecl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpecl_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpecl_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpecl_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpecl_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpecl_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpecl_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpecl_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpecl_inst(l_torrwnum).mn_comp_val := objinst.mn_comp_val;
    g_cache_elpecl_inst(l_torrwnum).mx_comp_val := objinst.mx_comp_val;
    g_cache_elpecl_inst(l_torrwnum).no_mn_comp_flag := objinst.no_mn_comp_flag;
    g_cache_elpecl_inst(l_torrwnum).no_mx_comp_flag := objinst.no_mx_comp_flag;
    g_cache_elpecl_inst(l_torrwnum).comp_src_cd := objinst.comp_src_cd;
    g_cache_elpecl_inst(l_torrwnum).comp_lvl_fctr_id := objinst.comp_lvl_fctr_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpecl_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpecl_writecache;
--
procedure elpecl_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_comp_src_cd       in  varchar2 default null,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecl_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpecl_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpecl_lookup.delete;
    g_cache_elpecl_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpecl_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpecl_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpecl_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpecl_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecl_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpecl_lookup(l_index).starttorele_num ..
    g_cache_elpecl_lookup(l_index).endtorele_num loop
    --
    if nvl(g_cache_elpecl_inst(l_insttorrw_num).comp_src_cd,'ZZZZZ') = nvl(p_comp_src_cd,'XXXXX') then
      --
      p_inst_set(l_torrwnum) := g_cache_elpecl_inst(l_insttorrw_num);
      l_torrwnum := l_torrwnum+1;
      --
    end if;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpecl_getcacdets;
--
procedure elpepf_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepf_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepf_look is
    select epl.eligy_prfl_id,
           epl.business_group_id
    from   ben_eligy_prfl_f epl
    where  p_effective_date
           between epl.effective_start_date
           and     epl.effective_end_date
    and    exists(select null
                  from   ben_elig_pct_fl_tm_prte_f epf,
                         ben_pct_fl_tm_fctr pff
                  where  epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
                  and    epf.business_group_id = pff.business_group_id
                  and    p_effective_date
                         between epf.effective_start_date
                         and     epf.effective_end_date
                  and epf.eligy_prfl_id = epl.eligy_prfl_id)
    order  by epl.eligy_prfl_id;
  --
  cursor c_elpepf_inst is
    select epf.eligy_prfl_id,
           epf.elig_pct_fl_tm_prte_id pk_id,
           'EPF' short_code,
           epf.pct_fl_tm_fctr_id,
           epf.excld_flag,
           epf.criteria_score,
           epf.criteria_weight,
           pff.mx_pct_val,
           pff.mn_pct_val,
           pff.no_mn_pct_val_flag,
           pff.no_mx_pct_val_flag
    from   ben_elig_pct_fl_tm_prte_f epf,
           ben_pct_fl_tm_fctr pff
    where  epf.pct_fl_tm_fctr_id = pff.pct_fl_tm_fctr_id
    and    epf.business_group_id = pff.business_group_id
    and    p_effective_date
           between epf.effective_start_date
           and     epf.effective_end_date
    order  by epf.eligy_prfl_id,
           decode(epf.excld_flag,'Y',1,2),
           epf.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepf_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepf_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepf_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepf_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepf_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepf_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepf_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepf_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepf_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepf_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepf_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepf_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepf_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpepf_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpepf_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpepf_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpepf_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpepf_inst(l_torrwnum).mx_pct_val := objinst.mx_pct_val;
    g_cache_elpepf_inst(l_torrwnum).mn_pct_val := objinst.mn_pct_val;
    g_cache_elpepf_inst(l_torrwnum).no_mn_pct_val_flag := objinst.no_mn_pct_val_flag;
    g_cache_elpepf_inst(l_torrwnum).no_mx_pct_val_flag := objinst.no_mx_pct_val_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepf_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepf_writecache;
--
procedure elpepf_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepf_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepf_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepf_lookup.delete;
    g_cache_elpepf_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepf_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepf_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepf_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepf_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepf_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepf_lookup(l_index).starttorele_num ..
    g_cache_elpepf_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepf_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepf_getcacdets;
--
procedure elpegr_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpegr_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpegr_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_grd_prte_f egr
                  where  p_effective_date
                         between egr.effective_start_date
                         and     egr.effective_end_date
                  and    egr.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpegr_inst is
    select egr.eligy_prfl_id,
           egr.elig_grd_prte_id pk_id,
           'EGR' short_code,
           egr.grade_id,
           egr.excld_flag,
           egr.criteria_score,
           egr.criteria_weight
    from   ben_elig_grd_prte_f egr
    where  p_effective_date
           between egr.effective_start_date
           and     egr.effective_end_date
    order  by egr.eligy_prfl_id,
           decode(egr.excld_flag,'Y',1,2),
           egr.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpegr_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpegr_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpegr_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpegr_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpegr_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpegr_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpegr_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpegr_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpegr_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpegr_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpegr_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpegr_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpegr_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpegr_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpegr_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpegr_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpegr_inst(l_torrwnum).grade_id := objinst.grade_id;
    g_cache_elpegr_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpegr_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpegr_writecache;
--
procedure elpegr_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpegr_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpegr_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpegr_lookup.delete;
    g_cache_elpegr_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpegr_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpegr_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpegr_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpegr_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpegr_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpegr_lookup(l_index).starttorele_num ..
    g_cache_elpegr_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpegr_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpegr_getcacdets;
--
procedure elpegn_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpegn_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpegn_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_grd_prte_f egn
                  where  p_effective_date
                         between egn.effective_start_date
                         and     egn.effective_end_date
                  and    egn.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpegn_inst is
    select egn.eligy_prfl_id,
           egn.elig_gndr_prte_id pk_id,
           'EGN' short_code,
           egn.sex,
           egn.excld_flag,
           egn.criteria_score,
           egn.criteria_weight
    from   ben_elig_gndr_prte_f egn
    where  p_effective_date
           between egn.effective_start_date
           and     egn.effective_end_date
    order  by egn.eligy_prfl_id,
           decode(egn.excld_flag,'Y',1,2),
           egn.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpegn_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpegn_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpegn_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpegn_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpegn_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpegn_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpegn_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpegn_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpegn_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpegn_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpegn_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpegn_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpegn_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpegn_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpegn_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpegn_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpegn_inst(l_torrwnum).sex := objinst.sex;
    g_cache_elpegn_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpegn_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpegn_writecache;
--
procedure elpegn_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpegn_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpegn_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpegn_lookup.delete;
    g_cache_elpegn_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpegn_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpegn_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpegn_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpegn_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpegn_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpegn_lookup(l_index).starttorele_num ..
    g_cache_elpegn_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpegn_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpegn_getcacdets;
--
procedure elpejp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpejp_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpejp_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_job_prte_f ejp
                  where  p_effective_date
                         between ejp.effective_start_date
                         and     ejp.effective_end_date
                  and ejp.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpejp_inst is
    select ejp.eligy_prfl_id,
           ejp.elig_job_prte_id pk_id,
           'EJP' short_code,
           ejp.job_id,
           ejp.excld_flag,
           ejp.criteria_score,
           ejp.criteria_weight
    from   ben_elig_job_prte_f ejp
    where  p_effective_date
           between ejp.effective_start_date
           and ejp.effective_end_date
    order  by ejp.eligy_prfl_id,
           decode(ejp.excld_flag,'Y',1,2),
           ejp.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpejp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpejp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpejp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpejp_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpejp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpejp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpejp_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpejp_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    if l_prev_id = -1 then
      --
      g_cache_elpejp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpejp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpejp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpejp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpejp_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpejp_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpejp_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpejp_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpejp_inst(l_torrwnum).job_id := objinst.job_id;
    g_cache_elpejp_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpejp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpejp_writecache;
--
procedure elpejp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpejp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpejp_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpejp_lookup.delete;
    g_cache_elpejp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpejp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpejp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpejp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpejp_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpejp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpejp_lookup(l_index).starttorele_num ..
    g_cache_elpejp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpejp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpejp_getcacdets;
--
procedure elpepb_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepb_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepb_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_py_bss_prte_f epb
                  where  p_effective_date
                         between epb.effective_start_date
                         and     epb.effective_end_date
                  and    epb.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpepb_inst is
    select epb.eligy_prfl_id,
           epb.elig_py_bss_prte_id pk_id,
           'EPB' short_code,
           epb.pay_basis_id,
           epb.excld_flag,
           epb.criteria_score,
           epb.criteria_weight
    from   ben_elig_py_bss_prte_f epb
    where  p_effective_date
           between epb.effective_start_date
           and     epb.effective_end_date
    order  by epb.eligy_prfl_id,
           decode(epb.excld_flag,'Y',1,2),
           epb.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepb_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepb_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepb_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepb_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepb_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepb_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepb_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepb_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepb_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepb_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepb_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepb_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepb_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpepb_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpepb_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpepb_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpepb_inst(l_torrwnum).pay_basis_id := objinst.pay_basis_id;
    g_cache_elpepb_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepb_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepb_writecache;
--
procedure elpepb_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepb_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepb_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepb_lookup.delete;
    g_cache_elpepb_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepb_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepb_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepb_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepb_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepb_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepb_lookup(l_index).starttorele_num ..
    g_cache_elpepb_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepb_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepb_getcacdets;
--
procedure elpepy_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepy_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepy_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and elp.effective_end_date
    and    exists(select null
                  from   ben_elig_pyrl_prte_f epy
                  where  p_effective_date
                         between epy.effective_start_date
                         and     epy.effective_end_date
                  and    epy.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpepy_inst is
    select epy.eligy_prfl_id,
           epy.elig_pyrl_prte_id pk_id,
           'EPY' short_code,
           epy.payroll_id,
           epy.excld_flag,
           epy.criteria_score,
           epy.criteria_weight
    from   ben_elig_pyrl_prte_f epy
    where  p_effective_date
           between epy.effective_start_date
           and     epy.effective_end_date
    order  by epy.eligy_prfl_id,
           decode(epy.excld_flag,'Y',1,2),
           epy.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepy_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepy_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepy_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepy_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepy_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepy_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepy_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepy_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepy_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepy_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepy_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepy_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepy_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpepy_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpepy_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpepy_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpepy_inst(l_torrwnum).payroll_id := objinst.payroll_id;
    g_cache_elpepy_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepy_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepy_writecache;
--
procedure elpepy_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepy_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepy_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepy_lookup.delete;
    g_cache_elpepy_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepy_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepy_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepy_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepy_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepy_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepy_lookup(l_index).starttorele_num ..
    g_cache_elpepy_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepy_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepy_getcacdets;
--
procedure elpebu_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default false) is
  --
  l_proc varchar2(72) :=  'elpebu_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpebu_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_brgng_unit_prte_f ebu
                  where  p_effective_date
                         between ebu.effective_start_date
                         and     ebu.effective_end_date
                  and    ebu.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpebu_inst is
    select ebu.eligy_prfl_id,
           ebu.elig_brgng_unit_prte_id pk_id,
           'EBU' short_code,
           ebu.brgng_unit_cd,
           ebu.excld_flag,
           ebu.criteria_score,
           ebu.criteria_weight
    from   ben_elig_brgng_unit_prte_f ebu
    where  p_effective_date
           between ebu.effective_start_date
           and     ebu.effective_end_date
    order  by ebu.eligy_prfl_id,
           decode(ebu.excld_flag,'Y',1,2),
           ebu.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpebu_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpebu_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpebu_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpebu_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpebu_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpebu_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpebu_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpebu_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpebu_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpebu_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpebu_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpebu_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpebu_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpebu_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpebu_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpebu_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpebu_inst(l_torrwnum).brgng_unit_cd := objinst.brgng_unit_cd;
    g_cache_elpebu_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpebu_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpebu_writecache;
--
procedure elpebu_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpebu_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpebu_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpebu_lookup.delete;
    g_cache_elpebu_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpebu_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpebu_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpebu_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpebu_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpebu_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpebu_lookup(l_index).starttorele_num ..
    g_cache_elpebu_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpebu_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpebu_getcacdets;
--
procedure elpelu_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpelu_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpelu_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_lbr_mmbr_prte_f elu
                  where  p_effective_date
                         between elu.effective_start_date
                         and     elu.effective_end_date
                  and    elu.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpelu_inst is
    select elu.eligy_prfl_id,
           elu.elig_lbr_mmbr_prte_id pk_id,
           'ELU' short_code,
           elu.lbr_mmbr_flag,
           elu.excld_flag,
           elu.criteria_score,
           elu.criteria_weight
    from   ben_elig_lbr_mmbr_prte_f elu
    where  p_effective_date
           between elu.effective_start_date
           and elu.effective_end_date
    order  by elu.eligy_prfl_id,
           decode(elu.excld_flag,'Y',1,2),
           elu.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpelu_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelu_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelu_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
      --
      end loop;
      --
    end if;
    --
    g_cache_elpelu_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpelu_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpelu_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelu_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpelu_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpelu_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpelu_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpelu_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpelu_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpelu_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpelu_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpelu_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpelu_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpelu_inst(l_torrwnum).lbr_mmbr_flag := objinst.lbr_mmbr_flag;
    g_cache_elpelu_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpelu_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpelu_writecache;
--
procedure elpelu_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelu_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpelu_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpelu_lookup.delete;
    g_cache_elpelu_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpelu_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpelu_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpelu_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpelu_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelu_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpelu_lookup(l_index).starttorele_num ..
    g_cache_elpelu_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpelu_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpelu_getcacdets;
--
procedure elpelr_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpelr_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpelr_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_loa_rsn_prte_f elr
                  where  p_effective_date
                         between elr.effective_start_date
                         and     elr.effective_end_date
                  and elr.eligy_prfl_id = elp.eligy_prfl_id)
    order by elp.eligy_prfl_id;
  --
  cursor c_elpelr_inst is
    select elr.eligy_prfl_id,
           elr.elig_loa_rsn_prte_id pk_id,
           'ELR' short_code,
           elr.absence_attendance_type_id,
           elr.abs_attendance_reason_id,
           elr.excld_flag,
           elr.criteria_score,
           elr.criteria_weight
    from   ben_elig_loa_rsn_prte_f elr
    where  p_effective_date
           between elr.effective_start_date
           and     elr.effective_end_date
    order  by elr.eligy_prfl_id,
           decode(elr.excld_flag,'Y',1,2),
           elr.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpelr_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelr_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelr_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpelr_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpelr_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpelr_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelr_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpelr_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpelr_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpelr_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpelr_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpelr_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpelr_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpelr_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpelr_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpelr_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpelr_inst(l_torrwnum).absence_attendance_type_id := objinst.absence_attendance_type_id;
    g_cache_elpelr_inst(l_torrwnum).abs_attendance_reason_id := objinst.abs_attendance_reason_id;
    g_cache_elpelr_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpelr_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpelr_writecache;
--
procedure elpelr_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelr_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpelr_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpelr_lookup.delete;
    g_cache_elpelr_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpelr_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpelr_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpelr_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpelr_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelr_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpelr_lookup(l_index).starttorele_num ..
    g_cache_elpelr_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpelr_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpelr_getcacdets;
--
procedure elpeap_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeap_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeap_look is
    select elp.eligy_prfl_id, elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and elp.effective_end_date
    and    exists(select null
                  from   ben_elig_age_prte_f eap,
                         ben_age_fctr agf
                  where  eap.age_fctr_id = agf.age_fctr_id
                  and    eap.business_group_id = agf.business_group_id
                  and    p_effective_date
                         between eap.effective_start_date
                         and     eap.effective_end_date
                  and eap.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeap_inst is
    select eap.eligy_prfl_id,
           eap.elig_age_prte_id pk_id,
           'EAP' short_code,
           eap.age_fctr_id,
           eap.excld_flag,
           eap.criteria_score,
           eap.criteria_weight,
           agf.mx_age_num,
           agf.mn_age_num,
           agf.no_mn_age_flag,
           agf.no_mx_age_flag
    from   ben_elig_age_prte_f eap,
           ben_age_fctr agf
    where  eap.age_fctr_id = agf.age_fctr_id
    and    eap.business_group_id = agf.business_group_id
    and    p_effective_date
           between eap.effective_start_date
           and     eap.effective_end_date
    order  by eap.eligy_prfl_id,
           decode(eap.excld_flag,'Y',1,2),
           eap.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeap_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeap_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeap_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeap_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeap_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeap_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeap_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeap_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeap_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeap_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeap_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeap_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeap_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpeap_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpeap_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpeap_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpeap_inst(l_torrwnum).age_fctr_id := objinst.age_fctr_id;
    g_cache_elpeap_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpeap_inst(l_torrwnum).mx_age_num := objinst.mx_age_num;
    g_cache_elpeap_inst(l_torrwnum).mn_age_num := objinst.mn_age_num;
    g_cache_elpeap_inst(l_torrwnum).no_mn_age_flag := objinst.no_mn_age_flag;
    g_cache_elpeap_inst(l_torrwnum).no_mx_age_flag := objinst.no_mx_age_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeap_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeap_writecache;
--
procedure elpeap_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeap_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeap_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeap_lookup.delete;
    g_cache_elpeap_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeap_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeap_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeap_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeap_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeap_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeap_lookup(l_index).starttorele_num ..
    g_cache_elpeap_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeap_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeap_getcacdets;
--
procedure elpepz_writecache
  (p_effective_date in date,
   p_refresh_cache in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepz_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepz_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and elp.effective_end_date
    and    exists(select null
                  from   ben_elig_pstl_cd_r_rng_prte_f epz,
                         ben_pstl_zip_rng_f rzr
                  where  epz.pstl_zip_rng_id = rzr.pstl_zip_rng_id
                  and    epz.business_group_id = rzr.business_group_id
                  and    p_effective_date
                         between rzr.effective_start_date
                         and     rzr.effective_end_date
                  and    p_effective_date
                         between epz.effective_start_date
                         and     epz.effective_end_date
                  and    epz.eligy_prfl_id = elp.eligy_prfl_id)
    order by elp.eligy_prfl_id;
  --
  cursor c_elpepz_inst is
    select epz.eligy_prfl_id,
           epz.elig_pstl_cd_r_rng_prte_id pk_id,
           'EPZ' short_code,
           epz.excld_flag,
           epz.criteria_score,
           epz.criteria_weight,
           rzr.from_value,
           rzr.to_value
    from   ben_elig_pstl_cd_r_rng_prte_f epz,
           ben_pstl_zip_rng_f rzr
    where  epz.pstl_zip_rng_id = rzr.pstl_zip_rng_id
    and    epz.business_group_id = rzr.business_group_id
    and    p_effective_date
           between rzr.effective_start_date
           and     rzr.effective_end_date
    and    p_effective_date
           between epz.effective_start_date
           and     epz.effective_end_date
    order  by epz.eligy_prfl_id,
           decode(epz.excld_flag,'Y',1,2),
           epz.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepz_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepz_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepz_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepz_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepz_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepz_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepz_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepz_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepz_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepz_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepz_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepz_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepz_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpepz_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpepz_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpepz_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpepz_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpepz_inst(l_torrwnum).from_value := objinst.from_value;
    g_cache_elpepz_inst(l_torrwnum).to_value := objinst.to_value;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepz_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepz_writecache;
--
procedure elpepz_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepz_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepz_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepz_lookup.delete;
    g_cache_elpepz_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepz_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepz_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepz_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepz_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepz_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepz_lookup(l_index).starttorele_num ..
    g_cache_elpepz_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepz_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepz_getcacdets;
--
procedure elpebn_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpebn_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpebn_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_benfts_grp_prte_f ebn
                  where  p_effective_date
                         between ebn.effective_start_date
                         and     ebn.effective_end_date
                  and    ebn.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpebn_inst is
    select ebn.eligy_prfl_id,
           ebn.elig_benfts_grp_prte_id pk_id,
           'EBN' short_code,
           ebn.benfts_grp_id,
           ebn.excld_flag,
           ebn.criteria_score,
           ebn.criteria_weight
    from   ben_elig_benfts_grp_prte_f ebn
    where  p_effective_date
           between ebn.effective_start_date
           and     ebn.effective_end_date
    order  by ebn.eligy_prfl_id,
           decode(ebn.excld_flag,'Y',1,2),
           ebn.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpebn_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpebn_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpebn_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpebn_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpebn_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpebn_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpebn_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpebn_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpebn_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpebn_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpebn_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpebn_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpebn_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpebn_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpebn_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpebn_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpebn_inst(l_torrwnum).benfts_grp_id := objinst.benfts_grp_id;
    g_cache_elpebn_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpebn_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpebn_writecache;
--
procedure elpebn_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpebn_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpebn_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpebn_lookup.delete;
    g_cache_elpebn_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpebn_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpebn_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpebn_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpebn_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpebn_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpebn_lookup(l_index).starttorele_num ..
    g_cache_elpebn_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpebn_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpebn_getcacdets;
--
procedure elpeln_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeln_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeln_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and exists(select null
               from   ben_elig_lgl_enty_prte_f eln,
                      hr_all_organization_units hao
               where  eln.organization_id = hao.organization_id
               and    eln.business_group_id = hao.business_group_id
               and    p_effective_date
                      between eln.effective_start_date
                      and     eln.effective_end_date
               and eln.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeln_inst is
    select eln.eligy_prfl_id,
           eln.elig_lgl_enty_prte_id pk_id,
           'ELN' short_code,
           eln.excld_flag,
           eln.criteria_score,
           eln.criteria_weight,
           hao.name
    from   ben_elig_lgl_enty_prte_f eln,
           hr_all_organization_units hao
    where  eln.organization_id = hao.organization_id
    and    eln.business_group_id = hao.business_group_id
    and    p_effective_date
           between eln.effective_start_date
           and     eln.effective_end_date
    order  by eln.eligy_prfl_id,
           decode(eln.excld_flag,'Y',1,2),
           eln.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeln_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeln_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeln_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeln_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeln_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeln_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeln_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeln_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeln_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeln_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeln_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeln_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeln_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpeln_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpeln_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpeln_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpeln_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpeln_inst(l_torrwnum).name := objinst.name;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeln_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeln_writecache;
--
procedure elpeln_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_eligy_prfl_id     in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeln_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeln_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeln_lookup.delete;
    g_cache_elpeln_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeln_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeln_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeln_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeln_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeln_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeln_lookup(l_index).starttorele_num ..
    g_cache_elpeln_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeln_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeln_getcacdets;
--
procedure elpepp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpepp_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpepp_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_prtt_anthr_pl_prte_f epp
                  where  p_effective_date
                         between epp.effective_start_date
                         and     epp.effective_end_date
                  and    epp.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpepp_inst is
    select epp.eligy_prfl_id,
           epp.pl_id,
           epp.excld_flag
    from   ben_elig_prtt_anthr_pl_prte_f epp
    where  p_effective_date
           between epp.effective_start_date
           and     epp.effective_end_date
    order  by epp.eligy_prfl_id,
           decode(epp.excld_flag,'Y',1,2),
           epp.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpepp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpepp_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpepp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpepp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpepp_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpepp_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpepp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpepp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpepp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpepp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpepp_inst(l_torrwnum).pl_id := objinst.pl_id;
    g_cache_elpepp_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpepp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpepp_writecache;
--
procedure elpepp_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpepp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpepp_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpepp_lookup.delete;
    g_cache_elpepp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpepp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpepp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpepp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpepp_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpepp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpepp_lookup(l_index).starttorele_num ..
    g_cache_elpepp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpepp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpepp_getcacdets;
--
procedure elpeoy_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeoy_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeoy_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_othr_ptip_prte_f eoy
                  where  p_effective_date
                         between eoy.effective_start_date
                         and     eoy.effective_end_date
                  and    eoy.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeoy_inst is
    select eoy.eligy_prfl_id,
           eoy.ptip_id,
           eoy.only_pls_subj_cobra_flag,
           eoy.excld_flag
    from   ben_elig_othr_ptip_prte_f eoy
    where  p_effective_date
           between eoy.effective_start_date
           and     eoy.effective_end_date
    order  by eoy.eligy_prfl_id,
           decode(eoy.excld_flag,'Y',1,2),
           eoy.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeoy_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeoy_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeoy_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeoy_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeoy_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeoy_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeoy_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeoy_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeoy_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeoy_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeoy_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeoy_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeoy_inst(l_torrwnum).ptip_id := objinst.ptip_id;
    g_cache_elpeoy_inst(l_torrwnum).only_pls_subj_cobra_flag :=
                                    objinst.only_pls_subj_cobra_flag;
    g_cache_elpeoy_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeoy_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeoy_writecache;
--
procedure elpeoy_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeoy_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeoy_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeoy_lookup.delete;
    g_cache_elpeoy_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeoy_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeoy_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeoy_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeoy_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeoy_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeoy_lookup(l_index).starttorele_num ..
    g_cache_elpeoy_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeoy_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeoy_getcacdets;
--
/************************************************/
procedure elpetd_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpetd_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpetd_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_dpnt_othr_ptip_f etd
                  where  p_effective_date
                         between etd.effective_start_date
                         and     etd.effective_end_date
                  and    etd.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpetd_inst is
    select etd.eligy_prfl_id,
           etd.ptip_id,
           --etd.only_pls_subj_cobra_flag,
           etd.excld_flag
    from   ben_elig_dpnt_othr_ptip_f etd
    where  p_effective_date
           between etd.effective_start_date
           and     etd.effective_end_date
    order  by etd.eligy_prfl_id,
           decode(etd.excld_flag,'Y',1,2),
           etd.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpetd_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpetd_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpetd_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpetd_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpetd_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpetd_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpetd_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpetd_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpetd_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpetd_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpetd_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpetd_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpetd_inst(l_torrwnum).ptip_id := objinst.ptip_id;
   -- g_cache_elpetd_inst(l_torrwnum).only_pls_subj_cobra_flag :=
    --                                objinst.only_pls_subj_cobra_flag;
    g_cache_elpetd_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpetd_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpetd_writecache;
--
procedure elpetd_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpetd_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpetd_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpetd_lookup.delete;
    g_cache_elpetd_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpetd_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpetd_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpetd_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpetd_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
       --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index)
;
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpetd_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
 end if;
  --
  for l_insttorrw_num in g_cache_elpetd_lookup(l_index).starttorele_num ..
    g_cache_elpetd_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpetd_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpetd_getcacdets;
--
/************************************************/
procedure elpeno_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeno_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeno_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_no_othr_cvg_prte_f eno
                  where  p_effective_date
                         between eno.effective_start_date
                         and     eno.effective_end_date
                  and    eno.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeno_inst is
    select eno.eligy_prfl_id,
           eno.coord_ben_no_cvg_flag
    from   ben_elig_no_othr_cvg_prte_f eno
    where  p_effective_date
           between eno.effective_start_date
           and     eno.effective_end_date
    order  by eno.eligy_prfl_id;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeno_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeno_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeno_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeno_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeno_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeno_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeno_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeno_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeno_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeno_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeno_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeno_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeno_inst(l_torrwnum).coord_ben_no_cvg_flag :=
                                    objinst.coord_ben_no_cvg_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeno_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeno_writecache;
--
procedure elpeno_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeno_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeno_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeno_lookup.delete;
    g_cache_elpeno_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeno_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeno_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeno_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeno_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeno_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeno_lookup(l_index).starttorele_num ..
    g_cache_elpeno_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeno_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeno_getcacdets;
--
procedure elpeep_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeep_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeep_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_enrld_anthr_pl_f eep
                  where  p_effective_date
                         between eep.effective_start_date
                         and     eep.effective_end_date
                  and    eep.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeep_inst is
    select eep.eligy_prfl_id,
           eep.pl_id,
           eep.enrl_det_dt_cd,
           eep.excld_flag
    from   ben_elig_enrld_anthr_pl_f eep
    where  p_effective_date
           between eep.effective_start_date
           and     eep.effective_end_date
    order  by eep.eligy_prfl_id,
           decode(eep.excld_flag,'Y',1,2),
           eep.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeep_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeep_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeep_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeep_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeep_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeep_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeep_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeep_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeep_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeep_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeep_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeep_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeep_inst(l_torrwnum).pl_id := objinst.pl_id;
    g_cache_elpeep_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpeep_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeep_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeep_writecache;
--
procedure elpeep_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeep_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeep_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeep_lookup.delete;
    g_cache_elpeep_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeep_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeep_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeep_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeep_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeep_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeep_lookup(l_index).starttorele_num ..
    g_cache_elpeep_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeep_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeep_getcacdets;
--
procedure elpeei_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeei_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeei_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_enrld_anthr_oipl_f eei
                  where  p_effective_date
                         between eei.effective_start_date
                         and     eei.effective_end_date
                  and    eei.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeei_inst is
    select eei.eligy_prfl_id,
           eei.oipl_id,
           eei.enrl_det_dt_cd,
           eei.excld_flag
    from   ben_elig_enrld_anthr_oipl_f eei
    where  p_effective_date
           between eei.effective_start_date
           and     eei.effective_end_date
    order  by eei.eligy_prfl_id,
           decode(eei.excld_flag,'Y',1,2),
           eei.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeei_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeei_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeei_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeei_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeei_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeei_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeei_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeei_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeei_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeei_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeei_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeei_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeei_inst(l_torrwnum).oipl_id := objinst.oipl_id;
    g_cache_elpeei_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpeei_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeei_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeei_writecache;
--
procedure elpeei_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeei_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeei_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeei_lookup.delete;
    g_cache_elpeei_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeei_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeei_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeei_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeei_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeei_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeei_lookup(l_index).starttorele_num ..
    g_cache_elpeei_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeei_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeei_getcacdets;
--
procedure elpeeg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeeg_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeeg_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_enrld_anthr_pgm_f eeg
                  where  p_effective_date
                         between eeg.effective_start_date
                         and     eeg.effective_end_date
                  and    eeg.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeeg_inst is
    select eeg.eligy_prfl_id,
           eeg.pgm_id,
           eeg.enrl_det_dt_cd,
           eeg.excld_flag
    from   ben_elig_enrld_anthr_pgm_f eeg
    where  p_effective_date
           between eeg.effective_start_date
           and     eeg.effective_end_date
    order  by eeg.eligy_prfl_id,
           decode(eeg.excld_flag,'Y',1,2),
           eeg.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeeg_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeeg_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeeg_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeeg_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeeg_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeeg_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeeg_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeeg_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeeg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeeg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeeg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeeg_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeeg_inst(l_torrwnum).pgm_id := objinst.pgm_id;
    g_cache_elpeeg_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpeeg_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeeg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeeg_writecache;
--
procedure elpeeg_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeeg_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeeg_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeeg_lookup.delete;
    g_cache_elpeeg_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeeg_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeeg_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeeg_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeeg_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeeg_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeeg_lookup(l_index).starttorele_num ..
    g_cache_elpeeg_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeeg_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeeg_getcacdets;
--
procedure elpedp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpedp_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpedp_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_dpnt_cvrd_othr_pl_f edp
                  where  p_effective_date
                         between edp.effective_start_date
                         and     edp.effective_end_date
                  and    edp.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpedp_inst is
    select edp.eligy_prfl_id,
           edp.pl_id,
           edp.cvg_det_dt_cd,
           edp.excld_flag
    from   ben_elig_dpnt_cvrd_othr_pl_f edp
    where  p_effective_date
           between edp.effective_start_date
           and     edp.effective_end_date
    order  by edp.eligy_prfl_id,
           decode(edp.excld_flag,'Y',1,2),
           edp.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpedp_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedp_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedp_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpedp_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpedp_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpedp_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedp_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpedp_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpedp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpedp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpedp_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpedp_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpedp_inst(l_torrwnum).pl_id := objinst.pl_id;
    g_cache_elpedp_inst(l_torrwnum).cvg_det_dt_cd := objinst.cvg_det_dt_cd;
    g_cache_elpedp_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpedp_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpedp_writecache;
--
procedure elpedp_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedp_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpedp_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpedp_lookup.delete;
    g_cache_elpedp_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpedp_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpedp_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpedp_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpedp_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedp_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpedp_lookup(l_index).starttorele_num ..
    g_cache_elpedp_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpedp_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpedp_getcacdets;
--
procedure elpelv_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpelv_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpelv_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_lvg_rsn_prte_f elv
                  where  p_effective_date
                         between elv.effective_start_date
                         and     elv.effective_end_date
                  and    elv.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpelv_inst is
    select elv.eligy_prfl_id,
           elv.elig_lvg_rsn_prte_id pk_id,
           'ELV' short_code,
           elv.lvg_rsn_cd,
           elv.excld_flag,
           elv.criteria_score,
           elv.criteria_weight
    from   ben_elig_lvg_rsn_prte_f elv
    where  p_effective_date
           between elv.effective_start_date
           and     elv.effective_end_date
    order  by elv.eligy_prfl_id,
           decode(elv.excld_flag,'Y',1,2),
           elv.ordr_num;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpelv_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelv_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelv_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpelv_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpelv_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpelv_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpelv_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpelv_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpelv_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpelv_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpelv_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpelv_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpelv_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpelv_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpelv_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpelv_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpelv_inst(l_torrwnum).lvg_rsn_cd := objinst.lvg_rsn_cd;
    g_cache_elpelv_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpelv_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpelv_writecache;
--
procedure elpelv_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpelv_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpelv_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpelv_lookup.delete;
    g_cache_elpelv_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpelv_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpelv_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpelv_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpelv_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpelv_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpelv_lookup(l_index).starttorele_num ..
    g_cache_elpelv_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpelv_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpelv_getcacdets;
--
procedure elpeom_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeom_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeom_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_optd_mdcr_prte_f eom
                  where  p_effective_date
                         between eom.effective_start_date
                         and     eom.effective_end_date
                  and    eom.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeom_inst is
    select eom.eligy_prfl_id,
           eom.optd_mdcr_flag,
           eom.exlcd_flag
    from   ben_elig_optd_mdcr_prte_f eom
    where  p_effective_date
           between eom.effective_start_date
           and     eom.effective_end_date
    order  by eom.eligy_prfl_id,
           decode(eom.exlcd_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeom_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeom_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeom_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeom_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeom_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeom_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeom_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeom_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeom_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeom_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeom_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeom_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeom_inst(l_torrwnum).optd_mdcr_flag := objinst.optd_mdcr_flag;
    g_cache_elpeom_inst(l_torrwnum).excld_flag := objinst.exlcd_flag;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeom_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeom_writecache;
--
procedure elpeom_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeom_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeom_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeom_lookup.delete;
    g_cache_elpeom_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeom_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeom_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeom_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeom_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeom_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeom_lookup(l_index).starttorele_num ..
    g_cache_elpeom_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeom_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeom_getcacdets;
--
procedure elpeai_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeai_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeai_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_enrld_anthr_plip_f eai
                  where  p_effective_date
                         between eai.effective_start_date
                         and     eai.effective_end_date
                  and    eai.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeai_inst is
    select eai.eligy_prfl_id,
           eai.enrl_det_dt_cd,
           eai.plip_id,
           eai.excld_flag
    from   ben_elig_enrld_anthr_plip_f eai
    where  p_effective_date
           between eai.effective_start_date
           and     eai.effective_end_date
    order  by eai.eligy_prfl_id,
           decode(eai.excld_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeai_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeai_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeai_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeai_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeai_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeai_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeai_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeai_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeai_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeai_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeai_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeai_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeai_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpeai_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpeai_inst(l_torrwnum).plip_id := objinst.plip_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeai_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeai_writecache;
--
procedure elpeai_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeai_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeai_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeai_lookup.delete;
    g_cache_elpeai_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeai_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeai_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeai_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeai_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeai_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeai_lookup(l_index).starttorele_num ..
    g_cache_elpeai_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeai_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeai_getcacdets;
--
procedure elpedi_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpedi_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpedi_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_dpnt_cvrd_plip_f edi
                  where  p_effective_date
                         between edi.effective_start_date
                         and     edi.effective_end_date
                  and    edi.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpedi_inst is
    select edi.eligy_prfl_id,
           edi.enrl_det_dt_cd,
           edi.plip_id,
           edi.excld_flag
    from   ben_elig_dpnt_cvrd_plip_f edi
    where  p_effective_date
           between edi.effective_start_date
           and     edi.effective_end_date
    order  by edi.eligy_prfl_id,
           decode(edi.excld_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpedi_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedi_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedi_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpedi_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpedi_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpedi_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedi_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpedi_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpedi_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpedi_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpedi_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpedi_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpedi_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpedi_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpedi_inst(l_torrwnum).plip_id := objinst.plip_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpedi_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpedi_writecache;
--
procedure elpedi_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedi_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpedi_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpedi_lookup.delete;
    g_cache_elpedi_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpedi_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpedi_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpedi_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpedi_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedi_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpedi_lookup(l_index).starttorele_num ..
    g_cache_elpedi_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpedi_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpedi_getcacdets;
--
procedure elpeet_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpeet_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpeet_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_enrld_anthr_ptip_f eet
                  where  p_effective_date
                         between eet.effective_start_date
                         and     eet.effective_end_date
                  and    eet.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpeet_inst is
    select eet.eligy_prfl_id,
           eet.excld_flag,
           eet.enrl_det_dt_cd,
           eet.only_pls_subj_cobra_flag,
           eet.ptip_id
    from   ben_elig_enrld_anthr_ptip_f eet
    where  p_effective_date
           between eet.effective_start_date
           and     eet.effective_end_date
    order  by eet.eligy_prfl_id,
           decode(eet.excld_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpeet_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeet_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeet_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpeet_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpeet_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpeet_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpeet_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpeet_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpeet_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpeet_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpeet_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpeet_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpeet_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpeet_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpeet_inst(l_torrwnum).only_pls_subj_cobra_flag := objinst.only_pls_subj_cobra_flag;
    g_cache_elpeet_inst(l_torrwnum).ptip_id := objinst.ptip_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpeet_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpeet_writecache;
--
procedure elpeet_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpeet_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpeet_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpeet_lookup.delete;
    g_cache_elpeet_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpeet_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpeet_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpeet_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpeet_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpeet_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpeet_lookup(l_index).starttorele_num ..
    g_cache_elpeet_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpeet_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpeet_getcacdets;
--
procedure elpedt_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpedt_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpedt_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_dpnt_cvrd_othr_ptip_f edt
                  where  p_effective_date
                         between edt.effective_start_date
                         and     edt.effective_end_date
                  and    edt.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpedt_inst is
    select edt.eligy_prfl_id,
           edt.excld_flag,
           edt.enrl_det_dt_cd,
           edt.only_pls_subj_cobra_flag,
           edt.ptip_id
    from   ben_elig_dpnt_cvrd_othr_ptip_f edt
    where  p_effective_date
           between edt.effective_start_date
           and     edt.effective_end_date
    order  by edt.eligy_prfl_id,
           decode(edt.excld_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpedt_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedt_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedt_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpedt_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpedt_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpedt_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedt_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpedt_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpedt_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpedt_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpedt_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpedt_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpedt_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpedt_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpedt_inst(l_torrwnum).only_pls_subj_cobra_flag := objinst.only_pls_subj_cobra_flag;
    g_cache_elpedt_inst(l_torrwnum).ptip_id := objinst.ptip_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpedt_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpedt_writecache;
--
procedure elpedt_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedt_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpedt_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpedt_lookup.delete;
    g_cache_elpedt_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpedt_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpedt_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpedt_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpedt_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedt_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpedt_lookup(l_index).starttorele_num ..
    g_cache_elpedt_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpedt_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpedt_getcacdets;
--
procedure elpedg_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpedg_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpedg_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_dpnt_cvrd_othr_pgm_f edg
                  where  p_effective_date
                         between edg.effective_start_date
                         and     edg.effective_end_date
                  and    edg.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpedg_inst is
    select edg.eligy_prfl_id,
           edg.excld_flag,
           edg.enrl_det_dt_cd,
           edg.pgm_id
    from   ben_elig_dpnt_cvrd_othr_pgm_f edg
    where  p_effective_date
           between edg.effective_start_date
           and     edg.effective_end_date
    order  by edg.eligy_prfl_id,
           decode(edg.excld_flag,'Y',1,2);
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpedg_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedg_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedg_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpedg_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpedg_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpedg_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpedg_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpedg_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpedg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpedg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpedg_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpedg_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpedg_inst(l_torrwnum).excld_flag := objinst.excld_flag;
    g_cache_elpedg_inst(l_torrwnum).enrl_det_dt_cd := objinst.enrl_det_dt_cd;
    g_cache_elpedg_inst(l_torrwnum).pgm_id := objinst.pgm_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpedg_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpedg_writecache;
--
procedure elpedg_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpedg_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpedg_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpedg_lookup.delete;
    g_cache_elpedg_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpedg_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpedg_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpedg_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpedg_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpedg_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpedg_lookup(l_index).starttorele_num ..
    g_cache_elpedg_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpedg_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpedg_getcacdets;
--
procedure elpecq_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE) is
  --
  l_proc varchar2(72) :=  'elpecq_writecache';
  l_torrwnum pls_integer;
  l_prev_id number;
  l_id number;
  --
  cursor c_elpecq_look is
    select elp.eligy_prfl_id,
           elp.business_group_id
    from   ben_eligy_prfl_f elp
    where  p_effective_date
           between elp.effective_start_date
           and     elp.effective_end_date
    and    exists(select null
                  from   ben_elig_cbr_quald_bnf_f ecq
                  where  p_effective_date
                         between ecq.effective_start_date
                         and     ecq.effective_end_date
                  and    ecq.eligy_prfl_id = elp.eligy_prfl_id)
    order  by elp.eligy_prfl_id;
  --
  cursor c_elpecq_inst is
    select ecq.eligy_prfl_id,
           ecq.elig_cbr_quald_bnf_id pk_id,
           'ECQ' short_code,
           ecq.quald_bnf_flag,
           ecq.pgm_id, -- lamc added 2 fields
           ecq.ptip_id,
           ecq.criteria_score,
           ecq.criteria_weight
    from   ben_elig_cbr_quald_bnf_f ecq
    where  p_effective_date
           between ecq.effective_start_date
           and     ecq.effective_end_date
    order  by ecq.eligy_prfl_id;
  --
  l_not_hash_found boolean;
  --
begin
  --
  for objlook in c_elpecq_look loop
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objlook.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecq_lookup.exists(l_id) then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecq_lookup.exists(l_id) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    g_cache_elpecq_lookup(l_id).id := objlook.eligy_prfl_id;
    g_cache_elpecq_lookup(l_id).fk_id := objlook.business_group_id;
    --
  end loop;
  --
  l_torrwnum := 0;
  l_prev_id := -1;
  --
  for objinst in c_elpecq_inst loop
    --
    -- Populate the cache lookup details
    --
    l_id := ben_hash_utility.get_hashed_index(p_id => objinst.eligy_prfl_id);
    --
    -- Check if hashed value is already allocated
    --
    if g_cache_elpecq_lookup(l_id).id = objinst.eligy_prfl_id then
      --
      null;
      --
    else
      --
      loop
        --
        l_id := ben_hash_utility.get_next_hash_index(p_hash_index => l_id);
        --
        if g_cache_elpecq_lookup(l_id).id = objinst.eligy_prfl_id then
          --
          exit;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
    -- Check for first row
    --
    if l_prev_id = -1 then
      --
      g_cache_elpecq_lookup(l_id).starttorele_num := l_torrwnum;
      --
    elsif l_id <> l_prev_id then
      --
      g_cache_elpecq_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
      g_cache_elpecq_lookup(l_id).starttorele_num := l_torrwnum;
      --
    end if;
    --
    -- Populate the cache instance details
    --
    g_cache_elpecq_inst(l_torrwnum).eligy_prfl_id := objinst.eligy_prfl_id;
    g_cache_elpecq_inst(l_torrwnum).pk_id := objinst.pk_id;
    g_cache_elpecq_inst(l_torrwnum).short_code := objinst.short_code;
    g_cache_elpecq_inst(l_torrwnum).criteria_score := objinst.criteria_score;
    g_cache_elpecq_inst(l_torrwnum).criteria_weight := objinst.criteria_weight;
    g_cache_elpecq_inst(l_torrwnum).quald_bnf_flag := objinst.quald_bnf_flag;
    -- lamc added these 2 lines:
    g_cache_elpecq_inst(l_torrwnum).pgm_id := objinst.pgm_id;
    g_cache_elpecq_inst(l_torrwnum).ptip_id := objinst.ptip_id;
    --
    l_torrwnum := l_torrwnum+1;
    l_prev_id := l_id;
    --
  end loop;
  --
  g_cache_elpecq_lookup(l_prev_id).endtorele_num := l_torrwnum-1;
  --
end elpecq_writecache;
--
procedure elpecq_getcacdets
  (p_effective_date    in date,
   p_business_group_id in number,
   p_eligy_prfl_id     in number,
   p_refresh_cache     in boolean default FALSE,
   p_inst_set          out nocopy ben_elp_cache.g_cache_elpecq_instor,
   p_inst_count        out nocopy number) is
  --
  l_proc varchar2(72) :=  'elpecq_getcacdets';
  l_torrwnum pls_integer;
  l_insttorrw_num pls_integer;
  l_index         pls_integer;
  --
  l_not_hash_found boolean;
  --
begin
  --
  -- Flush the cache
  --
  if p_refresh_cache then
    --
    g_cache_elpecq_lookup.delete;
    g_cache_elpecq_inst.delete;
    --
  end if;
  --
  -- Populate the global cache
  --
  if g_cache_elpecq_lookup.count = 0 then
    --
    -- Build the cache
    --
    ben_elp_cache.elpecq_writecache
      (p_effective_date => p_effective_date,
       p_refresh_cache  => p_refresh_cache);
    --
  end if;
  --
  -- Get the instance details
  --
  l_torrwnum := 0;
  l_index := ben_hash_utility.get_hashed_index(p_id => p_eligy_prfl_id);
  --
  -- Check if hashed value is already allocated
  --
  if g_cache_elpecq_lookup.exists(l_index) then
    --
    -- If it does exist make sure its the right one
    --
    if g_cache_elpecq_lookup(l_index).id <> p_eligy_prfl_id then
      --
      l_not_hash_found := false;
      --
      -- Loop until un-allocated has value is derived
      --
      while not l_not_hash_found loop
        --
        l_index := ben_hash_utility.get_next_hash_index(p_hash_index => l_index);
        --
        -- Check if the hash index exists, if not we can use it
        --
        if not g_cache_elpecq_lookup.exists(l_index) then
          --
          -- Lets store the hash value in the index
          --
          l_not_hash_found := true;
          exit;
          --
        else
          --
          l_not_hash_found := false;
          --
        end if;
        --
      end loop;
      --
    end if;
    --
  end if;
  --
  for l_insttorrw_num in g_cache_elpecq_lookup(l_index).starttorele_num ..
    g_cache_elpecq_lookup(l_index).endtorele_num loop
    --
    p_inst_set(l_torrwnum) := g_cache_elpecq_inst(l_insttorrw_num);
    l_torrwnum := l_torrwnum+1;
    --
  end loop;
  --
  p_inst_count := l_torrwnum;
  --
exception
  --
  when no_data_found then
    --
    p_inst_count := 0;
    --
end elpecq_getcacdets;
-- ---------------------------------------------------------------------
-- eligibility profile - Disability
-- ---------------------------------------------------------------------
procedure elpeds_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'.elpeds_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_dsbld_prte_id pk_id,
           'EDB' short_code,
           tab.dsbld_cd,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_dsbld_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).pk_id         := instrow.pk_id;
    l_inst_set(l_elenum).short_code    := instrow.short_code;
    l_inst_set(l_elenum).criteria_score := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight := instrow.criteria_weight;
    l_inst_set(l_elenum).v230_val      := instrow.dsbld_cd;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpeds_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Tobacco use
-- ---------------------------------------------------------------------
procedure elpetu_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'.elpetu_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_tbco_use_prte_id pk_id,
           'ETU' short_code,
           tab.uses_tbco_flag,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_tbco_use_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).v230_val      := instrow.uses_tbco_flag;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
     --start 4446984
    l_inst_set(l_elenum).short_code        := instrow.short_code;
    l_inst_set(l_elenum).pk_id             := instrow.pk_id;
    l_inst_set(l_elenum).criteria_score    := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight   := instrow.criteria_weight;
    --end 4446984
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpetu_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Total coverage volume
-- ---------------------------------------------------------------------
--
procedure elpetc_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
   --
  ,p_inst_set       in out nocopy g_elp_cache  ) is
  --
  l_proc varchar2(80) := g_package || '.elpetc_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
      (c_eligy_prfl_id  number
      ,c_effective_date date  ) is
       select etc.eligy_prfl_id
       	    , etc.mn_cvg_vol_amt
       	    , etc.mx_cvg_vol_amt
       	    , etc.no_mn_cvg_vol_amt_apls_flag
       	    , etc.no_mx_cvg_vol_amt_apls_flag
       from ben_elig_ttl_cvg_vol_prte_f etc
       where etc.eligy_prfl_id = c_eligy_prfl_id
	 and c_effective_date
	     between etc.effective_start_date and etc.effective_end_date
       order by etc.eligy_prfl_id;
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).num_val       := instrow.mn_cvg_vol_amt;
    l_inst_set(l_elenum).num_val1      := instrow.mx_cvg_vol_amt;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null ;
    --
end;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Total participants
-- ---------------------------------------------------------------------
--
procedure elpetp_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
   --
  ,p_inst_set       in out nocopy g_elp_cache  ) is
  --
  l_proc varchar2(80) := g_package || '.elpetp_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
      (c_eligy_prfl_id  number
      ,c_effective_date date  ) is
       select etp.eligy_prfl_id
            , etp.mn_prtt_num
            , etp.mx_prtt_num
            , etp.no_mn_prtt_num_apls_flag
            , etp.no_mx_prtt_num_apls_flag
       from ben_elig_ttl_prtt_prte_f etp
       where etp.eligy_prfl_id = c_eligy_prfl_id
	 and c_effective_date
	     between etp.effective_start_date and etp.effective_end_date
       order by etp.eligy_prfl_id;
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).num_val       := instrow.mn_prtt_num;
    l_inst_set(l_elenum).num_val1      := instrow.mx_prtt_num;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null ;
    --
end;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Participation in another plan
-- ---------------------------------------------------------------------
--
procedure elpeop_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'.elpeop_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.pl_id,
           tab.excld_flag
    from   ben_elig_anthr_pl_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).num_val       := instrow.pl_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpeop_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Health Coverage Selected
-- ---------------------------------------------------------------------
--
procedure elpehc_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'.elpehc_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.pl_typ_opt_typ_id,
           tab.oipl_id,
           tab.excld_flag
    from   ben_elig_hlth_cvg_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).num_val       := instrow.pl_typ_opt_typ_id;
    l_inst_set(l_elenum).num_val1      := instrow.oipl_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpehc_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Competency
-- ---------------------------------------------------------------------
--
procedure elpecy_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  )
is
  --
  l_proc varchar2(72) := g_package||'.elpecy_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_comptncy_prte_id pk_id,
           'ECY' short_code,
           tab.competence_id,
           tab.rating_level_id,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_comptncy_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).num_val       := instrow.competence_id;
    l_inst_set(l_elenum).num_val1      := instrow.rating_level_id;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    --start 4446984
    l_inst_set(l_elenum).short_code    := instrow.short_code;
    l_inst_set(l_elenum).pk_id    := instrow.pk_id;
    l_inst_set(l_elenum).criteria_score    := instrow.criteria_score;
    l_inst_set(l_elenum).criteria_weight    := instrow.criteria_weight;
    --end 4446984
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpecy_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Quartile in Grade
-- ---------------------------------------------------------------------
--
procedure elpeqg_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
   --
  ,p_inst_set       in out nocopy g_elp_cache
  ) is
  --
  l_proc varchar2(72) := g_package||'.elpeqg_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_qua_in_gr_prte_id pk_id,
           'EQG' short_code,
           tab.quar_in_grade_cd,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_qua_in_gr_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).v230_val       := instrow.quar_in_grade_cd;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpeqg_getdets;
--
-- ---------------------------------------------------------------------
-- eligibility profile - Performance Rating
-- ---------------------------------------------------------------------
--
procedure elpepr_getdets
  (p_effective_date in     date
  ,p_eligy_prfl_id  in     number
  --
  ,p_inst_set       in out nocopy g_elp_cache
  ) is

  --
  l_proc varchar2(72) := g_package||'.elpepr_getdets';
  --
  l_inst_set     g_elp_cache := g_elp_cache();
  --
  l_elenum       pls_integer;
  --
  cursor c_instance
    (c_eligy_prfl_id  number
    ,c_effective_date date
    )
  is
    select tab.eligy_prfl_id,
           tab.elig_perf_rtng_prte_id pk_id,
           'ERG' short_code,
           tab.perf_rtng_cd,
           tab.event_type,
           tab.excld_flag,
           tab.criteria_score,
           tab.criteria_weight
    from   ben_elig_perf_rtng_prte_f tab
    where tab.eligy_prfl_id = c_eligy_prfl_id
      and c_effective_date
        between tab.effective_start_date and tab.effective_end_date
    order by tab.eligy_prfl_id,
             decode(tab.excld_flag,'Y',1,2);
  --
begin
  --
  l_elenum := 1;
  --
  for instrow in c_instance
    (c_eligy_prfl_id  => p_eligy_prfl_id
    ,c_effective_date => p_effective_date
    )
  loop
    --
    l_inst_set.extend(1);
    l_inst_set(l_elenum).eligy_prfl_id := instrow.eligy_prfl_id;
    l_inst_set(l_elenum).v230_val      := instrow.perf_rtng_cd;
    l_inst_set(l_elenum).v230_val1     := instrow.event_type;
    l_inst_set(l_elenum).excld_flag    := instrow.excld_flag;
    l_elenum := l_elenum+1;
    --
  end loop;
  --
  p_inst_set := l_inst_set;
  --
exception
  --
  when no_data_found then
    --
    null;
    --
end elpepr_getdets;
--
procedure clear_down_cache
is
  --
  --
begin
  --
  -- On demand cache structures
  --
  g_copcep_odlookup.delete;
  g_copcep_odinst.delete;
  g_copcep_odcached := 0;
  g_copcep_nxelenum := null;
  --
  -- Clear down all cache structures
  --
  g_cobcep_lookup.delete;
  g_cobcep_inst.delete;
  g_cobcep_cached := FALSE;
  --
  g_elpept_lookup.delete;
  g_elpept_inst.delete;
  g_elpees_lookup.delete;
  g_elpees_inst.delete;
  g_elpesa_lookup.delete;
  g_elpesa_inst.delete;
  g_elpehs_lookup.delete;
  g_elpehs_inst.delete;
  g_elpels_lookup.delete;
  g_elpels_inst.delete;
  g_elpecp_lookup.delete;
  g_elpecp_inst.delete;
  --
  -- Old
  --
  g_cache_elpept_lookup.delete;
  g_cache_elpept_inst.delete;
  g_cache_elpepg_lookup.delete;
  g_cache_elpepg_inst.delete;
  g_cache_elpees_lookup.delete;
  g_cache_elpees_inst.delete;
  g_cache_elpels_lookup.delete;
  g_cache_elpels_inst.delete;
  g_cache_elpecp_lookup.delete;
  g_cache_elpecp_inst.delete;
  g_cache_elpewl_lookup.delete;
  g_cache_elpewl_inst.delete;
  g_cache_elpeou_lookup.delete;
  g_cache_elpeou_inst.delete;
  g_cache_elpehs_lookup.delete;
  g_cache_elpehs_inst.delete;
  g_cache_elpefp_lookup.delete;
  g_cache_elpefp_inst.delete;
  g_cache_elpesh_lookup.delete;
  g_cache_elpesh_inst.delete;
  g_cache_elpecl_lookup.delete;
  g_cache_elpecl_inst.delete;
  g_cache_elpehw_lookup.delete;
  g_cache_elpehw_inst.delete;
  g_cache_elpepf_lookup.delete;
  g_cache_elpepf_inst.delete;
  g_cache_elpegr_lookup.delete;
  g_cache_elpegr_inst.delete;
  g_cache_elpejp_lookup.delete;
  g_cache_elpejp_inst.delete;
  g_cache_elpepb_lookup.delete;
  g_cache_elpepb_inst.delete;
  g_cache_elpepy_lookup.delete;
  g_cache_elpepy_inst.delete;
  g_cache_elpebu_lookup.delete;
  g_cache_elpebu_inst.delete;
  g_cache_elpelu_lookup.delete;
  g_cache_elpelu_inst.delete;
  g_cache_elpelr_lookup.delete;
  g_cache_elpelr_inst.delete;
  g_cache_elpeap_lookup.delete;
  g_cache_elpeap_inst.delete;
  g_cache_elpepz_lookup.delete;
  g_cache_elpepz_inst.delete;
  g_cache_elpebn_lookup.delete;
  g_cache_elpebn_inst.delete;
  g_cache_elpeln_lookup.delete;
  g_cache_elpeln_inst.delete;
  g_cache_elpepp_lookup.delete;
  g_cache_elpepp_inst.delete;
  g_cache_elpesa_lookup.delete;
  g_cache_elpesa_inst.delete;
  g_cache_elpeoy_lookup.delete;
  g_cache_elpeoy_inst.delete;
  g_cache_elpetd_lookup.delete;
  g_cache_elpetd_inst.delete;
  g_cache_elpeno_lookup.delete;
  g_cache_elpeno_inst.delete;
  g_cache_elpeep_lookup.delete;
  g_cache_elpeep_inst.delete;
  g_cache_elpeei_lookup.delete;
  g_cache_elpeei_inst.delete;
  g_cache_elpeeg_lookup.delete;
  g_cache_elpeeg_inst.delete;
  g_cache_elpedp_lookup.delete;
  g_cache_elpedp_inst.delete;
  g_cache_elpelv_lookup.delete;
  g_cache_elpelv_inst.delete;
  g_cache_elpeom_lookup.delete;
  g_cache_elpeom_inst.delete;
  g_cache_elpeai_lookup.delete;
  g_cache_elpeai_inst.delete;
  g_cache_elpedi_lookup.delete;
  g_cache_elpedi_inst.delete;
  g_cache_elpeet_lookup.delete;
  g_cache_elpeet_inst.delete;
  g_cache_elpedt_lookup.delete;
  g_cache_elpedt_inst.delete;
  g_cache_elpedg_lookup.delete;
  g_cache_elpedg_inst.delete;
  g_cache_elpecq_lookup.delete;
  g_cache_elpecq_inst.delete;
  --
  -- Grab back memory
  --
  begin
    --
    dbms_session.free_unused_user_memory;
    --
  end;
  --
end clear_down_cache;
--
end ben_elp_cache;
--

/
