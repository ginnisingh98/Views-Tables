--------------------------------------------------------
--  DDL for Package BEN_CEL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CEL_CACHE" AUTHID CURRENT_USER AS
/* $Header: bencelch.pkh 115.4 2002/12/24 15:44:17 bmanyam ship $ */
--
-- Hand coded
--
-- cep participating eligibility profile by cep
--
type g_cache_cepelp_object_rec is record
 (pl_id         ben_pl_f.pl_id%type,
  pgm_id        ben_pgm_f.pgm_id%type,
  oipl_id       ben_oipl_f.oipl_id%type,
  plip_id       ben_plip_f.plip_id%type,
  ptip_id       ben_ptip_f.ptip_id%type,
  prtn_elig_id  ben_prtn_elig_f.prtn_elig_id%type,
  mndtry_flag   ben_prtn_elig_prfl_f.mndtry_flag%type,
  eligy_prfl_id ben_eligy_prfl_f.eligy_prfl_id%type);
--
type g_cache_cepelp_instor is table of g_cache_cepelp_object_rec
  index by binary_integer;
--
-- plan participating eligibility profile by plan
--
procedure plnelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure plnelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_pl_id             in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
-- program participating eligibility profile by program
--
procedure pgmelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure pgmelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_pgm_id            in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
-- oipl participating eligibility profile by oipl
--
procedure copelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure copelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_oipl_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
-- plip participating eligibility profile by plip
--
procedure cppelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure cppelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_plip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
-- ptip participating eligibility profile by ptip
--
procedure ctpelp_writecache
  (p_effective_date in date,
   p_refresh_cache  in boolean default FALSE);
--
procedure ctpelp_getcacdets
  (p_effective_date    in  date,
   p_business_group_id in  number,
   p_ptip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
-- cep participating eligibility profile by cep
--
procedure cepelp_getdets
  (p_business_group_id in  number,
   p_effective_date    in  date,
   p_pgm_id            in  number,
   p_pl_id             in  number,
   p_oipl_id           in  number,
   p_plip_id           in  number,
   p_ptip_id           in  number,
   p_refresh_cache     in  boolean default FALSE,
   p_inst_set          out nocopy ben_cel_cache.g_cache_cepelp_instor,
   p_inst_count        out nocopy number);
--
procedure clear_down_cache;
--
END ben_cel_cache;

 

/
