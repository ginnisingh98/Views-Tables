--------------------------------------------------------
--  DDL for Package GHR_PSN_POS_GRP1_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PSN_POS_GRP1_PK" AUTHID CURRENT_USER as
/* $Header: ghposrul.pkh 120.0.12010000.1 2008/07/28 10:37:23 appldev ship $ */
procedure ghr_psn_pos_grp1_pk_drv
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
procedure psn_flsa_cat
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_flsa_cat_3
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_funct_class_id_3
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
procedure psn_pos_scty_acs_1
     (
      p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
/*
procedure psn_supv_status_11
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
*/
procedure psn_supv_status_19
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_2
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_3
     (
      p_grade   in  VARCHAR2
     ,p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_4
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_5
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_6
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_8
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
procedure psn_supv_status_9
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp1_type  in  ghr_api.pos_grp1_type
     );
end ghr_psn_pos_grp1_pk;

/
