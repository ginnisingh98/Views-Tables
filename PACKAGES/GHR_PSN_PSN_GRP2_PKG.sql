--------------------------------------------------------
--  DDL for Package GHR_PSN_PSN_GRP2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PSN_PSN_GRP2_PKG" AUTHID CURRENT_USER as
/* $Header: ghposrul.pkh 120.0.12010000.1 2008/07/28 10:37:23 appldev ship $ */
procedure ghr_psn_psn_grp2_pkg_drv
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
procedure psn_posn_occupd_id_2
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
procedure psn_posn_occupd_id_3
     (
      p_pay_plan  in  VARCHAR2
     ,p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
procedure psn_posn_occupd_id_8
     (
      p_pos_grp2_type  in  ghr_api.pos_grp2_type
     );
end ghr_psn_psn_grp2_pkg;

/
