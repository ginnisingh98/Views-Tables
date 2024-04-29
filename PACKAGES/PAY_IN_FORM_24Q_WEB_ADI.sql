--------------------------------------------------------
--  DDL for Package PAY_IN_FORM_24Q_WEB_ADI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_FORM_24Q_WEB_ADI" AUTHID CURRENT_USER AS
/* $Header: pyinwadi.pkh 120.6 2007/11/22 06:32:22 rsaharay noship $ */
--Global Variable
g_assessment_year        VARCHAR2(20);
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ASSESSMENT_YEAR                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the assessment year              --
--                                                                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_assessment_year
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_ASSESSMENT_YEAR                                 --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to set the assessment year                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : VARCHAR2                                            --
---------------------------------------------------------------------------
PROCEDURE set_assessment_year(p_assessment_year  VARCHAR2);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the date earned                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id    NUMBER                    --
--         RETURN : DATE                                                --
---------------------------------------------------------------------------
FUNCTION get_date_earned
         (p_assignment_action_id    IN NUMBER
         )
RETURN DATE;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED_EE                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the date earned                  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--         RETURN : DATE                                                --
---------------------------------------------------------------------------
FUNCTION get_date_earned_ee
         (p_element_entry_id  IN NUMBER
         )
RETURN DATE;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EE_VALUE                                        --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the element entry value          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id  NUMBER                          --
--                  p_input_name        VARCHAR2                        --
--                  p_effective_date    DATE                            --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_ee_value
         (p_element_entry_id  IN NUMBER
         ,p_input_name        IN VARCHAR2
         ,p_effective_date    IN DATE
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAN_NUMBER                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tan number for an organization-
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--                  p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tan_number
         (p_assignment_id    IN NUMBER
         ,p_effective_date   IN DATE
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAN_NUMBER_EE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tan number for an organization-
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_element_entry_id NUMBER                           --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tan_number_ee
         (p_element_entry_id    IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ORG_ID                                          --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the organization id               -
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_tan_number   VARCHAR2                             --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_org_id
         (p_tan_number   IN VARCHAR2
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the balance value                --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_balance_value(p_assignment_action_id   IN NUMBER
                           ,p_balance_name           IN VARCHAR2
                           ,p_dimension              IN VARCHAR2
                           )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TOTAL_TAX_DEPOSITED                             --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the total tax deposited          --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_total_tax_deposited(p_assignment_action_id IN NUMBER
                                ,p_element_entry_id     IN NUMBER
                                ,p_effective_date       IN DATE DEFAULT NULL
                                )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_FORM_24                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create the element as per the details   --
--                  passed from the Web ADI Excel Sheet.                --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE create_form_24
        (p_assessment_year              IN VARCHAR2 DEFAULT NULL
        ,p_payroll_name                 IN VARCHAR2 DEFAULT NULL
        ,p_period                       IN VARCHAR2 DEFAULT NULL
        ,p_earned_date                  IN DATE     DEFAULT NULL
        ,p_pre_payment_date             IN DATE
        ,p_employee_id                  IN VARCHAR2
        ,p_employee_name                IN VARCHAR2 DEFAULT NULL
        ,p_taxable_income               IN NUMBER DEFAULT NULL
        ,p_income_tax_deducted          IN NUMBER DEFAULT NULL
        ,p_surcharge_deducted           IN NUMBER DEFAULT NULL
        ,p_education_cess_deducted      IN NUMBER DEFAULT NULL
        ,p_total_tax_deducted           IN NUMBER DEFAULT NULL
        ,p_amount_deposited             IN NUMBER
        ,p_voucher_number               IN VARCHAR2
        ,p_correction_flag              IN VARCHAR2
        ,p_last_updated_date            IN DATE   DEFAULT NULL
        ,p_element_entry_id             IN NUMBER DEFAULT NULL
        ,p_tan_number                   IN VARCHAR2 DEFAULT NULL
        ,p_purge_record                 IN VARCHAR2 DEFAULT NULL
 	,p_assignment_id                IN NUMBER
        );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BG_ID                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the business group id            --
--                                                                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_bg_id
RETURN NUMBER;

END pay_in_form_24q_web_adi;

/
