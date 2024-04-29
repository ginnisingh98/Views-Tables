--------------------------------------------------------
--  DDL for Package BEN_PLN_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLN_CACHE" AUTHID CURRENT_USER AS
/* $Header: benplnch.pkh 115.7 2003/01/01 00:00:22 mmudigon ship $ */
--
-- Get plan details for plans which are not in programs
--
type g_nipplnpln_cache is table of ben_pl_f%rowtype
index by binary_integer;
--
type g_bgppln_rec is record
  (pl_id                     ben_pl_f.pl_id%type
  ,pl_typ_id                 ben_pl_f.pl_typ_id%type
  ,ptp_opt_typ_cd            ben_pl_typ_f.opt_typ_cd%type
  ,drvbl_fctr_prtn_elig_flag ben_pl_f.drvbl_fctr_prtn_elig_flag%type
  ,drvbl_fctr_apls_rts_flag  ben_pl_f.drvbl_fctr_apls_rts_flag%type
  ,trk_inelig_per_flag       ben_pl_f.trk_inelig_per_flag%type
  );
--
type g_bgppln_cache is table of g_bgppln_rec
index by binary_integer;
--
type g_bgpcpp_cache_rec is record
(pgm_id    number
,pl_id     number
,pl_typ_id number
);
--
type g_bgpcpp_cache is table of ben_pl_f%rowtype
index by binary_integer;
--
g_eedcpp_parlookup ben_cache.g_cache_lookup_table;
g_eedcpp_lookup    ben_cache.g_cache_lookup_table;
g_eedcpp_inst      ben_pln_cache.g_bgpcpp_cache;
--
procedure bgpcpp_getdets
  (p_business_group_id     in     number
  ,p_effective_date        in     date
  ,p_mode                  in     varchar2
  ,p_pgm_id                in     number default null
  ,p_pl_id                 in     number default null
  ,p_opt_id                in     number default null
  ,p_rptg_grp_id           in     number default null
  ,p_vrbl_rt_prfl_id       in     number default null
  ,p_eligy_prfl_id         in     number default null
  -- PB : 5422 :
  -- ,p_popl_enrt_typ_cycl_id in     number default null
  --
  ,p_asnd_lf_evt_dt        in     date default null
  ,p_inst_set                 out nocopy ben_pln_cache.g_bgppln_cache
  );
--
procedure clear_down_cache;
--
END ben_pln_cache;

 

/
