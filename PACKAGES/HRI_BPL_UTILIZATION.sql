--------------------------------------------------------
--  DDL for Package HRI_BPL_UTILIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_UTILIZATION" AUTHID CURRENT_USER AS
/* $Header: hributl.pkh 120.2.12000000.1 2007/01/15 21:28:48 appldev noship $ */

FUNCTION convert_days_to_hours(p_assignment_id       IN NUMBER,
                               p_business_group_id   IN NUMBER,
                               p_effective_date      IN DATE,
                               p_session_date        IN DATE,
                               p_number_of_days      IN NUMBER)
        RETURN NUMBER;

FUNCTION convert_hours_to_days(p_assignment_id       IN NUMBER,
                               p_business_group_id   IN NUMBER,
                               p_effective_date      IN DATE,
                               p_session_date        IN DATE,
                               p_number_of_hours     IN NUMBER)
        RETURN NUMBER;

FUNCTION calculate_absence_duration(p_absence_attendance_id  IN VARCHAR2,
                                    p_uom_code               IN VARCHAR2,
                                    p_absence_hours          IN NUMBER,
                                    p_absence_days           IN NUMBER,
                                    p_assignment_id          IN NUMBER,
                                    p_business_group_id      IN NUMBER,
                                    p_primary_flag           IN VARCHAR2,
                                    p_date_start             IN DATE,
                                    p_date_end               IN DATE,
                                    p_time_start             IN VARCHAR2,
                                    p_time_end               IN VARCHAR2)
        RETURN NUMBER;

FUNCTION get_abs_durtn_profile_vl
        RETURN VARCHAR2;

END hri_bpl_utilization;

 

/
