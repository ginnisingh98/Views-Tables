--------------------------------------------------------
--  DDL for Package BEN_DERIVE_PART_AND_RATE_PREM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVE_PART_AND_RATE_PREM" AUTHID CURRENT_USER as
/* $Header: bendrpre.pkh 120.0 2005/05/28 04:13:20 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Derive Participation and Rate Premium Routine
Purpose
	This package is used to return or retrieve information that is
        needed for rates and or factors.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        23 Mar 00        G Perry    115.0      Created.

*/
--------------------------------------------------------------------------------
--
-- Cache all derivable factor stuff for any particular plan or program or
-- oipl.
--
g_cache_pl_los_rt_rec   ben_derive_part_and_rate_cache.g_cache_los_rec_table;
g_cache_oipl_los_rt_rec ben_derive_part_and_rate_cache.g_cache_los_rec_table;
--
g_cache_pl_age_rt_rec   ben_derive_part_and_rate_cache.g_cache_age_rec_table;
g_cache_oipl_age_rt_rec ben_derive_part_and_rate_cache.g_cache_age_rec_table;
--
g_cache_pl_clf_rt_rec   ben_derive_part_and_rate_cache.g_cache_clf_rec_table;
g_cache_oipl_clf_rt_rec ben_derive_part_and_rate_cache.g_cache_clf_rec_table;
--
g_cache_pl_cla_rt_rec   ben_derive_part_and_rate_cache.g_cache_cla_rec_table;
g_cache_oipl_cla_rt_rec ben_derive_part_and_rate_cache.g_cache_cla_rec_table;
--
g_cache_pl_pff_rt_rec   ben_derive_part_and_rate_cache.g_cache_pff_rec_table;
g_cache_oipl_pff_rt_rec ben_derive_part_and_rate_cache.g_cache_pff_rec_table;
--
g_cache_pl_hwf_rt_rec   ben_derive_part_and_rate_cache.g_cache_hwf_rec_table;
g_cache_oipl_hwf_rt_rec ben_derive_part_and_rate_cache.g_cache_hwf_rec_table;
--
procedure get_los_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_los_rec_obj);
--
procedure get_age_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_age_rec_obj);
--
procedure get_comp_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_clf_rec_obj);
--
procedure get_comb_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_cla_rec_obj);
--
procedure get_pct_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_pff_rec_obj);
--
procedure get_hours_rate
    (p_pl_id             in  number,
     p_oipl_id           in  number,
     p_old_val           in  number default null,
     p_new_val           in  number default null,
     p_business_group_id in  number,
     p_effective_date    in  date,
     p_rec               out nocopy ben_derive_part_and_rate_cache.g_cache_hwf_rec_obj);
--
procedure clear_down_cache;
--
end ben_derive_part_and_rate_prem;

 

/
