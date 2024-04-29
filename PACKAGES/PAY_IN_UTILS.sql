--------------------------------------------------------
--  DDL for Package PAY_IN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_UTILS" AUTHID CURRENT_USER AS
/* $Header: pyinutil.pkh 120.15 2008/01/12 17:13:41 lnagaraj noship $ */

  TYPE char_tab_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MAX_ACT_SEQUENCE                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : This function returns the maximum action sequence   --
--                  for a given assignment id and process type          --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_process_type   VARCHAR2                           --
--                  p_effective_date DATE                               --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_max_act_sequence (p_assignment_id  IN NUMBER
                              ,p_process_type   IN VARCHAR2
                              ,p_effective_date IN DATE
                               )
RETURN NUMBER;


----------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_LOCATION                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the location based on the trace    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_step        number                                --
--                  p_trace       varchar2                              --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE set_location (p_trace     IN   BOOLEAN
                       ,p_message   IN   VARCHAR2
                       ,p_step      IN   INTEGER
                       );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : TRACE                                               --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the trace                          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_value       varchar2                              --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE trace (p_message   IN   VARCHAR2
                ,p_value     IN   VARCHAR2);


--------------------------------------------------------------------------
--                                                                      --
-- Name           : TRACE                                               --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to set the trace in Fast formulas          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_value       varchar2                              --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION trace (p_message IN VARCHAR2
               ,p_value   IN VARCHAR2) RETURN NUMBER ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PAY_MESSAGE                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to construct the message for FF            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message_name        VARCHAR2                      --
--                  p_token1              VARCHAR2                      --
--                  p_token2              VARCHAR2                      --
--                  p_token3              VARCHAR2                      --
--                  p_token4              VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_pay_message
            (p_message_name      IN VARCHAR2
            ,p_token1            IN VARCHAR2 DEFAULT NULL
            ,p_token2            IN VARCHAR2 DEFAULT NULL
            ,p_token3            IN VARCHAR2 DEFAULT NULL
            ,p_token4            IN VARCHAR2 DEFAULT NULL
	    )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NULL_MESSAGE                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to null the messages                       --
-- Parameters     :                                                     --
--------------------------------------------------------------------------
PROCEDURE null_message
           (p_token_name   IN OUT NOCOPY pay_in_utils.char_tab_type
           ,p_token_value  IN OUT NOCOPY pay_in_utils.char_tab_type);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : RAISE_MESSAGE                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to set and raise the messages              --
-- Parameters     :                                                     --
--------------------------------------------------------------------------
  PROCEDURE raise_message
           (p_application_id IN NUMBER
	   ,p_message_name IN VARCHAR2
	   ,p_token_name   IN OUT NOCOPY pay_in_utils.char_tab_type
           ,p_token_value  IN OUT NOCOPY pay_in_utils.char_tab_type);
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_USER_TABLE_VALUE                                --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the user table value              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id   NUMBER                        --
--                  p_table_name          VARCHAR2                      --
--                  p_column_name         VARCHAR2                      --
--                  p_row_name            VARCHAR2                      --
--                  p_row_value           VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
--            OUT : p_message             VARCHAR2                      --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_user_table_value
            (p_business_group_id      IN NUMBER
            ,p_table_name             IN VARCHAR2
            ,p_column_name            IN VARCHAR2
	    ,p_row_name               IN VARCHAR2
            ,p_row_value              IN VARCHAR2
	    ,p_effective_date         IN DATE
	    ,p_message                OUT NOCOPY VARCHAR2
	    )
RETURN VARCHAR2;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_RUN_TYPE_NAME                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the run type name                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_payroll_action_id                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_run_type_name (p_payroll_action_id     IN NUMBER,
                            p_assignment_action_id  IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_PERSON_ID                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the person_id of the assignment    --
--                  as of effective date. IF effective date is null     --
--                  then details are retrieved as of sysdate.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_effective_date DATE                               --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_person_id
    (p_assignment_id  IN per_assignments_f.assignment_id%TYPE
    ,p_effective_date IN DATE default null)
RETURN per_assignments_f.person_id%TYPE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : NEXT_TAX_YEAR                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the beginning of the next finan-   --
--                  cial year calculated based of the p_date input.     --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date DATE                                         --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION next_tax_year(p_date IN  DATE)
RETURN DATE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_EFFECTIVE_DATE                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the calculates the effective date  --
--                  based on the following conditions:                  --
--                  1) If effective date is passed returns the same     --
--                  2) Else use the System date.                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_effective_date DATE                               --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_effective_date(p_effective_date IN DATE)
RETURN DATE;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ASSIGNMENT_ID                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function returns the assignment_if of the person    --
--                  as of effective date. IF effective date is null     --
--                  then details are retrieved as of sysdate.           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id      NUMBER                             --
--                  p_effective_date DATE                               --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_assignment_id
    (p_person_id      IN per_people_f.person_id%TYPE
    ,p_effective_date IN DATE default null)
RETURN per_assignments_f.assignment_id%TYPE;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : validate_dates                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if the effective end date is   --
--                  greater than or equal to effective start date .     --
-- Parameters     :                                                     --
--             IN :     p_effective_start_date   IN DATE                --
--                      p_effective_end_date     IN DATE                --
--         RETURN :   BOOLEAN                                           --
--------------------------------------------------------------------------
FUNCTION validate_dates(p_start_date IN DATE,
                        p_end_date   IN DATE)
RETURN BOOLEAN;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_org_class                                       --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if the organization passed has --
--                  the classification enabled                          --
-- Parameters     :                                                     --
--             IN :     p_effective_start_date   IN DATE                --
--                      p_effective_end_date     IN DATE                --
--         RETURN :   BOOLEAN                                           --
--------------------------------------------------------------------------
FUNCTION chk_org_class(p_organization_id IN NUMBER,
                       p_org_class       IN VARCHAR2)
RETURN BOOLEAN;


-------------------------------------------------------------------------
--                                                                      --
-- Name           : number_to_words                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns the number passed to the      --
--                  function in words.                                  --
-- Parameters     :                                                     --
--             IN :   p_value   IN NUMBER                               --
--         RETURN :   VARCHAR2                                          --
--------------------------------------------------------------------------
FUNCTION number_to_words ( p_value IN number)
RETURN VARCHAR2;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : encode_html_string                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This procedure encodes the HTML literals.		--
--                                                                      --
-- Parameters     :                                                     --
--             IN :   p_value   IN NUMBER                               --
--         RETURN :   VARCHAR2                                          --
--------------------------------------------------------------------------
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid   Bug      Description                       --
--------------------------------------------------------------------------
-- 1.0   22/12/04   aaagarwa 4070869  Created this function             --
--------------------------------------------------------------------------

FUNCTION encode_html_string(p_value IN VARCHAR2)
RETURN VARCHAR2;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_SCL_SEGMENT_ON_DATE                             --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Returns                                             --
-- Parameters     :                                                     --
--             IN : p_assigment_id        VARCHAR2                      --
--                : p_business_group_id   NUMBER                        --
--                : p_date                DATE                          --
--                : p_column              VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------


FUNCTION get_scl_segment_on_date(p_assignment_id     IN NUMBER
                              ,p_business_group_id IN NUMBER
                              ,p_date              IN DATE
                              ,p_column            IN VARCHAR2)
RETURN VARCHAR2 ;



-------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_element_link                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function checks if an assignment is eligible   --
--                  for an element as on a given date                   --
-- Parameters     :                                                     --
--             IN :     p_element_name    VARCHAR2                      --
--                      p_assignment_id   NUMBER                        --
--                      p_effective_date  DATE                          --
--            OUT :     p_element_link_id NUMBER                        --
--         RETURN :     VARCHAR2                                        --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   27/12/04  lnagaraj   Created this function                     --
--------------------------------------------------------------------------
FUNCTION chk_element_link(p_element_name IN VARCHAR2
                         ,p_assignment_id  IN NUMBER
			 ,p_effective_date IN DATE
      		         ,p_element_link_id OUT NOCOPY NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------
--                                                                      --
-- Name           : get_element_link_id                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : This function returns element link id for an        --
--                  assignment for an element as on a given date        --
-- Parameters     :                                                     --
--             IN :     p_assignment_id   NUMBER                        --
--                      p_effective_date  DATE                          --
--                      p_element_type_id NUMBER                        --
--         RETURN :     NUMBER                                          --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   06/12/05  aaagarwa   Created this function                     --
--------------------------------------------------------------------------
FUNCTION get_element_link_id(p_assignment_id   IN NUMBER
                            ,p_effective_date  IN DATE
                            ,p_element_type_id IN NUMBER
                            )
RETURN NUMBER;
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
         )
RETURN VARCHAR2;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ACTION_TYPE                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the action_type of an asact_id   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id  NUMBER                      --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_action_type
         (p_assignment_action_id  IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TAX_UNIT_ID                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the tax unit id for an assignment--
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id  NUMBER                             --
--                  p_effective_date DATE                               --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_tax_unit_id
         (p_assignment_id  IN NUMBER
          ,p_effective_date DATE
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_FORMULA_ID                                      --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the formula_id                    --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_formula_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_formula_id
         (p_effective_date   IN DATE
         ,p_formula_name     IN VARCHAR2
         )
RETURN NUMBER ;

--------------------------------------------------------------------------
-- Name           : GET_ELEMENT_TYPE_ID                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the element_type_id               --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_element_type_id
         (p_effective_date    IN DATE
         ,p_element_name      IN VARCHAR2
         )
RETURN NUMBER ;

--------------------------------------------------------------------------
-- Name           : GET_BALANCE_TYPE_ID                                 --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the balance_type_id               --
-- Parameters     :                                                     --
--             IN : p_balance_name        VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_balance_type_id
         (p_balance_name      IN VARCHAR2
         )
RETURN NUMBER;

--------------------------------------------------------------------------
-- Name           : GET_INPUT_VALUE_ID                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the input_value_id                --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_id          NUMBER                        --
--                : p_input_value         VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_input_value_id
         (p_effective_date    IN DATE
         ,p_element_id        IN NUMBER
	 ,p_input_value       IN VARCHAR2
         )
RETURN NUMBER ;

--------------------------------------------------------------------------
-- Name           : GET_INPUT_VALUE_ID                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the input_value_id                --
-- Parameters     :                                                     --
--             IN : p_effective_date      DATE                          --
--                : p_element_id          NUMBER                        --
--                : p_input_value         VARCHAR2                      --
--            OUT : N/A                                                 --
--         RETURN : Number                                              --
--------------------------------------------------------------------------
FUNCTION  get_input_value_id
         (p_effective_date    IN DATE
         ,p_element_name      IN VARCHAR2
	 ,p_input_value       IN VARCHAR2
         )
RETURN NUMBER ;

--------------------------------------------------------------------------
-- Name           : GET_TEMPLATE_ID                                     --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
FUNCTION get_template_id
         (p_template_name     IN    VARCHAR2
         )
RETURN NUMBER ;

--------------------------------------------------------------------------
-- Name           : GET_PERSON_NAME                                     --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the person name based on person id--
-- Parameters     :                                                     --
--             IN : p_person_id       IN  NUMBER                        --
--                : p_effective_date  IN  DATE                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_person_name
         (p_person_id      IN NUMBER
         ,p_effective_date IN DATE
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_ORGANIZATION_NAME                               --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the organization name             --
-- Parameters     :                                                     --
--             IN : p_organization_id IN  NUMBER                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_organization_name
         (p_organization_id      IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_PAYMENT_NAME                                    --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the payment method name           --
-- Parameters     :                                                     --
--             IN : p_payment_type_id IN  NUMBER                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_payment_name
         (p_payment_type_id      IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_BANK_NAME                                       --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the bank name                     --
-- Parameters     :                                                     --
--             IN : p_org_information_id IN  NUMBER                     --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_bank_name
         (p_org_information_id   IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_ARCHIVE_REF_NUM                                 --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the form 24Q or 24QC ref number.  --
-- Parameters     :                                                     --
--             IN : p_year               IN VARCHAR2                    --
--                : p_quarter            IN VARCHAR2                    --
--                : p_return_type        IN VARCHAR2                    --
--                : p_organization_id    IN NUMBER                      --
--                : p_action_context_id  IN NUMBER                      --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_archive_ref_num
         (p_year               IN VARCHAR2,
          p_quarter            IN VARCHAR2,
          p_return_type        IN VARCHAR2,
          p_organization_id    IN NUMBER,
          p_action_context_id  IN NUMBER
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_ADDR_DFF_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : Function to fetch the segments of 'Personal Address --
--                : ' Information' DFF for IN localization.             --
-- Parameters     :                                                     --
--             IN : p_address_id    IN  NUMBER                          --
--                : p_segment_no    IN  VARCHAR2                        --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_addr_dff_details
         (p_address_id   IN NUMBER
         ,p_segment_no   IN VARCHAR2
         )
RETURN VARCHAR2;


--------------------------------------------------------------------------
-- Name           : get_processing_type                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to get processing type                     --
--                  (Non-recurring/Recurring) of an element             --
-- Parameters     :                                                     --
--             IN :   p_element_type_id   NUMBER                        --
--                    p_business_group_id NUMBER                        --
--                    p_earned_date       DATE                          --
--------------------------------------------------------------------------
FUNCTION get_processing_type
    (p_element_type_id          IN NUMBER
    ,p_business_group_id        IN NUMBER
    ,p_earned_date              IN DATE
    )
RETURN VARCHAR;

--------------------------------------------------------------------------
-- Name           : chk_business_group                                  --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to check the business group as per the     --
--                : profile value.                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id IN  NUMBER                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION chk_business_group
         (p_assignment_id   IN NUMBER
         )
RETURN NUMBER;

--------------------------------------------------------------------------
-- Name           : INS_FORM_RES_RULE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to update element details in post-process --
-- Parameters     :                                                     --
--             IN : p_business_group_id          NUMBER                 --
--                : p_effective_date             DATE                   --
--                : p_status_processing_rule_id  NUMBER                 --
--                : p_result_name                VARCHAR2               --
--                : p_result_rule_type           VARCHAR2               --
--                : p_element_name               VARCHAR2               --
--                : p_input_value_name           VARCHAR2               --
--                : p_severity_level             VARCHAR2               --
--                : p_element_type_id            NUMBER                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE ins_form_res_rule
 (
  p_business_group_id          NUMBER,
  p_effective_date             DATE ,
  p_status_processing_rule_id  NUMBER,
  p_result_name                VARCHAR2,
  p_result_rule_type           VARCHAR2,
  p_element_name               VARCHAR2 DEFAULT NULL,
  p_input_value_name           VARCHAR2 DEFAULT NULL,
  p_severity_level             VARCHAR2 DEFAULT NULL,
  p_element_type_id            NUMBER DEFAULT NULL
 );

--------------------------------------------------------------------------
-- Name           : DEL_FORM_RES_RULE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : Procedure to delete formula setup for elements      --
-- Parameters     :                                                     --
--             IN : p_element_type_id_id         NUMBER                 --
--                : p_effective_date             DATE                   --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE del_form_res_rule
        (p_element_type_id   IN  NUMBER,
	 p_effective_date    IN  DATE
        );

--------------------------------------------------------------------------
-- Name           : DELETE_BALANCE_FEEDS                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the template_id                  --
-- Parameters     :                                                     --
--             IN : p_template_name       VARCHAR2                      --
--            OUT : p_template_id         NUMBER                        --
--         RETURN : N/A                                                 --
--------------------------------------------------------------------------
PROCEDURE delete_balance_feeds
         (p_balance_name     IN    VARCHAR2
	 ,p_element_name     IN    VARCHAR2
	 ,p_input_value_name IN    VARCHAR2
	 ,p_effective_date   IN    DATE
         );

--------------------------------------------------------------------------
-- Name           : GET_SECONDARY_CLASSIFICATION                        --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the secondary classification     --
-- Parameters     :                                                     --
--             IN : p_element_type_id     NUMBER                        --
--            OUT : p_date_earned         DATE                          --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_secondary_classification
         (p_element_type_id     NUMBER
         ,p_date_earned         DATE
         )
RETURN NUMBER;

--------------------------------------------------------------------------
-- Name           : GET_CONFIGURATION_INFO                              --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the configuartion information    --
-- Parameters     :                                                     --
--             IN : p_element_type_id     NUMBER                        --
--            OUT : p_date_earned         DATE                          --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_configuration_info
         (p_element_type_id     NUMBER
         ,p_date_earned         DATE
         )
RETURN VARCHAR2;
--------------------------------------------------------------------------
-- Name           : GET_ELEMENT_ENTRY_END_DATE                          --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to fetch the element entry date           --
-- Parameters     :                                                     --
--             IN : p_element_entry_id    NUMBER                        --
--         RETURN : DATE                                                --
--------------------------------------------------------------------------
FUNCTION get_element_entry_end_date
         (p_element_entry_id     NUMBER
         )
RETURN DATE;
--------------------------------------------------------------------------
-- Name           : GET_CONTACT_RELATIONSHIP                            --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the relationship between 2 persons              --
-- Parameters     :                                                     --
--             IN : p_asg_id    NUMBER                                  --
--                : p_contact_person_id NUMBER                          --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------
FUNCTION get_contact_relationship
         (p_asg_id     NUMBER
	 ,p_contact_person_id NUMBER
         )
RETURN VARCHAR2;
--------------------------------------------------------------------------
-- Name           : GET_HIRE_DATE                                       --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the hire date of an assignment                 --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--         RETURN : DATE                                                --

--------------------------------------------------------------------------


FUNCTION get_hire_date(p_assignment_id NUMBER)
RETURN DATE;

--------------------------------------------------------------------------
-- Name           : GET_POSITION_NAME                                   --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the position                                   --
-- Parameters     :                                                     --
--             IN : p_assignment_id    NUMBER                           --
--                : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------

FUNCTION get_position_name
         (p_assignment_id     NUMBER
	 ,p_effective_date DATE
         )
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Name           : GET_AGE                                             --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the age of a person as on a date               --
-- Parameters     :                                                     --
--             IN : p_person_id        NUMBER                           --
--                : p_effective_date   DATE                             --
--         RETURN : NUMBER                                              --

--------------------------------------------------------------------------

FUNCTION get_age(p_person_id in number
                ,p_effective_date in date)
RETURN NUMBER ;
--------------------------------------------------------------------------
-- Name           : GET_LTC_BLOCK                                       --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the current LTC Block                          --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------

FUNCTION get_ltc_block(p_effective_date in date)
RETURN VARCHAR2 ;
--------------------------------------------------------------------------
-- Name           : GET_PREV_LTC_BLOCK                                  --
-- Type           : fUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Gets the previous LTC Block                         --
-- Parameters     :                                                     --
--             IN : p_effective_date   DATE                             --
--         RETURN : VARCHAR2                                            --

--------------------------------------------------------------------------


FUNCTION get_prev_ltc_block(p_effective_date in date)
RETURN VARCHAR2 ;

END pay_in_utils;

/
