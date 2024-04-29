--------------------------------------------------------
--  DDL for Package BEN_ELIG_SCRE_WTG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELIG_SCRE_WTG_API" AUTHID CURRENT_USER as
/* $Header: beeswapi.pkh 120.1 2005/06/17 09:40:58 abparekh noship $ */

procedure create_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               out nocopy number
  ,p_effective_date                 in date
  ,p_elig_per_id                    in number   default null
  ,p_elig_per_opt_id                in number   default null
  ,p_elig_rslt_id                   in number   default null
  ,p_per_in_ler_id                  in number   default null
  ,p_eligy_prfl_id                  in number
  ,p_crit_tab_short_name            in varchar2
  ,p_crit_tab_pk_id                 in number
  ,p_computed_score                 in number   default null
  ,p_benefit_action_id              in number   default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
);
procedure update_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_benefit_action_id              in number default hr_api.g_number
  ,p_computed_score                 in number   default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
);
procedure delete_perf_score_weight
(  p_validate                       in boolean    default false
  ,p_elig_scre_wtg_id               in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
);
procedure load_score_weight
(  p_validate                       in boolean    default false
  ,p_score_tab                      in ben_evaluate_elig_profiles.scoreTab
  ,p_elig_per_id                    in number   default null
  ,p_elig_per_opt_id                in number   default null
  ,p_elig_rslt_id                   in number   default null
  ,p_per_in_ler_id                  in number   default null
  ,p_effective_date                 in date
);

end BEN_ELIG_SCRE_WTG_API;

 

/
