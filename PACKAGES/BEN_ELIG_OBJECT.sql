--------------------------------------------------------
--  DDL for Package BEN_ELIG_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_OBJECT" AUTHID CURRENT_USER as
/* $Header: beneligo.pkh 120.0 2005/05/28 08:56:16 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Comp Elig Object Caching Routine
Purpose
	This package is used to return comp object elig information.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        05 May 99        G Perry    115.0      Created
        06 May 99        G Perry    115.1      Backport for Fidelity.
        06 May 99        G Perry    115.2      Leapfrog from 115.0.
        07 May 99        G Perry    115.3      Added cache for ben_prtn_elig_f
                                               for Bala.
        15 May 00        RChase     115.9      Altered all procedure calls to
                                               utilize NOCOPY for large objects
        22 May 00        mhoyes     115.10   - Modified set_object to pass out
                                               record structure.
*/
--------------------------------------------------------------------------------
--
-- Cache all comp object stuff
--
type g_cache_elig_prte_rec_table is table of ben_elig_to_prte_rsn_f%rowtype
  index by binary_integer;
--
type g_cache_elig_rec_table is table of ben_prtn_elig_f%rowtype
  index by binary_integer;
--
g_cache_pgm_rec         g_cache_elig_prte_rec_table;
g_cache_pl_rec          g_cache_elig_prte_rec_table;
g_cache_oipl_rec        g_cache_elig_prte_rec_table;
g_cache_plip_rec        g_cache_elig_prte_rec_table;
g_cache_ptip_rec        g_cache_elig_prte_rec_table;
g_cache_pgm_elig_rec    g_cache_elig_rec_table;
g_cache_pl_elig_rec     g_cache_elig_rec_table;
g_cache_oipl_elig_rec   g_cache_elig_rec_table;
g_cache_plip_elig_rec   g_cache_elig_rec_table;
g_cache_ptip_elig_rec   g_cache_elig_rec_table;
--
-- Set object routines
--
procedure set_object(p_pgm_id  in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure set_object(p_pl_id   in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure set_object(p_oipl_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure set_object(p_plip_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure set_object(p_ptip_id in number,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
--
procedure set_object(p_pgm_id  in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure set_object(p_pl_id   in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure set_object(p_oipl_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure set_object(p_plip_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure set_object(p_ptip_id in number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
--
procedure set_object(p_pl_id             in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                    );
procedure set_object(p_pgm_id            in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     );
procedure set_object(p_oipl_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     );
procedure set_object(p_plip_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     );
procedure set_object(p_ptip_id           in number,
                     p_ler_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date,
                     p_rec               in out NOCOPY ben_elig_to_prte_rsn_f%rowtype
                     );
--
procedure set_object(p_pl_id             in number,
                     p_business_group_id in number,
                     p_effective_date    in date);
procedure set_object(p_pgm_id            in number,
                     p_business_group_id in number,
                     p_effective_date    in date);
procedure set_object(p_oipl_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date);
procedure set_object(p_plip_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date);
procedure set_object(p_ptip_id           in number,
                     p_business_group_id in number,
                     p_effective_date    in date);
--
-- Get object routines
--
procedure get_object(p_pgm_id  in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure get_object(p_pl_id   in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure get_object(p_oipl_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure get_object(p_plip_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
procedure get_object(p_ptip_id in  number,
                     p_ler_id  in  number default null,
                     p_rec     in out NOCOPY ben_elig_to_prte_rsn_f%rowtype);
--
procedure get_object(p_pgm_id  in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure get_object(p_pl_id   in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure get_object(p_oipl_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure get_object(p_plip_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
procedure get_object(p_ptip_id in  number,
                     p_rec     in out NOCOPY ben_prtn_elig_f%rowtype);
--
procedure clear_down_cache;
--
end ben_elig_object;

 

/
