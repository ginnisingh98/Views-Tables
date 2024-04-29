--------------------------------------------------------
--  DDL for Package PQP_SCHEDULE_CALCULATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SCHEDULE_CALCULATION_PKG" AUTHID CURRENT_USER AS
/* $Header: pqschcal.pkh 120.1.12000000.1 2007/01/16 04:34:10 appldev noship $ */

TYPE t_working_dates IS TABLE OF DATE
INDEX BY BINARY_INTEGER;

TYPE r_work_pattern IS RECORD
  (hours                          NUMBER
  ,next_working_day_index         BINARY_INTEGER
  ,days_to_next_working_day       NUMBER
  );

TYPE t_work_pattern_cache_type IS TABLE OF r_work_pattern
  INDEX BY BINARY_INTEGER;



  CURSOR c_wp_dets
    (p_assignment_id NUMBER
    ,p_start_date    DATE
    ,p_end_date      DATE
    )
  IS
  SELECT *
  FROM   pqp_assignment_attributes_f
  WHERE  assignment_id = p_assignment_id
    AND  (
           (p_start_date BETWEEN effective_start_date
                             AND effective_end_date)
          OR
           (p_end_date   BETWEEN effective_start_date
                             AND effective_end_date)
          OR
           (effective_start_date BETWEEN p_start_date
                                     AND p_end_date)
          OR
           (effective_end_date   BETWEEN p_start_date
                                     AND p_end_date)
         )
  ORDER BY effective_start_date;


  CURSOR c_wp_dets_up(p_assignment_id NUMBER
                     ,p_start_date    DATE
                     ) IS
  SELECT *
  FROM   pqp_assignment_attributes_f
  WHERE  assignment_id = p_assignment_id
    AND  (
           (p_start_date BETWEEN effective_start_date
                             AND effective_end_date)
           OR
            (effective_start_date > p_start_date)
         )
  ORDER BY effective_start_date;

  CURSOR c_get_legcode
    (p_business_group_id NUMBER
    )IS
  SELECT legislation_code
  FROM   per_business_groups_perf
  WHERE  business_group_id = p_business_group_id;


-- Global variables
g_udt_name                VARCHAR2(50) := 'PQP_COMPANY_WORK_PATTERNS';
g_default_start_day       VARCHAR2(10) := 'sunday';
g_override_work_pattern   pay_user_columns.user_column_name%TYPE;

PROCEDURE get_day_dets
  (p_wp_dets        IN  c_wp_dets%ROWTYPE
  ,p_calc_stdt      IN  DATE
  ,p_calc_edt       IN  DATE
  ,p_day_no         OUT NOCOPY NUMBER
  ,p_days_in_wp     OUT NOCOPY NUMBER
  );

-- Returns the number  of hours worked in the given date range
FUNCTION calculate_time_worked
  (p_assignment_id          IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_date_end               IN     DATE
  ) RETURN NUMBER;

-- Returns the number  of hours worked in the given date range
-- Uses Default Work Pattern if Assignment does not have a WP
FUNCTION get_hours_worked
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_date_end               IN     DATE
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_message             OUT NOCOPY VARCHAR2
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ,p_is_assignment_wp       IN BOOLEAN DEFAULT FALSE
  ) RETURN NUMBER;

-- Returns the number  of days worked in the given date range
-- Also returns a Table of Working Dates
-- Uses Default Work Pattern if Assignment does not have a WP
FUNCTION get_days_worked
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_date_end               IN     DATE
  ,p_working_dates             OUT NOCOPY t_working_dates
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_message             OUT NOCOPY VARCHAR2
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

-- OVERLOADED get_days_worked
-- Returns the number  of days worked in the given date range
-- Uses Default Work Pattern if Assignment does not have a WP
FUNCTION get_days_worked
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_date_end               IN     DATE
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_message             OUT NOCOPY VARCHAR2
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

-- Return Y if the given date is a working day, N if not a working day
FUNCTION is_working_day
  (p_assignment_id     IN     NUMBER
  ,p_business_group_id IN     NUMBER
  ,p_date              IN     DATE
  ,p_error_code           OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2
  ,p_default_wp        IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN     VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

-- Returns the date prior to the next working day(p_days+1) after adding
-- working days to p_date_start
-- Uses default work pattern if Assignment does not have a WP
FUNCTION add_working_days
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_days                   IN     NUMBER
  ,p_error_code                OUT NOCOPY NUMBER
  ,p_error_message             OUT NOCOPY VARCHAR2
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ) RETURN DATE;

-----------------------------------------------------
-- Returns the number of Working Days in a Workpattern
-- as on the effective date
-- it takes 2 optional parameters p_override_wp, p_default_wp
-- Order of precedence is Override->Assignment->Default
FUNCTION get_working_days_in_week
  (p_assignment_id     IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_effective_date    IN DATE
  ,p_default_wp        IN VARCHAR2 DEFAULT NULL
  ,p_override_wp       IN VARCHAR2 DEFAULT NULL
  ) RETURN NUMBER;

FUNCTION get_day_index_for_date
  (p_asg_work_pattern_start_date  IN DATE
  ,p_asg_work_pattern_start_day_n IN NUMBER
  ,p_total_days_in_work_pattern   IN NUMBER
  ,p_date_to_index                IN DATE
  ) RETURN NUMBER;

PROCEDURE load_work_pattern_into_cache
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ,p_work_pattern_used              OUT NOCOPY VARCHAR2
  ,p_asg_work_pattern_start_day_n   OUT NOCOPY BINARY_INTEGER
  ,p_asg_work_pattern_start_date    OUT NOCOPY DATE
  ,p_date_start_day_index           OUT NOCOPY BINARY_INTEGER
  );

FUNCTION add_working_days_using_one_wp
  (p_assignment_id          IN     NUMBER
  ,p_business_group_id      IN     NUMBER
  ,p_date_start             IN     DATE
  ,p_working_days_to_add    IN     NUMBER
  ,p_default_wp             IN     VARCHAR2 DEFAULT NULL
  ,p_override_wp            IN     VARCHAR2 DEFAULT NULL
  ) RETURN DATE;


PROCEDURE clear_cache;


END pqp_schedule_calculation_pkg;

 

/
