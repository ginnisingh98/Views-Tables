--------------------------------------------------------
--  DDL for Package BEN_ELIG_RL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_RL_CACHE" AUTHID CURRENT_USER AS
/* $Header: benelrch.pkh 120.0.12010000.1 2008/07/29 12:23:11 appldev ship $*/
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  bbulusu    Created.
  115.1      02-Aug-99  gperry     Added support for PLIP and PTIP.
  115.2      30-Dec-02  ikasire    nocopy changes
  -----------------------------------------------------------------------------
*/
--
-- Global record type.
--
type g_elig_rl_rec is record
  (id               number
  ,pgm_id           ben_pgm_f.pgm_id%type
  ,pl_id            ben_pl_f.pl_id%type
  ,oipl_id          ben_oipl_f.oipl_id%type
  ,plip_id          ben_plip_f.plip_id%type
  ,ptip_id          ben_ptip_f.ptip_id%type
  ,formula_id       ben_prtn_eligy_rl_f.formula_id%type
  ,mndtry_flag      ben_prtn_eligy_rl_f.mndtry_flag%type
  ,ordr_to_aply_num ben_prtn_eligy_rl_f.ordr_to_aply_num%type
  );
--
type g_elig_rl_inst_tbl is table of g_elig_rl_rec index by binary_integer;
--
-- Global cache structures for eache comp object's lookup and instance.
--
g_pgm_lookup           ben_cache.g_cache_lookup_table;
g_pl_lookup            ben_cache.g_cache_lookup_table;
g_oipl_lookup          ben_cache.g_cache_lookup_table;
g_plip_lookup          ben_cache.g_cache_lookup_table;
g_ptip_lookup          ben_cache.g_cache_lookup_table;
g_pgm_instance         ben_elig_rl_cache.g_elig_rl_inst_tbl;
g_pl_instance          ben_elig_rl_cache.g_elig_rl_inst_tbl;
g_oipl_instance        ben_elig_rl_cache.g_elig_rl_inst_tbl;
g_plip_instance        ben_elig_rl_cache.g_elig_rl_inst_tbl;
g_ptip_instance        ben_elig_rl_cache.g_elig_rl_inst_tbl;
--
procedure get_elig_rl_cache
  (p_pgm_id            in number
  ,p_pl_id             in number
  ,p_oipl_id           in number
  ,p_plip_id           in number
  ,p_ptip_id           in number
  ,p_effective_date    in date
  ,p_lf_evt_ocrd_dt    in date
  ,p_business_group_id in number
  ,p_inst_set          out nocopy ben_elig_rl_cache.g_elig_rl_inst_tbl
  ,p_inst_count        out nocopy number
  );
--
procedure clear_down_cache;
--
end ben_elig_rl_cache;

/
