--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_ELIGIBILITY4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_ELIGIBILITY4" AUTHID CURRENT_USER as
/* $Header: bendete4.pkh 120.0.12000000.2 2007/02/07 23:10:59 kmahendr noship $ */
  --
  g_debug boolean := hr_utility.debug_enabled;
  --
procedure prev_elig_check
  (p_person_id        in        number
  ,p_pgm_id           in        number
  ,p_pl_id            in        number
  ,p_ptip_id          in        number
  ,p_effective_date   in        date
  ,p_mode_cd          in        varchar2
  ,p_irec_asg_id      in        number
  --
  ,p_prev_eligibility      out nocopy boolean
  ,p_elig_per_id           out nocopy number
  ,p_elig_per_elig_flag    out nocopy varchar2
  ,p_prev_prtn_strt_dt     out nocopy date
  ,p_prev_prtn_end_dt      out nocopy date
  ,p_per_in_ler_id         out nocopy number
  ,p_object_version_number out nocopy number
  ,p_prev_age_val          out nocopy number
  ,p_prev_los_val          out nocopy number
  );
procedure prev_opt_elig_check
  (p_person_id        in        number
  ,p_effective_date   in        date
  ,p_pl_id            in        number
  ,p_opt_id           in        number
  ,p_mode_cd          in        varchar2
  ,p_irec_asg_id      in        number
  --
  ,p_prev_eligibility          out nocopy boolean
  ,p_elig_per_opt_id           out nocopy number
  ,p_opt_elig_flag             out nocopy varchar2
  ,p_prev_prtn_strt_dt         out nocopy date
  ,p_prev_prtn_end_dt          out nocopy date
  ,p_object_version_number_opt out nocopy number
  ,p_elig_per_id               out nocopy number
  ,p_per_in_ler_id             out nocopy number
  ,p_elig_per_prtn_strt_dt     out nocopy date
  ,p_elig_per_prtn_end_dt      out nocopy date
  ,p_prev_age_val          out nocopy number
  ,p_prev_los_val          out nocopy number
  );
end ben_determine_eligibility4;

 

/
