--------------------------------------------------------
--  DDL for Package PAY_IN_MED_WEB_ADI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_MED_WEB_ADI" AUTHID CURRENT_USER AS
/* $Header: pyinmadi.pkh 120.1.12010000.1 2008/07/27 22:53:32 appldev ship $ */
--Global Variable
g_assessment_year        VARCHAR2(20);

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
FUNCTION get_bg_id RETURN NUMBER ;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_MEDICAL                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create and update the Medical Bill and  --
--                  Benefit element enrty as per the Med Bill details   --
--                  passed from the Web ADI Excel Sheet.                --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE create_medical
        (P_TAX_YEAR              IN VARCHAR2
        ,P_MONTH                        IN VARCHAR2   DEFAULT NULL
        ,P_BILL_DATE                    IN DATE
        ,P_NAME                         IN VARCHAR2
        ,P_BILL_NUMBER                  IN VARCHAR2   DEFAULT NULL
        ,P_BILL_AMOUNT                  IN NUMBER     DEFAULT NULL
        ,P_APPROVED_BILL_AMOUNT         IN NUMBER
        ,P_EMPLOYEE_REMARKS             IN VARCHAR2   DEFAULT NULL
        ,P_EMPLOYER_REMARKS             IN VARCHAR2   DEFAULT NULL
        ,P_ELEMENT_ENTRY_ID             IN NUMBER     DEFAULT NULL
        ,P_LAST_UPDATED_DATE            IN DATE       DEFAULT NULL
 	,P_ASSIGNMENT_ID                IN NUMBER
        ,P_EMPLOYEE_ID                  IN NUMBER
        ,P_EMPLOYEE_NAME                IN VARCHAR2
        ,P_ASSIGNMENT_EXTRA_INFO_ID     IN NUMBER
        ,P_ENTRY_DATE                   IN DATE       DEFAULT NULL
        );

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_MEDICAL_BEN                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to update the Med Ben element enrty as per --
--                  the details passed from the Web ADI Excel Sheet.    --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE create_medical_ben
( P_employee_number		        IN VARCHAR2
,P_full_name			        IN VARCHAR2
,P_effective_start_date		        IN DATE
,P_effective_end_date		        IN DATE      DEFAULT NULL
,P_Benefit			        IN NUMBER
,P_Add_to_NetPay           		IN VARCHAR2
,P_AnnualLimit                          IN NUMBER    DEFAULT NULL
,P_assignment_id			IN NUMBER
,P_element_entry_id		        IN NUMBER    DEFAULT NULL
);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_LTC_ELEMENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create and update the LTC element enrty --
--                  as per the LTC Bill details passed from the Web ADI --
--		    Excel Sheet.                                        --
--                                                                      --
---------------------------------------------------------------------------


PROCEDURE create_ltc_element
(
 P_LTCBLOCK                     IN VARCHAR2
,P_PLACE_FROM                   IN VARCHAR2
,P_PLACE_TO                     IN VARCHAR2
,P_MODE_CLASS                   IN VARCHAR2
,P_CARRY_OVER                   IN VARCHAR2   DEFAULT NULL
,P_SUBMITTED                    IN NUMBER
,P_EXEMPTED                     IN NUMBER     DEFAULT NULL
,P_ELEMENT_ENTRY_ID             IN NUMBER
,P_START_DATE                   IN DATE
,P_END_DATE                     IN DATE
,P_BILL_NUM                     IN VARCHAR2   DEFAULT NULL
,P_EE_COMMENTS                  IN VARCHAR2   DEFAULT NULL
,P_ER_COMMENTS                  IN VARCHAR2   DEFAULT NULL
,P_LAST_UPDATED_DATE            IN DATE
,P_ASSIGNMENT_ID                IN NUMBER
,P_EMPLOYEE_ID                  IN NUMBER
,P_ASSIGNMENT_EXTRA_INFO_ID     IN NUMBER
,P_ENTRY_DATE                   IN DATE       DEFAULT NULL

);


--------------------------------------------------------------------------
--                                                                      --
-- Name           : UPDATE_LTC_ELEMENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to update the LTC element enrty as per the --
--                  details passed from the Web ADI Excel Sheet.        --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE update_ltc_element
(
 p_employee_number          IN VARCHAR2
,p_full_name                IN VARCHAR2
,p_start_date                IN DATE
,p_effective_end_date       IN DATE       DEFAULT NULL
,p_fare		            IN NUMBER
,p_blockYr		    IN VARCHAR2
,p_carry		    IN VARCHAR2
,p_benefit		    IN NUMBER
,p_assignment_id            IN NUMBER
,p_element_entry_id         IN NUMBER     DEFAULT NULL
);

END ;


/
