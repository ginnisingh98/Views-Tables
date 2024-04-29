--------------------------------------------------------
--  DDL for Package BEN_CAGR_CHECK_ELIGIBILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CAGR_CHECK_ELIGIBILITY" AUTHID CURRENT_USER AS
/* $Header: bendtlca.pkh 120.0 2005/05/28 04:15:40 appldev noship $ */
--
procedure check_gndr_elig
  (p_eligy_prfl_id     in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date    in date
  ,p_per_sex           in varchar2
  );
--
procedure check_mrtl_sts_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_mar_status   in varchar2
  );
--
procedure check_dsblty_ctg_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_dsblty_ctg   in varchar2
  );
--
procedure check_dsblty_rsn_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_per_dsblty_rsn   in varchar2
  );
--
procedure check_dsblty_dgr_elig
  (p_eligy_prfl_id     in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date    in date
  ,p_per_degree        in number
  );
--
procedure check_suppl_role_elig
  (p_eligy_prfl_id    in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date   in date
  ,p_asg_job_id       in number
  ,p_asg_job_group_id in number
  );
--
procedure check_qual_titl_elig
  (p_eligy_prfl_id   in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date  in date
  ,p_per_qual_title  in varchar2
  ,p_per_qual_typ_id in number
  );
--
procedure check_pstn_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_asg_position_id   in varchar2
  );
--
procedure check_prbtn_perd_elig
  (p_eligy_prfl_id  in     number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in     date
  ,p_asg_prob_perd  in     number
  ,p_asg_prob_unit  in     varchar2
  );
--
procedure check_sp_clng_prg_elig
  (p_eligy_prfl_id  in number
  ,p_score_compute_mode in boolean default false
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_effective_date in date
  ,p_asg_sps_id   in varchar2
  );
--
procedure check_cagr_elig_profiles
  (p_eligprof_dets    in     ben_cep_cache.g_cobcep_cache_rec
  ,p_effective_date   in     date
  --
  ,p_person_id        in     number
  ,p_score_compute_mode in     boolean
  ,p_profile_score_tab in out nocopy ben_evaluate_elig_profiles.scoreTab
  ,p_per_sex          in     varchar2
  ,p_per_mar_status   in     varchar2
  ,p_per_qualification_type_id   in     varchar2 default null
  ,p_per_title        in     varchar2 default null
  ,p_asg_job_id       in     number
  ,p_asg_position_id  in     number
  ,p_asg_prob_perd    in     number
  ,p_asg_prob_unit    in     varchar2
  ,p_asg_sps_id       in     number
  );
--
END ben_cagr_check_eligibility;

 

/
