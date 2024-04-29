--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ELIGIBILITY" AUTHID CURRENT_USER AS
/* $Header: bendetel.pkh 120.1.12010000.1 2008/07/29 12:09:55 appldev ship $ */
  --
  g_eligible        exception;
  g_criteria_failed exception;
  g_skip_profile    exception;
  g_not_eligible    exception;
  g_inelg_rsn_cd    varchar2(30);
  --
  g_rec             benutils.g_batch_elig_rec;
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
type g_elig_dpnt_table is table of per_contact_relationships%rowtype
  index by binary_integer;
--
g_elig_dpnt_rec g_elig_dpnt_table;
--
procedure determine_elig_prfls
  (p_comp_obj_tree_row         in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_par_elig_state            in out NOCOPY ben_comp_obj_filter.g_par_elig_state_rec
  ,p_per_row                   in out NOCOPY per_all_people_f%rowtype
  ,p_empasg_row                in out NOCOPY per_all_assignments_f%rowtype
  ,p_benasg_row                in out NOCOPY per_all_assignments_f%rowtype
  ,p_appasg_row                in out NOCOPY ben_person_object.g_cache_ass_table
  ,p_empasgast_row             in out NOCOPY per_assignment_status_types%rowtype
  ,p_benasgast_row             in out NOCOPY per_assignment_status_types%rowtype
  ,p_pil_row                   in out NOCOPY ben_per_in_ler%rowtype
  ,p_person_id                 in number
  ,p_business_group_id         in number
  ,p_effective_date            in date
  ,p_lf_evt_ocrd_dt            in date
  ,p_pl_id                     in number
  ,p_pgm_id                    in number
  ,p_oipl_id                   in number
  ,p_plip_id                   in number
  ,p_ptip_id                   in number
  ,p_ler_id                    in number
  ,p_comp_rec                  in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_oiplip_rec                in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  --
  ,p_eligible                     out nocopy boolean
  ,p_not_eligible                 out nocopy boolean
  --
  ,p_newly_elig                   out nocopy boolean
  ,p_newly_inelig                 out nocopy boolean
  ,p_first_elig                   out nocopy boolean
  ,p_first_inelig                 out nocopy boolean
  ,p_still_elig                   out nocopy boolean
  ,p_still_inelig                 out nocopy boolean
  );
------------------------------------------------------------------------
END;

/
