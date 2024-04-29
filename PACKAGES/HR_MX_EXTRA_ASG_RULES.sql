--------------------------------------------------------
--  DDL for Package HR_MX_EXTRA_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_EXTRA_ASG_RULES" AUTHID CURRENT_USER as
/* $Header: hrmxexas.pkh 120.1.12010000.1 2008/07/28 03:31:56 appldev ship $ */

PROCEDURE chk_loc_gre_for_leav_reason
         (p_effective_date        IN DATE,
          p_datetrack_update_mode IN VARCHAR2,
          p_assignment_id         IN per_assignments_f.assignment_id%TYPE,
          p_location_id           IN hr_locations.location_id%TYPE,
          p_scl_segment1          IN hr_soft_coding_keyflex.segment1%TYPE
         );

PROCEDURE chk_gre_for_leav_reason
         (p_effective_date        IN DATE,
          p_datetrack_update_mode IN VARCHAR2,
          p_assignment_id         IN per_assignments_f.assignment_id%TYPE,
          p_segment1              IN hr_soft_coding_keyflex.segment1%TYPE
         ) ;

PROCEDURE chk_leav_reason_for_del_asg
         (p_final_process_date    IN DATE,
          p_assignment_id         IN per_assignments_f.assignment_id%TYPE
	 ) ;

PROCEDURE chk_leav_reason_for_del_emp
        (p_final_process_date    IN DATE,
         p_period_of_service_id  IN
                             per_periods_of_service.period_of_service_id%TYPE,
         p_object_version_number IN NUMBER
        ) ;

PROCEDURE get_gre_loc(p_effective_date IN DATE,
                      p_assignment_id  IN per_assignments_f.assignment_id%TYPE
                     ) ;

end hr_mx_extra_asg_rules;

/
