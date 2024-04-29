--------------------------------------------------------
--  DDL for Package BEN_PEP_CACHE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEP_CACHE1" AUTHID CURRENT_USER as
/* $Header: benppch1.pkh 115.5 2004/04/06 11:31:00 mhoyes noship $*/
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
  115.0      25-Aug-03	mhoyes     Created.
  115.1      28-Aug-03	mhoyes     - Added get_currplnpep_dets.
  115.2      01-Feb-04	mhoyes     - Bug 3412822: Added get_currpepcobj_prtnstrtdt.
  115.3      18-Feb-04  mhoyes     - Bug 3412822. Revamp of eligibility cache.
  115.4      24-Feb-04  mhoyes     - Bug 3412822. More eligibility cache tuning.
  115.5      08-Apr-04  mhoyes     - Bug 3412822. More eligibility cache tuning.
  -----------------------------------------------------------------------------
*/
--
type g_ecrpep_rec is record
  (prtn_strt_dt          date
  ,prtn_ovridn_flag      varchar2(30)
  ,prtn_ovridn_thru_dt   date
  ,rt_age_val            number
  ,rt_los_val            number
  ,rt_hrs_wkd_val        number
  ,rt_cmbn_age_n_los_val number
  ,per_in_ler_id         number
  ,elig_per_id           number
  ,elig_per_opt_id       number
  );
--
procedure get_curroiplippep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY ben_pep_cache.g_pep_rec
  );
--
procedure get_currplnpep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY ben_pep_cache.g_pep_rec
  );
--
procedure get_currpepcobj_cache
  (p_person_id         in     number
  ,p_pgm_id            in     number
  ,p_ptip_id           in     number default null
  ,p_pl_id             in     number
  ,p_plip_id           in     number default null
  ,p_opt_id            in     number
  ,p_effective_date    in     date
  --
  ,p_ecrpep_rec        in out NOCOPY g_ecrpep_rec
  );
--
END ben_pep_cache1;

 

/
