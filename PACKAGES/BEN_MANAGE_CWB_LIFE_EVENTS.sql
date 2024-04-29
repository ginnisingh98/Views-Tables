--------------------------------------------------------
--  DDL for Package BEN_MANAGE_CWB_LIFE_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_CWB_LIFE_EVENTS" AUTHID CURRENT_USER as
/* $Header: bencwbcm.pkh 120.6.12000000.1 2007/01/19 15:22:40 appldev noship $ */
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Manage Life Events
Purpose
	This package is used to handle cwb pre-benmngle process and post
        benmngle cwb relevent actions like populating the cross business group
        and other hierarchy data.
History
Date             Who        Version    What?
----             ---        -------    -----
19 Dec 03        pbodla/
                 Indrasen   115.0      Created.
22 Dec 03        Indrase    115.1      Added new procedure and
                                       globals.
05 Jan 05        Pbodla     115.2      Added CWB table record structures
07 Jan 03        pbodla     115.5      Added code to populate cwb_rates
09 Jan 03        pbodla     115.6      Added code for auto budget issue
17 Jan 03        pbodla     115.8      Added code to populate missing pils
                 ikasire               Added p_group_pl_id to get_group_plan_info
05 Feb 04        ikasire    115.9      Added online call- new procedure
                                       global_online_process_w
25 Feb 04        pbodla     115.10     Added params p_no_person_rates,
                                                    p_no_person_groups for the
                                       populate_cwb_rates procedure.
26 Feb 04        ikasire    115.11     rebuild_heirarchy externalised
21 Jul 04        pbodla     115.12     Added logic for single person run.
                                       Procedures modified are :
                                       popu_cwb_tables, popu_cwb_group_pil_data
21 Jul 04        pbodla     115.12     Added p_use_eff_dt_flag to
                                       global_online_process_w, if front end
                                       takes the decision to take full control
                                       to clone data then this flag is passed
                                       as Y.
08 oct 04        pbodla     115.14     Added extra parameters to
                                       global_online_process_w, to handle
                                       backout.
01 nov 04        pbodla     115.15     Added global g_options_exists
                                       Added procedure
                                       sum_oipl_rates_and_upd_pl_rate
                                       Bug : 3968065
01 nov 04        pbodla     115.16
06-Dec-04       bmanyam     115.17     Bug: 3979082. Added hrchy_ame_trn_cd and hrchy_rl
                                       to g_cache_group_plan_type
14-Dec-04       pbodla      115.18     bug 4040013 - g_options_exists is defaulted to null.
21-Feb-05       pbodla      115.19     bug 4198404 - Added record structure
                                       g_error_log_rec_type to log proper
                                       error messages.
 03-Jan-06      nhunur       115.20    cwb - changes for person type param.
 08-Feb-06      abparekh     115.21    Bug 4875181 - Added p_run_rollup_only to global_process
 08-Feb-06      mmudigon     115.22    CWB Multi currency support. Added
                                            procs() exec_element_det_rl and
                                            get_abr_ele_inp
                                            determine_curr_code
 08-Feb-06      pbodla/stee  115.22    CWB Multi currency support. Added
                                            determine_curr_code
 16-Mar-06      nhunur       115.23     Made exec_element_det_rl public.
 24-Mar-06      maagrawa     115.24     GSCC nocopy error fixed.
 22-May-06      pbodla       115.25     Bug 5232223 - Added code to handle the trk inelig flag
                                        If trk inelig flag is set to N at group plan level
                                        then do not create cwb per in ler and all associated data.
*/
--------------------------------------------------------------------------------
--
--
g_trk_inelig_flag     varchar2(1);
type g_cwb_processes_table is table of number index by binary_integer;
g_cwb_processes_rec g_cwb_processes_table;
g_num_cwb_processes       number := 0;
type g_cache_group_plan_type is record
  (group_pl_id             ben_pl_f.pl_id%type,
   group_lf_evt_ocrd_dt    date,
   group_ler_id            ben_ler_f.ler_id%type,
   group_business_group_id number,
   hrchy_to_use_cd         varchar2(30),
   pos_structure_version_id number,
   group_per_in_ler_id     number,
   access_cd               varchar2(30),
   plans_wthn_group_pl     number,
   end_dt                  date,
   auto_distr_flag         varchar2(30),
   ws_upd_strt_dt          date,
   ws_upd_end_dt           date,
   uses_bdgt_flag          varchar2(30),
   hrchy_ame_trn_cd        varchar2(30),
   hrchy_rl                number,
   -- Bug 5232223
   trk_inelig_per_flag     varchar2(30));
--
g_cwb_person_groups_rec          ben_cwb_person_groups%ROWTYPE;
g_cwb_person_rates_rec           ben_cwb_person_rates%ROWTYPE;
g_cwb_person_groups_rec_temp     ben_cwb_person_groups%ROWTYPE;
g_cwb_person_rates_rec_temp      ben_cwb_person_rates%ROWTYPE;
g_options_exists                 boolean;
--
g_cache_group_plan_rec g_cache_group_plan_type;
--
type g_cache_cpg_rec_table is table of ben_cwb_person_groups%rowtype index
  by binary_integer;
--
g_cache_cpg_rec          g_cache_cpg_rec_table;
--
-- Structure for Error logging .
--
type g_error_log_rec_type is record
  (group_pl_id             ben_pl_f.pl_id%type,
   group_lf_evt_ocrd_dt    date,
   person_id               number,
   assignment_id           number,
   mgr_person_id           number,
   group_per_in_ler_id     number,
   step_number             number,
   calling_proc            varchar2(200));
--
g_error_log_rec g_error_log_rec_type;
-----------------------------------------------------------------------
procedure popu_group_pil_heir(p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number);

--
procedure get_group_plan_info(p_pl_id    in number,
                              p_lf_evt_ocrd_dt in date,
                              p_business_group_id    in number default null,
                             -- 9999IK Not required if we only run for group pl
                              p_group_pl_id in number default null
);
--
procedure popu_cwb_tables(
                        p_group_per_in_ler_id in number,
                        p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number,
                        p_use_eff_dt_flag      in varchar2 default 'N',
                        p_effective_date       in date default null);
--
procedure get_cwb_manager_and_assignment
             (p_person_id in number,
              p_hrchy_to_use_cd in varchar2,
              p_pos_structure_version_id in number,
              p_effective_date in date,
              p_manager_id out nocopy number,
              p_assignment_id out nocopy number );
-----------------------------------------------------------------------
procedure global_process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_mode                     in     varchar2 default 'W'
  ,p_derivable_factors        in     varchar2 default 'ASC'
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_pgm_id                   in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_lf_evt_ocrd_dt           in     varchar2 default null
  ,p_person_type_id           in     number   default null
  ,p_no_programs              in     varchar2 default 'N'
  ,p_no_plans                 in     varchar2 default 'N'
  ,p_comp_selection_rule_id   in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_pstl_zip_rng_id          in     number   default null
  ,p_rptg_grp_id              in     number   default null
  ,p_pl_typ_id                in     number   default null
  ,p_opt_id                   in     number   default null
  ,p_eligy_prfl_id            in     number   default null
  ,p_vrbl_rt_prfl_id          in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_commit_data              in     varchar2 default 'Y'
  ,p_audit_log_flag           in     varchar2 default 'N'
  ,p_lmt_prpnip_by_org_flag   in     varchar2 default 'N'
  ,p_cbr_tmprl_evt_flag       in     varchar2 default 'N'
  ,p_trace_plans_flag         in     varchar2 default 'N'
  ,p_online_call_flag         in     varchar2 default 'N'
  ,p_clone_all_data_flag      in     varchar2 default 'N'
  ,p_cwb_person_type          in     varchar2 default NULL
  ,p_run_rollup_only          in     varchar2 default 'N'     /* Bug 4875181 */
  );
--
-----------------------------------------------------------------------
procedure populate_cwb_rates(
           --
           -- Columns needed for ben_cwb_person_rates
           --
           p_person_id        in     number
          ,p_assignment_id    in     number   default null
          ,p_organization_id  in     number   default null
          ,p_pl_id            in     number
          ,p_oipl_id          in     number   default null
          ,p_opt_id           in     number   default null
          ,p_ler_id           in     number   default null
          ,p_business_group_id in    number   default null
          ,p_acty_base_rt_id   in    number   default null
          ,p_elig_flag        in     varchar2 default 'Y'
          ,p_inelig_rsn_cd    in     varchar2 default null
          --
          -- Columns needed by BEN_CWB_PERSON_GROUPS
          --
          ,p_due_dt           in     date     default null
          ,p_access_cd        in     varchar2 default null
          ,p_elig_per_elctbl_chc_id in number   default null
          ,p_no_person_rates  in     varchar2 default null
          ,p_no_person_groups in     varchar2 default null
          ,p_currency_det_cd  in     varchar2 default null
          ,p_element_det_rl   in     number   default null
          ,p_base_element_type_id in number   default null
       );
-----------------------------------------------------------------------
procedure popu_cwb_group_pil_data (
                        p_group_per_in_ler_id in number,
                        p_group_pl_id    in number,
                        p_group_lf_evt_ocrd_dt in date,
                        p_group_business_group_id    in number,
                        p_group_ler_id         in number,
                        p_use_eff_dt_flag      in varchar2 default 'N',
                        p_effective_date       in date default null);
----------------------------------------------------------------------
procedure global_online_process_w
  (
   p_effective_date           in     date
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_business_group_id        in     number
  ,p_pl_id                    in     number   default null
  ,p_lf_evt_ocrd_dt           in     date default null
  ,p_clone_all_data_flag      in     varchar2 default 'N'
  ,p_backout_and_process_flag in     varchar2 default 'N'
  );
----------------------------------------------------------------------
procedure rebuild_heirarchy
  (p_group_per_in_ler_id in number ) ;
----------------------------------------------------------------------
----------------------------------------------------------------------
procedure sum_oipl_rates_and_upd_pl_rate (
            p_pl_id          in number,
            p_group_pl_id    in number,
            p_lf_evt_ocrd_dt in date,
            p_person_id      in number,
            p_assignment_id  in number
            );
----------------------------------------------------------------------
procedure auto_allocate_budgets (
            p_pl_id          in number default null,
            p_group_pl_id    in number,
            p_lf_evt_ocrd_dt in date,
            p_person_id      in number default null,
            p_assignment_id  in number default null
            );
----------------------------------------------------------------------
procedure determine_curr_code
           (p_element_det_rl           number    default null,
            p_acty_base_rt_id          number    default null,
            p_currency_det_cd          varchar2  default null,
            p_base_element_type_id     number    default null,
            p_effective_date           date,
            p_assignment_id            number    default null,
            p_organization_id          number    default null,
            p_business_group_id        number    default null,
            p_pl_id                    number    default null,
            p_opt_id                   number    default null,
            p_ler_id                   number    default null,
            p_element_type_id      out nocopy number,
            p_input_value_id       out nocopy number,
            p_currency_cd          out nocopy varchar2);
----------------------------------------------------------------------
procedure get_abr_ele_inp
           (p_person_id                 number,
            p_acty_base_rt_id           number,
            p_effective_date            date,
            p_element_type_id_in        number default null,
            p_input_value_id_in         number default null,
            p_pl_id                     number default null,
            p_element_type_id_out  out  nocopy number,
            p_input_value_id_out   out  nocopy number );
----------------------------------------------------------------------
procedure exec_element_det_rl
           (p_element_det_rl           number    default null,
            p_acty_base_rt_id          number    default null,
            p_effective_date           date,
            p_assignment_id            number    default null,
            p_organization_id          number    default null,
            p_business_group_id        number    default null,
            p_pl_id                    number    default null,
            p_ler_id                   number    default null,
            p_element_type_id      out nocopy number,
            p_input_value_id       out nocopy number,
            p_currency_cd          out nocopy varchar2);
----------------------------------------------------------------------
end ben_manage_cwb_life_events;

 

/
