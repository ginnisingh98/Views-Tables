--------------------------------------------------------
--  DDL for Package Body GHR_PSN_PSN_VAL_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PSN_PSN_VAL_PKG2" as
/* $Header: ghposrul.pkb 120.0.12010000.1 2008/07/28 10:37:20 appldev ship $ */
procedure ghr_psn_psn_val_pkg2_drv
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_oblig_type  in  ghr_api.pos_oblig_type
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     ,p_target_grade  in  VARCHAR2
     )
is
begin
posn_oblig_2
     (
      p_pos_oblig_type  =>  p_pos_oblig_type
     );
psn_grade_9
     (
      p_grade   =>  p_grade
     ,p_pay_plan  =>  p_pay_plan
     );
psn_pay_basis_1
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_valid_grade_type  =>  p_pos_valid_grade_type
     );
psn_pay_plan_grade_3
     (
      p_grade   =>  p_grade
     ,p_target_grade  =>  p_target_grade
     );
target_gr_civ5
     (
      p_target_grade  =>  p_target_grade
     );
psn_asg_work_sch
     (
      p_pos_grp1_type  =>  p_pos_grp1_type
     );
end ghr_psn_psn_val_pkg2_drv;
--
procedure posn_oblig_2
     (
      p_pos_oblig_type  in  ghr_api.pos_oblig_type
     )
is
begin
   IF ( p_pos_oblig_type.expiration_date IS NULL
     AND p_pos_oblig_type.obligation_type IN  ('C', 'E', 'M', 'N', 'S', 'T'))
    THEN
        hr_utility.set_message(8301, 'GHR_38456_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end posn_oblig_2;
--
procedure psn_asg_work_sch
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF (  p_pos_grp1_type.work_schedule in ('F','G','B','I','J')
     AND p_pos_grp1_type.part_time_hours IS NOT NULL)
    THEN
        hr_utility.set_message(8301, 'GHR_38427_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_asg_work_sch;
--
procedure psn_grade_9
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     )
is
begin
   IF ( p_pay_plan IN ( 'GH', 'GM')
     AND p_grade  NOT IN ('13', '14', '15') )
    THEN
        hr_utility.set_message(8301, 'GHR_38458_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_grade_9;
--
procedure psn_pay_basis_1
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     )
is
begin
   IF ( p_pay_plan IN ('WG', 'WL', 'WS', 'YV', 'YW')
     AND p_pos_valid_grade_type.pay_basis <> 'PH')
    THEN
        hr_utility.set_message(8301, 'GHR_38461_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_pay_basis_1;
--
procedure psn_pay_plan_grade_3
     (
      p_grade   in  VARCHAR2
     ,p_target_grade  in  VARCHAR2
     )
is
begin
   IF ( SUBSTR(p_target_grade, 4, 2) < p_grade )
    THEN
        hr_utility.set_message(8301, 'GHR_38463_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_pay_plan_grade_3;
--
procedure target_gr_civ5
     (
      p_target_grade  in  VARCHAR2
     )
is
begin
   IF ( SUBSTR(p_target_grade, 4, 2) > '05'
     AND SUBSTR(p_target_grade, 1, 2) IN ('EX', 'WW'))
    THEN
        hr_utility.set_message(8301, 'GHR_38469_POSN_RULES');
        hr_utility.raise_error;
   END IF;
   IF ( SUBSTR(p_target_grade, 4, 2) > '15'
     AND SUBSTR(p_target_grade, 1, 2) IN ('GG', 'GH', 'GM', 'GS', 'RL', 'RM', 'WG', 'WL', 'XD', 'XL', 'XP'))
    THEN
        hr_utility.set_message(8301, 'GHR_38470_POSN_RULES');
        hr_utility.raise_error;
   END IF;
   IF ( SUBSTR(p_target_grade, 4, 2) > '19'
     AND SUBSTR(p_target_grade, 1, 2) IN ('SX', 'WS', 'XN', 'XS'))
    THEN
        hr_utility.set_message(8301, 'GHR_38471_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end target_gr_civ5;
--
end ghr_psn_psn_val_pkg2;

/
