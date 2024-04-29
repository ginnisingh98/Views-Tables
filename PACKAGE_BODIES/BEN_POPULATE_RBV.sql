--------------------------------------------------------
--  DDL for Package Body BEN_POPULATE_RBV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POPULATE_RBV" as
/* $Header: benrbvpo.pkb 120.0 2005/05/28 09:25:06 appldev noship $ */
--
g_package varchar2(50) := 'ben_populate_rbv.';
--
Type t_ppl_tab   is table of ben_ptnl_ler_for_per%rowtype     index by binary_integer;
Type t_pil_tab   is table of ben_per_in_ler%rowtype     index by binary_integer;
Type t_crp_tab   is table of ben_cbr_per_in_ler%rowtype     index by binary_integer;
Type t_cqb_tab   is table of ben_cbr_quald_bnf%rowtype     index by binary_integer;
Type t_pep_tab   is table of ben_elig_per_f%rowtype     index by binary_integer;
Type t_epo_tab   is table of ben_elig_per_opt_f%rowtype index by binary_integer;
Type t_epe_tab   is table of ben_elig_per_elctbl_chc%rowtype index by binary_integer;
Type t_pel_tab   is table of ben_pil_elctbl_chc_popl%rowtype index by binary_integer;
Type t_ecc_tab   is table of ben_elctbl_chc_ctfn%rowtype index by binary_integer;
Type t_egd_tab   is table of ben_elig_dpnt%rowtype index by binary_integer;
Type t_pdp_tab   is table of ben_elig_cvrd_dpnt_f%rowtype index by binary_integer;
Type t_enb_tab   is table of ben_enrt_bnft%rowtype index by binary_integer;
Type t_epr_tab   is table of ben_enrt_prem%rowtype index by binary_integer;
Type t_ecr_tab   is table of ben_enrt_rt%rowtype index by binary_integer;
Type t_prv_tab   is table of ben_prtt_rt_val%rowtype index by binary_integer;
Type t_pen_tab   is table of ben_prtt_enrt_rslt_f%rowtype index by binary_integer;
Type t_pcm_tab   is table of ben_per_cm_f%rowtype index by binary_integer;
Type t_bpl_tab   is table of ben_bnft_prvdd_ldgr_f%rowtype index by binary_integer;
Type t_cwbmh_tab is table of ben_cwb_mgr_hrchy%rowtype index by binary_integer;
--
PROCEDURE write_ppl_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_ppl_set           in     t_ppl_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_ppl_set.count > 0 then
    --
    for elenum in p_ppl_set.first..p_ppl_set.last
    loop
      --
      insert into ben_ptnl_ler_for_per_rbv
        (ptnl_ler_for_per_id
        ,business_group_id
        ,lf_evt_ocrd_dt
        ,ler_id
        ,ptnl_ler_for_per_stat_cd
        ,ptnl_ler_for_per_src_cd
        ,ntfn_dt
        ,person_id
        ,dtctd_dt
        ,procd_dt
        ,unprocd_dt
        ,voidd_dt
        ,mnl_dt
        ,enrt_perd_id
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,request_id
        ,program_application_id
        ,program_id
        ,program_update_date
        ,object_version_number
        ,mnlo_dt
        ,csd_by_ptnl_ler_for_per_id
        ,benefit_action_id
        ,person_action_id
        )
      values
        (p_ppl_set(elenum).ptnl_ler_for_per_id
        ,p_ppl_set(elenum).business_group_id
        ,p_ppl_set(elenum).lf_evt_ocrd_dt
        ,p_ppl_set(elenum).ler_id
        ,p_ppl_set(elenum).ptnl_ler_for_per_stat_cd
        ,p_ppl_set(elenum).ptnl_ler_for_per_src_cd
        ,p_ppl_set(elenum).ntfn_dt
        ,p_ppl_set(elenum).person_id
        ,p_ppl_set(elenum).dtctd_dt
        ,p_ppl_set(elenum).procd_dt
        ,p_ppl_set(elenum).unprocd_dt
        ,p_ppl_set(elenum).voidd_dt
        ,p_ppl_set(elenum).mnl_dt
        ,p_ppl_set(elenum).enrt_perd_id
        ,p_ppl_set(elenum).last_update_date
        ,p_ppl_set(elenum).last_updated_by
        ,p_ppl_set(elenum).last_update_login
        ,p_ppl_set(elenum).created_by
        ,p_ppl_set(elenum).creation_date
        ,p_ppl_set(elenum).request_id
        ,p_ppl_set(elenum).program_application_id
        ,p_ppl_set(elenum).program_id
        ,p_ppl_set(elenum).program_update_date
        ,p_ppl_set(elenum).object_version_number
        ,p_ppl_set(elenum).mnlo_dt
        ,p_ppl_set(elenum).csd_by_ptnl_ler_for_per_id
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_ppl_rbvs;
--
PROCEDURE write_pil_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pil_set           in     t_pil_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pil_set.count > 0 then
    --
    for elenum in p_pil_set.first ..p_pil_set.last
    loop
      --
      insert into ben_per_in_ler_rbv
        (per_in_ler_id
        ,per_in_ler_stat_cd
        ,prvs_stat_cd
        ,lf_evt_ocrd_dt
        ,procd_dt
        ,strtd_dt
        ,voidd_dt
        ,bckt_dt
        ,clsd_dt
        ,ntfn_dt
        ,ptnl_ler_for_per_id
        ,bckt_per_in_ler_id
        ,ler_id
        ,person_id
        ,business_group_id
        ,pil_attribute_category
        ,pil_attribute1
        ,pil_attribute2
        ,pil_attribute3
        ,pil_attribute4
        ,pil_attribute5
        ,pil_attribute6
        ,pil_attribute7
        ,pil_attribute8
        ,pil_attribute9
        ,pil_attribute10
        ,pil_attribute11
        ,pil_attribute12
        ,pil_attribute13
        ,pil_attribute14
        ,pil_attribute15
        ,pil_attribute16
        ,pil_attribute17
        ,pil_attribute18
        ,pil_attribute19
        ,pil_attribute20
        ,pil_attribute21
        ,pil_attribute22
        ,pil_attribute23
        ,pil_attribute24
        ,pil_attribute25
        ,pil_attribute26
        ,pil_attribute27
        ,pil_attribute28
        ,pil_attribute29
        ,pil_attribute30
        ,request_id
        ,program_application_id
        ,program_id
        ,program_update_date
        ,object_version_number
        ,benefit_action_id
        ,person_action_id
        )
      values
        (p_pil_set(elenum).per_in_ler_id
        ,p_pil_set(elenum).per_in_ler_stat_cd
        ,p_pil_set(elenum).prvs_stat_cd
        ,p_pil_set(elenum).lf_evt_ocrd_dt
        ,p_pil_set(elenum).procd_dt
        ,p_pil_set(elenum).strtd_dt
        ,p_pil_set(elenum).voidd_dt
        ,p_pil_set(elenum).bckt_dt
        ,p_pil_set(elenum).clsd_dt
        ,p_pil_set(elenum).ntfn_dt
        ,p_pil_set(elenum).ptnl_ler_for_per_id
        ,p_pil_set(elenum).bckt_per_in_ler_id
        ,p_pil_set(elenum).ler_id
        ,p_pil_set(elenum).person_id
        ,p_pil_set(elenum).business_group_id
        ,p_pil_set(elenum).pil_attribute_category
        ,p_pil_set(elenum).pil_attribute1
        ,p_pil_set(elenum).pil_attribute2
        ,p_pil_set(elenum).pil_attribute3
        ,p_pil_set(elenum).pil_attribute4
        ,p_pil_set(elenum).pil_attribute5
        ,p_pil_set(elenum).pil_attribute6
        ,p_pil_set(elenum).pil_attribute7
        ,p_pil_set(elenum).pil_attribute8
        ,p_pil_set(elenum).pil_attribute9
        ,p_pil_set(elenum).pil_attribute10
        ,p_pil_set(elenum).pil_attribute11
        ,p_pil_set(elenum).pil_attribute12
        ,p_pil_set(elenum).pil_attribute13
        ,p_pil_set(elenum).pil_attribute14
        ,p_pil_set(elenum).pil_attribute15
        ,p_pil_set(elenum).pil_attribute16
        ,p_pil_set(elenum).pil_attribute17
        ,p_pil_set(elenum).pil_attribute18
        ,p_pil_set(elenum).pil_attribute19
        ,p_pil_set(elenum).pil_attribute20
        ,p_pil_set(elenum).pil_attribute21
        ,p_pil_set(elenum).pil_attribute22
        ,p_pil_set(elenum).pil_attribute23
        ,p_pil_set(elenum).pil_attribute24
        ,p_pil_set(elenum).pil_attribute25
        ,p_pil_set(elenum).pil_attribute26
        ,p_pil_set(elenum).pil_attribute27
        ,p_pil_set(elenum).pil_attribute28
        ,p_pil_set(elenum).pil_attribute29
        ,p_pil_set(elenum).pil_attribute30
        ,p_pil_set(elenum).request_id
        ,p_pil_set(elenum).program_application_id
        ,p_pil_set(elenum).program_id
        ,p_pil_set(elenum).program_update_date
        ,p_pil_set(elenum).object_version_number
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pil_rbvs;
--
PROCEDURE write_crp_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_crp_set           in     t_crp_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_crp_set.count > 0 then
    --
    for elenum in p_crp_set.first ..p_crp_set.last
    loop
      --
      insert into ben_cbr_per_in_ler_rbv
        (cbr_per_in_ler_id
        ,init_evt_flag
        ,per_in_ler_id
        ,cbr_quald_bnf_id
        ,business_group_id
        ,crp_attribute_category
        ,crp_attribute1
        ,crp_attribute2
        ,crp_attribute3
        ,crp_attribute4
        ,crp_attribute5
        ,crp_attribute6
        ,crp_attribute7
        ,crp_attribute8
        ,crp_attribute9
        ,crp_attribute10
        ,crp_attribute11
        ,crp_attribute12
        ,crp_attribute13
        ,crp_attribute14
        ,crp_attribute15
        ,crp_attribute16
        ,crp_attribute17
        ,crp_attribute18
        ,crp_attribute19
        ,crp_attribute20
        ,crp_attribute21
        ,crp_attribute22
        ,crp_attribute23
        ,crp_attribute24
        ,crp_attribute25
        ,crp_attribute26
        ,crp_attribute27
        ,crp_attribute28
        ,crp_attribute29
        ,crp_attribute30
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,object_version_number
        ,cnt_num
        ,prvs_elig_perd_end_dt
        ,benefit_action_id
        ,person_action_id
        )
      values
        (p_crp_set(elenum).cbr_per_in_ler_id
        ,p_crp_set(elenum).init_evt_flag
        ,p_crp_set(elenum).per_in_ler_id
        ,p_crp_set(elenum).cbr_quald_bnf_id
        ,p_crp_set(elenum).business_group_id
        ,p_crp_set(elenum).crp_attribute_category
        ,p_crp_set(elenum).crp_attribute1
        ,p_crp_set(elenum).crp_attribute2
        ,p_crp_set(elenum).crp_attribute3
        ,p_crp_set(elenum).crp_attribute4
        ,p_crp_set(elenum).crp_attribute5
        ,p_crp_set(elenum).crp_attribute6
        ,p_crp_set(elenum).crp_attribute7
        ,p_crp_set(elenum).crp_attribute8
        ,p_crp_set(elenum).crp_attribute9
        ,p_crp_set(elenum).crp_attribute10
        ,p_crp_set(elenum).crp_attribute11
        ,p_crp_set(elenum).crp_attribute12
        ,p_crp_set(elenum).crp_attribute13
        ,p_crp_set(elenum).crp_attribute14
        ,p_crp_set(elenum).crp_attribute15
        ,p_crp_set(elenum).crp_attribute16
        ,p_crp_set(elenum).crp_attribute17
        ,p_crp_set(elenum).crp_attribute18
        ,p_crp_set(elenum).crp_attribute19
        ,p_crp_set(elenum).crp_attribute20
        ,p_crp_set(elenum).crp_attribute21
        ,p_crp_set(elenum).crp_attribute22
        ,p_crp_set(elenum).crp_attribute23
        ,p_crp_set(elenum).crp_attribute24
        ,p_crp_set(elenum).crp_attribute25
        ,p_crp_set(elenum).crp_attribute26
        ,p_crp_set(elenum).crp_attribute27
        ,p_crp_set(elenum).crp_attribute28
        ,p_crp_set(elenum).crp_attribute29
        ,p_crp_set(elenum).crp_attribute30
        ,p_crp_set(elenum).last_update_date
        ,p_crp_set(elenum).last_updated_by
        ,p_crp_set(elenum).last_update_login
        ,p_crp_set(elenum).created_by
        ,p_crp_set(elenum).creation_date
        ,p_crp_set(elenum).object_version_number
        ,p_crp_set(elenum).cnt_num
        ,p_crp_set(elenum).prvs_elig_perd_end_dt
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_crp_rbvs;
--
PROCEDURE write_pep_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pep_set           in     t_pep_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pep_set.count > 0 then
    --
    for elenum in p_pep_set.first ..p_pep_set.last
    loop
      --
      insert into ben_elig_per_f_rbv
        (
        elig_per_id,
        effective_start_date,
        effective_end_date,
        business_group_id,
        pl_id,
        pgm_id,
        plip_id,
        ptip_id,
        ler_id,
        person_id,
        per_in_ler_id,
        dpnt_othr_pl_cvrd_rl_flag,
        prtn_ovridn_thru_dt,
        pl_key_ee_flag,
        pl_hghly_compd_flag,
        elig_flag,
        comp_ref_amt,
        cmbn_age_n_los_val,
        comp_ref_uom,
        age_val,
        los_val,
        prtn_end_dt,
        prtn_strt_dt,
        wait_perd_cmpltn_dt,
        wait_perd_strt_dt ,
        wv_ctfn_typ_cd,
        hrs_wkd_val,
        hrs_wkd_bndry_perd_cd,
        prtn_ovridn_flag,
        no_mx_prtn_ovrid_thru_flag,
        prtn_ovridn_rsn_cd,
        age_uom,
        los_uom,
        ovrid_svc_dt,
        inelg_rsn_cd,
        frz_los_flag,
        frz_age_flag,
        frz_cmp_lvl_flag,
        frz_pct_fl_tm_flag,
        frz_hrs_wkd_flag,
        frz_comb_age_and_los_flag,
        dstr_rstcn_flag,
        pct_fl_tm_val,
        wv_prtn_rsn_cd,
        pl_wvd_flag,
        rt_comp_ref_amt,
        rt_cmbn_age_n_los_val,
        rt_comp_ref_uom,
        rt_age_val,
        rt_los_val,
        rt_hrs_wkd_val,
        rt_hrs_wkd_bndry_perd_cd,
        rt_age_uom,
        rt_los_uom,
        rt_pct_fl_tm_val,
        rt_frz_los_flag,
        rt_frz_age_flag,
        rt_frz_cmp_lvl_flag,
        rt_frz_pct_fl_tm_flag,
        rt_frz_hrs_wkd_flag,
        rt_frz_comb_age_and_los_flag,
        once_r_cntug_cd,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        pep_attribute_category,
        pep_attribute1,
        pep_attribute2,
        pep_attribute3,
        pep_attribute4,
        pep_attribute5,
        pep_attribute6,
        pep_attribute7,
        pep_attribute8,
        pep_attribute9,
        pep_attribute10,
        pep_attribute11,
        pep_attribute12,
        pep_attribute13,
        pep_attribute14,
        pep_attribute15,
        pep_attribute16,
        pep_attribute17,
        pep_attribute18,
        pep_attribute19,
        pep_attribute20,
        pep_attribute21,
        pep_attribute22,
        pep_attribute23,
        pep_attribute24,
        pep_attribute25,
        pep_attribute26,
        pep_attribute27,
        pep_attribute28,
        pep_attribute29,
        pep_attribute30,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        object_version_number,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        benefit_action_id,
        person_action_id
      )
      Values
      (
        p_pep_set(elenum).elig_per_id,
        p_pep_set(elenum).effective_start_date,
        p_pep_set(elenum).effective_end_date,
        p_pep_set(elenum).business_group_id,
        p_pep_set(elenum).pl_id,
        p_pep_set(elenum).pgm_id,
        p_pep_set(elenum).plip_id,
        p_pep_set(elenum).ptip_id,
        p_pep_set(elenum).ler_id,
        p_pep_set(elenum).person_id,
        p_pep_set(elenum).per_in_ler_id,
        p_pep_set(elenum).dpnt_othr_pl_cvrd_rl_flag,
        p_pep_set(elenum).prtn_ovridn_thru_dt,
        p_pep_set(elenum).pl_key_ee_flag,
        p_pep_set(elenum).pl_hghly_compd_flag,
        p_pep_set(elenum).elig_flag,
        p_pep_set(elenum).comp_ref_amt,
        p_pep_set(elenum).cmbn_age_n_los_val,
        p_pep_set(elenum).comp_ref_uom,
        p_pep_set(elenum).age_val,
        p_pep_set(elenum).los_val,
        p_pep_set(elenum).prtn_end_dt,
        p_pep_set(elenum).prtn_strt_dt,
        p_pep_set(elenum).wait_perd_cmpltn_dt,
        p_pep_set(elenum).wait_perd_strt_dt ,
        p_pep_set(elenum).wv_ctfn_typ_cd,
        p_pep_set(elenum).hrs_wkd_val,
        p_pep_set(elenum).hrs_wkd_bndry_perd_cd,
        p_pep_set(elenum).prtn_ovridn_flag,
        p_pep_set(elenum).no_mx_prtn_ovrid_thru_flag,
        p_pep_set(elenum).prtn_ovridn_rsn_cd,
        p_pep_set(elenum).age_uom,
        p_pep_set(elenum).los_uom,
        p_pep_set(elenum).ovrid_svc_dt,
        p_pep_set(elenum).inelg_rsn_cd,
        p_pep_set(elenum).frz_los_flag,
        p_pep_set(elenum).frz_age_flag,
        p_pep_set(elenum).frz_cmp_lvl_flag,
        p_pep_set(elenum).frz_pct_fl_tm_flag,
        p_pep_set(elenum).frz_hrs_wkd_flag,
        p_pep_set(elenum).frz_comb_age_and_los_flag,
        p_pep_set(elenum).dstr_rstcn_flag,
        p_pep_set(elenum).pct_fl_tm_val,
        p_pep_set(elenum).wv_prtn_rsn_cd,
        p_pep_set(elenum).pl_wvd_flag,
        p_pep_set(elenum).rt_comp_ref_amt,
        p_pep_set(elenum).rt_cmbn_age_n_los_val,
        p_pep_set(elenum).rt_comp_ref_uom,
        p_pep_set(elenum).rt_age_val,
        p_pep_set(elenum).rt_los_val,
        p_pep_set(elenum).rt_hrs_wkd_val,
        p_pep_set(elenum).rt_hrs_wkd_bndry_perd_cd,
        p_pep_set(elenum).rt_age_uom,
        p_pep_set(elenum).rt_los_uom,
        p_pep_set(elenum).rt_pct_fl_tm_val,
        p_pep_set(elenum).rt_frz_los_flag,
        p_pep_set(elenum).rt_frz_age_flag,
        p_pep_set(elenum).rt_frz_cmp_lvl_flag,
        p_pep_set(elenum).rt_frz_pct_fl_tm_flag,
        p_pep_set(elenum).rt_frz_hrs_wkd_flag,
        p_pep_set(elenum).rt_frz_comb_age_and_los_flag,
        p_pep_set(elenum).once_r_cntug_cd,
        p_pep_set(elenum).pl_ordr_num,
        p_pep_set(elenum).plip_ordr_num,
        p_pep_set(elenum).ptip_ordr_num,
        p_pep_set(elenum).pep_attribute_category,
        p_pep_set(elenum).pep_attribute1,
        p_pep_set(elenum).pep_attribute2,
        p_pep_set(elenum).pep_attribute3,
        p_pep_set(elenum).pep_attribute4,
        p_pep_set(elenum).pep_attribute5,
        p_pep_set(elenum).pep_attribute6,
        p_pep_set(elenum).pep_attribute7,
        p_pep_set(elenum).pep_attribute8,
        p_pep_set(elenum).pep_attribute9,
        p_pep_set(elenum).pep_attribute10,
        p_pep_set(elenum).pep_attribute11,
        p_pep_set(elenum).pep_attribute12,
        p_pep_set(elenum).pep_attribute13,
        p_pep_set(elenum).pep_attribute14,
        p_pep_set(elenum).pep_attribute15,
        p_pep_set(elenum).pep_attribute16,
        p_pep_set(elenum).pep_attribute17,
        p_pep_set(elenum).pep_attribute18,
        p_pep_set(elenum).pep_attribute19,
        p_pep_set(elenum).pep_attribute20,
        p_pep_set(elenum).pep_attribute21,
        p_pep_set(elenum).pep_attribute22,
        p_pep_set(elenum).pep_attribute23,
        p_pep_set(elenum).pep_attribute24,
        p_pep_set(elenum).pep_attribute25,
        p_pep_set(elenum).pep_attribute26,
        p_pep_set(elenum).pep_attribute27,
        p_pep_set(elenum).pep_attribute28,
        p_pep_set(elenum).pep_attribute29,
        p_pep_set(elenum).pep_attribute30,
        p_pep_set(elenum).request_id,
        p_pep_set(elenum).program_application_id,
        p_pep_set(elenum).program_id,
        p_pep_set(elenum).program_update_date,
        p_pep_set(elenum).object_version_number,
        p_pep_set(elenum).created_by,
        p_pep_set(elenum).creation_date,
        p_pep_set(elenum).last_update_date,
        p_pep_set(elenum).last_updated_by,
        p_pep_set(elenum).last_update_login,
        p_benefit_action_id,
        p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pep_rbvs;
--
PROCEDURE write_epo_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_epo_set           in     t_epo_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_epo_set.count > 0 then
    --
    for elenum in p_epo_set.first ..p_epo_set.last
    loop
      --
      insert into ben_elig_per_opt_f_rbv
      ( elig_per_opt_id,
        elig_per_id,
        effective_start_date,
        effective_end_date,
        prtn_ovridn_flag,
        prtn_ovridn_thru_dt,
        no_mx_prtn_ovrid_thru_flag,
        elig_flag,
        prtn_strt_dt,
        prtn_end_dt,
        wait_perd_cmpltn_dt,
        wait_perd_strt_dt,
        prtn_ovridn_rsn_cd,
        pct_fl_tm_val,
        opt_id,
        per_in_ler_id,
        rt_comp_ref_amt,
        rt_cmbn_age_n_los_val,
        rt_comp_ref_uom,
        rt_age_val,
        rt_los_val,
        rt_hrs_wkd_val,
        rt_hrs_wkd_bndry_perd_cd,
        rt_age_uom,
        rt_los_uom,
        rt_pct_fl_tm_val,
        rt_frz_los_flag,
        rt_frz_age_flag,
        rt_frz_cmp_lvl_flag,
        rt_frz_pct_fl_tm_flag,
        rt_frz_hrs_wkd_flag,
        rt_frz_comb_age_and_los_flag,
        comp_ref_amt,
        cmbn_age_n_los_val,
        comp_ref_uom,
        age_val,
        los_val,
        hrs_wkd_val,
        hrs_wkd_bndry_perd_cd,
        age_uom,
        los_uom,
        frz_los_flag,
        frz_age_flag,
        frz_cmp_lvl_flag,
        frz_pct_fl_tm_flag,
        frz_hrs_wkd_flag,
        frz_comb_age_and_los_flag,
        ovrid_svc_dt,
        inelg_rsn_cd,
        once_r_cntug_cd,
        oipl_ordr_num,
        business_group_id,
        epo_attribute_category,
        epo_attribute1,
        epo_attribute2,
        epo_attribute3,
        epo_attribute4,
        epo_attribute5,
        epo_attribute6,
        epo_attribute7,
        epo_attribute8,
        epo_attribute9,
        epo_attribute10,
        epo_attribute11,
        epo_attribute12,
        epo_attribute13,
        epo_attribute14,
        epo_attribute15,
        epo_attribute16,
        epo_attribute17,
        epo_attribute18,
        epo_attribute19,
        epo_attribute20,
        epo_attribute21,
        epo_attribute22,
        epo_attribute23,
        epo_attribute24,
        epo_attribute25,
        epo_attribute26,
        epo_attribute27,
        epo_attribute28,
        epo_attribute29,
        epo_attribute30,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        object_version_number,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        benefit_action_id,
        person_action_id
      )
      Values
      ( p_epo_set(elenum).elig_per_opt_id,
        p_epo_set(elenum).elig_per_id,
        p_epo_set(elenum).effective_start_date,
        p_epo_set(elenum).effective_end_date,
        p_epo_set(elenum).prtn_ovridn_flag,
        p_epo_set(elenum).prtn_ovridn_thru_dt,
        p_epo_set(elenum).no_mx_prtn_ovrid_thru_flag,
        p_epo_set(elenum).elig_flag,
        p_epo_set(elenum).prtn_strt_dt,
        p_epo_set(elenum).prtn_end_dt,
        p_epo_set(elenum).wait_perd_cmpltn_dt,
        p_epo_set(elenum).wait_perd_strt_dt,
        p_epo_set(elenum).prtn_ovridn_rsn_cd,
        p_epo_set(elenum).pct_fl_tm_val,
        p_epo_set(elenum).opt_id,
        p_epo_set(elenum).per_in_ler_id,
        p_epo_set(elenum).rt_comp_ref_amt,
        p_epo_set(elenum).rt_cmbn_age_n_los_val,
        p_epo_set(elenum).rt_comp_ref_uom,
        p_epo_set(elenum).rt_age_val,
        p_epo_set(elenum).rt_los_val,
        p_epo_set(elenum).rt_hrs_wkd_val,
        p_epo_set(elenum).rt_hrs_wkd_bndry_perd_cd,
        p_epo_set(elenum).rt_age_uom,
        p_epo_set(elenum).rt_los_uom,
        p_epo_set(elenum).rt_pct_fl_tm_val,
        p_epo_set(elenum).rt_frz_los_flag,
        p_epo_set(elenum).rt_frz_age_flag,
        p_epo_set(elenum).rt_frz_cmp_lvl_flag,
        p_epo_set(elenum).rt_frz_pct_fl_tm_flag,
        p_epo_set(elenum).rt_frz_hrs_wkd_flag,
        p_epo_set(elenum).rt_frz_comb_age_and_los_flag,
        p_epo_set(elenum).comp_ref_amt,
        p_epo_set(elenum).cmbn_age_n_los_val,
        p_epo_set(elenum).comp_ref_uom,
        p_epo_set(elenum).age_val,
        p_epo_set(elenum).los_val,
        p_epo_set(elenum).hrs_wkd_val,
        p_epo_set(elenum).hrs_wkd_bndry_perd_cd,
        p_epo_set(elenum).age_uom,
        p_epo_set(elenum).los_uom,
        p_epo_set(elenum).frz_los_flag,
        p_epo_set(elenum).frz_age_flag,
        p_epo_set(elenum).frz_cmp_lvl_flag,
        p_epo_set(elenum).frz_pct_fl_tm_flag,
        p_epo_set(elenum).frz_hrs_wkd_flag,
        p_epo_set(elenum).frz_comb_age_and_los_flag,
        p_epo_set(elenum).ovrid_svc_dt,
        p_epo_set(elenum).inelg_rsn_cd,
        p_epo_set(elenum).once_r_cntug_cd,
        p_epo_set(elenum).oipl_ordr_num,
        p_epo_set(elenum).business_group_id,
        p_epo_set(elenum).epo_attribute_category,
        p_epo_set(elenum).epo_attribute1,
        p_epo_set(elenum).epo_attribute2,
        p_epo_set(elenum).epo_attribute3,
        p_epo_set(elenum).epo_attribute4,
        p_epo_set(elenum).epo_attribute5,
        p_epo_set(elenum).epo_attribute6,
        p_epo_set(elenum).epo_attribute7,
        p_epo_set(elenum).epo_attribute8,
        p_epo_set(elenum).epo_attribute9,
        p_epo_set(elenum).epo_attribute10,
        p_epo_set(elenum).epo_attribute11,
        p_epo_set(elenum).epo_attribute12,
        p_epo_set(elenum).epo_attribute13,
        p_epo_set(elenum).epo_attribute14,
        p_epo_set(elenum).epo_attribute15,
        p_epo_set(elenum).epo_attribute16,
        p_epo_set(elenum).epo_attribute17,
        p_epo_set(elenum).epo_attribute18,
        p_epo_set(elenum).epo_attribute19,
        p_epo_set(elenum).epo_attribute20,
        p_epo_set(elenum).epo_attribute21,
        p_epo_set(elenum).epo_attribute22,
        p_epo_set(elenum).epo_attribute23,
        p_epo_set(elenum).epo_attribute24,
        p_epo_set(elenum).epo_attribute25,
        p_epo_set(elenum).epo_attribute26,
        p_epo_set(elenum).epo_attribute27,
        p_epo_set(elenum).epo_attribute28,
        p_epo_set(elenum).epo_attribute29,
        p_epo_set(elenum).epo_attribute30,
        p_epo_set(elenum).request_id,
        p_epo_set(elenum).program_application_id,
        p_epo_set(elenum).program_id,
        p_epo_set(elenum).program_update_date,
        p_epo_set(elenum).object_version_number,
        p_epo_set(elenum).created_by,
        p_epo_set(elenum).creation_date,
        p_epo_set(elenum).last_update_date,
        p_epo_set(elenum).last_updated_by,
        p_epo_set(elenum).last_update_login,
        p_benefit_action_id,
        p_person_action_id
      );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_epo_rbvs;
--
PROCEDURE write_epe_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_epe_set           in     t_epe_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_epe_set.count > 0 then
    --
    for elenum in p_epe_set.first ..p_epe_set.last
    loop
      --
      insert into ben_elig_per_elctbl_chc_rbv
  (	elig_per_elctbl_chc_id,
--	enrt_typ_cycl_cd,
	enrt_cvg_strt_dt_cd,
--	enrt_perd_end_dt,
--	enrt_perd_strt_dt,
	enrt_cvg_strt_dt_rl,
--	rt_strt_dt,
--	rt_strt_dt_rl,
--	rt_strt_dt_cd,
        ctfn_rqd_flag,
        pil_elctbl_chc_popl_id,
	roll_crs_flag,
	crntly_enrd_flag,
	dflt_flag,
	elctbl_flag,
	mndtry_flag,
        in_pndg_wkflow_flag,
--	dflt_enrt_dt,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	enrt_cvg_strt_dt,
	alws_dpnt_dsgn_flag,
	dpnt_dsgn_cd,
	ler_chg_dpnt_cvg_cd,
	erlst_deenrt_dt,
	procg_end_dt,
	comp_lvl_cd,
	pl_id,
	oipl_id,
	pgm_id,
	plip_id,
	ptip_id,
	pl_typ_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
        assignment_id,
	spcl_rt_pl_id,
	spcl_rt_oipl_id,
	must_enrl_anthr_pl_id,
	interim_elig_per_elctbl_chc_id,
	prtt_enrt_rslt_id,
	bnft_prvdr_pool_id,
	per_in_ler_id,
	yr_perd_id,
	auto_enrt_flag,
	business_group_id,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
        -- cwb
        comments,
        elig_flag,
        elig_ovrid_dt,
        elig_ovrid_person_id,
        inelig_rsn_cd,
        mgr_ovrid_dt,
        mgr_ovrid_person_id,
        ws_mgr_id,
        -- cwb
	epe_attribute_category,
	epe_attribute1,
	epe_attribute2,
	epe_attribute3,
	epe_attribute4,
	epe_attribute5,
	epe_attribute6,
	epe_attribute7,
	epe_attribute8,
	epe_attribute9,
	epe_attribute10,
	epe_attribute11,
	epe_attribute12,
	epe_attribute13,
	epe_attribute14,
	epe_attribute15,
	epe_attribute16,
	epe_attribute17,
	epe_attribute18,
	epe_attribute19,
	epe_attribute20,
	epe_attribute21,
	epe_attribute22,
	epe_attribute23,
	epe_attribute24,
	epe_attribute25,
	epe_attribute26,
	epe_attribute27,
	epe_attribute28,
	epe_attribute29,
	epe_attribute30,
        cryfwd_elig_dpnt_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number,
        benefit_action_id,
        person_action_id
       )
  Values
       (p_epe_set(elenum).elig_per_elctbl_chc_id,
--	p_enrt_typ_cycl_cd,
        p_epe_set(elenum).enrt_cvg_strt_dt_cd,
--	p_enrt_perd_end_dt,
--	p_enrt_perd_strt_dt,
        p_epe_set(elenum).enrt_cvg_strt_dt_rl,
--	p_rt_strt_dt,
--	p_rt_strt_dt_rl,
--	p_rt_strt_dt_cd,
        p_epe_set(elenum).ctfn_rqd_flag,
        p_epe_set(elenum).pil_elctbl_chc_popl_id,
        p_epe_set(elenum).roll_crs_flag,
        p_epe_set(elenum).crntly_enrd_flag,
        p_epe_set(elenum).dflt_flag,
        p_epe_set(elenum).elctbl_flag,
        p_epe_set(elenum).mndtry_flag,
        p_epe_set(elenum).in_pndg_wkflow_flag,
--	p_dflt_enrt_dt,
        p_epe_set(elenum).dpnt_cvg_strt_dt_cd,
        p_epe_set(elenum).dpnt_cvg_strt_dt_rl,
        p_epe_set(elenum).enrt_cvg_strt_dt,
        p_epe_set(elenum).alws_dpnt_dsgn_flag,
        p_epe_set(elenum).dpnt_dsgn_cd,
        p_epe_set(elenum).ler_chg_dpnt_cvg_cd,
        p_epe_set(elenum).erlst_deenrt_dt,
        p_epe_set(elenum).procg_end_dt,
        p_epe_set(elenum).comp_lvl_cd,
        p_epe_set(elenum).pl_id,
        p_epe_set(elenum).oipl_id,
        p_epe_set(elenum).pgm_id,
        p_epe_set(elenum).plip_id,
        p_epe_set(elenum).ptip_id,
        p_epe_set(elenum).pl_typ_id,
        p_epe_set(elenum).oiplip_id,
        p_epe_set(elenum).cmbn_plip_id,
        p_epe_set(elenum).cmbn_ptip_id,
        p_epe_set(elenum).cmbn_ptip_opt_id,
        p_epe_set(elenum).assignment_id,
        p_epe_set(elenum).spcl_rt_pl_id,
        p_epe_set(elenum).spcl_rt_oipl_id,
        p_epe_set(elenum).must_enrl_anthr_pl_id,
        p_epe_set(elenum).interim_elig_per_elctbl_chc_id,
        p_epe_set(elenum).prtt_enrt_rslt_id,
        p_epe_set(elenum).bnft_prvdr_pool_id,
        p_epe_set(elenum).per_in_ler_id,
        p_epe_set(elenum).yr_perd_id,
        p_epe_set(elenum).auto_enrt_flag,
        p_epe_set(elenum).business_group_id,
        p_epe_set(elenum).pl_ordr_num,
        p_epe_set(elenum).plip_ordr_num,
        p_epe_set(elenum).ptip_ordr_num,
        p_epe_set(elenum).oipl_ordr_num,
        -- cwb
        p_epe_set(elenum).comments,
        p_epe_set(elenum).elig_flag,
        p_epe_set(elenum).elig_ovrid_dt,
        p_epe_set(elenum).elig_ovrid_person_id,
        p_epe_set(elenum).inelig_rsn_cd,
        p_epe_set(elenum).mgr_ovrid_dt,
        p_epe_set(elenum).mgr_ovrid_person_id,
        p_epe_set(elenum).ws_mgr_id,
        -- cwb
        p_epe_set(elenum).epe_attribute_category,
        p_epe_set(elenum).epe_attribute1,
        p_epe_set(elenum).epe_attribute2,
        p_epe_set(elenum).epe_attribute3,
        p_epe_set(elenum).epe_attribute4,
        p_epe_set(elenum).epe_attribute5,
        p_epe_set(elenum).epe_attribute6,
        p_epe_set(elenum).epe_attribute7,
        p_epe_set(elenum).epe_attribute8,
        p_epe_set(elenum).epe_attribute9,
        p_epe_set(elenum).epe_attribute10,
        p_epe_set(elenum).epe_attribute11,
        p_epe_set(elenum).epe_attribute12,
        p_epe_set(elenum).epe_attribute13,
        p_epe_set(elenum).epe_attribute14,
        p_epe_set(elenum).epe_attribute15,
        p_epe_set(elenum).epe_attribute16,
        p_epe_set(elenum).epe_attribute17,
        p_epe_set(elenum).epe_attribute18,
        p_epe_set(elenum).epe_attribute19,
        p_epe_set(elenum).epe_attribute20,
        p_epe_set(elenum).epe_attribute21,
        p_epe_set(elenum).epe_attribute22,
        p_epe_set(elenum).epe_attribute23,
        p_epe_set(elenum).epe_attribute24,
        p_epe_set(elenum).epe_attribute25,
        p_epe_set(elenum).epe_attribute26,
        p_epe_set(elenum).epe_attribute27,
        p_epe_set(elenum).epe_attribute28,
        p_epe_set(elenum).epe_attribute29,
        p_epe_set(elenum).epe_attribute30,
        p_epe_set(elenum).cryfwd_elig_dpnt_cd,
        p_epe_set(elenum).request_id,
        p_epe_set(elenum).program_application_id,
        p_epe_set(elenum).program_id,
        p_epe_set(elenum).program_update_date,
        p_epe_set(elenum).object_version_number,
        p_benefit_action_id,
        p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_epe_rbvs;
--
PROCEDURE write_pel_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pel_set           in     t_pel_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pel_set.count > 0 then
    --
    for elenum in p_pel_set.first..p_pel_set.last
    loop
      --
      insert into ben_pil_epe_popl_rbv
  (	pil_elctbl_chc_popl_id,
	dflt_enrt_dt,
	dflt_asnd_dt,
	elcns_made_dt,
	cls_enrt_dt_to_use_cd,
	enrt_typ_cycl_cd,
	enrt_perd_end_dt,
	enrt_perd_strt_dt,
	procg_end_dt,
	pil_elctbl_popl_stat_cd,
	acty_ref_perd_cd,
	uom,
        --cwb
        bdgt_acc_cd,
        pop_cd,
        bdgt_due_dt,
        bdgt_export_flag,
        bdgt_iss_dt,
        bdgt_stat_cd,
        ws_acc_cd,
        ws_due_dt,
        ws_export_flag,
        ws_iss_dt,
        ws_stat_cd,
        --cwb
	auto_asnd_dt,
        cbr_elig_perd_strt_dt,
        cbr_elig_perd_end_dt,
	lee_rsn_id,
	enrt_perd_id,
	per_in_ler_id,
	pgm_id,
	pl_id,
	business_group_id,
	pel_attribute_category,
	pel_attribute1,
	pel_attribute2,
	pel_attribute3,
	pel_attribute4,
	pel_attribute5,
	pel_attribute6,
	pel_attribute7,
	pel_attribute8,
	pel_attribute9,
	pel_attribute10,
	pel_attribute11,
	pel_attribute12,
	pel_attribute13,
	pel_attribute14,
	pel_attribute15,
	pel_attribute16,
	pel_attribute17,
	pel_attribute18,
	pel_attribute19,
	pel_attribute20,
	pel_attribute21,
	pel_attribute22,
	pel_attribute23,
	pel_attribute24,
	pel_attribute25,
	pel_attribute26,
	pel_attribute27,
	pel_attribute28,
	pel_attribute29,
	pel_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number,
        benefit_action_id,
        person_action_id
  )
  Values
  (     p_pel_set(elenum).pil_elctbl_chc_popl_id,
        p_pel_set(elenum).dflt_enrt_dt,
        p_pel_set(elenum).dflt_asnd_dt,
        p_pel_set(elenum).elcns_made_dt,
        p_pel_set(elenum).cls_enrt_dt_to_use_cd,
        p_pel_set(elenum).enrt_typ_cycl_cd,
        p_pel_set(elenum).enrt_perd_end_dt,
        p_pel_set(elenum).enrt_perd_strt_dt,
        p_pel_set(elenum).procg_end_dt,
        p_pel_set(elenum).pil_elctbl_popl_stat_cd,
        p_pel_set(elenum).acty_ref_perd_cd,
        p_pel_set(elenum).uom,
        --cwb
        p_pel_set(elenum).bdgt_acc_cd,
        p_pel_set(elenum).pop_cd,
        p_pel_set(elenum).bdgt_due_dt,
        p_pel_set(elenum).bdgt_export_flag,
        p_pel_set(elenum).bdgt_iss_dt,
        p_pel_set(elenum).bdgt_stat_cd,
        p_pel_set(elenum).ws_acc_cd,
        p_pel_set(elenum).ws_due_dt,
        p_pel_set(elenum).ws_export_flag,
        p_pel_set(elenum).ws_iss_dt,
        p_pel_set(elenum).ws_stat_cd,
        --cwb
        p_pel_set(elenum).auto_asnd_dt,
        p_pel_set(elenum).cbr_elig_perd_strt_dt,
        p_pel_set(elenum).cbr_elig_perd_end_dt,
        p_pel_set(elenum).lee_rsn_id,
        p_pel_set(elenum).enrt_perd_id,
        p_pel_set(elenum).per_in_ler_id,
        p_pel_set(elenum).pgm_id,
        p_pel_set(elenum).pl_id,
        p_pel_set(elenum).business_group_id,
        p_pel_set(elenum).pel_attribute_category,
        p_pel_set(elenum).pel_attribute1,
        p_pel_set(elenum).pel_attribute2,
        p_pel_set(elenum).pel_attribute3,
        p_pel_set(elenum).pel_attribute4,
        p_pel_set(elenum).pel_attribute5,
        p_pel_set(elenum).pel_attribute6,
        p_pel_set(elenum).pel_attribute7,
        p_pel_set(elenum).pel_attribute8,
        p_pel_set(elenum).pel_attribute9,
        p_pel_set(elenum).pel_attribute10,
        p_pel_set(elenum).pel_attribute11,
        p_pel_set(elenum).pel_attribute12,
        p_pel_set(elenum).pel_attribute13,
        p_pel_set(elenum).pel_attribute14,
        p_pel_set(elenum).pel_attribute15,
        p_pel_set(elenum).pel_attribute16,
        p_pel_set(elenum).pel_attribute17,
        p_pel_set(elenum).pel_attribute18,
        p_pel_set(elenum).pel_attribute19,
        p_pel_set(elenum).pel_attribute20,
        p_pel_set(elenum).pel_attribute21,
        p_pel_set(elenum).pel_attribute22,
        p_pel_set(elenum).pel_attribute23,
        p_pel_set(elenum).pel_attribute24,
        p_pel_set(elenum).pel_attribute25,
        p_pel_set(elenum).pel_attribute26,
        p_pel_set(elenum).pel_attribute27,
        p_pel_set(elenum).pel_attribute28,
        p_pel_set(elenum).pel_attribute29,
        p_pel_set(elenum).pel_attribute30,
        p_pel_set(elenum).request_id,
        p_pel_set(elenum).program_application_id,
        p_pel_set(elenum).program_id,
        p_pel_set(elenum).program_update_date,
        p_pel_set(elenum).object_version_number,
        p_benefit_action_id,
        p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pel_rbvs;
--
PROCEDURE write_ecc_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_ecc_set           in     t_ecc_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_ecc_set.count > 0 then
    --
    for elenum in p_ecc_set.first..p_ecc_set.last
    loop
      --
      insert into ben_elctbl_chc_ctfn_rbv
      (	elctbl_chc_ctfn_id,
    	enrt_ctfn_typ_cd,
    	rqd_flag,
    	elig_per_elctbl_chc_id,
    	enrt_bnft_id,
    	business_group_id,
    	ecc_attribute_category,
    	ecc_attribute1,
    	ecc_attribute2,
    	ecc_attribute3,
    	ecc_attribute4,
    	ecc_attribute5,
    	ecc_attribute6,
    	ecc_attribute7,
    	ecc_attribute8,
    	ecc_attribute9,
    	ecc_attribute10,
    	ecc_attribute11,
    	ecc_attribute12,
    	ecc_attribute13,
    	ecc_attribute14,
    	ecc_attribute15,
    	ecc_attribute16,
    	ecc_attribute17,
    	ecc_attribute18,
    	ecc_attribute19,
    	ecc_attribute20,
    	ecc_attribute21,
    	ecc_attribute22,
    	ecc_attribute23,
    	ecc_attribute24,
    	ecc_attribute25,
    	ecc_attribute26,
    	ecc_attribute27,
    	ecc_attribute28,
    	ecc_attribute29,
    	ecc_attribute30,
    	request_id,
    	program_application_id,
    	program_id,
    	program_update_date,
    	object_version_number,
        benefit_action_id,
        person_action_id
      )
  Values
      (	p_ecc_set(elenum).elctbl_chc_ctfn_id,
    	p_ecc_set(elenum).enrt_ctfn_typ_cd,
    	p_ecc_set(elenum).rqd_flag,
    	p_ecc_set(elenum).elig_per_elctbl_chc_id,
    	p_ecc_set(elenum).enrt_bnft_id,
    	p_ecc_set(elenum).business_group_id,
    	p_ecc_set(elenum).ecc_attribute_category,
    	p_ecc_set(elenum).ecc_attribute1,
    	p_ecc_set(elenum).ecc_attribute2,
    	p_ecc_set(elenum).ecc_attribute3,
    	p_ecc_set(elenum).ecc_attribute4,
    	p_ecc_set(elenum).ecc_attribute5,
    	p_ecc_set(elenum).ecc_attribute6,
    	p_ecc_set(elenum).ecc_attribute7,
    	p_ecc_set(elenum).ecc_attribute8,
    	p_ecc_set(elenum).ecc_attribute9,
    	p_ecc_set(elenum).ecc_attribute10,
    	p_ecc_set(elenum).ecc_attribute11,
    	p_ecc_set(elenum).ecc_attribute12,
    	p_ecc_set(elenum).ecc_attribute13,
    	p_ecc_set(elenum).ecc_attribute14,
    	p_ecc_set(elenum).ecc_attribute15,
    	p_ecc_set(elenum).ecc_attribute16,
    	p_ecc_set(elenum).ecc_attribute17,
    	p_ecc_set(elenum).ecc_attribute18,
    	p_ecc_set(elenum).ecc_attribute19,
    	p_ecc_set(elenum).ecc_attribute20,
    	p_ecc_set(elenum).ecc_attribute21,
    	p_ecc_set(elenum).ecc_attribute22,
    	p_ecc_set(elenum).ecc_attribute23,
    	p_ecc_set(elenum).ecc_attribute24,
    	p_ecc_set(elenum).ecc_attribute25,
    	p_ecc_set(elenum).ecc_attribute26,
    	p_ecc_set(elenum).ecc_attribute27,
    	p_ecc_set(elenum).ecc_attribute28,
    	p_ecc_set(elenum).ecc_attribute29,
    	p_ecc_set(elenum).ecc_attribute30,
    	p_ecc_set(elenum).request_id,
    	p_ecc_set(elenum).program_application_id,
    	p_ecc_set(elenum).program_id,
    	p_ecc_set(elenum).program_update_date,
    	p_ecc_set(elenum).object_version_number,
        p_benefit_action_id,
        p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_ecc_rbvs;
--
PROCEDURE write_egd_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_egd_set           in     t_egd_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_egd_set.count > 0 then
    --
    for elenum in p_egd_set.first ..p_egd_set.last
    loop
      --
      insert into ben_elig_dpnt_rbv
        ( elig_dpnt_id,
          create_dt,
          elig_strt_dt,
          elig_thru_dt,
          ovrdn_flag,
          ovrdn_thru_dt,
          inelg_rsn_cd,
          dpnt_inelig_flag,
          elig_per_elctbl_chc_id,
          per_in_ler_id,
          elig_per_id,
          elig_per_opt_id,
          elig_cvrd_dpnt_id,
          dpnt_person_id,
          business_group_id,
          egd_attribute_category,
          egd_attribute1,
          egd_attribute2,
          egd_attribute3,
          egd_attribute4,
          egd_attribute5,
          egd_attribute6,
          egd_attribute7,
          egd_attribute8,
          egd_attribute9,
          egd_attribute10,
          egd_attribute11,
          egd_attribute12,
          egd_attribute13,
          egd_attribute14,
          egd_attribute15,
          egd_attribute16,
          egd_attribute17,
          egd_attribute18,
          egd_attribute19,
          egd_attribute20,
          egd_attribute21,
          egd_attribute22,
          egd_attribute23,
          egd_attribute24,
          egd_attribute25,
          egd_attribute26,
          egd_attribute27,
          egd_attribute28,
          egd_attribute29,
          egd_attribute30,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          object_version_number,
          benefit_action_id,
          person_action_id
        )
        Values
        (p_egd_set(elenum).elig_dpnt_id,
         p_egd_set(elenum).create_dt,
         p_egd_set(elenum).elig_strt_dt,
         p_egd_set(elenum).elig_thru_dt,
         p_egd_set(elenum).ovrdn_flag,
         p_egd_set(elenum).ovrdn_thru_dt,
         p_egd_set(elenum).inelg_rsn_cd,
         p_egd_set(elenum).dpnt_inelig_flag,
         p_egd_set(elenum).elig_per_elctbl_chc_id,
         p_egd_set(elenum).per_in_ler_id,
         p_egd_set(elenum).elig_per_id,
         p_egd_set(elenum).elig_per_opt_id,
         p_egd_set(elenum).elig_cvrd_dpnt_id,
         p_egd_set(elenum).dpnt_person_id,
         p_egd_set(elenum).business_group_id,
         p_egd_set(elenum).egd_attribute_category,
         p_egd_set(elenum).egd_attribute1,
         p_egd_set(elenum).egd_attribute2,
         p_egd_set(elenum).egd_attribute3,
         p_egd_set(elenum).egd_attribute4,
         p_egd_set(elenum).egd_attribute5,
         p_egd_set(elenum).egd_attribute6,
         p_egd_set(elenum).egd_attribute7,
         p_egd_set(elenum).egd_attribute8,
         p_egd_set(elenum).egd_attribute9,
         p_egd_set(elenum).egd_attribute10,
         p_egd_set(elenum).egd_attribute11,
         p_egd_set(elenum).egd_attribute12,
         p_egd_set(elenum).egd_attribute13,
         p_egd_set(elenum).egd_attribute14,
         p_egd_set(elenum).egd_attribute15,
         p_egd_set(elenum).egd_attribute16,
         p_egd_set(elenum).egd_attribute17,
         p_egd_set(elenum).egd_attribute18,
         p_egd_set(elenum).egd_attribute19,
         p_egd_set(elenum).egd_attribute20,
         p_egd_set(elenum).egd_attribute21,
         p_egd_set(elenum).egd_attribute22,
         p_egd_set(elenum).egd_attribute23,
         p_egd_set(elenum).egd_attribute24,
         p_egd_set(elenum).egd_attribute25,
         p_egd_set(elenum).egd_attribute26,
         p_egd_set(elenum).egd_attribute27,
         p_egd_set(elenum).egd_attribute28,
         p_egd_set(elenum).egd_attribute29,
         p_egd_set(elenum).egd_attribute30,
         p_egd_set(elenum).request_id,
         p_egd_set(elenum).program_application_id,
         p_egd_set(elenum).program_id,
         p_egd_set(elenum).program_update_date,
         p_egd_set(elenum).object_version_number,
         p_benefit_action_id,
         p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_egd_rbvs;
--
PROCEDURE write_pdp_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pdp_set           in     t_pdp_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pdp_set.count > 0 then
    --
    for elenum in p_pdp_set.first ..p_pdp_set.last
    loop
      --
      insert into ben_elig_cvrd_dpnt_f_rbv
      (	elig_cvrd_dpnt_id,
        effective_start_date,
        effective_end_date,
        business_group_id,
        prtt_enrt_rslt_id,
        dpnt_person_id,
        cvg_strt_dt,
        cvg_thru_dt,
        cvg_pndg_flag,
        pdp_attribute_category,
	pdp_attribute1,
	pdp_attribute2,
	pdp_attribute3,
	pdp_attribute4,
	pdp_attribute5,
	pdp_attribute6,
	pdp_attribute7,
	pdp_attribute8,
	pdp_attribute9,
	pdp_attribute10,
	pdp_attribute11,
	pdp_attribute12,
	pdp_attribute13,
	pdp_attribute14,
	pdp_attribute15,
	pdp_attribute16,
	pdp_attribute17,
	pdp_attribute18,
	pdp_attribute19,
	pdp_attribute20,
	pdp_attribute21,
	pdp_attribute22,
	pdp_attribute23,
	pdp_attribute24,
	pdp_attribute25,
	pdp_attribute26,
	pdp_attribute27,
	pdp_attribute28,
	pdp_attribute29,
	pdp_attribute30,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
	object_version_number,
        ovrdn_flag,
        per_in_ler_id,
        ovrdn_thru_dt,
        created_by,
   	creation_date,
   	last_update_date,
   	last_updated_by,
   	last_update_login,
        benefit_action_id,
        person_action_id
      )
  Values
      (	p_pdp_set(elenum).elig_cvrd_dpnt_id,
	p_pdp_set(elenum).effective_start_date,
	p_pdp_set(elenum).effective_end_date,
	p_pdp_set(elenum).business_group_id,
	p_pdp_set(elenum).prtt_enrt_rslt_id,
	p_pdp_set(elenum).dpnt_person_id,
	p_pdp_set(elenum).cvg_strt_dt,
	p_pdp_set(elenum).cvg_thru_dt,
	p_pdp_set(elenum).cvg_pndg_flag,
	p_pdp_set(elenum).pdp_attribute_category,
	p_pdp_set(elenum).pdp_attribute1,
	p_pdp_set(elenum).pdp_attribute2,
	p_pdp_set(elenum).pdp_attribute3,
	p_pdp_set(elenum).pdp_attribute4,
	p_pdp_set(elenum).pdp_attribute5,
	p_pdp_set(elenum).pdp_attribute6,
	p_pdp_set(elenum).pdp_attribute7,
	p_pdp_set(elenum).pdp_attribute8,
	p_pdp_set(elenum).pdp_attribute9,
	p_pdp_set(elenum).pdp_attribute10,
	p_pdp_set(elenum).pdp_attribute11,
	p_pdp_set(elenum).pdp_attribute12,
	p_pdp_set(elenum).pdp_attribute13,
	p_pdp_set(elenum).pdp_attribute14,
	p_pdp_set(elenum).pdp_attribute15,
	p_pdp_set(elenum).pdp_attribute16,
	p_pdp_set(elenum).pdp_attribute17,
	p_pdp_set(elenum).pdp_attribute18,
	p_pdp_set(elenum).pdp_attribute19,
	p_pdp_set(elenum).pdp_attribute20,
	p_pdp_set(elenum).pdp_attribute21,
	p_pdp_set(elenum).pdp_attribute22,
	p_pdp_set(elenum).pdp_attribute23,
	p_pdp_set(elenum).pdp_attribute24,
	p_pdp_set(elenum).pdp_attribute25,
	p_pdp_set(elenum).pdp_attribute26,
	p_pdp_set(elenum).pdp_attribute27,
	p_pdp_set(elenum).pdp_attribute28,
	p_pdp_set(elenum).pdp_attribute29,
	p_pdp_set(elenum).pdp_attribute30,
	p_pdp_set(elenum).request_id,
	p_pdp_set(elenum).program_application_id,
	p_pdp_set(elenum).program_id,
	p_pdp_set(elenum).program_update_date,
	p_pdp_set(elenum).object_version_number,
	p_pdp_set(elenum).ovrdn_flag,
	p_pdp_set(elenum).per_in_ler_id,
	p_pdp_set(elenum).ovrdn_thru_dt,
	p_pdp_set(elenum).created_by,
	p_pdp_set(elenum).creation_date,
	p_pdp_set(elenum).last_update_date,
	p_pdp_set(elenum).last_updated_by,
        p_pdp_set(elenum).last_update_login,
        p_benefit_action_id,
        p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pdp_rbvs;
--
PROCEDURE write_cqb_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_cqb_set           in     t_cqb_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_cqb_set.count > 0 then
    --
    for elenum in p_cqb_set.first ..p_cqb_set.last
    loop
      --
      insert into ben_cbr_quald_bnf_rbv
        (cbr_quald_bnf_id
        ,quald_bnf_flag
        ,quald_bnf_person_id
        ,business_group_id
        ,cqb_attribute_category
        ,cqb_attribute1
        ,cqb_attribute2
        ,cqb_attribute3
        ,cqb_attribute4
        ,cqb_attribute5
        ,cqb_attribute6
        ,cqb_attribute7
        ,cqb_attribute8
        ,cqb_attribute9
        ,cqb_attribute10
        ,cqb_attribute11
        ,cqb_attribute12
        ,cqb_attribute13
        ,cqb_attribute14
        ,cqb_attribute15
        ,cqb_attribute16
        ,cqb_attribute17
        ,cqb_attribute18
        ,cqb_attribute19
        ,cqb_attribute20
        ,cqb_attribute21
        ,cqb_attribute22
        ,cqb_attribute23
        ,cqb_attribute24
        ,cqb_attribute25
        ,cqb_attribute26
        ,cqb_attribute27
        ,cqb_attribute28
        ,cqb_attribute29
        ,cqb_attribute30
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,object_version_number
        ,cbr_elig_perd_strt_dt
        ,cbr_elig_perd_end_dt
        ,cvrd_emp_person_id
        ,cbr_inelg_rsn_cd
        ,pgm_id
        ,ptip_id
        ,pl_typ_id
        ,benefit_action_id
        ,person_action_id
        )
      values
        (p_cqb_set(elenum).cbr_quald_bnf_id
        ,p_cqb_set(elenum).quald_bnf_flag
        ,p_cqb_set(elenum).quald_bnf_person_id
        ,p_cqb_set(elenum).business_group_id
        ,p_cqb_set(elenum).cqb_attribute_category
        ,p_cqb_set(elenum).cqb_attribute1
        ,p_cqb_set(elenum).cqb_attribute2
        ,p_cqb_set(elenum).cqb_attribute3
        ,p_cqb_set(elenum).cqb_attribute4
        ,p_cqb_set(elenum).cqb_attribute5
        ,p_cqb_set(elenum).cqb_attribute6
        ,p_cqb_set(elenum).cqb_attribute7
        ,p_cqb_set(elenum).cqb_attribute8
        ,p_cqb_set(elenum).cqb_attribute9
        ,p_cqb_set(elenum).cqb_attribute10
        ,p_cqb_set(elenum).cqb_attribute11
        ,p_cqb_set(elenum).cqb_attribute12
        ,p_cqb_set(elenum).cqb_attribute13
        ,p_cqb_set(elenum).cqb_attribute14
        ,p_cqb_set(elenum).cqb_attribute15
        ,p_cqb_set(elenum).cqb_attribute16
        ,p_cqb_set(elenum).cqb_attribute17
        ,p_cqb_set(elenum).cqb_attribute18
        ,p_cqb_set(elenum).cqb_attribute19
        ,p_cqb_set(elenum).cqb_attribute20
        ,p_cqb_set(elenum).cqb_attribute21
        ,p_cqb_set(elenum).cqb_attribute22
        ,p_cqb_set(elenum).cqb_attribute23
        ,p_cqb_set(elenum).cqb_attribute24
        ,p_cqb_set(elenum).cqb_attribute25
        ,p_cqb_set(elenum).cqb_attribute26
        ,p_cqb_set(elenum).cqb_attribute27
        ,p_cqb_set(elenum).cqb_attribute28
        ,p_cqb_set(elenum).cqb_attribute29
        ,p_cqb_set(elenum).cqb_attribute30
        ,p_cqb_set(elenum).last_update_date
        ,p_cqb_set(elenum).last_updated_by
        ,p_cqb_set(elenum).last_update_login
        ,p_cqb_set(elenum).created_by
        ,p_cqb_set(elenum).creation_date
        ,p_cqb_set(elenum).object_version_number
        ,p_cqb_set(elenum).cbr_elig_perd_strt_dt
        ,p_cqb_set(elenum).cbr_elig_perd_end_dt
        ,p_cqb_set(elenum).cvrd_emp_person_id
        ,p_cqb_set(elenum).cbr_inelg_rsn_cd
        ,p_cqb_set(elenum).pgm_id
        ,p_cqb_set(elenum).ptip_id
        ,p_cqb_set(elenum).pl_typ_id
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_cqb_rbvs;
--
PROCEDURE write_enb_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_enb_set           in     t_enb_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_enb_set.count > 0 then
    --
    for elenum in p_enb_set.first ..p_enb_set.last
    loop
      --
      insert into ben_enrt_bnft_rbv
        (enrt_bnft_id
	,dflt_flag
	,val_has_bn_prortd_flag
	,bndry_perd_cd
	,val
	,nnmntry_uom
	,bnft_typ_cd
	,entr_val_at_enrt_flag
	,mn_val
	,mx_val
	,incrmt_val
        ,dflt_val
	,rt_typ_cd
	,cvg_mlt_cd
	,ctfn_rqd_flag
	,ordr_num
	,crntly_enrld_flag
	,elig_per_elctbl_chc_id
	,prtt_enrt_rslt_id
	,comp_lvl_fctr_id
	,business_group_id
	,enb_attribute_category
	,enb_attribute1
	,enb_attribute2
	,enb_attribute3
	,enb_attribute4
	,enb_attribute5
	,enb_attribute6
	,enb_attribute7
	,enb_attribute8
	,enb_attribute9
	,enb_attribute10
	,enb_attribute11
	,enb_attribute12
	,enb_attribute13
	,enb_attribute14
	,enb_attribute15
	,enb_attribute16
	,enb_attribute17
	,enb_attribute18
	,enb_attribute19
	,enb_attribute20
	,enb_attribute21
	,enb_attribute22
	,enb_attribute23
	,enb_attribute24
	,enb_attribute25
	,enb_attribute26
	,enb_attribute27
	,enb_attribute28
	,enb_attribute29
        ,enb_attribute30
        ,request_id
        ,program_application_id
        ,program_id
        ,mx_wout_ctfn_val
        ,mx_wo_ctfn_flag
        ,program_update_date
        ,object_version_number
        ,benefit_action_id
        ,person_action_id
        )
     Values
        (p_enb_set(elenum).enrt_bnft_id
        ,p_enb_set(elenum).dflt_flag
        ,p_enb_set(elenum).val_has_bn_prortd_flag
        ,p_enb_set(elenum).bndry_perd_cd
        ,p_enb_set(elenum).val
        ,p_enb_set(elenum).nnmntry_uom
        ,p_enb_set(elenum).bnft_typ_cd
        ,p_enb_set(elenum).entr_val_at_enrt_flag
        ,p_enb_set(elenum).mn_val
        ,p_enb_set(elenum).mx_val
        ,p_enb_set(elenum).incrmt_val
        ,p_enb_set(elenum).dflt_val
        ,p_enb_set(elenum).rt_typ_cd
        ,p_enb_set(elenum).cvg_mlt_cd
        ,p_enb_set(elenum).ctfn_rqd_flag
        ,p_enb_set(elenum).ordr_num
        ,p_enb_set(elenum).crntly_enrld_flag
        ,p_enb_set(elenum).elig_per_elctbl_chc_id
        ,p_enb_set(elenum).prtt_enrt_rslt_id
        ,p_enb_set(elenum).comp_lvl_fctr_id
        ,p_enb_set(elenum).business_group_id
        ,p_enb_set(elenum).enb_attribute_category
        ,p_enb_set(elenum).enb_attribute1
        ,p_enb_set(elenum).enb_attribute2
        ,p_enb_set(elenum).enb_attribute3
        ,p_enb_set(elenum).enb_attribute4
        ,p_enb_set(elenum).enb_attribute5
        ,p_enb_set(elenum).enb_attribute6
        ,p_enb_set(elenum).enb_attribute7
        ,p_enb_set(elenum).enb_attribute8
        ,p_enb_set(elenum).enb_attribute9
        ,p_enb_set(elenum).enb_attribute10
        ,p_enb_set(elenum).enb_attribute11
        ,p_enb_set(elenum).enb_attribute12
        ,p_enb_set(elenum).enb_attribute13
        ,p_enb_set(elenum).enb_attribute14
        ,p_enb_set(elenum).enb_attribute15
        ,p_enb_set(elenum).enb_attribute16
        ,p_enb_set(elenum).enb_attribute17
        ,p_enb_set(elenum).enb_attribute18
        ,p_enb_set(elenum).enb_attribute19
        ,p_enb_set(elenum).enb_attribute20
        ,p_enb_set(elenum).enb_attribute21
        ,p_enb_set(elenum).enb_attribute22
        ,p_enb_set(elenum).enb_attribute23
        ,p_enb_set(elenum).enb_attribute24
        ,p_enb_set(elenum).enb_attribute25
        ,p_enb_set(elenum).enb_attribute26
        ,p_enb_set(elenum).enb_attribute27
        ,p_enb_set(elenum).enb_attribute28
        ,p_enb_set(elenum).enb_attribute29
        ,p_enb_set(elenum).enb_attribute30
        ,p_enb_set(elenum).request_id
        ,p_enb_set(elenum).program_application_id
        ,p_enb_set(elenum).program_id
        ,p_enb_set(elenum).mx_wout_ctfn_val
        ,p_enb_set(elenum).mx_wo_ctfn_flag
        ,p_enb_set(elenum).program_update_date
        ,p_enb_set(elenum).object_version_number
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_enb_rbvs;
--
PROCEDURE write_epr_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_epr_set           in     t_epr_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_epr_set.count > 0 then
    --
    for elenum in p_epr_set.first ..p_epr_set.last
    loop
      --
      insert into ben_enrt_prem_rbv
        (enrt_prem_id,
         val,
         uom,
         elig_per_elctbl_chc_id,
         enrt_bnft_id,
         actl_prem_id,
         business_group_id,
         epr_attribute_category,
         epr_attribute1,
         epr_attribute2,
         epr_attribute3,
         epr_attribute4,
         epr_attribute5,
         epr_attribute6,
         epr_attribute7,
         epr_attribute8,
         epr_attribute9,
         epr_attribute10,
         epr_attribute11,
         epr_attribute12,
         epr_attribute13,
         epr_attribute14,
         epr_attribute15,
         epr_attribute16,
         epr_attribute17,
         epr_attribute18,
         epr_attribute19,
         epr_attribute20,
         epr_attribute21,
         epr_attribute22,
         epr_attribute23,
         epr_attribute24,
         epr_attribute25,
         epr_attribute26,
         epr_attribute27,
         epr_attribute28,
         epr_attribute29,
         epr_attribute30,
         object_version_number,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         benefit_action_id,
         person_action_id
        )
    VALUES
      (p_epr_set(elenum).enrt_prem_id,
       p_epr_set(elenum).val,
       p_epr_set(elenum).uom,
       p_epr_set(elenum).elig_per_elctbl_chc_id,
       p_epr_set(elenum).enrt_bnft_id,
       p_epr_set(elenum).actl_prem_id,
       p_epr_set(elenum).business_group_id,
       p_epr_set(elenum).epr_attribute_category,
       p_epr_set(elenum).epr_attribute1,
       p_epr_set(elenum).epr_attribute2,
       p_epr_set(elenum).epr_attribute3,
       p_epr_set(elenum).epr_attribute4,
       p_epr_set(elenum).epr_attribute5,
       p_epr_set(elenum).epr_attribute6,
       p_epr_set(elenum).epr_attribute7,
       p_epr_set(elenum).epr_attribute8,
       p_epr_set(elenum).epr_attribute9,
       p_epr_set(elenum).epr_attribute10,
       p_epr_set(elenum).epr_attribute11,
       p_epr_set(elenum).epr_attribute12,
       p_epr_set(elenum).epr_attribute13,
       p_epr_set(elenum).epr_attribute14,
       p_epr_set(elenum).epr_attribute15,
       p_epr_set(elenum).epr_attribute16,
       p_epr_set(elenum).epr_attribute17,
       p_epr_set(elenum).epr_attribute18,
       p_epr_set(elenum).epr_attribute19,
       p_epr_set(elenum).epr_attribute20,
       p_epr_set(elenum).epr_attribute21,
       p_epr_set(elenum).epr_attribute22,
       p_epr_set(elenum).epr_attribute23,
       p_epr_set(elenum).epr_attribute24,
       p_epr_set(elenum).epr_attribute25,
       p_epr_set(elenum).epr_attribute26,
       p_epr_set(elenum).epr_attribute27,
       p_epr_set(elenum).epr_attribute28,
       p_epr_set(elenum).epr_attribute29,
       p_epr_set(elenum).epr_attribute30,
       p_epr_set(elenum).object_version_number,
       p_epr_set(elenum).request_id,
       p_epr_set(elenum).program_application_id,
       p_epr_set(elenum).program_id,
       p_epr_set(elenum).program_update_date,
       p_benefit_action_id,
       p_person_action_id
       );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_epr_rbvs;
--
PROCEDURE write_ecr_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_ecr_set           in     t_ecr_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_ecr_set.count > 0 then
    --
    for elenum in p_ecr_set.first ..p_ecr_set.last
    loop
      --
      insert into ben_enrt_rt_rbv
        (enrt_rt_id,
         acty_typ_cd,
         tx_typ_cd,
         ctfn_rqd_flag,
         dflt_flag,
         dflt_pndg_ctfn_flag,
         dsply_on_enrt_flag,
         use_to_calc_net_flx_cr_flag,
         entr_val_at_enrt_flag,
         asn_on_enrt_flag,
         rl_crs_only_flag,
         dflt_val,
         ann_val,
         ann_mn_elcn_val,
         ann_mx_elcn_val,
         val,
         nnmntry_uom,
         mx_elcn_val,
         mn_elcn_val,
         incrmt_elcn_val,
         cmcd_acty_ref_perd_cd,
         cmcd_mn_elcn_val,
         cmcd_mx_elcn_val,
         cmcd_val,
         cmcd_dflt_val,
         rt_usg_cd,
         ann_dflt_val,
         bnft_rt_typ_cd,
         rt_mlt_cd,
         dsply_mn_elcn_val,
         dsply_mx_elcn_val,
         entr_ann_val_flag,
         rt_strt_dt,
         rt_strt_dt_cd,
         rt_strt_dt_rl,
         rt_typ_cd,
         elig_per_elctbl_chc_id,
         acty_base_rt_id,
         spcl_rt_enrt_rt_id,
         enrt_bnft_id,
         prtt_rt_val_id,
         decr_bnft_prvdr_pool_id,
         cvg_amt_calc_mthd_id,
         actl_prem_id,
         comp_lvl_fctr_id,
         ptd_comp_lvl_fctr_id,
         clm_comp_lvl_fctr_id,
         business_group_id,
         ecr_attribute_category,
         ecr_attribute1,
         ecr_attribute2,
         ecr_attribute3,
         ecr_attribute4,
         ecr_attribute5,
         ecr_attribute6,
         ecr_attribute7,
         ecr_attribute8,
         ecr_attribute9,
         ecr_attribute10,
         ecr_attribute11,
         ecr_attribute12,
         ecr_attribute13,
         ecr_attribute14,
         ecr_attribute15,
         ecr_attribute16,
         ecr_attribute17,
         ecr_attribute18,
         ecr_attribute19,
         ecr_attribute20,
         ecr_attribute21,
         ecr_attribute22,
         ecr_attribute23,
         ecr_attribute24,
         ecr_attribute25,
         ecr_attribute26,
         ecr_attribute27,
         ecr_attribute28,
         ecr_attribute29,
         ecr_attribute30,
         last_update_login,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         object_version_number,
         benefit_action_id,
         person_action_id
         )
      VALUES
        (p_ecr_set(elenum).enrt_rt_id,
         p_ecr_set(elenum).acty_typ_cd,
         p_ecr_set(elenum).tx_typ_cd,
         p_ecr_set(elenum).ctfn_rqd_flag,
         p_ecr_set(elenum).dflt_flag,
         p_ecr_set(elenum).dflt_pndg_ctfn_flag,
         p_ecr_set(elenum).dsply_on_enrt_flag,
         p_ecr_set(elenum).use_to_calc_net_flx_cr_flag,
         p_ecr_set(elenum).entr_val_at_enrt_flag,
         p_ecr_set(elenum).asn_on_enrt_flag,
         p_ecr_set(elenum).rl_crs_only_flag,
         p_ecr_set(elenum).dflt_val,
         p_ecr_set(elenum).ann_val,
         p_ecr_set(elenum).ann_mn_elcn_val,
         p_ecr_set(elenum).ann_mx_elcn_val,
         p_ecr_set(elenum).val,
         p_ecr_set(elenum).nnmntry_uom,
         p_ecr_set(elenum).mx_elcn_val,
         p_ecr_set(elenum).mn_elcn_val,
         p_ecr_set(elenum).incrmt_elcn_val,
         p_ecr_set(elenum).cmcd_acty_ref_perd_cd,
         p_ecr_set(elenum).cmcd_mn_elcn_val,
         p_ecr_set(elenum).cmcd_mx_elcn_val,
         p_ecr_set(elenum).cmcd_val,
         p_ecr_set(elenum).cmcd_dflt_val,
         p_ecr_set(elenum).rt_usg_cd,
         p_ecr_set(elenum).ann_dflt_val,
         p_ecr_set(elenum).bnft_rt_typ_cd,
         p_ecr_set(elenum).rt_mlt_cd,
         p_ecr_set(elenum).dsply_mn_elcn_val,
         p_ecr_set(elenum).dsply_mx_elcn_val,
         p_ecr_set(elenum).entr_ann_val_flag,
         p_ecr_set(elenum).rt_strt_dt,
         p_ecr_set(elenum).rt_strt_dt_cd,
         p_ecr_set(elenum).rt_strt_dt_rl,
         p_ecr_set(elenum).rt_typ_cd,
         p_ecr_set(elenum).elig_per_elctbl_chc_id,
         p_ecr_set(elenum).acty_base_rt_id,
         p_ecr_set(elenum).spcl_rt_enrt_rt_id,
         p_ecr_set(elenum).enrt_bnft_id,
         p_ecr_set(elenum).prtt_rt_val_id,
         p_ecr_set(elenum).decr_bnft_prvdr_pool_id,
         p_ecr_set(elenum).cvg_amt_calc_mthd_id,
         p_ecr_set(elenum).actl_prem_id,
         p_ecr_set(elenum).comp_lvl_fctr_id,
         p_ecr_set(elenum).ptd_comp_lvl_fctr_id,
         p_ecr_set(elenum).clm_comp_lvl_fctr_id,
         p_ecr_set(elenum).business_group_id,
         p_ecr_set(elenum).ecr_attribute_category,
         p_ecr_set(elenum).ecr_attribute1,
         p_ecr_set(elenum).ecr_attribute2,
         p_ecr_set(elenum).ecr_attribute3,
         p_ecr_set(elenum).ecr_attribute4,
         p_ecr_set(elenum).ecr_attribute5,
         p_ecr_set(elenum).ecr_attribute6,
         p_ecr_set(elenum).ecr_attribute7,
         p_ecr_set(elenum).ecr_attribute8,
         p_ecr_set(elenum).ecr_attribute9,
         p_ecr_set(elenum).ecr_attribute10,
         p_ecr_set(elenum).ecr_attribute11,
         p_ecr_set(elenum).ecr_attribute12,
         p_ecr_set(elenum).ecr_attribute13,
         p_ecr_set(elenum).ecr_attribute14,
         p_ecr_set(elenum).ecr_attribute15,
         p_ecr_set(elenum).ecr_attribute16,
         p_ecr_set(elenum).ecr_attribute17,
         p_ecr_set(elenum).ecr_attribute18,
         p_ecr_set(elenum).ecr_attribute19,
         p_ecr_set(elenum).ecr_attribute20,
         p_ecr_set(elenum).ecr_attribute21,
         p_ecr_set(elenum).ecr_attribute22,
         p_ecr_set(elenum).ecr_attribute23,
         p_ecr_set(elenum).ecr_attribute24,
         p_ecr_set(elenum).ecr_attribute25,
         p_ecr_set(elenum).ecr_attribute26,
         p_ecr_set(elenum).ecr_attribute27,
         p_ecr_set(elenum).ecr_attribute28,
         p_ecr_set(elenum).ecr_attribute29,
         p_ecr_set(elenum).ecr_attribute30,
         p_ecr_set(elenum).last_update_login,
         p_ecr_set(elenum).created_by,
         p_ecr_set(elenum).creation_date,
         p_ecr_set(elenum).last_updated_by,
         p_ecr_set(elenum).last_update_date,
         p_ecr_set(elenum).request_id,
         p_ecr_set(elenum).program_application_id,
         p_ecr_set(elenum).program_id,
         p_ecr_set(elenum).program_update_date,
         p_ecr_set(elenum).object_version_number,
         p_benefit_action_id,
         p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_ecr_rbvs;
--
PROCEDURE write_prv_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_prv_set           in     t_prv_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_prv_set.count > 0 then
    --
    for elenum in p_prv_set.first ..p_prv_set.last
    loop
      --
      insert into ben_prtt_rt_val_rbv
      (	prtt_rt_val_id,
    	rt_strt_dt,
    	rt_end_dt,
    	rt_typ_cd,
    	tx_typ_cd,
    	acty_typ_cd,
    	mlt_cd,
    	acty_ref_perd_cd,
    	rt_val,
    	ann_rt_val,
    	cmcd_rt_val,
    	cmcd_ref_perd_cd,
    	bnft_rt_typ_cd,
    	dsply_on_enrt_flag,
    	rt_ovridn_flag,
    	rt_ovridn_thru_dt,
    	elctns_made_dt,
    	prtt_rt_val_stat_cd,
    	prtt_enrt_rslt_id,
    	cvg_amt_calc_mthd_id,
    	actl_prem_id,
    	comp_lvl_fctr_id,
    	element_entry_value_id,
    	per_in_ler_id,
    	ended_per_in_ler_id,
    	acty_base_rt_id,
    	prtt_reimbmt_rqst_id,
        prtt_rmt_aprvd_fr_pymt_id,
    	business_group_id,
    	prv_attribute_category,
    	prv_attribute1,
    	prv_attribute2,
    	prv_attribute3,
    	prv_attribute4,
    	prv_attribute5,
    	prv_attribute6,
    	prv_attribute7,
    	prv_attribute8,
    	prv_attribute9,
    	prv_attribute10,
    	prv_attribute11,
    	prv_attribute12,
    	prv_attribute13,
    	prv_attribute14,
    	prv_attribute15,
    	prv_attribute16,
    	prv_attribute17,
    	prv_attribute18,
    	prv_attribute19,
    	prv_attribute20,
    	prv_attribute21,
    	prv_attribute22,
    	prv_attribute23,
    	prv_attribute24,
    	prv_attribute25,
    	prv_attribute26,
    	prv_attribute27,
    	prv_attribute28,
    	prv_attribute29,
    	prv_attribute30,
    	object_version_number,
        benefit_action_id,
        person_action_id
      )
      Values
      (	p_prv_set(elenum).prtt_rt_val_id,
        p_prv_set(elenum).rt_strt_dt,
        p_prv_set(elenum).rt_end_dt,
        p_prv_set(elenum).rt_typ_cd,
        p_prv_set(elenum).tx_typ_cd,
        p_prv_set(elenum).acty_typ_cd,
        p_prv_set(elenum).mlt_cd,
        p_prv_set(elenum).acty_ref_perd_cd,
        p_prv_set(elenum).rt_val,
        p_prv_set(elenum).ann_rt_val,
        p_prv_set(elenum).cmcd_rt_val,
        p_prv_set(elenum).cmcd_ref_perd_cd,
        p_prv_set(elenum).bnft_rt_typ_cd,
        p_prv_set(elenum).dsply_on_enrt_flag,
        p_prv_set(elenum).rt_ovridn_flag,
        p_prv_set(elenum).rt_ovridn_thru_dt,
        p_prv_set(elenum).elctns_made_dt,
        p_prv_set(elenum).prtt_rt_val_stat_cd,
        p_prv_set(elenum).prtt_enrt_rslt_id,
        p_prv_set(elenum).cvg_amt_calc_mthd_id,
        p_prv_set(elenum).actl_prem_id,
        p_prv_set(elenum).comp_lvl_fctr_id,
        p_prv_set(elenum).element_entry_value_id,
        p_prv_set(elenum).per_in_ler_id,
        p_prv_set(elenum).ended_per_in_ler_id,
        p_prv_set(elenum).acty_base_rt_id,
        p_prv_set(elenum).prtt_reimbmt_rqst_id,
        p_prv_set(elenum).prtt_rmt_aprvd_fr_pymt_id,
        p_prv_set(elenum).business_group_id,
        p_prv_set(elenum).prv_attribute_category,
        p_prv_set(elenum).prv_attribute1,
        p_prv_set(elenum).prv_attribute2,
        p_prv_set(elenum).prv_attribute3,
        p_prv_set(elenum).prv_attribute4,
        p_prv_set(elenum).prv_attribute5,
        p_prv_set(elenum).prv_attribute6,
        p_prv_set(elenum).prv_attribute7,
        p_prv_set(elenum).prv_attribute8,
        p_prv_set(elenum).prv_attribute9,
        p_prv_set(elenum).prv_attribute10,
        p_prv_set(elenum).prv_attribute11,
        p_prv_set(elenum).prv_attribute12,
        p_prv_set(elenum).prv_attribute13,
        p_prv_set(elenum).prv_attribute14,
        p_prv_set(elenum).prv_attribute15,
        p_prv_set(elenum).prv_attribute16,
        p_prv_set(elenum).prv_attribute17,
        p_prv_set(elenum).prv_attribute18,
        p_prv_set(elenum).prv_attribute19,
        p_prv_set(elenum).prv_attribute20,
        p_prv_set(elenum).prv_attribute21,
        p_prv_set(elenum).prv_attribute22,
        p_prv_set(elenum).prv_attribute23,
        p_prv_set(elenum).prv_attribute24,
        p_prv_set(elenum).prv_attribute25,
        p_prv_set(elenum).prv_attribute26,
        p_prv_set(elenum).prv_attribute27,
        p_prv_set(elenum).prv_attribute28,
        p_prv_set(elenum).prv_attribute29,
        p_prv_set(elenum).prv_attribute30,
        p_prv_set(elenum).object_version_number,
        p_benefit_action_id,
        p_person_action_id
      );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_prv_rbvs;
--
PROCEDURE write_pen_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pen_set           in     t_pen_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pen_set.count > 0 then
    --
    for elenum in p_pen_set.first ..p_pen_set.last
    loop
      --
      insert into ben_prtt_enrt_rslt_f_rbv
        ( prtt_enrt_rslt_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          oipl_id,
          person_id,
          assignment_id,
          pgm_id,
          pl_id,
          rplcs_sspndd_rslt_id,
          ptip_id,
          pl_typ_id,
          ler_id,
          sspndd_flag,
          prtt_is_cvrd_flag,
          bnft_amt,
          uom     ,
          orgnl_enrt_dt,
          enrt_mthd_cd,
          no_lngr_elig_flag,
          enrt_ovridn_flag,
          enrt_ovrid_rsn_cd,
          erlst_deenrt_dt,
          enrt_cvg_strt_dt,
          enrt_cvg_thru_dt,
          enrt_ovrid_thru_dt,
          pl_ordr_num,
          plip_ordr_num,
          ptip_ordr_num,
          oipl_ordr_num,
          pen_attribute_category,
          pen_attribute1,
          pen_attribute2,
          pen_attribute3,
          pen_attribute4,
          pen_attribute5,
          pen_attribute6,
          pen_attribute7,
          pen_attribute8,
          pen_attribute9,
          pen_attribute10,
          pen_attribute11,
          pen_attribute12,
          pen_attribute13,
          pen_attribute14,
          pen_attribute15,
          pen_attribute16,
          pen_attribute17,
          pen_attribute18,
          pen_attribute19,
          pen_attribute20,
          pen_attribute21,
          pen_attribute22,
          pen_attribute23,
          pen_attribute24,
          pen_attribute25,
          pen_attribute26,
          pen_attribute27,
          pen_attribute28,
          pen_attribute29,
          pen_attribute30,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          object_version_number,
          per_in_ler_id,
          bnft_typ_cd,
          bnft_ordr_num,
          prtt_enrt_rslt_stat_cd,
          bnft_nnmntry_uom,
          comp_lvl_cd,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          benefit_action_id,
          person_action_id
          )
        Values
          (p_pen_set(elenum).prtt_enrt_rslt_id,
          p_pen_set(elenum).effective_start_date,
          p_pen_set(elenum).effective_end_date,
          p_pen_set(elenum).business_group_id,
          p_pen_set(elenum).oipl_id,
          p_pen_set(elenum).person_id,
          p_pen_set(elenum).assignment_id,
          p_pen_set(elenum).pgm_id,
          p_pen_set(elenum).pl_id,
          p_pen_set(elenum).rplcs_sspndd_rslt_id,
          p_pen_set(elenum).ptip_id,
          p_pen_set(elenum).pl_typ_id,
          p_pen_set(elenum).ler_id,
          p_pen_set(elenum).sspndd_flag,
          p_pen_set(elenum).prtt_is_cvrd_flag,
          p_pen_set(elenum).bnft_amt,
          p_pen_set(elenum).uom     ,
          p_pen_set(elenum).orgnl_enrt_dt,
          p_pen_set(elenum).enrt_mthd_cd,
          p_pen_set(elenum).no_lngr_elig_flag,
          p_pen_set(elenum).enrt_ovridn_flag,
          p_pen_set(elenum).enrt_ovrid_rsn_cd,
          p_pen_set(elenum).erlst_deenrt_dt,
          p_pen_set(elenum).enrt_cvg_strt_dt,
          p_pen_set(elenum).enrt_cvg_thru_dt,
          p_pen_set(elenum).enrt_ovrid_thru_dt,
          p_pen_set(elenum).pl_ordr_num,
          p_pen_set(elenum).plip_ordr_num,
          p_pen_set(elenum).ptip_ordr_num,
          p_pen_set(elenum).oipl_ordr_num,
          p_pen_set(elenum).pen_attribute_category,
          p_pen_set(elenum).pen_attribute1,
          p_pen_set(elenum).pen_attribute2,
          p_pen_set(elenum).pen_attribute3,
          p_pen_set(elenum).pen_attribute4,
          p_pen_set(elenum).pen_attribute5,
          p_pen_set(elenum).pen_attribute6,
          p_pen_set(elenum).pen_attribute7,
          p_pen_set(elenum).pen_attribute8,
          p_pen_set(elenum).pen_attribute9,
          p_pen_set(elenum).pen_attribute10,
          p_pen_set(elenum).pen_attribute11,
          p_pen_set(elenum).pen_attribute12,
          p_pen_set(elenum).pen_attribute13,
          p_pen_set(elenum).pen_attribute14,
          p_pen_set(elenum).pen_attribute15,
          p_pen_set(elenum).pen_attribute16,
          p_pen_set(elenum).pen_attribute17,
          p_pen_set(elenum).pen_attribute18,
          p_pen_set(elenum).pen_attribute19,
          p_pen_set(elenum).pen_attribute20,
          p_pen_set(elenum).pen_attribute21,
          p_pen_set(elenum).pen_attribute22,
          p_pen_set(elenum).pen_attribute23,
          p_pen_set(elenum).pen_attribute24,
          p_pen_set(elenum).pen_attribute25,
          p_pen_set(elenum).pen_attribute26,
          p_pen_set(elenum).pen_attribute27,
          p_pen_set(elenum).pen_attribute28,
          p_pen_set(elenum).pen_attribute29,
          p_pen_set(elenum).pen_attribute30,
          p_pen_set(elenum).request_id,
          p_pen_set(elenum).program_application_id,
          p_pen_set(elenum).program_id,
          p_pen_set(elenum).program_update_date,
          p_pen_set(elenum).object_version_number,
          p_pen_set(elenum).per_in_ler_id,
          p_pen_set(elenum).bnft_typ_cd,
          p_pen_set(elenum).bnft_ordr_num,
          p_pen_set(elenum).prtt_enrt_rslt_stat_cd,
          p_pen_set(elenum).bnft_nnmntry_uom,
          p_pen_set(elenum).comp_lvl_cd,
          p_pen_set(elenum).created_by,
          p_pen_set(elenum).creation_date,
          p_pen_set(elenum).last_update_date,
          p_pen_set(elenum).last_updated_by,
          p_pen_set(elenum).last_update_login,
          p_benefit_action_id,
          p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pen_rbvs;
--
PROCEDURE write_pcm_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_pcm_set           in     t_pcm_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_pcm_set.count > 0 then
    --
    for elenum in p_pcm_set.first ..p_pcm_set.last
    loop
      --
      insert into ben_per_cm_f_rbv
      (	per_cm_id,
    	effective_start_date,
    	effective_end_date,
    	lf_evt_ocrd_dt,
        rqstbl_untl_dt,
    	ler_id,
    	per_in_ler_id,
    	prtt_enrt_actn_id,
    	person_id,
    	bnf_person_id,
    	dpnt_person_id,
    	cm_typ_id,
    	business_group_id,
    	pcm_attribute_category,
    	pcm_attribute1,
    	pcm_attribute2,
    	pcm_attribute3,
    	pcm_attribute4,
    	pcm_attribute5,
    	pcm_attribute6,
    	pcm_attribute7,
    	pcm_attribute8,
    	pcm_attribute9,
    	pcm_attribute10,
    	pcm_attribute11,
    	pcm_attribute12,
    	pcm_attribute13,
    	pcm_attribute14,
    	pcm_attribute15,
    	pcm_attribute16,
    	pcm_attribute17,
    	pcm_attribute18,
    	pcm_attribute19,
    	pcm_attribute20,
    	pcm_attribute21,
    	pcm_attribute22,
    	pcm_attribute23,
    	pcm_attribute24,
    	pcm_attribute25,
    	pcm_attribute26,
    	pcm_attribute27,
    	pcm_attribute28,
    	pcm_attribute29,
    	pcm_attribute30,
    	request_id,
    	program_application_id,
    	program_id,
    	program_update_date,
    	object_version_number
       	, created_by,
       	creation_date,
       	last_update_date,
       	last_updated_by,
       	last_update_login,
        benefit_action_id,
        person_action_id
      )
      Values
      (	p_pcm_set(elenum).per_cm_id,
    	p_pcm_set(elenum).effective_start_date,
    	p_pcm_set(elenum).effective_end_date,
    	p_pcm_set(elenum).lf_evt_ocrd_dt,
    	p_pcm_set(elenum).rqstbl_untl_dt,
    	p_pcm_set(elenum).ler_id,
    	p_pcm_set(elenum).per_in_ler_id,
    	p_pcm_set(elenum).prtt_enrt_actn_id,
    	p_pcm_set(elenum).person_id,
    	p_pcm_set(elenum).bnf_person_id,
    	p_pcm_set(elenum).dpnt_person_id,
    	p_pcm_set(elenum).cm_typ_id,
    	p_pcm_set(elenum).business_group_id,
    	p_pcm_set(elenum).pcm_attribute_category,
    	p_pcm_set(elenum).pcm_attribute1,
    	p_pcm_set(elenum).pcm_attribute2,
    	p_pcm_set(elenum).pcm_attribute3,
    	p_pcm_set(elenum).pcm_attribute4,
    	p_pcm_set(elenum).pcm_attribute5,
    	p_pcm_set(elenum).pcm_attribute6,
    	p_pcm_set(elenum).pcm_attribute7,
    	p_pcm_set(elenum).pcm_attribute8,
    	p_pcm_set(elenum).pcm_attribute9,
    	p_pcm_set(elenum).pcm_attribute10,
    	p_pcm_set(elenum).pcm_attribute11,
    	p_pcm_set(elenum).pcm_attribute12,
    	p_pcm_set(elenum).pcm_attribute13,
    	p_pcm_set(elenum).pcm_attribute14,
    	p_pcm_set(elenum).pcm_attribute15,
    	p_pcm_set(elenum).pcm_attribute16,
    	p_pcm_set(elenum).pcm_attribute17,
    	p_pcm_set(elenum).pcm_attribute18,
    	p_pcm_set(elenum).pcm_attribute19,
    	p_pcm_set(elenum).pcm_attribute20,
    	p_pcm_set(elenum).pcm_attribute21,
    	p_pcm_set(elenum).pcm_attribute22,
    	p_pcm_set(elenum).pcm_attribute23,
    	p_pcm_set(elenum).pcm_attribute24,
    	p_pcm_set(elenum).pcm_attribute25,
    	p_pcm_set(elenum).pcm_attribute26,
    	p_pcm_set(elenum).pcm_attribute27,
    	p_pcm_set(elenum).pcm_attribute28,
    	p_pcm_set(elenum).pcm_attribute29,
    	p_pcm_set(elenum).pcm_attribute30,
    	p_pcm_set(elenum).request_id,
    	p_pcm_set(elenum).program_application_id,
    	p_pcm_set(elenum).program_id,
    	p_pcm_set(elenum).program_update_date,
    	p_pcm_set(elenum).object_version_number,
    	p_pcm_set(elenum).created_by,
    	p_pcm_set(elenum).creation_date,
    	p_pcm_set(elenum).last_update_date,
    	p_pcm_set(elenum).last_updated_by,
    	p_pcm_set(elenum).last_update_login,
        p_benefit_action_id,
        p_person_action_id
      );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_pcm_rbvs;
--
PROCEDURE write_bpl_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_bpl_set           in     t_bpl_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_bpl_set.count > 0 then
    --
    for elenum in p_bpl_set.first ..p_bpl_set.last
    loop
      --
      insert into ben_bnft_prvdd_ldgr_f_rbv
      (	bnft_prvdd_ldgr_id,
    	effective_start_date,
    	effective_end_date,
    	prtt_ro_of_unusd_amt_flag,
    	frftd_val,
    	prvdd_val,
    	used_val,
    	bnft_prvdr_pool_id,
    	acty_base_rt_id,
    	per_in_ler_id,
    	prtt_enrt_rslt_id,
    	business_group_id,
    	bpl_attribute_category,
    	bpl_attribute1,
    	bpl_attribute2,
    	bpl_attribute3,
    	bpl_attribute4,
    	bpl_attribute5,
    	bpl_attribute6,
    	bpl_attribute7,
    	bpl_attribute8,
    	bpl_attribute9,
    	bpl_attribute10,
    	bpl_attribute11,
    	bpl_attribute12,
    	bpl_attribute13,
    	bpl_attribute14,
    	bpl_attribute15,
    	bpl_attribute16,
    	bpl_attribute17,
    	bpl_attribute18,
    	bpl_attribute19,
    	bpl_attribute20,
    	bpl_attribute21,
    	bpl_attribute22,
    	bpl_attribute23,
    	bpl_attribute24,
    	bpl_attribute25,
    	bpl_attribute26,
    	bpl_attribute27,
    	bpl_attribute28,
    	bpl_attribute29,
    	bpl_attribute30,
    	object_version_number,
    	cash_recd_val
       	, created_by,
       	creation_date,
       	last_update_date,
       	last_updated_by,
       	last_update_login,
        benefit_action_id,
        person_action_id
      )
      Values
      (	p_bpl_set(elenum).bnft_prvdd_ldgr_id,
    	p_bpl_set(elenum).effective_start_date,
    	p_bpl_set(elenum).effective_end_date,
    	p_bpl_set(elenum).prtt_ro_of_unusd_amt_flag,
    	p_bpl_set(elenum).frftd_val,
    	p_bpl_set(elenum).prvdd_val,
    	p_bpl_set(elenum).used_val,
    	p_bpl_set(elenum).bnft_prvdr_pool_id,
    	p_bpl_set(elenum).acty_base_rt_id,
    	p_bpl_set(elenum).per_in_ler_id,
    	p_bpl_set(elenum).prtt_enrt_rslt_id,
    	p_bpl_set(elenum).business_group_id,
    	p_bpl_set(elenum).bpl_attribute_category,
    	p_bpl_set(elenum).bpl_attribute1,
    	p_bpl_set(elenum).bpl_attribute2,
    	p_bpl_set(elenum).bpl_attribute3,
    	p_bpl_set(elenum).bpl_attribute4,
    	p_bpl_set(elenum).bpl_attribute5,
    	p_bpl_set(elenum).bpl_attribute6,
    	p_bpl_set(elenum).bpl_attribute7,
    	p_bpl_set(elenum).bpl_attribute8,
    	p_bpl_set(elenum).bpl_attribute9,
    	p_bpl_set(elenum).bpl_attribute10,
    	p_bpl_set(elenum).bpl_attribute11,
    	p_bpl_set(elenum).bpl_attribute12,
    	p_bpl_set(elenum).bpl_attribute13,
    	p_bpl_set(elenum).bpl_attribute14,
    	p_bpl_set(elenum).bpl_attribute15,
    	p_bpl_set(elenum).bpl_attribute16,
    	p_bpl_set(elenum).bpl_attribute17,
    	p_bpl_set(elenum).bpl_attribute18,
    	p_bpl_set(elenum).bpl_attribute19,
    	p_bpl_set(elenum).bpl_attribute20,
    	p_bpl_set(elenum).bpl_attribute21,
    	p_bpl_set(elenum).bpl_attribute22,
    	p_bpl_set(elenum).bpl_attribute23,
    	p_bpl_set(elenum).bpl_attribute24,
    	p_bpl_set(elenum).bpl_attribute25,
    	p_bpl_set(elenum).bpl_attribute26,
    	p_bpl_set(elenum).bpl_attribute27,
    	p_bpl_set(elenum).bpl_attribute28,
    	p_bpl_set(elenum).bpl_attribute29,
    	p_bpl_set(elenum).bpl_attribute30,
    	p_bpl_set(elenum).object_version_number,
    	p_bpl_set(elenum).cash_recd_val,
    	p_bpl_set(elenum).created_by,
        p_bpl_set(elenum).creation_date,
        p_bpl_set(elenum).last_update_date,
        p_bpl_set(elenum).last_updated_by,
        p_bpl_set(elenum).last_update_login,
        p_benefit_action_id,
        p_person_action_id
      );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_bpl_rbvs;
--
PROCEDURE write_cwbmh_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_cwbmh_set         in     t_cwbmh_tab
  )
is
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin
  --
  if p_cwbmh_set.count > 0 then
    --
    for elenum in p_cwbmh_set.first ..p_cwbmh_set.last
    loop
      --
      insert into ben_cwb_mgr_hrchy_rbv
        (mgr_elig_per_elctbl_chc_id
        ,emp_elig_per_elctbl_chc_id
        ,lvl_num
        ,last_update_date
        ,last_updated_by
        ,last_update_login
        ,created_by
        ,creation_date
        ,object_version_number
        ,benefit_action_id
        ,person_action_id
        )
      Values
        (p_cwbmh_set(elenum).mgr_elig_per_elctbl_chc_id
        ,p_cwbmh_set(elenum).emp_elig_per_elctbl_chc_id
        ,p_cwbmh_set(elenum).lvl_num
        ,p_cwbmh_set(elenum).last_update_date
        ,p_cwbmh_set(elenum).last_updated_by
        ,p_cwbmh_set(elenum).last_update_login
        ,p_cwbmh_set(elenum).created_by
        ,p_cwbmh_set(elenum).creation_date
        ,p_cwbmh_set(elenum).object_version_number
        ,p_benefit_action_id
        ,p_person_action_id
        );
      --
    end loop;
    --
  end if;
  --
  commit;
  --
end write_cwbmh_rbvs;
--
PROCEDURE populate_benmngle_rbvs
  (p_benefit_action_id in     number
  ,p_person_action_id  in     number
  ,p_validate_flag     in     varchar2
  )
IS
  --
  l_ppl_set    t_ppl_tab;
  l_pil_set    t_pil_tab;
  l_crp_set    t_crp_tab;
  l_pep_set    t_pep_tab;
  l_epo_set    t_epo_tab;
  l_epe_set    t_epe_tab;
  l_pel_set    t_pel_tab;
  l_ecc_set    t_ecc_tab;
  l_egd_set    t_egd_tab;
  l_pdp_set    t_pdp_tab;
  l_cqb_set    t_cqb_tab;
  l_enb_set    t_enb_tab;
  l_epr_set    t_epr_tab;
  l_ecr_set    t_ecr_tab;
  l_prv_set    t_prv_tab;
  l_pen_set    t_pen_tab;
  l_pcm_set    t_pcm_tab;
  l_bpl_set    t_bpl_tab;
  l_cwbmh_set  t_cwbmh_tab;
  --
  l_elenum     pls_integer;
  --
  l_bft_lud    date;
  l_bft_ludtm  date;
  l_person_id  number;
  --
  l_table_name varchar2(100);
  --
  cursor c_bftdets
    (c_bft_id number
    )
  is
    select bft.person_id,
           bft.created_by,
           bft.creation_date,
           bft.last_update_date,
           bft.last_updated_by,
           bft.last_update_login,
           bft.mode_cd
    from ben_benefit_actions bft
    where bft.benefit_action_id = c_bft_id;
  --
  l_bftdets c_bftdets%rowtype;
  --
  cursor c_pactdets
    (c_pact_id number
    )
  is
    select pact.person_id
    from ben_person_actions pact
    where pact.person_action_id = c_pact_id;
  --
  cursor c_pplrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ppl.*
    from ben_ptnl_ler_for_per ppl
    where ppl.person_id = c_per_id
    and   ppl.last_update_date
      between c_lu_dt and sysdate
    order by ppl.ptnl_ler_for_per_id;
  --
  cursor c_pilrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pil.*
    from ben_per_in_ler pil
    where pil.person_id = c_per_id
    and   pil.last_update_date
      between c_lu_dt and sysdate
    order by pil.per_in_ler_id;
  --
  cursor c_crprbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select crp.*
    from ben_cbr_per_in_ler crp,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   crp.per_in_ler_id = pil.per_in_ler_id
    and   crp.last_update_date
      between c_lu_dt and sysdate
    order by crp.cbr_per_in_ler_id;
  --
  cursor c_peprbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pep.*
    from ben_elig_per_f pep
    where pep.person_id = c_per_id
    and   pep.last_update_date
      between c_lu_dt and sysdate
    order by pep.elig_per_id;
  --
  cursor c_eporbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epo.*
    from ben_elig_per_opt_f epo,
         ben_elig_per_f pep
    where pep.person_id   = c_per_id
    and   pep.elig_per_id = epo.elig_per_id
    and   epo.effective_start_date
      between pep.effective_start_date and pep.effective_end_date
/*
    and   pep.per_in_ler_id = epo.per_in_ler_id
*/
    and   epo.last_update_date
      between c_lu_dt and sysdate
    order by epo.elig_per_opt_id,
             epo.effective_start_date;
  --
  cursor c_epopilrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epo.*
    from ben_elig_per_opt_f epo,
         ben_per_in_ler pil
    where pil.person_id   = c_per_id
    and   pil.per_in_ler_id = epo.per_in_ler_id
    and   epo.last_update_date
      between c_lu_dt and sysdate
    order by epo.elig_per_opt_id,
             epo.effective_start_date;
  --
  cursor c_eperbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epe.*
    from ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.last_update_date
      between c_lu_dt and sysdate
    order by epe.elig_per_elctbl_chc_id;
  --
  cursor c_pelrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pel.*
    from ben_pil_elctbl_chc_popl pel,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   pel.per_in_ler_id = pil.per_in_ler_id
    and   pel.last_update_date
      between c_lu_dt and sysdate
    order by pel.pil_elctbl_chc_popl_id;
  --
/*
  cursor c_eccrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecc.*
    from ben_elctbl_chc_ctfn ecc,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = ecc.ELIG_PER_ELCTBL_CHC_ID
    and   ecc.last_update_date > c_lu_dt
  union
    select ecc.*
    from ben_elctbl_chc_ctfn ecc,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   ecc.enrt_bnft_id  = enb.enrt_bnft_id
    and   ecc.last_update_date > c_lu_dt
  order by 1;
  --
*/
  cursor c_eccrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecc.*
    from ben_elctbl_chc_ctfn ecc,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = ecc.ELIG_PER_ELCTBL_CHC_ID
    and   ecc.last_update_date
      between c_lu_dt and sysdate
    and   pil.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
  cursor c_eccenbrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecc.*
    from ben_elctbl_chc_ctfn ecc,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   ecc.enrt_bnft_id  = enb.enrt_bnft_id
    and   ecc.ELIG_PER_ELCTBL_CHC_ID is null
    and   ecc.last_update_date
      between c_lu_dt and sysdate
    and   pil.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
  cursor c_egdrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select egd.*
    from ben_elig_dpnt egd,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   egd.per_in_ler_id = pil.per_in_ler_id
    and   egd.last_update_date
      between c_lu_dt and sysdate
    order by egd.elig_dpnt_id;
  --
  cursor c_pdprbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pdp.*
    from ben_elig_cvrd_dpnt_f pdp,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   pdp.per_in_ler_id = pil.per_in_ler_id
    and   pdp.last_update_date
      between c_lu_dt and sysdate
    order by pdp.elig_cvrd_dpnt_id;
  --
  cursor c_cqbrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select cqb.*
    from ben_cbr_quald_bnf cqb
    where cqb.cvrd_emp_person_id = c_per_id
    and   cqb.last_update_date
      between c_lu_dt and sysdate
    order by cqb.cbr_quald_bnf_id;
  --
  cursor c_enbrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select enb.*
    from ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   enb.last_update_date
      between c_lu_dt and sysdate
    order by enb.enrt_bnft_id;
  --
/*
  cursor c_eprrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epr.*
    from ben_enrt_prem epr,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = epr.ELIG_PER_ELCTBL_CHC_ID
    and   epr.last_update_date
      between c_lu_dt and sysdate
  union
    select epr.*
    from ben_enrt_prem epr,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   epr.enrt_bnft_id  = enb.enrt_bnft_id
    and   epr.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
*/
  cursor c_epreperbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epr.*
    from ben_enrt_prem epr,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = epr.ELIG_PER_ELCTBL_CHC_ID
    and   epr.last_update_date
      between c_lu_dt and sysdate
    order by 1;
  --
  cursor c_eprenbrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select epr.*
    from ben_enrt_prem epr,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   epr.enrt_bnft_id  = enb.enrt_bnft_id
    and   epr.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
/*
  cursor c_ecrrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecr.*
    from ben_enrt_rt ecr,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = ecr.ELIG_PER_ELCTBL_CHC_ID
    and   ecr.last_update_date
      between c_lu_dt and sysdate
  union
    select ecr.*
    from ben_enrt_rt ecr,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   ecr.enrt_bnft_id  = enb.enrt_bnft_id
    and   ecr.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
*/
  cursor c_ecreperbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecr.*
    from ben_enrt_rt ecr,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   ecr.enrt_bnft_id is null
    and   epe.ELIG_PER_ELCTBL_CHC_ID = ecr.ELIG_PER_ELCTBL_CHC_ID
    and   ecr.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
  cursor c_ecrenbrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select ecr.*
    from ben_enrt_rt ecr,
         ben_enrt_bnft enb,
         ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.ELIG_PER_ELCTBL_CHC_ID = enb.ELIG_PER_ELCTBL_CHC_ID
    and   ecr.ELIG_PER_ELCTBL_CHC_ID is null
    and   ecr.enrt_bnft_id  = enb.enrt_bnft_id
    and   ecr.last_update_date
      between c_lu_dt and sysdate
  order by 1;
  --
  cursor c_prvrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select prv.*
    from ben_prtt_rt_val prv,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   prv.per_in_ler_id = pil.per_in_ler_id
    and   prv.last_update_date
      between c_lu_dt and sysdate
    order by prv.prtt_rt_val_id;
  --
  cursor c_penrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pen.*
    from ben_prtt_enrt_rslt_f pen
    where pen.person_id = c_per_id
    and   pen.last_update_date
      between c_lu_dt and sysdate
    order by pen.prtt_enrt_rslt_id;
  --
  cursor c_pcmrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select pcm.*
    from ben_per_cm_f pcm
    where pcm.person_id = c_per_id
    and   pcm.last_update_date
      between c_lu_dt and sysdate
    order by pcm.per_cm_id;
  --
  cursor c_bplrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select bpl.*
    from ben_bnft_prvdd_ldgr_f bpl,
         ben_per_in_ler pil
    where pil.person_id     = c_per_id
    and   bpl.per_in_ler_id = pil.per_in_ler_id
    and   bpl.last_update_date
      between c_lu_dt and sysdate
    order by bpl.bnft_prvdd_ldgr_id;
  --
  cursor c_cwbmhrbv
    (c_per_id number
    ,c_lu_dt  date
    )
  is
    select cwbmh.*
    from ben_elig_per_elctbl_chc epe,
         ben_per_in_ler pil,
         ben_cwb_mgr_hrchy cwbmh
    where pil.person_id     = c_per_id
    and   epe.per_in_ler_id = pil.per_in_ler_id
    and   epe.elig_per_elctbl_chc_id = cwbmh.emp_elig_per_elctbl_chc_id
    and   cwbmh.last_update_date
      between c_lu_dt and sysdate
    order by cwbmh.mgr_elig_per_elctbl_chc_id,
             emp_elig_per_elctbl_chc_id;
  --
  l_epo_cnt number;
  --
BEGIN
  --
  l_table_name := null;
  --
  if p_validate_flag in ('C','B')
  then
    --
    -- Get the benefit action details
    --
    open c_bftdets
      (c_bft_id => p_benefit_action_id
      );
    fetch c_bftdets into l_bftdets;
    close c_bftdets;
    --
    l_bft_lud   := trunc(l_bftdets.last_update_date);
    l_bft_ludtm := l_bftdets.last_update_date;
    l_person_id := l_bftdets.person_id;
    --
    -- When person id is null then running batch benmngle
    --
    if l_person_id is null
    then
      --
      -- Get the person id from the person action
      --
      open c_pactdets
        (c_pact_id => p_person_action_id
        );
      fetch c_pactdets into l_person_id;
      close c_pactdets;
      --
    end if;
    --
    if l_person_id is not null
    then
      --
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_person_id: '||l_person_id);
/*
        dbms_output.put_line(' BENRBVPO: l_person_id: '||l_person_id
                            ||' l_bft_ludtm: '||to_char(l_bft_ludtm,'DD-MON-YYYY-HH24-MI-SS')
                            );
        --
*/
      l_table_name := 'BEN_PTNL_LER_FOR_PER_RBV';
      l_elenum := 0;
      --
      for row in c_pplrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ppl_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_ppl_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_ppl_set           => l_ppl_set
        );
      --
      l_table_name := 'BEN_PER_IN_LER_RBV';
      l_elenum := 0;
      --
      for row in c_pilrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pil_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_pil_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pil_set           => l_pil_set
        );
      --
      l_table_name := 'BEN_CBR_PER_IN_LER_RBV';
      l_elenum := 0;
      --
      for row in c_crprbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_crp_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_crp_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_crp_set           => l_crp_set
        );
      --
      l_table_name := 'BEN_ELIG_PER_F_RBV';
      l_elenum := 0;
      --
      for row in c_peprbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pep_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_pep_set.count: '||l_pep_set.count);
        --
*/
      write_pep_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pep_set           => l_pep_set
        );
      --
      l_table_name := 'BEN_ELIG_PER_OPT_F_RBV';
      l_elenum := 0;
      --
      if l_bftdets.mode_cd = 'S'
      then
        --
        for row in c_eporbv
          (c_per_id => l_person_id
          ,c_lu_dt  => l_bft_lud
          )
        loop
          --
          if row.last_update_date >= l_bft_ludtm
          then
            --
            l_epo_set(l_elenum) := row;
            --
            l_elenum := l_elenum+1;
            --
          end if;
          --
        end loop;
        --
      else
        --
        for row in c_epopilrbv
          (c_per_id => l_person_id
          ,c_lu_dt  => l_bft_lud
          )
        loop
          --
          if row.last_update_date >= l_bft_ludtm
          then
            --
            l_epo_set(l_elenum) := row;
            --
            l_elenum := l_elenum+1;
            --
          end if;
          --
        end loop;
        --
      end if;
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_epo_set.count: '||l_epo_set.count);
        --
*/
      write_epo_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_epo_set           => l_epo_set
        );
      --
      -- Electability
      --
      l_table_name := 'BEN_ELIG_PER_ELCTBL_CHC_RBV';
      l_elenum := 0;
      --
      for row in c_eperbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_epe_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_epe_set.count: '||l_epe_set.count);
        --
*/
      write_epe_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_epe_set           => l_epe_set
        );
      --
      l_table_name := 'BEN_PIL_EPE_POPL_RBV';
      l_elenum := 0;
      --
      for row in c_pelrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pel_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_pel_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pel_set           => l_pel_set
        );
      --
      l_table_name := 'BEN_ELCTBL_CHC_CTFN_RBV';
      l_elenum := 0;
      --
      for row in c_eccrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ecc_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_ecc_set.count 1: '||l_ecc_set.count);
        --
*/
      --
      for row in c_eccenbrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ecc_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_ecc_set.count 2: '||l_ecc_set.count);
        --
*/
      --
      write_ecc_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_ecc_set           => l_ecc_set
        );
      --
      -- Dependent eligibility
      --
      l_table_name := 'BEN_ELIG_DPNT_RBV';
      l_elenum := 0;
      --
      for row in c_egdrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_egd_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_egd_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_egd_set           => l_egd_set
        );
      --
      l_table_name := 'BEN_ELIG_CVRD_DPNT_RBV';
      l_elenum := 0;
      --
      for row in c_pdprbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pdp_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
          --
      end loop;
      --
      write_pdp_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pdp_set           => l_pdp_set
        );
      --
      l_table_name := 'BEN_CBR_QUALD_BNF_RBV';
      l_elenum := 0;
      --
      for row in c_cqbrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_cqb_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
          --
      end loop;
      --
      write_cqb_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_cqb_set           => l_cqb_set
        );
      --
      -- Coverage
      --
      l_table_name := 'BEN_ENRT_BNFT_RBV';
      l_elenum := 0;
      --
      for row in c_enbrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_enb_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_enb_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_enb_set           => l_enb_set
        );
      --
      -- Premiums
      --
      l_table_name := 'BEN_ENRT_PREM_RBV';
      l_elenum := 0;
      --
      for row in c_epreperbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_epr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      for row in c_eprenbrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_epr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
/*
      for row in c_eprrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_epr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
*/
      write_epr_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_epr_set           => l_epr_set
        );
      --
      -- Rates
      --
      l_table_name := 'BEN_ENRT_RT_RBV';
      l_elenum := 0;
      --
      for row in c_ecreperbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ecr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      for row in c_ecrenbrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ecr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
/*
      for row in c_ecrrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_ecr_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
*/
      write_ecr_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_ecr_set           => l_ecr_set
        );
      --
      -- Participant rate values
      --
      l_table_name := 'BEN_PRTT_RT_VAL_RBV';
      l_elenum := 0;
      --
      for row in c_prvrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_prv_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
/*
        --
        -- Temporary
        --
        benutils.write(p_text => ' l_prv_set.count: '||l_prv_set.count);
        --
*/
      write_prv_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_prv_set           => l_prv_set
        );
      --
      -- Enrolment results
      --
      l_table_name := 'BEN_PRTT_ENRT_RSLT_F_RBV';
      l_elenum := 0;
      --
      for row in c_penrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pen_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_pen_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pen_set           => l_pen_set
        );
      --
      -- Communications
      --
      l_table_name := 'BEN_PER_CM_F_RBV';
      l_elenum := 0;
      --
      for row in c_pcmrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_pcm_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_pcm_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_pcm_set           => l_pcm_set
        );
      --
      -- Benefit provider ledgers
      --
      l_table_name := 'BEN_BNFT_PRVDD_LDGR_RBV';
      l_elenum := 0;
      --
      for row in c_bplrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_bpl_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_bpl_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_bpl_set           => l_bpl_set
        );
      --
      l_table_name := 'BEN_CWB_MGR_HRCHY_RBV';
      l_elenum := 0;
      --
      for row in c_cwbmhrbv
        (c_per_id => l_person_id
        ,c_lu_dt  => l_bft_lud
        )
      loop
        --
        if row.last_update_date >= l_bft_ludtm
        then
          --
          l_cwbmh_set(l_elenum) := row;
          --
          l_elenum := l_elenum+1;
          --
        end if;
        --
      end loop;
      --
      write_cwbmh_rbvs
        (p_benefit_action_id => p_benefit_action_id
        ,p_person_action_id  => p_person_action_id
        ,p_cwbmh_set         => l_cwbmh_set
        );
      --
    end if;
    --
  end if;
  --
exception
  when others then
    --
    raise;
    --
/*
    fnd_message.set_name('BEN','BEN_?????_POPRBV');
    benutils.write(fnd_message.get);
    fnd_message.raise_error;
*/
    --
END populate_benmngle_rbvs;
--
function validate_mode
  (p_validate in varchar2
  ) return boolean
Is

begin
  --
  if p_validate in ('Y','C','B')
  then
    --
    return TRUE;
    --
  end if;
  --
  return false;
  --
End validate_mode;
--
end ben_populate_rbv;

/
