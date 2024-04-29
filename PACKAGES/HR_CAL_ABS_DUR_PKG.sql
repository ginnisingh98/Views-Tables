--------------------------------------------------------
--  DDL for Package HR_CAL_ABS_DUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ABS_DUR_PKG" AUTHID CURRENT_USER AS
/* $Header: peabsdur.pkh 115.2 2002/12/12 11:55:40 raranjan noship $ */
-- --------------- calculate_absence_duration ---------------------
--
-- computes the employee's absence duration
--
PROCEDURE calculate_absence_duration
( p_days_or_hours           IN VARCHAR2,
  p_date_start              IN DATE,
  p_date_end                IN DATE,
  p_time_start              IN VARCHAR2,
  p_time_end                IN VARCHAR2,
  p_business_group_id       IN NUMBER,
  p_legislation_code        IN VARCHAR2,
  p_session_date            IN DATE,
  p_assignment_id           IN NUMBER,
  p_element_type_id         IN NUMBER,
  p_invalid_message         IN OUT NOCOPY VARCHAR2,
  p_duration                IN OUT NOCOPY NUMBER,
  p_use_formula             IN OUT NOCOPY VARCHAR2);
--
-- --------------------- count_working_days -----------------------
--
-- This function is called from the formula and its used to
-- count the number of working days (Monday to Friday) for the
-- duration of the absence.
--
function count_working_days(starting_date DATE, total_days NUMBER)
  return NUMBER;
--
--
end hr_cal_abs_dur_pkg;

 

/
