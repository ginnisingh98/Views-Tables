--------------------------------------------------------
--  DDL for Package BEN_DERIVE_PART_AND_RATE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVE_PART_AND_RATE_CACHE" AUTHID CURRENT_USER as
/* $Header: bendrpac.pkh 120.0 2005/05/28 04:12:26 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Derive Participation and Rate Caching Routine
Purpose
	This package is used to return or retrieve information that is
        needed for rates and or factors.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        23 Nov 98        G Perry    115.0      Created.
        20 Dec 98        G Perry    115.1      Support for hours worked.
        17 Feb 99        G Perry    115.2      Changed cache strucutre for
                                               hours worked so we can store
                                               the once_r_cntug_cd.
        04 May 99        G Perry    115.3      Added cache support for
                                               PLIP and PTIP.
        06 May 99        G Perry    115.4      Backport for Fidelity
        06 May 99        G Perry    115.5      Leapfrog from 115.3
        04 Aug 99        T Guy      115.6      added age_to_use_cd to
                                               g_cache_age_rec_obj
        23 Aug 99        G Perry    115.7      Added nocopy compiler directive.
        10 Jan 00        pbodla     115.8      Added los_calc_rl to
                                                     g_cache_los_rec_obj
        24 Jan 00        lmcdonal   115.9      Add hrs_wkd_calc_rl to hwf and
                                               comp_calc_rl to clf. Bugs
                                               1118118, 1118113.
        07 Mar 00        gperry     115.10     Fixed for WWBUG 1195803.
        31 Mar 00        gperry     115.11     Added oiplip support.
        26 Jun 00        gperry     115.12     Added age_calc_rl support.
        08 Oct 02        kmahendr   115.13     Added parameters to get_los_elig
        08 Oct 02        kmahendr   115.14     Added dbdrv command
        18 Oct 02        kmahendr   115.15     Added parameters to get_age_elig, get_comp_elig
                                               get_pct_elig, get_hours_elig, get_comb_elig
        22 Oct 02        ikasire    115.16     Bug 2502763 added parameters to clf routine
*/
--------------------------------------------------------------------------------
--
-- Cache all derivable factor stuff for any particular plan or program or
-- oipl.
--
type g_cache_los_rec_obj is record
(id                     number,
 exist                  varchar2(1),
 los_det_cd             ben_los_fctr.los_det_cd%type,
 los_dt_to_use_cd       ben_los_fctr.los_dt_to_use_cd%type,
 use_overid_svc_dt_flag ben_los_fctr.use_overid_svc_dt_flag%type,
 los_uom                ben_los_fctr.los_uom%type,
 los_det_rl             ben_los_fctr.los_det_rl%type,
 los_dt_to_use_rl       ben_los_fctr.los_dt_to_use_rl%type,
 los_calc_rl            ben_los_fctr.los_calc_rl%type,
 rndg_cd                ben_los_fctr.rndg_cd%type,
 rndg_rl                ben_los_fctr.rndg_rl%type,
 mn_los_num             ben_los_fctr.mn_los_num%type,
 mx_los_num             ben_los_fctr.mx_los_num%type);
--
type g_cache_los_rec_table is table of g_cache_los_rec_obj index
  by binary_integer;
--
g_cache_pl_los_el_rec     g_cache_los_rec_table;
g_cache_oipl_los_el_rec   g_cache_los_rec_table;
g_cache_pgm_los_el_rec    g_cache_los_rec_table;
g_cache_plip_los_el_rec   g_cache_los_rec_table;
g_cache_ptip_los_el_rec   g_cache_los_rec_table;
g_cache_pl_los_rt_rec     g_cache_los_rec_table;
g_cache_oipl_los_rt_rec   g_cache_los_rec_table;
g_cache_pgm_los_rt_rec    g_cache_los_rec_table;
g_cache_plip_los_rt_rec   g_cache_los_rec_table;
g_cache_ptip_los_rt_rec   g_cache_los_rec_table;
g_cache_oiplip_los_rt_rec g_cache_los_rec_table;
g_cache_stated_los_rec    g_cache_los_rec_table;
--
type g_cache_age_rec_obj is record
(id                    number,
 exist                 varchar2(1),
 age_det_cd            ben_age_fctr.age_det_cd%type,
 age_to_use_cd         ben_age_fctr.age_to_use_cd%type,
 age_uom               ben_age_fctr.age_uom%type,
 age_det_rl            ben_age_fctr.age_det_rl%type,
 rndg_cd               ben_age_fctr.rndg_cd%type,
 rndg_rl               ben_age_fctr.rndg_rl%type,
 age_calc_rl           ben_age_fctr.age_calc_rl%type,
 mn_age_num            ben_age_fctr.mn_age_num%type,
 mx_age_num            ben_age_fctr.mx_age_num%type);
--
type g_cache_age_rec_table is table of g_cache_age_rec_obj index
  by binary_integer;
--
g_cache_pl_age_el_rec     g_cache_age_rec_table;
g_cache_oipl_age_el_rec   g_cache_age_rec_table;
g_cache_pgm_age_el_rec    g_cache_age_rec_table;
g_cache_plip_age_el_rec   g_cache_age_rec_table;
g_cache_ptip_age_el_rec   g_cache_age_rec_table;
g_cache_pl_age_rt_rec     g_cache_age_rec_table;
g_cache_oipl_age_rt_rec   g_cache_age_rec_table;
g_cache_pgm_age_rt_rec    g_cache_age_rec_table;
g_cache_plip_age_rt_rec   g_cache_age_rec_table;
g_cache_ptip_age_rt_rec   g_cache_age_rec_table;
g_cache_oiplip_age_rt_rec g_cache_age_rec_table;
g_cache_stated_age_rec    g_cache_age_rec_table;
--
type g_cache_clf_rec_obj is record
(id                    number,
 exist                 varchar2(1),
 comp_lvl_uom          ben_comp_lvl_fctr.comp_lvl_uom%type,
 comp_src_cd           ben_comp_lvl_fctr.comp_src_cd%type,
 comp_lvl_det_cd       ben_comp_lvl_fctr.comp_lvl_det_cd%type,
 comp_lvl_det_rl       ben_comp_lvl_fctr.comp_lvl_det_rl%type,
 rndg_cd               ben_comp_lvl_fctr.rndg_cd%type,
 rndg_rl               ben_comp_lvl_fctr.rndg_rl%type,
 mn_comp_val           ben_comp_lvl_fctr.mn_comp_val%type,
 mx_comp_val           ben_comp_lvl_fctr.mx_comp_val%type,
 bnfts_bal_id          ben_comp_lvl_fctr.bnfts_bal_id%type,
 defined_balance_id    ben_comp_lvl_fctr.defined_balance_id%type,
 sttd_sal_prdcty_cd    ben_comp_lvl_fctr.sttd_sal_prdcty_cd%type,
 comp_lvl_fctr_id      ben_comp_lvl_fctr.comp_lvl_fctr_id%type,
 comp_calc_rl          ben_comp_lvl_fctr.comp_calc_rl%type);
--
type g_cache_clf_rec_table is table of g_cache_clf_rec_obj index
  by binary_integer;
--
g_cache_pl_clf_el_rec     g_cache_clf_rec_table;
g_cache_oipl_clf_el_rec   g_cache_clf_rec_table;
g_cache_pgm_clf_el_rec    g_cache_clf_rec_table;
g_cache_plip_clf_el_rec   g_cache_clf_rec_table;
g_cache_ptip_clf_el_rec   g_cache_clf_rec_table;
g_cache_pl_clf_rt_rec     g_cache_clf_rec_table;
g_cache_oipl_clf_rt_rec   g_cache_clf_rec_table;
g_cache_pgm_clf_rt_rec    g_cache_clf_rec_table;
g_cache_plip_clf_rt_rec   g_cache_clf_rec_table;
g_cache_ptip_clf_rt_rec   g_cache_clf_rec_table;
g_cache_oiplip_clf_rt_rec g_cache_clf_rec_table;
--
type g_cache_cla_rec_obj is record
(id                    number,
 exist                 varchar2(1),
 los_fctr_id           ben_cmbn_age_los_fctr.los_fctr_id%type,
 age_fctr_id           ben_cmbn_age_los_fctr.age_fctr_id%type,
 cmbnd_min_val         ben_cmbn_age_los_fctr.cmbnd_min_val%type,
 cmbnd_max_val         ben_cmbn_age_los_fctr.cmbnd_max_val%type);
--
type g_cache_cla_rec_table is table of g_cache_cla_rec_obj index
  by binary_integer;
--
g_cache_pl_cla_el_rec     g_cache_cla_rec_table;
g_cache_oipl_cla_el_rec   g_cache_cla_rec_table;
g_cache_pgm_cla_el_rec    g_cache_cla_rec_table;
g_cache_plip_cla_el_rec   g_cache_cla_rec_table;
g_cache_ptip_cla_el_rec   g_cache_cla_rec_table;
g_cache_pl_cla_rt_rec     g_cache_cla_rec_table;
g_cache_oipl_cla_rt_rec   g_cache_cla_rec_table;
g_cache_pgm_cla_rt_rec    g_cache_cla_rec_table;
g_cache_plip_cla_rt_rec   g_cache_cla_rec_table;
g_cache_ptip_cla_rt_rec   g_cache_cla_rec_table;
g_cache_oiplip_cla_rt_rec g_cache_cla_rec_table;
--
type g_cache_pff_rec_obj is record
(id                        number,
 exist                     varchar2(1),
 use_prmry_asnt_only_flag  ben_pct_fl_tm_fctr.use_prmry_asnt_only_flag%type,
 use_sum_of_all_asnts_flag ben_pct_fl_tm_fctr.use_sum_of_all_asnts_flag%type,
 rndg_cd                   ben_pct_fl_tm_fctr.rndg_cd%type,
 rndg_rl                   ben_pct_fl_tm_fctr.rndg_rl%type,
 mn_pct_val                ben_pct_fl_tm_fctr.mn_pct_val%type,
 mx_pct_val                ben_pct_fl_tm_fctr.mx_pct_val%type);
--
type g_cache_pff_rec_table is table of g_cache_pff_rec_obj index
  by binary_integer;
--
g_cache_pl_pff_el_rec     g_cache_pff_rec_table;
g_cache_oipl_pff_el_rec   g_cache_pff_rec_table;
g_cache_pgm_pff_el_rec    g_cache_pff_rec_table;
g_cache_plip_pff_el_rec   g_cache_pff_rec_table;
g_cache_ptip_pff_el_rec   g_cache_pff_rec_table;
g_cache_pl_pff_rt_rec     g_cache_pff_rec_table;
g_cache_oipl_pff_rt_rec   g_cache_pff_rec_table;
g_cache_pgm_pff_rt_rec    g_cache_pff_rec_table;
g_cache_plip_pff_rt_rec   g_cache_pff_rec_table;
g_cache_ptip_pff_rt_rec   g_cache_pff_rec_table;
g_cache_oiplip_pff_rt_rec g_cache_pff_rec_table;
--
type g_cache_hwf_rec_obj is record
(id                    number,
 exist                 varchar2(1),
 hrs_src_cd            ben_hrs_wkd_in_perd_fctr.hrs_src_cd%type,
 hrs_wkd_det_cd        ben_hrs_wkd_in_perd_fctr.hrs_wkd_det_cd%type,
 hrs_wkd_det_rl        ben_hrs_wkd_in_perd_fctr.hrs_wkd_det_rl%type,
 rndg_cd               ben_hrs_wkd_in_perd_fctr.rndg_cd%type,
 rndg_rl               ben_hrs_wkd_in_perd_fctr.rndg_rl%type,
 defined_balance_id    ben_hrs_wkd_in_perd_fctr.defined_balance_id%type,
 bnfts_bal_id          ben_hrs_wkd_in_perd_fctr.bnfts_bal_id%type,
 mn_hrs_num            ben_hrs_wkd_in_perd_fctr.mn_hrs_num%type,
 mx_hrs_num            ben_hrs_wkd_in_perd_fctr.mx_hrs_num%type,
 once_r_cntug_cd       ben_hrs_wkd_in_perd_fctr.once_r_cntug_cd%type,
 hrs_wkd_calc_rl       ben_hrs_wkd_in_perd_fctr.hrs_wkd_calc_rl%type);
--
type g_cache_hwf_rec_table is table of g_cache_hwf_rec_obj index
  by binary_integer;
--
g_cache_pl_hwf_el_rec     g_cache_hwf_rec_table;
g_cache_oipl_hwf_el_rec   g_cache_hwf_rec_table;
g_cache_pgm_hwf_el_rec    g_cache_hwf_rec_table;
g_cache_plip_hwf_el_rec   g_cache_hwf_rec_table;
g_cache_ptip_hwf_el_rec   g_cache_hwf_rec_table;
g_cache_pl_hwf_rt_rec     g_cache_hwf_rec_table;
g_cache_oipl_hwf_rt_rec   g_cache_hwf_rec_table;
g_cache_pgm_hwf_rt_rec    g_cache_hwf_rec_table;
g_cache_plip_hwf_rt_rec   g_cache_hwf_rec_table;
g_cache_ptip_hwf_rt_rec   g_cache_hwf_rec_table;
g_cache_oiplip_hwf_rt_rec g_cache_hwf_rec_table;
--
procedure get_los_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_los_rec_obj);
--
procedure get_los_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_los_rec_obj);
--
procedure get_los_stated
    (p_los_fctr_id       in  number,
     p_business_group_id in  number,
     p_rec               out nocopy g_cache_los_rec_obj);
--
procedure get_age_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_age_rec_obj);
--
procedure get_age_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_age_rec_obj);
--
procedure get_age_stated
    (p_age_fctr_id       in  number,
     p_business_group_id in  number,
     p_rec               out nocopy g_cache_age_rec_obj);
--
procedure get_comp_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_clf_rec_obj);
--
procedure get_comp_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_clf_rec_obj);
--
procedure get_comb_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_cla_rec_obj);
--
procedure get_comb_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_cla_rec_obj);
--
procedure get_pct_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_pff_rec_obj);
--
procedure get_pct_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_pff_rec_obj);
--
procedure get_hours_elig
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_hwf_rec_obj);
--
procedure get_hours_rate
    (p_pgm_id            in  number,
     p_pl_id             in  number,
     p_oipl_id           in  number,
     p_plip_id           in  number,
     p_ptip_id           in  number,
     p_oiplip_id         in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy g_cache_hwf_rec_obj);
--
procedure clear_down_cache;
--
end ben_derive_part_and_rate_cache;

 

/
