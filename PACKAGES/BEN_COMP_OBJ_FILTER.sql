--------------------------------------------------------
--  DDL for Package BEN_COMP_OBJ_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_OBJ_FILTER" AUTHID CURRENT_USER AS
/* $Header: bebmfilt.pkh 120.2 2005/08/30 02:27:54 ssarkar noship $ */
--
-- Parent eligibility state information
--
type g_par_elig_state_rec is record
  (elig_for_pgm_flag  varchar2(30)
  ,elig_for_ptip_flag varchar2(30)
  ,elig_for_plip_flag varchar2(30)
  ,elig_for_pl_flag   varchar2(30)
  );
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
procedure filter_comp_objects
  (p_comp_obj_tree         in     ben_manage_life_events.g_cache_proc_object_table
  ,p_mode                  in     varchar
  ,p_person_id             in     number
  ,p_effective_date        in     date
  ,p_maxtreeele_num        in     pls_integer
  --
  ,p_par_elig_state        in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  ,p_treeele_num           in out nocopy pls_integer
  --
  ,p_treeloop                 out nocopy boolean
  ,p_ler_id                in     number default null
  -- PB : 5422 :
  ,p_lf_evt_ocrd_dt        in     date default null
  -- ,p_popl_enrt_typ_cycl_id in     number default null
  ,p_business_group_id     in     number default null
  );
--
END ben_comp_obj_filter;

 

/
