--------------------------------------------------------
--  DDL for Package BEN_PEP_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEP_CACHE" AUTHID CURRENT_USER as
/* $Header: benpepch.pkh 120.2 2005/10/21 01:58:56 abparekh noship $*/
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
  115.1      05-Jul-00	mhoyes     Upgraded.
  115.2      11-Dec-01	mhoyes     - Added get_pilplnpep_dets.
  115.3      17-Apr-02  pbodla     - Added lines for GSCC compliance.
  115.4      12-Jul-02  mhoyes     - Added get_curroiplippep_dets and
                                     get_currplnpep_dets.
  115.5      20-Aug-02  mhoyes     - Added caching into get_currpepepo_dets based
                                     on comp object list row values.
  115.6      17-Mar-03  vsethi     - Bug 2650247 added inelg_rsn_cd to g_pep_rec
  				     record type
  115.7      18-Feb-04  mhoyes     - Bug 3412822. Revamp of eligibility cache.
  115.8      06-Apr-04  mhoyes     - Bug 3412822. Revamp of eligibility cache.
  115.9      13-Oct-04  mhoyes     - Bug 3950924. Added get_pilepo_dets11521.
  115.10     04-May-05  mhoyes     - Bug 4350303. Backed out nocopy due to
                                     performance regression.
  115.11     06-May-05  mhoyes     - Bug 4350303. Removed obsolete procedures.
  115.12     12-jun-05  mhoyes     - Bug 4425771. Defined package locals as
                                     globals.
  115.13     20-Oct-05  abparekh   - Bug 4646361 : Added NOCOPY hint to out parameters
  -----------------------------------------------------------------------------
*/
--
-- elig per
--
type g_pep_inst_tbl is table of ben_derive_part_and_rate_facts.g_cache_structure
  index by binary_integer;
--
--
-- elig per
--
g_pilpep_lookup         ben_cache.g_cache_lookup_table;
g_pilpep_instance       g_pep_inst_tbl;
g_pilpep_cached         boolean := FALSE;
--
-- Globals.
--
g_package varchar2(50) := 'ben_pep_cache.';
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
g_pilpep_effdt       date;
g_pilpep_personid    number;
g_optpilepo_effdt    date;
g_optpilepo_personid number;
--
procedure get_pilpep_dets
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_ptip_id           in     number default null
  ,p_pl_id             in     number default null
  ,p_plip_id           in     number default null
  ,p_date_sync         in     boolean default false
--  ,p_inst_row          in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inst_row             out nocopy ben_derive_part_and_rate_facts.g_cache_structure
  );
--
type g_epo_inst_tbl is table of ben_derive_part_and_rate_facts.g_cache_structure
  index by binary_integer;
--
g_optpilepo_lookup       ben_cache.g_cache_lookup_table;
g_optpilepo_instance     g_epo_inst_tbl;
g_optpilepo_cached       boolean := FALSE;
--
procedure get_pilepo_dets
  (p_person_id         in     number
  ,p_business_group_id in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number default null
  ,p_pl_id             in     number default null
  ,p_opt_id            in     number default null
  ,p_plip_id           in     number default null
  ,p_date_sync         in     boolean default false
--  ,p_inst_row          in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inst_row             out nocopy ben_derive_part_and_rate_facts.g_cache_structure
  );
--
type g_pep_rec is record
  (elig_per_id           number
  ,elig_flag             varchar2(30)
  ,must_enrl_anthr_pl_id number
  ,prtn_strt_dt          date
  ,prtn_end_dt           date
  ,inelg_rsn_cd		 varchar2(30) -- 2650247
  );
--
procedure get_currpepepo_dets
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_per_in_ler_id     in     number
  ,p_effective_date    in     date
  ,p_pgm_id            in     number
  ,p_pl_id             in     number
  ,p_oipl_id           in     number
  ,p_opt_id            in     number
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  );
--
procedure get_curroiplippep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  );
--
procedure get_currplnpep_dets
  (p_comp_obj_tree_row in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_person_id         in     number
  ,p_effective_date    in     date
  --
  ,p_inst_row	       in out NOCOPY g_pep_rec
  );
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
procedure clear_down_pepcache;
procedure clear_down_epocache;
--
END ben_pep_cache;

 

/
