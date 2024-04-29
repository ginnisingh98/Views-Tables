--------------------------------------------------------
--  DDL for Package PAY_CN_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pycnrept.pkh 120.0.12000000.1 2007/01/17 17:57:04 appldev noship $ */

g_package_name     VARCHAR2(18):= 'pay_cn_report_pkg.';

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the value of a particular        --
--                  balance from PAY_ACTION_INFORMATION
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_balance_name                VARCHAR2              --
--                  p_dimension_name              VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_balance_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_balance_name              IN VARCHAR2
                       ,p_dimension_name            IN VARCHAR2 DEFAULT 'PTD'
		       )
RETURN NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ELEMENT_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the 'Pay Value' of a particular  --
--                  element from PAY_ACTION_INFORMATION                 --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_element_name                VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_element_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_element_name              IN VARCHAR2
		       )
RETURN NUMBER;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ELEMENT_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the specified input value of a   --
--                  particular element from PAY_ACTION_INFORMATION      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_assignment_action_id        NUMBER                --
--                  p_element_name                VARCHAR2              --
--                  p_input_value_name            VARCHAR2              --
--            OUT : N/A                                                 --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_element_value
                       (p_assignment_action_id      IN NUMBER
                       ,p_element_name              IN VARCHAR2
		       ,p_input_value_name          IN VARCHAR2
		       )
RETURN NUMBER;

END pay_cn_report_pkg;

 

/
