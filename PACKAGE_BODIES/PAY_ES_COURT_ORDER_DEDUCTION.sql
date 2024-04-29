--------------------------------------------------------
--  DDL for Package Body PAY_ES_COURT_ORDER_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_COURT_ORDER_DEDUCTION" as
/* $Header: pyescodc.pkb 120.0.12010000.2 2008/08/06 07:11:18 ubhat ship $ */
--------------------------------------------------------------------------------
-- CALC_COURT_ORDER_DEDUCTION
--------------------------------------------------------------------------------
FUNCTION calc_court_order_deduction(p_business_gr_id NUMBER
                                   ,p_effective_date DATE
                                   ,p_minimum_wage   NUMBER
                                   ,p_annual_salary  NUMBER
                                   ,p_age            NUMBER) RETURN NUMBER
IS
    CURSOR csr_get_table_range(c_salary         NUMBER
                              ,c_wage           NUMBER
                              ,c_effective_date DATE) IS
    SELECT /*+ ORDERED*/ to_number(pur.row_low_range_or_name) Low_value
           ,to_number(pur.row_high_range) High_value
    FROM    pay_user_tables put
           ,pay_user_rows_f pur
    WHERE   put.user_table_name = 'ES_COURT_ORDER_DEDUCTION_SCALE'
    AND     put.user_table_id = pur.user_table_id
    AND     put.legislation_code = 'ES'
    AND     pur.legislation_code = 'ES'
    AND     (c_salary > to_number(pur.row_low_range_or_name) * c_wage
            OR c_salary BETWEEN to_number(pur.row_low_range_or_name) * c_wage
                            AND to_number(pur.row_high_range * c_wage))
    AND     c_effective_date between pur.effective_start_date AND pur.effective_end_date
    ORDER BY 1;
    --
    l_perc NUMBER;
    l_co_deduction NUMBER;
    l_salary NUMBER;
    --
BEGIN
    --
    l_co_deduction := 0;
    l_salary := p_annual_salary;
    FOR l_rec in csr_get_table_range(p_annual_salary
                                    ,p_minimum_wage
                                    ,p_effective_date) LOOP
        hr_utility.trace('High Val :'||l_rec.high_value||'  Low Val :'||l_rec.low_value);
        BEGIN
            l_perc := hruserdt.get_table_value(p_bus_group_id     =>  p_business_gr_id
                                 ,p_table_name     => 'ES_COURT_ORDER_DEDUCTION_SCALE'
                                 ,p_col_name       => 'DEDUCTION_SCALE'
                                 ,p_row_value      => l_rec.low_value
                                 ,p_effective_date => p_effective_date);
        EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		        l_perc := 0;
    	END;
        hr_utility.trace('High Val :'||l_rec.high_value||'  Low Val :'||l_rec.low_value||' perc :'||l_perc);
        l_co_deduction := l_co_deduction + (LEAST(p_minimum_wage, l_salary)* l_perc/100);
        l_salary := l_salary - p_minimum_wage;
    END LOOP;

    RETURN l_co_deduction;
END calc_court_order_deduction;
--
END pay_es_court_order_deduction;

/
