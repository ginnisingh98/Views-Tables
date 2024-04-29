--------------------------------------------------------
--  DDL for Package PAY_IN_BONUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_BONUS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyinbonp.pkh 120.0 2005/05/29 05:49 appldev noship $ */



--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_DATE_EARNED                                     --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return earn date                        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date_earned         date                          --
--         RETURN : VARCHAR2                                            --
--------------------------------------------------------------------------
FUNCTION get_date_earned
            (p_date_earned      IN DATE)
RETURN DATE;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BALANCE_VALUE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to get balance value for bonus             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_date_earned      date                             --
--                  p_assignment_id    number                           --
--         RETURN : NUMBER                                              --
--------------------------------------------------------------------------
FUNCTION get_balance_value
            (p_date_earned      IN DATE
            ,p_assignment_id    IN NUMBER
            ,p_last_earn_date   OUT NOCOPY DATE)
RETURN NUMBER;

END pay_in_bonus_pkg;

 

/
