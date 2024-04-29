--------------------------------------------------------
--  DDL for Package PQH_CPD_HR_TO_STAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CPD_HR_TO_STAGE" AUTHID CURRENT_USER as
/* $Header: pqcpdhrs.pkh 120.0 2005/05/29 01:44 appldev noship $ */
function get_crpth_hier_ver return number;
procedure corps_to_stage(p_copy_entity_txn_id in number,
                         p_pgm_id             in number,
                         p_effective_date     in date,
                         p_pgm_cer_id         in number);
function check_cpd_row(p_copy_entity_txn_id in number) return varchar2;
function check_cdd_row(p_copy_entity_txn_id in number) return varchar2;
procedure get_scale_ddf_det(p_scale_id             in number,
                            p_information_category    out nocopy varchar2,
                            p_information1            out nocopy varchar2,
                            p_information2            out nocopy varchar2);
procedure get_point_details(p_point_id             in number,
                            p_information_category    out nocopy varchar2,
                            p_information1            out nocopy varchar2,
                            p_information2            out nocopy varchar2,
                            p_information3            out nocopy varchar2,
                            p_information4            out nocopy varchar2,
                            p_information5            out nocopy varchar2);
procedure get_corp(p_pgm_cer_id in number,
                   p_corps_id      out nocopy number,
                   p_cet_id        out nocopy number);
procedure get_grd_quota(p_pgm_cer_id          in number,
                        p_grade_id            in number,
                        p_corps_definition_id in number,
                        p_cet_id              in number,
                        p_perc_quota          out nocopy number,
                        p_population_cd       out nocopy varchar2,
                        p_comb_grade          out nocopy varchar2,
                        p_max_speed_quota     out nocopy number,
                        p_avg_speed_quota     out nocopy number,
                        p_corps_extra_info_id out nocopy number);
procedure stage_to_corps(p_copy_entity_txn_id in number,
                         p_effective_date     in date,
                         p_business_group_id  in number,
                         p_datetrack_mode     in varchar2);
procedure grd_quota_update(p_effective_date      in date,
                           p_grade_id            in number,
                           p_corps_definition_id in number,
                           p_corps_extra_info_id in number,
                           p_perc_quota          in number,
                           p_population_cd       in varchar2,
                           p_comb_grades         in varchar2,
                           p_max_speed_quota     in number,
                           p_avg_speed_quota     in number);
procedure pull_career_path(p_copy_entity_txn_id in number,
                           p_step_id            in number,
                           p_effective_date     in date,
                           p_grade_id           in number);
procedure update_point(p_point_id             in number,
                       p_point_ovn            in out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_information3         in varchar2,
                       p_information4         in varchar2,
                       p_information5         in varchar2,
                       p_effective_date       in date,
                       p_business_group_id    in number,
                       p_parent_spine_id      in number,
                       p_sequence             in number,
                       p_spinal_point         in varchar2);
procedure create_point(p_point_id             out nocopy number,
                       p_point_ovn            out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_information3         in varchar2,
                       p_information4         in varchar2,
                       p_information5         in varchar2,
                       p_effective_date       in date,
                       p_business_group_id    in number,
                       p_parent_spine_id      in number,
                       p_sequence             in number,
                       p_spinal_point         in varchar2);
procedure create_scale(p_scale_id             out nocopy number,
                       p_scale_ovn            out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_business_group_id    in number,
                       p_name                 in varchar2,
                       p_effective_date       in date,
                       p_increment_frequency  in number,
                       p_increment_period     in varchar2);
procedure update_scale(p_scale_id             in number,
                       p_scale_ovn            in out nocopy number,
                       p_information_category in varchar2,
                       p_information1         in varchar2,
                       p_information2         in varchar2,
                       p_business_group_id    in number,
                       p_name                 in varchar2,
                       p_effective_date       in date,
                       p_increment_frequency  in number,
                       p_increment_period     in varchar2);
procedure get_pgm_extra_info(p_pgm_id          in number,
                        p_quota_flag          out nocopy varchar2,
                        p_appraisal_type      out nocopy varchar2,
                        p_review_period       out nocopy number,
                        p_pgm_extra_info_id out nocopy number);
end pqh_cpd_hr_to_stage;

 

/
