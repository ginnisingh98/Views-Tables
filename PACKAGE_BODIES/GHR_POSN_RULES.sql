--------------------------------------------------------
--  DDL for Package Body GHR_POSN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_POSN_RULES" as
/* $Header: ghposrul.pkb 120.0.12010000.1 2008/07/28 10:37:20 appldev ship $ */
procedure ghr_posn_drv
     (
      p_asg_sf52_type         in  ghr_api.asg_sf52_type
     ,p_pos_grp1_type         in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type         in  ghr_api.pos_grp2_type
     ,p_pos_oblig_type        in  ghr_api.pos_oblig_type
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     ,p_ghr_pa_requests       in  ghr_pa_requests%rowtype
    )
is
    p_grade          ghr_pa_requests.to_grade_or_level%type;
    p_pay_plan       ghr_pa_requests.to_pay_plan%type;
    p_target_grade   ghr_pa_requests.to_grade_or_level%type;
    p_valid_grade    ghr_pa_requests.to_grade_or_level%type;
    l_grade_or_level ghr_pa_requests.to_grade_or_level%type;
    l_pay_plan       ghr_pa_requests.to_pay_plan%type;

    CURSOR cur_grd IS
           SELECT  gdf.segment1 pay_plan
                  ,gdf.segment2 grade_or_level
           FROM    per_grade_definitions         gdf
                  ,per_grades                    grd
           WHERE   grd.grade_id              =   p_pos_valid_grade_type.target_grade
           AND     grd.grade_definition_id   =   gdf.grade_definition_id;

begin

   p_grade              := nvl(p_ghr_pa_requests.to_grade_or_level, p_ghr_pa_requests.from_grade_or_level);
   p_pay_plan           := nvl(p_ghr_pa_requests.to_pay_plan, p_ghr_pa_requests.from_pay_plan);
   p_valid_grade        := p_pay_plan||'-'||p_grade;

   open cur_grd;
   fetch cur_grd into l_pay_plan, l_grade_or_level;
   close cur_grd;
   p_target_grade := l_pay_plan||'-'||l_grade_or_level;

ghr_psn_pos_grp1_pk.ghr_psn_pos_grp1_pk_drv
     (
      p_grade                 =>  p_grade
     ,p_pay_plan              =>  p_pay_plan
     ,p_pos_grp1_type         =>  p_pos_grp1_type
     ,p_pos_grp2_type         =>  p_pos_grp2_type
     );
ghr_psn_psn_val_pkg2.ghr_psn_psn_val_pkg2_drv
     (
      p_grade                 =>  p_grade
     ,p_pay_plan              =>  p_pay_plan
     ,p_pos_grp1_type         =>  p_pos_grp1_type
     ,p_pos_oblig_type        =>  p_pos_oblig_type
     ,p_pos_valid_grade_type  =>  p_pos_valid_grade_type
     ,p_target_grade          =>  p_target_grade
     );
ghr_psn_psn_grp2_pkg.ghr_psn_psn_grp2_pkg_drv
     (
      p_pay_plan              =>  p_pay_plan
     ,p_pos_grp2_type         =>  p_pos_grp2_type
     );
end ghr_posn_drv;
end ghr_posn_rules;

/
