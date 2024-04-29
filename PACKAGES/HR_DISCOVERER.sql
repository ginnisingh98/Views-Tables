--------------------------------------------------------
--  DDL for Package HR_DISCOVERER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DISCOVERER" AUTHID CURRENT_USER AS
/* $Header: hrdiscov.pkh 115.3 2003/12/18 05:31:35 prasharm ship $ */
--
-- time_in function
--
FUNCTION time_in
 (p_assignment_id IN NUMBER
 ,p_mode          IN VARCHAR2
 ,p_terminate     IN VARCHAR2 DEFAULT NULL
 )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(time_in, WNDS);
--
-- over_70_check function
--
FUNCTION over_70_check
 (p_date_of_birth IN DATE
 )
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(over_70_check, WNDS);
--
-- check_end_date function
--
FUNCTION check_end_date
 (p_end_date IN DATE
 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(check_end_date, WNDS, WNPS);
--
-- get_actual_budget_values function
--
FUNCTION get_actual_budget_values
 (p_unit              IN VARCHAR2,
  p_bus_group_id      IN NUMBER,
  p_organization_id   IN NUMBER,
  p_job_id            IN NUMBER,
  p_position_id       IN NUMBER,
  p_grade_id          IN NUMBER,
  p_start_date        IN DATE,
  p_end_date          IN DATE,
  p_actual_val        IN NUMBER
 )
RETURN NUMBER;
--PRAGMA RESTRICT_REFERENCES(get_actual_budget_values, WNDS);
--
--
END hr_discoverer;

 

/
