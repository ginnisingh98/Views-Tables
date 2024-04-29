--------------------------------------------------------
--  DDL for Package BEN_MAINTAIN_BENEFIT_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MAINTAIN_BENEFIT_ACTIONS" AUTHID CURRENT_USER AS
/* $Header: benbmbft.pkh 120.0 2005/05/28 03:43:58 appldev noship $ */
--
-- Local package types
--
type g_processes_table is table of number index by binary_integer;
--
g_processes_rec g_processes_table;
--
g_num_processes       number := 0;
--
PROCEDURE grab_next_batch_range
  (p_benefit_action_id      in     number
  --
  ,p_start_person_action_id    out nocopy number
  ,p_end_person_action_id      out nocopy number
  ,p_rows_found                out nocopy boolean
  );
--
procedure start_slaves
  (p_threads                  in number
  ,p_num_ranges               in number
  ,p_validate                 in varchar2
  ,p_benefit_action_id        in number
  ,p_effective_date           in varchar2
  ,p_pgm_id                   in number
  ,p_business_group_id        in number
  ,p_pl_id                    in number
  ,p_no_programs              in varchar2
  ,p_no_plans                 in varchar2
  ,p_rptg_grp_id              in number
  ,p_pl_typ_id                in number
  ,p_opt_id                   in number
  ,p_eligy_prfl_id            in number
  ,p_vrbl_rt_prfl_id          in number
  ,p_mode                     in varchar2
  ,p_person_selection_rule_id in number
  ,p_comp_selection_rule_id   in number
  ,p_derivable_factors        in varchar2
  ,p_cbr_tmprl_evt_flag       in varchar2
  ,p_lf_evt_ocrd_dt           in varchar2
  ,p_lmt_prpnip_by_org_flag   in varchar2
  ,p_gsp_eval_elig_flag       in varchar2 default null  -- GSP Rate Sync : Evaluate Eligibility
  ,p_lf_evt_oper_cd           in varchar2 default null  -- GSP Rate Sync : Life Event Operation code
  );
--
procedure check_slaves_status
  (p_num_processes in     number
  ,p_processes_rec in     ben_maintain_benefit_actions.g_processes_table
  ,p_master        in     varchar2
  ,p_slave_errored    out nocopy boolean
  );
--
procedure check_all_slaves_finished
  (p_benefit_action_id in     number
  ,p_business_group_id in     number
  ,p_slave_errored        out nocopy boolean
  );
--
PROCEDURE get_peractionrange_persondets
  (p_benefit_action_id      in            number
  ,p_start_person_action_id in            number
  ,p_end_person_action_id   in            number
  --
  ,p_personid_va            in out nocopy benutils.g_number_table
  ,p_pactid_va              in out nocopy benutils.g_number_table
  ,p_pactovn_va             in out nocopy benutils.g_number_table
  ,p_lerid_va               in out nocopy benutils.g_number_table
  );
--
END ben_maintain_benefit_actions;

 

/
