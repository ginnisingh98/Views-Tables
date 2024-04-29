--------------------------------------------------------
--  DDL for Package BEN_DERIVE_PART_AND_RATE_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DERIVE_PART_AND_RATE_FACTS" AUTHID CURRENT_USER as
/* $Header: bendrpar.pkh 120.0.12000000.1 2007/01/19 15:55:20 appldev noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Derive Participation and Rate Factors
Purpose
	This package is used to derive the participation and rate factor
        information for a particular person for a particular program, plan
        or option.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        14 Dec 97        G Perry    110.0      Created.
        15 Dec 97        G Perry    110.1      Changed type of g_min_max_breach
                                               to a boolean so that we handle
                                               the breach logic differently.
                                               Made all functions public and
                                               made caching utility public.
        04 Jan 98        G Perry    110.2      Added exception g_record_error.
                                               Changed public interfaces to
                                               remove ler_id and oipl_id as
                                               these are not needed.
        05 Jan 98        G Perry    110.3      removed g_record_error
                                               exception as we now use the
                                               generic exception raised by
                                               the benmngle process.
        13 Jan 98        G Perry    110.4      Added extra parameter to
                                               cache function.
        24 Jan 98        G Perry    110.5      Now caching next years popl
                                               start date.
        06 Mar 98        G Perry    110.6      Added caching structures to
                                               store los and age details. This
                                               makes the run more performant.
        08 Apr 98        G Perry    110.7      Added get_calculated_age, added
                                               all FF stuff. Made code more
                                               reusable.
        20 Apr 98        G Perry    110.8      Now caching comb_age and
                                               comb_los.
        11 Apr 98        G Perry    110.9      Added cache structures so we
                                               only create temporal life
                                               events once.
        13 Jun 98        G Perry    110.10     Made clear_down_cache public.
        26 Aug 98        G Perry    115.4      Added cmbn_age_n_los_val into
                                               g_cache_details structure.
        28 Aug 98        G Perry    115.5      Removed cache where we store
                                               latest temporal life event date
                                               information.
        23 Nov 98        G Perry    115.6      Added rate information into
                                               cache. Added support for rates
                                               as well as factors.
        18 Jan 99        G Perry    115.8      LED V ED
        08 Feb 99        G Perry    115.9      Added in ptnl_ler_trtmt_cd in
                                               all procedures.
        17 Feb 99        G Perry    115.10     Added in once_r_cntug_cd and
                                               elig_flag into cache structure.
        21 Apr 99        G Perry    115.11     Added new procedure and function
                                               set_potential_ler_id
                                               get_potential_ler_id
        05 May 99        G Perry    115.12     Added support for PTIP, PLIP.
        15 Nov 99        S Tee      115.13     Added determine_cobra_eligibility.
        05-Feb-00        maagrawa   115.14     Data type of prtn_ovrid_thru_dt
                                               changed to date (Bug 1169243)
        26-Feb-00        mhoyes     115.15   - Added p_comp_obj_tree_row parameter
                                               to all routines which use
                                               ben_env_object comp object values.
        28-Feb-00        stee       115.16   - Added p_cbr_tmprl_evt_flag
                                               parameter.
        05-Mar-00        stee       115.17   - Added ptip_id to
                                               determine_cobra_eligibility.
        05-Mar-00        tmathers   115.18   - readded missing comment end
        24-Mar-00        gperry     115.19     Changed g_cache_structure for
                                               factor values to number else
                                               it truncs values implicitly due
                                               to number(15) type.
        31-Mar-00        gperry     115.20     Added oiplip support.
        26-Jun-00        stee       115.21     Added p_derivable_factors to
                                               derive_rate_and_factors
                                               procedure.  Removed
                                               p_cbr_tmprl_evt_flag.
        27-Jun-00        stee       115.21     Added p_derivable_factors to
                                               derive_rate_and_factors
                                               procedure.  Removed
                                               p_cbr_tmprl_evt_flag.
        27-Jun-00        mhoyes     115.22   - Added p_business_group_id to
                                               cache_data_structures.
                                             - Extended g_cache_structure for
                                               the elig per caches.
        30-Jun-00        mhoyes     115.23   - Added context parameters.
        13-Jul-00        mhoyes     115.24   - Added NOCOPYs.
        03-Aug-00        mhoyes     115.25   - Removed get_temporal_ler_id.
                                             - Commented out hr_utility statements
                                               were causing 1000000 executions in
                                               temporal mode for 25 people.
        07-Jan-01        mhoyes     115.26   - Made comp_calculation public.
        06-Apr-01        mhoyes     115.27   - Added p_calculate_only_mode for EFC.
        30-jan-02        tjesumic   115.28   - set_taxunit_context procedure added
                                               to set the tax_unit_context before calling
                                               per_balance_pkg.set_value, bug: 2180602
       01-feb-02         tjesumic   115.29     dbdrv fixed
       01-feb-02         tjesumic   115.30     dbdrv fixed
       01-jul-03         pabodla    115.31     Grade/Step Added global variables
                                               to support grade/step life event
                                               triggering.
       19-Aug-03         mmudigon   115.32     gscc fix
       11-Nov-03         ikasire    115.33     Added g_no_ptnl_ler_id for getting
                                               not to trigger potentials as part of
                                               U,W,M,P,I,A Modes BUG 3243960
--------------------------------------------------------------------------------
*/
--
type g_cache_structure is record
  (los_val                      number
  ,age_val                      number
  ,comp_ref_amt                 number
  ,hrs_wkd_val                  number
  ,pct_fl_tm_val                number
  ,cmbn_age_n_los_val           number
  ,age_uom                      varchar2(30)
  ,los_uom                      varchar2(30)
  ,comp_ref_uom                 varchar2(30)
  ,hrs_wkd_bndry_perd_cd        varchar2(30)
  ,frz_los_flag                 varchar2(30)
  ,frz_age_flag                 varchar2(30)
  ,frz_hrs_wkd_flag             varchar2(30)
  ,frz_cmp_lvl_flag             varchar2(30)
  ,frz_pct_fl_tm_flag           varchar2(30)
  ,frz_comb_age_and_los_flag    varchar2(30)
  ,rt_los_val                   number
  ,rt_age_val                   number
  ,rt_comp_ref_amt              number
  ,rt_hrs_wkd_val               number
  ,rt_pct_fl_tm_val             number
  ,rt_cmbn_age_n_los_val        number
  ,rt_age_uom                   varchar2(30)
  ,rt_los_uom                   varchar2(30)
  ,rt_comp_ref_uom              varchar2(30)
  ,rt_hrs_wkd_bndry_perd_cd     varchar2(30)
  ,rt_frz_los_flag              varchar2(30)
  ,rt_frz_age_flag              varchar2(30)
  ,rt_frz_hrs_wkd_flag          varchar2(30)
  ,rt_frz_cmp_lvl_flag          varchar2(30)
  ,rt_frz_pct_fl_tm_flag        varchar2(30)
  ,rt_frz_comb_age_and_los_flag varchar2(30)
  ,ovrid_svc_dt                 date
  ,prtn_ovridn_flag             varchar2(30)
  ,prtn_ovridn_thru_dt          date
  ,comb_age                     number
  ,comb_los                     number
  ,comb_rt_age                  number
  ,comb_rt_los                  number
  ,once_r_cntug_cd              varchar2(30)
  ,elig_flag                    varchar2(30)
  ,pgm_id                       number
  ,ptip_id                      number
  ,pl_id                        number
  ,plip_id                      number
  ,opt_id                       number
  ,prtn_strt_dt                 date
  ,prtn_end_dt                  date
  ,elig_per_opt_id              number
  ,object_version_number        number
  ,elig_per_id                  number
  ,per_in_ler_id                number
  ,pep_prtn_strt_dt             date
  ,pep_prtn_end_dt              date
  );
--
-- Variable which represents the cache data structure
--
g_cache_details  g_cache_structure;
--
-- GRADE/STEP :variables added for Grade/step.
g_prev_pgm_id      NUMBER;
g_pgm_typ_cd  varchar2(30);
g_gsp_ler_id       NUMBER;
g_gsp_ler_name     varchar2(600);
g_temp_ler_id NUMBER;
--Added to restrict triggering of potentials for Unrestricted LER
g_no_ptnl_ler_id      NUMBER;
--
FUNCTION comp_calculation
 (p_comp_obj_tree_row IN ben_manage_life_events.g_cache_proc_objects_rec
 ,p_empasg_row        IN per_all_assignments_f%ROWTYPE
 ,p_benasg_row        IN per_all_assignments_f%ROWTYPE
 ,p_curroiplip_row    IN ben_cobj_cache.g_oiplip_inst_row
 ,p_rec               IN ben_derive_part_and_rate_cache.g_cache_clf_rec_obj
 ,p_person_id         IN NUMBER
 ,p_business_group_id IN NUMBER
 ,p_pgm_id            IN NUMBER
 ,p_pl_id             IN NUMBER
 ,p_oipl_id           IN NUMBER
 ,p_oiplip_id         IN NUMBER
 ,p_plip_id           IN NUMBER
 ,p_ptip_id           IN NUMBER
 ,p_effective_date    IN DATE
 ,p_lf_evt_ocrd_dt    IN DATE
 ) RETURN NUMBER;
--
PROCEDURE derive_rates_and_factors
  (p_calculate_only_mode in     boolean default false
  ,p_comp_obj_tree_row   IN OUT NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  --
  -- Context info
  --
  ,p_per_row           IN OUT NOCOPY per_all_people_f%ROWTYPE
  ,p_empasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
  ,p_benasg_row        IN OUT NOCOPY per_all_assignments_f%ROWTYPE
  ,p_pil_row           IN OUT NOCOPY ben_per_in_ler%ROWTYPE
  --
  ,p_mode              IN            VARCHAR2 DEFAULT NULL
  --
  ,p_effective_date    IN            DATE
  ,p_lf_evt_ocrd_dt    IN            DATE
  ,p_person_id         IN            NUMBER
  ,p_business_group_id IN            NUMBER
  ,p_pgm_id            IN            NUMBER DEFAULT NULL
  ,p_pl_id             IN            NUMBER DEFAULT NULL
  ,p_oipl_id           IN            NUMBER DEFAULT NULL
  ,p_plip_id           IN            NUMBER DEFAULT NULL
  ,p_ptip_id           IN            NUMBER DEFAULT NULL
  ,p_ptnl_ler_trtmt_cd IN            VARCHAR2 DEFAULT NULL
  ,p_derivable_factors IN            VARCHAR2 DEFAULT 'ASC'
  ,p_comp_rec          IN OUT NOCOPY g_cache_structure
  ,p_oiplip_rec        IN OUT NOCOPY g_cache_structure
  );
-----------------------------------------------------------------------
procedure cache_data_structures
  (p_comp_obj_tree_row     in out NOCOPY ben_manage_life_events.g_cache_proc_objects_rec
  ,p_empasg_row            in out NOCOPY per_all_assignments_f%rowtype
  ,p_benasg_row            in out NOCOPY per_all_assignments_f%rowtype
  ,p_pil_row               in out NOCOPY ben_per_in_ler%rowtype
  ,p_business_group_id     in     number
  ,p_effective_date        in     date
  ,p_person_id             in     number
  ,p_pgm_id                in     number
  ,p_pl_id                 in     number
  ,p_oipl_id               in     number
  ,p_plip_id               in     number
  ,p_ptip_id               in     number
  ,p_comp_rec              in out NOCOPY g_cache_structure
  ,p_oiplip_rec            in out NOCOPY g_cache_structure
  );
-----------------------------------------------------------------------
procedure determine_cobra_eligibility
  (p_calculate_only_mode in     boolean default false
  ,p_person_id           in     number
  ,p_business_group_id   in     number
  ,p_pgm_id              in     number
  ,p_ptip_id             in     number default null
  ,p_ptnl_ler_trtmt_cd   in     varchar2
  ,p_effective_date      in     date
  ,p_lf_evt_ocrd_dt      in     date
  ,p_derivable_factors   in     varchar2
  );
-----------------------------------------------------------------------
procedure clear_down_cache;
-----------------------------------------------------------------------
procedure set_taxunit_context
  (p_person_id           in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  );
-----------------------------------------------------------------------
function get_latest_paa_id
  (p_person_id           in     number
  ,p_business_group_id   in     number
  ,p_effective_date      in     date
  ) return number;
-----------------------------------------------------------------------
end ben_derive_part_and_rate_facts;

 

/
