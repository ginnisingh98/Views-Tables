--------------------------------------------------------
--  DDL for Package BEN_COMP_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_OBJECT" AUTHID CURRENT_USER as
/* $Header: bencompo.pkh 120.0 2005/05/28 03:51:53 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Comp Object Caching Routine
Purpose
	This package is used to return comp object information.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        05 May 99        G Perry    115.0      Created
        27 May 99        G Perry    115.1      Added extra cache for cobra.
        26 Jun 99        G Perry    115.2      Made objects cache on demand.
        04 Aug 99        G Perry    115.3      Added last record got cache.
        31 Mar 00        G Perry    115.4      Added extra cache for oiplip.
        06 May 00        RChase     115.9      Performance NOCOPY changes
        29 Dec 00        Tmathsers  115.10     Foxed check_sql errors.
*/
--------------------------------------------------------------------------------
--
-- Cache all comp object stuff
--
type g_cache_pgm_rec_table is table of ben_pgm_f%rowtype index
  by binary_integer;
--
type g_cache_pl_rec_table is table of ben_pl_f%rowtype index
  by binary_integer;
--
type g_cache_oipl_rec_table is table of ben_oipl_f%rowtype index
  by binary_integer;
--
type g_cache_ptip_rec_table is table of ben_ptip_f%rowtype index
  by binary_integer;
--
type g_cache_plip_rec_table is table of ben_plip_f%rowtype index
  by binary_integer;
--
type g_cache_opt_rec_table is table of ben_opt_f%rowtype index
  by binary_integer;
--
type g_cache_oiplip_rec_table is table of ben_oiplip_f%rowtype index
  by binary_integer;
--
g_cache_pgm_rec          g_cache_pgm_rec_table;
g_cache_pl_rec           g_cache_pl_rec_table;
g_cache_pgm_cobra_rec    g_cache_pl_rec_table;
g_cache_pgm_cobra_lookup ben_cache.g_cache_lookup_table;
g_cache_oipl_rec         g_cache_oipl_rec_table;
g_cache_plip_rec         g_cache_plip_rec_table;
g_cache_ptip_rec         g_cache_ptip_rec_table;
g_cache_opt_rec          g_cache_opt_rec_table;
g_cache_oiplip_rec       g_cache_oiplip_rec_table;
--
g_cache_last_pgm_rec     ben_pgm_f%rowtype;
g_cache_last_pl_rec      ben_pl_f%rowtype;
g_cache_last_oipl_rec    ben_oipl_f%rowtype;
g_cache_last_plip_rec    ben_plip_f%rowtype;
g_cache_last_ptip_rec    ben_ptip_f%rowtype;
g_cache_last_opt_rec     ben_opt_f%rowtype;
g_cache_last_oiplip_rec  ben_oiplip_f%rowtype;
--
-- Set object routines
--
procedure set_object(p_rec in out NOCOPY ben_pgm_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_pl_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_oipl_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_ptip_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_plip_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_opt_f%rowtype);
procedure set_object(p_rec in out NOCOPY ben_oiplip_f%rowtype);
--
procedure set_object(p_pl_id             in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_pl_f%rowtype);
procedure set_object(p_pgm_id            in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_pgm_f%rowtype);
procedure set_object(p_oipl_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_oipl_f%rowtype);
procedure set_object(p_plip_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_plip_f%rowtype);
procedure set_object(p_ptip_id           in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_ptip_f%rowtype);
procedure set_object(p_opt_id            in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_opt_f%rowtype);
procedure set_object(p_oiplip_id         in  number,
                     p_business_group_id in  number,
                     p_effective_date    in  date,
                     p_rec               in out NOCOPY ben_oiplip_f%rowtype);
--
-- Get object routines
--
procedure get_object(p_pgm_id in  number,
                     p_rec    in out NOCOPY ben_pgm_f%rowtype);
procedure get_object(p_pl_id  in  number,
                     p_rec    in out NOCOPY ben_pl_f%rowtype);
procedure get_object(p_oipl_id in  number,
                     p_rec     in out NOCOPY ben_oipl_f%rowtype);
procedure get_object(p_plip_id in  number,
                     p_rec     in out NOCOPY ben_plip_f%rowtype);
procedure get_object(p_ptip_id in  number,
                     p_rec     in out NOCOPY ben_ptip_f%rowtype);
procedure get_object(p_opt_id  in  number,
                     p_rec     in out NOCOPY ben_opt_f%rowtype);
procedure get_object(p_oiplip_id  in  number,
                     p_rec        in out NOCOPY ben_oiplip_f%rowtype);
--
-- Set routines
--
procedure get_object_set_cobra
   (p_pgm_id                   in  number,
    p_only_pls_subj_cobra_flag in varchar2,
    p_rec                      in out NOCOPY g_cache_pl_rec_table);
--
procedure clear_down_cache;
--
end ben_comp_object;

 

/
