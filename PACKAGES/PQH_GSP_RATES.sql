--------------------------------------------------------
--  DDL for Package PQH_GSP_RATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_RATES" AUTHID CURRENT_USER as
/* $Header: pqgsprat.pkh 120.2.12010000.1 2008/07/28 12:57:54 appldev ship $ */
  type t_grd_steps is record (
    grade_cer_id  number,
    plip_cer_id   number,
    num_steps     number,
    range         number,
    crset_id      number,
    point1_cer_id number,
    point2_cer_id number,
    point3_cer_id number,
    point4_cer_id number,
    point5_cer_id number);

  type t_gs_matx is table of t_grd_steps
   index by binary_integer ;

  type t_gs_rate is record (
    grade_cer_id  number,
    plip_cer_id   number,
    esd           date,
    eed           date,
    num_steps     number,
    range         number,
    crset_id      number,
    point1_cer_id number,
    point2_cer_id number,
    point3_cer_id number,
    point4_cer_id number,
    point5_cer_id number,
    point1_value  number,
    point2_value  number,
    point3_value  number,
    point4_value  number,
    point5_value  number);

  type t_gs_rate_matx is table of t_gs_rate
   index by binary_integer ;

  type t_pt_matx is table of date
   index by binary_integer ;

procedure build_gs_matrix(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_business_group_id  in number) ;
procedure update_gsrate(p_copy_entity_txn_id in number,
                        p_gsr_cer_id         in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_value1             in number,
                        p_value2             in number,
                        p_value3             in number,
                        p_value4             in number,
                        p_value5             in number,
                        p_datetrack_mode     in varchar2);
procedure build_gr_matrix(p_copy_entity_txn_id in number,
                          p_effective_date     in date,
                          p_crset_id           in number,
                          p_business_group_id  in number);
procedure update_grrate(p_copy_entity_txn_id in number,
                        p_grr_cer_id         in number,
                        p_effective_date     in date,
                        p_business_group_id  in number,
                        p_value1             in number,
                        p_value2             in number,
                        p_value3             in number,
                        p_value4             in number,
                        p_value5             in number,
                        p_datetrack_mode     in varchar2);
procedure update_crrate(p_crset_id           in number,
                        p_effective_date     in date,
                        p_copy_entity_txn_id in number,
                        p_datetrack_mode     in varchar2,
                        p_grade_cer_id       in number default null,
                        p_point_cer_id       in number default null,
                        p_new_value          in number);
procedure update_hrrate(p_old_hrrate_cer_id in number,
                        p_effective_date    in date,
                        p_value             in number,
                        p_datetrack_mode    in varchar2,
                        p_grd_min_value     in number default null,
                        p_grd_mid_value     in number default null,
                        p_grd_max_value     in number default null,
                        p_new_hrrate_cer_id out nocopy number);
procedure update_point_hrrate(p_copy_entity_txn_id in number,
                              p_rt_effective_date  in date,
                              p_gl_effective_date  in date,
                              p_business_group_id  in number,
                              p_hrrate_cer_id      in out nocopy number,
                              p_point_cer_id       in number,
                              p_point_value        in number,
                              p_datetrack_mode     in varchar2);
procedure update_grade_hrrate(p_copy_entity_txn_id in number,
                              p_rt_effective_date  in date,
                              p_gl_effective_date  in date,
                              p_business_group_id  in number,
                              p_hrrate_cer_id      in out nocopy number,
                              p_grade_cer_id       in number,
                              p_grd_value          in number,
                              p_grd_min_value      in number,
                              p_grd_mid_value      in number,
                              p_grd_max_value      in number,
                              p_datetrack_mode     in varchar2);
procedure create_grade_hrrate(p_copy_entity_txn_id in number,
                              p_effective_date     in date,
                              p_abr_id             in number,
                              p_abr_cer_id         in number,
                              p_pay_rule_id        in number,
                              p_grade_id           in number);
procedure create_point_hrrate(p_copy_entity_txn_id in number,
                              p_effective_date     in date,
                              p_abr_id             in number,
                              p_abr_cer_id         in number,
                              p_pay_rule_id        in number,
                              p_point_id           in number);
procedure sync_grrate(p_crset_id           in number,
                      p_copy_entity_txn_id in number);
procedure populate_old_values(p_copy_entity_txn_id in number);
end pqh_gsp_rates;

/
