--------------------------------------------------------
--  DDL for Package GHR_PSN_PSN_VAL_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PSN_PSN_VAL_PKG2" AUTHID CURRENT_USER as
/* $Header: ghposrul.pkh 120.0.12010000.1 2008/07/28 10:37:23 appldev ship $ */
procedure ghr_psn_psn_val_pkg2_drv
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_oblig_type  in  ghr_api.pos_oblig_type
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     ,p_target_grade  in  VARCHAR2
     );
procedure posn_oblig_2
     (
      p_pos_oblig_type  in  ghr_api.pos_oblig_type
     );
procedure psn_asg_work_sch
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_grade_9
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     );
procedure psn_pay_basis_1
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     );
procedure psn_pay_plan_grade_3
     (
      p_grade   in  VARCHAR2
     ,p_target_grade  in  VARCHAR2
     );
procedure target_gr_civ5
     (
      p_target_grade  in  VARCHAR2
     );
end ghr_psn_psn_val_pkg2;

/
