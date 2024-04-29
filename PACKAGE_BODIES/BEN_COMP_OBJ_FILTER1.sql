--------------------------------------------------------
--  DDL for Package Body BEN_COMP_OBJ_FILTER1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_COMP_OBJ_FILTER1" as
/* $Header: bebmflt1.pkb 120.2 2005/09/27 14:15:00 tmathers noship $ */
--
function check_prevelig_compobj
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_business_group_id in     number
  ,p_person_id         in     number
  ,p_effective_date    in     date
  )
return boolean
is
begin
  return FALSE;
  --
end check_prevelig_compobj;
--
function check_selection_rule
    (p_person_selection_rule_id in number,
     p_person_id                in number,
     p_business_group_id        in number,
     p_effective_date           in date) return boolean is
  --
  l_outputs       ff_exec.outputs_t;
  l_assignment_id number;
  l_package varchar2(80) := 'ben_comp_obj_filter1.check_selection_rule';
  --
begin
    --
    return true;
    --
end check_selection_rule;
--
function check_dupproc_ptip
  (p_ptip_id in     number
  )
return boolean
is
  --
  l_package    varchar2(80) := 'ben_comp_obj_filter1.check_dupproc_ptip';
  --
  l_hv         pls_integer;
  --
begin
    return true;
end check_dupproc_ptip;
--
procedure set_dupproc_ptip_elig
  (p_ptip_id  in     number
  ,p_eligible in     boolean
  )
is
  --
  l_package    varchar2(80) := 'ben_comp_obj_filter1.set_dupproc_ptip_elig';
  --
  l_hv         pls_integer;
  --
begin
  null;
end set_dupproc_ptip_elig;
--
function get_dupproc_ptip_elig
  (p_ptip_id in     number
  )
return boolean
is
  --
  l_package    varchar2(80) := 'ben_comp_obj_filter1.get_dupproc_ptip_elig';
  --
  l_hv         pls_integer;
  --
begin
  return false;
end get_dupproc_ptip_elig;
--
procedure flush_dupproc_ptip_list

is
  --
  l_package    varchar2(80) := 'ben_comp_obj_filter1.flush_dupproc_ptip_list';
  --
  l_dupptip    boolean;
  --
begin
  --
  null;
  --
end flush_dupproc_ptip_list;
--
procedure set_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  ,p_eligible          in     boolean
  ,p_treeele_num       in     pls_integer
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  )
is
  --
  l_package    varchar2(80) := 'ben_comp_obj_filter1.set_parent_elig_flags';
  --
  l_hv         pls_integer;
  --
begin
  null;
end set_parent_elig_flags;
--
procedure set_bound_parent_elig_flags
  (p_comp_obj_tree_row in     ben_manage_life_events.g_cache_proc_objects_rec
  --
  ,p_par_elig_state    in out nocopy ben_comp_obj_filter.g_par_elig_state_rec
  )
is
  --
  l_package varchar2(80) := 'ben_comp_obj_filter1.set_bound_parent_elig_flags';
  --
begin
  null;
end set_bound_parent_elig_flags;
--
end ben_comp_obj_filter1;

/
