--------------------------------------------------------
--  DDL for Package BEN_EPE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EPE_CACHE" AUTHID CURRENT_USER as
/* $Header: benepech.pkh 120.0 2005/05/28 08:59:10 appldev noship $*/
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
  115.0      07-Aug-00	mhoyes     Created.
  115.1      05-Jan-01  kmahendr   added parameter per_in_ler_id
  115.2      27-Jan-01  mhoyes     Added new columns to cache for use with EFC
  115.3      01-Aug-01  ikasire    added in_pndg_wkflow_flag column to epe
  115.4      13-Aug-01  mhoyes   - Added bnft_prvdr_pool_id to type.
                                 - Added EPE_GetEPEDets.
  115.5      11-Dec-01	mhoyes   - Added get_pilcobjepe_dets.
  115.6      12-Apr-04  kmahendr - Added three columns to cache.
  -----------------------------------------------------------------------------
*/
--
type g_pilepe_inst_row is record
  (elig_per_elctbl_chc_id       ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type
  ,business_group_id            ben_elig_per_elctbl_chc.business_group_id%type
  ,person_id                    ben_per_in_ler.person_id%type
  ,ler_id                       ben_per_in_ler.ler_id%type
  ,LF_EVT_OCRD_DT               ben_per_in_ler.LF_EVT_OCRD_DT%type
  ,per_in_ler_stat_cd           ben_per_in_ler.per_in_ler_stat_cd%type
  ,per_in_ler_id                ben_elig_per_elctbl_chc.per_in_ler_id%type
  ,pgm_id                       ben_elig_per_elctbl_chc.pgm_id%type
  ,pl_typ_id                    ben_elig_per_elctbl_chc.pl_typ_id%type
  ,ptip_id                      ben_elig_per_elctbl_chc.ptip_id%type
  ,plip_id                      ben_elig_per_elctbl_chc.plip_id%type
  ,pl_id                        ben_elig_per_elctbl_chc.pl_id%type
  ,oipl_id                      ben_elig_per_elctbl_chc.oipl_id%type
  ,oiplip_id                    ben_elig_per_elctbl_chc.oiplip_id%type
  ,opt_id                       ben_opt_f.opt_id%type
  ,enrt_perd_id                 ben_pil_elctbl_chc_popl.enrt_perd_id%type
  ,lee_rsn_id                   ben_pil_elctbl_chc_popl.lee_rsn_id%type
  ,enrt_perd_strt_dt            ben_pil_elctbl_chc_popl.enrt_perd_strt_dt%type
  ,prtt_enrt_rslt_id            ben_elig_per_elctbl_chc.prtt_enrt_rslt_id%type
  ,enrt_cvg_strt_dt             ben_elig_per_elctbl_chc.enrt_cvg_strt_dt%type
  ,enrt_cvg_strt_dt_cd          ben_elig_per_elctbl_chc.enrt_cvg_strt_dt_cd%type
  ,enrt_cvg_strt_dt_rl          ben_elig_per_elctbl_chc.enrt_cvg_strt_dt_rl%type
  ,yr_perd_id                   ben_elig_per_elctbl_chc.yr_perd_id%type
  ,comp_lvl_cd                  ben_elig_per_elctbl_chc.comp_lvl_cd%type
  ,cmbn_plip_id                 ben_elig_per_elctbl_chc.cmbn_plip_id%type
  ,cmbn_ptip_id                 ben_elig_per_elctbl_chc.cmbn_ptip_id%type
  ,cmbn_ptip_opt_id             ben_elig_per_elctbl_chc.cmbn_ptip_opt_id%type
  ,dflt_flag                    ben_elig_per_elctbl_chc.dflt_flag%type
  ,ctfn_rqd_flag                ben_elig_per_elctbl_chc.ctfn_rqd_flag%type
  ,enrt_bnft_id                 number
  ,val                          ben_enrt_bnft.val%type
  ,acty_ref_perd_cd             ben_pil_elctbl_chc_popl.acty_ref_perd_cd%type
  ,prtn_strt_dt                 ben_elig_per_f.prtn_strt_dt%type
  ,prtn_ovridn_flag             ben_elig_per_f.prtn_ovridn_flag%type
  ,prtn_ovridn_thru_dt          ben_elig_per_f.prtn_ovridn_thru_dt%type
  ,rt_age_val                   ben_elig_per_f.rt_age_val%type
  ,rt_los_val                   ben_elig_per_f.rt_los_val%type
  ,rt_hrs_wkd_val               ben_elig_per_f.rt_hrs_wkd_val%type
  ,rt_cmbn_age_n_los_val        ben_elig_per_f.rt_cmbn_age_n_los_val%type
  ,elctbl_flag                  ben_elig_per_elctbl_chc.elctbl_flag%type
  ,object_version_number        ben_elig_per_elctbl_chc.object_version_number%type
  ,alws_dpnt_dsgn_flag          ben_elig_per_elctbl_chc.alws_dpnt_dsgn_flag%type
  ,dpnt_dsgn_cd                 ben_elig_per_elctbl_chc.dpnt_dsgn_cd%type
  ,ler_chg_dpnt_cvg_cd          ben_elig_per_elctbl_chc.ler_chg_dpnt_cvg_cd%type
  ,dpnt_cvg_strt_dt_cd          ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_cd%type
  ,dpnt_cvg_strt_dt_rl          ben_elig_per_elctbl_chc.dpnt_cvg_strt_dt_rl%type
  ,in_pndg_wkflow_flag          ben_elig_per_elctbl_chc.in_pndg_wkflow_flag%type
  ,bnft_prvdr_pool_id           ben_elig_per_elctbl_chc.bnft_prvdr_pool_id%type
  ,elig_flag                    ben_elig_per_elctbl_chc.elig_flag%type
  ,inelig_rsn_cd                ben_elig_per_elctbl_chc.inelig_rsn_cd%type
  ,fonm_cvg_strt_dt             ben_elig_per_elctbl_chc.fonm_cvg_strt_dt%type
  );
--
type g_pilepe_inst_tbl is table of g_pilepe_inst_row
  index by binary_integer;
--
g_perepe_instance       g_pilepe_inst_tbl;
--
g_currepe_row                   g_pilepe_inst_row;
g_currcobjepe_row               g_pilepe_inst_row;
--
procedure get_perpilepe_list
  (p_person_id     in     number
  ,p_per_in_ler_id in     number
  ,p_inst_set      in out NOCOPY g_pilepe_inst_tbl
  );
--
g_enbepe_instance     g_pilepe_inst_tbl;
--
procedure ENBEPE_GetEPEDets
  (p_enrt_bnft_id  in     number
  ,p_per_in_ler_id in     number
  ,p_inst_row      in out NOCOPY g_pilepe_inst_row
  );
--
g_epe_instance     g_pilepe_inst_tbl;
--
procedure EPE_GetEPEDets
  (p_elig_per_elctbl_chc_id in     number
  ,p_per_in_ler_id          in     number
  ,p_inst_row               in out NOCOPY g_pilepe_inst_row
  );
--
procedure get_pilcobjepe_dets
  (p_per_in_ler_id  in     number
  ,p_pgm_id         in     number
  ,p_pl_id          in     number
  ,p_oipl_id        in     number
  --
  ,p_inst_row	    in out NOCOPY g_pilepe_inst_row
  );
--
procedure init_context_pileperow;
--
procedure init_context_cobj_pileperow;
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
END ben_epe_cache;

 

/
