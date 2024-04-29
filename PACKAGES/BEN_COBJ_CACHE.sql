--------------------------------------------------------
--  DDL for Package BEN_COBJ_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COBJ_CACHE" AUTHID CURRENT_USER as
/* $Header: becobjch.pkh 120.2 2006/03/13 17:12:36 kmahendr noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      28-Jun-99	mhoyes     Created.
  115.1      13-Jul-00	mhoyes     Added pgm,ptip,plip,prel and etpr caches.
  115.2      17-May-01  maagrawa   Added columns to pgm,pl,plip,ptip,oipl
                                   records.
  115.3      22-May-01  mhoyes   - Upgraded comp object caches to be context
                                   sensitive. Hence when the refresh routine is
                                   not called then the cache will use SQL.
  115.4      26-Jul-01  ikasire    Bug1895874 added nip_dflt_flag to ben_pl_f
                                   table needs to be cached for bendenrr
  115.7      29-Nov-05  abparekh   Bug 4766118 - Added ALWS_QDRO_FLAG to G_PL_INST_ROW
  115.8      13-Mar-06  kmahendr   bug#5082245 - added svgs_pl_flag to g_pl_inst_ro
  -----------------------------------------------------------------------------
*/
--
type g_oiplip_inst_row is record
  (oiplip_id ben_oiplip_f.oiplip_id%type
  ,plip_id   ben_oiplip_f.plip_id%type
  ,oipl_id   ben_oiplip_f.oipl_id%type
  );
--
type g_oiplip_inst_tbl is table of g_oiplip_inst_row
  index by binary_integer;
--
g_oiplip_lookup       ben_cache.g_cache_lookup_table;
g_oiplip_instance     g_oiplip_inst_tbl;
g_oiplip_currow       g_oiplip_inst_row;
g_oiplip_cached       pls_integer := 0;
--
procedure get_oiplip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_oiplip_id         in     number default null
  ,p_inst_row	       in out NOCOPY g_oiplip_inst_row
  );
--
type g_opt_inst_row is record
  (opt_id                     ben_opt_f.opt_id%type
  ,name                       ben_opt_f.name%type
  ,effective_start_date       ben_opt_f.effective_start_date%type
  ,effective_end_date         ben_opt_f.effective_end_date%type
  ,rqd_perd_enrt_nenrt_uom    ben_opt_f.rqd_perd_enrt_nenrt_uom%type
  ,rqd_perd_enrt_nenrt_val    ben_opt_f.rqd_perd_enrt_nenrt_val%type
  ,rqd_perd_enrt_nenrt_rl     ben_opt_f.rqd_perd_enrt_nenrt_rl%type
  );
--
type g_opt_inst_tbl is table of g_opt_inst_row
  index by binary_integer;
--
g_opt_lookup       ben_cache.g_cache_lookup_table;
g_opt_instance     g_opt_inst_tbl;
g_opt_currow       g_opt_inst_row;
g_opt_cached       pls_integer := 0;
--
procedure get_opt_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_opt_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_opt_inst_row
  );
--
type g_oipl_inst_row is record
  (oipl_id                   ben_oipl_f.oipl_id%type
  ,effective_start_date      ben_oipl_f.effective_start_date%type
  ,effective_end_date        ben_oipl_f.effective_end_date%type
  ,opt_id                    ben_oipl_f.opt_id%type
  ,pl_id                     ben_oipl_f.pl_id%type
  ,trk_inelig_per_flag       ben_oipl_f.trk_inelig_per_flag%type
  ,ordr_num                  ben_oipl_f.ordr_num%type
  ,elig_apls_flag            ben_oipl_f.elig_apls_flag%type
  ,prtn_elig_ovrid_alwd_flag ben_oipl_f.prtn_elig_ovrid_alwd_flag%type
  ,vrfy_fmly_mmbr_cd         ben_oipl_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_oipl_f.vrfy_fmly_mmbr_rl%type
  ,per_cvrd_cd               ben_oipl_f.per_cvrd_cd%type
  ,dflt_flag                 ben_oipl_f.dflt_flag%type
  ,mndtry_flag               ben_oipl_f.mndtry_flag%type
  ,mndtry_rl                 ben_oipl_f.mndtry_rl%type
  ,auto_enrt_flag            ben_oipl_f.auto_enrt_flag%type
  ,auto_enrt_mthd_rl         ben_oipl_f.auto_enrt_mthd_rl%type
  ,enrt_cd                   ben_oipl_f.enrt_cd%type
  ,enrt_rl                   ben_oipl_f.enrt_rl%type
  ,dflt_enrt_cd              ben_oipl_f.dflt_enrt_cd%type
  ,dflt_enrt_det_rl          ben_oipl_f.dflt_enrt_det_rl%type
  ,rqd_perd_enrt_nenrt_uom   ben_oipl_f.rqd_perd_enrt_nenrt_uom%type
  ,rqd_perd_enrt_nenrt_val   ben_oipl_f.rqd_perd_enrt_nenrt_val%type
  ,rqd_perd_enrt_nenrt_rl    ben_oipl_f.rqd_perd_enrt_nenrt_rl%type
  ,actl_prem_id              ben_oipl_f.actl_prem_id%type
  ,postelcn_edit_rl          ben_oipl_f.postelcn_edit_rl%type
  );
--
type g_oipl_inst_tbl is table of g_oipl_inst_row
  index by binary_integer;
--
g_oipl_lookup       ben_cache.g_cache_lookup_table;
g_oipl_instance     g_oipl_inst_tbl;
g_oipl_currow       g_oipl_inst_row;
g_oipl_cached       pls_integer := 0;
--
procedure get_oipl_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_oipl_inst_row
  );
--
type g_pgm_inst_row is record
  (pgm_id                    ben_pgm_f.pgm_id%type
  ,effective_start_date      ben_pgm_f.effective_start_date%type
  ,effective_end_date        ben_pgm_f.effective_end_date%type
  ,enrt_cvg_strt_dt_cd       ben_pgm_f.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl       ben_pgm_f.enrt_cvg_strt_dt_rl%type
  ,enrt_cvg_end_dt_cd        ben_pgm_f.enrt_cvg_end_dt_cd%type
  ,enrt_cvg_end_dt_rl        ben_pgm_f.enrt_cvg_end_dt_rl%type
  ,rt_strt_dt_cd             ben_pgm_f.rt_strt_dt_cd%type
  ,rt_strt_dt_rl             ben_pgm_f.rt_strt_dt_rl%type
  ,rt_end_dt_cd              ben_pgm_f.rt_end_dt_cd%type
  ,rt_end_dt_rl              ben_pgm_f.rt_end_dt_rl%type
  ,elig_apls_flag            ben_pgm_f.elig_apls_flag%type
  ,prtn_elig_ovrid_alwd_flag ben_pgm_f.prtn_elig_ovrid_alwd_flag%type
  ,trk_inelig_per_flag       ben_pgm_f.trk_inelig_per_flag%type
  ,vrfy_fmly_mmbr_cd         ben_pgm_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_pgm_f.vrfy_fmly_mmbr_rl%type
  ,dpnt_dsgn_lvl_cd          ben_pgm_f.dpnt_dsgn_lvl_cd%type
  ,dpnt_dsgn_cd              ben_pgm_f.dpnt_dsgn_cd%type
  ,dpnt_cvg_strt_dt_cd       ben_pgm_f.dpnt_cvg_strt_dt_cd%type
  ,dpnt_cvg_strt_dt_rl       ben_pgm_f.dpnt_cvg_strt_dt_rl%type
  ,dpnt_cvg_end_dt_cd        ben_pgm_f.dpnt_cvg_end_dt_cd%type
  ,dpnt_cvg_end_dt_rl        ben_pgm_f.dpnt_cvg_end_dt_rl%type
  ,pgm_typ_cd                ben_pgm_f.pgm_typ_cd%type
  );
--
type g_pgm_inst_tbl is table of g_pgm_inst_row
  index by binary_integer;
--
g_pgm_lookup       ben_cache.g_cache_lookup_table;
g_pgm_instance     g_pgm_inst_tbl;
g_pgm_currow       g_pgm_inst_row;
g_pgm_cached       pls_integer := 0;
--
g_pgm_default_row  g_pgm_inst_row;
--
procedure get_pgm_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_inst_row	       in out NOCOPY g_pgm_inst_row
  );
--
type g_ptip_inst_row is record
  (ptip_id                   ben_ptip_f.ptip_id%type
  ,effective_start_date      ben_ptip_f.effective_start_date%type
  ,effective_end_date        ben_ptip_f.effective_end_date%type
  ,enrt_cvg_strt_dt_cd       ben_ptip_f.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl       ben_ptip_f.enrt_cvg_strt_dt_rl%type
  ,enrt_cvg_end_dt_cd        ben_ptip_f.enrt_cvg_end_dt_cd%type
  ,enrt_cvg_end_dt_rl        ben_ptip_f.enrt_cvg_end_dt_rl%type
  ,rt_strt_dt_cd             ben_ptip_f.rt_strt_dt_cd%type
  ,rt_strt_dt_rl             ben_ptip_f.rt_strt_dt_rl%type
  ,rt_end_dt_cd              ben_ptip_f.rt_end_dt_cd%type
  ,rt_end_dt_rl              ben_ptip_f.rt_end_dt_rl%type
  ,elig_apls_flag            ben_ptip_f.elig_apls_flag%type
  ,prtn_elig_ovrid_alwd_flag ben_ptip_f.prtn_elig_ovrid_alwd_flag%type
  ,trk_inelig_per_flag       ben_ptip_f.trk_inelig_per_flag%type
  ,ordr_num                  ben_ptip_f.ordr_num%type
  ,vrfy_fmly_mmbr_cd         ben_ptip_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_ptip_f.vrfy_fmly_mmbr_rl%type
  ,rqd_perd_enrt_nenrt_tm_uom ben_ptip_f.rqd_perd_enrt_nenrt_tm_uom%type
  ,rqd_perd_enrt_nenrt_val   ben_ptip_f.rqd_perd_enrt_nenrt_val%type
  ,rqd_perd_enrt_nenrt_rl    ben_ptip_f.rqd_perd_enrt_nenrt_rl%type
  ,dpnt_dsgn_cd              ben_ptip_f.dpnt_dsgn_cd%type
  ,dpnt_cvg_strt_dt_cd       ben_ptip_f.dpnt_cvg_strt_dt_cd%type
  ,dpnt_cvg_strt_dt_rl       ben_ptip_f.dpnt_cvg_strt_dt_rl%type
  ,dpnt_cvg_end_dt_cd        ben_ptip_f.dpnt_cvg_end_dt_cd%type
  ,dpnt_cvg_end_dt_rl        ben_ptip_f.dpnt_cvg_end_dt_rl%type
  ,postelcn_edit_rl          ben_ptip_f.postelcn_edit_rl%type
  );
--
type g_ptip_inst_tbl is table of g_ptip_inst_row
  index by binary_integer;
--
g_ptip_lookup       ben_cache.g_cache_lookup_table;
g_ptip_instance     g_ptip_inst_tbl;
g_ptip_currow       g_ptip_inst_row;
g_ptip_cached       pls_integer := 0;
--
g_ptip_default_row  g_ptip_inst_row;
--
procedure get_ptip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_ptip_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_ptip_inst_row
  );
--
type g_plip_inst_row is record
  (plip_id                   ben_plip_f.plip_id%type
  ,effective_start_date      ben_plip_f.effective_start_date%type
  ,effective_end_date        ben_plip_f.effective_end_date%type
  ,enrt_cvg_strt_dt_cd       ben_plip_f.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl       ben_plip_f.enrt_cvg_strt_dt_rl%type
  ,enrt_cvg_end_dt_cd        ben_plip_f.enrt_cvg_end_dt_cd%type
  ,enrt_cvg_end_dt_rl        ben_plip_f.enrt_cvg_end_dt_rl%type
  ,rt_strt_dt_cd             ben_plip_f.rt_strt_dt_cd%type
  ,rt_strt_dt_rl             ben_plip_f.rt_strt_dt_rl%type
  ,rt_end_dt_cd              ben_plip_f.rt_end_dt_cd%type
  ,rt_end_dt_rl              ben_plip_f.rt_end_dt_rl%type
  ,elig_apls_flag            ben_plip_f.elig_apls_flag%type
  ,prtn_elig_ovrid_alwd_flag ben_plip_f.prtn_elig_ovrid_alwd_flag%type
  ,trk_inelig_per_flag       ben_plip_f.trk_inelig_per_flag%type
  ,ordr_num                  ben_plip_f.ordr_num%type
  ,vrfy_fmly_mmbr_cd         ben_plip_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_plip_f.vrfy_fmly_mmbr_rl%type
  ,bnft_or_option_rstrctn_cd ben_plip_f.bnft_or_option_rstrctn_cd%type
  ,pl_id                     ben_plip_f.pl_id%type
  ,pgm_id                    ben_plip_f.pgm_id%type
  ,cvg_incr_r_decr_only_cd   ben_plip_f.cvg_incr_r_decr_only_cd%type
  ,mx_cvg_mlt_incr_num       ben_plip_f.mx_cvg_mlt_incr_num%type
  ,mx_cvg_mlt_incr_wcf_num   ben_plip_f.mx_cvg_mlt_incr_wcf_num%type
  ,postelcn_edit_rl          ben_plip_f.postelcn_edit_rl%type
  );
--
type g_plip_inst_tbl is table of g_plip_inst_row
  index by binary_integer;
--
g_plip_lookup       ben_cache.g_cache_lookup_table;
g_plip_instance     g_plip_inst_tbl;
g_plip_currow       g_plip_inst_row;
g_plip_cached       pls_integer := 0;
--
g_plip_default_row  g_plip_inst_row;
--
procedure get_plip_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_plip_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_plip_inst_row
  );
--
type g_pl_inst_row is record
  (pl_id                     ben_pl_f.pl_id%type
  ,effective_start_date      ben_pl_f.effective_start_date%type
  ,effective_end_date        ben_pl_f.effective_end_date%type
  ,enrt_cvg_strt_dt_cd       ben_pl_f.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl       ben_pl_f.enrt_cvg_strt_dt_rl%type
  ,enrt_cvg_end_dt_cd        ben_pl_f.enrt_cvg_end_dt_cd%type
  ,enrt_cvg_end_dt_rl        ben_pl_f.enrt_cvg_end_dt_rl%type
  ,rt_strt_dt_cd             ben_pl_f.rt_strt_dt_cd%type
  ,rt_strt_dt_rl             ben_pl_f.rt_strt_dt_rl%type
  ,rt_end_dt_cd              ben_pl_f.rt_end_dt_cd%type
  ,rt_end_dt_rl              ben_pl_f.rt_end_dt_rl%type
  ,elig_apls_flag            ben_pl_f.elig_apls_flag%type
  ,prtn_elig_ovrid_alwd_flag ben_pl_f.prtn_elig_ovrid_alwd_flag%type
  ,per_cvrd_cd               ben_pl_f.per_cvrd_cd%type
  ,pl_typ_id                 ben_pl_f.pl_typ_id%type
  ,trk_inelig_per_flag       ben_pl_f.trk_inelig_per_flag%type
  ,ordr_num                  ben_pl_f.ordr_num%type
  ,mx_wtg_dt_to_use_cd       ben_pl_f.mx_wtg_dt_to_use_cd%type
  ,mx_wtg_dt_to_use_rl       ben_pl_f.mx_wtg_dt_to_use_rl%type
  ,mx_wtg_perd_rl            ben_pl_f.mx_wtg_perd_rl%type
  ,mx_wtg_perd_prte_uom      ben_pl_f.mx_wtg_perd_prte_uom%type
  ,mx_wtg_perd_prte_val      ben_pl_f.mx_wtg_perd_prte_val%type
  ,vrfy_fmly_mmbr_cd         ben_pl_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_pl_f.vrfy_fmly_mmbr_rl%type
  ,bnft_or_option_rstrctn_cd ben_pl_f.bnft_or_option_rstrctn_cd%type
  ,nip_dflt_enrt_cd          ben_pl_f.nip_dflt_enrt_cd%type
  ,nip_dflt_enrt_det_rl      ben_pl_f.nip_dflt_enrt_det_rl%type
  ,rqd_perd_enrt_nenrt_uom   ben_pl_f.rqd_perd_enrt_nenrt_uom%type
  ,rqd_perd_enrt_nenrt_val   ben_pl_f.rqd_perd_enrt_nenrt_val%type
  ,rqd_perd_enrt_nenrt_rl    ben_pl_f.rqd_perd_enrt_nenrt_rl%type
  ,cvg_incr_r_decr_only_cd   ben_pl_f.cvg_incr_r_decr_only_cd%type
  ,mx_cvg_mlt_incr_num       ben_pl_f.mx_cvg_mlt_incr_num%type
  ,mx_cvg_mlt_incr_wcf_num   ben_pl_f.mx_cvg_mlt_incr_wcf_num%type
  ,name                      ben_pl_f.name%type
  ,actl_prem_id              ben_pl_f.actl_prem_id%type
  ,bnf_dsgn_cd               ben_pl_f.bnf_dsgn_cd%type
  ,enrt_pl_opt_flag          ben_pl_f.enrt_pl_opt_flag%type
  ,dpnt_cvg_strt_dt_cd       ben_pl_f.dpnt_cvg_strt_dt_cd%type
  ,dpnt_cvg_strt_dt_rl       ben_pl_f.dpnt_cvg_strt_dt_rl%type
  ,dpnt_cvg_end_dt_cd        ben_pl_f.dpnt_cvg_end_dt_cd%type
  ,dpnt_cvg_end_dt_rl        ben_pl_f.dpnt_cvg_end_dt_rl%type
  ,alws_qmcso_flag           ben_pl_f.alws_qmcso_flag%type
  ,alws_qdro_flag            ben_pl_f.alws_qdro_flag%type
  ,dpnt_dsgn_cd              ben_pl_f.dpnt_dsgn_cd%type
  ,postelcn_edit_rl          ben_pl_f.postelcn_edit_rl%type
  ,dpnt_cvd_by_othr_apls_flag ben_pl_f.dpnt_cvd_by_othr_apls_flag%type
  ,nip_dflt_flag             ben_pl_f.nip_dflt_flag%type
  ,svgs_pl_flag              ben_pl_f.svgs_pl_flag%type
  );
--
type g_pl_inst_tbl is table of g_pl_inst_row
  index by binary_integer;
--
g_pl_lookup       ben_cache.g_cache_lookup_table;
g_pl_instance     g_pl_inst_tbl;
g_pl_currow       g_pl_inst_row;
g_pl_cached       pls_integer := 0;
--
g_pl_default_row  g_pl_inst_row;
--
procedure get_pl_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pl_id             in     number default null
  ,p_inst_row	       in out NOCOPY g_pl_inst_row
  );
--
type g_etpr_inst_row is record
  (elig_to_prte_rsn_id       ben_elig_to_prte_rsn_f.elig_to_prte_rsn_id%type
  ,effective_start_date      ben_elig_to_prte_rsn_f.effective_start_date%type
  ,effective_end_date        ben_elig_to_prte_rsn_f.effective_end_date%type
  ,ler_id                    ben_elig_to_prte_rsn_f.ler_id%type
  ,pgm_id                    ben_elig_to_prte_rsn_f.pgm_id%type
  ,ptip_id                   ben_elig_to_prte_rsn_f.ptip_id%type
  ,plip_id                   ben_elig_to_prte_rsn_f.plip_id%type
  ,pl_id                     ben_elig_to_prte_rsn_f.pl_id%type
  ,oipl_id                   ben_elig_to_prte_rsn_f.oipl_id%type
  ,wait_perd_dt_to_use_cd    ben_elig_to_prte_rsn_f.wait_perd_dt_to_use_cd%type
  ,wait_perd_dt_to_use_rl    ben_elig_to_prte_rsn_f.wait_perd_dt_to_use_rl%type
  ,wait_perd_rl              ben_elig_to_prte_rsn_f.wait_perd_rl%type
  ,wait_perd_uom             ben_elig_to_prte_rsn_f.wait_perd_uom%type
  ,wait_perd_val             ben_elig_to_prte_rsn_f.wait_perd_val%type
  ,prtn_eff_strt_dt_rl       ben_elig_to_prte_rsn_f.prtn_eff_strt_dt_rl%type
  ,prtn_eff_end_dt_rl        ben_elig_to_prte_rsn_f.prtn_eff_end_dt_rl%type
  ,prtn_eff_strt_dt_cd       ben_elig_to_prte_rsn_f.prtn_eff_strt_dt_cd%type
  ,prtn_eff_end_dt_cd        ben_elig_to_prte_rsn_f.prtn_eff_end_dt_cd%type
  ,elig_inelig_cd            ben_elig_to_prte_rsn_f.elig_inelig_cd%type
  ,ignr_prtn_ovrid_flag      ben_elig_to_prte_rsn_f.ignr_prtn_ovrid_flag%type
  ,vrfy_fmly_mmbr_cd         ben_elig_to_prte_rsn_f.vrfy_fmly_mmbr_cd%type
  ,vrfy_fmly_mmbr_rl         ben_elig_to_prte_rsn_f.vrfy_fmly_mmbr_rl%type
  );
--
type g_etpr_inst_tbl is table of g_etpr_inst_row
  index by binary_integer;
--
g_etpr_lookup       ben_cache.g_cache_lookup_table;
g_etpr_instance     g_etpr_inst_tbl;
g_pgmetpr_currow    g_etpr_inst_row;
g_ptipetpr_currow   g_etpr_inst_row;
g_plipetpr_currow   g_etpr_inst_row;
g_pletpr_currow     g_etpr_inst_row;
g_oipletpr_currow   g_etpr_inst_row;
g_etpr_cached       boolean := FALSE;
--
procedure get_etpr_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_ler_id            in     number default null
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_plip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_etpr_inst_row
  );
--
type g_prel_inst_row is record
  (prtn_elig_id              ben_prtn_elig_f.prtn_elig_id%type
  ,effective_start_date      ben_prtn_elig_f.effective_start_date%type
  ,effective_end_date        ben_prtn_elig_f.effective_end_date%type
  ,pgm_id                    ben_prtn_elig_f.pgm_id%type
  ,ptip_id                   ben_prtn_elig_f.ptip_id%type
  ,plip_id                   ben_prtn_elig_f.plip_id%type
  ,pl_id                     ben_prtn_elig_f.pl_id%type
  ,oipl_id                   ben_prtn_elig_f.oipl_id%type
  ,wait_perd_dt_to_use_cd    ben_prtn_elig_f.wait_perd_dt_to_use_cd%type
  ,wait_perd_dt_to_use_rl    ben_prtn_elig_f.wait_perd_dt_to_use_rl%type
  ,wait_perd_rl              ben_prtn_elig_f.wait_perd_rl%type
  ,wait_perd_uom             ben_prtn_elig_f.wait_perd_uom%type
  ,wait_perd_val             ben_prtn_elig_f.wait_perd_val%type
  ,prtn_eff_strt_dt_rl       ben_prtn_elig_f.prtn_eff_strt_dt_rl%type
  ,prtn_eff_end_dt_rl        ben_prtn_elig_f.prtn_eff_end_dt_rl%type
  ,prtn_eff_strt_dt_cd       ben_prtn_elig_f.prtn_eff_strt_dt_cd%type
  ,prtn_eff_end_dt_cd        ben_prtn_elig_f.prtn_eff_end_dt_cd%type
  );
--
type g_prel_inst_tbl is table of g_prel_inst_row
  index by binary_integer;
--
g_prel_lookup       ben_cache.g_cache_lookup_table;
g_prel_instance     g_prel_inst_tbl;
g_pgmprel_currow    g_prel_inst_row;
g_ptipprel_currow   g_prel_inst_row;
g_plipprel_currow   g_prel_inst_row;
g_plprel_currow     g_prel_inst_row;
g_oiplprel_currow   g_prel_inst_row;
g_prel_cached       boolean := FALSE;
--
procedure get_prel_dets
  (p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_plip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_oipl_id           in     number default null
  ,p_inst_row	       in out NOCOPY g_prel_inst_row
  );
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
procedure set_no_cache_context;
--
END ben_cobj_cache;

 

/
