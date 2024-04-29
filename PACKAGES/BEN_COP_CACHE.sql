--------------------------------------------------------
--  DDL for Package BEN_COP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COP_CACHE" AUTHID CURRENT_USER AS
/* $Header: bencopch.pkh 115.3 2003/01/30 00:08:01 kmahendr ship $ */
--
-- Get oipl details for plans which are not in programs
--
type g_bgpcop_rec is record
  (oipl_id                   ben_oipl_f.oipl_id%type
  ,opt_id                    ben_oipl_f.opt_id%type
  ,drvbl_fctr_prtn_elig_flag ben_oipl_f.drvbl_fctr_prtn_elig_flag%type
  ,drvbl_fctr_apls_rts_flag  ben_oipl_f.drvbl_fctr_apls_rts_flag%type
  ,trk_inelig_per_flag       ben_oipl_f.trk_inelig_per_flag%type
  );
--
type g_bgpcop_cache is table of g_bgpcop_rec
index by binary_integer;
--
g_eedcop_parlookup ben_cache.g_cache_lookup_table;
g_eedcop_lookup    ben_cache.g_cache_lookup_table;
g_eedcop_inst      ben_cop_cache.g_bgpcop_cache;
--
procedure bgpcop_getdets
  (p_effective_date    in     date
  ,p_business_group_id in     number
  ,p_pl_id             in     number default null
  ,p_opt_id            in     number default null
  ,p_eligy_prfl_id     in     number default null
  ,p_vrbl_rt_prfl_id   in     number default null
  ,p_mode              in     varchar2 default null
  --
  ,p_inst_set                 out nocopy ben_cop_cache.g_bgpcop_cache
  );
--
procedure clear_down_cache;
--
END ben_cop_cache;

 

/
