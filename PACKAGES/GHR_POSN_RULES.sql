--------------------------------------------------------
--  DDL for Package GHR_POSN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_POSN_RULES" AUTHID CURRENT_USER as
/* $Header: ghposrul.pkh 120.0.12010000.1 2008/07/28 10:37:23 appldev ship $ */
procedure ghr_posn_drv
     (
      p_asg_sf52_type         in  ghr_api.asg_sf52_type
     ,p_pos_grp1_type         in  ghr_api.pos_grp1_type
     ,p_pos_grp2_type         in  ghr_api.pos_grp2_type
     ,p_pos_oblig_type        in  ghr_api.pos_oblig_type
     ,p_pos_valid_grade_type  in  ghr_api.pos_valid_grade_type
     ,p_ghr_pa_requests       in  ghr_pa_requests%rowtype
     );
end ghr_posn_rules;

/
