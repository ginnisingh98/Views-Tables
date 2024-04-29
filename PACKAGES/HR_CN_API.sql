--------------------------------------------------------
--  DDL for Package HR_CN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CN_API" AUTHID CURRENT_USER AS
/* $Header: hrcnapi.pkh 120.1.12000000.1 2007/01/22 14:29:42 appldev ship $ */

  g_package  VARCHAR2(33);

  TYPE char_tab_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

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

----------------------------------------------------------------------------
--                                                                      --
-- Name           : SET_LOCATION                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to set the location irrespective of trace --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_message     varchar2                              --
--                  p_step        number                                --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE set_location (p_message   IN   VARCHAR2
                       ,p_step      IN   INTEGER
                       );

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_LOOKUP                                        --
-- Type           : Procedure                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the lookupcode in lookuptype   --
--                  Function will return true in case the lookupcode is --
--                  found in the lookuptype.Used in the check_employee. --
-- Parameters     :                                                     --
--             IN : p_value     varchar2                                --
--                  p_lookup_name             varchar2                  --
--         RETURN : Boolean                                             --
---------------------------------------------------------------------------
PROCEDURE check_lookup (
            p_lookup_type      IN VARCHAR2,
            p_argument         IN VARCHAR2,
            p_argument_value   IN VARCHAR2
           );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_POSITIVE_INTEGER                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the char as positive integer   --
-- Parameters     :                                                     --
--             IN : p_value     varchar2                                --
--         RETURN : Boolean                                             --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION is_positive_integer
	(p_value IN NUMBER
        )
RETURN BOOLEAN;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_VALID_PERCENTAGE                                 --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to validate the char as positive percentage--
-- Parameters     :                                                     --
--             IN : p_value     varchar2                                --
--         RETURN : Boolean                                             --
--                                                                      --
---------------------------------------------------------------------------

FUNCTION is_valid_percentage
	( p_value IN NUMBER
  	)
RETURN BOOLEAN;

--------------------------------------------------------------------------
-- Name           : IS_VALID_POSTAL_CODE                                --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : The function validates the postal code ,checks to   --
--                  see if the postal code is a 6 digit value and that  --
--                  all digits are numbers,if so returns true else false--
-- Parameters     :                                                     --
--             IN : p_value_to_be_checked     IN  VARCHAR2              --
--         RETURN : Boolean                                             --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION is_valid_postal_code
	(p_value IN VARCHAR2
	 )
RETURN BOOLEAN;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHK_PERSON_TYPE                                     --
-- Type           : Function                                            --
-- Access         : Public                                             --
-- Description    : Returns true/false if p_code is a valid Person Type --
-- Parameters     :                                                     --
--             IN : p_code VARCHAR2                                     --
--            OUT : N/A                                                 --
--         RETURN : BOOLEAN                                             --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION chk_person_type
        (p_code in varchar2)
RETURN BOOLEAN;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORGANIZATION                                  --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks if the organization id          --
--                  belongs to the business group specified for the     --
--                  legislation             --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_business_group_id   IN  NUMBER                    --
--                  p_legislation_code    IN  NUMBER                    --
--                  p_effective_date      IN  DATE                      --
--         RETURN : Boolean                                             --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE check_organization
		(p_organization_id   IN NUMBER
                ,p_business_group_id IN NUMBER
                ,p_legislation_code  IN VARCHAR2
	        ,p_effective_date    IN DATE
		) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORG_CLASS                                     --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks if org classification is as per --
--                  the classification passed as a parameter            --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_classification      IN  VARCHAR2                  --
--                                                                      --
--------------------------------------------------------------------------

PROCEDURE check_org_class
		(p_organization_id   IN NUMBER
                ,p_classification    IN VARCHAR2
		) ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ORG_TYPE                                      --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : The function checks if org type is as per           --
--                  the type passed as a parameter                      --
-- Parameters     :                                                     --
--             IN : p_organization_id     IN  NUMBER                    --
--                : p_type                IN  VARCHAR2                  --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE check_org_type
		(p_organization_id   IN NUMBER
                ,p_type              IN VARCHAR2
		) ;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : IS_NUMBER                                           --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Procedure to check if a value is numeric            --
-- Parameters     :                                                     --
--             IN : p_value                   varchar2                  --
--                                                                      --
---------------------------------------------------------------------------

FUNCTION is_number
            (p_value         in      varchar2)
RETURN BOOLEAN;

--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_CIN                                           --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the citizen identification num--
--                : CIN should be mandatory in case of Chinese EMP/APL  --
-- Parameters     :                                                     --
--             IN : p_business_group_id    NUMBER                       --
--                  p_national_identifier  VARCHAR2,                    --
--                  p_person_type_id       NUMBER,                      --
--                  p_expatriate_indicator VARCHAR2,                    --
--                  p_effective_date       DATE,                        --
--                  p_person_id            NUMBER                       --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE check_cin
  		(  p_business_group_id      NUMBER,
		   p_national_identifier    VARCHAR2,
   		   p_person_type_id         NUMBER,
   		   p_expatriate_indicator   VARCHAR2,
   		   p_effective_date         DATE,
   		   p_person_id              NUMBER
                 );



--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_TAX_DEPENDENCE                                --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the tax dependence on         --
--                  the exemption indicator.                            --
--                  Exemption Indicator    Tax Percentage               --
--                  N                      Should be null               --
--                  Y                      Should be valid %            --
-- Parameters     :                                                     --
--             IN : p_tax_exemption_indicator varchar2                  --
--                : p_percentage              varchar2                  --
--            OUT : p_return_number           number                    --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE check_tax_dependence
		( p_tax_exemption_indicator IN VARCHAR2
                 ,p_percentage              IN NUMBER
                 );

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_BUS_GRP                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id NUMBER                          --
--                  p_legislation_code  VARCHAR2                        --
---------------------------------------------------------------------------
PROCEDURE check_bus_grp (p_business_group_id IN NUMBER
                        ,p_legislation_code  IN VARCHAR2
                        );

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PERSON                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_person_id         NUMBER                          --
--                  p_legislation_code  VARCHAR2                        --
---------------------------------------------------------------------------
PROCEDURE check_person (p_person_id         IN NUMBER
                       ,p_legislation_code  IN VARCHAR2
                       ,p_effective_date    IN DATE
                        );

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ADDRESS                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Business Group            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_address_id         NUMBER                          --
--                  p_address_style     VARCHAR2                        --
---------------------------------------------------------------------------
PROCEDURE check_address (p_address_id  IN NUMBER
                        ,p_address_style IN VARCHAR2
                        );


----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ASSIGNMENT                                     --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Assignment                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_id         NUMBER                       --
--                  p_legislation_code    VARCHAR2                      --
--                  p_effective_date       DATE                         --
---------------------------------------------------------------------------
PROCEDURE check_assignment
  (p_assignment_id          IN     NUMBER
  ,p_legislation_code       IN     VARCHAR2
  ,p_effective_date         IN     DATE
  ) ;

----------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_PAYMENT_METHOD                                --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to validate the Payment Method            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_payment_method_id    NUMBER                       --
--                  p_legislation_code    VARCHAR2                      --
--                  p_effective_date       DATE                         --
---------------------------------------------------------------------------
PROCEDURE check_payment_method
  ( p_personal_payment_method_id    IN  NUMBER
    ,p_effective_date               IN  DATE
   ,p_legislation_code      IN VARCHAR2
  ) ;

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
-- Name           : GET_DFF_TL_VALUE                                    --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to fetch the translated value              --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_column_name         VARCHAR2                      --
--                  p_dff                 VARCHAR2                      --
--                  p_dff_context_code    VARCHAR2                      --
--         RETURN : VARCHAR2                                            --
--                                                                      --
---------------------------------------------------------------------------
FUNCTION get_dff_tl_value(p_column_name      IN VARCHAR2
                         ,p_dff              IN VARCHAR2
			 ,p_dff_context_code IN VARCHAR2
			 )
RETURN VARCHAR2;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : RAISE_MESSAGE                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to raise the error message                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_application_id      NUMBER                        --
--                  p_message_name        VARCHAR2                      --
--                  p_token_name          HR_CN_API.CHAR_TAB_TYPE       --
--                  p_token_value         HR_CN_API.CHAR_TAB_TYPE       --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE raise_message(p_application_id IN NUMBER
		       ,p_message_name IN VARCHAR2
		       ,p_token_name   IN OUT NOCOPY hr_cn_api.char_tab_type
	               ,p_token_value  IN OUT NOCOPY hr_cn_api.char_tab_type
		       );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_class_tl_name                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function  to raise the error message                --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_classification_name      VARCHAR2                 --
--        RETURN  : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_class_tl_name(p_classification_name IN VARCHAR2)
RETURN VARCHAR2;

END hr_cn_api;

 

/
