--------------------------------------------------------
--  DDL for Package PQP_SERVICE_HISTORY_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_SERVICE_HISTORY_CALC_PKG" AUTHID CURRENT_USER as
/* $Header: pqshpcal.pkh 115.2 2003/02/14 19:21:22 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_service_history >----------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_service_history (p_assignment_id    in number
                                   ,p_calculation_date in date
                                   )
RETURN number;

  --
  -- This function is required to calculate the length of previous service
  -- in days.
  --
-- Added this new function
-- PS Bug 2028104 for details
-- ----------------------------------------------------------------------------
-- |-----------------------< calculate_all_service_history >------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION calculate_all_service_history (p_assignment_id    in number
                                       )
RETURN number;
--
-- ----------------------------------------------------------------------------
-- |---------------------< calculate_continuous_service >---------------------|
-- ----------------------------------------------------------------------------
FUNCTION calculate_continuous_service (p_assignment_id    in number
                                      ,p_calculation_date in date
                                      )
RETURN number;

  --
  -- This function is required to calculate the total continuous service in days  --
--
-- Added this new function
-- PS Bug 2028104 for details
-- ----------------------------------------------------------------------------
-- |---------------------< calculate_all_continuous_serv >--------------------|
-- ----------------------------------------------------------------------------
FUNCTION calculate_all_continuous_serv (p_assignment_id    in number
                                       )
RETURN number;
--
-- ----------------------------------------------------------------------------
-- |-------------------< calculate_service_hist_period >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE calculate_service_hist_period (p_start_date in     date
                                        ,p_end_date   in     date
                                        ,p_years         out nocopy number
                                        ,p_days          out nocopy number
                                        );
  --
  -- This procedure is required to calculate the duration of a particular
  -- period of service history in years and days.
-------------------------------
END pqp_service_history_calc_pkg;

 

/
