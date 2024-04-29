--------------------------------------------------------
--  DDL for Package BEN_COMP_OBJ_FILTER1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_OBJ_FILTER1" AUTHID CURRENT_USER AS
/* $Header: bebmflt1.pkh 120.1 2005/06/06 11:43:12 mhoyes noship $ */
--
g_hash_key number      := ben_hash_utility.get_hash_key;
g_hash_jump number     := ben_hash_utility.get_hash_jump;
--
function check_prevelig_compobj
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_business_group_id in     number
  ,p_person_id         in     number
  ,p_effective_date    in     date
  )
return boolean;
--
function check_selection_rule
    (p_person_selection_rule_id in number,
     p_person_id                in number,
     p_business_group_id        in number,
     p_effective_date           in date)
return boolean;
--
function check_dupproc_ptip
  (p_ptip_id in     number
  )
return boolean;
--
procedure set_dupproc_ptip_elig
  (p_ptip_id  in     number
  ,p_eligible in     boolean
  );
--
function get_dupproc_ptip_elig
  (p_ptip_id in     number
  )
return boolean;
--
procedure flush_dupproc_ptip_list;
--
procedure set_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_eligible          in     boolean
  ,p_treeele_num       in     pls_integer
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  );
--
procedure set_bound_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  );
--
END ben_comp_obj_filter1;

 

/
