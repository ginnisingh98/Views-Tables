--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_ELIG_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_ELIG_PROFILES" AUTHID CURRENT_USER as
/* $Header: benevlpr.pkh 120.0.12010000.1 2008/07/29 12:23:36 appldev ship $ */

Type profrec is record
(eligy_prfl_id            number,
 mndtry_flag              varchar2(1),
 compute_score_flag       varchar2(1),
 trk_scr_for_inelg_flag   varchar2(1));
Type profTab is Table of profRec index by binary_integer;
t_prof_tbl profTab;

Type scoreRec is Record
(eligy_prfl_id         number,
 crit_tab_short_name   varchar2(30),
 crit_tab_pk_id        number,
 computed_score        number,
 benefit_action_id     number);
Type scoreTab is Table of scoreRec index by binary_integer;
t_default_score_tbl scoreTab; --dummy. used as default param only

g_eligible        exception;
g_criteria_failed exception;
g_skip_profile    exception;
g_not_eligible    exception;
g_inelg_rsn_cd    varchar2(30);

l_dpr_rec ben_derive_part_and_rate_facts.g_cache_structure := null;

procedure write(p_score_tab         in out nocopy scoreTab,
                p_eligy_prfl_id     number,
                p_tab_short_name    varchar2,
                p_pk_id             number,
                p_computed_score    number);

procedure write(p_profile_score_tab     in out nocopy scoreTab,
                p_crit_score_tab        in scoreTab);

-- -----------------------------------------------------------------------------
-- |------------------------------< eligible >---------------------------------|
-- -----------------------------------------------------------------------------
--
-- Main function
function eligible
  (p_person_id                 in number
  ,p_assignment_id             in number default null
  ,p_business_group_id         in number
  ,p_effective_date            in date
  ,p_eligprof_tab              in proftab default t_prof_tbl
  ,p_vrbl_rt_prfl_id           in number  default null
  ,p_lf_evt_ocrd_dt            in date   default null
  ,p_dpr_rec                   in ben_derive_part_and_rate_facts.g_cache_structure default l_dpr_rec
  ,p_per_in_ler_id             in number default null
  ,p_ler_id                    in number default null
  ,p_pgm_id                    in number default null
  ,p_ptip_id                   in number default null
  ,p_plip_id                   in number default null
  ,p_pl_id                     in number default null
  ,p_oipl_id                   in number default null
  ,p_oiplip_id                 in number default null
  ,p_pl_typ_id                 in number default null
  ,p_opt_id                    in number default null
  ,p_par_pgm_id                in number default null
  ,p_par_plip_id               in number default null
  ,p_par_pl_id                 in number default null
  ,p_par_opt_id                in number default null
  ,p_currepe_row               in ben_determine_rates.g_curr_epe_rec default ben_determine_rates.g_def_curr_epe_rec
  ,p_asg_status                in varchar2 default 'EMP'
  ,p_ttl_prtt                  in number   default null
  ,p_ttl_cvg                   in number   default null
  ,p_all_prfls                 in boolean  default false
  ,p_eval_typ                  in varchar2 default 'E'
  ,p_comp_obj_mode             in boolean default true
  ,p_score_tab                 out nocopy scoreTab
  ) return boolean;

end ben_evaluate_elig_profiles;

/
