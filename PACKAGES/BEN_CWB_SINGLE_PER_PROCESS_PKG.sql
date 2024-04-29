--------------------------------------------------------
--  DDL for Package BEN_CWB_SINGLE_PER_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_SINGLE_PER_PROCESS_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbsp.pkh 120.2 2007/08/21 12:14:54 steotia noship $ */
--
-- --------------------------------------------------------------------------
-- |-----------------------------< process >--------------------------------|
-- --------------------------------------------------------------------------
--
procedure process
               (errbuf OUT NOCOPY VARCHAR2
               ,retcode OUT NOCOPY NUMBER
	       ,p_validate in varchar2 default 'Y'
	       ,p_search_date in varchar2
	       ,p_person_id in number
	       ,p_business_group in number
               ,p_group_pl_id in varchar2
	       ,p_lf_evt_dt_range in varchar2
               ,p_lf_evt_dt in varchar2
	       ,p_run_from_ss in varchar2 default 'N'
	       ,p_clone_all_data_flag in varchar2 default 'N'
	       ,p_backout_and_process_flag in varchar2 default 'N');
--
-- --------------------------------------------------------------------------
-- |-----------------------< recreate_error_stack >-------------------------|
-- --------------------------------------------------------------------------
--
procedure recreate_error_stack(p_request_id in number);
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
-- --------------------------------------------------------------------------
-- |----------------------< detect_method_and_warnings >---------------------|
-- --------------------------------------------------------------------------
--
procedure detect_method_and_warnings
               (p_person_id in number
               ,p_group_pl_id in number
               ,p_lf_evt_dt in date
               ,p_data_freeze_date in date
               ,p_search_date in date
               ,p_person_type out nocopy varchar2
               ,p_method out nocopy varchar2
               ,p_method_display out nocopy varchar2
               ,p_special_flag out nocopy varchar2
               ,p_start_date out nocopy varchar2
               ,p_term_date out nocopy varchar2
               ,p_no_payroll_warn out nocopy varchar2
               ,p_no_salary_warn out nocopy varchar2
               ,p_no_supervisor_warn out nocopy varchar2
               ,p_no_position_warn out nocopy varchar2
               ,p_no_paybasis_warn out nocopy varchar2
               ,p_past_term_warn out nocopy varchar2
               ,p_future_term_warn out nocopy varchar2
               ,p_curr_absence_warn out nocopy varchar2
               ,p_future_absence_warn out nocopy varchar2);

-- --------------------------------------------------------------------------
-- |----------------------< run_participation_process >---------------------|
-- --------------------------------------------------------------------------
-- This procedure calls ben_manage_cwb_life_events.global_online_process_w
-- for running the single person participation process. It returns back the
-- the following parameters.
--          Column                     Desc
--       p_group_per_in_ler_id   group_per_in_ler_id of the person
--       p_group_pl_name         group plan name
--       p_plan_name             plan name
--       p_prsrv_bdgt_cd         budgets storing method
--       p_period                period of plan
--       p_elig_satus            eligibility status
--       p_event_status          event status
--       p_pp_stat_cd            participation process status code
--       p_pl_id                 local plan for which the person is processed
--
procedure run_participation_process
               (p_validate                 in     varchar2 default 'N'
               ,p_effective_date           in     date
               ,p_person_id                in     number   default null
               ,p_business_group_id        in     number
               ,p_group_pl_id              in     number   default null
               ,p_lf_evt_ocrd_dt           in     date default null
               ,p_clone_all_data_flag      in     varchar2 default 'N'
               ,p_backout_and_process_flag in     varchar2 default 'N'
               ,p_group_per_in_ler_id      out nocopy number
               ,p_group_pl_name            out nocopy varchar2
               ,p_plan_name                out nocopy varchar2
               ,p_prsrv_bdgt_cd            out nocopy varchar2
               ,p_period                   out nocopy varchar2
               ,p_elig_status              out nocopy varchar2
               ,p_event_status             out nocopy varchar2
               ,p_pp_stat_cd               out nocopy varchar2
               ,p_pl_id                    out nocopy number);

end BEN_CWB_SINGLE_PER_PROCESS_PKG;


/
