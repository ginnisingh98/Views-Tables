--------------------------------------------------------
--  DDL for Package PQP_BUDGET_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_BUDGET_MAINTENANCE" AUTHID CURRENT_USER AS
/* $Header: pqabvmaintain.pkh 120.2.12010000.1 2008/07/28 11:07:34 appldev ship $ */
   TYPE t_indexed_dates IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

   TYPE t_asg_set_amnds IS TABLE OF hr_assignment_set_amendments.include_or_exclude%TYPE
      INDEX BY BINARY_INTEGER;

   g_tab_asg_set_amnds              t_asg_set_amnds;
-- configuration value constant

   c_abvm_maintenance      CONSTANT pqp_configuration_values.pcv_information_category%TYPE
                                                    := 'PQP_ABVM_MAINTENANCE';
   c_abvm_definition       CONSTANT pqp_configuration_values.pcv_information_category%TYPE
                                                     := 'PQP_ABVM_DEFINITION';
   c_abvm_fte_additional   CONSTANT pqp_configuration_values.pcv_information_category%TYPE
                                                 := 'PQP_ABVM_FTE_ADDITIONAL';

-- Procedure to get legislative parameters for payroll action

   PROCEDURE GET_PARAMETER_LIST(
      p_pay_action_id    IN              NUMBER
     ,p_parameter_list   OUT NOCOPY      VARCHAR2
   );

-- Function to get the value of a legislative parameter
   FUNCTION get_parameter_value(
      p_string           IN   VARCHAR2
     ,p_parameter_list   IN   VARCHAR2
   )
      RETURN VARCHAR2;

-- Procedure to get assignment set details
   PROCEDURE get_asg_set_details(
      p_assignment_set_id   IN              NUMBER
     ,p_formula_id          OUT NOCOPY      NUMBER
     ,p_tab_asg_set_amnds   OUT NOCOPY      t_asg_set_amnds
   );

-- Procedure for range cursor
   PROCEDURE range_cursor(
      p_pay_action_id   IN              NUMBER
     ,p_sqlstr          OUT NOCOPY      VARCHAR2
   );

-- Function to check whether an assignment exists in an assignment set
   FUNCTION chk_is_asg_in_asg_set(
      p_assignment_id       IN   NUMBER
     ,p_formula_id          IN   NUMBER
     ,p_tab_asg_set_amnds   IN   t_asg_set_amnds
     ,p_effective_date      IN   DATE
   )
      RETURN VARCHAR2;

-- Function for assignment action creation
   PROCEDURE action_creation(
      p_pay_action_id   IN   NUMBER
     ,p_start_person    IN   NUMBER
     ,p_end_person      IN   NUMBER
     ,p_chunk           IN   NUMBER
   );

-- Procedure for archive data
   PROCEDURE archive_data(
      p_assignment_action_id   IN   NUMBER
     ,p_effective_date         IN   DATE
   );

-- Procedure for deinitialise
   PROCEDURE deinitialization_code(p_pay_action_id IN NUMBER);

--
-- Maintain_ABV_For_Assignment
-- Maintain assignment budget values for a single assignment
   PROCEDURE maintain_abv_for_assignment(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_action              IN   VARCHAR2
   );

-- Get_Impact_Dates
-- Get the set of dates on which to calculate budget value
   PROCEDURE get_event_dates(
      p_uom                  IN              VARCHAR2
     ,p_assignment_id        IN              NUMBER
     ,p_business_group_id    IN              NUMBER
     ,p_event_dates_source   IN              VARCHAR2
     ,p_event_group_id       IN              NUMBER
     ,p_custom_function      IN              VARCHAR2
     ,p_effective_date       IN              DATE
     ,p_impact_dates         IN OUT NOCOPY   t_indexed_dates
   );

-- Get_Change_Dates_From_DTI
-- Obtains dates returned by datetrack interpreter
   PROCEDURE get_change_dates_from_dti(
      p_assignment_id       IN              NUMBER
     ,p_business_group_id   IN              NUMBER
     ,p_event_group_id      IN              NUMBER
     ,p_calculation_date    IN              DATE
     ,p_impact_dates        IN OUT NOCOPY   t_indexed_dates
   );

-- Execute_Custom_Function
-- Construct the dynamic query to execute a user provided custom
-- function or the inbuilt custom function to obtain impact dates
   PROCEDURE execute_custom_function(
      p_uom                  IN              VARCHAR2
     ,p_assignment_id        IN              NUMBER
     ,p_business_group_id    IN              NUMBER
     ,p_custom_function      IN              VARCHAR2
     ,p_effective_date       IN              DATE
     ,p_event_dates          IN OUT NOCOPY   pqp_table_of_dates
   );

-- Get_FTE_Event_Dates
-- Inbuilt custom function to return impact dates using search and
-- compare for FTE budget value only
   PROCEDURE get_fte_event_dates(
      p_uom                 IN              VARCHAR2
     ,p_assignment_id       IN              NUMBER
     ,p_business_group_id   IN              NUMBER
     ,p_effective_date      IN              DATE
     ,p_event_dates         IN OUT NOCOPY   pqp_table_of_dates
   );

--
-- Calculate_ABV
-- Calculate ABV based on seeded GB specific formula
-- or using user provided formula
   PROCEDURE update_value_for_event_dates(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_formula_id          IN   NUMBER
     ,p_action              IN   VARCHAR2
     ,p_effective_date      IN   DATE
   );

-- Update_And_Store_ABV
-- Write calculated Budget Value to database
   PROCEDURE update_and_store_abv(
      p_uom                 IN   VARCHAR2
     ,p_assignment_id       IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_abv_value           IN   NUMBER
     ,p_action              IN   VARCHAR2
     ,p_effective_date      IN   DATE
   );

-- Csr_Get_Configuration_Data
-- Obtain Configuration data
   CURSOR csr_get_configuration_data(
      p_uom                    VARCHAR2
     ,p_business_group_id      NUMBER
     ,p_legislation_code       VARCHAR2
     ,p_information_category   VARCHAR2
   )
   IS
      SELECT   *
          FROM pqp_configuration_values
         WHERE pcv_information_category = p_information_category
           AND pcv_information1 = p_uom
           AND (   (business_group_id = p_business_group_id)
                OR (    business_group_id IS NULL
                    AND legislation_code = p_legislation_code
                   )
                OR (business_group_id IS NULL AND legislation_code IS NULL)
               )
      ORDER BY 1 DESC;

-- Load_Cache
-- Obtains the configuration value data returning the data in the order
-- Business_Group = P_Business_Group
-- Business_Group IS NULL AND Legislation_Code = 'GB'
-- Business_Group IS NULL AND Legislation_Code = NULL
-- where multiple rows exist
   PROCEDURE load_cache(
      p_uom                    IN              VARCHAR2
     ,p_business_group_id      IN              NUMBER
     ,p_legislation_code       IN              VARCHAR2
     ,p_information_category   IN              VARCHAR2
     ,p_configuration_data     IN OUT NOCOPY   csr_get_configuration_data%ROWTYPE
   );
--
--

END pqp_budget_maintenance;

/
