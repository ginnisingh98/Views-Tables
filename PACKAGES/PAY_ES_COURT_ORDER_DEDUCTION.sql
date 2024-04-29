--------------------------------------------------------
--  DDL for Package PAY_ES_COURT_ORDER_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ES_COURT_ORDER_DEDUCTION" AUTHID CURRENT_USER as
/* $Header: pyescodc.pkh 120.0.12000000.1 2007/01/17 18:59:45 appldev noship $ */
--
FUNCTION calc_court_order_deduction(p_business_gr_id NUMBER
                                   ,p_effective_date DATE
                                   ,p_minimum_wage   NUMBER
                                   ,p_annual_salary  NUMBER
                                   ,p_age            NUMBER) RETURN NUMBER;
--
END pay_es_court_order_deduction;

 

/
