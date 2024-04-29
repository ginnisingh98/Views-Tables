--------------------------------------------------------
--  DDL for Package BEN_ICM_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ICM_LIFE_EVENTS" AUTHID CURRENT_USER AS
/* $Header: benicmle.pkh 120.2 2007/04/09 10:41:49 rtagarra noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|        Copyright (c) 1997 Oracle Corporation            |
|           Redwood Shores, California, USA                |
|                All rights reserved.                   |
+==============================================================================+
Name:
    Determine Rates.

Purpose:
    This process determines rates for either elctable choices or coverages, and
    writes them to the ben_enrt_rt table.  This process can only run in benmngle.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        10-Feb-07       rtagarra    120.0      Created.
	28-Feb-07       rtagarra    120.1      GSCC Error.
*/
--------------------------------------------------------------------------------
--
   TYPE g_cache_pep_objects_rec IS RECORD (
      elig_per_id                    ben_elig_per_f.elig_per_id%TYPE,
      effective_start_date           ben_elig_per_f.effective_start_date%TYPE,
      effective_end_date             ben_elig_per_f.effective_end_date%TYPE,
      business_group_id              ben_elig_per_f.business_group_id%TYPE,
      pl_id                          ben_elig_per_f.pl_id%TYPE,
      plip_id                        ben_elig_per_f.plip_id%TYPE,
      ptip_id                        ben_elig_per_f.ptip_id%TYPE,
      pgm_id                         ben_elig_per_f.pgm_id%TYPE,
      ler_id                         ben_elig_per_f.ler_id%TYPE,
      person_id                      ben_elig_per_f.person_id%TYPE,
      per_in_ler_id                  ben_elig_per_f.per_in_ler_id%TYPE,
      dpnt_othr_pl_cvrd_rl_flag      ben_elig_per_f.dpnt_othr_pl_cvrd_rl_flag%TYPE,
      pl_key_ee_flag                 ben_elig_per_f.pl_key_ee_flag%TYPE,
      pl_hghly_compd_flag            ben_elig_per_f.pl_hghly_compd_flag%TYPE,
      prtn_ovridn_flag               ben_elig_per_f.prtn_ovridn_flag%TYPE,
      prtn_ovridn_thru_dt            ben_elig_per_f.prtn_ovridn_thru_dt%TYPE,
      no_mx_prtn_ovrid_thru_flag     ben_elig_per_f.no_mx_prtn_ovrid_thru_flag%TYPE,
      prtn_strt_dt                   ben_elig_per_f.prtn_strt_dt%TYPE,
      dstr_rstcn_flag                ben_elig_per_f.dstr_rstcn_flag%TYPE,
      pl_wvd_flag                    ben_elig_per_f.pl_wvd_flag%TYPE,
      wait_perd_cmpltn_dt            ben_elig_per_f.wait_perd_cmpltn_dt%TYPE,
      wait_perd_strt_dt              ben_elig_per_f.wait_perd_strt_dt%TYPE,
      elig_flag                      ben_elig_per_f.elig_flag%TYPE,
      comp_ref_amt                   ben_elig_per_f.comp_ref_amt%TYPE,
      cmbn_age_n_los_val             ben_elig_per_f.cmbn_age_n_los_val%TYPE,
      comp_ref_uom                   ben_elig_per_f.comp_ref_uom%TYPE,
      age_val                        ben_elig_per_f.age_val%TYPE,
      age_uom                        ben_elig_per_f.age_uom%TYPE,
      los_val                        ben_elig_per_f.los_val%TYPE,
      los_uom                        ben_elig_per_f.los_uom%TYPE,
      hrs_wkd_val                    ben_elig_per_f.hrs_wkd_val%TYPE,
      hrs_wkd_bndry_perd_cd          ben_elig_per_f.hrs_wkd_bndry_perd_cd%TYPE,
      pct_fl_tm_val                  ben_elig_per_f.pct_fl_tm_val%TYPE,
      frz_los_flag                   ben_elig_per_f.frz_los_flag%TYPE,
      frz_age_flag                   ben_elig_per_f.frz_age_flag%TYPE,
      frz_cmp_lvl_flag               ben_elig_per_f.frz_cmp_lvl_flag%TYPE,
      frz_pct_fl_tm_flag             ben_elig_per_f.frz_pct_fl_tm_flag%TYPE,
      frz_hrs_wkd_flag               ben_elig_per_f.frz_hrs_wkd_flag%TYPE,
      frz_comb_age_and_los_flag      ben_elig_per_f.frz_comb_age_and_los_flag%TYPE,
      rt_comp_ref_amt                ben_elig_per_f.rt_comp_ref_amt%TYPE,
      rt_cmbn_age_n_los_val          ben_elig_per_f.rt_cmbn_age_n_los_val%TYPE,
      rt_comp_ref_uom                ben_elig_per_f.rt_comp_ref_uom%TYPE,
      rt_age_val                     ben_elig_per_f.rt_age_val%TYPE,
      rt_age_uom                     ben_elig_per_f.rt_age_uom%TYPE,
      rt_los_val                     ben_elig_per_f.rt_los_val%TYPE,
      rt_los_uom                     ben_elig_per_f.rt_los_uom%TYPE,
      rt_hrs_wkd_val                 ben_elig_per_f.rt_hrs_wkd_val%TYPE,
      rt_hrs_wkd_bndry_perd_cd       ben_elig_per_f.rt_hrs_wkd_bndry_perd_cd%TYPE,
      rt_pct_fl_tm_val               ben_elig_per_f.rt_pct_fl_tm_val%TYPE,
      rt_frz_los_flag                ben_elig_per_f.rt_frz_los_flag%TYPE,
      rt_frz_age_flag                ben_elig_per_f.rt_frz_age_flag%TYPE,
      rt_frz_cmp_lvl_flag            ben_elig_per_f.rt_frz_cmp_lvl_flag%TYPE,
      rt_frz_pct_fl_tm_flag          ben_elig_per_f.rt_frz_pct_fl_tm_flag%TYPE,
      rt_frz_hrs_wkd_flag            ben_elig_per_f.rt_frz_hrs_wkd_flag%TYPE,
      rt_frz_comb_age_and_los_flag   ben_elig_per_f.rt_frz_comb_age_and_los_flag%TYPE,
      once_r_cntug_cd                ben_elig_per_f.once_r_cntug_cd%TYPE,
      pl_ordr_num                    ben_elig_per_f.pl_ordr_num%TYPE,
      plip_ordr_num                  ben_elig_per_f.plip_ordr_num%TYPE,
      ptip_ordr_num                  ben_elig_per_f.ptip_ordr_num%TYPE,
      object_version_number          ben_elig_per_f.object_version_number%TYPE,
      p_effective_date               DATE,
      program_application_id         ben_elig_per_f.program_application_id%TYPE,
      prtn_end_dt                    ben_elig_per_f.prtn_end_dt%TYPE,
      program_id                     ben_elig_per_f.program_id%TYPE,
      request_id                     ben_elig_per_f.request_id%TYPE,
      program_update_date            ben_elig_per_f.program_update_date%TYPE,
      p_datetrack_mode               VARCHAR2 (100),
      p_newly_elig                   BOOLEAN,
      p_newly_inelig                 BOOLEAN,
      p_first_elig                   BOOLEAN,
      p_first_inelig                 BOOLEAN,
      p_still_elig                   BOOLEAN,
      p_still_inelig                 BOOLEAN
   );

   TYPE g_cache_pep_objects_rec_tab IS TABLE OF g_cache_pep_objects_rec
      INDEX BY BINARY_INTEGER;

   g_cache_pep_object   g_cache_pep_objects_rec_tab;

--
   TYPE g_cache_epo_objects_rec IS RECORD (
      elig_per_id                    ben_elig_per_opt_f.elig_per_id%TYPE,
      elig_per_opt_id                ben_elig_per_opt_f.elig_per_opt_id%TYPE,
      effective_start_date           ben_elig_per_opt_f.effective_start_date%TYPE,
      effective_end_date             ben_elig_per_opt_f.effective_end_date%TYPE,
      business_group_id              ben_elig_per_opt_f.business_group_id%TYPE,
      opt_id                         ben_elig_per_opt_f.opt_id%TYPE,
      per_in_ler_id                  ben_elig_per_opt_f.per_in_ler_id%TYPE,
      wait_perd_cmpltn_date          ben_elig_per_opt_f.wait_perd_cmpltn_date%TYPE,
      wait_perd_strt_dt              ben_elig_per_opt_f.wait_perd_strt_dt%TYPE,
      prtn_ovridn_flag               ben_elig_per_opt_f.prtn_ovridn_flag%TYPE,
      oipl_ordr_num                  ben_elig_per_opt_f.oipl_ordr_num%TYPE,
      prtn_ovridn_thru_dt            ben_elig_per_opt_f.prtn_ovridn_thru_dt%TYPE,
      no_mx_prtn_ovrid_thru_flag     ben_elig_per_opt_f.no_mx_prtn_ovrid_thru_flag%TYPE,
      prtn_strt_dt                   ben_elig_per_opt_f.prtn_strt_dt%TYPE,
      prtn_end_dt                    ben_elig_per_opt_f.prtn_end_dt%TYPE,
      wait_perd_cmpltn_dt            ben_elig_per_opt_f.wait_perd_cmpltn_dt%TYPE,
      elig_flag                      ben_elig_per_opt_f.elig_flag%TYPE,
      comp_ref_amt                   ben_elig_per_opt_f.comp_ref_amt%TYPE,
      cmbn_age_n_los_val             ben_elig_per_opt_f.cmbn_age_n_los_val%TYPE,
      comp_ref_uom                   ben_elig_per_opt_f.comp_ref_uom%TYPE,
      age_val                        ben_elig_per_opt_f.age_val%TYPE,
      age_uom                        ben_elig_per_opt_f.age_uom%TYPE,
      los_val                        ben_elig_per_opt_f.los_val%TYPE,
      los_uom                        ben_elig_per_opt_f.los_uom%TYPE,
      hrs_wkd_val                    ben_elig_per_opt_f.hrs_wkd_val%TYPE,
      hrs_wkd_bndry_perd_cd          ben_elig_per_opt_f.hrs_wkd_bndry_perd_cd%TYPE,
      pct_fl_tm_val                  ben_elig_per_opt_f.pct_fl_tm_val%TYPE,
      frz_los_flag                   ben_elig_per_opt_f.frz_los_flag%TYPE,
      frz_age_flag                   ben_elig_per_opt_f.frz_age_flag%TYPE,
      frz_cmp_lvl_flag               ben_elig_per_opt_f.frz_cmp_lvl_flag%TYPE,
      frz_pct_fl_tm_flag             ben_elig_per_opt_f.frz_pct_fl_tm_flag%TYPE,
      frz_hrs_wkd_flag               ben_elig_per_opt_f.frz_hrs_wkd_flag%TYPE,
      frz_comb_age_and_los_flag      ben_elig_per_opt_f.frz_comb_age_and_los_flag%TYPE,
      rt_comp_ref_amt                ben_elig_per_opt_f.rt_comp_ref_amt%TYPE,
      rt_cmbn_age_n_los_val          ben_elig_per_opt_f.rt_cmbn_age_n_los_val%TYPE,
      rt_comp_ref_uom                ben_elig_per_opt_f.rt_comp_ref_uom%TYPE,
      rt_age_val                     ben_elig_per_opt_f.rt_age_val%TYPE,
      rt_age_uom                     ben_elig_per_opt_f.rt_age_uom%TYPE,
      rt_los_val                     ben_elig_per_opt_f.rt_los_val%TYPE,
      rt_los_uom                     ben_elig_per_opt_f.rt_los_uom%TYPE,
      rt_hrs_wkd_val                 ben_elig_per_opt_f.rt_hrs_wkd_val%TYPE,
      rt_hrs_wkd_bndry_perd_cd       ben_elig_per_opt_f.rt_hrs_wkd_bndry_perd_cd%TYPE,
      rt_pct_fl_tm_val               ben_elig_per_opt_f.rt_pct_fl_tm_val%TYPE,
      rt_frz_los_flag                ben_elig_per_opt_f.rt_frz_los_flag%TYPE,
      rt_frz_age_flag                ben_elig_per_opt_f.rt_frz_age_flag%TYPE,
      rt_frz_cmp_lvl_flag            ben_elig_per_opt_f.rt_frz_cmp_lvl_flag%TYPE,
      rt_frz_pct_fl_tm_flag          ben_elig_per_opt_f.rt_frz_pct_fl_tm_flag%TYPE,
      rt_frz_hrs_wkd_flag            ben_elig_per_opt_f.rt_frz_hrs_wkd_flag%TYPE,
      rt_frz_comb_age_and_los_flag   ben_elig_per_opt_f.rt_frz_comb_age_and_los_flag%TYPE,
      once_r_cntug_cd                ben_elig_per_opt_f.once_r_cntug_cd%TYPE,
      object_version_number          ben_elig_per_opt_f.object_version_number%TYPE,
      p_effective_date               DATE,
      p_datetrack_mode               VARCHAR2 (100),
      program_application_id         ben_elig_per_opt_f.program_application_id%TYPE,
      program_id                     ben_elig_per_opt_f.program_id%TYPE,
      request_id                     ben_elig_per_opt_f.request_id%TYPE,
      program_update_date            ben_elig_per_opt_f.program_update_date%TYPE,
      inelg_rsn_cd                   ben_elig_per_opt_f.inelg_rsn_cd%TYPE,
      p_newly_elig                   BOOLEAN,
      p_newly_inelig                 BOOLEAN,
      p_first_elig                   BOOLEAN,
      p_first_inelig                 BOOLEAN,
      p_still_elig                   BOOLEAN,
      p_still_inelig                 BOOLEAN,
      p_pl_id                        NUMBER
   );

--
   TYPE g_cache_epo_objects_rec_tab IS TABLE OF g_cache_epo_objects_rec
      INDEX BY BINARY_INTEGER;

   g_cache_epo_object   g_cache_epo_objects_rec_tab;

--
   TYPE icd_chc_rates_rec IS RECORD (
      icd_chc_rate_id              NUMBER,
      person_id                    NUMBER,
      business_group_id            NUMBER,
      effective_date               DATE,
      acty_base_rt_id              NUMBER,
      pl_id                        NUMBER,
      pl_typ_id                    NUMBER,
      oipl_id                      NUMBER,
      opt_id                       NUMBER,
      pl_ordr_num                  NUMBER,
      oipl_ordr_num                NUMBER,
      nnmntry_uom                  VARCHAR (100),
      rt_strt_dt_cd                VARCHAR (100),
      rt_strt_dt                   DATE,
      rt_strt_dt_rl                NUMBER,
      rt_end_dt_cd                 VARCHAR (100),
      rt_end_dt                    DATE,
      rt_end_dt_rl                 NUMBER,
      bnf_rqd_yn                   VARCHAR (100),
      input_value_id1              NUMBER,
      input_value1               VARCHAR (100),
      input_value_id2              NUMBER,
      input_value2               VARCHAR (100),
      input_value_id3              NUMBER,
      input_value3               VARCHAR (100),
      input_value_id4              NUMBER,
      input_value4               VARCHAR (100),
      input_value_id5              NUMBER,
      input_value5               VARCHAR (100),
      input_value_id6              NUMBER,
      input_value6               VARCHAR (100),
      input_value_id7              NUMBER,
      input_value7               VARCHAR (100),
      input_value_id8              NUMBER,
      input_value8               VARCHAR (100),
      input_value_id9              NUMBER,
      input_value9               VARCHAR (100),
      input_value_id10             NUMBER,
      input_value10              VARCHAR (100),
      input_value_id11             NUMBER,
      input_value11              VARCHAR (100),
      input_value_id12             NUMBER,
      input_value12              VARCHAR (100),
      input_value_id13             NUMBER,
      input_value13              VARCHAR (100),
      input_value_id14             NUMBER,
      input_value14              VARCHAR (100),
      input_value_id15             NUMBER,
      input_value15              VARCHAR (100),
      element_type_id              NUMBER,
      element_link_id              NUMBER,
      object_version_number        NUMBER,
      last_update_date             DATE,
      last_updated_by              NUMBER,
      creation_date                DATE,
      created_by                   NUMBER,
      cost_allocation_keyflex_id   NUMBER,
      l_assignment_id              per_all_assignments_f.assignment_id%TYPE,
      l_level                      varchar2(30)
   );

--
   TYPE icd_chc_rates_tab IS TABLE OF icd_chc_rates_rec
      INDEX BY BINARY_INTEGER;

--
   PROCEDURE p_manage_icm_life_events (
      p_person_id           IN   NUMBER,
      p_effective_date      IN   DATE,
      p_business_group_id   IN   NUMBER,
      p_lf_evt_ocrd_dt      IN   DATE DEFAULT NULL
   );
--
END ben_icm_life_events;

/
