--------------------------------------------------------
--  DDL for Package PAY_IN_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_TERMINATION_PKG" AUTHID CURRENT_USER AS
/* $Header: pyinterm.pkh 120.2.12010000.1 2008/07/27 22:54:50 appldev ship $ */
  g_leaving_reason   per_periods_of_service.leaving_reason%TYPE;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_TERMINATION_ELEMENTS                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to handle creation of Termination EE for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
--------------------------------------------------------------------------
PROCEDURE create_termination_elements
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
	     ,p_calling_procedure       IN VARCHAR2
	     ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
	     );

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_TERMINATION_ELEMENTS                           --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete all Termination Element entries   --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
--------------------------------------------------------------------------
PROCEDURE delete_termination_elements
              (p_period_of_service_id    IN NUMBER
	      ,p_business_group_id       IN NUMBER
	      ,p_actual_termination_date IN DATE
	      ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : YEARS_OF_SERVICE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to return the number of years of service   --
--                  for a  terminated employee.                         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_start_date                   DATE                 --
--                  p_end_date                     DATE                 --
--                  p_flag                         VARCHAR2             --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION years_of_service(p_start_date            IN DATE
                         ,p_end_date              IN DATE
                         ,p_flag                  IN VARCHAR2
                         )
RETURN NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_AVERAGE_SALARY                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return average salary for a duration    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                NUMBER               --
--                  p_assignment_action_id         NUMBER               --
--                  p_payroll_id                   NUMBER               --
--                  p_balance_name                 VARCHAR2             --
--                  p_end_date                     DATE                 --
--                  p_duration                     NUMBER               --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_average_salary
         (p_assignment_id        IN NUMBER
	 ,p_assignment_action_id IN NUMBER
	 ,p_payroll_id           IN NUMBER
	 ,p_balance_name         IN VARCHAR2
	 ,p_end_date             IN DATE
	 ,p_duration             IN NUMBER
	 )
RETURN NUMBER;

--------------------------------------------------------------------------
-- Name           : check_notice_period                                 --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Internal Proc to be called for validation           --
-- Parameters     :                                                     --
--             IN : p_organization_id        NUMBER                     --
--                  p_org_info_type_code     VARCHAR2                   --
--                  p_emp_category           VARCHAR2                   --
--                  p_notice_period          VARCHAR2                   --
--                  p_calling_procedure      VARCHAR2                   --
--            OUT : p_message_name           VARCHAR2                   --
--                  p_token_name             pay_in_utils.char_tab_type --
--                  p_token_value            pay_in_utils.char_tab_type --
--------------------------------------------------------------------------
PROCEDURE check_notice_period
          (p_organization_id     IN NUMBER
	  ,p_org_information_id  IN NUMBER
	  ,p_org_info_type_code  IN VARCHAR2
	  ,p_emp_category        IN VARCHAR2
   	  ,p_notice_period       IN VARCHAR2
	  ,p_calling_procedure   IN VARCHAR2
	  ,p_message_name        OUT NOCOPY VARCHAR2
	  ,p_token_name          OUT NOCOPY pay_in_utils.char_tab_type
	  ,p_token_value         OUT NOCOPY pay_in_utils.char_tab_type);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_GRATUITY		                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate gratuity as required for India--
--                  Localization.                                       --
--                                                                      --
-- Parameters     :							--
--             IN : p_element_entry_id        NUMBER                    --
--                  p_effective_date          DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
--------------------------------------------------------------------------
PROCEDURE check_gratuity
             (p_element_entry_id        IN NUMBER
             ,p_effective_date          IN DATE
	     ,p_calling_procedure       IN VARCHAR2
	     ,p_message_name            OUT NOCOPY VARCHAR2
	     ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_GRATUITY_ENTRY                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to handle creation of Gratuity entry for  --
--                  terminated employee based on conditions as required --
--                  for India Localization.                             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE create_gratuity_entry
             (p_period_of_service_id    IN NUMBER
             ,p_business_group_id       IN NUMBER
             ,p_actual_termination_date IN DATE
             ,p_calling_procedure       IN VARCHAR2
             ,p_message_name            OUT NOCOPY VARCHAR2
             ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
             ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              );

--------------------------------------------------------------------------
--                                                                      --
-- Name         : DELETE_GRATUITY_ENTRY                                 --
-- Type         : Procedure                                             --
-- Access       : Public                                                --
-- Description 	: Procedure to delete 'Gratuity Information' Entry      --
--                if termination is reversed for the employee.          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_period_of_service_id    NUMBER                    --
--                  p_business_group_id       NUMBER                    --
--                  p_actual_termination_date DATE                      --
--                  p_calling_procedure       VARCHAR2                  --
--            OUT : p_message_name            VARCHAR2                  --
--                  p_token_name              pay_in_utils.char_tab_type--
--                  p_token_value             pay_in_utils.char_tab_type--
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   19-OCT-04  statkar   Created this procedure                    --
--------------------------------------------------------------------------
PROCEDURE delete_gratuity_entry
              (p_period_of_service_id    IN NUMBER
              ,p_business_group_id       IN NUMBER
              ,p_actual_termination_date IN DATE
              ,p_calling_procedure       IN VARCHAR2
              ,p_message_name            OUT NOCOPY VARCHAR2
              ,p_token_name              OUT NOCOPY pay_in_utils.char_tab_type
              ,p_token_value             OUT NOCOPY pay_in_utils.char_tab_type
              ) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_value_on_termination                            --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return balance value as of the          --
--                  termination month.                                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id                NUMBER               --
--                  p_end_date                     DATE                 --
--                  p_balance_name                 VARCHAR2             --
--                  p_dimension_name               VARCHAR2             --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06-Jan-05  lnagaraj   Created this function                    --
--------------------------------------------------------------------------

FUNCTION get_value_on_termination
    (p_assignment_id      IN NUMBER
    ,p_end_date IN DATE
    ,p_balance_name IN VARCHAR2
    ,p_dimension_name IN VARCHAR2
    )
RETURN NUMBER;

--

END pay_in_termination_pkg;

/
