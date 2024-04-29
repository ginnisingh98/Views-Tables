--------------------------------------------------------
--  DDL for Package PER_GB_ABSENCE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_GB_ABSENCE_RULES" AUTHID CURRENT_USER AS
/* $Header: pegbabsr.pkh 120.5.12010000.1 2008/07/28 04:44:34 appldev ship $ */

PROCEDURE sickness_date_update
  (p_absence_attendance_id                in    number
  );

PROCEDURE validate_abs_create(p_business_group_id            IN NUMBER
                             ,p_person_id                    IN NUMBER
			                 ,p_date_start                   IN DATE
			                 ,p_date_end                     IN DATE
                             ,p_time_start IN VARCHAR2   -- Bug 6708992
                             ,p_time_end IN VARCHAR2	 -- Bug 6708992
		                     ,p_absence_attendance_type_id   IN NUMBER);

PROCEDURE validate_abs_update(p_date_start            IN DATE,
                              p_date_end              IN DATE,
                              p_time_start IN VARCHAR2, -- Bug 6708992
                              p_time_end IN VARCHAR2,   -- Bug 6708992
                              p_absence_attendance_id IN NUMBER);

PROCEDURE validate_abs_delete(p_absence_attendance_id        IN NUMBER);
END;

/
