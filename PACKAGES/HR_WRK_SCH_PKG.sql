--------------------------------------------------------
--  DDL for Package HR_WRK_SCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WRK_SCH_PKG" AUTHID CURRENT_USER AS
  -- $Header: pewrksch.pkh 120.1.12010000.1 2008/07/28 06:08:03 appldev ship $

  --
  -----------------------------------------------------------------------------
  --------------------------< get_per_asg_schedule >---------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure can be invoked by downstream products wishing to use the
  -- the Absences Availability functionality to retreive availability data
  -- for a person assignment.
  --
  PROCEDURE get_per_asg_schedule(p_person_assignment_id IN NUMBER
                                ,p_period_start_date    IN DATE
                                ,p_period_end_date      IN DATE
                                ,p_schedule_category    IN VARCHAR2
                                ,p_include_exceptions   IN VARCHAR2
                                ,p_busy_tentative_as    IN VARCHAR2
                                ,x_schedule_source      IN OUT NOCOPY VARCHAR2
                                ,x_schedule             IN OUT NOCOPY cac_avlblty_time_varray
                                ,x_return_status        OUT NOCOPY NUMBER
                                ,x_return_message       OUT NOCOPY VARCHAR2
                                );

  --
  -----------------------------------------------------------------------------
  --------------------------< get_working_day >--------------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure can be invoked by downstream products wishing to use the
  -- Absences Availability functionality to retrieve the next/previous working
  -- day after a leave.

 function get_working_day
(
   p_person_assignment_id IN NUMBER
  ,loa_start_date in DATE
  ,loa_end_date in DATE
  ,prev_next_flag in VARCHAR2 default 'N'

) return DATE;

END hr_wrk_sch_pkg;

/
