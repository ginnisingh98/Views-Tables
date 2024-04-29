--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ELIGIBILITY2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ELIGIBILITY2" AUTHID CURRENT_USER as
/* $Header: bendete2.pkh 120.2.12000000.1 2007/01/19 15:44:46 appldev noship $ */
  --
  g_package varchar2(50):= 'ben_determine_eligibility2.';
  g_debug boolean := hr_utility.debug_enabled;
  --
procedure check_prev_elig
  (p_comp_obj_tree_row       in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_per_row                 in out NOCOPY per_all_people_f%rowtype
  ,p_empasg_row              in out NOCOPY per_all_assignments_f%rowtype
  ,p_benasg_row              in out NOCOPY per_all_assignments_f%rowtype
  ,p_pil_row                 in out NOCOPY ben_per_in_ler%rowtype
  ,p_person_id               in     number
  ,p_business_group_id       in     number
  ,p_effective_date          in     date
  ,p_lf_evt_ocrd_dt          in     date
  ,p_pl_id                   in     number
  ,p_pgm_id                  in     number
  ,p_oipl_id                 in     number
  ,p_plip_id                 in     number
  ,p_ptip_id                 in     number
  ,p_ler_id                  in     number
  ,p_comp_rec                in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_oiplip_rec              in out NOCOPY ben_derive_part_and_rate_facts.g_cache_structure
  ,p_inelg_rsn_cd            in     varchar2
  --
  ,p_elig_flag               in out nocopy boolean
  ,p_newly_elig                 out nocopy boolean
  ,p_newly_inelig               out nocopy boolean
  ,p_first_elig                 out nocopy boolean
  ,p_first_inelig               out nocopy boolean
  ,p_still_elig                 out nocopy boolean
  ,p_still_inelig               out nocopy boolean
  ,p_score_tab               in ben_evaluate_elig_profiles.scoreTab default ben_evaluate_elig_profiles.t_default_score_tbl
  );

END;

 

/
