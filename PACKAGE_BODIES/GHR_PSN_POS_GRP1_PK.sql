--------------------------------------------------------
--  DDL for Package Body GHR_PSN_POS_GRP1_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PSN_POS_GRP1_PK" as
/* $Header: ghposrul.pkb 120.0.12010000.1 2008/07/28 10:37:20 appldev ship $ */
procedure ghr_psn_pos_grp1_pk_drv
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
psn_flsa_cat
     (
      p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_flsa_cat_3
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_funct_class_id_3
     (
      p_pos_grp1_type  =>  p_pos_grp1_type
     ,p_pos_grp2_type  =>  p_pos_grp2_type
     );
psn_pos_scty_acs_1
     (
      p_pos_grp1_type  =>  p_pos_grp1_type
     );
/* Commented as per Aug 2001 10.7 Patch
psn_supv_status_11
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
*/
psn_supv_status_19
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_2
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_3
     (
      p_grade   =>  p_grade
     ,p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_4
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_5
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_6
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_8
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
psn_supv_status_9
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp1_type  =>  p_pos_grp1_type
     );
end ghr_psn_pos_grp1_pk_drv;
--
--
procedure psn_flsa_cat
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pos_grp1_type.flsa_category IS NULL)
    THEN
        hr_utility.set_message(8301, 'GHR_38420_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_flsa_cat;
--
procedure psn_flsa_cat_3
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan IN ('AL', 'CA', 'ES', 'EX', 'SL', 'ST')
     AND p_pos_grp1_type.flsa_category <> 'E')
    THEN
        hr_utility.set_message(8301, 'GHR_38421_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_flsa_cat_3;
--
procedure psn_funct_class_id_3
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
   IF ( p_pos_grp2_type.training_program_id = '53'
     AND p_pos_grp1_type.functional_class IS NULL)
    THEN
        hr_utility.set_message(8301, 'GHR_38424_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_funct_class_id_3;
--
procedure psn_pos_scty_acs_1
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pos_grp1_type.position_sensitivity <> '1'
     AND p_pos_grp1_type.position_sensitivity IS NOT NULL
     AND p_pos_grp1_type.security_access IS NULL)
    THEN
        hr_utility.set_message(8301, 'GHR_38425_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_pos_scty_acs_1;
--
/* Removed as per Aug 2001 10.7 Patch and patched in April 2002 Patch for 11i
procedure psn_supv_status_11
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pos_grp1_type.supervisory_status = '5'
     AND p_pay_plan NOT IN ('AL','CA','GM','GS','SL','GG','GH','FT','FM','FG') )
    THEN
        hr_utility.set_message(8301, 'GHR_38429_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_11;
*/
--
procedure psn_supv_status_19
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan IN ('ES',  'EX', 'FE')
     AND p_pos_grp1_type.supervisory_status NOT IN ('1','2', '3', '8'))
    THEN
        hr_utility.set_message(8301, 'GHR_38433_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_19;
--
procedure psn_supv_status_2
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan IN ('WN', 'WS')
     AND p_pos_grp1_type.supervisory_status NOT IN ('1','2','3'))
    THEN
        hr_utility.set_message(8301, 'GHR_38434_POSN_RULES');
        hr_utility.raise_error;
   END IF;
   IF ( p_pay_plan = 'WG'
     AND p_pos_grp1_type.supervisory_status NOT IN ('4','7','8'))
    THEN
        hr_utility.set_message(8301, 'GHR_38435_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_2;
--
procedure psn_supv_status_3
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan = 'GS'
     AND p_grade  IN ('01', '02', '03', '04')
     AND p_pos_grp1_type.supervisory_status NOT IN ('4','6','8'))
    THEN
        hr_utility.set_message(8301, 'GHR_38436_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_3;
--
procedure psn_supv_status_4
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
-- Bug 2681833 -- Added code '7'
   IF ( p_pay_plan <> 'GS'
     AND p_pay_plan = 'GM'
     AND p_pos_grp1_type.supervisory_status NOT IN ('1','2','3','4','5','7'))
    THEN
        hr_utility.set_message(8301, 'GHR_38437_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_4;
--
procedure psn_supv_status_5
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan IN ('GW', 'WW', 'YW', 'YV', 'IP', 'DW')
     AND p_pos_grp1_type.supervisory_status <> '8')
    THEN
        hr_utility.set_message(8301, 'GHR_38438_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_5;
--
procedure psn_supv_status_6
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pos_grp1_type.supervisory_status NOT IN ('1','2')
     AND p_pay_plan IN ('WA','WN', 'WS', 'WQ', 'XN', 'XS'))
    THEN
        hr_utility.set_message(8301, 'GHR_38439_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_6;
--
procedure psn_supv_status_8
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pay_plan = 'WB'
     AND p_pos_grp1_type.supervisory_status NOT IN ('1','2','6','8'))
    THEN
        hr_utility.set_message(8301, 'GHR_38440_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_8;
--
procedure psn_supv_status_9
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     )
is
begin
   IF ( p_pos_grp1_type.supervisory_status <> '6'
     AND p_pay_plan IN ( 'LL', 'LX', 'ML', 'RL', 'WL', 'XL' ))
    THEN
        hr_utility.set_message(8301, 'GHR_38441_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_supv_status_9;
--
end ghr_psn_pos_grp1_pk;

/
