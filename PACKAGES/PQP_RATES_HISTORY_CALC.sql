--------------------------------------------------------
--  DDL for Package PQP_RATES_HISTORY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_RATES_HISTORY_CALC" AUTHID CURRENT_USER AS
/* $Header: pqrthcal.pkh 120.1.12010000.1 2008/07/28 11:22:57 appldev ship $ */


c_overrides_asg_contract       CONSTANT VARCHAR2(80):= 'OVERRIDE';
c_defaults_asg_contract        CONSTANT VARCHAR2(80):= 'DEFAULT';
c_default_type_of_rate         CONSTANT VARCHAR2(30):= 'E';
c_contract_table_name          CONSTANT pay_user_tables.user_table_name%TYPE :=
  'PQP_CONTRACT_TYPES';

g_default_contract_type_usage  CONSTANT VARCHAR2(80):=
  c_overrides_asg_contract;

g_rounding_precision           NUMBER(2,0):=5;


CURSOR csr_element_type_id
  (p_name    VARCHAR2
  ) IS
SELECT element_type_id
FROM   pay_element_types_f
WHERE  element_name = p_name;

TYPE csr_element_set_typ IS REF CURSOR RETURN csr_element_type_id%ROWTYPE;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_element_attributes >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Returns all the rates history attribution held at the
-- element level.
-- Added to spec due to dependency in pqpgbtp1.pkb
PROCEDURE get_element_attributes
 (p_element_type_extra_info_id IN      NUMBER
 ,p_service_history           OUT NOCOPY VARCHAR2
 ,p_fte                       OUT NOCOPY VARCHAR2
 ,p_pay_source_value          OUT NOCOPY VARCHAR2
 ,p_qualifier                 OUT NOCOPY VARCHAR2
 ,p_from_time_dim             OUT NOCOPY VARCHAR2
 ,p_calculation_type          OUT NOCOPY VARCHAR2
 ,p_calculation_value         OUT NOCOPY VARCHAR2
 ,p_input_value               OUT NOCOPY VARCHAR2
 ,p_linked_to_assignment      OUT NOCOPY VARCHAR2
 ,p_term_time_yes_no          OUT NOCOPY VARCHAR2
 ,p_sum_multiple_entries_yn   OUT NOCOPY VARCHAR2
 ,p_lookup_input_values_yn    OUT NOCOPY VARCHAR2
 ,p_column_name_source_type   OUT NOCOPY VARCHAR2
 ,p_column_name_source_name   OUT NOCOPY VARCHAR2
 ,p_row_name_source_type      OUT NOCOPY VARCHAR2
 ,p_row_name_source_name      OUT NOCOPY VARCHAR2
 );

-- ----------------------------------------------------------------------------
-- |--------------------------< convert_values >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Convert values from source to destination dimensions
-- includes applying the FTE, Service History and Term Time Factors
-- Added to spec due to dependency in pqpgbtp1.pkb
FUNCTION convert_values
 (p_assignment_id             IN       NUMBER
 ,p_date                      IN       DATE
 ,p_value                     IN       NUMBER
 ,p_to_time_dim               IN       VARCHAR2
 ,p_from_time_dim             IN       VARCHAR2
 ,p_fte                       IN       VARCHAR2
 ,p_service_history           IN       VARCHAR2
 ,p_term_time_yes_no          IN       VARCHAR2
 ,p_contract_type             IN       VARCHAR2 DEFAULT NULL
 ,p_contract_type_usage       IN       VARCHAR2 DEFAULT g_default_contract_type_usage
 ) RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |--------------------------< process_element >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Retrive all necessary data, and calculate the
-- applicable rate of pay.
-- Added to spec due to dependency in pqpgbtp1.pkb
FUNCTION process_element(
  p_assignment_id             IN       NUMBER
 ,p_date                      IN       DATE
 ,p_element_type_id           IN       NUMBER
 ,p_to_time_dim               IN       VARCHAR2
 ,p_fte                       IN       VARCHAR2
 ,p_service_history           IN       VARCHAR2
 ,p_pay_source_value          IN       VARCHAR2
 ,p_qualifier                 IN       VARCHAR2
 ,p_from_time_dim             IN       VARCHAR2
 ,p_calculation_type          IN       VARCHAR2
 ,p_calculation_value         IN       NUMBER
 ,p_input_value               IN       VARCHAR2
 ,p_term_time_yes_no          IN       VARCHAR2
 ,p_sum_multiple_entries_yn   IN       VARCHAR2
 ,p_lookup_input_values_yn    IN       VARCHAR2
 ,p_column_name_source_type   IN       VARCHAR2
 ,p_column_name_source_name   IN       VARCHAR2
 ,p_row_name_source_type      IN       VARCHAR2
 ,p_row_name_source_name      IN       VARCHAR2
 ,p_contract_type             IN       VARCHAR2 DEFAULT NULL
 ,p_contract_type_usage       IN       VARCHAR2 DEFAULT g_default_contract_type_usage
 ) RETURN NUMBER;


-- ----------------------------------------------------------------------------
-- |--------------------------< rates_history >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Top level function, returning rate of pay. Can be used
-- for single element or rate type.
-- Formula Function: GB_RATES_HISTORY (aliased RATES_HISTORY) maps to this spec
-- deprecate use of this function gradually

FUNCTION rates_history
 (p_assignment_id                IN            NUMBER
 ,p_calculation_date             IN            DATE
 ,p_name                         IN            VARCHAR2
 ,p_rt_element                   IN            VARCHAR2
 ,p_to_time_dim                  IN            VARCHAR2
 ,p_rate                         IN OUT NOCOPY NUMBER
 ,p_error_message                IN OUT NOCOPY VARCHAR2
 ,p_contract_type                IN            VARCHAR2      DEFAULT NULL
 ,p_contract_type_usage          IN            VARCHAR2      DEFAULT g_default_contract_type_usage
 ) RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_historic_rate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Top level function, returning rate of pay. Can be used
-- for single element or rate type.
-- Formula Function: GET_HISTORIC_RATE (aliased RATES_HISTORY) maps to this spec
-- p_effective_date               DEFAULT session effective date,
--                                        if the session date is no not set then
--                                        system date
-- p_time_dimension               DEFAULT the same as the source time dimension
--                                        for the element
-- p_rate_type_or_element         DEFAULT c_default_type_of_rate = 'E'
-- p_contract_type                DEFAULT Null , if no contract type is supplied
--                                               then one is expected to exist
--                                               at the assignment level
-- p_contract_type_usage          DEFAULT g_default_contract_type_usage = 'OVERRIDE'
--                                        override the assignment contract with
--                                        the one specified in p_contract_type
FUNCTION get_historic_rate
  (p_assignment_id                IN            NUMBER
  ,p_rate_name                    IN            VARCHAR2
  ,p_effective_date               IN            DATE     DEFAULT NULL
  ,p_time_dimension               IN            VARCHAR2 DEFAULT NULL
  ,p_rate_type_or_element         IN            VARCHAR2 DEFAULT c_default_type_of_rate
  ,p_contract_type                IN            VARCHAR2 DEFAULT NULL
  ,p_contract_type_usage          IN            VARCHAR2 DEFAULT g_default_contract_type_usage
  ) RETURN NUMBER;



END pqp_rates_history_calc;

/
