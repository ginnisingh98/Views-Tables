--------------------------------------------------------
--  DDL for Package Body PAY_NZ_EMS_TAX_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_EMS_TAX_RATE" as
/*  $Header: pynzemsrt.pkb 120.0.12010000.2 2008/11/10 07:26:32 dduvvuri noship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  The package has a function which checks if the value of Tax Rate input
**  being used is NULL or not.
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  07-NOV-2009 dduvvuri  7480679   Created
**  10-NOV-2009 dduvvuri  7480679   Function inputs and body changed
*/

FUNCTION get_tax_rate
(
   p_given_date  IN DATE
   ,p_run_result_id   IN NUMBER
)
RETURN VARCHAR2
IS

    l_input_value_id   pay_input_values_f.input_value_id%TYPE;

    l_result number := NULL;

  CURSOR get_rate_input_value
    (c_effective_date  date)
     IS
        SELECT pivf.input_value_id
        FROM   pay_input_values_f pivf
        WHERE  pivf.element_type_id = (select distinct element_type_id
	                               from pay_element_types_f
				       where legislation_code = 'NZ'
				       and element_name = 'PAYE Information'
				       )
        AND    upper(pivf.name) = 'TAX RATE'
        AND    c_effective_date between pivf.effective_start_date and pivf.effective_end_date;

    CURSOR  get_rate_result_value
    (c_run_result_id  pay_run_result_values.run_result_id%TYPE
    ,c_input_value_id pay_run_result_values.input_value_id%TYPE)
    IS
    SELECT prrv.result_value
        FROM   pay_run_result_values prrv
        WHERE  prrv.run_result_id  = c_run_result_id
        AND    prrv.input_value_id = c_input_value_id;

BEGIN

    OPEN get_rate_input_value(p_given_date);
    FETCH get_rate_input_value INTO l_input_value_id;
    CLOSE get_rate_input_value;

    IF l_input_value_id IS NOT NULL
    THEN
        OPEN get_rate_result_value(p_run_result_id,l_input_value_id);
        FETCH get_rate_result_value INTO l_result;
        CLOSE get_rate_result_value;
    END IF;


    IF l_result IS NULL THEN
        RETURN 'N';
    ELSE
        RETURN 'Y';
    END IF;

END get_tax_rate;

end pay_nz_ems_tax_rate ;

/
