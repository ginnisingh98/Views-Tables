--------------------------------------------------------
--  DDL for Package PQH_GSP_HR_TO_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_HR_TO_STAGE" AUTHID CURRENT_USER as
/* $Header: pqgsphrs.pkh 120.1.12010000.1 2008/07/28 12:57:43 appldev ship $ */
g_master_txn_id number;
g_txn_id number;
procedure update_crset_type(p_copy_entity_txn_id in number,
                            p_crset_id           in number,
                            p_crset_type         in varchar2);
function get_grd_start_date(p_grade_cer_id in number) return date;
function get_abr_cer(p_copy_entity_txn_id in number,
                     p_pl_cer_id          in number default null,
                     p_opt_cer_id         in number default null,
                     p_effective_date     in date) return number;
procedure update_crset(p_crset_id           in number,
                       p_effective_date     in date,
                       p_crset_name         in varchar2,
                       p_copy_entity_txn_id in number,
                       p_datetrack_mode     in varchar2,
                       p_bu_cd              in varchar2 default null,
                       p_bu_name            in varchar2 default null,
                       p_fp_cd              in varchar2 default null,
                       p_fp_name            in varchar2 default null,
                       p_job_id             in number default null,
                       p_job_name           in varchar2 default null,
                       p_org_id             in number default null,
                       p_org_name           in varchar2 default null,
                       p_pt_id              in number default null,
                       p_pt_name            in varchar2 default null,
                       p_loc_id             in number default null,
                       p_loc_name           in varchar2 default null,
                       p_perf_rtng_cd       in varchar2 default null,
                       p_perf_rtng_name     in varchar2 default null,
                       p_event_type         in varchar2 default null,
                       p_event_name         in varchar2 default null,
                       p_sa_id              in number default null,
                       p_sa_name            in varchar2 default null,
                       p_ff_id              in number default null,
                       p_ff_name            in varchar2 default null);
procedure create_crset_row(p_crset_id           out nocopy number,
                           p_effective_date     in date,
                           p_copy_entity_txn_id in number,
                           p_bu_cd              in varchar2 default null,
                           p_bu_name            in varchar2 default null,
                           p_fp_cd              in varchar2 default null,
                           p_fp_name            in varchar2 default null,
                           p_job_id             in number default null,
                           p_job_name           in varchar2 default null,
                           p_org_id             in number default null,
                           p_org_name           in varchar2 default null,
                           p_pt_id              in number default null,
                           p_pt_name            in varchar2 default null,
                           p_loc_id             in number default null,
                           p_loc_name           in varchar2 default null,
                           p_perf_rtng_cd       in varchar2 default null,
                           p_event_type         in varchar2 default null,
                           p_perf_rtng_name     in varchar2 default null,
                           p_event_name         in varchar2 default null,
                           p_sa_id              in number default null,
                           p_sa_name            in varchar2 default null,
                           p_ff_id              in number default null,
                           p_ff_name            in varchar2 default null,
                           p_validate           in varchar2 default 'TRUE',
                           p_crset_type         in varchar2,
                           p_name               in varchar2);
procedure pull_elp_for_crset(p_elp_id             in number,
                             p_copy_entity_txn_id in number,
                             p_crset_type         in varchar2,
                             p_effective_date     in date,
                             p_business_group_id  in number,
                             p_crset_id           out nocopy number,
                             p_dup_crset          out nocopy varchar2);
function is_crrate_there(p_oipl_cer_id        in number default null,
                         p_plip_cer_id        in number default null,
                         p_pl_cer_id          in number default null,
                         p_point_cer_id       in number default null,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date) return varchar2;
procedure create_crrate_row(p_vpf_cer_id         in number default null,
                            p_abr_cer_id         in number ,
                            p_vpf_id             in number default null,
                            p_vpf_name           in varchar2 default null,
                            p_vpf_ovn            in number default null,
                            p_grade_cer_id       in number default null,
                            p_point_cer_id       in number default null,
                            p_copy_entity_txn_id in number,
                            p_business_group_id  in number,
                            p_effective_date     in date,
                            p_vpf_esd            in date,
                            p_vpf_eed            in date,
                            p_vpf_value          in number,
                            p_crset_id           in number,
                            p_dml_operation      in varchar2 default 'INSERT',
                            p_datetrack_mode     in varchar2 default 'INSERT',
                            p_elp_id             in number default null,
                            p_crr_cer_id         out nocopy number);
procedure create_crrate_row(p_grade_cer_id       in number default null,
                            p_point_cer_id       in number default null,
                            p_copy_entity_txn_id in number,
                            p_business_group_id  in number,
                            p_effective_date     in date,
                            p_vpf_value          in number,
                            p_crset_id           in number,
                            p_crr_cer_id         out nocopy number);
procedure update_txn_table_route(p_copy_entity_txn_id in number);
procedure get_table_route_details(p_table_alias    in varchar2,
                                  p_table_route_id out nocopy number ,
                                  p_table_name     out nocopy varchar2 );
Procedure grade_to_pl_stage(p_grade_id         in number,
                            p_pl_cer_id        in number,
                            p_effective_date   in date);
Procedure scale_to_stage(p_scale_id           in number,
                         p_business_group_id  in number,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                         p_scale_cer_id          out nocopy number);
procedure get_point_rate_values(p_effective_date in date,
                                p_opt_id         in number,
                                p_point_id       in number,
                                p_point_value    out nocopy number);
procedure step_to_oipl_stage(p_copy_entity_txn_id in number,
                             p_oipl_id            in number,
                             p_step_id            in number,
                             p_oipl_cer_id        in number,
                             p_parent_cer_id      in number,
                             p_effective_date     in date,
                             p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure populate_pgm_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_pgm_id             in number);
procedure hrate_to_stage(p_abr_cer_id         in number,
                         p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_abr_id             in number,
                         p_parent_cer_id      in number);
procedure point_to_opt_stage(p_copy_entity_txn_id in number,
                             p_option_id          in number,
                             p_opt_cer_id         in number,
                             p_effective_date     in date,
                             p_business_group_id  in number,
                             p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
Procedure grade_to_plip_stage(p_grade_id       in number,
                              p_plip_cer_id    in number,
                              p_pl_cer_id      in number,
                              p_parent_cer_id  in number,
                              p_mirror_ser_id  in number,
                              p_effective_date in date,
                              p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure create_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure create_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_gl_exists          in varchar2,
                                 p_sal_exists         in varchar2,
                                 p_grd_exists         in varchar2,
                                 p_step_exists        in varchar2,
                                 p_rate_exists        in varchar2,
                                 p_rule_exists        in varchar2);
procedure hr_to_stage(p_copy_entity_txn_id in number,
                      p_start_cer_id  in number default null,
                      p_effective_date in date,
                      p_business_group_id in number,
                      p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure start_gsp_txn(p_copy_entity_txn_id    out nocopy number
                       ,p_business_group_id     in number
                       ,p_name                  in varchar2
                       ,p_effective_date        in date
                       ,p_status                in varchar2
                       ,p_business_area         in varchar2 default 'PQH_GSP_TASK_LIST'
                       ,p_object_version_number out nocopy number) ;
procedure update_gsp_control_rec(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST');
procedure update_GL(p_pgm_id             in number,
                    p_action_type        in varchar2 default 'REFRESH',
                    p_pgm_name           in varchar2,
                    p_effective_date     in date,
                    p_business_group_id  in number,
                    p_user_id            in number,
                    p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                    p_copy_entity_txn_id out nocopy number );
procedure update_or_view_GL(p_calling_mode       in varchar2,
                            p_action_type        in varchar2 default 'REFRESH',
                            p_pgm_id             in number,
                            p_pgm_name           in varchar2,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_user_id            in number,
                            p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                            p_copy_entity_txn_id out nocopy number);
procedure get_step_all_details(p_point_id       in number,
                               p_grade_id       in number,
                               p_option_id      in number,
                               p_effective_date in date,
                               p_point_name     out nocopy varchar2,
                               p_step_name      out nocopy varchar2,
                               p_step_id        out nocopy number,
                               p_step_ovn       out nocopy number,
                               p_grade_spine_id out nocopy number,
                               p_ceiling_flag   out nocopy varchar2,
                               p_point_value    out nocopy number,
                               p_scale_id       out nocopy number);
procedure populate_pl_hierarchy(p_copy_entity_txn_id in number,
                                p_effective_date     in date,
                                p_business_group_id  in number,
                                p_plip_cer_id        in number,
                                p_pl_id              in number,
                                p_mode               in varchar2 default 'COMPLETE',
                                p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                p_pl_cer_id          out nocopy number);
procedure populate_ep_hierarchy(p_copy_entity_txn_id in number,
                                p_effective_date     in date,
                                p_business_group_id  in number,
                                p_ep_id              in number,
                                p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                p_ep_cer_id          out nocopy number);
procedure populate_opt_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_opt_id             in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_opt_cer_id         out nocopy number);
procedure populate_scale_hierarchy(p_copy_entity_txn_id in number,
                                   p_effective_date     in date,
                                   p_business_group_id  in number,
                                   p_scale_id           in number,
                                   p_mode               in varchar2 default 'COMPLETE',
                                   p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                   p_scale_cer_id       out nocopy number);
procedure get_grade_scale_details(p_grade_id       in number,
                                  p_scale_id       in number,
                                  p_effective_date in date,
                                  p_ceiling_step_id out nocopy number,
                                  p_grade_spine_id  out nocopy number,
                                  p_starting_step out nocopy number);
procedure get_grd_scale_details(p_grade_id in number,
                                p_effective_date in date,
                                p_scale_id          out nocopy number,
                                p_ceiling_step_id   out nocopy number,
                                p_grade_spine_ovn   out nocopy number,
                                p_grade_spine_id    out nocopy number,
                                p_scale_ovn         out nocopy number,
                                p_scale_name        out nocopy varchar2,
                                p_starting_step     out nocopy number);
procedure vpf_to_stage(p_vpf_cer_id         in number,
                       p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_result_type_cd     in varchar2);
function get_plan_for_grade(p_grade_id  in number,
                            p_effective_date in date) return number;
function get_grade_for_plan(p_plan_id  in number,
                            p_effective_date in date) return number;
procedure create_option_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_business_group_id  in number,
                            p_scale_id           in number,
                            p_scale_cer_id       in number,
                            p_point_id           in number,
                            p_dml_operation      in varchar2 default 'INSERT',
                            p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                            p_opt_cer_id         out nocopy number,
                            p_opt_cer_ovn        out nocopy number);
function is_scale_exists_in_txn(p_copy_entity_txn_id in number,
                                p_scale_id           in number) return number;
function is_option_exists_in_txn(p_copy_entity_txn_id in number,
                                 p_opt_id             in number) return number;
function is_hrrate_for_abr_exists(p_copy_entity_txn_id in number,
                                  p_abr_id             in number) return boolean;
function is_grd_exists_in_txn(p_copy_entity_txn_id in number,
                              p_grd_id              in number) return number;
function is_pl_exists_in_txn(p_copy_entity_txn_id in number,
                             p_pl_id              in number) return number;
function is_ep_exists_in_txn(p_copy_entity_txn_id in number,
                             p_start_cer          in number,
                             p_ep_id              in number) return number;
function is_point_exists_in_txn(p_copy_entity_txn_id in number,
                                p_point_id           in number) return number;
function get_point_for_step(p_step_id        in number,
                            p_effective_date in date) return number;
function get_point_for_opt(p_option_id      in number,
                           p_effective_date in date) return number;
function get_opt_for_point(p_point_id       in number,
                           p_effective_date in date) return number;
function get_step_for_oipl(p_oipl_id in number,
                           p_effective_date in date) return number;
function get_oipl_for_step(p_step_id in number,
                           p_effective_date in date) return number;
procedure get_grade_for_plip(p_plip_id        in number,
                             p_effective_date in date,
                             p_plan_id           out nocopy number,
                             p_grade_id          out nocopy number);
procedure create_oipl_row(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_grade_id           in number,
                          p_plip_cer_id        in number,
                          p_point_id           in number,
                          p_point_cer_id       in number,
                          p_option_id          in number,
                          p_scale_cer_id       in number,
                          p_dml_operation      in varchar2 default 'INSERT',
                          p_oipl_cer_id        out nocopy  number);
procedure populate_grd_hierarchy(p_copy_entity_txn_id in number,
                                 p_effective_date     in date,
                                 p_business_group_id  in number,
                                 p_grade_id           in number,
                                 p_grade_name         in varchar2,
                                 p_pgm_cer_id         in number,
                                 p_in_pl_cer_id       in number,
                                 p_business_area      in varchar2 default 'PQH_GSP_TASK_LIST',
                                 p_out_pl_cer_id      out nocopy number,
                                 p_plip_cer_id        out nocopy number,
                                 p_scale_cer_id       out nocopy number);
procedure create_plan_row(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number,
                          p_grade_id           in number,
                          p_plip_cer_id        in number,
                          p_dml_operation      in varchar2 default 'INSERT',
                          p_pl_cer_id          out nocopy number,
                          p_pl_cer_ovn         out nocopy number);
procedure create_abr_row(p_copy_entity_txn_id in number,
                         p_start_date         in date,
                         p_pl_cer_id          in number default null,
                         p_opt_cer_id         in number default null,
                         p_business_group_id  in number,
                         p_effective_date     in date,
                         p_abr_cer_id         out nocopy number,
                         p_create_hrr         in varchar2 default 'N',
                         p_dml_oper           in varchar2);
procedure create_hrrate_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_start_date         in date,
                            p_business_group_id  in number,
                            p_abr_cer_id         in number,
                            p_grade_cer_id       in number,
                            p_grd_value          in number,
                            p_grd_min_value      in number,
                            p_grd_mid_value      in number,
                            p_grd_max_value      in number,
                            p_dml_oper           in varchar2,
                            p_hrrate_cer_id      out nocopy number);
procedure create_hrrate_row(p_copy_entity_txn_id in number,
                            p_effective_date     in date,
                            p_start_date         in date,
                            p_business_group_id  in number,
                            p_abr_cer_id         in number,
                            p_point_cer_id       in number,
                            p_point_value        in number,
                            p_dml_oper           in varchar2,
                            p_hrrate_cer_id      out nocopy number);
function is_step_exists_in_txn(p_copy_entity_txn_id in number,
                               p_step_id            in number,
                               p_option_id          in number,
                               p_pl_id              in number) return number;
procedure pull_payrate(p_copy_entity_txn_id in number,
                       p_payrate_id         in number,
                       p_effective_date     in date);
procedure update_frps_point_rate(p_point_cer_id       in number,
                                 p_copy_entity_txn_id in number,
                                 p_business_group_id  in number,
                                 p_point_value        in number,
                                 p_effective_date     in date);
function get_co_std_rate(p_plan_id in number default null,
                         p_opt_id in number default null,
                         p_effective_date in date,
                         p_pay_rule_id out nocopy number) return number;
procedure create_payrate(p_copy_entity_txn_id in number,
                       p_effective_date     in date,
                       p_business_group_id in number);
function get_plip_for_pgm_plan(p_pgm_id        in number,
                                p_plan_id       in number,
                                p_effective_date in date
                               ) return number;
end pqh_gsp_hr_to_stage;

/
