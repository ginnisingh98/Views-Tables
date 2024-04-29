--------------------------------------------------------
--  DDL for Package Body GHR_PSN_PSN_GRP2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PSN_PSN_GRP2_PKG" as
/* $Header: ghposrul.pkb 120.0.12010000.1 2008/07/28 10:37:20 appldev ship $ */
procedure ghr_psn_psn_grp2_pkg_drv
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
psn_posn_occupd_id_2
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp2_type  =>  p_pos_grp2_type
     );
psn_posn_occupd_id_3
     (
      p_pay_plan  =>  p_pay_plan
     ,p_pos_grp2_type  =>  p_pos_grp2_type
     );
psn_posn_occupd_id_8
     (
      p_pos_grp2_type  =>  p_pos_grp2_type
     );
end ghr_psn_psn_grp2_pkg_drv;
--
procedure psn_posn_occupd_id_2
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
   IF ( p_pay_plan = 'WT'
     AND p_pos_grp2_type.position_occupied NOT IN ('1', '2'))
    THEN
        hr_utility.set_message(8301, 'GHR_38450_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_posn_occupd_id_2;
--
procedure psn_posn_occupd_id_3
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
   IF ( p_pay_plan = 'ES'
     AND p_pos_grp2_type.position_occupied NOT IN ('3', '4') )
    THEN
        hr_utility.set_message(8301, 'GHR_38451_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_posn_occupd_id_3;
--
procedure psn_posn_occupd_id_8
     (
      p_pos_grp2_type  in  ghr_api.pos_grp2_type
     )
is
begin
   IF ( p_pos_grp2_type.intelligence_position_ind = '2'
     AND p_pos_grp2_type.position_occupied = 1 )
    THEN
        hr_utility.set_message(8301, 'GHR_38453_POSN_RULES');
        hr_utility.raise_error;
   END IF;
end psn_posn_occupd_id_8;
--
end ghr_psn_psn_grp2_pkg;

/
